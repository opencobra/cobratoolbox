/**
 * Filename    : TestReferenceGlyph.cpp
 * Description : Unit tests for ReferenceGlyph
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

#include <sbml/packages/layout/sbml/ReferenceGlyph.h>
#include <sbml/packages/layout/sbml/LineSegment.h>
#include <sbml/packages/layout/sbml/CubicBezier.h>
#include <sbml/packages/layout/sbml/Curve.h>
#include <sbml/packages/layout/sbml/Point.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static ReferenceGlyph * SRG;
static LayoutPkgNamespaces* LN;

void
ReferenceGlyphTest_setup (void)
{
  LN = new LayoutPkgNamespaces();
  SRG = new (std::nothrow) ReferenceGlyph(LN);
  
  if (SRG == NULL)
  {
    fail("new(std::nothrow) ReferenceGlyph() returned a NULL pointer.");
  }
  
}

void
ReferenceGlyphTest_teardown (void)
{
  delete SRG;
  delete LN;
}

START_TEST (test_ReferenceGlyph_new )
{
  fail_unless( SRG->getTypeCode()   == SBML_LAYOUT_REFERENCEGLYPH );
  fail_unless( SRG->getMetaId()     == "" );
  fail_unless( !SRG->isSetId() );
  fail_unless( !SRG->isSetReferenceId() );
  fail_unless( !SRG->isSetGlyphId() );
  fail_unless( !SRG->isSetRole() );
  fail_unless( SRG->getRole() == "" );
  fail_unless( SRG->getCurve() != NULL);
  fail_unless( !SRG->isSetCurve());
}
END_TEST

START_TEST (test_ReferenceGlyph_new_with_data)
{
  std::string sid="TestReferenceGlyph";
  std::string glyphId="TestGlyph";
  std::string referenceId="TestReference";
  ReferenceGlyph* srg=new ReferenceGlyph( LN, sid,
                                         glyphId,
                                         referenceId,
                                         "substrate"
                                         );
  
  fail_unless( srg->getTypeCode()   == SBML_LAYOUT_REFERENCEGLYPH );
  fail_unless( srg->getMetaId()     == "" );
  fail_unless( srg->isSetId() );
  fail_unless( srg->getId() == sid);
  fail_unless( srg->isSetReferenceId() );
  fail_unless( srg->getReferenceId() == referenceId);
  fail_unless( srg->isSetGlyphId() );
  fail_unless( srg->getGlyphId() == glyphId);
  fail_unless( srg->isSetRole());
  fail_unless( srg->getRole() == "substrate" );
  fail_unless( srg->getCurve() != NULL);
  fail_unless( !srg->isSetCurve());
  
  delete srg;
}
END_TEST

START_TEST (test_ReferenceGlyph_setGlyphId)
{
  std::string glyphId="TestGlyph";
  SRG->setGlyphId(glyphId);
  fail_unless(SRG->isSetGlyphId());
  fail_unless(SRG->getGlyphId() == glyphId);
  SRG->setGlyphId("");
  fail_unless(!SRG->isSetGlyphId());
}
END_TEST

START_TEST (test_ReferenceGlyph_setReferenceId)
{
  std::string referenceId="TestReference";
  SRG->setReferenceId(referenceId);
  fail_unless(SRG->isSetReferenceId());
  fail_unless(SRG->getReferenceId() == referenceId);
  SRG->setReferenceId("");
  fail_unless(!SRG->isSetReferenceId());
}
END_TEST

START_TEST (test_ReferenceGlyph_setRole)
{
  SRG->setRole("modifier");
  fail_unless(SRG->isSetRole());
  fail_unless(SRG->getRole() == "modifier");
}
END_TEST


START_TEST ( test_ReferenceGlyph_getRole )
{
  SRG->setRole("undefined");
  fail_unless(SRG->getRole() == "undefined");
  SRG->setRole("substrate");
  fail_unless(SRG->getRole() == "substrate");
}
END_TEST

START_TEST (test_ReferenceGlyph_setCurve)
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

START_TEST (test_ReferenceGlyph_setCurve_NULL)
{
  SRG->setCurve(NULL);
  fail_unless(!SRG->isSetCurve());
  fail_unless(SRG->getCurve() != NULL);
}
END_TEST

START_TEST (test_ReferenceGlyph_createLineSegment)
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

START_TEST (test_ReferenceGlyph_createCubicBezier)
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

START_TEST ( test_ReferenceGlyph_copyConstructor )
{
  ReferenceGlyph* srg1=new ReferenceGlyph();
  XMLNode notes;
  srg1->setNotes(&notes);
  XMLNode annotation;
  srg1->setAnnotation(&annotation);
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createCubicBezier();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createCubicBezier();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createCubicBezier();
  ReferenceGlyph* srg2=new ReferenceGlyph(*srg1);
  delete srg2;
  delete srg1;
}
END_TEST

START_TEST ( test_ReferenceGlyph_assignmentOperator )
{
  ReferenceGlyph* srg1=new ReferenceGlyph();
  XMLNode notes;
  srg1->setNotes(&notes);
  XMLNode annotation;
  srg1->setAnnotation(&annotation);
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createCubicBezier();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createCubicBezier();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createLineSegment();
  srg1->getCurve()->createCubicBezier();
  ReferenceGlyph srg2=*srg1;
  delete srg1;
}
END_TEST


START_TEST ( test_ReferenceGlyph_createWith )
{
  ReferenceGlyph* srg1= ReferenceGlyph_createWith("id", "glyphId", "referenceId", "product");
  fail_unless(srg1->getId()          == "id");
  fail_unless(srg1->getGlyphId()     == "glyphId");
  fail_unless(srg1->getReferenceId() == "referenceId");
  fail_unless(srg1->getRole()        == "product");
  delete srg1;

  LayoutPkgNamespaces layoutns(3, 1, 1, "layout");
  ReferenceGlyph srg(&layoutns, "id", "glyphId", "referenceId", "product");
  fail_unless(srg.getId()          == "id");
  fail_unless(srg.getGlyphId()     == "glyphId");
  fail_unless(srg.getReferenceId() == "referenceId");
  fail_unless(srg.getRole()        == "product");
}
END_TEST



Suite *
create_suite_ReferenceGlyph (void)
{
  Suite *suite = suite_create("ReferenceGlyph");
  TCase *tcase = tcase_create("ReferenceGlyph");
  
  tcase_add_checked_fixture( tcase,
                            ReferenceGlyphTest_setup,
                            ReferenceGlyphTest_teardown );
  
  tcase_add_test( tcase, test_ReferenceGlyph_new                );
  tcase_add_test( tcase, test_ReferenceGlyph_new_with_data      );
  tcase_add_test( tcase, test_ReferenceGlyph_setGlyphId         );
  tcase_add_test( tcase, test_ReferenceGlyph_setReferenceId     );
  tcase_add_test( tcase, test_ReferenceGlyph_setRole            );
  tcase_add_test( tcase, test_ReferenceGlyph_getRole            );
  tcase_add_test( tcase, test_ReferenceGlyph_setCurve           );
  tcase_add_test( tcase, test_ReferenceGlyph_setCurve_NULL      );
  tcase_add_test( tcase, test_ReferenceGlyph_createLineSegment  );
  tcase_add_test( tcase, test_ReferenceGlyph_createCubicBezier  );
  tcase_add_test( tcase, test_ReferenceGlyph_copyConstructor    );
  tcase_add_test( tcase, test_ReferenceGlyph_assignmentOperator );
  tcase_add_test( tcase, test_ReferenceGlyph_createWith         );
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}



END_C_DECLS
