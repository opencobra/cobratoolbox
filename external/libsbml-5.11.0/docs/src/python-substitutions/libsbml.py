def endl(*args):
    """
    endl(ostream s) -> ostream

    Insert a newline character into the given C++ stream @p s.

    This is a wrapper around the underlying C++ OStream method
    <code>endl</code>.  It inserts a newline into the stream
    passed as argument.  Additionally, it flushes buffered
    streams.

    @param s the stream to which the newline should be written.

    @return the stream @p s.
    """

def flush(*args):
    """
    flush(ostream s) -> ostream

    Flush the given C++ stream @p s.

    This is a wrapper around the underlying C++ OStream method
    <code>flush</code>.  It flush any pending output in the stream 
    passed as argument.

    @param s the stream to be flushed.

    @return the stream @p s.
    """

XMLUnknownError = _libsbml.XMLUnknownError
    ## @var long XMLUnknownError
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLOutOfMemory = _libsbml.XMLOutOfMemory
    ## @var long XMLOutOfMemory
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLFileUnreadable = _libsbml.XMLFileUnreadable
    ## @var long XMLFileUnreadable
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLFileUnwritable = _libsbml.XMLFileUnwritable
    ## @var long XMLFileUnwritable
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLFileOperationError = _libsbml.XMLFileOperationError
    ## @var long XMLFileOperationError
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLNetworkAccessError = _libsbml.XMLNetworkAccessError
    ## @var long XMLNetworkAccessError
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

InternalXMLParserError = _libsbml.InternalXMLParserError
    ## @var long InternalXMLParserError
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

UnrecognizedXMLParserCode = _libsbml.UnrecognizedXMLParserCode
    ## @var long UnrecognizedXMLParserCode
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLTranscoderError = _libsbml.XMLTranscoderError
    ## @var long XMLTranscoderError
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

MissingXMLDecl = _libsbml.MissingXMLDecl
    ## @var long MissingXMLDecl
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

MissingXMLEncoding = _libsbml.MissingXMLEncoding
    ## @var long MissingXMLEncoding
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadXMLDecl = _libsbml.BadXMLDecl
    ## @var long BadXMLDecl
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadXMLDOCTYPE = _libsbml.BadXMLDOCTYPE
    ## @var long BadXMLDOCTYPE
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

InvalidCharInXML = _libsbml.InvalidCharInXML
    ## @var long InvalidCharInXML
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadlyFormedXML = _libsbml.BadlyFormedXML
    ## @var long BadlyFormedXML
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

UnclosedXMLToken = _libsbml.UnclosedXMLToken
    ## @var long UnclosedXMLToken
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

InvalidXMLConstruct = _libsbml.InvalidXMLConstruct
    ## @var long InvalidXMLConstruct
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLTagMismatch = _libsbml.XMLTagMismatch
    ## @var long XMLTagMismatch
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

DuplicateXMLAttribute = _libsbml.DuplicateXMLAttribute
    ## @var long DuplicateXMLAttribute
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

UndefinedXMLEntity = _libsbml.UndefinedXMLEntity
    ## @var long UndefinedXMLEntity
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadProcessingInstruction = _libsbml.BadProcessingInstruction
    ## @var long BadProcessingInstruction
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadXMLPrefix = _libsbml.BadXMLPrefix
    ## @var long BadXMLPrefix
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadXMLPrefixValue = _libsbml.BadXMLPrefixValue
    ## @var long BadXMLPrefixValue
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

MissingXMLRequiredAttribute = _libsbml.MissingXMLRequiredAttribute
    ## @var long MissingXMLRequiredAttribute
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLAttributeTypeMismatch = _libsbml.XMLAttributeTypeMismatch
    ## @var long XMLAttributeTypeMismatch
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLBadUTF8Content = _libsbml.XMLBadUTF8Content
    ## @var long XMLBadUTF8Content
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

MissingXMLAttributeValue = _libsbml.MissingXMLAttributeValue
    ## @var long MissingXMLAttributeValue
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadXMLAttributeValue = _libsbml.BadXMLAttributeValue
    ## @var long BadXMLAttributeValue
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadXMLAttribute = _libsbml.BadXMLAttribute
    ## @var long BadXMLAttribute
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

UnrecognizedXMLElement = _libsbml.UnrecognizedXMLElement
    ## @var long UnrecognizedXMLElement
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadXMLComment = _libsbml.BadXMLComment
    ## @var long BadXMLComment
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadXMLDeclLocation = _libsbml.BadXMLDeclLocation
    ## @var long BadXMLDeclLocation
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLUnexpectedEOF = _libsbml.XMLUnexpectedEOF
    ## @var long XMLUnexpectedEOF
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadXMLIDValue = _libsbml.BadXMLIDValue
    ## @var long BadXMLIDValue
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadXMLIDRef = _libsbml.BadXMLIDRef
    ## @var long BadXMLIDRef
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

UninterpretableXMLContent = _libsbml.UninterpretableXMLContent
    ## @var long UninterpretableXMLContent
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

BadXMLDocumentStructure = _libsbml.BadXMLDocumentStructure
    ## @var long BadXMLDocumentStructure
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

InvalidAfterXMLContent = _libsbml.InvalidAfterXMLContent
    ## @var long InvalidAfterXMLContent
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLExpectedQuotedString = _libsbml.XMLExpectedQuotedString
    ## @var long XMLExpectedQuotedString
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLEmptyValueNotPermitted = _libsbml.XMLEmptyValueNotPermitted
    ## @var long XMLEmptyValueNotPermitted
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLBadNumber = _libsbml.XMLBadNumber
    ## @var long XMLBadNumber
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLBadColon = _libsbml.XMLBadColon
    ## @var long XMLBadColon
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

MissingXMLElements = _libsbml.MissingXMLElements
    ## @var long MissingXMLElements
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLContentEmpty = _libsbml.XMLContentEmpty
    ## @var long XMLContentEmpty
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

XMLErrorCodesUpperBound = _libsbml.XMLErrorCodesUpperBound
    ## @var long XMLErrorCodesUpperBound
    ##
    ## A value in the enumeration of all the error and warning codes returned
    ## by the XML layer in libSBML.  Please consult the documentation for
    ## XMLError for an explanation of the meaning of this particular error
    ## code.

LIBSBML_CAT_INTERNAL = _libsbml.LIBSBML_CAT_INTERNAL
    ## @var long LIBSBML_CAT_INTERNAL
    ## @brief Category code for errors in the XML layer.
    ## 
    ## This code has the following meaning: A problem involving the libSBML
    ## software itself or the underlying XML parser.  This almost certainly
    ## indicates a software defect (i.e., bug) in libSBML.  Please report
    ## instances of this to the libSBML developers.

LIBSBML_CAT_SYSTEM = _libsbml.LIBSBML_CAT_SYSTEM
    ## @var long LIBSBML_CAT_SYSTEM
    ## @brief Category code for errors in the XML layer.
    ##
    ## This code has the following meaning: A problem reported by the
    ## operating system, such as an inability to read or write a file.
    ## This indicates something that is not a program error but is outside
    ## of the control of libSBML.

LIBSBML_CAT_XML = _libsbml.LIBSBML_CAT_XML
    ## @var long LIBSBML_CAT_XML
    ## @brief Category code for errors in the XML layer.
    ##
    ## This code has the following meaning: A problem in the XML content
    ## itself.  This usually arises from malformed XML or the use of
    ## constructs not permitted in SBML.

LIBSBML_CAT_SBML = _libsbml.LIBSBML_CAT_SBML
    ## @var long LIBSBML_CAT_SBML
    ## @brief Category code for errors in the XML layer.
    ##
    ## This code has the following meaning: General SBML error not falling
    ## into another category below.

LIBSBML_SEV_INFO = _libsbml.LIBSBML_SEV_INFO
    ## @var long LIBSBML_SEV_INFO
    ## @brief Severity code for errors in the XML layer.
    ##
    ## This code has the following meaning: The error is actually
    ## informational and not necessarily a serious problem.

LIBSBML_SEV_WARNING = _libsbml.LIBSBML_SEV_WARNING
    ## @var long LIBSBML_SEV_WARNING
    ## @brief Severity code for errors in the XML layer.
    ##
    ## This code has the following meaning: The error object represents a
    ## problem that is not serious enough to necessarily stop the problem,
    ## but applications should take note of the problem and evaluate what
    ## its implications may be.

LIBSBML_SEV_ERROR = _libsbml.LIBSBML_SEV_ERROR
    ## @var long LIBSBML_SEV_ERROR
    ## @brief Severity code for errors in the XML layer.
    ##
    ## This code has the following meaning: The error object represents a
    ## serious error.  The application may continue running but it is
    ## unlikely to be able to continue processing the same XML file or data
    ## stream. 

LIBSBML_SEV_FATAL = _libsbml.LIBSBML_SEV_FATAL
    ## @var long LIBSBML_SEV_FATAL
    ## @brief Severity code for errors in the XML layer.
    ##
    ## This code has the following meaning: A serious error occurred, such
    ## as an out-of-memory condition, and the software should terminate
    ## immediately.

UnknownError = _libsbml.UnknownError
    ## @var long UnknownError
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NotUTF8 = _libsbml.NotUTF8
    ## @var long NotUTF8
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UnrecognizedElement = _libsbml.UnrecognizedElement
    ## @var long UnrecognizedElement
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NotSchemaConformant = _libsbml.NotSchemaConformant
    ## @var long NotSchemaConformant
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

L3NotSchemaConformant = _libsbml.L3NotSchemaConformant
    ## @var long L3NotSchemaConformant
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidMathElement = _libsbml.InvalidMathElement
    ## @var long InvalidMathElement
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DisallowedMathMLSymbol = _libsbml.DisallowedMathMLSymbol
    ## @var long DisallowedMathMLSymbol
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DisallowedMathMLEncodingUse = _libsbml.DisallowedMathMLEncodingUse
    ## @var long DisallowedMathMLEncodingUse
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DisallowedDefinitionURLUse = _libsbml.DisallowedDefinitionURLUse
    ## @var long DisallowedDefinitionURLUse
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

BadCsymbolDefinitionURLValue = _libsbml.BadCsymbolDefinitionURLValue
    ## @var long BadCsymbolDefinitionURLValue
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DisallowedMathTypeAttributeUse = _libsbml.DisallowedMathTypeAttributeUse
    ## @var long DisallowedMathTypeAttributeUse
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DisallowedMathTypeAttributeValue = _libsbml.DisallowedMathTypeAttributeValue
    ## @var long DisallowedMathTypeAttributeValue
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

LambdaOnlyAllowedInFunctionDef = _libsbml.LambdaOnlyAllowedInFunctionDef
    ## @var long LambdaOnlyAllowedInFunctionDef
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

BooleanOpsNeedBooleanArgs = _libsbml.BooleanOpsNeedBooleanArgs
    ## @var long BooleanOpsNeedBooleanArgs
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NumericOpsNeedNumericArgs = _libsbml.NumericOpsNeedNumericArgs
    ## @var long NumericOpsNeedNumericArgs
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ArgsToEqNeedSameType = _libsbml.ArgsToEqNeedSameType
    ## @var long ArgsToEqNeedSameType
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

PiecewiseNeedsConsistentTypes = _libsbml.PiecewiseNeedsConsistentTypes
    ## @var long PiecewiseNeedsConsistentTypes
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

PieceNeedsBoolean = _libsbml.PieceNeedsBoolean
    ## @var long PieceNeedsBoolean
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ApplyCiMustBeUserFunction = _libsbml.ApplyCiMustBeUserFunction
    ## @var long ApplyCiMustBeUserFunction
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ApplyCiMustBeModelComponent = _libsbml.ApplyCiMustBeModelComponent
    ## @var long ApplyCiMustBeModelComponent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

KineticLawParametersAreLocalOnly = _libsbml.KineticLawParametersAreLocalOnly
    ## @var long KineticLawParametersAreLocalOnly
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MathResultMustBeNumeric = _libsbml.MathResultMustBeNumeric
    ## @var long MathResultMustBeNumeric
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OpsNeedCorrectNumberOfArgs = _libsbml.OpsNeedCorrectNumberOfArgs
    ## @var long OpsNeedCorrectNumberOfArgs
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidNoArgsPassedToFunctionDef = _libsbml.InvalidNoArgsPassedToFunctionDef
    ## @var long InvalidNoArgsPassedToFunctionDef
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DisallowedMathUnitsUse = _libsbml.DisallowedMathUnitsUse
    ## @var long DisallowedMathUnitsUse
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidUnitsValue = _libsbml.InvalidUnitsValue
    ## @var long InvalidUnitsValue
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DuplicateComponentId = _libsbml.DuplicateComponentId
    ## @var long DuplicateComponentId
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DuplicateUnitDefinitionId = _libsbml.DuplicateUnitDefinitionId
    ## @var long DuplicateUnitDefinitionId
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DuplicateLocalParameterId = _libsbml.DuplicateLocalParameterId
    ## @var long DuplicateLocalParameterId
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MultipleAssignmentOrRateRules = _libsbml.MultipleAssignmentOrRateRules
    ## @var long MultipleAssignmentOrRateRules
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MultipleEventAssignmentsForId = _libsbml.MultipleEventAssignmentsForId
    ## @var long MultipleEventAssignmentsForId
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

EventAndAssignmentRuleForId = _libsbml.EventAndAssignmentRuleForId
    ## @var long EventAndAssignmentRuleForId
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DuplicateMetaId = _libsbml.DuplicateMetaId
    ## @var long DuplicateMetaId
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidSBOTermSyntax = _libsbml.InvalidSBOTermSyntax
    ## @var long InvalidSBOTermSyntax
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidMetaidSyntax = _libsbml.InvalidMetaidSyntax
    ## @var long InvalidMetaidSyntax
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidIdSyntax = _libsbml.InvalidIdSyntax
    ## @var long InvalidIdSyntax
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidUnitIdSyntax = _libsbml.InvalidUnitIdSyntax
    ## @var long InvalidUnitIdSyntax
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidNameSyntax = _libsbml.InvalidNameSyntax
    ## @var long InvalidNameSyntax
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MissingAnnotationNamespace = _libsbml.MissingAnnotationNamespace
    ## @var long MissingAnnotationNamespace
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DuplicateAnnotationNamespaces = _libsbml.DuplicateAnnotationNamespaces
    ## @var long DuplicateAnnotationNamespaces
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SBMLNamespaceInAnnotation = _libsbml.SBMLNamespaceInAnnotation
    ## @var long SBMLNamespaceInAnnotation
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MultipleAnnotations = _libsbml.MultipleAnnotations
    ## @var long MultipleAnnotations
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InconsistentArgUnits = _libsbml.InconsistentArgUnits
    ## @var long InconsistentArgUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InconsistentKineticLawUnitsL3 = _libsbml.InconsistentKineticLawUnitsL3
    ## @var long InconsistentKineticLawUnitsL3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AssignRuleCompartmentMismatch = _libsbml.AssignRuleCompartmentMismatch
    ## @var long AssignRuleCompartmentMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AssignRuleSpeciesMismatch = _libsbml.AssignRuleSpeciesMismatch
    ## @var long AssignRuleSpeciesMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AssignRuleParameterMismatch = _libsbml.AssignRuleParameterMismatch
    ## @var long AssignRuleParameterMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AssignRuleStoichiometryMismatch = _libsbml.AssignRuleStoichiometryMismatch
    ## @var long AssignRuleStoichiometryMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InitAssignCompartmenMismatch = _libsbml.InitAssignCompartmenMismatch
    ## @var long InitAssignCompartmenMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InitAssignSpeciesMismatch = _libsbml.InitAssignSpeciesMismatch
    ## @var long InitAssignSpeciesMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InitAssignParameterMismatch = _libsbml.InitAssignParameterMismatch
    ## @var long InitAssignParameterMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InitAssignStoichiometryMismatch = _libsbml.InitAssignStoichiometryMismatch
    ## @var long InitAssignStoichiometryMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

RateRuleCompartmentMismatch = _libsbml.RateRuleCompartmentMismatch
    ## @var long RateRuleCompartmentMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

RateRuleSpeciesMismatch = _libsbml.RateRuleSpeciesMismatch
    ## @var long RateRuleSpeciesMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

RateRuleParameterMismatch = _libsbml.RateRuleParameterMismatch
    ## @var long RateRuleParameterMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

RateRuleStoichiometryMismatch = _libsbml.RateRuleStoichiometryMismatch
    ## @var long RateRuleStoichiometryMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

KineticLawNotSubstancePerTime = _libsbml.KineticLawNotSubstancePerTime
    ## @var long KineticLawNotSubstancePerTime
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SpeciesInvalidExtentUnits = _libsbml.SpeciesInvalidExtentUnits
    ## @var long SpeciesInvalidExtentUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DelayUnitsNotTime = _libsbml.DelayUnitsNotTime
    ## @var long DelayUnitsNotTime
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

EventAssignCompartmentMismatch = _libsbml.EventAssignCompartmentMismatch
    ## @var long EventAssignCompartmentMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

EventAssignSpeciesMismatch = _libsbml.EventAssignSpeciesMismatch
    ## @var long EventAssignSpeciesMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

EventAssignParameterMismatch = _libsbml.EventAssignParameterMismatch
    ## @var long EventAssignParameterMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

EventAssignStoichiometryMismatch = _libsbml.EventAssignStoichiometryMismatch
    ## @var long EventAssignStoichiometryMismatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

PriorityUnitsNotDimensionless = _libsbml.PriorityUnitsNotDimensionless
    ## @var long PriorityUnitsNotDimensionless
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UpperUnitBound = _libsbml.UpperUnitBound
    ## @var long UpperUnitBound
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OverdeterminedSystem = _libsbml.OverdeterminedSystem
    ## @var long OverdeterminedSystem
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidModelSBOTerm = _libsbml.InvalidModelSBOTerm
    ## @var long InvalidModelSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidFunctionDefSBOTerm = _libsbml.InvalidFunctionDefSBOTerm
    ## @var long InvalidFunctionDefSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidParameterSBOTerm = _libsbml.InvalidParameterSBOTerm
    ## @var long InvalidParameterSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidInitAssignSBOTerm = _libsbml.InvalidInitAssignSBOTerm
    ## @var long InvalidInitAssignSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidRuleSBOTerm = _libsbml.InvalidRuleSBOTerm
    ## @var long InvalidRuleSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidConstraintSBOTerm = _libsbml.InvalidConstraintSBOTerm
    ## @var long InvalidConstraintSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidReactionSBOTerm = _libsbml.InvalidReactionSBOTerm
    ## @var long InvalidReactionSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidSpeciesReferenceSBOTerm = _libsbml.InvalidSpeciesReferenceSBOTerm
    ## @var long InvalidSpeciesReferenceSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidKineticLawSBOTerm = _libsbml.InvalidKineticLawSBOTerm
    ## @var long InvalidKineticLawSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidEventSBOTerm = _libsbml.InvalidEventSBOTerm
    ## @var long InvalidEventSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidEventAssignmentSBOTerm = _libsbml.InvalidEventAssignmentSBOTerm
    ## @var long InvalidEventAssignmentSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidCompartmentSBOTerm = _libsbml.InvalidCompartmentSBOTerm
    ## @var long InvalidCompartmentSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidSpeciesSBOTerm = _libsbml.InvalidSpeciesSBOTerm
    ## @var long InvalidSpeciesSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidCompartmentTypeSBOTerm = _libsbml.InvalidCompartmentTypeSBOTerm
    ## @var long InvalidCompartmentTypeSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidSpeciesTypeSBOTerm = _libsbml.InvalidSpeciesTypeSBOTerm
    ## @var long InvalidSpeciesTypeSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidTriggerSBOTerm = _libsbml.InvalidTriggerSBOTerm
    ## @var long InvalidTriggerSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidDelaySBOTerm = _libsbml.InvalidDelaySBOTerm
    ## @var long InvalidDelaySBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NotesNotInXHTMLNamespace = _libsbml.NotesNotInXHTMLNamespace
    ## @var long NotesNotInXHTMLNamespace
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NotesContainsXMLDecl = _libsbml.NotesContainsXMLDecl
    ## @var long NotesContainsXMLDecl
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NotesContainsDOCTYPE = _libsbml.NotesContainsDOCTYPE
    ## @var long NotesContainsDOCTYPE
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidNotesContent = _libsbml.InvalidNotesContent
    ## @var long InvalidNotesContent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyOneNotesElementAllowed = _libsbml.OnlyOneNotesElementAllowed
    ## @var long OnlyOneNotesElementAllowed
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidNamespaceOnSBML = _libsbml.InvalidNamespaceOnSBML
    ## @var long InvalidNamespaceOnSBML
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MissingOrInconsistentLevel = _libsbml.MissingOrInconsistentLevel
    ## @var long MissingOrInconsistentLevel
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MissingOrInconsistentVersion = _libsbml.MissingOrInconsistentVersion
    ## @var long MissingOrInconsistentVersion
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

PackageNSMustMatch = _libsbml.PackageNSMustMatch
    ## @var long PackageNSMustMatch
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

LevelPositiveInteger = _libsbml.LevelPositiveInteger
    ## @var long LevelPositiveInteger
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

VersionPositiveInteger = _libsbml.VersionPositiveInteger
    ## @var long VersionPositiveInteger
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnSBML = _libsbml.AllowedAttributesOnSBML
    ## @var long AllowedAttributesOnSBML
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MissingModel = _libsbml.MissingModel
    ## @var long MissingModel
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

IncorrectOrderInModel = _libsbml.IncorrectOrderInModel
    ## @var long IncorrectOrderInModel
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

EmptyListElement = _libsbml.EmptyListElement
    ## @var long EmptyListElement
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NeedCompartmentIfHaveSpecies = _libsbml.NeedCompartmentIfHaveSpecies
    ## @var long NeedCompartmentIfHaveSpecies
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneOfEachListOf = _libsbml.OneOfEachListOf
    ## @var long OneOfEachListOf
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyFuncDefsInListOfFuncDefs = _libsbml.OnlyFuncDefsInListOfFuncDefs
    ## @var long OnlyFuncDefsInListOfFuncDefs
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyUnitDefsInListOfUnitDefs = _libsbml.OnlyUnitDefsInListOfUnitDefs
    ## @var long OnlyUnitDefsInListOfUnitDefs
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyCompartmentsInListOfCompartments = _libsbml.OnlyCompartmentsInListOfCompartments
    ## @var long OnlyCompartmentsInListOfCompartments
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlySpeciesInListOfSpecies = _libsbml.OnlySpeciesInListOfSpecies
    ## @var long OnlySpeciesInListOfSpecies
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyParametersInListOfParameters = _libsbml.OnlyParametersInListOfParameters
    ## @var long OnlyParametersInListOfParameters
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyInitAssignsInListOfInitAssigns = _libsbml.OnlyInitAssignsInListOfInitAssigns
    ## @var long OnlyInitAssignsInListOfInitAssigns
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyRulesInListOfRules = _libsbml.OnlyRulesInListOfRules
    ## @var long OnlyRulesInListOfRules
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyConstraintsInListOfConstraints = _libsbml.OnlyConstraintsInListOfConstraints
    ## @var long OnlyConstraintsInListOfConstraints
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyReactionsInListOfReactions = _libsbml.OnlyReactionsInListOfReactions
    ## @var long OnlyReactionsInListOfReactions
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyEventsInListOfEvents = _libsbml.OnlyEventsInListOfEvents
    ## @var long OnlyEventsInListOfEvents
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

L3ConversionFactorOnModel = _libsbml.L3ConversionFactorOnModel
    ## @var long L3ConversionFactorOnModel
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

L3TimeUnitsOnModel = _libsbml.L3TimeUnitsOnModel
    ## @var long L3TimeUnitsOnModel
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

L3VolumeUnitsOnModel = _libsbml.L3VolumeUnitsOnModel
    ## @var long L3VolumeUnitsOnModel
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

L3AreaUnitsOnModel = _libsbml.L3AreaUnitsOnModel
    ## @var long L3AreaUnitsOnModel
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

L3LengthUnitsOnModel = _libsbml.L3LengthUnitsOnModel
    ## @var long L3LengthUnitsOnModel
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

L3ExtentUnitsOnModel = _libsbml.L3ExtentUnitsOnModel
    ## @var long L3ExtentUnitsOnModel
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnModel = _libsbml.AllowedAttributesOnModel
    ## @var long AllowedAttributesOnModel
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfFuncs = _libsbml.AllowedAttributesOnListOfFuncs
    ## @var long AllowedAttributesOnListOfFuncs
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfUnitDefs = _libsbml.AllowedAttributesOnListOfUnitDefs
    ## @var long AllowedAttributesOnListOfUnitDefs
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfComps = _libsbml.AllowedAttributesOnListOfComps
    ## @var long AllowedAttributesOnListOfComps
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfSpecies = _libsbml.AllowedAttributesOnListOfSpecies
    ## @var long AllowedAttributesOnListOfSpecies
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfParams = _libsbml.AllowedAttributesOnListOfParams
    ## @var long AllowedAttributesOnListOfParams
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfInitAssign = _libsbml.AllowedAttributesOnListOfInitAssign
    ## @var long AllowedAttributesOnListOfInitAssign
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfRules = _libsbml.AllowedAttributesOnListOfRules
    ## @var long AllowedAttributesOnListOfRules
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfConstraints = _libsbml.AllowedAttributesOnListOfConstraints
    ## @var long AllowedAttributesOnListOfConstraints
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfReactions = _libsbml.AllowedAttributesOnListOfReactions
    ## @var long AllowedAttributesOnListOfReactions
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfEvents = _libsbml.AllowedAttributesOnListOfEvents
    ## @var long AllowedAttributesOnListOfEvents
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

