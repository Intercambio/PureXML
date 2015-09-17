//
//  PXNode.h
//  PureXML
//
//  Created by Tobias Kräntzer on 14.09.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _xmlNode xmlNode;
typedef xmlNode *xmlNodePtr;

@class PXDocument;

@interface PXNode : NSObject

#pragma mark Document
@property (nonatomic, readonly) PXDocument *document;

#pragma mark Node Structure
@property (nonatomic, readonly) PXNode *parent;
- (void)removeFromParent;

#pragma mark Content
@property (nonatomic, readonly, copy) NSString *stringValue;

#pragma mark XPath
- (NSArray *)nodesForXPath:(NSString *)xpath usingNamespaces:(NSDictionary *)namespaces;
- (void)enumerateNodesForXPath:(NSString *)xpath
               usingNamespaces:(NSDictionary *)namespaces
                         block:(void(^)(PXNode *element, BOOL *stop))block;

#pragma mark libxml Property
@property (nonatomic, readonly) xmlNodePtr xmlNode;

@end
