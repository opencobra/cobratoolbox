/**
 * @file    SBMLInternalValidator.cpp
 * @brief   Implementation of SBMLInternalValidator, the validator for all internal validation performed by libSBML.
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

#include <sbml/validator/SBMLInternalValidator.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>
#include <vector>
#include <map>

#include <sbml/validator/ConsistencyValidator.h>
#include <sbml/validator/IdentifierConsistencyValidator.h>
#include <sbml/validator/MathMLConsistencyValidator.h>
#include <sbml/validator/SBOConsistencyValidator.h>
#include <sbml/validator/UnitConsistencyValidator.h>
#include <sbml/validator/OverdeterminedValidator.h>
#include <sbml/validator/ModelingPracticeValidator.h>
#include <sbml/validator/L1CompatibilityValidator.h>
#include <sbml/validator/L2v1CompatibilityValidator.h>
#include <sbml/validator/L2v2CompatibilityValidator.h>
#include <sbml/validator/L2v3CompatibilityValidator.h>
#include <sbml/validator/L2v4CompatibilityValidator.h>
#include <sbml/validator/L3v1CompatibilityValidator.h>
#include <sbml/validator/InternalConsistencyValidator.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLWriter.h>
#include <sbml/SBMLReader.h>
#include <sbml/AlgebraicRule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>




using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN


SBMLInternalValidator::SBMLInternalValidator() 
  : SBMLValidator()
  , mApplicableValidators(0)
  , mApplicableValidatorsForConversion(0)
{

}


SBMLInternalValidator::SBMLInternalValidator(const SBMLInternalValidator& orig) 
  : SBMLValidator(orig)
  , mApplicableValidators(orig.mApplicableValidators)
  , mApplicableValidatorsForConversion(orig.mApplicableValidatorsForConversion)
{
}

SBMLValidator* 
SBMLInternalValidator::clone() const
{
  return new SBMLInternalValidator(*this);
}


/*
 * Destroy this object.
 */
SBMLInternalValidator::~SBMLInternalValidator ()
{

}


void 
SBMLInternalValidator::setConsistencyChecks(SBMLErrorCategory_t category,
                                   bool apply)
{
  switch (category)
  {
  case LIBSBML_CAT_IDENTIFIER_CONSISTENCY:
    if (apply)
    {
      mApplicableValidators |= IdCheckON;
    }
    else
    {
      mApplicableValidators &= IdCheckOFF;
    }

    break;

  case LIBSBML_CAT_GENERAL_CONSISTENCY:
    if (apply)
    {
      mApplicableValidators |= SBMLCheckON;
    }
    else
    {
      mApplicableValidators &= SBMLCheckOFF;
    }

    break;
  
  case LIBSBML_CAT_SBO_CONSISTENCY:
    if (apply)
    {
      mApplicableValidators |= SBOCheckON;
    }
    else
    {
      mApplicableValidators &= SBOCheckOFF;
    }

    break;
  
  case LIBSBML_CAT_MATHML_CONSISTENCY:
    if (apply)
    {
      mApplicableValidators |= MathCheckON;
    }
    else
    {
      mApplicableValidators &= MathCheckOFF;
    }

    break;
  
  case LIBSBML_CAT_UNITS_CONSISTENCY:
    if (apply)
    {
      mApplicableValidators |= UnitsCheckON;
    }
    else
    {
      mApplicableValidators &= UnitsCheckOFF;
    }

    break;
  
  case LIBSBML_CAT_OVERDETERMINED_MODEL:
    if (apply)
    {
      mApplicableValidators |= OverdeterCheckON;
    }
    else
    {
      mApplicableValidators &= OverdeterCheckOFF;
    }

    break;

  case LIBSBML_CAT_MODELING_PRACTICE:
    if (apply)
    {
      mApplicableValidators |= PracticeCheckON;
    }
    else
    {
      mApplicableValidators &= PracticeCheckOFF;
    }

    break;

  default:
    // If it's a category for which we don't have validators, ignore it.
    break;
  }

}


