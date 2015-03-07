/**
 * \file    TestSpecies_newSetters.c
 * \brief   Species unit tests for new set function API
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
#include <sbml/Species.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static Species_t *C;


void
SpeciesTest1_setup (void)
{
  C = Species_create(1, 2);

  if (C == NULL)
  {
    fail("Species_create() returned a NULL pointer.");
  }
}


void
SpeciesTest1_teardown (void)
{
  Species_free(C);
}


START_TEST (test_Species_setSpeciesType1)
{
  int i = Species_setSpeciesType(C, "cell");

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( !Species_isSetSpeciesType(C) );

  i = Species_unsetSpeciesType(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetSpeciesType(C) );
}
END_TEST


START_TEST (test_Species_setSpeciesType2)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setSpeciesType(c, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Species_isSetSpeciesType(c) );

  i = Species_unsetSpeciesType(c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetSpeciesType(c) );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setSpeciesType3)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setSpeciesType(c, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_isSetSpeciesType(c) );
  fail_unless( !strcmp(Species_getSpeciesType(c), "cell" ));

  i = Species_unsetSpeciesType(c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetSpeciesType(c) );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setSpeciesType4)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setSpeciesType(c, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_isSetSpeciesType(c) );
  fail_unless( !strcmp(Species_getSpeciesType(c), "cell" ));

  i = Species_setSpeciesType(c, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetSpeciesType(c) );

  Species_free(c);
}
END_TEST


/* since the setId function has been used as an
 * alias for setName we cant require it to only
 * be used on a L2 model
START_TEST (test_Species_setId1)
{
  int i = Species_setId(C, "cell");

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( !Species_isSetId(C) );
}
END_TEST
*/

START_TEST (test_Species_setId2)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setId(c, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Species_isSetId(c) );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setId3)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setId(c, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_isSetId(c) );
  fail_unless( !strcmp(Species_getId(c), "cell" ));

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setId4)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setId(c, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_isSetId(c) );
  fail_unless( !strcmp(Species_getId(c), "cell" ));

  i = Species_setId(c, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetId(c) );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setName1)
{
  int i = Species_setName(C, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_isSetName(C) );

  i = Species_unsetName(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetName(C) );
}
END_TEST


START_TEST (test_Species_setName2)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setName(c, "1cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_isSetName(c) );

  i = Species_unsetName(c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetName(c) );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setName3)
{
  int i = Species_setName(C, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_isSetName(C) );

  i = Species_setName(C, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetName(C) );
}
END_TEST


START_TEST (test_Species_setSubstanceUnits1)
{
  int i = Species_setSubstanceUnits(C, "mm");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_isSetSubstanceUnits(C) );

}
END_TEST


START_TEST (test_Species_setSubstanceUnits2)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setSubstanceUnits(c, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Species_isSetSubstanceUnits(c) );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setSubstanceUnits3)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setSubstanceUnits(c, "mole");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !strcmp(Species_getSubstanceUnits(c), "mole") );
  fail_unless( Species_isSetSubstanceUnits(c) );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setSubstanceUnits4)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setSubstanceUnits(c, "mole");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !strcmp(Species_getSubstanceUnits(c), "mole") );
  fail_unless( Species_isSetSubstanceUnits(c) );

  i = Species_setSubstanceUnits(c, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetSubstanceUnits(c) );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setInitialConcentration1)
{
  int i = Species_setInitialConcentration(C, 2.0);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( !Species_isSetInitialConcentration(C) );
}
END_TEST


START_TEST (test_Species_setInitialConcentration2)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setInitialConcentration(c, 4);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_getInitialConcentration(c) == 4 );
  fail_unless( Species_isSetInitialConcentration(c));

  i = Species_unsetInitialConcentration(c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetInitialConcentration(c));

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setInitialAmount1)
{
  int i = Species_setInitialAmount(C, 2.0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_getInitialAmount(C) == 2.0 );
  fail_unless( Species_isSetInitialAmount(C));

  i = Species_unsetInitialAmount(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetInitialAmount(C));

}
END_TEST


START_TEST (test_Species_setInitialAmount2)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setInitialAmount(c, 4);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_getInitialAmount(c) == 4.0 );
  fail_unless( Species_isSetInitialAmount(c));

  i = Species_unsetInitialAmount(c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetInitialAmount(c));

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setUnits1)
{
  int i = Species_setUnits(C, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Species_isSetUnits(C) );

  i = Species_unsetUnits(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetUnits(C) );
}
END_TEST


START_TEST (test_Species_setUnits2)
{
  int i = Species_setUnits(C, "litre");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_isSetUnits(C) );

  i = Species_unsetUnits(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetUnits(C) );
}
END_TEST


START_TEST (test_Species_setUnits3)
{
  int i = Species_setUnits(C, "litre");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_isSetUnits(C) );

  i = Species_setUnits(C, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetUnits(C) );
}
END_TEST


START_TEST (test_Species_setCompartment1)
{
  int i = Species_setCompartment(C, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Species_isSetCompartment(C) );

  i = Species_setCompartment(C, "");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetCompartment(C) );
}
END_TEST


START_TEST (test_Species_setCompartment2)
{
  int i = Species_setCompartment(C, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_isSetCompartment(C) );

  i = Species_setCompartment(C, "");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetCompartment(C) );
}
END_TEST


