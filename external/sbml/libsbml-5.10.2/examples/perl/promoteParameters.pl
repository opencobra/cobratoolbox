#!/usr/bin/env perl
# -*-Perl-*-
##
## @file    promoteParameters.pl
## @brief   promotes all local to global paramters
## @author  Frank T. Bergmann
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

use File::Basename;
use LibSBML;
no strict;

if ($#ARGV != 1) {
   print  "usage: promoteParameters.pl input-filename output-filename\n";
   exit 1;
}

$infile  = $ARGV[0];
$outfile = $ARGV[1];

unless (-e $infile) {
  print("[Error] ", $infile, ": No such file.", "\n");
  exit 1;
}
$reader  = new LibSBML::SBMLReader();
$writer  = new LibSBML::SBMLWriter();
$sbmldoc = $reader->readSBML($infile);

if ($sbmldoc->getNumErrors() > 0) {
  if ($sbmldoc->getError(0)->getErrorId() == $LibSBML::XMLFileUnreadable) {
    # Handle case of unreadable file here.
    $sbmldoc->printErrors();
  }
  elsif ($sbmldoc->getError(0)->getErrorId() == $LibSBML::XMLFileOperationError) {
    # Handle case of other file error here.
    $sbmldoc->printErrors();
  }
  else {
    # Handle other error cases here.
    $sbmldoc->printErrors();
  }
  exit 1;
}
$props = new LibSBML::ConversionProperties();
$props->addOption("promoteLocalParameters", true, "Promotes all Local Parameters to Global ones");
if ($sbmldoc->convert($props) != $LibSBML::LIBSBML_OPERATION_SUCCESS)
{
  print("[Error] Conversion failed.", "\n");
  exit 3;
}
$writer->writeSBML($sbmldoc, $outfile);
print("[OK] done, wrote ", $outfile, "\n");

