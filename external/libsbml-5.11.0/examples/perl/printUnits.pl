#!/usr/bin/env perl
# -*-Perl-*-
## 
## @file    printUnits.pl
## @brief   Prints some unit information about the $model
## @author  Sarah Keating
## @author  Michael Hucka
## 
## 
## <!--------------------------------------------------------------------------
## This sample program is distributed under a different license than the rest
## of libSBML.  This program uses the open-source MIT license, as follows:
##
## Copyright (c) 2013-2014 by the California Institute of Technology
## (California, USA), the European Bioinformatics Institute (EMBL-EBI, UK)
## and the University of Heidelberg (Germany), with support from the National
## Institutes of Health (USA) under grant R01GM070923.  All rights reserved.
##
## Permission is hereby granted, free of charge, to any person obtaining a
## copy of this software and associated documentation files (the "Software"),
## to deal in the Software without restriction, including without limitation
## the rights to use, copy, modify, merge, publish, distribute, sublicense,
## and/or sell copies of the Software, and to permit persons to whom the
## Software is furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
## THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
## DEALINGS IN THE SOFTWARE.
##
## Neither the name of the California Institute of Technology (Caltech), nor
## of the European Bioinformatics Institute (EMBL-EBI), nor of the University
## of Heidelberg, nor the names of any contributors, may be used to endorse
## or promote products derived from this software without specific prior
## written permission.
## ------------------------------------------------------------------------ -->
## 

use LibSBML;
no strict;

if ($#ARGV != 0) {
    print "Usage: printUnits filename\n\n";
    exit 1;
}

$filename = $ARGV[0];
$document = LibSBML::readSBML($filename);

if ($document->getNumErrors() > 0) {
    print("Encountered the following SBML errors:");
    $document->printErrors();
    exit 1;
}

$model = $document->getModel();

if ($model == undef) {
    print("No model present.");
    exit 1;
}
for ($i=0; $i < $model->getNumSpecies();$i++) {
    $s = $model->getSpecies($i);
    print "Species ", $i, ": " , LibSBML::UnitDefinition::printUnits($s->getDerivedUnitDefinition()), "\n";
}
for ($i=0; $i < $model->getNumCompartments(); $i++) {
    $c = $model->getCompartment($i);
    print("Compartment ",i, ": ",
                                  LibSBML::UnitDefinition::printUnits($c->getDerivedUnitDefinition()), "\n");
}
for ($i = 0; $i < $model->getNumParameters(); $i++) {
    $p = $model->getParameter($i);
    print("Parameter ",$i, ": " ,LibSBML::UnitDefinition::printUnits($p->getDerivedUnitDefinition()), "\n");
}
for ($i = 0; $i < $model->getNumInitialAssignments(); $i++) {
    $ia = $model->getInitialAssignment($i);
    print("InitialAssignment ",$i,": ", LibSBML::UnitDefinition::printUnits($ia->getDerivedUnitDefinition()), "\n");
    $tmp = "no";
    if ($ia->containsUndeclaredUnits()) {
      $tmp = "yes";
    }
    print("        undeclared units: ", $tmp, "\n");
}
for ($i =0; $i <$model->getNumEvents(); $i++) {
    $e = $model->getEvent($i);
    print("Event ", $i, ": ");

    if ($e->isSetDelay()) {
        print("Delay: ", LibSBML::UnitDefinition::printUnits($e->getDelay()->getDerivedUnitDefinition()), "\n");
        $tmp = "no";
        if ($e->getDelay()->containsUndeclaredUnits()) {
          $tmp = "yes";
        }
        print("        undeclared units: ",$tmp, "\n");
    }
    for ($j =0; $j < $e->getNumEventAssignments();$j++) {
        $ea = $e->getEventAssignment($j);
        print("EventAssignment ", $j, ": ", LibSBML::UnitDefinition::printUnits($ea->getDerivedUnitDefinition()), "\n");
        $tmp = "no";
        if ($ea->containsUndeclaredUnits()) {
          $tmp = "yes";
        }
        print("        undeclared units: ", $tmp, "\n");
     }
}
for ($i =0; $i < $model->getNumReactions(); $i++) {
    $r = $model->getReaction($i);

    print("Reaction ",$i,": ");

    if ($r->isSetKineticLaw()) {
        print("Kinetic Law: ", LibSBML::UnitDefinition::printUnits($r->getKineticLaw()->getDerivedUnitDefinition()), "\n");
        $tmp = "no";
        if ($r->getKineticLaw()->containsUndeclaredUnits()) {
     $tmp = "yes";
        }
        print("        undeclared units: ", $tmp, "\n");
    }
    for ($j=0; $j< $r->getNumReactants(); $j++) {
        $sr = $r->getReactant($j);

        if ($sr->isSetStoichiometryMath()) {
            print("Reactant stoichiometryMath", $j, ": ", LibSBML::UnitDefinition::printUnits($sr->getStoichiometryMath()->getDerivedUnitDefinition()), "\n");
            $tmp = "no";
            if ($sr->getStoichiometryMath()->containsUndeclaredUnits()) {
	$tmp = "yes";
            }
            print("        undeclared units: ", $tmp, "\n");
         }
    }
    for ($j=0; $j < $r->getNumProducts(); $j++) {
        $sr = $r->getProduct($j);

        if ($sr->isSetStoichiometryMath()) {
            print("Product stoichiometryMath",$j, ": ", LibSBML::UnitDefinition::printUnits($sr->getStoichiometryMath()->getDerivedUnitDefinition()), "\n");
            $tmp = "no";
            if ($sr->getStoichiometryMath()->containsUndeclaredUnits()) {
              $tmp = "yes";
            }
            print("        undeclared units: ", tmp, "\n");    
        }
    }
}
for ($i = 0; $i < $model->getNumRules(); $i++) {
    $r = $model->getRule($i);
    print("Rule ", i, ": ", LibSBML::UnitDefinition::printUnits($r->getDerivedUnitDefinition()), "\n");
    $tmp = "no";
    if ($r->containsUndeclaredUnits()) {
       $tmp = "yes";
    }
    print("        undeclared units: ", tmp, "\n");    
}
exit;
  
