#!/usr/bin/perl
# -*-Perl-*-

#
# \file    example1-L3->pl
# \brief   SBML Layout example
# \author  Ralph Gauges
# \author  Akiya Jouraku
# \author  Frank Bergmann(ported to perl and adapted to use libsbml-5 package version)
#
#

# Copyright 2004 European Media Laboratories Research gGmbH
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 2->1 of the License, or
# any later version->
#
# This library is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE->  The software and
# documentation provided hereunder is on an "as is" basis, and the
# European Media Laboratories Research gGmbH have no obligations to
# provide maintenance, support, updates, enhancements or modifications->
# In no event shall the European Media Laboratories Research gGmbH be
# liable to any party for direct, indirect, special, incidental or
# consequential damages, including lost profits, arising out of the use of
# this software and its documentation, even if the European Media
# Laboratories Research gGmbH have been advised of the possibility of such
# damage->  See the GNU Lesser General Public License for more details->
#
# You should have received a copy of the GNU Lesser General Public License
# along with this library; if not, write to the Free Software Foundation,
# Inc->, 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA->
#
# The original code contained here was initially developed by:
#
#     Ralph Gaugess
#     Bioinformatics Group
#     European Media Laboratories Research gGmbH
#     Schloss-Wolfsbrunnenweg 31c
#     69118 Heidelberg
#     Germany
#
#     http://www->eml-research->de/english/Research/BCB/
#     mailto:ralph->gauges@eml-r->villa-bosch->de
#
# Contributor(s):
#

use blib '../../src/bindings/perl';
use LibSBML;
use strict;

# Creates an SBMLNamespaces object with the given SBML level, version
# package name, package version->
# 
#(NOTE) By defualt, the name of package(i->e-> "layout") will be used
# if the arugment for the prefix is missing or empty-> Thus the argument
# for the prefix can be added as follows:
# 
#    SBMLNamespaces sbmlns(3,1,"layout",1,"LAYOUT")
# 
my $sbmlns = new LibSBML::SBMLNamespaces(3, 1, "layout", 1);
# create the document
my $document=new LibSBML::SBMLDocument($sbmlns);
# set the "required" attribute of layout package  to "1"
$document->setPkgRequired("layout", 1);

# create the Model

my $model=$document->createModel();
$model->setId("TestModel");
$document->setModel($model);

# create the Compartment

my $compartment=$model->createCompartment();
$compartment->setId("Compartment_1");
$compartment->setConstant(1);
# create the Species

my $species1=$model->createSpecies();
$species1->setId("Species_1");
$species1->setCompartment($compartment->getId());
$species1->setHasOnlySubstanceUnits(0);
$species1->setBoundaryCondition(0);
$species1->setConstant(0);

my $species2=$model->createSpecies();
$species2->setId("Species_2");
$species2->setCompartment($compartment->getId());
$species2->setHasOnlySubstanceUnits(0);
$species2->setBoundaryCondition(0);
$species2->setConstant(0);

# create the Reactions

my $reaction1=$model->createReaction();
$reaction1->setId("Reaction_1");
$reaction1->setReversible(0);
$reaction1->setFast(0);

my $reference1=$reaction1->createReactant();
$reference1->setSpecies($species1->getId());
$reference1->setId("SpeciesReference_1");
$reference1->setConstant(0);


my $reference2= $reaction1->createProduct();
$reference2->setSpecies($species2->getId());
$reference2->setId("SpeciesReference_2");
$reference2->setConstant(0);

my $reaction2=$model->createReaction();
$reaction2->setId("Reaction_2");
$reaction2->setReversible(0);
$reaction2->setFast(0);

my $reference3=$reaction2->createReactant();
$reference3->setSpecies($species2->getId());
$reference3->setId("SpeciesReference_3");
$reference3->setConstant(0);

my $reference4=$reaction2->createProduct();
$reference4->setSpecies($species1->getId());
$reference4->setId("SpeciesReference_4");
$reference4->setConstant(0);


# create the Layout

#
# set the LayoutPkgNamespaces for Level 3 Version1 Layout Version 1
#
my $layoutns = new LibSBML::LayoutPkgNamespaces(3, 1, 1);


#
# Get a LayoutModelPlugin object plugged in the model object->
#
# The type of the returned value of SBase::getPlugin() function is SBasePlugin, and
# thus the value needs to be casted for the corresponding derived class->
#

my $mplugin = $model->getPlugin("layout");


if ($mplugin == '')
{
	die "[Fatal Error] Layout Extension Level ", $layoutns->getLevel(), " Version ", $layoutns->getVersion(), " package version ", $layoutns->getPackageVersion(), " is not registered.";
}
#
# Creates a Layout object via LayoutModelPlugin object->
#
my $layout = $mplugin->createLayout();
$layout->setId("Layout_1");
$layout->setDimensions(new LibSBML::Dimensions($layoutns,400.0,220.0));

# create the CompartmentGlyph

my $compartmentGlyph=$layout->createCompartmentGlyph();
$compartmentGlyph->setId("CompartmentGlyph_1");
$compartmentGlyph->setCompartmentId($compartment->getId());
$compartmentGlyph->setBoundingBox(new LibSBML::BoundingBox($layoutns,"bb1",5,5,390,210));


# create the SpeciesGlyphs

my $speciesGlyph1=$layout->createSpeciesGlyph();
$speciesGlyph1->setId("SpeciesGlyph_1");
$speciesGlyph1->setSpeciesId($species1->getId());
$speciesGlyph1->setBoundingBox(new LibSBML::BoundingBox($layoutns,"bb2",80,26,240,24));

