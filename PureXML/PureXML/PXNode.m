//
//  PXNode.m
//  PureXML
//
//  Created by Tobias Kräntzer on 14.09.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <libxml/tree.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

#import "NSString+PureXML.h"

#import "PXDocument.h"
#import "PXDocument+Private.h"
#import "PXElement.h"
#import "PXText.h"

#import "PXNode.h"
#import "PXNode+Private.h"

@interface PXNode ()
@property (nonatomic, readwrite, assign) xmlNodePtr xmlNode;
@end

@implementation PXNode

#pragma mark Life-cycle

- (void)dealloc
{
    xmlNodePtr node = self.xmlNode;
    if (node->parent == 0 && xmlDocGetRootElement(self.document.xmlDoc) != node) {
        xmlFreeNode(node);
    }
}

#pragma mark Manage Structure

- (PXNode *)parent
{
    xmlNodePtr node = self.xmlNode;
    if (node->parent) {
        return [self.document nodeWithXmlNode:node->parent];
    } else {
        return nil;
    }
}

- (void)removeFromParent
{
    xmlUnlinkNode(self.xmlNode);
}

#pragma mark Content

- (NSString *)stringValue
{
    return [NSString px_stringWithContentOfXMLNode:self.xmlNode];
}

#pragma mark XPath

- (NSArray *)nodesForXPath:(NSString *)xpath usingNamespaces:(NSDictionary *)namespaces
{
    NSMutableArray *nodes = [[NSMutableArray alloc] init];
    [self enumerateNodesForXPath:xpath
                 usingNamespaces:namespaces
                           block:^(PXNode *element, BOOL *stop) {
                               [nodes addObject:element];
                           }];
    return nodes;
}

- (void)enumerateNodesForXPath:(NSString *)xpath
               usingNamespaces:(NSDictionary *)namespaces
                         block:(void (^)(PXNode *element, BOOL *stop))block
{
    if (block != nil) {
        xmlXPathContextPtr xpathCtx;
        xmlXPathObjectPtr xpathObj;

        xpathCtx = xmlXPathNewContext(self.document.xmlDoc);
        if (!xpathCtx) {
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:@"Unable to create new XPath context."
                                   userInfo:nil] raise];
        }

        xmlXPathSetContextNode(self.xmlNode, xpathCtx);

        [namespaces enumerateKeysAndObjectsUsingBlock:^(NSString *prefix, NSString *href, BOOL *stop) {
            BOOL success = xmlXPathRegisterNs(xpathCtx, BAD_CAST[prefix UTF8String], BAD_CAST[href UTF8String]) == 0;
            if (!success) {
                xmlXPathFreeContext(xpathCtx);
                [[NSException exceptionWithName:NSInternalInconsistencyException
                                         reason:[NSString stringWithFormat:@"Unable to register namespace '%@' using prefix '%@'.", href, prefix]
                                       userInfo:nil] raise];
            }
        }];

        xpathObj = xmlXPathEvalExpression(BAD_CAST[xpath UTF8String], xpathCtx);
        if (!xpathObj) {
            xmlXPathFreeContext(xpathCtx);
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Unable to evaluate xpath expression '%@'.", xpath]
                                   userInfo:nil] raise];
        }

        NSUInteger numberOfNodes = (xpathObj->nodesetval) ? xpathObj->nodesetval->nodeNr : 0;
        BOOL stop = NO;
        for (int i = 0; i < numberOfNodes && stop == NO; i++) {
            xmlNodePtr xmlNode = xpathObj->nodesetval->nodeTab[i];
            PXNode *node = [self.document nodeWithXmlNode:xmlNode];
            block(node, &stop);
        }

        xmlXPathFreeObject(xpathObj);
        xmlXPathFreeContext(xpathCtx);
    }
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object
{
    return self == object;
}

@end

@implementation PXNode (Private)

- (instancetype)initWithDocument:(PXDocument *)document xmlNode:(xmlNodePtr)xmlNode
{
    self = [super init];
    if (self) {
        _document = document;
        _xmlNode = xmlNode;
    }
    return self;
}

@end
