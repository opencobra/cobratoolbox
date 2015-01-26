/**
 * @file    LayoutUtilities.cpp
 * @brief   Implementation of some methods used by many of the layout files.
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
#include <sbml/xml/XMLAttributes.h>
#include <sbml/common/extern.h>


LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

LIBSBML_EXTERN
void 
addSBaseAttributes(const SBase& object,XMLAttributes& att)
{
   if(object.isSetMetaId())
   { 
     att.add("metaid",object.getMetaId());
   }
}

LIBSBML_EXTERN
void 
addGraphicalObjectAttributes(const GraphicalObject& object,XMLAttributes& att)
{
    att.add("id",object.getId());
}

LIBSBML_EXTERN XMLNode getXmlNodeForSBase(const SBase* object)
{
  char* rawsbml = const_cast<SBase*>(object)->toSBML();  
  SBMLNamespaces *sbmlns = object->getSBMLNamespaces();
  XMLNamespaces* xmlns = sbmlns->getNamespaces()->clone();
  // in rare cases the above returns a package element with default namespace, however the 
  // XMLNamespaces would then assign the actual default namespace, which is in most cases
  // the SBML namespace. In that case we adjust the default namespace here
  ISBMLExtensionNamespaces *extns = dynamic_cast<ISBMLExtensionNamespaces*>(sbmlns);
  if (extns != NULL)
  {
    xmlns->remove("");
    xmlns->add(xmlns->getURI(extns->getPackageName()), "");    
  }

  XMLNode* tmp = XMLNode::convertStringToXMLNode(rawsbml, xmlns);
  if (tmp == NULL) return XMLNode();
  XMLNode result(*tmp);
  delete tmp;
  delete xmlns;
  free(rawsbml);
  return result;
}

LIBSBML_EXTERN
void 
copySBaseAttributes(const SBase& source,SBase& target)
{
    target.setMetaId(source.getMetaId());
//    target.setId(source.getId());
//    target.setName(source.getName());
    target.setSBMLDocument(const_cast<SBMLDocument*>(source.getSBMLDocument()));
    target.setSBOTerm(source.getSBOTerm());
    if(source.isSetAnnotation())
    {
      target.setAnnotation(new XMLNode(*const_cast<SBase&>(source).getAnnotation()));
    }
    if(source.isSetNotes())
    {
      target.setNotes(new XMLNode(*const_cast<SBase&>(source).getNotes()));
    }
    if (source.getSBMLNamespaces())
    {
      target.setSBMLNamespaces(source.getSBMLNamespaces());
    }
    List* pCVTerms=target.getCVTerms();
    // first delete all the old CVTerms
    if(pCVTerms)
    {
      while(pCVTerms->getSize()>0)
      {
        CVTerm* object=static_cast<CVTerm*>(pCVTerms->remove(0));
        delete object;
      }
      // add the cloned CVTerms from source
      if(source.getCVTerms()!=NULL)
      {
          unsigned int i=0,iMax=source.getCVTerms()->getSize();
          while(i<iMax)
          {
              target.addCVTerm(static_cast<CVTerm*>(static_cast<CVTerm*>(source.getCVTerms()->get(i))->clone()));
              ++i;
          }
      }
    }
}

#endif /* __cplusplus */
LIBSBML_CPP_NAMESPACE_END