void 
SBMLInternalValidator::setConsistencyChecksForConversion(SBMLErrorCategory_t category,
                                   bool apply)
{
  switch (category)
  {
  case LIBSBML_CAT_IDENTIFIER_CONSISTENCY:
    if (apply)
    {
      mApplicableValidatorsForConversion |= IdCheckON;
    }
    else
    {
      mApplicableValidatorsForConversion &= IdCheckOFF;
    }

    break;

  case LIBSBML_CAT_GENERAL_CONSISTENCY:
    if (apply)
    {
      mApplicableValidatorsForConversion |= SBMLCheckON;
    }
    else
    {
      mApplicableValidatorsForConversion &= SBMLCheckOFF;
    }

    break;
  
  case LIBSBML_CAT_SBO_CONSISTENCY:
    if (apply)
    {
      mApplicableValidatorsForConversion |= SBOCheckON;
    }
    else
    {
      mApplicableValidatorsForConversion &= SBOCheckOFF;
    }

    break;
  
  case LIBSBML_CAT_MATHML_CONSISTENCY:
    if (apply)
    {
      mApplicableValidatorsForConversion |= MathCheckON;
    }
    else
    {
      mApplicableValidatorsForConversion &= MathCheckOFF;
    }

    break;
  
  case LIBSBML_CAT_UNITS_CONSISTENCY:
    if (apply)
    {
      mApplicableValidatorsForConversion |= UnitsCheckON;
    }
    else
    {
      mApplicableValidatorsForConversion &= UnitsCheckOFF;
    }

    break;
  
  case LIBSBML_CAT_OVERDETERMINED_MODEL:
    if (apply)
    {
      mApplicableValidatorsForConversion |= OverdeterCheckON;
    }
    else
    {
      mApplicableValidatorsForConversion &= OverdeterCheckOFF;
    }

    break;

  case LIBSBML_CAT_MODELING_PRACTICE:
    if (apply)
    {
      mApplicableValidatorsForConversion |= PracticeCheckON;
    }
    else
    {
      mApplicableValidatorsForConversion &= PracticeCheckOFF;
    }

    break;

  default:
    // If it's a category for which we don't have validators, ignore it.
    break;
  }

}
/*
 * Performs a set of semantic consistency checks on the document.  Query
 * the results by calling getNumErrors() and getError().
 *
 * @return the number of failed checks (errors) encountered.
 */
