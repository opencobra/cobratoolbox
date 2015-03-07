/**
 * \file    libsbml.i
 * \brief   Language-independent SWIG directives for wrapping libSBML
 * \author  Ben Bornstein and Ben Kovitz
 *
 * <!--------------------------------------------------------------------------
 * This file is part of libSBML.  Please visit http://sbml.org for more
 * information about SBML, and the latest version of libSBML.
 *
 * Copyright (C) 2013-2014 jointly by the following organizations:
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *     3. University of Heidelberg, Heidelberg, Germany
 *
 * Copyright (C) 2009-2013 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *  
 * Copyright (C) 2006-2008 by the California Institute of Technology,
 *     Pasadena, CA, USA 
 *  
 * Copyright (C) 2002-2005 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. Japan Science and Technology Agency, Japan
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

%module(directors="1") libsbml

%feature("director") SBMLValidator;  
%feature("director") SBMLConverter;  
%feature("director") ElementFilter;  
%feature("director") IdentifierTransformer;  
%ignore IdentifierTransformer::transform(const SBase* element);

#pragma SWIG nowarn=473,401,844

%pragma(java) moduleclassmodifiers="
/**
  * Wrapper class for global methods and constants defined by libSBML.
  * <p>
  * <em style='color: #555'>
  * This class of objects is defined by libSBML only and has no direct
  * equivalent in terms of SBML components.  This class is not prescribed by
  * the SBML specifications, although it is used to implement features
  * defined in SBML.
  * </em>
  * <p>
  * In the C++ and C versions of libSBML, there exists a small number of
  * methods that are global in scope; in addition, libSBML uses a number
  * of enum's to define such things as error codes in a way that can be
  * used by both C++ and C.  This poses a problem in languages such as
  * Java, where there is no concept of global method or global constant.
  * SWIG wraps these global identifiers in the class whose documentation
  * you see before you.
  */
public class"


%{
#include "libsbml.h"

LIBSBML_CPP_NAMESPACE_USE

#include "../swig/libsbml-packages.h"
	
#include "local.cpp"
%}

%import  sbml/common/libsbml-namespace.h
%import  sbml/common/extern.h
%import  sbml/common/sbmlfwd.h
%import  sbml/xml/XMLExtern.h

/**
 * Wraps List class by ListWrapper<TYPENAME> template class.
 * TYPENAME is replaced with a corresponding data type which is
 * stored in the List object (e.g. ModelCreator, CVTerm and ASTNode). 
 *
 * ListWrapper<TYPENAME> class is wrapped as TYPENAMEList class
 * (e.g. ListWrapper<CVTerm> -> CVTermList)
 *
 */

%include "ListWrapper.h"
%template(ModelCreatorList)   ListWrapper<ModelCreator>;
%template(DateList)           ListWrapper<Date>;
%template(CVTermList)         ListWrapper<CVTerm>;
%template(ASTNodeList)        ListWrapper<ASTNode>;
%template(SBMLNamespacesList) ListWrapper<SBMLNamespaces>;
%template(SBaseList)          ListWrapper<SBase>;

/**
 *
 * Includes a language specific interface file.
 *
 */

%include local.i

/**
 * Unfortunately, SWIG makes no distinction between const and non-const
 * member functions (SWIG 1.3 Manual, Section 6.25), but in libSBML C++ we
 * have both const and non-const versions of most getter methods.  To avoid
 * a ton of warning messages about 'const' methods not being wrapped, we
 * disable Warning(516).
 */
#pragma SWIG nowarn=516

/**
 * Ignore the Visitor pattern accept() method (for now) on all SBML
 * objects.
 */
%ignore *::accept;

/**
 * Ignore internal implementation methods in ASTNode.h
 */
%ignore ASTNode(Token_t*);
%ignore ASTNode::getListOfNodes(ASTNodePredicate predicate) const;
%ignore ASTNode::fillListOfNodes;
%ignore ASTNode::setSemanticsFlag;
%ignore ASTNode::unsetSemanticsFlag;
%ignore ASTNode::getSemanticsFlag;

/**
 * Ignore the list that can't be wrapped
 */
%ignore SBMLExtensionRegistry::getRegisteredPackageNames;

/**
 * SWIG makes no distinction between int and long arguments.
 * (SWIG 1.3 Manual, Section 6.15.2)
 */
%ignore ASTNode::setValue(int);

/**
 * Ignore operator= and operator<< on all SBML objects.
 */
%ignore *::operator=;
%ignore *::operator<<;
%ignore operator==;
%ignore operator!=;

/**
 * Ignore certain internal implementation methods on all objects.
 */
%ignore *::writeElements;
%ignore *::getElementPosition;
%ignore *::setSBMLDocument;
%ignore *::setParentSBMLObject;
%ignore *::setInternalId;
%ignore *::getInternalId;

/**
 * Ignore internal implementation methods in MathML.h
 */
%ignore readMathML;
%ignore writeMathML;

/**
 * Ignore methods whose pointer argument serves as both input and output
 */
%ignore XMLAttributes::readInto;

/**
 * Ignore methods which receive std::list.
 */
%ignore XMLErrorLog::add(const std::list<XMLError>& errors);
%ignore SBMLErrorLog::add(const std::list<SBMLError>& errors);
%ignore SBMLErrorLog::add(const std::vector<SBMLError>& errors);

/**
 * Ignore methods from SBML Validator that can't be wrapped
 */
%ignore SBMLValidator::getFailures;
%ignore SBMLExternalValidator::getArguments;
%ignore SBMLExternalValidator::setArguments;

/**
 * Ignore 'static ParentMap mParent;' in SBO.h
 */
%ignore mParent;

/**
 * Ignore 'struct xmlErrorTableEntry' in XMLError.h.
 */
%ignore xmlErrorTableEntry;

/**
 * Both "const std::string& SBase::getMetaId() const" and
 * "std:string& SBase::getMetaId()" are defined in SBase.cpp.
 * By default, SWIG doesn't convert non-const std:string& to and from
 * target language string.
 * So we ignore the non-const version.
 */
%ignore SBase::getMetaId();

/**
 * Ignore internal methods on SBase
 */
%ignore SBase::removeDuplicateAnnotations;
%ignore SBase::setSBMLNamespaces;
//%ignore SBase::getSBMLNamespaces;
%ignore SBase::read;
%ignore SBase::write;

/**
 * Ignore internal methods on Model
 */
%ignore Model::addFormulaUnitsData;
%ignore Model::createFormulaUnitsData;
%ignore Model::getFormulaUnitsData;
%ignore Model::getListFormulaUnitsData;
%ignore Model::getNumFormulaUnitsData;
%ignore Model::isBoolean;
%ignore Model::removeMetaId;
%ignore Model::removeSBOTerms;
%ignore Model::removeHasOnlySubstanceUnits;
%ignore Model::removeSBOTermsNotInL2V2;
%ignore Model::removeDuplicateTopLevelAnnotations;
%ignore Model::convertToL1;
%ignore Model::convertToL2;
%ignore Model::convertToL2V1;
%ignore Model::convertToL2V2;
%ignore Model::convertToL2Strict;

/**
 * Ignore internal implementation methods in Rule
 */
%ignore Rule::setInternalIdOnly;
%ignore Rule::getInternalIdOnly;

/**
 * Ignore internal implementation methods in SpeciesReference
 */
%ignore SpeciesReference::sortMath;

/**
 * Ignore internal implementation methods in UnitDefinition
 */
%ignore UnitDefinition::areIdenticalSIUnits;

/**
 * Ignore internal implementation methods in XMLAttributes
 */
%ignore XMLAttributes::addResource;
%ignore XMLAttributes::write;
%ignore XMLAttributes::setErrorLog;

/**
 * Ignore internal implementation methods in Event
 */
%ignore Event::setInternalIdOnly;

/**
 * Ignore internal implementation methods in SBO
 */
%ignore SBO::readTerm;
%ignore SBO::writeTerm;

/**
 * With the new Validator API we no longer exclude the following 
 * methods:
 */ 
//%ignore SBMLErrorLog::logError;
//%ignore SBMLErrorLog::add;
//%ignore SBMLErrorLog::remove;
//%ignore SBMLErrorLog::SBMLErrorLog;
//%ignore XMLErrorLog::XMLErrorLog;
//%ignore XMLErrorLog::add;


/**
 * Ignore internal implementation methods in XMLErrorLog
 */
%ignore XMLErrorLog::setParser;


/**
 * Ignore internal implementation methods in ModelCreator
 */
%ignore ModelCreator::getAdditionalRDF;

/**
 * Ignore internal implementation methods in RDFAnnotationParser
 */
%ignore RDFAnnotationParser::hasRDFAnnotation;
%ignore RDFAnnotationParser::hasAdditionalRDFAnnotation;
%ignore RDFAnnotationParser::hasCVTermRDFAnnotation;
%ignore RDFAnnotationParser::hasHistoryRDFAnnotation;
%ignore RDFAnnotationParser::createRDFDescription;
%ignore RDFAnnotationParser::createRDFDescriptionWithCVTerms;
%ignore RDFAnnotationParser::createRDFDescriptionWithHistory;
%ignore RDFAnnotationParser::deriveCVTermsFromAnnotation;
%ignore RDFAnnotationParser::deriveHistoryFromAnnotation;

/**
 * Ignore internal implementation methods in SyntaxChecer
 */
%ignore SyntaxChecker::isAllowedElement;
%ignore SyntaxChecker::hasDeclaredNS;
%ignore SyntaxChecker::isCorrectHTMLNode;

/** 
 * Ignore some const versions of methods
 */
%ignore SBMLConverter::setDocument(SBMLDocument const *);
%ignore SBMLReactionConverter::setDocument(SBMLDocument const *);


/**
 * Ignore internal implementation methods and some other methods
 * on SBMLNamespces.
 */
%ignore SBMLNamespaces::setLevel;
%ignore SBMLNamespaces::setVersion;
%ignore SBMLNamespaces::setNamespaces;

/**
 * Ignore internal implementation methods and some other methods
 * on SBMLTransforms.
 */
%ignore SBMLTransforms::evaluateASTNode(const ASTNode * node, const IdValueMap& values, const Model * m = NULL);
%ignore SBMLTransforms::evaluateASTNode(const ASTNode * node, const std::map<std::string, double>& values, const Model * m = NULL);
%ignore SBMLTransforms::getComponentValuesForModel(const Model * m, IdValueMap& values);

/**
 * Ignore internal implementation methods in XMLToken
 */
%ignore XMLToken::write;

/**
 * Ignore internal implementation methods in XMLNode
 */
//%ignore XMLNode::XMLNode(XMLInputStream&);
%ignore XMLNode::write;

/**
 * Ignore internal implementation methods in XMLOutputStream
 */
%ignore XMLOutputStream::getStringStream;

/**
 * Ignore internal implementation classes
 */
%ignore XMLOutputStringStream;
%ignore XMLOutputFileStream;

/**
 * Ignore the unsigned int version of XMLOutputStream::writeAttribute method
 * in order to properly wrap the long version of XMLOutputStream::writeAttribute 
 * method which should be used instead of the unsigned int version.
 */
%ignore XMLOutputStream::writeAttribute(const std::string&, const unsigned int&);
%ignore XMLOutputStream::writeAttribute(const XMLTriple&,   const unsigned int&);

/**
 * The following methods will create new objects.  To prevent memory
 * leaks we must inform SWIG of this.
 */

%typemap(newfree) char * "free($1);";

%newobject *::clone;
%newobject SBase::toSBML;
%newobject SBMLReader::readSBMLFromString;
%newobject SBMLReader::readSBMLFromFile;
%newobject SBMLReader::readSBML;
%newobject readSBML(const char *);
%newobject readSBMLFromString(const char *);
%newobject readSBMLFromFile(const char *);
%newobject SBMLWriter::writeToString;
%newobject writeSBMLToString;
%newobject readMathMLFromString;
%newobject writeMathMLToString;
%newobject SBML_formulaToString;
%newobject SBML_formulaToL3String;
%newobject SBML_formulaToL3StringWithSettings;
%newobject SBML_parseFormula;
%newobject SBML_parseL3Formula;
%newobject SBML_parseL3FormulaWithModel;
%newobject SBML_parseL3FormulaWithSettings;
%newobject SBML_getDefaultL3ParserSettings;
%newobject SBML_getLastParseL3Error;
%newobject ASTNode::deepCopy;
%newobject ASTNode::getListOfNodes();
%newobject *::remove;
%newobject Model::removeFunctionDefinition;
%newobject Model::removeUnitDefinition;
%newobject Model::removeCompartmentType;
%newobject Model::removeSpeciesType;
%newobject Model::removeSpecies;
%newobject Model::removeCompartment;
%newobject Model::removeParameter;
%newobject Model::removeInitialAssignment;
%newobject Model::removeRule;
%newobject Model::removeConstraint;
%newobject Model::removeReaction;
%newobject Model::removeEvent;
%newobject Reaction::removeReactant;
%newobject Reaction::removeProduct;
%newobject Reaction::removeModifier;
%newobject Event::removeEventAssignment;
%newobject UnitDefinition::removeUnit;
%newobject KineticLaw::removeParameter;
%newobject KineticLaw::removeLocalParameter;
%newobject RDFAnnotationParser::parseRDFAnnotation(XMLNode *);
%newobject RDFAnnotationParser::deleteRDFAnnotation;
%newobject RDFAnnotationParser::parseCVTerms;
%newobject RDFAnnotationParser::parseModelHistory;
%newobject RDFAnnotationParser::createRDFAnnotation;
%newobject RDFAnnotationParser::createAnnotation;
%newobject RDFAnnotationParser::createRDFDescription;
%newobject RDFAnnotationParser::createCVTerms;
%newobject XMLNode::removeChild;
%newobject XMLNode::convertStringToXMLNode;
%newobject Unit::convertToSI;
%newobject UnitDefinition::convertToSI;
%newobject UnitDefinition::combine;

/**
 * We can't currently support attaching arbitrary user data to
 * libSBML objects.
 */
%ignore *::setUserData;
%ignore *::getUserData;

/**
 * In the wrapped languages, these methods will appear as:
 *
 *  - libsbml.formulaToString()
 *  - libsbml.parseFormula()
 */
%rename(formulaToL3String) SBML_formulaToL3String;
%rename(formulaToL3StringWithSettings) SBML_formulaToL3StringWithSettings;
%rename(formulaToString) SBML_formulaToString;
%rename(parseFormula)    SBML_parseFormula;
%rename(parseL3Formula)    SBML_parseL3Formula;
%rename(parseL3FormulaWithModel)    SBML_parseL3FormulaWithModel;
%rename(parseL3FormulaWithSettings)    SBML_parseL3FormulaWithSettings;
%rename(getDefaultL3ParserSettings)    SBML_getDefaultL3ParserSettings;
%rename(getLastParseL3Error)    SBML_getLastParseL3Error;

/**
 *
 * wraps "List* ASTNode::getListOfNodes(ASTNodePredicate)" function
 * as "ListWrapper<ASTNode>* ASTNode::getListOfNodes()" function
 * which returns a list of all ASTNodes.
 *
 */

%ignore SBase::getAllElementsFromPlugins;
%ignore SBasePlugin::getAllElements;
%ignore SBase::getAllElements;
%ignore Model::renameIDs(List* elements, IdentifierTransformer* idTransformer);

%extend Model
{
   void renameIDs(ListWrapper<SBase>* elements, IdentifierTransformer *idTransformer)
   {
		if (!elements) return;

		List *list = elements->getList();
		$self->renameIDs(list, idTransformer);
   }
}

/*
 * Docstring additions using SWIG's %feature("docstring") have to come before
 * the method definitions.  I have no idea why.  I don't think it's
 * documented that way, and it's backwards, and I would never have figured it
 * out except for the fact that I found a comment in someone else's code on
 * GitHub where they had problems with missing doc strings.
 */
#ifndef SWIGRUBY
%feature("docstring") SBasePlugin::getListOfAllElements "
Returns an SBaseList of all child SBase objects, including those
nested to an arbitrary depth.

@return a list of all objects that are children of this object.
";
#endif
%extend SBasePlugin
{
	ListWrapper<SBase>* getListOfAllElements(ElementFilter* filter=NULL)
	{
		List* list = $self->getAllElements(filter);
		return new ListWrapper<SBase>(list);
	}
}
#ifndef SWIGRUBY
%feature("docstring") SBase::getListOfAllElements "
Returns an SBaseList of all child SBase objects, including those
nested to an arbitrary depth.

@return a list of all objects that are children of this object.
";
#endif
%extend SBase
{
	ListWrapper<SBase>* getListOfAllElements(ElementFilter* filter=NULL)
	{
		List* list = $self->getAllElements(filter);
		return new ListWrapper<SBase>(list);
	}
}

#ifndef SWIGRUBY
%feature("docstring") SBase::getListOfAllElementsFromPlugins "
Returns a List of all child SBase objects contained in SBML package
plug-ins.

@copydetails doc_what_are_plugins

This method walks down the list of all SBML Level&nbsp;3 packages used
by this object and returns all child objects defined by those packages.

@return a pointer to a List of pointers to all children objects from
plug-ins.

@ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
";
#endif
%extend SBase
{
	ListWrapper<SBase>* getListOfAllElementsFromPlugins(ElementFilter* filter=NULL)
	{
		List* list = $self->getAllElementsFromPlugins(filter);
		return new ListWrapper<SBase>(list);
	}
}
#ifndef SWIGRUBY

%feature("docstring") ASTNode::getListOfNodes "
Returns a list of nodes.

Unlike the equivalent method in the libSBML C/C++ interface, this method does
not offer the ability to pass a predicate as an argument.  The method always
returns the list of all ASTNode objects.

@return the ASTNodeList of nodes.

@warning The list returned is owned by the caller and should be deleted after
the caller is done using it.  The ASTNode objects in the list; however, are
<strong>not</strong> owned by the caller (as they still belong to the tree
itself), and therefore should not be deleted.
";
#endif
%extend ASTNode
{
  ListWrapper<ASTNode>* getListOfNodes()
  {
    List *list = $self->getListOfNodes(ASTNode_true);
    return new ListWrapper<ASTNode>(list);
  }
}


/*
 * Wraps "static void RDFAnnotationParser::parseRDFAnnotation(const XMLNode *annotation, 
 * List *CVTerms)" function as 
 * "static void RDFAnnotationParser::parseRDFAnnotation(const XMLNode *annotation, 
 *  ListWrapper<CVTerm> *CVTerms);
 *
 */

%ignore RDFAnnotationParser::parseRDFAnnotation(const XMLNode * annotation, List * CVTerms);
%ignore RDFAnnotationParser::parseRDFAnnotation(const XMLNode * annotation, List * CVTerms, const char* metaId = NULL, XMLInputStream* stream = NULL);

#ifndef SWIGRUBY

%feature("docstring") RDFAnnotationParser::parseRDFAnnotation "
Parses an annotation (given as an XMLNode tree) into a list of
CVTerm objects.

This is used to take an annotation that has been read into an SBML
model, identify the RDF elements within it, and create a list of
corresponding CVTerm (controlled vocabulary term) objects.

@param annotation XMLNode containing the annotation.
@param CVTerms list of CVTerm objects to be created.
@param metaId optional metaId, if set only the RDF annotation for this metaId will be returned.
@param stream optional XMLInputStream that facilitates error logging.

@copydetails doc_note_static_methods

@htmlinclude warn-default-args-in-docs.html
";
#endif
%extend RDFAnnotationParser
{
  static void parseRDFAnnotation(const XMLNode *annotation, ListWrapper<CVTerm> *CVTerms)
  {
    if (!CVTerms) return;

    List *list = CVTerms->getList();
    RDFAnnotationParser::parseRDFAnnotation(annotation,list);
  }

  static void parseRDFAnnotation(const XMLNode *annotation, ListWrapper<CVTerm> *CVTerms, const char* metaId = NULL, XMLInputStream* stream = NULL)
  {
    if (!CVTerms) return;

    List *list = CVTerms->getList();
    RDFAnnotationParser::parseRDFAnnotation(annotation,list, metaId, stream);
  }
}


/**
 * For reasons I cannot fathom, SWIG refuses to incorporate the comment for
 * this method into the libsbml_wrap.cpp file, even though there is nothing
 * special about this method and it looks for all the world like other
 * methods in SBase.h.  So, this next item is simply to duplicate the method
 * comment from SBase.h to here.
 */

#ifndef SWIGRUBY

%feature("docstring") SBase::hasValidLevelVersionNamespaceCombination "
Predicate returning @c true if this object's level/version and namespace
values correspond to a valid SBML specification.

The valid combinations of SBML Level, Version and Namespace as of this
release of libSBML are the following:
<ul>
<li> Level&nbsp;1 Version&nbsp;2: <code style='margin-right:0; padding-right:0'>http</code><code style='margin-left:0; padding-left:0'>://www.sbml.org/sbml/level1</code>
<li> Level&nbsp;2 Version&nbsp;1: <code style='margin-right:0; padding-right:0'>http</code><code style='margin-left:0; padding-left:0'>://www.sbml.org/sbml/level2</code>
<li> Level&nbsp;2 Version&nbsp;2: <code style='margin-right:0; padding-right:0'>http</code><code style='margin-left:0; padding-left:0'>://www.sbml.org/sbml/level2/version2</code>
<li> Level&nbsp;2 Version&nbsp;3: <code style='margin-right:0; padding-right:0'>http</code><code style='margin-left:0; padding-left:0'>://www.sbml.org/sbml/level2/version3</code>
<li> Level&nbsp;2 Version&nbsp;4: <code style='margin-right:0; padding-right:0'>http</code><code style='margin-left:0; padding-left:0'>://www.sbml.org/sbml/level2/version4</code>
<li> Level&nbsp;3 Version&nbsp;1 Core: <code style='margin-right:0; padding-right:0'>http</code><code style='margin-left:0; padding-left:0'>://www.sbml.org/sbml/level3/version1/core</code>
</ul>

@return @c true if the level, version and namespace values of this 
SBML object correspond to a valid set of values, @c false otherwise.
";


/*
 * If left as-is, the method descriptions for the constructors for
 * XMLInputStream and XMLOutputStream end up on our "Core libSBML" page in
 * the API docs rather than on the pages for the individual classes
 * themselves.  This is another case of unfathomable behavior of either
 * Doxygen or SWIG (not sure which one is to blame for this).  Adding
 * explicit docstrings declarations here solves this problem.
 */

%feature("docstring") XMLInputStream::XMLInputStream "
Creates a new XMLInputStream.

@param content the source of the stream.

@param isFile a boolean flag to indicate whether @p content is a file
name.  If @c true, @p content is assumed to be the file from which the
XML content is to be read.  If @c false, @p content is taken to be a
string that @em is the content to be read.

@param library the name of the parser library to use.

@param errorLog the XMLErrorLog object to use.

@htmlinclude warn-default-args-in-docs.html
";

%feature("docstring") XMLOutputStream::XMLOutputStream "
Creates a new XMLOutputStream that wraps the given @p stream.

@copydetails doc_programname_arguments

@copydetails doc_xml_declaration

@param stream the input stream to wrap.

@param encoding the XML encoding to declare in the output. This value should
be <code>&quot;UTF-8&quot;</code> for SBML documents.  The default value is
<code>&quot;UTF-8&quot;</code> if no value is supplied for this parameter.

@param writeXMLDecl whether to write a standard XML declaration at
the beginning of the content written on @p stream.  The default is
@c true.

@param programName an optional program name to write as a comment
in the output stream.

@param programVersion an optional version identification string to write
as a comment in the output stream.

@htmlinclude warn-default-args-in-docs.html
";

#endif
/**
 * Wrap these files.
 */

