//
//  PXElementTests.m
//  PureXML
//
//  Created by Tobias Kräntzer on 15.09.14.
//  Copyright (c) 2014 Tobias Kräntzer. All rights reserved.
//

#import <PureXML/PureXML.h>
#import <XCTest/XCTest.h>

@interface PXMyElement : PXElement

@end

@interface PXFooElement : PXElement

@end

@interface PXElementTests : XCTestCase

@end

@implementation PXElementTests

- (void)testGetAttribute
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    PXDocument *document = [PXDocument documentNamed:@"simpleDocument.xml" inBundle:bundle];
    PXElement *rootElement = document.root;

    XCTAssertEqualObjects([rootElement valueForAttribute:@"from"], @"juliet@im.example.com");
    XCTAssertEqualObjects([rootElement valueForAttribute:@"version"], @"1.0");
    XCTAssertEqualObjects([rootElement valueForAttribute:@"test" inNamespace:@"http://example.com/foo"], @"bar");
    XCTAssertNil([rootElement valueForAttribute:@"test"], @"bar");

    NSMutableSet *attributes = [NSMutableSet set];
    [rootElement enumerateAttributesUsingBlock:^(NSString *name, NSString *value, NSString *namespace, BOOL *stop) {
        if (namespace) {
            [attributes addObject:[NSString stringWithFormat:@"%@: %@ (%@)", name, value, namespace]];
        } else {
            [attributes addObject:[NSString stringWithFormat:@"%@: %@", name, value]];
        }
    }];

    XCTAssertEqual([attributes count], 5);
    XCTAssertTrue([attributes containsObject:@"from: juliet@im.example.com"]);
    XCTAssertTrue([attributes containsObject:@"test: bar (http://example.com/foo)"]);
    XCTAssertTrue([attributes containsObject:@"to: im.example.com"]);
    XCTAssertTrue([attributes containsObject:@"version: 1.0"]);
    XCTAssertTrue([attributes containsObject:@"lang: en (http://www.w3.org/XML/1998/namespace)"]);
}

- (void)testSetAttribute
{
    PXDocument *document = [[PXDocument alloc] initWithElementName:@"foo"
                                                         namespace:@"http://example.com/ns"
                                                            prefix:nil];
    PXElement *root = document.root;

    [root setValue:@"1" forAttribute:@"a"];
    [root setValue:@"2" forAttribute:@"a" inNamespace:@"http://example.com/aaa"];
    [root setValue:@"3" forAttribute:@"a" inNamespace:@"http://example.com/xxx"];

    XCTAssertEqualObjects([root valueForAttribute:@"a"], @"1");
    XCTAssertEqualObjects([root valueForAttribute:@"a" inNamespace:@"http://example.com/aaa"], @"2");
    XCTAssertEqualObjects([root valueForAttribute:@"a" inNamespace:@"http://example.com/xxx"], @"3");

    [root setValue:@"4" forAttribute:@"a" inNamespace:@"http://example.com/ns"];
    XCTAssertEqualObjects([root valueForAttribute:@"a" inNamespace:@"http://example.com/ns"], @"4");

    [root setValue:nil forAttribute:@"a"];
    XCTAssertNil([root valueForAttribute:@"a"]);
}

- (void)testGetChildren
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    PXDocument *document = [PXDocument documentNamed:@"simpleDocument.xml" inBundle:bundle];
    PXElement *rootElement = document.root;

    NSMutableArray *children = [NSMutableArray array];
    [rootElement enumerateChildrenUsingBlock:^(PXNode *child, BOOL *stop) {
        [children addObject:child];
    }];

    XCTAssertEqual([children count], 5);
    XCTAssertEqualObjects([children[1] name], @"foo");
    XCTAssertEqualObjects([children[1] namespace], @"jabber:client");

    XCTAssertEqualObjects([children[3] name], @"bar");
    XCTAssertEqualObjects([children[3] namespace], @"jabber:client");
}

- (void)testGetElements
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    PXDocument *document = [PXDocument documentNamed:@"simpleDocument.xml" inBundle:bundle];
    PXElement *rootElement = document.root;

    NSMutableArray *elements = [NSMutableArray array];
    [rootElement enumerateElementsUsingBlock:^(PXElement *element, BOOL *stop) {
        [elements addObject:element];
    }];

    XCTAssertEqual([elements count], 2);
    XCTAssertEqualObjects([elements[0] name], @"foo");
    XCTAssertEqualObjects([elements[0] namespace], @"jabber:client");

    XCTAssertEqualObjects([elements[1] name], @"bar");
    XCTAssertEqualObjects([elements[1] namespace], @"jabber:client");

    XCTAssertEqual([rootElement numberOfElements], 2);

    PXElement *element = [rootElement elementAtIndex:1];
    XCTAssertTrue([element isKindOfClass:[PXElement class]]);
    XCTAssertEqualObjects(element.name, @"bar");
    XCTAssertEqualObjects(element.namespace, @"jabber:client");

    XCTAssertNil([rootElement elementAtIndex:4]);
}

