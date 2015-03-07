/** 
 *@cond doxygenLibsbmlInternal 
 **
 *
 * @file    FormulaUnitsData.h
 * @brief   Class for storing information relating to units of a formula
 * @author  SBML Team <sbml-team@caltech.edu>
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 *
 * @class FormulaUnitsData
 * @sbmlbrief{core} Object for recording the units associated with objects
 * and math expressions.
 * 
 * @htmlinclude not-sbml-warning.html
 *
 * A FormulaUnitsData object records information about the units of the
 * SBML object associated with it.
 *
 * A FormulaUnitsData object has several elements:
 *
 * unitReferenceId - a string; which is the identifier from the object used 
 * to create the FormulaUnitsData, or a constructed identifer in the case 
 * where the originating object has no identifier e.g. a KineticLaw.
 *
 * mTypeOfElement - an SBMLTypeCode_t; the typecode of the object used to
 * create the FormulaUnitsData.
 *
 * mUnitDefinition - a UnitDefinition object; which is constructed to 
 * represent the units of the originating object.
 *
 * mPerTimeUnitDefinition - a UnitDefinition object; which is constructed
 * to represent the units of the originating object divided by the
 * appropriate time units.
 *
 * mEventTimeUnitDefinition - a UnitDefinition object; which is constructed
 * to represent the time units for the originating Event.
 *
 * @note Since the unitReferenceIds across the list of FormulaUnitsData 
 * objects defining the units of an entire model need not be unique, 
 * the SBMLTypeCode_t is necessary to retrieve specific FormulaUnitsData
 * objects from the list.
 */

#ifndef FormulaUnitsData_h
#define FormulaUnitsData_h


#ifdef __cplusplus
#include <sbml/SBase.h>

#include <sbml/util/List.h>
#include <sbml/ListOf.h>
#include <sbml/UnitDefinition.h>
#include <sbml/Model.h>
#include <sbml/SBMLTypeCodes.h>

#include <sbml/math/FormulaFormatter.h>

#include <sbml/units/UnitFormulaFormatter.h>


LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN FormulaUnitsData 
{
public:
   
  /**
   * Creates a new FormulaUnitsData.
   */
  FormulaUnitsData();


  /**
   * Copy constructor; creates a copy of this FormulaUnitsData.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  FormulaUnitsData(const FormulaUnitsData& orig);


  /**
   * Assignment operator for FormulaUnitsData.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  FormulaUnitsData& operator=(const FormulaUnitsData& rhs);


  /**
   * Destroys this FormulaUnitsData.
   */
  virtual ~FormulaUnitsData();
 

  /**
   * Creates and returns a deep copy of this FormulaUnitsData object.
   *
   * @return the (deep) copy of this FormulaUnitsData object.
   */
  virtual FormulaUnitsData* clone () const;
  
  
  /**
   * Get the unitReferenceId of this FormulaUnitsData.
   * 
   * @return the value of the unitReferenceId of this 
   * FormulaUnitsData as a string.
   */
  const std::string& getUnitReferenceId();


  /**
   * Get the unitReferenceId of this FormulaUnitsData.
   * 
   * @return the value of the unitReferenceId of this 
   * FormulaUnitsData as a string.
   */
  const std::string& getUnitReferenceId() const;
 

  /**
   * Get the SBMLTypecode of this FormulaUnitsData.
   * This will be the typecode of the SBML component used to populate
   * this FormulaUnitsData eg SBML_SPECIES or SBML_ASSIGNMENT_RULE.
   * 
   * @return the value of the SBMLTypeCode_t of this 
   * FormulaUnitsData.
   */
  int getComponentTypecode();


  /**
   * Get the SBMLTypecode of this FormulaUnitsData.
   * This will be the typecode of the SBML component used to populate
   * this FormulaUnitsData eg SBML_SPECIES or SBML_ASSIGNMENT_RULE.
   * 
   * @return the value of the SBMLTypeCode_t of this 
   * FormulaUnitsData.
   */
  int getComponentTypecode() const;


  /**
   * Get the value of the "containsUndeclaredUnits" flag for this 
   * FormulaUnitsData.
   * 
   * @return @c true if the FormulaUnitsData includes parameters/numbers 
   * with undeclared units, @c false otherwise.
   */
  bool getContainsUndeclaredUnits(); 


  /**
   * Get the value of the "containsUndeclaredUnits" flag for this 
   * FormulaUnitsData.
   * 
   * @return @c true if the FormulaUnitsData includes parameters/numbers 
   * with undeclared units, @c false otherwise.
   */
  bool getContainsUndeclaredUnits() const;


  /**
   * Get the value of the "canIgnoreUndeclaredUnits" flag for this 
   * FormulaUnitsData.
   *
   * On occasion it is possible to "ignore" undeclared units when
   * determining the overall units of an expression.
   * For example, if p has known units and k does not then the units 
   * resulting from the expression 'p + k' must have the units of p and
   * thus it is possible to "ignore" the fact that the units of k are
   * unknown. However, it is not possible to "ignore" the unknown units
   * in the expression 'p * k' as the units of k will impact on the
   * units resulting from the expression.
   * 
   * @return @c true if the parameters/numbers 
   * with undeclared units can be ignored, @c false otherwise.
   */
  bool getCanIgnoreUndeclaredUnits();


  /**
   * Get the value of the "canIgnoreUndeclaredUnits" flag for this 
   * FormulaUnitsData.
   *
   * On occasion it is possible to "ignore" undeclared units when
   * determining the overall units of an expression.
   * For example, if p has known units and k does not then the units 
   * resulting from the expression 'p + k' must have the units of p and
   * thus it is possible to "ignore" the fact that the units of k are
   * unknown. However, it is not possible to "ignore" the unknown units
   * in the expression 'p * k' as the units of k will impact on the
   * units resulting from the expression.
   * 
   * @return @c true if the parameters/numbers 
   * with undeclared units can be ignored, @c false otherwise.
   */
  bool getCanIgnoreUndeclaredUnits() const;


  /**
   * Get the unit definition for this FormulaUnitsData.
   * 
   * @return the UnitDefinition object of this FormulaUnitsData.
   *
   * @note the UnitDefinition object is constructed to represent
   * the units associated with the component used to populate 
   * this FormulaUnitsData object.
   */
  UnitDefinition * getUnitDefinition();


  /**
   * Get the unit definition for this FormulaUnitsData.
   * 
   * @return the UnitDefinition object of this FormulaUnitsData.
   *
   * @note the UnitDefinition object is constructed to represent
   * the units associated with the component used to populate 
   * this FormulaUnitsData object.
   */
  const UnitDefinition * getUnitDefinition() const;


  /**
   * Get the 'perTime' unit definition for this FormulaUnitsData.
   * 
   * @return the 'perTime' UnitDefinition object of this FormulaUnitsData.
   *
   * @note the perTime UnitDefinition object is constructed to represent
   * the units associated with the component used to populate 
   * this FormulaUnitsData object divided by the time units for the model.
   */
  UnitDefinition * getPerTimeUnitDefinition();

  
  /**
   * Get the 'perTime' unit definition for this FormulaUnitsData.
   * 
   * @return the 'perTime' UnitDefinition object of this FormulaUnitsData.
   *
   * @note the perTime UnitDefinition object is constructed to represent
   * the units associated with the component used to populate 
   * this FormulaUnitsData object divided by the time units for the model.
   */
  const UnitDefinition * getPerTimeUnitDefinition() const;


  /**
   * Get the 'EventTime' unit definition for this FormulaUnitsData.
   * 
   * @return the 'EventTime' UnitDefinition object of this FormulaUnitsData.
   *
   * @note the EventTime UnitDefinition object is constructed to represent
   * the time units associated with the Event used to populate 
   * this FormulaUnitsData object.
   */
  UnitDefinition * getEventTimeUnitDefinition();


  /**
   * Get the 'EventTime' unit definition for this FormulaUnitsData.
   * 
   * @return the 'EventTime' UnitDefinition object of this FormulaUnitsData.
   *
   * @note the EventTime UnitDefinition object is constructed to represent
   * the time units associated with the Event used to populate 
   * this FormulaUnitsData object.
   */
  const UnitDefinition * getEventTimeUnitDefinition() const;

  const UnitDefinition * getSpeciesExtentUnitDefinition() const;
  UnitDefinition * getSpeciesExtentUnitDefinition();
  const UnitDefinition * getSpeciesSubstanceUnitDefinition() const;
  UnitDefinition * getSpeciesSubstanceUnitDefinition();

  /**
   * Sets the unitReferenceId attribute of this FormulaUnitsData.
   *
   * @param unitReferenceId the identifier of the object defined
   * elsewhere in this Model for which this FormulaUnitsData contains
   * unit information.
   */
  void setUnitReferenceId(const std::string& unitReferenceId);

    
  /**
   * Sets the SBMLTypecode of this FormulaUnitsData.
   * 
   * @param typecode the SBMLTypeCode_t of the object defined
   * elsewhere in this Model for which this FormulaUnitsData contains
   * unit information.
   */
  void setComponentTypecode(int typecode);


  /**
   * Sets the value of the "containsUndeclaredUnits" flag for this 
   * FormulaUnitsData.
   * 
   * @param flag boolean value indicating whether the FormulaUnitsData 
   * includes parameters/numbers with undeclared units.
   */
  void setContainsParametersWithUndeclaredUnits(bool flag);


  /**
   * Sets the value of the "canIgnoreUndeclaredUnits" flag for this 
   * FormulaUnitsData.
   * 
   * @param flag boolean value indicating whether parameters/numbers 
   * with undeclared units can be ignored.
   */
  void setCanIgnoreUndeclaredUnits(bool flag);


  /**
   * Set the unit definition for this FormulaUnitsData.
   * 
   * @param ud the UnitDefinition object constructed to represent
   * the units associated with the component used to populate 
   * this FormulaUnitsData object.
   */
  void setUnitDefinition(UnitDefinition * ud);


  /**
   * Set the 'perTime' unit definition for this FormulaUnitsData.
   * 
   * @param ud the UnitDefinition object constructed to represent
   * the units associated with the component used to populate 
   * this FormulaUnitsData object divided by the time units for the model.
   */
  void setPerTimeUnitDefinition(UnitDefinition * ud);


  /**
   * Set the 'EventTime' unit definition for this FormulaUnitsData.
   * 
   * @param ud the UnitDefinition object constructed to represent
   * the time units associated with the Event used to populate 
   * this FormulaUnitsData object.
   */
  void setEventTimeUnitDefinition(UnitDefinition * ud);

  void setSpeciesExtentUnitDefinition(UnitDefinition * ud);
  void setSpeciesSubstanceUnitDefinition(UnitDefinition * ud);

protected:
  /** @cond doxygenLibsbmlInternal */

    std::string mUnitReferenceId;

    bool mContainsUndeclaredUnits;
    bool mCanIgnoreUndeclaredUnits;

    int mTypeOfElement;

    UnitDefinition * mUnitDefinition;
    UnitDefinition * mPerTimeUnitDefinition;
    UnitDefinition * mEventTimeUnitDefinition;
    UnitDefinition * mSpeciesExtentUnitDefinition;
    UnitDefinition * mSpeciesSubstanceUnitDefinition;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

/* NOT YET NECESSARY 
#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

LIBSBML_EXTERN
FormulaUnitsData_t* 
FormulaUnitsData_create();

LIBSBML_EXTERN
const char* 
FormulaUnitsData_getUnitReferenceId(FormulaUnitsData_t* fud);

LIBSBML_EXTERN
SBMLTypeCode_t 
FormulaUnitsData_getComponentTypecode(FormulaUnitsData_t* fud);

LIBSBML_EXTERN
int 
FormulaUnitsData_getContainsUndeclaredUnits(FormulaUnitsData_t* fud);

LIBSBML_EXTERN
int 
FormulaUnitsData_getCanIgnoreUndeclaredUnits(FormulaUnitsData_t* fud);

LIBSBML_EXTERN
UnitDefinition_t * 
FormulaUnitsData_getUnitDefinition(FormulaUnitsData_t* fud);

LIBSBML_EXTERN
UnitDefinition_t * 
FormulaUnitsData_getPerTimeUnitDefinition(FormulaUnitsData_t* fud);

LIBSBML_EXTERN
UnitDefinition_t * 
FormulaUnitsData_getEventTimeUnitDefinition(FormulaUnitsData_t* fud);

LIBSBML_EXTERN
void 
FormulaUnitsData_setUnitReferenceId(FormulaUnitsData_t* fud, const char* id);

LIBSBML_EXTERN
void 
FormulaUnitsData_setComponentTypecode(FormulaUnitsData_t* fud, 
                                      SBMLTypeCode_t typecode);

LIBSBML_EXTERN
void 
FormulaUnitsData_setContainsUndeclaredUnits(FormulaUnitsData_t* fud, 
                                            int flag);

LIBSBML_EXTERN
void 
FormulaUnitsData_setCanIgnoreUndeclaredUnits(FormulaUnitsData_t* fud, 
                                             int flag);

LIBSBML_EXTERN
void 
FormulaUnitsData_setUnitDefinition(FormulaUnitsData_t* fud,
                                   UnitDefinition_t* ud);

LIBSBML_EXTERN
void 
FormulaUnitsData_setPerTimeUnitDefinition(FormulaUnitsData_t* fud,
                                   UnitDefinition_t* ud);

LIBSBML_EXTERN
void 
FormulaUnitsData_setEventTimeUnitDefinition(FormulaUnitsData_t* fud,
                                   UnitDefinition_t* ud);

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif   !SWIG   */


#endif //FormulaUnitsData_h

/** @endcond */


