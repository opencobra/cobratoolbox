//!/usr/bin/env node
// 
// \file    addCVTerms.js
// \brief   adds controlled vocabulary terms to a species in a model
// \author  Sarah Keating
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

var sbml = require('sbml');


if (process.argv.length != 4)
{
  console.log("usage: addCVTerms <input-filename> <output-filename>");
  console.log("       Adds controlled vocabulary term to a species");
  process.exit(2);
}

var d = sbml.readSBML(process.argv[2]);
var errors = d.getNumErrors();

if (errors > 0)
{
  console.log("Read Error(s):");
  d.printErrors();
  console.log("Correct the above and re-run.");
  process.exit(errors);
}

var n = d.getModel().getNumSpecies();

if (n <= 0)
{
    console.log("Model has no species.\n Cannot add CV terms\n");
    process.exit(0);
}

var s = d.getModel().getSpecies(0);

if (!s.isSetMetaId())
  s.setMetaId("meta_001");

var cv = new sbml.CVTerm();
cv.setQualifierType(sbml.BIOLOGICAL_QUALIFIER);
cv.setBiologicalQualifierType(sbml.BQB_IS_VERSION_OF);
cv.addResource("http://www.geneontology.org/#GO:0005892");

var cv2 = new sbml.CVTerm();
cv2.setQualifierType(sbml.BIOLOGICAL_QUALIFIER);
cv2.setBiologicalQualifierType(sbml.BQB_IS);
cv2.addResource("http://www.geneontology.org/#GO:0005895")

var cv1 = new sbml.CVTerm();
cv1.setQualifierType(sbml.BIOLOGICAL_QUALIFIER);
cv1.setBiologicalQualifierType(sbml.BQB_IS_VERSION_OF);
cv1.addResource("http://www.ebi.ac.uk/interpro/#IPR002394");

s.addCVTerm(cv);
s.addCVTerm(cv2);
s.addCVTerm(cv1);

sbml.writeSBML(d, process.argv[3]);

process.exit(errors);

