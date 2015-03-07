/**
 * @file    ReactionGlyph.cpp
 * @brief   Implementation of ReactionGlyph for SBML Layout.
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
#include <sbml/packages/layout/sbml/ReactionGlyph.h>
#include <sbml/packages/layout/sbml/SpeciesReferenceGlyph.h>
#include <sbml/packages/layout/util/LayoutUtilities.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>
#include <sbml/packages/layout/sbml/Layout.h>
#include <sbml/packages/layout/validator/LayoutSBMLError.h>

#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/util/ElementFilter.h>


LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus


List*
ReactionGlyph::getAllElements(ElementFilter *filter)
{
  List* ret = GraphicalObject::getAllElements(filter);
  List* sublist = NULL;

  ADD_FILTERED_LIST(ret, sublist, mSpeciesReferenceGlyphs, filter);  
  ADD_FILTERED_ELEMENT(ret, sublist, mCurve, filter);  

  return ret;
}

void
ReactionGlyph::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  GraphicalObject::renameSIdRefs(oldid, newid);
  if (isSetReactionId() && mReaction == oldid) {
    mReaction = newid;
  }
}


/*
 * Creates a new ReactionGlyph.  The list of species reference glyph is
 * empty and the id of the associated reaction is set to the empty string.
 */
ReactionGlyph::ReactionGlyph(unsigned int level, unsigned int version, unsigned int pkgVersion) 
 : GraphicalObject (level,version,pkgVersion)
  ,mReaction("")
  ,mSpeciesReferenceGlyphs(level,version,pkgVersion)
  ,mCurve(level,version,pkgVersion)
  ,mCurveExplicitlySet (false)
{
  connectToChild();
  //
  // (NOTE) Developers don't have to invoke setSBMLNamespacesAndOwn function as follows (commentted line)
  //        in this constuctor because the function is properly invoked in the constructor of the
  //        base class (GraphicalObject).
  //
  //setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));  
}


/*
 * Creates a new ReactionGlyph with the given LayoutPkgNamespaces
 */
ReactionGlyph::ReactionGlyph(LayoutPkgNamespaces* layoutns)
 : GraphicalObject (layoutns)
  ,mReaction("")
  ,mSpeciesReferenceGlyphs(layoutns)
  ,mCurve(layoutns)
  , mCurveExplicitlySet ( false )
{
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
 * Creates a ReactionGlyph with the given @p id.
 */
ReactionGlyph::ReactionGlyph (LayoutPkgNamespaces* layoutns, const std::string& id)
  : GraphicalObject(layoutns, id)
   ,mReaction("")
   ,mSpeciesReferenceGlyphs(layoutns)
   ,mCurve(layoutns)
   ,mCurveExplicitlySet (false)
{
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
 * Creates a ReactionGlyph with the given @p id and set the id of the
 * associated reaction to the second argument.
 */
ReactionGlyph::ReactionGlyph (LayoutPkgNamespaces* layoutns, const std::string& id,
                              const std::string& reactionId) 
  : GraphicalObject( layoutns, id  )
   ,mReaction      ( reactionId  )
   ,mSpeciesReferenceGlyphs(layoutns)
   ,mCurve(layoutns)
   , mCurveExplicitlySet (false)
{
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
 * Creates a new ReactionGlyph from the given XMLNode
 */
ReactionGlyph::ReactionGlyph(const XMLNode& node, unsigned int l2version)
  : GraphicalObject(node,l2version)
   ,mReaction      ("")
   ,mSpeciesReferenceGlyphs(2,l2version)
   ,mCurve(2,l2version)
   ,mCurveExplicitlySet (false)
{
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
            if(pTmpCurve->isSetNotes()) this->mCurve.setNotes(pTmpCurve->getNotes());
            if(pTmpCurve->isSetAnnotation()) this->mCurve.setAnnotation(pTmpCurve->getAnnotation());
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
        else if(childName=="listOfSpeciesReferenceGlyphs")
        {
            const XMLNode* innerChild;
            unsigned int i=0,iMax=child->getNumChildren();
            while(i<iMax)
            {
                innerChild=&child->getChild(i);
                const std::string innerChildName=innerChild->getName();
                if(innerChildName=="speciesReferenceGlyph")
                {
                    this->mSpeciesReferenceGlyphs.appendAndOwn(new SpeciesReferenceGlyph(*innerChild));
                }
                else if(innerChildName=="annotation")
                {
                    this->mSpeciesReferenceGlyphs.setAnnotation(new XMLNode(*innerChild));
                }
                else if(innerChildName=="notes")
                {
                    this->mSpeciesReferenceGlyphs.setNotes(new XMLNode(*innerChild));
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
ReactionGlyph::ReactionGlyph(const ReactionGlyph& source):GraphicalObject(source)
{
    this->mReaction=source.getReactionId();
    this->mCurve=*source.getCurve();
    this->mSpeciesReferenceGlyphs=*source.getListOfSpeciesReferenceGlyphs();
    this->mCurveExplicitlySet = source.mCurveExplicitlySet;

    connectToChild();
}

/*
 * Assignment operator.
 */
ReactionGlyph& ReactionGlyph::operator=(const ReactionGlyph& source)
{
  if(&source!=this)
  {
    GraphicalObject::operator=(source);
    this->mReaction=source.getReactionId();
    this->mCurve=*source.getCurve();
    this->mSpeciesReferenceGlyphs=*source.getListOfSpeciesReferenceGlyphs();
    this->mCurveExplicitlySet = source.mCurveExplicitlySet;
    connectToChild();
  }
  
  return *this;
}



/*
 * Destructor.
 */ 
ReactionGlyph::~ReactionGlyph ()
{
} 


/*
 * Returns the id of the associated reaction.
 */  
const std::string&
ReactionGlyph::getReactionId () const
{
  return this->mReaction;
}


/*
 * Sets the id of the associated reaction.
 */ 
int
ReactionGlyph::setReactionId (const std::string& id)
{
  if (!(SyntaxChecker::isValidInternalSId(id)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mReaction = id;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Returns true if the id of the associated reaction is not the empty
 * string.
 */ 
bool
ReactionGlyph::isSetReactionId() const
{
  return ! this->mReaction.empty();
}


/*
 * Returns the ListOf object that hold the species reference glyphs.
 */  
const ListOfSpeciesReferenceGlyphs*
ReactionGlyph::getListOfSpeciesReferenceGlyphs () const
{
  return &this->mSpeciesReferenceGlyphs;
}


/*
 * Returns the ListOf object that hold the species reference glyphs.
 */  
ListOfSpeciesReferenceGlyphs*
ReactionGlyph::getListOfSpeciesReferenceGlyphs ()
{
  return &this->mSpeciesReferenceGlyphs;
}

/*
 * Returns the species reference glyph with the given index.  If the index
 * is invalid, @c NULL is returned.
 */ 
SpeciesReferenceGlyph*
ReactionGlyph::getSpeciesReferenceGlyph (unsigned int index) 
{
  return static_cast<SpeciesReferenceGlyph*>
  (
    this->mSpeciesReferenceGlyphs.get(index)
  );
}


/*
 * Returns the species reference glyph with the given index.  If the index
 * is invalid, @c NULL is returned.
 */ 
const SpeciesReferenceGlyph*
ReactionGlyph::getSpeciesReferenceGlyph (unsigned int index) const
{
  return static_cast<const SpeciesReferenceGlyph*>
  (
    this->mSpeciesReferenceGlyphs.get(index)
  );
}


/*
 * Adds a new species reference glyph to the list.
 */
void
ReactionGlyph::addSpeciesReferenceGlyph (const SpeciesReferenceGlyph* glyph)
{
  this->mSpeciesReferenceGlyphs.append(glyph);
}


/*
 * Returns the number of species reference glyph objects.
 */ 
unsigned int
ReactionGlyph::getNumSpeciesReferenceGlyphs () const
{
  return this->mSpeciesReferenceGlyphs.size();
}


/*
 * Calls initDefaults from GraphicalObject.
 */ 
void ReactionGlyph::initDefaults ()
{
  GraphicalObject::initDefaults();
}


/*
 * Returns the curve object for the reaction glyph
 */ 
const Curve*
ReactionGlyph::getCurve () const
{
  return &this->mCurve;
}

/*
 * Returns the curve object for the reaction glyph
 */ 
Curve*
ReactionGlyph::getCurve () 
{
  return &this->mCurve;
}


/*
 * Sets the curve object for the reaction glyph.
 */ 
void ReactionGlyph::setCurve (const Curve* curve)
{
  if(!curve) return;
  this->mCurve = *curve;
  this->mCurve.connectToParent(this);
  mCurveExplicitlySet = true;
}


/*
 * Returns true if the curve consists of one or more segments.
 */ 
bool ReactionGlyph::isSetCurve () const
{
  return this->mCurve.getNumCurveSegments() > 0;
}


bool
ReactionGlyph::getCurveExplicitlySet() const
{
  return mCurveExplicitlySet;
}


/*
 * Creates a new SpeciesReferenceGlyph object, adds it to the end of the
 * list of species reference objects and returns a reference to the newly
 * created object.
 */
SpeciesReferenceGlyph*
ReactionGlyph::createSpeciesReferenceGlyph ()
{
  LAYOUT_CREATE_NS(layoutns,getSBMLNamespaces());
  SpeciesReferenceGlyph* srg = new SpeciesReferenceGlyph(layoutns);

  this->mSpeciesReferenceGlyphs.appendAndOwn(srg);
  delete layoutns;
  return srg;
}


/*
 * Creates a new LineSegment object, adds it to the end of the list of
 * curve segment objects of the curve and returns a reference to the newly
 * created object.
 */
LineSegment*
ReactionGlyph::createLineSegment ()
{
  return this->mCurve.createLineSegment();
}

 
/*
 * Creates a new CubicBezier object, adds it to the end of the list of
 * curve segment objects of the curve and returns a reference to the newly
 * created object.
 */
CubicBezier*
ReactionGlyph::createCubicBezier ()
{
  return this->mCurve.createCubicBezier();
}

/*
 * Remove the species reference glyph with the given index.
 * A pointer to the object is returned. If no object has been removed, NULL
 * is returned.
 */
SpeciesReferenceGlyph*
ReactionGlyph::removeSpeciesReferenceGlyph(unsigned int index)
{
    SpeciesReferenceGlyph* srg=NULL;
    if(index < this->getNumSpeciesReferenceGlyphs())
    {
        srg=dynamic_cast<SpeciesReferenceGlyph*>(this->getListOfSpeciesReferenceGlyphs()->remove(index));
    }
    return srg;
}

/*
 * Remove the species reference glyph with the given @p id.
 * A pointer to the object is returned. If no object has been removed, NULL
 * is returned.
 */
SpeciesReferenceGlyph*
ReactionGlyph::removeSpeciesReferenceGlyph(const std::string& id)
{
    SpeciesReferenceGlyph* srg=NULL;
    unsigned int index=this->getIndexForSpeciesReferenceGlyph(id);
    if(index!=std::numeric_limits<unsigned int>::max())
    {
        srg=this->removeSpeciesReferenceGlyph(index);
    }
    return srg;
}

/*
 * Returns the index of the species reference glyph with the given @p id.
 * If the reaction glyph does not contain a species reference glyph with this
 * id, numreic_limits<int>::max() is returned.
 */
unsigned int
ReactionGlyph::getIndexForSpeciesReferenceGlyph(const std::string& id) const
{
    unsigned int i,iMax=this->getNumSpeciesReferenceGlyphs();
    unsigned int index=std::numeric_limits<unsigned int>::max();
    for(i=0;i<iMax;++i)
    {
        const SpeciesReferenceGlyph* srg=this->getSpeciesReferenceGlyph(i);
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
const std::string& ReactionGlyph::getElementName () const 
{
  static const std::string name = "reactionGlyph";
  return name;
}

/*
 * @return a (deep) copy of this ReactionGlyph.
 */
ReactionGlyph* 
ReactionGlyph::clone () const
{
    return new ReactionGlyph(*this);
}


/** @cond doxygenLibsbmlInternal */
SBase*
ReactionGlyph::createObject (XMLInputStream& stream)
{
  const std::string& name   = stream.peek().getName();
  
  SBase*        object = 0;

  if (name == "listOfSpeciesReferenceGlyphs")
  {
    if (mSpeciesReferenceGlyphs.size() != 0)
    {
      getErrorLog()->logPackageError("layout", LayoutRGAllowedElements, 
        getPackageVersion(), getLevel(), getVersion());
    }

    object = &mSpeciesReferenceGlyphs;
  }
  else if(name=="curve")
  {
    if (getCurveExplicitlySet() == true)
    {
      getErrorLog()->logPackageError("layout", LayoutRGAllowedElements, 
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
ReactionGlyph::addExpectedAttributes(ExpectedAttributes& attributes)
{
  GraphicalObject::addExpectedAttributes(attributes);

  attributes.add("reaction");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void ReactionGlyph::readAttributes (const XMLAttributes& attributes,
                                    const ExpectedAttributes& expectedAttributes)
{
	const unsigned int sbmlLevel   = getLevel  ();
	const unsigned int sbmlVersion = getVersion();

	unsigned int numErrs;

	/* look to see whether an unknown attribute error was logged
	 * during the read of the listOfReactionGlyphs - which will have
	 * happened immediately prior to this read
	*/

  bool loSubGlyphs = false;
  if (getParentSBMLObject() != NULL
    && getParentSBMLObject()->getElementName() == "listOfSubGlyphs")
  {
    loSubGlyphs = true;
  }

	if (getErrorLog() != NULL &&
	    static_cast<ListOfReactionGlyphs*>(getParentSBMLObject())->size() < 2)
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
                                    LayoutLORnGlyphAllowedAttributes,
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
                                    LayoutLORnGlyphAllowedAttributes,
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
				getErrorLog()->logPackageError("layout", LayoutRGAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				                  getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
				getErrorLog()->logPackageError("layout", LayoutRGAllowedCoreAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
		}
	}

	bool assigned = false;

	//
	// reaction SIdRef   ( use = "optional" )
	//
	assigned = attributes.readInto("reaction", mReaction);

	if (assigned == true && getErrorLog() != NULL)
	{
		// check string is not empty and correct syntax

		if (mReaction.empty() == true)
		{
			logEmptyString(mReaction, getLevel(), getVersion(), "<ReactionGlyph>");
		}
		else if (SyntaxChecker::isValidSBMLSId(mReaction) == false)
		{
			getErrorLog()->logPackageError("layout", LayoutRGReactionSyntax,
				             getPackageVersion(), sbmlLevel, sbmlVersion);
		}
	}

}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
ReactionGlyph::writeElements (XMLOutputStream& stream) const
{
  if(this->isSetCurve())
  {
    SBase::writeElements(stream);
    mCurve.write(stream);
    //
    // BoundingBox is to be ignored if a curve element defined.
    //
  }
  else
  {
    //
    // SBase::writeElements(stream) is invoked in the function below.
    //
    GraphicalObject::writeElements(stream);
  }

  if ( getNumSpeciesReferenceGlyphs() > 0 ) mSpeciesReferenceGlyphs.write(stream);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void ReactionGlyph::writeAttributes (XMLOutputStream& stream) const
{
  GraphicalObject::writeAttributes(stream);
  if(this->isSetReactionId())
  {
    stream.writeAttribute("reaction", getPrefix(), mReaction);
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
ReactionGlyph::getTypeCode () const
{
  return SBML_LAYOUT_REACTIONGLYPH;
}


/*
 * Creates an XMLNode object from this.
 */
XMLNode ReactionGlyph::toXML() const
{
  return getXmlNodeForSBase(this);
}



/*
 * Ctor.
 */
ListOfSpeciesReferenceGlyphs::ListOfSpeciesReferenceGlyphs(unsigned int level, unsigned int version, unsigned int pkgVersion)
 : ListOf(level,version)
{
  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));
};


/*
 * Ctor.
 */
ListOfSpeciesReferenceGlyphs::ListOfSpeciesReferenceGlyphs(LayoutPkgNamespaces* layoutns)
 : ListOf(layoutns)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());
}


/*
 * @return a (deep) copy of this ListOfSpeciesReferenceGlyphs.
 */
ListOfSpeciesReferenceGlyphs*
ListOfSpeciesReferenceGlyphs::clone () const
{
  return new ListOfSpeciesReferenceGlyphs(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfSpeciesReferenceGlyphs::getItemTypeCode () const
{
  return SBML_LAYOUT_SPECIESREFERENCEGLYPH;
}


/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string&
ListOfSpeciesReferenceGlyphs::getElementName () const
{
  static const std::string name = "listOfSpeciesReferenceGlyphs";
  return name;
}


/* return nth item in list */
SpeciesReferenceGlyph *
ListOfSpeciesReferenceGlyphs::get(unsigned int n)
{
  return static_cast<SpeciesReferenceGlyph*>(ListOf::get(n));
}


/* return nth item in list */
const SpeciesReferenceGlyph *
ListOfSpeciesReferenceGlyphs::get(unsigned int n) const
{
  return static_cast<const SpeciesReferenceGlyph*>(ListOf::get(n));
}


/* return item by id */
SpeciesReferenceGlyph*
ListOfSpeciesReferenceGlyphs::get (const std::string& sid)
{
  return const_cast<SpeciesReferenceGlyph*>( 
    static_cast<const ListOfSpeciesReferenceGlyphs&>(*this).get(sid) );
}


/* return item by id */
const SpeciesReferenceGlyph*
ListOfSpeciesReferenceGlyphs::get (const std::string& sid) const
{
  std::vector<SBase*>::const_iterator result;

  result = std::find_if( mItems.begin(), mItems.end(), IdEq<SpeciesReferenceGlyph>(sid) );
  return (result == mItems.end()) ? 0 : static_cast <SpeciesReferenceGlyph*> (*result);
}


/* Removes the nth item from this list */
SpeciesReferenceGlyph*
ListOfSpeciesReferenceGlyphs::remove (unsigned int n)
{
   return static_cast<SpeciesReferenceGlyph*>(ListOf::remove(n));
}


/* Removes item in this list by id */
SpeciesReferenceGlyph*
ListOfSpeciesReferenceGlyphs::remove (const std::string& sid)
{
  SBase* item = 0;
  std::vector<SBase*>::iterator result;

  result = std::find_if( mItems.begin(), mItems.end(), IdEq<SpeciesReferenceGlyph>(sid) );

  if (result != mItems.end())
  {
    item = *result;
    mItems.erase(result);
  }

  return static_cast <SpeciesReferenceGlyph*> (item);
}


/** @cond doxygenLibsbmlInternal */
SBase*
ListOfSpeciesReferenceGlyphs::createObject (XMLInputStream& stream)
{
  const std::string& name   = stream.peek().getName();
  SBase*        object = 0;


  if (name == "speciesReferenceGlyph")
  {
    LAYOUT_CREATE_NS(layoutns,this->getSBMLNamespaces());
    object = new SpeciesReferenceGlyph(layoutns);
    appendAndOwn(object);
    delete layoutns;
//    mItems.push_back(object);
  }

  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
XMLNode ListOfSpeciesReferenceGlyphs::toXML() const
{
  return getXmlNodeForSBase(this);
}
/** @endcond */



/*
 * Accepts the given SBMLVisitor.
 */
bool
ReactionGlyph::accept (SBMLVisitor& v) const
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

  this->mSpeciesReferenceGlyphs.accept(v);
  
  v.leave(*this);
  
  return true;
}



/** @cond doxygenLibsbmlInternal */
/*
 * Sets the parent SBMLDocument of this SBML object.
 */
void
ReactionGlyph::setSBMLDocument (SBMLDocument* d)
{
  GraphicalObject::setSBMLDocument(d);

  mSpeciesReferenceGlyphs.setSBMLDocument(d);
  mCurve.setSBMLDocument(d);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
/*
 * Sets this SBML object to child SBML objects (if any).
 * (Creates a child-parent relationship by the parent)
 */
void
ReactionGlyph::connectToChild()
{
  GraphicalObject::connectToChild();
  mSpeciesReferenceGlyphs.connectToParent(this);
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
ReactionGlyph::enablePackageInternal(const std::string& pkgURI,
                                     const std::string& pkgPrefix, bool flag)
{
  SBase::enablePackageInternal(pkgURI,pkgPrefix,flag);

  mSpeciesReferenceGlyphs.enablePackageInternal(pkgURI,pkgPrefix,flag);
  mCurve.enablePackageInternal(pkgURI,pkgPrefix,flag);
}
/** @endcond */



#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
ReactionGlyph_t *
ReactionGlyph_create (void)
{
  return new(std::nothrow) ReactionGlyph;
}


LIBSBML_EXTERN
ReactionGlyph_t *
ReactionGlyph_createWith (const char *sid)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) ReactionGlyph(&layoutns, sid ? sid : "", "");
}


LIBSBML_EXTERN
ReactionGlyph_t *
ReactionGlyph_createWithReactionId (const char *id, const char *reactionId)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) ReactionGlyph(&layoutns, id ? id : "", reactionId ? reactionId : "");
}


LIBSBML_EXTERN
ReactionGlyph_t *
ReactionGlyph_createFrom (const ReactionGlyph_t *temp)
{
  return new(std::nothrow) ReactionGlyph(*temp);
}


LIBSBML_EXTERN
void
ReactionGlyph_free (ReactionGlyph_t *rg)
{
  delete rg;
}


LIBSBML_EXTERN
void
ReactionGlyph_setReactionId (ReactionGlyph_t *rg,const char *id)
{
  if (rg == NULL) return;
  static_cast<ReactionGlyph*>(rg)->setReactionId( id ? id : "" );
}


LIBSBML_EXTERN
const char *
ReactionGlyph_getReactionId (const ReactionGlyph_t *rg)
{
  if (rg == NULL) return NULL;
  return rg->isSetReactionId() ? rg->getReactionId().c_str() : NULL;
}


LIBSBML_EXTERN
int
ReactionGlyph_isSetReactionId (const ReactionGlyph_t *rg)
{
  if (rg == NULL) return (int)false;
  return static_cast<int>( rg->isSetReactionId() );
}


LIBSBML_EXTERN
void
ReactionGlyph_addSpeciesReferenceGlyph (ReactionGlyph_t         *rg,
                                        SpeciesReferenceGlyph_t *srg)
{
  if (rg == NULL) return;
  rg->addSpeciesReferenceGlyph(srg);
}


LIBSBML_EXTERN
unsigned int
ReactionGlyph_getNumSpeciesReferenceGlyphs (const ReactionGlyph_t *rg)
{
  if (rg == NULL) return 0;
  return rg->getNumSpeciesReferenceGlyphs();
}


LIBSBML_EXTERN
SpeciesReferenceGlyph_t *
ReactionGlyph_getSpeciesReferenceGlyph (ReactionGlyph_t *rg,
                                        unsigned int           index)
{
  if (rg == NULL) return NULL;
  return rg->getSpeciesReferenceGlyph(index);
}


LIBSBML_EXTERN
ListOf_t *
ReactionGlyph_getListOfSpeciesReferenceGlyphs (ReactionGlyph_t *rg)
{
  if (rg == NULL) return NULL;
  return rg->getListOfSpeciesReferenceGlyphs();
}


LIBSBML_EXTERN
void
ReactionGlyph_initDefaults (ReactionGlyph_t *rg)
{
  if (rg == NULL) return;
  rg->initDefaults();
}


LIBSBML_EXTERN
void
ReactionGlyph_setCurve (ReactionGlyph_t *rg, Curve_t *c)
{
  if (rg == NULL) return;
  rg->setCurve(c);
}


LIBSBML_EXTERN
Curve_t *
ReactionGlyph_getCurve (ReactionGlyph_t *rg)
{
  if (rg == NULL) return NULL;
  return rg->getCurve();
}


LIBSBML_EXTERN
int
ReactionGlyph_isSetCurve (ReactionGlyph_t *rg)
{
  if (rg == NULL) return (int)false;
  return static_cast<int>( rg->isSetCurve() );
}


LIBSBML_EXTERN
SpeciesReferenceGlyph_t *
ReactionGlyph_createSpeciesReferenceGlyph (ReactionGlyph_t *rg)
{
  if (rg == NULL) return NULL;
  return rg->createSpeciesReferenceGlyph();
}


LIBSBML_EXTERN
LineSegment_t *
ReactionGlyph_createLineSegment (ReactionGlyph_t *rg)
{
  if (rg == NULL) return NULL;
  return rg->getCurve()->createLineSegment();
}


LIBSBML_EXTERN
CubicBezier_t *
ReactionGlyph_createCubicBezier (ReactionGlyph_t *rg)
{
  if (rg == NULL) return NULL;
  return rg->getCurve()->createCubicBezier();
}


LIBSBML_EXTERN
SpeciesReferenceGlyph_t*
ReactionGlyph_removeSpeciesReferenceGlyph(ReactionGlyph_t* rg,unsigned int index)
{
  if (rg == NULL) return NULL;
  return rg->removeSpeciesReferenceGlyph(index);
}

LIBSBML_EXTERN
SpeciesReferenceGlyph_t*
ReactionGlyph_removeSpeciesReferenceGlyphWithId(ReactionGlyph_t* rg,const char* id)
{
  if (rg == NULL) return NULL;
  return rg->removeSpeciesReferenceGlyph(id);
}

LIBSBML_EXTERN
unsigned int
ReactionGlyph_getIndexForSpeciesReferenceGlyph(ReactionGlyph_t* rg,const char* id)
{
  if (rg == NULL) return 0;
  return rg->getIndexForSpeciesReferenceGlyph(id);
}

LIBSBML_EXTERN
ReactionGlyph_t *
ReactionGlyph_clone (const ReactionGlyph_t *m)
{
  if (m == NULL) return NULL;
  return static_cast<ReactionGlyph*>( m->clone() );
}


/** @endcond */
LIBSBML_CPP_NAMESPACE_END
