/**
 * @file    LayoutModelPlugin.cpp
 * @brief   Implementation of LayoutModelPlugin, the plugin class of 
 *          layout package for the Model element.
 * @author  Akiya Jouraku
 *
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
 * Copyright (C) 2006-2008 by the California Institute of Technology,
 *     Pasadena, CA, USA 
 *  
 * Copyright (C) 2002-2005 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. Japan Science and Technology Agency, Japan
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */

#include <sbml/packages/layout/extension/LayoutModelPlugin.h>
#include <sbml/packages/layout/util/LayoutAnnotation.h>

#include <sbml/util/ElementFilter.h>

#include <sbml/packages/layout/validator/LayoutSBMLError.h>

#include <iostream>
using namespace std;


#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

List*
LayoutModelPlugin::getAllElements(ElementFilter *filter)
{
  List* ret = new List();
  List* sublist = NULL;

  ADD_FILTERED_LIST(ret, sublist, mLayouts, filter);  

  return ret;
}


/** @cond doxygenLibsbmlInternal */
int 
LayoutModelPlugin::appendFrom(const Model* model)
{
  int ret = LIBSBML_OPERATION_SUCCESS;

  if (model==NULL)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  const LayoutModelPlugin* modplug = 
    static_cast<const LayoutModelPlugin*>(model->getPlugin(getPrefix()));
  
  if (modplug==NULL)
  {
    return LIBSBML_INVALID_OBJECT;
  }

  Model* parent = static_cast<Model*>(getParentSBMLObject());

  if (parent==NULL) 
  {
    return LIBSBML_INVALID_OBJECT;
  }
  
  ret = mLayouts.appendFrom(modplug->getListOfLayouts());
  
  if (ret != LIBSBML_OPERATION_SUCCESS)
  {
    return ret;
  }


  for (unsigned int i = 0; i < mLayouts.SBase::getNumPlugins(); i++) 
  {
    ret = mLayouts.getPlugin(i)->appendFrom(model);
    if (ret != LIBSBML_OPERATION_SUCCESS) 
    {
      return ret;
    }
  }

  return ret;
}
/** @endcond */



/*
 * 
 */
LayoutModelPlugin::LayoutModelPlugin (const std::string &uri, 
                                      const std::string &prefix,
                                      LayoutPkgNamespaces *layoutns)
  : SBasePlugin(uri,prefix,layoutns)
   ,mLayouts(layoutns)
{
}


/*
 * Copy constructor. Creates a copy of this SBase object.
 */
LayoutModelPlugin::LayoutModelPlugin(const LayoutModelPlugin& orig)
  : SBasePlugin(orig)
  , mLayouts(orig.mLayouts)
{
}


/*
 * Destroy this object.
 */
LayoutModelPlugin::~LayoutModelPlugin () {}

/*
 * Assignment operator for LayoutModelPlugin.
 */
LayoutModelPlugin& 
LayoutModelPlugin::operator=(const LayoutModelPlugin& orig)
{
  if(&orig!=this)
  {
    this->SBasePlugin::operator =(orig);
    mLayouts    = orig.mLayouts;
  }    

  return *this;
}


/*
 * Creates and returns a deep copy of this LayoutModelPlugin object.
 * 
 * @return a (deep) copy of this LayoutModelPlugin object
 */
LayoutModelPlugin* 
LayoutModelPlugin::clone () const
{
  return new LayoutModelPlugin(*this);  
}


