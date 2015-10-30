//
//  PXInputStream.h
//  PureXML
//
//  Created by Tobias Kräntzer on 30.10.15.
//  Copyright © 2015 Tobias Kräntzer. All rights reserved.
//

@import Foundation;

@class PXElement;
@class PXInputStream;

@protocol PXInputStreamDelegate <NSObject>
- (void)inputStream:(PXInputStream *)inputStream didOpenWithHeader:(PXElement *)element;
- (void)inputStream:(PXInputStream *)inputStream didReceiveElement:(PXElement *)element;
- (void)inputStream:(PXInputStream *)inputStream didCloseWithError:(NSError *)error;
@end

@interface PXInputStream : NSObject

#pragma mark Delegate
@property (nonatomic, weak) id<PXInputStreamDelegate> delegate;

#pragma mark Feed Stream
- (void)processData:(NSData *)chunk terminate:(BOOL)terminate;

@end
