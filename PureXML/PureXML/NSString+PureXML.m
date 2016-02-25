//
//  NSString+PureXML.m
//  PureXML
//
//  Created by Tobias Kräntzer on 25.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "NSString+PureXML.h"

@implementation NSString (PureXML)

+ (instancetype)px_stringWithContentOfXMLNode:(const xmlNode *)node
{
    NSString *result = nil;
    xmlChar *content = xmlNodeGetContent(node);
    if (content) {
        result = [NSString stringWithUTF8String:(const char *)content];
        xmlFree(content);
    }
    return result;
}

@end
