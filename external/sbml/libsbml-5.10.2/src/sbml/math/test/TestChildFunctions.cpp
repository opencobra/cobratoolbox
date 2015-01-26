/**
 * \file    TestChildFunctions.cpp
 * \brief   MathML unit tests for child manipulation functions
 * \author  Sarah Keating
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
 * Copyright (C) 2009-2012 jointly by the following organizations: 
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

#include <limits>
#include <iostream>
#include <cstring>
#include <cstdio>

#include <check.h>

#include <sbml/math/FormulaParser.h>
#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/ASTNode.h>
#include <sbml/math/MathML.h>

#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLNode.h>

/** @cond doxygenLibsbmlInternal */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */


/**
 * Wraps the string s in the appropriate XML boilerplate.
 */
#define XML_HEADER    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
#define MATHML_HEADER "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">\n"
#define MATHML_HEADER_UNITS  "<math xmlns=\"http://www.w3.org/1998/Math/MathML\""
#define MATHML_HEADER_UNITS2  " xmlns:sbml=\"http://www.sbml.org/sbml/level3/version1/core\">\n"
#define MATHML_FOOTER "</math>"

#define wrapMathML(s)   XML_HEADER MATHML_HEADER s MATHML_FOOTER
#define wrapMathMLUnits(s)  XML_HEADER MATHML_HEADER_UNITS MATHML_HEADER_UNITS2 s MATHML_FOOTER


static ASTNode* N;
static char*    S;


void
TestChildFunctions_setup ()
{
  N = NULL;
  S = NULL;
}


void
TestChildFunctions_teardown ()
{
  delete N;
  free(S);
}


static bool
equals (const char* expected, const char* actual)
{
  if ( !strcmp(expected, actual) ) return true;

  printf( "\nStrings are not equal:\n"  );
  printf( "Expected:\n[%s]\n", expected );
  printf( "Actual:\n[%s]\n"  , actual   );

  return false;
}


CK_CPPSTART


START_TEST (test_ChildFunctions_addToPiecewise_1)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <cn> 0 </cn>\n"
    "      <apply>\n"
    "        <eq/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "    <otherwise>\n"
    "      <ci> newChild </ci>\n"
    "    </otherwise>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <cn>0</cn>"
    "    <apply> <eq/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  ASTNode * newChild1 = new ASTNode(AST_NAME);
  newChild1->setName("newChild1");

  int i = N->addChild(newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_addToPiecewise_2)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <cn> 0 </cn>\n"
    "      <apply>\n"
    "        <eq/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "    <piece>\n"
    "      <ci> newChild </ci>\n"
    "      <ci> newChild1 </ci>\n"
    "    </piece>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <cn>0</cn>"
    "    <apply> <eq/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  ASTNode * newChild1 = new ASTNode(AST_NAME);
  newChild1->setName("newChild1");

  int i = N->addChild(newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  i = N->addChild(newChild1);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 4);  
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_addToPiecewise_3)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <cn> 0 </cn>\n"
    "      <true/>\n"
    "    </piece>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <cn>0</cn>"
    "  </piece>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 1);

  ASTNode * newChild = new ASTNode(AST_CONSTANT_TRUE);

  int i = N->addChild(newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 2);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_addToLambda_1)
{
  const char* expected = wrapMathML
  (
    "  <lambda>\n"
    "    <bvar>\n"
    "      <ci> x </ci>\n"
    "    </bvar>\n"
    "    <bvar>\n"
    "      <ci> y </ci>\n"
    "    </bvar>\n"
    "    <ci> newChild </ci>\n"
    "  </lambda>\n"
  );

  const char* original = wrapMathML
  (
    "<lambda>"
    "  <bvar> <ci>x</ci> </bvar>"
    "  <ci>y</ci>"
    "</lambda>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == false);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->addChild(newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == true);
  fail_unless(N->getChild(2)->representsBvar() == false);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_addToLog_1)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "    <logbase>\n"
    "      <cn type=\"integer\"> 3 </cn>\n"
    "    </logbase>\n"
    "    <ci> newChild </ci>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <log/> <logbase> <cn type='integer'> 3 </cn> </logbase>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->addChild(newChild);

  /* old behaviour will 'replace' the last child when it is written out
   * but it does have 3 children 
   */ 
  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_addToLog_2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "    <logbase>\n"
    "      <cn type=\"integer\"> 10 </cn>\n"
    "    </logbase>\n"
    "    <ci> newChild </ci>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <log/> "
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->addChild(newChild);

  /* old behaviour will 'replace' the last child when it is written out
   * but it does have 3 children 
   */ 
  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_addToLog_3)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION_LOG);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->addChild(newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 1);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_addToRoot_1)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <degree>\n"
    "      <cn type=\"integer\"> 3 </cn>\n"
    "    </degree>\n"
    "    <ci> newChild </ci>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <root/> <degree> <cn type='integer'> 3 </cn> </degree>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->addChild(newChild);

  /* old behaviour will 'replace' the last child when it is written out
   * but it does have 3 children 
   */ 
  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_addToRoot_2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <degree>\n"
    "      <cn type=\"integer\"> 2 </cn>\n"
    "    </degree>\n"
    "    <ci> newChild </ci>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <root/> "
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->addChild(newChild);

  /* old behaviour will 'replace' the last child when it is written out
   * but it does have 3 children 
   */ 
  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_addToRoot_3)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <ci> newChild </ci>\n"
    "  </apply>\n"
  );

  N = new ASTNode(AST_FUNCTION_ROOT);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->addChild(newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 1);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_getChild)
{

  N = new ASTNode(AST_TIMES);

  ASTNode * c1 = new ASTNode(AST_NAME);
  c1->setName("c1");
  N->addChild(c1);
  ASTNode * c2 = new ASTNode(AST_NAME);
  c2->setName("c2");
  N->addChild(c2);

  /* we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  /* check we fail nicely if we try to access more children */
  ASTNode * child = N->getChild(2);

  fail_unless ( child == NULL);

  child = N->getChild(3);

  fail_unless ( child == NULL);
  
  child = N->getChild(1);

  fail_unless ( child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "c2") == 0); 
}
END_TEST