FunctionDefMathNotLambda = _libsbml.FunctionDefMathNotLambda
    ## @var long FunctionDefMathNotLambda
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidApplyCiInLambda = _libsbml.InvalidApplyCiInLambda
    ## @var long InvalidApplyCiInLambda
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

RecursiveFunctionDefinition = _libsbml.RecursiveFunctionDefinition
    ## @var long RecursiveFunctionDefinition
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidCiInLambda = _libsbml.InvalidCiInLambda
    ## @var long InvalidCiInLambda
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidFunctionDefReturnType = _libsbml.InvalidFunctionDefReturnType
    ## @var long InvalidFunctionDefReturnType
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneMathElementPerFunc = _libsbml.OneMathElementPerFunc
    ## @var long OneMathElementPerFunc
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnFunc = _libsbml.AllowedAttributesOnFunc
    ## @var long AllowedAttributesOnFunc
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidUnitDefId = _libsbml.InvalidUnitDefId
    ## @var long InvalidUnitDefId
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidSubstanceRedefinition = _libsbml.InvalidSubstanceRedefinition
    ## @var long InvalidSubstanceRedefinition
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidLengthRedefinition = _libsbml.InvalidLengthRedefinition
    ## @var long InvalidLengthRedefinition
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidAreaRedefinition = _libsbml.InvalidAreaRedefinition
    ## @var long InvalidAreaRedefinition
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidTimeRedefinition = _libsbml.InvalidTimeRedefinition
    ## @var long InvalidTimeRedefinition
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidVolumeRedefinition = _libsbml.InvalidVolumeRedefinition
    ## @var long InvalidVolumeRedefinition
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

VolumeLitreDefExponentNotOne = _libsbml.VolumeLitreDefExponentNotOne
    ## @var long VolumeLitreDefExponentNotOne
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

VolumeMetreDefExponentNot3 = _libsbml.VolumeMetreDefExponentNot3
    ## @var long VolumeMetreDefExponentNot3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

EmptyListOfUnits = _libsbml.EmptyListOfUnits
    ## @var long EmptyListOfUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidUnitKind = _libsbml.InvalidUnitKind
    ## @var long InvalidUnitKind
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OffsetNoLongerValid = _libsbml.OffsetNoLongerValid
    ## @var long OffsetNoLongerValid
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

CelsiusNoLongerValid = _libsbml.CelsiusNoLongerValid
    ## @var long CelsiusNoLongerValid
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

EmptyUnitListElement = _libsbml.EmptyUnitListElement
    ## @var long EmptyUnitListElement
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneListOfUnitsPerUnitDef = _libsbml.OneListOfUnitsPerUnitDef
    ## @var long OneListOfUnitsPerUnitDef
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyUnitsInListOfUnits = _libsbml.OnlyUnitsInListOfUnits
    ## @var long OnlyUnitsInListOfUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnUnitDefinition = _libsbml.AllowedAttributesOnUnitDefinition
    ## @var long AllowedAttributesOnUnitDefinition
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfUnits = _libsbml.AllowedAttributesOnListOfUnits
    ## @var long AllowedAttributesOnListOfUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnUnit = _libsbml.AllowedAttributesOnUnit
    ## @var long AllowedAttributesOnUnit
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ZeroDimensionalCompartmentSize = _libsbml.ZeroDimensionalCompartmentSize
    ## @var long ZeroDimensionalCompartmentSize
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ZeroDimensionalCompartmentUnits = _libsbml.ZeroDimensionalCompartmentUnits
    ## @var long ZeroDimensionalCompartmentUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ZeroDimensionalCompartmentConst = _libsbml.ZeroDimensionalCompartmentConst
    ## @var long ZeroDimensionalCompartmentConst
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UndefinedOutsideCompartment = _libsbml.UndefinedOutsideCompartment
    ## @var long UndefinedOutsideCompartment
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

RecursiveCompartmentContainment = _libsbml.RecursiveCompartmentContainment
    ## @var long RecursiveCompartmentContainment
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ZeroDCompartmentContainment = _libsbml.ZeroDCompartmentContainment
    ## @var long ZeroDCompartmentContainment
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

Invalid1DCompartmentUnits = _libsbml.Invalid1DCompartmentUnits
    ## @var long Invalid1DCompartmentUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

Invalid2DCompartmentUnits = _libsbml.Invalid2DCompartmentUnits
    ## @var long Invalid2DCompartmentUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

Invalid3DCompartmentUnits = _libsbml.Invalid3DCompartmentUnits
    ## @var long Invalid3DCompartmentUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidCompartmentTypeRef = _libsbml.InvalidCompartmentTypeRef
    ## @var long InvalidCompartmentTypeRef
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneDimensionalCompartmentUnits = _libsbml.OneDimensionalCompartmentUnits
    ## @var long OneDimensionalCompartmentUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

TwoDimensionalCompartmentUnits = _libsbml.TwoDimensionalCompartmentUnits
    ## @var long TwoDimensionalCompartmentUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ThreeDimensionalCompartmentUnits = _libsbml.ThreeDimensionalCompartmentUnits
    ## @var long ThreeDimensionalCompartmentUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnCompartment = _libsbml.AllowedAttributesOnCompartment
    ## @var long AllowedAttributesOnCompartment
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoUnitsOnCompartment = _libsbml.NoUnitsOnCompartment
    ## @var long NoUnitsOnCompartment
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidSpeciesCompartmentRef = _libsbml.InvalidSpeciesCompartmentRef
    ## @var long InvalidSpeciesCompartmentRef
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

HasOnlySubsNoSpatialUnits = _libsbml.HasOnlySubsNoSpatialUnits
    ## @var long HasOnlySubsNoSpatialUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoSpatialUnitsInZeroD = _libsbml.NoSpatialUnitsInZeroD
    ## @var long NoSpatialUnitsInZeroD
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoConcentrationInZeroD = _libsbml.NoConcentrationInZeroD
    ## @var long NoConcentrationInZeroD
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SpatialUnitsInOneD = _libsbml.SpatialUnitsInOneD
    ## @var long SpatialUnitsInOneD
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SpatialUnitsInTwoD = _libsbml.SpatialUnitsInTwoD
    ## @var long SpatialUnitsInTwoD
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SpatialUnitsInThreeD = _libsbml.SpatialUnitsInThreeD
    ## @var long SpatialUnitsInThreeD
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidSpeciesSusbstanceUnits = _libsbml.InvalidSpeciesSusbstanceUnits
    ## @var long InvalidSpeciesSusbstanceUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

BothAmountAndConcentrationSet = _libsbml.BothAmountAndConcentrationSet
    ## @var long BothAmountAndConcentrationSet
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NonBoundarySpeciesAssignedAndUsed = _libsbml.NonBoundarySpeciesAssignedAndUsed
    ## @var long NonBoundarySpeciesAssignedAndUsed
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NonConstantSpeciesUsed = _libsbml.NonConstantSpeciesUsed
    ## @var long NonConstantSpeciesUsed
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidSpeciesTypeRef = _libsbml.InvalidSpeciesTypeRef
    ## @var long InvalidSpeciesTypeRef
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MultSpeciesSameTypeInCompartment = _libsbml.MultSpeciesSameTypeInCompartment
    ## @var long MultSpeciesSameTypeInCompartment
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MissingSpeciesCompartment = _libsbml.MissingSpeciesCompartment
    ## @var long MissingSpeciesCompartment
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SpatialSizeUnitsRemoved = _libsbml.SpatialSizeUnitsRemoved
    ## @var long SpatialSizeUnitsRemoved
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SubstanceUnitsOnSpecies = _libsbml.SubstanceUnitsOnSpecies
    ## @var long SubstanceUnitsOnSpecies
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ConversionFactorOnSpecies = _libsbml.ConversionFactorOnSpecies
    ## @var long ConversionFactorOnSpecies
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnSpecies = _libsbml.AllowedAttributesOnSpecies
    ## @var long AllowedAttributesOnSpecies
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidParameterUnits = _libsbml.InvalidParameterUnits
    ## @var long InvalidParameterUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ParameterUnits = _libsbml.ParameterUnits
    ## @var long ParameterUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ConversionFactorMustConstant = _libsbml.ConversionFactorMustConstant
    ## @var long ConversionFactorMustConstant
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnParameter = _libsbml.AllowedAttributesOnParameter
    ## @var long AllowedAttributesOnParameter
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidInitAssignSymbol = _libsbml.InvalidInitAssignSymbol
    ## @var long InvalidInitAssignSymbol
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MultipleInitAssignments = _libsbml.MultipleInitAssignments
    ## @var long MultipleInitAssignments
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InitAssignmentAndRuleForSameId = _libsbml.InitAssignmentAndRuleForSameId
    ## @var long InitAssignmentAndRuleForSameId
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneMathElementPerInitialAssign = _libsbml.OneMathElementPerInitialAssign
    ## @var long OneMathElementPerInitialAssign
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnInitialAssign = _libsbml.AllowedAttributesOnInitialAssign
    ## @var long AllowedAttributesOnInitialAssign
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidAssignRuleVariable = _libsbml.InvalidAssignRuleVariable
    ## @var long InvalidAssignRuleVariable
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidRateRuleVariable = _libsbml.InvalidRateRuleVariable
    ## @var long InvalidRateRuleVariable
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AssignmentToConstantEntity = _libsbml.AssignmentToConstantEntity
    ## @var long AssignmentToConstantEntity
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

RateRuleForConstantEntity = _libsbml.RateRuleForConstantEntity
    ## @var long RateRuleForConstantEntity
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

RepeatedRule10304 = _libsbml.RepeatedRule10304
    ## @var long RepeatedRule10304
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

CircularRuleDependency = _libsbml.CircularRuleDependency
    ## @var long CircularRuleDependency
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneMathElementPerRule = _libsbml.OneMathElementPerRule
    ## @var long OneMathElementPerRule
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnAssignRule = _libsbml.AllowedAttributesOnAssignRule
    ## @var long AllowedAttributesOnAssignRule
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnRateRule = _libsbml.AllowedAttributesOnRateRule
    ## @var long AllowedAttributesOnRateRule
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnAlgRule = _libsbml.AllowedAttributesOnAlgRule
    ## @var long AllowedAttributesOnAlgRule
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ConstraintMathNotBoolean = _libsbml.ConstraintMathNotBoolean
    ## @var long ConstraintMathNotBoolean
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

IncorrectOrderInConstraint = _libsbml.IncorrectOrderInConstraint
    ## @var long IncorrectOrderInConstraint
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ConstraintNotInXHTMLNamespace = _libsbml.ConstraintNotInXHTMLNamespace
    ## @var long ConstraintNotInXHTMLNamespace
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ConstraintContainsXMLDecl = _libsbml.ConstraintContainsXMLDecl
    ## @var long ConstraintContainsXMLDecl
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ConstraintContainsDOCTYPE = _libsbml.ConstraintContainsDOCTYPE
    ## @var long ConstraintContainsDOCTYPE
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidConstraintContent = _libsbml.InvalidConstraintContent
    ## @var long InvalidConstraintContent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneMathElementPerConstraint = _libsbml.OneMathElementPerConstraint
    ## @var long OneMathElementPerConstraint
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneMessageElementPerConstraint = _libsbml.OneMessageElementPerConstraint
    ## @var long OneMessageElementPerConstraint
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnConstraint = _libsbml.AllowedAttributesOnConstraint
    ## @var long AllowedAttributesOnConstraint
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoReactantsOrProducts = _libsbml.NoReactantsOrProducts
    ## @var long NoReactantsOrProducts
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

IncorrectOrderInReaction = _libsbml.IncorrectOrderInReaction
    ## @var long IncorrectOrderInReaction
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

EmptyListInReaction = _libsbml.EmptyListInReaction
    ## @var long EmptyListInReaction
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidReactantsProductsList = _libsbml.InvalidReactantsProductsList
    ## @var long InvalidReactantsProductsList
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidModifiersList = _libsbml.InvalidModifiersList
    ## @var long InvalidModifiersList
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneSubElementPerReaction = _libsbml.OneSubElementPerReaction
    ## @var long OneSubElementPerReaction
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

CompartmentOnReaction = _libsbml.CompartmentOnReaction
    ## @var long CompartmentOnReaction
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnReaction = _libsbml.AllowedAttributesOnReaction
    ## @var long AllowedAttributesOnReaction
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidSpeciesReference = _libsbml.InvalidSpeciesReference
    ## @var long InvalidSpeciesReference
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

RepeatedRule20611 = _libsbml.RepeatedRule20611
    ## @var long RepeatedRule20611
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

BothStoichiometryAndMath = _libsbml.BothStoichiometryAndMath
    ## @var long BothStoichiometryAndMath
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnSpeciesReference = _libsbml.AllowedAttributesOnSpeciesReference
    ## @var long AllowedAttributesOnSpeciesReference
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnModifier = _libsbml.AllowedAttributesOnModifier
    ## @var long AllowedAttributesOnModifier
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UndeclaredSpeciesRef = _libsbml.UndeclaredSpeciesRef
    ## @var long UndeclaredSpeciesRef
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

IncorrectOrderInKineticLaw = _libsbml.IncorrectOrderInKineticLaw
    ## @var long IncorrectOrderInKineticLaw
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

EmptyListInKineticLaw = _libsbml.EmptyListInKineticLaw
    ## @var long EmptyListInKineticLaw
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NonConstantLocalParameter = _libsbml.NonConstantLocalParameter
    ## @var long NonConstantLocalParameter
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SubsUnitsNoLongerValid = _libsbml.SubsUnitsNoLongerValid
    ## @var long SubsUnitsNoLongerValid
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

TimeUnitsNoLongerValid = _libsbml.TimeUnitsNoLongerValid
    ## @var long TimeUnitsNoLongerValid
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneListOfPerKineticLaw = _libsbml.OneListOfPerKineticLaw
    ## @var long OneListOfPerKineticLaw
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyLocalParamsInListOfLocalParams = _libsbml.OnlyLocalParamsInListOfLocalParams
    ## @var long OnlyLocalParamsInListOfLocalParams
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfLocalParam = _libsbml.AllowedAttributesOnListOfLocalParam
    ## @var long AllowedAttributesOnListOfLocalParam
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneMathPerKineticLaw = _libsbml.OneMathPerKineticLaw
    ## @var long OneMathPerKineticLaw
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UndeclaredSpeciesInStoichMath = _libsbml.UndeclaredSpeciesInStoichMath
    ## @var long UndeclaredSpeciesInStoichMath
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnKineticLaw = _libsbml.AllowedAttributesOnKineticLaw
    ## @var long AllowedAttributesOnKineticLaw
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfSpeciesRef = _libsbml.AllowedAttributesOnListOfSpeciesRef
    ## @var long AllowedAttributesOnListOfSpeciesRef
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfMods = _libsbml.AllowedAttributesOnListOfMods
    ## @var long AllowedAttributesOnListOfMods
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnLocalParameter = _libsbml.AllowedAttributesOnLocalParameter
    ## @var long AllowedAttributesOnLocalParameter
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MissingTriggerInEvent = _libsbml.MissingTriggerInEvent
    ## @var long MissingTriggerInEvent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

TriggerMathNotBoolean = _libsbml.TriggerMathNotBoolean
    ## @var long TriggerMathNotBoolean
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MissingEventAssignment = _libsbml.MissingEventAssignment
    ## @var long MissingEventAssignment
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

TimeUnitsEvent = _libsbml.TimeUnitsEvent
    ## @var long TimeUnitsEvent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

IncorrectOrderInEvent = _libsbml.IncorrectOrderInEvent
    ## @var long IncorrectOrderInEvent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ValuesFromTriggerTimeNeedDelay = _libsbml.ValuesFromTriggerTimeNeedDelay
    ## @var long ValuesFromTriggerTimeNeedDelay
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DelayNeedsValuesFromTriggerTime = _libsbml.DelayNeedsValuesFromTriggerTime
    ## @var long DelayNeedsValuesFromTriggerTime
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneMathPerTrigger = _libsbml.OneMathPerTrigger
    ## @var long OneMathPerTrigger
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneMathPerDelay = _libsbml.OneMathPerDelay
    ## @var long OneMathPerDelay
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidEventAssignmentVariable = _libsbml.InvalidEventAssignmentVariable
    ## @var long InvalidEventAssignmentVariable
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

EventAssignmentForConstantEntity = _libsbml.EventAssignmentForConstantEntity
    ## @var long EventAssignmentForConstantEntity
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneMathPerEventAssignment = _libsbml.OneMathPerEventAssignment
    ## @var long OneMathPerEventAssignment
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnEventAssignment = _libsbml.AllowedAttributesOnEventAssignment
    ## @var long AllowedAttributesOnEventAssignment
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyOneDelayPerEvent = _libsbml.OnlyOneDelayPerEvent
    ## @var long OnlyOneDelayPerEvent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneListOfEventAssignmentsPerEvent = _libsbml.OneListOfEventAssignmentsPerEvent
    ## @var long OneListOfEventAssignmentsPerEvent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyEventAssignInListOfEventAssign = _libsbml.OnlyEventAssignInListOfEventAssign
    ## @var long OnlyEventAssignInListOfEventAssign
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnListOfEventAssign = _libsbml.AllowedAttributesOnListOfEventAssign
    ## @var long AllowedAttributesOnListOfEventAssign
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnEvent = _libsbml.AllowedAttributesOnEvent
    ## @var long AllowedAttributesOnEvent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnTrigger = _libsbml.AllowedAttributesOnTrigger
    ## @var long AllowedAttributesOnTrigger
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnDelay = _libsbml.AllowedAttributesOnDelay
    ## @var long AllowedAttributesOnDelay
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

PersistentNotBoolean = _libsbml.PersistentNotBoolean
    ## @var long PersistentNotBoolean
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InitialValueNotBoolean = _libsbml.InitialValueNotBoolean
    ## @var long InitialValueNotBoolean
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OnlyOnePriorityPerEvent = _libsbml.OnlyOnePriorityPerEvent
    ## @var long OnlyOnePriorityPerEvent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OneMathPerPriority = _libsbml.OneMathPerPriority
    ## @var long OneMathPerPriority
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AllowedAttributesOnPriority = _libsbml.AllowedAttributesOnPriority
    ## @var long AllowedAttributesOnPriority
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

GeneralWarningNotSpecified = _libsbml.GeneralWarningNotSpecified
    ## @var long GeneralWarningNotSpecified
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

CompartmentShouldHaveSize = _libsbml.CompartmentShouldHaveSize
    ## @var long CompartmentShouldHaveSize
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SpeciesShouldHaveValue = _libsbml.SpeciesShouldHaveValue
    ## @var long SpeciesShouldHaveValue
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ParameterShouldHaveUnits = _libsbml.ParameterShouldHaveUnits
    ## @var long ParameterShouldHaveUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

LocalParameterShadowsId = _libsbml.LocalParameterShadowsId
    ## @var long LocalParameterShadowsId
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

LibSBMLAdditionalCodesLowerBound = _libsbml.LibSBMLAdditionalCodesLowerBound
    ## @var long LibSBMLAdditionalCodesLowerBound
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

CannotConvertToL1V1 = _libsbml.CannotConvertToL1V1
    ## @var long CannotConvertToL1V1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoEventsInL1 = _libsbml.NoEventsInL1
    ## @var long NoEventsInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoFunctionDefinitionsInL1 = _libsbml.NoFunctionDefinitionsInL1
    ## @var long NoFunctionDefinitionsInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoConstraintsInL1 = _libsbml.NoConstraintsInL1
    ## @var long NoConstraintsInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoInitialAssignmentsInL1 = _libsbml.NoInitialAssignmentsInL1
    ## @var long NoInitialAssignmentsInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoSpeciesTypesInL1 = _libsbml.NoSpeciesTypesInL1
    ## @var long NoSpeciesTypesInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoCompartmentTypeInL1 = _libsbml.NoCompartmentTypeInL1
    ## @var long NoCompartmentTypeInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoNon3DCompartmentsInL1 = _libsbml.NoNon3DCompartmentsInL1
    ## @var long NoNon3DCompartmentsInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoFancyStoichiometryMathInL1 = _libsbml.NoFancyStoichiometryMathInL1
    ## @var long NoFancyStoichiometryMathInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoNonIntegerStoichiometryInL1 = _libsbml.NoNonIntegerStoichiometryInL1
    ## @var long NoNonIntegerStoichiometryInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoUnitMultipliersOrOffsetsInL1 = _libsbml.NoUnitMultipliersOrOffsetsInL1
    ## @var long NoUnitMultipliersOrOffsetsInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SpeciesCompartmentRequiredInL1 = _libsbml.SpeciesCompartmentRequiredInL1
    ## @var long SpeciesCompartmentRequiredInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoSpeciesSpatialSizeUnitsInL1 = _libsbml.NoSpeciesSpatialSizeUnitsInL1
    ## @var long NoSpeciesSpatialSizeUnitsInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoSBOTermsInL1 = _libsbml.NoSBOTermsInL1
    ## @var long NoSBOTermsInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

StrictUnitsRequiredInL1 = _libsbml.StrictUnitsRequiredInL1
    ## @var long StrictUnitsRequiredInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ConversionFactorNotInL1 = _libsbml.ConversionFactorNotInL1
    ## @var long ConversionFactorNotInL1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

CompartmentNotOnL1Reaction = _libsbml.CompartmentNotOnL1Reaction
    ## @var long CompartmentNotOnL1Reaction
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ExtentUnitsNotSubstance = _libsbml.ExtentUnitsNotSubstance
    ## @var long ExtentUnitsNotSubstance
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoConstraintsInL2v1 = _libsbml.NoConstraintsInL2v1
    ## @var long NoConstraintsInL2v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoInitialAssignmentsInL2v1 = _libsbml.NoInitialAssignmentsInL2v1
    ## @var long NoInitialAssignmentsInL2v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoSpeciesTypeInL2v1 = _libsbml.NoSpeciesTypeInL2v1
    ## @var long NoSpeciesTypeInL2v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoCompartmentTypeInL2v1 = _libsbml.NoCompartmentTypeInL2v1
    ## @var long NoCompartmentTypeInL2v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoSBOTermsInL2v1 = _libsbml.NoSBOTermsInL2v1
    ## @var long NoSBOTermsInL2v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoIdOnSpeciesReferenceInL2v1 = _libsbml.NoIdOnSpeciesReferenceInL2v1
    ## @var long NoIdOnSpeciesReferenceInL2v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoDelayedEventAssignmentInL2v1 = _libsbml.NoDelayedEventAssignmentInL2v1
    ## @var long NoDelayedEventAssignmentInL2v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

StrictUnitsRequiredInL2v1 = _libsbml.StrictUnitsRequiredInL2v1
    ## @var long StrictUnitsRequiredInL2v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

IntegerSpatialDimensions = _libsbml.IntegerSpatialDimensions
    ## @var long IntegerSpatialDimensions
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

StoichiometryMathNotYetSupported = _libsbml.StoichiometryMathNotYetSupported
    ## @var long StoichiometryMathNotYetSupported
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

PriorityLostFromL3 = _libsbml.PriorityLostFromL3
    ## @var long PriorityLostFromL3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NonPersistentNotSupported = _libsbml.NonPersistentNotSupported
    ## @var long NonPersistentNotSupported
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InitialValueFalseEventNotSupported = _libsbml.InitialValueFalseEventNotSupported
    ## @var long InitialValueFalseEventNotSupported
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SBOTermNotUniversalInL2v2 = _libsbml.SBOTermNotUniversalInL2v2
    ## @var long SBOTermNotUniversalInL2v2
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoUnitOffsetInL2v2 = _libsbml.NoUnitOffsetInL2v2
    ## @var long NoUnitOffsetInL2v2
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoKineticLawTimeUnitsInL2v2 = _libsbml.NoKineticLawTimeUnitsInL2v2
    ## @var long NoKineticLawTimeUnitsInL2v2
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoKineticLawSubstanceUnitsInL2v2 = _libsbml.NoKineticLawSubstanceUnitsInL2v2
    ## @var long NoKineticLawSubstanceUnitsInL2v2
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoDelayedEventAssignmentInL2v2 = _libsbml.NoDelayedEventAssignmentInL2v2
    ## @var long NoDelayedEventAssignmentInL2v2
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ModelSBOBranchChangedBeyondL2v2 = _libsbml.ModelSBOBranchChangedBeyondL2v2
    ## @var long ModelSBOBranchChangedBeyondL2v2
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

