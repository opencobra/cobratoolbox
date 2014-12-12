/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    IdentifierConsistencyConstraints.cpp
 * @brief   IdentifierConsistency check constraints.  See SBML Wiki
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

#include <sbml/validator/VConstraint.h>

#include "UniqueIdsForUnitDefinitions.h"
#include "UniqueIdsInKineticLaw.h"
#include "UniqueIdsInModel.h"
#include "UniqueVarsInEventAssignments.h"
#include "UniqueVarsInRules.h"
#include "UniqueVarsInEventsAndRules.h"
#include "UniqueMetaId.h"


#endif


#include <sbml/validator/ConstraintMacros.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */


// General Identifier validation 
EXTERN_CONSTRAINT( 10301, UniqueIdsInModel             )
EXTERN_CONSTRAINT( 10302, UniqueIdsForUnitDefinitions  )
EXTERN_CONSTRAINT( 10303, UniqueIdsInKineticLaw        )
EXTERN_CONSTRAINT( 10304, UniqueVarsInRules            )
EXTERN_CONSTRAINT( 10305, UniqueVarsInEventAssignments )
EXTERN_CONSTRAINT( 10306, UniqueVarsInEventsAndRules   )
EXTERN_CONSTRAINT( 10307, UniqueMetaId                 )

// 10308: SBO term - caught at read
// 10309: syntax of metid - caught at read but not finished TO DO
// 10310: syntax of id - caught at read
// 10311: syntax of UnitSId - caught at read

START_CONSTRAINT (99303, Parameter, p)
{
  pre( p.isSetUnits() );

  const string& units = p.getUnits();

  msg = "The units '";
  msg += units;
  msg+= "'of the <parameter> '";
  msg += p.getId() ;
  msg += "' do not refer to a valid unit kind/built-in unit ";
  msg += "or the identifier of an existing <unitDefinition>. ";
 
  inv_or( Unit::isUnitKind(units, p.getLevel(), p.getVersion())    );
  inv_or( Unit::isBuiltIn(units, p.getLevel())     );
  inv_or( m.getUnitDefinition(units) );
}
END_CONSTRAINT


START_CONSTRAINT (99303, Species, s)
{
  bool failed = false;

  msg = "";

  if ( s.isSetSubstanceUnits() == true)
  {

    const string& units = s.getSubstanceUnits();

    if (Unit::isUnitKind(units, s.getLevel(), s.getVersion()) == false
      && Unit::isBuiltIn(units, s.getLevel()) == false
      && m.getUnitDefinition(units) == NULL)
    {
      msg += "\nThe subtanceUnits '";
      msg += units;
      msg += "'of the <species> do not refer to a valid unit kind ";
      msg += "or the identifier of an existing <unitDefinition>. ";
      failed = true;
    }
  }

  if ( s.isSetSpatialSizeUnits() == true)
  {

    const string& units = s.getSpatialSizeUnits();

    if (Unit::isUnitKind(units, s.getLevel(), s.getVersion()) == false
      && Unit::isBuiltIn(units, s.getLevel()) == false
      && m.getUnitDefinition(units) == NULL)
    {
      msg += "\nThe spatialSizeUnits '";
      msg += units;
      msg += "'of the <species> do not refer to a valid unit kind ";
      msg += "or the identifier of an existing <unitDefinition>. ";
      failed = true;
    }
  }
   
  inv(failed == false);
}
END_CONSTRAINT


START_CONSTRAINT (99303, Compartment, c)
{
  pre( c.isSetUnits() );

  const string& units = c.getUnits();

  msg = "The units '";
  msg += units;
  msg+= "'of the <compartment> '";
  msg += c.getId() ;
  msg += "' do not refer to a valid unit kind/built-in unit ";
  msg += "or the identifier of an existing <unitDefinition>. ";
 
  inv_or( Unit::isUnitKind(units, c.getLevel(), c.getVersion())    );
  inv_or( Unit::isBuiltIn(units, c.getLevel())     );
  inv_or( m.getUnitDefinition(units) );
}
END_CONSTRAINT


START_CONSTRAINT (99303, KineticLaw, kl)
{
  bool failed = false;

  msg = "";

  if ( kl.isSetSubstanceUnits() == true)
  {

    const string& units = kl.getSubstanceUnits();

    if (Unit::isUnitKind(units, kl.getLevel(), kl.getVersion()) == false
      && Unit::isBuiltIn(units, kl.getLevel()) == false
      && m.getUnitDefinition(units) == NULL)
    {
      msg += "\nThe subtanceUnits '";
      msg += units;
      msg += "'of the <kineticLaw> do not refer to a valid unit kind ";
      msg += "or the identifier of an existing <unitDefinition>. ";
      failed = true;
    }
  }

  if ( kl.isSetTimeUnits() == true)
  {

    const string& units = kl.getTimeUnits();

    if (Unit::isUnitKind(units, kl.getLevel(), kl.getVersion()) == false
      && Unit::isBuiltIn(units, kl.getLevel()) == false
      && m.getUnitDefinition(units) == NULL)
    {
      msg += "\nThe timeUnits '";
      msg += units;
      msg += "'of the <kineticLaw> do not refer to a valid unit kind ";
      msg += "or the identifier of an existing <unitDefinition>. ";
      failed = true;
    }
  }
   
  inv(failed == false);
}
END_CONSTRAINT


START_CONSTRAINT (99303, Event, e)
{
  pre( e.isSetTimeUnits() );

  const string& units = e.getTimeUnits();

  msg = "The timeUnits '";
  msg += units;
  msg+= "'of the <event> '";
  msg += e.getId() ;
  msg += "' do not refer to a valid unit kind/built-in unit ";
  msg += "or the identifier of an existing <unitDefinition>. ";
 
  inv_or( Unit::isUnitKind(units, e.getLevel(), e.getVersion())    );
  inv_or( Unit::isBuiltIn(units, e.getLevel())     );
  inv_or( m.getUnitDefinition(units) );
}
END_CONSTRAINT


START_CONSTRAINT (99303, Model, x)
{
  // level 3
  pre( m.getLevel() > 2);

  bool failed = false;

  msg = "";

  if ( m.isSetSubstanceUnits() == true)
  {
    const string& units = m.getSubstanceUnits();
    if (Unit::isUnitKind(units, m.getLevel(), m.getVersion()) == false
      && m.getUnitDefinition(units) == NULL)
    {
      msg += "\nThe subtanceUnits '";
      msg += units;
      msg += "'of the <model> do not refer to a valid unit kind ";
      msg += "or the identifier of an existing <unitDefinition>. ";
      failed = true;
    }
  }

  if ( m.isSetExtentUnits() == true)
  {
    const string& units = m.getExtentUnits();
    if (Unit::isUnitKind(units, m.getLevel(), m.getVersion()) == false
      && m.getUnitDefinition(units) == NULL)
    {
      msg += "\nThe extentUnits '";
      msg += units;
      msg += "'of the <model> do not refer to a valid unit kind ";
      msg += "or the identifier of an existing <unitDefinition>. ";
      failed = true;
    }
  }

  if ( m.isSetTimeUnits() == true)
  {
    const string& units = m.getTimeUnits();
    if (Unit::isUnitKind(units, m.getLevel(), m.getVersion()) == false
      && m.getUnitDefinition(units) == NULL)
    {
      msg += "\nThe timeUnits '";
      msg += units;
      msg += "'of the <model> do not refer to a valid unit kind ";
      msg += "or the identifier of an existing <unitDefinition>. ";
      failed = true;
    }
  }

  if ( m.isSetVolumeUnits() == true)
  {
    const string& units = m.getVolumeUnits();
    if (Unit::isUnitKind(units, m.getLevel(), m.getVersion()) == false
      && m.getUnitDefinition(units) == NULL)
    {
      msg += "\nThe volumeUnits '";
      msg += units;
      msg += "'of the <model> do not refer to a valid unit kind ";
      msg += "or the identifier of an existing <unitDefinition>. ";
      failed = true;
    }
  }

  if ( m.isSetAreaUnits() == true)
  {
    const string& units = m.getAreaUnits();
    if (Unit::isUnitKind(units, m.getLevel(), m.getVersion()) == false
      && m.getUnitDefinition(units) == NULL)
    {
      msg += "\nThe areaUnits '";
      msg += units;
      msg += "'of the <model> do not refer to a valid unit kind ";
      msg += "or the identifier of an existing <unitDefinition>. ";
      failed = true;
    }
  }

  if ( m.isSetLengthUnits() == true)
  {
    const string& units = m.getLengthUnits();
    if (Unit::isUnitKind(units, m.getLevel(), m.getVersion()) == false
      && m.getUnitDefinition(units) == NULL)
    {
      msg += "\nThe lengthUnits '";
      msg += units;
      msg += "'of the <model> do not refer to a valid unit kind ";
      msg += "or the identifier of an existing <unitDefinition>. ";
      failed = true;
    }
  }

  inv(failed == false);
 
}
END_CONSTRAINT




/** @endcond */

