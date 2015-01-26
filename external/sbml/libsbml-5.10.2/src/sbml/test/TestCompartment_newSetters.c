/**
 * \file    TestCompartment_newSetters.c
 * \brief   Compartment unit tests for new set function API
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
#include <sbml/Compartment.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Compartment_t *C;


void
CompartmentTest1_setup (void)
{
  C = Compartment_create(1, 2);

  if (C == NULL)
  {
    fail("Compartment_create(2, 4) returned a NULL pointer.");
  }
}


void
CompartmentTest1_teardown (void)
{
  Compartment_free(C);
}


START_TEST (test_Compartment_setCompartmentType1)
{
  int i = Compartment_setCompartmentType(C, "cell");

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( !Compartment_isSetCompartmentType(C) );

  i = Compartment_unsetCompartmentType(C);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( !Compartment_isSetCompartmentType(C) );
}
END_TEST


START_TEST (test_Compartment_setCompartmentType2)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setCompartmentType(c, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Compartment_isSetCompartmentType(c) );

  i = Compartment_unsetCompartmentType(c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetCompartmentType(c) );

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_setCompartmentType3)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setCompartmentType(c, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_isSetCompartmentType(c) );
  fail_unless( !strcmp(Compartment_getCompartmentType(c), "cell" ));

  i = Compartment_unsetCompartmentType(c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetCompartmentType(c) );

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_setCompartmentType4)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setCompartmentType(c, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetCompartmentType(c) );

  Compartment_free(c);
}
END_TEST


/* since the setId function has been used as an
 * alias for setName we cant require it to only
 * be used on a L2 model
START_TEST (test_Compartment_setId1)
{
  int i = Compartment_setId(C, "cell");

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( !Compartment_isSetId(C) );
}
END_TEST
*/

START_TEST (test_Compartment_setId2)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setId(c, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Compartment_isSetId(c) );

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_setId3)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setId(c, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_isSetId(c) );
  fail_unless( !strcmp(Compartment_getId(c), "cell" ));

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_setId4)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setId(c, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetId(c) );

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_setName1)
{
  int i = Compartment_setName(C, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_isSetName(C) );

  i = Compartment_unsetName(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetName(C) );
}
END_TEST


START_TEST (test_Compartment_setName2)
{
  Compartment_t *c = 
    Compartment_create(1, 2);

  int i = Compartment_setName(c, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Compartment_isSetName(c) );

  i = Compartment_unsetName(c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetName(c) );

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_setName3)
{
  int i = Compartment_setName(C, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetName(C) );
}
END_TEST


START_TEST (test_Compartment_setSpatialDimensions1)
{
  int i = Compartment_setSpatialDimensions(C, 2);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( Compartment_getSpatialDimensions(C) == 3 );

}
END_TEST


START_TEST (test_Compartment_setSpatialDimensions2)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setSpatialDimensions(c, 4);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Compartment_getSpatialDimensions(c) == 3 );

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_setSpatialDimensions3)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setSpatialDimensions(c, 2);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_getSpatialDimensions(c) == 2 );

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_setSpatialDimensions4)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setSpatialDimensionsAsDouble(c, 2.0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_getSpatialDimensions(c) == 2 );

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_setSpatialDimensions5)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setSpatialDimensionsAsDouble(c, 2.2);

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( Compartment_getSpatialDimensions(c) == 3 );

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_setSize1)
{
  int i = Compartment_setSize(C, 2.0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_getSize(C) == 2.0 );

  i = Compartment_unsetSize(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
}
END_TEST


START_TEST (test_Compartment_setSize2)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setSize(c, 4);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_getSize(c) == 4 );
  fail_unless( Compartment_isSetSize(c));

  i = Compartment_unsetSize(c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetSize(c));

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_setVolume1)
{
  int i = Compartment_setVolume(C, 2.0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_getVolume(C) == 2.0 );
  fail_unless( Compartment_isSetVolume(C));

  i = Compartment_unsetVolume(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_getVolume(C) == 1.0 );
  fail_unless( Compartment_isSetVolume(C));

}
END_TEST


