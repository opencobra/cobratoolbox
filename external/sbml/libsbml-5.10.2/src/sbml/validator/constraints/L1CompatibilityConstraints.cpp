/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    L1CompatibilityConstraints.cpp
 * @brief   L1 compatibility for conversion from L2
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
#endif


#include <sbml/validator/ConstraintMacros.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */


START_CONSTRAINT (91001, Model, x)
{
  //msg =
  //  "A model with <event> definitions cannot be represented in SBML Level 1.";

  inv( m.getNumEvents() == 0 );
}
END_CONSTRAINT


START_CONSTRAINT (91002, Model, x)
{
  //msg =
  //  "Conversion of a model with <functionDefinition>s to SBML Level 1 is not "
  //  "yet supported.";

  inv( m.getNumFunctionDefinitions() == 0 );
}
END_CONSTRAINT


START_CONSTRAINT (91003, Model, x)
{
  //msg =
  //  "Conversion of a model with <constraint>s to SBML Level 1 may result "
  //  "in loss of information.";

  inv( m.getNumConstraints() == 0 );
}
END_CONSTRAINT


START_CONSTRAINT (91004, Model, x)
{
  //msg =
  //  "Conversion of a model with <initialAssignment>s to SBML Level 1 is not "
  //  "yet supported.";

  inv( m.getNumInitialAssignments() == 0 );
}
END_CONSTRAINT


START_CONSTRAINT (91005, Model, x)
{
  //msg =
  //  "<speciesType> definitions cannot be represented in SBML Level 1.";

  inv( m.getNumSpeciesTypes() == 0 );
}
END_CONSTRAINT


START_CONSTRAINT (91006, Model, x)
{
  //msg =
  //  "<compartmentType> definitions cannot be represented in SBML Level 1.";

  inv( m.getNumCompartmentTypes() == 0 );
}
END_CONSTRAINT


START_CONSTRAINT (91007, Compartment, c)
{
  //msg =
  //  "A <compartment> with 'spatialDimensions' not equal to 3 cannot be "
  //  "represented in SBML Level 1.";

  inv( c.getSpatialDimensions() == 3 );
}
END_CONSTRAINT


START_CONSTRAINT (91008, SpeciesReference, sr) 
{
  //msg =
  //  "A <speciesReference> containing a non-integer or non-rational "
  //  "<stoichiometryMath> subelement cannot be represented in SBML Level 1.";

  /* doesnt apply if the SpeciesReference is a modifier */
  pre(!sr.isModifier());

  if (sr.isSetStoichiometryMath() )
  {
    inv_or( sr.getStoichiometryMath()->getMath()->isInteger()  );
    inv_or( sr.getStoichiometryMath()->getMath()->isRational() );
  }
  else if (sr.getLevel() > 2)
  {
    inv( sr.getConstant());
  }
}
END_CONSTRAINT


START_CONSTRAINT (91009, SpeciesReference, sr)
{
  //msg =
  //  "A <speciesReference> containing a non-integer 'stoichiometry' attribute "
  //  "value cannot be represented in SBML Level 1.";
  
  /* doesnt apply if the SpeciesReference is a modifier */
  pre(!sr.isModifier());
  pre( !sr.isSetStoichiometryMath() );

  inv( floor(sr.getStoichiometry()) == sr.getStoichiometry() );
}
END_CONSTRAINT


START_CONSTRAINT (91010, Unit, u)
{
  //msg =
  //  "A <unit> containing multipliers or offsets cannot be represented in "
  //  "SBML Level 1.";


  inv( u.getMultiplier() == 1.0 );
  inv( u.getOffset() == 0.0 );
}
END_CONSTRAINT


START_CONSTRAINT (91011, Species, s)
{
  //msg =
  //  "A <species> that does not identify its compartment cannot be "
  //  "represented in SBML Level 1.";


  inv( s.isSetCompartment() );
}
END_CONSTRAINT


START_CONSTRAINT (91012, Species, s)
{
  //msg =
  //  "The information represented by the value of a 'spatialSizeUnit' "
  //  "attribute on a <species> definition cannot be represented in "
  //  "SBML Level 1.";


  inv( !s.isSetSpatialSizeUnits() );
}
END_CONSTRAINT


START_CONSTRAINT (91013, Model, x)
{
  //msg =
  //  "SBO terms cannot be represented directly in SBML Level 1.";

  inv( m.getSBOTerm() == -1 );
}
END_CONSTRAINT


START_CONSTRAINT (91013, UnitDefinition, ud)
{
  //msg =
  //  "SBO terms cannot be represented directly in SBML Level 1.";

  inv( ud.getSBOTerm() == -1 );
}
END_CONSTRAINT


START_CONSTRAINT (91013, Unit, u)
{
  //msg =
  //  "SBO terms cannot be represented directly in SBML Level 1.";

  inv( u.getSBOTerm() == -1 );
}
END_CONSTRAINT


START_CONSTRAINT (91013, Compartment, c)
{
  //msg =
  //  "SBO terms cannot be represented directly in SBML Level 1.";

  inv( c.getSBOTerm() == -1 );
}
END_CONSTRAINT


START_CONSTRAINT (91013, Species, s)
{
  //msg =
  //  "SBO terms cannot be represented directly in SBML Level 1.";

  inv( s.getSBOTerm() == -1 );
}
END_CONSTRAINT


START_CONSTRAINT (91013, Parameter, p)
{
  //msg =
  //  "SBO terms cannot be represented directly in SBML Level 1.";

  inv( p.getSBOTerm() == -1 );
}
END_CONSTRAINT


START_CONSTRAINT (91013, AssignmentRule, r)
{
  //msg =
  //  "SBO terms cannot be represented directly in SBML Level 1.";

  inv( r.getSBOTerm() == -1 );
}
END_CONSTRAINT


START_CONSTRAINT (91013, RateRule, r)
{
  //msg =
  //  "SBO terms cannot be represented directly in SBML Level 1.";

  inv( r.getSBOTerm() == -1 );
}
END_CONSTRAINT


START_CONSTRAINT (91013, AlgebraicRule, r)
{
  //msg =
  //  "SBO terms cannot be represented directly in SBML Level 1.";

  inv( r.getSBOTerm() == -1 );
}
END_CONSTRAINT


START_CONSTRAINT (91013, Reaction, r)
{
  //msg =
  //  "SBO terms cannot be represented directly in SBML Level 1.";

  inv( r.getSBOTerm() == -1 );
}
END_CONSTRAINT


START_CONSTRAINT (91013, SpeciesReference, sr)
{
  //msg =
  //  "SBO terms cannot be represented directly in SBML Level 1.";

  inv( sr.getSBOTerm() == -1 );
}
END_CONSTRAINT


START_CONSTRAINT (91013, KineticLaw, kl)
{
  //msg =
  //  "SBO terms cannot be represented directly in SBML Level 1.";

  inv( kl.getSBOTerm() == -1 );
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


START_CONSTRAINT (99926, Compartment, c)
{
  pre (c.getLevel() > 2);

  inv( c.isSetSpatialDimensions() == true );
}
END_CONSTRAINT


START_CONSTRAINT (91019, Species, s)
{
  inv( s.getHasOnlySubstanceUnits() == false );
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


START_CONSTRAINT (91020, InitialAssignment, ia)
{
  pre (ia.isSetMath() == true);

  List * names = ia.getMath()
                     ->getListOfNodes((ASTNodePredicate) ASTNode_isAvogadro);

  inv( names->getSize() == 0 );
  delete names;
}
END_CONSTRAINT


/** @endcond */
