/**
 * @file    SimpleSpeciesReference.h
 * @brief   Definitions of SimpleSpeciesReference. 
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
 * @class SimpleSpeciesReference
 * @sbmlbrief{core} Abstract class for references to species in reactions.
 *
 * As mentioned in the description of Reaction, every species that enters
 * into a given reaction must appear in that reaction's lists of reactants,
 * products and/or modifiers.  In an SBML model, all species that may
 * participate in any reaction are listed in the "listOfSpecies" element of
 * the top-level Model object.  Lists of products, reactants and modifiers
 * in Reaction objects do not introduce new species, but rather, they refer
 * back to those listed in the model's top-level "listOfSpecies".  For
 * reactants and products, the connection is made using SpeciesReference
 * objects; for modifiers, it is made using ModifierSpeciesReference
 * objects.  SimpleSpeciesReference is an abstract type that serves as the
 * parent class of both SpeciesReference and ModifierSpeciesReference.  It
 * is used simply to hold the attributes and elements that are common to
 * the latter two structures.
 *
 * The SimpleSpeciesReference structure has a mandatory attribute,
 * "species", which must be a text string conforming to the identifer
 * syntax permitted in %SBML.  This attribute is inherited by the
 * SpeciesReference and ModifierSpeciesReference subclasses derived from
 * SimpleSpeciesReference.  The value of the "species" attribute must be
 * the identifier of a species defined in the enclosing Model.  The species
 * is thereby declared as participating in the reaction being defined.  The
 * precise role of that species as a reactant, product, or modifier in the
 * reaction is determined by the subclass of SimpleSpeciesReference (i.e.,
 * either SpeciesReference or ModifierSpeciesReference) in which the
 * identifier appears.
 * 
 * SimpleSpeciesReference also contains an optional attribute, "id",
 * allowing instances to be referenced from other structures.  No SBML
 * structures currently do this; however, such structures are anticipated
 * in future SBML Levels.
 *  
 */

#ifndef SimpleSpeciesReference_h
#define SimpleSpeciesReference_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus


#include <string>
#include <sbml/ExpectedAttributes.h>
#include <sbml/SBase.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/xml/XMLAttributes.h>

LIBSBML_CPP_NAMESPACE_BEGIN
  
class SBMLNamespaces;

class LIBSBML_EXTERN SimpleSpeciesReference : public SBase
{
public:

  /**
   * Creates a new SimpleSpeciesReference using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this SimpleSpeciesReference
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * SimpleSpeciesReference
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   */
  SimpleSpeciesReference (unsigned int level, unsigned int version);


  /**
   * Destroys this SimpleSpeciesReference.
   */
  virtual ~SimpleSpeciesReference ();


  /**
   * Copy constructor; creates a copy of this SimpleSpeciesReference.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  SimpleSpeciesReference(const SimpleSpeciesReference& orig);


  /**
   * Assignment operator. 
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  SimpleSpeciesReference& operator=(const SimpleSpeciesReference& rhs);


  /**
   * Accepts the given SBMLVisitor.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Returns the value of the "id" attribute of this SimpleSpeciesReference.
   * 
   * @return the id of this SimpleSpeciesReference.
   */
  virtual const std::string& getId () const;


  /**
   * Returns the value of the "name" attribute of this SimpleSpeciesReference.
   * 
   * @return the name of this SimpleSpeciesReference.
   */
  virtual const std::string& getName () const;


  /**
   * Get the value of the "species" attribute.
   * 
   * @return the value of the attribute "species" for this
   * SimpleSpeciesReference.
   */
  const std::string& getSpecies () const;


  /**
   * Predicate returning @c true if this
   * SimpleSpeciesReference's "id" attribute is set.
   *
   * @return @c true if the "id" attribute of this SimpleSpeciesReference is
   * set, @c false otherwise.
   */
  virtual bool isSetId () const;


  /**
   * Predicate returning @c true if this
   * SimpleSpeciesReference's "name" attribute is set.
   *
   * @return @c true if the "name" attribute of this SimpleSpeciesReference is
   * set, @c false otherwise.
   */
  virtual bool isSetName () const;


  /**
   * Predicate returning @c true if this
   * SimpleSpeciesReference's "species" attribute is set.
   * 
   * @return @c true if the "species" attribute of this
   * SimpleSpeciesReference is set, @c false otherwise.
   */
  bool isSetSpecies () const;


  /**
   * Sets the "species" attribute of this SimpleSpeciesReference.
   *
   * The identifier string passed in @p sid is copied.
   *
   * @param sid the identifier of a species defined in the enclosing
   * Model's ListOfSpecies.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setSpecies (const std::string& sid);


  /**
   * Sets the value of the "id" attribute of this SimpleSpeciesReference.
   *
   * The string @p sid is copied.
   *
   * @copydetails doc_id_syntax
   *
   * @param sid the string to use as the identifier of this SimpleSpeciesReference
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   */
  virtual int setId (const std::string& sid);


  /**
   * Sets the value of the "name" attribute of this SimpleSpeciesReference.
   *
   * The string in @p name is copied.
   *
   * @param name the new name for the SimpleSpeciesReference
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   */
  virtual int setName (const std::string& name);


  /**
   * Unsets the value of the "id" attribute of this SimpleSpeciesReference.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  virtual int unsetId ();


  /**
   * Unsets the value of the "name" attribute of this SimpleSpeciesReference.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  virtual int unsetName ();


  /**
   * Predicate returning @c true if this
   * is a ModifierSpeciesReference.
   * 
   * @return @c true if this SimpleSpeciesReference's subclass is
   * ModiferSpeciesReference, @c false if it is a plain SpeciesReference.
   */
  bool isModifier () const;


  /**
   * @copydoc doc_renamesidref_common
   */
  virtual void renameSIdRefs(const std::string& oldid, const std::string& newid);



protected:
  /** @cond doxygenLibsbmlInternal */

  virtual bool hasRequiredAttributes() const ;

  /**
   * Creates a new SimpleSpeciesReference using the given SBMLNamespaces object
   * @p sbmlns.
   *
   * @copydetails doc_what_are_sbmlnamespaces 
   *
   * @param sbmlns an SBMLNamespaces object.
   *
   * @note Upon the addition of a SimpleSpeciesReference object to an
   * SBMLDocument (e.g., using Model::addSimpleSpeciesReference()), the
   * SBML XML namespace of the document @em overrides the value used when
   * creating the SimpleSpeciesReference object via this constructor.  This
   * is necessary to ensure that an SBML document is a consistent
   * structure.  Nevertheless, the ability to supply the values at the time
   * of creation of a SimpleSpeciesReference is an important aid to
   * producing valid SBML.  Knowledge of the intented SBML Level and
   * Version determine whether it is valid to assign a particular value to
   * an attribute, or whether it is valid to add an object to an existing
   * SBMLDocument.
   */
  SimpleSpeciesReference (SBMLNamespaces* sbmlns);


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

  void readL1Attributes (const XMLAttributes& attributes);

  void readL2Attributes (const XMLAttributes& attributes);

  void readL3Attributes (const XMLAttributes& attributes);

  /**
   * Subclasses should override this method to write their XML attributes
   * to the XMLOutputStream.  Be sure to call your parents implementation
   * of this method as well.
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;

  std::string  mId;
  std::string  mName;
  std::string  mSpecies;

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
#endif  /* SimpleSpeciesReference_h */
