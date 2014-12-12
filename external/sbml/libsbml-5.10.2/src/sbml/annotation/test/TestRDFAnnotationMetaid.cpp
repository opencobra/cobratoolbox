/**
 * \file    TestRDFAnnotationMetaid.cpp
 * \brief   tests for setting appending annotation with/without metaid
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

#include <sbml/annotation/RDFAnnotationParser.h>
#include <sbml/annotation/ModelHistory.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

CK_CPPSTART


static Model *m;
static SBMLDocument* d;

extern char *TestDataDirectory;

/* 
 * tests the results from rdf annotations
 */



void
RDFAnnotationMetaid_setup (void)
{
  char *filename = safe_strcat(TestDataDirectory, "annotationL3_3.xml");

  // The following will return a pointer to a new SBMLDocument.
  d = readSBML(filename);
  m = d->getModel();
}


void
RDFAnnotationMetaid_teardown (void)
{
  delete d;
}

static bool
equals (const char* expected, const char* actual)
{
  if ( !strcmp(expected, actual) ) return true;

  printf( "\nStrings are not equal:\n"  );
  printf( "Expected:\n[%s]\n", expected );
  printf( "Actual:\n[%s]\n"  , actual   );

  return false;
}



START_TEST (test_RDFAnnotationMetaid_setAnnotation1)
{
  const char * rdfAnn =
    "<annotation>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"    <rdf:Description rdf:about=\"#_002\">\n"
    "      <dc:creator>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:parseType=\"Resource\">\n"
    "            <vCard:N rdf:parseType=\"Resource\">\n"
		"              <vCard:Family>Le Novere</vCard:Family>\n"
		"              <vCard:Given>Nicolas</vCard:Given>\n"
		"            </vCard:N>\n"
		"            <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"            <vCard:ORG rdf:parseType=\"Resource\">\n"
		"              <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"            </vCard:ORG>\n"
		"          </rdf:li>\n"
		"        </rdf:Bag>\n"
		"      </dc:creator>\n"
		"      <dcterms:created rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"      </dcterms:created>\n"
		"      <dcterms:modified rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"      </dcterms:modified>\n"
		"      <bqbiol:is>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"        </rdf:Bag>\n"
		"      </bqbiol:is>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";


  fail_unless(m->setAnnotation(rdfAnn) == LIBSBML_UNEXPECTED_ATTRIBUTE);

  fail_unless(m->getAnnotation() == NULL);

  m->setMetaId("_002");
  fail_unless(m->setAnnotation(rdfAnn) == LIBSBML_OPERATION_SUCCESS);

  fail_unless(m->getAnnotation() != NULL);

  fail_unless( equals(rdfAnn, m->getAnnotation()->toXMLString().c_str()));


}
END_TEST


START_TEST (test_RDFAnnotationMetaid_setAnnotation2)
{
  const char * rdfAnn =
    "<annotation>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"    <rdf:Description rdf:about=\"#_002\">\n"
    "      <dc:creator>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:parseType=\"Resource\">\n"
    "            <vCard:N rdf:parseType=\"Resource\">\n"
		"              <vCard:Family>Le Novere</vCard:Family>\n"
		"              <vCard:Given>Nicolas</vCard:Given>\n"
		"            </vCard:N>\n"
		"            <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"            <vCard:ORG rdf:parseType=\"Resource\">\n"
		"              <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"            </vCard:ORG>\n"
		"          </rdf:li>\n"
		"        </rdf:Bag>\n"
		"      </dc:creator>\n"
		"      <dcterms:created rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"      </dcterms:created>\n"
		"      <dcterms:modified rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"      </dcterms:modified>\n"
		"      <bqbiol:is>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"        </rdf:Bag>\n"
		"      </bqbiol:is>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";

  const char * expected =
    "<annotation>\n"
		"  <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"0\" BuildVersion=\"41\">\n"
		"    <jd2:header>\n"
		"      <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"      <jd2:ModelHeader Author=\"Mr Untitled\" ModelVersion=\"0.0\" ModelTitle=\"untitled\"/>\n"
		"      <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"10\" numberOfPoints=\"1000\"/>\n"
		"    </jd2:header>\n"
		"  </jd2:JDesignerLayout>\n"
    "</annotation>";

  Compartment * c = m->getCompartment(1);
  fail_unless(c->appendAnnotation(rdfAnn) == LIBSBML_UNEXPECTED_ATTRIBUTE);

  fail_unless( equals (expected, c->getAnnotation()->toXMLString().c_str()));


}
END_TEST


START_TEST (test_RDFAnnotationMetaid_setAnnotation3)
{
  const char * rdfAnn =
    "<annotation>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"    <rdf:Description rdf:about=\"#_003\">\n"
    "      <dc:creator>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:parseType=\"Resource\">\n"
    "            <vCard:N rdf:parseType=\"Resource\">\n"
		"              <vCard:Family>Le Novere</vCard:Family>\n"
		"              <vCard:Given>Nicolas</vCard:Given>\n"
		"            </vCard:N>\n"
		"            <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"            <vCard:ORG rdf:parseType=\"Resource\">\n"
		"              <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"            </vCard:ORG>\n"
		"          </rdf:li>\n"
		"        </rdf:Bag>\n"
		"      </dc:creator>\n"
		"      <dcterms:created rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"      </dcterms:created>\n"
		"      <dcterms:modified rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"      </dcterms:modified>\n"
		"      <bqbiol:is>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"        </rdf:Bag>\n"
		"      </bqbiol:is>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";


  Species *s = m->getSpecies(0);
  fail_unless(s->setAnnotation(rdfAnn) == LIBSBML_UNEXPECTED_ATTRIBUTE);

  fail_unless(s->getAnnotation() == NULL);

  s->setMetaId("_003");
  fail_unless(s->setAnnotation(rdfAnn) == LIBSBML_OPERATION_SUCCESS);

  fail_unless(s->getAnnotation() != NULL);

  fail_unless( equals(rdfAnn, s->getAnnotation()->toXMLString().c_str()));


}
END_TEST


Suite *
create_suite_RDFAnnotationMetaid (void)
{
  Suite *suite = suite_create("RDFAnnotationMetaid");
  TCase *tcase = tcase_create("RDFAnnotationMetaid");

  tcase_add_checked_fixture(tcase,
                            RDFAnnotationMetaid_setup,
                            RDFAnnotationMetaid_teardown);

  tcase_add_test(tcase, test_RDFAnnotationMetaid_setAnnotation1 );
  tcase_add_test(tcase, test_RDFAnnotationMetaid_setAnnotation2 );
  tcase_add_test(tcase, test_RDFAnnotationMetaid_setAnnotation3 );
  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND

