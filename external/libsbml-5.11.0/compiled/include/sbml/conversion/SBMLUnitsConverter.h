/**
 * @file    SBMLUnitsConverter.h
 * @brief   Definition of SBMLUnitsConverter, for converting units to SI.
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
 * @class SBMLUnitsConverter
 * @sbmlbrief{core} Converts a model's existing units to SI units.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * This SBML converter converts the units in a model to base SI units, that
 * is, using only the units metre, kilogram, second, ampere, kelvin, mole and
 * candela.
 *
 * Unit conversion will only be performed on models that are fully unit
 * consistent, meaning that all objects have units associated with them and
 * there are no literal numbers with unspecified units.  In the case of an
 * SBML Level&nbsp;3 model involving math expressions, this means that the @c
 * timeUnits attribute on the Model object must be set, and if there are any
 * reactions in the model, the @c extentUnits attribute on the Model object
 * must also be set.
 *
 * @section SBMLUnitsConverter-usage Configuration and use of SBMLUnitsConverter
 *
 * SBMLUnitsConverter is enabled by creating a ConversionProperties object
 * with the option @c "units", and passing this properties object to
 * SBMLDocument::convert(@if java ConversionProperties@endif).  This
 * converter takes one optional option:
 *
 * @li @c "removeUnusedUnits": the value of this property should be a
 * Boolean.  If it is @c true, it tells the unit convert to remove any unused
 * UnitDefinition objects after conversion is complete.  ("Unused" units are
 * units that are not referenced by any object in the model.)  If the value
 * is @c false, unused UnitDefinition objects are not removed from the model.
 * The default is @c true.
 *
 * @copydetails doc_section_using_sbml_converters
 */

#ifndef SBMLUnitsConverter_h
#define SBMLUnitsConverter_h

#include <sbml/SBMLNamespaces.h>
#include <sbml/conversion/SBMLConverter.h>
#include <sbml/conversion/SBMLConverterRegister.h>

#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN SBMLUnitsConverter : public SBMLConverter
{
public:

  /** @cond doxygenLibsbmlInternal */

  /**
   * Register with the ConversionRegistry.
   */
  static void init();

#ifndef SWIG
  typedef std::map<const std::string, const std::string> GlobalUnits;
  typedef GlobalUnits::iterator                  GlobalUnitsIter;
#endif

  /** @endcond */


  /**
   * Creates a new SBMLUnitsConverter object.
   */
  SBMLUnitsConverter ();


  /**
   * Copy constructor; creates a copy of an SBMLUnitsConverter
   * object.
   *
   * @param obj the SBMLUnitsConverter object to copy.
   */
  SBMLUnitsConverter(const SBMLUnitsConverter& obj);


  /**
   * Destroy this object.
   */
  virtual ~SBMLUnitsConverter ();


  /**
   * Assignment operator for SBMLUnitsConverter.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  SBMLUnitsConverter& operator=(const SBMLUnitsConverter& rhs);


  /**
   * Creates and returns a deep copy of this SBMLUnitsConverter
   * object.
   *
   * @return a (deep) copy of this converter.
   */
  virtual SBMLUnitsConverter* clone() const;


  /**
   * Returns @c true if this converter object's properties match the given
   * properties.
   *
   * A typical use of this method involves creating a ConversionProperties
   * object, setting the options desired, and then calling this method on
   * an SBMLUnitsConverter object to find out if the object's
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
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_CONV_CONVERSION_NOT_AVAILABLE, OperationReturnValues_t}
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



#ifndef SWIG

#endif // SWIG


private:
  /** @cond doxygenLibsbmlInternal */

  bool convertUnits(SBase& sb, Model& m);

  bool convertUnits(SBase& sb, Model& m, std::string &modelUnitAttribute, ASTNode *ast = 0);

  int applyNewUnitDefinition(SBase& sb, Model& m, UnitDefinition *newUD,
    std::string &modelUnitAttribute, ASTNode * ast);

  std::string existsAlready(Model& m, UnitDefinition *newUD);

  bool getRemoveUnusedUnitsFlag();

  void removeUnusedUnitDefinitions(Model& m);


  bool convertGlobalUnits(Model& m);


  bool convertCnUnits(Model& m);


  bool isUsed(Model& m, std::string unitSId);


  bool unacceptable_errors(unsigned int errors);

  bool hasCnUnits(Model& m);

  bool mathHasCnUnits(const ASTNode *ast);

  bool matchesCnUnits(Model& m, std::string& units);

  bool mathMatchesCnUnits(const ASTNode *ast, std::string& units);
  bool convertAST(ASTNode *ast, Model &m);

  unsigned int newIdCount;

  GlobalUnits mGlobalUnits;

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
#endif  /* SBMLUnitsConverter_h */

