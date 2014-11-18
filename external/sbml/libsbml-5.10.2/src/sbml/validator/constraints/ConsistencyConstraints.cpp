/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    ConsistencyConstraints.cpp
 * @brief   Consistency check constraints.  See SBML Wiki
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


 
#ifndef AddingConstraintsToValidator

#include <cstring>
#include <list>

#include <sbml/SBMLTypeCodes.h>
#include <sbml/SBO.h>
#include <sbml/validator/VConstraint.h>
#include <sbml/units/UnitFormulaFormatter.h>
#include <sbml/units/FormulaUnitsData.h>
#include <sbml/AssignmentRule.h>
#include <sbml/AlgebraicRule.h>
#include <sbml/RateRule.h>

#include <sbml/util/List.h>

#include "CompartmentOutsideCycles.h"
#include "FunctionDefinitionVars.h"

#include "UniqueIdsForUnitDefinitions.h"
#include "UniqueIdsInKineticLaw.h"
#include "UniqueIdsInModel.h"
#include "UniqueVarsInEventAssignments.h"
#include "UniqueVarsInRules.h"
#include "UniqueVarsInEventsAndRules.h"
#include "UniqueMetaId.h"

#include "FunctionReferredToExists.h"
#include "SpeciesReactionOrRule.h"
#include "UniqueSpeciesTypesInCompartment.h"
#include "UniqueSymbolsInInitialAssignments.h"
#include "UniqueVarsInInitialAssignmentsAndRules.h"
#include "StoichiometryMathVars.h"
#include "KineticLawVars.h"
#include "AssignmentCycles.h"
#include "AssignmentRuleOrdering.h"

//#include "FormulaUnitsCheck.h"

//#include "PowerUnitsCheck.h"
//#include "ExponentUnitsCheck.h"
#include "ArgumentsUnitsCheck.h"

#include "LogicalArgsMathCheck.h"
#include "NumericArgsMathCheck.h"
#include "PieceBooleanMathCheck.h"
#include "PiecewiseValueMathCheck.h"
#include "EqualityArgsMathCheck.h"
#include "FunctionApplyMathCheck.h"
#include "CiElementMathCheck.h"
#include "LambdaMathCheck.h"
#include "NumericReturnMathCheck.h"
#include "LocalParameterMathCheck.h"
#include "NumberArgsMathCheck.h"

#include "OverDeterminedCheck.h"

#endif

#include <sbml/validator/ConstraintMacros.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

EXTERN_CONSTRAINT( 10214, FunctionApplyMathCheck )


// General Notes validation

// 10801 - namespace - TO DO
// 10802 - no XML - TO DO
// 10803 - no DOCTYPE - TO DO
// 10804 form of xhtml - TO DO

// SBML container validation

// 20101: sbml namespace - caught at read
// 20102: level declared and consistent - caught at read
// 20103: version declared and consistent - caught at read


// Model validation

// 20201: must contain model - caught at read

// 20202: ordering - caught at read

// 20203: no empty listOf - caught at read

START_CONSTRAINT (20204, Model, x)
{
  //msg =
  //  "If a model defines any species, then the model must also define at "
  //  "least one compartment. This is an implication of the fact that the "
  //  "'compartment' attribute on the <species> element is not optional. "
  //  "(References: L2V1 Section 4.5; L2V2 Section 4.8.3; L2V3 Section "
  //  "4.8.3.)";

  // not valid in level 1
  pre( m.getLevel() > 1);

  pre( m.getNumSpecies()      > 0 );
  inv( m.getNumCompartments() > 0 );
}
END_CONSTRAINT


START_CONSTRAINT (20216, Model, x)
{
  // level 3
  pre( m.getLevel() > 2);
  pre( m.isSetConversionFactor());

  const string&         factor = m.getConversionFactor();
  inv( m.getParameter( factor ) != NULL );
}
END_CONSTRAINT


START_CONSTRAINT (20705, Model, x)
{
  // level 3
  pre( m.getLevel() > 2);
  pre( m.isSetConversionFactor());

  const string&         factor = m.getConversionFactor();
  const Parameter* p  = m.getParameter(factor);

  pre(p != NULL);

  inv( p->getConstant() == true );
}
END_CONSTRAINT


// FunctionDefinition validation

START_CONSTRAINT (20301, FunctionDefinition, fd)
{
  pre( fd.getLevel() > 1 );
  pre( fd.isSetMath()     );

  if (fd.getLevel() == 2  && fd.getVersion() < 3)
  {
    msg =
      "The top-level element within <math> in a <functionDefinition> must be "
      "one and only one <lambda>.";
  }
  else
  {
    msg =
      "The top-level element within <math> in a <functionDefinition> must be "
      "one and only one <lambda> or a <semantics> element containing one "
      "and only one <lambda> element.";
  }
  
  bool fail = false;

  if (fd.getLevel() == 2 && fd.getVersion() < 3)
  {
    // must be a lambda but no semantics
    if (fd.getMath()->isLambda() == false)
      fail = true;
    else if (fd.getMath()->isSemantics() == true)
      fail = true;
  }
  else
  {
    if (fd.getMath()->isLambda() == false)
    {
      if (fd.getMath()->isSemantics() == true)
      {
        if (fd.getMath()->getNumChildren() == 1)
        {
          if (fd.getMath()->getChild(0)->isLambda() == false)
          {
            fail = true;
          }
        }
        else
        {
          fail = true;
        }
      }
      else
      {
        fail = true;
      }
    }
  }

  //if (fd.getLevel() == 2 && fd.getVersion() < 3)
  //{
  //  inv( !fd.getMath()->getSemanticsFlag() );
  //}

  //inv( fd.getMath()->isLambda() );

  inv(fail == false);
}
END_CONSTRAINT


EXTERN_CONSTRAINT(20302, FunctionReferredToExists)


START_CONSTRAINT (20303, FunctionDefinition, fd)
{
  //msg =
  //  "Inside the <lambda> of a <functionDefinition>, the identifier of that "
  //  "<functionDefinition> cannot appear as the value of a <ci> element. SBML "
  //  "functions are not permitted to be recursive. (References: L2V2 Sections "
  //  "3.5.3 and 4.3.2; L2V3 Sections 3.4.3 and 4.3.2.)";

  //only applies to level 2
  pre( fd.getLevel() > 1        );
  pre( fd.isSetMath()            );
  pre( fd.isSetBody() == true      );
  pre( fd.getNumArguments() != 0 );
  
  const string  id = fd.getId();

  List* variables = fd.getBody()->getListOfNodes( ASTNode_isFunction );

  std::list<ASTNode*> astlist;
  for (unsigned int n = 0; n < variables->getSize(); ++n)
  {
    astlist.push_back(static_cast<ASTNode*>(variables->get(n)));
  }

  // To avoid memory leak, the List object (variables) needs to be
  // deleted before invoking the inv macro below
  delete variables;

  std::list<ASTNode*>::iterator it = astlist.begin();

  while (it != astlist.end())
  {
    const char* name = (*it)->getName() ? (*it)->getName() : "";

    inv(strcmp(name, id.c_str()));

    ++it;
  }

}
END_CONSTRAINT


EXTERN_CONSTRAINT(20304, FunctionDefinitionVars)


START_CONSTRAINT (20305, FunctionDefinition, fd)
{
  //msg =
  //  "The value type returned by a <functionDefinition>'s <lambda> must be "
  //  "either boolean or numeric. (References: L2V2 Section 3.5.8; L2V3 "
  //  "Section 3.4.9.)";

  //only applies to level 2
  pre( fd.getLevel() > 1        );
  pre( fd.isSetMath()           );
  pre( fd.isSetBody() == true      );

  /*
   * need to look at the special case where the body of the lambda function
   * contains only one of the bvar elements
   * eg
   *  <lambda>
   *    <bvar> <ci> v </ci> </bvar>
   *    <ci> v </ci>
   *  </lambda>
   *
   * OR
   * it contains the csymbol time
   * eg
   *  <lambda>
   *    <csymbol encoding="text" 
   *    definitionURL="http://www.sbml.org/sbml/symbols/time"> 
   *    time </csymbol>
   *  </lambda>
   *
   */

  bool specialCase = false;
  if (fd.getBody()->isName() && fd.getBody()->getNumChildren() == 0)
  {
    for (unsigned int n = 0; n < fd.getNumArguments(); n++)
    {
      const ASTNode *fdArg = fd.getArgument(n);
      if (fdArg != NULL && 
          fdArg->getName() != NULL && 
          fd.getBody()->getName() != NULL )
      {
        if (!strcmp(fdArg->getName(), fd.getBody()->getName()))
        {
          specialCase = true;
          break;
        }
      }
    }
    if (fd.getNumArguments() == 0)
    {
      if (fd.getBody()->getType() == AST_NAME_TIME)
      {
        specialCase = true;
      }
    }
  }

  inv_or( fd.getBody()->isBoolean() );
  inv_or( fd.getBody()->isNumber()  );
  inv_or( fd.getBody()->isFunction());
  inv_or( fd.getBody()->isOperator());
  inv_or( specialCase);
}
END_CONSTRAINT


START_CONSTRAINT (20306, FunctionDefinition, fd)
{
  //only applies to level 3
  pre( fd.getLevel() > 2        );

  // fd must have exactly one math
  inv( fd.isSetMath() );

}
END_CONSTRAINT


START_CONSTRAINT (99301, FunctionDefinition, fd)
{
  // csymbol time shouldnt be used in function
  pre( fd.getLevel() > 1        );
  pre( fd.isSetMath()            );
  pre( fd.isSetBody() == true      );
  
  const string  id = fd.getId();

  List* variables = fd.getBody()->getListOfNodes( ASTNode_isName );

  std::list<ASTNode*> astlist;
  for (unsigned int n = 0; n < variables->getSize(); ++n)
  {
    astlist.push_back(static_cast<ASTNode*>(variables->get(n)));
  }

  // To avoid memory leak, the List object (variables) needs to be 
  // deleted before invoking the inv macro below
  delete variables;

  std::list<ASTNode*>::iterator it = astlist.begin();

  while (it != astlist.end())
  {
    ASTNodeType_t type = (*it)->getType();

    inv(type != AST_NAME_TIME);
    ++it;
  }

}
END_CONSTRAINT


START_CONSTRAINT (99302, FunctionDefinition, fd)
{

  pre( fd.getLevel() > 1        );
  pre( fd.isSetMath()            );
  pre( fd.getMath()->isLambda() );
  
  inv( fd.isSetBody() == true      );
}
END_CONSTRAINT


// Unit and UnitDefinition validation

START_CONSTRAINT (20401, UnitDefinition, ud)
{
  if (ud.getLevel() == 1)
  {
    msg =
      //"The value of the 'name' attribute in a <unitDefinition> must be of "
      //"type 'UnitSId' and not be identical "
      //"to any unit predefined in SBML. 
      "That is, the identifier must not be the "
      "same as any of the following predefined units: 'ampere' 'Celsius' "
      "'gram' "
      "'katal' 'metre' 'meter' 'second' 'watt' 'becquerel' 'gray' 'kelvin' "
      "'mole' "
      "'siemens' 'weber' 'candela' 'henry' 'kilogram' 'newton' 'sievert' "
      "'coulomb' 'hertz' 'litre' 'liter' 'ohm' 'steradian' 'dimensionless' "
      "'item' "
      "'lumen' 'pascal' 'tesla' 'farad' 'joule' 'lux' 'radian' 'volt'. ";
  }
  else
  {
    if (ud.getLevel() == 2 && ud.getVersion() == 1)
    {
      msg =
        //"The value of the 'id' attribute in a <unitDefinition> must be of "
        //"type 'UnitSId' and not be identical "
        //"to any unit predefined in SBML. 
        "That is, the identifier must not be "
        "the same as any of the following predefined units: 'ampere' 'Celsius' "
        "'gram' "
        "'katal' 'metre' 'second' 'watt' 'becquerel' 'gray' 'kelvin' 'mole' "
        "'siemens' 'weber' 'candela' 'henry' 'kilogram' 'newton' 'sievert' "
        "'coulomb' 'hertz' 'litre' 'ohm' 'steradian' 'dimensionless' 'item' "
        "'lumen' 'pascal' 'tesla' 'farad' 'joule' 'lux' 'radian' 'volt'. ";
    }
    else if (ud.getLevel() == 3)
    {
      msg =
        //"The value of the 'id' attribute in a <unitDefinition> must be of "
        //"type 'UnitSId' and not be identical "
        //"to any unit predefined in SBML. 
        "That is, the identifier must not be "
        "the same as any of the following predefined units: 'ampere' 'avogadro' "
        "'gram' "
        "'katal' 'metre' 'second' 'watt' 'becquerel' 'gray' 'kelvin' 'mole' "
        "'siemens' 'weber' 'candela' 'henry' 'kilogram' 'newton' 'sievert' "
        "'coulomb' 'hertz' 'litre' 'ohm' 'steradian' 'dimensionless' 'item' "
        "'lumen' 'pascal' 'tesla' 'farad' 'joule' 'lux' 'radian' 'volt'. ";
    }
    else
    {
      msg =
        //"The value of the 'id' attribute in a <unitDefinition> must be of "
        //"type UnitSId and not be identical "
        //"to any unit predefined in SBML. 
        "That is, the identifier must not be "
        "the same as any of the following predefined units: 'ampere' 'gram' "
        "'katal' 'metre' 'second' 'watt' 'becquerel' 'gray' 'kelvin' 'mole' "
        "'siemens' 'weber' 'candela' 'henry' 'kilogram' 'newton' 'sievert' "
        "'coulomb' 'hertz' 'litre' 'ohm' 'steradian' 'dimensionless' 'item' "
        "'lumen' 'pascal' 'tesla' 'farad' 'joule' 'lux' 'radian' 'volt'. ";
    }
  }
   
  inv( Unit::isUnitKind( ud.getId() , ud.getLevel(), ud.getVersion() ) == false );
}
END_CONSTRAINT


START_CONSTRAINT (20402, UnitDefinition, ud)
{
  pre( ud.getId() == "substance" );

  if (ud.getLevel() == 1  || (ud.getLevel() == 2 && ud.getVersion() == 1))
  {
    msg =
      "Redefinitions of the built-in unit 'substance' must be based on the "
      "units 'mole' or 'item'. More "
      "formally, a <unitDefinition> for 'substance' must simplify to a single "
      "<unit> whose 'kind' attribute has a value of 'mole' or 'item', and whose "
      "'exponent' attribute has a value "
      "of '1'.";
  }
  else   
  {
    msg =
      "Redefinitions of the predefined unit 'substance' must be based on the "
      "units 'mole', 'item', 'gram', 'kilogram', or 'dimensionless'. More "
      "formally, a <unitDefinition> for 'substance' must simplify to a single "
      "<unit> in which either (a) the 'kind' attribute has a value of 'mole', "
      "'item', 'gram' or 'kilogram', and the 'exponent' attribute has a "
      "value of '1' or (b) the 'kind' attribute has a value of 'dimensionless' "
      "with any 'exponent' attribute value.";
  }


    /* dimensionless allowable from L2V2*/
  if ( ud.getLevel() == 1 
    || ( ud.getLevel() == 2 && ud.getVersion() == 1))
  {
    inv( ud.isVariantOfSubstance() );
  }
  else
  {
    inv_or (ud.isVariantOfSubstance());
    inv_or (ud.getNumUnits() == 1 && ud.getUnit(0)->isDimensionless());
  }

}
END_CONSTRAINT


START_CONSTRAINT (20403, UnitDefinition, ud)
{
  pre( ud.getId() == "length" );

  if (ud.getLevel() == 1)
  {
    msg =
      "In later versions of SBML 'length' was added to the built-in units "
      "with restrictions on <unitDefinition>. Care would need be taken "
      "if this model were to be converted to a later Level and Version.";
  }
  else
  {
    if (ud.getLevel() == 2 && ud.getVersion() == 1)
    {
    msg =
      "Redefinitions of the built-in unit 'length' must be based on the unit "
      "'metre'. More formally, a <unitDefinition> for "
      "'length' must simplify to a single <unit> in which the "
      "'kind' attribute has a value of 'metre' and the 'exponent' attribute "
      "has a value of '1'.";
    }
    else 
    {
      msg =
        "Redefinitions of the built-in unit 'length' must be based on the unit "
        "'metre' or 'dimensionless'. More formally, a <unitDefinition> for "
        "'length' must simplify to a single <unit> in which either (a) the "
        "'kind' attribute has a value of 'metre' and the 'exponent' attribute "
        "has a value of '1', or (b) the 'kind' attribute has a value of "
        "'dimensionless' "
        "with any 'exponent' value.";
    }
  }


  /* dimensionless is allowable from L2V2 */
  if ( ud.getLevel() == 1 
    || ( ud.getLevel() == 2 && ud.getVersion() == 1))
  {
    inv( ud.isVariantOfLength());
  }
  else
  {
    inv_or(ud.getNumUnits() == 1 && ud.getUnit(0)->isDimensionless());
    inv_or(ud.isVariantOfLength());
  }
}
END_CONSTRAINT


START_CONSTRAINT (20404, UnitDefinition, ud)
{
  pre( ud.getId() == "area" );

  if (ud.getLevel() == 1)
  {
    msg =
      "In later versions of SBML 'area' was added to the built-in units "
      "with restrictions on <unitDefinition>. Care would need be taken "
      "if this model were to be converted to a later level and version.";
  }
  else
  {
    if (ud.getLevel() == 2 && ud.getVersion() == 1)
    {
      msg =
        "Redefinitions of the built-in unit 'area' must be based on squared "
        "'metre's. More formally, a <unitDefinition> for "
        "'area' must simplify to a single <unit> in which  the 'kind' "
        "attribute has a value of 'metre' and the 'exponent' attribute has a "
        "value of '2'.";
    }
    else
    {
      msg =
        "Redefinitions of the built-in unit 'area' must be based on squared "
        "'metre's or 'dimensionless'. More formally, a <unitDefinition> for "
        "'area' must simplify to a single <unit> in which either (a) the 'kind' "
        "attribute has a value of 'metre' and the 'exponent' attribute has a "
        "value of "
        "'2', or (b) the 'kind' attribute has a value of 'dimensionless' with any "
        "'exponent' value.";
    }
  }


  /* dimensionless is allowable in L2V2 */
  if ( ud.getLevel() == 1 
    || ( ud.getLevel() == 2 && ud.getVersion() == 1))
  {
    inv( ud.isVariantOfArea()         );
  }
  else
  {
    inv_or(ud.getNumUnits() == 1  && ud.getUnit(0)->isDimensionless());
    inv_or(ud.isVariantOfArea());
  }
}
END_CONSTRAINT


START_CONSTRAINT (20405, UnitDefinition, ud)
{
  pre( ud.getId() == "time" );

  if (ud.getLevel() == 1  || (ud.getLevel() == 2 && ud.getVersion() == 1))
  {
    msg =
      "Redefinitions of the built-in unit 'time' must be based on 'second'. "
      "More formally, a <unitDefinition> for 'time' must simplify to a single "
      "<unit> in which the 'kind' attribute has a value of 'second' and "
      "the 'exponent' attribute has a value of '1'.";
  }
  else
  {
    msg =
      "Redefinitions of the built-in unit 'time' must be based on 'second'. "
      "More formally, a <unitDefinition> for 'time' must simplify to a single "
      "<unit> in which either (a) the 'kind' attribute has a value of 'second' "
      "and the 'exponent' attribute has a value of '1', or (b) the 'kind' "
      "attribute has a "
      "value of 'dimensionless' with any 'exponent' value.";
  }



  /* dimensionless is allowable in L2V2 */
  if ( ud.getLevel() == 1 
    || ( ud.getLevel() == 2 && ud.getVersion() == 1))
  {
    inv( ud.isVariantOfTime()        );
  }
  else
  {
    inv_or(ud.getNumUnits() == 1 && ud.getUnit(0)->isDimensionless());
    inv_or(ud.isVariantOfTime());
  }
}
END_CONSTRAINT


START_CONSTRAINT (20406, UnitDefinition, ud)
{
  pre( ud.getId() == "volume" );

  if (ud.getLevel() == 1)
  {
    msg =
      "Redefinitions of the built-in unit 'volume' must be based on 'litre'. "
      "More formally, a <unitDefinition> for "
      "'volume' must simplify to a single <unit> in which the 'kind' attribute "
      "value is 'litre'. ";
  }
  else
  {
    if (ud.getLevel() == 2 && ud.getVersion() == 1)
    {
      msg =
        "Redefinitions of the built-in unit 'volume' must be based on 'litre', "
        "or 'metre'. More formally, a <unitDefinition> for "
        "'volume' must simplify to a single <unit> in which the 'kind' "
        "attribute "
        "value is either 'litre' or 'metre'. Additional "
        "constraints apply if the kind is 'litre' or 'metre'.";
    }
    else if (ud.getLevel() == 2 && ud.getVersion() < 4)
    {
      msg =
        "Redefinitions of the built-in unit 'volume' must be based on 'litre', "
        "'metre' or 'dimensionless'. More formally, a <unitDefinition> for "
        "'volume' must simplify to a single <unit> in which the 'kind' "
        "attribute "
        "value is either 'litre', 'metre', or 'dimensionless'. Additional "
        "constraints apply if the kind is 'litre' or 'metre'.";
    }
    else 
    {
      msg =
        "Redefinitions of the prefined unit 'volume' must be based on 'litre', "
        "'metre' or 'dimensionless'. More formally, a <unitDefinition> for "
        "'volume' must simplify to a single <unit> in which either (a) the 'kind' "
        "attribute is 'litre' and the 'exponent' has a value of '1'; (b) the 'kind' "
        "attribute has a value of 'metre' and the 'exponent' has a value of '3', or "
        "(c) the 'kind' attribute has a value of 'dimensionless' with any 'exponent "
        "value.";
   }
  }


  if (ud.getLevel() == 1 || (ud.getLevel() == 2 && ud.getVersion() < 4))
  {
    /* Hack whilst we sort out whether there should be three rules for volume 
    * redefinition or just one
    */
    /* dimensionless is allowable in L2V2 */
    if (ud.getNumUnits() == 1)
    {
      if (  ud.getLevel() == 1 )
      {
        inv (ud.getUnit(0)->isLitre());
      }
      else if ( ud.getLevel() == 2 && ud.getVersion() == 1)
      {
        inv( ud.getUnit(0)->isLitre() || ud.getUnit(0)->isMetre() );
      }
      else
      {
        inv( ud.getUnit(0)->isLitre() 
          || ud.getUnit(0)->isMetre() 
          || ud.getUnit(0)->isDimensionless() );
      }
    }
    else
    {
      if (  ud.getLevel() == 1 )
      {
        inv (ud.getNumUnits() == 1 && ud.getUnit(0)->isLitre());
      }
      else if (ud.getLevel() == 2 && ud.getVersion() == 1)
      {
        inv(ud.isVariantOfVolume());
      }
      else
      {
        inv_or( ud.getNumUnits() == 1 && ud.getUnit(0)->isDimensionless() );
        inv_or( ud.isVariantOfVolume());
      }
    }
  }
  else
  {
    inv_or(ud.getNumUnits() == 1 && ud.getUnit(0)->isDimensionless());
    inv_or(ud.isVariantOfVolume());
  }
}
END_CONSTRAINT


START_CONSTRAINT (20407, UnitDefinition, ud)
{
  /* this constraint was removed in l2V4 as it was assumed into 20406 */
  pre( ud.getLevel() == 1 || ( ud.getLevel() == 2 && ud.getVersion() < 4));
  pre( ud.getId()       == "volume" );
  pre( ud.getNumUnits() == 1        );
  pre( ud.getUnit(0)->isLitre()     );

  //msg =
  //  "If a <unitDefinition> for 'volume' simplifies to a <unit> in which the "
  //  "'kind' attribute value is 'litre', then its 'exponent' attribute value "
  //  "must be '1'. (References: L2V1 Section 4.4.3; L2V2 Section 4.4.3; L2V3 "
  //  "Section 4.4.3.)";

  inv( ud.getUnit(0)->getExponent() == 1 );
}
END_CONSTRAINT


START_CONSTRAINT (20408, UnitDefinition, ud)
{
  pre( ud.getLevel() > 1);
  /* this constraint was removed in l2V4 as it was assumed into 20406 */
  pre( ud.getLevel() == 2 && ud.getVersion() < 4);

  pre( ud.getId()       == "volume" );
  pre( ud.getNumUnits() == 1        );
  pre( ud.getUnit(0)->isMetre()     );
  //msg =
  //  "If a <unitDefinition> for 'volume' simplifies to a <unit> in which the "
  //  "'kind' attribute value is 'metre', then its 'exponent' attribute value "
  //  "must be '3'. (References: L2V1 Section 4.4.3; L2V2 Section 4.4.3; L2V3 "
  //  "Section 4.4.3.)";


  inv( ud.getUnit(0)->getExponent() == 3 );
}
END_CONSTRAINT


// 20409: ListofUnits cannot be empty - caught at read


START_CONSTRAINT (20410, UnitDefinition, ud)
{
  //msg =
  //  "The value of the 'kind' attribute of a <unit> can only be one of the "
  //  "predefined units enumerated by 'UnitKind'; that is, the SBML unit "
  //  "system is not hierarchical and user-defined units cannot be defined "
  //  "using other user-defined units. (References: L2V2 Section 4.4.2; L2V3 "
  //  "Section 4.4.2.)";

  for (unsigned int n = 0; n < ud.getNumUnits(); ++n)
  {
    /* if the unit kind is Celsius and invalid we dont want to report
     * this as it is caught by another constraint
     */
    if (!(ud.getUnit(n)->isCelsius()))
    {
      inv( Unit::isUnitKind( UnitKind_toString(ud.getUnit(n)->getKind()), 
        ud.getLevel(), ud.getVersion()));
    }
  }
}
END_CONSTRAINT


START_CONSTRAINT (20411, UnitDefinition, ud)
{
  pre( ud.getLevel() > 1);
  if ( ud.getLevel() == 2)
  {
    pre (ud.getVersion() > 1 );
  }
  //msg =
  //  "The 'offset' attribute on <unit> previously available in SBML Level 2 "
  //  "Version 1, has been removed as of SBML Level 2 Version 2. (References: "
  //  "L2V2 Section 4.4.)";


  for (unsigned int n = 0; n < ud.getNumUnits(); ++n)
  {
    inv(ud.getUnit(n)->getOffset() == 0);
  }
}
END_CONSTRAINT


START_CONSTRAINT (20412, Unit, u)
{
  pre( u.getLevel() > 1);
  if ( u.getLevel() == 2)
  {
    pre (u.getVersion() > 1 );
  }
  //msg =
  //  "The predefined unit 'Celsius', previously available in SBML Level 1 and "
  //  "Level 2 Version 1, has been removed as of SBML Level 2 Version 2. "
  //  "(References: L2V2 Section 4.4.)";

  inv( u.isCelsius() == false );
}
END_CONSTRAINT


START_CONSTRAINT (20412, Parameter, p)
{
  pre( p.getLevel() > 1);
  if ( p.getLevel() == 2)
  {
    pre (p.getVersion() > 1 );
  }
  //msg =
  //  "The predefined unit 'Celsius', previously available in SBML Level 1 and "
  //  "Level 2 Version 1, has been removed as of SBML Level 2 Version 2. "
  //  "(References: L2V2 Section 4.4.)";

  inv( UnitKind_forName( p.getUnits().c_str() ) != UNIT_KIND_CELSIUS );
}
END_CONSTRAINT


// Compartment validation

START_CONSTRAINT (20501, Compartment, c)
{
  pre( c.getLevel() > 1);
  if (c.getLevel() == 2)
  {
    pre( c.getSpatialDimensions() == 0 );
  }
  else
  {
    pre( c.getSpatialDimensionsAsDouble() == 0);
  }
  
  //msg =
  //  "The size of a <compartment> must not be set if the compartment's "
  //  "'spatialDimensions' attribute has value '0'. (References: L2V1 Section "
  //  "4.5.3; L2V2 Section 4.7.4; L2V3 Section 4.7.5.)";

  inv( c.isSetSize() == false );
}
END_CONSTRAINT


START_CONSTRAINT (20502, Compartment, c)
{
  pre( c.getLevel() > 1);
  if (c.getLevel() == 2)
  {
    pre( c.getSpatialDimensions() == 0 );
  }
  else
  {
    pre( c.getSpatialDimensionsAsDouble() == 0);
  }

  //msg =
  //  "If a <compartment> definition has a 'spatialDimensions' value of '0', "
  //  "then its 'units' attribute must not be set. If the compartment has no "
  //  "dimensions, then no units can be associated with a non-existent size. "
  //  "(References: L2V1 Section 4.5.4; L2V2 Section 4.7.5; L2V3 Section 4.7.5.)";

  
  inv( c.isSetUnits() == false       );
}
END_CONSTRAINT


START_CONSTRAINT (20503, Compartment, c)
{
  pre( c.getLevel() > 1);
  if (c.getLevel() == 2)
  {
    pre( c.getSpatialDimensions() == 0 );
  }
  else
  {
    pre( c.getSpatialDimensionsAsDouble() == 0);
  }
  //msg =
  //  "If a <compartment> definition has a 'spatialDimensions' value of '0', "
  //  "then its 'constant' attribute value must either default to or be set to "
  //  "'true'. If the compartment has no dimensions, then its size can never "
  //  "change. (References: L2V1 Section 4.5.5; L2V2 Section 4.7.4; L2V3 "
  //  "Section 4.7.6.)";

  inv( c.getConstant() == true       );
}
END_CONSTRAINT


START_CONSTRAINT (20504, Compartment, c)
{
  pre( c.isSetOutside() );

  //msg =
  //  "The 'outside' attribute value of a <compartment> must be the identifier of "
  //  "another <compartment> defined in the model. (References: L2V1 Section "
  //  "4.5.6; L2V2 Section 4.7.7; L2V3 Section 4.7.7.)";

  inv( m.getCompartment( c.getOutside() ) != NULL );
}
END_CONSTRAINT


EXTERN_CONSTRAINT(20505, CompartmentOutsideCycles)


START_CONSTRAINT (20506, Compartment, c)
{
  pre (c.getLevel() > 1);
  pre ( c.isSetOutside() && c.getSpatialDimensions() == 0 );
  pre ( m.getCompartment( c.getOutside() ) != NULL );

  //msg =
  //  "The 'outside' attribute value of a <compartment> cannot be a compartment "
  //  "whose 'spatialDimensions' value is '0', unless both compartments have "
  //  "'spatialDimensions'='0'. Simply put, a zero-dimensional compartment "
  //  "cannot enclose compartments that have anything other than zero "
  //  "dimensions themselves. (References: L2V2 Section 4.7.7; L2V3 Section "
  //  "4.7.7.)";


  inv( m.getCompartment( c.getOutside() )->getSpatialDimensions() == 0 );
}
END_CONSTRAINT


START_CONSTRAINT (20507, Compartment, c)
{
  pre (c.getLevel() > 1);
  pre( c.getSpatialDimensions() == 1 );
  pre( c.isSetUnits()                );

  if (c.getLevel() == 2 && c.getVersion() == 1)
  {
    msg =
      "The value of the 'units' attribute on a <compartment> having "
      "'spatialDimensions' of '1' must be either 'length' or 'metre', "
      "or the identifier of a <unitDefinition> based on "
      "either 'metre' (with 'exponent' equal to '1').";
  }
  else
  {
    msg =
      "The value of the 'units' attribute on a <compartment> having "
      "'spatialDimensions' of '1' must be either 'length', 'metre', "
      "'dimensionless', or the identifier of a <unitDefinition> based on "
      "either 'metre' (with 'exponent' equal to '1') or 'dimensionless'.";
  }

  const string&         units = c.getUnits();
  const UnitDefinition* defn  = m.getUnitDefinition(units);

  /* dimensionless is allowable in L2V2 */
  if (c.getLevel() == 2 && c.getVersion() == 1)
  {
    inv_or( units == "length" );
    inv_or( units == "metre"  );
    inv_or( defn  != NULL && defn->isVariantOfLength() );
  }
  else
  {
    inv_or( units == "length" );
    inv_or( units == "metre"  );
    inv_or( units == "dimensionless"  );
    inv_or( defn  != NULL && defn->isVariantOfLength() );
    inv_or( defn  != NULL && defn->isVariantOfDimensionless() );
  }
}
END_CONSTRAINT


START_CONSTRAINT (20508, Compartment, c)
{
  pre (c.getLevel() > 1);
  pre( c.getSpatialDimensions() == 2 );
  pre( c.isSetUnits()                );

  if (c.getLevel() == 2 && c.getVersion() == 1)
  {
    msg =
      "The value of the 'units' attribute on a <compartment> having "
      "'spatialDimensions' of '2' must be either 'area' or "
      "the identifier of a <unitDefinition> based on 'metre' (with "
      "'exponent' equal to '2').";
  }
  else
  {
    msg =
      "The value of the 'units' attribute on a <compartment> having "
      "'spatialDimensions' of '2' must be either 'area', 'dimensionless', or "
      "the identifier of a <unitDefinition> based on either 'metre' (with "
      "'exponent' equal to '2') or 'dimensionless'.";
  }

  const string&         units = c.getUnits();
  const UnitDefinition* defn  = m.getUnitDefinition(units);

  /* dimensionless is allowable in L2V2 */
  if (c.getLevel() == 2 && c.getVersion() == 1)
  {
    inv_or( units == "area" );
    inv_or( defn  != NULL && defn->isVariantOfArea() );
  }
  else
  {
    inv_or( units == "area" );
    inv_or( units == "dimensionless"  );
    inv_or( defn  != NULL && defn->isVariantOfArea() );
    inv_or( defn  != NULL && defn->isVariantOfDimensionless() );
  }
}
END_CONSTRAINT


START_CONSTRAINT (20510, Compartment, c)
{
  pre( c.getLevel() > 1);
  if (c.getLevel() == 2 )
  {
    pre( c.getVersion() > 1 );
  }
  pre( c.isSetCompartmentType());

  msg =
    "Compartment type '" + c.getCompartmentType() + "' is undefined. ";
    //"If the 'compartmentType' attribute is given a value in a <compartment> "
    //"definition, it must contain the identifier of an existing "
    //"<compartmentType>. (References: L2V2 Section 4.7.2; L2V3 Section 4.7.2.)";


  inv( m.getCompartmentType( c.getCompartmentType() ) != NULL );
}
END_CONSTRAINT

/* moved to unit validator */
//START_CONSTRAINT (20511, Compartment, c)
//{
//  pre( c.getLevel() > 2);
//  pre( c.getSpatialDimensionsAsDouble() == 1);
//  pre( !(c.isSetUnits()));
//
//  inv( m.isSetLengthUnits());
//}
//END_CONSTRAINT
//
//START_CONSTRAINT (20512, Compartment, c)
//{
//  pre( c.getLevel() > 2);
//  pre( c.getSpatialDimensionsAsDouble() == 2);
//  pre( !(c.isSetUnits()));
//
//  inv( m.isSetAreaUnits());
//}
//END_CONSTRAINT
//
//START_CONSTRAINT (20513, Compartment, c)
//{
//  pre( c.getLevel() > 2);
//  pre( c.getSpatialDimensionsAsDouble() == 3);
//  pre( !(c.isSetUnits()));
//
//  inv( m.isSetVolumeUnits());
//}
//END_CONSTRAINT

// Species validation

START_CONSTRAINT (20601, Species, s)
{
  pre( s.isSetCompartment() );

  msg =
    "Compartment '" + s.getCompartment() + "' is undefined. ";
    //"The value of 'compartment' in a <species> definition must be the "
    //"identifier of an existing <compartment> defined in the model. "
    //"(References: L2V1 Section 4.6.2; L2V2 Section 4.8.3; L2V3 Section 4.8.3.)";

  inv( m.getCompartment( s.getCompartment() ) != NULL );
}
END_CONSTRAINT


START_CONSTRAINT (20602, Species, s)
{
  pre ( s.getLevel() == 2 && s.getVersion() < 3);
  pre( s.getHasOnlySubstanceUnits() == true );

  //msg =
  //  "If a <species> definition sets 'hasOnlySubstanceUnits' to 'true', then "
  //  "it must not have a value for 'spatialSizeUnits'. (References: L2V1 "
  //  "Section 4.6.4; L2V2 Section 4.8.5.)";

  inv( !s.isSetSpatialSizeUnits()           );
}
END_CONSTRAINT


START_CONSTRAINT (20603, Species, s)
{
  pre ( s.getLevel() == 2 && s.getVersion() < 3);

  const Compartment* c = m.getCompartment( s.getCompartment() );
  pre( c != NULL && c->getSpatialDimensions() == 0 );

  //msg =
  //  "A <species> definition must not set 'spatialSizeUnits' if the "
  //  "<compartment> in which it is located has a 'spatialDimensions' value of "
  //  "'0'. (References: L2V1 Section 4.6.4; L2V2 Section 4.8.5.)";

  inv( !s.isSetSpatialSizeUnits()                  );
}
END_CONSTRAINT


START_CONSTRAINT (20604, Species, s)
{
  pre ( s.getLevel() > 1);

  const Compartment* c = m.getCompartment( s.getCompartment() );

  pre( c != NULL && c->getSpatialDimensions() == 0 );

  //msg =
  //  "If a <species> located in a <compartment> whose 'spatialDimensions' is "
  //  "set to '0', then that <species> definition cannot set "
  //  "'initialConcentration'. (References: L2V1 Section 4.6.3; L2V2 Section "
  //  "4.8.4; L2V3 Section 4.8.4.)";


  inv( !s.isSetInitialConcentration()              );
}
END_CONSTRAINT


START_CONSTRAINT (20605, Species, s)
{
  pre ( s.getLevel() == 2 && s.getVersion() < 3);

  const Compartment* c = m.getCompartment( s.getCompartment() );

  pre( c != NULL && c->getSpatialDimensions() == 1 );
  pre( s.isSetSpatialSizeUnits() );

  //msg =
    //"If a <species> is located in a <compartment> whose 'spatialDimensions' "
    //"has value '1', then that <species> definition can only set "
    //"'spatialSizeUnits' to a value of 'length', 'metre', 'dimensionless', or "
    //"the identifier of a <unitDefinition> derived from 'metre' (with an "
    //"'exponent' value of '1') or 'dimensionless'. (References: L2V1 Section "
    //"4.6.4; L2V2 Section 4.8.5.)";


  const string&         units = s.getSpatialSizeUnits();
  const UnitDefinition* defn  = m.getUnitDefinition(units);

  /* dimensionless is allowable in L2V2 */
  if (s.getVersion() == 2)
  {
    inv_or( units == "length" );
    inv_or( units == "metre"  );
    inv_or( units == "dimensionless"  );
    inv_or( defn  != NULL && defn->isVariantOfLength() );
    inv_or( defn  != NULL && defn->isVariantOfDimensionless() );
  }
  else
  {
    inv_or( units == "length" );
    inv_or( units == "metre"  );
    inv_or( defn  != NULL && defn->isVariantOfLength() );
  }
}
END_CONSTRAINT


