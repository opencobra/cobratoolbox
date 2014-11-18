/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    SBMLTransforms.h
 * @brief   Transform functions
 * @author  Sarah Keating
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
 * @class SBMLTransforms
 * @sbmlbrief{core} Methods for transform elements of SBML
 *
 */

#ifndef SBMLTransforms_h
#define SBMLTransforms_h


#include <sbml/common/extern.h>
#include <sbml/SBase.h>
#include <sbml/util/util.h>
#include <sbml/math/ASTNode.h>
#include <sbml/FunctionDefinition.h>
#include <sbml/InitialAssignment.h>
#ifndef LIBSBML_USE_STRICT_INCLUDES
#include <sbml/SBMLTypes.h>
#endif
#include <sbml/SpeciesReference.h>

#ifdef __cplusplus


#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

class IdList;

#ifdef LIBSBML_USE_STRICT_INCLUDES
class ASTNode;
class FunctionDefinition;
class InitialAssignment;
class Model;
class Species;
class SpeciesReference;
class Compartment;
class Parameter;
#endif 

class LIBSBML_EXTERN SBMLTransforms
{
public:

#ifndef SWIG
  typedef std::pair<double, bool>   ValueSet;
  typedef std::map<const std::string, ValueSet> IdValueMap;
  typedef IdValueMap::iterator                  IdValueIter;
#endif

  /**
   * Expands the math represented by the ASTNode to implement the functionality
   * of the FunctionDefinition, if it occurs within the original
   * math.
   *
   * For example, an ASTNode represents the math expression: f(s, p) where
   * f is the id of a FunctionDefinition representing f(x, y) = x * y.
   * The outcome of the function is that the ASTNode now represents
   * the math expression: s * p
   *
   * @param math ASTNode representing the math to be transformed
   *
   * @param fd the FunctionDefinition to be expanded
   *
   * @param idsToExclude an optional list of function definition ids to exclude.
   *
   * @copydetails doc_note_static_methods
   */
  static void replaceFD(ASTNode * math, const FunctionDefinition * fd,
                        const IdList* idsToExclude = NULL);


  /**
   * Expands the math represented by the ASTNode to implement the functionality
   * of all the FunctionDefinitions in the list, if they occur within the 
   * original math.
   *
   * For example, an ASTNode represents the math expression: f(s, g(p, q)) where
   * f is the id of a FunctionDefinition representing f(x, y) = x * y
   * and g is the id of a FunctionDefinition representing f(x, y) = x/y
   * The outcome of the function is that the ASTNode now represents
   * the math expression: s * p/q
   *
   * @param math ASTNode representing the math to be transformed
   *
   * @param lofd the ListOfFunctionDefinitions to be expanded
   * 
   * @param idsToExclude an optional list of function definition ids to exclude.
   *
   * @copydetails doc_note_static_methods
   */
  static void replaceFD(ASTNode * math, const ListOfFunctionDefinitions * lofd,
                        const IdList* idsToExclude = NULL);


  static bool expandInitialAssignments(Model * m);


  static double evaluateASTNode(const ASTNode * node, const Model * m = NULL);

#ifndef SWIG
  static double evaluateASTNode(const ASTNode * node, const IdValueMap& values, const Model * m = NULL);
  static double evaluateASTNode(const ASTNode * node, const std::map<std::string, double>& values, const Model * m = NULL);
  static IdList getComponentValuesForModel(const Model * m, IdValueMap& values);
#endif
  
  static IdList mapComponentValues(const Model * m);

  static void clearComponentValues();


protected:  
  static void replaceBvars(ASTNode * math, const FunctionDefinition * fd);
  
  static bool checkFunctionNodeForIds(ASTNode * node, IdList& ids);
  
  static bool nodeContainsId(const ASTNode * node, IdList& ids);
  
  static bool nodeContainsNameNotInList(const ASTNode * node, IdList& ids);
  
  static bool expandInitialAssignment(Parameter * p, 
                                          const InitialAssignment *ia);
  
  static bool expandInitialAssignment(Compartment * c, 
                                          const InitialAssignment *ia);
  
  static bool expandInitialAssignment(SpeciesReference * sr, 
                                          const InitialAssignment *ia);
  
  static bool expandInitialAssignment(Species * s, 
                                          const InitialAssignment *ia);

  static void recurseReplaceFD(ASTNode * math, const FunctionDefinition * fd,
                        const IdList* idsToExclude);


  static IdValueMap mValues;

};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#endif  /* SBMLTransforms_h */


/** @endcond */

