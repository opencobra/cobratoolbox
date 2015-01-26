/**
 * \file    TestL3ModelHistory.cpp
 * \brief   test for ModelHistory on any SBase object
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


LIBSBML_CPP_NAMESPACE_USE

CK_CPPSTART

static Model *m;
static Compartment *c;
static SBMLDocument* d;

extern char *TestDataDirectory;

/* 
 * tests the results from rdf annotations
 */

void
L3ModelHistory_setup (void)
{
  char *filename = safe_strcat(TestDataDirectory, "annotationL3.xml");

  // The following will return a pointer to a new SBMLDocument.
  d = readSBML(filename);
  m = d->getModel();
  c = m->getCompartment(0);
}


void
L3ModelHistory_teardown (void)
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



START_TEST (test_L3ModelHistory_getModelHistory)
{
  fail_if(c == NULL);

  ModelHistory * history = c->getModelHistory();

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


START_TEST (test_L3ModelHistory_parseModelHistory)
{
  XMLNode* node = RDFAnnotationParser::parseModelHistory(c);

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
  fail_unless(XMLNode_getNumChildren(desc) == 4);

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

START_TEST (test_L3ModelHistory_delete)
{
  XMLNode* node = RDFAnnotationParser::parseModelHistory(c);

  XMLNode* n1 = RDFAnnotationParser::deleteRDFAnnotation(node);

  const char * expected = "<annotation/>";

  fail_unless(n1->getNumChildren() == 0);
  fail_unless(n1->getName() == "annotation");

  fail_unless( equals(expected, n1->toXMLString().c_str()) );

  delete node;
}
END_TEST


START_TEST (test_L3ModelHistory_deleteWithOther)
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

#if 0
START_TEST (test_L3ModelHistory_recreate)
{
  Compartment* c = m->getCompartment(1);

  const char * expected =
    "<compartment metaid=\"_000003\" id=\"A\" constant=\"true\">\n"
    "  <annotation>\n"
		"    <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"0\" BuildVersion=\"41\">\n"
		"      <jd2:header>\n"
		"        <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"        <jd2:ModelHeader Author=\"Mr Untitled\" ModelVersion=\"0.0\" ModelTitle=\"untitled\"/>\n"
		"        <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"10\" numberOfPoints=\"1000\"/>\n"
		"      </jd2:header>\n"
		"    </jd2:JDesignerLayout>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000003\">\n"
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
    "  </annotation>\n"
    "</compartment>";
  fail_unless( equals(expected, c->toSBML()) );

}
END_TEST
#endif

#if 0
START_TEST (test_L3ModelHistory_recreateFromEmpty)
{
  Compartment* c = m->getCompartment(3);

  const char * expected =
    "<compartment metaid=\"_000004\" id=\"C\" constant=\"true\">\n"
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
    "  </annotation>\n"
    "</compartment>";


  fail_unless( equals(expected, c->toSBML()) );

}
END_TEST
#endif


START_TEST (test_L3ModelHistory_deleteWithOutOther)
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


START_TEST (test_L3ModelHistory_recreateWithOutOther)
{
  Compartment* c = m->getCompartment(2);

  const char * expected =
    "<compartment id=\"B\" constant=\"true\">\n"
    "  <annotation>\n"
		"    <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"0\" BuildVersion=\"41\">\n"
		"      <jd2:header>\n"
		"        <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"        <jd2:ModelHeader Author=\"Mr Untitled\" ModelVersion=\"0.0\" ModelTitle=\"untitled\"/>\n"
		"        <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"10\" numberOfPoints=\"1000\"/>\n"
		"      </jd2:header>\n"
		"    </jd2:JDesignerLayout>\n"
    "  </annotation>\n"
    "</compartment>";


  fail_unless( equals(expected, c->toSBML()) );

}
END_TEST


START_TEST (test_L3ModelHistory_getModelHistory_Model)
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


START_TEST (test_L3ModelHistory_parseModelHistory_Model)
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
  fail_unless(XMLNode_getNumChildren(desc) == 4);

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

START_TEST (test_L3ModelHistory_delete_Model)
{
  XMLNode* node = RDFAnnotationParser::parseModelHistory(m);

  XMLNode* n1 = RDFAnnotationParser::deleteRDFAnnotation(node);

  const char * expected = "<annotation/>";

  fail_unless(n1->getNumChildren() == 0);
  fail_unless(n1->getName() == "annotation");

  fail_unless( equals(expected, n1->toXMLString().c_str()) );

  delete node;
}
END_TEST

#if 0
START_TEST (test_L3ModelHistory_recreateFromEmpty_Model)
{
  std::string ann = m->getAnnotationString();

  m->setAnnotation(NULL);

  XMLNode* n1 = m->getAnnotation();

  fail_unless (n1 == NULL);

  m->setAnnotation(ann);

  n1 = m->getAnnotation();


  const char * expected =
    "<annotation>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"    <rdf:Description rdf:about=\"#_000001\">\n"
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
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";


  fail_unless( equals(expected, n1->toXMLString().c_str()) );

}
END_TEST
#endif


/* when I rewrote the parsing an annotation that has not been touched
 * does not get "recreated"
 */

Suite *
create_suite_L3ModelHistory (void)
{
  Suite *suite = suite_create("L3ModelHistory");
  TCase *tcase = tcase_create("L3ModelHistory");

  tcase_add_checked_fixture(tcase,
                            L3ModelHistory_setup,
                            L3ModelHistory_teardown);

  tcase_add_test(tcase, test_L3ModelHistory_getModelHistory );
  tcase_add_test(tcase, test_L3ModelHistory_parseModelHistory );
  tcase_add_test(tcase, test_L3ModelHistory_delete );
  tcase_add_test(tcase, test_L3ModelHistory_deleteWithOther );
//  tcase_add_test(tcase, test_L3ModelHistory_recreate );
//  tcase_add_test(tcase, test_L3ModelHistory_recreateFromEmpty );
  tcase_add_test(tcase, test_L3ModelHistory_deleteWithOutOther );
  tcase_add_test(tcase, test_L3ModelHistory_recreateWithOutOther );
  tcase_add_test(tcase, test_L3ModelHistory_getModelHistory_Model );
  tcase_add_test(tcase, test_L3ModelHistory_parseModelHistory_Model );
  tcase_add_test(tcase, test_L3ModelHistory_delete_Model );
//  tcase_add_test(tcase, test_L3ModelHistory_recreateFromEmpty_Model );
  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND

