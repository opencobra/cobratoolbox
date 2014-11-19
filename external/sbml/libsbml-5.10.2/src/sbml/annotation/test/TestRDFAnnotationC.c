/**
 * \file    TestRDFAnnotationC.c
 * \brief   RDFAnnotation parser unit tests
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
#include <sbml/common/extern.h>

#include <sbml/SBMLReader.h>
#include <sbml/SBMLTypes.h>

#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>
#include <sbml/SBMLTypeCodes.h>

#include <sbml/annotation/RDFAnnotation.h>
#include <sbml/annotation/ModelHistory.h>

#include <check.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

static Model_t *m;
static SBMLDocument_t* d;

extern char *TestDataDirectory;

/* 
 * tests the results from rdf annotations
 */

void
RDFAnnotation_C_setup (void)
{
  char *filename = safe_strcat(TestDataDirectory, "annotation.xml");

  // The following will return a pointer to a new SBMLDocument.
  d = readSBML(filename);
  m = SBMLDocument_getModel(d);
}


void
RDFAnnotation_C_teardown (void)
{
  SBMLDocument_free(d);
}

START_TEST (test_RDFAnnotation_C_getModelHistory)
{
  fail_if(m == NULL);

  ModelHistory_t * history = Model_getModelHistory(m);

  fail_unless(history != NULL);

  ModelCreator_t * mc = (ModelCreator_t * )
                               (ModelHistory_getCreator(history, 0));

  fail_unless(!strcmp(ModelCreator_getFamilyName(mc), "Le Novere"));
  fail_unless(!strcmp(ModelCreator_getGivenName(mc), "Nicolas"));
  fail_unless(!strcmp(ModelCreator_getEmail(mc), "lenov@ebi.ac.uk"));
  fail_unless(!strcmp(ModelCreator_getOrganisation(mc), "EMBL-EBI"));

  Date_t * date = ModelHistory_getCreatedDate(history);
  fail_unless(Date_getYear(date) == 2005);
  fail_unless(Date_getMonth(date) == 2);
  fail_unless(Date_getDay(date) == 2);
  fail_unless(Date_getHour(date) == 14);
  fail_unless(Date_getMinute(date) == 56);
  fail_unless(Date_getSecond(date) == 11);
  fail_unless(Date_getSignOffset(date) == 0);
  fail_unless(Date_getHoursOffset(date) == 0);
  fail_unless(Date_getMinutesOffset(date) == 0);
  fail_unless(!strcmp(Date_getDateAsString(date), "2005-02-02T14:56:11Z"));

  date = ModelHistory_getModifiedDate(history);
  fail_unless(Date_getYear(date) == 2006);
  fail_unless(Date_getMonth(date) == 5);
  fail_unless(Date_getDay(date) == 30);
  fail_unless(Date_getHour(date) == 10);
  fail_unless(Date_getMinute(date) == 46);
  fail_unless(Date_getSecond(date) == 2);
  fail_unless(Date_getSignOffset(date) == 0);
  fail_unless(Date_getHoursOffset(date) == 0);
  fail_unless(Date_getMinutesOffset(date) == 0);
  fail_unless(!strcmp(Date_getDateAsString(date), "2006-05-30T10:46:02Z"));
}
END_TEST


START_TEST (test_RDFAnnotation_C_parseModelHistory)
{
  XMLNode_t* node = RDFAnnotationParser_parseModelHistory((SBase_t *) m);

  fail_unless(XMLNode_getNumChildren(node) == 1);

  const XMLNode_t* rdf = XMLNode_getChild(node, 0);

  fail_unless(!strcmp(XMLNode_getName(rdf), "RDF"));
  fail_unless(!strcmp(XMLNode_getPrefix(rdf), "rdf"));
  fail_unless(!strcmp(XMLNode_getURI(rdf), "http://www.w3.org/1999/02/22-rdf-syntax-ns#"));
  fail_unless(XMLNode_getNumChildren(rdf) == 1);

  const XMLNode_t* desc = XMLNode_getChild(rdf, 0);
  
  fail_unless(!strcmp(XMLNode_getName(desc), "Description"));
  fail_unless(!strcmp(XMLNode_getPrefix(desc), "rdf"));
  fail_unless(!strcmp(XMLNode_getURI(desc), "http://www.w3.org/1999/02/22-rdf-syntax-ns#"));
  fail_unless(XMLNode_getNumChildren(desc) == 3);

  const XMLNode_t * creator = XMLNode_getChild(desc, 0);
  fail_unless(!strcmp(XMLNode_getName(creator), "creator"));
  fail_unless(!strcmp(XMLNode_getPrefix(creator), "dc"));
  fail_unless(!strcmp(XMLNode_getURI(creator), "http://purl.org/dc/elements/1.1/"));
  fail_unless(XMLNode_getNumChildren(creator) == 1);

  const XMLNode_t * Bag = XMLNode_getChild(creator, 0);
  fail_unless(!strcmp(XMLNode_getName(Bag), "Bag"));
  fail_unless(!strcmp(XMLNode_getPrefix(Bag), "rdf"));
  fail_unless(!strcmp(XMLNode_getURI(Bag), "http://www.w3.org/1999/02/22-rdf-syntax-ns#"));
  fail_unless(XMLNode_getNumChildren(Bag) == 1);

  const XMLNode_t * li = XMLNode_getChild(Bag, 0);
  fail_unless(!strcmp(XMLNode_getName(li), "li"));
  fail_unless(!strcmp(XMLNode_getPrefix(li), "rdf"));
  fail_unless(!strcmp(XMLNode_getURI(li), "http://www.w3.org/1999/02/22-rdf-syntax-ns#"));
  fail_unless(XMLNode_getNumChildren(li) == 3);


  const XMLNode_t *N = XMLNode_getChild(li, 0);
  fail_unless(!strcmp(XMLNode_getName(N), "N"));
  fail_unless(!strcmp(XMLNode_getPrefix(N), "vCard"));
  fail_unless(!strcmp(XMLNode_getURI(N), "http://www.w3.org/2001/vcard-rdf/3.0#"));
  fail_unless(XMLNode_getNumChildren(N) == 2);

  const XMLNode_t *Family = XMLNode_getChild(N, 0);
  fail_unless(!strcmp(XMLNode_getName(Family), "Family"));
  fail_unless(!strcmp(XMLNode_getPrefix(Family), "vCard"));
  fail_unless(!strcmp(XMLNode_getURI(Family), "http://www.w3.org/2001/vcard-rdf/3.0#"));
  fail_unless(XMLNode_getNumChildren(Family) == 1);


  const XMLNode_t *Given = XMLNode_getChild(N, 1);
  fail_unless(!strcmp(XMLNode_getName(Given), "Given"));
  fail_unless(!strcmp(XMLNode_getPrefix(Given), "vCard"));
  fail_unless(!strcmp(XMLNode_getURI(Given), "http://www.w3.org/2001/vcard-rdf/3.0#"));
  fail_unless(XMLNode_getNumChildren(Given) == 1);


  const XMLNode_t *EMAIL = XMLNode_getChild(li, 1);
  fail_unless(!strcmp(XMLNode_getName(EMAIL), "EMAIL"));
  fail_unless(!strcmp(XMLNode_getPrefix(EMAIL), "vCard"));
  fail_unless(!strcmp(XMLNode_getURI(EMAIL), "http://www.w3.org/2001/vcard-rdf/3.0#"));
  fail_unless(XMLNode_getNumChildren(EMAIL) == 1);

  const XMLNode_t *ORG = XMLNode_getChild(li, 2);
  fail_unless(!strcmp(XMLNode_getName(ORG), "ORG"));
  fail_unless(!strcmp(XMLNode_getPrefix(ORG), "vCard"));
  fail_unless(!strcmp(XMLNode_getURI(ORG), "http://www.w3.org/2001/vcard-rdf/3.0#"));
  fail_unless(XMLNode_getNumChildren(ORG) == 1);

  const XMLNode_t *Orgname = XMLNode_getChild(ORG, 0);
  fail_unless(!strcmp(XMLNode_getName(Orgname), "Orgname"));
  fail_unless(!strcmp(XMLNode_getPrefix(Orgname), "vCard"));
  fail_unless(!strcmp(XMLNode_getURI(Orgname), "http://www.w3.org/2001/vcard-rdf/3.0#"));
  fail_unless(XMLNode_getNumChildren(Orgname) == 1);

  const XMLNode_t * created = XMLNode_getChild(desc, 1);
  fail_unless(!strcmp(XMLNode_getName(created), "created"));
  fail_unless(!strcmp(XMLNode_getPrefix(created), "dcterms"));
  fail_unless(!strcmp(XMLNode_getURI(created), "http://purl.org/dc/terms/"));
  fail_unless(XMLNode_getNumChildren(created) == 1);

  const XMLNode_t * cr_date = XMLNode_getChild(created, 0);
  fail_unless(!strcmp(XMLNode_getName(cr_date), "W3CDTF"));
  fail_unless(!strcmp(XMLNode_getPrefix(cr_date), "dcterms"));
  fail_unless(!strcmp(XMLNode_getURI(cr_date), "http://purl.org/dc/terms/"));
  fail_unless(XMLNode_getNumChildren(cr_date) == 1);

  const XMLNode_t * modified = XMLNode_getChild(desc, 2);
  fail_unless(!strcmp(XMLNode_getName(modified), "modified"));
  fail_unless(!strcmp(XMLNode_getPrefix(modified), "dcterms"));
  fail_unless(!strcmp(XMLNode_getURI(modified), "http://purl.org/dc/terms/"));
  fail_unless(XMLNode_getNumChildren(modified) == 1);

  const XMLNode_t * mo_date = XMLNode_getChild(created, 0);
  fail_unless(!strcmp(XMLNode_getName(mo_date), "W3CDTF"));
  fail_unless(!strcmp(XMLNode_getPrefix(mo_date), "dcterms"));
  fail_unless(!strcmp(XMLNode_getURI(mo_date), "http://purl.org/dc/terms/"));
  fail_unless(XMLNode_getNumChildren(mo_date) == 1);


  XMLNode_free(node);

}
END_TEST

