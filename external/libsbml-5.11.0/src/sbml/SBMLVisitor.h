/**
 * @file   SBMLVisitor.h
 * @brief  Visitor Design Pattern for the SBML object tree
 * @author Ben Bornstein
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
 * ---------------------------------------------------------------------- -->
 *
 * @class SBMLVisitor
 * @sbmlbrief{core} Support class for operations on SBML objects.
 * 
 * <em style='color: #555'>This class of objects is defined by libSBML only
 * and has no direct equivalent in terms of SBML components.</em>
 * 
 * This is a class that supports the use of the <a target="_blank"
 * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
 * Pattern</i></a> to perform operations on SBML objects.  The LibSBML
 * implementation of the Visitor Pattern couples the notion of visitation
 * with the traversal of an SBML model oject hierarchy.
 *
 * This class (SBMLVisitor) does not provide stand-alone functionality;
 * rather, it defines the interface that user visitor classes must
 * implement.  All of the individual SBML object classes have methods named
 * <code>accept</code> that are used for invoking an object of class
 * SBMLVisitor.  An example of its use is in the SBML validation system,
 * which is internally implemented using this Visitor Pattern facility.
 */

#ifndef SBMLVisitor_h
#define SBMLVisitor_h


#ifdef __cplusplus


#include <sbml/common/extern.h>
#include <sbml/SBMLTypeCodes.h>


LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * Forward class name declarations avoid cyclic dependencies.
 */

class SBase;

class SBMLDocument;
class Model;
class FunctionDefinition;
class Unit;
class UnitDefinition;
class CompartmentType;
class SpeciesType;
class Compartment;
class Species;
class Parameter;
class InitialAssignment;

class Rule;
class AlgebraicRule;
class AssignmentRule;
class RateRule;

class Constraint;

class Reaction;
class SimpleSpeciesReference;
class ModifierSpeciesReference;
class SpeciesReference;
class KineticLaw;

class Event;
class EventAssignment;

class Trigger;
class Delay;
class Priority;

class ListOf;


class LIBSBML_EXTERN SBMLVisitor
{
public:

  /**
   * Destructor method.
   */
  virtual ~SBMLVisitor ();

  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on SBMLDocument objects.
   *
   * @param x the SBMLDocument object to visit.
   */
  virtual void visit (const SBMLDocument &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Model objects.
   *
   * @param x the Model object to visit.
   */
  virtual void visit (const Model        &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on KineticLaw objects.
   *
   * @param x the KineticLaw object to visit.
   */
  virtual void visit (const KineticLaw   &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on ListOf objects.
   *
   * @param x the ListOf object to visit.
   *
   * @param type the object type code.
   */
  virtual void visit (const ListOf       &x, int type);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on SBase objects.
   *
   * @param x the SBase object to visit.
   */
  virtual bool visit (const SBase                    &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on FunctionDefinition objects.
   *
   * @param x the FunctionDefinition object to visit.
   */
  virtual bool visit (const FunctionDefinition       &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on UnitDefinition objects.
   *
   * @param x the UnitDefinition object to visit.
   */
  virtual bool visit (const UnitDefinition           &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Unit objects.
   *
   * @param x the Unit object to visit.
   */
  virtual bool visit (const Unit                     &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on CompartmentType objects.
   *
   * @param x the CompartmentType object to visit.
   */
  virtual bool visit (const CompartmentType          &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on SpeciesType objects.
   *
   * @param x the SpeciesType object to visit.
   */
  virtual bool visit (const SpeciesType              &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Compartment objects.
   *
   * @param x the Compartment object to visit.
   */
  virtual bool visit (const Compartment              &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Species objects.
   *
   * @param x the Species object to visit.
   */
  virtual bool visit (const Species                  &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Parameter objects.
   *
   * @param x the Parameter object to visit.
   */
  virtual bool visit (const Parameter                &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on InitialAssignment objects.
   *
   * @param x the InitialAssignment object to visit.
   */
  virtual bool visit (const InitialAssignment        &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Rule objects.
   *
   * @param x the Rule object to visit.
   */
  virtual bool visit (const Rule                     &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on AlgebraicRule objects.
   *
   * @param x the AlgebraicRule object to visit.
   */
  virtual bool visit (const AlgebraicRule            &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on AssignmentRule objects.
   *
   * @param x the AssignmentRule object to visit.
   */
  virtual bool visit (const AssignmentRule           &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on RateRule objects.
   *
   * @param x the RateRule object to visit.
   */
  virtual bool visit (const RateRule                 &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Constraint objects.
   *
   * @param x the Constraint object to visit.
   */
  virtual bool visit (const Constraint               &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Reaction objects.
   *
   * @param x the Reaction object to visit.
   */
  virtual bool visit (const Reaction                 &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on SimpleSpeciesReference objects.
   *
   * @param x the SimpleSpeciesReference object to visit.
   */
  virtual bool visit (const SimpleSpeciesReference   &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on SpeciesReference objects.
   *
   * @param x the SpeciesReference object to visit.
   */
  virtual bool visit (const SpeciesReference         &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on ModifierSpeciesReference objects.
   *
   * @param x the ModifierSpeciesReference object to visit.
   */
  virtual bool visit (const ModifierSpeciesReference &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Event objects.
   *
   * @param x the Event object to visit.
   */
  virtual bool visit (const Event                    &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on EventAssignment objects.
   *
   * @param x the EventAssignment object to visit.
   */
  virtual bool visit (const EventAssignment          &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Trigger objects.
   *
   * @param x the Trigger object to visit.
   */
  virtual bool visit (const Trigger                  &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Delay objects.
   *
   * @param x the Delay object to visit.
   */
  virtual bool visit (const Delay                    &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Priority objects.
   *
   * @param x the Priority object to visit.
   */
  virtual void visit (const Priority                 &x);



  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on SBMLDocument objects.
   *
   * @param x the SBMLDocument object to visit.
   */
  virtual void leave (const SBMLDocument &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Model objects.
   *
   * @param x the Model object to visit.
   */
  virtual void leave (const Model        &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on KineticLaw objects.
   *
   * @param x the KineticLaw object to visit.
   */
  virtual void leave (const KineticLaw   &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Priority objects.
   *
   * @param x the Priority object to visit.
   */
  virtual void leave (const Priority     &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Reaction objects.
   *
   * @param x the Reaction object to visit.
   */
  virtual void leave (const Reaction     &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on Reaction objects.
   *
   * @param x the Reaction object to visit.
   */
  virtual void leave (const SBase     &x);


  /**
   * Interface method for using the <a target="_blank" 
   * href="http://en.wikipedia.org/wiki/Design_pattern_(computer_science)"><i>Visitor
   * Pattern</i></a> to perform operations on ListOf objects.
   *
   * @param x the ListOf object to visit.
   *
   * @param type the object type code.
   *
   */
  virtual void leave (const ListOf &x, int type);
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */
#endif  /* SBMLVisitor_h */

