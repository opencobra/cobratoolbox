/**
 * @file    TestRenameIDs.cpp
 * @brief   RenameIDs unit tests
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



START_TEST (test_RenameIDs)
{
  SBMLReader        reader;
  SBMLDocument*     d;

  std::string filename(TestDataDirectory);
  filename += "multiple-ids.xml";


  d = reader.readSBML(filename);

  if (d == NULL || d->getModel() == NULL)
  {
    fail("readSBML(\"multiple-ids.xml\") returned a NULL pointer.");
  }
  SBase* obj;

  //Loop through every element in the model and rename everything.
  List* allelements = d->getAllElements();
  for (unsigned int el=0; el<allelements->getSize(); el++) {
    SBase* obj = static_cast<SBase*>(allelements->get(el));
    fail_unless(obj != NULL);
    obj->renameSIdRefs("comp", "comp_new");
    obj->renameSIdRefs("C", "C_new");
    obj->renameSIdRefs("conv", "conv_new");
    obj->renameSIdRefs("b", "b_new");
    obj->renameSIdRefs("b2", "b2_new");
    obj->renameSIdRefs("x", "x_new");
    obj->renameSIdRefs("y", "y_new"); //The 'y' here in the function definition not actually an SId, so this should have no effect.
    obj->renameUnitSIdRefs("volume", "volume_new");
    obj->renameUnitSIdRefs("substance", "substance_new");
    obj->renameUnitSIdRefs("item", "item_new");
    obj->renameUnitSIdRefs("second", "second_new");
    obj->renameUnitSIdRefs("litre", "litre_new");
    obj->renameUnitSIdRefs("candela", "candela_new");
    obj->renameUnitSIdRefs("farad", "farad_new");
    obj->renameUnitSIdRefs("coulomb", "coulomb_new");
  }
  //Function definition
  obj = d->getElementByMetaId("meta21");
  fail_unless(obj != NULL);
  char* xml = obj->toSBML();
  std::string xmlstr(xml);
  fail_unless(xmlstr.find("y_new") == std::string::npos);
  fail_unless(xmlstr.find("volume_new") != std::string::npos);
  safe_free(xml);

  //Compartment
  obj = d->getElementByMetaId("meta4");
  fail_unless(obj != NULL);
  Compartment* compartment = static_cast<Compartment*>(obj);
  fail_unless(compartment->getUnits() == "volume_new");

  //Species
  obj = d->getElementByMetaId("meta6");
  fail_unless(obj != NULL);
  Species* sp = static_cast<Species*>(obj);
  fail_unless(sp->getSubstanceUnits() == "substance_new");
  fail_unless(sp->getConversionFactor() == "conv_new");
  fail_unless(sp->getCompartment() == "comp_new");

  //Kinetic law
  obj = d->getElementByMetaId("meta11");
  fail_unless(obj != NULL);
  xml = obj->toSBML();
  xmlstr = xml;
  fail_unless(xmlstr.find("x_new") == std::string::npos);
  fail_unless(xmlstr.find("b_new") != std::string::npos);
  fail_unless(xmlstr.find("b2_new") != std::string::npos);
  fail_unless(xmlstr.find("volume_new") != std::string::npos);
  safe_free(xml);

  //Local parameter
  obj = d->getElementByMetaId("meta28");
  fail_unless(obj != NULL);
  LocalParameter* lp = static_cast<LocalParameter*>(obj);
  fail_unless(lp->getUnits() == "volume_new");

  //Species reference
  obj = d->getElementByMetaId("meta10");
  fail_unless(obj != NULL);
  SpeciesReference* sr = static_cast<SpeciesReference*>(obj);
  fail_unless(sr->getSpecies() == "b_new");

  //Modifier species reference
  obj = d->getElementByMetaId("meta10");
  fail_unless(obj != NULL);
  ModifierSpeciesReference* msr = static_cast<ModifierSpeciesReference*>(obj);
  fail_unless(msr->getSpecies() == "b_new");

  //Reaction
  obj = d->getElementByMetaId("meta8");
  fail_unless(obj != NULL);
  Reaction* rxn = static_cast<Reaction*>(obj);
  fail_unless(rxn->getCompartment() == "comp_new");

  //Parameter
  obj = d->getElementByMetaId("meta18");
  fail_unless(obj != NULL);
  Parameter* p = static_cast<Parameter*>(obj);
  fail_unless(p->getUnits() == "volume_new");

  //Trigger
  obj = d->getElementByMetaId("meta14");
  fail_unless(obj != NULL);
  xml = obj->toSBML();
  xmlstr = xml;
  fail_unless(xmlstr.find("b_new") != std::string::npos);
  fail_unless(xmlstr.find("volume_new") != std::string::npos);
  safe_free(xml);

  //Event assignment
  obj = d->getElementByMetaId("meta16");
  fail_unless(obj != NULL);
  xml = obj->toSBML();
  xmlstr = xml;
  fail_unless(xmlstr.find("b_new") != std::string::npos);
  fail_unless(xmlstr.find("volume_new") != std::string::npos);
  safe_free(xml);
  EventAssignment* ea = static_cast<EventAssignment*>(obj);
  fail_unless(ea->getVariable() == "b_new");

  //Delay
  obj = d->getElementByMetaId("meta17");
  fail_unless(obj != NULL);
  xml = obj->toSBML();
  xmlstr = xml;
  fail_unless(xmlstr.find("b_new") != std::string::npos);
  fail_unless(xmlstr.find("volume_new") != std::string::npos);
  safe_free(xml);

  //Priority
  obj = d->getElementByMetaId("meta19");
  fail_unless(obj != NULL);
  xml = obj->toSBML();
  xmlstr = xml;
  fail_unless(xmlstr.find("b_new") != std::string::npos);
  fail_unless(xmlstr.find("volume_new") != std::string::npos);
  safe_free(xml);

  //Initial assignment
  obj = d->getElementByMetaId("meta23");
  fail_unless(obj != NULL);
  xml = obj->toSBML();
  xmlstr = xml;
  fail_unless(xmlstr.find("x_new") != std::string::npos);
  fail_unless(xmlstr.find("volume_new") != std::string::npos);
  safe_free(xml);
  InitialAssignment* ia = static_cast<InitialAssignment*>(obj);
  fail_unless(ia->getSymbol() == "b_new");

  //Rate rule
  obj = d->getElementByMetaId("meta25");
  fail_unless(obj != NULL);
  xml = obj->toSBML();
  xmlstr = xml;
  fail_unless(xmlstr.find("b_new") != std::string::npos);
  fail_unless(xmlstr.find("volume_new") != std::string::npos);
  safe_free(xml);
  RateRule* rr = static_cast<RateRule*>(obj);
  fail_unless(rr->getVariable() == "x_new"); 

  //Assignment rule
  obj = d->getElementByMetaId("meta26");
  fail_unless(obj != NULL);
  xml = obj->toSBML();
  xmlstr = xml;
  fail_unless(xmlstr.find("b_new") != std::string::npos);
  fail_unless(xmlstr.find("volume_new") != std::string::npos);
  safe_free(xml);
  AssignmentRule* ar = static_cast<AssignmentRule*>(obj);
  fail_unless(ar->getVariable() == "C_new");

  //Model
  obj = d->getElementByMetaId("meta2");
  fail_unless(obj != NULL);
  Model* mod=static_cast<Model*>(obj);
  fail_unless(mod->getConversionFactor() == "conv_new");
  fail_unless(mod->getSubstanceUnits() == "item_new");
  fail_unless(mod->getTimeUnits() == "second_new");
  fail_unless(mod->getVolumeUnits() == "litre_new");
  fail_unless(mod->getAreaUnits() == "candela_new");
  fail_unless(mod->getLengthUnits() == "farad_new");
  fail_unless(mod->getExtentUnits() == "coulomb_new");

  delete d;
  delete allelements;
}
END_TEST




Suite *
create_suite_RenameIDs (void)
{
  Suite *suite = suite_create("RenameIDs");
  TCase *tcase = tcase_create("RenameIDs");


  tcase_add_test(tcase, test_RenameIDs);


  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