unsigned int
SBMLInternalValidator::checkConsistency (bool writeDocument)
{
  unsigned int nerrors = 0;
  unsigned int total_errors = 0;

  //if (getLevel() == 3)
  //{
  //  logError(L3NotSupported);
  //  return 1;
  //}
  /* determine which validators to run */
  bool id    = ((mApplicableValidators & 0x01) == 0x01);
  bool sbml  = ((mApplicableValidators & 0x02) == 0x02);
  bool sbo   = ((mApplicableValidators & 0x04) == 0x04);
  bool math  = ((mApplicableValidators & 0x08) == 0x08);
  bool units = ((mApplicableValidators & 0x10) == 0x10);
  bool over  = ((mApplicableValidators & 0x20) == 0x20);
  bool practice = ((mApplicableValidators & 0x40) == 0x40);

  /* taken the state machine concept out for now
  if (LibSBMLStateMachine::isActive()) 
  {
    units = LibSBMLStateMachine::getUnitState();
  }
  */

  SBMLDocument *doc;
  SBMLErrorLog *log = getErrorLog();
  
  if (writeDocument)
  {
    char* sbmlString = writeSBMLToString(getDocument());
    log->clearLog();
    doc = readSBMLFromString(sbmlString);
    free (sbmlString);  
  }
  else
  {
    doc = getDocument();
  }

  /* calls each specified validator in turn 
   * - stopping when errors are encountered */

  if (id)
  {
    IdentifierConsistencyValidator id_validator;
    id_validator.init();
    nerrors = id_validator.validate(*doc);
    if (nerrors > 0) 
    {
      unsigned int origNum = log->getNumErrors();
      log->add( id_validator.getFailures() );

      if (origNum > 0 && log->contains(InvalidUnitIdSyntax) == true)
      {
        /* do not log dangling ref */
        while (log->contains(DanglingUnitSIdRef) == true)
        {
          log->remove(DanglingUnitSIdRef);
          nerrors--;
        }
        
        total_errors += nerrors;
        if (nerrors > 0)
        {
          if (writeDocument)
            SBMLDocument_free(doc);
          return total_errors;
        }
      }
      else if (log->contains(DanglingUnitSIdRef) == false)
      {
        total_errors += nerrors;
        if (writeDocument)
          SBMLDocument_free(doc);
        return total_errors;
      }
      else
      {
        bool onlyDangRef = true;
        for (unsigned int a = 0; a < log->getNumErrors(); a++)
        {
          if (log->getError(a)->getErrorId() != DanglingUnitSIdRef)
          {
            onlyDangRef = false;
            break;
          }
        }
        total_errors += nerrors;

        if (onlyDangRef == false)
        {
          if (writeDocument)
            SBMLDocument_free(doc);
          return total_errors;
        }
      }
    }
  }

  if (sbml)
  {
    ConsistencyValidator validator;
    validator.init();
    nerrors = validator.validate(*doc);
    total_errors += nerrors;
    if (nerrors > 0) 
    {
      log->add( validator.getFailures() );
      /* only want to bail if errors not warnings */
      if (log->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) > 0)
      {
        if (writeDocument)
          SBMLDocument_free(doc);
        return total_errors;
      }
    }
  }

  if (sbo)
  {
    SBOConsistencyValidator sbo_validator;
    sbo_validator.init();
    nerrors = sbo_validator.validate(*doc);
    total_errors += nerrors;
    if (nerrors > 0) 
    {
      log->add( sbo_validator.getFailures() );
      /* only want to bail if errors not warnings */
      if (log->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) > 0)
      {
        if (writeDocument)
          SBMLDocument_free(doc);
        return total_errors;
      }
    }
  }

  if (math)
  {
    MathMLConsistencyValidator math_validator;
    math_validator.init();
    nerrors = math_validator.validate(*doc);
    total_errors += nerrors;
    if (nerrors > 0) 
    {
      log->add( math_validator.getFailures() );
      /* at this point bail if any problems
       * unit checks may crash if there have been math errors/warnings
       */
      if (writeDocument)
        SBMLDocument_free(doc);
      return total_errors;
    }
  }


  if (units)
  {
    UnitConsistencyValidator unit_validator;
    unit_validator.init();
    nerrors = unit_validator.validate(*doc);
    total_errors += nerrors;
    if (nerrors > 0) 
    {
      log->add( unit_validator.getFailures() );
      /* only want to bail if errors not warnings */
      if (log->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) > 0)
      {
        if (writeDocument)
          SBMLDocument_free(doc);
        return total_errors;
      }
    }
  }

  /* do not even try if there have been unit warnings 
   * changed this as would have bailed */
  if (over)
  {
    OverdeterminedValidator over_validator;
    over_validator.init();
    nerrors = over_validator.validate(*doc);
    total_errors += nerrors;
    if (nerrors > 0) 
    {
      log->add( over_validator.getFailures() );
      /* only want to bail if errors not warnings */
      if (log->getNumFailsWithSeverity(LIBSBML_SEV_ERROR) > 0)
      {
        if (writeDocument)
          SBMLDocument_free(doc);
        return total_errors;
      }
    }
  }

  if (practice)
  {
    ModelingPracticeValidator practice_validator;
    practice_validator.init();
    nerrors = practice_validator.validate(*doc);
    if (nerrors > 0) 
    {
      unsigned int errorsAdded = 0;
      const std::list<SBMLError> practiceErrors = practice_validator.getFailures();
      list<SBMLError>::const_iterator end = practiceErrors.end();
      list<SBMLError>::const_iterator iter;
      for (iter = practiceErrors.begin(); iter != end; ++iter)
      {
        if (SBMLError(*iter).getErrorId() != 80701)
        {
          log->add( SBMLError(*iter) );
          errorsAdded++;
        }
        else
        {
          if (units) 
          {
            log->add( SBMLError(*iter) );
            errorsAdded++;
          }
        }
      }
      total_errors += errorsAdded;

    }
  }

  if (writeDocument)
    SBMLDocument_free(doc);
  return total_errors;
}

/*
 * Performs consistency checking on libSBML's internal representation of 
 * an SBML Model.
 *
 * Callers should query the results of the consistency check by calling
 * getError().
 *
 * @return the number of failed checks (errors) encountered.
 */
unsigned int
SBMLInternalValidator::checkInternalConsistency()
{
  unsigned int nerrors = 0;
  unsigned int totalerrors = 0;

  InternalConsistencyValidator validator;

  validator.init();
  nerrors = validator.validate(*getDocument());
  if (nerrors > 0) 
  {
    getErrorLog()->add( validator.getFailures() );
  }
  totalerrors += nerrors;
  
  /* hack to catch errors normally caught at read time */
  char* doc = writeSBMLToString(getDocument());
  SBMLDocument *d = readSBMLFromString(doc);
  util_free(doc);
  nerrors = d->getNumErrors();

  for (unsigned int i = 0; i < nerrors; i++)
  {
    getErrorLog()->add(*(d->getError(i)));
  }
  delete d;
  totalerrors += nerrors;


  return totalerrors;

}

