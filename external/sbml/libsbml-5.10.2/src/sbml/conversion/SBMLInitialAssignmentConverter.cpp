/**
* @file    SBMLInitialAssignmentConverter.cpp
* @brief   Implementation of SBMLInitialAssignmentConverter, a converter inlining initial assignments
* @author  Frank Bergmann 
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


#include <sbml/conversion/SBMLInitialAssignmentConverter.h>
#include <sbml/conversion/SBMLConverterRegistry.h>
#include <sbml/conversion/SBMLConverterRegister.h>
#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN


/** @cond doxygenLibsbmlInternal */
void SBMLInitialAssignmentConverter::init()
{
  SBMLInitialAssignmentConverter converter;
  SBMLConverterRegistry::getInstance().addConverter(&converter);
}
/** @endcond */


SBMLInitialAssignmentConverter::SBMLInitialAssignmentConverter() 
  : SBMLConverter("SBML Initial Assignment Converter")
{

}


SBMLInitialAssignmentConverter::SBMLInitialAssignmentConverter(const SBMLInitialAssignmentConverter& orig) :
  SBMLConverter(orig)
{
}

SBMLInitialAssignmentConverter* 
SBMLInitialAssignmentConverter::clone() const
{
  return new SBMLInitialAssignmentConverter(*this);
}


/*
 * Destroy this object.
 */
SBMLInitialAssignmentConverter::~SBMLInitialAssignmentConverter ()
{
}


ConversionProperties
SBMLInitialAssignmentConverter::getDefaultProperties() const
{
  static ConversionProperties prop;
  static bool init = false;

  if (init) 
  {
    return prop;
  }
  else
  {
    prop.addOption("expandInitialAssignments", true,
                   "Expand initial assignments in the model");
    init = true;
    return prop;
  }
}


bool 
SBMLInitialAssignmentConverter::matchesProperties(const ConversionProperties &props) const
{
  if (&props == NULL || !props.hasOption("expandInitialAssignments"))
    return false;
  return true;
}

int 
SBMLInitialAssignmentConverter::convert()
{
  if (mDocument == NULL) return LIBSBML_INVALID_OBJECT;
  Model* mModel = mDocument->getModel();
  if (mModel == NULL) return LIBSBML_INVALID_OBJECT;

  bool success = false;
  /* if no initial assignments bail now */
  if (mModel->getNumInitialAssignments() == 0)
  {
    return true;
  }

  /* check consistency of model */
  /* since this function will write to the error log we should
   * clear anything in the log first
   */
  mDocument->getErrorLog()->clearLog();
  unsigned char origValidators = mDocument->getApplicableValidators();

  mDocument->setApplicableValidators(AllChecksON);

  mDocument->checkConsistency();
  
  if (mDocument->getErrorLog()->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) == 0)
  {
    SBMLTransforms::expandInitialAssignments(mModel);
  }

  /* replace original consistency checks */
  mDocument->setApplicableValidators(origValidators);

  success = (mModel->getNumInitialAssignments() == 0);

  
  if (success) return LIBSBML_OPERATION_SUCCESS;
  return LIBSBML_OPERATION_FAILED;
  
}

/** @cond doxygenIgnored */


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


