/**
 * \file    local.i
 * \brief   Java-specific SWIG directives for wrapping libSBML API
 * \author  Ben Bornstein
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

%include "javadoc.i"
%include "std_string.i"


/**
 * Renames *::clone() to *::cloneObject().
 * In JDK 1.4.2, libsbml's *::clone() methods can't override 
 * "Object Java.lang.Object.clone()" because JDK 1.4.2 doesn't
 * allow override with different return type. 
 *
 * (2008-12-07)
 * Currently, JDK 1.5 or later, which allows a covariant return type,
 * is required for libSBML Java binding, and thus we don't have to use
 * this rename directive. However, this directive is still enabled for 
 * compatiblity.
 */

%rename(cloneObject) *::clone;


/** 
 * Rename XMLNode::equals() to XMLNode::xmlEquals(), otherwise it conflicts with the 
 * equals operation defined below
 */
%rename(xmlEquals) XMLNode::equals;
/** 
 * Rename *::getClass() to *::getClassName(), otherwise it conflicts 
 */
%rename(getClassName) *::getClass;
%rename(setClassName) *::setClass;

/**
 * Wraps covariant return types of ::clone functions.
 *
 * Currently, SWIG doesn't allow a covariant return type although
 * JDK 1.5 or later supports it.
 * Thus, the following directives are required to enable the 
 * covariant return type. 
 */

#pragma SWIG nowarn=822

%define COVARIANT_RTYPE_CLONE(_CNAME_)
%typemap(jstype) _CNAME_* _CNAME_::clone  "_CNAME_"
%enddef

COVARIANT_RTYPE_CLONE(Compartment)
COVARIANT_RTYPE_CLONE(CompartmentType)
COVARIANT_RTYPE_CLONE(Constraint)
COVARIANT_RTYPE_CLONE(Delay)
COVARIANT_RTYPE_CLONE(Event)
COVARIANT_RTYPE_CLONE(EventAssignment)
COVARIANT_RTYPE_CLONE(FunctionDefinition)
COVARIANT_RTYPE_CLONE(InitialAssignment)
COVARIANT_RTYPE_CLONE(KineticLaw)
COVARIANT_RTYPE_CLONE(Model)
COVARIANT_RTYPE_CLONE(LocalParameter)
COVARIANT_RTYPE_CLONE(Parameter)
COVARIANT_RTYPE_CLONE(Priority)
COVARIANT_RTYPE_CLONE(Reaction)
COVARIANT_RTYPE_CLONE(Rule)
COVARIANT_RTYPE_CLONE(AlgebraicRule)
COVARIANT_RTYPE_CLONE(AssignmentRule)
COVARIANT_RTYPE_CLONE(RateRule)
COVARIANT_RTYPE_CLONE(SBMLDocument)
COVARIANT_RTYPE_CLONE(Species)
COVARIANT_RTYPE_CLONE(SpeciesReference)
COVARIANT_RTYPE_CLONE(SpeciesType)
COVARIANT_RTYPE_CLONE(StoichiometryMath)
COVARIANT_RTYPE_CLONE(Trigger)
COVARIANT_RTYPE_CLONE(Unit)
COVARIANT_RTYPE_CLONE(UnitDefinition)
COVARIANT_RTYPE_CLONE(ListOf)
COVARIANT_RTYPE_CLONE(ListOfCompartmentTypes)
COVARIANT_RTYPE_CLONE(ListOfCompartments)
COVARIANT_RTYPE_CLONE(ListOfConstraints)
COVARIANT_RTYPE_CLONE(ListOfEventAssignments)
COVARIANT_RTYPE_CLONE(ListOfEvents)
COVARIANT_RTYPE_CLONE(ListOfFunctionDefinitions)
COVARIANT_RTYPE_CLONE(ListOfInitialAssignments)
COVARIANT_RTYPE_CLONE(ListOfParameters)
COVARIANT_RTYPE_CLONE(ListOfLocalParameters)
COVARIANT_RTYPE_CLONE(ListOfReactions)
COVARIANT_RTYPE_CLONE(ListOfRules)
COVARIANT_RTYPE_CLONE(ListOfSpecies)
COVARIANT_RTYPE_CLONE(ListOfSpeciesReferences)
COVARIANT_RTYPE_CLONE(ListOfSpeciesTypes)
COVARIANT_RTYPE_CLONE(ListOfUnitDefinitions)
COVARIANT_RTYPE_CLONE(ListOfUnits)




/**
 *
 * Wraps covariant return types of ListOfXXX::get functions.
 *
 */

%define COVARIANT_RTYPE_LISTOF_GET_REMOVE(_CNAME_)
%typemap(jstype) _CNAME_* ListOf ## _CNAME_ ## s::get  "_CNAME_"
%typemap(jstype) _CNAME_* ListOf ## _CNAME_ ## s::remove  "_CNAME_"
%enddef

COVARIANT_RTYPE_LISTOF_GET_REMOVE(CompartmentType)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Compartment)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(EventAssignment)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Event)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(FunctionDefinition)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(InitialAssignment)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(LocalParameter)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Parameter)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Reaction)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Rule)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(SpeciesType)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(UnitDefinition)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Constraint)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Unit)

// Only ListOfSpecies and ListOfSpeciesReference classes do not 
// match the above macro...
%typemap(jstype) Species* ListOfSpecies::get    "Species"
%typemap(jstype) Species* ListOfSpecies::remove "Species"
%typemap(jstype) SimpleSpeciesReference* ListOfSpeciesReferences::get    "SimpleSpeciesReference"
%typemap(jstype) SimpleSpeciesReference* ListOfSpeciesReferences::remove "SimpleSpeciesReference"


/**
 * Wraps the SBMLConstructorException
 *
 * The SBMLConstructorException (C++ class) is wrapped as the 
 * SBMLConstructorException (Java class) which is derived from
 * the built-in IllegalArgumentException class which is a subclass
 * of RunTimeException.
 *
 * For example, the exception can be catched in Java code as follows:
 *
 * ---------------------------------------------
 *  try
 *  {
 *    Model s = new Model(level,version);
 *  }
 *  catch (SBMLConstructorException e)
 *  {
 *     String errmsg = e.getMessage();
 *  }
 * ---------------------------------------------
 */

%ignore SBMLConstructorException::SBMLConstructorException(std::string);

