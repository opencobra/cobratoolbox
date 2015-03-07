/**
 * @file    LineSegment.cpp
 * @brief   Implementation of LineSegment for SBML Layout.
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

#include <sbml/packages/layout/sbml/LineSegment.h>
#include <sbml/packages/layout/sbml/Curve.h>
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
LineSegment::getAllElements(ElementFilter *filter)
{
  List* ret = new List();
  List* sublist = NULL;

  ADD_FILTERED_ELEMENT(ret, sublist, mStartPoint, filter);  
  ADD_FILTERED_ELEMENT(ret, sublist, mEndPoint, filter);  

  ADD_FILTERED_FROM_PLUGIN(ret, sublist, filter);

  return ret;
}


/*
 * Creates a line segment with the given SBML level, version, and package version
 * and both points set to (0.0,0.0,0.0)
 */ 
LineSegment::LineSegment (unsigned int level, unsigned int version, unsigned int pkgVersion)
 :  SBase (level,version)
  , mStartPoint(level,version,pkgVersion)
  , mEndPoint  (level,version,pkgVersion)
  , mStartExplicitlySet (false)
  , mEndExplicitlySet (false)
{
  this->mStartPoint.setElementName("start");
  this->mEndPoint.setElementName("end");

  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));  
  connectToChild();
}


/*
 * Creates a new line segment with the given LayoutPkgNamespaces
 */ 
LineSegment::LineSegment (LayoutPkgNamespaces* layoutns)
 : SBase (layoutns)
 , mStartPoint(layoutns)
 , mEndPoint (layoutns)
  , mStartExplicitlySet (false)
  , mEndExplicitlySet (false)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  this->mStartPoint.setElementName("start");
  this->mEndPoint.setElementName("end");

  connectToChild();

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}


/*
 * Creates a new line segment with the given 2D coordinates.
 */ 
LineSegment::LineSegment (LayoutPkgNamespaces* layoutns, double x1, double y1, double x2, double y2) 
 : SBase (layoutns)
 , mStartPoint(layoutns, x1, y1, 0.0 )
 , mEndPoint (layoutns, x2, y2, 0.0 )
  , mStartExplicitlySet (true)
  , mEndExplicitlySet (true)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  this->mStartPoint.setElementName("start");
  this->mEndPoint.setElementName("end");

  connectToChild();

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}


/*
 * Creates a new line segment with the given 3D coordinates.
 */ 
LineSegment::LineSegment (LayoutPkgNamespaces* layoutns, double x1, double y1, double z1,
                          double x2, double y2, double z2) 
 : SBase(layoutns)
  , mStartPoint(layoutns, x1, y1, z1)
  , mEndPoint  (layoutns, x2, y2, z2)
  , mStartExplicitlySet (true)
  , mEndExplicitlySet (true)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  this->mStartPoint.setElementName("start");
  this->mEndPoint.setElementName("end");

  connectToChild();

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}

/*
 * Copy constructor.
 */
LineSegment::LineSegment(const LineSegment& orig):SBase(orig)
{
  this->mStartPoint=orig.mStartPoint;
  this->mEndPoint=orig.mEndPoint;
  this->mStartExplicitlySet=orig.mStartExplicitlySet;
  this->mEndExplicitlySet=orig.mEndExplicitlySet;

  connectToChild();
}


/*
 * Assignment operator.
 */
LineSegment& LineSegment::operator=(const LineSegment& orig)
{
  if(&orig!=this)
  {
    this->SBase::operator=(orig);
    this->mStartPoint=orig.mStartPoint;
    this->mEndPoint=orig.mEndPoint;
    this->mStartExplicitlySet=orig.mStartExplicitlySet;
    this->mEndExplicitlySet=orig.mEndExplicitlySet;
    connectToChild();
  }
  
  return *this;
}


/*
 * Creates a new line segment with the two given points.
 */ 
LineSegment::LineSegment (LayoutPkgNamespaces* layoutns, const Point* start, const Point* end) 
 : SBase (layoutns)
 , mStartPoint(layoutns)
 , mEndPoint  (layoutns)
  , mStartExplicitlySet (true)
  , mEndExplicitlySet (true)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  if(start && end)
  {  
    this->mStartPoint=*start;  
    this->mStartPoint.setElementName("start");
    this->mEndPoint=*end;  
    this->mEndPoint.setElementName("end");
  }

  connectToChild();

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}

/*
 * Creates a new LineSegment from the given XMLNode
 */
LineSegment::LineSegment(const XMLNode& node, unsigned int l2version)
 : SBase (2, l2version)
 , mStartPoint(2, l2version)
 , mEndPoint  (2, l2version)
  , mStartExplicitlySet (false)
  , mEndExplicitlySet (false)
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
        if(childName=="start")
        {
            this->mStartPoint=Point(*child);
            this->mStartExplicitlySet = true;
        }
        else if(childName=="end")
        {
            this->mEndPoint=Point(*child);
            this->mEndExplicitlySet = true;
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

  connectToChild();
  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(2,l2version));  
}


/*
 * Destructor.
 */ 
LineSegment::~LineSegment ()
{
}


