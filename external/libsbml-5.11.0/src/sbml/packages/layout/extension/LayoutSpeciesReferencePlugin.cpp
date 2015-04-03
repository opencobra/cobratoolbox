/**
 * @file    LayoutSpeciesReferencePlugin.cpp
 * @brief   Implementation of LayoutSpeciesReferencePlugin, the plugin
 *          object of layout package (Level2) for the SpeciesReference 
 *          and ModifierSpeciesReference elements.
 * @author  Akiya Jouraku
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

#include <sbml/packages/layout/extension/LayoutSpeciesReferencePlugin.h>
#include <sbml/packages/layout/util/LayoutAnnotation.h>


#ifdef __cplusplus

using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * 
 */
LayoutSpeciesReferencePlugin::LayoutSpeciesReferencePlugin (const std::string &uri, 
                                                            const std::string &prefix,
                                                            LayoutPkgNamespaces* layoutns)
  : SBasePlugin(uri,prefix,layoutns)
{
}


/*
 * Copy constructor. Creates a copy of this SBase object.
 */
LayoutSpeciesReferencePlugin::LayoutSpeciesReferencePlugin(const LayoutSpeciesReferencePlugin& orig)
  : SBasePlugin(orig)
{
}


/*
 * Destroy this object.
 */
LayoutSpeciesReferencePlugin::~LayoutSpeciesReferencePlugin () {}

/*
 * Assignment operator for LayoutSpeciesReferencePlugin.
 */
LayoutSpeciesReferencePlugin& 
LayoutSpeciesReferencePlugin::operator=(const LayoutSpeciesReferencePlugin& orig)
{
  if(&orig!=this)
  {
    this->SBasePlugin::operator =(orig);
  }    

  return *this;
}


/*
 * Creates and returns a deep copy of this LayoutSpeciesReferencePlugin object.
 * 
 * @return a (deep) copy of this LayoutSpeciesReferencePlugin object
 */
LayoutSpeciesReferencePlugin* 
LayoutSpeciesReferencePlugin::clone () const
{
  return new LayoutSpeciesReferencePlugin(*this);  
}


/** @cond doxygenLibsbmlInternal */
bool 
LayoutSpeciesReferencePlugin::readOtherXML (SBase* parentObject, XMLInputStream& stream)
{
  if (!parentObject) return false;

  bool readAnnotationFromStream = false;

  //
  // This plugin object is used only for SBML Level 2 Version 1.
  //
  if ( getURI() != LayoutExtension::getXmlnsL2() ) return false;
  if ( parentObject->getVersion() > 1 )       return false;

  XMLNode *pAnnotation = parentObject->getAnnotation();

  if (!pAnnotation)
  {
    //
    // (NOTES)
    //
    // annotation element has not been parsed by the parent element
    // (SpeciesReference) of this plugin object, thus annotation 
    // element is parsed via the given XMLInputStream object in this block. 
    //
  
    const string& name = stream.peek().getName();

    if (name == "annotation")
    {
      pAnnotation = new XMLNode(stream); 

      SpeciesReference *sr = static_cast<SpeciesReference*>(parentObject);

      parseSpeciesReferenceAnnotation(pAnnotation,*sr);
      std::string srId = sr->getId();

      if (!srId.empty())
      {
        //
        // Removes the annotation for layout extension from the annotation
        // of parent element (pAnnotation) and then set the new annotation 
        // (newAnnotation) to the parent element.
        //
        deleteLayoutIdAnnotation(pAnnotation);        
      }

      parentObject->setAnnotation(pAnnotation);
      delete pAnnotation;

      readAnnotationFromStream = true;
    }
    
  }
  else if (parentObject->getId().empty())
  {
    //
    // (NOTES)
    //
    // annotation element has been parsed by the parent element
    // (SpeciesReference) of this plugin object, thus the annotation element 
    // set to the above pAnnotation variable is parsed in this block.
    //
    SpeciesReference *sr = static_cast<SpeciesReference*>(parentObject);
    parseSpeciesReferenceAnnotation(pAnnotation, *sr);
    std::string srId = sr->getId();

    if (!srId.empty())
    {
      //
      // Removes the annotation for layout extension from the annotation
      // of parent element (pAnnotation) and then set the new annotation 
      // (newAnnotation) to the parent element.
      //
      deleteLayoutIdAnnotation(pAnnotation);      
    }
    readAnnotationFromStream = true;
  }
  return readAnnotationFromStream;
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void 
LayoutSpeciesReferencePlugin::writeAttributes (XMLOutputStream& stream) const
{
  SimpleSpeciesReference *parent;
  parent = static_cast<SimpleSpeciesReference*>(const_cast<SBase*>(getParentSBMLObject()));

  if (!parent) return;

  //
  // This plugin object is used only for SBML Level 2 Version 1.
  //
  if ( getURI() != LayoutExtension::getXmlnsL2() ) return;
  // in a conversion the uri might be L2 but the model will be L3
  if ( parent->getLevel() != 2)               return;
  if ( parent->getVersion() > 1 )             return;

  XMLNode *annt = parseLayoutId(parent);
  if (annt)
  {
    //cout << "[DEBUG] LayoutSpeciesReferencePlugin::writeAttributes (before) " 
    //     << annt->toXMLString() << endl;

    //XMLNode *pAnnotation   = parent->getAnnotation();
    //XMLNode *newAnnotation = deleteLayoutAnnotation(pAnnotation);
    //parent->setAnnotation(newAnnotation);
    parent->appendAnnotation(annt);

    //cout << "[DEBUG] LayoutSpeciesReferencePlugin::writeAttributes (result) " 
    //     << result << " (annt) " << parent->getAnnotationString() << endl;

    //delete newAnnotation;
    delete annt;
  }
}
/** @endcond */


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
