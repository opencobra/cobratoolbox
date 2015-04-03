/**
 * \file    TestPriority.c
 * \brief   SBML Priority unit tests
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
#include <sbml/math/FormulaParser.h>
#include <sbml/math/FormulaFormatter.h>

#include <sbml/SBase.h>
#include <sbml/Priority.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>

#ifdef __cplusplus
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

static Priority_t *P;


void
PriorityTest_setup (void)
{
  P = Priority_create(3, 1);

  if (P == NULL)
  {
    fail("Priority_create() returned a NULL pointer.");
  }
}


void
PriorityTest_teardown (void)
{
  Priority_free(P);
}


START_TEST (test_Priority_create)
{
  fail_unless( SBase_getTypeCode((SBase_t *) P) == SBML_PRIORITY );
  fail_unless( SBase_getMetaId    ((SBase_t *) P) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) P) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) P) == NULL );

  fail_unless( Priority_getMath(P) == NULL );
}
END_TEST


START_TEST (test_Priority_free_NULL)
{
  Priority_free(NULL);
}
END_TEST


START_TEST (test_Priority_setMath)
{
  ASTNode_t *math = SBML_parseFormula("lambda(x, x^3)");

  const ASTNode_t * math1;
  char * formula;

  Priority_setMath(P, math);

  math1 = Priority_getMath(P);
  fail_unless( math1 != NULL );

  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "lambda(x, x^3)") );
  fail_unless( Priority_getMath(P) != math );
  fail_unless( Priority_isSetMath(P) );
  safe_free(formula);

  /* Reflexive case (pathological) */
  Priority_setMath(P, (ASTNode_t *) Priority_getMath(P));
  math1 = Priority_getMath(P);
  fail_unless( math1 != NULL );

  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "lambda(x, x^3)") );
  safe_free(formula);

  Priority_setMath(P, NULL);
  fail_unless( !Priority_isSetMath(P) );

  if (Priority_getMath(P) != NULL)
  {
    fail("Priority_setMath(P, NULL) did not clear ASTNode.");
  }
  ASTNode_free(math);
}
END_TEST


START_TEST (test_Priority_setMath1)
{
  ASTNode_t *math = SBML_parseFormula("2 * k");

  int i = Priority_setMath(P, math);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Priority_getMath(P) != math );
  fail_unless( Priority_isSetMath(P) );

  i = Priority_setMath(P, NULL);
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Priority_getMath(P) == NULL );
  fail_unless( !Priority_isSetMath(P) );

  ASTNode_free(math);
}
END_TEST


START_TEST (test_Priority_setMath2)
{
  ASTNode_t *math = ASTNode_createWithType(AST_DIVIDE);

  int i = Priority_setMath(P, math);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( !Priority_isSetMath(P) );

  ASTNode_free(math);
}
END_TEST


START_TEST (test_Priority_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(3,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  Priority_t *object = 
    Priority_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_PRIORITY );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 3 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 1 );

  fail_unless( Priority_getNamespaces     (object) != NULL );
  fail_unless( XMLNamespaces_getLength(Priority_getNamespaces(object)) == 2 );

  Priority_free(object);
  XMLNamespaces_free(xmlns);
  SBMLNamespaces_free(sbmlns);
}
END_TEST


Suite *
create_suite_Priority (void)
{
  Suite *suite = suite_create("Priority");
  TCase *tcase = tcase_create("Priority");


  tcase_add_checked_fixture( tcase,
                             PriorityTest_setup,
                             PriorityTest_teardown );

  tcase_add_test( tcase, test_Priority_create       );
  tcase_add_test( tcase, test_Priority_setMath      );
  tcase_add_test( tcase, test_Priority_setMath1     );
  tcase_add_test( tcase, test_Priority_setMath2     );
  tcase_add_test( tcase, test_Priority_free_NULL );
  tcase_add_test( tcase, test_Priority_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

#ifdef __cplusplus
CK_CPPEND
#endif
