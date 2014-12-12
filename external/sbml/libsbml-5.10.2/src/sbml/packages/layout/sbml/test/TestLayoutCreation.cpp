/**
 * Filename    : TestLayoutCreation.cpp
 * Description : Unit tests for the creation of the layout struvtures from XMLNodes.
 * Organization: European Media Laboratories Research gGmbH
 * Created     : 2007-02-21
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

#include <sbml/packages/layout/sbml/Layout.h>
#include <sbml/packages/layout/sbml/LineSegment.h>
#include <sbml/packages/layout/sbml/CubicBezier.h>
#include <sbml/packages/layout/util/LayoutAnnotation.h>

#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLNode.h>

#include <check.h>

#include "utility.h"

using namespace std;

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static string NOTES;


static void
LayoutCreationTest_setup (void)
{
	NOTES = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<notes><body xmlns=\"http://www.w3.org/1999/xhtml\">\n <p>Testnote</p>\n</body></notes>";
}

static void
LayoutCreationTest_teardown (void)
{
}


START_TEST (test_LayoutCreation_Layout)
{
	const char* content =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\" >\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfCompartmentGlyphs>\n"
  "      <compartmentGlyph id=\"compartmentGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"0\" y=\"0\"/>\n"
  "          <dimensions width=\"0\" height=\"0\"/>\n"
  "        </boundingBox>\n"
  "      </compartmentGlyph>\n"
  "    </listOfCompartmentGlyphs>\n"
  "    <listOfSpeciesGlyphs>\n"
  "      <speciesGlyph id=\"speciesGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"0\" y=\"0\"/>\n"
  "          <dimensions width=\"0\" height=\"0\"/>\n"
  "        </boundingBox>\n"
  "      </speciesGlyph>\n"
  "    </listOfSpeciesGlyphs>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"0\" y=\"0\"/>\n"
  "          <dimensions width=\"0\" height=\"0\"/>\n"
  "        </boundingBox>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "    <listOfTextGlyphs>\n"
  "      <textGlyph id=\"textGlyph_1\" text=\"test\">\n"
  "        <boundingBox>\n"
  "          <position x=\"0\" y=\"0\"/>\n"
  "          <dimensions width=\"0\" height=\"0\"/>\n"
  "        </boundingBox>\n"
  "      </textGlyph>\n"
  "    </listOfTextGlyphs>\n"
  "    <listOfAdditionalGraphicalObjects>\n"
  "      <graphicalObject id=\"graphicalObject_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"0\" y=\"0\"/>\n"
  "          <dimensions width=\"0\" height=\"0\"/>\n"
  "        </boundingBox>\n"
  "      </graphicalObject>\n"
  "    </listOfAdditionalGraphicalObjects>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
	XMLInputStream *stream= new XMLInputStream(content,false);
	fail_unless(stream->isError() == false);
	fail_unless(stream->isGood() == true);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation( &node , *pListOfLayouts );
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getNumCompartmentGlyphs()==1);
	CompartmentGlyph* cg=l->getCompartmentGlyph(0);
	fail_unless(cg!=NULL);
	fail_unless(cg->getId()=="compartmentGlyph_1");
	BoundingBox* box=cg->getBoundingBox();
	fail_unless(!box->isSetId());
	Point* position=box->getPosition();
	fail_unless(position->getXOffset()==0.0);
	fail_unless(position->getYOffset()==0.0);
	fail_unless(position->getZOffset()==0.0);
	dimensions=box->getDimensions();
	fail_unless(dimensions->getWidth()==0.0);
	fail_unless(dimensions->getHeight()==0.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getNumSpeciesGlyphs()==1);
	SpeciesGlyph* sg=l->getSpeciesGlyph(0);
	fail_unless(sg!=NULL);
	fail_unless(sg->getId()=="speciesGlyph_1");
	box=sg->getBoundingBox();
	fail_unless(!box->isSetId());
	position=box->getPosition();
	fail_unless(position->getXOffset()==0.0);
	fail_unless(position->getYOffset()==0.0);
	fail_unless(position->getZOffset()==0.0);
	dimensions=box->getDimensions();
	fail_unless(dimensions->getWidth()==0.0);
	fail_unless(dimensions->getHeight()==0.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg!=NULL);
	fail_unless(rg->getId()=="reactionGlyph_1");
	box=rg->getBoundingBox();
	fail_unless(!box->isSetId());
	position=box->getPosition();
	fail_unless(position->getXOffset()==0.0);
	fail_unless(position->getYOffset()==0.0);
	fail_unless(position->getZOffset()==0.0);
	dimensions=box->getDimensions();
	fail_unless(dimensions->getWidth()==0.0);
	fail_unless(dimensions->getHeight()==0.0);
	fail_unless(dimensions->getDepth()==0.0);
  
  
	fail_unless(l->getNumTextGlyphs()==1);
	TextGlyph* tg=l->getTextGlyph(0);
	fail_unless(tg!=NULL);
	fail_unless(tg->getId()=="textGlyph_1");
	box=tg->getBoundingBox();
	fail_unless(!box->isSetId());
	position=box->getPosition();
	fail_unless(position->getXOffset()==0.0);
	fail_unless(position->getYOffset()==0.0);
	fail_unless(position->getZOffset()==0.0);
	dimensions=box->getDimensions();
	fail_unless(dimensions->getWidth()==0.0);
	fail_unless(dimensions->getHeight()==0.0);
	fail_unless(dimensions->getDepth()==0.0);
  
  
	fail_unless(l->getNumAdditionalGraphicalObjects()==1);
	GraphicalObject* go=l->getAdditionalGraphicalObject(0);
	fail_unless(go!=NULL);
	fail_unless(go->getId()=="graphicalObject_1");
	box=go->getBoundingBox();
	fail_unless(!box->isSetId());
	position=box->getPosition();
	fail_unless(position->getXOffset()==0.0);
	fail_unless(position->getYOffset()==0.0);
	fail_unless(position->getZOffset()==0.0);
	dimensions=box->getDimensions();
	fail_unless(dimensions->getWidth()==0.0);
	fail_unless(dimensions->getHeight()==0.0);
	fail_unless(dimensions->getDepth()==0.0);
	delete pListOfLayouts;
	delete stream;
}
END_TEST


START_TEST (test_LayoutCreation_Layout_notes)
{
  
  
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <notes>"
  "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  "   <p>Testnote</p>\n"
  "  </body>"
  "  </notes>\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->isSetNotes());
	XMLInputStream *stream2 = new XMLInputStream(NOTES.c_str(),false);
	XMLNode notes=XMLNode(*stream2);
	fail_unless(l->getNotes()->equals(notes, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_Layout_annotation)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <annotation>\n"
  "      <this-is-a-test>\n"
  "        <another-level> level2 </another-level>\n"
  "      </this-is-a-test>\n"
  "    </annotation>\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
	const char* a =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "    <this-is-a-test>\n"
  "      <another-level> level2 </another-level>\n"
  "    </this-is-a-test>\n"
  "  </annotation>";
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->isSetAnnotation());
	XMLInputStream stream2(a,false);
	XMLNode aNode=XMLNode(stream2);
	fail_unless(l->getAnnotation()->equals(aNode, true));
  
	delete pListOfLayouts;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_Layout_skipOptional)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getNumCompartmentGlyphs()==0);
	fail_unless(l->getNumSpeciesGlyphs()==0);
	fail_unless(l->getNumReactionGlyphs()==0);
	fail_unless(l->getNumTextGlyphs()==0);
	fail_unless(l->getNumAdditionalGraphicalObjects()==0);
  
	delete pListOfLayouts;
	delete stream;
}
END_TEST


START_TEST (test_LayoutCreation_CompartmentGlyph)
{
  const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfCompartmentGlyphs>\n"
  "      <compartmentGlyph id=\"compartmentGlyph_1\" compartment=\"compartment_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </compartmentGlyph>\n"
  "    </listOfCompartmentGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumCompartmentGlyphs()==1);
	CompartmentGlyph* cg=l->getCompartmentGlyph(0);
	fail_unless(cg->getId()=="compartmentGlyph_1");
	fail_unless(cg->getCompartmentId()=="compartment_1");
  
	BoundingBox* bb=cg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	delete pListOfLayouts;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_CompartmentGlyph_notes)
{
  const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfCompartmentGlyphs>\n"
  "      <compartmentGlyph id=\"compartmentGlyph_1\">\n"
  "        <notes>"
  "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  "   <p>Testnote</p>\n"
  "  </body>"
  "  </notes>\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </compartmentGlyph>\n"
  "    </listOfCompartmentGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream= new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumCompartmentGlyphs()==1);
	CompartmentGlyph* cg=l->getCompartmentGlyph(0);
	fail_unless(cg->getId()=="compartmentGlyph_1");
	fail_unless(!cg->isSetCompartmentId());
  
	BoundingBox* bb=cg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	fail_unless(cg->isSetNotes());
	XMLInputStream *stream2 = new XMLInputStream(NOTES.c_str(),false);
	XMLNode notes=XMLNode(*stream2);
	fail_unless(cg->getNotes()->equals(notes, true));
  
	delete pListOfLayouts;
	delete stream2;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_CompartmentGlyph_annotation)
{
	const char* a =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "        <this-is-a-test>\n"
  "          <another-level> level2 </another-level>\n"
  "        </this-is-a-test>\n"
  "      </annotation>";
  
  const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfCompartmentGlyphs>\n"
  "      <compartmentGlyph id=\"compartmentGlyph_1\">\n"
  "        <annotation>\n"
  "          <this-is-a-test>\n"
  "            <another-level> level2 </another-level>\n"
  "          </this-is-a-test>\n"
  "        </annotation>\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </compartmentGlyph>\n"
  "    </listOfCompartmentGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumCompartmentGlyphs()==1);
	CompartmentGlyph* cg=l->getCompartmentGlyph(0);
	fail_unless(cg->getId()=="compartmentGlyph_1");
	fail_unless(!cg->isSetCompartmentId());
  
	BoundingBox* bb=cg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	fail_unless(cg->isSetAnnotation());
	XMLInputStream *stream2 = new XMLInputStream(a,false);
	XMLNode aNode=XMLNode(*stream2);
	fail_unless(cg->getAnnotation()->equals(aNode, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_CompartmentGlyph_skipOptional)
{
  const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfCompartmentGlyphs>\n"
  "      <compartmentGlyph id=\"compartmentGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </compartmentGlyph>\n"
  "    </listOfCompartmentGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumCompartmentGlyphs()==1);
	CompartmentGlyph* cg=l->getCompartmentGlyph(0);
	fail_unless(cg->getId()=="compartmentGlyph_1");
	fail_unless(!cg->isSetCompartmentId());
  
	BoundingBox* bb=cg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	delete pListOfLayouts;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_SpeciesGlyph)
{
  const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfSpeciesGlyphs>\n"
  "      <speciesGlyph id=\"speciesGlyph_1\" species=\"species_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </speciesGlyph>\n"
  "    </listOfSpeciesGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumSpeciesGlyphs()==1);
	SpeciesGlyph* sg=l->getSpeciesGlyph(0);
	fail_unless(sg->getId()=="speciesGlyph_1");
	fail_unless(sg->getSpeciesId()=="species_1");
  
	BoundingBox* bb=sg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	delete pListOfLayouts;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_SpeciesGlyph_notes)
{
  const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfSpeciesGlyphs>\n"
  "      <speciesGlyph id=\"speciesGlyph_1\">\n"
  "    <notes>"
  "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  "   <p>Testnote</p>\n"
  "  </body>"
  "  </notes>\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </speciesGlyph>\n"
  "    </listOfSpeciesGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumSpeciesGlyphs()==1);
	SpeciesGlyph* sg=l->getSpeciesGlyph(0);
	fail_unless(sg->getId()=="speciesGlyph_1");
	fail_unless(!sg->isSetSpeciesId());
  
	BoundingBox* bb=sg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	fail_unless(sg->isSetNotes());
	XMLInputStream *stream2 = new XMLInputStream(NOTES.c_str(),false);
	XMLNode notes=XMLNode(*stream2);
	fail_unless(sg->getNotes()->equals(notes, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_SpeciesGlyph_annotation)
{
	const char* a =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "        <this-is-a-test>\n"
  "          <another-level> level2 </another-level>\n"
  "        </this-is-a-test>\n"
  "      </annotation>";
  
  const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfSpeciesGlyphs>\n"
  "      <speciesGlyph id=\"speciesGlyph_1\">\n"
  "        <annotation>\n"
  "          <this-is-a-test>\n"
  "            <another-level> level2 </another-level>\n"
  "          </this-is-a-test>\n"
  "        </annotation>\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </speciesGlyph>\n"
  "    </listOfSpeciesGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumSpeciesGlyphs()==1);
	SpeciesGlyph* sg=l->getSpeciesGlyph(0);
	fail_unless(sg->getId()=="speciesGlyph_1");
	fail_unless(!sg->isSetSpeciesId());
  
	BoundingBox* bb=sg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	fail_unless(sg->isSetAnnotation());
	XMLInputStream *stream2 = new XMLInputStream(a,false);
	XMLNode aNode=XMLNode(*stream2);
	fail_unless(sg->getAnnotation()->equals(aNode, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_SpeciesGlyph_skipOptional)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfSpeciesGlyphs>\n"
  "      <speciesGlyph id=\"speciesGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </speciesGlyph>\n"
  "    </listOfSpeciesGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumSpeciesGlyphs()==1);
	SpeciesGlyph* sg=l->getSpeciesGlyph(0);
	fail_unless(sg->getId()=="speciesGlyph_1");
  
	fail_unless(!sg->isSetSpeciesId());
  
	BoundingBox* bb=sg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
	delete pListOfLayouts;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_ReactionGlyph_Curve)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\" reaction=\"reaction_1\">\n"
  "        <curve>\n"
  "          <listOfCurveSegments>\n"
  "            <curveSegment xsi:type=\"LineSegment\">\n"
  "              <start x=\"10\" y=\"15\"/>\n"
  "              <end x=\"20\" y=\"30\"/>\n"
  "            </curveSegment>\n"
  "          </listOfCurveSegments>\n"
  "        </curve>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(rg->getReactionId()=="reaction_1");
  
	fail_unless(rg->isSetCurve());
	Curve* curve=rg->getCurve();
	fail_unless(curve->getNumCurveSegments()==1);
	LineSegment* ls=curve->getCurveSegment(0);
	fail_unless(ls->getTypeCode()!=SBML_LAYOUT_CUBICBEZIER);
	Point* start=ls->getStart();
	fail_unless(start->getXOffset()==10.0);
	fail_unless(start->getYOffset()==15.0);
	fail_unless(start->getZOffset()==0.0);
	Point* end=ls->getEnd();
	fail_unless(end->getXOffset()==20.0);
	fail_unless(end->getYOffset()==30.0);
	fail_unless(end->getZOffset()==0.0);
  
	delete pListOfLayouts;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_ReactionGlyph_BoundingBox)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\" reaction=\"reaction_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(rg->getReactionId()=="reaction_1");
  
	BoundingBox* bb=rg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
	delete pListOfLayouts;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_ReactionGlyph_notes)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\" reaction=\"reaction_1\">\n"
  "        <notes>"
  "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  "   <p>Testnote</p>\n"
  "  </body>"
  "  </notes>\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(rg->getReactionId()=="reaction_1");
  
	BoundingBox* bb=rg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
	fail_unless(rg->isSetNotes());
	XMLInputStream *stream2 = new XMLInputStream(NOTES.c_str(),false);
	XMLNode notes=XMLNode(*stream2);
	fail_unless(rg->getNotes()->equals(notes, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_ReactionGlyph_annotation)
{
	const char* a =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "        <this-is-a-test>\n"
  "          <another-level> level2 </another-level>\n"
  "        </this-is-a-test>\n"
  "      </annotation>";
  
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\" reaction=\"reaction_1\">\n"
  "        <annotation>\n"
  "          <this-is-a-test>\n"
  "            <another-level> level2 </another-level>\n"
  "          </this-is-a-test>\n"
  "        </annotation>\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(rg->getReactionId()=="reaction_1");
  
	BoundingBox* bb=rg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	fail_unless(rg->isSetAnnotation());
	XMLInputStream *stream2 = new XMLInputStream(a,false);
	XMLNode aNode=XMLNode(*stream2);
	fail_unless(rg->getAnnotation()->equals(aNode, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_ReactionGlyph_skipOptional)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	BoundingBox* bb=rg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	delete pListOfLayouts;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_SpeciesReferenceGlyph_Curve)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "        <listOfSpeciesReferenceGlyphs>\n"
  "          <speciesReferenceGlyph id=\"speciesReferenceGlyph_1\" speciesReference=\"speciesReference_1\" speciesGlyph=\"speciesGlyph_1\" role=\"activator\">\n"
  "            <curve>\n"
  "              <listOfCurveSegments>\n"
  "                <curveSegment xsi:type=\"LineSegment\">\n"
  "                  <start x=\"10\" y=\"15\"/>\n"
  "                  <end x=\"20\" y=\"30\"/>\n"
  "                </curveSegment>\n"
  "              </listOfCurveSegments>\n"
  "            </curve>\n"
  "          </speciesReferenceGlyph>\n"
  "        </listOfSpeciesReferenceGlyphs>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	BoundingBox* bb=rg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	fail_unless(rg->getNumSpeciesReferenceGlyphs()==1);
	SpeciesReferenceGlyph* srg=rg->getSpeciesReferenceGlyph(0);
	fail_unless(srg->getId()=="speciesReferenceGlyph_1");
	fail_unless(srg->getRole()==SPECIES_ROLE_ACTIVATOR);
	fail_unless(srg->getSpeciesGlyphId()=="speciesGlyph_1");
	fail_unless(srg->getSpeciesReferenceId()=="speciesReference_1");
  
	fail_unless(srg->isSetCurve());
	Curve* curve=srg->getCurve();
	fail_unless(curve->getNumCurveSegments()==1);
	LineSegment* ls=curve->getCurveSegment(0);
	fail_unless(ls->getTypeCode()!=SBML_LAYOUT_CUBICBEZIER);
	Point* start=ls->getStart();
	fail_unless(start->getXOffset()==10.0);
	fail_unless(start->getYOffset()==15.0);
	fail_unless(start->getZOffset()==0.0);
	Point* end=ls->getEnd();
	fail_unless(end->getXOffset()==20.0);
	fail_unless(end->getYOffset()==30.0);
	fail_unless(end->getZOffset()==0.0);
  
	delete pListOfLayouts;
}
END_TEST

START_TEST (test_LayoutCreation_SpeciesReferenceGlyph_BoundingBox)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "        <listOfSpeciesReferenceGlyphs>\n"
  "          <speciesReferenceGlyph id=\"speciesReferenceGlyph_1\" speciesReference=\"speciesReference_1\" speciesGlyph=\"speciesGlyph_1\" role=\"modifier\">\n"
  "            <boundingBox>\n"
  "              <position x=\"110.3\" y=\"120\"/>\n"
  "              <dimensions width=\"20.5\" height=\"40.5\"/>\n"
  "            </boundingBox>\n"
  "          </speciesReferenceGlyph>\n"
  "        </listOfSpeciesReferenceGlyphs>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	BoundingBox* bb=rg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions3=bb->getDimensions();
	fail_unless(dimensions3->getWidth()==200.5);
	fail_unless(dimensions3->getHeight()==400.5);
	fail_unless(dimensions3->getDepth()==0.0);
  
	fail_unless(rg->getNumSpeciesReferenceGlyphs()==1);
	SpeciesReferenceGlyph* srg=rg->getSpeciesReferenceGlyph(0);
	fail_unless(srg->getId()=="speciesReferenceGlyph_1");
	fail_unless(srg->getRole()==SPECIES_ROLE_MODIFIER);
	fail_unless(srg->getSpeciesGlyphId()=="speciesGlyph_1");
	fail_unless(srg->getSpeciesReferenceId()=="speciesReference_1");
  
	BoundingBox* bb2=srg->getBoundingBox();
	Point* position2=bb2->getPosition();
	fail_unless(position2->getXOffset()==110.3);
	fail_unless(position2->getYOffset()==120.0);
	fail_unless(position2->getZOffset()==0.0);
	Dimensions* dimensions2=bb2->getDimensions();
	fail_unless(dimensions2->getWidth()==20.5);
	fail_unless(dimensions2->getHeight()==40.5);
	fail_unless(dimensions2->getDepth()==0.0);
	delete pListOfLayouts;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_SpeciesReferenceGlyph_notes)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "        <listOfSpeciesReferenceGlyphs>\n"
  "          <speciesReferenceGlyph id=\"speciesReferenceGlyph_1\" role=\"substrate\">\n"
  "            <notes>"
  "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  "   <p>Testnote</p>\n"
  "  </body>"
  "  </notes>\n"
  "            <boundingBox>\n"
  "              <position x=\"110.3\" y=\"120\"/>\n"
  "              <dimensions width=\"20.5\" height=\"40.5\"/>\n"
  "            </boundingBox>\n"
  "          </speciesReferenceGlyph>\n"
  "        </listOfSpeciesReferenceGlyphs>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	BoundingBox* bb=rg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions3=bb->getDimensions();
	fail_unless(dimensions3->getWidth()==200.5);
	fail_unless(dimensions3->getHeight()==400.5);
	fail_unless(dimensions3->getDepth()==0.0);
  
	fail_unless(rg->getNumSpeciesReferenceGlyphs()==1);
	SpeciesReferenceGlyph* srg=rg->getSpeciesReferenceGlyph(0);
	fail_unless(srg->getId()=="speciesReferenceGlyph_1");
	fail_unless(srg->getRole()==SPECIES_ROLE_SUBSTRATE);
	fail_unless(!srg->isSetSpeciesGlyphId());
	fail_unless(!srg->isSetSpeciesReferenceId());
  
	BoundingBox* bb2=srg->getBoundingBox();
	Point* position2=bb2->getPosition();
	fail_unless(position2->getXOffset()==110.3);
	fail_unless(position2->getYOffset()==120.0);
	fail_unless(position2->getZOffset()==0.0);
	Dimensions* dimensions2=bb2->getDimensions();
	fail_unless(dimensions2->getWidth()==20.5);
	fail_unless(dimensions2->getHeight()==40.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	fail_unless(srg->isSetNotes());
	XMLInputStream *stream2 = new XMLInputStream(NOTES.c_str(),false);
	XMLNode notes=XMLNode(*stream2);
	fail_unless(srg->getNotes()->equals(notes, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_SpeciesReferenceGlyph_annotation)
{
	const char* a =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "            <this-is-a-test>\n"
  "              <another-level> level2 </another-level>\n"
  "            </this-is-a-test>\n"
  "          </annotation>";
  
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "        <listOfSpeciesReferenceGlyphs>\n"
  "          <speciesReferenceGlyph id=\"speciesReferenceGlyph_1\" role=\"sideproduct\">\n"
  "            <annotation>\n"
  "              <this-is-a-test>\n"
  "                <another-level> level2 </another-level>\n"
  "              </this-is-a-test>\n"
  "            </annotation>\n"
  "            <boundingBox>\n"
  "              <position x=\"110.3\" y=\"120\"/>\n"
  "              <dimensions width=\"20.5\" height=\"40.5\"/>\n"
  "            </boundingBox>\n"
  "          </speciesReferenceGlyph>\n"
  "        </listOfSpeciesReferenceGlyphs>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	BoundingBox* bb=rg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions3=bb->getDimensions();
	fail_unless(dimensions3->getWidth()==200.5);
	fail_unless(dimensions3->getHeight()==400.5);
	fail_unless(dimensions3->getDepth()==0.0);
  
	fail_unless(rg->getNumSpeciesReferenceGlyphs()==1);
	SpeciesReferenceGlyph* srg=rg->getSpeciesReferenceGlyph(0);
	fail_unless(srg->getId()=="speciesReferenceGlyph_1");
	fail_unless(srg->getRole()==SPECIES_ROLE_SIDEPRODUCT);
	fail_unless(!srg->isSetSpeciesGlyphId());
	fail_unless(!srg->isSetSpeciesReferenceId());
  
	BoundingBox* bb2=srg->getBoundingBox();
	Point* position2=bb2->getPosition();
	fail_unless(position2->getXOffset()==110.3);
	fail_unless(position2->getYOffset()==120.0);
	fail_unless(position2->getZOffset()==0.0);
	Dimensions* dimensions2=bb2->getDimensions();
	fail_unless(dimensions2->getWidth()==20.5);
	fail_unless(dimensions2->getHeight()==40.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	fail_unless(srg->isSetAnnotation());
	XMLInputStream *stream2 = new XMLInputStream(a,false);
	XMLNode aNode=XMLNode(*stream2);
	fail_unless(srg->getAnnotation()->equals(aNode, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_SpeciesReferenceGlyph_skipOptional)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "        <listOfSpeciesReferenceGlyphs>\n"
  "          <speciesReferenceGlyph id=\"speciesReferenceGlyph_1\" role=\"sidesubstrate\">\n"
  "            <boundingBox>\n"
  "              <position x=\"110.3\" y=\"120\"/>\n"
  "              <dimensions width=\"20.5\" height=\"40.5\"/>\n"
  "            </boundingBox>\n"
  "          </speciesReferenceGlyph>\n"
  "        </listOfSpeciesReferenceGlyphs>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	BoundingBox* bb=rg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions3=bb->getDimensions();
	fail_unless(dimensions3->getWidth()==200.5);
	fail_unless(dimensions3->getHeight()==400.5);
	fail_unless(dimensions3->getDepth()==0.0);
  
	fail_unless(rg->getNumSpeciesReferenceGlyphs()==1);
	SpeciesReferenceGlyph* srg=rg->getSpeciesReferenceGlyph(0);
	fail_unless(srg->getId()=="speciesReferenceGlyph_1");
	fail_unless(srg->getRole()==SPECIES_ROLE_SIDESUBSTRATE);
	fail_unless(!srg->isSetSpeciesGlyphId());
	fail_unless(!srg->isSetSpeciesReferenceId());
  
	BoundingBox* bb2=srg->getBoundingBox();
	Point* position2=bb2->getPosition();
	fail_unless(position2->getXOffset()==110.3);
	fail_unless(position2->getYOffset()==120.0);
	fail_unless(position2->getZOffset()==0.0);
	Dimensions* dimensions2=bb2->getDimensions();
	fail_unless(dimensions2->getWidth()==20.5);
	fail_unless(dimensions2->getHeight()==40.5);
	fail_unless(dimensions2->getDepth()==0.0);
	delete pListOfLayouts;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_TextGlyph_text)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfTextGlyphs>\n"
  "      <textGlyph id=\"textGlyph_1\" graphicalObject=\"speciesGlyph_1\" text=\"test text\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </textGlyph>\n"
  "    </listOfTextGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumTextGlyphs()==1);
	TextGlyph* tg=l->getTextGlyph(0);
	fail_unless(tg->getId()=="textGlyph_1");
  
	fail_unless(tg->getGraphicalObjectId()=="speciesGlyph_1");
	fail_unless(tg->getText()=="test text");
  
	BoundingBox* bb=tg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
	delete pListOfLayouts;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_TextGlyph_originOfText)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfTextGlyphs>\n"
  "      <textGlyph id=\"textGlyph_1\" graphicalObject=\"speciesGlyph_1\" originOfText=\"reactionGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </textGlyph>\n"
  "    </listOfTextGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumTextGlyphs()==1);
	TextGlyph* tg=l->getTextGlyph(0);
	fail_unless(tg->getId()=="textGlyph_1");
  
	fail_unless(tg->getGraphicalObjectId()=="speciesGlyph_1");
	fail_unless(tg->getOriginOfTextId()=="reactionGlyph_1");
  
	BoundingBox* bb=tg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
	delete pListOfLayouts;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_TextGlyph_notes)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfTextGlyphs>\n"
  "      <textGlyph id=\"textGlyph_1\" graphicalObject=\"speciesGlyph_1\" originOfText=\"reactionGlyph_1\">\n"
  "        <notes>"
  "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  "   <p>Testnote</p>\n"
  "  </body>"
  "  </notes>\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </textGlyph>\n"
  "    </listOfTextGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream= new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumTextGlyphs()==1);
	TextGlyph* tg=l->getTextGlyph(0);
	fail_unless(tg->getId()=="textGlyph_1");
  
	fail_unless(tg->getGraphicalObjectId()=="speciesGlyph_1");
	fail_unless(tg->getOriginOfTextId()=="reactionGlyph_1");
  
	BoundingBox* bb=tg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	fail_unless(tg->isSetNotes());
	XMLInputStream *stream2 = new XMLInputStream(NOTES.c_str(),false);
	XMLNode notes=XMLNode(*stream2);
	fail_unless(tg->getNotes()->equals(notes, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_TextGlyph_annotation)
{
	const char* a =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "        <this-is-a-test>\n"
  "          <another-level> level2 </another-level>\n"
  "        </this-is-a-test>\n"
  "      </annotation>";
  
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfTextGlyphs>\n"
  "      <textGlyph id=\"textGlyph_1\" graphicalObject=\"speciesGlyph_1\" originOfText=\"reactionGlyph_1\">\n"
  "        <annotation>\n"
  "          <this-is-a-test>\n"
  "            <another-level> level2 </another-level>\n"
  "          </this-is-a-test>\n"
  "        </annotation>\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </textGlyph>\n"
  "    </listOfTextGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumTextGlyphs()==1);
	TextGlyph* tg=l->getTextGlyph(0);
	fail_unless(tg->getId()=="textGlyph_1");
  
	fail_unless(tg->getGraphicalObjectId()=="speciesGlyph_1");
	fail_unless(tg->getOriginOfTextId()=="reactionGlyph_1");
  
	BoundingBox* bb=tg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	fail_unless(tg->isSetAnnotation());
	XMLInputStream *stream2 = new XMLInputStream(a,false);
	XMLNode aNode=XMLNode(*stream2);
	fail_unless(tg->getAnnotation()->equals(aNode, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_TextGlyph_skipOptional)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfTextGlyphs>\n"
  "      <textGlyph id=\"textGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </textGlyph>\n"
  "   </listOfTextGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumTextGlyphs()==1);
	TextGlyph* tg=l->getTextGlyph(0);
	fail_unless(tg->getId()=="textGlyph_1");
  
	fail_unless(!tg->isSetGraphicalObjectId());
	fail_unless(!tg->isSetOriginOfTextId());
	fail_unless(!tg->isSetText());
  
	BoundingBox* bb=tg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
	delete pListOfLayouts;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_GraphicalObject)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfAdditionalGraphicalObjects>\n"
  "      <graphicalObject id=\"graphicalObject_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </graphicalObject>\n"
  "    </listOfAdditionalGraphicalObjects>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumAdditionalGraphicalObjects()==1);
	GraphicalObject* go=l->getAdditionalGraphicalObject(0);
	fail_unless(go->getId()=="graphicalObject_1");
	BoundingBox* bb=go->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
	delete pListOfLayouts;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_GraphicalObject_notes)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfAdditionalGraphicalObjects>\n"
  "      <graphicalObject id=\"graphicalObject_1\">\n"
  "        <notes>"
  "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  "   <p>Testnote</p>\n"
  "  </body>"
  "  </notes>\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </graphicalObject>\n"
  "    </listOfAdditionalGraphicalObjects>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumAdditionalGraphicalObjects()==1);
	GraphicalObject* go=l->getAdditionalGraphicalObject(0);
	fail_unless(go->getId()=="graphicalObject_1");
	BoundingBox* bb=go->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
	fail_unless(go->isSetNotes());
	XMLInputStream *stream2 = new XMLInputStream(NOTES.c_str(),false);
	XMLNode notes=XMLNode(*stream2);
	fail_unless(go->getNotes()->equals(notes, true));
  
	delete pListOfLayouts;
	delete stream2;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_GraphicalObject_annotation)
{
	const char* a =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "        <this-is-a-test>\n"
  "          <another-level> level2 </another-level>\n"
  "        </this-is-a-test>\n"
  "      </annotation>";
  
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfAdditionalGraphicalObjects>\n"
  "      <graphicalObject id=\"graphicalObject_1\">\n"
  "        <annotation>\n"
  "          <this-is-a-test>\n"
  "            <another-level> level2 </another-level>\n"
  "          </this-is-a-test>\n"
  "        </annotation>\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </graphicalObject>\n"
  "    </listOfAdditionalGraphicalObjects>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumAdditionalGraphicalObjects()==1);
	GraphicalObject* go=l->getAdditionalGraphicalObject(0);
	fail_unless(go->getId()=="graphicalObject_1");
	BoundingBox* bb=go->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	fail_unless(go->isSetAnnotation());
	XMLInputStream *stream2 = new XMLInputStream(a,false);
	XMLNode aNode=XMLNode(*stream2);
	fail_unless(go->getAnnotation()->equals(aNode, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_Curve)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <curve>\n"
  "          <listOfCurveSegments>\n"
  "            <curveSegment xsi:type=\"LineSegment\">\n"
  "              <start x=\"10\" y=\"15\"/>\n"
  "              <end x=\"20\" y=\"30\"/>\n"
  "            </curveSegment>\n"
  "          </listOfCurveSegments>\n"
  "        </curve>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	fail_unless(rg->isSetCurve());
	Curve* curve=rg->getCurve();
	fail_unless(curve->getNumCurveSegments()==1);
	LineSegment* ls=curve->getCurveSegment(0);
	fail_unless(ls->getTypeCode()!=SBML_LAYOUT_CUBICBEZIER);
	Point* start=ls->getStart();
	fail_unless(start->getXOffset()==10.0);
	fail_unless(start->getYOffset()==15.0);
	fail_unless(start->getZOffset()==0.0);
	Point* end=ls->getEnd();
	fail_unless(end->getXOffset()==20.0);
	fail_unless(end->getYOffset()==30.0);
	fail_unless(end->getZOffset()==0.0);
	delete pListOfLayouts;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_Curve_notes)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <curve>\n"
  "          <notes>"
  "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  "   <p>Testnote</p>\n"
  "  </body>"
  "  </notes>\n"
  "          <listOfCurveSegments>\n"
  "            <curveSegment xsi:type=\"LineSegment\">\n"
  "              <start x=\"10\" y=\"15\"/>\n"
  "              <end x=\"20\" y=\"30\"/>\n"
  "            </curveSegment>\n"
  "          </listOfCurveSegments>\n"
  "        </curve>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	fail_unless(rg->isSetCurve());
	Curve* curve=rg->getCurve();
	fail_unless(curve->getNumCurveSegments()==1);
	LineSegment* ls=curve->getCurveSegment(0);
	fail_unless(ls->getTypeCode()!=SBML_LAYOUT_CUBICBEZIER);
	Point* start=ls->getStart();
	fail_unless(start->getXOffset()==10.0);
	fail_unless(start->getYOffset()==15.0);
	fail_unless(start->getZOffset()==0.0);
	Point* end=ls->getEnd();
	fail_unless(end->getXOffset()==20.0);
	fail_unless(end->getYOffset()==30.0);
	fail_unless(end->getZOffset()==0.0);
	fail_unless(curve->isSetNotes()==true);
	XMLInputStream *stream2 = new XMLInputStream(NOTES.c_str(),false);
	XMLNode notes=XMLNode(*stream2);
	fail_unless(curve->getNotes()->equals(notes, true));
  
	delete pListOfLayouts;
	delete stream;
	delete stream2;
  
}
END_TEST

START_TEST (test_LayoutCreation_Curve_annotation)
{
	const char* a =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "          <this-is-a-test>\n"
  "            <another-level> level2 </another-level>\n"
  "          </this-is-a-test>\n"
  "        </annotation>";
  
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <curve>\n"
  "          <annotation>\n"
  "            <this-is-a-test>\n"
  "              <another-level> level2 </another-level>\n"
  "            </this-is-a-test>\n"
  "          </annotation>\n"
  "          <listOfCurveSegments>\n"
  "            <curveSegment xsi:type=\"LineSegment\">\n"
  "              <start x=\"10\" y=\"15\"/>\n"
  "              <end x=\"20\" y=\"30\"/>\n"
  "            </curveSegment>\n"
  "          </listOfCurveSegments>\n"
  "        </curve>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	fail_unless(rg->isSetCurve());
	Curve* curve=rg->getCurve();
	fail_unless(curve->getNumCurveSegments()==1);
	LineSegment* ls=curve->getCurveSegment(0);
	fail_unless(ls->getTypeCode()!=SBML_LAYOUT_CUBICBEZIER);
	Point* start=ls->getStart();
	fail_unless(start->getXOffset()==10.0);
	fail_unless(start->getYOffset()==15.0);
	Point* end=ls->getEnd();
	fail_unless(end->getXOffset()==20.0);
	fail_unless(end->getYOffset()==30.0);
  
	fail_unless(curve->isSetAnnotation());
	XMLInputStream *stream2 = new XMLInputStream(a,false);
	XMLNode aNode=XMLNode(*stream2);
	fail_unless(curve->getAnnotation()->equals(aNode, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_Curve_skipOptional)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <curve>\n"
  "        </curve>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	fail_unless(!rg->isSetCurve());
	delete pListOfLayouts;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_LineSegment)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <curve>\n"
  "          <listOfCurveSegments>\n"
  "            <curveSegment xsi:type=\"LineSegment\">\n"
  "              <start x=\"10\" y=\"15\"/>\n"
  "              <end x=\"20\" y=\"30\"/>\n"
  "            </curveSegment>\n"
  "          </listOfCurveSegments>\n"
  "        </curve>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	fail_unless(rg->isSetCurve());
	Curve* curve=rg->getCurve();
	fail_unless(curve->getNumCurveSegments()==1);
	LineSegment* ls=curve->getCurveSegment(0);
	fail_unless(ls->getTypeCode()!=SBML_LAYOUT_CUBICBEZIER);
	Point* start=ls->getStart();
	fail_unless(start->getXOffset()==10.0);
	fail_unless(start->getYOffset()==15.0);
	Point* end=ls->getEnd();
	fail_unless(end->getXOffset()==20.0);
	fail_unless(end->getYOffset()==30.0);
	delete pListOfLayouts;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_LineSegment_notes)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <curve>\n"
  "          <listOfCurveSegments>\n"
  "            <curveSegment xsi:type=\"LineSegment\">\n"
  "              <notes>"
  "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  "   <p>Testnote</p>\n"
  "  </body>"
  "  </notes>\n"
  "                    <start x=\"10\" y=\"15\"/>\n"
  "              <end x=\"20\" y=\"30\"/>\n"
  "            </curveSegment>\n"
  "          </listOfCurveSegments>\n"
  "        </curve>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	fail_unless(rg->isSetCurve());
	Curve* curve=rg->getCurve();
	fail_unless(curve->getNumCurveSegments()==1);
	LineSegment* ls=curve->getCurveSegment(0);
	fail_unless(ls->getTypeCode()!=SBML_LAYOUT_CUBICBEZIER);
	Point* start=ls->getStart();
	fail_unless(start->getXOffset()==10.0);
	fail_unless(start->getYOffset()==15.0);
	Point* end=ls->getEnd();
	fail_unless(end->getXOffset()==20.0);
	fail_unless(end->getYOffset()==30.0);
	fail_unless(ls->isSetNotes());
	XMLInputStream *stream2 = new XMLInputStream(NOTES.c_str(),false);
	XMLNode notes=XMLNode(*stream2);
	fail_unless(ls->getNotes()->equals(notes, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_LineSegment_annotation)
{
	const char* a =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "              <this-is-a-test>\n"
  "                <another-level> level2 </another-level>\n"
  "              </this-is-a-test>\n"
  "            </annotation>";
  
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <curve>\n"
  "          <listOfCurveSegments>\n"
  "            <curveSegment xsi:type=\"LineSegment\">\n"
  "              <annotation>\n"
  "                <this-is-a-test>\n"
  "                  <another-level> level2 </another-level>\n"
  "                </this-is-a-test>\n"
  "              </annotation>\n"
  "              <start x=\"10\" y=\"15\"/>\n"
  "              <end x=\"20\" y=\"30\"/>\n"
  "            </curveSegment>\n"
  "          </listOfCurveSegments>\n"
  "        </curve>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	fail_unless(rg->isSetCurve());
	Curve* curve=rg->getCurve();
	fail_unless(curve->getNumCurveSegments()==1);
	LineSegment* ls=curve->getCurveSegment(0);
	fail_unless(ls->getTypeCode()!=SBML_LAYOUT_CUBICBEZIER);
	Point* start=ls->getStart();
	fail_unless(start->getXOffset()==10.0);
	fail_unless(start->getYOffset()==15.0);
	Point* end=ls->getEnd();
	fail_unless(end->getXOffset()==20.0);
	fail_unless(end->getYOffset()==30.0);
  
	fail_unless(ls->isSetAnnotation());
	XMLInputStream *stream2 = new XMLInputStream(a,false);
	XMLNode aNode=XMLNode(*stream2);
	fail_unless(ls->getAnnotation()->equals(aNode, true));
	delete pListOfLayouts;
	delete stream2;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_CubicBezier)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <curve>\n"
  "          <listOfCurveSegments>\n"
  "            <curveSegment xsi:type=\"CubicBezier\">\n"
  "              <start x=\"10\" y=\"15\"/>\n"
  "              <end x=\"20\" y=\"30\"/>\n"
  "              <basePoint1 x=\"15\" y=\"5\"/>\n"
  "              <basePoint2 x=\"15\" y=\"17\"/>\n"
  "            </curveSegment>\n"
  "          </listOfCurveSegments>\n"
  "        </curve>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	fail_unless(rg->isSetCurve());
	Curve* curve=rg->getCurve();
	fail_unless(curve->getNumCurveSegments()==1);
	LineSegment* ls=curve->getCurveSegment(0);
	CubicBezier* cb=static_cast< CubicBezier*>(ls);
	fail_unless(cb!=NULL);
	Point* start=cb->getStart();
	fail_unless(start!=NULL);
	fail_unless(start->getXOffset()==10.0);
	fail_unless(start->getYOffset()==15.0);
	fail_unless(start->getZOffset()==0.0);
	Point* end=cb->getEnd();
	fail_unless(end->getXOffset()==20.0);
	fail_unless(end->getYOffset()==30.0);
	fail_unless(end->getZOffset()==0.0);
	Point* base1=cb->getBasePoint1();
	fail_unless(base1->getXOffset()==15.0);
	fail_unless(base1->getYOffset()==5.0);
	fail_unless(base1->getZOffset()==0.0);
	Point* base2=cb->getBasePoint2();
	fail_unless(base2->getXOffset()==15.0);
	fail_unless(base2->getYOffset()==17.0);
	fail_unless(base2->getZOffset()==0.0);
  
	delete pListOfLayouts;
	delete stream;
  
  
}
END_TEST

START_TEST (test_LayoutCreation_CubicBezier_notes)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <curve>\n"
  "          <listOfCurveSegments>\n"
  "            <curveSegment xsi:type=\"CubicBezier\">\n"
  "              <notes>"
  "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  "   <p>Testnote</p>\n"
  "  </body>"
  "  </notes>\n"
  "                    <start x=\"10\" y=\"15\"/>\n"
  "              <end x=\"20\" y=\"30\"/>\n"
  "              <basePoint1 x=\"15\" y=\"5\"/>\n"
  "              <basePoint2 x=\"16\" y=\"17\"/>\n"
  "            </curveSegment>\n"
  "          </listOfCurveSegments>\n"
  "        </curve>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	fail_unless(rg->isSetCurve());
	Curve* curve=rg->getCurve();
	fail_unless(curve->getNumCurveSegments()==1);
	LineSegment* ls=curve->getCurveSegment(0);
	CubicBezier* cb=static_cast< CubicBezier*>(ls);
	fail_unless(cb!=NULL);
	Point* start=cb->getStart();
	fail_unless(start->getXOffset()==10.0);
	fail_unless(start->getYOffset()==15.0);
	fail_unless(start->getZOffset()==0.0);
	Point* end=cb->getEnd();
	fail_unless(end->getXOffset()==20.0);
	fail_unless(end->getYOffset()==30.0);
	fail_unless(end->getZOffset()==0.0);
	Point* base1=cb->getBasePoint1();
	fail_unless(base1->getXOffset()==15.0);
	fail_unless(base1->getYOffset()==5.0);
	fail_unless(base1->getZOffset()==0.0);
	Point* base2=cb->getBasePoint2();
	fail_unless(base2->getXOffset()==16.0);
	fail_unless(base2->getYOffset()==17.0);
	fail_unless(base2->getZOffset()==0.0);
	fail_unless(cb->isSetNotes());
	XMLInputStream *stream2 = new XMLInputStream(NOTES.c_str(),false);
	XMLNode notes=XMLNode(*stream2);
	fail_unless(cb->getNotes()->equals(notes, true)==true);
  
	delete pListOfLayouts;
	delete stream2;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_CubicBezier_annotation)
{
	const char* a =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "              <this-is-a-test>\n"
  "                <another-level> level2 </another-level>\n"
  "              </this-is-a-test>\n"
  "            </annotation>";
  
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n"
  "    <dimensions width=\"200\" height=\"400\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <curve>\n"
  "          <listOfCurveSegments>\n"
  "            <curveSegment xsi:type=\"CubicBezier\">\n"
  "              <annotation>\n"
  "                <this-is-a-test>\n"
  "                  <another-level> level2 </another-level>\n"
  "                </this-is-a-test>\n"
  "              </annotation>\n"
  "              <start x=\"10\" y=\"15\"/>\n"
  "              <end x=\"20\" y=\"30\"/>\n"
  "              <basePoint1 x=\"15\" y=\"5\"/>\n"
  "              <basePoint2 x=\"16\" y=\"17\"/>\n"
  "            </curveSegment>\n"
  "          </listOfCurveSegments>\n"
  "        </curve>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.0);
	fail_unless(dimensions->getHeight()==400.0);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getId()=="layout_1");
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	fail_unless(rg->isSetCurve());
	Curve* curve=rg->getCurve();
	fail_unless(curve->getNumCurveSegments()==1);
	LineSegment* ls=curve->getCurveSegment(0);
	CubicBezier* cb=static_cast< CubicBezier*>(ls);
	fail_unless(cb!=NULL);
	Point* start=cb->getStart();
	fail_unless(start->getXOffset()==10.0);
	fail_unless(start->getYOffset()==15.0);
	fail_unless(start->getZOffset()==0.0);
	Point* end=cb->getEnd();
	fail_unless(end->getXOffset()==20.0);
	fail_unless(end->getYOffset()==30.0);
	fail_unless(end->getZOffset()==0.0);
	Point* base1=cb->getBasePoint1();
	fail_unless(base1->getXOffset()==15.0);
	fail_unless(base1->getYOffset()==5.0);
	fail_unless(base1->getZOffset()==0.0);
	Point* base2=cb->getBasePoint2();
	fail_unless(base2->getXOffset()==16.0);
	fail_unless(base2->getYOffset()==17.0);
	fail_unless(base2->getZOffset()==0.0);
  
	fail_unless(cb->isSetAnnotation());
	XMLInputStream *stream2= new XMLInputStream(a,false);
	XMLNode aNode=XMLNode(*stream2);
	fail_unless(cb->getAnnotation()->equals(aNode, true)==true);
	delete pListOfLayouts;
	delete stream2;
	delete stream;
}
END_TEST

START_TEST (test_LayoutCreation_Dimensions)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200.5\" height=\"400.5\" depth=\"455.2\"/>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	fail_unless(l->getId()=="layout_1");
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.5);
	fail_unless(dimensions->getHeight()==400.5);
	fail_unless(dimensions->getDepth()==455.2);
  
	delete pListOfLayouts;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_Dimensions_notes)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200.5\" height=\"400.5\" depth=\"455.2\">\n"
  "      <notes>"
  "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  "   <p>Testnote</p>\n"
  "  </body>"
  "  </notes>\n"
  "    </dimensions>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	fail_unless(l->getId()=="layout_1");
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.5);
	fail_unless(dimensions->getHeight()==400.5);
	fail_unless(dimensions->getDepth()==455.2);
	fail_unless(dimensions->isSetNotes());
	XMLInputStream *stream2 = new XMLInputStream(NOTES.c_str(),false);
	XMLNode notes=XMLNode(*stream2);
	fail_unless(dimensions->getNotes()->equals(notes, true)==true);
  
	delete pListOfLayouts;
	delete stream2;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_Dimensions_annotation)
{
	const char* a =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "      <this-is-a-test>\n"
  "        <another-level> level2 </another-level>\n"
  "      </this-is-a-test>\n"
  "    </annotation>";
  
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200.5\" height=\"400.5\" depth=\"455.2\">\n"
  "      <annotation>\n"
  "        <this-is-a-test>\n"
  "          <another-level> level2 </another-level>\n"
  "        </this-is-a-test>\n"
  "      </annotation>\n"
  "    </dimensions>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	fail_unless(l->getId()=="layout_1");
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.5);
	fail_unless(dimensions->getHeight()==400.5);
	fail_unless(dimensions->getDepth()==455.2);
  
	fail_unless(dimensions->isSetAnnotation());
	XMLInputStream *stream2 = new XMLInputStream(a,false);
	XMLNode aNode=XMLNode(*stream2);
	fail_unless(dimensions->getAnnotation()->equals(aNode, true)==true);
	delete pListOfLayouts;
	delete stream2;
	delete stream;
  
  
}
END_TEST

START_TEST (test_LayoutCreation_Dimensions_skipOptional)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>"
  ;
  
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	fail_unless(l->getId()=="layout_1");
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.5);
	fail_unless(dimensions->getHeight()==400.5);
	fail_unless(dimensions->getDepth()==0.0);
  
	delete pListOfLayouts;
	delete stream;
  
}
END_TEST


START_TEST (test_LayoutCreation_BoundingBox)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <boundingBox id=\"boundingBox_1\">\n"
  "          <position x=\"10.3\" y=\"20\" z=\"30.23\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\" depth=\"100.2\"/>\n"
  "        </boundingBox>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	fail_unless(l->getId()=="layout_1");
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.5);
	fail_unless(dimensions->getHeight()==400.5);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	BoundingBox* bb=rg->getBoundingBox();
	fail_unless(bb->getId()=="boundingBox_1");
  
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==30.23);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==100.2);
	delete pListOfLayouts;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_BoundingBox_notes)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <notes>"
  "  <body xmlns=\"http://www.w3.org/1999/xhtml\">\n"
  "   <p>Testnote</p>\n"
  "  </body>"
  "  </notes>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	fail_unless(l->getId()=="layout_1");
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.5);
	fail_unless(dimensions->getHeight()==400.5);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	BoundingBox* bb=rg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
	fail_unless(bb->isSetNotes());
	XMLInputStream *stream2 = new XMLInputStream(NOTES.c_str(),false);
	XMLNode notes=XMLNode(*stream2);
	fail_unless(bb->getNotes()->equals(notes, true)==true);
	delete pListOfLayouts;
	delete stream2;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_BoundingBox_annotation)
{
	const char* a =
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "          <this-is-a-test>\n"
  "            <another-level> level2 </another-level>\n"
  "          </this-is-a-test>\n"
  "        </annotation>";
  
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\">\n"
  "    <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <annotation>\n"
  "            <this-is-a-test>\n"
  "              <another-level> level2 </another-level>\n"
  "            </this-is-a-test>\n"
  "          </annotation>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	fail_unless(l->getId()=="layout_1");
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.5);
	fail_unless(dimensions->getHeight()==400.5);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	BoundingBox* bb=rg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	fail_unless(bb->isSetAnnotation());
	XMLInputStream *stream2 = new XMLInputStream(a,false);
	XMLNode aNode=XMLNode(*stream2);
	fail_unless(bb->getAnnotation()->equals(aNode, true)==true);
	delete pListOfLayouts;
	delete stream2;
	delete stream;
  
}
END_TEST

START_TEST (test_LayoutCreation_BoundingBox_skipOptional)
{
	const char* content=
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  "<annotation>\n"
  "<listOfLayouts xmlns=\"http://projects.eml.org/bcb/sbml/level2\">\n"
  "  <layout id=\"layout_1\"  >\n"
  "    <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "    <listOfReactionGlyphs>\n"
  "      <reactionGlyph id=\"reactionGlyph_1\">\n"
  "        <boundingBox>\n"
  "          <position x=\"10.3\" y=\"20\"/>\n"
  "          <dimensions width=\"200.5\" height=\"400.5\"/>\n"
  "        </boundingBox>\n"
  "      </reactionGlyph>\n"
  "    </listOfReactionGlyphs>\n"
  "  </layout>\n"
  "</listOfLayouts>\n"
  "</annotation>\n"
  ;
  
  
	XMLInputStream *stream=new XMLInputStream(content,false);
	XMLNode node=XMLNode(*stream);
	ListOfLayouts* pListOfLayouts=new ListOfLayouts();
	parseLayoutAnnotation(&node,*pListOfLayouts);
  
	fail_unless(pListOfLayouts->size()==1);
  
	Layout* l=(Layout*)pListOfLayouts->get(0);
  
	fail_unless(l!=NULL);
  
	fail_unless(l->getId()=="layout_1");
  
	Dimensions* dimensions=l->getDimensions();
	fail_unless(dimensions->getWidth()==200.5);
	fail_unless(dimensions->getHeight()==400.5);
	fail_unless(dimensions->getDepth()==0.0);
  
	fail_unless(l->getNumReactionGlyphs()==1);
	ReactionGlyph* rg=l->getReactionGlyph(0);
	fail_unless(rg->getId()=="reactionGlyph_1");
	fail_unless(!rg->isSetReactionId());
  
	BoundingBox* bb=rg->getBoundingBox();
	Point* position=bb->getPosition();
	fail_unless(position->getXOffset()==10.3);
	fail_unless(position->getYOffset()==20.0);
	fail_unless(position->getZOffset()==0.0);
	Dimensions* dimensions2=bb->getDimensions();
	fail_unless(dimensions2->getWidth()==200.5);
	fail_unless(dimensions2->getHeight()==400.5);
	fail_unless(dimensions2->getDepth()==0.0);
  
	delete pListOfLayouts;
	delete stream;
  
}
END_TEST

Suite *
create_suite_LayoutCreation (void)
{
	Suite *suite = suite_create("LayoutCreation");
	TCase *tcase = tcase_create("LayoutCreation");
  
	tcase_add_checked_fixture( tcase,
                            LayoutCreationTest_setup,
                            LayoutCreationTest_teardown );
  
  
	tcase_add_test( tcase, test_LayoutCreation_Layout                            );
	tcase_add_test( tcase, test_LayoutCreation_Layout_notes                      );
	tcase_add_test( tcase, test_LayoutCreation_Layout_annotation                 );
	tcase_add_test( tcase, test_LayoutCreation_Layout_skipOptional               );
	tcase_add_test( tcase, test_LayoutCreation_CompartmentGlyph                  );
	tcase_add_test( tcase, test_LayoutCreation_CompartmentGlyph_notes            );
	tcase_add_test( tcase, test_LayoutCreation_CompartmentGlyph_annotation       );
	tcase_add_test( tcase, test_LayoutCreation_CompartmentGlyph_skipOptional     );
	tcase_add_test( tcase, test_LayoutCreation_SpeciesGlyph                      );
	tcase_add_test( tcase, test_LayoutCreation_SpeciesGlyph_notes                );
	tcase_add_test( tcase, test_LayoutCreation_SpeciesGlyph_annotation           );
	tcase_add_test( tcase, test_LayoutCreation_SpeciesGlyph_skipOptional         );
	tcase_add_test( tcase, test_LayoutCreation_ReactionGlyph_Curve               );
	tcase_add_test( tcase, test_LayoutCreation_ReactionGlyph_BoundingBox         );
	tcase_add_test( tcase, test_LayoutCreation_ReactionGlyph_notes               );
	tcase_add_test( tcase, test_LayoutCreation_ReactionGlyph_annotation          );
	tcase_add_test( tcase, test_LayoutCreation_ReactionGlyph_skipOptional        );
	tcase_add_test( tcase, test_LayoutCreation_SpeciesReferenceGlyph_Curve       );
	tcase_add_test( tcase, test_LayoutCreation_SpeciesReferenceGlyph_BoundingBox );
	tcase_add_test( tcase, test_LayoutCreation_SpeciesReferenceGlyph_notes       );
	tcase_add_test( tcase, test_LayoutCreation_SpeciesReferenceGlyph_annotation  );
	tcase_add_test( tcase, test_LayoutCreation_SpeciesReferenceGlyph_skipOptional);
	tcase_add_test( tcase, test_LayoutCreation_TextGlyph_text                    );
	tcase_add_test( tcase, test_LayoutCreation_TextGlyph_notes                   );
	tcase_add_test( tcase, test_LayoutCreation_TextGlyph_annotation              );
	tcase_add_test( tcase, test_LayoutCreation_TextGlyph_originOfText            );
	tcase_add_test( tcase, test_LayoutCreation_TextGlyph_skipOptional            );
	tcase_add_test( tcase, test_LayoutCreation_GraphicalObject                   );
	tcase_add_test( tcase, test_LayoutCreation_GraphicalObject_notes             );
	tcase_add_test( tcase, test_LayoutCreation_GraphicalObject_annotation        );
	tcase_add_test( tcase, test_LayoutCreation_Curve                             );
	tcase_add_test( tcase, test_LayoutCreation_Curve_notes                       );
	tcase_add_test( tcase, test_LayoutCreation_Curve_annotation                  );
	tcase_add_test( tcase, test_LayoutCreation_Curve_skipOptional                );
	tcase_add_test( tcase, test_LayoutCreation_LineSegment                       );
	tcase_add_test( tcase, test_LayoutCreation_LineSegment_notes                 );
	tcase_add_test( tcase, test_LayoutCreation_LineSegment_annotation            );
	tcase_add_test( tcase, test_LayoutCreation_CubicBezier                       );
	tcase_add_test( tcase, test_LayoutCreation_CubicBezier_notes                 );
	tcase_add_test( tcase, test_LayoutCreation_CubicBezier_annotation            );
	tcase_add_test( tcase, test_LayoutCreation_Dimensions                        );
	tcase_add_test( tcase, test_LayoutCreation_Dimensions_notes                  );
	tcase_add_test( tcase, test_LayoutCreation_Dimensions_annotation             );
	tcase_add_test( tcase, test_LayoutCreation_Dimensions_skipOptional           );
	tcase_add_test( tcase, test_LayoutCreation_BoundingBox                       );
	tcase_add_test( tcase, test_LayoutCreation_BoundingBox_notes                 );
	tcase_add_test( tcase, test_LayoutCreation_BoundingBox_annotation            );
	tcase_add_test( tcase, test_LayoutCreation_BoundingBox_skipOptional          );
	suite_add_tcase(suite, tcase);
  
	return suite;
}




END_C_DECLS
