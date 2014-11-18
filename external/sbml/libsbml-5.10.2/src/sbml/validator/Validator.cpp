/**
 * @file    Validator.cpp
 * @brief   Base class for SBML Validators
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#include <algorithm>
#include <functional>
#include <typeinfo>

#include <sbml/SBMLVisitor.h>

#include <sbml/units/FormulaUnitsData.h>

#include <sbml/validator/VConstraint.h>
#include <sbml/validator/Validator.h>
#include <sbml/validator/UnitConsistencyValidator.h>
#include <sbml/AlgebraicRule.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>
#include <sbml/ModifierSpeciesReference.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLReader.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

//
// NOTE: ConstraintSet, ValidatorConstraints, and ValidatingVisitor used to
// be in separate .cpp and .h files, but in order to link under MSVC6 (the
// compiler doesn't instantiate templates (i.e. generate code), even when
// told explicitly to do so), the classes needed to be combined into a single
// file.
//


// ----------------------------------------------------------------------
// Apply<T> and ConstraintSet<T>
// ----------------------------------------------------------------------


/**
 * Applies a Constraint<T> to an SBML object of type T.
 */
template <typename T>
struct Apply : public unary_function<TConstraint<T>*, void>
{
  Apply (const Model& m, const T& o) : model(m), object(o) { }


  void operator() (TConstraint<T>* constraint)
  {
    constraint->check(model, object);
  }


  const Model& model;
  const T&     object;
};


template <typename T>
class ConstraintSet
{
public:

   ConstraintSet () { }
  ~ConstraintSet () { }


  /**
   * Adds a Constraint to this ConstraintSet.
   */
  void add (TConstraint<T>* c)
  {
    constraints.push_back(c);
  }

  /**
   * Applies all Constraints in this ConstraintSet to the given SBML object
   * of type T.  Constraint violations are logged to Validator.
   */
  void applyTo (const Model& model, const T& object)
  {
    for_each(constraints.begin(), constraints.end(), Apply<T>(model, object));
  }

  /**
   * Returns true if this ConstraintSet is empty, false otherwise.
   *
   * @return true if this ConstraintSet is empty, false otherwise.
   */
  bool empty () const
  {
    return constraints.empty();
  }


protected:

  std::list< TConstraint<T>* > constraints;
};



// ----------------------------------------------------------------------




// ----------------------------------------------------------------------
// ValidatorConstraints
// ----------------------------------------------------------------------

/**
 * ValidatorConstraints maintain a separate list of constraints for each
 * SBML type.  This is done so that constraints may be applied efficiently
 * during the validation process.
 */
struct ValidatorConstraints
{
  ConstraintSet<SBMLDocument>             mSBMLDocument;
  ConstraintSet<Model>                    mModel;
  ConstraintSet<FunctionDefinition>       mFunctionDefinition;
  ConstraintSet<UnitDefinition>           mUnitDefinition;
  ConstraintSet<Unit>                     mUnit;
  ConstraintSet<Compartment>              mCompartment;
  ConstraintSet<Species>                  mSpecies;
  ConstraintSet<Parameter>                mParameter;
  ConstraintSet<Rule>                     mRule;
  ConstraintSet<AlgebraicRule>            mAlgebraicRule;
  ConstraintSet<AssignmentRule>           mAssignmentRule;
  ConstraintSet<RateRule>                 mRateRule;
  ConstraintSet<Reaction>                 mReaction;
  ConstraintSet<KineticLaw>               mKineticLaw;
  ConstraintSet<SimpleSpeciesReference>   mSimpleSpeciesReference;
  ConstraintSet<SpeciesReference>         mSpeciesReference;
  ConstraintSet<ModifierSpeciesReference> mModifierSpeciesReference;
  ConstraintSet<Event>                    mEvent;
  ConstraintSet<EventAssignment>          mEventAssignment;
  ConstraintSet<InitialAssignment>        mInitialAssignment;
  ConstraintSet<Constraint>               mConstraint;
  ConstraintSet<Trigger>                  mTrigger;
  ConstraintSet<Delay>                    mDelay;
  ConstraintSet<CompartmentType>          mCompartmentType;
  ConstraintSet<SpeciesType>              mSpeciesType;
  ConstraintSet<Priority>                 mPriority;

  map<VConstraint*,bool> ptrMap;

  ~ValidatorConstraints ();
  void add (VConstraint* c);
};

/*
 * Deletes constraints (TConstraint(T>*) which are stored in lists
 * (ConstraintSet<T>) of this struct.
 * Since the same pointer values could be stored in different lists
 * (e.g., TConstraint<SimpleSpeciesReference>* is stored in both
 * ConstraintSet<SimpleSpeciesReference> and
 * ConstraintSet<ModifierSimpleSpeciesReference>), a pointer map is used for
 * avoiding segmentation fault caused by deleting the same pointer twice.
 */
ValidatorConstraints::~ValidatorConstraints ()
{
  map<VConstraint*,bool>::iterator it = ptrMap.begin();

  while(it != ptrMap.end())
  {
     if(it->second) delete it->first;
     ++it;
  }
}


/*
 * Adds the given Contraint to the appropriate ConstraintSet.
 */
void
ValidatorConstraints::add (VConstraint* c)
{
  if (c == NULL) return;

  ptrMap.insert(pair<VConstraint*,bool>(c,true));

  if (dynamic_cast< TConstraint<SBMLDocument>* >(c) != NULL)
  {
    mSBMLDocument.add( static_cast< TConstraint<SBMLDocument>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<Model>* >(c) != NULL)
  {
    mModel.add( static_cast< TConstraint<Model>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<FunctionDefinition>* >(c) != NULL)
  {
    mFunctionDefinition.add
    (
      static_cast< TConstraint<FunctionDefinition>* >(c)
    );
    return;
  }

  if (dynamic_cast< TConstraint<UnitDefinition>* >(c) != NULL)
  {
    mUnitDefinition.add( static_cast< TConstraint<UnitDefinition>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<Unit>* >(c) != NULL)
  {
    mUnit.add( static_cast< TConstraint<Unit>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<Compartment>* >(c) != NULL)
  {
    mCompartment.add( static_cast< TConstraint<Compartment>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<Species>* >(c) != NULL)
  {
    mSpecies.add( static_cast< TConstraint<Species>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<Parameter>* >(c) != NULL)
  {
    mParameter.add( static_cast< TConstraint<Parameter>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<Rule>* >(c) != NULL)
  {
    mRule.add( static_cast< TConstraint<Rule>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<AlgebraicRule>* >(c) != NULL)
  {
    mAlgebraicRule.add( static_cast< TConstraint<AlgebraicRule>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<AssignmentRule>* >(c) != NULL)
  {
    mAssignmentRule.add( static_cast< TConstraint<AssignmentRule>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<RateRule>* >(c) != NULL)
  {
    mRateRule.add( static_cast< TConstraint<RateRule>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<Reaction>* >(c) != NULL)
  {
    mReaction.add( static_cast< TConstraint<Reaction>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<KineticLaw>* >(c) != NULL)
  {
    mKineticLaw.add( static_cast< TConstraint<KineticLaw>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<SimpleSpeciesReference>* >(c) != NULL)
  {
    mSimpleSpeciesReference.add
    (
      static_cast< TConstraint<SimpleSpeciesReference>* >(c)
    );
    /* forces constraints to be applied to modifiers */
    mModifierSpeciesReference.add
    (
      static_cast< TConstraint<ModifierSpeciesReference>* >(c)
    );
    return;
  }

  if (dynamic_cast< TConstraint<SpeciesReference>* >(c) != NULL)
  {
    mSpeciesReference.add
    (
      static_cast< TConstraint<SpeciesReference>* >(c)
    );
    /* forces constraints to be applied to modifiers */
    mModifierSpeciesReference.add
    (
      static_cast< TConstraint<ModifierSpeciesReference>* >(c)
    );
    return;
  }

  if (dynamic_cast< TConstraint<ModifierSpeciesReference>* >(c) != NULL)
  {
    mModifierSpeciesReference.add
    (
      static_cast< TConstraint<ModifierSpeciesReference>* >(c)
    );
    return;
  }

  if (dynamic_cast< TConstraint<Event>* >(c) != NULL)
  {
    mEvent.add( static_cast< TConstraint<Event>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<EventAssignment>* >(c) != NULL)
  {
    mEventAssignment.add( static_cast< TConstraint<EventAssignment>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<InitialAssignment>* >(c) != NULL)
  {
    mInitialAssignment.add( static_cast< TConstraint<InitialAssignment>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<Constraint>* >(c) != NULL)
  {
    mConstraint.add( static_cast< TConstraint<Constraint>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<Trigger>* >(c) != NULL)
  {
    mTrigger.add( static_cast< TConstraint<Trigger>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<Delay>* >(c) != NULL)
  {
    mDelay.add( static_cast< TConstraint<Delay>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<CompartmentType>* >(c) != NULL)
  {
    mCompartmentType.add( static_cast< TConstraint<CompartmentType>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<SpeciesType>* >(c) != NULL)
  {
    mSpeciesType.add( static_cast< TConstraint<SpeciesType>* >(c) );
    return;
  }

  if (dynamic_cast< TConstraint<Priority>* >(c) != NULL)
  {
    mPriority.add( static_cast< TConstraint<Priority>* >(c) );
    return;
  }

}

// ----------------------------------------------------------------------




// ----------------------------------------------------------------------
// ValidatingVisitor
// ----------------------------------------------------------------------


/*
 * An SBMLVisitor visits each object in an SBML object tree, calling the
 * appropriate visit() method for the object visited.
 *
 * A ValidatingVisitor overrides each visit method to validate the given
 * SBML object.
 */
class ValidatingVisitor: public SBMLVisitor
{
public:

  ValidatingVisitor (Validator& v, const Model& m) : v(v), m(m) { }


  void visit (const SBMLDocument& x)
  {
    v.mConstraints->mSBMLDocument.applyTo(m, x);
  }


  void visit (const Model& x)
  {
    v.mConstraints->mModel.applyTo(m, x);
  }


  void visit (const KineticLaw& x)
  {
    v.mConstraints->mKineticLaw.applyTo(m, x);
  }

  void visit (const Priority& x)
  {
    v.mConstraints->mPriority.applyTo(m, x);
  }


  /*
   * Visit methods should return true if the more objects of the given type
   * should be visited and false otherwise.
   *
   * For example, it doesn't make sense to keep visiting additional
   * FunctionDefinition objects in the SBML object tree if no
   * FunctionDefinition constraints have been added to the validator. ...
   */

  bool visit (const FunctionDefinition& x)
  {
    v.mConstraints->mFunctionDefinition.applyTo(m, x);
    return !v.mConstraints->mFunctionDefinition.empty();
  }


  /*
   * ... In this case, even if there are no UnitDefinitionConstraints,
   * UnitDefinitions will still need to be visited to ensure that
   * subordinate Unit objects are visited.  If no UnitDefinition or Unit
   * constraints exist, then its okay to skip further UnitDefinitions.
   */

  bool visit (const UnitDefinition& x)
  {
    v.mConstraints->mUnitDefinition.applyTo(m, x);

    return
      !v.mConstraints->mUnitDefinition.empty() ||
      !v.mConstraints->mUnit          .empty();
  }


  bool visit (const Unit& x)
  {
    v.mConstraints->mUnit.applyTo(m, x);
    return !v.mConstraints->mUnit.empty();
  }


  bool visit (const Compartment &x)
  {
    v.mConstraints->mCompartment.applyTo(m, x);
    return !v.mConstraints->mCompartment.empty();
  }


  bool visit (const Species& x)
  {
    v.mConstraints->mSpecies.applyTo(m, x);
    return !v.mConstraints->mSpecies.empty();
  }


  bool visit (const Parameter& x)
  {
    v.mConstraints->mParameter.applyTo(m, x);
    return !v.mConstraints->mParameter.empty();
  }


  bool visit (const Rule& x)
  {
    v.mConstraints->mRule.applyTo(m, x);
    return true;
  }


  bool visit (const AlgebraicRule& x)
  {
    visit( static_cast<const Rule&>(x) );
    v.mConstraints->mAlgebraicRule.applyTo(m, x);

    return true;
  }


  bool visit (const AssignmentRule& x)
  {
    visit( static_cast<const Rule&>(x) );
    v.mConstraints->mAssignmentRule.applyTo(m, x);

    return true;
  }


  bool visit (const RateRule& x)
  {
    visit( static_cast<const Rule&>(x) );
    v.mConstraints->mRateRule.applyTo(m, x);

    return true;
  }


  bool visit (const Reaction& x)
  {
    v.mConstraints->mReaction.applyTo(m, x);
    return true;
  }


  bool visit (const SimpleSpeciesReference& x)
  {
    v.mConstraints->mSimpleSpeciesReference.applyTo(m, x);
    return true;
  }


  bool visit (const SpeciesReference& x)
  {
    visit( static_cast<const SimpleSpeciesReference&>(x) );
    v.mConstraints->mSpeciesReference.applyTo(m, x);

    return
      !v.mConstraints->mSimpleSpeciesReference.empty() ||
      !v.mConstraints->mSpeciesReference      .empty();
  }


  bool visit (const ModifierSpeciesReference& x)
  {
    visit( static_cast<const SimpleSpeciesReference&>(x) );
    v.mConstraints->mModifierSpeciesReference.applyTo(m, x);

    return
      !v.mConstraints->mSimpleSpeciesReference  .empty() ||
      !v.mConstraints->mModifierSpeciesReference.empty();
  }


  bool visit (const Event& x)
  {
    v.mConstraints->mEvent.applyTo(m, x);

    return
      !v.mConstraints->mEvent          .empty() ||
      !v.mConstraints->mEventAssignment.empty();
  }


  bool visit (const EventAssignment& x)
  {
    v.mConstraints->mEventAssignment.applyTo(m, x);
    return !v.mConstraints->mEventAssignment.empty();
  }

  bool visit (const InitialAssignment& x)
  {
    v.mConstraints->mInitialAssignment.applyTo(m, x);
    return !v.mConstraints->mInitialAssignment.empty();
  }

  bool visit (const Constraint& x)
  {
    v.mConstraints->mConstraint.applyTo(m, x);
    return !v.mConstraints->mConstraint.empty();
  }

  bool visit (const Trigger& x)
  {
    v.mConstraints->mTrigger.applyTo(m, x);
    return !v.mConstraints->mTrigger.empty();
  }

  bool visit (const Delay& x)
  {
    v.mConstraints->mDelay.applyTo(m, x);
    return !v.mConstraints->mDelay.empty();
  }

  bool visit (const CompartmentType& x)
  {
    v.mConstraints->mCompartmentType.applyTo(m, x);
    return !v.mConstraints->mCompartmentType.empty();
  }

  bool visit (const SpeciesType& x)
  {
    v.mConstraints->mSpeciesType.applyTo(m, x);
    return !v.mConstraints->mSpeciesType.empty();
  }


protected:

  Validator&   v;
  const Model& m;
};


// ----------------------------------------------------------------------




// ----------------------------------------------------------------------
// Validator
// ----------------------------------------------------------------------


Validator::Validator (const SBMLErrorCategory_t category)
{
  mCategory = category;
  mConstraints = new ValidatorConstraints();
}


Validator::~Validator ()
{
  delete mConstraints;
}


/*
 * Adds the given Contraint to this validator.
 */
void
Validator::addConstraint (VConstraint* c)
{
  mConstraints->add(c);
}


/*
 * Clears the Validator's list of failures.
 *
 * If you are validating multiple SBML documents with the same Validator,
 * call this method after you have processed the list of failures from the
 * last Validation run and before validating the next document.
 */
void
Validator::clearFailures ()
{
  mFailures.clear();
}


/*
 * @return the category covered by this Validator.
 */
const unsigned int
Validator::getCategory () const
{
  return mCategory;
}


/*
 * @return a list of failures logged during validation.
 */
const std::list<SBMLError>&
Validator::getFailures () const
{
  return mFailures;
}


/*
 * Adds the given failure to this list of Validators failures.
 */
void
Validator::logFailure (const SBMLError& msg)
{
  if (&msg == NULL) return;
  mFailures.push_back(msg);
}

/*
 * Helper class used by
 * validate
 */
class MatchId
{
public:
  MatchId(unsigned int id) : id(id) {};

  bool operator() (XMLError e) const
  {
    return e.getErrorId() == id;
  };

private:
  unsigned int id;
};

class DontMatchId
{
public:
  DontMatchId(unsigned int id) : id(id) {};

  bool operator() (XMLError e) const
  {
    return e.getErrorId() != id;
  };

private:
  unsigned int id;
};

/*
 * Validates the given SBMLDocument.  Failures logged during
 * validation may be retrieved via <code>getFailures()</code>.
 *
 * @return the number of validation errors that occurred.
 */
unsigned int
Validator::validate (const SBMLDocument& d)
{
  if (&d == NULL) return 0;

  Model* m = const_cast<SBMLDocument&>(d).getModel();

  if (m != NULL)
  {
    if (this->getCategory() == LIBSBML_CAT_UNITS_CONSISTENCY)
    {
      /* create list of formula units for validation */
      if (!m->isPopulatedListFormulaUnitsData())
      {
        m->populateListFormulaUnitsData();
      }
    }
    ValidatingVisitor vv(*this, *m);
    d.accept(vv);
  }

  if (this->getCategory() == LIBSBML_CAT_SBO_CONSISTENCY
      && mFailures.size() > 1)
  {
    /* in SBO check if we have encountered an unrecognised term error
     * dont want to report the others since they may not be accurate
     */
    bool unrecognisedTerm = false;

    int n = 0;

#if defined(__SUNPRO_CC)
    // Workaround for Sun cc which is missing:
    count_if(mFailures.begin(), mFailures.end(), MatchId(99701), n);
#else
    n = (int)count_if(mFailures.begin(), mFailures.end(), MatchId(99701));
#endif

    if (n != 0)
      unrecognisedTerm = true;

    if (unrecognisedTerm)
    {
      std::list<SBMLError>::iterator it;
      it = remove_if(mFailures.begin(), mFailures.end(),DontMatchId(99701));
      mFailures.erase(it, mFailures.end());

      //remove_if(mFailures.begin(), mFailures.end(), DontMatchId(99701));
    }
  }

  return (unsigned int)mFailures.size();
}


/*
 * Validates the given SBMLDocument.  Failures logged during
 * validation may be retrieved via <code>getFailures()</code>.
 *
 * @return the number of validation errors that occurred.
 */
unsigned int
Validator::validate (const std::string& filename)
{
  if (&filename == NULL) return 0;

  SBMLReader    reader;
  SBMLDocument& d = *reader.readSBML(filename);


  for (unsigned int n = 0; n < d.getNumErrors(); ++n)
  {
    logFailure( *d.getError(n) );
  }

  return validate(d);
}

#endif /* __cplusplus */


/** @cond doxygenIgnored */

/** @endcond */
LIBSBML_CPP_NAMESPACE_END

// ----------------------------------------------------------------------

