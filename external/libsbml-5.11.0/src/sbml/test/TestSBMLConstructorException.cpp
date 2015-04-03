/**
 * \file    TestSBMLConstructorException.cpp
 * \brief   SBMLConstructorException unit tests
 * \author  Akiya Jouraku
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

#include <sbml/common/common.h>

#include <sbml/SBase.h>
#include <sbml/Compartment.h>
#include <sbml/CompartmentType.h>
#include <sbml/Constraint.h>
#include <sbml/Delay.h>
#include <sbml/Event.h>
#include <sbml/EventAssignment.h>
#include <sbml/FunctionDefinition.h>
#include <sbml/InitialAssignment.h>
#include <sbml/KineticLaw.h>
#include <sbml/ListOf.h>
#include <sbml/Model.h>
#include <sbml/Parameter.h>
#include <sbml/Reaction.h>
#include <sbml/SBMLDocument.h>
#include <sbml/Species.h>
#include <sbml/ModifierSpeciesReference.h>

#include <sbml/AlgebraicRule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>

#include <sbml/SpeciesType.h>
#include <sbml/Unit.h>
#include <sbml/UnitDefinition.h>
#include <sbml/units/FormulaUnitsData.h>
#include <sbml/SBMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <sbml/math/ASTNode.h>

#include <check.h>

/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */
CK_CPPSTART

static const string errMsg = "Level/version/namespaces combination is invalid";
static const string errMsg1 = "Null argument to copy constructor";
static const string errMsg2 = "Null argument to assignment operator";

static SBMLNamespaces SN11(1,1);
static SBMLNamespaces SN12(1,2);
static SBMLNamespaces SN21(2,1);
static SBMLNamespaces SN22(2,2);
static SBMLNamespaces SN23(2,3);
static SBMLNamespaces SN24(2,4);
static SBMLNamespaces SN99(9,9);
static SBMLNamespaces SN31(3,1);



START_TEST ( test_SBMLConstructorException_Compartment )
{
  string msg;
  try
  {
    Compartment s11(1,1);
    Compartment s12(1,2);
    Compartment s21(2,1);
    Compartment s22(2,2);
    Compartment s23(2,3);
    Compartment s24(2,4);
    Compartment s31(3,1);
    Compartment sn11(&SN11);
    Compartment sn12(&SN12);
    Compartment sn21(&SN21);
    Compartment sn22(&SN22);
    Compartment sn23(&SN23);
    Compartment sn24(&SN24);
    Compartment sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    Compartment s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Compartment s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }

  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Compartment s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  Compartment *sn24 = NULL;
  msg = "";
  try
  {
    Compartment s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    Compartment *s = new Compartment(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST

START_TEST ( test_SBMLConstructorException_CompartmentType )
{
  string msg;
  try
  {
    CompartmentType s22(2,2);
    CompartmentType s23(2,3);
    CompartmentType s24(2,4);
    CompartmentType sn22(&SN22);
    CompartmentType sn23(&SN23);
    CompartmentType sn24(&SN24);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    CompartmentType s(1,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    CompartmentType s(1,2);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    CompartmentType s(2,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    CompartmentType s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    CompartmentType s(&SN11);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    CompartmentType s(&SN12);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    CompartmentType s(&SN21);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    CompartmentType s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    CompartmentType s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);
  
  CompartmentType *sn24 = NULL;
  msg = "";
  try
  {
    CompartmentType s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    CompartmentType *s = new CompartmentType(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_Constraint )
{
  string msg;
  try
  {
    Constraint s22(2,2);
    Constraint s23(2,3);
    Constraint s24(2,4);
    Constraint s31(3,1);
    Constraint sn22(&SN22);
    Constraint sn23(&SN23);
    Constraint sn24(&SN24);
    Constraint sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    Constraint s(1,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Constraint s(1,2);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Constraint s(2,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Constraint s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Constraint s(&SN11);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Constraint s(&SN12);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Constraint s(&SN21);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Constraint s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Constraint s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  Constraint *sn24 = NULL;
  msg = "";
  try
  {
    Constraint s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    Constraint *s = new Constraint(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST

START_TEST ( test_SBMLConstructorException_InitialAssignment )
{
  string msg;
  try
  {
    InitialAssignment s22(2,2);
    InitialAssignment s23(2,3);
    InitialAssignment s24(2,4);
    InitialAssignment s31(3,1);
    InitialAssignment sn22(&SN22);
    InitialAssignment sn23(&SN23);
    InitialAssignment sn24(&SN24);
    InitialAssignment sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    InitialAssignment s(1,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    InitialAssignment s(1,2);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    InitialAssignment s(2,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    InitialAssignment s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    InitialAssignment s(&SN11);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    InitialAssignment s(&SN12);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    InitialAssignment s(&SN21);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    InitialAssignment s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    InitialAssignment s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  InitialAssignment *sn24 = NULL;
  msg = "";
  try
  {
    InitialAssignment s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    InitialAssignment *s = new InitialAssignment(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_Species )
{
  string msg;
  try
  {
    Species s11(1,1);
    Species s12(1,2);
    Species s21(2,1);
    Species s22(2,2);
    Species s23(2,3);
    Species s24(2,4);
    Species s31(3,1);
    Species sn11(&SN11);
    Species sn12(&SN12);
    Species sn21(&SN21);
    Species sn22(&SN22);
    Species sn23(&SN23);
    Species sn24(&SN24);
    Species sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    Species s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Species s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Species s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  Species *sn24 = NULL;
  msg = "";
  try
  {
    Species s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    Species *s = new Species(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_SpeciesType )
{
  string msg;
  try
  {
    SpeciesType s22(2,2);
    SpeciesType s23(2,3);
    SpeciesType s24(2,4);
    SpeciesType sn22(&SN22);
    SpeciesType sn23(&SN23);
    SpeciesType sn24(&SN24);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    SpeciesType s(1,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    SpeciesType s(1,2);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    SpeciesType s(2,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    SpeciesType s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    SpeciesType s(&SN11);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    SpeciesType s(&SN12);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    SpeciesType s(&SN21);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    SpeciesType s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    SpeciesType s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  SpeciesType *sn24 = NULL;
  msg = "";
  try
  {
    SpeciesType s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    SpeciesType *s = new SpeciesType(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_Delay )
{
  string msg;
  try
  {
    Delay s21(2,1);
    Delay s22(2,2);
    Delay s23(2,3);
    Delay s24(2,4);
    Delay s31(3,1);
    Delay sn21(&SN21);
    Delay sn22(&SN22);
    Delay sn23(&SN23);
    Delay sn24(&SN24);
    Delay sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    Delay s(1,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Delay s(1,2);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Delay s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Delay s(&SN11);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Delay s(&SN12);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Delay s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Delay s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  Delay *sn24 = NULL;
  msg = "";
  try
  {
    Delay s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    Delay *s = new Delay(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_Trigger )
{
  string msg;
  try
  {
    Trigger s21(2,1);
    Trigger s22(2,2);
    Trigger s23(2,3);
    Trigger s24(2,4);
    Trigger s31(3,1);
    Trigger sn21(&SN21);
    Trigger sn22(&SN22);
    Trigger sn23(&SN23);
    Trigger sn24(&SN24);
    Trigger sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    Trigger s(1,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Trigger s(1,2);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Trigger s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Trigger s(&SN11);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Trigger s(&SN12);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Trigger s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Trigger s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  Trigger *sn24 = NULL;
  msg = "";
  try
  {
    Trigger s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    Trigger *s = new Trigger(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_Event )
{
  string msg;
  try
  {
    Event s21(2,1);
    Event s22(2,2);
    Event s23(2,3);
    Event s24(2,4);
    Event s31(3,1);
    Event sn21(&SN21);
    Event sn22(&SN22);
    Event sn23(&SN23);
    Event sn24(&SN24);
    Event sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    Event s(1,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Event s(1,2);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Event s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Event s(&SN11);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Event s(&SN12);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Event s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Event s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  Event *sn24 = NULL;
  msg = "";
  try
  {
    Event s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    Event *s = new Event(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_EventAssignment )
{
  string msg;
  try
  {
    EventAssignment s21(2,1);
    EventAssignment s22(2,2);
    EventAssignment s23(2,3);
    EventAssignment s24(2,4);
    EventAssignment s31(3,1);
    EventAssignment sn21(&SN21);
    EventAssignment sn22(&SN22);
    EventAssignment sn23(&SN23);
    EventAssignment sn24(&SN24);
    EventAssignment sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    EventAssignment s(1,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    EventAssignment s(1,2);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    EventAssignment s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    EventAssignment s(&SN11);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    EventAssignment s(&SN12);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    EventAssignment s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    EventAssignment s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  EventAssignment *sn24 = NULL;
  msg = "";
  try
  {
    EventAssignment s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    EventAssignment *s = new EventAssignment(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_ModifierSpeciesReference )
{
  string msg;
  try
  {
    ModifierSpeciesReference s21(2,1);
    ModifierSpeciesReference s22(2,2);
    ModifierSpeciesReference s23(2,3);
    ModifierSpeciesReference s24(2,4);
    ModifierSpeciesReference s31(3,1);
    ModifierSpeciesReference sn21(&SN21);
    ModifierSpeciesReference sn22(&SN22);
    ModifierSpeciesReference sn23(&SN23);
    ModifierSpeciesReference sn24(&SN24);
    ModifierSpeciesReference sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    ModifierSpeciesReference s(1,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    ModifierSpeciesReference s(1,2);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    ModifierSpeciesReference s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    ModifierSpeciesReference s(&SN11);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    ModifierSpeciesReference s(&SN12);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    ModifierSpeciesReference s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    ModifierSpeciesReference s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  ModifierSpeciesReference *sn24 = NULL;
  msg = "";
  try
  {
    ModifierSpeciesReference s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    ModifierSpeciesReference *s = new ModifierSpeciesReference(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_StoichiometryMath )
{
  string msg;
  try
  {
    StoichiometryMath s21(2,1);
    StoichiometryMath s22(2,2);
    StoichiometryMath s23(2,3);
    StoichiometryMath s24(2,4);
    StoichiometryMath sn21(&SN21);
    StoichiometryMath sn22(&SN22);
    StoichiometryMath sn23(&SN23);
    StoichiometryMath sn24(&SN24);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    StoichiometryMath s(1,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    StoichiometryMath s(1,2);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    StoichiometryMath s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    StoichiometryMath s(&SN11);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    StoichiometryMath s(&SN12);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    StoichiometryMath s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    StoichiometryMath s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  StoichiometryMath *sn24 = NULL;
  msg = "";
  try
  {
    StoichiometryMath s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    StoichiometryMath *s = new StoichiometryMath(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_SpeciesReference )
{
  string msg;
  try
  {
    SpeciesReference s11(1,1);
    SpeciesReference s12(1,2);
    SpeciesReference s21(2,1);
    SpeciesReference s22(2,2);
    SpeciesReference s23(2,3);
    SpeciesReference s24(2,4);
    SpeciesReference s31(3,1);
    SpeciesReference sn11(&SN11);
    SpeciesReference sn12(&SN12);
    SpeciesReference sn21(&SN21);
    SpeciesReference sn22(&SN22);
    SpeciesReference sn23(&SN23);
    SpeciesReference sn24(&SN24);
    SpeciesReference sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    SpeciesReference s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    SpeciesReference s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    SpeciesReference s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  SpeciesReference *sn24 = NULL;
  msg = "";
  try
  {
    SpeciesReference s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    SpeciesReference *s = new SpeciesReference(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_FunctionDefinition )
{
  string msg;
  try
  {
    FunctionDefinition s21(2,1);
    FunctionDefinition s22(2,2);
    FunctionDefinition s23(2,3);
    FunctionDefinition s24(2,4);
    FunctionDefinition s31(3,1);
    FunctionDefinition sn21(&SN21);
    FunctionDefinition sn22(&SN22);
    FunctionDefinition sn23(&SN23);
    FunctionDefinition sn24(&SN24);
    FunctionDefinition sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    FunctionDefinition s(1,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    FunctionDefinition s(1,2);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    FunctionDefinition s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    FunctionDefinition s(&SN11);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    FunctionDefinition s(&SN12);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    FunctionDefinition s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    FunctionDefinition s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  FunctionDefinition *sn24 = NULL;
  msg = "";
  try
  {
    FunctionDefinition s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    FunctionDefinition *s = new FunctionDefinition(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_KineticLaw )
{
  string msg;
  try
  {
    KineticLaw s11(1,1);
    KineticLaw s12(1,2);
    KineticLaw s21(2,1);
    KineticLaw s22(2,2);
    KineticLaw s23(2,3);
    KineticLaw s24(2,4);
    KineticLaw s31(3,1);
    KineticLaw sn11(&SN11);
    KineticLaw sn12(&SN12);
    KineticLaw sn21(&SN21);
    KineticLaw sn22(&SN22);
    KineticLaw sn23(&SN23);
    KineticLaw sn24(&SN24);
    KineticLaw sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    KineticLaw s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    KineticLaw s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    KineticLaw s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  KineticLaw *sn24 = NULL;
  msg = "";
  try
  {
    KineticLaw s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    KineticLaw *s = new KineticLaw(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_Model )
{
  string msg;
  try
  {
    Model s11(1,1);
    Model s12(1,2);
    Model s21(2,1);
    Model s22(2,2);
    Model s23(2,3);
    Model s24(2,4);
    Model s31(3,1);
    Model sn11(&SN11);
    Model sn12(&SN12);
    Model sn21(&SN21);
    Model sn22(&SN22);
    Model sn23(&SN23);
    Model sn24(&SN24);
    Model sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    Model s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Model s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Model s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  Model *sn24 = NULL;
  msg = "";
  try
  {
    Model s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    Model *s = new Model(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_Parameter )
{
  string msg;
  try
  {
    Parameter s11(1,1);
    Parameter s12(1,2);
    Parameter s21(2,1);
    Parameter s22(2,2);
    Parameter s23(2,3);
    Parameter s24(2,4);
    Parameter s31(3,1);
    Parameter sn11(&SN11);
    Parameter sn12(&SN12);
    Parameter sn21(&SN21);
    Parameter sn22(&SN22);
    Parameter sn23(&SN23);
    Parameter sn24(&SN24);
    Parameter sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    Parameter s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Parameter s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Parameter s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  Parameter *sn24 = NULL;
  msg = "";
  try
  {
    Parameter s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    Parameter *s = new Parameter(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_Reaction )
{
  string msg;
  try
  {
    Reaction s11(1,1);
    Reaction s12(1,2);
    Reaction s21(2,1);
    Reaction s22(2,2);
    Reaction s23(2,3);
    Reaction s24(2,4);
    Reaction s31(3,1);
    Reaction sn11(&SN11);
    Reaction sn12(&SN12);
    Reaction sn21(&SN21);
    Reaction sn22(&SN22);
    Reaction sn23(&SN23);
    Reaction sn24(&SN24);
    Reaction sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    Reaction s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Reaction s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Reaction s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  Reaction *sn24 = NULL;
  msg = "";
  try
  {
    Reaction s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    Reaction *s = new Reaction(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_Unit )
{
  string msg;
  try
  {
    Unit s11(1,1);
    Unit s12(1,2);
    Unit s21(2,1);
    Unit s22(2,2);
    Unit s23(2,3);
    Unit s24(2,4);
    Unit s31(3,1);
    Unit sn11(&SN11);
    Unit sn12(&SN12);
    Unit sn21(&SN21);
    Unit sn22(&SN22);
    Unit sn23(&SN23);
    Unit sn24(&SN24);
    Unit sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    Unit s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Unit s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    Unit s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  Unit *sn24 = NULL;
  msg = "";
  try
  {
    Unit s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    Unit *s = new Unit(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_UnitDefinition )
{
  string msg;
  try
  {
    UnitDefinition s11(1,1);
    UnitDefinition s12(1,2);
    UnitDefinition s21(2,1);
    UnitDefinition s22(2,2);
    UnitDefinition s23(2,3);
    UnitDefinition s24(2,4);
    UnitDefinition s31(3,1);
    UnitDefinition sn11(&SN11);
    UnitDefinition sn12(&SN12);
    UnitDefinition sn21(&SN21);
    UnitDefinition sn22(&SN22);
    UnitDefinition sn23(&SN23);
    UnitDefinition sn24(&SN24);
    UnitDefinition sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    UnitDefinition s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    UnitDefinition s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    UnitDefinition s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  UnitDefinition *sn24 = NULL;
  msg = "";
  try
  {
    UnitDefinition s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    UnitDefinition *s = new UnitDefinition(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_AssignmentRule )
{
  string msg;
  try
  {
    AssignmentRule s11(1,1);
    AssignmentRule s12(1,2);
    AssignmentRule s21(2,1);
    AssignmentRule s22(2,2);
    AssignmentRule s23(2,3);
    AssignmentRule s24(2,4);
    AssignmentRule s31(3,1);
    AssignmentRule sn11(&SN11);
    AssignmentRule sn12(&SN12);
    AssignmentRule sn21(&SN21);
    AssignmentRule sn22(&SN22);
    AssignmentRule sn23(&SN23);
    AssignmentRule sn24(&SN24);
    AssignmentRule sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    AssignmentRule s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    AssignmentRule s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    AssignmentRule s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  AssignmentRule *sn24 = NULL;
  msg = "";
  try
  {
    AssignmentRule s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    AssignmentRule *s = new AssignmentRule(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_AlgebraicRule )
{
  string msg;
  try
  {
    AlgebraicRule s11(1,1);
    AlgebraicRule s12(1,2);
    AlgebraicRule s21(2,1);
    AlgebraicRule s22(2,2);
    AlgebraicRule s23(2,3);
    AlgebraicRule s24(2,4);
    AlgebraicRule s31(3,1);
    AlgebraicRule sn11(&SN11);
    AlgebraicRule sn12(&SN12);
    AlgebraicRule sn21(&SN21);
    AlgebraicRule sn22(&SN22);
    AlgebraicRule sn23(&SN23);
    AlgebraicRule sn24(&SN24);
    AlgebraicRule sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    AlgebraicRule s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    AlgebraicRule s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    AlgebraicRule s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  AlgebraicRule *sn24 = NULL;
  msg = "";
  try
  {
    AlgebraicRule s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    AlgebraicRule *s = new AlgebraicRule(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_RateRule )
{
  string msg;
  try
  {
    RateRule s11(1,1);
    RateRule s12(1,2);
    RateRule s21(2,1);
    RateRule s22(2,2);
    RateRule s23(2,3);
    RateRule s24(2,4);
    RateRule s31(3,1);
    RateRule sn11(&SN11);
    RateRule sn12(&SN12);
    RateRule sn21(&SN21);
    RateRule sn22(&SN22);
    RateRule sn23(&SN23);
    RateRule sn24(&SN24);
    RateRule sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");

  msg = "";
  try
  {
    RateRule s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    RateRule s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  msg = "";
  try
  {
    RateRule s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  RateRule *sn24 = NULL;
  msg = "";
  try
  {
    RateRule s(&SN24);
    s=*sn24;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    RateRule *s = new RateRule(*sn24);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_Priority )
{
  string msg;
  try
  {
    Priority sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");
  
  msg = "";
  try
  {
    Priority s(3,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");
  
  msg = "";
  try
  {
    Priority s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);
  
  msg = "";
  try
  {
    Priority s(&SN21);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);
  
  msg = "";
  try
  {
    Priority s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);
  
  msg = "";
  try
  {
    Priority s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);
  
  Priority *sn31 = NULL;
  msg = "";
  try
  {
    Priority s(&SN31);
    s=*sn31;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
  
  msg = "";
  try
  {
    Priority *s = new Priority(*sn31);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_LocalParameter )
{
  string msg;
  try
  {
    LocalParameter sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");
  
  msg = "";
  try
  {
    LocalParameter s(3,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");
  
  msg = "";
  try
  {
    LocalParameter s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what(); 
  }
  fail_unless(msg == errMsg);
  
  msg = "";
  try
  {
    LocalParameter s(&SN21);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);
  
  msg = "";
  try
  {
    LocalParameter s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);
  
  msg = "";
  try
  {
    LocalParameter s(0);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);

  LocalParameter *sn31 = NULL;
  msg = "";
  try
  {
    LocalParameter s(&SN31);
    s=*sn31;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    LocalParameter *s = new LocalParameter(*sn31);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


START_TEST ( test_SBMLConstructorException_SBMLNamespaces )
{
  string msg;
  try
  {
    SBMLNamespaces sn31(3,1);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");
  
  //msg = "";
  //try
  //{
  //  SBMLNamespaces s(4,2);
  //}
  //catch (SBMLConstructorException &e)
  //{
  //  msg = e.what();
  //}
  //fail_unless(msg == errMsg);

  SBMLNamespaces *sn31 = NULL;
  msg = "";
  try
  {
    SBMLNamespaces s(SN31);
    s=*sn31;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    SBMLNamespaces *s = new SBMLNamespaces(*sn31);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST

START_TEST ( test_SBMLConstructorException_SBMLDocument )
{
  string msg;
  try
  {
    SBMLDocument s11(1,1);
    SBMLDocument s12(1,2);
    SBMLDocument s21(2,1);
    SBMLDocument s22(2,2);
    SBMLDocument s23(2,3);
    SBMLDocument s24(2,4);
    SBMLDocument s31(3,1);
    SBMLDocument sn11(&SN11);
    SBMLDocument sn12(&SN12);
    SBMLDocument sn21(&SN21);
    SBMLDocument sn22(&SN22);
    SBMLDocument sn23(&SN23);
    SBMLDocument sn24(&SN24);
    SBMLDocument sn31(&SN31);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == "");
  
  msg = "";
  try
  {
    SBMLDocument s(9,9);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what(); 
  }
  fail_unless(msg == errMsg);
  
  msg = "";
  try
  {
    SBMLDocument s(&SN99);
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.what();
  }
  fail_unless(msg == errMsg);
  
  SBMLDocument *sn31 = NULL;
  msg = "";
  try
  {
    SBMLDocument s(&SN31);
    s=*sn31;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg2);
 
  msg = "";
  try
  {
    SBMLDocument *s = new SBMLDocument(*sn31);
    (void) s;
  }
  catch (SBMLConstructorException &e)
  {
    msg = e.getSBMLErrMsg();
  }
  fail_unless(msg == errMsg1);
}
END_TEST


Suite *
create_suite_SBMLConstructorException (void)
{
  Suite *suite = suite_create("SBMLConstructorException");
  TCase *tcase = tcase_create("SBMLConstructorException");

  tcase_add_test( tcase, test_SBMLConstructorException_Compartment );
  tcase_add_test( tcase, test_SBMLConstructorException_CompartmentType );
  tcase_add_test( tcase, test_SBMLConstructorException_Constraint );
  tcase_add_test( tcase, test_SBMLConstructorException_InitialAssignment );
  tcase_add_test( tcase, test_SBMLConstructorException_Species );
  tcase_add_test( tcase, test_SBMLConstructorException_SpeciesType );
  tcase_add_test( tcase, test_SBMLConstructorException_Delay );
  tcase_add_test( tcase, test_SBMLConstructorException_Trigger );
  tcase_add_test( tcase, test_SBMLConstructorException_Event );
  tcase_add_test( tcase, test_SBMLConstructorException_EventAssignment );
  tcase_add_test( tcase, 
                  test_SBMLConstructorException_ModifierSpeciesReference );
  tcase_add_test( tcase, test_SBMLConstructorException_StoichiometryMath );
  tcase_add_test( tcase, test_SBMLConstructorException_SpeciesReference );
  tcase_add_test( tcase, test_SBMLConstructorException_FunctionDefinition );
  tcase_add_test( tcase, test_SBMLConstructorException_KineticLaw );
  tcase_add_test( tcase, test_SBMLConstructorException_Model );
  tcase_add_test( tcase, test_SBMLConstructorException_Parameter );
  tcase_add_test( tcase, test_SBMLConstructorException_Reaction );
  tcase_add_test( tcase, test_SBMLConstructorException_Unit );
  tcase_add_test( tcase, test_SBMLConstructorException_UnitDefinition );
  tcase_add_test( tcase, test_SBMLConstructorException_AssignmentRule );
  tcase_add_test( tcase, test_SBMLConstructorException_AlgebraicRule );
  tcase_add_test( tcase, test_SBMLConstructorException_RateRule );
  tcase_add_test( tcase, test_SBMLConstructorException_Priority );
  tcase_add_test( tcase, test_SBMLConstructorException_LocalParameter );
  tcase_add_test( tcase, test_SBMLConstructorException_SBMLNamespaces );
  tcase_add_test( tcase, test_SBMLConstructorException_SBMLDocument );

  suite_add_tcase(suite, tcase);

  return suite;
}
CK_CPPEND
