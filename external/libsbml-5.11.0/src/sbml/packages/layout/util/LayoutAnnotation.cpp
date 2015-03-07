/**
 * @file    LayoutAnnotation.cpp
 * @brief   Layout annotation I/O
 * @author  Ralph Gauges
 * @author  Akiya Jouraku (Modified this file for package extension in libSBML 5)
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

#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLErrorLog.h>

#include <sbml/SBase.h>
#include <sbml/Model.h>

#include <sbml/SBMLErrorLog.h>

#include <sbml/util/util.h>
#include <sbml/util/List.h>

#include <sbml/annotation/ModelHistory.h>

#include <sbml/packages/layout/sbml/Layout.h>
#include <sbml/packages/layout/util/LayoutAnnotation.h>
#include <sbml/packages/layout/extension/LayoutModelPlugin.h>
#include <sbml/packages/layout/extension/LayoutSpeciesReferencePlugin.h>


/** @cond doxygenIgnore */

using namespace std;

/** @endcond doxygenIgnore */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/*
 * takes an annotation that has been read into the model
 * identifies the listOfLayouts element and creates a List of 
 * Layouts from the annotation
 */
LIBSBML_EXTERN
void 
parseLayoutAnnotation(XMLNode * annotation, ListOfLayouts& layouts)
{

  if (!annotation) return;

  const string&  name = annotation->getName();
  const XMLNode*  LayoutTop = NULL;
  Layout* layout;
  unsigned int n = 0;

  // need to find the layout desciption opening annotation
  if (name == "annotation" && annotation->getNumChildren() > 0)
  {
    while (n < annotation->getNumChildren())
    {
      const string &name1 = annotation->getChild(n).getName();
      if (name1 == "listOfLayouts") // also check the namespace
      {
        const XMLNamespaces& namespaces=annotation->getChild(n).getNamespaces();
        if(namespaces.getIndex("http://projects.eml.org/bcb/sbml/level2")!=-1)
        {
          LayoutTop = &(annotation->getChild(n));
          break;
        }
      }
      n++;
    }
  }

  // find qualifier nodes and create 

  
  n = 0;
  if (LayoutTop)
  {
    while (n < LayoutTop->getNumChildren())
    {
      const string &name2 = LayoutTop->getChild(n).getName();
      
      if (name2 == "annotation")
      {
        const XMLNode &annot = LayoutTop->getChild(n);
        layouts.setAnnotation(&annot);
      }
      
      if (name2 == "layout")
      {
        layout = new Layout(LayoutTop->getChild(n));
        layouts.appendAndOwn(layout);
      }

      n++;
    }
  }
}

  
/*
 * Takes an XMLNode and tries to find the layout annotation node and deletes it if it was found.
 */
LIBSBML_EXTERN
XMLNode* deleteLayoutAnnotation(XMLNode* pAnnotation)
{
  if (!pAnnotation) return 0;

  const string&  name = pAnnotation->getName();
  unsigned int n = 0;

  // need to find each annotation and remove it if it is an RDF
  if (name == "annotation" && pAnnotation->getNumChildren() > 0)
  {
    while (n < pAnnotation->getNumChildren())
    {
      const string &name1 = pAnnotation->getChild(n).getName();
      if (name1 == "listOfLayouts" || 
        pAnnotation->getChild(n).getNamespaces().getIndex("http://projects.eml.org/bcb/sbml/level2")!=-1)
      {
        delete pAnnotation->removeChild(n);
        continue;
      }
      n++;
    }
  }

  return pAnnotation;
}

/*
 * Creates an XMLNode that represents the layouts of the model from the given Model object.
 */
LIBSBML_EXTERN
XMLNode* parseLayouts(const Model* pModel)
{
  if (!pModel) return 0;
  
  XMLToken ann_token = XMLToken(XMLTriple("annotation", "", ""), XMLAttributes()); 
  XMLNode* pNode = new XMLNode(ann_token);
  const LayoutModelPlugin* lep;

  lep = static_cast<const LayoutModelPlugin*>(pModel->getPlugin("layout"));
  ListOfLayouts* lol = const_cast<ListOfLayouts*>(lep->getListOfLayouts());
  if( lol->size()>0)
  {        
    // then add the ones toXML()
    pNode->addChild(lep->getListOfLayouts()->toXML());
  }
  return pNode;
}
 
  
  

/*
 * takes an annotation that has been read into the species reference
 * identifies the id elements and set the id of the species reference
 */
LIBSBML_EXTERN
void 
parseSpeciesReferenceAnnotation(XMLNode * annotation, SimpleSpeciesReference& sr)
{
  if (!annotation) return;

  const string&  name = annotation->getName();
  unsigned int n=0;
  // need to find the layout desciption opening annotation
  if (name == "annotation" && annotation->getNumChildren() > 0)
  {
    while (n < annotation->getNumChildren())
    {
      const string &name1 = annotation->getChild(n).getName();
      if (name1 == "layoutId") // also check the namespace
      {
        const XMLNamespaces& namespaces=annotation->getChild(n).getNamespaces();
        if(namespaces.getIndex("http://projects.eml.org/bcb/sbml/level2")!=-1)
        {
          
          // set the id of the species reference
          int index=annotation->getChild(n).getAttributes().getIndex("id");
          assert(index!=-1);

          sr.setId(annotation->getChild(n).getAttributes().getValue(index));
          break;
        }
      }
      n++;
    }
  }  

}

  
/*
 * Takes an XMLNode and tries to find the layoutId annotation node and deletes it if it was found.
 */
LIBSBML_EXTERN
XMLNode* deleteLayoutIdAnnotation(XMLNode* pAnnotation)
{
  if (!pAnnotation) return 0;

  const string&  name = pAnnotation->getName();
  unsigned int n = 0;

  // need to find the layoutId annotation
  if (name == "annotation" && pAnnotation->getNumChildren() > 0)
  {
    while (n < pAnnotation->getNumChildren())
    {
      const string &name1 = pAnnotation->getChild(n).getName();
      if (name1 == "layoutId" || 
        pAnnotation->getChild(n).getNamespaces().getIndex("http://projects.eml.org/bcb/sbml/level2")!=-1)
      {
        delete pAnnotation->removeChild(n);
        continue;
      }
      n++;
    }
  }

  return pAnnotation;
}

/*
 * Creates an XMLNode that represents the layoutId annotation of the species reference from the given SpeciesReference object.
 *
 * (TODO) 
 *
 */
LIBSBML_EXTERN
XMLNode* parseLayoutId(const SimpleSpeciesReference* sr)
{
  if (!sr || !sr->isSetId()) return 0;

  XMLToken ann_token = XMLToken(XMLTriple("annotation", "", ""), XMLAttributes()); 
  XMLNode* pNode = new XMLNode(ann_token);
  XMLNamespaces xmlns = XMLNamespaces();
  xmlns.add("http://projects.eml.org/bcb/sbml/level2", "");
  XMLTriple triple = XMLTriple("layoutId", "", "");
  XMLAttributes id_att = XMLAttributes();
  id_att.add("id", sr->getId());
  XMLToken token = XMLToken(triple, id_att, xmlns); 
  XMLNode node(token);
  pNode->addChild(node);
  return pNode;
}

#endif /* __cplusplus */
LIBSBML_CPP_NAMESPACE_END
