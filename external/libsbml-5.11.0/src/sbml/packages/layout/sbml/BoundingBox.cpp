/**
 * @file    BoundingBox.cpp
 * @brief   Implementation of BoundingBox for SBML Layout.
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

#include <sbml/packages/layout/sbml/BoundingBox.h>
#include <sbml/packages/layout/util/LayoutUtilities.h>

#include <sbml/SBMLVisitor.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/util/ElementFilter.h>

#include <sbml/packages/layout/extension/LayoutExtension.h>
#include <sbml/packages/layout/validator/LayoutSBMLError.h>

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus


List*
BoundingBox::getAllElements(ElementFilter *filter)
{
  List* ret = new List();
  List* sublist = NULL;

  ADD_FILTERED_ELEMENT(ret, sublist, mPosition, filter);  
  ADD_FILTERED_ELEMENT(ret, sublist, mDimensions, filter);  

  ADD_FILTERED_FROM_PLUGIN(ret, sublist, filter);

  return ret;
}

/*
 * Default Constructor set position and dimensions to (0.0,0.0,0.0) and the
 * id to an empty string.
 */ 
BoundingBox::BoundingBox(unsigned int level, unsigned int version, unsigned int pkgVersion) 
 : SBase(level,version)
  ,mPosition(level,version,pkgVersion)
  ,mDimensions(level,version,pkgVersion)
  ,mPositionExplicitlySet (false)
  ,mDimensionsExplicitlySet (false)
{
  mPosition.setElementName("position");
  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));  
  connectToChild();
}


BoundingBox::BoundingBox(LayoutPkgNamespaces* layoutns)
 : SBase(layoutns)
  ,mPosition(layoutns)
  ,mDimensions(layoutns)
  ,mPositionExplicitlySet (false)
  ,mDimensionsExplicitlySet (false)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  mPosition.setElementName("position");

  connectToChild();

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}


/*
 * Copy constructor.
 */
BoundingBox::BoundingBox(const BoundingBox& orig):SBase(orig)
{
  this->mId = orig.mId;
  this->mPosition=orig.mPosition;
  this->mDimensions=orig.mDimensions;
  this->mPositionExplicitlySet = orig.mPositionExplicitlySet;
  this->mDimensionsExplicitlySet = orig.mDimensionsExplicitlySet;

  connectToChild();
}


/*
 * Assignment operator
 */
BoundingBox& BoundingBox::operator=(const BoundingBox& orig)
{
  if(&orig!=this)
  {
    this->SBase::operator=(orig);
  
    this->mId = orig.mId;
    this->mPosition=orig.mPosition;
    this->mDimensions=orig.mDimensions;
    this->mPositionExplicitlySet = orig.mPositionExplicitlySet;
    this->mDimensionsExplicitlySet = orig.mDimensionsExplicitlySet;

    connectToChild();
  }

  return *this;
}


/*
 * Constructor set position and dimensions to (0.0,0.0,0.0) and the id to a
 * copy of the given string.
 */ 
BoundingBox::BoundingBox (LayoutPkgNamespaces* layoutns, const std::string id)
 : 
  SBase(layoutns)
 ,mId (id)
 ,mPosition(layoutns)
 ,mDimensions(layoutns)
  ,mPositionExplicitlySet (false)
  ,mDimensionsExplicitlySet (false)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  mPosition.setElementName("position");

  connectToChild();
  loadPlugins(layoutns);
}


/*
 * Constructor which sets the id, the coordinates and the dimensions to the
 * given 2D values.
 */ 
BoundingBox::BoundingBox (LayoutPkgNamespaces* layoutns, const std::string id,
                          double x, double y, double width, double height)
  : SBase     (layoutns)
  , mId (id)
  , mPosition  (layoutns, x, y, 0.0)
  , mDimensions(layoutns, width, height, 0.0)
  ,mPositionExplicitlySet (true)
  ,mDimensionsExplicitlySet (true)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  mPosition.setElementName("position");

  connectToChild();
  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}


/*
 * Constructor which sets the id, the coordinates and the dimensions to the
 * given 3D values.
 */ 
BoundingBox::BoundingBox (LayoutPkgNamespaces* layoutns, const std::string id,
                          double x, double y, double z,
                          double width, double height, double depth)
  : SBase     (layoutns)
  , mId (id)
  , mPosition  (layoutns, x, y, z)
  , mDimensions(layoutns, width, height, depth)
  ,mPositionExplicitlySet (true)
  ,mDimensionsExplicitlySet (true)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  mPosition.setElementName("position");

  connectToChild();
  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}

        
/*
 * Constructor which sets the id, the coordinates and the dimensions to the
 * given 3D values.
 */ 
BoundingBox::BoundingBox (LayoutPkgNamespaces* layoutns, const std::string id,
                          const Point*      p,
                          const Dimensions* d)
  : SBase     (layoutns)
  , mId (id)
  , mPosition(layoutns)
  , mDimensions(layoutns)
  ,mPositionExplicitlySet (true)
  ,mDimensionsExplicitlySet (true)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  if(p)
  {
      this->mPosition=*p;   
  }

  mPosition.setElementName("position");


  if(d)
  {
      this->mDimensions=*d;   
  }

  connectToChild();
  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}

/*
 * Creates a new BoundingBox from the given XMLNode
 */
BoundingBox::BoundingBox(const XMLNode& node, unsigned int l2version)
 :  SBase(2,l2version)
  , mId("")
  , mPosition(2,l2version)
  , mDimensions(2,l2version)
  ,mPositionExplicitlySet (false)
  ,mDimensionsExplicitlySet (false)
{
    mPosition.setElementName("position");

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
        if(childName=="position")
        {
            this->mPosition=Point(*child);
            this->mPositionExplicitlySet = true;
        }
        else if(childName=="dimensions")
        {
            this->mDimensions=Dimensions(*child);
            this->mDimensionsExplicitlySet = true;
        }
        else if(childName=="annotation")
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
  connectToChild();
}


/*
 * Destructor which does nothing.
 */ 
BoundingBox::~BoundingBox ()
{
}


/*
 * Does nothing since no defaults are defined for a BundingBox.
 */ 
void BoundingBox::initDefaults ()
{
}


/*
  * Returns the value of the "id" attribute of this BoundingBox.
  */
const std::string& BoundingBox::getId () const
{
  return mId;
}


/*
  * Predicate returning @c true or @c false depending on whether this
  * BoundingBox's "id" attribute has been set.
  */
bool BoundingBox::isSetId () const
{
  return (mId.empty() == false);
}

/*
  * Sets the value of the "id" attribute of this BoundingBox.
  */
int BoundingBox::setId (const std::string& id)
{
  return SyntaxChecker::checkAndSetSId(id,mId);
}


/*
  * Unsets the value of the "id" attribute of this BoundingBox.
  */
int BoundingBox::unsetId ()
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
 * Returns the position of the BoundingBox as const referece to a Point
 * object.
 */ 
const Point*
BoundingBox::getPosition () const
{
  return &this->mPosition;
}


/*
 * Returns the dimensions of the BoundingBox as const referece to a
 * Dimensions object.
 */ 
const Dimensions*
BoundingBox::getDimensions () const
{
  return &this->mDimensions;
}


/*
 * Returns the position of the BoundingBox as referece to a Point object.
 */ 
Point*
BoundingBox::getPosition ()
{
  return &this->mPosition;
}


/*
 * Returns the dimensions of the BoundingBox as referece to a Dimensions
 * object.
 */ 
Dimensions*
BoundingBox::getDimensions ()
{
  return &this->mDimensions;
}


/*
 * Sets the position to a copy of the Point object given.
 */ 
void BoundingBox::setPosition (const Point* p)
{
    if(!p) return;  
    this->mPosition = Point(*p);
	this->mPosition.setElementName("position");
    this->mPosition.connectToParent(this);
    this->mPositionExplicitlySet = true;
}


/*
 * Sets the dimensions to a copy of the Dimensions object given.
 */ 
void
BoundingBox::setDimensions (const Dimensions* d)
{
  if(!d) return;
  this->mDimensions = Dimensions(*d);
  this->mDimensions.connectToParent(this);
  this->mDimensionsExplicitlySet = true;
}

bool
BoundingBox::getPositionExplicitlySet() const
{
  return mPositionExplicitlySet;
}

bool
BoundingBox::getDimensionsExplicitlySet() const
{
  return mDimensionsExplicitlySet;
}


/*
 * Sets the x offset of the BoundingBox.
 */
void
BoundingBox::setX(double x)
{
  this->mPosition.setX(x);
}


/*
 * Sets the y offset of the BoundingBox.
 */
void
BoundingBox::setY(double y)
{
  this->mPosition.setY(y);
}


/*
 * Sets the z offset of the BoundingBox.
 */
void
BoundingBox::setZ(double z)
{
  this->mPosition.setZ(z);
}


/*
 * Sets the width of the BoundingBox.
 */
void
BoundingBox::setWidth(double width)
{
  this->mDimensions.setWidth(width);
}


/*
 * Sets the height of the BoundingBox.
 */
void
BoundingBox::setHeight(double height)
{
  this->mDimensions.setHeight(height);
}


/*
 * Sets the depth of the BoundingBox.
 */
void
BoundingBox::setDepth(double depth)
{
  this->mDimensions.setDepth(depth);
}

/*
 * Returns the x offset of the bounding box.
 */
double
BoundingBox::x() const
{
  return this->mPosition.x();
}

/*
 * Returns the y offset of the bounding box.
 */
double
BoundingBox::y() const
{
  return this->mPosition.y();
}

/*
 * Returns the z offset of the bounding box.
 */
double
BoundingBox::z() const
{
  return this->mPosition.z();
}

/*
 * Returns the width of the bounding box.
 */
double
BoundingBox::width() const
{
  return this->mDimensions.width();
}

/*
 * Returns the height of the bounding box.
 */
double
BoundingBox::height() const
{
  return this->mDimensions.height();
}

/*
 * Returns the depth of the bounding box.
 */
double
BoundingBox::depth() const
{
  return this->mDimensions.depth();
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
void BoundingBox::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);
  this->mPosition.write(stream);
  this->mDimensions.write(stream);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */

/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string& BoundingBox::getElementName () const 
{
  static const std::string name = "boundingBox";
  return name;
}

/*
 * @return a (deep) copy of this BoundingBox.
 */
BoundingBox* 
BoundingBox::clone () const
{
    return new BoundingBox(*this);
}


/** @cond doxygenLibsbmlInternal */
SBase*
BoundingBox::createObject (XMLInputStream& stream)
{
  const std::string& name   = stream.peek().getName();
  SBase*        object = 0;

  if (name == "dimensions")
  {
    if (getDimensionsExplicitlySet() == true)
    {
      getErrorLog()->logPackageError("layout", LayoutBBoxAllowedElements, 
          getPackageVersion(), getLevel(), getVersion());
    }
    object = &mDimensions;
    mDimensionsExplicitlySet = true;
  }

  else if ( name == "position"    )
  {
    if (getPositionExplicitlySet() == true)
    {
      getErrorLog()->logPackageError("layout", LayoutBBoxAllowedElements, 
          getPackageVersion(), getLevel(), getVersion());
    }
      object = &mPosition;
      mPositionExplicitlySet = true;
  }

  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
BoundingBox::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  attributes.add("id");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void BoundingBox::readAttributes (const XMLAttributes& attributes,
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
				getErrorLog()->logPackageError("layout", LayoutBBoxAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				                  getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
				getErrorLog()->logPackageError("layout", 
                       LayoutBBoxAllowedCoreAttributes,
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
			logEmptyString(mId, getLevel(), getVersion(), "<BoundingBox>");
		}
		else if (SyntaxChecker::isValidSBMLSId(mId) == false)
		{
      getErrorLog()->logPackageError("layout", LayoutSIdSyntax, 
        getPackageVersion(), sbmlLevel, sbmlVersion);
		}
	}
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void BoundingBox::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);
  stream.writeAttribute("id", getPrefix(), mId);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */


/*
 * Returns the package type code  for this object.
 */
int
BoundingBox::getTypeCode () const
{
  return SBML_LAYOUT_BOUNDINGBOX;
}


/*
 * Accepts the given SBMLVisitor.
 */
bool
BoundingBox::accept (SBMLVisitor& v) const
{
  v.visit(*this);

  mPosition.accept(v);
  mDimensions.accept(v);
  
  v.leave(*this);
  
  return true;
}

/*
 * Creates an XMLNode object from this.
 */
XMLNode BoundingBox::toXML() const
{
  return getXmlNodeForSBase(this);
}


/** @cond doxygenLibsbmlInternal */
/*
 * Sets the parent SBMLDocument of this SBML object.
 */
void
BoundingBox::setSBMLDocument (SBMLDocument* d)
{
  SBase::setSBMLDocument(d);

  mPosition.setSBMLDocument(d);
  mDimensions.setSBMLDocument(d);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Sets this SBML object to child SBML objects (if any).
 * (Creates a child-parent relationship by the parent)
  */
void
BoundingBox::connectToChild()
{
  SBase::connectToChild();
  mPosition.connectToParent(this);
  mDimensions.connectToParent(this);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Enables/Disables the given package with this element and child
 * elements (if any).
 * (This is an internal implementation for enablePakcage function)
 */
void
BoundingBox::enablePackageInternal(const std::string& pkgURI,
                                   const std::string& pkgPrefix, bool flag)
{
  SBase::enablePackageInternal(pkgURI,pkgPrefix,flag);

  mPosition.enablePackageInternal(pkgURI,pkgPrefix,flag);
  mDimensions.enablePackageInternal(pkgURI,pkgPrefix,flag);
}
/** @endcond */


#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
BoundingBox_t *
BoundingBox_create (void)
{
  return new(std::nothrow) BoundingBox;
}


LIBSBML_EXTERN
BoundingBox_t *
BoundingBox_createWith (const char *id)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) BoundingBox(&layoutns, id ? id : "");
}


LIBSBML_EXTERN
BoundingBox_t *
BoundingBox_createWithCoordinates (const char *id,
                                   double x, double y, double z,
                                   double width, double height, double depth)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) BoundingBox(&layoutns, id ? id : "" , x, y, z, width, height, depth);
}