START_TEST (test_Species_setConstant1)
{
  int i = Species_setConstant(C, 0);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( Species_getConstant(C) == 0 );
}
END_TEST


START_TEST (test_Species_setConstant2)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setConstant(c, 1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_getConstant(c) == 1 );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setSpatialSizeUnits1)
{
  int i = Species_setSpatialSizeUnits(C, "mm");

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( !Species_isSetSpatialSizeUnits(C) );

}
END_TEST


START_TEST (test_Species_setSpatialSizeUnits2)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setSpatialSizeUnits(c, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Species_isSetSpatialSizeUnits(c) );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setSpatialSizeUnits3)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setSpatialSizeUnits(c, "mole");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !strcmp(Species_getSpatialSizeUnits(c), "mole") );
  fail_unless( Species_isSetSpatialSizeUnits(c) );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setSpatialSizeUnits4)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setSpatialSizeUnits(c, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetSpatialSizeUnits(c) );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setHasOnlySubstanceUnits1)
{
  int i = Species_setHasOnlySubstanceUnits(C, 0);
  fail_unless( Species_getHasOnlySubstanceUnits(C) == 0 );

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
}
END_TEST


START_TEST (test_Species_setHasOnlySubstanceUnits2)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setHasOnlySubstanceUnits(c, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_getHasOnlySubstanceUnits(c) == 0 );

  i = Species_setHasOnlySubstanceUnits(c, 1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_getHasOnlySubstanceUnits(c) == 1 );

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setBoundaryCondition1)
{
  int i = Species_setBoundaryCondition(C, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_getBoundaryCondition(C) == 0 );

  i = Species_setBoundaryCondition(C, 1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_getBoundaryCondition(C) == 1 );
}
END_TEST


START_TEST (test_Species_setCharge1)
{
  int i = Species_setCharge(C, 2);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Species_isSetCharge(C) );
  fail_unless( Species_getCharge(C) == 2);

  i = Species_unsetCharge(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetCharge(C) );
}
END_TEST


START_TEST (test_Species_setCharge2)
{
  Species_t *c = 
    Species_create(2, 2);

  int i = Species_setCharge(c, 4);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( !Species_isSetCharge(c));

  Species_free(c);
}
END_TEST


START_TEST (test_Species_setCharge3)
{
  Species_t *c = 
    Species_create(2, 1);

  int i = Species_unsetCharge(c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Species_isSetCharge(c));

  Species_free(c);
}
END_TEST


Suite *
create_suite_Species_newSetters (void)
{
  Suite *suite = suite_create("Species_newSetters");
  TCase *tcase = tcase_create("Species_newSetters");


  tcase_add_checked_fixture( tcase,
                             SpeciesTest1_setup,
                             SpeciesTest1_teardown );

  tcase_add_test( tcase, test_Species_setSpeciesType1       );
  tcase_add_test( tcase, test_Species_setSpeciesType2       );
  tcase_add_test( tcase, test_Species_setSpeciesType3       );
  tcase_add_test( tcase, test_Species_setSpeciesType4       );
  tcase_add_test( tcase, test_Species_setId2       );
  tcase_add_test( tcase, test_Species_setId3       );
  tcase_add_test( tcase, test_Species_setId4       );
  tcase_add_test( tcase, test_Species_setName1       );
  tcase_add_test( tcase, test_Species_setName2       );
  tcase_add_test( tcase, test_Species_setName3       );
  tcase_add_test( tcase, test_Species_setSubstanceUnits1       );
  tcase_add_test( tcase, test_Species_setSubstanceUnits2       );
  tcase_add_test( tcase, test_Species_setSubstanceUnits3       ); 
  tcase_add_test( tcase, test_Species_setSubstanceUnits4       ); 
  tcase_add_test( tcase, test_Species_setInitialConcentration1       );
  tcase_add_test( tcase, test_Species_setInitialConcentration2       );
  tcase_add_test( tcase, test_Species_setInitialAmount1       );
  tcase_add_test( tcase, test_Species_setInitialAmount2       );
  tcase_add_test( tcase, test_Species_setUnits1       );
  tcase_add_test( tcase, test_Species_setUnits2       );
  tcase_add_test( tcase, test_Species_setUnits3       );
  tcase_add_test( tcase, test_Species_setCompartment1       );
  tcase_add_test( tcase, test_Species_setCompartment2       );
  tcase_add_test( tcase, test_Species_setConstant1       );
  tcase_add_test( tcase, test_Species_setConstant2       );
  tcase_add_test( tcase, test_Species_setSpatialSizeUnits1       );
  tcase_add_test( tcase, test_Species_setSpatialSizeUnits2       );
  tcase_add_test( tcase, test_Species_setSpatialSizeUnits3       ); 
  tcase_add_test( tcase, test_Species_setSpatialSizeUnits4       ); 
  tcase_add_test( tcase, test_Species_setHasOnlySubstanceUnits1       );
  tcase_add_test( tcase, test_Species_setHasOnlySubstanceUnits2       );
  tcase_add_test( tcase, test_Species_setBoundaryCondition1       );
  tcase_add_test( tcase, test_Species_setCharge1       );
  tcase_add_test( tcase, test_Species_setCharge2       );
  tcase_add_test( tcase, test_Species_setCharge3       );


  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

