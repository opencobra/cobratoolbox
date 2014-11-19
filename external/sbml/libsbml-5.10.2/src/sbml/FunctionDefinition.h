/**
 * @file    FunctionDefinition.h
 * @brief   Definitions of FunctionDefinition and ListOfFunctionDefinitions.
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
 * @class FunctionDefinition
 * @sbmlbrief{core} A user-defined function in an SBML model.
 *
 * The FunctionDefinition structure associates an identifier with a
 * function definition.  This identifier can then be used as the function
 * called in subsequent MathML content elsewhere in an SBML model.
 * 
 * FunctionDefinition has one required attribute, "id", to give the
 * function a unique identifier by which other parts of an SBML model
 * definition can refer to it.  A FunctionDefinition instance can also have
 * an optional "name" attribute of type @c string.  Identifiers and names
 * must be used according to the guidelines described in the %SBML
 * specification (e.g., Section 3.3 in the Level 2 Version 4
 * specification).
 * 
 * FunctionDefinition has a required "math" subelement containing a MathML
 * expression defining the function body.  The content of this element can
 * only be a MathML "lambda" element.  The "lambda" element must begin with
 * zero or more "bvar" elements, followed by any other of the elements in
 * the MathML subset allowed in SBML Level 2 @em except "lambda" (i.e., a
 * "lambda" element cannot contain another "lambda" element).  This is the
 * only place in SBML where a "lambda" element can be used.  The function
 * defined by a FunctionDefinition is only available for use in other
 * MathML elements that @em follow the FunctionDefinition definition in the
 * model.  (These restrictions prevent recursive and mutually-recursive
 * functions from being expressed.)
 *
 * A further restriction on the content of "math" is that it cannot contain
 * references to variables other than the variables declared to the
 * "lambda" itself.  That is, the contents of MathML "ci" elements inside
 * the body of the "lambda" can only be the variables declared by its
 * "bvar" elements, or the identifiers of other FunctionDefinition
 * instances in the model.  This means must be written so that all
 * variables or parameters used in the MathML content are passed to them
 * via their function parameters.  In SBML Level&nbsp;2, this restriction
 * applies also to the MathML @c csymbol elements for @em time and @em
 * delay; in SBML Level&nbsp;3, it additionally applies to the @c csymbol
 * element for @em avogadro.
 *
 * @note Function definitions (also informally known as user-defined
 * functions) were introduced in SBML Level 2.  They have purposefully
 * limited capabilities.  A function cannot reference parameters or other
 * model quantities outside of itself; values must be passed as parameters
 * to the function.  Moreover, recursive and mutually-recursive functions
 * are not permitted.  The purpose of these limitations is to balance power
 * against complexity of implementation.  With the restrictions as they
 * are, function definitions could be implemented as textual
 * substitutions---they are simply macros.  Software implementations
 * therefore do not need the full function-definition machinery typically
 * associated with programming languages.
 * <br><br>
 * Another important point to note is FunctionDefinition does not
 * have a separate attribute for defining the units of the value returned
 * by the function.  The units associated with the function's return value,
 * when the function is called from within MathML expressions elsewhere in
 * SBML, are simply the overall units of the expression in
 * FunctionDefinition's "math" subelement when applied to the arguments
 * supplied in the call to the function.  Ascertaining these units requires
 * performing dimensional analysis on the expression.  (Readers may wonder
 * why there is no attribute.  The reason is that having a separate
 * attribute for declaring the units would not only be redundant, but also
 * lead to the potential for having conflicting information.  In the case
 * of a conflict between the declared units and those of the value actually
 * returned by the function, the only logical resolution rule would be to
 * assume that the correct units are those of the expression anyway.)
 * 
 * <!---------------------------------------------------------------------- -->
 *
 * @class ListOfFunctionDefinitions
 * @sbmlbrief{core} A list of FunctionDefinition objects.
 *
 * @copydetails doc_what_is_listof
 */

#ifndef FunctionDefinition_h
#define FunctionDefinition_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/SBO.h>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTNode;
class SBMLVisitor;


class LIBSBML_EXTERN FunctionDefinition : public SBase
{
public:

  /**
   * Creates a new FunctionDefinition using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this FunctionDefinition
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * FunctionDefinition
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  FunctionDefinition (unsigned int level, unsigned int version);


  /**
   * Creates a new FunctionDefinition using the given SBMLNamespaces object
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
  FunctionDefinition (SBMLNamespaces* sbmlns);


  /**
   * Destroys this FunctionDefinition.
   */
  virtual ~FunctionDefinition ();


  /**
   * Copy constructor; creates a copy of this FunctionDefinition.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  FunctionDefinition (const FunctionDefinition& orig);


  /**
   * Assignment operator for FunctionDefinition.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  FunctionDefinition& operator=(const FunctionDefinition& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of FunctionDefinition.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next FunctionDefinition in
   * the list of function definitions.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this FunctionDefinition object.
   *
   * @return the (deep) copy of this FunctionDefinition object.
   */
  virtual FunctionDefinition* clone () const;


  /**
   * Returns the value of the "id" attribute of this FunctionDefinition.
   * 
   * @return the id of this FunctionDefinition.
   */
  virtual const std::string& getId () const;


  /**
   * Returns the value of the "name" attribute of this FunctionDefinition.
   * 
   * @return the name of this FunctionDefinition.
   */
  virtual const std::string& getName () const;


  /**
   * Get the mathematical formula of this FunctionDefinition.
   *
   * @return an ASTNode, the value of the "math" subelement of this
   * FunctionDefinition
   */
  const ASTNode* getMath () const;


  /**
   * Predicate returning @c true if this
   * FunctionDefinition's "id" attribute is set.
   *
   * @return @c true if the "id" attribute of this FunctionDefinition is
   * set, @c false otherwise.
   */
  virtual bool isSetId () const;


  /**
   * Predicate returning @c true if this
   * FunctionDefinition's "name" attribute is set.
   *
   * @return @c true if the "name" attribute of this FunctionDefinition is
   * set, @c false otherwise.
   */
  virtual bool isSetName () const;


  /**
   * Predicate returning @c true if this
   * FunctionDefinition's "math" subelement contains a value.
   * 
   * @return @c true if the "math" for this FunctionDefinition is set,
   * @c false otherwise.
   */
  bool isSetMath () const;


  /**
   * Sets the value of the "id" attribute of this FunctionDefinition.
   *
   * The string @p sid is copied.
   *
   * @copydetails doc_id_syntax
   *
   * @param sid the string to use as the identifier of this FunctionDefinition
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  virtual int setId (const std::string& sid);


  /**
   * Sets the value of the "name" attribute of this FunctionDefinition.
   *
   * The string in @p name is copied.
   *
   * @param name the new name for the FunctionDefinition
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  virtual int setName (const std::string& name);


  /**
   * Sets the "math" subelement of this FunctionDefinition to the Abstract
   * Syntax Tree given in @p math.
   *
   * @param math an AST containing the mathematical expression to
   * be used as the formula for this FunctionDefinition.
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
   * Unsets the value of the "name" attribute of this FunctionDefinition.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  virtual int unsetName ();


  /**
   * Get the <code>n</code>th argument to this function.
   *
   * Callers should first find out the number of arguments to the function
   * by calling getNumArguments().
   *
   * @param n an integer index for the argument sought.
   * 
   * @return the nth argument (bound variable) passed to this
   * FunctionDefinition.
   *
   * @see getNumArguments()
   */
  const ASTNode* getArgument (unsigned int n) const;


  /**
   * Get the argument named @p name to this FunctionDefinition.
   *
   * @param name the exact name (case-sensitive) of the sought-after
   * argument
   * 
   * @return the argument (bound variable) having the given name, or @c NULL if
   * no such argument exists.
   */
  const ASTNode* getArgument (const std::string& name) const;


  /**
   * Get the mathematical expression that is the body of this
   * FunctionDefinition object.
   * 
   * @return the body of this FunctionDefinition as an Abstract Syntax
   * Tree, or @c NULL if no body is defined.
   */
  const ASTNode* getBody () const;


  /**
   * Get the mathematical expression that is the body of this
   * FunctionDefinition object.
   * 
   * @return the body of this FunctionDefinition as an Abstract Syntax
   * Tree, or @c NULL if no body is defined.
   */
  ASTNode* getBody ();


  /**
   * Predicate returning @c true if the body of this
   * FunctionDefinition has set.
   *
   * @return @c true if the body of this FunctionDefinition is 
   * set, @c false otherwise.
   */
  bool isSetBody () const;


  /**
   * Get the number of arguments (bound variables) taken by this
   * FunctionDefinition.
   *
   * @return the number of arguments (bound variables) that must be passed
   * to this FunctionDefinition.
   */
  unsigned int getNumArguments () const;


  /**
   * Returns the libSBML type code for this %SBML object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_FUNCTION_DEFINITION, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for
   * FunctionDefinition, is always @c "functionDefinition".
   * 
   * @return the name of this element, i.e., @c "functionDefinition".
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
   * all the required attributes for this FunctionDefinition object
   * have been set.
   *
   * The required attributes for a FunctionDefinition object are:
   * @li "id"
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const ;

  /**
   * Predicate returning @c true if
   * all the required elements for this FunctionDefinition object
   * have been set.
   *
   * @note The required elements for a FunctionDefinition object are:
   * @li "math"
   *
   * @return a boolean value indicating whether all the required
   * elements for this object have been defined.
   */
  virtual bool hasRequiredElements() const ;


  /**
   * Renames all the @c UnitSIdRef attributes on this element.
   *
   * @copydetails doc_what_is_unitsidref
   *
   * This method works by looking at all unit identifier attribute values
   * (including, if appropriate, inside mathematical formulas), comparing the
   * unit identifiers to the value of @p oldid.  If any matches are found,
   * the matching identifiers are replaced with @p newid.  The method does
   * @em not descend into child elements.
   * 
   * @param oldid the old identifier
   * @param newid the new identifier
   */
  virtual void renameUnitSIdRefs(const std::string& oldid, const std::string& newid);


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


  std::string   mId;
  std::string   mName;
  ASTNode*      mMath;

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



class LIBSBML_EXTERN ListOfFunctionDefinitions : public ListOf
{
public:

  /**
   * Creates a new ListOfFunctionDefinitions object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   * 
   * @param version the Version within the SBML Level
   */
  ListOfFunctionDefinitions(unsigned int level, unsigned int version);


  /**
   * Creates a new ListOfFunctionDefinitions object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfFunctionDefinitions object to be created.
   */
  ListOfFunctionDefinitions(SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfFunctionDefinitions object.
   *
   * @return the (deep) copy of this ListOfFunctionDefinitions object.
   */
  virtual ListOfFunctionDefinitions* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., FunctionDefinition objects, if the list is non-empty).
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for the objects contained in this ListOf:
   * @sbmlconstant{SBML_FUNCTION_DEFINITION, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfFunctionDefinitions, the XML element name is @c
   * "listOfFunctionDefinitions".
   * 
   * @return the name of this element, i.e., @c "listOfFunctionDefinitions".
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a FunctionDefinition from the ListOfFunctionDefinitions.
   *
   * @param n the index number of the FunctionDefinition to get.
   * 
   * @return the nth FunctionDefinition in this ListOfFunctionDefinitions.
   *
   * @see size()
   */
  virtual FunctionDefinition * get(unsigned int n); 


  /**
   * Get a FunctionDefinition from the ListOfFunctionDefinitions.
   *
   * @param n the index number of the FunctionDefinition to get.
   * 
   * @return the nth FunctionDefinition in this ListOfFunctionDefinitions.
   *
   * @see size()
   */
  virtual const FunctionDefinition * get(unsigned int n) const; 


  /**
   * Get a FunctionDefinition from the ListOfFunctionDefinitions
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the FunctionDefinition to get.
   * 
   * @return FunctionDefinition in this ListOfFunctionDefinitions
   * with the given @p sid or @c NULL if no such
   * FunctionDefinition exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual FunctionDefinition* get (const std::string& sid);


  /**
   * Get a FunctionDefinition from the ListOfFunctionDefinitions
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the FunctionDefinition to get.
   * 
   * @return FunctionDefinition in this ListOfFunctionDefinitions
   * with the given @p sid or @c NULL if no such
   * FunctionDefinition exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const FunctionDefinition* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfFunctionDefinitions items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual FunctionDefinition* remove (unsigned int n);


  /**
   * Removes item in this ListOfFunctionDefinitions items with the given identifier.
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
  virtual FunctionDefinition* remove (const std::string& sid);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Get the ordinal position of this element in the containing object
   * (which in this case is the Model object).
   *
   * The ordering of elements in the XML form of %SBML is generally fixed
   * for most components in %SBML.  So, for example, the
   * ListOfFunctionDefinitions in a model is (in %SBML Level 2 Version 4)
   * the first ListOf___.  (However, it differs for different Levels and
   * Versions of SBML.)
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
 * Creates a new FunctionDefinition_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * FunctionDefinition_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * FunctionDefinition_t
 *
 * @return a pointer to the newly created FunctionDefinition_t structure.
 *
 * @note Once a FunctionDefinition_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the FunctionDefinition_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
FunctionDefinition_t *
FunctionDefinition_create (unsigned int level, unsigned int version);


/**
 * Creates a new FunctionDefinition_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this FunctionDefinition_t
 *
 * @return a pointer to the newly created FunctionDefinition_t structure.
 *
 * @note Once a FunctionDefinition_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the FunctionDefinition_t.  Despite this, the ability to supply the values at 
 * creation time is an important aid to creating valid SBML.  Knowledge of the 
 * intended SBML Level and Version determine whether it is valid to assign a 
 * particular value to an attribute, or whether it is valid to add a structure to 
 * an existing SBMLDocument_t.
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
FunctionDefinition_t *
FunctionDefinition_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given FunctionDefinition_t.
 *
 * @param fd the FunctionDefinition_t structure
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
void
FunctionDefinition_free (FunctionDefinition_t *fd);


/**
 * Creates a deep copy of the given FunctionDefinition_t structure
 * 
 * @param fd the FunctionDefinition_t structure to be copied
 * 
 * @return a (deep) copy of the given FunctionDefinition_t structure.
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
FunctionDefinition_t *
FunctionDefinition_clone (const FunctionDefinition_t* fd);


/**
 * Returns a list of XMLNamespaces_t associated with this FunctionDefinition_t
 * structure.
 *
 * @param fd the FunctionDefinition_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
FunctionDefinition_getNamespaces(FunctionDefinition_t *fd);


/**
 * Get the identifier of the given FunctionDefinition_t structure.
 *
 * @param fd the FunctionDefinition_t structure
 * 
 * @return the value of the "id" attribute of this FunctionDefinition_t
 * structure.
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
const char *
FunctionDefinition_getId (const FunctionDefinition_t *fd);


/**
 * Get the name of the given FunctionDefinition_t structure.
 *
 * @param fd the FunctionDefinition_t structure
 *
 * @return the name of this FunctionDefinition_t structure.
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
const char *
FunctionDefinition_getName (const FunctionDefinition_t *fd);


/**
 * Get the mathematical formula implemented by the given function.
 *
 * @param fd the FunctionDefinition_t structure
 * 
 * @return an ASTNode_t tree representing the mathematical formula of this
 * FunctionDefinition_t structure.
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
const ASTNode_t *
FunctionDefinition_getMath (const FunctionDefinition_t *fd);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * FunctionDefinition_t structure's "id" attribute is set.
 *
 * @param fd the FunctionDefinition_t structure
 *
 * @return nonzero if the "id" attribute of the FunctionDefinition_t
 * structure is set, zero (0) otherwise.
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
int
FunctionDefinition_isSetId (const FunctionDefinition_t *fd);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * FunctionDefinition_t structure's "name" attribute is set.
 *
 * @param fd the FunctionDefinition_t structure
 *
 * @return nonzero if the "name" attribute of the FunctionDefinition_t
 * structure is set, zero (0) otherwise.
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
int
FunctionDefinition_isSetName (const FunctionDefinition_t *fd);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * FunctionDefinition_t structure's "math" subelement is set.
 *
 * @param fd the FunctionDefinition_t structure
 *
 * @return nonzero if the mathematical expression of this
 * FunctionDefinition_t is set, zero (0) otherwise.
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
int
FunctionDefinition_isSetMath (const FunctionDefinition_t *fd);


/**
 * Sets the value of the "id" attribute of a FunctionDefinition_t structure.
 *
 * @param fd the FunctionDefinition_t structure to set.
 *
 * @param sid the identifier to assign to the "id" attribute of @p fd
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
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
int
FunctionDefinition_setId (FunctionDefinition_t *fd, const char *sid);


/**
 * Sets the value of the "name" attribute of a FunctionDefinition_t structure.
 *
 * @param fd the FunctionDefinition_t structure to set.
 *
 * @param name the identifier to assign to the "name" attribute of @p fd
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
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
int
FunctionDefinition_setName (FunctionDefinition_t *fd, const char *name);


/**
 * Sets the "math" subelement of a given FunctionDefinition_t structure.
 *
 * The ASTNode_t structure given in @p math is copied.
 *
 * @param fd the FunctionDefinition_t structure to set.
 *
 * @param math the ASTNode_t structure to copy and assign to the "math"
 * subelement of the given FunctionDefinition_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
int
FunctionDefinition_setMath (FunctionDefinition_t *fd, const ASTNode_t *math);


/**
 * Unsets the "name" attribute of the given FunctionDefinition_t structure.
 * 
 * @param fd the FunctionDefinition_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
int
FunctionDefinition_unsetName (FunctionDefinition_t *fd);


/**
 * Get the nth argument (bound variable) to the given FunctionDefinition_t
 * structure.
 * 
 * @param fd the FunctionDefinition_t structure
 *
 * @param n the index of the argument to return
 *
 * @return an ASTNode_t tree structure for the argument.
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
const ASTNode_t *
FunctionDefinition_getArgument(const FunctionDefinition_t *fd, unsigned int n);


/**
 * Get the argument named @p name to the given FunctionDefinition_t structure.
 *
 * @param fd the FunctionDefinition_t structure
 *
 * @param name the exact name (case-sensitive) of the sought-after argument
 *
 * @return an ASTNode_t structure representing the argument (bound
 * variable)
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
const ASTNode_t *
FunctionDefinition_getArgumentByName (  FunctionDefinition_t *fd
                                      , const char *name );


/**
 * Get the mathematical expression that constitutes the body of the given
 * function definition.
 *
 * @param fd the FunctionDefinition_t structure
 * 
 * @return an ASTNode_t tree that is the "math" subelement" of this
 * FunctionDefinition_t structure
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
const ASTNode_t *
FunctionDefinition_getBody (const FunctionDefinition_t *fd);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * FunctionDefinition_t structure's "math" subelement has a body.
 *
 * @param fd the FunctionDefinition_t structure
 *
 * @return nonzero if the body of this
 * FunctionDefinition_t is set, zero (0) otherwise.
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
int
FunctionDefinition_isSetBody (const FunctionDefinition_t *fd);


/**
 * Get the number of arguments that the given function definition takes.
 *
 * @param fd the FunctionDefinition_t structure
 * 
 * @return the number of arguments (bound variables) that must be passed
 * to this FunctionDefinition_t structure.
 *
 * @memberof FunctionDefinition_t
 */
LIBSBML_EXTERN
unsigned int
FunctionDefinition_getNumArguments (const FunctionDefinition_t *fd);


/**
 * Returns the FunctionDefinition_t structure having a given identifier.
 *
 * @param lo the ListOfFunctionDefinitions_t structure to search.
 * @param sid the "id" attribute value being sought.
 *
 * @return item in the @p lo ListOfFunctionDefinitions with the given @p sid or a
 * null pointer if no such item exists.
 *
 * @see ListOf_t
 *
 * @memberof ListOfFunctionDefinitions_t
 */
LIBSBML_EXTERN
FunctionDefinition_t *
ListOfFunctionDefinitions_getById (ListOf_t *lo, const char *sid);


/**
 * Removes a FunctionDefinition_t structure based on its identifier.
 *
 * The caller owns the returned item and is responsible for deleting it.
 *
 * @param lo the list of FunctionDefinition_t structures to search.
 * @param sid the "id" attribute value of the structure to remove
 *
 * @return The FunctionDefinition_t structure removed, or a null pointer if no such
 * item exists in @p lo.
 *
 * @see ListOf_t
 *
 * @memberof ListOfFunctionDefinitions_t
 */
LIBSBML_EXTERN
FunctionDefinition_t *
ListOfFunctionDefinitions_removeById (ListOf_t *lo, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* FunctionDefinition_h */

