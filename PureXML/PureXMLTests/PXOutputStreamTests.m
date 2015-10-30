//
//  PXOutputStreamTests.m
//  PureXML
//
//  Created by Tobias Kräntzer on 04.05.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <PureXML/PureXML.h>

@interface PXOutputStreamTests : XCTestCase

@end

@implementation PXOutputStreamTests

- (void)testStream
{
    // Prepare delegate mock and captor for the header
    id<PXOutputStreamDataDelegate> delegate = mockProtocol(@protocol(PXOutputStreamDataDelegate));

    // Setup stream
    PXOutputStream *stream = [[PXOutputStream alloc] init];
    stream.delegate = delegate;

    // Open, send element and close
    PXDocument *headerDocument = [PXDocument documentNamed:@"streamHeader.xml"
                                                  inBundle:[NSBundle bundleForClass:[self class]]];
    PXDocument *elementDocument = [PXDocument documentNamed:@"element.xml"
                                                   inBundle:[NSBundle bundleForClass:[self class]]];

    [stream openWithHeader:headerDocument.root];
    [stream sendElement:elementDocument.root];
    [stream close];

    // Verify delegate calls
    HCArgumentCaptor *dataCaptor = [[HCArgumentCaptor alloc] init];
    [verifyCount(delegate, atLeastOnce()) outputStream:stream processData:(id)dataCaptor terminate:NO];

    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSData *data in [dataCaptor allValues]) {
        if ([data isKindOfClass:[NSData class]]) {
            [result appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        }
    }
    NSLog(@"\n %@", result);
    assertThat(result, startsWith(@"<?xml version=\"1.0\"?>"));
}

@end
