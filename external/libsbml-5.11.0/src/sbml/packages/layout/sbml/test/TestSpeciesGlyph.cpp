/**
 * Filename    : TestSpeciesGlyph.cpp
 * Description : Unit tests for SpeciesGlyph
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


#include <sbml/packages/layout/sbml/SpeciesGlyph.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS


static SpeciesGlyph * SG;
static LayoutPkgNamespaces* LN;

void
SpeciesGlyphTest_setup (void)
{
  LN = new LayoutPkgNamespaces();
  SG = new (std::nothrow) SpeciesGlyph(LN);
  
  if (SG == NULL)
  {
    fail("new(std::nothrow) SpeciesGlyph() returned a NULL pointer.");
  }
  
}

void
SpeciesGlyphTest_teardown (void)
{
  delete SG;
  delete LN;
}

START_TEST ( test_SpeciesGlyph_new )
{
  fail_unless( SG->getTypeCode()    == SBML_LAYOUT_SPECIESGLYPH );
  fail_unless( SG->getMetaId()      == "" );
  //    fail_unless( SG->getNotes()       == "" );
  //    fail_unless( SG->getAnnotation()  == "" );
  fail_unless( SG->getId()          == "" );
  fail_unless( !SG->isSetId());
  fail_unless( !SG->isSetSpeciesId());
}
END_TEST

START_TEST ( test_SpeciesGlyph_new_with_id_and_speciesid)
{
  
  std::string id="TestSpeciesGlyph";
  std::string speciesId="TestSpecies";
  SpeciesGlyph* sg=new SpeciesGlyph(LN,id,speciesId);
  fail_unless(sg->isSetSpeciesId());
  fail_unless(sg->getSpeciesId()==speciesId);
  delete sg;
}
END_TEST

START_TEST ( test_SpeciesGlyph_setSpeciesId )
{
  std::string speciesId="TestSpeciesGlyph";
  SG->setSpeciesId(speciesId);
  fail_unless(SG->isSetSpeciesId());
  fail_unless(SG->getSpeciesId()==speciesId);
  speciesId="";
  SG->setSpeciesId(speciesId);
  fail_unless(!SG->isSetSpeciesId());
}
END_TEST

START_TEST ( test_SpeciesGlyph_copyConstructor )
{
  SpeciesGlyph* sg1=new SpeciesGlyph();
  XMLNode notes;
  sg1->setNotes(&notes);
  XMLNode annotation;
  sg1->setAnnotation(&annotation);
  SpeciesGlyph* sg2=new SpeciesGlyph(*sg1);
  delete sg2;
  delete sg1;
}
END_TEST

START_TEST ( test_SpeciesGlyph_assignmentOperator )
{
  SpeciesGlyph* sg1=new SpeciesGlyph();
  XMLNode notes;
  sg1->setNotes(&notes);
  XMLNode annotation;
  sg1->setAnnotation(&annotation);
  SpeciesGlyph sg2=*sg1;
  delete sg1;
}
END_TEST


Suite *
create_suite_SpeciesGlyph (void)
{
  Suite *suite = suite_create("SpeciesGlyph");
  TCase *tcase = tcase_create("SpeciesGlyph");
  
  tcase_add_checked_fixture( tcase,
                            SpeciesGlyphTest_setup,
                            SpeciesGlyphTest_teardown );
  
  tcase_add_test( tcase, test_SpeciesGlyph_new                       );
  tcase_add_test( tcase, test_SpeciesGlyph_new_with_id_and_speciesid );
  tcase_add_test( tcase, test_SpeciesGlyph_setSpeciesId              );
  tcase_add_test( tcase, test_SpeciesGlyph_copyConstructor           );
  tcase_add_test( tcase, test_SpeciesGlyph_assignmentOperator        );
  
  
  suite_add_tcase(suite, tcase);
  
  return suite;
}



END_C_DECLS
