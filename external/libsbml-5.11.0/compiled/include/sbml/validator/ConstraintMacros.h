/**
 * @file    ConstraintMacros.h
 * @brief   Defines the validator constraint "language"
 * @author  Ben Bornstein
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 *
 * This file provides C/C++ macros that make it possible to easily define
 * validation rules for SBML.  These are called "validation constraints" in
 * SBML (not to be confused with the Constraint object in SBML).  The
 * validator works by applying such constraints to a Model object in
 * memory.  A constraint can have preconditions, invariants, and log
 * failures.  Failures are retrievable as SBMLError objects in the
 * SBMLErrorLog attached to the SBMLDocument containing the model.
 *
 * Users can define their own additional validation constraints using the
 * facilities in this file and the Validator class.  Please consult the
 * code from existing validation constraints for examples about how to use
 * this.
 */

#undef START_CONSTRAINT
#undef END_CONSTRAINT
#undef EXTERN_CONSTRAINT
#undef pre
#undef inv
#undef inv_or
#undef fail
 
#ifdef __BORLANDC__
// borland fails to compile because of too many warnings in the below
// 8008: Condition is always false in function
#pragma option -w-8066 -w-8008
#endif

#ifndef AddingConstraintsToValidator


#define START_CONSTRAINT(Id, Typename, Varname)                   \
LIBSBML_CPP_NAMESPACE_BEGIN \
struct VConstraint ## Typename ## Id: public TConstraint<Typename> \
{                                                                 \
  VConstraint ## Typename ## Id (Validator& V) :                   \
    TConstraint<Typename>(Id, V) { }                              \
protected:                                                        \
  void check_ (const Model& m, const Typename& Varname)

#define END_CONSTRAINT }; \
LIBSBML_CPP_NAMESPACE_END

#define EXTERN_CONSTRAINT(Id, Name)

#define fail()       mLogMsg = true; return;
#define pre(expr)    if (!(expr)) return;
#define inv(expr)    if (!(expr)) { mLogMsg = true; return; }
#define inv_or(expr) if (expr) { mLogMsg = false; return; } else mLogMsg = true;


#else


#define START_CONSTRAINT(Id, Typename, Varname)              \
  addConstraint( new VConstraint ## Typename ## Id (*this) ); \
  if (0) { const Model m(2,4); const Typename Varname(2,4); std::string msg;

#define END_CONSTRAINT }

#define EXTERN_CONSTRAINT(Id, Name) \
  addConstraint( new Name(Id, *this) ); \


#define pre(expr)    { (void)(expr);}
#define inv(expr)    { (void)(expr);}
#define inv_or(expr) { (void)(expr);}
#define fail()


#endif  /* !AddingConstraintsToValidator */

