/**
 * @file    SBMLReactionConverter.h
 * @brief   Definition of SBMLReactionConverter, a converter changing reactions into rate rules
 * @author  Sarah Keating
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
 * @class SBMLReactionConverter
 * @sbmlbrief{core} Converter to replace reactions with SBML <em>rate rules</em>.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * This converter will take an SBML model and replace the definitions of
 * reactions in the model with definitions of SBML rate rules.  Equivalent
 * RateRule objects are only created for species mentioned in reactions that
 * have KineticLaw subobjects, since those are the only reactions that have
 * an effect on the rates of change of species in the model; however, the
 * converter removes all Reaction objects in the model after it is done.
 *
 * @section SBMLReactionConverter-usage Configuration and use of SBMLReactionConverter
 *
 * SBMLReactionConverter is enabled by creating a ConversionProperties object
 * with the option @c "replaceReactions", and passing this properties object
 * to SBMLDocument::convert(@if java ConversionProperties@endif).  This
 * converter does not offer any additional configuration options.
 *
 * @copydetails doc_section_using_sbml_converters
 */

#ifndef SBMLReactionConverter_h
#define SBMLReactionConverter_h

#include <sbml/SBMLNamespaces.h>
#include <sbml/conversion/SBMLConverter.h>
#include <sbml/conversion/SBMLConverterRegister.h>
#include <sbml/util/IdList.h>


#ifdef __cplusplus

#include <map>
#include <string>
class SpeciesReference;

LIBSBML_CPP_NAMESPACE_BEGIN

typedef std::vector< std::pair<std::string, ASTNode *> >             RuleMap;
typedef std::vector< std::pair<std::string, ASTNode *> >::iterator   RuleMapIter;

class LIBSBML_EXTERN SBMLReactionConverter : public SBMLConverter
{
public:

  /** @cond doxygenLibsbmlInternal */

  /* register with the ConversionRegistry */
  static void init();

  /** @endcond */


  /**
   * Creates a new SBMLReactionConverter object.
   */
  SBMLReactionConverter();


  /**
   * Copy constructor; creates a copy of an SBMLReactionConverter
   * object.
   *
   * @param obj the SBMLReactionConverter object to copy.
   */
  SBMLReactionConverter(const SBMLReactionConverter& obj);


  /**
   * Creates and returns a deep copy of this SBMLReactionConverter
   * object.
   *
   * @return a (deep) copy of this converter.
   */
  virtual SBMLReactionConverter* clone() const;


  /**
   * Destroy this SBMLReactionConverter object.
   */
  virtual ~SBMLReactionConverter ();


  /**
   * Returns @c true if this converter object's properties match the given
   * properties.
   *
   * A typical use of this method involves creating a ConversionProperties
   * object, setting the options desired, and then calling this method on
   * an SBMLReactionConverter object to find out if the object's
   * property values match the given ones.  This method is also used by
   * SBMLConverterRegistry::getConverterFor(@if java ConversionProperties@endif)
   * to search across all registered converters for one matching particular
   * properties.
   *
   * @param props the properties to match.
   *
   * @return @c true if this converter's properties match, @c false
   * otherwise.
   */
  virtual bool matchesProperties(const ConversionProperties &props) const;


  /**
   * Perform the conversion.
   *
   * This method causes the converter to do the actual conversion work,
   * that is, to convert the SBMLDocument object set by
   * SBMLConverter::setDocument(@if java SBMLDocument@endif) and
   * with the configuration options set by
   * SBMLConverter::setProperties(@if java ConversionProperties@endif).
   *
   * @return  integer value indicating the success/failure of the operation.
   * @if clike The value is drawn from the enumeration
   * #OperationReturnValues_t. @endif@~ The possible values are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_CONV_INVALID_SRC_DOCUMENT, OperationReturnValues_t}
   */
  virtual int convert();


  /**
   * Returns the default properties of this converter.
   *
   * A given converter exposes one or more properties that can be adjusted
   * in order to influence the behavior of the converter.  This method
   * returns the @em default property settings for this converter.  It is
   * meant to be called in order to discover all the settings for the
   * converter object.
   *
   * @return the ConversionProperties object describing the default properties
   * for this converter.
   */
  virtual ConversionProperties getDefaultProperties() const;


  /**
   * Sets the current SBML document to the given SBMLDocument object.
   *
   * @param doc the document to use for this conversion.
   *
   * @warning Even though the @p doc is 'const', it is immediately cast
   * to a non-const version, which is then usually changed by the
   * converter upon a successful conversion.  This function is here
   * solely to preserve backwards compatibility.
   *
   * @return integer value indicating the success/failure of the operation.
   * @if clike The value is drawn from the enumeration
   * #OperationReturnValues_t. @endif@~ The set of possible values that may
   * be returned ultimately depends on the specific subclass of
   * SBMLConverter being used, but the default method can return the
   * following values:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  virtual int setDocument(const SBMLDocument* doc);


  /**
   * Sets the current SBML document to the given SBMLDocument object.
   *
   * @param doc the document to use for this conversion.
   *
   * @return integer value indicating the success/failure of the operation.
   * @if clike The value is drawn from the enumeration
   * #OperationReturnValues_t. @endif@~ The set of possible values that may
   * be returned ultimately depends on the specific subclass of
   * SBMLConverter being used, but the default method can return the
   * following values:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  virtual int setDocument(SBMLDocument* doc);


private:

  ASTNode * createRateRuleMathForSpecies(const std::string& spId,
                                         Reaction * rn);


  ASTNode* determineStoichiometryNode(SpeciesReference * sr,
                                      bool isReactant);

  int createRateRule(const std::string& spId, ASTNode * math);


  bool replaceReactions();


  bool isDocumentValid();


  // member variables
  IdList mReactionsToRemove;

  RuleMap mRateRulesMap;

  Model * mOriginalModel;
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* SBMLReactionConverter_h */

