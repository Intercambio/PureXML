//
//  PXDocument.m
//  PureXML
//
//  Created by Tobias Kräntzer on 04.05.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <libxml/tree.h>

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
        xmlReconciliateNs(_xmlDoc, node);
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
    return [[NSString alloc] initWithData:[self data] encoding:NSUTF8StringEncoding];
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
