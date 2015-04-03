/**
 * @file    TestReadFromFile2.cpp
 * @brief   Tests for reading MathML from files into ASTNodes.
 * @author  Sarah Keating
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

#include <sbml/SBMLReader.h>
#include <sbml/SBMLTypes.h>

#include <sbml/math/ASTNode.h>



#include <string>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS


extern char *TestDataDirectory;


START_TEST (test_read_MathML_2)
{
  SBMLReader         reader;
  SBMLDocument*      d;
  Model*             m;
  FunctionDefinition* fd;
  InitialAssignment* ia;
  Rule*              r;
  char * math;


  std::string filename(TestDataDirectory);
  filename += "mathML_2-invalid.xml";


  d = reader.readSBML(filename);

  if (d == NULL)
  {
    fail("readSBML(\"mathML_2-invalid.xml\") returned a NULL pointer.");
  }

  m = d->getModel();
  fail_unless( m != NULL, NULL );

  // check that whole model has been read in
  fail_unless( m->getNumFunctionDefinitions() == 2, NULL);
  fail_unless( m->getNumInitialAssignments() == 1, NULL);
  fail_unless( m->getNumRules() == 2, NULL );

  //<functionDefinition id="fd">
  //  <math xmlns="http://www.w3.org/1998/Math/MathML">
  //    <lambda>
  //      <apply/>
  //    </lambda>
  //  </math>
  //</functionDefinition>
  fd = m->getFunctionDefinition(0);
  const ASTNode *fd_math = fd->getMath();

  fail_unless (fd_math->getType() == AST_LAMBDA, NULL);
  fail_unless (fd_math->getNumChildren() == 1, NULL);
  math = SBML_formulaToString(fd_math);
  fail_unless (!strcmp(math, "lambda()"), NULL);
  safe_free(math);
  //fail_unless (fd_math->getNumVariablesWithUndeclaredUnits() == 0);
  //fail_unless( fd_math->containsVariable("c") == false );
  //fail_unless( fd_math->containsVariable("x") == false );
  //fail_unless( fd_math->containsVariable("p") == false );

  ASTNode *child = fd_math->getChild(0);
  fail_unless (child->getType() == AST_UNKNOWN, NULL);
  fail_unless (child->getNumChildren() == 0, NULL);
  math = SBML_formulaToString(child);
  fail_unless (!strcmp(math, ""), NULL);
  safe_free(math);
  //fail_unless( child->containsVariable("c") == false );
  //fail_unless( child->containsVariable("x") == false );
  //fail_unless( child->containsVariable("p") == false );

  //<functionDefinition id="fd1">
  //  <math xmlns="http://www.w3.org/1998/Math/MathML">
  //    <lambda>
  //      <bvar>
  //        <ci> x </ci>
  //      </bvar>
        //<piecewise>
        //  <piece>
        //    <ci> p </ci>
        //    <apply>
        //      <leq/>
        //      <ci> x </ci>
        //      <cn type="integer"> 4 </cn>
        //    </apply>
        //  </piece>
        //</piecewise>
  //    </lambda>
  //  </math>
  //</functionDefinition>
  fd = m->getFunctionDefinition(1);
  const ASTNode *fd1_math = fd->getMath();

  fail_unless (fd1_math->getType() == AST_LAMBDA, NULL);
  fail_unless (fd1_math->getNumChildren() == 2, NULL);
  math = SBML_formulaToString(fd1_math);
  fail_unless (!strcmp(math, "lambda(x, piecewise(p, leq(x, 4)))"), NULL);
  safe_free(math);
  //fail_unless (fd1_math->getNumVariablesWithUndeclaredUnits() == 0);
  //fail_unless( fd1_math->containsVariable("c") == false );
  //fail_unless( fd1_math->containsVariable("x") == true );
  //fail_unless( fd1_math->containsVariable("p") == true );

  ASTNode *child1 = fd1_math->getRightChild();
  fail_unless (child1->getType() == AST_FUNCTION_PIECEWISE, NULL);
  fail_unless (child1->getNumChildren() == 2, NULL);
  math = SBML_formulaToString(child1);
  fail_unless (!strcmp(math, "piecewise(p, leq(x, 4))"), NULL);
  safe_free(math);
  //fail_unless( child1->containsVariable("c") == false );
  //fail_unless( child1->containsVariable("x") == true );
  //fail_unless( child1->containsVariable("p") == true );

  ASTNode *c1 = child1->getChild(0);
  fail_unless (c1->getType() == AST_NAME, NULL);
  fail_unless (c1->getNumChildren() == 0, NULL);
  math = SBML_formulaToString(c1);
  fail_unless (!strcmp(math, "p"), NULL);
  safe_free(math);
  //fail_unless( c1->containsVariable("c") == false );
  //fail_unless( c1->containsVariable("x") == false );
  //fail_unless( c1->containsVariable("p") == true );

  ASTNode *c2 = child1->getChild(1);
  fail_unless (c2->getType() == AST_RELATIONAL_LEQ, NULL);
  fail_unless (c2->getNumChildren() == 2, NULL);
  math = SBML_formulaToString(c2);
  fail_unless (!strcmp(math, "leq(x, 4)"), NULL);
  safe_free(math);
  //fail_unless( c2->containsVariable("c") == false );
  //fail_unless( c2->containsVariable("x") == true );
  //fail_unless( c2->containsVariable("p") == false );


  
  //<initialAssignment symbol="p1">
    //<math xmlns="http://www.w3.org/1998/Math/MathML">
    //    <piecewise>
    //      <piece>
    //          <apply><minus/><ci> x </ci></apply>
    //          <apply><lt/><ci> x </ci> <cn> 0 </cn></apply>
    //      </piece>
    //      <piece>
    //          <cn> 0 </cn>
    //          <apply><eq/><ci> x </ci> <cn> 0 </cn></apply>
    //      </piece>
    //    </piecewise>
    //</math>
  //</initialAssignment>
  ia = m->getInitialAssignment(0);
  const ASTNode *ia_math = ia->getMath();

  fail_unless (ia_math->getType() == AST_FUNCTION_PIECEWISE, NULL);
  fail_unless (ia_math->getNumChildren() == 4, NULL);
  math = SBML_formulaToString(ia_math);
  fail_unless (!strcmp(math, "piecewise(-x, lt(x, 0), 0, eq(x, 0))"), NULL);
  safe_free(math);
  //fail_unless (ia_math->getNumVariablesWithUndeclaredUnits() == 0);
  //fail_unless( ia_math->containsVariable("c") == false );
  //fail_unless( ia_math->containsVariable("x") == true );
  //fail_unless( ia_math->containsVariable("p") == false );

  child1 = ia_math->getChild(0);
  ASTNode *child2 = ia_math->getChild(1);
  ASTNode *child3 = ia_math->getChild(2);
  ASTNode *child4 = ia_math->getChild(3);

  fail_unless (child1->getType() == AST_MINUS, NULL);
  fail_unless (child1->getNumChildren() == 1, NULL);
  math = SBML_formulaToString(child1);
  fail_unless (!strcmp(math, "-x"), NULL);
  safe_free(math);
  //fail_unless( child1->containsVariable("c") == false );
  //fail_unless( child1->containsVariable("x") == true );
  //fail_unless( child1->containsVariable("p") == false );

  fail_unless (child2->getType() == AST_RELATIONAL_LT, NULL);
  fail_unless (child2->getNumChildren() == 2, NULL);
  math = SBML_formulaToString(child2);
  fail_unless (!strcmp(math, "lt(x, 0)"), NULL);
  safe_free(math);
  //fail_unless( child2->containsVariable("c") == false );
  //fail_unless( child2->containsVariable("x") == true );
  //fail_unless( child2->containsVariable("p") == false );

  fail_unless (child3->getType() == AST_REAL, NULL);
  fail_unless (child3->getNumChildren() == 0, NULL);
  math = SBML_formulaToString(child3);
  fail_unless (!strcmp(math, "0"), NULL);
  safe_free(math);
  //fail_unless( child3->containsVariable("c") == false );
  //fail_unless( child3->containsVariable("x") == false );
  //fail_unless( child3->containsVariable("p") == false );

  fail_unless (child4->getType() == AST_RELATIONAL_EQ, NULL);
  fail_unless (child4->getNumChildren() == 2, NULL);
  math = SBML_formulaToString(child4);
  fail_unless (!strcmp(math, "eq(x, 0)"), NULL);
  safe_free(math);
  //fail_unless( child4->containsVariable("c") == false );
  //fail_unless( child4->containsVariable("x") == true );
  //fail_unless( child4->containsVariable("p") == false );

  //<algebraicRule>
  //  <math xmlns="http://www.w3.org/1998/Math/MathML">
      //<apply>
      //<true/>
      //</apply>
  //  </math>
  //</algebraicRule>
  r = m->getRule(0);
  const ASTNode *r_math = r->getMath();

  fail_unless (r_math->getType() == AST_CONSTANT_TRUE, NULL);
  fail_unless (r_math->getNumChildren() == 0, NULL);
  math = SBML_formulaToString(r_math);
  fail_unless (!strcmp(math, "true"), NULL);
  safe_free(math);
  //fail_unless (r_math->getNumVariablesWithUndeclaredUnits() == 0);
  //fail_unless( r_math->containsVariable("c") == false );
  //fail_unless( r_math->containsVariable("x") == false );
  //fail_unless( r_math->containsVariable("p") == false );

  //<assignmentRule variable="p2">
  //  <math xmlns="http://www.w3.org/1998/Math/MathML">
      //<apply>
      //  <log/>
      //  <logbase>
      //    <cn> 3 </cn>
      //  </logbase>
      //  <ci> x </ci>
      //</apply>
  //  </math>
  //</assignmentRule>
  r = m->getRule(1);
  const ASTNode *r1_math = r->getMath();

  fail_unless (r1_math->getType() == AST_FUNCTION_LOG, NULL);
  fail_unless (r1_math->getNumChildren() == 2, NULL);
  math = SBML_formulaToString(r1_math);
  fail_unless (!strcmp(math, "log(3, x)"), NULL);
  safe_free(math);
  //fail_unless (r1_math->getNumVariablesWithUndeclaredUnits() == 0);
  //fail_unless( r1_math->containsVariable("c") == false );
  //fail_unless( r1_math->containsVariable("x") == true );
  //fail_unless( r1_math->containsVariable("p") == false );

  child1 = r1_math->getChild(0);
  child2 = r1_math->getChild(1);

  fail_unless (child1->getType() == AST_REAL, NULL);
  fail_unless (child1->getNumChildren() == 0, NULL);
  math = SBML_formulaToString(child1);
  fail_unless (!strcmp(math, "3"), NULL);
  safe_free(math);
  //fail_unless( child1->containsVariable("c") == false );
  //fail_unless( child1->containsVariable("x") == false );
  //fail_unless( child1->containsVariable("p") == false );

  fail_unless (child2->getType() == AST_NAME, NULL);
  fail_unless (child2->getNumChildren() == 0, NULL);
  math = SBML_formulaToString(child2);
  fail_unless (!strcmp(math, "x"), NULL);
  safe_free(math);
  //fail_unless( child2->containsVariable("c") == false );
  //fail_unless( child2->containsVariable("x") == true );
  //fail_unless( child2->containsVariable("p") == false );


  delete d;
}
END_TEST


Suite *
create_suite_TestReadFromFile2 (void)
{ 
  Suite *suite = suite_create("test-data/mathML_2.xml");
  TCase *tcase = tcase_create("test-data/mathML_2.xml");


  tcase_add_test(tcase, test_read_MathML_2);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

