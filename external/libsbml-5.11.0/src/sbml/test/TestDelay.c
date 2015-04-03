/**
 * \file    TestDelay.c
 * \brief   SBML Delay unit tests
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
#include <sbml/Delay.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Delay_t *D;


void
DelayTest_setup (void)
{
  D = Delay_create(2, 4);

  if (D == NULL)
  {
    fail("Delay_create() returned a NULL pointer.");
  }
}


void
DelayTest_teardown (void)
{
  Delay_free(D);
}


START_TEST (test_Delay_create)
{
  fail_unless( SBase_getTypeCode((SBase_t *) D) == SBML_DELAY );
  fail_unless( SBase_getMetaId    ((SBase_t *) D) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) D) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) D) == NULL );

  fail_unless( Delay_getMath(D) == NULL );
}
END_TEST


//START_TEST (test_Delay_createWithMath)
//{
//  ASTNode_t            *math = SBML_parseFormula("x^3");
//  Delay_t *fd   = Delay_createWithMath(math);
//
//  const ASTNode_t * math1;
//  char * formula;
//
//  fail_unless( SBase_getTypeCode((SBase_t *) fd) == SBML_DELAY );
//  fail_unless( SBase_getMetaId    ((SBase_t *) fd) == NULL );
//  fail_unless( SBase_getNotes     ((SBase_t *) fd) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) fd) == NULL );
//
//
//  math1 = Delay_getMath(fd);
//  fail_unless( math1 != NULL );
//
//  formula = SBML_formulaToString(math1);
//  fail_unless( formula != NULL );
//  fail_unless( !strcmp(formula, "x^3") );
//  fail_unless( Delay_getMath(fd) != math );
//  fail_unless( Delay_isSetMath(fd) );
//
//
//  Delay_free(fd);
//}
//END_TEST


START_TEST (test_Delay_free_NULL)
{
  Delay_free(NULL);
}
END_TEST


START_TEST (test_Delay_setMath)
{
  ASTNode_t *math = SBML_parseFormula("lambda(x, x^3)");

  const ASTNode_t * math1;
  char * formula;

  Delay_setMath(D, math);

  math1 = Delay_getMath(D);
  fail_unless( math1 != NULL );

  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "lambda(x, x^3)") );
  fail_unless( Delay_getMath(D) != math );
  fail_unless( Delay_isSetMath(D) );

  /* Reflexive case (pathological) */
  Delay_setMath(D, (ASTNode_t *) Delay_getMath(D));
  math1 = Delay_getMath(D);
  fail_unless( math1 != NULL );

  safe_free(formula);
  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "lambda(x, x^3)") );
  safe_free(formula);

  Delay_setMath(D, NULL);
  fail_unless( !Delay_isSetMath(D) );

  if (Delay_getMath(D) != NULL)
  {
    fail("Delay_setMath(D, NULL) did not clear ASTNode.");
  }
  ASTNode_free(math);
}
END_TEST


START_TEST (test_Delay_setMath1)
{
  ASTNode_t *math = SBML_parseFormula("2 * k");

  int i = Delay_setMath(D, math);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Delay_getMath(D) != math );
  fail_unless( Delay_isSetMath(D) );

  i = Delay_setMath(D, NULL);
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Delay_getMath(D) == NULL );
  fail_unless( !Delay_isSetMath(D) );

  ASTNode_free(math);
}
END_TEST


START_TEST (test_Delay_setMath2)
{
  ASTNode_t *math = ASTNode_createWithType(AST_DIVIDE);

  int i = Delay_setMath(D, math);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( !Delay_isSetMath(D) );

  ASTNode_free(math);
}
END_TEST


START_TEST (test_Delay_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  Delay_t *object = 
    Delay_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_DELAY );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 1 );

  fail_unless( Delay_getNamespaces     (object) != NULL );
  fail_unless( XMLNamespaces_getLength(Delay_getNamespaces(object)) == 2 );

  Delay_free(object);
  XMLNamespaces_free(xmlns);
  SBMLNamespaces_free(sbmlns);
}
END_TEST


Suite *
create_suite_Delay (void)
{
  Suite *suite = suite_create("Delay");
  TCase *tcase = tcase_create("Delay");


  tcase_add_checked_fixture( tcase,
                             DelayTest_setup,
                             DelayTest_teardown );

  tcase_add_test( tcase, test_Delay_create       );
  //tcase_add_test( tcase, test_Delay_createWithMath   );
  tcase_add_test( tcase, test_Delay_setMath      );
  tcase_add_test( tcase, test_Delay_setMath1     );
  tcase_add_test( tcase, test_Delay_setMath2     );
  tcase_add_test( tcase, test_Delay_free_NULL );
  tcase_add_test( tcase, test_Delay_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


