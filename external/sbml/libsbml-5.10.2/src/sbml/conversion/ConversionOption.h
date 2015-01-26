/**
 * @file    ConversionOption.h
 * @brief   Definition of ConversionOption, the class encapsulating conversion options.
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
 * @class ConversionOption
 * @sbmlbrief{core} A single configuration setting for an SBML converter.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * LibSBML provides a number of converters that can perform transformations
 * on SBML documents.  These converters allow their behaviors to be
 * controlled by setting property values.  Converter properties are
 * communicated using objects of class ConversionProperties, and within
 * such objects, individual options are encapsulated using ConversionOption
 * objects.
 *
 * A ConversionOption @if conly structure @else object@endif@~ consists of
 * four parts:
 * @li A @em key, acting as the name of the option.
 * @li A @em value of this option.
 * @li A @em type for the value; the type code is chosen from @if clike
 * an enumeration @else a set of integer constants@endif@~ whose names all
 * begin with the prefix <code>CNV_TYPE_</code>.  (See the separate <a
 * class="el" href="#ConversionOptionType_t">subsection</a> below for more
 * information.)
 * @li A @em description consisting of a text string that describes the
 * option in some way.
 *
 * There are no constraints on the values of keys or descriptions;
 * authors of SBML converters are free to choose them as they see fit.
 *
 * @section ConversionOptionType_t Conversion option data types
 *
 * An option in ConversionOption must have a data type declared, to
 * indicate whether it is a string value, an integer, and so forth.  The
 * possible types of values are taken from
 * @if clike the enumeration ConversionOptionType_t @else a set of
 * constants whose symbol names begin with the prefix
 * <code>CNV_TYPE_</code>@endif. The following are the possible values:
 *
 * <p>
 * <center>
 * <table width="90%" cellspacing="1" cellpadding="1" border="0" class="normal-font">
 *  <tr style="background: lightgray" class="normal-font">
 *      <td><strong>Enumerator</strong></td>
 *      <td><strong>Meaning</strong></td>
 *  </tr>
 * <tr>
 * <td><code>@sbmlconstant{CNV_TYPE_BOOL, ConversionOptionType_t}</code></td>
 * <td>Indicates the value type is a Boolean.</td>
 * </tr>
 * <tr>
 * <td><code>@sbmlconstant{CNV_TYPE_DOUBLE, ConversionOptionType_t}</code></td>
 * <td>Indicates the value type is a double-sized float.</td>
 * </tr>
 * <tr>
 * <td><code>@sbmlconstant{CNV_TYPE_INT, ConversionOptionType_t}</code></td>
 * <td>Indicates the value type is an integer.</td>
 * </tr>
 * <tr>
 * <td><code>@sbmlconstant{CNV_TYPE_SINGLE, ConversionOptionType_t}</code></td>
 * <td>Indicates the value type is a float.</td>
 * </tr>
 * <tr>
  * <td><code>@sbmlconstant{CNV_TYPE_STRING, ConversionOptionType_t}</code></td>
 * <td>Indicates the value type is a string.</td>
 * </tr>
 * </table>
 * </center>
 *
 * @see ConversionProperties
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_cnv_type
 *
 * @par
 * The conversion @p type argument value must be one of
 * @if clike the values defined in the enumeration
 * ConversionOptionType_t.@endif@if java the constants whose names begin
 * with the characters <code>CNV_TYPE_</code> in the interface class
 * {@link libsbmlConstants}.@endif@if python the constants whose names begin
 * with the characters <code>CNV_TYPE_</code> in the interface class
 * @link libsbml libsbml@endlink.@endif
 */

#ifndef ConversionOption_h
#define ConversionOption_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * @enum  ConversionOptionType_t
 * @brief ConversionOptionType_t is the enumeration of possible option types.
 */
typedef enum
{
    CNV_TYPE_BOOL     /*!< The Boolean option value type. */
  , CNV_TYPE_DOUBLE   /*!< The double-sized float option value type. */
  , CNV_TYPE_INT      /*!< The integer option value type. */
  , CNV_TYPE_SINGLE   /*!< The float option value type. */
  , CNV_TYPE_STRING   /*!< The string option value type. */
} ConversionOptionType_t;

LIBSBML_CPP_NAMESPACE_END


#ifdef __cplusplus
#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN ConversionOption
{
public:

  /**
   * Creates a new ConversionOption.
   *
   * This is the general constructor, taking arguments for all aspects of
   * an option.  Other constructors exist with different arguments.
   *
   * @copydetails doc_cnv_type
   *
   * @param key the key for this option
   * @param value an optional value for this option
   * @param type the type of this option
   * @param description the description for this option
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  ConversionOption(const std::string& key, const std::string& value="",
                   ConversionOptionType_t type=CNV_TYPE_STRING,
                   const std::string& description="");


  /**
   * Creates a new ConversionOption specialized for string-type options.
   *
   * @param key the key for this option
   * @param value the value for this option
   * @param description an optional description
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  ConversionOption(const std::string& key, const char* value,
                   const std::string& description="");


  /**
   * Creates a new ConversionOption specialized for Boolean-type options.
   *
   * @param key the key for this option
   * @param value the value for this option
   * @param description an optional description
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  ConversionOption(const std::string& key, bool value,
                   const std::string& description="");


  /**
   * Creates a new ConversionOption specialized for double-type options.
   *
   * @param key the key for this option
   * @param value the value for this option
   * @param description an optional description
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  ConversionOption(const std::string& key, double value,
                   const std::string& description="");


  /**
   * Creates a new ConversionOption specialized for float-type options.
   *
   * @param key the key for this option
   * @param value the value for this option
   * @param description an optional description
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  ConversionOption(const std::string& key, float value,
                   const std::string& description="");


  /**
   * Creates a new ConversionOption specialized for integer-type options.
   *
   * @param key the key for this option
   * @param value the value for this option
   * @param description an optional description
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  ConversionOption(const std::string& key, int value,
                   const std::string& description="");


  /**
   * Copy constructor; creates a copy of an ConversionOption object.
   *
   * @param orig the ConversionOption object to copy.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  ConversionOption(const ConversionOption& orig);


  /**
   * Assignment operator for ConversionOption.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  ConversionOption& operator=(const ConversionOption& rhs);


  /**
   * Destroys this object.
   */
  virtual ~ConversionOption();


  /**
   * Creates and returns a deep copy of this ConversionOption object.
   *
   * @return the (deep) copy of this ConversionOption object.
   */
  virtual ConversionOption* clone() const;


  /**
   * Returns the key for this option.
   *
   * @return the key, as a string.
   */
  const std::string& getKey() const;


  /**
   * Sets the key for this option.
   *
   * @param key a string representing the key to set.
   */
  void setKey(const std::string& key);


  /**
   * Returns the value of this option.
   *
   * @return the value of this option, as a string.
   */
  const std::string& getValue() const;


  /**
   * Sets the value for this option.
   *
   * @param value the value to set, as a string.
   */
  void setValue(const std::string& value);


  /**
   * Returns the description string for this option.
   *
   * @return the description of this option.
   */
  const std::string& getDescription() const;


  /**
   * Sets the description text for this option.
   *
   * @param description the description to set for this option.
   */
  void setDescription(const std::string& description);


  /**
   * Returns the type of this option
   *
   * @return the type of this option.
   */
  ConversionOptionType_t getType() const;


  /**
   * Sets the type of this option.
   *
   * @copydetails doc_cnv_type
   *
   * @param type the type value to use.
   */
  void setType(ConversionOptionType_t type);


  /**
   * Returns the value of this option as a Boolean.
   *
   * @return the value of this option.
   */
  virtual bool getBoolValue() const;


  /**
   * Set the value of this option to a given Boolean value.
   *
   * Invoking this method will also set the type of the option to
   * @sbmlconstant{CNV_TYPE_BOOL, ConversionOptionType_t}.
   *
   * @param value the Boolean value to set
   */
  virtual void setBoolValue(bool value);


  /**
   * Returns the value of this option as a @c double.
   *
   * @return the value of this option.
   */
  virtual double getDoubleValue() const;


  /**
   * Set the value of this option to a given @c double value.
   *
   * Invoking this method will also set the type of the option to
   * @sbmlconstant{CNV_TYPE_DOUBLE, ConversionOptionType_t}.
   *
   * @param value the value to set
   */
  virtual void setDoubleValue(double value);


  /**
   * Returns the value of this option as a @c float.
   *
   * @return the value of this option as a float
   */
  virtual float getFloatValue() const;


  /**
   * Set the value of this option to a given @c float value.
   *
   * Invoking this method will also set the type of the option to
   * @sbmlconstant{CNV_TYPE_SINGLE, ConversionOptionType_t}.
   *
   * @param value the value to set
   */
  virtual void setFloatValue(float value);


  /**
   * Returns the value of this option as an @c integer.
   *
   * @return the value of this option, as an int
   */
  virtual int getIntValue() const;


  /**
   * Set the value of this option to a given @c int value.
   *
   * Invoking this method will also set the type of the option to
   * @sbmlconstant{CNV_TYPE_INT, ConversionOptionType_t}.
   *
   * @param value the value to set
   */
  virtual void setIntValue(int value);


protected:
  /** @cond doxygenLibsbmlInternal */

  std::string mKey;
  std::string mValue;
  ConversionOptionType_t mType;
  std::string mDescription;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new ConversionOption_t with the given key.
 *
 * @param key the key for this option
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
ConversionOption_t*
ConversionOption_create(const char* key);

/**
 * Creates and returns a deep copy of the ConversionOption_t structure.
 *
 * @param co the conversion option to clone
 *
 * @return a (deep) copy of the ConversionOption_t structure.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
ConversionOption_t*
ConversionOption_clone(const ConversionOption_t* co);

/**
 * Creates a new ConversionOption_t with given key and type.
 *
 * @param key the key for this option
 * @param type the type of this option
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
ConversionOption_t*
ConversionOption_createWithKeyAndType(const char* key, ConversionOptionType_t type);

/**
 * Returns the key for the given option.
 *
 * @param co the conversion option
 *
 * @return the key, as a string.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
const char*
ConversionOption_getKey(const ConversionOption_t* co);

/**
 * Returns the description for the given option.
 *
 * @param co the conversion option
 *
 * @return the description, as a string.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
const char*
ConversionOption_getDescription(const ConversionOption_t* co);

/**
 * Returns the value for the given option.
 *
 * @param co the conversion option
 *
 * @return the value, as a string.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
const char*
ConversionOption_getValue(const ConversionOption_t* co);

/**
 * Returns the value (as boolean) for the given option.
 *
 * @param co the conversion option
 *
 * @return the value, as a boolean.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
int
ConversionOption_getBoolValue(const ConversionOption_t* co);

/**
 * Returns the value (as integer) for the given option.
 *
 * @param co the conversion option
 *
 * @return the value, as a integer.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
int
ConversionOption_getIntValue(const ConversionOption_t* co);

/**
 * Returns the value (as float) for the given option.
 *
 * @param co the conversion option
 *
 * @return the value, as a float.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
float
ConversionOption_getFloatValue(const ConversionOption_t* co);

/**
 * Returns the value (as double) for the given option.
 *
 * @param co the conversion option
 *
 * @return the value, as a double.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
double
ConversionOption_getDoubleValue(const ConversionOption_t* co);

/**
 * Returns the type for the given option.
 *
 * @param co the conversion option
 *
 * @return the type
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
ConversionOptionType_t
ConversionOption_getType(const ConversionOption_t* co);

/**
 * Sets the key for the option.
 *
 * @param co the conversion option
 * @param key a string representing the key to set.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
void
ConversionOption_setKey(ConversionOption_t* co, const char* key);

/**
 * Sets the description for the option.
 *
 * @param co the conversion option
 * @param description a string representing the description to set.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
void
ConversionOption_setDescription(ConversionOption_t* co, const char* description);

/**
 * Sets the value for the option.
 *
 * @param co the conversion option
 * @param value a string representing the value to set.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
void
ConversionOption_setValue(ConversionOption_t* co, const char* value);

/**
 * Sets the value for the option.
 *
 * @param co the conversion option
 * @param value a bool representing the value to set.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
void
ConversionOption_setBoolValue(ConversionOption_t* co, int value);

/**
 * Sets the value for the option.
 *
 * @param co the conversion option
 * @param value an integer representing the value to set.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
void
ConversionOption_setIntValue(ConversionOption_t* co, int value);

/**
 * Sets the value for the option.
 *
 * @param co the conversion option
 * @param value a float representing the value to set.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
void
ConversionOption_setFloatValue(ConversionOption_t* co, float value);

/**
 * Sets the value for the option.
 *
 * @param co the conversion option
 * @param value a double representing the value to set.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
void
ConversionOption_setDoubleValue(ConversionOption_t* co, double value);

/**
 * Sets the type for the option.
 *
 * @param co the conversion option
 * @param type the type for this option.
 *
 * @memberof ConversionOption_t
 */
LIBSBML_EXTERN
void
ConversionOption_setType(ConversionOption_t* co, ConversionOptionType_t type);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif /* !ConversionOption */

