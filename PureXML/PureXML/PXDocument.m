//
//  PXDocument.m
//  PureXML
//
//  Created by Tobias Kräntzer on 04.05.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <libxml/tree.h>
#import <libxml/xmlerror.h>

#import "PXElement.h"
#import "PXText.h"
#import "PXNode.h"
#import "PXNode+Private.h"

#import "PXDocument.h"
#import "PXDocument+Private.h"

@interface PXDocument ()
@property (nonatomic, readonly) NSMapTable *documentNodes;
@end

@implementation PXDocument

+ (instancetype)documentNamed:(NSString *)name
{
    return [self documentNamed:name inBundle:[NSBundle mainBundle]];
}

+ (instancetype)documentNamed:(NSString *)name inBundle:(NSBundle *)bundle
{
    NSString *path = [bundle pathForResource:name ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data ? [self documentWithData:data] : nil;
}

+ (instancetype)documentWithData:(NSData *)data
{
    xmlDocPtr doc = xmlReadMemory([data bytes], (int)[data length], "", nil, XML_PARSE_RECOVER);
    return doc ? [[self alloc] initWithXMLDoc:doc] : nil;
}

#pragma mark Life-cycle

- (id)init
{
    return [self initWithXMLDoc:xmlNewDoc(BAD_CAST "1.0")];
}

- (id)initWithElementName:(NSString *)name namespace:(NSString *)ns prefix:(NSString *)prefix
{
    self = [self initWithXMLDoc:xmlNewDoc(BAD_CAST "1.0")];
    if (self) {
        xmlNodePtr node = xmlNewNode(NULL, BAD_CAST[name UTF8String]);
        xmlDocSetRootElement(_xmlDoc, node);
        if (ns) {
            xmlNsPtr nsPtr = xmlNewNs(node, BAD_CAST[ns UTF8String], BAD_CAST[prefix UTF8String]);
            xmlSetNs(node, nsPtr);
        }
    }
    return self;
}

- (id)initWithElement:(PXElement *)element
{
    self = [self initWithXMLDoc:xmlNewDoc(BAD_CAST "1.0")];
    if (self) {
        xmlNodePtr node = xmlCopyNode(element.xmlNode, 1);
        xmlDocSetRootElement(_xmlDoc, node);
        px_xmlReconciliateNs(_xmlDoc, node);
    }
    return self;
}

- (id)initWithXMLDoc:(xmlDocPtr)xmlDoc
{
    self = [super init];
    if (self) {
        _xmlDoc = xmlDoc;
        _documentNodes = [NSMapTable strongToWeakObjectsMapTable];
    }
    return self;
}

- (void)dealloc
{
    xmlFreeDoc(_xmlDoc);
}

#pragma mark Data

- (NSData *)data
{
    xmlChar *buffer;
    int size;
    xmlDocDumpMemory(_xmlDoc, &buffer, &size);
    return [NSData dataWithBytesNoCopy:buffer length:size freeWhenDone:YES];
}

#pragma mark Root Element

- (PXElement *)root
{
    xmlNodePtr rootNode = xmlDocGetRootElement(self.xmlDoc);
    if (rootNode) {
        return (PXElement *)[self nodeWithXmlNode:rootNode];
    } else {
        return nil;
    }
}

#pragma NSObject

- (NSString *)description
{
    xmlChar *buffer;
    int size;
    xmlDocDumpFormatMemory(_xmlDoc, &buffer, &size, 1);
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:size freeWhenDone:YES];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

@implementation PXDocument (Private)

- (PXNode *)nodeWithXmlNode:(xmlNodePtr)xmlNode
{
    NSParameterAssert(xmlNode);

    NSValue *pointer = [NSValue valueWithPointer:xmlNode];

    PXNode *node = [self.documentNodes objectForKey:pointer];

    if (node == nil) {
        switch (xmlNode->type) {
        case XML_ELEMENT_NODE:
            node = [[PXElement alloc] initWithDocument:self xmlNode:xmlNode];
            break;

        case XML_TEXT_NODE:
            node = [[PXText alloc] initWithDocument:self xmlNode:xmlNode];
            break;

        default:
            node = [[PXNode alloc] initWithDocument:self xmlNode:xmlNode];
            break;
        }
        [self.documentNodes setObject:node forKey:pointer];
    }

    return node;
}

@end

/**
 * px_xmlTreeErrMemory:
 * @extra:  extra informations
 *
 * Handle an out of memory condition
 */
static void
px_xmlTreeErrMemory(const char *extra)
{
    NSCAssert(NO, @"Out of memory: %s", extra);
}

/**
 * xmlNewReconciliedNs:
 * @doc:  the document
 * @tree:  a node expected to hold the new namespace
 * @ns:  the original namespace
 *
 * This function tries to locate a namespace definition in a tree
 * ancestors, or create a new namespace definition node similar to
 * @ns trying to reuse the same prefix.
 * Returns the (new) namespace definition or NULL in case of error
 */
static xmlNsPtr
px_xmlNewReconciliedNs(xmlDocPtr doc, xmlNodePtr tree, xmlNsPtr ns)
{
    xmlNsPtr def;

    if ((tree == NULL) || (tree->type != XML_ELEMENT_NODE)) {
#ifdef DEBUG_TREE
        xmlGenericError(xmlGenericErrorContext,
                        "xmlNewReconciliedNs : tree == NULL\n");
#endif
        return (NULL);
    }
    if ((ns == NULL) || (ns->type != XML_NAMESPACE_DECL)) {
#ifdef DEBUG_TREE
        xmlGenericError(xmlGenericErrorContext,
                        "xmlNewReconciliedNs : ns == NULL\n");
#endif
        return (NULL);
    }
    /*
     * Search an existing namespace definition inherited.
     */
    def = xmlSearchNsByHref(doc, tree, ns->href);
    if (def != NULL)
        return (def);

    /*
     * OK, now we are ready to create a new one.
     */
    def = xmlNewNs(tree, ns->href, ns->prefix);
    return (def);
}

/**
 * xmlReconciliateNs:
 * @doc:  the document
 * @tree:  a node defining the subtree to reconciliate
 *
 * This function checks that all the namespaces declared within the given
 * tree are properly declared. This is needed for example after Copy or Cut
 * and then paste operations. The subtree may still hold pointers to
 * namespace declarations outside the subtree or invalid/masked. As much
 * as possible the function try to reuse the existing namespaces found in
 * the new environment. If not possible the new namespaces are redeclared
 * on @tree at the top of the given subtree.
 * Returns the number of namespace declarations created or -1 in case of error.
 */
int px_xmlReconciliateNs(xmlDocPtr doc, xmlNodePtr tree)
{
    xmlNsPtr *oldNs = NULL;
    xmlNsPtr *newNs = NULL;
    int sizeCache = 0;
    int nbCache = 0;

    xmlNsPtr n;
    xmlNodePtr node = tree;
    xmlAttrPtr attr;
    int ret = 0, i;

    if ((node == NULL) || (node->type != XML_ELEMENT_NODE))
        return (-1);
    if ((doc == NULL) || (doc->type != XML_DOCUMENT_NODE))
        return (-1);
    if (node->doc != doc)
        return (-1);
    while (node != NULL) {
        /*
         * Reconciliate the node namespace
         */
        if (node->ns != NULL) {
            /*
             * initialize the cache if needed
             */
            if (sizeCache == 0) {
                sizeCache = 10;
                oldNs = (xmlNsPtr *)xmlMalloc(sizeCache *
                                              sizeof(xmlNsPtr));
                if (oldNs == NULL) {
                    px_xmlTreeErrMemory("fixing namespaces");
                    return (-1);
                }
                newNs = (xmlNsPtr *)xmlMalloc(sizeCache *
                                              sizeof(xmlNsPtr));
                if (newNs == NULL) {
                    px_xmlTreeErrMemory("fixing namespaces");
                    xmlFree(oldNs);
                    return (-1);
                }
            }
            for (i = 0; i < nbCache; i++) {
                if (oldNs[i] == node->ns) {
                    node->ns = newNs[i];
                    break;
                }
            }
            if (i == nbCache) {
                /*
                 * OK we need to recreate a new namespace definition
                 */
                n = px_xmlNewReconciliedNs(doc, tree, node->ns);
                if (n != NULL) { /* :-( what if else ??? */
                    /*
                     * check if we need to grow the cache buffers.
                     */
                    if (sizeCache <= nbCache) {
                        sizeCache *= 2;
                        oldNs = (xmlNsPtr *)xmlRealloc(oldNs, sizeCache *
                                                                  sizeof(xmlNsPtr));
                        if (oldNs == NULL) {
                            px_xmlTreeErrMemory("fixing namespaces");
                            xmlFree(newNs);
                            return (-1);
                        }
                        newNs = (xmlNsPtr *)xmlRealloc(newNs, sizeCache *
                                                                  sizeof(xmlNsPtr));
                        if (newNs == NULL) {
                            px_xmlTreeErrMemory("fixing namespaces");
                            xmlFree(oldNs);
                            return (-1);
                        }
                    }
                    newNs[nbCache] = n;
                    oldNs[nbCache++] = node->ns;
                    node->ns = n;
                }
            }
        }
        /*
         * now check for namespace hold by attributes on the node.
         */
        if (node->type == XML_ELEMENT_NODE) {
            attr = node->properties;
            while (attr != NULL) {
                if (attr->ns != NULL) {
                    /*
                     * initialize the cache if needed
                     */
                    if (sizeCache == 0) {
                        sizeCache = 10;
                        oldNs = (xmlNsPtr *)xmlMalloc(sizeCache *
                                                      sizeof(xmlNsPtr));
                        if (oldNs == NULL) {
                            px_xmlTreeErrMemory("fixing namespaces");
                            return (-1);
                        }
                        newNs = (xmlNsPtr *)xmlMalloc(sizeCache *
                                                      sizeof(xmlNsPtr));
                        if (newNs == NULL) {
                            px_xmlTreeErrMemory("fixing namespaces");
                            xmlFree(oldNs);
                            return (-1);
                        }
                    }
                    for (i = 0; i < nbCache; i++) {
                        if (oldNs[i] == attr->ns) {
                            attr->ns = newNs[i];
                            break;
                        }
                    }
                    if (i == nbCache) {
                        /*
                         * OK we need to recreate a new namespace definition
                         */
                        n = px_xmlNewReconciliedNs(doc, tree, attr->ns);
                        if (n != NULL) { /* :-( what if else ??? */
                            /*
                             * check if we need to grow the cache buffers.
                             */
                            if (sizeCache <= nbCache) {
                                sizeCache *= 2;
                                oldNs = (xmlNsPtr *)xmlRealloc(oldNs,
                                                               sizeCache * sizeof(xmlNsPtr));
                                if (oldNs == NULL) {
                                    px_xmlTreeErrMemory("fixing namespaces");
                                    xmlFree(newNs);
                                    return (-1);
                                }
                                newNs = (xmlNsPtr *)xmlRealloc(newNs,
                                                               sizeCache * sizeof(xmlNsPtr));
                                if (newNs == NULL) {
                                    px_xmlTreeErrMemory("fixing namespaces");
                                    xmlFree(oldNs);
                                    return (-1);
                                }
                            }
                            newNs[nbCache] = n;
                            oldNs[nbCache++] = attr->ns;
                            attr->ns = n;
                        }
                    }
                }
                attr = attr->next;
            }
        }

        /*
         * Browse the full subtree, deep first
         */
        if ((node->children != NULL) && (node->type != XML_ENTITY_REF_NODE)) {
            /* deep first */
            node = node->children;
        } else if ((node != tree) && (node->next != NULL)) {
            /* then siblings */
            node = node->next;
        } else if (node != tree) {
            /* go up to parents->next if needed */
            while (node != tree) {
                if (node->parent != NULL)
                    node = node->parent;
                if ((node != tree) && (node->next != NULL)) {
                    node = node->next;
                    break;
                }
                if (node->parent == NULL) {
                    node = NULL;
                    break;
                }
            }
            /* exit condition */
            if (node == tree)
                node = NULL;
        } else
            break;
    }
    if (oldNs != NULL)
        xmlFree(oldNs);
    if (newNs != NULL)
        xmlFree(newNs);
    return (ret);
}