%typemap(javabase) SBMLConstructorException "java.lang.IllegalArgumentException";
%typemap(javacode) SBMLConstructorException 
%{
  protected SBMLConstructorException(long cPtr, boolean cMemoryOwn, String v)
  {
    super(v);
    swigCMemOwn = cMemoryOwn;
    swigCPtr    = cPtr;
  }

  /**
   * Exception thrown by libSBML object constructors if something prevents
   * the object from being properly created.
   *
   * An example of what can cause this exception to be thrown is attempting
   * to create an SBML component with an invalid SBML Level/Version
   * combination.
   */
  public SBMLConstructorException(String v)
  {
    this(libsbmlJNI.new_SBMLConstructorException__SWIG_0(), true, v);
  }
%}

%define SBMLCONSTRUCTOR_EXCEPTION(SBASE_CLASS_NAME)
%javaexception("org.sbml.libsbml.SBMLConstructorException") SBASE_CLASS_NAME
%{
  try {
    $action
  }
  catch (const SBMLConstructorException &e) {
    jenv->ExceptionClear();
    jclass clazz = jenv->FindClass("org/sbml/libsbml/SBMLConstructorException");
    if (clazz)
      jenv->ThrowNew(clazz, e.what());
    return $null;
  }
  catch (const SBMLExtensionException &e) {
    jenv->ExceptionClear();
    jclass clazz = jenv->FindClass("org/sbml/libsbml/SBMLConstructorException");
    if (clazz)
      jenv->ThrowNew(clazz, e.what());
    return $null;
  }
%}
%enddef


SBMLCONSTRUCTOR_EXCEPTION(Compartment)
SBMLCONSTRUCTOR_EXCEPTION(CompartmentType)
SBMLCONSTRUCTOR_EXCEPTION(Constraint)
SBMLCONSTRUCTOR_EXCEPTION(Delay)
SBMLCONSTRUCTOR_EXCEPTION(Event)
SBMLCONSTRUCTOR_EXCEPTION(EventAssignment)
SBMLCONSTRUCTOR_EXCEPTION(FunctionDefinition)
SBMLCONSTRUCTOR_EXCEPTION(InitialAssignment)
SBMLCONSTRUCTOR_EXCEPTION(KineticLaw)
SBMLCONSTRUCTOR_EXCEPTION(Model)
SBMLCONSTRUCTOR_EXCEPTION(LocalParameter)
SBMLCONSTRUCTOR_EXCEPTION(Parameter)
SBMLCONSTRUCTOR_EXCEPTION(Priority)
SBMLCONSTRUCTOR_EXCEPTION(Reaction)
SBMLCONSTRUCTOR_EXCEPTION(AssignmentRule)
SBMLCONSTRUCTOR_EXCEPTION(AlgebraicRule)
SBMLCONSTRUCTOR_EXCEPTION(RateRule)
SBMLCONSTRUCTOR_EXCEPTION(Species)
SBMLCONSTRUCTOR_EXCEPTION(SpeciesReference)
SBMLCONSTRUCTOR_EXCEPTION(ModifierSpeciesReference)
SBMLCONSTRUCTOR_EXCEPTION(SpeciesType)
SBMLCONSTRUCTOR_EXCEPTION(StoichiometryMath)
SBMLCONSTRUCTOR_EXCEPTION(Trigger)
SBMLCONSTRUCTOR_EXCEPTION(Unit)
SBMLCONSTRUCTOR_EXCEPTION(UnitDefinition)
SBMLCONSTRUCTOR_EXCEPTION(SBMLDocument)
SBMLCONSTRUCTOR_EXCEPTION(SBMLNamespaces)
SBMLCONSTRUCTOR_EXCEPTION(SBMLExtensionNamespaces)

SBMLCONSTRUCTOR_EXCEPTION(ListOf)
SBMLCONSTRUCTOR_EXCEPTION(ListOfCompartments)
SBMLCONSTRUCTOR_EXCEPTION(ListOfCompartmentTypes)
SBMLCONSTRUCTOR_EXCEPTION(ListOfConstraints)
SBMLCONSTRUCTOR_EXCEPTION(ListOfEventAssignments)
SBMLCONSTRUCTOR_EXCEPTION(ListOfEvents)
SBMLCONSTRUCTOR_EXCEPTION(ListOfFunctionDefinitions)
SBMLCONSTRUCTOR_EXCEPTION(ListOfInitialAssignments)
SBMLCONSTRUCTOR_EXCEPTION(ListOfParameters)
SBMLCONSTRUCTOR_EXCEPTION(ListOfLocalParameters)
SBMLCONSTRUCTOR_EXCEPTION(ListOfReactions)
SBMLCONSTRUCTOR_EXCEPTION(ListOfRules)
SBMLCONSTRUCTOR_EXCEPTION(ListOfSpecies)
SBMLCONSTRUCTOR_EXCEPTION(ListOfSpeciesReferences)
SBMLCONSTRUCTOR_EXCEPTION(ListOfSpeciesTypes)
SBMLCONSTRUCTOR_EXCEPTION(ListOfUnitDefinitions)
SBMLCONSTRUCTOR_EXCEPTION(ListOfUnits)

/**
 * Wraps the XMLConstructorException
 *
 * The XMLConstructorException (C++ class) is wrapped as the 
 * XMLConstructorException (Java class) which is derived from
 * the built-in IllegalArgumentException class which is a subclass
 * of RunTimeException.
 *
 * For example, the exception can be catched in Java code as follows:
 *
 * ---------------------------------------------
 *  try
 *  {
 *    Model s = new Model(level,version);
 *  }
 *  catch (XMLConstructorException e)
 *  {
 *     String errmsg = e.getMessage();
 *  }
 * ---------------------------------------------
 */

%typemap(javabase) XMLConstructorException "java.lang.IllegalArgumentException";
%typemap(javacode) XMLConstructorException 
%{
  /*
   * To pass the message from an exception to the parent exception class,
   * we have to create our own variant of the constructor that takes an
   * extra string argument.
   */
  protected XMLConstructorException(long cPtr, boolean cMemoryOwn, String v)
  {
    super(v);
    swigCMemOwn = cMemoryOwn;
    swigCPtr    = cPtr;
  }

  /*
   * Next, we define the public constructor to take a string (like all basic
   * Java exception class constructors), and invoke our internal special
   * constructor with the extra argument.
   */
  public XMLConstructorException(String v)
  {
    this(libsbmlJNI.new_XMLConstructorException(), true, v);
  }
%}

