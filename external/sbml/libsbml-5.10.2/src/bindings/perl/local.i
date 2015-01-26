/**
 * \file    local.i
 * \brief   Perl-specific SWIG directives for wrapping libSBML API
 * \author  TBI {xtof,raim}@tbi.univie.ac.at
 * 
 * Copyright 2004 TBI
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 2.1 of the License, or
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY, WITHOUT EVEN THE IMPLIED WARRANTY OF
 * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  The software and
 * documentation provided hereunder is on an "as is" basis, and the
 * California Institute of Technology and Japan Science and Technology
 * Corporation have no obligations to provide maintenance, support,
 * updates, enhancements or modifications.  In no event shall the
 * California Institute of Technology or the Japan Science and Technology
 * Corporation be liable to any party for direct, indirect, special,
 * incidental or consequential damages, including lost profits, arising
 * out of the use of this software and its documentation, even if the
 * California Institute of Technology and/or Japan Science and Technology
 * Corporation have been advised of the possibility of such damage.  See
 * the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * The original code contained here was initially developed by:
 *
 *     Christoph Flamm and Rainer Machne
 *
 * Contributor(s):
 */

/**
 * Convert SBase, SimpleSpeciesReference and Rule objects into the most specific type possible.
 */
%typemap(out) SBase*, SimpleSpeciesReference*, Rule*, SBasePlugin*, SBMLExtension*, SBMLNamespaces*, SBMLConverter*
{
  ST(argvi) = SWIG_NewPointerObj(SWIG_as_voidptr($1), GetDowncastSwigType($1),
                                 $owner | %newpointer_flags);
  argvi++;
}

/**
 * typemap to handle functions which take a FILE*
 */
%typemap(in) FILE * {
  if (SvOK($input)) /* check for undef */
        $1 = PerlIO_findFILE(IoIFP(sv_2io($input)));
  else  $1 = NULL;
}

/**
 * By default, returned boolean false (C++) is converted to "" (Perl) in 
 * SWIG 1.3.31.
 * The following typemap converts returned boolean value to 0 (false) or 
 * 1 (true) like C/C++ for compatibility.
 */
%typemap(out) bool
{
   ST(argvi) = sv_newmortal();
   sv_setiv(ST(argvi++), (IV) $1);
}

/**
 * The features directives below override the default SWIG generated
 * code for certain methods.  The idea is to tell SWIG to disown the
 * passed-in object.  The containing object will takeover ownership
 * and delete the object as appropriate.  This avoids a deadly
 * double-delete which can result in a segmentation fault.  For
 * example, each SBase that is appended to a ListOf is subsequently
 * owned by that ListOf.
 */

// ----------------------------------------------------------------------
// ListOf
// ----------------------------------------------------------------------

%feature("shadow") ListOf::appendAndOwn(SBase*)
%{
  sub appendAndOwn {
    $_[1]->DISOWN() if defined $_[1];
    return LibSBMLc::ListOf_appendAndOwn(@_);
  }
%}

// ----------------------------------------------------------------------
// ASTNode
// ----------------------------------------------------------------------

%feature("shadow") ASTNode::addChild(ASTNode*)
%{
  sub addChild {
    $_[1]->DISOWN() if defined $_[1];
    return LibSBMLc::ASTNode_addChild(@_);
  }
%}

%feature("shadow") ASTNode::prependChild(ASTNode*)
%{
  sub prependChild {
    $_[1]->DISOWN() if defined $_[1];
    return LibSBMLc::ASTNode_prependChild(@_);
  }
%}

%feature("shadow") ASTNode::insertChild(unsigned int, ASTNode*)
%{
  sub insertChild {
    $_[2]->DISOWN() if defined $_[2];
    return LibSBMLc::ASTNode_insertChild(@_);
  }
%}

%feature("shadow") ASTNode::replaceChild(unsigned int, ASTNode*)
%{
  sub replaceChild {
    $_[2]->DISOWN() if defined $_[2];
    return LibSBMLc::ASTNode_replaceChild(@_);
  }
%}

