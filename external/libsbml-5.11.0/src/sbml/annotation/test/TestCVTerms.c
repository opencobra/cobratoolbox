/**
 * \file    TestCVTerms.cpp
 * \brief   CVTerms unit tests
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
#include <sbml/annotation/CVTerm.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLTriple.h>

#include <check.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif



START_TEST (test_CVTerm_create)
{
  CVTerm_t *term = CVTerm_createWithQualifierType(MODEL_QUALIFIER);

  fail_unless(term != NULL);
  fail_unless(CVTerm_getQualifierType(term) == MODEL_QUALIFIER);
  CVTerm_free(term);

}
END_TEST

START_TEST (test_CVTerm_set_get)
{
  CVTerm_t *term = CVTerm_createWithQualifierType(MODEL_QUALIFIER);

  fail_unless(term != NULL);
  fail_unless(CVTerm_getQualifierType(term) == MODEL_QUALIFIER);
  
  CVTerm_setModelQualifierType(term, BQM_IS);

  fail_unless(term != NULL);
  fail_unless(CVTerm_getQualifierType(term) == MODEL_QUALIFIER);
  fail_unless(CVTerm_getModelQualifierType(term) == BQM_IS);

  fail_unless(strcmp( ModelQualifierType_toString (CVTerm_getModelQualifierType(term)), "is" ) == 0);
  CVTerm_setModelQualifierTypeByString( term, "isDerivedFrom");
  
  fail_unless(CVTerm_getModelQualifierType(term) == BQM_IS_DERIVED_FROM);  

  CVTerm_setModelQualifierTypeByString( term, NULL);
  
  fail_unless(CVTerm_getModelQualifierType(term) == BQM_UNKNOWN);  
  

  CVTerm_setQualifierType(term, BIOLOGICAL_QUALIFIER);
  CVTerm_setBiologicalQualifierType( term, BQB_IS);

  fail_unless(CVTerm_getQualifierType(term) == BIOLOGICAL_QUALIFIER);
  fail_unless(CVTerm_getBiologicalQualifierType(term) == BQB_IS);

  fail_unless(strcmp( BiolQualifierType_toString (CVTerm_getBiologicalQualifierType(term)), "is" ) == 0);
  CVTerm_setBiologicalQualifierTypeByString( term, "encodes");

  fail_unless(CVTerm_getBiologicalQualifierType(term) == BQB_ENCODES);

  CVTerm_setBiologicalQualifierTypeByString( term, NULL);
  fail_unless(CVTerm_getBiologicalQualifierType(term) == BQB_UNKNOWN);
  
  
  CVTerm_free(term);
}
END_TEST

START_TEST (test_CVTerm_createFromNode)
{
  XMLAttributes_t * xa;
  XMLTriple_t * qual_triple = XMLTriple_createWith ("is", "", "bqbiol");
  XMLTriple_t * bag_triple = XMLTriple_create ();
  XMLTriple_t * li_triple = XMLTriple_create();
  XMLAttributes_t * att = XMLAttributes_create ();
  XMLAttributes_add(att, "", "This is my resource");
  XMLAttributes_t *att1 = XMLAttributes_create();

  XMLToken_t * li_token = XMLToken_createWithTripleAttr(li_triple, att);
  XMLToken_t * bag_token = XMLToken_createWithTripleAttr(bag_triple, att1);
  XMLToken_t * qual_token = XMLToken_createWithTripleAttr(qual_triple, att1);

  XMLNode_t * li = XMLNode_createFromToken(li_token);
  XMLNode_t * bag = XMLNode_createFromToken(bag_token);
  XMLNode_t * node = XMLNode_createFromToken(qual_token);

  XMLNode_addChild(bag, li);
  XMLNode_addChild(node, bag);

  CVTerm_t *term = CVTerm_createFromNode(node);

  fail_unless(term != NULL);
  fail_unless(CVTerm_getQualifierType(term) == BIOLOGICAL_QUALIFIER);
  fail_unless(CVTerm_getBiologicalQualifierType(term) == BQB_IS);

  xa = CVTerm_getResources(term);

  fail_unless(XMLAttributes_getLength(xa) == 1);
  
  char * name = XMLAttributes_getName(xa, 0);
  char * value = XMLAttributes_getValue(xa, 0);
  
  fail_unless(!strcmp(name, "rdf:resource"));
  fail_unless(!strcmp(value, "This is my resource"));

  free(name);
  free(value);

  XMLTriple_free(qual_triple);
  XMLTriple_free(bag_triple);
  XMLTriple_free(li_triple);
  XMLToken_free(li_token);
  XMLToken_free(bag_token);
  XMLToken_free(qual_token);
  XMLAttributes_free(att);
  XMLAttributes_free(att1);
  CVTerm_free(term);
  XMLNode_free(node);
  XMLNode_free(bag);
  XMLNode_free(li);
}
END_TEST

START_TEST (test_CVTerm_addResource)
{
  CVTerm_t *term = CVTerm_createWithQualifierType(MODEL_QUALIFIER);
  const char * resource = "GO6666";
  XMLAttributes_t *xa;

  fail_unless(term != NULL);
  fail_unless(CVTerm_getQualifierType(term) == MODEL_QUALIFIER);
  
  CVTerm_addResource(term, resource);

  xa = CVTerm_getResources(term);

  fail_unless(XMLAttributes_getLength(xa) == 1);

  char * name = XMLAttributes_getName(xa, 0);
  char * value = XMLAttributes_getValue(xa, 0);
  
  fail_unless(!strcmp(name, "rdf:resource"));
  fail_unless(!strcmp(value, "GO6666"));

  free(name);
  free(value);
  
  CVTerm_free(term);
}
END_TEST


START_TEST (test_CVTerm_getResources)
{
  CVTerm_t *term = CVTerm_createWithQualifierType(MODEL_QUALIFIER);
  const char * resource = "GO6666";
  const char * resource1 = "OtherURI";
  unsigned int number;
  
  CVTerm_addResource(term, resource);
  CVTerm_addResource(term, resource1);

  number = CVTerm_getNumResources(term);

  fail_unless(number == 2);

  char * res1 = CVTerm_getResourceURI(term, 0);
  char * res2 = CVTerm_getResourceURI(term, 1);

  fail_unless(!strcmp(res1, "GO6666"));
  fail_unless(!strcmp(res2, "OtherURI"));

  free(res1);
  free(res2);
  
  CVTerm_free(term);
}
END_TEST

START_TEST (test_CVTerm_accessWithNULL)
{
	fail_unless (CVTerm_addResource(NULL, NULL) == LIBSBML_OPERATION_FAILED);
	fail_unless (CVTerm_clone(NULL) == NULL);
	fail_unless (CVTerm_createFromNode(NULL) == NULL);

	// make sure we don't crash on freeing nothing
    CVTerm_free(NULL);

	fail_unless (CVTerm_getBiologicalQualifierType(NULL) == BQB_UNKNOWN);
	fail_unless (CVTerm_getModelQualifierType(NULL) == BQM_UNKNOWN);
	fail_unless (CVTerm_getNumResources(NULL) == SBML_INT_MAX);
	fail_unless (CVTerm_getQualifierType(NULL) == UNKNOWN_QUALIFIER);
	fail_unless (CVTerm_getResources(NULL) == NULL);
	fail_unless (CVTerm_getResourceURI(NULL, 0) == NULL);
	fail_unless (CVTerm_hasRequiredAttributes(NULL) == 0);
	fail_unless (CVTerm_removeResource(NULL, NULL) == LIBSBML_INVALID_OBJECT);
	fail_unless (CVTerm_setBiologicalQualifierType(NULL, BQB_UNKNOWN) == LIBSBML_INVALID_OBJECT);
	fail_unless (CVTerm_setBiologicalQualifierTypeByString(NULL, NULL) == LIBSBML_INVALID_OBJECT);  
	fail_unless (CVTerm_setModelQualifierType(NULL, BQM_UNKNOWN) == LIBSBML_INVALID_OBJECT);
	fail_unless (CVTerm_setModelQualifierTypeByString(NULL, NULL) == LIBSBML_INVALID_OBJECT);
	fail_unless (CVTerm_setQualifierType(NULL, UNKNOWN_QUALIFIER) == LIBSBML_INVALID_OBJECT);
	
  fail_unless (ModelQualifierType_fromString(NULL) == BQM_UNKNOWN);
	fail_unless (BiolQualifierType_fromString(NULL) == BQB_UNKNOWN);
}
END_TEST

START_TEST (test_CVTerm_get_biol_qualifiers)
{
  fail_unless (BiolQualifierType_fromString("is") == BQB_IS);
  fail_unless (BiolQualifierType_fromString("hasPart") == BQB_HAS_PART);
  fail_unless (BiolQualifierType_fromString("isPartOf") == BQB_IS_PART_OF);
  fail_unless (BiolQualifierType_fromString("isVersionOf") == BQB_IS_VERSION_OF);
  fail_unless (BiolQualifierType_fromString("hasVersion") == BQB_HAS_VERSION);
  fail_unless (BiolQualifierType_fromString("isHomologTo") == BQB_IS_HOMOLOG_TO);
  fail_unless (BiolQualifierType_fromString("isDescribedBy") == BQB_IS_DESCRIBED_BY);
  fail_unless (BiolQualifierType_fromString("isEncodedBy") == BQB_IS_ENCODED_BY);
  fail_unless (BiolQualifierType_fromString("encodes") == BQB_ENCODES);
  fail_unless (BiolQualifierType_fromString("occursIn") == BQB_OCCURS_IN);
  fail_unless (BiolQualifierType_fromString("hasProperty") == BQB_HAS_PROPERTY);
  fail_unless (BiolQualifierType_fromString("isPropertyOf") == BQB_IS_PROPERTY_OF);
  fail_unless (BiolQualifierType_fromString("isUnknown") == BQB_UNKNOWN);
  fail_unless (BiolQualifierType_fromString("xxx") == BQB_UNKNOWN);

  fail_unless (strcmp(BiolQualifierType_toString(BQB_IS), "is") == 0);
  fail_unless (strcmp(BiolQualifierType_toString(BQB_HAS_PART), "hasPart") == 0);
  fail_unless (strcmp(BiolQualifierType_toString(BQB_IS_PART_OF), "isPartOf") == 0);
  fail_unless (strcmp(BiolQualifierType_toString(BQB_IS_VERSION_OF), "isVersionOf") == 0);
  fail_unless (strcmp(BiolQualifierType_toString(BQB_HAS_VERSION), "hasVersion") == 0);
  fail_unless (strcmp(BiolQualifierType_toString(BQB_IS_HOMOLOG_TO), "isHomologTo") == 0);
  fail_unless (strcmp(BiolQualifierType_toString(BQB_IS_DESCRIBED_BY), "isDescribedBy") == 0);
  fail_unless (strcmp(BiolQualifierType_toString(BQB_IS_ENCODED_BY), "isEncodedBy") == 0);
  fail_unless (strcmp(BiolQualifierType_toString(BQB_ENCODES), "encodes") == 0);
  fail_unless (strcmp(BiolQualifierType_toString(BQB_OCCURS_IN), "occursIn") == 0);
  fail_unless (strcmp(BiolQualifierType_toString(BQB_HAS_PROPERTY), "hasProperty") == 0);
  fail_unless (strcmp(BiolQualifierType_toString(BQB_IS_PROPERTY_OF), "isPropertyOf") == 0);
  fail_unless (BiolQualifierType_toString(BQB_UNKNOWN) ==  NULL); 
}
END_TEST

START_TEST (test_CVTerm_get_model_qualifiers)
{
  
  fail_unless (ModelQualifierType_fromString("is") == BQM_IS);
  fail_unless (ModelQualifierType_fromString("isDescribedBy") == BQM_IS_DESCRIBED_BY);
  fail_unless (ModelQualifierType_fromString("isDerivedFrom") == BQM_IS_DERIVED_FROM);
  fail_unless (ModelQualifierType_fromString("isUnknown") == BQM_UNKNOWN);
  fail_unless (ModelQualifierType_fromString("xxx") == BQM_UNKNOWN);

  fail_unless (strcmp(ModelQualifierType_toString(BQM_IS), "is") == 0);
  fail_unless (strcmp(ModelQualifierType_toString(BQM_IS_DESCRIBED_BY), "isDescribedBy") == 0);
  fail_unless (strcmp(ModelQualifierType_toString(BQM_IS_DERIVED_FROM), "isDerivedFrom") == 0);
  fail_unless (ModelQualifierType_toString(BQM_UNKNOWN) ==  NULL);
  
}
END_TEST

Suite *
create_suite_CVTerms (void)
{
  Suite *suite = suite_create("CVTerms");
  TCase *tcase = tcase_create("CVTerms");

  tcase_add_test( tcase, test_CVTerm_create               );
  tcase_add_test( tcase, test_CVTerm_set_get              );
  tcase_add_test( tcase, test_CVTerm_addResource          );
  tcase_add_test( tcase, test_CVTerm_createFromNode       );
  tcase_add_test( tcase, test_CVTerm_getResources         );
  tcase_add_test( tcase, test_CVTerm_accessWithNULL       );
  tcase_add_test( tcase, test_CVTerm_get_biol_qualifiers  );
  tcase_add_test( tcase, test_CVTerm_get_model_qualifiers );
  suite_add_tcase(suite, tcase);

  return suite;
};


#if defined(__cplusplus)
CK_CPPEND
#endif