START_CONSTRAINT (20606, Species, s)
{
  pre ( s.getLevel() == 2 && s.getVersion() < 3);
  
  const Compartment* c = m.getCompartment( s.getCompartment() );

  pre( c != NULL && c->getSpatialDimensions() == 2 );
  pre( s.isSetSpatialSizeUnits() );

  //msg =
    //"If a <species> is located in a <compartment> whose 'spatialDimensions' "
    //"has value '2', then that <species> definition can only set "
    //"'spatialSizeUnits' to a value of 'area', 'dimensionless', or the "
    //"identifier of a <unitDefinition> derived from either 'metre' (with an "
    //"'exponent' value of '2') or 'dimensionless'. (References: L2V1 Section "
    //"4.6.4; L2V2 Section 4.8.5.)";


  const string&         units = s.getSpatialSizeUnits();
  const UnitDefinition* defn  = m.getUnitDefinition(units);

  /* dimensionless is allowable in L2V2 */
  if (s.getVersion() == 2)
  {
    inv_or( units == "area" );
    inv_or( units == "dimensionless"  );
    inv_or( defn  != NULL && defn->isVariantOfArea() );
    inv_or( defn  != NULL && defn->isVariantOfDimensionless() );
  }
  else
  {
    inv_or( units == "area" );
    inv_or( defn  != NULL && defn->isVariantOfArea() );
  }
}
END_CONSTRAINT


START_CONSTRAINT (20607, Species, s)
{
  pre ( s.getLevel() == 2 && s.getVersion() < 3);

  const Compartment* c = m.getCompartment( s.getCompartment() );

  pre( c != NULL && c->getSpatialDimensions() == 3 );
  pre( s.isSetSpatialSizeUnits() );

  //msg =
  //  "If a <species> is located in a <compartment> whose 'spatialDimensions' "
  //  "has value '3', then that <species> definition can only set "
  //  "'spatialSizeUnits' to a value of 'volume', 'litre', 'dimensionless', or "
  //  "the identifier of a <unitDefinition> derived from either 'litre', "
  //  "'metre' (with an 'exponent' value of '3') or 'dimensionless'. "
  //  "(References: L2V1 Section 4.6.4; L2V2 Section 4.8.5.)";

  const string&         units = s.getSpatialSizeUnits();
  const UnitDefinition* defn  = m.getUnitDefinition(units);

  /* dimensionless is allowable in L2V2 */
  if (s.getVersion() == 2)
  {
    inv_or( units == "volume" );
    inv_or( units == "litre"  );
    inv_or( units == "dimensionless"  );
    inv_or( defn  != NULL && defn->isVariantOfVolume() );
    inv_or( defn  != NULL && defn->isVariantOfDimensionless() );
  }
  else
  {
    inv_or( units == "volume" );
    inv_or( units == "litre"  );
    inv_or( defn  != NULL && defn->isVariantOfVolume() );
  }
}
END_CONSTRAINT


START_CONSTRAINT (20609, Species, s)
{
  pre ( s.getLevel() > 1);
  pre(  s.isSetInitialAmount()        );
  
  //msg =
  //  "A <species> cannot set values for both 'initialConcentration' and "
  //  "'initialAmount' because they are mutually exclusive. (References: L2V1 "
  //  "Section 4.6.3; L2V2 Section 4.8.4; L2V3 Section 4.8.4.)";

  inv( !s.isSetInitialConcentration() );
}
END_CONSTRAINT


EXTERN_CONSTRAINT(20610, SpeciesReactionOrRule)

// TO DO - get this to reference line no of species 
START_CONSTRAINT (20611, SpeciesReference, sr)
{
  pre (sr.getLevel() > 1);

  /* doesnt apply if the SpeciesReference is a modifier */
  pre(!sr.isModifier());
  const Species* s = m.getSpecies( sr.getSpecies() );

  pre( s != NULL );
  
  //msg =
  //  "A <species> having boundaryCondition=\"false\" cannot appear as a "
  //  "reactant or product in any reaction if that Species also has "
  //  "constant=\"true\". (References: L2V1 Section 4.6.5; L2V2 Section "
  //  "4.8.6; L2V3 Section 4.8.6.)";


  inv( ! (s->getConstant() == true && s->getBoundaryCondition() == false) ); 
}
END_CONSTRAINT


START_CONSTRAINT (20612, Species, s)
{
  pre( s.getLevel() > 1);
  if (s.getLevel() == 2) 
  {
    pre( s.getVersion() > 1 );
  }
  pre( s.isSetSpeciesType() );

  msg =
    "Species type '" + s.getSpeciesType() + "' is undefined. ";
    //"The value of 'speciesType' in a <species> definition must be the "
    //"identifier of an existing <speciesType>. (References: L2V2 Section "
    //"4.8.2; L2V3 Section 4.8.2)";

  inv( m.getSpeciesType( s.getSpeciesType() ) != NULL );
}
END_CONSTRAINT


EXTERN_CONSTRAINT(20613, UniqueSpeciesTypesInCompartment)


START_CONSTRAINT (20614, Species, s)
{
  // level 3 catches this elsewhere
  pre (s.getLevel() < 3);
  //msg =
  //  "The 'compartment' attribute in a <species> is mandatory. A <species> "
  //  "definition in a model must include a value for this attribute. "
  //  "(References: L2V2 Section 4.8.3; L2V3 Section 4.8.3.)";

  inv( s.isSetCompartment() );
}
END_CONSTRAINT


START_CONSTRAINT (20615, Species, s)
{
  pre(s.getLevel() > 1);
  if (s.getLevel() == 2)
  {
    pre(s.getVersion() > 2);
  }
  //msg =
  //  "The 'spatialSizeUnits' attribute on <species>, previously available "
  //  "in SBML Level 2 versions prior to Version 3, has been removed as "
  //  "of SBML Level 2 Version 3. (References: L2V3 Section 4.8.)";

  inv( s.isSetSpatialSizeUnits() == false);
}
END_CONSTRAINT

/* moved to unit validator */
//
//START_CONSTRAINT (20616, Species, s)
//{
//  pre( s.getLevel() > 2);
//  pre( !(s.isSetSubstanceUnits()));
//
//  inv( m.isSetSubstanceUnits());
//}
//END_CONSTRAINT


START_CONSTRAINT (20617, Species, s)
{
  // level 3
  pre( s.getLevel() > 2);
  pre( s.isSetConversionFactor());

  const string&         factor = s.getConversionFactor();
  inv( m.getParameter( factor ) != NULL );
}
END_CONSTRAINT


START_CONSTRAINT (20705, Species, s)
{
  // level 3
  pre( s.getLevel() > 2);
  pre( s.isSetConversionFactor());

  const string&         factor = s.getConversionFactor();
  const Parameter* p  = m.getParameter(factor);
  pre(p != NULL);

  inv( p->getConstant() == true );
}
END_CONSTRAINT


// Parameter validation

/* moved to unit validator */
//START_CONSTRAINT (20702, Parameter, p)
//{
//  pre( p.getLevel() > 2 );
//
//  inv( p.isSetUnits() );
//}
//END_CONSTRAINT
//
//
// InitialAssignment validation

START_CONSTRAINT (20801, InitialAssignment, ia)
{
  pre( ia.isSetSymbol() );

  //msg =
  //  "The value of 'symbol' in an <initialAssignment> definition must be the "
  //  "identifier of an existing <compartment>, <species>, or <parameter> "
  //  "defined in the model. (References: L2V2 Section 4.10; L2V3 Section 4.10.)";

  const string& id = ia.getSymbol();

  if (ia.getLevel() == 2)
  {
    inv_or( m.getCompartment(id) );
    inv_or( m.getSpecies    (id) );
    inv_or( m.getParameter  (id) );
  }
  else
  {
    inv_or( m.getCompartment(id) );
    inv_or( m.getSpecies    (id) );
    inv_or( m.getParameter  (id) );
    inv_or( m.getSpeciesReference  (id) );
  }
}
END_CONSTRAINT


EXTERN_CONSTRAINT(20802, UniqueSymbolsInInitialAssignments)
EXTERN_CONSTRAINT(20803, UniqueVarsInInitialAssignmentsAndRules)

START_CONSTRAINT (20804, InitialAssignment, ia)
{
  //only applies to level 3
  pre( ia.getLevel() > 2        );

  // ia must have exactly one math
  inv( ia.isSetMath() );

}
END_CONSTRAINT




// Assignment and rate Rule validation

START_CONSTRAINT (20901, AssignmentRule, r)
{
  if (r.getLevel() == 1)
  {
    pre ( r.isScalar() );
  }
  pre( r.isSetVariable() );

  if (r.getLevel() > 1)
  {
    //msg =
    //  "The value of an <assignmentRule>'s 'variable' must be the identifier of "
    //  "an existing <compartment>, <species>, or globally-defined <parameter>. "
    //  "(References: L2V1 Section 4.8.2; L2V2 Section 4.11.3; L2V3 Section "
    //  "4.11.3.)";
  }
  else
  {
    if (r.isCompartmentVolume())
    {
      msg =
        "In a level 1 model this implies that "
        "the value of a <compartmentVolumeRule>'s 'compartment' must be the "
        "identifier of an existing <compartment>. ";
    }
    else if (r.isSpeciesConcentration())
    {
      msg =
        "In a level 1 model this implies that "
        "the value of a <speciesConcentrationRule>'s 'species' must be the "
        "identifier of an existing <species>. ";
    }
    else
    {
      msg =
        "In a level 1 model this implies that "
        "the value of a <parameterRule>'s 'name' must be the "
        "identifier of an existing <parameter>. ";
    }
  }



  const string& id = r.getVariable();

  if (r.getLevel() < 3)
  {
    inv_or( m.getCompartment(id) );
    inv_or( m.getSpecies    (id) );
    inv_or( m.getParameter  (id) );
  }
  else
  {
    inv_or( m.getCompartment(id) );
    inv_or( m.getSpecies    (id) );
    inv_or( m.getParameter  (id) );
    inv_or( m.getSpeciesReference  (id) );

  }
}
END_CONSTRAINT


