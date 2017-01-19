//
//  PXText.h
//  PureXML
//
//  Created by Tobias Kräntzer on 14.09.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import "PXNode.h"

@interface PXText : PXNode

#pragma mark Content
@property (nonatomic, readwrite, copy, nullable) NSString *stringValue;

@end