/*
 * Does nothing since no defaults are defined for LineSegment.
 */ 
void LineSegment::initDefaults ()
{
}


/*
 * Returns the start point of the line.
 */ 
const Point*
LineSegment::getStart () const
{
  return &this->mStartPoint;
}


/*
 * Returns the start point of the line.
 */ 
Point*
LineSegment::getStart()
{
  return &this->mStartPoint;
}


/*
 * Initializes the start point with a copy of the given Point object.
 */
void
LineSegment::setStart (const Point* start)
{
  if(start)
  {  
    this->mStartPoint=*start;
    this->mStartPoint.setElementName("start");
    this->mStartPoint.connectToParent(this);
    this->mStartExplicitlySet = true;
  }
}


/*
 * Initializes the start point with the given coordinates.
 */
void
LineSegment::setStart (double x, double y, double z)
{
  this->mStartPoint.setOffsets(x, y, z);
  this->mStartExplicitlySet = true;
}


/*
 * Returns the end point of the line.
 */ 
const Point*
LineSegment::getEnd () const
{
  return &this->mEndPoint;
}


/*
 * Returns the end point of the line.
 */ 
Point*
LineSegment::getEnd ()
{
  return &this->mEndPoint;
}


/*
 * Initializes the end point with a copy of the given Point object.
 */
void
LineSegment::setEnd (const Point* end)
{
  if(end)
  {  
    this->mEndPoint = *end;
    this->mEndPoint.setElementName("end");
    this->mEndPoint.connectToParent(this);
    this->mEndExplicitlySet = true;
  }
}


/*
 * Initializes the end point with the given coordinates.
 */
void
LineSegment::setEnd (double x, double y, double z)
{
  this->mEndPoint.setOffsets(x, y, z);
  this->mEndExplicitlySet = true;
}


/** @cond doxygenLibsbmlInternal */
bool
LineSegment::getStartExplicitlySet() const
{
  return mStartExplicitlySet;
}
/** @endcond */



/** @cond doxygenLibsbmlInternal */
bool
LineSegment::getEndExplicitlySet() const
{
  return mEndExplicitlySet;
}
/** @endcond */


/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string& LineSegment::getElementName () const 
{
  static const std::string name = "curveSegment";
  return name;
}

/*
 * @return a (deep) copy of this LineSegment.
 */
LineSegment* 
LineSegment::clone () const
{
    return new LineSegment(*this);
}


/** @cond doxygenLibsbmlInternal */
SBase*
LineSegment::createObject (XMLInputStream& stream)
{

  const std::string& name   = stream.peek().getName();
  SBase*        object = 0;

  if (name == "start")
  {
    if (getStartExplicitlySet() == true)
    {
      getErrorLog()->logPackageError("layout", LayoutLSegAllowedElements, 
          getPackageVersion(), getLevel(), getVersion());
    }

    object = &mStartPoint;
    mStartExplicitlySet = true;
  }
  else if(name == "end")
  {
    if (getEndExplicitlySet() == true)
    {
      getErrorLog()->logPackageError("layout", LayoutLSegAllowedElements, 
          getPackageVersion(), getLevel(), getVersion());
    }

    object = &mEndPoint;
    mEndExplicitlySet = true;
  }

 
  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
LineSegment::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);
  attributes.add("xsi:type");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void LineSegment::readAttributes (const XMLAttributes& attributes,
                                  const ExpectedAttributes& expectedAttributes)
{
	const unsigned int sbmlLevel   = getLevel  ();
	const unsigned int sbmlVersion = getVersion();

	unsigned int numErrs;

	/* look to see whether an unknown attribute error was logged
	 * during the read of the listOfLineSegments - which will have
	 * happened immediately prior to this read
	*/

	if (getErrorLog() != NULL &&
	    static_cast<ListOfLineSegments*>(getParentSBMLObject())->size() < 2)
	{
		numErrs = getErrorLog()->getNumErrors();
		for (int n = numErrs-1; n >= 0; n--)
		{
			if (getErrorLog()->getError(n)->getErrorId() == UnknownPackageAttribute)
			{
				const std::string details =
				      getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownPackageAttribute);
				getErrorLog()->logPackageError("layout", 
                  LayoutLOCurveSegsAllowedAttributes,
				          getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				           getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
				getErrorLog()->logPackageError("layout", 
                  LayoutLOCurveSegsAllowedAttributes,
				          getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
		}
	}

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
        if (this->getTypeCode() == SBML_LAYOUT_LINESEGMENT)
        {
				  getErrorLog()->logPackageError("layout", LayoutLSegAllowedAttributes,
				                 getPackageVersion(), sbmlLevel, sbmlVersion, details);
        }
        else
        {
 				  getErrorLog()->logPackageError("layout", LayoutCBezAllowedAttributes,
				                 getPackageVersion(), sbmlLevel, sbmlVersion, details);
       }
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				                  getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
        if (this->getTypeCode() == SBML_LAYOUT_LINESEGMENT)
        {
				  getErrorLog()->logPackageError("layout", 
                         LayoutLSegAllowedCoreAttributes,
				                 getPackageVersion(), sbmlLevel, sbmlVersion, details);
        }
        else
        {
				  getErrorLog()->logPackageError("layout", 
                         LayoutCBezAllowedCoreAttributes,
				                 getPackageVersion(), sbmlLevel, sbmlVersion, details);
        }
			}
		}
	}

	//bool assigned = false;

	////
	//// xsi:type string   ( use = "required" )
	////
	//assigned = attributes.readInto("xsi:type", mXsi:type);

	//if (assigned == true)
	//{
	//	// check string is not empty

	//	if (mXsi:type.empty() == true)
	//	{
	//		logEmptyString(mXsi:type, getLevel(), getVersion(), "<LineSegment>");
	//	}
	//}
	//else
	//{
	//	std::string message = "Layout attribute 'xsi:type' is missing.";
	//	getErrorLog()->logPackageError("layout", LayoutUnknownError,
	//	               getPackageVersion(), sbmlLevel, sbmlVersion, message);
	//}
}

