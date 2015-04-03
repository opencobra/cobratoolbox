/**
 * @file    Point.cpp
 * @brief   Implementation of Point for SBML Layout.
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

#include <sbml/packages/layout/sbml/Point.h>
#include <sbml/packages/layout/util/LayoutUtilities.h>
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
 * Creates a new point with x,y and z set  to 0.0.
 */ 
Point::Point(unsigned int level, unsigned int version, unsigned int pkgVersion) 
 :  SBase(level,version)
  , mXOffset(0.0)
  , mYOffset(0.0)
  , mZOffset(0.0)
  , mZOffsetExplicitlySet (false)
  , mElementName("point")
{
  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));  
}



/*
 * Constructor
 */ 
Point::Point(LayoutPkgNamespaces* layoutns)
 : SBase(layoutns)
  , mXOffset(0.0)
  , mYOffset(0.0)
  , mZOffset(0.0)
  , mZOffsetExplicitlySet (false)
  , mElementName("point")
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
 * Copy constructor.
 */
Point::Point(const Point& orig):SBase(orig)
{
    this->mXOffset=orig.mXOffset;
    this->mYOffset=orig.mYOffset;
    this->mZOffset=orig.mZOffset;
    this->mZOffsetExplicitlySet=orig.mZOffsetExplicitlySet;
    this->mElementName=orig.mElementName;
}

Point& Point::operator=(const Point& orig)
{
  if(&orig!=this)
  {
    SBase::operator=(orig);
    this->mId=orig.mId;
    this->mXOffset=orig.mXOffset;
    this->mYOffset=orig.mYOffset;
    this->mZOffset=orig.mZOffset;
    this->mZOffsetExplicitlySet=orig.mZOffsetExplicitlySet;
    this->mElementName=orig.mElementName;
  }
  
  return *this;
}


/*
 * Creates a new point with the given ccordinates.
 */ 
Point::Point(LayoutPkgNamespaces* layoutns, double x, double y, double z)
  : SBase  (layoutns)
  , mXOffset(x)
  , mYOffset(y)
  , mZOffset(z)
  , mZOffsetExplicitlySet (true)
  , mElementName("point")  
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
 * Sets the Z offset to 0.0.
 */
void Point::initDefaults ()
{
  this->setZOffset(0.0);
}

/*
 * Creates a new Point from the given XMLNode
 */
Point::Point(const XMLNode& node, unsigned int l2version) 
 : SBase(2,l2version)
  , mXOffset(0.0)
  , mYOffset(0.0)
  , mZOffset(0.0)
  , mZOffsetExplicitlySet (false)
  , mElementName(node.getName())
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
            this->mAnnotation=new XMLNode(node);
        }
        else if(childName=="notes")
        {
            this->mNotes=new XMLNode(node);
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
 * Destructor.
 */ 
Point::~Point()
{
}


/*
  * Returns the value of the "id" attribute of this Point.
  */
const std::string& Point::getId () const
{
  return mId;
}


/*
  * Predicate returning @c true or @c false depending on whether this
  * Point's "id" attribute has been set.
  */
bool Point::isSetId () const
{
  return (mId.empty() == false);
}

/*
  * Sets the value of the "id" attribute of this Point.
  */
int Point::setId (const std::string& id)
{
  return SyntaxChecker::checkAndSetSId(id,mId);
}


/*
  * Unsets the value of the "id" attribute of this Point.
  */
int Point::unsetId ()
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
 * Sets the coordinates to the given values.
 */ 
void
Point::setOffsets (double x, double y, double z)
{
  this->setXOffset(x);
  this->setYOffset(y);
  this->setZOffset(z);
}


/*
 * Sets the x offset.
 */ 
void
Point::setXOffset (double x)
{
  this->setX(x);
}


/*
 * Sets the y offset.
 */ 
void
Point::setYOffset (double y)
{
  this->setY(y);
}


/*
 * Sets the z offset.
 */ 
void
Point::setZOffset (double z)
{
  this->setZ(z);
}


/*
 * Sets the x offset.
 */ 
void
Point::setX (double x)
{
  this->mXOffset = x;
}


/*
 * Sets the y offset.
 */ 
void
Point::setY (double y)
{
  this->mYOffset = y;
}


/*
 * Sets the z offset.
 */ 
void
Point::setZ (double z)
{
  this->mZOffset = z;
  this->mZOffsetExplicitlySet = true;
}


/*
 * Returns the x offset.
 */ 
double
Point::getXOffset () const
{
  return this->x();
}


/*
 * Returns the y offset.
 */ 
double
Point::getYOffset () const
{
  return this->y();
}


/*
 * Returns the z offset.
 */ 
double
Point::getZOffset () const
{
  return this->z();
}

/*
 * Returns the x offset.
 */ 
double
Point::x () const
{
  return this->mXOffset;
}


/*
 * Returns the y offset.
 */ 
double
Point::y () const
{
  return this->mYOffset;
}


/*
 * Returns the z offset.
 */ 
double
Point::z () const
{
  return this->mZOffset;
}


bool
Point::getZOffsetExplicitlySet() const
{
  return mZOffsetExplicitlySet;
}

/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write out their contained
 * SBML objects as XML elements.  Be sure to call your parents
 * implementation of this method as well.  For example:
 *
 *   SBase::writeElements(stream);
 *   mReactants.write(stream);
 *   mProducts.write(stream);
 *   ...
 */
void Point::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */

/*
 * Sets the element name to be returned by getElementName.
 */
void Point::setElementName(const std::string& name)
{
    this->mElementName=name;
}
 
/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string& Point::getElementName () const 
{
  return this->mElementName;
}

/*
 * @return a (deep) copy of this Point.
 */
Point* 
Point::clone () const
{
    return new Point(*this);
}


/** @cond doxygenLibsbmlInternal */
SBase*
Point::createObject (XMLInputStream& stream)
{
  SBase*        object = 0;

  object=SBase::createObject(stream);
  
  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
Point::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  attributes.add("id");
  attributes.add("x");
  attributes.add("y");
  attributes.add("z");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void Point::readAttributes (const XMLAttributes& attributes,
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
				getErrorLog()->logPackageError("layout", LayoutPointAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				                  getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
				getErrorLog()->logPackageError("layout", 
                       LayoutPointAllowedCoreAttributes,
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
			logEmptyString(mId, getLevel(), getVersion(), "<Point>");
		}
		else if (SyntaxChecker::isValidSBMLSId(mId) == false)
		{
      getErrorLog()->logPackageError("layout", LayoutSIdSyntax, 
        getPackageVersion(), sbmlLevel, sbmlVersion);
		}
	}

	//
	// x double   ( use = "required" )
	//
  numErrs = getErrorLog() != NULL ? getErrorLog()->getNumErrors() : 0;
	assigned = attributes.readInto("x", mXOffset);

	if (assigned == false)
	{
		if (getErrorLog() != NULL)
		{
			if (getErrorLog()->getNumErrors() == numErrs + 1 &&
			        getErrorLog()->contains(XMLAttributeTypeMismatch))
			{
				getErrorLog()->remove(XMLAttributeTypeMismatch);
				getErrorLog()->logPackageError("layout", 
                     LayoutPointAttributesMustBeDouble,
				             getPackageVersion(), sbmlLevel, sbmlVersion);
			}
			else
			{
				std::string message = "Layout attribute 'x' is missing.";
				getErrorLog()->logPackageError("layout", LayoutPointAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, message);
			}
		}
	}

	//
	// y double   ( use = "required" )
	//
  numErrs = getErrorLog() != NULL ? getErrorLog()->getNumErrors() : 0;
	assigned = attributes.readInto("y", mYOffset);

	if (assigned == false)
	{
		if (getErrorLog() != NULL)
		{
			if (getErrorLog()->getNumErrors() == numErrs + 1 &&
			        getErrorLog()->contains(XMLAttributeTypeMismatch))
			{
				getErrorLog()->remove(XMLAttributeTypeMismatch);
				getErrorLog()->logPackageError("layout", 
                     LayoutPointAttributesMustBeDouble,
				             getPackageVersion(), sbmlLevel, sbmlVersion);
			}
			else
			{
				std::string message = "Layout attribute 'y' is missing.";
				getErrorLog()->logPackageError("layout", LayoutPointAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, message);
			}
		}
	}

	//
	// z double   ( use = "optional" )
	//
  numErrs = getErrorLog() != NULL ? getErrorLog()->getNumErrors() : 0;
	mZOffsetExplicitlySet = attributes.readInto("z", mZOffset);

	if (mZOffsetExplicitlySet == false)
	{
    mZOffset = 0.0;
		if (getErrorLog() != NULL)
		{
			if (getErrorLog()->getNumErrors() == numErrs + 1 &&
			        getErrorLog()->contains(XMLAttributeTypeMismatch))
			{
				getErrorLog()->remove(XMLAttributeTypeMismatch);
				getErrorLog()->logPackageError("layout", 
                     LayoutPointAttributesMustBeDouble,
				             getPackageVersion(), sbmlLevel, sbmlVersion);
			}
		}
	}
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void Point::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);
  if (isSetId())
  {
    stream.writeAttribute("id", getPrefix(), mId);
  }
  stream.writeAttribute("x", getPrefix(), mXOffset);
  stream.writeAttribute("y", getPrefix(), mYOffset);

  //
  // (TODO) default value should be allowd in package of Level 3?
  //
  if(this->mZOffset!=0.0)
  {
    stream.writeAttribute("z", getPrefix(), mZOffset);
  }

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */

XMLNode Point::toXML(const std::string& name) const
{
  return getXmlNodeForSBase(this);
}


/*
 * Returns the package type code for this object.
 */
int
Point::getTypeCode () const
{
  return SBML_LAYOUT_POINT;
}


/*
 * Accepts the given SBMLVisitor.
 *
 * @return the result of calling <code>v.visit()</code>, which indicates
 * whether or not the Visitor would like to visit the SBML object's next
 * sibling object (if available).
 */
bool Point::accept (SBMLVisitor& v) const
{
    return v.visit(*this);
}




#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
Point_t *
Point_create (void)
{
  return new(std::nothrow) Point; 
}


LIBSBML_EXTERN
Point_t *
Point_createWithCoordinates (double x, double y, double z)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) Point(&layoutns, x, y, z);
}


LIBSBML_EXTERN
void
Point_free (Point_t *p)
{
  delete p;
}


LIBSBML_EXTERN
void
Point_initDefaults (Point_t *p)
{
  if (p == NULL) return;
  p->initDefaults();
}


LIBSBML_EXTERN
void
Point_setOffsets (Point_t *p, double x, double y, double z)
{
  if (p == NULL) return;
  p->setOffsets(x, y, z);
}


LIBSBML_EXTERN
void
Point_setXOffset (Point_t *p, double x)
{
  if (p == NULL) return;
  p->setX(x);
}


LIBSBML_EXTERN
void
Point_setYOffset (Point_t *p, double y)
{
  if (p == NULL) return;
  p->setY(y);
}


LIBSBML_EXTERN
void
Point_setZOffset (Point_t *p, double z)
{
  if (p == NULL) return;
  p->setZ(z);
}


LIBSBML_EXTERN
double
Point_getXOffset (const Point_t *p)
{
  if (p == NULL) return numeric_limits<double>::quiet_NaN();
  return p->x();
}


LIBSBML_EXTERN
double
Point_getYOffset (const Point_t *p)
{
  if (p == NULL) return numeric_limits<double>::quiet_NaN();
  return p->y();
}


LIBSBML_EXTERN
double
Point_getZOffset (const Point_t *p)
{
  if (p == NULL) return numeric_limits<double>::quiet_NaN();
  return p->z();
}


LIBSBML_EXTERN
void
Point_setX (Point_t *p, double x)
{
  if (p == NULL) return;
  p->setX(x);
}


LIBSBML_EXTERN
void
Point_setY (Point_t *p, double y)
{
  if (p == NULL) return;
  p->setY(y);
}


LIBSBML_EXTERN
void
Point_setZ (Point_t *p, double z)
{
  if (p == NULL) return;
  p->setZ(z);
}


LIBSBML_EXTERN
double
Point_x (const Point_t *p)
{
  if (p == NULL) return numeric_limits<double>::quiet_NaN();
  return p->x();
}


LIBSBML_EXTERN
double
Point_y (const Point_t *p)
{
  if (p == NULL) return numeric_limits<double>::quiet_NaN();
  return p->y();
}


LIBSBML_EXTERN
double
Point_z (const Point_t *p)
{
  if (p == NULL) return numeric_limits<double>::quiet_NaN();
  return p->z();
}

LIBSBML_EXTERN
Point_t *
Point_clone (const Point_t *m)
{
  if (m == NULL) return NULL;
  return static_cast<Point*>( m->clone() );
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END

