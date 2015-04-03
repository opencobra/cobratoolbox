# 
# @file    printMath.R
# @brief   Prints Rule, Reaction, and Event formulas in a given SBML Document
# @author  Frank Bergmann
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
# Usage: R --slave -f printMath.R --args <full path to input file>
#
library(libSBML)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1)
{
  stop("Usage: printMath input-filename\n");
}


printFunctionDefinition <- function(n, fd) {
  if ( FunctionDefinition_isSetMath(fd) )
  {
    cat("FunctionDefinition ",n,", ",FunctionDefinition_getId(fd),"(");

    math = FunctionDefinition_getMath(fd);

    # Print function arguments. 
    if (ASTNode_getNumChildren(math) > 1) {
      cat(ASTNode_getName( ASTNode_getLeftChild(math) ));

      for (n in seq_len(ASTNode_getNumChildren(math) - 1)) {
        cat(", ", ASTNode_getName( ASTNode_getChild(math, n) ));
      }
    }

    cat(") := ");

    # Print function body. 
    if (ASTNode_getNumChildren(math) == 0) {
      cat("(no body defined)");
    } else {
      math    = ASTNode_getChild(math, ASTNode_getNumChildren(math) - 1);
      formula = formulaToString(math);
      cat(formula,"\n");      
    }
  }
}


printRuleMath <- function(n, r) {
  if ( Rule_isSetMath(r) ) {
    formula = formulaToString( Rule_getMath(r) );
    cat("Rule ",n,", formula: ",formula,"\n");    
  }
}


printReactionMath <- function(n, r)
{
  if (Reaction_isSetKineticLaw(r)) {
    kl = Reaction_getKineticLaw(r);

    if ( KineticLaw_isSetMath(kl) ) {
      formula = formulaToString( KineticLaw_getMath(kl) );
      cat("Reaction ",n,", formula: ",formula,"\n");      
    }
  }
}


printEventAssignmentMath <- function(n, ea) {
  if ( EventAssignment_isSetMath(ea) ) {
    variable = EventAssignment_getVariable(ea);
    formula  = formulaToString( EventAssignment_getMath(ea) );

    cat("  EventAssignment ",n,", trigger: ",variable," = ",formula,"\n");

  }
}


printEventMath <- function(n, e) {
  if ( Event_isSetDelay(e) ) {
    delay = Event_getDelay(e);
    formula = formulaToString( Delay_getMath(delay) );
    cat("Event ",n," delay: ",formula,"\n");    
  }

  if ( Event_isSetTrigger(e) ) {
    trigger = Event_getTrigger(e);

    formula = formulaToString( Trigger_getMath(trigger) );
    cat("Event ",n," trigger: ",formula,"\n");    
  }

  for (i in seq_len(Event_getNumEventAssignments(e))) {
    printEventAssignmentMath(i, Event_getEventAssignment(e, i-1));
  }

  cat("\n");
}


printMath <- function(m) {

  for (n in seq_len(Model_getNumFunctionDefinitions(m))){
    printFunctionDefinition(n, Model_getFunctionDefinition(m, n-1));
  }
  
  for (n in seq_len(Model_getNumRules(m))){
    printRuleMath(n , Model_getRule(m, n-1));
  }

  cat("\n");

  for (n in seq_len(Model_getNumReactions(m))){
    printReactionMath(n, Model_getReaction(m, n-1));
  }

  cat("\n");

  for (n in seq_len(Model_getNumEvents(m))){
    printEventMath(n , Model_getEvent(m, n-1));
  }
}



d = readSBML(args[1]);
m = SBMLDocument_getModel(d);

SBMLDocument_printErrors(d);

printMath(m);
cat("\n");

q(status=0);


