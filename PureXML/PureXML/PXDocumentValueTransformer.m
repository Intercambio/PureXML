//
//  PXDocumentValueTransformer.m
//  PureXML
//
//  Created by Tobias Kräntzer on 07.12.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import "PXDocument.h"

#import "PXDocumentValueTransformer.h"

@implementation PXDocumentValueTransformer

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(PXDocument *)value
{
    NSParameterAssert([value isKindOfClass:[PXDocument class]]);
    return [value data];
}

- (id)reverseTransformedValue:(NSData *)value
{
    NSParameterAssert([value isKindOfClass:[NSData class]]);
    return [PXDocument documentWithData:value];
}

@end
