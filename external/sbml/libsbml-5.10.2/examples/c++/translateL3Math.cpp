/**
 * @file    translateL3Math.cpp
 * @brief   Translates infix formulas into MathML and vice-versa, using the L3 parser instead of the old L1 parser.
 * @author  Lucian Smith
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


#include <iostream>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sbml/SBMLTypes.h>


#define BUFFER_SIZE 1024


using namespace std;
LIBSBML_CPP_NAMESPACE_USE

char *translateInfix  (const char *formula, const L3ParserSettings& settings);
char *translateMathML (const char *xml);


int
main (int argc, char* argv[])
{
  char            line[BUFFER_SIZE];
  char*           trimmed;
  char*           result;
  char*           str;
  unsigned int    len;
  SBMLDocument*   doc = NULL;
  StringBuffer_t* sb = StringBuffer_create(1024);


  cout << endl 
       << "This program translates L3 infix formulas into MathML and" << endl
       << "vice-versa.  Enter or return on an empty line triggers" << endl
       << "translation. Ctrl-C quits" << endl
       << endl;

  L3ParserSettings settings;
  while (1)
  {
    cout << "Enter infix formula, MathML expression, or change parsing rules with the keywords:\nLOG_AS_LOG10, LOG_AS_LN, LOG_AS_ERROR, EXPAND_UMINUS, COLLAPSE_UMINUS, TARGETL2, TARGETL3, NO_UNITS, UNITS, or FILE:<filename>\n(Ctrl-C to quit):"
         << endl << endl;
    cout << "> " ;

    cin.getline(line, BUFFER_SIZE, '\n');

    while (line != 0)
    {
      trimmed = util_trim(line);
      len     = strlen(trimmed);

      if (len > 0)
      {
        if (strcmp(line, "LOG_AS_LOG10")==0) {
          settings.setParseLog(L3P_PARSE_LOG_AS_LOG10);
          cout << "Now parsing 'log(x)' as 'log10(x)'" << endl << endl << "> ";
        }
        else if (strcmp(line, "LOG_AS_LN")==0) {
          settings.setParseLog(L3P_PARSE_LOG_AS_LN);
          cout << "Now parsing 'log(x)' as 'ln(x)'" << endl << endl << "> ";
        }
        else if (strcmp(line, "LOG_AS_ERROR")==0) {
          settings.setParseLog(L3P_PARSE_LOG_AS_ERROR);
          cout << "Now parsing 'log(x)' as an error" << endl << endl << "> ";
        }
        else if (strcmp(line, "EXPAND_UMINUS")==0) {
          settings.setParseCollapseMinus(L3P_EXPAND_UNARY_MINUS);
          cout << "Will now leave multiple unary minuses expanded, and all negative numbers will be translated using the <minus> construct." << endl << endl << "> ";
        }
        else if (strcmp(line, "COLLAPSE_UMINUS")==0) {
          settings.setParseCollapseMinus(L3P_COLLAPSE_UNARY_MINUS);
          cout << "Will now collapse multiple unary minuses, and incorporate a negative sign into digits." << endl << endl << "> ";
        }
        else if (strcmp(line, "TARGETL2")==0) {
          settings.setParseUnits(false);
          settings.setParseAvogadroCsymbol(false);
          cout << "Will now target SBML Level 2 MathML, with no units on numbers, and no csymbol 'avogadro'." << endl << endl << "> ";
        }
        else if (strcmp(line, "NO_UNITS")==0) {
          settings.setParseUnits(false);
          cout << "Will now target MathML but with no units on numbers." << endl << endl << "> ";
        }
        else if (strcmp(line, "UNITS")==0) {
          settings.setParseUnits(true);
          cout << "Will now target MathML but with units on numbers." << endl << endl << "> ";
        }
        else if (strcmp(line, "TARGETL3")==0) {
          settings.setParseUnits(true);
          settings.setParseAvogadroCsymbol(true);
          cout << "Will now target SBML Level 3 MathML, including having units on numbers, and the csymbol 'avogadro'." << endl << endl << "> ";
        }
        else if (line[0] == 'F' && line[1] == 'I' && line[2]=='L' && line[3]=='E' && line[4]==':') {
          string filename(line);
          filename = filename.substr(5, filename.size());
          delete doc;
          doc = readSBMLFromFile(filename.c_str());
          if (doc->getModel()==NULL) {
            cout << "File '" << filename << "' not found or no model present.  Clearing the Model parsing object." << endl << endl << "> ";
          }
          else {
            cout << "Using model from file " << filename << " to parse infix:  all symbols present in that model will not be translated as native MathML or SBML-defined elements." << endl << endl << "> ";
          }
          settings.setModel(doc->getModel());
        }
        else {
          StringBuffer_append    (sb, trimmed);
          StringBuffer_appendChar(sb, ' ');
        }
      }
      else
      {
        str    = StringBuffer_getBuffer(sb);
        result = (str[0] == '<') ? translateMathML(str) : translateInfix(str, settings);

        cout << "Result:" << endl << endl << result << endl << endl << endl;

        StringBuffer_reset(sb);
        break;
      }

      cin.getline(line, BUFFER_SIZE, '\n');
    }
  }

  StringBuffer_free(sb);
  return 0;
}


/**
 * Translates the given infix formula into MathML.
 *
 * @return the MathML as a string.  The caller owns the memory and is
 * responsible for freeing it.
 */
char *
translateInfix (const char* formula, const L3ParserSettings& settings)
{
  char*    result;
  ASTNode* math = SBML_parseL3FormulaWithSettings(formula, &settings);

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