START_TEST (test_RDFAnnotation_C_parseCVTerms)
{
  SBase_t * obj = (SBase_t *) (Model_getCompartment(m, 0));
  XMLNode_t* node = RDFAnnotationParser_parseCVTerms(obj);

  fail_unless(XMLNode_getNumChildren(node) == 1);

  const XMLNode_t* rdf = XMLNode_getChild(node, 0);

  fail_unless(!strcmp(XMLNode_getName(rdf), "RDF"));
  fail_unless(!strcmp(XMLNode_getPrefix(rdf), "rdf"));
  fail_unless(!strcmp(XMLNode_getURI(rdf), "http://www.w3.org/1999/02/22-rdf-syntax-ns#"));
  fail_unless(XMLNode_getNumChildren(rdf) == 1);

  const XMLNode_t* desc = XMLNode_getChild(rdf, 0);
  
  fail_unless(!strcmp(XMLNode_getName(desc), "Description"));
  fail_unless(!strcmp(XMLNode_getPrefix(desc), "rdf"));
  fail_unless(!strcmp(XMLNode_getURI(desc), "http://www.w3.org/1999/02/22-rdf-syntax-ns#"));
  fail_unless(XMLNode_getNumChildren(desc) == 1);

  const XMLNode_t * is1 = XMLNode_getChild(desc, 0);
  fail_unless(!strcmp(XMLNode_getName(is1), "is"));
  fail_unless(!strcmp(XMLNode_getPrefix(is1), "bqbiol"));
  fail_unless(XMLNode_getNumChildren(is1) == 1);

  const XMLNode_t * Bag = XMLNode_getChild(is1, 0);
  fail_unless(!strcmp(XMLNode_getName(Bag), "Bag"));
  fail_unless(!strcmp(XMLNode_getPrefix(Bag), "rdf"));
  fail_unless(!strcmp(XMLNode_getURI(Bag), "http://www.w3.org/1999/02/22-rdf-syntax-ns#"));
  fail_unless(XMLNode_getNumChildren(Bag) == 4);

  const XMLNode_t * li = XMLNode_getChild(Bag, 0);
  fail_unless(!strcmp(XMLNode_getName(li), "li"));
  fail_unless(!strcmp(XMLNode_getPrefix(li), "rdf"));
  fail_unless(!strcmp(XMLNode_getURI(li), "http://www.w3.org/1999/02/22-rdf-syntax-ns#"));
  fail_unless(XMLNode_getNumChildren(li) == 0);

  const XMLNode_t * li1 = XMLNode_getChild(Bag, 1);
  fail_unless(!strcmp(XMLNode_getName(li1), "li"));
  fail_unless(!strcmp(XMLNode_getPrefix(li1), "rdf"));
  fail_unless(!strcmp(XMLNode_getURI(li1), "http://www.w3.org/1999/02/22-rdf-syntax-ns#"));
  fail_unless(XMLNode_getNumChildren(li1) == 0);

  const XMLNode_t * li2 = XMLNode_getChild(Bag, 2);
  fail_unless(!strcmp(XMLNode_getName(li2), "li"));
  fail_unless(!strcmp(XMLNode_getPrefix(li2), "rdf"));
  fail_unless(!strcmp(XMLNode_getURI(li2), "http://www.w3.org/1999/02/22-rdf-syntax-ns#"));
  fail_unless(XMLNode_getNumChildren(li2) == 0);

  const XMLNode_t * li3 = XMLNode_getChild(Bag, 3);
  fail_unless(!strcmp(XMLNode_getName(li3), "li"));
  fail_unless(!strcmp(XMLNode_getPrefix(li3), "rdf"));
  fail_unless(!strcmp(XMLNode_getURI(li3), "http://www.w3.org/1999/02/22-rdf-syntax-ns#"));
  fail_unless(XMLNode_getNumChildren(li3) == 0);

  XMLNode_free(node);
}
END_TEST

