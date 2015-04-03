/**
 * Filename    : TestBoundingBox.cpp
 * Description : Unit tests for BoundingBox
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

#include <sbml/packages/layout/sbml/BoundingBox.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

static BoundingBox* BB;
static LayoutPkgNamespaces* LN;

static void
BoundingBoxTest_setup (void)
{
  LN = new LayoutPkgNamespaces();
  BB = new BoundingBox(LN);
  
  if(BB == NULL)
  {
    fail("BoundingBox(); returned a NULL pointer.");
  }
}

static void
BoundingBoxTest_teardown (void)
{
  delete BB;
  delete LN;
}


CK_CPPSTART

START_TEST ( test_BoundingBox_create )
{
  fail_unless( BB->getTypeCode() == SBML_LAYOUT_BOUNDINGBOX );
  fail_unless( BB->getMetaId() == "" );
  //   fail_unless( SBase_getNotes      ((SBase_t*) BB) == NULL );
  //   fail_unless( SBase_getAnnotation ((SBase_t*) BB) == NULL );
  
  fail_unless(BB->isSetId() == false );
  
  Point* pos=BB->getPosition();
  fail_unless(pos != NULL);
  fail_unless(pos->getXOffset() == 0.0);
  fail_unless(pos->getYOffset() == 0.0);
  fail_unless(pos->getZOffset() == 0.0);
  
  Dimensions *dim=BB->getDimensions();
  fail_unless(dim != NULL);
  fail_unless(dim->getWidth () == 0.0);
  fail_unless(dim->getHeight() == 0.0);
  fail_unless(dim->getDepth () == 0.0);
  
}
END_TEST


START_TEST ( test_BoundingBox_createWith )
{
  const char* id="BoundingBox";
  BoundingBox *bb=new BoundingBox(LN,id);
  fail_unless( bb->getTypeCode() == SBML_LAYOUT_BOUNDINGBOX );
  fail_unless( bb->getMetaId()   == "" );
  //   fail_unless( SBase_getNotes      ((SBase_t*) bb) == NULL );
  //   fail_unless( SBase_getAnnotation ((SBase_t*) bb) == NULL );
  
  fail_unless( bb->isSetId() == true );
  fail_unless( bb->getId() == id);
  
  Point *pos=bb->getPosition();
  fail_unless(pos != NULL);
  fail_unless(pos->getXOffset() == 0.0);
  fail_unless(pos->getYOffset() == 0.0);
  fail_unless(pos->getZOffset() == 0.0);
  
  Dimensions *dim=bb->getDimensions();
  fail_unless(dim != NULL);
  fail_unless(dim->getWidth () == 0.0);
  fail_unless(dim->getHeight() == 0.0);
  fail_unless(dim->getDepth () == 0.0);
  delete bb;
}
END_TEST

START_TEST ( test_BoundingBox_createWith_NULL )
{
  BoundingBox *bb=new BoundingBox(LN,"");
  fail_unless( bb->getTypeCode()    == SBML_LAYOUT_BOUNDINGBOX );
  fail_unless( bb->getMetaId()  == "" );
  //   fail_unless( SBase_getNotes      ((SBase_t*) bb) == NULL );
  //   fail_unless( SBase_getAnnotation ((SBase_t*) bb) == NULL );
  
  fail_unless( bb->isSetId() == false );
  
  Point *pos=bb->getPosition();
  fail_unless(pos != NULL);
  fail_unless(pos->getXOffset() == 0.0);
  fail_unless(pos->getYOffset() == 0.0);
  fail_unless(pos->getZOffset() == 0.0);
  
  Dimensions *dim=bb->getDimensions();
  fail_unless(dim != NULL);
  fail_unless(dim->getWidth () == 0.0);
  fail_unless(dim->getHeight() == 0.0);
  fail_unless(dim->getDepth () == 0.0);
  
  delete bb;
}
END_TEST

START_TEST ( test_BoundingBox_createWithCoordinates )
{
  const char* id="BoundingBox";
  BoundingBox *bb=new BoundingBox(LN,id,1.1,-2.2,3.3,-4.4,5.5,-6.6);
  fail_unless( bb->getTypeCode() == SBML_LAYOUT_BOUNDINGBOX );
  fail_unless( bb->getMetaId() == "" );
  //   fail_unless( SBase_getNotes      ((SBase_t*) bb) == NULL );
  //   fail_unless( SBase_getAnnotation ((SBase_t*) bb) == NULL );
  
  fail_unless( bb->isSetId() == true );
  fail_unless( bb->getId() == id);
  
  Point *pos=bb->getPosition();
  fail_unless(pos != NULL);
  fail_unless(pos->getXOffset() ==  1.1);
  fail_unless(pos->getYOffset() == -2.2);
  fail_unless(pos->getZOffset() ==  3.3);
  
  Dimensions *dim=bb->getDimensions();
  fail_unless(dim != NULL);
  fail_unless(dim->getWidth () == -4.4);
  fail_unless(dim->getHeight() ==  5.5);
  fail_unless(dim->getDepth () == -6.6);
  
  delete bb;
}
END_TEST

START_TEST ( test_BoundingBox_createWithCoordinates_NULL )
{
  BoundingBox *bb=new BoundingBox(LN,"",1.1,-2.2,3.3,-4.4,5.5,-6.6);
  fail_unless( bb->getTypeCode() == SBML_LAYOUT_BOUNDINGBOX );
  fail_unless( bb->getMetaId() == "" );
  //   fail_unless( SBase_getNotes      ((SBase_t*) bb) == NULL );
  //   fail_unless( SBase_getAnnotation ((SBase_t*) bb) == NULL );
  
  fail_unless( bb->isSetId() == false );
  
  Point *pos=bb->getPosition();
  fail_unless(pos != NULL);
  fail_unless(pos->getXOffset() ==  1.1);
  fail_unless(pos->getYOffset() == -2.2);
  fail_unless(pos->getZOffset() ==  3.3);
  
  Dimensions *dim=bb->getDimensions();
  fail_unless(dim != NULL);
  fail_unless(dim->getWidth () == -4.4);
  fail_unless(dim->getHeight() ==  5.5);
  fail_unless(dim->getDepth () == -6.6);
  
  delete bb;
}
END_TEST

START_TEST ( test_BoundingBox_setId )
{
  const char* id="BoundingBox";
  BB->setId(id);
  fail_unless(BB->isSetId() == true);
  fail_unless(BB->getId() == id);
}
END_TEST

START_TEST ( test_BoundingBox_setId_NULL )
{
  BB->setId("");
  fail_unless(BB->isSetId() == false);
  fail_unless(BB->getId() == "");
}
END_TEST

START_TEST ( test_BoundingBox_setPosition )
{
  Point pos=Point(LN,-1.1,2.2,-3.3);
  BB->setPosition(&pos);
  Point *pos2=BB->getPosition();
  fail_unless(pos2 != NULL);
  fail_unless(pos.getXOffset() == pos2->getXOffset() );
  fail_unless(pos.getYOffset() == pos2->getYOffset() );
  fail_unless(pos.getZOffset() == pos2->getZOffset() );
}
END_TEST

START_TEST ( test_BoundingBox_setPosition_NULL )
{
  BB->setPosition(NULL);
  Point *pos=BB->getPosition();
  fail_unless(pos != NULL);
  fail_unless(pos->getXOffset() == 0.0 );
  fail_unless(pos->getYOffset() == 0.0 );
  fail_unless(pos->getZOffset() == 0.0 );
}
END_TEST

START_TEST ( test_BoundingBox_setDimensions )
{
  Dimensions dim=Dimensions(LN,-4.4,5.5,-6.6);
  BB->setDimensions(&dim);
  Dimensions *dim2=BB->getDimensions();
  fail_unless(dim2 != NULL);
  fail_unless(dim.getWidth () == dim2->getWidth () );
  fail_unless(dim.getHeight() == dim2->getHeight() );
  fail_unless(dim.getDepth () == dim2->getDepth () );
}
END_TEST

START_TEST ( test_BoundingBox_setDimensions_NULL )
{
  BB->setDimensions(NULL);
  Dimensions *dim=BB->getDimensions();
  fail_unless(dim != NULL);
  fail_unless(dim->getWidth () == 0.0 );
  fail_unless(dim->getHeight() == 0.0 );
  fail_unless(dim->getDepth () == 0.0 );
}
END_TEST

START_TEST ( test_BoundingBox_copyConstructor )
{
  BoundingBox* bb1=new BoundingBox();
  XMLNode notes;
  bb1->setNotes(&notes);
  XMLNode annotation;
  bb1->setAnnotation(&annotation);
  BoundingBox* bb2=new BoundingBox(*bb1);
  delete bb2;
  delete bb1;
}
END_TEST

START_TEST ( test_BoundingBox_assignmentOperator )
{
  BoundingBox* bb1=new BoundingBox();
  XMLNode notes;
  bb1->setNotes(&notes);
  XMLNode annotation;
  bb1->setAnnotation(&annotation);
  BoundingBox bb2=*bb1;
  delete bb1;
}
END_TEST

Suite *
create_suite_BoundingBox (void)
{
  Suite *suite = suite_create("BoundingBox");
  TCase *tcase = tcase_create("BoundingBox");
  
  
  tcase_add_checked_fixture( tcase,
                            BoundingBoxTest_setup,
                            BoundingBoxTest_teardown );
  
  tcase_add_test( tcase, test_BoundingBox_create                     );
  tcase_add_test( tcase, test_BoundingBox_createWith                 );
  tcase_add_test( tcase, test_BoundingBox_createWith_NULL            );
  tcase_add_test( tcase, test_BoundingBox_createWithCoordinates_NULL );
  tcase_add_test( tcase,   test_BoundingBox_createWithCoordinates    );
  tcase_add_test( tcase, test_BoundingBox_setId                      );
  tcase_add_test( tcase, test_BoundingBox_setId_NULL                 );
  tcase_add_test( tcase, test_BoundingBox_setPosition                );
  tcase_add_test( tcase, test_BoundingBox_setPosition_NULL           );
  tcase_add_test( tcase, test_BoundingBox_setDimensions              );
  tcase_add_test( tcase, test_BoundingBox_setDimensions_NULL         );
  tcase_add_test( tcase, test_BoundingBox_copyConstructor            );
  tcase_add_test( tcase, test_BoundingBox_assignmentOperator         );
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}


CK_CPPEND
