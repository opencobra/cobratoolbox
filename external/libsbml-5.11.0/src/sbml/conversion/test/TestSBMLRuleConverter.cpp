/**
 * @file    TestSBMLRuleConverter.cpp
 * @brief   Tests for assignment rule sorter
 * @author  Frank Bergmann
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

#include <sbml/SBase.h>
#include <sbml/SBMLTypes.h>

#include <sbml/conversion/SBMLConverter.h>
#include <sbml/conversion/SBMLConverterRegistry.h>
#include <sbml/conversion/SBMLRuleConverter.h>

#include <sbml/math/FormulaParser.h>

#include <string>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS


extern char *TestDataDirectory;


START_TEST (test_conversion_ruleconverter_sort)
{

  // create test model

  SBMLDocument doc; 

  Model* model = doc.createModel();
  model->setId("m");

  Parameter* parameter1 = model->createParameter();
  parameter1->setId("s");
  parameter1->setConstant(false);
  parameter1->setValue(0);

  Parameter* parameter = model->createParameter();
  parameter->setId("p");
  parameter->setConstant(false);
  parameter->setValue(0);

  AssignmentRule* rule1 = model->createAssignmentRule();
  rule1->setVariable("s");
  rule1->setFormula("p + 1");
  rule1->setMetaId("m1");

  AssignmentRule* rule2 = model->createAssignmentRule();
  rule2->setVariable("p");
  rule2->setFormula("1");
  rule2->setMetaId("m2");

  ConversionProperties props;
  props.addOption("sortRules", true, "sort rules");

  SBMLConverter* converter = new SBMLRuleConverter();
  converter->setProperties(&props);
  converter->setDocument(&doc);
  
  fail_unless (converter->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (model->getNumRules() == 2);
  fail_unless (model->getRule(0)->getMetaId() == "m2");
  fail_unless (model->getRule(1)->getMetaId() == "m1");

  delete converter;
}
END_TEST


START_TEST (test_conversion_ruleconverter_dontSort)
{

  // create test model

  SBMLDocument doc; 

  Model* model = doc.createModel();
  model->setId("m");

  Parameter* parameter1 = model->createParameter();
  parameter1->setId("s");
  parameter1->setConstant(false);
  parameter1->setValue(0);

  Parameter* parameter = model->createParameter();
  parameter->setId("p");
  parameter->setConstant(false);
  parameter->setValue(0);

  AssignmentRule* rule2 = model->createAssignmentRule();
  rule2->setVariable("p");
  rule2->setFormula("1");
  rule2->setMetaId("m2");

  AssignmentRule* rule1 = model->createAssignmentRule();
  rule1->setVariable("s");
  rule1->setFormula("p + 1");
  rule1->setMetaId("m1");


  ConversionProperties props;
  props.addOption("sortRules", true, "sort rules");

  SBMLConverter* converter = new SBMLRuleConverter();
  converter->setProperties(&props);
  converter->setDocument(&doc);

  fail_unless (converter->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (model->getNumRules() == 2);
  fail_unless (model->getRule(0)->getMetaId() == "m2");
  fail_unless (model->getRule(1)->getMetaId() == "m1");

  delete converter;
}
END_TEST



START_TEST (test_conversion_ruleconverter_sortIA)
{

  // create test model

  SBMLDocument doc; 

  Model* model = doc.createModel();
  model->setId("m");

  Parameter* parameter1 = model->createParameter();
  parameter1->setId("s");
  parameter1->setConstant(false);
  parameter1->setValue(0);

  Parameter* parameter = model->createParameter();
  parameter->setId("p");
  parameter->setConstant(false);
  parameter->setValue(0);

  InitialAssignment* ia1 = model->createInitialAssignment();
  ia1->setSymbol("s");
  ASTNode * math = SBML_parseFormula("p + 1");
  ia1->setMath(math);
  delete math;
  ia1->setMetaId("m1");

  InitialAssignment* ia2 = model->createInitialAssignment();
  ia2->setSymbol("p");
  math = SBML_parseFormula("1");
  ia2->setMath(math);
  delete math;
  ia2->setMetaId("m2");

  ConversionProperties props;
  props.addOption("sortRules", true, "sort rules");

  SBMLConverter* converter = new SBMLRuleConverter();
  converter->setProperties(&props);
  converter->setDocument(&doc);
  
  fail_unless (converter->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (model->getNumInitialAssignments() == 2);
  fail_unless (model->getInitialAssignment(0)->getMetaId() == "m2");
  fail_unless (model->getInitialAssignment(1)->getMetaId() == "m1");

  delete converter;
}
END_TEST


START_TEST (test_conversion_ruleconverter_dontSortIA)
{

  // create test model

  SBMLDocument doc; 

  Model* model = doc.createModel();
  model->setId("m");

  Parameter* parameter1 = model->createParameter();
  parameter1->setId("s");
  parameter1->setConstant(false);
  parameter1->setValue(0);

  Parameter* parameter = model->createParameter();
  parameter->setId("p");
  parameter->setConstant(false);
  parameter->setValue(0);

  InitialAssignment* ia2 = model->createInitialAssignment();
  ia2->setSymbol("p");
  ASTNode * math = SBML_parseFormula("1");
  ia2->setMath(math);
  delete math;
  ia2->setMetaId("m2");
  
  InitialAssignment* ia1 = model->createInitialAssignment();
  ia1->setSymbol("s");
  math = SBML_parseFormula("p + 1");
  ia1->setMath(math);
  delete math;
  ia1->setMetaId("m1");

  ConversionProperties props;
  props.addOption("sortRules", true, "sort rules");

  SBMLConverter* converter = new SBMLRuleConverter();
  converter->setProperties(&props);
  converter->setDocument(&doc);
  
  fail_unless (converter->convert() == LIBSBML_OPERATION_SUCCESS);
  fail_unless (model->getNumInitialAssignments() == 2);
  fail_unless (model->getInitialAssignment(0)->getMetaId() == "m2");
  fail_unless (model->getInitialAssignment(1)->getMetaId() == "m1");

  delete converter;
}
END_TEST


START_TEST (test_conversion_ruleconverter_with_alg)
{
  // create test model

  SBMLDocument doc; 

  Model* model = doc.createModel();
  model->setId("m");

  Parameter* parameter1 = model->createParameter();
  parameter1->setId("s");
  parameter1->setConstant(false);
  parameter1->setValue(0);

  Parameter* parameter = model->createParameter();
  parameter->setId("p");
  parameter->setConstant(false);
  parameter->setValue(0);

  Parameter* parameter2 = model->createParameter();
  parameter2->setId("k");
  parameter2->setConstant(false);
  parameter2->setValue(0);

  AlgebraicRule* rule0 = model->createAlgebraicRule();
  rule0->setFormula("k + 2");
  rule0->setMetaId("m0");

  AssignmentRule* rule1 = model->createAssignmentRule();
  rule1->setVariable("s");
  rule1->setFormula("p + 1");
  rule1->setMetaId("m1");

  AssignmentRule* rule2 = model->createAssignmentRule();
  rule2->setVariable("p");
  rule2->setFormula("1");
  rule2->setMetaId("m2");

  ConversionProperties props;
  props.addOption("sortRules", true, "sort rules");

  SBMLConverter* converter = new SBMLRuleConverter();
  converter->setProperties(&props);
  converter->setDocument(&doc);
  fail_unless (converter->convert() == LIBSBML_OPERATION_SUCCESS);

  fail_unless (model->getNumRules() == 3);
  fail_unless (model->getRule(0)->getMetaId() == "m2");
  fail_unless (model->getRule(1)->getMetaId() == "m1");
  fail_unless (model->getRule(2)->getMetaId() == "m0");

  delete converter;
}
END_TEST


START_TEST (test_conversion_inlineFD_bug)
{
  std::string filename = "/inline_bug_minimal.xml";
  filename = TestDataDirectory + filename;
  SBMLDocument* doc = readSBMLFromFile(filename.c_str());

  ConversionProperties props;
  props.addOption("expandFunctionDefinitions", "true");

  fail_unless(doc->getModel() != NULL);
  fail_unless(doc->convert(props) == LIBSBML_OPERATION_SUCCESS);
  fail_unless(doc->getModel()->getNumReactions() == 1);
  fail_unless(doc->getModel()->getReaction(0)->isSetKineticLaw());
  fail_unless(doc->getModel()->getReaction(0)->getKineticLaw()->getMath() != NULL);

  // all seems good ... write it 
  const ASTNode * node = doc->getModel()->getReaction(0)->getKineticLaw()->getMath();
#ifndef LIBSBML_USE_LEGACY_MATH
  fail_unless(node->ASTBase::isChild() == false);
#endif
  std::string math = writeMathMLToStdString(node);
  ASTNode* test = readMathMLFromString(math.c_str());
  fail_unless(test != NULL);

  delete test;

  // additional test where the node being converted is the top-level
  fail_unless(doc->getModel()->getNumRules() == 1);
  fail_unless(doc->getModel()->getRule(0)->isSetMath());
  fail_unless(doc->getModel()->getRule(0)->getMath() != NULL);

  node = doc->getModel()->getRule(0)->getMath();
#ifndef LIBSBML_USE_LEGACY_MATH
  fail_unless(node->ASTBase::isChild() == false);
#endif
  math = writeMathMLToStdString(node);
  test = readMathMLFromString(math.c_str());
  fail_unless(test != NULL);

  delete test;
  delete doc;
}
END_TEST


Suite *
create_suite_TestSBMLRuleConverter (void)
{ 
  Suite *suite = suite_create("SBMLRuleConverter");
  TCase *tcase = tcase_create("SBMLRuleConverter");

  tcase_add_test(tcase, test_conversion_ruleconverter_sort);
  tcase_add_test(tcase, test_conversion_ruleconverter_dontSort);
  tcase_add_test(tcase, test_conversion_ruleconverter_with_alg);
  tcase_add_test(tcase, test_conversion_ruleconverter_sortIA);
  tcase_add_test(tcase, test_conversion_ruleconverter_dontSortIA);
  tcase_add_test(tcase, test_conversion_inlineFD_bug);
      

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