StrictUnitsRequiredInL2v2 = _libsbml.StrictUnitsRequiredInL2v2
    ## @var long StrictUnitsRequiredInL2v2
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

StrictSBORequiredInL2v2 = _libsbml.StrictSBORequiredInL2v2
    ## @var long StrictSBORequiredInL2v2
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DuplicateAnnotationInvalidInL2v2 = _libsbml.DuplicateAnnotationInvalidInL2v2
    ## @var long DuplicateAnnotationInvalidInL2v2
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoUnitOffsetInL2v3 = _libsbml.NoUnitOffsetInL2v3
    ## @var long NoUnitOffsetInL2v3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoKineticLawTimeUnitsInL2v3 = _libsbml.NoKineticLawTimeUnitsInL2v3
    ## @var long NoKineticLawTimeUnitsInL2v3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoKineticLawSubstanceUnitsInL2v3 = _libsbml.NoKineticLawSubstanceUnitsInL2v3
    ## @var long NoKineticLawSubstanceUnitsInL2v3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoSpeciesSpatialSizeUnitsInL2v3 = _libsbml.NoSpeciesSpatialSizeUnitsInL2v3
    ## @var long NoSpeciesSpatialSizeUnitsInL2v3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoEventTimeUnitsInL2v3 = _libsbml.NoEventTimeUnitsInL2v3
    ## @var long NoEventTimeUnitsInL2v3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoDelayedEventAssignmentInL2v3 = _libsbml.NoDelayedEventAssignmentInL2v3
    ## @var long NoDelayedEventAssignmentInL2v3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ModelSBOBranchChangedBeyondL2v3 = _libsbml.ModelSBOBranchChangedBeyondL2v3
    ## @var long ModelSBOBranchChangedBeyondL2v3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

StrictUnitsRequiredInL2v3 = _libsbml.StrictUnitsRequiredInL2v3
    ## @var long StrictUnitsRequiredInL2v3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

StrictSBORequiredInL2v3 = _libsbml.StrictSBORequiredInL2v3
    ## @var long StrictSBORequiredInL2v3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DuplicateAnnotationInvalidInL2v3 = _libsbml.DuplicateAnnotationInvalidInL2v3
    ## @var long DuplicateAnnotationInvalidInL2v3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoUnitOffsetInL2v4 = _libsbml.NoUnitOffsetInL2v4
    ## @var long NoUnitOffsetInL2v4
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoKineticLawTimeUnitsInL2v4 = _libsbml.NoKineticLawTimeUnitsInL2v4
    ## @var long NoKineticLawTimeUnitsInL2v4
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoKineticLawSubstanceUnitsInL2v4 = _libsbml.NoKineticLawSubstanceUnitsInL2v4
    ## @var long NoKineticLawSubstanceUnitsInL2v4
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoSpeciesSpatialSizeUnitsInL2v4 = _libsbml.NoSpeciesSpatialSizeUnitsInL2v4
    ## @var long NoSpeciesSpatialSizeUnitsInL2v4
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoEventTimeUnitsInL2v4 = _libsbml.NoEventTimeUnitsInL2v4
    ## @var long NoEventTimeUnitsInL2v4
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ModelSBOBranchChangedInL2v4 = _libsbml.ModelSBOBranchChangedInL2v4
    ## @var long ModelSBOBranchChangedInL2v4
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DuplicateAnnotationInvalidInL2v4 = _libsbml.DuplicateAnnotationInvalidInL2v4
    ## @var long DuplicateAnnotationInvalidInL2v4
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoSpeciesTypeInL3v1 = _libsbml.NoSpeciesTypeInL3v1
    ## @var long NoSpeciesTypeInL3v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoCompartmentTypeInL3v1 = _libsbml.NoCompartmentTypeInL3v1
    ## @var long NoCompartmentTypeInL3v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoUnitOffsetInL3v1 = _libsbml.NoUnitOffsetInL3v1
    ## @var long NoUnitOffsetInL3v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoKineticLawTimeUnitsInL3v1 = _libsbml.NoKineticLawTimeUnitsInL3v1
    ## @var long NoKineticLawTimeUnitsInL3v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoKineticLawSubstanceUnitsInL3v1 = _libsbml.NoKineticLawSubstanceUnitsInL3v1
    ## @var long NoKineticLawSubstanceUnitsInL3v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoSpeciesSpatialSizeUnitsInL3v1 = _libsbml.NoSpeciesSpatialSizeUnitsInL3v1
    ## @var long NoSpeciesSpatialSizeUnitsInL3v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoEventTimeUnitsInL3v1 = _libsbml.NoEventTimeUnitsInL3v1
    ## @var long NoEventTimeUnitsInL3v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ModelSBOBranchChangedInL3v1 = _libsbml.ModelSBOBranchChangedInL3v1
    ## @var long ModelSBOBranchChangedInL3v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

DuplicateAnnotationInvalidInL3v1 = _libsbml.DuplicateAnnotationInvalidInL3v1
    ## @var long DuplicateAnnotationInvalidInL3v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoCompartmentOutsideInL3v1 = _libsbml.NoCompartmentOutsideInL3v1
    ## @var long NoCompartmentOutsideInL3v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoStoichiometryMathInL3v1 = _libsbml.NoStoichiometryMathInL3v1
    ## @var long NoStoichiometryMathInL3v1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidSBMLLevelVersion = _libsbml.InvalidSBMLLevelVersion
    ## @var long InvalidSBMLLevelVersion
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

AnnotationNotesNotAllowedLevel1 = _libsbml.AnnotationNotesNotAllowedLevel1
    ## @var long AnnotationNotesNotAllowedLevel1
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidRuleOrdering = _libsbml.InvalidRuleOrdering
    ## @var long InvalidRuleOrdering
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

RequiredPackagePresent = _libsbml.RequiredPackagePresent
    ## @var long RequiredPackagePresent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UnrequiredPackagePresent = _libsbml.UnrequiredPackagePresent
    ## @var long UnrequiredPackagePresent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SubsUnitsAllowedInKL = _libsbml.SubsUnitsAllowedInKL
    ## @var long SubsUnitsAllowedInKL
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

TimeUnitsAllowedInKL = _libsbml.TimeUnitsAllowedInKL
    ## @var long TimeUnitsAllowedInKL
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

FormulaInLevel1KL = _libsbml.FormulaInLevel1KL
    ## @var long FormulaInLevel1KL
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

TimeUnitsRemoved = _libsbml.TimeUnitsRemoved
    ## @var long TimeUnitsRemoved
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

BadMathML = _libsbml.BadMathML
    ## @var long BadMathML
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

FailedMathMLReadOfDouble = _libsbml.FailedMathMLReadOfDouble
    ## @var long FailedMathMLReadOfDouble
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

FailedMathMLReadOfInteger = _libsbml.FailedMathMLReadOfInteger
    ## @var long FailedMathMLReadOfInteger
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

FailedMathMLReadOfExponential = _libsbml.FailedMathMLReadOfExponential
    ## @var long FailedMathMLReadOfExponential
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

FailedMathMLReadOfRational = _libsbml.FailedMathMLReadOfRational
    ## @var long FailedMathMLReadOfRational
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

BadMathMLNodeType = _libsbml.BadMathMLNodeType
    ## @var long BadMathMLNodeType
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidMathMLAttribute = _libsbml.InvalidMathMLAttribute
    ## @var long InvalidMathMLAttribute
    ##
    ## Attribute not allowed on this element. 

NoTimeSymbolInFunctionDef = _libsbml.NoTimeSymbolInFunctionDef
    ## @var long NoTimeSymbolInFunctionDef
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NoBodyInFunctionDef = _libsbml.NoBodyInFunctionDef
    ## @var long NoBodyInFunctionDef
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InconsistentArgUnitsWarnings = _libsbml.InconsistentArgUnitsWarnings
    ## @var long InconsistentArgUnitsWarnings
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InconsistentPowerUnitsWarnings = _libsbml.InconsistentPowerUnitsWarnings
    ## @var long InconsistentPowerUnitsWarnings
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InconsistentExponUnitsWarnings = _libsbml.InconsistentExponUnitsWarnings
    ## @var long InconsistentExponUnitsWarnings
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UndeclaredUnits = _libsbml.UndeclaredUnits
    ## @var long UndeclaredUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UndeclaredTimeUnitsL3 = _libsbml.UndeclaredTimeUnitsL3
    ## @var long UndeclaredTimeUnitsL3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UndeclaredExtentUnitsL3 = _libsbml.UndeclaredExtentUnitsL3
    ## @var long UndeclaredExtentUnitsL3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UndeclaredObjectUnitsL3 = _libsbml.UndeclaredObjectUnitsL3
    ## @var long UndeclaredObjectUnitsL3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UnrecognisedSBOTerm = _libsbml.UnrecognisedSBOTerm
    ## @var long UnrecognisedSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ObseleteSBOTerm = _libsbml.ObseleteSBOTerm
    ## @var long ObseleteSBOTerm
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

IncorrectCompartmentSpatialDimensions = _libsbml.IncorrectCompartmentSpatialDimensions
    ## @var long IncorrectCompartmentSpatialDimensions
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

CompartmentTypeNotValidAttribute = _libsbml.CompartmentTypeNotValidAttribute
    ## @var long CompartmentTypeNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ConstantNotValidAttribute = _libsbml.ConstantNotValidAttribute
    ## @var long ConstantNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MetaIdNotValidAttribute = _libsbml.MetaIdNotValidAttribute
    ## @var long MetaIdNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SBOTermNotValidAttributeBeforeL2V3 = _libsbml.SBOTermNotValidAttributeBeforeL2V3
    ## @var long SBOTermNotValidAttributeBeforeL2V3
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidL1CompartmentUnits = _libsbml.InvalidL1CompartmentUnits
    ## @var long InvalidL1CompartmentUnits
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

L1V1CompartmentVolumeReqd = _libsbml.L1V1CompartmentVolumeReqd
    ## @var long L1V1CompartmentVolumeReqd
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

CompartmentTypeNotValidComponent = _libsbml.CompartmentTypeNotValidComponent
    ## @var long CompartmentTypeNotValidComponent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ConstraintNotValidComponent = _libsbml.ConstraintNotValidComponent
    ## @var long ConstraintNotValidComponent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

EventNotValidComponent = _libsbml.EventNotValidComponent
    ## @var long EventNotValidComponent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SBOTermNotValidAttributeBeforeL2V2 = _libsbml.SBOTermNotValidAttributeBeforeL2V2
    ## @var long SBOTermNotValidAttributeBeforeL2V2
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

FuncDefNotValidComponent = _libsbml.FuncDefNotValidComponent
    ## @var long FuncDefNotValidComponent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InitialAssignNotValidComponent = _libsbml.InitialAssignNotValidComponent
    ## @var long InitialAssignNotValidComponent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

VariableNotValidAttribute = _libsbml.VariableNotValidAttribute
    ## @var long VariableNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UnitsNotValidAttribute = _libsbml.UnitsNotValidAttribute
    ## @var long UnitsNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

ConstantSpeciesNotValidAttribute = _libsbml.ConstantSpeciesNotValidAttribute
    ## @var long ConstantSpeciesNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SpatialSizeUnitsNotValidAttribute = _libsbml.SpatialSizeUnitsNotValidAttribute
    ## @var long SpatialSizeUnitsNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SpeciesTypeNotValidAttribute = _libsbml.SpeciesTypeNotValidAttribute
    ## @var long SpeciesTypeNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

HasOnlySubsUnitsNotValidAttribute = _libsbml.HasOnlySubsUnitsNotValidAttribute
    ## @var long HasOnlySubsUnitsNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

IdNotValidAttribute = _libsbml.IdNotValidAttribute
    ## @var long IdNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

NameNotValidAttribute = _libsbml.NameNotValidAttribute
    ## @var long NameNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SpeciesTypeNotValidComponent = _libsbml.SpeciesTypeNotValidComponent
    ## @var long SpeciesTypeNotValidComponent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

StoichiometryMathNotValidComponent = _libsbml.StoichiometryMathNotValidComponent
    ## @var long StoichiometryMathNotValidComponent
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

MultiplierNotValidAttribute = _libsbml.MultiplierNotValidAttribute
    ## @var long MultiplierNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

OffsetNotValidAttribute = _libsbml.OffsetNotValidAttribute
    ## @var long OffsetNotValidAttribute
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

L3SpatialDimensionsUnset = _libsbml.L3SpatialDimensionsUnset
    ## @var long L3SpatialDimensionsUnset
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

UnknownCoreAttribute = _libsbml.UnknownCoreAttribute
    ## @var long UnknownCoreAttribute
    ##
    ## Encountered an unknow attribute in the core SBML Level 3 namespace.

UnknownPackageAttribute = _libsbml.UnknownPackageAttribute
    ## @var long UnknownPackageAttribute
    ##
    ## Encountered an unknown attribute in an SBML Level 3 package namespace.

PackageConversionNotSupported = _libsbml.PackageConversionNotSupported
    ## @var long PackageConversionNotSupported
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

InvalidTargetLevelVersion = _libsbml.InvalidTargetLevelVersion
    ## @var long InvalidTargetLevelVersion
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

L3NotSupported = _libsbml.L3NotSupported
    ## @var long L3NotSupported
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

SBMLCodesUpperBound = _libsbml.SBMLCodesUpperBound
    ## @var long SBMLCodesUpperBound
    ## 
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

LIBSBML_CAT_SBML = _libsbml.LIBSBML_CAT_SBML
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: General SBML error not falling
    ## into another category below.

LIBSBML_CAT_SBML_L1_COMPAT = _libsbml.LIBSBML_CAT_SBML_L1_COMPAT
    ## @var long LIBSBML_CAT_SBML_L1_COMPAT
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of errors that can
    ## only occur during attempted translation from one Level/Version of
    ## SBML to another.  This particular category applies to errors
    ## encountered while trying to convert a model from SBML Level&nbsp;2
    ## to SBML Level&nbsp;1.

LIBSBML_CAT_SBML_L2V1_COMPAT = _libsbml.LIBSBML_CAT_SBML_L2V1_COMPAT
    ## @var long LIBSBML_CAT_SBML_L2V1_COMPAT
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of errors that can
    ## only occur during attempted translation from one Level/Version of
    ## SBML to another.  This particular category applies to errors
    ## encountered while trying to convert a model to SBML Level&nbsp;2
    ## Version&nbsp;1.

LIBSBML_CAT_SBML_L2V2_COMPAT = _libsbml.LIBSBML_CAT_SBML_L2V2_COMPAT
    ## @var long LIBSBML_CAT_SBML_L2V2_COMPAT
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of errors that can
    ## only occur during attempted translation from one Level/Version of
    ## SBML to another.  This particular category applies to errors
    ## encountered while trying to convert a model to SBML Level&nbsp;2
    ## Version&nbsp;2.

LIBSBML_CAT_GENERAL_CONSISTENCY = _libsbml.LIBSBML_CAT_GENERAL_CONSISTENCY
    ## @var long LIBSBML_CAT_GENERAL_CONSISTENCY
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of errors that can
    ## occur while validating general SBML constructs.  With respect to the
    ## SBML specification, these concern failures in applying the
    ## validation rules numbered 2xxxx in the Level&nbsp;2 Versions&nbsp;2
    ## and&nbsp;3 specifications.

LIBSBML_CAT_IDENTIFIER_CONSISTENCY = _libsbml.LIBSBML_CAT_IDENTIFIER_CONSISTENCY
    ## @var long LIBSBML_CAT_IDENTIFIER_CONSISTENCY
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of errors that can
    ## occur while validating symbol identifiers in a model.  With respect
    ## to the SBML specification, these concern failures in applying the
    ## validation rules numbered 103xx in the Level&nbsp;2 Versions&nbsp;2
    ## and&nbsp;3 specifications.

LIBSBML_CAT_UNITS_CONSISTENCY = _libsbml.LIBSBML_CAT_UNITS_CONSISTENCY
    ## @var long LIBSBML_CAT_UNITS_CONSISTENCY
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of errors that can
    ## occur while validating the units of measurement on quantities in a
    ## model.  With respect to the SBML specification, these concern
    ## failures in applying the validation rules numbered 105xx in the
    ## Level&nbsp;2 Versions&nbsp;2 and&nbsp;3 specifications.

LIBSBML_CAT_MATHML_CONSISTENCY = _libsbml.LIBSBML_CAT_MATHML_CONSISTENCY
    ## @var long LIBSBML_CAT_MATHML_CONSISTENCY
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of errors that can
    ## occur while validating MathML formulas in a model.  With respect to
    ## the SBML specification, these concern failures in applying the
    ## validation rules numbered 102xx in the Level&nbsp;2 Versions&nbsp;2
    ## and&nbsp;3 specifications.

LIBSBML_CAT_SBO_CONSISTENCY = _libsbml.LIBSBML_CAT_SBO_CONSISTENCY
    ## @var long LIBSBML_CAT_SBO_CONSISTENCY
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of errors that can
    ## occur while validating SBO identifiers in a model.  With respect to
    ## the SBML specification, these concern failures in applying the
    ## validation rules numbered 107xx in the Level&nbsp;2 Versions&nbsp;2
    ## and&nbsp;3 specifications.

LIBSBML_CAT_OVERDETERMINED_MODEL = _libsbml.LIBSBML_CAT_OVERDETERMINED_MODEL
    ## @var long LIBSBML_CAT_OVERDETERMINED_MODEL
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Error in the system of
    ## equations in the model: the system is overdetermined, therefore
    ## violating a tenet of proper SBML.  With respect to the SBML
    ## specification, this is validation rule #10601 in the SBML
    ## Level&nbsp;2 Versions&nbsp;2 and&nbsp;3 specifications.

LIBSBML_CAT_SBML_L2V3_COMPAT = _libsbml.LIBSBML_CAT_SBML_L2V3_COMPAT
    ## @var long LIBSBML_CAT_SBML_L2V3_COMPAT
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of errors that can
    ## only occur during attempted translation from one Level/Version of
    ## SBML to another.  This particular category applies to errors
    ## encountered while trying to convert a model to SBML Level&nbsp;2
    ## Version&nbsp;3.

LIBSBML_CAT_MODELING_PRACTICE = _libsbml.LIBSBML_CAT_MODELING_PRACTICE
    ## @var long LIBSBML_CAT_MODELING_PRACTICE
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of warnings about
    ## recommended good practices involving SBML and computational
    ## modeling.  (These are tests performed by libSBML and do not have
    ## equivalent SBML validation rules.)

LIBSBML_CAT_INTERNAL_CONSISTENCY = _libsbml.LIBSBML_CAT_INTERNAL_CONSISTENCY
    ## @var long LIBSBML_CAT_INTERNAL_CONSISTENCY
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of errors that can
    ## occur while validating libSBML's internal representation of SBML
    ## constructs. (These are tests performed by libSBML and do not have
    ## equivalent SBML validation rules.)

LIBSBML_CAT_SBML_L2V4_COMPAT = _libsbml.LIBSBML_CAT_SBML_L2V4_COMPAT
    ## @var long LIBSBML_CAT_SBML_L2V4_COMPAT
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of errors that can
    ## only occur during attempted translation from one Level/Version of
    ## SBML to another.  This particular category applies to errors
    ## encountered while trying to convert a model to SBML Level&nbsp;2
    ## Version&nbsp;4.

LIBSBML_CAT_SBML_L3V1_COMPAT = _libsbml.LIBSBML_CAT_SBML_L3V1_COMPAT
    ## @var long LIBSBML_CAT_SBML_L3V1_COMPAT
    ## Category code for SBMLError diagnostics.
    ##
    ## This code has the following meaning: Category of errors that can
    ## only occur during attempted translation from one Level/Version of
    ## SBML to another.  This particular category applies to errors
    ## encountered while trying to convert a model to SBML Level&nbsp;3
    ## Version&nbsp;1.

SBML_UNKNOWN = _libsbml.SBML_UNKNOWN
    ## @var long SBML_UNKNOWN
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_COMPARTMENT = _libsbml.SBML_COMPARTMENT
    ## @var long SBML_COMPARTMENT
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_COMPARTMENT_TYPE = _libsbml.SBML_COMPARTMENT_TYPE
    ## @var long SBML_COMPARTMENT_TYPE
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_CONSTRAINT = _libsbml.SBML_CONSTRAINT
    ## @var long SBML_CONSTRAINT
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_DOCUMENT = _libsbml.SBML_DOCUMENT
    ## @var long SBML_DOCUMENT
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_EVENT = _libsbml.SBML_EVENT
    ## @var long SBML_EVENT
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_EVENT_ASSIGNMENT = _libsbml.SBML_EVENT_ASSIGNMENT
    ## @var long SBML_EVENT_ASSIGNMENT
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_FUNCTION_DEFINITION = _libsbml.SBML_FUNCTION_DEFINITION
    ## @var long SBML_FUNCTION_DEFINITION
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_INITIAL_ASSIGNMENT = _libsbml.SBML_INITIAL_ASSIGNMENT
    ## @var long SBML_INITIAL_ASSIGNMENT
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_KINETIC_LAW = _libsbml.SBML_KINETIC_LAW
    ## @var long SBML_KINETIC_LAW
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_LIST_OF = _libsbml.SBML_LIST_OF
    ## @var long SBML_LIST_OF
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_MODEL = _libsbml.SBML_MODEL
    ## @var long SBML_MODEL
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_PARAMETER = _libsbml.SBML_PARAMETER
    ## @var long SBML_PARAMETER
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_REACTION = _libsbml.SBML_REACTION
    ## @var long SBML_REACTION
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_RULE = _libsbml.SBML_RULE
    ## @var long SBML_RULE
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_SPECIES = _libsbml.SBML_SPECIES
    ## @var long SBML_SPECIES
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_SPECIES_REFERENCE = _libsbml.SBML_SPECIES_REFERENCE
    ## @var long SBML_SPECIES_REFERENCE
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_SPECIES_TYPE = _libsbml.SBML_SPECIES_TYPE
    ## @var long SBML_SPECIES_TYPE
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_MODIFIER_SPECIES_REFERENCE = _libsbml.SBML_MODIFIER_SPECIES_REFERENCE
    ## @var long SBML_MODIFIER_SPECIES_REFERENCE
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_UNIT_DEFINITION = _libsbml.SBML_UNIT_DEFINITION
    ## @var long SBML_UNIT_DEFINITION
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_UNIT = _libsbml.SBML_UNIT
    ## @var long SBML_UNIT
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_ALGEBRAIC_RULE = _libsbml.SBML_ALGEBRAIC_RULE
    ## @var long SBML_ALGEBRAIC_RULE
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_ASSIGNMENT_RULE = _libsbml.SBML_ASSIGNMENT_RULE
    ## @var long SBML_ASSIGNMENT_RULE
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_RATE_RULE = _libsbml.SBML_RATE_RULE
    ## @var long SBML_RATE_RULE
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_SPECIES_CONCENTRATION_RULE = _libsbml.SBML_SPECIES_CONCENTRATION_RULE
    ## @var long SBML_SPECIES_CONCENTRATION_RULE
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_COMPARTMENT_VOLUME_RULE = _libsbml.SBML_COMPARTMENT_VOLUME_RULE
    ## @var long SBML_COMPARTMENT_VOLUME_RULE
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_PARAMETER_RULE = _libsbml.SBML_PARAMETER_RULE
    ## @var long SBML_PARAMETER_RULE
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_TRIGGER = _libsbml.SBML_TRIGGER
    ## @var long SBML_TRIGGER
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_DELAY = _libsbml.SBML_DELAY
    ## @var long SBML_DELAY
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_STOICHIOMETRY_MATH = _libsbml.SBML_STOICHIOMETRY_MATH
    ## @var long SBML_STOICHIOMETRY_MATH
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_LOCAL_PARAMETER = _libsbml.SBML_LOCAL_PARAMETER
    ## @var long SBML_LOCAL_PARAMETER
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

SBML_PRIORITY = _libsbml.SBML_PRIORITY
    ## @var long SBML_PRIORITY
    ## @brief One of the possible SBML component type codes.
    ##
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.

