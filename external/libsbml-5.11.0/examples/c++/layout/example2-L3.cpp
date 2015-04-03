/**
 * @file    example2-L3.cpp
 * @brief   SBML Layout example
 * @author  Ralph Gauges
 * @author  Akiya Jouraku (Modified this file for layout package of 
 * SBML Level 3 in libSBML 5)
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

#include "sbml/SBMLDocument.h"
#include "sbml/Model.h"
#include "sbml/Compartment.h"
#include "sbml/Species.h"
#include "sbml/SpeciesReference.h"
#include "sbml/Reaction.h"
#include "sbml/packages/layout/sbml/Layout.h"
#include "sbml/packages/layout/sbml/CompartmentGlyph.h"
#include "sbml/packages/layout/sbml/SpeciesGlyph.h"
#include "sbml/packages/layout/sbml/ReactionGlyph.h"
#include "sbml/packages/layout/sbml/SpeciesReferenceGlyph.h"
#include "sbml/packages/layout/sbml/Curve.h"
#include "sbml/packages/layout/sbml/Dimensions.h"
#include "sbml/packages/layout/sbml/BoundingBox.h"
#include "sbml/packages/layout/sbml/Point.h"
#include "sbml/packages/layout/sbml/LineSegment.h"
#include "sbml/packages/layout/sbml/CubicBezier.h"
#include "sbml/SBMLWriter.h"

#include "sbml/packages/layout/extension/LayoutExtension.h"
#include "sbml/packages/layout/extension/LayoutModelPlugin.h"

#if (!defined LIBSBML_HAS_PACKAGE_LAYOUT)
#error "This example requires libSBML to be built with the layout extension."
#endif

LIBSBML_CPP_NAMESPACE_USE

Species* createSpecies(const char* id, const char* name,
                       const char* compartmentId, Model* model)
{
  Species* species = model->createSpecies();
  species->setId(id);
  species->setName(name);
  species->setCompartment(compartmentId);
  species->setHasOnlySubstanceUnits(false);
  species->setBoundaryCondition(false);
  species->setConstant(false);
  return species;
}


int main(int argc, char** argv)
{
  //
  // Creates an SBMLNamespaces object with the given SBML level, version
  // package name, package version.
  //
  // (NOTE) By defualt, the name of package (i.e. "layout") will be used
  // if the arugment for the prefix is missing or empty. Thus the argument
  // for the prefix can be added as follows:
  //
  //    SBMLNamespaces sbmlns(3, 1,"layout", 1,"LAYOUT");
  //

  SBMLNamespaces sbmlns(3, 1,"layout", 1);

  //
  // (NOTES) The above code creating an SBMLNamespaces object can be replaced
  //         with one of the following other styles.
  //
  // (1) Creates an SBMLNamespace object with a SBML core namespace and then
  //     adds a layout package namespace to the object.
  //
  //         SBMLNamespaces sbmlns(3, 1);
  //         sbmlns.addPkgNamespace("layout", 1);
  //
  //          OR
  //
  //         SBMLNamespaces sbmlns(3, 1);
  //         sbmlns.addNamespace(LayoutExtension::getXmlnsL3V1V1(),"layout");
  //
  // (2) Creates a LayoutPkgNamespaces object (SBMLNamespace derived class
  //     for layout package. The class is basically used for createing an
  //     SBase derived objects belonging to the layout package) with the
  //     given SBML level, version, and package version
  //
  //        LayoutPkgNamespaces sbmlns(3, 1, 1);
  //

  // create the document

  SBMLDocument *document = new SBMLDocument(&sbmlns);

  document->enableDefaultNS("layout", true);

  // create the Model

  Model* model = document->createModel();
  model->setId("Glycolysis");
  document->setModel(model);

  // create the Compartment

  Compartment* compartment = model->createCompartment();
  compartment->setId("Yeast");
  compartment->setConstant(true);

  // create the Species

  Species* species_Gluc = createSpecies("Glucose", "Glucose",
                                        compartment->getId().c_str(), model);
  Species* species_G6P = createSpecies("Glucose_hyphen_6_hyphen_phosphate",
                                       "Glucose-6-phosphate",
                                       compartment->getId().c_str(), model);
  Species* species_F6P = createSpecies("Fructose_hyphen_6_hyphen_phosphate",
                                       "Fructose-6-phosphate",
                                       compartment->getId().c_str(), model);
  Species* species_F16BP = createSpecies("Fructose_hyphen_1_6_hyphen_bisphosphate",
                                         "Fructose-1, 6-bisphosphate",
                                         compartment->getId().c_str(), model);
  Species* species_DHAP = createSpecies("Dihydroxyacetonephosphate",
                                        "Dihydroxyacetonephosphate",
                                        compartment->getId().c_str(), model);
  Species* species_GAP = createSpecies("Glyceraldehyd_hyphen_3_hyphen_phosphate",
                                       "Glyceraldehyd-3-phosphate",
                                       compartment->getId().c_str(), model);
  Species* species_BPG = createSpecies("_1_3_hyphen_Bisphosphoglycerate",
                                       "1, 3-Bisphosphoglycerate",
                                       compartment->getId().c_str(), model);
  Species* species_3PG = createSpecies("_3_hyphen_Phosphoglycerate",
                                       "3-Phosphoglycerate",
                                       compartment->getId().c_str(), model);
  Species* species_2PG = createSpecies("_2_hyphen_Phosphoglycerate",
                                       "2-Phosphoglycerate",
                                       compartment->getId().c_str(), model);
  Species* species_PEP = createSpecies("Phosphoenolpyruvate",
                                       "Phosphoenolpyruvate",
                                       compartment->getId().c_str(), model);
  Species* species_Pyr = createSpecies("Pyruvate", "Pyruvate",
                                       compartment->getId().c_str(), model);
  Species* species_ATP = createSpecies("ATP", "ATP",
                                       compartment->getId().c_str(), model);
  Species* species_ADP = createSpecies("ADP", "ADP",
                                       compartment->getId().c_str(), model);
  Species* species_H = createSpecies("H_plus_", "H+",
                                     compartment->getId().c_str(), model);
  Species* species_NAD = createSpecies("NAD_plus_", "NAD+",
                                       compartment->getId().c_str(), model);
  Species* species_NADH = createSpecies("NADH", "NADH",
                                        compartment->getId().c_str(), model);
  Species* species_H2O = createSpecies("H2O", "H2O",
                                       compartment->getId().c_str(), model);
  Species* species_PI = createSpecies("Pi", "Pi",
                                      compartment->getId().c_str(), model);

  // create the Reactions
  ///////////////////////////////////////////////////////////////////////////////

  // Hexokinase Reaction
  Reaction* reaction_Hexokinase = model->createReaction();
  reaction_Hexokinase->setId("Hexokinase");
  reaction_Hexokinase->setReversible(false);
  reaction_Hexokinase->setFast(false);

  SpeciesReference* reference_Gluc = reaction_Hexokinase->createReactant();
  reference_Gluc->setSpecies(species_Gluc->getId());
  reference_Gluc->setId("ref_Gluc");
  reference_Gluc->setConstant(false);

  SpeciesReference* reference_G6P_1 = reaction_Hexokinase->createProduct();
  reference_G6P_1->setSpecies(species_G6P->getId());
  reference_G6P_1->setId("ref_G6P_1");
  reference_G6P_1->setConstant(false);

  SpeciesReference* reference_ATP_1 = reaction_Hexokinase->createReactant();
  reference_ATP_1->setSpecies(species_ATP->getId());
  reference_ATP_1->setId("ref_ATP_1");
  reference_ATP_1->setConstant(false);

  SpeciesReference* reference_ADP_1 = reaction_Hexokinase->createProduct();
  reference_ADP_1->setSpecies(species_ADP->getId());
  reference_ADP_1->setId("ref_ADP_1");
  reference_ADP_1->setConstant(false);

  SpeciesReference* reference_H_1 = reaction_Hexokinase->createProduct();
  reference_H_1->setSpecies(species_H->getId());
  reference_H_1->setId("ref_H_1");
  reference_H_1->setConstant(false);

  // Phosphoglucoseisomerase Reaction

  Reaction* reaction_PGIsomerase = model->createReaction();
  reaction_PGIsomerase->setId("Phosphoglucoseisomerase");
  reaction_PGIsomerase->setFast(false);

  SpeciesReference* reference_G6P_2 = reaction_PGIsomerase->createReactant();
  reference_G6P_2->setSpecies(species_G6P->getId());
  reference_G6P_2->setId("ref_G6P_2");
  reference_G6P_2->setConstant(false);

  SpeciesReference* reference_F6P_1 = reaction_PGIsomerase->createProduct();
  reference_F6P_1->setSpecies(species_F6P->getId());
  reference_F6P_1->setId("ref_F6P_1");
  reference_F6P_1->setConstant(false);

  // Phosphofructokinase Reaction

  Reaction* reaction_PFK = model->createReaction();
  reaction_PFK->setId("Phosphofructokinase");
  reaction_PFK->setReversible(false);
  reaction_PFK->setFast(false);

  SpeciesReference* reference_F6P_2 = reaction_PFK->createReactant();
  reference_F6P_2->setSpecies(species_F6P->getId());
  reference_F6P_2->setId("ref_F6P_2");
  reference_F6P_2->setConstant(false);
  SpeciesReference* reference_F16BP_1 = reaction_PFK->createProduct();
  reference_F16BP_1->setSpecies(species_F16BP->getId());
  reference_F16BP_1->setId("ref_F16BP_1");
  reference_F16BP_1->setConstant(false);
  SpeciesReference* reference_ATP_2 = reaction_PFK->createReactant();
  reference_ATP_2->setSpecies(species_ATP->getId());
  reference_ATP_2->setId("ref_ATP_2");
  reference_ATP_2->setConstant(false);
  SpeciesReference* reference_ADP_2 = reaction_PFK->createProduct();
  reference_ADP_2->setSpecies(species_ADP->getId());
  reference_ADP_2->setId("ref_ADP_2");
  reference_ADP_2->setConstant(false);
  SpeciesReference* reference_H_2 = reaction_PFK->createProduct();
  reference_H_2->setSpecies(species_H->getId());
  reference_H_2->setId("ref_H_2");
  reference_H_2->setConstant(false);

  // Aldolase Reaction

  Reaction* reaction_Aldolase = model->createReaction();
  reaction_Aldolase->setId("Aldolase");
  reaction_Aldolase->setFast(false);

  SpeciesReference* reference_F16BP_2 = reaction_Aldolase->createReactant();
  reference_F16BP_2->setSpecies(species_F16BP->getId());
  reference_F16BP_2->setId("ref_F16BP_2");
  reference_F16BP_2->setConstant(false);
  SpeciesReference* reference_DHAP_1 = reaction_Aldolase->createProduct();
  reference_DHAP_1->setSpecies(species_DHAP->getId());
  reference_DHAP_1->setId("ref_DHAP_1");
  reference_DHAP_1->setConstant(false);
  SpeciesReference* reference_GAP_1 = reaction_Aldolase->createProduct();
  reference_GAP_1->setSpecies(species_GAP->getId());
  reference_GAP_1->setId("ref_GAP_1");
  reference_GAP_1->setConstant(false);

  // Triose phosphate isomerase Reaction

  Reaction* reaction_TPI = model->createReaction();
  reaction_TPI->setId("triose_phosphate_isomerase");
  reaction_TPI->setFast(false);

  SpeciesReference* reference_DHAP_2 = reaction_TPI->createReactant();
  reference_DHAP_2->setSpecies(species_DHAP->getId());
  reference_DHAP_2->setId("ref_DHAP_2");
  reference_DHAP_2->setConstant(false);
  SpeciesReference* reference_GAP_2 = reaction_TPI->createProduct();
  reference_GAP_2->setSpecies(species_GAP->getId());
  reference_GAP_2->setId("ref_GAP_2");
  reference_GAP_2->setConstant(false);

  // Glyceraldehyde-3-phosphatedehydrogenase Reaction

  Reaction* reaction_GAPDeh = model->createReaction();
  reaction_GAPDeh->setId("GAP_Dehydrogenase");
  reaction_GAPDeh->setReversible(false);
  reaction_GAPDeh->setFast(false);
        
  SpeciesReference* reference_GAP_3 = reaction_GAPDeh->createReactant();
  reference_GAP_3->setSpecies(species_GAP->getId());
  reference_GAP_3->setId("ref_GAP_3");
  reference_GAP_3->setConstant(false);
  SpeciesReference* reference_BPG_1 = reaction_GAPDeh->createProduct();
  reference_BPG_1->setSpecies(species_BPG->getId());
  reference_BPG_1->setId("ref_BPG_1");
  reference_BPG_1->setConstant(false);
  SpeciesReference* reference_NAD_1 = reaction_GAPDeh->createReactant();
  reference_NAD_1->setSpecies(species_NAD->getId());
  reference_NAD_1->setId("ref_NAD_1");
  reference_NAD_1->setConstant(false);
  SpeciesReference* reference_NADH_1 = reaction_GAPDeh->createProduct();
  reference_NADH_1->setSpecies(species_NADH->getId());
  reference_NADH_1->setId("ref_NADH_1");
  reference_NADH_1->setConstant(false);
  SpeciesReference* reference_H_5 = reaction_GAPDeh->createProduct();
  reference_H_5->setSpecies(species_H->getId());
  reference_H_5->setId("ref_H_5");
  reference_H_5->setConstant(false);
  SpeciesReference* reference_PI_1 = reaction_GAPDeh->createReactant();
  reference_PI_1->setSpecies(species_PI->getId());
  reference_PI_1->setId("ref_PI_1");
  reference_PI_1->setConstant(false);

  // Phosphoglyceratekinase Reaction

  Reaction* reaction_PGK = model->createReaction();
  reaction_PGK->setId("Phosphoglyceratekinase");
  reaction_PGK->setReversible(false);
  reaction_PGK->setFast(false);

  SpeciesReference* reference_BPG_2 = reaction_PGK->createReactant();
  reference_BPG_2->setSpecies(species_BPG->getId());
  reference_BPG_2->setId("ref_BPG_2");
  reference_BPG_2->setConstant(false);
  SpeciesReference* reference_3PG_1 = reaction_PGK->createProduct();
  reference_3PG_1->setSpecies(species_3PG->getId());
  reference_3PG_1->setId("ref_3PG_1");
  reference_3PG_1->setConstant(false);
  SpeciesReference* reference_ATP_3 = reaction_PGK->createProduct();
  reference_ATP_3->setSpecies(species_ATP->getId());
  reference_ATP_3->setId("ref_ATP_3");
  reference_ATP_3->setConstant(false);
  SpeciesReference* reference_ADP_3 = reaction_PGK->createReactant();
  reference_ADP_3->setSpecies(species_ADP->getId());
  reference_ADP_3->setId("ref_ADP_3");
  reference_ADP_3->setConstant(false);
  SpeciesReference* reference_H_3 = reaction_PGK->createReactant();
  reference_H_3->setSpecies(species_H->getId());
  reference_H_3->setId("ref_H_3");
  reference_H_3->setConstant(false);

  // Phosphoglyceratemutase Reaction 

  Reaction* reaction_PGM = model->createReaction();
  reaction_PGM->setId("Phosphoglyceratemutase");
  reaction_PGM->setFast(false);

  SpeciesReference* reference_3PG_2 = reaction_PGM->createReactant();
  reference_3PG_2->setSpecies(species_3PG->getId());
  reference_3PG_2->setId("ref_3PG_2");
  reference_3PG_2->setConstant(false);
  SpeciesReference* reference_2PG_1 = reaction_PGM->createProduct();
  reference_2PG_1->setSpecies(species_2PG->getId());
  reference_2PG_1->setId("ref_2PG_1");
  reference_2PG_1->setConstant(false);

  // Enolase Reaction

  Reaction* reaction_Enolase = model->createReaction();
  reaction_Enolase->setId("Enolase");
  reaction_Enolase->setFast(false);

  SpeciesReference* reference_2PG_2 = reaction_Enolase->createReactant();
  reference_2PG_2->setSpecies(species_3PG->getId());
  reference_2PG_2->setId("ref_2PG_2");
  reference_2PG_2->setConstant(false);
  SpeciesReference* reference_PEP_1 = reaction_Enolase->createProduct();
  reference_PEP_1->setSpecies(species_2PG->getId());
  reference_PEP_1->setId("ref_PEP_1");
  reference_PEP_1->setConstant(false);
  SpeciesReference* reference_H2O_1 = reaction_Enolase->createProduct();
  reference_H2O_1->setSpecies(species_H2O->getId());
  reference_H2O_1->setId("ref_H2O_1");
  reference_H2O_1->setConstant(false);

  // Pyruvatekinase Reaction

  Reaction* reaction_PK = model->createReaction();
  reaction_PK->setId("Pyruvatekinase");
  reaction_PK->setReversible(false);
  reaction_PK->setFast(false);

  SpeciesReference* reference_PEP_2 = reaction_PK->createReactant();
  reference_PEP_2->setSpecies(species_3PG->getId());
  reference_PEP_2->setId("ref_PEP_2");
  reference_PEP_2->setConstant(false);
  SpeciesReference* reference_Pyr_1 = reaction_PK->createProduct();
  reference_Pyr_1->setSpecies(species_2PG->getId());
  reference_Pyr_1->setId("ref_Pyr_1");
  reference_Pyr_1->setConstant(false);
  SpeciesReference* reference_ATP_4 = reaction_PK->createProduct();
  reference_ATP_4->setSpecies(species_ATP->getId());
  reference_ATP_4->setId("ref_ATP_4");
  reference_ATP_4->setConstant(false);
  SpeciesReference* reference_ADP_4 = reaction_PK->createReactant();
  reference_ADP_4->setSpecies(species_ADP->getId());
  reference_ADP_4->setId("ref_ADP_4");
  reference_ADP_4->setConstant(false);
  SpeciesReference* reference_H_4 = reaction_PK->createProduct();
  reference_H_4->setSpecies(species_H->getId());
  reference_H_4->setId("ref_H_4");
  reference_H_4->setConstant(false);

  // create the Layout
  ////////////////////////////////////////////////////////////////////////////////////////

  //
  // set the LayoutPkgNamespaces* for Level 3 Version 1 Layout Version 1
  //
  LayoutPkgNamespaces layoutns(3, 1, 1);

  //
  // Get a LayoutModelPlugin object plugged in the model object.
  //
  // The type of the returned value of SBase::getPlugin() function is SBasePlugin*, and
  // thus the value needs to be casted for the corresponding derived class.
  //
  LayoutModelPlugin* mplugin  =  static_cast<LayoutModelPlugin*>(model->getPlugin("layout"));

  //
  // Creates a Layout object via LayoutModelPlugin object.
  //
  Layout* layout = mplugin->createLayout();

  layout->setId("Glycolysis_Layout");
  Dimensions dim(&layoutns, 800.0, 1600.0);
  layout->setDimensions(&dim);

  // create the SpeciesGlyphs

  SpeciesGlyph* glyph_Gluc = layout->createSpeciesGlyph();
  glyph_Gluc->setId("glyph_Gluc");
  glyph_Gluc->setSpeciesId(species_Gluc->getId());
  BoundingBox bb(&layoutns, "bb_01", 105, 20, 130, 20);
  glyph_Gluc->setBoundingBox(&bb);

  TextGlyph* tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_01");
  bb = BoundingBox(&layoutns, "bbT_01", 115, 20, 110, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_Gluc->getId());
  tGlyph->setGraphicalObjectId(glyph_Gluc->getId());

  SpeciesGlyph* glyph_ATP_1 = layout->createSpeciesGlyph();
  glyph_ATP_1->setId("glyph_ATP_1");
  glyph_ATP_1->setSpeciesId(species_ATP->getId());
  bb = BoundingBox(&layoutns, "bb_02", 270, 70, 80, 20);
  glyph_ATP_1->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_02");
  bb = BoundingBox(&layoutns, "bbT_02", 280, 70, 60, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_ATP->getId());
  tGlyph->setGraphicalObjectId(glyph_ATP_1->getId());

  SpeciesGlyph* glyph_ADP_1 = layout->createSpeciesGlyph();
  glyph_ADP_1->setId("glyph_ADP_1");
  glyph_ADP_1->setSpeciesId(species_ADP->getId());
  bb = BoundingBox(&layoutns, "bb_03", 270, 140, 80, 20);
  glyph_ADP_1->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_03");
  bb = BoundingBox(&layoutns, "bbT_03", 280, 140, 60, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_ADP->getId());
  tGlyph->setGraphicalObjectId(glyph_ADP_1->getId());


  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_plus_01");
  bb = BoundingBox(&layoutns, "bb_plus_01", 350, 140, 20, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setText("+");


  SpeciesGlyph* glyph_H_1 = layout->createSpeciesGlyph();
  glyph_H_1->setId("glyph_H_1");
  glyph_H_1->setSpeciesId(species_H->getId());
  bb = BoundingBox(&layoutns, "bb_04", 380, 140, 60, 20);
  glyph_H_1->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_04");
  bb = BoundingBox(&layoutns, "bbT_04", 390, 140, 40, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_H->getId());
  tGlyph->setGraphicalObjectId(glyph_H_1->getId());


  SpeciesGlyph* glyph_G6P = layout->createSpeciesGlyph();
  glyph_G6P->setId("glyph_G6P");
  glyph_G6P->setSpeciesId(species_G6P->getId());
  bb = BoundingBox(&layoutns, "bb_05", 50, 190, 270, 20);
  glyph_G6P->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_05");
  bb = BoundingBox(&layoutns, "bbT_05", 60, 190, 250, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_G6P->getId());
  tGlyph->setGraphicalObjectId(glyph_G6P->getId());


  SpeciesGlyph* glyph_F6P = layout->createSpeciesGlyph();
  glyph_F6P->setId("glyph_F6P");
  glyph_F6P->setSpeciesId(species_F6P->getId());
  bb = BoundingBox(&layoutns, "bb_06", 50, 360, 270, 20);
  glyph_F6P->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_06");
  bb = BoundingBox(&layoutns, "bbT_06", 60, 360, 250, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_F6P->getId());
  tGlyph->setGraphicalObjectId(glyph_F6P->getId());


  SpeciesGlyph* glyph_ATP_2 = layout->createSpeciesGlyph();
  glyph_ATP_2->setId("glyph_ATP_2");
  glyph_ATP_2->setSpeciesId(species_ATP->getId());
  bb = BoundingBox(&layoutns, "bb_07", 270, 410, 80, 20);
  glyph_ATP_2->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_07");
  bb = BoundingBox(&layoutns, "bbT_07", 280, 410, 60, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_ATP->getId());
  tGlyph->setGraphicalObjectId(glyph_ATP_2->getId());


  SpeciesGlyph* glyph_ADP_2 = layout->createSpeciesGlyph();
  glyph_ADP_2->setId("glyph_ADP_2");
  glyph_ADP_2->setSpeciesId(species_ADP->getId());
  bb = BoundingBox(&layoutns, "bb_08", 270, 480, 80, 20);
  glyph_ADP_2->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_08");
  bb = BoundingBox(&layoutns, "bbT_08", 280, 480, 60, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_ADP->getId());
  tGlyph->setGraphicalObjectId(glyph_ADP_2->getId());

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_plus_02");
  bb = BoundingBox(&layoutns, "bb_plus_02", 350, 480, 20, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setText("+");


  SpeciesGlyph* glyph_H_2 = layout->createSpeciesGlyph();
  glyph_H_2->setId("glyph_H_2");
  glyph_H_2->setSpeciesId(species_H->getId());
  bb = BoundingBox(&layoutns, "bb_09", 380, 480, 60, 20);
  glyph_H_2->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_09");
  bb = BoundingBox(&layoutns, "bbT_09", 390, 480, 40, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_H->getId());
  tGlyph->setGraphicalObjectId(glyph_H_2->getId());


  SpeciesGlyph* glyph_F16BP = layout->createSpeciesGlyph();
  glyph_F16BP->setId("glyph_F16BP");
  glyph_F16BP->setSpeciesId(species_F16BP->getId());
  bb = BoundingBox(&layoutns, "bb_10", 20, 530, 340, 20);
  glyph_F16BP->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_10");
  bb = BoundingBox(&layoutns, "bbT_10", 30, 530, 320, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_F16BP->getId());
  tGlyph->setGraphicalObjectId(glyph_F16BP->getId());


  SpeciesGlyph* glyph_DHAP = layout->createSpeciesGlyph();
  glyph_DHAP->setId("glyph_DHAP");
  glyph_DHAP->setSpeciesId(species_DHAP->getId());
  bb = BoundingBox(&layoutns, "bb_11", 380, 595, 340, 20);
  glyph_DHAP->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_11");
  bb = BoundingBox(&layoutns, "bbT_11", 390, 595, 320, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_DHAP->getId());
  tGlyph->setGraphicalObjectId(glyph_DHAP->getId());


  SpeciesGlyph* glyph_GAP = layout->createSpeciesGlyph();
  glyph_GAP->setId("glyph_GAP");
  glyph_GAP->setSpeciesId(species_GAP->getId());
  bb = BoundingBox(&layoutns, "bb_12", 20, 700, 340, 20);
  glyph_GAP->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_12");
  bb = BoundingBox(&layoutns, "bbT_12", 30, 700, 320, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_GAP->getId());
  tGlyph->setGraphicalObjectId(glyph_GAP->getId());


  SpeciesGlyph* glyph_NAD_1 = layout->createSpeciesGlyph();
  glyph_NAD_1->setId("glyph_NAD_1");
  glyph_NAD_1->setSpeciesId(species_NAD->getId());
  bb = BoundingBox(&layoutns, "bb_13", 270, 750, 80, 20);
  glyph_NAD_1->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_13");
  bb = BoundingBox(&layoutns, "bbT_13", 280, 750, 60, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_NAD->getId());
  tGlyph->setGraphicalObjectId(glyph_NAD_1->getId());

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_plus_06");
  bb = BoundingBox(&layoutns, "bb_plus_06", 350, 750, 20, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setText("+");


  SpeciesGlyph* glyph_PI_1 = layout->createSpeciesGlyph();
  glyph_PI_1->setId("glyph_PI_1");
  glyph_PI_1->setSpeciesId(species_PI->getId());
  bb = BoundingBox(&layoutns, "bb_14", 380, 750, 60, 20);
  glyph_PI_1->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_14");
  bb = BoundingBox(&layoutns, "bbT_14", 390, 750, 40, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_PI->getId());
  tGlyph->setGraphicalObjectId(glyph_PI_1->getId());


  SpeciesGlyph* glyph_NADH_1 = layout->createSpeciesGlyph();
  glyph_NADH_1->setId("glyph_NADH_1");
  glyph_NADH_1->setSpeciesId(species_NADH->getId());
  bb = BoundingBox(&layoutns, "bb_15", 270, 820, 100, 20);
  glyph_NADH_1->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_15");
  bb = BoundingBox(&layoutns, "bbT_15", 280, 820, 80, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_NADH->getId());
  tGlyph->setGraphicalObjectId(glyph_NADH_1->getId());


  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_plus_06");
  bb = BoundingBox(&layoutns, "bb_plus_06", 365, 820, 20, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setText("+");


  SpeciesGlyph* glyph_H_5 = layout->createSpeciesGlyph();
  glyph_H_5->setId("glyph_H_5");
  glyph_H_5->setSpeciesId(species_H->getId());
  bb = BoundingBox(&layoutns, "bb_16", 390, 820, 60, 20);
  glyph_H_5->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_16");
  bb = BoundingBox(&layoutns, "bbT_16", 400, 820, 40, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_H->getId());
  tGlyph->setGraphicalObjectId(glyph_H_5->getId());


  SpeciesGlyph* glyph_BPG = layout->createSpeciesGlyph();
  glyph_BPG->setId("glyph_BPG");
  glyph_BPG->setSpeciesId(species_BPG->getId());
  bb = BoundingBox(&layoutns, "bb_17", 30, 870, 310, 20);
  glyph_BPG->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_17");
  bb = BoundingBox(&layoutns, "bbT_17", 40, 870, 290, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_BPG->getId());
  tGlyph->setGraphicalObjectId(glyph_BPG->getId());


  SpeciesGlyph* glyph_ADP_3 = layout->createSpeciesGlyph();
  glyph_ADP_3->setId("glyph_ADP_3");
  glyph_ADP_3->setSpeciesId(species_ADP->getId());
  bb = BoundingBox(&layoutns, "bb_18", 270, 920, 80, 20);
  glyph_ADP_3->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_18");
  bb = BoundingBox(&layoutns, "bbT_18", 280, 920, 60, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_ADP->getId());
  tGlyph->setGraphicalObjectId(glyph_ADP_3->getId());

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_plus_03");
  bb = BoundingBox(&layoutns, "bb_plus_03", 350, 920, 20, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setText("+");


  SpeciesGlyph* glyph_H_3 = layout->createSpeciesGlyph();
  glyph_H_3->setId("glyph_H_3");
  glyph_H_3->setSpeciesId(species_H->getId());
  bb = BoundingBox(&layoutns, "bb_19", 380, 920, 60, 20);
  glyph_H_3->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_19");
  bb = BoundingBox(&layoutns, "bbT_19", 390, 920, 40, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_H->getId());
  tGlyph->setGraphicalObjectId(glyph_H_3->getId());


  SpeciesGlyph* glyph_ATP_3 = layout->createSpeciesGlyph();
  glyph_ATP_3->setId("glyph_ATP_3");
  glyph_ATP_3->setSpeciesId(species_ATP->getId());
  bb = BoundingBox(&layoutns, "bb_20", 270, 990, 80, 20);
  glyph_ATP_3->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_20");
  bb = BoundingBox(&layoutns, "bbT_20", 280, 990, 60, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_ATP->getId());
  tGlyph->setGraphicalObjectId(glyph_ATP_3->getId());


  SpeciesGlyph* glyph_3PG = layout->createSpeciesGlyph();
  glyph_3PG->setId("glyph_3PG");
  glyph_3PG->setSpeciesId(species_3PG->getId());
  bb = BoundingBox(&layoutns, "bb_21", 50, 1040, 250, 20);
  glyph_3PG->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_21");
  bb = BoundingBox(&layoutns, "bbT_21", 60, 1040, 230, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_3PG->getId());
  tGlyph->setGraphicalObjectId(glyph_3PG->getId());


  SpeciesGlyph* glyph_2PG = layout->createSpeciesGlyph();
  glyph_2PG->setId("glyph_2PG");
  glyph_2PG->setSpeciesId(species_2PG->getId());
  bb = BoundingBox(&layoutns, "bb_22", 50, 1210, 250, 20);
  glyph_2PG->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_22");
  bb = BoundingBox(&layoutns, "bbT_22", 60, 1210, 230, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_2PG->getId());
  tGlyph->setGraphicalObjectId(glyph_2PG->getId());


  SpeciesGlyph* glyph_H2O_1 = layout->createSpeciesGlyph();
  glyph_H2O_1->setId("glyph_H2O_1");
  glyph_H2O_1->setSpeciesId(species_H2O->getId());
  bb = BoundingBox(&layoutns, "bb_23", 270, 1350, 80, 20);
  glyph_H2O_1->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_23");
  bb = BoundingBox(&layoutns, "bbT_23", 280, 1350, 60, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_H2O->getId());
  tGlyph->setGraphicalObjectId(glyph_H2O_1->getId());


  SpeciesGlyph* glyph_PEP = layout->createSpeciesGlyph();
  glyph_PEP->setId("glyph_PEP");
  glyph_PEP->setSpeciesId(species_PEP->getId());
  bb = BoundingBox(&layoutns, "bb_24", 40, 1380, 265, 20);
  glyph_PEP->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_24");
  bb = BoundingBox(&layoutns, "bbT_24", 50, 1380, 245, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_PEP->getId());
  tGlyph->setGraphicalObjectId(glyph_PEP->getId());


  SpeciesGlyph* glyph_ADP_4 = layout->createSpeciesGlyph();
  glyph_ADP_4->setId("glyph_ADP_4");
  glyph_ADP_4->setSpeciesId(species_ADP->getId());
  bb = BoundingBox(&layoutns, "bb_25", 270, 1430, 80, 20);
  glyph_ADP_4->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_25");
  bb = BoundingBox(&layoutns, "bbT_25", 280, 1430, 60, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_ADP->getId());
  tGlyph->setGraphicalObjectId(glyph_ADP_4->getId());

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_plus_04");
  bb = BoundingBox(&layoutns, "bb_plus_04", 345, 1430, 20, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setText("+");


  SpeciesGlyph* glyph_H_4 = layout->createSpeciesGlyph();
  glyph_H_4->setId("glyph_H_4");
  glyph_H_4->setSpeciesId(species_H->getId());
  bb = BoundingBox(&layoutns, "bb_26", 370, 1430, 60, 20);
  glyph_H_4->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_26");
  bb = BoundingBox(&layoutns, "bbT_26", 380, 1430, 40, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_H->getId());
  tGlyph->setGraphicalObjectId(glyph_H_4->getId());


  SpeciesGlyph* glyph_ATP_4 = layout->createSpeciesGlyph();
  glyph_ATP_4->setId("glyph_ATP_4");
  glyph_ATP_4->setSpeciesId(species_ATP->getId());
  bb = BoundingBox(&layoutns, "bb_27", 270, 1520, 80, 20);
  glyph_ATP_4->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_27");
  bb = BoundingBox(&layoutns, "bbT_27", 280, 1520, 60, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_ATP->getId());
  tGlyph->setGraphicalObjectId(glyph_ATP_4->getId());


  SpeciesGlyph* glyph_Pyr = layout->createSpeciesGlyph();
  glyph_Pyr->setId("glyph_Pyr");
  glyph_Pyr->setSpeciesId(species_Pyr->getId());
  bb = BoundingBox(&layoutns, "bb_28", 100, 1550, 140, 20);
  glyph_Pyr->setBoundingBox(&bb);

  tGlyph = layout->createTextGlyph();
  tGlyph->setId("TextGlyph_28");
  bb = BoundingBox(&layoutns, "bbT_28", 110, 1550, 120, 20);
  tGlyph->setBoundingBox(&bb);
  tGlyph->setOriginOfTextId(species_Pyr->getId());
  tGlyph->setGraphicalObjectId(glyph_Pyr->getId());

  // create the ReactionGlyphs

  ReactionGlyph* glyph_Hexokinase = layout->createReactionGlyph();
  glyph_Hexokinase->setId("glyph_Hexokinase");
  glyph_Hexokinase->setReactionId(reaction_Hexokinase->getId());

  Curve* curve_Hexokinase = glyph_Hexokinase->getCurve();
  LineSegment* ls = curve_Hexokinase->createLineSegment();
  Point p(&layoutns, 170, 100);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 130);
  ls->setEnd(&p);

  ReactionGlyph* glyph_PGIsomerase = layout->createReactionGlyph();
  glyph_PGIsomerase->setId("glyph_PGIsomerase");
  glyph_PGIsomerase->setReactionId(reaction_PGIsomerase->getId());

  Curve* curve_PGIsomerase = glyph_PGIsomerase->getCurve();
  ls = curve_PGIsomerase->createLineSegment();
  p = Point(&layoutns, 170, 270);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 300);
  ls->setEnd(&p);


  ReactionGlyph* glyph_PFK = layout->createReactionGlyph();
  glyph_PFK->setId("glyph_PFK");
  glyph_PFK->setReactionId(reaction_PFK->getId());

  Curve* curve_PFK = glyph_PFK->getCurve();
  ls = curve_PFK->createLineSegment();
  p = Point(&layoutns, 170, 440);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 470);
  ls->setEnd(&p);


  ReactionGlyph* glyph_Aldolase = layout->createReactionGlyph();
  glyph_Aldolase->setId("glyph_Aldolase");
  glyph_Aldolase->setReactionId(reaction_Aldolase->getId());

  Curve* curve_Aldolase = glyph_Aldolase->getCurve();
  ls = curve_Aldolase->createLineSegment();
  p = Point(&layoutns, 170, 610);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 640);
  ls->setEnd(&p);

  ReactionGlyph* glyph_TPI = layout->createReactionGlyph();
  glyph_TPI->setId("glyph_TPI");
  glyph_TPI->setReactionId(reaction_TPI->getId());


  Curve* curve_TPI = glyph_TPI->getCurve();
  ls = curve_TPI->createLineSegment();
  p = Point(&layoutns, 515, 700);
  ls->setStart(&p);
  p = Point(&layoutns, 515, 700);
  ls->setEnd(&p);


  ReactionGlyph* glyph_GAPDeh = layout->createReactionGlyph();
  glyph_GAPDeh->setId("glyph_GAPDeh");
  glyph_GAPDeh->setReactionId(reaction_GAPDeh->getId());

  Curve* curve_GAPDeh = glyph_GAPDeh->getCurve();
  ls = curve_GAPDeh->createLineSegment();
  p = Point(&layoutns, 170, 780);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 810);
  ls->setEnd(&p);


  ReactionGlyph* glyph_PGK = layout->createReactionGlyph();
  glyph_PGK->setId("glyph_PGK");
  glyph_PGK->setReactionId(reaction_PGK->getId());

  Curve* curve_PGK = glyph_PGK->getCurve();
  ls = curve_PGK->createLineSegment();
  p = Point(&layoutns, 170, 950);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 980);
  ls->setEnd(&p);


  ReactionGlyph* glyph_PGM = layout->createReactionGlyph();
  glyph_PGM->setId("glyph_PGM");
  glyph_PGM->setReactionId(reaction_PGM->getId());

  Curve* curve_PGM = glyph_PGM->getCurve();
  ls = curve_PGM->createLineSegment();
  p = Point(&layoutns, 170, 1120);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 1150);
  ls->setEnd(&p);


  ReactionGlyph* glyph_Enolase = layout->createReactionGlyph();
  glyph_Enolase->setId("glyph_Enolase");
  glyph_Enolase->setReactionId(reaction_Enolase->getId());

  Curve* curve_Enolase = glyph_Enolase->getCurve();
  ls = curve_Enolase->createLineSegment();
  p = Point(&layoutns, 170, 1290);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 1320);
  ls->setEnd(&p);


  ReactionGlyph* glyph_PK = layout->createReactionGlyph();
  glyph_PK->setId("glyph_PK");
  glyph_PK->setReactionId(reaction_PK->getId());

  Curve* curve_PK = glyph_PK->getCurve();
  ls = curve_PK->createLineSegment();
  p = Point(&layoutns, 170, 1460);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 1490);
  ls->setEnd(&p);

  // add the SpeciesReferenceGlyphs

  // the main substrates
  SpeciesReferenceGlyph* speciesReferenceGlyph1 = glyph_Hexokinase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph1->setId("SpeciesReferenceGlyph_01");
  speciesReferenceGlyph1->setSpeciesGlyphId(glyph_Gluc->getId());
  speciesReferenceGlyph1->setSpeciesReferenceId(reference_Gluc->getId());
  speciesReferenceGlyph1->setRole(SPECIES_ROLE_SUBSTRATE);

  ls = speciesReferenceGlyph1->createLineSegment();
  p = Point(&layoutns, 170, 100);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 50);
  ls->setEnd(&p);

  SpeciesReferenceGlyph* speciesReferenceGlyph = glyph_PGIsomerase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_02");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_G6P->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_G6P_2->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SUBSTRATE);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 270);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 220);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_PFK->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_03");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_F6P->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_F6P_2->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SUBSTRATE);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 440);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 390);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_Aldolase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_04");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_F16BP->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_F16BP_2->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SUBSTRATE);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 610);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 560);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_GAPDeh->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_05");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_GAP->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_GAP_3->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SUBSTRATE);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 780);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 730);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_PGK->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_06");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_BPG->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_BPG_2->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SUBSTRATE);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 950);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 900);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_PGM->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_07");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_3PG->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_3PG_2->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SUBSTRATE);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 1120);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 1070);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_Enolase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_08");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_2PG->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_2PG_2->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SUBSTRATE);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 1290);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 1240);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_PK->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_09");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_PEP->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_PEP_2->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SUBSTRATE);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 1460);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 1410);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_TPI->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_10");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_DHAP->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_DHAP_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SUBSTRATE);

  CubicBezier* cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 515, 700);
  cb->setStart(&p);
  p = Point(&layoutns, 535, 680);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 535, 680);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 535, 625);
  cb->setEnd(&p);

  // the main products
  speciesReferenceGlyph = glyph_Hexokinase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_11");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_G6P->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_G6P_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_PRODUCT);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 130);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 180);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_PGIsomerase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_12");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_F6P->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_F6P_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_PRODUCT);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 300);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 350);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_PFK->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_13");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_F16BP->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_F16BP_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_PRODUCT);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 470);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 520);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_Aldolase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_14");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_GAP->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_GAP_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_PRODUCT);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 640);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 690);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_Aldolase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_15");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_DHAP->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_DHAP_2->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_PRODUCT);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 640);
  cb->setStart(&p);
  p = Point(&layoutns, 270, 700);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 270, 605);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 370, 605);
  cb->setEnd(&p);

  speciesReferenceGlyph = glyph_GAPDeh->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_16");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_BPG->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_BPG_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_PRODUCT);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 810);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 860);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_PGK->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_17");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_3PG->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_3PG_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_PRODUCT);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 980);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 1030);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_PGM->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_18");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_2PG->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_2PG_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_PRODUCT);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 1150);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 1200);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_Enolase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_19");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_PEP->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_PEP_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_PRODUCT);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 1320);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 1370);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_PK->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_20");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_Pyr->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_Pyr_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_PRODUCT);

  ls = speciesReferenceGlyph->createLineSegment();
  p = Point(&layoutns, 170, 1490);
  ls->setStart(&p);
  p = Point(&layoutns, 170, 1540);
  ls->setEnd(&p);

  speciesReferenceGlyph = glyph_TPI->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_21");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_GAP->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_GAP_2->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_PRODUCT);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 515, 700);
  cb->setStart(&p);
  p = Point(&layoutns, 505, 710);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 505, 710);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 370, 710);
  cb->setEnd(&p);


  // sidesubstrates and products

  // hexokinase
  speciesReferenceGlyph = glyph_Hexokinase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_22");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_ATP_1->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_ATP_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SIDESUBSTRATE);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 100);
  cb->setStart(&p);
  p = Point(&layoutns, 170, 80);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 170, 80);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 260, 80);
  cb->setEnd(&p);

  speciesReferenceGlyph = glyph_Hexokinase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_23");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_ADP_1->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_ADP_1->getId());
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

  // PFK
  speciesReferenceGlyph = glyph_PFK->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_24");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_ATP_2->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_ATP_2->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SIDESUBSTRATE);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 440);
  cb->setStart(&p);
  p = Point(&layoutns, 170, 420);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 170, 420);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 260, 420);
  cb->setEnd(&p);

  speciesReferenceGlyph = glyph_PFK->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_24");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_ADP_2->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_ADP_2->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SIDEPRODUCT);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 470);
  cb->setStart(&p);
  p = Point(&layoutns, 170, 490);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 170, 490);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 260, 490);
  cb->setEnd(&p);

  // GAP Dehydrogenase
  speciesReferenceGlyph = glyph_GAPDeh->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_25");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_NAD_1->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_NAD_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SIDESUBSTRATE);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 780);
  cb->setStart(&p);
  p = Point(&layoutns, 170, 760);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 170, 760);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 260, 760);
  cb->setEnd(&p);

  speciesReferenceGlyph = glyph_GAPDeh->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_26");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_NADH_1->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_NADH_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SIDEPRODUCT);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 810);
  cb->setStart(&p);
  p = Point(&layoutns, 170, 830);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 170, 830);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 260, 830);
  cb->setEnd(&p);

  // PGK
  speciesReferenceGlyph = glyph_PGK->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_27");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_ADP_3->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_ADP_3->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SIDESUBSTRATE);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 950);
  cb->setStart(&p);
  p = Point(&layoutns, 170, 930);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 170, 930);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 260, 930);
  cb->setEnd(&p);

  speciesReferenceGlyph = glyph_PGK->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_28");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_ATP_3->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_ATP_3->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SIDEPRODUCT);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 980);
  cb->setStart(&p);
  p = Point(&layoutns, 170, 1000);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 170, 1000);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 260, 1000);
  cb->setEnd(&p);

  //Enolase
  speciesReferenceGlyph = glyph_Enolase->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_29");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_H2O_1->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_H2O_1->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SIDEPRODUCT);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 1320);
  cb->setStart(&p);
  p = Point(&layoutns, 170, 1360);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 170, 1360);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 260, 1360);
  cb->setEnd(&p);

  // PK
  speciesReferenceGlyph = glyph_PK->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_30");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_ADP_4->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_ADP_4->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SIDESUBSTRATE);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 1460);
  cb->setStart(&p);
  p = Point(&layoutns, 170, 1440);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 170, 1440);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 260, 1440);
  cb->setEnd(&p);

  speciesReferenceGlyph = glyph_PK->createSpeciesReferenceGlyph();
  speciesReferenceGlyph->setId("SpeciesReferenceGlyph_31");
  speciesReferenceGlyph->setSpeciesGlyphId(glyph_ATP_4->getId());
  speciesReferenceGlyph->setSpeciesReferenceId(reference_ATP_4->getId());
  speciesReferenceGlyph->setRole(SPECIES_ROLE_SIDEPRODUCT);

  cb = speciesReferenceGlyph->createCubicBezier();
  p = Point(&layoutns, 170, 1490);
  cb->setStart(&p);
  p = Point(&layoutns, 170, 1530);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 170, 1530);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 260, 1530);
  cb->setEnd(&p);


  writeSBML(document, "layout_example2_L3.xml");
  delete document;
}
