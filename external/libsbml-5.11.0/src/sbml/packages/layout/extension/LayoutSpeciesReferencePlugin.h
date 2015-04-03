/**
 * @file    LayoutSpeciesReferencePlugin.h
 * @brief   Definition of LayoutSpeciesReferencePlugin, the plugin
 *          class of layout package (Level2) for the SpeciesReference and 
 *          ModifierSpeciesReference elements.
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
 * @class LayoutSpeciesReferencePlugin
 * @sbmlbrief{layout} Extension of SpeciesReference.
 */

#ifndef LayoutSpeciesReferencePlugin_h
#define LayoutSpeciesReferencePlugin_h


#include <sbml/common/sbmlfwd.h>
#include <sbml/SBMLErrorLog.h>
#include <sbml/SpeciesReference.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/extension/SBasePlugin.h>
#include <sbml/packages/layout/sbml/Layout.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>

#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN LayoutSpeciesReferencePlugin : public SBasePlugin
{
public:

  /**
   * Constructor
   */
  LayoutSpeciesReferencePlugin (const std::string &uri, const std::string &prefix,
                                LayoutPkgNamespaces* layoutns);


  /**
   * Copy constructor. Creates a copy of this SBase object.
   */
  LayoutSpeciesReferencePlugin(const LayoutSpeciesReferencePlugin& orig);


  /**
   * Destroy this object.
   */
  virtual ~LayoutSpeciesReferencePlugin ();

  /**
   * Assignment operator for LayoutSpeciesReferencePlugin.
   */
  LayoutSpeciesReferencePlugin& operator=(const LayoutSpeciesReferencePlugin& orig);


  /**
   * Creates and returns a deep copy of this LayoutSpeciesReferencePlugin object.
   * 
   * @return a (deep) copy of this LayoutSpeciesReferencePlugin object
   */
  virtual LayoutSpeciesReferencePlugin* clone () const;

#ifndef SWIG

  // ---------------------------------------------------------
  //
  // overridden virtual functions for reading/writing/checking
  // attributes
  //
  // ---------------------------------------------------------

  /** @cond doxygenLibsbmlInternal */
  /**
   * Parses Layout Extension of SBML Level 2
   */
  virtual bool readOtherXML (SBase* parentObject, XMLInputStream& stream);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * This function is a bit tricky.
   * This function is used only for setting annotation element of layout
   * extension for SBML Level2 because annotation element needs to be
   * set before invoking the above writeElements function.
   * Thus, no attribute is written by this function.
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;
  /** @endcond */

#endif //SWIG
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* LayoutSpeciesReferencePlugin_h */

