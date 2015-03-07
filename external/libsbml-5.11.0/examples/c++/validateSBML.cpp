/**
 * @file    validateSBML.cpp
 * @brief   Validates an SBML file against the appropriate schema
 * @author  Sarah Keating
 * @author  Ben Bornstein
 * @author  Michael Hucka
 * @author  Akiya Jouraku
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
#include <sstream>

#include <sbml/SBMLTypes.h>
#include "util.h"


using namespace std;
LIBSBML_CPP_NAMESPACE_USE

bool validateSBML(const string& filename, bool enableUnitCheck=true);

const string usage = "Usage: validateSBML [-u] filename [...]\n"
                     " -u : disable unit consistency check";

int
main (int argc, char* argv[])
{
  bool enableUnitCheck = true;
   
  if (argc < 2)
  {
    cout << usage << endl;
    return 1;
  }
  else if (argc == 2)
  {
    if ( string("-u") == string(argv[1]) )
    {
      cout << usage << endl;
      return 1;
    }       
  }

  int  argIndex = 1;
  
  if ( string("-u") == string(argv[1]) )
  {
    enableUnitCheck = false;
    ++argIndex;
  }     
  
  int numInvalidFiles = 0;

  for (int i=argIndex; i < argc; i++)
  {
    if (!validateSBML(argv[i], enableUnitCheck))
      ++numInvalidFiles;

    cout << "---------------------------------------------------------------------------\n";
  }
  
  int numFiles = (enableUnitCheck) ? argc - 1 : argc - 2;
 
  cout << "Validated " << numFiles << " files, " << (numFiles - numInvalidFiles) << " valid files, " 
       << numInvalidFiles << " invalid files" << endl;
  if (!enableUnitCheck)
    cout << "(Unit consistency checks skipped)" << endl;

  return numInvalidFiles;
}


bool validateSBML(const string& filename, bool enableUnitCheck)
{
  SBMLDocument* document;
  SBMLReader reader;
#ifdef __BORLANDC__
  unsigned long start, stop;
#else
  unsigned long long start, stop;
#endif

  start    = getCurrentMillis();
  document = reader.readSBML(filename);
  stop     = getCurrentMillis();
  
  double     timeRead = (double)(stop - start);
  unsigned int errors = document->getNumErrors();
  bool  seriousErrors = false;

  unsigned int numReadErrors   = 0;
  unsigned int numReadWarnings = 0;
  string       errMsgRead      = "";

  if (errors > 0)
  {
    for (unsigned int i = 0; i < errors; i++)
    {
      if (document->getError(i)->isFatal() || document->getError(i)->isError())
      {
        seriousErrors = true;
	++numReadErrors;
        break;
      }
      else
        ++numReadWarnings;
    }

    ostringstream oss;
    document->printErrors(oss);
    errMsgRead = oss.str();
  }

  // If serious errors are encountered while reading an SBML document, it
  // does not make sense to go on and do full consistency checking because
  // the model may be nonsense in the first place.

  unsigned int numCCErrors   = 0;
  unsigned int numCCWarnings = 0;
  string       errMsgCC      = "";
  bool   skipCC = false;
  double timeCC = 0.0;
  bool  isValid = true;

  if (seriousErrors)
  {
    skipCC = true;
    isValid = false;
    errMsgRead += "Further consistency checking and validation aborted.";
  }
  else
  {
    unsigned int failures = 0;

    document->setConsistencyChecks(LIBSBML_CAT_UNITS_CONSISTENCY, enableUnitCheck);
    
    start    = getCurrentMillis();
    failures = document->checkConsistency();
    stop     = getCurrentMillis();
    timeCC   = (double)(stop - start);

    if (failures > 0)
    {

      for (unsigned int i = 0; i < failures; i++)
      {
        if (document->getError(i)->isFatal() || document->getError(i)->isError())
        {
          ++numCCErrors;
	  isValid = false;
        }
        else
          ++numCCWarnings;
      }

      ostringstream oss;
      document->printErrors(oss);
      errMsgCC = oss.str();

    }
  }

  //
  // Print Results
  //
  cout << "                 filename : " << filename << endl;
  cout << "         file size (byte) : " << getFileSize(filename.c_str()) << endl;
  cout << "           read time (ms) : " << timeRead << endl;

  if (!skipCC)
  {
    cout << "        c-check time (ms) : " << timeCC << endl;
  }	 
  else
  {     
    cout << "        c-check time (ms) : skipped" << endl;
  }      

  cout << "      validation error(s) : " << numReadErrors  + numCCErrors << endl;
  if (!skipCC)
    cout << "    (consistency error(s)): " << numCCErrors << endl;
  else
    cout << "    (consistency error(s)): skipped" << endl;

  cout << "    validation warning(s) : " << numReadWarnings + numCCWarnings << endl;
  if (!skipCC)
    cout << "  (consistency warning(s)): " << numCCWarnings << endl;
  else
    cout << "  (consistency warning(s)): skipped" << endl;

  if ( !errMsgRead.empty() || !errMsgCC.empty() )
  {
    cout << "\n===== validation error/warning messages =====\n";
    if (!errMsgRead.empty())
      cout << errMsgRead << endl;

    if (!errMsgCC.empty())
    {
      cout << "\n*** consistency check ***\n";
      cout << errMsgCC << endl;
    }	 
  }

  delete document;

  return (isValid) ? true: false;
}
