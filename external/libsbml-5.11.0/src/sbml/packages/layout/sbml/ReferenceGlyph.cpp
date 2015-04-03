/**
 * @file    ReferenceGlyph.cpp
 * @brief   Implementation of ReferenceGlyph for SBML Layout.
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

#include <sbml/packages/layout/sbml/ReferenceGlyph.h>
#include <sbml/packages/layout/sbml/GeneralGlyph.h>
#include <sbml/packages/layout/sbml/GraphicalObject.h>
#include <sbml/packages/layout/util/LayoutUtilities.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>

#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/util/ElementFilter.h>
#include <sbml/packages/layout/validator/LayoutSBMLError.h>

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

List*
ReferenceGlyph::getAllElements(ElementFilter *filter)
{
  List* ret = GraphicalObject::getAllElements(filter);
  List* sublist = NULL;

  ADD_FILTERED_ELEMENT(ret, sublist, mCurve, filter);  

  return ret;
}

void
ReferenceGlyph::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  GraphicalObject::renameSIdRefs(oldid, newid);
  if (isSetReferenceId() && mReference == oldid) 
  {
    mReference = newid;
  }
  if (isSetGlyphId() && mGlyph == oldid)
  {
    mGlyph = newid;
  }
}

/*
 * Creates a new ReferenceGlyph.  The id if the associated 
 * reference and the id of the associated glyph are set to the
 * empty string.  The role is set to empty.
 */
ReferenceGlyph::ReferenceGlyph (unsigned int level, unsigned int version, unsigned int pkgVersion)
 : GraphicalObject(level,version,pkgVersion)
   ,mReference("")
   ,mGlyph("")
   ,mRole  ( "" )
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


ReferenceGlyph::ReferenceGlyph(LayoutPkgNamespaces* layoutns)
 : GraphicalObject(layoutns)
   ,mReference("")
   ,mGlyph    ("")
   ,mRole     ("")
   ,mCurve(layoutns)
  , mCurveExplicitlySet ( false )
{
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
 * Creates a new ReferenceGlyph.  The id is given as the first
 * argument, the id of the associated glyph is given as the
 * second argument.  The third argument is the id of the associated
 * reference and the fourth argument is the role.
 */ 
ReferenceGlyph::ReferenceGlyph
(
  LayoutPkgNamespaces* layoutns,
  const std::string& sid,
  const std::string& glyphId,
  const std::string& referenceId,
  const std::string& role
) :
  GraphicalObject    ( layoutns, sid  )
  , mReference       ( referenceId )
  , mGlyph           ( glyphId     )
  , mRole            ( role        )
  , mCurve           ( layoutns    )
  , mCurveExplicitlySet (false)
{
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
 * Creates a new ReferenceGlyph from the given XMLNode
 */
ReferenceGlyph::ReferenceGlyph(const XMLNode& node, unsigned int l2version)
 :  GraphicalObject  (node, l2version)
   ,mReference("")
   ,mGlyph    ("")
   ,mRole     ("")
  , mCurve           (2, l2version)
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
        ++n;
    }    

  connectToChild();
}

/*
 * Copy constructor.
 */
ReferenceGlyph::ReferenceGlyph(const ReferenceGlyph& source) :
    GraphicalObject(source)
{
    this->mReference=source.mReference;
    this->mGlyph=source.mGlyph;
    this->mRole=source.mRole;
    this->mCurve=*source.getCurve();
    this->mCurveExplicitlySet = source.mCurveExplicitlySet;

    connectToChild();
}

/*
 * Assignment operator.
 */
ReferenceGlyph& ReferenceGlyph::operator=(const ReferenceGlyph& source)
{
  if(&source!=this)
  {
    GraphicalObject::operator=(source);
    this->mReference=source.mReference;
    this->mGlyph=source.mGlyph;
    this->mRole=source.mRole;
    this->mCurve=*source.getCurve();

    this->mCurveExplicitlySet = source.mCurveExplicitlySet;
    connectToChild();
  }
  
  return *this;
}

/*
 * Destructor.
 */ 
ReferenceGlyph::~ReferenceGlyph ()
{
}


/*
 * Returns the id of the associated glyph.
 */ 
const std::string&
ReferenceGlyph::getGlyphId () const
{
  return this->mGlyph;
}


/*
 * Sets the id of the associated glyph.
 */ 
void
ReferenceGlyph::setGlyphId (const std::string& glyphId)
{
  this->mGlyph = glyphId;
}


/*
 * Returns the id of the associated reference.
 */ 
const std::string&
ReferenceGlyph::getReferenceId () const
{
  return this->mReference;
}


/*
 * Sets the id of the associated reference.
 */ 
void
ReferenceGlyph::setReferenceId (const std::string& id)
{
  this->mReference=id;
}



/*
 * Returns a string representation for the role
 */
const std::string& ReferenceGlyph::getRole() const{
    return this->mRole;
}

/*
 * Sets the role based on a string.
 */ 
void
ReferenceGlyph::setRole (const std::string& role)
{
  this->mRole = role;
}



/*
 * Returns the curve object for the reference glyph
 */ 
Curve* ReferenceGlyph::getCurve() 
{
  return &this->mCurve;
}

/*
 * Returns the curve object for the reference glyph
 */ 
const Curve* ReferenceGlyph::getCurve() const
{
  return &this->mCurve;
}


/*
 * Sets the curve object for the reference glyph.
 */ 
void
ReferenceGlyph::setCurve (const Curve* curve)
{
  if(!curve) return;
  this->mCurve = *curve;
  this->mCurve.connectToParent(this);
  mCurveExplicitlySet = true;
}


/*
 * Returns true if the curve consists of one or more segments.
 */ 
bool
ReferenceGlyph::isSetCurve () const
{
  return this->mCurve.getNumCurveSegments() > 0;
}

bool
ReferenceGlyph::getCurveExplicitlySet() const
{
  return mCurveExplicitlySet;
}

/*
 * Returns true if the id of the associated glyph is not the empty
 * string.
 */ 
bool
ReferenceGlyph::isSetGlyphId () const
{
  return ! this->mGlyph.empty();
}


/*
 * Returns true if the id of the associated reference is not the
 * empty string.
 */ 
bool
ReferenceGlyph::isSetReferenceId () const
{
  return ! this->mReference.empty();
}


/*
 * Returns true of role is different from the empty string.
 */ 
bool ReferenceGlyph::isSetRole () const
{
  return ! this->mRole.empty();
}


/*
 * Calls initDefaults on GraphicalObject 
 */ 
void
ReferenceGlyph::initDefaults ()
{
    GraphicalObject::initDefaults();    
}


/*
 * Creates a new LineSegment object, adds it to the end of the list of
 * curve segment objects of the curve and returns a reference to the newly
 * created object.
 */
LineSegment*
ReferenceGlyph::createLineSegment ()
{
  return this->mCurve.createLineSegment();
}


/*
 * Creates a new CubicBezier object, adds it to the end of the list of
 * curve segment objects of the curve and returns a reference to the newly
 * created object.
 */
CubicBezier*
ReferenceGlyph::createCubicBezier ()
{
  return this->mCurve.createCubicBezier();
}


/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string& ReferenceGlyph::getElementName () const 
{
  static const std::string name = "referenceGlyph";
  return name;
}

/*
 * @return a (deep) copy of this ReferenceGlyph.
 */
ReferenceGlyph* 
ReferenceGlyph::clone () const
{
    return new ReferenceGlyph(*this);
}


/** @cond doxygenLibsbmlInternal */
SBase*
ReferenceGlyph::createObject (XMLInputStream& stream)
{
  const std::string& name   = stream.peek().getName();
  
  SBase*        object = 0;

  if (name == "curve")
  {
    if (getCurveExplicitlySet() == true)
    {
      getErrorLog()->logPackageError("layout", LayoutREFGAllowedElements, 
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
ReferenceGlyph::addExpectedAttributes(ExpectedAttributes& attributes)
{
  GraphicalObject::addExpectedAttributes(attributes);

  attributes.add("reference");
  attributes.add("glyph");
  attributes.add("role");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void ReferenceGlyph::readAttributes (const XMLAttributes& attributes,
                                const ExpectedAttributes& expectedAttributes)
{
	const unsigned int sbmlLevel   = getLevel  ();
	const unsigned int sbmlVersion = getVersion();

	unsigned int numErrs;

	/* look to see whether an unknown attribute error was logged
	 * during the read of the listOfReferenceGlyphs - which will have
	 * happened immediately prior to this read
	*/

  bool loSubGlyphs = false;
  if (getParentSBMLObject() != NULL
    && getParentSBMLObject()->getElementName() == "listOfSubGlyphs")
  {
    loSubGlyphs = true;
  }

	if (getErrorLog() != NULL &&
	    static_cast<ListOfReferenceGlyphs*>(getParentSBMLObject())->size() < 2)
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
                                    LayoutLOReferenceGlyphAllowedAttribs,
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
                                    LayoutLOReferenceGlyphAllowedAttribs,
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
				getErrorLog()->logPackageError("layout", LayoutREFGAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				                  getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
				getErrorLog()->logPackageError("layout", 
                       LayoutREFGAllowedCoreAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
		}
	}

	bool assigned = false;

	//
	// glyph SIdRef   ( use = "required" )
	//
	assigned = attributes.readInto("glyph", mGlyph);

  if (getErrorLog() != NULL)
  {
	  if (assigned == true)
	  {
		  // check string is not empty and correct syntax

		  if (mGlyph.empty() == true)
		  {
			  logEmptyString(mGlyph, getLevel(), getVersion(), "<ReferenceGlyph>");
		  }
		  else if (SyntaxChecker::isValidSBMLSId(mGlyph) == false)
		  {
		    getErrorLog()->logPackageError("layout", LayoutREFGGlyphSyntax,
		                   getPackageVersion(), sbmlLevel, sbmlVersion);
		  }
	  }
	  else
	  {
		  std::string message = "Layout attribute 'glyph' is missing.";
		  getErrorLog()->logPackageError("layout", LayoutREFGAllowedAttributes,
		                 getPackageVersion(), sbmlLevel, sbmlVersion, message);
	  }
  }

	//
	// reference SIdRef   ( use = "optional" )
	//
	assigned = attributes.readInto("reference", mReference);

	if (assigned == true && getErrorLog() != NULL)
	{
		// check string is not empty and correct syntax

		if (mReference.empty() == true)
		{
			logEmptyString(mReference, getLevel(), getVersion(), "<ReferenceGlyph>");
		}
		else if (SyntaxChecker::isValidSBMLSId(mReference) == false)
		{
		  getErrorLog()->logPackageError("layout", LayoutREFGReferenceSyntax,
		                 getPackageVersion(), sbmlLevel, sbmlVersion);
		}
	}

	//
	// role string   ( use = "optional" )
	//
  std::string role;
	assigned = attributes.readInto("role", role);

	if (assigned == true)
	{
		// check string is not empty

		if (role.empty() == true  && getErrorLog() != NULL)
		{
			logEmptyString(role, getLevel(), getVersion(), "<ReferenceGlyph>");
		}

    this->setRole(role);
	}
  
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
ReferenceGlyph::writeElements (XMLOutputStream& stream) const
{
  if(this->isSetCurve())
  {
      SBase::writeElements(stream);
      mCurve.write(stream);
  }
  else
  {
    GraphicalObject::writeElements(stream);
  }

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void ReferenceGlyph::writeAttributes (XMLOutputStream& stream) const
{
  GraphicalObject::writeAttributes(stream);
  if(this->isSetReferenceId())
  {
    stream.writeAttribute("reference", getPrefix(), mReference);
  }
  if(this->isSetGlyphId())
  {
    stream.writeAttribute("glyph", getPrefix(), mGlyph);
  }
  if(this->isSetRole())
  {
    stream.writeAttribute("role", getPrefix(), this->mRole );
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
ReferenceGlyph::getTypeCode () const
{
  return SBML_LAYOUT_REFERENCEGLYPH;
}

/*
 * Creates an XMLNode object from this.
 */
XMLNode ReferenceGlyph::toXML() const
{
  return getXmlNodeForSBase(this);
}


/*
 * Accepts the given SBMLVisitor.
 */
bool
ReferenceGlyph::accept (SBMLVisitor& v) const
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

  v.leave(*this);
  
  return true;
}



/** @cond doxygenLibsbmlInternal */
/*
 * Sets the parent SBMLDocument of this SBML object.
 */
void
ReferenceGlyph::setSBMLDocument (SBMLDocument* d)
{
  GraphicalObject::setSBMLDocument(d);

  mCurve.setSBMLDocument(d);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Sets this SBML object to child SBML objects (if any).
 * (Creates a child-parent relationship by the parent)
 */
void
ReferenceGlyph::connectToChild()
{
  GraphicalObject::connectToChild();
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
ReferenceGlyph::enablePackageInternal(const std::string& pkgURI,
                                             const std::string& pkgPrefix, 
                                             bool flag)
{
  SBase::enablePackageInternal(pkgURI,pkgPrefix,flag);

  mCurve.enablePackageInternal(pkgURI,pkgPrefix,flag);
}
/** @endcond */




#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
ReferenceGlyph_t *
ReferenceGlyph_create(void)
{
  return new(std::nothrow) ReferenceGlyph;
}


LIBSBML_EXTERN
ReferenceGlyph_t *
ReferenceGlyph_createFrom (const ReferenceGlyph_t *temp)
{
  return new(std::nothrow) ReferenceGlyph(*temp);
}


LIBSBML_EXTERN
ReferenceGlyph_t *
ReferenceGlyph_createWith (const char *sid,
                           const char *glyphId,
                           const char *referenceId,
                           const char* role)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow)
    ReferenceGlyph(&layoutns, sid ? sid : "", glyphId ? glyphId : "", referenceId ? referenceId : "", role ? role : "");
}


LIBSBML_EXTERN
void
ReferenceGlyph_free(ReferenceGlyph_t *srg)
{
  delete srg;
}


LIBSBML_EXTERN
void
ReferenceGlyph_setReferenceId (ReferenceGlyph_t *srg,
                                             const char *id)
{
  if (srg == NULL) return;
  srg->setReferenceId( id ? id : "" );
}


LIBSBML_EXTERN
const char *
ReferenceGlyph_getReferenceId (const ReferenceGlyph_t *srg)
{
  if (srg == NULL) return NULL;
  return srg->isSetReferenceId() ? srg->getReferenceId().c_str() : NULL;
}


LIBSBML_EXTERN
int
ReferenceGlyph_isSetReferenceId
  (const ReferenceGlyph_t *srg)
{
  if (srg == NULL) return (int)false;
  return (int)srg->isSetReferenceId();
}


LIBSBML_EXTERN
void
ReferenceGlyph_setGlyphId (ReferenceGlyph_t *srg,
                                         const char *id)
{
  if (srg == NULL) return;
  srg->setGlyphId( id ? id : "" );
}


LIBSBML_EXTERN
const char *
ReferenceGlyph_getGlyphId (const ReferenceGlyph_t *srg)
{
  if (srg == NULL) return NULL;
  return srg->isSetGlyphId() ? srg->getGlyphId().c_str() : NULL;
}


LIBSBML_EXTERN
int
ReferenceGlyph_isSetGlyphId (const ReferenceGlyph_t *srg)
{
  if (srg == NULL) return (int)false;
  return static_cast<int>( srg->isSetGlyphId() );
}


LIBSBML_EXTERN
void
ReferenceGlyph_setCurve(ReferenceGlyph_t *srg, Curve_t *c)
{
  if (srg == NULL) return;
  srg->setCurve(c);
}


LIBSBML_EXTERN
Curve_t *
ReferenceGlyph_getCurve (ReferenceGlyph_t *srg)
{
  if (srg == NULL) return NULL;
  return srg->getCurve();
}


LIBSBML_EXTERN
int
ReferenceGlyph_isSetCurve (ReferenceGlyph_t *srg)
{
  if (srg == NULL) return (int)false;
  return static_cast<int>( srg->isSetCurve() );
}


LIBSBML_EXTERN
void
ReferenceGlyph_setRole (ReferenceGlyph_t *srg,
                               const char *r)
{
  if (srg == NULL) return;
  srg->setRole(r);
}


LIBSBML_EXTERN
const char*
ReferenceGlyph_getRole(const ReferenceGlyph_t* srg)
{
  if (srg == NULL) return NULL;
  return srg->getRole().empty() ? NULL : srg->getRole().c_str();
}


LIBSBML_EXTERN
int
ReferenceGlyph_isSetRole (const ReferenceGlyph_t *srg)
{
  if (srg == NULL) return (int)false;
  return static_cast<int>( srg->isSetRole() );
}


LIBSBML_EXTERN
void
ReferenceGlyph_initDefaults (ReferenceGlyph_t *srg)
{
  if (srg == NULL) return;
  srg->initDefaults();
}


LIBSBML_EXTERN
LineSegment_t *
ReferenceGlyph_createLineSegment (ReferenceGlyph_t *srg)
{
  if (srg == NULL) return NULL;
  return srg->getCurve()->createLineSegment();
}  


LIBSBML_EXTERN
CubicBezier_t *
ReferenceGlyph_createCubicBezier (ReferenceGlyph_t *srg)
{
  if (srg == NULL) return NULL;
  return srg->getCurve()->createCubicBezier();
}


LIBSBML_EXTERN
ReferenceGlyph_t *
ReferenceGlyph_clone (const ReferenceGlyph_t *m)
{
  if (m == NULL) return NULL;
  return static_cast<ReferenceGlyph*>( m->clone() );
}

LIBSBML_EXTERN
int
ReferenceGlyph_isSetId (const ReferenceGlyph_t *srg)
{
  if (srg == NULL) return (int)false;
  return static_cast <int> (srg->isSetId());
}

LIBSBML_EXTERN
const char *
ReferenceGlyph_getId (const ReferenceGlyph_t *srg)
{
  if (srg == NULL) return NULL;
  return srg->isSetId() ? srg->getId().c_str() : NULL;
}

LIBSBML_EXTERN
int
ReferenceGlyph_setId (ReferenceGlyph_t *srg, const char *sid)
{
  if (srg == NULL) return (int)false;
  return (sid == NULL) ? srg->setId("") : srg->setId(sid);
}

LIBSBML_EXTERN
void
ReferenceGlyph_unsetId (ReferenceGlyph_t *srg)
{
  if (srg == NULL) return;
  srg->unsetId();
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END

