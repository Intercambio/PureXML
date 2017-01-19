//
//  PXTextTests.m
//  PureXML
//
//  Created by Tobias Kraentzer on 18.01.15.
//  Copyright (c) 2015 Tobias Kräntzer. All rights reserved.
//

#import <PureXML/PureXML.h>
#import <XCTest/XCTest.h>

@interface PXTextTests : XCTestCase

@end

@implementation PXTextTests

- (void)testSetContent
{
    PXDocument *document = [[PXDocument alloc] initWithElementName:@"foo"
                                                         namespace:@"http://example.com/ns"
                                                            prefix:@"bar"];

    PXElement *element = [document.root addElementWithName:@"el" namespace:@"http://example.com/ns" content:@"Foo"];

    XCTAssertEqual([element numberOfChildren], 1);

    PXText *text = (PXText *)[element childAtIndex:0];
    XCTAssertEqualObjects([text stringValue], @"Foo");

    text.stringValue = @"Bar";
    XCTAssertEqualObjects([text stringValue], @"Bar");
}

@end
