//!/usr/bin/env node
//
// 
// @file    printUnits.js
// @brief   Prints some unit information about the model
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
// 


var sbml = require('sbml');


if (process.argv.length != 3)
{
  console.log("Usage: node printUnits.js filename");
  process.exit(1);
}

var filename = process.argv[2];
var document = sbml.readSBML(filename);

if (document.getNumErrors() > 0)
{
  console.log("Encountered the following SBML errors:");
  document.printErrors();
  process.exit(1);
}

var model = document.getModel();

if (model == null)
{
  console.log("No model present.");
  process.exit(1);
}

for (i = 0; i < model.getNumSpecies(); i++)
{
  var s = model.getSpecies(i);
  console.log("Species " + i + ": " + sbml.UnitDefinition.printUnits(s.getDerivedUnitDefinition()));
}

for (i = 0; i < model.getNumCompartments(); i++)
{
  var c = model.getCompartment(i);
  console.log("Compartment " + i + ": " + sbml.UnitDefinition.printUnits(c.getDerivedUnitDefinition()));
}

for (i = 0; i < model.getNumParameters(); i++)
{
  var p = model.getParameter(i);
  console.log("Parameter " + i + ": " + sbml.UnitDefinition.printUnits(p.getDerivedUnitDefinition()));
}

for (i = 0; i < model.getNumInitialAssignments(); i++)
{
  var ia = model.getInitialAssignment(i);
  console.log("InitialAssignment " + i + ": " + sbml.UnitDefinition.printUnits(p.getDerivedUnitDefinition()));
  var tmp = "no";
  if (ia.containsUndeclaredUnits())
  {
	  tmp = "yes"
  }
  console.log("        undeclared units: "+ tmp);
}

for (i = 0; i < model.getNumInitialAssignments(); i++)
{
  var e = model.getEvent(i);
  console.log("Event " + i);


  if (e.isSetDelay())
  {
    console.log("\n\tDelay: " + sbml.UnitDefinition.printUnits(e.getDelay().getDerivedUnitDefinition()))
    var tmp = "no";
    if (e.getDelay().containsUndeclaredUnits())
    {
	    tmp = "yes";
    }
    console.log("        undeclared units: " + tmp);
  }

  for (j = 0; j < e.getNumEventAssignments(); j++)
  {
    var ea = e.getEventAssignment(j);
    console.log("\n\tEventAssignment " + j+": "+ sbml.UnitDefinition.printUnits(ea.getDerivedUnitDefinition()));
    var tmp = "no";
    if (ea.containsUndeclaredUnits())
    {
      tmp = "yes";
    }
    console.log("        undeclared units: " + tmp);
  }
}

for (i = 0; i < model.getNumReactions(); i++)
{
  var r = model.getReaction(i);

  console.log("\nReaction " + i);

  if (r.isSetKineticLaw())
  {
    console.log("Kinetic Law: " + sbml.UnitDefinition.printUnits(r.getKineticLaw().getDerivedUnitDefinition()));
    var tmp = "no";
    if (r.getKineticLaw().containsUndeclaredUnits())
    {
	     tmp = "yes";
    }
    console.log("        undeclared units: " + tmp);
  }

  for (j = 0; j < r.getNumReactants(); j++)
  {
    var sr = r.getReactant(j);

    if (sr.isSetStoichiometryMath())
    {
      console.log("Reactant stoichiometryMath " + j + ": " + sbml.UnitDefinition.printUnits(sr.getStoichiometryMath().getDerivedUnitDefinition()));
      var tmp = "no";
      if (sr.getStoichiometryMath().containsUndeclaredUnits())
      {
        tmp = "yes";
      }
      console.log("        undeclared units: " + tmp);
    }
  }

  for (j = 0; j < r.getNumReactants(); j++)
  {
    var sr = r.getProduct(j);

    if (sr.isSetStoichiometryMath())
    {
      console.log("Product stoichiometryMath " + j +": " + sbml.UnitDefinition.printUnits(sr.getStoichiometryMath().getDerivedUnitDefinition()));
      var tmp = "no";
      if (sr.getStoichiometryMath().containsUndeclaredUnits())
      {
	      tmp = "yes";
      }
      console.log("        undeclared units: " + tmp);
    }
  }
}

for (i = 0; i < model.getNumRules(); i++)
{
  var r = model.getRule(i);
  console.log("\nRule " + i +": " + sbml.UnitDefinition.printUnits(r.getDerivedUnitDefinition()));
  var tmp = "no";
  if (r.getStoichiometryMath().containsUndeclaredUnits())
  {
	  tmp = "yes"
  }

  console.log("        undeclared units: " + tmp)
}

process.exit(0);

