/**
 * @file    SpeciesGlyph.cpp
 * @brief   Implementation of SpeciesGlyph for SBML Layout.
 * @author  Ralph Gauges
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
 * Copyright (C) 2004-2008 by European Media Laboratories Research gGmbH,
 *     Heidelberg, Germany
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */

#include <sbml/packages/layout/sbml/SpeciesGlyph.h>
#include <sbml/packages/layout/sbml/Layout.h>
#include <sbml/packages/layout/util/LayoutUtilities.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/packages/layout/validator/LayoutSBMLError.h>
LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

void
SpeciesGlyph::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  GraphicalObject::renameSIdRefs(oldid, newid);
  if (isSetSpeciesId() && mSpecies == oldid) 
  {
    mSpecies = newid;
  }
}

/*
 * Creates a new SpeciesGlyph with the given SBML level, version, and package version
 * and the id of the associated species set to the empty string.
 */        
SpeciesGlyph::SpeciesGlyph (unsigned int level, unsigned int version, unsigned int pkgVersion)
  : GraphicalObject(level,version,pkgVersion)
  , mSpecies("")
{
  //
  // (NOTE) Developers don't have to invoke setSBMLNamespacesAndOwn function as follows (commentted line)
  //        in this constuctor because the function is properly invoked in the constructor of the
  //        base class (GraphicalObject).
  //

  //setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));  
}


/*
 * Creates a new SpeciesGlyph with the given LayoutPkgNamespaces 
 * and the id of the associated species set to the empty string.
 */        
SpeciesGlyph::SpeciesGlyph (LayoutPkgNamespaces* layoutns)
  : GraphicalObject(layoutns)
  , mSpecies("")
{
  //
  // (NOTE) Developers don't have to invoke setElementNamespace function as follows (commentted line)
  //        in this constuctor because the function is properly invoked in the constructor of the
  //        base class (LineSegment).
  //

  // setElementNamespace(layoutns->getURI());

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}


/*
 * Creates a new SpeciesGlyph with the given @p id.
 */ 
SpeciesGlyph::SpeciesGlyph (LayoutPkgNamespaces* layoutns, const std::string& sid)
 : GraphicalObject(layoutns, sid )
  ,mSpecies("")
{
  //
  // (NOTE) Developers don't have to invoke setElementNamespace function as follows (commentted line)
  //        in this constuctor because the function is properly invoked in the constructor of the
  //        base class (LineSegment).
  //

  // setElementNamespace(layoutns->getURI());

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}

/*
 * Creates a new SpeciesGlyph with the given @p id and the id of the
 * associated species object set to the second argument.
 */ 
SpeciesGlyph::SpeciesGlyph (LayoutPkgNamespaces* layoutns, const std::string& sid,
                            const std::string& speciesId) 
 : GraphicalObject( layoutns, sid )
  ,mSpecies        ( speciesId )
{
  //
  // (NOTE) Developers don't have to invoke setElementNamespace function as follows (commentted line)
  //        in this constuctor because the function is properly invoked in the constructor of the
  //        base class (LineSegment).
  //

  // setElementNamespace(layoutns->getURI());

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}

/*
 * Creates a new SpeciesGlyph from the given XMLNode
 */
SpeciesGlyph::SpeciesGlyph(const XMLNode& node, unsigned int l2version)
 : GraphicalObject(node, l2version)
  ,mSpecies("")
{
    const XMLAttributes& attributes=node.getAttributes();
    ExpectedAttributes ea;
    addExpectedAttributes(ea);
    this->readAttributes(attributes,ea);
}

/*
 * Copy constructor.
 */
SpeciesGlyph::SpeciesGlyph(const SpeciesGlyph& source):GraphicalObject(source)
{
    this->mSpecies=source.getSpeciesId();
}

/*
 * Assignment operator.
 */
SpeciesGlyph& SpeciesGlyph::operator=(const SpeciesGlyph& source)
{
  if(&source!=this)
  {
    GraphicalObject::operator=(source);
    this->mSpecies=source.getSpeciesId();    
  }
  
  return *this;
}


/*
 * Destructor.
 */ 
SpeciesGlyph::~SpeciesGlyph ()
{
} 


/*
 * Returns the id of the associated species object.
 */ 
const std::string&
SpeciesGlyph::getSpeciesId () const
{
  return this->mSpecies;
}


/*
 * Sets the id of the associated species object.
 */ 
void
SpeciesGlyph::setSpeciesId (const std::string& id)
{
  this->mSpecies=id;
} 


/*
 * Returns true if the id of the associated species object is not the empty
 * string.
 */ 
bool
SpeciesGlyph::isSetSpeciesId () const
{
  return ! this->mSpecies.empty();
}


/*
 * Calls initDefaults from GraphicalObject.
 */ 
void SpeciesGlyph::initDefaults ()
{
  GraphicalObject::initDefaults();
}

/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string& SpeciesGlyph::getElementName () const 
{
  static const std::string name = "speciesGlyph";
  return name;
}

/*
 * @return a (deep) copy of this SpeciesGlyph.
 */
SpeciesGlyph* 
SpeciesGlyph::clone () const
{
    return new SpeciesGlyph(*this);
}


/** @cond doxygenLibsbmlInternal */
SBase*
SpeciesGlyph::createObject (XMLInputStream& stream)
{
  SBase*        object = 0;

  object=GraphicalObject::createObject(stream);
  
  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
SpeciesGlyph::addExpectedAttributes(ExpectedAttributes& attributes)
{
  GraphicalObject::addExpectedAttributes(attributes);

  attributes.add("species");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void SpeciesGlyph::readAttributes (const XMLAttributes& attributes,
                                   const ExpectedAttributes& expectedAttributes)
{
	const unsigned int sbmlLevel   = getLevel  ();
	const unsigned int sbmlVersion = getVersion();

	unsigned int numErrs;

	/* look to see whether an unknown attribute error was logged
	 * during the read of the listOfSpeciesGlyphs - which will have
	 * happened immediately prior to this read
	*/

  bool loSubGlyphs = false;
  if (getParentSBMLObject() != NULL
    && getParentSBMLObject()->getElementName() == "listOfSubGlyphs")
  {
    loSubGlyphs = true;
  }

	if (getErrorLog() != NULL &&
	    static_cast<ListOfSpeciesGlyphs*>(getParentSBMLObject())->size() < 2)
	{
		numErrs = getErrorLog()->getNumErrors();
		for (int n = numErrs-1; n >= 0; n--)
		{
			if (getErrorLog()->getError(n)->getErrorId() == UnknownPackageAttribute)
			{
				const std::string details =
				      getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownPackageAttribute);
        if (loSubGlyphs == true)
        {
				  getErrorLog()->logPackageError("layout", 
                                    LayoutLOSubGlyphAllowedAttribs,
				            getPackageVersion(), sbmlLevel, sbmlVersion, details);
        }
        else
        {
				  getErrorLog()->logPackageError("layout", 
                                    LayoutLOSpeciesGlyphAllowedAttributes,
				            getPackageVersion(), sbmlLevel, sbmlVersion, details);
        }
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				           getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
        if (loSubGlyphs == true)
        {
				  getErrorLog()->logPackageError("layout", 
                                    LayoutLOSubGlyphAllowedAttribs,
				            getPackageVersion(), sbmlLevel, sbmlVersion, details);
        }
        else
        {
				  getErrorLog()->logPackageError("layout", 
                                    LayoutLOSpeciesGlyphAllowedAttributes,
				            getPackageVersion(), sbmlLevel, sbmlVersion, details);
        }
			}
		}
	}

	GraphicalObject::readAttributes(attributes, expectedAttributes);

	// look to see whether an unknown attribute error was logged
	if (getErrorLog() != NULL)
	{
		numErrs = getErrorLog()->getNumErrors();
		for (int n = numErrs-1; n >= 0; n--)
		{
			if (getErrorLog()->getError(n)->getErrorId() == UnknownPackageAttribute)
			{
				const std::string details =
				                  getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownPackageAttribute);
				getErrorLog()->logPackageError("layout", LayoutSGAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				                  getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
				getErrorLog()->logPackageError("layout", LayoutSGAllowedCoreAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
		}
	}

	bool assigned = false;

	//
	// species SIdRef   ( use = "optional" )
	//
	assigned = attributes.readInto("species", mSpecies);

	if (assigned == true && getErrorLog() != NULL)
	{
		// check string is not empty and correct syntax

		if (mSpecies.empty() == true)
		{
			logEmptyString(mSpecies, getLevel(), getVersion(), "<SpeciesGlyph>");
		}
		else if (SyntaxChecker::isValidSBMLSId(mSpecies) == false)
		{
			getErrorLog()->logPackageError("layout", LayoutSGSpeciesSyntax,
				             getPackageVersion(), sbmlLevel, sbmlVersion);
		}
	}

}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void SpeciesGlyph::writeElements (XMLOutputStream& stream) const
{
  GraphicalObject::writeElements(stream);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void SpeciesGlyph::writeAttributes (XMLOutputStream& stream) const
{
  GraphicalObject::writeAttributes(stream);
  if(this->isSetSpeciesId())
  {
    stream.writeAttribute("species", getPrefix(), mSpecies);
  }

  //
  // (EXTENSION) will be written by GraphicalObject!
  //
  //SBase::writeExtensionAttributes(stream);

}
/** @endcond */


/*
 * Returns the package type code for this object.
 */
int
SpeciesGlyph::getTypeCode () const
{
  return SBML_LAYOUT_SPECIESGLYPH;
}

/*
 * Creates an XMLNode object from this.
 */
XMLNode SpeciesGlyph::toXML() const
{
 return getXmlNodeForSBase(this);
}





#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
SpeciesGlyph_t *
SpeciesGlyph_create (void)
{
  return new(std::nothrow) SpeciesGlyph;
}


LIBSBML_EXTERN
SpeciesGlyph_t *
SpeciesGlyph_createFrom (const SpeciesGlyph_t *temp)
{
  return new(std::nothrow) SpeciesGlyph(*temp);
}


LIBSBML_EXTERN
SpeciesGlyph_t *
SpeciesGlyph_createWith (const char *id)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) SpeciesGlyph(&layoutns, id ? id : "", "");
}


LIBSBML_EXTERN
SpeciesGlyph_t *
SpeciesGlyph_createWithSpeciesId (const char *sid, const char *speciesId)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) SpeciesGlyph(&layoutns, sid ? sid : "", speciesId ? speciesId : "");
}


