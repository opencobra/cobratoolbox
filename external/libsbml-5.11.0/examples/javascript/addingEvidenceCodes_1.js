//!/usr/bin/env node
//
// 
// \file    addingEvidenceCodes_1.js
// \brief   adds controlled vocabulary terms to a reaction in a model
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
  console.log("usage: addingEvidenceCodes_1 <input-filename> <output-filename>");
  console.log("       Adds controlled vocabulary term to a reaction");
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

var n = d.getModel().getNumReactions();

if (n <= 0)
{
  console.log("Model has no reactions.\n Cannot add CV terms\n");
  process.exit(0);
}

var r = d.getModel().getReaction(0);

// check that the reaction has a metaid
// no CVTerms will be added if there is no metaid to reference
// 
if ( !r.isSetMetaId())
    r.setMetaId("metaid_0000052")

var cv1 = new sbml.CVTerm(sbml.BIOLOGICAL_QUALIFIER)
cv1.setBiologicalQualifierType(sbml.BQB_IS_DESCRIBED_BY)
cv1.addResource("urn:miriam:obo.eco:ECO%3A0000183")

r.addCVTerm(cv1)

var cv2 = new sbml.CVTerm(sbml.BIOLOGICAL_QUALIFIER)
cv2.setBiologicalQualifierType(sbml.BQB_IS)
cv2.addResource("urn:miriam:kegg.reaction:R00756")
cv2.addResource("urn:miriam:reactome:REACT_736")

r.addCVTerm(cv2)

sbml.writeSBML(d, process.argv[3])
process.exit(errors);