/*
 * Finally, to make our string-passing constructor work, we have to disable
 * the default constructor created by SWIG in newer versions of SWIG.
 */
%ignore XMLConstructorException(std::string message);

/*
 * The following creates a macro used to wrap individual class constructors
 * that may throw XMLConstructorException.
 */
%define XMLCONSTRUCTOR_EXCEPTION(SBASE_CLASS_NAME)
%javaexception("org.sbml.libsbml.XMLConstructorException") SBASE_CLASS_NAME
%{
  try {
    $action
  }
  catch (const XMLConstructorException &e) {
    jenv->ExceptionClear();
    jclass clazz = jenv->FindClass("org/sbml/libsbml/XMLConstructorException");
    if (clazz)
      jenv->ThrowNew(clazz, e.what());
    return $null;
  }
%}
%enddef


XMLCONSTRUCTOR_EXCEPTION(XMLAttributes)
XMLCONSTRUCTOR_EXCEPTION(XMLError)
XMLCONSTRUCTOR_EXCEPTION(XMLNamespaces)
XMLCONSTRUCTOR_EXCEPTION(XMLNode)
XMLCONSTRUCTOR_EXCEPTION(XMLOutputStream)
XMLCONSTRUCTOR_EXCEPTION(XMLToken)
XMLCONSTRUCTOR_EXCEPTION(XMLTripple)


/**
 * Ignores XMLToken::clone() in order to use XMLNode::clone().
 * (XMLNode is a derived class of XMLToken)
 * In JDK 1.4.2, "XMLNode XMLNode::clone()" can't override 
 * "XMLToken XMLToken::clone()" because JDK 1.4.2 doesn't
 * allow override with different return type.
 */

//%javamethodmodifiers       XMLToken::clone "private"

/**
 * Ignores XMLErrorLog::getError(unsigned int) in order to use
 * SBMLErrorLog::getError(unsigned int).
 * (XMLErrorLog is a derived class of SBMLErrorLog)
 * In JDK 1.4.2, "SBMLError* SBMLErrorLog::getError(unsigned int)"
 * can't override "XMLError* XMLErrorLog::getError(unsigned int)"
 * due to the above mentioned reason.
 */

//%javamethodmodifiers       XMLErrorLog::getError "private"

/**
 * Turns off object destruction.  For testing purposes only.
 *
 * FIXME: Disable for the final 3.0 release.
 */
/*
%typemap (javafinalize) SWIGTYPE %{ %}
*/


/**
 * Make most libSBML constants (e.g. SBMLTypecodes) Java compile-time
 * constants so they may be used in switch statements.
 */
%include "enumsimple.swg"
%javaconst(1);


/**
 * A bug in Swig prevents these four ASTNode constants being generated
 * as Java compile-time constants.  Swig does not parse the following
 * enum correctly:
 *
 *   typedef enum
 *   {
 *       AST_PLUS    = '+'
 *     , AST_MINUS   = '-'
 *     , AST_TIMES   = '*'
 *     , AST_DIVIDE  = '/'
 *     , AST_POWER   = '^'
 *
 *
 * The generated Java code does not like the tick marks (').  To fix
 * this, we need to be explicit about (and duplicate) the value of
 * the constants here.
 */

%javaconstvalue("'+'") AST_PLUS;
%javaconstvalue("'-'") AST_MINUS;
%javaconstvalue("'*'") AST_TIMES;
%javaconstvalue("'/'") AST_DIVIDE;
%javaconstvalue("'^'") AST_POWER;

/**
 * Adds DownCastBase(long cPtr, boolean owner) method for package extension
 */
%typemap(javacode) SBMLExtension
%{
  /**
   * SBMLExtension derived classes must override this method
   */
  public SBasePlugin DowncastSBasePlugin(long cPtr, boolean owner)
  {
    if (cPtr == 0) return null;

    return new SBasePlugin(cPtr,false);
  }


  /**
   * SBMLExtension derived classes must override this method
   */
  public SBase DowncastSBase(long cPtr, boolean owner)
  {
    if (cPtr == 0) return null;

    return new SBase(cPtr, owner);
  }
%}


/**
 * @return the most specific Java object possible for the given SBase
 * object.
 */
