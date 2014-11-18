/**
 * Filename    : TestGraphicalObject.cpp
 * Description : Unit tests for GraphicalObject
 * Organization: European Media Laboratories Research gGmbH
 * Created     : 2005-05-03
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

#include <string>

#include <sbml/common/common.h>
#include <sbml/common/extern.h>

#include <sbml/packages/layout/common/LayoutExtensionTypes.h>

#include <sbml/conversion/ConversionProperties.h>
#include <sbml/extension/SBasePlugin.h>
#include <sbml/SBMLReader.h>
#include <sbml/SBMLWriter.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

extern char *TestDataDirectory;

BEGIN_C_DECLS

static GraphicalObject* GO;
static LayoutPkgNamespaces* LN;

void
GraphicalObjectTest_setup (void)
{
  LN = new LayoutPkgNamespaces();
  GO = new (std::nothrow) GraphicalObject(LN);
  
  if (GO == NULL)
  {
    fail("new (std::nothrow) GraphicalObject returned a NULL pointer.");
  }
  
}

void
GraphicalObjectTest_teardown (void)
{
  delete GO;
  delete LN;
}

START_TEST (test_GraphicalObject_new)
{
  fail_unless( GO->getTypeCode()    == SBML_LAYOUT_GRAPHICALOBJECT );
  fail_unless( GO->getMetaId()      == "" );
  //    fail_unless( GO->getNotes()       == "" );
  //    fail_unless( GO->getAnnotation()  == "" );
  fail_unless( GO->getId()          == "" );
  fail_unless( !GO->isSetId());
  BoundingBox* bb=(GO->getBoundingBox());
  Point* pos=(bb->getPosition());
  Dimensions* dim=(bb->getDimensions());
  fail_unless(pos->getXOffset() == 0.0);
  fail_unless(pos->getYOffset() == 0.0);
  fail_unless(pos->getZOffset() == 0.0);
  fail_unless(dim->getWidth()  == 0.0);
  fail_unless(dim->getHeight() == 0.0);
  fail_unless(dim->getDepth()  == 0.0);
  
}
END_TEST

START_TEST (test_GraphicalObject_new_with_id)
{
  std::string id="TestGraphicalObject";
  GraphicalObject* go=new GraphicalObject(LN,id);
  fail_unless( go->getTypeCode()    == SBML_LAYOUT_GRAPHICALOBJECT );
  fail_unless( go->getMetaId()      == "" );
  //    fail_unless( go->getNotes()       == "" );
  //    fail_unless( go->getAnnotation() == "" );
  fail_unless( go->isSetId());
  fail_unless( go->getId() == id );
  
	BoundingBox* bb=(GO->getBoundingBox());
  Point* pos=(bb->getPosition());
  Dimensions* dim=(bb->getDimensions());
  fail_unless(pos->getXOffset() == 0.0);
  fail_unless(pos->getYOffset() == 0.0);
  fail_unless(pos->getZOffset() == 0.0);
  fail_unless(dim->getWidth()  == 0.0);
  fail_unless(dim->getHeight() == 0.0);
  fail_unless(dim->getDepth()  == 0.0);
  
  delete go;
}
END_TEST

START_TEST (test_GraphicalObject_new_with_id_and_2D_coordinates)
{
  std::string id="TestGraphicalObject";
  GraphicalObject* go=new GraphicalObject(LN,id,1.1,-2.2,3.3,-4.4);
  fail_unless( go->getTypeCode()    == SBML_LAYOUT_GRAPHICALOBJECT );
  fail_unless( go->getMetaId()      == "" );
  //    fail_unless( go->getNotes()       == "" );
  //    fail_unless( go->getAnnotation() == "" );
  fail_unless( go->isSetId());
  fail_unless( go->getId() == id );
  
	BoundingBox* bb=(go->getBoundingBox());
  Point* pos=(bb->getPosition());
  Dimensions* dim=(bb->getDimensions());
  fail_unless(pos->getXOffset() ==  1.1);
  fail_unless(pos->getYOffset() == -2.2);
  fail_unless(pos->getZOffset() ==  0.0);
  fail_unless(dim->getWidth()  ==  3.3);
  fail_unless(dim->getHeight() == -4.4);
  fail_unless(dim->getDepth()  ==  0.0);
  
  delete go;
}
END_TEST


START_TEST (test_GraphicalObject_new_with_id_and_3D_coordinates)
{
  std::string id="TestGraphicalObject";
  GraphicalObject* go=new GraphicalObject(LN,id,1.1,-2.2,3.3,-4.4,5.5,-6.6);
  fail_unless( go->getTypeCode()    == SBML_LAYOUT_GRAPHICALOBJECT );
  fail_unless( go->getMetaId()      == "" );
  //    fail_unless( go->getNotes()       == "" );
  //    fail_unless( go->getAnnotation() == "" );
  fail_unless( go->isSetId());
  fail_unless( go->getId() == id );
  
	BoundingBox* bb=(go->getBoundingBox());
  Point* pos=(bb->getPosition());
  Dimensions* dim=(bb->getDimensions());
  fail_unless(pos->getXOffset() ==  1.1);
  fail_unless(pos->getYOffset() == -2.2);
  fail_unless(pos->getZOffset() ==  3.3);
  fail_unless(dim->getWidth()  == -4.4);
  fail_unless(dim->getHeight() ==  5.5);
  fail_unless(dim->getDepth()  == -6.6);
  
  delete go;
  
}
END_TEST

START_TEST (test_GraphicalObject_new_with_id_point_and_dimensions)
{
  Point pos2=Point(LN,1.1,-2.2,3.3);
  Dimensions dim2=Dimensions(LN,-4.4,5.5,-6.6);
  std::string id="TestGraphicalObject";
  GraphicalObject* go=new GraphicalObject(LN,id,&pos2,&dim2);
  fail_unless( go->getTypeCode()    == SBML_LAYOUT_GRAPHICALOBJECT );
  fail_unless( go->getMetaId()      == "" );
  //    fail_unless( go->getNotes()       == "" );
  //    fail_unless( go->getAnnotation() == "" );
  fail_unless( go->isSetId());
  fail_unless( go->getId() == id );
  
	BoundingBox* bb=(go->getBoundingBox());
  Point* pos=(bb->getPosition());
  Dimensions* dim=(bb->getDimensions());
  fail_unless(pos->getXOffset() == pos2.getXOffset());
  fail_unless(pos->getYOffset() == pos2.getYOffset());
  fail_unless(pos->getZOffset() == pos2.getZOffset());
  fail_unless(dim->getWidth  () == dim2.getWidth  ());
  fail_unless(dim->getHeight () == dim2.getHeight ());
  fail_unless(dim->getDepth  () == dim2.getDepth  ());
  
  delete go;
}
END_TEST

START_TEST (test_GraphicalObject_new_with_id_and_boundingbox )
{
  BoundingBox bb2=BoundingBox(LN);
  Point pos2=Point(LN,1.1,-2.2,3.3);
  bb2.setPosition(&pos2);
  Dimensions dim2=Dimensions(LN,-4.4,5.5,-6.6);
  bb2.setDimensions(&dim2);
  std::string id="TestGraphicalObject";
  GraphicalObject* go=new GraphicalObject(LN,id,&bb2);
  fail_unless( go->getTypeCode()    == SBML_LAYOUT_GRAPHICALOBJECT );
  fail_unless( go->getMetaId()      == "" );
  //    fail_unless( go->getNotes()       == "" );
  //    fail_unless( go->getAnnotation() == "" );
  fail_unless( go->isSetId());
  fail_unless( go->getId() == id );
  
	BoundingBox* bb=(go->getBoundingBox());
  Point* pos=(bb->getPosition());
  Dimensions* dim=(bb->getDimensions());
  fail_unless(pos->getXOffset() == pos2.getXOffset());
  fail_unless(pos->getYOffset() == pos2.getYOffset());
  fail_unless(pos->getZOffset() == pos2.getZOffset());
  fail_unless(dim->getWidth()  == dim2.getWidth());
  fail_unless(dim->getHeight() == dim2.getHeight());
  fail_unless(dim->getDepth()  == dim2.getDepth());
  
  delete go;
  
}
END_TEST

START_TEST (test_GraphicalObject_setId )
{
  std::string id="TestGraphicalObject";
  GO->setId(id);
  fail_unless(GO->isSetId());
  fail_unless(GO->getId() == id);
}
END_TEST

START_TEST (test_GraphicalObject_setBoundingBox)
{
  BoundingBox bb2=BoundingBox(LN);
  Point* p=new Point(LN,1.1,-2.2,3.3);
  bb2.setPosition(p);
  delete p;
  Dimensions d=Dimensions(LN,-4.4,5.5,-6.6);
  bb2.setDimensions(&d);
  GO->setBoundingBox(&bb2);
	BoundingBox* bb=(GO->getBoundingBox());
  
  fail_unless(bb->getPosition()->getXOffset() == bb2.getPosition()->getXOffset());
  fail_unless(bb->getPosition()->getYOffset() == bb2.getPosition()->getYOffset());
  fail_unless(bb->getPosition()->getZOffset() == bb2.getPosition()->getZOffset());
  fail_unless(bb->getDimensions()->getWidth() == bb2.getDimensions()->getWidth());
  fail_unless(bb->getDimensions()->getHeight() == bb2.getDimensions()->getHeight());
  fail_unless(bb->getDimensions()->getDepth() == bb2.getDimensions()->getDepth());
}
END_TEST

START_TEST ( test_GraphicalObject_copyConstructor )
{
  GraphicalObject* go1=new GraphicalObject();
  XMLNode* notes=new XMLNode();
  go1->setNotes(notes);
  XMLNode* annotation=new XMLNode();
  go1->setAnnotation(annotation);
  GraphicalObject* go2=new GraphicalObject(*go1);
  delete go2;
  delete go1;
}
END_TEST

START_TEST ( test_GraphicalObject_assignmentOperator )
{
  GraphicalObject* go1=new GraphicalObject();
  XMLNode* notes=new XMLNode();
  go1->setNotes(notes);
  XMLNode* annotation=new XMLNode();
  go1->setAnnotation(annotation);
  GraphicalObject* go2=new GraphicalObject();
  (*go2)=(*go1);
  delete go2;
  delete go1;
}
END_TEST

START_TEST ( test_GraphicalObject_metaidRef)
{
  GraphicalObject* go1=new GraphicalObject();
  
  fail_unless(go1->isSetMetaIdRef() == false);
  fail_unless(go1->setMetaIdRef("meta1") == LIBSBML_OPERATION_SUCCESS);
  fail_unless(go1->isSetMetaIdRef() == true);
  fail_unless(go1->getMetaIdRef() == "meta1");
  fail_unless(go1->unsetMetaIdRef() == LIBSBML_OPERATION_SUCCESS);
  fail_unless(go1->isSetMetaIdRef() == false);
  
  fail_unless(go1->isSetId() == false);
  fail_unless(go1->setId("id1") == LIBSBML_OPERATION_SUCCESS);
  fail_unless(go1->isSetId() == true);
  fail_unless(go1->getId() == "id1");
  fail_unless(go1->setMetaIdRef("meta2") == LIBSBML_OPERATION_SUCCESS);
  fail_unless(go1->isSetMetaIdRef() == true);
  fail_unless(go1->getMetaIdRef() == "meta2");
  fail_unless(go1->getId() == "id1");
  
  delete go1;
}
END_TEST


START_TEST ( test_GeneralGlyph_new )
{
  
  GeneralGlyph glyph;
  glyph.setId("g1");
  fail_unless(glyph.getId() == "g1");
  
  glyph.setReferenceId("sbmlId");
  
  ReferenceGlyph r2;
  r2.setId("rg1");
  r2.setRole("target");
  r2.setReferenceId("species1");
  
  fail_unless(glyph.getNumReferenceGlyphs() == 0);
  
  glyph.addReferenceGlyph(&r2);
  
  fail_unless(glyph.getNumReferenceGlyphs() == 1);
  
  fail_unless(glyph.getNumSubGlyphs() == 0);
  
  TextGlyph text;
  
  text.setId("text1");
  text.setText("Some text ...");
  
  glyph.addSubGlyph(&text);
  
  fail_unless(glyph.getNumSubGlyphs() == 1);
  
  std::string result = glyph.toSBML();
  XMLNode node = glyph.toXML();
  GeneralGlyph fromXml(node);
  std::string read = fromXml.toSBML();
  
  fail_unless(result == read);
  
  // deletion
  ReferenceGlyph* temp = glyph.removeReferenceGlyph(0);
  
  fail_unless(glyph.getNumReferenceGlyphs() == 0);
  
  std::string ref1 = temp->toSBML();
  std::string ref2 = r2.toSBML();
  
  fail_unless(ref1 == ref2);
  delete temp;
  
  TextGlyph *temp1 = (TextGlyph*)glyph.removeSubGlyph("text1");
  
  fail_unless(temp1 != NULL);
  fail_unless(glyph.getNumSubGlyphs() == 0);
  
  std::string sub1 = temp1->toSBML();
  std::string sub2 = text.toSBML();
  
  fail_unless( sub1 == sub2 );
  delete temp1;
  
}
END_TEST

START_TEST(test_GraphicalObject_readL2FileWithRenderAnnotation)
{
  std::string  fileName(TestDataDirectory);
  fileName += "/l2-with-render.xml";

  SBMLDocument* doc = readSBMLFromFile(fileName.c_str());

  fail_unless(doc->getModel() != NULL);

  LayoutModelPlugin* plug = static_cast<LayoutModelPlugin*>(doc->getModel()->getPlugin("layout"));

  fail_unless(plug != NULL);

  SpeciesGlyph* importantGlyph = plug->getLayout(0)->getSpeciesGlyph(0);

  fail_unless(importantGlyph != NULL);

#if !LIBSBML_HAS_PACKAGE_RENDER

  fail_unless(doc->getErrorLog()->getNumErrors() == 0);

  char* xml = importantGlyph->toSBML();

  fail_unless(xml != NULL);

  free(xml);

  char* saved = writeSBMLToString(doc);

  delete doc;
  doc = readSBMLFromString(saved);
  fail_unless(doc->getModel() != NULL);
  fail_unless(doc->getErrorLog()->getNumErrors() == 0);

#endif

  delete doc;
}
END_TEST

Suite *
create_suite_GraphicalObject (void)
{
  Suite *suite = suite_create("GraphicalObject");
  TCase *tcase = tcase_create("GraphicalObject");
  
  tcase_add_checked_fixture( tcase,
                            GraphicalObjectTest_setup,
                            GraphicalObjectTest_teardown );
  
  tcase_add_test( tcase, test_GraphicalObject_new                              );
  tcase_add_test( tcase, test_GeneralGlyph_new                                 );
  tcase_add_test( tcase, test_GraphicalObject_new_with_id                      );
  tcase_add_test( tcase, test_GraphicalObject_new_with_id_and_2D_coordinates   );
  tcase_add_test( tcase, test_GraphicalObject_new_with_id_and_3D_coordinates   );
  tcase_add_test( tcase, test_GraphicalObject_new_with_id_point_and_dimensions );
  tcase_add_test( tcase, test_GraphicalObject_new_with_id_and_boundingbox      );
  tcase_add_test( tcase, test_GraphicalObject_setId                            );
  tcase_add_test( tcase, test_GraphicalObject_metaidRef                        );
  tcase_add_test( tcase, test_GraphicalObject_setBoundingBox                   );
  tcase_add_test( tcase, test_GraphicalObject_copyConstructor                  );
  tcase_add_test( tcase, test_GraphicalObject_assignmentOperator               );
  tcase_add_test( tcase, test_GraphicalObject_readL2FileWithRenderAnnotation   );
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}



END_C_DECLS
