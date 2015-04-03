/**
 * @file    SBMLValidator.cpp
 * @brief   Implementation of SBMLValidator, the base class for user callable SBML validators.
 * @author  Frank Bergmann
 * 
 * <!--------------------------------------------------------------------------
 * This file is part of libSBML.  Please visit http://sbml.org for more
 * information about SBML, and the latest version of libSBML.
 *
 * Copyright (C) 2013-2014 jointly by the following organizations:
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *     3. University of Heidelberg, Heidelberg, Germany
 *
 * Copyright (C) 2009-2013 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *  
 * Copyright (C) 2006-2008 by the California Institute of Technology,
 *     Pasadena, CA, USA 
 *  
 * Copyright (C) 2002-2005 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. Japan Science and Technology Agency, Japan
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */

#include <sbml/validator/SBMLValidator.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLReader.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN

SBMLValidator::SBMLValidator () :
    mDocument (NULL)
{
}


/*
 * Copy constructor.
 */
    SBMLValidator::SBMLValidator(const SBMLValidator& orig) :
    mDocument (NULL)
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mDocument = orig.mDocument;
    
    
  }
}


/*
 * Destroy this object.
 */
SBMLValidator::~SBMLValidator ()
{

}


/*
 * Assignment operator for SBMLConverter.
 */
SBMLValidator& 
SBMLValidator::operator=(const SBMLValidator& rhs)
{  
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    mDocument = rhs.mDocument;
    
    
  }

  return *this;
}


SBMLValidator*
SBMLValidator::clone () const
{
  return new SBMLValidator(*this);
}


SBMLDocument* 
SBMLValidator::getDocument()
{
  return mDocument;
}


const SBMLDocument* 
SBMLValidator::getDocument() const
{
  return mDocument;
}

int 
SBMLValidator::setDocument(const SBMLDocument* doc)
{
  if (mDocument == doc)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }

  mDocument = const_cast<SBMLDocument *> (doc);
  return LIBSBML_OPERATION_SUCCESS;
}




/*
 * Clears the Validator's list of failures.
 *
 * If you are validating multiple SBML documents with the same Validator,
 * call this method after you have processed the list of failures from the
 * last Validation run and before validating the next document.
 */
void
SBMLValidator::clearFailures ()
{
  mFailures.clear();
}


/*
 * @return a list of failures logged during validation.
 */
const std::vector<SBMLError>&
SBMLValidator::getFailures () const
{
  return mFailures;
}



/*
 * Adds the given failure to this list of Validators failures.
 */
void
SBMLValidator::logFailure (const SBMLError& msg)
{
  if (&msg == NULL) return;
  mFailures.push_back(msg);
}


/*
 * Validates the given SBMLDocument.  Failures logged during
 * validation may be retrieved via <code>getFailures()</code>.
 *
 * @return the number of validation errors that occurred.
 */
unsigned int
SBMLValidator::validate (const std::string& filename)
{
  if (&filename == NULL) return 0;

  SBMLReader    reader;
  SBMLDocument* d = reader.readSBML(filename);


  for (unsigned int n = 0; n < d->getNumErrors(); ++n)
  {
    logFailure( *d->getError(n) );
  }

  unsigned int ret = validate(*d);
  delete d;
  return ret;
}


unsigned int
SBMLValidator::validate(const SBMLDocument& d)
{
  setDocument(&d);
  return validate();
}
  

/*
 * @return the SBMLErrorLog used to log errors while reading and
 * validating SBML.
 */
SBMLErrorLog*
SBMLValidator::getErrorLog ()
{
  if (mDocument == NULL) return NULL;
  return mDocument->getErrorLog();
}

/*
 * @return the Model contained in this SBMLDocument.
 */
const Model*
SBMLValidator::getModel () const
{
  if (mDocument == NULL) return NULL;
  return mDocument->getModel();
}


/*
 * @return the Model contained in this SBMLDocument.
 */
Model*
SBMLValidator::getModel ()
{
  if (mDocument == NULL) return NULL;
  return mDocument->getModel();
}

unsigned int
SBMLValidator::validate()
{
  return 0;
}
  

SBMLError*
SBMLValidator::getFailure (unsigned int n) const
{
  return (n < mFailures.size()) ? mFailures[n].clone() : NULL;
}

unsigned int
SBMLValidator::getNumFailures() const
{
  return (unsigned int) mFailures.size();
}
  
/** @cond doxygenIgnored */


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


