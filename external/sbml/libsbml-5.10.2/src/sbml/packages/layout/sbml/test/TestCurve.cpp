/**
 * Filename    : TestCurve.cpp
 * Description : Unit tests for Curve
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

#include <sbml/packages/layout/sbml/Curve.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static Curve_t * C;

void
CurveTest_setup (void)
{
  C = Curve_create();
  
  if (C == NULL)
  {
    fail("Curve_create(); returned a NULL pointer.");
  }
  
}

void
CurveTest_teardown (void)
{
  Curve_free(C);
}

START_TEST (test_Curve_create)
{
  fail_unless( SBase_getTypeCode   ((SBase_t*) C) == SBML_LAYOUT_CURVE );
  fail_unless( SBase_getMetaId     ((SBase_t*) C) == NULL );
  //    fail_unless( SBase_getNotes      ((SBase_t*) C) == NULL );
  //    fail_unless( SBase_getAnnotation ((SBase_t*) C) == NULL );
  
  
  
}
END_TEST

START_TEST (test_Curve_createFrom)
{
  Curve_t* c=Curve_createFrom(C);
  Curve_free(c);
}
END_TEST

START_TEST (test_Curve_createFrom_NULL)
{
  Curve_t* c=Curve_createFrom(NULL);
  Curve_free(c);
  
}
END_TEST

START_TEST (test_Curve_addCurveSegment)
{
}
END_TEST

START_TEST (test_Curve_addCurveSegment_NULL)
{
  
}
END_TEST

START_TEST (test_Curve_getNumCurveSegments)
{
  
}
END_TEST

START_TEST (test_Curve_getCurveSegment)
{
	unsigned int num;
  C->createLineSegment();
	num = C->getNumCurveSegments();
  LineSegment_t* ls=C->getCurveSegment(num-1);
  fail_unless(ls != NULL);
}
END_TEST

START_TEST (test_Curve_getListOfCurveSegments )
{
  Curve_createLineSegment(C);
  ListOf* l=Curve_getListOfCurveSegments(C);
  fail_unless(l != NULL);
  fail_unless(ListOf_size(l) == 1);
}
END_TEST

START_TEST (test_Curve_createLineSegment )
{
  unsigned int number=Curve_getNumCurveSegments(C);
  LineSegment_t* ls=Curve_createLineSegment(C);
  fail_unless(ls !=NULL);
  fail_unless(Curve_getNumCurveSegments(C)==number+1);
}
END_TEST

START_TEST (test_Curve_createCubicBezier )
{
  unsigned int number=Curve_getNumCurveSegments(C);
  CubicBezier_t* cb=Curve_createCubicBezier(C);
  fail_unless(cb !=NULL);
  fail_unless(Curve_getNumCurveSegments(C)==number+1);
}
END_TEST

START_TEST ( test_Curve_copyConstructor )
{
  Curve* c1=new Curve();
  XMLNode* notes=new XMLNode();
  c1->setNotes(notes);
  XMLNode* annotation=new XMLNode();
  c1->setAnnotation(annotation);
  c1->createLineSegment();
  c1->createLineSegment();
  c1->createCubicBezier();
  c1->createCubicBezier();
  Curve* c2=new Curve(*c1);
  delete c2;
  delete c1;
}
END_TEST

START_TEST ( test_Curve_assignmentOperator )
{
  Curve* c1=new Curve();
  XMLNode* notes=new XMLNode();
  c1->setNotes(notes);
  XMLNode* annotation=new XMLNode();
  c1->setAnnotation(annotation);
  c1->createLineSegment();
  c1->createLineSegment();
  c1->createCubicBezier();
  c1->createCubicBezier();
  Curve* c2=new Curve();
  (*c2)=(*c1);
  delete c2;
  delete c1;
}
END_TEST

Suite *
create_suite_Curve (void)
{
  Suite *suite = suite_create("Curve");
  TCase *tcase = tcase_create("Curve");
  
  
  tcase_add_checked_fixture( tcase,
                            CurveTest_setup,
                            CurveTest_teardown );
  
  tcase_add_test( tcase, test_Curve_create                           );
  tcase_add_test( tcase, test_Curve_createFrom                       );
  tcase_add_test( tcase, test_Curve_createFrom_NULL                  );
  tcase_add_test( tcase, test_Curve_addCurveSegment                  );
  tcase_add_test( tcase, test_Curve_addCurveSegment_NULL             );
  tcase_add_test( tcase, test_Curve_getNumCurveSegments              );
  tcase_add_test( tcase, test_Curve_getCurveSegment                  );
  tcase_add_test( tcase, test_Curve_getListOfCurveSegments           );
  tcase_add_test( tcase, test_Curve_createLineSegment                );
  tcase_add_test( tcase, test_Curve_createCubicBezier                );
  tcase_add_test( tcase, test_Curve_copyConstructor                  );
  tcase_add_test( tcase, test_Curve_assignmentOperator               );
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}


END_C_DECLS
