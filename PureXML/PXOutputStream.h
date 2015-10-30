//
//  PXOutputStream.h
//  PureXML
//
//  Created by Tobias Kräntzer on 30.10.15.
//  Copyright © 2015 Tobias Kräntzer. All rights reserved.
//

@import Foundation;

@class PXElement;
@class PXOutputStream;

@protocol PXOutputStreamDataDelegate <NSObject>
- (void)outputStream:(PXOutputStream *)stream processData:(NSData *)data terminate:(BOOL)terminate;
@end

@interface PXOutputStream : NSObject

#pragma mark Delegate
@property (nonatomic, weak) id<PXOutputStreamDataDelegate> delegate;

#pragma mark Feed Stream
- (void)openWithHeader:(PXElement *)element;
- (void)sendElement:(PXElement *)element;
- (void)close;

@end
