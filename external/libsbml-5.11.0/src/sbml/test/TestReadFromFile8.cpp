/**
 * \file    TestReadFromFile8.cpp
 * \brief   Reads test-data/l2v4-new.xml into memory and tests it.
 * \author  Sarah Keating
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
#include <sbml/SBMLWriter.h>
#include <sbml/SBMLTypes.h>

#include <string>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS


extern char *TestDataDirectory;


START_TEST (test_read_l2v4_new)
{
  SBMLReader        reader;
  SBMLDocument*     d;
  Model*            m;
  Compartment*      c;
  Event*            e;
  Trigger*          trigger;
  EventAssignment*  ea;
  
  const ASTNode*   ast;

  std::string filename(TestDataDirectory);
  filename += "l2v4-new.xml";


  d = reader.readSBML(filename);

  if (d == NULL)
  {
    fail("readSBML(\"l2v4-new.xml\") returned a NULL pointer.");
  }



  //
  // <sbml level="2" version="3" ...>
  //
  fail_unless( d->getLevel  () == 2, NULL );
  fail_unless( d->getVersion() == 4, NULL );


  //
  // <model id="l2v4_all">
  //
  m = d->getModel();
  fail_unless( m != NULL, NULL );

  fail_unless(m->getId() == "l2v4_all", NULL);


  //<listOfCompartments>
  //  <compartment id="a" size="1" constant="false"/>
  //</listOfCompartments>
  fail_unless( m->getNumCompartments() == 1, NULL );

  c = m->getCompartment(0);
  fail_unless( c          != NULL  , NULL );
  fail_unless( c->getId() == "a", NULL );
  fail_unless( c->getSize() == 1, NULL );
  fail_unless( !c->getConstant(), NULL );


  //<event useValuesFromTriggerTime="true">
  //  <trigger>
  //    <math xmlns="http://www.w3.org/1998/Math/MathML">
  //      <apply>
  //        <lt/>
  //        <ci> x </ci>
  //        <cn type="integer"> 3 </cn>
  //      </apply>
  //    </math>
  //  </trigger>
  //  <listOfEventAssignments>
  //    <eventAssignment variable="a">
  //      <math xmlns="http://www.w3.org/1998/Math/MathML">
  //        <apply>
  //          <times/>
  //          <ci> x </ci>
  //          <ci> p3 </ci>
  //        </apply>
  //      </math>
  //    </eventAssignment>
  //  </listOfEventAssignments>
  //</event>
  fail_unless( m->getNumEvents() == 1, NULL );

  e = m->getEvent(0);
  fail_unless(e != NULL, NULL);

  fail_unless(e->getUseValuesFromTriggerTime(), NULL);

  fail_unless(e->isSetTrigger(), NULL);
  
  trigger = e->getTrigger();
  fail_unless(trigger != NULL, NULL);

  ast = trigger->getMath();
  char* math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "lt(x, 3)"), NULL);
  safe_free(math);

  fail_unless( e->getNumEventAssignments() == 1, NULL );

  ea = e->getEventAssignment(0);
  fail_unless(ea != NULL, NULL);

  fail_unless(ea->getVariable() == "a", NULL);

  ast = ea->getMath();
  math = SBML_formulaToString(ast);
  fail_unless(!strcmp(math, "x * p3"), NULL);
  safe_free(math);


  delete d;
}
END_TEST


Suite *
create_suite_TestReadFromFile8 (void)
{ 
  Suite *suite = suite_create("test-data/l2v4-new.xml");
  TCase *tcase = tcase_create("test-data/l2v4-new.xml");


  tcase_add_test(tcase, test_read_l2v4_new);

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
