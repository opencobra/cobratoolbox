/**
 * @file    LocalParameter.h
 * @brief   Definitions of LocalParameter and ListOfLocalParameters.
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 * 
 * @class LocalParameter
 * @sbmlbrief{core} A parameter inside an SBML <em>reaction</em> definition.
 *
 * LocalParameter has been introduced in SBML Level&nbsp;3 to serve as the
 * object class for parameter definitions that are intended to be local to
 * a Reaction.  Objects of class LocalParameter never appear at the Model
 * level; they are always contained within ListOfLocalParameters lists
 * which are in turn contained within KineticLaw objects.
 *
 * Like its global Parameter counterpart, the LocalParameter object class
 * is used to define a symbol associated with a value; this symbol can then
 * be used in a model's mathematical formulas (and specifically, for
 * LocalParameter, reaction rate formulas).  Unlike Parameter, the
 * LocalParameter class does not have a "constant" attribute: local
 * parameters within reactions are @em always constant.
 * 
 * LocalParameter has one required attribute, "id", to give the
 * parameter a unique identifier by which other parts of an SBML model
 * definition can refer to it.  A parameter can also have an optional
 * "name" attribute of type @c string.  Identifiers and names must be used
 * according to the guidelines described in the SBML specifications.
 * 
 * The optional attribute "value" determines the value (of type @c double)
 * assigned to the parameter.  A missing value for "value" implies that
 * the value either is unknown, or to be obtained from an external source,
 * or determined by an initial assignment.  The unit of measurement
 * associated with the value of the parameter can be specified using the
 * optional attribute "units".  Here we only mention briefly some notable
 * points about the possible unit choices, but readers are urged to consult
 * the SBML specification documents for more information:
 * <ul>
 *
 * <li> In SBML Level&nbsp;3, there are no constraints on the units that
 * can be assigned to parameters in a model; there are also no units to
 * inherit from the enclosing Model object.
 *
 * <li> In SBML Level&nbsp;2, the value assigned to the parameter's "units"
 * attribute must be chosen from one of the following possibilities: one of
 * the base unit identifiers defined in SBML; one of the built-in unit
 * identifiers @c "substance", @c "time", @c "volume", @c "area" or @c
 * "length"; or the identifier of a new unit defined in the list of unit
 * definitions in the enclosing Model structure.  There are no constraints
 * on the units that can be chosen from these sets.  There are no default
 * units for local parameters.
 * </ul>
 *
 * As with all other major SBML components, LocalParameter is derived from
 * SBase, and the methods defined on SBase are available on LocalParameter.
 * 
 * @warning <span class="warning">LibSBML derives LocalParameter from
 * Parameter; however, this does not precisely match the object hierarchy
 * defined by SBML Level&nbsp;3, where LocalParameter is derived directly
 * from SBase and not Parameter.  We believe this arrangement makes it easier
 * for libSBML users to program applications that work with both SBML
 * Level&nbsp;2 and SBML Level&nbsp;3, but programmers should also keep in
 * mind this difference exists.  A side-effect of libSBML's scheme is that
 * certain methods on LocalParameter that are inherited from Parameter do not
 * actually have relevance to LocalParameter objects.  An example of this is
 * the methods pertaining to Parameter's attribute "constant" (i.e.,
 * isSetConstant(), setConstant(), and getConstant()).</span>
 *
 * @see ListOfLocalParameters
 * @see KineticLaw
 * 
 * 
 * <!-- ------------------------------------------------------------------- -->
 * @class ListOfLocalParameters
 * @sbmlbrief{core} A list of LocalParameter objects.
 * 
 * @copydetails doc_what_is_listof
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_localparameter_units
 *
 * @par
 * LocalParameters in SBML have an attribute ("units") for declaring the
 * units of measurement intended for the parameter's value.  <b>No
 * defaults are defined</b> by SBML in the absence of a definition for
 * "units".  This method returns a UnitDefinition object based on the
 * units declared for this LocalParameter using its "units" attribute, or
 * it returns @c NULL if no units have been declared.
 *
 * Note that unit declarations for LocalParameter objects are specified
 * in terms of the @em identifier of a unit (e.g., using setUnits()), but
 * @em this method returns a UnitDefinition object, not a unit
 * identifier.  It does this by constructing an appropriate
 * UnitDefinition.  For SBML Level&nbsp;2 models, it will do this even
 * when the value of the "units" attribute is one of the predefined SBML
 * units @c "substance", @c "volume", @c "area", @c "length" or @c
 * "time".  Callers may find this useful in conjunction with the helper
 * methods provided by the UnitDefinition class for comparing different
 * UnitDefinition objects.
 *
 */

#ifndef LocalParameter_h
#define LocalParameter_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/Parameter.h>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>


#ifdef __cplusplus


#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBMLVisitor;


class LIBSBML_EXTERN LocalParameter : public Parameter
{
public:

  /**
   * Creates a new LocalParameter object with the given SBML @p level and
   * @p version values.
   *
   * @param level an unsigned int, the SBML Level to assign to this
   * LocalParameter.
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * LocalParameter.
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  LocalParameter (unsigned int level, unsigned int version);


  /**
   * Creates a new LocalParameter object with the given SBMLNamespaces
   * object @p sbmlns.
   *
   * @copydetails doc_what_are_sbmlnamespaces 
   *
   * It is worth emphasizing that although this constructor does not take
   * an identifier argument, in SBML Level&nbsp;2 and beyond, the "id"
   * (identifier) attribute of a LocalParameter is required to have a value.
   * Thus, callers are cautioned to assign a value after calling this
   * constructor if no identifier is provided as an argument.  Setting the
   * identifier can be accomplished using the method
   * @if java setId(String id)@else setId()@endif.
   *
   * @param sbmlns an SBMLNamespaces object.
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  LocalParameter (SBMLNamespaces* sbmlns);


  /**
   * Destroys this LocalParameter.
   */
  virtual ~LocalParameter ();


  /**
   * Copy constructor; creates a copy of a given LocalParameter object.
   * 
   * @param orig the LocalParameter instance to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  LocalParameter(const LocalParameter& orig);


  /**
   * Copy constructor; creates a LocalParameter object by copying
   * the attributes of a given Parameter object.
   * 
   * @param orig the Parameter instance to copy.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  LocalParameter(const Parameter& orig);


  /**
   * Assignment operator for LocalParameter.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  LocalParameter& operator=(const LocalParameter& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of LocalParameter.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next LocalParameter in the list
   * of parameters within which this LocalParameter is embedded (i.e., either
   * the list of parameters in the parent Model or the list of parameters
   * in the enclosing KineticLaw).
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this LocalParameter object.
   *
   * @return the (deep) copy of this LocalParameter object.
   */
  virtual LocalParameter* clone () const;


  /**
   * Constructs and returns a UnitDefinition that corresponds to the units
   * of this LocalParameter's value.
   *
   * @copydetails doc_localparameter_units
   * 
   * @return a UnitDefinition that expresses the units of this 
   * LocalParameter, or @c NULL if one cannot be constructed.
   *
   * @note The libSBML system for unit analysis depends on the model as a
   * whole.  In cases where the LocalParameter object has not yet been
   * added to a model, or the model itself is incomplete, unit analysis is
   * not possible, and consequently this method will return @c NULL.
   *
   * @see isSetUnits()
   */
  UnitDefinition * getDerivedUnitDefinition();


  /**
   * Constructs and returns a UnitDefinition that corresponds to the units
   * of this LocalParameter's value.
   *
   * @copydetails doc_localparameter_units
   *
   * @return a UnitDefinition that expresses the units of this 
   * LocalParameter, or @c NULL if one cannot be constructed.
   *
   * @note The libSBML system for unit analysis depends on the model as a
   * whole.  In cases where the LocalParameter object has not yet been
   * added to a model, or the model itself is incomplete, unit analysis is
   * not possible, and consequently this method will return @c NULL.
   *
   * @see isSetUnits()
   */
  const UnitDefinition * getDerivedUnitDefinition() const;


  /**
   * Returns the libSBML type code for this SBML object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_LOCAL_PARAMETER, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for LocalParameter,
   * is always @c "localParameter".
   * 
   * @return the name of this element, i.e., @c "localParameter".
   */
  virtual const std::string& getElementName () const;


  /**
   * Predicate returning @c true if all the required attributes for this
   * LocalParameter object have been set.
   *
   * The required attributes for a LocalParameter object are:
   * @li "id"
   * @li "value"
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const ;

  /** @cond doxygenLibsbmlInternal */

  /* a local Parameter does not have a constant attribute but
   * because it derives from parameter it inherits one
   * need to make sure these do the right thing
   */
  virtual bool getConstant () const;

  virtual bool isSetConstant () const;

  virtual int setConstant (bool flag);
  /** @endcond */

protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Subclasses should override this method to get the list of
   * expected attributes.
   * This function is invoked from corresponding readAttributes()
   * function.
   */
  virtual void addExpectedAttributes(ExpectedAttributes& attributes);


  /**
   * Subclasses should override this method to read values from the given
   * XMLAttributes set into their specific fields.  Be sure to call your
   * parents implementation of this method as well.
   */
  virtual void readAttributes (const XMLAttributes& attributes,
                               const ExpectedAttributes& expectedAttributes);

  void readL3Attributes (const XMLAttributes& attributes);


  /**
   * Subclasses should override this method to write their XML attributes
   * to the XMLOutputStream.  Be sure to call your parents implementation
   * of this method as well.
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;

  /* the validator classes need to be friends to access the 
   * protected constructor that takes no arguments
   */
  friend class Validator;
  friend class ConsistencyValidator;
  friend class IdentifierConsistencyValidator;
  friend class InternalConsistencyValidator;
  friend class L1CompatibilityValidator;
  friend class L2v1CompatibilityValidator;
  friend class L2v2CompatibilityValidator;
  friend class L2v3CompatibilityValidator;
  friend class L2v4CompatibilityValidator;
  friend class MathMLConsistencyValidator;
  friend class ModelingPracticeValidator;
  friend class OverdeterminedValidator;
  friend class SBOConsistencyValidator;
  friend class UnitConsistencyValidator;

  /** @endcond */
};


class LIBSBML_EXTERN ListOfLocalParameters : public ListOfParameters
{
public:

  /**
   * Creates a new ListOfLocalParameters object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   * 
   * @param version the Version within the SBML Level
   */
  ListOfLocalParameters (unsigned int level, unsigned int version);
          

  /**
   * Creates a new ListOfLocalParameters object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfLocalParameters object to be created.
   */
  ListOfLocalParameters (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfLocalParameters object.
   *
   * @return the (deep) copy of this ListOfLocalParameters object.
   */
  virtual ListOfLocalParameters* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., LocalParameter objects, if the list is non-empty).
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for the objects contained in this ListOf:
   * @sbmlconstant{SBML_LOCAL_PARAMETER, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfLocalParameters, the XML element name is @c "listOfLocalParameters".
   * 
   * @return the name of this element, i.e., @c "listOfLocalParameters".
   */
  virtual const std::string& getElementName () const;


  /**
   * Returns the LocalParameter object located at position @p n within this
   * ListOfLocalParameters instance.
   *
   * @param n the index number of the LocalParameter to get.
   * 
   * @return the nth LocalParameter in this ListOfLocalParameters.  If the
   * index @p n is out of bounds for the length of the list, then @c NULL
   * is returned.
   *
   * @see size()
   * @see get(const std::string& sid)
   */
  virtual LocalParameter * get (unsigned int n); 


  /**
   * Returns the LocalParameter object located at position @p n within this
   * ListOfLocalParameters instance.
   *
   * @param n the index number of the LocalParameter to get.
   * 
   * @return the item at position @p n.  The caller owns the returned
   * object and is responsible for deleting it.  If the index number @p n
   * is out of bounds for the length of the list, then @c NULL is returned.
   *
   * @see size()
   * @see get(const std::string& sid)
   */
  virtual const LocalParameter * get (unsigned int n) const; 


  /**
   * Returns the first LocalParameter object matching the given identifier.
   *
   * @param sid a string, the identifier of the LocalParameter to get.
   * 
   * @return the LocalParameter object found.  The caller owns the returned
   * object and is responsible for deleting it.  If none of the items have
   * an identifier matching @p sid, then @c NULL is returned.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual LocalParameter* get (const std::string& sid);


  /**
   * Returns the first LocalParameter object matching the given identifier.
   *
   * @param sid a string representing the identifier of the LocalParameter
   * to get.
   * 
   * @return the LocalParameter object found.  The caller owns the returned
   * object and is responsible for deleting it.  If none of the items have
   * an identifier matching @p sid, then @c NULL is returned.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const LocalParameter* get (const std::string& sid) const;


   /**
   * Returns the first child element found that has the given @p id in the
   * model-wide SId namespace, or @c NULL if no such object is found.
   *
   * Note that LocalParameters, while they use the SId namespace, are not in
   * the model-wide SId namespace, so no LocalParameter object will be
   * returned from this function (and is the reason we override the base
   * ListOf::getElementBySId function here).
   *
   * @param id string representing the id of objects to find
   *
   * @return pointer to the first element found with the given @p id.
   */
  virtual SBase* getElementBySId(const std::string& id);
  
  
 /**
   * Removes the nth item from this ListOfLocalParameters, and returns a
   * pointer to it.
   *
   * @param n the index of the item to remove.  
   *
   * @return the item removed.  The caller owns the returned object and is
   * responsible for deleting it.  If the index number @p n is out of
   * bounds for the length of the list, then @c NULL is returned.
   *
   * @see size()
   * @see remove(const std::string& sid)
   */
  virtual LocalParameter* remove (unsigned int n);


  /**
   * Removes the first LocalParameter object in this ListOfLocalParameters
   * matching the given identifier, and returns a pointer to it.
   *
   * @param sid the identifier of the item to remove.
   *
   * @return the item removed.  The caller owns the returned object and is
   * responsible for deleting it.  If none of the items have an identifier
   * matching @p sid, then @c NULL is returned.
   */
  virtual LocalParameter* remove (const std::string& sid);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Get the ordinal position of this element in the containing object
   * (which in this case is the Model object).
   *
   * The ordering of elements in the XML form of SBML is generally fixed
   * for most components in SBML.  So, for example, the ListOfLocalParameters
   * in a model is (in SBML Level&nbsp;2 Version&nbsp;4) the seventh
   * ListOf___.  (However, it differs for different Levels and Versions of
   * SBML.)
   *
   * @return the ordinal position of the element with respect to its
   * siblings, or @c -1 (default) to indicate the position is not significant.
   */
  virtual int getElementPosition () const;

  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Create a ListOfLocalParameters object corresponding to the next token in
   * the XML input stream.
   * 
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream, or @c NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new LocalParameter_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * LocalParameter_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * LocalParameter_t
 *
 * @return a pointer to the newly created LocalParameter_t structure.
 *
 * @note Once a LocalParameter_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the LocalParameter_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
LocalParameter_t *
LocalParameter_create (unsigned int level, unsigned int version);


/**
 * Creates a new LocalParameter_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this LocalParameter_t
 *
 * @return a pointer to the newly created LocalParameter_t structure.
 *
 * @note Once a LocalParameter_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the LocalParameter_t.  Despite this, the ability to supply the values at creation time
 * is an important aid to creating valid SBML.  Knowledge of the intended SBML
 * Level and Version determine whether it is valid to assign a particular value
 * to an attribute, or whether it is valid to add a structure to an existing
 * SBMLDocument_t.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
LocalParameter_t *
LocalParameter_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given LocalParameter_t structure.
 *
 * @param p the LocalParameter_t structure to be freed.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
void
LocalParameter_free (LocalParameter_t *p);


/**
 * Creates a deep copy of the given LocalParameter_t structure
 * 
 * @param p the LocalParameter_t structure to be copied
 * 
 * @return a (deep) copy of the given LocalParameter_t structure.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
LocalParameter_t *
LocalParameter_clone (const LocalParameter_t *p);


/**
 * Does nothing:  this function initializes structures according to their defaults in SBML Level 2, but Local Parameters did not exist in SBML Level 2.
 * 
 * @param p the LocalParameter_t structure to be ignored
 * 
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
void
LocalParameter_initDefaults (LocalParameter_t *p);


/**
 * Returns a list of XMLNamespaces_t associated with this LocalParameter_t
 * structure.
 *
 * @param p the LocalParameter_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
LocalParameter_getNamespaces(LocalParameter_t *p);


/**
 * Takes a LocalParameter_t structure and returns its identifier.
 *
 * @param p the LocalParameter_t structure whose identifier is sought
 * 
 * @return the identifier of this LocalParameter_t, as a pointer to a string.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
const char *
LocalParameter_getId (const LocalParameter_t *p);


/**
 * Takes a LocalParameter_t structure and returns its name.
 *
 * @param p the LocalParameter_t whose name is sought.
 *
 * @return the name of this LocalParameter_t, as a pointer to a string.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
const char *
LocalParameter_getName (const LocalParameter_t *p);


/**
 * Takes a LocalParameter_t structure and returns its value.
 *
 * @param p the LocalParameter_t whose value is sought.
 *
 * @return the value assigned to this LocalParameter_t structure, as a @c double.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
double
LocalParameter_getValue (const LocalParameter_t *p);


/**
 * Takes a LocalParameter_t structure and returns its units.
 *
 * @param p the LocalParameter_t whose units are sought.
 *
 * @return the units assigned to this LocalParameter_t structure, as a pointer
 * to a string.  
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
const char *
LocalParameter_getUnits (const LocalParameter_t *p);


/**
 * Because a LocalParameter_t has no 'constant' attribute, always returns 'true', as local parameters in SBML may not vary.
 *
 * @param p the LocalParameter_t to ignore.
 *
 * @return @c non-zero (true).
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_getConstant (const LocalParameter_t *p);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * LocalParameter_t structure's identifier is set.
 *
 * @param p the LocalParameter_t structure to query
 * 
 * @return @c non-zero (true) if the "id" attribute of the given
 * LocalParameter_t structure is set, zero (false) otherwise.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_isSetId (const LocalParameter_t *p);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * LocalParameter_t structure's name is set.
 *
 * @param p the LocalParameter_t structure to query
 * 
 * @return @c non-zero (true) if the "name" attribute of the given
 * LocalParameter_t structure is set, zero (false) otherwise.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_isSetName (const LocalParameter_t *p);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * LocalParameter_t structure's value is set.
 * 
 * @param p the LocalParameter_t structure to query
 * 
 * @return @c non-zero (true) if the "value" attribute of the given
 * LocalParameter_t structure is set, zero (false) otherwise.
 *
 * @note In SBML Level 1 Version 1, a LocalParameter_t value is required and
 * therefore <em>should always be set</em>.  In Level 1 Version 2 and
 * later, the value is optional, and as such, may or may not be set.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_isSetValue (const LocalParameter_t *p);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * LocalParameter_t structure's units have been set.
 *
 * @param p the LocalParameter_t structure to query
 * 
 * @return @c non-zero (true) if the "units" attribute of the given
 * LocalParameter_t structure is set, zero (false) otherwise.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_isSetUnits (const LocalParameter_t *p);


/**
 * Assigns the identifier of a LocalParameter_t structure.
 *
 * This makes a copy of the string passed in the param @p sid.
 *
 * @param p the LocalParameter_t structure to set.
 * @param sid the string to use as the identifier.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "id" attribute.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_setId (LocalParameter_t *p, const char *sid);


/**
 * Assign the name of a LocalParameter_t structure.
 *
 * This makes a copy of the string passed in as the argument @p name.
 *
 * @param p the LocalParameter_t structure to set.
 * @param name the string to use as the name.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with the name set to NULL is equivalent to
 * unsetting the "name" attribute.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_setName (LocalParameter_t *p, const char *name);


/**
 * Assign the value of a LocalParameter_t structure.
 *
 * @param p the LocalParameter_t structure to set.
 * @param value the @c double value to use.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_setValue (LocalParameter_t *p, double value);


/**
 * Assign the units of a LocalParameter_t structure.
 *
 * This makes a copy of the string passed in as the argument @p units.
 *
 * @param p the LocalParameter_t structure to set.
 * @param units the string to use as the identifier of the units to assign.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with units set to NULL is equivalent to
 * unsetting the "units" attribute.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_setUnits (LocalParameter_t *p, const char *units);

/**
 * Because LocalParameter_t structures don't have a 'constant' attribute, this function always
 * returns @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}.
 *
 * @param p the LocalParameter_t structure to leave unchanged.
 * @param value The boolean value to ignore.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible value
 * returned by this function is:
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_setConstant (LocalParameter_t *p, int value);


/**
 * Unsets the name of this LocalParameter_t structure.
 * 
 * @param p the LocalParameter_t structure whose name is to be unset.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_unsetName (LocalParameter_t *p);


/**
 * Unsets the value of this LocalParameter_t structure.
 *
 * In SBML Level 1 Version 1, a parameter is required to have a value and
 * therefore this attribute <em>should always be set</em>.  In Level 1
 * Version 2 and beyond, a value is optional, and as such, may or may not be
 * set.
 *
 * @param p the LocalParameter_t structure whose value is to be unset.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_unsetValue (LocalParameter_t *p);


/**
 * Unsets the units of this LocalParameter_t structure.
 * 
 * @param p the LocalParameter_t structure whose units are to be unset.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_unsetUnits (LocalParameter_t *p);


/**
 * Predicate returning @c true or @c false depending on whether
 * all the required attributes for this LocalParameter object
 * have been set.
 *
 * @param p the LocalParameter_t structure to check.
 *
 * The required attributes for a LocalParameter object are:
 * @li id (name in L1)
 *
 * @return @c 1 if all the required attributes for this object have been
 * defined, @c 0 otherwise.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
int
LocalParameter_hasRequiredAttributes (LocalParameter_t *p);


/**
 * Constructs and returns a UnitDefinition_t structure that expresses 
 * the units of this LocalParameter_t structure.
 *
 * @param p the LocalParameter_t structure whose units are to be returned.
 *
 * @return a UnitDefinition_t structure that expresses the units 
 * of this LocalParameter_t strucuture.
 *
 * @note This function returns the units of the LocalParameter_t expressed 
 * as a UnitDefinition_t. The units may be those explicitly declared. 
 * In the case where no units have been declared, @c NULL is returned.
 *
 * @memberof LocalParameter_t
 */
LIBSBML_EXTERN
UnitDefinition_t * 
LocalParameter_getDerivedUnitDefinition(LocalParameter_t *p);


/**
 * Returns the LocalParameter_t structure having a given identifier.
 *
 * @param lo the ListOfLocalParameters_t structure to search.
 * @param sid the "id" attribute value being sought.
 *
 * @return item in the @p lo ListOfLocalParameters with the given @p sid or a
 * null pointer if no such item exists.
 *
 * @see ListOf_t
 *
 * @memberof ListOfLocalParameters_t
 */
LIBSBML_EXTERN
LocalParameter_t *
ListOfLocalParameters_getById (ListOf_t *lo, const char *sid);


/**
 * Removes a LocalParameter_t structure based on its identifier.
 *
 * The caller owns the returned item and is responsible for deleting it.
 *
 * @param lo the list of LocalParameter_t structures to search.
 * @param sid the "id" attribute value of the structure to remove
 *
 * @return The LocalParameter_t structure removed, or a null pointer if no such
 * item exists in @p lo.
 *
 * @see ListOf_t
 *
 * @memberof ListOfLocalParameters_t
 */
LIBSBML_EXTERN
LocalParameter_t *
ListOfLocalParameters_removeById (ListOf_t *lo, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* LocalParameter_h */
