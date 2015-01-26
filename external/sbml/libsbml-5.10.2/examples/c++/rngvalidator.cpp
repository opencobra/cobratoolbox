/**
* @file    rngvalidator.cpp
* @brief   Example creating a rng validator to be called during validation
* @author  Frank T. Bergmann
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
#include <sbml/SBMLTypes.h>
#include <sbml/SBMLError.h>

#include <sbml/validator/SBMLValidator.h>

#include <libxml/xmlmemory.h>
#include <libxml/parser.h>
#include <libxml/relaxng.h>
#include <stdarg.h>
#include <util.h>

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

std::vector<std::string> warnings;
std::vector<std::string> errors;

void logWarning(void *ctx, const char *msg, ...)
{
  char buffer[1000];
  va_list args;
  va_start (args, msg);
  vsprintf (buffer,msg, args);
  va_end (args);

  warnings.push_back(buffer); 
}
void logError(void *ctx, const char *msg, ...)
{
  char buffer[1000];
  va_list args;
  va_start (args, msg);
  vsprintf (buffer,msg, args);
  va_end (args);

  errors.push_back(buffer); 
}

  /** 
  * Declares a custom validator to be called. This allows you to validate 
  * any aspect of an SBML Model that you want to be notified about. You could 
  * use this to notify your application that a model contains an unsupported 
  * feature of SBML (either as warning). 
  * 
  * In this example the validator will go through the model and test for the 
  * presence of 'fast' reactions and algebraic rules. If either is used a 
  * warning will be added to the error log. 
  */
class RNGValidator : public SBMLValidator
{
private: 
  std::string mSchema;

public:

  void setSchema(const std::string& schemaFile)
  {
    mSchema =schemaFile;
  }

  const std::string& getSchema() const { return mSchema; } 

  RNGValidator() : SBMLValidator(), mSchema() {}

  RNGValidator(const std::string& schema) : SBMLValidator(), mSchema(schema) {}

  RNGValidator(const RNGValidator& orig) : SBMLValidator(orig), mSchema(orig.mSchema) {    
  }
  virtual ~RNGValidator() {}

  virtual SBMLValidator* clone() const { return new RNGValidator(*this); }

  virtual unsigned int validate() {
    // if we don't have a model we don't apply this validator.
    if (getDocument() == NULL || getModel() == NULL)
      return 0;

    // we dont' have a schema, so don't report
    if (mSchema.empty())
      return 0;

    // if we have no rules and reactions we don't apply this validator either
    if (getModel()->getNumReactions() == 0 && getModel()->getNumRules() == 0)
      return 0;

    // get document

    std::string sbmlDoc = writeSBMLToString(getDocument());
    warnings.clear();
    errors.clear();

    xmlDoc *doc;
    xmlRelaxNGPtr schema;
    xmlRelaxNGValidCtxtPtr validctxt;
    xmlRelaxNGParserCtxtPtr rngparser;

    doc = xmlParseMemory(sbmlDoc.c_str(), sbmlDoc.length());

    rngparser = xmlRelaxNGNewParserCtxt(mSchema.c_str());
    schema = xmlRelaxNGParse(rngparser);
    validctxt = xmlRelaxNGNewValidCtxt(schema);

    
    xmlRelaxNGSetParserErrors	(rngparser, 
					 &logError, 
					 &logWarning, 
					 (void *) getErrorLog());
   xmlRelaxNGSetValidErrors	(validctxt,
					 &logError, 
					 &logWarning, 
					 (void *) getErrorLog());

    xmlRelaxNGValidateDoc(validctxt, doc);

    xmlRelaxNGFree(schema);
    xmlRelaxNGFreeValidCtxt(validctxt);
    xmlRelaxNGFreeParserCtxt(rngparser);
    xmlFreeDoc(doc);

    unsigned int numErrors = 0;

    for (size_t i = 0; i < warnings.size(); ++i)
    {
      
        getErrorLog()->add(SBMLError(99999, 3, 1, 
          warnings[i],
          0, 0, 
          LIBSBML_SEV_WARNING, // or LIBSBML_SEV_ERROR if you want to stop
          LIBSBML_CAT_SBML // or whatever category you prefer
          ));      
    }

    for (size_t i = 0; i < errors.size(); ++i)
    {
      
        getErrorLog()->add(SBMLError(99999, 3, 1, 
          errors[i],
          0, 0, 
          LIBSBML_SEV_ERROR, // or LIBSBML_SEV_ERROR if you want to stop
          LIBSBML_CAT_SBML // or whatever category you prefer
          ));      
        numErrors ++;
    }

    return numErrors;
  }


};


int
main (int argc, char *argv[])
{
  if (argc < 2)
  {
    cout << endl << "Usage: rngvalidator filename [schema]" << endl << endl;
    return 1;
  }

  const char* filename   = argv[1];

  const char* schema   = argc > 2 ? argv[2] : NULL;

  // read the file name
  SBMLDocument* document = readSBML(filename);

  // add a custom validator if given
  if (schema  != NULL)
    document->addValidator(new RNGValidator(schema));

  unsigned long long start, stop;

  start    = getCurrentMillis();
 
  // check consistency like before
  int numErrors = document->checkConsistency();

  stop     = getCurrentMillis();

  cout << "      validation time (ms): " << stop - start          << endl<< endl;


  // print errors and warnings
  document->printErrors();

  // return number of errors
  return  numErrors;

}
