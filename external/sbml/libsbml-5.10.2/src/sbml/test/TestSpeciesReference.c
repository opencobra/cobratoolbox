/**
 * \file    TestSpeciesReference.c
 * \brief   SpeciesReference unit tests
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

#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/FormulaParser.h>

#include <sbml/SBase.h>
#include <sbml/SpeciesReference.h>
#include <sbml/StoichiometryMath.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/SBMLDocument.h>

#include <check.h>



#include <sbml/common/extern.h>

LIBSBML_CPP_NAMESPACE_USE


BEGIN_C_DECLS

static SpeciesReference_t *SR;


void
SpeciesReferenceTest_setup (void)
{
  SR = SpeciesReference_create(2, 4);

  if (SR == NULL)
  {
    fail("SpeciesReference_create() returned a NULL pointer.");
  }
}


void
SpeciesReferenceTest_teardown (void)
{
  SpeciesReference_free(SR);
}


START_TEST (test_SpeciesReference_create)
{
  fail_unless( SBase_getTypeCode  ((SBase_t *) SR) == SBML_SPECIES_REFERENCE );
  fail_unless( SBase_getMetaId    ((SBase_t *) SR) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) SR) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) SR) == NULL );

  fail_unless( SpeciesReference_getSpecies          (SR) == NULL );
  fail_unless( SpeciesReference_getStoichiometry    (SR) == 1    );
  fail_unless( SpeciesReference_getStoichiometryMath(SR) == NULL );
  fail_unless( SpeciesReference_getDenominator      (SR) == 1    );

  fail_unless( !SpeciesReference_isSetSpecies(SR) );
  fail_unless( !SpeciesReference_isSetStoichiometryMath(SR) );
}
END_TEST


//START_TEST (test_SpeciesReference_createWith)
//{
//  SpeciesReference_t *sr = SpeciesReference_createWithSpeciesAndStoichiometry("s3", 4, 2);
//
//
//  fail_unless( SBase_getTypeCode  ((SBase_t *) sr) == SBML_SPECIES_REFERENCE );
//  fail_unless( SBase_getMetaId    ((SBase_t *) sr) == NULL );
//  fail_unless( SBase_getNotes     ((SBase_t *) sr) == NULL );
//  fail_unless( SBase_getAnnotation((SBase_t *) sr) == NULL );
//
//  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "s3") );
//
//  fail_unless( SpeciesReference_getStoichiometry(sr) == 4    );
//  fail_unless( SpeciesReference_getDenominator  (sr) == 2    );
//
//  fail_unless( SpeciesReference_isSetSpecies(sr) );
//
//  SpeciesReference_free(sr);
//}
//END_TEST


START_TEST (test_SpeciesReference_createModifier)
{
  SpeciesReference_t *sr = 
    SpeciesReference_createModifier(2, 4);


  fail_unless( SBase_getTypeCode  ((SBase_t *) sr) == SBML_MODIFIER_SPECIES_REFERENCE );
  fail_unless( SBase_getMetaId    ((SBase_t *) sr) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) sr) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) sr) == NULL );

  fail_unless( SpeciesReference_isModifier(sr));
  SpeciesReference_free(sr);
}
END_TEST


START_TEST (test_SpeciesReference_free_NULL)
{
  SpeciesReference_free(NULL);
}
END_TEST


START_TEST (test_SpeciesReference_setSpecies)
{
  const char *species = "X0";


  SpeciesReference_setSpecies(SR, species);

  fail_unless( !strcmp(SpeciesReference_getSpecies(SR), species) );
  fail_unless( SpeciesReference_isSetSpecies(SR) );

  if (SpeciesReference_getSpecies(SR) == species)
  {
    fail("SpeciesReference_setSpecies(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  SpeciesReference_setSpecies(SR, SpeciesReference_getSpecies(SR));
  fail_unless( !strcmp(SpeciesReference_getSpecies(SR), species) );

  SpeciesReference_setSpecies(SR, NULL);
  fail_unless( !SpeciesReference_isSetSpecies(SR) );

  if (SpeciesReference_getSpecies(SR) != NULL)
  {
    fail("SpeciesReference_setSpecies(SR, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_SpeciesReference_setId)
{
  const char *species = "X0";


  SpeciesReference_setId(SR, species);

  fail_unless( !strcmp(SpeciesReference_getId(SR), species) );
  fail_unless( SpeciesReference_isSetId(SR) );

  if (SpeciesReference_getId(SR) == species)
  {
    fail("SpeciesReference_setId(...) did not make a copy of string.");
  }

  /* Reflexive case (pathological) */
  SpeciesReference_setId(SR, SpeciesReference_getId(SR));
  fail_unless( !strcmp(SpeciesReference_getId(SR), species) );

  SpeciesReference_setId(SR, NULL);
  fail_unless( !SpeciesReference_isSetId(SR) );

  if (SpeciesReference_getId(SR) != NULL)
  {
    fail("SpeciesReference_setId(SR, NULL) did not clear string.");
  }
}
END_TEST


