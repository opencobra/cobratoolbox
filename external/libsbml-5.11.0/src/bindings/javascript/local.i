/**
 * @file    local.i
 * @brief   Ruby-specific SWIG directives for wrapping libSBML API
 * @author  Alex Gutteridge
 * @author  Ben Bornstein
 * @author  Akiya Jouraku
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

#pragma SWIG nowarn=509
%warnfilter(365) operator+=;
%warnfilter(401) basic_ios<char>;    
%warnfilter(801) basic_string<char>; 

/**
 *  Wraps std::cout, std::cerr, std::clog, std::ostream, and std::ostringstream, 
 *
 * (sample code) -----------------------------------------------------
 *
 * 1. wraps std::cout
 *
 *    xos = LibSBML::XMLOutputStream.new(LibSBML::cout)
 *
 * 2. wraps std::cerr
 *
 *    d = LibSBML::readSBML("foo.xml")
 *    if ( d.getNumErrors > 0 ) 
 *       d.printErrors(LibSBML::cerr)
 *    end
 *
 * 3. wraps std::ostringstream
 *
 *    oss = LibSBML::Ostringstream.new()
 *    xos = LibSBML::XMLOutputStream.new(oss)
 *    ...
 *    LibSBML::endl(oss)
 *    s = oss.str();
 * 
 */

// ignores C++ specific methods in std::string.
%ignore std::basic_string<char>::begin;
%ignore std::basic_string<char>::end;
%ignore std::basic_string<char>::rbegin;
%ignore std::basic_string<char>::rend;
%ignore std::basic_string<char>::get_allocator;
%ignore std::basic_string<char>::capacity;
%ignore std::basic_string<char>::reserve;

//%include <std_alloc.i>
//%include <std_basic_string.i>
%include <std_string.i>

namespace std
{
  // Template class basic ios
  template<typename _CharT, typename _Traits = char_traits<_CharT> >
  class basic_ios : public ios_base {};

  // Template class basic_ostream
  template<typename _CharT, typename _Traits = char_traits<_CharT> >
  class basic_ostream : virtual public basic_ios<_CharT, _Traits> 
  {
    public:
      explicit
      basic_ostream(std::basic_streambuf<_CharT, _Traits>* __sb);
      virtual 
      ~basic_ostream();
  };

  // Template class basic_ostringstream
  template<typename _CharT, typename _Traits = char_traits<_CharT>,
           typename _Alloc = allocator<_CharT> >
  class basic_ostringstream : public basic_ostream<_CharT, _Traits>
  {
    public:
      explicit
      basic_ostringstream(std::ios_base::openmode __mode = std::ios_base::out);
      ~basic_ostringstream();

      basic_string<_CharT, _Traits, _Alloc> 
      str() const;

      void
      str(const basic_string<_CharT, _Traits, _Alloc>& __s);
  };

  template<typename _CharT, typename _Traits = char_traits<_CharT> >
  basic_ostream<_CharT, _Traits>& 
  endl(basic_ostream<_CharT, _Traits>&);

  template<typename _CharT, typename _Traits = char_traits<_CharT> >
  basic_ostream<_CharT, _Traits>& 
  flush(basic_ostream<_CharT, _Traits>&);
}

namespace std
{
  /**
   *  std::ostream and std::ostringstream 
   *  (std::ios is not wrapped)
   */
  typedef basic_ios<char>           ios;
  typedef basic_ostream<char>       ostream ;
  typedef basic_ostringstream<char> ostringstream ;

  %template()              basic_ios<char>;
  %template(Ostream)       basic_ostream<char>;
  %template(Ostringstream) basic_ostringstream<char>;

  /**
   *  output manipulators
   */
  %template(endl)  endl<char, char_traits<char> >;
  %template(flush) flush<char, char_traits<char> >;

  /**
   *  std::cout, std::cerr, and std::clog.
   */
  %immutable;
  extern std::ostream cout;
  extern std::ostream cerr;
  extern std::ostream clog;
  %mutable;
}



/**
 * Convert an SBase object to a string.
 */

%extend SBase
{
   char* __str__(void){
     return self->toSBML();
   }
}


%extend ListOf
{
  int __len__()
  {
    return self->size();
  }

  SBase* __getitem__(int i)
  {
     return self->get(fixNegativeIndex(i,self));
  }

}