/** @cond doxygenLibsbmlInternal */
SBase*
LayoutModelPlugin::createObject(XMLInputStream& stream)
{
  SBase*        object = 0;

  const std::string&   name   = stream.peek().getName();
  const XMLNamespaces& xmlns  = stream.peek().getNamespaces();
  const std::string&   prefix = stream.peek().getPrefix();

  const std::string& targetPrefix = (xmlns.hasURI(mURI)) ? xmlns.getPrefix(mURI) : mPrefix;
  
  if (prefix == targetPrefix)
  {
    if ( name == "listOfLayouts" ) 
    {
      if (mLayouts.size() != 0)
      {
        getErrorLog()->logPackageError("layout", LayoutOnlyOneLOLayouts, 
          getPackageVersion(), getLevel(), getVersion());
      }

      //cout << "[DEBUG] LayoutModelPlugin::createObject create listOfLayouts" << endl;
      object = &mLayouts;
    
      if (targetPrefix.empty())
      {
        //
        // prefix is empty when writing elements in layout extension.
        //
        mLayouts.getSBMLDocument()->enableDefaultNS(mURI,true);
      }
    }          
  }    

  return object;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
bool 
LayoutModelPlugin::readOtherXML (SBase* parentObject, XMLInputStream& stream)
{
  // L2 layout parsed by the annotation API 
  // @see parseAnnotation / syncAnnotation
  return false; 

}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void 
LayoutModelPlugin::writeAttributes (XMLOutputStream& stream) const
{
  //
  // This function is used only for SBML Level 2.
  //
  if ( getURI() != LayoutExtension::getXmlnsL2() ) return;

  SBase *parent = const_cast<SBase*>(getParentSBMLObject());
  if (parent == NULL) 
    return;

  // when called this will serialize the annotation
  parent->getAnnotation();
  
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void
LayoutModelPlugin::writeElements (XMLOutputStream& stream) const
{
  //
  // This function is not used for SBML Level 2.
  //
  if ( getURI() == LayoutExtension::getXmlnsL2() ) return;

  if (mLayouts.size() > 0)
  {
    mLayouts.write(stream);
  }    
  // do nothing.  
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/* default for components that have no required elements */
bool
LayoutModelPlugin::hasRequiredElements() const
{
  bool allPresent = true;

  if ( mLayouts.size() < 1)
  {
    allPresent = false;    
  }
  
  return allPresent;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/* 
 * Parse L2 annotation if supported
 *
 */
void 
LayoutModelPlugin::parseAnnotation(SBase *parentObject, XMLNode *pAnnotation)
{
  mLayouts.setSBMLDocument(mSBML);  
  // don't read if we have an invalid node or already a layout|
  if (pAnnotation == NULL || mLayouts.size() > 0)
    return;

  // annotation element has been parsed by the parent element
  // (Model) of this plugin object, thus the annotation element 
  // set to the above pAnnotation variable is parsed in this block.
  
  XMLNode& listOfLayouts = pAnnotation->getChild("listOfLayouts");
  if (listOfLayouts.getNumChildren() == 0)
    return;
 
  // read the xml node, overriding that all errors are flagged as 
  // warnings
  mLayouts.read(listOfLayouts, LIBSBML_OVERRIDE_WARNING);
  // remove listOfLayouts annotation  
  parentObject->removeTopLevelAnnotationElement("listOfLayouts", "", false);
 

}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Synchronizes the annotation of this SBML object.
 */
void
LayoutModelPlugin::syncAnnotation (SBase *parentObject, XMLNode *pAnnotation)
{
  if(pAnnotation && pAnnotation->getNumChildren() > 0)
  {
      parentObject->removeTopLevelAnnotationElement("listOfLayouts", "", false);
  }

  // only do this for L1 and L2 documents
  if(getLevel() >= 3) 
    return;

  
  if (mLayouts.size() == 0)
    return;
  
  XMLNode * listOfLayouts = mLayouts.toXMLNode();
  if (listOfLayouts == NULL)
    return;

  
  if (pAnnotation == NULL)
  {
    // cannot happen, as syncAnnotation is called with a valid Annotation
    // (possibly empty)
    return;
  }
  else
  {
    if (pAnnotation->isEnd())
    {
        pAnnotation->unsetEnd();
    }
    pAnnotation->addChild(*listOfLayouts);
    delete listOfLayouts;
  }   
}
/** @endcond */


/*
 *
 *  (EXTENSION) Additional public functions
 *
 */  


/*
 * Returns the ListOf Layouts for this Model.
 */
const ListOfLayouts*
LayoutModelPlugin::getListOfLayouts () const
{
  return &this->mLayouts;
}


/*
 * Returns the ListOf Layouts for this Model.
 */
ListOfLayouts*
LayoutModelPlugin::getListOfLayouts ()
{
  return &this->mLayouts;
}


/*
 * Returns the layout object that belongs to the given index. If the index
 * is invalid, @c NULL is returned.
 */
const Layout*
LayoutModelPlugin::getLayout (unsigned int index) const
{
  return static_cast<const Layout*>( mLayouts.get(index) );
}


/*
 * Returns the layout object that belongs to the given index. If the index
 * is invalid, @c NULL is returned.
 */
Layout*
LayoutModelPlugin::getLayout (unsigned int index)
{
  return static_cast<Layout*>( mLayouts.get(index) );
}


/*
 * Returns the layout object with the given @p id attribute. If the
 * id is invalid, @c NULL is returned.
 */
const Layout*
LayoutModelPlugin::getLayout (const std::string& sid) const
{
  return static_cast<const Layout*>( mLayouts.get(sid) );
}


/*
 * Returns the layout object with the given @p id attribute. If the
 * id is invalid, @c NULL is returned.
 */
Layout*
LayoutModelPlugin::getLayout (const std::string& sid)
{
  return static_cast<Layout*>( mLayouts.get(sid) );
}


int 
LayoutModelPlugin::getNumLayouts() const
{
  return mLayouts.size();
}


/*
 * Adds a copy of the layout object to the list of layouts.
 */ 
int
LayoutModelPlugin::addLayout (const Layout* layout)
{
  if (layout == NULL)
  {
    return LIBSBML_OPERATION_FAILED;
  }
  //
  // (TODO) Layout::hasRequiredAttributes() and 
  //       Layout::hasRequiredElements() should be implemented.
  //
  else if (!(layout->hasRequiredAttributes()) || !(layout->hasRequiredElements()))
  {
    return LIBSBML_INVALID_OBJECT;
  }
  else if (getLevel() != layout->getLevel())
  {
    return LIBSBML_LEVEL_MISMATCH;
  }
  else if (getVersion() != layout->getVersion())
  {
    return LIBSBML_VERSION_MISMATCH;
  }
  else if (getPackageVersion() != layout->getPackageVersion())
  {
    return LIBSBML_PKG_VERSION_MISMATCH;
  }
  else if (getLayout(layout->getId()) != NULL)
  {
    // an object with this id already exists
    return LIBSBML_DUPLICATE_OBJECT_ID;
  }
  else
  {
    mLayouts.append(layout);
  }

  return LIBSBML_OPERATION_SUCCESS;
}


/*
 * Creates a new layout object and adds it to the list of layout objects.
 * A reference to the newly created object is returned.
 */
Layout*
LayoutModelPlugin::createLayout ()
{
  Layout* l = NULL;
  try
  {  
    LAYOUT_CREATE_NS(layoutns,getSBMLNamespaces());
    l = new Layout(layoutns);
    mLayouts.appendAndOwn(l);
    delete layoutns;
  }
  catch(...)
  {
    /* 
     * NULL will be returned if the mSBMLNS is invalid (basically this
     * should not happen) or some exception is thrown (e.g. std::bad_alloc)
     *
     * (Maybe this should be changed so that caller can detect what kind 
     *  of error happened in this function.)
     */
  }    
  
  return l;
}


/*
 * Removes the nth Layout object from this Model object and
 * returns a pointer to it.
 */
Layout* 
LayoutModelPlugin::removeLayout (unsigned int n)
{
  return static_cast<Layout*>(mLayouts.remove(n));
}


/** @cond doxygenLibsbmlInternal */
/*
 * Sets the parent SBMLDocument of this SBML object.
 *
 * @param d the SBMLDocument object to use
 */
void 
LayoutModelPlugin::setSBMLDocument (SBMLDocument* d)
{
  SBasePlugin::setSBMLDocument(d);

  mLayouts.setSBMLDocument(d);  
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Sets the parent SBML object of this plugin object to
 * this object and child elements (if any).
 * (Creates a child-parent relationship by this plugin object)
 */
void
LayoutModelPlugin::connectToParent (SBase* sbase)
{
  SBasePlugin::connectToParent(sbase);

  mLayouts.connectToParent(sbase);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Enables/Disables the given package with child elements in this plugin
 * object (if any).
 */
void
LayoutModelPlugin::enablePackageInternal(const std::string& pkgURI,
                                         const std::string& pkgPrefix, bool flag)
{
  mLayouts.enablePackageInternal(pkgURI,pkgPrefix,flag);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Accept the SBMLVisitor.
 */
bool
LayoutModelPlugin::accept(SBMLVisitor& v) const
{
	const Model * model = static_cast<const Model * >(this->getParentSBMLObject());

	v.visit(*model);
	v.leave(*model);

	for(int i = 0; i < getNumLayouts(); i++)
	{
		getLayout(i)->accept(v);
	}

	return true;
}
/** @endcond */




LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
