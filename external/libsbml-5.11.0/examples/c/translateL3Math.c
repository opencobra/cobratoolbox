/**
 * @file    translateL3Math.c
 * @brief   Translates infix formulas into MathML and vice-versa, using the L3 parser instead of the old L1 parser.
 * @author  Sarah Keating
 * @author  Ben Bornstein
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

#include <sbml/SBMLTypes.h>
#include "util.h"


#define BUFFER_SIZE 1024


char *translateInfix  (const char *formula, L3ParserSettings_t* settings);
char *translateMathML (const char *xml);


int
main (int argc, char* argv[])
{
  char         *line;
  char         *result;
  char         *buffer  = (char*)calloc( 1, sizeof(char) );
  unsigned long len;
  L3ParserSettings_t* settings;
  int           reading = 1;
  SBMLDocument_t*   doc = NULL;


  printf( "\n" );
  printf( "This program translates infix formulas into MathML and\n" );
  printf( "vice-versa.  An 'enter' or a 'return' on an empty line\n" );
  printf( "triggers translation.\n" );
  printf( "\n" );

  settings = L3ParserSettings_create();
  while (reading)
  {
    printf( "Enter infix formula, MathML expression, \n");
    printf( "or change parsing rules with the keywords:\n");
    printf( "LOG_AS_LOG10, LOG_AS_LN, LOG_AS_ERROR, EXPAND_UMINUS, ");
    printf( "COLLAPSE_UMINUS, TARGETL2, TARGETL3, NO_UNITS, UNITS, ");
    printf( "or FILE:<filename>\n\n\n" );
    printf( "> " );

    do
    {
      line = trim_whitespace(get_line(stdin));
      len  = (unsigned int)strlen(line);

      if (len > 0)
      {
        buffer = (char *) realloc( buffer, 1 + strlen(buffer) + len );

        if (strcmp(line, "LOG_AS_LOG10")==0) {
          L3ParserSettings_setParseLog(settings, L3P_PARSE_LOG_AS_LOG10);
          printf( "Now parsing 'log(x)' as 'log10(x)'\n\n> ");
        }
        else if (strcmp(line, "LOG_AS_LN")==0) {
          L3ParserSettings_setParseLog(settings, L3P_PARSE_LOG_AS_LN);
          printf( "Now parsing 'log(x)' as 'ln(x)'\n\n> ");
        }
        else if (strcmp(line, "LOG_AS_ERROR")==0) {
          L3ParserSettings_setParseLog(settings, L3P_PARSE_LOG_AS_ERROR);
          printf( "Now parsing 'log(x)' as an error\n\n> ");
        }
        else if (strcmp(line, "EXPAND_UMINUS")==0) {
          L3ParserSettings_setParseCollapseMinus(settings, 0);
          printf( "Will now leave multiple unary minuses expanded, ");
          printf("and all negative numbers will be translated using the ");
          printf("<minus> construct.\n\n> ");
        }
        else if (strcmp(line, "COLLAPSE_UMINUS")==0) {
          L3ParserSettings_setParseCollapseMinus(settings, 1);
          printf( "Will now collapse multiple unary minuses, and incorporate ");
          printf("a negative sign into digits.\n\n> ");
        }
        else if (strcmp(line, "NO_UNITS")==0) {
          L3ParserSettings_setParseUnits(settings, 0);
          printf( "Will now target MathML but with no units on numbers.\n\n> ");
        }
        else if (strcmp(line, "UNITS")==0) {
          L3ParserSettings_setParseUnits(settings, 1);
          printf( "Will now target MathML but with units on numbers.\n\n> ");
        }
        else if (line[0] == 'F' && line[1] == 'I' && line[2]=='L' 
          && line[3]=='E' && line[4]==':') {
		  int len = strlen(line);
		  char *filename = (char*) malloc(len-5+1);
		  strncpy(filename, line+5, len-5);
		  SBMLDocument_free(doc);
          doc = readSBMLFromFile(filename);
          if (SBMLDocument_getModel(doc)==NULL) {
            printf( "File '%s' not found or no model present.", filename);
            printf( "Clearing the Model parsing object.\n\n> ");
          }
          else {
            printf( "Using model from file %s to parse infix:", filename);
            printf( "all symbols present in that model will not be translated ");
            printf( "as native MathML or SBML-defined elements.\n\n> ");;
          }
          L3ParserSettings_setModel(settings, SBMLDocument_getModel(doc));
        }
        else
        {
          strncat(buffer, line, len);
          strncat(buffer, "\n", 1);
        }
      }
      else
      {
        result = (buffer[0] == '<') ?
          translateMathML(buffer) : translateInfix(buffer, settings);

        printf("Result:\n\n%s\n\n\n", result);

        free(result);
        reading = 0;
      }
    }
    while (len > 0);

  }

  free(line);
  return 0;
}


/**
 * Translates the given infix formula into MathML.
 *
 * @return the MathML as a string.  The caller owns the memory and is
 * responsible for freeing it.
 */
char *
translateInfix (const char* formula, L3ParserSettings_t* settings)
{
  char*    result;
  ASTNode_t* math = SBML_parseL3FormulaWithSettings(formula, settings);

  if (math==NULL) {
    result = SBML_getLastParseL3Error();
  }
  else {
    result = writeMathMLToString(math);
    ASTNode_free(math);
  }
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
translateMathML (const char* xml)
{
  char*           result;
  ASTNode_t*      math;

  math   = readMathMLFromString(xml);
  result = SBML_formulaToString(math);

  ASTNode_free(math);
  return result;
}
