/**
 * @file    Model.h
 * @brief   Definition of Model.
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
 * @class Model
 * @sbmlbrief{core} An SBML model.
 *
 * In an SBML model definition, a single object of class Model serves as
 * the overall container for the lists of the various model components.
 * All of the lists are optional, but if a given list container is present
 * within the model, the list must not be empty; that is, it must have
 * length one or more.  The following are the components and lists
 * permitted in different Levels and Versions of SBML in
 * version @htmlinclude libsbml-version.html
 * of libSBML:
 * <ul>
 * <li> In SBML Level 1, the components are: UnitDefinition, Compartment,
 * Species, Parameter, Rule, and Reaction.  Instances of the classes are
 * placed inside instances of classes ListOfUnitDefinitions,
 * ListOfCompartments, ListOfSpecies, ListOfParameters, ListOfRules, and
 * ListOfReactions.
 *
 * <li> In SBML Level 2 Version 1, the components are: FunctionDefinition,
 * UnitDefinition, Compartment, Species, Parameter, Rule, Reaction and
 * Event.  Instances of the classes are placed inside instances of classes
 * ListOfFunctionDefinitions, ListOfUnitDefinitions, ListOfCompartments,
 * ListOfSpecies, ListOfParameters, ListOfRules, ListOfReactions, and
 * ListOfEvents.
 *
 * <li> In SBML Level 2 Versions 2, 3 and 4, the components are:
 * FunctionDefinition, UnitDefinition, CompartmentType, SpeciesType,
 * Compartment, Species, Parameter, InitialAssignment, Rule, Constraint,
 * Reaction and Event.  Instances of the classes are placed inside
 * instances of classes ListOfFunctionDefinitions, ListOfUnitDefinitions,
 * ListOfCompartmentTypes, ListOfSpeciesTypes, ListOfCompartments,
 * ListOfSpecies, ListOfParameters, ListOfInitialAssignments, ListOfRules,
 * ListOfConstraints, ListOfReactions, and ListOfEvents.
 *
 * <li> In SBML Level 3 Version 1, the components are: FunctionDefinition,
 * UnitDefinition, Compartment, Species, Parameter, InitialAssignment,
 * Rule, Constraint, Reaction and Event.  Instances of the classes are
 * placed inside instances of classes ListOfFunctionDefinitions,
 * ListOfUnitDefinitions, ListOfCompartments, ListOfSpecies,
 * ListOfParameters, ListOfInitialAssignments, ListOfRules,
 * ListOfConstraints, ListOfReactions, and ListOfEvents.  
 * </ul>
 *
 * Although all the lists are optional, there are dependencies between SBML
 * components such that defining some components requires defining others.
 * An example is that defining a species requires defining a compartment,
 * and defining a reaction requires defining a species.  The dependencies
 * are explained in more detail in the SBML specifications.
 *
 * In addition to the above lists and attributes, the Model class in both
 * SBML Level&nbsp;2 and Level&nbsp;3 has the usual two attributes of "id"
 * and "name", and both are optional.  As is the case for other SBML
 * components with "id" and "name" attributes, they must be used according
 * to the guidelines described in the SBML specifications.  (Within the
 * frameworks of SBML Level&nbsp;2 and Level&nbsp;3 Version&nbsp;1 Core, a
 * Model object identifier has no assigned meaning, but extension packages
 * planned for SBML Level&nbsp;3 are likely to make use of this
 * identifier.)
 *
 * Finally, SBML Level&nbsp;3 has introduced a number of additional Model
 * attributes.  They are discussed in a separate section below.
 *
 *
 * @section approaches Approaches to creating objects using the libSBML API
 *
 * LibSBML provides two main mechanisms for creating objects: class
 * constructors
 * (e.g., @if java <a href="org/sbml/libsbml/Species.html">Species()</a> @else Species::Species() @endif), 
 * and <code>create<span class="placeholder-nospace"><em>Object</em></span>()</code>
 * methods (such as Model::createSpecies()) provided by certain <span
 * class="placeholder-nospace"><em>Object</em></span> classes such as Model.  These
 * multiple mechanisms are provided by libSBML for flexibility and to
 * support different use-cases, but they also have different implications
 * for the overall model structure.
 *
 * In general, the recommended approach is to use the <code>create<span
 * class="placeholder-nospace"><em>Object</em></span>()</code> methods.  These
 * methods both create an object @em and link it to the parent in one step.
 * Here is an example:@if clike
 * @code{.cpp}
// Create an SBMLDocument object in Level 3 Version 1 format:

SBMLDocument* sbmlDoc = new SBMLDocument(3, 1);

// Create a Model object inside the SBMLDocument object and set
// its identifier.  The call returns a pointer to the Model object
// created, and methods called on that object affect the attributes
// of the object attached to the model (as expected).

Model* model = sbmlDoc->createModel();
model->setId("BestModelEver");

// Create a Species object inside the Model and set its identifier.
// Similar to the lines above, this call returns a pointer to the Species
// object created, and methods called on that object affect the attributes
// of the object attached to the model (as expected).

Species *sp = model->createSpecies();
sp->setId("MySpecies");
@endcode
 * @endif@if java
@code{.java}
// Create an SBMLDocument object in Level 3 Version 1 format:

SBMLDocument sbmlDoc = new SBMLDocument(3, 1);

// Create a Model object inside the SBMLDocument object and set
// its identifier.  The call returns a pointer to the Model object
// created, and methods called on that object affect the attributes
// of the object attached to the model (as expected).  Note that
// the call to setId() returns a status code, and a real program
// should check this status code to make sure everything went okay.

Model model = sbmlDoc.createModel();
model.setId(&#34;BestModelEver&#34;);

// Create a Species object inside the Model and set its identifier.
// Similar to the lines above, this call returns a pointer to the Species
// object created, and methods called on that object affect the attributes
// of the object attached to the model (as expected).  Note that, like
// with Model, the call to setId() returns a status code, and a real program
// should check this status code to make sure everything went okay.

Species sp = model.createSpecies();
sp.setId(&#34;BestSpeciesEver&#34;);
@endcode
 * @endif@if python
@code{.py}
# Create an SBMLDocument object in Level 3 Version 1 format.
# Make sure to check for possible failures.

try:
  sbmlDoc = SBMLDocument(3, 1)
except ValueError:
  print('Could not create SBMLDocument object')
  sys.exit(1)

# Create a Model object inside the SBMLDocument object and set its
# identifier, checking the returned values.  The call to setId() returns a
# status code to indicate whether the assignment was successful.

model = sbmlDoc.createModel()
if model == None:
  # Do something to handle the error here.
  print("Unable to create Model object.")
  sys.exit(1)

status = model.setId('BestModelEver')
if status != LIBSBML_OPERATION_SUCCESS:
  # Do something to handle the error here.
  print("Unable to set identifier on the Model object")
  sys.exit(1)

# Create a Species object inside the Model and set its identifier.
# Again, the setId() returns a status code to indicate whether the
# assignment was successful.

sp = model.createSpecies()
if sp == None:
  # Do something to handle the error here.
  print("Unable to create Species object.")
  sys.exit(1)

status = sp.setId('BestSpeciesEver')
if status != LIBSBML_OPERATION_SUCCESS:
  # Do something to handle the error here.
  print("Unable to set identifier on the Species object")
  sys.exit(1)
@endcode
 * @endif@if csharp
@code
// Create an SBMLDocument object in Level 3 Version 1 format:

SBMLDocument sbmlDoc = new SBMLDocument(3, 1);

// Create a Model object inside the SBMLDocument object and set
// its identifier.  The call returns a pointer to the Model object
// created, and methods called on that object affect the attributes
// of the object attached to the model (as expected).

Model model = sbmlDoc.createModel();
model.setId("BestModelEver");

// Create a Species object inside the Model and set its identifier.
// Similar to the lines above, this call returns a pointer to the Species
// object created, and methods called on that object affect the attributes
// of the object attached to the model (as expected).

Species sp = model.createSpecies();
sp.setId("MySpecies");
@endcode
 * @endif@~
 *
 * The <code>create<span
 * class="placeholder-nospace"><em>Object</em></span>()</code> methods return a
 * pointer to the object created, but they also add the object to the
 * relevant list of object instances contained in the parent.  (These lists
 * become the <code>&lt;listOf<span
 * class="placeholder-nospace"><em>Object</em></span>s&gt;</code> elements in the
 * finished XML rendition of SBML.)  In the example above,
 * Model::createSpecies() adds the created species directly to the
 * <code>&lt;listOfSpecies&gt;</code> list in the model.  Subsequently,
 * methods called on the species change the species in the model (which is
 * what is expected in most situations).
 *
 * @section model-checking Consistency and adherence to SBML specifications
 *
 * To make it easier for applications to do whatever they need,
 * libSBML version @htmlinclude libsbml-version.html
 * is relatively lax when it comes to enforcing correctness and
 * completeness of models @em during model construction and editing.
 * Essentially, libSBML @em will @em not in most cases check automatically
 * that a model's components have valid attribute values, or that the
 * overall model is consistent and free of errors---even obvious errors
 * such as duplication of identifiers.  This allows applications great
 * leeway in how they build their models, but it means that software
 * authors must take deliberate steps to ensure that the model will be, in
 * the end, valid SBML.  These steps include such things as keeping track
 * of the identifiers used in a model, manually performing updates in
 * certain situations where an entity is referenced in more than one place
 * (e.g., a species that is referenced by multiple SpeciesReference
 * objects), and so on.
 *
 * That said, libSBML does provide powerful features for deliberately
 * performing validation of SBML when an application decides it is time to
 * do so.  The interfaces to these facilities are on the SBMLDocument
 * class, in the form of SBMLDocument::checkInternalConsistency() and
 * SBMLDocument::checkConsistency().  Please refer to the documentation for
 * SBMLDocument for more information about this.
 *
 * While applications may play fast and loose and live like free spirits
 * during the construction and editing of SBML models, they should always
 * make sure to call SBMLDocument::checkInternalConsistency() and/or
 * SBMLDocument::checkConsistency() before writing out the final version of
 * an SBML model.
 *
 *
 * @section model-l3-attrib Model attributes introduced in SBML Level&nbsp;3
 *
 * As mentioned above, the Model class has a number of optional attributes
 * in SBML Level&nbsp;3 Version&nbsp;1 Core.  These are "substanceUnits",
 * "timeUnits", "volumeUnits", "areaUnits", "lengthUnits", "extentUnits",
 * and "conversionFactor.  The following provide more information about
 * them.
 *
 * @subsection model-l3-substanceunits The "substanceUnits" attribute
 *
 * The "substanceUnits" attribute is used to specify the unit of
 * measurement associated with substance quantities of Species objects that
 * do not specify units explicitly.  If a given Species object definition
 * does not specify its unit of substance quantity via the "substanceUnits"
 * attribute on the Species object instance, then that species inherits the
 * value of the Model "substanceUnits" attribute.  If the Model does not
 * define a value for this attribute, then there is no unit to inherit, and
 * all species that do not specify individual "substanceUnits" attribute
 * values then have <em>no</em> declared units for their quantities.  The
 * SBML Level&nbsp;3 Version&nbsp;1 Core specification provides more
 * details.
 *
 * Note that when the identifier of a species appears in a model's
 * mathematical expressions, the unit of measurement associated with that
 * identifier is <em>not solely determined</em> by setting "substanceUnits"
 * on Model or Species.  Please see the discussion about units given in
 * the documentation for the Species class.
 *
 *
 * @subsection model-l3-timeunits The "timeUnits" attribute
 *
 * The "timeUnits" attribute on SBML Level&nbsp;3's Model object is used to
 * specify the unit in which time is measured in the model.  This attribute
 * on Model is the <em>only</em> way to specify a unit for time in a model.
 * It is a global attribute; time is measured in the model everywhere in
 * the same way.  This is particularly relevant to Reaction and RateRule
 * objects in a model: all Reaction and RateRule objects in SBML define
 * per-time values, and the unit of time is given by the "timeUnits"
 * attribute on the Model object instance.  If the Model "timeUnits"
 * attribute has no value, it means that the unit of time is not defined
 * for the model's reactions and rate rules.  Leaving it unspecified in an
 * SBML model does not result in an invalid model in SBML Level&nbsp;3;
 * however, as a matter of best practice, we strongly recommend that all
 * models specify units of measurement for time.
 *
 *
 * @subsection model-l3-voletc The "volumeUnits", "areaUnits", and "lengthUnits" attributes
 *
 * The attributes "volumeUnits", "areaUnits" and "lengthUnits" together are
 * used to set the units of measurements for the sizes of Compartment
 * objects in an SBML Level&nbsp;3 model when those objects do not
 * otherwise specify units.  The three attributes correspond to the most
 * common cases of compartment dimensions: "volumeUnits" for compartments
 * having a "spatialDimensions" attribute value of @c "3", "areaUnits" for
 * compartments having a "spatialDimensions" attribute value of @c "2", and
 * "lengthUnits" for compartments having a "spatialDimensions" attribute
 * value of @c "1".  The attributes are not applicable to compartments
 * whose "spatialDimensions" attribute values are @em not one of @c "1", @c
 * "2" or @c "3".
 *
 * If a given Compartment object instance does not provide a value for its
 * "units" attribute, then the unit of measurement of that compartment's
 * size is inherited from the value specified by the Model "volumeUnits",
 * "areaUnits" or "lengthUnits" attribute, as appropriate based on the
 * Compartment object's "spatialDimensions" attribute value.  If the Model
 * object does not define the relevant attribute, then there are no units
 * to inherit, and all Compartment objects that do not set a value for
 * their "units" attribute then have <em>no</em> units associated with
 * their compartment sizes.
 *
 * The use of three separate attributes is a carry-over from SBML
 * Level&nbsp;2.  Note that it is entirely possible for a model to define a
 * value for two or more of the attributes "volumeUnits", "areaUnits" and
 * "lengthUnits" simultaneously, because SBML models may contain
 * compartments with different numbers of dimensions.
 *
 *
 * @subsection model-l3-extentunits The "extentUnits" attribute
 *
 * Reactions are processes that occur over time.  These processes involve
 * events of some sort, where a single ``reaction event'' is one in which
 * some set of entities (known as reactants, products and modifiers in
 * SBML) interact, once.  The <em>extent</em> of a reaction is a measure of
 * how many times the reaction has occurred, while the time derivative of
 * the extent gives the instantaneous rate at which the reaction is
 * occurring.  Thus, what is colloquially referred to as the "rate of the
 * reaction" is in fact equal to the rate of change of reaction extent.
 *
 * In SBML Level&nbsp;3, the combination of "extentUnits" and "timeUnits"
 * defines the units of kinetic laws in SBML and establishes how the
 * numerical value of each KineticLaw object's mathematical formula is
 * meant to be interpreted in a model.  The units of the kinetic laws are
 * taken to be "extentUnits" divided by "timeUnits".
 *
 * Note that this embodies an important principle in SBML Level&nbsp;3
 * models: <em>all reactions in an SBML model must have the same units</em>
 * for the rate of change of extent.  In other words, the units of all
 * reaction rates in the model <em>must be the same</em>.  There is only
 * one global value for "extentUnits" and one global value for "timeUnits".
 *
 *
 * @subsection model-l3-convfactor The "conversionFactor" attribute
 *
 * The attribute "conversionFactor" in SBML Level&nbsp;3's Model object
 * defines a global value inherited by all Species object instances that do
 * not define separate values for their "conversionFactor" attributes.  The
 * value of this attribute must refer to a Parameter object instance
 * defined in the model.  The Parameter object in question must be a
 * constant; ie it must have its "constant" attribute value set to @c
 * "true".
 *
 * If a given Species object definition does not specify a conversion
 * factor via the "conversionFactor" attribute on Species, then the species
 * inherits the conversion factor specified by the Model "conversionFactor"
 * attribute.  If the Model does not define a value for this attribute,
 * then there is no conversion factor to inherit.  More information about
 * conversion factors is provided in the SBML Level&nbsp;3 Version&nbsp;1
 * specification.
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_how_added_last_reaction_irrelevant
 *
 * @par
 * The mechanism by which the last Reaction object was created and added
 * to this Model is not significant.  It could have been created in a
 * variety of ways, for example using createReaction().  If a Reaction
 * does not exist for this model, a new SpeciesReference is @em not
 * created and @c NULL is returned instead.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_how_added_last_kineticlaw_irrelevant
 *
 * @par
 * The last KineticLaw object in this Model could have been created in a
 * variety of ways.  For example, it could have been added using
 * createKineticLaw(), or it could be the result of using
 * Reaction::createKineticLaw() on the Reaction object created by a
 * createReaction().  If a Reaction does not exist for this model, or the
 * last Reaction does not contain a KineticLaw object, a new Parameter is
 * @em not created and @c NULL is returned instead.
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class doc_how_added_last_event_irrelevant
 *
 * @par
 * The mechanism by which the last Event object in this model was created
 * is not significant.  It could have been created in a variety of ways,
 * for example by using createEvent().  If no Event object exists in this
 * Model object, a new EventAssignment is @em not created and @c NULL is
 * returned instead.
 */

