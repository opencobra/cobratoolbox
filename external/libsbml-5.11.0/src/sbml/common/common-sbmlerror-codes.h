/**
 * @class doc_sbml_error_table
 *
 * @par
<table id="sbmlerror-table"
       class="text-table small-font alt-row-colors"
       width="95%" cellspacing="1" cellpadding="2" border="0">
 <tr style="background: lightgray" class="normal-font">
     <th valign="bottom"><strong>Enumerator</strong></th>
     <th valign="bottom"><strong>Meaning</strong></th>
     <th align="center" width="10">L1 V1</th>
     <th align="center" width="10">L1 V2</th>
     <th align="center" width="10">L2 V1</th>
     <th align="center" width="10">L2 V2</th>
     <th align="center" width="10">L2 V3</th>
     <th align="center" width="10">L2 V4</th>
     <th align="center" width="10">L3 V1</th>
 </tr>
<tr><td class="code">@sbmlconstant{XMLUnknownError, SBMLErrorCode_t}</td>
<td class="meaning">Unknown error</td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLOutOfMemory, SBMLErrorCode_t}</td>
<td class="meaning">Out of memory</td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLFileUnreadable, SBMLErrorCode_t}</td>
<td class="meaning">File unreadable</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLFileUnwritable, SBMLErrorCode_t}</td>
<td class="meaning">File unwritable</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLFileOperationError, SBMLErrorCode_t}</td>
<td class="meaning">File operation error</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLNetworkAccessError, SBMLErrorCode_t}</td>
<td class="meaning">Network access error</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InternalXMLParserError, SBMLErrorCode_t}</td>
<td class="meaning">Internal XML parser error</td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
</tr>
<tr><td class="code">@sbmlconstant{UnrecognizedXMLParserCode, SBMLErrorCode_t}</td>
<td class="meaning">Unrecognized XML parser code</td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLTranscoderError, SBMLErrorCode_t}</td>
<td class="meaning">Transcoder error</td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
</tr>
<tr><td class="code">@sbmlconstant{MissingXMLDecl, SBMLErrorCode_t}</td>
<td class="meaning">Missing XML declaration</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MissingXMLEncoding, SBMLErrorCode_t}</td>
<td class="meaning">Missing XML encoding attribute</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadXMLDecl, SBMLErrorCode_t}</td>
<td class="meaning">Bad XML declaration</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadXMLDOCTYPE, SBMLErrorCode_t}</td>
<td class="meaning">Bad XML DOCTYPE</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidCharInXML, SBMLErrorCode_t}</td>
<td class="meaning">Invalid character</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadlyFormedXML, SBMLErrorCode_t}</td>
<td class="meaning">Badly formed XML</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{UnclosedXMLToken, SBMLErrorCode_t}</td>
<td class="meaning">Unclosed token</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidXMLConstruct, SBMLErrorCode_t}</td>
<td class="meaning">Invalid XML construct</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLTagMismatch, SBMLErrorCode_t}</td>
<td class="meaning">XML tag mismatch</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DuplicateXMLAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate attribute</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{UndefinedXMLEntity, SBMLErrorCode_t}</td>
<td class="meaning">Undefined XML entity</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadProcessingInstruction, SBMLErrorCode_t}</td>
<td class="meaning">Bad XML processing instruction</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadXMLPrefix, SBMLErrorCode_t}</td>
<td class="meaning">Bad XML prefix</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadXMLPrefixValue, SBMLErrorCode_t}</td>
<td class="meaning">Bad XML prefix value</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MissingXMLRequiredAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Missing required attribute</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLAttributeTypeMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Attribute type mismatch</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLBadUTF8Content, SBMLErrorCode_t}</td>
<td class="meaning">Bad UTF8 content</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MissingXMLAttributeValue, SBMLErrorCode_t}</td>
<td class="meaning">Missing attribute value</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadXMLAttributeValue, SBMLErrorCode_t}</td>
<td class="meaning">Bad attribute value</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadXMLAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Bad XML attribute</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{UnrecognizedXMLElement, SBMLErrorCode_t}</td>
<td class="meaning">Unrecognized XML element</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadXMLComment, SBMLErrorCode_t}</td>
<td class="meaning">Bad XML comment</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadXMLDeclLocation, SBMLErrorCode_t}</td>
<td class="meaning">Bad XML declaration location</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLUnexpectedEOF, SBMLErrorCode_t}</td>
<td class="meaning">Unexpected EOF</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadXMLIDValue, SBMLErrorCode_t}</td>
<td class="meaning">Bad XML ID value</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadXMLIDRef, SBMLErrorCode_t}</td>
<td class="meaning">Bad XML IDREF</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{UninterpretableXMLContent, SBMLErrorCode_t}</td>
<td class="meaning">Uninterpretable XML content</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadXMLDocumentStructure, SBMLErrorCode_t}</td>
<td class="meaning">Bad XML document structure</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidAfterXMLContent, SBMLErrorCode_t}</td>
<td class="meaning">Invalid content after XML content</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLExpectedQuotedString, SBMLErrorCode_t}</td>
<td class="meaning">Expected quoted string</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLEmptyValueNotPermitted, SBMLErrorCode_t}</td>
<td class="meaning">Empty value not permitted</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLBadNumber, SBMLErrorCode_t}</td>
<td class="meaning">Bad number</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLBadColon, SBMLErrorCode_t}</td>
<td class="meaning">Colon character not permitted</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MissingXMLElements, SBMLErrorCode_t}</td>
<td class="meaning">Missing XML elements</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{XMLContentEmpty, SBMLErrorCode_t}</td>
<td class="meaning">Empty XML content</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{UnknownError, SBMLErrorCode_t}</td>
<td class="meaning">Encountered unknown internal libSBML error</td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
<td class="s-fatal"></td>
</tr>
<tr><td class="code">@sbmlconstant{NotUTF8, SBMLErrorCode_t}</td>
<td class="meaning">File does not use UTF-8 encoding</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{UnrecognizedElement, SBMLErrorCode_t}</td>
<td class="meaning">Encountered unrecognized element</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NotSchemaConformant, SBMLErrorCode_t}</td>
<td class="meaning">Document does not conform to the SBML XML schema</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{L3NotSchemaConformant, SBMLErrorCode_t}</td>
<td class="meaning">Document is not well-formed XML</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidMathElement, SBMLErrorCode_t}</td>
<td class="meaning">Invalid MathML</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DisallowedMathMLSymbol, SBMLErrorCode_t}</td>
<td class="meaning">Disallowed MathML symbol found</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DisallowedMathMLEncodingUse, SBMLErrorCode_t}</td>
<td class="meaning">Use of the MathML 'encoding' attribute is not allowed on this element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DisallowedDefinitionURLUse, SBMLErrorCode_t}</td>
<td class="meaning">Use of the MathML 'definitionURL' attribute is not allowed on this element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadCsymbolDefinitionURLValue, SBMLErrorCode_t}</td>
<td class="meaning">Invalid <code>&lt;csymbol&gt;</code> 'definitionURL' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DisallowedMathTypeAttributeUse, SBMLErrorCode_t}</td>
<td class="meaning">Use of the MathML 'type' attribute is not allowed on this element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DisallowedMathTypeAttributeValue, SBMLErrorCode_t}</td>
<td class="meaning">Disallowed MathML 'type' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LambdaOnlyAllowedInFunctionDef, SBMLErrorCode_t}</td>
<td class="meaning">Use of <code>&lt;lambda&gt;</code> not permitted outside of FunctionDefinition objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BooleanOpsNeedBooleanArgs, SBMLErrorCode_t}</td>
<td class="meaning">Non-Boolean argument given to Boolean operator</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NumericOpsNeedNumericArgs, SBMLErrorCode_t}</td>
<td class="meaning">Non-numerical argument given to numerical operator</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{ArgsToEqNeedSameType, SBMLErrorCode_t}</td>
<td class="meaning">Arguments to <code>&lt;eq&gt;</code> and <code>&lt;neq&gt;</code> must have the same data types</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{PiecewiseNeedsConsistentTypes, SBMLErrorCode_t}</td>
<td class="meaning">Terms in a <code>&lt;piecewise&gt;</code> expression must have consistent data types</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{PieceNeedsBoolean, SBMLErrorCode_t}</td>
<td class="meaning">The second argument of a <code>&lt;piece&gt;</code> expression must yield a Boolean value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{ApplyCiMustBeUserFunction, SBMLErrorCode_t}</td>
<td class="meaning">A <code>&lt;ci&gt;</code> element in this context must refer to a function definition</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{ApplyCiMustBeModelComponent, SBMLErrorCode_t}</td>
<td class="meaning">A <code>&lt;ci&gt;</code> element in this context must refer to a model component</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{KineticLawParametersAreLocalOnly, SBMLErrorCode_t}</td>
<td class="meaning">Cannot use a KineticLaw local parameter outside of its local scope</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MathResultMustBeNumeric, SBMLErrorCode_t}</td>
<td class="meaning">A formula's result in this context must be a numerical value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OpsNeedCorrectNumberOfArgs, SBMLErrorCode_t}</td>
<td class="meaning">Incorrect number of arguments given to MathML operator</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidNoArgsPassedToFunctionDef, SBMLErrorCode_t}</td>
<td class="meaning">Incorrect number of arguments given to function invocation</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DisallowedMathUnitsUse, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'units' is only permitted on <code>&lt;cn&gt;</code> elements</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidUnitsValue, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value given for the 'units' attribute</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DuplicateComponentId, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate 'id' attribute value</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DuplicateUnitDefinitionId, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate unit definition 'id' attribute value</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DuplicateLocalParameterId, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate local parameter 'id' attribute value</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MultipleAssignmentOrRateRules, SBMLErrorCode_t}</td>
<td class="meaning">Multiple rules for the same variable are not allowed</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MultipleEventAssignmentsForId, SBMLErrorCode_t}</td>
<td class="meaning">Multiple event assignments for the same variable are not allowed</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{EventAndAssignmentRuleForId, SBMLErrorCode_t}</td>
<td class="meaning">An event assignment and an assignment rule must not have the same value for 'variable'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DuplicateMetaId, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate 'metaid' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidSBOTermSyntax, SBMLErrorCode_t}</td>
<td class="meaning">Invalid syntax for an 'sboTerm' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidMetaidSyntax, SBMLErrorCode_t}</td>
<td class="meaning">Invalid syntax for a 'metaid' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidIdSyntax, SBMLErrorCode_t}</td>
<td class="meaning">Invalid syntax for an 'id' attribute value</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidUnitIdSyntax, SBMLErrorCode_t}</td>
<td class="meaning">Invalid syntax for the identifier of a unit</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidNameSyntax, SBMLErrorCode_t}</td>
<td class="meaning">Invalid syntax for a 'name' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MissingAnnotationNamespace, SBMLErrorCode_t}</td>
<td class="meaning">Missing declaration of the XML namespace for the annotation</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DuplicateAnnotationNamespaces, SBMLErrorCode_t}</td>
<td class="meaning">Multiple annotations using the same XML namespace</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{SBMLNamespaceInAnnotation, SBMLErrorCode_t}</td>
<td class="meaning">The SBML XML namespace cannot be used in an Annotation object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{MultipleAnnotations, SBMLErrorCode_t}</td>
<td class="meaning">Only one Annotation object is permitted under a given SBML object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InconsistentArgUnits, SBMLErrorCode_t}</td>
<td class="meaning">The units of the function call's arguments are not consistent with its definition</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InconsistentKineticLawUnitsL3, SBMLErrorCode_t}</td>
<td class="meaning">The kinetic law's units are inconsistent with those of other kinetic laws in the model</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{AssignRuleCompartmentMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in assignment rule for compartment</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{AssignRuleSpeciesMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in assignment rule for species</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{AssignRuleParameterMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in assignment rule for parameter</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{AssignRuleStoichiometryMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in assignment rule for stoichiometry</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InitAssignCompartmenMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in initial assignment to compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InitAssignSpeciesMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in initial assignment to species</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InitAssignParameterMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in initial assignment to parameter</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InitAssignStoichiometryMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in initial assignment to stoichiometry</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{RateRuleCompartmentMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in rate rule for compartment</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{RateRuleSpeciesMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in rate rule for species</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{RateRuleParameterMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in rate rule for parameter</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{RateRuleStoichiometryMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in rate rule for stoichiometry</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{KineticLawNotSubstancePerTime, SBMLErrorCode_t}</td>
<td class="meaning">The units of the kinetic law are not 'substance'/'time'</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{SpeciesInvalidExtentUnits, SBMLErrorCode_t}</td>
<td class="meaning">The species' units are not consistent with units of extent</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{DelayUnitsNotTime, SBMLErrorCode_t}</td>
<td class="meaning">The units of the delay expression are not units of time</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{EventAssignCompartmentMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in event assignment for compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{EventAssignSpeciesMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in event assignment for species</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{EventAssignParameterMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in event assignment for parameter</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{EventAssignStoichiometryMismatch, SBMLErrorCode_t}</td>
<td class="meaning">Mismatched units in event assignment for stoichiometry</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{PriorityUnitsNotDimensionless, SBMLErrorCode_t}</td>
<td class="meaning">The units of a priority expression must be 'dimensionless'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{OverdeterminedSystem, SBMLErrorCode_t}</td>
<td class="meaning">The model is overdetermined</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidModelSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for a Model object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidFunctionDefSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for a FunctionDefinition object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidParameterSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for a Parameter object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidInitAssignSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for an InitialAssignment object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidRuleSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for a Rule object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidConstraintSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for a Constraint object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidReactionSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for a Reaction object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidSpeciesReferenceSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for a SpeciesReference object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidKineticLawSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for a KineticLaw object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidEventSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for an Event object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidEventAssignmentSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for an EventAssignment object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidCompartmentSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for a Compartment object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidSpeciesSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for a Species object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidCompartmentTypeSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for a CompartmentType object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidSpeciesTypeSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for a SpeciesType object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidTriggerSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for an Event Trigger object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidDelaySBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'sboTerm' attribute value for an Event Delay object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{NotesNotInXHTMLNamespace, SBMLErrorCode_t}</td>
<td class="meaning">Notes must be placed in the XHTML XML namespace</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NotesContainsXMLDecl, SBMLErrorCode_t}</td>
<td class="meaning">XML declarations are not permitted in Notes objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NotesContainsDOCTYPE, SBMLErrorCode_t}</td>
<td class="meaning">XML DOCTYPE elements are not permitted in Notes objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidNotesContent, SBMLErrorCode_t}</td>
<td class="meaning">Invalid notes content found</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyOneNotesElementAllowed, SBMLErrorCode_t}</td>
<td class="meaning">Only one Notes subobject is permitted on a given SBML object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidNamespaceOnSBML, SBMLErrorCode_t}</td>
<td class="meaning">Invalid XML namespace for the SBML container element</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MissingOrInconsistentLevel, SBMLErrorCode_t}</td>
<td class="meaning">Missing or inconsistent value for the 'level' attribute</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MissingOrInconsistentVersion, SBMLErrorCode_t}</td>
<td class="meaning">Missing or inconsistent value for the 'version' attribute</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{PackageNSMustMatch, SBMLErrorCode_t}</td>
<td class="meaning">Inconsistent or invalid SBML Level/Version for the package namespace declaration</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LevelPositiveInteger, SBMLErrorCode_t}</td>
<td class="meaning">The 'level' attribute must have a positive integer value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{VersionPositiveInteger, SBMLErrorCode_t}</td>
<td class="meaning">The 'version' attribute must have a positive integer value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnSBML, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the SBML container element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{L3PackageOnLowerSBML, SBMLErrorCode_t}</td>
<td class="meaning">An L3 package ns found on the SBML container element</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{MissingModel, SBMLErrorCode_t}</td>
<td class="meaning">No model definition found</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{IncorrectOrderInModel, SBMLErrorCode_t}</td>
<td class="meaning">Incorrect ordering of components within the Model object</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{EmptyListElement, SBMLErrorCode_t}</td>
<td class="meaning">Empty ListOf___ object found</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NeedCompartmentIfHaveSpecies, SBMLErrorCode_t}</td>
<td class="meaning">The presence of a species requires a compartment</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneOfEachListOf, SBMLErrorCode_t}</td>
<td class="meaning">Only one of each kind of ListOf___ object is allowed inside a Model object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyFuncDefsInListOfFuncDefs, SBMLErrorCode_t}</td>
<td class="meaning">Only FunctionDefinition, Notes and Annotation objects are allowed in ListOfFunctionDefinitions</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyUnitDefsInListOfUnitDefs, SBMLErrorCode_t}</td>
<td class="meaning">Only UnitDefinition, Notes and Annotation objects are allowed in ListOfUnitDefinitions objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyCompartmentsInListOfCompartments, SBMLErrorCode_t}</td>
<td class="meaning">Only Compartment, Notes and Annotation objects are allowed in ListOfCompartments objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlySpeciesInListOfSpecies, SBMLErrorCode_t}</td>
<td class="meaning">Only Species, Notes and Annotation objects are allowed in ListOfSpecies objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyParametersInListOfParameters, SBMLErrorCode_t}</td>
<td class="meaning">Only Parameter, Notes and Annotation objects are allowed in ListOfParameters objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyInitAssignsInListOfInitAssigns, SBMLErrorCode_t}</td>
<td class="meaning">Only InitialAssignment, Notes and Annotation objects are allowed in ListOfInitialAssignments objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyRulesInListOfRules, SBMLErrorCode_t}</td>
<td class="meaning">Only Rule, Notes and Annotation objects are allowed in ListOfRules objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyConstraintsInListOfConstraints, SBMLErrorCode_t}</td>
<td class="meaning">Only Constraint, Notes and Annotation objects are allowed in ListOfConstraints objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyReactionsInListOfReactions, SBMLErrorCode_t}</td>
<td class="meaning">Only Reaction, Notes and Annotation objects are allowed in ListOfReactions objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyEventsInListOfEvents, SBMLErrorCode_t}</td>
<td class="meaning">Only Event, Notes and Annotation objects are allowed in ListOfEvents objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{L3ConversionFactorOnModel, SBMLErrorCode_t}</td>
<td class="meaning">A 'conversionFactor' attribute value must reference a Parameter object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{L3TimeUnitsOnModel, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'timeUnits' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{L3VolumeUnitsOnModel, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'volumeUnits' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{L3AreaUnitsOnModel, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'areaUnits' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{L3LengthUnitsOnModel, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'lengthUnits' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{L3ExtentUnitsOnModel, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'extentUnits' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnModel, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the Model object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfFuncs, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfFunctionDefinitions object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfUnitDefs, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfUnitDefinitions object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfComps, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfCompartments object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfSpecies, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfSpecies object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfParams, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfParameters object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfInitAssign, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfInitialAssignments object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfRules, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfRules object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfConstraints, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfConstraints object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfReactions, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfReactions object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfEvents, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfEvents object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FunctionDefMathNotLambda, SBMLErrorCode_t}</td>
<td class="meaning">Invalid expression found in the function definition</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidApplyCiInLambda, SBMLErrorCode_t}</td>
<td class="meaning">Invalid forward reference in the MathML <code>&lt;apply&gt;</code><code>&lt;ci&gt;</code>...<code>&lt;/ci&gt;</code><code>&lt;/apply&gt;</code> expression</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{RecursiveFunctionDefinition, SBMLErrorCode_t}</td>
<td class="meaning">Recursive function definitions are not permitted</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidCiInLambda, SBMLErrorCode_t}</td>
<td class="meaning">Invalid <code>&lt;ci&gt;</code> reference found inside the <code>&lt;lambda&gt;</code> mathematical formula</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidFunctionDefReturnType, SBMLErrorCode_t}</td>
<td class="meaning">A function's return type must be either a number or a Boolean</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneMathElementPerFunc, SBMLErrorCode_t}</td>
<td class="meaning">A FunctionDefinition object must contain one <code>&lt;math&gt;</code> element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnFunc, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the FunctionDefinition object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidUnitDefId, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'id' attribute value for a UnitDefinition object</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidSubstanceRedefinition, SBMLErrorCode_t}</td>
<td class="meaning">Invalid redefinition of built-in type 'substance'</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidLengthRedefinition, SBMLErrorCode_t}</td>
<td class="meaning">Invalid redefinition of built-in type 'length'</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidAreaRedefinition, SBMLErrorCode_t}</td>
<td class="meaning">Invalid redefinition of built-in type name 'area'</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidTimeRedefinition, SBMLErrorCode_t}</td>
<td class="meaning">Invalid redefinition of built-in type name 'time'</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidVolumeRedefinition, SBMLErrorCode_t}</td>
<td class="meaning">Invalid redefinition of built-in type name 'volume'</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{VolumeLitreDefExponentNotOne, SBMLErrorCode_t}</td>
<td class="meaning">Must use 'exponent'=1 when defining 'volume' in terms of litres</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{VolumeMetreDefExponentNot3, SBMLErrorCode_t}</td>
<td class="meaning">Must use 'exponent'=3 when defining 'volume' in terms of metres</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{EmptyListOfUnits, SBMLErrorCode_t}</td>
<td class="meaning">An empty list of Unit objects is not permitted in a UnitDefinition object</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidUnitKind, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'kind' attribute of a UnitDefinition object</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OffsetNoLongerValid, SBMLErrorCode_t}</td>
<td class="meaning">Unit attribute 'offset' is not supported in this Level+Version of SBML</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{CelsiusNoLongerValid, SBMLErrorCode_t}</td>
<td class="meaning">Unit name 'Celsius' is not defined in this Level+Version of SBML</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{EmptyUnitListElement, SBMLErrorCode_t}</td>
<td class="meaning">A ListOfUnits object must not be empty</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneListOfUnitsPerUnitDef, SBMLErrorCode_t}</td>
<td class="meaning">At most one ListOfUnits object is allowed inside a UnitDefinition object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyUnitsInListOfUnits, SBMLErrorCode_t}</td>
<td class="meaning">Only Unit, Notes and Annotation objects are allowed in ListOfUnits objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnUnitDefinition, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the UnitDefinition object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfUnits, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfUnits object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnUnit, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the Unit object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{ZeroDimensionalCompartmentSize, SBMLErrorCode_t}</td>
<td class="meaning">Invalid use of the 'size' attribute for a zero-dimensional compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{ZeroDimensionalCompartmentUnits, SBMLErrorCode_t}</td>
<td class="meaning">Invalid use of the 'units' attribute for a zero-dimensional compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{ZeroDimensionalCompartmentConst, SBMLErrorCode_t}</td>
<td class="meaning">Zero-dimensional compartments must be defined to be constant</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{UndefinedOutsideCompartment, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'outside' attribute of a Compartment object</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{RecursiveCompartmentContainment, SBMLErrorCode_t}</td>
<td class="meaning">Recursive nesting of compartments via the 'outside' attribute is not permitted</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{ZeroDCompartmentContainment, SBMLErrorCode_t}</td>
<td class="meaning">Invalid nesting of zero-dimensional compartments</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{Invalid1DCompartmentUnits, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'units' attribute of a one-dimensional compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{Invalid2DCompartmentUnits, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'units' attribute of a two-dimensional compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{Invalid3DCompartmentUnits, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'units' attribute of a three-dimensional compartment</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidCompartmentTypeRef, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'compartmentType' attribute of a compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneDimensionalCompartmentUnits, SBMLErrorCode_t}</td>
<td class="meaning">No units defined for 1-D compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{TwoDimensionalCompartmentUnits, SBMLErrorCode_t}</td>
<td class="meaning">No units defined for 2-D compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{ThreeDimensionalCompartmentUnits, SBMLErrorCode_t}</td>
<td class="meaning">No units defined for 3-D Compartment object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnCompartment, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on Compartment object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoUnitsOnCompartment, SBMLErrorCode_t}</td>
<td class="meaning">No units defined for Compartment object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidSpeciesCompartmentRef, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value found for Species 'compartment' attribute</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{HasOnlySubsNoSpatialUnits, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'spatialSizeUnits' must not be set if 'hasOnlySubstanceUnits'='true'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoSpatialUnitsInZeroD, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'spatialSizeUnits' must not be set if the compartment is zero-dimensional</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoConcentrationInZeroD, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'initialConcentration' must not be set if the compartment is zero-dimensional</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{SpatialUnitsInOneD, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for 'spatialSizeUnits' attribute of a one-dimensional compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{SpatialUnitsInTwoD, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'spatialSizeUnits' attribute of a two-dimensional compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{SpatialUnitsInThreeD, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'spatialSizeUnits' attribute of a three-dimensional compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidSpeciesSusbstanceUnits, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for a Species 'units' attribute</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{BothAmountAndConcentrationSet, SBMLErrorCode_t}</td>
<td class="meaning">Cannot set both 'initialConcentration' and 'initialAmount' attributes simultaneously</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NonBoundarySpeciesAssignedAndUsed, SBMLErrorCode_t}</td>
<td class="meaning">Cannot use a non-boundary species in both reactions and rules simultaneously</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NonConstantSpeciesUsed, SBMLErrorCode_t}</td>
<td class="meaning">Cannot use a constant, non-boundary species as a reactant or product</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidSpeciesTypeRef, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'speciesType' attribute of a species</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{MultSpeciesSameTypeInCompartment, SBMLErrorCode_t}</td>
<td class="meaning">Cannot have multiple species of the same species type in the same compartment</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{MissingSpeciesCompartment, SBMLErrorCode_t}</td>
<td class="meaning">Missing value for the 'compartment' attribute</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{SpatialSizeUnitsRemoved, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'spatialSizeUnits' is not supported in this Level+Version of SBML</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{SubstanceUnitsOnSpecies, SBMLErrorCode_t}</td>
<td class="meaning">No substance units defined for the species</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{ConversionFactorOnSpecies, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'conversionFactor' attribute</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnSpecies, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on Species object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidParameterUnits, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'units' attribute of a Parameter object</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{ParameterUnits, SBMLErrorCode_t}</td>
<td class="meaning">No units defined for the parameter</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{ConversionFactorMustConstant, SBMLErrorCode_t}</td>
<td class="meaning">A conversion factor must reference a Parameter object declared to be a constant</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnParameter, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on Parameter object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidInitAssignSymbol, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'symbol' attribute of an InitialAssignment object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MultipleInitAssignments, SBMLErrorCode_t}</td>
<td class="meaning">Multiple initial assignments for the same 'symbol' value are not allowed</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InitAssignmentAndRuleForSameId, SBMLErrorCode_t}</td>
<td class="meaning">Cannot set a value using both an initial assignment and an assignment rule simultaneously</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneMathElementPerInitialAssign, SBMLErrorCode_t}</td>
<td class="meaning">An InitialAssignment object must contain one <code>&lt;math&gt;</code> element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnInitialAssign, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on an InitialAssignment object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidAssignRuleVariable, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'variable' attribute of an AssignmentRule object</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidRateRuleVariable, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the 'variable' attribute of a RateRule object</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AssignmentToConstantEntity, SBMLErrorCode_t}</td>
<td class="meaning">An assignment rule cannot assign an entity declared to be constant</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{RateRuleForConstantEntity, SBMLErrorCode_t}</td>
<td class="meaning">A rate rule cannot assign an entity declared to be constant</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CircularRuleDependency, SBMLErrorCode_t}</td>
<td class="meaning">Circular dependencies involving rules and reactions are not permitted</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneMathElementPerRule, SBMLErrorCode_t}</td>
<td class="meaning">A rule object must contain one <code>&lt;math&gt;</code> element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnAssignRule, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on an AssignmentRule object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnRateRule, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on a RateRule object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnAlgRule, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on an AlgebraicRule object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{ConstraintMathNotBoolean, SBMLErrorCode_t}</td>
<td class="meaning">A Constraint object's <code>&lt;math&gt;</code> must evaluate to a Boolean value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{IncorrectOrderInConstraint, SBMLErrorCode_t}</td>
<td class="meaning">Subobjects inside the Constraint object are not in the prescribed order</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{ConstraintNotInXHTMLNamespace, SBMLErrorCode_t}</td>
<td class="meaning">A Constraint's Message subobject must be in the XHTML XML namespace</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{ConstraintContainsXMLDecl, SBMLErrorCode_t}</td>
<td class="meaning">XML declarations are not permitted within Constraint's Message objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{ConstraintContainsDOCTYPE, SBMLErrorCode_t}</td>
<td class="meaning">XML DOCTYPE elements are not permitted within Constraint's Message objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidConstraintContent, SBMLErrorCode_t}</td>
<td class="meaning">Invalid content for a Constraint object's Message object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneMathElementPerConstraint, SBMLErrorCode_t}</td>
<td class="meaning">A Constraint object must contain one <code>&lt;math&gt;</code> element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneMessageElementPerConstraint, SBMLErrorCode_t}</td>
<td class="meaning">A Constraint object must contain one Message subobject</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnConstraint, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on Constraint object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoReactantsOrProducts, SBMLErrorCode_t}</td>
<td class="meaning">Cannot have a reaction with neither reactants nor products</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{IncorrectOrderInReaction, SBMLErrorCode_t}</td>
<td class="meaning">Subobjects inside the Reaction object are not in the prescribed order</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{EmptyListInReaction, SBMLErrorCode_t}</td>
<td class="meaning">Reaction components, if present, cannot be empty</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidReactantsProductsList, SBMLErrorCode_t}</td>
<td class="meaning">Invalid object found in the list of reactants or products</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidModifiersList, SBMLErrorCode_t}</td>
<td class="meaning">Invalid object found in the list of modifiers</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneSubElementPerReaction, SBMLErrorCode_t}</td>
<td class="meaning">A Reaction object can only contain one of each allowed type of object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompartmentOnReaction, SBMLErrorCode_t}</td>
<td class="meaning">Invalid value for the Reaction 'compartment' attribute</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnReaction, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute for a Reaction object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidSpeciesReference, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'species' attribute value in SpeciesReference object</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BothStoichiometryAndMath, SBMLErrorCode_t}</td>
<td class="meaning">The 'stoichiometry' attribute and StoichiometryMath subobject are mutually exclusive</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnSpeciesReference, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the SpeciesReference object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnModifier, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ModifierSpeciesReference object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{UndeclaredSpeciesRef, SBMLErrorCode_t}</td>
<td class="meaning">Unknown species referenced in the kinetic law <code>&lt;math&gt;</code> formula</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{IncorrectOrderInKineticLaw, SBMLErrorCode_t}</td>
<td class="meaning">Incorrect ordering of components in the KineticLaw object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{EmptyListInKineticLaw, SBMLErrorCode_t}</td>
<td class="meaning">The list of parameters, if present, cannot be empty</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NonConstantLocalParameter, SBMLErrorCode_t}</td>
<td class="meaning">Parameters local to a KineticLaw object must have a 'constant' attribute value of 'true'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{SubsUnitsNoLongerValid, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'substanceUnits' is not supported in this Level+Version of SBML</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{TimeUnitsNoLongerValid, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'timeUnits' is not supported in this Level+Version of SBML</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneListOfPerKineticLaw, SBMLErrorCode_t}</td>
<td class="meaning">Only one ListOfLocalParameters object is permitted within a KineticLaw object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyLocalParamsInListOfLocalParams, SBMLErrorCode_t}</td>
<td class="meaning">Only LocalParameter, Notes and Annotation objects are allowed in ListOfLocalParameter objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfLocalParam, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfLocalParameters object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneMathPerKineticLaw, SBMLErrorCode_t}</td>
<td class="meaning">Only one <code>&lt;math&gt;</code> element is allowed in a KineticLaw object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{UndeclaredSpeciesInStoichMath, SBMLErrorCode_t}</td>
<td class="meaning">Unknown species referenced in the StoichiometryMath object's <code>&lt;math&gt;</code> formula</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnKineticLaw, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the KineticLaw object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfSpeciesRef, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfSpeciesReferences object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfMods, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfModifiers object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnLocalParameter, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the LocalParameter object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MissingTriggerInEvent, SBMLErrorCode_t}</td>
<td class="meaning">The Event object is missing a Trigger subobject</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{TriggerMathNotBoolean, SBMLErrorCode_t}</td>
<td class="meaning">A Trigger object's <code>&lt;math&gt;</code> expression must evaluate to a Boolean value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MissingEventAssignment, SBMLErrorCode_t}</td>
<td class="meaning">The Event object is missing an EventAssignment subobject</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{TimeUnitsEvent, SBMLErrorCode_t}</td>
<td class="meaning">Units referenced by 'timeUnits' attribute are not compatible with units of time</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{IncorrectOrderInEvent, SBMLErrorCode_t}</td>
<td class="meaning">Incorrect ordering of components in Event object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{ValuesFromTriggerTimeNeedDelay, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'useValuesFromTriggerTime'='false', but the Event object does not define a delay</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{DelayNeedsValuesFromTriggerTime, SBMLErrorCode_t}</td>
<td class="meaning">The use of a Delay object requires the Event attribute 'useValuesFromTriggerTime'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneMathPerTrigger, SBMLErrorCode_t}</td>
<td class="meaning">A Trigger object must have one <code>&lt;math&gt;</code> element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneMathPerDelay, SBMLErrorCode_t}</td>
<td class="meaning">A Delay object must have one <code>&lt;math&gt;</code> element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidEventAssignmentVariable, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'variable' attribute value in Event object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{EventAssignmentForConstantEntity, SBMLErrorCode_t}</td>
<td class="meaning">An EventAssignment object cannot assign to a component having attribute 'constant'='true'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneMathPerEventAssignment, SBMLErrorCode_t}</td>
<td class="meaning">An EventAssignment object must have one <code>&lt;math&gt;</code> element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnEventAssignment, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the EventAssignment object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyOneDelayPerEvent, SBMLErrorCode_t}</td>
<td class="meaning">An Event object can only have one Delay subobject</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneListOfEventAssignmentsPerEvent, SBMLErrorCode_t}</td>
<td class="meaning">An Event object can only have one ListOfEventAssignments subobject</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyEventAssignInListOfEventAssign, SBMLErrorCode_t}</td>
<td class="meaning">Only EventAssignment, Notes and Annotation objects are allowed in ListOfEventAssignments</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnListOfEventAssign, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the ListOfEventAssignments object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnEvent, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the Event object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnTrigger, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the Trigger object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnDelay, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the Delay object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{PersistentNotBoolean, SBMLErrorCode_t}</td>
<td class="meaning">The Trigger attribute 'persistent' must evaluate to a Boolean value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InitialValueNotBoolean, SBMLErrorCode_t}</td>
<td class="meaning">The Trigger attribute 'initialValue' must evaluate to a Boolean value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OnlyOnePriorityPerEvent, SBMLErrorCode_t}</td>
<td class="meaning">An Event object can only have one Priority subobject</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{OneMathPerPriority, SBMLErrorCode_t}</td>
<td class="meaning">A Priority object must have one <code>&lt;math&gt;</code> element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AllowedAttributesOnPriority, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on the Priority object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompartmentShouldHaveSize, SBMLErrorCode_t}</td>
<td class="meaning">It's best to define a size for every compartment in a model</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{SpeciesShouldHaveValue, SBMLErrorCode_t}</td>
<td class="meaning">It's best to define an initial amount or initial concentration for every species in a model</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{ParameterShouldHaveUnits, SBMLErrorCode_t}</td>
<td class="meaning">It's best to declare units for every parameter in a model</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{LocalParameterShadowsId, SBMLErrorCode_t}</td>
<td class="meaning">Local parameters defined within a kinetic law shadow global object symbols</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{CannotConvertToL1V1, SBMLErrorCode_t}</td>
<td class="meaning">Cannot convert to SBML Level 1 Version 1</td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoEventsInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support events</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoFunctionDefinitionsInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support function definitions</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoConstraintsInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support constraints</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoInitialAssignmentsInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support initial assignments</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoSpeciesTypesInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support species types</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoCompartmentTypeInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support compartment types</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoNon3DCompartmentsInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 only supports three-dimensional compartments</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoFancyStoichiometryMathInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support non-integer nor non-rational stoichiometry formulas</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoNonIntegerStoichiometryInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support non-integer 'stoichiometry' attribute values</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoUnitMultipliersOrOffsetsInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support multipliers or offsets in unit definitions</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{SpeciesCompartmentRequiredInL1, SBMLErrorCode_t}</td>
<td class="meaning">In SBML Level 1, a value for 'compartment' is mandatory in species definitions</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoSpeciesSpatialSizeUnitsInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support species 'spatialSizeUnits' settings</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoSBOTermsInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support the 'sboTerm' attribute</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{StrictUnitsRequiredInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 requires strict unit consistency</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{ConversionFactorNotInL1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support the 'conversionFactor' attribute</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompartmentNotOnL1Reaction, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 1 does not support the 'compartment' attribute on Reaction objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{ExtentUnitsNotSubstance, SBMLErrorCode_t}</td>
<td class="meaning">Units of extent must be compatible with units of substance</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{GlobalUnitsNotDeclared, SBMLErrorCode_t}</td>
<td class="meaning">Global units must be refer to unit kind or unitDefinition.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{HasOnlySubstanceUnitsNotinL1, SBMLErrorCode_t}</td>
<td class="meaning">The concept of hasOnlySubstanceUnits was not available in SBML Level 1.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AvogadroNotSupported, SBMLErrorCode_t}</td>
<td class="meaning">Avogadro not supported in Levels 2 and 1.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoConstraintsInL2v1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 1 does not support Constraint objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoInitialAssignmentsInL2v1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 1 does not support InitialAssignment objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoSpeciesTypeInL2v1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 1 does not support SpeciesType objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoCompartmentTypeInL2v1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 1 does not support CompartmentType objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoSBOTermsInL2v1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 1 does not support the 'sboTerm' attribute</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoIdOnSpeciesReferenceInL2v1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 1 does not support the 'id' attribute on SpeciesReference objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoDelayedEventAssignmentInL2v1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 1 does not support the 'useValuesFromTriggerTime' attribute</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{StrictUnitsRequiredInL2v1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 1 requires strict unit consistency</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{IntegerSpatialDimensions, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 1 requires that compartments have spatial dimensions of 0-3</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{StoichiometryMathNotYetSupported, SBMLErrorCode_t}</td>
<td class="meaning">Conversion to StoichiometryMath objects not yet supported</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{PriorityLostFromL3, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 1 does not support priorities on Event objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NonPersistentNotSupported, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 1 does not support the 'persistent' attribute on Trigger objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InitialValueFalseEventNotSupported, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 1 does not support the 'initialValue' attribute on Trigger objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{SBOTermNotUniversalInL2v2, SBMLErrorCode_t}</td>
<td class="meaning">The 'sboTerm' attribute is invalid for this component in SBML Level 2 Version 2</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoUnitOffsetInL2v2, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'offset' attribute on Unit objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoKineticLawTimeUnitsInL2v2, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'timeUnits' attribute on KineticLaw objects</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoKineticLawSubstanceUnitsInL2v2, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'substanceUnits' attribute on KineticLaw objects</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoDelayedEventAssignmentInL2v2, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'useValuesFromTriggerTime' attribute</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{ModelSBOBranchChangedBeyondL2v2, SBMLErrorCode_t}</td>
<td class="meaning">The allowable 'sboTerm' attribute values for Model objects differ for this SBML Level+Version</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{StrictUnitsRequiredInL2v2, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 2 requires strict unit consistency</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{StrictSBORequiredInL2v2, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 2 requires strict SBO term consistency</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{DuplicateAnnotationInvalidInL2v2, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate top-level annotations are invalid in SBML Level 2 Version 2</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoUnitOffsetInL2v3, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'offset' attribute on Unit objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoKineticLawTimeUnitsInL2v3, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'timeUnits' attribute on KineticLaw objects</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoKineticLawSubstanceUnitsInL2v3, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'substanceUnits' attribute on KineticLaw objects</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoSpeciesSpatialSizeUnitsInL2v3, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'spatialSizeUnit' attribute on Species objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoEventTimeUnitsInL2v3, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'timeUnits' attribute on Event objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoDelayedEventAssignmentInL2v3, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'useValuesFromTriggerTime' attribute</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{ModelSBOBranchChangedBeyondL2v3, SBMLErrorCode_t}</td>
<td class="meaning">The allowable 'sboTerm' attribute values for Model objects differ for this SBML Level+Version</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{StrictUnitsRequiredInL2v3, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 3 requires strict unit consistency</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{StrictSBORequiredInL2v3, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 2 Version 3 requires strict SBO term consistency</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{DuplicateAnnotationInvalidInL2v3, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate top-level annotations are invalid in SBML Level 2 Version 3</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoUnitOffsetInL2v4, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'offset' attribute on Unit objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoKineticLawTimeUnitsInL2v4, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'timeUnits' attribute on KineticLaw objects</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoKineticLawSubstanceUnitsInL2v4, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'substanceUnits' attribute on KineticLaw objects</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoSpeciesSpatialSizeUnitsInL2v4, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'spatialSizeUnit' attribute on Species objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoEventTimeUnitsInL2v4, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'timeUnits' attribute on Event objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{ModelSBOBranchChangedInL2v4, SBMLErrorCode_t}</td>
<td class="meaning">The allowable 'sboTerm' attribute values for Model objects differ for this SBML Level+Version</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{DuplicateAnnotationInvalidInL2v4, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate top-level annotations are invalid in SBML Level 2 Version 4</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoSpeciesTypeInL3v1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 3 Version 1 does not support SpeciesType objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoCompartmentTypeInL3v1, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 3 Version 1 does not support CompartmentType objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoUnitOffsetInL3v1, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'offset' attribute on Unit objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoKineticLawTimeUnitsInL3v1, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'timeUnits' attribute on KineticLaw objects</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoKineticLawSubstanceUnitsInL3v1, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'substanceUnits' attribute on KineticLaw objects</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoSpeciesSpatialSizeUnitsInL3v1, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'spatialSizeUnit' attribute on Species objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoEventTimeUnitsInL3v1, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'timeUnits' attribute on Event objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{ModelSBOBranchChangedInL3v1, SBMLErrorCode_t}</td>
<td class="meaning">The allowable 'sboTerm' attribute values for Model objects differ for this SBML Level+Version</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{DuplicateAnnotationInvalidInL3v1, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate top-level annotations are invalid in SBML Level 3 Version 1</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoCompartmentOutsideInL3v1, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'outside' attribute on Compartment objects</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoStoichiometryMathInL3v1, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the StoichiometryMath object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidSBMLLevelVersion, SBMLErrorCode_t}</td>
<td class="meaning">Unknown Level+Version combination of SBML</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{AnnotationNotesNotAllowedLevel1, SBMLErrorCode_t}</td>
<td class="meaning">Annotation objects on the SBML container element are not permitted in SBML Level 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidRuleOrdering, SBMLErrorCode_t}</td>
<td class="meaning">Invalid ordering of rules</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{RequiredPackagePresent, SBMLErrorCode_t}</td>
<td class="meaning">The SBML document requires an SBML Level 3 package unavailable in this software</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{UnrequiredPackagePresent, SBMLErrorCode_t}</td>
<td class="meaning">The SBML document uses an SBML Level 3 package unavailable in this software</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{PackageRequiredShouldBeFalse, SBMLErrorCode_t}</td>
<td class="meaning">This package expects required to be false</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{SubsUnitsAllowedInKL, SBMLErrorCode_t}</td>
<td class="meaning">Disallowed value for attribute 'substanceUnits' on KineticLaw object</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{TimeUnitsAllowedInKL, SBMLErrorCode_t}</td>
<td class="meaning">Disallowed value for attribute 'timeUnits' on KineticLaw object</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{FormulaInLevel1KL, SBMLErrorCode_t}</td>
<td class="meaning">Only predefined functions are allowed in SBML Level 1 formulas</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{L3SubstanceUnitsOnModel, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'substanceUnits' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{TimeUnitsRemoved, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'timeUnits' attribute on Event objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadMathML, SBMLErrorCode_t}</td>
<td class="meaning">Invalid MathML expression</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FailedMathMLReadOfDouble, SBMLErrorCode_t}</td>
<td class="meaning">Missing or invalid floating-point number in MathML expression</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FailedMathMLReadOfInteger, SBMLErrorCode_t}</td>
<td class="meaning">Missing or invalid integer in MathML expression</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FailedMathMLReadOfExponential, SBMLErrorCode_t}</td>
<td class="meaning">Missing or invalid exponential expression in MathML</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FailedMathMLReadOfRational, SBMLErrorCode_t}</td>
<td class="meaning">Missing or invalid rational expression in MathML</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{BadMathMLNodeType, SBMLErrorCode_t}</td>
<td class="meaning">Invalid MathML element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidMathMLAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Invalid MathML attribute</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoTimeSymbolInFunctionDef, SBMLErrorCode_t}</td>
<td class="meaning">Use of <code>&lt;csymbol&gt;</code> for 'time' not allowed within FunctionDefinition objects</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{NoBodyInFunctionDef, SBMLErrorCode_t}</td>
<td class="meaning">There must be a <code>&lt;lambda&gt;</code> body within the <code>&lt;math&gt;</code> element of a FunctionDefinition object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{DanglingUnitSIdRef, SBMLErrorCode_t}</td>
<td class="meaning">Units must refer to valid unit or unitDefinition</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{RDFMissingAboutTag, SBMLErrorCode_t}</td>
<td class="meaning">RDF missing the <code>&lt;about&gt;</code> tag</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{RDFEmptyAboutTag, SBMLErrorCode_t}</td>
<td class="meaning">RDF empty <code>&lt;about&gt;</code> tag</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{RDFAboutTagNotMetaid, SBMLErrorCode_t}</td>
<td class="meaning">RDF <code>&lt;about&gt;</code> tag is not metaid</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{RDFNotCompleteModelHistory, SBMLErrorCode_t}</td>
<td class="meaning">RDF does not contain valid ModelHistory</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{RDFNotModelHistory, SBMLErrorCode_t}</td>
<td class="meaning">RDF does not result in a ModelHistory</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{AnnotationNotElement, SBMLErrorCode_t}</td>
<td class="meaning">Annotation must contain element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{UndeclaredUnits, SBMLErrorCode_t}</td>
<td class="meaning">Missing unit declarations on parameters or literal numbers in expression</td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{UndeclaredTimeUnitsL3, SBMLErrorCode_t}</td>
<td class="meaning">Unable to verify consistency of units: the unit of time has not been declared</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{UndeclaredExtentUnitsL3, SBMLErrorCode_t}</td>
<td class="meaning">Unable to verify consistency of units: the units of reaction extent have not been declared</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{UndeclaredObjectUnitsL3, SBMLErrorCode_t}</td>
<td class="meaning">Unable to verify consistency of units: encountered a model entity with no declared units</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{UnrecognisedSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Unrecognized 'sboTerm' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{ObseleteSBOTerm, SBMLErrorCode_t}</td>
<td class="meaning">Obsolete 'sboTerm' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{IncorrectCompartmentSpatialDimensions, SBMLErrorCode_t}</td>
<td class="meaning">In SBML Level 1, only three-dimensional compartments are allowed</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompartmentTypeNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">CompartmentType objects are not available in this Level+Version of SBML</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{ConstantNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">This Level+Version of SBML does not support the 'constant' attribute on this component</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{MetaIdNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'metaid' is not available in SBML Level 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{SBOTermNotValidAttributeBeforeL2V3, SBMLErrorCode_t}</td>
<td class="meaning">The 'sboTerm' attribute is not available on this component before SBML Level 2 Version 3</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidL1CompartmentUnits, SBMLErrorCode_t}</td>
<td class="meaning">Invalid units for a compartment in SBML Level 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{L1V1CompartmentVolumeReqd, SBMLErrorCode_t}</td>
<td class="meaning">In SBML Level 1, a compartment's volume must be specified</td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompartmentTypeNotValidComponent, SBMLErrorCode_t}</td>
<td class="meaning">CompartmentType objects are not available in this Level+Version of SBML</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{ConstraintNotValidComponent, SBMLErrorCode_t}</td>
<td class="meaning">Constraint objects are not available in this Level+Version of SBML</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{EventNotValidComponent, SBMLErrorCode_t}</td>
<td class="meaning">Event objects are not available in this Level+Version of SBML</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{SBOTermNotValidAttributeBeforeL2V2, SBMLErrorCode_t}</td>
<td class="meaning">The 'sboTerm' attribute is invalid for this component before Level 2 Version 2</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{FuncDefNotValidComponent, SBMLErrorCode_t}</td>
<td class="meaning">FunctionDefinition objects are not available in this Level+Version of SBML</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{InitialAssignNotValidComponent, SBMLErrorCode_t}</td>
<td class="meaning">InitialAssignment objects are not available in this Level+Version of SBML</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{VariableNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'variable' is not available on this component in this Level+Version of SBML</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{UnitsNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'units' is not available on this component in this Level+Version of SBML</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{ConstantSpeciesNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'constant' is not available on Species objects in SBML Level 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{SpatialSizeUnitsNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'spatialSizeUnits' is not available on Species objects in SBML Level 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{SpeciesTypeNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'speciesType' is not available on Species objects in SBML Level 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{HasOnlySubsUnitsNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'hasOnlySubstanceUnits' is not available on Species objects in SBML Level 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{IdNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'id' is not available on SpeciesReference objects in SBML Level 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{NameNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'name' is not available on SpeciesReference objects in SBML Level 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{SpeciesTypeNotValidComponent, SBMLErrorCode_t}</td>
<td class="meaning">The SpeciesType object is not supported in SBML Level 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{StoichiometryMathNotValidComponent, SBMLErrorCode_t}</td>
<td class="meaning">The StoichiometryMath object is not supported in SBML Level 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{MultiplierNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'multiplier' on Unit objects is not supported in SBML Level 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{OffsetNotValidAttribute, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'offset' on Unit objects is only available in SBML Level 2 Version 1</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{L3SpatialDimensionsUnset, SBMLErrorCode_t}</td>
<td class="meaning">No value given for 'spatialDimensions' attribute; assuming a value of 3</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{PackageConversionNotSupported, SBMLErrorCode_t}</td>
<td class="meaning">Conversion of SBML Level 3 package constructs is not yet supported</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{InvalidTargetLevelVersion, SBMLErrorCode_t}</td>
<td class="meaning">The requested SBML Level/Version combination is not known to exist</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{L3NotSupported, SBMLErrorCode_t}</td>
<td class="meaning">SBML Level 3 is not yet supported</td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompUnknown, SBMLErrorCode_t}</td>
<td class="meaning"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompNSUndeclared, SBMLErrorCode_t}</td>
<td class="meaning">The comp ns is not correctly declared</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompElementNotInNs, SBMLErrorCode_t}</td>
<td class="meaning">Element not in comp namespace</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompDuplicateComponentId, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate 'id' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompUniqueModelIds, SBMLErrorCode_t}</td>
<td class="meaning">Model and ExternalModelDefinitions must have unique ids</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompUniquePortIds, SBMLErrorCode_t}</td>
<td class="meaning">Ports must have unique ids</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidSIdSyntax, SBMLErrorCode_t}</td>
<td class="meaning">Invalid SId syntax</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidSubmodelRefSyntax, SBMLErrorCode_t}</td>
<td class="meaning">Invalid submodelRef syntax</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidDeletionSyntax, SBMLErrorCode_t}</td>
<td class="meaning">Invalid deletion syntax</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidConversionFactorSyntax, SBMLErrorCode_t}</td>
<td class="meaning">Invalid conversionFactor syntax</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidNameSyntax, SBMLErrorCode_t}</td>
<td class="meaning">Invalid name syntax</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedUnitsShouldMatch, SBMLErrorCode_t}</td>
<td class="meaning">Units of replaced elements should match replacement units.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompOneListOfReplacedElements, SBMLErrorCode_t}</td>
<td class="meaning">Only one <code>&lt;listOfReplacedElements&gt;</code> allowed.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLOReplaceElementsAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed children of <code>&lt;listOfReplacedElements&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLOReplacedElementsAllowedAttribs, SBMLErrorCode_t}</td>
<td class="meaning">Allowed <code>&lt;listOfReplacedElements&gt;</code> attributes</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompEmptyLOReplacedElements, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;listOfReplacedElements&gt;</code> must not be empty</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompOneReplacedByElement, SBMLErrorCode_t}</td>
<td class="meaning">Only one <code>&lt;replacedBy&gt;</code> object allowed.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompAttributeRequiredMissing, SBMLErrorCode_t}</td>
<td class="meaning">Required comp:required attribute on <code>&lt;sbml&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompAttributeRequiredMustBeBoolean, SBMLErrorCode_t}</td>
<td class="meaning">The comp:required attribute must be Boolean</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompRequiredTrueIfElementsRemain, SBMLErrorCode_t}</td>
<td class="meaning">The comp:required attribute must be 'true' if math changes</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompRequiredFalseIfAllElementsReplaced, SBMLErrorCode_t}</td>
<td class="meaning">The comp:required attribute must be 'false' if math does not change</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompOneListOfModelDefinitions, SBMLErrorCode_t}</td>
<td class="meaning">Only one <code>&lt;listOfModelDefinitions&gt;</code> allowed.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompEmptyLOModelDefs, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;listOfModelDefinitions&gt;</code> and <code>&lt;listOfExternalModelDefinitions&gt;</code> must not be empty</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLOModelDefsAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Only <code>&lt;modelDefinitions&gt;</code> in <code>&lt;listOfModelDefinitions&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLOExtModelDefsAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Only <code>&lt;externalModelDefinitions&gt;</code> in <code>&lt;listOfExternalModelDefinitions&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLOModelDefsAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed <code>&lt;listOfModelDefinitions&gt;</code> attributes</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLOExtModDefsAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed <code>&lt;listOfExternalModelDefinitions&gt;</code> attributes</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompOneListOfExtModelDefinitions, SBMLErrorCode_t}</td>
<td class="meaning">Only one <code>&lt;listOfExternalModelDefinitions&gt;</code> allowed.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompAttributeRequiredMustBeTrue, SBMLErrorCode_t}</td>
<td class="meaning">The comp:required attribute must be 'true'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompExtModDefAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed <code>&lt;externalModelDefinitions&gt;</code> core attributes</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompExtModDefAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed <code>&lt;externalModelDefinitions&gt;</code> elements</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompExtModDefAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed <code>&lt;externalModelDefinitions&gt;</code> attributes</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReferenceMustBeL3, SBMLErrorCode_t}</td>
<td class="meaning">External models must be L3</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompModReferenceMustIdOfModel, SBMLErrorCode_t}</td>
<td class="meaning">'modelRef' must be the 'id' of a model in the 'source' document</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompExtModMd5DoesNotMatch, SBMLErrorCode_t}</td>
<td class="meaning">MD5 checksum does not match the 'source' document</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidSourceSyntax, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:source' attribute must be of type 'anyURI'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidModelRefSyntax, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:modelRef' attribute must have the syntax of 'SId'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidMD5Syntax, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:md5' attribute must have the syntax of 'string'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompCircularExternalModelReference, SBMLErrorCode_t}</td>
<td class="meaning">Circular reference in <code>&lt;externalModelDefinition&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompOneListOfOnModel, SBMLErrorCode_t}</td>
<td class="meaning">Only one <code>&lt;listOfSubmodels&gt;</code> and one <code>&lt;listOfPorts&gt;</code> allowed</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompNoEmptyListOfOnModel, SBMLErrorCode_t}</td>
<td class="meaning">No empty listOf elements allowed</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLOSubmodelsAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed elements on <code>&lt;listOfSubmodels&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLOPortsAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed elements on <code>&lt;listOfPorts&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLOSubmodelsAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on <code>&lt;listOfSubmodels&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLOPortsAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on <code>&lt;listOfPorts&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompSubmodelAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed core attributes on <code>&lt;submodel&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompSubmodelAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed elements on <code>&lt;submodel&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompOneListOfDeletionOnSubmodel, SBMLErrorCode_t}</td>
<td class="meaning">Only one <code>&lt;listOfDeletions&gt;</code> on a <code>&lt;submodel&gt;</code> allowed</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompSubmodelNoEmptyLODeletions, SBMLErrorCode_t}</td>
<td class="meaning">No empty listOfDeletions elements allowed</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLODeletionsAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed elements on <code>&lt;listOfDeletions&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLODeletionAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed <code>&lt;listOfDeletions&gt;</code> attributes</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompSubmodelAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed <code>&lt;submodel&gt;</code> attributes</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompModReferenceSyntax, SBMLErrorCode_t}</td>
<td class="meaning">'comp:modelRef' must conform to SId syntax</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidTimeConvFactorSyntax, SBMLErrorCode_t}</td>
<td class="meaning">'comp:timeConversionFactor' must conform to SId syntax</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidExtentConvFactorSyntax, SBMLErrorCode_t}</td>
<td class="meaning">'comp:extentConversionFactor' must conform to SId syntax</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompSubmodelMustReferenceModel, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:modelRef' attribute must reference a model</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompSubmodelCannotReferenceSelf, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:modelRef' attribute cannot reference own model</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompModCannotCircularlyReferenceSelf, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;model&gt;</code> may not reference <code>&lt;submodel&gt;</code> that references itself.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompTimeConversionMustBeParameter, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:timeConversionFactor' must reference a parameter</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompExtentConversionMustBeParameter, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:extentConversionFactor' must reference a parameter</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompPortRefMustReferencePort, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:portRef' attribute must be the 'id' of a <code>&lt;port&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompIdRefMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:idRef' attribute must be the 'id' of a model element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompUnitRefMustReferenceUnitDef, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:unitRef' attribute must be the 'id' of a UnitDefinition</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompMetaIdRefMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:metaIdRef' attribute must be the 'metaid' of an object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompParentOfSBRefChildMustBeSubmodel, SBMLErrorCode_t}</td>
<td class="meaning">If <code>&lt;sBaseRef&gt;</code> has a child <code>&lt;sBaseRef&gt;</code> its parent must be a <code>&lt;submodel&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidPortRefSyntax, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:portRef' attribute must have the syntax of an SBML SId</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidIdRefSyntax, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:idRef' attribute must have the syntax of an SBML SId</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidUnitRefSyntax, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:unitRef' attribute must have the syntax of an SBML SId</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompInvalidMetaIdRefSyntax, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:metaIdRef' attribute must have the syntax of an XML ID</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompOneSBaseRefOnly, SBMLErrorCode_t}</td>
<td class="meaning">Only one <code>&lt;sbaseRef&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompDeprecatedSBaseRefSpelling, SBMLErrorCode_t}</td>
<td class="meaning">The spelling 'sbaseRef' is deprecated</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompSBaseRefMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">An SBaseRef must reference an object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompSBaseRefMustReferenceOnlyOneObject, SBMLErrorCode_t}</td>
<td class="meaning">An SBaseRef must reference only one other object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompNoMultipleReferences, SBMLErrorCode_t}</td>
<td class="meaning">Objects may not be referenced by mutiple SBaseRef constructs.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompPortMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">Port must reference an object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompPortMustReferenceOnlyOneObject, SBMLErrorCode_t}</td>
<td class="meaning">Port must reference only one other object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompPortAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on a Port</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompPortReferencesUnique, SBMLErrorCode_t}</td>
<td class="meaning">Port definitions must be unique.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompDeletionMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">Deletion must reference an object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompDeletionMustReferOnlyOneObject, SBMLErrorCode_t}</td>
<td class="meaning">Deletion must reference only one other object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompDeletionAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on a Deletion</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedElementMustRefObject, SBMLErrorCode_t}</td>
<td class="meaning">ReplacedElement must reference an object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedElementMustRefOnlyOne, SBMLErrorCode_t}</td>
<td class="meaning">ReplacedElement must reference only one other object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedElementAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on <code>&lt;replacedElement&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedElementSubModelRef, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:submodelRef' attribute must point to a <code>&lt;submodel&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedElementDeletionRef, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:deletion' attribute must point to a <code>&lt;deletion&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedElementConvFactorRef, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:conversionFactor attribute must point to a <code>&lt;parameter&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedElementSameReference, SBMLErrorCode_t}</td>
<td class="meaning">No <code>&lt;replacedElement&gt;</code> refer to same object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedElementNoDelAndConvFact, SBMLErrorCode_t}</td>
<td class="meaning">No <code>&lt;replacedElement&gt;</code> with deletion and conversionfactor</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedByMustRefObject, SBMLErrorCode_t}</td>
<td class="meaning">ReplacedBy must reference an object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedByMustRefOnlyOne, SBMLErrorCode_t}</td>
<td class="meaning">ReplacedBy must reference only one other object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedByAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on <code>&lt;replacedBy&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompReplacedBySubModelRef, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:submodelRef' attribute must point to a <code>&lt;submodel&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompMustReplaceSameClass, SBMLErrorCode_t}</td>
<td class="meaning">Replaced classes must match.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompMustReplaceIDs, SBMLErrorCode_t}</td>
<td class="meaning">Replaced IDs must be replaced with IDs.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompMustReplaceMetaIDs, SBMLErrorCode_t}</td>
<td class="meaning">Replaced metaids must be replaced with metaids.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompMustReplacePackageIDs, SBMLErrorCode_t}</td>
<td class="meaning">Replaced package IDs must be replaced with package IDs.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompUnresolvedReference, SBMLErrorCode_t}</td>
<td class="meaning">Unresolved reference.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompNoModelInReference, SBMLErrorCode_t}</td>
<td class="meaning">No model in referenced document.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompExtModDefBad, SBMLErrorCode_t}</td>
<td class="meaning">Referenced <code>&lt;externalModelDefinition&gt;</code> unresolvable.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompModelFlatteningFailed, SBMLErrorCode_t}</td>
<td class="meaning">Model failed to flatten.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompFlatModelNotValid, SBMLErrorCode_t}</td>
<td class="meaning">Flat model not valid.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompLineNumbersUnreliable, SBMLErrorCode_t}</td>
<td class="meaning">Line numbers unreliable.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompFlatteningNotRecognisedReqd, SBMLErrorCode_t}</td>
<td class="meaning">Flattening not implemented for required package.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompFlatteningNotRecognisedNotReqd, SBMLErrorCode_t}</td>
<td class="meaning">Flattening not implemented for unrequired package.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompFlatteningNotImplementedNotReqd, SBMLErrorCode_t}</td>
<td class="meaning">Flattening not implemented for unrequired package.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompFlatteningNotImplementedReqd, SBMLErrorCode_t}</td>
<td class="meaning">Flattening not implemented for required package.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompFlatteningWarning, SBMLErrorCode_t}</td>
<td class="meaning">Flattening reference may come from package.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompDeprecatedDeleteFunction, SBMLErrorCode_t}</td>
<td class="meaning">The performDeletions functions is deprecated.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompDeprecatedReplaceFunction, SBMLErrorCode_t}</td>
<td class="meaning">The performReplacementsAndConversions fuctions is deprecated.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompDeletedReplacement, SBMLErrorCode_t}</td>
<td class="meaning">Element deleted before a subelement could be replaced.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompIdRefMayReferenceUnknownPackage, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:idRef' attribute must be the 'id' of a model element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{CompMetaIdRefMayReferenceUnknownPkg, SBMLErrorCode_t}</td>
<td class="meaning">The 'comp:metaIdRef' attribute must be the 'metaid' of a model element</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcUnknown, SBMLErrorCode_t}</td>
<td class="meaning"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcNSUndeclared, SBMLErrorCode_t}</td>
<td class="meaning">The fbc ns is not correctly declared</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcElementNotInNs, SBMLErrorCode_t}</td>
<td class="meaning">Element not in fbc namespace</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcDuplicateComponentId, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate 'id' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcSBMLSIdSyntax, SBMLErrorCode_t}</td>
<td class="meaning">Invalid 'id' attribute</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcAttributeRequiredMissing, SBMLErrorCode_t}</td>
<td class="meaning">Required fbc:required attribute on <code>&lt;sbml&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcAttributeRequiredMustBeBoolean, SBMLErrorCode_t}</td>
<td class="meaning">The fbc:required attribute must be Boolean</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcRequiredFalse, SBMLErrorCode_t}</td>
<td class="meaning">The fbc:required attribute must be 'false'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcOnlyOneEachListOf, SBMLErrorCode_t}</td>
<td class="meaning">One of each list of allowed</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcNoEmptyListOfs, SBMLErrorCode_t}</td>
<td class="meaning">ListOf elements cannot be empty</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcLOFluxBoundsAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed elements on ListOfFluxBounds</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcLOObjectivesAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed elements on ListOfObjectives</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcLOFluxBoundsAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on ListOfFluxBounds</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcLOObjectivesAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on ListOfObjectives</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcActiveObjectiveSyntax, SBMLErrorCode_t}</td>
<td class="meaning">Type of activeObjective attribute</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcActiveObjectiveRefersObjective, SBMLErrorCode_t}</td>
<td class="meaning">ActiveObjective must reference Objective</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcSpeciesAllowedL3Attributes, SBMLErrorCode_t}</td>
<td class="meaning">Species allowed attributes</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcSpeciesChargeMustBeInteger, SBMLErrorCode_t}</td>
<td class="meaning">Charge must be integer</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcSpeciesFormulaMustBeString, SBMLErrorCode_t}</td>
<td class="meaning">Chemical formula must be string</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxBoundAllowedL3Attributes, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;fluxBound&gt;</code> may only have 'metaId' and 'sboTerm' from L3 namespace</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxBoundAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;fluxBound&gt;</code> may only have <code>&lt;notes&gt;</code> and <code>&lt;annotations&gt;</code> from L3 Core</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxBoundRequiredAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on <code>&lt;fluxBound&gt;</code> object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxBoundRectionMustBeSIdRef, SBMLErrorCode_t}</td>
<td class="meaning">Datatype for 'fbc:reaction' must be SIdRef</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxBoundNameMustBeString, SBMLErrorCode_t}</td>
<td class="meaning">The attribute 'fbc:name' must be of the data type string</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxBoundOperationMustBeEnum, SBMLErrorCode_t}</td>
<td class="meaning">The attribute 'fbc:operation' must be of data type FbcOperation</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxBoundValueMustBeDouble, SBMLErrorCode_t}</td>
<td class="meaning">The attribute 'fbc:value' must be of the data type double</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxBoundReactionMustExist, SBMLErrorCode_t}</td>
<td class="meaning">'fbc:reaction' must refer to valid reaction</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxBoundsForReactionConflict, SBMLErrorCode_t}</td>
<td class="meaning">Conflicting set of FluxBounds for a reaction</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcObjectiveAllowedL3Attributes, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;objective&gt;</code> may only have 'metaId' and 'sboTerm' from L3 namespace</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcObjectiveAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;objective&gt;</code> may only have <code>&lt;notes&gt;</code> and <code>&lt;annotations&gt;</code> from L3 Core</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcObjectiveRequiredAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on <code>&lt;objective&gt;</code> object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcObjectiveNameMustBeString, SBMLErrorCode_t}</td>
<td class="meaning">The attribute 'fbc:name' must be of the data type string</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcObjectiveTypeMustBeEnum, SBMLErrorCode_t}</td>
<td class="meaning">The attribute 'fbc:type' must be of data type FbcType.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcObjectiveOneListOfObjectives, SBMLErrorCode_t}</td>
<td class="meaning">An <code>&lt;objective&gt;</code> must have one <code>&lt;listOfFluxObjectives&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcObjectiveLOFluxObjMustNotBeEmpty, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;listOfFluxObjectives&gt;</code> subobject must not be empty</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcObjectiveLOFluxObjOnlyFluxObj, SBMLErrorCode_t}</td>
<td class="meaning">Invalid element found in <code>&lt;listOfFluxObjectives&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcObjectiveLOFluxObjAllowedAttribs, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;listOfFluxObjectives&gt;</code> may only have 'metaId' and 'sboTerm' from L3 core</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxObjectAllowedL3Attributes, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;fluxObjective&gt;</code> may only have 'metaId' and 'sboTerm' from L3 namespace</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxObjectAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;fluxObjective&gt;</code> may only have <code>&lt;notes&gt;</code> and <code>&lt;annotations&gt;</code> from L3 Core</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxObjectRequiredAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Invalid attribute found on <code>&lt;fluxObjective&gt;</code> object</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxObjectNameMustBeString, SBMLErrorCode_t}</td>
<td class="meaning">The attribute 'fbc:name' must be of the data type string</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxObjectReactionMustBeSIdRef, SBMLErrorCode_t}</td>
<td class="meaning">Datatype for 'fbc:reaction' must be SIdRef</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxObjectReactionMustExist, SBMLErrorCode_t}</td>
<td class="meaning">'fbc:reaction' must refer to valid reaction</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{FbcFluxObjectCoefficientMustBeDouble, SBMLErrorCode_t}</td>
<td class="meaning">The attribute 'fbc:coefficient' must be of the data type double</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualUnknown, SBMLErrorCode_t}</td>
<td class="meaning"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualNSUndeclared, SBMLErrorCode_t}</td>
<td class="meaning">The qual ns is not correctly declared</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualElementNotInNs, SBMLErrorCode_t}</td>
<td class="meaning">Element not in qual namespace</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualFunctionTermBool, SBMLErrorCode_t}</td>
<td class="meaning">FunctionTerm should return boolean</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualMathCSymbolDisallowed, SBMLErrorCode_t}</td>
<td class="meaning">CSymbol time or delay not allowed</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-warning"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualDuplicateComponentId, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate 'id' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualAttributeRequiredMissing, SBMLErrorCode_t}</td>
<td class="meaning">Required qual:required attribute on <code>&lt;sbml&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualAttributeRequiredMustBeBoolean, SBMLErrorCode_t}</td>
<td class="meaning">The qual:required attribute must be Boolean</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualRequiredTrueIfTransitions, SBMLErrorCode_t}</td>
<td class="meaning">The qual:required attribute must be 'true' if math changes</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualOneListOfTransOrQS, SBMLErrorCode_t}</td>
<td class="meaning">Only one <code>&lt;listOfTransitions&gt;</code> or <code>&lt;listOfQualitativeSpecies&gt;</code> allowed.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualEmptyLONotAllowed, SBMLErrorCode_t}</td>
<td class="meaning">Empty <code>&lt;listOfTransitions&gt;</code> or <code>&lt;listOfQualitativeSpecies&gt;</code> not allowed.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualLOTransitiondAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;listOfTransitions&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualLOQualSpeciesAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;listOfTransitions&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualLOQualSpeciesAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;listOfQualitativeSpecies&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualLOTransitionsAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;listOfTransitions&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualQualSpeciesAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;qualitativeSpecies&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualQualSpeciesAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;qualitativeSpecies&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualQualSpeciesAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;qualitativeSpecies&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualConstantMustBeBool, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'constant' on <code>&lt;qualitativeSpecies&gt;</code> must be boolean.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualNameMustBeString, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'name' on <code>&lt;qualitativeSpecies&gt;</code> must be string.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInitialLevelMustBeInt, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'initialLevel' on <code>&lt;qualitativeSpecies&gt;</code> must be integer.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualMaxLevelMustBeInt, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'maxLevel' on <code>&lt;qualitativeSpecies&gt;</code> must be integer.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualCompartmentMustReferExisting, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'compartment' on <code>&lt;qualitativeSpecies&gt;</code> must reference compartment.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInitialLevelCannotExceedMax, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'initialLevel' on <code>&lt;qualitativeSpecies&gt;</code> cannot exceed maxLevel.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualConstantQSCannotBeOutput, SBMLErrorCode_t}</td>
<td class="meaning">Constant <code>&lt;qualitativeSpecies&gt;</code> cannot be an Output.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualQSAssignedOnlyOnce, SBMLErrorCode_t}</td>
<td class="meaning">A <code>&lt;qualitativeSpecies&gt;</code> can only be assigned once.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInitalLevelNotNegative, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'initialLevel' on <code>&lt;qualitativeSpecies&gt;</code> cannot be negative.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualMaxLevelNotNegative, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'maxLevel' on <code>&lt;qualitativeSpecies&gt;</code> cannot be negative.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;transition&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;transition&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;transition&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionNameMustBeString, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'name' on <code>&lt;transition&gt;</code> must be string.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionLOElements, SBMLErrorCode_t}</td>
<td class="meaning">ListOf elements on <code>&lt;transition&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionEmptyLOElements, SBMLErrorCode_t}</td>
<td class="meaning">ListOf elements on <code>&lt;transition&gt;</code> not empty.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionLOInputElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements on <code>&lt;listOfInputs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionLOOutputElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements on <code>&lt;listOfOutputs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionLOFuncTermElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements on <code>&lt;listOfFunctionTerms&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionLOInputAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;listOfInputs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionLOOutputAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;listOfOutputs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionLOFuncTermAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;listOfFunctionTerms&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionLOFuncTermExceedMax, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;listOfFunctionTerms&gt;</code> cannot make qualitativeSpecies exceed maxLevel.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualTransitionLOFuncTermNegative, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;listOfFunctionTerms&gt;</code> cannot make qualitativeSpecies negative.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInputAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;input&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInputAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;input&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInputAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;input&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInputNameMustBeString, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'name' on <code>&lt;input&gt;</code> must be string.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInputSignMustBeSignEnum, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'sign' on <code>&lt;input&gt;</code> must be enum.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInputTransEffectMustBeInputEffect, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'transitionEffect' on <code>&lt;input&gt;</code> must be enum.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInputThreshMustBeInteger, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'thresholdLevel' on <code>&lt;input&gt;</code> must be non negative integer.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInputQSMustBeExistingQS, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'qualitativeSpecies' on <code>&lt;input&gt;</code> must refer to existing</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInputConstantCannotBeConsumed, SBMLErrorCode_t}</td>
<td class="meaning">Constant <code>&lt;input&gt;</code> cannot be consumed.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualInputThreshMustBeNonNegative, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'thresholdLevel' on <code>&lt;input&gt;</code> must be non negative integer.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualOutputAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;output&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualOutputAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;output&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualOutputAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;output&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualOutputNameMustBeString, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'name' on <code>&lt;output&gt;</code> must be string.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualOutputTransEffectMustBeOutput, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'transitionEffect' on <code>&lt;output&gt;</code> must be enum.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualOutputLevelMustBeInteger, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'outputLevel' on <code>&lt;output&gt;</code> must be non negative integer.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualOutputQSMustBeExistingQS, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'qualitativeSpecies' on <code>&lt;output&gt;</code> must refer to existing</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualOutputConstantMustBeFalse, SBMLErrorCode_t}</td>
<td class="meaning">Constant 'qualitativeSpecies' cannot be <code>&lt;output&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualOutputProductionMustHaveLevel, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;output&gt;</code> being produced must have level</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualOutputLevelMustBeNonNegative, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'outputLevel' on <code>&lt;output&gt;</code> must be non negative integer.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualDefaultTermAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;defaultTerm&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualDefaultTermAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;defaultTerm&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualDefaultTermAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;defaultTerm&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualDefaultTermResultMustBeInteger, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'resultLevel' on <code>&lt;defaultTerm&gt;</code> must be non negative integer.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualDefaultTermResultMustBeNonNeg, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'resultLevel' on <code>&lt;defaultTerm&gt;</code> must be non negative integer.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualFuncTermAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;functionTerm&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualFuncTermAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;functionTerm&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualFuncTermAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;functionTerm&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualFuncTermOnlyOneMath, SBMLErrorCode_t}</td>
<td class="meaning">Only one <code>&lt;math&gt;</code> on <code>&lt;functionTerm&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualFuncTermResultMustBeInteger, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'resultLevel' on <code>&lt;functionTerm&gt;</code> must be non negative integer.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{QualFuncTermResultMustBeNonNeg, SBMLErrorCode_t}</td>
<td class="meaning">Attribute 'resultLevel' on <code>&lt;functionTerm&gt;</code> must be non negative integer.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutUnknownError, SBMLErrorCode_t}</td>
<td class="meaning"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutNSUndeclared, SBMLErrorCode_t}</td>
<td class="meaning">The layout ns is not correctly declared</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutElementNotInNs, SBMLErrorCode_t}</td>
<td class="meaning">Element not in layout namespace</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutDuplicateComponentId, SBMLErrorCode_t}</td>
<td class="meaning">Duplicate 'id' attribute value</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSIdSyntax, SBMLErrorCode_t}</td>
<td class="meaning">'id' attribute incorrect syntax</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutXsiTypeAllowedLocations, SBMLErrorCode_t}</td>
<td class="meaning">'xsi:type' allowed locations</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutXsiTypeSyntax, SBMLErrorCode_t}</td>
<td class="meaning">'xsi:type' attribute incorrect syntax</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutAttributeRequiredMissing, SBMLErrorCode_t}</td>
<td class="meaning">Required layout:required attribute on <code>&lt;sbml&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutAttributeRequiredMustBeBoolean, SBMLErrorCode_t}</td>
<td class="meaning">The layout:required attribute must be Boolean</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutRequiredFalse, SBMLErrorCode_t}</td>
<td class="meaning">The layout:required attribute must be 'false'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutOnlyOneLOLayouts, SBMLErrorCode_t}</td>
<td class="meaning">Only one listOfLayouts on <code>&lt;model&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOLayoutsNotEmpty, SBMLErrorCode_t}</td>
<td class="meaning">ListOf elements cannot be empty</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOLayoutsAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed elements on ListOfLayouts</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOLayoutsAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on ListOfLayouts</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLayoutAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed elements on Layout</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLayoutAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed core attributes on Layout</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutOnlyOneEachListOf, SBMLErrorCode_t}</td>
<td class="meaning">Only one each listOf on <code>&lt;layout&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutNoEmptyListOfs, SBMLErrorCode_t}</td>
<td class="meaning">ListOf elements cannot be empty</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLayoutAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning"><code>&lt;layout&gt;</code> must have 'id' and may have 'name'</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLayoutNameMustBeString, SBMLErrorCode_t}</td>
<td class="meaning">'name' must be string</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOCompGlyphAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;listOfCompartmentGlyphs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOCompGlyphAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;listOfCompartmentGlyphs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOSpeciesGlyphAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;listOfSpeciesGlyphs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOSpeciesGlyphAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;listOfSpeciesGlyphs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLORnGlyphAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;listOfReactionGlyphs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLORnGlyphAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;listOfReactionGlyphs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOAddGOAllowedAttribut, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;listOfAdditionalGraphicalObjectGlyphs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOAddGOAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;listOfAdditionalGraphicalObjectGlyphs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLayoutMustHaveDimensions, SBMLErrorCode_t}</td>
<td class="meaning">Layout must have <code>&lt;dimensions&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOTextGlyphAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Attributes allowed on <code>&lt;listOfTextGlyphs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOTextGlyphAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Elements allowed on <code>&lt;listOfTextGlyphs&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGOAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;graphicalObject&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGOAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;graphicalObject&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGOAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Layout elements allowed on <code>&lt;graphicalObject&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGOAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;graphicalObject&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGOMetaIdRefMustBeIDREF, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must be IDREF.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGOMetaIdRefMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must reference existing object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGOMustContainBoundingBox, SBMLErrorCode_t}</td>
<td class="meaning">A <code>&lt;graphicalObject&gt;</code> must contain a <code>&lt;boundingBox&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCGAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;compartmentGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCGAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;compartmentGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCGAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Layout elements allowed on <code>&lt;compartmentGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCGAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;compartmentGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCGMetaIdRefMustBeIDREF, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must be IDREF.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCGMetaIdRefMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must reference existing object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCGCompartmentSyntax, SBMLErrorCode_t}</td>
<td class="meaning">CompartmentGlyph 'compartment' must have SIdRef syntax.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCGCompartmentMustRefComp, SBMLErrorCode_t}</td>
<td class="meaning">CompartmentGlyph compartment must reference existing compartment.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCGNoDuplicateReferences, SBMLErrorCode_t}</td>
<td class="meaning">CompartmentGlyph cannot reference two objects.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCGOrderMustBeDouble, SBMLErrorCode_t}</td>
<td class="meaning">CompartmentGlyph order must be double.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSGAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;speciesGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSGAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;speciesGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSGAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Layout elements allowed on <code>&lt;speciesGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSGAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;speciesGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSGMetaIdRefMustBeIDREF, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must be IDREF.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSGMetaIdRefMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must reference existing object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSGSpeciesSyntax, SBMLErrorCode_t}</td>
<td class="meaning">SpeciesGlyph 'species' must have SIdRef syntax.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSGSpeciesMustRefSpecies, SBMLErrorCode_t}</td>
<td class="meaning">SpeciesGlyph species must reference existing species.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSGNoDuplicateReferences, SBMLErrorCode_t}</td>
<td class="meaning">SpeciesGlyph cannot reference two objects.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutRGAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;reactionGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutRGAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;reactionGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutRGAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Layout elements allowed on <code>&lt;reactionGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutRGAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;reactionGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutRGMetaIdRefMustBeIDREF, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must be IDREF.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutRGMetaIdRefMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must reference existing object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutRGReactionSyntax, SBMLErrorCode_t}</td>
<td class="meaning">ReactionGlyph 'reaction' must have SIdRef syntax.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutRGReactionMustRefReaction, SBMLErrorCode_t}</td>
<td class="meaning">ReactionGlyph reaction must reference existing reaction.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutRGNoDuplicateReferences, SBMLErrorCode_t}</td>
<td class="meaning">ReactionGlyph cannot reference two objects.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOSpeciesRefGlyphAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed elements on ListOfSpeciesReferenceGlyphs</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOSpeciesRefGlyphAllowedAttribs, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on ListOfSpeciesReferenceGlyphs</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOSpeciesRefGlyphNotEmpty, SBMLErrorCode_t}</td>
<td class="meaning">ListOfSpeciesReferenceGlyphs not empty</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGGAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;generalGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGGAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;generalGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGGAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Layout elements allowed on <code>&lt;generalGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGGAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;generalGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGGMetaIdRefMustBeIDREF, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must be IDREF.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGGMetaIdRefMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must reference existing object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGGReferenceSyntax, SBMLErrorCode_t}</td>
<td class="meaning">GeneralGlyph 'reference' must have SIdRef syntax.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGGReferenceMustRefObject, SBMLErrorCode_t}</td>
<td class="meaning">GeneralGlyph 'reference' must reference existing element.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutGGNoDuplicateReferences, SBMLErrorCode_t}</td>
<td class="meaning">GeneralGlyph cannot reference two objects.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOReferenceGlyphAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed elements on ListOfReferenceGlyphs</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOReferenceGlyphAllowedAttribs, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on ListOfReferenceGlyphs</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOSubGlyphAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOSubGlyphAllowedAttribs, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on ListOfSubGlyphs</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutTGAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;textGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutTGAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;textGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutTGAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Layout elements allowed on <code>&lt;textGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutTGAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;textGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutTGMetaIdRefMustBeIDREF, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must be IDREF.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutTGMetaIdRefMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must reference existing object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutTGOriginOfTextSyntax, SBMLErrorCode_t}</td>
<td class="meaning">TextGlyph 'originOfText' must have SIdRef syntax.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutTGOriginOfTextMustRefObject, SBMLErrorCode_t}</td>
<td class="meaning">TextGlyph 'originOfText' must reference existing element.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutTGNoDuplicateReferences, SBMLErrorCode_t}</td>
<td class="meaning">TextGlyph cannot reference two objects.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutTGGraphicalObjectSyntax, SBMLErrorCode_t}</td>
<td class="meaning">TextGlyph 'graphicalObject' must have SIdRef syntax.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutTGGraphicalObjectMustRefObject, SBMLErrorCode_t}</td>
<td class="meaning">TextGlyph 'graphicalObject' must reference existing element.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutTGTextMustBeString, SBMLErrorCode_t}</td>
<td class="meaning">TextGlyph 'text' must be string.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSRGAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;speciesReferenceGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSRGAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;speciesReferenceGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSRGAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Layout elements allowed on <code>&lt;speciesReferenceGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSRGAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;speciesReferenceGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSRGMetaIdRefMustBeIDREF, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must be IDREF.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSRGMetaIdRefMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must reference existing object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSRGSpeciesReferenceSyntax, SBMLErrorCode_t}</td>
<td class="meaning">SpeciesReferenceGlyph 'speciesReference' must have SIdRef syntax.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSRGSpeciesRefMustRefObject, SBMLErrorCode_t}</td>
<td class="meaning">SpeciesReferenceGlyph 'speciesReference' must reference existing element.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSRGNoDuplicateReferences, SBMLErrorCode_t}</td>
<td class="meaning">SpeciesReferenceGlyph cannot reference two objects.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSRGSpeciesGlyphSyntax, SBMLErrorCode_t}</td>
<td class="meaning">SpeciesReferenceGlyph 'speciesGlyph' must have SIdRef syntax.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSRGSpeciesGlyphMustRefObject, SBMLErrorCode_t}</td>
<td class="meaning">SpeciesReferenceGlyph 'speciesGlyph' must reference existing element.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutSRGRoleSyntax, SBMLErrorCode_t}</td>
<td class="meaning">SpeciesReferenceGlyph 'role' must be string from enumeration.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutREFGAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;referenceGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutREFGAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;referenceGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutREFGAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Layout elements allowed on <code>&lt;referenceGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutREFGAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;referenceGlyph&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutREFGMetaIdRefMustBeIDREF, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must be IDREF.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutREFGMetaIdRefMustReferenceObject, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'metIdRef' must reference existing object.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutREFGReferenceSyntax, SBMLErrorCode_t}</td>
<td class="meaning">ReferenceGlyph 'reference' must have SIdRef syntax.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutREFGReferenceMustRefObject, SBMLErrorCode_t}</td>
<td class="meaning">ReferenceGlyph 'reference' must reference existing element.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutREFGNoDuplicateReferences, SBMLErrorCode_t}</td>
<td class="meaning">ReferenceGlyph cannot reference two objects.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutREFGGlyphSyntax, SBMLErrorCode_t}</td>
<td class="meaning">ReferenceGlyph 'glyph' must have SIdRef syntax.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutREFGGlyphMustRefObject, SBMLErrorCode_t}</td>
<td class="meaning">ReferenceGlyph 'glyph' must reference existing element.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutREFGRoleSyntax, SBMLErrorCode_t}</td>
<td class="meaning">ReferenceGlyph 'role' must be string.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutPointAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;point&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutPointAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;point&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutPointAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;point&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutPointAttributesMustBeDouble, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'x', 'y' and 'z' must be double.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutBBoxAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;boundingBox&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutBBoxAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;boundingBox&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutBBoxAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Layout elements allowed on <code>&lt;boundingBox&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutBBoxAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;boundingBox&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutBBoxConsistent3DDefinition, SBMLErrorCode_t}</td>
<td class="meaning">Layout consistent dimensions on a <code>&lt;boundingBox&gt;</code></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCurveAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;curve&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCurveAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;curve&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCurveAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Layout elements allowed on <code>&lt;curve&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCurveAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;curve&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOCurveSegsAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Allowed attributes on ListOfCurveSegments</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOCurveSegsAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Allowed elements on ListOfCurveSegments</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLOCurveSegsNotEmpty, SBMLErrorCode_t}</td>
<td class="meaning">No empty ListOfCurveSegments</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLSegAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;lineSegment&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLSegAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;lineSegment&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLSegAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Layout elements allowed on <code>&lt;lineSegment&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutLSegAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;lineSegment&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCBezAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;cubicBezier&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCBezAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;cubicBezier&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCBezAllowedElements, SBMLErrorCode_t}</td>
<td class="meaning">Layout elements allowed on <code>&lt;cubicBezier&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutCBezAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;cubicBezier&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutDimsAllowedCoreElements, SBMLErrorCode_t}</td>
<td class="meaning">Core elements allowed on <code>&lt;dimensions&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutDimsAllowedCoreAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Core attributes allowed on <code>&lt;dimensions&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutDimsAllowedAttributes, SBMLErrorCode_t}</td>
<td class="meaning">Layout attributes allowed on <code>&lt;dimensions&gt;</code>.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
<tr><td class="code">@sbmlconstant{LayoutDimsAttributesMustBeDouble, SBMLErrorCode_t}</td>
<td class="meaning">Layout 'width', 'height' and 'depth' must be double.</td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-na"></td>
<td class="s-error"></td>
</tr>
</table>

*/
