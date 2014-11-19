/**
 * @file    SpeciesReferenceGlyph.cpp
 * @brief   Implementation of SpeciesReferenceGlyph for SBML Layout.
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

#include <sbml/packages/layout/sbml/SpeciesReferenceGlyph.h>
#include <sbml/packages/layout/sbml/Layout.h>
#include <sbml/packages/layout/util/LayoutUtilities.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>

#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>
#include <sbml/packages/layout/validator/LayoutSBMLError.h>

#include <sbml/util/ElementFilter.h>

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/** @cond doxygenLibsbmlInternal */
const std::string SpeciesReferenceGlyph::SPECIES_REFERENCE_ROLE_STRING[]={
    "undefined" 
   ,"substrate"
   ,"product"
   ,"sidesubstrate"
   ,"sideproduct"
   ,"modifier"
   ,"activator"
   ,"inhibitor"
   ,""
};
/** @endcond */

List*
SpeciesReferenceGlyph::getAllElements(ElementFilter *filter)
{
  List* ret = GraphicalObject::getAllElements(filter);
  List* sublist = NULL;

  ADD_FILTERED_ELEMENT(ret, sublist, mCurve, filter);  

  return ret;
}

void
SpeciesReferenceGlyph::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  GraphicalObject::renameSIdRefs(oldid, newid);
  if (isSetSpeciesReferenceId() && mSpeciesReference == oldid) 
  {
    mSpeciesReference = newid;
  }
  if (isSetSpeciesGlyphId() && mSpeciesGlyph == oldid)
  {
    mSpeciesGlyph = newid;
  }
}

/*
 * Creates a new SpeciesReferenceGlyph.  The id if the associated species
 * reference and the id of the associated species glyph are set to the
 * empty string.  The role is set to SPECIES_ROLE_UNDEFINED.
 */
SpeciesReferenceGlyph::SpeciesReferenceGlyph (unsigned int level, unsigned int version, unsigned int pkgVersion)
 : GraphicalObject(level,version,pkgVersion)
   ,mSpeciesReference("")
   ,mSpeciesGlyph("")
   ,mRole  ( SPECIES_ROLE_UNDEFINED )
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


SpeciesReferenceGlyph::SpeciesReferenceGlyph(LayoutPkgNamespaces* layoutns)
 : GraphicalObject(layoutns)
   ,mSpeciesReference("")
   ,mSpeciesGlyph("")
   ,mRole  ( SPECIES_ROLE_UNDEFINED )
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
 * Creates a new SpeciesReferenceGlyph.  The id is given as the first
 * argument, the id of the associated species reference is given as the
 * second argument.  The third argument is the id of the associated species
 * glyph and the fourth argument is the role.
 */ 
SpeciesReferenceGlyph::SpeciesReferenceGlyph
(
  LayoutPkgNamespaces* layoutns,
  const std::string& sid,
  const std::string& speciesGlyphId,
  const std::string& speciesReferenceId,
  SpeciesReferenceRole_t role
) :
  GraphicalObject    ( layoutns, sid      )
  , mSpeciesReference( speciesReferenceId )
  , mSpeciesGlyph    ( speciesGlyphId     )
  , mRole            ( role               )
  ,mCurve            (layoutns)
   ,mCurveExplicitlySet (false)
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
 * Creates a new SpeciesReferenceGlyph from the given XMLNode
 */
SpeciesReferenceGlyph::SpeciesReferenceGlyph(const XMLNode& node, unsigned int l2version)
 :  GraphicalObject  (node, l2version)
  , mSpeciesReference("")
  , mSpeciesGlyph    ("")
  , mRole            (SPECIES_ROLE_UNDEFINED)
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
SpeciesReferenceGlyph::SpeciesReferenceGlyph(const SpeciesReferenceGlyph& source) :
    GraphicalObject(source)
{
    this->mSpeciesReference=source.getSpeciesReferenceId();
    this->mSpeciesGlyph=source.getSpeciesGlyphId();
    this->mRole=source.getRole();
    this->mCurve=*source.getCurve();
    this->mCurveExplicitlySet = source.mCurveExplicitlySet;

    connectToChild();
}

/*
 * Assignment operator.
 */
SpeciesReferenceGlyph& SpeciesReferenceGlyph::operator=(const SpeciesReferenceGlyph& source)
{
  if(&source!=this)
  {
    GraphicalObject::operator=(source);
    this->mSpeciesReference=source.getSpeciesReferenceId();
    this->mSpeciesGlyph=source.getSpeciesGlyphId();
    this->mRole=source.getRole();
    this->mCurve=*source.getCurve();

    this->mCurveExplicitlySet = source.mCurveExplicitlySet;
    connectToChild();
  }
  
  return *this;
}

/*
 * Destructor.
 */ 
SpeciesReferenceGlyph::~SpeciesReferenceGlyph ()
{
}


/*
 * Returns the id of the associated SpeciesGlyph.
 */ 
const std::string&
SpeciesReferenceGlyph::getSpeciesGlyphId () const
{
  return this->mSpeciesGlyph;
}


/*
 * Sets the id of the associated species glyph.
 */ 
void
SpeciesReferenceGlyph::setSpeciesGlyphId (const std::string& speciesGlyphId)
{
  this->mSpeciesGlyph = speciesGlyphId;
}


/*
 * Returns the id of the associated species reference.
 */ 
const std::string&
SpeciesReferenceGlyph::getSpeciesReferenceId () const
{
  return this->mSpeciesReference;
}


/*
 * Sets the id of the associated species reference.
 */ 
void
SpeciesReferenceGlyph::setSpeciesReferenceId (const std::string& id)
{
  this->mSpeciesReference=id;
}


/*
 * Returns the role.
 */ 
SpeciesReferenceRole_t
SpeciesReferenceGlyph::getRole() const
{
  return this->mRole;
}

/*
 * Returns a string representation for the role
 */
const std::string& SpeciesReferenceGlyph::getRoleString() const{
    return SpeciesReferenceGlyph::SPECIES_REFERENCE_ROLE_STRING[this->mRole];
}

/*
 * Sets the role based on a string.
 * The String can be one of
 * SUBSTRATE
 * PRODUCT
 * SIDESUBSTRATE
 * SIDEPRODUCT
 * MODIFIER
 * ACTIVATOR
 * INHIBITOR    
 */ 
void
SpeciesReferenceGlyph::setRole (const std::string& role)
{
       if ( role == "substrate"     ) this->mRole = SPECIES_ROLE_SUBSTRATE;
  else if ( role == "product"       ) this->mRole = SPECIES_ROLE_PRODUCT;
  else if ( role == "sidesubstrate" ) this->mRole = SPECIES_ROLE_SIDESUBSTRATE;
  else if ( role == "sideproduct"   ) this->mRole = SPECIES_ROLE_SIDEPRODUCT;
  else if ( role == "modifier"      ) this->mRole = SPECIES_ROLE_MODIFIER;
  else if ( role == "activator"     ) this->mRole = SPECIES_ROLE_ACTIVATOR;
  else if ( role == "inhibitor"     ) this->mRole = SPECIES_ROLE_INHIBITOR;
  else                                this->mRole = SPECIES_ROLE_UNDEFINED;
}


/*
 * Sets the role.
 */ 
void
SpeciesReferenceGlyph::setRole (SpeciesReferenceRole_t role)
{
  this->mRole=role;
}


/*
 * Returns the curve object for the species reference glyph
 */ 
Curve* SpeciesReferenceGlyph::getCurve() 
{
  return &this->mCurve;
}

/*
 * Returns the curve object for the species reference glyph
 */ 
const Curve* SpeciesReferenceGlyph::getCurve() const
{
  return &this->mCurve;
}


/*
 * Sets the curve object for the species reference glyph.
 */ 
void
SpeciesReferenceGlyph::setCurve (const Curve* curve)
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
SpeciesReferenceGlyph::isSetCurve () const
{
  return this->mCurve.getNumCurveSegments() > 0;
}

bool
SpeciesReferenceGlyph::getCurveExplicitlySet() const
{
  return mCurveExplicitlySet;
}


/*
 * Returns true if the id of the associated species glyph is not the empty
 * string.
 */ 
bool
SpeciesReferenceGlyph::isSetSpeciesGlyphId () const
{
  return ! this->mSpeciesGlyph.empty();
}


/*
 * Returns true if the id of the associated species reference is not the
 * empty string.
 */ 
bool
SpeciesReferenceGlyph::isSetSpeciesReferenceId () const
{
  return ! this->mSpeciesReference.empty();
}


/*
 * Returns true of role is different from SPECIES_ROLE_UNDEFINED.
 */ 
bool SpeciesReferenceGlyph::isSetRole () const
{
  return ! (this->mRole == SPECIES_ROLE_UNDEFINED);
}


/*
 * Calls initDefaults on GraphicalObject and sets role to
 * SPECIES_ROLE_UNDEFINED.
 */ 
void
SpeciesReferenceGlyph::initDefaults ()
{
    GraphicalObject::initDefaults();
    this->mRole = SPECIES_ROLE_UNDEFINED;
}


/*
 * Creates a new LineSegment object, adds it to the end of the list of
 * curve segment objects of the curve and returns a reference to the newly
 * created object.
 */
LineSegment*
SpeciesReferenceGlyph::createLineSegment ()
{
  return this->mCurve.createLineSegment();
}


/*
 * Creates a new CubicBezier object, adds it to the end of the list of
 * curve segment objects of the curve and returns a reference to the newly
 * created object.
 */
CubicBezier*
SpeciesReferenceGlyph::createCubicBezier ()
{
  return this->mCurve.createCubicBezier();
}


/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string& SpeciesReferenceGlyph::getElementName () const 
{
  static const std::string name = "speciesReferenceGlyph";
  return name;
}

/*
 * @return a (deep) copy of this SpeciesReferenceGlyph.
 */
SpeciesReferenceGlyph* 
SpeciesReferenceGlyph::clone () const
{
    return new SpeciesReferenceGlyph(*this);
}


/** @cond doxygenLibsbmlInternal */
SBase*
SpeciesReferenceGlyph::createObject (XMLInputStream& stream)
{
  const std::string& name   = stream.peek().getName();
  
  SBase*        object = 0;

  if (name == "curve")
  {
    if (getCurveExplicitlySet() == true)
    {
      getErrorLog()->logPackageError("layout", LayoutSRGAllowedElements, 
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
SpeciesReferenceGlyph::addExpectedAttributes(ExpectedAttributes& attributes)
{
  GraphicalObject::addExpectedAttributes(attributes);

  attributes.add("speciesReference");
  attributes.add("speciesGlyph");
  attributes.add("role");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void SpeciesReferenceGlyph::readAttributes (const XMLAttributes& attributes,
                                            const ExpectedAttributes& expectedAttributes)
{
	const unsigned int sbmlLevel   = getLevel  ();
	const unsigned int sbmlVersion = getVersion();

	unsigned int numErrs;

	/* look to see whether an unknown attribute error was logged
	 * during the read of the listOfSpeciesReferenceGlyphs - which will have
	 * happened immediately prior to this read
	*/

  bool loSubGlyphs = false;
  if (getParentSBMLObject() != NULL
    && getParentSBMLObject()->getElementName() == "listOfSubGlyphs")
  {
    loSubGlyphs = true;
  }

	if (getErrorLog() != NULL &&
	    static_cast<ListOfSpeciesReferenceGlyphs*>
                           (getParentSBMLObject())->size() < 2)
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
                                    LayoutLOSpeciesRefGlyphAllowedAttribs,
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
                                    LayoutLOSpeciesRefGlyphAllowedAttribs,
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
				getErrorLog()->logPackageError("layout", LayoutSRGAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				                  getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
				getErrorLog()->logPackageError("layout", LayoutSRGAllowedCoreAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
		}
	}

	bool assigned = false;

	//
	// speciesGlyph SIdRef   ( use = "required" )
	//
	assigned = attributes.readInto("speciesGlyph", mSpeciesGlyph);

  if (getErrorLog() != NULL)
  {
	  if (assigned == true)
	  {
		  // check string is not empty and correct syntax

		  if (mSpeciesGlyph.empty() == true)
		  {
			  logEmptyString(mSpeciesGlyph, getLevel(), getVersion(), 
                                     "<SpeciesReferenceGlyph>");
		  }
		  else if (SyntaxChecker::isValidSBMLSId(mSpeciesGlyph) == false)
		  {
        getErrorLog()->logPackageError("layout", LayoutSRGSpeciesGlyphSyntax, 
            getPackageVersion(), sbmlLevel, sbmlVersion);
		  }
	  }
	  else
	  {
		  std::string message = "Layout attribute 'speciesGlyph' is missing.";
		  getErrorLog()->logPackageError("layout", LayoutSRGAllowedAttributes,
		                 getPackageVersion(), sbmlLevel, sbmlVersion, message);
	  }
  }

	//
	// speciesReference SIdRef   ( use = "optional" )
	//
	assigned = attributes.readInto("speciesReference", mSpeciesReference);

	if (assigned == true && getErrorLog() != NULL)
	{
		// check string is not empty and correct syntax

		if (mSpeciesReference.empty() == true)
		{
			logEmptyString(mSpeciesReference, getLevel(), getVersion(), 
                                        "<SpeciesReferenceGlyph>");
		}
		else if (SyntaxChecker::isValidSBMLSId(mSpeciesReference) == false)
		{

      getErrorLog()->logPackageError("layout", LayoutSRGSpeciesReferenceSyntax, 
          getPackageVersion(), sbmlLevel, sbmlVersion);
		}
	}

	//
	// roleType string   ( use = "optional" )
	//
  std::string role;
	assigned = attributes.readInto("role", role);

	if (assigned == true)
	{
		// check string is not empty

		if (role.empty() == true && getErrorLog() != NULL)
		{
			logEmptyString(role, getLevel(), getVersion(), "<SpeciesReferenceGlyph>");
		}
    else
    {
      this->setRole(role);

      if (this->getRole() == SPECIES_ROLE_UNDEFINED && getErrorLog() != NULL)
      {
        getErrorLog()->logPackageError("layout", LayoutSRGRoleSyntax, 
            getPackageVersion(), sbmlLevel, sbmlVersion);
      }
    }
	}
  else
  {
    this->setRole(SPECIES_ROLE_UNDEFINED);
  }

  
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
SpeciesReferenceGlyph::writeElements (XMLOutputStream& stream) const
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
void SpeciesReferenceGlyph::writeAttributes (XMLOutputStream& stream) const
{
  GraphicalObject::writeAttributes(stream);
  if(this->isSetSpeciesReferenceId())
  {
    stream.writeAttribute("speciesReference", getPrefix(), mSpeciesReference);
  }
  if(this->isSetSpeciesGlyphId())
  {
    stream.writeAttribute("speciesGlyph", getPrefix(), mSpeciesGlyph);
  }
  if(this->isSetRole())
  {
    stream.writeAttribute("role", getPrefix(), this->getRoleString().c_str() );
  }

  //
  // (EXTENSION) will be written by GraphicalObject!
  //
  //SBase::writeExtensionAttributes(stream);

}
/** @endcond */


int
SpeciesReferenceGlyph::getTypeCode () const
{
  return SBML_LAYOUT_SPECIESREFERENCEGLYPH;
}

XMLNode SpeciesReferenceGlyph::toXML() const
{
  return getXmlNodeForSBase(this);
}


/*
 * Accepts the given SBMLVisitor.
 */
bool
SpeciesReferenceGlyph::accept (SBMLVisitor& v) const
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
SpeciesReferenceGlyph::setSBMLDocument (SBMLDocument* d)
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
SpeciesReferenceGlyph::connectToChild()
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
SpeciesReferenceGlyph::enablePackageInternal(const std::string& pkgURI,
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
SpeciesReferenceGlyph_t *
SpeciesReferenceGlyph_create(void)
{
  return new(std::nothrow) SpeciesReferenceGlyph;
}


LIBSBML_EXTERN
SpeciesReferenceGlyph_t *
SpeciesReferenceGlyph_createFrom (const SpeciesReferenceGlyph_t *temp)
{
  return new(std::nothrow) SpeciesReferenceGlyph(*temp);
}


LIBSBML_EXTERN
SpeciesReferenceGlyph_t *
SpeciesReferenceGlyph_createWith (const char *sid,
                                  const char *speciesGlyphId,
                                  const char *speciesReferenceId,
                                  SpeciesReferenceRole_t role)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow)
    SpeciesReferenceGlyph(&layoutns, sid ? sid : "", speciesGlyphId ? speciesGlyphId : "", speciesReferenceId ? speciesReferenceId : "", role);
}


LIBSBML_EXTERN
void
SpeciesReferenceGlyph_free(SpeciesReferenceGlyph_t *srg)
{
  delete srg;
}


LIBSBML_EXTERN
void
SpeciesReferenceGlyph_setSpeciesReferenceId (SpeciesReferenceGlyph_t *srg,
                                             const char *id)
{
  if (srg == NULL) return;
  srg->setSpeciesReferenceId( id ? id : "" );
}


LIBSBML_EXTERN
const char *
SpeciesReferenceGlyph_getSpeciesReferenceId (const SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL) return NULL;
  return srg->isSetSpeciesReferenceId() ? srg->getSpeciesReferenceId().c_str() : NULL;
}


LIBSBML_EXTERN
int
SpeciesReferenceGlyph_isSetSpeciesReferenceId
  (const SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL) return (int)false;
  return (int)srg->isSetSpeciesReferenceId();
}


LIBSBML_EXTERN
void
SpeciesReferenceGlyph_setSpeciesGlyphId (SpeciesReferenceGlyph_t *srg,
                                         const char *id)
{
  if (srg == NULL) return;
  srg->setSpeciesGlyphId( id ? id : "" );
}


LIBSBML_EXTERN
const char *
SpeciesReferenceGlyph_getSpeciesGlyphId (const SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL) return NULL;
  return srg->isSetSpeciesGlyphId() ? srg->getSpeciesGlyphId().c_str() : NULL;
}


LIBSBML_EXTERN
int
SpeciesReferenceGlyph_isSetSpeciesGlyphId (const SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL) return (int)false;
  return static_cast<int>( srg->isSetSpeciesGlyphId() );
}


LIBSBML_EXTERN
void
SpeciesReferenceGlyph_setCurve(SpeciesReferenceGlyph_t *srg, Curve_t *c)
{
  if (srg == NULL) return;
  srg->setCurve(c);
}


LIBSBML_EXTERN
Curve_t *
SpeciesReferenceGlyph_getCurve (SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL) return NULL;
  return srg->getCurve();
}


LIBSBML_EXTERN
int
SpeciesReferenceGlyph_isSetCurve (SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL) return (int)false;
  return static_cast<int>( srg->isSetCurve() );
}


LIBSBML_EXTERN
void
SpeciesReferenceGlyph_setRole (SpeciesReferenceGlyph_t *srg,
                               const char *r)
{
  if (srg == NULL) return;
  srg->setRole(r);
}


LIBSBML_EXTERN
SpeciesReferenceRole_t
SpeciesReferenceGlyph_getRole (const SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL) return SPECIES_ROLE_UNDEFINED;
  return srg->getRole();
}

LIBSBML_EXTERN
const char*
SpeciesReferenceGlyph_getRoleString(const SpeciesReferenceGlyph_t* srg)
{
  if (srg == NULL) return NULL;
  return srg->getRoleString().empty() ? NULL : srg->getRoleString().c_str();
}



LIBSBML_EXTERN
int
SpeciesReferenceGlyph_isSetRole (const SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL) return (int)false;
  return static_cast<int>( srg->isSetRole() );
}


LIBSBML_EXTERN
void
SpeciesReferenceGlyph_initDefaults (SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL) return;
  srg->initDefaults();
}


LIBSBML_EXTERN
LineSegment_t *
SpeciesReferenceGlyph_createLineSegment (SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL || srg->getCurve() == NULL) return NULL;
  return srg->getCurve()->createLineSegment();
}  


LIBSBML_EXTERN
CubicBezier_t *
SpeciesReferenceGlyph_createCubicBezier (SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL || srg->getCurve() == NULL) return NULL;
  return srg->getCurve()->createCubicBezier();
}


LIBSBML_EXTERN
SpeciesReferenceGlyph_t *
SpeciesReferenceGlyph_clone (const SpeciesReferenceGlyph_t *m)
{
  if (m == NULL) return NULL;
  return static_cast<SpeciesReferenceGlyph*>( m->clone() );
}

LIBSBML_EXTERN
int
SpeciesReferenceGlyph_isSetId (const SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL) return (int)false;
  return static_cast <int> (srg->isSetId());
}

LIBSBML_EXTERN
const char *
SpeciesReferenceGlyph_getId (const SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL) return NULL;
  return srg->isSetId() ? srg->getId().c_str() : NULL;
}

LIBSBML_EXTERN
int
SpeciesReferenceGlyph_setId (SpeciesReferenceGlyph_t *srg, const char *sid)
{
  if (srg == NULL) return (int)false;
  return (sid == NULL) ? srg->setId("") : srg->setId(sid);
}

LIBSBML_EXTERN
void
SpeciesReferenceGlyph_unsetId (SpeciesReferenceGlyph_t *srg)
{
  if (srg == NULL) return;
  srg->unsetId();
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END

