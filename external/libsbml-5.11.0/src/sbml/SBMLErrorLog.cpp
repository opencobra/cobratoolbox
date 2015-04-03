/**
 * @file    SBMLErrorLog.cpp
 * @brief   Stores errors (and messages) encountered while processing SBML.
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
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#include <algorithm>
#include <functional>
#include <string>
#include <list>

#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLParser.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLErrorLog.h>


/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/** @cond doxygenLibsbmlInternal */
/** Most of the methods are internal.  A few visible ones are at the end. */


/*
 * Creates a new empty SBMLErrorLog.
 */
SBMLErrorLog::SBMLErrorLog ()
{
}

/*
* Copy Constructor
*/
SBMLErrorLog::SBMLErrorLog (const SBMLErrorLog& other)
  : XMLErrorLog(other)
{
}

/*
* Assignment operator
*/
SBMLErrorLog& SBMLErrorLog::operator=(const SBMLErrorLog& other)
{
  XMLErrorLog::operator=(other);
  return *this;
}



/*
 * Used by the Destructor to delete each item in mErrors.
 */
struct Delete : public unary_function<XMLError*, void>
{
  void operator() (XMLError* error) { delete error; }
};


/*
 * Destroys this SBMLErrorLog.
 */
SBMLErrorLog::~SBMLErrorLog ()
{
/*
  //
  // debug code for SBMLErrorLog::remove(const unsigned int)
  //
  vector<XMLError*>::iterator iter;

  int count = 0;
  iter = mErrors.begin();
  while(iter != mErrors.end() )
  {
    ++count;
    unsigned int errid  = (*iter)->getErrorId();
    unsigned int column = (*iter)->getColumn();
    cout << "(" << count << ") ErrorId " << errid << " column " << column << endl;
    remove (errid);
    cout << "Size of mErrors " << mErrors.size() << endl;
    iter = mErrors.begin();
  }
*/
}


/*
 * See SBMLError for a list of SBML error codes and XMLError
 * for a list of system and XML-level error codes.
 */
void
SBMLErrorLog::logError ( const unsigned int errorId
                       , const unsigned int level
                       , const unsigned int version
                       , const std::string& details
                       , const unsigned int line
                       , const unsigned int column
                       , const unsigned int severity
                       , const unsigned int category )
{
  add( SBMLError( errorId, level, version, details, line, column,
                  severity, category ));
}


void
SBMLErrorLog::logPackageError ( const std::string& package
                       , const unsigned int errorId
                       , const unsigned int pkgVersion
                       , const unsigned int level
                       , const unsigned int version
                       , const std::string& details
                       , const unsigned int line
                       , const unsigned int column
                       , const unsigned int severity
                       , const unsigned int category )
{
  add( SBMLError( errorId, level, version, details, line, column,
                  severity, category, package, pkgVersion));
}


/*
 * Adds the given SBMLError to the log.
 *
 * @param error SBMLError, the error to be logged.
 */
void
SBMLErrorLog::add (const SBMLError& error)
{
  if (error.getSeverity() != LIBSBML_SEV_NOT_APPLICABLE)
    XMLErrorLog::add(error);
}


/*
 * Logs (copies) the SBMLErrors in the given SBMLError list to this
 * SBMLErrorLog.
 *
 * @param errors list, a list of SBMLError to be added to the log.
 */
void
SBMLErrorLog::add (const std::list<SBMLError>& errors)
{
  list<SBMLError>::const_iterator end = errors.end();
  list<SBMLError>::const_iterator iter;

  for (iter = errors.begin(); iter != end; ++iter)
    XMLErrorLog::add( *iter );
}

/*
 * Logs (copies) the SBMLErrors in the given SBMLError vector to this
 * SBMLErrorLog.
 *
 * @param errors vector, a vector of SBMLError to be added to the log.
 */
void
SBMLErrorLog::add (const std::vector<SBMLError>& errors)
{
  vector<SBMLError>::const_iterator end = errors.end();
  vector<SBMLError>::const_iterator iter;

  for (iter = errors.begin(); iter != end; ++iter)
    XMLErrorLog::add( *iter );
}

/*
 * Helper class used by SBMLErrorLog::remove.
 */
class MatchErrorId
{
public:
  MatchErrorId(const unsigned int theId) : idToFind(theId) {};

