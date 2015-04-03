/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    SBOConsistencyConstraints.cpp
 * @brief   SBOConsistency check constraints.  See SBML Wiki
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

//#include <string>

#include <sbml/SBMLTypeCodes.h>
#include <sbml/SBO.h>
#include <sbml/validator/VConstraint.h>
#include <sbml/units/UnitFormulaFormatter.h>
#include <sbml/units/FormulaUnitsData.h>
#include <sbml/AssignmentRule.h>
#include <sbml/RateRule.h>
#include <sbml/AlgebraicRule.h>

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

// General SBO validation

START_CONSTRAINT(99701, Model, m1)
{
  pre(m1.getLevel() > 1);
  if (m1.getLevel() == 2) 
  {
    pre( m1.getVersion() > 1);
  }
  pre(m1.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (m1.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (m1.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (m1.getSBOTerm()));
  inv_or(SBO::isInteraction            (m1.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (m1.getSBOTerm()));
  inv_or(SBO::isEntity                 (m1.getSBOTerm()));
  inv_or(SBO::isObselete               (m1.getSBOTerm()));
}
END_CONSTRAINT

START_CONSTRAINT(99701, FunctionDefinition, fd)
{
  pre(fd.getLevel() > 1);
  if (fd.getLevel() == 2) 
  {
    pre( fd.getVersion() > 1);
  }
  pre(fd.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (fd.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (fd.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (fd.getSBOTerm()));
  inv_or(SBO::isInteraction            (fd.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (fd.getSBOTerm()));
  inv_or(SBO::isEntity                 (fd.getSBOTerm()));
  inv_or(SBO::isObselete               (fd.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, Parameter, p)
{
  pre(p.getLevel() > 1);
  if (p.getLevel() == 2) 
  {
    pre( p.getVersion() > 1);
  }
  pre(p.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (p.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (p.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (p.getSBOTerm()));
  inv_or(SBO::isInteraction            (p.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (p.getSBOTerm()));
  inv_or(SBO::isEntity                 (p.getSBOTerm()));
  inv_or(SBO::isObselete               (p.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, InitialAssignment, ia)
{
  pre(ia.getLevel() > 1);
  if (ia.getLevel() == 2) 
  {
    pre( ia.getVersion() > 1);
  }
  pre(ia.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (ia.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (ia.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (ia.getSBOTerm()));
  inv_or(SBO::isInteraction            (ia.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (ia.getSBOTerm()));
  inv_or(SBO::isEntity                 (ia.getSBOTerm()));
  inv_or(SBO::isObselete               (ia.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, AssignmentRule, ar)
{
  pre(ar.getLevel() > 1);
  if (ar.getLevel() == 2)
  {
    pre( ar.getVersion() > 1);
  }
  pre(ar.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (ar.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (ar.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (ar.getSBOTerm()));
  inv_or(SBO::isInteraction            (ar.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (ar.getSBOTerm()));
  inv_or(SBO::isEntity                 (ar.getSBOTerm()));
  inv_or(SBO::isObselete               (ar.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, RateRule, rr)
{
  pre(rr.getLevel() > 1);
  if (rr.getLevel() == 2)
  {
    pre( rr.getVersion() > 1);
  }
  pre(rr.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (rr.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (rr.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (rr.getSBOTerm()));
  inv_or(SBO::isInteraction            (rr.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (rr.getSBOTerm()));
  inv_or(SBO::isEntity                 (rr.getSBOTerm()));
  inv_or(SBO::isObselete               (rr.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, AlgebraicRule, ar)
{
  pre(ar.getLevel() > 1);
  if (ar.getLevel() == 2)
  {
    pre( ar.getVersion() > 1);
  }
  pre(ar.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (ar.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (ar.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (ar.getSBOTerm()));
  inv_or(SBO::isInteraction            (ar.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (ar.getSBOTerm()));
  inv_or(SBO::isEntity                 (ar.getSBOTerm()));
  inv_or(SBO::isObselete               (ar.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, Constraint, c)
{
  pre(c.getLevel() > 1);
  if (c.getLevel() == 2)
  {
    pre( c.getVersion() > 1);
  }
  pre(c.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (c.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (c.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (c.getSBOTerm()));
  inv_or(SBO::isInteraction            (c.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (c.getSBOTerm()));
  inv_or(SBO::isEntity                 (c.getSBOTerm()));
  inv_or(SBO::isObselete               (c.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, Reaction, r)
{
  pre(r.getLevel() > 1);
  if (r.getLevel() == 2)
  {
    pre( r.getVersion() > 1);
  }
  pre(r.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (r.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (r.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (r.getSBOTerm()));
  inv_or(SBO::isInteraction            (r.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (r.getSBOTerm()));
  inv_or(SBO::isEntity                 (r.getSBOTerm()));
  inv_or(SBO::isObselete               (r.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, SpeciesReference, sr)
{
  pre(sr.getLevel() > 1);
  if (sr.getLevel() == 2)
  {
    pre( sr.getVersion() > 1);
  }
  pre(sr.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (sr.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (sr.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (sr.getSBOTerm()));
  inv_or(SBO::isInteraction            (sr.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (sr.getSBOTerm()));
  inv_or(SBO::isEntity                 (sr.getSBOTerm()));
  inv_or(SBO::isObselete               (sr.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, KineticLaw, kl)
{
  pre(kl.getLevel() > 1);
  if (kl.getLevel() == 2)
  {
    pre( kl.getVersion() > 1);
  }
  pre(kl.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (kl.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (kl.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (kl.getSBOTerm()));
  inv_or(SBO::isInteraction            (kl.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (kl.getSBOTerm()));
  inv_or(SBO::isEntity                 (kl.getSBOTerm()));
  inv_or(SBO::isObselete               (kl.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, Event, e)
{
  pre(e.getLevel() > 1);
  if (e.getLevel() == 2)
  {
    pre( e.getVersion() > 1);
  }
  pre(e.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (e.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (e.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (e.getSBOTerm()));
  inv_or(SBO::isInteraction            (e.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (e.getSBOTerm()));
  inv_or(SBO::isEntity                 (e.getSBOTerm()));
  inv_or(SBO::isObselete               (e.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, EventAssignment, ea)
{
  pre(ea.getLevel() > 1);
  if (ea.getLevel() == 2)
  {
    pre( ea.getVersion() > 1);
  }
  pre(ea.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (ea.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (ea.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (ea.getSBOTerm()));
  inv_or(SBO::isInteraction            (ea.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (ea.getSBOTerm()));
  inv_or(SBO::isEntity                 (ea.getSBOTerm()));
  inv_or(SBO::isObselete               (ea.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, Compartment, c)
{
  pre(c.getLevel() > 1);
  if (c.getLevel() == 2)
  {
    pre( c.getVersion() > 2);
  }
  pre(c.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (c.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (c.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (c.getSBOTerm()));
  inv_or(SBO::isInteraction            (c.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (c.getSBOTerm()));
  inv_or(SBO::isEntity                 (c.getSBOTerm()));
  inv_or(SBO::isObselete               (c.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, Species, s)
{
  pre(s.getLevel() > 1);
  if (s.getLevel() == 2)
  {
    pre( s.getVersion() > 2);
  }
  pre(s.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (s.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (s.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (s.getSBOTerm()));
  inv_or(SBO::isInteraction            (s.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (s.getSBOTerm()));
  inv_or(SBO::isEntity                 (s.getSBOTerm()));
  inv_or(SBO::isObselete               (s.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, CompartmentType, ct)
{
  pre(ct.getLevel() > 1);
  if (ct.getLevel() == 2)
  {
    pre( ct.getVersion() > 2);
  }
  pre(ct.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (ct.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (ct.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (ct.getSBOTerm()));
  inv_or(SBO::isInteraction            (ct.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (ct.getSBOTerm()));
  inv_or(SBO::isEntity                 (ct.getSBOTerm()));
  inv_or(SBO::isObselete               (ct.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, SpeciesType, st)
{
  pre(st.getLevel() > 1);
  if (st.getLevel() == 2)
  {
    pre( st.getVersion() > 2);
  }
  pre(st.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (st.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (st.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (st.getSBOTerm()));
  inv_or(SBO::isInteraction            (st.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (st.getSBOTerm()));
  inv_or(SBO::isEntity                 (st.getSBOTerm()));
  inv_or(SBO::isObselete               (st.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, Trigger, t)
{
  pre(t.getLevel() > 1);
  if (t.getLevel() == 2)
  {
    pre( t.getVersion() > 2);
  }
  pre(t.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (t.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (t.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (t.getSBOTerm()));
  inv_or(SBO::isInteraction            (t.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (t.getSBOTerm()));
  inv_or(SBO::isEntity                 (t.getSBOTerm()));
  inv_or(SBO::isObselete               (t.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99701, Delay, d)
{
  pre(d.getLevel() > 1);
  if (d.getLevel() == 2)
  {
    pre( d.getVersion() > 2);
  }
  pre(d.isSetSBOTerm());

  inv_or(SBO::isQuantitativeParameter  (d.getSBOTerm()));
  inv_or(SBO::isModellingFramework     (d.getSBOTerm()));
  inv_or(SBO::isMathematicalExpression (d.getSBOTerm()));
  inv_or(SBO::isInteraction            (d.getSBOTerm()));
  inv_or(SBO::isParticipantRole        (d.getSBOTerm()));
  inv_or(SBO::isEntity                 (d.getSBOTerm()));
  inv_or(SBO::isObselete               (d.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(10701, Model, m1)
{
  pre(m1.getLevel() > 1);
  if (m1.getLevel() == 2)
  {
    pre( m1.getVersion() > 1);
  }
  pre(m1.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a <model> must be an SBO "
  //  "identifier (http://www.biomodels.net/SBO/) referring to a modeling "
  //  "framework defined in SBO (i.e., terms derived from SBO:0000004, "
  //  "\"modeling framework\"). "
  //  "(References: L2V2 Section 4.2.1; L2V3 Section 4.2.2.)";


  if (m1.getLevel() == 2 && m1.getVersion() < 4)
  {
    inv(SBO::isModellingFramework(m1.getSBOTerm()));
  }
  else
  {
    inv(SBO::isInteraction(m1.getSBOTerm()));
  }
}
END_CONSTRAINT


START_CONSTRAINT(10702, FunctionDefinition, fd)
{
  pre(fd.getLevel() > 1);
  if (fd.getLevel() == 2)
  {
    pre( fd.getVersion() > 1);
  }
  pre(fd.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a <functionDefinition> must be "
  //  "an SBO identifier (http://www.biomodels.net/SBO/) referring to a "
  //  "mathematical expression (i.e., terms derived from SBO:0000064, "
  //  "\"mathematical expression\"). "
  //  "(References: L2V2 Section 4.3.3; L2V3 Section 4.3.3.)";

  inv(SBO::isMathematicalExpression(fd.getSBOTerm()));
}
END_CONSTRAINT


START_CONSTRAINT(10703, Parameter, p)
{
  pre(p.getLevel() > 1);
  if (p.getLevel() == 2)
  {
    pre( p.getVersion() > 1);
  }
  pre(p.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a <parameter> must be an "
  //  "SBO identifier (http://www.biomodels.net/SBO/) referring to a "
  //  "quantitative parameter defined in SBO (i.e., terms derived from "
  //  "SBO:0000002, \"quantitative parameter\"). "
  //  "(References: L2V2 Section 4.9.5; L2V3 Section 4.9.5.)";

  inv(SBO::isQuantitativeParameter(p.getSBOTerm()));
}
END_CONSTRAINT


START_CONSTRAINT(10704, InitialAssignment, ia)
{
  pre(ia.getLevel() > 1);
  if (ia.getLevel() == 2)
  {
    pre( ia.getVersion() > 1);
  }
  pre(ia.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on an <initialAssignment> must "
  //  "be an SBO identifier (http://www.biomodels.net/SBO/) referring to a "
  //  "mathematical expression (i.e., terms derived from SBO:0000064, "
  //  "\"mathematical expression\"). "
  //  "(References: L2V2 Section 4.10.3; L2V3 Section 4.10.3.)";

  inv(SBO::isMathematicalExpression(ia.getSBOTerm()));
}
END_CONSTRAINT


START_CONSTRAINT(10705, AssignmentRule, r)
{
  pre(r.getLevel() > 1);
  if (r.getLevel() == 2)
  {
    pre( r.getVersion() > 1);
  }
  pre(r.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a rule must be an SBO identifier "
  //  "(http://www.biomodels.net/SBO/) referring to a mathematical expression "
  //  "(i.e., terms derived from SBO:0000064, \"mathematical expression\"). "
  //  "Note: This applies to Algebraic Rules in addition to Rate and Assignment "
  //  "Rules. (References: L2V2 Section 4.11.1; L2V3 Section 4.11.1.)";

  inv(SBO::isMathematicalExpression(r.getSBOTerm()));
}
END_CONSTRAINT


START_CONSTRAINT(10705, RateRule, r)
{
  pre(r.getLevel() > 1);
  if (r.getLevel() == 2)
  {
    pre( r.getVersion() > 1);
  }
  pre(r.isSetSBOTerm());

  //msg = 
    //"The value of the 'sboTerm' attribute on a rule must be an SBO identifier "
    //"(http://www.biomodels.net/SBO/) referring to a mathematical expression "
    //"(i.e., terms derived from SBO:0000064, \"mathematical expression\"). Note: "
    //"This applies to Algebraic Rules in addition to Rate and Assignment Rules. "
    //"(References: L2V2 Section 4.11.1; L2V3 Section 4.11.1.)";

  inv(SBO::isMathematicalExpression(r.getSBOTerm()));
}
END_CONSTRAINT


START_CONSTRAINT(10705, AlgebraicRule, r)
{
  pre(r.getLevel() > 1);
  if (r.getLevel() == 2)
  {
    pre( r.getVersion() > 1);
  }
  pre(r.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a rule must be an SBO identifier "
  //  "(http://www.biomodels.net/SBO/) referring to a mathematical expression "
  //  "(i.e., terms derived from SBO:0000064, \"mathematical expression\"). Note: "
  //  "This applies to Algebraic Rules in addition to Rate and Assignment Rules. "
  //  "(References: L2V2 Section 4.11.1; L2V3 Section 4.11.1.)";

  inv(SBO::isMathematicalExpression(r.getSBOTerm()));
}
END_CONSTRAINT


START_CONSTRAINT(10706, Constraint, c)
{
  pre(c.getLevel() > 1);
  if (c.getLevel() == 2)
  {
    pre( c.getVersion() > 1);
  }
  pre(c.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a <constraint> must be an SBO "
  //  "identifier (http://www.biomodels.net/SBO/) referring to a mathematical "
  //  "expression (i.e., terms derived from SBO:0000064, \"mathematical "
  //  "expression\"). "
  //  "(References: L2V2 Section 4.12.3; L2V3 Section 4.12.3.)";

  inv(SBO::isMathematicalExpression(c.getSBOTerm()));
}
END_CONSTRAINT


START_CONSTRAINT(10707, Reaction, r)
{
  pre(r.getLevel() > 1);
  if (r.getLevel() == 2)
  {
    pre( r.getVersion() > 1);
  }
  pre(r.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a <reaction> must be an SBO "
  //  "identifier (http://www.biomodels.net/SBO/) referring to an event defined "
  //  "in SBO (i.e., terms derived from SBO:0000231, \"event\"). "
  //  "(References: L2V2 Section 4.13.1; L2V3 Section 4.13.1)";

  if (r.getLevel() == 2 && r.getVersion() < 4)
  {
    inv(SBO::isEvent(r.getSBOTerm()));
  }
  else
  {
    inv(SBO::isInteraction(r.getSBOTerm()));
  }
}
END_CONSTRAINT


START_CONSTRAINT(10708, SpeciesReference, sr)
{
  pre(sr.getLevel() > 1);
  if (sr.getLevel() == 2)
  {
    pre( sr.getVersion() > 1);
  }
  pre(sr.isSetSBOTerm());

   //msg = 
   //  "The value of the 'sboTerm' attribute on a <speciesReference> "
   //  "or <modifierSpeciesReference> must be an SBO "
   //  "identifier (http://www.biomodels.net/SBO/) referring to a participant "
   //  "role. The appropriate term depends on whether the object is a reactant, "
   //  "product or modifier. If a reactant, then it should be a term in the "
   //  "SBO:0000010, \"reactant\" hierarchy; if a product, then it should be a "
   //  "term in the SBO:0000011, \"product\" hierarchy; and if a modifier, then "
   //  "it should be a term in the SBO:0000019, \"modifier\" hierarchy. "
   //  "(References: L2V2 Section 4.13.2; L2V3 Sections 4.13.1 and 5.)";

  if (!sr.isModifier())
  {
    inv_or(SBO::isProduct(sr.getSBOTerm()));
    inv_or(SBO::isReactant(sr.getSBOTerm()));
  }
  else
  {
    inv(SBO::isModifier(sr.getSBOTerm()));
  }
}
END_CONSTRAINT


START_CONSTRAINT(10709, KineticLaw, kl)
{
  pre(kl.getLevel() > 1);
  if (kl.getLevel() == 2)
  {
    pre( kl.getVersion() > 1);
  }
  pre(kl.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a <kineticLaw> must be an SBO "
  //  "identifier (http://www.biomodels.net/SBO/) referring rate law defined "
  //  "in SBO (i.e., terms derived from SBO:0000001, \"rate law\"). "
  //  "(References: L2V2 Section 4.13.5.)";

  inv(SBO::isRateLaw(kl.getSBOTerm()));
}
END_CONSTRAINT


START_CONSTRAINT(10710, Event, e)
{
  pre(e.getLevel() > 1);
  if (e.getLevel() == 2)
  {
    pre( e.getVersion() > 1);
  }
  pre(e.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on an <event> must be an SBO "
  //  "identifier (http://www.biomodels.net/SBO/) referring to an event "
  //  "defined in SBO (i.e., terms derived from SBO:0000231, \"event\"). "
  //  "(References: L2V2 Section 4.14.1; L2V3 Section 4.14.1.)";
 
  if (e.getLevel() == 2 && e.getVersion() < 4)
  {
    inv(SBO::isEvent(e.getSBOTerm()));
  }
  else
  {
    inv(SBO::isInteraction(e.getSBOTerm()));
  }
}
END_CONSTRAINT


START_CONSTRAINT(10711, EventAssignment, ea)
{
  pre(ea.getLevel() > 1);
  if (ea.getLevel() == 2)
  {
    pre( ea.getVersion() > 1);
  }
  pre(ea.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on an <eventAssignment> must be an "
  //  "SBO identifier (http://www.biomodels.net/SBO/) referring to a "
  //  "mathematical expression (i.e., terms derived from SBO:0000064, "
  //  "\"mathematical expression\"). "
  //  "(References: L2V2 Section 4.14.2; L2V3 Section 4.14.1.)";

  inv(SBO::isMathematicalExpression(ea.getSBOTerm()));
}
END_CONSTRAINT


START_CONSTRAINT(10712, Compartment, c)
{
  pre(c.getLevel() > 1);
  if (c.getLevel() == 2)
  {
    pre( c.getVersion() > 2);
  }
  pre(c.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a <compartment> must be an SBO "
  //  "identifier (http://www.biomodels.net/SBO/) referring to a participant "
  //  "physical type (i.e., terms derived from SBO:0000236, \"participant "
  //  "physical type\"). (References: L2V3 Section 5.2.2.)";

  if (c.getLevel() == 2 && c.getVersion() == 3)
  {
    inv(SBO::isPhysicalParticipant(c.getSBOTerm()));
  }
  else
  {
    inv(SBO::isMaterialEntity(c.getSBOTerm()));
  }
}
END_CONSTRAINT


START_CONSTRAINT(10713, Species, s)
{
  pre(s.getLevel() > 1);
  if (s.getLevel() == 2)
  {
    pre( s.getVersion() > 2);
  }
  pre(s.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a <species> must be an SBO "
  //  "identifier (http://www.biomodels.net/SBO/) referring to a participant "
  //  "physical type (i.e., terms derived from SBO:0000236, \"participant "
  //  "physical type\"). (References: L2V3 Section 5.2.2.)";

  if (s.getLevel() == 2 && s.getVersion() == 3)
  {
    inv(SBO::isPhysicalParticipant(s.getSBOTerm()));
  }
  else
  {
    inv(SBO::isMaterialEntity(s.getSBOTerm()));
  }
}
END_CONSTRAINT


START_CONSTRAINT(10714, CompartmentType, c)
{
  pre(c.getLevel() > 1);
  if (c.getLevel() == 2)
  {
    pre( c.getVersion() > 2);
  }
  pre(c.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a <compartmentType> must be an SBO "
  //  "identifier (http://www.biomodels.net/SBO/) referring to a participant "
  //  "physical type (i.e., terms derived from SBO:0000236, \"participant "
  //  "physical type\"). (References: L2V3 Section 5.2.2.)";

  if (c.getLevel() == 2 && c.getVersion() == 3)
  {
    inv(SBO::isPhysicalParticipant(c.getSBOTerm()));
  }
  else
  {
    inv(SBO::isMaterialEntity(c.getSBOTerm()));
  }
}
END_CONSTRAINT


START_CONSTRAINT(10715, SpeciesType, s)
{
  pre(s.getLevel() > 1);
  if (s.getLevel() == 2)
  {
    pre( s.getVersion() > 2);
  }
  pre(s.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a <speciesType> must be an SBO "
  //  "identifier (http://www.biomodels.net/SBO/) referring to a participant "
  //  "physical type (i.e., terms derived from SBO:0000236, \"participant "
  //  "physical type\"). (References: L2V3 Section 5.2.2.)";

  if (s.getLevel() == 2 && s.getVersion() == 3)
  {
    inv(SBO::isPhysicalParticipant(s.getSBOTerm()));
  }
  else
  {
    inv(SBO::isMaterialEntity(s.getSBOTerm()));
  }
}
END_CONSTRAINT


START_CONSTRAINT(10716, Trigger, t)
{
  pre(t.getLevel() > 1);
  if (t.getLevel() == 2)
  {
    pre( t.getVersion() > 2);
  }
  pre(t.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a <trigger> must be an SBO "
  //  "identifier (http://www.biomodels.net/SBO/) referring to a mathematical "
  //  "expression (i.e., terms derived from SBO:0000064, \"mathematical "
  //  "expression\"). (References: L2V3 Section 5.2.2.)";

  inv(SBO::isMathematicalExpression(t.getSBOTerm()));
}
END_CONSTRAINT


START_CONSTRAINT(10717, Delay, d)
{
  pre(d.getLevel() > 1);
  if (d.getLevel() == 2)
  {
    pre( d.getVersion() > 2);
  }
  pre(d.isSetSBOTerm());

  //msg = 
  //  "The value of the 'sboTerm' attribute on a <delay> must be an SBO "
  //  "identifier (http://www.biomodels.net/SBO/) referring to a mathematical "
  //  "expression (i.e., terms derived from SBO:0000064, \"mathematical "
  //  "expression\"). (References: L2V3 Section 5.2.2.)";

  inv(SBO::isMathematicalExpression(d.getSBOTerm()));
}
END_CONSTRAINT

START_CONSTRAINT(99702, Model, m1)
{
  pre(m1.getLevel() > 1);
  if (m1.getLevel() == 2) 
  {
    pre( m1.getVersion() > 1);
  }
  pre(m1.isSetSBOTerm());

  inv(! SBO::isObselete               (m1.getSBOTerm()));
}
END_CONSTRAINT

START_CONSTRAINT(99702, FunctionDefinition, fd)
{
  pre(fd.getLevel() > 1);
  if (fd.getLevel() == 2) 
  {
    pre( fd.getVersion() > 1);
  }
  pre(fd.isSetSBOTerm());

  inv(! SBO::isObselete               (fd.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, Parameter, p)
{
  pre(p.getLevel() > 1);
  if (p.getLevel() == 2) 
  {
    pre( p.getVersion() > 1);
  }
  pre(p.isSetSBOTerm());

  inv(! SBO::isObselete               (p.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, InitialAssignment, ia)
{
  pre(ia.getLevel() > 1);
  if (ia.getLevel() == 2) 
  {
    pre( ia.getVersion() > 1);
  }
  pre(ia.isSetSBOTerm());

  inv(! SBO::isObselete               (ia.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, AssignmentRule, ar)
{
  pre(ar.getLevel() > 1);
  if (ar.getLevel() == 2)
  {
    pre( ar.getVersion() > 1);
  }
  pre(ar.isSetSBOTerm());

  inv(! SBO::isObselete               (ar.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, RateRule, rr)
{
  pre(rr.getLevel() > 1);
  if (rr.getLevel() == 2)
  {
    pre( rr.getVersion() > 1);
  }
  pre(rr.isSetSBOTerm());

  inv(! SBO::isObselete               (rr.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, AlgebraicRule, ar)
{
  pre(ar.getLevel() > 1);
  if (ar.getLevel() == 2)
  {
    pre( ar.getVersion() > 1);
  }
  pre(ar.isSetSBOTerm());

  inv(! SBO::isObselete               (ar.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, Constraint, c)
{
  pre(c.getLevel() > 1);
  if (c.getLevel() == 2)
  {
    pre( c.getVersion() > 1);
  }
  pre(c.isSetSBOTerm());

  inv(! SBO::isObselete               (c.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, Reaction, r)
{
  pre(r.getLevel() > 1);
  if (r.getLevel() == 2)
  {
    pre( r.getVersion() > 1);
  }
  pre(r.isSetSBOTerm());

  inv(! SBO::isObselete               (r.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, SpeciesReference, sr)
{
  pre(sr.getLevel() > 1);
  if (sr.getLevel() == 2)
  {
    pre( sr.getVersion() > 1);
  }
  pre(sr.isSetSBOTerm());

  inv(! SBO::isObselete               (sr.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, KineticLaw, kl)
{
  pre(kl.getLevel() > 1);
  if (kl.getLevel() == 2)
  {
    pre( kl.getVersion() > 1);
  }
  pre(kl.isSetSBOTerm());

  inv(! SBO::isObselete               (kl.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, Event, e)
{
  pre(e.getLevel() > 1);
  if (e.getLevel() == 2)
  {
    pre( e.getVersion() > 1);
  }
  pre(e.isSetSBOTerm());

  inv(! SBO::isObselete               (e.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, EventAssignment, ea)
{
  pre(ea.getLevel() > 1);
  if (ea.getLevel() == 2)
  {
    pre( ea.getVersion() > 1);
  }
  pre(ea.isSetSBOTerm());

  inv(! SBO::isObselete               (ea.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, Compartment, c)
{
  pre(c.getLevel() > 1);
  if (c.getLevel() == 2)
  {
    pre( c.getVersion() > 2);
  }
  pre(c.isSetSBOTerm());

  inv(! SBO::isObselete               (c.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, Species, s)
{
  pre(s.getLevel() > 1);
  if (s.getLevel() == 2)
  {
    pre( s.getVersion() > 2);
  }
  pre(s.isSetSBOTerm());

  inv(! SBO::isObselete               (s.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, CompartmentType, ct)
{
  pre(ct.getLevel() > 1);
  if (ct.getLevel() == 2)
  {
    pre( ct.getVersion() > 2);
  }
  pre(ct.isSetSBOTerm());

  inv(! SBO::isObselete               (ct.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, SpeciesType, st)
{
  pre(st.getLevel() > 1);
  if (st.getLevel() == 2)
  {
    pre( st.getVersion() > 2);
  }
  pre(st.isSetSBOTerm());

  inv(! SBO::isObselete               (st.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, Trigger, t)
{
  pre(t.getLevel() > 1);
  if (t.getLevel() == 2)
  {
    pre( t.getVersion() > 2);
  }
  pre(t.isSetSBOTerm());

  inv(! SBO::isObselete               (t.getSBOTerm()));

}
END_CONSTRAINT

START_CONSTRAINT(99702, Delay, d)
{
  pre(d.getLevel() > 1);
  if (d.getLevel() == 2)
  {
    pre( d.getVersion() > 2);
  }
  pre(d.isSetSBOTerm());

  inv(! SBO::isObselete               (d.getSBOTerm()));

}
END_CONSTRAINT


/** @endcond */

