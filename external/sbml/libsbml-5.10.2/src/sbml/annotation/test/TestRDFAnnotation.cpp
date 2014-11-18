/**
 * \file    TestRDFAnnotation.cpp
 * \brief   fomula units data unit tests
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
#include <sbml/common/extern.h>

#include <sbml/SBMLReader.h>
#include <sbml/SBMLTypes.h>

#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>
#include <sbml/SBMLTypeCodes.h>

#include <sbml/annotation/RDFAnnotation.h>
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
RDFAnnotation_setup (void)
{
  char *filename = safe_strcat(TestDataDirectory, "annotation.xml");

  // The following will return a pointer to a new SBMLDocument.
  d = readSBML(filename);
  m = d->getModel();
}


void
RDFAnnotation_teardown (void)
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
START_TEST (test_invalid_user_annotation)
{

  // does not get logged for l2v1
  // changed so it does log warning in l2v1
  const char* invalidL2V1 = "<?xml version='1.0' encoding='UTF-8'?>\n"
      "<sbml xmlns='http://www.sbml.org/sbml/level2'\n"
      " level='2'\n"
      " version='1'>\n"
      "  <annotation>\n"
      "    Created by The MathWorks, Inc. SimBiology tool, Version 4.0\n"
      "  </annotation>\n"
      "  <model id='trial_spatial' name='trial_spatial'>\n"
      "    <listOfCompartments>\n"
      "      <compartment id='cytosol' constant='true' size='1'/>\n"
      "    </listOfCompartments>\n"
      "  </model>\n"
      "</sbml>\n";

  SBMLDocument * doc = readSBMLFromString(invalidL2V1);
  int numErrors = doc->getNumErrors();
  fail_unless(numErrors == 1);
  delete doc;

  const char* invalidL2V2 = "<?xml version='1.0' encoding='UTF-8'?>\n"
      "<sbml xmlns='http://www.sbml.org/sbml/level2/version2'\n"
      " level='2'\n"
      " version='2'>\n"
      "  <annotation>\n"
      "    Created by The MathWorks, Inc. SimBiology tool, Version 4.0\n"
      "  </annotation>\n"
      "  <model id='trial_spatial' name='trial_spatial'>\n"
      "    <listOfCompartments>\n"
      "      <compartment id='cytosol' constant='true' size='1'/>\n"
      "    </listOfCompartments>\n"
      "  </model>\n"
      "</sbml>\n";

  // but for l2v2 and above
  doc = readSBMLFromString(invalidL2V2);
  numErrors = doc->getNumErrors();
  fail_unless(numErrors == 1);
  fail_unless(doc->getErrorLog()->contains(AnnotationNotElement));
  delete doc;
}
END_TEST



START_TEST (test_RDFAnnotation_getModelHistory)
{
  fail_if(m == NULL);

  ModelHistory * history = m->getModelHistory();

  fail_unless(history != NULL);

  ModelCreator * mc = (ModelCreator * )(history->getCreator(0));

  fail_unless(!strcmp(ModelCreator_getFamilyName(mc), "Le Novere"));
  fail_unless(!strcmp(ModelCreator_getGivenName(mc), "Nicolas"));
  fail_unless(!strcmp(ModelCreator_getEmail(mc), "lenov@ebi.ac.uk"));
  fail_unless(!strcmp(ModelCreator_getOrganisation(mc), "EMBL-EBI"));

  Date * date = history->getCreatedDate();
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

  date = history->getModifiedDate();
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


START_TEST (test_RDFAnnotation_parseModelHistory)
{
  XMLNode* node = RDFAnnotationParser::parseModelHistory(m);

  fail_unless(node->getNumChildren() == 1);

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


  delete node;

}
END_TEST

START_TEST (test_RDFAnnotation_parseCVTerms)
{
  XMLNode* node = RDFAnnotationParser::parseCVTerms(m->getCompartment(0));

  fail_unless(node->getNumChildren() == 1);

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

  delete node;

  XMLNode* node1 = RDFAnnotationParser::parseCVTerms(NULL);

  fail_unless(node1 == NULL);

  node1 = RDFAnnotationParser::createCVTerms(NULL);

  fail_unless(node1 == NULL);  
  
  // no metaid
  node1 = RDFAnnotationParser::parseCVTerms(m->getCompartment(2));

  fail_unless(node1 == NULL);

  node1 = RDFAnnotationParser::createCVTerms(m->getCompartment(2));

  fail_unless(node1 == NULL);

  // no cvterms
  node1 = RDFAnnotationParser::parseCVTerms(m);

  fail_unless(node1 == NULL);

  node1 = RDFAnnotationParser::createCVTerms(m);

  fail_unless(node1 == NULL);

  // null cvterms
  Compartment *c = new Compartment(3,1);
  c->setMetaId("_002");

  node1 = RDFAnnotationParser::parseCVTerms(c);

  fail_unless(node1 == NULL);

  node1 = RDFAnnotationParser::createCVTerms(c);

  fail_unless(node1 == NULL);

  CVTerm *cv = new CVTerm(BIOLOGICAL_QUALIFIER);
  cv->setBiologicalQualifierType(BiolQualifierType_t(23));
  cv->addResource("http://myres");

  c->addCVTerm(cv);

  node1 = RDFAnnotationParser::createCVTerms(c);

  fail_unless(node1 == NULL);

  delete c;

  Model *m1 = new Model(3,1);
  m1->setMetaId("_002");

  cv = new CVTerm(MODEL_QUALIFIER);
  cv->setModelQualifierType(ModelQualifierType_t(23));
  cv->addResource("http://myres");

  m1->addCVTerm(cv);

  node1 = RDFAnnotationParser::createCVTerms(m1);

  fail_unless(node1 == NULL);


}
END_TEST

START_TEST (test_RDFAnnotation_delete)
{
  XMLNode* node = RDFAnnotationParser::parseCVTerms(m->getCompartment(0));

  XMLNode* n1 = RDFAnnotationParser::deleteRDFAnnotation(node);

  const char * expected = "<annotation/>";

  fail_unless(n1->getNumChildren() == 0);
  fail_unless(n1->getName() == "annotation");

  fail_unless( equals(expected, n1->toXMLString().c_str()) );

  delete node;
}
END_TEST


START_TEST (test_RDFAnnotation_deleteWithOther)
{
  Compartment* c = m->getCompartment(1);

  XMLNode* node = RDFAnnotationParser::deleteRDFAnnotation(c->getAnnotation());
  const char * expected = "<annotation>\n"
		"  <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"0\" BuildVersion=\"41\">\n"
		"    <jd2:header>\n"
		"      <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"      <jd2:ModelHeader Author=\"Mr Untitled\" ModelVersion=\"0.0\" ModelTitle=\"untitled\"/>\n"
		"      <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"10\" numberOfPoints=\"1000\"/>\n"
		"    </jd2:header>\n"
		"  </jd2:JDesignerLayout>\n"
    "</annotation>";

  fail_unless( equals(expected,node->toXMLString().c_str()) );

}
END_TEST


START_TEST (test_RDFAnnotation_deleteWithOutOther)
{
  Compartment* c = m->getCompartment(2);

  XMLNode* node = c->getAnnotation();
  const char * expected = "<annotation>\n"
		"  <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"0\" BuildVersion=\"41\">\n"
		"    <jd2:header>\n"
		"      <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"      <jd2:ModelHeader Author=\"Mr Untitled\" ModelVersion=\"0.0\" ModelTitle=\"untitled\"/>\n"
		"      <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"10\" numberOfPoints=\"1000\"/>\n"
		"    </jd2:header>\n"
		"  </jd2:JDesignerLayout>\n"
    "</annotation>";


  fail_unless( equals(expected, node->toXMLString().c_str()) );

}
END_TEST


START_TEST (test_RDFAnnotation_deleteWithOtherRDF)
{
  Compartment* c = m->getCompartment(5);

  XMLNode* node = c->getAnnotation();
  const char * expected = "<annotation>\n"
		"  <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"0\" BuildVersion=\"41\">\n"
		"    <jd2:header>\n"
		"      <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"      <jd2:ModelHeader Author=\"Mr Untitled\" ModelVersion=\"0.0\" ModelTitle=\"untitled\"/>\n"
		"      <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"10\" numberOfPoints=\"1000\"/>\n"
		"    </jd2:header>\n"
		"  </jd2:JDesignerLayout>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"    <rdf:Description>\n"
    "      <rdf:other/>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";


  fail_unless( equals(expected, node->toXMLString().c_str()) );

}
END_TEST


#include <sbml/SBMLTypes.h>

START_TEST (test_RDFAnnotation_testAnnotationForMetaId)
{

  SBMLDocument doc(3, 1);
  Model* model = doc.createModel();
  fail_unless(model != NULL);
  
  model->setId("test1");
    
  CVTerm term (MODEL_QUALIFIER);
  term.addResource("testResource");
  term.setModelQualifierType(BQM_IS);
  
  model->setMetaId("t1");
  model->addCVTerm(&term);
  
  // unset metaid ... now we have potentially dangling RDF
  model->setMetaId("");
  std::string test = model->toSBML();

  // this should be the test
  fail_unless(test == "<model id=\"test1\"/>");   

}
END_TEST

#include <sbml/xml/XMLInputStream.h>
  
START_TEST (test_RDFAnnotation_testMissingAbout)
{

 const char * withAbout =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000004\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * emptyAbout =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * noAbout =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description>\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 List *cvTerms = new List();
 XMLInputStream stream(withAbout,false);
 XMLNode node(stream);
 RDFAnnotationParser::parseRDFAnnotation( &node, cvTerms );

 // regular parsing
 fail_unless( cvTerms->getSize() == 1 );
 
 // test parsing for specific meta id
 cvTerms = new List();
 RDFAnnotationParser::parseRDFAnnotation( &node, cvTerms, "_000004" );
 fail_unless( cvTerms->getSize() == 1 );

 // test parsing for a non-existing meta id
 cvTerms = new List();
 RDFAnnotationParser::parseRDFAnnotation( &node, cvTerms, "badMetaId" );
 fail_unless( cvTerms->getSize() == 0 );


 // now the test with empty about 
 cvTerms = new List();

 XMLInputStream stream1(emptyAbout,false);
 XMLNode node1(stream1);
 RDFAnnotationParser::parseRDFAnnotation( &node1, cvTerms );

 fail_unless( cvTerms->getSize() == 0 );
 
 // now the test with empty about 
 cvTerms = new List();

 XMLInputStream stream2(noAbout,false);
 XMLNode node2(stream2);
 RDFAnnotationParser::parseRDFAnnotation( &node2, cvTerms );

 fail_unless( cvTerms->getSize() == 0 );

}
END_TEST


START_TEST (test_RDFAnnotation_testMissingMetaId)
{

  SBMLDocument doc(3, 1);
  Model* model = doc.createModel();
  fail_unless(model != NULL);
  
  model->setId("test1");
    
  CVTerm term (MODEL_QUALIFIER);
  term.addResource("testResource");
  term.setModelQualifierType(BQM_IS);
  
  model->setMetaId("t1");
  model->addCVTerm(&term);
  
  // unset metaid ... now we have potentially dangling RDF
  model->setMetaId("");
  std::string test = model->toSBML();

  // this should be the test
  fail_unless(test == "<model id=\"test1\"/>");   

}
END_TEST


START_TEST (test_RDFAnnotation_testHasRDFAnnotation)
{

 const char * notAnnotation =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <ann>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000004\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </ann>";

  const char * withRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"a\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * noRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
    "    <otherns/>\n"
    "  </annotation>";

  fail_unless(RDFAnnotationParser::hasRDFAnnotation(NULL) == false);

  XMLInputStream stream(notAnnotation,false);
  XMLNode node(stream);

  fail_unless(RDFAnnotationParser::hasRDFAnnotation(&node) == false);

  XMLInputStream stream1(withRDF,false);
  XMLNode node1(stream1);

  fail_unless(RDFAnnotationParser::hasRDFAnnotation(&node1) == true);
  
  XMLInputStream stream2(noRDF,false);
  XMLNode node2(stream2);

  fail_unless(RDFAnnotationParser::hasRDFAnnotation(&node2) == false);

}
END_TEST


START_TEST (test_RDFAnnotation_testHasAdditionalRDFAnnotation)
{

 const char * addRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000004\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * withRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"a\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * withRDF1 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"a\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * otherRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"a\">\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * noRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
    "    <otherns/>\n"
    "  </annotation>";

  fail_unless(RDFAnnotationParser::hasAdditionalRDFAnnotation(NULL) == false);

  XMLInputStream stream(noRDF,false);
  XMLNode node(stream);

  fail_unless(RDFAnnotationParser::hasAdditionalRDFAnnotation(&node) == false);

  XMLInputStream stream1(withRDF,false);
  XMLNode node1(stream1);

  fail_unless(RDFAnnotationParser::hasAdditionalRDFAnnotation(&node1) == false);
  
  XMLInputStream stream2(withRDF1,false);
  XMLNode node2(stream2);

  fail_unless(RDFAnnotationParser::hasAdditionalRDFAnnotation(&node2) == false);

  XMLInputStream stream3(addRDF,false);
  XMLNode node3(stream3);

  fail_unless(RDFAnnotationParser::hasAdditionalRDFAnnotation(&node3) == true);

  XMLInputStream stream4(otherRDF,false);
  XMLNode node4(stream4);

  fail_unless(RDFAnnotationParser::hasAdditionalRDFAnnotation(&node4) == true);

}
END_TEST


START_TEST (test_RDFAnnotation_testHasCVTermRDFAnnotation)
{

 const char * addRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000004\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 const char * addRDF1 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000004\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 const char * addRDF2 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000004\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 const char * withRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"a\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * withRDF1 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"a\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * withRDF2 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"a\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * otherRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"a\">\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * noRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
    "    <otherns/>\n"
    "  </annotation>";

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(NULL) == false);

  XMLInputStream stream(noRDF,false);
  XMLNode node(stream);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node) == false);

  XMLInputStream stream1(withRDF,false);
  XMLNode node1(stream1);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node1) == true);
  
  XMLInputStream stream2(withRDF1,false);
  XMLNode node2(stream2);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node2) == false);

  XMLInputStream stream3(addRDF,false);
  XMLNode node3(stream3);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node3) == true);

  XMLInputStream stream4(otherRDF,false);
  XMLNode node4(stream4);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node4) == false);

  XMLInputStream stream5(addRDF1,false);
  XMLNode node5(stream5);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node5) == false);

  XMLInputStream stream6(addRDF2,false);
  XMLNode node6(stream6);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node6) == true);

  XMLInputStream stream7(withRDF2,false);
  XMLNode node7(stream7);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node7) == true);

}
END_TEST


START_TEST (test_RDFAnnotation_testHasHistoryRDFAnnotation)
{

 const char * addRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000004\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 const char * addRDF1 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000004\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 const char * addRDF2 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000004\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * withRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"a\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * withRDF1 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"a\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 const char * withRDF2 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000004\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * otherRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"a\">\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * noRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
    "    <otherns/>\n"
    "  </annotation>";

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(NULL) == false);

  XMLInputStream stream(noRDF,false);
  XMLNode node(stream);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node) == false);

  XMLInputStream stream1(withRDF,false);
  XMLNode node1(stream1);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node1) == false);
  
  XMLInputStream stream2(withRDF1,false);
  XMLNode node2(stream2);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node2) == true);

  XMLInputStream stream3(addRDF,false);
  XMLNode node3(stream3);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node3) == false);

  XMLInputStream stream4(otherRDF,false);
  XMLNode node4(stream4);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node4) == false);

  XMLInputStream stream5(addRDF1,false);
  XMLNode node5(stream5);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node5) == true);

    XMLInputStream stream6(addRDF2,false);
  XMLNode node6(stream6);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node6) == true);

  XMLInputStream stream7(withRDF2,false);
  XMLNode node7(stream7);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node7) == true);

}
END_TEST


START_TEST (test_RDFAnnotation_testHasCVTermRDFAnnotationBadAbout)
{

 const char * addRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 const char * addRDF1 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 const char * addRDF2 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description>\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 const char * withRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * withRDF1 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description>\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * withRDF2 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * otherRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * noRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
    "    <otherns/>\n"
    "  </annotation>";

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(NULL) == false);

  XMLInputStream stream(noRDF,false);
  XMLNode node(stream);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node) == false);

  XMLInputStream stream1(withRDF,false);
  XMLNode node1(stream1);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node1) == true);
  
  XMLInputStream stream2(withRDF1,false);
  XMLNode node2(stream2);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node2) == false);

  XMLInputStream stream3(addRDF,false);
  XMLNode node3(stream3);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node3) == true);

  XMLInputStream stream4(otherRDF,false);
  XMLNode node4(stream4);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node4) == false);

  XMLInputStream stream5(addRDF1,false);
  XMLNode node5(stream5);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node5) == false);

  XMLInputStream stream6(addRDF2,false);
  XMLNode node6(stream6);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node6) == true);

  XMLInputStream stream7(withRDF2,false);
  XMLNode node7(stream7);

  fail_unless(RDFAnnotationParser::hasCVTermRDFAnnotation(&node7) == true);

}
END_TEST


START_TEST (test_RDFAnnotation_testHasHistoryRDFAnnotationBadAbout)
{

 const char * addRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 const char * addRDF1 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 const char * addRDF2 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description>\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * withRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * withRDF1 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description>\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

 const char * withRDF2 =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"\">\n"
    "        <dc:creator>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG rdf:parseType=\"Resource\">\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11Z</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02Z</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * otherRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  const char * noRDF =
    "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    "  <annotation>\n"
    "    <otherns/>\n"
    "  </annotation>";

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(NULL) == false);

  XMLInputStream stream(noRDF,false);
  XMLNode node(stream);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node) == false);

  XMLInputStream stream1(withRDF,false);
  XMLNode node1(stream1);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node1) == false);
  
  XMLInputStream stream2(withRDF1,false);
  XMLNode node2(stream2);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node2) == true);

  XMLInputStream stream3(addRDF,false);
  XMLNode node3(stream3);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node3) == false);

  XMLInputStream stream4(otherRDF,false);
  XMLNode node4(stream4);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node4) == false);

  XMLInputStream stream5(addRDF1,false);
  XMLNode node5(stream5);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node5) == true);

    XMLInputStream stream6(addRDF2,false);
  XMLNode node6(stream6);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node6) == true);

  XMLInputStream stream7(withRDF2,false);
  XMLNode node7(stream7);

  fail_unless(RDFAnnotationParser::hasHistoryRDFAnnotation(&node7) == true);

}
END_TEST


START_TEST (test_RDFAnnotation_testCreateAnnotations)
{
  XMLNode *ann = RDFAnnotationParser::createAnnotation();

  fail_unless(ann != NULL);
  fail_unless(ann->getName() == "annotation");
  fail_unless(ann->getAttributes().getLength() == 0);
  fail_unless(ann->getNumChildren() == 0);

  delete ann;

  XMLNode * ann1 = RDFAnnotationParser::createRDFAnnotation();
  
  fail_unless(ann1 != NULL);
  fail_unless(ann1->getName() == "RDF");
  fail_unless(ann1->getPrefix() == "rdf");
  fail_unless(ann1->getAttributes().getLength() == 0);
  fail_unless(ann1->getNumChildren() == 0);
  fail_unless(ann1->getNamespaces().getLength() == 6);
  fail_unless(ann1->getNamespaceURI(0) == "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
  fail_unless(ann1->getNamespaceURI(1) == "http://purl.org/dc/elements/1.1/");
  fail_unless(ann1->getNamespaceURI(2) == "http://purl.org/dc/terms/");
  fail_unless(ann1->getNamespaceURI(3) == "http://www.w3.org/2001/vcard-rdf/3.0#");
  fail_unless(ann1->getNamespaceURI(4) == "http://biomodels.net/biology-qualifiers/");
  fail_unless(ann1->getNamespaceURI(5) == "http://biomodels.net/model-qualifiers/");
  fail_unless(ann1->getNamespacePrefix(0) == "rdf");
  fail_unless(ann1->getNamespacePrefix(1) == "dc");
  fail_unless(ann1->getNamespacePrefix(2) == "dcterms");
  fail_unless(ann1->getNamespacePrefix(3) == "vCard");
  fail_unless(ann1->getNamespacePrefix(4) == "bqbiol");
  fail_unless(ann1->getNamespacePrefix(5) == "bqmodel");

  delete ann1;

  XMLNode * ann2 = RDFAnnotationParser::createRDFDescription(NULL);
  
  fail_unless(ann2 == NULL);

  Model * m = new Model(3,1);
  ann2 = RDFAnnotationParser::createRDFDescription(m);
  
  fail_unless(ann2 == NULL);

  m->setMetaId("_001");
  ann2 = RDFAnnotationParser::createRDFDescription(m);
  
  fail_unless(ann2 != NULL);
  fail_unless(ann2->getName() == "Description");
  fail_unless(ann2->getNumChildren() == 0);
  fail_unless(ann2->getURI() == "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
  fail_unless(ann2->getPrefix() == "rdf");
  fail_unless(ann2->getAttributes().getLength() == 1);
  fail_unless(ann2->getAttrName(0) == "rdf:about");
  fail_unless(ann2->getAttrPrefix(0) == "");
  fail_unless(ann2->getAttrValue(0) == "#_001");

  delete ann2;
  delete m;

  //XMLNode * ann3 = RDFAnnotationParser::createRDFDescription("");

  //fail_unless(ann3 == NULL);

  //ann3 = RDFAnnotationParser::createRDFDescription("001");
  //
  //fail_unless(ann3 != NULL);
  //fail_unless(ann3->getName() == "Description");
  //fail_unless(ann3->getNumChildren() == 0);
  //fail_unless(ann3->getNamespaces().getLength() == 1);
  //fail_unless(ann3->getNamespaceURI(0) == "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
  //fail_unless(ann3->getNamespacePrefix(0) == "rdf");
  //fail_unless(ann3->getAttributes().getLength() == 1);
  //fail_unless(ann3->getAttrName(0) == "about");
  //fail_unless(ann3->getAttrPrefix(0) == "rdf");
  //fail_unless(ann3->getAttrValue(0) == "#001");

  //delete ann3;
}
END_TEST


START_TEST (test_RDFAnnotation_deleteCVTerms)
{
  XMLNode* node = m->getCompartment(0)->getAnnotation();

  XMLNode* n1 = NULL;

  const char * empty = "<annotation/>";
  const char * noRDF = "<annotation>\n"
		"  <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"0\" BuildVersion=\"41\">\n"
		"    <jd2:header>\n"
		"      <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"      <jd2:ModelHeader Author=\"Mr Untitled\" ModelVersion=\"0.0\" ModelTitle=\"untitled\"/>\n"
		"      <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"10\" numberOfPoints=\"1000\"/>\n"
		"    </jd2:header>\n"
		"  </jd2:JDesignerLayout>\n"
    "</annotation>";
  const char * otherRDF =
    "<annotation>\n"
		"  <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"0\" BuildVersion=\"41\">\n"
		"    <jd2:header>\n"
		"      <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"      <jd2:ModelHeader Author=\"Mr Untitled\" ModelVersion=\"0.0\" ModelTitle=\"untitled\"/>\n"
		"      <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"10\" numberOfPoints=\"1000\"/>\n"
		"    </jd2:header>\n"
		"  </jd2:JDesignerLayout>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"    <rdf:Description>\n"
    "      <rdf:other/>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";

  n1 = RDFAnnotationParser::deleteRDFCVTermAnnotation(NULL);

  fail_unless (n1 == NULL);

  n1 = RDFAnnotationParser::deleteRDFCVTermAnnotation(node);

  fail_unless(n1->getNumChildren() == 0);
  fail_unless(n1->getName() == "annotation");

  fail_unless( equals(empty, n1->toXMLString().c_str()) );

  node = m->getCompartment(2)->getAnnotation();
  n1 = RDFAnnotationParser::deleteRDFCVTermAnnotation(node);

  fail_unless( equals(noRDF, n1->toXMLString().c_str()) );

  node = m->getCompartment(1)->getAnnotation();
  n1 = RDFAnnotationParser::deleteRDFCVTermAnnotation(node);

  fail_unless( equals(noRDF, n1->toXMLString().c_str()) );

  node = m->getCompartment(4)->getAnnotation();
  n1 = RDFAnnotationParser::deleteRDFCVTermAnnotation(node);

  fail_unless( equals(otherRDF, n1->toXMLString().c_str()) );
  
  node = XMLNode::convertStringToXMLNode("<notannotatio/>");
  n1 = RDFAnnotationParser::deleteRDFCVTermAnnotation(node);

  fail_unless (n1 == NULL);
}
END_TEST


START_TEST (test_RDFAnnotation_removeSingleAnnotation)
{
  XMLNode* n1 = NULL;


  int i = m->getCompartment(0)->removeTopLevelAnnotationElement("RDF");
  n1 = m->getCompartment(0)->getAnnotation();

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);
  fail_unless (n1 == NULL);

  i = m->getCompartment(2)->removeTopLevelAnnotationElement("JDesignerLayout");
  n1 = m->getCompartment(2)->getAnnotation();

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);
  fail_unless (n1 == NULL);

  i = m->getCompartment(3)->removeTopLevelAnnotationElement("RDF", "http://www.w3.org/1999/02/22-rdf-syntax-ns#");
  n1 = m->getCompartment(3)->getAnnotation();

  fail_unless (i == LIBSBML_OPERATION_SUCCESS);
  fail_unless (n1 == NULL);
}
END_TEST


START_TEST (test_RDFAnnotation_removeSingleAnnotation1)
{
  XMLNode* n1 = NULL;


  int i = m->getCompartment(0)->removeTopLevelAnnotationElement("RDF1");
  n1 = m->getCompartment(0)->getAnnotation();

  fail_unless (i == LIBSBML_ANNOTATION_NAME_NOT_FOUND);
  fail_unless (n1->getNumChildren() == 1);

  i = m->getCompartment(2)->removeTopLevelAnnotationElement("JDLayout");
  n1 = m->getCompartment(2)->getAnnotation();

  fail_unless (i == LIBSBML_ANNOTATION_NAME_NOT_FOUND);
  fail_unless (n1->getNumChildren() == 1);

  i = m->getCompartment(3)->removeTopLevelAnnotationElement("RDF", "http://www.w3.org/1999/02/22-rdf-syntax-ns");
  n1 = m->getCompartment(3)->getAnnotation();

  fail_unless (i == LIBSBML_ANNOTATION_NS_NOT_FOUND);
  fail_unless (n1->getNumChildren() == 1);
}
END_TEST


START_TEST (test_RDFAnnotation_removeAnnotation)
{
  XMLNode* n1 = NULL;

  const char * expected =
    "<annotation>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
    "    <rdf:Description rdf:about=\"#_000005\">\n"
		"      <bqbiol:is>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"        </rdf:Bag>\n"
		"      </bqbiol:is>\n"
		"    </rdf:Description>\n"
		"    <rdf:Description>\n"
    "      <rdf:other/>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";

  int i = m->getCompartment(4)->removeTopLevelAnnotationElement("JDesignerLayout");
  n1 = m->getCompartment(4)->getAnnotation();

  fail_unless(i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( equals(expected, n1->toXMLString().c_str()) );

  i = m->getListOfCompartments()->removeTopLevelAnnotationElement("RDF");
  fail_unless(i == LIBSBML_OPERATION_SUCCESS);

}
END_TEST


START_TEST (test_RDFAnnotation_replaceAnnotation)
{
  XMLNode* node = m->getCompartment(3)->getAnnotation();
  XMLNode* n1 = NULL;

  const char * expected =
    "<annotation>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
    "    <rdf:Description rdf:about=\"#_000002\">\n"
		"      <bqbiol:is>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"        </rdf:Bag>\n"
		"      </bqbiol:is>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";

  int i = m->getCompartment(0)->replaceTopLevelAnnotationElement(node);
  n1 = m->getCompartment(0)->getAnnotation();

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( equals(expected, n1->toXMLString().c_str()) );
}
END_TEST


START_TEST (test_RDFAnnotation_replaceAnnotation1)
{
  XMLNode* n1 = NULL;

  const char * noRDF = "<annotation>\n"
		"  <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"3\" BuildVersion=\"41\">\n"
		"    <jd2:header>\n"
		"      <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"      <jd2:ModelHeader Author=\"Sarah\" ModelVersion=\"0.0\" ModelTitle=\"mine\"/>\n"
		"      <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"12\" numberOfPoints=\"1000\"/>\n"
		"    </jd2:header>\n"
		"  </jd2:JDesignerLayout>\n"
    "</annotation>";

  const char * expected =
    "<annotation>\n"
		"  <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"3\" BuildVersion=\"41\">\n"
		"    <jd2:header>\n"
		"      <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"      <jd2:ModelHeader Author=\"Sarah\" ModelVersion=\"0.0\" ModelTitle=\"mine\"/>\n"
		"      <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"12\" numberOfPoints=\"1000\"/>\n"
		"    </jd2:header>\n"
		"  </jd2:JDesignerLayout>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
    "    <rdf:Description rdf:about=\"#_000005\">\n"
		"      <bqbiol:is>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"        </rdf:Bag>\n"
		"      </bqbiol:is>\n"
		"    </rdf:Description>\n"
		"    <rdf:Description>\n"
    "      <rdf:other/>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";

  int i = m->getCompartment(4)->replaceTopLevelAnnotationElement(noRDF);
  n1 = m->getCompartment(4)->getAnnotation();

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( equals(expected, n1->toXMLString().c_str()) );
}
END_TEST


START_TEST (test_RDFAnnotation_replaceAnnotation2)
{
  XMLNode* n1 = NULL;

  const char * jd = "  <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"3\" BuildVersion=\"41\">\n"
		"    <jd2:header>\n"
		"      <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"      <jd2:ModelHeader Author=\"Sarah\" ModelVersion=\"0.0\" ModelTitle=\"mine\"/>\n"
		"      <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"12\" numberOfPoints=\"1000\"/>\n"
		"    </jd2:header>\n"
		"  </jd2:JDesignerLayout>";

  const char * twoAnn =
    "<annotation>\n"
		"  <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"3\" BuildVersion=\"41\">\n"
		"    <jd2:header>\n"
		"      <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"      <jd2:ModelHeader Author=\"Sarah\" ModelVersion=\"0.0\" ModelTitle=\"mine\"/>\n"
		"      <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"12\" numberOfPoints=\"1000\"/>\n"
		"    </jd2:header>\n"
		"  </jd2:JDesignerLayout>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
    "    <rdf:Description rdf:about=\"#_000005\">\n"
		"      <bqbiol:is>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"        </rdf:Bag>\n"
		"      </bqbiol:is>\n"
		"    </rdf:Description>\n"
		"    <rdf:Description>\n"
    "      <rdf:other/>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";

  int i = m->getCompartment(4)->replaceTopLevelAnnotationElement(twoAnn);
  fail_unless ( i == LIBSBML_INVALID_OBJECT);

  i = m->getCompartment(4)->replaceTopLevelAnnotationElement(jd);
  n1 = m->getCompartment(4)->getAnnotation();

  fail_unless ( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( equals(twoAnn, n1->toXMLString().c_str()) );
}
END_TEST


/* when I rewrote the parsing an annotation that has not been touched
 * does not get "recreated" - so I took out these tests
 */

Suite *
create_suite_RDFAnnotation (void)
{
  Suite *suite = suite_create("RDFAnnotation");
  TCase *tcase = tcase_create("RDFAnnotation");

  tcase_add_checked_fixture(tcase,
                            RDFAnnotation_setup,
                            RDFAnnotation_teardown);

  tcase_add_test(tcase, test_invalid_user_annotation );
  tcase_add_test(tcase, test_RDFAnnotation_getModelHistory );
  tcase_add_test(tcase, test_RDFAnnotation_parseModelHistory );
  tcase_add_test(tcase, test_RDFAnnotation_parseCVTerms );
  tcase_add_test(tcase, test_RDFAnnotation_delete );
  tcase_add_test(tcase, test_RDFAnnotation_deleteWithOther );
//  tcase_add_test(tcase, test_RDFAnnotation_recreate );
//  tcase_add_test(tcase, test_RDFAnnotation_recreateFromEmpty );
  tcase_add_test(tcase, test_RDFAnnotation_deleteWithOutOther );
  tcase_add_test(tcase, test_RDFAnnotation_deleteWithOtherRDF );
//  tcase_add_test(tcase, test_RDFAnnotation_recreateWithOutOther );
  tcase_add_test(tcase, test_RDFAnnotation_testMissingMetaId );
  tcase_add_test(tcase, test_RDFAnnotation_testMissingAbout );
  tcase_add_test(tcase, test_RDFAnnotation_testAnnotationForMetaId );
  tcase_add_test(tcase, test_RDFAnnotation_testHasRDFAnnotation );
  tcase_add_test(tcase, test_RDFAnnotation_testHasAdditionalRDFAnnotation );
  tcase_add_test(tcase, test_RDFAnnotation_testHasCVTermRDFAnnotation );
  tcase_add_test(tcase, test_RDFAnnotation_testHasHistoryRDFAnnotation );
  tcase_add_test(tcase, test_RDFAnnotation_testHasCVTermRDFAnnotationBadAbout );
  tcase_add_test(tcase, test_RDFAnnotation_testHasHistoryRDFAnnotationBadAbout );
  tcase_add_test(tcase, test_RDFAnnotation_testCreateAnnotations );
  tcase_add_test(tcase, test_RDFAnnotation_deleteCVTerms );
  tcase_add_test(tcase, test_RDFAnnotation_removeSingleAnnotation );
  tcase_add_test(tcase, test_RDFAnnotation_removeSingleAnnotation1 );
  tcase_add_test(tcase, test_RDFAnnotation_removeAnnotation );
  tcase_add_test(tcase, test_RDFAnnotation_replaceAnnotation );
  tcase_add_test(tcase, test_RDFAnnotation_replaceAnnotation1 );
  tcase_add_test(tcase, test_RDFAnnotation_replaceAnnotation2 );
  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND

