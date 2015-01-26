/**
 * @file    Event.h
 * @brief   Definitions of Event and ListOfEvents.
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
 * @class Event
 * @sbmlbrief{core} A discontinuous SBML <em>event</em>.
 * 
 * An SBML Event object defines when the event can occur, the variables
 * that are affected by it, how the variables are affected, and the event's
 * relationship to other events.  The effect of the event can optionally be
 * delayed after the occurrence of the condition which invokes it.
 *
 * The operation of Event is divided into two phases (even when the event
 * is not delayed): one when the event is @em triggered, and the other when
 * the event is @em executed.  Trigger objects define the conditions for
 * triggering an event, Delay objects define when the event is actually
 * executed, EventAssignment objects define the effects of executing the
 * event, and (in SBML Level&nbsp;3) Priority objects influence the order
 * of EventAssignment performance in cases of simultaneous events.  Please
 * consult the descriptions of Trigger, Delay, EventAssignment and Priority
 * for more information.
 *
 * @section event-version-diffs SBML Level/Version differences
 * 
 * @subsection sbml-l3 SBML Level 3
 *
 * SBML Level 3 introduces several changes to the structure and components
 * of Events compared to SBML Level&nbsp;2.  These changes fall into two
 * main categories: changes to what is optional or required, and additions
 * of new attributes and elements.
 * <ul>
 * <li> The attribute "useValuesFromTriggerTime" on Event is mandatory (it
 * was optional in Level&nbsp;2);
 * <li> Event's "listOfEventAssignments" element (of class
 * ListOfEventAssignments) is optional (it was mandatory in Level&nbsp;2);
 * <li> Event's "priority" element (of class Priority) is new in
 * Level&nbsp;3; and
 * <li> The Trigger object gains new mandatory attributes (described as part
 * of the definition of Trigger).
 * </ul>
 *
 * The changes to the attributes of Event are described below; the changes
 * to Trigger and Priority are described in their respective sections.
 *
 * @subsection sbml-l2 SBML Level 2
 * 
 * In SBML Level&nbsp;2 versions before Version&nbsp;4, the semantics of
 * Event time delays were defined such that the expressions in the event's
 * assignments were always evaluated at the time the event was
 * <em>triggered</em>.  This definition made it difficult to define an event
 * whose assignment formulas were meant to be evaluated at the time the
 * event was <em>executed</em> (i.e., after the time period defined by the
 * value of the Delay element).  In SBML Level&nbsp;2 Version&nbsp;4 and in
 * Level&nbsp;3, the attribute "useValuesFromTriggerTime" on Event allows a
 * model to indicate the time at which the event's assignments are intended
 * the values of the assignment formulas are computed at the moment the
 * event is triggered, not after the delay.  If "useValuesFromTriggerTime"=@c
 * false, it means that the formulas in the event's assignments are to be
 * computed @em after the delay, at the time the event is executed.
 *
 * The definition of Event in SBML Level&nbsp;2 Versions 1 and 2 includes
 * an additional attribute called "timeUnits", which allowed the time units
 * of the Delay to be set explicitly.  Later Versions of SBML Level&nbsp;2
 * as well as SBML Level&nbsp;3 do not define this attribute.  LibSBML
 * supports this attribute for compatibility with previous versions of SBML
 * Level&nbsp;2; however, if a model in SBML Level&nbsp;3 or Level&nbsp;2
 * Versions&nbsp;3&ndash;4 format sets the attribute, the
 * consistency-checking method SBMLDocument::checkConsistency() will report
 * an error.
 *
 * The attribute "useValuesFromTriggerTime" was introduced in SBML
 * Level&nbsp;2 Version&nbsp;4.  Models defined in prior Versions of SBML
 * Level&nbsp;2 cannot use this attribute, and
 * SBMLDocument::checkConsistency() will report an error if they do.
 *
 * @section semantics Semantics of events in SBML Level 3 Version&nbsp;1
 *
 * The detailed semantics of events are described in the specification
 * documents for each SBML Level/Version.  Here we include the description
 * from the SBML Level&nbsp;1 Version&nbsp;1.
 * Any transition of a Trigger object's "math" formula from the value @c
 * false to @c true will cause the enclosing Event object to
 * <em>trigger</em>.  Such a transition is not possible at the very start
 * of a simulation (i.e., at time <em>t = 0</em>) unless the Trigger
 * object's "initialValue" attribute has a value of @c false; this defines
 * the value of the trigger formula to be @c false immediately prior to the
 * start of simulation, thereby giving it the potential to change in value
 * from @c false to @c true when the formula is evaluated at <em>t =
 * 0</em>.  If "initialValue"=@c true, then the trigger expression cannot
 * transition from @c false to @c true at <em>t = 0</em> but may do so at
 * some time <em>t > 0</em>.
 * 
 * Consider an Event object definition <EM>E</EM> with delay <em>d</em> in
 * which the Trigger object's "math" formula makes a transition in value
 * from @c false to @c true at times <em>t<sub>1</sub></em> and
 * <em>t<sub>2</sub></em>.  The EventAssignment within the Event object
 * will have effect at <em>t<sub>1</sub> + d</em> and
 * <em>t<sub>2</sub> + d</em> irrespective of the relative times of
 * <em>t<sub>1</sub></em> and <em>t<sub>2</sub></em>.  For example, events
 * can "overlap" so that <em>t<sub>1</sub> < t<sub>2</sub> <
 * t<sub>1</sub> + d</em> still causes an event assignments to occur at
 * <em>t<sub>1</sub> + d</em> and <em>t<sub>2</sub> + d</em>.
 * 
 * It is entirely possible for two events to be executed simultaneously,
 * and it is possible for events to trigger other events (i.e., an event
 * assignment can cause an event to trigger).  This leads to several
 * points:
 * <ul>
 * 
 * <li> A software package should retest all event triggers after executing
 * an event assignment in order to account for the possibility that the
 * assignment causes another event trigger to transition from @c false to
 * @c true.  This check should be made after each individual Event object's
 * execution, even when several events are to be executed simultaneously.
 * 
 * <li> Any Event object whose Trigger "persistent" attribute has the value
 * @c false must have its trigger expression reevaluated continuously
 * between when the event is triggered and when it is executed.  If
 * its trigger expression ever evaluates to @c false, it must be removed
 * from the queue of events pending execution and treated as any other
 * event whose trigger expression evaluates to @c false.
 * 
 * <li> Although the precise time at which events are executed is not
 * resolved beyond the given execution point in simulated time, it is
 * assumed that the order in which the events occur <em>is</em> resolved.
 * This order can be significant in determining the overall outcome of a
 * given simulation.  When an event <EM>X</EM> <em>triggers</em> another
 * event <EM>Y</EM> and event <EM>Y</EM> has zero delay, then event
 * <EM>Y</EM> is added to the existing set of simultaneous events that are
 * pending <em>execution</em>.  Events <EM>X</EM> and <EM>Y</EM> form a
 * cascade of events at the same point in simulation time.  An event such
 * as <EM>Y</EM> may have a special priority if it contains a Priority
 * subobject.
 * 
 * <li> All events in a model are open to being in a cascade.  The position
 * of an event in the event queue does not affect whether it can be in the
 * cascade: event <EM>Y</EM> can be triggered whether it is before or after
 * <EM>X</EM> in the queue of events pending execution.  A cascade of
 * events can be potentially infinite (never terminate); when this occurs a
 * simulator should indicate this has occurred---it is incorrect for a
 * simulator to break a cascade arbitrarily and continue the simulation
 * without at least indicating that the infinite cascade occurred.
 * 
 * <li> Simultaneous events having no defined priorities are executed in an
 * undefined order.  This does not mean that the behavior of the simulation
 * is completely undefined; merely that the <em>order</em> of execution of
 * these particular events is undefined.  A given simulator may use any
 * algorithm to choose an order as long as every event is executed exactly
 * once.
 * 
 * <li> Events with defined priorities are executed in the order implied by
 * their Priority "math" formula values, with events having higher
 * priorities being executed ahead of events with lower priorities, and
 * events with identical priorities being executed in a random order with
 * respect to one another (as determined at run-time by some random
 * algorithm equivalent to coin-flipping).  Newly-triggered events that are
 * to be executed immediately (i.e., if they define no delays) should be
 * inserted into the queue of events pending execution according to their
 * priorities: events with higher priority values value must be inserted
 * ahead of events with lower priority values and after any pending events
 * with even higher priorities, and inserted randomly among pending events
 * with the same priority values.  Events without Priority objects must be
 * inserted into the queue in some fashion, but the algorithm used to place
 * it in the queue is undefined.  Similarly, there is no restriction on the
 * order of a newly-inserted event with a defined Priority with respect to
 * any other pending Event without a defined Priority.
 * 
 * <li> A model variable that is the target of one or more event
 * assignments can change more than once when simultaneous events are
 * processed at some time point <em>t</em>.  The model's behavior (output)
 * for such a variable is the value of the variable at the end of
 * processing all the simultaneous events at time <em>t</em>.
 * 
 * </ul>
 *
 * @see Trigger
 * @see Priority
 * @see Delay
 * @see EventAssignment
 * 
 *
 * <!-- ------------------------------------------------------------------- -->
 * @class ListOfEvents
 * @sbmlbrief{core} A list of Event objects.
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
 * @class doc_warning_event_timeUnits
 *
 * @warning <span class="warning">Definitions of Event in SBML Level 2
 * Versions&nbsp;1 and&nbsp;2 included the additional attribute called
 * "timeUnits", but it was removed in SBML Level&nbsp;2 Version&nbsp;3.
 * LibSBML supports this attribute for compatibility with previous versions
 * of SBML Level&nbsp;2, but its use is discouraged since models in
 * Level&nbsp;2 Versions&nbsp;3 and&nbsp;4 cannot contain it.  If a
 * Version&nbsp;3 or&nbsp;4 model sets the attribute, the
 * consistency-checking method SBMLDocument::checkConsistency() will report
 * an error.</span>
 *
 * @class doc_warning_useValuesFromTriggerTime
 *
 * @warning <span class="warning">The attribute "useValuesFromTriggerTime"
 * was introduced in SBML Level&nbsp;2 Version&nbsp;4.  It is not valid in
 * models defined using SBML Level&nbsp;2 versions prior to Version&nbsp;4.
 * If a Level&nbsp;2 Version&nbsp;1&ndash;3 model sets the attribute, the
 * consistency-checking method SBMLDocument::checkConsistency() will report
 * an error.</span>
 *
 * @class doc_event_using_useValuesFromTriggerTime
 *
 * @par
 * The optional Delay on Event means there are two times to consider when
 * computing the results of an event: the time at which the event is
 * <em>triggered</em>, and the time at which assignments are
 * <em>executed</em>.  It is also possible to distinguish between the
 * time at which the EventAssignment's expression is calculated, and the
 * time at which the assignment is made: the expression could be
 * evaluated at the same time the assignments are performed, i.e., when
 * the event is <em>executed</em>, but it could also be defined to be
 * evaluated at the time the event is <em>triggered</em>.
 * 
 * In SBML Level&nbsp;2 versions prior to Version&nbsp;4, the semantics
 * of Event time delays were defined such that the expressions in the
 * event's assignments were always evaluated at the time the event was
 * <em>triggered</em>.  This definition made it difficult to define an
 * event whose assignment formulas were meant to be evaluated at the time
 * the event was <em>executed</em> (i.e., after the time period defined
 * by the value of the Delay element).  In SBML Level&nbsp;2
 * Version&nbsp;4, the attribute "useValuesFromTriggerTime" on Event
 * allows a model to indicate the time at which the event's assignments
 * are intended to be evaluated.  In SBML Level&nbsp;2, the attribute has
 * a default value of @c true, which corresponds to the interpretation of
 * event assignments prior to Version&nbsp;4: the values of the
 * assignment formulas are computed at the moment the event is triggered,
 * not after the delay.  If "useValuesFromTriggerTime"=@c false, it means
 * that the formulas in the event's assignments are to be computed after
 * the delay, at the time the event is executed.  In SBML Level&nbsp;3,
 * the attribute is mandatory, not optional, and all events must specify
 * a value for it.
 *
 */

#ifndef Event_h
#define Event_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>
#include <sbml/EventAssignment.h>
#include <sbml/Trigger.h>
#include <sbml/Delay.h>
#include <sbml/Priority.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class ASTNode;
class SBMLVisitor;


class LIBSBML_EXTERN Event : public SBase
{
public:

  /**
   * Creates a new Event using the given SBML @p level and @p version
   * values.
   *
   * @param level an unsigned int, the SBML Level to assign to this Event
   *
   * @param version an unsigned int, the SBML Version to assign to this
   * Event
   *
   * @throws SBMLConstructorException
   * Thrown if the given @p level and @p version combination, or this kind
   * of SBML object, are either invalid or mismatched with respect to the
   * parent SBMLDocument object.
   * 
   * @copydetails doc_note_setting_lv
   */
  Event (unsigned int level, unsigned int version);


  /**
   * Creates a new Event using the given SBMLNamespaces object
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
  Event (SBMLNamespaces* sbmlns);


  /**
   * Destroys this Event.
   */
  virtual ~Event ();


  /**
   * Copy constructor; creates a copy of this Event.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  Event (const Event& orig);


  /**
   * Assignment operator for Event.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  Event& operator=(const Event& rhs);


  /**
   * Accepts the given SBMLVisitor for this instance of Event.
   *
   * @param v the SBMLVisitor instance to be used.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether the Visitor would like to visit the next Event in the list
   * of events within which this Event is embedded.
   */
  virtual bool accept (SBMLVisitor& v) const;


  /**
   * Creates and returns a deep copy of this Event object.
   *
   * @return the (deep) copy of this Event object.
   */
  virtual Event* clone () const;


  /**
   * Returns the first child element found that has the given @p id in the
   * model-wide SId namespace, or @c NULL if no such object is found.
   *
   * @param id string representing the id of objects to find
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
   * arbitrary depth.
   *
   * @return a List of pointers to all children objects.
   */
  virtual List* getAllElements(ElementFilter* filter=NULL);
  
  
  /**
   * Returns the value of the "id" attribute of this Event.
   * 
   * @return the id of this Event.
   */
  virtual const std::string& getId () const;


  /**
   * Returns the value of the "name" attribute of this Event.
   * 
   * @return the name of this Event.
   */
  virtual const std::string& getName () const;


  /**
   * Get the event trigger portion of this Event.
   * 
   * @return the Trigger object of this Event.
   */
  const Trigger* getTrigger () const;


  /**
   * Get the event trigger portion of this Event.
   * 
   * @return the Trigger object of this Event.
   */
  Trigger* getTrigger ();


  /**
   * Get the assignment delay portion of this Event, if there is one.
   * 
   * @return the delay of this Event if one is defined, or @c NULL if none
   * is defined.
   */
  const Delay* getDelay () const;


  /**
   * Get the assignment delay portion of this Event, if there is one.
   * 
   * @return the delay of this Event if one is defined, or @c NULL if none
   * is defined.
   */
  Delay* getDelay ();


  /**
   * (SBML Level&nbsp;3 only) Get the event priority portion of this
   * Event.
   * 
   * @return the Priority object of this Event.
   * 
   * @note The element "priority" is available in SBML Level&nbsp;3
   * Version&nbsp;1 Core, but is not present in lower Levels of SBML.
   */
  const Priority* getPriority () const;


  /**
   * (SBML Level&nbsp;3 only) Get the event priority portion of this
   * Event.
   * 
   * @return the Priority object of this Event.
   * 
   * @note The element "priority" is available in SBML Level&nbsp;3
   * Version&nbsp;1 Core, but is not present in lower Levels of SBML.
   */
  Priority* getPriority ();


  /**
   * Get the value of the "timeUnits" attribute of this Event, if it has one.
   * 
   * @return the value of the attribute "timeUnits" as a string.
   *
   * @copydetails doc_warning_event_timeUnits
   */
  const std::string& getTimeUnits () const;


  /**
   * Get the value of the "useValuesFromTriggerTime" attribute of this Event.
   *
   * @copydetails doc_event_using_useValuesFromTriggerTime
   * 
   * @return the value of the attribute "useValuesFromTriggerTime" as a boolean.
   *
   * @copydetails doc_warning_useValuesFromTriggerTime 
   */
  bool getUseValuesFromTriggerTime () const;


  /**
   * Predicate returning @c true if this
   * Event's "id" attribute is set.
   *
   * @return @c true if the "id" attribute of this Event is
   * set, @c false otherwise.
   */
  virtual bool isSetId () const;


  /**
   * Predicate returning @c true if this
   * Event's "name" attribute is set.
   *
   * @return @c true if the "name" attribute of this Event is
   * set, @c false otherwise.
   */
  virtual bool isSetName () const;


  /**
   * Predicate for testing whether the trigger for this Event is set.
   *
   * @return @c true if the trigger of this Event is set, @c false
   * otherwise.
   */
  bool isSetTrigger () const;


  /**
   * Predicate for testing whether the delay for this Event is set.
   *
   * @return @c true if the delay of this Event is set, @c false
   * otherwise.
   */
  bool isSetDelay () const;


  /**
   * (SBML Level&nbsp;3 only) Predicate for testing whether the priority
   * for this Event is set.
   *
   * @return @c true if the priority of this Event is set, @c false
   * otherwise.
   * 
   * @note The element "priority" is available in SBML Level&nbsp;3
   * Version&nbsp;1 Core, but is not present in lower Levels of SBML.
   */
  bool isSetPriority () const;


  /**
   * Predicate for testing whether the "timeUnits" attribute of this Event
   * is set.
   *
   * @return @c true if the "timeUnits" attribute of this Event is
   * set, @c false otherwise.
   *
   * @copydetails doc_warning_event_timeUnits
   */
  bool isSetTimeUnits () const;


  /**
   * Predicate for testing whether the "useValuesFromTriggerTime" attribute of this Event
   * is set.
   *
   * @return @c true if the "useValuesFromTriggerTime" attribute of this Event is
   * set, @c false otherwise.
   *
   * @note In SBML Level&nbsp;2, this attribute is optional and has a default value of
   * @c true, whereas in Level&nbsp;3 Version&nbsp;1, this optional is mandatory and
   * has no default value.
   */
  bool isSetUseValuesFromTriggerTime () const;


  /**
   * Sets the value of the "id" attribute of this Event.
   *
   * The string @p sid is copied.
   *
   * @copydetails doc_id_syntax
   *
   * @param sid the string to use as the identifier of this Event
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
   * Sets the value of the "name" attribute of this Event.
   *
   * The string in @p name is copied.
   *
   * @param name the new name for the Event
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
   * Sets the trigger definition of this Event to a copy of the given
   * Trigger object instance.
   *
   * @param trigger the Trigger object instance to use.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
   */
  int setTrigger (const Trigger* trigger);


  /**
   * Sets the delay definition of this Event to a copy of the given Delay
   * object instance.
   *
   * @param delay the Delay object instance to use
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
   */
  int setDelay (const Delay* delay);


  /**
   * (SBML Level&nbsp;3 only) Sets the priority definition of this Event
   * to a copy of the given Priority object instance.
   *
   * @param priority the Priority object instance to use
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * 
   * @note The element "priority" is available in SBML Level&nbsp;3
   * Version&nbsp;1 Core, but is not present in lower Levels of SBML.
   */
  int setPriority (const Priority* priority);


  /**
   * Sets the "timeUnits" attribute of this Event to a copy of @p sid.
   *
   * @param sid the identifier of the time units to use.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @copydetails doc_warning_event_timeUnits
   *
   */
  int setTimeUnits (const std::string& sid);


  /**
   * Sets the "useValuesFromTriggerTime" attribute of this Event to a @p value.
   * 
   * @copydetails doc_event_using_useValuesFromTriggerTime
   *
   * @param value the value of useValuesFromTriggerTime to use.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   *
   * @copydetails doc_warning_useValuesFromTriggerTime
   */
  int setUseValuesFromTriggerTime (bool value);


  /**
   * Unsets the value of the "id" attribute of this Event.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  virtual int unsetId ();


  /**
   * Unsets the value of the "name" attribute of this Event.
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
   * Unsets the Delay of this Event.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   */
  int unsetDelay ();


  /**
   * (SBML Level&nbsp;3 only) Unsets the Priority of this Event.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * 
   * @note The element "priority" is available in SBML Level&nbsp;3
   * Version&nbsp;1 Core, but is not present in lower Levels of SBML.
   */
  int unsetPriority ();


  /**
   * Unsets the Trigger of this Event.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   * 
   * @note The element "priority" is available in SBML Level&nbsp;3
   * Version&nbsp;1 Core, but is not present in lower Levels of SBML.
   */
  int unsetTrigger();


  /**
   * Unsets the "timeUnits" attribute of this Event.
   *
   * @return integer value indicating success/failure of the
   * function.  @if clike The value is drawn from the
   * enumeration #OperationReturnValues_t. @endif@~ The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
   *
   * @copydetails doc_warning_event_timeUnits
   */
  int unsetTimeUnits ();


  /**
   * Appends a copy of the given EventAssignment to this Event.
   *
   * @param ea the EventAssignment object to add.
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
   * @copydetails doc_note_object_is_copied 
   *
   * @see createEventAssignment()
   */
  int addEventAssignment (const EventAssignment* ea);


  /**
   * Creates a new, empty EventAssignment, adds it to this Event's list of
   * event assignments and returns the EventAssignment.
   *
   * @return the newly created EventAssignment object instance
   *
   * @see addEventAssignment(const EventAssignment* ea)
   */
  EventAssignment* createEventAssignment ();


  /**
   * Creates a new, empty Trigger, adds it to this Event and 
   * returns the Trigger.
   *
   * @return the newly created Trigger object instance
   */
  Trigger* createTrigger ();


  /**
   * Creates a new, empty Delay, adds it to this Event and 
   * returns the Delay.
   *
   * @return the newly created Delay object instance
   */
  Delay* createDelay ();


  /**
   * (SBML Level&nbsp;3 only) Creates a new, empty Priority, adds it to this
   * Event and returns the Priority.
   *
   * @return the newly created Priority object instance
   * 
   * @note The element "priority" is available in SBML Level&nbsp;3
   * Version&nbsp;1 Core, but is not present in lower Levels of SBML.
   */
  Priority* createPriority ();


  /**
   * Returns the list of event assignments for this Event.
   * 
   * @return the list of EventAssignments for this Event.
   */
  const ListOfEventAssignments* getListOfEventAssignments () const;


  /**
   * Returns the list of event assignments for this Event.
   * 
   * @return the list of EventAssignments for this Event.
   */
  ListOfEventAssignments* getListOfEventAssignments ();


  /**
   * Return a specific EventAssignment object of this Event.
   *
   * @param n an integer, the index of the EventAssignment object to return
   * 
   * @return the <code>n</code>th EventAssignment of this Event.
   */
  const EventAssignment* getEventAssignment (unsigned int n) const;


  /**
   * Return a specific EventAssignment object of this Event.
   *
   * @param n an integer, the index of the EventAssignment object to return
   * 
   * @return the <code>n</code>th EventAssignment of this Event.
   */
  EventAssignment* getEventAssignment (unsigned int n);


  /**
   * Return the event assignment indicated by the given @p variable.
   *
   * @param variable a string, the identifier of the variable whose
   * EventAssignment is being sought.
   *
   * @return the EventAssignment for the given @p variable, or @c NULL if
   * no such EventAssignment exits.
   */
  const EventAssignment* getEventAssignment (const std::string& variable) const;


  /**
   * Return the event assignment indicated by the given @p variable.
   *
   * @param variable a string, the identifier of the variable whose
   * EventAssignment is being sought.
   *
   * @return the EventAssignment for the given @p variable, or @c NULL if
   * no such EventAssignment exits.
   */
  EventAssignment* getEventAssignment (const std::string& variable);


  /**
   * Returns the number of EventAssignment objects attached to this
   * Event.
   * 
   * @return the number of EventAssignments in this Event.
   */
  unsigned int getNumEventAssignments () const;


  /**
   * Removes the nth EventAssignment object from this Event object and
   * returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   *
   * @param n the index of the EventAssignment object to remove
   *
   * @return the EventAssignment object removed.  As mentioned above, 
   * the caller owns the returned item. @c NULL is returned if the given index 
   * is out of range.
   *
   */
  EventAssignment* removeEventAssignment (unsigned int n);


  /**
   * Removes the EventAssignment object with the given "variable" attribute 
   * from this Event object and returns a pointer to it.
   *
   * The caller owns the returned object and is responsible for deleting it.
   * If none of the EventAssignment objects in this Event object have the 
   * "variable" attribute @p variable, then @c NULL is returned.
   *
   * @param variable the "variable" attribute of the EventAssignment object 
   * to remove
   *
   * @return the EventAssignment object removed.  As mentioned above, the 
   * caller owns the returned object. @c NULL is returned if no EventAssignment
   * object with the "variable" attribute exists in this Event object.
   */
  EventAssignment* removeEventAssignment (const std::string& variable);


  /** @cond doxygenLibsbmlInternal */
  /**
   * Sets the parent SBMLDocument of this SBML object.
   *
   * @param d the SBMLDocument to use
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
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_EVENT, SBMLTypeCode_t} (default).
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Returns the XML element name of this object, which for Event, is
   * always @c "event".
   * 
   * @return the name of this element, i.e., @c "event". 
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
  /**
   * sets the mInternalIdOnly flag
   */
  void setInternalIdOnly();
  /** @endcond */


  /**
   * Predicate returning @c true if all the required attributes for this
   * Event object have been set.
   *
   * The required attributes for an Event object are:
   * @li "useValuesfromTriggerTime" (required in SBML Level&nbsp;3)
   *
   * @return @c true if the required attributes have been set, @c false
   * otherwise.
   */
  virtual bool hasRequiredAttributes() const;


  /**
   * Predicate returning @c true if
   * all the required elements for the given Event_t structure
   * have been set.
   *
   * @note The required elements for an Event object are:
   * @li "trigger"
   * @li "listOfEventAssignments" (required in SBML Level&nbsp;2, optional in Level&nbsp;3)
   */
  virtual bool hasRequiredElements() const;


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

  bool isExplicitlySetUVFTT() const { return mExplicitlySetUVFTT; } ;


  std::string             mId;
  std::string             mName;
  Trigger*                mTrigger;
  Delay*                  mDelay;
  Priority*               mPriority;
  std::string             mTimeUnits;
  bool                    mUseValuesFromTriggerTime;
  bool                    mIsSetUseValuesFromTriggerTime;
  bool mInternalIdOnly;
  bool mExplicitlySetUVFTT;
  ListOfEventAssignments  mEventAssignments;
  

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



class LIBSBML_EXTERN ListOfEvents : public ListOf
{
public:

  /**
   * Creates a new ListOfEvents object.
   *
   * The object is constructed such that it is valid for the given SBML
   * Level and Version combination.
   *
   * @param level the SBML Level
   * 
   * @param version the Version within the SBML Level
   */
  ListOfEvents (unsigned int level, unsigned int version);
          

  /**
   * Creates a new ListOfEvents object.
   *
   * The object is constructed such that it is valid for the SBML Level and
   * Version combination determined by the SBMLNamespaces object in @p
   * sbmlns.
   *
   * @param sbmlns an SBMLNamespaces object that is used to determine the
   * characteristics of the ListOfEvents object to be created.
   */
  ListOfEvents (SBMLNamespaces* sbmlns);


  /**
   * Creates and returns a deep copy of this ListOfEvents object.
   *
   * @return the (deep) copy of this ListOfEvents object.
   */
  virtual ListOfEvents* clone () const;


  /**
   * Returns the libSBML type code for the objects contained in this ListOf
   * (i.e., Event objects, if the list is non-empty).
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for the objects contained in this ListOf:
   * @sbmlconstant{SBML_EVENT, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of this object.
   *
   * For ListOfEvents, the XML element name is @c "listOfEvents".
   * 
   * @return the name of this element, i.e., @c "listOfEvents".
   */
  virtual const std::string& getElementName () const;


   /**
   * Get an Event from the ListOfEvents.
   *
   * @param n the index number of the Event to get.
   * 
   * @return the <code>n</code>th Event in this ListOfEvents.
   *
   * @see size()
   */
  virtual Event * get(unsigned int n); 


  /**
   * Get an Event from the ListOfEvents.
   *
   * @param n the index number of the Event to get.
   * 
   * @return the <code>n</code>th Event in this ListOfEvents.
   *
   * @see size()
   */
  virtual const Event * get(unsigned int n) const; 


  /**
   * Get an Event from the ListOfEvents
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the Event to get.
   * 
   * @return Event in this ListOfEvents
   * with the given @p sid or @c NULL if no such
   * Event exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual Event* get (const std::string& sid);


  /**
   * Get an Event from the ListOfEvents
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the Event to get.
   * 
   * @return Event in this ListOfEvents
   * with the given @p sid or @c NULL if no such
   * Event exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const Event* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfEvents items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual Event* remove (unsigned int n);


  /**
   * Removes item in this ListOfEvents items with the given identifier.
   *
   * The caller owns the returned item and is responsible for deleting it.
   * If none of the items in this list have the identifier @p sid, then
   * @c NULL is returned.
   *
   * @param sid the identifier of the item to remove
   *
   * @return the item removed.  As mentioned above, the caller owns the
   * returned item.
   */
  virtual Event* remove (const std::string& sid);


 /** @cond doxygenLibsbmlInternal */

  /**
   * Get the ordinal position of this element in the containing object
   * (which in this case is the Model object).
   *
   * The ordering of elements in the XML form of SBML is generally fixed
   * for most components in SBML.  So, for example, the ListOfEvents in a
   * model is (in SBML Level&nbsp;2 Version&nbsp;4) the twelfth ListOf___.
   * (However, it differs for different Levels and Versions of SBML, so
   * calling code should not hardwire this number.)
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

/* ----------------------------------------------------------------------------
 * See the .cpp file for the documentation of the following functions.
 * --------------------------------------------------------------------------*/

/**
 * Creates a new Event_t structure using the given SBML @p level
 * and @p version values.
 *
 * @param level an unsigned int, the SBML Level to assign to this
 * Event_t
 *
 * @param version an unsigned int, the SBML Version to assign to this
 * Event_t
 *
 * @return a pointer to the newly created Event_t structure.
 *
 * @note Once an Event_t has been added to an SBMLDocument_t, the @p
 * level and @p version for the document @em override those used to create
 * the Event_t.  Despite this, the ability to supply the values at
 * creation time is an important aid to creating valid SBML.  Knowledge of
 * the intended SBML Level and Version  determine whether it is valid to
 * assign a particular value to an attribute, or whether it is valid to add
 * a structure to an existing SBMLDocument_t.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
Event_t *
Event_create (unsigned int level, unsigned int version);


/**
 * Creates a new Event_t structure using the given
 * SBMLNamespaces_t structure.
 *
 * @param sbmlns SBMLNamespaces_t, a pointer to an SBMLNamespaces_t structure
 * to assign to the given Event_t
 *
 * @return a pointer to the newly created Event_t structure.
 *
 * @note Once an Event_t has been added to an SBMLDocument_t, the
 * @p sbmlns namespaces for the document @em override those used to create
 * the Event_t.  Despite this, the ability to supply the values at creation time
 * is an important aid to creating valid SBML.  Knowledge of the intended SBML
 * Level and Version determine whether it is valid to assign a particular value
 * to an attribute, or whether it is valid to add a structure to an existing
 * SBMLDocument_t.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
Event_t *
Event_createWithNS (SBMLNamespaces_t *sbmlns);


/**
 * Frees the given Event_t structure.
 *
 * @param e the Event_t structure to free.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
void
Event_free (Event_t *e);


/**
 * Returns a copy of the given Event_t structure.
 *
 * @param e the Event_t structure to copy.
 * 
 * @return a (deep) copy of the Event_t.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
Event_t *
Event_clone (const Event_t *e);


/**
 * Returns a list of XMLNamespaces_t associated with the given Event_t
 * structure.
 *
 * @param e the Event_t structure
 * 
 * @return pointer to the XMLNamespaces_t structure associated with 
 * this structure
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
const XMLNamespaces_t *
Event_getNamespaces(Event_t *e);


/**
 * Takes an Event_t structure and returns its identifier.
 *
 * @param e the Event_t structure whose identifier is sought
 * 
 * @return the identifier of the given Event_t, as a pointer to a string.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
const char *
Event_getId (const Event_t *e);


/**
 * Takes an Event_t structure and returns its name.
 *
 * @param e the Event_t whose name is sought.
 *
 * @return the name of the given Event_t, as a pointer to a string.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
const char *
Event_getName (const Event_t *e);


/**
 * Takes an Event_t structure and returns its Trigger_t structure.
 *
 * @param e the Event_t structure whose trigger definition is sought.
 * 
 * @return the Trigger_t of the given Event_t.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
Trigger_t *
Event_getTrigger (Event_t *e);


/**
 * Takes an Event_t structure and returns its Delay_t structure.
 *
 * @param e the Event_t structure whose delay definition is sought.
 * 
 * @return the Delay_t of the given Event_t.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
Delay_t *
Event_getDelay (Event_t *e);


/**
 * Takes an Event_t structure and returns its Priority_t structure.
 *
 * @param e the Event_t structure whose delay definition is sought.
 * 
 * @return the Priority_t of the given Event_t.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
Priority_t *
Event_getPriority (Event_t *e);


/**
 * Takes an Event_t structure and returns the value of its "timeUnits"
 * attribute.
 *
 * @param e the Event_t structure whose "timeUnits" value is sought
 * 
 * @return the timeUnits of the given Event_t
 *
 * @warning Definitions of Event_t in SBML Level 2 Versions 1 and 2
 * included the additional attribute called "timeUnits", but it was
 * removed in SBML Level 2 Version 3.  LibSBML supports this attribute
 * for compatibility with previous versions of SBML Level 2, but its use
 * is discouraged since models in Level 2 Versions 3 and 4 cannot contain it.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
const char *
Event_getTimeUnits (const Event_t *e);


/**
 * Takes an Event_t structure and returns the value of its "useValuesFromTriggerTime"
 * attribute.
 *
 * @param e the Event_t structure whose "useValuesFromTriggerTime" value is sought
 * 
 * @return the useValuesFromTriggerTime of the given Event_t
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_getUseValuesFromTriggerTime (const Event_t *e);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * Event_t structure's identifier is set.
 *
 * @param e the Event_t structure to query
 * 
 * @return @c non-zero (true) if the "id" attribute of the given
 * Event_t structure is set, zero (false) otherwise.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_isSetId (const Event_t *e);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * Event_t structure's name is set.
 *
 * @param e the Event_t structure to query
 * 
 * @return @c non-zero (true) if the "name" attribute of the given
 * Event_t structure is set, zero (false) otherwise.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_isSetName (const Event_t *e);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * Event_t structure's trigger is set.
 *
 * @param e the Event_t structure to query
 * 
 * @return @c non-zero (true) if a Trigger_t structure is assigned to
 * the given Event_t structure, zero (false) otherwise.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_isSetTrigger (const Event_t *e);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * Event_t structure's delay is set.
 *
 * @param e the Event_t structure to query
 * 
 * @return @c non-zero (true) if a Delay_t structure is assigned to
 * the given Event_t structure, zero (false) otherwise.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_isSetDelay (const Event_t *e);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * Event_t structure's priority is set.
 *
 * @param e the Event_t structure to query
 * 
 * @return @c non-zero (true) if a Priority_t structure is assigned to
 * the given Event_t structure, zero (false) otherwise.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_isSetPriority (const Event_t *e);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * Event_t structure's "timeUnits" attribute is set.
 *
 * @param e the Event_t structure to query
 * 
 * @return @c non-zero (true) if a value for the "timeUnits" attribute is
 * assigned in the given Event_t structure, zero (false) otherwise.
 *
 * @warning Definitions of Event_t in SBML Level 2 Versions 1 and 2
 * included the additional attribute called "timeUnits", but it was
 * removed in SBML Level 2 Version 3.  LibSBML supports this attribute
 * for compatibility with previous versions of SBML Level 2, but its use
 * is discouraged since models in Level 2 Versions 3 and 4 cannot contain it.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_isSetTimeUnits (const Event_t *e);


/**
 * Predicate returning @c true or @c false depending on whether the given
 * Event_t structure's useValuesFromTriggerTime attribute is set.
 *
 * @param e the Event_t structure to query
 * 
 * @return @c non-zero (true) if the "useValuesFromTriggerTime" attribute of the given
 * Event_t structure is set, zero (false) otherwise.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_isSetUseValuesFromTriggerTime (const Event_t *e);


/**
 * Assigns the identifier of an Event_t structure.
 *
 * This makes a copy of the string passed in the param @p sid.
 *
 * @param e the Event_t structure to set.
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
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_setId (Event_t *e, const char *sid);


/**
 * Sets the name of the given Event_t to a copy of @p name.
 *
 * @param e the Event_t structure to set
 * @param name the name to assign to the given Event_t's "name" attribute.
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
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_setName (Event_t *e, const char *name);


/**
 * Sets the trigger of the given Event_t to a copy of the given Trigger_t.
 *
 * @param e the Event_t structure to set
 * @param trigger the Trigger_t structure to use.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_setTrigger (Event_t *e, const Trigger_t *trigger);


/**
 * Sets the delay of the given Event_t to a copy of the given Delay_t.
 * 
 * @param e the Event_t structure to set
 * @param delay the Delay_t structure to use.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_setDelay (Event_t *e, const Delay_t *delay);


/**
 * Sets the priority of the given Event_t to a copy of the given Priority_t.
 * 
 * @param e the Event_t structure to set
 * @param priority the Priority_t structure to use.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_LEVEL_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_VERSION_MISMATCH, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_setPriority (Event_t *e, const Priority_t *priority);


/**
 * Sets the "timeUnits" attribute of the given Event_t to a copy of @p sid.
 * 
 * @param e the Event_t structure to set
 * @param sid the identifier of the units to use as the value of the
 * "timeUnits" attribute
 *
 * @warning Definitions of Event_t in SBML Level 2 Versions 1 and 2
 * included the additional attribute called "timeUnits", but it was
 * removed in SBML Level 2 Version 3.  LibSBML supports this attribute
 * for compatibility with previous versions of SBML Level 2, but its use
 * is discouraged since models in Level 2 Versions 3 and 4 cannot contain it.
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
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_setTimeUnits (Event_t *e, const char *sid);


/**
 * Sets the "useValuesFromTriggerTime" attribute of the given Event_t to a @p value.
 * 
 * @param e the Event_t structure to set
 * @param value the value of the "useValuesFromTriggerTime" attribute
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_UNEXPECTED_ATTRIBUTE, OperationReturnValues_t}
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_setUseValuesFromTriggerTime (Event_t *e, int value);


/**
 * Unsets the "id" attribute of the given Event_t structure.
 *
 * @param e the Event_t structure to unset
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_unsetId (Event_t *e);


/**
 * Unsets the "name" attribute of the given Event_t structure.
 *
 * @param e the Event_t structure to unset
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_unsetName (Event_t *e);


/**
 * Unsets the delay of the given Event_t.
 *
 * @param e the Event_t structure to unset
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_unsetDelay (Event_t *e);


/**
 * Unsets the priority of the given Event_t.
 *
 * @param e the Event_t structure to unset
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_unsetPriority (Event_t *e);


/**
 * Unsets the "timeUnits" attribute of the given Event_t.
 *
 * @param e the Event_t structure to unset
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 *
 * @warning Definitions of Event_t in SBML Level 2 Versions 1 and 2
 * included the additional attribute called "timeUnits", but it was
 * removed in SBML Level 2 Version 3.  LibSBML supports this attribute
 * for compatibility with previous versions of SBML Level 2, but its use
 * is discouraged since models in Level 2 Versions 3 and 4 cannot contain it.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_unsetTimeUnits (Event_t *e);


/**
 * Predicate returning @c true or @c false depending on whether
 * all the required attributes for the given Event_t structure
 * have been set.
 *
 * The required attributes for an Event_t structure are:
 * @li useValuesfromTriggerTime ( L3 onwards )
 *
 * @return @c 1 if the required attributes have been set, @c 0
 * otherwise.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_hasRequiredAttributes (Event_t *e);


/**
  * Predicate returning @c true or @c false depending on whether
  * all the required elements for the given Event_t structure
  * have been set.
  *
  * @note The required elements for an Event_t structure are:
  * @li trigger
  * @li listOfEventAssignments (requirement removed in L3)
  *
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_hasRequiredElements (Event_t *e);


/**
 * Appends a copy of the given EventAssignment_t structure to the given Event_t
 * structure.
 *
 * @param e the Event_t structure to which the EventAssignment_t should be
 * added
 *
 * @param ea an EventAssignment_t structure to add
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
 * @memberof Event_t
 */
LIBSBML_EXTERN
int
Event_addEventAssignment (Event_t *e, const EventAssignment_t *ea);


/**
 * Creates a new, empty EventAssignment_t structure, adds it to this
 * Event_t's list of event assignments, and returns the EventAssignment_t.
 *
 * @param e the Event_t structure to which the event assignment should be
 * added
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
EventAssignment_t *
Event_createEventAssignment (Event_t *e);


/**
 * Creates a new, empty Trigger_t structure, adds it to this
 * Event_t, and returns the Trigger_t.
 *
 * @param e the Event_t structure to which the trigger should be
 * added
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
Trigger_t *
Event_createTrigger (Event_t *e);


/**
 * Creates a new, empty Delay_t structure, adds it to this
 * Event_t, and returns the Delay_t.
 *
 * @param e the Event_t structure to which the delay should be
 * added
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
Delay_t *
Event_createDelay (Event_t *e);


/**
 * Creates a new, empty Priority_t structure, adds it to this
 * Event_t, and returns the Priority_t.
 *
 * @param e the Event_t structure to which the priority should be
 * added
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
Priority_t *
Event_createPriority (Event_t *e);


/**
 * Get the list of EventAssignment_t structures from the given Event_t
 * structure.
 *
 * @param e the Event_t structure to use.
 *
 * @return the list of EventAssignments for the given Event_t.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
ListOf_t *
Event_getListOfEventAssignments (Event_t *e);


/**
 * Return a specific EventAssignment_t structure of the given Event_t.
 *
 * @param e the Event_t structure to use
 *
 * @param n an integer, the index of the EventAssignment_t structure to return
 * 
 * @return the nth EventAssignment_t of the given Event_t, or @c NULL if no such EventAssignment_t exists.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
EventAssignment_t *
Event_getEventAssignment (Event_t *e, unsigned int n);


/**
 * Return the event assignment indicated by the given @p variable.
 *
 * @param e the Event_t structure to use
 *
 * @param variable a string, the identifier of the variable whose
 * EventAssignment_t is being sought.
 *
 * @return the EventAssignment_t for the given variable, or @c NULL if no such
 * EventAssignment_t exits.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
EventAssignment_t *
Event_getEventAssignmentByVar (Event_t *e, const char *variable);


/**
 * Returns the number of EventAssignment_t structures attached to the given
 * Event_t.
 *
 * @param e the Event_t structure to use
 * 
 * @return the number of EventAssignment_t structures in the given Event_t.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
unsigned int
Event_getNumEventAssignments (const Event_t *e);


/**
 * Removes the nth EventAssignment_t structure from the given Event_t structure and
 * returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param e the Event_t structure
 * @param n the integer index of the EventAssignment_t sought
 *
 * @return the EventAssignment_t structure removed.  As mentioned above, 
 * the caller owns the returned item. @c NULL is returned if the given index 
 * is out of range.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
EventAssignment_t *
Event_removeEventAssignment (Event_t *e, unsigned int n);


/**
 * Removes the EventAssignment_t structure with the given "variable" attribute
 * from the given Event_t structure and returns a pointer to it.
 *
 * The caller owns the returned structure and is responsible for deleting it.
 *
 * @param e the Event_t structure
 * @param variable the string of the "variable" attribute of the EventAssignment_t sought
 *
 * @return the EventAssignment_t structure removed.  As mentioned above, the 
 * caller owns the returned structure. @c NULL is returned if no EventAssignment_t
 * structure with the "variable" attribute exists in the given Event_t structure.
 *
 * @memberof Event_t
 */
LIBSBML_EXTERN
EventAssignment_t *
Event_removeEventAssignmentByVar (Event_t *e, const char *variable);

/**
 * Returns the Event_t structure having a given identifier.
 *
 * @param lo the ListOfEvents_t structure to search.
 * @param sid the "id" attribute value being sought.
 *
 * @return item in the @p lo ListOfEvents with the given @p sid or a
 * null pointer if no such item exists.
 *
 * @see ListOf_t
 *
 * @memberof ListOfEvents_t
 */
LIBSBML_EXTERN
Event_t *
ListOfEvents_getById (ListOf_t *lo, const char *sid);


/**
 * Removes a Event_t structure based on its identifier.
 *
 * The caller owns the returned item and is responsible for deleting it.
 *
 * @param lo the list of Event_t structures to search.
 * @param sid the "id" attribute value of the structure to remove
 *
 * @return The Event_t structure removed, or a null pointer if no such
 * item exists in @p lo.
 *
 * @see ListOf_t
 *
 * @memberof ListOfEvents_t
 */
LIBSBML_EXTERN
Event_t *
ListOfEvents_removeById (ListOf_t *lo, const char *sid);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG   */
#endif  /* Event_h */