START_CONSTRAINT (20902, RateRule, r)
{
  if (r.getLevel() == 1)
  {
    pre ( r.isRate() );
  }
  pre( r.isSetVariable() );

  if (r.getLevel() > 1)
  {
    //msg =
    //  "The value of a <rateRule>'s 'variable' must be the identifier of an "
    //  "existing <compartment>, <species>, or globally-defined <parameter>. "
    //  "(References: L2V1 Section 4.8.3; L2V2 Section 4.11.4; L2V3 Section "
    //  "4.11.4.)";
  }
  else
  {
    if (r.isCompartmentVolume())
    {
      msg =
        "In a level 1 model this implies that "
        "the value of a <compartmentVolumeRule>'s 'compartment' must be the "
        "identifier of an existing <compartment>. ";
    }
    else if (r.isSpeciesConcentration())
    {
      msg =
        "In a level 1 model this implies that "
        "the value of a <speciesConcentrationRule>'s 'species' must be the "
        "identifier of an existing <species>. ";
    }
    else
    {
      msg =
        "In a level 1 model this implies that "
        "the value of a <parameterRule>'s 'name' must be the "
        "identifier of an existing <parameter>. ";
    }
  }



  const string& id = r.getVariable();

  if (r.getLevel() < 3)
  {
    inv_or( m.getCompartment(id) );
    inv_or( m.getSpecies    (id) );
    inv_or( m.getParameter  (id) );
  }
  else
  {
    inv_or( m.getCompartment(id) );
    inv_or( m.getSpecies    (id) );
    inv_or( m.getParameter  (id) );
    inv_or( m.getSpeciesReference  (id) );
  }
}
END_CONSTRAINT


START_CONSTRAINT (20903, AssignmentRule, r)
{
  pre( r.getLevel() > 1);
  pre( r.isSetVariable() );

  //msg =
  //  "Any <compartment>, <species> or <parameter> whose identifier is the "
  //  "value of a 'variable' attribute in an <assignmentRule>, must have a value "
  //  "of 'false' for 'constant'. (References: L2V1 Section 4.8.4; L2V2 "
  //  "Section 4.11.3; L2V3 Section 4.11.3.)";


  const string& id = r.getVariable();

  const Compartment* c = m.getCompartment(id);
  const Species*     s = m.getSpecies    (id);
  const Parameter*   p = m.getParameter  (id);
  const SpeciesReference* sr = m.getSpeciesReference(id);

  if (r.getLevel() < 3)
  {
    pre( c || s || p );

    inv_or( c && c->getConstant() == false );
    inv_or( s && s->getConstant() == false );
    inv_or( p && p->getConstant() == false );
  }
  else
  {
    pre( c || s || p || sr);

    inv_or( c && c->getConstant() == false );
    inv_or( s && s->getConstant() == false );
    inv_or( p && p->getConstant() == false );
    inv_or( sr && sr->getConstant() == false );
  }
}
END_CONSTRAINT


START_CONSTRAINT (20904, RateRule, r)
{
  pre( r.getLevel() > 1);
  pre( r.isSetVariable() );

  //msg =
  //  "Any <compartment>, <species> or <parameter> whose identifier is the "
  //  "value of a 'variable' attribute in an <rateRule>, must have a value of "
  //  "'false' for 'constant'. (References: L2V1 Section 4.8.4; L2V2 Section "
  //  "4.11.4; L2V3 Section 4.11.4)";


  const string& id = r.getVariable();

  const Compartment* c = m.getCompartment(id);
  const Species*     s = m.getSpecies    (id);
  const Parameter*   p = m.getParameter  (id);
  const SpeciesReference* sr = m.getSpeciesReference(id);

  if (r.getLevel() < 3)
  {
    pre( c || s || p );

    inv_or( c && c->getConstant() == false );
    inv_or( s && s->getConstant() == false );
    inv_or( p && p->getConstant() == false );
  }
  else
  {
    pre( c || s || p || sr);

    inv_or( c && c->getConstant() == false );
    inv_or( s && s->getConstant() == false );
    inv_or( p && p->getConstant() == false );
    inv_or( sr && sr->getConstant() == false );
  }
}
END_CONSTRAINT


// 20905 is missing as it is a repeat of 10304
EXTERN_CONSTRAINT(20906, AssignmentCycles)
EXTERN_CONSTRAINT(99106, AssignmentRuleOrdering)

START_CONSTRAINT (20907, AssignmentRule, r)
{
  //only applies to level 3
  pre( r.getLevel() > 2        );

  // r must have exactly one math
  inv( r.isSetMath() );

}
END_CONSTRAINT


START_CONSTRAINT (20907, RateRule, r)
{
  //only applies to level 3
  pre( r.getLevel() > 2        );

  // r must have exactly one math
  inv( r.isSetMath() );

}
END_CONSTRAINT


START_CONSTRAINT (20907, AlgebraicRule, r)
{
  //only applies to level 3
  pre( r.getLevel() > 2        );

  // r must have exactly one math
  inv( r.isSetMath() );

}
END_CONSTRAINT




// Constraint validation

START_CONSTRAINT (21001, Constraint, c)
{
  pre ( c.getLevel() > 1);
  if (c.getLevel() == 2)
  {
    pre( c.getVersion() > 1);
  }
  pre( c.isSetMath() );

  //msg =
  //  "A <constraint>'s <math> expression must evaluate to a value of type "
  //  "boolean. (References: L2V2 Section 4.12.1; L2V3 Section 4.12.)";

  inv( m.isBoolean( c.getMath() ) );
}
END_CONSTRAINT


// 21002: ordering - caught at read
// 21003: message namespace - caught at read
// 21004: message no XML - caught at read
// 21005: message - no DOCTYPE - caught at read
// 21006: message format - caught at read


START_CONSTRAINT (21007, Constraint, c)
{
  //only applies to level 3
  pre( c.getLevel() > 2        );

  // c must have exactly one math
  inv( c.isSetMath() );

}
END_CONSTRAINT



//Reaction validation

START_CONSTRAINT (21101, Reaction, r)
{
  //msg =
  //  "A <reaction> definition must contain at least one <speciesReference>, "
  //  "either in its <listOfReactants> or its <listOfProducts>. A reaction "
  //  "without any reactant or product species is not permitted, regardless of "
  //  "whether the reaction has any modifier species. (References: L2V2 "
  //  "Section 4.13.1; L2V3 Section 4.13.3.)";

  inv( r.getNumReactants() > 0 || r.getNumProducts() > 0 );
}
END_CONSTRAINT


// 21102: ordering - caught at read
// 21103: non empty listOf - caught at read
// 21104: listOfReactants/Products must be speciesReference - caught at read
// 21105: listOfModifiers must be ModifierSppeciesreference - caught at read 

START_CONSTRAINT (21107, Reaction, r)
{
  pre (r.getLevel() > 2);
  pre (r.isSetCompartment());

  inv( m.getCompartment(r.getCompartment()) != NULL );
}
END_CONSTRAINT



// SpeciesReference Validation

START_CONSTRAINT (21111, SpeciesReference, sr)
{
  msg =
    "Species '" + sr.getSpecies() + "' is undefined. ";
    //"The value of a <speciesReference> 'species' attribute must be the "
    //"identifier of an existing <species> in the model. (References: L2V1 "
    //"Section 4.9.5; L2V2 Section 4.13.2. L2V3 Section 4.13.3.)";

  inv( m.getSpecies( sr.getSpecies() ) != NULL );
}
END_CONSTRAINT

// 21112 - repeat of 20611

START_CONSTRAINT (21113, SpeciesReference, sr)
{
  pre (sr.getLevel() > 1);

  /* doesnt apply if the SpeciesReference is a modifier */
  pre(!sr.isModifier());
  pre( sr.isSetStoichiometryMath()  );

  //msg =
  //  "A <speciesReference> must not have a value for both 'stoichiometry' and "
  //  "'stoichiometryMath'; they are mutually exclusive. (References: L2V1 "
  //  "Section 4.9.5; L2V2 Section 4.13.3; L2V3 Section 4.13.3.)";


  inv( !sr.isSetStoichiometry() );
}
END_CONSTRAINT


// KineticLaw validation

EXTERN_CONSTRAINT(21121, KineticLawVars)


// 21122: ordering - caught at read
// 21123: non empty list - caught at read


START_CONSTRAINT (21124, KineticLaw, kl)
{
  pre(kl.getLevel() > 1);

  pre(kl.getNumParameters() != 0);

  //msg =
  //  "The 'constant' attribute on a <parameter> local to a <kineticLaw> cannot "
  //  "have a value other than 'true'. The values of parameters local to "
  //  "<kineticLaw> definitions cannot be changed, and therefore they are "
  //  "always constant. (References: L2V2 Section 4.9.4; L2V3 Section 4.9.4.)";

  for (unsigned int n = 0; n < kl.getNumParameters(); ++n)
  {
    inv(kl.getParameter(n)->getConstant() == true);
  }
}
END_CONSTRAINT


START_CONSTRAINT (21125, KineticLaw, kl)
{
  pre( kl.getLevel() > 1);
  if (kl.getLevel() == 2)
  {
    pre( kl.getVersion() > 1 );
  }
  //msg =
  //  "The 'substanceUnits' attribute on <kineticLaw>, previously available in "
  //  "SBML Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
  //  "Version 2. In SBML Level 2 Version 2, the substance units of a reaction "
  //  "rate expression are those of the global 'substance' units of the model. "
  //  "(References: L2V2 Section 4.13.5.)";

  inv( kl.isSetSubstanceUnits() == false );
}
END_CONSTRAINT


START_CONSTRAINT (21126, KineticLaw, kl)
{
  pre( kl.getLevel() > 1);
  if (kl.getLevel() == 2)
  {
    pre( kl.getVersion() > 1 );
  }
  //msg =
  //  "The 'timeUnits' attribute on <kineticLaw>, previously available in SBML "
  //  "Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
  //  "Version 2. In SBML Level 2 Version 2, the time units of a reaction rate "
  //  "expression are those of the global 'time' units of the model. "
  //  "(References: L2V2 Section 4.13.5.)";

  inv( kl.isSetTimeUnits() == false );
}
END_CONSTRAINT

START_CONSTRAINT (21130, KineticLaw, kl)
{
  pre( kl.getLevel() > 1        );

  // fd must have exactly one math
  inv( kl.isSetMath() );

}
END_CONSTRAINT