LIBSBML_EXTERN
void
BoundingBox_free (BoundingBox_t *bb)
{
  delete bb;
}


LIBSBML_EXTERN
void
BoundingBox_initDefaults (BoundingBox_t *bb)
{
  if (bb == NULL) return;
  bb->initDefaults();
}


LIBSBML_EXTERN
Point_t *
BoundingBox_getPosition (BoundingBox_t *bb)
{
  if (bb == NULL) return NULL;
  return bb->getPosition();
}


LIBSBML_EXTERN
Dimensions_t *
BoundingBox_getDimensions (BoundingBox_t *bb)
{
  if (bb == NULL) return NULL;
  return bb->getDimensions();
}


LIBSBML_EXTERN
void
BoundingBox_setPosition (BoundingBox_t *bb, const Point_t *p)
{
  if (bb == NULL) return;
  bb->setPosition(p);
}


LIBSBML_EXTERN
void
BoundingBox_setDimensions (BoundingBox_t *bb, const Dimensions_t *d)
{
  if (bb == NULL) return;
  bb->setDimensions(d);
}

LIBSBML_EXTERN
void
BoundingBox_setX(BoundingBox_t* bb,double x)
{
  if (bb == NULL) return;
  bb->setX(x);
}

LIBSBML_EXTERN
void
BoundingBox_setY(BoundingBox_t* bb,double y)
{
  if (bb == NULL) return;
  bb->setY(y);
}


LIBSBML_EXTERN
void
BoundingBox_setZ(BoundingBox_t* bb,double z)
{
  if (bb == NULL) return;
  bb->setZ(z);
}


LIBSBML_EXTERN
void
BoundingBox_setWidth(BoundingBox_t* bb,double width)
{
  if (bb == NULL) return;
  bb->setWidth(width);
}


LIBSBML_EXTERN
void
BoundingBox_setHeight(BoundingBox_t* bb,double height)
{
  if (bb == NULL) return;
  bb->setHeight(height);
}


LIBSBML_EXTERN
void
BoundingBox_setDepth(BoundingBox_t* bb,double depth)
{
  if (bb == NULL) return;
  bb->setDepth(depth);
}

LIBSBML_EXTERN
double
BoundingBox_x(BoundingBox_t* bb)
{
  if (bb == NULL) return std::numeric_limits<double>::quiet_NaN();
  return bb->x();
}

LIBSBML_EXTERN
double
BoundingBox_y(BoundingBox_t* bb)
{
  if (bb == NULL) return std::numeric_limits<double>::quiet_NaN();
  return bb->y();
}

LIBSBML_EXTERN
double
BoundingBox_z(BoundingBox_t* bb)
{
  if (bb == NULL) return std::numeric_limits<double>::quiet_NaN();
  return bb->z();
}

LIBSBML_EXTERN
double
BoundingBox_width(BoundingBox_t* bb)
{
  if (bb == NULL) return std::numeric_limits<double>::quiet_NaN();
  return bb->width();
}

LIBSBML_EXTERN
double
BoundingBox_height(BoundingBox_t* bb)
{
  if (bb == NULL) return std::numeric_limits<double>::quiet_NaN();
  return bb->height();
}

LIBSBML_EXTERN
double
BoundingBox_depth(BoundingBox_t* bb)
{
  if (bb == NULL) return std::numeric_limits<double>::quiet_NaN();
  return bb->depth();
}

LIBSBML_EXTERN
BoundingBox_t *
BoundingBox_clone (const BoundingBox_t *m)
{
  if (m == NULL) return NULL;
  return static_cast<BoundingBox*>( m->clone() );
}

LIBSBML_EXTERN
int
BoundingBox_isSetId (const BoundingBox_t *bb)
{
  if (bb == NULL) return (int)false;
  return static_cast <int> (bb->isSetId());
}

LIBSBML_EXTERN
const char *
BoundingBox_getId (const BoundingBox_t *bb)
{
  if (bb == NULL) return NULL;
  return bb->isSetId() ? bb->getId().c_str() : NULL;
}

LIBSBML_EXTERN
int
BoundingBox_setId (BoundingBox_t *bb, const char *sid)
{
  if (bb == NULL) return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  return (sid == NULL) ? bb->setId("") : bb->setId(sid);
}

LIBSBML_EXTERN
void
BoundingBox_unsetId (BoundingBox_t *bb)
{
  if (bb == NULL) return;
  bb->unsetId();
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END



