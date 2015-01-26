/**
 * \file    TestReaction_newSetters.p
 * \brief   Reaction unit tests for new set function API
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
#include <sbml/KineticLaw.h>
#include <sbml/SpeciesReference.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>
#include <sbml/math/FormulaParser.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static Reaction_t *R;


void
ReactionTest1_setup (void)
{
  R = Reaction_create(1, 2);

  if (R == NULL)
  {
    fail("Reaction_create() returned a NULL pointer.");
  }
}


void
ReactionTest1_teardown (void)
{
  Reaction_free(R);
}


START_TEST (test_Reaction_setId1)
{
  int i = Reaction_setId(R, "1cell");

  fail_unless( i == LIBSBML_INVALID_ATTRIBUTE_VALUE );
  fail_unless( !Reaction_isSetId(R) );
}
END_TEST


START_TEST (test_Reaction_setId2)
{
  int i = Reaction_setId(R, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Reaction_isSetId(R) );
  fail_unless( !strcmp(Reaction_getId(R), "cell" ));

  i = Reaction_setId(R, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Reaction_isSetId(R) );
}
END_TEST


START_TEST (test_Reaction_setName1)
{
  int i = Reaction_setName(R, "cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Reaction_isSetName(R) );

  i = Reaction_unsetName(R);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Reaction_isSetName(R) );
}
END_TEST


START_TEST (test_Reaction_setName2)
{
  Reaction_t *p = 
    Reaction_create(2, 2);

  int i = Reaction_setName(p, "1cell");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Reaction_isSetName(p) );

  i = Reaction_unsetName(p);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Reaction_isSetName(p) );

  Reaction_free(p);
}
END_TEST


START_TEST (test_Reaction_setName3)
{
  Reaction_t *p = 
    Reaction_create(2, 2);

  int i = Reaction_setName(p, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Reaction_isSetName(p) );

  Reaction_free(p);
}
END_TEST


START_TEST (test_Reaction_setFast1)
{
  int i = Reaction_setFast(R, 1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Reaction_getFast(R) == 1 );
  fail_unless( Reaction_isSetFast(R));

  i = Reaction_setFast(R, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Reaction_getFast(R) == 0 );
  fail_unless( Reaction_isSetFast(R));

  i = Reaction_unsetFast(R);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Reaction_getFast(R) == 0 );
  fail_unless( !Reaction_isSetFast(R));
}
END_TEST


START_TEST (test_Reaction_setFast2)
{
  Reaction_t *R1 = Reaction_create(2, 4);
  int i = Reaction_unsetFast(R1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Reaction_getFast(R1) == 0 );
  fail_unless( !Reaction_isSetFast(R1));
}
END_TEST


START_TEST (test_Reaction_setReversible1)
{
  int i = Reaction_setReversible(R, 1);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Reaction_getReversible(R) == 1 );

  i = Reaction_setReversible(R, 0);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Reaction_getReversible(R) == 0 );
}
END_TEST


START_TEST (test_Reaction_setKineticLaw1)
{
  KineticLaw_t *kl = 
    KineticLaw_create(2, 1);
  KineticLaw_setMath(kl, SBML_parseFormula("1"));

  int i = Reaction_setKineticLaw(R, kl);

  fail_unless( i == LIBSBML_LEVEL_MISMATCH );
  fail_unless( !Reaction_isSetKineticLaw(R) );

  KineticLaw_free(kl);
}
END_TEST


START_TEST (test_Reaction_setKineticLaw2)
{
  KineticLaw_t *kl = 
    KineticLaw_create(1, 1);
  KineticLaw_setMath(kl, SBML_parseFormula("1"));

  int i = Reaction_setKineticLaw(R, kl);

  fail_unless( i == LIBSBML_VERSION_MISMATCH );
  fail_unless( !Reaction_isSetKineticLaw(R) );

  KineticLaw_free(kl);
}
END_TEST


START_TEST (test_Reaction_setKineticLaw3)
{
  KineticLaw_t *kl = 
    KineticLaw_create(1, 2);
  KineticLaw_setMath(kl, SBML_parseFormula("1"));

  int i = Reaction_setKineticLaw(R, kl);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( Reaction_isSetKineticLaw(R) );

  KineticLaw_free(kl);
}
END_TEST


START_TEST (test_Reaction_setKineticLaw4)
{
  int i = Reaction_setKineticLaw(R, NULL);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Reaction_isSetKineticLaw(R) );

  i = Reaction_unsetKineticLaw(R);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS );
  fail_unless( !Reaction_isSetKineticLaw(R) );
}
END_TEST


START_TEST (test_Reaction_addReactant1)
{
  Reaction_t *m = Reaction_create(2, 2);
  SpeciesReference_t *p 
    = SpeciesReference_create(2, 2);
  SpeciesReference_t *p1 
    = SpeciesReference_create(2, 2);
  SpeciesReference_setSpecies(p1, "k");
  SpeciesReference_setId(p1, "k1");

  int i = Reaction_addReactant(m, p);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  SpeciesReference_setSpecies(p, "k");
  SpeciesReference_setId(p, "k1");
  i = Reaction_addReactant(m, p);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Reaction_getNumReactants(m) == 1);

  i = Reaction_addReactant(m, p1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Reaction_getNumReactants(m) == 1);
  
  SpeciesReference_free(p1);
  SpeciesReference_free(p);
  Reaction_free(m);
}
END_TEST


START_TEST (test_Reaction_addReactant2)
{
  Reaction_t *m = Reaction_create(2, 2);
  SpeciesReference_t *p 
    = SpeciesReference_create(2, 1);
  SpeciesReference_setSpecies(p, "k");

  int i = Reaction_addReactant(m, p);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Reaction_getNumReactants(m) == 0);

  SpeciesReference_free(p);
  Reaction_free(m);
}
END_TEST


START_TEST (test_Reaction_addReactant3)
{
  Reaction_t *m = Reaction_create(2, 2);
  SpeciesReference_t *p 
    = SpeciesReference_create(1, 2);
  SpeciesReference_setSpecies(p, "k");

  int i = Reaction_addReactant(m, p);

  fail_unless( i == LIBSBML_LEVEL_MISMATCH);
  fail_unless( Reaction_getNumReactants(m) == 0);

  SpeciesReference_free(p);
  Reaction_free(m);
}
END_TEST


START_TEST (test_Reaction_addReactant4)
{
  Reaction_t *m = Reaction_create(2, 2);
  SpeciesReference_t *p = NULL; 

  int i = Reaction_addReactant(m, p);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Reaction_getNumReactants(m) == 0);

  Reaction_free(m);
}
END_TEST



START_TEST (test_Reaction_addProduct1)
{
  Reaction_t *m = Reaction_create(2, 2);
  SpeciesReference_t *p 
    = SpeciesReference_create(2, 2);
  SpeciesReference_t *p1 
    = SpeciesReference_create(2, 2);
  SpeciesReference_setSpecies(p1, "k");
  SpeciesReference_setId(p1, "k1");

  int i = Reaction_addProduct(m, p);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  SpeciesReference_setSpecies(p, "k");
  SpeciesReference_setId(p, "k1");
  i = Reaction_addProduct(m, p);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Reaction_getNumProducts(m) == 1);

  i = Reaction_addProduct(m, p1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Reaction_getNumProducts(m) == 1);

  SpeciesReference_free(p);
  SpeciesReference_free(p1);
  Reaction_free(m);
}
END_TEST


START_TEST (test_Reaction_addProduct2)
{
  Reaction_t *m = Reaction_create(2, 2);
  SpeciesReference_t *p 
    = SpeciesReference_create(2, 1);
  SpeciesReference_setSpecies(p, "k");

  int i = Reaction_addProduct(m, p);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Reaction_getNumProducts(m) == 0);

  SpeciesReference_free(p);
  Reaction_free(m);
}
END_TEST


START_TEST (test_Reaction_addProduct3)
{
  Reaction_t *m = Reaction_create(2, 2);
  SpeciesReference_t *p 
    = SpeciesReference_create(1, 2);
  SpeciesReference_setSpecies(p, "k");

  int i = Reaction_addProduct(m, p);

  fail_unless( i == LIBSBML_LEVEL_MISMATCH);
  fail_unless( Reaction_getNumProducts(m) == 0);

  SpeciesReference_free(p);
  Reaction_free(m);
}
END_TEST


START_TEST (test_Reaction_addProduct4)
{
  Reaction_t *m = Reaction_create(2, 2);
  SpeciesReference_t *p = NULL; 

  int i = Reaction_addProduct(m, p);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Reaction_getNumProducts(m) == 0);

  Reaction_free(m);
}
END_TEST



START_TEST (test_Reaction_addModifier1)
{
  Reaction_t *m = Reaction_create(2, 2);
  SpeciesReference_t *p 
    = SpeciesReference_createModifier(2, 2);
  SpeciesReference_t *p1 
    = SpeciesReference_createModifier(2, 2);
  SpeciesReference_setSpecies(p1, "k");
  SpeciesReference_setId(p1, "k1");

  int i = Reaction_addModifier(m, p);

  fail_unless( i == LIBSBML_INVALID_OBJECT);
  
  SpeciesReference_setSpecies(p, "k");
  SpeciesReference_setId(p, "k1");
  i = Reaction_addModifier(m, p);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( Reaction_getNumModifiers(m) == 1);

  i = Reaction_addModifier(m, p1);

  fail_unless( i == LIBSBML_DUPLICATE_OBJECT_ID);
  fail_unless( Reaction_getNumModifiers(m) == 1);

  SpeciesReference_free(p);
  SpeciesReference_free(p1);
  Reaction_free(m);
}
END_TEST


START_TEST (test_Reaction_addModifier2)
{
  Reaction_t *m = Reaction_create(2, 2);
  SpeciesReference_t *p 
    = SpeciesReference_createModifier(2, 1);
  SpeciesReference_setSpecies(p, "k");

  int i = Reaction_addModifier(m, p);

  fail_unless( i == LIBSBML_VERSION_MISMATCH);
  fail_unless( Reaction_getNumModifiers(m) == 0);

  SpeciesReference_free(p);
  Reaction_free(m);
}
END_TEST


START_TEST (test_Reaction_addModifier3)
{
  Reaction_t *m = Reaction_create(2, 2);
  SpeciesReference_t *p = NULL; 

  int i = Reaction_addModifier(m, p);

  fail_unless( i == LIBSBML_OPERATION_FAILED);
  fail_unless( Reaction_getNumModifiers(m) == 0);

  Reaction_free(m);
}
END_TEST


START_TEST (test_Reaction_createReactant)
{
  Reaction_t *m = Reaction_create(2, 2);
  
  SpeciesReference_t *p = Reaction_createReactant(m);

  fail_unless( Reaction_getNumReactants(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Reaction_free(m);
}
END_TEST


START_TEST (test_Reaction_createProduct)
{
  Reaction_t *m = Reaction_create(2, 2);
  
  SpeciesReference_t *p = Reaction_createProduct(m);

  fail_unless( Reaction_getNumProducts(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Reaction_free(m);
}
END_TEST


START_TEST (test_Reaction_createModifier)
{
  Reaction_t *m = Reaction_create(2, 2);
  
  SpeciesReference_t *p = Reaction_createModifier(m);

  fail_unless( Reaction_getNumModifiers(m) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (p)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (p)) == 2 );

  Reaction_free(m);
}
END_TEST


START_TEST (test_Reaction_createKineticLaw)
{
  Reaction_t *r = Reaction_create(2, 2);
  
  KineticLaw_t *kl = Reaction_createKineticLaw(r);

  fail_unless( Reaction_isSetKineticLaw(r) == 1);
  fail_unless( SBase_getLevel((SBase_t *) (kl)) == 2 );
  fail_unless( SBase_getVersion((SBase_t *) (kl)) == 2 );

  Reaction_free(r);
}
END_TEST


Suite *
create_suite_Reaction_newSetters (void)
{
  Suite *suite = suite_create("Reaction_newSetters");
  TCase *tcase = tcase_create("Reaction_newSetters");


  tcase_add_checked_fixture( tcase,
                             ReactionTest1_setup,
                             ReactionTest1_teardown );

  tcase_add_test( tcase, test_Reaction_setId1       );
  tcase_add_test( tcase, test_Reaction_setId2       );
  tcase_add_test( tcase, test_Reaction_setName1       );
  tcase_add_test( tcase, test_Reaction_setName2       );
  tcase_add_test( tcase, test_Reaction_setName3       );
  tcase_add_test( tcase, test_Reaction_setReversible1       );
  tcase_add_test( tcase, test_Reaction_setFast1       );
  tcase_add_test( tcase, test_Reaction_setFast2       );
  tcase_add_test( tcase, test_Reaction_setKineticLaw1       );
  tcase_add_test( tcase, test_Reaction_setKineticLaw2       );
  tcase_add_test( tcase, test_Reaction_setKineticLaw3       );
  tcase_add_test( tcase, test_Reaction_setKineticLaw4       );
  tcase_add_test( tcase, test_Reaction_addReactant1       );
  tcase_add_test( tcase, test_Reaction_addReactant2       );
  tcase_add_test( tcase, test_Reaction_addReactant3       );
  tcase_add_test( tcase, test_Reaction_addReactant4       );
  tcase_add_test( tcase, test_Reaction_addProduct1       );
  tcase_add_test( tcase, test_Reaction_addProduct2       );
  tcase_add_test( tcase, test_Reaction_addProduct3       );
  tcase_add_test( tcase, test_Reaction_addProduct4       );
  tcase_add_test( tcase, test_Reaction_addModifier1       );
  tcase_add_test( tcase, test_Reaction_addModifier2       );
  tcase_add_test( tcase, test_Reaction_addModifier3       );
  tcase_add_test( tcase, test_Reaction_createReactant     );
  tcase_add_test( tcase, test_Reaction_createProduct     );
  tcase_add_test( tcase, test_Reaction_createModifier     );
  tcase_add_test( tcase, test_Reaction_createKineticLaw       );


  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS

