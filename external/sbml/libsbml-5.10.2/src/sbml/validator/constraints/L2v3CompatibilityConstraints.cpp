/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    L2v3CompatibilityConstraints.cpp
 * @brief   L2v3 compatibility for conversion
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
 * ---------------------------------------------------------------------- -->*/

#ifndef AddingConstraintsToValidator
#include <sbml/SBase.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>
#include <sbml/AlgebraicRule.h>
#include <sbml/validator/VConstraint.h>
#include <math.h>
#include <sbml/util/List.h>
#include "DuplicateTopLevelAnnotation.h"
#endif


#include <sbml/validator/ConstraintMacros.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */


START_CONSTRAINT (94001, Unit, u)
{
  //msg =
  //  "The 'offset' attribute on <unit> previously available in SBML Level 2 "
  //  "Version 1, has been removed as of SBML Level 2 Version 2. (References: "
  //  "L2V2 Section 4.4.)";

  inv( u.getOffset() == 0.0 );
}
END_CONSTRAINT

START_CONSTRAINT (94002, KineticLaw, kl)
{
  //msg =
  //  "The 'timeUnits' attribute on <kineticLaw>, previously available in SBML "
  //  "Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
  //  "Version 2. In SBML Level 2 Version 3, the time units of a reaction rate "
  //  "expression are those of the global 'time' units of the model. "
  //  "(References: L2V2 Section 4.13.5.)";

  inv( kl.isSetTimeUnits() == false );
}
END_CONSTRAINT

START_CONSTRAINT (94003, KineticLaw, kl)
{
  //msg =
  //  "The 'substanceUnits' attribute on <kineticLaw>, previously available in "
  //  "SBML Level 1 and Level 2 Version 1, has been removed as of SBML Level 2 "
  //  "Version 2. In SBML Level 2 Version 3, the substance units of a reaction "
  //  "rate expression are those of the global 'substance' units of the model. "
  //  "(References: L2V2 Section 4.13.5.)";

  inv( kl.isSetSubstanceUnits() == false );
}
END_CONSTRAINT

START_CONSTRAINT (94004, Species, s)
{
  //msg =
  //  "The 'spatialSizeUnits' attribute on <species>, previously available "
  //  "in SBML Level 2 versions prior to Version 3, has been removed as "
  //  "of SBML Level 2 Version 3. (References: L2V3 Section 4.8.)";

  inv( s.isSetSpatialSizeUnits() == false);
}
END_CONSTRAINT

START_CONSTRAINT (94005, Event, e)
{
  //msg =
  //  "The 'timeUnits' attribute on <event>, previously available in SBML "
  //  "Level 2 versions prior to Version 3, has been removed as of SBML "
  //  "Level 2 Version 3. (References: L2V3 Section 4.14.)";

  inv( e.isSetTimeUnits() == false);

}
END_CONSTRAINT


START_CONSTRAINT (94006, Event, e)
{
  inv( e.getUseValuesFromTriggerTime() == true);
}
END_CONSTRAINT

START_CONSTRAINT (94007, Model, m1)
{
  // if the model was L2V4 or above the model sbo term will not
  // be valid in l2v3
  pre( m1.getLevel() >1 );
  if (m1.getLevel() == 2)
  {
    pre( m1.getVersion() > 3);
  }

  inv( !m1.isSetSBOTerm());
}
END_CONSTRAINT

EXTERN_CONSTRAINT(94010, DuplicateTopLevelAnnotation)

START_CONSTRAINT (92009, Compartment, c)
{
  inv_or( c.getSpatialDimensions() == 3 );
  inv_or( c.getSpatialDimensions() == 2 );
  inv_or( c.getSpatialDimensions() == 1 );
  inv_or( c.getSpatialDimensionsAsDouble() == 0.0 );
}
END_CONSTRAINT


START_CONSTRAINT (92010, SpeciesReference, sr) 
{
  //msg =
  //  "A <speciesReference> containing a non-integer or non-rational "
  //  "<stoichiometryMath> subelement cannot be represented in SBML Level 1.";

  /* doesnt apply if the SpeciesReference is a modifier */
  pre(!sr.isModifier());

  if (sr.getLevel() > 2)
  {
    inv( sr.getConstant());
  }
}
END_CONSTRAINT


