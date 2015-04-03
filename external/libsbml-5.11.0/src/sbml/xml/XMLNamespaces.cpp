/**
 * @file    XMLNamespaces.cpp
 * @brief   A list of XMLNamespace declarations (URI/prefix pairs)
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

/** @cond doxygenLibsbmlInternal */
#include <sbml/xml/XMLOutputStream.h>
#include <sbml/util/util.h>
/** @endcond */

#include <sbml/xml/XMLTriple.h>
#include <sbml/xml/XMLNamespaces.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLConstructorException.h>
#include <sbml/SBMLNamespaces.h>
#include <sbml/util/List.h>


/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/*
 * Creates a new empty list of XML namespace declarations.
 */
XMLNamespaces::XMLNamespaces ()
{
}


/*
 * Destroys this list of XML namespace declarations.
 */
XMLNamespaces::~XMLNamespaces ()
{
}


/*
 * Copy constructor; creates a copy of this XMLNamespaces set.
 */
XMLNamespaces::XMLNamespaces(const XMLNamespaces& orig)
{
  if (&orig == NULL)
  {
    throw XMLConstructorException("Null argument to copy constructor");
  }
  else  
  {
    mNamespaces.assign( orig.mNamespaces.begin(), orig.mNamespaces.end() ); 
  }
}


/*
 * Assignment operator for XMLNamespaces.
 */
XMLNamespaces& 
XMLNamespaces::operator=(const XMLNamespaces& rhs)
{
  if (&rhs == NULL)
  {
    throw XMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    mNamespaces.assign( rhs.mNamespaces.begin(), rhs.mNamespaces.end() ); 
  }
  
  return *this;
}

/*
 * Creates and returns a deep copy of this XMLNamespaces set.
 * 
 * @return a (deep) copy of this XMLNamespaces set.
 */
XMLNamespaces* 
XMLNamespaces::clone () const
{
  return new XMLNamespaces(*this);
}

/*
 * Appends an XML namespace prefix/URI pair to this list of namespace
 * declarations.
 * If there is an XML namespace with the given prefix in this list,
 * then the existing XML namespace will be overwritten by the new one.
 */
int
XMLNamespaces::add (const std::string& uri, const std::string& prefix)
{
  if (&uri == NULL || &prefix == NULL) return LIBSBML_INVALID_OBJECT;
  //
  // avoids duplicate prefix
  // BUT do not replace the sbml core ns
  //
  bool sbmlCoreNS = false;
  if (getURI(prefix).empty() == false)
  {
    // there is already a uri with this prefix
    // is it the sbml ns
    const List * supportedNS = SBMLNamespaces::getSupportedNamespaces();
    for (unsigned int i = 0; i < supportedNS->getSize(); i++)
    {
      const SBMLNamespaces * current = (const SBMLNamespaces *) supportedNS->get(i);
      if (getURI(prefix) == current->getURI())
      {
        sbmlCoreNS = true;
        break;
      }
    }    
    SBMLNamespaces::freeSBMLNamespaces(const_cast<List*>(supportedNS));    
  }

  if (sbmlCoreNS == true)
  {
    return LIBSBML_OPERATION_FAILED;
  }
  else
  {
    if ( prefix.empty()    ) removeDefault();
    if ( hasPrefix(prefix) ) remove(prefix);

    mNamespaces.push_back( make_pair(prefix, uri) );
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * @param index an integer, position of the removed namespace.
 */
int XMLNamespaces::remove (int index)
{
  if (index < 0 || index >= getLength()) 
  {
    return LIBSBML_INDEX_EXCEEDS_SIZE;
  }

  vector<PrefixURIPair>::iterator it = mNamespaces.begin() + index;
  mNamespaces.erase(it);

  return LIBSBML_OPERATION_SUCCESS;
}



/*
 * @param prefix a string, prefix of the required namespace.
 */
int XMLNamespaces::remove (const std::string& prefix)
{
  int index = getIndexByPrefix(prefix);
  if(index == -1) 
  {
    return LIBSBML_INDEX_EXCEEDS_SIZE;
  }

  vector<PrefixURIPair>::iterator it = mNamespaces.begin() + index;
  mNamespaces.erase(it);

  return LIBSBML_OPERATION_SUCCESS;
}


/*
 * Clears (deletes) all XML namespace declarations.
 */
int
XMLNamespaces::clear ()
{
  mNamespaces.clear();
  if (mNamespaces.empty())
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Lookup the index of an XML namespace declaration by URI.
 *
 * @return the index of the given declaration, or -1 if not present.
 */
int
XMLNamespaces::getIndex (const std::string uri) const
{
  for (int index = 0; index < getLength(); ++index)
  {
    if (getURI(index) == uri) return index;
  }
  
  return -1;
}

/**
 * Tests whether the given uri is contained in this set of namespaces. 
 */
bool 
XMLNamespaces::containsUri(const std::string uri) const
{
  return getIndex(uri) != -1;
}

/*
 * Lookup the index of an XML namespace declaration by Prefix.
 *
 * @return the index of the given declaration, or -1 if not present.
 */
int
XMLNamespaces::getIndexByPrefix (const std::string prefix) const
{
  for (int index = 0; index < getLength(); ++index)
  {
     if (getPrefix(index) == prefix) return index;
  }
  
  return -1;
}


/*
 * @return the number of namespaces in this list.
 */
int
XMLNamespaces::getLength () const
{
  return (int)mNamespaces.size();
}


/*
 * @return the number of namespaces in this list.
 */
int
XMLNamespaces::getNumNamespaces () const
{
  return (int)mNamespaces.size();
}


/*
 * @return the prefix of an XML namespace declaration in this list (by
 * position).  If index is out of range, an empty string will be
 * returned.
 */
std::string
XMLNamespaces::getPrefix (int index) const
{
  return (index < 0 || index >= getLength()) ? std::string() : mNamespaces[index].first;
}


/*
 * @return the prefix of an XML namespace declaration given its URI.  If
 * URI does not exist, an empty string will be returned.
 */
std::string
XMLNamespaces::getPrefix (const std::string& uri) const
{
  return getPrefix( getIndex(uri) );
}


/*
 * @return the URI of an XML namespace declaration in this list (by
 * position).  If index is out of range, an empty string will be
 * returned.
 */
std::string
XMLNamespaces::getURI (int index) const
{
  return (index < 0 || index >= getLength()) ? std::string() : mNamespaces[index].second;
}


/*
 * @return the URI of an XML namespace declaration given its prefix.  If
 * no prefix is given and a default namespace exists it will be returned.
 * If prefix does not exist, an empty string will be returned.
 */
std::string
XMLNamespaces::getURI (const std::string& prefix) const
{
  if (&prefix == NULL) return std::string();
  for (int index = 0; index < getLength(); ++index)
  {
    if (getPrefix(index) == prefix) return getURI(index);
  }
  
  return std::string();
}


/*
 * @return true if this XMLNamespaces set is empty, false otherwise.
 */
bool
XMLNamespaces::isEmpty () const
{
  return (getLength() == 0);
}


 /*
  * @return @c true if an XML Namespace with the given URI is contained in this 
  * XMLNamespaces list,  @c false otherwise.
  */
bool XMLNamespaces::hasURI(const std::string& uri) const
{
  if (&uri == NULL) return false;
  return ( getIndex(uri) != -1 );
}


/*
 * @return @c true if an XML Namespace with the given URI is contained in this 
 * XMLNamespaces list, @c false otherwise.
 */
bool XMLNamespaces::hasPrefix(const std::string& prefix) const
{
  if (&prefix == NULL) return false;
  return ( getIndexByPrefix(prefix) != -1 );
}


/*
 * @return @c true if an XML Namespace with the given uri/prefix pair is 
 * contained in this XMLNamespaces list,  @c false otherwise.
 */
bool XMLNamespaces::hasNS(const std::string& uri, const std::string& prefix) const
{
  if (&uri == NULL || &prefix == NULL) return false;

  for (int i= 0; i < getLength(); ++i)
  {
     if ( (getURI(i) == uri) && (getPrefix(i) == prefix) ) 
       return true;
  }

  return false;
}


/** @cond doxygenLibsbmlInternal */
/*
 * Removes the default XML namespace.
 */
void
XMLNamespaces::removeDefault ()
{
  vector<PrefixURIPair>::iterator i;

  for (i = mNamespaces.begin(); i != mNamespaces.end(); ++i)
  {
    if (i->first.empty())
    {
      mNamespaces.erase(i);
      break;
    }
  }
}

bool 
XMLNamespaces::containIdenticalSetNS(XMLNamespaces* rhs)
{
  bool equivalent = true;

  if (getNumNamespaces() != rhs->getNumNamespaces())
  {
    equivalent = false;
  }

  int i = 0;

  while(i < getNumNamespaces() && equivalent == true)
  {
    // in order for namespaces to be identical, the namespace prefixes don't 
    // necessarily have to match, the only requirement is that the uri's match
    //
    // if (!rhs->hasNS(getURI(i), getPrefix(i)))
    //
    if (!rhs->hasURI(getURI(i)))
    {
      equivalent = false;
    }

    i++;
  }

  return equivalent;
}

/** @endcond */

#ifndef SWIG

/** @cond doxygenLibsbmlInternal */
/*
 * Writes the XML namespace declarations to stream.
 */
void
XMLNamespaces::write (XMLOutputStream& stream) const
{
  for (int n = 0; n < getLength(); ++n)
  {
    if ( getPrefix(n).empty() )
    {
      stream.writeAttribute( "xmlns", getURI(n) );
    }
    else
    {
      const XMLTriple triple(getPrefix(n), "", "xmlns");
      stream.writeAttribute( triple, getURI(n) );
    }
  }
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Inserts this XML namespace declarations into stream.
 */
LIBLAX_EXTERN
XMLOutputStream&
operator<< (XMLOutputStream& stream, const XMLNamespaces& namespaces)
{
  namespaces.write(stream);
  return stream;
}
/** @endcond */

#endif  /* !SWIG */


#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBLAX_EXTERN
XMLNamespaces_t *
XMLNamespaces_create (void)
{
  return new(nothrow) XMLNamespaces;
}


LIBLAX_EXTERN
void
XMLNamespaces_free (XMLNamespaces_t *ns)
{
  if (ns == NULL) return;
  delete ns;
}


LIBLAX_EXTERN
XMLNamespaces_t *
XMLNamespaces_clone (const XMLNamespaces_t* ns)
{
  if (ns == NULL) return NULL;
  return static_cast<XMLNamespaces*>( ns->clone() );
}


LIBLAX_EXTERN
int
XMLNamespaces_add (XMLNamespaces_t *ns, 
		   const char *uri, const char *prefix)
{
  if (ns == NULL) return LIBSBML_INVALID_OBJECT;
  return ns->add(uri, prefix);
}


LIBLAX_EXTERN
int XMLNamespaces_remove (XMLNamespaces_t *ns, int index)
{
  if (ns == NULL) return LIBSBML_INVALID_OBJECT;
  return ns->remove(index);
}


LIBLAX_EXTERN
int XMLNamespaces_removeByPrefix (XMLNamespaces_t *ns, const char* prefix)
{
  if (ns == NULL) return LIBSBML_INVALID_OBJECT;
  return ns->remove(prefix);
}



LIBLAX_EXTERN
int
XMLNamespaces_clear (XMLNamespaces_t *ns)
{
  if (ns == NULL) return LIBSBML_OPERATION_FAILED;
  return ns->clear();
}


LIBLAX_EXTERN
int
XMLNamespaces_getIndex (const XMLNamespaces_t *ns, const char *uri)
{
  if (ns == NULL) return -1;
  return ns->getIndex(uri);
}


LIBLAX_EXTERN
int XMLNamespaces_getIndexByPrefix (const XMLNamespaces_t *ns, const char* prefix)
{
  if (ns == NULL) return -1;
  return ns->getIndexByPrefix(prefix);
}


LIBLAX_EXTERN
int
XMLNamespaces_getLength (const XMLNamespaces_t *ns)
{
  if (ns == NULL) return 0;
  return ns->getLength();
}


LIBLAX_EXTERN
int
XMLNamespaces_getNumNamespaces (const XMLNamespaces_t *ns)
{
  if (ns == NULL) return 0;
  return ns->getLength();
}


LIBLAX_EXTERN
char *
XMLNamespaces_getPrefix (const XMLNamespaces_t *ns, int index)
{
  if (ns == NULL) return NULL;
  return ns->getPrefix(index).empty() ? NULL : safe_strdup(ns->getPrefix(index).c_str());
}


LIBLAX_EXTERN
char *
XMLNamespaces_getPrefixByURI (const XMLNamespaces_t *ns, const char *uri)
{
  if (ns == NULL) return NULL;
  return ns->getPrefix(uri).empty() ? NULL : safe_strdup(ns->getPrefix(uri).c_str());
}

LIBLAX_EXTERN
char *
XMLNamespaces_getURI (const XMLNamespaces_t *ns, int index)
{
  if (ns == NULL) return NULL;
  return ns->getURI(index).empty() ? NULL : safe_strdup(ns->getURI(index).c_str());
}

LIBLAX_EXTERN
char *
XMLNamespaces_getURIByPrefix (const XMLNamespaces_t *ns, const char *prefix)
{
  if (ns == NULL) return NULL;
  return ns->getURI(prefix).empty() ? NULL : safe_strdup(ns->getURI(prefix).c_str());
}


LIBLAX_EXTERN
int
XMLNamespaces_isEmpty (const XMLNamespaces_t *ns)
{
  if (ns == NULL) return (int)true;
  return ns->isEmpty();
}


LIBLAX_EXTERN
int 
XMLNamespaces_hasURI(const XMLNamespaces_t *ns, const char* uri)
{
  if (ns == NULL) return (int)false;
  return ns->hasURI(uri);
}


LIBLAX_EXTERN
int 
XMLNamespaces_hasPrefix(const XMLNamespaces_t *ns, const char* prefix)
{
  if (ns == NULL) return (int)false;
  return ns->hasPrefix(prefix);
}


LIBLAX_EXTERN
int 
XMLNamespaces_hasNS(const XMLNamespaces_t *ns, const char* uri, const char* prefix)
{
  if (ns == NULL) return (int)false;
  return ns->hasNS(uri, prefix);
}


/** @endcond */

LIBSBML_CPP_NAMESPACE_END