/**
 * Convert SBase, SimpleSpeciesReference, and Rule objects into the most specific type possible.
 */
%typemap(out) SBase*, SimpleSpeciesReference*, Rule*, SBasePlugin*, SBMLExtension*, SBMLNamespaces*, SBMLConverter*
{
  $result = SWIG_NewPointerObj(SWIG_as_voidptr($1), GetDowncastSwigType($1), $owner | %newpointer_flags);
}


/*
 * SWIG-generated wrapper code for Ruby binding wrongly invokes
 * XMLOutputStream::writeAttribute(.., const unsigned int& value) instead of
 * XMLOutputStream::writeAttribute(.., const bool& value) even if the writeAttribute
 * function properly invoked with a bool value (true or false) in Ruby code.
 * It seems that a bool value could be casted to unsigned int, int, or long value
 * in SWIG-generated internal type check code when these types are overloaded in the
 * wrapped function.
 *
 * To avoid this problem, XMLOutputStream::writeAttributeBool(.., const bool&)
 * functions, which internally invoke XMLOutputStream::writeAttribute(.., const bool& value)
 * functions properly, are additionally wrapped as aliases. 
 */
%extend XMLOutputStream
{
  void writeAttributeBool(const std::string& name, const bool& value)
  {
    $self->writeAttribute(name, value);
  }

  void writeAttributeBool(const XMLTriple& name, const bool& value)
  {
    $self->writeAttribute(name, value);
  }
}


// ----------------------------------------------------------------------
// takeover ownership
// ----------------------------------------------------------------------

/**
 * - void ListOf::appendAndOwn(SBase* item)
 */
%apply SWIGTYPE *DISOWN {SBase* item};
%apply SWIGTYPE * {const SBase* item};

/**
 * - void ASTNode::addChild (ASTNode* child)
 * - void ASTNode::prependChild (ASTNode* child)
 */
%apply SWIGTYPE *DISOWN {ASTNode* child};
%apply SWIGTYPE * {const ASTNode* child};

/**
 * - void ASTNode::insertChild  (unsigned int n, ASTNode* newChild)
 * - void ASTNode::replaceChild (unsigned int n, ASTNode* newChild)
 */
%apply SWIGTYPE *DISOWN {ASTNode* newChild};
%apply SWIGTYPE * {const ASTNode* newChild};

/**
 * - void ASTNode::addSemanticsAnnotation (XMLNode* sAnnotation);
 */
%apply SWIGTYPE *DISOWN {XMLNode* sAnnotation};
%apply SWIGTYPE * {const XMLNode* sAnnotation};


/**
 * Wraps the SBMLConstructorException
 *
 * The SBMLConstructorException (C++ class) is wrapped as the 
 * SBMLConsturctorException (Ruby class) which is derived from
 * the built-in ArgumentError class (Ruby class).
 *
 * For example, the exception can be catched in Ruby code as follows:
 *
 * -------------------------------------------------
 *  begin
 *    s = LibSBML::Compartment.new(level,version)
 *  rescue SBMLConstructorException
 *    errmsg = $! 
 *  end
 * -------------------------------------------------
 */

%exceptionclass SBMLConstructorException;

%define SBMLCONSTRUCTOR_EXCEPTION(SBASE_CLASS_NAME)
%exception SBASE_CLASS_NAME{
  //try {
    $action
  //}
  //catch (const SBMLConstructorException &e){
//    static VALUE cpperror = rb_define_class("SBMLConstructorException", rb_eArgError);
//    rb_raise(cpperror, "%s", e.what());
  //}
  //catch (const SBMLExtensionException &e){
//    static VALUE cpperror = rb_define_class("SBMLConstructorException", rb_eArgError);
//    rb_raise(cpperror, "%s", e.what());
  //}
  //catch (...){
  //}
}
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
SBMLCONSTRUCTOR_EXCEPTION(Parameter)
SBMLCONSTRUCTOR_EXCEPTION(Priority)
SBMLCONSTRUCTOR_EXCEPTION(LocalParameter)
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
 * SBMLConsturctorException (Ruby class) which is derived from
 * the built-in ArgumentError class (Ruby class).
 *
 * For example, the exception can be catched in Ruby code as follows:
 *
 * -------------------------------------------------
 *  begin
 *    s = LibSBML::XMLAttributes.new(invalid arguments)
 *  rescue XMLConstructorException
 *    errmsg = $! 
 *  end
 * -------------------------------------------------
 */

