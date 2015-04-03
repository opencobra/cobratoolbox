/**
 * @file    SBasePluginCreator.h
 * @brief   Template class for SBasePlugin-based classes.
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
 *
 * @class SBasePluginCreator
 * @sbmlbrief{core} Template for SBasePlugin factory objects.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * @copydetails doc_extension_sbaseplugincreator
 */

#ifndef SBasePluginCreator_h
#define SBasePluginCreator_h


#include <sbml/extension/SBasePluginCreatorBase.h>
#include <sbml/extension/SBMLExtensionNamespaces.h>
#include <sbml/extension/SBMLExtensionRegistry.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

template<class SBasePluginType, class SBMLExtensionType>
class LIBSBML_EXTERN SBasePluginCreator : public SBasePluginCreatorBase
{
public:

  /**
   * Constructor for SBasePluginCreator.
   *
   * @param extPoint the SBaseExtensionPoint object that defines the
   * extension point.
   *
   * @param packageURIs a vector of XML namespace URIs that identifies
   * the SBML package namespaces to which this extension applies.
   */

  SBasePluginCreator (const SBaseExtensionPoint& extPoint,
                      const std::vector<std::string>& packageURIs)
    : SBasePluginCreatorBase(extPoint, packageURIs) {}


  /**
   * Copy constructor for SBasePluginCreator.
   *
   * @param orig the object to copy.
   */
  SBasePluginCreator(const SBasePluginCreator& orig)
   : SBasePluginCreatorBase(orig) {}


  /**
   * Destroys this object.
   */
  virtual ~SBasePluginCreator () {}


  /**
   * Creats an SBasePlugin object with a given URI and namespace prefix.
   *
   * @param uri the XML namespace URI for the SBML package implemented
   * by this libSBML package extension.
   *
   * @param prefix the XML namespace prefix of the package (e.g.,
   * <code>"layout"</code>, <code>"multi"</code>).
   *
   * @param xmlns an XMLNamespaces object that identifies namespaces in
   * use by this package extension
   */
  virtual SBasePluginType* createPlugin(const std::string& uri,
                                        const std::string& prefix,
                                        const XMLNamespaces *xmlns) const
  {
    const SBMLExtension *sbmlext  = SBMLExtensionRegistry::getInstance().getExtensionInternal(uri);
    unsigned int level      = sbmlext->getLevel(uri);
    unsigned int version    = sbmlext->getVersion(uri);
    unsigned int pkgVersion = sbmlext->getPackageVersion(uri);

    SBMLExtensionNamespaces<SBMLExtensionType> extns(level, version, pkgVersion, prefix);
    extns.addNamespaces(xmlns);

    return new SBasePluginType(uri,prefix,&extns);
  }


  /**
   * Creates and returns a deep copy of this SBasePluginCreator object.
   *
   * @return the (deep) copy of this SBasePluginCreator object.
   */
  virtual SBasePluginCreator* clone () const
  {
    return new SBasePluginCreator(*this);
  }


protected:
  /** @cond doxygenLibsbmlInternal */

  /** @endcond */


private:
  /** @cond doxygenLibsbmlInternal */

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* SBasePluginCreator_h */

