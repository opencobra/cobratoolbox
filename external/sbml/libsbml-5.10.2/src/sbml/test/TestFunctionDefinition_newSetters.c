/**
 * \file    TestFunctionDefinition_newSetters.c
 * \brief   FunctionDefinition unit tests for new set function API
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

#include <sbml/SBase.h>
#include <sbml/FunctionDefinition.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>




#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static FunctionDefinition_t *E;


void
FunctionDefinitionTest1_setup (void)
{
  E = FunctionDefinition_create(2, 4);

  if (E == NULL)
  {
    fail("FunctionDefinition_create() returned a NULL pointer.");
  }
}


void
FunctionDefinitionTest1_teardown (void)
{
  FunctionDefinition_free(E);
}


START_TEST (test_FunctionDefinition_setId1)
{
  const char *id = "1e1";
  int i = FunctionDefinition_setId(E, id);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !FunctionDefinition_isSetId(E) );
}
END_TEST


START_TEST (test_FunctionDefinition_setId2)
{
  const char *id = "e1";
  int i = FunctionDefinition_setId(E, id);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !strcmp(FunctionDefinition_getId(E), id) );
  fail_unless( FunctionDefinition_isSetId(E) );

  i = FunctionDefinition_setId(E, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !FunctionDefinition_isSetId(E) );
}
END_TEST


START_TEST (test_FunctionDefinition_setName1)
{
  const char *name = "3Set_k2";

  int i = FunctionDefinition_setName(E, name);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( FunctionDefinition_isSetName(E) );
}
END_TEST


START_TEST (test_FunctionDefinition_setName2)
{
  const char *name = "Set k2";

  int i = FunctionDefinition_setName(E, name);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !strcmp(FunctionDefinition_getName(E), name) );
  fail_unless( FunctionDefinition_isSetName(E) );

  i = FunctionDefinition_unsetName(E);


  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !FunctionDefinition_isSetName(E) );
}
END_TEST


START_TEST (test_FunctionDefinition_setName3)
{
  int i = FunctionDefinition_setName(E, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !FunctionDefinition_isSetName(E) );
}
END_TEST


START_TEST (test_FunctionDefinition_setMath1)
{
  ASTNode_t *math = SBML_parseFormula("2 * k");

  int i = FunctionDefinition_setMath(E, math);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( FunctionDefinition_getMath(E) != math );
  fail_unless( FunctionDefinition_isSetMath(E) );

  i = FunctionDefinition_setMath(E, NULL);
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( FunctionDefinition_getMath(E) == NULL );
  fail_unless( !FunctionDefinition_isSetMath(E) );

  ASTNode_free(math);
}
END_TEST


START_TEST (test_FunctionDefinition_setMath2)
{
  ASTNode_t *math = ASTNode_createWithType(AST_DIVIDE);

  int i = FunctionDefinition_setMath(E, math);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( !FunctionDefinition_isSetMath(E) );

  ASTNode_free(math);
}
END_TEST


Suite *
create_suite_FunctionDefinition_newSetters (void)
{
  Suite *suite = suite_create("FunctionDefinition_newSetters");
  TCase *tcase = tcase_create("FunctionDefinition_newSetters");


  tcase_add_checked_fixture( tcase,
                             FunctionDefinitionTest1_setup,
                             FunctionDefinitionTest1_teardown );

  tcase_add_test( tcase, test_FunctionDefinition_setId1        );
  tcase_add_test( tcase, test_FunctionDefinition_setId2        );
  tcase_add_test( tcase, test_FunctionDefinition_setName1      );
  tcase_add_test( tcase, test_FunctionDefinition_setName2      );
  tcase_add_test( tcase, test_FunctionDefinition_setName3      );
  tcase_add_test( tcase, test_FunctionDefinition_setMath1      );
  tcase_add_test( tcase, test_FunctionDefinition_setMath2      );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


