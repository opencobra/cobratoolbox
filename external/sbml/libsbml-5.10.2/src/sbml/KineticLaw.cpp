/**
 * @file    KineticLaw.cpp
 * @brief   Implementation of KineticLaw.
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
 * ---------------------------------------------------------------------- -->*/

#include <sbml/xml/XMLNode.h>
#include <sbml/xml/XMLAttributes.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>

#include <sbml/math/FormulaFormatter.h>
#include <sbml/math/FormulaParser.h>
#include <sbml/math/MathML.h>
#include <sbml/math/ASTNode.h>

#include <sbml/SBO.h>
#include <sbml/SBMLVisitor.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLError.h>
#include <sbml/Model.h>
#include <sbml/Parameter.h>
#include <sbml/KineticLaw.h>

#include <sbml/util/ElementFilter.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

KineticLaw::KineticLaw (unsigned int level, unsigned int version) :
   SBase ( level, version )
 , mMath          ( NULL              )
 , mParameters      (level, version)
 , mLocalParameters (level, version)
 , mTimeUnits       ("")
 , mSubstanceUnits  ("")
 , mInternalId      ("")

{
  if (!hasValidLevelVersionNamespaceCombination())
    throw SBMLConstructorException();

  connectToChild();
}


KineticLaw::KineticLaw (SBMLNamespaces * sbmlns) :
   SBase            (sbmlns )
 , mMath          ( NULL              )
 , mParameters      (sbmlns)
 , mLocalParameters (sbmlns)
 , mTimeUnits       ("")
 , mSubstanceUnits  ("")
 , mInternalId      ("")

{
  if (!hasValidLevelVersionNamespaceCombination())
  {
    throw SBMLConstructorException(getElementName(), sbmlns);
  }

  connectToChild();
  loadPlugins(sbmlns);
}


/*
 * Destroys this KineticLaw.
 */
KineticLaw::~KineticLaw ()
{
  delete mMath;
}


/*
 * Copy constructor. Creates a copy of this KineticLaw.
 */
KineticLaw::KineticLaw (const KineticLaw& orig) :
   SBase          ( orig                 )
 , mMath          ( NULL                    )
 , mParameters    ( orig.mParameters     )
 , mLocalParameters    ( orig.mLocalParameters     )
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mFormula         = orig.mFormula;
    mTimeUnits       = orig.mTimeUnits;
    mSubstanceUnits  = orig.mSubstanceUnits;
    mInternalId      = orig.mInternalId;

    if (orig.mMath != NULL) 
    {
      mMath = orig.mMath->deepCopy();
      mMath->setParentSBMLObject(this);
    }
  }
  connectToChild();
}


/*
 * Assignment operator
 */
KineticLaw& KineticLaw::operator=(const KineticLaw& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->SBase::operator =(rhs);
    mFormula        = rhs.mFormula        ;
    mTimeUnits      = rhs.mTimeUnits      ;
    mSubstanceUnits = rhs.mSubstanceUnits ;
    mParameters     = rhs.mParameters     ;
    mLocalParameters     = rhs.mLocalParameters     ;
    mInternalId     = rhs.mInternalId     ;
    
    delete mMath;
    if (rhs.mMath != NULL) 
    {
      mMath = rhs.mMath->deepCopy();
      mMath->setParentSBMLObject(this);
    }
    else
    {
      mMath = NULL;
    }
  }

  connectToChild();

  return *this;
}


/*
 * Accepts the given SBMLVisitor.
 */
bool
KineticLaw::accept (SBMLVisitor& v) const
{
  v.visit(*this);
  if (getLevel() > 2)
    mLocalParameters.accept(v);
  else
    mParameters.accept(v);
  v.leave(*this);

  return true;
}


/*
 * @return a (deep) copy of this KineticLaw.
 */
KineticLaw*
KineticLaw::clone () const
{
  return new KineticLaw(*this);
}


SBase*
KineticLaw::getElementBySId(const std::string& id)
{
  if (id.empty()) return NULL;
  //Don't look in mParameters--they're only for L1, so their IDs are not appropriate, and they won't have L3 plugins on them.  We can't rely on ListOfParameters being overridden, either, as we can for ListOfLocalParameters.
  SBase* obj = mLocalParameters.getElementBySId(id);
  if (obj != NULL) return obj;

  return getElementFromPluginsBySId(id);
}


SBase*
KineticLaw::getElementByMetaId(const std::string& metaid)
{
  if (metaid.empty()) return NULL;
  //Go ahead and check mParameters, since metaIDs are global.
  if (mParameters.getMetaId() == metaid) return &mParameters;
  if (mLocalParameters.getMetaId() == metaid) return &mLocalParameters;

  SBase* obj = mLocalParameters.getElementByMetaId(metaid);
  if (obj != NULL) return obj;
  obj = mParameters.getElementByMetaId(metaid);
  if (obj != NULL) return obj;

  return getElementFromPluginsByMetaId(metaid);
}


List*
KineticLaw::getAllElements(ElementFilter *filter)
{
  List* ret = new List();
  List* sublist = NULL;

  ADD_FILTERED_LIST(ret, sublist, mParameters, filter);
  ADD_FILTERED_LIST(ret, sublist, mLocalParameters, filter);
  
  ADD_FILTERED_FROM_PLUGIN(ret, sublist, filter);

  return ret;
}

/*
 * @return the formula of this KineticLaw.
 */
