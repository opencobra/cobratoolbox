//!/usr/bin/env node
//
// @file    printMath.js
// @brief   Prints Rule, Reaction, and Event formulas in a given SBML Document
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

function printFunctionDefinition(n, fd)
{
  if (!fd.isSetMath())
    return;

  console.log("FunctionDefinition " + n + ", " + fd.getId());

  var math = fd.getMath();

  // Print function arguments.
  if (math.getNumChildren() > 1)
  {
    console.log("(" + (math.getLeftChild()).getName());

    for ( n=1; n < math.getNumChildren(); n++)
    {
      console.log(", " + (math.getChild(n)).getName());
    }
  }

  console.log(") := ");

  // Print function body.
  if (math.getNumChildren() == 0)
  {
    console.log("(no body defined)");
  }
  else
  {
    math = math.getChild(math.getNumChildren() - 1);
    formula = sbml.formulaToString(math);
    console.log(formula);
  }
}


function printRuleMath(n, r)
{
  if (!r.isSetMath())
    return;

  var formula = sbml.formulaToString(r.getMath());

  if (r.isSetVariable())
  {
    console.log("Rule " + n + ", formula: "
                + r.getVariable() + " = " + formula);
  }
  else
  {
    console.log("Rule " + n + ", formula: "
                + formula + " = 0");
  }
}


function printReactionMath(n, r)
{
  if (!r.isSetKineticLaw())
    return;

  var kl = r.getKineticLaw();
  if (!kl.isSetMath())
    return;

  var formula = sbml.formulaToString(kl.getMath());
  console.log("Reaction " + n + ", formula: " + formula);
}

function printEventAssignmentMath(n, ea)
{
  if (!ea.isSetMath())
    return;

  var variable = ea.getVariable();
  var formula = sbml.formulaToString(ea.getMath());
  console.log("  EventAssignment " + n
              + ", trigger: " + variable + " = " + formula);
}

function printEventMath(n, e)
{
  if (e.isSetDelay())
  {
    var formula = sbml.formulaToString(e.getDelay().getMath());
    console.log("Event " + n + " delay: " + formula);
  }

  if (e.isSetTrigger())
  {
    var formula = formulaToString(e.getTrigger().getMath());
    console.log("Event " + n + " trigger: " + formula);
  }

  for (i=0; i < e.getNumEventAssignments(); i++)
  {
    printEventAssignmentMath(i + 1, e.getEventAssignment(i));
  }

}

function printMath(m)
{
  for (n = 0; n < m.getNumFunctionDefinitions(); n++)
  {
    printFunctionDefinition(n + 1, m.getFunctionDefinition(n));
  }

  for (n = 0; n < m.getNumRules(); n++)
  {
    printRuleMath(n + 1, m.getRule(n));
  }

  for (n = 0; n < m.getNumReactions(); n++)
  {
    printReactionMath(n + 1, m.getReaction(n));
  }

  for (n = 0; n < m.getNumEvents(); n++)
  {
    printEventMath(n + 1, m.getEvent(n));
  }
}


if (process.argv.length != 3)
{
  console.log("\n" + "Usage: node printMath.js filename");
  process.exit(1);
}

var filename = process.argv[2];
var document = sbml.readSBML(filename);

if (document.getNumErrors() > 0)
{
  console.log("Encountered the following SBML errors:");
  document.printErrors();
  process.exit(1)
}

var model = document.getModel();

if (model == null)
{
  console.log("No model present.");
  process.exit(1);
}

printMath(model);
