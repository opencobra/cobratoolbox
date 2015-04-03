/**
 * \file    TestCompartment.c
 * \brief   Compartment unit tests
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
#include <sbml/Compartment.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Compartment_t *C;


void
CompartmentTest_setup (void)
{
  C = Compartment_create(2, 4);

  if (C == NULL)
  {
    fail("Compartment_create(2, 4) returned a NULL pointer.");
  }
}


void
CompartmentTest_teardown (void)
{
  Compartment_free(C);
}


START_TEST (test_Compartment_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) C) == SBML_COMPARTMENT );
  fail_unless( SBase_getMetaId    ((SBase_t *) C) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) C) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) C) == NULL );

  fail_unless( Compartment_getId     (C) == NULL );
  fail_unless( Compartment_getName   (C) == NULL );
  fail_unless( Compartment_getUnits  (C) == NULL );
  fail_unless( Compartment_getOutside(C) == NULL );

  fail_unless( Compartment_getSpatialDimensions(C) == 3   );
  fail_unless( Compartment_getVolume           (C) == 1.0 );
  fail_unless( Compartment_getConstant         (C) == 1   );

  fail_unless( !Compartment_isSetId     (C) );
  fail_unless( !Compartment_isSetName   (C) );
  fail_unless( !Compartment_isSetSize   (C) );
  fail_unless( !Compartment_isSetVolume (C) );
  fail_unless( !Compartment_isSetUnits  (C) );
  fail_unless( !Compartment_isSetOutside(C) );
}
END_TEST


START_TEST (test_Compartment_initDefaults)
{
  Compartment_t *c = Compartment_create(2, 4);
    
  Compartment_setId(c, "A");
  Compartment_initDefaults(c);

  fail_unless( !strcmp(Compartment_getId     (c), "A"));
  fail_unless( Compartment_getName   (c) == NULL );
  fail_unless( Compartment_getUnits  (c) == NULL );
  fail_unless( Compartment_getOutside(c) == NULL );

  fail_unless( Compartment_getSpatialDimensions(c) == 3   );
  fail_unless( Compartment_getVolume           (c) == 1.0 );
  fail_unless( Compartment_getConstant         (c) == 1   );

  fail_unless( Compartment_isSetId     (c) );
  fail_unless( !Compartment_isSetName   (c) );
  fail_unless( !Compartment_isSetSize   (c) );
  fail_unless( !Compartment_isSetVolume (c) );
  fail_unless( !Compartment_isSetUnits  (c) );
  fail_unless( !Compartment_isSetOutside(c) );
  fail_unless( Compartment_isSetSpatialDimensions(c) );
  fail_unless( Compartment_isSetConstant(c) );
  
  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_createWith)
{
  Compartment_t *c = Compartment_create(2, 4);
    
  Compartment_setId(c, "A");


  fail_unless( SBase_getTypeCode  ((SBase_t *) c) == SBML_COMPARTMENT );
  fail_unless( SBase_getMetaId    ((SBase_t *) c) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) c) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) c) == NULL );

  fail_unless( Compartment_getName(c)              == NULL );
  fail_unless( Compartment_getSpatialDimensions(c) == 3    );

  fail_unless( !strcmp( Compartment_getId     (c), "A"     ) );

  fail_unless( Compartment_getConstant(c) == 1   );

  fail_unless( Compartment_isSetId     (c) );
  fail_unless( !Compartment_isSetName  (c) );

  Compartment_free(c);
}
END_TEST


START_TEST (test_Compartment_free_NULL)
{
  Compartment_free(NULL);
}
END_TEST


START_TEST (test_Compartment_setId)
{
  const char *id = "mitochondria";


  Compartment_setId(C, id);

  fail_unless( !strcmp(Compartment_getId(C), id) );
  fail_unless( Compartment_isSetId(C) );

  if (Compartment_getId(C) == id)
  {
    fail("Compartment_setId(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Compartment_setId(C, Compartment_getId(C));
  fail_unless( !strcmp(Compartment_getId(C), id) );

  Compartment_setId(C, NULL);
  fail_unless( !Compartment_isSetId(C) );

  if (Compartment_getId(C) != NULL)
  {
    fail("Compartment_setId(C, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Compartment_setName)
{
  const char *name = "My_Favorite_Factory";


  Compartment_setName(C, name);

  fail_unless( !strcmp(Compartment_getName(C), name) );
  fail_unless( Compartment_isSetName(C) );

  if (Compartment_getName(C) == name)
  {
    fail("Compartment_setName(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Compartment_setName(C, Compartment_getName(C));
  fail_unless( !strcmp(Compartment_getName(C), name) );

  Compartment_setName(C, NULL);
  fail_unless( !Compartment_isSetName(C) );

  if (Compartment_getName(C) != NULL)
  {
    fail("Compartment_setName(C, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Compartment_setUnits)
{
  const char *units = "volume";


  Compartment_setUnits(C, units);

  fail_unless( !strcmp(Compartment_getUnits(C), units) );
  fail_unless( Compartment_isSetUnits(C) );

  if (Compartment_getUnits(C) == units)
  {
    fail("Compartment_setUnits(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Compartment_setUnits(C, Compartment_getUnits(C));
  fail_unless( !strcmp(Compartment_getUnits(C), units) );

  Compartment_setUnits(C, NULL);
  fail_unless( !Compartment_isSetUnits(C) );

  if (Compartment_getUnits(C) != NULL)
  {
    fail("Compartment_setUnits(C, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Compartment_setOutside)
{
  const char *outside = "cell";


  Compartment_setOutside(C, outside);

  fail_unless( !strcmp(Compartment_getOutside(C), outside) );
  fail_unless( Compartment_isSetOutside(C)  );

  if (Compartment_getOutside(C) == outside)
  {
    fail("Compartment_setOutside(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Compartment_setOutside(C, Compartment_getOutside(C));
  fail_unless( !strcmp(Compartment_getOutside(C), outside) );

  Compartment_setOutside(C, NULL);
  fail_unless( !Compartment_isSetOutside(C) );

  if (Compartment_getOutside(C) != NULL)
  {
    fail("Compartment_setOutside(C, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Compartment_unsetSize)
{
  Compartment_setSize(C, 0.2);

  fail_unless( Compartment_getSize(C) == 0.2 );
  fail_unless( Compartment_isSetSize(C) );

  Compartment_unsetSize(C);

  fail_unless( !Compartment_isSetSize(C) );
}
END_TEST


START_TEST (test_Compartment_unsetVolume)
{
  Compartment_setVolume(C, 1.0);

  fail_unless( Compartment_getVolume(C) == 1.0 );
/* FIX_ME
  fail_unless( Compartment_isSetVolume(C) );
  */

  Compartment_unsetVolume(C);

  fail_unless( !Compartment_isSetVolume(C) );
}
END_TEST


