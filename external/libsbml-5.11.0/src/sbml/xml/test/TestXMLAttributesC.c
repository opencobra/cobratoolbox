/**
 * @file    TestXMLAttributesC.c
 * @brief   XMLAttributes unit tests, C version
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

#if defined(WIN32) && !defined(CYGWIN) 

#include <iostream>

#endif


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <XMLAttributes.h>
#include <XMLTriple.h>
#include <XMLErrorLog.h>
#include <util/memory.h>
#include <util/util.h>
#include <check.h>

#include <sbml/common/extern.h>

#if defined(__cplusplus)
LIBSBML_CPP_NAMESPACE_USE
CK_CPPSTART
#endif

START_TEST (test_XMLAttributes_create_C)
{
  XMLAttributes_t *xa = XMLAttributes_create();

  XMLAttributes_add(xa, "double", "3.12");
  XMLAttributes_add(xa, "bool", "1");
  XMLAttributes_add(xa, "long", "23456543");
  XMLAttributes_add(xa, "int", "-12");
  XMLAttributes_add(xa, "uint", "33");

  double value = 0.0;
  int bint = 2;
  long longv = 278787878;
  int intv = -646464;
  unsigned int uintv = 99;

  fail_unless(value == 0.0);
  fail_unless(bint == 2);
  fail_unless(longv == 278787878);
  fail_unless(intv == -646464);
  fail_unless(uintv == 99);

  XMLAttributes_readIntoDouble(xa, "double", &value, NULL, 0);
  XMLAttributes_readIntoBoolean(xa, "bool", &bint, NULL, 0);
  XMLAttributes_readIntoLong(xa, "long", &longv, NULL, 0);
  XMLAttributes_readIntoInt(xa, "int", &intv, NULL, 0);
  XMLAttributes_readIntoUnsignedInt(xa, "uint", &uintv, NULL, 0);

  fail_unless(value == 3.12);
  fail_unless(bint == 1);
  fail_unless(longv == 23456543);
  fail_unless(intv == -12);
  fail_unless(uintv == 33);

  XMLAttributes_free(xa);
}
END_TEST

START_TEST(test_XMLAttributes_add_remove_qname_C)
{
  char * test;

  XMLAttributes_t *xa = XMLAttributes_create();
  XMLTriple_t* xt1    = XMLTriple_createWith("name1", "http://name1.org/", "p1");
  XMLTriple_t* xt2    = XMLTriple_createWith("name2", "http://name2.org/", "p2");
  XMLTriple_t* xt3    = XMLTriple_createWith("name3", "http://name3.org/", "p3");
  XMLTriple_t* xt1a   = XMLTriple_createWith("name1", "http://name1a.org/", "p1a");
  XMLTriple_t* xt2a   = XMLTriple_createWith("name2", "http://name2a.org/", "p2a");

  XMLAttributes_addWithNamespace(xa, "name1", "val1", "http://name1.org/", "p1");
  XMLAttributes_addWithTriple(xa, xt2, "val2");
  fail_unless( XMLAttributes_getLength(xa) == 2 );
  fail_unless( XMLAttributes_isEmpty(xa)   == 0 );

  test = XMLAttributes_getName  (xa, 0);
  fail_unless( strcmp(test, "name1") == 0 );
  free(test);

  test = XMLAttributes_getValue (xa, 0);
  fail_unless( strcmp(test, "val1" ) == 0 );
  free(test);

  test = XMLAttributes_getURI   (xa, 0);
  fail_unless( strcmp(test, "http://name1.org/") == 0 );
  free(test);

  test = XMLAttributes_getPrefix(xa, 0);
  fail_unless( strcmp(test, "p1"   ) == 0 );
  free(test);

  test = XMLAttributes_getName  (xa, 1);
  fail_unless( strcmp(test, "name2") == 0 );
  free(test);

  test = XMLAttributes_getValue (xa, 1);
  fail_unless( strcmp(test, "val2" ) == 0 );
  free(test);

  test = XMLAttributes_getURI   (xa, 1);
  fail_unless( strcmp(test, "http://name2.org/") == 0 );
  free(test);

  test = XMLAttributes_getPrefix(xa, 1);
  fail_unless( strcmp(test, "p2"   ) == 0 );
  free(test);

  test = XMLAttributes_getValueByName (xa, "name1");
  fail_unless( strcmp(test, "val1" ) == 0 );
  free(test);
  
  test = XMLAttributes_getValueByName (xa, "name2");
  fail_unless( strcmp(test, "val2" ) == 0 );
  free(test);
  
  test = XMLAttributes_getValueByNS (xa, "name1", "http://name1.org/");
  fail_unless( strcmp(test, "val1" ) == 0 );
  free(test);
  
  test = XMLAttributes_getValueByNS (xa, "name2", "http://name2.org/");
  fail_unless( strcmp(test, "val2" ) == 0 );
  free(test);
  
  test = XMLAttributes_getValueByTriple (xa, xt1);
  fail_unless( strcmp(test, "val1" ) == 0 );
  free(test);
  
  test = XMLAttributes_getValueByTriple (xa, xt2);
  fail_unless( strcmp(test, "val2" ) == 0 );
  free(test);
  
  fail_unless( XMLAttributes_hasAttribute        (xa, -1) == 0 );
  fail_unless( XMLAttributes_hasAttribute        (xa,  2) == 0 );
  fail_unless( XMLAttributes_hasAttribute        (xa,  0) == 1 );
  fail_unless( XMLAttributes_hasAttributeWithNS(xa, "name1", "http://name1.org/")   == 1 );
  fail_unless( XMLAttributes_hasAttributeWithNS(xa, "name2", "http://name2.org/")   == 1 );
  fail_unless( XMLAttributes_hasAttributeWithNS(xa, "name3", "http://name3.org/")   == 0 );
  fail_unless( XMLAttributes_hasAttributeWithTriple(xa, xt1)   == 1 );
  fail_unless( XMLAttributes_hasAttributeWithTriple(xa, xt2)   == 1 );
  fail_unless( XMLAttributes_hasAttributeWithTriple(xa, xt3)   == 0 );


  XMLAttributes_add(xa, "noprefix", "val3");
  fail_unless( XMLAttributes_getLength(xa) == 3 );
  fail_unless( XMLAttributes_isEmpty(xa)   == 0 );
  
  test = XMLAttributes_getName  (xa, 2);
  fail_unless( strcmp(test, "noprefix") == 0 );
  free(test);

  test = XMLAttributes_getValue (xa, 2);
  fail_unless( strcmp(test, "val3" ) == 0 );
  free(test);

  fail_unless( XMLAttributes_getURI    (xa, 2) == NULL );
  fail_unless( XMLAttributes_getPrefix (xa, 2) == NULL );

  test = XMLAttributes_getValueByNS (xa, "noprefix", "");
  fail_unless( strcmp(test, "val3") == 0 );
  free(test);

  fail_unless( XMLAttributes_hasAttributeWithName (xa, "noprefix"    ) == 1 );
  fail_unless( XMLAttributes_hasAttributeWithNS(xa, "noprefix", "") == 1 );


  XMLAttributes_addWithTriple(xa, xt1, "mval1");
  XMLAttributes_addWithNamespace(xa, "name2", "mval2", "http://name2.org/", "p2");
  XMLAttributes_add(xa, "noprefix", "mval3");
  fail_unless( XMLAttributes_getLength(xa) == 3 );
  fail_unless( XMLAttributes_isEmpty(xa)   == 0 );
  
  test = XMLAttributes_getName  (xa, 0);
  fail_unless( strcmp(test, "name1") == 0 );
  free(test);

  test = XMLAttributes_getValue (xa, 0);
  fail_unless( strcmp(test, "mval1" ) == 0 );
  free(test);

  test = XMLAttributes_getURI   (xa, 0);
  fail_unless( strcmp(test, "http://name1.org/") == 0 );
  free(test);

  test = XMLAttributes_getPrefix(xa, 0);
  fail_unless( strcmp(test, "p1"   ) == 0 );
  free(test);

  test = XMLAttributes_getName  (xa, 1);
  fail_unless( strcmp(test, "name2") == 0 );
  free(test);

  test = XMLAttributes_getValue (xa, 1);
  fail_unless( strcmp(test, "mval2" ) == 0 );
  free(test);

  test = XMLAttributes_getURI   (xa, 1);
  fail_unless( strcmp(test, "http://name2.org/") == 0 );
  free(test);

  test = XMLAttributes_getPrefix(xa, 1);
  fail_unless( strcmp(test, "p2"   ) == 0 );
  free(test);

  test = XMLAttributes_getName  (xa, 2);
  fail_unless( strcmp(test, "noprefix") == 0 );
  free(test);

  test = XMLAttributes_getValue (xa, 2);
  fail_unless( strcmp(test, "mval3" ) == 0 );
  free(test);

  fail_unless(        XMLAttributes_getURI   (xa, 2) == NULL );
  fail_unless(        XMLAttributes_getPrefix(xa, 2) == NULL );
  fail_unless( XMLAttributes_hasAttributeWithTriple(xa, xt1) == 1 );
  fail_unless( XMLAttributes_hasAttributeWithNS(xa, "name1", "http://name1.org/")   == 1 );
  fail_unless( XMLAttributes_hasAttributeWithName (xa, "noprefix") == 1 );


  XMLAttributes_addWithTriple(xa, xt1a, "val1a");
  XMLAttributes_addWithTriple(xa, xt2a, "val2a");
  fail_unless( XMLAttributes_getLength(xa) == 5 );
  
  test = XMLAttributes_getName  (xa, 3);
  fail_unless( strcmp(test, "name1") == 0 );
  free(test);

  test = XMLAttributes_getValue (xa, 3);
  fail_unless( strcmp(test, "val1a" ) == 0 );
  free(test);

  test = XMLAttributes_getURI   (xa, 3);
  fail_unless( strcmp(test, "http://name1a.org/") == 0 );
  free(test);

  test = XMLAttributes_getPrefix(xa, 3);
  fail_unless( strcmp(test, "p1a"   ) == 0 );
  free(test);

  test = XMLAttributes_getName  (xa, 4);
  fail_unless( strcmp(test, "name2") == 0 );
  free(test);

  test = XMLAttributes_getValue (xa, 4);
  fail_unless( strcmp(test, "val2a" ) == 0 );
  free(test);

  test = XMLAttributes_getURI   (xa, 4);
  fail_unless( strcmp(test, "http://name2a.org/") == 0 );
  free(test);

  test = XMLAttributes_getPrefix(xa, 4);
  fail_unless( strcmp(test, "p2a"   ) == 0 );
  free(test);


  test = XMLAttributes_getValueByName (xa, "name1");
  fail_unless( strcmp(test, "mval1" ) == 0 );
  free(test);
  
  test = XMLAttributes_getValueByName (xa, "name2");
  fail_unless( strcmp(test, "mval2" ) == 0 );
  free(test);
  
  test = XMLAttributes_getValueByNS (xa, "name1", "http://name1a.org/");
  fail_unless( strcmp(test, "val1a" ) == 0 );
  free(test);
  
  test = XMLAttributes_getValueByNS (xa, "name2", "http://name2a.org/");
  fail_unless( strcmp(test, "val2a" ) == 0 );
  free(test);
  
  test = XMLAttributes_getValueByTriple (xa, xt1a);
  fail_unless( strcmp(test, "val1a" ) == 0 );
  free(test);
  
  test = XMLAttributes_getValueByTriple (xa, xt2a);
  fail_unless( strcmp(test, "val2a" ) == 0 );
  free(test);
  
  XMLAttributes_removeByTriple(xa, xt1a);
  XMLAttributes_removeByTriple(xa, xt2a);
  fail_unless( XMLAttributes_getLength(xa) == 3 );

  XMLAttributes_removeByNS(xa, "name1", "http://name1.org/");
  fail_unless( XMLAttributes_getLength(xa)    == 2     );
  fail_unless( XMLAttributes_isEmpty(xa)      == 0 );
  
  test = XMLAttributes_getName  (xa, 0);
  fail_unless( strcmp(test, "name2") == 0 );
  free(test);

  test = XMLAttributes_getValue (xa, 0);
  fail_unless( strcmp(test, "mval2" ) == 0 );
  free(test);

  test = XMLAttributes_getURI   (xa, 0);
  fail_unless( strcmp(test, "http://name2.org/") == 0 );
  free(test);

  test = XMLAttributes_getPrefix(xa, 0);
  fail_unless( strcmp(test, "p2"   ) == 0 );
  free(test);

  test = XMLAttributes_getName  (xa, 1);
  fail_unless( strcmp(test, "noprefix") == 0 );
  free(test);

  test = XMLAttributes_getValue (xa, 1);
  fail_unless( strcmp(test, "mval3" ) == 0 );
  free(test);

  fail_unless(        XMLAttributes_getURI   (xa, 1) == NULL);
  fail_unless(        XMLAttributes_getPrefix(xa, 1) == NULL);
  fail_unless( XMLAttributes_hasAttributeWithNS(xa, "name1", "http://name1.org/")   == 0 );

  XMLAttributes_removeByTriple(xa, xt2);
  fail_unless( XMLAttributes_getLength(xa) == 1 );
  fail_unless( XMLAttributes_isEmpty(xa)   == 0 );

  test = XMLAttributes_getName  (xa, 0);
  fail_unless( strcmp(test, "noprefix") == 0 );
  free(test);

  test = XMLAttributes_getValue (xa, 0);
  fail_unless( strcmp(test, "mval3" ) == 0 );
  free(test);

  fail_unless(       XMLAttributes_getURI   (xa, 0) == NULL );
  fail_unless(       XMLAttributes_getPrefix(xa, 0) == NULL );
  fail_unless( XMLAttributes_hasAttributeWithTriple(xa, xt2) == 0 );
  fail_unless( XMLAttributes_hasAttributeWithNS(xa, "name2", "http://name2.org/")   == 0 );

  XMLAttributes_removeByNS(xa, "noprefix", "");
  fail_unless( XMLAttributes_getLength(xa) == 0 );
  fail_unless( XMLAttributes_isEmpty(xa)   == 1 );
  fail_unless( XMLAttributes_hasAttributeWithName (xa, "noprefix"    ) == 0 );
  fail_unless( XMLAttributes_hasAttributeWithNS(xa, "noprefix", "") == 0 );


  XMLAttributes_free(xa);
  XMLTriple_free(xt1);
  XMLTriple_free(xt2);
  XMLTriple_free(xt3);
  XMLTriple_free(xt1a);
  XMLTriple_free(xt2a);

}
END_TEST


START_TEST(test_XMLAttributes_add1)
{
  XMLAttributes_t *xa = XMLAttributes_create();
  XMLTriple_t* xt2    = XMLTriple_createWith("name2", "http://name2.org/", "p2");

  int i = XMLAttributes_addWithNamespace(xa, "name1", "val1", "http://name1.org/", "p1");
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);

  i = XMLAttributes_addWithTriple(xa, xt2, "val2");
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);

  fail_unless( XMLAttributes_getLength(xa) == 2 );
  fail_unless( XMLAttributes_isEmpty(xa)   == 0 );

  i = XMLAttributes_add(xa, "noprefix", "val3");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLAttributes_getLength(xa) == 3 );
  fail_unless( XMLAttributes_isEmpty(xa)   == 0 );

  XMLAttributes_free(xa);
  XMLTriple_free(xt2);
}
END_TEST


START_TEST (test_XMLAttributes_readInto_string_C)
{
  XMLAttributes_t* attrs = XMLAttributes_create();
  char* value = NULL;

  XMLTriple_t* trp0  = XMLTriple_createWith("str0", "http://ns0.org/", "p0");
  XMLTriple_t* trp1  = XMLTriple_createWith("str1", "http://ns1.org/", "p1");
  XMLTriple_t* trp2  = XMLTriple_createWith("str2", "http://ns2.org/", "p2");
  XMLTriple_t* trp3  = XMLTriple_createWith("str3", "http://ns3.org/", "p3");
  XMLTriple_t* trp4  = XMLTriple_createWith("str4", "http://ns4.org/", "p4");

  XMLAttributes_addWithTriple(attrs, trp0, "id0");
  XMLAttributes_addWithTriple(attrs, trp1, "id1");
  XMLAttributes_addWithTriple(attrs, trp2, "id2");
  XMLAttributes_addWithTriple(attrs, trp3, "id3");
  XMLAttributes_addWithTriple(attrs, trp4, "id4");

  XMLErrorLog_t* log = XMLErrorLog_create();

  fail_unless( XMLAttributes_readIntoString(attrs, "str0", &value, NULL, 0) != 0 );
  fail_unless( strcmp(value, "id0") == 0 );
  safe_free(value);
  fail_unless( XMLAttributes_readIntoString(attrs, "str1", &value, NULL, 0) != 0 );
  fail_unless( strcmp(value, "id1") == 0 );
  safe_free(value);
  fail_unless( XMLAttributes_readIntoString(attrs, "str2", &value, NULL, 0) != 0 );
  fail_unless( strcmp(value, "id2") == 0 );
  safe_free(value);
  fail_unless( XMLAttributes_readIntoString(attrs, "str3", &value, NULL, 0) != 0 );
  fail_unless( strcmp(value, "id3") == 0 );
  safe_free(value);
  fail_unless( XMLAttributes_readIntoString(attrs, "str4", &value, NULL, 0) != 0 );
  fail_unless( strcmp(value, "id4") == 0 );
  safe_free(value);

  value = safe_strdup("false");

  fail_unless( XMLAttributes_readIntoString(attrs, "str5", &value, log, 1) == 0 );
  fail_unless( strcmp(value, "false") == 0 );
  fail_unless( XMLErrorLog_getNumErrors(log) == 1 );
  fail_unless( XMLErrorLog_getError(log, 0) != NULL );
  XMLErrorLog_clearLog(log);
  safe_free(value);

  fail_unless( XMLAttributes_readIntoStringByTriple(attrs, trp0, &value, NULL, 0) != 0 );
  fail_unless( strcmp(value, "id0") == 0 );
  safe_free(value);
  fail_unless( XMLAttributes_readIntoStringByTriple(attrs, trp1, &value, NULL, 0) != 0 );
  fail_unless( strcmp(value, "id1") == 0 );
  safe_free(value);
  fail_unless( XMLAttributes_readIntoStringByTriple(attrs, trp2, &value, NULL, 0) != 0 );
  fail_unless( strcmp(value, "id2") == 0 );
  safe_free(value);
  fail_unless( XMLAttributes_readIntoStringByTriple(attrs, trp3, &value, NULL, 0) != 0 );
  fail_unless( strcmp(value, "id3") == 0 );
  safe_free(value);
  fail_unless( XMLAttributes_readIntoStringByTriple(attrs, trp4, &value, NULL, 0) != 0 );
  fail_unless( strcmp(value, "id4") == 0 );
  safe_free(value);

  value=safe_strdup("false");
  XMLTriple_t* trpX  = XMLTriple_createWith("str0", "http://ns0.org/","pX");
  XMLTriple_t* empty = XMLTriple_createWith("","","");

  fail_unless( XMLAttributes_readIntoStringByTriple(attrs, trpX, &value, log, 1) == 0 );
  fail_unless( strcmp(value, "false") == 0 );
  fail_unless( XMLErrorLog_getNumErrors(log) == 1 );
  fail_unless( XMLErrorLog_getError(log, 0) != NULL );

  fail_unless( XMLAttributes_readIntoStringByTriple(attrs, empty, &value, log, 1) == 0 );
  fail_unless( strcmp(value, "false") == 0 );
  fail_unless( XMLErrorLog_getNumErrors(log) == 2 );
  fail_unless( XMLErrorLog_getError(log, 1) != NULL );

  safe_free(value);

  XMLAttributes_free(attrs);
  XMLTriple_free(trp0);
  XMLTriple_free(trp1);
  XMLTriple_free(trp2);
  XMLTriple_free(trp3);
  XMLTriple_free(trp4);
  XMLTriple_free(trpX);
  XMLTriple_free(empty);
  XMLErrorLog_free(log);

}
END_TEST


START_TEST (test_XMLAttributes_readInto_boolean_C)
{
  XMLAttributes_t* attrs = XMLAttributes_create();

  XMLTriple_t* trp0  = XMLTriple_createWith("str0", "http://ns0.org/", "p0");
  XMLTriple_t* trp1  = XMLTriple_createWith("str1", "http://ns1.org/", "p1");
  XMLTriple_t* trp2  = XMLTriple_createWith("str2", "http://ns2.org/", "p2");
  XMLTriple_t* trp3  = XMLTriple_createWith("str3", "http://ns3.org/", "p3");
  XMLTriple_t* trp4  = XMLTriple_createWith("str4", "http://ns4.org/", "p4");
  XMLTriple_t* trp5  = XMLTriple_createWith("str5", "http://ns5.org/", "p5");
  XMLTriple_t* trp6  = XMLTriple_createWith("str6", "http://ns6.org/", "p6");
  XMLTriple_t* trp7  = XMLTriple_createWith("str7", "http://ns7.org/", "p7");


  XMLAttributes_addWithTriple(attrs, trp0, "0"       );
  XMLAttributes_addWithTriple(attrs, trp1, " 0 "     );
  XMLAttributes_addWithTriple(attrs, trp2, "false"   );
  XMLAttributes_addWithTriple(attrs, trp3, "  false ");
  XMLAttributes_addWithTriple(attrs, trp4, "1"       );
  XMLAttributes_addWithTriple(attrs, trp5, "true"    );
  XMLAttributes_addWithTriple(attrs, trp6, " 1 "     );
  XMLAttributes_addWithTriple(attrs, trp7, "  true  ");

  XMLErrorLog_t* log = XMLErrorLog_create();

  int value = -1;

  fail_unless( XMLAttributes_readIntoBoolean(attrs, "str0", &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoBoolean(attrs, "str1", &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoBoolean(attrs, "str2", &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoBoolean(attrs, "str3", &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoBoolean(attrs, "str4", &value, NULL, 0) != 0 );
  fail_unless( value != 0 );
  fail_unless( XMLAttributes_readIntoBoolean(attrs, "str5", &value, NULL, 0) != 0 );
  fail_unless( value != 0 );
  fail_unless( XMLAttributes_readIntoBoolean(attrs, "str6", &value, NULL, 0) != 0 );
  fail_unless( value != 0 );
  fail_unless( XMLAttributes_readIntoBoolean(attrs, "str7", &value, NULL, 0) != 0 );
  fail_unless( value != 0 );

  value = -1;

  fail_unless( XMLAttributes_readIntoBoolean(attrs, "str9", &value, log, 1) == 0 );
  fail_unless( value == -1 );

  fail_unless( XMLErrorLog_getNumErrors(log) == 1 );
  fail_unless( XMLErrorLog_getError(log, 0) != NULL );
  XMLErrorLog_clearLog(log);

  fail_unless( XMLAttributes_readIntoBooleanByTriple(attrs, trp0, &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoBooleanByTriple(attrs, trp1, &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoBooleanByTriple(attrs, trp2, &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoBooleanByTriple(attrs, trp3, &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoBooleanByTriple(attrs, trp4, &value, NULL, 0) != 0 );
  fail_unless( value != 0 );
  fail_unless( XMLAttributes_readIntoBooleanByTriple(attrs, trp5, &value, NULL, 0) != 0 );
  fail_unless( value != 0 );
  fail_unless( XMLAttributes_readIntoBooleanByTriple(attrs, trp6, &value, NULL, 0) != 0 );
  fail_unless( value != 0 );
  fail_unless( XMLAttributes_readIntoBooleanByTriple(attrs, trp7, &value, NULL, 0) != 0 );
  fail_unless( value != 0 );

  value = -1;
  XMLTriple_t* trpX  = XMLTriple_createWith("str0", "http://ns0.org/","pX");
  XMLTriple_t* empty = XMLTriple_createWith("","","");

  fail_unless( XMLAttributes_readIntoBooleanByTriple(attrs, trpX, &value, log, 1) == 0 );
  fail_unless( value == -1 );
  fail_unless( XMLErrorLog_getNumErrors(log) == 1 );
  fail_unless( XMLErrorLog_getError(log, 0) != NULL );

  fail_unless( XMLAttributes_readIntoBooleanByTriple(attrs, empty, &value, log, 1) == 0 );
  fail_unless( value == -1 );
  fail_unless( XMLErrorLog_getNumErrors(log) == 2 );
  fail_unless( XMLErrorLog_getError(log, 1) != NULL );

  XMLAttributes_free(attrs);
  XMLTriple_free(trp0);
  XMLTriple_free(trp1);
  XMLTriple_free(trp2);
  XMLTriple_free(trp3);
  XMLTriple_free(trp4);
  XMLTriple_free(trp5);
  XMLTriple_free(trp6);
  XMLTriple_free(trp7);
  XMLTriple_free(trpX);
  XMLTriple_free(empty);
  XMLErrorLog_free(log);

}
END_TEST


START_TEST (test_XMLAttributes_readInto_double_C)
{
  XMLAttributes_t* attrs = XMLAttributes_create();

  XMLTriple_t* trp0  = XMLTriple_createWith("str0", "http://ns0.org/", "p0");
  XMLTriple_t* trp1  = XMLTriple_createWith("str1", "http://ns1.org/", "p1");
  XMLTriple_t* trp2  = XMLTriple_createWith("str2", "http://ns2.org/", "p2");
  XMLTriple_t* trp3  = XMLTriple_createWith("str3", "http://ns3.org/", "p3");
  XMLTriple_t* trp4  = XMLTriple_createWith("str4", "http://ns4.org/", "p4");
  XMLTriple_t* trp5  = XMLTriple_createWith("str5", "http://ns5.org/", "p5");
  XMLTriple_t* trp6  = XMLTriple_createWith("str6", "http://ns6.org/", "p6");
  XMLTriple_t* trp7  = XMLTriple_createWith("str7", "http://ns7.org/", "p7");
  XMLTriple_t* trp8  = XMLTriple_createWith("str8", "http://ns8.org/", "p8");
  XMLTriple_t* trp9  = XMLTriple_createWith("str9", "http://ns9.org/", "p9");

  XMLAttributes_addWithTriple(attrs, trp0, "0");
  XMLAttributes_addWithTriple(attrs, trp1, "1.");
  XMLAttributes_addWithTriple(attrs, trp2, "3.14");
  XMLAttributes_addWithTriple(attrs, trp3, "-2.72");
  XMLAttributes_addWithTriple(attrs, trp4, "6.022e23");
  XMLAttributes_addWithTriple(attrs, trp5, "-0");
  XMLAttributes_addWithTriple(attrs, trp6, "INF");
  XMLAttributes_addWithTriple(attrs, trp7, "-INF");
  XMLAttributes_addWithTriple(attrs, trp8, "NaN");
  XMLAttributes_addWithTriple(attrs, trp9, "3,14");

  XMLErrorLog_t* log = XMLErrorLog_create();

  double value = -1;

  fail_unless( XMLAttributes_readIntoDouble(attrs, "str0", &value, NULL, 0) != 0 );
  fail_unless( value == 0.0 );
  fail_unless( XMLAttributes_readIntoDouble(attrs, "str1", &value, NULL, 0) != 0 );
  fail_unless( value == 1.0 );
  fail_unless( XMLAttributes_readIntoDouble(attrs, "str2", &value, NULL, 0) != 0 );
  fail_unless( value == 3.14 );
  fail_unless( XMLAttributes_readIntoDouble(attrs, "str3", &value, NULL, 0) != 0 );
  fail_unless( value == -2.72 );
  fail_unless( XMLAttributes_readIntoDouble(attrs, "str4", &value, NULL, 0) != 0 );
  fail_unless( value == 6.022e23 );
  fail_unless( XMLAttributes_readIntoDouble(attrs, "str5", &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoDouble(attrs, "str6", &value, NULL, 0) != 0 );
  fail_unless( value == util_PosInf() );
  fail_unless( XMLAttributes_readIntoDouble(attrs, "str7", &value, NULL, 0) != 0 );
  fail_unless( value == util_NegInf() );
  fail_unless( XMLAttributes_readIntoDouble(attrs, "str8", &value, NULL, 0) != 0 );
  fail_unless( value != value );
  fail_unless( XMLAttributes_readIntoDouble(attrs, "str9", &value, NULL, 0) == 0 );

  value = -1;

  fail_unless( XMLAttributes_readIntoDoubleByTriple(attrs, trp0, &value, NULL, 0) != 0 );
  fail_unless( value == 0.0 );
  fail_unless( XMLAttributes_readIntoDoubleByTriple(attrs, trp1, &value, NULL, 0) != 0 );
  fail_unless( value == 1.0 );
  fail_unless( XMLAttributes_readIntoDoubleByTriple(attrs, trp2, &value, NULL, 0) != 0 );
  fail_unless( value == 3.14 );
  fail_unless( XMLAttributes_readIntoDoubleByTriple(attrs, trp3, &value, NULL, 0) != 0 );
  fail_unless( value == -2.72 );
  fail_unless( XMLAttributes_readIntoDoubleByTriple(attrs, trp4, &value, NULL, 0) != 0 );
  fail_unless( value == 6.022e23 );
  fail_unless( XMLAttributes_readIntoDoubleByTriple(attrs, trp5, &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoDoubleByTriple(attrs, trp6, &value, NULL, 0) != 0 );
  fail_unless( value == util_PosInf() );
  fail_unless( XMLAttributes_readIntoDoubleByTriple(attrs, trp7, &value, NULL, 0) != 0 );
  fail_unless( value == util_NegInf() );
  fail_unless( XMLAttributes_readIntoDoubleByTriple(attrs, trp8, &value, NULL, 0) != 0 );
  fail_unless( value != value );
  fail_unless( XMLAttributes_readIntoDoubleByTriple(attrs, trp9, &value, NULL, 0) == 0 );


  XMLAttributes_free(attrs);
  XMLTriple_free(trp0);
  XMLTriple_free(trp1);
  XMLTriple_free(trp2);
  XMLTriple_free(trp3);
  XMLTriple_free(trp4);
  XMLTriple_free(trp5);
  XMLTriple_free(trp6);
  XMLTriple_free(trp7);
  XMLTriple_free(trp8);
  XMLTriple_free(trp9);
  XMLErrorLog_free(log);

}
END_TEST


START_TEST (test_XMLAttributes_readInto_long_C)
{
  XMLAttributes_t* attrs = XMLAttributes_create();

  XMLTriple_t* trp0  = XMLTriple_createWith("str0", "http://ns0.org/", "p0");
  XMLTriple_t* trp1  = XMLTriple_createWith("str1", "http://ns1.org/", "p1");
  XMLTriple_t* trp2  = XMLTriple_createWith("str2", "http://ns2.org/", "p2");
  XMLTriple_t* trp3  = XMLTriple_createWith("str3", "http://ns3.org/", "p3");
  XMLTriple_t* trp4  = XMLTriple_createWith("str4", "http://ns4.org/", "p4");
  XMLTriple_t* trp5  = XMLTriple_createWith("str5", "http://ns5.org/", "p5");
  XMLTriple_t* trp6  = XMLTriple_createWith("str6", "http://ns6.org/", "p6");

  XMLAttributes_addWithTriple(attrs, trp0, " 0");
  XMLAttributes_addWithTriple(attrs, trp1, " 1");
  XMLAttributes_addWithTriple(attrs, trp2, " 2");
  XMLAttributes_addWithTriple(attrs, trp3, "-3");
  XMLAttributes_addWithTriple(attrs, trp4, "+4");
  XMLAttributes_addWithTriple(attrs, trp5, "3.14");
  XMLAttributes_addWithTriple(attrs, trp6, "foo");

  XMLErrorLog_t* log = XMLErrorLog_create();

  long value = -1;

  fail_unless( XMLAttributes_readIntoLong(attrs, "str0", &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoLong(attrs, "str1", &value, NULL, 0) != 0 );
  fail_unless( value == 1 );
  fail_unless( XMLAttributes_readIntoLong(attrs, "str2", &value, NULL, 0) != 0 );
  fail_unless( value == 2 );
  fail_unless( XMLAttributes_readIntoLong(attrs, "str3", &value, NULL, 0) != 0 );
  fail_unless( value == -3 );
  fail_unless( XMLAttributes_readIntoLong(attrs, "str4", &value, NULL, 0) != 0 );
  fail_unless( value == 4 );
  fail_unless( XMLAttributes_readIntoLong(attrs, "str5", &value, NULL, 0) == 0 );
  fail_unless( XMLAttributes_readIntoLong(attrs, "str6", &value, NULL, 0) == 0 );

  value = -1;

  fail_unless( XMLAttributes_readIntoLongByTriple(attrs, trp0, &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoLongByTriple(attrs, trp1, &value, NULL, 0) != 0 );
  fail_unless( value == 1 );
  fail_unless( XMLAttributes_readIntoLongByTriple(attrs, trp2, &value, NULL, 0) != 0 );
  fail_unless( value == 2 );
  fail_unless( XMLAttributes_readIntoLongByTriple(attrs, trp3, &value, NULL, 0) != 0 );
  fail_unless( value == -3 );
  fail_unless( XMLAttributes_readIntoLongByTriple(attrs, trp4, &value, NULL, 0) != 0 );
  fail_unless( value == 4 );
  fail_unless( XMLAttributes_readIntoLongByTriple(attrs, trp5, &value, NULL, 0) == 0 );
  fail_unless( XMLAttributes_readIntoLongByTriple(attrs, trp6, &value, NULL, 0) == 0 );

  XMLAttributes_free(attrs);
  XMLTriple_free(trp0);
  XMLTriple_free(trp1);
  XMLTriple_free(trp2);
  XMLTriple_free(trp3);
  XMLTriple_free(trp4);
  XMLTriple_free(trp5);
  XMLTriple_free(trp6);
  XMLErrorLog_free(log);

}
END_TEST


START_TEST (test_XMLAttributes_readInto_int_C)
{
  XMLAttributes_t* attrs = XMLAttributes_create();

  XMLTriple_t* trp0  = XMLTriple_createWith("str0", "http://ns0.org/", "p0");
  XMLTriple_t* trp1  = XMLTriple_createWith("str1", "http://ns1.org/", "p1");
  XMLTriple_t* trp2  = XMLTriple_createWith("str2", "http://ns2.org/", "p2");
  XMLTriple_t* trp3  = XMLTriple_createWith("str3", "http://ns3.org/", "p3");
  XMLTriple_t* trp4  = XMLTriple_createWith("str4", "http://ns4.org/", "p4");
  XMLTriple_t* trp5  = XMLTriple_createWith("str5", "http://ns5.org/", "p5");
  XMLTriple_t* trp6  = XMLTriple_createWith("str6", "http://ns6.org/", "p6");

  XMLAttributes_addWithTriple(attrs, trp0, " 0");
  XMLAttributes_addWithTriple(attrs, trp1, " 1");
  XMLAttributes_addWithTriple(attrs, trp2, " 2");
  XMLAttributes_addWithTriple(attrs, trp3, "-3");
  XMLAttributes_addWithTriple(attrs, trp4, "+4");
  XMLAttributes_addWithTriple(attrs, trp5, "3.14");
  XMLAttributes_addWithTriple(attrs, trp6, "foo");

  XMLErrorLog_t* log = XMLErrorLog_create();

  int value = -1;

  fail_unless( XMLAttributes_readIntoInt(attrs, "str0", &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoInt(attrs, "str1", &value, NULL, 0) != 0 );
  fail_unless( value == 1 );
  fail_unless( XMLAttributes_readIntoInt(attrs, "str2", &value, NULL, 0) != 0 );
  fail_unless( value == 2 );
  fail_unless( XMLAttributes_readIntoInt(attrs, "str3", &value, NULL, 0) != 0 );
  fail_unless( value == -3 );
  fail_unless( XMLAttributes_readIntoInt(attrs, "str4", &value, NULL, 0) != 0 );
  fail_unless( value == 4 );
  fail_unless( XMLAttributes_readIntoInt(attrs, "str5", &value, NULL, 0) == 0 );
  fail_unless( XMLAttributes_readIntoInt(attrs, "str6", &value, NULL, 0) == 0 );

  value = -1;

  fail_unless( XMLAttributes_readIntoIntByTriple(attrs, trp0, &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoIntByTriple(attrs, trp1, &value, NULL, 0) != 0 );
  fail_unless( value == 1 );
  fail_unless( XMLAttributes_readIntoIntByTriple(attrs, trp2, &value, NULL, 0) != 0 );
  fail_unless( value == 2 );
  fail_unless( XMLAttributes_readIntoIntByTriple(attrs, trp3, &value, NULL, 0) != 0 );
  fail_unless( value == -3 );
  fail_unless( XMLAttributes_readIntoIntByTriple(attrs, trp4, &value, NULL, 0) != 0 );
  fail_unless( value == 4 );
  fail_unless( XMLAttributes_readIntoIntByTriple(attrs, trp5, &value, NULL, 0) == 0 );
  fail_unless( XMLAttributes_readIntoIntByTriple(attrs, trp6, &value, NULL, 0) == 0 );

  XMLAttributes_free(attrs);
  XMLTriple_free(trp0);
  XMLTriple_free(trp1);
  XMLTriple_free(trp2);
  XMLTriple_free(trp3);
  XMLTriple_free(trp4);
  XMLTriple_free(trp5);
  XMLTriple_free(trp6);
  XMLErrorLog_free(log);

}
END_TEST


START_TEST (test_XMLAttributes_readInto_uint_C)
{
  XMLAttributes_t* attrs = XMLAttributes_create();

  XMLTriple_t* trp0  = XMLTriple_createWith("str0", "http://ns0.org/", "p0");
  XMLTriple_t* trp1  = XMLTriple_createWith("str1", "http://ns1.org/", "p1");
  XMLTriple_t* trp2  = XMLTriple_createWith("str2", "http://ns2.org/", "p2");
  XMLTriple_t* trp3  = XMLTriple_createWith("str3", "http://ns3.org/", "p3");
  XMLTriple_t* trp4  = XMLTriple_createWith("str4", "http://ns4.org/", "p4");
  XMLTriple_t* trp5  = XMLTriple_createWith("str5", "http://ns5.org/", "p5");
  XMLTriple_t* trp6  = XMLTriple_createWith("str6", "http://ns6.org/", "p6");

  XMLAttributes_addWithTriple(attrs, trp0, " 0");
  XMLAttributes_addWithTriple(attrs, trp1, " 1");
  XMLAttributes_addWithTriple(attrs, trp2, "+2");
  XMLAttributes_addWithTriple(attrs, trp3, " 3 ");
  XMLAttributes_addWithTriple(attrs, trp4, "-4");
  XMLAttributes_addWithTriple(attrs, trp5, "3.14");
  XMLAttributes_addWithTriple(attrs, trp6, "foo");

  XMLErrorLog_t* log = XMLErrorLog_create();

  unsigned int value = 999;

  fail_unless( XMLAttributes_readIntoUnsignedInt(attrs, "str0", &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoUnsignedInt(attrs, "str1", &value, NULL, 0) != 0 );
  fail_unless( value == 1 );
  fail_unless( XMLAttributes_readIntoUnsignedInt(attrs, "str2", &value, NULL, 0) != 0 );
  fail_unless( value == 2 );
  fail_unless( XMLAttributes_readIntoUnsignedInt(attrs, "str3", &value, NULL, 0) != 0 );
  fail_unless( value == 3 );
  fail_unless( XMLAttributes_readIntoUnsignedInt(attrs, "str4", &value, NULL, 0) == 0 );
  fail_unless( XMLAttributes_readIntoUnsignedInt(attrs, "str5", &value, NULL, 0) == 0 );
  fail_unless( XMLAttributes_readIntoUnsignedInt(attrs, "str6", &value, NULL, 0) == 0 );

  value = -1;

  fail_unless( XMLAttributes_readIntoUnsignedIntByTriple(attrs, trp0, &value, NULL, 0) != 0 );
  fail_unless( value == 0 );
  fail_unless( XMLAttributes_readIntoUnsignedIntByTriple(attrs, trp1, &value, NULL, 0) != 0 );
  fail_unless( value == 1 );
  fail_unless( XMLAttributes_readIntoUnsignedIntByTriple(attrs, trp2, &value, NULL, 0) != 0 );
  fail_unless( value == 2 );
  fail_unless( XMLAttributes_readIntoUnsignedIntByTriple(attrs, trp3, &value, NULL, 0) != 0 );
  fail_unless( value == 3 );
  fail_unless( XMLAttributes_readIntoUnsignedIntByTriple(attrs, trp4, &value, NULL, 0) == 0 );
  fail_unless( XMLAttributes_readIntoUnsignedIntByTriple(attrs, trp5, &value, NULL, 0) == 0 );
  fail_unless( XMLAttributes_readIntoUnsignedIntByTriple(attrs, trp6, &value, NULL, 0) == 0 );

  XMLAttributes_free(attrs);
  XMLTriple_free(trp0);
  XMLTriple_free(trp1);
  XMLTriple_free(trp2);
  XMLTriple_free(trp3);
  XMLTriple_free(trp4);
  XMLTriple_free(trp5);
  XMLTriple_free(trp6);
  XMLErrorLog_free(log);

}
END_TEST


START_TEST(test_XMLAttributes_remove1)
{
  XMLAttributes_t *xa = XMLAttributes_create();
  XMLTriple_t* xt2    = XMLTriple_createWith("name2", "http://name2.org/", "p2");

  int i = XMLAttributes_addWithNamespace(xa, "name1", "val1", "http://name1.org/", "p1");
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);

  i = XMLAttributes_addWithTriple(xa, xt2, "val2");
  
  fail_unless( i == LIBSBML_OPERATION_SUCCESS);

  i = XMLAttributes_add(xa, "noprefix", "val3");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  
  i = XMLAttributes_addWithNamespace(xa, "name4", "val4", "http://name4.org/", "p1");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLAttributes_getLength(xa) == 4 );

  i = XMLAttributes_remove(xa, 4);

  fail_unless(i == LIBSBML_INDEX_EXCEEDS_SIZE);

  i = XMLAttributes_remove(xa, 3);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLAttributes_getLength(xa) == 3 );

  i = XMLAttributes_removeByName(xa, "noprefix");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLAttributes_getLength(xa) ==  2);

  i = XMLAttributes_removeByTriple(xa, xt2);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLAttributes_getLength(xa) ==  1);

  i = XMLAttributes_removeByNS(xa, "name1", "http://name1.org/");

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLAttributes_getLength(xa) ==  0);

  XMLAttributes_free(xa);
  XMLTriple_free(xt2);
}
END_TEST


START_TEST(test_XMLAttributes_clear1)
{
  XMLAttributes_t *xa = XMLAttributes_create();
  XMLTriple_t* xt2    = XMLTriple_createWith("name2", "http://name2.org/", "p2");
  int i = XMLAttributes_addWithNamespace(xa, "name1", "val1", "http://name1.org/", "p1");
  i = XMLAttributes_addWithTriple(xa, xt2, "val2");
  i = XMLAttributes_add(xa, "noprefix", "val3");
  fail_unless( XMLAttributes_getLength(xa) == 3 );
  fail_unless( XMLAttributes_isEmpty(xa)   == 0 );

  i = XMLAttributes_clear(xa);

  fail_unless( i == LIBSBML_OPERATION_SUCCESS);
  fail_unless( XMLAttributes_getLength(xa) == 0 );
  fail_unless( XMLAttributes_isEmpty(xa)   == 1 );

  XMLAttributes_free(xa);
  XMLTriple_free(xt2);
}
END_TEST

START_TEST(test_XMLAttributes_accessWithNULL)
{
  fail_unless ( XMLAttributes_add(NULL, NULL, NULL) == LIBSBML_INVALID_OBJECT );  
  fail_unless ( XMLAttributes_addWithNamespace(NULL, NULL, NULL, NULL, NULL) 
      == LIBSBML_INVALID_OBJECT );
  fail_unless ( XMLAttributes_addWithTriple(NULL, NULL, NULL) 
      == LIBSBML_INVALID_OBJECT );
  fail_unless ( XMLAttributes_clear(NULL) == LIBSBML_INVALID_OBJECT );  
  fail_unless ( XMLAttributes_clone(NULL) == NULL );  

  XMLAttributes_free(NULL);

  fail_unless ( XMLAttributes_getIndex(NULL, NULL) == -1 );  
  fail_unless ( XMLAttributes_getIndexByNS(NULL, NULL, NULL) == -1 );  
  fail_unless ( XMLAttributes_getIndexByTriple(NULL, NULL) == -1 );  
  fail_unless ( XMLAttributes_getLength(NULL) == 0 );  
  fail_unless ( XMLAttributes_getName(NULL, 0) == NULL );  
  fail_unless ( XMLAttributes_getPrefix(NULL, 0) == NULL );  
  fail_unless ( XMLAttributes_getURI(NULL, 0) == NULL );  
  fail_unless ( XMLAttributes_getValue(NULL, 0) == NULL );  
  fail_unless ( XMLAttributes_getValueByName(NULL, NULL) == NULL );  
  fail_unless ( XMLAttributes_getValueByNS(NULL, NULL, NULL) == NULL );  
  fail_unless ( XMLAttributes_getValueByTriple(NULL, NULL) == NULL );  
  fail_unless ( XMLAttributes_hasAttribute(NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_hasAttributeWithName(NULL, NULL) == 0 );  
  fail_unless ( XMLAttributes_hasAttributeWithNS(NULL, NULL, NULL) == 0 );  
  fail_unless ( XMLAttributes_hasAttributeWithTriple(NULL, NULL) == 0 );  
  fail_unless ( XMLAttributes_isEmpty(NULL) == 1 );  
  fail_unless ( XMLAttributes_readIntoBoolean(NULL, NULL, NULL, NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_readIntoBooleanByTriple(NULL, NULL, NULL, NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_readIntoDouble(NULL, NULL, NULL, NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_readIntoDoubleByTriple(NULL, NULL, NULL, NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_readIntoInt(NULL, NULL, NULL, NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_readIntoIntByTriple(NULL, NULL, NULL, NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_readIntoLong(NULL, NULL, NULL, NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_readIntoLongByTriple(NULL, NULL, NULL, NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_readIntoString(NULL, NULL, NULL, NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_readIntoStringByTriple(NULL, NULL, NULL, NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_readIntoUnsignedInt(NULL, NULL, NULL, NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_readIntoUnsignedIntByTriple(NULL, NULL, NULL, NULL, 0) == 0 );  
  fail_unless ( XMLAttributes_remove(NULL, 0) == LIBSBML_INVALID_OBJECT );  
  fail_unless ( XMLAttributes_removeByName(NULL, NULL) == LIBSBML_INVALID_OBJECT );  
  fail_unless ( XMLAttributes_removeByNS(NULL, NULL, NULL) == LIBSBML_INVALID_OBJECT );  
  fail_unless ( XMLAttributes_removeByTriple(NULL, NULL) == LIBSBML_INVALID_OBJECT );  
  fail_unless ( XMLAttributes_removeResource(NULL, 0) == LIBSBML_INVALID_OBJECT );  
}
END_TEST

Suite *
create_suite_XMLAttributes_C (void)
{
  Suite *suite = suite_create("XMLAttributesC");
  TCase *tcase = tcase_create("XMLAttributesC");

  tcase_add_test( tcase, test_XMLAttributes_create_C  );
  tcase_add_test( tcase, test_XMLAttributes_add_remove_qname_C);
  tcase_add_test( tcase, test_XMLAttributes_add1);
  tcase_add_test( tcase, test_XMLAttributes_readInto_string_C );
  tcase_add_test( tcase, test_XMLAttributes_readInto_boolean_C );
  tcase_add_test( tcase, test_XMLAttributes_readInto_double_C );
  tcase_add_test( tcase, test_XMLAttributes_readInto_long_C );
  tcase_add_test( tcase, test_XMLAttributes_readInto_int_C );
  tcase_add_test( tcase, test_XMLAttributes_readInto_uint_C );
  tcase_add_test( tcase, test_XMLAttributes_remove1);
  tcase_add_test( tcase, test_XMLAttributes_clear1);
  tcase_add_test( tcase, test_XMLAttributes_accessWithNULL     );
  suite_add_tcase(suite, tcase);

  return suite;
}

#if defined(__cplusplus)
CK_CPPEND
#endif
