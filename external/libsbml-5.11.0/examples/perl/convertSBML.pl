#!/usr/bin/env perl
# -*-Perl-*-

##
## \file    convertSBML.pl
## \brief   Converts SBML L1 documents (any version) to L2v3
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
use vars qw/@ARGV/;

unless (@ARGV == 2) {
  printf STDERR
      "\n  usage: @{[basename($0)]} <input-filename> <output-filename>\n\n";
  exit (1);
};

my ($inFileName, $outFileName) = (shift(),shift());
my $rd        = new LibSBML::SBMLReader();
my $d         = $rd->readSBML($inFileName);
my $errors    = $d->getNumErrors();

if ($errors > 0) {
  printf( "Read Error(s):\n" );
  
  $d->printErrors();
  
  printf("Conversion skipped.  Correct the above and re-run.\n");
}
else {
  if ( $d->getLevel() == 2 ) {
    $d->setLevelAndVersion(1, 2)
  }
  else {
    $d->setLevelAndVersion(2, 4)
  }

  $errors    =  $d->getNumErrors();
  if ($errors > 0) {
    printf( "Conversion Error(s):\n" );
    
    $d->printErrors();

    printf("Conversion skipped.  Either libSBML does not (yet) have ");
    printf("ability to convert this model or (automatic) conversion ");
    printf("is not possible.");
  }
  else {
    $d->writeSBML($outFileName);
  }
}

__END__
