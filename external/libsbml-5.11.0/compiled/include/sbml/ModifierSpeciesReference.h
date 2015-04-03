/**
 * @file    ModifierSpeciesReference.h
 * @brief   Definitions of ModifierSpeciesReference. 
 * @author  Ben Bornstein
 *
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
 * @class ModifierSpeciesReference
 * @sbmlbrief{core} A reference to an SBML <em>modifier species</em>.
 *
 * Sometimes a species appears in the kinetic rate formula of a reaction
 * but is itself neither created nor destroyed in that reaction (for
 * example, because it acts as a catalyst or inhibitor).  In SBML, all such
 * species are simply called @em modifiers without regard to the detailed
 * role of those species in the model.  The Reaction structure provides a
 * way to express which species act as modifiers in a given reaction.  This
 * is the purpose of the list of modifiers available in Reaction.  The list
 * contains instances of ModifierSpeciesReference structures.
 *
 * The ModifierSpeciesReference structure inherits the mandatory attribute
 * "species" and optional attributes "id" and "name" from the parent class
 * SimpleSpeciesReference.  See the description of SimpleSpeciesReference
 * for more information about these.
 *
 * The value of the "species" attribute must be the identifier of a species
 * defined in the enclosing Model; this species is designated as a modifier
 * for the current reaction.  A reaction may have any number of modifiers.
 * It is permissible for a modifier species to appear simultaneously in the
 * list of reactants and products of the same reaction where it is
 * designated as a modifier, as well as to appear in the list of reactants,
 * products and modifiers of other reactions in the model.
 *
 */

#ifndef ModifierSpeciesReference_h
#define ModifierSpeciesReference_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/SimpleSpeciesReference.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/ListOf.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBMLNamespaces;

class LIBSBML_EXTERN ModifierSpeciesReference : public SimpleSpeciesReference
{
public:

  /**
   * Creates a new ModifierSpeciesReference using the given SBML @p level and
   * @p version values.
   *
   * @param level an unsigned int, the SBML Level to assign to this
   * ModifierSpeciesReference
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * ModifierSpeciesReference
   *
   * @copydetails doc_note_setting_lv
   */
  ModifierSpeciesReference (unsigned int level, unsigned int version);


  /**
   * Creates a new ModifierSpeciesReference using the given SBMLNamespaces
   * object @p sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object.
   *
   * @copydetails doc_note_setting_lv
   */
  ModifierSpeciesReference (SBMLNamespaces* sbmlns);


  /**
   * Destroys this ModifierSpeciesReference.
   */
  virtual ~ModifierSpeciesReference();


  /**
   * Accepts the given SBMLVisitor.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this ModifierSpeciesReference object.
   *
   * @return the (deep) copy of this ModifierSpeciesReference object.
   */
  virtual ModifierSpeciesReference* clone () const;


  /**
   * Returns the libSBML type code for this %SBML object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_MODIFIER_SPECIES_REFERENCE, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for Species, is
   * always @c "modifierSpeciesReference".
   * 
   * @return the name of this element, i.e., @c "modifierSpeciesReference".
   */
  virtual const std::string& getElementName () const;


  /**
   * Predicate returning @c true if
   * all the required attributes for this ModifierSpeciesReference object
   * have been set.
   *
   * The required attributes for a ModifierSpeciesReference object are:
   * species
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const ;


protected:
  /** @cond doxygenLibsbmlInternal */

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


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new ModifierSpeciesReference_t structure using the given SBML @p level and
 * @p version values.
 *
 * @param level an unsigned int, the SBML level to assign to this
 * ModifierSpeciesReference_t structure.
 *
 * @param version an unsigned int, the SBML version to assign to this
 * ModifierSpeciesReference_t structure.
 *
 * @returns the newly-created ModifierSpeciesReference_t structure, or a null pointer if
 * an error occurred during construction.
 *
 * @copydetails doc_note_setting_lv
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
ModifierSpeciesReference_t *
ModifierSpeciesReference_create(unsigned int level, unsigned int version);


/**
 * Creates a new ModifierSpeciesReference_t structure using the given SBMLNamespaces_t
 * structure, @p sbmlns.
 *
 * @copydetails doc_what_are_sbmlnamespaces
 *
 * @param sbmlns an SBMLNamespaces_t structure.
 *
 * @returns the newly-created ModifierSpeciesReference_t structure, or a null pointer if
 * an error occurred during construction.
 *
 * @copydetails doc_note_setting_lv
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
ModifierSpeciesReference_t *
ModifierSpeciesReference_createWithNS(SBMLNamespaces_t* sbmlns);


/**
 * Frees the given ModifierSpeciesReference_t structure.
 * 
 * @param msr the ModifierSpeciesReference_t structure to be freed.
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
void
ModifierSpeciesReference_free(ModifierSpeciesReference_t * msr);


/**
 * Creates a deep copy of the given ModifierSpeciesReference_t structure.
 * 
 * @param msr the ModifierSpeciesReference_t structure to be copied.
 *
 * @returns a (deep) copy of the given ModifierSpeciesReference_t structure, or a null
 * pointer if a failure occurred.
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
ModifierSpeciesReference_t *
ModifierSpeciesReference_clone(ModifierSpeciesReference_t * msr);


/**
 * Returns the value of the "id" attribute of the given ModifierSpeciesReference_t
 * structure.
 *
 * @param msr the ModifierSpeciesReference_t structure.
 *
 * @return the id of this structure.
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
const char *
ModifierSpeciesReference_getId(const ModifierSpeciesReference_t * msr);


/**
 * Returns the value of the "name" attribute of the given ModifierSpeciesReference_t
 * structure.
 *
 * @param msr the ModifierSpeciesReference_t structure.
 *
 * @return the name of this structure.
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
const char *
ModifierSpeciesReference_getName(const ModifierSpeciesReference_t * msr);


/**
 * Returns the value of the "species" attribute of the given ModifierSpeciesReference_t
 * structure.
 *
 * @param msr the ModifierSpeciesReference_t structure.
 *
 * @return the species of this structure.
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
const char *
ModifierSpeciesReference_getSpecies(const ModifierSpeciesReference_t * msr);


/**
 * Predicate returning @c 1 if the given ModifierSpeciesReference_t structure's "id"
 * is set.
 *
 * @param msr the ModifierSpeciesReference_t structure.
 *
 * @return @c 1 if the "id" of this ModifierSpeciesReference_t structure is
 * set, @c 0 otherwise.
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
int
ModifierSpeciesReference_isSetId(const ModifierSpeciesReference_t * msr);


/**
 * Predicate returning @c 1 if the given ModifierSpeciesReference_t structure's "name"
 * is set.
 *
 * @param msr the ModifierSpeciesReference_t structure.
 *
 * @return @c 1 if the "name" of this ModifierSpeciesReference_t structure is
 * set, @c 0 otherwise.
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
int
ModifierSpeciesReference_isSetName(const ModifierSpeciesReference_t * msr);


/**
 * Predicate returning @c 1 if the given ModifierSpeciesReference_t structure's "species"
 * is set.
 *
 * @param msr the ModifierSpeciesReference_t structure.
 *
 * @return @c 1 if the "species" of this ModifierSpeciesReference_t structure is
 * set, @c 0 otherwise.
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
int
ModifierSpeciesReference_isSetSpecies(const ModifierSpeciesReference_t * msr);


/**
 * Sets the "id" attribute of the given ModifierSpeciesReference_t structure.
 *
 * This function copies the string given in @p string.  If the string is
 * a null pointer, this function performs ModifierSpeciesReference_unsetId() instead.
 *
 * @param msr the ModifierSpeciesReference_t structure.
 *
 * @param id the string to which the structures "id" attribute should be
 * set.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note Using this function with a null pointer for @p name is equivalent to
 * unsetting the value of the "name" attribute.
 * 
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
int
ModifierSpeciesReference_setId(ModifierSpeciesReference_t * msr, const char * id);


/**
 * Sets the "name" attribute of the given ModifierSpeciesReference_t structure.
 *
 * This function copies the string given in @p string.  If the string is
 * a null pointer, this function performs ModifierSpeciesReference_unsetName() instead.
 *
 * @param msr the ModifierSpeciesReference_t structure.
 *
 * @param name the string to which the structures "name" attribute should be
 * set.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note Using this function with a null pointer for @p name is equivalent to
 * unsetting the value of the "name" attribute.
 * 
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
int
ModifierSpeciesReference_setName(ModifierSpeciesReference_t * msr, const char * name);


/**
 * Sets the "species" attribute of the given ModifierSpeciesReference_t structure.
 *
 * This function copies the string given in @p string.  If the string is
 * a null pointer, this function performs ModifierSpeciesReference_unsetSpecies() instead.
 *
 * @param msr the ModifierSpeciesReference_t structure.
 *
 * @param species the string to which the structures "species" attribute should be
 * set.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note Using this function with a null pointer for @p name is equivalent to
 * unsetting the value of the "name" attribute.
 * 
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
int
ModifierSpeciesReference_setSpecies(ModifierSpeciesReference_t * msr, const char * species);


/**
 * Unsets the value of the "id" attribute of the given 
 *ModifierSpeciesReference_t structure.
 *
 * @param msr the ModifierSpeciesReference_t structure.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
int
ModifierSpeciesReference_unsetId(ModifierSpeciesReference_t * msr);


/**
 * Unsets the value of the "name" attribute of the given 
 *ModifierSpeciesReference_t structure.
 *
 * @param msr the ModifierSpeciesReference_t structure.
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
int
ModifierSpeciesReference_unsetName(ModifierSpeciesReference_t * msr);


/**
 * Predicate returning @c 1 or *c 0 depending on whether all the required
 * attributes of the given ModifierSpeciesReference_t structure have been set.
 *
 * @param msr the ModifierSpeciesReference_t structure to check.
 *
 * @return @c 1 if all the required attributes for this
 * structure have been defined, @c 0 otherwise.
 *
 * @memberof ModifierSpeciesReference_t
 */
LIBSBML_EXTERN
int
ModifierSpeciesReference_hasRequiredAttributes(const ModifierSpeciesReference_t * msr);




END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* ModifierSpeciesReference_h */
