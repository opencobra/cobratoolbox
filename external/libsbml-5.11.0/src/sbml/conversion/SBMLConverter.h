/**
 * @file    SBMLConverter.h
 * @brief   Definition of SBMLConverter, the base class for SBML conversion.
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
 * @class SBMLConverter
 * @sbmlbrief{core} Base class for SBML converters.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * The SBMLConverter class is the base class for the various SBML @em
 * converters: classes of objects that transform or convert SBML documents.
 * These transformations can involve essentially anything that can be written
 * algorithmically; examples include converting the units of measurement in a
 * model, or converting from one Level+Version combination of SBML to
 * another.  Applications can also create their own converters by subclassing
 * SBMLConverter and following the examples of the existing converters.
 *
 * @copydetails doc_section_using_sbml_converters
 */

#ifndef SBMLConverter_h
#define SBMLConverter_h

#include <string>

#include <sbml/SBMLNamespaces.h>
#include <sbml/conversion/ConversionProperties.h>

#ifndef LIBSBML_USE_STRICT_INCLUDES
#include <sbml/SBMLTypes.h>
#endif

#ifdef __cplusplus


LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN SBMLConverter
{
public:

  /**
   * Creates a new SBMLConverter object.
   */
  SBMLConverter ();


  /**
   * Creates a new SBMLConverter object with a given name.
   *
   * @param name the name for the converter to create
   */
  SBMLConverter (const std::string& name);


  /**
   * Copy constructor.
   *
   * This creates a copy of an SBMLConverter object.
   *
   * @param orig the SBMLConverter object to copy.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  SBMLConverter(const SBMLConverter& orig);


  /**
   * Destroy this SBMLConverter object.
   */
  virtual ~SBMLConverter ();


  /**
   * Assignment operator for SBMLConverter.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  SBMLConverter& operator=(const SBMLConverter& rhs);


  /**
   * Creates and returns a deep copy of this SBMLConverter object.
   *
   * @return the (deep) copy of this SBMLConverter object.
   */
  virtual SBMLConverter* clone() const;


  /**
   * Returns the SBML document that is the subject of the conversions.
   *
   * @return the current SBMLDocument object.
   */
  virtual SBMLDocument* getDocument();


  /**
   * Returns the SBML document that is the subject of the conversions.
   *
   * @return the current SBMLDocument object.
   */
  virtual const SBMLDocument* getDocument() const;


  /**
   * Returns the default properties of this converter.
   *
   * A given converter exposes one or more properties that can be adjusted
   * in order to influence the behavior of the converter.  This method
   * returns the @em default property settings for this converter.  It is
   * meant to be called in order to discover all the settings for the
   * converter object.  The run-time properties of the converter object can
   * be adjusted by using the method
   * SBMLConverter::setProperties(const ConversionProperties *props).
   *
   * @return the default properties for the converter.
   *
   * @see setProperties(@if java ConversionProperties@endif)
   * @see matchesProperties(@if java ConversionProperties@endif)
   */
  virtual ConversionProperties getDefaultProperties() const;


  /**
   * Returns the target SBML namespaces of the currently set properties.
   *
   * SBML namespaces are used by libSBML to express the Level+Version of the
   * SBML document (and, possibly, any SBML Level&nbsp;3 packages in
   * use). Some converters' behavior is affected by the SBML namespace
   * configured in the converter.  For example, in SBMLLevelVersionConverter
   * (the converter for converting SBML documents from one Level+Version
   * combination to another), the actions are fundamentally dependent on the
   * SBML namespaces targeted.
   *
   * @return the SBMLNamespaces object that describes the SBML namespaces
   * in effect, or @c NULL if none are set.
   */
  virtual SBMLNamespaces* getTargetNamespaces();


  /**
   * Returns @c true if this converter matches the given properties.
   *
   * Given a ConversionProperties object @p props, this method checks that @p
   * props possesses an option value to enable this converter.  If it does,
   * this method returns @c true.
   *
   * @param props the properties to match.
   *
   * @return @c true if the properties @p props would match the necessary
   * properties for this type of converter, @c false otherwise.
   */
  virtual bool matchesProperties(const ConversionProperties &props) const;


  /**
   * Sets the SBML document to be converted.
   *
   * @param doc the document to use for this conversion.
   *
   * @return integer value indicating the success/failure of the operation.
   * @if clike The value is drawn from the enumeration
   * #OperationReturnValues_t. @endif@~ The set of possible values that may
   * be returned ultimately depends on the specific subclass of
   * SBMLConverter being used, but the default method can return the
   * following:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @if cpp
   * @warning Even though the argument @p doc is 'const', it is immediately
   * cast to a non-const version, which is then usually changed by the
   * converter upon a successful conversion.  This variant of the
   * setDocument() method is here solely to preserve backwards compatibility.
   * @endif
   */
  virtual int setDocument(const SBMLDocument* doc);


  /**
   * Sets the SBML document to be converted.
   *
   * @param doc the document to use for this conversion.
   *
   * @return integer value indicating the success/failure of the operation.
   * @if clike The value is drawn from the enumeration
   * #OperationReturnValues_t. @endif@~ The set of possible values that may
   * be returned ultimately depends on the specific subclass of
   * SBMLConverter being used, but the default method can return the
   * following:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  virtual int setDocument(SBMLDocument* doc);


  /**
   * Sets the configuration properties to be used by this converter.
   *
   * @param props the ConversionProperties object defining the properties
   * to set.
   *
   * @return integer value indicating the success/failure of the operation.
   * @if clike The value is drawn from the enumeration
   * #OperationReturnValues_t. @endif@~ The set of possible values that may
   * be returned ultimately depends on the specific subclass of
   * SBMLConverter being used, but the default method can return the
   * following values:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see getProperties()
   * @see matchesProperties(@if java ConversionProperties@endif)
   */
  virtual int setProperties(const ConversionProperties *props);


  /**
   * Returns the current properties in effect for this converter.
   *
   * A given converter exposes one or more properties that can be adjusted
   * in order to influence the behavior of the converter.  This method
   * returns the current properties for this converter; in other words, the
   * settings in effect at this moment.  To change the property values, you
   * can use SBMLConverter::setProperties(const ConversionProperties *props).
   *
   * @return the currently set configuration properties.
   *
   * @see setProperties(@if java ConversionProperties@endif)
   * @see matchesProperties(@if java ConversionProperties@endif)
   */
  virtual ConversionProperties* getProperties() const;


  /**
   * Perform the conversion.
   *
   * This method causes the converter to do the actual conversion work,
   * that is, to convert the SBMLDocument object set by
   * SBMLConverter::setDocument(@if java const SBMLDocument@endif) and
   * with the configuration options set by
   * SBMLConverter::setProperties(@if java const ConversionProperties@endif).
   *
   * @return  integer value indicating the success/failure of the operation.
   * @if clike The value is drawn from the enumeration
   * #OperationReturnValues_t. @endif@~ The set of possible values that may
   * be returned depends on the converter subclass; please consult
   * the documentation for the relevant class to find out what the
   * possibilities are.
   */
  virtual int convert();


  /**
   * Returns the name of this converter.
   *
   * @return a string, the name of this converter.
   */
  const std::string& getName() const;


protected:
  /** @cond doxygenLibsbmlInternal */

  SBMLDocument *   mDocument;
  ConversionProperties *mProps;
  std::string mName;

  friend class SBMLDocument;
  /** @endcond */

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
#endif  /* SBMLConverter_h */