%pragma(java) modulecode =
%{
	
  /**
   * Downcast a package extension object to its specific package class.
   *
   * This method is used in the implementation of libSBML extensions to
   * support SBML Level&nbsp;3 packages.  It allows an object to be
   * downcast to the actual {@link SBMLExtension} object it is.
   *
   * @param cPtr the the pointer to the object
   * @param owner if <code>true</code>, it indicates the caller will "own"
   * the memory associated with the object and will be responsible for
   * freeing it.
   *
   * @return the {@link SBMLExtension} for the package
   *
   * @internal
   */
  public static SBMLExtension DowncastExtension(long cPtr, boolean owner)
  {		
    if (cPtr == 0) return null;
		
    SBMLExtension ext = new SBMLExtension(cPtr, false);
    String pkgName = ext.getName();
%}
%include "local-downcast-extension.i"
%pragma(java) modulecode =
%{
    return new SBMLExtension(cPtr,owner);
  }     
        
  /**
   * SBMLExtension derived classes must override this method
   * @internal
   */
  public static SBasePlugin DowncastSBasePlugin(long cPtr, boolean owner)
  {
    if (cPtr == 0) return null;

    SBasePlugin sbp = new SBasePlugin(cPtr,false);
    String pkgName = sbp.getPackageName();

    SBMLExtension sbmlext = SBMLExtensionRegistry.getInstance().getExtension(pkgName);
    if (sbmlext != null)
    {
      return sbmlext.DowncastSBasePlugin(cPtr,owner);
    }
    return new SBasePlugin(cPtr,owner);
  }

  /**
   * @internal
   */
  public static SBMLConverter DowncastSBMLConverter(long cPtr, boolean owner)
  {
    if (cPtr == 0) return null;
                
    SBMLConverter con = new SBMLConverter(cPtr, false);
    String conName = con.getName();
    
    if (conName.equals("SBML Units Converter"))
      return new SBMLUnitsConverter(cPtr,owner);
    else if (conName.equals("SBML Strip Package Converter"))
      return new SBMLStripPackageConverter(cPtr,owner);
    else if (conName.equals("SBML Rule Converter"))
      return new SBMLRuleConverter(cPtr,owner);
    else if (conName.equals("SBML Reaction Converter"))
      return new SBMLReactionConverter(cPtr,owner);
    else if (conName.equals("SBML Local Parameter Converter"))
      return new SBMLLocalParameterConverter(cPtr,owner);
    else if (conName.equals("SBML Level Version Converter"))
      return new SBMLLevelVersionConverter(cPtr,owner);
    else if (conName.equals("SBML Initial Assignment Converter"))
      return new SBMLInitialAssignmentConverter(cPtr,owner);
    else if (conName.equals("SBML Infer Units Converter"))
      return new SBMLInferUnitsConverter(cPtr,owner);
    else if (conName.equals("SBML Id Converter"))
      return new SBMLIdConverter(cPtr,owner);
    else if (conName.equals("SBML Function Definition Converter"))
      return new SBMLFunctionDefinitionConverter(cPtr,owner);
%}
%include "local-downcast-converters.i"
%pragma(java) modulecode =
%{		
    return new SBMLConverter(cPtr,owner);
  }
  
  /**
   * @internal
   */
  public static SBMLNamespaces DowncastSBMLNamespaces(long cPtr, boolean owner)
  {
    if (cPtr == 0) return null;
                
    SBMLNamespaces sbn = new SBMLNamespaces(cPtr, false);
    if (sbn != null)
    {
      XMLNamespaces ns = sbn.getNamespaces();
%}
%include "local-downcast-namespaces.i"
%pragma(java) modulecode =
%{                              
    }
    return new SBMLNamespaces(cPtr, owner);
  }     
  
  /**
   * Internal method.
   *
   * @internal
   */
  public static SBase DowncastSBase(long cPtr, boolean owner)
  {
    if (cPtr == 0) return null;

    SBase sb = new SBase(cPtr,false);
    String pkgName = sb.getPackageName();
    if (pkgName.equals("core"))
    {
      switch( sb.getTypeCode() )
      {
        case libsbmlConstants.SBML_COMPARTMENT:
          return new Compartment(cPtr, owner);
  
        case libsbmlConstants.SBML_COMPARTMENT_TYPE:
          return new CompartmentType(cPtr, owner);
  
        case libsbmlConstants.SBML_CONSTRAINT:
          return new Constraint(cPtr, owner);
  
        case libsbmlConstants.SBML_DOCUMENT:
          return new SBMLDocument(cPtr, owner);
  
        case libsbmlConstants.SBML_DELAY:
          return new Delay(cPtr, owner);
  
        case libsbmlConstants.SBML_EVENT:
          return new Event(cPtr, owner);

        case libsbmlConstants.SBML_EVENT_ASSIGNMENT:
          return new EventAssignment(cPtr, owner);

        case libsbmlConstants.SBML_FUNCTION_DEFINITION:
          return new FunctionDefinition(cPtr, owner);
  
        case libsbmlConstants.SBML_INITIAL_ASSIGNMENT:
          return new InitialAssignment(cPtr, owner);

        case libsbmlConstants.SBML_KINETIC_LAW:
          return new KineticLaw(cPtr, owner);

        case libsbmlConstants.SBML_LIST_OF:
          String name = sb.getElementName();
          if(name.equals("listOf")){
            return new ListOf(cPtr, owner);
          }
          else if(name.equals("listOfCompartments")){
            return new ListOfCompartments(cPtr, owner);
          }
          else if(name.equals("listOfCompartmentTypes")){
            return new ListOfCompartmentTypes(cPtr, owner);
          }
          else if(name.equals("listOfConstraints")){
            return new ListOfConstraints(cPtr, owner);
          }
          else if(name.equals("listOfEvents")){
            return new ListOfEvents(cPtr, owner);
          }
          else if(name.equals("listOfEventAssignments")){
            return new ListOfEventAssignments(cPtr, owner);
          }
          else if(name.equals("listOfFunctionDefinitions")){
            return new ListOfFunctionDefinitions(cPtr, owner);
          }
          else if(name.equals("listOfInitialAssignments")){
            return new ListOfInitialAssignments(cPtr, owner);
          }
          else if(name.equals("listOfParameters")){
            return new ListOfParameters(cPtr, owner);
          }
          else if(name.equals("listOfLocalParameters")){
            return new ListOfLocalParameters(cPtr, owner);
          }
          else if(name.equals("listOfReactions")){
            return new ListOfReactions(cPtr, owner);
          }
          else if(name.equals("listOfRules")){
            return new ListOfRules(cPtr, owner);
          }
          else if(name.equals("listOfSpecies")){
            return new ListOfSpecies(cPtr, owner);
          }
          else if(name.equals("listOfUnknowns")){
            return new ListOfSpeciesReferences(cPtr, owner);
          }
          else if(name.equals("listOfReactants")){
            return new ListOfSpeciesReferences(cPtr, owner);
          }
          else if(name.equals("listOfProducts")){
            return new ListOfSpeciesReferences(cPtr, owner);
          }
          else if(name.equals("listOfModifiers")){
            return new ListOfSpeciesReferences(cPtr, owner);
          }
          else if(name.equals("listOfSpeciesTypes")){
            return new ListOfSpeciesTypes(cPtr, owner);
          }
          else if(name.equals("listOfUnits")){
            return new ListOfUnits(cPtr, owner);
          }
          else if(name.equals("listOfUnitDefinitions")){
            return new ListOfUnitDefinitions(cPtr, owner);
          }
          return new ListOf(cPtr, owner);

        case libsbmlConstants.SBML_MODEL:
          return new Model(cPtr, owner);

        case libsbmlConstants.SBML_PARAMETER:
          return new Parameter(cPtr, owner);

      case libsbmlConstants.SBML_PRIORITY:
        return new Priority(cPtr, owner);

      case libsbmlConstants.SBML_LOCAL_PARAMETER:
        return new LocalParameter(cPtr, owner);

        case libsbmlConstants.SBML_REACTION:
          return new Reaction(cPtr, owner);

        case libsbmlConstants.SBML_SPECIES:
          return new Species(cPtr, owner);

        case libsbmlConstants.SBML_SPECIES_REFERENCE:
          return new SpeciesReference(cPtr, owner);

        case libsbmlConstants.SBML_MODIFIER_SPECIES_REFERENCE:
          return new ModifierSpeciesReference(cPtr, owner);

        case libsbmlConstants.SBML_SPECIES_TYPE:
          return new SpeciesType(cPtr, owner);

        case libsbmlConstants.SBML_TRIGGER:
          return new Trigger(cPtr, owner);

        case libsbmlConstants.SBML_UNIT_DEFINITION:
          return new UnitDefinition(cPtr, owner);

        case libsbmlConstants.SBML_UNIT:
          return new Unit(cPtr, owner);

        case libsbmlConstants.SBML_ALGEBRAIC_RULE:
          return new AlgebraicRule(cPtr, owner);

        case libsbmlConstants.SBML_ASSIGNMENT_RULE:
          return new AssignmentRule(cPtr, owner);

        case libsbmlConstants.SBML_RATE_RULE:
          return new RateRule(cPtr, owner);

        case libsbmlConstants.SBML_STOICHIOMETRY_MATH:
          return new StoichiometryMath(cPtr, owner);

        default:
          return new SBase(cPtr, owner);
      }
    }
    else
    {
      SBMLExtension sbmlext = SBMLExtensionRegistry.getInstance().getExtension(pkgName);
      if (sbmlext != null)
      {
        return sbmlext.DowncastSBase(cPtr,owner);
      }
    }
    return new SBase(cPtr, owner);
  }
  
%}

#ifndef LIBSBML_USE_LEGACY_MATH

%pragma(java) modulecode =
%{ 
  public static ASTBase DowncastASTBase(long cPtr, boolean owner)
  {
    if (cPtr == 0) return null;

    ASTBase ab = new ASTBase(cPtr,false);
	switch( ab.getTypeCode() )
    {
		default:
	    case libsbmlConstants.AST_TYPECODE_BASE:
          return new ASTBase(cPtr, owner);
		  /*
	    case libsbmlConstants.AST_TYPECODE_CN_BASE:
          return new ASTCnBase(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_FUNCTION_BASE:
          return new ASTFunctionBase(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_NUMBER:
          return new ASTNumber(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_CN_INTEGER:
          return new ASTCnIntegerNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_CN_EXPONENTIAL:
          return new ASTCnExponentialNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_CN_RATIONAL:
          return new ASTCnRationalNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_CN_REAL:
          return new ASTCnRealNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_CSYMBOL:
          return new ASTCSymbol(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_CSYMBOL_AVOGADRO:
          return new ASTCSymbolAvogadroNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_CSYMBOL_DELAY:
          return new ASTCSymbolDelayNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_CSYMBOL_TIME:
          return new ASTCSymbolTimeNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_FUNCTION:
          return new ASTFunction(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_FUNCTION_UNARY:
          return new ASTUnaryFunctionNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_FUNCTION_BINARY:
          return new ASTBinaryFunctionNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_FUNCTION_NARY:
          return new ASTNaryFunctionNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_FUNCTION_PIECEWISE:
          return new ASTPiecewiseFunctionNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_FUNCTION_LAMBDA:
          return new ASTLambdaFunctionNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_FUNCTION_CI:
          return new ASTCiFunctionNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_FUNCTION_SEMANTIC:
          return new ASTSemanticsNode(cPtr, owner);
	    case libsbmlConstants.AST_TYPECODE_FUNCTION_QUALIFIER:
          return new ASTQualifierNode(cPtr, owner);*/
	    case libsbmlConstants.AST_TYPECODE_ASTNODE:
          return new ASTNode(cPtr, owner);

	}	
    //return new ASTBase(cPtr, owner);
  }
  
%}

/**
 * Convert ASTBase objects into the most specific object possible.
 */
%typemap("javaout") ASTBase*
{
  return libsbml.DowncastASTBase($jnicall, $owner);
}


#endif


/**
 * Convert SBMLExtension objects into the most specific object possible.
 */
%typemap("javaout") SBMLExtension*
{
	return libsbml.DowncastExtension($jnicall, $owner);
}


/**
 * Convert SBMLConverter objects into the most specific object possible.
 */
%typemap("javaout") SBMLConverter*
{
	return libsbml.DowncastSBMLConverter($jnicall, $owner);
}

/**
 * Convert SBMLExtension objects into the most specific object possible.
 */
%typemap("javaout") SBMLExtension*
{
	return libsbml.DowncastExtension($jnicall, $owner);
}


/**
 * Convert SBase objects into the most specific object possible.
 */
%typemap("javaout") SBase*
{
  return libsbml.DowncastSBase($jnicall, $owner);
}

/**
 * Convert Rule objects into the most specific object possible.
 */
%typemap("javaout") Rule*
{
  return (Rule) libsbml.DowncastSBase($jnicall, $owner);
}

/**
 * Convert SimpleSpeciesReference objects into the most specific object possible.
 */
%typemap("javaout") SimpleSpeciesReference*
{
  return (SimpleSpeciesReference) libsbml.DowncastSBase($jnicall, $owner);
}


/**
 * Convert SBMLNamespaces objects into the most specific object possible.
 */
%typemap("javaout") SBMLNamespaces*
{
  return libsbml.DowncastSBMLNamespaces($jnicall, $owner);
}

/**
 * Convert SBasePlugin objects into the most specific object possible.
 */
%typemap("javaout") SBasePlugin*
{
	return libsbml.DowncastSBasePlugin($jnicall, $owner);
}



/**
 * getCPtrAndDisown() is like getCPtr() but it also sets the SWIG memory
 * ownsership flag to false.
 *
 * We used to use %typemap(javagetcptr), but this has been deprecated
 * in SWIG 1.3.24.  Instead we add getCPtrAndDisown() from the incantation
 * below (taken from the SWIG 1.3.24 CHANGES file).
 */

/* Utility macro for manipulating the Java body code method attributes */
%define SWIGJAVA_ATTRIBS(TYPENAME, CTOR_ATTRIB, GETCPTR_ATTRIB)

