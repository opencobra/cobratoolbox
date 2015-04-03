//!/usr/bin/env node
//
// \file    appendAnnotation.js
// \brief   adds annotation strings to a model and a species
// \author  Frank Bergmann
// 
// <!--------------------------------------------------------------------------
// This sample program is distributed under a different license than the rest
// of libSBML.  This program uses the open-source MIT license, as follows:
//
// Copyright (c) 2013-2014 by the California Institute of Technology
// (California, USA), the European Bioinformatics Institute (EMBL-EBI, UK)
// and the University of Heidelberg (Germany), with support from the National
// Institutes of Health (USA) under grant R01GM070923.  All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
// Neither the name of the California Institute of Technology (Caltech), nor
// of the European Bioinformatics Institute (EMBL-EBI), nor of the University
// of Heidelberg, nor the names of any contributors, may be used to endorse
// or promote products derived from this software without specific prior
// written permission.
// ------------------------------------------------------------------------ -->
// 

var sbml = require('sbml');

if (process.argv.length != 4)
{
  console.log("Usage: node appendAnnotation.js <input-filename> <output-filename>");
  console.log("Adds annotations");
  process.exit(1);
}

var d = sbml.readSBML(process.argv[2]);
var errors = d.getNumErrors();

if (errors > 0)
{
    console.log("Read Error(s):\n");
    d.printErrors();

    console.log("Correct the above and re-run.\n");
	process.exit(errors);
}

var model_history_annotation = 
  "<annotation>\n"+
  "<rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:dcterms='http://purl.org/dc/terms/' xmlns:vCard='http://www.w3.org/2001/vcard-rdf/3.0//' xmlns:bqbiol='http://biomodels.net/biology-qualifiers/' xmlns:bqmodel='http://biomodels.net/model-qualifiers/'>\n"+
  "  <rdf:Description rdf:about='#meta_0001'>\n"+
  "    <dc:creator rdf:parseType='Resource'>\n"+
  "      <rdf:Bag>\n"+
  "        <rdf:li rdf:parseType='Resource'>\n"+
  "          <vCard:N rdf:parseType='Resource'>\n"+
  "            <vCard:Family>Keating</vCard:Family>\n"+
  "            <vCard:Given>Sarah</vCard:Given>\n"+
  "          </vCard:N>\n"+
  "          <vCard:EMAIL>sbml-team@caltech.edu</vCard:EMAIL>\n"+
  "          <vCard:ORG>\n"+
  "            <vCard:Orgname>University of Hertfordshire</vCard:Orgname>\n"+
  "          </vCard:ORG>\n"+
  "        </rdf:li>\n"+
  "      </rdf:Bag>\n"+
  "    </dc:creator>\n"+
  "    <dcterms:created rdf:parseType='Resource'>\n"+
  "      <dcterms:W3CDTF>1999-11-13T06:54:32Z</dcterms:W3CDTF>\n"+
  "    </dcterms:created>\n"+
  "    <dcterms:modified rdf:parseType='Resource'>\n"+
  "      <dcterms:W3CDTF>2007-11-31T06:54:00-02:00</dcterms:W3CDTF>\n"+
  "    </dcterms:modified>\n"+
  "  </rdf:Description>\n"+
  "</rdf:RDF>\n"+
  "</annotation>";

d.getModel().setMetaId("meta_0001");
d.getModel().appendAnnotation(model_history_annotation);

// 
// The above code can be replaced by the following code.
// 
// 
// var h = new sbml.ModelHistory();
// 
// var c = new sbml.ModelCreator();
// c.setFamilyName("Keating");
// c.setGivenName("Sarah");
// c.setEmail("sbml-team@caltech.edu");
// c.setOrganisation("University of Hertfordshire");
// 
// h.addCreator(c);
// 
// var date = new sbml.Date("1999-11-13T06:54:32");
// var date2 = new sbml.Date("2007-11-31T06:54:00-02:00");
// 
// h.setCreatedDate(date);
// h.setModifiedDate(date2);
// 
// d.getModel().setModelHistory(h);
// 
// 
// 


var n = d.getModel().getNumSpecies();

if (n <= 0)
{
  console.log("Model has no species.\n Cannot add CV terms\n");
  process.exit(0);
}

var s = d.getModel().getSpecies(0);

var cvterms_annotation = 
 "<annotation>		  \n"+
 "  <rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:dcterms='http://purl.org/dc/terms/' xmlns:vCard='http://www.w3.org/2001/vcard-rdf/3.0//' xmlns:bqbiol='http://biomodels.net/biology-qualifiers/' xmlns:bqmodel='http://biomodels.net/model-qualifiers/'>\n"+
 "    <rdf:Description rdf:about='//'>\n"+
 "      <bqbiol:isVersionOf>\n"+
 "        <rdf:Bag>\n"+
 "          <rdf:li rdf:resource='http://www.geneontology.org/#GO:0005892'/>\n"+
 "          <rdf:li rdf:resource='http://www.ebi.ac.uk/interpro/#IPR002394'/>\n"+
 "        </rdf:Bag>\n"+
 "      </bqbiol:isVersionOf>\n"+
 "      <bqbiol:is>\n"+
 "        <rdf:Bag>\n"+
 "          <rdf:li rdf:resource='http://www.geneontology.org/#GO:0005895'/>\n"+
 "        </rdf:Bag>\n"+
 "      </bqbiol:is>\n"+
 "    </rdf:Description>\n"+
 "  </rdf:RDF>\n"+
 "</annotation>";
 
s.appendAnnotation(cvterms_annotation);

// 
// The above code can be replaced by the following code.
// 
// 
// var cv = new sbml.CVTerm();
// cv.setQualifierType(sbml.BIOLOGICAL_QUALIFIER);
// cv.setBiologicalQualifierType(sbml.BQB_IS_VERSION_OF);
// cv.addResource("http://www.geneontology.org/#GO:0005892");
// 
// var cv2 = new sbml.CVTerm();
// cv2.setQualifierType(sbml.BIOLOGICAL_QUALIFIER);
// cv2.setBiologicalQualifierType(sbml.BQB_IS);
// cv2.addResource("http://www.geneontology.org/#GO:0005895");
// 
// var cv1 = new sbml.CVTerm();
// cv1.setQualifierType(sbml.BIOLOGICAL_QUALIFIER);
// cv1.setBiologicalQualifierType(sbml.BQB_IS_VERSION_OF);
// cv1.addResource("http://www.ebi.ac.uk/interpro/#IPR002394");
// 
// s.addCVTerm(cv);
// s.addCVTerm(cv2);
// s.addCVTerm(cv1);
// 
// 
// 

sbml.writeSBML(d, process.argv[3]);
process.exit(errors);
 

