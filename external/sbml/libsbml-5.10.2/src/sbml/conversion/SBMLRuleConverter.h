/**
 * @file    SBMLRuleConverter.h
 * @brief   Definition of SBMLRuleConverter, a converter sorting rules
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
 *
 * @class SBMLRuleConverter
 * @sbmlbrief{core} Converter that sorts SBML rules and assignments.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * This converter reorders assignments in a model.  Specifically, it sorts
 * the list of assignment rules (i.e., the AssignmentRule objects contained
 * in the ListOfAssignmentRules within the Model object) and the initial
 * assignments (i.e., the InitialAssignment objects contained in the
 * ListOfInitialAssignments) such that, within each set, assignments that
 * depend on @em prior values are placed @em after the values are set.  For
 * example, if there is an assignment rule stating <i>a = b + 1</i>, and
 * another rule stating <i>b = 3</i>, the list of rules is sorted and the
 * rules are arranged so that the rule for <i>b = 3</i> appears @em before
 * the rule for <i>a = b + 1</i>.  Similarly, if dependencies of this
 * sort exist in the list of initial assignments in the model, the initial
 * assignments are sorted as well.
 *
 * Beginning with SBML Level 2, assignment rules have no ordering
 * required---the order in which the rules appear in an SBML file has
 * no significance.  Software tools, however, may need to reorder
 * assignments for purposes of evaluating them.  For example, for
 * simulators that use time integration methods, it would be a good idea to
 * reorder assignment rules such as the following,
 *
 * <i>b = a + 10 seconds</i><br>
 * <i>a = time</i>
 *
 * so that the evaluation of the rules is independent of integrator
 * step sizes. (This is due to the fact that, in this case, the order in
 * which the rules are evaluated changes the result.)  SBMLRuleConverter
 * can be used to reorder the SBML objects regardless of whether the
 * input file contained them in the desired order.
 *
 * @note The two sets of assignments (list of assignment rules on the one
 * hand, and list of initial assignments on the other hand) are handled @em
 * independently.  In an SBML model, these entities are treated differently
 * and no amount of sorting can deal with inter-dependencies between
 * assignments of the two kinds.

 * @section SBMLRuleConverter-usage Configuration and use of SBMLRuleConverter
 *
 * SBMLRuleConverter is enabled by creating a ConversionProperties object
 * with the option @c "sortRules", and passing this properties object to
 * SBMLDocument::convert(@if java ConversionProperties@endif).  This
 * converter offers no other options.
 *
 * @copydetails doc_section_using_sbml_converters
 */


#ifndef SBMLRuleConverter_h
#define SBMLRuleConverter_h

#include <sbml/SBMLNamespaces.h>
#include <sbml/conversion/SBMLConverter.h>
#include <sbml/conversion/SBMLConverterRegister.h>

#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN SBMLRuleConverter : public SBMLConverter
{
public:

  /** @cond doxygenLibsbmlInternal */

  /* register with the ConversionRegistry */
  static void init();

  /** @endcond */


  /**
   * Creates a new SBMLLevelVersionConverter object.
   */
  SBMLRuleConverter();


  /**
   * Copy constructor; creates a copy of an SBMLLevelVersionConverter
   * object.
   *
   * @param obj the SBMLLevelVersionConverter object to copy.
   */
  SBMLRuleConverter(const SBMLRuleConverter& obj);


  /**
   * Creates and returns a deep copy of this SBMLLevelVersionConverter
   * object.
   *
   * @return a (deep) copy of this converter.
   */
  virtual SBMLRuleConverter* clone() const;


  /**
   * Destroy this SBMLRuleConverter object.
   */
  virtual ~SBMLRuleConverter ();


  /**
   * Returns @c true if this converter object's properties match the given
   * properties.
   *
   * A typical use of this method involves creating a ConversionProperties
   * object, setting the options desired, and then calling this method on
   * an SBMLLevelVersionConverter object to find out if the object's
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


private:
  /** @cond doxygenLibsbmlInternal */

  /** @endcond */

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* SBMLRuleConverter_h */

