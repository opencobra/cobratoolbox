/**
 * \file    TestFunctionDefinition.c
 * \brief   SBML FunctionDefinition unit tests
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
#include <sbml/math/FormulaParser.h>
#include <sbml/math/FormulaFormatter.h>

#include <sbml/SBase.h>
#include <sbml/FunctionDefinition.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static FunctionDefinition_t *FD;


void
FunctionDefinitionTest_setup (void)
{
  FD = FunctionDefinition_create(2, 4);

  if (FD == NULL)
  {
    fail("FunctionDefinition_create() returned a NULL pointer.");
  }
}


void
FunctionDefinitionTest_teardown (void)
{
  FunctionDefinition_free(FD);
}


START_TEST (test_FunctionDefinition_create)
{
  fail_unless( SBase_getTypeCode((SBase_t *) FD) == SBML_FUNCTION_DEFINITION );
  fail_unless( SBase_getMetaId    ((SBase_t *) FD) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) FD) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) FD) == NULL );

  fail_unless( FunctionDefinition_getId  (FD) == NULL );
  fail_unless( FunctionDefinition_getName(FD) == NULL );
  fail_unless( FunctionDefinition_getMath(FD) == NULL );
}
END_TEST


START_TEST (test_FunctionDefinition_createWith)
{
  ASTNode_t            *math = SBML_parseFormula("lambda(x, x^3)");
  FunctionDefinition_t *fd   = 
    FunctionDefinition_create(2, 4);
  FunctionDefinition_setId(fd, "pow3");
  FunctionDefinition_setMath(fd, math);

  const ASTNode_t * math1;
  char * formula;

  fail_unless( SBase_getTypeCode((SBase_t *) fd) == SBML_FUNCTION_DEFINITION );
  fail_unless( SBase_getMetaId    ((SBase_t *) fd) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) fd) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) fd) == NULL );

  fail_unless( FunctionDefinition_getName(fd) == NULL );

  math1 = FunctionDefinition_getMath(fd);
  fail_unless( math1 != NULL );

  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "lambda(x, x^3)") );
  fail_unless( FunctionDefinition_getMath(fd) != math );
  fail_unless( FunctionDefinition_isSetMath(fd) );

  fail_unless( !strcmp(FunctionDefinition_getId(fd), "pow3") );
  fail_unless( FunctionDefinition_isSetId(fd) );

  ASTNode_free(math);
  safe_free(formula);
  FunctionDefinition_free(fd);
}
END_TEST


START_TEST (test_FunctionDefinition_free_NULL)
{
  FunctionDefinition_free(NULL);
}
END_TEST


START_TEST (test_FunctionDefinition_getArguments)
{
  const ASTNode_t *math; 

  ASTNode_t* math1 = SBML_parseFormula("lambda(x, y, x^y)");
  FunctionDefinition_setMath(FD, math1 );
  ASTNode_free(math1);

  fail_unless( FunctionDefinition_getNumArguments(FD) == 2 );


  math = FunctionDefinition_getArgument(FD, 0);

  fail_unless( math != NULL                        );
  fail_unless( ASTNode_isName(math)                );
  fail_unless( !strcmp(ASTNode_getName(math), "x") );
  fail_unless( ASTNode_getNumChildren(math) == 0   );

  math = FunctionDefinition_getArgument(FD, 1);

  fail_unless( math != NULL                        );
  fail_unless( ASTNode_isName(math)                );
  fail_unless( !strcmp(ASTNode_getName(math), "y") );
  fail_unless( ASTNode_getNumChildren(math) == 0   );

  fail_unless( FunctionDefinition_getArgument(FD, 0) ==
               FunctionDefinition_getArgumentByName(FD, "x") );

  fail_unless( FunctionDefinition_getArgument(FD, 1) ==
               FunctionDefinition_getArgumentByName(FD, "y") );
}
END_TEST


START_TEST (test_FunctionDefinition_getBody)
{
  const ASTNode_t *math;

  ASTNode_t * math1 = SBML_parseFormula("lambda(x, x)");

  FunctionDefinition_setMath(FD, math1 );
  math = FunctionDefinition_getBody(FD);

  fail_unless( math != NULL                        );
  fail_unless( ASTNode_isName(math)                );
  fail_unless( !strcmp(ASTNode_getName(math), "x") );
  fail_unless( ASTNode_getNumChildren(math) == 0   );

  ASTNode_free(math1);
}
END_TEST


START_TEST (test_FunctionDefinition_setId)
{
  const char *id = "pow3";


  FunctionDefinition_setId(FD, id);

  fail_unless( !strcmp(FunctionDefinition_getId(FD), id) );
  fail_unless( FunctionDefinition_isSetId(FD) );

  if (FunctionDefinition_getId(FD) == id)
  {
    fail("FunctionDefinition_setId(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  FunctionDefinition_setId(FD, FunctionDefinition_getId(FD));
  fail_unless( !strcmp(FunctionDefinition_getId(FD), id) );

  FunctionDefinition_setId(FD, NULL);
  fail_unless( !FunctionDefinition_isSetId(FD) );

  if (FunctionDefinition_getId(FD) != NULL)
  {
    fail("FunctionDefinition_setId(FD, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_FunctionDefinition_setName)
{
  const char *name = "Cube_Me";


  FunctionDefinition_setName(FD, name);

  fail_unless( !strcmp(FunctionDefinition_getName(FD), name) );
  fail_unless( FunctionDefinition_isSetName(FD) );

  if (FunctionDefinition_getName(FD) == name)
  {
    fail("FunctionDefinition_setName(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  FunctionDefinition_setName(FD, FunctionDefinition_getName(FD));
  fail_unless( !strcmp(FunctionDefinition_getName(FD), name) );

  FunctionDefinition_setName(FD, NULL);
  fail_unless( !FunctionDefinition_isSetName(FD) );

  if (FunctionDefinition_getName(FD) != NULL)
  {
    fail("FunctionDefinition_setName(FD, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_FunctionDefinition_setMath)
{
  ASTNode_t *math = SBML_parseFormula("lambda(x, x^3)");

  const ASTNode_t * math1;
  char * formula;

  FunctionDefinition_setMath(FD, math);

  math1 = FunctionDefinition_getMath(FD);
  fail_unless( math1 != NULL );

  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "lambda(x, x^3)") );
  fail_unless( FunctionDefinition_getMath(FD) != math );
  fail_unless( FunctionDefinition_isSetMath(FD) );
  fail_unless( FunctionDefinition_isSetBody(FD) );

  /* Reflexive case (pathological) */
  FunctionDefinition_setMath(FD, (ASTNode_t *) FunctionDefinition_getMath(FD));
  math1 = FunctionDefinition_getMath(FD);
  fail_unless( math1 != NULL );

  safe_free(formula);
  formula = SBML_formulaToString(math1);
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "lambda(x, x^3)") );
  fail_unless( FunctionDefinition_getMath(FD) != math );

  FunctionDefinition_setMath(FD, NULL);
  fail_unless( !FunctionDefinition_isSetMath(FD) );
  fail_unless( !FunctionDefinition_isSetBody(FD) );

  if (FunctionDefinition_getMath(FD) != NULL)
  {
    fail("FunctionDefinition_setMath(FD, NULL) did not clear ASTNode.");
  }

  ASTNode_free(math);
  safe_free(formula);
}
END_TEST