UNIT_KIND_AMPERE = _libsbml.UNIT_KIND_AMPERE
    ## @var long UNIT_KIND_AMPERE
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_AVOGADRO = _libsbml.UNIT_KIND_AVOGADRO
    ## @var long UNIT_KIND_AVOGADRO
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_BECQUEREL = _libsbml.UNIT_KIND_BECQUEREL
    ## @var long UNIT_KIND_BECQUEREL
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_CANDELA = _libsbml.UNIT_KIND_CANDELA
    ## @var long UNIT_KIND_CANDELA
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_CELSIUS = _libsbml.UNIT_KIND_CELSIUS
    ## @var long UNIT_KIND_CELSIUS
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_COULOMB = _libsbml.UNIT_KIND_COULOMB
    ## @var long UNIT_KIND_COULOMB
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_DIMENSIONLESS = _libsbml.UNIT_KIND_DIMENSIONLESS
    ## @var long UNIT_KIND_DIMENSIONLESS
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_FARAD = _libsbml.UNIT_KIND_FARAD
    ## @var long UNIT_KIND_FARAD
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_GRAM = _libsbml.UNIT_KIND_GRAM
    ## @var long UNIT_KIND_GRAM
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_GRAY = _libsbml.UNIT_KIND_GRAY
    ## @var long UNIT_KIND_GRAY
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_HENRY = _libsbml.UNIT_KIND_HENRY
    ## @var long UNIT_KIND_HENRY
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_HERTZ = _libsbml.UNIT_KIND_HERTZ
    ## @var long UNIT_KIND_HERTZ
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_ITEM = _libsbml.UNIT_KIND_ITEM
    ## @var long UNIT_KIND_ITEM
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_JOULE = _libsbml.UNIT_KIND_JOULE
    ## @var long UNIT_KIND_JOULE
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_KATAL = _libsbml.UNIT_KIND_KATAL
    ## @var long UNIT_KIND_KATAL
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_KELVIN = _libsbml.UNIT_KIND_KELVIN
    ## @var long UNIT_KIND_KELVIN
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_KILOGRAM = _libsbml.UNIT_KIND_KILOGRAM
    ## @var long UNIT_KIND_KILOGRAM
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_LITER = _libsbml.UNIT_KIND_LITER
    ## @var long UNIT_KIND_LITER
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_LITRE = _libsbml.UNIT_KIND_LITRE
    ## @var long UNIT_KIND_LITRE
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_LUMEN = _libsbml.UNIT_KIND_LUMEN
    ## @var long UNIT_KIND_LUMEN
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_LUX = _libsbml.UNIT_KIND_LUX
    ## @var long UNIT_KIND_LUX
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_METER = _libsbml.UNIT_KIND_METER
    ## @var long UNIT_KIND_METER
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_METRE = _libsbml.UNIT_KIND_METRE
    ## @var long UNIT_KIND_METRE
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_MOLE = _libsbml.UNIT_KIND_MOLE
    ## @var long UNIT_KIND_MOLE
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_NEWTON = _libsbml.UNIT_KIND_NEWTON
    ## @var long UNIT_KIND_NEWTON
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_OHM = _libsbml.UNIT_KIND_OHM
    ## @var long UNIT_KIND_OHM
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_PASCAL = _libsbml.UNIT_KIND_PASCAL
    ## @var long UNIT_KIND_PASCAL
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_RADIAN = _libsbml.UNIT_KIND_RADIAN
    ## @var long UNIT_KIND_RADIAN
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_SECOND = _libsbml.UNIT_KIND_SECOND
    ## @var long UNIT_KIND_SECOND
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_SIEMENS = _libsbml.UNIT_KIND_SIEMENS
    ## @var long UNIT_KIND_SIEMENS
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_SIEVERT = _libsbml.UNIT_KIND_SIEVERT
    ## @var long UNIT_KIND_SIEVERT
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_STERADIAN = _libsbml.UNIT_KIND_STERADIAN
    ## @var long UNIT_KIND_STERADIAN
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_TESLA = _libsbml.UNIT_KIND_TESLA
    ## @var long UNIT_KIND_TESLA
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_VOLT = _libsbml.UNIT_KIND_VOLT
    ## @var long UNIT_KIND_VOLT
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_WATT = _libsbml.UNIT_KIND_WATT
    ## @var long UNIT_KIND_WATT
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_WEBER = _libsbml.UNIT_KIND_WEBER
    ## @var long UNIT_KIND_WEBER
    ## @brief One of the possible predefined SBML units.

UNIT_KIND_INVALID = _libsbml.UNIT_KIND_INVALID
    ## @var long UNIT_KIND_INVALID
    ## @brief One of the possible predefined SBML units.

RULE_TYPE_RATE = _libsbml.RULE_TYPE_RATE
    ## @var long RULE_TYPE_RATE
    ## @brief One of the possible SBML Rule object types.

RULE_TYPE_SCALAR = _libsbml.RULE_TYPE_SCALAR
    ## @var long RULE_TYPE_SCALAR
    ## @brief One of the possible SBML Rule object types.

RULE_TYPE_INVALID = _libsbml.RULE_TYPE_INVALID
    ## @var long RULE_TYPE_INVALID
    ## @brief One of the possible SBML Rule object types.

AST_UNKNOWN = _libsbml.AST_UNKNOWN
    ## @var long AST_UNKNOWN
    ## @brief One of the possible SBML Rule object types.

AST_ORIGINATES_IN_PACKAGE = _libsbml.AST_ORIGINATES_IN_PACKAGE
    ## @var long AST_ORIGINATES_IN_PACKAGE
    ## @brief This node uses math that is only available in an
    ## SBML Level 3 package.

AST_PLUS = _libsbml.AST_PLUS
    ## @var long AST_PLUS
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_MINUS = _libsbml.AST_MINUS
    ## @var long AST_MINUS
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_TIMES = _libsbml.AST_TIMES
    ## @var long AST_TIMES
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_DIVIDE = _libsbml.AST_DIVIDE
    ## @var long AST_DIVIDE
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_POWER = _libsbml.AST_POWER
    ## @var long AST_POWER
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_INTEGER = _libsbml.AST_INTEGER
    ## @var long AST_INTEGER
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_REAL = _libsbml.AST_REAL
    ## @var long AST_REAL
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_REAL_E = _libsbml.AST_REAL_E
    ## @var long AST_REAL_E
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_RATIONAL = _libsbml.AST_RATIONAL
    ## @var long AST_RATIONAL
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_NAME = _libsbml.AST_NAME
    ## @var long AST_NAME
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_NAME_AVOGADRO = _libsbml.AST_NAME_AVOGADRO
    ## @var long AST_NAME_AVOGADRO
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_NAME_TIME = _libsbml.AST_NAME_TIME
    ## @var long AST_NAME_TIME
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_CONSTANT_E = _libsbml.AST_CONSTANT_E
    ## @var long AST_CONSTANT_E
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_CONSTANT_FALSE = _libsbml.AST_CONSTANT_FALSE
    ## @var long AST_CONSTANT_FALSE
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_CONSTANT_PI = _libsbml.AST_CONSTANT_PI
    ## @var long AST_CONSTANT_PI
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_CONSTANT_TRUE = _libsbml.AST_CONSTANT_TRUE
    ## @var long AST_CONSTANT_TRUE
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_LAMBDA = _libsbml.AST_LAMBDA
    ## @var long AST_LAMBDA
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION = _libsbml.AST_FUNCTION
    ## @var long AST_FUNCTION
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ABS = _libsbml.AST_FUNCTION_ABS
    ## @var long AST_FUNCTION_ABS
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ARCCOS = _libsbml.AST_FUNCTION_ARCCOS
    ## @var long AST_FUNCTION_ARCCOS
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ARCCOSH = _libsbml.AST_FUNCTION_ARCCOSH
    ## @var long AST_FUNCTION_ARCCOSH
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ARCCOT = _libsbml.AST_FUNCTION_ARCCOT
    ## @var long AST_FUNCTION_ARCCOT
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ARCCOTH = _libsbml.AST_FUNCTION_ARCCOTH
    ## @var long AST_FUNCTION_ARCCOTH
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ARCCSC = _libsbml.AST_FUNCTION_ARCCSC
    ## @var long AST_FUNCTION_ARCCSC
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ARCCSCH = _libsbml.AST_FUNCTION_ARCCSCH
    ## @var long AST_FUNCTION_ARCCSCH
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ARCSEC = _libsbml.AST_FUNCTION_ARCSEC
    ## @var long AST_FUNCTION_ARCSEC
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ARCSECH = _libsbml.AST_FUNCTION_ARCSECH
    ## @var long AST_FUNCTION_ARCSECH
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ARCSIN = _libsbml.AST_FUNCTION_ARCSIN
    ## @var long AST_FUNCTION_ARCSIN
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ARCSINH = _libsbml.AST_FUNCTION_ARCSINH
    ## @var long AST_FUNCTION_ARCSINH
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ARCTAN = _libsbml.AST_FUNCTION_ARCTAN
    ## @var long AST_FUNCTION_ARCTAN
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ARCTANH = _libsbml.AST_FUNCTION_ARCTANH
    ## @var long AST_FUNCTION_ARCTANH
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_CEILING = _libsbml.AST_FUNCTION_CEILING
    ## @var long AST_FUNCTION_CEILING
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_COS = _libsbml.AST_FUNCTION_COS
    ## @var long AST_FUNCTION_COS
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_COSH = _libsbml.AST_FUNCTION_COSH
    ## @var long AST_FUNCTION_COSH
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_COT = _libsbml.AST_FUNCTION_COT
    ## @var long AST_FUNCTION_COT
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_COTH = _libsbml.AST_FUNCTION_COTH
    ## @var long AST_FUNCTION_COTH
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_CSC = _libsbml.AST_FUNCTION_CSC
    ## @var long AST_FUNCTION_CSC
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_CSCH = _libsbml.AST_FUNCTION_CSCH
    ## @var long AST_FUNCTION_CSCH
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_DELAY = _libsbml.AST_FUNCTION_DELAY
    ## @var long AST_FUNCTION_DELAY
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_EXP = _libsbml.AST_FUNCTION_EXP
    ## @var long AST_FUNCTION_EXP
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_FACTORIAL = _libsbml.AST_FUNCTION_FACTORIAL
    ## @var long AST_FUNCTION_FACTORIAL
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_FLOOR = _libsbml.AST_FUNCTION_FLOOR
    ## @var long AST_FUNCTION_FLOOR
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_LN = _libsbml.AST_FUNCTION_LN
    ## @var long AST_FUNCTION_LN
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_LOG = _libsbml.AST_FUNCTION_LOG
    ## @var long AST_FUNCTION_LOG
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_PIECEWISE = _libsbml.AST_FUNCTION_PIECEWISE
    ## @var long AST_FUNCTION_PIECEWISE
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_POWER = _libsbml.AST_FUNCTION_POWER
    ## @var long AST_FUNCTION_POWER
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_ROOT = _libsbml.AST_FUNCTION_ROOT
    ## @var long AST_FUNCTION_ROOT
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_SEC = _libsbml.AST_FUNCTION_SEC
    ## @var long AST_FUNCTION_SEC
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_SECH = _libsbml.AST_FUNCTION_SECH
    ## @var long AST_FUNCTION_SECH
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_SIN = _libsbml.AST_FUNCTION_SIN
    ## @var long AST_FUNCTION_SIN
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_SINH = _libsbml.AST_FUNCTION_SINH
    ## @var long AST_FUNCTION_SINH
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_TAN = _libsbml.AST_FUNCTION_TAN
    ## @var long AST_FUNCTION_TAN
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_FUNCTION_TANH = _libsbml.AST_FUNCTION_TANH
    ## @var long AST_FUNCTION_TANH
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_LOGICAL_AND = _libsbml.AST_LOGICAL_AND
    ## @var long AST_LOGICAL_AND
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_LOGICAL_NOT = _libsbml.AST_LOGICAL_NOT
    ## @var long AST_LOGICAL_NOT
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_LOGICAL_OR = _libsbml.AST_LOGICAL_OR
    ## @var long AST_LOGICAL_OR
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_LOGICAL_XOR = _libsbml.AST_LOGICAL_XOR
    ## @var long AST_LOGICAL_XOR
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_RELATIONAL_EQ = _libsbml.AST_RELATIONAL_EQ
    ## @var long AST_RELATIONAL_EQ
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_RELATIONAL_GEQ = _libsbml.AST_RELATIONAL_GEQ
    ## @var long AST_RELATIONAL_GEQ
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_RELATIONAL_GT = _libsbml.AST_RELATIONAL_GT
    ## @var long AST_RELATIONAL_GT
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_RELATIONAL_LEQ = _libsbml.AST_RELATIONAL_LEQ
    ## @var long AST_RELATIONAL_LEQ
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_RELATIONAL_LT = _libsbml.AST_RELATIONAL_LT
    ## @var long AST_RELATIONAL_LT
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_RELATIONAL_NEQ = _libsbml.AST_RELATIONAL_NEQ
    ## @var long AST_RELATIONAL_NEQ
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_CONSTRUCTOR_OTHERWISE = _libsbml.AST_CONSTRUCTOR_OTHERWISE
    ## @var long AST_CONSTRUCTOR_OTHERWISE
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_CONSTRUCTOR_PIECE = _libsbml.AST_CONSTRUCTOR_PIECE
    ## @var long AST_CONSTRUCTOR_PIECE
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_QUALIFIER_BVAR = _libsbml.AST_QUALIFIER_BVAR
    ## @var long AST_QUALIFIER_BVAR
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_QUALIFIER_DEGREE = _libsbml.AST_QUALIFIER_DEGREE
    ## @var long AST_QUALIFIER_DEGREE
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_QUALIFIER_LOGBASE = _libsbml.AST_QUALIFIER_LOGBASE
    ## @var long AST_QUALIFIER_LOGBASE
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

AST_SEMANTICS = _libsbml.AST_SEMANTICS
    ## @var long AST_SEMANTICS
    ##
    ## One of the possible ASTNode types.  Each ASTNode has
    ## a type whose value is one of the elements of this enumeration.

L3P_PARSE_LOG_AS_LOG10 = _libsbml.L3P_PARSE_LOG_AS_LOG10
    ## @var long L3P_PARSE_LOG_AS_LOG10
    ##
    ## Parse <code>log(x)</code> as the natural logarithm of <code>x</code>.

L3P_PARSE_LOG_AS_LN = _libsbml.L3P_PARSE_LOG_AS_LN
    ## @var long L3P_PARSE_LOG_AS_LN
    ##
    ## Refuse to parse <code>log(x)</code> at all, and set an error message 
    ## telling the user to use <code>log10(x)</code>, <code>ln(x)</code>,
    ## or <code>log(base, x)</code> instead.

L3P_PARSE_LOG_AS_ERROR = _libsbml.L3P_PARSE_LOG_AS_ERROR
    ## @var long L3P_PARSE_LOG_AS_ERROR
    ##
    ## Collapse unary minuses where possible when parsing text-string
    ## formulas.

L3P_COLLAPSE_UNARY_MINUS = _libsbml.L3P_COLLAPSE_UNARY_MINUS
    ## @var long L3P_COLLAPSE_UNARY_MINUS
    ##
    ## Retain unary minuses in the AST representation when parsing
    ## text-string formulas.

L3P_EXPAND_UNARY_MINUS = _libsbml.L3P_EXPAND_UNARY_MINUS
    ## @var long L3P_EXPAND_UNARY_MINUS
    ##
    ## Parse units in text-string formulas when parsing
    ## text-string formulas.

L3P_PARSE_UNITS = _libsbml.L3P_PARSE_UNITS
    ## @var long L3P_PARSE_UNITS
    ##
    ## Do not recognize units in text-string formulas&mdash;treat them as
    ## errors.

L3P_NO_UNITS = _libsbml.L3P_NO_UNITS
    ## @var long L3P_NO_UNITS
    ##
    ## Recognize 'avogadro' as an SBML Level 3 symbol when parsing
    ## text-string formulas.

L3P_AVOGADRO_IS_CSYMBOL = _libsbml.L3P_AVOGADRO_IS_CSYMBOL
    ## @var long L3P_AVOGADRO_IS_CSYMBOL
    ##
    ## Do not treat 'avogadro' specially&mdash;consider it a plain symbol
    ## name when parsing text-string formulas.

L3P_AVOGADRO_IS_NAME = _libsbml.L3P_AVOGADRO_IS_NAME
    ## @var long L3P_AVOGADRO_IS_NAME
    ##
    ## Collapse unary minuses where possible.

L3P_COMPARE_BUILTINS_CASE_INSENSITIVE = _libsbml.L3P_COMPARE_BUILTINS_CASE_INSENSITIVE
    ## @var long L3P_COMPARE_BUILTINS_CASE_INSENSITIVE
    ##
    ## Treat all forms of built-in functions as referencing that function,
    ## regardless of the capitalization of that string.

L3P_COMPARE_BUILTINS_CASE_SENSITIVE = _libsbml.L3P_COMPARE_BUILTINS_CASE_SENSITIVE
    ## @var long L3P_COMPARE_BUILTINS_CASE_SENSITIVE
    ##
    ## Treat only the all-lower-case form of built-in functions as referencing
    ## that function, and all other forms of capitalization of that string
    ## as referencing user-defined functions or values.

INFIX_SYNTAX_NAMED_SQUARE_BRACKETS = _libsbml.INFIX_SYNTAX_NAMED_SQUARE_BRACKETS
    ## @var long INFIX_SYNTAX_NAMED_SQUARE_BRACKETS
    ##

INFIX_SYNTAX_CURLY_BRACES = _libsbml.INFIX_SYNTAX_CURLY_BRACES
    ## @var long INFIX_SYNTAX_CURLY_BRACES
    ##

INFIX_SYNTAX_CURLY_BRACES_SEMICOLON = _libsbml.INFIX_SYNTAX_CURLY_BRACES_SEMICOLON
    ## @var long INFIX_SYNTAX_CURLY_BRACES_SEMICOLON
    ##

MODEL_QUALIFIER = _libsbml.MODEL_QUALIFIER
    ## @var long MODEL_QUALIFIER
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BIOLOGICAL_QUALIFIER = _libsbml.BIOLOGICAL_QUALIFIER
    ## @var long BIOLOGICAL_QUALIFIER
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

UNKNOWN_QUALIFIER = _libsbml.UNKNOWN_QUALIFIER
    ## @var long UNKNOWN_QUALIFIER
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQM_IS = _libsbml.BQM_IS
    ## @var long BQM_IS
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQM_IS_DESCRIBED_BY = _libsbml.BQM_IS_DESCRIBED_BY
    ## @var long BQM_IS_DESCRIBED_BY
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQM_IS_DERIVED_FROM = _libsbml.BQM_IS_DERIVED_FROM
    ## @var long BQM_IS_DERIVED_FROM
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQM_IS_INSTANCE_OF = _libsbml.BQM_IS_INSTANCE_OF
    ## @var long BQM_IS_INSTANCE_OF
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQM_HAS_INSTANCE = _libsbml.BQM_HAS_INSTANCE
    ## @var long BQM_HAS_INSTANCE
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQM_UNKNOWN = _libsbml.BQM_UNKNOWN
    ## @var long BQM_UNKNOWN
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_IS = _libsbml.BQB_IS
    ## @var long BQB_IS
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_HAS_PART = _libsbml.BQB_HAS_PART
    ## @var long BQB_HAS_PART
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_IS_PART_OF = _libsbml.BQB_IS_PART_OF
    ## @var long BQB_IS_PART_OF
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_IS_VERSION_OF = _libsbml.BQB_IS_VERSION_OF
    ## @var long BQB_IS_VERSION_OF
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_HAS_VERSION = _libsbml.BQB_HAS_VERSION
    ## @var long BQB_HAS_VERSION
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_IS_HOMOLOG_TO = _libsbml.BQB_IS_HOMOLOG_TO
    ## @var long BQB_IS_HOMOLOG_TO
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_IS_DESCRIBED_BY = _libsbml.BQB_IS_DESCRIBED_BY
    ## @var long BQB_IS_DESCRIBED_BY
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_IS_ENCODED_BY = _libsbml.BQB_IS_ENCODED_BY
    ## @var long BQB_IS_ENCODED_BY
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_ENCODES = _libsbml.BQB_ENCODES
    ## @var long BQB_ENCODES
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_OCCURS_IN = _libsbml.BQB_OCCURS_IN
    ## @var long BQB_OCCURS_IN
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_HAS_PROPERTY = _libsbml.BQB_HAS_PROPERTY
    ## @var long BQB_HAS_PROPERTY
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_IS_PROPERTY_OF = _libsbml.BQB_IS_PROPERTY_OF
    ## @var long BQB_IS_PROPERTY_OF
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_HAS_TAXON = _libsbml.BQB_HAS_TAXON
    ## @var long BQB_HAS_TAXON
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

BQB_UNKNOWN = _libsbml.BQB_UNKNOWN
    ## @var long BQB_UNKNOWN
    ##
    ## One of the possible MIRIAM annotation types used by CVTerm.

LIBSBML_OPERATION_SUCCESS = _libsbml.LIBSBML_OPERATION_SUCCESS
    ## @var long LIBSBML_OPERATION_SUCCESS
    ## @brief One of the possible libSBML operation return codes.
    ##
    ## This code has the following meaning: The operation was successful.
  
LIBSBML_INDEX_EXCEEDS_SIZE = _libsbml.LIBSBML_INDEX_EXCEEDS_SIZE
    ## @var long LIBSBML_INDEX_EXCEEDS_SIZE
    ## @brief One of the possible libSBML operation return codes.
    ##
    ## This code has the following meaning: An index parameter exceeded the
    ## bounds of a data array or other collection used in the operation.
    ## This return value is typically returned by methods that take index
    ## numbers to refer to lists of objects, when the caller has provided
    ## an index that exceeds the bounds of the list.  LibSBML provides
    ## methods for checking the size of list/sequence/collection
    ## structures, and callers should verify the sizes before calling
    ## methods that take index numbers.
  
LIBSBML_UNEXPECTED_ATTRIBUTE = _libsbml.LIBSBML_UNEXPECTED_ATTRIBUTE
    ## @var long LIBSBML_UNEXPECTED_ATTRIBUTE
    ## @brief One of the possible libSBML operation return codes.
    ##
    ## This code has the following meaning: The attribute that is the
    ## subject of this operation is not valid for the combination of SBML
    ## Level and Version for the underlying object.  This can happen
    ## because libSBML strives to offer a uniform API for all SBML Levels
    ## and Versions, but some object attributes and elements are not
    ## defined for all SBML Levels and Versions.  Calling programs are
    ## expected to be aware of which object structures they are working
    ## with, but when errors of this kind occur, they are reported using
    ## this return value.
  
LIBSBML_OPERATION_FAILED = _libsbml.LIBSBML_OPERATION_FAILED
    ## @var long LIBSBML_OPERATION_FAILED
    ## @brief One of the possible libSBML operation return codes.
    ##
    ## This code has the following meaning: The requested action could not
    ## be performed.  This can occur in a variety of contexts, such as
    ## passing a null object as a parameter in a situation where it does
    ## not make sense to permit a null object.
  
LIBSBML_INVALID_ATTRIBUTE_VALUE = _libsbml.LIBSBML_INVALID_ATTRIBUTE_VALUE
    ## @var long LIBSBML_INVALID_ATTRIBUTE_VALUE
    ## @brief One of the possible libSBML operation return codes.
    ##
    ## This code has the following meaning: A value passed as an argument
    ## to the method is not of a type that is valid for the operation or
    ## kind of object involved.  For example, this return code is used when
    ## a calling program attempts to set an SBML object identifier to a
    ## string whose syntax does not conform to the SBML identifier syntax.
  
LIBSBML_INVALID_OBJECT = _libsbml.LIBSBML_INVALID_OBJECT
    ## @var long LIBSBML_INVALID_OBJECT
    ## @brief One of the possible libSBML operation return codes.
    ##
    ## This code has the following meaning: The object passed as an
    ## argument to the method is not of a type that is valid for the
    ## operation or kind of object involved.  For example, handing an
    ## invalidly-constructed @link ASTNode@endlink to a method expecting an
    ## @link ASTNode@endlink will result in this error.
  
LIBSBML_DUPLICATE_OBJECT_ID = _libsbml.LIBSBML_DUPLICATE_OBJECT_ID
    ## @var long LIBSBML_DUPLICATE_OBJECT_ID
    ## @brief One of the possible libSBML operation return codes.
    ##
    ## This code has the following meaning: There already exists an object
    ## with this identifier in the context where this operation is being
    ## attempted.  This error is typically returned in situations where
    ## SBML object identifiers must be unique, such as attempting to add
    ## two species with the same identifier to a model.
  
LIBSBML_LEVEL_MISMATCH = _libsbml.LIBSBML_LEVEL_MISMATCH
    ## @var long LIBSBML_LEVEL_MISMATCH
    ## @brief One of the possible libSBML operation return codes.
    ##
    ## This code has the following meaning: The SBML Level associated with
    ## the object does not match the Level of the parent object.  This
    ## error can happen when an SBML component such as a species or
    ## compartment object is created outside of a model and a calling
    ## program then attempts to add the object to a model that has a
    ## different SBML Level defined.
  
LIBSBML_VERSION_MISMATCH = _libsbml.LIBSBML_VERSION_MISMATCH
    ## @var long LIBSBML_VERSION_MISMATCH
    ## @brief One of the possible libSBML operation return codes.
    ##
    ## This code has the following meaning: The SBML Version within the
    ## SBML Level associated with the object does not match the Version of
    ## the parent object.  This error can happen when an SBML component
    ## such as a species or compartment object is created outside of a
    ## model and a calling program then attempts to add the object to a
    ## model that has a different SBML Level+Version combination.
  
LIBSBML_INVALID_XML_OPERATION = _libsbml.LIBSBML_INVALID_XML_OPERATION
    ## @var long LIBSBML_INVALID_XML_OPERATION
    ## @brief One of the possible libSBML operation return codes.
    ##
    ## This code has the following meaning: The XML operation attempted is
    ## not valid for the object or context involved.  This error is
    ## typically returned by the XML interface layer of libSBML, when a
    ## calling program attempts to construct or manipulate XML in an
    ## invalid way.

LIBSBML_NAMESPACES_MISMATCH = _libsbml.LIBSBML_NAMESPACES_MISMATCH
    ## @var long LIBSBML_NAMESPACES_MISMATCH
    ## @brief One of the possible libSBML operation return codes.
    ##
    ## This code has the following meaning: The operation attempt could not
    ## be performed because the object(s) involved have mismatched XML
    ## namespaces for SBML Level/Versions.  This typically means the
    ## properties of the @link SBMLNamespaces@endlink objects possessed by the
    ## SBML objects do not correspond in some way.

LIBSBML_PKG_VERSION_MISMATCH = _libsbml.LIBSBML_PKG_VERSION_MISMATCH
    ## @var long LIBSBML_PKG_VERSION_MISMATCH
    ## @brief One of the possible libSBML package operation return codes.
    ##
    ## This code has the following meaning: the Version of the package
    ## extension within the SBML Level and version associated with the
    ## object does not match the Version of the parent object. This error
    ## can happen when an SBML component object is created outside of a
    ## model, and a calling program then attempts to add the object to a
    ## model that has a different SBML Level+Version+Package Version
    ## combination.

LIBSBML_DUPLICATE_ANNOTATION_NS = _libsbml.LIBSBML_DUPLICATE_ANNOTATION_NS
    ## @var long LIBSBML_DUPLICATE_ANNOTATION_NS
    ## @brief There already exists a top level annotation with the same
    ## namespace as annoation being appended.
    ##
    ## This error is typically returned in situations where the
    ## appendAnnotation function is being used to add an annotation that has
    ## a namespace that is already present in the existing annotation.

LIBSBML_ANNOTATION_NAME_NOT_FOUND = _libsbml.LIBSBML_ANNOTATION_NAME_NOT_FOUND
    ## @var long LIBSBML_ANNOTATION_NAME_NOT_FOUND
    ## @brief The existing annotation does not have a top-level element with
    ## the given name.
    ##
    ## This error is typically returned in situations where the
    ## replaceTopLevelAnnotationElement function or the
    ## removeTopLevelAnnotationElement function is being used to replace or
    ## remove an annotation with a name that does not match the name of any
    ## top-level element that is already present in the existing annotation.

LIBSBML_ANNOTATION_NS_NOT_FOUND = _libsbml.LIBSBML_ANNOTATION_NS_NOT_FOUND
    ## @var long LIBSBML_ANNOTATION_NS_NOT_FOUND
    ## @brief The existing annotation does not have a top-level element with
    ## the given namespace.
    ##
    ## This error is typically returned in situations where the
    ## replaceTopLevelAnnotationElement function or the
    ## removeTopLevelAnnotationElement function is being used to replace or
    ## remove an annotation with a namespace that does not match the
    ## namespace of any top-level element that is already present in the
    ## existing annotation.

LIBSBML_PKG_UNKNOWN = _libsbml.LIBSBML_PKG_UNKNOWN
    ## @var long LIBSBML_PKG_UNKNOWN
    ## @brief One of the possible libSBML package operation return codes.
    ##
    ## This code has the following meaning: the required package extension
    ## is unknown. This error is typically returned when creating an object
    ## of @link SBase@endlink derived class with the required package, creating
    ## an object of @link SBMLNamespaces@endlink or its derived class with the
    ## required package, or invoking functions depending on the required
    ## package.  To avoid this error, the library of the required package
    ## needs to be linked.

LIBSBML_PKG_UNKNOWN_VERSION = _libsbml.LIBSBML_PKG_UNKNOWN_VERSION
    ## @var long LIBSBML_PKG_UNKNOWN_VERSION
    ## @brief One of the possible libSBML package operation return codes.
    ##
    ## This code has the following meaning: The required version of the
    ## package extension is unknown.  This error is typically returned when
    ## creating an object of @link SBase@endlink derived class with the required
    ## package, creating an object of @link SBMLNamespaces@endlink or its derived
    ## class with the required package, or invoking functions depending on
    ## the required package.  This error may be avoided by updating the
    ## library of the required package to be linked.

LIBSBML_PKG_DISABLED = _libsbml.LIBSBML_PKG_DISABLED
    ## @var long LIBSBML_PKG_DISABLED
    ## @brief One of the possible libSBML package operation return codes.
    ##
    ## This code has the following meaning: The required package extension
    ## is disabled.  This error is typically returned when creating an
    ## object of @link SBase@endlink derived class with the required package,
    ## creating an object of @link SBMLNamespaces@endlink or its derived class
    ## with the required package, or invoking functions depending on the
    ## required package.  To avoid this error, the library of the required
    ## package needs to be enabled.

LIBSBML_PKG_CONFLICTED_VERSION = _libsbml.LIBSBML_PKG_CONFLICTED_VERSION
    ## @var long LIBSBML_PKG_CONFLICTED_VERSION
    ## @brief One of the possible libSBML package operation return codes.
    ##
    ## This code has the following meaning: another version of the required
    ## package extension has already been enabled in the target SBase
    ## object, or enabled in the model to/in which the target object to be
    ## added/contained. This error is typically returned when adding an
    ## object of some @link SBase@endlink derived class with the required package
    ## to other @link SBase@endlink derived object, or when enabling the required
    ## package in the target object.  To avoid this error, the conflict of
    ## versions need to be avoided.

LIBSBML_PKG_CONFLICT = _libsbml.LIBSBML_PKG_CONFLICT
    ## @var long LIBSBML_PKG_CONFLICT
    ## @brief One of the possible libSBML package operation return codes.
    ##
    ## This code has the following meaning: another SBML package extension
    ## for the same URI has already been registered. This error is
    ## typically returned when adding a SBML package extension to the
    ## @link SBMLExtensionRegistry@endlink. To avoid this error, ensure that SBML
    ## package extensions are only registered once.

LIBSBML_CONV_INVALID_TARGET_NAMESPACE = _libsbml.LIBSBML_CONV_INVALID_TARGET_NAMESPACE
    ## @var long LIBSBML_CONV_INVALID_TARGET_NAMESPACE
    ## @brief One of the possible libSBML package operation return codes.
    ##
    ## This code has the following meaning: while attempting to convert the
    ## SBML document using @link SBMLLevelVersionConverter#convert()@endlink or
    ## related methods, the target namespace has been found to be invalid
    ## or unset.  (The function @link SBMLNamespaces#isValidCombination()@endlink
    ## may be useful in detecting this situation and preventing the error.)

LIBSBML_CONV_PKG_CONVERSION_NOT_AVAILABLE = _libsbml.LIBSBML_CONV_PKG_CONVERSION_NOT_AVAILABLE
    ## @var long LIBSBML_CONV_PKG_CONVERSION_NOT_AVAILABLE
    ## @brief One of the possible libSBML package operation return codes.
    ##
    ## This code has the following meaning: conversions involving SBML
    ## Level&nbsp;3 packages are not available in the given libSBML
    ## method. This error is typically returned when calling a converter
    ## that does not have the functionality to deal with SBML packages. To
    ## avoid this error, ensure that the requested {@link
    ## ConversionProperties} specifies packages.

LIBSBML_CONV_INVALID_SRC_DOCUMENT = _libsbml.LIBSBML_CONV_INVALID_SRC_DOCUMENT
    ## @var long LIBSBML_CONV_INVALID_SRC_DOCUMENT
    ## @brief One of the possible libSBML package operation return codes.
    ##
    ## This code has the following meaning: The document on which
    ## conversion is being requested is invalid and the requested
    ## conversion cannot be performed. This error is typically returned
    ## when a conversion routine has been given an invalid target document
    ## or the conversion requires a certain degree of validity that is not
    ## present in the document. To avoid this error use the {@link
    ## SBMLDocument#checkConsistency()} function to find and resolve errors
    ## before passing the document to a conversion method.

LIBSBML_CONV_CONVERSION_NOT_AVAILABLE = _libsbml.LIBSBML_CONV_CONVERSION_NOT_AVAILABLE
    ## @var long LIBSBML_CONV_CONVERSION_NOT_AVAILABLE
    ## @brief One of the possible libSBML package operation return codes.
    ##
    ## This code has the following meaning: conversion with the given
    ## properties is not yet available.

LIBSBML_CONV_PKG_CONSIDERED_UNKNOWN = _libsbml.LIBSBML_CONV_PKG_CONSIDERED_UNKNOWN
    ## @var long LIBSBML_CONV_PKG_CONSIDERED_UNKNOWN
    ## @brief The package that is being stripped is not an enabled package
    ## but considered by libSBML to be an unrecognized package.
    ##
    ## This error is typically returned when calling the StripPackage
    ## converter requesting that a package for which code is not available be
    ## stripped. Thus the containing document will not be altered as the
    ## elements and attributes for this package are stored as unknown package
    ## information and will be written out as such.

CNV_TYPE_BOOL = _libsbml.CNV_TYPE_BOOL
    ## @var long CNV_TYPE_BOOL
    ## @brief One of the possible ConversionOption data type indicators.
    ##
    ## Indicates the value type is a Boolean.

CNV_TYPE_DOUBLE = _libsbml.CNV_TYPE_DOUBLE
    ## @var long CNV_TYPE_DOUBLE
    ## @brief One of the possible ConversionOption data type indicators.
    ##
    ## Indicates the value type is a double-sized float.

CNV_TYPE_INT = _libsbml.CNV_TYPE_INT
    ## @var long CNV_TYPE_INT
    ## @brief One of the possible ConversionOption data type indicators.
    ##
    ## Indicates the value type is an integer.

CNV_TYPE_SINGLE = _libsbml.CNV_TYPE_SINGLE
    ## @var long CNV_TYPE_SINGLE
    ## @brief One of the possible ConversionOption data type indicators.
    ##
    ## Indicates the value type is a float.

CNV_TYPE_STRING = _libsbml.CNV_TYPE_STRING
    ## @var long CNV_TYPE_STRING
    ## @brief One of the possible ConversionOption data type indicators.
    ##
    ## Indicates the value type is a string.

LIBSBML_DOTTED_VERSION = _libsbml.LIBSBML_DOTTED_VERSION
    ## @var long LIBSBML_DOTTED_VERSION
    ## @brief A version string of the form "1.2.3".

LIBSBML_VERSION = _libsbml.LIBSBML_VERSION
    ## @var long LIBSBML_VERSION
    ## 
    ## The version as an integer: version 1.2.3 becomes 10203.  Since the major
    ## number comes first, the overall number will always increase when a new
    ## libSBML is released, making it easy to use less-than and greater-than
    ## comparisons when testing versions numbers.

LIBSBML_VERSION_STRING = _libsbml.LIBSBML_VERSION_STRING
    ## @var long LIBSBML_DOTTED_VERSION
    ## @brief The numeric version as a string: version 1.2.3 becomes "10203".


    ## SBMLCompTypeCode_t 

SBML_COMP_SUBMODEL = _libsbml.SBML_COMP_SUBMODEL
    ## @var long SBML_COMP_SUBMODEL
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Hierarchical Model
    ## Composition (&ldquo;comp&rdquo;) package.  It is used to identify
    ## the type of SBML component to which a given object corresponds.

    
SBML_COMP_MODELDEFINITION = _libsbml.SBML_COMP_MODELDEFINITION
    ## @var long SBML_COMP_MODELDEFINITION
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Hierarchical Model
    ## Composition (&ldquo;comp&rdquo;) package.  It is used to identify
    ## the type of SBML component to which a given object corresponds.


SBML_COMP_EXTERNALMODELDEFINITION = _libsbml.SBML_COMP_EXTERNALMODELDEFINITION
    ## @var long SBML_COMP_EXTERNALMODELDEFINITION
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Hierarchical Model
    ## Composition (&ldquo;comp&rdquo;) package.  It is used to identify
    ## the type of SBML component to which a given object corresponds.


SBML_COMP_SBASEREF = _libsbml.SBML_COMP_SBASEREF
    ## @var long SBML_COMP_SBASEREF
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Hierarchical Model
    ## Composition (&ldquo;comp&rdquo;) package.  It is used to identify
    ## the type of SBML component to which a given object corresponds.

    
SBML_COMP_DELETION = _libsbml.SBML_COMP_DELETION
    ## @var long SBML_COMP_DELETION
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Hierarchical Model
    ## Composition (&ldquo;comp&rdquo;) package.  It is used to identify
    ## the type of SBML component to which a given object corresponds.

    
SBML_COMP_REPLACEDELEMENT = _libsbml.SBML_COMP_REPLACEDELEMENT
    ## <span class="pkg-marker pkg-color-comp">comp</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Hierarchical Model
    ## Composition (&ldquo;comp&rdquo;) package.  It is used to identify
    ## the type of SBML component to which a given object corresponds.

SBML_COMP_REPLACEDBY = _libsbml.SBML_COMP_REPLACEDBY
    ## @var long SBML_COMP_REPLACEDBY
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Hierarchical Model
    ## Composition (&ldquo;comp&rdquo;) package.  It is used to identify
    ## the type of SBML component to which a given object corresponds.

    
SBML_COMP_PORT = _libsbml.SBML_COMP_PORT
    ## @var long SBML_COMP_PORT
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Hierarchical Model
    ## Composition (&ldquo;comp&rdquo;) package.  It is used to identify
    ## the type of SBML component to which a given object corresponds.


    ## SBMLFbcTypeCode_t 

    
SBML_FBC_ASSOCIATION = _libsbml.SBML_FBC_ASSOCIATION
    ## @var long SBML_FBC_ASSOCIATION
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Flux Balance Constraints
    ## (&ldquo;fbc&rdquo;) package.  It is used to identify the type of SBML
    ## component to which a given object corresponds.

    
SBML_FBC_FLUXBOUND = _libsbml.SBML_FBC_FLUXBOUND
    ## @var long SBML_FBC_FLUXBOUND
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Flux Balance Constraints
    ## (&ldquo;fbc&rdquo;) package.  It is used to identify the type of SBML
    ## component to which a given object corresponds.

    
SBML_FBC_FLUXOBJECTIVE = _libsbml.SBML_FBC_FLUXOBJECTIVE
    ## @var long SBML_FBC_FLUXOBJECTIVE
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Flux Balance Constraints
    ## (&ldquo;fbc&rdquo;) package.  It is used to identify the type of SBML
    ## component to which a given object corresponds.

    
SBML_FBC_GENEASSOCIATION = _libsbml.SBML_FBC_GENEASSOCIATION
    ## @var long SBML_FBC_GENEASSOCIATION
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Flux Balance Constraints
    ## (&ldquo;fbc&rdquo;) package.  It is used to identify the type of SBML
    ## component to which a given object corresponds.

    
SBML_FBC_OBJECTIVE = _libsbml.SBML_FBC_OBJECTIVE
    ## @var long SBML_FBC_OBJECTIVE
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Flux Balance Constraints
    ## (&ldquo;fbc&rdquo;) package.  It is used to identify the type of SBML
    ## component to which a given object corresponds.

    ## AssociationTypeCode_t 

    
GENE_ASSOCIATION = _libsbml.GENE_ASSOCIATION
    ## @var long GENE_ASSOCIATION
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible Association types.
    ## 
    ## The Association class is not part of the official SBML Level&nbsp;3
    ## Flux Balance Constraints specification, but is instead a proposed
    ## future development of the package.  If adopted, it would be a child of
    ## a GeneAssociation that would describe a single 'and' or 'or'
    ## relationship between two or more genes or other associations.
    ## 
    ## The present code is one of the possible Association types for this
    ## proposed SBML Level&nbsp;3 Flux Balance Constraints
    ## (&ldquo;fbc&rdquo;) package future development.  

    
AND_ASSOCIATION = _libsbml.AND_ASSOCIATION
    ## @var long AND_ASSOCIATION
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible Association types.
    ## 
    ## The Association class is not part of the official SBML Level&nbsp;3
    ## Flux Balance Constraints specification, but is instead a proposed
    ## future development of the package.  If adopted, it would be a child of
    ## a GeneAssociation that would describe a single 'and' or 'or'
    ## relationship between two or more genes or other associations.
    ## 
    ## The present code is one of the possible Association types for this
    ## proposed SBML Level&nbsp;3 Flux Balance Constraints
    ## (&ldquo;fbc&rdquo;) package future development.  

    
OR_ASSOCIATION = _libsbml.OR_ASSOCIATION
    ## @var long OR_ASSOCIATION
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible Association types.
    ## 
    ## The Association class is not part of the official SBML Level&nbsp;3
    ## Flux Balance Constraints specification, but is instead a proposed
    ## future development of the package.  If adopted, it would be a child of
    ## a GeneAssociation that would describe a single 'and' or 'or'
    ## relationship between two or more genes or other associations.
    ## 
    ## The present code is one of the possible Association types for this
    ## proposed SBML Level&nbsp;3 Flux Balance Constraints
    ## (&ldquo;fbc&rdquo;) package future development.  

    
UNKNOWN_ASSOCIATION = _libsbml.UNKNOWN_ASSOCIATION
    ## @var long UNKNOWN_ASSOCIATION
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible Association types.
    ## 
    ## The Association class is not part of the official SBML Level&nbsp;3
    ## Flux Balance Constraints specification, but is instead a proposed
    ## future development of the package.  If adopted, it would be a child of
    ## a GeneAssociation that would describe a single 'and' or 'or'
    ## relationship between two or more genes or other associations.
    ## 
    ## The present code is one of the possible Association types for this
    ## proposed SBML Level&nbsp;3 Flux Balance Constraints
    ## (&ldquo;fbc&rdquo;) package future development.  


    ## FluxBoundOperation_t 

    
FLUXBOUND_OPERATION_LESS_EQUAL = _libsbml.FLUXBOUND_OPERATION_LESS_EQUAL
    ## @var long FLUXBOUND_OPERATION_LESS_EQUAL
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible FluxBound operation types.
    ## 
    ## The FluxBound class is part of the SBML Level&nbsp;3 Flux Balanced
    ## Constraints package.  Its purpose is to to hold a single equality or
    ## inequality that represents the maximum or minimum value a reaction
    ## flux can obtain at steady state.  One of the attributes of FluxBound
    ## is "operation".  This code is one of the possible values of the
    ## "operation" attribute.  The possible legal values are less than or
    ## equal to, greater than or equal to, or equal to.  The additional two
    ## options "less than" and "greater than" are not legal values for the
    ## FluxBound "operation" attribute, but are provided to allow backwards
    ## compatibility with an earlier version of the draft specification.

    
FLUXBOUND_OPERATION_GREATER_EQUAL = _libsbml.FLUXBOUND_OPERATION_GREATER_EQUAL
    ## @var long FLUXBOUND_OPERATION_GREATER_EQUAL
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible FluxBound operation types.
    ## 
    ## The FluxBound class is part of the SBML Level&nbsp;3 Flux Balanced
    ## Constraints package.  Its purpose is to to hold a single equality or
    ## inequality that represents the maximum or minimum value a reaction
    ## flux can obtain at steady state.  One of the attributes of FluxBound
    ## is "operation".  This code is one of the possible values of the
    ## "operation" attribute.  The possible legal values are less than or
    ## equal to, greater than or equal to, or equal to.  The additional two
    ## options "less than" and "greater than" are not legal values for the
    ## FluxBound "operation" attribute, but are provided to allow backwards
    ## compatibility with an earlier version of the draft specification.

    
FLUXBOUND_OPERATION_LESS = _libsbml.FLUXBOUND_OPERATION_LESS
    ## @var long FLUXBOUND_OPERATION_LESS
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible FluxBound operation types.
    ## 
    ## The FluxBound class is part of the SBML Level&nbsp;3 Flux Balanced
    ## Constraints package.  Its purpose is to to hold a single equality or
    ## inequality that represents the maximum or minimum value a reaction
    ## flux can obtain at steady state.  One of the attributes of FluxBound
    ## is "operation".  This code is one of the possible values of the
    ## "operation" attribute.  The possible legal values are less than or
    ## equal to, greater than or equal to, or equal to.  The additional two
    ## options "less than" and "greater than" are not legal values for the
    ## FluxBound "operation" attribute, but are provided to allow backwards
    ## compatibility with an earlier version of the draft specification.

    
FLUXBOUND_OPERATION_GREATER = _libsbml.FLUXBOUND_OPERATION_GREATER
    ## @var long FLUXBOUND_OPERATION_GREATER
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible FluxBound operation types.
    ## 
    ## The FluxBound class is part of the SBML Level&nbsp;3 Flux Balanced
    ## Constraints package.  Its purpose is to to hold a single equality or
    ## inequality that represents the maximum or minimum value a reaction
    ## flux can obtain at steady state.  One of the attributes of FluxBound
    ## is "operation".  This code is one of the possible values of the
    ## "operation" attribute.  The possible legal values are less than or
    ## equal to, greater than or equal to, or equal to.  The additional two
    ## options "less than" and "greater than" are not legal values for the
    ## FluxBound "operation" attribute, but are provided to allow backwards
    ## compatibility with an earlier version of the draft specification.

    
FLUXBOUND_OPERATION_EQUAL = _libsbml.FLUXBOUND_OPERATION_EQUAL
    ## @var long FLUXBOUND_OPERATION_EQUAL
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible FluxBound operation types.
    ## 
    ## The FluxBound class is part of the SBML Level&nbsp;3 Flux Balanced
    ## Constraints package.  Its purpose is to to hold a single equality or
    ## inequality that represents the maximum or minimum value a reaction
    ## flux can obtain at steady state.  One of the attributes of FluxBound
    ## is "operation".  This code is one of the possible values of the
    ## "operation" attribute.  The possible legal values are less than or
    ## equal to, greater than or equal to, or equal to.  The additional two
    ## options "less than" and "greater than" are not legal values for the
    ## FluxBound "operation" attribute, but are provided to allow backwards
    ## compatibility with an earlier version of the draft specification.

    
FLUXBOUND_OPERATION_UNKNOWN = _libsbml.FLUXBOUND_OPERATION_UNKNOWN
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible FluxBound operation types.
    ## 
    ## The FluxBound class is part of the SBML Level&nbsp;3 Flux Balanced
    ## Constraints package.  Its purpose is to to hold a single equality or
    ## inequality that represents the maximum or minimum value a reaction
    ## flux can obtain at steady state.  One of the attributes of FluxBound
    ## is "operation".  This code is one of the possible values of the
    ## "operation" attribute.  The possible legal values are less than or
    ## equal to, greater than or equal to, or equal to.  The additional two
    ## options "less than" and "greater than" are not legal values for the
    ## FluxBound "operation" attribute, but are provided to allow backwards
    ## compatibility with an earlier version of the draft specification.

    ## ObjectiveType_t 

    
OBJECTIVE_TYPE_MAXIMIZE = _libsbml.OBJECTIVE_TYPE_MAXIMIZE
    ## @var long OBJECTIVE_TYPE_MAXIMIZE
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible Objective types.
    ## 
    ## The Objective class is part of the SBML Level&nbsp;3 Flux Balanced
    ## Constraints package.  Its purpose is to represent the so-called
    ## <em>objective function</em>, which generally consist of a linear
    ## combination ofmodel variables (fluxes) and a sense (direction).  The
    ## Objective class has a "type" attribute, and the present code is one of
    ## possible type values.
    ##


    
OBJECTIVE_TYPE_MINIMIZE = _libsbml.OBJECTIVE_TYPE_MINIMIZE
    ## @var long OBJECTIVE_TYPE_MINIMIZE
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible Objective types.
    ## 
    ## The Objective class is part of the SBML Level&nbsp;3 Flux Balanced
    ## Constraints package.  Its purpose is to represent the so-called
    ## <em>objective function</em>, which generally consist of a linear
    ## combination ofmodel variables (fluxes) and a sense (direction).  The
    ## Objective class has a "type" attribute, and the present code is one of
    ## possible type values.
    ##


    
OBJECTIVE_TYPE_UNKNOWN = _libsbml.OBJECTIVE_TYPE_UNKNOWN
    ## @var long OBJECTIVE_TYPE_UNKNOWN
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> One of the
    ## possible Objective types.
    ## 
    ## The Objective class is part of the SBML Level&nbsp;3 Flux Balanced
    ## Constraints package.  Its purpose is to represent the so-called
    ## <em>objective function</em>, which generally consist of a linear
    ## combination ofmodel variables (fluxes) and a sense (direction).  The
    ## Objective class has a "type" attribute, and the present code is one of
    ## possible type values.
    ##


    ## SBMLLayoutTypeCode_t 

    
SBML_LAYOUT_BOUNDINGBOX = _libsbml.SBML_LAYOUT_BOUNDINGBOX
    ## @var long SBML_LAYOUT_BOUNDINGBOX
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_COMPARTMENTGLYPH = _libsbml.SBML_LAYOUT_COMPARTMENTGLYPH
    ## @var long SBML_LAYOUT_COMPARTMENTGLYPH
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_CUBICBEZIER = _libsbml.SBML_LAYOUT_CUBICBEZIER
    ## @var long SBML_LAYOUT_CUBICBEZIER
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_CURVE = _libsbml.SBML_LAYOUT_CURVE
    ## @var long SBML_LAYOUT_CURVE
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_DIMENSIONS = _libsbml.SBML_LAYOUT_DIMENSIONS
    ## @var long SBML_LAYOUT_DIMENSIONS
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_GRAPHICALOBJECT = _libsbml.SBML_LAYOUT_GRAPHICALOBJECT
    ## @var long SBML_LAYOUT_GRAPHICALOBJECT
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_LAYOUT = _libsbml.SBML_LAYOUT_LAYOUT
    ## @var long SBML_LAYOUT_LAYOUT
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_LINESEGMENT = _libsbml.SBML_LAYOUT_LINESEGMENT
    ## @var long SBML_LAYOUT_LINESEGMENT
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_POINT = _libsbml.SBML_LAYOUT_POINT
    ## @var long SBML_LAYOUT_POINT
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_REACTIONGLYPH = _libsbml.SBML_LAYOUT_REACTIONGLYPH
    ## @var long SBML_LAYOUT_REACTIONGLYPH
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_SPECIESGLYPH = _libsbml.SBML_LAYOUT_SPECIESGLYPH
    ## @var long SBML_LAYOUT_SPECIESGLYPH
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_SPECIESREFERENCEGLYPH = _libsbml.SBML_LAYOUT_SPECIESREFERENCEGLYPH
    ## @var long SBML_LAYOUT_SPECIESREFERENCEGLYPH
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_TEXTGLYPH = _libsbml.SBML_LAYOUT_TEXTGLYPH
    ## @var long SBML_LAYOUT_TEXTGLYPH
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_REFERENCEGLYPH = _libsbml.SBML_LAYOUT_REFERENCEGLYPH
    ## @var long SBML_LAYOUT_REFERENCEGLYPH
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_LAYOUT_GENERALGLYPH = _libsbml.SBML_LAYOUT_GENERALGLYPH
    ## @var long SBML_LAYOUT_GENERALGLYPH
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Layout
    ## (&ldquo;layout&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    ## SpeciesReferenceRole_t 

    
SPECIES_ROLE_UNDEFINED = _libsbml.SPECIES_ROLE_UNDEFINED
    ## @var long SPECIES_ROLE_UNDEFINED
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible roles of a SpeciesReferenceGlyph.
    ## 
    ## SpeciesReferenceGlyphs include an attribute to describe the role of a
    ## given SpeciesReference in a model diagram.  The present code is one of
    ## the possible values for this role attribute.
    ##


    
SPECIES_ROLE_SUBSTRATE = _libsbml.SPECIES_ROLE_SUBSTRATE
    ## @var long SPECIES_ROLE_SUBSTRATE
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible roles of a SpeciesReferenceGlyph.
    ## 
    ## SpeciesReferenceGlyphs include an attribute to describe the role of a
    ## given SpeciesReference in a model diagram.  The present code is one of
    ## the possible values for this role attribute.
    ##


    
SPECIES_ROLE_PRODUCT = _libsbml.SPECIES_ROLE_PRODUCT
    ## @var long SPECIES_ROLE_PRODUCT
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible roles of a SpeciesReferenceGlyph.
    ## 
    ## SpeciesReferenceGlyphs include an attribute to describe the role of a
    ## given SpeciesReference in a model diagram.  The present code is one of
    ## the possible values for this role attribute.
    ##


    
SPECIES_ROLE_SIDESUBSTRATE = _libsbml.SPECIES_ROLE_SIDESUBSTRATE
    ## @var long SPECIES_ROLE_SIDESUBSTRATE
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible roles of a SpeciesReferenceGlyph.
    ## 
    ## SpeciesReferenceGlyphs include an attribute to describe the role of a
    ## given SpeciesReference in a model diagram.  The present code is one of
    ## the possible values for this role attribute.
    ##


    
SPECIES_ROLE_SIDEPRODUCT = _libsbml.SPECIES_ROLE_SIDEPRODUCT
    ## @var long SPECIES_ROLE_SIDEPRODUCT
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible roles of a SpeciesReferenceGlyph.
    ## 
    ## SpeciesReferenceGlyphs include an attribute to describe the role of a
    ## given SpeciesReference in a model diagram.  The present code is one of
    ## the possible values for this role attribute.
    ##


    
SPECIES_ROLE_MODIFIER = _libsbml.SPECIES_ROLE_MODIFIER
    ## @var long SPECIES_ROLE_MODIFIER
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible roles of a SpeciesReferenceGlyph.
    ## 
    ## SpeciesReferenceGlyphs include an attribute to describe the role of a
    ## given SpeciesReference in a model diagram.  The present code is one of
    ## the possible values for this role attribute.
    ##


    
SPECIES_ROLE_ACTIVATOR = _libsbml.SPECIES_ROLE_ACTIVATOR
    ## @var long SPECIES_ROLE_ACTIVATOR
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible roles of a SpeciesReferenceGlyph.
    ## 
    ## SpeciesReferenceGlyphs include an attribute to describe the role of a
    ## given SpeciesReference in a model diagram.  The present code is one of
    ## the possible values for this role attribute.
    ##


    
SPECIES_ROLE_INHIBITOR = _libsbml.SPECIES_ROLE_INHIBITOR
    ## @var long SPECIES_ROLE_INHIBITOR
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> One of the
    ## possible roles of a SpeciesReferenceGlyph.
    ## 
    ## SpeciesReferenceGlyphs include an attribute to describe the role of a
    ## given SpeciesReference in a model diagram.  The present code is one of
    ## the possible values for this role attribute.
    ##


    ## SBMLQualTypeCode_t 

    
SBML_QUAL_QUALITATIVE_SPECIES = _libsbml.SBML_QUAL_QUALITATIVE_SPECIES
    ## @var long SBML_QUAL_QUALITATIVE_SPECIES
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Qualitative Models
    ## (&ldquo;qual&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_QUAL_TRANSITION = _libsbml.SBML_QUAL_TRANSITION
    ## @var long SBML_QUAL_TRANSITION
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Qualitative Models
    ## (&ldquo;qual&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_QUAL_INPUT = _libsbml.SBML_QUAL_INPUT
    ## @var long SBML_QUAL_INPUT
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Qualitative Models
    ## (&ldquo;qual&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_QUAL_OUTPUT = _libsbml.SBML_QUAL_OUTPUT
    ## @var long SBML_QUAL_OUTPUT
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Qualitative Models
    ## (&ldquo;qual&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_QUAL_FUNCTION_TERM = _libsbml.SBML_QUAL_FUNCTION_TERM
    ## @var long SBML_QUAL_FUNCTION_TERM
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Qualitative Models
    ## (&ldquo;qual&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    
SBML_QUAL_DEFAULT_TERM = _libsbml.SBML_QUAL_DEFAULT_TERM
    ## @var long SBML_QUAL_DEFAULT_TERM
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible SBML component type codes.
    ## 
    ## LibSBML attaches an identifying code to every kind of SBML object.
    ## These are known as <em>SBML type codes</em>.  In other languages,
    ## the set of type codes is stored in an enumeration; in the Java
    ## language interface for libSBML, the type codes are defined as static
    ## integer constants in the interface class @link libsbml libsbml@endlink.
    ## The names of the type codes all begin with the characters
    ## <code>SBML_</code>.
    ## 
    ## Each libSBML extension for SBML Level&nbsp;3 packages adds its own
    ## type codes to objects.  The present type code belongs to libSBML's
    ## extension to support the SBML Level&nbsp;3 Qualitative Models
    ## (&ldquo;qual&rdquo;) package.  It is used to identify the type of
    ## SBML component to which a given object corresponds.
    ##


    ## InputTransitionEffect_t 

    
INPUT_TRANSITION_EFFECT_NONE = _libsbml.INPUT_TRANSITION_EFFECT_NONE
    ## @var long INPUT_TRANSITION_EFFECT_NONE
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible Input transition effects.
    ## 
    ## The Input class is part of the SBML Level&nbsp;3 Qualitative Models
    ## package.  Its purpose is to represent a qualitative species that
    ## participates in a Transition; specifically, in Petri nets, these are
    ## the input places of the transition, and in logical models, they are
    ## the regulators of the species whose behaviour is defined by the
    ## transition.  Input has an attribute named "transitionEffect" that 
    ## is used to describe how the QualitativeSpecies referenced by the
    ## Input is affected by the Transition.
    ## 
    ## The present code is one of the possible values of the
    ## "transitionEffect" attribute of an Input object.
    ##


    
INPUT_TRANSITION_EFFECT_CONSUMPTION = _libsbml.INPUT_TRANSITION_EFFECT_CONSUMPTION
    ## @var long INPUT_TRANSITION_EFFECT_CONSUMPTION
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible Input transition effects.
    ## 
    ## The Input class is part of the SBML Level&nbsp;3 Qualitative Models
    ## package.  Its purpose is to represent a qualitative species that
    ## participates in a Transition; specifically, in Petri nets, these are
    ## the input places of the transition, and in logical models, they are
    ## the regulators of the species whose behaviour is defined by the
    ## transition.  Input has an attribute named "transitionEffect" that 
    ## is used to describe how the QualitativeSpecies referenced by the
    ## Input is affected by the Transition.
    ## 
    ## The present code is one of the possible values of the
    ## "transitionEffect" attribute of an Input object.
    ##


    
INPUT_TRANSITION_EFFECT_UNKNOWN = _libsbml.INPUT_TRANSITION_EFFECT_UNKNOWN
    ## @var long INPUT_TRANSITION_EFFECT_UNKNOWN
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible Input transition effects.
    ## 
    ## The Input class is part of the SBML Level&nbsp;3 Qualitative Models
    ## package.  Its purpose is to represent a qualitative species that
    ## participates in a Transition; specifically, in Petri nets, these are
    ## the input places of the transition, and in logical models, they are
    ## the regulators of the species whose behaviour is defined by the
    ## transition.  Input has an attribute named "transitionEffect" that 
    ## is used to describe how the QualitativeSpecies referenced by the
    ## Input is affected by the Transition.
    ## 
    ## The present code is one of the possible values of the
    ## "transitionEffect" attribute of an Input object.
    ##

    ## InputSign_t 

    
INPUT_SIGN_POSITIVE = _libsbml.INPUT_SIGN_POSITIVE
    ## @var long INPUT_SIGN_POSITIVE
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible Input "sign" attribute values.
    ## 
    ## The Input class is part of the SBML Level&nbsp;3 Qualitative Models
    ## package.  Its purpose is to represent a qualitative species that
    ## participates in a Transition; specifically, in Petri nets, these are
    ## the input places of the transition, and in logical models, they are
    ## the regulators of the species whose behaviour is defined by the
    ## transition.  Input has an attribute named "sign" that is used to
    ## indicate whether the contribution of this input is positive, negative,
    ## both (dual) or unknown. This enables a model to distinguish between
    ## stimulation and inhibition and can facilitate interpretation of
    ## themodel without the mathematics. The sign is particularly used for
    ## visualization purposes and has no impact on the mathematical
    ## interpretation.
    ## 
    ## The present code is one of the possible values of the "sign" attribute
    ## of an Input object.
    ##


    
INPUT_SIGN_NEGATIVE = _libsbml.INPUT_SIGN_NEGATIVE
    ## @var long INPUT_SIGN_NEGATIVE
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible Input "sign" attribute values.
    ## 
    ## The Input class is part of the SBML Level&nbsp;3 Qualitative Models
    ## package.  Its purpose is to represent a qualitative species that
    ## participates in a Transition; specifically, in Petri nets, these are
    ## the input places of the transition, and in logical models, they are
    ## the regulators of the species whose behaviour is defined by the
    ## transition.  Input has an attribute named "sign" that is used to
    ## indicate whether the contribution of this input is positive, negative,
    ## both (dual) or unknown. This enables a model to distinguish between
    ## stimulation and inhibition and can facilitate interpretation of
    ## themodel without the mathematics. The sign is particularly used for
    ## visualization purposes and has no impact on the mathematical
    ## interpretation.
    ## 
    ## The present code is one of the possible values of the "sign" attribute
    ## of an Input object.
    ##


    
INPUT_SIGN_DUAL = _libsbml.INPUT_SIGN_DUAL
    ## @var long INPUT_SIGN_DUAL
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible Input "sign" attribute values.
    ## 
    ## The Input class is part of the SBML Level&nbsp;3 Qualitative Models
    ## package.  Its purpose is to represent a qualitative species that
    ## participates in a Transition; specifically, in Petri nets, these are
    ## the input places of the transition, and in logical models, they are
    ## the regulators of the species whose behaviour is defined by the
    ## transition.  Input has an attribute named "sign" that is used to
    ## indicate whether the contribution of this input is positive, negative,
    ## both (dual) or unknown. This enables a model to distinguish between
    ## stimulation and inhibition and can facilitate interpretation of
    ## themodel without the mathematics. The sign is particularly used for
    ## visualization purposes and has no impact on the mathematical
    ## interpretation.
    ## 
    ## The present code is one of the possible values of the "sign" attribute
    ## of an Input object.
    ##


    
INPUT_SIGN_UNKNOWN = _libsbml.INPUT_SIGN_UNKNOWN
    ## @var long INPUT_SIGN_UNKNOWN
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible Input "sign" attribute values.
    ## 
    ## The Input class is part of the SBML Level&nbsp;3 Qualitative Models
    ## package.  Its purpose is to represent a qualitative species that
    ## participates in a Transition; specifically, in Petri nets, these are
    ## the input places of the transition, and in logical models, they are
    ## the regulators of the species whose behaviour is defined by the
    ## transition.  Input has an attribute named "sign" that is used to
    ## indicate whether the contribution of this input is positive, negative,
    ## both (dual) or unknown. This enables a model to distinguish between
    ## stimulation and inhibition and can facilitate interpretation of
    ## themodel without the mathematics. The sign is particularly used for
    ## visualization purposes and has no impact on the mathematical
    ## interpretation.
    ## 
    ## The present code is one of the possible values of the "sign" attribute
    ## of an Input object.
    ##


    
INPUT_SIGN_VALUE_NOTSET = _libsbml.INPUT_SIGN_VALUE_NOTSET
    ## @var long INPUT_SIGN_VALUE_NOTSET
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible Input "sign" attribute values.
    ## 
    ## The Input class is part of the SBML Level&nbsp;3 Qualitative Models
    ## package.  Its purpose is to represent a qualitative species that
    ## participates in a Transition; specifically, in Petri nets, these are
    ## the input places of the transition, and in logical models, they are
    ## the regulators of the species whose behaviour is defined by the
    ## transition.  Input has an attribute named "sign" that is used to
    ## indicate whether the contribution of this input is positive, negative,
    ## both (dual) or unknown. This enables a model to distinguish between
    ## stimulation and inhibition and can facilitate interpretation of
    ## themodel without the mathematics. The sign is particularly used for
    ## visualization purposes and has no impact on the mathematical
    ## interpretation.
    ## 
    ## The present code is one of the possible values of the "sign" attribute
    ## of an Input object.
    ##


    ## OutputTransitionEffect_t 

    
OUTPUT_TRANSITION_EFFECT_PRODUCTION = _libsbml.OUTPUT_TRANSITION_EFFECT_PRODUCTION
    ## @var long OUTPUT_TRANSITION_EFFECT_PRODUCTION
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible OutputTransition "transitionEffect" attribute values.
    ## 
    ## The OutputTransition class is part of the SBML Level&nbsp;3
    ## Qualitative Models package.  Its purpose is to represent a qualitative
    ## species that is affected by a Transition.  (In Petri net models, these
    ## are the output places of the transition.)  OutputTransition has an
    ## attribute named "transitionEffect" that is used to describe how the
    ## QualitativeSpecies referenced by the Output is affected by the
    ## Transition.
    ##
    ## The present code is one of the possible values of the
    ## "transitionEffect" attribute of an OutputTransition object.
    ##


    
OUTPUT_TRANSITION_EFFECT_ASSIGNMENT_LEVEL = _libsbml.OUTPUT_TRANSITION_EFFECT_ASSIGNMENT_LEVEL
    ## @var long OUTPUT_TRANSITION_EFFECT_ASSIGNMENT_LEVEL
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible OutputTransition "transitionEffect" attribute values.
    ## 
    ## The OutputTransition class is part of the SBML Level&nbsp;3
    ## Qualitative Models package.  Its purpose is to represent a qualitative
    ## species that is affected by a Transition.  (In Petri net models, these
    ## are the output places of the transition.)  OutputTransition has an
    ## attribute named "transitionEffect" that is used to describe how the
    ## QualitativeSpecies referenced by the Output is affected by the
    ## Transition.
    ##
    ## The present code is one of the possible values of the
    ## "transitionEffect" attribute of an OutputTransition object.
    ##


    
OUTPUT_TRANSITION_EFFECT_UNKNOWN = _libsbml.OUTPUT_TRANSITION_EFFECT_UNKNOWN
    ## @var long OUTPUT_TRANSITION_EFFECT_UNKNOWN
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> One of the
    ## possible OutputTransition "transitionEffect" attribute values.
    ## 
    ## The OutputTransition class is part of the SBML Level&nbsp;3
    ## Qualitative Models package.  Its purpose is to represent a qualitative
    ## species that is affected by a Transition.  (In Petri net models, these
    ## are the output places of the transition.)  OutputTransition has an
    ## attribute named "transitionEffect" that is used to describe how the
    ## QualitativeSpecies referenced by the Output is affected by the
    ## Transition.
    ##     
    ## The present code is one of the possible values of the
    ## "transitionEffect" attribute of an OutputTransition object.
    ##


    ## CompSBMLErrorCode_t 

    
