# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl GRN-Models.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;

BEGIN { plan tests => 390 };

use LibSBML;
use strict;
use Data::Dumper;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my @SBaseClassList = (
  "FunctionDefinition",
  "UnitDefinition",
  "CompartmentType",
  "SpeciesType",
  "Compartment",
  "Species",
  "Parameter",
  "InitialAssignment",
  "AssignmentRule",
  "AlgebraicRule",
  "RateRule",
  "Constraint",
  "Reaction",
  "SpeciesReference",
  "ModifierSpeciesReference",
  "Event",
  "EventAssignment",
  "Unit",
  "UnitDefinition",
  "Trigger",
  "Delay",
  "ListOf",
  "ListOfCompartments",
  "ListOfCompartmentTypes",
  "ListOfConstraints",
  "ListOfEvents",
  "ListOfEventAssignments",
  "ListOfFunctionDefinitions",
  "ListOfInitialAssignments",
  "ListOfParameters",
  "ListOfReactions",
  "ListOfRules",
  "ListOfSpecies",
  "ListOfSpeciesReferences",
  "ListOfSpeciesTypes",
  "ListOfUnits",
  "ListOfUnitDefinitions",
  "StoichiometryMath",
);

my @MiscClassList = (
   "XMLToken",
   "XMLNode",
   "XMLTriple",
   "CVTerm",
   "Date",
   "ModelCreator",
   "XMLAttributes",
   "XMLNamespaces",
);

#########################

my $lo = new LibSBML::ListOf;

my $level   = 2;
my $version = 4;

foreach my $class ( map { "LibSBML::" . $_ } @SBaseClassList )
{
   #my $obj = ($class !~ /ListOf/) ? new $class($level,$version) : new $class;
   my $obj = new $class($level,$version);
   ok(&isOwned($obj), 1);
   ok(ref $obj, $class);
   my $clone = &checkClone($obj,ref($obj));

   $lo->append($clone);
   ok(ref $lo->get(0), $class);
   ok(&isOwned($lo->get(0)), undef);
   ok(&isOwned($lo->remove(0)), 1);
}

foreach my $class ( map { "LibSBML::" . $_ } @MiscClassList )
{
   my $obj = new $class;
   ok(&isOwned($obj), 1);
   ok(ref $obj, $class);
   my $clone = &checkClone($obj,ref($obj));
}

#########################

sub checkClone {
   my($obj,$class) = @_;

   ok(&isOwned($obj), 1);
   ok(ref($obj), $class);

   my $clone = $obj->clone();

   ok(&isOwned($clone), 1);
   ok(ref($clone), $class);

   $clone;
}

#
# ownership check code for SBase derived classes.
#

no strict 'refs';

sub isOwned {
  my $self = shift;

  my $ptr   = tied(%$self);
  my $class = ref($self);

  return ${"${class}::OWNER"}{$ptr};
}
