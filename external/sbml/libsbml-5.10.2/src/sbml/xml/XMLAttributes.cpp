/**
 * @file    XMLAttributes.cpp
 * @brief   XMLAttributes are a list of name/value pairs for XMLElements
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

#include <cerrno>
#include <clocale>
#include <cstdlib>
#include <limits>
#include <sstream>

#include <sbml/xml/XMLErrorLog.h>
#include <sbml/xml/XMLConstructorException.h>
#include <sbml/xml/XMLAttributes.h>
/** @cond doxygenLibsbmlInternal */
#include <sbml/xml/XMLOutputStream.h>
#include <sbml/util/util.h>
/** @endcond */

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus
/*
 * @return s with whitespace removed from the beginning and end.
 */
static const std::string
trim (const std::string& s)
{
  static const std::string whitespace(" \t\r\n");

  std::string::size_type begin = s.find_first_not_of(whitespace);
  std::string::size_type end   = s.find_last_not_of (whitespace);

  return (begin == std::string::npos) ? std::string() : s.substr(begin, end - begin + 1);
}


/*
 * Creates a new empty XMLAttributes set.
 */
XMLAttributes::XMLAttributes () : mLog( NULL )
{
}


/*
 * Destroys this XMLAttributes set.
 */
XMLAttributes::~XMLAttributes ()
{
}

/*
 * Copy constructor; creates a copy of this XMLAttributes set.
 */
XMLAttributes::XMLAttributes(const XMLAttributes& orig)
{
  if (&orig == NULL)
  {
    throw XMLConstructorException("Null argument to copy constructor");
  }
  else  
  {
    this->mNames.assign( orig.mNames.begin(), orig.mNames.end() ); 
    this->mValues.assign( orig.mValues.begin(), orig.mValues.end() ); 
    this->mElementName = orig.mElementName;
    this->mLog = orig.mLog;
  }
}


/*
 * Assignment operator for XMLAttributes.
 */
XMLAttributes& 
XMLAttributes::operator=(const XMLAttributes& rhs)
{
  if (&rhs == NULL)
  {
    throw XMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->mNames.assign( rhs.mNames.begin(), rhs.mNames.end() ); 
    this->mValues.assign( rhs.mValues.begin(), rhs.mValues.end() ); 
    this->mElementName = rhs.mElementName;
    this->mLog = rhs.mLog;
  }

  return *this;
}

/*
 * Creates and returns a deep copy of this XMLAttributes set.
 * 
 * @return a (deep) copy of this XMLAttributes set.
 */
XMLAttributes* 
XMLAttributes::clone () const
{
  return new XMLAttributes(*this);
}



/*
 * Adds an attribute (a name/value pair) to this XMLAttributes set.  
 * If name with the same namespace URI already exists in this attribute set, 
 * its value will be replaced.
 */
int
XMLAttributes::add (const std::string& name,
		    const std::string& value,
		    const std::string& namespaceURI,
		    const std::string& prefix)
{
  if (&name == NULL || &value == NULL 
                    || &namespaceURI == NULL 
                    || &prefix == NULL)
      return LIBSBML_INVALID_OBJECT;


  int index = getIndex(name, namespaceURI);

  // since in the old version of the method the XMLTriple was initialized
  // with empty strings for the prefix and the uri, I assume that only
  // attributes that are not from the default namespace should have a set
  // prefix and uri.

  if (index == -1)
  {
    mNames .push_back( XMLTriple(name, namespaceURI, prefix) );
    mValues.push_back( value );
  }
  else
  {
    mValues[index] = value;
    mNames[index]  = XMLTriple(name, namespaceURI, prefix);
  }
  return LIBSBML_OPERATION_SUCCESS;
}


/*
 * Adds an attribute with the given triple/value pair to this XMLAttributes set.
 * If name with the same namespaceURI already exists in this attribute set,
 * its value will be replaced.
 */
int 
XMLAttributes::add ( const XMLTriple& triple, const std::string& value)
{
  if (&triple == NULL || &value == NULL) return LIBSBML_INVALID_OBJECT;
  return add(triple.getName(), value, triple.getURI(), triple.getPrefix());
}


/** @cond doxygenLibsbmlInternal */
/*
 * Adds an attribute with the given name/value pair to this XMLAttributes set.  
 * This is really the add function but an attribute with same name wont 
 * be overwritten - this is for annotations
 */
int
XMLAttributes::addResource (const std::string& name, const std::string& value)
{
  mNames .push_back( XMLTriple(name, "", "") );
  mValues.push_back( value );
  return LIBSBML_OPERATION_SUCCESS;
}
/** @endcond */


/*
 * Removes an attribute with the given index from this XMLAttributes set.  
 * This is for annotations
 */
int
XMLAttributes::removeResource (int n)
{
  if (n < 0 || n >= getLength()) 
  {
    return LIBSBML_INDEX_EXCEEDS_SIZE;
  }

  vector<XMLTriple>::iterator   names_iter  = mNames.begin()  + n;
  vector<std::string>::iterator values_iter = mValues.begin() + n;

  mNames.erase(names_iter);
  mValues.erase(values_iter);

  return LIBSBML_OPERATION_SUCCESS;
}


