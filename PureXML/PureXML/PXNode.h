//
//  PXNode.h
//  PureXML
//
//  Created by Tobias Kräntzer on 14.09.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

@import Foundation;

typedef struct _xmlNode xmlNode;
typedef xmlNode *xmlNodePtr;

@class PXDocument;

@interface PXNode : NSObject

#pragma mark Document
@property (nonatomic, readonly, nonnull) PXDocument *document;

#pragma mark Node Structure
@property (nonatomic, readonly, nullable) PXNode *parent;
- (void)removeFromParent;

#pragma mark Content
@property (nonatomic, readonly, copy, nullable) NSString *stringValue;

#pragma mark XPath
- (nonnull NSArray *)nodesForXPath:(nonnull NSString *)xpath usingNamespaces:(nonnull NSDictionary *)namespaces;
- (void)enumerateNodesForXPath:(nonnull NSString *)xpath
               usingNamespaces:(nonnull NSDictionary *)namespaces
                         block:(nullable void (^)(PXNode *_Nonnull element, BOOL *_Nonnull stop))block;

#pragma mark libxml Property
@property (nonatomic, readonly, nonnull) xmlNodePtr xmlNode;

@end
