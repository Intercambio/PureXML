//
//  PXElement.h
//  PureXML
//
//  Created by Tobias Kräntzer on 04.05.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import "PXNode.h"
#import "PXQName.h"

@class PXDocument;

@interface PXElement : PXNode

#pragma mark Properties
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *namespace;
@property (nonatomic, readonly) NSString *prefix;

@property (nonatomic, readonly) PXQName *qualifiedName;

#pragma mark Content
@property (nonatomic, readwrite, copy) NSString *stringValue;

#pragma mark Attributes
- (id)valueForAttribute:(NSString *)name;
- (id)valueForAttribute:(NSString *)name inNamespace:(NSString *)namespace;
- (void)enumerateAttributesUsingBlock:(void (^)(NSString *name, id value, NSString *namespace, BOOL *stop))block;

- (void)setValue:(NSString *)value forAttribute:(NSString *)name;
- (void)setValue:(NSString *)value forAttribute:(NSString *)name inNamespace:(NSString *)namespace;

- (void)removeForAttribute:(NSString *)name;
- (void)removeForAttribute:(NSString *)name inNamespace:(NSString *)namespace;

#pragma mark Children
- (NSUInteger)numberOfChildren;
- (PXNode *)childAtIndex:(NSUInteger)index;
- (void)enumerateChildrenUsingBlock:(void (^)(PXNode *child, BOOL *stop))block;

#pragma mark Elements
- (NSUInteger)numberOfElements;
- (PXElement *)elementAtIndex:(NSUInteger)index;
- (void)enumerateElementsUsingBlock:(void (^)(PXElement *element, BOOL *stop))block;

- (PXElement *)addElementWithName:(NSString *)name namespace:(NSString *)namespace content:(NSString *)content;
- (PXElement *)addElement:(PXElement *)element;

@end