CompUnknown = _libsbml.CompUnknown
    ## @var long CompUnknown
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompNSUndeclared = _libsbml.CompNSUndeclared
    ## @var long CompNSUndeclared
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompElementNotInNs = _libsbml.CompElementNotInNs
    ## @var long CompElementNotInNs
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompDuplicateComponentId = _libsbml.CompDuplicateComponentId
    ## @var long CompDuplicateComponentId
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##

    
CompUniqueModelIds = _libsbml.CompUniqueModelIds
    ## @var long CompUniqueModelIds
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompUniquePortIds = _libsbml.CompUniquePortIds
    ## @var long CompUniquePortIds
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidSIdSyntax = _libsbml.CompInvalidSIdSyntax
    ## @var long CompInvalidSIdSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidSubmodelRefSyntax = _libsbml.CompInvalidSubmodelRefSyntax
    ## @var long CompInvalidSubmodelRefSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidDeletionSyntax = _libsbml.CompInvalidDeletionSyntax
    ## @var long CompInvalidDeletionSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidConversionFactorSyntax = _libsbml.CompInvalidConversionFactorSyntax
    ## @var long CompInvalidConversionFactorSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidNameSyntax = _libsbml.CompInvalidNameSyntax
    ## @var long CompInvalidNameSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedUnitsShouldMatch = _libsbml.CompReplacedUnitsShouldMatch
    ## @var long CompReplacedUnitsShouldMatch
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompOneListOfReplacedElements = _libsbml.CompOneListOfReplacedElements
    ## @var long CompOneListOfReplacedElements
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLOReplaceElementsAllowedElements = _libsbml.CompLOReplaceElementsAllowedElements
    ## @var long CompLOReplaceElementsAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLOReplacedElementsAllowedAttribs = _libsbml.CompLOReplacedElementsAllowedAttribs
    ## @var long CompLOReplacedElementsAllowedAttribs
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompEmptyLOReplacedElements = _libsbml.CompEmptyLOReplacedElements
    ## @var long CompEmptyLOReplacedElements
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompOneReplacedByElement = _libsbml.CompOneReplacedByElement
    ## @var long CompOneReplacedByElement
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompAttributeRequiredMissing = _libsbml.CompAttributeRequiredMissing
    ## @var long CompAttributeRequiredMissing
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompAttributeRequiredMustBeBoolean = _libsbml.CompAttributeRequiredMustBeBoolean
    ## @var long CompAttributeRequiredMustBeBoolean
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompRequiredTrueIfElementsRemain = _libsbml.CompRequiredTrueIfElementsRemain
    ## @var long CompRequiredTrueIfElementsRemain
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompRequiredFalseIfAllElementsReplaced = _libsbml.CompRequiredFalseIfAllElementsReplaced
    ## @var long CompRequiredFalseIfAllElementsReplaced
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompOneListOfModelDefinitions = _libsbml.CompOneListOfModelDefinitions
    ## @var long CompOneListOfModelDefinitions
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompEmptyLOModelDefs = _libsbml.CompEmptyLOModelDefs
    ## @var long CompEmptyLOModelDefs
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLOModelDefsAllowedElements = _libsbml.CompLOModelDefsAllowedElements
    ## @var long CompLOModelDefsAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLOExtModelDefsAllowedElements = _libsbml.CompLOExtModelDefsAllowedElements
    ## @var long CompLOExtModelDefsAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLOModelDefsAllowedAttributes = _libsbml.CompLOModelDefsAllowedAttributes
    ## @var long CompLOModelDefsAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLOExtModDefsAllowedAttributes = _libsbml.CompLOExtModDefsAllowedAttributes
    ## @var long CompLOExtModDefsAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompOneListOfExtModelDefinitions = _libsbml.CompOneListOfExtModelDefinitions
    ## @var long CompOneListOfExtModelDefinitions
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompAttributeRequiredMustBeTrue = _libsbml.CompAttributeRequiredMustBeTrue
    ## @var long CompAttributeRequiredMustBeTrue
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompExtModDefAllowedCoreAttributes = _libsbml.CompExtModDefAllowedCoreAttributes
    ## @var long CompExtModDefAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompExtModDefAllowedElements = _libsbml.CompExtModDefAllowedElements
    ## @var long CompExtModDefAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompExtModDefAllowedAttributes = _libsbml.CompExtModDefAllowedAttributes
    ## @var long CompExtModDefAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReferenceMustBeL3 = _libsbml.CompReferenceMustBeL3
    ## @var long CompReferenceMustBeL3
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompModReferenceMustIdOfModel = _libsbml.CompModReferenceMustIdOfModel
    ## @var long CompModReferenceMustIdOfModel
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompExtModMd5DoesNotMatch = _libsbml.CompExtModMd5DoesNotMatch
    ## @var long CompExtModMd5DoesNotMatch
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidSourceSyntax = _libsbml.CompInvalidSourceSyntax
    ## @var long CompInvalidSourceSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidModelRefSyntax = _libsbml.CompInvalidModelRefSyntax
    ## @var long CompInvalidModelRefSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidMD5Syntax = _libsbml.CompInvalidMD5Syntax
    ## @var long CompInvalidMD5Syntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompCircularExternalModelReference = _libsbml.CompCircularExternalModelReference
    ## @var long CompCircularExternalModelReference
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompOneListOfOnModel = _libsbml.CompOneListOfOnModel
    ## @var long CompOneListOfOnModel
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompNoEmptyListOfOnModel = _libsbml.CompNoEmptyListOfOnModel
    ## @var long CompNoEmptyListOfOnModel
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLOSubmodelsAllowedElements = _libsbml.CompLOSubmodelsAllowedElements
    ## @var long CompLOSubmodelsAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLOPortsAllowedElements = _libsbml.CompLOPortsAllowedElements
    ## @var long CompLOPortsAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLOSubmodelsAllowedAttributes = _libsbml.CompLOSubmodelsAllowedAttributes
    ## @var long CompLOSubmodelsAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLOPortsAllowedAttributes = _libsbml.CompLOPortsAllowedAttributes
    ## @var long CompLOPortsAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompSubmodelAllowedCoreAttributes = _libsbml.CompSubmodelAllowedCoreAttributes
    ## @var long CompSubmodelAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompSubmodelAllowedElements = _libsbml.CompSubmodelAllowedElements
    ## @var long CompSubmodelAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompOneListOfDeletionOnSubmodel = _libsbml.CompOneListOfDeletionOnSubmodel
    ## @var long CompOneListOfDeletionOnSubmodel
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompSubmodelNoEmptyLODeletions = _libsbml.CompSubmodelNoEmptyLODeletions
    ## @var long CompSubmodelNoEmptyLODeletions
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLODeletionsAllowedElements = _libsbml.CompLODeletionsAllowedElements
    ## @var long CompLODeletionsAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLODeletionAllowedAttributes = _libsbml.CompLODeletionAllowedAttributes
    ## @var long CompLODeletionAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompSubmodelAllowedAttributes = _libsbml.CompSubmodelAllowedAttributes
    ## @var long CompSubmodelAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompModReferenceSyntax = _libsbml.CompModReferenceSyntax
    ## @var long CompModReferenceSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidTimeConvFactorSyntax = _libsbml.CompInvalidTimeConvFactorSyntax
    ## @var long CompInvalidTimeConvFactorSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidExtentConvFactorSyntax = _libsbml.CompInvalidExtentConvFactorSyntax
    ## @var long CompInvalidExtentConvFactorSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompSubmodelMustReferenceModel = _libsbml.CompSubmodelMustReferenceModel
    ## @var long CompSubmodelMustReferenceModel
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompSubmodelCannotReferenceSelf = _libsbml.CompSubmodelCannotReferenceSelf
    ## @var long CompSubmodelCannotReferenceSelf
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompModCannotCircularlyReferenceSelf = _libsbml.CompModCannotCircularlyReferenceSelf
    ## @var long CompModCannotCircularlyReferenceSelf
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompTimeConversionMustBeParameter = _libsbml.CompTimeConversionMustBeParameter
    ## @var long CompTimeConversionMustBeParameter
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompExtentConversionMustBeParameter = _libsbml.CompExtentConversionMustBeParameter
    ## @var long CompExtentConversionMustBeParameter
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompPortRefMustReferencePort = _libsbml.CompPortRefMustReferencePort
    ## @var long CompPortRefMustReferencePort
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompIdRefMustReferenceObject = _libsbml.CompIdRefMustReferenceObject
    ## @var long CompIdRefMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompUnitRefMustReferenceUnitDef = _libsbml.CompUnitRefMustReferenceUnitDef
    ## @var long CompUnitRefMustReferenceUnitDef
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompMetaIdRefMustReferenceObject = _libsbml.CompMetaIdRefMustReferenceObject
    ## @var long CompMetaIdRefMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompParentOfSBRefChildMustBeSubmodel = _libsbml.CompParentOfSBRefChildMustBeSubmodel
    ## @var long CompParentOfSBRefChildMustBeSubmodel
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidPortRefSyntax = _libsbml.CompInvalidPortRefSyntax
    ## @var long CompInvalidPortRefSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidIdRefSyntax = _libsbml.CompInvalidIdRefSyntax
    ## @var long CompInvalidIdRefSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidUnitRefSyntax = _libsbml.CompInvalidUnitRefSyntax
    ## @var long CompInvalidUnitRefSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompInvalidMetaIdRefSyntax = _libsbml.CompInvalidMetaIdRefSyntax
    ## @var long CompInvalidMetaIdRefSyntax
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompOneSBaseRefOnly = _libsbml.CompOneSBaseRefOnly
    ## @var long CompOneSBaseRefOnly
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompDeprecatedSBaseRefSpelling = _libsbml.CompDeprecatedSBaseRefSpelling
    ## @var long CompDeprecatedSBaseRefSpelling
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompSBaseRefMustReferenceObject = _libsbml.CompSBaseRefMustReferenceObject
    ## @var long CompSBaseRefMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompSBaseRefMustReferenceOnlyOneObject = _libsbml.CompSBaseRefMustReferenceOnlyOneObject
    ## @var long CompSBaseRefMustReferenceOnlyOneObject
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompNoMultipleReferences = _libsbml.CompNoMultipleReferences
    ## @var long CompNoMultipleReferences
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompPortMustReferenceObject = _libsbml.CompPortMustReferenceObject
    ## @var long CompPortMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompPortMustReferenceOnlyOneObject = _libsbml.CompPortMustReferenceOnlyOneObject
    ## @var long CompPortMustReferenceOnlyOneObject
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompPortAllowedAttributes = _libsbml.CompPortAllowedAttributes
    ## @var long CompPortAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompPortReferencesUnique = _libsbml.CompPortReferencesUnique
    ## @var long CompPortReferencesUnique
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompDeletionMustReferenceObject = _libsbml.CompDeletionMustReferenceObject
    ## @var long CompDeletionMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompDeletionMustReferOnlyOneObject = _libsbml.CompDeletionMustReferOnlyOneObject
    ## @var long CompDeletionMustReferOnlyOneObject
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompDeletionAllowedAttributes = _libsbml.CompDeletionAllowedAttributes
    ## @var long CompDeletionAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedElementMustRefObject = _libsbml.CompReplacedElementMustRefObject
    ## @var long CompReplacedElementMustRefObject
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedElementMustRefOnlyOne = _libsbml.CompReplacedElementMustRefOnlyOne
    ## @var long CompReplacedElementMustRefOnlyOne
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedElementAllowedAttributes = _libsbml.CompReplacedElementAllowedAttributes
    ## @var long CompReplacedElementAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedElementSubModelRef = _libsbml.CompReplacedElementSubModelRef
    ## @var long CompReplacedElementSubModelRef
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedElementDeletionRef = _libsbml.CompReplacedElementDeletionRef
    ## @var long CompReplacedElementDeletionRef
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedElementConvFactorRef = _libsbml.CompReplacedElementConvFactorRef
    ## @var long CompReplacedElementConvFactorRef
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedElementSameReference = _libsbml.CompReplacedElementSameReference
    ## @var long CompReplacedElementSameReference
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedElementNoDelAndConvFact = _libsbml.CompReplacedElementNoDelAndConvFact
    ## @var long CompReplacedElementNoDelAndConvFact
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedByMustRefObject = _libsbml.CompReplacedByMustRefObject
    ## @var long CompReplacedByMustRefObject
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedByMustRefOnlyOne = _libsbml.CompReplacedByMustRefOnlyOne
    ## @var long CompReplacedByMustRefOnlyOne
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedByAllowedAttributes = _libsbml.CompReplacedByAllowedAttributes
    ## @var long CompReplacedByAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompReplacedBySubModelRef = _libsbml.CompReplacedBySubModelRef
    ## @var long CompReplacedBySubModelRef
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompMustReplaceSameClass = _libsbml.CompMustReplaceSameClass
    ## @var long CompMustReplaceSameClass
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompMustReplaceIDs = _libsbml.CompMustReplaceIDs
    ## @var long CompMustReplaceIDs
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompMustReplaceMetaIDs = _libsbml.CompMustReplaceMetaIDs
    ## @var long CompMustReplaceMetaIDs
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompMustReplacePackageIDs = _libsbml.CompMustReplacePackageIDs
    ## @var long CompMustReplacePackageIDs
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompUnresolvedReference = _libsbml.CompUnresolvedReference
    ## @var long CompUnresolvedReference
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompNoModelInReference = _libsbml.CompNoModelInReference
    ## @var long CompNoModelInReference
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompExtModDefBad = _libsbml.CompExtModDefBad
    ## @var long CompExtModDefBad
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompModelFlatteningFailed = _libsbml.CompModelFlatteningFailed
    ## @var long CompModelFlatteningFailed
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompFlatModelNotValid = _libsbml.CompFlatModelNotValid
    ## @var long CompFlatModelNotValid
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompLineNumbersUnreliable = _libsbml.CompLineNumbersUnreliable
    ## @var long CompLineNumbersUnreliable
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompFlatteningNotRecognisedReqd = _libsbml.CompFlatteningNotRecognisedReqd
    ## @var long CompFlatteningNotRecognisedReqd
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompFlatteningNotRecognisedNotReqd = _libsbml.CompFlatteningNotRecognisedNotReqd
    ## @var long CompFlatteningNotRecognisedNotReqd
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompFlatteningNotImplementedNotReqd = _libsbml.CompFlatteningNotImplementedNotReqd
    ## @var long CompFlatteningNotImplementedNotReqd
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompFlatteningNotImplementedReqd = _libsbml.CompFlatteningNotImplementedReqd
    ## @var long CompFlatteningNotImplementedReqd
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompFlatteningWarning = _libsbml.CompFlatteningWarning
    ## @var long CompFlatteningWarning
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompDeprecatedDeleteFunction = _libsbml.CompDeprecatedDeleteFunction
    ## @var long CompDeprecatedDeleteFunction
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompDeprecatedReplaceFunction = _libsbml.CompDeprecatedReplaceFunction
    ## @var long CompDeprecatedReplaceFunction
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompDeletedReplacement = _libsbml.CompDeletedReplacement
    ## @var long CompDeletedReplacement
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompIdRefMayReferenceUnknownPackage = _libsbml.CompIdRefMayReferenceUnknownPackage
    ## @var long CompIdRefMayReferenceUnknownPackage
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
CompMetaIdRefMayReferenceUnknownPkg = _libsbml.CompMetaIdRefMayReferenceUnknownPkg
    ## @var long CompMetaIdRefMayReferenceUnknownPkg
    ##
    ## <span class="pkg-marker pkg-color-comp">comp</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;comp&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    ## FbcSBMLErrorCode_t 

    
FbcUnknown = _libsbml.FbcUnknown
    ## @var long FbcUnknown
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcNSUndeclared = _libsbml.FbcNSUndeclared
    ## @var long FbcNSUndeclared
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcElementNotInNs = _libsbml.FbcElementNotInNs
    ## @var long FbcElementNotInNs
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcDuplicateComponentId = _libsbml.FbcDuplicateComponentId
    ## @var long FbcDuplicateComponentId
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcSBMLSIdSyntax = _libsbml.FbcSBMLSIdSyntax
    ## @var long FbcSBMLSIdSyntax
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcAttributeRequiredMissing = _libsbml.FbcAttributeRequiredMissing
    ## @var long FbcAttributeRequiredMissing
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcAttributeRequiredMustBeBoolean = _libsbml.FbcAttributeRequiredMustBeBoolean
    ## @var long FbcAttributeRequiredMustBeBoolean
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcRequiredFalse = _libsbml.FbcRequiredFalse
    ## @var long FbcRequiredFalse
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcOnlyOneEachListOf = _libsbml.FbcOnlyOneEachListOf
    ## @var long FbcOnlyOneEachListOf
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcNoEmptyListOfs = _libsbml.FbcNoEmptyListOfs
    ## @var long FbcNoEmptyListOfs
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcLOFluxBoundsAllowedElements = _libsbml.FbcLOFluxBoundsAllowedElements
    ## @var long FbcLOFluxBoundsAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcLOObjectivesAllowedElements = _libsbml.FbcLOObjectivesAllowedElements
    ## @var long FbcLOObjectivesAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcLOFluxBoundsAllowedAttributes = _libsbml.FbcLOFluxBoundsAllowedAttributes
    ## @var long FbcLOFluxBoundsAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcLOObjectivesAllowedAttributes = _libsbml.FbcLOObjectivesAllowedAttributes
    ## @var long FbcLOObjectivesAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcActiveObjectiveSyntax = _libsbml.FbcActiveObjectiveSyntax
    ## @var long FbcActiveObjectiveSyntax
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcActiveObjectiveRefersObjective = _libsbml.FbcActiveObjectiveRefersObjective
    ## @var long FbcActiveObjectiveRefersObjective
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcSpeciesAllowedL3Attributes = _libsbml.FbcSpeciesAllowedL3Attributes
    ## @var long FbcSpeciesAllowedL3Attributes
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcSpeciesChargeMustBeInteger = _libsbml.FbcSpeciesChargeMustBeInteger
    ## @var long FbcSpeciesChargeMustBeInteger
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcSpeciesFormulaMustBeString = _libsbml.FbcSpeciesFormulaMustBeString
    ## @var long FbcSpeciesFormulaMustBeString
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxBoundAllowedL3Attributes = _libsbml.FbcFluxBoundAllowedL3Attributes
    ## @var long FbcFluxBoundAllowedL3Attributes
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxBoundAllowedElements = _libsbml.FbcFluxBoundAllowedElements
    ## @var long FbcFluxBoundAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxBoundRequiredAttributes = _libsbml.FbcFluxBoundRequiredAttributes
    ## @var long FbcFluxBoundRequiredAttributes
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxBoundRectionMustBeSIdRef = _libsbml.FbcFluxBoundRectionMustBeSIdRef
    ## @var long FbcFluxBoundRectionMustBeSIdRef
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxBoundNameMustBeString = _libsbml.FbcFluxBoundNameMustBeString
    ## @var long FbcFluxBoundNameMustBeString
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxBoundOperationMustBeEnum = _libsbml.FbcFluxBoundOperationMustBeEnum
    ## @var long FbcFluxBoundOperationMustBeEnum
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxBoundValueMustBeDouble = _libsbml.FbcFluxBoundValueMustBeDouble
    ## @var long FbcFluxBoundValueMustBeDouble
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxBoundReactionMustExist = _libsbml.FbcFluxBoundReactionMustExist
    ## @var long FbcFluxBoundReactionMustExist
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxBoundsForReactionConflict = _libsbml.FbcFluxBoundsForReactionConflict
    ## @var long FbcFluxBoundsForReactionConflict
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcObjectiveAllowedL3Attributes = _libsbml.FbcObjectiveAllowedL3Attributes
    ## @var long FbcObjectiveAllowedL3Attributes
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcObjectiveAllowedElements = _libsbml.FbcObjectiveAllowedElements
    ## @var long FbcObjectiveAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcObjectiveRequiredAttributes = _libsbml.FbcObjectiveRequiredAttributes
    ## @var long FbcObjectiveRequiredAttributes
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcObjectiveNameMustBeString = _libsbml.FbcObjectiveNameMustBeString
    ## @var long FbcObjectiveNameMustBeString
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcObjectiveTypeMustBeEnum = _libsbml.FbcObjectiveTypeMustBeEnum
    ## @var long FbcObjectiveTypeMustBeEnum
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcObjectiveOneListOfObjectives = _libsbml.FbcObjectiveOneListOfObjectives
    ## @var long FbcObjectiveOneListOfObjectives
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcObjectiveLOFluxObjMustNotBeEmpty = _libsbml.FbcObjectiveLOFluxObjMustNotBeEmpty
    ## @var long FbcObjectiveLOFluxObjMustNotBeEmpty
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcObjectiveLOFluxObjOnlyFluxObj = _libsbml.FbcObjectiveLOFluxObjOnlyFluxObj
    ## @var long FbcObjectiveLOFluxObjOnlyFluxObj
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcObjectiveLOFluxObjAllowedAttribs = _libsbml.FbcObjectiveLOFluxObjAllowedAttribs
    ## @var long FbcObjectiveLOFluxObjAllowedAttribs
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxObjectAllowedL3Attributes = _libsbml.FbcFluxObjectAllowedL3Attributes
    ## @var long FbcFluxObjectAllowedL3Attributes
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxObjectAllowedElements = _libsbml.FbcFluxObjectAllowedElements
    ## @var long FbcFluxObjectAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxObjectRequiredAttributes = _libsbml.FbcFluxObjectRequiredAttributes
    ## @var long FbcFluxObjectRequiredAttributes
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxObjectNameMustBeString = _libsbml.FbcFluxObjectNameMustBeString
    ## @var long FbcFluxObjectNameMustBeString
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxObjectReactionMustBeSIdRef = _libsbml.FbcFluxObjectReactionMustBeSIdRef
    ## @var long FbcFluxObjectReactionMustBeSIdRef
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxObjectReactionMustExist = _libsbml.FbcFluxObjectReactionMustExist
    ## @var long FbcFluxObjectReactionMustExist
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
FbcFluxObjectCoefficientMustBeDouble = _libsbml.FbcFluxObjectCoefficientMustBeDouble
    ## @var long FbcFluxObjectCoefficientMustBeDouble
    ##
    ## <span class="pkg-marker pkg-color-fbc">fbc</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;fbc&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    ## LayoutSBMLErrorCode_t 

    
