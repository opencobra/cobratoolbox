//!/usr/bin/env node
//
// 
// @file    unsetNotes.js
// @brief   unset notes for each element
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


if (process.argv.length != 4)
{
    console.log("\nUsage: node unsetNotes.js <input-filename> <output-filename>" + "\n" + "\n")
    process.exit(1);
}

var filename = process.argv[2];

var document = sbml.readSBML(filename);


var errors = document.getNumErrors();

if (errors > 0)
{
  document.printErrors();
  process.exit(errors);
}

var m = document.getModel();
m.unsetNotes();

for (i = 0; i < m.getNumReactions(); i++)
{
  var re = m.getReaction(i);
  re.unsetNotes();

  for (j = 0; j < re.getNumReactants(); j++)
  {
    var rt = re.getReactant(j);
    rt.unsetNotes();
  }
  for (j = 0; j < re.getNumProducts(); j++)
  {
    var rt = re.getProduct(j);
    rt.unsetNotes();
  }
  for (j = 0; j < re.getNumModifiers(); j++)
  {
    var md = re.getModifier(j);
    md.unsetNotes();
  }
  if (re.isSetKineticLaw())
  {
    var kl = re.getKineticLaw();
    kl.unsetNotes();

    for (j = 0; j < kl.getNumParameters(); j++)
    {
      var pa = kl.getParameter(j);
      pa.unsetNotes();
    }
  }
}

for (i = 0; i < m.getNumSpecies(); i++)
{
  var sp = m.getSpecies(i);
  sp.unsetNotes();
}

for (i = 0; i < m.getNumCompartments(); i++)
{
    var sp = m.getCompartment(i)
    sp.unsetNotes
}

for (i = 0; i < m.getNumFunctionDefinitions(); i++)
{
  var sp = m.getFunctionDefinition(i);
  sp.unsetNotes();
}

for (i = 0; i < m.getNumUnitDefinitions(); i++)
{
  var sp = m.getUnitDefinition(i);
  sp.unsetNotes();
}

for (i = 0; i < m.getNumParameters(); i++)
{
  var sp = m.getParameter(i);
  sp.unsetNotes();
}

for (i = 0; i < m.getNumRules(); i++)
{
  var sp = m.getRule(i);
  sp.unsetNotes();
}

for (i = 0; i < m.getNumInitialAssignments(); i++)
{
  var sp = m.getInitialAssignment(i);
  sp.unsetNotes();
}

for (i = 0; i < m.getNumEvents(); i++)
{
  var sp = m.getEvent(i);
  sp.unsetNotes();

  for (j = 0; j < sp.getNumEventAssignments(); j++)
  {
    var  ea = sp.getEventAssignment(j);
    ea.unsetNotes();
  }
}

for (i = 0; i < m.getNumSpeciesTypes(); i++)
{
  var sp = m.getSpeciesType(i);
  sp.unsetNotes();
}

for (i = 0; i < m.getNumConstraints(); i++)
{
  var sp = m.getConstraint(i);
  sp.unsetNotes();
}

sbml.writeSBML(document, process.argv[3])

process.exit(errors);
