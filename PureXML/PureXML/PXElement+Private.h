//
//  PXElement+Private.h
//  PureXML
//
//  Created by Tobias Kraentzer on 22.05.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <PureXML/PureXML.h>

@interface PXElement (Private)

+ (NSString *)nameOfXmlElementNode:(xmlNodePtr)elementNode;
+ (NSString *)namespaceOfXmlElementNode:(xmlNodePtr)elementNode;
+ (PXQName *)qualifiedNameOfXmlElementNode:(xmlNodePtr)elementNode;

@end