#ifndef Model_h
#define Model_h


#include <sbml/common/libsbml-config.h>
#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>

#include <sbml/SBMLTypeCodes.h>


#ifdef __cplusplus


#include <string>

#include <sbml/FunctionDefinition.h>
#include <sbml/UnitDefinition.h>
#include <sbml/CompartmentType.h>
#include <sbml/SpeciesType.h>
#include <sbml/Compartment.h>
#include <sbml/Species.h>
#include <sbml/Parameter.h>
#include <sbml/InitialAssignment.h>
#include <sbml/Rule.h>
#include <sbml/Constraint.h>
#include <sbml/Reaction.h>
#include <sbml/Event.h>

#include <sbml/units/FormulaUnitsData.h>

#include <sbml/annotation/ModelHistory.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class SBMLVisitor;
class FormulaUnitsData;
class UnitFormulaFormatter;
class ElementFilter;

LIBSBML_CPP_NAMESPACE_END


LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN Model : public SBase
{
  friend class SBMLDocument; //So that SBMLDocument can change the element namespace if it needs to.
public:

  /**
   * Creates a new Model using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this Model
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * Model
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   *
   * @copydetails doc_note_setting_lv
   */
  Model (unsigned int level, unsigned int version);


  /**
   * Creates a new Model using the given SBMLNamespaces object
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
  Model (SBMLNamespaces* sbmlns);


  /**
   * Destroys this Model.
   */
  virtual ~Model ();


  /**
   * Copy constructor; creates a (deep) copy of the given Model object.
   *
   * @param orig the object to copy.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  Model(const Model& orig);


  /**
   * Assignment operator for Model.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  Model& operator=(const Model& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of Constraint.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this Model object.
   *
   * @return the (deep) copy of this Model object.
   */
  virtual Model* clone () const;


  /**
   * Returns the first child element found that has the given @p id.
   *
   * This operation searches the model-wide <code>SId</code> identifier
   * type namespace
   *
   * @param id string representing the id of the object to find.
   *
   * @return pointer to the first element found with the given @p id, or @c
   * NULL if no such object is found.
   */
  virtual SBase* getElementBySId(const std::string& id);


  /**
   * Returns the first child element it can find with the given @p metaid.
   *
   * @param metaid string representing the meta-identifier of the object to
   * find.
   *
   * @return pointer to the first element found with the given @p metaid, or
   * NULL if no such object is found.
   */
  virtual SBase* getElementByMetaId(const std::string& metaid);


  /**
   * Returns a List of all child objects.
   *
   * This returns all child objects nested to an arbitrary depth.  If an
   * optional element filter is provided, only those objects for which the
   * @p filter's <code>filter()</code> method returns true will be added to 
   * the list.
   *
   * @param filter optional filter to apply to objects before putting them
   * into the list to be returned.
   *
   * @return a List* of pointers to all children objects.
   */
  virtual List* getAllElements(ElementFilter* filter=NULL);


  /**
   * Returns the value of the "id" attribute of this Model.
   *
   * @return the id of this Model.
   */
  virtual const std::string& getId () const;


  /**
   * Returns the value of the "name" attribute of this Model.
   *
   * @return the name of this Model.
   */
  virtual const std::string& getName () const;


  /**
   * Returns the value of the "substanceUnits" attribute of this Model.
   *
   * @return the substanceUnits of this Model.
   *
   * @note The "substanceUnits" attribute is available in
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  const std::string& getSubstanceUnits () const;


  /**
   * Returns the value of the "timeUnits" attribute of this Model.
   *
   * @return the timeUnits of this Model.
   *
   * @note The "timeUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  const std::string& getTimeUnits () const;


  /**
   * Returns the value of the "volumeUnits" attribute of this Model.
   *
   * @return the volumeUnits of this Model.
   *
   * @note The "volumeUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  const std::string& getVolumeUnits () const;


  /**
   * Returns the value of the "areaUnits" attribute of this Model.
   *
   * @return the areaUnits of this Model.
   *
   * @note The "areaUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  const std::string& getAreaUnits () const;


  /**
   * Returns the value of the "lengthUnits" attribute of this Model.
   *
   * @return the lengthUnits of this Model.
   *
   * @note The "lengthUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  const std::string& getLengthUnits () const;


  /**
   * Returns the value of the "extentUnits" attribute of this Model.
   *
   * @return the extentUnits of this Model.
   *
   * @note The "extentUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  const std::string& getExtentUnits () const;


  /**
   * Returns the value of the "conversionFactor" attribute of this Model.
   *
   * @return the conversionFactor of this Model.
   *
   * @note The "conversionFactor" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  const std::string& getConversionFactor () const;


  /**
   * Predicate returning @c true if this
   * Model's "id" attribute is set.
   *
   * @return @c true if the "id" attribute of this Model is
   * set, @c false otherwise.
   */
  virtual bool isSetId () const;


  /**
   * Predicate returning @c true if this
   * Model's "name" attribute is set.
   *
   * @return @c true if the "name" attribute of this Model is
   * set, @c false otherwise.
   */
  virtual bool isSetName () const;


  /**
   * Predicate returning @c true if this
   * Model's "substanceUnits" attribute is set.
   *
   * @return @c true if the "substanceUnits" attribute of this Model is
   * set, @c false otherwise.
   *
   * @note The "substanceUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  bool isSetSubstanceUnits () const;


  /**
   * Predicate returning @c true if this
   * Model's "timeUnits" attribute is set.
   *
   * @return @c true if the "timeUnits" attribute of this Model is
   * set, @c false otherwise.
   *
   * @note The "substanceUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  bool isSetTimeUnits () const;


  /**
   * Predicate returning @c true if this
   * Model's "volumeUnits" attribute is set.
   *
   * @return @c true if the "volumeUnits" attribute of this Model is
   * set, @c false otherwise.
   *
   * @note The "volumeUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  bool isSetVolumeUnits () const;


  /**
   * Predicate returning @c true if this
   * Model's "areaUnits" attribute is set.
   *
   * @return @c true if the "areaUnits" attribute of this Model is
   * set, @c false otherwise.
   *
   * @note The "areaUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  bool isSetAreaUnits () const;


  /**
   * Predicate returning @c true if this
   * Model's "lengthUnits" attribute is set.
   *
   * @return @c true if the "lengthUnits" attribute of this Model is
   * set, @c false otherwise.
   *
   * @note The "lengthUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  bool isSetLengthUnits () const;


  /**
   * Predicate returning @c true if this
   * Model's "extentUnits" attribute is set.
   *
   * @return @c true if the "extentUnits" attribute of this Model is
   * set, @c false otherwise.
   *
   * @note The "extentUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  bool isSetExtentUnits () const;


  /**
   * Predicate returning @c true if this
   * Model's "conversionFactor" attribute is set.
   *
   * @return @c true if the "conversionFactor" attribute of this Model is
   * set, @c false otherwise.
   *
   * @note The "conversionFactor" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  bool isSetConversionFactor () const;


  /**
   * Sets the value of the "id" attribute of this Model.
   *
   * The string @p sid is copied.
   *
   * @copydetails doc_id_syntax
   *
   * @param sid the string to use as the identifier of this Model
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  virtual int setId (const std::string& sid);


  /**
   * Sets the value of the "name" attribute of this Model.
   *
   * The string in @p name is copied.
   *
   * @param name the new name for the Model
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  virtual int setName (const std::string& name);


  /**
   * Sets the value of the "substanceUnits" attribute of this Model.
   *
   * The string in @p units is copied.
   *
   * @param units the new substanceUnits for the Model
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note The "substanceUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int setSubstanceUnits (const std::string& units);


  /**
   * Sets the value of the "timeUnits" attribute of this Model.
   *
   * The string in @p units is copied.
   *
   * @param units the new timeUnits for the Model
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note The "timeUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int setTimeUnits (const std::string& units);


  /**
   * Sets the value of the "volumeUnits" attribute of this Model.
   *
   * The string in @p units is copied.
   *
   * @param units the new volumeUnits for the Model
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note The "volumeUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int setVolumeUnits (const std::string& units);


  /**
   * Sets the value of the "areaUnits" attribute of this Model.
   *
   * The string in @p units is copied.
   *
   * @param units the new areaUnits for the Model
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note The "areaUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int setAreaUnits (const std::string& units);


  /**
   * Sets the value of the "lengthUnits" attribute of this Model.
   *
   * The string in @p units is copied.
   *
   * @param units the new lengthUnits for the Model
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note The "lengthUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int setLengthUnits (const std::string& units);


  /**
   * Sets the value of the "extentUnits" attribute of this Model.
   *
   * The string in @p units is copied.
   *
   * @param units the new extentUnits for the Model
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note The "extentUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int setExtentUnits (const std::string& units);


  /**
   * Sets the value of the "conversionFactor" attribute of this Model.
   *
   * The string in @p units is copied.
   *
   * @param units the new conversionFactor for the Model
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   *
   * @note The "conversionFactor" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int setConversionFactor (const std::string& units);


  /**
   * Unsets the value of the "id" attribute of this Model.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  virtual int unsetId ();


  /**
   * Unsets the value of the "name" attribute of this Model.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  virtual int unsetName ();


  /**
   * Unsets the value of the "substanceUnits" attribute of this Model.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note The "substanceUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int unsetSubstanceUnits ();


  /**
   * Unsets the value of the "timeUnits" attribute of this Model.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note The "timeUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int unsetTimeUnits ();


  /**
   * Unsets the value of the "volumeUnits" attribute of this Model.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note The "volumeUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int unsetVolumeUnits ();


  /**
   * Unsets the value of the "areaUnits" attribute of this Model.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note The "areaUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int unsetAreaUnits ();


  /**
   * Unsets the value of the "lengthUnits" attribute of this Model.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note The "lengthUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int unsetLengthUnits ();


  /**
   * Unsets the value of the "extentUnits" attribute of this Model.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note The "extentUnits" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int unsetExtentUnits ();


  /**
   * Unsets the value of the "conversionFactor" attribute of this Model.
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @note The "conversionFactor" attribute is available in 
   * SBML Level&nbsp;3 but is not present on Model in lower Levels of SBML.
   */
  int unsetConversionFactor ();


  /**
   * Adds a copy of the given FunctionDefinition object to this Model.
   *
   * @param fd the FunctionDefinition to add
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
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
   * @see createFunctionDefinition()
   */
  int addFunctionDefinition (const FunctionDefinition* fd);


  /**
   * Adds a copy of the given UnitDefinition object to this Model.
   *
   * @param ud the UnitDefinition object to add
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
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
   * @see createUnitDefinition()
   */
  int addUnitDefinition (const UnitDefinition* ud);


  /**
   * Adds a copy of the given CompartmentType object to this Model.
   *
   * @param ct the CompartmentType object to add
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
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
   * @note The CompartmentType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   *
   * @see createCompartmentType()
   */
  int addCompartmentType (const CompartmentType* ct);


  /**
   * Adds a copy of the given SpeciesType object to this Model.
   *
   * @param st the SpeciesType object to add
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
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
   * @note The SpeciesType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   *
   * @see createSpeciesType()
   */
  int addSpeciesType (const SpeciesType* st);


  /**
   * Adds a copy of the given Compartment object to this Model.
   *
   * @param c the Compartment object to add
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
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
   * @see createCompartment()
   */
  int addCompartment (const Compartment* c);


  /**
   * Adds a copy of the given Species object to this Model.
   *
   * @param s the Species object to add
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
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
   * @see createSpecies()
   */
  int addSpecies (const Species* s);


  /**
   * Adds a copy of the given Parameter object to this Model.
   *
   * @param p the Parameter object to add
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
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
   * Adds a copy of the given InitialAssignment object to this Model.
   *
   * @param ia the InitialAssignment object to add
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
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
   * @see createInitialAssignment()
   */
  int addInitialAssignment (const InitialAssignment* ia);


  /**
   * Adds a copy of the given Rule object to this Model.
   *
   * @param r the Rule object to add
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
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
   * @see createAlgebraicRule()
   * @see createAssignmentRule()
   * @see createRateRule()
   */
  int addRule (const Rule* r);


  /**
   * Adds a copy of the given Constraint object to this Model.
   *
   * @param c the Constraint object to add
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @copydetails doc_note_object_is_copied 
   *
   * @see createConstraint()
   */
  int addConstraint (const Constraint* c);


  /**
   * Adds a copy of the given Reaction object to this Model.
   *
   * @param r the Reaction object to add
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
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
   * @see createReaction()
   */
  int addReaction (const Reaction* r);


  /**
   * Adds a copy of the given Event object to this Model.
   *
   * @param e the Event object to add
   *
   * @return integer value indicating success/failure of the
   * function.  The possible values
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
   * @see createEvent()
   */
  int addEvent (const Event* e);


  /**
   * Creates a new FunctionDefinition inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the FunctionDefinition object created
   *
   * @see addFunctionDefinition(const FunctionDefinition* fd)
   */
  FunctionDefinition* createFunctionDefinition ();


  /**
   * Creates a new UnitDefinition inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the UnitDefinition object created
   *
   * @see addUnitDefinition(const UnitDefinition* ud)
   */
  UnitDefinition* createUnitDefinition ();


  /**
   * Creates a new Unit object within the last UnitDefinition object
   * created in this model and returns a pointer to it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * The mechanism by which the UnitDefinition was created is not
   * significant.  If a UnitDefinition object does not exist in this model,
   * a new Unit is @em not created and @c NULL is returned instead.
   *
   * @return the Unit object created
   *
   * @see addUnitDefinition(const UnitDefinition* ud)
   */
  Unit* createUnit ();


  /**
   * Creates a new CompartmentType inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the CompartmentType object created
   *
   * @note The CompartmentType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   *
   * @see addCompartmentType(const CompartmentType* ct)
   */
  CompartmentType* createCompartmentType ();


  /**
   * Creates a new SpeciesType inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the SpeciesType object created
   *
   * @note The SpeciesType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   *
   * @see addSpeciesType(const SpeciesType* st)
   */
  SpeciesType* createSpeciesType ();


  /**
   * Creates a new Compartment inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the Compartment object created
   *
   * @see addCompartment(const Compartment *c)
   */
  Compartment* createCompartment ();


  /**
   * Creates a new Species inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the Species object created
   *
   * @see addSpecies(const Species *s)
   */
  Species* createSpecies ();


  /**
   * Creates a new Parameter inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the Parameter object created
   *
   * @see addParameter(const Parameter *p)
   */
  Parameter* createParameter ();


  /**
   * Creates a new InitialAssignment inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the InitialAssignment object created
   *
   * @see addInitialAssignment(const InitialAssignment* ia)
   */
  InitialAssignment* createInitialAssignment ();


  /**
   * Creates a new AlgebraicRule inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the AlgebraicRule object created
   *
   * @see addRule(const Rule* r)
   */
  AlgebraicRule* createAlgebraicRule ();


  /**
   * Creates a new AssignmentRule inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the AssignmentRule object created
   *
   * @see addRule(const Rule* r)
   */
  AssignmentRule* createAssignmentRule ();


  /**
   * Creates a new RateRule inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the RateRule object created
   *
   * @see addRule(const Rule* r)
   */
  RateRule* createRateRule ();


  /**
   * Creates a new Constraint inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the Constraint object created
   *
   * @see addConstraint(const Constraint *c)
   */
  Constraint* createConstraint ();


  /**
   * Creates a new Reaction inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the Reaction object created
   *
   * @see addReaction(const Reaction *r)
   */
  Reaction* createReaction ();


  /**
   * Creates a new SpeciesReference object for a reactant inside the last
   * Reaction object in this Model, and returns a pointer to it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @copydetails doc_how_added_last_reaction_irrelevant
   *
   * @return the SpeciesReference object created.  If a Reaction does not
   * exist for this model, a new SpeciesReference is @em not created and @c
   * NULL is returned.
   */
  SpeciesReference* createReactant ();


  /**
   * Creates a new SpeciesReference object for a product inside the last
   * Reaction object in this Model, and returns a pointer to it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @copydetails doc_how_added_last_reaction_irrelevant
   *
   * @return the SpeciesReference object created. If a Reaction does not
   * exist for this model, a new SpeciesReference is @em not created and @c
   * NULL is returned.
   */
  SpeciesReference* createProduct ();


  /**
   * Creates a new ModifierSpeciesReference object for a modifier species
   * inside the last Reaction object in this Model, and returns a pointer
   * to it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @copydetails doc_how_added_last_reaction_irrelevant
   *
   * @return the SpeciesReference object created.  If a Reaction does not
   * exist for this model, a new SpeciesReference is @em not created and @c
   * NULL is returned.
   */
  ModifierSpeciesReference* createModifier ();


  /**
   * Creates a new KineticLaw inside the last Reaction object created in
   * this Model, and returns a pointer to it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @copydetails doc_how_added_last_reaction_irrelevant
   *
   * @return the KineticLaw object created.  If a Reaction does not exist for
   * this model, or a Reaction does exist but already has a KineticLaw, a new
   * KineticLaw is @em not created and @c NULL is returned.
   */
  KineticLaw* createKineticLaw ();


  /**
   * Creates a new local Parameter inside the KineticLaw object of the last
   * Reaction created inside this Model, and returns a pointer to it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @copydetails doc_how_added_last_kineticlaw_irrelevant
   *
   * @return the Parameter object created.  If a Reaction does not exist for
   * this model, or a KineticLaw for the Reaction does not exist, a new
   * Parameter is @em not created and @c NULL is returned.
   */
  Parameter* createKineticLawParameter ();


  /**
   * Creates a new LocalParameter inside the KineticLaw object of the last
   * Reaction created inside this Model, and returns a pointer to it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @copydetails doc_how_added_last_kineticlaw_irrelevant
   *
   * @return the Parameter object created.  If a Reaction does not exist for
   * this model, or a KineticLaw for the Reaction does not exist, a new
   * Parameter is @em not created and @c NULL is returned.
   */
  LocalParameter* createKineticLawLocalParameter ();


  /**
   * Creates a new Event inside this Model and returns it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @return the Event object created
   */
  Event* createEvent ();


  /**
   * Creates a new EventAssignment inside the last Event object created in
   * this Model, and returns a pointer to it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @copydetails doc_how_added_last_event_irrelevant
   *
   * @return the EventAssignment object created
   */
  EventAssignment* createEventAssignment ();


  /**
   * Creates a new Trigger inside the last Event object created in
   * this Model, and returns a pointer to it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @copydetails doc_how_added_last_event_irrelevant
   *
   * @return the Trigger object created
   */
  Trigger* createTrigger ();


  /**
   * Creates a new Delay inside the last Event object created in
   * this Model, and returns a pointer to it.
   *
   * The SBML Level and Version of the enclosing Model object, as well as
   * any SBML package namespaces, are used to initialize this
   * object's corresponding attributes.
   *
   * @copydetails doc_how_added_last_event_irrelevant
   *
   * @return the Delay object created
   */
  Delay* createDelay ();


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
   * @see appendAnnotation(const std::string& annotation)
   */
  virtual int setAnnotation (const std::string& annotation);


  /**
   * Appends annotation content to any existing content in the "annotation"
   * subelement of this object.
   *
   * The content in @p annotation is copied.  Unlike setAnnotation(), this
   * method allows other annotations to be preserved when an application
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
   * @see setAnnotation(const XMLNode* annotation)
   */
  virtual int appendAnnotation (const XMLNode* annotation);


  /**
   * Appends annotation content to any existing content in the "annotation"
   * subelement of this object.
   *
   * The content in @p annotation is copied.  Unlike setAnnotation(), this 
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
   */
  virtual int appendAnnotation (const std::string& annotation);


  /**
   * Get the ListOfFunctionDefinitions object in this Model.
   *
   * @return the list of FunctionDefinitions for this Model.
   */
  const ListOfFunctionDefinitions* getListOfFunctionDefinitions () const;


  /**
   * Get the ListOfFunctionDefinitions object in this Model.
   *
   * @return the list of FunctionDefinitions for this Model.
   */
  ListOfFunctionDefinitions* getListOfFunctionDefinitions ();


  /**
   * Get the ListOfUnitDefinitions object in this Model.
   *
   * @return the list of UnitDefinitions for this Model.
   */
  const ListOfUnitDefinitions* getListOfUnitDefinitions () const;


  /**
   * Get the ListOfUnitDefinitions object in this Model.
   *
   * @return the list of UnitDefinitions for this Model.
   */
  ListOfUnitDefinitions* getListOfUnitDefinitions ();


  /**
   * Get the ListOfCompartmentTypes object in this Model.
   *
   * @return the list of CompartmentTypes for this Model.
   *
   * @note The CompartmentType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  const ListOfCompartmentTypes* getListOfCompartmentTypes () const;


  /**
   * Get the ListOfCompartmentTypes object in this Model.
   *
   * @return the list of CompartmentTypes for this Model.
   *
   * @note The CompartmentType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  ListOfCompartmentTypes* getListOfCompartmentTypes ();


  /**
   * Get the ListOfSpeciesTypes object in this Model.
   *
   * @return the list of SpeciesTypes for this Model.
   *
   * @note The SpeciesType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  const ListOfSpeciesTypes* getListOfSpeciesTypes () const;


  /**
   * Get the ListOfSpeciesTypes object in this Model.
   *
   * @return the list of SpeciesTypes for this Model.
   *
   * @note The SpeciesType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  ListOfSpeciesTypes* getListOfSpeciesTypes ();


  /**
   * Get the ListOfCompartments object in this Model.
   *
   * @return the list of Compartments for this Model.
   */
  const ListOfCompartments* getListOfCompartments () const;


  /**
   * Get the ListOfCompartments object in this Model.
   *
   * @return the list of Compartments for this Model.
   */
  ListOfCompartments* getListOfCompartments ();


  /**
   * Get the ListOfSpecies object in this Model.
   *
   * @return the list of Species for this Model.
   */
  const ListOfSpecies* getListOfSpecies () const;


  /**
   * Get the ListOfSpecies object in this Model.
   *
   * @return the list of Species for this Model.
   */
  ListOfSpecies* getListOfSpecies ();


  /**
   * Get the ListOfParameters object in this Model.
   *
   * @return the list of Parameters for this Model.
   */
  const ListOfParameters* getListOfParameters () const;


  /**
   * Get the ListOfParameters object in this Model.
   *
   * @return the list of Parameters for this Model.
   */
  ListOfParameters* getListOfParameters ();


  /**
   * Get the ListOfInitialAssignments object in this Model.
   *
   * @return the list of InitialAssignments for this Model.
   */
  const ListOfInitialAssignments* getListOfInitialAssignments () const;


  /**
   * Get the ListOfInitialAssignments object in this Model.
   *
   * @return the list of InitialAssignment for this Model.
   */
  ListOfInitialAssignments* getListOfInitialAssignments ();


  /**
   * Get the ListOfRules object in this Model.
   *
   * @return the list of Rules for this Model.
   */
  const ListOfRules* getListOfRules () const;


  /**
   * Get the ListOfRules object in this Model.
   *
   * @return the list of Rules for this Model.
   */
  ListOfRules* getListOfRules ();


  /**
   * Get the ListOfConstraints object in this Model.
   *
   * @return the list of Constraints for this Model.
   */
  const ListOfConstraints* getListOfConstraints () const;


  /**
   * Get the ListOfConstraints object in this Model.
   *
   * @return the list of Constraints for this Model.
   */
  ListOfConstraints* getListOfConstraints ();


  /**
   * Get the ListOfReactions object in this Model.
   *
   * @return the list of Reactions for this Model.
   */
  const ListOfReactions* getListOfReactions () const;


  /**
   * Get the ListOfReactions object in this Model.
   *
   * @return the list of Reactions for this Model.
   */
  ListOfReactions* getListOfReactions ();


  /**
   * Get the ListOfEvents object in this Model.
   *
   * @return the list of Events for this Model.
   */
  const ListOfEvents* getListOfEvents () const;


  /**
   * Get the ListOfEvents object in this Model.
   *
   * @return the list of Events for this Model.
   */
  ListOfEvents* getListOfEvents ();


  /**
   * Get the nth FunctionDefinitions object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth FunctionDefinition of this Model.
   */
  const FunctionDefinition* getFunctionDefinition (unsigned int n) const;


  /**
   * Get the nth FunctionDefinitions object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth FunctionDefinition of this Model.
   */
  FunctionDefinition* getFunctionDefinition (unsigned int n);


  /**
   * Get a FunctionDefinition object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the FunctionDefinition in this Model with the identifier
   * @p sid or @c NULL if no such FunctionDefinition exists.
   */
  const FunctionDefinition*
  getFunctionDefinition (const std::string& sid) const;


  /**
   * Get a FunctionDefinition object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the FunctionDefinition in this Model with the identifier
   * @p sid or @c NULL if no such FunctionDefinition exists.
   */
  FunctionDefinition* getFunctionDefinition (const std::string& sid);


  /**
   * Get the nth UnitDefinition object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth UnitDefinition of this Model.
   */
  const UnitDefinition* getUnitDefinition (unsigned int n) const;


  /**
   * Get the nth UnitDefinition object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth UnitDefinition of this Model.
   */
  UnitDefinition* getUnitDefinition (unsigned int n);


  /**
   * Get a UnitDefinition based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the UnitDefinition in this Model with the identifier @p sid or
   * @c NULL if no such UnitDefinition exists.
   */
  const UnitDefinition* getUnitDefinition (const std::string& sid) const;


  /**
   * Get a UnitDefinition based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the UnitDefinition in this Model with the identifier @p sid or
   * @c NULL if no such UnitDefinition exists.
   */
  UnitDefinition* getUnitDefinition (const std::string& sid);


  /**
   * Get the nth CompartmentType object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth CompartmentType of this Model.
   *
   * @note The CompartmentType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  const CompartmentType* getCompartmentType (unsigned int n) const;


  /**
   * Get the nth CompartmentType object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth CompartmentType of this Model.
   *
   * @note The CompartmentType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  CompartmentType* getCompartmentType (unsigned int n);


  /**
   * Get a CompartmentType object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the CompartmentType in this Model with the identifier @p sid
   * or @c NULL if no such CompartmentType exists.
   *
   * @note The CompartmentType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  const CompartmentType* getCompartmentType (const std::string& sid) const;


  /**
   * Get a CompartmentType object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the CompartmentType in this Model with the identifier @p sid
   * or @c NULL if no such CompartmentType exists.
   *
   * @note The CompartmentType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  CompartmentType* getCompartmentType (const std::string& sid);


  /**
   * Get the nth SpeciesType object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth SpeciesType of this Model.
   *
   * @note The SpeciesType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  const SpeciesType* getSpeciesType (unsigned int n) const;


  /**
   * Get the nth SpeciesType object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth SpeciesType of this Model.
   *
   * @note The SpeciesType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  SpeciesType* getSpeciesType (unsigned int n);


  /**
   * Get a SpeciesType object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the SpeciesType in this Model with the identifier @p sid or
   * @c NULL if no such SpeciesType exists.
   *
   * @note The SpeciesType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  const SpeciesType* getSpeciesType (const std::string& sid) const;


  /**
   * Get a SpeciesType object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the SpeciesType in this Model with the identifier @p sid or
   * @c NULL if no such SpeciesType exists.
   *
   * @note The SpeciesType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  SpeciesType* getSpeciesType (const std::string& sid);


  /**
   * Get the nth Compartment object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Compartment of this Model.
   */
  const Compartment* getCompartment (unsigned int n) const;


  /**
   * Get the nth Compartment object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Compartment of this Model.
   */
  Compartment* getCompartment (unsigned int n);


  /**
   * Get a Compartment object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the Compartment in this Model with the identifier @p sid or
   * @c NULL if no such Compartment exists.
   */
  const Compartment* getCompartment (const std::string& sid) const;


  /**
   * Get a Compartment object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the Compartment in this Model with the identifier @p sid or
   * @c NULL if no such Compartment exists.
   */
  Compartment* getCompartment (const std::string& sid);


  /**
   * Get the nth Species object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Species of this Model.
   */
  const Species* getSpecies (unsigned int n) const;


  /**
   * Get the nth Species object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Species of this Model.
   */
  Species* getSpecies (unsigned int n);


  /**
   * Get a Species object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the Species in this Model with the identifier @p sid or @c NULL
   * if no such Species exists.
   */
  const Species* getSpecies (const std::string& sid) const;


  /**
   * Get a Species object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the Species in this Model with the identifier @p sid or @c NULL
   * if no such Species exists.
   */
  Species* getSpecies (const std::string& sid);


  /**
   * Get the nth Parameter object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Parameter of this Model.
   */
  const Parameter* getParameter (unsigned int n) const;


  /**
   * Get the nth Parameter object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Parameter of this Model.
   */
  Parameter* getParameter (unsigned int n);


  /**
   * Get a Parameter object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the Parameter in this Model with the identifier @p sid or @c NULL
   * if no such Parameter exists.
   */
  const Parameter* getParameter (const std::string& sid) const;


  /**
   * Get a Parameter object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the Parameter in this Model with the identifier @p sid or @c NULL
   * if no such Parameter exists.
   */
  Parameter* getParameter (const std::string& sid);


  /**
   * Get the nth InitialAssignment object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth InitialAssignment of this Model.
   */
  const InitialAssignment* getInitialAssignment (unsigned int n) const;


  /**
   * Get the nth InitialAssignment object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth InitialAssignment of this Model.
   */
  InitialAssignment* getInitialAssignment (unsigned int n);


  /**
   * Get an InitialAssignment object based on the symbol to which it
   * assigns a value.
   *
   * @param symbol the symbol to search for.
   *
   * @return the InitialAssignment in this Model with the given "symbol"
   * attribute value or @c NULL if no such InitialAssignment exists.
   */
  const InitialAssignment*
      getInitialAssignment (const std::string& symbol) const;


  /**
   * Get an InitialAssignment object based on the symbol to which it
   * assigns a value.
   *
   * @param symbol the symbol to search for.
   *
   * @return the InitialAssignment in this Model with the given "symbol"
   * attribute value or @c NULL if no such InitialAssignment exists.
   */
  const InitialAssignment*
      getInitialAssignmentBySymbol(const std::string& symbol) const;


  /**
   * Get an InitialAssignment object based on the symbol to which it
   * assigns a value.
   *
   * @param symbol the symbol to search for.
   *
   * @return the InitialAssignment in this Model with the given "symbol"
   * attribute value or @c NULL if no such InitialAssignment exists.
   */
  InitialAssignment* getInitialAssignment (const std::string& symbol);


  /**
   * Get an InitialAssignment object based on the symbol to which it
   * assigns a value.
   *
   * @param symbol the symbol to search for.
   *
   * @return the InitialAssignment in this Model with the given "symbol"
   * attribute value or @c NULL if no such InitialAssignment exists.
   */
  InitialAssignment* getInitialAssignmentBySymbol(const std::string& symbol);


  /**
   * Get the nth Rule object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Rule of this Model.
   */
  const Rule* getRule (unsigned int n) const;


  /**
   * Get the nth Rule object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Rule of this Model.
   */
  Rule* getRule (unsigned int n);


  /**
   * Get a Rule object based on the variable to which it assigns a value.
   *
   * @param variable the variable to search for.
   *
   * @return the Rule in this Model with the given "variable" attribute
   * value or @c NULL if no such Rule exists.
   */
  const Rule* getRule (const std::string& variable) const;


  /**
   * Get a Rule object based on the variable to which it assigns a value.
   *
   * @param variable the variable to search for.
   *
   * @return the Rule in this Model with the given "variable" attribute
   * value or @c NULL if no such Rule exists.
   */
  Rule* getRule (const std::string& variable);


  /**
   * Get a Rule object based on the variable to which it assigns a value.
   *
   * @param variable the variable to search for.
   *
   * @return the Rule in this Model with the given "variable" attribute
   * value or @c NULL if no such Rule exists.
   */
  const Rule* getRuleByVariable(const std::string& variable) const;


  /**
   * Get a Rule object based on the variable to which it assigns a value.
   *
   * @param variable the variable to search for.
   *
   * @return the Rule in this Model with the given "variable" attribute
   * value or @c NULL if no such Rule exists.
   */
  Rule* getRuleByVariable(const std::string& variable);


  /**
   * Get a Rule object based on the variable to which it assigns a value.
   *
   * @param variable the variable to search for.
   *
   * @return the Rule in this Model with the given "variable" attribute
   * value or @c NULL if no such Rule exists.
   */
  const AssignmentRule* getAssignmentRule (const std::string& variable) const;


  /**
   * Get a Rule object based on the variable to which it assigns a value.
   *
   * @param variable the variable to search for.
   *
   * @return the Rule in this Model with the given "variable" attribute
   * value or @c NULL if no such Rule exists.
   */
  AssignmentRule* getAssignmentRule (const std::string& variable);


  /**
   * Get a Rule object based on the variable to which it assigns a value.
   *
   * @param variable the symbol to search for.
   *
   * @return the Rule in this Model with the given "variable" attribute
   * value or @c NULL if no such Rule exists.
   */
  const RateRule* getRateRule (const std::string& variable) const;


  /**
   * Get a Rule object based on the variable to which it assigns a value.
   *
   * @param variable the variable to search for.
   *
   * @return the Rule in this Model with the given "variable" attribute
   * value or @c NULL if no such Rule exists.
   */
  RateRule* getRateRule (const std::string& variable);

  /**
   * Get a Rule object based on the variable to which it assigns a value.
   *
   * @param variable the variable to search for.
   *
   * @return the Rule in this Model with the given "variable" attribute
   * value or @c NULL if no such Rule exists.
   */
  const AssignmentRule* getAssignmentRuleByVariable(const std::string& variable) const;


  /**
   * Get a Rule object based on the variable to which it assigns a value.
   *
   * @param variable the variable to search for.
   *
   * @return the Rule in this Model with the given "variable" attribute
   * value or @c NULL if no such Rule exists.
   */
  AssignmentRule* getAssignmentRuleByVariable(const std::string& variable);


  /**
   * Get a Rule object based on the variable to which it assigns a value.
   *
   * @param variable the variable to search for.
   *
   * @return the Rule in this Model with the given "variable" attribute
   * value or @c NULL if no such Rule exists.
   */
  const RateRule* getRateRuleByVariable(const std::string& variable) const;


  /**
   * Get a Rule object based on the variable to which it assigns a value.
   *
   * @param variable the variable to search for.
   *
   * @return the Rule in this Model with the given "variable" attribute
   * value or @c NULL if no such Rule exists.
   */
  RateRule* getRateRuleByVariable(const std::string& variable);


  /**
   * Get the nth Constraint object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Constraint of this Model.
   */
  const Constraint* getConstraint (unsigned int n) const;


  /**
   * Get the nth Constraint object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Constraint of this Model.
   */
  Constraint* getConstraint (unsigned int n);


  /**
   * Get the nth Reaction object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Reaction of this Model.
   */
  const Reaction* getReaction (unsigned int n) const;


  /**
   * Get the nth Reaction object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Reaction of this Model.
   */
  Reaction* getReaction (unsigned int n);


  /**
   * Get a Reaction object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the Reaction in this Model with the identifier @p sid or @c NULL
   * if no such Reaction exists.
   */
  const Reaction* getReaction (const std::string& sid) const;


  /**
   * Get a Reaction object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the Reaction in this Model with the identifier @p sid or @c NULL
   * if no such Reaction exists.
   */
  Reaction* getReaction (const std::string& sid);


  /**
   * Get a SpeciesReference object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the SpeciesReference in this Model with the identifier @p sid or @c NULL
   * if no such SpeciesReference exists.
   */
  SpeciesReference* getSpeciesReference (const std::string& sid);


  /**
   * Get a SpeciesReference object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the SpeciesReference in this Model with the identifier @p sid or @c NULL
   * if no such SpeciesReference exists.
   */
  const SpeciesReference* getSpeciesReference (const std::string& sid) const;


  /**
   * Get a ModifierSpeciesReference object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the ModifierSpeciesReference in this Model with the 
   * identifier @p sid or @c NULL
   * if no such ModifierSpeciesReference exists.
   */
  ModifierSpeciesReference* getModifierSpeciesReference 
                                       (const std::string& sid);


  /**
   * Get a ModifierSpeciesReference object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the ModifierSpeciesReference in this Model with the 
   * identifier @p sid or @c NULL
   * if no such ModifierSpeciesReference exists.
   */
  const ModifierSpeciesReference* getModifierSpeciesReference 
                                             (const std::string& sid) const;


  /**
   * Get the nth Event object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Event of this Model.
   */
  const Event* getEvent (unsigned int n) const;


  /**
   * Get the nth Event object in this Model.
   *
   * @param n the index of the object to return.
   *
   * @return the nth Event of this Model.
   */
  Event* getEvent (unsigned int n);


  /**
   * Get an Event object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the Event in this Model with the identifier @p sid or @c NULL if
   * no such Event exists.
   */
  const Event* getEvent (const std::string& sid) const;


  /**
   * Get an Event object based on its identifier.
   *
   * @param sid the identifier to search for.
   *
   * @return the Event in this Model with the identifier @p sid or @c NULL if
   * no such Event exists.
   */
  Event* getEvent (const std::string& sid);


  /**
   * Get the number of FunctionDefinition objects in this Model.
   *
   * @return the number of FunctionDefinitions in this Model.
   */
  unsigned int getNumFunctionDefinitions () const;


  /**
   * Get the number of UnitDefinition objects in this Model.
   *
   * @return the number of UnitDefinitions in this Model.
   */
  unsigned int getNumUnitDefinitions () const;


  /**
   * Get the number of CompartmentType objects in this Model.
   *
   * @return the number of CompartmentTypes in this Model.
   *
   * @note The CompartmentType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  unsigned int getNumCompartmentTypes () const;


  /**
   * Get the number of SpeciesType objects in this Model.
   *
   * @return the number of SpeciesTypes in this Model.
   *
   * @note The SpeciesType object class is only available in SBML
   * Level&nbsp;2 Versions&nbsp;2&ndash;4.  It is not available in
   * Level&nbsp;1 nor Level&nbsp;3.
   */
  unsigned int getNumSpeciesTypes () const;


  /**
   * Get the number of Compartment objects in this Model.
   *
   * @return the number of Compartments in this Model.
   */
  unsigned int getNumCompartments () const;


  /**
   * Get the number of Specie objects in this Model.
   *
   * @return the number of Species in this Model.
   */
  unsigned int getNumSpecies () const;


  /**
   * Get the number of Species in this Model having their
   * "boundaryCondition" attribute value set to @c true.
   *
   * @return the number of Species in this Model with boundaryCondition set
   * to true.
   */
  unsigned int getNumSpeciesWithBoundaryCondition () const;


  /**
   * Get the number of Parameter objects in this Model.
   *
   * @return the number of Parameters in this Model.  Parameters defined in
   * KineticLaws are not included.
   */
  unsigned int getNumParameters () const;


  /**
   * Get the number of InitialAssignment objects in this Model.
   *
   * @return the number of InitialAssignments in this Model.
   */
  unsigned int getNumInitialAssignments () const;


  /**
   * Get the number of Rule objects in this Model.
   *
   * @return the number of Rules in this Model.
   */
  unsigned int getNumRules () const;


  /**
   * Get the number of Constraint objects in this Model.
   *
   * @return the number of Constraints in this Model.
   */
  unsigned int getNumConstraints () const;


  /**
   * Get the number of Reaction objects in this Model.
   *
   * @return the number of Reactions in this Model.
   */
  unsigned int getNumReactions () const;


  /**
   * Get the number of Event objects in this Model.
   *
   * @return the number of Events in this Model.
   */
  unsigned int getNumEvents () const;


  /**
   * Remove this Model from its parent SBMLDocument object.
   *
   * This works by finding this Model's parent SBMLDocument and then calling
   * <code>setModel(NULL)</code> on it, indirectly deleting itself.
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


  /** @cond doxygenLibsbmlInternal */
  virtual int renameAllIds(IdentifierTransformer* idTransformer, ElementFilter* filter=NULL);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  virtual void renameIDs(List* elements, IdentifierTransformer* idTransformer);
  /** @endcond */


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
   * Predicate returning @c true if the
   * given ASTNode is a boolean.
   *
   * Often times, this question can be answered with the ASTNode's own
   * isBoolean() method, but if the AST is an expression that calls a
   * function defined in the Model's ListOfFunctionDefinitions, the model
   * is needed for lookup context.
   *
   * @return true if the given ASTNode is a boolean.
   */
  bool isBoolean (const ASTNode* node) const;
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */


 /**************************************************************
  * Conversion between levels/versions
  *
  * these are internal functions used when converting
  * they are actually defined in the file SBMLConvert.cpp
  ***************************************************************/


  /*
   * Converts the model to a from SBML Level 1 to Level 2.
   *
   * Most of the necessary changes occur during the various
   * writeAttributes() methods, however there are some difference between
   * L1 and L2 that require the underlying Model to be changed.
   */
  void convertL1ToL2 ();


  /*
   * Converts the model to a from SBML Level 1 to Level 3.
   *
   * Most of the necessary changes occur during the various
   * writeAttributes() methods, however there are some difference between
   * L1 and L3 that require the underlying Model to be changed.
   */
  void convertL1ToL3 ();


  /*
   * Converts the model to a from SBML Level 2 to Level 3.
   *
   * Most of the necessary changes occur during the various
   * writeAttributes() methods, however there are some difference between
   * L2 and L3 that require the underlying Model to be changed.
   */
  void convertL2ToL3 ();

  
  /*
   * Converts the model to a from SBML Level 2 to Level 1.
   *
   * Most of the necessary changes occur during the various
   * writeAttributes() methods, however there are some difference between
   * L1 and L2 that require the underlying Model to be changed.
   */
  void convertL2ToL1 (bool strict = false);


  /*
   * Converts the model to a from SBML Level 3 to Level 1.
   *
   * Most of the necessary changes occur during the various
   * writeAttributes() methods, however there are some difference between
   * L1 and L3 that require the underlying Model to be changed.
   */
  void convertL3ToL1 ();


  /*
   * Converts the model to a from SBML Level 3 to Level 2.
   *
   * Most of the necessary changes occur during the various
   * writeAttributes() methods, however there are some difference between
   * L1 and L3 that require the underlying Model to be changed.
   */
  void convertL3ToL2 (bool strict = false);

  //void convertTimeWith(ASTNode* conversionFactor);

  //void convertExtentWith(ASTNode* conversionFactor);

  //void convertSubstanceWith(ASTNode* conversionFactor);


  /* ****************************************************
   * helper functions used by the main conversion functions 
   *******************************************************/

  /* adds species referred to in a KineticLaw to the ListOfModifiers
   * this will only be applicable when up converting an L1 model
   */
  void addModifiers ();


  /* declares constant = false for any L1 compartment/parameter
   * assigned by a rule
   */
  void addConstantAttribute ();


  /* in L1 spatialDimensions did not exist as an attribute
   * but was considered to be '3'
   * L3 does not require the attribute and will
   * only record it is officially set
   */
  void setSpatialDimensions (double dims = 3.0);


  /* in L1 and L2 there were built in values for key units
   * such as 'volume', 'length', 'area', 'substance' and 'time'
   * In L3 these have been removed - thus if a model uses one of these
   * it needs a unitDefinition to define it
   */
  void addDefinitionsForDefaultUnits ();


  void convertParametersToLocals(unsigned int level, unsigned int version);


  void setSpeciesReferenceConstantValueAndStoichiometry();

  /* new functions for strict conversion */
  void removeMetaId();


  void removeSBOTerms(bool strict);


  void removeHasOnlySubstanceUnits();


  void removeSBOTermsNotInL2V2(bool strict);


  void removeDuplicateTopLevelAnnotations();


  /*
   */
  void removeParameterRuleUnits (bool strict);


  /* StoichiometryMath does not exist in L3 but the id of
   * the species Reference can be used as a variable
   * on an assignment rule to achieve varying stoichiometry
   */
  void convertStoichiometryMath ();


  /* assigns the required values to L2 defaults
   */
  void assignRequiredValues ();


  /* deal with units values on L3 model
   */
  void dealWithModelUnits ();

  
  void dealWithStoichiometry ();

  
  void dealWithEvents (bool strict);


  /* declares constant = false for any L1 compartment/parameter
   * assigned by a rule
   */
//  void convertLayoutFromAnnotation ();

//  void convertLayoutToAnnotation ();


  /*
   * Converts the model to a from SBML Level 1 to Level 2.
   *
   * Most of the necessary changes occur during the various
   * writeAttributes() methods, however there are some difference between
   * L1 and L2 that require the underlying Model to be changed.
   */
  void convertToL2Strict ();


  /*
   * Sets the parent SBMLDocument of this SBML object.
   *
   * @param d the SBMLDocument object to set
   */
  virtual void setSBMLDocument (SBMLDocument* d);


  /**
   * Sets this SBML object to child SBML objects (if any).
   * (Creates a child-parent relationship by the parent)
   *
   * Subclasses must override this function if they define
   * one ore more child elements.
   * Basically, this function needs to be called in
   * constructor, copy constructor and assignment operator.
   *
   * @see setSBMLDocument
   * @see enablePackageInternal
   */
  virtual void connectToChild ();

  /** @endcond */


  /**
   * Returns the libSBML type code for this %SBML object.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_MODEL, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for Model, is
   * always @c "model".
   *
   * @return the name of this element, i.e., @c "model".
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
   * Populates the internal list of derived units for this Model object.
   *
   * This method tells libSBML to (re)calculate all units for all components
   * of the enclosing Model object.  The result is stored in an internal list
   * of unit data.  Users can access the resulting data by calling the method
   * SBase::getDerivedUnitDefinition() available on most objects.  (The name
   * "formula units data" is drawn from the name of the internal objects
   * libSBML uses to store the data; note that these internal objects are not
   * exposed to callers, because callers can interact with the results using
   * the ordinary SBML unit objects.)
   *
   * This method is used by libSBML itself in the validator concerned with
   * unit consistency.  The unit consistency validator (like all other
   * validators in libSBML) is invoked by using
   * SBMLDocument::checkConsistency(), with the consistency checks for the
   * category @sbmlconstant{LIBSBML_CAT_UNITS_CONSISTENCY, SBMLErrorCategory_t} turned on.  The method
   * populateListFormulaUnitsData() does not need to be called prior to
   * invoking the validator if unit consistency checking has not been turned
   * off.  This method is only provided for cases when callers have a special
   * need to force the unit data to be recalculated.  For instance, during
   * construction of a model, a caller may want to interrogate libSBML's
   * inferred units without invoking full-blown model validation; this is a
   * scenario in which calling populateListFormulaUnitsData() may be useful.
   *
   * @warning Computing and inferring units is a time-consuming operation.
   * Callers may want to call isPopulatedListFormulaUnitsData() to determine
   * whether the units may already have been computed, to save themselves the
   * need of invoking unit inference unnecessarily.
   *
   * @see isPopulatedListFormulaUnitsData()
   */
  void populateListFormulaUnitsData();


  /**
   * Predicate returning @c true if libSBML has derived units for the
   * components of this model.
   *
   * LibSBML can infer the units of measurement associated with different
   * elements of a model.  When libSBML does that, it builds a complex
   * internal structure during a resource-intensive operation.  This is done
   * automatically only when callers invoke validation (via
   * SBMLDocument::checkConsistency()) and have not turned off the unit
   * validation option.
   *
   * Callers can force units to be recalculated by calling
   * populateListFormulaUnitsData().  To avoid calling that method
   * unnecessarily, calling programs may first want to invoke this method
   * (isPopulatedListFormulaUnitsData()) to determine whether it is even
   * necessary.
   *
   * @return @c true if the units have already been computed, @c false
   * otherwise.
   */
  bool isPopulatedListFormulaUnitsData();


  /** @cond doxygenLibsbmlInternal */

  /**
   * Adds a copy of the given FormulaUnitsData object to this Model.
   *
   * @param fud the FormulaUnitsData to add
   */
  void addFormulaUnitsData (const FormulaUnitsData* fud);


  /**
   * Creates a new FormulaUnitsData inside this Model and returns it.
   *
   * @return the FormulaUnitsData object created
   */
  FormulaUnitsData* createFormulaUnitsData ();


  /**
   * Get the nth FormulaUnitsData object in this Model.
   *
   * @return the nth FormulaUnitsData of this Model.
   */
  const FormulaUnitsData* getFormulaUnitsData (unsigned int n) const;


  /**
   * Get the nth FormulaUnitsData object in this Model.
   *
   * @return the nth FormulaUnitsData of this Model.
   */
  FormulaUnitsData* getFormulaUnitsData (unsigned int n);


  /**
   * Get a FormulaUnitsData object based on its unitReferenceId and typecode.
   *
   * @return the FormulaUnitsData in this Model with the unitReferenceId @p sid 
   * and the typecode (int) @p typecode or @c NULL
   * if no such FormulaUnitsData exists.
   *
   * @note The typecode (int) parameter is necessary as the unitReferenceId
   * of the FormulaUnitsData need not be unique. For example if a Species
   * with id 's' is assigned by an AssignmentRule there will be two 
   * elements of the FormulaUnitsData list with the unitReferenceId 's'; 
   * one with
   * typecode 'SBML_SPECIES' referring to the units related to the species, 
   * the other with typecode 'SBML_ASSIGNMENT_RULE' referring to the units
   * derived from the math element of the AssignmentRule.
   */
  const FormulaUnitsData*
  getFormulaUnitsData (const std::string& sid, int typecode) const;


  /**
   * Get a FormulaUnitsData object based on its unitReferenceId and typecode.
   *
   * @return the FormulaUnitsData in this Model with the unitReferenceId @p sid 
   * and the typecode (int) @p typecode or @c NULL
   * if no such FormulaUnitsData exists.
   *
   * @note The typecode (int) parameter is necessary as the unitReferenceId
   * of the FormulaUnitsData need not be unique. For example if a Species
   * with id 's' is assigned by an AssignmentRule there will be two 
   * elements of the FormulaUnitsData list with the unitReferenceId 's'; 
   * one with
   * typecode 'SBML_SPECIES' referring to the units related to the species, 
   * the other with typecode 'SBML_ASSIGNMENT_RULE' referring to the units
   * derived from the math element of the AssignmentRule.
   */
  FormulaUnitsData*
  getFormulaUnitsData(const std::string& sid, int);


  /**
   * Get a FormulaUnitsData variable object based on its unitReferenceId.
   *
   * @return the FormulaUnitsData in this Model with the unitReferenceId @p sid 
   * that corrsponds to a variable object or @c NULL
   * if no such FormulaUnitsData exists.
   *
   * @note  This function restricts the search to classes that can be varied
   * Species, Compartment, Parameter, SpeciesReference.
   */
  FormulaUnitsData*
  getFormulaUnitsDataForVariable(const std::string& sid);


  /**
   * Get a FormulaUnitsData variable object based on its unitReferenceId.
   *
   * @return the FormulaUnitsData in this Model with the unitReferenceId @p sid 
   * that corrsponds to a variable object or @c NULL
   * if no such FormulaUnitsData exists.
   *
   * @note  This function restricts the search to classes that can be varied
   * Species, Compartment, Parameter, SpeciesReference.
   */
  FormulaUnitsData*
  getFormulaUnitsDataForAssignment(const std::string& sid);


  /**
   * Get the number of FormulaUnitsData objects in this Model.
   *
   * @return the number of FormulaUnitsData in this Model.
   */
  unsigned int getNumFormulaUnitsData () const;


  /**
   * Get the list of FormulaUnitsData object in this Model.
   *
   * @return the list of FormulaUnitsData for this Model.
   */
  List* getListFormulaUnitsData ();


  /**
   * Get the list of FormulaUnitsData object in this Model.
   *
   * @return the list of FormulaUnitsData for this Model.
   */
  const List* getListFormulaUnitsData () const;

  
  /** @endcond */


  /**
   * Predicate returning @c true if all the required elements for this Model
   * object have been set.
   *
   * @return a boolean value indicating whether all the required
   * elements for this object have been defined.
   */
  virtual bool hasRequiredElements() const ;


  /**
   * Removes the nth FunctionDefinition object from this Model object and 
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the FunctionDefinition object to remove
   *
   * @return the FunctionDefinition object removed, or @c NULL if the given
   * index is out of range.
   *
   */
  FunctionDefinition* removeFunctionDefinition (unsigned int n);


  /**
   * Removes the FunctionDefinition object with the given identifier from this Model 
   * object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param sid the identifier of the FunctionDefinition object to remove
   *
   * @return the FunctionDefinition object removed, or @c NULL if no
   * FunctionDefinition object with the identifier exists in this Model
   * object.
   */
  FunctionDefinition* removeFunctionDefinition (const std::string& sid);


  /**
   * Removes the nth UnitDefinition object from this Model object and
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the UnitDefinition object to remove
   *
   * @return the UnitDefinition object removed., or @c NULL if the given
   * index is out of range.
   *
   */
  UnitDefinition* removeUnitDefinition (unsigned int n);


  /**
   * Removes the UnitDefinition object with the given identifier from this Model
   * object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param sid the identifier of the UnitDefinition object to remove
   *
   * @return the UnitDefinition object removed, or @c NULL if no
   * UnitDefinition object with the identifier exists in this Model object.
   */
  UnitDefinition* removeUnitDefinition (const std::string& sid);


  /**
   * Removes the nth CompartmentType object from this Model object and
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the CompartmentType object to remove
   *
   * @return the ComapartmentType object removed, or @c NULL if the given
   * index is out of range.
   *
   */
  CompartmentType* removeCompartmentType (unsigned int n);


  /**
   * Removes the CompartmentType object with the given identifier from this Model
   * object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param sid the identifier of the object to remove
   *
   * @return the CompartmentType object removed, or @c NULL if no
   * CompartmentType object with the identifier exists in this Model object.
   */
  CompartmentType* removeCompartmentType (const std::string& sid);


  /**
   * Removes the nth SpeciesType object from this Model object and
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the SpeciesType object to remove
   *
   * @return the SpeciesType object removed, or @c NULL if the given index is
   * out of range.
   *
   */
  SpeciesType* removeSpeciesType (unsigned int n);


  /**
   * Removes the SpeciesType object with the given identifier from this Model
   * object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param sid the identifier of the SpeciesType object to remove
   *
   * @return the SpeciesType object removed, or @c NULL if no SpeciesType
   * object with the identifier exists in this Model object.
   *
   */
  SpeciesType* removeSpeciesType (const std::string& sid);


  /**
   * Removes the nth Compartment object from this Model object and
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the Compartment object to remove
   *
   * @return the Compartment object removed, or @c NULL if the given index is
   * out of range.
   *
   */
  Compartment* removeCompartment (unsigned int n);


  /**
   * Removes the Compartment object with the given identifier from this Model
   * object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param sid the identifier of the Compartment object to remove
   *
   * @return the Compartment object removed, or @c NULL if no Compartment
   * object with the identifier exists in this Model object.
   */
  Compartment* removeCompartment (const std::string& sid);


  /**
   * Removes the nth Species object from this Model object and
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the Species object to remove
   *
   * @return the Species object removed, or @c NULL if the given index is out
   * of range.
   *
   */
  Species* removeSpecies (unsigned int n);


  /**
   * Removes the Species object with the given identifier from this Model
   * object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param sid the identifier of the Species object to remove
   *
   * @return the Species object removed, or @c NULL if no Species object with
   * the identifier exists in this Model object.
   *
   */
  Species* removeSpecies (const std::string& sid);


  /**
   * Removes the nth Parameter object from this Model object and
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the Parameter object to remove
   *
   * @return the Parameter object removed, or @c NULL if the given index is
   * out of range.
   *
   */
  Parameter* removeParameter (unsigned int n);


  /**
   * Removes the Parameter object with the given identifier from this Model
   * object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param sid the identifier of the Parameter object to remove
   *
   * @return the Parameter object removed, or @c NULL if no Parameter object
   * with the identifier exists in this Model object.
   */
  Parameter* removeParameter (const std::string& sid);


  /**
   * Removes the nth InitialAssignment object from this Model object and
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the InitialAssignment object to remove
   *
   * @return the InitialAssignment object removed, or @c NULL if the given
   * index is out of range.
   *
   */
  InitialAssignment* removeInitialAssignment (unsigned int n);


  /**
   * Removes the InitialAssignment object with the given "symbol" attribute 
   * from this Model object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param symbol the "symbol" attribute of the InitialAssignment object to remove
   *
   * @return the InitialAssignment object removed, or @c NULL if no
   * InitialAssignment object with the "symbol" attribute exists in this
   * Model object.
   */
  InitialAssignment* removeInitialAssignment (const std::string& symbol);


  /**
   * Removes the nth Rule object from this Model object and
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the Rule object to remove
   *
   * @return the Rule object removed, or @c NULL if the given index is out of
   * range.
   *
   */
  Rule* removeRule (unsigned int n);


  /**
   * Removes the Rule object with the given "variable" attribute from this Model 
   * object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param variable the "variable" attribute of the Rule object to remove
   *
   * @return the Rule object removed, or @c NULL if no Rule object with the
   * "variable" attribute exists in this Model object.
   */
  Rule* removeRule (const std::string& variable);

  /**
   * Removes the Rule object with the given "variable" attribute from this Model 
   * object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param variable the "variable" attribute of the Rule object to remove
   *
   * @return the Rule object removed, or @c NULL if no Rule object with the
   * "variable" attribute exists in this Model object.
   */
  Rule* removeRuleByVariable (const std::string& variable);


  /**
   * Removes the nth Constraint object from this Model object and
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the Constraint object to remove
   *
   * @return the Constraint object removed, or @c NULL if the given index is
   * out of range.
   *
   */
  Constraint* removeConstraint (unsigned int n);


  /**
   * Removes the nth Reaction object from this Model object and
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the Reaction object to remove
   *
   * @return the Reaction object removed, or @c NULL if the given index is
   * out of range.
   *
   */
  Reaction* removeReaction (unsigned int n);


  /**
   * Removes the Reaction object with the given identifier from this Model
   * object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param sid the identifier of the Reaction object to remove
   *
   * @return the Reaction object removed, or @c NULL if no Reaction object
   * with the identifier exists in this Model object.
   *
   */
  Reaction* removeReaction (const std::string& sid);


  /**
   * Removes the nth Event object from this Model object and
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the Event object to remove
   *
   * @return the Event object removed, or @c NULL if the given index is out
   * of range.
   *
   */
  Event* removeEvent (unsigned int n);


  /**
   * Removes the Event object with the given identifier from this Model
   * object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param sid the identifier of the Event object to remove
   *
   * @return the Event object removed, or @c NULL if no Event object with the
   * identifier exists in this Model object.
   *
   */
  Event* removeEvent (const std::string& sid);


  /**
   * Copies a given Model object's subcomponents and appends the copies to
   * the appropriate places in this Model.
   *
   * This method also calls the <code>appendFrom</code> method on all libSBML
   * plug-in objects.
   *
   * @copydetails doc_what_are_plugins
   *
   * @param model the Model to merge with this one.
   *
   */
  virtual int appendFrom(const Model* model);


  /** @cond doxygenLibsbmlInternal */
  /**
   * Enables/Disables the given package with this element and child elements
   * (if any).  (This is an internal implementation for enablePackage
   * function)
   *
   * @note Subclasses of the SBML Core package in which one or more child
   * elements are defined must override this function.
   */
  virtual void enablePackageInternal(const std::string& pkgURI, const std::string& pkgPrefix, bool flag);
  /** @endcond */


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
   * Create and return an SBML object of this class, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or @c NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);


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
   * Synchronizes the annotation of this SBML object.
   *
   * Annotation element (XMLNode* mAnnotation) is synchronized with the
   * current CVTerm objects (List* mCVTerm), ModelHistory object 
   * (ModelHistory* mHistory) and ListOfLayouts object (ListOfLayouts mLayouts).
   * Currently, this method is called in getAnnotation, isSetAnnotation,
   * and writeElements methods.
   */
  virtual void syncAnnotation();

  std::string     mId;
  std::string     mName;
  std::string     mSubstanceUnits;
  std::string     mTimeUnits;
  std::string     mVolumeUnits;
  std::string     mAreaUnits;
  std::string     mLengthUnits;
  std::string     mExtentUnits;
  std::string     mConversionFactor;


  ListOfFunctionDefinitions  mFunctionDefinitions;
  ListOfUnitDefinitions      mUnitDefinitions;
  ListOfCompartmentTypes     mCompartmentTypes;
  ListOfSpeciesTypes         mSpeciesTypes;
  ListOfCompartments         mCompartments;
  ListOfSpecies              mSpecies;
  ListOfParameters           mParameters;
  ListOfInitialAssignments   mInitialAssignments;
  ListOfRules                mRules;
  ListOfConstraints          mConstraints;
  ListOfReactions            mReactions;
  ListOfEvents               mEvents;

  List *                     mFormulaUnitsData;


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

  private:

  /** @cond doxygenLibsbmlInternal */

  /**
   * Internal function used in populateListFormulaUnitsData
   */
  void populatePerTimeUnitDefinition(FormulaUnitsData *fud);

  /**
   * Internal function used in populateListFormulaUnitsData
   */
  void createSpeciesReferenceUnitsData(SpeciesReference* sr,
                             UnitFormulaFormatter* unitFormatter);

  /*
   * Clears the list of FormulaUnitsData object in this Model.
   */
  void removeListFormulaUnitsData();

  
  /*
   * creates the substance units data item
   */
  void createSubstanceUnitsData();

  UnitDefinition* getL3SubstanceUD();

  UnitDefinition* getSubstanceUD();

  
  /*
   * creates the time units data item
   */
  void createTimeUnitsData();

  UnitDefinition* getL3TimeUD();

  UnitDefinition* getTimeUD();

  
  /*
   * creates the volume units data item
   */
  void createVolumeUnitsData();

  UnitDefinition* getL3VolumeUD();

  UnitDefinition* getVolumeUD();

  
  /*
   * creates the area units data item
   */
  void createAreaUnitsData();

  UnitDefinition* getL3AreaUD();

  UnitDefinition* getAreaUD();

  
  /*
   * creates the length units data item
   */
  void createLengthUnitsData();

  UnitDefinition* getL3LengthUD();

  UnitDefinition* getLengthUD();

  
  /*
   * creates the extent units data item
   */
  void createExtentUnitsData();

  UnitDefinition* getL3ExtentUD();


  /*
   * creates the substance_per_time units data item
   */
  void createSubstancePerTimeUnitsData();

  UnitDefinition* getL3SubstancePerTimeUD(FormulaUnitsData* fud);

  UnitDefinition* getSubstancePerTimeUD();

  /*
   * creates the units data for 'variables'
   */

  void createCompartmentUnitsData();

  void createSpeciesUnitsData();

  void createL3SpeciesUnitsData();

  void createParameterUnitsData();


  /* create units data for objects with math */

  void createUnitsDataFromMath(UnitFormulaFormatter * unitFormatter,
                       FormulaUnitsData * fud, const ASTNode * math);

  void createInitialAssignmentUnitsData(UnitFormulaFormatter * unitFormatter);

  void createRuleUnitsData(UnitFormulaFormatter * unitFormatter);

  void createReactionUnitsData(UnitFormulaFormatter * unitFormatter);

  void createEventUnitsData(UnitFormulaFormatter * unitFormatter);

  void createDelayUnitsData(UnitFormulaFormatter* unitFormatter, Event * e, 
                            const std::string& eventId);

  void createPriorityUnitsData(UnitFormulaFormatter* unitFormatter, 
                               Priority * p, const std::string& eventId);

  void createEventAssignmentUnitsData(UnitFormulaFormatter* unitFormatter, 
                            EventAssignment * ea, const std::string& eventId);




  /** @endcond */

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new Model_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * Model_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * Model_t
 *
 * @return a pointer to the newly created Model_t structure.
 *
 * @note Once a Model_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the Model_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Model_t *
Model_create (unsigned int level, unsigned int version);


/**
 * Creates a new Model_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to this Model_t
 *
 * @return a pointer to the newly created Model_t structure.
 *
 * @note Once a Model_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the Model_t.  Despite this, the ability to supply the values at creation time
 * is an important aid to creating valid SBML.  Knowledge of the intended SBML
 * Level and Version determine whether it is valid to assign a particular value
 * to an attribute, or whether it is valid to add a structure to an existing
 * SBMLDocument_t.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Model_t *
Model_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Creates and returns a deep copy of a given Model_t structure.
 *
 * @param m the Model_t structure to copy
 *
 * @return a (deep) copy of this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Model_t *
Model_clone (const Model_t *m);


/**
 * Frees the given Model_t structure.
 *
 * @param m the Model_structure to free
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
void
Model_free (Model_t *m);


/**
 * Returns a list of XMLNamespaces_t associated with this Model_t
 * structure.
 *
 * @param m the Model_t structure
 *
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
Model_getNamespaces(Model_t *m);


/**
 * Get the identifier of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the id of this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
const char *
Model_getId (const Model_t *m);


/**
 * Get the name of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the name of this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
const char *
Model_getName (const Model_t *m);


/**
 * Get the substanceUnits of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the substanceUnits of this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
const char *
Model_getSubstanceUnits (const Model_t *m);


/**
 * Get the timeUnits of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the timeUnits of this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
const char *
Model_getTimeUnits (const Model_t *m);


/**
 * Get the volumeUnits of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the volumeUnits of this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
const char *
Model_getVolumeUnits (const Model_t *m);


/**
 * Get the areaUnits of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the areaUnits of this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
const char *
Model_getAreaUnits (const Model_t *m);


/**
 * Get the lengthUnits of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the lengthUnits of this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
const char *
Model_getLengthUnits (const Model_t *m);


/**
 * Get the extentUnits of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the extentUnits of this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
const char *
Model_getExtentUnits (const Model_t *m);


/**
 * Get the conversionFactor of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the conversionFactor of this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
const char *
Model_getConversionFactor (const Model_t *m);


/**
 * Predicate for testing whether the identifier of a given Model_t
 * structure is assigned.
 *
 * @param m the Model_t structure
 *
 * @return nonzero if the "id" attribute of this Model_t structure is 
 * set, zero (0) otherwise.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_isSetId (const Model_t *m);


/**
 * Predicate for testing whether the name of a given Model_t structure is
 * assigned.
 *
 * @param m the Model_t structure
 *
 * @return nonzero if the "name" attribute of this Model_t structure is
 * set, zero (0) otherwise.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_isSetName (const Model_t *m);


/**
 * Predicate for testing whether the substanceUnits of a given Model_t structure is
 * assigned.
 *
 * @param m the Model_t structure
 *
 * @return nonzero if the "substanceUnits" attribute of this Model_t structure is
 * set, zero (0) otherwise.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_isSetSubstanceUnits (const Model_t *m);


/**
 * Predicate for testing whether the timeUnits of a given Model_t structure is
 * assigned.
 *
 * @param m the Model_t structure
 *
 * @return nonzero if the "timeUnits" attribute of this Model_t structure is
 * set, zero (0) otherwise.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_isSetTimeUnits (const Model_t *m);


/**
 * Predicate for testing whether the volumeUnits of a given Model_t structure is
 * assigned.
 *
 * @param m the Model_t structure
 *
 * @return nonzero if the "volumeUnits" attribute of this Model_t structure is
 * set, zero (0) otherwise.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_isSetVolumeUnits (const Model_t *m);


/**
 * Predicate for testing whether the areaUnits of a given Model_t structure is
 * assigned.
 *
 * @param m the Model_t structure
 *
 * @return nonzero if the "areaUnits" attribute of this Model_t structure is
 * set, zero (0) otherwise.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_isSetAreaUnits (const Model_t *m);


/**
 * Predicate for testing whether the lengthUnits of a given Model_t structure is
 * assigned.
 *
 * @param m the Model_t structure
 *
 * @return nonzero if the "lengthUnits" attribute of this Model_t structure is
 * set, zero (0) otherwise.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_isSetLengthUnits (const Model_t *m);


/**
 * Predicate for testing whether the extentUnits of a given Model_t structure is
 * assigned.
 *
 * @param m the Model_t structure
 *
 * @return nonzero if the "extentUnits" attribute of this Model_t structure is
 * set, zero (0) otherwise.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_isSetExtentUnits (const Model_t *m);


/**
 * Predicate for testing whether the conversionFactor of a given Model_t structure is
 * assigned.
 *
 * @param m the Model_t structure
 *
 * @return nonzero if the "conversionFactor" attribute of this Model_t structure is
 * set, zero (0) otherwise.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_isSetConversionFactor (const Model_t *m);


/**
 * Set the identifier of a given Model_t structure.
 *
 * This copies the string in @p sid.
 *
 * @param m the Model_t structure
 * @param sid the identifier string
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
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_setId (Model_t *m, const char *sid);


/**
 * Set the identifier of the given Model_t structure.
 *
 * This copies the string in @p name.
 *
 * @param m the Model_t structure
 * @param name the name string
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
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_setName (Model_t *m, const char *name);


/**
 * Set the substanceUnits attribute of a given Model_t structure.
 *
 * This copies the string in @p units.
 *
 * @param m the Model_t structure
 * @param units the identifier string
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with units NULL is equivalent to
 * unsetting the "substanceUnits" attribute.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_setSubstanceUnits (Model_t *m, const char *units);


/**
 * Set the timeUnits attribute of a given Model_t structure.
 *
 * This copies the string in @p units.
 *
 * @param m the Model_t structure
 * @param units the identifier string
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with units NULL is equivalent to
 * unsetting the "timeUnits" attribute.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_setTimeUnits (Model_t *m, const char *units);


/**
 * Set the volumeUnits attribute of a given Model_t structure.
 *
 * This copies the string in @p units.
 *
 * @param m the Model_t structure
 * @param units the identifier string
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with units NULL is equivalent to
 * unsetting the "volumeUnits" attribute.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_setVolumeUnits (Model_t *m, const char *units);


/**
 * Set the areaUnits attribute of a given Model_t structure.
 *
 * This copies the string in @p units.
 *
 * @param m the Model_t structure
 * @param units the identifier string
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with units NULL is equivalent to
 * unsetting the "areaUnits" attribute.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_setAreaUnits (Model_t *m, const char *units);


/**
 * Set the lengthUnits attribute of a given Model_t structure.
 *
 * This copies the string in @p units.
 *
 * @param m the Model_t structure
 * @param units the identifier string
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with units NULL is equivalent to
 * unsetting the "lengthUnits" attribute.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_setLengthUnits (Model_t *m, const char *units);


/**
 * Set the extentUnits attribute of a given Model_t structure.
 *
 * This copies the string in @p units.
 *
 * @param m the Model_t structure
 * @param units the identifier string
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with units NULL is equivalent to
 * unsetting the "extentUnits" attribute.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_setExtentUnits (Model_t *m, const char *units);


/**
 * Set the conversionFactor attribute of a given Model_t structure.
 *
 * This copies the string in @p sid.
 *
 * @param m the Model_t structure
 * @param sid the identifier string
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 *
 * @note Using this function with sid NULL is equivalent to
 * unsetting the "conversionFactor" attribute.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_setConversionFactor (Model_t *m, const char *sid);


/**
 * Unsets the "id" attribute of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_unsetId (Model_t *m);


/**
 * Unsets the "name" attribute of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_unsetName (Model_t *m);


/**
 * Unsets the "substanceUnits" attribute of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_unsetSubstanceUnits (Model_t *m);


/**
 * Unsets the "timeUnits" attribute of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_unsetTimeUnits (Model_t *m);


/**
 * Unsets the "volumeUnits" attribute of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_unsetVolumeUnits (Model_t *m);


/**
 * Unsets the "areaUnits" attribute of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_unsetAreaUnits (Model_t *m);


/**
 * Unsets the "lengthUnits" attribute of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_unsetLengthUnits (Model_t *m);


/**
 * Unsets the "extentUnits" attribute of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_unsetExtentUnits (Model_t *m);


/**
 * Unsets the "conversionFactor" attribute of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_unsetConversionFactor (Model_t *m);


/**
 * Returns the ModelHistory_t of the given Model_t structure.
 *
 * @return the ModelHistory_t of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ModelHistory_t *
Model_getModelHistory(Model_t *m);


/**
 * Predicate for testing whether the ModelHistory_t of a given Model_t structure is
 * assigned.
 *
 * @param m the Model_t structure
 *
 * @return nonzero if the ModelHistory_t of this Model_t structure is
 * set, zero (0) otherwise.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int 
Model_isSetModelHistory(Model_t *m);


/**
 * Set the ModelHistory_t of the given Model_t structure.
 *
 * @param m the Model_t structure
 * @param history the ModelHistory_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int 
Model_setModelHistory(Model_t *m, ModelHistory_t *history);


/**
 * Unsets the ModelHistory_t of the given Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int 
Model_unsetModelHistory(Model_t *m);


/**
 * Adds a copy of a FunctionDefinition_t structure to a given Model_t
 * structure.
 *
 * @param m the Model_t structure
 * @param fd the FunctionDefinition_t structure to copy and add
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_addFunctionDefinition (Model_t *m, const FunctionDefinition_t *fd);


/**
 * Adds a copy of a UnitDefinition_t structure to a given Model_t structure.
 *
 * @param m the Model_t structure
 * @param ud the UnitDefinition_t structure to copy and add
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_addUnitDefinition (Model_t *m, const UnitDefinition_t *ud);


/**
 * Adds a copy of a CompartmentType_t structure to a given Model_t structure.
 *
 * @param m the Model_t structure
 * @param ct the CompartmentType_t structure to copy and add
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_addCompartmentType (Model_t *m, const CompartmentType_t *ct);


/**
 * Adds a copy of a SpeciesType_t structure to a given Model_t structure.
 *
 * @param m the Model_t structure
 * @param st the SpeciesType_t structure to copy and add
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_addSpeciesType (Model_t *m, const SpeciesType_t *st);


/**
 * Adds a copy of a Compartment_t structure to a given Model_t structure.
 *
 * @param m the Model_t structure
 * @param c the Compartment_t structure to copy and add
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_addCompartment (Model_t *m, const Compartment_t *c);


/**
 * Adds a copy of a Species_t structure to a given Model_t structure.
 *
 * @param m the Model_t structure
 * @param s the Species_t structure to copy and add
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_addSpecies (Model_t *m, const Species_t *s);


/**
 * Adds a copy of a Parameter_t structure to a given Model_t structure.
 *
 * @param m the Model_t structure
 * @param p the Parameter_t structure to copy and add
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_addParameter (Model_t *m, const Parameter_t *p);


/**
 * Adds a copy of a InitialAssignment_t structure to a given Model_t structure.
 *
 * @param m the Model_t structure
 * @param ia the InitialAssignment_t structure to copy and add
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_addInitialAssignment (Model_t *m, const InitialAssignment_t *ia);


/**
 * Adds a copy of a Rule_t structure to a given Model_t structure.
 *
 * @param m the Model_t structure
 * @param r the Rule_t structure to copy and add
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_addRule (Model_t *m, const Rule_t *r);


/**
 * Adds a copy of a Constraint_t structure to a given Model_t structure.
 *
 * @param m the Model_t structure
 * @param c the Constraint_t structure to copy and add
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_addConstraint (Model_t *m, const Constraint_t *c);


/**
 * Adds a copy of a Reaction_t structure to a given Model_t structure.
 *
 * @param m the Model_t structure
 * @param r the Reaction_t structure to copy and add
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_addReaction (Model_t *m, const Reaction_t *r);


/**
 * Adds a copy of a Event_t structure to a given Model_t structure.
 *
 * @param m the Model_t structure
 * @param e the Event_t structure to copy and add
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_DUPLICATE_OBJECT_ID, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int
Model_addEvent (Model_t *m, const Event_t *e);


/**
 * Creates a new FunctionDefinition_t structure inside the given Model_t
 * and returns a pointer to it.
 *
 * @param m the Model_t structure
 *
 * @return the new FunctionDefinition_t structure
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
FunctionDefinition_t *
Model_createFunctionDefinition (Model_t *m);


/**
 * Creates a new UnitDefinition_t structure inside the given Model_t and
 * returns a pointer to it.
 *
 * @param m the Model_t structure
 *
 * @return the new UnitDefinition_t structure
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
UnitDefinition_t *
Model_createUnitDefinition (Model_t *m);


/**
 * Creates a new Unit_t structure inside the last UnitDefinition_t
 * structure created in this model and returns a pointer to it.
 *
 * The mechanism by which the UnitDefinition_t structure was created is not
 * significant.  If a UnitDefinition_t does not exist in this model, a new
 * Unit_t structure is @em not created and @c NULL is returned instead.
 *
 * @param m the Model_t structure
 *
 * @return the Unit_t structure created, or @c NULL.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Unit_t *
Model_createUnit (Model_t *m);


/**
 * Creates a new CompartmentType_t structure inside the given Model_t and
 * returns a pointer to it.
 *
 * @param m the Model_t structure
 *
 * @return the CompartmentType_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
CompartmentType_t *
Model_createCompartmentType (Model_t *m);


/**
 * Creates a new SpeciesType_t structure inside the given Model_t and
 * returns a pointer to it.
 *
 * @param m the Model_t structure
 *
 * @return the SpeciesType_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
SpeciesType_t *
Model_createSpeciesType (Model_t *m);


/**
 * Creates a new Compartment_t structure inside the given Model_t and
 * returns a pointer to it.
 *
 * @param m the Model_t structure
 *
 * @return the Compartment_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Compartment_t *
Model_createCompartment (Model_t *m);


/**
 * Creates a new Species_t structure inside the given Model_t and returns a
 * pointer to it.
 *
 * @param m the Model_t structure
 *
 * @return the Species_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Species_t *
Model_createSpecies (Model_t *m);


/**
 * Creates a new Parameter_t structure inside the given Model_t and returns
 * a pointer to it.
 *
 * @param m the Model_t structure
 *
 * @return the Parameter_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Parameter_t *
Model_createParameter (Model_t *m);


/**
 * Creates a new InitialAssignment_t structure inside the given Model_t
 * structure and returns it.
 *
 * @param m the Model_t structure
 *
 * @return the InitialAssignment_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
InitialAssignment_t *
Model_createInitialAssignment (Model_t *m);


/**
 * Creates a new AlgebraicRule_t structure inside the given Model_t
 * structure and returns a pointer to it.
 *
 * @param m the Model_t structure
 *
 * @return the AlgebraicRule_t structure created.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Rule_t *
Model_createAlgebraicRule (Model_t *m);


/**
 * Creates a new AssignmentRule_t structure inside the given Model_t
 * structure and returns a pointer to it.
 *
 * @param m the Model_t structure
 *
 * @return the AssignmentRule_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Rule_t *
Model_createAssignmentRule (Model_t *m);


/**
 * Creates a new RateRule_t structure inside the given Model_t structure
 * and returns a pointer to it.
 *
 * @param m the Model_t structure
 *
 * @return the RateRule_t structure created.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Rule_t *
Model_createRateRule (Model_t *m);


/**
 * Creates a new Constraint_t structure inside the given Model_t structure
 * and returns it.
 *
 * @param m the Model_t structure
 *
 * @return the Constraint_t structure created.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Constraint_t *
Model_createConstraint (Model_t *m);


/**
 * Creates a new Reaction_t structure inside the given Model_t structure
 * and returns a pointer to it.
 *
 * @param m the Model_t structure
 *
 * @return the Reaction_t structure created.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Reaction_t *
Model_createReaction (Model_t *m);


/**
 * Creates a new SpeciesReference_t structure for a reactant inside the
 * last Reaction_t structure in the given Model_t structure, and returns a
 * pointer to it.
 *
 * The mechanism by which the last Reaction_t structure was created and
 * added to @p m is not significant.  It could have been created in a
 * variety of ways, for example using Model_createReaction().  If a
 * Reaction_t structure does not exist, a new SpeciesReference_t structure
 * is @em not created and @c NULL is returned instead.
 *
 * @param m the Model_t structure
 *
 * @return the SpeciesReference_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
SpeciesReference_t *
Model_createReactant (Model_t *m);


/**
 * Creates a new SpeciesReference_t structure for a product inside the
 * last Reaction_t structure in the given Model_t structure, and returns a
 * pointer to it.
 *
 * The mechanism by which the last Reaction_t structure was created and
 * added to @p m is not significant.  It could have been created in a
 * variety of ways, for example using Model_createReaction().  If a
 * Reaction_t structure does not exist, a new SpeciesReference_t structure
 * is @em not created and @c NULL is returned instead.
 *
 * @param m the Model_t structure
 *
 * @return the SpeciesReference_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
SpeciesReference_t *
Model_createProduct (Model_t *m);


/**
 * Creates a new modifier SpeciesReference_t structure for a reactant inside
 * the last Reaction_t structure in the given Model_t structure, and
 * returns a pointer to it.
 *
 * The mechanism by which the last Reaction_t structure was created and
 * added to @p m is not significant.  It could have been created in a
 * variety of ways, for example using Model_createReaction().  If a
 * Reaction_t structure does not exist, a new modifier SpeciesReference_t
 * structure is @em not created and @c NULL is returned instead.
 *
 * @param m the Model_t structure
 *
 * @return the modifier SpeciesReference_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
SpeciesReference_t *
Model_createModifier (Model_t *m);


/**
 * Creates a new KineticLaw_t structure inside the last Reaction_t
 * structure in the given Model_t structure, and returns a pointer to it.
 *
 * The mechanism by which the last Reaction_t structure was created and
 * added to @p m is not significant.  It could have been created in a
 * variety of ways, for example using Model_createReaction().  If a
 * Reaction_t structure does not exist for the model, or a Reaction_t
 * structure exists but already contains a KineticLaw_t structure, a new
 * KineticLaw_t is @em not created and @c NULL is returned instead.
 *
 * @param m the Model_t structure
 *
 * @return the KineticLaw_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
KineticLaw_t *
Model_createKineticLaw (Model_t *m);


/**
 * Creates a new local Parameter_t structure inside the KineticLaw_t
 * structure of the last Reaction_t structure created inside the given
 * model, and returns a pointer to it.
 *
 * The last KineticLaw_t structure could have been created in a variety of
 * ways.  For example, it could have been added using
 * Model_createKineticLaw(), or it could be the result of using
 * Reaction_createKineticLaw() on the Reaction_t structure created by a
 * Model_createReaction().  If a Reaction_t structure does not exist for
 * this model, or the last Reaction_t structure does not contain a
 * KineticLaw_t structure, a new Parameter_t is @em not created and NULL is
 * returned instead.
 *
 * @param m the Model_t structure
 *
 * @return the Parameter_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Parameter_t *
Model_createKineticLawParameter (Model_t *m);


/**
 * Creates a new LocalParameter_t structure inside the KineticLaw_t
 * structure of the last Reaction_t structure created inside the given
 * model, and returns a pointer to it.
 *
 * The last KineticLaw_t structure could have been created in a variety of
 * ways.  For example, it could have been added using
 * Model_createKineticLaw(), or it could be the result of using
 * Reaction_createKineticLaw() on the Reaction_t structure created by a
 * Model_createReaction().  If a Reaction_t structure does not exist for
 * this model, or the last Reaction_t structure does not contain a
 * KineticLaw_t structure, a new Parameter_t is @em not created and NULL is
 * returned instead.
 *
 * @param m the Model_t structure
 *
 * @return the LocalParameter_t structure created
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
LocalParameter_t *
Model_createKineticLawLocalParameter (Model_t *m);


/**
 * Creates a new Event inside the given Model_t structure and returns a
 * pointer to it.
 *
 * @param m the Model_t structure
 *
 * @return a new Event_t structure
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Event_t *
Model_createEvent (Model_t *m);


/**
 * Creates a new EventAssignment_t structure inside the last Event_t
 * structure created in the given Model_t structure, and returns a pointer
 * to it.
 *
 * The mechanism by which the last Event_t structure was created is not
 * significant.  It could have been created in a variety of ways, for
 * example by using Model_createEvent().  If an Event_t structure does not
 * exist, a new EventAssignment_t structure is @em not created and NULL is
 * returned instead.
 *
 * @param m the Model_t structure
 *
 * @return the new EventAssignment_t structure
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
EventAssignment_t *
Model_createEventAssignment (Model_t *m);


/**
 * Creates a new Trigger_t structure inside the last Event_t
 * structure created in the given Model_t structure, and returns a pointer
 * to it.
 *
 * The mechanism by which the last Event_t structure was created is not
 * significant.  It could have been created in a variety of ways, for
 * example by using Model_createEvent().  If an Event_t structure does not
 * exist, a new Trigger_t structure is @em not created and NULL is
 * returned instead.
 *
 * @param m the Model_t structure
 *
 * @return the new Trigger_t structure
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Trigger_t *
Model_createTrigger (Model_t *m);


/**
 * Creates a new Delay_t structure inside the last Event_t
 * structure created in the given Model_t structure, and returns a pointer
 * to it.
 *
 * The mechanism by which the last Event_t structure was created is not
 * significant.  It could have been created in a variety of ways, for
 * example by using Model_createEvent().  If an Event_t structure does not
 * exist, a new Delay_t structure is @em not created and NULL is
 * returned instead.
 *
 * @param m the Model_t structure
 *
 * @return the new Delay_t structure
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Delay_t *
Model_createDelay (Model_t *m);


/**
 * Get the list of FunctionDefinition_t structures contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the list of FunctionDefinition_t structures
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ListOf_t *
Model_getListOfFunctionDefinitions (Model_t *m);


/**
 * Get the list of UnitDefinition_t structures contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the list of UnitDefinition_t structures.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ListOf_t *
Model_getListOfUnitDefinitions (Model_t *m);


/**
 * Get the list of CompartmentType_t structures contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the list of CompartmentType_t structures.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ListOf_t *
Model_getListOfCompartmentTypes (Model_t *m);


/**
 * Get the list of SpeciesType_t structures contained in the given Model_t
 * structure.
 *
 * @param m the Model_t structure
 *
 * @return the list of SpeciesType_t structures.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ListOf_t *
Model_getListOfSpeciesTypes (Model_t *m);


/**
 * Get the list of Compartment_t structures contained in the given Model_t
 * structure.
 *
 * @param m the Model_t structure
 *
 * @return the list of Compartment_t structures.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ListOf_t *
Model_getListOfCompartments (Model_t *m);


/**
 * Get the list of Species_t structures contained in the given Model_t
 * structure.
 *
 * @param m the Model_t structure
 *
 * @return the list of Specie_t structures.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ListOf_t *
Model_getListOfSpecies (Model_t *m);


/**
 * Get the list of Parameter_t structures contained in the given Model_t
 * structure.
 *
 * @param m the Model_t structure
 *
 * @return the list of Parameter_t structures.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ListOf_t *
Model_getListOfParameters (Model_t *m);


/**
 * Get the list of InitialAssignment_t structures contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 *
 * @return the list of InitialAssignment_t structures.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ListOf_t *
Model_getListOfInitialAssignments (Model_t* m);


/**
 * Get the list of Rule_t structures contained in the given Model_t
 * structure.
 *
 * @param m the Model_t structure
 *
 * @return the list of Rule_t structures.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ListOf_t *
Model_getListOfRules (Model_t *m);


/**
 * Get the list of Constraint_t structures contained in the given Model_t
 * structure.
 *
 * @param m the Model_t structure
 *
 * @return the list of Constraint_t structures.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ListOf_t *
Model_getListOfConstraints (Model_t* m);


/**
 * Get the list of Reaction_t structures contained in the given Model_t
 * structure.
 *
 * @param m the Model_t structure
 *
 * @return the list of Reaction_t structures.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ListOf_t *
Model_getListOfReactions (Model_t *m);


/**
 * Get the list of Event_t structures contained in the given Model_t
 * structure.
 *
 * @param m the Model_t structure
 *
 * @return the list of Event_t structures.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
ListOf_t *
Model_getListOfEvents (Model_t *m);


/**
 * Get the nth FunctionDefinition_t structure contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 * @param n the integer index of the FunctionDefinition_t sought
 *
 * @return the FunctionDefinition_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
FunctionDefinition_t *
Model_getFunctionDefinition (Model_t *m, unsigned int n);


/**
 * Get the FunctionDefinition_t structure whose identifier is @p sid in the
 * given Model_t structure.
 *
 * @param m the Model_t structure
 * @param sid the identifier of the FunctionDefinition_t structure sought
 *
 * @return the FunctionDefinition_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
FunctionDefinition_t *
Model_getFunctionDefinitionById (Model_t *m, const char *sid);


/**
 * Get the nth UnitDefinition_t structure contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 * @param n the integer index of the UnitDefinition_t sought
 *
 * @return the UnitDefinition_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
UnitDefinition_t *
Model_getUnitDefinition (Model_t *m, unsigned int n);


/**
 * Get the UnitDefinition_t structure whose identifier is @p sid in the
 * given Model_t structure.
 *
 * @param m the Model_t structure
 * @param sid the identifier of the UnitDefinition_t structure sought
 *
 * @return the UnitDefinition_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
UnitDefinition_t *
Model_getUnitDefinitionById (Model_t *m, const char *sid);


/**
 * Get the nth CompartmentType_t structure contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 * @param n the integer index of the CompartmentType_t sought
 *
 * @return the CompartmentType_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
CompartmentType_t *
Model_getCompartmentType (Model_t *m, unsigned int n);


/**
 * Get the CompartmentType_t structure whose identifier is @p sid in the
 * given Model_t structure.
 *
 * @param m the Model_t structure
 * @param sid the identifier of the CompartmentType_t structure sought
 *
 * @return the CompartmentType_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
CompartmentType_t *
Model_getCompartmentTypeById (Model_t *m, const char *sid);


/**
 * Get the nth SpeciesType_t structure contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 * @param n the integer index of the SpeciesType_t sought
 *
 * @return the SpeciesType_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
SpeciesType_t *
Model_getSpeciesType (Model_t *m, unsigned int n);


/**
 * Get the SpeciesType_t structure whose identifier is @p sid in the
 * given Model_t structure.
 *
 * @param m the Model_t structure
 * @param sid the identifier of the SpeciesType_t structure sought
 *
 * @return the SpeciesType_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
SpeciesType_t *
Model_getSpeciesTypeById (Model_t *m, const char *sid);


/**
 * Get the nth Compartment_t structure contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Compartment_t sought
 *
 * @return the Compartment_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Compartment_t *
Model_getCompartment (Model_t *m, unsigned int n);


/**
 * Get the Compartment_t structure whose identifier is @p sid in the
 * given Model_t structure.
 *
 * @param m the Model_t structure
 * @param sid the identifier of the Compartment_t structure sought
 *
 * @return the Compartment_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Compartment_t *
Model_getCompartmentById (Model_t *m, const char *sid);


/**
 * Get the nth Species_t structure contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Species_t sought
 *
 * @return the Species_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Species_t *
Model_getSpecies (Model_t *m, unsigned int n);


/**
 * Get the Species_t structure whose identifier is @p sid in the
 * given Model_t structure.
 *
 * @param m the Model_t structure
 * @param sid the identifier of the Species_t structure sought
 *
 * @return the Species_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Species_t *
Model_getSpeciesById (Model_t *m, const char *sid);


/**
 * Get the nth Parameter_t structure contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Parameter_t sought
 *
 * @return the Parameter_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Parameter_t *
Model_getParameter (Model_t *m, unsigned int n);


/**
 * Get the Parameter_t structure whose identifier is @p sid in the
 * given Model_t structure.
 *
 * @param m the Model_t structure
 * @param sid the identifier of the Parameter_t structure sought
 *
 * @return the Parameter_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Parameter_t *
Model_getParameterById (Model_t *m, const char *sid);


/**
 * Get the nth InitialAssignment_t structure contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 * @param n the integer index of the InitialAssignment_t sought
 *
 * @return the InitialAssignment_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
InitialAssignment_t *
Model_getInitialAssignment (Model_t *m, unsigned int n);


/**
 * @return the InitialAssignment_t in this Model_t with the given symbol or
 * @c NULL if no such InitialAssignment_t exists.
 *
 * @param m the Model_t structure
 * @param symbol the symbol to search for
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
InitialAssignment_t *
Model_getInitialAssignmentBySym (Model_t *m, const char *symbol);


/**
 * Get the nth Rule_t structure contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Rule_t sought
 *
 * @return the Rule_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Rule_t *
Model_getRule (Model_t *m, unsigned int n);


/**
 * @return the Rule_t in this Model_t with the given variable or @c NULL if no
 * such Rule_t exists.
 *
 * @param m the Model_t structure
 * @param variable the variable to search for
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Rule_t *
Model_getRuleByVar (Model_t *m, const char *variable);


/**
 * Get the nth Constraint_t structure contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Constraint_t sought
 *
 * @return the Constraint_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Constraint_t *
Model_getConstraint (Model_t *m, unsigned int n);


/**
 * Get the nth Reaction_t structure contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Reaction_t sought
 *
 * @return the Reaction_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Reaction_t *
Model_getReaction (Model_t *m, unsigned int n);


/**
 * Get the Reaction_t structure whose identifier is @p sid in the
 * given Model_t structure.
 *
 * @param m the Model_t structure
 * @param sid the identifier of the Reaction_t structure sought
 *
 * @return the Reaction_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Reaction_t *
Model_getReactionById (Model_t *m, const char *sid);


/**
 * Get the SpeciesReference_t structure whose identifier is @p sid in the
 * given Model_t structure.
 *
 * @param m the Model_t structure
 * @param sid the identifier of the SpeciesReference_t structure sought
 *
 * @return the SpeciesReference_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
SpeciesReference_t *
Model_getSpeciesReferenceById (Model_t *m, const char *sid);


/**
 * Get the nth Event_t structure contained in the given
 * Model_t structure.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Event_t sought
 *
 * @return the Event_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Event_t *
Model_getEvent (Model_t *m, unsigned int n);


/**
 * Get the Event_t structure whose identifier is @p sid in the
 * given Model_t structure.
 *
 * @param m the Model_t structure
 * @param sid the identifier of the Event_t structure sought
 *
 * @return the Event_t if found, or @c NULL if not found
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Event_t *
Model_getEventById (Model_t *m, const char *sid);


/**
 * Get the number of FunctionDefinition_t structures in the given
 * Model_t structure
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of FunctionDefinition_t
 * structures in @p m
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumFunctionDefinitions (const Model_t *m);


/**
 * Get the number of UnitDefinition_t structures in the given
 * Model_t structure
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of UnitDefinition_t
 * structures in @p m
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumUnitDefinitions (const Model_t *m);


/**
 * Get the number of CompartmentType_t structures in the given
 * Model_t structure
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of CompartmentType_t
 * structures in @p m
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumCompartmentTypes (const Model_t *m);


/**
 * Get the number of SpeciesType_t structures in the given
 * Model_t structure
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of SpeciesType_t
 * structures in @p m
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumSpeciesTypes (const Model_t *m);


/**
 * Get the number of Compartment_t structures in the given
 * Model_t structure
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of Compartment_t
 * structures in @p m
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumCompartments (const Model_t *m);


/**
 * Get the number of Specie_t structures in the given
 * Model_t structure
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of Specie_t
 * structures in @p m
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumSpecies (const Model_t *m);


/**
 * Get the number of Species_t structure in this Model_t structure having
 * nonzero values for their "boundaryCondition" attribute.
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of Species_t structures
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumSpeciesWithBoundaryCondition (const Model_t *m);


/**
 * Get the number of Parameter_t structures in the given
 * Model_t structure
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of Parameter_t
 * structures in @p m
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumParameters (const Model_t *m);


/**
 * Get the number of InitialAssignment_t structures in the given
 * Model_t structure
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of InitialAssignment_t
 * structures in @p m
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumInitialAssignments (const Model_t *m);


/**
 * Get the number of Rule_t structures in the given
 * Model_t structure
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of Rule_t
 * structures in @p m
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumRules (const Model_t *m);


/**
 * Get the number of Constraint_t structures in the given
 * Model_t structure
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of Constraint_t
 * structures in @p m
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumConstraints (const Model_t *m);


/**
 * Get the number of Reaction_t structures in the given
 * Model_t structure
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of Reaction_t
 * structures in @p m
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumReactions (const Model_t *m);


/**
 * Get the number of Event_t structures in the given
 * Model_t structure
 *
 * @param m the Model_t structure
 *
 * @return an unsigned integer as the count of Event_t
 * structures in @p m
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
unsigned int
Model_getNumEvents (const Model_t *m);

/**
 * Populates the list of FormulaDataUnits with the units derived 
 * for the model. The list contains elements of class
 * FormulaUnitsData. 
 *
 * The first element of the list refers to the default units
 * of 'substance per time' derived from the model and has the
 * unitReferenceId 'subs_per_time'. This facilitates the comparison of units
 * derived from mathematical formula with the expected units.
 *
 * The next elements of the list record the units of the 
 * compartments and species established from either explicitly
 * declared or default units.
 *
 * The next elements record the units of any parameters.
 *
 * Subsequent elements of the list record the units derived for
 * each mathematical expression encountered within the model.
 *
 * @param m the Model_t structure
 *
 * @note This function is utilised by the Unit Consistency Validator.
 * The List is populated prior to running the validation and thus
 * the consistency of units can be checked by accessing the members
 * of the list and comparing the appropriate data.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
void 
Model_populateListFormulaUnitsData(Model_t *m);


/**
 * Predicate returning @c true or @c false depending on whether 
 * the list of FormulaUnitsData is populated.
 *
 * @param m the Model_t structure
 *
 * @return @c true if the list of FormulaUnitsData is populated, 
 * @c false otherwise.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
int 
Model_isPopulatedListFormulaUnitsData(Model_t *m);


/**
 * Removes the nth FunctionDefinition_t structure from this Model_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param n the integer index of the FunctionDefinition_t sought
 *
 * @return the FunctionDefinition_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
FunctionDefinition_t*
Model_removeFunctionDefinition (Model_t *m, unsigned int n);


/**
 * Removes the FunctionDefinition_t structure with the given "id" attribute
 * from this Model_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param sid the string of the "id" attribute of the FunctionDefinition_t sought
 *
 * @return the FunctionDefinition_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no FunctionDefinition_t
 * structure with the identifier exists in this Model_t structure.
 *
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
FunctionDefinition_t*
Model_removeFunctionDefinitionById (Model_t *m, const char* sid);


/**
 * Removes the nth UnitDefinition_t structure from this Model_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param n the integer index of the UnitDefinition_t sought
 *
 * @return the UnitDefinition_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
UnitDefinition_t*
Model_removeUnitDefinition (Model_t *m, unsigned int n);


/**
 * Removes the UnitDefinition_t structure with the given "id" attribute
 * from this Model_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param sid the string of the "id" attribute of the UnitDefinition_t sought
 *
 * @return the UnitDefinition_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no UnitDefinition_t
 * structure with the identifier exists in this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
UnitDefinition_t*
Model_removeUnitDefinitionById (Model_t *m, const char* sid);


/**
 * Removes the nth CompartmentType_t structure from this Model_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param n the integer index of the CompartmentType_t sought
 *
 * @return the CompartmentType_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
CompartmentType_t*
Model_removeCompartmentType (Model_t *m, unsigned int n);


/**
 * Removes the CompartmentType_t structure with the given "id" attribute
 * from this Model_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param sid the string of the "id" attribute of the CompartmentType_t sought
 *
 * @return the CompartmentType_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no CompartmentType_t
 * structure with the identifier exists in this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
CompartmentType_t*
Model_removeCompartmentTypeById (Model_t *m, const char* sid);


/**
 * Removes the nth SpeciesType_t structure from this Model_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param n the integer index of the SpeciesType_t sought
 *
 * @return the SpeciesType_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
SpeciesType_t*
Model_removeSpeciesType (Model_t *m, unsigned int n);


/**
 * Removes the SpeciesType_t structure with the given "id" attribute
 * from this Model_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param sid the string of the "id" attribute of the SpeciesType_t sought
 *
 * @return the SpeciesType_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no SpeciesType_t
 * structure with the identifier exists in this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
SpeciesType_t*
Model_removeSpeciesTypeById (Model_t *m, const char* sid);


/**
 * Removes the nth Compartment_t structure from this Model_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Compartment_t sought
 *
 * @return the Compartment_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Compartment_t*
Model_removeCompartment (Model_t *m, unsigned int n);


/**
 * Removes the Compartment_t structure with the given "id" attribute
 * from this Model_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param sid the string of the "id" attribute of the Compartment_t sought
 *
 * @return the Compartment_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no Compartment_t
 * structure with the identifier exists in this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Compartment_t*
Model_removeCompartmentById (Model_t *m, const char* sid);


/**
 * Removes the nth Species_t structure from this Model_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Species_t sought
 *
 * @return the Species_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Species_t*
Model_removeSpecies (Model_t *m, unsigned int n);


/**
 * Removes the Species_t structure with the given "id" attribute
 * from this Model_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param sid the string of the "id" attribute of the Species_t sought
 *
 * @return the Species_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no Species_t
 * structure with the identifier exists in this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Species_t*
Model_removeSpeciesById (Model_t *m, const char* sid);


/**
 * Removes the nth Parameter_t structure from this Model_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Parameter_t sought
 *
 * @return the Parameter_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Parameter_t*
Model_removeParameter (Model_t *m, unsigned int n);


/**
 * Removes the Parameter_t structure with the given "id" attribute
 * from this Model_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param sid the string of the "id" attribute of the Parameter_t sought
 *
 * @return the Parameter_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no Parameter_t
 * structure with the identifier exists in this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Parameter_t*
Model_removeParameterById (Model_t *m, const char* sid);


/**
 * Removes the nth InitialAssignment_t structure from this Model_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param n the integer index of the InitialAssignment_t sought
 *
 * @return the InitialAssignment_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
InitialAssignment_t*
Model_removeInitialAssignment (Model_t *m, unsigned int n);


/**
 * Removes the InitialAssignment_t structure with the given "symbol" attribute
 * from this Model_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param symbol the string of the "symbol" attribute of the InitialAssignment_t sought
 *
 * @return the InitialAssignment_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no InitialAssignment_t
 * structure with the "symbol" attribute exists in this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
InitialAssignment_t*
Model_removeInitialAssignmentBySym (Model_t *m, const char* symbol);


/**
 * Removes the nth Rule_t structure from this Model_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Rule_t sought
 *
 * @return the Rule_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Rule_t*
Model_removeRule (Model_t *m, unsigned int n);


/**
 * Removes the Rule_t structure with the given "variable" attribute
 * from this Model_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param variable the string of the "variable" attribute of the Rule_t sought
 *
 * @return the Rule_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no Rule_t
 * structure with the "variable" attribute exists in this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Rule_t*
Model_removeRuleByVar (Model_t *m, const char* variable);


/**
 * Removes the nth Constraint_t structure from this Model_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Constraint_t sought
 *
 * @return the Constraint_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Constraint_t*
Model_removeConstraint (Model_t *m, unsigned int n);


/**
 * Removes the nth Reaction_t structure from this Model_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Reaction_t sought
 *
 * @return the Reaction_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Reaction_t*
Model_removeReaction (Model_t *m, unsigned int n);


/**
 * Removes the Reaction_t structure with the given "id" attribute
 * from this Model_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param sid the string of the "id" attribute of the Reaction_t sought
 *
 * @return the Reaction_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no Reaction_t
 * structure with the identifier exists in this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Reaction_t*
Model_removeReactionById (Model_t *m, const char* sid);


/**
 * Removes the nth Event_t structure from this Model_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param n the integer index of the Event_t sought
 *
 * @return the Event_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Event_t*
Model_removeEvent (Model_t *m, unsigned int n);


/**
 * Removes the Event_t structure with the given "id" attribute
 * from this Model_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param m the Model_t structure
 * @param sid the string of the "id" attribute of the Event_t sought
 *
 * @return the Event_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no Event_t
 * structure with the identifier exists in this Model_t structure.
 *
 * @memberof Model_t
 */
LIBSBML_EXTERN
Event_t*
Model_removeEventById (Model_t *m, const char* sid);

/* not yet exposed but leave in case we need them

 * Adds a copy of the given FormulaUnitsData_t structure to this Model_t.
 *
 * @param m the Model_t structure
 * @param fud the FormulaUnitsData_t structure to add

LIBSBML_EXTERN
void 
Model_addFormulaUnitsData (Model_t *m, FormulaUnitsData_t* fud);


 * Creates a new FormulaUnitsData_t inside this Model_t and returns it.
 *
 * @param m the Model_t structure
 *
 * @return the FormulaUnitsData_t structure created

LIBSBML_EXTERN
FormulaUnitsData_t*
Model_createFormulaUnitsData (Model_t *m);


 * Get the nth FormulaUnitsData_t structure in this Model_t.
 *
 * @param m the Model_t structure
 *
 * @return the nth FormulaUnitsData_t of this Model_t.

LIBSBML_EXTERN
FormulaUnitsData_t*
Model_getFormulaUnitsData (Model_t *m, unsigned int n);


 * Get a FormulaUnitsData_t structure based on its unitReferenceId and typecode.
 *
 * @param m the Model_t structure
 *
 * @return the FormulaUnitsData_t in this Model_t with the unitReferenceId @p sid 
 * and the typecode (int) @p typecode or @c NULL
 * if no such FormulaUnitsData exists.
 *
 * @note The typecode (int) parameter is necessary as the unitReferenceId
 * of the FormulaUnitsData_t need not be unique. For example if a Species_t
 * with id 's' is assigned by an AssignmentRule_t there will be two 
 * elements of the FormulaUnitsData_t List with the unitReferenceId 's'; 
 * one with
 * typecode 'SBML_SPECIES' referring to the units related to the species, 
 * the other with typecode 'SBML_ASSIGNMENT_RULE' referring to the units
 * derived from the math element of the AssignmentRule_t.

LIBSBML_EXTERN
FormulaUnitsData_t*
Model_getFormulaUnitsDataById(Model_t *m, const char* sid, int);


 * Get the number of FormulaUnitsData_t structures in this Model_t.
 *
 * @param m the Model_t structure
 *
 * @return the number of FormulaUnitsData_t in this Model_t.

LIBSBML_EXTERN
unsigned int 
Model_getNumFormulaUnitsData (Model_t *m);


 * Get the list of FormulaUnitsData_t structure in this Model_t.
 *
 * @param m the Model_t structure
 *
 * @return the list of FormulaUnitsData_t for this Model_t.

LIBSBML_EXTERN
List_t*
Model_getListFormulaUnitsData (Model_t *m);

*/


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG   */
#endif  /* Model_h */