START_CONSTRAINT (99127, KineticLaw, kl)
{
  pre( kl.getLevel() == 1 || (kl.getLevel() == 2 && kl.getVersion() == 1));
  pre( kl.isSetSubstanceUnits() );
  
  //msg =
  //  "A KineticLaw's substanceUnits must be 'substance', 'item', 'mole', or "
  //  "the id of a UnitDefinition that defines a variant of 'item' or 'mole' "
  //  "(L2v1 Section 4.9.7).";


  const string&         units = kl.getSubstanceUnits();
  const UnitDefinition* defn  = m.getUnitDefinition(units);

    inv_or( units == "substance" );
    inv_or( units == "item"      );
    inv_or( units == "mole"      );
    inv_or( defn  != NULL && defn->isVariantOfSubstance() );
}
END_CONSTRAINT


START_CONSTRAINT (99128, KineticLaw, kl)
{
  pre( kl.getLevel() == 1 || (kl.getLevel() == 2 && kl.getVersion() == 1));
  pre( kl.isSetTimeUnits() );

  //msg =
  //  "A KineticLaw's timeUnits must be 'time', 'second', or the id of a "
  //  "UnitDefnition that defines a variant of 'second' with exponent='1' "
  //  "(L2v1 Section 4.9.7).";


  const string&         units = kl.getTimeUnits();
  const UnitDefinition* defn  = m.getUnitDefinition(units);

  inv_or( units == "time"   );
  inv_or( units == "second" );
  inv_or( defn  != NULL && defn->isVariantOfTime() );
}
END_CONSTRAINT

START_CONSTRAINT (99129, KineticLaw, kl)
{
  pre (m.getLevel() == 1);
  pre (kl.isSetFormula() == 1);

  FormulaTokenizer_t * ft = 
                 FormulaTokenizer_createFromFormula (kl.getFormula().c_str());
  Token_t * t = FormulaTokenizer_nextToken (ft);

  const Compartment * c;
  const Species * s;
  const Parameter * p, * p1;

  /* loop through each token of the formula
   * if it has type TT_NAME then it is either the id of some component
   * of the model or the name of a function in which case 
   * need to check whether it is defined
   */
  bool fail = false;
  while (t->type != TT_END)
  {
    if (t->type == TT_NAME)
    {
      c = m.getCompartment(t->value.name);
      s = m.getSpecies    (t->value.name);
      p = m.getParameter  (t->value.name);
      p1 = kl.getParameter(t->value.name);

      if (c == NULL && s == NULL && p == NULL && p1 == NULL)
      {
        fail = true;
        /* defined functions */
        if ((strcmp(t->value.name, "abs") == 0)
        || (strcmp(t->value.name, "acos") == 0)
        || (strcmp(t->value.name, "asin") == 0)
        || (strcmp(t->value.name, "atan") == 0)
        || (strcmp(t->value.name, "ceil") == 0)
        || (strcmp(t->value.name, "cos") == 0)
        || (strcmp(t->value.name, "exp") == 0)
        || (strcmp(t->value.name, "floor") == 0)
        || (strcmp(t->value.name, "log") == 0)
        || (strcmp(t->value.name, "log10") == 0)
        || (strcmp(t->value.name, "pow") == 0)
        || (strcmp(t->value.name, "sqr") == 0)
        || (strcmp(t->value.name, "sqrt") == 0)
        || (strcmp(t->value.name, "sin") == 0)
        || (strcmp(t->value.name, "tan") == 0)
        /* predefined rate laws */
        || (strcmp(t->value.name, "mass") == 0)
        || (strcmp(t->value.name, "uui") == 0)
        || (strcmp(t->value.name, "uur") == 0)
        || (strcmp(t->value.name, "uuhr") == 0)
        || (strcmp(t->value.name, "isouur") == 0)
        || (strcmp(t->value.name, "hilli") == 0)
        || (strcmp(t->value.name, "hillr") == 0)
        || (strcmp(t->value.name, "hillmr") == 0)
        || (strcmp(t->value.name, "hillmmr") == 0)
        || (strcmp(t->value.name, "usii") == 0)
        || (strcmp(t->value.name, "usir") == 0)
        || (strcmp(t->value.name, "uai") == 0)
        || (strcmp(t->value.name, "ucii") == 0)
        || (strcmp(t->value.name, "ucir") == 0)
        || (strcmp(t->value.name, "unii") == 0)
        || (strcmp(t->value.name, "unir") == 0)
        || (strcmp(t->value.name, "uuci") == 0)
        || (strcmp(t->value.name, "uucr") == 0)
        || (strcmp(t->value.name, "umi") == 0)
        || (strcmp(t->value.name, "umr") == 0)
        || (strcmp(t->value.name, "uaii") == 0)
        || (strcmp(t->value.name, "uar") == 0)
        || (strcmp(t->value.name, "ucti") == 0)
        || (strcmp(t->value.name, "uctr") == 0)
        || (strcmp(t->value.name, "umai") == 0)
        || (strcmp(t->value.name, "umar") == 0)
        || (strcmp(t->value.name, "uhmi") == 0)
        || (strcmp(t->value.name, "uhmr") == 0)
        || (strcmp(t->value.name, "ualii") == 0)
        || (strcmp(t->value.name, "ordubr") == 0)
        || (strcmp(t->value.name, "ordbur") == 0)
        || (strcmp(t->value.name, "ordbbr") == 0)
        || (strcmp(t->value.name, "ppbr") == 0))
        {
          fail = false;
        }
      }
    }

    inv (fail == false);
    t = FormulaTokenizer_nextToken(ft);
  }
}
END_CONSTRAINT


START_CONSTRAINT (99129, AssignmentRule, ar)
{
  pre (m.getLevel() == 1);
  pre (ar.isSetFormula() == 1);

  //msg =
  //  "In a Level 1 model only predefined functions are permitted "
  //   "within the KineticLaw formula. (L1V2 Appendix C)";


  FormulaTokenizer_t * ft = 
    FormulaTokenizer_createFromFormula (ar.getFormula().c_str());
  Token_t * t = FormulaTokenizer_nextToken (ft);

  const Compartment * c;
  const Species * s;
  const Parameter * p;

  /* loop through each token of the formula
   * if it has type TT_NAME then it is either the id of some component
   * of the model or the name of a function in which case 
   * need to check whether it is defined
   */
  bool fail = false;
  while (t->type != TT_END)
  {
    if (t->type == TT_NAME)
    {
      c = m.getCompartment(t->value.name);
      s = m.getSpecies    (t->value.name);
      p = m.getParameter  (t->value.name);

      if (c == NULL && s == NULL && p == NULL)
      {
        fail = true;
        /* defined functions */
        if ((strcmp(t->value.name, "abs") == 0)
        || (strcmp(t->value.name, "acos") == 0)
        || (strcmp(t->value.name, "asin") == 0)
        || (strcmp(t->value.name, "atan") == 0)
        || (strcmp(t->value.name, "ceil") == 0)
        || (strcmp(t->value.name, "cos") == 0)
        || (strcmp(t->value.name, "exp") == 0)
        || (strcmp(t->value.name, "floor") == 0)
        || (strcmp(t->value.name, "log") == 0)
        || (strcmp(t->value.name, "log10") == 0)
        || (strcmp(t->value.name, "pow") == 0)
        || (strcmp(t->value.name, "sqr") == 0)
        || (strcmp(t->value.name, "sqrt") == 0)
        || (strcmp(t->value.name, "sin") == 0)
        || (strcmp(t->value.name, "tan") == 0)
        /* predefined rate laws */
        || (strcmp(t->value.name, "mass") == 0)
        || (strcmp(t->value.name, "uui") == 0)
        || (strcmp(t->value.name, "uur") == 0)
        || (strcmp(t->value.name, "uuhr") == 0)
        || (strcmp(t->value.name, "isouur") == 0)
        || (strcmp(t->value.name, "hilli") == 0)
        || (strcmp(t->value.name, "hillr") == 0)
        || (strcmp(t->value.name, "hillmr") == 0)
        || (strcmp(t->value.name, "hillmmr") == 0)
        || (strcmp(t->value.name, "usii") == 0)
        || (strcmp(t->value.name, "usir") == 0)
        || (strcmp(t->value.name, "uai") == 0)
        || (strcmp(t->value.name, "ucii") == 0)
        || (strcmp(t->value.name, "ucir") == 0)
        || (strcmp(t->value.name, "unii") == 0)
        || (strcmp(t->value.name, "unir") == 0)
        || (strcmp(t->value.name, "uuci") == 0)
        || (strcmp(t->value.name, "uucr") == 0)
        || (strcmp(t->value.name, "umi") == 0)
        || (strcmp(t->value.name, "umr") == 0)
        || (strcmp(t->value.name, "uaii") == 0)
        || (strcmp(t->value.name, "uar") == 0)
        || (strcmp(t->value.name, "ucti") == 0)
        || (strcmp(t->value.name, "uctr") == 0)
        || (strcmp(t->value.name, "umai") == 0)
        || (strcmp(t->value.name, "umar") == 0)
        || (strcmp(t->value.name, "uhmi") == 0)
        || (strcmp(t->value.name, "uhmr") == 0)
        || (strcmp(t->value.name, "ualii") == 0)
        || (strcmp(t->value.name, "ordubr") == 0)
        || (strcmp(t->value.name, "ordbur") == 0)
        || (strcmp(t->value.name, "ordbbr") == 0)
        || (strcmp(t->value.name, "ppbr") == 0))
        {
          fail = false;
        }
      }
    }

    inv (fail == false);
    t = FormulaTokenizer_nextToken(ft);
  }
}
END_CONSTRAINT


