/**
 * @file    KineticLaw.h
 * @brief   Definition of KineticLaw
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
 * @class KineticLaw
 * @sbmlbrief{core} The rate expression for an SBML reaction.
 *
 * An object of class KineticLaw is used to describe the rate at which the
 * process defined by a given Reaction takes place.  KineticLaw has
 * subelements called "math" (for MathML content) and "listOfParameters"
 * (of class ListOfParameters), in addition to the attributes and
 * subelements it inherits from SBase.
 *
 * KineticLaw's "math" subelement for holding a MathML formula defines the
 * rate of the reaction.  The formula may refer to other entities in a
 * model as well as local parameter definitions within the scope of the
 * Reaction (see below).  It is important to keep in mind, however, that
 * the only Species identifiers that can be used in this formula are those
 * declared in the lists of reactants, products and modifiers in the
 * Reaction structure.  (In other words, before a species can be referenced
 * in the KineticLaw, it must be declared in one of those lists.)
 *
 * KineticLaw provides a way to define @em local parameters whose
 * identifiers can be used in the "math" formula of that KineticLaw
 * instance.  Prior to SBML Level&nbsp;3, these parameter definitions are
 * stored inside a "listOfParameters" subelement containing Parameter
 * objects; in SBML Level&nbsp;3, this is achieved using a specialized
 * object class called LocalParameter and the containing subelement is
 * called "listOfLocalParameters".  In both cases, the parameters so
 * defined are only visible within the KineticLaw; they cannot be accessed
 * outside.  A local parameter within one reaction is not visible from
 * within another reaction, nor is it visible to any other construct
 * outside of the KineticLaw in which it is defined.  In addition, another
 * important feature is that if such a Parameter (or in Level&nbsp;3,
 * LocalParameter) object has the same identifier as another object in the
 * scope of the enclosing Model, the definition inside the KineticLaw takes
 * precedence.  In other words, within the KineticLaw's "math" formula,
 * references to local parameter identifiers <strong>shadow any identical
 * global identifiers</strong>.
 *
 * The values of local parameters defined within KineticLaw objects cannot
 * change.  In SBML Level&nbsp;3, this quality is built into the
 * LocalParameter construct.  In Level&nbsp;2, where the same kind of
 * Parameter object class is used as for global parameters, the Parameter
 * objects' "constant" attribute must always have a value of @c true
 * (either explicitly or left to its default value).
 *
 * 
 * @section shadowing-warning A warning about identifier shadowing
 *
 * A common misconception is that different classes of objects (e.g.,
 * species, compartments, parameters) in SBML have different identifier
 * scopes.  They do not.  The implication is that if a KineticLaw's local
 * parameter definition uses an identifier identical to @em any other
 * identifier defined in the model outside the KineticLaw, even if the
 * other identifier does @em not belong to a parameter type of object, the
 * local parameter's identifier takes precedence within that KineticLaw's
 * "math" formula.  It is not an error in SBML for identifiers to shadow
 * each other this way, but can lead to confusing and subtle errors.
 *
 * 
 * @section version-diffs SBML Level/Version differences
 *
 * In SBML Level&nbsp;2 Version&nbsp;1, the SBML specification
 * included two additional attributes on KineticLaw called "substanceUnits"
 * and "timeUnits".  They were removed beginning with SBML Level&nbsp;2
 * Version&nbsp;2 because further research determined they introduced many
 * problems.  The most significant problem was that their use could easily
 * lead to the creation of valid models whose reactions nevertheless could
 * not be integrated into a system of equations without outside knowledge
 * for converting the quantities used.  Examination of real-life models
 * revealed that a common reason for using "substanceUnits" on KineticLaw
 * was to set the units of all reactions to the same set of substance
 * units, something that is better achieved by using UnitDefinition to
 * redefine @c "substance" for the whole Model.
 *
 * As mentioned above, in SBML Level&nbsp;2 Versions 2&ndash;4, local
 * parameters are of class Parameter.  In SBML Level&nbsp;3, the class of
 * object is LocalParameter.
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_kineticlaw_units
 *
 * @par
 * The units are calculated based on the mathematical expression in the
 * KineticLaw and the model quantities referenced by <code>&lt;ci&gt;</code>
 * elements used within that expression.  The
 * @if java KineticLaw::getDerivedUnitDefinition()@else getDerivedUnitDefinition()@endif@~
 * method returns the calculated units.
 *
 * <!---------------------------------------------------------------------- -->
 * @class doc_warning_kineticlaw_math_literals
 *
 * @warning <span class="warning">Note that it is possible the "math"
 * expression in the KineticLaw contains pure numbers or parameters with
 * undeclared units.  In those cases, it is not possible to calculate the
 * units of the overall expression without making assumptions.  LibSBML does
 * not make assumptions about the units, and
 * KineticLaw::getDerivedUnitDefinition() returns the units as far as it is
 * able to determine them.  For example, in an expression <em>X + Y</em>, if
 * <em>X</em> has unambiguously-defined units and <em>Y</em> does not, it
 * will return the units of <em>X</em>.  <strong>It is important that callers
 * also invoke the method</strong>
 * KineticLaw::containsUndeclaredUnits()<strong>to determine whether this
 * situation holds</strong>.  Callers may wish to take suitable actions in
 * those scenarios.</span>
 *
 * <!---------------------------------------------------------------------- -->
 * @class doc_note_timeunits_substanceunits
 *
 * @note The attributes "timeUnits" and "substanceUnits" are present only
 * in SBML Level&nbsp;2 Version&nbsp;1.  In SBML Level&nbsp;2
 * Version&nbsp;2, the "timeUnits" and "substanceUnits" attributes were
 * removed.  For compatibility with new versions of SBML, users are
 * cautioned to avoid these attributes.
 *
 */

#ifndef KineticLaw_h
#define KineticLaw_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/Parameter.h>
#include <sbml/LocalParameter.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTNode;
class Parameter;
class SBMLVisitor;
class LocalParameter;


class LIBSBML_EXTERN KineticLaw : public SBase
{
public:

  /**
   * Creates a new KineticLaw using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this KineticLaw
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * KineticLaw
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  KineticLaw (unsigned int level, unsigned int version);


  /**
   * Creates a new KineticLaw using the given SBMLNamespaces object
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
  KineticLaw (SBMLNamespaces* sbmlns);


  /**
   * Destroys this KineticLaw.
   */
  virtual ~KineticLaw ();


  /**
   * Copy constructor; creates a copy of this KineticLaw.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  KineticLaw (const KineticLaw& orig);


  /**
   * Assignment operator for KineticLaw.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  KineticLaw& operator=(const KineticLaw& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of KineticLaw.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this KineticLaw object.
   *
   * @return the (deep) copy of this KineticLaw object.
   */
  virtual KineticLaw* clone () const;


   /**
   * Returns the first child element found that has the given @p id in the
   * model-wide SId namespace, or @c NULL if no such object is found.
   *
   * @param id string representing the id of objects to find.
   *
   * @return pointer to the first element found with the given @p id.
   */
  virtual SBase* getElementBySId(const std::string& id);
  
  
  /**
   * Returns the first child element it can find with the given @p metaid, or
   * @c NULL if no such object is found.
   *
   * @param metaid string representing the metaid of objects to find
   *
   * @return pointer to the first element found with the given @p metaid.
   */
  virtual SBase* getElementByMetaId(const std::string& metaid);
  
  
  /**
   * Returns a List of all child SBase objects, including those nested to an
   * arbitrary depth
   *
   * @return a List of pointers to all children objects.
   */
  virtual List* getAllElements(ElementFilter* filter=NULL);
  
  
  /**
   * Returns the mathematical formula for this KineticLaw object and return
   * it as as a text string.
   *
   * This is fundamentally equivalent to
   * @if java KineticLaw::getMath()@else getMath()@endif.
   * This variant is provided principally for compatibility compatibility
   * with SBML Level&nbsp;1.
   * 
   * @return a string representing the formula of this KineticLaw.
   *
   * @note @htmlinclude level-1-uses-text-string-math.html
   *
   * @see getMath()
   */
  const std::string& getFormula () const;


  /**
   * Returns the mathematical formula for this KineticLaw object and return
   * it as as an AST.
   *
   * This is fundamentally equivalent to
   * @if java KineticLaw::getFormula()@else getFormula()@endif.
   * The latter is provided principally for compatibility compatibility
   * with SBML Level&nbsp;1, which represented mathematical formulas in
   * text-string form.
   * 
   * @return the ASTNode representation of the mathematical formula.
   *
   * @see getFormula()
   */
  const ASTNode* getMath () const;


  /**
   * (SBML Level&nbsp;2 Version&nbsp;1 only) Returns the value of the
   * "timeUnits" attribute of this KineticLaw object.
   *
   * @return the "timeUnits" attribute value.
   *
   * @copydetails doc_note_timeunits_substanceunits 
   */
  const std::string& getTimeUnits () const;


  /**
   * (SBML Level&nbsp;2 Version&nbsp;1 only) Returns the value of the
   * "substanceUnits" attribute of this KineticLaw object.
   *
   * @return the "substanceUnits" attribute value.
   *
   * @copydetails doc_note_timeunits_substanceunits 
   */
  const std::string& getSubstanceUnits () const;


  /**
   * Predicate returning @c true if this KineticLaw's "formula" attribute is
   * set.
   *
   * This is functionally identical to the method
   * @if java KineticLaw::isSetMath()@else isSetMath()@endif.  It is
   * provided in order to mirror the parallel between
   * @if java KineticLaw::getFormula()@else getFormula()@endif@~ and
   * @if java KineticLaw::getMath()@else getMath()@endif.
   *
   * @return @c true if the formula (meaning the @c math subelement) of
   * this KineticLaw is set, @c false otherwise.
   *
   * @note @htmlinclude level-1-uses-text-string-math.html
   *
   * @see isSetMath()
   */  
  bool isSetFormula () const;


  /**
   * Predicate returning @c true if this Kinetic's "math" subelement is set.
   *
   * This is identical to the method
   * @if java KineticLaw::isSetFormula()@else isSetFormula()@endif.
   * It is provided in order to mirror the parallel between
   * @if java KineticLaw::getFormula()@else getFormula()@endif@~ and
   * @if java KineticLaw::getMath()@else getMath()@endif.
   * 
   * @return @c true if the formula (meaning the @c math subelement) of
   * this KineticLaw is set, @c false otherwise.
   * 
   * @see isSetFormula()
   */
  bool isSetMath () const;


  /**
   * (SBML Level&nbsp;2 Version&nbsp;1 only) Predicate returning @c true if
   * this SpeciesReference's "timeUnits" attribute is set.
   *
   * @return @c true if the "timeUnits" attribute of this KineticLaw object
   * is set, @c false otherwise.
   *
   * @copydetails doc_note_timeunits_substanceunits 
   */
  bool isSetTimeUnits () const;


  /**
   * (SBML Level&nbsp;2 Version&nbsp;1 only) Predicate returning @c true if
   * this SpeciesReference's "substanceUnits" attribute is set.
   *
   * @return @c true if the "substanceUnits" attribute of this KineticLaw
   * object is set, @c false otherwise.
   *
   * @copydetails doc_note_timeunits_substanceunits 
   */
  bool isSetSubstanceUnits () const;


  /**
   * Sets the mathematical expression of this KineticLaw instance to the
   * given @p formula.
   *
   * The given @p formula string is copied.  Internally, libSBML stores the
   * mathematical expression as an ASTNode.
   *
   * @param formula the mathematical expression to use, represented in
   * text-string form.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   *
   * @note @htmlinclude level-1-uses-text-string-math.html
   *
   * @see setMath(const ASTNode* math)
   */
  int setFormula (const std::string& formula);


  /**
   * Sets the mathematical expression of this KineticLaw instance to a copy
   * of the given ASTNode.
   *
   * This is fundamentally identical to
   * @if java KineticLaw::setFormula(String formula)@else getFormula()@endif.
   * The latter is provided principally for compatibility compatibility with
   * SBML Level&nbsp;1, which represented mathematical formulas in text-string
   * form.
   *
   * @param math an ASTNode representing a formula tree.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   *
   * @see setFormula(const std::string& formula)
   */
  int setMath (const ASTNode* math);


  /**
   * (SBML Level&nbsp;2 Version&nbsp;1 only) Sets the "timeUnits" attribute
   * of this KineticLaw object to a copy of the identifier in @p sid.
   *
   * @param sid the identifier of the units to use.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @copydetails doc_note_timeunits_substanceunits 
   */
  int setTimeUnits (const std::string& sid);


  /**
   * (SBML Level&nbsp;2 Version&nbsp;1 only) Sets the "substanceUnits"
   * attribute of this KineticLaw object to a copy of the identifier given
   * in @p sid.
   *
   * @param sid the identifier of the units to use.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @copydetails doc_note_timeunits_substanceunits 
   */
  int setSubstanceUnits (const std::string& sid);


  /**
   * (SBML Level&nbsp;2 Version&nbsp;1 only) Unsets the "timeUnits"
   * attribugte of this KineticLaw object.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @copydetails doc_note_timeunits_substanceunits 
   */
  int unsetTimeUnits ();


  /**
   * (SBML Level&nbsp;2 Version&nbsp;1 only) Unsets the "substanceUnits"
   * attribute of this KineticLaw object.
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @copydetails doc_note_timeunits_substanceunits 
   */
  int unsetSubstanceUnits ();


  /**
   * Adds a copy of the given Parameter object to the list of local
   * parameters in this KineticLaw.
   *
   * @param p the Parameter to add
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @copydetails doc_note_object_is_copied 
   *
   * @see createParameter()
   */
  int addParameter (const Parameter* p);


  /**
   * Adds a copy of the given LocalParameter object to the list of local
   * parameters in this KineticLaw.
   *
   * @param p the LocalParameter to add
   *
   * @return integer value indicating success/failure of the
   * function. The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @copydetails doc_note_object_is_copied 
   *
   * @see createLocalParameter()
   */
  int addLocalParameter (const LocalParameter* p);


  /**
   * Creates a new Parameter object, adds it to this KineticLaw's list of
   * local parameters, and returns the Parameter object created.
   *
   * @return a new Parameter object instance
   *
   * @see addParameter(const Parameter* p)
   */
  Parameter* createParameter ();


  /**
   * Creates a new LocalParameter object, adds it to this KineticLaw's list
   * of local parameters, and returns the LocalParameter object created.
   *
   * @return a new LocalParameter object instance
   *
   * @see addLocalParameter(const LocalParameter* p)
   */
  LocalParameter* createLocalParameter ();


  /**
   * Returns the list of local parameters in this KineticLaw object.
   * 
   * @return the list of Parameters for this KineticLaw.
   */
  const ListOfParameters* getListOfParameters () const;


  /**
   * Returns the list of local parameters in this KineticLaw object.
   * 
   * @return the list of Parameters for this KineticLaw.
   */
  ListOfParameters* getListOfParameters ();


  /**
   * Returns the list of local parameters in this KineticLaw object.
   * 
   * @return the list of LocalParameters for this KineticLaw.
   */
  const ListOfLocalParameters* getListOfLocalParameters () const;


  /**
   * Returns the list of local parameters in this KineticLaw object.
   * 
   * @return the list of LocalParameters for this KineticLaw.
   */
  ListOfLocalParameters* getListOfLocalParameters ();


  /**
   * Returns the nth Parameter object in the list of local parameters in
   * this KineticLaw instance.
   *
   * @param n the index of the Parameter object sought
   * 
   * @return the nth Parameter of this KineticLaw.
   */
  const Parameter* getParameter (unsigned int n) const;


  /**
   * Returns the nth Parameter object in the list of local parameters in
   * this KineticLaw instance.
   *
   * @param n the index of the Parameter object sought
   * 
   * @return the nth Parameter of this KineticLaw.
   */
  Parameter* getParameter (unsigned int n);


  /**
   * Returns the nth LocalParameter object in the list of local parameters in
   * this KineticLaw instance.
   *
   * @param n the index of the LocalParameter object sought
   * 
   * @return the nth LocalParameter of this KineticLaw.
   */
  const LocalParameter* getLocalParameter (unsigned int n) const;


  /**
   * Returns the nth LocalParameter object in the list of local parameters in
   * this KineticLaw instance.
   *
   * @param n the index of the LocalParameter object sought
   * 
   * @return the nth LocalParameter of this KineticLaw.
   */
  LocalParameter* getLocalParameter (unsigned int n);


  /**
   * Returns a local parameter based on its identifier.
   *
   * @param sid the identifier of the Parameter being sought.
   * 
   * @return the Parameter object in this KineticLaw instace having the
   * given "id", or @c NULL if no such Parameter exists.
   */
  const Parameter* getParameter (const std::string& sid) const;


  /**
   * Returns a local parameter based on its identifier.
   *
   * @param sid the identifier of the Parameter being sought.
   * 
   * @return the Parameter object in this KineticLaw instace having the
   * given "id", or @c NULL if no such Parameter exists.
   */
  Parameter* getParameter (const std::string& sid);


  /**
   * Returns a local parameter based on its identifier.
   *
   * @param sid the identifier of the LocalParameter being sought.
   * 
   * @return the LocalParameter object in this KineticLaw instace having the
   * given "id", or @c NULL if no such LocalParameter exists.
   */
  const LocalParameter* getLocalParameter (const std::string& sid) const;


  /**
   * Returns a local parameter based on its identifier.
   *
   * @param sid the identifier of the LocalParameter being sought.
   * 
   * @return the LocalParameter object in this KineticLaw instace having the
   * given "id", or @c NULL if no such LocalParameter exists.
   */
  LocalParameter* getLocalParameter (const std::string& sid);


  /**
   * Returns the number of local parameters in this KineticLaw instance.
   * 
   * @return the number of Parameters in this KineticLaw.
   */
  unsigned int getNumParameters () const;


  /**
   * Returns the number of local parameters in this KineticLaw instance.
   * 
   * @return the number of LocalParameters in this KineticLaw.
   */
  unsigned int getNumLocalParameters () const;


  /**
   * Calculates and returns a UnitDefinition that expresses the units of
   * measurement assumed for the "math" expression of this KineticLaw.
   *
   * @copydetails doc_kineticlaw_units 
   *
   * @copydetails doc_note_unit_inference_depends_on_model 
   *
   * @copydetails doc_warning_kineticlaw_math_literals
   * 
   * @return a UnitDefinition that expresses the units of the math 
   * expression of this KineticLaw, or @c NULL if one cannot be constructed.
   *
   * @see containsUndeclaredUnits()
   */
  UnitDefinition * getDerivedUnitDefinition();


  /**
   * Calculates and returns a UnitDefinition that expresses the units of
   * measurement assumed for the "math" expression of this KineticLaw.
   *
   * @copydetails doc_kineticlaw_units 
   *
   * @copydetails doc_note_unit_inference_depends_on_model 
   *
   * @copydetails doc_warning_kineticlaw_math_literals
   *
   * @return a UnitDefinition that expresses the units of the math 
   * expression of this KineticLaw, or @c NULL if one cannot be constructed.
   *
   * @see containsUndeclaredUnits()
   */
  const UnitDefinition * getDerivedUnitDefinition() const;


  /**
   * Predicate returning @c true if the math expression of this KineticLaw
   * contains parameters/numbers with undeclared units.
   * 
   * @return @c true if the math expression of this KineticLaw
   * includes parameters/numbers 
   * with undeclared units, @c false otherwise.
   *
   * @note A return value of @c true indicates that the UnitDefinition
   * returned by
   * @if java KineticLaw::getDerivedUnitDefinition()@else getDerivedUnitDefinition()@endif@~
   * may not accurately represent the units of the expression.
   *
   * @see getDerivedUnitDefinition()
   */
  bool containsUndeclaredUnits();


  /**
   * Predicate returning @c true if the math expression of this KineticLaw
   * contains parameters/numbers with undeclared units.
   * 
   * @return @c true if the math expression of this KineticLaw
   * includes parameters/numbers 
   * with undeclared units, @c false otherwise.
   *
   * @note A return value of @c true indicates that the UnitDefinition
   * returned by
   * @if java KineticLaw::getDerivedUnitDefinition()@else getDerivedUnitDefinition()@endif@~
   * may not accurately represent the units of the expression.
   *
   * @see getDerivedUnitDefinition()
   */
  bool containsUndeclaredUnits() const;


  /**
   * Removes the nth Parameter object in the list of local parameters 
   * in this KineticLaw instance and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the Parameter object to remove
   * 
   * @return the Parameter object removed.  As mentioned above, 
   * the caller owns the returned item. @c NULL is returned if the given index 
   * is out of range.
   */
  Parameter* removeParameter (unsigned int n);


  /**
   * Removes the nth LocalParameter object in the list of local parameters 
   * in this KineticLaw instance and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the LocalParameter object to remove
   * 
   * @return the LocalParameter object removed.  As mentioned above, 
   * the caller owns the returned item. @c NULL is returned if the given index 
   * is out of range.
   */
  LocalParameter* removeLocalParameter (unsigned int n);


  /**
   * Removes a Parameter object with the given identifier in the list of
   * local parameters in this KineticLaw instance and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param sid the identifier of the Parameter to remove
   * 
   * @return the Parameter object removed.  As mentioned above, the 
   * caller owns the returned object. @c NULL is returned if no Parameter
   * object with the identifier exists in this KineticLaw instance.
   */
  Parameter* removeParameter (const std::string& sid);


  /**
   * Removes a LocalParameter object with the given identifier in the list of
   * local parameters in this KineticLaw instance and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param sid the identifier of the LocalParameter to remove
   * 
   * @return the LocalParameter object removed.  As mentioned above, the 
   * caller owns the returned object. @c NULL is returned if no LocalParameter
   * object with the identifier exists in this KineticLaw instance.
   */
  LocalParameter* removeLocalParameter (const std::string& sid);