my $textGlyph1=$layout->createTextGlyph();
$textGlyph1->setId("TextGlyph_01");
$textGlyph1->setBoundingBox(new LibSBML::BoundingBox($layoutns,"bbA",92,26,228,24));
$textGlyph1->setOriginOfTextId($speciesGlyph1->getId());
$textGlyph1->setGraphicalObjectId($speciesGlyph1->getId());


my $speciesGlyph2=$layout->createSpeciesGlyph();
$speciesGlyph2->setId("SpeciesGlyph_2");
$speciesGlyph2->setSpeciesId($species2->getId());
$speciesGlyph2->setBoundingBox(new LibSBML::BoundingBox($layoutns,"bb3",80,170,240,24));

my $textGlyph2=$layout->createTextGlyph();
$textGlyph2->setId("TextGlyph_02");
$textGlyph2->setBoundingBox(new LibSBML::BoundingBox($layoutns,"bbB",92,170,228,24));
$textGlyph2->setOriginOfTextId($speciesGlyph2->getId());
$textGlyph2->setGraphicalObjectId($speciesGlyph2->getId());

# create the ReactionGlyphs

my $reactionGlyph1=$layout->createReactionGlyph();
$reactionGlyph1->setId("ReactionGlyph_1");
$reactionGlyph1->setReactionId($reaction1->getId());

my $reactionCurve1=$reactionGlyph1->getCurve();
my $ls=$reactionCurve1->createLineSegment();
$ls->setStart(new LibSBML::Point($layoutns,165,105));
$ls->setEnd(new LibSBML::Point($layoutns,165,115));

my $reactionGlyph2=$layout->createReactionGlyph();
$reactionGlyph2->setId("ReactionGlyph_1");
$reactionGlyph2->setReactionId($reaction2->getId());

my $reactionCurve2=$reactionGlyph2->getCurve();
$ls=$reactionCurve2->createLineSegment();
$ls->setStart(new LibSBML::Point($layoutns,235,105));
$ls->setEnd(new LibSBML::Point($layoutns,235,115));

# add the SpeciesReferenceGlyphs

my $speciesReferenceGlyph1=$reactionGlyph1->createSpeciesReferenceGlyph();
$speciesReferenceGlyph1->setId("SpeciesReferenceGlyph_1");
$speciesReferenceGlyph1->setSpeciesGlyphId($speciesGlyph1->getId());
$speciesReferenceGlyph1->setSpeciesReferenceId($reference1->getId());
$speciesReferenceGlyph1->setRole($LibSBML::SPECIES_ROLE_SUBSTRATE);

my $speciesReferenceCurve1=$speciesReferenceGlyph1->getCurve();
my $cb=$speciesReferenceCurve1->createCubicBezier();
$cb->setStart(new LibSBML::Point($layoutns,165,105));
$cb->setBasePoint1(new LibSBML::Point($layoutns,165,90));
$cb->setBasePoint2(new LibSBML::Point($layoutns,165,90));
$cb->setEnd(new LibSBML::Point($layoutns,195,60));

my $speciesReferenceGlyph2=$reactionGlyph1->createSpeciesReferenceGlyph();
$speciesReferenceGlyph2->setId("SpeciesReferenceGlyph_2");
$speciesReferenceGlyph2->setSpeciesGlyphId($speciesGlyph2->getId());
$speciesReferenceGlyph2->setSpeciesReferenceId($reference2->getId());
$speciesReferenceGlyph2->setRole($LibSBML::SPECIES_ROLE_PRODUCT);

my $speciesReferenceCurve2=$speciesReferenceGlyph2->getCurve();
$cb=$speciesReferenceCurve2->createCubicBezier();
$cb->setStart(new LibSBML::Point($layoutns,165,115));
$cb->setBasePoint1(new LibSBML::Point($layoutns,165,130));
$cb->setBasePoint2(new LibSBML::Point($layoutns,165,130));
$cb->setEnd(new LibSBML::Point($layoutns,195,160));


my $speciesReferenceGlyph3=$reactionGlyph2->createSpeciesReferenceGlyph();
$speciesReferenceGlyph3->setId("SpeciesReferenceGlyph_3");
$speciesReferenceGlyph3->setSpeciesGlyphId($speciesGlyph2->getId());
$speciesReferenceGlyph3->setSpeciesReferenceId($reference3->getId());
$speciesReferenceGlyph3->setRole($LibSBML::SPECIES_ROLE_SUBSTRATE);

my $speciesReferenceCurve3=$speciesReferenceGlyph3->getCurve();
$cb=$speciesReferenceCurve3->createCubicBezier();
$cb->setStart(new LibSBML::Point($layoutns,235,115));
$cb->setBasePoint1(new LibSBML::Point($layoutns,235,130));
$cb->setBasePoint2(new LibSBML::Point($layoutns,235,130));
$cb->setEnd(new LibSBML::Point($layoutns,205,160));

my $speciesReferenceGlyph4=$reactionGlyph2->createSpeciesReferenceGlyph();
$speciesReferenceGlyph4->setId("SpeciesReferenceGlyph_4");
$speciesReferenceGlyph4->setSpeciesGlyphId($speciesGlyph1->getId());
$speciesReferenceGlyph4->setSpeciesReferenceId($reference4->getId());
$speciesReferenceGlyph4->setRole($LibSBML::SPECIES_ROLE_PRODUCT);

my $speciesReferenceCurve4=$speciesReferenceGlyph4->getCurve();
my $cb=$speciesReferenceCurve4->createCubicBezier();
$cb->setStart(new LibSBML::Point($layoutns,235,105));
$cb->setBasePoint1(new LibSBML::Point($layoutns,235,90));
$cb->setBasePoint2(new LibSBML::Point($layoutns,235,90));
$cb->setEnd(new LibSBML::Point($layoutns,205,60));

LibSBML::writeSBML($document,"layout_example1_L3-perl.xml");

