/**
 * \file    TestL3SpeciesReference.c
 * \brief   L3 SpeciesReference unit tests
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
#include <sbml/SpeciesReference.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>

#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static SpeciesReference_t *SR;


void
L3SpeciesReferenceTest_setup (void)
{
  SR = SpeciesReference_create(3, 1);

  if (SR == NULL)
  {
    fail("SpeciesReference_create(3, 1) returned a NULL pointer.");
  }
}


void
L3SpeciesReferenceTest_teardown (void)
{
  SpeciesReference_free(SR);
}


START_TEST (test_L3_SpeciesReference_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) SR) == SBML_SPECIES_REFERENCE );
  fail_unless( SBase_getMetaId    ((SBase_t *) SR) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) SR) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) SR) == NULL );

  fail_unless( SpeciesReference_getId     (SR) == NULL );
  fail_unless( SpeciesReference_getName   (SR) == NULL );
  fail_unless( SpeciesReference_getSpecies  (SR) == NULL );
  fail_unless( util_isNaN(SpeciesReference_getStoichiometry (SR)) );
  fail_unless( SpeciesReference_getConstant(SR) == 0   );

  fail_unless( !SpeciesReference_isSetId     (SR) );
  fail_unless( !SpeciesReference_isSetName   (SR) );
  fail_unless( !SpeciesReference_isSetSpecies (SR) );
  fail_unless( !SpeciesReference_isSetStoichiometry (SR) );
  fail_unless( !SpeciesReference_isSetConstant(SR)   );
}
END_TEST


START_TEST (test_L3_SpeciesReference_free_NULL)
{
  SpeciesReference_free(NULL);
}
END_TEST


START_TEST (test_L3_SpeciesReference_id)
{
  const char *id = "mitochondria";


  fail_unless( !SpeciesReference_isSetId(SR) );
  
  SpeciesReference_setId(SR, id);

  fail_unless( !strcmp(SpeciesReference_getId(SR), id) );
  fail_unless( SpeciesReference_isSetId(SR) );

  if (SpeciesReference_getId(SR) == id)
  {
    fail("SpeciesReference_setId(...) did not make a copy of string.");
  }
}
END_TEST


START_TEST (test_L3_SpeciesReference_name)
{
  const char *name = "My_Favorite_Factory";


  fail_unless( !SpeciesReference_isSetName(SR) );

  SpeciesReference_setName(SR, name);

  fail_unless( !strcmp(SpeciesReference_getName(SR), name) );
  fail_unless( SpeciesReference_isSetName(SR) );

  if (SpeciesReference_getName(SR) == name)
  {
    fail("SpeciesReference_setName(...) did not make a copy of string.");
  }

  SpeciesReference_unsetName(SR);
  
  fail_unless( !SpeciesReference_isSetName(SR) );

  if (SpeciesReference_getName(SR) != NULL)
  {
    fail("SpeciesReference_unsetName(SR) did not clear string.");
  }
}
END_TEST


START_TEST (test_L3_SpeciesReference_species)
{
  const char *species = "cell";


  fail_unless( !SpeciesReference_isSetSpecies(SR) );
  
  SpeciesReference_setSpecies(SR, species);

  fail_unless( !strcmp(SpeciesReference_getSpecies(SR), species) );
  fail_unless( SpeciesReference_isSetSpecies(SR) );

  if (SpeciesReference_getSpecies(SR) == species)
  {
    fail("SpeciesReference_setSpecies(...) did not make a copy of string.");
  }

}
END_TEST


START_TEST (test_L3_SpeciesReference_stoichiometry)
{
  double stoichiometry = 0.2;

  fail_unless( !SpeciesReference_isSetStoichiometry(SR));
  fail_unless( util_isNaN(SpeciesReference_getStoichiometry(SR)));
  
  SpeciesReference_setStoichiometry(SR, stoichiometry);

  fail_unless( SpeciesReference_getStoichiometry(SR) == stoichiometry );
  fail_unless( SpeciesReference_isSetStoichiometry(SR) );

  SpeciesReference_unsetStoichiometry(SR);

  fail_unless( !SpeciesReference_isSetStoichiometry(SR) );
  fail_unless( util_isNaN(SpeciesReference_getStoichiometry(SR)));
}
END_TEST


START_TEST (test_L3_SpeciesReference_constant)
{
  fail_unless(SpeciesReference_isSetConstant(SR) == 0);

  SpeciesReference_setConstant(SR, 1);

  fail_unless(SpeciesReference_getConstant(SR) == 1);
  fail_unless(SpeciesReference_isSetConstant(SR) == 1);

  SpeciesReference_setConstant(SR, 0);

  fail_unless(SpeciesReference_getConstant(SR) == 0);
  fail_unless(SpeciesReference_isSetConstant(SR) == 1);

}
END_TEST


START_TEST (test_L3_SpeciesReference_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(3,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  SpeciesReference_t *sr = 
    SpeciesReference_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) sr) == SBML_SPECIES_REFERENCE );
  fail_unless( SBase_getMetaId    ((SBase_t *) sr) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) sr) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) sr) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) sr) == 3 );
  fail_unless( SBase_getVersion     ((SBase_t *) sr) == 1 );

  fail_unless( SpeciesReference_getNamespaces     (sr) != NULL );
  fail_unless( XMLNamespaces_getLength(SpeciesReference_getNamespaces(sr)) == 2 );


  fail_unless( SpeciesReference_getId     (sr) == NULL );
  fail_unless( SpeciesReference_getName   (sr) == NULL );
  fail_unless( SpeciesReference_getSpecies  (sr) == NULL );
  fail_unless( util_isNaN(SpeciesReference_getStoichiometry (sr)) );
  fail_unless( SpeciesReference_getConstant(sr) == 0   );

  fail_unless( !SpeciesReference_isSetId     (sr) );
  fail_unless( !SpeciesReference_isSetName   (sr) );
  fail_unless( !SpeciesReference_isSetSpecies (sr) );
  fail_unless( !SpeciesReference_isSetStoichiometry (sr) );
  fail_unless( !SpeciesReference_isSetConstant(sr)   );

  SpeciesReference_free(sr);
  XMLNamespaces_free(xmlns);
  SBMLNamespaces_free(sbmlns);
}
END_TEST


START_TEST (test_L3_SpeciesReference_hasRequiredAttributes )
{
  SpeciesReference_t *sr = SpeciesReference_create (3, 1);

  fail_unless ( !SpeciesReference_hasRequiredAttributes(sr));

  SpeciesReference_setSpecies(sr, "id");

  fail_unless ( !SpeciesReference_hasRequiredAttributes(sr));

  SpeciesReference_setConstant(sr, 0);

  fail_unless ( SpeciesReference_hasRequiredAttributes(sr));

  SpeciesReference_free(sr);
}
END_TEST


START_TEST (test_L3_SpeciesReference_NS)
{
  fail_unless( SpeciesReference_getNamespaces     (SR) != NULL );
  fail_unless( XMLNamespaces_getLength(SpeciesReference_getNamespaces(SR)) == 1 );
  char* uri = XMLNamespaces_getURI(SpeciesReference_getNamespaces(SR), 0);
  fail_unless( !strcmp( uri, "http://www.sbml.org/sbml/level3/version1/core"));
  safe_free(uri);
}
END_TEST


Suite *
create_suite_L3_SpeciesReference (void)
{
  Suite *suite = suite_create("L3_SpeciesReference");
  TCase *tcase = tcase_create("L3_SpeciesReference");


  tcase_add_checked_fixture( tcase,
                             L3SpeciesReferenceTest_setup,
                             L3SpeciesReferenceTest_teardown );

  tcase_add_test( tcase, test_L3_SpeciesReference_create              );
  tcase_add_test( tcase, test_L3_SpeciesReference_free_NULL           );
  tcase_add_test( tcase, test_L3_SpeciesReference_id               );
  tcase_add_test( tcase, test_L3_SpeciesReference_name             );
  tcase_add_test( tcase, test_L3_SpeciesReference_species            );
  tcase_add_test( tcase, test_L3_SpeciesReference_stoichiometry      );
  tcase_add_test( tcase, test_L3_SpeciesReference_constant);
  tcase_add_test( tcase, test_L3_SpeciesReference_createWithNS         );
  tcase_add_test( tcase, test_L3_SpeciesReference_hasRequiredAttributes        );
  tcase_add_test( tcase, test_L3_SpeciesReference_NS              );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

