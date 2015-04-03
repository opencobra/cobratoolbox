/**
 * \file    TestConstraint_newSetters.c
 * \brief   Constraint unit tests for new set function API
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
#include <sbml/Constraint.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLTriple.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Constraint_t *C;


void
ConstraintTest1_setup (void)
{
  C = Constraint_create(2, 4);

  if (C == NULL)
  {
    fail("Constraint_create() returned a NULL pointer.");
  }
}


void
ConstraintTest1_teardown (void)
{
  Constraint_free(C);
}


START_TEST (test_Constraint_setMath1)
{
  ASTNode_t *math = SBML_parseFormula("2 * k");

  int i = Constraint_setMath(C, math);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Constraint_getMath(C) != math );
  fail_unless( Constraint_isSetMath(C) );

  i = Constraint_setMath(C, NULL);
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Constraint_getMath(C) == NULL );
  fail_unless( !Constraint_isSetMath(C) );

  ASTNode_free(math);
}
END_TEST


START_TEST (test_Constraint_setMath2)
{
  ASTNode_t *math = ASTNode_createWithType(AST_DIVIDE);

  int i = Constraint_setMath(C, math);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  fail_unless( !Constraint_isSetMath(C) );

  ASTNode_free(math);
}
END_TEST


START_TEST (test_Constraint_setMessage1)
{
  XMLNode_t *node = XMLNode_create();

  int i = Constraint_setMessage(C, node);

  fail_unless(i == LIBSBML_INVALID_OBJECT);
  fail_unless( Constraint_isSetMessage(C) == 0);

  i = Constraint_unsetMessage(C);
  
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !Constraint_isSetMessage(C) );

  if (Constraint_getMessage(C) != NULL)
  {
    fail("Constraint_unsetMessage(C) did not clear XMLNode.");
  }

  XMLNode_free(node);
}
END_TEST


START_TEST (test_Constraint_setMessage2)
{
  //const char * expected = (
  //  "<message>\n"
  //  "  <p xmlns=\"http://www.w3.org/1999/xhtml\"> Some text </p>\n"
  //  "</message>");

  XMLNode_t *text = XMLNode_convertStringToXMLNode(" Some text ", NULL);
  XMLTriple_t *triple = XMLTriple_createWith("p", "http://www.w3.org/1999/xhtml", "");
  XMLAttributes_t *att = XMLAttributes_create();
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.w3.org/1999/xhtml", "");
  
  XMLNode_t *p = XMLNode_createStartElementNS(triple, att, xmlns);
  XMLNode_addChild(p, text);
  
  XMLTriple_t *triple1 = XMLTriple_createWith("message", "", "");
  XMLAttributes_t *att1 = XMLAttributes_create();
  XMLNode_t *node = XMLNode_createStartElement(triple1, att1);

  XMLNode_addChild(node, p);

  int i = Constraint_setMessage(C, node);

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Constraint_isSetMessage(C) == 1);
  /* FIX ME
  printf("Expected: %s\n", expected);
  printf("String  : %s\n", Constraint_getMessage(C));
  fail_unless( strcmp(Constraint_getMessageString(C),
    expected) == 0);
  */
  i = Constraint_unsetMessage(C);
  
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( !Constraint_isSetMessage(C) );

  if (Constraint_getMessage(C) != NULL)
  {
    fail("Constraint_unsetMessage(C) did not clear XMLNode.");
  }

  XMLNode_free(text);
  XMLTriple_free(triple);
  XMLAttributes_free(att);
  XMLNamespaces_free(xmlns);
  XMLNode_free(p);
  XMLTriple_free(triple1);
  XMLAttributes_free(att1);
  XMLNode_free(node);
}
END_TEST


Suite *
create_suite_Constraint_newSetters (void)
{
  Suite *suite = suite_create("Constraint_newSetters");
  TCase *tcase = tcase_create("Constraint_newSetters");


  tcase_add_checked_fixture( tcase,
                             ConstraintTest1_setup,
                             ConstraintTest1_teardown );

  tcase_add_test( tcase, test_Constraint_setMath1     );
  tcase_add_test( tcase, test_Constraint_setMath2     );
  tcase_add_test( tcase, test_Constraint_setMessage1  );
  tcase_add_test( tcase, test_Constraint_setMessage2  );


  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


