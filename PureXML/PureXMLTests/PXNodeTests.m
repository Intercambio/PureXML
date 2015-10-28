//
//  PXNodeTests.m
//  PureXML
//
//  Created by Tobias Kräntzer on 09.12.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PureXML.h"

@interface PXNodeTests : XCTestCase

@end

@implementation PXNodeTests

- (void)testTextNode
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    PXDocument *document = [PXDocument documentNamed:@"text.xml" inBundle:bundle];
    PXElement *rootElement = document.root;

    XCTAssertEqual([rootElement numberOfChildren], 1);
    if ([rootElement numberOfChildren] == 1) {
        PXNode *node = [rootElement childAtIndex:0];
        XCTAssertTrue([node isKindOfClass:[PXText class]]);
        XCTAssertEqualObjects([node stringValue], @"foo");
    }
}

- (void)testEquality
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    PXDocument *document = [PXDocument documentNamed:@"text.xml" inBundle:bundle];
    PXElement *rootElement = document.root;
    XCTAssertEqualObjects(rootElement, rootElement.document.root);
}

@end
