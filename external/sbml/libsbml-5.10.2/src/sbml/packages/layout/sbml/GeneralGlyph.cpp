/**
 * @file    GeneralGlyph.cpp
 * @brief   Implementation of GeneralGlyph for SBML Layout.
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
#include <limits>
#include <sbml/packages/layout/sbml/GeneralGlyph.h>
#include <sbml/packages/layout/sbml/ReferenceGlyph.h>
#include <sbml/packages/layout/sbml/SpeciesGlyph.h>
#include <sbml/packages/layout/sbml/TextGlyph.h>
#include <sbml/packages/layout/sbml/CompartmentGlyph.h>
#include <sbml/packages/layout/sbml/ReactionGlyph.h>
#include <sbml/packages/layout/sbml/GraphicalObject.h>
#include <sbml/packages/layout/util/LayoutUtilities.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>
#include <sbml/packages/layout/sbml/Layout.h>
#include <sbml/packages/layout/validator/LayoutSBMLError.h>
#include <sbml/util/ElementFilter.h>

#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

List*
GeneralGlyph::getAllElements(ElementFilter *filter)
{
  List* ret = GraphicalObject::getAllElements(filter);
  List* sublist = NULL;

  ADD_FILTERED_LIST(ret, sublist, mReferenceGlyphs, filter);  
  ADD_FILTERED_LIST(ret, sublist, mSubGlyphs, filter);  
  ADD_FILTERED_ELEMENT(ret, sublist, mCurve, filter);  

  return ret;
}

void
GeneralGlyph::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  GraphicalObject::renameSIdRefs(oldid, newid);
  if (isSetReferenceId() && mReference == oldid) 
  {
    setReferenceId(newid);
  }
}

/*
 * Creates a new GeneralGlyph.  The list of reference and sub glyph is
 * empty and the id of the associated element is set to the empty string.
 */
GeneralGlyph::GeneralGlyph(unsigned int level, unsigned int version, unsigned int pkgVersion) 
 : GraphicalObject (level,version,pkgVersion)
  ,mReference("")
  ,mReferenceGlyphs(level,version,pkgVersion)
  ,mSubGlyphs(level,version,pkgVersion)
  ,mCurve(level,version,pkgVersion)
  ,mCurveExplicitlySet (false)
{
  mSubGlyphs.setElementName("listOfSubGlyphs");

  connectToChild();
  //
  // (NOTE) Developers don't have to invoke setSBMLNamespacesAndOwn function as follows (commentted line)
  //        in this constuctor because the function is properly invoked in the constructor of the
  //        base class (GraphicalObject).
  //
  //setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));  
}


/*
 * Creates a new GeneralGlyph with the given LayoutPkgNamespaces
 */
GeneralGlyph::GeneralGlyph(LayoutPkgNamespaces* layoutns)
 : GraphicalObject (layoutns)
  ,mReference("")
  ,mReferenceGlyphs(layoutns)
  ,mSubGlyphs(layoutns)
  ,mCurve(layoutns)
  , mCurveExplicitlySet ( false )
{
  mSubGlyphs.setElementName("listOfSubGlyphs");
  //
  // (NOTE) Developers don't have to invoke setElementNamespace function as follows (commentted line)
  //        in this constuctor because the function is properly invoked in the constructor of the
  //        base class (LineSegment).
  //

  // setElementNamespace(layoutns->getURI());


  connectToChild();

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}


/*
 * Creates a GeneralGlyph with the given @p id.
 */
GeneralGlyph::GeneralGlyph (LayoutPkgNamespaces* layoutns, const std::string& id)
  : GraphicalObject(layoutns, id)
   ,mReference("")
   ,mReferenceGlyphs(layoutns)
   ,mSubGlyphs(layoutns)
   ,mCurve(layoutns)
   ,mCurveExplicitlySet (false)
{
  mSubGlyphs.setElementName("listOfSubGlyphs");

  //
  // (NOTE) Developers don't have to invoke setElementNamespace function as follows (commentted line)
  //        in this constuctor because the function is properly invoked in the constructor of the
  //        base class (LineSegment).
  //

  // setElementNamespace(layoutns->getURI());

  connectToChild();

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}


/*
 * Creates a GeneralGlyph with the given @p id and set the id of the
 * associated reaction to the second argument.
 */
GeneralGlyph::GeneralGlyph (LayoutPkgNamespaces* layoutns, const std::string& id,
                              const std::string& referenceId) 
  : GraphicalObject( layoutns, id  )
   ,mReference      ( referenceId  )
   ,mReferenceGlyphs(layoutns)
   ,mSubGlyphs(layoutns)
   ,mCurve(layoutns)
   , mCurveExplicitlySet (false)
{
  mSubGlyphs.setElementName("listOfSubGlyphs");

  //
  // (NOTE) Developers don't have to invoke setElementNamespace function as follows (commentted line)
  //        in this constuctor because the function is properly invoked in the constructor of the
  //        base class (LineSegment).
  //

  // setElementNamespace(layoutns->getURI());

  connectToChild();

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}

/*
 * Creates a new GeneralGlyph from the given XMLNode
 */
GeneralGlyph::GeneralGlyph(const XMLNode& node, unsigned int l2version)
  : GraphicalObject(node,l2version)
   ,mReference      ("")
   ,mReferenceGlyphs(2,l2version)
   ,mSubGlyphs(2,l2version)
   ,mCurve(2,l2version)
   ,mCurveExplicitlySet (false)
{
    mSubGlyphs.setElementName("listOfSubGlyphs");
    const XMLAttributes& attributes=node.getAttributes();
    const XMLNode* child;
    ExpectedAttributes ea;
    addExpectedAttributes(ea);
    this->readAttributes(attributes,ea);
    unsigned int n=0,nMax = node.getNumChildren();
    while(n<nMax)
    {
        child=&node.getChild(n);
        const std::string& childName=child->getName();
        if(childName=="curve")
        {
            // since the copy constructor of ListOf does not make deep copies
            // of the objects, we have to add the individual curveSegments to the 
            // curve instead of just copying the whole curve.
            Curve* pTmpCurve=new Curve(*child);
            unsigned int i,iMax=pTmpCurve->getNumCurveSegments();
            for(i=0;i<iMax;++i)
            {
                this->mCurve.addCurveSegment(pTmpCurve->getCurveSegment(i));
            }
            // we also have to copy mAnnotations, mNotes, mCVTerms and mHistory
            if(pTmpCurve->isSetNotes()) this->mCurve.setNotes(new XMLNode(*pTmpCurve->getNotes()));
            if(pTmpCurve->isSetAnnotation()) this->mCurve.setAnnotation(new XMLNode(*pTmpCurve->getAnnotation()));
            if(pTmpCurve->getCVTerms()!=NULL)
            {
              iMax=pTmpCurve->getCVTerms()->getSize(); 
              for(i=0;i<iMax;++i)
              {
                this->mCurve.getCVTerms()->add(static_cast<CVTerm*>(pTmpCurve->getCVTerms()->get(i))->clone());
              }
            }
            delete pTmpCurve;
            mCurveExplicitlySet = true;
        }
        else if(childName=="listOfReferenceGlyphs")
        {
            const XMLNode* innerChild;
            unsigned int i=0,iMax=child->getNumChildren();
            while(i<iMax)
            {
                innerChild=&child->getChild(i);
                const std::string innerChildName=innerChild->getName();
                if(innerChildName=="referenceGlyph")
                {
                    this->mReferenceGlyphs.appendAndOwn(new ReferenceGlyph(*innerChild));
                }
                else if(innerChildName=="annotation")
                {
                    this->mReferenceGlyphs.setAnnotation(new XMLNode(*innerChild));
                }
                else if(innerChildName=="notes")
                {
                    this->mReferenceGlyphs.setNotes(new XMLNode(*innerChild));
                }
                else
                {
                    // throw
                }
                ++i;
            }
        }
        else if(childName=="listOfSubGlyphs")
        {
            const XMLNode* innerChild;
            unsigned int i=0,iMax=child->getNumChildren();
            while(i<iMax)
            {
                innerChild=&child->getChild(i);
                const std::string innerChildName=innerChild->getName();
                ListOf& list=this->mSubGlyphs;
                if(innerChildName=="graphicalObject")
                {
                    list.appendAndOwn(new GraphicalObject(*innerChild));
                }
                else if(innerChildName=="textGlyph")
                {
                    list.appendAndOwn(new TextGlyph(*innerChild));
                }
                else if(innerChildName=="reactionGlyph")
                {
                    list.appendAndOwn(new ReactionGlyph(*innerChild));
                }
                else if(innerChildName=="speciesGlyph")
                {
                    list.appendAndOwn(new SpeciesGlyph(*innerChild));
                }
                else if(innerChildName=="compartmentGlyph")
                {
                    list.appendAndOwn(new CompartmentGlyph(*innerChild));
                }
                else if(innerChildName=="generalGlyph")
                {
                    list.appendAndOwn(new GeneralGlyph(*innerChild));
                }
                else if(innerChildName=="annotation")
                {
                    list.setAnnotation(new XMLNode(*innerChild));
                }
                else if(innerChildName=="notes")
                {
                    list.setNotes(new XMLNode(*innerChild));
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

  connectToChild();
}

/*
 * Copy constructor.
 */
GeneralGlyph::GeneralGlyph(const GeneralGlyph& source):GraphicalObject(source)
{
    this->mReference=source.getReferenceId();
    this->mCurve=*source.getCurve();
    this->mReferenceGlyphs=*source.getListOfReferenceGlyphs();
    this->mSubGlyphs=*source.getListOfSubGlyphs();
    this->mCurveExplicitlySet = source.mCurveExplicitlySet;

    connectToChild();
}

/*
 * Assignment operator.
 */
GeneralGlyph& GeneralGlyph::operator=(const GeneralGlyph& source)
{
  if(&source!=this)
  {
    GraphicalObject::operator=(source);
    this->mReference=source.mReference;
    this->mCurve=*source.getCurve();
    this->mReferenceGlyphs=*source.getListOfReferenceGlyphs();
    this->mSubGlyphs=*source.getListOfSubGlyphs();
    this->mCurveExplicitlySet = source.mCurveExplicitlySet;
    connectToChild();
  }
  
  return *this;
}



/*
 * Destructor.
 */ 
GeneralGlyph::~GeneralGlyph ()
{
} 


/*
 * Returns the id of the associated reaction.
 */  
const std::string&
GeneralGlyph::getReferenceId () const
{
  return this->mReference;
}


/*
 * Sets the id of the associated reaction.
 */ 
int
GeneralGlyph::setReferenceId (const std::string& id)
{
  if (!(SyntaxChecker::isValidInternalSId(id)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mReference = id;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Returns true if the id of the associated reaction is not the empty
 * string.
 */ 
bool
GeneralGlyph::isSetReferenceId() const
{
  return ! this->mReference.empty();
}


/*
 * Returns the ListOf object that hold the reference glyphs.
 */  
const ListOfReferenceGlyphs*
GeneralGlyph::getListOfReferenceGlyphs () const
{
  return &this->mReferenceGlyphs;
}


/*
 * Returns the ListOf object that hold the reference glyphs.
 */  
ListOfReferenceGlyphs*
GeneralGlyph::getListOfReferenceGlyphs ()
{
  return &this->mReferenceGlyphs;
}

/*
 * Returns the ListOf object that hold the subglyphs.
 */  
const ListOfGraphicalObjects*
GeneralGlyph::getListOfSubGlyphs () const
{
  return &this->mSubGlyphs;
}


/*
 * Returns the ListOf object that hold the subglyphs.
 */  
ListOfGraphicalObjects*
GeneralGlyph::getListOfSubGlyphs ()
{
  return &this->mSubGlyphs;
}


/*
 * Returns the reference glyph with the given index.  If the index
 * is invalid, @c NULL is returned.
 */ 
ReferenceGlyph*
GeneralGlyph::getReferenceGlyph (unsigned int index) 
{
  return static_cast<ReferenceGlyph*>
  (
    this->mReferenceGlyphs.get(index)
  );
}


/*
 * Returns the reference glyph with the given index.  If the index
 * is invalid, @c NULL is returned.
 */ 
const ReferenceGlyph*
GeneralGlyph::getReferenceGlyph (unsigned int index) const
{
  return static_cast<const ReferenceGlyph*>
  (
    this->mReferenceGlyphs.get(index)
  );
}

/*
 * Returns the reference glyph with the given index.  If the index
 * is invalid, @c NULL is returned.
 */ 
GraphicalObject*
GeneralGlyph::getSubGlyph (unsigned int index) 
{
  return static_cast<GraphicalObject*>
  (
    this->mSubGlyphs.get(index)
  );
}


/*
 * Returns the reference glyph with the given index.  If the index
 * is invalid, @c NULL is returned.
 */ 
const GraphicalObject*
GeneralGlyph::getSubGlyph (unsigned int index) const
{
  return static_cast<const GraphicalObject*>
  (
    this->mSubGlyphs.get(index)
  );
}

/*
 * Adds a new reference glyph to the list.
 */
void
GeneralGlyph::addReferenceGlyph (const ReferenceGlyph* glyph)
{
  this->mReferenceGlyphs.append(glyph);
}

/*
 * Adds a new subglyph to the list.
 */
void
  GeneralGlyph::addSubGlyph (const GraphicalObject* glyph)
{
  this->mSubGlyphs.append(glyph);
}


/*
 * Returns the number of reference glyph objects.
 */ 
unsigned int
GeneralGlyph::getNumReferenceGlyphs () const
{
  return this->mReferenceGlyphs.size();
}


/*
 * Returns the number of subglyph objects.
 */ 
unsigned int
GeneralGlyph::getNumSubGlyphs () const
{
  return this->mSubGlyphs.size();
}

/*
 * Calls initDefaults from GraphicalObject.
 */ 
void GeneralGlyph::initDefaults ()
{
  GraphicalObject::initDefaults();
}


/*
 * Returns the curve object for the glyph
 */ 
const Curve*
GeneralGlyph::getCurve () const
{
  return &this->mCurve;
}

/*
 * Returns the curve object for the glyph
 */ 
Curve*
GeneralGlyph::getCurve () 
{
  return &this->mCurve;
}


/*
 * Sets the curve object for the reaction glyph.
 */ 
void GeneralGlyph::setCurve (const Curve* curve)
{
  if(!curve) return;
  this->mCurve = *curve;
  this->mCurve.connectToParent(this);
  mCurveExplicitlySet = true;
}


/*
 * Returns true if the curve consists of one or more segments.
 */ 
bool GeneralGlyph::isSetCurve () const
{
  return this->mCurve.getNumCurveSegments() > 0;
}


bool
GeneralGlyph::getCurveExplicitlySet() const
{
  return mCurveExplicitlySet;
}


/*
 * Creates a new ReferenceGlyph object, adds it to the end of the
 * list of reference objects and returns a reference to the newly
 * created object.
 */
ReferenceGlyph*
GeneralGlyph::createReferenceGlyph ()
{
  LAYOUT_CREATE_NS(layoutns,getSBMLNamespaces());
  ReferenceGlyph* srg = new ReferenceGlyph(layoutns);

  this->mReferenceGlyphs.appendAndOwn(srg);
  delete layoutns;
  return srg;
}


/*
 * Creates a new LineSegment object, adds it to the end of the list of
 * curve segment objects of the curve and returns a reference to the newly
 * created object.
 */
LineSegment*
GeneralGlyph::createLineSegment ()
{
  return this->mCurve.createLineSegment();
}

 
/*
 * Creates a new CubicBezier object, adds it to the end of the list of
 * curve segment objects of the curve and returns a reference to the newly
 * created object.
 */
CubicBezier*
GeneralGlyph::createCubicBezier ()
{
  return this->mCurve.createCubicBezier();
}

/*
 * Remove the reference glyph with the given index.
 * A pointer to the object is returned. If no object has been removed, NULL
 * is returned.
 */
ReferenceGlyph*
GeneralGlyph::removeReferenceGlyph(unsigned int index)
{
    ReferenceGlyph* srg=NULL;
    if(index < this->getNumReferenceGlyphs())
    {
        srg=dynamic_cast<ReferenceGlyph*>(this->getListOfReferenceGlyphs()->remove(index));
    }
    return srg;
}

/*
 * Remove the reference glyph with the given @p id.
 * A pointer to the object is returned. If no object has been removed, NULL
 * is returned.
 */
ReferenceGlyph*
GeneralGlyph::removeReferenceGlyph(const std::string& id)
{
    ReferenceGlyph* srg=NULL;
    unsigned int index=this->getIndexForReferenceGlyph(id);
    if(index!=std::numeric_limits<unsigned int>::max())
    {
        srg=this->removeReferenceGlyph(index);
    }
    return srg;
}


/*
 * Remove the subglyph with the given index.
 * A pointer to the object is returned. If no object has been removed, NULL
 * is returned.
 */
GraphicalObject*
GeneralGlyph::removeSubGlyph(unsigned int index)
{
    GraphicalObject* srg=NULL;
    if(index < this->getNumSubGlyphs())
    {
        srg=dynamic_cast<GraphicalObject*>(this->getListOfSubGlyphs()->remove(index));
    }
    return srg;
}

/*
 * Remove the subglyph with the given @p id.
 * A pointer to the object is returned. If no object has been removed, NULL
 * is returned.
 */
GraphicalObject*
GeneralGlyph::removeSubGlyph(const std::string& id)
{
    GraphicalObject* srg=NULL;
    unsigned int index=this->getIndexForSubGlyph(id);
    if(index!=std::numeric_limits<unsigned int>::max())
    {
        srg=this->removeSubGlyph(index);
    }
    return srg;
}

/*
 * Returns the index of the reference glyph with the given @p id.
 * If the reaction glyph does not contain a reference glyph with this
 * id, numreic_limits<int>::max() is returned.
 */
unsigned int
GeneralGlyph::getIndexForReferenceGlyph(const std::string& id) const
{
    unsigned int i,iMax=this->getNumReferenceGlyphs();
    unsigned int index=std::numeric_limits<unsigned int>::max();
    for(i=0;i<iMax;++i)
    {
        const ReferenceGlyph* srg=this->getReferenceGlyph(i);
        if(srg->getId()==id)
        {
            index=i;
            break;
        }
    }
    return index;
}



/*
 * Returns the index of the subglyph with the given @p id.
 * If the reaction glyph does not contain a subglyph with this
 * id, numreic_limits<int>::max() is returned.
 */
unsigned int
GeneralGlyph::getIndexForSubGlyph(const std::string& id) const
{
    unsigned int i,iMax=this->getNumSubGlyphs();
    unsigned int index=std::numeric_limits<unsigned int>::max();
    for(i=0;i<iMax;++i)
    {
      const GraphicalObject* srg=this->getSubGlyph(i);
        if(srg->getId()==id)
        {
            index=i;
            break;
        }
    }
    return index;
}


/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string& GeneralGlyph::getElementName () const 
{
  static const std::string name = "generalGlyph";
  return name;
}

/*
 * @return a (deep) copy of this GeneralGlyph.
 */
GeneralGlyph* 
GeneralGlyph::clone () const
{
    return new GeneralGlyph(*this);
}


/** @cond doxygenLibsbmlInternal */
SBase*
GeneralGlyph::createObject (XMLInputStream& stream)
{
  const std::string& name   = stream.peek().getName();
  
  SBase*        object = 0;

  if (name == "listOfReferenceGlyphs")
  {
    if (mReferenceGlyphs.size() != 0)
    {
      getErrorLog()->logPackageError("layout", LayoutGGAllowedElements, 
        getPackageVersion(), getLevel(), getVersion());
    }

    object = &mReferenceGlyphs;
  }
  else if (name == "listOfSubGlyphs")
  {
    if (mSubGlyphs.size() != 0)
    {
      getErrorLog()->logPackageError("layout", LayoutGGAllowedElements, 
        getPackageVersion(), getLevel(), getVersion());
    }

    object = &mSubGlyphs;
  }
  else if(name=="curve")
  {
    if (getCurveExplicitlySet() == true)
    {
      getErrorLog()->logPackageError("layout", LayoutGGAllowedElements, 
        getPackageVersion(), getLevel(), getVersion());
    }

    object = &mCurve;
    mCurveExplicitlySet = true;
  }
  else
  {
    object=GraphicalObject::createObject(stream);
  }
  
  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
GeneralGlyph::addExpectedAttributes(ExpectedAttributes& attributes)
{
  GraphicalObject::addExpectedAttributes(attributes);

  attributes.add("reference");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void GeneralGlyph::readAttributes (const XMLAttributes& attributes,
                                    const ExpectedAttributes& expectedAttributes)
{
	const unsigned int sbmlLevel   = getLevel  ();
	const unsigned int sbmlVersion = getVersion();

	unsigned int numErrs;

	/* look to see whether an unknown attribute error was logged
	 * during the read of the listOfAdditionalGraphicalObjects - which will have
	 * happened immediately prior to this read
	*/

  bool loSubGlyphs = false;
  if (getParentSBMLObject() != NULL
    && getParentSBMLObject()->getElementName() == "listOfSubGlyphs")
  {
    loSubGlyphs = true;
  }

	if (getErrorLog() != NULL &&
	    static_cast<ListOfGraphicalObjects*>(getParentSBMLObject())->size() < 2)
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
                                    LayoutLOAddGOAllowedAttribut,
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
                                    LayoutLOAddGOAllowedAttribut,
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
				getErrorLog()->logPackageError("layout", LayoutGGAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				                  getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
				getErrorLog()->logPackageError("layout", LayoutGGAllowedCoreAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
		}
	}

	bool assigned = false;

	//
	// reference SIdRef   ( use = "optional" )
	//
	assigned = attributes.readInto("reference", mReference);

	if (assigned == true)
	{
		// check string is not empty and correct syntax

		if (mReference.empty() == true)
		{
			logEmptyString(mReference, getLevel(), getVersion(), "<GeneralGlyph>");
		}
		else if (SyntaxChecker::isValidSBMLSId(mReference) == false)
		{
			getErrorLog()->logPackageError("layout", LayoutGGReferenceSyntax,
				             getPackageVersion(), sbmlLevel, sbmlVersion);
		}
	}


}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
GeneralGlyph::writeElements (XMLOutputStream& stream) const
{
  GraphicalObject::writeElements(stream);
  if(this->isSetCurve())
  {
    mCurve.write(stream);
  }
 
  if ( getNumReferenceGlyphs() > 0 ) mReferenceGlyphs.write(stream);
  if ( getNumSubGlyphs() > 0 ) mSubGlyphs.write(stream);
 
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void GeneralGlyph::writeAttributes (XMLOutputStream& stream) const
{
  GraphicalObject::writeAttributes(stream);
  if(this->isSetReferenceId())
  {
    stream.writeAttribute("reference", getPrefix(), mReference);
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
GeneralGlyph::getTypeCode () const
{
  return SBML_LAYOUT_GENERALGLYPH;
}


/*
 * Creates an XMLNode object from this.
 */
XMLNode GeneralGlyph::toXML() const
{
   return getXmlNodeForSBase(this);
}



/*
 * Ctor.
 */
ListOfReferenceGlyphs::ListOfReferenceGlyphs(unsigned int level, unsigned int version, unsigned int pkgVersion)
 : ListOf(level,version)
{
  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));
};


/*
 * Ctor.
 */
ListOfReferenceGlyphs::ListOfReferenceGlyphs(LayoutPkgNamespaces* layoutns)
 : ListOf(layoutns)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());
}


/*
 * @return a (deep) copy of this ListOfReferenceGlyphs.
 */
ListOfReferenceGlyphs*
ListOfReferenceGlyphs::clone () const
{
  return new ListOfReferenceGlyphs(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfReferenceGlyphs::getItemTypeCode () const
{
  return SBML_LAYOUT_REFERENCEGLYPH;
}


/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string&
ListOfReferenceGlyphs::getElementName () const
{
  static const std::string name = "listOfReferenceGlyphs";
  return name;
}


/* return nth item in list */
ReferenceGlyph *
ListOfReferenceGlyphs::get(unsigned int n)
{
  return static_cast<ReferenceGlyph*>(ListOf::get(n));
}


/* return nth item in list */
const ReferenceGlyph *
ListOfReferenceGlyphs::get(unsigned int n) const
{
  return static_cast<const ReferenceGlyph*>(ListOf::get(n));
}


/* return item by id */
ReferenceGlyph*
ListOfReferenceGlyphs::get (const std::string& sid)
{
  return const_cast<ReferenceGlyph*>( 
    static_cast<const ListOfReferenceGlyphs&>(*this).get(sid) );
}


/* return item by id */
const ReferenceGlyph*
ListOfReferenceGlyphs::get (const std::string& sid) const
{
  std::vector<SBase*>::const_iterator result;

  result = std::find_if( mItems.begin(), mItems.end(), IdEq<ReferenceGlyph>(sid) );
  return (result == mItems.end()) ? 0 : static_cast <ReferenceGlyph*> (*result);
}


/* Removes the nth item from this list */
ReferenceGlyph*
ListOfReferenceGlyphs::remove (unsigned int n)
{
   return static_cast<ReferenceGlyph*>(ListOf::remove(n));
}


/* Removes item in this list by id */
ReferenceGlyph*
ListOfReferenceGlyphs::remove (const std::string& sid)
{
  SBase* item = 0;
  std::vector<SBase*>::iterator result;

  result = std::find_if( mItems.begin(), mItems.end(), IdEq<ReferenceGlyph>(sid) );

  if (result != mItems.end())
  {
    item = *result;
    mItems.erase(result);
  }

  return static_cast <ReferenceGlyph*> (item);
}


/** @cond doxygenLibsbmlInternal */
SBase*
ListOfReferenceGlyphs::createObject (XMLInputStream& stream)
{
  const std::string& name   = stream.peek().getName();
  SBase*             object = NULL;


  if (name == "referenceGlyph")
  {
    LAYOUT_CREATE_NS(layoutns,this->getSBMLNamespaces());
    object = new ReferenceGlyph(layoutns);
    appendAndOwn(object);
    delete layoutns;
  }

  return object;
}
/** @endcond */

/*
 * Creates an XMLNode object from this.
 */
XMLNode ListOfReferenceGlyphs::toXML() const
{
  return getXmlNodeForSBase(this);
}



/*
 * Accepts the given SBMLVisitor.
 */
bool
GeneralGlyph::accept (SBMLVisitor& v) const
{
  v.visit(*this);
  
  if(getCurveExplicitlySet() == true)
  {
    this->mCurve.accept(v);
  }
  
  if (getBoundingBoxExplicitlySet() == true)
  {
    this->mBoundingBox.accept(v);
  }
  
  this->mReferenceGlyphs.accept(v);
  
  v.leave(*this);
  
  return true;
}



/** @cond doxygenLibsbmlInternal */
/*
 * Sets the parent SBMLDocument of this SBML object.
 */
void
GeneralGlyph::setSBMLDocument (SBMLDocument* d)
{
  GraphicalObject::setSBMLDocument(d);

  mReferenceGlyphs.setSBMLDocument(d);
  mSubGlyphs.setSBMLDocument(d);
  mCurve.setSBMLDocument(d);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Sets this SBML object to child SBML objects (if any).
 * (Creates a child-parent relationship by the parent)
 */
void
GeneralGlyph::connectToChild()
{
  GraphicalObject::connectToChild();
  mReferenceGlyphs.connectToParent(this);
  mCurve.connectToParent(this);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Enables/Disables the given package with this element and child
 * elements (if any).
 * (This is an internal implementation for enablePakcage function)
 */
void
GeneralGlyph::enablePackageInternal(const std::string& pkgURI,
                                     const std::string& pkgPrefix, bool flag)
{
  SBase::enablePackageInternal(pkgURI,pkgPrefix,flag);

  mReferenceGlyphs.enablePackageInternal(pkgURI,pkgPrefix,flag);
  mSubGlyphs.enablePackageInternal(pkgURI,pkgPrefix,flag);
  mCurve.enablePackageInternal(pkgURI,pkgPrefix,flag);
}
/** @endcond */



#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
GeneralGlyph_t *
GeneralGlyph_create (void)
{
  return new(std::nothrow) GeneralGlyph;
}


LIBSBML_EXTERN
GeneralGlyph_t *
GeneralGlyph_createWith (const char *sid)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) GeneralGlyph(&layoutns, sid ? sid : "", "");
}


LIBSBML_EXTERN
GeneralGlyph_t *
GeneralGlyph_createWithReferenceId (const char *id, const char *referenceId)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) GeneralGlyph(&layoutns, id ? id : "", referenceId ? referenceId : "");
}


LIBSBML_EXTERN
GeneralGlyph_t *
GeneralGlyph_createFrom (const GeneralGlyph_t *temp)
{
  return new(std::nothrow) GeneralGlyph(*temp);
}


LIBSBML_EXTERN
void
GeneralGlyph_free (GeneralGlyph_t *rg)
{
  delete rg;
}


LIBSBML_EXTERN
void
GeneralGlyph_setReferenceId (GeneralGlyph_t *rg,const char *id)
{
  if (rg == NULL) return;
  static_cast<GeneralGlyph*>(rg)->setReferenceId( id ? id : "" );
}


LIBSBML_EXTERN
const char *
GeneralGlyph_getReferenceId (const GeneralGlyph_t *rg)
{
  if (rg == NULL) return NULL;
  return rg->isSetReferenceId() ? rg->getReferenceId().c_str() : NULL;
}


LIBSBML_EXTERN
int
GeneralGlyph_isSetReferenceId (const GeneralGlyph_t *rg)
{
  if (rg == NULL) return (int)false;
  return static_cast<int>( rg->isSetReferenceId() );
}


LIBSBML_EXTERN
void
GeneralGlyph_addReferenceGlyph (GeneralGlyph_t         *rg,
                                        ReferenceGlyph_t *srg)
{
  if (rg == NULL) return;
  rg->addReferenceGlyph(srg);
}


LIBSBML_EXTERN
unsigned int
GeneralGlyph_getNumReferenceGlyphs (const GeneralGlyph_t *rg)
{
  if (rg == NULL) return 0;
  return rg->getNumReferenceGlyphs();
}


LIBSBML_EXTERN
ReferenceGlyph_t *
GeneralGlyph_getReferenceGlyph (GeneralGlyph_t *rg,
                                        unsigned int           index)
{
  if (rg == NULL) return  NULL;
  return rg->getReferenceGlyph(index);
}


LIBSBML_EXTERN
ListOf_t *
GeneralGlyph_getListOfReferenceGlyphs (GeneralGlyph_t *rg)
{
  if (rg == NULL) return NULL;
  return rg->getListOfReferenceGlyphs();
}


LIBSBML_EXTERN
void
GeneralGlyph_initDefaults (GeneralGlyph_t *rg)
{
  if (rg == NULL) return;
  rg->initDefaults();
}


LIBSBML_EXTERN
void
GeneralGlyph_setCurve (GeneralGlyph_t *rg, Curve_t *c)
{
  if (rg == NULL) return;
  rg->setCurve(c);
}


LIBSBML_EXTERN
Curve_t *
GeneralGlyph_getCurve (GeneralGlyph_t *rg)
{
  if (rg == NULL) return NULL;
  return rg->getCurve();
}


LIBSBML_EXTERN
int
GeneralGlyph_isSetCurve (GeneralGlyph_t *rg)
{
  if (rg == NULL) return (int)false;
  return static_cast<int>( rg->isSetCurve() );
}


LIBSBML_EXTERN
ReferenceGlyph_t *
GeneralGlyph_createReferenceGlyph (GeneralGlyph_t *rg)
{
  if (rg == NULL) return NULL;
  return rg->createReferenceGlyph();
}


LIBSBML_EXTERN
LineSegment_t *
GeneralGlyph_createLineSegment (GeneralGlyph_t *rg)
{
  if (rg == NULL) return NULL;
  return rg->getCurve()->createLineSegment();
}


LIBSBML_EXTERN
CubicBezier_t *
GeneralGlyph_createCubicBezier (GeneralGlyph_t *rg)
{
  if (rg == NULL) return NULL;
  return rg->getCurve()->createCubicBezier();
}


LIBSBML_EXTERN
ReferenceGlyph_t*
GeneralGlyph_removeReferenceGlyph(GeneralGlyph_t* rg,unsigned int index)
{
  if (rg == NULL) return NULL;
  return rg->removeReferenceGlyph(index);
}

LIBSBML_EXTERN
ReferenceGlyph_t*
GeneralGlyph_removeReferenceGlyphWithId(GeneralGlyph_t* rg,const char* id)
{
  if (rg == NULL) return NULL;
  return rg->removeReferenceGlyph(id);
}

LIBSBML_EXTERN
unsigned int
GeneralGlyph_getIndexForReferenceGlyph(GeneralGlyph_t* rg,const char* id)
{
  if (rg == NULL) return 0;
  return rg->getIndexForReferenceGlyph(id);
}

LIBSBML_EXTERN
GeneralGlyph_t *
GeneralGlyph_clone (const GeneralGlyph_t *m)
{
  if (m == NULL) return NULL;
  return static_cast<GeneralGlyph*>( m->clone() );
}


/** @endcond */
LIBSBML_CPP_NAMESPACE_END
