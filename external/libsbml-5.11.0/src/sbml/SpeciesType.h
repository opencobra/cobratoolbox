/**
 * @file    SpeciesType.h
 * @brief   Definitions of SpeciesType and ListOfSpeciesType.
 * @author  Ben Bornstein
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
 * @class SpeciesType
 * @sbmlbrief{core} A <em>species type</em> in SBML Level 2.
 *
 * The term @em species @em type refers to reacting entities independent of
 * location.  These include simple ions (e.g., protons, calcium), simple
 * molecules (e.g., glucose, ATP), large molecules (e.g., RNA,
 * polysaccharides, and proteins), and others.
 * 
 * SBML Level&nbsp;2 Versions&nbsp;2&ndash;4 provide an explicit
 * SpeciesType class of object to enable Species objects of the same type
 * to be related together.  SpeciesType is a conceptual construct; the
 * existence of SpeciesType objects in a model has no effect on the model's
 * numerical interpretation.  Except for the requirement for uniqueness of
 * species/species type combinations located in compartments, simulators
 * and other numerical analysis software may ignore SpeciesType definitions
 * and references to them in a model.
 * 
 * There is no mechanism in SBML Level 2 for representing hierarchies of
 * species types.  One SpeciesType object cannot be the subtype of another
 * SpeciesType object; SBML provides no means of defining such
 * relationships.
 * 
 * As with other major structures in SBML, SpeciesType has a mandatory
 * attribute, "id", used to give the species type an identifier.  The
 * identifier must be a text string conforming to the identifer syntax
 * permitted in SBML.  SpeciesType also has an optional "name" attribute,
 * of type @c string.  The "id" and "name" must be used according to the
 * guidelines described in the SBML specification (e.g., Section 3.3 in
 * the Level&nbsp;2 Version&nbsp;4 specification).
 *
 * SpeciesType was introduced in SBML Level 2 Version 2.  It is not
 * available in SBML Level&nbsp;1 nor in Level&nbsp;3.
 *
 * @see Species
 * @see ListOfSpeciesTypes
 * @see CompartmentType
 * @see ListOfCompartmentTypes
 * 
 * <!---------------------------------------------------------------------- -->
 * @class ListOfSpeciesTypes
 * @sbmlbrief{core} A list of SpeciesType objects.
 *
 * @copydetails doc_what_is_listof
 */

#ifndef SpeciesType_h
#define SpeciesType_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBMLVisitor;


class LIBSBML_EXTERN SpeciesType : public SBase
{
public:

  /**
   * Creates a new SpeciesType using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this SpeciesType
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * SpeciesType
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  SpeciesType (unsigned int level, unsigned int version);


  /**
   * Creates a new SpeciesType using the given SBMLNamespaces object
   * @p sbmlns.
   *
   * @copydetails doc_what_are_sbmlnamespaces 
   *
   * It is worth emphasizing that although this constructor does not take
   * an identifier argument, in SBML Level&nbsp;2 and beyond, the "id"
   * (identifier) attribute of a SpeciesType object is required to have a value.
   * Thus, callers are cautioned to assign a value after calling this
   * constructor.  Setting the identifier can be accomplished using the
   * method SBase::setId(@if java String@endif).
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
  SpeciesType (SBMLNamespaces* sbmlns);



  /**
   * Destroys this SpeciesType.
   */
  virtual ~SpeciesType ();


  /**
   * Copy constructor; creates a copy of this SpeciesType.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  SpeciesType(const SpeciesType& orig);


  /**
   * Assignment operator for SpeciesType.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  SpeciesType& operator=(const SpeciesType& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of SpeciesType.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next SpeciesType in
   * the list of compartment types.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this SpeciesType object.
   *
   * @return the (deep) copy of this SpeciesType object.
   */
  virtual SpeciesType* clone () const;


  /**
   * Returns the value of the "id" attribute of this SpeciesType.
   * 
   * @return the id of this SpeciesType.
   */
  virtual const std::string& getId () const;


  /**
   * Returns the value of the "name" attribute of this SpeciesType.
   * 
   * @return the name of this SpeciesType.
   */
  virtual const std::string& getName () const;


  /**
   * Predicate returning @c true if this
   * SpeciesType's "id" attribute is set.
   *
   * @return @c true if the "id" attribute of this SpeciesType is
   * set, @c false otherwise.
   */
  virtual bool isSetId () const;


  /**
   * Predicate returning @c true if this
   * SpeciesType's "name" attribute is set.
   *
   * @return @c true if the "name" attribute of this SpeciesType is
   * set, @c false otherwise.
   */
  virtual bool isSetName () const;


  /**
   * Sets the value of the "id" attribute of this SpeciesType.
   *
   * The string @p sid is copied.
   *
   * @copydetails doc_id_syntax
   *
   * @param sid the string to use as the identifier of this SpeciesType
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  virtual int setId (const std::string& sid);


  /**
   * Sets the value of the "name" attribute of this SpeciesType.
   *
   * The string in @p name is copied.
   *
   * @param name the new name for the SpeciesType
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  virtual int setName (const std::string& name);


  /**
   * Unsets the value of the "name" attribute of this SpeciesType.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  virtual int unsetName ();


  /**
   * Returns the libSBML type code for this SBML object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_SPECIES_TYPE, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for
   * SpeciesType, is always @c "compartmentType".
   * 
   * @return the name of this element, i.e., @c "compartmentType".
   */
  virtual const std::string& getElementName () const;


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses should override this method to write out their contained
   * SBML objects as XML elements.  Be sure to call your parents
   * implementation of this method as well.
   */
  virtual void writeElements (XMLOutputStream& stream) const;
  /** @endcond */


  /**
   * Predicate returning @c true if
   * all the required attributes for this SpeciesType object
   * have been set.
   *
   * The required attributes for a SpeciesType object are:
   * @li "id"
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const ;


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
   *
   * @param attributes the XMLAttributes to use.
   */
  virtual void readAttributes (const XMLAttributes& attributes,
                               const ExpectedAttributes& expectedAttributes);

  void readL2Attributes (const XMLAttributes& attributes);
  

  /**
   * Subclasses should override this method to write their XML attributes
   * to the XMLOutputStream.  Be sure to call your parents implementation
   * of this method as well.
   *
   * @param stream the XMLOutputStream to use.
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;

  std::string  mId;
  std::string  mName;

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



class LIBSBML_EXTERN ListOfSpeciesTypes : public ListOf
{
public:

  /**
   * Creates a new ListOfSpeciesTypes object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   * 
   * @param version the Version within the SBML Level
   */
  ListOfSpeciesTypes (unsigned int level, unsigned int version);
          

  /**
   * Creates a new ListOfSpeciesTypes object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfSpeciesTypes object to be created.
   */
  ListOfSpeciesTypes (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfSpeciesTypes object.
   *
   * @return the (deep) copy of this ListOfSpeciesTypes object.
   */
  virtual ListOfSpeciesTypes* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., SpeciesType objects, if the list is non-empty).
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_SPECIES_TYPE, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfSpeciesTypes, the XML element name is @c
   * "listOfSpeciesTypes".
   * 
   * @return the name of this element, i.e., @c "listOfSpeciesTypes".
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a SpeciesType from the ListOfSpeciesTypes.
   *
   * @param n the index number of the SpeciesType to get.
   * 
   * @return the nth SpeciesType in this ListOfSpeciesTypes.
   *
   * @see size()
   */
  virtual SpeciesType * get(unsigned int n); 


  /**
   * Get a SpeciesType from the ListOfSpeciesTypes.
   *
   * @param n the index number of the SpeciesType to get.
   * 
   * @return the nth SpeciesType in this ListOfSpeciesTypes.
   *
   * @see size()
   */
  virtual const SpeciesType * get(unsigned int n) const; 

  /**
   * Get a SpeciesType from the ListOfSpeciesTypes
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the SpeciesType to get.
   * 
   * @return SpeciesType in this ListOfSpeciesTypes
   * with the given @p sid or @c NULL if no such
   * SpeciesType exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual SpeciesType* get (const std::string& sid);


  /**
   * Get a SpeciesType from the ListOfSpeciesTypes
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the SpeciesType to get.
   * 
   * @return SpeciesType in this ListOfSpeciesTypes
   * with the given @p sid or @c NULL if no such
   * SpeciesType exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const SpeciesType* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfSpeciesTypes items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual SpeciesType* remove (unsigned int n);


  /**
   * Removes item in this ListOfSpeciesTypes items with the given identifier.
   *
   * The caller owns the returned item and is responsible for deleting it.
   * If none of the items in this list have the identifier @p sid, then @c
   * NULL is returned.
   *
   * @param sid the identifier of the item to remove
   *
   * @return the item removed.  As mentioned above, the caller owns the
   * returned item.
   */
  virtual SpeciesType* remove (const std::string& sid);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Get the ordinal position of this element in the containing object
   * (which in this case is the Model object).
   *
   * The ordering of elements in the XML form of SBML is generally fixed
   * for most components in SBML.  For example, the
   * ListOfSpeciesTypes in a model (in SBML Level 2 Version 4) is the
   * third ListOf___.  (However, it differs for different Levels and
   * Versions of SBML, so calling code should not hardwire this number.)
   *
   * @return the ordinal position of the element with respect to its
   * siblings, or @c -1 (default) to indicate the position is not significant.
   */
  virtual int getElementPosition () const;

  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Create a ListOfSpeciesTypes object corresponding to the next token
   * in the XML input stream.
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
 * Creates a new SpeciesType_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * SpeciesType_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * SpeciesType_t
 *
 * @return a pointer to the newly created SpeciesType_t structure.
 *
 * @note Once a SpeciesType_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the SpeciesType_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof SpeciesType_t
 */
LIBSBML_EXTERN
SpeciesType_t *
SpeciesType_create (unsigned int level, unsigned int version);


/**
 * Creates a new SpeciesType_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this SpeciesType_t
 *
 * @return a pointer to the newly created SpeciesType_t structure.
 *
 * @note Once a SpeciesType_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the SpeciesType_t. Despite this, the ability to supply the values at creation 
 * time is an important aid to creating valid SBML.  Knowledge of the intended 
 * SBML Level and Version determine whether it is valid to assign a particular 
 * value to an attribute, or whether it is valid to add a structure to an existing
 * SBMLDocument_t.
 *
 * @memberof SpeciesType_t
 */
LIBSBML_EXTERN
SpeciesType_t *
SpeciesType_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given SpeciesType_t structure.
 *
 * @param st the SpeciesType_t structure to be freed.
 *
 * @memberof SpeciesType_t
 */
LIBSBML_EXTERN
void
SpeciesType_free (SpeciesType_t *st);


/**
 * Creates a deep copy of the given SpeciesType_t structure
 * 
 * @param st the SpeciesType_t structure to be copied
 * 
 * @return a (deep) copy of this SpeciesType_t structure.
 *
 * @memberof SpeciesType_t
 */
LIBSBML_EXTERN
SpeciesType_t *
SpeciesType_clone (const SpeciesType_t *st);


/**
 * Returns a list of XMLNamespaces_t associated with this SpeciesType_t
 * structure.
 *
 * @param st the SpeciesType_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof SpeciesType_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
SpeciesType_getNamespaces(SpeciesType_t *st);


/**
 * Takes a SpeciesType_t structure and returns its identifier.
 *
 * @param st the SpeciesType_t structure whose identifier is sought
 * 
 * @return the identifier of this SpeciesType_t, as a pointer to a string.
 *
 * @memberof SpeciesType_t
 */
LIBSBML_EXTERN
const char *
SpeciesType_getId (const SpeciesType_t *st);


/**
 * Takes a SpeciesType_t structure and returns its name.
 *
 * @param st the SpeciesType_t whose name is sought.
 *
 * @return the name of this SpeciesType_t, as a pointer to a string.
 *
 * @memberof SpeciesType_t
 */
LIBSBML_EXTERN
const char *
SpeciesType_getName (const SpeciesType_t *st);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * SpeciesType_t structure's identifier is set.
 *
 * @param st the SpeciesType_t structure to query
 * 
 * @return @c non-zero (true) if the "id" field of the given
 * SpeciesType_t is set, zero (false) otherwise.
 *
 * @memberof SpeciesType_t
 */
LIBSBML_EXTERN
int
SpeciesType_isSetId (const SpeciesType_t *st);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * SpeciesType_t structure's name is set.
 *
 * @param st the SpeciesType_t structure to query
 * 
 * @return @c non-zero (true) if the "name" field of the given
 * SpeciesType_t is set, zero (false) otherwise.
 *
 * @memberof SpeciesType_t
 */
LIBSBML_EXTERN
int
SpeciesType_isSetName (const SpeciesType_t *st);


/**
 * Assigns the identifier of a SpeciesType_t structure.
 *
 * This makes a copy of the string passed as the argument @p sid.
 *
 * @param st the SpeciesType_t structure to set.
 * @param sid the string to use as the identifier.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "id" attribute.
 *
 * @memberof SpeciesType_t
 */
LIBSBML_EXTERN
int
SpeciesType_setId (SpeciesType_t *st, const char *sid);


/**
 * Assign the name of a SpeciesType_t structure.
 *
 * This makes a copy of the string passed as the argument @p name.
 *
 * @param st the SpeciesType_t structure to set.
 * @param name the string to use as the name.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with the name set to NULL is equivalent to
 * unsetting the "name" attribute.
 *
 * @memberof SpeciesType_t
 */
LIBSBML_EXTERN
int
SpeciesType_setName (SpeciesType_t *st, const char *name);


/**
 * Unsets the name of a SpeciesType_t.
 * 
 * @param st the SpeciesType_t structure whose name is to be unset.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof SpeciesType_t
 */
LIBSBML_EXTERN
int
SpeciesType_unsetName (SpeciesType_t *st);


/**
 * Returns the SpeciesType_t structure having a given identifier.
 *
 * @param lo the ListOfSpeciesTypes_t structure to search.
 * @param sid the "id" attribute value being sought.
 *
 * @return item in the @p lo ListOfSpeciesTypes with the given @p sid or a
 * null pointer if no such item exists.
 *
 * @see ListOf_t
 *
 * @memberof ListOfSpeciesTypes_t
 */
LIBSBML_EXTERN
SpeciesType_t *
ListOfSpeciesTypes_getById (ListOf_t *lo, const char *sid);


/**
 * Removes a SpeciesType_t structure based on its identifier.
 *
 * The caller owns the returned item and is responsible for deleting it.
 *
 * @param lo the list of SpeciesType_t structures to search.
 * @param sid the "id" attribute value of the structure to remove
 *
 * @return The SpeciesType_t structure removed, or a null pointer if no such
 * item exists in @p lo.
 *
 * @see ListOf_t
 *
 * @memberof ListOfSpeciesTypes_t
 */
LIBSBML_EXTERN
SpeciesType_t *
ListOfSpeciesTypes_removeById (ListOf_t *lo, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* SpeciesType_h */

