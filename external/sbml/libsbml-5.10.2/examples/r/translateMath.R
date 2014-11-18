# 
# @file    translateMath.R
# @brief   Translates infix formulas into MathML and vice-versa
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
# Usage: R --slave -f translateMath.R 
#
#

library(libSBML)

# Utility function to read a line from stdin
#
getline <- function() {
	f <- file("stdin")
	open(f)
	line = readLines(f,n=1)
	close(f)
	return (line)
}

# Utility function to trim the string
trim <- function(str) {
  return(gsub("(^ +)|( +$)", "", str))
}

# 
# Translates the given infix formula into MathML.
# 
# @return the MathML as a string.  The caller owns the memory and is
# responsible for freeing it.
# 
translateInfix <- function(formula) {

  math = parseFormula(formula);
  result = writeMathMLToString(math);
  
  return (result);
}


# 
# Translates the given MathML into an infix formula.  The MathML must
# contain no leading whitespace, but an XML header is optional.
# 
# @return the infix formula as a string.  The caller owns the memory and
# is responsible for freeing it.
# 
translateMathML <- function(xml) {
  # 
  # Prepend an XML header if not already present.
  #   
  if (substring(trim(xml),1, 2) != '<?') {
    header  = "<?xml version='1.0' encoding='UTF-8'?>\n";    
    math = readMathMLFromString(paste(header, xml));    
	return( formulaToString(math))
  } else {    
    math = readMathMLFromString(xml);
	return( formulaToString(math))
  }
}




cat( "\n" );
cat( "This program translates infix formulas into MathML and\n" );
cat( "vice-versa.  An 'enter' or a 'return' on an empty line\n" );
cat( "triggers translation. Ctrl-C quits\n" );
cat( "\n" );

while (TRUE) {
  cat( "Enter an infix formula or MathML expression (Ctrl-C to quit):\n" );
  cat( "\n" );
  cat( "> " );

  buffer = "" 
  
  repeat { 
    line = trim(getline());
    len  = nchar(line);

    if (len > 0) {
	  buffer = paste(buffer, line ,"\n", sep="");
    } else {
      if(substring(trim(buffer), 1,1) == "<") {
	    result = translateMathML(buffer)
      } else {
        result = translateInfix(buffer)
	  }
      cat("Result:\n\n",result,"\n\n\n");

      buffer = ""
	  break;
    }
  }
}

q(status=0);


