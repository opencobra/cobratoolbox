/**
 * @file    translateMath.c
 * @brief   Translates infix formulas into MathML and vice-versa
 * @author  Ben Bornstein
 * @author  Michael Hucka
 *
 * <!--------------------------------------------------------------------------
 * This sample program is distributed under a different license than the rest
 * of libSBML.  This program uses the open-source MIT license, as follows:
 *
 * Copyright (c) 2013-2014 by the California Institute of Technology
 * (California, USA), the European Bioinformatics Institute (EMBL-EBI, UK)
 * and the University of Heidelberg (Germany), with support from the National
 * Institutes of Health (USA) under grant R01GM070923.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Neither the name of the California Institute of Technology (Caltech), nor
 * of the European Bioinformatics Institute (EMBL-EBI), nor of the University
 * of Heidelberg, nor the names of any contributors, may be used to endorse
 * or promote products derived from this software without specific prior
 * written permission.
 * ------------------------------------------------------------------------ -->
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/FormulaParser.h>
#include <sbml/math/MathML.h>

#include "util.h"


char *translateInfix  (const char *formula);
char *translateMathML (const char *xml);

int
main (int argc, char *argv[])
{
  char         *line;
  char         *result;
  char         *buffer  = (char*)calloc( 1, sizeof(char) );
  int           reading = 1;
  unsigned long len;


  printf( "\n" );
  printf( "This program translates infix formulas into MathML and\n" );
  printf( "vice-versa.  An 'enter' or a 'return' on an empty line\n" );
  printf( "triggers translation. Ctrl-C quits\n" );
  printf( "\n" );

  while (reading)
  {
    printf( "Enter an infix formula or MathML expression (Ctrl-C to quit):\n" );
    printf( "\n" );
    printf( "> " );

    do
    {
      line = trim_whitespace(get_line(stdin));
      len  = (unsigned int)strlen(line);

      if (len > 0)
      {
        buffer = (char *) realloc( buffer, 1 + strlen(buffer) + len );

        strncat(buffer, line, len);
        strncat(buffer, "\n", 1);
      }
      else
      {
        result = (buffer[0] == '<') ?
          translateMathML(buffer) : translateInfix(buffer);

        printf("Result:\n\n%s\n\n\n", result);

        free(result);
        reading = 0;
      }
    }
    while (len > 0);
  }

  free(line);
  free(buffer);
  return 0;
}


/**
 * Translates the given infix formula into MathML.
 *
 * @return the MathML as a string.  The caller owns the memory and is
 * responsible for freeing it.
 */
char *
translateInfix (const char *formula)
{
  char      *result;
  ASTNode_t *math = SBML_parseFormula(formula);

  result = writeMathMLToString(math);
  ASTNode_free(math);

  return result;
}


/**
 * Translates the given MathML into an infix formula.  The MathML must
 * contain no leading whitespace, but an XML header is optional.
 *
 * @return the infix formula as a string.  The caller owns the memory and
 * is responsible for freeing it.
 */
char *
translateMathML (const char *xml)
{
  char           *result;
  ASTNode_t      *math;

  /**
   * Prepend an XML header if not already present.
   */
  if (xml[0] == '<' && xml[1] != '?')
  {
    char *header  = "<?xml version='1.0' encoding='UTF-8'?>\n";
    char *content = (char *) calloc( strlen(xml) + strlen(header) + 1, sizeof(char) );

    strncat(content, header, strlen(header));
    strncat(content, xml, strlen(xml));

    math = readMathMLFromString(content);
    free(content);
  }
  else
  {
    math = readMathMLFromString(xml);
  }

  result = SBML_formulaToString(math);

  ASTNode_free(math);
  return result;
}