%typemap(javabody) TYPENAME
%{
   private long swigCPtr;
   protected boolean swigCMemOwn;

   CTOR_ATTRIB $javaclassname(long cPtr, boolean cMemoryOwn)
   {
     swigCMemOwn = cMemoryOwn;
     swigCPtr    = cPtr;
   }

   GETCPTR_ATTRIB static long getCPtr($javaclassname obj)
   {
     return (obj == null) ? 0 : obj.swigCPtr;
   }

   GETCPTR_ATTRIB static long getCPtrAndDisown ($javaclassname obj)
   {
     long ptr = 0;

     if (obj != null)
     {
       ptr             = obj.swigCPtr;
       obj.swigCMemOwn = false;
     }

     return ptr;
   }
%}


#if SWIG_VERSION >= 0x020000

%typemap(javabody_derived) TYPENAME
%{
   private long swigCPtr;

   CTOR_ATTRIB $javaclassname(long cPtr, boolean cMemoryOwn)
   {
     super($moduleJNI.$javaclassname_SWIGUpcast(cPtr), cMemoryOwn);
     swigCPtr = cPtr;
   }

   GETCPTR_ATTRIB static long getCPtr($javaclassname obj)
   {
     return (obj == null) ? 0 : obj.swigCPtr;
   }

   GETCPTR_ATTRIB static long getCPtrAndDisown ($javaclassname obj)
   {
     long ptr = 0;

     if (obj != null)
     {
       ptr             = obj.swigCPtr;
       obj.swigCMemOwn = false;
     }

     return ptr;
   }
%}

#else

%typemap(javabody_derived) TYPENAME
%{
   private long swigCPtr;

   CTOR_ATTRIB $javaclassname(long cPtr, boolean cMemoryOwn)
   {
     super($moduleJNI.SWIG$javaclassnameUpcast(cPtr), cMemoryOwn);
     swigCPtr = cPtr;
   }

   GETCPTR_ATTRIB static long getCPtr($javaclassname obj)
   {
     return (obj == null) ? 0 : obj.swigCPtr;
   }

   GETCPTR_ATTRIB static long getCPtrAndDisown ($javaclassname obj)
   {
     long ptr = 0;

     if (obj != null)
     {
       ptr             = obj.swigCPtr;
       obj.swigCMemOwn = false;
     }

     return ptr;
   }
%}

#endif

%enddef

/* The default is protected getCPtr, protected constructor */
SWIGJAVA_ATTRIBS(SWIGTYPE, protected, protected)

/* Public getCPtr method, protected constructor */
%define PUBLIC_GETCPTR(TYPENAME)
SWIGJAVA_ATTRIBS(TYPENAME, protected, public)
%enddef

/* Public getCPtr method, public constructor */
%define PUBLIC_BODYMETHODS(TYPENAME)
SWIGJAVA_ATTRIBS(TYPENAME, public, public)
%enddef

/**
 *
 * Overrides the 'equals' method for SBase subclasses and other classes
 * in libsbml.
 *
 * By default, 'equals' method ( and '==' operator) for each wrapped class
 * object returns 'true' if the given two objects refer to the same 
 * *Java proxy object* (not the underlying C++ object). 
 * For example, the following code returns 'true'.
 *
 *   Model m = new Model();
 *   m.createReaction();
 *   Reaction r1  = m.getReaction(0);
 *   Reaction r2 = r1;
 *   return r1.equals(r2);  <---- this returns 'true'
 *
 * On the other hand, the following code returns 'false' in spite of
 * the same underlying C++ objects.
 *
 *   Model m = new Model();
 *   m.createReaction();
 *   Reaction r1 = m.getReaction(0);
 *   Reaction r2 = m.getReaction(0);
 *   return r1.equals(r2);  <---- this returns 'false'
 *
 * The following override changes the behaviour of 'equals' method such that
 * returns 'true' if the given two objects refer to the same underlying C++ 
 * object (i.e. 'true' is returned in the both above examples).
 *
 * (Unfortunately, '==' operator can't be overidden in Java.
 *  Thus, the underlying C++ objects can't be compared by the '==' operator.)
 * 
 */

%define SWIGJAVA_EQUALS(CLASS)
%typemap("javacode") CLASS
%{
  /**
   * Equality comparison method for CLASS.
   * <p>
   * Because the Java methods for libSBML are actually wrappers around code
   * implemented in C++ and C, certain operations will not behave as
   * expected.  Equality comparison is one such case.  An instance of a
   * libSBML object class is actually a <em>proxy object</em>
   * wrapping the real underlying C/C++ object.  The normal <code>==</code>
   * equality operator in Java will <em>only compare the Java proxy objects</em>,
   * not the underlying native object.  The result is almost never what you
   * want in practical situations.  Unfortunately, Java does not provide a
   * way to override <code>==</code>.
   *  <p>
   * The alternative that must be followed is to use the
   * <code>equals()</code> method.  The <code>equals</code> method on this
   * class overrides the default java.lang.Object one, and performs an
   * intelligent comparison of instances of objects of this class.  The
   * result is an assessment of whether two libSBML Java objects are truly 
   * the same underlying native-code objects.
   *  <p>
   * The use of this method in practice is the same as the use of any other
   * Java <code>equals</code> method.  For example,
   * <em>a</em><code>.equals(</code><em>b</em><code>)</code> returns
   * <code>true</code> if <em>a</em> and <em>b</em> are references to the
   * same underlying object.
   *
   * @param sb a reference to an object to which the current object
   * instance will be compared
   *
   * @return <code>true</code> if <code>sb</code> refers to the same underlying 
   * native object as this one, <code>false</code> otherwise
   */
  public boolean equals(Object sb)
  {
    if ( this == sb ) 
    {
      return true;
    }
    return swigCPtr == getCPtr((CLASS)(sb));
  }

  /**
   * Returns a hashcode for this CLASS object.
   *
   * @return a hash code usable by Java methods that need them.
   */
  public int hashCode()
  {
    return (int)(swigCPtr^(swigCPtr>>>32));
  }
%}
%enddef

