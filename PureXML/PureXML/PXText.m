//
//  PXText.m
//  PureXML
//
//  Created by Tobias Kräntzer on 14.09.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <libxml/tree.h>

#import "PXText.h"

@implementation PXText

@dynamic stringValue;

- (void)setStringValue:(NSString *)stringValue
{
    xmlNodeSetContent(self.xmlNode, BAD_CAST [stringValue UTF8String]);
}

@end
