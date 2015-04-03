//!/usr/bin/env node
//
// 
// @file    printModel.js
// @brief   Prints some information about the top-level model
// @author  Frank Bergmann
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

if (process.argv.length != 3)
{
  console.log("\n" + "Usage: node printSBML.js filename" + "\n" + "\n");
  process.exit(1);
}

var filename = process.argv[2];
var document = sbml.readSBML(filename);

if (document.getNumErrors() > 0)
{
  console.log("Encountered the following SBML errors:" + "\n");
  document.printErrors();
  process.exit(1);
}

var level = document.getLevel()
var version = document.getVersion()

console.log("\nFile: " + filename + " (Level " + level +", " + version +")");

var model = document.getModel();

if (model == null)
{
    console.log("No model present." + "\n")
    process.exit(1);
}

var idString = "id"
if (level == 1)
{
  idString = "name"
}

id = "(empty)"
if (model.isSetId())
{
  id = model.getId()
}
console.log("                 " + idString + ": " + id )

if (model.isSetSBOTerm())
{
    console.log("      model sboTerm: " + model.getSBOTerm() + "\n")
}

console.log("functionDefinitions: " + model.getNumFunctionDefinitions());
console.log("    unitDefinitions: " + model.getNumUnitDefinitions());
console.log("   compartmentTypes: " + model.getNumCompartmentTypes());
console.log("        specieTypes: " + model.getNumSpeciesTypes());
console.log("       compartments: " + model.getNumCompartments());
console.log("            species: " + model.getNumSpecies());
console.log("         parameters: " + model.getNumParameters());
console.log(" initialAssignments: " + model.getNumInitialAssignments());
console.log("              rules: " + model.getNumRules());
console.log("        constraints: " + model.getNumConstraints());
console.log("          reactions: " + model.getNumReactions());
console.log("             events: " + model.getNumEvents());
console.log("\n")

process.exit(0);
