# 
# @file    printUnits.R
# @brief   Prints some unit information about the model
# @author  Frank Bergmann
# 
# 
# <!--------------------------------------------------------------------------
# This sample program is distributed under a different license than the rest
# of libSBML.  This program uses the open-source MIT license, as follows:
#
# Copyright (c) 2013-2014 by the California Institute of Technology
# (California, USA), the European Bioinformatics Institute (EMBL-EBI, UK)
# and the University of Heidelberg (Germany), with support from the National
# Institutes of Health (USA) under grant R01GM070923.  All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#
# Neither the name of the California Institute of Technology (Caltech), nor
# of the European Bioinformatics Institute (EMBL-EBI), nor of the University
# of Heidelberg, nor the names of any contributors, may be used to endorse
# or promote products derived from this software without specific prior
# written permission.
# ------------------------------------------------------------------------ -->
# 
#
# Usage: R --slave -f printUnits.R --args <full path to input file>
#
library(libSBML)


args <- commandArgs(trailingOnly = TRUE)


if (length(args) != 1)
{
  stop("Usage: printUnits input-filename\n");
}


filename  = args[1];
document  = readSBML(filename);

errors = SBMLErrorLog_getNumFailsWithSeverity(
			SBMLDocument_getErrorLog(document), 
			enumToInteger("LIBSBML_SEV_ERROR", "_XMLErrorSeverity_t")
		 );


if (errors > 0) {
  cat("Encountered the following SBML errors:\n");
  SBMLDocument_printErrors(document);
  q(status=1);
}

model = SBMLDocument_getModel(document);

if (is.null(model)) {
  cat("No model present.\n");
  q(status=1);
}

for (i in seq_len(Model_getNumSpecies(model))) {
  s = Model_getSpecies(model, i-1);
  cat("Species ", i, ": ",
      UnitDefinition_printUnits(Species_getDerivedUnitDefinition(s), FALSE),"\n");    
}


for (i in seq_len(Model_getNumCompartments(model))) {
  c = Model_getCompartment(model, i-1);
  cat("Compartment ", i, ": ",
      UnitDefinition_printUnits(Compartment_getDerivedUnitDefinition(c), FALSE),"\n");    
}

for (i in seq_len(Model_getNumParameters(model))) {
  p = Model_getParameter(model, i-1);
  cat("Parameter ", i, ": ",
      UnitDefinition_printUnits(Parameter_getDerivedUnitDefinition(p), FALSE),"\n");    
}


for (i in seq_len(Model_getNumInitialAssignments(model))) {
  ia = Model_getInitialAssignment(model, i-1);  
  cat("InitialAssignment ", i, ": ",
      UnitDefinition_printUnits(InitialAssignment_getDerivedUnitDefinition(ia), FALSE),"\n");    

  cat("        undeclared units: ", 
	ifelse(InitialAssignment_containsUndeclaredUnits(ia), 
			"yes\n" , "no\n"));
}

for (i in seq_len(Model_getNumEvents(model))) {
  e = Model_getEvent(model, i-1);
  cat("Event ",i,": \n" );

  if (Event_isSetDelay(e))   {
    cat( "Delay: ",UnitDefinition_printUnits(Delay_getDerivedUnitDefinition(Event_getDelay(e)), FALSE),"\n");
    cat("        undeclared units: ", 
	ifelse(Delay_containsUndeclaredUnits(Event_getDelay(e)), 
			"yes\n" , "no\n"));	
  }
    
  for (j in seq_len(Event_getNumEventAssignments(e))) {
    ea = Event_getEventAssignment(e, j);
    cat( "EventAssignment: ",UnitDefinition_printUnits(EventAssignment_getDerivedUnitDefinition(ea), FALSE),"\n");
	cat("        undeclared units: ", 
	ifelse(EventAssignment_containsUndeclaredUnits(ea), 
			"yes\n" , "no\n"));	
  }
}

for (i in seq_len(Model_getNumReactions(model))) {
  r = Model_getReaction(model, i-1);
    
  cat("Reaction ",i,": \n");

  if (Reaction_isSetKineticLaw(r)) {
    kl = Reaction_getKineticLaw(r);
    cat( "Kinetic Law: ",UnitDefinition_printUnits(KineticLaw_getDerivedUnitDefinition(kl), FALSE),"\n");
	cat("        undeclared units: ", 
	ifelse(KineticLaw_containsUndeclaredUnits(kl), 
			"yes\n" , "no\n"));	
  }

  for (j in seq_len(Reaction_getNumReactants(r)))  {
    sr = Reaction_getReactant(r, j-1);

    if (SpeciesReference_isSetStoichiometryMath(sr)) {
      sm = SpeciesReference_getStoichiometryMath(sr);
      cat( "Reactant stoichiometryMath ",j,": ",UnitDefinition_printUnits(StoichiometryMath_getDerivedUnitDefinition(sm), FALSE),"\n")
	  cat("        undeclared units: ", 
	  ifelse(StoichiometryMath_containsUndeclaredUnits(sm), 
			"yes\n" , "no\n"));	
    }
  }

  for (j in seq_len(Reaction_getNumProducts(r)))  {
    sr = Reaction_getProduct(r, j-1);

    if (SpeciesReference_isSetStoichiometryMath(sr)) {
      sm = SpeciesReference_getStoichiometryMath(sr);
      cat( "Product stoichiometryMath ",j,": ",UnitDefinition_printUnits(StoichiometryMath_getDerivedUnitDefinition(sm), FALSE),"\n")
	  cat("        undeclared units: ", 
	  ifelse(StoichiometryMath_containsUndeclaredUnits(sm), 
			"yes\n" , "no\n"));	
    }
  }

}

for (i in seq_len(Model_getNumRules(model))) {
  r = Model_getRule(model, i-1);

 cat( "Rule ",i,": ",UnitDefinition_printUnits(Rule_getDerivedUnitDefinition(r), FALSE),"\n");
 cat("        undeclared units: ", 
	  ifelse(Rule_containsUndeclaredUnits(r), 
			"yes\n" , "no\n"));	
}

q(status=0);

