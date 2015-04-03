# 
# \file    addCVTerms.R
# \brief   adds controlled vocabulary terms to a species in a model
# \author  Frank Bergmann
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
# This file is part of libSBML.  Please visit http://sbml.org for more
# information about SBML, and the latest version of libSBML.
# 
#
# Usage: R --slave -f addCVTerms.R --args <input-filename> <output-filename>
#
#

library(libSBML)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2)
{
  stop("Usage: addCVTerms <input-filename> <output-filename>\nAdds controlled vocabulary term to a species\n");
}


d      <- readSBML(args[1])
errors <- SBMLDocument_getNumErrors(d)

if (errors > 0) {
  cat("Read Error(s):\n")
  SBMLDocument_printErrors(d)
  cat("Correct the above and re-run.\n")
} else {
  m <- SBMLDocument_getModel(d)
  n <- Model_getNumSpecies(m)
 
  if (n <= 0) {
    cat( "Model has no species.\n Cannot add CV terms\n")
  } else {
    s <- Model_getSpecies(m ,0)
	if (SBase_isSetMetaId(s) == FALSE)
		SBase_setMetaId(s, "__meta2501")
    cv <- CVTerm("BIOLOGICAL_QUALIFIER")
    CVTerm_setBiologicalQualifierType(cv, "BQB_IS_VERSION_OF")
    CVTerm_addResource(cv, "http://www.geneontology.org/#GO:0005892")

    cv2 <- CVTerm("BIOLOGICAL_QUALIFIER")
    CVTerm_setBiologicalQualifierType(cv2, "BQB_IS")
    CVTerm_addResource(cv2, "http://www.geneontology.org/#GO:0005895")
	
    cv1 <- CVTerm("BIOLOGICAL_QUALIFIER")
    CVTerm_setBiologicalQualifierType(cv1, "BQB_IS_VERSION_OF")
    CVTerm_addResource(cv1, "http://www.ebi.ac.uk/interpro/#IPR002394")

    SBase_addCVTerm(s, cv)
    SBase_addCVTerm(s, cv2)
    SBase_addCVTerm(s, cv1)

	
    writeSBML(d, args[2])
  }
}


