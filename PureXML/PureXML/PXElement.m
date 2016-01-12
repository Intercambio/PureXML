//
//  PXElement.m
//  PureXML
//
//  Created by Tobias Kräntzer on 04.05.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <libxml/tree.h>

#import "PXDocument.h"
#import "PXDocument+Private.h"
#import "PXNode+Private.h"
#import "PXElement.h"

@implementation PXElement

@dynamic stringValue;

#pragma mark Properties

- (NSString *)name
{
    return self.xmlNode->name ? [NSString stringWithUTF8String:(const char *)self.xmlNode->name] : nil;
}

- (NSString *) namespace
{
    return self.xmlNode->ns->href ? [NSString stringWithUTF8String:(const char *)self.xmlNode->ns->href] : nil;
}

- (NSString *)prefix
{
    return self.xmlNode->ns->prefix ? [NSString stringWithUTF8String:(const char *)self.xmlNode->ns->prefix] : nil;
}

- (PXQName *)qualifiedName
{
    NSString *name = self.name;
    NSString *namespace = self.namespace;
    if (name && namespace) {
        return [[PXQName alloc] initWithName:self.name namespace:self.namespace];
    } else {
        return nil;
    }
}

#pragma mark Content

- (void)setStringValue:(NSString *)stringValue
{
    [self enumerateChildrenUsingBlock:^(PXNode *child, BOOL *stop) {
        [child removeFromParent];
    }];

    xmlNodePtr textNode = xmlNewText(BAD_CAST[stringValue UTF8String]);
    xmlAddChild(self.xmlNode, textNode);
}

#pragma mark Attributes

- (NSString *)valueForAttribute:(NSString *)name
{
    return [self valueForAttribute:name inNamespace:nil];
}

- (NSString *)valueForAttribute:(NSString *)name inNamespace:(NSString *) namespace
{
    xmlAttrPtr attr;

    if ([namespace isEqualToString:self.namespace]) {
        namespace = nil;
    }

    if (namespace) {
        attr = xmlHasNsProp(self.xmlNode, BAD_CAST[name UTF8String], BAD_CAST[namespace UTF8String]);
    } else {
        attr = xmlHasProp(self.xmlNode, BAD_CAST[name UTF8String]);
    }

    BOOL hasAttrNamespace = attr && attr->ns && attr->ns->href;

    if (attr && xmlNodeGetContent(attr->children)) {
        if (namespace != nil == hasAttrNamespace) {
            return [NSString stringWithUTF8String:(const char *)xmlNodeGetContent(attr->children)];
        }
    }
    return nil;
}

- (void)enumerateAttributesUsingBlock:(void (^)(NSString *name, id value, NSString *namespace, BOOL *stop))block
{
    if (block == nil)
        return;

    BOOL stop = NO;
    xmlAttrPtr attr = self.xmlNode->properties;
    while (attr && stop == NO) {

        NSString *name = [NSString stringWithUTF8String:(const char *)attr->name];
        NSString *namespace = attr->ns ? [NSString stringWithUTF8String:(const char *)attr->ns->href] : nil;
        NSString *value = [NSString stringWithUTF8String:(const char *)xmlNodeGetContent(attr->children)];

        block(name, value, namespace, &stop);

        attr = attr->next;
    }
}

- (void)setValue:(id)value forAttribute:(NSString *)name
{
    [self setValue:value forAttribute:name inNamespace:nil];
}

- (void)setValue:(id)value forAttribute:(NSString *)name inNamespace:(NSString *) namespace
{
    NSParameterAssert([value isKindOfClass:[NSString class]]);

    xmlNsPtr ns = NULL;
    if (namespace && ![namespace isEqualToString:self.namespace]) {
        ns = xmlSearchNsByHref(self.document.xmlDoc, self.xmlNode, BAD_CAST[namespace UTF8String]);
        if (ns == NULL) {
            NSString *prefix = nil;
            NSUInteger i = 1;
            xmlNsPtr freeNS = NULL;
            do {
                prefix = [NSString stringWithFormat:@"x%lu", (unsigned long)i++];
                freeNS = xmlSearchNs(self.document.xmlDoc, self.xmlNode, BAD_CAST[prefix UTF8String]);
            } while (freeNS);
            ns = xmlNewNs(self.xmlNode, BAD_CAST[namespace UTF8String], BAD_CAST[prefix UTF8String]);
        }
    }

    if (ns) {
        xmlSetNsProp(self.xmlNode, ns, BAD_CAST[name UTF8String], BAD_CAST[value UTF8String]);
    } else {
        xmlSetProp(self.xmlNode, BAD_CAST[name UTF8String], BAD_CAST[value UTF8String]);
    }
}