  bool operator() (XMLError* e) const
  {
    return e->getErrorId() == idToFind;
  };

private:
  unsigned int idToFind;
};


/*
 * Removes an error having errorId from the SBMLError list.
 *
 * Only the first item will be removed if there are multiple errors
 * with the given errorId.
 *
 * @param errorId the error identifier of the error to be removed.
 */
void
SBMLErrorLog::remove (const unsigned int errorId)
{
  //
  // "mErrors.erase( remove_if( ...))" can't be used for removing
  // the matched items from the list, because the type of the vector container is pointer
  // of XMLError object.
  //
  // (Effective STL 50 Specific Ways to Improve Your Use of the Standard Template Library
  //  Scott Meyers
  //  Item 33: Be wary of remove-like algorithms on containers of pointers. 143)
  //
  //
  vector<XMLError*>::iterator delIter;

  // finds an item with the given errorId (the first item will be found if
  // there are two or more items with the same Id)
  delIter = find_if(mErrors.begin(), mErrors.end(), MatchErrorId(errorId));

  if ( delIter != mErrors.end() )
  {
    // deletes (invoke delete operator for the matched item) and erases (removes
    // the pointer from mErrors) the matched item (if any)
    delete *delIter;
    mErrors.erase(delIter);
  }
}


bool
SBMLErrorLog::contains (const unsigned int errorId)
{
  vector<XMLError*>::iterator iter;

  // finds an item with the given errorId (the first item will be found if
  // there are two or more items with the same Id)
  iter = find_if(mErrors.begin(), mErrors.end(), MatchErrorId(errorId));

  if ( iter != mErrors.end() )
  {
    return true;
  }
  else
  {
    return false;
  }
}


/*
 * Helper class used by
 * SBMLErrorLog::getNumFailsWithSeverity(SBMLErrorSeverity_t).
 */
class MatchSeverity
{
public:
  MatchSeverity(const unsigned int s) : severity(s) {};

  bool operator() (XMLError* e) const
  {
    return e->getSeverity() == severity;
  };

private:
  unsigned int severity;
};



/** @endcond */

unsigned int 
SBMLErrorLog::getNumFailsWithSeverity(unsigned int severity) const
{
  int n = 0;

#if defined(__SUNPRO_CC)
  // Workaround for Sun cc which is missing:
  count_if(mErrors.begin(), mErrors.end(), MatchSeverity(severity), n);
#else
  n = (int)count_if(mErrors.begin(), mErrors.end(), MatchSeverity(severity));
#endif

  return n;
}

/*
 * Returns number of errors that are logged with severity Error
 */
unsigned int
SBMLErrorLog::getNumFailsWithSeverity(unsigned int severity)
{
  int n = 0;

#if defined(__SUNPRO_CC)
  // Workaround for Sun cc which is missing:
  count_if(mErrors.begin(), mErrors.end(), MatchSeverity(severity), n);
#else
  n = (int)count_if(mErrors.begin(), mErrors.end(), MatchSeverity(severity));
#endif

  return n;
}


/*
 * Returns the nth SBMLError in this log.
 *
 * @param n unsigned int number of the error to retrieve.
 *
 * @return the nth SBMLError in this log.
 */
const SBMLError*
SBMLErrorLog::getError (unsigned int n) const
{
  return static_cast<const SBMLError*>(XMLErrorLog::getError(n));
}

/*
 * Returns the nth SBMLError with severity in this log.
 *
 * @param n unsigned int number of the error to retrieve.
 * @param severity the severity sought
 *
 * @return the nth SBMLError in this log.
 */
const SBMLError*
SBMLErrorLog::getErrorWithSeverity(unsigned int n, unsigned int severity) const
{
  unsigned int count = 0;
  MatchSeverity matcher(severity);
  std::vector<XMLError*>::const_iterator it = mErrors.begin();
  for (; it != mErrors.end(); ++it)
  {
    if (matcher(*it))
    {
      if (count == n) return dynamic_cast<const SBMLError*>(*it);
      ++count;
    }
  }
  return NULL;
}

#endif /* __cplusplus */


/** @cond doxygenIgnored */

/** @endcond */
LIBSBML_CPP_NAMESPACE_END

