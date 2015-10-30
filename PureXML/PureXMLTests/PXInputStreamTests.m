//
//  PXInputStreamTests.m
//  PureXML
//
//  Created by Tobias Kräntzer on 15.09.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import <PureXML/PureXML.h>

@interface PXInputStreamTests : XCTestCase

@end

@implementation PXInputStreamTests

- (void)testStream
{
    // Prepare Delegate mock and captor for the header
    id<PXInputStreamDelegate> delegate = mockProtocol(@protocol(PXInputStreamDelegate));

    // Setup stream
    PXInputStream *stream = [[PXInputStream alloc] init];
    stream.delegate = delegate;

    // Feed file chunks into the stream
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"simpleStream" ofType:@"xml"];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];

    NSData *data = nil;
    do {
        data = [fileHandle readDataOfLength:4];
        [stream processData:data terminate:NO];
    } while ([data length] > 0);
    [stream processData:nil terminate:YES];

    // Verify delegate calls
    HCArgumentCaptor *headerCaptor = [[HCArgumentCaptor alloc] init];
    HCArgumentCaptor *elementCaptor = [[HCArgumentCaptor alloc] init];

    [verifyCount(delegate, times(1)) inputStream:stream didOpenWithHeader:(id)headerCaptor];
    [verifyCount(delegate, times(2)) inputStream:stream didReceiveElement:(id)elementCaptor];
    [verifyCount(delegate, times(1)) inputStream:stream didCloseWithError:nilValue()];

    PXElement *header = [headerCaptor value];
    assertThat(header, isA([PXElement class]));
    assertThat(header.name, equalTo(@"stream"));
    assertThat(header.namespace, equalTo(@"http://etherx.jabber.org/streams"));

    NSArray *elements = [elementCaptor allValues];
    assertThat(elements, hasCountOf(2));

    PXElement *element1 = [elements objectAtIndex:0];
    assertThat(element1, isA([PXElement class]));
    assertThat(element1.name, equalTo(@"foo"));
    assertThat(element1.namespace, equalTo(@"jabber:client"));

    PXElement *element2 = [elements objectAtIndex:1];
    assertThat(element2, isA([PXElement class]));
    assertThat(element2.name, equalTo(@"bar"));
    assertThat(element2.namespace, equalTo(@"jabber:client"));
}

@end
