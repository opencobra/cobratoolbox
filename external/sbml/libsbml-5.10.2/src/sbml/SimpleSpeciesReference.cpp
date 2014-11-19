/**
 * @file    SimpleSpeciesReference.cpp
 * @brief   Implementation of SimpleSpeciesReference. 
 * @author  Ben Bornstein
 *
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


#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/math/FormulaParser.h>
#include <sbml/math/MathML.h>
#include <sbml/math/ASTNode.h>

#include <sbml/SBO.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>
#include <sbml/SpeciesReference.h>
#include <sbml/extension/SBasePlugin.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

SimpleSpeciesReference::SimpleSpeciesReference (unsigned int level, 
                                                unsigned int version) :
   SBase ( level, version )
 , mId     ( "" )
 , mName   ( "" )
 , mSpecies( "" )
{
}


/** @cond doxygenLibsbmlInternal */
SimpleSpeciesReference::SimpleSpeciesReference (SBMLNamespaces *sbmlns) :
   SBase   (sbmlns  )
 , mId     ( "" )
 , mName   ( "" )
 , mSpecies( "" )
{
  loadPlugins(sbmlns);
}
/** @endcond */


/*
 * Destroys this SimpleSpeciesReference.
 */
SimpleSpeciesReference::~SimpleSpeciesReference ()
{
}


/*
 * Copy constructor. Creates a copy of this SimpleSpeciesReference.
 */
SimpleSpeciesReference::SimpleSpeciesReference(const SimpleSpeciesReference& orig) :
   SBase     ( orig                    )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mId      = orig.mId;
    mName    = orig.mName;
    mSpecies = orig.mSpecies;
  }
}


/*
 * Assignment operator.
 */
SimpleSpeciesReference& SimpleSpeciesReference::operator=(const SimpleSpeciesReference& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBase::operator =(rhs);
    mId = rhs.mId;
    mName = rhs.mName;
    mSpecies = rhs.mSpecies;
  }

  return *this;
}


/*
 * Accepts the given SBMLVisitor.
 *
 * @return the result of calling <code>v.visit()</code>, which indicates
 * whether or not the Visitor would like to visit the Reaction's next
 * SimpleSpeciesReference (if available).
 */
bool
SimpleSpeciesReference::accept (SBMLVisitor& v) const
{
  return v.visit(*this);
}


/*
 * @return the id of this SBML object.
 */
const string&
SimpleSpeciesReference::getId () const
{
  return mId;
}


/*
 * @return the name of this SBML object.
 */
const string&
SimpleSpeciesReference::getName () const
{
  return (getLevel() == 1) ? mId : mName;
}


/*
 * @return the species for this SimpleSpeciesReference.
 */
const string&
SimpleSpeciesReference::getSpecies () const
{
  return mSpecies;
}


/*
 * @return true if the id of this SBML object is set, false
 * otherwise.
 */
bool
SimpleSpeciesReference::isSetId () const
{
  return (mId.empty() == false);
}


/*
 * @return true if the name of this SBML object is set, false
 * otherwise.
 */
bool
SimpleSpeciesReference::isSetName () const
{
  return (getLevel() == 1) ? (mId.empty() == false) : 
                            (mName.empty() == false);
}


/*
 * @return true if the species for this SimpleSpeciesReference is 
 * set, false otherwise.
 */
bool
SimpleSpeciesReference::isSetSpecies () const
{
  return (mSpecies.empty() == false);
}


/*
 * Sets the species of this SimpleSpeciesReference to a copy of sid.
 */
int
SimpleSpeciesReference::setSpecies (const std::string& sid)
{
  if (&(sid) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else if (!(SyntaxChecker::isValidInternalSId(sid)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mSpecies = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the id of this SBML object to a copy of sid.
 */
int
SimpleSpeciesReference::setId (const std::string& sid)
{
  if (&(sid) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else if (getLevel() == 1 ||
    (getLevel() == 2 && getVersion() == 1))
  {
    //
    // (NOTE)
    //
    // The code below is specific to Layout Extension for SBML Level 2 Version 1.
    // The purpose of this code is not to break existing code based on optional 
    // Layout Extension implemented in libSBML 4 or before.
    //
    // (Basically, this kind of code which is specific to some package extension 
    //  should not be implemented in source files for SBML Core package. 
    //  However, only layout extension has been implemented in previours libSBML and 
    //  thus removing the code below can greately break existing code, which should 
    //  be avoided.)
    //
    bool enabledLayoutL2 = false;
    const std::string layoutL2URI = "http://projects.eml.org/bcb/sbml/level2";
    std::vector<SBasePlugin*>::iterator mextIter = mPlugins.begin();
    while (mextIter != mPlugins.end())
    { 
      if ( (*mextIter)->getURI() == layoutL2URI)
      {
#if 0
          std::cout << "[DEBUG] SimpleSpeciesReference::setId() layoutL2 is enabled" << std::endl;
#endif
        enabledLayoutL2 = true;
        break;
      }
      ++mextIter;
    }
                   
    if (enabledLayoutL2)
    {
      mId = sid;
      return LIBSBML_OPERATION_SUCCESS;
    }
    else
    {
      return LIBSBML_UNEXPECTED_ATTRIBUTE;
    }
  }
  else if (!(SyntaxChecker::isValidInternalSId(sid)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mId = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the name of this SBML object to a copy of name.
 */
int
SimpleSpeciesReference::setName (const std::string& name)
{
  if (&(name) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else if (getLevel() == 1 ||
    (getLevel() == 2 && getVersion() == 1))
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else if (!(SyntaxChecker::isValidInternalSId(name)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    if (getLevel() == 1) mId = name;
    else mName = name;
    return LIBSBML_OPERATION_SUCCESS;
  }
}

/*
 * Unsets the id of this SBML object.
 */
int
SimpleSpeciesReference::unsetId ()
{
  mId.erase();

  if (mId.empty())
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Unsets the name of this SBML object.
 */
int
SimpleSpeciesReference::unsetName ()
{
  if (getLevel() == 1) 
  {
    mId.erase();
  }
  else 
  {
    mName.erase();
  }

  if (getLevel() == 1 && mId.empty())
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else if (mName.empty())
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * @return true if this SpeciesReference is a ModiferSpeciesReference,
 * false otherwise.
 */
bool
SimpleSpeciesReference::isModifier () const
{
  return (getTypeCode() == SBML_MODIFIER_SPECIES_REFERENCE);
}


void
SimpleSpeciesReference::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetSpecies()) {
    if (mSpecies==oldid) setSpecies(newid);
  }
}

/** @cond doxygenLibsbmlInternal */
bool 
SimpleSpeciesReference::hasRequiredAttributes() const
{
  bool allPresent = true;

  if (!isSetSpecies())
    allPresent = false;

  return allPresent;
}


/**
 * Subclasses should override this method to get the list of
 * expected attributes.
 * This function is invoked from corresponding readAttributes()
 * function.
 */
void
SimpleSpeciesReference::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  const string s = (level == 1 && version == 1) ? "specie" : "species";
  attributes.add(s);

  if (level > 1)
  {
    if (!(level == 2 && version == 1))
    {
      attributes.add("id");
      attributes.add("name");
    }

    if (level == 2 && version == 2)
      attributes.add("sboTerm");

  }
}

/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
SimpleSpeciesReference::readAttributes (const XMLAttributes& attributes,
                                        const ExpectedAttributes& expectedAttributes)
{
  const unsigned int level   = getLevel  ();

  SBase::readAttributes(attributes, expectedAttributes);

  switch (level)
  {
  case 1:
    readL1Attributes(attributes);
    break;
  case 2:
    readL2Attributes(attributes);
    break;
  case 3:
  default:
    readL3Attributes(attributes);
    break;
  }
}


void
SimpleSpeciesReference::readL1Attributes (const XMLAttributes& attributes)
{
  const unsigned int version = getVersion();

  //
  // specie : SName   { use="required" }  (L1v1)
  // species: SName   { use="required" }  (L1v2, L2v1->)
  //
  const string s = (version == 1) ? "specie" : "species";
  attributes.readInto(s , mSpecies, getErrorLog(), true, getLine(), getColumn());
}


void
SimpleSpeciesReference::readL2Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();
  //
  // species: SName   { use="required" }  (L1v2, L2v1->)
  //
  attributes.readInto("species" , mSpecies, getErrorLog(), true, getLine(), getColumn());
  
  if (version > 1)
  {
    //
    // id: SId  { use="optional" }  (L2v2->)
    //
    bool assigned = attributes.readInto("id", mId, getErrorLog(), false, getLine(), getColumn());
    if (assigned && mId.size() == 0)
    {
      logEmptyString("id", level, version, "<speciesReference>");
    }
    if (!SyntaxChecker::isValidInternalSId(mId)) logError(InvalidIdSyntax);

    //
    // name: string  { use="optional" }  (L2v2->)
    //
    attributes.readInto("name" , mName, getErrorLog(), false, getLine(), getColumn());
  }
  if (version == 2)
  {
    //
    // sboTerm: SBOTerm { use="optional" }  (L2v2->)
    //
    mSBOTerm = SBO::readTerm(attributes, this->getErrorLog(), level, version,
				getLine(), getColumn());
  }

}


void
SimpleSpeciesReference::readL3Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();
  //
  // species: SName   { use="required" }  (L1v2, L2v1->)
  //
  bool assigned = attributes.readInto("species" , mSpecies, getErrorLog(), false, getLine(), getColumn());
  if (!assigned)
  {
    if (isModifier())
      logError(AllowedAttributesOnModifier, 
                     level, version, "The required attribute 'species' is missing.");
    else
      logError(AllowedAttributesOnSpeciesReference, 
                     level, version, "The required attribute 'species' is missing.");
  }
 
  //
  // id: SId  { use="optional" }  (L2v2->)
  //
  assigned = attributes.readInto("id", mId, getErrorLog(), false, getLine(), getColumn());
  if (assigned && mId.size() == 0)
  {
    logEmptyString("id", level, version, "<speciesReference>");
  }
  if (!SyntaxChecker::isValidInternalSId(mId)) logError(InvalidIdSyntax);

  //
  // name: string  { use="optional" }  (L2v2->)
  //
  attributes.readInto("name" , mName, getErrorLog(), false, getLine(), getColumn());

}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write their XML attributes
 * to the XMLOutputStream.  Be sure to call your parents implementation
 * of this method as well.
 */
void
SimpleSpeciesReference::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();


  if (level > 1)
  {
    if (!(level == 2 && version == 1))
    {
      //
      // sboTerm: SBOTerm { use="optional" }  (L2v2->)
      //
      //
      // sboTerm for L2V3 or later is written in SBase::writeAttributes()
      //
      if ( (level == 2) && (version == 2) )
      {
        SBO::writeTerm(stream, mSBOTerm);
      }

      //
      // id: SId  { use="optional" }  (L2v2->)
      //
      stream.writeAttribute("id" , mId);

      //
      // name: string  { use="optional" }  (L2v2->)
      //
      stream.writeAttribute("name" , mName);
    }
  }

  //
  // specie : SName   { use="required" }  (L1v1)
  // species: SName   { use="required" }  (L1v2, L2v1->)
  //
  const string s = (level == 1 && version == 1) ? "specie" : "species";
  stream.writeAttribute(s , mSpecies);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */

#endif /* __cplusplus */
/** @cond doxygenIgnored */

/** @endcond */

LIBSBML_CPP_NAMESPACE_END