/*
 * Removes an attribute with the given index from this XMLAttributes set.  
 * This is for annotations
 */
int
XMLAttributes::remove (int n)
{
  return removeResource(n);
}


/*
 * Removes an attribute with the given name and namespace URI from this 
 * XMLAttributes set.
 */
int 
XMLAttributes::remove (const std::string& name, const std::string& uri)
{
  return remove(getIndex(name,uri));
}


/*
 * Removes an attribute with the given triple from this XMLAttributes set.
 */
int 
XMLAttributes::remove (const XMLTriple& triple)
{
  return remove(getIndex(triple));
}


/*
 * Clears (deletes) all attributes in this XMLAttributes object.
 */
int 
XMLAttributes::clear()
{
  mNames.clear();
  mValues.clear();
  return LIBSBML_OPERATION_SUCCESS;
}


/*
 * Lookup the index of an attribute with the given name.
 *
 * @return the index of an attribute with the given name, or -1 if not present.
 */
int
XMLAttributes::getIndex (const std::string& name) const
{
  if (&name == NULL) return -1;

  for (int index = 0; index < getLength(); ++index)
  {
    if (getName(index) == name) return index;
  }
  
  return -1;
}


/*
 * Lookup the index of an attribute with the given name and namespace URI
 *
 * @return the index of an attribute with the given name and namespace URI, 
 * or -1 if not present.
 */
int
XMLAttributes::getIndex (const std::string& name, const std::string& uri) const
{
  if (&name == NULL || &uri == NULL) return -1;

  for (int index = 0; index < getLength(); ++index)
  {
    if ( (getName(index) == name) && (getURI(index) == uri) ) return index;
  }
  
  return -1;
}


/*
 * Lookup the index of an attribute by XMLTriple.
 *
 * @return the index of an attribute with the given XMLTriple, or -1 if not present.
 */
int 
XMLAttributes::getIndex (const XMLTriple& triple) const
{
  if (&triple  == NULL) return -1;

  for (int index = 0; index < getLength(); ++index)
  {
    if (mNames[index] == triple) return index;
  }
  
  return -1;
}


/*
 * @return the number of attributes in this list.
 */
int
XMLAttributes::getLength () const
{
  return (int)mNames.size();
}


/*
 * @return the number of attributes in this list.
 */
int
XMLAttributes::getNumAttributes () const
{
  return (int)mNames.size();
}


/*
 * @return the name of an attribute in this list (by position).  If index
 * is out of range, an empty string will be returned.  Use hasAttribute(index)
 * to test for attribute existence.
 */
std::string
XMLAttributes::getName (int index) const
{
  return (index < 0 || index >= getLength()) ? std::string() : mNames[index].getName();
}


/*
 * @return the namespace prefix of an attribute in this list (by
 * position).  If index is out of range, an empty string will be
 * returned.  Use hasAttribute(index) to test for attribute existence.
 */
std::string
XMLAttributes::getPrefix (int index) const
{
  return (index < 0 || index >= getLength()) ? std::string() : mNames[index].getPrefix();
}


/*
 * @return the prefixed name of an attribute in this list (by
 * position).  If index is out of range, an empty string will be
 * returned.  Use hasAttribute(index) to test for 
 * attribute existence.
 */
std::string
XMLAttributes::getPrefixedName (int index) const
{
  return (index < 0 || index >= getLength()) ? std::string() : mNames[index].getPrefixedName();
}


/*
 * @return the namespace URI of an attribute in this list (by position).
 * If index is out of range, an empty string will be returned.  Use
 * hasAttribute(index) to test for attribute existence.
 */
std::string
XMLAttributes::getURI (int index) const
{
  return (index < 0 || index >= getLength()) ? std::string() : mNames[index].getURI();
}


/*
 * @return the value of an attribute in the list (by position).  If index
 * is out of range, an empty string will be returned.  Use hasAttribute(index)
 * to test for attribute existence.
 */
std::string
XMLAttributes::getValue (int index) const
{
  return (index < 0 || index >= getLength()) ? std::string() : mValues[index];
}


/*
 * Lookup an attribute's value by name.
 *
 * @return The attribute value as a string.  If an attribute with the
 * given name does not exist, an empty string will be returned.  Use
 * hasAttribute(name) to test for attribute existence.
 */
std::string
XMLAttributes::getValue (const std::string name) const
{
  return getValue( getIndex(name) );
}


/*
 * Lookup an attribute's value with the name and namespace URI.
 *
 * @return The attribute value as a string.  If an attribute with the
 * given name does not exist, an empty string will be returned.  Use
 * hasAttribute(name,uri) to test for attribute existence.
 */
std::string
XMLAttributes::getValue (const std::string name, const std::string uri) const
{
  return getValue( getIndex(name,uri) );
}


/*
 * Return an attribute's value by XMLTriple.
 *
 * @return The attribute value as a string.
 * If an attribute with the
 * given XMLTriple does not exist, an empty string will be returned.
 * Use hasAttribute(triple) to test for attribute existence.
 */
std::string 
XMLAttributes::getValue (const XMLTriple& triple) const
{
  return getValue( getIndex(triple) );
}


