/**
 * @file    example3.cpp
 * @brief   SBML Layout example
 * @author  Ralph Gauges
 * @author  Akiya Jouraku (Modified this file for layout package of SBML Level 3
 * in libSBML 5)
 * 
 * Copyright 2004 European Media Laboratories Research gGmbH
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 2.1 of the License, or
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY, WITHOUT EVEN THE IMPLIED WARRANTY OF
 * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  The software and
 * documentation provided hereunder is on an "as is" basis, and the
 * European Media Laboratories Research gGmbH have no obligations to
 * provide maintenance, support, updates, enhancements or modifications.
 * In no event shall the European Media Laboratories Research gGmbH be
 * liable to any party for direct, indirect, special, incidental or
 * consequential damages, including lost profits, arising out of the use of
 * this software and its documentation, even if the European Media
 * Laboratories Research gGmbH have been advised of the possibility of such
 * damage.  See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * The original code contained here was initially developed by:
 *
 *     Ralph Gaugess
 *     Bioinformatics Group
 *     European Media Laboratories Research gGmbH
 *     Schloss-Wolfsbrunnenweg 31c
 *     69118 Heidelberg
 *     Germany
 *
 *     http://www.eml-research.de/english/Research/BCB/
 *     mailto:ralph.gauges@eml-r.villa-bosch.de
 */

#include "sbml/SBMLTypes.h"
#include "sbml/packages/layout/common/LayoutExtensionTypes.h"

#if (!defined LIBSBML_HAS_PACKAGE_LAYOUT)
#error "This example requires libSBML to be built with the layout extension."
#endif

LIBSBML_CPP_NAMESPACE_USE

int main(int argc, char** argv)
{
  //
  // Creates an SBMLNamespaces object with the given SBML level, version
  // package name.
  //

  SBMLNamespaces sbmlns(2, 3);
  sbmlns.addNamespace(LayoutExtension::getXmlnsL2(), "layout");

  // (NOTES) The above code creating an SBMLNamespaces object can be replaced
  //         with the following other style.
  //
  // (2) Creates a LayoutPkgNamespaces object (SBMLNamespace derived class
  //     for layout package. The class is basically used for createing an
  //     SBase derived objects belonging to the layout package) with the
  //     given SBML level, version.  (Package version is not required by
  //     Layout extension of SBML Level 2)
  //
  //        LayoutPkgNamespaces sbmlns(2, 3);
  //

  // create the document

  SBMLDocument *document = new SBMLDocument(&sbmlns);
  // create the Model

  Model* model = document->createModel();
  model->setId("TestModel_with_modifiers");
  document->setModel(model);

  // create the Layout

  LayoutPkgNamespaces layoutns(2, 3);

  LayoutModelPlugin* mplugin
    = static_cast<LayoutModelPlugin*>(model->getPlugin("layout"));
  Layout* layout = mplugin->createLayout();

  layout->setId("Layout_1");
  Dimensions dim(&layoutns, 400.0, 230.0);
  layout->setDimensions(&dim);


  // create the Compartment

  Compartment* compartment = model->createCompartment();
  compartment->setId("Yeast");

  // create the CompartmentGlyph

  CompartmentGlyph* compartmentGlyph = layout->createCompartmentGlyph();
  compartmentGlyph->setId("CompartmentGlyph_1");
  compartmentGlyph->setCompartmentId(compartment->getId());
  BoundingBox bb(&layoutns, "bb1", 5, 5, 390, 220);
  compartmentGlyph->setBoundingBox(&bb);

  // create the Species, SpeciesGlyphs and associated TextGlyphs

  // Glucose

  Species* species_Gluc = model->createSpecies();
  species_Gluc->setId("Glucose");
  species_Gluc->setCompartment(compartment->getId());

  SpeciesGlyph* glyph_Gluc = layout->createSpeciesGlyph();
  glyph_Gluc->setId("SpeciesGlyph_Glucose");
  glyph_Gluc->setSpeciesId(species_Gluc->getId());
  bb = BoundingBox(&layoutns, "bb2", 105, 20, 130, 20);
  glyph_Gluc->setBoundingBox(&bb);

  TextGlyph* tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_Glucose");
  bb = BoundingBox(&layoutns, "bbA", 115, 20, 110, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_Gluc->getId());
  tGlyph->setGraphicalObjectId(glyph_Gluc->getId());

  // Glucose-6-phosphate

  Species* species_G6P = model->createSpecies();
  species_G6P->setId("Glucose_hyphen_6_hyphen_phosphate");
  species_G6P->setCompartment(compartment->getId());

  SpeciesGlyph* glyph_G6P = layout->createSpeciesGlyph();
  glyph_G6P->setId("SpeciesGlyph_G6P");
  glyph_G6P->setSpeciesId(species_G6P->getId());
  bb = BoundingBox(&layoutns, "bb5", 50, 190, 270, 20);
  glyph_G6P->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_G6P");
  bb = BoundingBox(&layoutns, "bbD", 60, 190, 250, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_G6P->getId());
  tGlyph->setGraphicalObjectId(glyph_G6P->getId());

  // ATP

  Species* species_ATP = model->createSpecies();
  species_ATP->setId("ATP");
  species_ATP->setCompartment(compartment->getId());

  SpeciesGlyph* glyph_ATP = layout->createSpeciesGlyph();
  glyph_ATP->setId("SpeciesGlyph_ATP");
  glyph_ATP->setSpeciesId(species_ATP->getId());
  bb = BoundingBox(&layoutns, "bb3", 270, 70, 80, 20);
  glyph_ATP->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_ATP");
  bb = BoundingBox(&layoutns, "bbB", 280, 70, 60, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_ATP->getId());
  tGlyph->setGraphicalObjectId(glyph_ATP->getId());

  // ADP

  Species* species_ADP = model->createSpecies();
  species_ADP->setId("ADP");
  species_ADP->setCompartment(compartment->getId());

  SpeciesGlyph* glyph_ADP = layout->createSpeciesGlyph();
  glyph_ADP->setId("glyph_ADP");
  glyph_ADP->setSpeciesId(species_ADP->getId());
  bb = BoundingBox(&layoutns, "bb4", 270, 140, 80, 20);
  glyph_ADP->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_ADP");
  bb = BoundingBox(&layoutns, "bbC", 280, 140, 60, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_ADP->getId());
  tGlyph->setGraphicalObjectId(glyph_ADP->getId());

  // Phosphate

  Species* species_Pi = model->createSpecies();
  species_Pi->setId("Pi");
  species_Pi->setCompartment(compartment->getId());

  SpeciesGlyph* glyph_Pi = layout->createSpeciesGlyph();
  glyph_Pi->setId("SpeciesGlyph_Pi");
  glyph_Pi->setSpeciesId(species_Pi->getId());
  bb = BoundingBox(&layoutns, "bb6", 50, 100, 60, 20);
  glyph_Pi->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_PI");
  bb = BoundingBox(&layoutns, "bbE", 60, 100, 40, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_Pi->getId());
  tGlyph->setGraphicalObjectId(glyph_Pi->getId());

  // create the Reaction

  Reaction* reaction_Hexokinase = model->createReaction();
  reaction_Hexokinase->setId("Hexokinase");
  reaction_Hexokinase->setReversible(false);

  ReactionGlyph* glyph_Hexokinase = layout->createReactionGlyph();
  glyph_Hexokinase->setId("glyph_Hexokinase");
  glyph_Hexokinase->setReactionId(reaction_Hexokinase->getId());

  Curve* curve_Hexokinase = glyph_Hexokinase->getCurve();
  LineSegment* ls = curve_Hexokinase->createLineSegment();
  Point p(&layoutns, 170, 100);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 130);
  ls->setEnd(&p);

  // create the species reference for glucose

  SpeciesReference* reference_Gluc = reaction_Hexokinase->createReactant();
  reference_Gluc->setSpecies(species_Gluc->getId());
  reference_Gluc->setId("SpeciesReference_Glucose");

  // create species reference glyph for glucose

  SpeciesReferenceGlyph* speciesReferenceGlyph
    = glyph_Hexokinase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_Glucose");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_Gluc->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_Gluc->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SUBSTRATE);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 100);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 50);
  ls->setEnd(&p);

  // create species reference for ATP

  SpeciesReference* reference_ATP
    = reaction_Hexokinase->createReactant();
  reference_ATP->setSpecies(species_ATP->getId());
  reference_ATP->setId("SpeciesReference_ATP");

  // create the species reference glyph for ATP

  speciesReferenceGlyph = glyph_Hexokinase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_ATP");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_ATP->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_ATP->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SIDESUBSTRATE);

  CubicBezier* cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 100);
  cb->setStart(&p);
  p = Point(&layoutns, 170, 80);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 170, 80);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 260, 80);
  cb->setEnd(&p);

  // create species reference for G6P

  SpeciesReference* reference_G6P = reaction_Hexokinase->createProduct();
  reference_G6P->setSpecies(species_G6P->getId());
  reference_G6P->setId("SpeciesReference_G6P");

  // create species reference for G6P as product

  speciesReferenceGlyph = glyph_Hexokinase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_G6P_1");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_G6P->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_G6P->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_PRODUCT);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 130);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 180);
  ls->setEnd(&p);

  // create species reference for ADP

  SpeciesReference* reference_ADP = reaction_Hexokinase->createProduct();
  reference_ADP->setSpecies(species_ADP->getId());
  reference_ADP->setId("SpeciesReference_ADP");

  // create the species reference glyph for ADP

  speciesReferenceGlyph = glyph_Hexokinase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_ADP");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_ADP->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_ADP->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SIDEPRODUCT);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 130);
  cb->setStart(&p);
  p = Point(&layoutns, 170, 150);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 170, 150);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 260, 150);
  cb->setEnd(&p);

  // create modifier species reference for glucose-6-phosphate

  ModifierSpeciesReference* reference_G6P_2
    = reaction_Hexokinase->createModifier();
  reference_G6P_2->setSpecies(species_G6P->getId());
  reference_G6P_2->setId("ModifierSpeciesReference_G6P");

  reaction_Hexokinase->addModifier(reference_G6P_2);

  // create species reference glyph for G6P as a modifier

  speciesReferenceGlyph = glyph_Hexokinase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_G6P_2");
  speciesReferenceGlyph->setSpeciesReferenceId(reference_G6P_2->getId());
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_G6P->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_INHIBITOR);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 45, 200);
  cb->setStart(&p);
  p = Point(&layoutns, 0, 200);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 0, 120);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 165, 120);
  cb->setEnd(&p);

  // create modifier species reference for phosphate

  ModifierSpeciesReference* reference_Pi = reaction_Hexokinase->createModifier();
  reference_Pi->setSpecies(species_Pi->getId());
  reference_Pi->setId("ModifierSpeciesReference_Pi");

  reaction_Hexokinase->addModifier(reference_Pi);

  // create the species reference glyph for Phosphate

  speciesReferenceGlyph = glyph_Hexokinase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_PI");
  speciesReferenceGlyph->setSpeciesReferenceId(reference_Pi->getId());
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_Pi->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_ACTIVATOR);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 115, 110);
  cb->setStart(&p);
  p = Point(&layoutns, 140, 110);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 140, 110);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 165, 110);
  cb->setEnd(&p);

  // write model to file

  writeSBML(document, "layout_example3_L2.xml");
  delete document;

}