#pragma mark Children

- (NSUInteger)numberOfChildren
{
    NSUInteger idx = 0;

    xmlNodePtr child = self.xmlNode->children;
    while (child) {
        child = child->next;
        idx++;
    }

    return idx;
}

- (PXNode *)childAtIndex:(NSUInteger)index
{
    NSUInteger idx = 0;
    xmlNodePtr child = self.xmlNode->children;
    while (child && idx != index) {
        child = child->next;
        idx++;
    }

    if (child) {
        return [self.document nodeWithXmlNode:child];
    } else {
        return nil;
    }
}

- (void)enumerateChildrenUsingBlock:(void (^)(PXNode *child, BOOL *stop))block
{
    if (block == nil)
        return;

    BOOL stop = NO;
    xmlNodePtr child = self.xmlNode->children;
    while (child && stop == NO) {
        PXNode *node = [self.document nodeWithXmlNode:child];
        block(node, &stop);
        child = child->next;
    }
}

#pragma mark Elements

- (NSUInteger)numberOfElements
{
    NSUInteger idx = 0;

    xmlNodePtr child = self.xmlNode->children;
    while (child) {
        if (child && child->type == XML_ELEMENT_NODE) {
            idx++;
        }
        child = child->next;
    }

    return idx;
}

- (PXElement *)elementAtIndex:(NSUInteger)index
{
    NSUInteger idx = 0;
    xmlNodePtr child = self.xmlNode->children;
    xmlNodePtr element = NULL;
    while (child) {
        if (child && child->type == XML_ELEMENT_NODE) {
            element = child;
            if (idx == index)
                break;
            idx++;
        } else {
            element = NULL;
        }
        child = child->next;
    }

    if (element && element->type == XML_ELEMENT_NODE) {
        return (PXElement *)[self.document nodeWithXmlNode:child];
    } else {
        return nil;
    }
}

- (void)enumerateElementsUsingBlock:(void (^)(PXElement *element, BOOL *stop))block
{
    if (block == nil)
        return;

    BOOL stop = NO;
    xmlNodePtr child = self.xmlNode->children;
    while (child && stop == NO) {
        if (child && child->type == XML_ELEMENT_NODE) {
            PXElement *node = (PXElement *)[self.document nodeWithXmlNode:child];
            block(node, &stop);
        }
        child = child->next;
    }
}

- (PXElement *)addElementWithName:(NSString *)name namespace:(NSString *)namespace content:(NSString *)content
{
    xmlNodePtr element = xmlNewChild(self.xmlNode, NULL, BAD_CAST[name UTF8String], BAD_CAST[content UTF8String]);
    
    if (namespace && ![namespace isEqualToString:self.namespace]) {
        xmlNsPtr ns = xmlSearchNsByHref(self.document.xmlDoc, element, BAD_CAST[namespace UTF8String]);
        if (ns == NULL) {
            ns = xmlNewNs(element, BAD_CAST[namespace UTF8String], NULL);
        }
        xmlSetNs(element, ns);
    }
    
    return (PXElement *)[self.document nodeWithXmlNode:element];
}

- (PXElement *)addElement:(PXElement *)element
{
    xmlNodePtr node = xmlCopyNode(element.xmlNode, 1);
    xmlAddChild(self.xmlNode, node);
    px_xmlReconciliateNs(self.document.xmlDoc, node);
    return (PXElement *)[self.document nodeWithXmlNode:node];
}

#pragma mark KVC

- (id)valueForUndefinedKey:(NSString *)key
{
    return [self valueForAttribute:key];
}

#pragma mark NSObject

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[PXQName class]]) {
        return [self.qualifiedName isEqual:object];
    } else {
        return [super isEqual:object];
    }
}

@end
