/**
 * Filename    : TestLayoutWriting.cpp
 * Description : Unit tests for writing layout in the context of a complete model.
 * Organization: European Media Laboratories Research gGmbH
 * Created     : 2007-02-23
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
#include <string>

#include <locale.h>

#include <sbml/common/common.h>

#include <sbml/packages/layout/extension/LayoutModelPlugin.h>
#include <sbml/packages/layout/sbml/Layout.h>
#include <sbml/packages/layout/sbml/GraphicalObject.h>
#include <sbml/packages/layout/sbml/CompartmentGlyph.h>
#include <sbml/packages/layout/sbml/SpeciesGlyph.h>
#include <sbml/packages/layout/sbml/ReactionGlyph.h>
#include <sbml/packages/layout/sbml/TextGlyph.h>
#include <sbml/packages/layout/sbml/SpeciesReferenceGlyph.h>
#include <sbml/packages/layout/sbml/LineSegment.h>
#include <sbml/packages/layout/sbml/CubicBezier.h>
#include <sbml/packages/layout/sbml/Curve.h>
#include <sbml/packages/layout/sbml/Point.h>
#include <sbml/packages/layout/sbml/Dimensions.h>
#include <sbml/Reaction.h>
#include <sbml/Species.h>
#include <sbml/Compartment.h>
#include <sbml/Model.h>
#include <sbml/SBMLDocument.h>
#include <sbml/SBMLWriter.h>
#include <sbml/SBMLTypes.h>

#include <check.h>


#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLNode.h>
#include "utility.h"


using namespace std;
LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static LayoutPkgNamespaces* LN;

void
LayoutWritingTest_setup (void)
{
  LN = new LayoutPkgNamespaces(2,1);
}

void
LayoutWritingTest_teardown (void)
{
  delete LN;
}


START_TEST (test_LayoutWriting)
{
  std::string s =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
  "<sbml xmlns=\"http://www.sbml.org/sbml/level2\" level=\"2\" version=\"1\">"
  "  <model id=\"TestModel\">"
  "          <annotation>"
  "  <listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">"
  "    <layout id=\"Layout_1\">"
  "      <dimensions width=\"2320\" height=\"1000\"/>"
  "      <listOfCompartmentGlyphs>"
  "        <compartmentGlyph id=\"CompartmentGlyph_1\" compartment=\"Hepatocyte\">"
  "          <boundingBox id=\"bb_compartment\">"
  "            <position x=\"10\" y=\"10\"/>"
  "            <dimensions width=\"2300\" height=\"980\"/>"
  "          </boundingBox>"
  "        </compartmentGlyph>"
  "        <compartmentGlyph id=\"Mito1_Glyph\" compartment=\"Mito_1\">"
  "          <boundingBox id=\"bb_mito1\">"
  "            <position x=\"100\" y=\"100\"/>"
  "            <dimensions width=\"300\" height=\"100\"/>"
  "          </boundingBox>"
  "        </compartmentGlyph>"
  "        <compartmentGlyph id=\"Mito2_Glyph\" compartment=\"Mito_2\">"
  "          <boundingBox id=\"bb_mito2\">"
  "            <position x=\"200\" y=\"650\"/>"
  "            <dimensions width=\"300\" height=\"100\"/>"
  "          </boundingBox>"
  "        </compartmentGlyph>"
  "        <compartmentGlyph id=\"Mito3_Glyph_2\" compartment=\"Mito_3\">"
  "          <boundingBox id=\"bb_mito3_2\">"
  "            <position x=\"1470\" y=\"30\"/>"
  "            <dimensions width=\"820\" height=\"536\"/>"
  "          </boundingBox>"
  "        </compartmentGlyph>"
  "      </listOfCompartmentGlyphs>"
  "      <listOfSpeciesGlyphs>"
  "        <speciesGlyph id=\"SpeciesGlyph_malate_cyt\" species=\"malate_cyt\">"
  "          <boundingBox id=\"bb_sg_malate_cyt\">"
  "            <position x=\"580\" y=\"280\"/>"
  "            <dimensions width=\"240\" height=\"36\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_oxaloacetate_cyt\" species=\"oxaloacetate_cyt\">"
  "          <boundingBox id=\"bb_sg_oxaloacetate_cyt\">"
  "            <position x=\"580\" y=\"480\"/>"
  "            <dimensions width=\"240\" height=\"36\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_aspartate_cyt\" species=\"aspartate_cyt\">"
  "          <boundingBox id=\"bb_sg_aspartate_cyt\">"
  "            <position x=\"580\" y=\"680\"/>"
  "            <dimensions width=\"240\" height=\"36\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_glutamate_cyt\" species=\"glutamate_cyt\">"
  "          <boundingBox id=\"bb_sg_glutamate_cyt\">"
  "            <position x=\"800\" y=\"610\"/>"
  "            <dimensions width=\"240\" height=\"36\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_aKetoglutarate_cyt\" species=\"aKetoglutarate_cyt\">"
  "          <boundingBox id=\"bb_sg_aKetoglutarate_cyt\">"
  "            <position x=\"860\" y=\"500\"/>"
  "            <dimensions width=\"280\" height=\"36\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_nad_cyt\" species=\"nad_cyt\">"
  "          <boundingBox id=\"bb_sg_nad_cyt\">"
  "            <position x=\"520\" y=\"350\"/>"
  "            <dimensions width=\"100\" height=\"24\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_nadh_cyt\" species=\"nadh_cyt\">"
  "          <boundingBox id=\"bb_sg_nadh_cyt\">"
  "            <position x=\"520\" y=\"430\"/>"
  "            <dimensions width=\"100\" height=\"24\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_h_cyt\" species=\"h_cyt\">"
  "          <boundingBox id=\"bb_sg_h_cyt\">"
  "            <position x=\"430\" y=\"430\"/>"
  "            <dimensions width=\"40\" height=\"24\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_malate_mito3\" species=\"malate_mito3\">"
  "          <boundingBox id=\"bb_sg_malate_mito3\">"
  "            <position x=\"1850\" y=\"80\"/>"
  "            <dimensions width=\"240\" height=\"36\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_oxaloacetate_mito3\" species=\"oxaloacetate_mito3\">"
  "          <boundingBox id=\"bb_sg_oxaloacetate_mito3\">"
  "            <position x=\"1850\" y=\"280\"/>"
  "            <dimensions width=\"240\" height=\"36\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_aspartate_mito3\" species=\"aspartate_mito3\">"
  "          <boundingBox id=\"bb_sg_aspartate_mito3\">"
  "            <position x=\"1850\" y=\"480\"/>"
  "            <dimensions width=\"240\" height=\"36\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_glutamate_mito3\" species=\"glutamate_mito3\">"
  "          <boundingBox id=\"bb_sg_glutamate_mito3\">"
  "            <position x=\"1550\" y=\"430\"/>"
  "            <dimensions width=\"240\" height=\"36\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_aKetoglutarate_mito3\" species=\"aKetoglutarate_mito3\">"
  "          <boundingBox id=\"bb_sg_aKetoglutarate_mito3\">"
  "            <position x=\"1530\" y=\"300\"/>"
  "            <dimensions width=\"280\" height=\"36\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_nad_mito3\" species=\"nad_mito3\">"
  "          <boundingBox id=\"bb_sg_nad_mito3\">"
  "            <position x=\"2050\" y=\"150\"/>"
  "            <dimensions width=\"100\" height=\"24\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_nadh_mito3\" species=\"nadh_mito3\">"
  "          <boundingBox id=\"bb_sg_nadh_mito3\">"
  "            <position x=\"2050\" y=\"230\"/>"
  "            <dimensions width=\"100\" height=\"24\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "        <speciesGlyph id=\"SpeciesGlyph_h_mito3\" species=\"h_mito3\">"
  "          <boundingBox id=\"bb_sg_h_mito3\">"
  "            <position x=\"2200\" y=\"230\"/>"
  "            <dimensions width=\"40\" height=\"24\"/>"
  "          </boundingBox>"
  "        </speciesGlyph>"
  "      </listOfSpeciesGlyphs>"
  "      <listOfReactionGlyphs>"
  "        <reactionGlyph id=\"rg_malatedh_cyt\" reaction=\"reaction_malatedh_cyt\">"
  "          <curve>"
  "            <listOfCurveSegments>"
  "              <curveSegment xsi:type=\"LineSegment\">"
  "                <start x=\"700\" y=\"381\"/>"
  "                <end x=\"700\" y=\"415\"/>"
  "              </curveSegment>"
  "            </listOfCurveSegments>"
  "          </curve>"
  "          <listOfSpeciesReferenceGlyphs>"
  "            <speciesReferenceGlyph id=\"srg_malate_cyt_1\" speciesReference=\"sr_malate_cyt\" speciesGlyph=\"SpeciesGlyph_malate_cyt\" role=\"substrate\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"LineSegment\">"
  "                    <start x=\"700\" y=\"381\"/>"
  "                    <end x=\"700\" y=\"316\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_nad_cyt\" speciesReference=\"sr_nad_cyt\" speciesGlyph=\"SpeciesGlyph_nad_cyt\" role=\"substrate\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"700\" y=\"381\"/>"
  "                    <end x=\"620\" y=\"362\"/>"
  "                    <basePoint1 x=\"700\" y=\"362\"/>"
  "                    <basePoint2 x=\"700\" y=\"362\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_oxaloacetate_cyt_1\" speciesReference=\"sr_oxaloacetate_cyt_1\" speciesGlyph=\"SpeciesGlyph_oxaloacetate_cyt\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"LineSegment\">"
  "                    <start x=\"700\" y=\"415\"/>"
  "                    <end x=\"700\" y=\"480\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_nadh_cyt\" speciesReference=\"sr_nadh_cyt\" speciesGlyph=\"SpeciesGlyph_nadh_cyt\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"700\" y=\"415\"/>"
  "                    <end x=\"620\" y=\"442\"/>"
  "                    <basePoint1 x=\"700\" y=\"442\"/>"
  "                    <basePoint2 x=\"700\" y=\"442\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_h_cyt\" speciesReference=\"sr_h_cyt\" speciesGlyph=\"SpeciesGlyph_h_cyt\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"700\" y=\"415\"/>"
  "                    <end x=\"470\" y=\"430\"/>"
  "                    <basePoint1 x=\"570\" y=\"415\"/>"
  "                    <basePoint2 x=\"570\" y=\"415\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "          </listOfSpeciesReferenceGlyphs>"
  "        </reactionGlyph>"
  "        <reactionGlyph id=\"rg_aspartateat_cyt\" reaction=\"reaction_aspartateat_cyt\">"
  "          <curve>"
  "            <listOfCurveSegments>"
  "              <curveSegment xsi:type=\"LineSegment\">"
  "                <start x=\"700\" y=\"581\"/>"
  "                <end x=\"700\" y=\"615\"/>"
  "              </curveSegment>"
  "            </listOfCurveSegments>"
  "          </curve>"
  "          <listOfSpeciesReferenceGlyphs>"
  "            <speciesReferenceGlyph id=\"srg_oxaloacetate_cyt_2\" speciesReference=\"sr_oxaloacetate_cyt_2\" speciesGlyph=\"SpeciesGlyph_oxaloacetate_cyt\" role=\"substrate\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"LineSegment\">"
  "                    <start x=\"700\" y=\"581\"/>"
  "                    <end x=\"700\" y=\"516\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_glutamate_cyt_1\" speciesReference=\"sr_glutamate_cyt_1\" speciesGlyph=\"SpeciesGlyph_glutamate_cyt\" role=\"substrate\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"700\" y=\"581\"/>"
  "                    <end x=\"800\" y=\"628\"/>"
  "                    <basePoint1 x=\"750\" y=\"581\"/>"
  "                    <basePoint2 x=\"750\" y=\"628\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_aspartate_cyt_1\" speciesReference=\"sr_aspartate_cyt_1\" speciesGlyph=\"SpeciesGlyph_aspartate_cyt\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"LineSegment\">"
  "                    <start x=\"700\" y=\"615\"/>"
  "                    <end x=\"700\" y=\"680\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_aKetoglutaratecyt_1\" speciesReference=\"sr_aKetoglutarate_cyt_1\" speciesGlyph=\"SpeciesGlyph_aKetoglutarate_cyt\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"700\" y=\"615\"/>"
  "                    <end x=\"860\" y=\"515\"/>"
  "                    <basePoint1 x=\"790\" y=\"615\"/>"
  "                    <basePoint2 x=\"790\" y=\"515\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "          </listOfSpeciesReferenceGlyphs>"
  "        </reactionGlyph>"
  "        <reactionGlyph id=\"rg_malatedh_mito3\" reaction=\"reaction_malatedh_mito3\">"
  "          <curve>"
  "            <listOfCurveSegments>"
  "              <curveSegment xsi:type=\"LineSegment\">"
  "                <start x=\"1970\" y=\"181\"/>"
  "                <end x=\"1970\" y=\"215\"/>"
  "              </curveSegment>"
  "            </listOfCurveSegments>"
  "          </curve>"
  "          <listOfSpeciesReferenceGlyphs>"
  "            <speciesReferenceGlyph id=\"srg_malate_mito3_1\" speciesReference=\"sr_malate_mito3\" speciesGlyph=\"SpeciesGlyph_malate_mito3\" role=\"substrate\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"LineSegment\">"
  "                    <start x=\"1970\" y=\"181\"/>"
  "                    <end x=\"1970\" y=\"116\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_nad_mito3\" speciesReference=\"sr_nad_mito3\" speciesGlyph=\"SpeciesGlyph_nad_mito3\" role=\"substrate\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"1970\" y=\"181\"/>"
  "                    <end x=\"2050\" y=\"162\"/>"
  "                    <basePoint1 x=\"1970\" y=\"162\"/>"
  "                    <basePoint2 x=\"1970\" y=\"162\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_oxaloacetate_mito3_1\" speciesReference=\"sr_oxaloacetate_mito3_1\" speciesGlyph=\"SpeciesGlyph_oxaloacetate_mito3\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"LineSegment\">"
  "                    <start x=\"1970\" y=\"215\"/>"
  "                    <end x=\"1970\" y=\"280\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_nadh_mito3\" speciesReference=\"sr_nadh_mito3\" speciesGlyph=\"SpeciesGlyph_nadh_mito3\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"1970\" y=\"215\"/>"
  "                    <end x=\"2050\" y=\"242\"/>"
  "                    <basePoint1 x=\"1970\" y=\"242\"/>"
  "                    <basePoint2 x=\"1970\" y=\"242\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_h_mito3\" speciesReference=\"sr_h_mito3\" speciesGlyph=\"SpeciesGlyph_h_mito3\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"1970\" y=\"215\"/>"
  "                    <end x=\"2200\" y=\"230\"/>"
  "                    <basePoint1 x=\"2100\" y=\"215\"/>"
  "                    <basePoint2 x=\"2100\" y=\"215\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "          </listOfSpeciesReferenceGlyphs>"
  "        </reactionGlyph>"
  "        <reactionGlyph id=\"rg_aspartateat_mito3\" reaction=\"reaction_aspartateat_mito3\">"
  "          <curve>"
  "            <listOfCurveSegments>"
  "              <curveSegment xsi:type=\"LineSegment\">"
  "                <start x=\"1970\" y=\"381\"/>"
  "                <end x=\"1970\" y=\"415\"/>"
  "              </curveSegment>"
  "            </listOfCurveSegments>"
  "          </curve>"
  "          <listOfSpeciesReferenceGlyphs>"
  "            <speciesReferenceGlyph id=\"srg_oxaloacetate_mito3_2\" speciesReference=\"sr_oxaloacetate_mito3_2\" speciesGlyph=\"SpeciesGlyph_oxaloacetate_mito3\" role=\"substrate\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"LineSegment\">"
  "                    <start x=\"1970\" y=\"381\"/>"
  "                    <end x=\"1970\" y=\"316\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_glutamate_mito3_1\" speciesReference=\"sr_glutamate_mito3_1\" speciesGlyph=\"SpeciesGlyph_glutamate_mito3\" role=\"substrate\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"1970\" y=\"381\"/>"
  "                    <end x=\"1790\" y=\"448\"/>"
  "                    <basePoint1 x=\"1880\" y=\"381\"/>"
  "                    <basePoint2 x=\"1880\" y=\"448\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_aspartate_mito3_1\" speciesReference=\"sr_aspartate_mito3_1\" speciesGlyph=\"SpeciesGlyph_aspartate_mito3\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"LineSegment\">"
  "                    <start x=\"1970\" y=\"415\"/>"
  "                    <end x=\"1970\" y=\"480\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_aKetoglutaratemito3_1\" speciesReference=\"sr_aKetoglutarate_mito3_1\" speciesGlyph=\"SpeciesGlyph_aKetoglutarate_mito3\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"1970\" y=\"415\"/>"
  "                    <end x=\"1810\" y=\"315\"/>"
  "                    <basePoint1 x=\"1880\" y=\"415\"/>"
  "                    <basePoint2 x=\"1880\" y=\"315\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "          </listOfSpeciesReferenceGlyphs>"
  "        </reactionGlyph>"
  "        <reactionGlyph id=\"rg_aspartateCarrier\" reaction=\"aspartateCarrier\">"
  "          <curve>"
  "            <listOfCurveSegments>"
  "              <curveSegment xsi:type=\"LineSegment\">"
  "                <start x=\"1420\" y=\"530\"/>"
  "                <end x=\"1360\" y=\"550\"/>"
  "              </curveSegment>"
  "            </listOfCurveSegments>"
  "          </curve>"
  "          <listOfSpeciesReferenceGlyphs>"
  "            <speciesReferenceGlyph id=\"srg_aspartate_mito3_2\" speciesReference=\"sr_aspartate_mito3_2\" speciesGlyph=\"SpeciesGlyph_aspartate_mito3\" role=\"substrate\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"LineSegment\">"
  "                    <start x=\"1420\" y=\"530\"/>"
  "                    <end x=\"1850\" y=\"498\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_aspartate_cyt_2\" speciesReference=\"sr_aspartate_cyt_2\" speciesGlyph=\"SpeciesGlyph_aspartate_cyt\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"1360\" y=\"550\"/>"
  "                    <end x=\"820\" y=\"698\"/>"
  "                    <basePoint1 x=\"1390\" y=\"698\"/>"
  "                    <basePoint2 x=\"1390\" y=\"698\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_glutamate_cyt_2\" speciesReference=\"sr_glutamate_cyt_2\" speciesGlyph=\"SpeciesGlyph_glutamate_cyt\" role=\"substrate\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"1420\" y=\"530\"/>"
  "                    <end x=\"1050\" y=\"628\"/>"
  "                    <basePoint1 x=\"1390\" y=\"648\"/>"
  "                    <basePoint2 x=\"1390\" y=\"648\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_glutamate_mito3_2\" speciesReference=\"sr_glutamate_mito3_2\" speciesGlyph=\"SpeciesGlyph_glutamate_mito3\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"1360\" y=\"550\"/>"
  "                    <end x=\"1550\" y=\"448\"/>"
  "                    <basePoint1 x=\"1390\" y=\"448\"/>"
  "                    <basePoint2 x=\"1390\" y=\"448\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "          </listOfSpeciesReferenceGlyphs>"
  "        </reactionGlyph>"
  "        <reactionGlyph id=\"rg_malateCarrier\" reaction=\"malateCarrier\">"
  "          <curve>"
  "            <listOfCurveSegments>"
  "              <curveSegment xsi:type=\"LineSegment\">"
  "                <start x=\"1420\" y=\"320\"/>"
  "                <end x=\"1360\" y=\"340\"/>"
  "              </curveSegment>"
  "            </listOfCurveSegments>"
  "          </curve>"
  "          <listOfSpeciesReferenceGlyphs>"
  "            <speciesReferenceGlyph id=\"srg_aKetoglutarate_mito3_2\" speciesReference=\"sr_aKetoglutarate_mito3_2\" speciesGlyph=\"SpeciesGlyph_aKetoglutarate_mito3\" role=\"substrate\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"LineSegment\">"
  "                    <start x=\"1420\" y=\"320\"/>"
  "                    <end x=\"1530\" y=\"318\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_aKetoglutarate_cyt_2\" speciesReference=\"sr_aKetoglutarate_cyt_2\" speciesGlyph=\"SpeciesGlyph_aKetoglutarate_cyt\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"LineSegment\">"
  "                    <start x=\"1360\" y=\"340\"/>"
  "                    <end x=\"1140\" y=\"518\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_malate_cyt_2\" speciesReference=\"sr_malate_cyt_2\" speciesGlyph=\"SpeciesGlyph_malate_cyt\" role=\"substrate\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"1420\" y=\"320\"/>"
  "                    <end x=\"820\" y=\"298\"/>"
  "                    <basePoint1 x=\"1390\" y=\"250\"/>"
  "                    <basePoint2 x=\"1390\" y=\"250\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "            <speciesReferenceGlyph id=\"srg_malate_mito3_2\" speciesReference=\"sr_malate_mito3_2\" speciesGlyph=\"SpeciesGlyph_malate_mito3\" role=\"product\">"
  "              <curve>"
  "                <listOfCurveSegments>"
  "                  <curveSegment xsi:type=\"CubicBezier\">"
  "                    <start x=\"1360\" y=\"340\"/>"
  "                    <end x=\"1850\" y=\"98\"/>"
  "                    <basePoint1 x=\"1390\" y=\"150\"/>"
  "                    <basePoint2 x=\"1390\" y=\"150\"/>"
  "                  </curveSegment>"
  "                </listOfCurveSegments>"
  "              </curve>"
  "            </speciesReferenceGlyph>"
  "          </listOfSpeciesReferenceGlyphs>"
  "        </reactionGlyph>"
  "      </listOfReactionGlyphs>"
  "      <listOfTextGlyphs>"
  "        <textGlyph id=\"TextGlyph_Hepatocyte\" graphicalObject=\"CompartmentGlyph_1\" originOfText=\"Hepatocyte\">"
  "          <boundingBox id=\"bb_tg_compartment\">"
  "            <position x=\"50\" y=\"870\"/>"
  "            <dimensions width=\"300\" height=\"72\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_mito1\" graphicalObject=\"Mito1_Glyph\" originOfText=\"Mito_1\">"
  "          <boundingBox id=\"bb_tg_mito1\">"
  "            <position x=\"110\" y=\"110\"/>"
  "            <dimensions width=\"280\" height=\"72\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_mito2\" graphicalObject=\"Mito2_Glyph\" originOfText=\"Mito_2\">"
  "          <boundingBox id=\"bb_tg_mito2\">"
  "            <position x=\"210\" y=\"660\"/>"
  "            <dimensions width=\"280\" height=\"72\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_mito3_2\" graphicalObject=\"Mito3_Glyph_2\" originOfText=\"Mito_3\">"
  "          <boundingBox id=\"bb_tg_mito3_2\">"
  "            <position x=\"1475\" y=\"35\"/>"
  "            <dimensions width=\"200\" height=\"72\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_malate_cyt\" graphicalObject=\"SpeciesGlyph_malate_cyt\" originOfText=\"malate_cyt\">"
  "          <boundingBox id=\"bb_tg_malatate_cyt\">"
  "            <position x=\"590\" y=\"280\"/>"
  "            <dimensions width=\"220\" height=\"36\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_oxaloacetate_cyt\" graphicalObject=\"SpeciesGlyph_oxaloacetate_cyt\" originOfText=\"oxaloacetate_cyt\">"
  "          <boundingBox id=\"bb_tg_oxaloacetate_cyt\">"
  "            <position x=\"590\" y=\"480\"/>"
  "            <dimensions width=\"220\" height=\"36\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_aspartate_cyt\" graphicalObject=\"SpeciesGlyph_aspartate_cyt\" originOfText=\"aspartate_cyt\">"
  "          <boundingBox id=\"bb_tg_aspartate_cyt\">"
  "            <position x=\"590\" y=\"680\"/>"
  "            <dimensions width=\"220\" height=\"36\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_glutamate_cyt\" graphicalObject=\"SpeciesGlyph_glutamate_cyt\" originOfText=\"glutamate_cyt\">"
  "          <boundingBox id=\"bb_tg_glutamate_cyt\">"
  "            <position x=\"810\" y=\"610\"/>"
  "            <dimensions width=\"220\" height=\"36\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_aKetoglutarate_cyt\" graphicalObject=\"SpeciesGlyph_aKetoglutarate_cyt\" originOfText=\"aKetoglutarate_cyt\">"
  "          <boundingBox id=\"bb_tg_aKetoglutarate_cyt\">"
  "            <position x=\"870\" y=\"500\"/>"
  "            <dimensions width=\"260\" height=\"36\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_nad_cyt\" graphicalObject=\"SpeciesGlyph_nad_cyt\" originOfText=\"nad_cyt\">"
  "          <boundingBox id=\"bb_tg_nad_cyt\">"
  "            <position x=\"525\" y=\"350\"/>"
  "            <dimensions width=\"80\" height=\"24\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_nadh_cyt\" graphicalObject=\"SpeciesGlyph_nadh_cyt\" originOfText=\"nadh_cyt\">"
  "          <boundingBox id=\"bb_tg_nadh_cyt\">"
  "            <position x=\"525\" y=\"430\"/>"
  "            <dimensions width=\"80\" height=\"24\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_h_cyt\" graphicalObject=\"SpeciesGlyph_h_cyt\" originOfText=\"h_cyt\">"
  "          <boundingBox id=\"bb_tg_h_cyt\">"
  "            <position x=\"435\" y=\"430\"/>"
  "            <dimensions width=\"30\" height=\"24\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"tg_rg_malaltedh_cyt\" graphicalObject=\"rg_malatedh_cyt\" originOfText=\"reaction_malatedh_cyt\">"
  "          <boundingBox id=\"bb_tg_rg_malaltedh_cyt\">"
  "            <position x=\"700\" y=\"385\"/>"
  "            <dimensions width=\"210\" height=\"24\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"tg_rg_aspartateat_cyt\" graphicalObject=\"rg_aspartateat_cyt\" originOfText=\"reaction_aspartateat_cyt\">"
  "          <boundingBox id=\"bb_tg_rg_aspartateat_cyt\">"
  "            <position x=\"440\" y=\"585\"/>"
  "            <dimensions width=\"260\" height=\"24\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_malate_mito3\" graphicalObject=\"SpeciesGlyph_malate_mito3\" originOfText=\"malate_mito3\">"
  "          <boundingBox id=\"bb_tg_malatate_mito3\">"
  "            <position x=\"1860\" y=\"80\"/>"
  "            <dimensions width=\"220\" height=\"36\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_oxaloacetate_mito3\" graphicalObject=\"SpeciesGlyph_oxaloacetate_mito3\" originOfText=\"oxaloacetate_mito3\">"
  "          <boundingBox id=\"bb_tg_oxaloacetate_mito3\">"
  "            <position x=\"1860\" y=\"280\"/>"
  "            <dimensions width=\"220\" height=\"36\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_aspartate_mito3\" graphicalObject=\"SpeciesGlyph_aspartate_mito3\" originOfText=\"aspartate_mito3\">"
  "          <boundingBox id=\"bb_tg_aspartate_mito3\">"
  "            <position x=\"1860\" y=\"480\"/>"
  "            <dimensions width=\"220\" height=\"36\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_glutamate_mito3\" graphicalObject=\"SpeciesGlyph_glutamate_mito3\" originOfText=\"glutamate_mito3\">"
  "          <boundingBox id=\"bb_tg_glutamate_mito3\">"
  "            <position x=\"1560\" y=\"430\"/>"
  "            <dimensions width=\"220\" height=\"36\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_aKetoglutarate_mito3\" graphicalObject=\"SpeciesGlyph_aKetoglutarate_mito3\" originOfText=\"aKetoglutarate_mito3\">"
  "          <boundingBox id=\"bb_tg_aKetoglutarate_mito3\">"
  "            <position x=\"1540\" y=\"300\"/>"
  "            <dimensions width=\"260\" height=\"36\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_nad_mito3\" graphicalObject=\"SpeciesGlyph_nad_mito3\" originOfText=\"nad_mito3\">"
  "          <boundingBox id=\"bb_tg_nad_mito3\">"
  "            <position x=\"2055\" y=\"150\"/>"
  "            <dimensions width=\"80\" height=\"24\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_nadh_mito3\" graphicalObject=\"SpeciesGlyph_nadh_mito3\" originOfText=\"nadh_mito3\">"
  "          <boundingBox id=\"bb_tg_nadh_mito3\">"
  "            <position x=\"2055\" y=\"230\"/>"
  "            <dimensions width=\"80\" height=\"24\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"TextGlyph_h_mito3\" graphicalObject=\"SpeciesGlyph_h_mito3\" originOfText=\"h_mito3\">"
  "          <boundingBox id=\"bb_tg_h_mito3\">"
  "            <position x=\"2205\" y=\"230\"/>"
  "            <dimensions width=\"30\" height=\"24\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"tg_rg_malatedh_mito3\" graphicalObject=\"rg_malatedh_mito3\" originOfText=\"reaction_malatedh_mito3\">"
  "          <boundingBox id=\"bb_tg_rg_malatedh_mito3\">"
  "            <position x=\"1740\" y=\"185\"/>"
  "            <dimensions width=\"220\" height=\"24\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"tg_rg_aspartateat_mito3\" graphicalObject=\"rg_aspartateat_mito3\" originOfText=\"reaction_aspartateat_mito3\">"
  "          <boundingBox id=\"bb_tg_rg_aspartateat_mito3\">"
  "            <position x=\"1970\" y=\"385\"/>"
  "            <dimensions width=\"260\" height=\"24\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"tg_rg_aspartateCarrier\" graphicalObject=\"rg_aspartateCarrier\" originOfText=\"aspartateCarrier\">"
  "          <boundingBox id=\"bb_tg_rg_aspartateCarrier\">"
  "            <position x=\"1380\" y=\"500\"/>"
  "            <dimensions width=\"160\" height=\"24\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "        <textGlyph id=\"tg_rg_malateCarrier\" graphicalObject=\"rg_malateCarrier\" originOfText=\"malateCarrier\">"
  "          <boundingBox id=\"bb_tg_rg_malateCarrier\">"
  "            <position x=\"1360\" y=\"330\"/>"
  "            <dimensions width=\"140\" height=\"24\"/>"
  "          </boundingBox>"
  "        </textGlyph>"
  "      </listOfTextGlyphs>"
  "    </layout>"
  "  </listOfLayouts>"
  "            </annotation>"
  "    <listOfCompartments>"
  "      <compartment id=\"Hepatocyte\" name=\"Hepatocyte\"/>"
  "      <compartment id=\"Mito_1\" name=\"Mito 1\" outside=\"Hepatocyte\"/>"
  "      <compartment id=\"Mito_2\" name=\"Mito 2\" outside=\"Hepatocyte\"/>"
  "      <compartment id=\"Mito_3\" name=\"Mito 3\" outside=\"Hepatocyte\"/>"
  "    </listOfCompartments>"
  "    <listOfSpecies>"
  "      <species id=\"malate_cyt\" name=\"Malate\" compartment=\"Hepatocyte\"/>"
  "      <species id=\"malate_mito1\" name=\"Malate\" compartment=\"Mito_1\"/>"
  "      <species id=\"malate_mito2\" name=\"Malate\" compartment=\"Mito_2\"/>"
  "      <species id=\"malate_mito3\" name=\"Malate\" compartment=\"Mito_3\"/>"
  "      <species id=\"oxaloacetate_cyt\" name=\"Oxaloacetate\" compartment=\"Hepatocyte\"/>"
  "      <species id=\"oxaloacetate_mito1\" name=\"Oxaloacetate\" compartment=\"Mito_1\"/>"
  "      <species id=\"oxaloacetate_mito2\" name=\"Oxaloacetate\" compartment=\"Mito_2\"/>"
  "      <species id=\"oxaloacetate_mito3\" name=\"Oxaloacetate\" compartment=\"Mito_3\"/>"
  "      <species id=\"aspartate_cyt\" name=\"Aspartate\" compartment=\"Hepatocyte\"/>"
  "      <species id=\"aspartate_mito1\" name=\"Aspartate\" compartment=\"Mito_1\"/>"
  "      <species id=\"aspartate_mito2\" name=\"Aspartate\" compartment=\"Mito_2\"/>"
  "      <species id=\"aspartate_mito3\" name=\"Aspartate\" compartment=\"Mito_3\"/>"
  "      <species id=\"glutamate_cyt\" name=\"Glutamate\" compartment=\"Hepatocyte\"/>"
  "      <species id=\"glutamate_mito1\" name=\"Glutamate\" compartment=\"Mito_1\"/>"
  "      <species id=\"glutamate_mito2\" name=\"Glutamate\" compartment=\"Mito_2\"/>"
  "      <species id=\"glutamate_mito3\" name=\"Glutamate\" compartment=\"Mito_3\"/>"
  "      <species id=\"aKetoglutarate_cyt\" name=\"alpha-Ketoglutarate\" compartment=\"Hepatocyte\"/>"
  "      <species id=\"aKetoglutarate_mito1\" name=\"alpha-Ketoglutarate\" compartment=\"Mito_1\"/>"
  "      <species id=\"aKetoglutarate_mito2\" name=\"alpha-Ketoglutarate\" compartment=\"Mito_2\"/>"
  "      <species id=\"aKetoglutarate_mito3\" name=\"alpha-Ketoglutarate\" compartment=\"Mito_3\"/>"
  "      <species id=\"h_cyt\" name=\"H+\" compartment=\"Hepatocyte\"/>"
  "      <species id=\"h_mito1\" name=\"H+\" compartment=\"Mito_1\"/>"
  "      <species id=\"h_mito2\" name=\"H+\" compartment=\"Mito_2\"/>"
  "      <species id=\"h_mito3\" name=\"H+\" compartment=\"Mito_3\"/>"
  "      <species id=\"nad_cyt\" name=\"NAD+\" compartment=\"Hepatocyte\"/>"
  "      <species id=\"nad_mito1\" name=\"NAD+\" compartment=\"Mito_1\"/>"
  "      <species id=\"nad_mito2\" name=\"NAD+\" compartment=\"Mito_2\"/>"
  "      <species id=\"nad_mito3\" name=\"NAD+\" compartment=\"Mito_3\"/>"
  "      <species id=\"nadh_cyt\" name=\"NADH\" compartment=\"Hepatocyte\"/>"
  "      <species id=\"nadh_mito1\" name=\"NADH\" compartment=\"Mito_1\"/>"
  "      <species id=\"nadh_mito2\" name=\"NADH\" compartment=\"Mito_2\"/>"
  "      <species id=\"nadh_mito3\" name=\"NADH\" compartment=\"Mito_3\"/>"
  "    </listOfSpecies>"
  "    <listOfReactions>"
  "      <reaction id=\"reaction_malatedh_cyt\" name=\"malate dehydrogenase\" reversible=\"false\">"
  "        <listOfReactants>"
  "          <speciesReference species=\"malate_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_malate_cyt\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"nad_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_nad_cyt\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfReactants>"
  "        <listOfProducts>"
  "          <speciesReference species=\"nadh_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_nadh_cyt\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"h_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_h_cyt\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"oxaloacetate_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_oxaloacetate_cyt_1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfProducts>"
  "      </reaction>"
  "      <reaction id=\"reaction_aspartateat_cyt\" name=\"aspartate aminotransferase\" reversible=\"false\">"
  "        <listOfReactants>"
  "          <speciesReference species=\"oxaloacetate_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_oxaloacetate_cyt_2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"glutamate_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_glutamate_cyt_1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfReactants>"
  "        <listOfProducts>"
  "          <speciesReference species=\"aspartate_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_aspartate_cyt_1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"aKetoglutarate_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_aKetoglutarate_cyt_1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfProducts>"
  "      </reaction>"
  "      <reaction id=\"reaction_malatedh_mito1\" name=\"malate dehydrogenase\" reversible=\"false\">"
  "        <listOfReactants>"
  "          <speciesReference species=\"malate_mito1\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_malate_mito1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"nad_mito1\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_nad_mito1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfReactants>"
  "        <listOfProducts>"
  "          <speciesReference species=\"nadh_mito1\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_nadh_mito1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"h_mito1\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_h_mito1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"oxaloacetate_mito1\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_oxaloacetate_mito1_1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfProducts>"
  "      </reaction>"
  "      <reaction id=\"reaction_aspartateat_mito1\" name=\"aspartate aminotransferase\" reversible=\"false\">"
  "        <listOfReactants>"
  "          <speciesReference species=\"oxaloacetate_mito1\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_oxaloacetate_mito1_2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"glutamate_mito1\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_glutamate_mito1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfReactants>"
  "        <listOfProducts>"
  "          <speciesReference species=\"aspartate_mito1\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_aspartate_mito1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"aKetoglutarate_mito1\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_aKetoglutarate_mito1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfProducts>"
  "      </reaction>"
  "      <reaction id=\"reaction_malatedh_mito2\" name=\"malate dehydrogenase\" reversible=\"false\">"
  "        <listOfReactants>"
  "          <speciesReference species=\"malate_mito2\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_malate_mito2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"nad_mito2\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_nad_mito2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfReactants>"
  "        <listOfProducts>"
  "          <speciesReference species=\"nadh_mito2\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_nadh_mito2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"h_mito2\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_h_mito2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"oxaloacetate_mito2\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_oxaloacetate_mito2_1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfProducts>"
  "      </reaction>"
  "      <reaction id=\"reaction_aspartateat_mito2\" name=\"aspartate aminotransferase\" reversible=\"false\">"
  "        <listOfReactants>"
  "          <speciesReference species=\"oxaloacetate_mito2\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_oxaloacetate_mito2_2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"glutamate_mito2\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_glutamate_mito2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfReactants>"
  "        <listOfProducts>"
  "          <speciesReference species=\"aspartate_mito2\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_aspartate_mito2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"aKetoglutarate_mito2\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_aKetoglutarate_mito2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfProducts>"
  "      </reaction>"
  "      <reaction id=\"reaction_malatedh_mito3\" name=\"malate dehydrogenase\" reversible=\"false\">"
  "        <listOfReactants>"
  "          <speciesReference species=\"malate_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_malate_mito3\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"nad_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_nad_mito3\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfReactants>"
  "        <listOfProducts>"
  "          <speciesReference species=\"nadh_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_nadh_mito3\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"h_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_h_mito3\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"oxaloacetate_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_oxaloacetate_mito3_1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfProducts>"
  "      </reaction>"
  "      <reaction id=\"reaction_aspartateat_mito3\" name=\"aspartate aminotransferase\" reversible=\"false\">"
  "        <listOfReactants>"
  "          <speciesReference species=\"oxaloacetate_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_oxaloacetate_mito3_2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"glutamate_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_glutamate_mito3_1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfReactants>"
  "        <listOfProducts>"
  "          <speciesReference species=\"aspartate_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_aspartate_mito3_1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"aKetoglutarate_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_aKetoglutarate_mito3_1\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfProducts>"
  "      </reaction>"
  "      <reaction id=\"aspartateCarrier\" name=\"aspartate carrier\">"
  "        <listOfReactants>"
  "          <speciesReference species=\"glutamate_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_glutamate_mito3_2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"aspartate_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_aspartate_cyt_2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfReactants>"
  "        <listOfProducts>"
  "          <speciesReference species=\"glutamate_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_glutamate_cyt_2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"aspartate_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_aspartate_mito3_2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfProducts>"
  "      </reaction>"
  "      <reaction id=\"malateCarrier\" name=\"malate carrier\">"
  "        <listOfReactants>"
  "          <speciesReference species=\"aKetoglutarate_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_aKetoglutarate_mito3_2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"malate_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_malate_cyt_2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfReactants>"
  "        <listOfProducts>"
  "          <speciesReference species=\"aKetoglutarate_cyt\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_aKetoglutarate_cyt_2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "          <speciesReference species=\"malate_mito3\">"
  "            <annotation>"
  "  <layoutId xmlns=\"http://projects.eml.org/bcb/sbml/level2\" id=\"sr_malate_mito3_2\"/>"
  "</annotation>"
  "          </speciesReference>"
  "        </listOfProducts>"
  "      </reaction>"
  "    </listOfReactions>"
  "  </model>"
  "</sbml> "
  ;
  
  XMLInputStream *stream = new XMLInputStream (s.c_str(),false);
  XMLNode *node = new XMLNode(*stream);
  
  fail_unless(node != NULL);
  
  // create the document
  fail_unless(LN != NULL);
  SBMLDocument *document=new SBMLDocument(LN);
  fail_unless(document != NULL);
  // create the Model
  
  Model* model=document->createModel();
  model->setId("TestModel");
  document->setModel(model);
  
  // create the Compartment
  
  Compartment* compartment=model->createCompartment();
  compartment->setId("Hepatocyte");
  compartment->setName("Hepatocyte");
  
  Compartment* mito1=model->createCompartment();
  mito1->setId("Mito_1");
  mito1->setName("Mito 1");
  mito1->setOutside(compartment->getId());
  
  Compartment* mito2=model->createCompartment();
  mito2->setId("Mito_2");
  mito2->setName("Mito 2");
  mito2->setOutside(compartment->getId());
  
  Compartment* mito3=model->createCompartment();
  mito3->setId("Mito_3");
  mito3->setName("Mito 3");
  mito3->setOutside(compartment->getId());
  
  
  // create the Species
  
  // Malate
  Species* malate_cyt=model->createSpecies();
  malate_cyt->setId("malate_cyt");
  malate_cyt->setName("Malate");
  malate_cyt->setCompartment(compartment->getId());
  
  Species* malate_mito1=model->createSpecies();
  malate_mito1->setId("malate_mito1");
  malate_mito1->setCompartment(mito1->getId());
  malate_mito1->setName("Malate");
  
  Species* malate_mito2=model->createSpecies();
  malate_mito2->setId("malate_mito2");
  malate_mito2->setCompartment(mito2->getId());
  malate_mito2->setName("Malate");
  
  Species* malate_mito3=model->createSpecies();
  malate_mito3->setId("malate_mito3");
  malate_mito3->setCompartment(mito3->getId());
  malate_mito3->setName("Malate");
  
  
  // Oxaloacetate
  Species* oxaloacetate_cyt=model->createSpecies();
  oxaloacetate_cyt->setId("oxaloacetate_cyt");
  oxaloacetate_cyt->setName("Oxaloacetate");
  oxaloacetate_cyt->setCompartment(compartment->getId());
  
  Species* oxaloacetate_mito1=model->createSpecies();
  oxaloacetate_mito1->setId("oxaloacetate_mito1");
  oxaloacetate_mito1->setCompartment(mito1->getId());
  oxaloacetate_mito1->setName("Oxaloacetate");
  
  Species* oxaloacetate_mito2=model->createSpecies();
  oxaloacetate_mito2->setId("oxaloacetate_mito2");
  oxaloacetate_mito2->setCompartment(mito2->getId());
  oxaloacetate_mito2->setName("Oxaloacetate");
  
  Species* oxaloacetate_mito3=model->createSpecies();
  oxaloacetate_mito3->setId("oxaloacetate_mito3");
  oxaloacetate_mito3->setCompartment(mito3->getId());
  oxaloacetate_mito3->setName("Oxaloacetate");
  
  
  // Aspartate
  Species* aspartate_cyt=model->createSpecies();
  aspartate_cyt->setId("aspartate_cyt");
  aspartate_cyt->setName("Aspartate");
  aspartate_cyt->setCompartment(compartment->getId());
  
  Species* aspartate_mito1=model->createSpecies();
  aspartate_mito1->setId("aspartate_mito1");
  aspartate_mito1->setCompartment(mito1->getId());
  aspartate_mito1->setName("Aspartate");
  
  Species* aspartate_mito2=model->createSpecies();
  aspartate_mito2->setId("aspartate_mito2");
  aspartate_mito2->setCompartment(mito2->getId());
  aspartate_mito2->setName("Aspartate");
  
  Species* aspartate_mito3=model->createSpecies();
  aspartate_mito3->setId("aspartate_mito3");
  aspartate_mito3->setCompartment(mito3->getId());
  aspartate_mito3->setName("Aspartate");
  
  
  // Glutamate
  Species* glutamate_cyt=model->createSpecies();
  glutamate_cyt->setId("glutamate_cyt");
  glutamate_cyt->setName("Glutamate");
  glutamate_cyt->setCompartment(compartment->getId());
  
  Species* glutamate_mito1=model->createSpecies();
  glutamate_mito1->setId("glutamate_mito1");
  glutamate_mito1->setCompartment(mito1->getId());
  glutamate_mito1->setName("Glutamate");
  
  Species* glutamate_mito2=model->createSpecies();
  glutamate_mito2->setId("glutamate_mito2");
  glutamate_mito2->setCompartment(mito2->getId());
  glutamate_mito2->setName("Glutamate");
  
  Species* glutamate_mito3=model->createSpecies();
  glutamate_mito3->setId("glutamate_mito3");
  glutamate_mito3->setCompartment(mito3->getId());
  glutamate_mito3->setName("Glutamate");
  
  
  // alpha-Ketoglutarate
  Species* aKetoglutarate_cyt=model->createSpecies();
  aKetoglutarate_cyt->setId("aKetoglutarate_cyt");
  aKetoglutarate_cyt->setName("alpha-Ketoglutarate");
  aKetoglutarate_cyt->setCompartment(compartment->getId());
  
  Species* aKetoglutarate_mito1=model->createSpecies();
  aKetoglutarate_mito1->setId("aKetoglutarate_mito1");
  aKetoglutarate_mito1->setCompartment(mito1->getId());
  aKetoglutarate_mito1->setName("alpha-Ketoglutarate");
  
  Species* aKetoglutarate_mito2=model->createSpecies();
  aKetoglutarate_mito2->setId("aKetoglutarate_mito2");
  aKetoglutarate_mito2->setCompartment(mito2->getId());
  aKetoglutarate_mito2->setName("alpha-Ketoglutarate");
  
  Species* aKetoglutarate_mito3=model->createSpecies();
  aKetoglutarate_mito3->setId("aKetoglutarate_mito3");
  aKetoglutarate_mito3->setCompartment(mito3->getId());
  aKetoglutarate_mito3->setName("alpha-Ketoglutarate");
  
  
  // protons
  Species* h_cyt=model->createSpecies();
  h_cyt->setId("h_cyt");
  h_cyt->setName("H+");
  h_cyt->setCompartment(compartment->getId());
  
  Species* h_mito1=model->createSpecies();
  h_mito1->setId("h_mito1");
  h_mito1->setCompartment(mito1->getId());
  h_mito1->setName("H+");
  
  Species* h_mito2=model->createSpecies();
  h_mito2->setId("h_mito2");
  h_mito2->setCompartment(mito2->getId());
  h_mito2->setName("H+");
  
  Species* h_mito3=model->createSpecies();
  h_mito3->setId("h_mito3");
  h_mito3->setCompartment(mito3->getId());
  h_mito3->setName("H+");
  
  
  // NAD+
  Species* nad_cyt=model->createSpecies();
  nad_cyt->setId("nad_cyt");
  nad_cyt->setName("NAD+");
  nad_cyt->setCompartment(compartment->getId());
  
  Species* nad_mito1=model->createSpecies();
  nad_mito1->setId("nad_mito1");
  nad_mito1->setCompartment(mito1->getId());
  nad_mito1->setName("NAD+");
  
  Species* nad_mito2=model->createSpecies();
  nad_mito2->setId("nad_mito2");
  nad_mito2->setCompartment(mito2->getId());
  nad_mito2->setName("NAD+");
  
  Species* nad_mito3=model->createSpecies();
  nad_mito3->setId("nad_mito3");
  nad_mito3->setCompartment(mito3->getId());
  nad_mito3->setName("NAD+");
  
  
  // NADH
  Species* nadh_cyt=model->createSpecies();
  nadh_cyt->setId("nadh_cyt");
  nadh_cyt->setName("NADH");
  nadh_cyt->setCompartment(compartment->getId());
  
  Species* nadh_mito1=model->createSpecies();
  nadh_mito1->setId("nadh_mito1");
  nadh_mito1->setCompartment(mito1->getId());
  nadh_mito1->setName("NADH");
  
  Species* nadh_mito2=model->createSpecies();
  nadh_mito2->setId("nadh_mito2");
  nadh_mito2->setCompartment(mito2->getId());
  nadh_mito2->setName("NADH");
  
  Species* nadh_mito3=model->createSpecies();
  nadh_mito3->setId("nadh_mito3");
  nadh_mito3->setCompartment(mito3->getId());
  nadh_mito3->setName("NADH");
  
  
  
  
  // create the Reactions
  
  // Cytosol
  
  // Malate Dehydrogenase
  Reaction* malatedh_cyt=model->createReaction();
  malatedh_cyt->setId("reaction_malatedh_cyt");
  malatedh_cyt->setName("malate dehydrogenase");
  malatedh_cyt->setReversible(false);
  
  SpeciesReference* sr_malate_cyt=malatedh_cyt->createReactant();
  sr_malate_cyt->setSpecies(malate_cyt->getId());
  sr_malate_cyt->setId("sr_malate_cyt");
  
  SpeciesReference* sr_nad_cyt=malatedh_cyt->createReactant();
  sr_nad_cyt->setSpecies(nad_cyt->getId());
  sr_nad_cyt->setId("sr_nad_cyt");
  
  SpeciesReference* sr_nadh_cyt=malatedh_cyt->createProduct();
  sr_nadh_cyt->setSpecies(nadh_cyt->getId());
  sr_nadh_cyt->setId("sr_nadh_cyt");
  
  SpeciesReference* sr_h_cyt=malatedh_cyt->createProduct();
  sr_h_cyt->setSpecies(h_cyt->getId());
  sr_h_cyt->setId("sr_h_cyt");
  
  SpeciesReference* sr_oxaloacetate_cyt_1=malatedh_cyt->createProduct();
  sr_oxaloacetate_cyt_1->setSpecies(oxaloacetate_cyt->getId());
  sr_oxaloacetate_cyt_1->setId("sr_oxaloacetate_cyt_1");
  
  //Aspartate Aminotransferase
  Reaction* aspartateat_cyt=model->createReaction();
  aspartateat_cyt->setId("reaction_aspartateat_cyt");
  aspartateat_cyt->setName("aspartate aminotransferase");
  aspartateat_cyt->setReversible(false);
  
  SpeciesReference* sr_oxaloacetate_cyt_2=aspartateat_cyt->createReactant();
  sr_oxaloacetate_cyt_2->setSpecies(oxaloacetate_cyt->getId());
  sr_oxaloacetate_cyt_2->setId("sr_oxaloacetate_cyt_2");
  
  SpeciesReference* sr_glutamate_cyt_1=aspartateat_cyt->createReactant();
  sr_glutamate_cyt_1->setSpecies(glutamate_cyt->getId());
  sr_glutamate_cyt_1->setId("sr_glutamate_cyt_1");
  
  SpeciesReference* sr_aspartate_cyt_1=aspartateat_cyt->createProduct();
  sr_aspartate_cyt_1->setSpecies(aspartate_cyt->getId());
  sr_aspartate_cyt_1->setId("sr_aspartate_cyt_1");
  
  SpeciesReference* sr_aKetoglutarate_cyt_1=aspartateat_cyt->createProduct();
  sr_aKetoglutarate_cyt_1->setSpecies(aKetoglutarate_cyt->getId());
  sr_aKetoglutarate_cyt_1->setId("sr_aKetoglutarate_cyt_1");
  
  
  // Mito 1
  
  // Malate Dehydrogenase
  Reaction* malatedh_mito1=model->createReaction();
  malatedh_mito1->setId("reaction_malatedh_mito1");
  malatedh_mito1->setName("malate dehydrogenase");
  malatedh_mito1->setReversible(false);
  
  SpeciesReference* sr_malate_mito1=malatedh_mito1->createReactant();
  sr_malate_mito1->setSpecies(malate_mito1->getId());
  sr_malate_mito1->setId("sr_malate_mito1");
  
  SpeciesReference* sr_nad_mito1=malatedh_mito1->createReactant();
  sr_nad_mito1->setSpecies(nad_mito1->getId());
  sr_nad_mito1->setId("sr_nad_mito1");
  
  SpeciesReference* sr_nadh_mito1=malatedh_mito1->createProduct();
  sr_nadh_mito1->setSpecies(nadh_mito1->getId());
  sr_nadh_mito1->setId("sr_nadh_mito1");
  
  SpeciesReference* sr_h_mito1=malatedh_mito1->createProduct();
  sr_h_mito1->setSpecies(h_mito1->getId());
  sr_h_mito1->setId("sr_h_mito1");
  
  SpeciesReference* sr_oxaloacetate_mito1_1=malatedh_mito1->createProduct();
  sr_oxaloacetate_mito1_1->setSpecies(oxaloacetate_mito1->getId());
  sr_oxaloacetate_mito1_1->setId("sr_oxaloacetate_mito1_1");
  
  //Aspartate Aminotransferase
  Reaction* aspartateat_mito1=model->createReaction();
  aspartateat_mito1->setId("reaction_aspartateat_mito1");
  aspartateat_mito1->setName("aspartate aminotransferase");
  aspartateat_mito1->setReversible(false);
  
  SpeciesReference* sr_oxaloacetate_mito1_2=aspartateat_mito1->createReactant();
  sr_oxaloacetate_mito1_2->setSpecies(oxaloacetate_mito1->getId());
  sr_oxaloacetate_mito1_2->setId("sr_oxaloacetate_mito1_2");
  
  SpeciesReference* sr_glutamate_mito1=aspartateat_mito1->createReactant();
  sr_glutamate_mito1->setSpecies(glutamate_mito1->getId());
  sr_glutamate_mito1->setId("sr_glutamate_mito1");
  
  SpeciesReference* sr_aspartate_mito1=aspartateat_mito1->createProduct();
  sr_aspartate_mito1->setSpecies(aspartate_mito1->getId());
  sr_aspartate_mito1->setId("sr_aspartate_mito1");
  
  SpeciesReference* sr_aKetoglutarate_mito1=aspartateat_mito1->createProduct();
  sr_aKetoglutarate_mito1->setSpecies(aKetoglutarate_mito1->getId());
  sr_aKetoglutarate_mito1->setId("sr_aKetoglutarate_mito1");
  
  
  // Mito 2
  
  // Malate Dehydrogenase
  Reaction* malatedh_mito2=model->createReaction();
  malatedh_mito2->setId("reaction_malatedh_mito2");
  malatedh_mito2->setName("malate dehydrogenase");
  malatedh_mito2->setReversible(false);
  
  SpeciesReference* sr_malate_mito2=malatedh_mito2->createReactant();
  sr_malate_mito2->setSpecies(malate_mito2->getId());
  sr_malate_mito2->setId("sr_malate_mito2");
  
  SpeciesReference* sr_nad_mito2=malatedh_mito2->createReactant();
  sr_nad_mito2->setSpecies(nad_mito2->getId());
  sr_nad_mito2->setId("sr_nad_mito2");
  
  SpeciesReference* sr_nadh_mito2=malatedh_mito2->createProduct();
  sr_nadh_mito2->setSpecies(nadh_mito2->getId());
  sr_nadh_mito2->setId("sr_nadh_mito2");
  
  SpeciesReference* sr_h_mito2=malatedh_mito2->createProduct();
  sr_h_mito2->setSpecies(h_mito2->getId());
  sr_h_mito2->setId("sr_h_mito2");
  
  SpeciesReference* sr_oxaloacetate_mito2_1=malatedh_mito2->createProduct();
  sr_oxaloacetate_mito2_1->setSpecies(oxaloacetate_mito2->getId());
  sr_oxaloacetate_mito2_1->setId("sr_oxaloacetate_mito2_1");
  
  //Aspartate Aminotransferase
  Reaction* aspartateat_mito2=model->createReaction();
  aspartateat_mito2->setId("reaction_aspartateat_mito2");
  aspartateat_mito2->setName("aspartate aminotransferase");
  aspartateat_mito2->setReversible(false);
  
  SpeciesReference* sr_oxaloacetate_mito2_2=aspartateat_mito2->createReactant();
  sr_oxaloacetate_mito2_2->setSpecies(oxaloacetate_mito2->getId());
  sr_oxaloacetate_mito2_2->setId("sr_oxaloacetate_mito2_2");
  
  SpeciesReference* sr_glutamate_mito2=aspartateat_mito2->createReactant();
  sr_glutamate_mito2->setSpecies(glutamate_mito2->getId());
  sr_glutamate_mito2->setId("sr_glutamate_mito2");
  
  SpeciesReference* sr_aspartate_mito2=aspartateat_mito2->createProduct();
  sr_aspartate_mito2->setSpecies(aspartate_mito2->getId());
  sr_aspartate_mito2->setId("sr_aspartate_mito2");
  
  SpeciesReference* sr_aKetoglutarate_mito2=aspartateat_mito2->createProduct();
  sr_aKetoglutarate_mito2->setSpecies(aKetoglutarate_mito2->getId());
  sr_aKetoglutarate_mito2->setId("sr_aKetoglutarate_mito2");
  
  
  // Mito 3
  
  // Malate Dehydrogenase
  Reaction* malatedh_mito3=model->createReaction();
  malatedh_mito3->setId("reaction_malatedh_mito3");
  malatedh_mito3->setName("malate dehydrogenase");
  malatedh_mito3->setReversible(false);
  
  SpeciesReference* sr_malate_mito3=malatedh_mito3->createReactant();
  sr_malate_mito3->setSpecies(malate_mito3->getId());
  sr_malate_mito3->setId("sr_malate_mito3");
  
  SpeciesReference* sr_nad_mito3=malatedh_mito3->createReactant();
  sr_nad_mito3->setSpecies(nad_mito3->getId());
  sr_nad_mito3->setId("sr_nad_mito3");
  
  SpeciesReference* sr_nadh_mito3=malatedh_mito3->createProduct();
  sr_nadh_mito3->setSpecies(nadh_mito3->getId());
  sr_nadh_mito3->setId("sr_nadh_mito3");
  
  SpeciesReference* sr_h_mito3=malatedh_mito3->createProduct();
  sr_h_mito3->setSpecies(h_mito3->getId());
  sr_h_mito3->setId("sr_h_mito3");
  
  SpeciesReference* sr_oxaloacetate_mito3_1=malatedh_mito3->createProduct();
  sr_oxaloacetate_mito3_1->setSpecies(oxaloacetate_mito3->getId());
  sr_oxaloacetate_mito3_1->setId("sr_oxaloacetate_mito3_1");
  
  //Aspartate Aminotransferase
  Reaction* aspartateat_mito3=model->createReaction();
  aspartateat_mito3->setId("reaction_aspartateat_mito3");
  aspartateat_mito3->setName("aspartate aminotransferase");
  aspartateat_mito3->setReversible(false);
  
  SpeciesReference* sr_oxaloacetate_mito3_2=aspartateat_mito3->createReactant();
  sr_oxaloacetate_mito3_2->setSpecies(oxaloacetate_mito3->getId());
  sr_oxaloacetate_mito3_2->setId("sr_oxaloacetate_mito3_2");
  
  
  SpeciesReference* sr_glutamate_mito3_1=aspartateat_mito3->createReactant();
  sr_glutamate_mito3_1->setSpecies(glutamate_mito3->getId());
  sr_glutamate_mito3_1->setId("sr_glutamate_mito3_1");
  
  
  SpeciesReference* sr_aspartate_mito3_1=aspartateat_mito3->createProduct();
  sr_aspartate_mito3_1->setSpecies(aspartate_mito3->getId());
  sr_aspartate_mito3_1->setId("sr_aspartate_mito3_1");
  
  
  SpeciesReference* sr_aKetoglutarate_mito3_1=aspartateat_mito3->createProduct();
  sr_aKetoglutarate_mito3_1->setSpecies(aKetoglutarate_mito3->getId());
  sr_aKetoglutarate_mito3_1->setId("sr_aKetoglutarate_mito3_1");
  
  
  // aspartate carrier
  
  Reaction* aspartateCarrier=model->createReaction();
  aspartateCarrier->setId("aspartateCarrier");
  aspartateCarrier->setName("aspartate carrier");
  aspartateCarrier->setReversible(true);
  
  SpeciesReference* sr_glutamate_mito3_2=aspartateCarrier->createReactant();
  sr_glutamate_mito3_2->setSpecies(glutamate_mito3->getId());
  sr_glutamate_mito3_2->setId("sr_glutamate_mito3_2");
  
  SpeciesReference* sr_aspartate_cyt_2=aspartateCarrier->createReactant();
  sr_aspartate_cyt_2->setSpecies(aspartate_cyt->getId());
  sr_aspartate_cyt_2->setId("sr_aspartate_cyt_2");
  
  SpeciesReference* sr_glutamate_cyt_2=aspartateCarrier->createProduct();
  sr_glutamate_cyt_2->setSpecies(glutamate_cyt->getId());
  sr_glutamate_cyt_2->setId("sr_glutamate_cyt_2");
  
  SpeciesReference* sr_aspartate_mito3_2=aspartateCarrier->createProduct();
  sr_aspartate_mito3_2->setSpecies(aspartate_mito3->getId());
  sr_aspartate_mito3_2->setId("sr_aspartate_mito3_2");
  
  // malate carrier
  
  Reaction* malateCarrier=model->createReaction();
  malateCarrier->setId("malateCarrier");
  malateCarrier->setName("malate carrier");
  malateCarrier->setReversible(true);
  
  SpeciesReference* sr_aKetoglutarate_mito3_2=malateCarrier->createReactant();
  sr_aKetoglutarate_mito3_2->setSpecies(aKetoglutarate_mito3->getId());
  sr_aKetoglutarate_mito3_2->setId("sr_aKetoglutarate_mito3_2");
  
  SpeciesReference* sr_malate_cyt_2=malateCarrier->createReactant();
  sr_malate_cyt_2->setSpecies(malate_cyt->getId());
  sr_malate_cyt_2->setId("sr_malate_cyt_2");
  
  SpeciesReference* sr_aKetoglutarate_cyt_2=malateCarrier->createProduct();
  sr_aKetoglutarate_cyt_2->setSpecies(aKetoglutarate_cyt->getId());
  sr_aKetoglutarate_cyt_2->setId("sr_aKetoglutarate_cyt_2");
  
  SpeciesReference* sr_malate_mito3_2=malateCarrier->createProduct();
  sr_malate_mito3_2->setSpecies(malate_mito3->getId());
  sr_malate_mito3_2->setId("sr_malate_mito3_2");
  
  
  /////////// create the Layout
  
  LayoutModelPlugin* mplugin = static_cast<LayoutModelPlugin*>(model->getPlugin("layout"));
  fail_unless(mplugin != NULL);
  Layout* layout=mplugin->createLayout();
  
  layout->setId("Layout_1");
  Dimensions dim(LN,2320.0,1000.0);
  layout->setDimensions(&dim);
  
  
  // create the CompartmentGlyph
  
  CompartmentGlyph* compartmentGlyph=layout->createCompartmentGlyph();
  compartmentGlyph->setId("CompartmentGlyph_1");
  compartmentGlyph->setCompartmentId(compartment->getId());
  BoundingBox bb=BoundingBox(LN,"bb_compartment",10,10,2300,980);
  compartmentGlyph->setBoundingBox(&bb);
  
  TextGlyph* tg=layout->createTextGlyph();
  tg->setId("TextGlyph_Hepatocyte");
  tg->setOriginOfTextId(compartment->getId());
  bb=BoundingBox(LN,"bb_tg_compartment",50,870,300,72);
  tg->setBoundingBox(&bb);
  tg->setGraphicalObjectId(compartmentGlyph->getId());
  
  CompartmentGlyph* mito1Glyph=layout->createCompartmentGlyph();
  mito1Glyph->setId("Mito1_Glyph");
  mito1Glyph->setCompartmentId(mito1->getId());
  bb=BoundingBox(LN,"bb_mito1",100,100,300,100);
  mito1Glyph->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_mito1");
  tg->setOriginOfTextId(mito1->getId());
  bb=BoundingBox(LN,"bb_tg_mito1",110,110,280,72);
  tg->setBoundingBox(&bb);
  tg->setGraphicalObjectId(mito1Glyph->getId());
  
  
  CompartmentGlyph* mito2Glyph=layout->createCompartmentGlyph();
  mito2Glyph->setId("Mito2_Glyph");
  mito2Glyph->setCompartmentId(mito2->getId());
  bb=BoundingBox(LN,"bb_mito2",200,650,300,100);
  mito2Glyph->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_mito2");
  tg->setOriginOfTextId(mito2->getId());
  bb=BoundingBox(LN,"bb_tg_mito2",210,660,280,72);
  tg->setBoundingBox(&bb);
  tg->setGraphicalObjectId(mito2Glyph->getId());
  
  CompartmentGlyph* mito3Glyph_2=layout->createCompartmentGlyph();
  mito3Glyph_2->setId("Mito3_Glyph_2");
  mito3Glyph_2->setCompartmentId(mito3->getId());
  bb=BoundingBox(LN,"bb_mito3_2",1470,30,820,536);
  mito3Glyph_2->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_mito3_2");
  tg->setOriginOfTextId(mito3->getId());
  bb=BoundingBox(LN,"bb_tg_mito3_2",1475,35,200,72);
  tg->setBoundingBox(&bb);
  tg->setGraphicalObjectId(mito3Glyph_2->getId());
  
  
  
  
  // create the SpeciesGlyphs
  
  // Cytosol
  
  // Malate cyt
  SpeciesGlyph* speciesGlyph_malate_cyt=layout->createSpeciesGlyph();
  speciesGlyph_malate_cyt->setId("SpeciesGlyph_malate_cyt");
  speciesGlyph_malate_cyt->setSpeciesId(malate_cyt->getId());
  bb=BoundingBox(LN,"bb_sg_malate_cyt",580,280,240,36);
  speciesGlyph_malate_cyt->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_malate_cyt");
  bb=BoundingBox(LN,"bb_tg_malatate_cyt",590,280,220,36);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(malate_cyt->getId());
  tg->setGraphicalObjectId(speciesGlyph_malate_cyt->getId());
  
  // Oxaloacetate cyt
  SpeciesGlyph* speciesGlyph_oxaloacetate_cyt=layout->createSpeciesGlyph();
  speciesGlyph_oxaloacetate_cyt->setId("SpeciesGlyph_oxaloacetate_cyt");
  speciesGlyph_oxaloacetate_cyt->setSpeciesId(oxaloacetate_cyt->getId());
  bb=BoundingBox(LN,"bb_sg_oxaloacetate_cyt",580,480,240,36);
  speciesGlyph_oxaloacetate_cyt->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_oxaloacetate_cyt");
  bb=BoundingBox(LN,"bb_tg_oxaloacetate_cyt",590,480,220,36);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(oxaloacetate_cyt->getId());
  tg->setGraphicalObjectId(speciesGlyph_oxaloacetate_cyt->getId());
  
  // Aspartate cyt
  SpeciesGlyph* speciesGlyph_aspartate_cyt=layout->createSpeciesGlyph();
  speciesGlyph_aspartate_cyt->setId("SpeciesGlyph_aspartate_cyt");
  speciesGlyph_aspartate_cyt->setSpeciesId(aspartate_cyt->getId());
  bb=BoundingBox(LN,"bb_sg_aspartate_cyt",580,680,240,36);
  speciesGlyph_aspartate_cyt->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_aspartate_cyt");
  bb=BoundingBox(LN,"bb_tg_aspartate_cyt",590,680,220,36);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(aspartate_cyt->getId());
  tg->setGraphicalObjectId(speciesGlyph_aspartate_cyt->getId());
  
  // Glutamate cyt
  SpeciesGlyph* speciesGlyph_glutamate_cyt=layout->createSpeciesGlyph();
  speciesGlyph_glutamate_cyt->setId("SpeciesGlyph_glutamate_cyt");
  speciesGlyph_glutamate_cyt->setSpeciesId(glutamate_cyt->getId());
  bb=BoundingBox(LN,"bb_sg_glutamate_cyt",800,610,240,36);
  speciesGlyph_glutamate_cyt->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_glutamate_cyt");
  bb=BoundingBox(LN,"bb_tg_glutamate_cyt",810,610,220,36);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(glutamate_cyt->getId());
  tg->setGraphicalObjectId(speciesGlyph_glutamate_cyt->getId());
  
  // alpha-Ketoglutarate cyt
  SpeciesGlyph* speciesGlyph_aKetoglutarate_cyt=layout->createSpeciesGlyph();
  speciesGlyph_aKetoglutarate_cyt->setId("SpeciesGlyph_aKetoglutarate_cyt");
  speciesGlyph_aKetoglutarate_cyt->setSpeciesId(aKetoglutarate_cyt->getId());
  bb=BoundingBox(LN,"bb_sg_aKetoglutarate_cyt",860,500,280,36);
  speciesGlyph_aKetoglutarate_cyt->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_aKetoglutarate_cyt");
  bb=BoundingBox(LN,"bb_tg_aKetoglutarate_cyt",870,500,260,36);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(aKetoglutarate_cyt->getId());
  tg->setGraphicalObjectId(speciesGlyph_aKetoglutarate_cyt->getId());
  
  // NAD+ cyt
  SpeciesGlyph* speciesGlyph_nad_cyt=layout->createSpeciesGlyph();
  speciesGlyph_nad_cyt->setId("SpeciesGlyph_nad_cyt");
  speciesGlyph_nad_cyt->setSpeciesId(nad_cyt->getId());
  bb=BoundingBox(LN,"bb_sg_nad_cyt",520,350,100,24);
  speciesGlyph_nad_cyt->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_nad_cyt");
  bb=BoundingBox(LN,"bb_tg_nad_cyt",525,350,80,24);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(nad_cyt->getId());
  tg->setGraphicalObjectId(speciesGlyph_nad_cyt->getId());
  
  // NADH cyt
  SpeciesGlyph* speciesGlyph_nadh_cyt=layout->createSpeciesGlyph();
  speciesGlyph_nadh_cyt->setId("SpeciesGlyph_nadh_cyt");
  speciesGlyph_nadh_cyt->setSpeciesId(nadh_cyt->getId());
  bb=BoundingBox(LN,"bb_sg_nadh_cyt",520,430,100,24);
  speciesGlyph_nadh_cyt->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_nadh_cyt");
  bb=BoundingBox(LN,"bb_tg_nadh_cyt",525,430,80,24);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(nadh_cyt->getId());
  tg->setGraphicalObjectId(speciesGlyph_nadh_cyt->getId());
  
  // H+ cyt
  SpeciesGlyph* speciesGlyph_h_cyt=layout->createSpeciesGlyph();
  speciesGlyph_h_cyt->setId("SpeciesGlyph_h_cyt");
  speciesGlyph_h_cyt->setSpeciesId(h_cyt->getId());
  bb=BoundingBox(LN,"bb_sg_h_cyt",430,430,40,24);
  speciesGlyph_h_cyt->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_h_cyt");
  bb=BoundingBox(LN,"bb_tg_h_cyt",435,430,30,24);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(h_cyt->getId());
  tg->setGraphicalObjectId(speciesGlyph_h_cyt->getId());
  
  
  // create the ReactionGlyphs
  
  ReactionGlyph* rg_malatedh_cyt=layout->createReactionGlyph();
  rg_malatedh_cyt->setId("rg_malatedh_cyt");
  rg_malatedh_cyt->setReactionId(malatedh_cyt->getId());
  
  Curve* curve=rg_malatedh_cyt->getCurve();
  LineSegment* ls=curve->createLineSegment();
  Point p(LN,700,381);
  ls->setStart(&p);
  p=Point(LN,700,415);
  ls->setEnd(&p);
  
  tg=layout->createTextGlyph();
  tg->setId("tg_rg_malaltedh_cyt");
  bb=BoundingBox(LN,"bb_tg_rg_malaltedh_cyt",700,385,210,24);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(malatedh_cyt->getId());
  tg->setGraphicalObjectId(rg_malatedh_cyt->getId());
  
  
  ReactionGlyph* rg_aspartateat_cyt=layout->createReactionGlyph();
  rg_aspartateat_cyt->setId("rg_aspartateat_cyt");
  rg_aspartateat_cyt->setReactionId(aspartateat_cyt->getId());
  
  curve=rg_aspartateat_cyt->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,700,581);
  ls->setStart(&p);
  p=Point(LN,700,615);
  ls->setEnd(&p);
  
  tg=layout->createTextGlyph();
  tg->setId("tg_rg_aspartateat_cyt");
  bb=BoundingBox(LN,"bb_tg_rg_aspartateat_cyt",440,585,260,24);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(aspartateat_cyt->getId());
  tg->setGraphicalObjectId(rg_aspartateat_cyt->getId());
  
  
  
  // add the SpeciesReferenceGlyphs
  
  SpeciesReferenceGlyph* srg_malate_cyt_1=rg_malatedh_cyt->createSpeciesReferenceGlyph();
  srg_malate_cyt_1->setId("srg_malate_cyt_1");
  srg_malate_cyt_1->setSpeciesGlyphId(speciesGlyph_malate_cyt->getId());
  srg_malate_cyt_1->setSpeciesReferenceId(sr_malate_cyt->getId());
  srg_malate_cyt_1->setRole(SPECIES_ROLE_SUBSTRATE);
  
  ls=srg_malate_cyt_1->createLineSegment();
  p=Point(LN,700,381);
  ls->setStart(&p);
  p=Point(LN,700,316);
  ls->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_nad_cyt=rg_malatedh_cyt->createSpeciesReferenceGlyph();
  srg_nad_cyt->setId("srg_nad_cyt");
  srg_nad_cyt->setSpeciesGlyphId(speciesGlyph_nad_cyt->getId());
  srg_nad_cyt->setSpeciesReferenceId(sr_nad_cyt->getId());
  srg_nad_cyt->setRole(SPECIES_ROLE_SUBSTRATE);
  
  CubicBezier* cb=srg_nad_cyt->createCubicBezier();
  p=Point(LN,700,381);
  cb->setStart(&p);
  p=Point(LN,700,362);
  cb->setBasePoint1(&p);
  p=Point(LN,700,362);
  cb->setBasePoint2(&p);
  p=Point(LN,620,362);
  cb->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_oxaloacetate_cyt_1=rg_malatedh_cyt->createSpeciesReferenceGlyph();
  srg_oxaloacetate_cyt_1->setId("srg_oxaloacetate_cyt_1");
  srg_oxaloacetate_cyt_1->setSpeciesGlyphId(speciesGlyph_oxaloacetate_cyt->getId());
  srg_oxaloacetate_cyt_1->setSpeciesReferenceId(sr_oxaloacetate_cyt_1->getId());
  srg_oxaloacetate_cyt_1->setRole(SPECIES_ROLE_PRODUCT);
  
  curve=srg_oxaloacetate_cyt_1->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,700,415);
  ls->setStart(&p);
  p=Point(LN,700,480);
  ls->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_nadh_cyt=rg_malatedh_cyt->createSpeciesReferenceGlyph();
  srg_nadh_cyt->setId("srg_nadh_cyt");
  srg_nadh_cyt->setSpeciesGlyphId(speciesGlyph_nadh_cyt->getId());
  srg_nadh_cyt->setSpeciesReferenceId(sr_nadh_cyt->getId());
  srg_nadh_cyt->setRole(SPECIES_ROLE_PRODUCT);
  
  cb=srg_nadh_cyt->createCubicBezier();
  p=Point(LN,700,415);
  cb->setStart(&p);
  p=Point(LN,700,442);
  cb->setBasePoint1(&p);
  p=Point(LN,700,442);
  cb->setBasePoint2(&p);
  p=Point(LN,620,442);
  cb->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_h_cyt=rg_malatedh_cyt->createSpeciesReferenceGlyph();
  srg_h_cyt->setId("srg_h_cyt");
  srg_h_cyt->setSpeciesGlyphId(speciesGlyph_h_cyt->getId());
  srg_h_cyt->setSpeciesReferenceId(sr_h_cyt->getId());
  srg_h_cyt->setRole(SPECIES_ROLE_PRODUCT);
  
  cb=srg_h_cyt->createCubicBezier();
  p=Point(LN,700,415);
  cb->setStart(&p);
  p=Point(LN,570,415);
  cb->setBasePoint1(&p);
  p=Point(LN,570,415);
  cb->setBasePoint2(&p);
  p=Point(LN,470,430);
  cb->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_oxaloacetate_cyt_2=rg_aspartateat_cyt->createSpeciesReferenceGlyph();
  srg_oxaloacetate_cyt_2->setId("srg_oxaloacetate_cyt_2");
  srg_oxaloacetate_cyt_2->setSpeciesGlyphId(speciesGlyph_oxaloacetate_cyt->getId());
  srg_oxaloacetate_cyt_2->setSpeciesReferenceId(sr_oxaloacetate_cyt_2->getId());
  srg_oxaloacetate_cyt_2->setRole(SPECIES_ROLE_SUBSTRATE);
  
  curve=srg_oxaloacetate_cyt_2->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,700,581);
  ls->setStart(&p);
  p=Point(LN,700,516);
  ls->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_glutamate_cyt_1=rg_aspartateat_cyt->createSpeciesReferenceGlyph();
  srg_glutamate_cyt_1->setId("srg_glutamate_cyt_1");
  srg_glutamate_cyt_1->setSpeciesGlyphId(speciesGlyph_glutamate_cyt->getId());
  srg_glutamate_cyt_1->setSpeciesReferenceId(sr_glutamate_cyt_1->getId());
  srg_glutamate_cyt_1->setRole(SPECIES_ROLE_SUBSTRATE);
  
  curve=srg_glutamate_cyt_1->getCurve();
  cb=curve->createCubicBezier();
  p=Point(LN,700,581);
  cb->setStart(&p);
  p=Point(LN,750,581);
  cb->setBasePoint1(&p);
  p=Point(LN,750,628);
  cb->setBasePoint2(&p);
  p=Point(LN,800,628);
  cb->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_aspartate_cyt_1=rg_aspartateat_cyt->createSpeciesReferenceGlyph();
  srg_aspartate_cyt_1->setId("srg_aspartate_cyt_1");
  srg_aspartate_cyt_1->setSpeciesGlyphId(speciesGlyph_aspartate_cyt->getId());
  srg_aspartate_cyt_1->setSpeciesReferenceId(sr_aspartate_cyt_1->getId());
  srg_aspartate_cyt_1->setRole(SPECIES_ROLE_PRODUCT);
  
  curve=srg_aspartate_cyt_1->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,700,615);
  ls->setStart(&p);
  p=Point(LN,700,680);
  ls->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_aKetoglutarate_cyt_1=rg_aspartateat_cyt->createSpeciesReferenceGlyph();
  srg_aKetoglutarate_cyt_1->setId("srg_aKetoglutaratecyt_1");
  srg_aKetoglutarate_cyt_1->setSpeciesGlyphId(speciesGlyph_aKetoglutarate_cyt->getId());
  srg_aKetoglutarate_cyt_1->setSpeciesReferenceId(sr_aKetoglutarate_cyt_1->getId());
  srg_aKetoglutarate_cyt_1->setRole(SPECIES_ROLE_PRODUCT);
  
  curve=srg_aKetoglutarate_cyt_1->getCurve();
  cb=curve->createCubicBezier();
  p=Point(LN,700,615);
  cb->setStart(&p);
  p=Point(LN,790,615);
  cb->setBasePoint1(&p);
  p=Point(LN,790,515);
  cb->setBasePoint2(&p);
  p=Point(LN,860,515);
  cb->setEnd(&p);
  
  
  // Malate mito3
  SpeciesGlyph* speciesGlyph_malate_mito3=layout->createSpeciesGlyph();
  speciesGlyph_malate_mito3->setId("SpeciesGlyph_malate_mito3");
  speciesGlyph_malate_mito3->setSpeciesId(malate_mito3->getId());
  bb=BoundingBox(LN,"bb_sg_malate_mito3",1850,80,240,36);
  speciesGlyph_malate_mito3->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_malate_mito3");
  bb=BoundingBox(LN,"bb_tg_malatate_mito3",1860,80,220,36);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(malate_mito3->getId());
  tg->setGraphicalObjectId(speciesGlyph_malate_mito3->getId());
  
  // Oxaloacetate mito3
  SpeciesGlyph* speciesGlyph_oxaloacetate_mito3=layout->createSpeciesGlyph();
  speciesGlyph_oxaloacetate_mito3->setId("SpeciesGlyph_oxaloacetate_mito3");
  speciesGlyph_oxaloacetate_mito3->setSpeciesId(oxaloacetate_mito3->getId());
  bb=BoundingBox(LN,"bb_sg_oxaloacetate_mito3",1850,280,240,36);
  speciesGlyph_oxaloacetate_mito3->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_oxaloacetate_mito3");
  bb=BoundingBox(LN,"bb_tg_oxaloacetate_mito3",1860,280,220,36);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(oxaloacetate_mito3->getId());
  tg->setGraphicalObjectId(speciesGlyph_oxaloacetate_mito3->getId());
  
  // Aspartate mito3
  SpeciesGlyph* speciesGlyph_aspartate_mito3=layout->createSpeciesGlyph();
  speciesGlyph_aspartate_mito3->setId("SpeciesGlyph_aspartate_mito3");
  speciesGlyph_aspartate_mito3->setSpeciesId(aspartate_mito3->getId());
  bb=BoundingBox(LN,"bb_sg_aspartate_mito3",1850,480,240,36);
  speciesGlyph_aspartate_mito3->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_aspartate_mito3");
  bb=BoundingBox(LN,"bb_tg_aspartate_mito3",1860,480,220,36);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(aspartate_mito3->getId());
  tg->setGraphicalObjectId(speciesGlyph_aspartate_mito3->getId());
  
  // Glutamate mito3
  SpeciesGlyph* speciesGlyph_glutamate_mito3=layout->createSpeciesGlyph();
  speciesGlyph_glutamate_mito3->setId("SpeciesGlyph_glutamate_mito3");
  speciesGlyph_glutamate_mito3->setSpeciesId(glutamate_mito3->getId());
  bb=BoundingBox(LN,"bb_sg_glutamate_mito3",1550,430,240,36);
  speciesGlyph_glutamate_mito3->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_glutamate_mito3");
  bb=BoundingBox(LN,"bb_tg_glutamate_mito3",1560,430,220,36);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(glutamate_mito3->getId());
  tg->setGraphicalObjectId(speciesGlyph_glutamate_mito3->getId());
  
  // alpha-Ketoglutarate mito3
  SpeciesGlyph* speciesGlyph_aKetoglutarate_mito3=layout->createSpeciesGlyph();
  speciesGlyph_aKetoglutarate_mito3->setId("SpeciesGlyph_aKetoglutarate_mito3");
  speciesGlyph_aKetoglutarate_mito3->setSpeciesId(aKetoglutarate_mito3->getId());
  bb=BoundingBox(LN,"bb_sg_aKetoglutarate_mito3",1530,300,280,36);
  speciesGlyph_aKetoglutarate_mito3->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_aKetoglutarate_mito3");
  bb=BoundingBox(LN,"bb_tg_aKetoglutarate_mito3",1540,300,260,36);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(aKetoglutarate_mito3->getId());
  tg->setGraphicalObjectId(speciesGlyph_aKetoglutarate_mito3->getId());
  
  // NAD+ mito3
  SpeciesGlyph* speciesGlyph_nad_mito3=layout->createSpeciesGlyph();
  speciesGlyph_nad_mito3->setId("SpeciesGlyph_nad_mito3");
  speciesGlyph_nad_mito3->setSpeciesId(nad_mito3->getId());
  bb=BoundingBox(LN,"bb_sg_nad_mito3",2050,150,100,24);
  speciesGlyph_nad_mito3->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_nad_mito3");
  bb=BoundingBox(LN,"bb_tg_nad_mito3",2055,150,80,24);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(nad_mito3->getId());
  tg->setGraphicalObjectId(speciesGlyph_nad_mito3->getId());
  
  // NADH mito3
  SpeciesGlyph* speciesGlyph_nadh_mito3=layout->createSpeciesGlyph();
  speciesGlyph_nadh_mito3->setId("SpeciesGlyph_nadh_mito3");
  speciesGlyph_nadh_mito3->setSpeciesId(nadh_mito3->getId());
  bb=BoundingBox(LN,"bb_sg_nadh_mito3",2050,230,100,24);
  speciesGlyph_nadh_mito3->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_nadh_mito3");
  bb=BoundingBox(LN,"bb_tg_nadh_mito3",2055,230,80,24);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(nadh_mito3->getId());
  tg->setGraphicalObjectId(speciesGlyph_nadh_mito3->getId());
  
  // H+ mito3
  SpeciesGlyph* speciesGlyph_h_mito3=layout->createSpeciesGlyph();
  speciesGlyph_h_mito3->setId("SpeciesGlyph_h_mito3");
  speciesGlyph_h_mito3->setSpeciesId(h_mito3->getId());
  bb=BoundingBox(LN,"bb_sg_h_mito3",2200,230,40,24);
  speciesGlyph_h_mito3->setBoundingBox(&bb);
  
  tg=layout->createTextGlyph();
  tg->setId("TextGlyph_h_mito3");
  bb=BoundingBox(LN,"bb_tg_h_mito3",2205,230,30,24);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(h_mito3->getId());
  tg->setGraphicalObjectId(speciesGlyph_h_mito3->getId());
  
  
  // create the ReactionGlyphs
  
  ReactionGlyph* rg_malatedh_mito3=layout->createReactionGlyph();
  rg_malatedh_mito3->setId("rg_malatedh_mito3");
  rg_malatedh_mito3->setReactionId(malatedh_mito3->getId());
  
  curve=rg_malatedh_mito3->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,1970,181);
  ls->setStart(&p);
  p=Point(LN,1970,215);
  ls->setEnd(&p);
  
  tg=layout->createTextGlyph();
  tg->setId("tg_rg_malatedh_mito3");
  bb=BoundingBox(LN,"bb_tg_rg_malatedh_mito3",1740,185,220,24);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(malatedh_mito3->getId());
  tg->setGraphicalObjectId(rg_malatedh_mito3->getId());
  
  ReactionGlyph* rg_aspartateat_mito3=layout->createReactionGlyph();
  rg_aspartateat_mito3->setId("rg_aspartateat_mito3");
  rg_aspartateat_mito3->setReactionId(aspartateat_mito3->getId());
  
  curve=rg_aspartateat_mito3->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,1970,381);
  ls->setStart(&p);
  p=Point(LN,1970,415);
  ls->setEnd(&p);
  
  tg=layout->createTextGlyph();
  tg->setId("tg_rg_aspartateat_mito3");
  bb=BoundingBox(LN,"bb_tg_rg_aspartateat_mito3",1970,385,260,24);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(aspartateat_mito3->getId());
  tg->setGraphicalObjectId(rg_aspartateat_mito3->getId());
  
  
  // add the SpeciesReferenceGlyphs
  
  SpeciesReferenceGlyph* srg_malate_mito3_1=rg_malatedh_mito3->createSpeciesReferenceGlyph();
  srg_malate_mito3_1->setId("srg_malate_mito3_1");
  srg_malate_mito3_1->setSpeciesGlyphId(speciesGlyph_malate_mito3->getId());
  srg_malate_mito3_1->setSpeciesReferenceId(sr_malate_mito3->getId());
  srg_malate_mito3_1->setRole(SPECIES_ROLE_SUBSTRATE);
  
  ls=srg_malate_mito3_1->createLineSegment();
  p=Point(LN,1970,181);
  ls->setStart(&p);
  p=Point(LN,1970,116);
  ls->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_nad_mito3=rg_malatedh_mito3->createSpeciesReferenceGlyph();
  srg_nad_mito3->setId("srg_nad_mito3");
  srg_nad_mito3->setSpeciesGlyphId(speciesGlyph_nad_mito3->getId());
  srg_nad_mito3->setSpeciesReferenceId(sr_nad_mito3->getId());
  srg_nad_mito3->setRole(SPECIES_ROLE_SUBSTRATE);
  
  cb=srg_nad_mito3->createCubicBezier();
  p=Point(LN,1970,181);
  cb->setStart(&p);
  p=Point(LN,1970,162);
  cb->setBasePoint1(&p);
  p=Point(LN,1970,162);
  cb->setBasePoint2(&p);
  p=Point(LN,2050,162);
  cb->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_oxaloacetate_mito3_1=rg_malatedh_mito3->createSpeciesReferenceGlyph();
  srg_oxaloacetate_mito3_1->setId("srg_oxaloacetate_mito3_1");
  srg_oxaloacetate_mito3_1->setSpeciesGlyphId(speciesGlyph_oxaloacetate_mito3->getId());
  srg_oxaloacetate_mito3_1->setSpeciesReferenceId(sr_oxaloacetate_mito3_1->getId());
  srg_oxaloacetate_mito3_1->setRole(SPECIES_ROLE_PRODUCT);
  
  curve=srg_oxaloacetate_mito3_1->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,1970,215);
  ls->setStart(&p);
  p=Point(LN,1970,280);
  ls->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_nadh_mito3=rg_malatedh_mito3->createSpeciesReferenceGlyph();
  srg_nadh_mito3->setId("srg_nadh_mito3");
  srg_nadh_mito3->setSpeciesGlyphId(speciesGlyph_nadh_mito3->getId());
  srg_nadh_mito3->setSpeciesReferenceId(sr_nadh_mito3->getId());
  srg_nadh_mito3->setRole(SPECIES_ROLE_PRODUCT);
  
  cb=srg_nadh_mito3->createCubicBezier();
  p=Point(LN,1970,215);
  cb->setStart(&p);
  p=Point(LN,1970,242);
  cb->setBasePoint1(&p);
  p=Point(LN,1970,242);
  cb->setBasePoint2(&p);
  p=Point(LN,2050,242);
  cb->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_h_mito3=rg_malatedh_mito3->createSpeciesReferenceGlyph();
  srg_h_mito3->setId("srg_h_mito3");
  srg_h_mito3->setSpeciesGlyphId(speciesGlyph_h_mito3->getId());
  srg_h_mito3->setSpeciesReferenceId(sr_h_mito3->getId());
  srg_h_mito3->setRole(SPECIES_ROLE_PRODUCT);
  
  cb=srg_h_mito3->createCubicBezier();
  p=Point(LN,1970,215);
  cb->setStart(&p);
  p=Point(LN,2100,215);
  cb->setBasePoint1(&p);
  p=Point(LN,2100,215);
  cb->setBasePoint2(&p);
  p=Point(LN,2200,230);
  cb->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_oxaloacetate_mito3_2=rg_aspartateat_mito3->createSpeciesReferenceGlyph();
  srg_oxaloacetate_mito3_2->setId("srg_oxaloacetate_mito3_2");
  srg_oxaloacetate_mito3_2->setSpeciesGlyphId(speciesGlyph_oxaloacetate_mito3->getId());
  srg_oxaloacetate_mito3_2->setSpeciesReferenceId(sr_oxaloacetate_mito3_2->getId());
  srg_oxaloacetate_mito3_2->setRole(SPECIES_ROLE_SUBSTRATE);
  
  curve=srg_oxaloacetate_mito3_2->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,1970,381);
  ls->setStart(&p);
  p=Point(LN,1970,316);
  ls->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_glutamate_mito3_1=rg_aspartateat_mito3->createSpeciesReferenceGlyph();
  srg_glutamate_mito3_1->setId("srg_glutamate_mito3_1");
  srg_glutamate_mito3_1->setSpeciesGlyphId(speciesGlyph_glutamate_mito3->getId());
  srg_glutamate_mito3_1->setSpeciesReferenceId(sr_glutamate_mito3_1->getId());
  srg_glutamate_mito3_1->setRole(SPECIES_ROLE_SUBSTRATE);
  
  curve=srg_glutamate_mito3_1->getCurve();
  cb=curve->createCubicBezier();
  p=Point(LN,1970,381);
  cb->setStart(&p);
  p=Point(LN,1880,381);
  cb->setBasePoint1(&p);
  p=Point(LN,1880,448);
  cb->setBasePoint2(&p);
  p=Point(LN,1790,448);
  cb->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_aspartate_mito3_1=rg_aspartateat_mito3->createSpeciesReferenceGlyph();
  srg_aspartate_mito3_1->setId("srg_aspartate_mito3_1");
  srg_aspartate_mito3_1->setSpeciesGlyphId(speciesGlyph_aspartate_mito3->getId());
  srg_aspartate_mito3_1->setSpeciesReferenceId(sr_aspartate_mito3_1->getId());
  srg_aspartate_mito3_1->setRole(SPECIES_ROLE_PRODUCT);
  
  curve=srg_aspartate_mito3_1->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,1970,415);
  ls->setStart(&p);
  p=Point(LN,1970,480);
  ls->setEnd(&p);
  
  SpeciesReferenceGlyph* srg_aKetoglutarate_mito3_1=rg_aspartateat_mito3->createSpeciesReferenceGlyph();
  srg_aKetoglutarate_mito3_1->setId("srg_aKetoglutaratemito3_1");
  srg_aKetoglutarate_mito3_1->setSpeciesGlyphId(speciesGlyph_aKetoglutarate_mito3->getId());
  srg_aKetoglutarate_mito3_1->setSpeciesReferenceId(sr_aKetoglutarate_mito3_1->getId());
  srg_aKetoglutarate_mito3_1->setRole(SPECIES_ROLE_PRODUCT);
  
  curve=srg_aKetoglutarate_mito3_1->getCurve();
  cb=curve->createCubicBezier();
  p=Point(LN,1970,415);
  cb->setStart(&p);
  p=Point(LN,1880,415);
  cb->setBasePoint1(&p);
  p=Point(LN,1880,315);
  cb->setBasePoint2(&p);
  p=Point(LN,1810,315);
  cb->setEnd(&p);
  
  // add the transport reaction glyphs
  
  ReactionGlyph* rg_aspartateCarrier=layout->createReactionGlyph();
  rg_aspartateCarrier->setId("rg_aspartateCarrier");
  rg_aspartateCarrier->setReactionId(aspartateCarrier->getId());
  
  curve=rg_aspartateCarrier->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,1420,530);
  ls->setStart(&p);
  p=Point(LN,1360,550);
  ls->setEnd(&p);
  
  tg=layout->createTextGlyph();
  tg->setId("tg_rg_aspartateCarrier");
  bb=BoundingBox(LN,"bb_tg_rg_aspartateCarrier",1380,500,160,24);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(aspartateCarrier->getId());
  tg->setGraphicalObjectId(rg_aspartateCarrier->getId());
  
  
  ReactionGlyph* rg_malateCarrier=layout->createReactionGlyph();
  rg_malateCarrier->setId("rg_malateCarrier");
  rg_malateCarrier->setReactionId(malateCarrier->getId());
  
  curve=rg_malateCarrier->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,1420,320);
  ls->setStart(&p);
  p=Point(LN,1360,340);
  ls->setEnd(&p);
  
  tg=layout->createTextGlyph();
  tg->setId("tg_rg_malateCarrier");
  bb=BoundingBox(LN,"bb_tg_rg_malateCarrier",1360,330,140,24);
  tg->setBoundingBox(&bb);
  tg->setOriginOfTextId(malateCarrier->getId());
  tg->setGraphicalObjectId(rg_malateCarrier->getId());
  
  
  
  // add the SpeciesReferenceGlyphs for the transporters
  
  SpeciesReferenceGlyph* srg_aKetoglutarate_mito3_2=rg_malateCarrier->createSpeciesReferenceGlyph();
  srg_aKetoglutarate_mito3_2->setId("srg_aKetoglutarate_mito3_2");
  srg_aKetoglutarate_mito3_2->setSpeciesGlyphId(speciesGlyph_aKetoglutarate_mito3->getId());
  srg_aKetoglutarate_mito3_2->setSpeciesReferenceId(sr_aKetoglutarate_mito3_2->getId());
  srg_aKetoglutarate_mito3_2->setRole(SPECIES_ROLE_SUBSTRATE);
  
  curve=srg_aKetoglutarate_mito3_2->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,1420,320);
  ls->setStart(&p);
  p=Point(LN,1530,318);
  ls->setEnd(&p);
  
  
  SpeciesReferenceGlyph* srg_aKetoglutarate_cyt_2=rg_malateCarrier->createSpeciesReferenceGlyph();
  srg_aKetoglutarate_cyt_2->setId("srg_aKetoglutarate_cyt_2");
  srg_aKetoglutarate_cyt_2->setSpeciesGlyphId(speciesGlyph_aKetoglutarate_cyt->getId());
  srg_aKetoglutarate_cyt_2->setSpeciesReferenceId(sr_aKetoglutarate_cyt_2->getId());
  srg_aKetoglutarate_cyt_2->setRole(SPECIES_ROLE_PRODUCT);
  
  curve=srg_aKetoglutarate_cyt_2->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,1360,340);
  ls->setStart(&p);
  p=Point(LN,1140,518);
  ls->setEnd(&p);
  
  
  SpeciesReferenceGlyph* srg_malate_cyt_2=rg_malateCarrier->createSpeciesReferenceGlyph();
  srg_malate_cyt_2->setId("srg_malate_cyt_2");
  srg_malate_cyt_2->setSpeciesGlyphId(speciesGlyph_malate_cyt->getId());
  srg_malate_cyt_2->setSpeciesReferenceId(sr_malate_cyt_2->getId());
  srg_malate_cyt_2->setRole(SPECIES_ROLE_SUBSTRATE);
  
  curve=srg_malate_cyt_2->getCurve();
  cb=curve->createCubicBezier();
  p=Point(LN,1420,320);
  cb->setStart(&p);
  p=Point(LN,1390,250);
  cb->setBasePoint1(&p);
  p=Point(LN,1390,250);
  cb->setBasePoint2(&p);
  p=Point(LN,820,298);
  cb->setEnd(&p);
  
  
  SpeciesReferenceGlyph* srg_malate_mito3_2=rg_malateCarrier->createSpeciesReferenceGlyph();
  srg_malate_mito3_2->setId("srg_malate_mito3_2");
  srg_malate_mito3_2->setSpeciesGlyphId(speciesGlyph_malate_mito3->getId());
  srg_malate_mito3_2->setSpeciesReferenceId(sr_malate_mito3_2->getId());
  srg_malate_mito3_2->setRole(SPECIES_ROLE_PRODUCT);
  
  curve=srg_malate_mito3_2->getCurve();
  cb=curve->createCubicBezier();
  p=Point(LN,1360,340);
  cb->setStart(&p);
  p=Point(LN,1390,150);
  cb->setBasePoint1(&p);
  p=Point(LN,1390,150);
  cb->setBasePoint2(&p);
  p=Point(LN,1850,98);
  cb->setEnd(&p);
  
  
  
  
  
  
  SpeciesReferenceGlyph* srg_aspartate_mito3_2=rg_aspartateCarrier->createSpeciesReferenceGlyph();
  srg_aspartate_mito3_2->setId("srg_aspartate_mito3_2");
  srg_aspartate_mito3_2->setSpeciesGlyphId(speciesGlyph_aspartate_mito3->getId());
  srg_aspartate_mito3_2->setSpeciesReferenceId(sr_aspartate_mito3_2->getId());
  srg_aspartate_mito3_2->setRole(SPECIES_ROLE_SUBSTRATE);
  
  curve=srg_aspartate_mito3_2->getCurve();
  ls=curve->createLineSegment();
  p=Point(LN,1420,530);
  ls->setStart(&p);
  p=Point(LN,1850,498);
  ls->setEnd(&p);
  
  
  SpeciesReferenceGlyph* srg_aspartate_cyt_2=rg_aspartateCarrier->createSpeciesReferenceGlyph();
  srg_aspartate_cyt_2->setId("srg_aspartate_cyt_2");
  srg_aspartate_cyt_2->setSpeciesGlyphId(speciesGlyph_aspartate_cyt->getId());
  srg_aspartate_cyt_2->setSpeciesReferenceId(sr_aspartate_cyt_2->getId());
  srg_aspartate_cyt_2->setRole(SPECIES_ROLE_PRODUCT);
  
  curve=srg_aspartate_cyt_2->getCurve();
  cb=curve->createCubicBezier();
  p=Point(LN,1360,550);
  cb->setStart(&p);
  p=Point(LN,1390,698);
  cb->setBasePoint1(&p);
  p=Point(LN,1390,698);
  cb->setBasePoint2(&p);
  p=Point(LN,820,698);
  cb->setEnd(&p);
  
  
  SpeciesReferenceGlyph* srg_glutamate_cyt_2=rg_aspartateCarrier->createSpeciesReferenceGlyph();
  srg_glutamate_cyt_2->setId("srg_glutamate_cyt_2");
  srg_glutamate_cyt_2->setSpeciesGlyphId(speciesGlyph_glutamate_cyt->getId());
  srg_glutamate_cyt_2->setSpeciesReferenceId(sr_glutamate_cyt_2->getId());
  srg_glutamate_cyt_2->setRole(SPECIES_ROLE_SUBSTRATE);
  
  curve=srg_glutamate_cyt_2->getCurve();
  cb=curve->createCubicBezier();
  p=Point(LN,1420,530);
  cb->setStart(&p);
  p=Point(LN,1390,648);
  cb->setBasePoint1(&p);
  p=Point(LN,1390,648);
  cb->setBasePoint2(&p);
  p=Point(LN,1050,628);
  cb->setEnd(&p);
  
  
  SpeciesReferenceGlyph* srg_glutamate_mito3_2=rg_aspartateCarrier->createSpeciesReferenceGlyph();
  srg_glutamate_mito3_2->setId("srg_glutamate_mito3_2");
  srg_glutamate_mito3_2->setSpeciesGlyphId(speciesGlyph_glutamate_mito3->getId());
  srg_glutamate_mito3_2->setSpeciesReferenceId(sr_glutamate_mito3_2->getId());
  srg_glutamate_mito3_2->setRole(SPECIES_ROLE_PRODUCT);
  
  curve=srg_glutamate_mito3_2->getCurve();
  cb=curve->createCubicBezier();
  p=Point(LN,1360,550);
  cb->setStart(&p);
  p=Point(LN,1390,448);
  cb->setBasePoint1(&p);
  p=Point(LN,1390,448);
  cb->setBasePoint2(&p);
  p=Point(LN,1550,448);
  cb->setEnd(&p);
  
  fail_unless(LN != NULL);
  
  SBMLWriter writer;
  //bool result=writer.write(document,"example6.xml");
  //std::cout << "result of writing: " << result << std::endl;
  char* writtenContent=writer.writeToString(document);
  //std::cout << writtenContent << std::endl;
  
  XMLInputStream *stream2 = new XMLInputStream(writtenContent,false);
  XMLNode *node2 = new XMLNode(*stream2);
  fail_unless(node->getName()=="sbml");
  fail_unless(node->getChild("model").getName()=="model");
  fail_unless(node->getChild("model").getChild("annotation").getName()=="annotation");
  fail_unless(node->getChild("model").getChild("annotation").getChild("listOfLayouts").getName()=="listOfLayouts");
  XMLNode& listOfLayouts1 = node->getChild("model").getChild("annotation").getChild("listOfLayouts");
  fail_unless(listOfLayouts1.getName()=="listOfLayouts");
  
  fail_unless(node2->getName()=="sbml");
  fail_unless(node2->getChild("model").getName()=="model");
  fail_unless(node2->getChild("model").getChild("annotation").getName()=="annotation");
  XMLNode& listOfLayouts2= node2->getChild("model").getChild("annotation").getChild("listOfLayouts");
  fail_unless(listOfLayouts2.getName()=="listOfLayouts");
  
  // until the sbml element gets a namespace, we only compare the listOfLayouts element and all its children.
  fail_unless(listOfLayouts1.equals(listOfLayouts2));
  
  free(writtenContent);
  delete document;
  delete node;
  delete node2;
  delete stream2;
  delete stream;
}
END_TEST

START_TEST(test_LayoutWriting_multipleTimes)
{
  LayoutPkgNamespaces ns (2,1);
  SBMLDocument doc(&ns);
  int rv = doc.setPkgRequired("layout", false);
  fail_unless(rv==LIBSBML_UNEXPECTED_ATTRIBUTE);
  
  Model* model = doc.createModel();
  model->setId("test1");
  
  LayoutModelPlugin* lPlugin = (LayoutModelPlugin*) model->getPlugin("layout");
  fail_unless(lPlugin != NULL);
  
  Layout* layout = lPlugin->createLayout();
  layout->setId("layout1");
  
  // whenever getannotation is called, the layout will be synchronized
  string model1 = writeSBMLToStdString(&doc);
  
  // writing should create that annotation ...
  XMLNode* annot = model->getAnnotation();
  int numAnnotation = annot->getNumChildren();
  
  // however, writing it again should not create multiple annotation
  string model2 = writeSBMLToStdString(&doc);
  annot = model->getAnnotation();
  fail_unless(numAnnotation == (int)annot->getNumChildren());
}
END_TEST


Suite *
create_suite_LayoutWriting (void)
{
  Suite *suite = suite_create("LayoutWriting");
  TCase *tcase = tcase_create("LayoutWriting");
  
  tcase_add_checked_fixture( tcase,
                            LayoutWritingTest_setup,
                            LayoutWritingTest_teardown );
  
  tcase_add_test( tcase, test_LayoutWriting_multipleTimes              );
  tcase_add_test( tcase, test_LayoutWriting                            );
  suite_add_tcase(suite, tcase);
  
  return suite;
}



END_C_DECLS
