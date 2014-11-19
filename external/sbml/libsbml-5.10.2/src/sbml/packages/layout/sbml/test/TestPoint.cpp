/**
 * Filename    : TestPoint.cpp
 * Description : Unit tests for Point
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

#include <sbml/packages/layout/sbml/Point.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static Point * P;
static LayoutPkgNamespaces* LN;

void
PointTest_setup (void)
{
  LN = new LayoutPkgNamespaces();
  P = new (std::nothrow) Point(LN);
  
  if (P == NULL)
  {
    fail("new(std::nothrow) Point() returned a NULL pointer.");
  }
  
}

void
PointTest_teardown (void)
{
  delete P;
  delete LN;
}

START_TEST (test_Point_create)
{
  fail_unless( P->getTypeCode   () == SBML_LAYOUT_POINT );
  fail_unless( P->getMetaId     () == "" );
  //    fail_unless( P->getNotes      () == "" );
  //    fail_unless( P->getAnnotation () == "" );
  fail_unless( P->getXOffset() == 0.0 );
  fail_unless( P->getYOffset() == 0.0 );
  fail_unless( P->getZOffset() == 0.0 );
}
END_TEST

START_TEST (test_Point_createWithCoordinates)
{
  Point* p = new (std::nothrow) Point(LN, 1.2 , 0.4 , 3.1415 );
  if (p == NULL)
  {
    fail("new(std::nothrow) Point(1.2,0.4,3.1415) returned a NULL pointer.");
  }
  
  fail_unless( p->getTypeCode   () == SBML_LAYOUT_POINT );
  fail_unless( p->getMetaId     () == "" );
  //    fail_unless( p->getNotes      () == "" );
  //    fail_unless( p->getAnnotation () == "" );
  fail_unless( p->getXOffset() == 1.2 );
  fail_unless( p->getYOffset() == 0.4 );
  fail_unless( p->getZOffset() == 3.1415 );
  
  delete p;
}
END_TEST

START_TEST ( test_Point_free_NULL)
{
  Point_free(NULL);
}
END_TEST

START_TEST ( test_Point_setOffsets)
{
  P->setOffsets(1.1 , -2.2 , 3.3);
  
  fail_unless( P->getXOffset() ==  1.1 );
  fail_unless( P->getYOffset() == -2.2 );
  fail_unless( P->getZOffset() ==  3.3 );
  
}
END_TEST

START_TEST ( test_Point_initDefaults)
{
  P->setOffsets(-1.1 , 2.2 , -3.3);
  P->initDefaults();
  
  fail_unless( P->getXOffset() == -1.1 );
  fail_unless( P->getYOffset() ==  2.2 );
  fail_unless( P->getZOffset() ==  0.0 );
  
}
END_TEST

START_TEST ( test_Point_setXOffset)
{
  P->setOffsets(1.1 , 2.2 , 3.3);
  P->setXOffset(8.8);
  
  fail_unless(P->getXOffset() == 8.8);
  fail_unless(P->getYOffset() == 2.2);
  fail_unless(P->getZOffset() == 3.3);
  
}
END_TEST

START_TEST ( test_Point_setYOffset)
{
  P->setOffsets(1.1 , 2.2 , 3.3);
  P->setYOffset(8.8);
  
  fail_unless(P->getXOffset() == 1.1);
  fail_unless(P->getYOffset() == 8.8);
  fail_unless(P->getZOffset() == 3.3);
  
}
END_TEST

START_TEST ( test_Point_setZOffset)
{
  P->setOffsets(1.1 , 2.2 , 3.3);
  P->setZOffset(8.8);
  
  fail_unless(P->getXOffset() == 1.1);
  fail_unless(P->getYOffset() == 2.2);
  fail_unless(P->getZOffset() == 8.8);
  
}
END_TEST

START_TEST ( test_Point_copyConstructor )
{
  Point* p1=new Point();
  XMLNode* notes=new XMLNode();
  p1->setNotes(notes);
  XMLNode* annotation=new XMLNode();
  p1->setAnnotation(annotation);
  Point* p2=new Point(*p1);
  delete p2;
  delete p1;
}
END_TEST

START_TEST ( test_Point_assignmentOperator )
{
  Point* p1=new Point();
  XMLNode* notes=new XMLNode();
  p1->setNotes(notes);
  XMLNode* annotation=new XMLNode();
  p1->setAnnotation(annotation);
  Point* p2=new Point();
  (*p2)=(*p1);
  delete p2;
  delete p1;
}
END_TEST



Suite *
create_suite_Point (void)
{
  Suite *suite = suite_create("Point");
  TCase *tcase = tcase_create("Point");
  
  
  tcase_add_checked_fixture( tcase,
                            PointTest_setup,
                            PointTest_teardown );
  
  tcase_add_test( tcase, test_Point_create                );
  tcase_add_test( tcase, test_Point_createWithCoordinates );
  tcase_add_test( tcase, test_Point_free_NULL             );
  tcase_add_test( tcase, test_Point_setOffsets            );
  tcase_add_test( tcase, test_Point_initDefaults          );
  tcase_add_test( tcase, test_Point_setXOffset            );
  tcase_add_test( tcase, test_Point_setYOffset            );
  tcase_add_test( tcase, test_Point_setZOffset            );
  tcase_add_test( tcase, test_Point_copyConstructor       );
  tcase_add_test( tcase, test_Point_assignmentOperator    );
  
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}

END_C_DECLS
