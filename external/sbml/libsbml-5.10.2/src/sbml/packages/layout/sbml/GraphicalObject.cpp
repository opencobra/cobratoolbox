/**
 * @file    GraphicalObject.cpp
 * @brief   Implementation of GraphicalObject for SBML Layout.
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

#include <sbml/packages/layout/util/LayoutUtilities.h>
#include <sbml/SBMLErrorLog.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/ExpectedAttributes.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/packages/layout/extension/LayoutExtension.h>
#include <sbml/packages/layout/common/LayoutExtensionTypes.h>
#include <sbml/packages/layout/validator/LayoutSBMLError.h>

#include <sbml/util/ElementFilter.h>

#if LIBSBML_HAS_PACKAGE_RENDER
#include <sbml/packages/render/extension/RenderGraphicalObjectPlugin.h>
#endif

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

List*
GraphicalObject::getAllElements(ElementFilter *filter)
{
  List* ret = new List();
  List* sublist = NULL;

  ADD_FILTERED_ELEMENT(ret, sublist, mBoundingBox, filter);

  ADD_FILTERED_FROM_PLUGIN(ret, sublist, filter);

  return ret;
}

void
GraphicalObject::renameMetaIdRefs(const std::string& oldid, const std::string& newid)
{
  SBase::renameMetaIdRefs(oldid, newid);
  if (isSetMetaIdRef() && mMetaIdRef == oldid)
  {
    mMetaIdRef = newid;
  }
}

/*
 * Creates a new GraphicalObject.
 */
GraphicalObject::GraphicalObject(unsigned int level, unsigned int version, unsigned int pkgVersion)
: SBase(level, version)
, mId("")
, mMetaIdRef("")
, mBoundingBox(level, version, pkgVersion)
, mBoundingBoxExplicitlySet(false)
{
  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level, version, pkgVersion));
}


/*
 * Creates a new GraphicalObject with the given @p id.
 */
GraphicalObject::GraphicalObject(LayoutPkgNamespaces* layoutns)
: SBase(layoutns)
, mId("")
, mMetaIdRef("")
, mBoundingBox(layoutns)
, mBoundingBoxExplicitlySet(false)
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
 * Creates a new GraphicalObject with the given @p id.
 */
GraphicalObject::GraphicalObject(LayoutPkgNamespaces* layoutns, const std::string& id)
: SBase(layoutns)
, mId(id)
, mMetaIdRef("")
, mBoundingBox(layoutns)
, mBoundingBoxExplicitlySet(false)
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
 * Creates a new GraphicalObject with the given @p id and 2D coordinates for
 * the bounding box.
 */
GraphicalObject::GraphicalObject(LayoutPkgNamespaces* layoutns, const std::string& id,
  double x, double y, double w, double h)
  : SBase(layoutns)
  , mId(id)
  , mMetaIdRef("")
  , mBoundingBox(BoundingBox(layoutns, "", x, y, 0.0, w, h, 0.0))
  , mBoundingBoxExplicitlySet(true)
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
 * Creates a new GraphicalObject with the given @p id and 3D coordinates for
 * the bounding box.
 */
GraphicalObject::GraphicalObject(LayoutPkgNamespaces* layoutns, const std::string& id,
  double x, double y, double z,
  double w, double h, double d)
  : SBase(layoutns)
  , mId(id)
  , mMetaIdRef("")
  , mBoundingBox(BoundingBox(layoutns, "", x, y, z, w, h, d))
  , mBoundingBoxExplicitlySet(true)
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
 * Creates a new GraphicalObject with the given @p id and 3D coordinates for
 * the bounding box.
 */
GraphicalObject::GraphicalObject(LayoutPkgNamespaces* layoutns, const std::string& id,
  const Point*       p,
  const Dimensions*  d)
  : SBase(layoutns)
  , mId(id)
  , mMetaIdRef("")
  , mBoundingBox(BoundingBox(layoutns, "", p, d))
  , mBoundingBoxExplicitlySet(true)
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
 * Creates a new GraphicalObject with the given @p id and 3D coordinates for
 * the bounding box.
 */
