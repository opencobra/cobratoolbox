/**
 * \file    TestModifierSpeciesReference.c
 * \brief   ModifierSpeciesReference unit tests
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

#include <sbml/SBase.h>
#include <sbml/SpeciesReference.h>
#include <sbml/ModifierSpeciesReference.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static ModifierSpeciesReference_t *MSR;


void
ModifierSpeciesReferenceTest_setup (void)
{
  MSR = ModifierSpeciesReference_create(2, 4);

  if (MSR == NULL)
  {
    fail( "ModifierSpeciesReference_create() returned a NULL pointer." );
  }
}


void
ModifierSpeciesReferenceTest_teardown (void)
{
  ModifierSpeciesReference_free(MSR);
}


START_TEST (test_ModifierSpeciesReference_create)
{
  fail_unless(SBase_getTypeCode((SBase_t *) MSR) ==
              SBML_MODIFIER_SPECIES_REFERENCE);

  fail_unless( SBase_getMetaId    ((SBase_t *) MSR) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) MSR) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) MSR) == NULL );

  fail_unless( ModifierSpeciesReference_getSpecies(MSR) == NULL );

  fail_unless( !ModifierSpeciesReference_isSetSpecies(MSR) );

  fail_unless( SpeciesReference_isModifier((SpeciesReference_t*)(MSR)) );
}
END_TEST


START_TEST (test_ModifierSpeciesReference_free_NULL)
{
  ModifierSpeciesReference_free(NULL);
}
END_TEST


START_TEST (test_ModifierSpeciesReference_setSpecies)
{
  const char *s;
  const char *species = "s1";



  ModifierSpeciesReference_setSpecies(MSR, species);

  s = ModifierSpeciesReference_getSpecies(MSR);
  fail_unless( !strcmp(s, species) );
  fail_unless(ModifierSpeciesReference_isSetSpecies(MSR));

  if (ModifierSpeciesReference_getSpecies(MSR) == species)
  {
    fail( "ModifierModifierSpeciesReference_setSpecies(...) "
          "did not make a copy of string." );
  }

  /* Reflexive case (pathological) */
  s = ModifierSpeciesReference_getSpecies(MSR);
  ModifierSpeciesReference_setSpecies(MSR, s);

  s = ModifierSpeciesReference_getSpecies(MSR);
  fail_unless( !strcmp(s, species) );

  ModifierSpeciesReference_setSpecies(MSR, NULL);
  fail_unless(!ModifierSpeciesReference_isSetSpecies(MSR));

  if (ModifierSpeciesReference_getSpecies(MSR) != NULL)
  {
    fail( "ModifierModifierSpeciesReference_setSpecies(MSR, NULL) "
          "did not clear string." );
  }
}
END_TEST


START_TEST (test_ModifierSpeciesReference_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  ModifierSpeciesReference_t *object = ModifierSpeciesReference_createWithNS(sbmlns);

  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_MODIFIER_SPECIES_REFERENCE );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 1 );

  fail_unless( SpeciesReference_getNamespaces ((SpeciesReference_t *) object) != NULL );
  const XMLNamespaces_t *n = SpeciesReference_getNamespaces((SpeciesReference_t *) object);
  fail_unless( XMLNamespaces_getLength( n ) == 2 );

  ModifierSpeciesReference_free(object);
  XMLNamespaces_free(xmlns);
  SBMLNamespaces_free(sbmlns);
}
END_TEST


Suite *
create_suite_ModifierSpeciesReference (void)
{
  Suite *suite = suite_create("ModifierSpeciesReference");
  TCase *tcase = tcase_create("ModifierSpeciesReference");


  tcase_add_checked_fixture( tcase,
                             ModifierSpeciesReferenceTest_setup,
                             ModifierSpeciesReferenceTest_teardown );

  tcase_add_test( tcase, test_ModifierSpeciesReference_create     );
  tcase_add_test( tcase, test_ModifierSpeciesReference_free_NULL  );
  tcase_add_test( tcase, test_ModifierSpeciesReference_setSpecies );
  tcase_add_test( tcase, test_ModifierSpeciesReference_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

