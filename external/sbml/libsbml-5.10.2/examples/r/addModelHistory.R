# 
# \file    addModelHistory.R
# \brief   adds Model History to a model
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
#
# Usage: R --slave -f addModelHistory.R --args <input-filename> <output-filename>
#
#
library(libSBML)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2) {
  stop(
         "  usage: addModelHistory <input-filename> <output-filename>\n"
      );
}

printStatus <- function(message,status) {
    enumStatus <- enumFromInteger(status, "_OperationReturnValues_t" )
	cat(message, switch(enumStatus, 
		LIBSBML_OPERATION_SUCCESS = "succeeded", 
		LIBSBML_INVALID_OBJECT = "invalid object", 
		LIBSBML_OPERATION_FAILED = "operation failed", 
		LIBSBML_UNEXPECTED_ATTRIBUTE = "unexpected attribute (missing metaid)", 
		"unknown"), "\n");
}

d      = readSBML(args[1]);
errors = SBMLDocument_getNumErrors(d);

if (errors > 0) {
  cat("Read Error(s):\n");
  SBMLDocument_printErrors(d);	 
  cat("Correct the above and re-run.\n");
} else {

  h = ModelHistory();
  c = ModelCreator();

  ModelCreator_setFamilyName(c, "Keating");
  ModelCreator_setGivenName(c, "Sarah");
  ModelCreator_setEmail(c, "sbml-team@caltech.edu");
  ModelCreator_setOrganisation(c, "University of Hertfordshire");

  status = ModelHistory_addCreator(h, c);
  printStatus("Status for addCreator: ", status);
  
  date = Date("1999-11-13T06:54:32");
  date2 = Date("2007-11-30T06:54:00-02:00");
     
  status = ModelHistory_setCreatedDate(h, date);
  printStatus("Set created date:      ", status);

  status = ModelHistory_setModifiedDate(h, date2);
  printStatus("Set modified date:     ", status);

  m = SBMLDocument_getModel(d);
  status =  SBase_setModelHistory(m, h);
  printStatus("Set model history:     ", status);

  writeSBML(d, args[2]);
}

q(status=errors);

