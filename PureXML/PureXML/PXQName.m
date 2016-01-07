//
//  PXQName.m
//  PureXML
//
//  Created by Tobias Kräntzer on 07.01.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

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

- (BOOL)isEqual:(PXQName *)object
{
    if (![self.name isEqualToString:object.name]) {
        return NO;
    }

    if (![self.namespace isEqualToString:object.namespace]) {
        return NO;
    }

    return YES;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[PXQName alloc] initWithName:self.name namespace:self.namespace];
}

@end
