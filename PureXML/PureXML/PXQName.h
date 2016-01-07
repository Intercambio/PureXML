//
//  PXQName.h
//  PureXML
//
//  Created by Tobias Kräntzer on 07.01.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PXQName : NSObject <NSCopying>

#pragma mark Life-cycle
- (instancetype)initWithName:(NSString *)name namespace:(NSString *)namespace;

#pragma mark Name & Namespace
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *namespace;

@end
