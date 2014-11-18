/**
 * \file    TestAlgebraicRule.c
 * \brief   AlgebraicRule unit tests
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

#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/FormulaParser.h>

#include <sbml/SBase.h>
#include <sbml/Rule.h>
#include <sbml/AlgebraicRule.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static AlgebraicRule_t *AR;


void
AlgebraicRuleTest_setup (void)
{
  AR = AlgebraicRule_create(2, 4);

  if (AR == NULL)
  {
    fail("AlgebraicRule_createAlgebraic() returned a NULL pointer.");
  }
}


void
AlgebraicRuleTest_teardown (void)
{
  Rule_free((Rule_t*)(AR));
}


START_TEST (test_AlgebraicRule_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) AR) == SBML_ALGEBRAIC_RULE );
  fail_unless( SBase_getMetaId    ((SBase_t *) AR) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) AR) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) AR) == NULL );

  fail_unless( Rule_getFormula((Rule_t *) AR) == NULL );
  fail_unless( AlgebraicRule_getMath   (AR) == NULL );
}
END_TEST


START_TEST (test_AlgebraicRule_createWithFormula)
{
  const ASTNode_t *math;
  char *formula;

  AlgebraicRule_t *ar = AlgebraicRule_create(2, 4);
  AlgebraicRule_setFormula(ar, "1 + 1");


  fail_unless( SBase_getTypeCode  ((SBase_t *) ar) == SBML_ALGEBRAIC_RULE );
  fail_unless( SBase_getMetaId    ((SBase_t *) ar) == NULL );

  math = AlgebraicRule_getMath(ar);
  fail_unless(math != NULL);

  formula = SBML_formulaToString(math);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "1 + 1") );

  fail_unless( !strcmp(AlgebraicRule_getFormula(ar), formula) );

  AlgebraicRule_free(ar);
  safe_free(formula);
}
END_TEST


START_TEST (test_AlgebraicRule_createWithMath)
{
  ASTNode_t       *math = SBML_parseFormula("1 + 1");
  AlgebraicRule_t *ar   = AlgebraicRule_create(2, 4);
  AlgebraicRule_setMath(ar, math);


  fail_unless( SBase_getTypeCode  ((SBase_t *) ar) == SBML_ALGEBRAIC_RULE );
  fail_unless( SBase_getMetaId    ((SBase_t *) ar) == NULL );

  fail_unless( !strcmp(AlgebraicRule_getFormula(ar), "1 + 1") );
  fail_unless( AlgebraicRule_getMath(ar) != math );

  AlgebraicRule_free(ar);
}
END_TEST


START_TEST (test_AlgebraicRule_free_NULL)
{
  AlgebraicRule_free(NULL);
}
END_TEST


START_TEST (test_AlgebraicRule_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,3);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  AlgebraicRule_t *r = 
    AlgebraicRule_createWithNS(sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) r) == SBML_ALGEBRAIC_RULE );
  fail_unless( SBase_getMetaId    ((SBase_t *) r) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) r) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) r) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) r) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) r) == 3 );

  fail_unless( Rule_getNamespaces     ((Rule_t*)(r)) != NULL );
  fail_unless( XMLNamespaces_getLength(Rule_getNamespaces((Rule_t*)(r))) == 2 );


  Rule_free((Rule_t*)(r));
}
END_TEST


Suite *
create_suite_AlgebraicRule (void)
{
  Suite *suite = suite_create("AlgebraicRule");
  TCase *tcase = tcase_create("AlgebraicRule");


  tcase_add_checked_fixture( tcase,
                             AlgebraicRuleTest_setup,
                             AlgebraicRuleTest_teardown );

  tcase_add_test( tcase, test_AlgebraicRule_create         );
  tcase_add_test( tcase, test_AlgebraicRule_createWithFormula     );
  tcase_add_test( tcase, test_AlgebraicRule_createWithMath );
  tcase_add_test( tcase, test_AlgebraicRule_free_NULL      );
  tcase_add_test( tcase, test_AlgebraicRule_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


