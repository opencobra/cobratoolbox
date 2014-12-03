/**
 * Filename    : TestLayout.cpp
 * Description : Unit tests for Layout
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

#include <sbml/common/common.h>
#include <sbml/common/extern.h>

#include <sbml/packages/layout/sbml/Layout.h>
#include <sbml/packages/layout/sbml/GraphicalObject.h>
#include <sbml/packages/layout/sbml/GeneralGlyph.h>
#include <sbml/packages/layout/sbml/CompartmentGlyph.h>
#include <sbml/packages/layout/sbml/SpeciesGlyph.h>
#include <sbml/packages/layout/sbml/ReactionGlyph.h>
#include <sbml/packages/layout/sbml/TextGlyph.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static Layout * L;
static LayoutPkgNamespaces* LN;

void
LayoutTest_setup (void)
{
  LN = new LayoutPkgNamespaces();
  L = new (std::nothrow) Layout(LN);
  
  if (L == NULL)
  {
    fail("new(std::nothrow) Layout() returned a NULL pointer.");
  }
  
}

void
LayoutTest_teardown (void)
{
  delete L;
  delete LN;
}

START_TEST ( test_Layout_new )
{
  fail_unless( L->getTypeCode()    == SBML_LAYOUT_LAYOUT );
  fail_unless( L->getMetaId()      == "" );
  //    fail_unless( L->getNotes()       == "" );
  //    fail_unless( L->getAnnotation()  == "" );
  fail_unless( L->getId()          == "" );
  fail_unless( !L->isSetId());
  Dimensions* dim=(L->getDimensions());
  fail_unless (dim->getWidth()  == 0.0 );
  fail_unless (dim->getHeight() == 0.0 );
  fail_unless (dim->getDepth()  == 0.0 );
  
  fail_unless ( L->getNumCompartmentGlyphs()         == 0 );
  fail_unless ( L->getNumSpeciesGlyphs()             == 0 );
  fail_unless ( L->getNumReactionGlyphs()            == 0 );
  fail_unless ( L->getNumTextGlyphs()                == 0 );
  fail_unless ( L->getNumAdditionalGraphicalObjects() == 0 );
}
END_TEST

START_TEST ( test_Layout_new_with_id_and_dimensions )
{
  std::string id="TestLayoutId";
  Dimensions dimensions=Dimensions(LN,-1.1,2.2,3.3);
  Layout* l=new Layout(LN,id,&dimensions);
  fail_unless( l->getTypeCode()    == SBML_LAYOUT_LAYOUT );
  fail_unless( l->getMetaId()      == "" );
  //    fail_unless( l->getNotes()       == "" );
  //    fail_unless( l->getAnnotation()  == "" );
  fail_unless( l->getId()          == id );
  fail_unless( l->isSetId());
  Dimensions* dim=(l->getDimensions());
  fail_unless (dim->getWidth()  == dimensions.getWidth() );
  fail_unless (dim->getHeight() == dimensions.getHeight() );
  fail_unless (dim->getDepth()  == dimensions.getDepth() );
  
  fail_unless ( l->getNumCompartmentGlyphs()         == 0 );
  fail_unless ( l->getNumSpeciesGlyphs()             == 0 );
  fail_unless ( l->getNumReactionGlyphs()            == 0 );
  fail_unless ( l->getNumTextGlyphs()                == 0 );
  fail_unless ( l->getNumAdditionalGraphicalObjects() == 0 );
  delete l;
}
END_TEST

START_TEST ( test_Layout_setId )
{
  std::string id="TestLayoutId";
  L->setId(id);
  fail_unless(L->isSetId());
  fail_unless(L->getId() == id);
}
END_TEST

START_TEST ( test_Layout_setDimensions )
{
  Dimensions dimensions=Dimensions(LN,-1.1,2.2,-3.3);
  L->setDimensions(&dimensions);
  Dimensions* dim=(L->getDimensions());
  fail_unless(dim->getWidth()  == dimensions.getWidth());
  fail_unless(dim->getHeight() == dimensions.getHeight());
  fail_unless(dim->getDepth()  == dimensions.getDepth());
}
END_TEST

START_TEST ( test_Layout_addCompartmentGlyph )
{
  CompartmentGlyph* cg=new CompartmentGlyph();
  L->addCompartmentGlyph(cg);
  fail_unless ( L->getNumCompartmentGlyphs() == 1 );
  delete cg;
}
END_TEST

START_TEST ( test_Layout_addSpeciesGlyph )
{
  SpeciesGlyph* sg=new SpeciesGlyph();
  L->addSpeciesGlyph(sg);
  fail_unless ( L->getNumSpeciesGlyphs() == 1 );
  delete sg;
}
END_TEST

START_TEST ( test_Layout_addReactionGlyph )
{
  ReactionGlyph* rg=new ReactionGlyph();
  L->addReactionGlyph(rg);
  fail_unless ( L->getNumReactionGlyphs() == 1 );
  
  delete rg;
}
END_TEST

START_TEST ( test_Layout_addTextGlyph )
{
  TextGlyph* tg=new TextGlyph();
  L->addTextGlyph(tg);
  fail_unless ( L->getNumTextGlyphs() == 1 );
  
  delete tg;
}
END_TEST

START_TEST ( test_Layout_addAdditionalGraphicalObject )
{
  GraphicalObject* ago=new GraphicalObject();
  L->addAdditionalGraphicalObject(ago);
  fail_unless ( L->getNumAdditionalGraphicalObjects() == 1 );
  delete ago;
}
END_TEST


START_TEST ( test_Layout_addGeneralGlyph )
{
  GeneralGlyph* ago=new GeneralGlyph();
  L->addGeneralGlyph(ago);
  fail_unless ( L->getNumGeneralGlyphs() == 1 );
  delete ago;
}
END_TEST

START_TEST ( test_Layout_getNumCompartmentGlyphs )
{
  std::string id1="TestCompartment_1";
  std::string id2="TestCompartment_2";
  std::string id3="TestCompartment_3";
  std::string id4="TestCompartment_4";
  std::string id5="TestCompartment_5";
  CompartmentGlyph* cg1=new CompartmentGlyph(LN,id1);
  CompartmentGlyph* cg2=new CompartmentGlyph(LN,id2);
  CompartmentGlyph* cg3=new CompartmentGlyph(LN,id3);
  CompartmentGlyph* cg4=new CompartmentGlyph(LN,id4);
  CompartmentGlyph* cg5=new CompartmentGlyph(LN,id5);
  L->addCompartmentGlyph(cg1);
  L->addCompartmentGlyph(cg2);
  L->addCompartmentGlyph(cg3);
  L->addCompartmentGlyph(cg4);
  L->addCompartmentGlyph(cg5);
  fail_unless( L->getNumCompartmentGlyphs() == 5);
  delete cg1;
  delete cg2;
  delete cg3;
  delete cg4;
  delete cg5;
}
END_TEST

START_TEST ( test_Layout_getNumGeneralGlyphs )
{
  GeneralGlyph* cg1=new GeneralGlyph(LN);
  GeneralGlyph* cg2=new GeneralGlyph(LN);
  GeneralGlyph* cg3=new GeneralGlyph(LN);
  GeneralGlyph* cg4=new GeneralGlyph(LN);
  GeneralGlyph* cg5=new GeneralGlyph(LN);
  L->addGeneralGlyph(cg1);
  L->addGeneralGlyph(cg2);
  L->addGeneralGlyph(cg3);
  L->addGeneralGlyph(cg4);
  L->addGeneralGlyph(cg5);
  fail_unless( L->getNumGeneralGlyphs() == 5);
  delete cg1;
  delete cg2;
  delete cg3;
  delete cg4;
  delete cg5;
}
END_TEST

START_TEST ( test_Layout_getNumSpeciesGlyphs )
{
  std::string id1="TestSpecies_1";
  std::string id2="TestSpecies_2";
  std::string id3="TestSpecies_3";
  std::string id4="TestSpecies_4";
  std::string id5="TestSpecies_5";
  SpeciesGlyph* sg1=new SpeciesGlyph(LN,id1);
  SpeciesGlyph* sg2=new SpeciesGlyph(LN,id2);
  SpeciesGlyph* sg3=new SpeciesGlyph(LN,id3);
  SpeciesGlyph* sg4=new SpeciesGlyph(LN,id4);
  SpeciesGlyph* sg5=new SpeciesGlyph(LN,id5);
  L->addSpeciesGlyph(sg1);
  L->addSpeciesGlyph(sg2);
  L->addSpeciesGlyph(sg3);
  L->addSpeciesGlyph(sg4);
  L->addSpeciesGlyph(sg5);
  fail_unless( L->getNumSpeciesGlyphs() == 5);
  delete sg1;
  delete sg2;
  delete sg3;
  delete sg4;
  delete sg5;
}
END_TEST


START_TEST ( test_Layout_getNumReactionGlyphs )
{
  std::string id1="TestReaction_1";
  std::string id2="TestReaction_2";
  std::string id3="TestReaction_3";
  std::string id4="TestReaction_4";
  std::string id5="TestReaction_5";
  ReactionGlyph* rg1=new ReactionGlyph(LN,id1);
  ReactionGlyph* rg2=new ReactionGlyph(LN,id2);
  ReactionGlyph* rg3=new ReactionGlyph(LN,id3);
  ReactionGlyph* rg4=new ReactionGlyph(LN,id4);
  ReactionGlyph* rg5=new ReactionGlyph(LN,id5);
  L->addReactionGlyph(rg1);
  L->addReactionGlyph(rg2);
  L->addReactionGlyph(rg3);
  L->addReactionGlyph(rg4);
  L->addReactionGlyph(rg5);
  fail_unless( L->getNumReactionGlyphs() == 5);
  delete rg1;
  delete rg2;
  delete rg3;
  delete rg4;
  delete rg5;
}
END_TEST


START_TEST ( test_Layout_getNumTextGlyphs )
{
  std::string id1="TestText_1";
  std::string id2="TestText_2";
  std::string id3="TestText_3";
  std::string id4="TestText_4";
  std::string id5="TestText_5";
  TextGlyph* tg1=new TextGlyph(LN,id1);
  TextGlyph* tg2=new TextGlyph(LN,id2);
  TextGlyph* tg3=new TextGlyph(LN,id3);
  TextGlyph* tg4=new TextGlyph(LN,id4);
  TextGlyph* tg5=new TextGlyph(LN,id5);
  L->addTextGlyph(tg1);
  L->addTextGlyph(tg2);
  L->addTextGlyph(tg3);
  L->addTextGlyph(tg4);
  L->addTextGlyph(tg5);
  fail_unless( L->getNumTextGlyphs() == 5);
  delete tg1;
  delete tg2;
  delete tg3;
  delete tg4;
  delete tg5;
}
END_TEST


START_TEST ( test_Layout_getNumAdditionalGraphicalObjects )
{
  std::string id1="TestGraphicalObject_1";
  std::string id2="TestGraphicalObject_2";
  std::string id3="TestGraphicalObject_3";
  std::string id4="TestGraphicalObject_4";
  std::string id5="TestGraphicalObject_5";
  GraphicalObject* go1=new GraphicalObject(LN,id1);
  GraphicalObject* go2=new GraphicalObject(LN,id2);
  GraphicalObject* go3=new GraphicalObject(LN,id3);
  GraphicalObject* go4=new GraphicalObject(LN,id4);
  GraphicalObject* go5=new GraphicalObject(LN,id5);
  L->addAdditionalGraphicalObject(go1);
  L->addAdditionalGraphicalObject(go2);
  L->addAdditionalGraphicalObject(go3);
  L->addAdditionalGraphicalObject(go4);
  L->addAdditionalGraphicalObject(go5);
  fail_unless( L->getNumAdditionalGraphicalObjects() == 5);
  delete go1;
  delete go2;
  delete go3;
  delete go4;
  delete go5;
}
END_TEST

START_TEST ( test_Layout_createCompartmentGlyph )
{
  L->createCompartmentGlyph();
  L->createCompartmentGlyph();
  L->createCompartmentGlyph();
  fail_unless ( L->getNumCompartmentGlyphs() == 3 );
}
END_TEST

START_TEST ( test_Layout_createSpeciesGlyph )
{
  L->createSpeciesGlyph();
  L->createSpeciesGlyph();
  L->createSpeciesGlyph();
  fail_unless ( L->getNumSpeciesGlyphs() == 3 );
}
END_TEST


START_TEST ( test_Layout_createReactionGlyph )
{
  L->createReactionGlyph();
  L->createReactionGlyph();
  L->createReactionGlyph();
  fail_unless ( L->getNumReactionGlyphs() == 3 );
}
END_TEST


START_TEST ( test_Layout_createTextGlyph )
{
  L->createTextGlyph();
  L->createTextGlyph();
  L->createTextGlyph();
  fail_unless ( L->getNumTextGlyphs() == 3 );
}
END_TEST


START_TEST ( test_Layout_createGeneralGlyph )
{
  L->createGeneralGlyph();
  L->createGeneralGlyph();
  L->createGeneralGlyph();
  fail_unless ( L->getNumGeneralGlyphs() == 3 );
}
END_TEST

START_TEST ( test_Layout_createAdditionalGraphicalObject )
{
  L->createAdditionalGraphicalObject();
  L->createAdditionalGraphicalObject();
  L->createAdditionalGraphicalObject();
  fail_unless ( L->getNumAdditionalGraphicalObjects() == 3 );
}
END_TEST


START_TEST ( test_Layout_createSpeciesReferenceGlyph )
{
  SpeciesReferenceGlyph* srg=L->createSpeciesReferenceGlyph();
  fail_unless(srg == NULL);
  L->createReactionGlyph();
  srg=L->createSpeciesReferenceGlyph();
  fail_unless(srg != NULL);
}
END_TEST


START_TEST ( test_Layout_createLineSegment )
{
  LineSegment* ls=L->createLineSegment();
  fail_unless(ls == NULL);
  L->createReactionGlyph();
  ls=L->createLineSegment();
  fail_unless(ls != NULL);
  L->createSpeciesReferenceGlyph();
  ls=L->createLineSegment();
  fail_unless ( ls != NULL );
  ReactionGlyph* rg=L->getReactionGlyph(0);
  fail_unless( rg->getCurve()->getNumCurveSegments() == 1);
  fail_unless( rg->getSpeciesReferenceGlyph(0)->getCurve()->getNumCurveSegments() == 1);
}
END_TEST


START_TEST ( test_Layout_createCubicBezier )
{
  CubicBezier* cb=L->createCubicBezier();
  fail_unless(cb == NULL);
  L->createReactionGlyph();
  cb=L->createCubicBezier();
  fail_unless(cb != NULL);
  L->createSpeciesReferenceGlyph();
  cb=L->createCubicBezier();
  fail_unless ( cb != NULL );
  ReactionGlyph* rg=L->getReactionGlyph(0);
  fail_unless( rg->getCurve()->getNumCurveSegments() == 1);
  fail_unless( rg->getSpeciesReferenceGlyph(0)->getCurve()->getNumCurveSegments() == 1);
}
END_TEST



START_TEST ( test_Layout_copyConstructor )
{
  Layout* l1=new Layout();
  XMLNode* notes=new XMLNode();
  l1->setNotes(notes);
  XMLNode* annotation=new XMLNode();
  l1->setAnnotation(annotation);
  GraphicalObject* go=l1->createCompartmentGlyph();
  go->setId("go1");
  go=l1->createCompartmentGlyph();
  go->setId("go2");
  go=l1->createCompartmentGlyph();
  go->setId("go3");
  go=l1->createSpeciesGlyph();
  go->setId("go4");
  go=l1->createSpeciesGlyph();
  go->setId("go5");
  go=l1->createSpeciesGlyph();
  go->setId("go6");
  go=l1->createSpeciesGlyph();
  go->setId("go7");
  go=l1->createSpeciesGlyph();
  go->setId("go8");
  go=l1->createSpeciesGlyph();
  go->setId("go9");
  go=l1->createSpeciesGlyph();
  go->setId("go10");
  go=l1->createReactionGlyph();
  go->setId("go11");
  go=l1->createReactionGlyph();
  go->setId("go12");
  go=l1->createReactionGlyph();
  go->setId("go13");
  go=l1->createReactionGlyph();
  go->setId("go14");
  go=l1->createReactionGlyph();
  go->setId("go15");
  go=l1->createReactionGlyph();
  go->setId("go16");
  go=l1->createReactionGlyph();
  go->setId("go17");
  go=l1->createReactionGlyph();
  go->setId("go18");
  go=l1->createTextGlyph();
  go->setId("go19");
  go=l1->createTextGlyph();
  go->setId("go20");
  go=l1->createTextGlyph();
  go->setId("go21");
  go=l1->createAdditionalGraphicalObject();
  go->setId("go22");
  go=l1->createAdditionalGraphicalObject();
  go->setId("go23");
  go=l1->createAdditionalGraphicalObject();
  go->setId("go24");
  go=l1->createAdditionalGraphicalObject();
  go->setId("go25");
  Layout* l2=new Layout(*l1);
  delete l2;
  delete l1;
}
END_TEST

START_TEST ( test_Layout_assignmentOperator )
{
  Layout* l1=new Layout();
  XMLNode* notes=new XMLNode();
  l1->setNotes(notes);
  XMLNode* annotation=new XMLNode();
  l1->setAnnotation(annotation);
  GraphicalObject* go=l1->createCompartmentGlyph();
  go->setId("go1");
  go=l1->createCompartmentGlyph();
  go->setId("go2");
  go=l1->createCompartmentGlyph();
  go->setId("go3");
  go=l1->createSpeciesGlyph();
  go->setId("go4");
  go=l1->createSpeciesGlyph();
  go->setId("go5");
  go=l1->createSpeciesGlyph();
  go->setId("go6");
  go=l1->createSpeciesGlyph();
  go->setId("go7");
  go=l1->createSpeciesGlyph();
  go->setId("go8");
  go=l1->createSpeciesGlyph();
  go->setId("go9");
  go=l1->createSpeciesGlyph();
  go->setId("go10");
  go=l1->createReactionGlyph();
  go->setId("go11");
  go=l1->createReactionGlyph();
  go->setId("go12");
  go=l1->createReactionGlyph();
  go->setId("go13");
  go=l1->createReactionGlyph();
  go->setId("go14");
  go=l1->createReactionGlyph();
  go->setId("go15");
  go=l1->createReactionGlyph();
  go->setId("go16");
  go=l1->createReactionGlyph();
  go->setId("go17");
  go=l1->createReactionGlyph();
  go->setId("go18");
  go=l1->createTextGlyph();
  go->setId("go19");
  go=l1->createTextGlyph();
  go->setId("go20");
  go=l1->createTextGlyph();
  go->setId("go21");
  go=l1->createAdditionalGraphicalObject();
  go->setId("go22");
  go=l1->createAdditionalGraphicalObject();
  go->setId("go23");
  go=l1->createAdditionalGraphicalObject();
  go->setId("go24");
  go=l1->createAdditionalGraphicalObject();
  go->setId("go25");
  Layout* l2=new Layout();
  (*l2)=(*l1);
  delete l2;
  delete l1;
}
END_TEST


Suite *
create_suite_Layout (void)
{
  Suite *suite = suite_create("Layout");
  TCase *tcase = tcase_create("Layout");
  
  tcase_add_checked_fixture( tcase,
                            LayoutTest_setup,
                            LayoutTest_teardown );
  
  tcase_add_test ( tcase , test_Layout_new                              );
  tcase_add_test ( tcase , test_Layout_new_with_id_and_dimensions       );
  tcase_add_test ( tcase , test_Layout_setId                            );
  tcase_add_test ( tcase , test_Layout_setDimensions                    );
  tcase_add_test ( tcase , test_Layout_addCompartmentGlyph              );
  tcase_add_test ( tcase , test_Layout_addSpeciesGlyph                  );
  tcase_add_test ( tcase , test_Layout_addGeneralGlyph                  );
  tcase_add_test ( tcase , test_Layout_addReactionGlyph                 );
  tcase_add_test ( tcase , test_Layout_addTextGlyph                     );
  tcase_add_test ( tcase , test_Layout_addAdditionalGraphicalObject     );
  tcase_add_test ( tcase , test_Layout_createCompartmentGlyph           );
  tcase_add_test ( tcase , test_Layout_createSpeciesGlyph               );
  tcase_add_test ( tcase , test_Layout_createGeneralGlyph               );
  tcase_add_test ( tcase , test_Layout_createReactionGlyph              );
  tcase_add_test ( tcase , test_Layout_createTextGlyph                  );
  tcase_add_test ( tcase , test_Layout_createAdditionalGraphicalObject  );
  tcase_add_test ( tcase , test_Layout_createSpeciesReferenceGlyph      );
  tcase_add_test ( tcase , test_Layout_createLineSegment                );
  tcase_add_test ( tcase , test_Layout_createCubicBezier                );
  tcase_add_test ( tcase , test_Layout_getNumCompartmentGlyphs          );
  tcase_add_test ( tcase , test_Layout_getNumGeneralGlyphs              );
  tcase_add_test ( tcase , test_Layout_getNumSpeciesGlyphs              );
  tcase_add_test ( tcase , test_Layout_getNumReactionGlyphs             );
  tcase_add_test ( tcase , test_Layout_getNumTextGlyphs                 );
  tcase_add_test ( tcase , test_Layout_getNumAdditionalGraphicalObjects );
  tcase_add_test(  tcase , test_Layout_copyConstructor                  );
  tcase_add_test(  tcase , test_Layout_assignmentOperator               );
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}



END_C_DECLS
