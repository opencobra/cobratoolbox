/**
 * @file    TestReadFromFile1.cpp
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


START_TEST (test_read_MathML_1)
{
  SBMLReader         reader;
  SBMLDocument*      d;
  Model*             m;
  FunctionDefinition* fd;
  InitialAssignment* ia;
  Rule*              r;
  KineticLaw*        kl;
  char * math;


  std::string filename(TestDataDirectory);
  filename += "mathML_1-invalid.xml";


  d = reader.readSBML(filename);

  m = d->getModel();
  if (m == NULL)
  {
    fail("readSBML(\"mathML_1-invalid.xml\") returned a NULL pointer.");
  }

  fail_unless( m != NULL, NULL );

  // check that whole model has been read in
  fail_unless( m->getNumFunctionDefinitions() == 2, NULL);
  fail_unless( m->getNumInitialAssignments() == 1, NULL);
  fail_unless( m->getNumRules() == 2, NULL );
  fail_unless( m->getNumReactions() == 1, NULL );

  //<functionDefinition id="fd">
  //  <math xmlns="http://www.w3.org/1998/Math/MathML">
  //    <lambda>
  //      <bvar>
  //        <ci> x </ci>
  //      </bvar>
  //      <apply/>
  //    </lambda>
  //  </math>
  //</functionDefinition>
  fd = m->getFunctionDefinition(0);
  const ASTNode *fd_math = fd->getMath();

  fail_unless (fd_math->getType() == AST_LAMBDA, NULL);
  fail_unless (fd_math->getNumChildren() == 2, NULL);
  math = SBML_formulaToString(fd_math);
  fail_unless (!strcmp(math, "lambda(x, )"), NULL);
  safe_free(math);
  fail_unless (fd_math->getParentSBMLObject() == fd, NULL);
  //fail_unless (fd_math->getNumVariablesWithUndeclaredUnits() == 0);
  //fail_unless( fd_math->containsVariable("c") == false );
  //fail_unless( fd_math->containsVariable("x") == true );

  ASTNode *child = fd_math->getRightChild();
  fail_unless (child->getType() == AST_UNKNOWN, NULL);
  fail_unless (child->getNumChildren() == 0, NULL);
  math = SBML_formulaToString(child);
  fail_unless (!strcmp(math, ""), NULL);
  safe_free(math);

  //<functionDefinition id="fd1">
  //  <math xmlns="http://www.w3.org/1998/Math/MathML">
  //    <lambda>
  //      <bvar>
  //        <ci> x </ci>
  //      </bvar>
  //        <true/>
  //    </lambda>
  //  </math>
  //</functionDefinition>
  fd = m->getFunctionDefinition(1);
  const ASTNode *fd1_math = fd->getMath();

  fail_unless (fd1_math->getType() == AST_LAMBDA, NULL);
  fail_unless (fd1_math->getNumChildren() == 2, NULL);
  math = SBML_formulaToString(fd1_math);
  fail_unless (!strcmp(math, "lambda(x, true)"), NULL);
  safe_free(math);
  fail_unless (fd1_math->getParentSBMLObject() == fd, NULL);
  //fail_unless (fd1_math->getNumVariablesWithUndeclaredUnits() == 0);
  //fail_unless( fd1_math->containsVariable("c") == false );
  //fail_unless( fd1_math->containsVariable("x") == true );

  ASTNode *child1 = fd1_math->getRightChild();
  fail_unless (child1->getType() == AST_CONSTANT_TRUE, NULL);
  fail_unless (child1->getNumChildren() == 0, NULL);

  math = SBML_formulaToString(child1);
  fail_unless (!strcmp(math, "true"), NULL);
  safe_free(math);

  //fail_unless( child1->containsVariable("c") == false );
  //fail_unless( child1->containsVariable("x") == false );

  //<initialAssignment symbol="p1">
  //  <math xmlns="http://www.w3.org/1998/Math/MathML">
  //    <apply/>
  //  </math>
  //</initialAssignment>
  ia = m->getInitialAssignment(0);
  const ASTNode *ia_math = ia->getMath();

  fail_unless (ia_math->getType() == AST_UNKNOWN, NULL);
  fail_unless (ia_math->getNumChildren() == 0, NULL);
  math = SBML_formulaToString(ia_math);
  fail_unless (!strcmp(math, ""), NULL);
  safe_free(math);
  fail_unless (ia_math->getParentSBMLObject() == ia, NULL);
  //fail_unless (ia_math->getNumVariablesWithUndeclaredUnits() == 0);
  //fail_unless( ia_math->containsVariable("c") == false );
  //fail_unless( ia_math->containsVariable("x") == false );

  //<algebraicRule>
  //  <math xmlns="http://www.w3.org/1998/Math/MathML">
  //    <true/>
  //  </math>
  //</algebraicRule>
  r = m->getRule(0);
  const ASTNode *r_math = r->getMath();

  fail_unless (r_math->getType() == AST_CONSTANT_TRUE, NULL);
  fail_unless (r_math->getNumChildren() == 0, NULL);
  math = SBML_formulaToString(r_math);
  fail_unless (!strcmp(math, "true"), NULL);
  safe_free(math);
  fail_unless (r_math->getParentSBMLObject() == r, NULL);
  //fail_unless (r_math->getNumVariablesWithUndeclaredUnits() == 0);
  //fail_unless( r_math->containsVariable("c") == false );
  //fail_unless( r_math->containsVariable("x") == false );

  //<assignmentRule variable="p2">
  //  <math xmlns="http://www.w3.org/1998/Math/MathML">
  //      <infinity/>
  //  </math>
  //</assignmentRule>
  r = m->getRule(1);
  const ASTNode *r1_math = r->getMath();

  fail_unless (r1_math->getType() == AST_REAL, NULL);
  fail_unless (r1_math->getNumChildren() == 0, NULL);
  math = SBML_formulaToString(r1_math);
  fail_unless (!strcmp(math, "INF"), NULL);
  safe_free(math);
  fail_unless (r1_math->getParentSBMLObject() == r, NULL);
  //fail_unless (r1_math->getNumVariablesWithUndeclaredUnits() == 0);
  //fail_unless( r1_math->containsVariable("c") == false );
  //fail_unless( r1_math->containsVariable("x") == false );

  //<kineticLaw>
  //  <math xmlns="http://www.w3.org/1998/Math/MathML">
  //    <apply>
  //      <cn> 4.5 </cn>
  //    </apply>
  //  </math>
  //  <listOfParameters>
  //    <parameter id="k" value="9" units="litre"/>
  //  </listOfParameters>
  //</kineticLaw>
  kl = m->getReaction(0)->getKineticLaw();
  const ASTNode *kl_math = kl->getMath();

  fail_unless (kl_math->getType() == AST_REAL, NULL);
  fail_unless (kl_math->getNumChildren() == 0, NULL);
  math = SBML_formulaToString(kl_math);
  fail_unless (!strcmp(math, "4.5"), NULL);
  safe_free(math);
  fail_unless (kl_math->getParentSBMLObject() == kl, NULL);
  //fail_unless (kl_math->getNumVariablesWithUndeclaredUnits() == 0);
  //fail_unless( kl_math->containsVariable("c") == false );
  //fail_unless( kl_math->containsVariable("x") == false );

  delete d;
}
END_TEST


Suite *
create_suite_TestReadFromFile1 (void)
{ 
  Suite *suite = suite_create("test-data/mathML_1.xml");
  TCase *tcase = tcase_create("test-data/mathML_1.xml");


  tcase_add_test(tcase, test_read_MathML_1);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

