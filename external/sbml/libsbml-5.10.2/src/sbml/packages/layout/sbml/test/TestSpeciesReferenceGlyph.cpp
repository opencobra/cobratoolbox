/**
 * Filename    : TestSpeciesReferenceGlyph.cpp
 * Description : Unit tests for SpeciesReferenceGlyph
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

#include <sbml/packages/layout/sbml/SpeciesReferenceGlyph.h>
#include <sbml/packages/layout/sbml/LineSegment.h>
#include <sbml/packages/layout/sbml/CubicBezier.h>
#include <sbml/packages/layout/sbml/Curve.h>
#include <sbml/packages/layout/sbml/Point.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static SpeciesReferenceGlyph * SRG;
static LayoutPkgNamespaces* LN;

void
SpeciesReferenceGlyphTest_setup (void)
{
  LN = new LayoutPkgNamespaces();
  SRG = new (std::nothrow) SpeciesReferenceGlyph(LN);
  
  if (SRG == NULL)
  {
    fail("new(std::nothrow) SpeciesReferenceGlyph() returned a NULL pointer.");
  }
  
}

void
SpeciesReferenceGlyphTest_teardown (void)
{
  delete SRG;
  delete LN;
}

START_TEST (test_SpeciesReferenceGlyph_new )
{
  fail_unless( SRG->getTypeCode()   == SBML_LAYOUT_SPECIESREFERENCEGLYPH );
  fail_unless( SRG->getMetaId()     == "" );
  //   fail_unless( SRG->getNotes()      == "" );
  //   fail_unless( SRG->getAnnotation() == "" );
  
  fail_unless( !SRG->isSetId() );
  fail_unless( !SRG->isSetSpeciesReferenceId() );
  fail_unless( !SRG->isSetSpeciesGlyphId() );
  fail_unless( !SRG->isSetRole() );
  fail_unless( SRG->getRole() == SPECIES_ROLE_UNDEFINED );
  fail_unless( SRG->getCurve() != NULL);
  fail_unless( !SRG->isSetCurve());
}
END_TEST

START_TEST (test_SpeciesReferenceGlyph_new_with_data)
{
  std::string sid="TestSpeciesReferenceGlyph";
  std::string glyphId="TestSpeciesGlyph";
  std::string referenceId="TestSpeciesReference";
  SpeciesReferenceGlyph* srg=new SpeciesReferenceGlyph( LN, sid,
                                                       glyphId,
                                                       referenceId,
                                                       SPECIES_ROLE_SUBSTRATE
                                                       );
  
  fail_unless( srg->getTypeCode()   == SBML_LAYOUT_SPECIESREFERENCEGLYPH );
  fail_unless( srg->getMetaId()     == "" );
  //   fail_unless( srg->getNotes()      == "" );
  //   fail_unless( srg->getAnnotation() == "" );
  
  fail_unless( srg->isSetId() );
  fail_unless( srg->getId() == sid);
  fail_unless( srg->isSetSpeciesReferenceId() );
  fail_unless( srg->getSpeciesReferenceId() == referenceId);
  fail_unless( srg->isSetSpeciesGlyphId() );
  fail_unless( srg->getSpeciesGlyphId() == glyphId);
  fail_unless( srg->isSetRole());
  fail_unless( srg->getRole() == SPECIES_ROLE_SUBSTRATE );
  fail_unless( srg->getCurve() != NULL);
  fail_unless( !srg->isSetCurve());
  
  delete srg;
}
END_TEST

START_TEST (test_SpeciesReferenceGlyph_setSpeciesGlyphId)
{
  std::string glyphId="TestSpeciesGlyph";
  SRG->setSpeciesGlyphId(glyphId);
  fail_unless(SRG->isSetSpeciesGlyphId());
  fail_unless(SRG->getSpeciesGlyphId() == glyphId);
  SRG->setSpeciesGlyphId("");
  fail_unless(!SRG->isSetSpeciesGlyphId());
}
END_TEST

START_TEST (test_SpeciesReferenceGlyph_setSpeciesReferenceId)
{
  std::string referenceId="TestSpeciesReference";
  SRG->setSpeciesReferenceId(referenceId);
  fail_unless(SRG->isSetSpeciesReferenceId());
  fail_unless(SRG->getSpeciesReferenceId() == referenceId);
  SRG->setSpeciesReferenceId("");
  fail_unless(!SRG->isSetSpeciesReferenceId());
}
END_TEST

START_TEST (test_SpeciesReferenceGlyph_setRole)
{
  SRG->setRole(SPECIES_ROLE_MODIFIER);
  fail_unless(SRG->isSetRole());
  fail_unless(SRG->getRole() == SPECIES_ROLE_MODIFIER);
}
END_TEST

START_TEST (test_SpeciesReferenceGlyph_setRole_by_string)
{
  SRG->setRole("undefined");
  fail_unless(SRG->getRole()==SPECIES_ROLE_UNDEFINED);
  SRG->setRole("substrate");
  fail_unless(SRG->getRole()==SPECIES_ROLE_SUBSTRATE);
  SRG->setRole("product");
  fail_unless(SRG->getRole()==SPECIES_ROLE_PRODUCT);
  SRG->setRole("sidesubstrate");
  fail_unless(SRG->getRole()==SPECIES_ROLE_SIDESUBSTRATE);
  SRG->setRole("sideproduct");
  fail_unless(SRG->getRole()==SPECIES_ROLE_SIDEPRODUCT);
  SRG->setRole("modifier");
  fail_unless(SRG->getRole()==SPECIES_ROLE_MODIFIER);
  SRG->setRole("activator");
  fail_unless(SRG->getRole()==SPECIES_ROLE_ACTIVATOR);
  SRG->setRole("inhibitor");
  fail_unless(SRG->getRole()==SPECIES_ROLE_INHIBITOR);
  SRG->setRole("test");
  fail_unless(SRG->getRole()==SPECIES_ROLE_UNDEFINED);
}
END_TEST

START_TEST ( test_SpeciesReferenceGlyph_getRoleString )
{
  SRG->setRole(SPECIES_ROLE_UNDEFINED);
  fail_unless(SRG->getRoleString() == "undefined");
  SRG->setRole(SPECIES_ROLE_SUBSTRATE);
  fail_unless(SRG->getRoleString() == "substrate");
  SRG->setRole(SPECIES_ROLE_PRODUCT);
  fail_unless(SRG->getRoleString() == "product");
  SRG->setRole(SPECIES_ROLE_SIDESUBSTRATE);
  fail_unless(SRG->getRoleString() == "sidesubstrate");
  SRG->setRole(SPECIES_ROLE_SIDEPRODUCT);
  fail_unless(SRG->getRoleString() == "sideproduct");
  SRG->setRole(SPECIES_ROLE_MODIFIER);
  fail_unless(SRG->getRoleString() == "modifier");
  SRG->setRole(SPECIES_ROLE_ACTIVATOR);
  fail_unless(SRG->getRoleString() == "activator");
  SRG->setRole(SPECIES_ROLE_INHIBITOR);
  fail_unless(SRG->getRoleString() == "inhibitor");
}
END_TEST

START_TEST (test_SpeciesReferenceGlyph_setCurve)
{
  Curve* c=new Curve();
  LineSegment* ls=new LineSegment();
  c->addCurveSegment(ls);
  delete ls;
  ls=new LineSegment();
  c->addCurveSegment(ls);
  delete ls;
  SRG->setCurve(c);
  fail_unless(SRG->isSetCurve());
  fail_unless(SRG->getCurve()->getNumCurveSegments() == 2);
  delete c;
}
END_TEST

START_TEST (test_SpeciesReferenceGlyph_setCurve_NULL)
{
  SRG->setCurve(NULL);
  fail_unless(!SRG->isSetCurve());
  fail_unless(SRG->getCurve() != NULL);
}
END_TEST

START_TEST (test_SpeciesReferenceGlyph_createLineSegment)
{
  LineSegment* ls=SRG->createLineSegment();
  fail_unless(SRG->isSetCurve());
  Point* p=ls->getStart();
  fail_unless(p->getXOffset() == 0.0);
  fail_unless(p->getYOffset() == 0.0);
  fail_unless(p->getZOffset() == 0.0);
  p=ls->getEnd();
  fail_unless(p->getXOffset() == 0.0);
  fail_unless(p->getYOffset() == 0.0);
  fail_unless(p->getZOffset() == 0.0);
}
END_TEST

START_TEST (test_SpeciesReferenceGlyph_createCubicBezier)
{
  CubicBezier* cb=SRG->createCubicBezier();
  fail_unless(SRG->isSetCurve());
  Point* p=cb->getStart();
  fail_unless(p->getXOffset() == 0.0);
  fail_unless(p->getYOffset() == 0.0);
  fail_unless(p->getZOffset() == 0.0);
  p=cb->getBasePoint1();
  fail_unless(p->getXOffset() == 0.0);
  fail_unless(p->getYOffset() == 0.0);
  fail_unless(p->getZOffset() == 0.0);
  p=cb->getBasePoint2();
  fail_unless(p->getXOffset() == 0.0);
  fail_unless(p->getYOffset() == 0.0);
  fail_unless(p->getZOffset() == 0.0);
  p=cb->getEnd();
  fail_unless(p->getXOffset() == 0.0);
  fail_unless(p->getYOffset() == 0.0);
  fail_unless(p->getZOffset() == 0.0);
}
END_TEST

START_TEST ( test_SpeciesReferenceGlyph_copyConstructor )
{
  SpeciesReferenceGlyph* srg1=new SpeciesReferenceGlyph();
  XMLNode* notes=new XMLNode();
  srg1->setNotes(notes);
  XMLNode* annotation=new XMLNode();
  srg1->setAnnotation(annotation);
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createCubicBezier();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createCubicBezier();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createCubicBezier();
  SpeciesReferenceGlyph* srg2=new SpeciesReferenceGlyph(*srg1);
  delete srg2;
  delete srg1;
}
END_TEST

START_TEST ( test_SpeciesReferenceGlyph_assignmentOperator )
{
  SpeciesReferenceGlyph* srg1=new SpeciesReferenceGlyph();
  XMLNode* notes=new XMLNode();
  srg1->setNotes(notes);
  XMLNode* annotation=new XMLNode();
  srg1->setAnnotation(annotation);
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createCubicBezier();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createCubicBezier();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createCubicBezier();
  SpeciesReferenceGlyph* srg2=new SpeciesReferenceGlyph();
  (*srg2)=(*srg1);
  delete srg2;
  delete srg1;
}
END_TEST



START_TEST ( test_SpeciesReferenceGlyph_createWith )
{
  SpeciesReferenceGlyph* srg1= SpeciesReferenceGlyph_createWith("id", "glyphId", "referenceId", SPECIES_ROLE_PRODUCT);
  fail_unless(srg1->getId()                 == "id");
  fail_unless(srg1->getSpeciesGlyphId()     == "glyphId");
  fail_unless(srg1->getSpeciesReferenceId() == "referenceId");
  fail_unless(srg1->getRole()               == SPECIES_ROLE_PRODUCT);
  delete srg1;

  LayoutPkgNamespaces layoutns(3, 1, 1, "layout");
  SpeciesReferenceGlyph srg(&layoutns, "id", "glyphId", "referenceId", SPECIES_ROLE_PRODUCT);
  fail_unless(srg.getId()                 == "id");
  fail_unless(srg.getSpeciesGlyphId()     == "glyphId");
  fail_unless(srg.getSpeciesReferenceId() == "referenceId");
  fail_unless(srg.getRole()               == SPECIES_ROLE_PRODUCT);
}
END_TEST


Suite *
create_suite_SpeciesReferenceGlyph (void)
{
  Suite *suite = suite_create("SpeciesReferenceGlyph");
  TCase *tcase = tcase_create("SpeciesReferenceGlyph");
  
  tcase_add_checked_fixture( tcase,
                            SpeciesReferenceGlyphTest_setup,
                            SpeciesReferenceGlyphTest_teardown );
  
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_new                   );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_new_with_data         );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_setSpeciesGlyphId     );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_setSpeciesReferenceId );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_setRole               );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_getRoleString         );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_setRole_by_string     );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_setCurve              );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_setCurve_NULL         );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_createLineSegment     );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_createCubicBezier     );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_copyConstructor       );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_assignmentOperator    );
  tcase_add_test( tcase, test_SpeciesReferenceGlyph_createWith            );
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}



END_C_DECLS
