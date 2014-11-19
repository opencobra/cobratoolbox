/**
 * \file    TestL3Reaction.c
 * \brief   L3 Reaction unit tests
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
#include <sbml/Reaction.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Reaction_t *R;


void
L3ReactionTest_setup (void)
{
  R = Reaction_create(3, 1);

  if (R == NULL)
  {
    fail("Reaction_create(3, 1) returned a NULL pointer.");
  }
}


void
L3ReactionTest_teardown (void)
{
  Reaction_free(R);
}


START_TEST (test_L3_Reaction_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) R) == SBML_REACTION );
  fail_unless( SBase_getMetaId    ((SBase_t *) R) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) R) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) R) == NULL );

  fail_unless( Reaction_getId     (R) == NULL );
  fail_unless( Reaction_getName   (R) == NULL );
  fail_unless( Reaction_getCompartment  (R) == NULL );
  fail_unless( Reaction_getFast(R) == 0   );
  fail_unless( Reaction_getReversible(R) == 1   );

  fail_unless( !Reaction_isSetId     (R) );
  fail_unless( !Reaction_isSetName   (R) );
  fail_unless( !Reaction_isSetCompartment (R) );
  fail_unless( !Reaction_isSetFast  (R) );
  fail_unless( !Reaction_isSetReversible(R) );
}
END_TEST


START_TEST (test_L3_Reaction_free_NULL)
{
  Reaction_free(NULL);
}
END_TEST


START_TEST (test_L3_Reaction_id)
{
  const char *id = "mitochondria";


  fail_unless( !Reaction_isSetId(R) );
  
  Reaction_setId(R, id);

  fail_unless( !strcmp(Reaction_getId(R), id) );
  fail_unless( Reaction_isSetId(R) );

  if (Reaction_getId(R) == id)
  {
    fail("Reaction_setId(...) did not make a copy of string.");
  }
}
END_TEST


START_TEST (test_L3_Reaction_name)
{
  const char *name = "My_Favorite_Factory";


  fail_unless( !Reaction_isSetName(R) );

  Reaction_setName(R, name);

  fail_unless( !strcmp(Reaction_getName(R), name) );
  fail_unless( Reaction_isSetName(R) );

  if (Reaction_getName(R) == name)
  {
    fail("Reaction_setName(...) did not make a copy of string.");
  }

  Reaction_unsetName(R);
  
  fail_unless( !Reaction_isSetName(R) );

  if (Reaction_getName(R) != NULL)
  {
    fail("Reaction_unsetName(R) did not clear string.");
  }
}
END_TEST


START_TEST (test_L3_Reaction_compartment)
{
  const char *compartment = "cell";


  fail_unless( !Reaction_isSetCompartment(R) );
  
  Reaction_setCompartment(R, compartment);

  fail_unless( !strcmp(Reaction_getCompartment(R), compartment) );
  fail_unless( Reaction_isSetCompartment(R) );

  if (Reaction_getCompartment(R) == compartment)
  {
    fail("Reaction_setCompartment(...) did not make a copy of string.");
  }

  Reaction_unsetCompartment(R);
  
  fail_unless( !Reaction_isSetCompartment(R) );

  if (Reaction_getCompartment(R) != NULL)
  {
    fail("Reaction_unsetCompartment(R, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_L3_Reaction_fast)
{
  fail_unless(Reaction_isSetFast(R) == 0);

  Reaction_setFast(R, 1);

  fail_unless(Reaction_getFast(R) == 1);
  fail_unless(Reaction_isSetFast(R) == 1);

  Reaction_setFast(R, 0);

  fail_unless(Reaction_getFast(R) == 0);
  fail_unless(Reaction_isSetFast(R) == 1);

}
END_TEST


START_TEST (test_L3_Reaction_reversible)
{
  fail_unless(Reaction_isSetReversible(R) == 0);

  Reaction_setReversible(R, 1);

  fail_unless(Reaction_getReversible(R) == 1);
  fail_unless(Reaction_isSetReversible(R) == 1);

  Reaction_setReversible(R, 0);

  fail_unless(Reaction_getReversible(R) == 0);
  fail_unless(Reaction_isSetReversible(R) == 1);

}
END_TEST


START_TEST (test_L3_Reaction_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(3,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  Reaction_t *r = 
    Reaction_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) r) == SBML_REACTION );
  fail_unless( SBase_getMetaId    ((SBase_t *) r) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) r) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) r) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) r) == 3 );
  fail_unless( SBase_getVersion     ((SBase_t *) r) == 1 );

  fail_unless( Reaction_getNamespaces     (r) != NULL );
  fail_unless( XMLNamespaces_getLength(Reaction_getNamespaces(r)) == 2 );


  fail_unless( Reaction_getId     (r) == NULL );
  fail_unless( Reaction_getName   (r) == NULL );
  fail_unless( Reaction_getCompartment  (r) == NULL );
  fail_unless( Reaction_getFast(r) == 0   );
  fail_unless( Reaction_getReversible(r) == 1   );

  fail_unless( !Reaction_isSetId     (r) );
  fail_unless( !Reaction_isSetName   (r) );
  fail_unless( !Reaction_isSetCompartment (r) );
  fail_unless( !Reaction_isSetFast  (r) );
  fail_unless( !Reaction_isSetReversible(r) );

  Reaction_free(r);
}
END_TEST


START_TEST (test_L3_Reaction_hasRequiredAttributes )
{
  Reaction_t *r = Reaction_create (3, 1);

  fail_unless ( !Reaction_hasRequiredAttributes(r));

  Reaction_setId(r, "id");

  fail_unless ( !Reaction_hasRequiredAttributes(r));

  Reaction_setFast(r, 0);

  fail_unless ( !Reaction_hasRequiredAttributes(r));

  Reaction_setReversible(r, 0);

  fail_unless ( Reaction_hasRequiredAttributes(r));

  Reaction_free(r);
}
END_TEST


START_TEST (test_L3_Reaction_NS)
{
  fail_unless( Reaction_getNamespaces     (R) != NULL );
  fail_unless( XMLNamespaces_getLength(Reaction_getNamespaces(R)) == 1 );
  fail_unless( !strcmp( XMLNamespaces_getURI(Reaction_getNamespaces(R), 0),
    "http://www.sbml.org/sbml/level3/version1/core"));
}
END_TEST


Suite *
create_suite_L3_Reaction (void)
{
  Suite *suite = suite_create("L3_Reaction");
  TCase *tcase = tcase_create("L3_Reaction");


  tcase_add_checked_fixture( tcase,
                             L3ReactionTest_setup,
                             L3ReactionTest_teardown );

  tcase_add_test( tcase, test_L3_Reaction_create              );
  tcase_add_test( tcase, test_L3_Reaction_free_NULL           );
  tcase_add_test( tcase, test_L3_Reaction_id               );
  tcase_add_test( tcase, test_L3_Reaction_name             );
  tcase_add_test( tcase, test_L3_Reaction_compartment            );
  tcase_add_test( tcase, test_L3_Reaction_fast      );
  tcase_add_test( tcase, test_L3_Reaction_reversible);
  tcase_add_test( tcase, test_L3_Reaction_createWithNS         );
  tcase_add_test( tcase, test_L3_Reaction_hasRequiredAttributes        );
  tcase_add_test( tcase, test_L3_Reaction_NS              );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