START_TEST (test_SpeciesReference_setStoichiometryMath)
{
  const ASTNode_t *math = SBML_parseFormula("k3 / k2");

  StoichiometryMath_t *stoich = StoichiometryMath_create(2, 4);
  StoichiometryMath_setMath(stoich, math);
  const StoichiometryMath_t * math1;
  char * formula;


  SpeciesReference_setStoichiometryMath(SR, stoich);

  math1 = SpeciesReference_getStoichiometryMath(SR);
  fail_unless( math1 != NULL );

  formula = SBML_formulaToString(StoichiometryMath_getMath(math1));
  fail_unless( formula != NULL );
  fail_unless( !strcmp(formula, "k3 / k2") );

  fail_unless( SpeciesReference_isSetStoichiometryMath(SR) );

  safe_free(formula);

}
END_TEST


START_TEST (test_SpeciesReference_createWithNS )
{
  XMLNamespaces_t *xmlns = XMLNamespaces_create();
  XMLNamespaces_add(xmlns, "http://www.sbml.org", "testsbml");
  SBMLNamespaces_t *sbmlns = SBMLNamespaces_create(2,1);
  SBMLNamespaces_addNamespaces(sbmlns,xmlns);

  SpeciesReference_t *object = 
    SpeciesReference_createWithNS (sbmlns);


  fail_unless( SBase_getTypeCode  ((SBase_t *) object) == SBML_SPECIES_REFERENCE );
  fail_unless( SBase_getMetaId    ((SBase_t *) object) == NULL );
  fail_unless( SBase_getNotes     ((SBase_t *) object) == NULL );
  fail_unless( SBase_getAnnotation((SBase_t *) object) == NULL );

  fail_unless( SBase_getLevel       ((SBase_t *) object) == 2 );
  fail_unless( SBase_getVersion     ((SBase_t *) object) == 1 );

  fail_unless( SpeciesReference_getNamespaces     (object) != NULL );
  fail_unless( XMLNamespaces_getLength(
                      SpeciesReference_getNamespaces(object)) == 2 );

  SpeciesReference_free(object);
}
END_TEST


Suite *
create_suite_SpeciesReference (void)
{
  Suite *suite = suite_create("SpeciesReference");
  TCase *tcase = tcase_create("SpeciesReference");


  tcase_add_checked_fixture( tcase,
                             SpeciesReferenceTest_setup,
                             SpeciesReferenceTest_teardown );

  tcase_add_test( tcase, test_SpeciesReference_create               );
  //tcase_add_test( tcase, test_SpeciesReference_createWith           );
  tcase_add_test( tcase, test_SpeciesReference_createModifier           );
  tcase_add_test( tcase, test_SpeciesReference_free_NULL            );
  tcase_add_test( tcase, test_SpeciesReference_setSpecies           );
  tcase_add_test( tcase, test_SpeciesReference_setId           );
  tcase_add_test( tcase, test_SpeciesReference_setStoichiometryMath );
  tcase_add_test( tcase, test_SpeciesReference_createWithNS         );

  suite_add_tcase(suite, tcase);

  return suite;
}

END_C_DECLS


