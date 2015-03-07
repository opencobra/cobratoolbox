//!/usr/bin/env node
//
// @file    translateMath.js
// @brief   Translates infix formulas into MathML and vice-versa
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
var readline = require('readline');

//
// Translates the given infix formula into MathML.
//
// @return the MathML as a string.  The caller owns the memory and is
// responsible for freeing it.
//
function translateInfix(formula)
{
  var math = sbml.parseFormula(formula);
  return sbml.writeMathMLToString(math);
}

// 
// Translates the given MathML into an infix formula.  The MathML must
// contain no leading whitespace, but an XML header is optional.
// 
// @return the infix formula as a string.  The caller owns the memory and
// is responsible for freeing it.
// 
function translateMathML(xml)
{
  var math = sbml.readMathMLFromString(xml);
  return sbml.formulaToString(math);
}

var rl = readline.createInterface({
                                  input: process.stdin,
                                  output: process.stdout,
                                  terminal: false
                                  });


// don't print the exception

console.log("This program translates infix formulas into MathML and");
console.log("vice-versa.  Enter triggers");
console.log("translation. Ctrl-C quits");

console.log("Enter infix formula or MathML expression (Ctrl-C to quit):");
console.log("> ");
rl.on('line', function (answer) {

      var result = "";

      if (answer.indexOf("<") == 0)
      {
    	  result = translateMathML(answer)
      }
              else
      {
    	  result =  translateInfix(answer)
      }

      console.log("Result:\n\n " + result + "\n\n");

      console.log("Enter infix formula or MathML expression (Ctrl-C to quit):");
      console.log("> ");

  });