void
LineSegment::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);
  mStartPoint.write(stream);
  mEndPoint.write(stream);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void LineSegment::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);
  stream.writeAttribute("type", "xsi", "LineSegment");

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
LineSegment::getTypeCode () const
{
  return SBML_LAYOUT_LINESEGMENT;
}

/*
 * Accepts the given SBMLVisitor.
 */
bool
LineSegment::accept (SBMLVisitor& v) const
{
  v.visit(*this);
  
  this->mStartPoint.accept(v);
  this->mEndPoint.accept(v);
  
  v.leave(*this);

  return true;
}


/** @cond doxygenLibsbmlInternal */
void 
LineSegment::writeXMLNS (XMLOutputStream& stream) const
{
  XMLNamespaces xmlns;
  xmlns.add(LayoutExtension::getXmlnsXSI(), "xsi");
  stream << xmlns;
}
/** @endcond */

/*
 * Creates an XMLNode object from this.
 */
XMLNode LineSegment::toXML() const
{
  return getXmlNodeForSBase(this);
}


/** @cond doxygenLibsbmlInternal */
/*
 * Sets the parent SBMLDocument of this SBML object.
 */
void
LineSegment::setSBMLDocument (SBMLDocument* d)
{
  SBase::setSBMLDocument(d);

  mStartPoint.setSBMLDocument(d);
  mEndPoint.setSBMLDocument(d);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Sets this SBML object to child SBML objects (if any).
 * (Creates a child-parent relationship by the parent)
 */
void
LineSegment::connectToChild()
{
  SBase::connectToChild();
  mStartPoint.connectToParent(this);
  mEndPoint.connectToParent(this);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Enables/Disables the given package with this element and child
 * elements (if any).
 * (This is an internal implementation for enablePakcage function)
 */
void
LineSegment::enablePackageInternal(const std::string& pkgURI,
                                   const std::string& pkgPrefix, bool flag)
{
  SBase::enablePackageInternal(pkgURI,pkgPrefix,flag);

  mStartPoint.enablePackageInternal(pkgURI,pkgPrefix,flag);
  mEndPoint.enablePackageInternal(pkgURI,pkgPrefix,flag);
}
/** @endcond */




#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
LineSegment_t *
LineSegment_create (void)
{
  return new(std::nothrow) LineSegment;
}


LIBSBML_EXTERN
LineSegment_t *
LineSegment_createFrom (const LineSegment_t *temp)
{
  LineSegment empty;
  return new(std::nothrow) LineSegment(temp ? *temp : empty);
}


LIBSBML_EXTERN
LineSegment_t *
LineSegment_createWithPoints (const Point_t *start, const Point_t *end)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) LineSegment (&layoutns, start, end );
}


LIBSBML_EXTERN
LineSegment_t *
LineSegment_createWithCoordinates (double x1, double y1, double z1,
                                   double x2, double y2, double z2)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) LineSegment(&layoutns, x1, y1, z1, x2, y2, z2);
}


LIBSBML_EXTERN
void
LineSegment_free (LineSegment_t *ls)
{
  delete ls;
}


LIBSBML_EXTERN
void
LineSegment_setStart (LineSegment_t *ls, const Point_t *start)
{
  if (ls == NULL) return;
  ls->setStart(start);
}


LIBSBML_EXTERN
void
LineSegment_setEnd (LineSegment_t *ls, const Point_t *end)
{
  if (ls == NULL) return;
  ls->setEnd(end);
}


LIBSBML_EXTERN
Point_t *
LineSegment_getStart (LineSegment_t *ls)
{
  if (ls == NULL) return NULL;
  return ls->getStart();
}


LIBSBML_EXTERN
Point_t *
LineSegment_getEnd (LineSegment_t *ls)
{
  if (ls == NULL) return NULL;
  return ls->getEnd();
}


LIBSBML_EXTERN
void
LineSegment_initDefaults (LineSegment_t *ls)
{
  if (ls == NULL) return;
  ls->initDefaults();
}


LIBSBML_EXTERN
LineSegment_t *
LineSegment_clone (const LineSegment_t *m)
{
  if (m == NULL) return NULL;
  return static_cast<LineSegment*>( m->clone() );
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END

