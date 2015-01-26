/**
 * \file    TestL3Species.c
 * \brief   L3 Species unit tests
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

#include <sbml/annotation/ModelHistory.h>
#include <sbml/annotation/ModelCreator.h>
#include <sbml/annotation/Date.h>

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
L3SpeciesTest_setup (void)
{
  S = Species_create(3, 1);

  if (S == NULL)
  {
    fail("Species_create(3, 1) returned a NULL pointer.");
  }
}


void
L3SpeciesTest_teardown (void)
{
  Species_free(S);
}


START_TEST (test_L3_Species_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) S) == SBML_SPECIES );
  fail_unless( SBase_getMetaId    ((SBase_t *) S) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) S) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) S) == NULL );

  fail_unless( Species_getId     (S) == NULL );
  fail_unless( Species_getName   (S) == NULL );
  fail_unless( Species_getCompartment  (S) == NULL );
  fail_unless( util_isNaN(Species_getInitialAmount (S)) );
  fail_unless( util_isNaN(Species_getInitialConcentration (S)) );
  fail_unless( Species_getSubstanceUnits  (S) == NULL );
  fail_unless( Species_getHasOnlySubstanceUnits(S) == 0   );
  fail_unless( Species_getBoundaryCondition(S) == 0   );
  fail_unless( Species_getConstant(S) == 0   );
  fail_unless( Species_getConversionFactor  (S) == NULL );

  fail_unless( !Species_isSetId     (S) );
  fail_unless( !Species_isSetName   (S) );
  fail_unless( !Species_isSetCompartment (S) );
  fail_unless( !Species_isSetInitialAmount (S) );
  fail_unless( !Species_isSetInitialConcentration (S) );
  fail_unless( !Species_isSetSubstanceUnits  (S) );
  fail_unless( !Species_isSetHasOnlySubstanceUnits(S)   );
  fail_unless( !Species_isSetBoundaryCondition(S)   );
  fail_unless( !Species_isSetConstant(S)   );
  fail_unless( !Species_isSetConversionFactor  (S) );
}
END_TEST


START_TEST (test_L3_Species_free_NULL)
{
  Species_free(NULL);
}
END_TEST


START_TEST (test_L3_Species_id)
{
  const char *id = "mitochondria";


  fail_unless( !Species_isSetId(S) );
  
  Species_setId(S, id);

  fail_unless( !strcmp(Species_getId(S), id) );
  fail_unless( Species_isSetId(S) );

  if (Species_getId(S) == id)
  {
    fail("Species_setId(...) did not make a copy of string.");
  }
}
END_TEST


START_TEST (test_L3_Species_name)
{
  const char *name = "My_Favorite_Factory";


  fail_unless( !Species_isSetName(S) );

  Species_setName(S, name);

  fail_unless( !strcmp(Species_getName(S), name) );
  fail_unless( Species_isSetName(S) );

  if (Species_getName(S) == name)
  {
    fail("Species_setName(...) did not make a copy of string.");
  }

  Species_unsetName(S);
  
  fail_unless( !Species_isSetName(S) );

  if (Species_getName(S) != NULL)
  {
    fail("Species_unsetName(S) did not clear string.");
  }
}
END_TEST


START_TEST (test_L3_Species_compartment)
{
  const char *compartment = "cell";


  fail_unless( !Species_isSetCompartment(S) );
  
  Species_setCompartment(S, compartment);

  fail_unless( !strcmp(Species_getCompartment(S), compartment) );
  fail_unless( Species_isSetCompartment(S) );

  if (Species_getCompartment(S) == compartment)
  {
    fail("Species_setCompartment(...) did not make a copy of string.");
  }

}
END_TEST


START_TEST (test_L3_Species_initialAmount)
{
  double initialAmount = 0.2;

  fail_unless( !Species_isSetInitialAmount(S));
  fail_unless( util_isNaN(Species_getInitialAmount(S)));
  
  Species_setInitialAmount(S, initialAmount);

  fail_unless( Species_getInitialAmount(S) == initialAmount );
  fail_unless( Species_isSetInitialAmount(S) );

  Species_unsetInitialAmount(S);

  fail_unless( !Species_isSetInitialAmount(S) );
  fail_unless( util_isNaN(Species_getInitialAmount(S)));
}
END_TEST


START_TEST (test_L3_Species_initialConcentration)
{
  double initialConcentration = 0.2;

  fail_unless( !Species_isSetInitialConcentration(S));
  fail_unless( util_isNaN(Species_getInitialConcentration(S)));
  
  Species_setInitialConcentration(S, initialConcentration);

  fail_unless( Species_getInitialConcentration(S) == initialConcentration );
  fail_unless( Species_isSetInitialConcentration(S) );

  Species_unsetInitialConcentration(S);

  fail_unless( !Species_isSetInitialConcentration(S) );
  fail_unless( util_isNaN(Species_getInitialConcentration(S)));
}
END_TEST


START_TEST (test_L3_Species_substanceUnits)
{
  const char *units = "volume";


  fail_unless( !Species_isSetSubstanceUnits(S) );
  
  Species_setSubstanceUnits(S, units);

  fail_unless( !strcmp(Species_getSubstanceUnits(S), units) );
  fail_unless( Species_isSetSubstanceUnits(S) );

  if (Species_getSubstanceUnits(S) == units)
  {
    fail("Species_setSubstanceUnits(...) did not make a copy of string.");
  }

  Species_unsetSubstanceUnits(S);
  
  fail_unless( !Species_isSetSubstanceUnits(S) );

  if (Species_getSubstanceUnits(S) != NULL)
  {
    fail("Species_unsetSubstanceUnits(S, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_L3_Species_hasOnlySubstanceUnits)
{
  fail_unless(Species_isSetHasOnlySubstanceUnits(S) == 0);

  Species_setHasOnlySubstanceUnits(S, 1);

  fail_unless(Species_getHasOnlySubstanceUnits(S) == 1);
  fail_unless(Species_isSetHasOnlySubstanceUnits(S) == 1);

  Species_setHasOnlySubstanceUnits(S, 0);

  fail_unless(Species_getHasOnlySubstanceUnits(S) == 0);
  fail_unless(Species_isSetHasOnlySubstanceUnits(S) == 1);

}
END_TEST


START_TEST (test_L3_Species_boundaryCondition)
{
  fail_unless(Species_isSetBoundaryCondition(S) == 0);

  Species_setBoundaryCondition(S, 1);

  fail_unless(Species_getBoundaryCondition(S) == 1);
  fail_unless(Species_isSetBoundaryCondition(S) == 1);

  Species_setBoundaryCondition(S, 0);

  fail_unless(Species_getBoundaryCondition(S) == 0);
  fail_unless(Species_isSetBoundaryCondition(S) == 1);

}
END_TEST




START_TEST (test_L3_Species_constant)
{
  fail_unless(Species_isSetConstant(S) == 0);

  Species_setConstant(S, 1);

  fail_unless(Species_getConstant(S) == 1);
  fail_unless(Species_isSetConstant(S) == 1);

  Species_setConstant(S, 0);

  fail_unless(Species_getConstant(S) == 0);
  fail_unless(Species_isSetConstant(S) == 1);

}
END_TEST


START_TEST (test_L3_Species_conversionFactor)
{
  const char *units = "volume";


  fail_unless( !Species_isSetConversionFactor(S) );
  
  Species_setConversionFactor(S, units);

  fail_unless( !strcmp(Species_getConversionFactor(S), units) );
  fail_unless( Species_isSetConversionFactor(S) );

  if (Species_getConversionFactor(S) == units)
  {
    fail("Species_setConversionFactor(...) did not make a copy of string.");
  }

  Species_unsetConversionFactor(S);
  
  fail_unless( !Species_isSetConversionFactor(S) );

  if (Species_getConversionFactor(S) != NULL)
  {
    fail("Species_unsetConversionFactor(S, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_L3_Species_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(3,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  Species_t *s = 
    Species_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) s) == SBML_SPECIES );
  fail_unless( SBase_getMetaId    ((SBase_t *) s) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) s) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) s) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) s) == 3 );
  fail_unless( SBase_getVersion     ((SBase_t *) s) == 1 );

  fail_unless( Species_getNamespaces     (s) != NULL );
  fail_unless( XMLNamespaces_getLength(Species_getNamespaces(s)) == 2 );


  fail_unless( Species_getId     (s) == NULL );
  fail_unless( Species_getName   (s) == NULL );
  fail_unless( Species_getCompartment  (s) == NULL );
  fail_unless( util_isNaN(Species_getInitialAmount (s)) );
  fail_unless( util_isNaN(Species_getInitialConcentration (s)) );
  fail_unless( Species_getSubstanceUnits  (s) == NULL );
  fail_unless( Species_getHasOnlySubstanceUnits(s) == 0   );
  fail_unless( Species_getBoundaryCondition(s) == 0   );
  fail_unless( Species_getConstant(s) == 0   );
  fail_unless( Species_getConversionFactor  (s) == NULL );

  fail_unless( !Species_isSetId     (s) );
  fail_unless( !Species_isSetName   (s) );
  fail_unless( !Species_isSetCompartment (s) );
  fail_unless( !Species_isSetInitialAmount (s) );
  fail_unless( !Species_isSetInitialConcentration (s) );
  fail_unless( !Species_isSetSubstanceUnits  (s) );
  fail_unless( !Species_isSetHasOnlySubstanceUnits(s)   );
  fail_unless( !Species_isSetBoundaryCondition(s)   );
  fail_unless( !Species_isSetConstant(s)   );
  fail_unless( !Species_isSetConversionFactor  (s) );

  Species_free(s);
}
END_TEST


START_TEST (test_L3_Species_hasRequiredAttributes )
{
  Species_t *s = Species_create (3, 1);

  fail_unless ( !Species_hasRequiredAttributes(s));

  Species_setId(s, "id");

  fail_unless ( !Species_hasRequiredAttributes(s));

  Species_setCompartment(s, "cell");

  fail_unless ( !Species_hasRequiredAttributes(s));
  
  Species_setHasOnlySubstanceUnits(s, 0);

  fail_unless ( !Species_hasRequiredAttributes(s));

  Species_setBoundaryCondition(s, 0);

  fail_unless ( !Species_hasRequiredAttributes(s));

  Species_setConstant(s, 0);

  fail_unless ( Species_hasRequiredAttributes(s));

  Species_free(s);
}
END_TEST


START_TEST (test_L3_Species_NS)
{
  fail_unless( Species_getNamespaces     (S) != NULL );
  fail_unless( XMLNamespaces_getLength(Species_getNamespaces(S)) == 1 );
  fail_unless( !strcmp( XMLNamespaces_getURI(Species_getNamespaces(S), 0),
    "http://www.sbml.org/sbml/level3/version1/core"));
}
END_TEST


START_TEST (test_L3_Species_ModelHistory)
{
  ModelHistory_t * history = ModelHistory_create();
  SBase_setMetaId((SBase_t *)(S), "_3");
  int i = SBase_setModelHistory((SBase_t *)(S), history);

  fail_unless( i == LIBSBML_INVALID_OBJECT );
  fail_unless( !SBase_isSetModelHistory((SBase_t *)(S)) );

  ModelCreator_t * mc = ModelCreator_create();
  Date_t * date = 
    Date_createFromValues(2005, 12, 30, 12, 15, 45, 1, 2, 0);

  ModelCreator_setFamilyName(mc, "Keating");
  ModelCreator_setGivenName(mc, "Sarah");
  ModelCreator_setEmail(mc, "sbml-team@caltech.edu");
  ModelCreator_setOrganisation(mc, "UH");

  ModelHistory_addCreator(history, mc);
  ModelHistory_setCreatedDate(history, date);
  ModelHistory_setModifiedDate(history, date);

  i = SBase_setModelHistory((SBase_t *)(S), history);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( SBase_isSetModelHistory((SBase_t *)(S)) );
  
  i = SBase_unsetModelHistory((SBase_t *)(S));

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !SBase_isSetModelHistory((SBase_t *)(S)) );
  fail_unless( SBase_getModelHistory((SBase_t *)(S)) == NULL );

  
  ModelHistory_free(history);
}
END_TEST


START_TEST (test_L3_Species_initDefaults)
{
  Species_t *s = Species_create(3,1);

  fail_unless( Species_getId     (s) == NULL );
  fail_unless( Species_getName   (s) == NULL );
  fail_unless( Species_getCompartment  (s) == NULL );
  fail_unless( util_isNaN(Species_getInitialAmount (s)) );
  fail_unless( util_isNaN(Species_getInitialConcentration (s)) );
  fail_unless( Species_getSubstanceUnits  (s) == NULL );
  fail_unless( Species_getHasOnlySubstanceUnits(s) == 0   );
  fail_unless( Species_getBoundaryCondition(s) == 0   );
  fail_unless( Species_getConstant(s) == 0   );
  fail_unless( Species_getConversionFactor  (s) == NULL );

  fail_unless( !Species_isSetId     (s) );
  fail_unless( !Species_isSetName   (s) );
  fail_unless( !Species_isSetCompartment (s) );
  fail_unless( !Species_isSetInitialAmount (s) );
  fail_unless( !Species_isSetInitialConcentration (s) );
  fail_unless( !Species_isSetSubstanceUnits  (s) );
  fail_unless( !Species_isSetHasOnlySubstanceUnits(s)   );
  fail_unless( !Species_isSetBoundaryCondition(s)   );
  fail_unless( !Species_isSetConstant(s)   );
  fail_unless( !Species_isSetConversionFactor  (s) );

  Species_initDefaults(s);

  fail_unless( Species_getId     (s) == NULL );
  fail_unless( Species_getName   (s) == NULL );
  fail_unless( Species_getCompartment  (s) == NULL );
  fail_unless( util_isNaN(Species_getInitialAmount (s)) );
  fail_unless( util_isNaN(Species_getInitialConcentration (s)) );
  fail_unless( !strcmp(Species_getSubstanceUnits  (s),"mole" ));
  fail_unless( Species_getHasOnlySubstanceUnits(s) == 0   );
  fail_unless( Species_getBoundaryCondition(s) == 0   );
  fail_unless( Species_getConstant(s) == 0   );
  fail_unless( Species_getConversionFactor  (s) == NULL );

  fail_unless( !Species_isSetId     (s) );
  fail_unless( !Species_isSetName   (s) );
  fail_unless( !Species_isSetCompartment (s) );
  fail_unless( !Species_isSetInitialAmount (s) );
  fail_unless( !Species_isSetInitialConcentration (s) );
  fail_unless( Species_isSetSubstanceUnits  (s) );
  fail_unless( Species_isSetHasOnlySubstanceUnits(s)   );
  fail_unless( Species_isSetBoundaryCondition(s)   );
  fail_unless( Species_isSetConstant(s)   );
  fail_unless( !Species_isSetConversionFactor  (s) );

  Species_free(s);
}
END_TEST


Suite *
create_suite_L3_Species (void)
{
  Suite *suite = suite_create("L3_Species");
  TCase *tcase = tcase_create("L3_Species");


  tcase_add_checked_fixture( tcase,
                             L3SpeciesTest_setup,
                             L3SpeciesTest_teardown );

  tcase_add_test( tcase, test_L3_Species_create              );
  tcase_add_test( tcase, test_L3_Species_free_NULL           );
  tcase_add_test( tcase, test_L3_Species_id               );
  tcase_add_test( tcase, test_L3_Species_name             );
  tcase_add_test( tcase, test_L3_Species_compartment            );
  tcase_add_test( tcase, test_L3_Species_initialAmount      );
  tcase_add_test( tcase, test_L3_Species_initialConcentration      );
  tcase_add_test( tcase, test_L3_Species_substanceUnits);
  tcase_add_test( tcase, test_L3_Species_hasOnlySubstanceUnits);
  tcase_add_test( tcase, test_L3_Species_boundaryCondition);
  tcase_add_test( tcase, test_L3_Species_constant);
  tcase_add_test( tcase, test_L3_Species_conversionFactor);
  tcase_add_test( tcase, test_L3_Species_createWithNS         );
  tcase_add_test( tcase, test_L3_Species_hasRequiredAttributes        );
  tcase_add_test( tcase, test_L3_Species_NS              );
  tcase_add_test( tcase, test_L3_Species_ModelHistory              );
  tcase_add_test( tcase, test_L3_Species_initDefaults            );

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