SWIGJAVA_EQUALS(SBase)
SWIGJAVA_EQUALS(SBMLReader)
SWIGJAVA_EQUALS(SBMLWriter)
SWIGJAVA_EQUALS(ASTNode)
SWIGJAVA_EQUALS(CVTerm)
SWIGJAVA_EQUALS(Date)
SWIGJAVA_EQUALS(ModelHistory)
SWIGJAVA_EQUALS(ModelCreator)
SWIGJAVA_EQUALS(XMLNamespaces)
SWIGJAVA_EQUALS(SBMLNamespaces)
SWIGJAVA_EQUALS(XMLAttributes)
SWIGJAVA_EQUALS(XMLToken)
SWIGJAVA_EQUALS(XMLNode)
SWIGJAVA_EQUALS(XMLTriple)
SWIGJAVA_EQUALS(XMLError)
SWIGJAVA_EQUALS(XMLErrorLog)
SWIGJAVA_EQUALS(XMLOutputStream)

/**
 * Part of libSBML methods takeover ownership of passed-in objects, so we need
 * to make sure SWIG disowns the object.
 * (Most libSBML methods don't takeover ownership since 3.0.0)
 *
 */

/**
 * takeover ownership
 *
 * - void ListOf::appendAndOwn(SBase* item)
 */
%typemap(javain) SBase*       item "SBase.getCPtrAndDisown($javainput)";
%typemap(javain) const SBase* item "SBase.getCPtr($javainput)";

/**
 * takeover ownership
 *
 * - void ASTNode::addChild (ASTNode* child)
 * - void ASTNode::prependChild (ASTNode* child)
 */
%typemap(javain) ASTNode*       child "ASTNode.getCPtrAndDisown($javainput)";
%typemap(javain) const ASTNode* child "ASTNode.getCPtr($javainput)";

/**
 * takeover ownership
 *
 * - void ASTNode::insertChild (unsigned int n, ASTNode *newChild)
 * - void ASTNode::replaceChild(unsigned int n, ASTNode *newChild)
 */
%typemap(javain) ASTNode*       newChild "ASTNode.getCPtrAndDisown($javainput)";
%typemap(javain) const ASTNode* newChild "ASTNode.getCPtr($javainput)";

/**
 * takeover ownership
 *
 * - void ASTNode::addSemanticsAnnotation (XMLNode* sAnnotation);
 */
%typemap(javain) XMLNode*       sAnnotation "XMLNode.getCPtrAndDisown($javainput)";
%typemap(javain) const XMLNode* sAnnotation "XMLNode.getCPtr($javainput)";


/**
 * On Windows, a string for filename should be encoded by ANSI CP 
 * instead of UTF-8 because file I/O APIs internally used in libSBML 
 * requires an ANSI CP encoded string for the given filename.
 *  
 *  1) SBMLReader::readSBML(const std::string& filename)
 *  2) readSBML(const char* filename)
 *  3) SBMLWriter::writeSBML(SBMLDocument*, const std::string& filename)
 *  4) writeSBML(SBMLDocument*, const char* filename)
 */

//
// UTF8 -> ANSI CP (for const std::string& filename)
//
%typemap("in") const std::string& filename (const char* arg_pstr, std::string arg_str) 
%{
  if(!$input) {
    SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "null std::string");
    return $null;
  }
  arg_pstr = (char const *)jenv->GetStringUTFChars($input, 0);
  if (!arg_pstr) return $null;
#ifdef WIN32
    char*  mbstr = convertUTF8ToACP(arg_pstr);
    if (!mbstr)
    {
      jenv->ReleaseStringUTFChars($input, arg_pstr);
      return $null;
    }

    arg_str.assign(mbstr);
    delete[] mbstr;
#else
  arg_str.assign(arg_pstr);
#endif
  $1 = &arg_str;
  jenv->ReleaseStringUTFChars($input, arg_pstr);

%}



//
// Unicode -> ANSI CP (for const char* filename)
//
%typemap("in")  const char* filename (const char* arg_pstr)
%{
  if ($input) {
    arg_pstr = (char const *)jenv->GetStringUTFChars($input, 0);
    if (!arg_pstr) return $null;
  }
  else
  {
    arg_pstr = 0;
  }
#ifdef WIN32
  $1 = convertUTF8ToACP(arg_pstr);
  if (!$1)
  {
    jenv->ReleaseStringUTFChars($input, (const char*)arg_pstr);
    return $null;
  }
  jenv->ReleaseStringUTFChars($input, (const char*)arg_pstr);
#else
  $1 = (char*)arg_pstr;
#endif
%}

%typemap("freearg")  const char* filename 
%{
#ifdef WIN32
  delete[] $1;
#else
  if ($1) jenv->ReleaseStringUTFChars($input, (const char*)$1);
#endif
%}


/**
 * Some combinations of platforms and underlying XML parsers *require*
 * an absolute path to a filename while others do not.  It's best to
 * hide this from the end-user by making SBMLReader.readSBML() and
 * readSBML() always compute an absolute path and filename.
 */

%pragma(java) modulecode =
%{
   static String getAbsolutePath(String filename)
   {
     java.io.File file = new java.io.File(filename);
     return file.getAbsolutePath();
   }
%}

%typemap("javain") const std::string& filename "libsbml.getAbsolutePath($javainput)";
%typemap("javain") const char* filename        "libsbml.getAbsolutePath($javainput)";

/**
 * Wraps std::ostream by implementing three simple wrapper classes.
 *
 * 1) OStream wraps std::cout, std::cerr, and std::clog.
 *    The following public final static variables are provied in
 *    libsbml class like in C++.
 *
 *    1. public final static OStream cout;
 *    2. public final static OStream cerr;
 *    3. public final static OStream clog;
 *
 * 2) OFStream (derived class of OStream) wraps std::ofstream 
 *    with ios_base::cout (default) or ios_base::app flag. 
 *
 * 3) OStringStream (derived class of OStream) wraps std::ostringstream.
 *
 * These wrapper classes provide only the minimum functions.
 *
 * (sample code) -----------------------------------------------------
 *
 * 1. wraps std::cout
 *
 *    XMLOutputStream xos = new XMLOutputStream(libsbml.cout);
 *
 * 2. wraps std::cerr
 *
 *    SBMLDocument d = libsbml.readSBML("foo.xml");
 *    if ( d.getNumErrors() > 0) {
 *       d.printErrors(libsbml.cerr);
 *    }
 *
 * 3. wraps std::ofstream (write to file "foo.xml")
 *
 *    OFStream   ofs = new OFStream("foo.xml");
 *    SBMLDocument d = libsbml.readSBML("foo.xml");
 *    SBMLWriter   w = new SBMLWriter();
 *    w.writeSBML(d,ofs);
 *
 * 4. wraps std::ofstream (write to file "foo.xml" with append mode)
 *
 *    OFStream ofs = new OFStream("foo.xml",true);
 *    XMLOutputStream xos = new XMLOutputStream(ofs);
 *
 * 5. wraps std::ostringstream 
 *
 *    OStringStream   oss = new OStringStream();
 *    XMLOutputStream xos = new XMLOutputStream(oss);
 *    ...
 *    oss.endl();
 *    String s = oss.str();
 *
 */

