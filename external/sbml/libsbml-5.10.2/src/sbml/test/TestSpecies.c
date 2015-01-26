/**
 * \file    TestSpecies.c
 * \brief   Species unit tests
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
#include <sbml/Species.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static Species_t *S;


void
SpeciesTest_setup (void)
{
  S = Species_create(2, 4);

  if (S == NULL)
  {
    fail("Species_create() returned a NULL pointer.");
  }
}


void
SpeciesTest_teardown (void)
{
  Species_free(S);
}


START_TEST (test_Species_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) S) == SBML_SPECIES );
  fail_unless( SBase_getMetaId    ((SBase_t *) S) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) S) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) S) == NULL );

  fail_unless( Species_getId                   (S) == NULL );
  fail_unless( Species_getName                 (S) == NULL );
  fail_unless( Species_getCompartment          (S) == NULL );
  fail_unless( Species_getInitialAmount        (S) == 0.0  );
  fail_unless( Species_getInitialConcentration (S) == 0.0  );
  fail_unless( Species_getSubstanceUnits       (S) == NULL );
  fail_unless( Species_getSpatialSizeUnits     (S) == NULL );
  fail_unless( Species_getHasOnlySubstanceUnits(S) == 0    );
  fail_unless( Species_getBoundaryCondition    (S) == 0    );
  fail_unless( Species_getCharge               (S) == 0    );
  fail_unless( Species_getConstant             (S) == 0    );

  fail_unless( !Species_isSetId                  (S) );
  fail_unless( !Species_isSetName                (S) );
  fail_unless( !Species_isSetCompartment         (S) );
  fail_unless( !Species_isSetInitialAmount       (S) );
  fail_unless( !Species_isSetInitialConcentration(S) );
  fail_unless( !Species_isSetSubstanceUnits      (S) );
  fail_unless( !Species_isSetSpatialSizeUnits    (S) );
  fail_unless( !Species_isSetUnits               (S) );
  fail_unless( !Species_isSetCharge              (S) );
  fail_unless( Species_isSetBoundaryCondition    (S) );
  fail_unless( Species_isSetHasOnlySubstanceUnits(S) );
  fail_unless( Species_isSetConstant             (S) );
}
END_TEST


//START_TEST (test_Species_createWith)
//{
//  Species_t *s = Species_createWith("Ca", "Calcium");
//
//
//  fail_unless( SBase_getTypeCode  ((SBase_t *) s) == SBML_SPECIES );
//  fail_unless( SBase_getMetaId    ((SBase_t *) s) == NULL );
//  fail_unless( SBase_getNotes     ((SBase_t *) s) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) s) == NULL );
//
//  fail_unless( !strcmp(Species_getName            (s), "Calcium"  ) );
//  fail_unless( Species_getSpatialSizeUnits     (s) == NULL );
//  fail_unless( Species_getHasOnlySubstanceUnits(s) == 0 );
//  fail_unless( Species_getConstant             (s) == 0 );
//
//  fail_unless( !strcmp(Species_getId            (s), "Ca"  ) );
//
//  fail_unless(   Species_isSetId                   (s) );
//  fail_unless(   Species_isSetName                 (s) );
//  fail_unless( ! Species_isSetCompartment          (s) );
//  fail_unless( ! Species_isSetSubstanceUnits       (s) );
//  fail_unless( ! Species_isSetSpatialSizeUnits     (s) );
//  fail_unless( ! Species_isSetUnits                (s) );
//  fail_unless( ! Species_isSetInitialAmount        (s) );
//  fail_unless( ! Species_isSetInitialConcentration (s) );
//  fail_unless( ! Species_isSetCharge               (s) );
//
//  Species_free(s);
//}
//END_TEST


START_TEST (test_Species_free_NULL)
{
  Species_free(NULL);
}
END_TEST


START_TEST (test_Species_setId)
{
  const char *id = "Glucose";


  Species_setId(S, id);

  fail_unless( !strcmp(Species_getId(S), id) );
  fail_unless( Species_isSetId(S) );

  if (Species_getId(S) == id)
  {
    fail("Species_setId(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Species_setId(S, Species_getId(S));
  fail_unless( !strcmp(Species_getId(S), id) );

  Species_setId(S, NULL);
  fail_unless( !Species_isSetId(S) );

  if (Species_getId(S) != NULL)
  {
    fail("Species_setId(S, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Species_setName)
{
  const char *name = "So_Sweet";


  Species_setName(S, name);

  fail_unless( !strcmp(Species_getName(S), name) );
  fail_unless( Species_isSetName(S) );

  if (Species_getName(S) == name)
  {
    fail("Species_setName(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Species_setName(S, Species_getName(S));
  fail_unless( !strcmp(Species_getName(S), name) );

  Species_setName(S, NULL);
  fail_unless( !Species_isSetName(S) );

  if (Species_getName(S) != NULL)
  {
    fail("Species_setName(S, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Species_setCompartment)
{
  const char *compartment = "cell";


  Species_setCompartment(S, compartment);

  fail_unless( !strcmp(Species_getCompartment(S), compartment) );
  fail_unless( Species_isSetCompartment(S) );

  if (Species_getCompartment(S) == compartment)
  {
    fail("Species_setCompartment(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Species_setCompartment(S, Species_getCompartment(S));
  fail_unless( !strcmp(Species_getCompartment(S), compartment) );

  Species_setCompartment(S, NULL);
  fail_unless( !Species_isSetCompartment(S) );

  if (Species_getCompartment(S) != NULL)
  {
    fail("Species_setComartment(S, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Species_setInitialAmount)
{
  fail_unless( !Species_isSetInitialAmount       (S) );
  fail_unless( !Species_isSetInitialConcentration(S) );

  Species_setInitialAmount(S, 1.2);

  fail_unless(  Species_isSetInitialAmount       (S) );
  fail_unless( !Species_isSetInitialConcentration(S) );

  fail_unless( Species_getInitialAmount(S) == 1.2 );
}
END_TEST


START_TEST (test_Species_setInitialConcentration)
{
  fail_unless( !Species_isSetInitialAmount       (S) );
  fail_unless( !Species_isSetInitialConcentration(S) );

  Species_setInitialConcentration(S, 3.4);

  fail_unless( !Species_isSetInitialAmount       (S) );
  fail_unless(  Species_isSetInitialConcentration(S) );

  fail_unless( Species_getInitialConcentration(S) == 3.4 );
}
END_TEST


START_TEST (test_Species_setSubstanceUnits)
{
  const char *units = "item";


  Species_setSubstanceUnits(S, units);

  fail_unless( !strcmp(Species_getSubstanceUnits(S), units) );
  fail_unless( Species_isSetSubstanceUnits(S) );

  if (Species_getSubstanceUnits(S) == units)
  {
    fail("Species_setSubstanceUnits(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Species_setSubstanceUnits(S, Species_getSubstanceUnits(S));
  fail_unless( !strcmp(Species_getSubstanceUnits(S), units) );

  Species_setSubstanceUnits(S, NULL);
  fail_unless( !Species_isSetSubstanceUnits(S) );

  if (Species_getSubstanceUnits(S) != NULL)
  {
    fail("Species_setSubstanceUnits(S, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Species_setSpatialSizeUnits)
{
  Species_t *s = 
    Species_create(2, 1);
  const char *units = "volume";


  Species_setSpatialSizeUnits(s, units);

  fail_unless( !strcmp(Species_getSpatialSizeUnits(s), units) );
  fail_unless( Species_isSetSpatialSizeUnits(s) );

  if (Species_getSpatialSizeUnits(s) == units)
  {
    fail("Species_setSpatialSizeUnits(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Species_setSpatialSizeUnits(s, Species_getSpatialSizeUnits(s));
  fail_unless( !strcmp(Species_getSpatialSizeUnits(s), units) );

  Species_setSpatialSizeUnits(s, NULL);
  fail_unless( !Species_isSetSpatialSizeUnits(s) );

  if (Species_getSpatialSizeUnits(s) != NULL)
  {
    fail("Species_setSpatialSizeUnits(S, NULL) did not clear string.");
  }

  Species_free(s);
}
END_TEST


START_TEST (test_Species_setUnits)
{
  const char *units = "mole";


  Species_setUnits(S, units);

  fail_unless( !strcmp(Species_getUnits(S), units) );
  fail_unless( Species_isSetUnits(S) );

  if (Species_getSubstanceUnits(S) == units)
  {
    fail("Species_setUnits(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Species_setUnits(S, Species_getSubstanceUnits(S));
  fail_unless( !strcmp(Species_getUnits(S), units) );

  Species_setUnits(S, NULL);
  fail_unless( !Species_isSetUnits(S) );

  if (Species_getSubstanceUnits(S) != NULL)
  {
    fail("Species_setUnits(S, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Species_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  Species_t *object = 
    Species_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_SPECIES );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 1 );

  fail_unless( Species_getNamespaces     (object) != NULL );
  fail_unless( XMLNamespaces_getLength(Species_getNamespaces(object)) == 2 );

  Species_free(object);
}
END_TEST


START_TEST (test_Species_conversionFactor)
{
  fail_unless( !Species_isSetConversionFactor(S) );
  int ret = Species_unsetConversionFactor(S);
  fail_unless( ret == LIBSBML_UNEXPECTED_ATTRIBUTE );
}
END_TEST


Suite *
create_suite_Species (void)
{
  Suite *suite = suite_create("Species");
  TCase *tcase = tcase_create("Species");


  tcase_add_checked_fixture( tcase,
                             SpeciesTest_setup,
                             SpeciesTest_teardown );

  tcase_add_test( tcase, test_Species_create                  );
  //tcase_add_test( tcase, test_Species_createWith              );
  tcase_add_test( tcase, test_Species_free_NULL               );
  tcase_add_test( tcase, test_Species_setId                   );
  tcase_add_test( tcase, test_Species_setName                 );
  tcase_add_test( tcase, test_Species_setCompartment          );
  tcase_add_test( tcase, test_Species_setInitialAmount        );
  tcase_add_test( tcase, test_Species_setInitialConcentration );
  tcase_add_test( tcase, test_Species_setSubstanceUnits       );
  tcase_add_test( tcase, test_Species_setSpatialSizeUnits     );
  tcase_add_test( tcase, test_Species_setUnits                );
  tcase_add_test( tcase, test_Species_createWithNS         );
  tcase_add_test( tcase, test_Species_conversionFactor        );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