START_TEST (test_ChildFunctions_getChildFromPiecewise_1)
{
  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <ci>y</ci>"
    "    <apply> <eq/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "    <otherwise>\n"
    "      <ci> x </ci>\n"
    "    </otherwise>\n"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 3 children */
  fail_unless(N->getNumChildren() == 3);

  /* check we fail nicely if we try to access more children */
  ASTNode * child = N->getChild(4);

  fail_unless ( child == NULL);

  child = N->getChild(3);

  fail_unless ( child == NULL);

  child = N->getChild(2);

  fail_unless ( child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "x") == 0); 

  child = N->getChild(1);

  fail_unless ( child->getType() == AST_RELATIONAL_EQ);

  child = N->getChild(0);

  fail_unless ( child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "y") == 0); 
}
END_TEST


START_TEST (test_ChildFunctions_getChildFromPiecewise_2)
{
  N = new ASTNode(AST_FUNCTION_PIECEWISE);

  ASTNode * c1 = new ASTNode(AST_NAME);
  c1->setName("y");
  N->addChild(c1);
  ASTNode * c2 = new ASTNode(AST_CONSTANT_TRUE);
  N->addChild(c2);
  ASTNode * c3 = new ASTNode(AST_NAME);
  c3->setName("x");
  N->addChild(c3);

  /* old behaviour - we should have 3 children */
  fail_unless(N->getNumChildren() == 3);

  /* check we fail nicely if we try to access more children */
  ASTNode * child = N->getChild(4);

  fail_unless ( child == NULL);

  child = N->getChild(3);

  fail_unless ( child == NULL);

  child = N->getChild(2);

  fail_unless ( child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "x") == 0); 

  child = N->getChild(1);

  fail_unless ( child->getType() == AST_CONSTANT_TRUE);

  child = N->getChild(0);

  fail_unless ( child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "y") == 0); 
}
END_TEST


START_TEST (test_ChildFunctions_getChildFromLambda_1)
{
  const char* original = wrapMathML
  (
    "<lambda>"
    "  <bvar> <ci>x</ci> </bvar>"
    "  <apply> <cos/><ci>x</ci></apply>"
    "</lambda>"
 );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  /* check we fail nicely if we try to access more children */
  ASTNode * child = N->getChild(3);

  fail_unless ( child == NULL);

  child = N->getChild(2);

  fail_unless ( child == NULL);

  child = N->getChild(0);

  fail_unless ( child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "x") == 0); 
  fail_unless( child->representsBvar() == true);

  child = N->getChild(1);

  fail_unless ( child->getType() == AST_FUNCTION_COS);
  fail_unless (child->getNumChildren() == 1);
  fail_unless( child->representsBvar() == false);

  ASTNode * child1 = child->getChild(0);

  fail_unless ( child1->getType() == AST_NAME);
  fail_unless( strcmp(child1->getName(), "x") == 0); 
}
END_TEST