%typemap(jstype) std::ostream& "OStream"
%typemap(javain) std::ostream& "SWIGTYPE_p_std__ostream.getCPtr($javainput.get_ostream())";

%include "OStream.h"

%{
#include "OStream.cpp"
%}

%pragma(java) modulecode =
%{
  /**
    * Stream handle for low-level C++ standard output stream.
    * <p>
    * A few libSBML methods accept an argument for indicating where to send
    * text string output.  An example is the {@link
    * SBMLDocument#printErrors} method.  However, the methods use C++ style
    * streams and not Java stream objects.  The OStream object class in the
    * libSBML Java interface provides a wrapper for the underlying C++
    * streams.  The present object (cout) is a static final variable that
    * can be used directly from your code.  An example use might be
    * something like this:
    * <p>
    * <div class="fragment"><pre class="fragment">
    * SBMLDocument document = libsbml.readSBML("somefile.xml");
    * if (document.getNumErrors() > 0)
    * {
    *     document.printErrors(libsbml.cout);
    *     println("Please correct the above problems first.");
    *     System.exit(1);
    * }</div>
    *
    * @see #cerr
    * @see #clog
    */
  public final static OStream cout;


  /**
    * Stream handle for low-level C++ standard error stream.
    * <p>
    * A few libSBML methods accept an argument for indicating where to send
    * text string output.  An example is the {@link
    * SBMLDocument#printErrors} method.  However, the methods use C++ style
    * streams and not Java stream objects.  The OStream object class in the
    * libSBML Java interface provides a wrapper for the underlying C++
    * streams.  The present object (cerr) is a static final variable that
    * can be used directly from your code.  An example use might be
    * something like this:
    * <p>
    * <div class="fragment"><pre class="fragment">
    * SBMLDocument document = libsbml.readSBML("somefile.xml");
    * if (document.getNumErrors() > 0)
    * {
    *     document.printErrors(libsbml.cerr);
    *     println("Please correct the above problems first.");
    *     System.exit(1);
    * }</div>
    * <p>
    * By default, most operating systems have have their standard error and
    * logging output streams directed to the console/terminal, and this is
    * where text messages will be shown.  This can usually be redirected
    * elsewhere, although how to do this depends on the specific environment
    * where the program is running.
    *
    * @see #cout
    * @see #clog
    */
  public final static OStream cerr;


  /**
    * Stream handle for low-level C++ standard logging stream.
    * <p>
    * A few libSBML methods accept an argument for indicating where to send
    * text string output.  An example is the {@link
    * SBMLDocument#printErrors} method.  However, the methods use C++ style
    * streams and not Java stream objects.  The OStream object class in the
    * libSBML Java interface provides a wrapper for the underlying C++
    * streams.  The present object (clog) is a static final variable that
    * can be used directly from your code.  An example use might be
    * something like this:
    * <p>
    * <div class="fragment"><pre class="fragment">
    * SBMLDocument document = libsbml.readSBML("somefile.xml");
    * if (document.getNumErrors() > 0)
    * {
    *     document.printErrors(libsbml.clog);
    *     println("Please correct the above problems first.");
    *     System.exit(1);
    * }</div>
    * <p>
    * By default, most operating systems have have their standard error and
    * logging output streams directed to the console/terminal, and this is
    * where text messages will be shown.  This can usually be redirected
    * elsewhere, although how to do this depends on the specific environment
    * where the program is running.
    *
    * @see #cout
    * @see #cerr
    */
  public final static OStream clog;

  static {
    cout = new OStream(OStream.COUT); 
    cerr = new OStream(OStream.CERR); 
    clog = new OStream(OStream.CLOG); 
  }

  /**
   * This private constructor does nothing and never invoked.
   * The purpose of this constuctor is to hide a default constructor of this 
   * class in javadoc documentation.
   */
  private libsbml() {}

%}



/**
 *  Wraps the following functions by using the corresponding
 *  ListWrapper<TYPENAME> class.
 *
 *  - List* ModelHistory::getListCreators()
 *  - List* ModelHistory::getListModifiedDates()
 *  - List* SBase::getCVTerms()
 *  - List* SBMLNamespaces::getSupportedNamespaces()
 *
 *  ListWrapper<TYPENAME> class is wrapped as TYPENAMEListclass.
 *  So, the above functions are wrapped as follows:
 *
 *  - ModelCreatorList ModelHistory.getListCreators()
 *  - DateList         ModelHistory.getListModifiedDates()
 *  - CVTermList       SBase.getCVTerms()
 *  - SBMLNamespacseList SBMLNamespaces.getSupportedNamespaces()
 *
 */

%define LIST_WRAPPER(_FNAME_,_TYPENAME_)
%typemap(jstype)  List* _FNAME_ %{ _TYPENAME_ ## List %}

%typemap(javaout) List* _FNAME_ 
{ 
  long cPtr = $jnicall;
  return (cPtr == 0) ? null : new  _TYPENAME_ ## List(cPtr, true);
}

%typemap(out) List* _FNAME_ 
{
   ListWrapper<_TYPENAME_> *listw = ($1 != 0) ? new ListWrapper<_TYPENAME_>($1) : 0;  
   *( ListWrapper<_TYPENAME_>   **)&$result = listw;
}
%enddef

LIST_WRAPPER(ModelHistory::getListCreators,ModelCreator)
LIST_WRAPPER(ModelHistory::getListModifiedDates,Date)
LIST_WRAPPER(SBase::getCVTerms,CVTerm)
LIST_WRAPPER(SBase::getListOfAllElements,SBase)
LIST_WRAPPER(SBasePlugin::getListOfAllElements,SBase)
LIST_WRAPPER(SBase::getListOfAllElementsFromPlugins,SBase)
LIST_WRAPPER(SBMLNamespaces::getSupportedNamespaces,SBMLNamespaces)


%include "local-packages.i"