START_TEST (test_Compartment_getsetType)
{
  Compartment_setCompartmentType(C, "cell");

  fail_unless( !strcmp(Compartment_getCompartmentType(C), "cell" ));
  fail_unless( Compartment_isSetCompartmentType(C) );

  Compartment_unsetCompartmentType(C);

  fail_unless( !Compartment_isSetCompartmentType(C) );
}
END_TEST


START_TEST (test_Compartment_getsetConstant)
{
  Compartment_setConstant(C, 1);

  fail_unless( Compartment_getConstant(C) == 1);

}
END_TEST


START_TEST (test_Compartment_getSpatialDimensions)
{
  Compartment_setSpatialDimensions(C, 1);

  fail_unless( Compartment_getSpatialDimensions(C) == 1);

}
END_TEST


START_TEST (test_Compartment_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  Compartment_t *c = 
    Compartment_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) c) == SBML_COMPARTMENT );
  fail_unless( SBase_getMetaId    ((SBase_t *) c) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) c) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) c) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) c) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) c) == 1 );

  fail_unless( Compartment_getNamespaces     (c) != NULL );
  fail_unless( XMLNamespaces_getLength(Compartment_getNamespaces(c)) == 2 );


  fail_unless( Compartment_getName(c)              == NULL );
  fail_unless( Compartment_getSpatialDimensions(c) == 3    );
  fail_unless( Compartment_getConstant(c) == 1   );

  Compartment_free(c);
  XMLNamespaces_free(xmlns);
  SBMLNamespaces_free(sbmlns);
}
END_TEST


Suite *
create_suite_Compartment (void)
{
  Suite *suite = suite_create("Compartment");
  TCase *tcase = tcase_create("Compartment");


  tcase_add_checked_fixture( tcase,
                             CompartmentTest_setup,
                             CompartmentTest_teardown );

  tcase_add_test( tcase, test_Compartment_create              );
  tcase_add_test( tcase, test_Compartment_createWith          );
  tcase_add_test( tcase, test_Compartment_free_NULL           );
  tcase_add_test( tcase, test_Compartment_setId               );
  tcase_add_test( tcase, test_Compartment_setName             );
  tcase_add_test( tcase, test_Compartment_setUnits            );
  tcase_add_test( tcase, test_Compartment_setOutside          );
  tcase_add_test( tcase, test_Compartment_unsetSize           );
  tcase_add_test( tcase, test_Compartment_unsetVolume         );
  tcase_add_test( tcase, test_Compartment_getsetType          );
  tcase_add_test( tcase, test_Compartment_getsetConstant      );
  tcase_add_test( tcase, test_Compartment_getSpatialDimensions);
  tcase_add_test( tcase, test_Compartment_initDefaults        );
  tcase_add_test( tcase, test_Compartment_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