/*
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given name exists in this XMLAttributes.
 */
bool 
XMLAttributes::hasAttribute (int index) const 
{ 
   return ( (index >= 0) && (index < getLength()) );
}


/*
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given name and namespace URI exists in this XMLAttributes.
 *
 * @param name a string, the name of the attribute 
 * @param uri  a string, the namespace URI of the attribute.
 *
 * @return @c true if an attribute with the given name exists in this
 * XMLAttributes, @c false otherwise.
 *
 */
bool 
XMLAttributes::hasAttribute (const std::string name, const std::string uri) const 
{ 
  return ( getIndex(name,uri) != -1 ); 
}


/*
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given XML triple exists in this XMLAttributes.
 *
 * @param triple an XMLTriple, the XML triple of the attribute 
 *
 * @return @c true if an attribute with the given XML triple exists in this
 * XMLAttributes, @c false otherwise.
 *
 */
bool 
XMLAttributes::hasAttribute (const XMLTriple& triple) const 
{ 
  return ( getIndex(triple) != -1 ); 
}


/*
 * @return true if this XMLAttributes set is empty, false otherwise.
 */
bool
XMLAttributes::isEmpty () const
{
  return (getLength() == 0);
}


/** @cond doxygenLibsbmlInternal */
/*
 * Reads the value for the attribute with the index into value.  If attribute 
 * was not found or value could not be interpreted as a boolean, value is not 
 * modified.
 *
 * According to the W3C XML Schema, valid boolean values are: "true",
 * "false", "1", and "0" (case-insensitive).  For more information, see:
 * http://www.w3.org/TR/xmlschema-2/#boolean
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns true if the attribute was read into value, false otherwise.
 */
bool
XMLAttributes::readInto (  int          index
                         , const std::string& name
                         , bool&        value
                         , XMLErrorLog* log
                         , bool         required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  bool assigned = false;
  bool missing  = true;

  if ( index != -1 )
  {
    const string& trimmed = trim( getValue(index) );
    if (&value != NULL && !trimmed.empty() )
    {
      missing = false;

      if (trimmed == "0" || trimmed == "false")
      {
        value    = false;
        assigned = true;
      }
      else if (trimmed == "1" || trimmed == "true")
      {
        value    = true;
        assigned = true;
      }
    }
  }

  if ( log == NULL ) log = mLog;

  if ( log != NULL && !assigned && &name != NULL)
  {
    if ( !missing ) attributeTypeError(name, Boolean, log, line, column);
    else if ( required ) attributeRequiredError (name, log, line, column);
  }

  return assigned;
}
/** @endcond */


/*
 * Reads the value for the attribute name into value.  If the given local
 * name was not found or value could not be interpreted as a boolean, 
 * value is not modified.
 *
 * According to the W3C XML Schema, valid boolean values are: "true",
 * "false", "1", and "0" (case-insensitive).  For more information, see:
 * http://www.w3.org/TR/xmlschema-2/#boolean
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns true if the attribute was read into value, false otherwise.
 */
bool
XMLAttributes::readInto (  const std::string&   name
                         , bool&                value
                         , XMLErrorLog*         log
                         , bool                 required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
   return readInto(getIndex(name), name, value, log, required, line, column);
}


/*
 * Reads the value for the attribute XMLTriple into value.  If XMLTriple was not
 * found or value could not be interpreted as a boolean, value is not modified.
 *
 * According to the W3C XML Schema, valid boolean values are: "true",
 * "false", "1", and "0" (case-insensitive).  For more information, see:
 * http://www.w3.org/TR/xmlschema-2/#boolean
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns true if the attribute was read into value, false otherwise.
 */
bool
XMLAttributes::readInto (  const XMLTriple& triple
                         , bool&            value
                         , XMLErrorLog*     log
                         , bool             required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  if (&triple == NULL || &value == NULL) return (int)false;
   return readInto(getIndex(triple), triple.getPrefixedName(), value, log, required, line, column);
}


/** @cond doxygenLibsbmlInternal */
/*
 * Reads the value for the attribute with the given index into value.  
 * If name was not found or value could be interpreted as a double, value 
 * is not modified.
 *
 * According to the W3C XML Schema, valid doubles are the same as valid
 * doubles for C and the special values "INF", "-INF", and "NaN"
 * (case-sensitive).  For more information, see:
 * http://www.w3.org/TR/xmlschema-2/#double
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns @c true if the attribute was read into value, @c false otherwise.
 *
 */
bool
XMLAttributes::readInto (  int          index
                         , const std::string& name
                         , double&      value
                         , XMLErrorLog* log
                         , bool         required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  bool assigned = false;
  bool missing  = true;

  if ( index != -1 )
  {
    const std::string& trimmed = trim( getValue(index) );
    if ( &value != NULL && !trimmed.empty() )
    {
      if (trimmed == "-INF")
      {
        value    = - numeric_limits<double>::infinity();
        assigned = true;
      }
      else if (trimmed == "INF")
      {
        value    = numeric_limits<double>::infinity();
        assigned = true;
      }
      else if (trimmed == "NaN")
      {
        value    = numeric_limits<double>::quiet_NaN();
        assigned = true;
      }
      else
      {
        // Ensure C locale
        char*  ptr    =  setlocale(LC_ALL, NULL);
        std::string locale = (ptr) ? ptr : "";
        setlocale(LC_ALL, "C");

        errno               = 0;
        char*        endptr = NULL;
        const char*  nptr   = trimmed.c_str();
        double       result = strtod(nptr, &endptr);
        unsigned int length = (unsigned int)(endptr - nptr);

        // Restore previous locale
        setlocale(LC_ALL, locale.empty() ? NULL : locale.c_str());

        if ((length == trimmed.size()) && (errno != ERANGE))
        {
          value    = result;
          assigned = true;
        }
        else
        {
          missing = false;
        }
      }
    }
  }

  if ( log == NULL ) log = mLog;

  if ( log != NULL && !assigned && &name != NULL)
  {
    if ( !missing ) attributeTypeError(name, Double, log, line, column);
    else if ( required ) attributeRequiredError (name, log, line, column);
  }

  return assigned;
}
/** @endcond */


/*
 * Reads the value for the attribute with the given XMLTriple into value.  
 * If the triple was not found or value could be interpreted as a double, 
 *value is not modified.
 *
 * According to the W3C XML Schema, valid doubles are the same as valid
 * doubles for C and the special values "INF", "-INF", and "NaN"
 * (case-sensitive).  For more information, see:
 * http://www.w3.org/TR/xmlschema-2/#double
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns @c true if the attribute was read into value, @c false otherwise.
 *
 */
bool
XMLAttributes::readInto (  const XMLTriple& triple
                         , double&          value
                         , XMLErrorLog*     log
                         , bool             required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  return readInto(getIndex(triple), triple.getPrefixedName(), value, log, required, line, column);
}


/*
 * Reads the value for the attribute name into value.  If name was not
 * found or value could not be interpreted as a double, value is not
 * modified.
 *
 * According to the W3C XML Schema, valid doubles are the same as valid
 * doubles for C and the special values "INF", "-INF", and "NaN"
 * (case-sensitive).  For more information, see:
 * http://www.w3.org/TR/xmlschema-2/#double
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns true if the attribute was read into value, false otherwise.
 */
bool
XMLAttributes::readInto (  const std::string&   name
                         , double&          value
                         , XMLErrorLog*     log
                         , bool             required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  return readInto(getIndex(name), name, value, log, required, line, column);
}


/** @cond doxygenLibsbmlInternal */
/*
 * Reads the value for the attribute with the given index into value.  
 * If the attribute was not found or value could be interpreted as a long, 
 * value is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a long.  For more information,
 * see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns @c true if the attribute was read into value, @c false otherwise.
 *
 */
bool
XMLAttributes::readInto (  int          index
			                   , const std::string& name
                         , long&        value
                         , XMLErrorLog* log
                         , bool         required 
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  bool assigned = false;
  bool missing  = true;

  if ( index != -1 )
  {
    const std::string& trimmed = trim( getValue(index) );
    if ( !trimmed.empty() && &value != NULL )
    {
      missing = false;

      errno               = 0;
      char*        endptr = NULL;
      const char*  nptr   = trimmed.c_str();
      long         result = strtol(nptr, &endptr, 10);
      unsigned int length = (unsigned int)(endptr - nptr);

      if ((length == trimmed.size()) && (errno != ERANGE))
      {
        value    = result;
        assigned = true;
      }
    }
  }

  if ( log == NULL ) log = mLog;

  if ( log != NULL && !assigned && &name != NULL )
  {
    if ( !missing ) attributeTypeError(name, Integer, log, line, column);
    else if ( required ) attributeRequiredError (name, log, line, column);
  }

  return assigned;
}
/** @endcond */


/*
 * Reads the value for the attribute XMLTriple into value.  
 * If the XMLTriple was not found or value could be interpreted as a long, 
 * value is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a long.  For more information,
 * see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns @c true if the attribute was read into value, @c false otherwise.
 *
 */
bool
XMLAttributes::readInto (  const XMLTriple& triple
                         , long&            value
                         , XMLErrorLog*     log
                         , bool             required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  if (&triple == NULL) return false;
  return readInto(getIndex(triple), triple.getPrefixedName(), value, log, required, line, column);
}

/*
 * Reads the value for the attribute name into value.  If name was not
 * found or value could not be interpreted as an long, value is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a long.  For more information,
 * see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns true if the attribute was read into value, false otherwise.
 */
bool
XMLAttributes::readInto (  const std::string& name
                         , long&              value
                         , XMLErrorLog*       log
                         , bool               required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  return readInto(getIndex(name), name, value, log, required, line, column);
}


/** @cond doxygenLibsbmlInternal */
/*
 * Reads the value for the attribute with the given index into value.  
 * If the attribute was not found or value could be interpreted as an integer, 
 * value is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a int.  For more information,
 * see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns @c true if the attribute was read into value, @c false otherwise.
 *
 */
bool
XMLAttributes::readInto (  int          index
			                   , const std::string& name
                         , int&         value
                         , XMLErrorLog* log
                         , bool         required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  long  temp;
  bool  assigned = readInto(index, name, temp, log, required, line, column);

  if (assigned) value = (int)temp;
  return assigned;
}
/** @endcond */


/*
 * Reads the value for the attribute with the given XMLTriple into value.  
 * If the XMLTriple was not found or value could be interpreted as an int, 
 * value is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a int.  For more information,
 * see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns @c true if the attribute was read into value, @c false otherwise.
 *
 */
bool
XMLAttributes::readInto (  const XMLTriple& triple
                         , int&             value
                         , XMLErrorLog*     log
                         , bool             required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  if (&triple == NULL) return false;
   return readInto(getIndex(triple), triple.getPrefixedName(), value, log, required, line, column);    
}


/*
 * Reads the value for the attribute name into value.  If name was not
 * found or value could not be interpreted as an int, value is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a int.  For more information,
 * see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns true if the attribute was read into value, false otherwise.
 */
bool
XMLAttributes::readInto (  const std::string&  name
                         , int&                value
                         , XMLErrorLog*        log
                         , bool                required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  return readInto(getIndex(name), name, value, log, required, line, column);
}


/** @cond doxygenLibsbmlInternal */
/*
 * Reads the value for the attribute with the given index into value.  
 * If the attribute was not found or value could be interpreted as an 
 * unsigned int, value is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a unsigned int.  For more
 * information, see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns @c true if the attribute was read into value, @c false otherwise.
 *
 */
bool
XMLAttributes::readInto (  int           index
			                   , const std::string& name
                         , unsigned int& value
                         , XMLErrorLog*  log
                         , bool          required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  long  temp;
  bool  assigned = readInto(index, name, temp, log, required, line, column);

  if (assigned && temp >= 0) value = (int)temp;
  else assigned = false;

  return assigned;
}
/** @endcond */


/*
 * Reads the value for the attribute with the given XMLTriple into value.  
 * If the XMLTriple was not found or value could be interpreted as an unsigned int, 
 * value is not modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a unsigned int.  For more
 * information, see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns @c true if the attribute was read into value, @c false otherwise.
 *
 */
bool
XMLAttributes::readInto (  const XMLTriple& triple
                         , unsigned int&    value
                         , XMLErrorLog*     log
                         , bool             required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  if (&triple == NULL) return false;
  return readInto(getIndex(triple), triple.getPrefixedName(), value, log, required, line, column);
}


/*
 * Reads the value for the attribute name into value.  If name was not
 * found or value could be interpreted as an unsigned int, value is not
 * modified.
 *
 * According to the W3C XML Schema valid integers include zero, *all*
 * positive and *all* negative whole numbers.  For practical purposes, we
 * limit values to what can be stored in a unsigned int.  For more
 * information, see: http://www.w3.org/TR/xmlschema-2/#integer
 *
 * If an XMLErrorLog is passed in datatype format errors are logged.  If
 * required is true, missing attributes are also logged.
 *
 * @returns true if the attribute was read into value, false otherwise.
 */
bool
XMLAttributes::readInto (  const std::string&  name
                         , unsigned int&       value
                         , XMLErrorLog*        log
                         , bool                required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  return readInto(getIndex(name), name, value, log, required, line, column);
}


/** @cond doxygenLibsbmlInternal */
/*
 * Reads the value for the attribute with the given index into value.  
 * If the attribute was not found, value is not modified.
 *
 * If an XMLErrorLog is passed in and required is true, missing
 * attributes are logged.
 *
 * @returns @c true if the attribute was read into value, @c false otherwise.
 *
 */
bool
XMLAttributes::readInto (  int          index
                         , const std::string& name
                         , std::string& value
                         , XMLErrorLog* log
                         , bool         required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  bool assigned = false;

  if ( index != -1 && &value != NULL)
  {
    value    = getValue(index);
    assigned = true;
  }

  if ( log == NULL ) log = mLog;

  if ( log != NULL && !assigned && required && &name != NULL )
  {
    attributeRequiredError(name, log, line, column);
  }

  return assigned;
}
/** @endcond */


/*
 * Reads the value for the attribute with the given XMLTriple into value.  
 * If the XMLTriple was not found, value is not modified.
 *
 * If an XMLErrorLog is passed in and required is true, missing
 * attributes are logged.
 *
 * @returns @c true if the attribute was read into value, @c false otherwise.
 *
 */
bool
XMLAttributes::readInto (  const XMLTriple& triple
			                   , std::string&     value
                         , XMLErrorLog*     log
                         , bool             required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  if (&triple == NULL) return false;
  return readInto(getIndex(triple), triple.getPrefixedName(), value, log, required, line, column);
}


/*
 * Reads the value for the attribute name into value.  If name was not
 * found, value is not modified.
 *
 * If an XMLErrorLog is passed in and required is true, missing
 * attributes are logged.
 *
 * @returns true if the attribute was read into value, false otherwise.
 */
bool
XMLAttributes::readInto (  const std::string& name
                         , std::string&       value
                         , XMLErrorLog*       log
                         , bool               required
                         , const unsigned int line     
                         , const unsigned int column   ) const
{
  return readInto(getIndex(name), name, value, log, required, line, column);
}