  /** @cond doxygenLibsbmlInternal */
  /**
   * Sets the parent SBMLDocument of this SBML object.
   *
   * @param d the SBMLDocument to use.
   */
  virtual void setSBMLDocument (SBMLDocument* d);

  /**
   * Sets this SBML object to child SBML objects (if any).
   * (Creates a child-parent relationship by the parent)
   *
   * Subclasses must override this function if they define one ore more child
   * elements.  Basically, this function needs to be called in constructor,
   * copy constructor and assignment operator.
   *
   * @see setSBMLDocument
   * @see enablePackageInternal
   */
  virtual void connectToChild ();


  /**
   * Enables/Disables the given package with this element and child
   * elements (if any).
   * (This is an internal implementation for enablePackage function)
   *
   * @note Subclasses of the SBML Core package in which one or more child
   * elements are defined must override this function.
   */
  virtual void enablePackageInternal(const std::string& pkgURI,
                                     const std::string& pkgPrefix, bool flag);
  /** @endcond */


  /**
   * Returns the libSBML type code for this %SBML object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_KINETIC_LAW, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for Species, is
   * always @c "kineticLaw".
   * 
   * @return the name of this element, i.e., @c "kineticLaw".
   */
  virtual const std::string& getElementName () const;


  /** @cond doxygenLibsbmlInternal */
  /**
   * Return the position of this element.
   *
   * @return the ordinal position of the element with respect to its
   * siblings or -1 (default) to indicate the position is not significant.
   */
  virtual int getElementPosition () const;
  /** @endcond */


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
   * KineticLaw object have been set.
   *
   * The required attributes for a KineticLaw object are:
   * @li "formula" (SBML Level&nbsp;1 only)
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const ;


  /**
   * Predicate returning @c true if all the required elements for this
   * KineticLaw object have been set.
   *
   * @note The required elements for a KineticLaw object are:
   * @li "math"
   *
   * @return a boolean value indicating whether all the required
   * elements for this object have been defined.
   */
  virtual bool hasRequiredElements() const ;


  /**
   * Finds this KineticLaw's Reaction parent and calls unsetKineticLaw() on
   * it, indirectly deleting itself.
   *
   * Overridden from the SBase function since the parent is not a ListOf.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  virtual int removeFromParentAndDelete();


  /**
   * @copydoc doc_renamesidref_common
   */
  virtual void renameSIdRefs(const std::string& oldid, const std::string& newid);


  /**
   * @copydoc doc_renameunitsidref_common
   */
  virtual void renameUnitSIdRefs(const std::string& oldid, const std::string& newid);


  /** @cond doxygenLibsbmlInternal */
  /*
   * Function to set/get an identifier for unit checking.
   */
  std::string getInternalId() const { return mInternalId; };
  void setInternalId(std::string id) { mInternalId = id; };
  /** @endcond */

  /** @cond doxygenLibsbmlInternal */
  /**
   * Replace all nodes with the name 'id' from the child 'math' object with the provided function. 
   *
   */
  virtual void replaceSIDWithFunction(const std::string& id, const ASTNode* function);
  /** @endcond */

  /** @cond doxygenLibsbmlInternal */
  /**
   * If this reaction id matches the provided 'id' string, replace the 'math' object with the function (existing/function). 
   */
  virtual void divideAssignmentsToSIdByFunction(const std::string& id, const ASTNode* function);
  /** @endcond */

  /** @cond doxygenLibsbmlInternal */
  /**
   * If this assignment assigns a value to the 'id' element, replace the 'math' object with the function (existing*function). 
   */
  virtual void multiplyAssignmentsToSIdByFunction(const std::string& id, const ASTNode* function);
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


  void readL1Attributes (const XMLAttributes& attributes);

  void readL2Attributes (const XMLAttributes& attributes);
  
  void readL3Attributes (const XMLAttributes& attributes);


  /**
   * Subclasses should override this method to write their XML attributes
   * to the XMLOutputStream.  Be sure to call your parents implementation
   * of this method as well.
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;


  mutable std::string  mFormula;
  mutable ASTNode*     mMath;

  ListOfParameters  mParameters;
  ListOfLocalParameters  mLocalParameters;
  std::string       mTimeUnits;
  std::string       mSubstanceUnits;

  /* internal id used by unit checking */
  std::string mInternalId;

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

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new KineticLaw_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * KineticLaw_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * KineticLaw_t
 *
 * @return a pointer to the newly created KineticLaw_t structure.
 *
 * @note Once a KineticLaw_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the KineticLaw_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
KineticLaw_t *
KineticLaw_create (unsigned int level, unsigned int version);


/**
 * Creates a new KineticLaw_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this KineticLaw_t
 *
 * @return a pointer to the newly created KineticLaw_t structure.
 *
 * @note Once a KineticLaw_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the KineticLaw_t.  Despite this, the ability to supply the values at creation time
 * is an important aid to creating valid SBML.  Knowledge of the intended SBML
 * Level and Version determine whether it is valid to assign a particular value
 * to an attribute, or whether it is valid to add a structure to an existing
 * SBMLDocument_t.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
KineticLaw_t *
KineticLaw_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given KineticLaw_t structure.
 *
 * @param kl the KineticLaw_t structure
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
void
KineticLaw_free (KineticLaw_t *kl);


/**
 * Returns a deep copy of the given KineticLaw_t structure.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return a (deep) copy of this KineticLaw_t structure.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
KineticLaw_t *
KineticLaw_clone (const KineticLaw_t *kl);


/**
 * Returns a list of XMLNamespaces_t associated with this KineticLaw_t
 * structure.
 *
 * @param kl the KineticLaw_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
KineticLaw_getNamespaces(KineticLaw_t *kl);


/**
 * Gets the mathematical expression of this KineticLaw_t structure as a
 * formula in text-string form.
 *
 * This is fundamentally equivalent to KineticLaw_getMath().  It is
 * provided principally for compatibility with SBML Level 1.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return the formula of this KineticLaw_t structure.
 *
 * @see KineticLaw_getMath().
 *
 * @note SBML Level 1 uses a text-string format for mathematical formulas.
 * SBML Level 2 uses MathML, an XML format for representing mathematical
 * expressions.  LibSBML provides an Abstract Syntax Tree API for working
 * with mathematical expressions; this API is more powerful than working
 * with formulas directly in text form, and ASTs can be translated into
 * either MathML or the text-string syntax.  The libSBML methods that
 * accept text-string formulas directly (such as this constructor) are
 * provided for SBML Level 1 compatibility, but developers are encouraged
 * to use the AST mechanisms.  See KineticLaw_createWithMath for a
 * version that takes an ASTNode_t structure.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
const char *
KineticLaw_getFormula (const KineticLaw_t *kl);


/**
 * Gets the mathematical expression of this KineticLaw_t structure as an
 * ASTNode_t structure.
 *
 * This is fundamentally equivalent to KineticLaw_getFormula().  The latter
 * is provided principally for compatibility with SBML Level 1, which
 * represented mathematical formulas in text-string form.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return the formula in the form of an ASTNode_t structure
 *
 * @see KineticLaw_getFormula().
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
const ASTNode_t *
KineticLaw_getMath (const KineticLaw_t *kl);


/**
 * Gets the value of the "timeUnits" attribute of the given
 * KineticLaw_t structure.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return the "timeUnits" attribute value
 *
 * @warning In SBML Level 2 Version 2, the "timeUnits" and "substanceUnits"
 * attributes were removed.  For compatibility with new versions of SBML,
 * users are cautioned to avoid these attributes.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
const char *
KineticLaw_getTimeUnits (const KineticLaw_t *kl);


/**
 * Gets the value of the "substanceUnits" attribute of the given
 * KineticLaw_t structure.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return the "substanceUnits" attribute value
 *
 * @warning In SBML Level 2 Version 2, the "timeUnits" and "substanceUnits"
 * attributes were removed.  For compatibility with new versions of SBML,
 * users are cautioned to avoid these attributes.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
const char *
KineticLaw_getSubstanceUnits (const KineticLaw_t *kl);


/**
 * Predicate returning nonzero (for true) or zero (for false) depending on
 * whether the "formula" attribute of the given KineticLaw_t structure is
 * set.
 *
 * This is fundamentally equivalent to KineticLaw_isSetMath().  It is
 * provided principally for compatibility with SBML Level 1.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return nonzero (meaning true) if the formula (or equivalently the
 * "math" subelement) of the given KineticLaw_t structure is set,
 * zero (meaning false) otherwise.
 *
 * @note SBML Level 1 uses a text-string format for mathematical formulas.
 * SBML Level 2 uses MathML, an XML format for representing mathematical
 * expressions.  LibSBML provides an Abstract Syntax Tree API for working
 * with mathematical expressions; this API is more powerful than working
 * with formulas directly in text form, and ASTs can be translated into
 * either MathML or the text-string syntax.  The libSBML methods that
 * accept text-string formulas directly (such as this constructor) are
 * provided for SBML Level 1 compatibility, but developers are encouraged
 * to use the AST mechanisms.  See KineticLaw_createWithMath for a
 * version that takes an ASTNode_t structure.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int
KineticLaw_isSetFormula (const KineticLaw_t *kl);


/**
 * Predicate returning nonzero (for true) or zero (for false) depending on
 * whether the "math" subelement of the given KineticLaw_t structure is
 * set.
 *
 * This is fundamentally equivalent to KineticLaw_isSetFormula().  The
 * latter provided principally for compatibility with SBML Level 1, which
 * represented mathematical formulas in text-string form.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return nonzero (meaning true) if the "math" subelement of the given
 * KineticLaw_t structure is set, zero (meaning false) otherwise.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int
KineticLaw_isSetMath (const KineticLaw_t *kl);


/**
 * Predicate returning nonzero (for true) or zero (for false) depending on
 * whether the "timeUnits" attribute of the given KineticLaw_t structure is
 * set.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return nonzero (meaning true) if the "timeUnits" attribute of the given
 * KineticLaw_t structure is set, zero (meaning false) otherwise.
 *
 * @warning In SBML Level 2 Version 2, the "timeUnits" and "substanceUnits"
 * attributes were removed.  For compatibility with new versions of SBML,
 * users are cautioned to avoid these attributes.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int
KineticLaw_isSetTimeUnits (const KineticLaw_t *kl);


/**
 * Predicate returning nonzero (for true) or zero (for false) depending on
 * whether the "timeUnits" attribute of the given KineticLaw_t structure is
 * set.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return nonzero (meaning true) if the "timeUnits" attribute of the given
 * KineticLaw_t structure is set, zero (meaning false) otherwise.
 *
 * @warning In SBML Level 2 Version 2, the "timeUnits" and "substanceUnits"
 * attributes were removed.  For compatibility with new versions of SBML,
 * users are cautioned to avoid these attributes.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int
KineticLaw_isSetSubstanceUnits (const KineticLaw_t *kl);


/**
 * Sets the formula of the given KineticLaw_t structure.
 *
 * This is fundamentally equivalent to KineticLaw_setMath().  It is
 * provided principally for compatibility with SBML Level 1.
 *
 * @param kl the KineticLaw_t structure.
 *
 * @param formula the mathematical expression, in text-string form.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note SBML Level 1 uses a text-string format for mathematical formulas.
 * SBML Level 2 uses MathML, an XML format for representing mathematical
 * expressions.  LibSBML provides an Abstract Syntax Tree API for working
 * with mathematical expressions; this API is more powerful than working
 * with formulas directly in text form, and ASTs can be translated into
 * either MathML or the text-string syntax.  The libSBML methods that
 * accept text-string formulas directly (such as this constructor) are
 * provided for SBML Level 1 compatibility, but developers are encouraged
 * to use the AST mechanisms.  See KineticLaw_createWithMath for a
 * version that takes an ASTNode_t structure.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int
KineticLaw_setFormula (KineticLaw_t *kl, const char *formula);


/**
 * Sets the formula of the given KineticLaw_t structure.
 *
 * This is fundamentally equivalent to KineticLaw_setFormula().  The latter
 * provided principally for compatibility with SBML Level 1, which
 * represented mathematical formulas in text-string form.
 *
 * @param kl the KineticLaw_t structure.
 *
 * @param math an ASTNode_t structure representing the mathematical formula
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int
KineticLaw_setMath (KineticLaw_t *kl, const ASTNode_t *math);


/**
 * Sets the "timeUnits" attribute of the given KineticLaw_t structure.
 *
 * The identifier string @p sid is copied.
 *
 * @param kl the KineticLaw_t structure.
 *
 * @param sid the identifier of the units
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
 * unsetting the "timeUnits" attribute.
 *
 * @warning In SBML Level 2 Version 2, the "timeUnits" and "substanceUnits"
 * attributes were removed.  For compatibility with new versions of SBML,
 * users are cautioned to avoid these attributes.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int
KineticLaw_setTimeUnits (KineticLaw_t *kl, const char *sid);


/**
 * Sets the "substanceUnits" attribute of the given KineticLaw_t structure.
 *
 * The identifier string @p sid is copied.
 *
 * @param kl the KineticLaw_t structure.
 *
 * @param sid the identifier of the units
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
 * unsetting the "substanceUnits" attribute.
 *
 * @warning In SBML Level 2 Version 2, the "timeUnits" and "substanceUnits"
 * attributes were removed.  For compatibility with new versions of SBML,
 * users are cautioned to avoid these attributes.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int
KineticLaw_setSubstanceUnits (KineticLaw_t *kl, const char *sid);


/**
 * Unsets the "timeUnits" attribute of the given KineticLaw_t structure.
 *
 * @param kl the KineticLaw_t structure.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @warning In SBML Level 2 Version 2, the "timeUnits" and "substanceUnits"
 * attributes were removed.  For compatibility with new versions of SBML,
 * users are cautioned to avoid these attributes.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int
KineticLaw_unsetTimeUnits (KineticLaw_t *kl);


/**
 * Unsets the "substanceUnits" attribute of the given KineticLaw_t structure.
 *
 * @param kl the KineticLaw_t structure.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @warning In SBML Level 2 Version 2, the "timeUnits" and "substanceUnits"
 * attributes were removed.  For compatibility with new versions of SBML,
 * users are cautioned to avoid these attributes.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int
KineticLaw_unsetSubstanceUnits (KineticLaw_t *kl);


/**
 * Adds a copy of the given Parameter_t structure to the list of local
 * parameters in the given KineticLaw_t structure.
 *
 * @param kl the KineticLaw_t structure.
 *
 * @param p a pointer to a Parameter_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int
KineticLaw_addParameter (KineticLaw_t *kl, const Parameter_t *p);


/**
 * Adds a copy of the given LocalParameter_t structure to the list of local
 * parameters in the given KineticLaw_t structure.
 *
 * @param kl the KineticLaw_t structure.
 *
 * @param p a pointer to a LocalParameter_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int
KineticLaw_addLocalParameter (KineticLaw_t *kl, const LocalParameter_t *p);


/**
 * Creates a new Parameter_t structure, adds it to the given KineticLaw_t
 * structures's list of local parameters, and returns a pointer to the
 * Parameter_t created.
 *
 * @param kl the KineticLaw_t structure.
 *
 * @return a pointer to a Parameter_t structure
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
Parameter_t *
KineticLaw_createParameter (KineticLaw_t *kl);


/**
 * Creates a new LocalParameter_t structure, adds it to the given KineticLaw_t
 * structures's list of local parameters, and returns a pointer to the
 * Parameter_t created.
 *
 * @param kl the KineticLaw_t structure.
 *
 * @return a pointer to a LocalParameter_t structure
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
LocalParameter_t *
KineticLaw_createLocalParameter (KineticLaw_t *kl);


/**
 * Get the list of local parameters defined for the given KineticLaw_t
 * structure.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return a list of Parameters
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
ListOf_t *
KineticLaw_getListOfParameters (KineticLaw_t *kl);


/**
 * Get the list of local parameters defined for the given KineticLaw_t
 * structure.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return a list of LocalParameters
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
ListOf_t *
KineticLaw_getListOfLocalParameters (KineticLaw_t *kl);


/**
 * Get the nth parameter in the list of local parameters in the
 * given KineticLaw_t structure.
 *
 * Callers should first find out how many parameters are in the list by
 * calling KineticLaw_getNumParameters().
 *
 * @param kl the KineticLaw_t structure.
 *
 * @param n the index of the Parameter_t structure sought
 * 
 * @return a pointer to the Parameter_t structure
 *
 * @see KineticLaw_getNumParameters().
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
Parameter_t *
KineticLaw_getParameter (KineticLaw_t *kl, unsigned int n);


/**
 * Get the nth parameter in the list of local parameters in the
 * given KineticLaw_t structure.
 *
 * Callers should first find out how many parameters are in the list by
 * calling KineticLaw_getNumLocalParameters().
 *
 * @param kl the KineticLaw_t structure.
 *
 * @param n the index of the LocalParameter_t structure sought
 * 
 * @return a pointer to the LocalParameter_t structure
 *
 * @see KineticLaw_getNumLocalParameters().
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
LocalParameter_t *
KineticLaw_getLocalParameter (KineticLaw_t *kl, unsigned int n);


/**
 * Get a parameter with identifier "id" out of the list of local
 * parameters defined for the given KineticLaw_t structure.
 *
 * @param kl the KineticLaw_t structure.
 *
 * @param sid the identifier of the Parameter_t structure sought
 * 
 * @return the Parameter_t structure with the given @p id, or @c NULL if no such
 * Parameter_t exists in the given KineticLaw_t structure.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
Parameter_t *
KineticLaw_getParameterById (KineticLaw_t *kl, const char *sid);


/**
 * Get a parameter with identifier "id" out of the list of local
 * parameters defined for the given KineticLaw_t structure.
 *
 * @param kl the KineticLaw_t structure.
 *
 * @param sid the identifier of the LocalParameter_t structure sought
 * 
 * @return the LocalParameter_t structure with the given @p id, or @c NULL if no such
 * LocalParameter_t exists in the given KineticLaw_t structure.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
LocalParameter_t *
KineticLaw_getLocalParameterById (KineticLaw_t *kl, const char *sid);


/**
 * Get the number of local parameters defined in the given KineticLaw_t
 * structure.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return the number of Parameter_t structures in the given KineticLaw_t
 * structure.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
unsigned int
KineticLaw_getNumParameters (const KineticLaw_t *kl);


/**
 * Get the number of local parameters defined in the given KineticLaw_t
 * structure.
 *
 * @param kl the KineticLaw_t structure.
 * 
 * @return the number of LocalParameter_t structures in the given KineticLaw_t
 * structure.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
unsigned int
KineticLaw_getNumLocalParameters (const KineticLaw_t *kl);


/**
  * Calculates and returns a UnitDefinition_t that expresses the units
  * returned by the math expression of this KineticLaw_t.
  *
  * @return a UnitDefinition_t that expresses the units of the math 
  * expression of this KineticLaw_t.
  *
  * Note that the functionality that facilitates unit analysis depends 
  * on the model as a whole.  Thus, in cases where the object has not 
  * been added to a model or the model itself is incomplete,
  * unit analysis is not possible and this method will return @c NULL.
  *
  * @note The units are calculated by applying the mathematics 
  * from the expression to the units of the &lt;ci&gt; elements used 
  * within the expression. Where there are parameters/numbers
  * with undeclared units the UnitDefinition_t returned by this
  * function may not accurately represent the units of the expression.
  *
  * @see KineticLaw_containsUndeclaredUnits()
  *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
UnitDefinition_t * 
KineticLaw_getDerivedUnitDefinition(KineticLaw_t *kl);


/**
  * Predicate returning @c true or @c false depending on whether 
  * the math expression of this KineticLaw_t contains
  * parameters/numbers with undeclared units.
  * 
  * @return @c true if the math expression of this KineticLaw_t
  * includes parameters/numbers 
  * with undeclared units, @c false otherwise.
  *
  * @note a return value of @c true indicates that the UnitDefinition_t
  * returned by the getDerivedUnitDefinition function may not 
  * accurately represent the units of the expression.
  *
  * @see KineticLaw_getDerivedUnitDefinition()
  *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
int 
KineticLaw_containsUndeclaredUnits(KineticLaw_t *kl);


/**
 * Removes the nth Parameter_t structure from the list of local parameters
 * in this KineticLaw_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param kl the KineticLaw_t structure
 * @param n the integer index of the Parameter_t sought
 *
 * @return the Parameter_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
Parameter_t *
KineticLaw_removeParameter (KineticLaw_t *kl, unsigned int n);


/**
 * Removes the nth LocalParameter_t structure from the list of local parameters
 * in this KineticLaw_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param kl the KineticLaw_t structure
 * @param n the integer index of the LocalParameter_t sought
 *
 * @return the LocalParameter_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
LocalParameter_t *
KineticLaw_removeLocalParameter (KineticLaw_t *kl, unsigned int n);


/**
 * Removes the Parameter_t structure with the given "id" attribute
 * from the list of local parameters in this KineticLaw_t structure and 
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param kl the KineticLaw_t structure
 * @param sid the string of the "id" attribute of the Parameter_t sought
 *
 * @return the Parameter_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no KineticLaw_t
 * structure with the identifier exists in this KineticLaw_t structure.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
Parameter_t *
KineticLaw_removeParameterById (KineticLaw_t *kl, const char *sid);


/**
 * Removes the LocalParameter_t structure with the given "id" attribute
 * from the list of local parameters in this KineticLaw_t structure and 
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param kl the KineticLaw_t structure
 * @param sid the string of the "id" attribute of the LocalParameter_t sought
 *
 * @return the LocalParameter_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no KineticLaw_t
 * structure with the identifier exists in this KineticLaw_t structure.
 *
 * @memberof KineticLaw_t
 */
LIBSBML_EXTERN
LocalParameter_t *
KineticLaw_removeLocalParameterById (KineticLaw_t *kl, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* KineticLaw_h */

