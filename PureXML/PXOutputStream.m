//
//  PXOutputStream.m
//  PureXML
//
//  Created by Tobias Kräntzer on 30.10.15.
//  Copyright © 2015 Tobias Kräntzer. All rights reserved.
//

#import <assert.h>
#import <libxml/tree.h>
#import <libxml/xmlIO.h>
#import <libxml/xmlwriter.h>

#import "PXDocument.h"
#import "PXElement.h"

#import "PXOutputStream.h"

XMLPUBFUN int XMLCALL xmlTextWriterWriteNode(xmlTextWriterPtr writer, xmlNodePtr node);
XMLPUBFUN int XMLCALL xmlTextWriterWriteElementNode(xmlTextWriterPtr writer, xmlNodePtr node);
XMLPUBFUN int XMLCALL xmlTextWriterWriteTextNode(xmlTextWriterPtr writer, xmlNodePtr node);

int XSOutputStream_xmlOutputWriteCallback(void *context, const char *buffer, int len);
int XSOutputStream_xmlOutputCloseCallback(void *context);

@interface PXOutputStream () {
    xmlOutputBufferPtr _out;
    xmlTextWriterPtr _writer;
}

@end

@implementation PXOutputStream

#pragma mark Life-cycle

- (id)init
{
    self = [super init];
    if (self) {
        _out = xmlOutputBufferCreateIO(XSOutputStream_xmlOutputWriteCallback,
                                       XSOutputStream_xmlOutputCloseCallback,
                                       (__bridge void *)(self),
                                       NULL);
        _writer = xmlNewTextWriter(_out);
    }
    return self;
}

- (void)dealloc
{
    if (_writer) {
        xmlFreeTextWriter(_writer);
    }
}

#pragma mark Send

- (void)openWithHeader:(PXElement *)element
{
    xmlDocPtr doc = element.document.xmlDoc;
    xmlNodePtr node = element.xmlNode;
    
    xmlTextWriterStartDocument(_writer, (const char *)doc->version, (const char *)doc->encoding, NULL);
    
    if (node->ns) {
        xmlTextWriterStartElementNS(_writer, node->ns->prefix, node->name, node->ns->href);
    } else {
        xmlTextWriterStartElement(_writer, node->name);
    }
    
    for(xmlAttrPtr attr = element.xmlNode->properties; attr != nil; attr = attr->next) {
        if (attr->ns) {
            xmlTextWriterWriteAttributeNS(_writer, attr->ns->prefix, attr->name, attr->ns->href, xmlNodeGetContent(attr->children));
        } else {
            xmlTextWriterWriteAttribute(_writer, attr->name, xmlNodeGetContent(attr->children));
        }
    }
    
    xmlTextWriterWriteRaw(_writer, BAD_CAST "\n");
    xmlTextWriterFlush(_writer);
}

- (void)sendElement:(PXElement *)element
{
    xmlNodePtr node = element.xmlNode;
    
    xmlTextWriterWriteNode(_writer, node);
    
    xmlTextWriterWriteRaw(_writer, BAD_CAST "\n");
    xmlTextWriterFlush(_writer);
}

- (void)close
{
    xmlTextWriterEndDocument(_writer);
    xmlTextWriterFlush(_writer);
    xmlFreeTextWriter(_writer);
    _writer = NULL;
    _out = NULL;
}

@end

int XSOutputStream_xmlOutputWriteCallback(void *context, const char *buffer, int len)
{
    PXOutputStream *stream = (__bridge PXOutputStream *)context;
    NSData *data = [NSData dataWithBytes:(void *)buffer length:len];
    if ([stream.delegate respondsToSelector:@selector(outputStream:processData:terminate:)]) {
        [stream.delegate outputStream:stream processData:data terminate:NO];
    }
    return len;
}

int XSOutputStream_xmlOutputCloseCallback(void *context)
{
    PXOutputStream *stream = (__bridge PXOutputStream *)context;
    if ([stream.delegate respondsToSelector:@selector(outputStream:processData:terminate:)]) {
        [stream.delegate outputStream:stream processData:nil terminate:YES];
    }
    return 0;
}

XMLPUBFUN int XMLCALL xmlTextWriterWriteNode(xmlTextWriterPtr writer, xmlNodePtr node)
{
    switch (node->type) {
        case XML_ELEMENT_NODE:
            return xmlTextWriterWriteElementNode(writer, node);
            
        case XML_TEXT_NODE:
            return xmlTextWriterWriteTextNode(writer, node);
            
        default:
            break;
    }
    
    return 0;
}

XMLPUBFUN int XMLCALL xmlTextWriterWriteElementNode(xmlTextWriterPtr writer, xmlNodePtr node)
{
    assert(node->type == XML_ELEMENT_NODE);
    
    int sum = 0;
    
    // Start Element
    
    int namespaceDeclaredInNode = 0;
    if (node->ns) {
        for (xmlNsPtr ns = node->nsDef; ns != NULL; ns = ns->next) {
            if (node->ns == ns) {
                namespaceDeclaredInNode = 1;
                break;
            }
        }
    }
    
    if (namespaceDeclaredInNode) {
        sum += xmlTextWriterStartElementNS(writer, node->ns->prefix, node->name, node->ns->href);
    } else {
        sum += xmlTextWriterStartElement(writer, node->name);
    }
    
    // Attributes
    
    for(xmlAttrPtr attr = node->properties; attr != NULL; attr = attr->next) {
        if (attr->ns) {
            xmlTextWriterWriteAttributeNS(writer, attr->ns->prefix, attr->name, attr->ns->href, xmlNodeGetContent(attr->children));
        } else {
            xmlTextWriterWriteAttribute(writer, attr->name, xmlNodeGetContent(attr->children));
        }
    }
    
    // Children
    
    for (xmlNodePtr child = node->children; child != NULL; child = child->next) {
        xmlTextWriterWriteNode(writer, child);
    }
    
    // End Element
    sum += xmlTextWriterEndElement(writer);
    
    return sum;
}

XMLPUBFUN int XMLCALL xmlTextWriterWriteTextNode(xmlTextWriterPtr writer, xmlNodePtr node)
{
    assert(node->type == XML_TEXT_NODE);
    return xmlTextWriterWriteRaw(writer, xmlNodeGetContent(node));
}

