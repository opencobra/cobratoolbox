/**
 * \file    TestInitialAssignment.c
 * \brief   SBML InitialAssignment unit tests
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
#include <sbml/InitialAssignment.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static InitialAssignment_t *IA;


void
InitialAssignmentTest_setup (void)
{
  IA = InitialAssignment_create(2, 4);

  if (IA == NULL)
  {
    fail("InitialAssignment_create() returned a NULL pointer.");
  }
}


void
InitialAssignmentTest_teardown (void)
{
  InitialAssignment_free(IA);
}


START_TEST (test_InitialAssignment_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) IA) == SBML_INITIAL_ASSIGNMENT );
  fail_unless( SBase_getMetaId    ((SBase_t *) IA) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) IA) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) IA) == NULL );

  fail_unless( InitialAssignment_getSymbol(IA) == NULL );
  fail_unless( InitialAssignment_getMath    (IA) == NULL );
}
END_TEST


//START_TEST (test_InitialAssignment_createWith)
//{
//  InitialAssignment_t *ia   = InitialAssignment_createWithSymbol("k");
//
//  fail_unless( SBase_getTypeCode  ((SBase_t *) ia) == SBML_INITIAL_ASSIGNMENT );
//  fail_unless( SBase_getMetaId    ((SBase_t *) ia) == NULL );
//  fail_unless( SBase_getNotes     ((SBase_t *) ia) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) ia) == NULL );
//
//  fail_unless( !InitialAssignment_isSetMath(ia) );
//
//  fail_unless( !strcmp(InitialAssignment_getSymbol(ia), "k") );
//  fail_unless( InitialAssignment_isSetSymbol(ia) );
//
//  InitialAssignment_free(ia);
//}
//END_TEST


START_TEST (test_InitialAssignment_free_NULL)
{
  InitialAssignment_free(NULL);
}
END_TEST


START_TEST (test_InitialAssignment_setSymbol)
{
  const char *Symbol = "k2";


  InitialAssignment_setSymbol(IA, Symbol);

  fail_unless( !strcmp(InitialAssignment_getSymbol(IA), Symbol) );
  fail_unless( InitialAssignment_isSetSymbol(IA) );

  if (InitialAssignment_getSymbol(IA) == Symbol)
  {
    fail("InitialAssignment_setSymbol(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  InitialAssignment_setSymbol(IA, InitialAssignment_getSymbol(IA));
  fail_unless( !strcmp(InitialAssignment_getSymbol(IA), Symbol) );

  InitialAssignment_setSymbol(IA, NULL);
  fail_unless( !InitialAssignment_isSetSymbol(IA) );

  if (InitialAssignment_getSymbol(IA) != NULL)
  {
    fail("InitialAssignment_setSymbol(IA, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_InitialAssignment_setMath)
{
  ASTNode_t *math = SBML_parseFormula("2 * k");
  char *formula;
  const ASTNode_t *math1;

  InitialAssignment_setMath(IA, math);

  math1 = InitialAssignment_getMath(IA);
  fail_unless( math1 != NULL );

  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "2 * k") );
  fail_unless( InitialAssignment_getMath(IA) != math );
  fail_unless( InitialAssignment_isSetMath(IA) );

  /* Reflexive case (pathological) */
  InitialAssignment_setMath(IA, (ASTNode_t *) InitialAssignment_getMath(IA));

  math1 = InitialAssignment_getMath(IA);
  fail_unless( math1 != NULL );

  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "2 * k") );
  fail_unless( InitialAssignment_getMath(IA) != math );

  InitialAssignment_setMath(IA, NULL);
  fail_unless( !InitialAssignment_isSetMath(IA) );

  if (InitialAssignment_getMath(IA) != NULL)
  {
    fail("InitialAssignment_setMath(IA, NULL) did not clear ASTNode.");
  }

  ASTNode_free(math);
}
END_TEST


START_TEST (test_InitialAssignment_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,3);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  InitialAssignment_t *object = 
    InitialAssignment_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_INITIAL_ASSIGNMENT );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 3 );

  fail_unless( InitialAssignment_getNamespaces     (object) != NULL );
  fail_unless( XMLNamespaces_getLength(
                      InitialAssignment_getNamespaces(object)) == 2 );

  InitialAssignment_free(object);
}
END_TEST


Suite *
create_suite_InitialAssignment (void)
{
  Suite *suite = suite_create("InitialAssignment");
  TCase *tcase = tcase_create("InitialAssignment");


  tcase_add_checked_fixture( tcase,
                             InitialAssignmentTest_setup,
                             InitialAssignmentTest_teardown );

  tcase_add_test( tcase, test_InitialAssignment_create      );
  //tcase_add_test( tcase, test_InitialAssignment_createWith  );
  tcase_add_test( tcase, test_InitialAssignment_free_NULL   );
  tcase_add_test( tcase, test_InitialAssignment_setSymbol );
  tcase_add_test( tcase, test_InitialAssignment_setMath     );
  tcase_add_test( tcase, test_InitialAssignment_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

