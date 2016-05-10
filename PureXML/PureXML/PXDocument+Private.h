//
//  PXDocument+Private.h
//  PureXML
//
//  Created by Tobias Kraentzer on 18.01.15.
//  Copyright (c) 2015 Tobias Kräntzer. All rights reserved.
//

#import "PXDocument.h"
#import "PXNode.h"

@interface PXDocument (Private)
- (PXNode *)nodeWithXmlNode:(xmlNodePtr)xmlNode;
@end

int px_xmlReconciliateNs(xmlDocPtr doc, xmlNodePtr tree);
