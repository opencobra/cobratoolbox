# 
# @file    convertSBML.R
# @brief   Converts SBML documents between levels
# @author  Frank Bergmann
# 
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
# Usage: R --slave -f convertSBML.R --args <input-filename> <output-filename>
#
#

library(libSBML)

args <- commandArgs(trailingOnly = TRUE)

latestLevel   = SBMLDocument_getDefaultLevel();
latestVersion = SBMLDocument_getDefaultVersion();

if (length(args) != 2) {
  stop(
		paste(
         "Usage: convertSBML <input-filename> <output-filename>\n",
		 "This program will attempt to convert a model either to\n",
         "SBML Level ",latestLevel," Version ",latestVersion," (if the model is not already) or, if",
	     "the model is already expressed in Level ",latestLevel," Version ",latestVersion,", this\n",
	     "program will attempt to convert the model to Level 1 Version 2.\n",
		 sep = "")
      );
}

d      = readSBML(args[1]);
errors = SBMLErrorLog_getNumFailsWithSeverity(
			SBMLDocument_getErrorLog(d), 
			enumToInteger("LIBSBML_SEV_ERROR", "_XMLErrorSeverity_t")
		 );

if (errors > 0) {
  cat("Encountered the following SBML error(s):\n");
  SBMLDocument_printErrors(d);
  stop("Conversion skipped.  Please correct the problems above first.\n");
} else {
  olevel   = SBase_getLevel(d);
  oversion = SBase_getVersion(d);
  
  if (olevel < latestLevel || oversion < latestVersion) {
    cat("Attempting to convert model to SBML Level ",latestLevel," Version ",latestVersion,".\n");
    success = SBMLDocument_setLevelAndVersion(d, latestLevel, latestVersion);
  } else {
    cat("Attempting to convert model to SBML Level 1 Version 2.\n");
    success = SBMLDocument_setLevelAndVersion(d, 1, 2);
  }

  errors = SBMLErrorLog_getNumFailsWithSeverity(
			SBMLDocument_getErrorLog(d), 
			enumToInteger("LIBSBML_SEV_ERROR", "_XMLErrorSeverity_t")
		 );

  if (!success) {
    cat("Unable to perform conversion due to the following:\n");
    SBMLDocument_printErrors(d);

    cat("Conversion skipped.  Either libSBML does not (yet) have\n");
    cat("ability to convert this model, or (automatic) conversion\n");
    cat("is not possible in this case.\n");
  } else if (errors > 0) {
    cat("Information may have been lost in conversion; but a valid model ");
    cat("was produced by the conversion.\nThe following information ");
    cat("was provided:\n");
    SBMLDocument_printErrors(d);
    writeSBML(d, args[2]);
  } else { 	    
    cat("Conversion completed.\n");
    writeSBML(d, args[2]);
  }
}

q(status=errors);
