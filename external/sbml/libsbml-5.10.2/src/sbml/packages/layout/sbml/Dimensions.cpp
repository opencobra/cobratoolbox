/**
 * @file    Dimensions.cpp
 * @brief   Implementation of Dimensions for SBML Layout.
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

#include <sstream>

#include <sbml/packages/layout/sbml/Dimensions.h>
#include <sbml/packages/layout/util/LayoutUtilities.h>
#include <sbml/xml/XMLErrorLog.h>
#include <sbml/SBMLErrorLog.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/packages/layout/extension/LayoutExtension.h>
#include <sbml/packages/layout/validator/LayoutSBMLError.h>

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

using namespace std;

/*
 * Creates a new Dimensions object with all sizes set to 0.0.
 */ 
Dimensions::Dimensions (unsigned int level, unsigned int version, unsigned int pkgVersion) 
 :  SBase(level,version)
  , mW(0.0)
  , mH(0.0)
  , mD(0.0)
  , mDExplicitlySet (false)
{
  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));  
}


/*
 * Ctor.
 */
Dimensions::Dimensions(LayoutPkgNamespaces* layoutns)
 : SBase(layoutns)
  , mW(0.0)
  , mH(0.0)
  , mD(0.0)  
  , mDExplicitlySet (false)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}


/*
 * Creates a new Dimensions object with the given sizes.
 */ 
Dimensions::Dimensions (LayoutPkgNamespaces* layoutns, double width, double height, double depth)
  : SBase(layoutns)
  , mW(width)
  , mH(height)
  , mD(depth)
  , mDExplicitlySet (true)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}


Dimensions::Dimensions(const Dimensions& orig)
 :SBase(orig)
{
    this->mH=orig.mH;
    this->mW=orig.mW;
    this->mD=orig.mD;
    this->mDExplicitlySet=orig.mDExplicitlySet;
    // attributes of SBase
//    this->mId=orig.mId;
//    this->mName=orig.mName;
    this->mMetaId=orig.mMetaId;
    if(orig.mNotes) this->mNotes=new XMLNode(*const_cast<Dimensions&>(orig).getNotes());
    if(orig.mAnnotation) this->mAnnotation=new XMLNode(*const_cast<Dimensions&>(orig).mAnnotation);
    this->mSBML=orig.mSBML;
    this->mSBOTerm=orig.mSBOTerm;
    this->mLine=orig.mLine;
    this->mColumn=orig.mColumn;

    if(orig.mCVTerms)
    {
      this->mCVTerms=new List();
      unsigned int i,iMax=orig.mCVTerms->getSize();
      for(i=0;i<iMax;++i)
      {
        this->mCVTerms->add(static_cast<CVTerm*>(orig.mCVTerms->get(i))->clone());
      }
    }
}

Dimensions& Dimensions::operator=(const Dimensions& orig)
{
  if(&orig!=this)
  {
    this->mH=orig.mH;
    this->mW=orig.mW;
    this->mD=orig.mD;
    this->mDExplicitlySet=orig.mDExplicitlySet;
    this->mMetaId=orig.mMetaId;
    delete this->mNotes;
    this->mNotes=NULL;
    if(orig.mNotes) this->mNotes=new XMLNode(*const_cast<Dimensions&>(orig).getNotes());
    delete this->mAnnotation;
    this->mAnnotation=NULL;
    if(orig.mAnnotation) this->mAnnotation=new XMLNode(*const_cast<Dimensions&>(orig).mAnnotation);
    this->mSBML=orig.mSBML;
    this->mSBOTerm=orig.mSBOTerm;
    this->mLine=orig.mLine;
    this->mColumn=orig.mColumn;
    delete this->mCVTerms;
    this->mCVTerms=NULL;
    if(orig.mCVTerms)
    {
      this->mCVTerms=new List();
      unsigned int i,iMax=orig.mCVTerms->getSize();
      for(i=0;i<iMax;++i)
      {
        this->mCVTerms->add(static_cast<CVTerm*>(orig.mCVTerms->get(i))->clone());
      }
    }
  }
  
  return *this;
}

/*
 * Creates a new Dimensions object from the given XMLNode
 */
Dimensions::Dimensions(const XMLNode& node, unsigned int l2version)
 : SBase(2,l2version)
 , mW(0.0)
 , mH(0.0)
 , mD(0.0)
 , mDExplicitlySet (false)
{
    const XMLAttributes& attributes=node.getAttributes();
    const XMLNode* child;
    //ExpectedAttributes ea(getElementName());
    ExpectedAttributes ea;
    addExpectedAttributes(ea);
    this->readAttributes(attributes,ea);
    unsigned int n=0,nMax = node.getNumChildren();
    while(n<nMax)
    {
        child=&node.getChild(n);
        const std::string& childName=child->getName();
        if(childName=="annotation")
        {
            this->mAnnotation=new XMLNode(*child);
        }
        else if(childName=="notes")
        {
            this->mNotes=new XMLNode(*child);
        }
        else
        {
            //throw;
        }
        ++n;
    }    

  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(2,l2version));  
}


/*
 * Frees memory taken up by the Dimensions object.
 */ 
Dimensions::~Dimensions ()
{
}


/*
  * Returns the value of the "id" attribute of this Dimensions.
  */
const std::string& Dimensions::getId () const
{
  return mId;
}


/*
  * Predicate returning @c true or @c false depending on whether this
  * Dimensions's "id" attribute has been set.
  */
bool Dimensions::isSetId () const
{
  return (mId.empty() == false);
}

/*
  * Sets the value of the "id" attribute of this Dimensions.
  */
int Dimensions::setId (const std::string& id)
{
  return SyntaxChecker::checkAndSetSId(id,mId);
}


/*
  * Unsets the value of the "id" attribute of this Dimensions.
  */
int Dimensions::unsetId ()
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
 * Returns the width.
 */
double
Dimensions::width() const
{
  return this->mW;
}


/*
 * Returns the height.
 */
double
Dimensions::height() const
{
  return this->mH;
}


/*
 * Returns the depth.
 */
double
Dimensions::depth () const
{
  return this->mD;
}


/*
 * Returns the width.
 */
double
Dimensions::getWidth() const
{
  return this->width();
}


/*
 * Returns the height.
 */
double
Dimensions::getHeight() const
{
  return this->height();
}


/*
 * Returns the depth.
 */
double
Dimensions::getDepth () const
{
  return this->depth();
}


/*
 * Sets the width to the given value.
 */ 
void
Dimensions::setWidth (double width)
{
  this->mW = width;
}


/*
 * Sets the height to the given value.
 */ 
void
Dimensions::setHeight (double height)
{
  this->mH = height;
}


/*
 * Sets the depth to the given value.
 */ 
void Dimensions::setDepth (double depth)
{
  this->mD = depth;
  this->mDExplicitlySet = true;

}


/*
 * Sets all sizes of the Dimensions object to the given values.
 */ 
void
Dimensions::setBounds (double w, double h, double d)
{
  this->setWidth (w);
  this->setHeight(h);
  this->setDepth (d);
}

bool 
Dimensions::getDExplicitlySet() const
{ 
  return mDExplicitlySet;
}

/*
 * Sets the depth to 0.0
 */ 
void Dimensions::initDefaults ()
{
  this->setDepth(0.0);
}

/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string& Dimensions::getElementName () const 
{
  static const std::string name = "dimensions";
  return name;
}

/*
 * @return a (deep) copy of this Dimensions object.
 */
Dimensions* 
Dimensions::clone () const
{
    return new Dimensions(*this);
}


/** @cond doxygenLibsbmlInternal */
SBase*
Dimensions::createObject (XMLInputStream& stream)
{
  SBase*        object = 0;

  object=SBase::createObject(stream);
  
  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
Dimensions::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  attributes.add("id");
  attributes.add("width");
  attributes.add("height");
  attributes.add("depth");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void Dimensions::readAttributes (const XMLAttributes& attributes,
                                 const ExpectedAttributes& expectedAttributes)
{
	const unsigned int sbmlLevel   = getLevel  ();
	const unsigned int sbmlVersion = getVersion();

	unsigned int numErrs;

	SBase::readAttributes(attributes, expectedAttributes);

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
				getErrorLog()->logPackageError("layout", LayoutDimsAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				                  getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
				getErrorLog()->logPackageError("layout", 
                       LayoutDimsAllowedCoreAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
		}
	}

	bool assigned = false;

	//
	// id SId  ( use = "optional" )
	//
	assigned = attributes.readInto("id", mId);

 	if (assigned == true && getErrorLog() != NULL)
	{
		// check string is not empty and correct syntax

		if (mId.empty() == true)
		{
			logEmptyString(mId, getLevel(), getVersion(), "<Dimensions>");
		}
		else if (SyntaxChecker::isValidSBMLSId(mId) == false)
		{
      getErrorLog()->logPackageError("layout", LayoutSIdSyntax, 
        getPackageVersion(), sbmlLevel, sbmlVersion);
		}
	}

	//
	// width double   ( use = "required" )
	//
  numErrs = getErrorLog() != NULL ? getErrorLog()->getNumErrors() : 0;
	assigned = attributes.readInto("width", mW);

	if (assigned == false)
	{
		if (getErrorLog() != NULL)
		{
			if (getErrorLog()->getNumErrors() == numErrs + 1 &&
			        getErrorLog()->contains(XMLAttributeTypeMismatch))
			{
				getErrorLog()->remove(XMLAttributeTypeMismatch);
				getErrorLog()->logPackageError("layout", 
                     LayoutDimsAttributesMustBeDouble,
				             getPackageVersion(), sbmlLevel, sbmlVersion);
			}
			else
			{
				std::string message = "Layout attribute 'width' is missing.";
				getErrorLog()->logPackageError("layout", LayoutDimsAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, message);
			}
		}
	}

	//
	// height double   ( use = "required" )
	//
  numErrs = getErrorLog() != NULL ? getErrorLog()->getNumErrors() : 0;
	assigned = attributes.readInto("height", mH);

	if (assigned == false)
	{
		if (getErrorLog() != NULL)
		{
			if (getErrorLog()->getNumErrors() == numErrs + 1 &&
			        getErrorLog()->contains(XMLAttributeTypeMismatch))
			{
				getErrorLog()->remove(XMLAttributeTypeMismatch);
				getErrorLog()->logPackageError("layout", 
                     LayoutDimsAttributesMustBeDouble,
				             getPackageVersion(), sbmlLevel, sbmlVersion);
			}
			else
			{
				std::string message = "Layout attribute 'height' is missing.";
				getErrorLog()->logPackageError("layout", LayoutDimsAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, message);
			}
		}
	}

	//
	// depth double   ( use = "optional" )
	//
  numErrs = getErrorLog() != NULL ? getErrorLog()->getNumErrors() : 0;
	mDExplicitlySet = attributes.readInto("depth", mD);

	if (mDExplicitlySet == false)
	{
    mD = 0.0;
		if (getErrorLog() != NULL)
		{
			if (getErrorLog()->getNumErrors() == numErrs + 1 &&
			        getErrorLog()->contains(XMLAttributeTypeMismatch))
			{
				getErrorLog()->remove(XMLAttributeTypeMismatch);
				getErrorLog()->logPackageError("layout", 
                     LayoutDimsAttributesMustBeDouble,
				             getPackageVersion(), sbmlLevel, sbmlVersion);
			}
		}
	}

}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
Dimensions::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void Dimensions::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);
  if (isSetId())
  {
    stream.writeAttribute("id", getPrefix(), mId);
  }
  stream.writeAttribute("width", getPrefix(), mW);
  stream.writeAttribute("height", getPrefix(), mH);

  //
  // (TODO) default value should be allowd in package of Level 3?
  //
  if(this->mD!=0.0)
  {
    stream.writeAttribute("depth", getPrefix(), mD);
  }

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */


/*
 * Returns the package type code for this object.
 */
int
Dimensions::getTypeCode () const
{
  return SBML_LAYOUT_DIMENSIONS;
}


/*
 * Accepts the given SBMLVisitor.
 *
 * @return the result of calling <code>v.visit()</code>, which indicates
 * whether or not the Visitor would like to visit the SBML object's next
 * sibling object (if available).
 */
bool Dimensions::accept (SBMLVisitor& v) const
{
    return v.visit(*this);
}

/*
 * Creates an XMLNode object from this.
 */
XMLNode Dimensions::toXML() const
{
  return getXmlNodeForSBase(this);
}




#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
Dimensions_t *
Dimensions_create (void)
{
  return new(std::nothrow) Dimensions;
}

LIBSBML_EXTERN
Dimensions_t *
Dimensions_createWithSize (double w, double h, double d)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) Dimensions(&layoutns, w, h, d);
}

LIBSBML_EXTERN
void
Dimensions_free (Dimensions_t *d)
{
  delete d;
}

LIBSBML_EXTERN
void
Dimensions_initDefaults (Dimensions_t *d)
{
  if (d == NULL) return;
  d->initDefaults();
}

LIBSBML_EXTERN
void
Dimensions_setBounds (Dimensions_t *dim, double w, double h, double d)
{
  if (dim == NULL) return;
  dim->setBounds(w, h, d);
}

LIBSBML_EXTERN
void
Dimensions_setWidth (Dimensions_t *d, double w)
{
  if (d == NULL) return;
  d->setWidth(w);
}

LIBSBML_EXTERN
void
Dimensions_setHeight (Dimensions_t *d, double h)
{
  if (d == NULL) return;
  d->setHeight(h);
}

LIBSBML_EXTERN
void
Dimensions_setDepth (Dimensions_t *dim, double d)
{
  if (dim == NULL) return;
  dim->setDepth(d);
}

LIBSBML_EXTERN
double
Dimensions_width (const Dimensions_t *d)
{
  if (d == NULL) return numeric_limits<double>::quiet_NaN();
  return d->width();
}

LIBSBML_EXTERN
double
Dimensions_height(const Dimensions_t *d)
{
  if (d == NULL) return numeric_limits<double>::quiet_NaN();
  return d->height();
}

LIBSBML_EXTERN
double
Dimensions_depth (const Dimensions_t *d)
{
  if (d == NULL) return numeric_limits<double>::quiet_NaN();
  return d->depth();
}

LIBSBML_EXTERN
double
Dimensions_getWidth (const Dimensions_t *d)
{
  if (d == NULL) return numeric_limits<double>::quiet_NaN();
  return d->width();
}

LIBSBML_EXTERN
double
Dimensions_getHeight(const Dimensions_t *d)
{
  if (d == NULL) return numeric_limits<double>::quiet_NaN();
  return d->height();
}

LIBSBML_EXTERN
double
Dimensions_getDepth (const Dimensions_t *d)
{
  if (d == NULL) return numeric_limits<double>::quiet_NaN();
  return d->depth();
}

LIBSBML_EXTERN
Dimensions_t *
Dimensions_clone (const Dimensions_t *m)
{
  if (m == NULL) return NULL;
  return static_cast<Dimensions*>( m->clone() );
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END

