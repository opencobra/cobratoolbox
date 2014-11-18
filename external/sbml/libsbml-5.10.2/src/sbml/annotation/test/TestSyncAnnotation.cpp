/**
 * \file    TestSyncAnnotation.cpp
 * \brief   tests for improved syncAnnotation functions
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
SyncAnnotation_setup (void)
{
  char *filename = safe_strcat(TestDataDirectory, "annotationL3_2.xml");

  // The following will return a pointer to a new SBMLDocument.
  d = readSBML(filename);
  m = d->getModel();
}


void
SyncAnnotation_teardown (void)
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



START_TEST (test_SyncAnnotation_noChanges_1)
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
		"              <vCard:ORG>\n"
		"                <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"              </vCard:ORG>\n"
		"            </rdf:li>\n"
		"          </rdf:Bag>\n"
		"        </dc:creator>\n"
		"        <dcterms:created rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2005-02-02T14:56:11</dcterms:W3CDTF>\n"
		"        </dcterms:created>\n"
		"        <dcterms:modified rdf:parseType=\"Resource\">\n"
		"          <dcterms:W3CDTF>2006-05-30T10:46:02</dcterms:W3CDTF>\n"
		"        </dcterms:modified>\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
    "      <rdf:Description>\n"
    "        <rdf:other/>\n"
    "      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>\n"
    "</compartment>";

  fail_unless( equals(expected, c->toSBML()) );

}
END_TEST


START_TEST (test_SyncAnnotation_noChanges_2)
{
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
		"            <vCard:ORG>\n"
		"              <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"            </vCard:ORG>\n"
		"          </rdf:li>\n"
		"        </rdf:Bag>\n"
		"      </dc:creator>\n"
		"      <dcterms:created rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2005-02-02T14:56:11</dcterms:W3CDTF>\n"
		"      </dcterms:created>\n"
		"      <dcterms:modified rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2006-05-30T10:46:02</dcterms:W3CDTF>\n"
		"      </dcterms:modified>\n"
		"      <bqbiol:is>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"        </rdf:Bag>\n"
		"      </bqbiol:is>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";


  fail_unless( equals(expected, m->getAnnotation()->toXMLString().c_str()) );

}
END_TEST


START_TEST (test_SyncAnnotation_deleteModelOnly)
{
  Compartment* c = m->getCompartment(1);
  XMLNode * xml = RDFAnnotationParser::deleteRDFHistoryAnnotation(
    c->getAnnotation());
  
  const char * expected =
    "<annotation>\n"
		"  <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"0\" BuildVersion=\"41\">\n"
		"    <jd2:header>\n"
		"      <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"      <jd2:ModelHeader Author=\"Mr Untitled\" ModelVersion=\"0.0\" ModelTitle=\"untitled\"/>\n"
		"      <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"10\" numberOfPoints=\"1000\"/>\n"
		"    </jd2:header>\n"
		"  </jd2:JDesignerLayout>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"    <rdf:Description rdf:about=\"#_000003\">\n"
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

  fail_unless( equals(expected, xml->toXMLString().c_str()) );

}
END_TEST


START_TEST (test_SyncAnnotation_deleteModelOnly_1)
{
  Compartment* c = m->getCompartment(7);
  XMLNode * xml = RDFAnnotationParser::deleteRDFHistoryAnnotation(
    c->getAnnotation());
  
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

  fail_unless( equals(expected, xml->toXMLString().c_str()) );

  xml = RDFAnnotationParser::deleteRDFHistoryAnnotation(NULL);

  fail_unless (xml == NULL);

  xml = RDFAnnotationParser::deleteRDFHistoryAnnotation(
    XMLNode::convertStringToXMLNode("<notannotatio/>"));

  fail_unless (xml == NULL);
}
END_TEST


START_TEST (test_SyncAnnotation_deleteCVTerms)
{
  Compartment* c = m->getCompartment(1);
  XMLNode * xml = RDFAnnotationParser::deleteRDFCVTermAnnotation(
    c->getAnnotation());

  const char * expected =
    "<annotation>\n"
		"  <jd2:JDesignerLayout version=\"2.0\" MajorVersion=\"2\" MinorVersion=\"0\" BuildVersion=\"41\">\n"
		"    <jd2:header>\n"
		"      <jd2:VersionHeader JDesignerVersion=\"2.0\"/>\n"
		"      <jd2:ModelHeader Author=\"Mr Untitled\" ModelVersion=\"0.0\" ModelTitle=\"untitled\"/>\n"
		"      <jd2:TimeCourseDetails timeStart=\"0\" timeEnd=\"10\" numberOfPoints=\"1000\"/>\n"
		"    </jd2:header>\n"
		"  </jd2:JDesignerLayout>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"    <rdf:Description rdf:about=\"#_000003\">\n"
    "      <dc:creator>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:parseType=\"Resource\">\n"
    "            <vCard:N rdf:parseType=\"Resource\">\n"
		"              <vCard:Family>Le Novere</vCard:Family>\n"
		"              <vCard:Given>Nicolas</vCard:Given>\n"
		"            </vCard:N>\n"
		"            <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"            <vCard:ORG>\n"
		"              <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"            </vCard:ORG>\n"
		"          </rdf:li>\n"
		"        </rdf:Bag>\n"
		"      </dc:creator>\n"
		"      <dcterms:created rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2005-02-02T14:56:11</dcterms:W3CDTF>\n"
		"      </dcterms:created>\n"
		"      <dcterms:modified rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2006-05-30T10:46:02</dcterms:W3CDTF>\n"
		"      </dcterms:modified>\n"
		"    </rdf:Description>\n"
    "    <rdf:Description>\n"
    "      <rdf:other/>\n"
    "    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";

  fail_unless( equals(expected, xml->toXMLString().c_str()) );

}
END_TEST


START_TEST (test_SyncAnnotation_modifyHistory_1)
{
  Compartment* c = m->getCompartment(3);
  ModelHistory *mh = c->getModelHistory()->clone();
  c->unsetModelHistory();
  c->setModelHistory(mh);

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
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>\n"
    "</compartment>";

  fail_unless( equals(expected, c->toSBML()) );

}
END_TEST


START_TEST (test_SyncAnnotation_modifyHistory_2)
{
  m->unsetModelHistory();

  const char * expected =
    "<annotation>\n"
		"  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"    <rdf:Description rdf:about=\"#_000001\">\n"
		"      <bqbiol:is>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"        </rdf:Bag>\n"
		"      </bqbiol:is>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";

  fail_unless( equals(expected, m->getAnnotation()->toXMLString().c_str()) );

}
END_TEST


START_TEST (test_SyncAnnotation_modifyHistory_3)
{
  ModelHistory *mh = m->getModelHistory()->clone();
  m->unsetModelHistory();
  m->setModelHistory(mh);

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
		"      <bqbiol:is>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"        </rdf:Bag>\n"
		"      </bqbiol:is>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";


  fail_unless( equals(expected, m->getAnnotation()->toXMLString().c_str()) );

}
END_TEST


START_TEST (test_SyncAnnotation_modifyHistory_4)
{
  Compartment* c = m->getCompartment(0);
  ModelHistory *mh = m->getModelHistory()->clone();
  c->setModelHistory(mh);

  const char * expected =
    "<compartment metaid=\"_000002\" id=\"comp1\" constant=\"true\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000002\">\n"
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
    "  </annotation>\n"
    "</compartment>";

  fail_unless( equals(expected, c->toSBML()) );

}
END_TEST


START_TEST (test_SyncAnnotation_modifyHistory_5)
{
  Compartment* c = m->getCompartment(5);
  ModelHistory *mh = c->getModelHistory()->clone();
  c->unsetModelHistory();
  c->setModelHistory(mh);

  const char * expected =
    "<compartment metaid=\"_000032\" id=\"C1\" constant=\"true\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000032\">\n"
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
		"      <rdf:other/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>\n"
    "</compartment>";

  fail_unless( equals(expected, c->toSBML()) );

}
END_TEST


START_TEST (test_SyncAnnotation_modifyCVTerms_1)
{
  Compartment* c = m->getCompartment(4);
  CVTerm *cv = c->getCVTerm(0)->clone();
  c->unsetCVTerms();
  c->addCVTerm(cv);

  const char * expected =
    "<compartment metaid=\"_000012\" id=\"cc\" constant=\"true\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000012\">\n"
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


START_TEST (test_SyncAnnotation_modifyCVTerms_2)
{
  m->unsetCVTerms();

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
		"            <vCard:ORG>\n"
		"              <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"            </vCard:ORG>\n"
		"          </rdf:li>\n"
		"        </rdf:Bag>\n"
		"      </dc:creator>\n"
		"      <dcterms:created rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2005-02-02T14:56:11</dcterms:W3CDTF>\n"
		"      </dcterms:created>\n"
		"      <dcterms:modified rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2006-05-30T10:46:02</dcterms:W3CDTF>\n"
		"      </dcterms:modified>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";


  fail_unless( equals(expected, m->getAnnotation()->toXMLString().c_str()) );

}
END_TEST


START_TEST (test_SyncAnnotation_modifyCVTerms_3)
{
  CVTerm *cv = m->getCVTerm(0)->clone();
  m->unsetCVTerms();
  m->addCVTerm(cv);

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
		"            <vCard:ORG>\n"
		"              <vCard:Orgname>EMBL-EBI</vCard:Orgname>\n"
		"            </vCard:ORG>\n"
		"          </rdf:li>\n"
		"        </rdf:Bag>\n"
		"      </dc:creator>\n"
		"      <dcterms:created rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2005-02-02T14:56:11</dcterms:W3CDTF>\n"
		"      </dcterms:created>\n"
		"      <dcterms:modified rdf:parseType=\"Resource\">\n"
		"        <dcterms:W3CDTF>2006-05-30T10:46:02</dcterms:W3CDTF>\n"
		"      </dcterms:modified>\n"
		"      <bqbiol:is>\n"
		"        <rdf:Bag>\n"
		"          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"        </rdf:Bag>\n"
		"      </bqbiol:is>\n"
		"    </rdf:Description>\n"
		"  </rdf:RDF>\n"
    "</annotation>";


  fail_unless( equals(expected, m->getAnnotation()->toXMLString().c_str()) );

}
END_TEST


START_TEST (test_SyncAnnotation_modifyCVTerms_4)
{
  CVTerm *cv = m->getCVTerm(0)->clone();
  Compartment* c = m->getCompartment(0);
  c->addCVTerm(cv);

  const char * expected =
    "<compartment metaid=\"_000002\" id=\"comp1\" constant=\"true\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000002\">\n"
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


START_TEST (test_SyncAnnotation_modifyCVTerms_5)
{
  Compartment* c = m->getCompartment(6);
  CVTerm *cv = c->getCVTerm(0)->clone();
  c->unsetCVTerms();
  c->addCVTerm(cv);

  const char * expected =
    "<compartment metaid=\"_000042\" id=\"cc1\" constant=\"true\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000042\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"      <rdf:Description/>\n"
		"    </rdf:RDF>\n"
    "  </annotation>\n"
    "</compartment>";

  fail_unless( equals(expected, c->toSBML()) );

}
END_TEST


START_TEST (test_SyncAnnotation_modifyBoth_1)
{
  Compartment* c = m->getCompartment(0);

  ModelHistory *mh = m->getModelHistory()->clone();
  CVTerm *cv = m->getCVTerm(0)->clone();
 
  c->setModelHistory(mh);
  c->addCVTerm(cv);
  c->unsetCVTerms();
 
  const char * expected =
    "<compartment metaid=\"_000002\" id=\"comp1\" constant=\"true\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000002\">\n"
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
    "  </annotation>\n"
    "</compartment>";


  fail_unless( equals(expected, c->toSBML()) );

  c->unsetModelHistory();
  c->addCVTerm(cv);
  const char * expected1 =
    "<compartment metaid=\"_000002\" id=\"comp1\" constant=\"true\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000002\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>\n"
    "</compartment>";


  fail_unless( equals(expected1, c->toSBML()) );

  c->setModelHistory(mh);
  c->unsetCVTerms();
  c->addCVTerm(cv);

  const char * expected2 =
    "<compartment metaid=\"_000002\" id=\"comp1\" constant=\"true\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000002\">\n"
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


  fail_unless( equals(expected2, c->toSBML()) );

}
END_TEST


START_TEST (test_SyncAnnotation_modifyBoth_2)
{
  Compartment* c = m->getCompartment(0);

  ModelHistory *mh = m->getModelHistory()->clone();
  CVTerm *cv = m->getCVTerm(0)->clone();
 
  c->setModelHistory(mh);
  c->unsetModelHistory();
  c->addCVTerm(cv);
 
  const char * expected =
    "<compartment metaid=\"_000002\" id=\"comp1\" constant=\"true\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000002\">\n"
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


START_TEST (test_SyncAnnotation_modifyBoth_3)
{
  Compartment* c = m->getCompartment(0);

  ModelHistory *mh = m->getModelHistory()->clone();
  CVTerm *cv = m->getCVTerm(0)->clone();
 
  c->setModelHistory(mh);
  c->addCVTerm(cv);
 
  const char * expected =
    "<compartment metaid=\"_000002\" id=\"comp1\" constant=\"true\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000002\">\n"
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


START_TEST (test_SyncAnnotation_modifyBoth_4)
{
  Compartment* c = m->getCompartment(1);
  ModelHistory *mh = c->getModelHistory()->clone();
  CVTerm *cv = c->getCVTerm(0)->clone();

  c->unsetModelHistory();
  c->unsetCVTerms();

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
    "      <rdf:Description>\n"
    "        <rdf:other/>\n"
    "      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>\n"
    "</compartment>";

  fail_unless( equals(expected, c->toSBML()) );

  c->setModelHistory(mh);
  c->addCVTerm(cv);
  c->unsetCVTerms();

  const char * expected1 =
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
		"      </rdf:Description>\n"
    "      <rdf:Description>\n"
    "        <rdf:other/>\n"
    "      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>\n"
    "</compartment>";

  fail_unless( equals(expected1, c->toSBML()) );

  c->unsetModelHistory();
  c->unsetCVTerms();
  c->addCVTerm(cv);

  const char * expected2 =
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
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
    "      <rdf:Description>\n"
    "        <rdf:other/>\n"
    "      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>\n"
    "</compartment>";

  fail_unless( equals(expected2, c->toSBML()) );

  c->unsetModelHistory();
  c->unsetCVTerms();
  c->addCVTerm(cv);
  c->setModelHistory(mh);

  const char * expected3 =
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
    "      <rdf:Description>\n"
    "        <rdf:other/>\n"
    "      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>\n"
    "</compartment>";

  fail_unless( equals(expected3, c->toSBML()) );
}
END_TEST


START_TEST (test_SyncAnnotation_stringHistoryWhenNotValid)
{
  Compartment* c = new Compartment(2,3);
  c->setMetaId("_000003");
  c->setId("A");

  const char * addedAnn =
    "  <annotation>\n"
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
    "  </annotation>";

  c->setAnnotation(addedAnn);

  const char * expected =
    "<compartment metaid=\"_000003\" id=\"A\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000003\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
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
    "      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>\n"
    "</compartment>";

  fail_unless( equals(expected, c->toSBML()) );
}
END_TEST


START_TEST (test_SyncAnnotation_stringChangesMetaid)
{
  Compartment* c = new Compartment(3, 1);
  c->setMetaId("_000005");
  c->setId("A");

  const char * addedAnn =
    "  <annotation>\n"
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
    "  </annotation>";

  c->setAnnotation(addedAnn);

  const char * expected =
    "<compartment metaid=\"_000005\" id=\"A\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000005\">\n"
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


START_TEST (test_SyncAnnotation_stringChangesMetaid1)
{
  Model* c = new Model(2, 3);
  c->setMetaId("_000005");
  c->setId("A");

  const char * addedAnn =
    "  <annotation>\n"
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
    "  </annotation>";

  c->setAnnotation(addedAnn);

  const char * expected =
    "<model metaid=\"_000005\" id=\"A\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000005\">\n"
    "        <dc:creator rdf:parseType=\"Resource\">\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:parseType=\"Resource\">\n"
    "              <vCard:N rdf:parseType=\"Resource\">\n"
		"                <vCard:Family>Le Novere</vCard:Family>\n"
		"                <vCard:Given>Nicolas</vCard:Given>\n"
		"              </vCard:N>\n"
		"              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>\n"
		"              <vCard:ORG>\n"
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
    "</model>";

  fail_unless( equals(expected, c->toSBML()) );
}
END_TEST


START_TEST (test_SyncAnnotation_stringChangesMetaid2)
{
  Compartment* c = new Compartment(2, 3);
  c->setMetaId("_000005");
  c->setId("A");

  const char * addedAnn =
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000003\">\n"
		"        <bqbiol:is>\n"
		"          <rdf:Bag>\n"
		"            <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0007274\"/>\n"
		"          </rdf:Bag>\n"
		"        </bqbiol:is>\n"
		"      </rdf:Description>\n"
		"    </rdf:RDF>\n"
    "  </annotation>";

  c->setAnnotation(addedAnn);

  const char * expected =
    "<compartment metaid=\"_000005\" id=\"A\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000005\">\n"
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


START_TEST (test_SyncAnnotation_stringChangesMetaid3)
{
  Model* c = new Model(3, 1);
  c->setMetaId("_000005");
  c->setId("A");

  const char * addedAnn =
    "  <annotation>\n"
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
    "  </annotation>";

  c->setAnnotation(addedAnn);

  const char * expected =
    "<model metaid=\"_000005\" id=\"A\">\n"
    "  <annotation>\n"
		"    <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
		"      <rdf:Description rdf:about=\"#_000005\">\n"
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
    "</model>";

  fail_unless( equals(expected, c->toSBML()) );
}
END_TEST


Suite *
create_suite_SyncAnnotation (void)
{
  Suite *suite = suite_create("SyncAnnotation");
  TCase *tcase = tcase_create("SyncAnnotation");

  tcase_add_checked_fixture(tcase,
                            SyncAnnotation_setup,
                            SyncAnnotation_teardown);

  tcase_add_test(tcase, test_SyncAnnotation_noChanges_1 );
  tcase_add_test(tcase, test_SyncAnnotation_noChanges_2 );
  tcase_add_test(tcase, test_SyncAnnotation_deleteModelOnly );
  tcase_add_test(tcase, test_SyncAnnotation_deleteModelOnly_1 );
  tcase_add_test(tcase, test_SyncAnnotation_deleteCVTerms );
  tcase_add_test(tcase, test_SyncAnnotation_modifyHistory_1 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyHistory_2 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyHistory_3 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyHistory_4 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyHistory_5 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyCVTerms_1 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyCVTerms_2 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyCVTerms_3 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyCVTerms_4 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyCVTerms_5 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyBoth_1 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyBoth_2 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyBoth_3 );
  tcase_add_test(tcase, test_SyncAnnotation_modifyBoth_4 );
  tcase_add_test(tcase, test_SyncAnnotation_stringHistoryWhenNotValid );
  tcase_add_test(tcase, test_SyncAnnotation_stringChangesMetaid );
  tcase_add_test(tcase, test_SyncAnnotation_stringChangesMetaid1 );
  tcase_add_test(tcase, test_SyncAnnotation_stringChangesMetaid2 );
  tcase_add_test(tcase, test_SyncAnnotation_stringChangesMetaid3 );
  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND

