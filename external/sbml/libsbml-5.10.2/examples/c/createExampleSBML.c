/**
 * @file    createExampleSBML.cpp
 * @brief   Creates example SBML models presented in the SBML specification.
 * @author  Akiya Jouraku
 * @author  Michael Hucka
 * @author  Sarah Keating
 * @author  Frank Bergmann
 *
 * <!--------------------------------------------------------------------------
 * This sample program is distributed under a different license than the rest
 * of libSBML.  This program uses the open-source MIT license, as follows:
 *
 * Copyright (c) 2013-2014 by the California Institute of Technology
 * (California, USA), the European Bioinformatics Institute (EMBL-EBI, UK)
 * and the University of Heidelberg (Germany), with support from the National
 * Institutes of Health (USA) under grant R01GM070923.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Neither the name of the California Institute of Technology (Caltech), nor
 * of the European Bioinformatics Institute (EMBL-EBI), nor of the University
 * of Heidelberg, nor the names of any contributors, may be used to endorse
 * or promote products derived from this software without specific prior
 * written permission.
 * ------------------------------------------------------------------------ -->
 */

#include <stdio.h>
#include <sbml/SBMLTypes.h>
#include <sbml/xml/XMLTriple.h>
/*
 * Functions for creating the Example SBML documents.
 */
SBMLDocument_t* createExampleEnzymaticReaction();            /* 7.1 */
SBMLDocument_t* createExampleInvolvingUnits();               /* 7.2 */
SBMLDocument_t* createExampleInvolvingFunctionDefinitions(); /* 7.8 */

/*
 * Helper functions for validating and writing the SBML documents created.
 */
int validateExampleSBML(SBMLDocument_t *sbmlDoc);
int writeExampleSBML(SBMLDocument_t *sbmlDoc, const char* filename);

/*
 * These variables are used in writeExampleSBML when writing an SBML
 * document.  They are handed to libSBML functions in order to include
 * the program information into comments within the SBML file.
 */
const char* ProgramName    = "createExampleModels";
const char* ProgramVersion = "1.0.0";

/*
 * The SBML Level and Version of the example SBML models.
 */
const unsigned int Level   = 2;
const unsigned int Version = 4;


/*===============================================================================
 *
 * Main routine
 *
 *  Creates SBML models represented in "Example models expressed in XML using
 *  SBML" in Section 7 of the SBML Level 2 Version 4 specification(*). 
 *
 *   (*) The specification document is available at the following URL:
 *       http://sbml.org/Documents/Specifications
 *
 *===============================================================================*/
int
main (int argc, char *argv[])
{
  SBMLDocument_t* sbmlDoc = NULL;
  int SBMLok           = 0;

  /*-------------------------------------------------
   * 7.1 A Simple example application of SBML
   *-------------------------------------------------*/
  
  sbmlDoc = createExampleEnzymaticReaction(); 
  SBMLok  = validateExampleSBML(sbmlDoc);
  if (SBMLok == 1) writeExampleSBML(sbmlDoc, "enzymaticreaction.xml");
  SBMLDocument_free(sbmlDoc);
  if (SBMLok == 0) return 1;
  
  /*-------------------------------------------------
   * 7.2 Example involving units
   *-------------------------------------------------*/
  
  sbmlDoc = createExampleInvolvingUnits(); 
  SBMLok  = validateExampleSBML(sbmlDoc);
  if (SBMLok == 1) writeExampleSBML(sbmlDoc, "units.xml");
  SBMLDocument_free(sbmlDoc);
  if (SBMLok == 0) return 1;
  
  /*-------------------------------------------------
   * 7.8 Example involving function definitions
   *-------------------------------------------------*/
  
  sbmlDoc = createExampleInvolvingFunctionDefinitions(); 
  SBMLok  = validateExampleSBML(sbmlDoc);
  if (SBMLok == 1) writeExampleSBML(sbmlDoc, "functiondef.xml");
  SBMLDocument_free(sbmlDoc);
  if (SBMLok == 0) return 1;
  
  
  /* A 0 return status is the standard Unix/Linux way to say "all ok". */
  return 0;

}


 /*===============================================================================
 *
 *
 * Functions for creating the Example SBML documents.
 *
 *
 *===============================================================================*/


/**
 *
 * Creates an SBML model represented in "7.1 A Simple example application of SBML"
 * in the SBML Level 2 Version 4 Specification.
 *
 */
SBMLDocument_t* createExampleEnzymaticReaction()
{
  const unsigned int level   = Level;
  const unsigned int version = Version;

  /* 
   * Variables
   */
  SBMLDocument_t* sbmlDoc;
  Model_t* model;

  /* Temporary pointers (reused more than once below). */

  UnitDefinition_t* unitdef;
  Unit_t* unit;
  Compartment_t* comp;
  
  const char* compName = "cytosol";
  char* mathXMLString;

  Species_t *sp;
  Reaction_t* reaction;
  SpeciesReference_t* spr;
  KineticLaw_t* kl;
  Parameter_t* para;

  ASTNode_t* astCytosol;
  ASTNode_t* astKon;
  ASTNode_t* astKoff;
  ASTNode_t* astE;
  ASTNode_t* astS;
  ASTNode_t* astES;
  ASTNode_t* astTimes1;
   
  ASTNode_t* astTimes2;
  ASTNode_t* astTimes;
  ASTNode_t* astMinus;
  ASTNode_t* astMath;   

  /*---------------------------------------------------------------------------
   *
   * Creates an SBMLDocument object 
   *
   *---------------------------------------------------------------------------*/

  sbmlDoc = SBMLDocument_createWithLevelAndVersion(level,version);  

  /*---------------------------------------------------------------------------
   *
   * Creates a Model object inside the SBMLDocument object. 
   *
   *---------------------------------------------------------------------------*/

  model = SBMLDocument_createModel(sbmlDoc);
  Model_setId(model, "EnzymaticReaction");

  /*---------------------------------------------------------------------------
   *
   * Creates UnitDefinition objects inside the Model object.
   *
   *---------------------------------------------------------------------------*/

  
  /*---------------------------------------------------------------------------  
   * (UnitDefinition1) Creates an UnitDefinition object ("per_second")
   *---------------------------------------------------------------------------*/

  unitdef = Model_createUnitDefinition(model);
  UnitDefinition_setId(unitdef, "per_second");

  /*  Creates an Unit inside the UnitDefinition object */

  unit = UnitDefinition_createUnit(unitdef);
  Unit_setKind(unit, UNIT_KIND_SECOND);
  Unit_setExponent(unit,-1);

  /*--------------------------------------------------------------------------------
   * (UnitDefinition2) Creates an UnitDefinition object ("litre_per_mole_per_second") 
   *--------------------------------------------------------------------------------*/
    
  /* Note that we can reuse the pointers 'unitdef' and 'unit' because the
   * actual UnitDefinition object (along with the Unit objects within it)
   * is already attached to the Model object.*/

  unitdef = Model_createUnitDefinition(model);
  UnitDefinition_setId(unitdef,"litre_per_mole_per_second");
    
  /*  Creates an Unit inside the UnitDefinition object ("litre_per_mole_per_second") */

  unit = UnitDefinition_createUnit(unitdef);
  Unit_setKind(unit,UNIT_KIND_MOLE);
  Unit_setExponent(unit,-1);

  /*  Creates an Unit inside the UnitDefinition object ("litre_per_mole_per_second") */

  unit = UnitDefinition_createUnit(unitdef);
  Unit_setKind(unit,UNIT_KIND_LITRE);
  Unit_setExponent(unit,1);

  /*  Creates an Unit inside the UnitDefinition object ("litre_per_mole_per_second") */

  unit = UnitDefinition_createUnit(unitdef);
  Unit_setKind(unit,UNIT_KIND_SECOND);
  Unit_setExponent(unit,-1);


  /*---------------------------------------------------------------------------
   *
   * Creates a Compartment object inside the Model object. 
   *
   *---------------------------------------------------------------------------*/

  /* Creates a Compartment object ("cytosol")*/

  comp = Model_createCompartment(model);
  Compartment_setId(comp,compName);
 
  /* Sets the "size" attribute of the Compartment object.
   *
   * We are not setting the units on the compartment size explicitly, so
   * the units of this Compartment object will be the default SBML units of
   * volume, which are liters.
   */
  Compartment_setSize(comp,1e-14);


  /*---------------------------------------------------------------------------
   *
   * Creates Species objects inside the Model object. 
   *
   *---------------------------------------------------------------------------*/
  
  

  /*---------------------------------------------------------------------------
   * (Species1) Creates a Species object ("ES")
   *---------------------------------------------------------------------------

   * Create the Species objects inside the Model object. */

  sp = Model_createSpecies(model);  
  Species_setId(sp,"ES");
  Species_setName(sp,"ES");

  /* Sets the "compartment" attribute of the Species object to identify the 
   * compartment in which the Species object is located.*/

  Species_setCompartment(sp,compName);

  /* Sets the "initialAmount" attribute of the Species object.
   *
   *  In SBML, the units of a Species object's initial quantity are
   *  determined by two attributes, "substanceUnits" and
   *  "hasOnlySubstanceUnits", and the "spatialDimensions" attribute
   *  of the Compartment object ("cytosol") in which the species
   *  object is located.  Here, we are using the default values for
   *  "substanceUnits" (which is "mole") and "hasOnlySubstanceUnits"
   *  (which is "false").  The compartment in which the species is
   *  located uses volume units of liters, so the units of these
   *  species (when the species appear in numerical formulas in the
   *  model) will be moles/liters.  
   */
  Species_setInitialAmount(sp,0);

  /*---------------------------------------------------------------------------
   * (Species2) Creates a Species object ("P")
   *---------------------------------------------------------------------------*/
   
  sp = Model_createSpecies(model);
  Species_setCompartment(sp,compName);
  Species_setId(sp,"P");
  Species_setName(sp,"P");
  Species_setInitialAmount(sp,0);

  /*---------------------------------------------------------------------------
   * (Species3) Creates a Species object ("S")
   *---------------------------------------------------------------------------*/

  sp = Model_createSpecies(model);
  Species_setCompartment(sp,compName);
  Species_setId(sp,"S");
  Species_setName(sp,"S");
  Species_setInitialAmount(sp,1e-20);

  /*---------------------------------------------------------------------------
   * (Species4) Creates a Species object ("E")
   *---------------------------------------------------------------------------*/

  sp = Model_createSpecies(model);
  Species_setCompartment(sp,compName);
  Species_setId(sp,"E");
  Species_setName(sp,"E");
  Species_setInitialAmount(sp,5e-21);

  
  /*---------------------------------------------------------------------------
   *
   * Creates Reaction objects inside the Model object. 
   *
   *---------------------------------------------------------------------------*/

  /*---------------------------------------------------------------------------
   * (Reaction1) Creates a Reaction object ("veq").
   *---------------------------------------------------------------------------*/

  reaction = Model_createReaction(model);
  Reaction_setId(reaction,"veq");

  /* (Reactant1) Creates a Reactant object that references Species "E"
   * in the model.  The object will be created within the reaction in the
   * SBML <listOfReactants>.*/

  spr = Reaction_createReactant(reaction);
  SpeciesReference_setSpecies(spr,"E");

  /* (Reactant2) Creates a Reactant object that references Species "S"
   * in the model.*/

  spr = Reaction_createReactant(reaction);
  SpeciesReference_setSpecies(spr,"S");

  /*---------------------------------------------------------------------------
   * (Product1) Creates a Product object that references Species "ES" in
   * the model.
   *---------------------------------------------------------------------------*/

  spr = Reaction_createProduct(reaction);
  SpeciesReference_setSpecies(spr, "ES");

  /*---------------------------------------------------------------------------
   * Creates a KineticLaw object inside the Reaction object ("veq"). 
   *---------------------------------------------------------------------------*/

  kl = Reaction_createKineticLaw(reaction);

  /*---------------------------------------------------------------------------
    * Creates an ASTNode object which represents the following math of the
    * KineticLaw.
    *
    *      <math xmlns="http://www.w3.org/1998/Math/MathML">
    *        <apply>
    *          <times/>
    *          <ci> cytosol </ci>
    *          <apply>
    *            <minus/>
    *            <apply>
    *              <times/>
    *              <ci> kon </ci>
    *              <ci> E </ci>
    *              <ci> S </ci>
    *            </apply>
    *            <apply>
    *              <times/>
    *              <ci> koff </ci>
    *              <ci> ES </ci>
    *            </apply>
    *          </apply>
    *        </apply>
    *      </math>
    *
  *---------------------------------------------------------------------------*/

   /*------------------------------------------
    *
    * create nodes representing the variables
    *
    *------------------------------------------*/

   
  astCytosol = ASTNode_createWithType(AST_NAME);
  ASTNode_setName(astCytosol, "cytosol");

  astKon = ASTNode_createWithType(AST_NAME);
  ASTNode_setName(astKon, "kon");

  astKoff = ASTNode_createWithType(AST_NAME);
  ASTNode_setName( astKoff, "koff");

  astE = ASTNode_createWithType(AST_NAME);
  ASTNode_setName(astE, "E");

  astS = ASTNode_createWithType(AST_NAME);
  ASTNode_setName(astS, "S");

  astES = ASTNode_createWithType(AST_NAME);
  ASTNode_setName(astES, "ES");


   /*--------------------------------------------
    *
    * create node representing
    *            <apply>
    *              <times/>
    *              <ci> koff </ci>
    *              <ci> ES </ci>
    *            </apply>
    *
    *--------------------------------------------*/

  astTimes1 = ASTNode_createWithType(AST_TIMES);
  ASTNode_addChild( astTimes1, astKoff);
  ASTNode_addChild( astTimes1, astES);

   /*--------------------------------------------
    *
    * create node representing
    *            <apply>
    *              <times/>
    *              <ci> kon </ci>
    *              <ci> E </ci>
    *              <ci> S </ci>
    *            </apply>
    *
    *
    * (NOTES)
    *
    *  Since there is a restriction with an ASTNode of "<times/>" operation
    *  such that the ASTNode is a binary class and thus only two operands can
    *  be directly added, the following code in this comment block is invalid
    *  because the code directly adds three <ci> ASTNodes to <times/> ASTNode.
    *
    *    ASTNode *astTimes = new ASTNode(AST_TIMES);
    *    astTimes->addChild(astKon);
    *    astTimes->addChild(astE);
    *    astTimes->addChild(astS);
    *
    * The following valid code after this comment block creates the ASTNode
    * as a binary tree.
    *
    * Please see "Converting between ASTs and text strings" described
    * at http://sbml.org/Software/libSBML/docs/cpp-api/class_a_s_t_node.html
    * for the detailed information.
    *
    *--------------------------------------------*/

   
  astTimes2 = ASTNode_createWithType(AST_TIMES);
  ASTNode_addChild( astTimes2, astE);
  ASTNode_addChild( astTimes2, astS);

  astTimes = ASTNode_createWithType(AST_TIMES);
  ASTNode_addChild( astTimes, astKon);
  ASTNode_addChild( astTimes, astTimes2);

   /*--------------------------------------------
    *
    * create node representing
    *          <apply>
    *            <minus/>
    *            <apply>
    *              <times/>
    *              <ci> kon </ci>
    *              <ci> E </ci>
    *              <ci> S </ci>
    *            </apply>
    *            <apply>
    *              <times/>
    *              <ci> koff </ci>
    *              <ci> ES </ci>
    *            </apply>
    *          </apply>
    *
    *--------------------------------------------*/
   
  astMinus = ASTNode_createWithType(AST_MINUS);
  ASTNode_addChild( astMinus, astTimes);
  ASTNode_addChild( astMinus, astTimes1);


   /*--------------------------------------------
    *
    * create node representing
    *        <apply>
    *          <times/>
    *          <ci> cytosol </ci>
    *          <apply>
    *            <minus/>
    *            <apply>
    *              <times/>
    *              <ci> kon </ci>
    *              <ci> E </ci>
    *              <ci> S </ci>
    *            </apply>
    *            <apply>
    *              <times/>
    *              <ci> koff </ci>
    *              <ci> ES </ci>
    *            </apply>
    *          </apply>
    *        </apply>
    *
    *--------------------------------------------*/

  astMath = ASTNode_createWithType(AST_TIMES);
  ASTNode_addChild( astMath, astCytosol);
  ASTNode_addChild( astMath, astMinus);

   /*---------------------------------------------
    *
    * set the Math element
    *
    *------------------------------------------------*/

  KineticLaw_setMath( kl, astMath);

  /* KineticLaw::setMath(const ASTNode*) sets the math of the KineticLaw object
   * to a copy of the given ASTNode, and thus basically the caller should delete 
   * the original ASTNode object if the caller has the ownership of the object to 
   * avoid memory leak.*/

  ASTNode_free(astMath);

  /*---------------------------------------------------------------------------
   * Creates local Parameter objects inside the KineticLaw object.
   *---------------------------------------------------------------------------*/

  /* Creates a Parameter ("kon")*/

  
  para = KineticLaw_createParameter( kl );
  Parameter_setId(para, "kon");
  Parameter_setValue( para, 1000000);
  Parameter_setUnits( para, "litre_per_mole_per_second");

  /* Creates a Parameter ("koff")*/

  para = KineticLaw_createParameter( kl );
  Parameter_setId( para, "koff");
  Parameter_setValue( para, 0.2);
  Parameter_setUnits( para, "per_second");


  /*---------------------------------------------------------------------------
   * (Reaction2) Creates a Reaction object ("vcat") .
   *---------------------------------------------------------------------------*/
  
  reaction = Model_createReaction(model);
  Reaction_setId(reaction, "vcat");
  Reaction_setReversible(reaction, 0);

  /*---------------------------------------------------------------------------
   * Creates Reactant objects inside the Reaction object ("vcat"). 
   *---------------------------------------------------------------------------

   * (Reactant1) Creates a Reactant object that references Species "ES" in the
   * model.*/

  spr = Reaction_createReactant(reaction);
  SpeciesReference_setSpecies(spr, "ES");

  /*---------------------------------------------------------------------------
   * Creates a Product object inside the Reaction object ("vcat"). 
   *---------------------------------------------------------------------------
  
   * (Product1) Creates a Product object that references Species "E" in the model.*/

  spr = Reaction_createProduct(reaction);
  SpeciesReference_setSpecies(spr,"E");

  /* (Product2) Creates a Product object that references Species "P" in the model.*/

  spr = Reaction_createProduct(reaction);
  SpeciesReference_setSpecies(spr,"P");

  /*---------------------------------------------------------------------------
   * Creates a KineticLaw object inside the Reaction object ("vcat"). 
   *---------------------------------------------------------------------------*/
  
  kl = Reaction_createKineticLaw(reaction);

  /*---------------------------------------------------------------------------
   * Sets a math (ASTNode object) to the KineticLaw object.
   *---------------------------------------------------------------------------*/

  /* To create mathematical expressions, one would typically construct
   * an ASTNode tree as the above example code which creates a math of another
   * KineticLaw object.  Here, to save some space and illustrate another approach 
   * of doing it, we will write out the formula in MathML form and then use a 
   * libSBML convenience function to create the ASTNode tree for us.  
   * (This is a bit dangerous; it's very easy to make mistakes when writing MathML 
   * by hand, so in a real program, we would not really want to do it this way.)*/

  mathXMLString = "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">"
                         "  <apply>"
                         "    <times/>"
                         "    <ci> cytosol </ci>"
                         "    <ci> kcat </ci>"
                         "    <ci> ES </ci>"
                         "  </apply>"
                         "</math>";

  astMath = readMathMLFromString(mathXMLString);
  KineticLaw_setMath( kl, astMath);
  ASTNode_free( astMath );

  /*---------------------------------------------------------------------------
   * Creates local Parameter objects inside the KineticLaw object.
   *---------------------------------------------------------------------------*/

  /* Creates a Parameter ("kcat")*/

  para = KineticLaw_createParameter( kl );
  Parameter_setId( para, "kcat");
  Parameter_setValue( para, 0.1);
  Parameter_setUnits(para, "per_second");


  /* Returns the created SBMLDocument object.
   * The returned object must be explicitly deleted by the caller,
   * otherwise a memory leak will happen.*/

  return sbmlDoc;

}


/**
 *
 * Creates an SBML model represented in "7.2 Example involving units"
 * in the SBML Level 2 Version 4 Specification.
 *
 */
SBMLDocument_t* createExampleInvolvingUnits()
{
  const unsigned int level   = Level;
  const unsigned int version = Version;

   /* 
   * Variables
   */
  SBMLDocument_t* sbmlDoc;
  Model_t* model;
  XMLNamespaces_t* xmlns;
  char* notesString, * mathXMLString ;
  ASTNode_t* astMath, * astDivide, * astTimes, * astPlus ; 
  XMLNode_t* notesXMLNode;
  XMLTriple_t *pTripple;
  XMLAttributes_t* xmlAttr;

  /* Temporary pointers (reused more than once below).*/

  UnitDefinition_t* unitdef;
  Unit_t *unit;

  Compartment_t* comp;
  const char* compName = "cell";

  Species_t *sp;
  Parameter_t* para;

  Reaction_t* reaction;
  SpeciesReference_t* spr;
  KineticLaw_t* kl;





  /* Temporary pointers (reused more than once below). */


  /*---------------------------------------------------------------------------
   *
   * Creates an SBMLDocument object 
   *
   *---------------------------------------------------------------------------*/

  sbmlDoc = SBMLDocument_createWithLevelAndVersion(level,version);

  /* Adds the namespace for XHTML to the SBMLDocument object.  We need this
   * because we will add notes to the model.  (By default, the SBML document
   * created by SBMLDocument only declares the SBML XML namespace.)*/

  xmlns = (XMLNamespaces_t*) SBMLDocument_getNamespaces(sbmlDoc);
  XMLNamespaces_add(xmlns, "http://www.w3.org/1999/xhtml", "xhtml");

  /*---------------------------------------------------------------------------
   *
   * Creates a Model object inside the SBMLDocument object. 
   *
   *---------------------------------------------------------------------------*/

  model = SBMLDocument_createModel( sbmlDoc );
  Model_setId(model, "unitsExample");

  /*---------------------------------------------------------------------------
   *
   * Creates UnitDefinition objects inside the Model object.
   *
   *---------------------------------------------------------------------------*/

  
  /*---------------------------------------------------------------------------  
   * (UnitDefinition1) Creates an UnitDefinition object ("substance").
   *
   * This has the effect of redefining the default unit of subtance for the
   * whole model.
   *---------------------------------------------------------------------------*/

  unitdef = Model_createUnitDefinition(model);
  UnitDefinition_setId(unitdef, "substance");

  /*  Creates an Unit inside the UnitDefinition object */

  unit = UnitDefinition_createUnit(unitdef);
  Unit_setKind(unit, UNIT_KIND_MOLE);
  Unit_setScale(unit, -3);

  /*--------------------------------------------------------------------------------
   * (UnitDefinition2) Creates an UnitDefinition object ("mmls") 
   *--------------------------------------------------------------------------------*/
    
  /* Note that we can reuse the pointers 'unitdef' and 'unit' because the
   * actual UnitDefinition object (along with the Unit objects within it)
   * is already attached to the Model object.*/

  unitdef = Model_createUnitDefinition(model);
  UnitDefinition_setId(unitdef,"mmls");
    
  /*  Creates an Unit inside the UnitDefinition object ("mmls")*/

  unit = UnitDefinition_createUnit(unitdef);
  Unit_setKind(unit,UNIT_KIND_MOLE);
  Unit_setScale(unit,-3);

  /*  Creates an Unit inside the UnitDefinition object ("mmls")*/

  unit = UnitDefinition_createUnit(unitdef);
  Unit_setKind(unit, UNIT_KIND_LITRE);
  Unit_setExponent(unit, -1);

  /*  Creates an Unit inside the UnitDefinition object ("mmls")*/

  unit = UnitDefinition_createUnit(unitdef);
  Unit_setKind(unit, UNIT_KIND_SECOND);
  Unit_setExponent(unit, -1);

  /*--------------------------------------------------------------------------------
   * (UnitDefinition3) Creates an UnitDefinition object ("mml") 
   *--------------------------------------------------------------------------------*/
    
  unitdef = Model_createUnitDefinition(model);
  UnitDefinition_setId(unitdef, "mml");
    
  /*  Creates an Unit inside the UnitDefinition object ("mml")*/

  unit = UnitDefinition_createUnit(unitdef);
  Unit_setKind(unit, UNIT_KIND_MOLE);
  Unit_setScale(unit, -3);

  /*  Creates an Unit inside the UnitDefinition object ("mml")*/

  unit = UnitDefinition_createUnit(unitdef);
  Unit_setKind(unit, UNIT_KIND_LITRE);
  Unit_setExponent(unit, -1);


  /*---------------------------------------------------------------------------
   *
   * Creates a Compartment object inside the Model object. 
   *
   *---------------------------------------------------------------------------*/

  /* Creates a Compartment object ("cell")*/

  comp = Model_createCompartment(model);
  Compartment_setId(comp, compName);
 
  /* Sets the "size" attribute of the Compartment object.
   *
   *   The units of this Compartment object is the default SBML 
   *   units of volume (litre), and thus we don't have to explicitly invoke 
   *   setUnits("litre") function to set the default units.
   */
  Compartment_setSize(comp, 1);


  /*---------------------------------------------------------------------------
   *
   * Creates Species objects inside the Model object. 
   *
   *---------------------------------------------------------------------------*/
  
  /*---------------------------------------------------------------------------
   * (Species1) Creates a Species object ("x0")
   *---------------------------------------------------------------------------*/

  sp = Model_createSpecies(model);
  Species_setId(sp, "x0");

  /* Sets the "compartment" attribute of the Species object to identify the 
   * compartnet in which the Species object located.*/

  Species_setCompartment(sp, compName);

  /* Sets the "initialConcentration" attribute of the Species object.
   *
   *  The units of this Species object is determined by two attributes of this 
   *  Species object ("substanceUnits" and "hasOnlySubstanceUnits") and the
   *  "spatialDimensions" attribute of the Compartment object ("cytosol") in which 
   *  this species object is located.
   *  Since the default values are used for "substanceUnits" (substance (mole)) 
   *  and "hasOnlySubstanceUnits" (false) and the value of "spatialDimension" (3) 
   *  is greater than 0, the units of this Species object is  moles/liters . 
   */
  Species_setInitialConcentration(sp, 1);

  /*---------------------------------------------------------------------------
   * (Species2) Creates a Species object ("x1")
   *---------------------------------------------------------------------------*/

  sp = Model_createSpecies(model);
  Species_setId(sp, "x1");
  Species_setCompartment(sp, compName);
  Species_setInitialConcentration(sp, 1);

  /*---------------------------------------------------------------------------
   * (Species3) Creates a Species object ("s1")
   *---------------------------------------------------------------------------*/

  sp = Model_createSpecies(model);
  Species_setCompartment(sp, compName);
  Species_setId(sp, "s1");
  Species_setInitialConcentration(sp, 1);

  /*---------------------------------------------------------------------------
   * (Species4) Creates a Species object ("s2")
   *---------------------------------------------------------------------------*/

  sp = Model_createSpecies(model);
  Species_setCompartment(sp, compName);
  Species_setId(sp, "s2");
  Species_setInitialConcentration(sp, 1);

  /*---------------------------------------------------------------------------
   *
   * Creates global Parameter objects inside the Model object. 
   *
   *---------------------------------------------------------------------------*/

  /* Creates a Parameter ("vm")  */

  para = Model_createParameter(model);
  Parameter_setId(para, "vm");
  Parameter_setValue(para, 2);
  Parameter_setUnits(para, "mmls");

  /* Creates a Parameter ("km") */

  para = Model_createParameter(model);
  Parameter_setId(para, "km");
  Parameter_setValue(para, 2);
  Parameter_setUnits(para, "mml");


  /*---------------------------------------------------------------------------
   *
   * Creates Reaction objects inside the Model object. 
   *
   *---------------------------------------------------------------------------*/
  
  
  /*---------------------------------------------------------------------------
   * (Reaction1) Creates a Reaction object ("v1").
   *---------------------------------------------------------------------------*/

  reaction = Model_createReaction(model);
  Reaction_setId(reaction, "v1");

  /*---------------------------------------------------------------------------
   * Creates Reactant objects inside the Reaction object ("v1"). 
   *---------------------------------------------------------------------------*/

  /* (Reactant1) Creates a Reactant object that references Species "x0"
   * in the model.*/

  spr = Reaction_createReactant(reaction);
  SpeciesReference_setSpecies(spr, "x0");

  /*---------------------------------------------------------------------------
   * Creates a Product object inside the Reaction object ("v1"). 
   *---------------------------------------------------------------------------*/

  /* Creates a Product object that references Species "s1" in the model. */

  spr = Reaction_createProduct(reaction);
  SpeciesReference_setSpecies(spr, "s1");

  /*---------------------------------------------------------------------------
   * Creates a KineticLaw object inside the Reaction object ("v1"). 
   *---------------------------------------------------------------------------*/
  
  kl = Reaction_createKineticLaw(reaction);

  /* Creates a <notes> element in the KineticLaw object.
   * Here we illustrate how to do it using a literal string.  This requires
   * known the required syntax of XHTML and the requirements for SBML <notes>
   * elements.  Later below, we show how to create notes using objects instead
   * of strings.*/

  notesString = "<xhtml:p> ((vm * s1)/(km + s1)) * cell </xhtml:p>";
  SBase_setNotesString((SBase_t*)kl, notesString);

  /*---------------------------------------------------------------------------
   * Creates an ASTNode object which represents the following KineticLaw object.
   *
   *  <math xmlns=\"http://www.w3.org/1998/Math/MathML\">
   *   <apply>
   *     <times/>
   *     <apply>
   *       <divide/>
   *       <apply>
   *         <times/>
   *           <ci> vm </ci>
   *           <ci> s1 </ci>
   *       </apply>
   *       <apply>
   *         <plus/>
   *           <ci> km </ci>
   *           <ci> s1 </ci>
   *       </apply>
   *     </apply>
   *     <ci> cell </ci>
   *    </apply>
   *  </math>
   *---------------------------------------------------------------------------*/

  /*
   * In the following code, ASTNode objects, which construct an ASTNode tree 
   * of the above math, are created and added in the order of preorder traversal 
   * of the tree (i.e. the order corresponds to the nested structure of the above 
   * MathML elements), and thus the following code maybe a bit more efficient but 
   * maybe a bit difficult to read.
   */

  astMath = ASTNode_createWithType(AST_TIMES);

  ASTNode_addChild( astMath, ASTNode_createWithType(AST_DIVIDE));
  astDivide = ASTNode_getLeftChild( astMath );

  ASTNode_addChild( astDivide, ASTNode_createWithType(AST_TIMES));
  astTimes = ASTNode_getLeftChild (astDivide);

  ASTNode_addChild( astTimes, ASTNode_createWithType(AST_NAME));
  ASTNode_setName(ASTNode_getLeftChild(astTimes), "vm");

  ASTNode_addChild( astTimes, ASTNode_createWithType(AST_NAME));
  ASTNode_setName(ASTNode_getRightChild( astTimes), "s1");

  ASTNode_addChild( astDivide, ASTNode_createWithType(AST_PLUS));
  astPlus = ASTNode_getRightChild( astDivide );

  ASTNode_addChild( astPlus, ASTNode_createWithType(AST_NAME));
  ASTNode_setName(ASTNode_getLeftChild( astPlus ), "km");

  ASTNode_addChild( astPlus, ASTNode_createWithType(AST_NAME));
  ASTNode_setName(ASTNode_getRightChild( astPlus ), "s1");


  ASTNode_addChild( astMath, ASTNode_createWithType(AST_NAME));
  ASTNode_setName(ASTNode_getRightChild( astMath), "cell");

  /*---------------------------------------------
   *
   * set the Math element
   *
   *------------------------------------------------*/

  KineticLaw_setMath( kl, astMath);
  ASTNode_free(astMath);


  /*---------------------------------------------------------------------------
   * (Reaction2) Creates a Reaction object ("v2").
   *---------------------------------------------------------------------------*/

  reaction = Model_createReaction(model);
  Reaction_setId(reaction, "v2");

  /*---------------------------------------------------------------------------
   * Creates Reactant objects inside the Reaction object ("v2"). 
   *---------------------------------------------------------------------------*/

  /* (Reactant2) Creates a Reactant object that references Species "s1"
   * in the model.*/

  spr = Reaction_createReactant(reaction);
  SpeciesReference_setSpecies(spr, "s1");

  /*---------------------------------------------------------------------------
   * Creates a Product object inside the Reaction object ("v2"). 
   *---------------------------------------------------------------------------*/

  /* Creates a Product object that references Species "s2" in the model. */

  spr = Reaction_createProduct(reaction);
  SpeciesReference_setSpecies(spr, "s2");

  /*---------------------------------------------------------------------------
   * Creates a KineticLaw object inside the Reaction object ("v2"). 
   *---------------------------------------------------------------------------*/
  
  kl = Reaction_createKineticLaw(reaction);

  /* Sets a notes (by XMLNode) to the KineticLaw object.
   *
   * The following code is an alternative to using setNotes(const string&).
   * The equivalent code would be like this:
   *   
   *     notesString = "<xhtml:p>((vm * s2)/(km + s2))*cell</xhtml:p>";
   *     kl->setNotes(notesString);

   * Creates an XMLNode of start element (<xhtml:p>) without attributes.*/

  pTripple = XMLTriple_createWith("p", "", "xhtml");
  xmlAttr = XMLAttributes_create();
  notesXMLNode = XMLNode_createStartElement(pTripple, xmlAttr);

  /* Adds a text element to the start element.*/

  XMLNode_addChild( notesXMLNode, XMLNode_createTextNode(" ((vm * s2)/(km + s2)) * cell ")); 

  /* Adds it to the kineticLaw object.*/

  SBase_setNotes( (SBase_t*) kl, notesXMLNode);

  /*---------------------------------------------------------------------------
   * Sets a math (ASTNode object) to the KineticLaw object.
   *---------------------------------------------------------------------------*/

  /* To create mathematical expressions, one would typically construct
   * an ASTNode tree as the above example code which creates a math of another
   * KineticLaw object.  Here, to save some space and illustrate another approach 
   * of doing it, we will write out the formula in MathML form and then use a 
   * libSBML convenience function to create the ASTNode tree for us.  
   * (This is a bit dangerous; it's very easy to make mistakes when writing MathML 
   * by hand, so in a real program, we would not really want to do it this way.)*/

  mathXMLString = "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">"
                         "  <apply>"
                         "    <times/>"
                         "    <apply>"
                         "      <divide/>"
                         "      <apply>"
                         "        <times/>"
                         "        <ci> vm </ci>"
                         "        <ci> s2 </ci>"
                         "      </apply>"
                         "      <apply>"
                         "        <plus/>"
                         "          <ci> km </ci>"
                         "          <ci> s2 </ci>"
                         "      </apply>"
                         "    </apply>"
                         "    <ci> cell </ci>"
                         "  </apply>"
                         "</math>";

  astMath = readMathMLFromString(mathXMLString);
  KineticLaw_setMath(kl, astMath);
  ASTNode_free(astMath);


  /*---------------------------------------------------------------------------
   * (Reaction3) Creates a Reaction object ("v3").
   *---------------------------------------------------------------------------*/

  reaction = Model_createReaction(model);
  Reaction_setId(reaction, "v3");

  /*---------------------------------------------------------------------------
   * Creates Reactant objects inside the Reaction object ("v3"). 
   *---------------------------------------------------------------------------*/

  /* (Reactant2) Creates a Reactant object that references Species "s2"
   * in the model.*/

  spr = Reaction_createReactant(reaction);
  SpeciesReference_setSpecies(spr, "s2");

  /*---------------------------------------------------------------------------
   * Creates a Product object inside the Reaction object ("v3"). 
   *---------------------------------------------------------------------------*/

  /* Creates a Product object that references Species "x1" in the model. */

  spr = Reaction_createProduct(reaction);
  SpeciesReference_setSpecies(spr, "x1");


  /*---------------------------------------------------------------------------
   * Creates a KineticLaw object inside the Reaction object ("v3"). 
   *---------------------------------------------------------------------------*/
  
  kl = Reaction_createKineticLaw(reaction);

  /* Sets a notes (by string) to the KineticLaw object.*/

  notesString = "<xhtml:p> ((vm * x1)/(km + x1)) * cell </xhtml:p>";
  SBase_setNotesString((SBase_t*) kl, notesString);

  /*---------------------------------------------------------------------------
   * Sets a math (ASTNode object) to the KineticLaw object.
   *---------------------------------------------------------------------------*/

  mathXMLString = "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">"
                  "  <apply>"
                  "    <times/>"
                  "    <apply>"
                  "      <divide/>"
                  "      <apply>"
                  "        <times/>"
                  "        <ci> vm </ci>"
                  "        <ci> x1 </ci>"
                  "      </apply>"
                  "      <apply>"
                  "        <plus/>"
                  "          <ci> km </ci>"
                  "          <ci> x1 </ci>"
                  "      </apply>"
                  "    </apply>"
                  "    <ci> cell </ci>"
                  "  </apply>"
                  "</math>";

  astMath = readMathMLFromString(mathXMLString);
  KineticLaw_setMath( kl, astMath);
  ASTNode_free(astMath);


  /* Returns the created SBMLDocument object.
   * The returned object must be explicitly deleted by the caller,
   * otherwise memory leak will happen.*/

  return sbmlDoc;

}



/**
 *
 * Creates an SBML model represented in "7.8 Example involving function definitions"
 * in the SBML Level 2 Version 4 Specification.
 *
 */
SBMLDocument_t* createExampleInvolvingFunctionDefinitions()
{
  const unsigned int level   = Level;
  const unsigned int version = Version;

  /* 
   * Variables
   */
  SBMLDocument_t* sbmlDoc;
  Model_t* model;
  FunctionDefinition_t* fdef;
  char* mathXMLString;
  ASTNode_t* astMath;
  Compartment_t* comp;
  const char* compName = "compartmentOne";
  Species_t* sp;
  Parameter_t* para;

  
  /* Temporary pointers.*/

  Reaction_t* reaction;
  SpeciesReference_t* spr;
  KineticLaw_t* kl;





  /*---------------------------------------------------------------------------
   *
   * Creates an SBMLDocument object 
   *
   *---------------------------------------------------------------------------*/

  sbmlDoc = SBMLDocument_createWithLevelAndVersion(level,version);

  /*---------------------------------------------------------------------------
   *
   * Creates a Model object inside the SBMLDocument object. 
   *
   *---------------------------------------------------------------------------*/

  model = SBMLDocument_createModel(sbmlDoc);
  Model_setId(model, "functionExample");

  /*---------------------------------------------------------------------------
   *
   * Creates a FunctionDefinition object inside the Model object. 
   *
   *---------------------------------------------------------------------------*/

  fdef = Model_createFunctionDefinition(model);
  FunctionDefinition_setId(fdef, "f");

  /* Sets a math (ASTNode object) to the FunctionDefinition object.*/

  mathXMLString = "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">"
                         "  <lambda>"
                         "    <bvar>"
                         "      <ci> x </ci>"
                         "    </bvar>"
                         "    <apply>"
                         "      <times/>"
                         "      <ci> x </ci>"
                         "      <cn> 2 </cn>"
                         "    </apply>"
                         "  </lambda>"
                         "</math>";

  astMath = readMathMLFromString(mathXMLString);
  FunctionDefinition_setMath( fdef, astMath);
  ASTNode_free(astMath);


  /*---------------------------------------------------------------------------
   *
   * Creates a Compartment object inside the Model object. 
   *
   *---------------------------------------------------------------------------*/

  
  /* Creates a Compartment object ("compartmentOne")*/

  comp = Model_createCompartment(model);
  Compartment_setId(comp, compName);
 
  /* Sets the "size" attribute of the Compartment object.
   *
   *   The units of this Compartment object is the default SBML 
   *   units of volume (litre), and thus we don't have to explicitly invoke 
   *   setUnits("litre") function to set the default units.
   */
  Compartment_setSize(comp, 1);


  /*---------------------------------------------------------------------------
   *
   * Creates Species objects inside the Model object. 
   *
   *---------------------------------------------------------------------------*/
  
  
  /*---------------------------------------------------------------------------
   * (Species1) Creates a Species object ("S1")
   *---------------------------------------------------------------------------*/

  sp = Model_createSpecies(model);
  Species_setId(sp, "S1");

  /* Sets the "compartment" attribute of the Species object to identify the 
   * compartnet in which the Species object located.*/

  Species_setCompartment(sp, compName);

  /* Sets the "initialConcentration" attribute of the Species object.
   *
   *  The units of this Species object is determined by two attributes of this 
   *  Species object ("substanceUnits" and "hasOnlySubstanceUnits") and the
   *  "spatialDimension" attribute of the Compartment object ("cytosol") in which 
   *  this species object located.
   *  Since the default values are used for "substanceUnits" (substance (mole)) 
   *  and "hasOnlySubstanceUnits" (false) and the value of "spatialDimension" (3) 
   *  is greater than 0, the units of this Species object is  mole/litre . 
   */

  Species_setInitialConcentration(sp, 1);

  /*---------------------------------------------------------------------------
   * (Species2) Creates a Species object ("S2")
   *---------------------------------------------------------------------------*/

  sp = Model_createSpecies(model);
  Species_setId(sp, "S2");
  Species_setCompartment(sp, compName);
  Species_setInitialConcentration(sp, 0);


  /*---------------------------------------------------------------------------
   *
   * Creates a global Parameter object inside the Model object. 
   *
   *---------------------------------------------------------------------------*/

  
  /* Creates a Parameter ("t")  */

  para = Model_createParameter(model);
  Parameter_setId(para, "t");
  Parameter_setValue(para, 1);
  Parameter_setUnits(para, "second");


  /*---------------------------------------------------------------------------
   *
   * Creates Reaction objects inside the Model object. 
   *
   *---------------------------------------------------------------------------*/
  
  /*---------------------------------------------------------------------------
   * (Reaction1) Creates a Reaction object ("reaction_1").
   *---------------------------------------------------------------------------*/

  reaction = Model_createReaction(model);
  Reaction_setId(reaction, "reaction_1");
  Reaction_setReversible(reaction, 0);

  /*---------------------------------------------------------------------------
   * Creates Reactant objects inside the Reaction object ("reaction_1"). 
   *---------------------------------------------------------------------------*/

  /* (Reactant1) Creates a Reactant object that references Species "S1"
   * in the model.*/

  spr = Reaction_createReactant(reaction);
  SpeciesReference_setSpecies(spr, "S1");

  /*---------------------------------------------------------------------------
   * Creates a Product object inside the Reaction object ("reaction_1"). 
   *---------------------------------------------------------------------------*/

  /* Creates a Product object that references Species "S2" in the model. */

  spr = Reaction_createProduct(reaction);
  SpeciesReference_setSpecies(spr, "S2");


  /*---------------------------------------------------------------------------
   * Creates a KineticLaw object inside the Reaction object ("reaction_1"). 
   *---------------------------------------------------------------------------*/
  
  kl = Reaction_createKineticLaw(reaction);

  /*---------------------------------------------------------------------------
   * Sets a math (ASTNode object) to the KineticLaw object.
   *---------------------------------------------------------------------------*/

  mathXMLString = "<math xmlns=\"http://www.w3.org/1998/Math/MathML\">"
                  "  <apply>"
                  "  <divide/>"
                  "    <apply>"
                  "      <times/>"
                  "      <apply>"
                  "        <ci> f </ci>"
                  "        <ci> S1 </ci>"
                  "      </apply>"
                  "      <ci> compartmentOne </ci>"
                  "    </apply>"
                  "    <ci> t </ci>"
                  "  </apply>"
                  "</math>";

  astMath = readMathMLFromString(mathXMLString);
  KineticLaw_setMath( kl, astMath);
  ASTNode_free(astMath);


  /* Returns the created SBMLDocument object.
   * The returned object must be explicitly deleted by the caller,
   * otherwise memory leak will happen.*/

  return sbmlDoc;
}


