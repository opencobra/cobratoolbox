/**
 * @file    CubicBezier.cpp
 * @brief   Implementation of CubicBezier for SBML Layout.
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

#include <sbml/packages/layout/sbml/CubicBezier.h>
#include <sbml/packages/layout/util/LayoutUtilities.h>

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
CubicBezier::getAllElements(ElementFilter *filter)
{
  List* ret = LineSegment::getAllElements(filter);
  List* sublist = NULL;

  ADD_FILTERED_ELEMENT(ret, sublist, mBasePoint1, filter);  
  ADD_FILTERED_ELEMENT(ret, sublist, mBasePoint2, filter);  

  return ret;
}

/*
 * Creates a CubicBezier and returns the pointer.
 */
CubicBezier::CubicBezier(unsigned int level, unsigned int version, unsigned int pkgVersion) 
 : LineSegment(level,version,pkgVersion)
  ,mBasePoint1(level,version,pkgVersion)
  ,mBasePoint2(level,version,pkgVersion)
  , mBasePt1ExplicitlySet (false)
  , mBasePt2ExplicitlySet (false)
{
  this->mStartPoint.setElementName("start");
  this->mEndPoint.setElementName("end");
  this->mBasePoint1.setElementName("basePoint1");
  this->mBasePoint2.setElementName("basePoint2");

  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));  
  connectToChild();
}


/*
 * Creates a CubicBezier and returns the pointer.
 */
