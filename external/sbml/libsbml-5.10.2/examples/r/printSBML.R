# 
# @file    printSBML.R
# @brief   Prints some information about the top-level model
# @author  Frank Bergmann
# 
# <!--------------------------------------------------------------------------
# This sample program is distributed under a different license than the rest
# of libSBML.  This program uses the open-source MIT license, as follows:
#
# Copyright (c) 2013-2014 by the California Institute of Technology
# (California, USA), the European Bioinformatics Institute (EMBL-EBI, UK)
# and the University of Heidelberg (Germany), with support from the National
# Institutes of Health (USA) under grant R01GM070923.  All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#
# Neither the name of the California Institute of Technology (Caltech), nor
# of the European Bioinformatics Institute (EMBL-EBI), nor of the University
# of Heidelberg, nor the names of any contributors, may be used to endorse
# or promote products derived from this software without specific prior
# written permission.
# ------------------------------------------------------------------------ -->
# 
#
# Usage: R --slave -f printSBML.R --args <full path to input file>
#
library(libSBML)


args <- commandArgs(trailingOnly = TRUE)


if (length(args) != 1)
{
  stop("Usage: printSBML input-filename\n");
}


filename = args[1];
d        = readSBML(filename);
errors   = SBMLDocument_getNumErrors(d);
SBMLDocument_printErrors(d);

m = SBMLDocument_getModel(d);

level   = SBase_getLevel  (d);
version = SBase_getVersion(d);

cat("\n");
cat("File: ",filename," (Level ",level,", version ",version,")\n");

if (errors > 0) {
  stop("No model present.");  
}

cat("         ");
cat("  model id: ", ifelse(Model_isSetId(m), Model_getId(m) ,"(empty)"),"\n");

cat( "functionDefinitions: ", Model_getNumFunctionDefinitions(m) ,"\n" );
cat( "    unitDefinitions: ", Model_getNumUnitDefinitions    (m) ,"\n" );
cat( "   compartmentTypes: ", Model_getNumCompartmentTypes   (m) ,"\n" );
cat( "        specieTypes: ", Model_getNumSpeciesTypes       (m) ,"\n" );
cat( "       compartments: ", Model_getNumCompartments       (m) ,"\n" );
cat( "            species: ", Model_getNumSpecies            (m) ,"\n" );
cat( "         parameters: ", Model_getNumParameters         (m) ,"\n" );
cat( " initialAssignments: ", Model_getNumInitialAssignments (m) ,"\n" );
cat( "              rules: ", Model_getNumRules              (m) ,"\n" );
cat( "        constraints: ", Model_getNumConstraints        (m) ,"\n" );
cat( "          reactions: ", Model_getNumReactions          (m) ,"\n" );
cat( "             events: ", Model_getNumEvents             (m) ,"\n" );
cat( "\n" );

q(status=0);