START_TEST (test_RDFAnnotation_C_delete)
{
  SBase_t * obj = (SBase_t *) (Model_getCompartment(m, 0));
  XMLNode_t* node = RDFAnnotationParser_parseCVTerms(obj);

  XMLNode_t* n1 = RDFAnnotationParser_deleteRDFAnnotation(node);

  fail_unless(XMLNode_getNumChildren(n1) == 0);
  fail_unless(!strcmp(XMLNode_getName(n1), "annotation"));

  XMLNode_free(node);
}
END_TEST

START_TEST (test_RDFAnnotation_C_accessWithNULL)
{
	fail_unless( RDFAnnotationParser_createCVTerms ( NULL ) == NULL );
	fail_unless( RDFAnnotationParser_createRDFDescription ( NULL ) == NULL );
	fail_unless( RDFAnnotationParser_deleteRDFAnnotation ( NULL ) == NULL );
	fail_unless( RDFAnnotationParser_parseCVTerms ( NULL ) == NULL );
	fail_unless( RDFAnnotationParser_parseModelHistory ( NULL ) == NULL );

	// ensure that we survive NULL arguments 
    RDFAnnotationParser_parseRDFAnnotation ( NULL, NULL );

	fail_unless( RDFAnnotationParser_parseRDFAnnotationWithModelHistory ( NULL ) == NULL );

}
END_TEST

Suite *
create_suite_RDFAnnotation_C (void)
{
  Suite *suite = suite_create("RDFAnnotation_C");
  TCase *tcase = tcase_create("RDFAnnotation_C");

  tcase_add_checked_fixture(tcase,
                            RDFAnnotation_C_setup,
                            RDFAnnotation_C_teardown);

  tcase_add_test(tcase, test_RDFAnnotation_C_getModelHistory );
  tcase_add_test(tcase, test_RDFAnnotation_C_parseModelHistory );
  tcase_add_test(tcase, test_RDFAnnotation_C_parseCVTerms );
  tcase_add_test(tcase, test_RDFAnnotation_C_delete );
  tcase_add_test(tcase, test_RDFAnnotation_C_accessWithNULL    );
  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif
