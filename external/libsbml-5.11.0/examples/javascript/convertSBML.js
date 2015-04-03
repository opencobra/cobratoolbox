//!/usr/bin/env node
//
// @file    convertSBML.js
// @brief   Converts SBML documents between levels 
// @author  Frank Bergmann
//
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
     
var latest_level= sbml.SBMLDocument.getDefaultLevel()
var latest_version = sbml.SBMLDocument.getDefaultVersion()              

if (process.argv.length != 4)
{
  console.log("Usage: node convertSBML.js input-filename output-filename");
  console.log("This program will attempt to convert a model either to");
  console.log("SBML Level "+latest_level+" Version "+ latest_version + " (if the model is not already) or, if");
  console.log("the model is already expressed in Level "+latest_level+" Version "+ latest_version + ", this");
  console.log("program will attempt to convert the model to Level 1 Version 2.");
  process.exit(1)
}

var d = sbml.readSBML(process.argv[2])

if (d.getNumErrors > 0)
{
  console.log("Encountered the following SBML error(s)");
  d.printErrors();
  console.log("Conversion skipped. Please correct the problems above first");
  process.exit(d.getNumErrors());
}
                                    
var success = false;

if (d.getLevel() < latest_level || d.getVersion() < latest_version)
{
  console.log("Attempting to convert model to SBML Level "+latest_level+" Version "+ latest_version);
  success = d.setLevelAndVersion(latest_level,latest_version);
}
else
{
  console.log("Attempting to convert model to SBML Level 1 Version 2");
  success = d.setLevelAndVersion(1,2);
}


if (!success)
{
  console.log("Unable to perform conversion due to the following:");
  d.printErrors();
  console.log("Conversion skipped.  Either libSBML does not (yet) have");
  console.log("ability to convert this model, or (automatic) conversion");
  console.log("is not possible in this case.");
}
else if (d.getNumErrors() > 0)
{
  console.log("Information may have been lost in conversion; but a valid model");
  console.log("was produced by the conversion.\nThe following information ");
  console.log("was provided:");
  d.printErrors();
  sbml.writeSBML(d, process.argv[3]);
}
else
{
  console.log("Conversion completed.");
  sbml.writeSBML(d, process.argv[3]);
}