START_TEST (test_ChildFunctions_getChildFromLambda_2)
{
  N = new ASTNode(AST_LAMBDA);

  ASTNode * c1 = new ASTNode(AST_NAME);
  c1->setName("y");
  N->addChild(c1);
  ASTNode * c2 = new ASTNode(AST_FUNCTION_ABS);
  ASTNode * c3 = new ASTNode(AST_NAME);
  c3->setName("y");
  c2->addChild(c3);

  N->addChild(c2);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  /* check we fail nicely if we try to access more children */
  ASTNode * child = N->getChild(3);

  fail_unless ( child == NULL);

  child = N->getChild(2);

  fail_unless ( child == NULL);

  child = N->getChild(0);

  fail_unless ( child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "y") == 0); 
  fail_unless( child->representsBvar() == true);

  child = N->getChild(1);

  fail_unless( child->representsBvar() == false);
  fail_unless ( child->getType() == AST_FUNCTION_ABS);
  fail_unless (child->getNumChildren() == 1);

  ASTNode * child1 = child->getChild(0);

  fail_unless ( child1->getType() == AST_NAME);
  fail_unless( strcmp(child1->getName(), "y") == 0); 
}
END_TEST


START_TEST (test_ChildFunctions_getChildFromLog_1)
{
  const char* original = wrapMathML
  (
    "<apply> <log/> "
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * child = N->getChild(0);

  fail_unless(child->getType() == AST_INTEGER);
  fail_unless(child->getInteger() == 10);

  child = N->getChild(1);

  fail_unless(child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "x") == 0); 

}
END_TEST


START_TEST (test_ChildFunctions_getChildFromLog_2)
{
  const char* original = wrapMathML
  (
    "<apply> <log/> <logbase> <cn type='integer'> 3 </cn> </logbase>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * child = N->getChild(0);

  fail_unless(child->getType() == AST_INTEGER);
  fail_unless(child->getInteger() == 3);

  child = N->getChild(1);

  fail_unless(child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "x") == 0); 

}
END_TEST


START_TEST (test_ChildFunctions_getChildFromLog_3)
{
  N = new ASTNode(AST_FUNCTION_LOG);

  ASTNode * c = new ASTNode(AST_QUALIFIER_LOGBASE);
  ASTNode * c1 = new ASTNode(AST_INTEGER);
  c1->setValue(2);

  c->addChild(c1);
  N->addChild(c);

  ASTNode * c3 = new ASTNode(AST_NAME);
  c3->setName("x");
  N->addChild(c3);


  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * child = N->getChild(0);

  fail_unless(child->getType() == AST_INTEGER);
  fail_unless(child->getInteger() == 2);

  child = N->getChild(1);

  fail_unless(child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "x") == 0); 

}
END_TEST


START_TEST (test_ChildFunctions_getChildFromRoot_1)
{
  const char* original = wrapMathML
  (
    "<apply> <root/> "
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * child = N->getChild(0);

  fail_unless(child->getType() == AST_INTEGER);
  fail_unless(child->getInteger() == 2);

  child = N->getChild(1);

  fail_unless(child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "x") == 0); 

}
END_TEST


START_TEST (test_ChildFunctions_getChildFromRoot_2)
{
  const char* original = wrapMathML
  (
    "<apply> <root/> <degree> <cn type='integer'> 3 </cn> </degree>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * child = N->getChild(0);

  fail_unless(child->getType() == AST_INTEGER);
  fail_unless(child->getInteger() == 3);

  child = N->getChild(1);

  fail_unless(child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "x") == 0); 

}
END_TEST


START_TEST (test_ChildFunctions_getChildFromRoot_3)
{
  N = new ASTNode(AST_FUNCTION_ROOT);

  ASTNode * c = new ASTNode(AST_QUALIFIER_DEGREE);
  ASTNode * c1 = new ASTNode(AST_INTEGER);
  c1->setValue(2);

  c->addChild(c1);
  N->addChild(c);

  ASTNode * c3 = new ASTNode(AST_NAME);
  c3->setName("x");
  N->addChild(c3);


  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * child = N->getChild(0);

  fail_unless(child->getType() == AST_INTEGER);
  fail_unless(child->getInteger() == 2);

  child = N->getChild(1);

  fail_unless(child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "x") == 0); 

}
END_TEST


START_TEST (test_ChildFunctions_remove)
{

  N = new ASTNode(AST_TIMES);

  ASTNode * c1 = new ASTNode(AST_NAME);
  c1->setName("c1");
  N->addChild(c1);
  ASTNode * c2 = new ASTNode(AST_NAME);
  c2->setName("c2");
  N->addChild(c2);

  /* we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  /* check we fail nicely if we try to access more children */
  int i = N->removeChild(3);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 2);

  i = N->removeChild(2);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 2);

  i = N->removeChild(0);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 1);

  ASTNode *child = N->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "c2") == 0); 
}
END_TEST