START_CONSTRAINT (91015, Model, x)
{
  pre (m.getLevel() > 2);
  inv( !m.isSetConversionFactor() );
}
END_CONSTRAINT


START_CONSTRAINT (91015, Species, s)
{
  pre (s.getLevel() > 2);
  inv( !s.isSetConversionFactor() );
}
END_CONSTRAINT


START_CONSTRAINT (91016, Reaction, r)
{
  pre (r.getLevel() > 2);
  inv( !r.isSetCompartment() );
}
END_CONSTRAINT


START_CONSTRAINT (91017, Model, x)
{
  pre (m.getLevel() > 2);
  pre (m.isSetExtentUnits());

  std::string extent = m.getExtentUnits();
  const UnitDefinition * ud = m.getUnitDefinition(extent);
  if (ud != NULL)
  {
    UnitDefinition *ud1 = new UnitDefinition(m.getSBMLNamespaces());
    for (unsigned int i = 0; i < ud->getNumUnits(); i++)
    {
      Unit * u = new Unit(m.getSBMLNamespaces());
      u->setKind(ud->getUnit(i)->getKind());
      u->setScale(ud->getUnit(i)->getScale());
      u->setExponent(ud->getUnit(i)->getExponent());
      u->setMultiplier(ud->getUnit(i)->getMultiplier());
      ud1->addUnit(u);
    }
  
    inv( ud1->isVariantOfSubstance());
  }
  else
  {
    inv_or( extent == "mole" );
    inv_or( extent == "item" );
  }
}
END_CONSTRAINT


START_CONSTRAINT (91018, Model, x)
{
  pre (m.getLevel() > 2);

  std::string units;
  bool allCorrect = true;

  if (m.isSetExtentUnits() == true)
  {
    units = m.getExtentUnits();
    if (UnitKind_isValidUnitKindString(units.c_str(), 
                                       m.getLevel(), m.getVersion()) == 0)
    {
      const UnitDefinition * ud = m.getUnitDefinition(units);
      if (ud != NULL)
      {
        if (ud->hasRequiredElements() == false)
        {
          allCorrect = false;
        }
      }
      else
      {
        allCorrect = false;
      }
    }
  }
  if (m.isSetTimeUnits() == true)
  {
    units = m.getTimeUnits();
    if (UnitKind_isValidUnitKindString(units.c_str(), 
                                       m.getLevel(), m.getVersion()) == 0)
    {
      const UnitDefinition * ud = m.getUnitDefinition(units);
      if (ud != NULL)
      {
        if (ud->hasRequiredElements() == false)
        {
          allCorrect = false;
        }
      }
      else
      {
        allCorrect = false;
      }
    }
  }
  if (m.isSetSubstanceUnits() == true)
  {
    units = m.getSubstanceUnits();
    if (UnitKind_isValidUnitKindString(units.c_str(), 
                                       m.getLevel(), m.getVersion()) == 0)
    {
      const UnitDefinition * ud = m.getUnitDefinition(units);
      if (ud != NULL)
      {
        if (ud->hasRequiredElements() == false)
        {
          allCorrect = false;
        }
      }
      else
      {
        allCorrect = false;
      }
    }
  }
  if (m.isSetVolumeUnits() == true)
  {
    units = m.getVolumeUnits();
    if (UnitKind_isValidUnitKindString(units.c_str(), 
                                       m.getLevel(), m.getVersion()) == 0)
    {
      const UnitDefinition * ud = m.getUnitDefinition(units);
      if (ud != NULL)
      {
        if (ud->hasRequiredElements() == false)
        {
          allCorrect = false;
        }
      }
      else
      {
        allCorrect = false;
      }
    }
  }
  if (m.isSetAreaUnits() == true)
  {
    units = m.getAreaUnits();
    if (UnitKind_isValidUnitKindString(units.c_str(), 
                                       m.getLevel(), m.getVersion()) == 0)
    {
      const UnitDefinition * ud = m.getUnitDefinition(units);
      if (ud != NULL)
      {
        if (ud->hasRequiredElements() == false)
        {
          allCorrect = false;
        }
      }
      else
      {
        allCorrect = false;
      }
    }
  }
  if (m.isSetLengthUnits() == true)
  {
    units = m.getLengthUnits();
    if (UnitKind_isValidUnitKindString(units.c_str(), 
                                       m.getLevel(), m.getVersion()) == 0)
    {
      const UnitDefinition * ud = m.getUnitDefinition(units);
      if (ud != NULL)
      {
        if (ud->hasRequiredElements() == false)
        {
          allCorrect = false;
        }
      }
      else
      {
        allCorrect = false;
      }
    }
  }

  inv (allCorrect == true);
}
END_CONSTRAINT


