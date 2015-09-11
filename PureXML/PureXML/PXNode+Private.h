//
//  PXNode+Private.h
//  PureXML
//
//  Created by Tobias Kräntzer on 09.12.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import "PXNode.h"

@interface PXNode (Private)
- (instancetype)initWithDocument:(PXDocument *)document xmlNode:(xmlNodePtr)xmlNode;
@end
