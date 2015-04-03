/**
 * @file    CompartmentType.h
 * @brief   Definitions of CompartmentType and ListOfCompartmentTypes.
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
 * @class CompartmentType
 * @sbmlbrief{core} A <em>compartment type</em> in SBML Level&nbsp;2.
 *
 * SBML Level&nbsp;2 Versions&nbsp;2&ndash;4 provide the <em>compartment
 * type</em> as a grouping construct that can be used to establish a
 * relationship between multiple Compartment objects.  A CompartmentType
 * object only has an identity, and this identity can only be used to
 * indicate that particular Compartment objects in the model belong to this
 * type.  This may be useful for conveying a modeling intention, such as
 * when a model contains many similar compartments, either by their
 * biological function or the reactions they carry.  Without a compartment
 * type construct, it would be impossible within SBML itself to indicate
 * that all of the compartments share an underlying conceptual relationship
 * because each SBML compartment must be given a unique and separate
 * identity.  Compartment types have no mathematical meaning in
 * SBML---they have no effect on a model's mathematical interpretation.
 * Simulators and other numerical analysis software may ignore
 * CompartmentType definitions and references to them in a model.
 * 
 * There is no mechanism in SBML Level 2 for representing hierarchies of
 * compartment types.  One CompartmentType instance cannot be the subtype
 * of another CompartmentType instance; SBML provides no means of defining
 * such relationships.
 * 
 * As with other major structures in SBML, CompartmentType has a mandatory
 * attribute, "id", used to give the compartment type an identifier.  The
 * identifier must be a text %string conforming to the identifer syntax
 * permitted in SBML.  CompartmentType also has an optional "name"
 * attribute, of type @c string.  The "id" and "name" must be used
 * according to the guidelines described in the SBML specification (e.g.,
 * Section 3.3 in the Level 2 Version 4 specification).
 *
 * CompartmentType was introduced in SBML Level 2 Version 2.  It is not
 * available in SBML Level&nbsp;1 nor in Level&nbsp;3.
 *
 * @see Compartment
 * @see ListOfCompartmentTypes
 * @see SpeciesType
 * @see ListOfSpeciesTypes
 *
 * 
 * <!-- ------------------------------------------------------------------- -->
 * @class ListOfCompartmentTypes
 * @sbmlbrief{core} A list of CompartmentType objects.
 * 
 * @copydetails doc_what_is_listof
 */

#ifndef CompartmentType_h
#define CompartmentType_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>


#ifdef __cplusplus


#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBMLVisitor;


class LIBSBML_EXTERN CompartmentType : public SBase
{
public:

  /**
   * Creates a new CompartmentType object using the given SBML @p level and
   * @p version values.
   *
   * @param level an unsigned int, the SBML Level to assign to this
   * CompartmentType
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * CompartmentType
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  CompartmentType (unsigned int level, unsigned int version);


  /**
   * Creates a new CompartmentType object using the given SBMLNamespaces
   * object @p sbmlns.
   *
   * @copydetails doc_what_are_sbmlnamespaces
   *
   * It is worth emphasizing that although this constructor does not take an
   * identifier argument, in SBML Level&nbsp;2 and beyond, the "id"
   * (identifier) attribute of a CompartmentType object is required to have a
   * value.  Thus, callers are cautioned to assign a value after calling this
   * constructor.  Setting the identifier can be accomplished using the
   * method setId(@if java String@endif).
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
  CompartmentType (SBMLNamespaces* sbmlns);


  /**
   * Destroys this CompartmentType object.
   */
  virtual ~CompartmentType ();


  /**
   * Copy constructor; creates a copy of this CompartmentType object.
   *
   * @param orig the object to copy.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  CompartmentType(const CompartmentType& orig);


  /**
   * Assignment operator for CompartmentType.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  CompartmentType& operator=(const CompartmentType& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of CompartmentType.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next CompartmentType object in
   * the list of compartment types.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this CompartmentType object.
   *
   * @return the (deep) copy of this CompartmentType object.
   */
  virtual CompartmentType* clone () const;


  /**
   * Returns the value of the "id" attribute of this CompartmentType object.
   *
   * @return the identifier of this CompartmentType object.
   *
   * @see getName()
   * @see setId(@if java String@endif)
   * @see unsetId()
   * @see isSetId()
   */
  virtual const std::string& getId () const;


  /**
   * Returns the value of the "name" attribute of this CompartmentType
   * object.
   *
   * @return the name of this CompartmentType object.
   *
   * @see getId()
   * @see isSetName()
   * @see setName(@if java String@endif)
   * @see unsetName()
   */
  virtual const std::string& getName () const;


  /**
   * Predicate returning @c true if this CompartmentType object's "id"
   * attribute is set.
   *
   * @return @c true if the "id" attribute of this CompartmentType object is
   * set, @c false otherwise.
   *
   * @see getId()
   * @see unsetId()
   * @see setId(@if java String@endif)
   */
  virtual bool isSetId () const;


  /**
   * Predicate returning @c true if this CompartmentType object's "name"
   * attribute is set.
   *
   * @return @c true if the "name" attribute of this CompartmentType object
   * is set, @c false otherwise.
   *
   * @see getName()
   * @see setName(@if java String@endif)
   * @see unsetName()
   */
  virtual bool isSetName () const;


  /**
   * Sets the value of the "id" attribute of this CompartmentType object.
   *
   * The string @p sid is copied.
   *
   * @copydetails doc_id_syntax
   *
   * @param sid the string to use as the identifier of this CompartmentType
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @see getId()
   * @see unsetId()
   * @see isSetId()
   */
  virtual int setId (const std::string& sid);


  /**
   * Sets the value of the "name" attribute of this CompartmentType object.
   *
   * The string in @p name is copied.
   *
   * @param name the new name for the CompartmentType
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @see getName()
   * @see isSetName()
   * @see unsetName()
   */
  virtual int setName (const std::string& name);


  /**
   * Unsets the value of the "name" attribute of this CompartmentType object.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see getName()
   * @see setName(@if java String@endif)
   * @see isSetName()
   */
  virtual int unsetName ();


  /**
   * Returns the libSBML type code for this SBML object.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_COMPARTMENT_TYPE, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object
   *
   * For CompartmentType, the element name is always @c "compartmentType".
   *
   * @return the name of this element.
   *
   * @see getTypeCode()
   * @see getPackageName()
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
   * Predicate returning @c true if all the required attributes for this
   * CompartmentType object have been set.
   *
   * The required attributes for a CompartmentType object are:
   * @li "id"
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const;


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

  std::string mId;
  std::string mName;

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



class LIBSBML_EXTERN ListOfCompartmentTypes : public ListOf
{
public:

  /**
   * Creates a new ListOfCompartmentTypes object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   *
   * @param version the Version within the SBML Level
   */
  ListOfCompartmentTypes (unsigned int level, unsigned int version);


  /**
   * Creates a new ListOfCompartmentTypes object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfCompartmentTypes object to be created.
   */
  ListOfCompartmentTypes (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfCompartmentTypes object.
   *
   * @return the (deep) copy of this ListOfCompartmentTypes object.
   */
  virtual ListOfCompartmentTypes* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., CompartmentType objects, if the list is non-empty).
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for the objects contained in this ListOf
   * instance: @sbmlconstant{SBML_COMPARTMENT_TYPE, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfCompartmentTypes, the XML element name is @c
   * "listOfCompartmentTypes".
   *
   * @return the name of this element, i.e., @c "listOfCompartmentTypes".
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a CompartmentType object from the ListOfCompartmentTypes.
   *
   * @param n the index number of the CompartmentType object to get.
   *
   * @return the nth CompartmentType object in this ListOfCompartmentTypes.
   *
   * @see size()
   */
  virtual CompartmentType * get(unsigned int n);


  /**
   * Get a CompartmentType object from the ListOfCompartmentTypes.
   *
   * @param n the index number of the CompartmentType object to get.
   *
   * @return the nth CompartmentType object in this ListOfCompartmentTypes.
   *
   * @see size()
   */
  virtual const CompartmentType * get(unsigned int n) const;


  /**
   * Get a CompartmentType object from the ListOfCompartmentTypes
   * based on its identifier.
   *
   * @param sid a string representing the identifier
   * of the CompartmentType object to get.
   *
   * @return CompartmentType object in this ListOfCompartmentTypes
   * with the given @p sid or @c NULL if no such
   * CompartmentType object exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual CompartmentType* get (const std::string& sid);


  /**
   * Get a CompartmentType object from the ListOfCompartmentTypes
   * based on its identifier.
   *
   * @param sid a string representing the identifier
   * of the CompartmentType object to get.
   *
   * @return CompartmentType object in this ListOfCompartmentTypes
   * with the given @p sid or @c NULL if no such
   * CompartmentType object exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const CompartmentType* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfCompartmentTypes items
   * and returns a pointer to it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual CompartmentType* remove (unsigned int n);


  /**
   * Removes item in this ListOfCompartmentTypes items with the given identifier.
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
  virtual CompartmentType* remove (const std::string& sid);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Get the ordinal position of this element in the containing object
   * (which in this case is the Model object).
   *
   * The ordering of elements in the XML form of SBML is generally fixed
   * for most components in SBML.  For example, the
   * ListOfCompartmentTypes in a model (in SBML Level 2 Version 4) is the
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
   * Create a ListOfCompartmentTypes object corresponding to the next token
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
 * Creates a new CompartmentType_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 
* CompartmentType_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * CompartmentType_t
 *
 * @return a pointer to the newly created CompartmentType_t structure.
 *
 * @note Once a CompartmentType_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the CompartmentType_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof CompartmentType_t
 */
LIBSBML_EXTERN
CompartmentType_t *
CompartmentType_create (unsigned int level, unsigned int version);


/**
 * Creates a new CompartmentType_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this CompartmentType_t
 *
 * @return a pointer to the newly created CompartmentType_t structure.
 *
 * @note Once a CompartmentType_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the CompartmentType_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of the
 * intended SBML Level and Version determine whether it is valid to assign a
 * particular value to an attribute, or whether it is valid to add a structure
 * to an existing SBMLDocument_t.
 *
 * @memberof CompartmentType_t
 */
LIBSBML_EXTERN
CompartmentType_t *
CompartmentType_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given CompartmentType_t structure.
 *
 * @param ct the CompartmentType_t structure to be freed.
 *
 * @memberof CompartmentType_t
 */
LIBSBML_EXTERN
void
CompartmentType_free (CompartmentType_t *ct);


/**
 * Creates a deep copy of the given CompartmentType_t structure
 *
 * @param ct the CompartmentType_t structure to be copied
 *
 * @return a (deep) copy of this CompartmentType_t structure.
 *
 * @memberof CompartmentType_t
 */
LIBSBML_EXTERN
CompartmentType_t *
CompartmentType_clone (const CompartmentType_t *ct);


/**
 * Returns a list of XMLNamespaces_t associated with this CompartmentType_t
 * structure.
 *
 * @param ct the CompartmentType_t structure
 *
 * @return pointer to the XMLNamespaces_t structure associated with
 * this structure
 *
 * @memberof CompartmentType_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
CompartmentType_getNamespaces(CompartmentType_t *ct);


/**
 * Takes a CompartmentType_t structure and returns its identifier.
 *
 * @param ct the CompartmentType_t structure whose identifier is sought
 *
 * @return the identifier of this CompartmentType_t, as a pointer to a string.
 *
 * @memberof CompartmentType_t
 */
LIBSBML_EXTERN
const char *
CompartmentType_getId (const CompartmentType_t *ct);


/**
 * Takes a CompartmentType_t structure and returns its name.
 *
 * @param ct the CompartmentType_t whose name is sought.
 *
 * @return the name of this CompartmentType_t, as a pointer to a string.
 *
 * @memberof CompartmentType_t
 */
LIBSBML_EXTERN
const char *
CompartmentType_getName (const CompartmentType_t *ct);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * CompartmentType_t structure's identifier is set.
 *
 * @param ct the CompartmentType_t structure to query
 *
 * @return @c non-zero (true) if the "id" field of the given
 * CompartmentType_t is set, zero (false) otherwise.
 *
 * @memberof CompartmentType_t
 */
LIBSBML_EXTERN
int
CompartmentType_isSetId (const CompartmentType_t *ct);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * CompartmentType_t structure's name is set.
 *
 * @param ct the CompartmentType_t structure to query
 *
 * @return @c non-zero (true) if the "name" field of the given
 * CompartmentType_t is set, zero (false) otherwise.
 *
 * @memberof CompartmentType_t
 */
LIBSBML_EXTERN
int
CompartmentType_isSetName (const CompartmentType_t *ct);


/**
 * Assigns the identifier of a CompartmentType_t structure.
 *
 * This makes a copy of the string passed as the argument @p sid.
 *
 * @param ct the CompartmentType_t structure to set.
 * @param sid the string to use as the identifier.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "id" attribute.
 *
 * @memberof CompartmentType_t
 */
LIBSBML_EXTERN
int
CompartmentType_setId (CompartmentType_t *ct, const char *sid);


/**
 * Assign the name of a CompartmentType_t structure.
 *
 * This makes a copy of the string passed as the argument @p name.
 *
 * @param ct the CompartmentType_t structure to set.
 * @param name the string to use as the name.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with the name set to NULL is equivalent to
 * unsetting the "name" attribute.
 *
 * @memberof CompartmentType_t
 */
LIBSBML_EXTERN
int
CompartmentType_setName (CompartmentType_t *ct, const char *name);


/**
 * Unsets the name of a CompartmentType_t.
 *
 * @param ct the CompartmentType_t structure whose name is to be unset.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof CompartmentType_t
 */
LIBSBML_EXTERN
int
CompartmentType_unsetName (CompartmentType_t *ct);


/**
 * Returns the CompartmentType_t structure having a given identifier.
 *
 * @param lo the ListOfCompartmentTypes_t structure to search.
 * @param sid the "id" attribute value being sought.
 *
 * @return item in the @p lo ListOfCompartmentTypes with the given @p sid or a
 * null pointer if no such item exists.
 *
 * @see ListOf_t
 *
 * @memberof ListOfCompartmentTypes_t
 */
LIBSBML_EXTERN
CompartmentType_t *
ListOfCompartmentTypes_getById (ListOf_t *lo, const char *sid);


/**
 * Removes a CompartmentType_t structure based on its identifier.
 *
 * The caller owns the returned item and is responsible for deleting it.
 *
 * @param lo the list of CompartmentType_t structures to search.
 * @param sid the "id" attribute value of the structure to remove
 *
 * @return The CompartmentType_t structure removed, or a null pointer if no such
 * item exists in @p lo.
 *
 * @see ListOf_t
 *
 * @memberof ListOfCompartmentTypes_t
 */
LIBSBML_EXTERN
CompartmentType_t *
ListOfCompartmentTypes_removeById (ListOf_t *lo, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* CompartmentType_h */