START_TEST (test_Compartment_setVolume2)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setVolume(c, 4);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_getVolume(c) == 4.0 );
  fail_unless( Compartment_isSetVolume(c));

  i = Compartment_unsetVolume(c);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetVolume(c));

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_setUnits1)
{
  int i = Compartment_setUnits(C, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Compartment_isSetUnits(C) );

  i = Compartment_unsetUnits(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetUnits(C) );
}
END_TEST


START_TEST (test_Compartment_setUnits2)
{
  int i = Compartment_setUnits(C, "litre");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_isSetUnits(C) );

  i = Compartment_unsetUnits(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetUnits(C) );
}
END_TEST


START_TEST (test_Compartment_setUnits3)
{
  int i = Compartment_setUnits(C, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetUnits(C) );
}
END_TEST


START_TEST (test_Compartment_setOutside1)
{
  int i = Compartment_setOutside(C, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Compartment_isSetOutside(C) );

  i = Compartment_unsetOutside(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetOutside(C) );
}
END_TEST


START_TEST (test_Compartment_setOutside2)
{
  int i = Compartment_setOutside(C, "litre");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_isSetOutside(C) );

  i = Compartment_unsetOutside(C);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetOutside(C) );
}
END_TEST


START_TEST (test_Compartment_setOutside3)
{
  int i = Compartment_setOutside(C, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Compartment_isSetOutside(C) );
}
END_TEST


START_TEST (test_Compartment_setConstant1)
{
  int i = Compartment_setConstant(C, 0);

  fail_unless( i == LIBSBML_UNEXPECTED_ATTRIBUTE );
  fail_unless( Compartment_getConstant(C) == 0 );
}
END_TEST


START_TEST (test_Compartment_setConstant2)
{
  Compartment_t *c = 
    Compartment_create(2, 2);

  int i = Compartment_setConstant(c, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Compartment_getConstant(c) == 0 );

  Compartment_free(c);
}
END_TEST


Suite *
create_suite_Compartment_newSetters (void)
{
  Suite *suite = suite_create("Compartment_newSetters");
  TCase *tcase = tcase_create("Compartment_newSetters");


  tcase_add_checked_fixture( tcase,
                             CompartmentTest1_setup,
                             CompartmentTest1_teardown );

  tcase_add_test( tcase, test_Compartment_setCompartmentType1       );
  tcase_add_test( tcase, test_Compartment_setCompartmentType2       );
  tcase_add_test( tcase, test_Compartment_setCompartmentType3       );
  tcase_add_test( tcase, test_Compartment_setCompartmentType4       );
  tcase_add_test( tcase, test_Compartment_setId2       );
  tcase_add_test( tcase, test_Compartment_setId3       );
  tcase_add_test( tcase, test_Compartment_setId4       );
  tcase_add_test( tcase, test_Compartment_setName1       );
  tcase_add_test( tcase, test_Compartment_setName2       );
  tcase_add_test( tcase, test_Compartment_setName3       );
  tcase_add_test( tcase, test_Compartment_setSpatialDimensions1       );
  tcase_add_test( tcase, test_Compartment_setSpatialDimensions2       );
  tcase_add_test( tcase, test_Compartment_setSpatialDimensions3       ); 
  tcase_add_test( tcase, test_Compartment_setSpatialDimensions4       );
  tcase_add_test( tcase, test_Compartment_setSpatialDimensions5       ); 
  tcase_add_test( tcase, test_Compartment_setSize1       );
  tcase_add_test( tcase, test_Compartment_setSize2       );
  tcase_add_test( tcase, test_Compartment_setVolume1       );
  tcase_add_test( tcase, test_Compartment_setVolume2       );
  tcase_add_test( tcase, test_Compartment_setUnits1       );
  tcase_add_test( tcase, test_Compartment_setUnits2       );
  tcase_add_test( tcase, test_Compartment_setUnits3       );
  tcase_add_test( tcase, test_Compartment_setOutside1       );
  tcase_add_test( tcase, test_Compartment_setOutside2       );
  tcase_add_test( tcase, test_Compartment_setOutside3       );
  tcase_add_test( tcase, test_Compartment_setConstant1       );
  tcase_add_test( tcase, test_Compartment_setConstant2       );


  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


