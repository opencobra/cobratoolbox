/**
 * \file    TestParameter.c
 * \brief   Parameter unit tests
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

#include <sbml/SBase.h>
#include <sbml/Parameter.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Parameter_t *P;


void
ParameterTest_setup (void)
{
  P = Parameter_create(2, 4);

  if (P == NULL)
  {
    fail("Parameter_create() returned a NULL pointer.");
  }
}


void
ParameterTest_teardown (void)
{
  Parameter_free(P);
}

START_TEST (test_Parameter_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) P) == SBML_PARAMETER );
  fail_unless( SBase_getMetaId    ((SBase_t *) P) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) P) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) P) == NULL );

  fail_unless( Parameter_getId      (P) == NULL );
  fail_unless( Parameter_getName    (P) == NULL );
  fail_unless( Parameter_getUnits   (P) == NULL );
  fail_unless( Parameter_getConstant(P) == 1    );

  fail_unless( !Parameter_isSetId   (P) );
  fail_unless( !Parameter_isSetName (P) );
  fail_unless( !Parameter_isSetValue(P) );
  fail_unless( !Parameter_isSetUnits(P) );
  fail_unless( Parameter_isSetConstant(P) );
}
END_TEST


//START_TEST (test_Parameter_createWith)
//{
//  Parameter_t *p = Parameter_createWithValueAndUnits("delay", 6.2, "second");
//
//
//  fail_unless( SBase_getTypeCode  ((SBase_t *) p) == SBML_PARAMETER );
//  fail_unless( SBase_getMetaId    ((SBase_t *) p) == NULL );
//  fail_unless( SBase_getNotes     ((SBase_t *) p) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) p) == NULL );
//
//  fail_unless( !strcmp(Parameter_getId   (p), "delay" ) );
//  fail_unless( !strcmp(Parameter_getUnits(p), "second") );
//
//  fail_unless( Parameter_getName    (p) == NULL );
//  fail_unless( Parameter_getValue   (p) == 6.2 );
//  fail_unless( Parameter_getConstant(p) == 1   );
//
//  fail_unless(   Parameter_isSetId   (p) );
//  fail_unless( ! Parameter_isSetName (p) );
//  fail_unless(   Parameter_isSetValue(p) );
//  fail_unless(   Parameter_isSetUnits(p) );
//
//  Parameter_free(p);
//}
//END_TEST


START_TEST (test_Parameter_free_NULL)
{
  Parameter_free(NULL);
}
END_TEST


START_TEST (test_Parameter_setId)
{
  const char *id = "Km1";


  Parameter_setId(P, id);

  fail_unless( !strcmp(Parameter_getId(P), id) );
  fail_unless( Parameter_isSetId(P) );

  if (Parameter_getId(P) == id)
  {
    fail("Parameter_setId(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Parameter_setId(P, Parameter_getId(P));
  fail_unless( !strcmp(Parameter_getId(P), id) );

  Parameter_setId(P, NULL);
  fail_unless( !Parameter_isSetId(P) );

  if (Parameter_getId(P) != NULL)
  {
    fail("Parameter_setId(P, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Parameter_setName)
{
  const char *name = "Forward_Michaelis_Menten_Constant";


  Parameter_setName(P, name);

  fail_unless( !strcmp(Parameter_getName(P), name) );
  fail_unless( Parameter_isSetName(P) );

  if (Parameter_getName(P) == name)
  {
    fail("Parameter_setName(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Parameter_setName(P, Parameter_getName(P));
  fail_unless( !strcmp(Parameter_getName(P), name) );

  Parameter_setName(P, NULL);
  fail_unless( !Parameter_isSetName(P) );

  if (Parameter_getName(P) != NULL)
  {
    fail("Parameter_setName(P, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Parameter_setUnits)
{
  const char *units = "second";


  Parameter_setUnits(P, units);

  fail_unless( !strcmp(Parameter_getUnits(P), units) );
  fail_unless( Parameter_isSetUnits(P)  );

  if (Parameter_getUnits(P) == units)
  {
    fail("Parameter_setUnits(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Parameter_setUnits(P, Parameter_getUnits(P));
  fail_unless( !strcmp(Parameter_getUnits(P), units) );

  Parameter_setUnits(P, NULL);
  fail_unless( !Parameter_isSetUnits(P) );

  if (Parameter_getUnits(P) != NULL)
  {
    fail("Parameter_setUnits(P, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Parameter_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  Parameter_t *object = 
    Parameter_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_PARAMETER );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 1 );

  fail_unless( Parameter_getNamespaces     (object) != NULL );
  fail_unless( XMLNamespaces_getLength(
                        Parameter_getNamespaces(object)) == 2 );

  Parameter_free(object);
}
END_TEST


Suite *
create_suite_Parameter (void)
{
  Suite *suite = suite_create("Parameter");
  TCase *tcase = tcase_create("Parameter");


  tcase_add_checked_fixture( tcase,
                             ParameterTest_setup,
                             ParameterTest_teardown );

  tcase_add_test( tcase, test_Parameter_create     );
  ////tcase_add_test( tcase, test_Parameter_createWith );
  tcase_add_test( tcase, test_Parameter_free_NULL  );
  tcase_add_test( tcase, test_Parameter_setId      );
  tcase_add_test( tcase, test_Parameter_setName    );
  tcase_add_test( tcase, test_Parameter_setUnits   );
  tcase_add_test( tcase, test_Parameter_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


