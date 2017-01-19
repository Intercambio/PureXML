//
//  PXDocument.h
//  PureXML
//
//  Created by Tobias Kräntzer on 04.05.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

@import Foundation;

typedef struct _xmlDoc xmlDoc;
typedef xmlDoc *xmlDocPtr;

@class PXElement;
@class PXQName;

@interface PXDocument : NSObject

#pragma mark Element Class Registration
+ (void)registerElementClass:(nonnull Class)elementClass forQualifiedName:(nonnull PXQName *)qualifiedName;
+ (nonnull NSDictionary *)registeredClassesByQualifiedName;

#pragma mark Document Creation
+ (nullable instancetype)documentNamed:(nonnull NSString *)name;
+ (nullable instancetype)documentNamed:(nonnull NSString *)name inBundle:(nullable NSBundle *)bundle;
+ (nullable instancetype)documentNamed:(nonnull NSString *)name inBundle:(nullable NSBundle *)bundle usingElementClasses:(nullable NSDictionary *)elementClasses;
+ (nullable instancetype)documentWithData:(nonnull NSData *)data;
+ (nullable instancetype)documentWithData:(nonnull NSData *)data usingElementClasses:(nullable NSDictionary *)elementClasses;

#pragma mark Life-cycle
- (nonnull instancetype)init;
- (nonnull instancetype)initWithElementName:(nonnull NSString *)name namespace:(nonnull NSString *)ns prefix:(nullable NSString *)prefix;
- (nonnull instancetype)initWithElementName:(nonnull NSString *)name namespace:(nonnull NSString *)ns prefix:(nullable NSString *)prefix elementClasses:(nullable NSDictionary *)elementClasses;
- (nonnull instancetype)initWithElement:(nonnull PXElement *)element;
- (nonnull instancetype)initWithXMLDoc:(nonnull xmlDocPtr)xmlDoc;
- (nonnull instancetype)initWithXMLDoc:(nonnull xmlDocPtr)xmlDoc elementClasses:(nullable NSDictionary *)elementClasses NS_DESIGNATED_INITIALIZER;

#pragma mark Element Classes
@property (nonatomic, readonly, nullable) NSDictionary *elementClasses;

#pragma mark Document Data
- (nonnull NSData *)data;

#pragma mark Root Element
@property (nonatomic, readonly, nonnull) PXElement *root;

#pragma mark libxml Property
@property (nonatomic, readonly, nonnull) xmlDocPtr xmlDoc;

@end
