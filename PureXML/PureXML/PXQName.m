//
//  PXQName.m
//  PureXML
//
//  Created by Tobias Kräntzer on 07.01.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import "PXElement.h"
#import "PXQName.h"

@implementation PXQName

#pragma mark Life-cycle

- (instancetype)initWithName:(NSString *)name namespace:(NSString *) namespace
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _namespace = [namespace copy];
    }
    return self;
}

#pragma mark NSObject

- (NSUInteger)hash
{
    return [self.name hash] * [self.namespace hash];
}

- (BOOL)isEqual:(PXQName *)object
{
    if ([object isKindOfClass:[PXElement class]]) {
        return [self isEqual:[(PXElement *)object qualifiedName]];
    } else {
        if (![self.name isEqualToString:object.name]) {
            return NO;
        }
        
        if (![self.namespace isEqualToString:object.namespace]) {
            return NO;
        }
        
        return YES;
    }
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