START_CONSTRAINT (92011, Event, e)
{
  pre (e.getLevel() > 2);
  inv( !e.isSetPriority() );
}
END_CONSTRAINT


START_CONSTRAINT (92012, Event, e)
{
  pre (e.getLevel() > 2);
  pre (e.isSetTrigger());

  inv( e.getTrigger()->getPersistent() == true );
}
END_CONSTRAINT


START_CONSTRAINT (92013, Event, e)
{
  pre (e.getLevel() > 2);
  pre (e.isSetTrigger());

  inv( e.getTrigger()->getInitialValue() == true );
}
END_CONSTRAINT


START_CONSTRAINT (99926, Compartment, c)
{
  pre (c.getLevel() > 2);

  inv( c.isSetSpatialDimensions() == true );
}
END_CONSTRAINT


START_CONSTRAINT (91020, Reaction, r)
{
  pre (r.isSetKineticLaw() == true);
  pre (r.getKineticLaw()->isSetMath() == true);

  List * names = r.getKineticLaw()->getMath()
                     ->getListOfNodes((ASTNodePredicate) ASTNode_isAvogadro);

  inv( names->getSize() == 0 );
  delete names;
}
END_CONSTRAINT


START_CONSTRAINT (91020, AssignmentRule, r)
{
  pre (r.isSetMath() == true);

  List * names = r.getMath()
                     ->getListOfNodes((ASTNodePredicate) ASTNode_isAvogadro);

  inv( names->getSize() == 0 );
  delete names;
}
END_CONSTRAINT


START_CONSTRAINT (91020, RateRule, r)
{
  pre (r.isSetMath() == true);

  List * names = r.getMath()
                     ->getListOfNodes((ASTNodePredicate) ASTNode_isAvogadro);

  inv( names->getSize() == 0 );
  delete names;
}
END_CONSTRAINT


START_CONSTRAINT (91020, AlgebraicRule, r)
{
  pre (r.isSetMath() == true);

  List * names = r.getMath()
                     ->getListOfNodes((ASTNodePredicate) ASTNode_isAvogadro);

  inv( names->getSize() == 0 );
  delete names;
}
END_CONSTRAINT


START_CONSTRAINT (91020, EventAssignment, ea)
{
  pre (ea.isSetMath() == true);

  List * names = ea.getMath()
                     ->getListOfNodes((ASTNodePredicate) ASTNode_isAvogadro);

  inv( names->getSize() == 0 );
  delete names;
}
END_CONSTRAINT


START_CONSTRAINT (91020, Trigger, t)
{
  pre (t.isSetMath() == true);

  List * names = t.getMath()
                     ->getListOfNodes((ASTNodePredicate) ASTNode_isAvogadro);

  inv( names->getSize() == 0 );
  delete names;
}
END_CONSTRAINT


START_CONSTRAINT (91020, Delay, d)
{
  pre (d.isSetMath() == true);

  List * names = d.getMath()
                     ->getListOfNodes((ASTNodePredicate) ASTNode_isAvogadro);

  inv( names->getSize() == 0 );
  delete names;
}
END_CONSTRAINT


START_CONSTRAINT (91020, InitialAssignment, ia)
{
  pre (ia.isSetMath() == true);

  List * names = ia.getMath()
                     ->getListOfNodes((ASTNodePredicate) ASTNode_isAvogadro);

  inv( names->getSize() == 0 );
  delete names;
}
END_CONSTRAINT


START_CONSTRAINT (91020, Constraint, c)
{
  pre (c.isSetMath() == true);

  List * names = c.getMath()
                     ->getListOfNodes((ASTNodePredicate) ASTNode_isAvogadro);

  inv( names->getSize() == 0 );
  delete names;
}
END_CONSTRAINT


/** @endcond */