const string&
KineticLaw::getFormula () const
{
  if (mFormula.empty() == true && mMath != NULL)
  {
    char* s  = SBML_formulaToString(mMath);
    mFormula = s;

    free(s);
  }

  return mFormula;
}


/*
 * @return the math of this KineticLaw.
 */
const ASTNode*
KineticLaw::getMath () const
{
  if (mMath == NULL && mFormula.empty() == false)
  {
    mMath = SBML_parseFormula( mFormula.c_str() );
  }

  return mMath;
}


/*
 * @return the timeUnits of this KineticLaw.
 */
const string&
KineticLaw::getTimeUnits () const
{
  return mTimeUnits;
}


/*
 * @return the substanceUnits of this KineticLaw.
 */
const string&
KineticLaw::getSubstanceUnits () const
{
  return mSubstanceUnits;
}


/*
 * @return true if the formula (or equivalently the math) of this
 * KineticLaw is set, false otherwise.
 */
bool
KineticLaw::isSetFormula () const
{
  return (mFormula.empty() == false) || (mMath != NULL);
}


/*
 * @return true if the math (or equivalently the formula) of this
 * KineticLaw is set, false otherwise.
 */
bool
KineticLaw::isSetMath () const
{
  /* if the formula has been set but it is not a correct formula
   * it cannot be correctly transferred to an ASTNode so in fact
   * getMath will return @c NULL
   *
   * this function needs to test for this
   */
  bool formula = isSetFormula();
  
  if (formula)
  {
    const ASTNode *temp = getMath();
    if (temp == NULL)
      formula = false;
  }
    
  return formula;
}


/*
 * @return true if the timeUnits of this KineticLaw is set, false
 * otherwise.
 */
bool
KineticLaw::isSetTimeUnits () const
{
  return (mTimeUnits.empty() == false);
}


/*
 * @return true if the substanceUnits of this KineticLaw is set,
 * false otherwise.
 */
bool
KineticLaw::isSetSubstanceUnits () const
{
  return (mSubstanceUnits.empty() == false);
}


/*
 * Sets the formula of this KineticLaw to a copy of formula.
 */
int
KineticLaw::setFormula (const std::string& formula)
{
  if (&(formula) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    ASTNode * math = SBML_parseFormula(formula.c_str());
    if (formula == "")
    {
      mFormula.erase();
      delete mMath;
      mMath = NULL;
      return LIBSBML_OPERATION_SUCCESS;
    }
    else if (math == NULL || !(math->isWellFormedASTNode()))
    {
      return LIBSBML_INVALID_OBJECT;
    }
    else
    {
      mFormula = formula;

      if (mMath != NULL)
      {
        delete mMath;
        mMath = NULL;
      }
      return LIBSBML_OPERATION_SUCCESS;
    }
  }
}


/*
 * Sets the math of this KineticLaw to a copy of the given ASTNode.
 */
int
KineticLaw::setMath (const ASTNode* math)
{
  if (mMath == math) 
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else if (math == NULL)
  {
    delete mMath;
    mMath = NULL;
    mFormula.erase();
    return LIBSBML_OPERATION_SUCCESS;
  }
  else if (!(math->isWellFormedASTNode()))
  {
    return LIBSBML_INVALID_OBJECT;
  }
  else
  {
    delete mMath;
    mMath = (math != NULL) ? math->deepCopy() : NULL;
    if (mMath != NULL) mMath->setParentSBMLObject(this);
    mFormula.erase();
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the timeUnits of this KineticLaw to a copy of sid.
 */
int
KineticLaw::setTimeUnits (const std::string& sid)
{
  /* only in L1 and L2V1 */
  if (&(sid) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else if ((getLevel() == 2 && getVersion() > 1)
    || getLevel() > 2)
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else if (!(SyntaxChecker::isValidInternalSId(sid)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mTimeUnits = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Sets the substanceUnits of this KineticLaw to a copy of sid.
 */
int
KineticLaw::setSubstanceUnits (const std::string& sid)
{
  /* only in L1 and L2V1 */
  if (&(sid) == NULL)
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else if ((getLevel() == 2 && getVersion() > 1)
    || getLevel() > 2)
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
  else if (!(SyntaxChecker::isValidInternalSId(sid)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mSubstanceUnits = sid;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Unsets the timeUnits of this KineticLaw.
 */
int
KineticLaw::unsetTimeUnits ()
{
  /* only in L1 and L2V1 */
  if ((getLevel() == 2 && getVersion() > 1)
    || getLevel() > 2)
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }

  mTimeUnits.erase();

  if (mTimeUnits.empty()) 
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Unsets the substanceUnits of this KineticLaw.
 */
int
KineticLaw::unsetSubstanceUnits ()
{
  /* only in L1 and L2V1 */
  if ((getLevel() == 2 && getVersion() > 1)
    || getLevel() > 2)
  {
    return LIBSBML_UNEXPECTED_ATTRIBUTE;
  }
 
  mSubstanceUnits.erase();
  
  if (mSubstanceUnits.empty()) 
  {
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_OPERATION_FAILED;
  }
}


/*
 * Adds a copy of the given Parameter to this KineticLaw.
 */
int
KineticLaw::addParameter (const Parameter* p)
{
  if (p == NULL)
  {
    return LIBSBML_OPERATION_FAILED;
  }
  else if (!(p->hasRequiredAttributes()) || !(p->hasRequiredElements()) 
    || p->getTypeCode() == SBML_LOCAL_PARAMETER)
  {
    /* 
     * in an attempt to make existing code work with the new localParameter
     * class this requires a further check
     */
    if (getLevel() < 3)
    {
      return LIBSBML_INVALID_OBJECT;
    }
    else
    {
      /* hack so this will deal with local parameters */
      LocalParameter *lp = new LocalParameter(*p);//->getSBMLNamespaces());

      if (!(lp->hasRequiredAttributes()) || !(lp->hasRequiredElements()))
      {
        return LIBSBML_INVALID_OBJECT;
      }
      else if (getLocalParameter(lp->getId()) != NULL)
      {
        // an parameter with this id already exists
        return LIBSBML_DUPLICATE_OBJECT_ID;
      }
      else
      {

        mLocalParameters.append(lp);

        return LIBSBML_OPERATION_SUCCESS;
      }
    }
  }
  else if (getLevel() != p->getLevel())
  {
    return LIBSBML_LEVEL_MISMATCH;
  }
  else if (getVersion() != p->getVersion())
  {
    return LIBSBML_VERSION_MISMATCH;
  }
  else if (matchesRequiredSBMLNamespacesForAddition(static_cast<const SBase *>(p)) == false)
  {
    return LIBSBML_NAMESPACES_MISMATCH;
  }
  else if (getParameter(p->getId()) != NULL)
  {
    // an parameter with this id already exists
    return LIBSBML_DUPLICATE_OBJECT_ID;
  }
  else
  {
    mParameters.append(p);

    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Adds a copy of the given LocalParameter to this KineticLaw.
 */
int
KineticLaw::addLocalParameter (const LocalParameter* p)
{
  int returnValue = checkCompatibility(static_cast<const SBase *>(p));
  if (returnValue != LIBSBML_OPERATION_SUCCESS)
  {
    return returnValue;
  }
  else if (getLocalParameter(p->getId()) != NULL)
  {
    // an parameter with this id already exists
    return LIBSBML_DUPLICATE_OBJECT_ID;
  }
  else
  {
    mLocalParameters.append(p);

    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * Creates a new Parameter, adds it to this KineticLaw's list of
 * parameters and returns it.
 */
Parameter*
KineticLaw::createParameter ()
{
  if (getLevel() < 3)
  {
    Parameter* p = NULL;
    
    try
    {
      p = new Parameter(getSBMLNamespaces());
    }
    catch (...)
    {
      /* here we do not create a default object as the level/version must
      * match the parent object
      *
      * so do nothing
      */
    }
    
    if (p) mParameters.appendAndOwn(p);

    return p;
  }
  else
  {
    LocalParameter *p = NULL;
    try
    {
      p = new LocalParameter(getSBMLNamespaces());
    }
    catch (...)
    {
      /* here we do not create a default object as the level/version must
      * match the parent object
      *
      * so do nothing
      */
    }
    
    if (p != NULL) mLocalParameters.appendAndOwn(p);

    return static_cast <Parameter *> (p);
  }
}


/*
 * Creates a new LocalParameter, adds it to this KineticLaw's list of
 * parameters and returns it.
 */
LocalParameter*
KineticLaw::createLocalParameter ()
{
  LocalParameter* p = NULL;

  try
  {
    p = new LocalParameter(getSBMLNamespaces());
  }
  catch (...)
  {
    /* here we do not create a default object as the level/version must
     * match the parent object
     *
     * so do nothing
     */
  }
  
  if (p != NULL) mLocalParameters.appendAndOwn(p);

  return p;
}


/*
 * @return the list of Parameters for this KineticLaw.
 */
const ListOfParameters*
KineticLaw::getListOfParameters () const
{
  if (getLevel() < 3)
    return &mParameters;
  else
    return static_cast <const ListOfParameters *> (&mLocalParameters);
}


/*
 * @return the list of Parameters for this KineticLaw.
 */
ListOfParameters*
KineticLaw::getListOfParameters ()
{
  if (getLevel() < 3)
    return &mParameters;
  else
    return static_cast <ListOfParameters *> (&mLocalParameters);
}


/*
 * @return the list of LocalParameters for this KineticLaw.
 */
const ListOfLocalParameters*
KineticLaw::getListOfLocalParameters () const
{
  return &mLocalParameters;
}


/*
 * @return the list of LocalParameters for this KineticLaw.
 */
ListOfLocalParameters*
KineticLaw::getListOfLocalParameters ()
{
  return &mLocalParameters;
}


/*
 * @return the nth Parameter of this KineticLaw.
 */
const Parameter*
KineticLaw::getParameter (unsigned int n) const
{
  if (getLevel() < 3)
    return static_cast<const Parameter*>( mParameters.get(n) );
  else
    return static_cast<const Parameter*>( mLocalParameters.get(n) );

}


/*
 * @return the nth Parameter of this KineticLaw.
 */
Parameter*
KineticLaw::getParameter (unsigned int n)
{
  if (getLevel() < 3)
    return static_cast<Parameter*>( mParameters.get(n) );
  else
    return static_cast<Parameter*>( mLocalParameters.get(n) );
}


/*
 * @return the nth LocalParameter of this KineticLaw.
 */
const LocalParameter*
KineticLaw::getLocalParameter (unsigned int n) const
{
  return static_cast<const LocalParameter*>( mLocalParameters.get(n) );
}


/*
 * @return the nth LocalParameter of this KineticLaw.
 */
LocalParameter*
KineticLaw::getLocalParameter (unsigned int n)
{
  return static_cast<LocalParameter*>( mLocalParameters.get(n) );
}


/*
 * @return the Parameter in this kineticLaw with the given @p id or @c NULL if
 * no such Parameter exists.
 */
const Parameter*
KineticLaw::getParameter (const std::string& sid) const
{
  if (getLevel() < 3)
    return static_cast<const Parameter*>( mParameters.get(sid) );
  else
    return static_cast<const Parameter*>( mLocalParameters.get(sid) );
}


/*
 * @return the Parameter in this kineticLaw with the given @p id or @c NULL if
 * no such Parameter exists.
 */
Parameter*
KineticLaw::getParameter (const std::string& sid)
{
  if (getLevel() < 3)
    return static_cast<Parameter*>( mParameters.get(sid) );
  else
    return static_cast<Parameter*>( mLocalParameters.get(sid) );
}


/*
 * @return the LocalParameter in this kineticLaw with the given @p id or @c NULL if
 * no such LocalParameter exists.
 */
const LocalParameter*
KineticLaw::getLocalParameter (const std::string& sid) const
{
  return static_cast<const LocalParameter*>( mLocalParameters.get(sid) );
}


/*
 * @return the LocalParameter in this kineticLaw with the given @p id or @c NULL if
 * no such LocalParameter exists.
 */
LocalParameter*
KineticLaw::getLocalParameter (const std::string& sid)
{
  return static_cast<LocalParameter*>( mLocalParameters.get(sid) );
}


/*
 * @return the number of Parameters in this KineticLaw.
 */
unsigned int
KineticLaw::getNumParameters () const
{
  if (getLevel() < 3)
    return mParameters.size();
  else
    return mLocalParameters.size();
}

/*
 * @return the number of LocalParameters in this KineticLaw.
 */
unsigned int
KineticLaw::getNumLocalParameters () const
{
  return mLocalParameters.size();
}

/*
  * Calculates and returns a UnitDefinition that expresses the units
  * returned by the math expression of this KineticLaw.
  */
UnitDefinition * 
KineticLaw::getDerivedUnitDefinition()
{
  if (!isSetMath())
    return NULL;
  /* if we have the whole model but it is not in a document
   * it is still possible to determine the units
   */
  
  /* VERY NASTY HACK THAT WILL WORK IF WE DONT KNOW ABOUT COMP
   * but will identify if the parent model is a ModelDefinition
   */
  Model * m = NULL;
  
  if (this->isPackageEnabled("comp"))
  {
    m = static_cast <Model *> (getAncestorOfType(251, "comp"));
  }

  if (m == NULL)
  {
    m = static_cast <Model *> (getAncestorOfType(SBML_MODEL));
  }

  /* we should have a model by this point 
   * OR the object is not yet a child of a model
   */

  if (m != NULL)
  {
    if (!m->isPopulatedListFormulaUnitsData())
    {
      m->populateListFormulaUnitsData();
    }
    
    if (m->getFormulaUnitsData(getInternalId(), getTypeCode()) != NULL)
    {
      return m->getFormulaUnitsData(getInternalId(), getTypeCode())
                                             ->getUnitDefinition();
    }
    else
    {
      return NULL;
    }  
  }
  else
  {
    return NULL;
  }
}


/*
  * Constructs and returns a UnitDefinition that expresses the units of this 
  * Compartment.
  */
const UnitDefinition *
KineticLaw::getDerivedUnitDefinition() const
{
  return const_cast <KineticLaw *> (this)->getDerivedUnitDefinition();
}


/*
 * Predicate returning @c true if 
 * the math expression of this KineticLaw contains
 * parameters/numbers with undeclared units that cannot be ignored.
 */
bool 
KineticLaw::containsUndeclaredUnits()
{
  if (!isSetMath())
    return false;
  /* if we have the whole model but it is not in a document
   * it is still possible to determine the units
   */
  
  /* VERY NASTY HACK THAT WILL WORK IF WE DONT KNOW ABOUT COMP
   * but will identify if the parent model is a ModelDefinition
   */
  Model * m = NULL;
  
  if (this->isPackageEnabled("comp"))
  {
    m = static_cast <Model *> (getAncestorOfType(251, "comp"));
  }

  if (m == NULL)
  {
    m = static_cast <Model *> (getAncestorOfType(SBML_MODEL));
  }

  /* we should have a model by this point 
   * OR the object is not yet a child of a model
   */


  if (m != NULL)
  {
    if (!m->isPopulatedListFormulaUnitsData())
    {
      m->populateListFormulaUnitsData();
    }
    
    if (m->getFormulaUnitsData(getInternalId(), getTypeCode()) != NULL)
    {
      return m->getFormulaUnitsData(getInternalId(), getTypeCode())
      ->getContainsUndeclaredUnits();
    }
    else
    {
      return false;
    }  
  }
  else
  {
    return false;
  }
}


bool 
KineticLaw::containsUndeclaredUnits() const
{
  return const_cast<KineticLaw *> (this)->containsUndeclaredUnits();
}

/**
 * Removes the nth Parameter object in the list of local parameters 
 * in this KineticLaw instance.
 */
Parameter* 
KineticLaw::removeParameter (unsigned int n)
{
  return mParameters.remove(n);  
}


/**
 * Removes the nth LocalParameter object in the list of local parameters 
 * in this KineticLaw instance.
 */
LocalParameter* 
KineticLaw::removeLocalParameter (unsigned int n)
{
  return mLocalParameters.remove(n);  
}


/**
 * Removes a Parameter object with the given identifier in the list of
 * local parameters in this KineticLaw instance.
 */
Parameter* 
KineticLaw::removeParameter (const std::string& sid)
{
  return (&sid != NULL) ? mParameters.remove(sid) : NULL;
}


/**
 * Removes a LocalParameter object with the given identifier in the list of
 * local parameters in this KineticLaw instance.
 */
LocalParameter* 
KineticLaw::removeLocalParameter (const std::string& sid)
{
  return (&sid != NULL) ? mLocalParameters.remove(sid) : NULL;
}


/** @cond doxygenLibsbmlInternal */

/*
 * Sets the parent SBMLDocument of this SBML object.
 */
void
KineticLaw::setSBMLDocument (SBMLDocument* d)
{
  SBase::setSBMLDocument(d);

  if (getLevel() < 3)
  {
  mParameters.setSBMLDocument(d);
  }
  else
  {
  mLocalParameters.setSBMLDocument(d);
  }
}


/*
 * Sets this SBML object to child SBML objects (if any).
 * (Creates a child-parent relationship by the parent)
  */
void
KineticLaw::connectToChild()
{
  SBase::connectToChild();
  mParameters.connectToParent(this);
  mLocalParameters.connectToParent(this);
}


/**
 * Enables/Disables the given package with this element and child
 * elements (if any).
 * (This is an internal implementation for enablePackage function)
 */
void 
KineticLaw::enablePackageInternal(const std::string& pkgURI, 
                                  const std::string& pkgPrefix, bool flag)
{
  SBase::enablePackageInternal(pkgURI,pkgPrefix,flag);

  if (getLevel() < 3)
  {
    mParameters.enablePackageInternal(pkgURI,pkgPrefix,flag);
  }
  else
  {
    mLocalParameters.enablePackageInternal(pkgURI,pkgPrefix,flag);
  }
}

/** @endcond */

/*
 * @return the typecode (int) of this SBML object or SBML_UNKNOWN
 * (default).
 *
 * @see getElementName()
 */
int
KineticLaw::getTypeCode () const
{
  return SBML_KINETIC_LAW;
}


/*
 * @return the name of this element ie "kineticLaw".
 */
const string&
KineticLaw::getElementName () const
{
  static const string name = "kineticLaw";
  return name;
}


bool 
KineticLaw::hasRequiredAttributes() const
{
  bool allPresent = true;

  /* required attributes for kineticLaw: formula (L1 only) */

  if (getLevel() == 1 && !isSetFormula())
    allPresent = false;

  return allPresent;
}


bool 
KineticLaw::hasRequiredElements() const
{
  bool allPresent = true;

  /* required attributes for kineticlaw: math */

  if (!isSetMath())
    allPresent = false;

  return allPresent;
}

int KineticLaw::removeFromParentAndDelete()
{
  if (mHasBeenDeleted) return LIBSBML_OPERATION_SUCCESS;
  SBase* parent = getParentSBMLObject();
  if (parent==NULL) return LIBSBML_OPERATION_FAILED;
  Reaction* parentReaction = static_cast<Reaction*>(parent);
  if (parentReaction== NULL) return LIBSBML_OPERATION_FAILED;
  return parentReaction->unsetKineticLaw();
}


void
KineticLaw::renameSIdRefs(const std::string& oldid, const std::string& newid)
{
  //If the oldid is actually a local parameter, we should not rename it.
  if (getParameter(oldid) != NULL) return;
  if (getLocalParameter(oldid) != NULL) return;
  if (isSetMath()) {
    mMath->renameSIdRefs(oldid, newid);
  }
}

void 
KineticLaw::renameUnitSIdRefs(const std::string& oldid, const std::string& newid)
{
  if (isSetMath()) {
    mMath->renameUnitSIdRefs(oldid, newid);
  }
  if (mTimeUnits == oldid) mTimeUnits = newid;
  if (mSubstanceUnits == oldid) mSubstanceUnits = newid;
}

/** @cond doxygenLibsbmlInternal */
void 
KineticLaw::replaceSIDWithFunction(const std::string& id, const ASTNode* function)
{
  if (isSetMath()) {
    if (mMath->getType() == AST_NAME && mMath->getId() == id) {
      delete mMath;
      mMath = function->deepCopy();
    }
    else {
      mMath->replaceIDWithFunction(id, function);
    }
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void 
KineticLaw::divideAssignmentsToSIdByFunction(const std::string& id, const ASTNode* function)
{
  SBase* parentrxn = getParentSBMLObject();
  if (parentrxn==NULL) return;
  if (parentrxn->getId() == id && isSetMath()) {
    ASTNode* temp = mMath;
    mMath = new ASTNode(AST_DIVIDE);
    mMath->addChild(temp);
    mMath->addChild(function->deepCopy());
  }
}
/** @endcond */

/** @cond doxygenLibsbmlInternal */
void 
KineticLaw::multiplyAssignmentsToSIdByFunction(const std::string& id, const ASTNode* function)
{
  SBase* parentrxn = getParentSBMLObject();
  if (parentrxn==NULL) return;
  if (parentrxn->getId() == id && isSetMath()) {
    ASTNode* temp = mMath;
    mMath = new ASTNode(AST_TIMES);
    mMath->addChild(temp);
    mMath->addChild(function->deepCopy());
  }
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return the ordinal position of the element with respect to its siblings
 * or -1 (default) to indicate the position is not significant.
 */
int
KineticLaw::getElementPosition () const
{
  return 4;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write out their contained
 * SBML objects as XML elements.  Be sure to call your parents
 * implementation of this method as well.
 */
void
KineticLaw::writeElements (XMLOutputStream& stream) const
{
  SBase::writeElements(stream);

  if ( getLevel() > 1 && isSetMath() ) writeMathML(getMath(), stream, getSBMLNamespaces());
  if ( getLevel() < 3 && getNumParameters() > 0 ) mParameters.write(stream);
  if ( getLevel() > 2 && getNumLocalParameters() > 0 ) 
    mLocalParameters.write(stream);

  //
  // (EXTENSION)
  //
  SBase::writeExtensionElements(stream);
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * @return the SBML object corresponding to next XMLToken in the
 * XMLInputStream or @c NULL if the token was not recognized.
 */
SBase*
KineticLaw::createObject (XMLInputStream& stream)
{
  SBase* object = NULL;

  const string& name = stream.peek().getName();

  if (name == "listOfParameters")
  {
    if (mParameters.size() != 0)
    {
      logError(NotSchemaConformant, getLevel(), getVersion(),
	       "Only one <listOfParameters> elements is permitted "
	       "in a given <kineticLaw> element.");
    }
    object = &mParameters;
  }
  else if (name == "listOfLocalParameters" && getLevel() > 2)
  {
    if (mLocalParameters.size() != 0)
    {
      logError(OneListOfPerKineticLaw, getLevel(), getVersion());
    }
    object = &mLocalParameters;
  }

  return object;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read (and store) XHTML,
 * MathML, etc. directly from the XMLInputStream.
 *
 * @return true if the subclass read from the stream, false otherwise.
 */
bool
KineticLaw::readOtherXML (XMLInputStream& stream)
{
  bool          read = false;
  const string& name = stream.peek().getName();

  if (name == "math")
  {
    // if this is level 1 there shouldnt be any math!!!
    if (getLevel() == 1) 
    {
      logError(NotSchemaConformant, getLevel(), getVersion(),
	       "SBML Level 1 does not support MathML.");
      delete mMath;
      return false;
    }
    if (mMath != NULL)
    {
      if (getLevel() < 3) 
      {
        logError(NotSchemaConformant, getLevel(), getVersion(),
	        "Only one <math> element is permitted inside a "
	        "particular containing element.");
      }
      else
      {
        logError(OneMathPerKineticLaw, getLevel(), getVersion());
      }
    }

    if (getNumParameters() > 0 && getLevel() < 3) 
      logError(IncorrectOrderInKineticLaw);

    /* check for MathML namespace 
     * this may be explicitly declared here
     * or implicitly declared on the whole document
     */
    const XMLToken elem = stream.peek();
    const std::string prefix = checkMathMLNamespace(elem);

    // the following assumes that the SBML Namespaces object is valid
    if (stream.getSBMLNamespaces() == NULL)
    {
      stream.setSBMLNamespaces(new SBMLNamespaces(getLevel(), getVersion()));
    }

    delete mMath;
    mMath = readMathML(stream, prefix);
    if (mMath != NULL) mMath->setParentSBMLObject(this);
    read  = true;
  }

  /* ------------------------------
   *
   *   (EXTENSION)
   *
   * ------------------------------ */
  if ( SBase::readOtherXML(stream) )
    read = true;

  return read;
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/**
 * Subclasses should override this method to get the list of
 * expected attributes.
 * This function is invoked from corresponding readAttributes()
 * function.
 */
void
KineticLaw::addExpectedAttributes(ExpectedAttributes& attributes)
{
  SBase::addExpectedAttributes(attributes);

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  switch (level)
  {
  case 1:
    attributes.add("formula");
    attributes.add("timeUnits");
    attributes.add("substanceUnits");
    break;
  case 2:
    if (version == 1)
    {
      attributes.add("timeUnits");
      attributes.add("substanceUnits");
    }
    if (version == 2)
    {
      attributes.add("sboTerm");
    }
    break;
  case 3:
  default:
    break;
  }
}

/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
KineticLaw::readAttributes (const XMLAttributes& attributes,
                            const ExpectedAttributes& expectedAttributes)
{
  const unsigned int level   = getLevel  ();

  SBase::readAttributes(attributes, expectedAttributes);

  switch (level)
  {
  case 1:
    readL1Attributes(attributes);
    break;
  case 2:
    readL2Attributes(attributes);
    break;
  case 3:
  default:
    readL3Attributes(attributes);
    break;
  }
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
KineticLaw::readL1Attributes (const XMLAttributes& attributes)
{
  //
  // formula: string  { use="required" }  (L1v1->)
  //
  attributes.readInto("formula", mFormula, getErrorLog(), true, getLine(), getColumn());

  //
  // timeUnits  { use="optional" }  (L1v1, L1v2, L2v1, L2v2)
  //
  attributes.readInto("timeUnits", mTimeUnits, getErrorLog(), false, getLine(), getColumn());

  //
  // substanceUnits  { use="optional" }  (L1v1, L1v2, L2v1, L2v2)
  //
  attributes.readInto("substanceUnits", mSubstanceUnits, getErrorLog(), false, getLine(), getColumn());

}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
KineticLaw::readL2Attributes (const XMLAttributes& attributes)
{
  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  if (version == 1)
  {
    //
    // timeUnits  { use="optional" }  (L1v1, L1v2, L2v1)
    //
    attributes.readInto("timeUnits", mTimeUnits, getErrorLog(), false, getLine(), getColumn());

    //
    // substanceUnits  { use="optional" }  (L1v1, L1v2, L2v1)
    //
    attributes.readInto("substanceUnits", mSubstanceUnits, getErrorLog(), false, getLine(), getColumn());
  }

  //
  // sboTerm: SBOTerm { use="optional" }  (L2v2 ->)
  //
  if (version == 2) 
    mSBOTerm = SBO::readTerm(attributes, this->getErrorLog(), level, version,
				getLine(), getColumn());
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to read values from the given
 * XMLAttributes set into their specific fields.  Be sure to call your
 * parents implementation of this method as well.
 */
void
KineticLaw::readL3Attributes (const XMLAttributes& attributes)
{
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
 * Subclasses should override this method to write their XML attributes
 * to the XMLOutputStream.  Be sure to call your parents implementation
 * of this method as well.
 */
void
KineticLaw::writeAttributes (XMLOutputStream& stream) const
{
  SBase::writeAttributes(stream);

  const unsigned int level   = getLevel  ();
  const unsigned int version = getVersion();

  //
  // formula: string  { use="required" }  (L1v1, L1v2)
  //
  if (level == 1) 
  {
    //
    // formula: string  { use="required" }  (L1v1, L1v2)
    //
    stream.writeAttribute("formula", getFormula());

    //
    // timeUnits  { use="optional" }  (L1v1, L1v2, L2v1)
    // removed in l2v2
    //
    stream.writeAttribute("timeUnits", mTimeUnits);

    //
    // substanceUnits  { use="optional" }  (L1v1, L1v2, L2v1)
    // removed in l2v2
    //
    stream.writeAttribute("substanceUnits", mSubstanceUnits);
  }
  else
  {
    //
    // sboTerm: SBOTerm { use="optional" }  (L2v2 ->)
    //
    // sboTerm for L2V3 or later is written in SBase::writeAttributes()
    //
    if ( (level == 2) && (version == 2) )
    {
      SBO::writeTerm(stream, mSBOTerm);
    }

    if (level == 2 && version == 1)
    {
      //
      // timeUnits  { use="optional" }  (L1v1, L1v2, L2v1)
      // removed in l2v2
      //
      stream.writeAttribute("timeUnits", mTimeUnits);

      //
      // substanceUnits  { use="optional" }  (L1v1, L1v2, L2v1)
      // removed in l2v2
      //
      stream.writeAttribute("substanceUnits", mSubstanceUnits);
    }
  }

  //
  // (EXTENSION)
  //
  SBase::writeExtensionAttributes(stream);
}
/** @endcond */


#endif /* __cplusplus */
/** @cond doxygenIgnored */


LIBSBML_EXTERN
KineticLaw_t *
KineticLaw_create (unsigned int level, unsigned int version)
{
  try
  {
    KineticLaw* obj = new KineticLaw(level,version);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
KineticLaw_t *
KineticLaw_createWithNS (SBMLNamespaces_t* sbmlns)
{
  try
  {
    KineticLaw* obj = new KineticLaw(sbmlns);
    return obj;
  }
  catch (SBMLConstructorException)
  {
    return NULL;
  }
}


LIBSBML_EXTERN
void
KineticLaw_free (KineticLaw_t *kl)
{
  if (kl != NULL)
  delete kl;
}


LIBSBML_EXTERN
KineticLaw_t *
KineticLaw_clone (const KineticLaw_t *kl)
{
  return (kl != NULL) ? kl->clone() : NULL;
}


LIBSBML_EXTERN
const XMLNamespaces_t *
KineticLaw_getNamespaces(KineticLaw_t *kl)
{
  return (kl != NULL) ? kl->getNamespaces() : NULL;
}

LIBSBML_EXTERN
const char *
KineticLaw_getFormula (const KineticLaw_t *kl)
{
  return (kl != NULL && kl->isSetFormula()) ? kl->getFormula().c_str() : NULL;
}


LIBSBML_EXTERN
const ASTNode_t *
KineticLaw_getMath (const KineticLaw_t *kl)
{
  return (kl != NULL) ? kl->getMath() : NULL;
}


LIBSBML_EXTERN
const char *
KineticLaw_getTimeUnits (const KineticLaw_t *kl)
{
  return (kl != NULL && kl->isSetTimeUnits()) ? 
                        kl->getTimeUnits().c_str() : NULL;
}


LIBSBML_EXTERN
const char *
KineticLaw_getSubstanceUnits (const KineticLaw_t *kl)
{
  return (kl != NULL && kl->isSetSubstanceUnits()) ? 
                        kl->getSubstanceUnits().c_str() : NULL;
}


LIBSBML_EXTERN
int
KineticLaw_isSetFormula (const KineticLaw_t *kl)
{
  return (kl != NULL) ? static_cast<int>( kl->isSetFormula() ) : 0;
}


LIBSBML_EXTERN
int
KineticLaw_isSetMath (const KineticLaw_t *kl)
{
  return (kl != NULL) ? static_cast<int>( kl->isSetMath() ) : 0;
}


LIBSBML_EXTERN
int
KineticLaw_isSetTimeUnits (const KineticLaw_t *kl)
{
  return (kl != NULL) ? static_cast<int>( kl->isSetTimeUnits() ) : 0;
}


LIBSBML_EXTERN
int
KineticLaw_isSetSubstanceUnits (const KineticLaw_t *kl)
{
  return (kl != NULL) ? static_cast<int>( kl->isSetSubstanceUnits() ) : 0;
}


LIBSBML_EXTERN
int
KineticLaw_setFormula (KineticLaw_t *kl, const char *formula)
{
  if (kl != NULL)
    return kl->setFormula((formula != NULL) ? formula : "");
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
KineticLaw_setMath (KineticLaw_t *kl, const ASTNode_t *math)
{
  if (kl != NULL)
    return kl->setMath(math);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
KineticLaw_setTimeUnits (KineticLaw_t *kl, const char *sid)
{
  if (kl != NULL)
    return (sid == NULL) ? kl->unsetTimeUnits() : kl->setTimeUnits(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
KineticLaw_setSubstanceUnits (KineticLaw_t *kl, const char *sid)
{
  if (kl != NULL)
    return (sid == NULL) ? 
            kl->unsetSubstanceUnits() : kl->setSubstanceUnits(sid);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
KineticLaw_unsetTimeUnits (KineticLaw_t *kl)
{
  if (kl != NULL)
    return kl->unsetTimeUnits();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
KineticLaw_unsetSubstanceUnits (KineticLaw_t *kl)
{
  if (kl != NULL)
    return kl->unsetSubstanceUnits();
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
KineticLaw_addParameter (KineticLaw_t *kl, const Parameter_t *p)
{
  if (kl != NULL)
    return kl->addParameter(p);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
int
KineticLaw_addLocalParameter (KineticLaw_t *kl, const LocalParameter_t *p)
{
  if (kl != NULL)
    return kl->addLocalParameter(p);
  else
    return LIBSBML_INVALID_OBJECT;
}


LIBSBML_EXTERN
Parameter_t *
KineticLaw_createParameter (KineticLaw_t *kl)
{
  return (kl != NULL) ? kl->createParameter() : NULL;
}


LIBSBML_EXTERN
LocalParameter_t *
KineticLaw_createLocalParameter (KineticLaw_t *kl)
{
  return (kl != NULL) ? kl->createLocalParameter() : NULL;
}


LIBSBML_EXTERN
ListOf_t *
KineticLaw_getListOfParameters (KineticLaw_t *kl)
{
  return (kl != NULL) ? kl->getListOfParameters() : NULL;
}


LIBSBML_EXTERN
ListOf_t *
KineticLaw_getListOfLocalParameters (KineticLaw_t *kl)
{
  return (kl != NULL) ? kl->getListOfLocalParameters() : 0;
}


LIBSBML_EXTERN
Parameter_t *
KineticLaw_getParameter (KineticLaw_t *kl, unsigned int n)
{
  return (kl != NULL) ? kl->getParameter(n) : NULL;
}


LIBSBML_EXTERN
LocalParameter_t *
KineticLaw_getLocalParameter (KineticLaw_t *kl, unsigned int n)
{
  return (kl != NULL) ? kl->getLocalParameter(n) : NULL;
}


LIBSBML_EXTERN
Parameter_t *
KineticLaw_getParameterById (KineticLaw_t *kl, const char *sid)
{
  return (kl != NULL && sid != NULL) ? kl->getParameter(sid) : NULL;
}


LIBSBML_EXTERN
LocalParameter_t *
KineticLaw_getLocalParameterById (KineticLaw_t *kl, const char *sid)
{
  return (kl != NULL && sid != NULL) ? kl->getLocalParameter(sid) : NULL;
}


LIBSBML_EXTERN
unsigned int
KineticLaw_getNumParameters (const KineticLaw_t *kl)
{
  return (kl != NULL) ? kl->getNumParameters() : SBML_INT_MAX;
}


LIBSBML_EXTERN
unsigned int
KineticLaw_getNumLocalParameters (const KineticLaw_t *kl)
{
  return (kl != NULL) ? kl->getNumLocalParameters() : SBML_INT_MAX;
}

LIBSBML_EXTERN
UnitDefinition_t * 
KineticLaw_getDerivedUnitDefinition(KineticLaw_t *kl)
{
  return (kl != NULL) ? kl->getDerivedUnitDefinition() : NULL;
}


LIBSBML_EXTERN
int 
KineticLaw_containsUndeclaredUnits(KineticLaw_t *kl)
{
  return (kl != NULL) ? static_cast<int>(kl->containsUndeclaredUnits()) : 0;
}


LIBSBML_EXTERN
Parameter_t *
KineticLaw_removeParameter (KineticLaw_t *kl, unsigned int n)
{
  return (kl != NULL) ? kl->removeParameter(n) : NULL;
}


LIBSBML_EXTERN
LocalParameter_t *
KineticLaw_removeLocalParameter (KineticLaw_t *kl, unsigned int n)
{
  return (kl != NULL) ? kl->removeLocalParameter(n) : NULL;
}


LIBSBML_EXTERN
Parameter_t *
KineticLaw_removeParameterById (KineticLaw_t *kl, const char *sid)
{
  if (kl != NULL)
    return sid != NULL ? kl->removeParameter(sid) : NULL;
  else
    return NULL;
}


LIBSBML_EXTERN
LocalParameter_t *
KineticLaw_removeLocalParameterById (KineticLaw_t *kl, const char *sid)
{
  if (kl != NULL)
    return sid != NULL ? kl->removeLocalParameter(sid) : NULL;
  else
    return NULL;
}


/** @endcond */

LIBSBML_CPP_NAMESPACE_END


