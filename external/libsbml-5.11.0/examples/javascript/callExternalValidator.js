//!/usr/bin/env node
// 
// @file    callExternalValidator.js
// @brief   Example that shows how to call an external program for validation
// @author  Frank T. Bergmann
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

if (process.argv.length <= 4)
{
  console.log("Usage: node callExternalValidator.js filename externalValidator [ tempSBMLFile outputFile [ ADDITIONAL-ARGS] ]");
  console.log("calls an external validator");
  process.exit(1);
}

var filename = process.argv[3];

// read additional args
var externalValidator = process.argv[2];

var tempSBMLFileName = filename + "_temp.xml";
if (process.argv.length  > 4)
    tempSBMLFileName = process.argv[4];

var outputFile = filename + "_out.xml";
if (process.argv.length > 5)
    outputFile = process.argv[5];

var additionalArgs = [];
for (i=6; i < process.argv.length; i++)
    additionalArgs.push(process.argv[i]);

// add the output file as additional arg
additionalArgs.push(outputFile);

// read the file name
var document = sbml.readSBML(filename);

// create a external validator that will write the model to 
// tempFile, then call teh externalValidator with the given number of arguments
// to produce the output file. This output file will then be parsed and its
// errors will be added to the error log.
var validator = new sbml.SBMLExternalValidator();

validator.setProgram(externalValidator);
validator.setSBMLFileName(tempSBMLFileName);
validator.setOutputFileName(outputFile);

for (i = 0; i < additionalArgs.length; i++)
  validator.addArgument(additionalArgs[i]);

// this means that the external program will be called with the following arguments
// 
//    externalValidator tempSBMLFileName additionalArgs
//
// (where additionalargs contains the output file as last argument)
//
// The output file that is generated should be an XML document following the 
// Validator XML format as described here: http://sbml.org/validator/api/#xml
//

// disable all regular checks
document.setApplicableValidators(0);

// add a custom validator
document.addValidator(validator);

// check consistency like before
numErrors = document.checkConsistency();

// print errors and warnings
document.printErrors();

// return number of errors
process.exit(numErrors);
