/**
 * @file    ConversionProperties.h
 * @brief   Definition of ConversionProperties, the class encapsulating conversion configuration.
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
 * @class ConversionProperties
 * @sbmlbrief{core} Set of configuration option values for a converter.
 *
 * @htmlinclude libsbml-facility-only-warning.html
 *
 * LibSBML provides a number of converters that can perform transformations
 * on SBML documents. The properties of SBML converters are communicated
 * using objects of class ConversionProperties, and within such objects,
 * individual options are encapsulated using ConversionOption objects.  The
 * ConversionProperties class provides numerous methods for setting and
 * getting options.
 *
 * ConversionProperties objects are also used to determine the target SBML
 * namespace when an SBML converter's behavior depends on the intended
 * Level+Version combination of SBML.  In addition, it is conceivable that
 * conversions may be affected by SBML Level&nbsp;3 packages being used by an
 * SBML document; consequently, the packages in use are also communicated by
 * the values of the SBML namespaces set on a ConversionProperties object.
 *
 * @see ConversionOption
 * @see SBMLNamespaces
 */

#ifndef ConversionProperties_h
#define ConversionProperties_h


#include <sbml/common/extern.h>
#include <sbml/SBMLNamespaces.h>
#include <sbml/conversion/ConversionOption.h>


#ifdef __cplusplus

#include <map>

LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN ConversionProperties
{
public:

  /**
   * Constructor that initializes the conversion properties
   * with a specific SBML target namespace.
   *
   * @param targetNS the target namespace to convert to
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  ConversionProperties(SBMLNamespaces* targetNS=NULL);


  /**
   * Copy constructor.
   *
   * @param orig the object to copy.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  ConversionProperties(const ConversionProperties& orig);


  /**
   * Assignment operator for conversion properties.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  ConversionProperties& operator=(const ConversionProperties& rhs);


  /**
   * Creates and returns a deep copy of this ConversionProperties object.
   *
   * @return the (deep) copy of this ConversionProperties object.
   */
  virtual ConversionProperties* clone() const;


  /**
   * Destructor.
   */
  virtual ~ConversionProperties();


  /**
   * Returns the current target SBML namespace.
   *
   * @return the SBMLNamepaces object expressing the target namespace.
   */
  virtual SBMLNamespaces * getTargetNamespaces() const;


  /**
   * Returns @c true if the target SBML namespace has been set.
   *
   * @return @c true if the target namespace has been set, @c false
   * otherwise.
   */
  virtual bool hasTargetNamespaces() const;


  /**
   * Sets the target namespace.
   *
   * @param targetNS the target namespace to use.
   */
  virtual void setTargetNamespaces(SBMLNamespaces *targetNS);


  /**
   * Returns the description string for a given option in this properties
   * object.
   *
   * @param key the key for the option.
   *
   * @return the description text of the option with the given key.
   */
  virtual const std::string& getDescription(const std::string& key) const;


  /**
   * Returns the type of a given option in this properties object.
   *
   * @param key the key for the option.
   *
   * @return the type of the option with the given key.
   */
  virtual ConversionOptionType_t  getType(const std::string& key) const;


  /**
   * Returns the ConversionOption object for a given key.
   *
   * @param key the key for the option.
   *
   * @return the option with the given key.
   */
  virtual ConversionOption* getOption(const std::string& key) const;

  
  /**
   * Returns the ConversionOption object for the given index.
   *
   * @param index the index for the option.
   *
   * @return the option with the given index.
   */
  virtual ConversionOption* getOption(int index) const;

  /**
   * Adds a copy of the given option to this properties object.
   *
   * @param option the option to add
   */
  virtual void addOption(const ConversionOption& option);


  /**
   * Adds a new ConversionOption object with the given parameters.
   *
   * @param key the key for the new option
   * @param value (optional) the value of that option
   * @param type (optional) the type of the option (see the documentation
   * for ConversionOption for more information about the types)
   * @param description (optional) the description for the option
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  virtual void addOption(const std::string& key, const std::string& value="",
                         ConversionOptionType_t type=CNV_TYPE_STRING,
                         const std::string& description="");


  /**
   * Adds a new ConversionOption object with the given parameters.
   *
   * @param key the key for the new option
   * @param value the string value of that option
   * @param description (optional) the description for the option
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  virtual void addOption(const std::string& key, const char* value,
                         const std::string& description="");


  /**
   * Adds a new ConversionOption object with the given parameters.
   *
   * @param key the key for the new option
   * @param value the boolean value of that option
   * @param description (optional) the description for the option
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  virtual void addOption(const std::string& key, bool value,
                         const std::string& description="");


  /**
   * Adds a new ConversionOption object with the given parameters.
   *
   * @param key the key for the new option
   * @param value the double value of that option
   * @param description (optional) the description for the option
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  virtual void addOption(const std::string& key, double value,
                         const std::string& description="");


  /**
   * Adds a new ConversionOption object with the given parameters.
   *
   * @param key the key for the new option
   * @param value the float value of that option
   * @param description (optional) the description for the option
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  virtual void addOption(const std::string& key, float value,
                         const std::string& description="");


  /**
   * Adds a new ConversionOption object with the given parameters.
   *
   * @param key the key for the new option
   * @param value the integer value of that option
   * @param description (optional) the description for the option
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  virtual void addOption(const std::string& key, int value,
                         const std::string& description="");


  /**
   * Removes the option with the given key from this properties object.
   *
   * @param key the key for the new option to remove
   * @return the removed option
   */
  virtual ConversionOption* removeOption(const std::string& key);


  /**
   * Returns @c true if this properties object contains an option with
   * the given key.
   *
   * @param key the key of the option to find.
   *
   * @return @c true if an option with the given @p key exists in
   * this properties object, @c false otherwise.
   */
  virtual bool hasOption(const std::string& key) const;


  /**
   * Returns the value of the given option as a string.
   *
   * @param key the key for the option.
   *
   * @return the string value of the option with the given key.
   */
  virtual const std::string& getValue(const std::string& key) const;


  /**
   * Sets the value of the given option to a string.
   *
   * @param key the key for the option
   * @param value the new value
   */
  virtual void setValue(const std::string& key, const std::string& value);


  /**
   * Returns the value of the given option as a Boolean.
   *
   * @param key the key for the option.
   *
   * @return the boolean value of the option with the given key.
   */
  virtual bool getBoolValue(const std::string& key) const;


  /**
   * Sets the value of the given option to a Boolean.
   *
   * @param key the key for the option.
   *
   * @param value the new Boolean value.
   */
  virtual void setBoolValue(const std::string& key, bool value);


  /**
   * Returns the value of the given option as a @c double.
   *
   * @param key the key for the option.
   *
   * @return the double value of the option with the given key.
   */
  virtual double getDoubleValue(const std::string& key) const;


  /**
   * Sets the value of the given option to a @c double.
   *
   * @param key the key for the option.
   *
   * @param value the new double value.
   */
  virtual void setDoubleValue(const std::string& key, double value);


  /**
   * Returns the value of the given option as a @c float.
   *
   * @param key the key for the option.
   *
   * @return the float value of the option with the given key.
   */
  virtual float getFloatValue(const std::string& key) const;


  /**
   * Sets the value of the given option to a @c float.
   *
   * @param key the key for the option.
   *
   * @param value the new float value.
   */
  virtual void setFloatValue(const std::string& key, float value);


  /**
   * Returns the value of the given option as an integer.
   *
   * @param key the key for the option.
   *
   * @return the int value of the option with the given key.
   */
  virtual int getIntValue(const std::string& key) const;


  /**
   * Sets the value of the given option to an integer.
   *
   * @param key the key for the option.
   *
   * @param value the new integer value.
   */
  virtual void setIntValue(const std::string& key, int value);

  /** 
   * Returns the number of options in this Conversion Properties object
   *
   * @return the number of options in this properties object
   */
  virtual int getNumOptions() const;

protected:
  /** @cond doxygenLibsbmlInternal */

  SBMLNamespaces *mTargetNamespaces;
  std::map<std::string, ConversionOption*> mOptions;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new conversion properties structure (without namespace)
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
ConversionProperties_t*
ConversionProperties_create();

/**
 * Creates a new conversion properties structure
 * with a specific SBML target namespace.
 *
 * @param sbmlns the target namespace to convert to
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
ConversionProperties_t*
ConversionProperties_createWithSBMLNamespace(SBMLNamespaces_t* sbmlns);

/**
 * Creates and returns a deep copy of the given ConversionProperties_t structure.
 *
 * @param cp the conversion properties to clone
 *
 * @return a (deep) copy of this ConversionProperties_t structure.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
ConversionProperties_t*
ConversionProperties_clone(const ConversionProperties_t* cp);

/**
 * Returns the value as boolean for a given option in the properties
 * structure.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 *
 * @return the boolean value of the option with the given key to be freed by the caller, or NULL.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
int
ConversionProperties_getBoolValue(const ConversionProperties_t* cp, const char* key);

/**
 * Returns the value as integer for a given option in the properties
 * structure.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 *
 * @return the integer value of the option with the given key to be freed by the caller, or -1.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
int
ConversionProperties_getIntValue(const ConversionProperties_t* cp, const char* key);

/**
 * Returns the description string for a given option in the properties
 * structure.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 *
 * @return the description text of the option with the given key to be freed by the caller.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
char*
ConversionProperties_getDescription(const ConversionProperties_t* cp, const char* key);

/**
 * Returns the value as double for a given option in the properties
 * structure.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 *
 * @return the double value of the option with the given key to be freed by the caller, or NaN.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
double
ConversionProperties_getDoubleValue(const ConversionProperties_t* cp, const char* key);

/**
 * Returns the value as float for a given option in the properties
 * structure.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 *
 * @return the float value of the option with the given key to be freed by the caller, or NaN.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
float
ConversionProperties_getFloatValue(const ConversionProperties_t* cp, const char* key);

/**
 * Returns the value string for a given option in the properties
 * structure.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 *
 * @return the string value of the option with the given key to be freed by the caller, or NULL.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
char*
ConversionProperties_getValue(const ConversionProperties_t* cp, const char* key);

/**
 * Returns the ConversionOption_t structure for a given key.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 *
 * @return the option with the given key, or NULL.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
const ConversionOption_t*
ConversionProperties_getOption(const ConversionProperties_t* cp, const char* key);

/**
 * Returns the type of a given option in the properties structure.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 *
 * @return the type of the option with the given key.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
ConversionOptionType_t
ConversionProperties_getType(const ConversionProperties_t* cp, const char* key);

/**
 * Returns the current target SBML namespace of the conversion properties.
 *
 * @param cp the conversion properties
 *
 * @return the SBMLNamepaces_t structure expressing the target namespace, or NULL.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
const SBMLNamespaces_t*
ConversionProperties_getTargetNamespaces(const ConversionProperties_t* cp);

/**
 * Checks whether the given properties structure has an option for the given key
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 *
 * @return @c 1 if the option exists, @c 0 otherwise.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
int
ConversionProperties_hasOption(const ConversionProperties_t* cp, const char* key);

/**
 * Tests whether the given conversion properties has a target namespace set
 *
 * @param cp the conversion properties
 *
 * @return @c 1 if the target namespace has been set, @c 0
 * otherwise.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
int
ConversionProperties_hasTargetNamespaces(const ConversionProperties_t* cp);

/**
 * Sets the target namespace.
 *
 * @param cp the conversion properties
 * @param sbmlns the target namespace to use.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
void
ConversionProperties_setTargetNamespaces(ConversionProperties_t* cp, SBMLNamespaces_t* sbmlns);

/**
 * Sets the value of the option with given key to the given boolean value.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 * @param value the new value for the option.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
void
ConversionProperties_setBoolValue(ConversionProperties_t* cp, const char* key, int value);

/**
 * Sets the value of the option with given key to the given int value.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 * @param value the new value for the option.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
void
ConversionProperties_setIntValue(ConversionProperties_t* cp, const char* key, int value);

/**
 * Sets the value of the option with given key to the given double value.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 * @param value the new value for the option.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
void
ConversionProperties_setDoubleValue(ConversionProperties_t* cp, const char* key, double value);

/**
 * Sets the value of the option with given key to the given float value.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 * @param value the new value for the option.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
void
ConversionProperties_setFloatValue(ConversionProperties_t* cp, const char* key, float value);

/**
 * Sets the value of the option with given key to the given value.
 *
 * @param cp the conversion properties
 * @param key the key for the option.
 * @param value the new value for the option.
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
void
ConversionProperties_setValue(ConversionProperties_t* cp, const char* key, const char* value);

/**
 * Adds a copy of the given ConversionOption_t structure to the properties.
 *
 * @param cp the conversion properties
 * @param option the option to add
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
void
ConversionProperties_addOption(ConversionProperties_t* cp, const ConversionOption_t* option);

/**
 * Adds a new ConversionOption_t structure with the given key to the properties.
 *
 * @param cp the conversion properties
 * @param key the key for the new option
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
void
ConversionProperties_addOptionWithKey(ConversionProperties_t* cp, const char* key);

/**
 * Removes the ConversionOption_t with the given key from the properties.
 *
 * @param cp the conversion properties
 * @param key the key for the option to remove
 *
 * @memberof ConversionProperties_t
 */
LIBSBML_EXTERN
void
ConversionProperties_removeOption(ConversionProperties_t* cp, const char* key);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif /* !ConversionProperties_h */