START_TEST (test_FunctionDefinition_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  FunctionDefinition_t *object = 
    FunctionDefinition_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_FUNCTION_DEFINITION );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 1 );

  fail_unless( FunctionDefinition_getNamespaces     (object) != NULL );
  fail_unless( XMLNamespaces_getLength(
                       FunctionDefinition_getNamespaces(object)) == 2 );

  FunctionDefinition_free(object);
  XMLNamespaces_free(xmlns);
  SBMLNamespaces_free(sbmlns);
}
END_TEST


Suite *
create_suite_FunctionDefinition (void)
{
  Suite *suite = suite_create("FunctionDefinition");
  TCase *tcase = tcase_create("FunctionDefinition");


  tcase_add_checked_fixture( tcase,
                             FunctionDefinitionTest_setup,
                             FunctionDefinitionTest_teardown );

  tcase_add_test( tcase, test_FunctionDefinition_create       );
  tcase_add_test( tcase, test_FunctionDefinition_createWith   );
  tcase_add_test( tcase, test_FunctionDefinition_free_NULL    );
  tcase_add_test( tcase, test_FunctionDefinition_getArguments );
  tcase_add_test( tcase, test_FunctionDefinition_getBody      );
  tcase_add_test( tcase, test_FunctionDefinition_setId        );
  tcase_add_test( tcase, test_FunctionDefinition_setName      );
  tcase_add_test( tcase, test_FunctionDefinition_setMath      );
  tcase_add_test( tcase, test_FunctionDefinition_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


