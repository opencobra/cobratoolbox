/**
 * @file    example1.cpp
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
 *     Ralph Gauges
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
#include "sbml/packages/layout/extension/LayoutExtension.h"
#include "sbml/packages/layout/extension/LayoutModelPlugin.h"
#include "sbml/packages/layout/sbml/Curve.h"
#include "sbml/packages/layout/sbml/Dimensions.h"
#include "sbml/packages/layout/sbml/BoundingBox.h"
#include "sbml/packages/layout/sbml/Point.h"
#include "sbml/packages/layout/sbml/LineSegment.h"
#include "sbml/packages/layout/sbml/CubicBezier.h"
#include "sbml/SBMLWriter.h"

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
  SBMLNamespaces sbmlns(2, 4);
  sbmlns.addNamespace(LayoutExtension::getXmlnsL2(),"layout");

  // (NOTES) The above code creating an SBMLNamespaces object can be replaced
  //         with the following other style.
  //
  // (2) Creates a LayoutPkgNamespaces object (SBMLNamespace derived class
  //     for layout package. The class is basically used for createing an
  //     SBase derived objects belonging to the layout package) with the
  //     given SBML level, version.  (Package version is not required by
  //     Layout extension of SBML Level 2)
  //
  //        LayoutPkgNamespaces sbmlns(2, 4);
  //

  // create the document

  SBMLDocument *document = new SBMLDocument(&sbmlns);

  // create the Model

  Model* model = document->createModel();
  model->setId("TestModel");
  document->setModel(model);

  // create the Compartment

  Compartment* compartment = model->createCompartment();
  compartment->setId("Compartment_1");

  // create the Species

  Species* species1 = model->createSpecies();
  species1->setId("Species_1");
  species1->setCompartment(compartment->getId());

  Species* species2 = model->createSpecies();
  species2->setId("Species_2");
  species2->setCompartment(compartment->getId());

  // create the Reactions

  Reaction* reaction1 = model->createReaction();
  reaction1->setId("Reaction_1");
  reaction1->setReversible(false);

  SpeciesReference* reference1 = reaction1->createReactant();
  reference1->setSpecies(species1->getId());
  reference1->setId("SpeciesReference_1");


  SpeciesReference* reference2 = reaction1->createProduct();
  reference2->setSpecies(species2->getId());
  reference2->setId("SpeciesReference_2");

  Reaction* reaction2 = model->createReaction();
  reaction2->setId("Reaction_2");
  reaction2->setReversible(false);

  SpeciesReference* reference3 = reaction2->createReactant();
  reference3->setSpecies(species2->getId());
  reference3->setId("SpeciesReference_3");

  SpeciesReference* reference4 = reaction2->createProduct();
  reference4->setSpecies(species1->getId());
  reference4->setId("SpeciesReference_4");

  // create the Layout

  LayoutPkgNamespaces layoutns(2, 4);

  LayoutModelPlugin* mplugin
    = static_cast<LayoutModelPlugin*>(model->getPlugin("layout"));
  Layout* layout = mplugin->createLayout();

  layout->setId("Layout_1");
  Dimensions dim(&layoutns, 400.0, 220.0);
  layout->setDimensions(&dim);

  // create the CompartmentGlyph

  CompartmentGlyph* compartmentGlyph = layout->createCompartmentGlyph();
  compartmentGlyph->setId("CompartmentGlyph_1");
  compartmentGlyph->setCompartmentId(compartment->getId());
  BoundingBox bb(&layoutns, "bb1", 5, 5, 390, 210);
  compartmentGlyph->setBoundingBox(&bb);

  // create the SpeciesGlyphs

  SpeciesGlyph* speciesGlyph1 = layout->createSpeciesGlyph();
  speciesGlyph1->setId("SpeciesGlyph_1");
  speciesGlyph1->setSpeciesId(species1->getId());
  bb = BoundingBox(&layoutns, "bb2", 80, 26, 240, 24);
  speciesGlyph1->setBoundingBox(&bb);

  TextGlyph* textGlyph1 = layout->createTextGlyph();
  textGlyph1->setId("TextGlyph_01");
  bb = BoundingBox(&layoutns, "bbA", 92, 26, 228, 24);
  textGlyph1->setBoundingBox(&bb);
  textGlyph1->setOriginOfTextId(speciesGlyph1->getId());
  textGlyph1->setGraphicalObjectId(speciesGlyph1->getId());

  SpeciesGlyph* speciesGlyph2 = layout->createSpeciesGlyph();
  speciesGlyph2->setId("SpeciesGlyph_2");
  speciesGlyph2->setSpeciesId(species2->getId());
  bb = BoundingBox(&layoutns, "bb3", 80, 170, 240, 24);
  speciesGlyph2->setBoundingBox(&bb);

  TextGlyph* textGlyph2 = layout->createTextGlyph();
  textGlyph2->setId("TextGlyph_02");
  bb = BoundingBox(&layoutns, "bbB", 92, 170, 228, 24);
  textGlyph2->setBoundingBox(&bb);
  textGlyph2->setOriginOfTextId(speciesGlyph2->getId());
  textGlyph2->setGraphicalObjectId(speciesGlyph2->getId());

  // create the ReactionGlyphs

  ReactionGlyph* reactionGlyph1 = layout->createReactionGlyph();
  reactionGlyph1->setId("ReactionGlyph_1");
  reactionGlyph1->setReactionId(reaction1->getId());

  Curve* reactionCurve1 = reactionGlyph1->getCurve();
  LineSegment* ls = reactionCurve1->createLineSegment();
  Point p(&layoutns, 165, 105);
  ls->setStart(&p);
  p = Point(&layoutns, 165, 115);
  ls->setEnd(&p);

  ReactionGlyph* reactionGlyph2 = layout->createReactionGlyph();
  reactionGlyph2->setId("ReactionGlyph_1");
  reactionGlyph2->setReactionId(reaction2->getId());

  Curve* reactionCurve2 = reactionGlyph2->getCurve();
  ls = reactionCurve2->createLineSegment();
  p = Point(&layoutns, 235, 105);
  ls->setStart(&p);
  p = Point(&layoutns, 235, 115);
  ls->setEnd(&p);

  // add the SpeciesReferenceGlyphs

  SpeciesReferenceGlyph* speciesReferenceGlyph1 = reactionGlyph1->createSpeciesReferenceGlyph();
  speciesReferenceGlyph1->setId("SpeciesReferenceGlyph_1");
  speciesReferenceGlyph1->setSpeciesGlyphId(speciesGlyph1->getId());
  speciesReferenceGlyph1->setSpeciesReferenceId(reference1->getId());
  speciesReferenceGlyph1->setRole(SPECIES_ROLE_SUBSTRATE);

  Curve* speciesReferenceCurve1 = speciesReferenceGlyph1->getCurve();
  CubicBezier* cb = speciesReferenceCurve1->createCubicBezier();
  p = Point(&layoutns, 165, 105);
  cb->setStart(&p);
  p = Point(&layoutns, 165, 90);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 165, 90);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 195, 60);
  cb->setEnd(&p);

  SpeciesReferenceGlyph* speciesReferenceGlyph2
    = reactionGlyph1->createSpeciesReferenceGlyph();
  speciesReferenceGlyph2->setId("SpeciesReferenceGlyph_2");
  speciesReferenceGlyph2->setSpeciesGlyphId(speciesGlyph2->getId());
  speciesReferenceGlyph2->setSpeciesReferenceId(reference2->getId());
  speciesReferenceGlyph2->setRole(SPECIES_ROLE_PRODUCT);

  Curve* speciesReferenceCurve2 = speciesReferenceGlyph2->getCurve();
  cb = speciesReferenceCurve2->createCubicBezier();
  p = Point(&layoutns, 165, 115);
  cb->setStart(&p);
  p = Point(&layoutns, 165, 130);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 165, 130);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 195, 160);
  cb->setEnd(&p);

  SpeciesReferenceGlyph* speciesReferenceGlyph3
    = reactionGlyph2->createSpeciesReferenceGlyph();
  speciesReferenceGlyph3->setId("SpeciesReferenceGlyph_3");
  speciesReferenceGlyph3->setSpeciesGlyphId(speciesGlyph2->getId());
  speciesReferenceGlyph3->setSpeciesReferenceId(reference3->getId());
  speciesReferenceGlyph3->setRole(SPECIES_ROLE_SUBSTRATE);

  Curve* speciesReferenceCurve3 = speciesReferenceGlyph3->getCurve();
  cb = speciesReferenceCurve3->createCubicBezier();
  p = Point(&layoutns, 235, 115);
  cb->setStart(&p);
  p = Point(&layoutns, 235, 130);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 235, 130);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 205, 160);
  cb->setEnd(&p);

  SpeciesReferenceGlyph* speciesReferenceGlyph4
    = reactionGlyph2->createSpeciesReferenceGlyph();
  speciesReferenceGlyph4->setId("SpeciesReferenceGlyph_4");
  speciesReferenceGlyph4->setSpeciesGlyphId(speciesGlyph1->getId());
  speciesReferenceGlyph4->setSpeciesReferenceId(reference4->getId());
  speciesReferenceGlyph4->setRole(SPECIES_ROLE_PRODUCT);

  Curve* speciesReferenceCurve4 = speciesReferenceGlyph4->getCurve();
  cb = speciesReferenceCurve4->createCubicBezier();
  p = Point(&layoutns, 235, 105);
  cb->setStart(&p);
  p = Point(&layoutns, 235, 90);
  cb->setBasePoint1(&p);
  p = Point(&layoutns, 235, 90);
  cb->setBasePoint2(&p);
  p = Point(&layoutns, 205, 60);
  cb->setEnd(&p);

  writeSBML(document,"layout_example1_L2.xml");
  delete document;
}

