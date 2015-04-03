/**
 * Filename    : TestTextGlyph.cpp
 * Description : Unit tests for TextGlyph
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

#include <sbml/packages/layout/sbml/TextGlyph.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

static TextGlyph * TG;
static LayoutPkgNamespaces* LN;

void
TextGlyphTest_setup (void)
{
  LN = new LayoutPkgNamespaces();
  TG = new TextGlyph(LN);
  
  if (TG == NULL)
  {
    fail("new(std::nothrow) TextGlyph() returned a NULL pointer.");
  }
  
}

void
TextGlyphTest_teardown (void)
{
  delete TG;
  delete LN;
}


CK_CPPSTART

START_TEST ( test_TextGlyph_new )
{
  fail_unless( TG->getTypeCode()    == SBML_LAYOUT_TEXTGLYPH );
  fail_unless( TG->getMetaId()      == "" );
  //    fail_unless( TG->getNotes()       == "" );
  //    fail_unless( TG->getAnnotation()  == "" );
  fail_unless( TG->getId()          == "" );
  fail_unless( !TG->isSetId());
  fail_unless( !TG->isSetText());
  fail_unless( !TG->isSetGraphicalObjectId());
  fail_unless( !TG->isSetOriginOfTextId());
}
END_TEST

START_TEST ( test_TextGlyph_new_with_text )
{
  std::string id="TestTextGlyphId";
  std::string text="TestTextGlyph";
  TextGlyph* tg=new TextGlyph(LN,id,text);
  fail_unless( tg->getTypeCode()    == SBML_LAYOUT_TEXTGLYPH );
  fail_unless( tg->getMetaId()      == "" );
  //    fail_unless( tg->getNotes()       == "" );
  //    fail_unless( tg->getAnnotation()  == "" );
  fail_unless( tg->getId()          == id );
  fail_unless( tg->isSetId());
  fail_unless( tg->isSetText());
  fail_unless( tg->getText()        == text );
  fail_unless( !tg->isSetGraphicalObjectId());
  fail_unless( !tg->isSetOriginOfTextId());
  delete tg;
}
END_TEST

START_TEST ( test_TextGlyph_setText )
{
  std::string text="TestTextGlyph";
  TG->setText(text);
  fail_unless ( TG->isSetText());
  fail_unless (TG->getText() == text );
}
END_TEST

START_TEST ( test_TextGlyph_setGraphicalObjectId )
{
  std::string id="SomeSpeciesGlyphId";
  TG->setGraphicalObjectId(id);
  fail_unless ( TG->isSetGraphicalObjectId());
  fail_unless ( TG->getGraphicalObjectId() == id );
}
END_TEST

START_TEST ( test_TextGlyph_setOriginOfTextId )
{
  std::string id="SomeSpeciesGlyphId";
  TG->setOriginOfTextId(id);
  fail_unless ( TG->isSetOriginOfTextId());
  fail_unless ( TG->getOriginOfTextId() == id );
}
END_TEST

START_TEST ( test_TextGlyph_copyConstructor )
{
  TextGlyph* tg1=new TextGlyph();
  XMLNode notes;
  tg1->setNotes(&notes);
  XMLNode annotation;
  tg1->setAnnotation(&annotation);
  TextGlyph* tg2=new TextGlyph(*tg1);
  delete tg2;
  delete tg1;
}
END_TEST

START_TEST ( test_TextGlyph_assignmentOperator )
{
  TextGlyph* tg1=new TextGlyph();
  XMLNode notes;
  tg1->setNotes(&notes);
  XMLNode annotation;
  tg1->setAnnotation(&annotation);
  TextGlyph tg2=*tg1;
  delete tg1;
}
END_TEST

Suite *
create_suite_TextGlyph (void)
{
  Suite *suite = suite_create("TextGlyph");
  TCase *tcase = tcase_create("TextGlyph");
  
  tcase_add_checked_fixture( tcase,
                            TextGlyphTest_setup,
                            TextGlyphTest_teardown );
  
  
  tcase_add_test(tcase , test_TextGlyph_new                  );
  tcase_add_test(tcase , test_TextGlyph_new_with_text        );
  tcase_add_test(tcase , test_TextGlyph_setText              );
  tcase_add_test(tcase , test_TextGlyph_setGraphicalObjectId );
  tcase_add_test(tcase , test_TextGlyph_setOriginOfTextId    );
  tcase_add_test( tcase, test_TextGlyph_copyConstructor      );
  tcase_add_test( tcase, test_TextGlyph_assignmentOperator   );
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}




CK_CPPEND
