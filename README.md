[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# PureXML

PureXML is a lightweight wrapper around libxml2 written in Objective-C for iOS and Mac OS X. It provides basic functionality to work with a XML document. You can access the element tree and the attributes of the elements.

## Installation

### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PureXML into you Xcode project using Carthage, specify it in your Cartfile:

```
github "Intercambio/PureXML" ~> 1.1
```

## Usage

### Document

You can create a document from a XML file in a bundle by invoking:

```objc
NSBundle *bundle = [NSBundle mainBundle];
PXDocument *document = [PXDocument documentNamed:@"doc.xml" inBundle:bundle];
```

or you can create a new document with an root element:

```objc
PXDocument *document = [[PXDocument alloc] initWithElementName:@"foo" namespace:@"http://example.com/ns" prefix:@"ns"];
```

### Elements

Once you have a document you can access the root element and traverse or modify the element tree.

```objc
PXElement *rootElement = document.root;
[rootElement enumerateElementsUsingBlock:^(PXElement *elements, BOOL *stop) {
    // Do something with the child element.
}];
```

```objc
PXElement *element = [document.root addElementWithName:@"el" namespace:@"http://example.com/ns" content:nil];
```

### Attributes

You can access attributes of the element without namespace

```objc
[rootElement setValue:@"1" forAttribute:@"a"];
[rootElement valueForAttribute:@"a"];
```

or with a namespace

```objc
[rootElement setValue:@"1" forAttribute:@"a" inNamespace:@"http://example.com/ns"];
[rootElement valueForAttribute:@"a" inNamespace:@"http://example.com/ns"];
```
 
### Custom Classes for Elements

You can specify custom subclasses of `PXElement` that should be used in a document for certain element types (name and namespace). To do so, you can pass a dictionary with `PXQName` objects as the key and the classes as objects on creation of a document.

```objc
@interface Foo : PXElement

@end
```

```objc
NSDictionary *elementClasses = @{ PXQN(@"http://example.com/ns", @"foo") : [Foo class] };
PXDocument *document = [[PXDocument alloc] initWithElementName:@"foo"
                                                     namespace:@"http://example.com/ns"
                                                        prefix:@"bar"
                                                elementClasses:elementClasses];

Foo *root = (Foo *)document.root;
```

In the example above the class `Foo` is now used for each element with the name `foo` in the namespace `http://example.com/ns` in this document. You can use this, to provide custom accessors to the content of the element.

If you don't want to specify the element classes for each document, you can register them globally in you application.

```objc
[PXDocument registerElementClass:[Foo class]
                forQualifiedName:PXQN(@"http://example.com/ns", @"foo")];
```

With this the class `Foo` is used as default for all elements with the name `foo` in the namespace `http://example.com/ns`. If you want to use a different class for an element in a document, you can overwrite the globally registered classes by providing a different class for a qualified name at creation of a document.


## Contributing

PureXML uses [git-flow](http://nvie.com/posts/a-successful-git-branching-model/) as branching model. New feature should always be started from the `develop` branch.

To contribute:

1. Fork it!
2. Create your feature branch (prefixed with feature): `git checkout -b feature/my-new-feature develop`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature/my-new-feature`
5. Submit a pull request :D

The unit tests are using OCMockito. To add the dependencies, simply run

```bash
$ carthage update
```

Before submitting a pull request, format the sources according to the `.clang-format` file in the repository. You can do so by invoking the script `./clang-formt.sh` also in the root of the repository.

## License

See LICENSE.md in the root of this repository.

