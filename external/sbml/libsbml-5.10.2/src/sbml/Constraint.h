/**
 * @file    Constraint.h
 * @brief   Definitions of Constraint and ListOfConstraints.
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
 * @class Constraint
 * @sbmlbrief{core} An SBML <em>constraint</em>, for stating validity assumptions.
 *
 * The Constraint object class was introduced in SBML Level&nbsp;2
 * Version&nbsp;2 as a mechanism for stating the assumptions under which a
 * model is designed to operate.  The <em>constraints</em> are statements
 * about permissible values of different quantities in a model.
 * Constraints are not used to compute dynamical values for simulation or
 * analysis, but rather, they serve an advisory role for
 * simulation/analysis tools.
 *
 * SBML's Constraint object class has one required attribute, "id", to
 * give the parameter a unique identifier by which other parts of an SBML
 * model definition can refer to it.  A Constraint object can also have an
 * optional "name" attribute of type @c string.  Identifiers and names must
 * be used according to the guidelines described in the SBML specification
 * (e.g., Section 3.3 in the Level&nbsp;2 Version 4 specification).  
 *
 * Constraint has one required subelement, "math", containing a MathML
 * formula defining the condition of the constraint.  This formula must
 * return a boolean value of @c true when the model is a <em>valid</em>
 * state.  The formula can be an arbitrary expression referencing the
 * variables and other entities in an SBML model.  The evaluation of "math"
 * and behavior of constraints are described in more detail below.
 *
 * A Constraint structure also has an optional subelement called "message".
 * This can contain a message in XHTML format that may be displayed to the
 * user when the condition of the formula in the "math" subelement
 * evaluates to a value of @c false.  Software tools are not required to
 * display the message, but it is recommended that they do so as a matter
 * of best practice.  The XHTML content within a "message" subelement must
 * follow the same restrictions as for the "notes" element on SBase
 * described in in the SBML Level&nbsp;2 specification; please consult the
 * <a target="_blank" href="http://sbml.org/Documents/Specifications">SBML
 * specification document</a> corresponding to the SBML Level and Version
 * of your model for more information about the requirements for "notes"
 * content.
 *
 * Constraint was introduced in SBML Level&nbsp;2 Version&nbsp;2.  It is
 * not available in earlier versions of Level&nbsp;2 nor in any version of
 * Level&nbsp;1.
 *
 * @section constraint-semantics Semantics of Constraints
 * 
 * In the context of a simulation, a Constraint has effect at all times
 * <em>t \f$\geq\f$ 0</em>.  Each Constraint's "math" subelement is first
 * evaluated after any InitialAssignment definitions in a model at <em>t =
 * 0</em> and can conceivably trigger at that point.  (In other words, a
 * simulation could fail a constraint immediately.)
 *
 * Constraint structures <em>cannot and should not</em> be used to compute
 * the dynamical behavior of a model as part of, for example, simulation.
 * Constraints may be used as input to non-dynamical analysis, for instance
 * by expressing flux constraints for flux balance analysis.
 *
 * The results of a simulation of a model containing a constraint are
 * invalid from any simulation time at and after a point when the function
 * given by the "math" subelement returns a value of @c false.  Invalid
 * simulation results do not make a prediction of the behavior of the
 * biochemical reaction network represented by the model.  The precise
 * behavior of simulation tools is left undefined with respect to
 * constraints.  If invalid results are detected with respect to a given
 * constraint, the "message" subelement may optionally be displayed to the
 * user.  The simulation tool may also halt the simulation or clearly
 * delimit in output data the simulation time point at which the simulation
 * results become invalid.
 *
 * SBML does not impose restrictions on duplicate Constraint definitions or
 * the order of evaluation of Constraint objects in a model.  It is
 * possible for a model to define multiple constraints all with the same
 * mathematical expression.  Since the failure of any constraint indicates
 * that the model simulation has entered an invalid state, a system is not
 * required to attempt to detect whether other constraints in the model
 * have failed once any one constraint has failed.
 *
 * <!---------------------------------------------------------------------- -->
 *
 * @class ListOfConstraints
 * @sbmlbrief{core} A list of Constraint objects.
 * 
 * @copydetails doc_what_is_listof
 */

#ifndef Constraint_h
#define Constraint_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTNode;
class XMLNode;
class SBMLVisitor;


class LIBSBML_EXTERN Constraint : public SBase
{
public:

  /**
   * Creates a new Constraint using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this Constraint
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * Constraint
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   * 
   * @copydetails doc_note_setting_lv
   */
  Constraint (unsigned int level, unsigned int version);


  /**
   * Creates a new Constraint using the given SBMLNamespaces object
   * @p sbmlns.
   *
   * @copydetails doc_what_are_sbmlnamespaces
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
  Constraint (SBMLNamespaces* sbmlns);


  /**
   * Destroys this Constraint.
   */
  virtual ~Constraint ();


  /**
   * Copy constructor; creates a copy of this Constraint.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  Constraint (const Constraint& orig);


  /**
   * Assignment operator for Constraint.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  Constraint& operator=(const Constraint& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of Constraint.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next Constraint in the
   * list of constraints within which this Constraint is embedded (i.e., in
   * the ListOfConstraints located in the enclosing Model instance).
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this Constraint object.
   *
   * @return the (deep) copy of this Constraint object.
   */
  virtual Constraint* clone () const;


  /**
   * Get the message, if any, associated with this Constraint
   * 
   * @return the message for this Constraint, as an XMLNode.
   */
  const XMLNode* getMessage () const;


  /**
   * Get the message string, if any, associated with this Constraint
   * 
   * @return the message for this Constraint, as a string.
   */
  std::string getMessageString () const;


  /**
   * Get the mathematical expression of this Constraint
   * 
   * @return the math for this Constraint, as an ASTNode.
   */
  const ASTNode* getMath () const;


  /**
   * Predicate returning @c true if a
   * message is defined for this Constraint.
   *
   * @return @c true if the message of this Constraint is set,
   * @c false otherwise.
   */
  bool isSetMessage () const;


  /**
   * Predicate returning @c true if a
   * mathematical formula is defined for this Constraint.
   *
   * @return @c true if the "math" subelement for this Constraint is
   * set, @c false otherwise.
   */
  bool isSetMath () const;


  /**
   * Sets the message of this Constraint.
   *
   * The XMLNode tree passed in @p xhtml is copied.
   *
   * @param xhtml an XML tree containing XHTML content.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int setMessage (const XMLNode* xhtml);


  /**
   * Sets the mathematical expression of this Constraint to a copy of the
   * AST given as @p math.
   *
   * @param math an ASTNode expression to be assigned as the "math"
   * subelement of this Constraint
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   */
  int setMath (const ASTNode* math);


  /**
   * Unsets the "message" subelement of this Constraint.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int unsetMessage ();


  /**
   * @copydoc doc_renamesidref_common
   */
  virtual void renameSIdRefs(const std::string& oldid, const std::string& newid);


  /**
   * @copydoc doc_renameunitsidref_common
   */
  virtual void renameUnitSIdRefs(const std::string& oldid, const std::string& newid);


  /** @cond doxygenLibsbmlInternal */
  /**
   * Replace all nodes with the name 'id' from the child 'math' object with the provided function. 
   *
   */
  virtual void replaceSIDWithFunction(const std::string& id, const ASTNode* function);
  /** @endcond */


  /**
   * Returns the libSBML type code for this SBML object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_CONSTRAINT, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for Constraint, is
   * always @c "constraint".
   * 
   * @return the name of this element, i.e., @c "constraint".
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
   * all the required elements for this Constraint object
   * have been set.
   *
   * @note The required elements for a Constraint object are:
   * @li 'math'
   *
   * @return a boolean value indicating whether all the required
   * elements for this object have been defined.
   */
  virtual bool hasRequiredElements() const;


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Subclasses should override this method to read (and store) XHTML,
   * MathML, etc. directly from the XMLInputStream.
   *
   * @return true if the subclass read from the stream, false otherwise.
   */
  virtual bool readOtherXML (XMLInputStream& stream);


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

  void readL2Attributes (const XMLAttributes& attributes);
  
  void readL3Attributes (const XMLAttributes& attributes);


  /**
   * Subclasses should override this method to write their XML attributes
   * to the XMLOutputStream.  Be sure to call your parents implementation
   * of this method as well.
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;


  ASTNode* mMath;
  XMLNode* mMessage;

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



class LIBSBML_EXTERN ListOfConstraints : public ListOf
{
public:

  /**
   * Creates a new ListOfConstraints object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   * 
   * @param version the Version within the SBML Level
   */
  ListOfConstraints (unsigned int level, unsigned int version);
          

  /**
   * Creates a new ListOfConstraints object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfConstraints object to be created.
   */
  ListOfConstraints (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfConstraints object.
   *
   * @return the (deep) copy of this ListOfConstraints object.
   */
  virtual ListOfConstraints* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., Constraint objects, if the list is non-empty).
   *
   * @copydetails doc_what_are_typecodes
   * 
   * @return the SBML type code for the objects contained in this ListOf
   * instance: @sbmlconstant{SBML_CONSTRAINT, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfConstraints, the XML element name is @c "listOfConstraints".
   * 
   * @return the name of this element.
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a Constraint from the ListOfConstraints.
   *
   * @param n the index number of the Constraint to get.
   * 
   * @return the nth Constraint in this ListOfConstraints.
   *
   * @see size()
   */
  virtual Constraint * get(unsigned int n); 


  /**
   * Get a Constraint from the ListOfConstraints.
   *
   * @param n the index number of the Constraint to get.
   * 
   * @return the nth Constraint in this ListOfConstraints.
   *
   * @see size()
   */
  virtual const Constraint * get(unsigned int n) const; 


  /**
   * Removes the nth item from this ListOfConstraints items and returns a
   * pointer to it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual Constraint* remove (unsigned int n);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Get the ordinal position of this element in the containing object
   * (which in this case is the Model object).
   *
   * The ordering of elements in the XML form of SBML is generally fixed
   * for most components in SBML.  So, for example, the ListOfConstraints
   * in a model is (in SBML Level&nbsp;2 Version 4) the tenth ListOf___.
   * (However, it differs for different Levels and Versions of SBML.)
   *
   * @return the ordinal position of the element with respect to its
   * siblings, or @c -1 (default) to indicate the position is not significant.
   */
  virtual int getElementPosition () const;

  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Create and return an SBML object of this class, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or @c NULL if the token was not recognized.
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
 * Creates a new Constraint_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * Constraint_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * Constraint_t
 *
 * @return a pointer to the newly created Constraint_t structure.
 *
 * @note Once a Constraint_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the Constraint_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
Constraint_t *
Constraint_create (unsigned int level, unsigned int version);


/**
 * Creates a new Constraint_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this Constraint_t
 *
 * @return a pointer to the newly created Constraint_t structure.
 *
 * @note Once a Constraint_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the Constraint_t.  Despite this, the ability to supply the values at creation 
 * time is an important aid to creating valid SBML.  Knowledge of the intended 
 * SBML Level and Version determine whether it is valid to assign a particular 
 * value to an attribute, or whether it is valid to add a structure to an existing
 * SBMLDocument_t.
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
Constraint_t *
Constraint_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given Constraint_t structure.
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
void
Constraint_free (Constraint_t *c);


/**
 * Creates and returns a deep copy of the given Constraint_t structure.
 *
 * @param c the Constraint_t structure to copy
 * 
 * @return a (deep) copy of Constraint_t.
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
Constraint_t *
Constraint_clone (const Constraint_t *c);


/**
 * Returns a list of XMLNamespaces_t associated with this Constraint_t
 * structure.
 *
 * @param c the Constraint_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
Constraint_getNamespaces(Constraint_t *c);


/**
 * Get the message, if any, associated with this Constraint_t
 *
 * @param c the Constraint_t structure 
 * 
 * @return the message for this Constraint_t, as an XMLNode_t.
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
const XMLNode_t *
Constraint_getMessage (const Constraint_t *c);


/**
 * Get the message string, if any, associated with this Constraint_t
 *
 * @param c the Constraint_t structure 
 * 
 * @return the message for this Constraint_t, as a string (char*).
 * @c NULL is returned if the message is not set.
 *
 * @note returned char* should be freed with safe_free() by the caller.
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
char*
Constraint_getMessageString (const Constraint_t *c);


/**
 * Get the mathematical expression of this Constraint_t
 *
 * @param c the Constraint_t structure 
 * 
 * @return the math for this Constraint_t, as an ASTNode_t.
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
const ASTNode_t *
Constraint_getMath (const Constraint_t *c);


/**
 * Predicate returning @c true or @c false depending on whether a
 * message is defined for this Constraint_t.
 *
 * @param c the Constraint_t structure 
 * 
 * @return a nonzero integer if the "message" subelement for this
 * Constraint_t is set, zero (0) otherwise.
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
int
Constraint_isSetMessage (const Constraint_t *c);


/**
 * Predicate returning @c true or @c false depending on whether a
 * mathematical formula is defined for this Constraint_t.
 *
 * @param c the Constraint_t structure 
 * 
 * @return a nonzero integer if the "math" subelement for this Constraint_t
 * is set, zero (0) otherwise.
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
int
Constraint_isSetMath (const Constraint_t *c);


/**
 * Sets the message of this Constraint_t.
 *
 * @param c the Constraint_t structure
 *
 * @param xhtml an XML tree containing XHTML content.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
int
Constraint_setMessage (Constraint_t *c, const XMLNode_t* xhtml);


/**
 * Sets the mathematical expression of this Constraint_t.
 *
 * @param c the Constraint_t structure
 *
 * @param math an ASTNode_t expression to be assigned as the "math"
 * subelement of this Constraint_t
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
int
Constraint_setMath (Constraint_t *c, const ASTNode_t *math);


/**
 * Unsets the "message" subelement of this Constraint_t.
 *
 * @param c the Constraint_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Constraint_t
 */
LIBSBML_EXTERN
int 
Constraint_unsetMessage (Constraint_t *c);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* !SWIG */
#endif  /* Constraint_h */
