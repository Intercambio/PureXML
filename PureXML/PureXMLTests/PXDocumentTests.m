//
//  PXDocumentTests.m
//  PureXML
//
//  Created by Tobias Kräntzer on 15.09.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <PureXML/PureXML.h>

@interface PXDocumentTests : XCTestCase

@end

@implementation PXDocumentTests

- (void)testNewDocument
{
    PXDocument *document = [[PXDocument alloc] init];
    XCTAssertNotNil(document);
    XCTAssertNil(document.root);
}

- (void)testNewDocumentWithElementNamed
{
    PXDocument *document = [[PXDocument alloc] initWithElementName:@"foo"
                                                         namespace:@"http://example.com/ns"
                                                            prefix:@"bar"];
    PXElement *rootElement = document.root;

    XCTAssert(rootElement.name, @"foo");
    XCTAssert(rootElement.namespace, @"http://example.com/ns");
}

- (void)testDocumentWithExsitingElement
{
    PXDocument *documentA = [[PXDocument alloc] initWithElementName:@"foo"
                                                          namespace:@"http://example.com/ns"
                                                             prefix:@"bar"];

    [documentA.root addElementWithName:@"a" namespace:nil content:nil];
    [documentA.root addElementWithName:@"b" namespace:nil content:nil];
    [documentA.root addElementWithName:@"c" namespace:nil content:nil];

    PXElement *element = [documentA.root elementAtIndex:1];
    PXDocument *documentB = [[PXDocument alloc] initWithElement:element];

    [element addElementWithName:@"1" namespace:nil content:nil];

    XCTAssertEqual([element numberOfElements], 1);
    XCTAssertEqual([documentB.root numberOfChildren], 0);
}

- (void)testDocumentNamedInBundle
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    PXDocument *document = [PXDocument documentNamed:@"simpleDocument.xml" inBundle:bundle];
    PXElement *rootElement = document.root;

    XCTAssert(rootElement.name, @"stream");
    XCTAssert(rootElement.namespace, @"http://etherx.jabber.org/streams");
}

- (void)testNamespaceHandlingOfCopiedElements
{
    PXDocument *document = [[PXDocument alloc] initWithElementName:@"foo" namespace:@"ns1" prefix:nil];
    PXElement *barElement = [document.root addElementWithName:@"bar" namespace:@"ns2" content:nil];
    PXElement *bazElement = [barElement addElementWithName:@"baz" namespace:@"ns2" content:@"123"];
    [bazElement addElementWithName:@"foo" namespace:@"ns1" content:nil];

    PXDocument *copiedDocument = [[PXDocument alloc] initWithElement:document.root];
    PXElement *copiedBarElement = [copiedDocument.root elementAtIndex:0];

    XCTAssertEqualObjects(copiedBarElement.name, @"bar");
    XCTAssertEqualObjects(copiedBarElement.namespace, @"ns2");
    XCTAssertNil(copiedBarElement.prefix);
    XCTAssertEqualObjects(document.data, copiedDocument.data);
}

@end
