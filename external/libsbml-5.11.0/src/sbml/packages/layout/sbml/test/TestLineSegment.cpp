/**
 * Filename    : TestLineSegment.cpp
 * Description : Unit tests for LineSegment
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

#include <sbml/SBase.h>
#include <sbml/packages/layout/sbml/LineSegment.h>
#include <sbml/packages/layout/sbml/Point.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static LineSegment_t* LS;
static LayoutPkgNamespaces* LN;

void
LineSegmentTest_setup (void)
{
  LS = LineSegment_create();
	LN = new LayoutPkgNamespaces();
  
  if(LS == NULL)
  {
    fail("LineSegment_create(); returned a NULL pointer.");
  }
}

void
LineSegmentTest_teardown (void)
{
  LineSegment_free(LS);
	delete LN;
}

START_TEST ( test_LineSegment_create )
{
  fail_unless( SBase_getTypeCode   ((SBase_t*) LS) == SBML_LAYOUT_LINESEGMENT );
  fail_unless( SBase_getMetaId     ((SBase_t*) LS) == NULL );
  
  Point_t *pos=LineSegment_getStart(LS);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
  
  pos=LineSegment_getEnd(LS);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
  
}
END_TEST


START_TEST ( test_LineSegment_createWithPoints )
{
  Point_t *start=new Point(LN,1.1,-2.2,3.3);
  Point_t *end  =new Point(LN,-4.4,5.5,-6.6);
  
  LineSegment_t *ls=new LineSegment(LN, start,end);
  
  fail_unless( SBase_getTypeCode   ((SBase_t*) ls) == SBML_LAYOUT_LINESEGMENT );
  fail_unless( SBase_getMetaId     ((SBase_t*) ls) == NULL );
  
  Point_t *pos=LineSegment_getStart(ls);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(start));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(start));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(start));
  
  pos=LineSegment_getEnd(ls);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(end));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(end));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(end));
  
  Point_free(start);
  Point_free(end);
  
  LineSegment_free(ls);
  
}
END_TEST

START_TEST ( test_LineSegment_createWithPoints_NULL )
{
  LineSegment_t *ls= new LineSegment(LN,NULL,NULL);
  
  fail_unless( SBase_getTypeCode   ((SBase_t*) ls) == SBML_LAYOUT_LINESEGMENT );
  fail_unless( SBase_getMetaId     ((SBase_t*) ls) == NULL );
  
  Point_t *pos=LineSegment_getStart(ls);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
  
  pos=LineSegment_getEnd(ls);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
  
  LineSegment_free(ls);
}
END_TEST

START_TEST ( test_LineSegment_createWithCoordinates )
{
  LineSegment_t* ls=new LineSegment(LN, 1.1,-2.2,3.3,-4.4,5.5,-6.6);
  
  fail_unless( SBase_getTypeCode   ((SBase_t*) ls) == SBML_LAYOUT_LINESEGMENT );
  fail_unless( SBase_getMetaId     ((SBase_t*) ls) == NULL );
  
  Point_t *pos=LineSegment_getStart(ls);
  fail_unless(pos != NULL);
  fail_unless(pos->getXOffset() ==  1.1);
  fail_unless(pos->getYOffset() == -2.2);
  fail_unless(pos->getZOffset() ==  3.3);
  
  pos=LineSegment_getEnd(ls);
  fail_unless(pos != NULL);
  fail_unless(pos->getXOffset() == -4.4);
  fail_unless(pos->getYOffset() ==  5.5);
  fail_unless(pos->getZOffset() == -6.6);
  
  LineSegment_free(ls);
}
END_TEST

START_TEST (test_LineSegment_free_NULL)
{
  LineSegment_free(NULL);
}
END_TEST

START_TEST (test_LineSegment_setStart)
{
  Point_t *pos=new Point(LN,1.1,-2.2,3.3);
  LineSegment_setStart(LS,pos);
  
  Point_t* POS=LineSegment_getStart(LS);
  
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(POS));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(POS));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(POS));
  Point_free(pos);
}
END_TEST

START_TEST (test_LineSegment_setEnd )
{
  Point_t *pos=new Point(LN,-4.4,5.5,-6.6);
  LineSegment_setEnd(LS,pos);
  
  Point_t* POS=LineSegment_getEnd(LS);
  
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(POS));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(POS));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(POS));
  Point_free(pos);
}
END_TEST

START_TEST ( test_LineSegment_createFrom )
{
  Point* start = new Point(LN,1.1,-2.2,3.3);
  Point* end=new Point(LN,-4.4,5.5,-6.6);
  LineSegment_setStart(LS,start);
  LineSegment_setEnd(LS,end);
  LineSegment_t* ls=LineSegment_createFrom(LS);
  
  
  fail_unless( SBase_getTypeCode   ((SBase_t*) ls) == SBML_LAYOUT_LINESEGMENT );
  
  if(SBase_isSetMetaId((SBase_t*)LS)){
    std::string c1=SBase_getMetaId((SBase_t*)LS);
    std::string c2=SBase_getMetaId((SBase_t*)ls);
    fail_unless( c1 == c2 );
  }
  //   c1=SBase_getNotes((SBase_t*)LS);
  //   c2=SBase_getNotes((SBase_t*)ls);
  //
  //   if(SBase_isSetNotes((SBase_t*)LS))
  //   {
  //     fail_unless( strncmp(c1 , c2 ,strlen( c1 ) + 1 ) );
  //   }
  //   else
  //   {
  //     fail_unless(!(c1 || c2));
  //   }
  //
  //   c1=SBase_getAnnotation((SBase_t*)LS);
  //   c2=SBase_getAnnotation((SBase_t*)ls);
  //
  //   if(SBase_isSetAnnotation((SBase_t*)LS))
  //   {
  //     fail_unless( strncmp(c1 , c2 ,strlen( c1 ) + 1) );
  //   }
  //   else
  //   {
  //     fail_unless(!(c1 || c2));
  //   }
  
  Point_t *pos=LineSegment_getStart(ls);
  Point_t *POS=LineSegment_getStart(LS);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(POS));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(POS));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(POS));
  
  pos=LineSegment_getEnd(ls);
  POS=LineSegment_getEnd(LS);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(POS));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(POS));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(POS));
  
  Point_free(start);
  Point_free(end);
  LineSegment_free(ls);
}
END_TEST

START_TEST (test_LineSegment_setStart_NULL )
{
  LineSegment_setStart(LS,NULL);
  
  Point_t *pos=LineSegment_getStart(LS);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
}
END_TEST

START_TEST (test_LineSegment_setEnd_NULL )
{
  LineSegment_setEnd(LS,NULL);
  Point_t *pos=LineSegment_getEnd(LS);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
}
END_TEST

START_TEST ( test_LineSegment_copyConstructor )
{
  LineSegment* ls1=new LineSegment();
  XMLNode notes;
  ls1->setNotes(&notes);
  XMLNode annotation;
  ls1->setAnnotation(&annotation);
  LineSegment* ls2=new LineSegment(*ls1);
  delete ls2;
  delete ls1;
}
END_TEST

START_TEST ( test_LineSegment_assignmentOperator )
{
  LineSegment* ls1=new LineSegment();
  XMLNode notes;
  ls1->setNotes(&notes);
  XMLNode annotation;
  ls1->setAnnotation(&annotation);
  LineSegment ls2=*ls1;
  delete ls1;
}
END_TEST


Suite *
create_suite_LineSegment (void)
{
  Suite *suite = suite_create("LineSegment");
  TCase *tcase = tcase_create("LineSegment");
  
  
  tcase_add_checked_fixture( tcase,
                            LineSegmentTest_setup,
                            LineSegmentTest_teardown );
  
  tcase_add_test( tcase, test_LineSegment_create                );
  tcase_add_test( tcase, test_LineSegment_createWithPoints      );
  tcase_add_test( tcase, test_LineSegment_createWithPoints_NULL );
  tcase_add_test( tcase, test_LineSegment_createWithCoordinates );
  tcase_add_test( tcase, test_LineSegment_free_NULL             );
  tcase_add_test( tcase, test_LineSegment_setStart              );
  tcase_add_test( tcase, test_LineSegment_setStart_NULL         );
  tcase_add_test( tcase, test_LineSegment_setEnd                );
  tcase_add_test( tcase, test_LineSegment_setEnd_NULL           );
  tcase_add_test( tcase, test_LineSegment_createFrom            );
  tcase_add_test( tcase, test_LineSegment_copyConstructor       );
  tcase_add_test( tcase, test_LineSegment_assignmentOperator    );
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}


END_C_DECLS