START_CONSTRAINT (99129, RateRule, rr)
{
  pre (m.getLevel() == 1);
  pre (rr.isSetFormula() == 1);

  //msg =
  //  "In a Level 1 model only predefined functions are permitted "
  //   "within the KineticLaw formula. (L1V2 Appendix C)";


  FormulaTokenizer_t * ft = 
    FormulaTokenizer_createFromFormula (rr.getFormula().c_str());
  Token_t * t = FormulaTokenizer_nextToken (ft);

  const Compartment * c;
  const Species * s;
  const Parameter * p;

  /* loop through each token of the formula
   * if it has type TT_NAME then it is either the id of some component
   * of the model or the name of a function in which case 
   * need to check whether it is defined
   */
  bool fail = false;
  while (t->type != TT_END)
  {
    if (t->type == TT_NAME)
    {
      c = m.getCompartment(t->value.name);
      s = m.getSpecies    (t->value.name);
      p = m.getParameter  (t->value.name);

      if (c == NULL && s == NULL && p == NULL)
      {
        fail = true;
        /* defined functions */
        if ((strcmp(t->value.name, "abs") == 0)
        || (strcmp(t->value.name, "acos") == 0)
        || (strcmp(t->value.name, "asin") == 0)
        || (strcmp(t->value.name, "atan") == 0)
        || (strcmp(t->value.name, "ceil") == 0)
        || (strcmp(t->value.name, "cos") == 0)
        || (strcmp(t->value.name, "exp") == 0)
        || (strcmp(t->value.name, "floor") == 0)
        || (strcmp(t->value.name, "log") == 0)
        || (strcmp(t->value.name, "log10") == 0)
        || (strcmp(t->value.name, "pow") == 0)
        || (strcmp(t->value.name, "sqr") == 0)
        || (strcmp(t->value.name, "sqrt") == 0)
        || (strcmp(t->value.name, "sin") == 0)
        || (strcmp(t->value.name, "tan") == 0)
        /* predefined rate laws */
        || (strcmp(t->value.name, "mass") == 0)
        || (strcmp(t->value.name, "uui") == 0)
        || (strcmp(t->value.name, "uur") == 0)
        || (strcmp(t->value.name, "uuhr") == 0)
        || (strcmp(t->value.name, "isouur") == 0)
        || (strcmp(t->value.name, "hilli") == 0)
        || (strcmp(t->value.name, "hillr") == 0)
        || (strcmp(t->value.name, "hillmr") == 0)
        || (strcmp(t->value.name, "hillmmr") == 0)
        || (strcmp(t->value.name, "usii") == 0)
        || (strcmp(t->value.name, "usir") == 0)
        || (strcmp(t->value.name, "uai") == 0)
        || (strcmp(t->value.name, "ucii") == 0)
        || (strcmp(t->value.name, "ucir") == 0)
        || (strcmp(t->value.name, "unii") == 0)
        || (strcmp(t->value.name, "unir") == 0)
        || (strcmp(t->value.name, "uuci") == 0)
        || (strcmp(t->value.name, "uucr") == 0)
        || (strcmp(t->value.name, "umi") == 0)
        || (strcmp(t->value.name, "umr") == 0)
        || (strcmp(t->value.name, "uaii") == 0)
        || (strcmp(t->value.name, "uar") == 0)
        || (strcmp(t->value.name, "ucti") == 0)
        || (strcmp(t->value.name, "uctr") == 0)
        || (strcmp(t->value.name, "umai") == 0)
        || (strcmp(t->value.name, "umar") == 0)
        || (strcmp(t->value.name, "uhmi") == 0)
        || (strcmp(t->value.name, "uhmr") == 0)
        || (strcmp(t->value.name, "ualii") == 0)
        || (strcmp(t->value.name, "ordubr") == 0)
        || (strcmp(t->value.name, "ordbur") == 0)
        || (strcmp(t->value.name, "ordbbr") == 0)
        || (strcmp(t->value.name, "ppbr") == 0))
        {
          fail = false;
        }
      }
    }

    inv (fail == false);
    t = FormulaTokenizer_nextToken(ft);
  }
}
END_CONSTRAINT


// StoichiometryMath validation

EXTERN_CONSTRAINT(21131, StoichiometryMathVars)


// Event validation

START_CONSTRAINT (21201, Event, e)
{
  //msg =
  //  "An <event> object must have a 'trigger'. (References: L2V1 Section "
  //  "4.10.2; L2V2 Section 4.14.)";

  inv( e.isSetTrigger() != 0 );
}
END_CONSTRAINT



START_CONSTRAINT (21202, Trigger, t)
{
  //msg =
  //  "An <event>'s <trigger> expression must evaluate to a value of type "
  //  "boolean. (References: L2V1 Section 4.10.2; L2V2 Section 4.14.1; L2V3 "
  //  "Section 4.14.2.)";

  pre( t.isSetMath() );
  inv( m.isBoolean( t.getMath() ) );
}
END_CONSTRAINT


START_CONSTRAINT (21203, Event, e)
{
  //msg =
  //  "An <event> object must have at least one <eventAssignment> object in "
  //  "its <listOfEventAssignments>. (References: L2V1 Section 4.10.5; L2V2 "
  //  "Section 4.14; L2V3 Section 4.14.)";

  // in L3 it is not compulsory to have a listOfEventAssignments
  pre(e.getLevel() < 3);

  inv( e.getNumEventAssignments() != 0 );
}
END_CONSTRAINT


START_CONSTRAINT (21204, Event, e)
{
  pre (e.getLevel() == 2 && e.getVersion() < 3);
  pre( e.isSetTimeUnits() );

  //msg =
  //  "The value of an <event>'s 'timeUnits' attribute must be 'time', 'second', "
  //  "'dimensionless', or the identifier of a <unitDefinition> derived from "
  //  "either 'second' (with an 'exponent' value of '1') or 'dimensionless'. "
  //  "(References: L2V1 Section 4.10.4; L2V2 Section 4.14.)";

  // does not apply to L2V3 models

  const string&         units = e.getTimeUnits();
  const UnitDefinition* defn  = m.getUnitDefinition(units);

  /* dimensionless is allowable in L2V2 */
  if (e.getVersion() == 2)
  {
    inv_or( units == "time" );
    inv_or( units == "second"  );
    inv_or( units == "dimensionless"  );
    inv_or( defn  != NULL && defn->isVariantOfTime() );
    inv_or( defn  != NULL && defn->isVariantOfDimensionless() );
  }
  else
  {
    inv_or( units == "time"   );
    inv_or( units == "second" );
    inv_or( defn  != NULL && defn->isVariantOfTime() );
  }
}
END_CONSTRAINT


// 21205: ordering - caught at read


// FIXME

START_CONSTRAINT (99206, Event, e)
{
  pre (e.getLevel() > 1);
  if (e.getLevel() == 2)
  {
    pre (e.getVersion() > 2);
  }
  //msg =
  //  "The 'timeUnits' attribute on <event>, previously available in SBML "
  //  "Level 2 versions prior to Version 3, has been removed as of SBML "
  //  "Level 2 Version 3. (References: L2V3 Section 4.14.)";

  inv( e.isSetTimeUnits() == false);

}
END_CONSTRAINT


START_CONSTRAINT (21206, Event, e)
{
  pre (e.getLevel() > 1);
  if (e.getLevel() == 2)
  {
    pre (e.getVersion() > 3);
  }
  
  pre (e.getUseValuesFromTriggerTime() == false);
  
  inv( e.isSetDelay() == true);

}
END_CONSTRAINT


START_CONSTRAINT (21207, Event, e)
{
  pre(e.getLevel() == 3);
  pre(e.isSetDelay());

  inv( e.isSetUseValuesFromTriggerTime() != 0 );
}
END_CONSTRAINT



START_CONSTRAINT (21209, Trigger, t)
{
  //only applies to level 3
  pre( t.getLevel() > 2        );

  // fd must have exactly one math
  inv( t.isSetMath() );

}
END_CONSTRAINT


START_CONSTRAINT (21210, Delay, d)
{
  //only applies to level 3
  pre( d.getLevel() > 2        );

  // fd must have exactly one math
  inv( d.isSetMath() );

}
END_CONSTRAINT



//EventAssignment validation

START_CONSTRAINT (21211, EventAssignment, ea)
{
  pre( ea.isSetVariable() );

  //msg = 
  //  "The value of 'variable' in an <eventAssignment> can only be the "
  //  "identifier of a <compartment>, <species>, or model-wide <parameter> "
  //  "definition. (References: L2V1 Section 4.10.5; L2V2 Section 4.14.2; "
  //  "L2V3 Section 4.14.4.)";


  const string& id = ea.getVariable();

  if (ea.getLevel() == 2)
  {
    inv_or( m.getCompartment(id) );
    inv_or( m.getSpecies    (id) );
    inv_or( m.getParameter  (id) );
  }
  else
  {
    inv_or( m.getCompartment(id) );
    inv_or( m.getSpecies    (id) );
    inv_or( m.getParameter  (id) );
    inv_or( m.getSpeciesReference  (id) );
  }
}
END_CONSTRAINT


START_CONSTRAINT (21212, EventAssignment, ea)
{
 pre( ea.isSetVariable() );

  //msg =
  //  "Any <compartment>, <species> or <parameter> definition whose identifier "
  //  "is used as the value of 'variable' in an <eventAssignment> must have a "
  //  "value of 'false' for its 'constant' attribute. (References: L2V1 Section "
  //  "4.10.5; L2V2 Section 4.14.2; L2V3 Section 4.14.4.)";

  const string& id = ea.getVariable();

  const Compartment* c = m.getCompartment(id);
  const Species*     s = m.getSpecies    (id);
  const Parameter*   p = m.getParameter  (id);

  pre( c || s || p );

  inv_or( c && c->getConstant() == false );
  inv_or( s && s->getConstant() == false );
  inv_or( p && p->getConstant() == false );
}
END_CONSTRAINT

START_CONSTRAINT (21213, EventAssignment, ea)
{
  //only applies to level 3
  pre( ea.getLevel() > 2        );

  // fd must have exactly one math
  inv( ea.isSetMath() );

}
END_CONSTRAINT

START_CONSTRAINT (21231, Priority, p)
{
  //only applies to level 3
  pre( p.getLevel() > 2        );

  // priority must have exactly one math
  inv( p.isSetMath() );

}
END_CONSTRAINT



/** @endcond */


