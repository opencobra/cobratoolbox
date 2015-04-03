/**
 * Filename    : TestCubicBezier.cpp
 * Description : Unit tests for CubicBezier
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
#include <sbml/packages/layout/sbml/CubicBezier.h>
#include <sbml/packages/layout/sbml/Point.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static CubicBezier_t* CB;
static LayoutPkgNamespaces* LN;

void
CubicBezierTest_setup (void)
{
  CB = CubicBezier_create();
	LN = new LayoutPkgNamespaces();
  if(CB == NULL)
  {
    fail("CubicBezier_create(); returned a NULL pointer.");
  }
}

void
CubicBezierTest_teardown (void)
{
  CubicBezier_free(CB);
	delete LN;
}

START_TEST ( test_CubicBezier_create )
{
  fail_unless( CB->getPackageName() == "layout");
  fail_unless( CB->getTypeCode() == SBML_LAYOUT_CUBICBEZIER);
  fail_unless( SBase_getMetaId     ((SBase_t*) CB) == NULL );
  
  Point_t *pos=CubicBezier_getStart(CB);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
  
  pos=CubicBezier_getBasePoint1(CB);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
  
  pos=CubicBezier_getBasePoint2(CB);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
  
  pos=CubicBezier_getEnd(CB);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
  
}
END_TEST

START_TEST ( test_CubicBezier_createWithPoints )
{
  Point_t *start= new (std::nothrow) Point(LN,1.1,-2.2,3.3);
  Point_t *base1= new (std::nothrow) Point(LN,-0.5,2.4,5.6);
  Point_t *base2= new (std::nothrow) Point(LN,7.8,-0.3,-1.2);
  Point_t *end  = new (std::nothrow) Point(LN,-4.4,5.5,-6.6);
  
  CubicBezier_t *cb= new CubicBezier(LN,start,base1,base2,end);
  
  fail_unless( cb->getPackageName() == "layout");
  fail_unless( cb->getTypeCode() == SBML_LAYOUT_CUBICBEZIER);
  fail_unless( SBase_getMetaId     ((SBase_t*) cb) == NULL );
  
  Point_t *pos=CubicBezier_getStart(cb);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(start));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(start));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(start));
  
  pos=CubicBezier_getBasePoint1(cb);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(base1));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(base1));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(base1));
  
  pos=CubicBezier_getBasePoint2(cb);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(base2));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(base2));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(base2));
  
  pos=CubicBezier_getEnd(cb);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(end));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(end));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(end));
  
  Point_free(start);
  Point_free(base1);
  Point_free(base2);
  Point_free(end);
  CubicBezier_free(cb);
}
END_TEST

START_TEST ( test_CubicBezier_createWithPoints_NULL )
{
	Point* nullPoint = NULL;
  CubicBezier_t *cb=new CubicBezier(LN,
                                    nullPoint,
                                    nullPoint,
                                    nullPoint,
                                    nullPoint);
  
  fail_unless( cb->getPackageName() == "layout");
  fail_unless( cb->getTypeCode() == SBML_LAYOUT_CUBICBEZIER);
  fail_unless( SBase_getMetaId     ((SBase_t*) cb) == NULL );
  
  Point_t *pos=CubicBezier_getStart(cb);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
  
  pos=CubicBezier_getBasePoint1(cb);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
  
  pos=CubicBezier_getBasePoint2(cb);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
  
  pos=CubicBezier_getEnd(cb);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
  
  CubicBezier_free(cb);
}
END_TEST

START_TEST ( test_CubicBezier_createWithCoordinates )
{
  Point p1(LN,1.1,-2.2,3.3);
  Point p2(LN,-4.4,5.5,-6.6);
  Point p3(LN,7.7,-8.8,9.9);
  Point p4(LN,-10.10,11.11,-12.12);

  CubicBezier_t* cb= new CubicBezier(LN, &p1, &p2, &p3, &p4);
  
  fail_unless( cb->getPackageName() == "layout");
  fail_unless( cb->getTypeCode() == SBML_LAYOUT_CUBICBEZIER);
  fail_unless( SBase_getMetaId     ((SBase_t*) cb) == NULL );
  
  Point_t *pos=CubicBezier_getStart(cb);
  fail_unless(pos != NULL);
  fail_unless(pos->getXOffset() ==  1.1);
  fail_unless(pos->getYOffset() == -2.2);
  fail_unless(pos->getZOffset() ==  3.3);
  
  pos=CubicBezier_getBasePoint1(cb);
  fail_unless(pos != NULL);
  fail_unless(pos->getXOffset() == -4.4);
  fail_unless(pos->getYOffset() ==  5.5);
  fail_unless(pos->getZOffset() == -6.6);
  
  pos=CubicBezier_getBasePoint2(cb);
  fail_unless(pos != NULL);
  fail_unless(pos->getXOffset() ==  7.7);
  fail_unless(pos->getYOffset() == -8.8);
  fail_unless(pos->getZOffset() ==  9.9);
  
  pos=CubicBezier_getEnd(cb);
  fail_unless(pos != NULL);
  fail_unless(pos->getXOffset() == -10.10);
  fail_unless(pos->getYOffset() ==  11.11);
  fail_unless(pos->getZOffset() == -12.12);
  
  CubicBezier_free(cb);
}
END_TEST

START_TEST (test_CubicBezier_free_NULL)
{
  CubicBezier_free(NULL);
}
END_TEST

START_TEST (test_CubicBezier_setStart)
{
  Point_t *pos= new (std::nothrow) Point(LN,1.1,-2.2,3.3);
  CubicBezier_setStart(CB,pos);
  
  Point_t* POS=CubicBezier_getStart(CB);
  
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(POS));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(POS));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(POS));
  Point_free(pos);
  
}
END_TEST

START_TEST (test_CubicBezier_setBasePoint1 )
{
  Point_t *pos= new (std::nothrow) Point(LN,7.7,-8.8,9.9);
  CubicBezier_setBasePoint1(CB,pos);
  
  Point_t* POS=CubicBezier_getBasePoint1(CB);
  
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(POS));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(POS));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(POS));
  Point_free(pos);
}
END_TEST

START_TEST (test_CubicBezier_setBasePoint2 )
{
  Point_t *pos= new (std::nothrow) Point(LN,-10.10,11.11,-12.12);
  CubicBezier_setBasePoint2(CB,pos);
  
  Point_t* POS=CubicBezier_getBasePoint2(CB);
  
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(POS));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(POS));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(POS));
  
  Point_free(pos);
}
END_TEST

START_TEST (test_CubicBezier_setEnd )
{
  Point_t *pos= new (std::nothrow) Point(LN,-4.4,5.5,-6.6);
  CubicBezier_setEnd(CB,pos);
  
  Point_t* POS=CubicBezier_getEnd(CB);
  
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(POS));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(POS));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(POS));
  Point_free(pos);
}
END_TEST

START_TEST ( test_CubicBezier_createFrom )
{
  Point_t* start= new (std::nothrow) Point(LN,1.1,-2.2,3.3);
  Point_t* base1= new (std::nothrow) Point(LN,-4.4,5.5,-6.6);
  Point_t* base2= new (std::nothrow) Point(LN,7.7,-8.8,9.9);
  Point_t* end= new (std::nothrow) Point(LN,-10.10,11.11,-12.12);
  CubicBezier_setStart(CB,start);
  CubicBezier_setBasePoint1(CB,base1);
  CubicBezier_setBasePoint2(CB,base2);
  CubicBezier_setEnd(CB,end);
  CubicBezier_t* cb=CubicBezier_createFrom(CB);
  fail_unless( cb->getPackageName() == "layout");
  fail_unless( cb->getTypeCode() == SBML_LAYOUT_CUBICBEZIER);
  if(SBase_isSetMetaId((SBase_t*)CB))
  {
    std::string c1=SBase_getMetaId((SBase_t*)CB);
    std::string c2=SBase_getMetaId((SBase_t*)cb);
    fail_unless( c1 == c2 );
  }
  
  //   c1=SBase_getNotes((SBase_t*)CB);
  //   c2=SBase_getNotes((SBase_t*)cb);
  //   if(SBase_isSetNotes((SBase_t*)CB))
  //   {
  //       fail_unless( strncmp(c1 , c2 ,strlen( c1)+1 )==0 );
  //   }
  //   else{
  //       fail_unless(!(c1 || c2));
  //   }
  
  //   c1=SBase_getAnnotation((SBase_t*)CB);
  //   c2=SBase_getAnnotation((SBase_t*)cb);
  //   if(SBase_isSetAnnotation((SBase_t*)CB))
  //   {
  //       fail_unless( strncmp(c1 , c2 ,strlen( c1)+1 )==0 );
  //   }
  //   else{
  //       fail_unless(!(c1 || c2));
  //   }
  
  Point_t *pos=CubicBezier_getStart(cb);
  Point_t *POS=CubicBezier_getStart(CB);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(POS));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(POS));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(POS));
  
  pos=CubicBezier_getBasePoint1(cb);
  POS=CubicBezier_getBasePoint1(CB);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(POS));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(POS));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(POS));
  
  pos=CubicBezier_getBasePoint2(cb);
  POS=CubicBezier_getBasePoint2(CB);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(POS));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(POS));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(POS));
  
  pos=CubicBezier_getEnd(cb);
  POS=CubicBezier_getEnd(CB);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == Point_getXOffset(POS));
  fail_unless(Point_getYOffset(pos) == Point_getYOffset(POS));
  fail_unless(Point_getZOffset(pos) == Point_getZOffset(POS));
  Point_free(start);
  Point_free(base1);
  Point_free(base2);
  Point_free(end);
  
  CubicBezier_free(cb);
}
END_TEST

START_TEST (test_CubicBezier_setStart_NULL )
{
  CubicBezier_setStart(CB,NULL);
  
  Point_t *pos=CubicBezier_getStart(CB);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
}
END_TEST

START_TEST (test_CubicBezier_setBasePoint1_NULL )
{
  CubicBezier_setBasePoint1(CB,NULL);
  
  Point_t *pos=CubicBezier_getBasePoint1(CB);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
}
END_TEST

START_TEST (test_CubicBezier_setBasePoint2_NULL )
{
  CubicBezier_setBasePoint2(CB,NULL);
  
  Point_t *pos=CubicBezier_getBasePoint2(CB);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
}
END_TEST


START_TEST (test_CubicBezier_setEnd_NULL )
{
  CubicBezier_setEnd(CB,NULL);
  Point_t *pos=CubicBezier_getEnd(CB);
  fail_unless(pos != NULL);
  fail_unless(Point_getXOffset(pos) == 0.0);
  fail_unless(Point_getYOffset(pos) == 0.0);
  fail_unless(Point_getZOffset(pos) == 0.0);
}
END_TEST

START_TEST ( test_CubicBezier_copyConstructor )
{
  CubicBezier* cb1=new CubicBezier();
  XMLNode notes;
  cb1->setNotes(&notes);
  XMLNode annotation;
  cb1->setAnnotation(&annotation);
  CubicBezier* cb2=new CubicBezier(*cb1);
  delete cb2;
  delete cb1;
}
END_TEST

START_TEST ( test_CubicBezier_assignmentOperator )
{
  CubicBezier* cb1=new CubicBezier();
  XMLNode notes;
  cb1->setNotes(&notes);
  XMLNode annotation;
  cb1->setAnnotation(&annotation);
  CubicBezier cb2=*cb1;
  delete cb1;
}
END_TEST

Suite *
create_suite_CubicBezier (void)
{
  Suite *suite = suite_create("CubicBezier");
  TCase *tcase = tcase_create("CubicBezier");
  
  
  tcase_add_checked_fixture( tcase,
                            CubicBezierTest_setup,
                            CubicBezierTest_teardown );
  
  tcase_add_test( tcase, test_CubicBezier_create                );
  tcase_add_test( tcase, test_CubicBezier_createWithPoints      );
  tcase_add_test( tcase, test_CubicBezier_createWithPoints_NULL );
  tcase_add_test( tcase, test_CubicBezier_createWithCoordinates );
  tcase_add_test( tcase, test_CubicBezier_free_NULL             );
  tcase_add_test( tcase, test_CubicBezier_setStart              );
  tcase_add_test( tcase, test_CubicBezier_setStart_NULL         );
  tcase_add_test( tcase, test_CubicBezier_setBasePoint1         );
  tcase_add_test( tcase, test_CubicBezier_setBasePoint1_NULL    );
  tcase_add_test( tcase, test_CubicBezier_setBasePoint2         );
  tcase_add_test( tcase, test_CubicBezier_setBasePoint2_NULL    );
  tcase_add_test( tcase, test_CubicBezier_setEnd                );
  tcase_add_test( tcase, test_CubicBezier_setEnd_NULL           );
  tcase_add_test( tcase, test_CubicBezier_createFrom            );
  tcase_add_test( tcase, test_CubicBezier_copyConstructor       );
  tcase_add_test( tcase, test_CubicBezier_assignmentOperator    );
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}


END_C_DECLS
