/**
 * \file    TestSpeciesType.c
 * \brief   SpeciesType unit tests
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
#include <sbml/SpeciesType.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static SpeciesType_t *CT;


void
SpeciesTypeTest_setup (void)
{
  CT = SpeciesType_create(2, 4);

  if (CT == NULL)
  {
    fail("SpeciesType_create() returned a NULL pointer.");
  }
}


void
SpeciesTypeTest_teardown (void)
{
  SpeciesType_free(CT);
}


START_TEST (test_SpeciesType_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) CT) == SBML_SPECIES_TYPE );
  fail_unless( SBase_getMetaId    ((SBase_t *) CT) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) CT) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) CT) == NULL );

  fail_unless( SpeciesType_getId     (CT) == NULL );
  fail_unless( SpeciesType_getName   (CT) == NULL );

  fail_unless( !SpeciesType_isSetId     (CT) );
  fail_unless( !SpeciesType_isSetName   (CT) );
}
END_TEST


//START_TEST (test_SpeciesType_createWith)
//{
//  SpeciesType_t *c = SpeciesType_createWith("A", "");
//
//
//  fail_unless( SBase_getTypeCode  ((SBase_t *) c) == SBML_SPECIES_TYPE );
//  fail_unless( SBase_getMetaId    ((SBase_t *) c) == NULL );
//  fail_unless( SBase_getNotes     ((SBase_t *) c) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) c) == NULL );
//
//  fail_unless( SpeciesType_getName(c)              == NULL );
//
//  fail_unless( !strcmp( SpeciesType_getId     (c), "A"     ) );
//
//  fail_unless( SpeciesType_isSetId     (c) );
//  fail_unless( !SpeciesType_isSetName  (c) );
//
//  SpeciesType_free(c);
//}
//END_TEST


START_TEST (test_SpeciesType_free_NULL)
{
  SpeciesType_free(NULL);
}
END_TEST


START_TEST (test_SpeciesType_setId)
{
  const char *id = "mitochondria";


  SpeciesType_setId(CT, id);

  fail_unless( !strcmp(SpeciesType_getId(CT), id) );
  fail_unless( SpeciesType_isSetId(CT) );

  if (SpeciesType_getId(CT) == id)
  {
    fail("SpeciesType_setId(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  SpeciesType_setId(CT, SpeciesType_getId(CT));
  fail_unless( !strcmp(SpeciesType_getId(CT), id) );

  SpeciesType_setId(CT, NULL);
  fail_unless( !SpeciesType_isSetId(CT) );

  if (SpeciesType_getId(CT) != NULL)
  {
    fail("SpeciesType_setId(CT, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_SpeciesType_setName)
{
  const char *name = "My_Favorite_Factory";


  SpeciesType_setName(CT, name);

  fail_unless( !strcmp(SpeciesType_getName(CT), name) );
  fail_unless( SpeciesType_isSetName(CT) );

  if (SpeciesType_getName(CT) == name)
  {
    fail("SpeciesType_setName(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  SpeciesType_setName(CT, SpeciesType_getName(CT));
  fail_unless( !strcmp(SpeciesType_getName(CT), name) );

  SpeciesType_setName(CT, NULL);
  fail_unless( !SpeciesType_isSetName(CT) );

  if (SpeciesType_getName(CT) != NULL)
  {
    fail("SpeciesType_setName(CT, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_SpeciesType_unsetName)
{
  SpeciesType_setName(CT, "name");

  fail_unless( !strcmp( SpeciesType_getName(CT), "name"     ));
  fail_unless( SpeciesType_isSetName(CT) );

  SpeciesType_unsetName(CT);

  fail_unless( !SpeciesType_isSetName(CT) );
}
END_TEST


START_TEST (test_SpeciesType_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,2);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  SpeciesType_t *object = 
    SpeciesType_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_SPECIES_TYPE );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 2 );

  fail_unless( SpeciesType_getNamespaces     (object) != NULL );
  fail_unless( XMLNamespaces_getLength(SpeciesType_getNamespaces(object)) == 2 );

  SpeciesType_free(object);
  XMLNamespaces_free(xmlns);
  SBMLNamespaces_free(sbmlns);
}
END_TEST


Suite *
create_suite_SpeciesType (void)
{
  Suite *suite = suite_create("SpeciesType");
  TCase *tcase = tcase_create("SpeciesType");


  tcase_add_checked_fixture( tcase,
                             SpeciesTypeTest_setup,
                             SpeciesTypeTest_teardown );

  tcase_add_test( tcase, test_SpeciesType_create      );
  //tcase_add_test( tcase, test_SpeciesType_createWith  );
  tcase_add_test( tcase, test_SpeciesType_free_NULL   );
  tcase_add_test( tcase, test_SpeciesType_setId       );
  tcase_add_test( tcase, test_SpeciesType_setName     );
  tcase_add_test( tcase, test_SpeciesType_unsetName   );
  tcase_add_test( tcase, test_SpeciesType_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


