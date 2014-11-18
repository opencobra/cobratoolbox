/**
 * \file    TestReaction.c
 * \brief   SBML Reaction unit tests
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
#include <sbml/SBMLTypes.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Reaction_t *R;


void
ReactionTest_setup (void)
{
  R = Reaction_create(2, 4);

  if (R == NULL)
  {
    fail("Reaction_create() returned a NULL pointer.");
  }
}


void
ReactionTest_teardown (void)
{
  Reaction_free(R);
}


START_TEST (test_Reaction_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) R) == SBML_REACTION );
  fail_unless( SBase_getMetaId    ((SBase_t *) R) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) R) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) R) == NULL );

  fail_unless( Reaction_getId        (R) == NULL );
  fail_unless( Reaction_getName      (R) == NULL );
  fail_unless( Reaction_getKineticLaw(R) == NULL );
  fail_unless( Reaction_getReversible(R) != 0    );
  fail_unless( Reaction_getFast      (R) == 0    );

  fail_unless( !Reaction_isSetId        (R) );
  fail_unless( !Reaction_isSetName      (R) );
  fail_unless( !Reaction_isSetKineticLaw(R) );
  fail_unless( !Reaction_isSetFast        (R) );
  fail_unless( Reaction_isSetReversible        (R) );

  fail_unless( Reaction_getNumReactants(R) == 0 );
  fail_unless( Reaction_getNumProducts (R) == 0 );
  fail_unless( Reaction_getNumModifiers(R) == 0 );
}
END_TEST


//START_TEST (test_Reaction_createWith)
//{
//  KineticLaw_t *kl = KineticLaw_create(2, 4);
//  Reaction_t   *r  = Reaction_createWithKineticLaw("r1", "", kl, 0, 1);
//
//
//  fail_unless( SBase_getTypeCode  ((SBase_t *) r) == SBML_REACTION );
//  fail_unless( SBase_getMetaId    ((SBase_t *) r) == NULL );
//  fail_unless( SBase_getNotes     ((SBase_t *) r) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) r) == NULL );
//
//  fail_unless( Reaction_getName(r) == NULL );
//
//  fail_unless( !strcmp(Reaction_getId(r), "r1") );
//
//  //fail_unless( Reaction_getKineticLaw(r) == kl );
//  fail_unless( Reaction_getReversible(r) ==  0 );
//  fail_unless( Reaction_getFast      (r) ==  1 );
//
//  fail_unless( Reaction_isSetId        (r) );
//  fail_unless( !Reaction_isSetName     (r) );
//  fail_unless( Reaction_isSetKineticLaw(r) );
//
//  fail_unless( Reaction_getNumReactants(r) == 0 );
//  fail_unless( Reaction_getNumProducts (r) == 0 );
//  fail_unless( Reaction_getNumModifiers(r) == 0 );
//
//  KineticLaw_free(kl);
//  Reaction_free(r);
//}
//END_TEST


START_TEST (test_Reaction_free_NULL)
{
  Reaction_free(NULL);
}
END_TEST


START_TEST (test_Reaction_setId)
{
  const char *id = "J1";


  Reaction_setId(R, id);

  fail_unless( !strcmp(Reaction_getId(R), id) );
  fail_unless( Reaction_isSetId(R) );

  if (Reaction_getId(R) == id)
  {
    fail("Reaction_setId(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Reaction_setId(R, Reaction_getId(R));
  fail_unless( !strcmp(Reaction_getId(R), id) );

  Reaction_setId(R, NULL);
  fail_unless( !Reaction_isSetId(R) );

  if (Reaction_getId(R) != NULL)
  {
    fail("Reaction_setId(R, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Reaction_setName)
{
  const char *name = "MapK_Cascade";


  Reaction_setName(R, name);

  fail_unless( !strcmp(Reaction_getName(R), name) );
  fail_unless( Reaction_isSetName(R) );

  if (Reaction_getName(R) == name)
  {
    fail("Reaction_setName(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  Reaction_setName(R, Reaction_getName(R));
  fail_unless( !strcmp(Reaction_getName(R), name) );

  Reaction_setName(R, NULL);
  fail_unless( !Reaction_isSetName(R) );

  if (Reaction_getName(R) != NULL)
  {
    fail("Reaction_setName(R, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_Reaction_addReactant)
{
  SpeciesReference_t *sr = SpeciesReference_create(2, 4);
  SpeciesReference_setSpecies(sr, "s");
  Reaction_addReactant(R, sr);

  fail_unless( Reaction_getNumReactants(R) == 1 );
  fail_unless( Reaction_getNumProducts (R) == 0 );
  fail_unless( Reaction_getNumModifiers(R) == 0 );

  SpeciesReference_free(sr);
}
END_TEST


START_TEST (test_Reaction_addProduct)
{
  SpeciesReference_t *sr = SpeciesReference_create(2, 4);
  SpeciesReference_setSpecies(sr, "s");
  
  Reaction_addProduct(R, sr);

  fail_unless( Reaction_getNumReactants(R) == 0 );
  fail_unless( Reaction_getNumProducts (R) == 1 );
  fail_unless( Reaction_getNumModifiers(R) == 0 );

  SpeciesReference_free(sr);
}
END_TEST


START_TEST (test_Reaction_addModifier)
{
  SpeciesReference_t * msr = SpeciesReference_createModifier(2, 4);
  SpeciesReference_setSpecies(msr, "s");
  Reaction_addModifier(R, msr);

  fail_unless( Reaction_getNumReactants(R) == 0 );
  fail_unless( Reaction_getNumProducts (R) == 0 );
  fail_unless( Reaction_getNumModifiers(R) == 1 );
}
END_TEST


START_TEST (test_Reaction_getReactant)
{
  SpeciesReference_t *sr1 = SpeciesReference_create(2, 4);
  SpeciesReference_t *sr2 = SpeciesReference_create(2, 4);


  SpeciesReference_setSpecies(sr1, "R1");
  SpeciesReference_setSpecies(sr2, "R2");

  Reaction_addReactant(R, sr1);
  Reaction_addReactant(R, sr2);

  SpeciesReference_free(sr1);
  SpeciesReference_free(sr2);

  fail_unless( Reaction_getNumReactants(R) == 2 );
  fail_unless( Reaction_getNumProducts (R) == 0 );
  fail_unless( Reaction_getNumModifiers(R) == 0 );

  sr1 = Reaction_getReactant(R, 0);
  sr2 = Reaction_getReactant(R, 1);

  fail_unless( !strcmp(SpeciesReference_getSpecies(sr1), "R1") );
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr2), "R2") );


}
END_TEST


START_TEST (test_Reaction_getReactantById)
{
  SpeciesReference_t *sr1 = SpeciesReference_create(2, 4);
  SpeciesReference_setSpecies(sr1, "R1");
  SpeciesReference_t *sr2 = SpeciesReference_create(2, 4);
  SpeciesReference_setSpecies(sr2, "R2");


  Reaction_addReactant(R, sr1);
  Reaction_addReactant(R, sr2);

  fail_unless( Reaction_getNumReactants(R) == 2 );
  fail_unless( Reaction_getNumProducts (R) == 0 );
  fail_unless( Reaction_getNumModifiers(R) == 0 );

  fail_unless( Reaction_getReactantBySpecies(R, "R1") != sr1  );
  fail_unless( Reaction_getReactantBySpecies(R, "R2") != sr2  );
  fail_unless( Reaction_getReactantBySpecies(R, "R3") == NULL );

  SpeciesReference_free(sr1);
  SpeciesReference_free(sr2);
}
END_TEST


START_TEST (test_Reaction_getProduct)
{
  SpeciesReference_t *sr1 = SpeciesReference_create(2, 4);
  SpeciesReference_t *sr2 = SpeciesReference_create(2, 4);


  SpeciesReference_setSpecies(sr1, "P1");
  SpeciesReference_setSpecies(sr2, "P2");

  Reaction_addProduct(R, sr1);
  Reaction_addProduct(R, sr2);

  SpeciesReference_free(sr1);
  SpeciesReference_free(sr2);

  fail_unless( Reaction_getNumReactants(R) == 0 );
  fail_unless( Reaction_getNumProducts (R) == 2 );
  fail_unless( Reaction_getNumModifiers(R) == 0 );

  sr1 = Reaction_getProduct(R, 0);
  sr2 = Reaction_getProduct(R, 1);

  fail_unless( !strcmp(SpeciesReference_getSpecies(sr1), "P1") );
  fail_unless( !strcmp(SpeciesReference_getSpecies(sr2), "P2") );

}
END_TEST


START_TEST (test_Reaction_getProductById)
{
  SpeciesReference_t *sr1 = SpeciesReference_create(2, 4);
  SpeciesReference_setSpecies(sr1, "P1");
  SpeciesReference_t *sr2 = SpeciesReference_create(2, 4);
  SpeciesReference_setSpecies(sr2, "P1");


  Reaction_addProduct(R, sr1);
  Reaction_addProduct(R, sr2);

  fail_unless( Reaction_getNumReactants(R) == 0 );
  fail_unless( Reaction_getNumProducts (R) == 2 );
  fail_unless( Reaction_getNumModifiers(R) == 0 );

  fail_unless( Reaction_getProductBySpecies(R, "P1") != sr1  );
  fail_unless( Reaction_getProductBySpecies(R, "P2") != sr2  );
  fail_unless( Reaction_getProductBySpecies(R, "P3") == NULL );

  SpeciesReference_free(sr1);
  SpeciesReference_free(sr2);
}
END_TEST


START_TEST (test_Reaction_getModifier)
{
  SpeciesReference_t *msr1 = SpeciesReference_createModifier(2, 4);
  SpeciesReference_t *msr2 = SpeciesReference_createModifier(2, 4);


  SpeciesReference_setSpecies(msr1, "M1");
  SpeciesReference_setSpecies(msr2, "M2");

  Reaction_addModifier(R, msr1);
  Reaction_addModifier(R, msr2);

  SpeciesReference_free(msr1);
  SpeciesReference_free(msr2);

  fail_unless( Reaction_getNumReactants(R) == 0 );
  fail_unless( Reaction_getNumProducts (R) == 0 );
  fail_unless( Reaction_getNumModifiers(R) == 2 );

  msr1 = Reaction_getModifier(R, 0);
  msr2 = Reaction_getModifier(R, 1);

  fail_unless(!strcmp(SpeciesReference_getSpecies(msr1), "M1"));
  fail_unless(!strcmp(SpeciesReference_getSpecies(msr2), "M2"));
}
END_TEST


START_TEST (test_Reaction_getModifierById)
{
  SpeciesReference_t *msr1 = SpeciesReference_createModifier(2, 4);
  SpeciesReference_t *msr2 = SpeciesReference_createModifier(2, 4);


  SpeciesReference_setSpecies(msr1, "M1");
  SpeciesReference_setSpecies(msr2, "M2");


  Reaction_addModifier(R, msr1);
  Reaction_addModifier(R, msr2);

  fail_unless( Reaction_getNumReactants(R) == 0 );
  fail_unless( Reaction_getNumProducts (R) == 0 );
  fail_unless( Reaction_getNumModifiers(R) == 2 );

  fail_unless( Reaction_getModifierBySpecies(R, "M1") != msr1 );
  fail_unless( Reaction_getModifierBySpecies(R, "M2") != msr2 );
  fail_unless( Reaction_getModifierBySpecies(R, "M3") == NULL );
  
  SpeciesReference_free(msr1);
  SpeciesReference_free(msr2);
}
END_TEST


START_TEST (test_Reaction_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  Reaction_t *object = 
    Reaction_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_REACTION );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 1 );

  fail_unless( Reaction_getNamespaces     (object) != NULL );
  fail_unless( XMLNamespaces_getLength(Reaction_getNamespaces(object)) == 2 );

  Reaction_free(object);
}
END_TEST


START_TEST (test_Reaction_removeReactant)
{
  SpeciesReference_t *o1, *o2, *o3;

  o1 = Reaction_createReactant(R);
  o2 = Reaction_createReactant(R);
  o3 = Reaction_createReactant(R);
  SpeciesReference_setSpecies(o3,"test");

  fail_unless( Reaction_removeReactant(R,0) == o1 );
  fail_unless( Reaction_getNumReactants(R)  == 2  );
  fail_unless( Reaction_removeReactant(R,0) == o2 );
  fail_unless( Reaction_getNumReactants(R)  == 1  );
  fail_unless( Reaction_removeReactantBySpecies(R,"test") == o3 );
  fail_unless( Reaction_getNumReactants(R)  == 0  );

  SpeciesReference_free(o1);
  SpeciesReference_free(o2);
  SpeciesReference_free(o3);
}
END_TEST


START_TEST (test_Reaction_removeProduct)
{
  SpeciesReference_t *o1, *o2, *o3;

  o1 = Reaction_createProduct(R);
  o2 = Reaction_createProduct(R);
  o3 = Reaction_createProduct(R);
  SpeciesReference_setSpecies(o3,"test");

  fail_unless( Reaction_removeProduct(R,0) == o1 );
  fail_unless( Reaction_getNumProducts(R)  == 2  );
  fail_unless( Reaction_removeProduct(R,0) == o2 );
  fail_unless( Reaction_getNumProducts(R)  == 1  );
  fail_unless( Reaction_removeProductBySpecies(R,"test") == o3 );
  fail_unless( Reaction_getNumProducts(R)  == 0  );

  SpeciesReference_free(o1);
  SpeciesReference_free(o2);
  SpeciesReference_free(o3);
}
END_TEST


START_TEST (test_Reaction_removeModifier)
{
  SpeciesReference_t *o1, *o2, *o3;

   o1 = Reaction_createModifier(R);
   o2 = Reaction_createModifier(R);
   o3 = Reaction_createModifier(R);
  SpeciesReference_setSpecies(o3, "test");

  fail_unless( Reaction_removeModifier(R, 0) == o1 );
  fail_unless( Reaction_getNumModifiers(R)   == 2  );
  fail_unless( Reaction_removeModifier(R, 0) == o2 );
  fail_unless( Reaction_getNumModifiers(R)   == 1  );
  fail_unless( Reaction_removeModifierBySpecies(R,"test") == o3 );
  fail_unless( Reaction_getNumModifiers(R)   == 0  );

  SpeciesReference_free(o1);
  SpeciesReference_free(o2);
  SpeciesReference_free(o3);
}
END_TEST


Suite *
create_suite_Reaction (void)
{
  Suite *suite = suite_create("Reaction");
  TCase *tcase = tcase_create("Reaction");


  tcase_add_checked_fixture(tcase, ReactionTest_setup, ReactionTest_teardown);

  tcase_add_test( tcase, test_Reaction_create          );
  //tcase_add_test( tcase, test_Reaction_createWith      );
  tcase_add_test( tcase, test_Reaction_free_NULL       );
  tcase_add_test( tcase, test_Reaction_setId           );
  tcase_add_test( tcase, test_Reaction_setName         );
  tcase_add_test( tcase, test_Reaction_addReactant     );
  tcase_add_test( tcase, test_Reaction_addProduct      );
  tcase_add_test( tcase, test_Reaction_addModifier     );
  tcase_add_test( tcase, test_Reaction_getReactant     );
  tcase_add_test( tcase, test_Reaction_getReactantById );
  tcase_add_test( tcase, test_Reaction_getProduct      );
  tcase_add_test( tcase, test_Reaction_getProductById  );
  tcase_add_test( tcase, test_Reaction_getModifier     );
  tcase_add_test( tcase, test_Reaction_getModifierById );
  tcase_add_test( tcase, test_Reaction_createWithNS         );
  tcase_add_test( tcase, test_Reaction_removeReactant  );
  tcase_add_test( tcase, test_Reaction_removeProduct   );
  tcase_add_test( tcase, test_Reaction_removeModifier  );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

