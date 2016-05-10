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

@interface PXDocument : NSObject

+ (instancetype)documentNamed:(NSString *)name;
+ (instancetype)documentNamed:(NSString *)name inBundle:(NSBundle *)bundle;
+ (instancetype)documentWithData:(NSData *)data;

#pragma mark Life-cycle
- (instancetype)init;
- (instancetype)initWithElementName:(NSString *)name namespace:(NSString *)ns prefix:(NSString *)prefix;
- (instancetype)initWithElement:(PXElement *)element;
- (instancetype)initWithXMLDoc:(xmlDocPtr)xmlDoc NS_DESIGNATED_INITIALIZER;

#pragma mark Document Data
- (NSData *)data;

#pragma mark Root Element
@property (nonatomic, readonly) PXElement *root;

#pragma mark libxml Property
@property (nonatomic, readonly) xmlDocPtr xmlDoc;

@end