%include "std_string.i"

%include sbml/common/libsbml-version.h
%include sbml/common/operationReturnValues.h
%include sbml/common/common-documentation.h
%include sbml/common/common-sbmlerror-codes.h

%include <sbml/util/IdList.h>
%include <sbml/util/IdentifierTransformer.h>
%include <sbml/util/ElementFilter.h>

%include <sbml/SBMLReader.h>
%include sbml/SBMLWriter.h
%include sbml/SBMLTypeCodes.h
%include sbml/SBase.h
%include sbml/ListOf.h
%include sbml/Model.h
%include sbml/SBMLDocument.h
%include sbml/FunctionDefinition.h
%include sbml/UnitKind.h
%include sbml/Unit.h
%include sbml/UnitDefinition.h
%include sbml/CompartmentType.h
%include sbml/SpeciesType.h
%include sbml/Compartment.h
%include sbml/Species.h
%include sbml/Parameter.h
%include sbml/LocalParameter.h
%include sbml/InitialAssignment.h
%include sbml/Rule.h
%include sbml/AlgebraicRule.h
%include sbml/AssignmentRule.h
%include sbml/RateRule.h
%include sbml/Constraint.h
%include sbml/Reaction.h
%include sbml/KineticLaw.h
%include sbml/SimpleSpeciesReference.h
%include sbml/SpeciesReference.h
%include sbml/ModifierSpeciesReference.h
%include sbml/Event.h
%include sbml/EventAssignment.h
%include sbml/Trigger.h
%include sbml/Delay.h
%include sbml/Priority.h
%include sbml/SBO.h
%include sbml/SyntaxChecker.h
%include sbml/StoichiometryMath.h
%include sbml/SBMLNamespaces.h
%include sbml/SBMLTransforms.h
%include sbml/SBMLConstructorException.h

%include sbml/conversion/ConversionOption.h
%include sbml/conversion/ConversionProperties.h
%include sbml/conversion/SBMLConverter.h
%include sbml/conversion/SBMLConverterRegistry.h
%include sbml/conversion/SBMLFunctionDefinitionConverter.h
%include sbml/conversion/SBMLIdConverter.h
%include sbml/conversion/SBMLInferUnitsConverter.h
%include sbml/conversion/SBMLInitialAssignmentConverter.h
%include sbml/conversion/SBMLLevelVersionConverter.h
%include sbml/conversion/SBMLLocalParameterConverter.h
%include sbml/conversion/SBMLReactionConverter.h
%include sbml/conversion/SBMLRuleConverter.h
%include sbml/conversion/SBMLStripPackageConverter.h
%include sbml/conversion/SBMLUnitsConverter.h

%include sbml/validator/SBMLValidator.h
%include sbml/validator/SBMLExternalValidator.h

%include sbml/xml/XMLAttributes.h
%include sbml/xml/XMLConstructorException.h
%include sbml/xml/XMLNamespaces.h
%include sbml/xml/XMLToken.h
%include sbml/xml/XMLNode.h
%include sbml/xml/XMLTriple.h
%include sbml/xml/XMLOutputStream.h
%include sbml/xml/XMLInputStream.h
%include sbml/xml/XMLError.h
%include sbml/xml/XMLErrorLog.h

%include sbml/SBMLErrorLog.h
%include sbml/SBMLError.h

%include sbml/annotation/CVTerm.h
%include sbml/annotation/Date.h
%include sbml/annotation/ModelCreator.h
%include sbml/annotation/ModelHistory.h
%include sbml/annotation/RDFAnnotationParser.h

%include sbml/extension/ISBMLExtensionNamespaces.h
%include sbml/extension/SBaseExtensionPoint.h
%include sbml/extension/SBasePlugin.h
%include sbml/extension/SBMLDocumentPlugin.h
%include sbml/extension/SBMLExtension.h
%include sbml/extension/SBMLExtensionException.h
%include sbml/extension/SBMLExtensionNamespaces.h
%include sbml/extension/SBMLExtensionRegistry.h

%include ASTNodes.i

%include "../swig/libsbml-packages.i"
