/**
 * \file    TestXMLAttributes.cpp
 * \brief   TestXMLAttributes unit tests
 * \author  Ben Bornstein
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

#include <limits>

#include <iostream>
#include <check.h>
#include <XMLAttributes.h>
#include <string>


/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */


CK_CPPSTART



START_TEST (test_XMLAttributes_add_get)
{
  XMLAttributes attrs;

  fail_unless( attrs.getLength() == 0 );
  fail_unless( attrs.getNumAttributes() == 0 );
  fail_unless( attrs.isEmpty()        );

  attrs.add("xmlns", "http://foo.org/");
  fail_unless( attrs.getLength() == 1     );
  fail_unless( attrs.getNumAttributes() == 1 );
  fail_unless( attrs.isEmpty()   == false );

  attrs.add("foo", "bar");
  fail_unless( attrs.getLength() == 2     );
  fail_unless( attrs.getNumAttributes() == 2 );
  fail_unless( attrs.isEmpty()   == false );

  fail_unless( attrs.getIndex("xmlns") ==  0 );
  fail_unless( attrs.getIndex("foo"  ) ==  1 );
  fail_unless( attrs.getIndex("bar"  ) == -1 );

  fail_unless( attrs.getValue("xmlns") == "http://foo.org/" );
  fail_unless( attrs.getValue("foo"  ) == "bar"             );
  fail_unless( attrs.getValue("bar"  ) == ""                );

  fail_unless( attrs.getName(0) == "xmlns" );
  fail_unless( attrs.getName(1) == "foo"   );
  fail_unless( attrs.getName(2) == ""      );
}
END_TEST


START_TEST (test_XMLAttributes_readInto_bool)
{
  XMLAttributes attrs;
  bool          value;

  attrs.add("bool0", "0"       );
  attrs.add("bool1", "1"       );
  attrs.add("bool2", "false"   );
  attrs.add("bool3", "true"    );
  attrs.add("bool4", " 0 "     );
  attrs.add("bool5", " 1 "     );
  attrs.add("bool6", " false " );
  attrs.add("bool7", " true "  );
  attrs.add("bool8", " fool "  );
  attrs.add("empty", ""        );

  value = true;

  fail_unless( attrs.readInto("bool0", value) == true );
  fail_unless( value == false );

  fail_unless( attrs.readInto("bool1", value) == true );
  fail_unless( value == true );

  fail_unless( attrs.readInto("bool2", value) == true );
  fail_unless( value == false );

  fail_unless( attrs.readInto("bool3", value) == true );
  fail_unless( value == true );

  fail_unless( attrs.readInto("bool4", value) == true );
  fail_unless( value == false );

  fail_unless( attrs.readInto("bool5", value) == true );
  fail_unless( value == true );

  fail_unless( attrs.readInto("bool6", value) == true );
  fail_unless( value == false );

  fail_unless( attrs.readInto("bool7", value) == true );
  fail_unless( value == true );

  fail_unless( attrs.readInto("bool8", value) == false );
  fail_unless( value == true );

  fail_unless( attrs.readInto("empty", value) == false );
  fail_unless( value == true );

  fail_unless( attrs.readInto("bar", value)   == false );
  fail_unless( value == true );
}
END_TEST


START_TEST (test_XMLAttributes_readInto_double)
{
  XMLAttributes attrs;
  double        value;

  attrs.add("double0", "0"       );
  attrs.add("double1", "1."      );
  attrs.add("double2", " 3.14"   );
  attrs.add("double3", "-2.72"   );
  attrs.add("double4", "6.022e23");
  attrs.add("double5", "-0"      );
  attrs.add("double6", "INF"     );
  attrs.add("double7", "-INF"    );
  attrs.add("double8", "NaN "    );
  attrs.add("double9", "3,14"    );
  attrs.add("empty"  , ""        );

  value = 42.0;

  fail_unless( attrs.readInto("double0", value) == true );
  fail_unless( value == 0.0 );

  fail_unless( attrs.readInto("double1", value) == true );
  fail_unless( value == 1.0 );

  fail_unless( attrs.readInto("double2", value) == true );
  fail_unless( value == 3.14 );

  fail_unless( attrs.readInto("double3", value) == true );
  fail_unless( value == -2.72 );

  fail_unless( attrs.readInto("double4", value) == true );
  fail_unless( value == 6.022e23);

  fail_unless( attrs.readInto("double5", value) == true );
  fail_unless( value == 0 );

  fail_unless( attrs.readInto("double6", value) == true      );
  fail_unless( value ==  numeric_limits<double>::infinity()  );

  fail_unless( attrs.readInto("double7", value) == true      );
  fail_unless( value == - numeric_limits<double>::infinity() );

  fail_unless( attrs.readInto("double8", value) == true );
  fail_unless( value != value );

  value = 42.0;

  fail_unless( attrs.readInto("double9", value)  == false );
  fail_unless( value == 42.0 );

  fail_unless( attrs.readInto("empty", value)    == false );
  fail_unless( value == 42.0 );

  fail_unless( attrs.readInto("bar", value)      == false );
  fail_unless( value == 42.0 );
}
END_TEST


START_TEST (test_XMLAttributes_readInto_long)
{
  XMLAttributes attrs;
  long          value;

  attrs.add("long0", " 0"   );
  attrs.add("long1", " 1"   );
  attrs.add("long2", " 2"   );
  attrs.add("long3", "-3"   );
  attrs.add("long4", "+4"   );
  attrs.add("long5", "3.14" );
  attrs.add("long6", "foo" );
  attrs.add("empty", ""    );

  value = 42;

  fail_unless( attrs.readInto("long0", value) == true );
  fail_unless( value == 0 );

  fail_unless( attrs.readInto("long1", value) == true );
  fail_unless( value == 1 );

  fail_unless( attrs.readInto("long2", value) == true );
  fail_unless( value == 2 );

  fail_unless( attrs.readInto("long3", value) == true );
  fail_unless( value == -3 );

  fail_unless( attrs.readInto("long4", value) == true );
  fail_unless( value == 4 );

  value = 42;

  fail_unless( attrs.readInto("long5", value) == false );
  fail_unless( value == 42 );

  fail_unless( attrs.readInto("long6", value) == false );
  fail_unless( value == 42 );

  fail_unless( attrs.readInto("empty", value) == false );
  fail_unless( value == 42 );

  fail_unless( attrs.readInto("bar", value)   == false );
  fail_unless( value == 42 );
}
END_TEST


START_TEST(test_XMLAttributes_copy)
{
  XMLAttributes *att1 = new XMLAttributes;

  att1->add("xmlns", "http://foo.org/");
  fail_unless( att1->getLength() == 1     );
  fail_unless( att1->getNumAttributes() == 1 );
  fail_unless( att1->isEmpty()   == false );
  fail_unless( att1->getIndex("xmlns") ==  0 );
  fail_unless( att1->getName(0) ==  "xmlns" );
  fail_unless( att1->getValue("xmlns") == "http://foo.org/" );
    
  XMLAttributes *att2 = new XMLAttributes(*att1);

  fail_unless( att2->getLength() == 1     );
  fail_unless( att2->isEmpty()   == false );
  fail_unless( att2->getIndex("xmlns") ==  0 );
  fail_unless( att2->getName(0) ==  "xmlns" );
  fail_unless( att2->getValue("xmlns") == "http://foo.org/" );

  delete att2;
  delete att1;
 

}
END_TEST

START_TEST(test_XMLAttributes_assignment)
{
  XMLAttributes *att1 = new XMLAttributes;

  att1->add("xmlns", "http://foo.org/");
  fail_unless( att1->getLength() == 1     );
  fail_unless( att1->isEmpty()   == false );
  fail_unless( att1->getIndex("xmlns") ==  0 );
  fail_unless( att1->getName(0) ==  "xmlns" );
  fail_unless( att1->getValue("xmlns") == "http://foo.org/" );
    
  XMLAttributes *att2 = new XMLAttributes();
  (*att2)=*att1;

  fail_unless( att2->getLength() == 1     );
  fail_unless( att2->isEmpty()   == false );
  fail_unless( att2->getIndex("xmlns") ==  0 );
  fail_unless( att2->getName(0) ==  "xmlns" );
  fail_unless( att2->getValue("xmlns") == "http://foo.org/" );

  delete att2;
  delete att1;
 

}
END_TEST

START_TEST(test_XMLAttributes_clone)
{
  XMLAttributes *att1 = new XMLAttributes;

  att1->add("xmlns", "http://foo.org/");
  fail_unless( att1->getLength() == 1     );
  fail_unless( att1->isEmpty()   == false );
  fail_unless( att1->getIndex("xmlns") ==  0 );
  fail_unless( att1->getName(0) ==  "xmlns" );
  fail_unless( att1->getValue("xmlns") == "http://foo.org/" );
    
 XMLAttributes* att2 = static_cast<XMLAttributes*>(att1->clone());

  fail_unless( att2->getLength() == 1     );
  fail_unless( att2->isEmpty()   == false );
  fail_unless( att2->getIndex("xmlns") ==  0 );
  fail_unless( att2->getName(0) ==  "xmlns" );
  fail_unless( att2->getValue("xmlns") == "http://foo.org/" );

  delete att2;
  delete att1;
 

}
END_TEST

START_TEST(test_XMLAttributes_add_removeResource)
{
  XMLAttributes *att1 = new XMLAttributes;

  att1->addResource("rdf", "http://foo.org/");
  att1->addResource("rdf", "http://foo1.org/");
  fail_unless( att1->getLength() == 2     );
  fail_unless( att1->isEmpty()   == false );
  fail_unless( att1->getName(0) ==  "rdf" );
  fail_unless( att1->getValue(0) == "http://foo.org/" );
  fail_unless( att1->getName(1) ==  "rdf" );
  fail_unless( att1->getValue(1) == "http://foo1.org/" );

  att1->addResource("rdf", "http://foo2.org/");
  fail_unless( att1->getLength() == 3     );
  fail_unless( att1->isEmpty()   == false );
  fail_unless( att1->getName(2) ==  "rdf" );
  fail_unless( att1->getValue(2) == "http://foo2.org/" );

  att1->removeResource(1);
  fail_unless( att1->getLength() == 2     );
  fail_unless( att1->isEmpty()   == false );
  fail_unless( att1->getName(0) ==  "rdf" );
  fail_unless( att1->getValue(0) == "http://foo.org/" );
  fail_unless( att1->getName(1) ==  "rdf" );
  fail_unless( att1->getValue(1) == "http://foo2.org/" );
}
END_TEST


Suite *
create_suite_XMLAttributes (void)
{
  Suite *suite = suite_create("XMLAttributes");
  TCase *tcase = tcase_create("XMLAttributes");

 
  tcase_add_test( tcase, test_XMLAttributes_add_get         );
  tcase_add_test( tcase, test_XMLAttributes_readInto_bool   );
  tcase_add_test( tcase, test_XMLAttributes_readInto_double );
  tcase_add_test( tcase, test_XMLAttributes_readInto_long   );
  tcase_add_test( tcase, test_XMLAttributes_copy            );
  tcase_add_test( tcase, test_XMLAttributes_assignment      );
  tcase_add_test( tcase, test_XMLAttributes_clone           );
  tcase_add_test( tcase, test_XMLAttributes_add_removeResource);

  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND
