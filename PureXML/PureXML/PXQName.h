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
- (nonnull instancetype)initWithName:(nonnull NSString *)name namespace:(nonnull NSString *)namespace;

#pragma mark Name & Namespace
@property (nonatomic, readonly, nonnull) NSString *name;
@property (nonatomic, readonly, nonnull) NSString *namespace;

@end

PXQName *_Nonnull PXQN(NSString *_Nonnull namespace, NSString *_Nonnull name);
