/**
 * \file    TestReadSBML.cpp
 * \brief   Read SBML unit tests
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
#include <sbml/SpeciesType.h>
#include <sbml/Unit.h>
#include <sbml/UnitDefinition.h>
#include <sbml/units/FormulaUnitsData.h>


#include <sbml/AlgebraicRule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>

#include <sbml/math/ASTNode.h>
#include <sbml/math/FormulaParser.h>

#include <check.h>

/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */


CK_CPPSTART
START_TEST ( test_Compartment_copyConstructor )
{
    Compartment* o1=new Compartment(2, 4);
    o1->setId("c");
    o1->setOutside("c2");
    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getOutside() == "c2");

    Compartment* o2=new Compartment(*o1);

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getOutside() == "c2");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Compartment_copyConstructor_L3 )
{
    Compartment* o1=new Compartment(3, 1);
    o1->setId("c");
    o1->setSpatialDimensions(2.5);
    o1->setSize(2);

    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getSpatialDimensionsAsDouble() == 2.5);
    fail_unless(o1->isSetSpatialDimensions() == true);
    fail_unless(o1->getConstant() == true);
    fail_unless(o1->isSetConstant() == false);

    Compartment* o2=new Compartment(*o1);

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getSpatialDimensionsAsDouble() == 2.5);
    fail_unless(o2->isSetSpatialDimensions() == true);
    fail_unless(o2->getConstant() == true);
    fail_unless(o2->isSetConstant() == false);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Compartment_assignmentOperator )
{
    Compartment* o1=new Compartment(2, 4);
    o1->setId("c");
    o1->setOutside("c2");
    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getOutside() == "c2");
    
    Compartment* o2 = new Compartment(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getOutside() == "c2");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Compartment_assignmentOperator_L3 )
{
    Compartment* o1=new Compartment(3, 1);
    o1->setId("c");
    o1->setSpatialDimensions(2.5);
    o1->setSize(2);

    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getSpatialDimensionsAsDouble() == 2.5);
    fail_unless(o1->isSetSpatialDimensions() == true);
    fail_unless(o1->getConstant() == true);
    fail_unless(o1->isSetConstant() == false);

    Compartment* o2 = new Compartment(3, 1);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getSpatialDimensionsAsDouble() == 2.5);
    fail_unless(o2->isSetSpatialDimensions() == true);
    fail_unless(o2->getConstant() == true);
    fail_unless(o2->isSetConstant() == false);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Compartment_clone )
{
    Compartment* o1=new Compartment(2, 4);
    o1->setId("c");
    o1->setOutside("c2");
    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getOutside() == "c2");

    Compartment* o2=o1->clone();
   
    fail_unless(o2->getId() == "c");
    fail_unless(o2->getOutside() == "c2");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_CompartmentType_copyConstructor )
{
    CompartmentType* o1=new CompartmentType(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    CompartmentType* o2=new CompartmentType(*o1);

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_CompartmentType_assignmentOperator )
{
    CompartmentType* o1=new CompartmentType(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");
    
    CompartmentType* o2 = new CompartmentType(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_CompartmentType_clone )
{
    CompartmentType* o1=new CompartmentType(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    CompartmentType* o2=o1->clone();
   
    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Constraint_copyConstructor )
{
    Constraint* o1=new Constraint(2, 4);
    o1->setMetaId("c");
    
    fail_unless(o1->getMetaId() == "c");

    XMLNode *text = XMLNode::convertStringToXMLNode(" Some text ");
    XMLTriple triple = XMLTriple("p", "http://www.w3.org/1999/xhtml", "");
    XMLAttributes att = XMLAttributes();
    XMLNamespaces xmlns = XMLNamespaces();
    xmlns.add("http://www.w3.org/1999/xhtml");
    
    XMLNode *p = new XMLNode(triple, att, xmlns);
    p->addChild(*(text));
    
    XMLTriple triple1 = XMLTriple("message", "", "");
    XMLAttributes att1 = XMLAttributes();
    XMLNode *message = new XMLNode(triple1, att1);

    message->addChild(*(p));

    ASTNode * math = new ASTNode (AST_CONSTANT_PI);

    o1->setMath(math);
    o1->setMessage(message);

    delete math;
    delete message;

    const XMLNode *msg;

    fail_unless(o1->getMath() != NULL);
    msg = o1->getMessage();
    fail_unless( msg != NULL);

    Constraint* o2 = new Constraint(*o1);

    fail_unless(o2->getMetaId() == "c");
    fail_unless(o2->getMath() != NULL);
    msg = o2->getMessage();
    fail_unless(msg != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
    delete text;
    delete p;
}
END_TEST

START_TEST ( test_Constraint_assignmentOperator )
{
    Constraint* o1=new Constraint(2, 4);
    o1->setMetaId("c");
    
    fail_unless(o1->getMetaId() == "c");
    
    XMLNode *text = XMLNode::convertStringToXMLNode(" Some text ");
    XMLTriple triple = XMLTriple("p", "http://www.w3.org/1999/xhtml", "");
    XMLAttributes att = XMLAttributes();
    XMLNamespaces xmlns = XMLNamespaces();
    xmlns.add("http://www.w3.org/1999/xhtml");
    
    XMLNode *p = new XMLNode(triple, att, xmlns);
    p->addChild(*(text));
    
    XMLTriple triple1 = XMLTriple("message", "", "");
    XMLAttributes att1 = XMLAttributes();
    XMLNode *message = new XMLNode(triple1, att1);

    message->addChild(*(p));

    ASTNode * math = new ASTNode (AST_CONSTANT_PI);

    o1->setMath(math);
    o1->setMessage(message);

    delete math;
    delete message;

    const XMLNode *msg;

    fail_unless(o1->getMath() != NULL);
    msg = o1->getMessage();
    fail_unless(msg != NULL);

    Constraint* o2 = new Constraint(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getMetaId() == "c");
    fail_unless(o2->getMath() != NULL);
    msg = o2->getMessage();
    fail_unless(msg != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
    delete text;
    delete p;
}
END_TEST


START_TEST ( test_Constraint_clone )
{
    Constraint* o1=new Constraint(2, 4);
    o1->setMetaId("c");
    
    fail_unless(o1->getMetaId() == "c");

    XMLNode *text = XMLNode::convertStringToXMLNode(" Some text ");
    XMLTriple triple = XMLTriple("p", "http://www.w3.org/1999/xhtml", "");
    XMLAttributes att = XMLAttributes();
    XMLNamespaces xmlns = XMLNamespaces();
    xmlns.add("http://www.w3.org/1999/xhtml");
    
    XMLNode *p = new XMLNode(triple, att, xmlns);
    p->addChild(*(text));
    
    XMLTriple triple1 = XMLTriple("message", "", "");
    XMLAttributes att1 = XMLAttributes();
    XMLNode *message = new XMLNode(triple1, att1);

    message->addChild(*(p));

    ASTNode * math = new ASTNode (AST_CONSTANT_PI);

    o1->setMath(math);
    o1->setMessage(message);

    delete math;
    delete message;

    const XMLNode *msg;

    fail_unless(o1->getMath() != NULL);
    msg = o1->getMessage();
    fail_unless(msg != NULL);

    Constraint* o2=o1->clone();
   
    fail_unless(o2->getMetaId() == "c");
    fail_unless(o2->getMath() != NULL);
    msg = o2->getMessage();
    fail_unless(msg != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
    delete text;
    delete p;
}
END_TEST


START_TEST ( test_Delay_copyConstructor )
{
    Delay* o1=new Delay(2, 4);
    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->getMath() != NULL);

    Delay* o2=new Delay(*o1);

    fail_unless(o2->getMath() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_Delay_assignmentOperator )
{
    Delay* o1=new Delay(2, 4);
    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->getMath() != NULL);

    Delay* o2 = new Delay(2, 4);
    (*o2)=*o1;

    fail_unless(o1->getMath() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Delay_clone )
{
    Delay* o1=new Delay(2, 4);
    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->getMath() != NULL);

    Delay* o2 = o1->clone();

    fail_unless(o1->getMath() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Event_copyConstructor )
{
    Event* o1=new Event(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    Event* o2=new Event(*o1);

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_Event_copyConstructor_L3 )
{
    Event* o1=new Event(3, 1);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getUseValuesFromTriggerTime() == true);
    fail_unless(o1->isSetUseValuesFromTriggerTime() == false);


    Event* o2=new Event(*o1);

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getUseValuesFromTriggerTime() == true);
    fail_unless(o2->isSetUseValuesFromTriggerTime() == false);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_Event_assignmentOperator )
{
    Event* o1=new Event(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");
    
    Event* o2 = new Event(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Event_assignmentOperator_L3 )
{
    Event* o1=new Event(3, 1);
    o1->setId("c");
    o1->setUseValuesFromTriggerTime(false);
    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getUseValuesFromTriggerTime() == false);
    fail_unless(o1->isSetUseValuesFromTriggerTime() == true);
    
    Event* o2 = new Event(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getUseValuesFromTriggerTime() == false);
    fail_unless(o2->isSetUseValuesFromTriggerTime() == true);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Event_clone )
{
    Event* o1=new Event(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    Event* o2=o1->clone();
   
    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_EventAssignment_copyConstructor )
{
    EventAssignment* o1=new EventAssignment(2, 4);
    o1->setVariable("c2");
    
    fail_unless(o1->getVariable() == "c2");

    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->getMath() != NULL);

    EventAssignment* o2=new EventAssignment(*o1);

    fail_unless(o2->getVariable() == "c2");
    fail_unless(o2->getMath() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_EventAssignment_assignmentOperator )
{
    EventAssignment* o1=new EventAssignment(2, 4);
    o1->setVariable("c2");
    
    fail_unless(o1->getVariable() == "c2");

    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->getMath() != NULL);

    EventAssignment* o2 = new EventAssignment(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getVariable() == "c2");
    fail_unless(o2->getMath() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_EventAssignment_clone )
{
    EventAssignment* o1=new EventAssignment(2, 4);
    o1->setVariable("c2");
    
    fail_unless(o1->getVariable() == "c2");

    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->getMath() != NULL);

    EventAssignment* o2=o1->clone();

    fail_unless(o2->getVariable() == "c2");
    fail_unless(o2->getMath() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_FunctionDefinition_copyConstructor )
{
    FunctionDefinition* o1=new FunctionDefinition(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->getMath() != NULL);

    FunctionDefinition* o2=new FunctionDefinition(*o1);

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getMath() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_FunctionDefinition_assignmentOperator )
{
    FunctionDefinition* o1=new FunctionDefinition(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");
    
    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->getMath() != NULL);

    FunctionDefinition* o2 = new FunctionDefinition(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getMath() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_FunctionDefinition_clone )
{
    FunctionDefinition* o1=new FunctionDefinition(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->getMath() != NULL);

    FunctionDefinition* o2=o1->clone();
   
    fail_unless(o2->getId() == "c");
    fail_unless(o2->getMath() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_InitialAssignment_copyConstructor )
{
    InitialAssignment* o1=new InitialAssignment(2, 4);
    o1->setSymbol("c");
    
    fail_unless(o1->getId() == "c");

    InitialAssignment* o2=new InitialAssignment(*o1);

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_InitialAssignment_assignmentOperator )
{
    InitialAssignment* o1=new InitialAssignment(2, 4);
    o1->setSymbol("c");
    
    fail_unless(o1->getId() == "c");
    
    InitialAssignment* o2 = new InitialAssignment(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_InitialAssignment_clone )
{
    InitialAssignment* o1=new InitialAssignment(2, 4);
    o1->setSymbol("c");
    
    fail_unless(o1->getId() == "c");

    InitialAssignment* o2=o1->clone();
   
    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_KineticLaw_copyConstructor )
{
    KineticLaw* o1=new KineticLaw(2, 4);
    o1->setInternalId("c");
    
    Parameter * p = new Parameter(2, 4);
    p->setId("jake");
    o1->addParameter(p);
    delete p;

    fail_unless(o1->getNumParameters() == 1);
    fail_unless(o1->getParameter(0)->getId() == "jake");
    fail_unless(o1->getInternalId() == "c");

    KineticLaw* o2=new KineticLaw(*o1);

    fail_unless(o2->getNumParameters() == 1);
    fail_unless(o2->getParameter(0)->getId() == "jake");
    fail_unless(o2->getInternalId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_KineticLaw_assignmentOperator )
{
    KineticLaw* o1=new KineticLaw(2, 4);
    o1->setInternalId("c");
    
    Parameter * p = new Parameter(2, 4);
    p->setId("jake");
    o1->addParameter(p);
    delete p;

    fail_unless(o1->getNumParameters() == 1);
    fail_unless(o1->getParameter(0)->getId() == "jake");
    fail_unless(o1->getInternalId() == "c");

    KineticLaw* o2 = new KineticLaw(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getNumParameters() == 1);
    fail_unless(o2->getParameter(0)->getId() == "jake");
    fail_unless(o2->getInternalId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_KineticLaw_clone )
{
    KineticLaw* o1=new KineticLaw(2, 4);
    o1->setInternalId("c");
    
    Parameter * p = new Parameter(2, 4);
    p->setId("jake");
    o1->addParameter(p);
    delete p;

    fail_unless(o1->getNumParameters() == 1);
    fail_unless(o1->getParameter(0)->getId() == "jake");
    fail_unless(o1->getInternalId() == "c");

    KineticLaw* o2=o1->clone();

    fail_unless(o2->getNumParameters() == 1);
    fail_unless(o2->getParameter(0)->getId() == "jake");
    fail_unless(o2->getInternalId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_ListOf_copyConstructor )
{
    ListOf* o1=new ListOf(2,1);
    
    Species * s = new Species(2, 1);
    s->setId("species_1");
    o1->append(s);

    delete s;
    
    ListOf* o2=new ListOf(*o1);
    fail_unless(o2->size() == 1);
    fail_unless(static_cast <Species *> (o2->get(0))->getId()
      == "species_1");
    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_ListOf_assignmentOperator )
{
    ListOf* o1=new ListOf(2,1);
    
    Species * s = new Species(2, 1);
    s->setId("species_1");
    o1->append(s);

    delete s;

    ListOf* o2 = new ListOf(2,1);
    (*o2)=*o1;

    fail_unless(o2->size() == 1);
    fail_unless(static_cast <Species *> (o2->get(0))->getId()
      == "species_1");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_ListOf_clone )
{
    ListOf* o1=new ListOf(2,1);

    Species * s = new Species(2, 1);
    s->setId("species_1");
    o1->append(s);

    delete s;


    ListOf* o2=static_cast<ListOf*>(o1->clone());
   
    fail_unless(o2->size() == 1);
    fail_unless(static_cast <Species *> (o2->get(0))->getId()
      == "species_1");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Model_copyConstructor )
{
    Model* o1=new Model(2, 4);
    o1->setId("c");

    Parameter *p = new Parameter(2, 4);
    p->setId("alex");
    o1->addParameter(p);
    delete p;
    FormulaUnitsData *fud = new FormulaUnitsData();
    o1->addFormulaUnitsData(fud);
    delete fud;
    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getNumParameters() == 1);
    fail_unless(o1->getNumFormulaUnitsData() == 1);
    fail_unless(o1->getParameter(0)->getId() == "alex");

    Model* o2=new Model(*o1);

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getNumParameters() == 1);
    fail_unless(o2->getNumFormulaUnitsData() == 1);
    fail_unless(o2->getParameter(0)->getId() == "alex");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_Model_assignmentOperator )
{
    Model* o1=new Model(2, 4);
    o1->setId("c");

    Parameter *p = new Parameter(2, 4);
    p->setId("alex");
    o1->addParameter(p);
    delete p;

    FormulaUnitsData *fud = new FormulaUnitsData();
    o1->addFormulaUnitsData(fud);
    delete fud;
    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getNumParameters() == 1);
    fail_unless(o1->getNumFormulaUnitsData() == 1);
    fail_unless(o1->getParameter(0)->getId() == "alex");

    Model* o2=new Model(2, 4);
    (*o2) = *o1;

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getNumParameters() == 1);
    fail_unless(o2->getNumFormulaUnitsData() == 1);
    fail_unless(o2->getParameter(0)->getId() == "alex");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Model_clone )
{
    Model* o1=new Model(2, 4);
    o1->setId("c");

    Parameter *p = new Parameter(2, 4);
    p->setId("alex");
    o1->addParameter(p);
    delete p;

    FormulaUnitsData *fud = new FormulaUnitsData();
    o1->addFormulaUnitsData(fud);
    delete fud;
    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getNumParameters() == 1);
    fail_unless(o1->getNumFormulaUnitsData() == 1);
    fail_unless(o1->getParameter(0)->getId() == "alex");

    Model* o2=o1->clone();

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getNumParameters() == 1);
    fail_unless(o2->getNumFormulaUnitsData() == 1);
    fail_unless(o2->getParameter(0)->getId() == "alex");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Parameter_copyConstructor )
{
    Parameter* o1=new Parameter(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    Parameter* o2=new Parameter(*o1);

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_Parameter_assignmentOperator )
{
    Parameter* o1=new Parameter(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");
    
    Parameter* o2 = new Parameter(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Parameter_clone )
{
    Parameter* o1=new Parameter(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    Parameter* o2=o1->clone();
   
    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Reaction_copyConstructor )
{
    Reaction* o1=new Reaction(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    KineticLaw *kl = new KineticLaw(2, 4);
    ASTNode* math = SBML_parseFormula("1");
    kl->setMath(math);
    delete math;
    o1->setKineticLaw(kl);
    delete kl;

    fail_unless(o1->isSetKineticLaw() == 1);
    fail_unless (o1->getKineticLaw() != NULL);

    Reaction* o2=new Reaction(*o1);

    fail_unless(o2->getId() == "c");
    fail_unless(o2->isSetKineticLaw() == 1);
    fail_unless(o2->getKineticLaw() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_Reaction_assignmentOperator )
{
    Reaction* o1=new Reaction(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");
    
    KineticLaw *kl = new KineticLaw(2, 4);
    ASTNode* math = SBML_parseFormula("1");
    kl->setMath(math);
    delete math;
    o1->setKineticLaw(kl);
    delete kl;

    fail_unless(o1->isSetKineticLaw() == 1);
    fail_unless (o1->getKineticLaw() != NULL);

    Reaction* o2 = new Reaction(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");
    fail_unless(o2->isSetKineticLaw() == 1);
    fail_unless(o2->getKineticLaw() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Reaction_clone )
{
    Reaction* o1=new Reaction(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    KineticLaw *kl = new KineticLaw(2, 4);
    ASTNode* math = SBML_parseFormula("1");
    kl->setMath(math);
    delete math;

    o1->setKineticLaw(kl);
    delete kl;

    fail_unless(o1->isSetKineticLaw() == 1);
    fail_unless (o1->getKineticLaw() != NULL);
   
    Reaction* o2=o1->clone();
   
    fail_unless(o2->getId() == "c");
    fail_unless(o2->isSetKineticLaw() == 1);
    fail_unless(o2->getKineticLaw() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Rule_copyConstructor )
{
    Rule* o1=new RateRule(2, 1);
    o1->setVariable("a");
    
    fail_unless(o1->getVariable() == "a");
    
    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->isSetMath() == 1);
    
    Rule* o2=new Rule(*o1);
    
    fail_unless(o2->getVariable() == "a");
    fail_unless(o2->isSetMath() == 1);
    
    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_Rule_assignmentOperator )
{
    Rule* o1=new RateRule(2, 4);
    o1->setVariable("a");
    
    fail_unless(o1->getVariable() == "a");
    
    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->isSetMath() == 1);
    
    Rule* o2 = new RateRule(2, 4);
    (*o2)=*o1;
    
    fail_unless(o2->getVariable() == "a");
    fail_unless(o2->isSetMath() == 1);
    
    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Rule_clone )
{
    Rule* o1=new RateRule(2, 1);
    o1->setVariable("a");
    
    fail_unless(o1->getVariable() == "a");
    
    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->isSetMath() == 1);
    
    Rule* o2= o1->clone();
    
    fail_unless(o2->getVariable() == "a");
    fail_unless(o2->isSetMath() == 1);
    
    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Species_copyConstructor )
{
    Species* o1=new Species(2, 4);
    o1->setId("c");
    o1->setSpeciesType("c1");
    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getSpeciesType() == "c1");

    Species* o2=new Species(*o1);

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getSpeciesType() == "c1");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_Species_assignmentOperator )
{
    Species* o1=new Species(2, 4);
    o1->setId("c");
    o1->setSpeciesType("c1");
    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getSpeciesType() == "c1");
    
    Species* o2 = new Species(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");
    fail_unless(o2->getSpeciesType() == "c1");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Species_clone )
{
    Species* o1=new Species(2, 4);
    o1->setId("c");
    o1->setSpeciesType("c1");
    
    fail_unless(o1->getId() == "c");
    fail_unless(o1->getSpeciesType() == "c1");

    Species* o2=o1->clone();
   
    fail_unless(o2->getId() == "c");
    fail_unless(o2->getSpeciesType() == "c1");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_SpeciesReference_copyConstructor )
{
    SpeciesReference* o1=new SpeciesReference(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    SpeciesReference* o2=new SpeciesReference(*o1);

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_SpeciesReference_assignmentOperator )
{
    SpeciesReference* o1=new SpeciesReference(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");
    
    SpeciesReference* o2 = new SpeciesReference(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_SpeciesReference_clone )
{
    SpeciesReference* o1=new SpeciesReference(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    SpeciesReference* o2=o1->clone();
   
    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_SpeciesType_copyConstructor )
{
    SpeciesType* o1=new SpeciesType(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    SpeciesType* o2=new SpeciesType(*o1);

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_SpeciesType_assignmentOperator )
{
    SpeciesType* o1=new SpeciesType(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");
    
    SpeciesType* o2 = new SpeciesType(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_SpeciesType_clone )
{
    SpeciesType* o1=new SpeciesType(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    SpeciesType* o2=o1->clone();
   
    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Trigger_copyConstructor )
{
    Trigger* o1=new Trigger(2, 4);
    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->getMath() != NULL);

    Trigger* o2=new Trigger(*o1);

    fail_unless(o2->getMath() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_Trigger_assignmentOperator )
{
    Trigger* o1=new Trigger(2, 4);
    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->getMath() != NULL);

    Trigger* o2 = new Trigger(2, 4);
    (*o2)=*o1;

    fail_unless(o1->getMath() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Trigger_clone )
{
    Trigger* o1=new Trigger(2, 4);
    ASTNode* node=new ASTNode(AST_CONSTANT_PI);
    o1->setMath(node);
    delete node;

    fail_unless(o1->getMath() != NULL);

    Trigger* o2 = o1->clone();

    fail_unless(o1->getMath() != NULL);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Unit_copyConstructor )
{
    Unit* o1=new Unit(2, 4);
    o1->setKind(UNIT_KIND_MOLE);
    
    fail_unless(o1->getKind() == UNIT_KIND_MOLE);

    Unit* o2=new Unit(*o1);

    fail_unless(o2->getKind() == UNIT_KIND_MOLE);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_Unit_assignmentOperator )
{
    Unit* o1=new Unit(2, 4);
    o1->setKind(UNIT_KIND_MOLE);
    
    fail_unless(o1->getKind() == UNIT_KIND_MOLE);
    
    Unit* o2 = new Unit(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getKind() == UNIT_KIND_MOLE);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_Unit_clone )
{
    Unit* o1=new Unit(2, 4);
    o1->setKind(UNIT_KIND_MOLE);
    
    fail_unless(o1->getKind() == UNIT_KIND_MOLE);

    Unit* o2=o1->clone();
   
    fail_unless(o2->getKind() == UNIT_KIND_MOLE);

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_UnitDefinition_copyConstructor )
{
    UnitDefinition* o1=new UnitDefinition(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    UnitDefinition* o2=new UnitDefinition(*o1);

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_UnitDefinition_assignmentOperator )
{
    UnitDefinition* o1=new UnitDefinition(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");
    
    UnitDefinition* o2 = new UnitDefinition(2, 4);;
    (*o2)=*o1;

    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_UnitDefinition_clone )
{
    UnitDefinition* o1=new UnitDefinition(2, 4);
    o1->setId("c");
    
    fail_unless(o1->getId() == "c");

    UnitDefinition* o2=o1->clone();
   
    fail_unless(o2->getId() == "c");

    fail_unless(o2->getParentSBMLObject() == o1->getParentSBMLObject());

    delete o2;
    delete o1;
}
END_TEST


START_TEST ( test_SBMLDocument_copyConstructor )
{
    SBMLDocument* o1=new SBMLDocument();
    o1->setLevelAndVersion(2, 1, false);
    
    fail_unless(o1->getLevel() == 2);
    fail_unless(o1->getVersion() == 1);

    SBMLDocument* o2=new SBMLDocument(*o1);

    fail_unless(o2->getLevel() == 2);
    fail_unless(o2->getVersion() == 1);

    delete o2;
    delete o1;
}
END_TEST

START_TEST ( test_SBMLDocument_assignmentOperator )
{
    SBMLDocument* o1=new SBMLDocument();
    o1->setLevelAndVersion(2, 1, false);
    
    fail_unless(o1->getLevel() == 2);
    fail_unless(o1->getVersion() == 1);
    
    SBMLDocument o2 = *o1;

    fail_unless(o2.getLevel() == 2);
    fail_unless(o2.getVersion() == 1);

    delete o1;
}
END_TEST


START_TEST ( test_SBMLDocument_clone )
{
    SBMLDocument* o1=new SBMLDocument();
    o1->setLevelAndVersion(1, 1, false);
    Model *m = new Model(1, 1);
    m->setId("foo");
    m->createCompartment();
    m->createSpecies();
    m->createReaction();
    o1->setModel(m);

    
    fail_unless(o1->getLevel() == 1);
    fail_unless(o1->getVersion() == 1);
    fail_unless(o1->getModel()->getId() == "foo");
    fail_unless(o1->getModel()->getLevel() == 1);
    fail_unless(o1->getModel()->getVersion() == 1);
    fail_unless(o1->getModel()->getSBMLDocument() == o1);

    SBMLDocument* o2=o1->clone();
   
    fail_unless(o2->getLevel() == 1);
    fail_unless(o2->getVersion() == 1);
    fail_unless(o2->getModel()->getId() == "foo");
    fail_unless(o2->getModel()->getLevel() == 1);
    fail_unless(o2->getModel()->getVersion() == 1);
    fail_unless(o2->getModel()->getSBMLDocument() == o2);

    delete o2;
    delete o1;
    delete m;
}
END_TEST


Suite *
create_suite_CopyAndClone (void)
{
  Suite *suite = suite_create("CopyAndClone");
  TCase *tcase = tcase_create("CopyAndClone");

  tcase_add_test( tcase, test_Compartment_copyConstructor );
  tcase_add_test( tcase, test_Compartment_copyConstructor_L3 );
  tcase_add_test( tcase, test_Compartment_assignmentOperator );
  tcase_add_test( tcase, test_Compartment_assignmentOperator_L3 );
  tcase_add_test( tcase, test_Compartment_clone );
  tcase_add_test( tcase, test_CompartmentType_copyConstructor );
  tcase_add_test( tcase, test_CompartmentType_assignmentOperator );
  tcase_add_test( tcase, test_CompartmentType_clone );
  tcase_add_test( tcase, test_Constraint_copyConstructor );
  tcase_add_test( tcase, test_Constraint_assignmentOperator );
  tcase_add_test( tcase, test_Constraint_clone );
  tcase_add_test( tcase, test_Delay_copyConstructor );
  tcase_add_test( tcase, test_Delay_assignmentOperator );
  tcase_add_test( tcase, test_Delay_clone );
  tcase_add_test( tcase, test_Event_copyConstructor );
  tcase_add_test( tcase, test_Event_copyConstructor_L3 );
  tcase_add_test( tcase, test_Event_assignmentOperator );
  tcase_add_test( tcase, test_Event_assignmentOperator_L3 );
  tcase_add_test( tcase, test_Event_clone );
  tcase_add_test( tcase, test_EventAssignment_copyConstructor );
  tcase_add_test( tcase, test_EventAssignment_assignmentOperator );
  tcase_add_test( tcase, test_EventAssignment_clone );
  tcase_add_test( tcase, test_FunctionDefinition_copyConstructor );
  tcase_add_test( tcase, test_FunctionDefinition_assignmentOperator );
  tcase_add_test( tcase, test_FunctionDefinition_clone );
  tcase_add_test( tcase, test_InitialAssignment_copyConstructor );
  tcase_add_test( tcase, test_InitialAssignment_assignmentOperator );
  tcase_add_test( tcase, test_InitialAssignment_clone );
  tcase_add_test( tcase, test_KineticLaw_copyConstructor );
  tcase_add_test( tcase, test_KineticLaw_assignmentOperator );
  tcase_add_test( tcase, test_KineticLaw_clone );
  tcase_add_test( tcase, test_ListOf_copyConstructor );
  tcase_add_test( tcase, test_ListOf_assignmentOperator );
  tcase_add_test( tcase, test_ListOf_clone );
  tcase_add_test( tcase, test_Model_copyConstructor );
  tcase_add_test( tcase, test_Model_assignmentOperator );
  tcase_add_test( tcase, test_Model_clone );
  tcase_add_test( tcase, test_Parameter_copyConstructor );
  tcase_add_test( tcase, test_Parameter_assignmentOperator );
  tcase_add_test( tcase, test_Parameter_clone );
  tcase_add_test( tcase, test_Reaction_copyConstructor );
  tcase_add_test( tcase, test_Reaction_assignmentOperator );
  tcase_add_test( tcase, test_Reaction_clone );
  tcase_add_test( tcase, test_Rule_copyConstructor );
  tcase_add_test( tcase, test_Rule_assignmentOperator );
  tcase_add_test( tcase, test_Rule_clone );
  tcase_add_test( tcase, test_Species_copyConstructor );
  tcase_add_test( tcase, test_Species_assignmentOperator );
  tcase_add_test( tcase, test_Species_clone );
  tcase_add_test( tcase, test_SpeciesReference_copyConstructor );
  tcase_add_test( tcase, test_SpeciesReference_assignmentOperator );
  tcase_add_test( tcase, test_SpeciesReference_clone );
  tcase_add_test( tcase, test_SpeciesType_copyConstructor );
  tcase_add_test( tcase, test_SpeciesType_assignmentOperator );
  tcase_add_test( tcase, test_SpeciesType_clone );
  tcase_add_test( tcase, test_Trigger_copyConstructor );
  tcase_add_test( tcase, test_Trigger_assignmentOperator );
  tcase_add_test( tcase, test_Trigger_clone );
  tcase_add_test( tcase, test_Unit_copyConstructor );
  tcase_add_test( tcase, test_Unit_assignmentOperator );
  tcase_add_test( tcase, test_Unit_clone );
  tcase_add_test( tcase, test_UnitDefinition_copyConstructor );
  tcase_add_test( tcase, test_UnitDefinition_assignmentOperator );
  tcase_add_test( tcase, test_UnitDefinition_clone );

  tcase_add_test( tcase, test_SBMLDocument_copyConstructor );
  tcase_add_test( tcase, test_SBMLDocument_assignmentOperator );
  tcase_add_test( tcase, test_SBMLDocument_clone );

  suite_add_tcase(suite, tcase);

  return suite;
}
CK_CPPEND

