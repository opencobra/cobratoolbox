/**
 * Filename    : TestSBMLHandler.cpp
 * Description : Unit tests for SBMLHandler with respect the the layout extension.
 * Organization: European Media Laboratories Research gGmbH
 * Created     : 2005-10-11
 *
 * <!--------------------------------------------------------------------------
 * This file is part of libSBML.  Please visit http://sbml.org for more
 * information about SBML, and the latest version of libSBML.
 *
 * Copyright (C) 2013-2014 jointly by the following organizations:
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *     3. University of Heidelberg, Heidelberg, Germany
 * 
 * Copyright (C) 2009-2013 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *  
 * Copyright (C) 2004-2008 by European Media Laboratories Research gGmbH,
 *     Heidelberg, Germany
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 */

#include <iostream>

#include <sbml/common/common.h>
#include <sbml/common/extern.h>

#include <sbml/SBMLReader.h>
#include <sbml/SBMLDocument.h>
#include <sbml/Model.h>
#include <sbml/Reaction.h>
#include <sbml/Compartment.h>
#include <sbml/Species.h>
#include <sbml/SpeciesReference.h>
#include <sbml/ModifierSpeciesReference.h>

#include <sbml/packages/layout/sbml/Layout.h>
#include <sbml/packages/layout/sbml/Dimensions.h>
#include <sbml/packages/layout/sbml/CompartmentGlyph.h>
#include <sbml/packages/layout/sbml/SpeciesGlyph.h>
#include <sbml/packages/layout/sbml/ReactionGlyph.h>
#include <sbml/packages/layout/sbml/TextGlyph.h>
#include <sbml/packages/layout/sbml/LineSegment.h>
#include <sbml/packages/layout/sbml/CubicBezier.h>

#include <sbml/packages/layout/extension/LayoutModelPlugin.h>
#include <sbml/packages/layout/extension/LayoutSpeciesReferencePlugin.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static SBMLDocument *D;


void
SBMLHandlerTest_setup (void)
{
  D = NULL;
}

void
SBMLHandlerTest_teardown (void)
{
  delete D;
}

START_TEST (test_SBMLHandler_Layout)
{
	std::string s =
	"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
	"<sbml xmlns=\"http://www.sbml.org/sbml/level2\" level=\"2\" version=\"1\" xmlns:layout=\"http://projects.eml.org/bcb/sbml/level2\">"
	"<model id=\"TestModel_with_modifiers\">"
	"<annotation>"
	"<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
	"  <layout id=\"Layout_1\">"
	"<dimensions width=\"400\" height=\"230\">"
	"</dimensions>"
	"<listOfCompartmentGlyphs>"
	"<compartmentGlyph id=\"CompartmentGlyph_1\" compartment=\"Yeast\">"
	"<boundingBox id=\"bb1\">"
	"<position x=\"5\" y=\"5\">"
	"</position>"
	"<dimensions width=\"390\" height=\"220\">"
	"</dimensions>"
	"</boundingBox>"
	"</compartmentGlyph>"
	"</listOfCompartmentGlyphs>"
	"<listOfSpeciesGlyphs>"
	"<speciesGlyph id=\"SpeciesGlyph_Glucose\" species=\"Glucose\">"
	"<boundingBox id=\"bb2\">"
	"<position x=\"105\" y=\"20\">"
	"</position>"
	"<dimensions width=\"130\" height=\"20\">"
	"</dimensions>"
	"</boundingBox>"
	"</speciesGlyph>"
	"<speciesGlyph id=\"SpeciesGlyph_G6P\" species=\"Glucose_6_phosphate\">"
	"<boundingBox id=\"bb5\">"
	"<position x=\"50\" y=\"190\">"
	"</position>"
	"<dimensions width=\"270\" height=\"20\">"
	"</dimensions>"
	"</boundingBox>"
	"</speciesGlyph>"
	"<speciesGlyph id=\"SpeciesGlyph_ATP\" species=\"ATP\">"
	"<boundingBox id=\"bb3\">"
	"<position x=\"270\" y=\"70\">"
	"</position>"
	"<dimensions width=\"80\" height=\"20\">"
	"</dimensions>"
	"</boundingBox>"
	"</speciesGlyph>"
	"<speciesGlyph id=\"glyph_ADP\" species=\"ADP\">"
	"<boundingBox id=\"bb4\">"
	"<position x=\"270\" y=\"140\">"
	"</position>"
	"<dimensions width=\"80\" height=\"20\">"
	"</dimensions>"
	"</boundingBox>"
	"</speciesGlyph>"
	"<speciesGlyph id=\"SpeciesGlyph_Pi\" species=\"Pi\">"
	"<boundingBox id=\"bb6\">"
	"<position x=\"50\" y=\"100\">"
	"</position>"
	"<dimensions width=\"60\" height=\"20\">"
	"</dimensions>"
	"</boundingBox>"
	"</speciesGlyph>"
	"</listOfSpeciesGlyphs>"
	"<listOfReactionGlyphs>"
	"<reactionGlyph id=\"glyph_Hexokinase\" reaction=\"Hexokinase\">"
	"<curve>"
	"<listOfCurveSegments>"
	"<curveSegment xsi:type=\"LineSegment\">"
	"<start x=\"170\" y=\"100\">"
	"</start>"
	"<end x=\"170\" y=\"130\">"
	"</end>"
	"</curveSegment>"
	"</listOfCurveSegments>"
	"</curve>"
	"<listOfSpeciesReferenceGlyphs>"
	"<speciesReferenceGlyph id=\"SpeciesReferenceGlyph_Glucose\" speciesReference=\"SpeciesReference_Glucose\" speciesGlyph=\"SpeciesGlyph_Glucose\" role=\"substrate\">"
	"<curve>"
	"<listOfCurveSegments>"
	"<curveSegment xsi:type=\"LineSegment\">"
	"<start x=\"170\" y=\"100\">"
	"</start>"
	"<end x=\"170\" y=\"50\">"
	"</end>"
	"</curveSegment>"
	"</listOfCurveSegments>"
	"</curve>"
	"</speciesReferenceGlyph>"
	"<speciesReferenceGlyph id=\"SpeciesReferenceGlyph_ATP\" speciesReference=\"SpeciesReference_ATP\" speciesGlyph=\"SpeciesGlyph_ATP\" role=\"sidesubstrate\">"
	"<curve>"
	"<listOfCurveSegments>"
	"<curveSegment xsi:type=\"CubicBezier\">"
	"<start x=\"170\" y=\"100\">"
	"</start>"
	"<end x=\"260\" y=\"80\">"
	"</end>"
	"<basePoint1 x=\"170\" y=\"80\">"
	"</basePoint1>"
	"<basePoint2 x=\"170\" y=\"80\">"
	"</basePoint2>"
	"</curveSegment>"
	"</listOfCurveSegments>"
	"</curve>"
	"</speciesReferenceGlyph>"
	"<speciesReferenceGlyph id=\"SpeciesReferenceGlyph_G6P_1\" speciesReference=\"SpeciesReference_G6P\" speciesGlyph=\"SpeciesGlyph_G6P\" role=\"product\">"
	"<curve>"
	"<listOfCurveSegments>"
	"<curveSegment xsi:type=\"LineSegment\">"
	"<start x=\"170\" y=\"130\">"
	"</start>"
	"<end x=\"170\" y=\"180\">"
	"</end>"
	"</curveSegment>"
	"</listOfCurveSegments>"
	"</curve>"
	"</speciesReferenceGlyph>"
	"<speciesReferenceGlyph id=\"SpeciesReferenceGlyph_ADP\" speciesReference=\"SpeciesReference_ADP\" speciesGlyph=\"glyph_ADP\" role=\"sideproduct\">"
	"<curve>"
	"<listOfCurveSegments>"
	"<curveSegment xsi:type=\"CubicBezier\">"
	"<start x=\"170\" y=\"130\">"
	"</start>"
	"<end x=\"260\" y=\"150\">"
	"</end>"
	"<basePoint1 x=\"170\" y=\"150\">"
	"</basePoint1>"
	"<basePoint2 x=\"170\" y=\"150\">"
	"</basePoint2>"
	"</curveSegment>"
	"</listOfCurveSegments>"
	"</curve>"
	"</speciesReferenceGlyph>"
	"<speciesReferenceGlyph id=\"SpeciesReferenceGlyph_G6P_2\" speciesReference=\"ModifierSpeciesReference_G6P\" speciesGlyph=\"SpeciesGlyph_G6P\" role=\"inhibitor\">"
	"<curve>"
	"<listOfCurveSegments>"
	"<curveSegment xsi:type=\"CubicBezier\">"
	"<start x=\"45\" y=\"200\">"
	"</start>"
	"<end x=\"165\" y=\"120\">"
	"</end>"
	"<basePoint1 x=\"0\" y=\"200\">"
	"</basePoint1>"
	"<basePoint2 x=\"0\" y=\"120\">"
	"</basePoint2>"
	"</curveSegment>"
	"</listOfCurveSegments>"
	"</curve>"
	"</speciesReferenceGlyph>"
	"<speciesReferenceGlyph id=\"SpeciesReferenceGlyph_PI\" speciesReference=\"ModifierSpeciesReference_Pi\" speciesGlyph=\"SpeciesGlyph_Pi\" role=\"activator\">"
	"<curve>"
	"<listOfCurveSegments>"
	"<curveSegment xsi:type=\"CubicBezier\">"
	"<start x=\"115\" y=\"110\">"
	"</start>"
	"<end x=\"165\" y=\"110\">"
	"</end>"
	"<basePoint1 x=\"140\" y=\"110\">"
	"</basePoint1>"
	"<basePoint2 x=\"140\" y=\"110\">"
	"</basePoint2>"
	"</curveSegment>"
	"</listOfCurveSegments>"
	"</curve>"
	"</speciesReferenceGlyph>"
	"</listOfSpeciesReferenceGlyphs>"
	"</reactionGlyph>"
	"</listOfReactionGlyphs>"
	"<listOfTextGlyphs>"
	"<textGlyph id=\"TextGlyph_Glucose\" graphicalObject=\"SpeciesGlyph_Glucose\" originOfText=\"Glucose\">"
	"<boundingBox id=\"bbA\">"
	"<position x=\"115\" y=\"20\">"
	"</position>"
	"<dimensions width=\"110\" height=\"20\">"
	"</dimensions>"
	"</boundingBox>"
	"</textGlyph>"
	"<textGlyph id=\"TextGlyph_G6P\" graphicalObject=\"SpeciesGlyph_G6P\" originOfText=\"Glucose_6_phosphate\">"
	"<boundingBox id=\"bbD\">"
	"<position x=\"60\" y=\"190\">"
	"</position>"
	"<dimensions width=\"250\" height=\"20\">"
	"</dimensions>"
	"</boundingBox>"
	"</textGlyph>"
	"<textGlyph id=\"TextGlyph_ATP\" graphicalObject=\"SpeciesGlyph_ATP\" originOfText=\"ATP\">"
	"<boundingBox id=\"bbB\">"
	"<position x=\"280\" y=\"70\">"
	"</position>"
	"<dimensions width=\"60\" height=\"20\">"
	"</dimensions>"
	"</boundingBox>"
	"</textGlyph>"
	"<textGlyph id=\"TextGlyph_ADP\" graphicalObject=\"glyph_ADP\" originOfText=\"ADP\">"
	"<boundingBox id=\"bbC\">"
	"<position x=\"280\" y=\"140\">"
	"</position>"
	"<dimensions width=\"60\" height=\"20\">"
	"</dimensions>"
	"</boundingBox>"
	"</textGlyph>"
	"<textGlyph id=\"TextGlyph_PI\" graphicalObject=\"SpeciesGlyph_Pi\" originOfText=\"Pi\">"
	"<boundingBox id=\"bbE\">"
	"<position x=\"60\" y=\"100\">"
	"</position>"
	"<dimensions width=\"40\" height=\"20\">"
	"</dimensions>"
	"</boundingBox>"
	"</textGlyph>"
	"</listOfTextGlyphs>"
	"  </layout>"
	"</listOfLayouts>"
	"</annotation>"
	"  <listOfCompartments>"
	"<compartment id=\"Yeast\"/>"
	"  </listOfCompartments>"
	"  <listOfSpecies>"
	"<species id=\"Glucose\" compartment=\"Yeast\"/>"
	"<species id=\"Glucose_6_phosphate\" compartment=\"Yeast\"/>"
	"<species id=\"ATP\" compartment=\"Yeast\"/>"
	"<species id=\"ADP\" compartment=\"Yeast\"/>"
	"<species id=\"Pi\" compartment=\"Yeast\"/>"
	"  </listOfSpecies>"
	"  <listOfReactions>"
	"<reaction id=\"Hexokinase\" reversible=\"false\">"
	"<listOfReactants>"
	"<speciesReference species=\"Glucose\">"
	"<annotation>"
	"<layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"SpeciesReference_Glucose\"/>"
	"</annotation>"
	"</speciesReference>"
	"<speciesReference species=\"ATP\">"
	"<annotation>"
	"<layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"SpeciesReference_ATP\"/>"
	"</annotation>"
	"</speciesReference>"
	"</listOfReactants>"
	"<listOfProducts>"
	"<speciesReference species=\"Glucose_6_phosphate\">"
	"<annotation>"
	"<layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"SpeciesReference_G6P\"/>"
	"</annotation>"
	"</speciesReference>"
	"<speciesReference species=\"ADP\">"
	"<annotation>"
	"<layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"SpeciesReference_ADP\"/>"
	"</annotation>"
	"</speciesReference>"
	"</listOfProducts>"
	"<listOfModifiers>"
	"<modifierSpeciesReference species=\"Glucose_6_phosphate\">"
	"<annotation>"
	"<layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"ModifierSpeciesReference_G6P\"/>"
	"</annotation>"
	"</modifierSpeciesReference>"
	"<modifierSpeciesReference species=\"Pi\">"
	"<annotation>"
	"<layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"ModifierSpeciesReference_Pi\"/>"
	"</annotation>"
	"</modifierSpeciesReference>"
	"</listOfModifiers>"
	"</reaction>"
	"  </listOfReactions>"
	"</model>"
	"</sbml>";
	
  SBMLReader reader=SBMLReader();
  
  D = reader.readSBMLFromString(s);
  
  fail_unless(D!=NULL);
  
  Model* model=D->getModel();
  
  fail_unless(model!=NULL);
  
  // test compartments
  fail_unless(model->getNumCompartments()==1);
  
  Compartment* c=model->getCompartment(0);
  
  fail_unless(c!=NULL);
  
  fail_unless(c->isSetId());
  
  fail_unless(c->getId()=="Yeast");
  
  fail_unless(!c->isSetName());
  
  // test species
  fail_unless(model->getNumSpecies()==5);
  
  Species* species=model->getSpecies(0);
  
  fail_unless(species!=NULL);
  
  fail_unless(species->getCompartment()=="Yeast");
  
  fail_unless(species->isSetId());
  
  fail_unless(species->getId()=="Glucose");
  
  fail_unless(!species->isSetName());
  
  species=model->getSpecies(1);
  
  fail_unless(species!=NULL);
  
  fail_unless(species->getCompartment()=="Yeast");
  
  fail_unless(species->isSetId());
  
  fail_unless(species->getId()=="Glucose_6_phosphate");
  
  fail_unless(!species->isSetName());
  
  species=model->getSpecies(2);
  
  fail_unless(species!=NULL);
  
  fail_unless(species->getCompartment()=="Yeast");
  
  fail_unless(species->isSetId());
  
  fail_unless(species->getId()=="ATP");
  
  fail_unless(!species->isSetName());
  
  species=model->getSpecies(3);
  
  fail_unless(species!=NULL);
  
  fail_unless(species->getCompartment()=="Yeast");
  
  fail_unless(species->isSetId());
  
  fail_unless(species->getId()=="ADP");
  
  fail_unless(!species->isSetName());
  
  species=model->getSpecies(4);
  
  fail_unless(species!=NULL);
  
  fail_unless(species->getCompartment()=="Yeast");
  
  fail_unless(species->isSetId());
  
  fail_unless(species->getId()=="Pi");
  
  fail_unless(!species->isSetName());
  
  // test reactions
  fail_unless(model->getNumReactions()==1);
  
  Reaction* r=model->getReaction(0);
  
  fail_unless(r!=NULL);
  
  fail_unless(r->isSetId());
  
  fail_unless(r->getId()=="Hexokinase");
  
  fail_unless(!r->isSetName());
  
  fail_unless(r->getNumReactants()==2);
  
  SpeciesReference* sr=r->getReactant(0);
  
  fail_unless(sr!=NULL);
  
  fail_unless(sr->isSetSpecies());
  
  fail_unless(sr->getSpecies()=="Glucose");
  
  fail_unless(sr->isSetId());
  fail_unless(sr->getId()=="SpeciesReference_Glucose");
  
  sr=r->getReactant(1);
  
  fail_unless(sr!=NULL);
  
  fail_unless(sr->isSetSpecies());
  
  fail_unless(sr->getSpecies()=="ATP");
  
  fail_unless(sr->isSetId());
  fail_unless(sr->getId()=="SpeciesReference_ATP");
  
  fail_unless(r->getNumProducts()==2);
  
  sr=r->getProduct(0);
  
  fail_unless(sr!=NULL);
  
  fail_unless(sr->isSetSpecies());
  
  fail_unless(sr->getSpecies()=="Glucose_6_phosphate");
  
  fail_unless(sr->isSetId());
  fail_unless(sr->getId()=="SpeciesReference_G6P");
  
  sr=r->getProduct(1);
  
  fail_unless(sr!=NULL);
  
  fail_unless(sr->isSetSpecies());
  
  fail_unless(sr->getSpecies()=="ADP");
  
  fail_unless(sr->isSetId());
  fail_unless(sr->getId()=="SpeciesReference_ADP");
  
  
  fail_unless(r->getNumModifiers()==2);
  
  ModifierSpeciesReference* msr=r->getModifier(0);
  
  fail_unless(msr!=NULL);
  
  fail_unless(msr->isSetSpecies());
  
  fail_unless(msr->getSpecies()=="Glucose_6_phosphate");
  
  fail_unless(msr->isSetId());
  fail_unless(msr->getId()=="ModifierSpeciesReference_G6P");
  
  msr=r->getModifier(1);
  
  fail_unless(msr!=NULL);
  
  fail_unless(msr->isSetSpecies());
  fail_unless(msr->getSpecies()=="Pi");
  
  fail_unless(msr->isSetId());
  fail_unless(msr->getId()=="ModifierSpeciesReference_Pi");
  
  LayoutModelPlugin *mplugin = static_cast<LayoutModelPlugin*>(model->getPlugin("layout"));
	
  fail_unless(mplugin != NULL);
  
  // test layout
  fail_unless(mplugin->getListOfLayouts()->size()==1);
  
  Layout* l=mplugin->getLayout(0);
  
  fail_unless(l!=NULL);
  
  fail_unless(l->isSetId());
  
  fail_unless(l->getId()=="Layout_1");
  
  Dimensions* dimensions=l->getDimensions();
  
  fail_unless(dimensions!=NULL);
  
  fail_unless(dimensions->getWidth()==400.0);
  
  fail_unless(dimensions->getHeight()==230.0);
  
  fail_unless(dimensions->getDepth()==0.0);
  
  // CompartmentGlyphs
  fail_unless(l->getNumCompartmentGlyphs()==1);
  
  CompartmentGlyph* cg=l->getCompartmentGlyph(0);
  
  fail_unless(cg!=NULL);
  
  fail_unless(cg->isSetId());
  
  fail_unless(cg->getId()=="CompartmentGlyph_1");
  
  fail_unless(cg->isSetCompartmentId());
  
  fail_unless(cg->getCompartmentId()=="Yeast");
  
  BoundingBox* bb=cg->getBoundingBox();
  
  fail_unless(bb!=NULL);
  
  fail_unless(bb->isSetId());
  
  fail_unless(bb->getId()=="bb1");
  
  Point* position=bb->getPosition();
  
  fail_unless(position->getXOffset()==5.0);
  
  fail_unless(position->getYOffset()==5.0);
  
  fail_unless(position->getZOffset()==0.0);
  
  fail_unless(bb!=NULL);
  
  dimensions=bb->getDimensions();
  
  fail_unless(dimensions!=NULL);
  
  fail_unless(dimensions->getWidth()==390.0);
  
  fail_unless(dimensions->getHeight()==220.0);
  
  fail_unless(dimensions->getDepth()==0.0);
  
  
  
  
  // SpeciesGlyphs
  fail_unless(l->getNumSpeciesGlyphs()==5);
  
  SpeciesGlyph* sg=l->getSpeciesGlyph(0);
  
  fail_unless(sg!=NULL);
  
  fail_unless(sg->isSetId());
  
  fail_unless(sg->getId()=="SpeciesGlyph_Glucose");
  
  fail_unless(sg->isSetSpeciesId());
  
  fail_unless(sg->getSpeciesId()=="Glucose");
  
  bb=sg->getBoundingBox();
  
  fail_unless(bb!=NULL);
  
  fail_unless(bb->isSetId());
  
  fail_unless(bb->getId()=="bb2");
  
  position=bb->getPosition();
  
  fail_unless(position != NULL);
  
  fail_unless(position->getXOffset()==105.0);
  
  fail_unless(position->getYOffset()==20.0);
  
  fail_unless(position->getZOffset()==0.0);
  
  dimensions=bb->getDimensions();
  
  fail_unless(dimensions!=NULL);
  
  fail_unless(dimensions->getWidth()==130.0);
  
  fail_unless(dimensions->getHeight()==20.0);
  
  fail_unless(dimensions->getDepth()==0.0);
  
  sg=l->getSpeciesGlyph(1);
  
  fail_unless(sg!=NULL);
  
  fail_unless(sg->isSetId());
  
  fail_unless(sg->getId()=="SpeciesGlyph_G6P");
  
  fail_unless(sg->isSetSpeciesId());
  
  fail_unless(sg->getSpeciesId()=="Glucose_6_phosphate");
  
  bb=sg->getBoundingBox();
  
  fail_unless(bb!=NULL);
  
  fail_unless(bb->isSetId());
  
  fail_unless(bb->getId()=="bb5");
  
  position=bb->getPosition();
  
  fail_unless(position != NULL);
  
  fail_unless(position->getXOffset()==50.0);
  
  fail_unless(position->getYOffset()==190.0);
  
  fail_unless(position->getZOffset()==0.0);
  
  fail_unless(bb!=NULL);
  
  dimensions=bb->getDimensions();
  
  fail_unless(dimensions!=NULL);
  
  fail_unless(dimensions->getWidth()==270.0);
  
  fail_unless(dimensions->getHeight()==20.0);
  
  fail_unless(dimensions->getDepth()==0.0);
  
  sg=l->getSpeciesGlyph(2);
  
  fail_unless(sg!=NULL);
  
  fail_unless(sg->isSetId());
  
  fail_unless(sg->getId()=="SpeciesGlyph_ATP");
  
  fail_unless(sg->isSetSpeciesId());
  
  fail_unless(sg->getSpeciesId()=="ATP");
  
  bb=sg->getBoundingBox();
  
  fail_unless(bb->isSetId());
  
  fail_unless(bb->getId()=="bb3");
  
  fail_unless(bb!=NULL);
  
  position=bb->getPosition();
  
  fail_unless(position != NULL);
  
  fail_unless(position->getXOffset()==270.0);
  
  fail_unless(position->getYOffset()==70.0);
  
  fail_unless(position->getZOffset()==0.0);
  
  fail_unless(bb!=NULL);
  
  dimensions=bb->getDimensions();
  
  fail_unless(dimensions!=NULL);
  
  fail_unless(dimensions->getWidth()==80.0);
  
  fail_unless(dimensions->getHeight()==20.0);
  
  fail_unless(dimensions->getDepth()==0.0);
  
  sg=l->getSpeciesGlyph(3);
  
  fail_unless(sg!=NULL);
  
  fail_unless(sg->isSetId());
  
  fail_unless(sg->getId()=="glyph_ADP");
  
  fail_unless(sg->isSetSpeciesId());
  
  fail_unless(sg->getSpeciesId()=="ADP");
  
  bb=sg->getBoundingBox();
  
  fail_unless(bb!=NULL);
  
  fail_unless(bb->isSetId());
  
  fail_unless(bb->getId()=="bb4");
  
  position=bb->getPosition();
  
  fail_unless(position != NULL);
  
  fail_unless(position->getXOffset()==270.0);
  
  fail_unless(position->getYOffset()==140.0);
  
  fail_unless(position->getZOffset()==0.0);
  
  fail_unless(bb!=NULL);
  
  dimensions=bb->getDimensions();
  
  fail_unless(dimensions!=NULL);
  
  fail_unless(dimensions->getWidth()==80.0);
  
  fail_unless(dimensions->getHeight()==20.0);
  
  fail_unless(dimensions->getDepth()==0.0);
  
  sg=l->getSpeciesGlyph(4);
  
  fail_unless(sg!=NULL);
  
  fail_unless(sg->isSetId());
  
  fail_unless(sg->getId()=="SpeciesGlyph_Pi");
  
  fail_unless(sg->isSetSpeciesId());
  
  fail_unless(sg->getSpeciesId()=="Pi");
  
  bb=sg->getBoundingBox();
  
  fail_unless(bb!=NULL);
  
  fail_unless(bb->isSetId());
  
  fail_unless(bb->getId()=="bb6");
  
  position=bb->getPosition();
  
  fail_unless(position != NULL);
  
  fail_unless(position->getXOffset()==50.0);
  
  fail_unless(position->getYOffset()==100.0);
  
  fail_unless(position->getZOffset()==0.0);
  
  fail_unless(bb!=NULL);
  
  dimensions=bb->getDimensions();
  
  fail_unless(dimensions!=NULL);
  
  fail_unless(dimensions->getWidth()==60.0);
  
  fail_unless(dimensions->getHeight()==20.0);
  
  fail_unless(dimensions->getDepth()==0.0);
  
  
  // ReactionGlyphs
  fail_unless(l->getNumReactionGlyphs()==1);
  
  ReactionGlyph* rg=l->getReactionGlyph(0);
  
  fail_unless(rg!=NULL);
  
  fail_unless(rg->isSetId());
  
  fail_unless(rg->getId()=="glyph_Hexokinase");
  
  fail_unless(rg->isSetReactionId());
  
  fail_unless(rg->getReactionId()=="Hexokinase");
  
  fail_unless(rg->isSetCurve());
  
  Curve* curve=rg->getCurve();
  
  fail_unless(curve!=NULL);
  
  fail_unless(curve->getNumCurveSegments()==1);
  
  LineSegment* ls=curve->getCurveSegment(0);
  
  fail_unless(ls!=NULL);
  
  fail_unless(ls->getTypeCode()==SBML_LAYOUT_LINESEGMENT);
  
  Point* p=ls->getStart();
  
  fail_unless(p!=NULL);
  
  fail_unless(p->getXOffset()==170.0);
  
  fail_unless(p->getYOffset()==100.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  p=ls->getEnd();
  
  fail_unless(p != NULL);
  
  fail_unless(p->getXOffset()==170.0);
  
  fail_unless(p->getYOffset()==130.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  fail_unless(rg->getNumSpeciesReferenceGlyphs()==6);
  
  SpeciesReferenceGlyph* srg=rg->getSpeciesReferenceGlyph(0);
  
  fail_unless(srg!=NULL);
  
  fail_unless(srg->isSetId());
  
  fail_unless(srg->getId()=="SpeciesReferenceGlyph_Glucose");
  
  fail_unless(srg->isSetSpeciesReferenceId());
  
  fail_unless(srg->getSpeciesReferenceId()=="SpeciesReference_Glucose");
  
  fail_unless(srg->isSetSpeciesGlyphId());
  
  fail_unless(srg->getSpeciesGlyphId()=="SpeciesGlyph_Glucose");
  
  fail_unless(srg->getRole()==SPECIES_ROLE_SUBSTRATE);
  
  fail_unless(srg->isSetCurve());
  
  curve=srg->getCurve();
  
  fail_unless(curve!=NULL);
  
  fail_unless(curve->getNumCurveSegments()==1);
  
  ls=curve->getCurveSegment(0);
  
  fail_unless(ls!=NULL);
  
  fail_unless(ls->getTypeCode()==SBML_LAYOUT_LINESEGMENT);
  
  p=ls->getStart();
  
  fail_unless(p!=NULL);
  
  fail_unless(p->getXOffset()==170.0);
  
  fail_unless(p->getYOffset()==100.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  p=ls->getEnd();
  
  fail_unless(p != NULL);
  
  fail_unless(p->getXOffset()==170.0);
  
  fail_unless(p->getYOffset()==50.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  srg=rg->getSpeciesReferenceGlyph(1);
  
  fail_unless(srg!=NULL);
  
  fail_unless(srg->isSetId());
  
  fail_unless(srg->getId()=="SpeciesReferenceGlyph_ATP");
  
  fail_unless(srg->isSetSpeciesReferenceId());
  
  fail_unless(srg->getSpeciesReferenceId()=="SpeciesReference_ATP");
  
  fail_unless(srg->isSetSpeciesGlyphId());
  
  fail_unless(srg->getSpeciesGlyphId()=="SpeciesGlyph_ATP");
  
  fail_unless(srg->getRole()==SPECIES_ROLE_SIDESUBSTRATE);
  
  fail_unless(srg->isSetCurve());
  
  curve=srg->getCurve();
  
  fail_unless(curve!=NULL);
  
  fail_unless(curve->getNumCurveSegments()==1);
  
  ls=curve->getCurveSegment(0);
  
  fail_unless(ls!=NULL);
  
  fail_unless(ls->getTypeCode()==SBML_LAYOUT_CUBICBEZIER);
  
  p=ls->getStart();
  
  fail_unless(p!=NULL);
  
  fail_unless(p->getXOffset()==170.0);
  
  fail_unless(p->getYOffset()==100.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  p=ls->getEnd();
  
  fail_unless(p != NULL);
  
  fail_unless(p->getXOffset()==260.0);
  
  fail_unless(p->getYOffset()==80.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  CubicBezier* cb = static_cast<CubicBezier*>(ls);
	
  fail_unless(cb  != NULL);
  
  p=cb->getBasePoint1();
  
  fail_unless(p != NULL);
  
  fail_unless(p->getXOffset()==170.0);
  
  fail_unless(p->getYOffset()==80.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  p=cb->getBasePoint2();
  
  fail_unless(p != NULL);
  
  fail_unless(p->getXOffset()==170.0);
  
  fail_unless(p->getYOffset()==80.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  srg=rg->getSpeciesReferenceGlyph(2);
  
  fail_unless(srg!=NULL);
  
  fail_unless(srg->isSetId());
  
  fail_unless(srg->getId()=="SpeciesReferenceGlyph_G6P_1");
  
  fail_unless(srg->isSetSpeciesReferenceId());
  
  fail_unless(srg->getSpeciesReferenceId()=="SpeciesReference_G6P");
  
  fail_unless(srg->isSetSpeciesGlyphId());
  
  fail_unless(srg->getSpeciesGlyphId()=="SpeciesGlyph_G6P");
  
  fail_unless(srg->getRole()==SPECIES_ROLE_PRODUCT);
  
  fail_unless(srg->isSetCurve());
  
  curve=srg->getCurve();
  
  fail_unless(curve!=NULL);
  
  fail_unless(curve->getNumCurveSegments()==1);
  
  ls=curve->getCurveSegment(0);
  
  fail_unless(ls!=NULL);
  
  fail_unless(ls->getTypeCode()==SBML_LAYOUT_LINESEGMENT);
  
  p=ls->getStart();
  
  fail_unless(p!=NULL);
  
  fail_unless(p->getXOffset()==170.0);
  
  fail_unless(p->getYOffset()==130.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  p=ls->getEnd();
  
  fail_unless(p != NULL);
  
  fail_unless(p->getXOffset()==170.0);
  
  fail_unless(p->getYOffset()==180.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  srg=rg->getSpeciesReferenceGlyph(3);
  
  fail_unless(srg!=NULL);
  
  fail_unless(srg->isSetId());
  
  fail_unless(srg->getId()=="SpeciesReferenceGlyph_ADP");
  
  fail_unless(srg->isSetSpeciesReferenceId());
  
  fail_unless(srg->getSpeciesReferenceId()=="SpeciesReference_ADP");
  
  fail_unless(srg->isSetSpeciesGlyphId());
  
  fail_unless(srg->getSpeciesGlyphId()=="glyph_ADP");
  
  fail_unless(srg->getRole()==SPECIES_ROLE_SIDEPRODUCT);
  
  fail_unless(srg->isSetCurve());
  
  curve=srg->getCurve();
  
  fail_unless(curve!=NULL);
  
  fail_unless(curve->getNumCurveSegments()==1);
  
  ls=curve->getCurveSegment(0);
  
  fail_unless(ls!=NULL);
  
  fail_unless(ls->getTypeCode()==SBML_LAYOUT_CUBICBEZIER);
  
  p=ls->getStart();
  
  fail_unless(p!=NULL);
  
  fail_unless(p->getXOffset()==170.0);
  
  fail_unless(p->getYOffset()==130.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  p=ls->getEnd();
  
  fail_unless(p->getXOffset()==260.0);
  
  fail_unless(p->getYOffset()==150.0);
  
  fail_unless(p->getZOffset()==0.0);
  
	cb = static_cast<CubicBezier*>(ls);
	
  p=cb->getBasePoint1();
  
  fail_unless(p->getXOffset()==170.0);
  
  fail_unless(p->getYOffset()==150.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  p=cb->getBasePoint2();
  
  fail_unless(p->getXOffset()==170.0);
  
  fail_unless(p->getYOffset()==150.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  srg=rg->getSpeciesReferenceGlyph(4);
  
  fail_unless(srg!=NULL);
  
  fail_unless(srg->isSetId());
  
  fail_unless(srg->getId()=="SpeciesReferenceGlyph_G6P_2");
  
  fail_unless(srg->isSetSpeciesReferenceId());
  
  fail_unless(srg->getSpeciesReferenceId()=="ModifierSpeciesReference_G6P");
  
  fail_unless(srg->isSetSpeciesGlyphId());
  
  fail_unless(srg->getSpeciesGlyphId()=="SpeciesGlyph_G6P");
  
  fail_unless(srg->getRole()==SPECIES_ROLE_INHIBITOR);
  
  fail_unless(srg->isSetCurve());
  
  curve=srg->getCurve();
  
  fail_unless(curve!=NULL);
  
  fail_unless(curve->getNumCurveSegments()==1);
  
  ls=curve->getCurveSegment(0);
  
  fail_unless(ls!=NULL);
  
  fail_unless(ls->getTypeCode()==SBML_LAYOUT_CUBICBEZIER);
  
  p=ls->getStart();
  
  fail_unless(p!=NULL);
  
  fail_unless(p->getXOffset()==45.0);
  
  fail_unless(p->getYOffset()==200.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  p=ls->getEnd();
  
  fail_unless(p->getXOffset()==165.0);
  
  fail_unless(p->getYOffset()==120.0);
  
  fail_unless(p->getZOffset()==0.0);
  cb = static_cast<CubicBezier*>(ls);
  
  p=cb->getBasePoint1();
  
  fail_unless(p->getXOffset()==0.0);
  
  fail_unless(p->getYOffset()==200.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  p=cb->getBasePoint2();
  
  fail_unless(p->getXOffset()==0.0);
  
  fail_unless(p->getYOffset()==120.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  srg=rg->getSpeciesReferenceGlyph(5);
  
  fail_unless(srg!=NULL);
  
  fail_unless(srg->isSetId());
  
  fail_unless(srg->getId()=="SpeciesReferenceGlyph_PI");
  
  fail_unless(srg->isSetSpeciesReferenceId());
  
  fail_unless(srg->getSpeciesReferenceId()=="ModifierSpeciesReference_Pi");
  
  fail_unless(srg->isSetSpeciesGlyphId());
  
  fail_unless(srg->getSpeciesGlyphId()=="SpeciesGlyph_Pi");
  
  fail_unless(srg->getRole()==SPECIES_ROLE_ACTIVATOR);
  
  fail_unless(srg->isSetCurve());
  
  curve=srg->getCurve();
  
  fail_unless(curve!=NULL);
  
  fail_unless(curve->getNumCurveSegments()==1);
  
  ls=curve->getCurveSegment(0);
  
  fail_unless(ls!=NULL);
  
  fail_unless(ls->getTypeCode()==SBML_LAYOUT_CUBICBEZIER);
  
  p=ls->getStart();
  
  fail_unless(p!=NULL);
  
  fail_unless(p->getXOffset()==115.0);
  
  fail_unless(p->getYOffset()==110.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  p=ls->getEnd();
  
  fail_unless(p->getXOffset()==165.0);
  
  fail_unless(p->getYOffset()==110.0);
  
  fail_unless(p->getZOffset()==0.0);
	cb = static_cast<CubicBezier*>(ls);
  
  p=cb->getBasePoint1();
  
  fail_unless(p->getXOffset()==140.0);
  
  fail_unless(p->getYOffset()==110.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  p=cb->getBasePoint2();
  
  fail_unless(p->getXOffset()==140.0);
  
  fail_unless(p->getYOffset()==110.0);
  
  fail_unless(p->getZOffset()==0.0);
  
  // TextGlyphs
  fail_unless(l->getNumTextGlyphs()==5);
  
  TextGlyph* tg=l->getTextGlyph(0);
  
  fail_unless(tg!=NULL);
  
  fail_unless(tg->isSetId());
  
  fail_unless(tg->getId()=="TextGlyph_Glucose");
  
  fail_unless(tg->isSetGraphicalObjectId());
  
  fail_unless(tg->getGraphicalObjectId()=="SpeciesGlyph_Glucose");
  
  fail_unless(tg->isSetOriginOfTextId());
  
  fail_unless(tg->getOriginOfTextId()=="Glucose");
  
  bb=tg->getBoundingBox();
  
  fail_unless(bb!=NULL);
  
  fail_unless(bb->isSetId());
  
  fail_unless(bb->getId()=="bbA");
  
  position=bb->getPosition();
  
  fail_unless(position->getXOffset()==115.0);
  
  fail_unless(position->getYOffset()==20.0);
  
  fail_unless(position->getZOffset()==0.0);
  
  fail_unless(bb!=NULL);
  
  dimensions=bb->getDimensions();
  
  fail_unless(dimensions!=NULL);
  
  fail_unless(dimensions->getWidth()==110.0);
  
  fail_unless(dimensions->getHeight()==20.0);
  
  fail_unless(dimensions->getDepth()==0.0);
  
  tg=l->getTextGlyph(1);
  
  fail_unless(tg!=NULL);
  
  fail_unless(tg->isSetId());
  
  fail_unless(tg->getId()=="TextGlyph_G6P");
  
  fail_unless(tg->isSetGraphicalObjectId());
  
  fail_unless(tg->getGraphicalObjectId()=="SpeciesGlyph_G6P");
  
  fail_unless(tg->isSetOriginOfTextId());
  
  fail_unless(tg->getOriginOfTextId()=="Glucose_6_phosphate");
  
  bb=tg->getBoundingBox();
  
  fail_unless(bb!=NULL);
  
  fail_unless(bb->isSetId());
  
  fail_unless(bb->getId()=="bbD");
  
  position=bb->getPosition();
  
  fail_unless(position->getXOffset()==60.0);
  
  fail_unless(position->getYOffset()==190.0);
  
  fail_unless(position->getZOffset()==0.0);
  
  fail_unless(bb!=NULL);
  
  dimensions=bb->getDimensions();
  
  fail_unless(dimensions!=NULL);
  
  fail_unless(dimensions->getWidth()==250.0);
  
  fail_unless(dimensions->getHeight()==20.0);
  
  fail_unless(dimensions->getDepth()==0.0);
  
  tg=l->getTextGlyph(2);
  
  fail_unless(tg!=NULL);
  
  fail_unless(tg->isSetId());
  
  fail_unless(tg->getId()=="TextGlyph_ATP");
  
  fail_unless(tg->isSetGraphicalObjectId());
  
  fail_unless(tg->getGraphicalObjectId()=="SpeciesGlyph_ATP");
  
  fail_unless(tg->isSetOriginOfTextId());
  
  fail_unless(tg->getOriginOfTextId()=="ATP");
  
  bb=tg->getBoundingBox();
  
  fail_unless(bb!=NULL);
  
  fail_unless(bb->isSetId());
  
  fail_unless(bb->getId()=="bbB");
  
  position=bb->getPosition();
  
  fail_unless(position->getXOffset()==280.0);
  
  fail_unless(position->getYOffset()==70.0);
  
  fail_unless(position->getZOffset()==0.0);
  
  fail_unless(bb!=NULL);
  
  dimensions=bb->getDimensions();
  
  fail_unless(dimensions!=NULL);
  
  fail_unless(dimensions->getWidth()==60.0);
  
  fail_unless(dimensions->getHeight()==20.0);
  
  fail_unless(dimensions->getDepth()==0.0);
  
  tg=l->getTextGlyph(3);
  
  fail_unless(tg!=NULL);
  
  fail_unless(tg->isSetId());
  
  fail_unless(tg->getId()=="TextGlyph_ADP");
  
  fail_unless(tg->isSetGraphicalObjectId());
  
  fail_unless(tg->getGraphicalObjectId()=="glyph_ADP");
  
  fail_unless(tg->isSetOriginOfTextId());
  
  fail_unless(tg->getOriginOfTextId()=="ADP");
  
  bb=tg->getBoundingBox();
  
  fail_unless(bb!=NULL);
  
  fail_unless(bb->isSetId());
  
  fail_unless(bb->getId()=="bbC");
  
  position=bb->getPosition();
  
  fail_unless(position->getXOffset()==280.0);
  
  fail_unless(position->getYOffset()==140.0);
  
  fail_unless(position->getZOffset()==0.0);
  
  fail_unless(bb!=NULL);
  
  dimensions=bb->getDimensions();
  
  fail_unless(dimensions!=NULL);
  
  fail_unless(dimensions->getWidth()==60.0);
  
  fail_unless(dimensions->getHeight()==20.0);
  
  fail_unless(dimensions->getDepth()==0.0);
  
  tg=l->getTextGlyph(4);
  
  fail_unless(tg!=NULL);
  
  fail_unless(tg->isSetId());
  
  fail_unless(tg->getId()=="TextGlyph_PI");
  
  fail_unless(tg->isSetGraphicalObjectId());
  
  fail_unless(tg->getGraphicalObjectId()=="SpeciesGlyph_Pi");
  
  fail_unless(tg->isSetOriginOfTextId());
  
  fail_unless(tg->getOriginOfTextId()=="Pi");
  
  bb=tg->getBoundingBox();
  
  fail_unless(bb!=NULL);
  
  fail_unless(bb->isSetId());
  
  fail_unless(bb->getId()=="bbE");
  
  position=bb->getPosition();
  
  fail_unless(position->getXOffset()==60.0);
  
  fail_unless(position->getYOffset()==100.0);
  
  fail_unless(position->getZOffset()==0.0);
  
  fail_unless(bb!=NULL);
  
  dimensions=bb->getDimensions();
  
  fail_unless(dimensions!=NULL);
  
  fail_unless(dimensions->getWidth()==40.0);
  
  fail_unless(dimensions->getHeight()==20.0);
  
  fail_unless(dimensions->getDepth()==0.0);
  
  // GraphicalObjects
  fail_unless(l->getNumAdditionalGraphicalObjects()==0);
  
}
END_TEST



Suite *
create_suite_SBMLHandler (void)
{
  Suite *suite = suite_create("SBMLHandler");
  TCase *tcase = tcase_create("SBMLHandler");
  
  tcase_add_checked_fixture( tcase,
                            SBMLHandlerTest_setup,
                            SBMLHandlerTest_teardown );
  
  
  tcase_add_test( tcase, test_SBMLHandler_Layout                            );
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}




END_C_DECLS