- (void)testAddElementWithName
{
    PXDocument *document = [[PXDocument alloc] initWithElementName:@"foo"
                                                         namespace:@"http://example.com/ns"
                                                            prefix:@"bar"];

    PXElement *element = [document.root addElementWithName:@"el" namespace:nil content:nil];

    XCTAssert(element, @"el");
    XCTAssert(element.namespace, @"http://example.com/ns");

    [document.root addElementWithName:@"el" namespace:@"http://example.com/xxx" content:@"Some content"];

    XCTAssertEqual([document.root numberOfElements], 2);
    XCTAssertEqualObjects([[document.root elementAtIndex:0] name], @"el");
    XCTAssertEqualObjects([[document.root elementAtIndex:0] namespace], @"http://example.com/ns");

    XCTAssertEqualObjects([[document.root elementAtIndex:1] name], @"el");
    XCTAssertEqualObjects([[document.root elementAtIndex:1] namespace], @"http://example.com/xxx");
}

- (void)testAddElement
{
    PXDocument *document = [[PXDocument alloc] initWithElementName:@"foo"
                                                         namespace:@"http://example.com/ns"
                                                            prefix:@"bar"];

    [document.root addElementWithName:@"a" namespace:nil content:nil];
    PXElement *x = [document.root addElementWithName:@"x" namespace:nil content:nil];
    PXElement *el = [[document.root elementAtIndex:0] addElementWithName:@"e" namespace:nil content:nil];
    [el addElement:x];
}

- (void)testRemoveElement
{
    PXDocument *document = [[PXDocument alloc] initWithElementName:@"foo"
                                                         namespace:@"http://example.com/ns"
                                                            prefix:@"bar"];

    PXElement *element = [document.root addElementWithName:@"el" namespace:nil content:nil];

    XCTAssertEqual([document.root numberOfElements], 1);
    XCTAssertEqualObjects([[document.root elementAtIndex:0] name], @"el");
    XCTAssertEqualObjects([[document.root elementAtIndex:0] namespace], @"http://example.com/ns");

    XCTAssertEqualObjects(element.parent, document.root);

    [element removeFromParent];
    XCTAssertNil(element.parent);

    XCTAssertEqual([document.root numberOfElements], 0);
}

- (void)testXPathEvaluation
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    PXDocument *document = [PXDocument documentNamed:@"simpleDocument.xml" inBundle:bundle];
    PXElement *rootElement = document.root;

    NSArray *nodes = [rootElement nodesForXPath:@"x:foo"
                                usingNamespaces:@{ @"x" : @"jabber:client" }];

    XCTAssertEqual([nodes count], 1);
    XCTAssertEqualObjects([nodes[0] name], @"foo");
    XCTAssertEqualObjects([nodes[0] namespace], @"jabber:client");
}

- (void)testEqualToQName
{
    PXDocument *document = [[PXDocument alloc] initWithElementName:@"foo"
                                                         namespace:@"http://example.com/ns"
                                                            prefix:@"bar"];

    PXQName *qname = PXQN(@"http://example.com/ns", @"foo");
    XCTAssertEqualObjects(document.root.qualifiedName, qname);
    XCTAssertEqualObjects(document.root, qname);
    XCTAssertEqualObjects(qname, document.root);

    PXQName *otherQName = PXQN(@"http://example.com/ns", @"bar");
    XCTAssertNotEqualObjects(document.root.qualifiedName, otherQName);
    XCTAssertNotEqualObjects(document.root, otherQName);
    XCTAssertNotEqualObjects(otherQName, document.root);
}

- (void)testElementClasses
{
    NSDictionary *elementClasses = @{ PXQN(@"http://example.com/ns", @"my") : [PXMyElement class] };
    PXDocument *document = [[PXDocument alloc] initWithElementName:@"my"
                                                         namespace:@"http://example.com/ns"
                                                            prefix:@"bar"
                                                    elementClasses:elementClasses];

    PXElement *root = document.root;
    XCTAssertEqualObjects([root class], [PXMyElement class]);
}

- (void)testRegisteredElementClasses
{
    PXDocument *document = [[PXDocument alloc] initWithElementName:@"foo"
                                                         namespace:@"http://example.com/ns2"
                                                            prefix:@"bar"];

    PXElement *root = document.root;
    XCTAssertEqualObjects([root class], [PXFooElement class]);
}

- (void)testMissingNamespace
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    PXDocument *document = [PXDocument documentNamed:@"missingNamespace.xml" inBundle:bundle];
    XCTAssertNil(document.root.qualifiedName);
}

@end

@implementation PXMyElement

@end

@implementation PXFooElement

+ (void)load
{
    [PXDocument registerElementClass:[self class] forQualifiedName:PXQN(@"http://example.com/ns2", @"foo")];
}

@end