%exceptionclass XMLConstructorException;

%define XMLCONSTRUCTOR_EXCEPTION(SBASE_CLASS_NAME)
%exception SBASE_CLASS_NAME{
//  try {
    $action
//  }
//  catch (const XMLConstructorException &e){
//    static VALUE cpperror = rb_define_class("XMLConstructorException", rb_eArgError);
//    rb_raise(cpperror, "%s", e.what());
//  }
}
%enddef


XMLCONSTRUCTOR_EXCEPTION(XMLAttributes)
XMLCONSTRUCTOR_EXCEPTION(XMLError)
XMLCONSTRUCTOR_EXCEPTION(XMLNamespaces)
XMLCONSTRUCTOR_EXCEPTION(XMLNode)
XMLCONSTRUCTOR_EXCEPTION(XMLOutputStream)
XMLCONSTRUCTOR_EXCEPTION(XMLToken)
XMLCONSTRUCTOR_EXCEPTION(XMLTripple)

/**
 *  Wraps the following functions by using the corresponding 
 *  ListWrapper<TYPENAME> class.
 *
 *  - List* ModelHistory::getListCreators()
 *  - List* ModelHistory::getListModifiedDates()
 *  - List* SBase::getCVTerms()
 *  - List* SBMLNamespaces::getSupportedNamespaces()
 *
 *  ListWrapper<TYPENAME> class is wrapped as ListTYPENAMEs class.
 *  So, the above functions are wrapped as follows:
 *
 *  - ModelCreatorList ModelHistory.getListCreators()
 *  - DateList         ModelHistory.getListModifiedDates()
 *  - CVTermList       SBase.getCVTerms()
 *  - SBMLNamespacesList SBMLNamespaces::getSupportedNamespaces()
 *
 */

 %typemap(out) List* SBMLNamespaces::getSupportedNamespaces
{
  ListWrapper<SBMLNamespaces> *listw = ($1 != 0) ? new ListWrapper<SBMLNamespaces>($1) : 0;
  $result = SWIG_NewPointerObj(SWIG_as_voidptr(listw), 
#if SWIG_VERSION > 0x010333
                               SWIGTYPE_p_ListWrapperT_SBMLNamespaces_t,
#else
                               SWIGTYPE_p_ListWrapperTSBMLNamespaces_t,
#endif
                               SWIG_POINTER_OWN |  0 );
}

 
%typemap(out) List* ModelHistory::getListCreators
{
  ListWrapper<ModelCreator> *listw = ($1 != 0) ? new ListWrapper<ModelCreator>($1) : 0;
  $result = SWIG_NewPointerObj(SWIG_as_voidptr(listw), 
#if SWIG_VERSION > 0x010333
                               SWIGTYPE_p_ListWrapperT_ModelCreator_t,
#else
                               SWIGTYPE_p_ListWrapperTModelCreator_t,
#endif
                               SWIG_POINTER_OWN |  0 );
}

%typemap(out) List* ModelHistory::getListModifiedDates
{
  ListWrapper<Date> *listw = ($1 != 0) ? new ListWrapper<Date>($1) : 0;
  $result = SWIG_NewPointerObj(SWIG_as_voidptr(listw), 
#if SWIG_VERSION > 0x010333
                               SWIGTYPE_p_ListWrapperT_Date_t, 
#else
                               SWIGTYPE_p_ListWrapperTDate_t, 
#endif
                               SWIG_POINTER_OWN |  0 );
}

%typemap(out) List* SBase::getCVTerms
{
  ListWrapper<CVTerm> *listw = ($1 != 0)? new ListWrapper<CVTerm>($1) : 0;
  $result = SWIG_NewPointerObj(SWIG_as_voidptr(listw), 
#if SWIG_VERSION > 0x010333
                               SWIGTYPE_p_ListWrapperT_CVTerm_t, 
#else
                               SWIGTYPE_p_ListWrapperTCVTerm_t, 
#endif
                               SWIG_POINTER_OWN |  0 );
}

%include "local-packages.i"

