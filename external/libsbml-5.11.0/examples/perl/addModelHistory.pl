#!/usr/bin/env perl
# -*-Perl-*-
## 
## \file    addModelHistory.pl
## \brief   adds Model History to a model
## \author  Sarah Keating
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


use LibSBML;
no strict;

sub printStatus {
  $message = $_[0];
  $status = $_[1];
  $statusString = "";
  if (status == $LibSBML::LIBSBML_OPERATION_SUCCESS) {
    $statusString = "succeeded";
  }
  elsif (status == $LibSBML::LIBSBML_INVALID_OBJECT) {
    $statusString = "invalid object";
  }
  elsif (status == $LibSBML::LIBSBML_OPERATION_FAILED) {
    $statusString = "operation failed";
  }
  else {
    $statusString = "unknown";          
  }  
  print ($message, $statusString, "\n");
}


if ($#ARGV  != 1) {
  print "usage: addModelHistory <input-filename> <output-filename>\n";
  print "       Adds a model history to the model\n";
  exit 2;
}

$d = LibSBML::readSBML($ARGV[0]);
$errors = $d->getNumErrors();

if (errors > 0) {
    print("Read Error(s):", "\n");
    $d->printErrors();  
    print("Correct the above and re-run.", "\n");
	exit $errors;
}

$h = new LibSBML::ModelHistory();

$c = new LibSBML::ModelCreator();
$c->setFamilyName("Keating");
$c->setGivenName("Sarah");
$c->setEmail("sbml-team@caltech.edu");
$c->setOrganization("University of Hertfordshire");

$status = $h->addCreator($c);
printStatus("Status for addCreator: ", $status);


$date = new LibSBML::Date("1999-11-13T06:54:32");
$date2 = new LibSBML::Date("2007-11-30T06:54:00-02:00");

$status = $h->setCreatedDate($date);
printStatus("Set created date:      ", $status);

$status = $h->setModifiedDate($date2);
printStatus("Set modified date:     ", $status);

$status = $d->getModel()->setModelHistory($h);
printStatus("Set model history:     ", $status);


LibSBML::writeSBML($d, $ARGV[1]);

exit $errors;

