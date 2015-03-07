//!/usr/bin/env node
//
// 
// \file    addingEvidenceCodes_2.js
// \brief   adds evidence codes to a species in a model
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
  console.log("usage: addingEvidenceCodes_2 <input-filename> <output-filename>");
  console.log("       Adds controlled vocabulary term to a species");
  process.exit(2);
}

var d = sbml.readSBML(process.argv[2]);
var errors = d.getNumErrors();

if (errors > 0)
{
  console.log("Read Error(s)\n");
  d.printErrors();
  console.log("Correct the above and re-run.\n");
  process.exit(errors);
}

var n = d.getModel().getNumSpecies();
if (n <= 0)
{
  console.log("Model has no species.\n Cannot add CV terms\n");
  process.exit(0);
}

var s = d.getModel().getSpecies(0)

// check that the species has a metaid
// no CVTerms will be added if there is no metaid to reference
// 
if (!s.isSetMetaId())
    s.setMetaId("metaid_0000052");

cv1 = new sbml.CVTerm(sbml.BIOLOGICAL_QUALIFIER);
cv1.setBiologicalQualifierType(sbml.BQB_OCCURS_IN);
cv1.addResource("urn:miriam:obo.go:GO%3A0005764");

s.addCVTerm(cv1)

// now create the additional annotation

// <rdf:Statement> 
//   <rdf:subject rdf:resource="//metaid_0000052"/> 
//   <rdf:predicate rdf:resource="http://biomodels.net/biology-qualifiers/occursIn"/> 
//   <rdf:object rdf:resource="urn:miriam:obo.go:GO%3A0005764"/> 
//   <bqbiol:isDescribedBy> 
//     <rdf:Bag> 
//       <rdf:li rdf:resource="urn:miriam:obo.eco:ECO%3A0000004"/> 
//       <rdf:li rdf:resource="urn:miriam:pubmed:7017716"/> 
//     </rdf:Bag> 
//   </bqbiol:isDescribedBy> 
// </rdf:Statement> 

// attributes
var blank_att = new sbml.XMLAttributes();

var resource_att = new sbml.XMLAttributes();

//  create the outer statement node 
var statement_triple = new sbml.XMLTriple("Statement",
                                       "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                       "rdf")

var statement_token = new sbml.XMLToken(statement_triple, blank_att);

var statement = new sbml.XMLNode(statement_token);

// create the subject node
var subject_triple = new sbml.XMLTriple("subject",
                                     "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                     "rdf");

resource_att.clear();
resource_att.add("rdf:resource", "#" + s.getMetaId());

var subject_token = new sbml.XMLToken(subject_triple, resource_att);

var subject = new sbml.XMLNode(subject_token);


//create the predicate node 
var predicate_triple = new sbml.XMLTriple("predicate",
                                       "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                       "rdf")

resource_att.clear();
resource_att.add("rdf:resource",
                 "http://biomodels.net/biology-qualifiers/occursIn");

var predicate_token = new sbml.XMLToken(predicate_triple, resource_att);

var predicate = new sbml.XMLNode(predicate_token);

//create the object node 
var object_triple = new sbml.XMLTriple("object",
                                    "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                    "rdf");

resource_att.clear();
resource_att.add("rdf:resource", "urn:miriam:obo.go:GO%3A0005764")

var object_token = new sbml.XMLToken(object_triple, resource_att);

var object_ = new sbml.XMLNode(object_token);

// create the bqbiol node 
var bqbiol_triple = new sbml.XMLTriple("isDescribedBy",
                                    "http://biomodels.net/biology-qualifiers/",
                                    "bqbiol");

var bqbiol_token = new sbml.XMLToken(bqbiol_triple, blank_att);

var bqbiol = new sbml.XMLNode(bqbiol_token);

// create the bag node 
var bag_triple = new sbml.XMLTriple("Bag",
                                 "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                 "rdf");

var bag_token = new sbml.XMLToken(bag_triple, blank_att);

var bag = new sbml.XMLNode(bag_token);

// create each li node and add to the bag 
var li_triple = new sbml.XMLTriple("li",
                                "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                "rdf");

resource_att.clear();
resource_att.add("rdf:resource", "urn:miriam:obo.eco:ECO%3A0000004");

var li_token = new sbml.XMLToken(li_triple, resource_att);
li_token.setEnd();

var li = new sbml.XMLNode(li_token);

bag.addChild(li);

resource_att.clear();
resource_att.add("rdf:resource", "urn:miriam:pubmed:7017716");
li_token = new sbml.XMLToken(li_triple, resource_att);
li_token.setEnd();
li = new sbml.XMLNode(li_token);

bag.addChild(li);

// add the bag to bqbiol 
bqbiol.addChild(bag);

// add subject, predicate, object and bqbiol to statement 
statement.addChild(subject);
statement.addChild(predicate);
statement.addChild(object_);
statement.addChild(bqbiol);


// create a top-level RDF element 
// this will ensure correct merging
// 

var xmlns = new sbml.XMLNamespaces();
xmlns.add("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf");
xmlns.add("http://purl.org/dc/elements/1.1/", "dc");
xmlns.add("http://purl.org/dc/terms/", "dcterms");
xmlns.add("http://www.w3.org/2001/vcard-rdf/3.0//", "vCard");
xmlns.add("http://biomodels.net/biology-qualifiers/", "bqbiol");
xmlns.add("http://biomodels.net/model-qualifiers/", "bqmodel");

var rDF_triple = new sbml.XMLTriple("RDF",
                                 "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                 "rdf");

var rDF_token = new sbml.XMLToken(rDF_triple, blank_att, xmlns);

var annotation = new sbml.XMLNode(rDF_token);

// add the statement node to the RDF node 
annotation.addChild(statement);

s.appendAnnotation(annotation);

sbml.writeSBML(d, process.argv[3]);
process.exit(errors);