START_TEST (test_ChildFunctions_removeFromPiecewise_1)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <cn> 0 </cn>\n"
    "      <apply>\n"
    "        <eq/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "    <piece>\n"
    "      <ci> x </ci>\n"
    "      <apply>\n"
    "        <gt/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <apply> <cos/> <ci>x</ci> </apply>"
    "    <apply> <lt/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "  <piece>"
    "    <cn>0</cn>"
    "    <apply> <eq/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "  <piece>"
    "    <ci>x</ci>"
    "    <apply> <gt/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 6 children */
  fail_unless(N->getNumChildren() == 6);

  int i = N->removeChild(0);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);

  /* old behaviour - we should have 5 children 
   * although the interpretation of the piecewise would be a complete mess
   */
  fail_unless(N->getNumChildren() == 5);
  
  i = N->removeChild(0);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);

  /* old behaviour - we should have 4 children 
   */
  fail_unless(N->getNumChildren() == 4);


  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromPiecewise_2)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <cn> 0 </cn>\n"
    "      <apply>\n"
    "        <eq/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <cn>0</cn>"
    "    <apply> <eq/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "    <otherwise>\n"
    "      <ci> x </ci>\n"
    "    </otherwise>\n"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 3 children */
  fail_unless(N->getNumChildren() == 3);

  int i = N->removeChild(2);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);


  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromPiecewise_3)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <cn> 0 </cn>\n"
    "    </piece>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <cn>0</cn>"
    "    <apply> <eq/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  int i = N->removeChild(1);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);

  /* old behaviour - we should have 1 children 
   * although the interpretation of the piecewise would be a complete mess
   * except there was only one piece so its reasonably clean
   */
  fail_unless(N->getNumChildren() == 1);
  
  /* lets look at the bad piecewise */
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromLambda_1)
{
  const char* expected = wrapMathML
  (
    "  <lambda>\n"
    "    <bvar>\n"
    "      <ci> y </ci>\n"
    "    </bvar>\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <ci> x </ci>\n"
    "      <ci> y </ci>\n"
    "    </apply>\n"
    "  </lambda>\n"
  );

  const char* original = wrapMathML
  (
    "<lambda>"
    "    <bvar> <ci>x</ci> </bvar>"
    "    <bvar> <ci>y</ci> </bvar>"
    "    <apply> <plus/> <ci>x</ci> <ci>y</ci> </apply>"
    "</lambda>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 3 children */
  fail_unless(N->getNumChildren() == 3);
  fail_unless(N->getNumBvars() == 2);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == true);
  fail_unless(N->getChild(2)->representsBvar() == false);

  /* check we fail nicely if we try to access more children */
  int i = N->removeChild(3);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  
  i = N->removeChild(0);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 2);
  fail_unless(N->getNumBvars() == 1);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == false);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromLambda_2)
{
  const char* expected = wrapMathML
  (
    "  <lambda>\n"
    "    <bvar>\n"
    "      <ci> x </ci>\n"
    "    </bvar>\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <ci> x </ci>\n"
    "      <ci> y </ci>\n"
    "    </apply>\n"
    "  </lambda>\n"
  );

  const char* original = wrapMathML
  (
    "<lambda>"
    "    <bvar> <ci>x</ci> </bvar>"
    "    <bvar> <ci>y</ci> </bvar>"
    "    <apply> <plus/> <ci>x</ci> <ci>y</ci> </apply>"
    "</lambda>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 3 children */
  fail_unless(N->getNumChildren() == 3);
  fail_unless(N->getNumBvars() == 2);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == true);
  fail_unless(N->getChild(2)->representsBvar() == false);

  int i = N->removeChild(1);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 2);
  fail_unless(N->getNumBvars() == 1);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == false);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromLambda_3)
{
  const char* expected = wrapMathML
  (
    "  <lambda>\n"
    "    <bvar>\n"
    "      <ci> x </ci>\n"
    "    </bvar>\n"
    "    <bvar>\n"
    "      <ci> y </ci>\n"
    "    </bvar>\n"
    "  </lambda>\n"
  );

  const char* original = wrapMathML
  (
    "<lambda>"
    "    <bvar> <ci>x</ci> </bvar>"
    "    <bvar> <ci>y</ci> </bvar>"
    "    <apply> <plus/> <ci>x</ci> <ci>y</ci> </apply>"
    "</lambda>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 3 children */
  fail_unless(N->getNumChildren() == 3);
  fail_unless(N->getNumBvars() == 2);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == true);
  fail_unless(N->getChild(2)->representsBvar() == false);

  int i = N->removeChild(2);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 2);
  fail_unless(N->getNumBvars() == 2);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == true);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromLog_1)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <log/> <logbase> <cn type='integer'> 3 </cn> </logbase>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  /* check we fail nicely if we try to access more children */
  int i = N->removeChild(3);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  
  i = N->removeChild(1);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 1);
  
  ASTNode* child = N->getChild(0);
  fail_unless(child->getType() == AST_INTEGER);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromLog_2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <log/>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  /* check we fail nicely if we try to access more children */
  int i = N->removeChild(3);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  
  i = N->removeChild(1);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 1);
  
  ASTNode* child = N->getChild(0);
  fail_unless(child->getType() == AST_INTEGER);
   
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromLog_3)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <log/> <logbase> <cn type='integer'> 3 </cn> </logbase>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  int i = N->removeChild(0);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 1);
  
  ASTNode* child = N->getChild(0);
  fail_unless(child->getType() == AST_NAME);
   
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromLog_4)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <log/>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  int i = N->removeChild(0);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 1);

  ASTNode* child = N->getChild(0);
  fail_unless(child->getType() == AST_NAME);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromRoot_1)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <degree>\n"
    "      <cn type=\"integer\"> 3 </cn>\n"
    "    </degree>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <root/> <degree> <cn type='integer'> 3 </cn> </degree>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  /* check we fail nicely if we try to access more children */
  int i = N->removeChild(3);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  
  i = N->removeChild(1);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 1);
  
  ASTNode* child = N->getChild(0);
  fail_unless(child->getType() == AST_INTEGER);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromRoot_2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <degree>\n"
    "      <cn type=\"integer\"> 2 </cn>\n"
    "    </degree>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <root/>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  /* check we fail nicely if we try to access more children */
  int i = N->removeChild(3);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  
  i = N->removeChild(1);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 1);
  
  ASTNode* child = N->getChild(0);
  fail_unless(child->getType() == AST_INTEGER);
   
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromRoot_3)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <ci> x </ci>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <root/> <degree> <cn type='integer'> 3 </cn> </degree>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  int i = N->removeChild(0);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 1);
  
  ASTNode* child = N->getChild(0);
  fail_unless(child->getType() == AST_NAME);
   
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_removeFromRoot_4)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <ci> x </ci>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <root/>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  int i = N->removeChild(0);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 1);

  ASTNode* child = N->getChild(0);
  fail_unless(child->getType() == AST_NAME);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_replace)
{

  N = new ASTNode(AST_TIMES);

  ASTNode * c1 = new ASTNode(AST_NAME);
  c1->setName("c1");
  N->addChild(c1);
  ASTNode * c2 = new ASTNode(AST_NAME);
  c2->setName("c2");
  N->addChild(c2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  /* we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  /* check we fail nicely if we try to access more children */
  int i = N->replaceChild(3, newChild);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 2);

  i = N->replaceChild(2, newChild);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 2);

  i = N->replaceChild(1, newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 2);

  ASTNode *child = N->getChild(1);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "newChild") == 0); 
}
END_TEST


START_TEST (test_ChildFunctions_replaceInPiecewise_1)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <ci> newChild </ci>\n"
    "      <apply>\n"
    "        <lt/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <ci> x </ci>"
    "    <apply> <lt/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");

  /* check we fail nicely if we try to access more children */
  int i = N->replaceChild(3, newChild);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 2);

  i = N->replaceChild(2, newChild);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 2);

  i = N->replaceChild(0, newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 2);

  ASTNode *child = N->getChild(0);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "newChild") == 0); 

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_replaceInPiecewise_2)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <ci> x </ci>\n"
    "      <apply>\n"
    "        <lt/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "    <otherwise>\n"
    "      <ci> newChild </ci>\n"
    "    </otherwise>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <ci> x </ci>"
    "    <apply> <lt/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "  <otherwise> <ci> x </ci> </otherwise>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 3 children */
  fail_unless(N->getNumChildren() == 3);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");

  /* check we fail nicely if we try to access more children */
  int i = N->replaceChild(4, newChild);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 3);

  i = N->replaceChild(3, newChild);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 3);

  i = N->replaceChild(2, newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  ASTNode *child = N->getChild(2);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "newChild") == 0); 

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_replaceInPiecewise_3)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <ci> x </ci>\n"
    "      <apply>\n"
    "        <plus/>\n"
    "        <ci> a </ci>\n"
    "        <ci> b </ci>\n"
    "      </apply>\n"
    "    </piece>\n"
    "    <otherwise>\n"
    "      <ci> x </ci>\n"
    "    </otherwise>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <ci> x </ci>"
    "    <apply> <lt/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "  <otherwise> <ci> x </ci> </otherwise>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 3 children */
  fail_unless(N->getNumChildren() == 3);

  ASTNode * newChild = SBML_parseFormula("a + b");

  int i = N->replaceChild(1, newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  ASTNode *child = N->getChild(1);

  fail_unless( child->getType() == AST_PLUS);
  fail_unless( child->getNumChildren() == 2);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_replaceInPiecewise_4)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <apply>\n"
    "        <cos/>\n"
    "        <ci> x </ci>\n"
    "      </apply>\n"
    "      <apply>\n"
    "        <lt/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "    <piece>\n"
    "      <cn> 0 </cn>\n"
    "      <apply>\n"
    "        <eq/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "    <piece>\n"
    "      <cn type=\"integer\"> 3 </cn>\n"
    "      <apply>\n"
    "        <gt/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <apply> <cos/> <ci>x</ci> </apply>"
    "    <apply> <lt/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "  <piece>"
    "    <cn>0</cn>"
    "    <apply> <eq/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "  <piece>"
    "    <ci>x</ci>"
    "    <apply> <gt/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 6 children */
  fail_unless(N->getNumChildren() == 6);

  ASTNode * newChild = SBML_parseFormula("3");

  int i = N->replaceChild(4, newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);

  fail_unless(N->getNumChildren() == 6);
  
  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_insert)
{

  N = new ASTNode(AST_TIMES);

  ASTNode * c1 = new ASTNode(AST_NAME);
  c1->setName("c1");
  N->addChild(c1);
  ASTNode * c2 = new ASTNode(AST_NAME);
  c2->setName("c2");
  N->addChild(c2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  ASTNode * newChild1 = new ASTNode(AST_NAME);
  newChild1->setName("newChild1");

  /* we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  /* check we fail nicely if we try to access more children */
  int i = N->insertChild(3, newChild);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 2);

  /* we can insert here because it will just go on the end */
  i = N->insertChild(2, newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);
  fail_unless(strcmp(SBML_formulaToString(N), "c1 * c2 * newChild") == 0);

  i = N->insertChild(1, newChild1);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 4);
  fail_unless(strcmp(SBML_formulaToString(N), "c1 * newChild1 * c2 * newChild") == 0);

  ASTNode *child = N->getChild(1);

  fail_unless( child->getType() == AST_NAME);
  fail_unless( strcmp(child->getName(), "newChild1") == 0); 
}
END_TEST


START_TEST (test_ChildFunctions_insertIntoPiecewise_1)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <cn> 0 </cn>\n"
    "      <apply>\n"
    "        <eq/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </piece>\n"
    "    <otherwise>\n"
    "      <ci> newChild </ci>\n"
    "    </otherwise>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <cn>0</cn>"
    "    <apply> <eq/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  /* check we fail nicely if we try to access more children */
  int i = N->insertChild(3, newChild);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 2);

  /* we can insert here because it will just go on the end */
  i = N->insertChild(2, newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );

}
END_TEST


START_TEST (test_ChildFunctions_insertIntoPiecewise_2)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <cn> 0 </cn>\n"
    "      <ci> newChild </ci>\n"
    "    </piece>\n"
    "    <otherwise>\n"
    "      <apply>\n"
    "        <eq/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </otherwise>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <cn>0</cn>"
    "    <apply> <eq/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  /* check we fail nicely if we try to access more children */
  int i = N->insertChild(3, newChild);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 2);

  i = N->insertChild(1, newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_insertIntoPiecewise_3)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <ci> newChild </ci>\n"
    "      <cn> 0 </cn>\n"
    "    </piece>\n"
    "    <otherwise>\n"
    "      <apply>\n"
    "        <eq/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </otherwise>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <cn>0</cn>"
    "    <apply> <eq/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  /* check we fail nicely if we try to access more children */
  int i = N->prependChild(newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_insertIntoPiecewise_4)
{
  const char* expected = wrapMathML
  (
    "  <piecewise>\n"
    "    <piece>\n"
    "      <apply>\n"
    "        <plus/>\n"
    "        <ci> a </ci>\n"
    "        <ci> b </ci>\n"
    "      </apply>\n"
    "      <cn> 0 </cn>\n"
    "    </piece>\n"
    "    <otherwise>\n"
    "      <apply>\n"
    "        <eq/>\n"
    "        <ci> x </ci>\n"
    "        <cn> 0 </cn>\n"
    "      </apply>\n"
    "    </otherwise>\n"
    "  </piecewise>\n"
  );

  const char* original = wrapMathML
  (
    "<piecewise>"
    "  <piece>"
    "    <cn>0</cn>"
    "    <apply> <eq/> <ci>x</ci> <cn>0</cn> </apply>"
    "  </piece>"
    "</piecewise>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = SBML_parseFormula("a + b");
  
  /* check we fail nicely if we try to access more children */
  int i = N->prependChild(newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_insertIntoLambda_1)
{
  const char* expected = wrapMathML
  (
    "  <lambda>\n"
    "    <bvar>\n"
    "      <ci> x </ci>\n"
    "    </bvar>\n"
    "    <bvar>\n"
    "      <ci> y </ci>\n"
    "    </bvar>\n"
    "    <ci> newChild </ci>\n"
    "  </lambda>\n"
  );

  const char* original = wrapMathML
  (
    "<lambda>"
    "    <bvar> <ci>x</ci> </bvar>"
    "    <ci>y</ci>"
    "</lambda>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);
  fail_unless(N->getNumBvars() == 1);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == false);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  /* check we fail nicely if we try to access more children */
  int i = N->insertChild(3, newChild);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 2);

  /* insert at end */
  i = N->insertChild(2, newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);
  fail_unless(N->getNumBvars() == 2);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == true);
  fail_unless(N->getChild(2)->representsBvar() == false);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_insertIntoLambda_2)
{
  const char* expected = wrapMathML
  (
    "  <lambda>\n"
    "    <bvar>\n"
    "      <ci> x </ci>\n"
    "    </bvar>\n"
    "    <bvar>\n"
    "      <ci> newChild </ci>\n"
    "    </bvar>\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <ci> x </ci>\n"
    "      <ci> y </ci>\n"
    "    </apply>\n"
    "  </lambda>\n"
  );

  const char* original = wrapMathML
  (
    "<lambda>"
    "    <bvar> <ci>x</ci> </bvar>"
    "    <apply> <plus/> <ci>x</ci> <ci>y</ci> </apply>"
    "</lambda>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);
  fail_unless(N->getNumBvars() == 1);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == false);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->insertChild(1, newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);
  fail_unless(N->getNumBvars() == 2);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == true);
  fail_unless(N->getChild(2)->representsBvar() == false);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_insertIntoLambda_3)
{
  const char* expected = wrapMathML
  (
    "  <lambda>\n"
    "    <bvar>\n"
    "      <ci> newChild </ci>\n"
    "    </bvar>\n"
    "    <bvar>\n"
    "      <ci> x </ci>\n"
    "    </bvar>\n"
    "    <apply>\n"
    "      <plus/>\n"
    "      <ci> x </ci>\n"
    "      <ci> y </ci>\n"
    "    </apply>\n"
    "  </lambda>\n"
  );

  const char* original = wrapMathML
  (
    "<lambda>"
    "    <bvar> <ci>x</ci> </bvar>"
    "    <apply> <plus/> <ci>x</ci> <ci>y</ci> </apply>"
    "</lambda>"
  );

  N = readMathMLFromString(original);

  /* old behaviour - we should have 2 children */
  fail_unless(N->getNumChildren() == 2);
  fail_unless(N->getNumBvars() == 1);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == false);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->insertChild(0, newChild);

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);
  fail_unless(N->getNumBvars() == 2);
  fail_unless(N->getChild(0)->representsBvar() == true);
  fail_unless(N->getChild(1)->representsBvar() == true);
  fail_unless(N->getChild(2)->representsBvar() == false);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_insertIntoLog_1)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "    <logbase>\n"
    "      <cn type=\"integer\"> 3 </cn>\n"
    "    </logbase>\n"
    "    <ci> newChild </ci>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <log/> <logbase> <cn type='integer'> 3 </cn> </logbase>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  /* check we fail nicely if we try to access more children */
  int i = N->insertChild(3, newChild);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 2);

  i = N->insertChild(2, newChild);

  /* old behaviour will 'replace' the last child when it is written out
   * but it does have 3 children 
   */ 
  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_insertIntoLog_2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "    <logbase>\n"
    "      <cn type=\"integer\"> 3 </cn>\n"
    "    </logbase>\n"
    "    <ci> x </ci>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <log/> <logbase> <cn type='integer'> 3 </cn> </logbase>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->insertChild(1, newChild);

  /* old behaviour will 'replace' the last child when it is written out
   * but it does have 3 children 
   */ 
  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_insertIntoLog_3)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <log/>\n"
    "    <logbase>\n"
    "      <ci> newChild </ci>\n"
    "    </logbase>\n"
    "    <ci> x </ci>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <log/> <logbase> <cn type='integer'> 3 </cn> </logbase>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->insertChild(0, newChild);

  /* old behaviour will 'replace' the first child when it is written out
   * but it does have 3 children 
   */ 
  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  ASTNode * child = N->getChild(1);
  fail_unless(child->getType() == AST_INTEGER);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_insertIntoRoot_1)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <degree>\n"
    "      <cn type=\"integer\"> 3 </cn>\n"
    "    </degree>\n"
    "    <ci> newChild </ci>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <root/> <degree> <cn type='integer'> 3 </cn> </degree>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  /* check we fail nicely if we try to access more children */
  int i = N->insertChild(3, newChild);

  fail_unless ( i == LIBSBML_INDEX_EXCEEDS_SIZE);
  fail_unless(N->getNumChildren() == 2);

  i = N->insertChild(2, newChild);

  /* old behaviour will 'replace' the last child when it is written out
   * but it does have 3 children 
   */ 
  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_insertIntoRoot_2)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <degree>\n"
    "      <cn type=\"integer\"> 3 </cn>\n"
    "    </degree>\n"
    "    <ci> x </ci>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <root/> <degree> <cn type='integer'> 3 </cn> </degree>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->insertChild(1, newChild);

  /* old behaviour will 'replace' the last child when it is written out
   * but it does have 3 children 
   */ 
  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  fail_unless( equals(expected, S) );
}
END_TEST


