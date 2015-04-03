/**
 * @file    TestGetMultipleObjects.cpp
 * @brief   GetMultipleObjects unit tests
 * @author  Sarah Keating
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
 * Copyright (C) 2006-2008 by the California Institute of Technology,
 *     Pasadena, CA, USA 
 *  
 * Copyright (C) 2002-2005 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. Japan Science and Technology Agency, Japan
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#include <sbml/common/common.h>
#include <sbml/common/extern.h>
#include <sbml/SBMLReader.h>
#include <sbml/SBMLTypes.h>

#include <sbml/util/ElementFilter.h>

#include <check.h>

#include <iostream>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

extern char *TestDataDirectory;



START_TEST (test_GetMultipleObjects_getId)
{
  SBMLReader        reader;
  SBMLDocument*     d;

  std::string filename(TestDataDirectory);
  filename += "multiple-ids.xml";


  d = reader.readSBML(filename);

 if (d == NULL)
  {
    fail("readSBML(\"multiple-ids.xml\") returned a NULL pointer.");
  }

  SBase* obj = d->getElementBySId("no_id");
  fail_unless(obj == NULL);

  obj = d->getElementBySId("");
  fail_unless(obj == NULL);

  obj = d->getElementBySId("find_id");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_MODEL);

  obj = d->getElementBySId("func1");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_FUNCTION_DEFINITION);

  obj = d->getElementBySId("comp");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_COMPARTMENT);

  obj = d->getElementBySId("b");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_SPECIES);

  obj = d->getElementBySId("x");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_PARAMETER);

  obj = d->getElementBySId("J0");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_REACTION);

  obj = d->getElementBySId("E0");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_EVENT);

  delete d;
}
END_TEST


START_TEST (test_GetMultipleObjects_getMetaId)
{
  SBMLReader        reader;
  SBMLDocument*     d;

  std::string filename(TestDataDirectory);
  filename += "multiple-ids.xml";


  d = reader.readSBML(filename);

  if (d == NULL)
  {
    fail("readSBML(\"multiple-ids.xml\") returned a NULL pointer.");
  }

  SBase* obj = d->getElementByMetaId("no_id");
  fail_unless(obj == NULL);

  obj = d->getElementByMetaId("");
  fail_unless(obj == NULL);

  obj = d->getElementByMetaId("meta1");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_DOCUMENT);

  obj = d->getElementByMetaId("meta2");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_MODEL);

  obj = d->getElementByMetaId("meta3");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_COMPARTMENT);

  obj = d->getElementByMetaId("meta4");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_COMPARTMENT);

  obj = d->getElementByMetaId("meta5");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_SPECIES);

  obj = d->getElementByMetaId("meta6");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_SPECIES);

  obj = d->getElementByMetaId("meta7");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_REACTION);

  obj = d->getElementByMetaId("meta8");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_REACTION);

  obj = d->getElementByMetaId("meta9");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_SPECIES_REFERENCE);

  obj = d->getElementByMetaId("meta10");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_SPECIES_REFERENCE);

  obj = d->getElementByMetaId("meta11");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_KINETIC_LAW);

  obj = d->getElementByMetaId("meta12");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_EVENT);

  obj = d->getElementByMetaId("meta13");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_EVENT);

  obj = d->getElementByMetaId("meta14");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_TRIGGER);

  obj = d->getElementByMetaId("meta15");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_EVENT_ASSIGNMENT);

  obj = d->getElementByMetaId("meta16");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_EVENT_ASSIGNMENT);

  obj = d->getElementByMetaId("meta17");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_DELAY);

  obj = d->getElementByMetaId("meta18");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_PARAMETER);

  obj = d->getElementByMetaId("meta19");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_PRIORITY);

  obj = d->getElementByMetaId("meta20");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_FUNCTION_DEFINITION);

  obj = d->getElementByMetaId("meta21");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_FUNCTION_DEFINITION);

  obj = d->getElementByMetaId("meta22");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_INITIAL_ASSIGNMENT);

  obj = d->getElementByMetaId("meta23");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_INITIAL_ASSIGNMENT);

  obj = d->getElementByMetaId("meta24");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_RULE);

  obj = d->getElementByMetaId("meta25");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_RATE_RULE);

  obj = d->getElementByMetaId("meta26");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_ASSIGNMENT_RULE);

  obj = d->getElementByMetaId("meta27");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_LOCAL_PARAMETER);

  obj = d->getElementByMetaId("meta28");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LOCAL_PARAMETER);

  obj = d->getElementByMetaId("meta29");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_UNIT_DEFINITION);

  obj = d->getElementByMetaId("meta30");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_UNIT_DEFINITION);

  obj = d->getElementByMetaId("meta31");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_UNIT);

  obj = d->getElementByMetaId("meta32");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_UNIT);

  obj = d->getElementByMetaId("meta33");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_PARAMETER);

  obj = d->getElementByMetaId("meta34");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LIST_OF);
  fail_unless(static_cast<ListOf*>(obj)->getItemTypeCode() == SBML_MODIFIER_SPECIES_REFERENCE);

  obj = d->getElementByMetaId("meta35");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_MODIFIER_SPECIES_REFERENCE);


  delete d;
}
END_TEST

START_TEST (test_GetMultipleObjects_noLocalParameters)
{
  SBMLReader        reader;
  SBMLDocument*     d;

  std::string filename(TestDataDirectory);
  filename += "multiple-ids.xml";


  d = reader.readSBML(filename);

 if (d == NULL)
  {
    fail("readSBML(\"multiple-ids.xml\") returned a NULL pointer.");
  }

  SBase* rxn = d->getElementBySId("J0");
  fail_unless(rxn != NULL);
  SBase* obj = rxn->getElementBySId("x");
  fail_unless(obj == NULL);
  obj = rxn->getElementByMetaId("meta28");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_LOCAL_PARAMETER);


  delete d;
}
END_TEST


START_TEST (test_GetMultipleObjects_noUnits)
{
  SBMLReader        reader;
  SBMLDocument*     d;

  std::string filename(TestDataDirectory);
  filename += "multiple-ids.xml";


  d = reader.readSBML(filename);

 if (d == NULL)
  {
    fail("readSBML(\"multiple-ids.xml\") returned a NULL pointer.");
  }

  SBase* obj = d->getElementBySId("volume");
  fail_unless(obj == NULL);
  obj = d->getElementByMetaId("meta30");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_UNIT_DEFINITION);


  delete d;
}
END_TEST


START_TEST (test_GetMultipleObjects_noAssignments)
{
  SBMLReader        reader;
  SBMLDocument*     d;

  std::string filename(TestDataDirectory);
  filename += "assignments-invalid.xml";


  d = reader.readSBML(filename);

 if (d->getModel() == NULL)
  {
    fail("readSBML(\"assignments-invalid.xml\") returned an empty model.");
  }

  SBase* obj = d->getElementBySId("ia");
  fail_unless(obj == NULL);
  obj = d->getElementByMetaId("ia_meta");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_INITIAL_ASSIGNMENT);

  obj = d->getElementBySId("ar");
  fail_unless(obj == NULL);
  obj = d->getElementByMetaId("ar_meta");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_ASSIGNMENT_RULE);

  obj = d->getElementBySId("rr");
  fail_unless(obj == NULL);
  obj = d->getElementByMetaId("rr_meta");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_RATE_RULE);

  obj = d->getElementBySId("ea");
  fail_unless(obj == NULL);
  obj = d->getElementByMetaId("ea_meta");
  fail_unless(obj != NULL);
  fail_unless(obj->getTypeCode() == SBML_EVENT_ASSIGNMENT);


  delete d;
}
END_TEST


START_TEST (test_GetMultipleObjects_allElements)
{
  SBMLReader        reader;
  SBMLDocument*     d;

  std::string filename(TestDataDirectory);
  filename += "multiple-ids.xml";


  d = reader.readSBML(filename);

 if (d->getModel() == NULL)
  {
    fail("readSBML(\"multiple-ids.xml\") returned a NULL pointer.");
  }

  List* list = d->getAllElements();
  fail_unless(list->getSize() == 37);
  delete list;
  delete d;
}
END_TEST


class TestFilter : public ElementFilter
{
public: 
   virtual bool filter(const SBase* element)
   {
     // filter for const parameters (of which there is only one in the model)
     // that one has id 'conv' which is what is tested for
     const Parameter* p = dynamic_cast<const Parameter*>(element);
     return p != NULL && p->isSetConstant() && p->getConstant() == true;
   }
};

START_TEST (test_GetMultipleObjects_withFilter)
{
  SBMLReader        reader;
  SBMLDocument*     d;

  std::string filename(TestDataDirectory);
  filename += "multiple-ids.xml";


  d = reader.readSBML(filename);

 if (d->getModel() == NULL)
  {
    fail("readSBML(\"multiple-ids.xml\") returned a NULL pointer.");
  }

 TestFilter test;
 List* list = d->getAllElements(&test);
 fail_unless(list->getSize() == 1);
 fail_unless(static_cast<SBase*>(list->get(0))->getId() == "conv");
 delete list;
  delete d;
}
END_TEST

Suite *
create_suite_GetMultipleObjects (void)
{
  Suite *suite = suite_create("GetMultipleObjects");
  TCase *tcase = tcase_create("GetMultipleObjects");


  tcase_add_test(tcase, test_GetMultipleObjects_getId);
  tcase_add_test(tcase, test_GetMultipleObjects_getMetaId);
  tcase_add_test(tcase, test_GetMultipleObjects_noLocalParameters);
  tcase_add_test(tcase, test_GetMultipleObjects_noUnits);
  tcase_add_test(tcase, test_GetMultipleObjects_noAssignments);
  tcase_add_test(tcase, test_GetMultipleObjects_allElements);
  tcase_add_test(tcase, test_GetMultipleObjects_withFilter);


  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
