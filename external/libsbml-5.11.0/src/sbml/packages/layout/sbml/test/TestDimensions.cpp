/**
 * Filename    : TestDimensions.cpp
 * Description : Unit tests for Dimensions
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

#include <sbml/packages/layout/sbml/Dimensions.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static Dimensions *D;
static LayoutPkgNamespaces* LN;

void
DimensionsTest_setup (void)
{
  LN = new LayoutPkgNamespaces();
  D = new (std::nothrow) Dimensions(LN);
  
  if (D == NULL)
  {
    fail("new(std::nothrow)Dimensions() returned a NULL pointer.");
  }
  
}

void
DimensionsTest_teardown (void)
{
  delete D;
  delete LN;
}

START_TEST (test_Dimensions_create)
{
  fail_unless( D->getTypeCode   () == SBML_LAYOUT_DIMENSIONS );
  fail_unless( D->getMetaId     () == "" );
  //    fail_unless( D->getNotes      () == "" );
  //    fail_unless( D->getAnnotation () == "" );
  fail_unless( D->getWidth () == 0.0 );
  fail_unless( D->getHeight() == 0.0 );
  fail_unless( D->getDepth () == 0.0 );
}
END_TEST

START_TEST (test_Dimensions_createWithSize)
{
  Dimensions* d = new(std::nothrow) Dimensions(LN, 1.2 , 0.4 , 3.1415 );
  fail_unless( d->getTypeCode   () == SBML_LAYOUT_DIMENSIONS );
  fail_unless( d->getMetaId     () == "" );
  //    fail_unless( d->getNotes      () == "" );
  //    fail_unless( d->getAnnotation () == "" );
  fail_unless( d->getWidth () == 1.2 );
  fail_unless( d->getHeight() == 0.4 );
  fail_unless( d->getDepth () == 3.1415 );
  
  delete d;
}
END_TEST

START_TEST ( test_Dimensions_free_NULL)
{
  Dimensions_free(NULL);
}
END_TEST

START_TEST ( test_Dimensions_setBounds)
{
  D->setBounds(1.1 , -2.2 , 3.3);
  
  fail_unless( D->getWidth () ==  1.1 );
  fail_unless( D->getHeight() == -2.2 );
  fail_unless( D->getDepth () ==  3.3 );
  
}
END_TEST

START_TEST ( test_Dimensions_initDefaults)
{
  D->setBounds(-1.1 , 2.2 , -3.3);
  D->initDefaults();
  
  fail_unless( D->getWidth () == -1.1 );
  fail_unless( D->getHeight() ==  2.2 );
  fail_unless( D->getDepth () ==  0.0 );
  
}
END_TEST

START_TEST ( test_Dimensions_setWidth)
{
  D->setBounds( 1.1 , 2.2 , 3.3);
  D->setWidth(8.8);
  
  fail_unless(D->getWidth () == 8.8);
  fail_unless(D->getHeight() == 2.2);
  fail_unless(D->getDepth () == 3.3);
  
}
END_TEST

START_TEST ( test_Dimensions_setHeight)
{
  D->setBounds(1.1 , 2.2 , 3.3);
  D->setHeight(8.8);
  
  fail_unless(D->getWidth () == 1.1);
  fail_unless(D->getHeight() == 8.8);
  fail_unless(D->getDepth () == 3.3);
  
}
END_TEST

START_TEST ( test_Dimensions_setDepth)
{
  D->setBounds(1.1 , 2.2 , 3.3);
  D->setDepth(8.8);
  
  fail_unless(D->getWidth () == 1.1);
  fail_unless(D->getHeight() == 2.2);
  fail_unless(D->getDepth () == 8.8);
  
}
END_TEST


START_TEST ( test_Dimensions_copyConstructor )
{
  Dimensions* d1=new Dimensions();
  XMLNode notes;
  d1->setNotes(&notes);
  XMLNode annotation;
  d1->setAnnotation(&annotation);
  Dimensions* d2=new Dimensions(*d1);
  delete d2;
  delete d1;
}
END_TEST

START_TEST ( test_Dimensions_assignmentOperator )
{
  Dimensions* d1=new Dimensions();
  XMLNode notes;
  d1->setNotes(&notes);
  XMLNode annotation;
  d1->setAnnotation(&annotation);
  Dimensions d2=*d1;
  delete d1;
}
END_TEST

Suite *
create_suite_Dimensions (void)
{
  Suite *suite = suite_create("Dimensions");
  TCase *tcase = tcase_create("Dimensions");
  
  
  tcase_add_checked_fixture( tcase,
                            DimensionsTest_setup,
                            DimensionsTest_teardown );
  
  tcase_add_test( tcase, test_Dimensions_create                );
  tcase_add_test( tcase, test_Dimensions_createWithSize        );
  tcase_add_test( tcase, test_Dimensions_free_NULL             );
  tcase_add_test( tcase, test_Dimensions_setBounds             );
  tcase_add_test( tcase, test_Dimensions_initDefaults          );
  tcase_add_test( tcase, test_Dimensions_setWidth              );
  tcase_add_test( tcase, test_Dimensions_setHeight             );
  tcase_add_test( tcase, test_Dimensions_setDepth              );
  tcase_add_test( tcase, test_Dimensions_copyConstructor       );
  tcase_add_test( tcase, test_Dimensions_assignmentOperator    );
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}

END_C_DECLS
