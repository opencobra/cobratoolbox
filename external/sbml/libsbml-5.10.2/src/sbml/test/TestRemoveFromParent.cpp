/**
 * @file    TestRemoveFromParent.cpp
 * @brief   RemoveFromParent unit tests
 * @author  Lucian Smith
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


#include <check.h>

#include <iostream>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

extern char *TestDataDirectory;



START_TEST (test_RemoveFromParent_successfulRemoves)
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
  SBase* obj;

  //Document
  obj = d->getElementByMetaId("meta1");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_FAILED); //Can't remove the SBML document itself.

  //Function definition
  obj = d->getElementByMetaId("meta21");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta21");
  fail_unless(obj == NULL);

  //List of function definitions
  obj = d->getElementByMetaId("meta20");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta20");
  fail_unless(obj == NULL);

  //Unit
  obj = d->getElementByMetaId("meta32");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta32");
  fail_unless(obj == NULL);

  //List of units
  obj = d->getElementByMetaId("meta31");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta31");
  fail_unless(obj == NULL);

  //Unit Definition
  obj = d->getElementByMetaId("meta30");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta30");
  fail_unless(obj == NULL);

  //List of unit definitions
  obj = d->getElementByMetaId("meta29");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta29");
  fail_unless(obj == NULL);

  //Compartment
  obj = d->getElementByMetaId("meta4");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta4");
  fail_unless(obj == NULL);

  //List of compartments
  obj = d->getElementByMetaId("meta3");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta3");
  fail_unless(obj == NULL);

  //Species
  obj = d->getElementByMetaId("meta6");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta6");
  fail_unless(obj == NULL);

  //List of species
  obj = d->getElementByMetaId("meta5");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta5");
  fail_unless(obj == NULL);

  //Local parameter
  obj = d->getElementByMetaId("meta28");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta28");
  fail_unless(obj == NULL);

  //List of local parameters
  obj = d->getElementByMetaId("meta27");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta27");
  fail_unless(obj == NULL);

  //Kinetic law
  obj = d->getElementByMetaId("meta11");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta11");
  fail_unless(obj == NULL);

  //Species reference
  obj = d->getElementByMetaId("meta10");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta10");
  fail_unless(obj == NULL);

  //List of reactants
  obj = d->getElementByMetaId("meta9");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta9");
  fail_unless(obj == NULL);

  //Modifier species reference
  obj = d->getElementByMetaId("meta35");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta35");
  fail_unless(obj == NULL);

  //List of modifiers
  obj = d->getElementByMetaId("meta34");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta34");
  fail_unless(obj == NULL);

  //Reaction
  obj = d->getElementByMetaId("meta8");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta8");
  fail_unless(obj == NULL);

  //List of reactions
  obj = d->getElementByMetaId("meta7");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta7");
  fail_unless(obj == NULL);

  //Parameter
  obj = d->getElementByMetaId("meta18");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta18");
  fail_unless(obj == NULL);

  //List of parameters
  obj = d->getElementByMetaId("meta33");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta33");
  fail_unless(obj == NULL);

  //Trigger
  obj = d->getElementByMetaId("meta14");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta14");
  fail_unless(obj == NULL);

  //Event assignment
  obj = d->getElementByMetaId("meta16");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta16");
  fail_unless(obj == NULL);

  //List of event assignments
  obj = d->getElementByMetaId("meta15");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta15");
  fail_unless(obj == NULL);

  //Delay
  obj = d->getElementByMetaId("meta17");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta17");
  fail_unless(obj == NULL);

  //Priority
  obj = d->getElementByMetaId("meta19");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta19");
  fail_unless(obj == NULL);

  //Event
  obj = d->getElementByMetaId("meta13");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta13");
  fail_unless(obj == NULL);

  //List of events
  obj = d->getElementByMetaId("meta12");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta12");
  fail_unless(obj == NULL);

  //Initial assignment
  obj = d->getElementByMetaId("meta23");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta23");
  fail_unless(obj == NULL);

  //List of initial assignments
  obj = d->getElementByMetaId("meta22");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta22");
  fail_unless(obj == NULL);

  //Rate rule
  obj = d->getElementByMetaId("meta25");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta25");
  fail_unless(obj == NULL);

  //Assignment rule
  obj = d->getElementByMetaId("meta26");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta26");
  fail_unless(obj == NULL);

  //List of rules
  obj = d->getElementByMetaId("meta24");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta24");
  fail_unless(obj == NULL);

  //Model
  obj = d->getElementByMetaId("meta2");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta2");
  fail_unless(obj == NULL);


  delete d;
}
END_TEST

START_TEST (test_RemoveFromParent_alreadyRemoved)
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
  SBase* obj;

  //List of function definitions
  obj = d->getElementByMetaId("meta20");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta20");
  fail_unless(obj == NULL);

  //Function definition
  obj = d->getElementByMetaId("meta21");
  fail_unless(obj == NULL);

  //Unit Definition
  obj = d->getElementByMetaId("meta30");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta30");
  fail_unless(obj == NULL);

  //Unit
  obj = d->getElementByMetaId("meta32");
  fail_unless(obj == NULL);

  //List of units
  obj = d->getElementByMetaId("meta31");
  fail_unless(obj == NULL);

  //List of compartments
  obj = d->getElementByMetaId("meta3");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta3");
  fail_unless(obj == NULL);

  //Compartment
  obj = d->getElementByMetaId("meta4");
  fail_unless(obj == NULL);

  //List of species
  obj = d->getElementByMetaId("meta5");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta5");
  fail_unless(obj == NULL);

  //Species
  obj = d->getElementByMetaId("meta6");
  fail_unless(obj == NULL);

  //Kinetic law
  obj = d->getElementByMetaId("meta11");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta11");
  fail_unless(obj == NULL);

  //Local parameter
  obj = d->getElementByMetaId("meta28");
  fail_unless(obj == NULL);

  //List of local parameters
  obj = d->getElementByMetaId("meta27");
  fail_unless(obj == NULL);

  //List of modifiers
  obj = d->getElementByMetaId("meta34");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta34");
  fail_unless(obj == NULL);

  //Modifier species reference
  obj = d->getElementByMetaId("meta35");
  fail_unless(obj == NULL);

  //Reaction
  obj = d->getElementByMetaId("meta8");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta8");
  fail_unless(obj == NULL);

  //Species reference
  obj = d->getElementByMetaId("meta10");
  fail_unless(obj == NULL);

  //List of reactants
  obj = d->getElementByMetaId("meta9");
  fail_unless(obj == NULL);

  //List of parameters
  obj = d->getElementByMetaId("meta33");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta33");
  fail_unless(obj == NULL);

  //Parameter
  obj = d->getElementByMetaId("meta18");
  fail_unless(obj == NULL);

  //List of event assignments
  obj = d->getElementByMetaId("meta15");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta15");
  fail_unless(obj == NULL);

  //Event assignment
  obj = d->getElementByMetaId("meta16");
  fail_unless(obj == NULL);

  //Event
  obj = d->getElementByMetaId("meta13");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta13");
  fail_unless(obj == NULL);

  //Trigger
  obj = d->getElementByMetaId("meta14");
  fail_unless(obj == NULL);

  //Delay
  obj = d->getElementByMetaId("meta17");
  fail_unless(obj == NULL);

  //Priority
  obj = d->getElementByMetaId("meta19");
  fail_unless(obj == NULL);

  //List of initial assignments
  obj = d->getElementByMetaId("meta22");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta22");
  fail_unless(obj == NULL);

  //Initial assignment
  obj = d->getElementByMetaId("meta23");
  fail_unless(obj == NULL);

  //List of rules
  obj = d->getElementByMetaId("meta24");
  fail_unless(obj != NULL);
  fail_unless(obj->removeFromParentAndDelete() == LIBSBML_OPERATION_SUCCESS);
  obj = d->getElementByMetaId("meta24");
  fail_unless(obj == NULL);

  //Rate rule
  obj = d->getElementByMetaId("meta25");
  fail_unless(obj == NULL);

  //Assignment rule
  obj = d->getElementByMetaId("meta26");
  fail_unless(obj == NULL);


  delete d;
}
END_TEST



Suite *
create_suite_RemoveFromParent (void)
{
  Suite *suite = suite_create("RemoveFromParent");
  TCase *tcase = tcase_create("RemoveFromParent");


  tcase_add_test(tcase, test_RemoveFromParent_successfulRemoves);
  tcase_add_test(tcase, test_RemoveFromParent_alreadyRemoved);


  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