GraphicalObject::GraphicalObject(LayoutPkgNamespaces* layoutns, const std::string& id, const BoundingBox* bb)
: SBase(layoutns)
, mId(id)
, mMetaIdRef("")
, mBoundingBox(layoutns)
, mBoundingBoxExplicitlySet(false)
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());

  if (bb)
  {
    this->mBoundingBox = *bb;
    mBoundingBoxExplicitlySet = true;
  }

  connectToChild();

  //
  // load package extensions bound with this object (if any) 
  //
  loadPlugins(layoutns);
}

/*
 * Creates a new GraphicalObject from the given XMLNode
 */
GraphicalObject::GraphicalObject(const XMLNode& node, unsigned int l2version)
: SBase(2, l2version)
{
  //
  // (TODO) check the xmlns of layout extension
  //

  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(2, l2version));

  loadPlugins(getSBMLNamespaces());

  const XMLAttributes& attributes = node.getAttributes();
  const XMLNode* child;
  //ExpectedAttributes ea(getElementName());
  ExpectedAttributes ea;
  addExpectedAttributes(ea);
  this->readAttributes(attributes, ea);
  unsigned int n = 0, nMax = node.getNumChildren();
  while (n < nMax)
  {
    child = &node.getChild(n);
    const std::string& childName = child->getName();
    if (childName == "boundingBox")
    {
      this->mBoundingBox = BoundingBox(*child);
      mBoundingBoxExplicitlySet = true;
    }
    else if (childName == "annotation")
    {
      this->mAnnotation = new XMLNode(*child);
    }
    else if (childName == "notes")
    {
      this->mNotes = new XMLNode(*child);
    }
    else
    {
      //throw;
    }
    ++n;
  }

#if LIBSBML_HAS_PACKAGE_RENDER

  // explicitly read render plugin for now until we sorted this whole reading from 
  // XMLNode business
  RenderGraphicalObjectPlugin *rplugin = static_cast<RenderGraphicalObjectPlugin *>(getPlugin("render"));
  if (rplugin != NULL) {
    ExpectedAttributes expected;
    expected.add("objectRole");
    rplugin->readAttributes(node.getAttributes(), expected);
  }
#endif


  connectToChild();
}


/*
 * Copy constructor.
 */
GraphicalObject::GraphicalObject(const GraphicalObject& source) :SBase(source)
{
  this->mId = source.mId;
  this->mMetaIdRef = source.mMetaIdRef;
  this->mBoundingBox = *source.getBoundingBox();
  this->mBoundingBoxExplicitlySet = source.mBoundingBoxExplicitlySet;

  connectToChild();
}

/*
 * Assignment operator.
 */
GraphicalObject& GraphicalObject::operator=(const GraphicalObject& source)
{
  if (&source != this)
  {
    this->SBase::operator=(source);
    this->mId = source.mId;
    this->mMetaIdRef = source.mMetaIdRef;
    this->mBoundingBox = *source.getBoundingBox();
    this->mBoundingBoxExplicitlySet = source.mBoundingBoxExplicitlySet;

    connectToChild();
  }

  return *this;
}

/*
 * Destructor.
 */
GraphicalObject::~GraphicalObject()
{
}


/*
  * Returns the value of the "id" attribute of this GraphicalObject.
  */
const std::string& GraphicalObject::getId() const
{
  return mId;
}


/*
  * Predicate returning @c true or @c false depending on whether this
  * GraphicalObject's "id" attribute has been set.
  */
bool GraphicalObject::isSetId() const
{
  return (mId.empty() == false);
}

/*
  * Sets the value of the "id" attribute of this GraphicalObject.
  */
int GraphicalObject::setId(const std::string& id)
{
  if (&id != NULL && id.empty())
    return unsetId();
  return SyntaxChecker::checkAndSetSId(id, mId);
}


/*
  * Unsets the value of the "id" attribute of this GraphicalObject.
  */
int GraphicalObject::unsetId()
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
  * Returns the value of the "metaidRef" attribute of this GraphicalObject.
  */
const std::string& GraphicalObject::getMetaIdRef() const
{
  return mMetaIdRef;
}


/*
  * Predicate returning @c true or @c false depending on whether this
  * GraphicalObject's "metaidRef" attribute has been set.
  */
bool GraphicalObject::isSetMetaIdRef() const
{
  return (mMetaIdRef.empty() == false);
}

/*
  * Sets the value of the "metaidRef" attribute of this GraphicalObject.
  */
int GraphicalObject::setMetaIdRef(const std::string& metaid)
{
  if (&metaid != NULL && metaid.empty())
    return unsetMetaIdRef();
  return SyntaxChecker::checkAndSetSId(metaid, mMetaIdRef);
}


/*
  * Unsets the value of the "metaidRef" attribute of this GraphicalObject.
  */
int GraphicalObject::unsetMetaIdRef()
{
  mMetaIdRef.erase();
  if (mMetaIdRef.empty())
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Sets the boundingbox for the GraphicalObject.
 */
void
GraphicalObject::setBoundingBox(const BoundingBox* bb)
{
  if (bb == NULL) return;
  this->mBoundingBox = *bb;
  this->mBoundingBox.connectToParent(this);
  this->mBoundingBoxExplicitlySet = true;
}


/*
 * Returns the bounding box for the GraphicalObject.
 */
const BoundingBox*
GraphicalObject::getBoundingBox() const
{
  return &this->mBoundingBox;
}


/*
 * Returns the bounding box for the GraphicalObject.
 */
BoundingBox*
GraphicalObject::getBoundingBox()
{
  return &this->mBoundingBox;
}


bool
GraphicalObject::getBoundingBoxExplicitlySet() const
{
  return mBoundingBoxExplicitlySet;
}

/*
 * Does nothing. No defaults are defined for GraphicalObject.
 */
void
GraphicalObject::initDefaults()
{
}

/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string& GraphicalObject::getElementName() const
{
  static const std::string name = "graphicalObject";
  return name;
}

/*
 * @return a (deep) copy of this GraphicalObject.
 */
GraphicalObject*
GraphicalObject::clone() const
{
  return new GraphicalObject(*this);
}


/** @cond doxygenLibsbmlInternal */
SBase*
GraphicalObject::createObject(XMLInputStream& stream)
{

  const std::string& name = stream.peek().getName();
  SBase*        object = 0;

  if (name == "boundingBox")
  {
    if (getBoundingBoxExplicitlySet() == true)
    {
      int tc = this->getTypeCode();

      switch (tc)
      {
      case SBML_LAYOUT_COMPARTMENTGLYPH:
        getErrorLog()->logPackageError("layout", LayoutCGAllowedElements,
          getPackageVersion(), getLevel(), getVersion());
        break;
      case SBML_LAYOUT_REACTIONGLYPH:
        getErrorLog()->logPackageError("layout", LayoutRGAllowedElements,
          getPackageVersion(), getLevel(), getVersion());
        break;
      case SBML_LAYOUT_SPECIESGLYPH:
        getErrorLog()->logPackageError("layout", LayoutSGAllowedElements,
          getPackageVersion(), getLevel(), getVersion());
        break;
      case SBML_LAYOUT_SPECIESREFERENCEGLYPH:
        getErrorLog()->logPackageError("layout", LayoutSRGAllowedElements,
          getPackageVersion(), getLevel(), getVersion());
        break;
      case SBML_LAYOUT_TEXTGLYPH:
        getErrorLog()->logPackageError("layout", LayoutTGAllowedElements,
          getPackageVersion(), getLevel(), getVersion());
        break;
      case SBML_LAYOUT_REFERENCEGLYPH:
        getErrorLog()->logPackageError("layout", LayoutREFGAllowedElements,
          getPackageVersion(), getLevel(), getVersion());
        break;
      case SBML_LAYOUT_GENERALGLYPH:
        getErrorLog()->logPackageError("layout", LayoutGGAllowedElements,
          getPackageVersion(), getLevel(), getVersion());
        break;
      default:
        getErrorLog()->logPackageError("layout", LayoutGOMustContainBoundingBox,
          getPackageVersion(), getLevel(), getVersion());
        break;
      }
    }

    object = &mBoundingBox;
    mBoundingBoxExplicitlySet = true;
  }

  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
GraphicalObject::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  attributes.add("id");
  attributes.add("metaidRef");
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void GraphicalObject::readAttributes(const XMLAttributes& attributes,
  const ExpectedAttributes& expectedAttributes)
{
  const unsigned int sbmlLevel = getLevel();
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

  if (getErrorLog() != NULL && loSubGlyphs == true &&
    static_cast<ListOfGraphicalObjects*>(getParentSBMLObject())->size() < 2)
  {
    numErrs = getErrorLog()->getNumErrors();
    for (int n = numErrs - 1; n >= 0; n--)
    {
      if (getErrorLog()->getError(n)->getErrorId() == UnknownPackageAttribute)
      {
        const std::string details =
          getErrorLog()->getError(n)->getMessage();
        getErrorLog()->remove(UnknownPackageAttribute);
        getErrorLog()->logPackageError("layout",
          LayoutLOSubGlyphAllowedAttribs,
          getPackageVersion(), sbmlLevel, sbmlVersion, details);
      }
      else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
      {
        const std::string details =
          getErrorLog()->getError(n)->getMessage();
        getErrorLog()->remove(UnknownCoreAttribute);
        getErrorLog()->logPackageError("layout",
          LayoutLOSubGlyphAllowedAttribs,
          getPackageVersion(), sbmlLevel, sbmlVersion, details);
      }
    }
  }

  SBase::readAttributes(attributes, expectedAttributes);


  // look to see whether an unknown attribute error was logged
  if (getErrorLog() != NULL)
  {
    numErrs = getErrorLog()->getNumErrors();
    for (int n = numErrs - 1; n >= 0; n--)
    {
      if (getErrorLog()->getError(n)->getErrorId() == UnknownPackageAttribute)
      {
        const std::string details =
          getErrorLog()->getError(n)->getMessage();
        getErrorLog()->remove(UnknownPackageAttribute);

        int tc = this->getTypeCode();

        switch (tc)
        {
        case SBML_LAYOUT_COMPARTMENTGLYPH:
          getErrorLog()->logPackageError("layout", LayoutCGAllowedAttributes,
            getPackageVersion(), sbmlLevel, sbmlVersion, details);
          break;
        case SBML_LAYOUT_REACTIONGLYPH:
          getErrorLog()->logPackageError("layout", LayoutRGAllowedAttributes,
            getPackageVersion(), sbmlLevel, sbmlVersion, details);
          break;
        case SBML_LAYOUT_SPECIESGLYPH:
          getErrorLog()->logPackageError("layout", LayoutSGAllowedAttributes,
            getPackageVersion(), sbmlLevel, sbmlVersion, details);
          break;
        case SBML_LAYOUT_SPECIESREFERENCEGLYPH:
          getErrorLog()->logPackageError("layout", LayoutSRGAllowedAttributes,
            getPackageVersion(), sbmlLevel, sbmlVersion, details);
          break;
        case SBML_LAYOUT_TEXTGLYPH:
          getErrorLog()->logPackageError("layout", LayoutTGAllowedAttributes,
            getPackageVersion(), sbmlLevel, sbmlVersion, details);
          break;
        case SBML_LAYOUT_REFERENCEGLYPH:
          getErrorLog()->logPackageError("layout", LayoutREFGAllowedAttributes,
            getPackageVersion(), sbmlLevel, sbmlVersion, details);
          break;
        case SBML_LAYOUT_GENERALGLYPH:
          getErrorLog()->logPackageError("layout", LayoutGGAllowedAttributes,
            getPackageVersion(), sbmlLevel, sbmlVersion, details);
          break;
        default:
          getErrorLog()->logPackageError("layout", LayoutGOAllowedAttributes,
            getPackageVersion(), sbmlLevel, sbmlVersion, details);
          break;
        }
      }
      else if (getErrorLog()->getError(n)->getErrorId() == UnknownCoreAttribute)
      {
        const std::string details =
          getErrorLog()->getError(n)->getMessage();
        getErrorLog()->remove(UnknownCoreAttribute);
        int tc = this->getTypeCode();

#if !LIBSBML_HAS_PACKAGE_RENDER

        if (getLevel() == 2 && details.find("'render:objectRole'") != std::string::npos)
        {
          std::string role;
          attributes.readInto("objectRole", role);
          int index = attributes.getIndex("objectRole");
          mAttributesOfUnknownPkg.add("objectRole", role, attributes.getURI(index), attributes.getPrefix(index));
        }
        else
#endif


        switch (tc)
        {
          case SBML_LAYOUT_COMPARTMENTGLYPH:
            getErrorLog()->logPackageError("layout",
              LayoutCGAllowedCoreAttributes,
              getPackageVersion(), sbmlLevel, sbmlVersion, details);
            break;
          case SBML_LAYOUT_REACTIONGLYPH:
            getErrorLog()->logPackageError("layout",
              LayoutRGAllowedCoreAttributes,
              getPackageVersion(), sbmlLevel, sbmlVersion, details);
            break;
          case SBML_LAYOUT_SPECIESGLYPH:
            getErrorLog()->logPackageError("layout",
              LayoutSGAllowedCoreAttributes,
              getPackageVersion(), sbmlLevel, sbmlVersion, details);
            break;
          case SBML_LAYOUT_SPECIESREFERENCEGLYPH:
            getErrorLog()->logPackageError("layout",
              LayoutSRGAllowedCoreAttributes,
              getPackageVersion(), sbmlLevel, sbmlVersion, details);
            break;
          case SBML_LAYOUT_TEXTGLYPH:
            getErrorLog()->logPackageError("layout",
              LayoutTGAllowedCoreAttributes,
              getPackageVersion(), sbmlLevel, sbmlVersion, details);
            break;
          case SBML_LAYOUT_REFERENCEGLYPH:
            getErrorLog()->logPackageError("layout",
              LayoutREFGAllowedCoreAttributes,
              getPackageVersion(), sbmlLevel, sbmlVersion, details);
            break;
          case SBML_LAYOUT_GENERALGLYPH:
            getErrorLog()->logPackageError("layout",
              LayoutGGAllowedCoreAttributes,
              getPackageVersion(), sbmlLevel, sbmlVersion, details);
            break;
          default:
            getErrorLog()->logPackageError("layout",
              LayoutGOAllowedCoreAttributes,
              getPackageVersion(), sbmlLevel, sbmlVersion, details);
            break;
        }
      }
    }
  }

  // id reqd
  bool assigned = attributes.readInto("id", mId);

  if (getErrorLog() != NULL)
  {

    if (assigned == true)
    {
      // "id" attribute is set to this fbc element

      if (mId.empty())
      {
        //
        // Logs an error if the "id" attribute is empty.
        //
        logEmptyString(mId, sbmlLevel, sbmlVersion, "<layout>");
      }
      else if (!SyntaxChecker::isValidSBMLSId(mId))
      {
        //
        // Logs an error if the "id" attribute doesn't
        // conform to the SBML type SId.
        //
        getErrorLog()->logPackageError("layout", LayoutSIdSyntax,
          getPackageVersion(), sbmlLevel, sbmlVersion);
      }
    }
    else
    {
      int tc = this->getTypeCode();

      switch (tc)
      {
      case SBML_LAYOUT_COMPARTMENTGLYPH:
        getErrorLog()->logPackageError("layout", LayoutCGAllowedAttributes,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      case SBML_LAYOUT_REACTIONGLYPH:
        getErrorLog()->logPackageError("layout", LayoutRGAllowedAttributes,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      case SBML_LAYOUT_SPECIESGLYPH:
        getErrorLog()->logPackageError("layout", LayoutSGAllowedAttributes,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      case SBML_LAYOUT_SPECIESREFERENCEGLYPH:
        getErrorLog()->logPackageError("layout", LayoutSRGAllowedAttributes,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      case SBML_LAYOUT_TEXTGLYPH:
        getErrorLog()->logPackageError("layout", LayoutTGAllowedAttributes,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      case SBML_LAYOUT_REFERENCEGLYPH:
        getErrorLog()->logPackageError("layout", LayoutREFGAllowedAttributes,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      case SBML_LAYOUT_GENERALGLYPH:
        getErrorLog()->logPackageError("layout", LayoutGGAllowedAttributes,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      default:
        getErrorLog()->logPackageError("layout", LayoutGOAllowedAttributes,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      }
    }
  }
  assigned = attributes.readInto("metaidRef", mMetaIdRef);
  if (assigned == true && getErrorLog() != NULL)
  {
    if (!SyntaxChecker::isValidInternalSId(mMetaIdRef))
    {
      int tc = this->getTypeCode();

      switch (tc)
      {
      case SBML_LAYOUT_COMPARTMENTGLYPH:
        getErrorLog()->logPackageError("layout", LayoutCGMetaIdRefMustBeIDREF,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      case SBML_LAYOUT_REACTIONGLYPH:
        getErrorLog()->logPackageError("layout", LayoutRGMetaIdRefMustBeIDREF,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      case SBML_LAYOUT_SPECIESGLYPH:
        getErrorLog()->logPackageError("layout", LayoutSGMetaIdRefMustBeIDREF,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      case SBML_LAYOUT_SPECIESREFERENCEGLYPH:
        getErrorLog()->logPackageError("layout", LayoutSRGMetaIdRefMustBeIDREF,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      case SBML_LAYOUT_TEXTGLYPH:
        getErrorLog()->logPackageError("layout", LayoutTGMetaIdRefMustBeIDREF,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      case SBML_LAYOUT_REFERENCEGLYPH:
        getErrorLog()->logPackageError("layout", LayoutREFGMetaIdRefMustBeIDREF,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      case SBML_LAYOUT_GENERALGLYPH:
        getErrorLog()->logPackageError("layout", LayoutGGMetaIdRefMustBeIDREF,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      default:
        getErrorLog()->logPackageError("layout", LayoutGOMetaIdRefMustBeIDREF,
          getPackageVersion(), sbmlLevel, sbmlVersion);
        break;
      }
    }
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
GraphicalObject::writeElements(XMLOutputStream& stream) const
{
  SBase::writeElements(stream);

  mBoundingBox.write(stream);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void GraphicalObject::writeAttributes(XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);
  stream.writeAttribute("id", getPrefix(), mId);

  if (isSetMetaIdRef())
    stream.writeAttribute("metaidRef", getPrefix(), mMetaIdRef);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */



/** @cond doxygenLibsbmlInternal */

#if LIBSBML_HAS_PACKAGE_RENDER

bool isL3RenderNamespaceDeclared(const SBMLDocument* doc, const RenderGraphicalObjectPlugin* plugin)
{
  if (doc == NULL || plugin == NULL) return false;
  if (doc->getSBMLNamespaces() == NULL) return false;
  if (doc->getSBMLNamespaces()->getNamespaces() == NULL) return false;

  const std::string& prefix = plugin->getPrefix();
  const std::string& uri = doc->getSBMLNamespaces()->getNamespaces()->getURI(plugin->getPrefix());

  return !uri.empty() && uri != RenderExtension::getXmlnsL2();

}

#endif

void
GraphicalObject::writeXMLNS(XMLOutputStream& stream) const
{
#if LIBSBML_HAS_PACKAGE_RENDER
  const RenderGraphicalObjectPlugin* plugin = static_cast<const RenderGraphicalObjectPlugin*>(getPlugin("render"));
  if ( plugin != NULL && plugin->isSetObjectRole())
  {
    // need to define this namespace also if it was not yet declared on the document!
    if (getLevel() < 3 || 
      !isL3RenderNamespaceDeclared(getSBMLDocument(),plugin) )
    {
      XMLNamespaces xmlns;
      xmlns.add(plugin->getURI(), plugin->getPrefix());
      stream << xmlns;
    }
  }
#else

  if (getLevel() < 3)
    for (int i = 0; i < mAttributesOfUnknownPkg.getNumAttributes(); ++i)
    {
      if (mAttributesOfUnknownPkg.getName(i) == "objectRole" && !mAttributesOfUnknownPkg.getPrefix(i).empty())
      {
        XMLNamespaces xmlns;
        xmlns.add(mAttributesOfUnknownPkg.getURI(i), mAttributesOfUnknownPkg.getPrefix(i));
        stream << xmlns;
        break;
      }
    }

#endif
}
/** @endcond */


/*
 * Returns the package type code  for this object.
 */
int
GraphicalObject::getTypeCode() const
{
  return SBML_LAYOUT_GRAPHICALOBJECT;
}


/*
 * Accepts the given SBMLVisitor.
 */
bool
GraphicalObject::accept(SBMLVisitor& v) const
{
  v.visit(*this);

  if (getBoundingBoxExplicitlySet() == true)
  {
    this->mBoundingBox.accept(v);
  }

  v.leave(*this);

  return true;
}

/*
 * Creates an XMLNode object from this.
 */
XMLNode GraphicalObject::toXML() const
{
  return getXmlNodeForSBase(this);
}


/** @cond doxygenLibsbmlInternal */
/*
 * Sets the parent SBMLDocument of this SBML object.
 */
void
GraphicalObject::setSBMLDocument(SBMLDocument* d)
{
  SBase::setSBMLDocument(d);

  mBoundingBox.setSBMLDocument(d);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Sets this SBML object to child SBML objects (if any).
 * (Creates a child-parent relationship by the parent)
 */
void
GraphicalObject::connectToChild()
{
  SBase::connectToChild();
  mBoundingBox.connectToParent(this);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Enables/Disables the given package with this element and child
 * elements (if any).
 * (This is an internal implementation for enablePakcage function)
 */
void
GraphicalObject::enablePackageInternal(const std::string& pkgURI,
const std::string& pkgPrefix, bool flag)
{
  SBase::enablePackageInternal(pkgURI, pkgPrefix, flag);

  mBoundingBox.enablePackageInternal(pkgURI, pkgPrefix, flag);
}
/** @endcond */



/*
 * Ctor.
 */
ListOfGraphicalObjects::ListOfGraphicalObjects(LayoutPkgNamespaces* layoutns)
: ListOf(layoutns)
, mElementName("listOfAdditionalGraphicalObjects")
{
  //
  // set the element namespace of this object
  //
  setElementNamespace(layoutns->getURI());
}


/*
 * Ctor.
 */
ListOfGraphicalObjects::ListOfGraphicalObjects(unsigned int level, unsigned int version, unsigned int pkgVersion)
: ListOf(level, version)
, mElementName("listOfAdditionalGraphicalObjects")
{
  setSBMLNamespacesAndOwn(new LayoutPkgNamespaces(level, version, pkgVersion));
};


/*
 * @return a (deep) copy of this ListOfGraphicalObjects.
 */
ListOfGraphicalObjects*
ListOfGraphicalObjects::clone() const
{
  return new ListOfGraphicalObjects(*this);
}


/*
 * @return the typecode (int) of SBML objects contained in this ListOf or
 * SBML_UNKNOWN (default).
 */
int
ListOfGraphicalObjects::getItemTypeCode() const
{
  return SBML_LAYOUT_GRAPHICALOBJECT;
}


/*
 * Returns the XML element name of
 * this SBML object.
 */
const std::string&
ListOfGraphicalObjects::getElementName() const
{
  return mElementName;
}

/** @cond doxygenLibsbmlInternal */
void
ListOfGraphicalObjects::setElementName(const std::string &elementName)
{
  mElementName = elementName;
}
/** @endcond **/


/* return nth item in list */
GraphicalObject *
ListOfGraphicalObjects::get(unsigned int n)
{
  return static_cast<GraphicalObject*>(ListOf::get(n));
}


/* return nth item in list */
const GraphicalObject *
ListOfGraphicalObjects::get(unsigned int n) const
{
  return static_cast<const GraphicalObject*>(ListOf::get(n));
}


/* return item by id */
GraphicalObject*
ListOfGraphicalObjects::get(const std::string& sid)
{
  return const_cast<GraphicalObject*>(
    static_cast<const ListOfGraphicalObjects&>(*this).get(sid));
}


/* return item by id */
const GraphicalObject*
ListOfGraphicalObjects::get(const std::string& sid) const
{
  std::vector<SBase*>::const_iterator result;

  result = std::find_if(mItems.begin(), mItems.end(), IdEq<GraphicalObject>(sid));
  return (result == mItems.end()) ? 0 : static_cast <GraphicalObject*> (*result);
}


/* Removes the nth item from this list */
GraphicalObject*
ListOfGraphicalObjects::remove(unsigned int n)
{
  return static_cast<GraphicalObject*>(ListOf::remove(n));
}


/* Removes item in this list by id */
GraphicalObject*
ListOfGraphicalObjects::remove(const std::string& sid)
{
  SBase* item = 0;
  std::vector<SBase*>::iterator result;

  result = std::find_if(mItems.begin(), mItems.end(), IdEq<GraphicalObject>(sid));

  if (result != mItems.end())
  {
    item = *result;
    mItems.erase(result);
  }

  return static_cast <GraphicalObject*> (item);
}


/** @cond doxygenLibsbmlInternal */
SBase*
ListOfGraphicalObjects::createObject(XMLInputStream& stream)
{
  const std::string& name = stream.peek().getName();
  SBase*        object = 0;


  LAYOUT_CREATE_NS(layoutns, this->getSBMLNamespaces());
  if (name == "graphicalObject")
  {
    object = new GraphicalObject(layoutns);
    appendAndOwn(object);
  }
  else if (name == "generalGlyph")
  {
    object = new GeneralGlyph(layoutns);
    appendAndOwn(object);
  }
  else if (name == "textGlyph")
  {
    object = new TextGlyph(layoutns);
    appendAndOwn(object);
  }
  else if (name == "speciesGlyph")
  {
    object = new SpeciesGlyph(layoutns);
    appendAndOwn(object);
  }
  else if (name == "compartmentGlyph")
  {
    object = new CompartmentGlyph(layoutns);
    appendAndOwn(object);
  }
  else if (name == "reactionGlyph")
  {
    object = new ReactionGlyph(layoutns);
    appendAndOwn(object);
  }
  else if (name == "speciesReferenceGlyph")
  {
    object = new SpeciesReferenceGlyph(layoutns);
    appendAndOwn(object);
  }
  else if (name == "referenceGlyph")
  {
    object = new ReferenceGlyph(layoutns);
    appendAndOwn(object);
  }

  delete layoutns;
  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
bool
ListOfGraphicalObjects::isValidTypeForList(SBase * item)
{
  int tc = item->getTypeCode();
  return ((tc == SBML_LAYOUT_COMPARTMENTGLYPH)
    || (tc == SBML_LAYOUT_REACTIONGLYPH)
    || (tc == SBML_LAYOUT_SPECIESGLYPH)
    || (tc == SBML_LAYOUT_SPECIESREFERENCEGLYPH)
    || (tc == SBML_LAYOUT_TEXTGLYPH)
    || (tc == SBML_LAYOUT_GRAPHICALOBJECT)
    || (tc == SBML_LAYOUT_REFERENCEGLYPH)
    || (tc == SBML_LAYOUT_GENERALGLYPH)
    );
}
/** @endcond */

XMLNode ListOfGraphicalObjects::toXML() const
{
  return getXmlNodeForSBase(this);
}



#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
GraphicalObject_t *
GraphicalObject_create(void)
{
  return new(std::nothrow) GraphicalObject;
}


LIBSBML_EXTERN
GraphicalObject_t *
GraphicalObject_createFrom(const GraphicalObject_t *temp)
{
  return new(std::nothrow) GraphicalObject(*temp);
}

LIBSBML_EXTERN
void
GraphicalObject_free(GraphicalObject_t *go)
{
  delete go;
}

LIBSBML_EXTERN
void
GraphicalObject_setBoundingBox(GraphicalObject_t *go, const BoundingBox_t *bb)
{
  if (go == NULL) return;
  go->setBoundingBox(bb);
}

LIBSBML_EXTERN
BoundingBox_t *
GraphicalObject_getBoundingBox(GraphicalObject_t *go)
{
  if (go == NULL) return NULL;
  return go->getBoundingBox();
}

LIBSBML_EXTERN
void
GraphicalObject_initDefaults(GraphicalObject_t *go)
{
  if (go == NULL) return;
  go->initDefaults();
}

LIBSBML_EXTERN
GraphicalObject_t *
GraphicalObject_clone(const GraphicalObject_t *m)
{
  if (m == NULL) return NULL;
  return static_cast<GraphicalObject*>(m->clone());
}

LIBSBML_EXTERN
int
GraphicalObject_isSetId(const GraphicalObject_t *go)
{
  if (go == NULL) return (int)false;
  return static_cast <int> (go->isSetId());
}

LIBSBML_EXTERN
const char *
GraphicalObject_getId(const GraphicalObject_t *go)
{
  if (go == NULL) return NULL;
  return go->isSetId() ? go->getId().c_str() : NULL;
}

LIBSBML_EXTERN
int
GraphicalObject_setId(GraphicalObject_t *go, const char *sid)
{
  if (go == NULL) return (int)false;
  return (sid == NULL) ? go->setId("") : go->setId(sid);
}

LIBSBML_EXTERN
void
GraphicalObject_unsetId(GraphicalObject_t *go)
{
  if (go == NULL) return;
  go->unsetId();
}

/** @endcond */
LIBSBML_CPP_NAMESPACE_END

