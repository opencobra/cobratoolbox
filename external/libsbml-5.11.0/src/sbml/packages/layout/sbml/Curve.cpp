/**
 * @file    Curve.cpp
 * @brief   Implementation of Curve for SBML Layout.
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

#include <assert.h>
#include <iostream>

#include <sbml/packages/layout/sbml/Curve.h>
#include <sbml/packages/layout/sbml/LineSegment.h>
#include <sbml/packages/layout/sbml/CubicBezier.h>
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
Curve::getAllElements(ElementFilter *filter)
{
  List* ret = new List();
  List* sublist = NULL;

  ADD_FILTERED_LIST(ret, sublist, mCurveSegments, filter);  

  ADD_FILTERED_FROM_PLUGIN(ret, sublist, filter);

  return ret;
}



/*
 * Creates a curve with the given SBML level, version and package version and 
 * an empty list of segments.
 */ 
Curve::Curve (unsigned int level, unsigned int version, unsigned int pkgVersion) 
 : SBase (level,version)
  ,mCurveSegments(level,version,pkgVersion)
{
  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));  
  connectToChild();
}


/*
 * Creates a curve with the given LayoutPkgNamespaces and an empty list of segments.
 */ 
Curve::Curve (LayoutPkgNamespaces *layoutns)
 : SBase (layoutns)
  ,mCurveSegments(layoutns)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  connectToChild();

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}


/*
 * Creates a new ReactionGlyph from the given XMLNode
 */
Curve::Curve(const XMLNode& node, unsigned int l2version)
 : SBase (2,l2version)
  ,mCurveSegments(2,l2version)
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
        else if(childName=="listOfCurveSegments")
        {
            const XMLNode* innerChild;
            unsigned int i=0,iMax=child->getNumChildren();
            while(i<iMax)
            {
                innerChild=&child->getChild(i);
                const std::string innerChildName=innerChild->getName();
                if(innerChildName=="curveSegment")
                {
                    // get the type
                    const XMLAttributes& innerAttributes=innerChild->getAttributes();
                    int typeIndex=innerAttributes.getIndex("type");
                    if(typeIndex==-1 || innerAttributes.getURI(typeIndex)!="http://www.w3.org/2001/XMLSchema-instance")
                    {
                        // throw
                        ++i;
                        continue;
                    }
                    if(innerAttributes.getValue(typeIndex)=="LineSegment")
                    {
                      this->mCurveSegments.appendAndOwn(new LineSegment(*innerChild));
                    }
                    else if(innerAttributes.getValue(typeIndex)=="CubicBezier")
                    {
                      this->mCurveSegments.appendAndOwn(new CubicBezier(*innerChild));
                    }
                    else
                    {
                        // throw
                    }
                }
                else if(innerChildName=="annotation")
                {
                    this->mCurveSegments.setAnnotation(new XMLNode(*innerChild));
                }
                else if(innerChildName=="notes")
                {
                    this->mCurveSegments.setNotes(new XMLNode(*innerChild));
                }
                else
                {
                    // throw
                }
                ++i;
            }
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
 * Destructor.
 */ 
Curve::~Curve ()
{
}


/*
 * Does nothing since no defaults are defined for Curve.
 */ 
void Curve::initDefaults ()
{
}


/*
 * Ctor.
 */
ListOfLineSegments::ListOfLineSegments(unsigned int level, unsigned int version, unsigned int pkgVersion)
 : ListOf(level,version)
{
  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));
};


/*
 * Ctor.
 */
ListOfLineSegments::ListOfLineSegments(LayoutPkgNamespaces* layoutns)
 : ListOf(layoutns)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());
}


/* return nth item in list */
LineSegment *
ListOfLineSegments::get(unsigned int n)
{
  return static_cast<LineSegment*>(ListOf::get(n));
}


/* return nth item in list */
const LineSegment *
ListOfLineSegments::get(unsigned int n) const
{
  return static_cast<const LineSegment*>(ListOf::get(n));
}


/* Removes the nth item from this list */
LineSegment*
ListOfLineSegments::remove (unsigned int n)
{
   return static_cast<LineSegment*>(ListOf::remove(n));
}


bool 
ListOfLineSegments::isValidTypeForList(SBase * item)
{
  int tc = item->getTypeCode();
  return ((tc == SBML_LAYOUT_CUBICBEZIER )
    ||    (tc == SBML_LAYOUT_LINESEGMENT ) );
}


/*
 * Returns a reference to the ListOf object that holds all the curve
 * segments.
 */