/*
 * Performs a set of semantic consistency checks on the document to establish
 * whether it is compatible with L1 and can be converted.  Query
 * the results by calling getNumErrors() and getError().
 *
 * @return the number of failed checks (errors) encountered.
 */
unsigned int
SBMLInternalValidator::checkL1Compatibility ()
{
  if (getModel() == NULL) return 0;

  L1CompatibilityValidator validator;
  validator.init();

  unsigned int nerrors = validator.validate(*getDocument());
  if (nerrors > 0) getErrorLog()->add( validator.getFailures() );

  return nerrors;
}


/*
 * Performs a set of semantic consistency checks on the document to establish
 * whether it is compatible with L2v1 and can be converted.  Query
 * the results by calling getNumErrors() and getError().
 *
 * @return the number of failed checks (errors) encountered.
 */
unsigned int
SBMLInternalValidator::checkL2v1Compatibility ()
{
  if (getModel() == NULL) return 0;

  L2v1CompatibilityValidator validator;
  validator.init();

  unsigned int nerrors = validator.validate(*getDocument());
  if (nerrors > 0) getErrorLog()->add( validator.getFailures() );

  return nerrors;
}


/*
 * Performs a set of semantic consistency checks on the document to establish
 * whether it is compatible with L2v2 and can be converted.  Query
 * the results by calling getNumErrors() and getError().
 *
 * @return the number of failed checks (errors) encountered.
 */
unsigned int
SBMLInternalValidator::checkL2v2Compatibility ()
{
  if (getModel() == NULL) return 0;

  L2v2CompatibilityValidator validator;
  validator.init();

  unsigned int nerrors = validator.validate(*getDocument());
  if (nerrors > 0) getErrorLog()->add( validator.getFailures() );

  return nerrors;
}

/*
 * Performs a set of semantic consistency checks on the document to establish
 * whether it is compatible with L2v3 and can be converted.  Query
 * the results by calling getNumErrors() and getError().
 *
 * @return the number of failed checks (errors) encountered.
 */
unsigned int
SBMLInternalValidator::checkL2v3Compatibility ()
{
  if (getModel() == NULL) return 0;

  L2v3CompatibilityValidator validator;
  validator.init();

  unsigned int nerrors = validator.validate(*getDocument());
  if (nerrors > 0) getErrorLog()->add( validator.getFailures() );

  return nerrors;
}

/*
 * Performs a set of semantic consistency checks on the document to establish
 * whether it is compatible with L2v4 and can be converted.  Query
 * the results by calling getNumErrors() and getError().
 *
 * @return the number of failed checks (errors) encountered.
 */
unsigned int
SBMLInternalValidator::checkL2v4Compatibility ()
{
  if (getModel() == NULL) return 0;

  L2v4CompatibilityValidator validator;
  validator.init();

  unsigned int nerrors = validator.validate(*getDocument());
  if (nerrors > 0) getErrorLog()->add( validator.getFailures() );

  return nerrors;
}



/*
 * Performs a set of semantic consistency checks on the document to establish
 * whether it is compatible with L2v1 and can be converted.  Query
 * the results by calling getNumErrors() and getError().
 *
 * @return the number of failed checks (errors) encountered.
 */
unsigned int
SBMLInternalValidator::checkL3v1Compatibility ()
{
  if (getModel() == NULL) return 0;

  L3v1CompatibilityValidator validator;
  validator.init();

  unsigned int nerrors = validator.validate(*getDocument());
  if (nerrors > 0) getErrorLog()->add( validator.getFailures() );

  return nerrors;
}


unsigned char
SBMLInternalValidator::getApplicableValidators() const
{
  return mApplicableValidators;
}


unsigned char
SBMLInternalValidator::getConversionValidators() const
{
  return mApplicableValidatorsForConversion;
}


void
SBMLInternalValidator::setApplicableValidators(unsigned char appl)
{
  mApplicableValidators = appl;
}


void
SBMLInternalValidator::setConversionValidators(unsigned char appl)
{
  mApplicableValidatorsForConversion = appl;
}

unsigned int 
  SBMLInternalValidator::validate()
{
  return checkConsistency();  
}

/** @cond doxygenIgnored */


/** @endcond */

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