%feature("shadow") ASTNode::addSemanticsAnnotation(XMLNode*)
%{
  sub addSemanticsAnnotation {
    $_[1]->DISOWN() if defined $_[1];
    return LibSBMLc::ASTNode_addSemanticsAnnotation(@_);
  }
%}

/**
 * Wraps standard output streams
 */

%include "std_string.i"

%{
#include <iostream>
#include <sstream>
%}

%rename(COUT) cout;
%rename(CERR) cerr;
%rename(CLOG) clog;

namespace std
{
%immutable;
extern std::ostream cout;
extern std::ostream cerr;
extern std::ostream clog;
%mutable;
}

/**
 * Wraps std::ostream by implementing two simple wrapper classes.
 *
 * 1) OStream wraps std::cout, std::cerr, and std::clog.
 *    The following public final static variables are provied in
 *    libsbml class like in C++.
 *
 *    1. public final static OStream cout;
 *    2. public final static OStream cerr;
 *    3. public final static OStream clog;
 *
 * 2) OStringStream (derived class of OStream) wraps std::ostringstream.
 *
 * These wrapper classes provide only the minimum functions.
 *
 * (sample code) -----------------------------------------------------
 *
 * 1. wraps std::cout
 *
 *    my $xos = new LibSBML::XMLOutputStream($LibSBML::COUT);
 *
 * 2. wraps std::cerr
 *
 *    my $rd = new LibSBML::SBMLReader
 *    my $d = $rd->readSBML("foo.xml");
 *    if ( $d->getNumErrors() > 0) {
 *       $d->printErrors($LibSBML::CERR);
 *    }
 * 3. wraps std::ostringstream 
 *
 *    my $oss = new LibSBML::OStringStream();
 *    my $xos = new XMLOutputStream($oss->get_ostream());
 *    my $p   = new LibSBML::Parameter("p", 3.31);
 *    $p->write($xos);
 *    $oss->endl();
 *    print $oss->str();
 *
 */

%include "OStream.h"

%{
#include "OStream.cpp"
%}

/**
 * Renames functions whose name is Perl keyword
 *
 */

%include list_of_fix.i
%include list_get_fix.i

/**
 * Wraps the SBMLConstructorException
 *
 * The SBMLConstructorException (C++ class) is converted into
 * Perl exception.
 *
 * For example, the exception can be catched in Perl as follows:
 *
 *  -----------------------------------------------------------------
 *  eval
 *  {
 *    $m = new LibSBML::Model($level,$version);
 *  };
 *  if ($@) 
 *  {
 *    warn $@; # print error message
 *    $m = new LibSBML::Model(2,4);
 *  }
 *  -----------------------------------------------------------------
 */

%define SBMLCONSTRUCTOR_EXCEPTION(SBASE_CLASS_NAME)
%exception SBASE_CLASS_NAME {
  try {
    $action
  }
  catch (SBMLConstructorException &e){
    croak("%s", e.what());
  }
  catch (SBMLExtensionException &e){
    croak("%s", e.what());
  }
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
 * The XMLConstructorException (C++ class) is converted into
 * Perl exception.
 *
 * For example, the exception can be catched in Perl as follows:
 *
 *  -----------------------------------------------------------------
 *  eval
 *  {
 *    $m = new LibSBML::XMLAttributes(invalid arguments);
 *  };
 *  if ($@) 
 *  {
 *    warn $@; # print error message
 *  }
 *  -----------------------------------------------------------------
 */

%define XMLCONSTRUCTOR_EXCEPTION(SBASE_CLASS_NAME)
%exception SBASE_CLASS_NAME {
  try {
    $action
  }
  catch (XMLConstructorException &e){
    croak("%s", e.what());
  }
}
%enddef

XMLCONSTRUCTOR_EXCEPTION(XMLAttributes)
XMLCONSTRUCTOR_EXCEPTION(XMLError)
XMLCONSTRUCTOR_EXCEPTION(XMLNamespaces)
XMLCONSTRUCTOR_EXCEPTION(XMLNode)
XMLCONSTRUCTOR_EXCEPTION(XMLOutputStream)
XMLCONSTRUCTOR_EXCEPTION(XMLToken)
XMLCONSTRUCTOR_EXCEPTION(XMLTripple)

%include "local-packages.i"