/*===============================================================================
 *
 *
 * Helper functions for writing/validating the given SBML documents.
 * 
 *
 *===============================================================================*/

/**
 *  
 *  Validates the given SBMLDocument.
 *
 *   This function is based on validateSBML.cpp implemented by
 *   Sarah Keating, Ben Bornstein, and Michael Hucka.
 *
 */
int validateExampleSBML (SBMLDocument_t* sbmlDoc)
{
  int noProblems                      = 1;
  unsigned int numCheckFailures       = 0;
  unsigned int numConsistencyErrors   = 0;
  unsigned int numConsistencyWarnings = 0;
  unsigned int numValidationErrors    = 0;
  unsigned int numValidationWarnings  = 0;

  if (!sbmlDoc)
  {
    fprintf(stderr, "validateExampleSBML: given a null SBML Document\n");
    return 0;
  }
 

  /* LibSBML 3.3 is lenient when generating models from scratch using the
   * API for creating objects.  Once the whole model is done and before it
   * gets written out, it's important to check that the whole model is in
   * fact complete, consistent and valid.*/

  numCheckFailures = SBMLDocument_checkInternalConsistency( sbmlDoc);
  if ( numCheckFailures > 0 )
  {
    unsigned int i;
    noProblems = 0;
    for (i = 0; i < numCheckFailures; i++)
    {
      const SBMLError_t* sbmlErr = SBMLDocument_getError( sbmlDoc, i);
      if ( XMLError_isFatal((const XMLError_t*) sbmlErr) || XMLError_isError((const XMLError_t*) sbmlErr) )
      {
        ++numConsistencyErrors;
      }
      else
      {
        ++numConsistencyWarnings;
      }      
    } 

    SBMLDocument_printErrors(sbmlDoc, stdout);
  }

  /* If the internal checks fail, it makes little sense to attempt
   * further validation, because the model may be too compromised to
   * be properly interpreted.*/

  if (numConsistencyErrors > 0)
  {
    printf("Further validation aborted.\n"); 
  }
  else
  {
    numCheckFailures = SBMLDocument_checkConsistency( sbmlDoc );
    if ( numCheckFailures > 0 )
    {
      unsigned int i;
      noProblems = 0;
      for (i = 0; i < numCheckFailures; i++)
      {
        const SBMLError_t* sbmlErr = SBMLDocument_getError( sbmlDoc, i);
        if ( XMLError_isFatal((const XMLError_t*) sbmlErr) || XMLError_isError((const XMLError_t*) sbmlErr) )
        {
          ++numValidationErrors;
        }
        else
        {
          ++numValidationWarnings;
        }      
      } 
      SBMLDocument_printErrors(sbmlDoc, stdout);
    }
  }

  if (noProblems)
    return 1;
  else
  {
    if (numConsistencyErrors > 0)
    {
      printf("ERROR: encountered %d consistency error%s in model '%s'.\n", 
        numConsistencyErrors, 
        (numConsistencyErrors == 1 ? "" : "s"),
        Model_getId(SBMLDocument_getModel( sbmlDoc)));
    }
    if (numConsistencyWarnings > 0)
    {
      printf( "Notice: encountered %d consistency warning%s in model '%s'.\n",
       numConsistencyWarnings, 
       (numConsistencyWarnings == 1 ? "" : "s"),
       Model_getId(SBMLDocument_getModel( sbmlDoc))
       );
    }

    if (numValidationErrors > 0)
    {
       printf("ERROR: encountered %d validation error%s in model '%s'.\n", 
        numValidationErrors, 
        (numValidationErrors == 1 ? "" : "s"),
        Model_getId(SBMLDocument_getModel( sbmlDoc)) );
    }
    if (numValidationWarnings > 0)
    {
       printf( "Notice: encountered %d validation warning%s in model '%s'.\n",
       numValidationWarnings, 
       (numValidationWarnings == 1 ? "" : "s"),
       Model_getId(SBMLDocument_getModel( sbmlDoc))
       );     
    }

    return (numConsistencyErrors == 0 && numValidationErrors == 0);
  }
}


/**
 *
 * Writes the given SBMLDocument to the given file.
 *
 */ 
int writeExampleSBML(SBMLDocument_t* sbmlDoc, const char* filename)
{

  int result = writeSBML(sbmlDoc, filename);

  if (result)
  {
    printf("Wrote file \"%s\"\n", filename);

    return 1;
  }
  else
  {
    fprintf(stderr, "Failed to write \"%s\"\n", filename );
    return 0;
  }
}
