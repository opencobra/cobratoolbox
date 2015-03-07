//!/usr/bin/env node
//
//
// @file    printAnnotation.js
// @brief   prints annotation strings for each element
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


function printAnnotation(sb, id)
{
  id = id || "";
  if (!sb.isSetAnnotation())
    return;

  var pid = "";

  if (sb.isSetId())
    pid = sb.getId();


  console.log("-----  " + sb.getElementName() + " (" + pid + ") annotation -----");
  console.log(sb.getAnnotationString());

}


if (process.argv.length != 3)
{
  console.log("Usage: node printAnnotation.js filename");
  process.exit(1)
}

var filename = process.argv[2];
var document = sbml.readSBML(filename);

var errors = document.getNumErrors

console.log("filename: " + filename);

if (errors > 0)
{
  document.printErrors();
  process.exit(errors);
}


// Model

var m = document.getModel();
printAnnotation(m);

var elements = m.getListOfAllElements();
for (i = 0;i < elements.getSize(); i++)
{
  var current = elements.get(i);
  printAnnotation(current);
}

process.exit(errors)
