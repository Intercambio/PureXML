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
+ (void)registerElementClass:(Class)elementClass forQualifiedName:(PXQName *)qualifiedName;
+ (NSDictionary *)registeredClassesByQualifiedName;

#pragma mark Document Creation
+ (instancetype)documentNamed:(NSString *)name;
+ (instancetype)documentNamed:(NSString *)name inBundle:(NSBundle *)bundle;
+ (instancetype)documentNamed:(NSString *)name inBundle:(NSBundle *)bundle usingElementClasses:(NSDictionary *)elementClasses;
+ (instancetype)documentWithData:(NSData *)data;
+ (instancetype)documentWithData:(NSData *)data usingElementClasses:(NSDictionary *)elementClasses;

#pragma mark Life-cycle
- (instancetype)init;
- (instancetype)initWithElementName:(NSString *)name namespace:(NSString *)ns prefix:(NSString *)prefix;
- (instancetype)initWithElementName:(NSString *)name namespace:(NSString *)ns prefix:(NSString *)prefix elementClasses:(NSDictionary *)elementClasses;
- (instancetype)initWithElement:(PXElement *)element;
- (instancetype)initWithXMLDoc:(xmlDocPtr)xmlDoc;
- (instancetype)initWithXMLDoc:(xmlDocPtr)xmlDoc elementClasses:(NSDictionary *)elementClasses NS_DESIGNATED_INITIALIZER;

#pragma mark Element Classes
@property (nonatomic, readonly) NSDictionary *elementClasses;

#pragma mark Document Data
- (NSData *)data;

#pragma mark Root Element
@property (nonatomic, readonly) PXElement *root;

#pragma mark libxml Property
@property (nonatomic, readonly) xmlDocPtr xmlDoc;

@end