const ListOfLineSegments*
Curve::getListOfCurveSegments () const
{
  return & this->mCurveSegments;
}


/*
 * Returns a reference to the ListOf object that holds all the curve
 * segments.
 */
ListOfLineSegments*
Curve::getListOfCurveSegments ()
{
  return &this->mCurveSegments;
}



/*
 * Returns a pointer to the curve segment with the given index.  If the
 * index is invalid, @c NULL is returned.
 */  
const LineSegment*
Curve::getCurveSegment (unsigned int index) const
{
  return dynamic_cast<const LineSegment*>( this->mCurveSegments.get(index) );
}


/*
 * Returns a pointer to the curve segment with the given index.  If the
 * index is invalid, @c NULL is returned.
 */  
LineSegment*
Curve::getCurveSegment (unsigned int index)
{
  return static_cast<LineSegment*>( this->mCurveSegments.get(index) );
}


/*
 * Adds a new CurveSegment to the end of the list.
 */ 
void
Curve::addCurveSegment (const LineSegment* segment)
{
  this->mCurveSegments.append(segment);
}


/*
 * Returns the number of curve segments.
 */ 
unsigned int
Curve::getNumCurveSegments () const
{
  return this->mCurveSegments.size();
}


/*
 * Creates a new LineSegment and adds it to the end of the list.  A
 * reference to the new LineSegment object is returned.
 */
LineSegment*
Curve::createLineSegment ()
{
  LAYOUT_CREATE_NS(layoutns,getSBMLNamespaces());
  LineSegment* ls = new LineSegment(layoutns);

  this->mCurveSegments.appendAndOwn(ls);
  delete layoutns;
  return ls;
}


/*
 * Creates a new CubicBezier and adds it to the end of the list.  A
 * reference to the new CubicBezier object is returned.
 */
CubicBezier* Curve::createCubicBezier ()
{
  LAYOUT_CREATE_NS(layoutns,getSBMLNamespaces());
  CubicBezier* cb = new CubicBezier(layoutns);

  this->mCurveSegments.appendAndOwn(cb);
  delete layoutns;
  return cb;
}


/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string& Curve::getElementName () const 
{
  static const std::string name = "curve";
  return name;
}

/*
 * @return a (deep) copy of this Curve.
 */
Curve* 
Curve::clone () const
{
    return new Curve(*this);
}


/*
 * Copy constructor.
 */
Curve::Curve(const Curve& source):SBase(source)
{
    // copy the line segments
    this->mCurveSegments=*source.getListOfCurveSegments();

    connectToChild();
}

/*
 * Assignment operator.
 */
Curve& Curve::operator=(const Curve& source)
{
  if(&source!=this)
  {
    this->SBase::operator=(source);
    // copy the line segments
    this->mCurveSegments=*source.getListOfCurveSegments();

    connectToChild();  
  }
  
  return *this;
}



/** @cond doxygenLibsbmlInternal */
SBase*
Curve::createObject (XMLInputStream& stream)
{

  const std::string& name   = stream.peek().getName();
  SBase*        object = 0;

  if (name == "listOfCurveSegments")
  {
    if (mCurveSegments.size() != 0)
    {
      getErrorLog()->logPackageError("layout", LayoutCurveAllowedElements, 
        getPackageVersion(), getLevel(), getVersion());
    }

    object = &mCurveSegments;
  }
 
  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
Curve::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void Curve::readAttributes (const XMLAttributes& attributes,
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
				getErrorLog()->logPackageError("layout", LayoutCurveAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				                  getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
				getErrorLog()->logPackageError("layout", 
                       LayoutCurveAllowedCoreAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
		}
	}
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
Curve::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);

  if (mCurveSegments.size() > 0)
  mCurveSegments.write(stream);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void Curve::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */

XMLNode Curve::toXML() const
{
  return getXmlNodeForSBase(this);
}


/** @cond doxygenLibsbmlInternal */
/*
 * Sets the parent SBMLDocument of this SBML object.
 */
void
Curve::setSBMLDocument (SBMLDocument* d)
{
  SBase::setSBMLDocument(d);

  mCurveSegments.setSBMLDocument(d);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Sets this SBML object to child SBML objects (if any).
 * (Creates a child-parent relationship by the parent)
 */
void
Curve::connectToChild()
{
  SBase::connectToChild();
  mCurveSegments.connectToParent(this);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Enables/Disables the given package with this element and child
 * elements (if any).
 * (This is an internal implementation for enablePakcage function)
 */
void
Curve::enablePackageInternal(const std::string& pkgURI,
                                      const std::string& pkgPrefix, bool flag)
{
  SBase::enablePackageInternal(pkgURI,pkgPrefix,flag);

  mCurveSegments.enablePackageInternal(pkgURI,pkgPrefix,flag);
}
/** @endcond */


/*
 * @return a (deep) copy of this ListOfLineSegments.
 */
ListOfLineSegments*
ListOfLineSegments::clone () const
{
  return new ListOfLineSegments(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfLineSegments::getItemTypeCode () const
{
  return SBML_LAYOUT_LINESEGMENT;
}


/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string&
ListOfLineSegments::getElementName () const
{
  static const std::string name = "listOfCurveSegments";
  return name;
}


/** @cond doxygenLibsbmlInternal */
SBase*
ListOfLineSegments::createObject (XMLInputStream& stream)
{
  const std::string& name   = stream.peek().getName();
  SBase*        object = 0;


  if (name == "curveSegment")
  {
    std::string type = "LineSegment";
    XMLTriple triple("type","http://www.w3.org/2001/XMLSchema-instance","xsi");

    if (!stream.peek().getAttributes().readInto(triple, type))
    {
      //std::cout << "[DEBUG] ListOfLineSegments::createObject () : 
      //              Failed to read xsi:type" << std::endl;
			getErrorLog()->logPackageError("layout", 
                     LayoutXsiTypeAllowedLocations,
			               getPackageVersion(), getLevel(), getVersion());

      return object;
    }

    //std::cout << "[DEBUG] ListOfLineSegments::createObject () : type " 
    //          << type << std::endl;
    
    LAYOUT_CREATE_NS(layoutns,this->getSBMLNamespaces());
    if(type=="LineSegment")
    {
      object = new LineSegment(layoutns);
    }
    else if(type=="CubicBezier")
    {
      object = new CubicBezier(layoutns);
    }
    else
    {
			getErrorLog()->logPackageError("layout", LayoutXsiTypeSyntax,
			               getPackageVersion(), getLevel(), getVersion());
    }
    delete layoutns;
  }
  
  if(object) appendAndOwn(object);

  return object;
}
/** @endcond */

/*
 * Creates an XMLNode object from this.
 */
XMLNode ListOfLineSegments::toXML() const
{
  return getXmlNodeForSBase(this);
}


/*
 * Returns the package type code  for this object.
 */
int
Curve::getTypeCode () const
{
  return SBML_LAYOUT_CURVE;
}


/*
 * Accepts the given SBMLVisitor.
 */
bool
Curve::accept (SBMLVisitor& v) const
{
  v.visit(*this);
  
  mCurveSegments.accept(v);
  
  v.leave(*this);
  
  return true;
}



#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
Curve_t *
Curve_create (void)
{
  return new(std::nothrow) Curve;
}


LIBSBML_EXTERN
Curve_t *
Curve_createFrom (const Curve_t *temp)
{
  Curve empty;
  return new(std::nothrow) Curve(temp ? *temp : empty);
}


LIBSBML_EXTERN
void
Curve_free (Curve_t *c)
{
  delete c;
}


LIBSBML_EXTERN
void
Curve_addCurveSegment (Curve_t *c, LineSegment_t *ls)
{
  if (c == NULL) return;
  c->addCurveSegment(ls);
}


LIBSBML_EXTERN
unsigned int
Curve_getNumCurveSegments (const Curve_t *c)
{
  if (c == NULL) return 0;
  return c->getNumCurveSegments();
}


LIBSBML_EXTERN
LineSegment_t *
Curve_getCurveSegment (const Curve_t *c, unsigned int index)
{
  if (c == NULL) return NULL;
  return const_cast<LineSegment*>(c->getCurveSegment(index));
}


LIBSBML_EXTERN
ListOf_t *
Curve_getListOfCurveSegments (Curve_t *c)
{
  if (c == NULL) return NULL;
  return c->getListOfCurveSegments();
}


LIBSBML_EXTERN
void
Curve_initDefaults (Curve_t *c)
{
  if (c == NULL) return;
  c->initDefaults();
}


LIBSBML_EXTERN
LineSegment_t *
Curve_createLineSegment (Curve_t *c)
{
  if (c == NULL)  return NULL;
  return c->createLineSegment();
}


LIBSBML_EXTERN
CubicBezier_t *
Curve_createCubicBezier (Curve_t *c)
{
  if (c == NULL) return NULL;
  return c->createCubicBezier();
}


LIBSBML_EXTERN
Curve_t *
Curve_clone (const Curve_t *m)
{
  if (m == NULL) return NULL;
  return static_cast<Curve*>( m->clone() );
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END