START_TEST (test_ChildFunctions_insertIntoRoot_3)
{
  const char* expected = wrapMathML
  (
    "  <apply>\n"
    "    <root/>\n"
    "    <degree>\n"
    "      <ci> newChild </ci>\n"
    "    </degree>\n"
    "    <ci> x </ci>\n"
    "  </apply>\n"
  );

  const char* original = wrapMathML
  (
    "<apply> <root/> <degree> <cn type='integer'> 3 </cn> </degree>"
    "               <ci> x </ci>"
    "</apply>"
  );

  N = readMathMLFromString(original);

  fail_unless(N->getNumChildren() == 2);

  ASTNode * newChild = new ASTNode(AST_NAME);
  newChild->setName("newChild");
  
  int i = N->insertChild(0, newChild);

  /* old behaviour will 'replace' the first child when it is written out
   * but it does have 3 children 
   */ 
  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless(N->getNumChildren() == 3);

  S = writeMathMLToString(N);

  ASTNode * child = N->getChild(1);
  fail_unless(child->getType() == AST_INTEGER);

  fail_unless( equals(expected, S) );
}
END_TEST


Suite *
create_suite_TestChildFunctions ()
{
  Suite *suite = suite_create("TestChildFunctions");
  TCase *tcase = tcase_create("TestChildFunctions");

  tcase_add_checked_fixture(tcase, TestChildFunctions_setup, 
                                   TestChildFunctions_teardown);

  tcase_add_test( tcase, test_ChildFunctions_addToPiecewise_1  );
  tcase_add_test( tcase, test_ChildFunctions_addToPiecewise_2  );
  tcase_add_test( tcase, test_ChildFunctions_addToPiecewise_3  );
  tcase_add_test( tcase, test_ChildFunctions_addToLambda_1  );
  tcase_add_test( tcase, test_ChildFunctions_addToLog_1  );
  tcase_add_test( tcase, test_ChildFunctions_addToLog_2  );
  tcase_add_test( tcase, test_ChildFunctions_addToLog_3  );
  tcase_add_test( tcase, test_ChildFunctions_addToRoot_1  );
  tcase_add_test( tcase, test_ChildFunctions_addToRoot_2  );
  tcase_add_test( tcase, test_ChildFunctions_addToRoot_3  );
  tcase_add_test( tcase, test_ChildFunctions_getChild             );
  tcase_add_test( tcase, test_ChildFunctions_getChildFromPiecewise_1  );
  tcase_add_test( tcase, test_ChildFunctions_getChildFromPiecewise_2  );
  tcase_add_test( tcase, test_ChildFunctions_getChildFromLambda_1  );
  tcase_add_test( tcase, test_ChildFunctions_getChildFromLambda_2  );
  tcase_add_test( tcase, test_ChildFunctions_getChildFromLog_1  );
  tcase_add_test( tcase, test_ChildFunctions_getChildFromLog_2  );
  tcase_add_test( tcase, test_ChildFunctions_getChildFromLog_3  );
  tcase_add_test( tcase, test_ChildFunctions_getChildFromRoot_1  );
  tcase_add_test( tcase, test_ChildFunctions_getChildFromRoot_2  );
  tcase_add_test( tcase, test_ChildFunctions_getChildFromRoot_3  );
  tcase_add_test( tcase, test_ChildFunctions_remove               );
  tcase_add_test( tcase, test_ChildFunctions_removeFromPiecewise_1  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromPiecewise_2  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromPiecewise_3  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromLambda_1  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromLambda_2  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromLambda_3  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromLog_1  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromLog_2  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromLog_3  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromLog_4  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromRoot_1  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromRoot_2  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromRoot_3  );
  tcase_add_test( tcase, test_ChildFunctions_removeFromRoot_4  );
  tcase_add_test( tcase, test_ChildFunctions_replace               );
  tcase_add_test( tcase, test_ChildFunctions_replaceInPiecewise_1  );
  tcase_add_test( tcase, test_ChildFunctions_replaceInPiecewise_2  );
  tcase_add_test( tcase, test_ChildFunctions_replaceInPiecewise_3  );
  tcase_add_test( tcase, test_ChildFunctions_replaceInPiecewise_4  );
  tcase_add_test( tcase, test_ChildFunctions_insert               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoPiecewise_1               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoPiecewise_2               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoPiecewise_3               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoPiecewise_4               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoLambda_1               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoLambda_2               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoLambda_3               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoLog_1               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoLog_2               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoLog_3               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoRoot_1               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoRoot_2               );
  tcase_add_test( tcase, test_ChildFunctions_insertIntoRoot_3               );

  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND
