/**
 * @file    TextGlyph.cpp
 * @brief   Implementation of TextGlyph for SBML Layout.
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

#include <sbml/packages/layout/sbml/TextGlyph.h>
#include <sbml/packages/layout/util/LayoutUtilities.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>
#include <sbml/packages/layout/sbml/Layout.h>
#include <sbml/packages/layout/validator/LayoutSBMLError.h>

#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

void
TextGlyph::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  GraphicalObject::renameSIdRefs(oldid, newid);
  if (isSetGraphicalObjectId() && mGraphicalObject == oldid) 
  {
    mGraphicalObject = newid;
  }
  if (isSetOriginOfTextId() && mOriginOfText == oldid)
  {
    mOriginOfText = newid;
  }
}

/*
 * Creates a new TextGlyph the ids of the associated GraphicalObject and
 * the originOfText are set to the empty string. The actual text is set to
 * the empty string as well.
 */  
TextGlyph::TextGlyph (unsigned int level, unsigned int version, unsigned int pkgVersion)
 : GraphicalObject(level,version,pkgVersion)
  ,mText("")
  ,mGraphicalObject("")
  ,mOriginOfText("")
{
  //
  // (NOTE) Developers don't have to invoke setSBMLNamespacesAndOwn function as follows (commentted line)
  //        in this constuctor because the function is properly invoked in the constructor of the
  //        base class (GraphicalObject).
  //

  //setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level,version,pkgVersion));  
}


/*
 * Creates a new SpeciesGlyph with the given LayoutPkgNamespaces 
 * and the id of the associated species set to the empty string.
 */        
TextGlyph::TextGlyph (LayoutPkgNamespaces* layoutns)
 : GraphicalObject(layoutns)
  ,mText("")
  ,mGraphicalObject("")
  ,mOriginOfText("")
{
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
 * Creates a new TextGlyph. The id is given as the first argument.
 */ 
TextGlyph::TextGlyph (LayoutPkgNamespaces* layoutns, const std::string& id)
 : GraphicalObject(layoutns, id)
  ,mText("")
  ,mGraphicalObject("")
  ,mOriginOfText("")
{
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
 * Creates a new TextGlyph. The id is given as the first argument, the text
 * to be displayed as the second.  All other attirbutes are set to the
 * empty string.
 */ 
TextGlyph::TextGlyph (LayoutPkgNamespaces* layoutns, const std::string& id, const std::string& text)
 : GraphicalObject(layoutns, id)
  ,mText(text)
  ,mGraphicalObject("")
  ,mOriginOfText("")
{
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
 * Creates a new TextGlyph from the given XMLNode
 */
TextGlyph::TextGlyph(const XMLNode& node, unsigned int l2version)
 : GraphicalObject(node, l2version)
  ,mText("")
  ,mGraphicalObject("")
  ,mOriginOfText("")
{
    const XMLAttributes& attributes=node.getAttributes();
    ExpectedAttributes ea;
    addExpectedAttributes(ea);
    this->readAttributes(attributes,ea);
}

/*
 * Copy constructor.
 */
TextGlyph::TextGlyph(const TextGlyph& source)
  : GraphicalObject(source)
{
    this->mText=source.getText();
    this->mOriginOfText=source.getOriginOfTextId();
    this->mGraphicalObject=source.getGraphicalObjectId();    
}

/*
 * Assignment operator.
 */
TextGlyph& TextGlyph::operator=(const TextGlyph& source)
{
  if(&source!=this)
  {
    GraphicalObject::operator=(source);
    this->mText=source.getText();
    this->mOriginOfText=source.getOriginOfTextId();
    this->mGraphicalObject=source.getGraphicalObjectId();    
  }
  
  return *this;
}

/*
 * Destructor.
 */ 
TextGlyph::~TextGlyph()
{
} 


/*
 * Returns the text to be displayed by the text glyph.
 */ 
const std::string&
TextGlyph::getText() const
{
  return this->mText;
}


/*
 * Sets the text to be displayed by the text glyph.
 */ 
void
TextGlyph::setText (const std::string& text)
{
  this->mText = text;
} 


/*
 * Returns the id of the associated graphical object.
 */ 
const std::string&
TextGlyph::getGraphicalObjectId () const
{
  return this->mGraphicalObject;
}


/*
 * Sets the id of the associated graphical object.
 */ 
int
TextGlyph::setGraphicalObjectId (const std::string& id)
{
  return SyntaxChecker::checkAndSetSId(id,mGraphicalObject);
}


/*
 * Returns the id of the origin of text.
 */ 
const std::string&
TextGlyph::getOriginOfTextId () const
{
  return this->mOriginOfText;
}


/*
 * Sets the id of the origin of text.
 */ 
int
TextGlyph::setOriginOfTextId (const std::string& orig)
{
  return SyntaxChecker::checkAndSetSId(orig,mOriginOfText);
}


/*
 * Returns true if the text is not the empty string.
 */ 
bool
TextGlyph::isSetText () const
{
  return ! this->mText.empty();
}


/*
 * Returns true if the id of the origin of text is not the empty string.
 */ 
bool
TextGlyph::isSetOriginOfTextId () const
{
  return ! this->mOriginOfText.empty();
}


/*
 * Returns true if the id of the associated graphical object is not the
 * empty string.
 */ 
bool
TextGlyph::isSetGraphicalObjectId () const
{
  return ! this->mGraphicalObject.empty();
}


/*
 * Calls initDefaults from GraphicalObject.
 */ 
void
TextGlyph::initDefaults()
{
  GraphicalObject::initDefaults();
}

/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string& TextGlyph::getElementName () const 
{
  static const std::string name = "textGlyph";
  return name;
}

/*
 * @return a (deep) copy of this TextGlyph.
 */
TextGlyph* 
TextGlyph::clone () const
{
    return new TextGlyph(*this);
}


/** @cond doxygenLibsbmlInternal */
SBase*
TextGlyph::createObject (XMLInputStream& stream)
{
  SBase*        object = 0;

  object=GraphicalObject::createObject(stream);
  
  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
TextGlyph::addExpectedAttributes(ExpectedAttributes& attributes)
{
  GraphicalObject::addExpectedAttributes(attributes);

  attributes.add("text");
  attributes.add("graphicalObject");
  attributes.add("originOfText");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void TextGlyph::readAttributes (const XMLAttributes& attributes,
                                const ExpectedAttributes& expectedAttributes)
{
	const unsigned int sbmlLevel   = getLevel  ();
	const unsigned int sbmlVersion = getVersion();

	unsigned int numErrs;

	/* look to see whether an unknown attribute error was logged
	 * during the read of the listOfTextGlyphs - which will have
	 * happened immediately prior to this read
	*/

  bool loSubGlyphs = false;
  if (getParentSBMLObject() != NULL
    && getParentSBMLObject()->getElementName() == "listOfSubGlyphs")
  {
    loSubGlyphs = true;
  }

	if (getErrorLog() != NULL &&
	    static_cast<ListOfTextGlyphs*>(getParentSBMLObject())->size() < 2)
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
                                    LayoutLOTextGlyphAllowedAttributes,
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
                                    LayoutLOTextGlyphAllowedAttributes,
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
				getErrorLog()->logPackageError("layout", LayoutTGAllowedAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
			else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
			{
				const std::string details =
				                  getErrorLog()->getError(n)->getMessage();
				getErrorLog()->remove(UnknownCoreAttribute);
				getErrorLog()->logPackageError("layout", LayoutTGAllowedCoreAttributes,
				               getPackageVersion(), sbmlLevel, sbmlVersion, details);
			}
		}
	}

	bool assigned = false;

	//
	// graphicalObject SIdRef   ( use = "optional" )
	//
	assigned = attributes.readInto("graphicalObject", mGraphicalObject);

	if (assigned == true && getErrorLog() != NULL)
	{
		// check string is not empty and correct syntax

		if (mGraphicalObject.empty() == true)
		{
			logEmptyString(mGraphicalObject, getLevel(), getVersion(), "<TextGlyph>");
		}
		else if (SyntaxChecker::isValidSBMLSId(mGraphicalObject) == false)
		{
			getErrorLog()->logPackageError("layout", LayoutTGGraphicalObjectSyntax,
				             getPackageVersion(), sbmlLevel, sbmlVersion);
		}
	}

	//
	// text string   ( use = "optional" )
	//
	assigned = attributes.readInto("text", mText);

	if (assigned == true && getErrorLog() != NULL)
	{
		// check string is not empty

		if (mText.empty() == true)
		{
			logEmptyString(mText, getLevel(), getVersion(), "<TextGlyph>");
		}
	}

	//
	// originOfText SIdRef   ( use = "optional" )
	//
	assigned = attributes.readInto("originOfText", mOriginOfText);

	if (assigned == true && getErrorLog() != NULL)
	{
		// check string is not empty and correct syntax

		if (mOriginOfText.empty() == true)
		{
			logEmptyString(mOriginOfText, getLevel(), getVersion(), "<TextGlyph>");
		}
		else if (SyntaxChecker::isValidSBMLSId(mOriginOfText) == false)
		{
			getErrorLog()->logPackageError("layout", LayoutTGOriginOfTextSyntax,
				             getPackageVersion(), sbmlLevel, sbmlVersion);
		}
	}

}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void TextGlyph::writeElements (XMLOutputStream& stream) const
{
  GraphicalObject::writeElements(stream);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void TextGlyph::writeAttributes (XMLOutputStream& stream) const
{
  GraphicalObject::writeAttributes(stream);
  if(this->isSetText())
  {
     stream.writeAttribute("text", getPrefix(), mText);
  }
  else if(this->isSetOriginOfTextId())
  {
     stream.writeAttribute("originOfText", getPrefix(), mOriginOfText);
  }
  if(this->isSetGraphicalObjectId())
  {
    stream.writeAttribute("graphicalObject",getPrefix(),  mGraphicalObject);
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
TextGlyph::getTypeCode () const
{
  return SBML_LAYOUT_TEXTGLYPH;
}

/*
 * Creates an XMLNode object from this.
 */
XMLNode TextGlyph::toXML() const
{
  return getXmlNodeForSBase(this);
}





#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
TextGlyph_t *
TextGlyph_create (void)
{
  return new(std::nothrow) TextGlyph;
}


LIBSBML_EXTERN
TextGlyph_t *
TextGlyph_createFrom (const TextGlyph_t *temp)
{
  return new(std::nothrow) TextGlyph(*temp);
}


LIBSBML_EXTERN
TextGlyph_t *
TextGlyph_createWith (const char *sid)
{
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) TextGlyph(&layoutns, sid ? sid : "", "");
}


LIBSBML_EXTERN
TextGlyph_t *
TextGlyph_createWithText (const char *id, const char *text)
{  
  LayoutPkgNamespaces layoutns;
  return new(std::nothrow) TextGlyph(&layoutns, id ? id : "", text ? text : "");
}


LIBSBML_EXTERN
void
TextGlyph_free (TextGlyph_t *tg)
{
  delete tg;
}


LIBSBML_EXTERN
void
TextGlyph_setText (TextGlyph_t *tg, const char *text)
{
  if (tg == NULL) return;
  tg->setText( text ? text : "" );
}


LIBSBML_EXTERN
void
TextGlyph_setOriginOfTextId (TextGlyph_t *tg, const char *sid)
{
  if (tg == NULL) return;
  tg->setOriginOfTextId( sid ? sid : "" );
}


LIBSBML_EXTERN
void
TextGlyph_setGraphicalObjectId (TextGlyph_t *tg, const char *sid)
{
  if (tg == NULL) return;
  tg->setGraphicalObjectId( sid ? sid : "" );
}


LIBSBML_EXTERN
const char *
TextGlyph_getText (const TextGlyph_t *tg)
{
  if (tg == NULL) return NULL;
  return tg->isSetText() ? tg->getText().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
TextGlyph_getGraphicalObjectId (const TextGlyph_t *tg)
{
  if (tg == NULL) return NULL;
  return tg->isSetGraphicalObjectId() ? tg->getGraphicalObjectId().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
TextGlyph_getOriginOfTextId (const TextGlyph_t *tg)
{
  if (tg == NULL) return NULL;
  return tg->isSetOriginOfTextId() ? tg->getOriginOfTextId().c_str() : NULL;
}


LIBSBML_EXTERN
int
TextGlyph_isSetText (const TextGlyph_t *tg)
{
  if (tg == NULL) return (int)false;
  return static_cast<int>( tg->isSetText() );
}


LIBSBML_EXTERN
int
TextGlyph_isSetOriginOfTextId (const TextGlyph_t *tg)
{
  if (tg == NULL) return (int)false;
  return static_cast<int>( tg->isSetOriginOfTextId() );
}


LIBSBML_EXTERN
int
TextGlyph_isSetGraphicalObjectId (const TextGlyph_t *tg)
{
  if (tg == NULL) return (int)false;
  return static_cast<int>( tg->isSetGraphicalObjectId() );
}


LIBSBML_EXTERN
void
TextGlyph_initDefaults (TextGlyph_t *tg)
{
  if (tg == NULL) return;
  tg->initDefaults();
}


LIBSBML_EXTERN
TextGlyph_t *
TextGlyph_clone (const TextGlyph_t *m)
{
  if (m == NULL) return NULL;
  return static_cast<TextGlyph*>( m->clone() );
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END

