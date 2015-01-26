/**
 * @file    SpeciesReference.h
 * @brief   Definitions of SpeciesReference and ListOfSpeciesReferences. 
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
 * @class SpeciesReference
 * @sbmlbrief{core} A reference to an SBML species in a reaction.
 *
 * The Reaction structure provides a way to express which species act as
 * reactants and which species act as products in a reaction.  In a given
 * reaction, references to those species acting as reactants and/or
 * products are made using instances of SpeciesReference structures in a
 * Reaction object's lists of reactants and products.
 *
 * A species can occur more than once in the lists of reactants and
 * products of a given Reaction instance.  The effective stoichiometry for
 * a species in a reaction is the sum of the stoichiometry values given on
 * the SpeciesReference object in the list of products minus the sum of
 * stoichiometry values given on the SpeciesReference objects in the list
 * of reactants.  A positive value indicates the species is effectively a
 * product and a negative value indicates the species is effectively a
 * reactant.  SBML places no restrictions on the effective stoichiometry of
 * a species in a reaction; for example, it can be zero.  In the following
 * SBML fragment, the two reactions have the same effective stoichiometry
 * for all their species:
 * @verbatim
 <reaction id="x">
     <listOfReactants>
         <speciesReference species="a"/>
         <speciesReference species="a"/>
         <speciesReference species="b"/>
     </listOfReactants>
     <listOfProducts>
         <speciesReference species="c"/>
         <speciesReference species="b"/>
     </listProducts>
 </reaction>
 <reaction id="y">
     <listOfReactants>
         <speciesReference species="a" stoichiometry="2"/>
     </listOfReactants>
     <listOfProducts>
         <speciesReference species="c"/>
     </listProducts>
 </reaction>
 @endverbatim
 *
 * The precise structure of SpeciesReference differs between SBML
 * Level&nbsp;2 and Level&nbsp;3.  We discuss the two variants in separate
 * sections below.
 * 
 * @section spr-l2 SpeciesReference in SBML Level 2
 *
 * The mandatory "species" attribute of SpeciesReference must have as its
 * value the identifier of an existing species defined in the enclosing
 * Model.  The species is thereby designated as a reactant or product in
 * the reaction.  Which one it is (i.e., reactant or product) is indicated
 * by whether the SpeciesReference appears in the Reaction's "reactant" or
 * "product" lists.
 * 
 * Product and reactant stoichiometries can be specified using
 * <em>either</em> "stoichiometry" or "stoichiometryMath" in a
 * SpeciesReference object.  The "stoichiometry" attribute is of type
 * double and should contain values greater than zero (0).  The
 * "stoichiometryMath" element is implemented as an element containing a
 * MathML expression.  These two are mutually exclusive; only one of
 * "stoichiometry" or "stoichiometryMath" should be defined in a given
 * SpeciesReference instance.  When neither the attribute nor the element
 * is present, the value of "stoichiometry" in the SpeciesReference
 * instance defaults to @c 1.
 *
 * For maximum interoperability, the "stoichiometry" attribute should be
 * used in preference to "stoichiometryMath" when a species' stoichiometry
 * is a simple scalar number (integer or decimal).  When the stoichiometry
 * is a rational number, or when it is a more complicated formula,
 * "stoichiometryMath" must be used.  The MathML expression in
 * "stoichiometryMath" may also refer to identifiers of entities in a model
 * (except reaction identifiers).  However, the only species identifiers
 * that can be used in "stoichiometryMath" are those referenced in the
 * Reaction list of reactants, products and modifiers.
 *
 * The following is a simple example of a species reference for species @c
 * X0, with stoichiometry @c 2, in a list of reactants within a reaction
 * having the identifier @c J1:
 * @verbatim
 <model>
     ...
     <listOfReactions>
         <reaction id="J1">
             <listOfReactants>
                 <speciesReference species="X0" stoichiometry="2">
             </listOfReactants>
             ...
         </reaction>
         ...
     </listOfReactions>
     ...
 </model>
 @endverbatim
 *
 * The following is a more complex example of a species reference for
 * species X0, with a stoichiometry formula consisting of the parameter
 * @c x:
 * @verbatim
 <model>
     ...
     <listOfReactions>
         <reaction id="J1">
             <listOfReactants>
                 <speciesReference species="X0">
                     <stoichiometryMath>
                         <math xmlns="http://www.w3.org/1998/Math/MathML">
                             <ci>x</ci>
                         </math>
                     </stoichiometryMath>
                 </speciesReference>
             </listOfReactants>
             ...
         </reaction>
         ...
     </listOfReactions>
     ...
 </model>
 @endverbatim
 *
 *
 * @section spr-l3 SpeciesReference in SBML Level 3
 *
 * In Level 2's definition of a reaction, the stoichiometry attribute of a
 * SpeciesReference is actually a combination of two factors, the standard
 * biochemical stoichiometry and a conversion factor that may be needed to
 * translate the units of the species quantity to the units of the reaction
 * rate. Unfortunately, Level&nbsp;2 offers no direct way of decoupling
 * these two factors, or for explicitly indicating the units. The only way
 * to do it in Level&nbsp;2 is to use the StoichiometryMath object
 * associated with SpeciesReferences, and to reference SBML Parameter
 * objects from within the StoichiometryMath formula. This works because
 * Parameter offers a way to attach units to a numerical value, but the
 * solution is indirect and awkward for something that should be a simple
 * matter.  Moreover, the question of how to properly encode
 * stoichiometries in SBML reactions has caused much confusion among
 * implementors of SBML software.
 *
 * SBML Level&nbsp;3 approaches this problem differently.  It (1) extends
 * the the use of the SpeciesReference identifier to represent the value of
 * the "stoichiometry" attribute, (2) makes the "stoichiometry" attribute
 * optional, (3) removes StoichiometryMath, and (4) adds a new "constant"
 * boolean attribute on SpeciesReference.
 *
 * As in Level&nbsp;2, the "stoichiometry" attribute is of type
 * @c double and should contain values greater than zero (@c 0).  A
 * missing "stoichiometry" implies that the stoichiometry is either
 * unknown, or to be obtained from an external source, or determined by an
 * InitialAssignment object or other SBML construct elsewhere in the model.
 *
 * A species reference's stoichiometry is set by its "stoichiometry"
 * attribute exactly once.  If the SpeciesReference object's "constant"
 * attribute has the value @c true, then the stoichiometry is fixed and
 * cannot be changed except by an InitialAssignment object.  These two
 * methods of setting the stoichiometry (i.e., using "stoichiometry"
 * directly, or using InitialAssignment) differ in that the "stoichiometry"
 * attribute can only be set to a literal floating-point number, whereas
 * InitialAssignment allows the value to be set using an arbitrary
 * mathematical expression.  (As an example, the approach could be used to
 * set the stoichiometry to a rational number of the form @em p/@em q,
 * where @em p and @em q are integers, something that is occasionally
 * useful in the context of biochemical reaction networks.)  If the species
 * reference's "constant" attribute has the value @c false, the species
 * reference's value may be overridden by an InitialAssignment or changed
 * by AssignmentRule or AlgebraicRule, and in addition, for simulation time
 * <em>t &gt; 0</em>, it may also be changed by a RateRule or Event
 * objects.  (However, some of these constructs are mutually exclusive; see
 * the SBML Level&nbsp;3 Version&nbsp;1 Core specifiation for more
 * details.)  It is not an error to define "stoichiometry" on a species
 * reference and also redefine the stoichiometry using an
 * InitialAssignment, but the "stoichiometry" attribute in that case is
 * ignored.
 *
 * The value of the "id" attribute of a SpeciesReference can be used as the
 * content of a <code>&lt;ci&gt;</code> element in MathML formulas
 * elsewhere in the model.  When the identifier appears in a MathML
 * <code>&lt;ci&gt;</code> element, it represents the stoichiometry of the
 * corresponding species in the reaction where the SpeciesReference object
 * instance appears.  More specifically, it represents the value of the
 * "stoichiometry" attribute on the SpeciesReference object.
 *
 * In SBML Level 3, the unit of measurement associated with the value of a
 * species' stoichiometry is always considered to be @c dimensionless.
 * This has the following implications:
 * <ul>
 *
 * <li> When a species reference's identifier appears in mathematical
 * formulas elsewhere in the model, the unit associated with that value is
 * @c dimensionless.
 *
 * <li> The units of the "math" elements of AssignmentRule,
 * InitialAssignment and EventAssignment objects setting the stoichiometry
 * of the species reference should be @c dimensionless.
 *
 * <li> If a species reference's identifier is the subject of a RateRule,
 * the unit associated with the RateRule object's value should be
 * <code>dimensionless</code>/<em>time</em>, where <em>time</em> is the
 * model-wide unit of time set on the Model object.
 *
 * </ul>
 * 
 * <!---------------------------------------------------------------------- -->
 * @class ListOfSpeciesReferences
 * @sbmlbrief{core} A list of SpeciesReference objects.
 *
 * @copydetails doc_what_is_listof 
 */

#ifndef SpeciesReference_h
#define SpeciesReference_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/ExpectedAttributes.h>
#include <sbml/SBase.h>
#include <sbml/SimpleSpeciesReference.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/StoichiometryMath.h>
#include <sbml/ListOf.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class StoichiometryMath;
class SBMLNamespaces;
class XMLNode;


class LIBSBML_EXTERN SpeciesReference : public SimpleSpeciesReference
{
public:

  /**
   * Creates a new SpeciesReference using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this SpeciesReference
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * SpeciesReference
   *
   * @copydetails doc_note_setting_lv
   */
  SpeciesReference (unsigned int level, unsigned int version);


  /**
   * Creates a new SpeciesReference using the given SBMLNamespaces object
   * @p sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object.
   *
   * @copydetails doc_note_setting_lv
   */
  SpeciesReference (SBMLNamespaces* sbmlns);


  /**
   * Destroys this SpeciesReference.
   */
  virtual ~SpeciesReference ();


  /**
   * Copy constructor; creates a copy of this SpeciesReference.
   * 
   * @param orig the SpeciesReference instance to copy.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  SpeciesReference (const SpeciesReference& orig);


  /**
   * Assignment operator
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  SpeciesReference& operator=(const SpeciesReference& rhs);


  /**
   * Accepts the given SBMLVisitor.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this SpeciesReference object.
   *
   * @return the (deep) copy of this SpeciesReference object.
   */
  virtual SpeciesReference* clone () const;


  /**
   * Initializes the fields of this SpeciesReference object to "typical"
   * default values.
   *
   * The SBML SpeciesReference component has slightly different aspects and
   * default attribute values in different SBML Levels and Versions.
   * This method sets the values to certain common defaults, based
   * mostly on what they are in SBML Level&nbsp;2.  Specifically:
   * <ul>
   * <li> Sets attribute "stoichiometry" to @c 1.0
   * <li> (Applies to Level&nbsp;1 models only) Sets attribute "denominator" to @c 1
   * </ul>
   *
   * @see getDenominator()
   * @see setDenominator(int value)
   * @see getStoichiometry()
   * @see setStoichiometry(double value)
   * @see getStoichiometryMath()
   * @see setStoichiometryMath(const StoichiometryMath* math)
   */
  void initDefaults ();


  /**
   * Get the value of the "stoichiometry" attribute.
   *
   * In SBML Level 2, product and reactant stoichiometries can be specified
   * using <em>either</em> "stoichiometry" or "stoichiometryMath" in a
   * SpeciesReference object.  The former is to be used when a
   * stoichiometry is simply a scalar number, while the latter is for
   * occasions when it needs to be a rational number or it needs to
   * reference other mathematical expressions.  The "stoichiometry"
   * attribute is of type @c double and should contain values greater than
   * zero (@c 0).  The "stoichiometryMath" element is implemented as an
   * element containing a MathML expression.  These two are mutually
   * exclusive; only one of "stoichiometry" or "stoichiometryMath" should
   * be defined in a given SpeciesReference instance.  When neither the
   * attribute nor the element is present, the value of "stoichiometry" in
   * the SpeciesReference instance defaults to @c 1.  For maximum
   * interoperability between different software tools, the "stoichiometry"
   * attribute should be used in preference to "stoichiometryMath" when a
   * species' stoichiometry is a simple scalar number (integer or
   * decimal).
   *
   * In SBML Level 3, there is no StoichiometryMath, and SpeciesReference
   * objects have only the "stoichiometry" attribute.
   * 
   * @return the value of the (scalar) "stoichiometry" attribute of this
   * SpeciesReference.
   *
   * @see getStoichiometryMath()
   */
  double getStoichiometry () const;


  /**
   * Get the content of the "stoichiometryMath" subelement as an ASTNode
   * tree.
   *
   * The "stoichiometryMath" element exists only in SBML Level 2.  There,
   * product and reactant stoichiometries can be specified using
   * <em>either</em> "stoichiometry" or "stoichiometryMath" in a
   * SpeciesReference object.  The former is to be used when a
   * stoichiometry is simply a scalar number, while the latter is for
   * occasions when it needs to be a rational number or it needs to
   * reference other mathematical expressions.  The "stoichiometry"
   * attribute is of type @c double and should contain values greater than
   * zero (@c 0).  The "stoichiometryMath" element is implemented as an
   * element containing a MathML expression.  These two are mutually
   * exclusive; only one of "stoichiometry" or "stoichiometryMath" should
   * be defined in a given SpeciesReference instance.  When neither the
   * attribute nor the element is present, the value of "stoichiometry" in
   * the SpeciesReference instance defaults to @c 1.  For maximum
   * interoperability between different software tools, the "stoichiometry"
   * attribute should be used in preference to "stoichiometryMath" when a
   * species' stoichiometry is a simple scalar number (integer or decimal).
   * 
   * @return the content of the "stoichiometryMath" subelement of this
   * SpeciesReference.
   */
  const StoichiometryMath* getStoichiometryMath () const;


  /**
   * Get the content of the "stoichiometryMath" subelement as an ASTNode
   * tree.
   *
   * The "stoichiometryMath" element exists only in SBML Level 2.  There,
   * product and reactant stoichiometries can be specified using
   * <em>either</em> "stoichiometry" or "stoichiometryMath" in a
   * SpeciesReference object.  The former is to be used when a
   * stoichiometry is simply a scalar number, while the latter is for
   * occasions when it needs to be a rational number or it needs to
   * reference other mathematical expressions.  The "stoichiometry"
   * attribute is of type @c double and should contain values greater than
   * zero (@c 0).  The "stoichiometryMath" element is implemented as an
   * element containing a MathML expression.  These two are mutually
   * exclusive; only one of "stoichiometry" or "stoichiometryMath" should
   * be defined in a given SpeciesReference instance.  When neither the
   * attribute nor the element is present, the value of "stoichiometry" in
   * the SpeciesReference instance defaults to @c 1.  For maximum
   * interoperability between different software tools, the "stoichiometry"
   * attribute should be used in preference to "stoichiometryMath" when a
   * species' stoichiometry is a simple scalar number (integer or decimal).
   * 
   * @return the content of the "stoichiometryMath" subelement of this
   * SpeciesReference.
   *
   * @see getStoichiometry()
   */
  StoichiometryMath* getStoichiometryMath ();


  /**
   * Get the value of the "denominator" attribute, for the case of a
   * rational-numbered stoichiometry or a model in SBML Level&nbsp;1.
   *
   * The "denominator" attribute is only actually written out in the case
   * of an SBML Level&nbsp;1 model.  In SBML Level&nbsp;2, rational-number
   * stoichiometries are written as MathML elements in the
   * "stoichiometryMath" subelement.  However, as a convenience to users,
   * libSBML allows the creation and manipulation of rational-number
   * stoichiometries by supplying the numerator and denominator directly
   * rather than having to manually create an ASTNode object.  LibSBML
   * will write out the appropriate constructs (either a combination of
   * "stoichiometry" and "denominator" in the case of SBML Level&nbsp;1, or a
   * "stoichiometryMath" subelement in the case of SBML Level&nbsp;2).
   * 
   * @return the value of the "denominator" attribute of this
   * SpeciesReference.
   */
  int getDenominator () const;


  /**
   * Get the value of the "constant" attribute.
   * 
   * @return the value of the "constant" attribute of this
   * SpeciesReference.
   */
  bool getConstant () const;


  /**
   * Predicate returning @c true if this
   * SpeciesReference's "stoichiometryMath" subelement is set
   * 
   * @return @c true if the "stoichiometryMath" subelement of this
   * SpeciesReference is set, @c false otherwise.
   */
  bool isSetStoichiometryMath () const;


  /**
   * Predicate returning @c true if this
   * SpeciesReference's "constant" attribute is set
   * 
   * @return @c true if the "constant" attribute of this
   * SpeciesReference is set, @c false otherwise.
   */
  bool isSetConstant () const;


  /**
   * Predicate returning @c true if this
   * SpeciesReference's "stoichiometry" attribute is set.
   * 
   * @return @c true if the "stoichiometry" attribute of this
   * SpeciesReference is set, @c false otherwise.
   */
  bool isSetStoichiometry () const;


  /**
   * Sets the value of the "stoichiometry" attribute of this
   * SpeciesReference.
   *
   * In SBML Level 2, product and reactant stoichiometries can be specified
   * using <em>either</em> "stoichiometry" or "stoichiometryMath" in a
   * SpeciesReference object.  The former is to be used when a
   * stoichiometry is simply a scalar number, while the latter is for
   * occasions when it needs to be a rational number or it needs to
   * reference other mathematical expressions.  The "stoichiometry"
   * attribute is of type @c double and should contain values greater than
   * zero (@c 0).  The "stoichiometryMath" element is implemented as an
   * element containing a MathML expression.  These two are mutually
   * exclusive; only one of "stoichiometry" or "stoichiometryMath" should
   * be defined in a given SpeciesReference instance.  When neither the
   * attribute nor the element is present, the value of "stoichiometry" in
   * the SpeciesReference instance defaults to @c 1.  For maximum
   * interoperability between different software tools, the "stoichiometry"
   * attribute should be used in preference to "stoichiometryMath" when a
   * species' stoichiometry is a simple scalar number (integer or
   * decimal).
   *
   * In SBML Level 3, there is no StoichiometryMath, and SpeciesReference
   * objects have only the "stoichiometry" attribute.
   * 
   * @param value the new value of the "stoichiometry" attribute
   *
   * @note In SBML Level&nbsp;2, the "stoichiometryMath" subelement of this
   * SpeciesReference object will be unset because the "stoichiometry"
   * attribute and the stoichiometryMath" subelement are mutually
   * exclusive.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setStoichiometry (double value);


  /**
   * Sets the "stoichiometryMath" subelement of this SpeciesReference.
   *
   * The Abstract Syntax Tree in @p math is copied.
   *
   * In SBML Level 2, product and reactant stoichiometries can be specified
   * using <em>either</em> "stoichiometry" or "stoichiometryMath" in a
   * SpeciesReference object.  The former is to be used when a
   * stoichiometry is simply a scalar number, while the latter is for
   * occasions when it needs to be a rational number or it needs to
   * reference other mathematical expressions.  The "stoichiometry"
   * attribute is of type @c double and should contain values greater than
   * zero (@c 0).  The "stoichiometryMath" element is implemented as an
   * element containing a MathML expression.  These two are mutually
   * exclusive; only one of "stoichiometry" or "stoichiometryMath" should
   * be defined in a given SpeciesReference instance.  When neither the
   * attribute nor the element is present, the value of "stoichiometry" in
   * the SpeciesReference instance defaults to @c 1.  For maximum
   * interoperability between different software tools, the "stoichiometry"
   * attribute should be used in preference to "stoichiometryMath" when a
   * species' stoichiometry is a simple scalar number (integer or
   * decimal).
   *
   * In SBML Level 3, there is no StoichiometryMath, and SpeciesReference
   * objects have only the "stoichiometry" attribute.
   * 
   * @param math the StoichiometryMath expression that is to be copied as the
   * content of the "stoichiometryMath" subelement.
   *
   * @note In SBML Level&nbsp;2, the "stoichiometry" attribute of this
   * SpeciesReference object will be unset (isSetStoichiometry() will
   * return @c false although getStoichiometry() will return @c 1.0) if the
   * given math is not null because the "stoichiometry" attribute and the
   * stoichiometryMath" subelement are mutually exclusive.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
   */
  int setStoichiometryMath (const StoichiometryMath* math);



  /**
   * Set the value of the "denominator" attribute, for the case of a
   * rational-numbered stoichiometry or a model in SBML Level&nbsp;1.
   *
   * The "denominator" attribute is only actually written out in the case
   * of an SBML Level&nbsp;1 model.  In SBML Level&nbsp;2, rational-number
   * stoichiometries are written as MathML elements in the
   * "stoichiometryMath" subelement.  However, as a convenience to users,
   * libSBML allows the creation and manipulation of rational-number
   * stoichiometries by supplying the numerator and denominator directly
   * rather than having to manually create an ASTNode object.  LibSBML
   * will write out the appropriate constructs (either a combination of
   * "stoichiometry" and "denominator" in the case of SBML Level&nbsp;1, or
   * a "stoichiometryMath" subelement in the case of SBML Level&nbsp;2).
   *
   * @param value the scalar value 
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int setDenominator (int value);


  /**
   * Sets the "constant" attribute of this SpeciesReference to the given boolean
   * @p flag.
   *
   * @param flag a boolean, the value for the "constant" attribute of this
   * SpeciesReference instance
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   */
  int setConstant (bool flag);


  /**
   * Unsets the "stoichiometryMath" subelement of this SpeciesReference.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * In SBML Level 2, product and reactant stoichiometries can be specified
   * using <em>either</em> "stoichiometry" or "stoichiometryMath" in a
   * SpeciesReference object.  The former is to be used when a
   * stoichiometry is simply a scalar number, while the latter is for
   * occasions when it needs to be a rational number or it needs to
   * reference other mathematical expressions.  The "stoichiometry"
   * attribute is of type @c double and should contain values greater than
   * zero (@c 0).  The "stoichiometryMath" element is implemented as an
   * element containing a MathML expression.  These two are mutually
   * exclusive; only one of "stoichiometry" or "stoichiometryMath" should
   * be defined in a given SpeciesReference instance.  When neither the
   * attribute nor the element is present, the value of "stoichiometry" in
   * the SpeciesReference instance defaults to @c 1.  For maximum
   * interoperability between different software tools, the "stoichiometry"
   * attribute should be used in preference to "stoichiometryMath" when a
   * species' stoichiometry is a simple scalar number (integer or
   * decimal).
   *
   * In SBML Level 3, there is no StoichiometryMath, and SpeciesReference
   * objects have only the "stoichiometry" attribute.
   *
   * @note In SBML Level&nbsp;2, the "stoichiometry" attribute of this
   * SpeciesReference object will be reset to a default value (@c 1.0) if
   * the "stoichiometry" attribute has not been set.
   */
  int unsetStoichiometryMath ();


  /**
   * Unsets the "stoichiometry" attribute of this SpeciesReference.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note In SBML Level&nbsp;1, the "stoichiometry" attribute of this
   * SpeciesReference object will be just reset to a default value (@c 1.0)
   * and isSetStoichiometry() will still return @c true.  In SBML
   * Level&nbsp;2, the "stoichiometry" attribute of this object will be
   * unset (which will result in isSetStoichiometry() returning @c false,
   * although getStoichiometry() will return @c 1.0) if the
   * "stoichiometryMath" subelement is set, otherwise the attribute
   * will be just reset to the default value (@c 1.0) (and
   * isSetStoichiometry() will still return @c true).  In SBML
   * Level&nbsp;3, the "stoichiometry" attribute of this object will be set
   * to @c NaN and isSetStoichiometry() will return @c false.
   */
  int unsetStoichiometry ();


  /**
   * Creates a new, empty StoichiometryMath object, adds it to this
   * SpeciesReference, and returns it.
   *
   * @return the newly created StoichiometryMath object instance
   *
   * @see Reaction::addReactant(const SpeciesReference* sr)
   * @see Reaction::addProduct(const SpeciesReference* sr)
   */
  StoichiometryMath* createStoichiometryMath ();


  /**
   * Sets the value of the "annotation" subelement of this SBML object to a
   * copy of @p annotation.
   *
   * Any existing content of the "annotation" subelement is discarded.
   * Unless you have taken steps to first copy and reconstitute any
   * existing annotations into the @p annotation that is about to be
   * assigned, it is likely that performing such wholesale replacement is
   * unfriendly towards other software applications whose annotations are
   * discarded.  An alternative may be to use appendAnnotation().
   *
   * @param annotation an XML structure that is to be used as the content
   * of the "annotation" subelement of this object
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   *
   * @see appendAnnotation(const XMLNode* annotation)
   * @see appendAnnotation(const std::string& annotation)
   */
  virtual int setAnnotation (const XMLNode* annotation);


  /**
   * Sets the value of the "annotation" subelement of this SBML object to a
   * copy of @p annotation.
   *
   * Any existing content of the "annotation" subelement is discarded.
   * Unless you have taken steps to first copy and reconstitute any
   * existing annotations into the @p annotation that is about to be
   * assigned, it is likely that performing such wholesale replacement is
   * unfriendly towards other software applications whose annotations are
   * discarded.  An alternative may be to use appendAnnotation().
   *
   * @param annotation an XML string that is to be used as the content
   * of the "annotation" subelement of this object
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see appendAnnotation(const XMLNode* annotation)
   * @see appendAnnotation(const std::string& annotation)
   */
  virtual int setAnnotation (const std::string& annotation);


  /**
   * Appends annotation content to any existing content in the "annotation"
   * subelement of this object.
   *
   * The content in @p annotation is copied.  Unlike
   * SpeciesReference::setAnnotation(@if java String@endif),
   * this method allows other annotations to be preserved when an application
   * adds its own data.
   *
   * @param annotation an XML structure that is to be copied and appended
   * to the content of the "annotation" subelement of this object
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see setAnnotation(const std::string& annotation)
   * @see setAnnotation(const XMLNode* annotation)
   */
  virtual int appendAnnotation (const XMLNode* annotation);


  /**
   * Appends annotation content to any existing content in the "annotation"
   * subelement of this object.
   *
   * The content in @p annotation is copied.  Unlike
   * SpeciesReference::setAnnotation(@if java String@endif), this
   * method allows other annotations to be preserved when an application
   * adds its own data.
   *
   * @param annotation an XML string that is to be copied and appended
   * to the content of the "annotation" subelement of this object
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @see setAnnotation(const std::string& annotation)
   * @see setAnnotation(const XMLNode* annotation)
   */
  virtual int appendAnnotation (const std::string& annotation);


  /**
   * Returns the libSBML type code for this %SBML object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_SPECIES_REFERENCE, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for
   * SpeciesReference, is always @c "speciesReference".
   * 
   * @return the name of this element, i.e., @c "speciesReference".
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


  /** @cond doxygenLibsbmlInternal */
  /*
   * This functional checks whether a math expression equates to 
   * a rational and produces values for stoichiometry and denominator
   */
  void sortMath();
  /** @endcond */


  /**
   * Predicate returning @c true if
   * all the required attributes for this SpeciesReference object
   * have been set.
   *
   * The required attributes for a SpeciesReference object are:
   * @li "species"
   * @li "constant" (only available SBML Level&nbsp;3)
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const ;


protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Create and return a speciesReference object, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or @c NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);

  /**
   * Subclasses should override this method to read (and store) XHTML,
   * MathML, etc. directly from the XMLInputStream.
   *
   * @return true if the subclass read from the stream, false otherwise.
   */
  bool readOtherXML (XMLInputStream& stream);


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

  /**
   *
   * Synchronizes the annotation of this SBML object.
   *
   * Annotation element (XMLNode* mAnnotation) is synchronized with the
   * current CVTerm objects (List* mCVTerm) and id string (std::string mId)
   * Currently, this method is called in getAnnotation(), isSetAnnotation(),
   * and writeElements() methods.
   */
  virtual void syncAnnotation();

  bool isExplicitlySetStoichiometry() const { 
                               return mExplicitlySetStoichiometry; };

  bool isExplicitlySetDenominator() const { 
                               return mExplicitlySetDenominator; } ;

  double    mStoichiometry;
  int       mDenominator;
  StoichiometryMath*  mStoichiometryMath;
  bool      mConstant;
  bool      mIsSetConstant;
  bool      mIsSetStoichiometry;

  bool      mExplicitlySetStoichiometry;
  bool      mExplicitlySetDenominator;

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
  friend class L3v1CompatibilityValidator;
  friend class MathMLConsistencyValidator;
  friend class ModelingPracticeValidator;
  friend class OverdeterminedValidator;
  friend class SBOConsistencyValidator;
  friend class UnitConsistencyValidator;

  /** @endcond */
};


class LIBSBML_EXTERN ListOfSpeciesReferences : public ListOf
{
public:

  /**
   * Creates a new, empty ListOfSpeciesReferences object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   * 
   * @param version the Version within the SBML Level
   */
  ListOfSpeciesReferences (unsigned int level, unsigned int version);
          

  /**
   * Creates a new ListOfSpeciesReferences object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfSpeciesReferences object to be created.
   */
  ListOfSpeciesReferences (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfSpeciesReferences object.
   *
   * @return the (deep) copy of this ListOfSpeciesReferences object.
   */
  virtual ListOfSpeciesReferences* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., SpeciesReference objects, if the list is non-empty).
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_SPECIES_REFERENCE, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfSpeciesReferences, the XML element name is @c
   * "listOfSpeciesReferences".
   * 
   * @return the name of this element, i.e., @c "listOfSpeciesReferences".
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a SpeciesReference from the ListOfSpeciesReferences.
   *
   * @param n the index number of the SpeciesReference to get.
   * 
   * @return the nth SpeciesReference in this ListOfSpeciesReferences.
   *
   * @see size()
   */
  virtual SimpleSpeciesReference * get(unsigned int n); 


  /**
   * Get a SpeciesReference from the ListOfSpeciesReferences.
   *
   * @param n the index number of the SpeciesReference to get.
   * 
   * @return the nth SpeciesReference in this ListOfSpeciesReferences.
   *
   * @see size()
   */
  virtual const SimpleSpeciesReference * get(unsigned int n) const; 


  /**
   * Get a SpeciesReference from the ListOfSpeciesReferences
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the SpeciesReference to get.
   * 
   * @return SpeciesReference in this ListOfSpeciesReferences
   * with the given @p sid or @c NULL if no such
   * SpeciesReference exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual SimpleSpeciesReference* get (const std::string& sid);


  /**
   * Get a SpeciesReference from the ListOfSpeciesReferences
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the SpeciesReference to get.
   * 
   * @return SpeciesReference in this ListOfSpeciesReferences
   * with the given @p sid or @c NULL if no such
   * SpeciesReference exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const SimpleSpeciesReference* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfSpeciesReferences items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual SimpleSpeciesReference* remove (unsigned int n);


  /**
   * Removes item in this ListOfSpeciesReferences items with the given identifier.
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
  virtual SimpleSpeciesReference* remove (const std::string& sid);


  /** @cond doxygenLibsbmlInternal */

  /**
   * Get the ordinal position of this element in the containing object
   * (which in this case is the Model object).
   *
   * @return the ordinal position of the element with respect to its
   * siblings, or @c -1 (default) to indicate the position is not significant.
   */
  virtual int getElementPosition () const;

  /** @endcond */


protected:
  /** @cond doxygenLibsbmlInternal */

  enum SpeciesType { Unknown, Reactant, Product, Modifier };


  /**
   * Sets type of this ListOfSpeciesReferences.
   */
  void setType (SpeciesType type);


  /**
   * Create and return a listOfSpeciesReferences object, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or @c NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);


  SpeciesType mType;


  friend class Reaction;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new SpeciesReference_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * SpeciesReference_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * SpeciesReference_t
 *
 * @return a pointer to the newly created SpeciesReference_t structure.
 *
 * @note Once a SpeciesReference_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the SpeciesReference_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
SpeciesReference_t *
SpeciesReference_create (unsigned int level, unsigned int version);


/**
 * Creates a new SpeciesReference_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this SpeciesReference_t
 *
 * @return a pointer to the newly created SpeciesReference_t structure.
 *
 * @note Once a SpeciesReference_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the SpeciesReference_t.  Despite this, the ability to supply the values at 
 * creation time is an important aid to creating valid SBML.  Knowledge of the 
 * intended SBML Level and Version determine whether it is valid to assign a 
 * particular value to an attribute, or whether it is valid to add a structure 
 * to an existing SBMLDocument_t.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
SpeciesReference_t *
SpeciesReference_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Creates a new ModifierSpeciesReference (SpeciesReference_t) structure 
 * using the given SBMLNamespaces_t structure.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * SpeciesReference_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * SpeciesReference_t
 *
 * @return a pointer to the newly created SpeciesReference_t structure.
 *
 * @note Once a modifier SpeciesReference_t has been added to an SBMLDocument_t, 
 * the @p level and @p version for the document @em override those used to 
 * create the modifier SpeciesReference_t.  Despite this, the ability to supply 
 * the values at creation time is an important aid to creating valid SBML.  
 * Knowledge of the intended SBML Level and Version determine whether it is
 * valid to assign a particular value to an attribute, or whether it is valid 
 * to add a structure to an existing SBMLDocument_t.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
SpeciesReference_t *
SpeciesReference_createModifier (unsigned int level, unsigned int version);


/**
 * Creates a new ModifierSpeciesReference (SpeciesReference_t) structure 
 * using the given SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this modifier SpeciesReference_t
 *
 * @return a pointer to the newly created SpeciesReference_t structure.
 *
 * @note Once a modifier SpeciesReference_t has been added to an SBMLDocument_t, 
 * the @p sbmlns namespaces for the document @em override those used to create
 * the modifier SpeciesReference_t. Despite this, the ability to supply the values 
 * at creation time is an important aid to creating valid SBML.  Knowledge of 
 * the intended SBML Level and Version determine whether it is valid to assign a 
 * particular value to an attribute, or whether it is valid to add a structure to 
 * an existing SBMLDocument_t.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
SpeciesReference_t *
SpeciesReference_createModifierWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given SpeciesReference_t structure.
 *
 * @param sr The SpeciesReference_t structure.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
void
SpeciesReference_free (SpeciesReference_t *sr);


/**
 * Creates and returns a deep copy of the given SpeciesReference_t
 * structure.
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return a (deep) copy of this SpeciesReference_t.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
SpeciesReference_t *
SpeciesReference_clone (const SpeciesReference_t *sr);


/**
 * Initializes the attributes of the given SpeciesReference_t structure to
 * their defaults:
 *
 * @li stoichiometry is set to @c 1
 * @li denominator is set to @c 1
 *
 * This function has no effect if the SpeciesReference_t structure is a
 * modifer (see SpeciesReference_isModifier()).
 *
 * @param sr The SpeciesReference_t structure to use.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
void
SpeciesReference_initDefaults (SpeciesReference_t *sr);


/**
 * Returns a list of XMLNamespaces_t associated with this SpeciesReference_t
 * structure.
 *
 * @param sr the SpeciesReference_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
SpeciesReference_getNamespaces(SpeciesReference_t *sr);


/**
 * Predicate returning @c true or @c false depending on whether the
 * given SpeciesReference_t structure is a modifier.
 * 
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return nonzero if this SpeciesReference_t represents a modifier
 * species, zero (0)if it is a plain SpeciesReference_t.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_isModifier (const SpeciesReference_t *sr);


/**
 * Get the value of the "id" attribute of the given SpeciesReference_t
 * structure.
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return the identifier of the SpeciesReference_t instance.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
const char *
SpeciesReference_getId (const SpeciesReference_t *sr);


/**
 * Get the value of the "name" attribute of the given SpeciesReference_t
 * structure.
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return the name of the SpeciesReference_t instance.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
const char *
SpeciesReference_getName (const SpeciesReference_t *sr);


/**
 * Get the value of the "species" attribute of the given SpeciesReference_t
 * structure.
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return the "species" attribute value
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
const char *
SpeciesReference_getSpecies (const SpeciesReference_t *sr);


/**
 * Get the value of the "stoichiometry" attribute of the given
 * SpeciesReference_t structure.
 *
 * This function returns zero if the SpeciesReference_t structure is a
 * Modifer (see SpeciesReference_isModifier()).
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return the "stoichiometry" attribute value
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
double
SpeciesReference_getStoichiometry (const SpeciesReference_t *sr);


/**
 * Get the content of the "stoichiometryMath" subelement of the given
 * SpeciesReference_t structure.
 *
 * This function returns NULL if the SpeciesReference_t structure is a
 * Modifer (see SpeciesReference_isModifier()).
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return the stoichiometryMath of this SpeciesReference_t.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
StoichiometryMath_t *
SpeciesReference_getStoichiometryMath (SpeciesReference_t *sr);


/**
 * Get the value of the "denominator" attribute, for the case of a
 * rational-numbered stoichiometry or a model in SBML Level 1.
 *
 * The "denominator" attribute is only actually written out in the case of
 * an SBML Level 1 model.  In SBML Level 2, rational-number stoichiometries
 * are written as MathML elements in the "stoichiometryMath" subelement.
 * However, as a convenience to users, libSBML allows the creation and
 * manipulation of rational-number stoichiometries by supplying the
 * numerator and denominator directly rather than having to manually create
 * an ASTNode_t structure.  LibSBML will write out the appropriate constructs
 * (either a combination of "stoichiometry" and "denominator" in the case
 * of SBML Level 1, or a "stoichiometryMath" subelement in the case of SBML
 * Level 2).
 *
 * This function returns 0 if the SpeciesReference_t structure is a Modifer (see
 * SpeciesReference_isModifier()).
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return the denominator of this SpeciesReference_t.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_getDenominator (const SpeciesReference_t *sr);


/**
 * Get the value of the "constant" attribute.
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return the constant attribute of this SpeciesReference_t.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_getConstant (const SpeciesReference_t *sr);


/**
 * Predicate returning nonzero (for true) or zero (for false) depending on
 * whether the "id" attribute of the given SpeciesReference_t structure is
 * set.
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return nonzero if the "id" attribute of given SpeciesReference_t
 * structure is set, zero (0) otherwise.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_isSetId (const SpeciesReference_t *sr);


/**
 * Predicate returning nonzero (for true) or zero (for false) depending on
 * whether the "name" attribute of the given SpeciesReference_t
 * structure is set.
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return nonzero if the "name" attribute of given SpeciesReference_t
 * structure is set, zero (0) otherwise.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_isSetName (const SpeciesReference_t *sr);


/**
 * Predicate returning nonzero (for true) or zero (for false) depending on
 * whether the "species" attribute of the given SpeciesReference_t
 * structure is set.
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return nonzero if the "species" attribute of given SpeciesReference_t
 * structure is set, zero (0) otherwise.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_isSetSpecies (const SpeciesReference_t *sr);


/**
 * Predicate returning nonzero (for true) or zero (for false) depending on
 * whether the "stoichiometryMath" subelement of the given
 * SpeciesReference_t structure is non-empty.
 *
 * This function returns false if the SpeciesReference_t structure is a
 * Modifer (see SpeciesReference_isModifier()).
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return nonzero if the "stoichiometryMath" subelement has content, zero
 * (0) otherwise.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_isSetStoichiometryMath (const SpeciesReference_t *sr);


/**
 * Predicate returning nonzero (for true) or zero (for false) depending on
 * whether the "stoichiometry" attribute of the given SpeciesReference_t structure is
 * set.
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return nonzero if the "stoichiometry" attribute of given SpeciesReference_t
 * structure is set, zero (0) otherwise.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_isSetStoichiometry (const SpeciesReference_t *sr);


/**
 * Predicate returning nonzero (for true) or zero (for false) depending on
 * whether the "constant" attribute of the given SpeciesReference_t structure is
 * set.
 *
 * @param sr The SpeciesReference_t structure to use.
 * 
 * @return nonzero if the "constant" attribute of given SpeciesReference_t
 * structure is set, zero (0) otherwise.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_isSetConstant (const SpeciesReference_t *sr);


/**
 * Sets the value of the "id" attribute of the given SpeciesReference_t
 * structure.
 *
 * The string in @p sid will be copied.
 *
 * @param sr The SpeciesReference_t structure to use.
 *
 * @param sid The identifier string that will be copied and assigned as the
 * "id" attribute value.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "id" attribute.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_setId (SpeciesReference_t *sr, const char *sid);


/**
 * Sets the value of the "name" attribute of the given SpeciesReference_t
 * structure.
 *
 * The string in @p sid will be copied.
 *
 * @param sr The SpeciesReference_t structure to use.
 *
 * @param name The identifier string that will be copied and assigned as the
 * "name" attribute value.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @note Using this function with the name set to NULL is equivalent to
 * unsetting the "name" attribute.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_setName (SpeciesReference_t *sr, const char *name);


/**
 * Sets the value of the "species" attribute of the given SpeciesReference_t
 * structure.
 *
 * The string in @p sid will be copied.
 *
 * @param sr The SpeciesReference_t structure to use.
 *
 * @param sid The identifier string that will be copied and assigned as the
 * "species" attribute value.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with an id of NULL is equivalent to
 * unsetting the "species" attribute.
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_setSpecies (SpeciesReference_t *sr, const char *sid);


/**
 * Sets the value of the "stoichiometry" attribute of the given
 * SpeciesReference_t structure.
 *
 * This function has no effect if the SpeciesReference_t structure is a
 * Modifer (see SpeciesReference_isModifier()).
 *
 * @param sr The SpeciesReference_t structure to use.
 *
 * @param value The value to assign to the "stoichiometry" attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_setStoichiometry (SpeciesReference_t *sr, double value);


/**
 * Creates a new, empty StoichiometryMath_t structure, adds it to the
 * @p sr SpeciesReference_t, and returns it.
 *
 * @return the newly created StoichiometryMath_t structure instance
 *
 * @see Reaction_addReactant()
 * @see Reaction_addProduct()
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
StoichiometryMath_t *
SpeciesReference_createStoichiometryMath (SpeciesReference_t *sr);


/**
 * Sets the content of the "stoichiometryMath" subelement of the given
 * SpeciesReference_t structure.
 *
 * This function has no effect if the SpeciesReference_t structure is a
 * Modifer (see SpeciesReference_isModifier()).
 *
 * @param sr The SpeciesReference_t structure to use.
 *
 * @param math The StoichiometryMath_t structure to use in the given SpeciesReference_t.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_setStoichiometryMath (  SpeciesReference_t *sr
                                       , const StoichiometryMath_t    *math );


/**
 * Sets the value of the "denominator" attribute of the given
 * SpeciesReference_t structure.
 *
 * The "denominator" attribute is only actually written out in the case of
 * an SBML Level 1 model.  In SBML Level 2, rational-number stoichiometries
 * are written as MathML elements in the "stoichiometryMath" subelement.
 * However, as a convenience to users, libSBML allows the creation and
 * manipulation of rational-number stoichiometries by supplying the
 * numerator and denominator directly rather than having to manually create
 * an ASTNode_t structure.  LibSBML will write out the appropriate constructs
 * (either a combination of "stoichiometry" and "denominator" in the case
 * of SBML Level 1, or a "stoichiometryMath" subelement in the case of SBML
 * Level 2).
 *
 * This function has no effect if the SpeciesReference_t structure is a
 * Modifer (see SpeciesReference_isModifier()).
 *
 * @param sr The SpeciesReference_t structure to use.
 *
 * @param value The value to assign to the "denominator" attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_setDenominator (SpeciesReference_t *sr, int value);


/**
 * Assign the "constant" attribute of a SpeciesReference_t structure.
 *
 * @param sr the SpeciesReference_t structure to set.
 * @param value the value to assign as the "constant" attribute
 * of the SpeciesReference_t, either zero for false or nonzero for true.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_setConstant (SpeciesReference_t *sr, int value);


/**
 * Unsets the value of the "id" attribute of the given SpeciesReference_t
 * structure.
 *
 * @param sr The SpeciesReference_t structure to use.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_unsetId (SpeciesReference_t *sr);


/**
 * Unsets the value of the "name" attribute of the given SpeciesReference_t
 * structure.
 *
 * @param sr The SpeciesReference_t structure to use.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_unsetName (SpeciesReference_t *sr);


/**
 * Unsets the content of the "stoichiometryMath" subelement of the given
 * SpeciesReference_t structure.
 *
 * This function has no effect if the SpeciesReference_t structure is a
 * Modifer (see SpeciesReference_isModifier()).
 *
 * @param sr The SpeciesReference_t structure to use.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_unsetStoichiometryMath (SpeciesReference_t *sr);


/**
 * Unsets the content of the "stoichiometry" attribute of the given
 * SpeciesReference_t structure.
 *
 * This function has no effect if the SpeciesReference_t structure is a
 * Modifer (see SpeciesReference_isModifier()).
 *
 * @param sr The SpeciesReference_t structure to use.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_unsetStoichiometry (SpeciesReference_t *sr);


/**
  * Predicate returning @c true or @c false depending on whether
  * all the required attributes for this SpeciesReference_t structure
  * have been set.
  *
  * The required attributes for a SpeciesReference_t structure are:
  * @li species
  * @li constant (in L3 only)
  *
  * @param sr the SpeciesReference_t structure to check.
  *
  * @return a true if all the required
  * attributes for this object have been defined, false otherwise.
  *
 * @memberof SpeciesReference_t
 */
LIBSBML_EXTERN
int
SpeciesReference_hasRequiredAttributes (SpeciesReference_t *sr);


/**
 * Returns the SpeciesReference_t structure having a given identifier.
 *
 * @param lo the ListOfSpeciesReferences_t structure to search.
 * @param sid the "id" attribute value being sought.
 *
 * @return item in the @p lo ListOfSpeciesReferences with the given @p sid or a
 * null pointer if no such item exists.
 *
 * @see ListOf_t
 *
 * @memberof ListOfSpeciesReferences_t
 */
LIBSBML_EXTERN
SpeciesReference_t *
ListOfSpeciesReferences_getById (ListOf_t *lo, const char *sid);


/**
 * Removes a SpeciesReference_t structure based on its identifier.
 *
 * The caller owns the returned item and is responsible for deleting it.
 *
 * @param lo the list of SpeciesReference_t structures to search.
 * @param sid the "id" attribute value of the structure to remove
 *
 * @return The SpeciesReference_t structure removed, or a null pointer if no such
 * item exists in @p lo.
 *
 * @see ListOf_t
 *
 * @memberof ListOfSpeciesReferences_t
 */
LIBSBML_EXTERN
SpeciesReference_t *
ListOfSpeciesReferences_removeById (ListOf_t *lo, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */

#ifndef LIBSBML_USE_STRICT_INCLUDES
#include <sbml/ModifierSpeciesReference.h>
#endif 

#endif  /* SpeciesReference_h */
