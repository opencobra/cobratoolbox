/**
 * @file    SBMLDocumentPluginNotRequired.cpp
 * @brief   Implementation of SBMLDocumentPluginNotRequired, the plugin class of
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

#include <sbml/extension/SBMLDocumentPluginNotRequired.h>

#include <iostream>
#include <string>
using namespace std;


#ifdef __cplusplus

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 *
 */
SBMLDocumentPluginNotRequired::SBMLDocumentPluginNotRequired (const std::string &uri,
                                                              const std::string &prefix,
                                                              SBMLNamespaces *sbmlns)
  : SBMLDocumentPlugin(uri,prefix,sbmlns)
{
  mRequired = false;
}


/*
 * Copy constructor. Creates a copy of this SBase object.
 */
SBMLDocumentPluginNotRequired::SBMLDocumentPluginNotRequired(const SBMLDocumentPluginNotRequired& orig)
  : SBMLDocumentPlugin(orig)
{
  mRequired = false;
}


SBMLDocumentPluginNotRequired&
SBMLDocumentPluginNotRequired::operator=(const SBMLDocumentPluginNotRequired& orig)
{
  if(&orig!=this)
  {
    this->SBMLDocumentPlugin::operator =(orig);
  }
  return *this;
}


/*
 * Destroy this object.
 */
SBMLDocumentPluginNotRequired::~SBMLDocumentPluginNotRequired () {}


/** @cond doxygenLibsbmlInternal */
void
SBMLDocumentPluginNotRequired::readAttributes (const XMLAttributes& attributes,
                                          const ExpectedAttributes& expectedAttributes)
{
  if (&attributes == NULL || &expectedAttributes == NULL ) return;

  //If we're reading from a file, the file might erroneously not have set the 'required' flag:
  mIsSetRequired = false;

  SBMLDocumentPlugin::readAttributes(attributes, expectedAttributes);

  if ( getLevel() > 2)
  {

    //Alternatively, it might have set the 'required' flag to be 'false':
    if (mIsSetRequired && mRequired==true)
    {
      getErrorLog()
        ->logError(PackageRequiredShouldBeFalse, getLevel(), getVersion());
    }
  }
}
/** @endcond */


#if(0)
int
SBMLDocumentPluginNotRequired::setRequired(bool required)
{

  if ( getLevel() < 3) {
    // required attribute is not defined for SBML Level 2 .
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  if (required==true) {
    //Illegal to set the layout package to 'required', as it cannot change the math.
    return LIBSBML_OPERATION_FAILED;
  }
  mRequired = required;
  mIsSetRequired = true;
  return LIBSBML_OPERATION_SUCCESS;
}

int
SBMLDocumentPluginNotRequired::unsetRequired()
{
  return LIBSBML_OPERATION_FAILED;
}
#endif //0

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
