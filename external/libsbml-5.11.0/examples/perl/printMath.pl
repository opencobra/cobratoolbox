#!/usr/bin/env perl
# -*-Perl-*-

##
## \file    printMath.pl
## \brief   Prints Rule, Reaction, and Event formulas in a given SBML Document
## \author  TBI {xtof,raim}@tbi.univie.ac.at
##

##
## Copyright 2005 TBI
##
## This library is free software; you can redistribute it and/or modify it
## under the terms of the GNU Lesser General Public License as published
## by the Free Software Foundation; either version 2.1 of the License, or
## any later version.
##
## This library is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY, WITHOUT EVEN THE IMPLIED WARRANTY OF
## MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  The software and
## documentation provided hereunder is on an "as is" basis, and the
## California Institute of Technology and Japan Science and Technology
## Corporation have no obligations to provide maintenance, support,
## updates, enhancements or modifications.  In no event shall the
## California Institute of Technology or the Japan Science and Technology
## Corporation be liable to any party for direct, indirect, special,
## incidental or consequential damages, including lost profits, arising
## out of the use of this software and its documentation, even if the
## California Institute of Technology and/or Japan Science and Technology
## Corporation have been advised of the possibility of such damage.  See
## the GNU Lesser General Public License for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with this library; if not, write to the Free Software Foundation,
## Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
##
## The original code contained here was initially developed by:
##
##     Christoph Flamm and Rainer Machne
##     Institut fuer Theoretische Chemie
##     Universitaet Wien
##     Waehringerstrasse 17/3/308
##     A-1090 Wien, Austria

use File::Basename;
use blib '../../src/bindings/perl';
use LibSBML;
use strict;

my $filename = shift()
    || do { printf STDERR "\n  usage: @{[basename($0)]} <filename>\n\n";
            exit (1);
          };


my $rd = new LibSBML::SBMLReader();
my $d  = $rd->readSBML($filename);

$d->printErrors();

my $m  = $d->getModel();

printMath($m);
printf("\n");

#---
sub printFunctionDefinition {
  my ($n, $fd) = @_;
  
  if ($fd->isSetMath()) {
    local $| = 1;
    printf "FunctionDefinition %d, %s(", $n, $fd->getId();

    my $math = $fd->getMath();
    my $numc = $math->getNumChildren();
    
    # Print function arguments
    if ($numc > 1) {
      printf "%s", $math->getLeftChild()->getName();

      for (my $n=1; $n < $numc-1; $n++) {
	printf ", %s", $math->getChild($n)->getName();
      }
    }
    
    printf ") := ";

    # Print function body
    if ($numc == 0) { printf "(no body defined)" }
    else { printf "%s\n", LibSBML::formulaToString($math->getChild($numc-1)) }
  }
}

#---
sub printRuleMath {
  my ($n, $r) = @_;
  printf
      "Rule %d, formula: %s\n",
      $n, LibSBML::formulaToString($r->getMath()) if $r->isSetMath();
}

#---
sub printReactionMath {
  my ($n, $r) = @_;
  if ($r->isSetKineticLaw()) {
    my $kl = $r->getKineticLaw();
    printf
	"Reaction %d, formula: %s\n",
	$n, LibSBML::formulaToString($kl->getMath()) if $kl->isSetMath();  
  }
}

#---
sub printEventAssignmentMath {
  my ($n, $ea) = @_;
  printf
      "  EventAssignment %d, trigger: %s = %s\n",
      $n, $ea->getVariable(),
      LibSBML::formulaToString($ea->getMath()) if $ea->isSetMath();
}

#---
sub printEventMath {
  my ($n, $e) = @_;

  printf
      "Event %d delay: %s\n",
      $n, LibSBML::formulaToString($e->getDelay()->getMath())
      if $e->isSetDelay();

  printf
      "Event %d trigger: %s\n",
      $n, LibSBML::formulaToString($e->getTrigger()->getMath())
      if $e->isSetTrigger();  

  printEventAssignmentMath($_+1, $e->getEventAssignment($_))
      for 0 .. $e->getNumEventAssignments()-1;
}

#---
sub printMath {
  my $m = shift || do {warn "Model not defined"; return };
  
  printFunctionDefinition($_+1, $m->getFunctionDefinition($_))
      for 0 .. $m->getNumFunctionDefinitions()-1;

  printRuleMath($_+1, $m->getRule($_)) for 0 .. $m->getNumRules()-1;
  printf("\n");

  printReactionMath($_+1, $m->getReaction($_))
      for 0 .. $m->getNumReactions()-1;
  printf("\n");
  
  printEventMath($_+1, $m->getEvent($_)) for 0 .. $m->getNumEvents()-1;
}

