/**
 * @file    TestConversionProperties.cpp
 * @brief   Tests for creating conversion properties
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
#include <sbml/conversion/ConversionProperties.h>


#include <string>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS


extern char *TestDataDirectory;


START_TEST (test_conversion_properties_read)
{

  ConversionProperties props;

  fail_unless(props.hasTargetNamespaces() == false);
  fail_unless(props.hasOption("nonexistent") == false);

  ConversionOption* option = new ConversionOption("strict", "true", CNV_TYPE_BOOL, "observe validation rules");
  props.addOption(*option);
  delete option;

  fail_unless(props.hasOption("strict") == true);
  fail_unless(props.getValue("strict") == "true");
  fail_unless(props.getBoolValue("strict") == true);
  
  props.setValue("strict", "false");
  fail_unless(props.getBoolValue("strict") == false);

  props.setBoolValue("strict", true);
  fail_unless(props.getBoolValue("strict") == true);

  props.setIntValue("strict", (int)false);
  fail_unless(props.getBoolValue("strict") == false);
}
END_TEST

START_TEST (test_conversion_properties_exceptions)
{
  int value = 0;

  // null copy constructor
  try
  {
    ConversionProperties *props = NULL;
    new ConversionProperties(*props);
  }
  catch(SBMLConstructorException& )
  {
    value = 1;
  }
  fail_unless(value == 1);

  value = 0;
  // null assignment op
  try
  {
    ConversionProperties *props = NULL;
    ConversionProperties props1 = *props;
  }
  catch(SBMLConstructorException& )
  {
    value = 1;
  }
  fail_unless(value == 1);
}
END_TEST

START_TEST (test_conversion_properties_write)
{
  ConversionProperties props;

  props.addOption("key", "test", "test option");

  fail_unless(props.getValue("key") == "test");
  fail_unless(props.getType("key") == CNV_TYPE_STRING);
  fail_unless(props.getDescription("key") == "test option");
  

  props.setBoolValue("key", true);
  fail_unless(props.getBoolValue("key") == true);
  fail_unless(props.getType("key") == CNV_TYPE_BOOL);
  
  props.setIntValue("key", 2);
  fail_unless(props.getIntValue("key") == 2);
  fail_unless(props.getType("key") == CNV_TYPE_INT);
  
  props.setFloatValue("key", 1.1f);
  fail_unless(props.getFloatValue("key") == 1.1f);
  fail_unless(props.getType("key") == CNV_TYPE_SINGLE);
  
  props.setDoubleValue("key", 2.1);
  fail_unless(props.getDoubleValue("key") == 2.1);
  fail_unless(props.getType("key") == CNV_TYPE_DOUBLE);
  
}
END_TEST

START_TEST (test_conversion_properties_clone)
{
  ConversionProperties props;

  props.addOption("key", "test", "test option");
  fail_unless(props.getValue("key") == "test");
  fail_unless(props.getType("key") == CNV_TYPE_STRING);
  fail_unless(props.getDescription("key") == "test option");

  ConversionProperties *prop1 = props.clone();
  fail_unless(prop1->getValue("key") == "test");
  fail_unless(prop1->getType("key") == CNV_TYPE_STRING);
  fail_unless(prop1->getDescription("key") == "test option");

  delete prop1;

}
END_TEST



START_TEST (test_conversion_properties_assign)
{
  ConversionProperties props;

  props.addOption("key", "test", "test option");
  fail_unless(props.getValue("key") == "test");
  fail_unless(props.getType("key") == CNV_TYPE_STRING);
  fail_unless(props.getDescription("key") == "test option");

  ConversionProperties props2 = props;
  fail_unless(props2.getValue("key") == "test");
  fail_unless(props2.getType("key") == CNV_TYPE_STRING);
  fail_unless(props2.getDescription("key") == "test option");

  props2 = ConversionProperties();
  fail_unless(props2.hasOption("key") == false);

}
END_TEST


Suite *
create_suite_TestConversionProperties (void)
{ 
  Suite *suite = suite_create("ConversionProperties");
  TCase *tcase = tcase_create("ConversionProperties");

  tcase_add_test(tcase, test_conversion_properties_read);
  tcase_add_test(tcase, test_conversion_properties_write);
  tcase_add_test(tcase, test_conversion_properties_exceptions);
  tcase_add_test(tcase, test_conversion_properties_clone);
  tcase_add_test(tcase, test_conversion_properties_assign);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

