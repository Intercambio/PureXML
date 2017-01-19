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
@property (nonatomic, readonly, nonnull) NSString *name;
@property (nonatomic, readonly, nonnull) NSString *namespace;
@property (nonatomic, readonly, nullable) NSString *prefix;

@property (nonatomic, readonly, nonnull) PXQName *qualifiedName;

#pragma mark Content
@property (nonatomic, readwrite, copy, nullable) NSString *stringValue;

#pragma mark Attributes
- (nullable id)valueForAttribute:(nonnull NSString *)name;
- (nullable id)valueForAttribute:(nonnull NSString *)name inNamespace:(nullable NSString *)namespace;
- (void)enumerateAttributesUsingBlock:(nullable void (^)(NSString *_Nonnull name, id _Nonnull value, NSString *_Nullable namespace, BOOL *_Nonnull stop))block;

- (void)setValue:(nullable NSString *)value forAttribute:(nonnull NSString *)name;
- (void)setValue:(nullable NSString *)value forAttribute:(nonnull NSString *)name inNamespace:(nullable NSString *)namespace;

- (void)removeForAttribute:(nonnull NSString *)name;
- (void)removeForAttribute:(nonnull NSString *)name inNamespace:(nullable NSString *)namespace;

#pragma mark Children
- (NSUInteger)numberOfChildren;
- (nullable PXNode *)childAtIndex:(NSUInteger)index;
- (void)enumerateChildrenUsingBlock:(nullable void (^)(PXNode *_Nonnull child, BOOL *_Nonnull stop))block;

#pragma mark Elements
- (NSUInteger)numberOfElements;
- (nullable PXElement *)elementAtIndex:(NSUInteger)index;
- (void)enumerateElementsUsingBlock:(nullable void (^)(PXElement *_Nonnull element, BOOL *_Nonnull stop))block;

- (nonnull PXElement *)addElementWithName:(nonnull NSString *)name namespace:(nonnull NSString *)namespace content:(nullable NSString *)content;
- (nonnull PXElement *)addElement:(nonnull PXElement *)element;

@end
