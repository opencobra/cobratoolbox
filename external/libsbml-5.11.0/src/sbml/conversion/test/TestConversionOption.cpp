/**
 * @file    TestConversionOption.cpp
 * @brief   Tests for creating conversion options
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

#include <sbml/SBMLReader.h>
#include <sbml/SBMLTypes.h>

#include <sbml/conversion/ConversionOption.h>



#include <string>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS


extern char *TestDataDirectory;


START_TEST (test_conversion_options_read)
{
  ConversionOption option("key");
  
  fail_unless(option.getKey() == "key");
  fail_unless(option.getValue() == "");
  fail_unless(option.getType() == CNV_TYPE_STRING);
  fail_unless(option.getDescription() == "");

  option.setDescription("Something");
  fail_unless(option.getDescription() == "Something");

  option.setValue("Something");
  fail_unless(option.getValue() == "Something");

  option.setType(CNV_TYPE_BOOL);
  fail_unless(option.getType() == CNV_TYPE_BOOL);

}
END_TEST

START_TEST (test_conversion_options_convert)
{
  ConversionOption option("key", "1");
  fail_unless(option.getKey() == "key");
  fail_unless(option.getValue() == "1");
  fail_unless(option.getIntValue() == 1);
  fail_unless(option.getDoubleValue() == 1.0);
  fail_unless(option.getFloatValue() == 1.0f);
  fail_unless(option.getBoolValue() == ((bool)1));

}
END_TEST


  START_TEST (test_conversion_options_readWrite)
{
  ConversionOption option("key", true, "");
  fail_unless(option.getBoolValue() == true);
  fail_unless(option.getValue() == "true");

  option.setBoolValue(false);
  fail_unless(option.getBoolValue() == false);
  fail_unless(option.getType() == CNV_TYPE_BOOL);

  option.setIntValue(0);
  fail_unless(option.getBoolValue() == false);

  option.setIntValue(1);
  fail_unless(option.getBoolValue() == true);

}
END_TEST

START_TEST (test_conversion_options_set)
{
  ConversionOption option("key", "test", "");
  fail_unless(option.getValue() == "test");
  fail_unless(option.getType() == CNV_TYPE_STRING);

  option.setFloatValue(1.1f);
  fail_unless(option.getFloatValue() == 1.1f );
  fail_unless(option.getType() == CNV_TYPE_SINGLE);

  option.setDoubleValue(2.1);
  fail_unless(option.getDoubleValue() == 2.1 );
  fail_unless(option.getType() == CNV_TYPE_DOUBLE);

  option.setIntValue(3);
  fail_unless(option.getIntValue() == 3 );
  fail_unless(option.getType() == CNV_TYPE_INT);

  option.setBoolValue(true);
  fail_unless(option.getBoolValue() == true );
  fail_unless(option.getType() == CNV_TYPE_BOOL);

}
END_TEST

START_TEST (test_conversion_options_constructor)
{
  ConversionOption option1("key", "test", "");
  fail_unless(option1.getValue() == "test");
  fail_unless(option1.getType() == CNV_TYPE_STRING);

  ConversionOption option2("key", 1.1, "");
  fail_unless(option2.getDoubleValue() == 1.1);
  fail_unless(option2.getType() == CNV_TYPE_DOUBLE);

  ConversionOption option3("key", 1.1f, "");
  fail_unless(option3.getFloatValue() == 1.1f);
  fail_unless(option3.getType() == CNV_TYPE_SINGLE);

  ConversionOption option4("key", 10, "");
  fail_unless(option4.getIntValue() == 10);
  fail_unless(option4.getType() == CNV_TYPE_INT);

  ConversionOption option5("key", false, "");
  fail_unless(option5.getBoolValue() == false);
  fail_unless(option5.getType() == CNV_TYPE_BOOL);

}
END_TEST

START_TEST (test_conversion_options_clone)
{
  ConversionOption option("key", 1.1, "some description");
  fail_unless(option.getDoubleValue() == 1.1);
  fail_unless(option.getType() == CNV_TYPE_DOUBLE);

  ConversionOption *clone = option.clone();

  fail_unless(option.getKey() == clone->getKey());
  fail_unless(option.getType() == clone->getType());
  fail_unless(option.getValue() == clone->getValue());
  fail_unless(option.getDescription() == clone->getDescription());

  delete clone;
}
END_TEST


START_TEST (test_conversion_options_exceptions)
{
  int value = 0;

  // null copy constructor
  try
  {
    ConversionOption *opt = NULL;
    new ConversionOption(*opt);
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
    ConversionOption *opt = NULL;
    ConversionOption opt2 = *opt;
  }
  catch(SBMLConstructorException& )
  {
    value = 1;
  }
  fail_unless(value == 1);

}
END_TEST

Suite *
create_suite_TestConversionOption (void)
{ 
  Suite *suite = suite_create("ConversionOption");
  TCase *tcase = tcase_create("ConversionOption");


  tcase_add_test(tcase, test_conversion_options_read);
  tcase_add_test(tcase, test_conversion_options_convert);
  tcase_add_test(tcase, test_conversion_options_readWrite);
  tcase_add_test(tcase, test_conversion_options_set);
  tcase_add_test(tcase, test_conversion_options_constructor);
  tcase_add_test(tcase, test_conversion_options_clone);
  tcase_add_test(tcase, test_conversion_options_exceptions);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS

