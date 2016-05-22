//
//  PXInputStream.m
//  PureXML
//
//  Created by Tobias Kräntzer on 30.10.15.
//  Copyright © 2015 Tobias Kräntzer. All rights reserved.
//

#import <libxml/parser.h>
#import <libxml/tree.h>

#import "PXDocument.h"

#import "PXInputStream.h"

void PXInputStream_startDocumentSAXFunc(void *);
void PXInputStream_endDocumentSAXFunc(void *);
void XSInputStream_startElementNs(void *ctx,
                                  const xmlChar *localname,
                                  const xmlChar *prefix,
                                  const xmlChar *URI,
                                  int nb_namespaces,
                                  const xmlChar **namespaces,
                                  int nb_attributes,
                                  int nb_defaulted,
                                  const xmlChar **attributes);
void PXInputStream_endElementNs(void *ctx,
                                const xmlChar *localname,
                                const xmlChar *prefix,
                                const xmlChar *URI);

#pragma mark - XSInputStream

@interface PXInputStream () {
    xmlParserCtxtPtr _parserContext;
}

#pragma mark SAX Functions
@property (nonatomic, readonly) startDocumentSAXFunc xml_startDocumentSAXFunc;
@property (nonatomic, readonly) endDocumentSAXFunc xml_endDocumentSAXFunc;
@property (nonatomic, readonly) startElementNsSAX2Func xml_startElementNsSAX2Func;
@property (nonatomic, readonly) endElementNsSAX2Func xml_endElementNsSAX2Func;

@end

@implementation PXInputStream

#pragma mark Life-cycle

- (id)init
{
    self = [super init];
    if (self) {
        _parserContext = xmlCreatePushParserCtxt(NULL, NULL, NULL, 0, NULL);
        _parserContext->_private = (__bridge void *)(self);

        _xml_startDocumentSAXFunc = _parserContext->sax->startDocument;
        _xml_endDocumentSAXFunc = _parserContext->sax->endDocument;
        _xml_startElementNsSAX2Func = _parserContext->sax->startElementNs;
        _xml_endElementNsSAX2Func = _parserContext->sax->endElementNs;

        _parserContext->sax->startDocument = &PXInputStream_startDocumentSAXFunc;
        _parserContext->sax->endDocument = &PXInputStream_endDocumentSAXFunc;
        _parserContext->sax->startElementNs = &XSInputStream_startElementNs;
        _parserContext->sax->endElementNs = &PXInputStream_endElementNs;
    }
    return self;
}

- (void)dealloc
{
    xmlFreeDoc(_parserContext->myDoc);
    xmlFreeParserCtxt(_parserContext);
}

#pragma mark Feed Stream

- (void)processData:(NSData *)chunk terminate:(BOOL)terminate
{
    int err = 0;
    if (chunk) {
        err = xmlParseChunk(_parserContext, [chunk bytes], (int)[chunk length], terminate);
    } else {
        err = xmlParseChunk(_parserContext, NULL, 0, terminate);
    }

    NSAssert(err == 0, @"Failed to parse chunk: %d", err);
}

@end

#pragma mark - SAX Callbacks

void PXInputStream_startDocumentSAXFunc(void *ctxt)
{
    xmlParserCtxtPtr context = (xmlParserCtxtPtr)ctxt;

    PXInputStream *stream = (__bridge PXInputStream *)(context->_private);
    stream.xml_startDocumentSAXFunc(ctxt);
}

void PXInputStream_endDocumentSAXFunc(void *ctxt)
{
    xmlParserCtxtPtr context = (xmlParserCtxtPtr)ctxt;

    PXInputStream *stream = (__bridge PXInputStream *)(context->_private);
    stream.xml_endDocumentSAXFunc(ctxt);
}

void XSInputStream_startElementNs(void *ctxt,
                                  const xmlChar *localname,
                                  const xmlChar *prefix,
                                  const xmlChar *URI,
                                  int nb_namespaces,
                                  const xmlChar **namespaces,
                                  int nb_attributes,
                                  int nb_defaulted,
                                  const xmlChar **attributes)
{
    xmlParserCtxtPtr context = (xmlParserCtxtPtr)ctxt;

    PXInputStream *stream = (__bridge PXInputStream *)(context->_private);
    stream.xml_startElementNsSAX2Func(ctxt, localname, prefix, URI, nb_namespaces, namespaces, nb_attributes, nb_defaulted, attributes);

    // Just added the root node to the document.
    if (context->nodeNr == 1 && [stream.delegate respondsToSelector:@selector(inputStream:didOpenWithHeader:)]) {
        xmlDocPtr _doc = xmlCopyDoc(context->myDoc, 1);
        PXDocument *streamDoc = [[PXDocument alloc] initWithXMLDoc:_doc];
        [stream.delegate inputStream:stream didOpenWithHeader:streamDoc.root];
    }
}

void PXInputStream_endElementNs(void *ctxt,
                                const xmlChar *localname,
                                const xmlChar *prefix,
                                const xmlChar *URI)
{
    xmlParserCtxtPtr context = (xmlParserCtxtPtr)ctxt;

    xmlNodePtr stanzaNode = NULL;
    if (context->nodeNr == 2) {
        stanzaNode = context->node;
    }

    PXInputStream *stream = (__bridge PXInputStream *)(context->_private);
    stream.xml_endElementNsSAX2Func(ctxt, localname, prefix, URI);

    if (stanzaNode && [stream.delegate respondsToSelector:@selector(inputStream:didReceiveElement:)]) {

        // Create a copy of the stream xml doc and a copy of the
        // stanza node. Set the copied node as the root node of the
        // new document and update all child nodes to point to the
        // new doc.

        xmlDocPtr _doc = xmlCopyDoc(context->myDoc, 0);
        xmlNodePtr node = xmlCopyNode(stanzaNode, 1);
        xmlDocSetRootElement(_doc, node);
        xmlSetTreeDoc(node, _doc);

        // The node needs to be copied, because libXml does some magic
        // with text nodes with reusing the memory.
        // Unlinking the stanzaNode and using it in the copied document
        // results into a crash if that document get's freed.

        PXDocument *doc = [[PXDocument alloc] initWithXMLDoc:_doc];

        // Remove all remaining children (including the created stanza).
        // This is needed, because the parser tries to concat to successive text
        // nodes and does some magic reallocation. If the stanza node has been
        // removed from the current node, the successive text nodes don't have
        // successive memory.

        while (context->node->children) {
            xmlNodePtr node = context->node->children;
            xmlUnlinkNode(node);
            xmlFreeNode(node);
        }

        [stream.delegate inputStream:stream didReceiveElement:doc.root];
    }

    if (context->nodeNr == 0 && [stream.delegate respondsToSelector:@selector(inputStream:didCloseWithError:)]) {
        // Stream did finish
        [stream.delegate inputStream:stream didCloseWithError:nil];
    }
}