CubicBezier::CubicBezier(LayoutPkgNamespaces* layoutns)
 : LineSegment(layoutns)
  ,mBasePoint1(layoutns)
  ,mBasePoint2(layoutns)
  , mBasePt1ExplicitlySet (false)
  , mBasePt2ExplicitlySet (false)
{
  this->mStartPoint.setElementName("start");
  this->mEndPoint.setElementName("end");
  this->mBasePoint1.setElementName("basePoint1");
  this->mBasePoint2.setElementName("basePoint2");

  connectToChild();

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
 * Creates a CubicBezier with the given 2D coordinates and returns the
 * pointer.
 */
CubicBezier::CubicBezier (LayoutPkgNamespaces* layoutns, double x1, double y1, double x2, double y2)
  : LineSegment(layoutns, x1, y1, 0.0, x2, y2, 0.0 )
  ,mBasePoint1(layoutns)
  ,mBasePoint2(layoutns)
  , mBasePt1ExplicitlySet (true)
  , mBasePt2ExplicitlySet (true)
{
  this->straighten();
  this->mBasePoint1.setElementName("basePoint1");
  this->mBasePoint2.setElementName("basePoint2");

  connectToChild();

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
 * Creates a CubicBezier with the given 3D coordinates and returns the
 * pointer.
 */
CubicBezier::CubicBezier (LayoutPkgNamespaces* layoutns, double x1, double y1, double z1,
                          double x2, double y2, double z2)
 : LineSegment(layoutns, x1, y1, z1, x2, y2, z2 )
  ,mBasePoint1(layoutns)
  ,mBasePoint2(layoutns)
  , mBasePt1ExplicitlySet (true)
  , mBasePt2ExplicitlySet (true)
{
  this->straighten();
  this->mBasePoint1.setElementName("basePoint1");
  this->mBasePoint2.setElementName("basePoint2");

  connectToChild();

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
 * Copy constructor.
 */
CubicBezier::CubicBezier(const CubicBezier& orig):LineSegment(orig)
{
  this->mBasePoint1=orig.mBasePoint1;
  this->mBasePoint2=orig.mBasePoint2;
  this->mBasePt1ExplicitlySet=orig.mBasePt1ExplicitlySet;
  this->mBasePt2ExplicitlySet=orig.mBasePt2ExplicitlySet;

  connectToChild();
}


/*
 * Assignment operator.
 */
CubicBezier& CubicBezier::operator=(const CubicBezier& orig)
{
  if(&orig!=this)
  {
    LineSegment::operator=(orig);
    this->mBasePoint1=orig.mBasePoint1;
    this->mBasePoint2=orig.mBasePoint2;
    this->mBasePt1ExplicitlySet=orig.mBasePt1ExplicitlySet;
    this->mBasePt2ExplicitlySet=orig.mBasePt2ExplicitlySet;
    connectToChild();
  }

  return *this;
}



/*
 * Makes a line from a CubicBezier by setting both base points into the
 * middle between the start and the end point.
 */
void CubicBezier::straighten ()
{
  double x = (this->mEndPoint.getXOffset()+this->mStartPoint.getXOffset()) / 2.0;
  double y = (this->mEndPoint.getYOffset()+this->mStartPoint.getYOffset()) / 2.0;
  double z = (this->mEndPoint.getZOffset()+this->mStartPoint.getZOffset()) / 2.0;

  this->mBasePoint1.setOffsets(x, y, z);
  this->mBasePoint2.setOffsets(x, y, z);
}


/*
 * Creates a CubicBezier with the given points and returns the pointer.
 */
CubicBezier::CubicBezier (LayoutPkgNamespaces* layoutns, const Point* start, const Point* end)
 : LineSegment(layoutns, start, end)
  ,mBasePoint1(layoutns)
  ,mBasePoint2(layoutns)
  , mBasePt1ExplicitlySet (false)
  , mBasePt2ExplicitlySet (false)
{
  this->straighten();
  this->mBasePoint1.setElementName("basePoint1");
  this->mBasePoint2.setElementName("basePoint2");

  connectToChild();

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
 * Creates a CubicBezier with the given points and returns the pointer.
 */
CubicBezier::CubicBezier (LayoutPkgNamespaces* layoutns, const Point* start, const Point* base1,
                          const Point* base2, const Point* end)
 : LineSegment(layoutns, start ,end )
  ,mBasePoint1(layoutns)
  ,mBasePoint2(layoutns)
  , mBasePt1ExplicitlySet (true)
  , mBasePt2ExplicitlySet (true)
{
    if(base1 && base2 && start && end)
    {
      this->mBasePoint1=*base1;
      this->mBasePoint1.setElementName("basePoint1");
      this->mBasePoint2=*base2;
      this->mBasePoint2.setElementName("basePoint2");
    }
    else
    {
        this->mStartPoint=Point(layoutns);
        this->mEndPoint=Point(layoutns);
    }

  connectToChild();

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
 * Creates a new CubicBezier from the given XMLNode
 */
CubicBezier::CubicBezier(const XMLNode& node, unsigned int l2version)
 : LineSegment(2, l2version)
  ,mBasePoint1(2, l2version)
  ,mBasePoint2(2, l2version)
  , mBasePt1ExplicitlySet (false)
  , mBasePt2ExplicitlySet (false)
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
        else if(childName=="basePoint1")
        {
            this->mBasePoint1=Point(*child);
            this->mBasePt1ExplicitlySet = true;
        }
        else if(childName=="basePoint2")
        {
            this->mBasePoint2=Point(*child);
            this->mBasePt2ExplicitlySet = true;
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
}


/*
 * Destructor.
 */ 
CubicBezier::~CubicBezier ()
{
}


/*
 * Calls initDefaults from LineSegment.
 */ 
void
CubicBezier::initDefaults()
{
  LineSegment::initDefaults();
}


/*
 * Returns the first base point of the curve (the one closer to the
 * starting point).
 */ 
const Point*
CubicBezier::getBasePoint1() const
{
  return &this->mBasePoint1;
}


/*
 * Returns the first base point of the curve (the one closer to the
 * starting point).
 */ 
Point*
CubicBezier::getBasePoint1 ()
{
  return &this->mBasePoint1;
}


/*
 * Initializes first base point with a copy of the given point.
 */
void
CubicBezier::setBasePoint1 (const Point* p)
{
  if(p)
  {  
    this->mBasePoint1 = *p;
    this->mBasePoint1.setElementName("basePoint1");
    this->mBasePoint1.connectToParent(this);
    this->mBasePt1ExplicitlySet = true;
  }
}


/*
 * Initializes first base point with the given ccordinates.
 */
void
CubicBezier::setBasePoint1 (double x, double y, double z)
{
  this->mBasePoint1.setOffsets(x, y ,z);
  this->mBasePoint1.connectToParent(this);
  this->mBasePt1ExplicitlySet = true;
}


/*
 * Returns the second base point of the curve (the one closer to the
 * starting point).
 */ 
const Point*
CubicBezier::getBasePoint2 () const
{
  return &this->mBasePoint2;
}


/*
 * Returns the second base point of the curve (the one closer to the
 * starting point).
 */ 
Point*
CubicBezier::getBasePoint2 ()
{
  return &this->mBasePoint2;
}


/*
 * Initializes second base point with a copy of the given point.
 */
void CubicBezier::setBasePoint2 (const Point* p)
{
  if(p)
  {  
    this->mBasePoint2 = *p;
    this->mBasePoint2.setElementName("basePoint2");
    this->mBasePoint2.connectToParent(this);
    this->mBasePt2ExplicitlySet = true;
  }
}


/*
 * Initializes second base point with the given ccordinates.
 */
void
CubicBezier::setBasePoint2 (double x, double y, double z)
{
  this->mBasePoint2.setOffsets(x, y, z);
  this->mBasePoint2.connectToParent(this);
  this->mBasePt2ExplicitlySet = true;
}


/** @cond doxygenLibsbmlInternal */
bool
CubicBezier::getBasePt1ExplicitlySet() const
{
  return mBasePt1ExplicitlySet;
}
/** @endcond */



/** @cond doxygenLibsbmlInternal */
bool
CubicBezier::getBasePt2ExplicitlySet() const
{
  return mBasePt2ExplicitlySet;
}
/** @endcond */


/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string& CubicBezier::getElementName () const 
{
  static const std::string name = "curveSegment";
  return name;
}


/*
 * @return a (deep) copy of this CubicBezier.
 */
CubicBezier* 
CubicBezier::clone () const
{
    return new CubicBezier(*this);
}


/** @cond doxygenLibsbmlInternal */
SBase*
CubicBezier::createObject (XMLInputStream& stream)
{

  const std::string& name   = stream.peek().getName();
  SBase*        object = 0;

  if (name == "basePoint1")
  {
    if (getBasePt1ExplicitlySet() == true)
    {
      getErrorLog()->logPackageError("layout", LayoutCBezAllowedElements, 
          getPackageVersion(), getLevel(), getVersion());
    }

    object = &mBasePoint1;
    mBasePt1ExplicitlySet = true;
  }
  else if(name == "basePoint2")
  {
    if (getBasePt2ExplicitlySet() == true)
    {
      getErrorLog()->logPackageError("layout", LayoutCBezAllowedElements, 
          getPackageVersion(), getLevel(), getVersion());
    }

    object = &mBasePoint2;
    mBasePt2ExplicitlySet = true;
  }
  else
  {
      object = LineSegment::createObject(stream);
  }
 
  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
CubicBezier::addExpectedAttributes(ExpectedAttributes& attributes)
{
  LineSegment::addExpectedAttributes(attributes);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void CubicBezier::readAttributes (const XMLAttributes& attributes,
                                  const ExpectedAttributes& expectedAttributes)
{
  LineSegment::readAttributes(attributes,expectedAttributes);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
CubicBezier::writeElements (XMLOutputStream& stream) const
{
  LineSegment::writeElements(stream);
  mBasePoint1.write(stream);
  mBasePoint2.write(stream);

  SBase::writeExtensionElements(stream);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void CubicBezier::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);
  stream.writeAttribute("type", "xsi", "CubicBezier");

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void 
CubicBezier::writeXMLNS (XMLOutputStream& stream) const
{
  XMLNamespaces xmlns;
  xmlns.add(LayoutExtension::getXmlnsXSI(), "xsi");
  stream << xmlns;
}
/** @endcond */


/*
 * Returns the package type code for this object.
 */
int
CubicBezier::getTypeCode () const
{
  return SBML_LAYOUT_CUBICBEZIER;
}


/*
 * Accepts the given SBMLVisitor.
 */
bool
CubicBezier::accept (SBMLVisitor& v) const
{
  v.visit(*this);
  
  this->mStartPoint.accept(v);
  this->mBasePoint1.accept(v);
  this->mBasePoint2.accept(v);
  this->mEndPoint.accept(v);
  
  v.leave(*this);
  
  return true;
}



/** @cond doxygenLibsbmlInternal */
/*
 * Sets the parent SBMLDocument of this SBML object.
 */
void
CubicBezier::setSBMLDocument (SBMLDocument* d)
{
  LineSegment::setSBMLDocument(d);

  mBasePoint1.setSBMLDocument(d);
  mBasePoint2.setSBMLDocument(d);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Sets this SBML object to child SBML objects (if any).
 * (Creates a child-parent relationship by the parent)
 */
void
CubicBezier::connectToChild()
{
  LineSegment::connectToChild();
  mBasePoint1.connectToParent(this);
  mBasePoint2.connectToParent(this);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Enables/Disables the given package with this element and child
 * elements (if any).
 * (This is an internal implementation for enablePakcage function)
 */
void
CubicBezier::enablePackageInternal(const std::string& pkgURI,
                                   const std::string& pkgPrefix, bool flag)
{
  LineSegment::enablePackageInternal(pkgURI,pkgPrefix,flag);

  mBasePoint1.enablePackageInternal(pkgURI,pkgPrefix,flag);
  mBasePoint2.enablePackageInternal(pkgURI,pkgPrefix,flag);
}
/** @endcond */



/*
 * Creates an XMLNode object from this.
 */
XMLNode CubicBezier::toXML() const
{ 
  return getXmlNodeForSBase(this);
}



#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
CubicBezier_t *
CubicBezier_create (void)
{
  return new(std::nothrow) CubicBezier;
}


LIBSBML_EXTERN
CubicBezier_t *
CubicBezier_createWithPoints (const Point_t *start, const Point_t *base1,
                              const Point_t *base2, const Point_t *end)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow)CubicBezier(&layoutns, start , base1, base2 , end );
}


LIBSBML_EXTERN
CubicBezier_t *
CubicBezier_createWithCoordinates (double x1, double y1, double z1,
                                   double x2, double y2, double z2,
                                   double x3, double y3, double z3,
                                   double x4, double y4, double z4)
{
  LayoutPkgNamespaces layoutns;

  Point* p1=new Point(&layoutns,x1,y1,z1);  
  Point* p2=new Point(&layoutns,x2,y2,z2);  
  Point* p3=new Point(&layoutns,x3,y3,z3);  
  Point* p4=new  Point(&layoutns,x4,y4,z4);  
  CubicBezier* cb=new(std::nothrow)CubicBezier(&layoutns, p1,p2,p3,p4);
  delete p1;
  delete p2;
  delete p3;
  delete p4;
  return cb;
}


LIBSBML_EXTERN
CubicBezier_t *
CubicBezier_createFrom (const CubicBezier_t *temp)
{
  CubicBezier empty;
  return new(std::nothrow) CubicBezier(temp ? *temp : empty);
}


LIBSBML_EXTERN
void
CubicBezier_free (CubicBezier_t *cb)
{
  delete cb;
}


LIBSBML_EXTERN
void
CubicBezier_setStart (CubicBezier_t *cb, const Point_t *start)
{
  LineSegment_setStart((LineSegment_t*)cb, start);
}


LIBSBML_EXTERN
Point_t *
CubicBezier_getStart (CubicBezier_t *cb)
{
  return LineSegment_getStart(cb);
}


LIBSBML_EXTERN
void
CubicBezier_setEnd (CubicBezier_t *cb, const Point_t *end)
{
  LineSegment_setEnd((LineSegment_t*)cb, end);
}


LIBSBML_EXTERN
Point_t *
CubicBezier_getEnd (CubicBezier_t *cb)
{
  return LineSegment_getEnd(cb);
}


LIBSBML_EXTERN
void
CubicBezier_setBasePoint1 (CubicBezier_t *cb, const Point_t *point)
{
  if (cb == NULL) return;
  cb->setBasePoint1(point);
}


LIBSBML_EXTERN
Point_t *
CubicBezier_getBasePoint1 (CubicBezier_t *cb)
{
  if (cb == NULL) return NULL;
  return cb->getBasePoint1();
}


LIBSBML_EXTERN
void
CubicBezier_setBasePoint2 (CubicBezier_t *cb, const Point_t *point)
{
  if (cb == NULL) return;
  cb->setBasePoint2(point );
}


LIBSBML_EXTERN
Point_t *
CubicBezier_getBasePoint2 (CubicBezier_t *cb)
{
  if (cb == NULL) return NULL;
  return cb->getBasePoint2();
}


LIBSBML_EXTERN
void
CubicBezier_initDefaults (CubicBezier_t *cb)
{
  if (cb == NULL) return;
  cb->initDefaults();
}

LIBSBML_EXTERN
CubicBezier_t *
CubicBezier_clone (const CubicBezier_t *m)
{
  if (m == NULL) return NULL;
  return static_cast<CubicBezier*>( m->clone() );
}


/** @endcond */
LIBSBML_CPP_NAMESPACE_END

