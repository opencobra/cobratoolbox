/**
 * @file    XMLErrorLog.cpp
 * @brief   Stores errors (and messages) encountered while processing XML.
 * @author  Ben Bornstein
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#include <algorithm>
#include <functional>
#include <sstream>

#include <sbml/xml/XMLError.h>
#include <sbml/xml/XMLParser.h>

#include <sbml/xml/XMLErrorLog.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/** @cond doxygenLibsbmlInternal */
/*
 * Creates a new empty XMLErrorLog.
 */
XMLErrorLog::XMLErrorLog ()
  : mParser(NULL)
  , mOverriddenSeverity(LIBSBML_OVERRIDE_DISABLED)
{
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
* Copy Constructor
*/
XMLErrorLog::XMLErrorLog (const XMLErrorLog& other)
  : mParser(NULL)
  , mOverriddenSeverity(other.mOverriddenSeverity)
{
  add(other.mErrors);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
* Assignment operator
*/
XMLErrorLog& XMLErrorLog::operator=(const XMLErrorLog& other)  
{
  if (this != &other)
  {
    mOverriddenSeverity = other.mOverriddenSeverity;
    mParser = NULL;
    
    mErrors.clear();
    add(other.mErrors);
  }
  return *this;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/**
 * Used by the Destructor to delete each item in mErrors.
 */
struct Delete : public unary_function<XMLError*, void>
{
  void operator() (XMLError* error) { delete error; }
};
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Destroys this XMLErrorLog.
 */
XMLErrorLog::~XMLErrorLog ()
{
  for_each( mErrors.begin(), mErrors.end(), Delete() );
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Logs the given XMLError.
 */
void
XMLErrorLog::add (const XMLError& error)
{
  if (&error == NULL || mOverriddenSeverity == LIBSBML_OVERRIDE_DONT_LOG) return;

  XMLError* cerror;

  try
  {
    cerror = error.clone();
  }
  catch (...)
  {
    // Currently do nothing.
    // An error status would be returned in the 4.x.
    return;
  }

  if (mOverriddenSeverity == LIBSBML_OVERRIDE_WARNING && 
    cerror->getSeverity() > LIBSBML_SEV_WARNING)
  {
    cerror->mSeverity = LIBSBML_SEV_WARNING;
  }

  mErrors.push_back(cerror);

  if (cerror->getLine() == 0 && cerror->getColumn() == 0)
  {
    unsigned int line, column;
    if (mParser != NULL)
    {
      try
      {
        line = mParser->getLine();
        column = mParser->getColumn();
      }
      catch (...)
      {
        line = 1;
        column = 1;
      }
    }
    else
    {
      line = 1;
      column = 1;
    }

    cerror->setLine(line);
    cerror->setColumn(column);
  }
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Logs (copies) the XMLErrors in the given XMLError list to this
 * XMLErrorLog.
 */
void
XMLErrorLog::add (const std::list<XMLError>& errors)
{
  list<XMLError>::const_iterator end = errors.end();
  list<XMLError>::const_iterator iter;

  for (iter = errors.begin(); iter != end; ++iter) add( *iter );
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Logs (copies) the XMLErrors in the given XMLError list to this
 * XMLErrorLog.
 */
void
XMLErrorLog::add (const std::vector<XMLError*>& errors)
{
  vector<XMLError*>::const_iterator end = errors.end();
  vector<XMLError*>::const_iterator iter;

  for (iter = errors.begin(); iter != end; ++iter) add( *(*iter) );
}
/** @endcond */

/*
 * Returns a boolean indicating whether or not the severity is overriden   
 */
bool 
XMLErrorLog::isSeverityOverridden() const
{
  return mOverriddenSeverity != LIBSBML_OVERRIDE_DISABLED;
}

/*
 * usets an existing override 
 */ 
void 
XMLErrorLog::unsetSeverityOverride()
{
  setSeverityOverride(LIBSBML_OVERRIDE_DISABLED);
}

/*
 * Returns the current override
 */
XMLErrorSeverityOverride_t 
XMLErrorLog::getSeverityOverride() const
{
  return mOverriddenSeverity;
}

/*
 * Set the severity override. 
 * 
 * If set to LIBSBML_OVERRIDE_DISABLED (default) all errors will be 
 * logged as specified in the error. Set to LIBSBML_OVERRIDE_DONT_LOG
 * no error will be logged. When set to LIBSBML_OVERRIDE_WARNING, then
 * all errors will be logged as warnings. 
 *
 */
void 
XMLErrorLog::setSeverityOverride(XMLErrorSeverityOverride_t severity)
{
  mOverriddenSeverity = severity;
}

/*
 * @return the nth XMLError in this log.
 */
const XMLError*
XMLErrorLog::getError (unsigned int n) const
{
  return (n < mErrors.size()) ? mErrors[n] : NULL;
}


/*
 * @return the number of errors that have been logged.
 */
unsigned int
XMLErrorLog::getNumErrors () const
{
  return (unsigned int)mErrors.size();
}


/*
 * Removes all errors from this log.
 */
void 
XMLErrorLog::clearLog()
{
  for_each( mErrors.begin(), mErrors.end(), Delete() );
  mErrors.clear();
}

/** @cond doxygenLibsbmlInternal */
/*
 * Sets the XMLParser for this XMLErrorLog.
 *
 * The XMLParser will be used to obtain the current line and column
 * number as XMLErrors are logged (if they have a line and column number
 * of zero).
 */
int
XMLErrorLog::setParser (const XMLParser* p)
{
  mParser = p;

  if (mParser != NULL)
    return LIBSBML_OPERATION_SUCCESS;
  else
    return LIBSBML_OPERATION_FAILED;
}
/** @endcond */

string
XMLErrorLog::toString() const
{
  stringstream stream;
  printErrors(stream);  
  return stream.str();
}

void 
XMLErrorLog::printErrors (std::ostream& stream /*= std::cerr*/) const
{
  vector<XMLError*>::const_iterator iter;

  for (iter = mErrors.begin(); iter != mErrors.end(); ++iter) 
    stream << *(*iter);
}


void 
XMLErrorLog::changeErrorSeverity(XMLErrorSeverity_t originalSeverity,
                                 XMLErrorSeverity_t targetSeverity,
                                 std::string package)
{
  vector<XMLError*>::const_iterator iter;

  for (iter = mErrors.begin(); iter != mErrors.end(); ++iter) 
  {
    if ((*iter)->getSeverity() == originalSeverity)
    {
      if (package == "all" || (*iter)->getPackage() == package)
      {
        (*iter)->mSeverity = targetSeverity;
        (*iter)->mSeverityString = (*iter)->stringForSeverity(targetSeverity);
      }
    }
  }
}

#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBLAX_EXTERN
XMLErrorLog_t *
XMLErrorLog_create (void)
{
  return new(nothrow) XMLErrorLog;
}


LIBLAX_EXTERN
void
XMLErrorLog_free (XMLErrorLog_t *log)
{
  if (log == NULL) return;
  delete static_cast<XMLErrorLog*>(log);
}


LIBLAX_EXTERN
void
XMLErrorLog_add (XMLErrorLog_t *log, const XMLError_t *error)
{
  if (log == NULL || error == NULL) return;
  log->add(*error);
}


LIBLAX_EXTERN
const XMLError_t *
XMLErrorLog_getError (const XMLErrorLog_t *log, unsigned int n)
{
  if (log == NULL) return NULL;
  return log->getError(n);
}


LIBLAX_EXTERN
unsigned int
XMLErrorLog_getNumErrors (const XMLErrorLog_t *log)
{
  if (log == NULL) return 0;
  return log->getNumErrors();
}

LIBLAX_EXTERN
void
XMLErrorLog_clearLog (XMLErrorLog_t *log)
{
  if (log == NULL) return;
  log->clearLog();
}


LIBLAX_EXTERN
char*
XMLErrorLog_toString (XMLErrorLog_t *log)
{
  if (log == NULL) return NULL;
  return safe_strdup(log->toString().c_str());
}


LIBLAX_EXTERN
int
XMLErrorLog_isSeverityOverridden (XMLErrorLog_t *log)
{
  if (log  == NULL) return static_cast<int>(false);
  return static_cast<int>(log->isSeverityOverridden());
}

LIBLAX_EXTERN
void
XMLErrorLog_unsetSeverityOverride (XMLErrorLog_t *log)
{
  if (log != NULL) log->unsetSeverityOverride();
}

LIBLAX_EXTERN
XMLErrorSeverityOverride_t
XMLErrorLog_getSeverityOverride (XMLErrorLog_t *log)
{
  if (log == NULL) return LIBSBML_OVERRIDE_DISABLED;
  return log->getSeverityOverride();
}

LIBLAX_EXTERN
void
XMLErrorLog_setSeverityOverride (XMLErrorLog_t *log, XMLErrorSeverityOverride_t overridden)
{
  if (log == NULL) return;
  log->setSeverityOverride(overridden);
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