LIBSBML_EXTERN
void
SpeciesGlyph_free (SpeciesGlyph_t *sg)
{
  delete sg;
}


LIBSBML_EXTERN
void
SpeciesGlyph_setSpeciesId (SpeciesGlyph_t *sg, const char *id)
{ 
  if (sg==NULL) return;
  static_cast<SpeciesGlyph*>(sg)->setSpeciesId( id ? id : "" );
}


LIBSBML_EXTERN
const char *
SpeciesGlyph_getSpeciesId (const SpeciesGlyph_t *sg)
{ 
  if (sg==NULL) return NULL;
  return sg->isSetSpeciesId() ? sg->getSpeciesId().c_str() : NULL ;
}


LIBSBML_EXTERN
int
SpeciesGlyph_isSetSpeciesId (const SpeciesGlyph_t *sg)
{ 
  if (sg==NULL) return (int)(false);
  return static_cast<int>( sg->isSetSpeciesId() );
}


LIBSBML_EXTERN
void
SpeciesGlyph_initDefaults (SpeciesGlyph_t *sg)
{ 
  if (sg==NULL) return;
  sg->initDefaults();
}


LIBSBML_EXTERN
SpeciesGlyph_t *
SpeciesGlyph_clone (const SpeciesGlyph_t *sg)
{ 
  if (sg==NULL) return NULL;
  return static_cast<SpeciesGlyph*>( sg->clone() );
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END