LayoutUnknownError = _libsbml.LayoutUnknownError
    ## @var long LayoutUnknownError
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutNSUndeclared = _libsbml.LayoutNSUndeclared
    ## @var long LayoutNSUndeclared
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutElementNotInNs = _libsbml.LayoutElementNotInNs
    ## @var long LayoutElementNotInNs
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutDuplicateComponentId = _libsbml.LayoutDuplicateComponentId
    ## @var long LayoutDuplicateComponentId
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSIdSyntax = _libsbml.LayoutSIdSyntax
    ## @var long LayoutSIdSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutXsiTypeAllowedLocations = _libsbml.LayoutXsiTypeAllowedLocations
    ## @var long LayoutXsiTypeAllowedLocations
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutXsiTypeSyntax = _libsbml.LayoutXsiTypeSyntax
    ## @var long LayoutXsiTypeSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutAttributeRequiredMissing = _libsbml.LayoutAttributeRequiredMissing
    ## @var long LayoutAttributeRequiredMissing
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutAttributeRequiredMustBeBoolean = _libsbml.LayoutAttributeRequiredMustBeBoolean
    ## @var long LayoutAttributeRequiredMustBeBoolean
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutRequiredFalse = _libsbml.LayoutRequiredFalse
    ## @var long LayoutRequiredFalse
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutOnlyOneLOLayouts = _libsbml.LayoutOnlyOneLOLayouts
    ## @var long LayoutOnlyOneLOLayouts
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOLayoutsNotEmpty = _libsbml.LayoutLOLayoutsNotEmpty
    ## @var long LayoutLOLayoutsNotEmpty
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOLayoutsAllowedElements = _libsbml.LayoutLOLayoutsAllowedElements
    ## @var long LayoutLOLayoutsAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOLayoutsAllowedAttributes = _libsbml.LayoutLOLayoutsAllowedAttributes
    ## @var long LayoutLOLayoutsAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLayoutAllowedElements = _libsbml.LayoutLayoutAllowedElements
    ## @var long LayoutLayoutAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLayoutAllowedCoreAttributes = _libsbml.LayoutLayoutAllowedCoreAttributes
    ## @var long LayoutLayoutAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutOnlyOneEachListOf = _libsbml.LayoutOnlyOneEachListOf
    ## @var long LayoutOnlyOneEachListOf
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutNoEmptyListOfs = _libsbml.LayoutNoEmptyListOfs
    ## @var long LayoutNoEmptyListOfs
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLayoutAllowedAttributes = _libsbml.LayoutLayoutAllowedAttributes
    ## @var long LayoutLayoutAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLayoutNameMustBeString = _libsbml.LayoutLayoutNameMustBeString
    ## @var long LayoutLayoutNameMustBeString
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOCompGlyphAllowedAttributes = _libsbml.LayoutLOCompGlyphAllowedAttributes
    ## @var long LayoutLOCompGlyphAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOCompGlyphAllowedElements = _libsbml.LayoutLOCompGlyphAllowedElements
    ## @var long LayoutLOCompGlyphAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOSpeciesGlyphAllowedAttributes = _libsbml.LayoutLOSpeciesGlyphAllowedAttributes
    ## @var long LayoutLOSpeciesGlyphAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOSpeciesGlyphAllowedElements = _libsbml.LayoutLOSpeciesGlyphAllowedElements
    ## @var long LayoutLOSpeciesGlyphAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLORnGlyphAllowedAttributes = _libsbml.LayoutLORnGlyphAllowedAttributes
    ## @var long LayoutLORnGlyphAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLORnGlyphAllowedElements = _libsbml.LayoutLORnGlyphAllowedElements
    ## @var long LayoutLORnGlyphAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOAddGOAllowedAttribut = _libsbml.LayoutLOAddGOAllowedAttribut
    ## @var long LayoutLOAddGOAllowedAttribut
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOAddGOAllowedElements = _libsbml.LayoutLOAddGOAllowedElements
    ## @var long LayoutLOAddGOAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLayoutMustHaveDimensions = _libsbml.LayoutLayoutMustHaveDimensions
    ## @var long LayoutLayoutMustHaveDimensions
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOTextGlyphAllowedAttributes = _libsbml.LayoutLOTextGlyphAllowedAttributes
    ## @var long LayoutLOTextGlyphAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOTextGlyphAllowedElements = _libsbml.LayoutLOTextGlyphAllowedElements
    ## @var long LayoutLOTextGlyphAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGOAllowedCoreElements = _libsbml.LayoutGOAllowedCoreElements
    ## @var long LayoutGOAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGOAllowedCoreAttributes = _libsbml.LayoutGOAllowedCoreAttributes
    ## @var long LayoutGOAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGOAllowedElements = _libsbml.LayoutGOAllowedElements
    ## @var long LayoutGOAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGOAllowedAttributes = _libsbml.LayoutGOAllowedAttributes
    ## @var long LayoutGOAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGOMetaIdRefMustBeIDREF = _libsbml.LayoutGOMetaIdRefMustBeIDREF
    ## @var long LayoutGOMetaIdRefMustBeIDREF
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGOMetaIdRefMustReferenceObject = _libsbml.LayoutGOMetaIdRefMustReferenceObject
    ## @var long LayoutGOMetaIdRefMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGOMustContainBoundingBox = _libsbml.LayoutGOMustContainBoundingBox
    ## @var long LayoutGOMustContainBoundingBox
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCGAllowedCoreElements = _libsbml.LayoutCGAllowedCoreElements
    ## @var long LayoutCGAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCGAllowedCoreAttributes = _libsbml.LayoutCGAllowedCoreAttributes
    ## @var long LayoutCGAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCGAllowedElements = _libsbml.LayoutCGAllowedElements
    ## @var long LayoutCGAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCGAllowedAttributes = _libsbml.LayoutCGAllowedAttributes
    ## @var long LayoutCGAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCGMetaIdRefMustBeIDREF = _libsbml.LayoutCGMetaIdRefMustBeIDREF
    ## @var long LayoutCGMetaIdRefMustBeIDREF
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCGMetaIdRefMustReferenceObject = _libsbml.LayoutCGMetaIdRefMustReferenceObject
    ## @var long LayoutCGMetaIdRefMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCGCompartmentSyntax = _libsbml.LayoutCGCompartmentSyntax
    ## @var long LayoutCGCompartmentSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCGCompartmentMustRefComp = _libsbml.LayoutCGCompartmentMustRefComp
    ## @var long LayoutCGCompartmentMustRefComp
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCGNoDuplicateReferences = _libsbml.LayoutCGNoDuplicateReferences
    ## @var long LayoutCGNoDuplicateReferences
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCGOrderMustBeDouble = _libsbml.LayoutCGOrderMustBeDouble
    ## @var long LayoutCGOrderMustBeDouble
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSGAllowedCoreElements = _libsbml.LayoutSGAllowedCoreElements
    ## @var long LayoutSGAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSGAllowedCoreAttributes = _libsbml.LayoutSGAllowedCoreAttributes
    ## @var long LayoutSGAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSGAllowedElements = _libsbml.LayoutSGAllowedElements
    ## @var long LayoutSGAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSGAllowedAttributes = _libsbml.LayoutSGAllowedAttributes
    ## @var long LayoutSGAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSGMetaIdRefMustBeIDREF = _libsbml.LayoutSGMetaIdRefMustBeIDREF
    ## @var long LayoutSGMetaIdRefMustBeIDREF
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSGMetaIdRefMustReferenceObject = _libsbml.LayoutSGMetaIdRefMustReferenceObject
    ## @var long LayoutSGMetaIdRefMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSGSpeciesSyntax = _libsbml.LayoutSGSpeciesSyntax
    ## @var long LayoutSGSpeciesSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSGSpeciesMustRefSpecies = _libsbml.LayoutSGSpeciesMustRefSpecies
    ## @var long LayoutSGSpeciesMustRefSpecies
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSGNoDuplicateReferences = _libsbml.LayoutSGNoDuplicateReferences
    ## @var long LayoutSGNoDuplicateReferences
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutRGAllowedCoreElements = _libsbml.LayoutRGAllowedCoreElements
    ## @var long LayoutRGAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutRGAllowedCoreAttributes = _libsbml.LayoutRGAllowedCoreAttributes
    ## @var long LayoutRGAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutRGAllowedElements = _libsbml.LayoutRGAllowedElements
    ## @var long LayoutRGAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutRGAllowedAttributes = _libsbml.LayoutRGAllowedAttributes
    ## @var long LayoutRGAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutRGMetaIdRefMustBeIDREF = _libsbml.LayoutRGMetaIdRefMustBeIDREF
    ## @var long LayoutRGMetaIdRefMustBeIDREF
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutRGMetaIdRefMustReferenceObject = _libsbml.LayoutRGMetaIdRefMustReferenceObject
    ## @var long LayoutRGMetaIdRefMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutRGReactionSyntax = _libsbml.LayoutRGReactionSyntax
    ## @var long LayoutRGReactionSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutRGReactionMustRefReaction = _libsbml.LayoutRGReactionMustRefReaction
    ## @var long LayoutRGReactionMustRefReaction
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutRGNoDuplicateReferences = _libsbml.LayoutRGNoDuplicateReferences
    ## @var long LayoutRGNoDuplicateReferences
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOSpeciesRefGlyphAllowedElements = _libsbml.LayoutLOSpeciesRefGlyphAllowedElements
    ## @var long LayoutLOSpeciesRefGlyphAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOSpeciesRefGlyphAllowedAttribs = _libsbml.LayoutLOSpeciesRefGlyphAllowedAttribs
    ## @var long LayoutLOSpeciesRefGlyphAllowedAttribs
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOSpeciesRefGlyphNotEmpty = _libsbml.LayoutLOSpeciesRefGlyphNotEmpty
    ## @var long LayoutLOSpeciesRefGlyphNotEmpty
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGGAllowedCoreElements = _libsbml.LayoutGGAllowedCoreElements
    ## @var long LayoutGGAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGGAllowedCoreAttributes = _libsbml.LayoutGGAllowedCoreAttributes
    ## @var long LayoutGGAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGGAllowedElements = _libsbml.LayoutGGAllowedElements
    ## @var long LayoutGGAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGGAllowedAttributes = _libsbml.LayoutGGAllowedAttributes
    ## @var long LayoutGGAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGGMetaIdRefMustBeIDREF = _libsbml.LayoutGGMetaIdRefMustBeIDREF
    ## @var long LayoutGGMetaIdRefMustBeIDREF
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGGMetaIdRefMustReferenceObject = _libsbml.LayoutGGMetaIdRefMustReferenceObject
    ## @var long LayoutGGMetaIdRefMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGGReferenceSyntax = _libsbml.LayoutGGReferenceSyntax
    ## @var long LayoutGGReferenceSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGGReferenceMustRefObject = _libsbml.LayoutGGReferenceMustRefObject
    ## @var long LayoutGGReferenceMustRefObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutGGNoDuplicateReferences = _libsbml.LayoutGGNoDuplicateReferences
    ## @var long LayoutGGNoDuplicateReferences
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOReferenceGlyphAllowedElements = _libsbml.LayoutLOReferenceGlyphAllowedElements
    ## @var long LayoutLOReferenceGlyphAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOReferenceGlyphAllowedAttribs = _libsbml.LayoutLOReferenceGlyphAllowedAttribs
    ## @var long LayoutLOReferenceGlyphAllowedAttribs
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOSubGlyphAllowedElements = _libsbml.LayoutLOSubGlyphAllowedElements
    ## @var long LayoutLOSubGlyphAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOSubGlyphAllowedAttribs = _libsbml.LayoutLOSubGlyphAllowedAttribs
    ## @var long LayoutLOSubGlyphAllowedAttribs
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutTGAllowedCoreElements = _libsbml.LayoutTGAllowedCoreElements
    ## @var long LayoutTGAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutTGAllowedCoreAttributes = _libsbml.LayoutTGAllowedCoreAttributes
    ## @var long LayoutTGAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutTGAllowedElements = _libsbml.LayoutTGAllowedElements
    ## @var long LayoutTGAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutTGAllowedAttributes = _libsbml.LayoutTGAllowedAttributes
    ## @var long LayoutTGAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutTGMetaIdRefMustBeIDREF = _libsbml.LayoutTGMetaIdRefMustBeIDREF
    ## @var long LayoutTGMetaIdRefMustBeIDREF
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutTGMetaIdRefMustReferenceObject = _libsbml.LayoutTGMetaIdRefMustReferenceObject
    ## @var long LayoutTGMetaIdRefMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutTGOriginOfTextSyntax = _libsbml.LayoutTGOriginOfTextSyntax
    ## @var long LayoutTGOriginOfTextSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutTGOriginOfTextMustRefObject = _libsbml.LayoutTGOriginOfTextMustRefObject
    ## @var long LayoutTGOriginOfTextMustRefObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutTGNoDuplicateReferences = _libsbml.LayoutTGNoDuplicateReferences
    ## @var long LayoutTGNoDuplicateReferences
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutTGGraphicalObjectSyntax = _libsbml.LayoutTGGraphicalObjectSyntax
    ## @var long LayoutTGGraphicalObjectSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutTGGraphicalObjectMustRefObject = _libsbml.LayoutTGGraphicalObjectMustRefObject
    ## @var long LayoutTGGraphicalObjectMustRefObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutTGTextMustBeString = _libsbml.LayoutTGTextMustBeString
    ## @var long LayoutTGTextMustBeString
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSRGAllowedCoreElements = _libsbml.LayoutSRGAllowedCoreElements
    ## @var long LayoutSRGAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSRGAllowedCoreAttributes = _libsbml.LayoutSRGAllowedCoreAttributes
    ## @var long LayoutSRGAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSRGAllowedElements = _libsbml.LayoutSRGAllowedElements
    ## @var long LayoutSRGAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSRGAllowedAttributes = _libsbml.LayoutSRGAllowedAttributes
    ## @var long LayoutSRGAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSRGMetaIdRefMustBeIDREF = _libsbml.LayoutSRGMetaIdRefMustBeIDREF
    ## @var long LayoutSRGMetaIdRefMustBeIDREF
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSRGMetaIdRefMustReferenceObject = _libsbml.LayoutSRGMetaIdRefMustReferenceObject
    ## @var long LayoutSRGMetaIdRefMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSRGSpeciesReferenceSyntax = _libsbml.LayoutSRGSpeciesReferenceSyntax
    ## @var long LayoutSRGSpeciesReferenceSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSRGSpeciesRefMustRefObject = _libsbml.LayoutSRGSpeciesRefMustRefObject
    ## @var long LayoutSRGSpeciesRefMustRefObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSRGNoDuplicateReferences = _libsbml.LayoutSRGNoDuplicateReferences
    ## @var long LayoutSRGNoDuplicateReferences
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSRGSpeciesGlyphSyntax = _libsbml.LayoutSRGSpeciesGlyphSyntax
    ## @var long LayoutSRGSpeciesGlyphSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSRGSpeciesGlyphMustRefObject = _libsbml.LayoutSRGSpeciesGlyphMustRefObject
    ## @var long LayoutSRGSpeciesGlyphMustRefObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutSRGRoleSyntax = _libsbml.LayoutSRGRoleSyntax
    ## @var long LayoutSRGRoleSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutREFGAllowedCoreElements = _libsbml.LayoutREFGAllowedCoreElements
    ## @var long LayoutREFGAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutREFGAllowedCoreAttributes = _libsbml.LayoutREFGAllowedCoreAttributes
    ## @var long LayoutREFGAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutREFGAllowedElements = _libsbml.LayoutREFGAllowedElements
    ## @var long LayoutREFGAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutREFGAllowedAttributes = _libsbml.LayoutREFGAllowedAttributes
    ## @var long LayoutREFGAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutREFGMetaIdRefMustBeIDREF = _libsbml.LayoutREFGMetaIdRefMustBeIDREF
    ## @var long LayoutREFGMetaIdRefMustBeIDREF
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutREFGMetaIdRefMustReferenceObject = _libsbml.LayoutREFGMetaIdRefMustReferenceObject
    ## @var long LayoutREFGMetaIdRefMustReferenceObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutREFGReferenceSyntax = _libsbml.LayoutREFGReferenceSyntax
    ## @var long LayoutREFGReferenceSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutREFGReferenceMustRefObject = _libsbml.LayoutREFGReferenceMustRefObject
    ## @var long LayoutREFGReferenceMustRefObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutREFGNoDuplicateReferences = _libsbml.LayoutREFGNoDuplicateReferences
    ## @var long LayoutREFGNoDuplicateReferences
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutREFGGlyphSyntax = _libsbml.LayoutREFGGlyphSyntax
    ## @var long LayoutREFGGlyphSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutREFGGlyphMustRefObject = _libsbml.LayoutREFGGlyphMustRefObject
    ## @var long LayoutREFGGlyphMustRefObject
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutREFGRoleSyntax = _libsbml.LayoutREFGRoleSyntax
    ## @var long LayoutREFGRoleSyntax
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutPointAllowedCoreElements = _libsbml.LayoutPointAllowedCoreElements
    ## @var long LayoutPointAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutPointAllowedCoreAttributes = _libsbml.LayoutPointAllowedCoreAttributes
    ## @var long LayoutPointAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutPointAllowedAttributes = _libsbml.LayoutPointAllowedAttributes
    ## @var long LayoutPointAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutPointAttributesMustBeDouble = _libsbml.LayoutPointAttributesMustBeDouble
    ## @var long LayoutPointAttributesMustBeDouble
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutBBoxAllowedCoreElements = _libsbml.LayoutBBoxAllowedCoreElements
    ## @var long LayoutBBoxAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutBBoxAllowedCoreAttributes = _libsbml.LayoutBBoxAllowedCoreAttributes
    ## @var long LayoutBBoxAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutBBoxAllowedElements = _libsbml.LayoutBBoxAllowedElements
    ## @var long LayoutBBoxAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutBBoxAllowedAttributes = _libsbml.LayoutBBoxAllowedAttributes
    ## @var long LayoutBBoxAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutBBoxConsistent3DDefinition = _libsbml.LayoutBBoxConsistent3DDefinition
    ## @var long LayoutBBoxConsistent3DDefinition
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCurveAllowedCoreElements = _libsbml.LayoutCurveAllowedCoreElements
    ## @var long LayoutCurveAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCurveAllowedCoreAttributes = _libsbml.LayoutCurveAllowedCoreAttributes
    ## @var long LayoutCurveAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCurveAllowedElements = _libsbml.LayoutCurveAllowedElements
    ## @var long LayoutCurveAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCurveAllowedAttributes = _libsbml.LayoutCurveAllowedAttributes
    ## @var long LayoutCurveAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOCurveSegsAllowedAttributes = _libsbml.LayoutLOCurveSegsAllowedAttributes
    ## @var long LayoutLOCurveSegsAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOCurveSegsAllowedElements = _libsbml.LayoutLOCurveSegsAllowedElements
    ## @var long LayoutLOCurveSegsAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLOCurveSegsNotEmpty = _libsbml.LayoutLOCurveSegsNotEmpty
    ## @var long LayoutLOCurveSegsNotEmpty
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLSegAllowedCoreElements = _libsbml.LayoutLSegAllowedCoreElements
    ## @var long LayoutLSegAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLSegAllowedCoreAttributes = _libsbml.LayoutLSegAllowedCoreAttributes
    ## @var long LayoutLSegAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLSegAllowedElements = _libsbml.LayoutLSegAllowedElements
    ## @var long LayoutLSegAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutLSegAllowedAttributes = _libsbml.LayoutLSegAllowedAttributes
    ## @var long LayoutLSegAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCBezAllowedCoreElements = _libsbml.LayoutCBezAllowedCoreElements
    ## @var long LayoutCBezAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCBezAllowedCoreAttributes = _libsbml.LayoutCBezAllowedCoreAttributes
    ## @var long LayoutCBezAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCBezAllowedElements = _libsbml.LayoutCBezAllowedElements
    ## @var long LayoutCBezAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutCBezAllowedAttributes = _libsbml.LayoutCBezAllowedAttributes
    ## @var long LayoutCBezAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutDimsAllowedCoreElements = _libsbml.LayoutDimsAllowedCoreElements
    ## @var long LayoutDimsAllowedCoreElements
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutDimsAllowedCoreAttributes = _libsbml.LayoutDimsAllowedCoreAttributes
    ## @var long LayoutDimsAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutDimsAllowedAttributes = _libsbml.LayoutDimsAllowedAttributes
    ## @var long LayoutDimsAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
LayoutDimsAttributesMustBeDouble = _libsbml.LayoutDimsAttributesMustBeDouble
    ## @var long LayoutDimsAttributesMustBeDouble
    ##
    ## <span class="pkg-marker pkg-color-layout">layout</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;layout&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    ## QualSBMLErrorCode_t 

    
QualUnknown = _libsbml.QualUnknown
    ## @var long QualUnknown
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualNSUndeclared = _libsbml.QualNSUndeclared
    ## @var long QualNSUndeclared
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualElementNotInNs = _libsbml.QualElementNotInNs
    ## @var long QualElementNotInNs
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualFunctionTermBool = _libsbml.QualFunctionTermBool
    ## @var long QualFunctionTermBool
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualMathCSymbolDisallowed = _libsbml.QualMathCSymbolDisallowed
    ## @var long QualMathCSymbolDisallowed
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualDuplicateComponentId = _libsbml.QualDuplicateComponentId
    ## @var long QualDuplicateComponentId
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualAttributeRequiredMissing = _libsbml.QualAttributeRequiredMissing
    ## @var long QualAttributeRequiredMissing
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualAttributeRequiredMustBeBoolean = _libsbml.QualAttributeRequiredMustBeBoolean
    ## @var long QualAttributeRequiredMustBeBoolean
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualRequiredTrueIfTransitions = _libsbml.QualRequiredTrueIfTransitions
    ## @var long QualRequiredTrueIfTransitions
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualOneListOfTransOrQS = _libsbml.QualOneListOfTransOrQS
    ## @var long QualOneListOfTransOrQS
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualEmptyLONotAllowed = _libsbml.QualEmptyLONotAllowed
    ## @var long QualEmptyLONotAllowed
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualLOTransitiondAllowedElements = _libsbml.QualLOTransitiondAllowedElements
    ## @var long QualLOTransitiondAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualLOQualSpeciesAllowedElements = _libsbml.QualLOQualSpeciesAllowedElements
    ## @var long QualLOQualSpeciesAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualLOQualSpeciesAllowedAttributes = _libsbml.QualLOQualSpeciesAllowedAttributes
    ## @var long QualLOQualSpeciesAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualLOTransitionsAllowedAttributes = _libsbml.QualLOTransitionsAllowedAttributes
    ## @var long QualLOTransitionsAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualQualSpeciesAllowedCoreAttributes = _libsbml.QualQualSpeciesAllowedCoreAttributes
    ## @var long QualQualSpeciesAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualQualSpeciesAllowedElements = _libsbml.QualQualSpeciesAllowedElements
    ## @var long QualQualSpeciesAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualQualSpeciesAllowedAttributes = _libsbml.QualQualSpeciesAllowedAttributes
    ## @var long QualQualSpeciesAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualConstantMustBeBool = _libsbml.QualConstantMustBeBool
    ## @var long QualConstantMustBeBool
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualNameMustBeString = _libsbml.QualNameMustBeString
    ## @var long QualNameMustBeString
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInitialLevelMustBeInt = _libsbml.QualInitialLevelMustBeInt
    ## @var long QualInitialLevelMustBeInt
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualMaxLevelMustBeInt = _libsbml.QualMaxLevelMustBeInt
    ## @var long QualMaxLevelMustBeInt
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualCompartmentMustReferExisting = _libsbml.QualCompartmentMustReferExisting
    ## @var long QualCompartmentMustReferExisting
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInitialLevelCannotExceedMax = _libsbml.QualInitialLevelCannotExceedMax
    ## @var long QualInitialLevelCannotExceedMax
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualConstantQSCannotBeOutput = _libsbml.QualConstantQSCannotBeOutput
    ## @var long QualConstantQSCannotBeOutput
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualQSAssignedOnlyOnce = _libsbml.QualQSAssignedOnlyOnce
    ## @var long QualQSAssignedOnlyOnce
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInitalLevelNotNegative = _libsbml.QualInitalLevelNotNegative
    ## @var long QualInitalLevelNotNegative
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualMaxLevelNotNegative = _libsbml.QualMaxLevelNotNegative
    ## @var long QualMaxLevelNotNegative
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionAllowedCoreAttributes = _libsbml.QualTransitionAllowedCoreAttributes
    ## @var long QualTransitionAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionAllowedElements = _libsbml.QualTransitionAllowedElements
    ## @var long QualTransitionAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionAllowedAttributes = _libsbml.QualTransitionAllowedAttributes
    ## @var long QualTransitionAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionNameMustBeString = _libsbml.QualTransitionNameMustBeString
    ## @var long QualTransitionNameMustBeString
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionLOElements = _libsbml.QualTransitionLOElements
    ## @var long QualTransitionLOElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionEmptyLOElements = _libsbml.QualTransitionEmptyLOElements
    ## @var long QualTransitionEmptyLOElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionLOInputElements = _libsbml.QualTransitionLOInputElements
    ## @var long QualTransitionLOInputElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionLOOutputElements = _libsbml.QualTransitionLOOutputElements
    ## @var long QualTransitionLOOutputElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionLOFuncTermElements = _libsbml.QualTransitionLOFuncTermElements
    ## @var long QualTransitionLOFuncTermElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionLOInputAttributes = _libsbml.QualTransitionLOInputAttributes
    ## @var long QualTransitionLOInputAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionLOOutputAttributes = _libsbml.QualTransitionLOOutputAttributes
    ## @var long QualTransitionLOOutputAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionLOFuncTermAttributes = _libsbml.QualTransitionLOFuncTermAttributes
    ## @var long QualTransitionLOFuncTermAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionLOFuncTermExceedMax = _libsbml.QualTransitionLOFuncTermExceedMax
    ## @var long QualTransitionLOFuncTermExceedMax
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualTransitionLOFuncTermNegative = _libsbml.QualTransitionLOFuncTermNegative
    ## @var long QualTransitionLOFuncTermNegative
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInputAllowedCoreAttributes = _libsbml.QualInputAllowedCoreAttributes
    ## @var long QualInputAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInputAllowedElements = _libsbml.QualInputAllowedElements
    ## @var long QualInputAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInputAllowedAttributes = _libsbml.QualInputAllowedAttributes
    ## @var long QualInputAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInputNameMustBeString = _libsbml.QualInputNameMustBeString
    ## @var long QualInputNameMustBeString
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInputSignMustBeSignEnum = _libsbml.QualInputSignMustBeSignEnum
    ## @var long QualInputSignMustBeSignEnum
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInputTransEffectMustBeInputEffect = _libsbml.QualInputTransEffectMustBeInputEffect
    ## @var long QualInputTransEffectMustBeInputEffect
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInputThreshMustBeInteger = _libsbml.QualInputThreshMustBeInteger
    ## @var long QualInputThreshMustBeInteger
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInputQSMustBeExistingQS = _libsbml.QualInputQSMustBeExistingQS
    ## @var long QualInputQSMustBeExistingQS
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInputConstantCannotBeConsumed = _libsbml.QualInputConstantCannotBeConsumed
    ## @var long QualInputConstantCannotBeConsumed
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualInputThreshMustBeNonNegative = _libsbml.QualInputThreshMustBeNonNegative
    ## @var long QualInputThreshMustBeNonNegative
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualOutputAllowedCoreAttributes = _libsbml.QualOutputAllowedCoreAttributes
    ## @var long QualOutputAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualOutputAllowedElements = _libsbml.QualOutputAllowedElements
    ## @var long QualOutputAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualOutputAllowedAttributes = _libsbml.QualOutputAllowedAttributes
    ## @var long QualOutputAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualOutputNameMustBeString = _libsbml.QualOutputNameMustBeString
    ## @var long QualOutputNameMustBeString
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualOutputTransEffectMustBeOutput = _libsbml.QualOutputTransEffectMustBeOutput
    ## @var long QualOutputTransEffectMustBeOutput
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualOutputLevelMustBeInteger = _libsbml.QualOutputLevelMustBeInteger
    ## @var long QualOutputLevelMustBeInteger
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualOutputQSMustBeExistingQS = _libsbml.QualOutputQSMustBeExistingQS
    ## @var long QualOutputQSMustBeExistingQS
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualOutputConstantMustBeFalse = _libsbml.QualOutputConstantMustBeFalse
    ## @var long QualOutputConstantMustBeFalse
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualOutputProductionMustHaveLevel = _libsbml.QualOutputProductionMustHaveLevel
    ## @var long QualOutputProductionMustHaveLevel
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualOutputLevelMustBeNonNegative = _libsbml.QualOutputLevelMustBeNonNegative
    ## @var long QualOutputLevelMustBeNonNegative
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualDefaultTermAllowedCoreAttributes = _libsbml.QualDefaultTermAllowedCoreAttributes
    ## @var long QualDefaultTermAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualDefaultTermAllowedElements = _libsbml.QualDefaultTermAllowedElements
    ## @var long QualDefaultTermAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualDefaultTermAllowedAttributes = _libsbml.QualDefaultTermAllowedAttributes
    ## @var long QualDefaultTermAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualDefaultTermResultMustBeInteger = _libsbml.QualDefaultTermResultMustBeInteger
    ## @var long QualDefaultTermResultMustBeInteger
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualDefaultTermResultMustBeNonNeg = _libsbml.QualDefaultTermResultMustBeNonNeg
    ## @var long QualDefaultTermResultMustBeNonNeg
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualFuncTermAllowedCoreAttributes = _libsbml.QualFuncTermAllowedCoreAttributes
    ## @var long QualFuncTermAllowedCoreAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.
    ##


    
QualFuncTermAllowedElements = _libsbml.QualFuncTermAllowedElements
    ## @var long QualFuncTermAllowedElements
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.

    
QualFuncTermAllowedAttributes = _libsbml.QualFuncTermAllowedAttributes
    ## @var long QualFuncTermAllowedAttributes
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.

    
QualFuncTermOnlyOneMath = _libsbml.QualFuncTermOnlyOneMath
    ## @var long QualFuncTermOnlyOneMath
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.

    
QualFuncTermResultMustBeInteger = _libsbml.QualFuncTermResultMustBeInteger
    ## @var long QualFuncTermResultMustBeInteger
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.

    
QualFuncTermResultMustBeNonNeg = _libsbml.QualFuncTermResultMustBeNonNeg
    ## @var long QualFuncTermResultMustBeNonNeg
    ##
    ## <span class="pkg-marker pkg-color-qual">qual</span> A value in the
    ## enumeration of all the error and warning codes generated by the
    ## libSBML &ldquo;qual&rdquo; extension for objects of class 
    ## SBMLError.  Please consult the documentation for  SBMLError
    ## for an explanation of the meaning of this particular error code.


LIBSBML_OVERRIDE_DISABLED = _libsbml.LIBSBML_OVERRIDE_DISABLED    
    ## @var long LIBSBML_OVERRIDE_DISABLED
    ##
    ## Severity override code for errors logged in the XML layer.
    ##
    ## XMLErrorLog can be configured whether to log errors or not log them.
    ## This code has the following meaning: log errors in the error log, as
    ## normal.

     
LIBSBML_OVERRIDE_DONT_LOG = _libsbml.LIBSBML_OVERRIDE_DONT_LOG
    ## @var long LIBSBML_OVERRIDE_DONT_LOG
    ##
    ## Severity override code for errors logged in the XML layer.
    ##
    ## XMLErrorLog can be configured whether to log errors or not log them.
    ## This code has the following meaning: disable all error logging.


LIBSBML_OVERRIDE_WARNING = _libsbml.LIBSBML_OVERRIDE_WARNING
    ## @var long LIBSBML_OVERRIDE_WARNING
    ##
    ## Severity override code for errors logged in the XML layer.
    ##
    ## XMLErrorLog can be configured whether to log errors or not log them.
    ## This code has the following meaning: log all errors as warnings instead
    ## of actual errors.


AnnotationNotElement = _libsbml.AnnotationNotElement
    ## @var long AnnotationNotElement
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.


L3PackageOnLowerSBML = _libsbml.L3PackageOnLowerSBML
    ## @var long L3PackageOnLowerSBML
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.
     

GlobalUnitsNotDeclared = _libsbml.GlobalUnitsNotDeclared
    ## @var long GlobalUnitsNotDeclared
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

     
HasOnlySubstanceUnitsNotinL1 = _libsbml.HasOnlySubstanceUnitsNotinL1
    ## @var long HasOnlySubstanceUnitsNotinL1
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.


AvogadroNotSupported = _libsbml.AvogadroNotSupported
    ## @var long AvogadroNotSupported
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.

     
PackageRequiredShouldBeFalse = _libsbml.PackageRequiredShouldBeFalse
    ## @var long PackageRequiredShouldBeFalse
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.
     

L3SubstanceUnitsOnModel = _libsbml.L3SubstanceUnitsOnModel
    ## @var long L3SubstanceUnitsOnModel
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.
     

RDFMissingAboutTag = _libsbml.RDFMissingAboutTag
    ## @var long RDFMissingAboutTag
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.


RDFEmptyAboutTag = _libsbml.RDFEmptyAboutTag
    ## @var long RDFEmptyAboutTag
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.


RDFAboutTagNotMetaid = _libsbml.RDFAboutTagNotMetaid
    ## @var long RDFAboutTagNotMetaid
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.


RDFNotCompleteModelHistory = _libsbml.RDFNotCompleteModelHistory
    ## @var long RDFNotCompleteModelHistory
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.


RDFNotModelHistory = _libsbml.RDFNotModelHistory
    ## @var long RDFNotModelHistory
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.


AnnotationNotElement = _libsbml.AnnotationNotElement
    ## @var long AnnotationNotElement
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class SBMLError.  Please consult the
    ## documentation for SBMLError for an explanation of the
    ## meaning of this particular error code.


DanglingUnitSIdRef = _libsbml.DanglingUnitSIdRef
    ## @var long DanglingUnitSIdRef
    ##
    ## A value in the enumeration of all the SBML error and warning codes
    ## for objects of class @link SBMLError@endlink.  Please consult the
    ## documentation for @link SBMLError@endlink for an explanation of the
    ## meaning of this particular error code.
