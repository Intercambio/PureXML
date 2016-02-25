//
//  NSString+PureXML.h
//  PureXML
//
//  Created by Tobias Kräntzer on 25.02.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>

@interface NSString (PureXML)

+ (instancetype)px_stringWithContentOfXMLNode:(const xmlNode *)node;

@end
