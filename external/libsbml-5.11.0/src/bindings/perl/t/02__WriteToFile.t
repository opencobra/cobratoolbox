# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl GRN-Models.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1 };

use LibSBML;
use File::Spec;
use strict;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $d = new LibSBML::SBMLDocument(2,4);
my $m = $d->createModel();
$m->setId('xtof');
my $s = $m->createSpecies();
$s->setId('rainer');
my $file = File::Spec->catfile('t','tmpfile');
$d->writeSBML($file);

my $rd   = new LibSBML::SBMLReader;
my $tmp  = $rd->readSBML($file);
my $doc  = $tmp->writeSBMLToString();
my $ref = join '', <DATA>;
ok($doc, $ref);
unlink($file);

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<sbml xmlns="http://www.sbml.org/sbml/level2/version4" level="2" version="4">
  <model id="xtof">
    <listOfSpecies>
      <species id="rainer"/>
    </listOfSpecies>
  </model>
</sbml>
