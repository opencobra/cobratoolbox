/**
 * \file    TestReadSBML.cpp
 * \brief   Read SBML unit tests
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

#include <iostream>

#include <sbml/common/common.h>

#include <sbml/math/ASTNode.h>
#include <sbml/math/FormulaFormatter.h>

#include <sbml/SBMLTypes.h>
#include <sbml/SBMLReader.h>
#include <sbml/SBMLError.h>

#include <check.h>

/** @cond doxygenIgnored */

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

/** @endcond */

CK_CPPSTART

//TO DO - add namespace

#define XML_HEADER        "<?xml version='1.0' encoding='UTF-8'?>\n"
#define SBML_HEADER_L1v1  "<sbml xmlns='http://www.sbml.org/sbml/level1' level='1' version='1'> <model name='m'>\n"
#define SBML_HEADER_L1v2  "<sbml xmlns='http://www.sbml.org/sbml/level1' level='1' version='2'> <model name='m'>\n"
#define SBML_HEADER_L2v1  "<sbml xmlns='http://www.sbml.org/sbml/level2' level='2' version='1'> <model name='m'>\n"
#define SBML_HEADER_L2v2  "<sbml xmlns='http://www.sbml.org/sbml/level2/version2' level='2' version='2'> <model name='m'>\n"
#define SBML_HEADER_L2v3  "<sbml xmlns='http://www.sbml.org/sbml/level2/version3' level='2' version='3'> <model name='m'>\n"
#define SBML_FOOTER       "</model> </sbml>"

/**
 * Wraps the string s in the appropriate XML or SBML boilerplate.
 */
#define wrapXML(s)        XML_HEADER s
#define wrapSBML_L1v1(s)  XML_HEADER SBML_HEADER_L1v1 s SBML_FOOTER
#define wrapSBML_L1v2(s)  XML_HEADER SBML_HEADER_L1v2 s SBML_FOOTER
#define wrapSBML_L2v1(s)  XML_HEADER SBML_HEADER_L2v1 s SBML_FOOTER
#define wrapSBML_L2v2(s)  XML_HEADER SBML_HEADER_L2v2 s SBML_FOOTER
#define wrapSBML_L2v3(s)  XML_HEADER SBML_HEADER_L2v3 s SBML_FOOTER


static SBMLDocument_t *D;
static Model_t        *M;


static void
ReadSBML_setup ()
{
  D = NULL;
}


static void
ReadSBML_teardown ()
{
  SBMLDocument_free(D);
}

START_TEST (test_ReadSBML_prefix)
{
  const char* unprefixed = 
    "<?xml version='1.0' encoding='UTF-8'?>"
    "<sbml xmlns='http://www.sbml.org/sbml/level2/version4' level='2' version='4'>"
    "  <model id='Model1' name='New Model'>"
    "    <listOfCompartments>"
    "      <compartment id='compartment_2' name='compartment_2' size='1'/>"
    "    </listOfCompartments>"
    "    <listOfSpecies>"
    "      <species id='species_2' name='species_2' compartment='compartment_2' initialConcentration='1'/>"
    "    </listOfSpecies>"
    "  </model>"
    "</sbml>";
  
  const char* prefixed = 
    "<?xml version='1.0' encoding='UTF-8'?>"
    "<sbml:sbml xmlns:sbml='http://www.sbml.org/sbml/level2/version4' sbml:level='2' sbml:version='4'>"
    "  <sbml:model sbml:id='Model1' sbml:name='New Model'>"
    "    <sbml:listOfCompartments>"
    "      <sbml:compartment sbml:id='compartment_1' sbml:name='compartment_1' sbml:size='1'/>"
    "    </sbml:listOfCompartments>"
    "    <sbml:listOfSpecies>"
    "      <sbml:species sbml:id='species_1' sbml:name='species_1' sbml:compartment='compartment_1' sbml:initialConcentration='1'/>"
    "    </sbml:listOfSpecies>"
    "  </sbml:model>"
    "</sbml:sbml>";
    

  SBMLDocument *doc1 = readSBMLFromString(unprefixed);
  SBMLDocument *doc2 = readSBMLFromString(prefixed);

  Model *model1 = doc1->getModel();
  Model *model2 = doc2->getModel();

  fail_unless(model1 != NULL);
  fail_unless(model2 != NULL);
  
  fail_unless(model1->addCompartment(model2->getCompartment(0)) == LIBSBML_OPERATION_SUCCESS);
  fail_unless(model1->addSpecies(model2->getSpecies(0)) == LIBSBML_OPERATION_SUCCESS);

  fail_unless(model2->addCompartment(model1->getCompartment(0)) == LIBSBML_OPERATION_SUCCESS);
  fail_unless(model2->addSpecies(model1->getSpecies(0)) == LIBSBML_OPERATION_SUCCESS);
  
  delete doc1;
  delete doc2;

}
END_TEST

START_TEST (test_ReadSBML_SBML)
{
  const char* s = wrapXML("<sbml level='1' version='1'> </sbml>");
  

  D = readSBMLFromString(s);

  fail_unless(SBMLDocument_getLevel  (D) == 1);
  fail_unless(SBMLDocument_getVersion(D) == 1);
}
END_TEST

START_TEST (test_ReadSBML_SBML_ONLY)
{
  const char* s = wrapXML("<sbml/>");
  D = readSBMLFromString(s);
  
  // write SBML to string
  char * sSBML = D->toSBML();

  // ensure that we are still there
  fail_unless(sSBML != NULL);
  free (sSBML);

  // check that the errors were logged
  fail_unless(SBMLDocument_getNumErrors(D) == 2);
}
END_TEST

START_TEST (test_ReadSBML_Model)
{
  const char* s = wrapXML
  (
    "<sbml level='1' version='1'>"
    "  <model name='testModel'></model>"
    "</sbml>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( !strcmp(Model_getId(M), "testModel") );
}
END_TEST

START_TEST (test_ReadSBML_Model_withoutEncoding)
{
  
  const char* s = 
    "<sbml level='2' version='1' xmlns='http://www.sbml.org/sbml/level2'>"
    "  <model id='testModel'></model>"
    "</sbml>";


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( !strcmp(Model_getId(M), "testModel") );
  fail_unless (SBMLDocument_getNumErrors(D) == 0);

  /*
  const char* s2 = 
    "<?xml version='1.0' encoding='UTF-8'?>\n"
    "<sbml level='2' version='1' xmlns='http://www.sbml.org/sbml/level2'>"
    "  <model id='testModel'></model>"
    "</sbml>";
  */

  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( !strcmp(Model_getId(M), "testModel") );
  fail_unless (SBMLDocument_getNumErrors(D) == 0);

}
END_TEST

START_TEST (test_ReadSBML_Model_L2)
{
  const char* s = wrapXML
  (
    "<sbml level='2' version='1'>"
    "  <model id='testModel'> </model>"
    "</sbml>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless(  Model_isSetId  (M) );
  fail_unless( !Model_isSetName(M) );

  fail_unless( !strcmp(Model_getId(M), "testModel") );
}
END_TEST


START_TEST (test_ReadSBML_FunctionDefinition)
{
  FunctionDefinition_t* fd;
  const ASTNode_t*      math;
  char*                 formula;

  const char* s = wrapSBML_L2v1
  (
    "<listOfFunctionDefinitions>"
    "  <functionDefinition id='pow3' name='cubed'>"
    "    <math>"
    "      <lambda>"
    "        <bvar><ci> x </ci></bvar>"
    "        <apply>"
    "          <power/>"
    "          <ci> x </ci>"
    "          <cn> 3 </cn>"
    "        </apply>"
    "      </lambda>"
    "    </math>"
    "  </functionDefinition>"
    "</listOfFunctionDefinitions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumFunctionDefinitions(M) == 1 );

  fd = Model_getFunctionDefinition(M, 0);
  fail_unless( fd != NULL );

  fail_unless( FunctionDefinition_isSetId  (fd) );
  fail_unless( FunctionDefinition_isSetName(fd) );

  fail_unless( !strcmp( FunctionDefinition_getId  (fd), "pow3"  ) );
  fail_unless( !strcmp( FunctionDefinition_getName(fd), "cubed" ) );

  fail_unless( FunctionDefinition_isSetMath(fd) );
  math = FunctionDefinition_getMath(fd);

  formula = SBML_formulaToString(math);
  fail_unless( formula != NULL );

  fail_unless( !strcmp(formula, "lambda(x, pow(x, 3))") );

  safe_free(formula);
}
END_TEST

START_TEST (test_ReadSBML_FunctionDefinition_MathReturnsCN)
{
  FunctionDefinition_t* fd;
  const ASTNode_t*      math;
  char*                 formula;

  const char* s = wrapSBML_L2v1
  (
    "<listOfFunctionDefinitions>"
    "  <functionDefinition id='getNumber'>"
    "    <math>"
    "      <lambda>"
    "        <bvar><ci> x </ci></bvar>"
    "        <cn> 42 </cn>"
    "      </lambda>"
    "    </math>"
    "  </functionDefinition>"
    "</listOfFunctionDefinitions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumFunctionDefinitions(M) == 1 );

  fd = Model_getFunctionDefinition(M, 0);
  fail_unless( fd != NULL );

  fail_unless( FunctionDefinition_isSetId  (fd) );
  fail_unless( !FunctionDefinition_isSetName(fd) );

  fail_unless( !strcmp( FunctionDefinition_getId  (fd), "getNumber"  ) );

  fail_unless( FunctionDefinition_isSetMath(fd) );
  math = FunctionDefinition_getMath(fd);

  formula = SBML_formulaToString(math);
  fail_unless( formula != NULL );

  fail_unless( !strcmp(formula, "lambda(x, 42)") );

  safe_free(formula);
}
END_TEST

START_TEST (test_ReadSBML_FunctionDefinition_OnlyBVars)
{
  FunctionDefinition_t* fd;
  const SBMLError_t*	error;
  int					numErrors;
  const ASTNode_t*      math;
  char*                 formula;

  const char* s = wrapSBML_L2v1
  (
    "<listOfFunctionDefinitions>"
    "  <functionDefinition id='invalid'>"
    "    <math xmlns='http://www.w3.org/1998/Math/MathML'>"
    "      <lambda>"
    "        <bvar><ci> x </ci></bvar>"
    "        <bvar><ci> y </ci></bvar>"
    "        <bvar><ci> z </ci></bvar>"
    "      </lambda>"
    "    </math>"
    "  </functionDefinition>"
    "</listOfFunctionDefinitions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  SBMLDocument_checkInternalConsistency(D);
  SBMLDocument_checkConsistency(D);
  numErrors = SBMLDocument_getNumErrors(D);
  fail_unless(numErrors == 1);
  error = SBMLDocument_getError(D, 0);
  
  fail_unless(XMLError_getErrorId(error) == NoBodyInFunctionDef);
  
  fail_unless( Model_getNumFunctionDefinitions(M) == 1 );

  fd = Model_getFunctionDefinition(M, 0);
  fail_unless( fd != NULL );

  fail_unless( FunctionDefinition_isSetId  (fd) );
  fail_unless( !FunctionDefinition_isSetName(fd) );

  fail_unless( !strcmp( FunctionDefinition_getId  (fd), "invalid"  ) );
  fail_unless( FunctionDefinition_getBody(fd) == NULL );

  fail_unless( FunctionDefinition_isSetMath(fd) );
  math = FunctionDefinition_getMath(fd);

  formula = SBML_formulaToString(math);
  fail_unless( formula != NULL );

  fail_unless( !strcmp(formula, "lambda(x, y, z)") );  

  safe_free(formula);
}
END_TEST


START_TEST (test_ReadSBML_UnitDefinition)
{
  UnitDefinition_t* ud;

  const char* s = wrapSBML_L1v2
  (
    "<listOfUnitDefinitions>"
    "  <unitDefinition name='mmls'/>"
    "</listOfUnitDefinitions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumUnitDefinitions(M) == 1 );

  ud = Model_getUnitDefinition(M, 0);
  fail_unless( !strcmp(UnitDefinition_getId(ud), "mmls") );
}
END_TEST


START_TEST (test_ReadSBML_UnitDefinition_L2)
{
  UnitDefinition_t* ud;

  const char* s = wrapSBML_L2v1
  (
    "<listOfUnitDefinitions>"
    "  <unitDefinition id='mmls' name='mmol/ls'/>"
    "</listOfUnitDefinitions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumUnitDefinitions(M) == 1 );

  ud = Model_getUnitDefinition(M, 0);

  fail_unless( UnitDefinition_isSetId  (ud) );
  fail_unless( UnitDefinition_isSetName(ud) );

  fail_unless( !strcmp(UnitDefinition_getId  (ud), "mmls")    );
  fail_unless( !strcmp(UnitDefinition_getName(ud), "mmol/ls") );
}
END_TEST


START_TEST (test_ReadSBML_Unit)
{
  Unit_t*           u;
  UnitDefinition_t* ud;


  const char* s = wrapSBML_L1v2
  (
    "<listOfUnitDefinitions>"
    "  <unitDefinition name='substance'>"
    "    <listOfUnits> <unit kind='mole' scale='-3'/> </listOfUnits>"
    "  </unitDefinition>"
    "</listOfUnitDefinitions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumUnitDefinitions(M) == 1 );

  ud = Model_getUnitDefinition(M, 0);

  fail_unless( !strcmp(UnitDefinition_getId(ud), "substance") );
  fail_unless( UnitDefinition_getNumUnits(ud) == 1 );

  u = UnitDefinition_getUnit(ud, 0);

  fail_unless( Unit_getKind    (u) == UNIT_KIND_MOLE );
  fail_unless( Unit_getExponent(u) ==  1 );
  fail_unless( Unit_getScale   (u) == -3 );
}
END_TEST


START_TEST (test_ReadSBML_Unit_L2)
{
  Unit_t*           u;
  UnitDefinition_t* ud;


  const char* s = wrapSBML_L2v1
  (
    "<listOfUnitDefinitions>"
    "  <unitDefinition id='Fahrenheit'>"
    "    <listOfUnits>"
    "      <unit kind='Celsius' multiplier='1.8' offset='32'/>"
    "    </listOfUnits>"
    "  </unitDefinition>"
    "</listOfUnitDefinitions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumUnitDefinitions(M) == 1 );

  ud = Model_getUnitDefinition(M, 0);

  fail_unless( UnitDefinition_isSetId(ud) );
  fail_unless( !strcmp(UnitDefinition_getId(ud), "Fahrenheit") );

  fail_unless( UnitDefinition_getNumUnits(ud) == 1 );

  u = UnitDefinition_getUnit(ud, 0);

  fail_unless( Unit_getKind      (u) == UNIT_KIND_CELSIUS );
  fail_unless( Unit_getExponent  (u) ==  1  , NULL );
  fail_unless( Unit_getScale     (u) ==  0  , NULL );
  fail_unless( Unit_getMultiplier(u) ==  1.8, NULL );
  fail_unless( Unit_getOffset    (u) == 32  , NULL );
}
END_TEST


START_TEST (test_ReadSBML_Unit_defaults_L1_L2)
{
  Unit_t*           u;
  UnitDefinition_t* ud;


  const char* s = wrapSBML_L1v2
  (
    "<listOfUnitDefinitions>"
    "  <unitDefinition name='bogomips'>"
    "    <listOfUnits> <unit kind='second'/> </listOfUnits>"
    "  </unitDefinition>"
    "</listOfUnitDefinitions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumUnitDefinitions(M) == 1 );

  ud = Model_getUnitDefinition(M, 0);

  fail_unless( !strcmp(UnitDefinition_getId(ud), "bogomips") );
  fail_unless( UnitDefinition_getNumUnits(ud) == 1 );

  u = UnitDefinition_getUnit(ud, 0);

  fail_unless( Unit_getKind      (u) == UNIT_KIND_SECOND );
  fail_unless( Unit_getExponent  (u) ==  1   );
  fail_unless( Unit_getScale     (u) ==  0   );
  fail_unless( Unit_getMultiplier(u) ==  1.0 );
  fail_unless( Unit_getOffset    (u) ==  0.0 );
}
END_TEST


START_TEST (test_ReadSBML_Compartment)
{
  Compartment_t* c;

  const char* s = wrapSBML_L1v2
  (
    "<listOfCompartments>"
    "  <compartment name='mitochondria' volume='.0001' units='milliliters'"
    "               outside='cell'/>"
    "</listOfCompartments>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumCompartments(M) == 1 );

  c = Model_getCompartment(M, 0);

  fail_unless( !strcmp( Compartment_getId     (c), "mitochondria" ) );
  fail_unless( !strcmp( Compartment_getUnits  (c), "milliliters"  ) );
  fail_unless( !strcmp( Compartment_getOutside(c), "cell"         ) );
  fail_unless( Compartment_getVolume(c) == .0001 );

  fail_unless( Compartment_isSetVolume(c) );
  fail_unless( Compartment_isSetSize  (c) );
}
END_TEST


START_TEST (test_ReadSBML_Compartment_L2)
{
  Compartment_t* c;

  const char* s = wrapSBML_L2v1
  (
    "<listOfCompartments>"
    "  <compartment id='membrane' size='.3' spatialDimensions='2'"
    "               units='area' outside='tissue' constant='false'/>"
    "</listOfCompartments>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumCompartments(M) == 1 );

  c = Model_getCompartment(M, 0);

  fail_unless(  Compartment_isSetId     (c) );
  fail_unless( !Compartment_isSetName   (c) );
  fail_unless(  Compartment_isSetVolume (c) );
  fail_unless(  Compartment_isSetSize   (c) );
  fail_unless(  Compartment_isSetUnits  (c) );
  fail_unless(  Compartment_isSetOutside(c) );

  fail_unless( !strcmp( Compartment_getId     (c), "membrane" ) );
  fail_unless( !strcmp( Compartment_getUnits  (c), "area"     ) );
  fail_unless( !strcmp( Compartment_getOutside(c), "tissue"   ) );

  fail_unless( Compartment_getSpatialDimensions(c) == 2 );
  fail_unless( Compartment_getSize(c) == .3 );
}
END_TEST


START_TEST (test_ReadSBML_Compartment_defaults)
{
  Compartment_t* c;

  const char* s = wrapSBML_L1v2
  (
     "<listOfCompartments> <compartment name='cell'/> </listOfCompartments>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumCompartments(M) == 1 );

  c = Model_getCompartment(M, 0);

  fail_unless(  Compartment_isSetId     (c) );
  fail_unless(  Compartment_isSetVolume (c) );
  fail_unless( !Compartment_isSetSize   (c) );
  fail_unless( !Compartment_isSetUnits  (c) );
  fail_unless( !Compartment_isSetOutside(c) );

  fail_unless( !strcmp( Compartment_getId(c), "cell" ) );
  fail_unless( Compartment_getVolume(c) == 1.0  );
}
END_TEST


START_TEST (test_ReadSBML_Compartment_defaults_L2)
{
  Compartment_t* c;

  const char* s = wrapSBML_L2v1
  (
     "<listOfCompartments> <compartment id='cell'/> </listOfCompartments>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumCompartments(M) == 1 );

  c = Model_getCompartment(M, 0);

  fail_unless(  Compartment_isSetId     (c) );
  fail_unless( !Compartment_isSetName   (c) );
  fail_unless( !Compartment_isSetSize   (c) );
  fail_unless( !Compartment_isSetUnits  (c) );
  fail_unless( !Compartment_isSetOutside(c) );

  fail_unless( !strcmp( Compartment_getId(c), "cell" ) );

  fail_unless( Compartment_getSpatialDimensions(c) == 3 );
  fail_unless( Compartment_getConstant(c)          == 1 );
}
END_TEST


START_TEST (test_ReadSBML_Specie)
{
  Species_t* sp;

  const char* s = wrapSBML_L1v1
  (
    "<listOfSpecie>"
    "  <specie name='Glucose' compartment='cell' initialAmount='4.1'"
    "          units='volume' boundaryCondition='false' charge='6'/>"
    "</listOfSpecie>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumSpecies(M) == 1 );

  sp = Model_getSpecies(M, 0);

  fail_unless( !strcmp( Species_getId         (sp), "Glucose" ) );
  fail_unless( !strcmp( Species_getCompartment(sp), "cell"    ) );
  fail_unless( !strcmp( Species_getUnits      (sp), "volume"  ) );

  fail_unless( Species_getInitialAmount    (sp) == 4.1 );
  fail_unless( Species_getBoundaryCondition(sp) == 0   );
  fail_unless( Species_getCharge           (sp) == 6   );

  fail_unless( Species_isSetInitialAmount(sp) == 1 );
  fail_unless( Species_isSetCharge       (sp) == 1 );
}
END_TEST


START_TEST (test_ReadSBML_Specie_defaults)
{
  Species_t* sp;

  const char* s = wrapSBML_L1v1
  (
    "<listOfSpecie>"
    "  <specie name='Glucose' compartment='cell' initialAmount='1.0'/>"
    "</listOfSpecie>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumSpecies(M) == 1 );

  sp = Model_getSpecies(M, 0);

  fail_unless( !strcmp( Species_getId         (sp), "Glucose" ) );
  fail_unless( !strcmp( Species_getCompartment(sp), "cell"    ) );

  fail_unless( Species_getInitialAmount    (sp) == 1.0 );
  fail_unless( Species_getBoundaryCondition(sp) == 0   );

  fail_unless( Species_isSetInitialAmount(sp) == 1 );
  fail_unless( Species_isSetCharge       (sp) == 0 );
}
END_TEST


START_TEST (test_ReadSBML_Species)
{
  Species_t* sp;

  const char* s = wrapSBML_L1v2
  (
    "<listOfSpecies>"
    "  <species name='Glucose' compartment='cell' initialAmount='4.1'"
    "           units='volume' boundaryCondition='false' charge='6'/>"
    "</listOfSpecies>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumSpecies(M) == 1 );

  sp = Model_getSpecies(M, 0);

  fail_unless( !strcmp( Species_getId         (sp), "Glucose" ) );
  fail_unless( !strcmp( Species_getCompartment(sp), "cell"    ) );
  fail_unless( !strcmp( Species_getUnits      (sp), "volume"  ) );

  fail_unless( Species_getInitialAmount    (sp) == 4.1 );
  fail_unless( Species_getBoundaryCondition(sp) == 0   );
  fail_unless( Species_getCharge           (sp) == 6   );

  fail_unless( Species_isSetInitialAmount(sp) == 1 );
  fail_unless( Species_isSetCharge       (sp) == 1 );
}
END_TEST


START_TEST (test_ReadSBML_Species_L2_1)
{
  Species_t* sp;

  const char* s = wrapSBML_L2v1
  (
    "<listOfSpecies>"
    "  <species id='Glucose' compartment='cell' initialConcentration='4.1'"
    "           substanceUnits='item' spatialSizeUnits='volume'"
    "           boundaryCondition='true' charge='6' constant='true'/>"
    "</listOfSpecies>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumSpecies(M) == 1 );

  sp = Model_getSpecies(M, 0);

  fail_unless(  Species_isSetId                  (sp) );
  fail_unless( !Species_isSetName                (sp) );
  fail_unless(  Species_isSetCompartment         (sp) );
  fail_unless( !Species_isSetInitialAmount       (sp) );
  fail_unless(  Species_isSetInitialConcentration(sp) );
  fail_unless(  Species_isSetSubstanceUnits      (sp) );
  fail_unless(  Species_isSetSpatialSizeUnits    (sp) );
  fail_unless(  Species_isSetCharge              (sp) );

  fail_unless( !strcmp( Species_getId              (sp), "Glucose" ) );
  fail_unless( !strcmp( Species_getCompartment     (sp), "cell"    ) );
  fail_unless( !strcmp( Species_getSubstanceUnits  (sp), "item"    ) );
  fail_unless( !strcmp( Species_getSpatialSizeUnits(sp), "volume"  ) );

  fail_unless( Species_getInitialConcentration (sp) == 4.1 );
  fail_unless( Species_getHasOnlySubstanceUnits(sp) == 0   );
  fail_unless( Species_getBoundaryCondition    (sp) == 1   );
  fail_unless( Species_getCharge               (sp) == 6   );
  fail_unless( Species_getConstant             (sp) == 1   );
}
END_TEST


START_TEST (test_ReadSBML_Species_L2_2)
{
  Species_t* sp;

  const char* s = wrapSBML_L2v1
  (
    "<listOfSpecies>"
    "  <species id='s' compartment='c' hasOnlySubstanceUnits='true'/>"
    "</listOfSpecies>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumSpecies(M) == 1 );

  sp = Model_getSpecies(M, 0);

  fail_unless(  Species_isSetId                  (sp) );
  fail_unless( !Species_isSetName                (sp) );
  fail_unless(  Species_isSetCompartment         (sp) );
  fail_unless( !Species_isSetInitialAmount       (sp) );
  fail_unless( !Species_isSetInitialConcentration(sp) );
  fail_unless( !Species_isSetSubstanceUnits      (sp) );
  fail_unless( !Species_isSetSpatialSizeUnits    (sp) );
  fail_unless( !Species_isSetCharge              (sp) );

  fail_unless( !strcmp( Species_getId         (sp), "s" ) );
  fail_unless( !strcmp( Species_getCompartment(sp), "c" ) );

  fail_unless( Species_getHasOnlySubstanceUnits(sp) == 1 );
  fail_unless( Species_getBoundaryCondition    (sp) == 0 );
  fail_unless( Species_getConstant             (sp) == 0 );
}
END_TEST


START_TEST (test_ReadSBML_Species_L2_defaults)
{
  Species_t* sp;

  const char* s = wrapSBML_L2v1
  (
    "<listOfSpecies>"
    "  <species id='Glucose_6_P' compartment='cell'/>"
    "</listOfSpecies>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumSpecies(M) == 1 );

  sp = Model_getSpecies(M, 0);

  fail_unless(  Species_isSetId                  (sp) );
  fail_unless( !Species_isSetName                (sp) );
  fail_unless(  Species_isSetCompartment         (sp) );
  fail_unless( !Species_isSetInitialAmount       (sp) );
  fail_unless( !Species_isSetInitialConcentration(sp) );
  fail_unless( !Species_isSetSubstanceUnits      (sp) );
  fail_unless( !Species_isSetSpatialSizeUnits    (sp) );
  fail_unless( !Species_isSetCharge              (sp) );

  fail_unless( !strcmp( Species_getId         (sp), "Glucose_6_P" ) );
  fail_unless( !strcmp( Species_getCompartment(sp), "cell"        ) );

  fail_unless( Species_getHasOnlySubstanceUnits(sp) == 0 );
  fail_unless( Species_getBoundaryCondition    (sp) == 0 );
  fail_unless( Species_getConstant             (sp) == 0 );
}
END_TEST


START_TEST (test_ReadSBML_Parameter)
{
  Parameter_t* p;

  const char* s = wrapSBML_L1v2
  (
    "<listOfParameters>"
    "  <parameter name='Km1' value='2.3' units='second'/>"
    "</listOfParameters>"
  );

    
  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumParameters(M) == 1 );

  p = Model_getParameter(M, 0);

  fail_unless( !strcmp( Parameter_getId   (p), "Km1"    ) );
  fail_unless( !strcmp( Parameter_getUnits(p), "second" ) );
  fail_unless( Parameter_getValue(p) == 2.3 );

  fail_unless( Parameter_isSetValue(p) == 1 );
}
END_TEST


START_TEST (test_ReadSBML_Parameter_L2)
{
  Parameter_t* p;

  const char* s = wrapSBML_L2v1
  (
    "<listOfParameters>"
    "  <parameter id='T' value='4.6' units='Celsius' constant='false'/>"
    "</listOfParameters>"
  );

    
  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumParameters(M) == 1 );

  p = Model_getParameter(M, 0);

  fail_unless(  Parameter_isSetId   (p) );
  fail_unless( !Parameter_isSetName (p) );
  fail_unless(  Parameter_isSetValue(p) );
  fail_unless(  Parameter_isSetUnits(p) );

  fail_unless( !strcmp( Parameter_getId   (p), "T"       ) );
  fail_unless( !strcmp( Parameter_getUnits(p), "Celsius" ) );

  fail_unless( Parameter_getValue   (p) == 4.6 );
  fail_unless( Parameter_getConstant(p) == 0   );
}
END_TEST


START_TEST (test_ReadSBML_Parameter_L2_defaults)
{
  Parameter_t* p;

  const char* s = wrapSBML_L2v1
  (
    "<listOfParameters> <parameter id='x'/> </listOfParameters>"
  );

    
  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumParameters(M) == 1 );

  p = Model_getParameter(M, 0);

  fail_unless(  Parameter_isSetId   (p) );
  fail_unless( !Parameter_isSetName (p) );
  fail_unless( !Parameter_isSetValue(p) );
  fail_unless( !Parameter_isSetUnits(p) );

  fail_unless( !strcmp(Parameter_getId(p), "x") );
  fail_unless( Parameter_getConstant(p) == 1 );
}
END_TEST


START_TEST (test_ReadSBML_Reaction)
{
  Reaction_t* r;

  const char* s = wrapSBML_L1v2
  (
    "<listOfReactions>"
    "  <reaction name='reaction_1' reversible='false'/>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);
  
  fail_unless( Model_getNumReactions(M) == 1 );
  
  r = Model_getReaction(M, 0);

  fail_unless( !strcmp(Reaction_getId(r), "reaction_1") );
  fail_unless( Reaction_getReversible(r) == 0 );
  fail_unless( Reaction_getFast      (r) == 0 );
}
END_TEST


START_TEST (test_ReadSBML_Reaction_defaults)
{
  Reaction_t* r;
  const char* s = wrapSBML_L1v2
  (
    "<listOfReactions>"
    "  <reaction name='reaction_1'/>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);
  
  fail_unless( Model_getNumReactions(M) == 1 );
  
  r = Model_getReaction(M, 0);

  fail_unless( !strcmp(Reaction_getId(r), "reaction_1") );
  fail_unless( Reaction_getReversible(r) != 0 );
  fail_unless( Reaction_getFast      (r) == 0 );
}
END_TEST


START_TEST (test_ReadSBML_Reaction_L2)
{
  Reaction_t* r;

  const char* s = wrapSBML_L2v1
  (
    "<listOfReactions>"
    "  <reaction id='r1' reversible='false' fast='false'/>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);
  
  fail_unless( Model_getNumReactions(M) == 1 );
  
  r = Model_getReaction(M, 0);

  fail_unless(  Reaction_isSetId  (r) );
  fail_unless( !Reaction_isSetName(r) );
  fail_unless(  Reaction_isSetFast(r) );

  fail_unless( !strcmp( Reaction_getId(r), "r1") );
  fail_unless( Reaction_getReversible(r) == 0 );
  fail_unless( Reaction_getFast(r)       == 0 );
}
END_TEST


START_TEST (test_ReadSBML_Reaction_L2_defaults)
{
  Reaction_t* r;
  const char* s = wrapSBML_L2v1
  (
    "<listOfReactions> <reaction id='r1'/> </listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);
  
  fail_unless( Model_getNumReactions(M) == 1 );
  
  r = Model_getReaction(M, 0);

  fail_unless(  Reaction_isSetId  (r) );
  fail_unless( !Reaction_isSetName(r) );
  fail_unless( !Reaction_isSetFast(r) );

  fail_unless( !strcmp( Reaction_getId(r), "r1") );
  fail_unless( Reaction_getReversible(r) == 1 );
}
END_TEST


START_TEST (test_ReadSBML_SpecieReference_Reactant)
{
  Reaction_t*         r;
  SpeciesReference_t* sr;

  const char* s = wrapSBML_L1v1
  (
    "<listOfReactions>"
    "  <reaction name='reaction_1' reversible='false'>"
    "    <listOfReactants>"
    "      <specieReference specie='X0' stoichiometry='1'/>"
    "    </listOfReactants>"
    "  </reaction>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumReactions(M) == 1 );
  
  r = Model_getReaction(M, 0);

  fail_unless( !strcmp(Reaction_getId(r), "reaction_1") );
  fail_unless( Reaction_getReversible  (r) == 0 );
  fail_unless( Reaction_getNumReactants(r) == 1 );

  sr = Reaction_getReactant(r, 0);

  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "X0") );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1 );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1 );
}
END_TEST


START_TEST (test_ReadSBML_SpecieReference_Product)
{
  Reaction_t*         r;
  SpeciesReference_t* sr;

  const char* s = wrapSBML_L1v1
  (
    "<listOfReactions>"
    "  <reaction name='reaction_1' reversible='false'>"
    "    <listOfProducts>"
    "      <specieReference specie='S1' stoichiometry='1'/>"
    "    </listOfProducts>"
    "  </reaction>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumReactions(M) == 1 );
  
  r = Model_getReaction(M, 0);

  fail_unless( !strcmp(Reaction_getId(r), "reaction_1") );
  fail_unless( Reaction_getReversible (r) == 0 );
  fail_unless( Reaction_getNumProducts(r) == 1 );

  sr = Reaction_getProduct(r, 0);

  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "S1") );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1 );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1 );
}
END_TEST


START_TEST (test_ReadSBML_SpecieReference_defaults)
{
  Reaction_t*         r;
  SpeciesReference_t* sr;

  const char* s = wrapSBML_L1v1
  (
    "<listOfReactions>"
    "  <reaction name='reaction_1' reversible='false'>"
    "    <listOfReactants>"
    "      <specieReference specie='X0'/>"
    "    </listOfReactants>"
    "  </reaction>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumReactions(M) == 1 );
  
  r = Model_getReaction(M, 0);

  fail_unless( !strcmp(Reaction_getId(r), "reaction_1") );
  fail_unless( Reaction_getReversible  (r) == 0 );
  fail_unless( Reaction_getNumReactants(r) == 1 );

  sr = Reaction_getReactant(r, 0);

  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "X0") );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1 );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1 );
}
END_TEST


START_TEST (test_ReadSBML_SpeciesReference_defaults)
{
  Reaction_t*         r;
  SpeciesReference_t* sr;

  const char* s = wrapSBML_L1v2
  (
    "<listOfReactions>"
    "  <reaction name='reaction_1' reversible='false'>"
    "    <listOfReactants>"
    "      <speciesReference species='X0'/>"
    "    </listOfReactants>"
    "  </reaction>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumReactions(M) == 1 );
  
  r = Model_getReaction(M, 0);

  fail_unless( !strcmp(Reaction_getId(r), "reaction_1") );
  fail_unless( Reaction_getReversible  (r) == 0 );
  fail_unless( Reaction_getNumReactants(r) == 1 );

  sr = Reaction_getReactant(r, 0);

  fail_unless( !strcmp(SpeciesReference_getSpecies(sr), "X0") );
  fail_unless( SpeciesReference_getStoichiometry(sr) == 1 );
  fail_unless( SpeciesReference_getDenominator  (sr) == 1 );
}
END_TEST


START_TEST (test_ReadSBML_SpeciesReference_StoichiometryMath_1)
{
  Reaction_t*         r;
  SpeciesReference_t* sr;
  const StoichiometryMath_t*    math;
  char*               formula;

  const char* s = wrapSBML_L2v1
  (
    "<listOfReactions>"
    "  <reaction name='r1'>"
    "    <listOfReactants>"
    "      <speciesReference species='X0'>"
    "        <stoichiometryMath>"
    "          <math> <ci> x </ci> </math>"
    "        </stoichiometryMath>"
    "      </speciesReference>"
    "    </listOfReactants>"
    "  </reaction>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumReactions(M) == 1 );

  r = Model_getReaction(M, 0);
  fail_unless( r != NULL );

  fail_unless( Reaction_getNumReactants(r) == 1 );

  sr = Reaction_getReactant(r, 0);
  fail_unless( sr != NULL );

  fail_unless( SpeciesReference_isSetStoichiometryMath(sr) );
  math = SpeciesReference_getStoichiometryMath(sr);

  formula = SBML_formulaToString(StoichiometryMath_getMath(math));
  fail_unless( formula != NULL );

  fail_unless( !strcmp(formula, "x") );

  safe_free(formula);
}
END_TEST


START_TEST (test_ReadSBML_SpeciesReference_StoichiometryMath_2)
{
  Reaction_t*         r;
  SpeciesReference_t* sr;

  const char* s = wrapSBML_L2v1
  (
    "<listOfReactions>"
    "  <reaction name='r1'>"
    "    <listOfReactants>"
    "      <speciesReference species='X0'>"
    "        <stoichiometryMath>"
    "          <math> <cn type='rational'> 3 <sep/> 2 </cn> </math>"
    "        </stoichiometryMath>"
    "      </speciesReference>"
    "    </listOfReactants>"
    "  </reaction>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumReactions(M) == 1 );

  r = Model_getReaction(M, 0);
  fail_unless( r != NULL );

  fail_unless( Reaction_getNumReactants(r) == 1 );

  sr = Reaction_getReactant(r, 0);
  fail_unless( sr != NULL );

  fail_unless( !SpeciesReference_isSetStoichiometryMath(sr) );

  fail_unless( SpeciesReference_getStoichiometry(sr) == 3 );
  fail_unless( SpeciesReference_getDenominator  (sr) == 2 );
}
END_TEST


START_TEST (test_ReadSBML_KineticLaw)
{
  Reaction_t*   r;
  KineticLaw_t* kl;

  const char* s = wrapSBML_L1v2
  (
    "<listOfReactions>"
    "  <reaction name='J1'>"
    "    <kineticLaw formula='k1*X0'/>"
    "  </reaction>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumReactions(M) == 1 );

  r  = Model_getReaction(M, 0);
  kl = Reaction_getKineticLaw(r);

  fail_unless( !strcmp(KineticLaw_getFormula(kl), "k1*X0") );
}
END_TEST


START_TEST (test_ReadSBML_KineticLaw_L2)
{
  Reaction_t*      r;
  KineticLaw_t*    kl;
  const ASTNode_t* math;
  const char*      formula;

  const char* s = wrapSBML_L2v1
  (
    "<listOfReactions>"
    "  <reaction id='J1'>"
    "    <kineticLaw>"
    "      <math>"
    "        <apply>"
    "          <times/>"
    "          <ci> k  </ci>"
    "          <ci> S2 </ci>"
    "          <ci> X0 </ci>"
    "        </apply>"
    "      </math>"
    "    </kineticLaw>"
    "  </reaction>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumReactions(M) == 1 );

  r = Model_getReaction(M, 0);
  fail_unless( r != NULL );

  kl = Reaction_getKineticLaw(r);
  fail_unless( kl != NULL );

  fail_unless( KineticLaw_isSetMath(kl) );
  math = KineticLaw_getMath(kl);

  formula = KineticLaw_getFormula(kl);
  fail_unless( formula != NULL );

  fail_unless( !strcmp(formula, "k * S2 * X0") );
}
END_TEST


START_TEST (test_ReadSBML_KineticLaw_Parameter)
{
  Reaction_t*   r;
  KineticLaw_t* kl;
  Parameter_t*  p;

  const char* s = wrapSBML_L1v2
  (
    "<listOfReactions>"
    "  <reaction name='J1'>"
    "    <kineticLaw formula='k1*X0'>"
    "      <listOfParameters>"
    "        <parameter name='k1' value='0'/>"
    "      </listOfParameters>"
    "    </kineticLaw>"
    "  </reaction>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumReactions(M) == 1 );

  r  = Model_getReaction(M, 0);
  kl = Reaction_getKineticLaw(r);

  fail_unless( !strcmp(KineticLaw_getFormula(kl), "k1*X0") );
  fail_unless( KineticLaw_getNumParameters(kl) == 1 );

  p = KineticLaw_getParameter(kl, 0);

  fail_unless( !strcmp(Parameter_getId(p), "k1") );
  fail_unless( Parameter_getValue(p) == 0 );
}
END_TEST


START_TEST (test_ReadSBML_AssignmentRule)
{
  Rule_t*           ar;
  const ASTNode_t*  math;
  const char*       formula;

  const char *s = wrapSBML_L2v1
  (
    "<listOfRules>"
    "  <assignmentRule variable='k'>"
    "    <math>"
    "      <apply>"
    "        <divide/>"
    "        <ci> k3 </ci>"
    "        <ci> k2 </ci>"
    "      </apply>"
    "    </math>"
    "  </assignmentRule>"
    "</listOfRules>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumRules(M) == 1 );

  ar = Model_getRule(M, 0);
  fail_unless( ar != NULL );

  fail_unless( Rule_isSetMath(ar) );
  math = Rule_getMath(ar);

  formula = Rule_getFormula(ar);
  fail_unless( formula != NULL );

  fail_unless( !strcmp(formula, "k3 / k2") );
}
END_TEST


START_TEST (test_ReadSBML_RateRule)
{
  Rule_t*          rr;
  const ASTNode_t* math;
  const char*      formula;

  const char *s = wrapSBML_L2v1
  (
    "<listOfRules>"
    "  <rateRule variable='x'>"
    "    <math>"
    "      <apply>"
    "        <times/>"
    "        <apply>"
    "          <minus/>"
    "          <cn> 1 </cn>"
    "          <ci> x </ci>"
    "        </apply>"
    "        <apply>"
    "          <ln/>"
    "          <ci> x </ci>"
    "        </apply>"
    "      </apply>"
    "    </math>"
    "  </rateRule>"
    "</listOfRules>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumRules(M) == 1 );

  rr = Model_getRule(M, 0);
  fail_unless( rr != NULL );

  fail_unless( Rule_isSetMath(rr) );
  math = Rule_getMath(rr);

  formula = Rule_getFormula(rr);
  fail_unless( formula != NULL );

  /**
   * In L1 formula syntax, the natural log (ln) is defined to be log.
   */
  fail_unless( !strcmp(formula, "(1 - x) * log(x)") );
}
END_TEST


START_TEST (test_ReadSBML_AlgebraicRule)
{
  Rule_t *ar;

  const char *s = wrapSBML_L1v2
  (
    "<listOfRules>"
    "  <algebraicRule formula='x + 1'/>"
    "</listOfRules>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumRules(M) == 1 );

  ar = Model_getRule(M, 0);

  fail_unless( !strcmp(Rule_getFormula(ar), "x + 1") );
}
END_TEST


START_TEST (test_ReadSBML_AlgebraicRule_L2)
{
  Rule_t*          ar;
  const ASTNode_t* math;
  const char*      formula;

  const char *s = wrapSBML_L2v1
  (
    "<listOfRules>"
    "  <algebraicRule>"
    "    <math>"
    "      <apply>"
    "        <minus/>"
    "        <apply>"
    "          <plus/>"
    "            <ci> S1 </ci>"
    "            <ci> S2 </ci>"
    "        </apply>"
    "        <ci> T </ci>"
    "      </apply>"
    "    </math>"
    "  </algebraicRule>"
    "</listOfRules>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumRules(M) == 1 );

  ar = Model_getRule(M, 0);
  fail_unless( ar != NULL );

  fail_unless( Rule_isSetMath(ar) );
  math = Rule_getMath(ar);

  formula = Rule_getFormula(ar);
  fail_unless( formula != NULL );

  fail_unless( !strcmp(formula, "S1 + S2 - T") );
}
END_TEST



START_TEST (test_ReadSBML_CompartmentVolumeRule)
{
  Rule_t *cvr;

  const char *s = wrapSBML_L1v2
  (
    "<listOfRules>"
    "  <compartmentVolumeRule compartment='A' formula='0.10 * t'/>"
    "</listOfRules>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumRules(M) == 1 );

  cvr = Model_getRule(M, 0);

  fail_unless( Rule_isCompartmentVolume(cvr) );

  fail_unless( !strcmp( Rule_getVariable(cvr), "A") );
  fail_unless( !strcmp( Rule_getFormula (cvr), "0.10 * t" ) );

  fail_unless( Rule_getType(cvr) == RULE_TYPE_SCALAR );
}
END_TEST


START_TEST (test_ReadSBML_ParameterRule)
{
  Rule_t *pr;

  const char *s = wrapSBML_L1v2
  (
    "<listOfRules>"
    "  <parameterRule name='k' formula='k3/k2'/>"
    "</listOfRules>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumRules(M) == 1 );

  pr = Model_getRule(M, 0);

  fail_unless( Rule_isParameter(pr) );

  fail_unless( !strcmp( Rule_getVariable(pr), "k") );
  fail_unless( !strcmp( Rule_getFormula (pr), "k3/k2" ) );

  fail_unless( Rule_getType(pr) == RULE_TYPE_SCALAR );
}
END_TEST


START_TEST (test_ReadSBML_SpecieConcentrationRule)
{
  Rule_t *scr;

  const char *s = wrapSBML_L1v1
  (
    "<listOfRules>"
    "  <specieConcentrationRule specie='s2' formula='k * t/(1 + k)'/>"
    "</listOfRules>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumRules(M) == 1 );

  scr = Model_getRule(M, 0);

  fail_unless( Rule_isSpeciesConcentration(scr) );

  fail_unless( !strcmp( Rule_getVariable(scr), "s2") );
  fail_unless( !strcmp( Rule_getFormula (scr), "k * t/(1 + k)" ) );

  fail_unless( Rule_getType(scr) == RULE_TYPE_SCALAR );
}
END_TEST


START_TEST (test_ReadSBML_SpecieConcentrationRule_rate)
{
  Rule_t *scr;

  const char *s = wrapSBML_L1v1
  (
    "<listOfRules>"
    "  <specieConcentrationRule specie='s2' formula='k * t/(1 + k)' "
    "                           type='rate'/>"
    "</listOfRules>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumRules(M) == 1 );

  scr = Model_getRule(M, 0);

  fail_unless( Rule_isSpeciesConcentration(scr) );

  fail_unless( !strcmp( Rule_getVariable(scr), "s2") );
  fail_unless( !strcmp( Rule_getFormula (scr), "k * t/(1 + k)" ) );

  fail_unless( Rule_getType(scr) == RULE_TYPE_RATE );
}
END_TEST


START_TEST (test_ReadSBML_SpeciesConcentrationRule)
{
  Rule_t *scr;

  const char *s = wrapSBML_L1v2
  (
    "<listOfRules>"
    "  <speciesConcentrationRule species='s2' formula='k * t/(1 + k)'/>"
    "</listOfRules>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumRules(M) == 1 );

  scr = Model_getRule(M, 0);

  fail_unless( Rule_isSpeciesConcentration(scr) );

  fail_unless( !strcmp( Rule_getVariable(scr), "s2") );
  fail_unless( !strcmp( Rule_getFormula (scr), "k * t/(1 + k)" ) );

  fail_unless( Rule_getType(scr) == RULE_TYPE_SCALAR );
}
END_TEST


START_TEST (test_ReadSBML_Event)
{
  Event_t* e;

  const char* s = wrapSBML_L2v2
  (
    "<listOfEvents>"
    "  <event id='e1' name='MyEvent' timeUnits='time'/>"
    "</listOfEvents>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumEvents(M) == 1 );

  e = Model_getEvent(M, 0);
  fail_unless( e != NULL );

  fail_unless(  Event_isSetId       (e) );
  fail_unless(  Event_isSetName     (e) );
  fail_unless(  Event_isSetTimeUnits(e) );
  fail_unless( !Event_isSetTrigger  (e) );
  fail_unless( !Event_isSetDelay    (e) );

  fail_unless( !strcmp( Event_getId       (e), "e1"      ) );
  fail_unless( !strcmp( Event_getName     (e), "MyEvent" ) );
  fail_unless( !strcmp( Event_getTimeUnits(e), "time"    ) );
}
END_TEST


START_TEST (test_ReadSBML_Event_trigger)
{
  Event_t*         e;
  const Trigger_t* trigger;
  char*            formula;

  const char* s = wrapSBML_L2v1
  (
    "<listOfEvents>"
    "  <event>"
    "    <trigger>"
    "      <math>"
    "        <apply>"
    "          <leq/>"
    "          <ci> P1 </ci>"
    "          <ci> t  </ci>"
    "        </apply>"
    "      </math>"
    "   </trigger>"
    "  </event>"
    "</listOfEvents>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumEvents(M) == 1 );

  e = Model_getEvent(M, 0);
  fail_unless( e != NULL );

  fail_unless( !Event_isSetDelay  (e) );
  fail_unless(  Event_isSetTrigger(e) );

  trigger = Event_getTrigger(e);

  formula = SBML_formulaToString(Trigger_getMath(trigger));
  fail_unless( formula != NULL );

  fail_unless( !strcmp(formula, "leq(P1, t)") );

  safe_free(formula);
}
END_TEST


START_TEST (test_ReadSBML_Event_delay)
{
  Event_t*         e;
  const Delay_t*   delay;
  char*            formula;

  const char* s = wrapSBML_L2v1
  (
    "<listOfEvents>"
    "  <event> <delay> <math> <cn> 5 </cn> </math> </delay> </event>"
    "</listOfEvents>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumEvents(M) == 1 );

  e = Model_getEvent(M, 0);
  fail_unless( e != NULL );

  fail_unless(  Event_isSetDelay  (e) );
  fail_unless( !Event_isSetTrigger(e) );

  delay = Event_getDelay(e);

  formula = SBML_formulaToString(Delay_getMath(delay));
  fail_unless( formula != NULL );

  fail_unless( !strcmp(formula, "5") );

  safe_free(formula);
}
END_TEST


START_TEST (test_ReadSBML_EventAssignment)
{
  Event_t*           e;
  EventAssignment_t* ea;
  const ASTNode_t*   math;
  char*              formula;

  const char* s = wrapSBML_L2v1
  (
    "<listOfEvents>"
    "  <event>"
    "    <listOfEventAssignments>"
    "      <eventAssignment variable='k2'>"
    "        <math> <cn> 0 </cn> </math>"
    "      </eventAssignment>"
    "    </listOfEventAssignments>"
    "  </event>"
    "</listOfEvents>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( Model_getNumEvents(M) == 1 );

  e = Model_getEvent(M, 0);
  fail_unless( e != NULL );

  fail_unless( Event_getNumEventAssignments(e) == 1 );

  ea = Event_getEventAssignment(e, 0);
  fail_unless( ea != NULL );

  fail_unless( EventAssignment_isSetVariable(ea) );
  fail_unless( !strcmp(EventAssignment_getVariable(ea), "k2") );

  fail_unless( EventAssignment_isSetMath(ea) );
  math = EventAssignment_getMath(ea);

  formula = SBML_formulaToString(math);
  fail_unless( formula != NULL );

  fail_unless( !strcmp( formula, "0") );

  safe_free(formula);
}
END_TEST


START_TEST (test_ReadSBML_metaid)
{
  SBase_t*  sb;

  const char* s = wrapSBML_L2v1
  (
    "<listOfFunctionDefinitions>"
    "  <functionDefinition metaid='fd'/>"
    "</listOfFunctionDefinitions>"
    "<listOfUnitDefinitions>"
    "  <unitDefinition metaid='ud'/>"
    "</listOfUnitDefinitions>"
    "<listOfCompartments>"
    "  <compartment metaid='c'/>"
    "</listOfCompartments>"
    "<listOfSpecies>"
    "  <species metaid='s'/>"
    "</listOfSpecies>"
    "<listOfParameters>"
    "  <parameter metaid='p'/>"
    "</listOfParameters>"
    "<listOfRules>"
    "  <rateRule metaid='rr'/>"
    "</listOfRules>"
    "<listOfReactions>"
    "  <reaction metaid='rx'/>"
    "</listOfReactions>"
    "<listOfEvents>"
    " <event metaid='e'/>"
    "</listOfEvents>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( M != NULL );

  sb = (SBase_t *) Model_getFunctionDefinition(M, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "fd") );


  sb = (SBase_t *) Model_getUnitDefinition(M, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "ud") );


  sb = (SBase_t *) Model_getCompartment(M, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "c") );


  sb = (SBase_t *) Model_getSpecies(M, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "s") );


  sb = (SBase_t *) Model_getParameter(M, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "p") );


  sb = (SBase_t *) Model_getRule(M, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "rr") );


  sb = (SBase_t *) Model_getReaction(M, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "rx") );


  sb = (SBase_t *) Model_getEvent(M, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "e") );
}
END_TEST


START_TEST (test_ReadSBML_metaid_Unit)
{
  SBase_t*          sb;
  UnitDefinition_t* ud;

  const char* s = wrapSBML_L2v1
  (
    "<listOfUnitDefinitions>"
    "  <unitDefinition metaid='ud'>"
    "    <listOfUnits metaid='lou'>"
    "      <unit metaid='u'/>"
    "    </listOfUnits>"
    "  </unitDefinition>"
    "</listOfUnitDefinitions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( M != NULL );

  ud = Model_getUnitDefinition(M, 0);
  sb = (SBase_t *) ud;

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "ud") );


  sb = (SBase_t *) UnitDefinition_getListOfUnits(ud);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "lou") );


  sb = (SBase_t *) UnitDefinition_getUnit(ud, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "u") );
}
END_TEST


START_TEST (test_ReadSBML_metaid_Reaction)
{
  SBase_t*    sb;
  Reaction_t* r;

  const char* s = wrapSBML_L2v1
  (
    "<listOfReactions>"
    "  <reaction metaid='r'>"
    "    <listOfReactants metaid='lor'>"
    "      <speciesReference metaid='sr1'/>"
    "    </listOfReactants>"
    "    <listOfProducts metaid='lop'>"
    "      <speciesReference metaid='sr2'/>"
    "    </listOfProducts>"
    "    <listOfModifiers metaid='lom'>"
    "      <modifierSpeciesReference metaid='msr'/>"
    "    </listOfModifiers>"
    "    <kineticLaw metaid='kl'/>"
    "  </reaction>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( M != NULL );

  r  = Model_getReaction(M, 0);
  sb = (SBase_t *) r;

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "r") );


  sb = (SBase_t *) Reaction_getListOfReactants(r);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "lor") );


  sb = (SBase_t *) Reaction_getReactant(r, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "sr1") );


  sb = (SBase_t *) Reaction_getListOfProducts(r);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "lop") );


  sb = (SBase_t *) Reaction_getProduct(r, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "sr2") );


  sb = (SBase_t *) Reaction_getListOfModifiers(r);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "lom") );


  sb = (SBase_t *) Reaction_getModifier(r, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "msr") );


  sb = (SBase_t *) Reaction_getKineticLaw(r);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "kl") );
}
END_TEST


START_TEST (test_ReadSBML_metaid_Event)
{
  SBase_t* sb;
  Event_t* e;

  const char* s = wrapSBML_L2v1
  (
    "<listOfEvents>"
    "  <event metaid='e'>"
    "    <listOfEventAssignments metaid='loea'>"
    "      <eventAssignment metaid='ea'/>"
    "    </listOfEventAssignments>"
    "  </event>"
    "</listOfEvents>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( M != NULL );


  e  = Model_getEvent(M, 0);
  sb = (SBase_t *) e;

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "e") );


  sb = (SBase_t *) Event_getListOfEventAssignments(e);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "loea") );


  sb = (SBase_t *) Event_getEventAssignment(e, 0);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "ea") );
}
END_TEST


START_TEST (test_ReadSBML_metaid_ListOf)
{
  SBase_t*  sb;

  const char* s = wrapSBML_L2v1
  (
    "<listOfFunctionDefinitions metaid='lofd'/>"
    "<listOfUnitDefinitions     metaid='loud'/>"
    "<listOfCompartments        metaid='loc'/>"
    "<listOfSpecies             metaid='los'/>"
    "<listOfParameters          metaid='lop'/>"
    "<listOfRules               metaid='lor'/>"
    "<listOfReactions           metaid='lorx'/>"
    "<listOfEvents              metaid='loe'/>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( M != NULL );

  sb = (SBase_t *) Model_getListOfFunctionDefinitions(M);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "lofd") );


  sb = (SBase_t *) Model_getListOfUnitDefinitions(M);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "loud") );


  sb = (SBase_t *) Model_getListOfCompartments(M);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "loc") );


  sb = (SBase_t *) Model_getListOfSpecies(M);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "los") );


  sb = (SBase_t *) Model_getListOfParameters(M);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "lop") );


  sb = (SBase_t *) Model_getListOfRules(M);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "lor") );


  sb = (SBase_t *) Model_getListOfReactions(M);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "lorx") );


  sb = (SBase_t *) Model_getListOfEvents(M);

  fail_unless( SBase_isSetMetaId(sb) );
  fail_unless( !strcmp(SBase_getMetaId(sb), "loe") );
}
END_TEST


