#!/usr/bin/env perl
# -*-Perl-*-
##
## \file    extractReactionInfo.pl
## \brief   Illustrates howto extract reaction information from a SBML file
## \author  TBI {xtof,raim}@tbi.univie.ac.at
##

##
## Copyright 2007 TBI
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

print "Reading \"$filename\"\n";

my $rd = new LibSBML::SBMLReader();
my $d  = $rd->readSBML($filename);

$d->printErrors();

my $model = $d->getModel();

# The following code illustrates the usage of getListOfXXXX methods in
# scalar and list context.
 
print "\nUsing getListOfXXXX in scalar context!!!\n\n";

# get list of species
my $ListOfSpecies = $model->getListOfSpecies();

# iterate list of species for ith reaction
# and translate SpeciesReferences to Species         
my @species = ();
for (0..$ListOfSpecies->size()-1) {
  push @species, $ListOfSpecies->get($_)->getId();
}

# print species
print "Species: ", join (", ", @species), "\n\n";

# get list of reactions
my $ListOfReaction = $model->getListOfReactions();

# iterate list of reactions
for (0..$ListOfReaction->size()-1) {

  # get ith reaction an print data
  my $reaction = $ListOfReaction->get($_);
  print
      "Reaction with Id ", $reaction->getId(), "\nhas ",
      $reaction->getNumReactants(), " Reactant(s), ",
      $reaction->getNumProducts(), " Product(s), ",
      $reaction->getNumModifiers(), " Modifier(s)\n";

  # get list of reactants
  my $ListOfReactants = $reaction->getListOfReactants();

  # iterate list of reactants for ith reaction
  # and translate SpeciesReferences to Species
  my @reactants = ();
  for (0..$ListOfReactants->size()-1) {
    push @reactants, $ListOfReactants->get($_)->getSpecies();
  }
  
  # print reactants
  print "Reactant(s): ", join(", ", @reactants), "\n";

  # get list of products
  my $ListOfProducts = $reaction->getListOfProducts();

  # iterate list of products for ith reaction
  # and translate SpeciesReferences to Species
  my @products = ();
  for (0..$ListOfProducts->size()-1) {
    push @products, $ListOfProducts->get($_)->getSpecies();
  }
  
  # print products
  print "Product(s): ", join(", ", @products), "\n";

  # get list of modifiers
  my $ListOfModifiers = $reaction->getListOfModifiers();

  # iterate list of modifiers for ith reaction
  # and translate SpeciesReferences to Species
  my @modifiers = ();
  for (0..$ListOfModifiers->size()-1) {
    push @modifiers, $ListOfModifiers->get($_)->getSpecies();
  }

  # print modifiers
  print "Modifier(s): ", join(", ", @modifiers), "\n\n";
}

# The following code does exactly the same thing as the above code. 
# Note how short and elegant the code gets if list context is used.

print "\nUsing Method getListOfXXXX in list context!!!\n\n";

print
    "Species: ",
    join(", ", map{$_->getId()} $model->getListOfSpecies()), "\n\n";

foreach my $reaction ($model->getListOfReactions()) {
  print
      "Reaction with Id ", $reaction->getId(), "\nhas ",
      $reaction->getNumReactants(), " Reactant(s), ",
      $reaction->getNumProducts(), " Product(s), ",      
      $reaction->getNumModifiers(), " Modifier(s)\n",       
      "Reactant(s): ",
      join(", ", map{$_->getSpecies()} $reaction->getListOfReactants()), "\n",
      "Product(s): ",
      join(", ", map{$_->getSpecies()} $reaction->getListOfProducts()), "\n",
      "Modyfier(s): ",
      join(", ", map{$_->getSpecies()} $reaction->getListOfModifiers()),"\n\n",
}

print "Both methods should give the same output =;)\n";

__END__

