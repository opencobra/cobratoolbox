/**
 * \file    TestL3KineticLaw.c
 * \brief   L3 KineticLaw unit tests
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

#include <sbml/SBase.h>
#include <sbml/KineticLaw.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static KineticLaw_t *KL;


void
L3KineticLawTest_setup (void)
{
  KL = KineticLaw_create(3, 1);

  if (KL == NULL)
  {
    fail("KineticLaw_create(3, 1) returned a NULL pointer.");
  }
}


void
L3KineticLawTest_teardown (void)
{
  KineticLaw_free(KL);
}


START_TEST (test_L3_KineticLaw_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) KL) == SBML_KINETIC_LAW );
  fail_unless( SBase_getMetaId    ((SBase_t *) KL) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) KL) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) KL) == NULL );

  fail_unless( KineticLaw_getNumParameters(KL) == 0);
  fail_unless( KineticLaw_getNumLocalParameters(KL) == 0);
}
END_TEST


START_TEST (test_L3_KineticLaw_free_NULL)
{
  KineticLaw_free(NULL);
}
END_TEST


START_TEST (test_L3_KineticLaw_addParameter1)
{
  KineticLaw_t *kl = KineticLaw_create(3, 1);
  Parameter_t *p 
    = Parameter_create(3, 1);

  int i = KineticLaw_addParameter(KL, p);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  Parameter_setId(p, "p");
  i = KineticLaw_addParameter(KL, p);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( KineticLaw_getNumParameters(KL) == 1);
  fail_unless( KineticLaw_getNumLocalParameters(KL) == 1);
  fail_unless( KineticLaw_getNumParameters(kl) == 0);
  fail_unless( KineticLaw_getNumLocalParameters(kl) == 0);

  i = KineticLaw_addParameter(kl, p);
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( KineticLaw_getNumParameters(KL) == 1);
  fail_unless( KineticLaw_getNumLocalParameters(KL) == 1);
  fail_unless( KineticLaw_getNumParameters(kl) == 1);
  fail_unless( KineticLaw_getNumLocalParameters(kl) == 1);


  Parameter_free(p);
  KineticLaw_free(kl);
}
END_TEST


START_TEST (test_L3_KineticLaw_addParameter2)
{
  KineticLaw_t *kl = KineticLaw_create(3, 1);
  LocalParameter_t *lp 
    = LocalParameter_create(3, 1);
  LocalParameter_t *lp1 
    = LocalParameter_create(3, 1);

  int i = KineticLaw_addLocalParameter(kl, lp);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
    
  LocalParameter_setId(lp, "p");
  LocalParameter_setId(lp1, "p1");
  i = KineticLaw_addLocalParameter(kl, lp);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( KineticLaw_getNumParameters(kl) == 1);
  fail_unless( KineticLaw_getNumLocalParameters(kl) == 1);

  i = KineticLaw_addParameter(kl, (Parameter_t *)lp1);
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( KineticLaw_getNumParameters(kl) == 2);
  fail_unless( KineticLaw_getNumLocalParameters(kl) == 2);


  LocalParameter_free(lp);
  KineticLaw_free(kl);
}
END_TEST


Suite *
create_suite_L3_KineticLaw (void)
{
  Suite *suite = suite_create("L3_KineticLaw");
  TCase *tcase = tcase_create("L3_KineticLaw");


  tcase_add_checked_fixture( tcase,
                             L3KineticLawTest_setup,
                             L3KineticLawTest_teardown );

  tcase_add_test( tcase, test_L3_KineticLaw_create              );
  tcase_add_test( tcase, test_L3_KineticLaw_free_NULL           );
  tcase_add_test( tcase, test_L3_KineticLaw_addParameter1               );
  tcase_add_test( tcase, test_L3_KineticLaw_addParameter2             );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