START_TEST (test_ReadSBML_notes)
{
  Reaction_t*   r;
  KineticLaw_t* kl;

  const char* s = wrapSBML_L2v3
  (
  "<listOfReactions>"
    "<reaction name='J1'>"
    "  <kineticLaw formula='k1*X0'>"
    "    <notes>This is a test note.</notes>"
    "    <listOfParameters>"
    "      <parameter name='k1' value='0'/>"
    "    </listOfParameters>"
    "  </kineticLaw>"
    "</reaction>"
    "</listOfReactions>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  r  = Model_getReaction(M, 0);
  kl = Reaction_getKineticLaw(r);

  fail_unless( SBase_getNotes(kl) != NULL );

  const char * notes = XMLNode_getCharacters(XMLNode_getChild(SBase_getNotes(kl), 0));
  fail_unless( strcmp(notes, "This is a test note.") == 0 );
}
END_TEST




START_TEST (test_ReadSBML_notes_xmlns)
{
  const char* s = wrapSBML_L2v3
  (
    "<notes>"
    "  <body xmlns=\"http://www.w3.org/1999/xhtml\">Some text.</body>"
    "</notes>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( SBase_getNotes(M) != NULL );

  const XMLNamespaces_t * ns = XMLNode_getNamespaces(XMLNode_getChild(SBase_getNotes(M), 0));

  fail_unless(XMLNamespaces_getLength(ns) == 1);
  fail_unless(!strcmp(XMLNamespaces_getURI(ns, 0), "http://www.w3.org/1999/xhtml"));

  const char * notes = XMLNode_getCharacters(XMLNode_getChild(XMLNode_getChild(SBase_getNotes(M), 0), 0));
  fail_unless( strcmp(notes, "Some text.") == 0 );
}
END_TEST


START_TEST (test_ReadSBML_notes_sbml)
{
  const char* s = wrapXML
  (
    "<sbml level='1' version='1'>"
    "  <notes>Notes are not allowed as part of the SBML element.</notes>"
    "</sbml>"
  );


  D = readSBMLFromString(s);

  fail_unless( SBase_getNotes(D) != NULL );

  const char * notes = XMLNode_getCharacters(XMLNode_getChild(SBase_getNotes(D), 0));
  fail_unless( strcmp(notes, "Notes are not allowed as part of the SBML element.") == 0 );

  fail_unless( SBMLDocument_getNumErrors(D) > 0 );
}
END_TEST


START_TEST (test_ReadSBML_notes_sbml_L2)
{
  const char* s = wrapXML
  (
  "<sbml xmlns=\"http://www.sbml.org/sbml/level2\" level=\"2\" version=\"1\"> "
  "  <notes>"
  "    <html xmlns=\"http://www.w3.org/1999/xhtml\">"
  "		 </html>"
  "	  </notes>"
  "	  <model>"
  "   </model>"
  " </sbml>"
  );


  D = readSBMLFromString(s);
  fail_unless( SBase_getNotes(D) != NULL );

  fail_unless( SBMLDocument_getNumErrors(D) == 0 );
}
END_TEST


START_TEST (test_ReadSBML_notes_ListOf)
{
  SBase_t*  sb;

  const char* s = wrapSBML_L2v1
  (
    "<listOfFunctionDefinitions>"
    "  <notes>My Functions</notes>"
    "  <functionDefinition/>"
    "</listOfFunctionDefinitions>"

    "<listOfUnitDefinitions>"
    "  <notes>My Units</notes>"
    "  <unitDefinition/>"
    "</listOfUnitDefinitions>"

    "<listOfCompartments>"
    "  <notes>My Compartments</notes>"
    "  <compartment/>"
    "</listOfCompartments>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( M != NULL );

  sb = (SBase_t *) Model_getListOfFunctionDefinitions(M);

  fail_unless( SBase_isSetNotes(sb) );
  const char * notes = XMLNode_getCharacters(XMLNode_getChild(SBase_getNotes(sb), 0));
  fail_unless( strcmp(notes, "My Functions") == 0 );


  sb = (SBase_t *) Model_getListOfUnitDefinitions(M);

  fail_unless( SBase_isSetNotes(sb) );
  notes = XMLNode_getCharacters(XMLNode_getChild(SBase_getNotes(sb), 0));
  fail_unless( strcmp(notes, "My Units") == 0 );


  sb = (SBase_t *) Model_getListOfCompartments(M);

  fail_unless( SBase_isSetNotes(sb) );
  notes = XMLNode_getCharacters(XMLNode_getChild(SBase_getNotes(sb), 0));
  fail_unless( strcmp(notes, "My Compartments") == 0 );


}
END_TEST


START_TEST (test_ReadSBML_annotation)
{
  const char* s = wrapSBML_L2v3
  (
    "<annotation xmlns:mysim=\"http://www.mysim.org/ns\">"
    "  <mysim:nodecolors mysim:bgcolor=\"green\" mysim:fgcolor=\"white\">"
    "  </mysim:nodecolors>"
    "  <mysim:timestamp>2000-12-18 18:31 PST</mysim:timestamp>"
    "</annotation>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( SBase_getAnnotation(M) != NULL );
  XMLNode_t * ann = SBase_getAnnotation(M);

  fail_unless(XMLNode_getNumChildren(ann) == 2);

}
END_TEST


START_TEST (test_ReadSBML_annotation_sbml)
{
  const char* s = wrapXML
  (
    "<sbml level=\"1\" version=\"1\">"
    "  <annotation xmlns:jd = \"http://www.sys-bio.org/sbml\">"
    "    <jd:header>"
    "      <VersionHeader SBMLVersion = \"1.0\"/>"
    "    </jd:header>"
    "    <jd:display>"
    "      <SBMLGraphicsHeader BackGroundColor = \"15728639\"/>"
    "    </jd:display>"
    "  </annotation>"
    "</sbml>"
  );


  D = readSBMLFromString(s);

  fail_unless( SBMLDocument_getNumErrors(D) > 0 );
}
END_TEST


START_TEST (test_ReadSBML_annotation_sbml_L2)
{
  const char* s = wrapXML
  (
  "<sbml xmlns=\"http://www.sbml.org/sbml/level2\" level=\"2\" version=\"1\"> "
  "  <annotation>"
  "    <rdf xmlns=\"http://www.w3.org/1999/anything\">"
  "		 </rdf>"
  "	  </annotation>"
  "	  <model>"
  "   </model>"
  " </sbml>"
  );


  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( SBMLDocument_getNumErrors(D) == 0 );
}
END_TEST


START_TEST (test_ReadSBML_line_col_numbers)
{
  SBase_t*  sb;

  const char* s =
    "<?xml version='1.0' encoding='UTF-8'?>\n"
    "<sbml xmlns='http://www.sbml.org/sbml/level2' level='2' version='1'>\n"
    "  <model id='testModel' name='testModel'>\n"
    "    <listOfReactions> <reaction/> </listOfReactions>\n"
    "  </model>\n"
    "</sbml>\n";
/*
              1         2         3         4         5         6 
     123456789012345678901234567890123456789012345678901234567890 
*/

  D = readSBMLFromString(s);
  M = SBMLDocument_getModel(D);

  fail_unless( M != NULL );

  /**
   * Xerces-C++ and Expat report line and column numbers differently.
   *
   * Expat reports the line and column numbers at the start of a token
   * (like every other parser program in the world) while Xerces reports
   * the end of a token (!?).
   *
   * I thought turning source offset calculation on would fix this, e.g.:
   *
   *   XMLReader.setFeature( XMLUni::fgXercesCalculateSrcOfs, true );
   *
   * but it has no effect.  Perhaps I misunderstood its meaning. :(
   */

  sb = (SBase_t *) M;

#ifdef USE_EXPAT
  fail_unless ( SBase_getLine  (sb) == 3 );
  fail_unless ( SBase_getColumn(sb) == 2 );
#endif
#ifdef USE_LIBXML
  fail_unless ( SBase_getLine  (sb) == 3 );
  /*  fail_unless ( SBase_getColumn(sb) == 2 ); */
#endif
#ifdef USE_XERCES
  fail_unless ( SBase_getLine  (sb) ==  3 );
  fail_unless ( SBase_getColumn(sb) == 42 );
#endif


  sb = (SBase_t *) Model_getListOfReactions(M);

#ifdef USE_EXPAT
  fail_unless ( SBase_getLine  (sb) == 4 );
  fail_unless ( SBase_getColumn(sb) == 4 );
#endif
#ifdef USE_LIBXML
  fail_unless ( SBase_getLine  (sb) == 4 );
  /*  fail_unless ( SBase_getColumn(sb) == 4 ); */
#endif
#ifdef USE_XERCES
  fail_unless ( SBase_getLine  (sb) ==  4 );
  fail_unless ( SBase_getColumn(sb) == 22 );
#endif


  sb = (SBase_t *) Model_getReaction(M, 0);

#ifdef USE_EXPAT
  fail_unless ( SBase_getLine  (sb) == 4 );
  fail_unless ( SBase_getColumn(sb) == 22 );
#endif
#ifdef USE_LIBXML
  fail_unless ( SBase_getLine  (sb) == 4 );
  /*  fail_unless ( SBase_getColumn(sb) == 22 ); */
#endif
#ifdef USE_XERCES
  fail_unless ( SBase_getLine  (sb) ==  4 );
  fail_unless ( SBase_getColumn(sb) == 34 );
#endif

  /* NULL test */
  sb = NULL;
#ifdef USE_EXPAT
  fail_unless ( SBase_getLine  (sb) == 0 );
  fail_unless ( SBase_getColumn(sb) == 0 );
#endif
#ifdef USE_LIBXML
  fail_unless ( SBase_getLine  (sb) == 0 );
  fail_unless ( SBase_getColumn(sb) == 0 ); 
#endif
#ifdef USE_XERCES
  fail_unless ( SBase_getLine  (sb) ==  0 );
  fail_unless ( SBase_getColumn(sb) == 0 );
#endif
}
END_TEST


START_TEST (test_ReadSBML_invalid_default_namespace )
{
  const char* valid = wrapXML
  (
  "<sbml xmlns=\"http://www.sbml.org/sbml/level2/version4\" level=\"2\" version=\"4\"> "
  "   <model>"
  "     <notes>"
  "       <p xmlns=\"http://www.w3.org/1999/xhtml\">Some text.</p>"
  "     </notes>"
  "     <annotation>"
  "       <example xmlns=\"http://www.example.org/\"/>"
  "     </annotation>"
  "     <listOfCompartments>"
  "       <compartment id=\"compartmentOne\" size=\"1\"/>"
  "     </listOfCompartments>"
  "     <listOfSpecies>"
  "       <species id=\"S1\" initialConcentration=\"1\" compartment=\"compartmentOne\"/>"
  "       <species id=\"S2\" initialConcentration=\"0\" compartment=\"compartmentOne\"/>"
  "     </listOfSpecies>"
  "     <listOfParameters>"
  "       <parameter id=\"t\" value = \"1\" units=\"second\"/>"
  "     </listOfParameters>"
  "     <listOfConstraints>"
  "       <constraint sboTerm=\"SBO:0000064\">"
  "         <math xmlns=\"http://www.w3.org/1998/Math/MathML\">"
  "           <apply>"
  "             <leq/>"
  "             <ci> S1 </ci>"
  "             <ci> t </ci>"
  "           </apply>"
  "         </math>"
  "         <message>"
  "           <p xmlns=\"http://www.w3.org/1999/xhtml\"> Species S1 is out of range </p>"
  "         </message>"
  "       </constraint>"
  "     </listOfConstraints>"
  "     <listOfReactions>"
  "       <reaction id=\"reaction_1\" reversible=\"false\">"
  "           <listOfReactants>"
  "             <speciesReference species=\"S1\"/>"
  "           </listOfReactants>"
  "           <listOfProducts>"
  "             <speciesReference species=\"S2\">"
  "             </speciesReference>"
  "           </listOfProducts>"
  "       </reaction>"
  "     </listOfReactions>"
  "   </model>"
  " </sbml>"
  );

  const char* invalid = wrapXML
  (
  "<sbml xmlns=\"http://www.sbml.org/sbml/level2/version4\" level=\"2\" version=\"4\"> "
  "   <model xmlns=\"http://invalid/custom/default/uri\">"
  "     <notes xmlns=\"http://invalid/custom/default/uri/in/notes\">"
  "       <p xmlns=\"http://www.w3.org/1999/xhtml\">Some text.</p>"
  "     </notes>"
  "     <annotation xmlns=\"http://invalid/custom/default/uri/in/annotation\">"
  "       <example xmlns=\"http://www.example.org/\"/>"
  "     </annotation>"
  "     <listOfCompartments>"
  "       <compartment id=\"compartmentOne\" size=\"1\"/>"
  "     </listOfCompartments>"
  "     <listOfSpecies>"
  "       <notes xmlns=\"http://invalid/custom/default/uri/in/notes\">"
  "         <p xmlns=\"http://www.w3.org/1999/xhtml\">Some text.</p>"
  "       </notes>"
  "       <annotation xmlns=\"http://invalid/custom/default/uri/in/annotation\">"
  "         <example xmlns=\"http://www.example.org/\"/>"
  "       </annotation>"
  "       <species id=\"S1\" initialConcentration=\"1\" compartment=\"compartmentOne\"/>"
  "       <species id=\"S2\" initialConcentration=\"0\" compartment=\"compartmentOne\"/>"
  "     </listOfSpecies>"
  "     <listOfParameters>"
  "       <parameter id=\"t\" value = \"1\" units=\"second\"/>"
  "     </listOfParameters>"
  "     <listOfConstraints>"
  "       <constraint sboTerm=\"SBO:0000064\">"
  "         <math xmlns=\"http://www.w3.org/1998/Math/MathML\">"
  "           <apply>"
  "             <leq/>"
  "             <ci> S1 </ci>"
  "             <ci> t </ci>"
  "           </apply>"
  "         </math>"
  "         <message xmlns=\"http://invalid/custom/default/uri/in/message\">"
  "           <p xmlns=\"http://www.w3.org/1999/xhtml\"> Species S1 is out of range </p>"
  "         </message>"
  "       </constraint>"
  "     </listOfConstraints>"
  "     <listOfReactions>"
  "       <reaction id=\"reaction_1\" reversible=\"false\">"
  "           <listOfReactants>"
  "             <speciesReference xmlns=\"http://invalid/custom/default/uri\" species=\"S1\"/>"
  "           </listOfReactants>"
  "           <listOfProducts>"
  "             <speciesReference species=\"S2\">"
  "               <notes xmlns=\"http://invalid/custom/default/uri/in/notes\">"
  "                 <p xmlns=\"http://www.w3.org/1999/xhtml\">Some text.</p>"
  "               </notes>"
  "               <annotation xmlns=\"http://invalid/custom/default/uri/in/annotation\">"
  "                 <example xmlns=\"http://www.example.org/\"/>"
  "               </annotation>"
  "             </speciesReference>"
  "           </listOfProducts>"
  "       </reaction>"
  "     </listOfReactions>"
  "   </model>"
  " </sbml>"
  );

  D = readSBMLFromString(valid);
  fail_unless( SBMLDocument_getNumErrors(D) == 0 );

  SBMLDocument_free(D);

  D = readSBMLFromString(invalid);
  fail_unless( SBMLDocument_getNumErrors(D) == 9 );
}
END_TEST


Suite *
create_suite_ReadSBML (void)
{
  Suite *suite = suite_create("ReadSBML");
  TCase *tcase = tcase_create("ReadSBML");


  tcase_add_checked_fixture(tcase, ReadSBML_setup, ReadSBML_teardown);

  tcase_add_test( tcase, test_ReadSBML_SBML      );
  tcase_add_test( tcase, test_ReadSBML_SBML_ONLY );
  tcase_add_test( tcase, test_ReadSBML_Model     );
  tcase_add_test( tcase, test_ReadSBML_Model_withoutEncoding);
  tcase_add_test( tcase, test_ReadSBML_Model_L2  );
  tcase_add_test( tcase, test_ReadSBML_prefix  );

  tcase_add_test( tcase, test_ReadSBML_FunctionDefinition  );
  tcase_add_test( tcase, test_ReadSBML_FunctionDefinition_MathReturnsCN  );
  tcase_add_test( tcase, test_ReadSBML_FunctionDefinition_OnlyBVars  );

  tcase_add_test( tcase, test_ReadSBML_UnitDefinition      );
  tcase_add_test( tcase, test_ReadSBML_UnitDefinition_L2   );
  tcase_add_test( tcase, test_ReadSBML_Unit                );
  tcase_add_test( tcase, test_ReadSBML_Unit_L2             );
  tcase_add_test( tcase, test_ReadSBML_Unit_defaults_L1_L2 );

  tcase_add_test( tcase, test_ReadSBML_Compartment             );
  tcase_add_test( tcase, test_ReadSBML_Compartment_L2          );
  tcase_add_test( tcase, test_ReadSBML_Compartment_defaults    );
  tcase_add_test( tcase, test_ReadSBML_Compartment_defaults_L2 );

  tcase_add_test( tcase, test_ReadSBML_Specie              );
  tcase_add_test( tcase, test_ReadSBML_Specie_defaults     );
  tcase_add_test( tcase, test_ReadSBML_Species             );
  tcase_add_test( tcase, test_ReadSBML_Species_L2_1        );
  tcase_add_test( tcase, test_ReadSBML_Species_L2_2        );
  tcase_add_test( tcase, test_ReadSBML_Species_L2_defaults );

  tcase_add_test( tcase, test_ReadSBML_Parameter             );
  tcase_add_test( tcase, test_ReadSBML_Parameter_L2          );
  tcase_add_test( tcase, test_ReadSBML_Parameter_L2_defaults );

  tcase_add_test( tcase, test_ReadSBML_Reaction             );
  tcase_add_test( tcase, test_ReadSBML_Reaction_defaults    );
  tcase_add_test( tcase, test_ReadSBML_Reaction_L2          );
  tcase_add_test( tcase, test_ReadSBML_Reaction_L2_defaults );

  tcase_add_test( tcase, test_ReadSBML_SpecieReference_Reactant             );
  tcase_add_test( tcase, test_ReadSBML_SpecieReference_Product              );
  tcase_add_test( tcase, test_ReadSBML_SpecieReference_defaults             );
  tcase_add_test( tcase, test_ReadSBML_SpeciesReference_defaults            );
  tcase_add_test( tcase, test_ReadSBML_SpeciesReference_StoichiometryMath_1 );
  tcase_add_test( tcase, test_ReadSBML_SpeciesReference_StoichiometryMath_2 );

  tcase_add_test( tcase, test_ReadSBML_KineticLaw           );
  tcase_add_test( tcase, test_ReadSBML_KineticLaw_L2        );
  tcase_add_test( tcase, test_ReadSBML_KineticLaw_Parameter );

  tcase_add_test( tcase, test_ReadSBML_AssignmentRule   );
  tcase_add_test( tcase, test_ReadSBML_RateRule         );
  tcase_add_test( tcase, test_ReadSBML_AlgebraicRule    );
  tcase_add_test( tcase, test_ReadSBML_AlgebraicRule_L2 );

  tcase_add_test( tcase, test_ReadSBML_CompartmentVolumeRule        );
  tcase_add_test( tcase, test_ReadSBML_ParameterRule                );
  tcase_add_test( tcase, test_ReadSBML_SpecieConcentrationRule      );
  tcase_add_test( tcase, test_ReadSBML_SpecieConcentrationRule_rate );
  tcase_add_test( tcase, test_ReadSBML_SpeciesConcentrationRule     );

  tcase_add_test( tcase, test_ReadSBML_Event           );
  tcase_add_test( tcase, test_ReadSBML_Event_trigger   );
  tcase_add_test( tcase, test_ReadSBML_Event_delay     );
  tcase_add_test( tcase, test_ReadSBML_EventAssignment );

  tcase_add_test( tcase, test_ReadSBML_metaid          );
  tcase_add_test( tcase, test_ReadSBML_metaid_Unit     );
  tcase_add_test( tcase, test_ReadSBML_metaid_Reaction );  
  tcase_add_test( tcase, test_ReadSBML_metaid_Event    );
  tcase_add_test( tcase, test_ReadSBML_metaid_ListOf   );

  tcase_add_test( tcase, test_ReadSBML_notes                         );
  tcase_add_test( tcase, test_ReadSBML_notes_xmlns                   );
  tcase_add_test( tcase, test_ReadSBML_notes_sbml                    );
  tcase_add_test( tcase, test_ReadSBML_notes_sbml_L2                 );
  tcase_add_test( tcase, test_ReadSBML_notes_ListOf                  );

  tcase_add_test( tcase, test_ReadSBML_annotation         );
  tcase_add_test( tcase, test_ReadSBML_annotation_sbml    );
  tcase_add_test( tcase, test_ReadSBML_annotation_sbml_L2 );
  
  tcase_add_test( tcase, test_ReadSBML_line_col_numbers );

  tcase_add_test( tcase, test_ReadSBML_invalid_default_namespace );
  
  suite_add_tcase(suite, tcase);

  return suite;
}


CK_CPPEND