/** @cond doxygenLibsbmlInternal */
/*
 * Writes this XMLAttributes set to stream.
 */
void
XMLAttributes::write (XMLOutputStream& stream) const
{
  for (int n = 0; n < getLength(); ++n)
  {
    if ( getPrefix(n).empty() )
    {
      stream.writeAttribute( getName(n), getValue(n) );
    }
    else
    {
      stream.writeAttribute( mNames[n], getValue(n) );
    }
  }
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */

/*
 * Logs an attribute format error.
 *
 * @param  name  Name of the attribute
 * @param  type  The datatype of the attribute value.
 */
void
XMLAttributes::attributeTypeError (  const std::string& name
				   , DataType           type
				   , XMLErrorLog*       log
           , const unsigned int line     
           , const unsigned int column   ) const
{
  ostringstream message;

  if ( log == NULL ) log = mLog;
  if ( log == NULL ) return;

  message << "The ";
  if ( !mElementName.empty() ) message << mElementName << ' ';
  message << name;

  switch ( type )
  {
    case XMLAttributes::Boolean:
      message <<
        " attribute must have a value of either \"true\" or \"false\""
        " (all lowercase).  The numbers \"1\" (true) and \"0\" (false) are"
        " also allowed, but not preferred.  For more information, see:"
        " http://www.w3.org/TR/xmlschema-2/#boolean.";
      break;

    case XMLAttributes::Double:
      message <<
        " attribute must be a double (decimal number).  To represent"
        " infinity use \"INF\", negative infinity use \"-INF\", and"
        " not-a-number use \"NaN\".  For more information, see:"
        " http://www.w3.org/TR/xmlschema-2/#double.";
      break;

    case XMLAttributes::Integer:
      message <<
        " attribute must be an integer (whole number).  For more"
        " information, see: http://www.w3.org/TR/xmlschema-2/#integer.";
      break;
  }

  log->add( XMLError(XMLAttributeTypeMismatch, message.str(), line, column) );
}


/*
 * Logs an error indicating a required attribute was missing.
 *
 * @param  name  Name of the attribute
 */
void
XMLAttributes::attributeRequiredError (const std::string&  name
				       , XMLErrorLog*        log
               , const unsigned int line     
               , const unsigned int column   ) const
{
  ostringstream message;

  if ( log == NULL ) log = mLog;
  if ( log == NULL ) return;

  message << "The ";
  if ( !mElementName.empty() ) message << mElementName << ' ';
  message << "attribute '" << name << "' is required.";

  log->add( XMLError(MissingXMLRequiredAttribute, message.str(), line, column) );
}

/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Sets the XMLErrorLog this parser will use to log errors.
 */
int
XMLAttributes::setErrorLog (XMLErrorLog* log)
{
  if (mLog == log)
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else if (log == NULL)
  {
    delete mLog;
    mLog = NULL;
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    mLog = log;
    return LIBSBML_OPERATION_SUCCESS;
  }
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Inserts this XMLAttributes set into stream.
 */
LIBLAX_EXTERN
XMLOutputStream&
operator<< (XMLOutputStream& stream, const XMLAttributes& attributes)
{
  attributes.write(stream);
  return stream;
}
/** @endcond */


#endif /* __cplusplus */
/** @cond doxygenIgnored */


LIBLAX_EXTERN
XMLAttributes_t *
XMLAttributes_create (void)
{
  return new(nothrow) XMLAttributes;
}


LIBLAX_EXTERN
void
XMLAttributes_free (XMLAttributes_t *xa)
{
  if (xa == NULL) return;
  delete static_cast<XMLAttributes*>(xa);
}


LIBLAX_EXTERN
XMLAttributes_t *
XMLAttributes_clone (const XMLAttributes_t* att)
{
  if (att == NULL) return NULL;
  return static_cast<XMLAttributes*>( att->clone() );
}


LIBLAX_EXTERN
int
XMLAttributes_add (XMLAttributes_t *xa,
                   const char *name,
                   const char *value)
{
  if (xa == NULL) return LIBSBML_INVALID_OBJECT;
  return xa->add(name, value);
}


LIBLAX_EXTERN
int
XMLAttributes_addWithNamespace (XMLAttributes_t *xa,
                                const char *name,
                                const char *value,
                                const char* uri,
                                const char* prefix)
{
  if (xa == NULL) return LIBSBML_INVALID_OBJECT;
  return xa->add(name, value, uri, prefix);
}


LIBLAX_EXTERN
int
XMLAttributes_addWithTriple ( XMLAttributes_t *xa 
			              , const XMLTriple_t* triple
			              , const char *value)
{
  if (xa == NULL) return LIBSBML_INVALID_OBJECT;
  return xa->add(*triple, value);
}


LIBLAX_EXTERN
int
XMLAttributes_removeResource (XMLAttributes_t *xa, int n)
{
  if (xa == NULL) return LIBSBML_INVALID_OBJECT;
  return xa->removeResource(n);
}


LIBLAX_EXTERN
int
XMLAttributes_remove (XMLAttributes_t *xa, int n)
{
  if (xa == NULL) return LIBSBML_INVALID_OBJECT;
  return xa->remove(n);
}


LIBLAX_EXTERN
int
XMLAttributes_removeByName (XMLAttributes_t *xa, const char* name)
{
  if (xa == NULL) return LIBSBML_INVALID_OBJECT;
  return xa->remove(name);
}


LIBLAX_EXTERN
int
XMLAttributes_removeByNS (XMLAttributes_t *xa, const char* name, const char* uri)
{
  if (xa == NULL) return LIBSBML_INVALID_OBJECT;
  return xa->remove(name, uri);
}


LIBLAX_EXTERN
int
XMLAttributes_removeByTriple (XMLAttributes_t *xa, const XMLTriple_t* triple)
{
  if (xa == NULL || triple == NULL) return LIBSBML_INVALID_OBJECT;
  return xa->remove(*triple);
}


LIBLAX_EXTERN
int 
XMLAttributes_clear(XMLAttributes_t *xa)
{
  if (xa == NULL) return LIBSBML_INVALID_OBJECT;
  return xa->clear();
}


LIBLAX_EXTERN
int
XMLAttributes_getIndex (const XMLAttributes_t *xa, const char *name)
{
  if (xa == NULL) return -1;
  return xa->getIndex(name);
}


LIBLAX_EXTERN
int
XMLAttributes_getIndexByNS (const XMLAttributes_t *xa, const char *name, const char *uri)
{
  if (xa == NULL) return -1;
  return xa->getIndex(name,uri);
}


LIBLAX_EXTERN
int 
XMLAttributes_getIndexByTriple (const XMLAttributes_t *xa, const XMLTriple_t* triple)
{
  if (xa == NULL) return -1;
  return xa->getIndex(*triple);
}


LIBLAX_EXTERN
int
XMLAttributes_getLength (const XMLAttributes_t *xa)
{
  if (xa == NULL) return 0;
  return xa->getLength();
}


LIBLAX_EXTERN
int
XMLAttributes_getNumAttributes (const XMLAttributes_t *xa)
{
  if (xa == NULL) return 0;
  return xa->getLength();
}


LIBLAX_EXTERN
char *
XMLAttributes_getName (const XMLAttributes_t *xa, int index)
{
  if (xa == NULL) return NULL;
  return xa->getName(index).empty() ? NULL : safe_strdup(xa->getName(index).c_str());
}


LIBLAX_EXTERN
char *
XMLAttributes_getPrefix (const XMLAttributes_t *xa, int index)
{
  if (xa == NULL) return NULL;
  return xa->getPrefix(index).empty() ? NULL : safe_strdup(xa->getPrefix(index).c_str());
}


LIBLAX_EXTERN
char *
XMLAttributes_getURI (const XMLAttributes_t *xa, int index)
{
  if (xa == NULL) return NULL;
  return xa->getURI(index).empty() ? NULL : safe_strdup(xa->getURI(index).c_str());
}


LIBLAX_EXTERN
char *
XMLAttributes_getValue (const XMLAttributes_t *xa, int index)
{
  if (xa == NULL) return NULL;
  return xa->getValue(index).empty() ? NULL : safe_strdup(xa->getValue(index).c_str());
}


LIBLAX_EXTERN
char *
XMLAttributes_getValueByName (const XMLAttributes_t *xa, const char *name)
{
  if (xa == NULL) return NULL;
  return xa->getValue(name).empty() ? NULL : safe_strdup(xa->getValue(name).c_str());
}


LIBLAX_EXTERN
char *
XMLAttributes_getValueByNS (const XMLAttributes_t *xa, const char *name, const char* uri)
{
  if (xa == NULL) return NULL;
  return (xa->getValue(name, uri).empty())? NULL : safe_strdup(xa->getValue(name, uri).c_str());
}


LIBLAX_EXTERN
char *
XMLAttributes_getValueByTriple (const XMLAttributes_t *xa, const XMLTriple_t* triple)
{
  //std::string val = xa->getValue(*triple);
  //if (val.empty()) return NULL;
  if (xa == NULL) return NULL;
  return xa->getValue(*triple).empty() ? NULL : safe_strdup(xa->getValue(*triple).c_str());
}


LIBLAX_EXTERN
int 
XMLAttributes_hasAttribute (const XMLAttributes_t *xa, int index)
{
  if (xa == NULL) return (int)false;
  return static_cast<int>( xa->hasAttribute(index) );
}


LIBLAX_EXTERN
int 
XMLAttributes_hasAttributeWithName (const XMLAttributes_t *xa, const char* name)
{
  if (xa == NULL) return (int)false;
  return static_cast<int>( xa->hasAttribute(name) );
}


LIBLAX_EXTERN
int 
XMLAttributes_hasAttributeWithNS (const XMLAttributes_t *xa, 
                                  const char* name, const char* uri)
{
  if (xa == NULL) return (int)false;
  return static_cast<int>( xa->hasAttribute(name, uri) );
}


LIBLAX_EXTERN
int 
XMLAttributes_hasAttributeWithTriple (const XMLAttributes_t *xa, const XMLTriple_t* triple)
{
  if (xa == NULL) return (int)false;
  return static_cast<int>( xa->hasAttribute(*triple) );
}  


LIBLAX_EXTERN
int
XMLAttributes_isEmpty (const XMLAttributes_t *xa)
{
  if (xa == NULL) return (int)true;
  return static_cast<int>( xa->isEmpty() );
}


LIBLAX_EXTERN
int
XMLAttributes_readIntoBoolean (XMLAttributes_t *xa,
			       const char *name,
			       int *value,
			       XMLErrorLog_t *log,
			       int required)
{
  if (xa == NULL) return (int)false;
  bool temp;
  bool result = xa->readInto(name, temp, log, required);
  if (result)
  {
    *value = static_cast<int>(temp);
  }
  return static_cast<int>(result);
}


LIBLAX_EXTERN
int
XMLAttributes_readIntoBooleanByTriple (XMLAttributes_t *xa,
                               const XMLTriple_t* triple,
                               int *value,
                               XMLErrorLog_t *log,
                               int required)
{
  if (xa == NULL) return (int)false;

  bool temp;
  bool result = xa->readInto(*triple, temp, log, required);
  if (result)
  {
    *value = static_cast<int>(temp);
  }
  return static_cast<int>(result);
}


LIBLAX_EXTERN
int
XMLAttributes_readIntoDouble (XMLAttributes_t *xa,
			      const char *name,
			      double *value,
			      XMLErrorLog_t *log,
			      int required)
{
  if (xa == NULL) return (int)false;
  return static_cast<int>( xa->readInto(name, *(value), log, required) );
}


LIBLAX_EXTERN
int
XMLAttributes_readIntoDoubleByTriple (XMLAttributes_t *xa,
                               const XMLTriple_t* triple,
                               double *value,
                               XMLErrorLog_t *log,
                               int required)
{
  if (xa == NULL || value == NULL || triple == NULL) return (int)false;
  return static_cast<int>( xa->readInto(*triple, *(value), log, required) );
}


LIBLAX_EXTERN
int
XMLAttributes_readIntoLong (XMLAttributes_t *xa,
			    const char *name,
			    long *value,
			    XMLErrorLog_t *log,
			    int required)
{
  if (xa == NULL || value == NULL) return (int)false;
  return static_cast<int>( xa->readInto(name, *(value), log, required) );
}


LIBLAX_EXTERN
int
XMLAttributes_readIntoLongByTriple (XMLAttributes_t *xa,
                               const XMLTriple_t* triple,
                               long *value,
                               XMLErrorLog_t *log,
                               int required)
{
  if (xa == NULL || triple == NULL || value == NULL) return (int)false;
  return static_cast<int>( xa->readInto(*triple, *(value), log, required) );
}


LIBLAX_EXTERN
int
XMLAttributes_readIntoInt (XMLAttributes_t *xa,
			   const char *name,
			   int *value,
			   XMLErrorLog_t *log,
			   int required)
{
  if (xa == NULL || value == NULL) return (int)false;
  return static_cast<int>( xa->readInto(name, *(value), log, required) );
}

LIBLAX_EXTERN
int
XMLAttributes_readIntoIntByTriple (XMLAttributes_t *xa,
                               const XMLTriple_t* triple,
                               int *value,
                               XMLErrorLog_t *log,
                               int required)
{
  if (xa == NULL || triple == NULL || value == NULL) return (int)false;
  return static_cast<int>( xa->readInto(*triple, *(value), log, required) );
}


LIBLAX_EXTERN
int
XMLAttributes_readIntoUnsignedInt (XMLAttributes_t *xa,
				   const char *name,
				   unsigned int *value,
				   XMLErrorLog_t *log,
				   int required)
{
  if (xa == NULL || value == NULL) return (int)false;
  return static_cast<int>( xa->readInto(name, *(value), log, required) );
}


LIBLAX_EXTERN
int
XMLAttributes_readIntoUnsignedIntByTriple (XMLAttributes_t *xa,
                               const XMLTriple_t* triple,
                               unsigned int *value,
                               XMLErrorLog_t *log,
                               int required)
{
  if (xa == NULL || triple == NULL || value == NULL) return (int)false;
  return static_cast<int>( xa->readInto(*triple, *(value), log, required) );
}



LIBLAX_EXTERN
int
XMLAttributes_readIntoString (XMLAttributes_t *xa,
			      const char *name,
			      char **value,
			      XMLErrorLog_t *log,
			      int required)
{
  if (xa == NULL || value == NULL) return (int)false;
  std::string temp;
  int result = static_cast<int>( xa->readInto(name, temp, log, required) );
  if(result)
  {
    *value = safe_strdup(temp.c_str());
  }
  return result;
}


LIBLAX_EXTERN
int
XMLAttributes_readIntoStringByTriple (XMLAttributes_t *xa,
                               const XMLTriple_t* triple,
                               char **value,
                               XMLErrorLog_t *log,
                               int required)
{
  if (xa == NULL || value == NULL || triple == NULL) return (int)false;
  std::string temp;
  int result = static_cast<int>( xa->readInto(*triple, temp, log, required) );
  if(result)
  {
    *value = safe_strdup(temp.c_str());
  }
  return result;
}


LIBSBML_CPP_NAMESPACE_END


/** @endcond */

