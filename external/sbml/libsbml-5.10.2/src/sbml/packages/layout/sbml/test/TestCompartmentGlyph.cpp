/**
 * Filename    : TestCompartmentGlyph.cpp
 * Description : Unit tests for the CompartmentGlyph
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

#include <sbml/packages/layout/sbml/CompartmentGlyph.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

static CompartmentGlyph * CG;
static LayoutPkgNamespaces* LN;

void
CompartmentGlyphTest_setup (void)
{
  LN = new LayoutPkgNamespaces();
  CG = new (std::nothrow) CompartmentGlyph(LN);
  
  if (CG == NULL)
  {
    fail("new(std::nothrow) CompartmentGlyph() returned a NULL pointer.");
  }
  
}

void
CompartmentGlyphTest_teardown (void)
{
  delete CG;
  delete LN;
}

START_TEST ( test_CompartmentGlyph_new )
{
  fail_unless( CG->getPackageName() == "layout");
  fail_unless( CG->getTypeCode() == SBML_LAYOUT_COMPARTMENTGLYPH);
  fail_unless( CG->getMetaId()      == "" );
  //    fail_unless( CG->getNotes()       == "" );
  //    fail_unless( CG->getAnnotation()  == "" );
  fail_unless( CG->getId()          == "" );
  fail_unless( !CG->isSetId());
  fail_unless( !CG->isSetCompartmentId());
}
END_TEST

START_TEST ( test_CompartmentGlyph_new_with_id_and_compartmentid)
{
  std::string id="TestCompartmentGlyph";
  std::string compId="TestCompartment";
  CompartmentGlyph* cg=new CompartmentGlyph(LN,id,compId);
  fail_unless(cg->isSetCompartmentId());
  fail_unless(cg->getCompartmentId()==compId);
  delete cg;
}
END_TEST

START_TEST ( test_CompartmentGlyph_setCompartmentId )
{
  std::string compId="TestCompartmentGlyph";
  CG->setCompartmentId(compId);
  fail_unless(CG->isSetCompartmentId());
  fail_unless(CG->getCompartmentId()==compId);
  compId="";
  CG->setCompartmentId(compId);
  fail_unless(!CG->isSetCompartmentId());
}
END_TEST

START_TEST ( test_CompartmentGlyph_setOrder )
{
  double order=1.21;  
  fail_unless(CG->setOrder(order) == LIBSBML_OPERATION_SUCCESS);
  fail_unless(CG->isSetOrder());
  fail_unless(CG->getOrder()==order);
  fail_unless(CG->unsetOrder() == LIBSBML_OPERATION_SUCCESS);
  fail_unless(!CG->isSetOrder());
}
END_TEST

START_TEST ( test_CompartmentGlyph_copyConstructor )
{
  CompartmentGlyph* cg1=new CompartmentGlyph();
  XMLNode* notes=new XMLNode();
  cg1->setNotes(notes);
  XMLNode* annotation=new XMLNode();
  cg1->setAnnotation(annotation);
  CompartmentGlyph* cg2=new CompartmentGlyph(*cg1);
  delete cg2;
  delete cg1;
}
END_TEST

START_TEST ( test_CompartmentGlyph_assignmentOperator )
{
  CompartmentGlyph* cg1=new CompartmentGlyph();
  XMLNode* notes=new XMLNode();
  cg1->setNotes(notes);
  XMLNode* annotation=new XMLNode();
  cg1->setAnnotation(annotation);
  CompartmentGlyph* cg2=new CompartmentGlyph();
  (*cg2)=(*cg1);
  delete cg2;
  delete cg1;
}
END_TEST

Suite *
create_suite_CompartmentGlyph (void)
{
  Suite *suite = suite_create("CompartmentGlyph");
  TCase *tcase = tcase_create("CompartmentGlyph");
  
  tcase_add_checked_fixture( tcase,
                            CompartmentGlyphTest_setup,
                            CompartmentGlyphTest_teardown );
  
  
  tcase_add_test( tcase, test_CompartmentGlyph_new                           );
  tcase_add_test( tcase, test_CompartmentGlyph_new_with_id_and_compartmentid );
  tcase_add_test( tcase, test_CompartmentGlyph_setCompartmentId              );
  tcase_add_test( tcase, test_CompartmentGlyph_setOrder                      );
  tcase_add_test( tcase, test_CompartmentGlyph_copyConstructor               );
  tcase_add_test( tcase, test_CompartmentGlyph_assignmentOperator            );
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}



END_C_DECLS
