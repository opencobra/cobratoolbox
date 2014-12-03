#!/usr/bin/env perl
# -*-Perl-*-

##
## \file    translateMath.pl
## \brief   Translates infix formulas into MathML and vice-versa
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

#use blib '../../src/bindings/perl';
use LibSBML;
use strict;

print
    "\nThis program translates infix formulas into MathML and\n",
    "vice-versa.  Enter or return on an empty line triggers\n",
    "translation. Ctrl-C quits\n\n";

while (1) {
  my $math = "";
  print "Enter infix formula or MathML expression (Ctrl-C to quit):\n\n> ";

  while (my $line = util_trim($_ = <>)) { $math .= "$line\n" }
  print
      "Result:\n\n",
      ($math =~ m/^</) ? translateMathML($math) : translateInfix($math),
      "\n\n\n";
}

#---
sub translateInfix {
  my $expr = shift;
  LibSBML::writeMathMLToString(LibSBML::parseFormula($expr));
}

#---
sub translateMathML {
  my $xml = shift;
  $xml = "<?xml version='1.0' encoding='ascii'?>\n" . $xml
      unless $xml =~ m/^<\?/;
  LibSBML::formulaToString(LibSBML::readMathMLFromString($xml));
}

#---
sub util_trim {
  local $_ = shift;
  s/^\s+//; s/\s+$//; chomp();
  return $_;
}
