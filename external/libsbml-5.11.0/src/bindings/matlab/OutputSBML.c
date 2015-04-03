/**
 * @file    OutputSBML.c
 * @brief   MATLAB code for translating SBML-MATLAB structure into a SBML document.
 * @author  Sarah Keating
 *
 * <!--------------------------------------------------------------------------
 * This file is part of SBMLToolbox.  Please visit http://sbml.org for more
 * information about SBML, and the latest version of SBMLToolbox.
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
 * in the file named "LICENSE.txt" included with this software distribution.
 * and also available online as http://sbml.org/software/sbmltoolbox/license.html
 * ---------------------------------------------------------------------- -->*/

#include <mex.h>
#ifndef USE_OCTAVE
#include <matrix.h>
#endif
#include <string.h>

#include <sbml/SBMLReader.h>
#include <sbml/SBMLTypes.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/math/ASTNode.h>

/*#define USE_FBC 1 */
#ifdef USE_FBC

#include <sbml/packages/fbc/extension/FbcModelPlugin.h>
#include <sbml/packages/fbc/extension/FbcSpeciesPlugin.h>
#include <sbml/packages/fbc/extension/FbcExtension.h>

#include <sbml/packages/fbc/sbml/FluxBound.h>
#include <sbml/packages/fbc/sbml/FluxObjective.h>
#include <sbml/packages/fbc/sbml/Objective.h>

#endif



#if defined(WIN32) && !defined(CYGWIN) && !defined(USE_OCTAVE)
#define FILE_CHAR wchar_t*
#define FILE_FOPEN(file) _wfopen(file, L"r")
#define USE_FILE_WCHAR 1
#else 
#define FILE_CHAR char*
#define FILE_FOPEN(file) fopen(file, "r")
#endif

#ifndef uint16_t
#define uint16_t unsigned short
#endif

FILE_CHAR readUnicodeString(const mxArray *prhs, mwSize length)
{
#ifdef USE_OCTAVE
  char* ansii = (char *) mxCalloc(length, sizeof(char));
  mxGetString(prhs, ansii, length);
  return ansii;
#else   
  wchar_t* utf16 = (wchar_t *) mxCalloc(length, sizeof(wchar_t));
  char* utf8 = NULL;
  uint16_T *ch = (uint16_T *) mxGetData(prhs);
  wchar_t* p = utf16;
  mwSize i;
  for ( i = 0; i < length-1; ++i)
    *p++ = *ch++;
  *p = 0;

#if USE_FILE_WCHAR
  return utf16;
#else

  utf8 = (char*)mxCalloc(length*2, sizeof(char));

  wcstombs(utf8, utf16, length*2);

  /*mxFree(utf16);*/

  if (utf8 != NULL && strlen(utf8) == 0 && length > 0)
  {
    mexErrMsgTxt("This string uses characters that cannot be expressed in UTF8, please rename the file.");
  }

  return utf8;
#endif /* USE_FILE_WCHAR */ 

#endif /* USE_OCTAVE*/ 

}


FILE_CHAR readUnicodeStringFromArrays(mxArray *mxFilename[2])

{
  mwSize nBuflen = (mxGetM(mxFilename[0])*mxGetN(mxFilename[0])+1);
  FILE_CHAR pacTempString1 = readUnicodeString(mxFilename[0],nBuflen);

  mwSize nBufferLen = (mxGetM(mxFilename[1])*mxGetN(mxFilename[1])+1);
  FILE_CHAR  pacTempString2 = readUnicodeString(mxFilename[1],nBufferLen);
  
#if USE_FILE_WCHAR
  FILE_CHAR  pacFilename = (wchar_t *) mxCalloc(nBufferLen+nBuflen, sizeof(wchar_t));
  wcscpy(pacFilename, pacTempString2);
  wcscat(pacFilename, pacTempString1);
#else
  FILE_CHAR  pacFilename = (char *) mxCalloc(nBufferLen+nBuflen, sizeof(char));
  strcpy(pacFilename, pacTempString2);
  strcat(pacFilename, pacTempString1);
#endif
  
  /*mxFree(pacTempString1);*/
  /*mxFree(pacTempString2);*/
  return pacFilename;
}

#if USE_FILE_WCHAR

int endsWith(const wchar_t* fileName, const char* ext)
{
  size_t len = wcslen(fileName), i;
  size_t targetLen = strlen(ext);
  wchar_t* temp1 =  (wchar_t*)mxCalloc(targetLen, sizeof(wchar_t));
  char* temp2 =  (char*)mxCalloc(targetLen, sizeof(char));
  int result = 0;
  
  for (i = 0; i < targetLen; ++i)
  {
    temp1[i] = fileName[len - targetLen + i];
  }
  
  wcstombs(temp2,temp1, targetLen);
  result = strcmp_insensitive(temp2, ext);

  /*mxFree(temp1);*/
  /*mxFree(temp2);*/
  return result;
}

#endif

static char * timeSymbol = NULL;
static char * delaySymbol = NULL;
static char * avoSymbol = NULL;

int fbcPresent;

/* function declarations */
void LookForCSymbolTime(ASTNode_t *);
void LookForCSymbolDelay(ASTNode_t *);
void LookForCSymbolAvo(ASTNode_t *);


SBMLTypeCode_t  CharToTypecode (char *);

void
GetNamespaces (mxArray * mxNamespaces,
			         SBMLNamespaces_t * pNamespaces);

void  GetParameter			( mxArray *, unsigned int, unsigned int, Model_t * );
void  GetCompartment		( mxArray *, unsigned int, unsigned int, Model_t * );
void  GetFunctionDefinition	( mxArray *, unsigned int, unsigned int, Model_t * );
void  GetUnitDefinition		( mxArray *, unsigned int, unsigned int, Model_t * );
void  GetSpecies			( mxArray *, unsigned int, unsigned int, Model_t * );
void  GetRule				( mxArray *, unsigned int, unsigned int, Model_t * );
void  GetReaction			( mxArray *, unsigned int, unsigned int, Model_t * );
void  GetEvent              ( mxArray *, unsigned int, unsigned int, Model_t * );
void  GetCompartmentType    ( mxArray *, unsigned int, unsigned int, Model_t * );
void  GetSpeciesType        ( mxArray *, unsigned int, unsigned int, Model_t * );
void  GetInitialAssignment  ( mxArray *, unsigned int, unsigned int, Model_t * );
void  GetConstraint         ( mxArray *, unsigned int, unsigned int, Model_t * );

void  GetEventAssignment ( mxArray *, unsigned int, unsigned int, Event_t * );
void  GetTrigger ( mxArray *, unsigned int, unsigned int, Event_t * );
void  GetDelay ( mxArray *, unsigned int, unsigned int, Event_t * );
void  GetPriority ( mxArray *, unsigned int, unsigned int, Event_t * );


void GetUnit ( mxArray *, unsigned int, unsigned int, UnitDefinition_t * );

void GetSpeciesReference	( mxArray *, unsigned int, unsigned int, Reaction_t *, int);
void GetProduct				( mxArray *, unsigned int, unsigned int, Reaction_t * );
void GetKineticLaw			( mxArray *, unsigned int, unsigned int, Reaction_t * );
void GetModifier			( mxArray *, unsigned int, unsigned int, Reaction_t * );

void GetStoichiometryMath			( mxArray *, unsigned int, unsigned int, SpeciesReference_t * );

void GetParameterFromKineticLaw ( mxArray *, unsigned int, unsigned int, KineticLaw_t * );

#ifdef USE_FBC

void  GetFluxBound         ( mxArray *, unsigned int, unsigned int, unsigned int, Model_t * );
void  GetObjective         ( mxArray *, unsigned int, unsigned int, unsigned int, Model_t * );
void  GetFluxObjective         ( mxArray *, unsigned int, unsigned int, unsigned int, Objective_t * );

#endif

mxArray * mxModel[2];

void FreeMem(void)
{
	/* destroy arrays created */
	mxDestroyArray(mxModel[0]);
}

char * ReadString(mxArray* mxParent, const char * name, 
                  const char * parentName,
                  unsigned int index,
                  size_t total)
{
  mxArray * mxField;
  char * value;
  size_t nBuflen;
  int nStatus;

  /* get field */
  mxField = mxGetField(mxParent, index, name);
  nBuflen = (mxGetM(mxField)*mxGetN(mxField)+1);
  value = (char *)mxCalloc(nBuflen, sizeof(char));
  nStatus = mxGetString(mxField, value, (mwSize)(nBuflen));

  if (nStatus != 0)
  {
    char my_local_output[400];
    if (total == 0)
      sprintf( my_local_output, "Cannot copy %s.%s field", parentName, name);
    else
      sprintf( my_local_output, "Cannot copy %s(%d).%s field", 
                                        parentName, index+1, name);

    mexErrMsgTxt(my_local_output);
  }

  return value;
}

/**
 * NAME:    mexFunction
 *
 * PARAMETERS:  int     nlhs     -  number of output arguments  
 *              mxArray *plhs[]  -  output arguments
 *              int     nrhs     -  number of input arguments
 *              mxArray *prhs[]  -  input arguments
 *
 * RETURNS:    
 *
 * FUNCTION:  MATLAB standard dll export function
 *            any returns are made through the mxArray * plhs
 */
void
mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  mxArray * mxCheckStructure[2];
  mxArray * mxFilename[2], * mxExt[1];
  int nStatus;
  FILE_CHAR pacFilename = NULL;
  char *pacTempString1 = NULL, *pacTempString2 = NULL;
  size_t nBuflen;

  SBMLDocument_t *sbmlDocument;
  SBMLNamespaces_t *ns;
  XMLNamespaces_t *xmlns;
  Model_t *sbmlModel;


  mxArray * mxLevel, * mxVersion, * mxAnnotations, * mxFBCVersion;
  mxArray * mxName, *mxNamespaces, *mxMetaid, *mxTimeSymbol, *mxId;
  mxArray * mxSubstanceUnits, * mxTimeUnits, *mxLengthUnits, *mxAreaUnits;
  mxArray * mxVolumeUnits, * mxExtentUnits, *mxConversionFactor;
  mxArray * mxDelaySymbol, *mxAvoSymbol, *mxActiveObjective;
  unsigned int nLevel, nVersion, nFBCVersion;
  char * pacNotes, * pacAnnotations;
  char * pacName, * pacId, *pacMetaid;
  char * pacSubstanceUnits, * pacTimeUnits, *pacLengthUnits, *pacAreaUnits;
  char * pacVolumeUnits, * pacExtentUnits, *pacConversionFactor, *pacActiveObjective;
  int nSBOTerm;

  mxArray * mxParameters, * mxCompartments, * mxFunctionDefinitions;
  mxArray * mxUnitDefinitions, *mxSBOTerm;
  mxArray * mxSpecies, * mxRules, * mxReactions, * mxEvents, * mxConstraints;
  mxArray * mxSpeciesTypes, * mxCompartmentTypes, * mxInitialAssignments;
  mxArray * mxFluxBounds, *mxObjectives;
  unsigned int usingOctave = 0;
  mxArray * mxOctave[1];
  int inInstaller = 0;
  char * msgTxt = NULL;
  fbcPresent = 0;

  /* determine whether we are in octave or matlab */

  mexCallMATLAB(1, mxOctave, 0, NULL, "isoctave");

  nBuflen = (mxGetM(mxOctave[0])*mxGetN(mxOctave[0])+1);
  pacTempString1 = (char *) mxCalloc(nBuflen, sizeof(char));
  nStatus = mxGetString(mxOctave[0], pacTempString1, (mwSize)(nBuflen));

  if (nStatus != 0)
  {
    mexErrMsgTxt("Could not determine platform");
  }

  if (!(strcmp_insensitive(pacTempString1, "0") == 0))
    usingOctave = 1;

  /*************************************************************************************
  * validate inputs and outputs
  **********************************************************************************/
  if (nrhs < 1)
  {
    mexErrMsgTxt("Must supply at least the model as an output argument\n"
      "USAGE: OutputSBML(SBMLModel, (filename))");
  }
  if (usingOctave == 1 && nrhs < 2)
  {
    mexErrMsgTxt("Octave requires the filename to be specified\n"
      "USAGE: OutputSBML(SBMLModel, filename)");
  }
  if (nrhs > 3)
  {
    inInstaller = 1;
  }

  /**
  * create a copy of the input
  */	
  mxModel[0] = mxDuplicateArray(prhs[0]);
  mexMakeArrayPersistent(mxModel[0]);
  mexAtExit(FreeMem);

  /**
  * we know have the option of a third argument that indicates that we
  * want the structure to ONLY contain expected fields or not
  */
  if (nrhs > 2)
  {
    mxModel[1] = (mxArray *)prhs[2];
  }  
  else
  {
    mxModel[1] = mxCreateDoubleScalar(1);
  }

  /**
  * check number and type of output arguments
  * SHOULDNT BE ANY
  */
  if (nlhs > 0)
  {
    mexErrMsgTxt("Too many output arguments\n"
      "USAGE: OutputSBML(SBMLModel, (filename))");
  }

  /**
  * check number and type of input arguments
  * must be a valid MATLAB_SBML structure
  * and optionally the filename
  */

  if (nrhs > 4)
  {
    mexErrMsgTxt("Too many input arguments\n"
      "USAGE: OutputSBML(SBMLModel, (filename), (exclusive))");
  }

  nStatus = mexCallMATLAB(2, mxCheckStructure, 2, mxModel, "isSBML_Model");

  if ((nStatus != 0) || (mxIsLogicalScalarTrue(mxCheckStructure[0]) != 1))
  {
    /* there are errors - use the pacTempString1 char * to list these to the user */
    nBuflen = (mxGetM(mxCheckStructure[1])*mxGetN(mxCheckStructure[1])+1);
    pacTempString1 = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxCheckStructure[1], pacTempString1, (mwSize)(nBuflen));
    if (nStatus == 0)
    {
      msgTxt = (char *) mxCalloc(200+nBuflen, sizeof(char));
      sprintf(msgTxt, "\n%s\n\nErrors reported: %s%s\n", "First input must be a valid MATLAB_SBML Structure", 
        pacTempString1, "USAGE: OutputSBML(SBMLModel, (filename))");
      mexErrMsgTxt(msgTxt);
    }
    else
    {
      msgTxt = (char *) mxCalloc(200, sizeof(char));
      sprintf(msgTxt, "%s\n%s", "First input must be a valid MATLAB_SBML Structure", 
        "USAGE: OutputSBML(SBMLModel, (filename))");
      mexErrMsgTxt(msgTxt);
    } 
  }

  if (nrhs >= 2)
  {

    if (mxIsChar(prhs[1]) != 1)
    {
      mexErrMsgTxt("Second input must be a filename\n"
        "USAGE: OutputSBML(SBMLModel, (filename))");
    }

    nBuflen = (mxGetM(prhs[1])*mxGetN(prhs[1])+1);
    pacFilename = readUnicodeString(prhs[1], (mwSize)nBuflen);

  }
  /*********************************************************************************************************
  * get the details of the model
  ***********************************************************************************************************/

  /**
  * get the SBML level and version from the structure
  * and create the document with these
  */

  mxLevel = mxGetField(mxModel[0], 0, "SBML_level");
  nLevel = (unsigned int) mxGetScalar(mxLevel);

  mxVersion = mxGetField(mxModel[0], 0, "SBML_version");
  nVersion = (unsigned int) mxGetScalar(mxVersion);

  if (nLevel > 1)
  {
    mxTimeSymbol = mxGetField(mxModel[0], 0, "time_symbol");
    nBuflen = (mxGetM(mxTimeSymbol)*mxGetN(mxTimeSymbol)+1);
    timeSymbol = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxTimeSymbol, timeSymbol, (mwSize)(nBuflen));

    mxDelaySymbol = mxGetField(mxModel[0], 0, "delay_symbol");
    nBuflen = (mxGetM(mxDelaySymbol)*mxGetN(mxDelaySymbol)+1);
    delaySymbol = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxDelaySymbol, delaySymbol, (mwSize)(nBuflen));
  }
  else
  {
    timeSymbol = (char *)mxCalloc(1, sizeof(char));
    delaySymbol = (char *)mxCalloc(1, sizeof(char));

  }

  if (nLevel > 2)
  {
    mxAvoSymbol = mxGetField(mxModel[0], 0, "avogadro_symbol");
    nBuflen = (mxGetM(mxAvoSymbol)*mxGetN(mxAvoSymbol)+1);
    avoSymbol = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxAvoSymbol, avoSymbol, (mwSize)(nBuflen)); 
  }
  else
  {
    avoSymbol = (char *)mxCalloc(1, sizeof(char));
  }

  /* add any saved namespaces */
  ns = SBMLNamespaces_create(nLevel, nVersion);
  mxNamespaces = mxGetField(mxModel[0], 0, "namespaces");
  GetNamespaces(mxNamespaces, ns);

  /* look for fbc */

  if (XMLNamespaces_hasPrefix(SBMLNamespaces_getNamespaces(ns), "fbc") == 1)
  {
    fbcPresent = 1;
  }

  /* the fbc namespace may not be set 
  * but thet fbc package may still be used
  */
  if (fbcPresent == 0)
  {
    nStatus = mxGetFieldNumber(mxModel[0], "fbc_version");
    if (nStatus > 0)
    {
      fbcPresent = 1;
      xmlns = XMLNamespaces_create();
      XMLNamespaces_add(xmlns, 
        "http://www.sbml.org/sbml/level3/version1/fbc/version1", "fbc");
      SBMLNamespaces_addNamespaces(ns, xmlns);
    }
  }

  sbmlDocument = SBMLDocument_createWithSBMLNamespaces(ns);
  if (fbcPresent == 1)
  {
    SBMLDocument_setPkgRequired(sbmlDocument, "fbc", 0);
    mxFBCVersion = mxGetField(mxModel[0], 0, "fbc_version");
    nFBCVersion = (unsigned int) mxGetScalar(mxFBCVersion);
  }

  /* create a model within the document */
  sbmlModel = SBMLDocument_createModel(sbmlDocument);

  /* get notes */
  pacNotes = ReadString(mxModel[0], "notes", "top-level", 0, 0);
  SBase_setNotesString((SBase_t *)(sbmlModel), pacNotes); 

  /* get name */
  mxName = mxGetField(mxModel[0], 0, "name");
  nBuflen = (mxGetM(mxName)*mxGetN(mxName)+1);
  pacName = (char *)mxCalloc(nBuflen, sizeof(char));
  nStatus = mxGetString(mxName, pacName, (mwSize)(nBuflen));

  if (nStatus != 0)
  {
    mexErrMsgTxt("Cannot copy name");
  }

  Model_setName(sbmlModel, pacName);

  mxUnitDefinitions = mxGetField(mxModel[0], 0, "unitDefinition");
  GetUnitDefinition(mxUnitDefinitions, nLevel, nVersion, sbmlModel);

  mxCompartments = mxGetField(mxModel[0], 0, "compartment");
  GetCompartment(mxCompartments, nLevel, nVersion, sbmlModel);

  mxSpecies = mxGetField(mxModel[0], 0, "species");
  GetSpecies(mxSpecies, nLevel, nVersion, sbmlModel);

  mxParameters = mxGetField(mxModel[0], 0, "parameter");
  GetParameter(mxParameters, nLevel, nVersion, sbmlModel);

  mxRules = mxGetField(mxModel[0], 0, "rule");
  GetRule(mxRules, nLevel, nVersion, sbmlModel);

  mxReactions = mxGetField(mxModel[0], 0, "reaction");
  GetReaction(mxReactions, nLevel, nVersion, sbmlModel);

  /* level 2 and 3 only */
  if (nLevel > 1)
  {
    /* get id */
    mxId = mxGetField(mxModel[0], 0, "id");
    nBuflen = (mxGetM(mxId)*mxGetN(mxId)+1);
    pacId = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxId, pacId, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy id");
    }

    Model_setId(sbmlModel, pacId);

    /* get metaid */
    mxMetaid = mxGetField(mxModel[0], 0, "metaid");
    nBuflen = (mxGetM(mxMetaid)*mxGetN(mxMetaid)+1);
    pacMetaid = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxMetaid, pacMetaid, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy metaid");
    }

    SBase_setMetaId((SBase_t *) (sbmlModel), pacMetaid);

    mxFunctionDefinitions = mxGetField(mxModel[0], 0, "functionDefinition");
    GetFunctionDefinition(mxFunctionDefinitions, nLevel, nVersion, sbmlModel);

    mxEvents = mxGetField(mxModel[0], 0, "event");
    GetEvent(mxEvents, nLevel, nVersion, sbmlModel);

  }

  /* level 2 version 2-4 */
  if (nLevel == 2)
  {
    if (nVersion > 1)
    {
      /* get sboTerm */
      mxSBOTerm = mxGetField(mxModel[0], 0, "sboTerm");
      nSBOTerm = (int)mxGetScalar(mxSBOTerm);

      SBase_setSBOTerm((SBase_t *) (sbmlModel), nSBOTerm);

      mxCompartmentTypes = mxGetField(mxModel[0], 0, "compartmentType");
      GetCompartmentType(mxCompartmentTypes, nLevel, nVersion, sbmlModel);

      mxSpeciesTypes = mxGetField(mxModel[0], 0, "speciesType");
      GetSpeciesType(mxSpeciesTypes, nLevel, nVersion, sbmlModel);

      mxInitialAssignments = mxGetField(mxModel[0], 0, "initialAssignment");
      GetInitialAssignment(mxInitialAssignments, nLevel, nVersion, sbmlModel);

      mxConstraints = mxGetField(mxModel[0], 0, "constraint");
      GetConstraint(mxConstraints, nLevel, nVersion, sbmlModel);
    }
  }

  /* level 3 */
  if (nLevel == 3)
  {
    /* get sboTerm */
    mxSBOTerm = mxGetField(mxModel[0], 0, "sboTerm");
    nSBOTerm = (int)mxGetScalar(mxSBOTerm);

    SBase_setSBOTerm((SBase_t *) (sbmlModel), nSBOTerm);

    mxInitialAssignments = mxGetField(mxModel[0], 0, "initialAssignment");
    GetInitialAssignment(mxInitialAssignments, nLevel, nVersion, sbmlModel);

    mxConstraints = mxGetField(mxModel[0], 0, "constraint");
    GetConstraint(mxConstraints, nLevel, nVersion, sbmlModel);

    /* get substanceUnits */
    mxSubstanceUnits = mxGetField(mxModel[0], 0, "substanceUnits");
    nBuflen = (mxGetM(mxSubstanceUnits)*mxGetN(mxSubstanceUnits)+1);
    pacSubstanceUnits = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxSubstanceUnits, pacSubstanceUnits, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy substanceUnits");
    }

    Model_setSubstanceUnits(sbmlModel, pacSubstanceUnits);

    /* get timeUnits */
    mxTimeUnits = mxGetField(mxModel[0], 0, "timeUnits");
    nBuflen = (mxGetM(mxTimeUnits)*mxGetN(mxTimeUnits)+1);
    pacTimeUnits = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxTimeUnits, pacTimeUnits, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy timeUnits");
    }

    Model_setTimeUnits(sbmlModel, pacTimeUnits);

    /* get lengthUnits */
    mxLengthUnits = mxGetField(mxModel[0], 0, "lengthUnits");
    nBuflen = (mxGetM(mxLengthUnits)*mxGetN(mxLengthUnits)+1);
    pacLengthUnits = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxLengthUnits, pacLengthUnits, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy lengthUnits");
    }

    Model_setLengthUnits(sbmlModel, pacLengthUnits);

    /* get areaUnits */
    mxAreaUnits = mxGetField(mxModel[0], 0, "areaUnits");
    nBuflen = (mxGetM(mxAreaUnits)*mxGetN(mxAreaUnits)+1);
    pacAreaUnits = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxAreaUnits, pacAreaUnits, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy areaUnits");
    }

    Model_setAreaUnits(sbmlModel, pacAreaUnits);

    /* get volumeUnits */
    mxVolumeUnits = mxGetField(mxModel[0], 0, "volumeUnits");
    nBuflen = (mxGetM(mxVolumeUnits)*mxGetN(mxVolumeUnits)+1);
    pacVolumeUnits = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxVolumeUnits, pacVolumeUnits, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy volumeUnits");
    }

    Model_setVolumeUnits(sbmlModel, pacVolumeUnits);

    /* get extentUnits */
    mxExtentUnits = mxGetField(mxModel[0], 0, "extentUnits");
    nBuflen = (mxGetM(mxExtentUnits)*mxGetN(mxExtentUnits)+1);
    pacExtentUnits = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxExtentUnits, pacExtentUnits, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy extentUnits");
    }

    Model_setExtentUnits(sbmlModel, pacExtentUnits);

    /* get conversionFactor */
    mxConversionFactor = mxGetField(mxModel[0], 0, "conversionFactor");
    nBuflen = (mxGetM(mxConversionFactor)*mxGetN(mxConversionFactor)+1);
    pacConversionFactor = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxConversionFactor, pacConversionFactor, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy conversionFactor");
    }

    Model_setConversionFactor(sbmlModel, pacConversionFactor);
  }


  /* get annotations  */
  mxAnnotations = mxGetField(mxModel[0], 0, "annotation");
  nBuflen = (mxGetM(mxAnnotations)*mxGetN(mxAnnotations)+1);
  pacAnnotations = (char *)mxCalloc(nBuflen, sizeof(char));

  nStatus = mxGetString(mxAnnotations, pacAnnotations, (mwSize)(nBuflen));

  if (nStatus != 0)
  {
    mexErrMsgTxt("Cannot copy annotations");
  }

  SBase_setAnnotationString((SBase_t *) (sbmlModel), pacAnnotations); 

  if (fbcPresent == 1)
  {
#ifdef USE_FBC
    mxFluxBounds = mxGetField(mxModel[0], 0, "fbc_fluxBound");
    GetFluxBound(mxFluxBounds, nLevel, nVersion, nFBCVersion, sbmlModel);

    mxObjectives = mxGetField(mxModel[0], 0, "fbc_objective");
    GetObjective(mxObjectives, nLevel, nVersion, nFBCVersion, sbmlModel);

    /* get conversionFactor */
    mxActiveObjective = mxGetField(mxModel[0], 0, "fbc_activeObjective");
    nBuflen = (mxGetM(mxActiveObjective)*mxGetN(mxActiveObjective)+1);
    pacActiveObjective = (char *)mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxActiveObjective, pacActiveObjective, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy ActiveObjective");
    }

    FbcModelPlugin_setActiveObjectiveId(SBase_getPlugin((SBase_t *)(sbmlModel), "fbc"),
      pacActiveObjective);
#endif
  }


  /************************************************************************************************************
  * output the resulting model to specified file
  *********************************************************************************************************/

  if (nrhs == 1) 
  {
    /**
    * prompt user for a filename 
    * and write the document to this
    */

    /* extension to look for */
    mxExt[0] = mxCreateString(".xml");
    nStatus = mexCallMATLAB(2, mxFilename, 1, mxExt, "uiputfile");

    if (nStatus != 0)
    {
      mexErrMsgTxt("Failed to read filename");
    }

    pacFilename = readUnicodeStringFromArrays(mxFilename);

#if USE_FILE_WCHAR
    if (wcsstr(pacFilename, L".xml") == NULL)
    {
      wcscat(pacFilename, L".xml");
    }
#else
    /* check that the extension has been used  */
    if (strstr(pacFilename, ".xml") == NULL)
    {
      strcat(pacFilename, ".xml");
    }
#endif
  }
  else
  {
    /* 
    * user has specified a filename	  
    * check that the extension has been used  
    */
#if USE_FILE_WCHAR
    if (wcsstr(pacFilename, L".xml") == NULL)
    {
      wcscat(pacFilename, L".xml");
    }
#else
    /* check that the extension has been used  */
    if (strstr(pacFilename, ".xml") == NULL)
    {
      strcat(pacFilename, ".xml");
    }
#endif
  }



  /* write the SBML document to the filename specified */
#if USE_FILE_WCHAR
  {
    char* sbml = writeSBMLToString(sbmlDocument);
    size_t len = strlen(sbml);
    FILE* fp = _wfopen(pacFilename, L"w");
    fwrite(sbml, sizeof(char), len, fp);
    fclose(fp);
    free(sbml);
    nStatus = 1;
  }
#else
  nStatus = writeSBML(sbmlDocument, pacFilename);
#endif
  /* don't output messages from installer tests */
  if (inInstaller == 0)
  {
    if (nStatus != 1)
    {
      mexErrMsgTxt("Failed to write file");
    }
    else
    {
      mexPrintf("Document written\n");
    }
  }

  /* free any memory allocated */
  mxFree(pacNotes);
  mxFree(pacAnnotations);
  mxFree(pacName);
  if (nLevel > 1)
  {
    mxFree(pacMetaid);
    mxFree(pacId);
  }
  if (nLevel == 3)
  {
    mxFree(pacSubstanceUnits);
    mxFree(pacTimeUnits);
    mxFree(pacLengthUnits);
    mxFree(pacAreaUnits);
    mxFree(pacVolumeUnits);
    mxFree(pacExtentUnits);
    mxFree(pacConversionFactor);
  }

  if (nrhs == 1)
  {
    mxFree(pacTempString1);
    mxFree(pacTempString2);
    mxFree(pacFilename);
    mxDestroyArray(mxFilename[0]);
    mxDestroyArray(mxFilename[1]);
    mxDestroyArray(mxExt[0]);
  }
  mxDestroyArray(mxCheckStructure[0]);

  SBMLDocument_free(sbmlDocument);
}

/**
 * NAME:    LookForCSymbolTime
 *
 * PARAMETERS:  ASTNode_t * 
 *
 * RETURNS:   
 *
 * FUNCTION:  replaces the csymbol time in this function
 */
void
LookForCSymbolTime(ASTNode_t * math)
{
  /*const char * time = "my_time";*/
  unsigned int i;

  if (math == NULL)
  {
    return;
  }

  if (ASTNode_getType(math) == AST_NAME)
  {
    if (!strcmp(ASTNode_getName(math), timeSymbol))
    {
      ASTNode_setType(math, AST_NAME_TIME);
    }
  }

  for (i = 0; i < ASTNode_getNumChildren(math); i++)
  {
    LookForCSymbolTime(ASTNode_getChild(math, i));
  }
}

/**
 * NAME:    LookForCSymbolTime
 *
 * PARAMETERS:  ASTNode_t * 
 *
 * RETURNS:   
 *
 * FUNCTION:  replaces the csymbol time in this function
 */
void
LookForCSymbolDelay(ASTNode_t * math)
{
  /*const char * time = "my_time";*/
  unsigned int i;

  if (math == NULL)
  {
    return;
  }

  if (ASTNode_getType(math) == AST_FUNCTION)
  {
    if (!strcmp(ASTNode_getName(math), delaySymbol))
    {
      ASTNode_setType(math, AST_FUNCTION_DELAY);
    }
  }

  for (i = 0; i < ASTNode_getNumChildren(math); i++)
  {
    LookForCSymbolDelay(ASTNode_getChild(math, i));
  }
}

/**
 * NAME:    LookForCSymbolAvo
 *
 * PARAMETERS:  ASTNode_t * 
 *
 * RETURNS:   
 *
 * FUNCTION:  replaces the csymbol avogadro in this function
 */
void
LookForCSymbolAvo(ASTNode_t * math)
{
  /*const char * time = "my_time";*/
  unsigned int i;

  if (math == NULL)
  {
    return;
  }

  if (ASTNode_getType(math) == AST_NAME)
  {
    if (!strcmp(ASTNode_getName(math), avoSymbol))
    {
      ASTNode_setType(math, AST_NAME_AVOGADRO);
    }
  }

  for (i = 0; i < ASTNode_getNumChildren(math); i++)
  {
    LookForCSymbolAvo(ASTNode_getChild(math, i));
  }
}

/**
 * NAME:    CharToTypecode
 *
 * PARAMETERS:  char * 
 *
 * RETURNS:    SBMLTypeCode_t typecode
 *
 * FUNCTION:  converts typecode string to SBMLTypeCode
 */
SBMLTypeCode_t
CharToTypecode (char * pacTypecode)
{
	SBMLTypeCode_t typecode = SBML_UNKNOWN;
	unsigned int nIndex;

	const char * Typecodes[] =
	{
		"SBML_ASSIGNMENT_RULE",
		"SBML_ALGEBRAIC_RULE",
		"SBML_RATE_RULE",
		"SBML_SPECIES_CONCENTRATION_RULE",
		"SBML_COMPARTMENT_VOLUME_RULE",
		"SBML_PARAMETER_RULE",
	};

	nIndex = 0;
	while (nIndex < 6)
	{
		if (strcmp(pacTypecode, Typecodes[nIndex]) == 0)
		{
			break;
		}
		nIndex++;
	}

  switch (nIndex)
  {
    case 0:
      typecode = SBML_ASSIGNMENT_RULE;
      break;

    case 1:
      typecode = SBML_ALGEBRAIC_RULE;
      break;

    case 2:
      typecode = SBML_RATE_RULE;
      break;

    case 3:
      typecode = SBML_SPECIES_CONCENTRATION_RULE;
      break;

    case 4:
      typecode = SBML_COMPARTMENT_VOLUME_RULE;
      break;

    case 5:
      typecode = SBML_PARAMETER_RULE;
      break;

    default:
      mexErrMsgTxt("error in typecode");
      break;
  }

  return typecode;
}

void
GetNamespaces (mxArray * mxNamespaces,
			         SBMLNamespaces_t * pNamespaces)
{
	size_t nNoNamespaces = mxGetNumberOfElements(mxNamespaces);

	int nStatus;
	size_t nBuflen;

	/* field values */
	char * pacURI;
	char * pacPrefix;
	const char * pacURIconst;
	const char * pacPrefixconst;
  XMLNamespaces_t * xmlns;

	mxArray * mxURI, * mxPrefix;
	
	size_t i;

  xmlns = XMLNamespaces_create();
	for (i = 0; i < nNoNamespaces; i++) {

		/* get uri */
		mxURI = mxGetField(mxNamespaces, i, "uri");
		nBuflen = (mxGetM(mxURI)*mxGetN(mxURI)+1);
		pacURI = (char *)mxCalloc(nBuflen, sizeof(char));
		nStatus = mxGetString(mxURI, pacURI, (mwSize)(nBuflen));

		if (nStatus != 0)
		{
			mexErrMsgTxt("Cannot copy uri");
		}


		/* get prefix */
		mxPrefix = mxGetField(mxNamespaces, i, "prefix");
		nBuflen = (mxGetM(mxPrefix)*mxGetN(mxPrefix)+1);
		pacPrefix = (char *)mxCalloc(nBuflen, sizeof(char));
		nStatus = mxGetString(mxPrefix, pacPrefix, (mwSize)(nBuflen));

		if (nStatus != 0)
		{
			mexErrMsgTxt("Cannot copy prefix");
		}


		/* add the namespaces to the model */
    pacURIconst = pacURI;
    pacPrefixconst = pacPrefix;
		XMLNamespaces_add(xmlns, pacURIconst, pacPrefixconst);

    /* free any memory allocated */
	  mxFree(pacURI);
	  mxFree(pacPrefix);
	}
	
  SBMLNamespaces_addNamespaces(pNamespaces, xmlns);
}

/**
 * NAME:    GetCompartment
 *
 * PARAMETERS:  mxArray of compartment structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the compartment mxArray structure
 *        and adds each compartment to the model
 *
 */
void
GetCompartment ( mxArray * mxCompartments,
                 unsigned int unSBMLLevel,
                 unsigned int unSBMLVersion, 
                 Model_t * sbmlModel)
{
  size_t nNoCompartments = mxGetNumberOfElements(mxCompartments);

  /* field values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacName;
  char * pacId;
  char * pacCompartmentType;
  double dVolume;
  unsigned int unSpatialDimensions;
  double dSpatialDimensions;
  double dSize;
  char * pacUnits;
  char * pacOutside;
  int nConstant;
  unsigned int unIsSetVolume;
  unsigned int unIsSetSize;
  unsigned int unIsSetSpatialDimensions;
  int nSBOTerm;
  char * pacMetaid;

  mxArray *mxIsSetSpatialDimensions;
  mxArray * mxVolume, * mxIsSetVolume, * mxSpatialDimensions;
  mxArray * mxSize, * mxConstant, * mxIsSetSize, * mxSBOTerm;


  Compartment_t *pCompartment;
  size_t i;

  for (i = 0; i < nNoCompartments; i++) {

    pCompartment = Model_createCompartment(sbmlModel);


    /* get notes */
    pacNotes = ReadString(mxCompartments, "notes", "compartment", i, nNoCompartments);
    SBase_setNotesString((SBase_t *) (pCompartment), pacNotes); 


    /* get name */
    pacName = ReadString(mxCompartments, "name", "compartment", i, nNoCompartments);
    Compartment_setName(pCompartment, pacName);


    /* get units */
    pacUnits = ReadString(mxCompartments, "units", "compartment", i, nNoCompartments);
    Compartment_setUnits(pCompartment, pacUnits);

    /* out of L3 */

    if (unSBMLLevel < 3)
    {
      /* get outside */
      pacOutside = ReadString(mxCompartments, "outside", "compartment", i, nNoCompartments);
      Compartment_setOutside(pCompartment, pacOutside);


      /* get isSetVolume */
      mxIsSetVolume = mxGetField(mxCompartments, i, "isSetVolume");
      unIsSetVolume = (unsigned int)mxGetScalar(mxIsSetVolume);

    }

    /* level 1 only */
    if (unSBMLLevel == 1)
    {
      /* get volume */
      mxVolume = mxGetField(mxCompartments, i, "volume");
      dVolume = mxGetScalar(mxVolume);

      if (unIsSetVolume == 1) {
        Compartment_setVolume(pCompartment, dVolume);
      }

    }

    /* level 2 only */
    if (unSBMLLevel == 2)
    {
      /* get metaid */
      pacMetaid = ReadString(mxCompartments, "metaid", "compartment", i, nNoCompartments);
      SBase_setMetaId((SBase_t *) (pCompartment), pacMetaid);

      /* get id */
      pacId = ReadString(mxCompartments, "id", "compartment", i, nNoCompartments);
      Compartment_setId(pCompartment, pacId);

      /* get constant */
      mxConstant = mxGetField(mxCompartments, i, "constant");
      nConstant = (int)mxGetScalar(mxConstant);

      Compartment_setConstant(pCompartment, nConstant);

      /* get spatialdimensions */
      mxSpatialDimensions = mxGetField(mxCompartments, i, "spatialDimensions");
      unSpatialDimensions = (unsigned int)mxGetScalar(mxSpatialDimensions);

      Compartment_setSpatialDimensions(pCompartment, unSpatialDimensions);

      /* get isSetSize */
      mxIsSetSize = mxGetField(mxCompartments, i, "isSetSize");
      unIsSetSize = (unsigned int)mxGetScalar(mxIsSetSize);


      /* get size */
      mxSize = mxGetField(mxCompartments, i, "size");
      dSize = mxGetScalar(mxSize);

      if (unIsSetSize == 1) {
        Compartment_setSize(pCompartment, dSize);
      }

      /* level 2 version 2 onwards */
      if (unSBMLVersion > 1)
      {
        /* get compartmentType */
        pacCompartmentType = ReadString(mxCompartments, "compartmentType", "compartment", i, nNoCompartments);
        Compartment_setCompartmentType(pCompartment, pacCompartmentType);

      }
      /* level 2 version 3 + */
      if (unSBMLVersion > 2)
      {
        /* get sboTerm */
        mxSBOTerm = mxGetField(mxCompartments, i, "sboTerm");
        nSBOTerm = (int)mxGetScalar(mxSBOTerm);

        SBase_setSBOTerm((SBase_t *) (pCompartment), nSBOTerm);
      }
    }
    /* level 3 only */
    else if (unSBMLLevel == 3)
    {
      /* get metaid */
      pacMetaid = ReadString(mxCompartments, "metaid", "compartment", i, nNoCompartments);
      SBase_setMetaId((SBase_t *) (pCompartment), pacMetaid);

      /* get id */
      pacId = ReadString(mxCompartments, "id", "compartment", i, nNoCompartments);
      Compartment_setId(pCompartment, pacId);


      /* get constant */
      mxConstant = mxGetField(mxCompartments, i, "constant");
      nConstant = (int)mxGetScalar(mxConstant);

      Compartment_setConstant(pCompartment, nConstant);

      /* get isSetSpatialDimensions */
      mxIsSetSpatialDimensions = mxGetField(mxCompartments, i, "isSetSpatialDimensions");
      unIsSetSpatialDimensions = (unsigned int)mxGetScalar(mxIsSetSpatialDimensions);

      /* get spatialdimensions */
      mxSpatialDimensions = mxGetField(mxCompartments, i, "spatialDimensions");
      dSpatialDimensions = mxGetScalar(mxSpatialDimensions);

      if (unIsSetSpatialDimensions == 1)
      {
        Compartment_setSpatialDimensionsAsDouble(pCompartment, dSpatialDimensions);
      }

      /* get isSetSize */
      mxIsSetSize = mxGetField(mxCompartments, i, "isSetSize");
      unIsSetSize = (unsigned int)mxGetScalar(mxIsSetSize);


      /* get size */
      mxSize = mxGetField(mxCompartments, i, "size");
      dSize = mxGetScalar(mxSize);

      if (unIsSetSize == 1) {
        Compartment_setSize(pCompartment, dSize);
      }

      /* get sboTerm */
      mxSBOTerm = mxGetField(mxCompartments, i, "sboTerm");
      nSBOTerm = (int)mxGetScalar(mxSBOTerm);

      SBase_setSBOTerm((SBase_t *) (pCompartment), nSBOTerm);
    }

    /* get annotations */
    pacAnnotations = ReadString(mxCompartments, "annotation", "compartment", i, nNoCompartments);
    SBase_setAnnotationString((SBase_t *) (pCompartment), pacAnnotations); 


    /* free any memory allocated */
    mxFree(pacNotes);
    mxFree(pacAnnotations);
    mxFree(pacName);
    mxFree(pacUnits);
    if (unSBMLLevel == 1)
    {
      mxFree(pacOutside);
    }
    /* level 2 only */
    else if (unSBMLLevel == 2)
    {
      mxFree(pacOutside);
      mxFree(pacId);
      mxFree(pacMetaid);
      if (unSBMLVersion > 1)
      {
        mxFree(pacCompartmentType);
      }
    }
    else if (unSBMLLevel == 3)
    {
      mxFree(pacId);
      mxFree(pacMetaid);
    }
  }
}

/**
 * NAME:    GetUnitDefinition
 *
 * PARAMETERS:  mxArray of unitdefinition structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the unit definition mxArray structure
 *        and adds each unitdefinition to the model
 */
void
GetUnitDefinition ( mxArray * mxUnitDefinitions,
                    unsigned int unSBMLLevel,
                    unsigned int unSBMLVersion, 
                    Model_t * sbmlModel )
{
  size_t nNoUnitDefinitions = mxGetNumberOfElements(mxUnitDefinitions);

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacName;
  char * pacId = NULL;
  int nSBOTerm;
  char * pacMetaid;

  mxArray * mxSBOTerm, * mxUnits;

  UnitDefinition_t *pUnitDefinition;
  size_t i;


  for (i = 0; i < nNoUnitDefinitions; i++) 
  {
    pUnitDefinition = Model_createUnitDefinition(sbmlModel);

    /* get notes */
    pacNotes = ReadString(mxUnitDefinitions, "notes", "unitDefinition", i, nNoUnitDefinitions);
    SBase_setNotesString((SBase_t *) (pUnitDefinition), pacNotes); 


    /* get name */
    pacName = ReadString(mxUnitDefinitions, "name", "unitDefinition", i, nNoUnitDefinitions);
    UnitDefinition_setName(pUnitDefinition, pacName);


    /* get list of units */
    mxUnits = mxGetField(mxUnitDefinitions, i, "unit");
    GetUnit(mxUnits, unSBMLLevel, unSBMLVersion, pUnitDefinition);


    /* level 2 only */
    if (unSBMLLevel > 1)
    {
      /* get metaid */
      pacMetaid = ReadString(mxUnitDefinitions, "metaid", "unitDefinition", i, nNoUnitDefinitions);
      SBase_setMetaId((SBase_t *) (pUnitDefinition), pacMetaid);

      /* get id */
      pacId = ReadString(mxUnitDefinitions, "id", "unitDefinition", i, nNoUnitDefinitions);
      UnitDefinition_setId(pUnitDefinition, pacId);

      /* level 2 version 3 only */
      if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2)
      {
        /* get sboTerm */
        mxSBOTerm = mxGetField(mxUnitDefinitions, i, "sboTerm");
        nSBOTerm = (int)mxGetScalar(mxSBOTerm);

        SBase_setSBOTerm((SBase_t *) (pUnitDefinition), nSBOTerm);
      }
    }

    /* get annotations */
    pacAnnotations = ReadString(mxUnitDefinitions, "annotation", "unitDefinition", i, nNoUnitDefinitions);
    SBase_setAnnotationString((SBase_t *) (pUnitDefinition), pacAnnotations); 


    /* free any memory allocated */
    mxFree(pacNotes);
    mxFree(pacAnnotations);
    mxFree(pacName);
    /* level 2 only */
    if (unSBMLLevel > 1)
    {
      mxFree(pacId);
      mxFree(pacMetaid);
    }

  }
}

/**
 * NAME:    GetUnit
 *
 * PARAMETERS:  mxArray of unit structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the unit definition
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the unit mxArray structure
 *        and adds each unit to the unitdefinition
 */
void
GetUnit ( mxArray * mxUnits,
          unsigned int unSBMLLevel,
          unsigned int unSBMLVersion, 
          UnitDefinition_t * sbmlUnitDefinition )
{
  size_t nNoUnits = mxGetNumberOfElements(mxUnits);

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacKind;
  int nExponent;
  int nScale;
  double dMultiplier;
  double dOffset;
  double dExponent;
  int nSBOTerm;
  char * pacMetaid;

  mxArray * mxExponent;
  mxArray * mxScale, * mxMultiplier, * mxOffset, * mxSBOTerm;

  Unit_t *pUnit;
  size_t i;


  for (i = 0; i < nNoUnits; i++) 
  {
    pUnit = UnitDefinition_createUnit(sbmlUnitDefinition);

    /* get notes */
    pacNotes = ReadString(mxUnits, "notes", "unit", i, nNoUnits);
    SBase_setNotesString((SBase_t *) (pUnit), pacNotes); 


    /* get kind */
    pacKind = ReadString(mxUnits, "kind", "unit", i, nNoUnits);
    Unit_setKind(pUnit, UnitKind_forName(pacKind));


    /* get scale */
    mxScale = mxGetField(mxUnits, i, "scale");
    nScale = (int)mxGetScalar(mxScale);

    Unit_setScale(pUnit, nScale);


    /* level 2 only */
    if (unSBMLLevel == 2)
    {
      /* get metaid */
      pacMetaid = ReadString(mxUnits, "metaid", "unit", i, nNoUnits);
      SBase_setMetaId((SBase_t *) (pUnit), pacMetaid);

      /* get multiplier */
      mxMultiplier = mxGetField(mxUnits, i, "multiplier");
      dMultiplier = mxGetScalar(mxMultiplier);

      Unit_setMultiplier(pUnit, dMultiplier);

      /* level 2 version 1 only */
      if (unSBMLVersion == 1)
      {
        /* get offset */
        mxOffset = mxGetField(mxUnits, i, "offset");
        dOffset = mxGetScalar(mxOffset);

        Unit_setOffset(pUnit, dOffset);
      }

      /* level 2 version 3 only */
      if (unSBMLVersion == 3)
      {
        /* get sboTerm */
        mxSBOTerm = mxGetField(mxUnits, i, "sboTerm");
        nSBOTerm = (int)mxGetScalar(mxSBOTerm);

        SBase_setSBOTerm((SBase_t *) (pUnit), nSBOTerm);
      }
    }
    else if (unSBMLLevel == 3)
    {
      /* get metaid */
      pacMetaid = ReadString(mxUnits, "metaid", "unit", i, nNoUnits);
      SBase_setMetaId((SBase_t *) (pUnit), pacMetaid);

      /* get multiplier */
      mxMultiplier = mxGetField(mxUnits, i, "multiplier");
      dMultiplier = mxGetScalar(mxMultiplier);

      Unit_setMultiplier(pUnit, dMultiplier);

      /* get sboTerm */
      mxSBOTerm = mxGetField(mxUnits, i, "sboTerm");
      nSBOTerm = (int)mxGetScalar(mxSBOTerm);

      SBase_setSBOTerm((SBase_t *) (pUnit), nSBOTerm);
    }

    if (unSBMLLevel < 3)
    {
      /* get exponent */
      mxExponent = mxGetField(mxUnits, i, "exponent");
      nExponent = (int)mxGetScalar(mxExponent);

      Unit_setExponent(pUnit, nExponent);
    }
    else
    {
      /* get exponent */
      mxExponent = mxGetField(mxUnits, i, "exponent");
      dExponent = mxGetScalar(mxExponent);

      Unit_setExponentAsDouble(pUnit, dExponent);
    }


    /* get annotations */
    pacAnnotations = ReadString(mxUnits, "annotation", "unit", i, nNoUnits);
    SBase_setAnnotationString((SBase_t *) (pUnit), pacAnnotations); 


    /* free any memory allocated */
    mxFree(pacNotes);
    mxFree(pacAnnotations);
    mxFree(pacKind);
    if (unSBMLLevel > 1)
    {
      mxFree(pacMetaid);
    }
  }
}

/**
 * NAME:    GetSpecies
 *
 * PARAMETERS:  mxArray of species structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the species mxArray structure
 *        and adds each species to the model
 *
 */
 void
 GetSpecies ( mxArray * mxSpecies,
              unsigned int unSBMLLevel,
              unsigned int unSBMLVersion, 
              Model_t * sbmlModel)
 {
   size_t nNoSpecies = mxGetNumberOfElements(mxSpecies);

   char * pacNotes;
   char * pacAnnotations;
   char * pacName;
   char * pacId;
   char * pacCompartment;
   char * pacSpeciesType = NULL;
   double dInitialAmount;
   double dInitialConcentration;
   char * pacUnits;
   char * pacSubstanceUnits;
   char * pacSpatialSizeUnits = NULL;
   int nHasOnlySubsUnits;
   int nBoundaryCondition;
   int nCharge;
   int nConstant;
   int nSBOTerm;
   unsigned int unIsSetInit;
   unsigned int unIsSetInitConc;
   unsigned int unIsSetCharge;
   char * pacMetaid;
   char * pacConversionFactor;
   char * pacChemicalFormula = NULL;

   mxArray * mxInitialAmount;
   mxArray * mxInitialConcentration, * mxHasOnlySubstance;
   mxArray * mxBoundaryCondition, * mxCharge, * mxSBOTerm;
   mxArray * mxConstant, * mxIsSetInitialAmt, * mxIsSetInitialConc, * mxIsSetCharge;

   SBasePlugin_t *plugin;

   Species_t *pSpecies;

   size_t i;

   for (i = 0; i < nNoSpecies; i++) 
   {

     pSpecies = Model_createSpecies(sbmlModel);

     /* get notes */
     pacNotes = ReadString(mxSpecies, "notes", "species", i, nNoSpecies);
     SBase_setNotesString((SBase_t *) (pSpecies), pacNotes);


     /* get name */
     pacName = ReadString(mxSpecies, "name", "species", i, nNoSpecies);
     Species_setName(pSpecies, pacName);


     /* get Compartment */
     pacCompartment = ReadString(mxSpecies, "compartment", "species", i, nNoSpecies);
     Species_setCompartment(pSpecies, pacCompartment);


     /* get isSetInitialAmount */
     mxIsSetInitialAmt = mxGetField(mxSpecies, i, "isSetInitialAmount");
     unIsSetInit = (unsigned int)mxGetScalar(mxIsSetInitialAmt);


     /* get initial amount */
     mxInitialAmount = mxGetField(mxSpecies, i, "initialAmount");
     dInitialAmount = mxGetScalar(mxInitialAmount);

     if (unIsSetInit == 1) {
       Species_setInitialAmount(pSpecies, dInitialAmount);
     }


     /* get boundary condition */
     mxBoundaryCondition = mxGetField(mxSpecies, i, "boundaryCondition");
     nBoundaryCondition = (int)mxGetScalar(mxBoundaryCondition);

     Species_setBoundaryCondition(pSpecies, nBoundaryCondition);

     if (unSBMLLevel < 3)
     {
       /* get isSetCharge */
       mxIsSetCharge = mxGetField(mxSpecies, i, "isSetCharge");
       unIsSetCharge = (unsigned int)mxGetScalar(mxIsSetCharge);


       /* get charge */
       mxCharge = mxGetField(mxSpecies, i, "charge");
       nCharge = (int)mxGetScalar(mxCharge);

       if (unIsSetCharge == 1) {
         Species_setCharge(pSpecies, nCharge);
       }
     }

     /* level 1 only */
     if (unSBMLLevel == 1)
     {
       /* get units */
       pacUnits = ReadString(mxSpecies, "units", "species", i, nNoSpecies);
       Species_setUnits(pSpecies, pacUnits);
     }


     /* level 2 */
     if (unSBMLLevel == 2)
     {
       /* get metaid */
       pacMetaid = ReadString(mxSpecies, "metaid", "species", i, nNoSpecies);
       SBase_setMetaId((SBase_t *) (pSpecies), pacMetaid);

       /* get id */
       pacId = ReadString(mxSpecies, "id", "species", i, nNoSpecies);
       Species_setId(pSpecies, pacId);

       /* get isSetInitialConcentration */
       mxIsSetInitialConc = mxGetField(mxSpecies, i, "isSetInitialConcentration");
       unIsSetInitConc = (unsigned int)mxGetScalar(mxIsSetInitialConc);


       /* get initial concentration */
       mxInitialConcentration = mxGetField(mxSpecies, i, "initialConcentration");
       dInitialConcentration = mxGetScalar(mxInitialConcentration);

       if (unIsSetInitConc == 1) {
         Species_setInitialConcentration(pSpecies, dInitialConcentration);
       }

       /* get substance units */
       pacSubstanceUnits = ReadString(mxSpecies, "substanceUnits", "species", i, nNoSpecies);
       Species_setSubstanceUnits(pSpecies, pacSubstanceUnits);


       /* get HasOnlySubstanceUnits */
       mxHasOnlySubstance = mxGetField(mxSpecies, i, "hasOnlySubstanceUnits");
       nHasOnlySubsUnits = (int)mxGetScalar(mxHasOnlySubstance);

       Species_setHasOnlySubstanceUnits(pSpecies, nHasOnlySubsUnits);


       /* get constant */
       mxConstant = mxGetField(mxSpecies, i, "constant");
       nConstant = (int)mxGetScalar(mxConstant);

       Species_setConstant(pSpecies, nConstant);

       /* level 2 version 1/2 only */
       if (unSBMLVersion < 3)
       {
         /* get spatial size units */
         pacSpatialSizeUnits = ReadString(mxSpecies, "spatialSizeUnits", "species", i, nNoSpecies);
         Species_setSpatialSizeUnits(pSpecies, pacSpatialSizeUnits);
       }

       /* level 2 version 2 onwards */
       if (unSBMLVersion > 1)
       {
         /* get speciesType */
         pacSpeciesType = ReadString(mxSpecies, "speciesType", "species", i, nNoSpecies);
         Species_setSpeciesType(pSpecies, pacSpeciesType);
       }
       /* level 2 version 3 on */
       if (unSBMLVersion > 2)
       {
         /* get sboTerm */
         mxSBOTerm = mxGetField(mxSpecies, i, "sboTerm");
         nSBOTerm = (int)mxGetScalar(mxSBOTerm);

         SBase_setSBOTerm((SBase_t *) (pSpecies), nSBOTerm);
       }	
     }
     else if (unSBMLLevel == 3)
     {
       /* get metaid */
       pacMetaid = ReadString(mxSpecies, "metaid", "species", i, nNoSpecies);
       SBase_setMetaId((SBase_t *) (pSpecies), pacMetaid);

       /* get id */
       pacId = ReadString(mxSpecies, "id", "species", i, nNoSpecies);
       Species_setId(pSpecies, pacId);

       /* get isSetInitialConcentration */
       mxIsSetInitialConc = mxGetField(mxSpecies, i, "isSetInitialConcentration");
       unIsSetInitConc = (unsigned int)mxGetScalar(mxIsSetInitialConc);


       /* get initial concentration */
       mxInitialConcentration = mxGetField(mxSpecies, i, "initialConcentration");
       dInitialConcentration = mxGetScalar(mxInitialConcentration);

       if (unIsSetInitConc == 1) {
         Species_setInitialConcentration(pSpecies, dInitialConcentration);
       }

       /* get substance units */
       pacSubstanceUnits = ReadString(mxSpecies, "substanceUnits", "species", i, nNoSpecies);
       Species_setSubstanceUnits(pSpecies, pacSubstanceUnits);


       /* get HasOnlySubstanceUnits */
       mxHasOnlySubstance = mxGetField(mxSpecies, i, "hasOnlySubstanceUnits");
       nHasOnlySubsUnits = (int)mxGetScalar(mxHasOnlySubstance);

       Species_setHasOnlySubstanceUnits(pSpecies, nHasOnlySubsUnits);


       /* get constant */
       mxConstant = mxGetField(mxSpecies, i, "constant");
       nConstant = (int)mxGetScalar(mxConstant);

       Species_setConstant(pSpecies, nConstant);

       /* get sboTerm */
       mxSBOTerm = mxGetField(mxSpecies, i, "sboTerm");
       nSBOTerm = (int)mxGetScalar(mxSBOTerm);

       SBase_setSBOTerm((SBase_t *) (pSpecies), nSBOTerm);

       /* getConversionFactor */
       pacConversionFactor = ReadString(mxSpecies, "conversionFactor", "species", i, nNoSpecies);
       Species_setConversionFactor(pSpecies, pacConversionFactor);
     }


     /* get annotations */
     pacAnnotations = ReadString(mxSpecies, "annotation", "species", i, nNoSpecies);
     SBase_setAnnotationString((SBase_t *) (pSpecies), pacAnnotations); 

     if (fbcPresent == 1)
     {
#ifdef USE_FBC
       plugin = SBase_getPlugin((SBase_t *)(pSpecies), "fbc");

       /* get isSetCharge */
       mxIsSetCharge = mxGetField(mxSpecies, i, "isSetfbc_charge");
       unIsSetCharge = (unsigned int)mxGetScalar(mxIsSetCharge);


       if (unIsSetCharge == 1) 
       { /* get charge */
         mxCharge = mxGetField(mxSpecies, i, "fbc_charge");
         nCharge = (int)mxGetScalar(mxCharge);

         FbcSpeciesPlugin_setCharge(plugin, nCharge);
       }

       /* getChemicalFormula */
       pacChemicalFormula = ReadString(mxSpecies, "fbc_chemicalFormula", "species", i, nNoSpecies);
       FbcSpeciesPlugin_setChemicalFormula(plugin, pacChemicalFormula);
#endif
     }



     /* free any memory allocated */
     mxFree(pacNotes);
     mxFree(pacAnnotations);
     mxFree(pacName);
     mxFree(pacCompartment);
     /* level 1 only */
     if (unSBMLLevel == 1)
     {
       mxFree(pacUnits);
     }
     /* level 2 only */
     else if (unSBMLLevel == 2)
     {
       mxFree(pacMetaid);
       mxFree(pacId);
       mxFree(pacSubstanceUnits);
       if (unSBMLVersion < 3)
       {
         mxFree(pacSpatialSizeUnits);
       }
       if (unSBMLVersion > 1)
       {
         mxFree(pacSpeciesType);
       }
     }
     else if (unSBMLLevel == 3)
     {
       mxFree(pacMetaid);
       mxFree(pacId);
       mxFree(pacSubstanceUnits);
       mxFree(pacConversionFactor);
       if (fbcPresent)
         mxFree(pacChemicalFormula);
     }
   }
 }

/**
 * NAME:    GetParameter
 *
 * PARAMETERS:  mxArray of parameter structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the parameter mxArray structure
 *        and adds each parameter to the model
 *
 */
 void
 GetParameter ( mxArray * mxParameters,
                unsigned int unSBMLLevel,
                unsigned int unSBMLVersion, 
                Model_t * sbmlModel)
 {
   size_t nNoParameters = mxGetNumberOfElements(mxParameters);

   char * pacNotes;
   char * pacAnnotations;
   char * pacName;
   char * pacId;
   double dValue;
   char * pacUnits;
   unsigned int unIsSetValue;
   int nSBOTerm;
   int nConstant;
   char * pacMetaid;

   mxArray * mxValue, * mxIsSetValue, * mxConstant, * mxSBOTerm;

   Parameter_t *pParameter;

   size_t i;

   for (i = 0; i < nNoParameters; i++) 
   {

     pParameter = Model_createParameter(sbmlModel);

     /* get notes */
     pacNotes = ReadString(mxParameters, "notes", "parameter", i, nNoParameters);
     SBase_setNotesString((SBase_t *) (pParameter), pacNotes); 


     /* get name */
     pacName = ReadString(mxParameters, "name", "parameter", i, nNoParameters);
     Parameter_setName(pParameter, pacName);


     /* get units */
     pacUnits = ReadString(mxParameters, "units", "parameter", i, nNoParameters);
     Parameter_setUnits(pParameter, pacUnits);


     /* get isSetValue */
     mxIsSetValue = mxGetField(mxParameters, i, "isSetValue");
     unIsSetValue = (unsigned int)mxGetScalar(mxIsSetValue);


     /* get value */
     mxValue = mxGetField(mxParameters, i, "value");
     dValue = mxGetScalar(mxValue);

     if (unIsSetValue == 1) {
       Parameter_setValue(pParameter, dValue);
     }


     /* level 2 */
     if (unSBMLLevel == 2)
     {
       /* get metaid */
       pacMetaid = ReadString(mxParameters, "metaid", "parameter", i, nNoParameters);
       SBase_setMetaId((SBase_t *) (pParameter), pacMetaid);

       /* get id */
       pacId = ReadString(mxParameters, "id", "parameter", i, nNoParameters);
       Parameter_setId(pParameter, pacId);

       /* get constant */
       mxConstant = mxGetField(mxParameters, i, "constant");
       nConstant = (int)mxGetScalar(mxConstant);

       Parameter_setConstant(pParameter, nConstant);

       /* level 2 version 2 onwards */
       if (unSBMLVersion > 1) 
       {
         /* get sboTerm */
         mxSBOTerm = mxGetField(mxParameters, i, "sboTerm");
         nSBOTerm = (int)mxGetScalar(mxSBOTerm);

         SBase_setSBOTerm((SBase_t *) (pParameter), nSBOTerm);
       }	
     }
     else if (unSBMLLevel == 3)
     {
       /* get metaid */
       pacMetaid = ReadString(mxParameters, "metaid", "parameter", i, nNoParameters);
       SBase_setMetaId((SBase_t *) (pParameter), pacMetaid);

       /* get id */
       pacId = ReadString(mxParameters, "id", "parameter", i, nNoParameters);
       Parameter_setId(pParameter, pacId);


       /* get constant */
       mxConstant = mxGetField(mxParameters, i, "constant");
       nConstant = (int)mxGetScalar(mxConstant);

       Parameter_setConstant(pParameter, nConstant);

       /* get sboTerm */
       mxSBOTerm = mxGetField(mxParameters, i, "sboTerm");
       nSBOTerm = (int)mxGetScalar(mxSBOTerm);

       SBase_setSBOTerm((SBase_t *) (pParameter), nSBOTerm);
     }


     /* get annotations */
     pacAnnotations = ReadString(mxParameters, "annotation", "parameter", i, nNoParameters);
     SBase_setAnnotationString((SBase_t *) (pParameter), pacAnnotations);


     /* free any memory allocated */
     mxFree(pacNotes);
     mxFree(pacAnnotations);
     mxFree(pacName);
     mxFree(pacUnits);
     /* level 2 only */
     if (unSBMLLevel > 1)
     {
       mxFree(pacMetaid);
       mxFree(pacId);
     }
   }

 }

/**
 * NAME:    GetRule
 *
 * PARAMETERS:  mxArray of Rule structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the Rule mxArray structure
 *        and adds each Rule to the model
 *
 */
 void
 GetRule ( mxArray * mxRule,
           unsigned int unSBMLLevel,
           unsigned int unSBMLVersion, 
           Model_t * sbmlModel)
 {
   size_t nNoRules = mxGetNumberOfElements(mxRule);

   int nStatus;
   size_t nBuflen;

   char * pacTypecode;
   char * pacNotes;
   char * pacAnnotations;
   char * pacType = NULL;
   char * pacFormula;
   char * pacVariable;
   char * pacSpecies;
   char * pacCompartment;
   char * pacName;
   char * pacUnits;
   int nSBOTerm = -1;
   char * pacMetaid = NULL;

   mxArray * mxSBOTerm;

   mxArray *mxInput[1];
   mxArray *mxOutput[1];
   Rule_t *pAssignRule;
   Rule_t *pAlgRule;
   Rule_t *pRateRule;
   Rule_t *pSpeciesConcentrationRule;
   Rule_t *pCompartmentVolumeRule;
   Rule_t *pParameterRule;
   ASTNode_t *ast;

   size_t i;

   for (i = 0; i < nNoRules; i++) 
   {

     /* get typecode */
     pacTypecode = ReadString(mxRule, "typecode", "rule", i, nNoRules);

     /* get notes */
     pacNotes = ReadString(mxRule, "notes", "rule", i, nNoRules);

     /* get annotations */
     pacAnnotations = ReadString(mxRule, "annotation", "rule", i, nNoRules);

     /* get formula */
     pacFormula = ReadString(mxRule, "formula", "rule", i, nNoRules);

     /* temporary hack to convert MATLAB formula to MathML infix */

     mxInput[0] = mxCreateString(pacFormula);
     nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

     if (nStatus != 0)
     {
       mexErrMsgTxt("Failed to convert formula");
     }

     /* get the formula returned */
     nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
     pacFormula = (char *) mxCalloc(nBuflen, sizeof(char));
     nStatus = mxGetString(mxOutput[0], (char *) pacFormula, (mwSize)(nBuflen));

     if (nStatus != 0)
     {
       mexErrMsgTxt("Cannot copy formula");
     }

     /* END OF HACK */

     ast = SBML_parseFormula(pacFormula);
     LookForCSymbolTime(ast);
     LookForCSymbolDelay(ast);
     LookForCSymbolAvo(ast);

     /* get each of the fields regardless of whether appropriate type */

     /* get Variable */
     pacVariable = ReadString(mxRule, "variable", "rule", i, nNoRules);

     /* get Species */
     pacSpecies = ReadString(mxRule, "species", "rule", i, nNoRules);

     /* get Compartment */
     pacCompartment = ReadString(mxRule, "compartment", "rule", i, nNoRules);

     /* get Name */
     pacName = ReadString(mxRule, "name", "rule", i, nNoRules);

     /* get Units */
     pacUnits = ReadString(mxRule, "units", "rule", i, nNoRules);

     if (unSBMLLevel == 1) 
     {
       /* get Type */
       pacType = ReadString(mxRule, "type", "rule", i, nNoRules);
    }
     else if (unSBMLLevel == 2)
     {
       /* get metaid */
       pacMetaid = ReadString(mxRule, "metaid", "rule", i, nNoRules);

       /* level 2 version 2 onwards */
       if (unSBMLVersion > 1)
       {
         /* get sboTerm */
         mxSBOTerm = mxGetField(mxRule, i, "sboTerm");
         nSBOTerm = (int)mxGetScalar(mxSBOTerm);
       }	
     }
     else if (unSBMLLevel == 3)
     {
       /* get metaid */
       pacMetaid = ReadString(mxRule, "metaid", "rule", i, nNoRules);

       /* get sboTerm */
       mxSBOTerm = mxGetField(mxRule, i, "sboTerm");
       nSBOTerm = (int)mxGetScalar(mxSBOTerm);
     }
     /* assign values for different types of rules */
     switch(CharToTypecode(pacTypecode)) {
     case SBML_ASSIGNMENT_RULE:
       pAssignRule = Model_createAssignmentRule(sbmlModel);
       Rule_setVariable(pAssignRule, pacVariable);			
       SBase_setNotesString((SBase_t *) (pAssignRule), pacNotes); 

       Rule_setMath((Rule_t *)pAssignRule, ast);
       if (unSBMLLevel == 2)
       {
         SBase_setMetaId((SBase_t *) (pAssignRule), pacMetaid);

         if (unSBMLVersion > 1)
         {
           SBase_setSBOTerm((SBase_t *) (pAssignRule), nSBOTerm);
         }

       }
       else if (unSBMLLevel == 3)
       {
         SBase_setMetaId((SBase_t *) (pAssignRule), pacMetaid);     
         SBase_setSBOTerm((SBase_t *) (pAssignRule), nSBOTerm);
       }
       SBase_setAnnotationString((SBase_t *) (pAssignRule), pacAnnotations); 
       break;

     case SBML_ALGEBRAIC_RULE:
       pAlgRule = Model_createAlgebraicRule(sbmlModel);
       SBase_setNotesString((SBase_t *) (pAlgRule), pacNotes); 

       if (unSBMLLevel == 1)
       {
         Rule_setFormula((Rule_t *)pAlgRule, pacFormula);
       }
       else if (unSBMLLevel == 2)
       {
         SBase_setMetaId((SBase_t *) (pAlgRule), pacMetaid);

         Rule_setMath((Rule_t *)pAlgRule, ast);
         if (unSBMLVersion > 1)
         {
           SBase_setSBOTerm((SBase_t *) (pAlgRule), nSBOTerm);
         }
       }
       else if (unSBMLLevel == 3)
       {
         SBase_setMetaId((SBase_t *) (pAlgRule), pacMetaid);     
         Rule_setMath((Rule_t *)pAlgRule, ast);
         SBase_setSBOTerm((SBase_t *) (pAlgRule), nSBOTerm);
       }
       SBase_setAnnotationString((SBase_t *) (pAlgRule), pacAnnotations); 

       break;

     case SBML_RATE_RULE:
       pRateRule = Model_createRateRule(sbmlModel);

       Rule_setVariable(pRateRule, pacVariable);			
       SBase_setNotesString((SBase_t *) (pRateRule), pacNotes); 

       Rule_setMath((Rule_t *)pRateRule, ast);

       if (unSBMLLevel == 2)
       {
         SBase_setMetaId((SBase_t *) (pRateRule), pacMetaid);

         if (unSBMLVersion > 1)
         {
           SBase_setSBOTerm((SBase_t *) (pRateRule), nSBOTerm);
         }
       }
       else if (unSBMLLevel == 3)
       {
         SBase_setMetaId((SBase_t *) (pRateRule), pacMetaid);     
         SBase_setSBOTerm((SBase_t *) (pRateRule), nSBOTerm);
       }
       SBase_setAnnotationString((SBase_t *) (pRateRule), pacAnnotations); 

       break;

     case SBML_SPECIES_CONCENTRATION_RULE:
       if (!strcmp(pacType, "scalar"))
       {
         pSpeciesConcentrationRule = Model_createAssignmentRule(sbmlModel);
       }
       else
       {
         pSpeciesConcentrationRule = Model_createRateRule(sbmlModel);
       }

       Rule_setL1TypeCode(pSpeciesConcentrationRule, SBML_SPECIES_CONCENTRATION_RULE);
       Rule_setVariable(pSpeciesConcentrationRule, pacSpecies);			
       SBase_setNotesString((SBase_t *) (pSpeciesConcentrationRule), pacNotes); 
       SBase_setAnnotationString((SBase_t *) (pSpeciesConcentrationRule), pacAnnotations); 

       Rule_setFormula((Rule_t *)pSpeciesConcentrationRule, pacFormula);

       break;

     case SBML_COMPARTMENT_VOLUME_RULE:
       if (!strcmp(pacType, "scalar"))
       {
         pCompartmentVolumeRule = Model_createAssignmentRule(sbmlModel);
       }
       else
       {
         pCompartmentVolumeRule = Model_createRateRule(sbmlModel);
       }

       Rule_setL1TypeCode(pCompartmentVolumeRule, SBML_COMPARTMENT_VOLUME_RULE);
       Rule_setVariable(pCompartmentVolumeRule, pacCompartment);			
       SBase_setNotesString((SBase_t *) (pCompartmentVolumeRule), pacNotes); 
       SBase_setAnnotationString((SBase_t *) (pCompartmentVolumeRule), pacAnnotations); 

       Rule_setFormula((Rule_t *)pCompartmentVolumeRule, pacFormula);

       break;

     case SBML_PARAMETER_RULE:
       if (!strcmp(pacType, "scalar"))
       {
         pParameterRule = Model_createAssignmentRule(sbmlModel);
       }
       else
       {
         pParameterRule = Model_createRateRule(sbmlModel);
       }

       Rule_setL1TypeCode(pParameterRule, SBML_PARAMETER_RULE);
       Rule_setVariable(pParameterRule, pacName);			
       SBase_setNotesString((SBase_t *) (pParameterRule), pacNotes); 
       SBase_setAnnotationString((SBase_t *) (pParameterRule), pacAnnotations); 

       Rule_setFormula((Rule_t *)pParameterRule, pacFormula);

       break;

     default:
       mexErrMsgTxt("Error in rule assignment");
       break;
     }

     /* free any memory allocated */
     mxFree(pacTypecode);
     mxFree(pacNotes);
     mxFree(pacAnnotations);
     mxFree(pacName);
     mxFree(pacCompartment);
     mxFree(pacFormula);
     mxFree(pacVariable);
     mxFree(pacUnits);
     mxFree(pacSpecies);
     /* level 1 only */
     if (unSBMLLevel == 1)
     {
       mxFree(pacType);
     }
     if (unSBMLLevel > 1)
     {
       mxFree(pacMetaid);
     }
   }

 }

/**
 * NAME:    GetReaction
 *
 * PARAMETERS:  mxArray of Reaction structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the Reaction mxArray structure
 *        and adds each Reaction to the model
 *
 */
 void
 GetReaction ( mxArray * mxReaction,
               unsigned int unSBMLLevel,
               unsigned int unSBMLVersion, 
			         Model_t * sbmlModel)
{
	size_t nNoReaction = mxGetNumberOfElements(mxReaction);

	char * pacNotes;
	char * pacAnnotations;
	char * pacName;
  char * pacCompartment;
	int nReversible;
	int nFast;
	char * pacId;
	unsigned int unIsSetFast;
  int nSBOTerm;


	size_t i;
      
	char * pacMetaid;

	mxArray * mxModifiers;
	mxArray * mxReversible, * mxFast, * mxIsSetFast, *mxReactants, * mxProducts;
  mxArray * mxSBOTerm, * mxKineticLaw;

	Reaction_t *pReaction;

	for (i = 0; i < nNoReaction; i++) 
	{

		pReaction = Model_createReaction(sbmlModel);


		/* get notes */
    pacNotes = ReadString(mxReaction, "notes", "reaction", i, nNoReaction);
		SBase_setNotesString((SBase_t *) (pReaction), pacNotes); 

		/* get name */
    pacName = ReadString(mxReaction, "name", "reaction", i, nNoReaction);
		Reaction_setName(pReaction, pacName);


		/* get reversible */
		mxReversible = mxGetField(mxReaction, i, "reversible");
		nReversible = (int)mxGetScalar(mxReversible);

		Reaction_setReversible(pReaction, nReversible);


		/* get list of reactants */
		mxReactants = mxGetField(mxReaction, i, "reactant");
		GetSpeciesReference(mxReactants, unSBMLLevel, unSBMLVersion, pReaction, 0);


		/* get list of products */
		mxProducts = mxGetField(mxReaction, i, "product");
		GetSpeciesReference(mxProducts, unSBMLLevel, unSBMLVersion, pReaction, 1);

		
    /* get kinetic law */
    mxKineticLaw = mxGetField(mxReaction, i, "kineticLaw");
		if ((mxKineticLaw != NULL) && (mxIsEmpty(mxKineticLaw) != 1)) {
      GetKineticLaw(mxKineticLaw, unSBMLLevel, unSBMLVersion, pReaction);
    }
        
		/* level 1 only */
		if (unSBMLLevel == 1)
		{
			/* get fast */
			mxFast = mxGetField(mxReaction, i, "fast");
			nFast = (int)mxGetScalar(mxFast);

			Reaction_setFast(pReaction, nFast);
		}
		

		/* level 2 */
		if (unSBMLLevel == 2)
		{
		  /* get metaid */
      pacMetaid = ReadString(mxReaction, "metaid", "reaction", i, nNoReaction);
		  SBase_setMetaId((SBase_t *) (pReaction), pacMetaid);

			/* get id */
      pacId = ReadString(mxReaction, "id", "reaction", i, nNoReaction);
			Reaction_setId(pReaction, pacId);
				
			/* get isSetFast */
			mxIsSetFast = mxGetField(mxReaction, i, "isSetFast");
            
      /* hack to catch bug in version 1.0.2 where field name was set as IsSetFast */
      if (mxIsSetFast == NULL)
      {
          mxIsSetFast = mxGetField(mxReaction, i, "IsSetFast");
      }

      unIsSetFast = (unsigned int)mxGetScalar(mxIsSetFast);


			/* get fast */
			mxFast = mxGetField(mxReaction, i, "fast");
			nFast = (int)mxGetScalar(mxFast);

			if (unIsSetFast == 1) {
				Reaction_setFast(pReaction, nFast);
			}

 			/* get modifiers */
			mxModifiers = mxGetField(mxReaction, i, "modifier");
  		GetModifier(mxModifiers, unSBMLLevel, unSBMLVersion, pReaction);
 
      /* level 2 version 2 onwards */
      if (unSBMLVersion > 1)
      {
			  /* get sboTerm */
			  mxSBOTerm = mxGetField(mxReaction, i, "sboTerm");
			  nSBOTerm = (int)mxGetScalar(mxSBOTerm);

			  SBase_setSBOTerm((SBase_t *) (pReaction), nSBOTerm);
      }	
    }
		else if (unSBMLLevel == 3)
		{
		  /* get metaid */
      pacMetaid = ReadString(mxReaction, "metaid", "reaction", i, nNoReaction);
		  SBase_setMetaId((SBase_t *) (pReaction), pacMetaid);

			/* get id */
      pacId = ReadString(mxReaction, "id", "reaction", i, nNoReaction);
			Reaction_setId(pReaction, pacId);
		
			/* get isSetFast */
			mxIsSetFast = mxGetField(mxReaction, i, "isSetFast");
            
      /* hack to catch bug in version 1.0.2 where field name was set as IsSetFast */
      if (mxIsSetFast == NULL)
      {
          mxIsSetFast = mxGetField(mxReaction, i, "IsSetFast");
      }

      unIsSetFast = (unsigned int)mxGetScalar(mxIsSetFast);


			/* get fast */
			mxFast = mxGetField(mxReaction, i, "fast");
			nFast = (int)mxGetScalar(mxFast);

			if (unIsSetFast == 1) {
				Reaction_setFast(pReaction, nFast);
			}

 			/* get modifiers */
			mxModifiers = mxGetField(mxReaction, i, "modifier");
  		GetModifier(mxModifiers, unSBMLLevel, unSBMLVersion, pReaction);
 
    /* get sboTerm */
      mxSBOTerm = mxGetField(mxReaction, i, "sboTerm");
      nSBOTerm = (int)mxGetScalar(mxSBOTerm);

      SBase_setSBOTerm((SBase_t *) (pReaction), nSBOTerm);

      /* get Compartment */
      pacCompartment = ReadString(mxReaction, "compartment", "reaction", i, nNoReaction);
		  Reaction_setCompartment(pReaction, pacCompartment);

    }

		/* get annotations */
    pacAnnotations = ReadString(mxReaction, "annotation", "reaction", i, nNoReaction);
		SBase_setAnnotationString((SBase_t *) (pReaction), pacAnnotations);

    /* free any memory allocated */
	  mxFree(pacNotes);
	  mxFree(pacAnnotations);
	  mxFree(pacName);
		/* level 2 only */
		if (unSBMLLevel == 2)
		{
  	  mxFree(pacId);
  	  mxFree(pacMetaid);
    }
		else if (unSBMLLevel == 3)
		{
  	  mxFree(pacId);
  	  mxFree(pacMetaid);
      mxFree(pacCompartment);
    }
	}
}

/**
 * NAME:    GetSpeciesReference
 *
 * PARAMETERS:  mxArray of Reactant structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the reaction
 *				      nFlag to indicate whether the species referred to are 
 *					              products or reactants
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the Reactant mxArray structure
 *        and adds each Reactant to the reaction
 *
 */
 void
 GetSpeciesReference ( mxArray * mxReactant,
                       unsigned int unSBMLLevel,
                       unsigned int unSBMLVersion, 
			                 Reaction_t * sbmlReaction, 
			                 int nFlag)
{
	size_t nNoReactant = 0;

	int nStatus;
	size_t nBuflen;

  char * pacNotes;
  char * pacAnnotations;
  char * pacSpecies;
  char * pacId = NULL;
  char * pacName = NULL;
  int nStoichiometry;
  int nDenominator;
  double dStoichiometry;
  char * pacStoichiometryMath = NULL;
  int nSBOTerm;
	char * pacMetaid;
  int nConstant;
  unsigned int unIsSetStoichiometry;
  const char * type;

  mxArray * mxInput[1];
  mxArray * mxOutput[1];
  
  SpeciesReference_t *pSpeciesReference;
  StoichiometryMath_t *pStoichiometryMath;
 
	mxArray * mxStoichiometry, *mxConstant;
  mxArray * mxDenominator, * mxStoichiometryMath, * mxSBOTerm;
  mxArray * mxIsSetStoichiometry;

  size_t i;

  if (mxReactant)
  {
    nNoReactant = mxGetNumberOfElements(mxReactant);
  }

	for (i = 0; i < nNoReactant; i++) 
	{

		if (nFlag == 0) {
			/* add the Reactant to the reaction */
		  pSpeciesReference = Reaction_createReactant(sbmlReaction);
      type = "reactant";
		}
		else {
			/* add the product to the reaction */
		  pSpeciesReference = Reaction_createProduct(sbmlReaction);
      type = "product";
		}

		/* get notes */
    pacNotes = ReadString(mxReactant, "notes", type, i, nNoReactant);
		SBase_setNotesString((SBase_t *) (pSpeciesReference), pacNotes); 


		/* get Species */
    pacSpecies = ReadString(mxReactant, "species", type, i, nNoReactant);
		SpeciesReference_setSpecies(pSpeciesReference, pacSpecies);

    if (unSBMLLevel == 1 || (unSBMLLevel == 2 && unSBMLVersion == 1))
    {
		  /* get Denominator */
		  mxDenominator = mxGetField(mxReactant, i, "denominator");
		  nDenominator = (int)mxGetScalar(mxDenominator);

		  SpeciesReference_setDenominator(pSpeciesReference, nDenominator);
    }
		
		/* level 1 only */
		if (unSBMLLevel == 1)
		{
			/* get Stoichiometry */
			mxStoichiometry = mxGetField(mxReactant, i, "stoichiometry");
			nStoichiometry = (int)mxGetScalar(mxStoichiometry);

			SpeciesReference_setStoichiometry(pSpeciesReference, nStoichiometry);
		}
		

		/* level 2 */
		if (unSBMLLevel == 2)
		{
		  /* get metaid */
      pacMetaid = ReadString(mxReactant, "metaid", type, i, nNoReactant);
		  SBase_setMetaId((SBase_t *) (pSpeciesReference), pacMetaid);

      /* get Stoichiometry */
			mxStoichiometry = mxGetField(mxReactant, i, "stoichiometry");
			dStoichiometry = mxGetScalar(mxStoichiometry);

			SpeciesReference_setStoichiometry(pSpeciesReference, dStoichiometry);

			/* get StoichiometryMath */
			mxStoichiometryMath = mxGetField(mxReactant, i, "stoichiometryMath");
      if (unSBMLVersion < 3)
      {
        nBuflen = (mxGetM(mxStoichiometryMath)*mxGetN(mxStoichiometryMath)+1);
        pacStoichiometryMath = (char *)mxCalloc(nBuflen, sizeof(char));
        nStatus = mxGetString(mxStoichiometryMath, pacStoichiometryMath, (mwSize)(nBuflen));

        if (nStatus != 0)
        {
          mexErrMsgTxt("Cannot copy StoichiometryMath");
        }

         /* temporary hack to convert MATLAB formula to MathML infix */

        mxInput[0] = mxCreateString(pacStoichiometryMath);
        nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

        if (nStatus != 0)
        {
            mexErrMsgTxt("Failed to convert formula");
        }

        /* get the formula returned */
        nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
        pacStoichiometryMath = (char *) mxCalloc(nBuflen, sizeof(char));
        nStatus = mxGetString(mxOutput[0], (char *) pacStoichiometryMath, (mwSize)(nBuflen));

        if (nStatus != 0)
        {
            mexErrMsgTxt("Cannot copy formula");
        }

        /* END OF HACK */
        if (strcmp(pacStoichiometryMath, ""))
        {
          pStoichiometryMath = 
            StoichiometryMath_create(unSBMLLevel, unSBMLVersion);
          StoichiometryMath_setMath(pStoichiometryMath, SBML_parseFormula(pacStoichiometryMath));
          SpeciesReference_setStoichiometryMath(pSpeciesReference, pStoichiometryMath);
        }
      }
      else
      {
		    if ((mxStoichiometryMath != NULL) && (mxIsEmpty(mxStoichiometryMath) != 1)) {
          GetStoichiometryMath(mxStoichiometryMath, unSBMLLevel, unSBMLVersion, pSpeciesReference);
        }
      }
      /* level 2 version 2 onwards */
      if (unSBMLVersion > 1)
      {
			  /* get sboTerm */
			  mxSBOTerm = mxGetField(mxReactant, i, "sboTerm");
			  nSBOTerm = (int)mxGetScalar(mxSBOTerm);

			  SBase_setSBOTerm((SBase_t *) (pSpeciesReference), nSBOTerm);

        /* get name */
        pacName = ReadString(mxReactant, "name", type, i, nNoReactant);
		    SpeciesReference_setName(pSpeciesReference, pacName);

			  /* get id */
        pacId = ReadString(mxReactant, "id", type, i, nNoReactant);
			  SpeciesReference_setId(pSpeciesReference, pacId);
  		
      }	
    }
    else if (unSBMLLevel == 3)
		{
		  /* get metaid */
      pacMetaid = ReadString(mxReactant, "metaid", type, i, nNoReactant);
		  SBase_setMetaId((SBase_t *) (pSpeciesReference), pacMetaid);
			
			/* get isSetStoichiometry */
			mxIsSetStoichiometry = mxGetField(mxReactant, i, "isSetStoichiometry");
			unIsSetStoichiometry = (unsigned int)mxGetScalar(mxIsSetStoichiometry);

			/* get Stoichiometry */
			mxStoichiometry = mxGetField(mxReactant, i, "stoichiometry");
			dStoichiometry = mxGetScalar(mxStoichiometry);

      if (unIsSetStoichiometry == 1)
      {
        SpeciesReference_setStoichiometry(pSpeciesReference, dStoichiometry);
      }
      /* get sboTerm */
      mxSBOTerm = mxGetField(mxReactant, i, "sboTerm");
      nSBOTerm = (int)mxGetScalar(mxSBOTerm);

      SBase_setSBOTerm((SBase_t *) (pSpeciesReference), nSBOTerm);

      /* get name */
      pacName = ReadString(mxReactant, "name", type, i, nNoReactant);
      SpeciesReference_setName(pSpeciesReference, pacName);

      /* get id */
      pacId = ReadString(mxReactant, "id", type, i, nNoReactant);
  	  SpeciesReference_setId(pSpeciesReference, pacId);
  		
			/* get constant */
			mxConstant = mxGetField(mxReactant, i, "constant");
			nConstant = (int)mxGetScalar(mxConstant);

			SpeciesReference_setConstant(pSpeciesReference, nConstant);

		}

		/* get annotations */
    pacAnnotations = ReadString(mxReactant, "annotation", type, i, nNoReactant);
		SBase_setAnnotationString((SBase_t *) (pSpeciesReference), pacAnnotations); 


    /* free any memory allocated */
	  mxFree(pacNotes);
	  mxFree(pacAnnotations);
  	mxFree(pacSpecies);
		/* level 2 only */
		if (unSBMLLevel == 2)
		{
  	  mxFree(pacMetaid);
      if (unSBMLVersion < 3)
      {
        mxFree(pacStoichiometryMath);
      }

      if (unSBMLVersion > 1)
      {
	      mxFree(pacName);
	      mxFree(pacId);
      }
    }
    else if (unSBMLLevel == 3)
    {
  	  mxFree(pacMetaid);
      mxFree(pacName);
      mxFree(pacId);
    }
	}
}

/**
 * NAME:    GetModifier
 *
 * PARAMETERS:  mxArray of modifier structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the reaction
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the modifier mxArray structure
 *        and adds each modifier to the reaction
 *
 */
 void
 GetModifier ( mxArray * mxModifier,
               unsigned int unSBMLLevel,
               unsigned int unSBMLVersion, 
			         Reaction_t * sbmlReaction)
{
	size_t nNoModifier = 0;

  char * pacNotes;
  char * pacAnnotations;
  char * pacSpecies;
  char * pacId;
  char * pacName;
  int nSBOTerm;
	char * pacMetaid;

  SpeciesReference_t *pSpeciesReference;
 
  mxArray * mxSBOTerm;

	size_t i;

  if (mxModifier)
  {
    nNoModifier = mxGetNumberOfElements(mxModifier);
  }

  for (i = 0; i < nNoModifier; i++) 
	{

		pSpeciesReference = Reaction_createModifier(sbmlReaction);

		/* get notes */
    pacNotes = ReadString(mxModifier, "notes", "modifier", i, nNoModifier);
		SBase_setNotesString((SBase_t *) (pSpeciesReference), pacNotes); 


		/* get Species */
    pacSpecies = ReadString(mxModifier, "species", "modifier", i, nNoModifier);
		SpeciesReference_setSpecies(pSpeciesReference, pacSpecies);


		/* get metaid */
    pacMetaid = ReadString(mxModifier, "metaid", "modifier", i, nNoModifier);
		SBase_setMetaId((SBase_t *) (pSpeciesReference), pacMetaid);

    /* level 2 version 2 onwards */
    if (unSBMLLevel == 2 && unSBMLVersion > 1)
    {
			/* get sboTerm */
			mxSBOTerm = mxGetField(mxModifier, i, "sboTerm");
			nSBOTerm = (int)mxGetScalar(mxSBOTerm);

			SBase_setSBOTerm((SBase_t *) (pSpeciesReference), nSBOTerm);

      /* get name */
      pacName = ReadString(mxModifier, "name", "modifier", i, nNoModifier);
		  SpeciesReference_setName(pSpeciesReference, pacName);

			/* get id */
      pacId = ReadString(mxModifier, "id", "modifier", i, nNoModifier);
			SpeciesReference_setId(pSpeciesReference, pacId);
  	
    }	
    else if (unSBMLLevel == 3)
    {
			/* get sboTerm */
			mxSBOTerm = mxGetField(mxModifier, i, "sboTerm");
			nSBOTerm = (int)mxGetScalar(mxSBOTerm);

			SBase_setSBOTerm((SBase_t *) (pSpeciesReference), nSBOTerm);

      /* get name */
      pacName = ReadString(mxModifier, "name", "modifier", i, nNoModifier);
		  SpeciesReference_setName(pSpeciesReference, pacName);

			/* get id */
      pacId = ReadString(mxModifier, "id", "modifier", i, nNoModifier);
			SpeciesReference_setId(pSpeciesReference, pacId);
  	
    }	

		/* get annotations */
    pacAnnotations = ReadString(mxModifier, "annotation", "modifier", i, nNoModifier);
		SBase_setAnnotationString((SBase_t *) (pSpeciesReference), pacAnnotations);


    /* free any memory allocated */
	  mxFree(pacNotes);
	  mxFree(pacAnnotations);
  	mxFree(pacSpecies);
  	mxFree(pacMetaid);
    if ((unSBMLLevel == 2 && unSBMLVersion > 1) || unSBMLLevel == 3)
    {
      mxFree(pacId);
      mxFree(pacName);
    }
	}

}

/**
 * NAME:    GetKineticLaw
 *
 * PARAMETERS:  mxArray of kinetic law structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the Reactiom
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the KineticLaw mxArray structure
 *        and adds Kinetic law to the reaction
 *
 */
 void
 GetKineticLaw ( mxArray * mxKineticLaw,
                 unsigned int unSBMLLevel,
                 unsigned int unSBMLVersion, 
			           Reaction_t * sbmlReaction)
{
	int nStatus;
	size_t nBuflen;

  char * pacNotes;
  char * pacAnnotations;
  char * pacFormula;
  char * pacTimeUnits = NULL;
  char * pacSubstanceUnits = NULL;
  char * pacMath = NULL;
  int nSBOTerm;
	char * pacMetaid = NULL;

	mxArray * mxParameter, *mxSBOTerm;
  mxArray *mxInput[1];
  mxArray *mxOutput[1];

  KineticLaw_t *pKineticLaw;

  ASTNode_t * ast;
  
  pKineticLaw = Reaction_createKineticLaw(sbmlReaction);
  
  /* get notes */
  pacNotes = ReadString(mxKineticLaw, "notes", "kineticLaw", 0, 0);
  SBase_setNotesString((SBase_t *) (pKineticLaw), pacNotes);
  
  
  if (unSBMLLevel < 3)
  {
    /* get formula */
    pacFormula = ReadString(mxKineticLaw, "formula", "kineticLaw", 0, 0);

     /* temporary hack to convert MATLAB formula to MathML infix */

    mxInput[0] = mxCreateString(pacFormula);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

    if (nStatus != 0)
    {
        mexErrMsgTxt("Failed to convert formula");
    }

    /* get the formula returned */
    nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
    pacFormula = (char *) mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxOutput[0], (char *) pacFormula, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
        mexErrMsgTxt("Cannot copy formula");
    }

    /* END OF HACK */

    KineticLaw_setFormula(pKineticLaw, pacFormula);
  }
  /* level 1 and level 2 version 1 ONLY */
  if (unSBMLLevel == 1 || (unSBMLLevel == 2 && unSBMLVersion == 1))
  {
    /* get timeUnits */
    pacTimeUnits = ReadString(mxKineticLaw, "timeUnits", "kineticLaw", 0, 0);
    KineticLaw_setTimeUnits(pKineticLaw, pacTimeUnits);


    /* get substanceUnits */
    pacSubstanceUnits = ReadString(mxKineticLaw, "substanceUnits", "kineticLaw", 0, 0);
    KineticLaw_setSubstanceUnits(pKineticLaw, pacSubstanceUnits);
  }
  if (unSBMLLevel < 3)
  {
    /* get list of parameters */
    mxParameter = mxGetField(mxKineticLaw, 0, "parameter");
    GetParameterFromKineticLaw(mxParameter, unSBMLLevel, unSBMLVersion, pKineticLaw);
  }
  else
  {
    /* get list of parameters */
    mxParameter = mxGetField(mxKineticLaw, 0, "localParameter");
    GetParameterFromKineticLaw(mxParameter, unSBMLLevel, unSBMLVersion, pKineticLaw);
  }
  
  if (unSBMLLevel == 2)
  {
    /* get metaid */
    pacMetaid = ReadString(mxKineticLaw, "metaid", "kineticLaw", 0, 0);
    SBase_setMetaId((SBase_t *) (pKineticLaw), pacMetaid);

    /* get Math */
    pacMath = ReadString(mxKineticLaw, "formula", "kineticLaw", 0, 0);

    /* temporary hack to convert MATLAB formula to MathML infix */

    mxInput[0] = mxCreateString(pacMath);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

    if (nStatus != 0)
    {
      mexErrMsgTxt("Failed to convert formula");
    }

    /* get the formula returned */
    nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
    pacMath = (char *) mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxOutput[0], (char *) pacMath, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy formula");
    }

    /* END OF HACK */
    ast = SBML_parseFormula(pacMath);
    LookForCSymbolTime(ast);
    LookForCSymbolDelay(ast);
    LookForCSymbolAvo(ast);

    KineticLaw_setMath(pKineticLaw, ast);

    /* level 2 version 2 onwards */
    if (unSBMLVersion > 1)
    {
      /* get sboTerm */
      mxSBOTerm = mxGetField(mxKineticLaw, 0, "sboTerm");
      nSBOTerm = (int)mxGetScalar(mxSBOTerm);

      SBase_setSBOTerm((SBase_t *) (pKineticLaw), nSBOTerm);
    }
  }
  else if (unSBMLLevel == 3)
  {
    /* get metaid */
    pacMetaid = ReadString(mxKineticLaw, "metaid", "kineticLaw", 0, 0);
    SBase_setMetaId((SBase_t *) (pKineticLaw), pacMetaid);

    /* get Math */
    pacMath = ReadString(mxKineticLaw, "math", "kineticLaw", 0, 0);

    /* temporary hack to convert MATLAB formula to MathML infix */

    mxInput[0] = mxCreateString(pacMath);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

    if (nStatus != 0)
    {
      mexErrMsgTxt("Failed to convert math");
    }

    /* get the formula returned */
    nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
    pacMath = (char *) mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxOutput[0], (char *) pacMath, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy math");
    }

    /* END OF HACK */
    ast = SBML_parseFormula(pacMath);
    LookForCSymbolTime(ast);
    LookForCSymbolDelay(ast);
    LookForCSymbolAvo(ast);

    KineticLaw_setMath(pKineticLaw, ast);

    /* get sboTerm */
    mxSBOTerm = mxGetField(mxKineticLaw, 0, "sboTerm");
    nSBOTerm = (int)mxGetScalar(mxSBOTerm);

    SBase_setSBOTerm((SBase_t *) (pKineticLaw), nSBOTerm);

  }

  /* get annotations */
  pacAnnotations = ReadString(mxKineticLaw, "annotation", "kineticLaw", 0, 0);
  SBase_setAnnotationString((SBase_t *) (pKineticLaw), pacAnnotations); 

  /* free any memory allocated */
	mxFree(pacNotes);
	mxFree(pacAnnotations);
  if (unSBMLLevel == 1 || (unSBMLLevel == 2 && unSBMLVersion == 1))
  {
	  mxFree(pacTimeUnits);
    mxFree(pacSubstanceUnits);
  }
  if (unSBMLLevel < 3)
  {
    mxFree(pacFormula);
  }
	/* level 2/3 only */
	if (unSBMLLevel > 1)
	{
  	mxFree(pacMath);
    mxFree(pacMetaid);
  }
}

/**
 * NAME:    GetParameterFromKineticLaw
 *
 * PARAMETERS:  mxArray of parameter structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the kinetic law
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the parameter mxArray structure
 *        and adds each parameter to the kinetic law
 *
 */
 void
 GetParameterFromKineticLaw ( mxArray * mxParameters,
                              unsigned int unSBMLLevel,
                              unsigned int unSBMLVersion, 
                              KineticLaw_t * sbmlKineticLaw)
 {
   size_t nNoParameters = mxGetNumberOfElements(mxParameters);

   char * pacNotes;
   char * pacAnnotations;
   char * pacName;
   char * pacId;
   double dValue;
   char * pacUnits;
   unsigned int unIsSetValue;
   int nSBOTerm;
   int nConstant;
   char * pacMetaid;

   mxArray * mxValue, * mxIsSetValue, * mxConstant, * mxSBOTerm;

   Parameter_t *pParameter;
   LocalParameter_t *pLocalParameter;

   size_t i;

   for (i = 0; i < nNoParameters; i++) 
   {

     if (unSBMLLevel < 3)
     {
       pParameter = KineticLaw_createParameter(sbmlKineticLaw);
     }
     else
     {
       pLocalParameter = KineticLaw_createLocalParameter(sbmlKineticLaw);
     }

     /* get notes */
     pacNotes = ReadString(mxParameters, "notes", "(local)Parameter", i, nNoParameters);
     if (unSBMLLevel < 3)
     {
       SBase_setNotesString((SBase_t *) (pParameter), pacNotes); 
     }
     else
     {
       SBase_setNotesString((SBase_t *) (pLocalParameter), pacNotes); 
     }



     /* get name */
     pacName = ReadString(mxParameters, "name", "(local)Parameter", i, nNoParameters);
     if (unSBMLLevel < 3)
     {
       Parameter_setName(pParameter, pacName); 
     }
     else
     {
       LocalParameter_setName(pLocalParameter, pacName); 
     }



     /* get units */
     pacUnits = ReadString(mxParameters, "units", "(local)Parameter", i, nNoParameters);
     if (unSBMLLevel < 3)
     {
       Parameter_setUnits(pParameter, pacUnits); 
     }
     else
     {
       LocalParameter_setUnits(pLocalParameter, pacUnits); 
     }



     /* get isSetValue */
     mxIsSetValue = mxGetField(mxParameters, i, "isSetValue");
     unIsSetValue = (unsigned int)mxGetScalar(mxIsSetValue);


     /* get value */
     mxValue = mxGetField(mxParameters, i, "value");
     dValue = mxGetScalar(mxValue);

     if (unIsSetValue == 1) {
       if (unSBMLLevel < 3)
       {
         Parameter_setValue(pParameter, dValue); 
       }
       else
       {
         LocalParameter_setValue(pLocalParameter, dValue); 
       }

     }


     /* level 2 */
     if (unSBMLLevel == 2)
     {
       /* get metaid */
       pacMetaid = ReadString(mxParameters, "metaid", "(local)Parameter", i, nNoParameters);
       SBase_setMetaId((SBase_t *) (pParameter), pacMetaid);

       /* get id */
       pacId = ReadString(mxParameters, "id", "(local)Parameter", i, nNoParameters);
       Parameter_setId(pParameter, pacId);


       /* get constant */
       mxConstant = mxGetField(mxParameters, i, "constant");
       nConstant = (int)mxGetScalar(mxConstant);

       Parameter_setConstant(pParameter, nConstant);

       /* level 2 version 2 onwards */
       if (unSBMLVersion > 1)
       {
         /* get sboTerm */
         mxSBOTerm = mxGetField(mxParameters, i, "sboTerm");
         nSBOTerm = (int)mxGetScalar(mxSBOTerm);

         SBase_setSBOTerm((SBase_t *) (pParameter), nSBOTerm);
       }	
     }
     /* level 2 */
     else if (unSBMLLevel == 3)
     {
       /* get metaid */
       pacMetaid = ReadString(mxParameters, "metaid", "(local)Parameter", i, nNoParameters);
       SBase_setMetaId((SBase_t *) (pLocalParameter), pacMetaid);

       /* get id */
       pacId = ReadString(mxParameters, "id", "(local)Parameter", i, nNoParameters);
       LocalParameter_setId(pLocalParameter, pacId);


       /* get sboTerm */
       mxSBOTerm = mxGetField(mxParameters, i, "sboTerm");
       nSBOTerm = (int)mxGetScalar(mxSBOTerm);

       SBase_setSBOTerm((SBase_t *) (pLocalParameter), nSBOTerm);
     }


     /* get annotations */
     pacAnnotations = ReadString(mxParameters, "annotation", "(local)Parameter", i, nNoParameters);
     if (unSBMLLevel < 3)
     {
       SBase_setAnnotationString((SBase_t *) (pParameter), pacAnnotations); 
     }
     else
     {
       SBase_setAnnotationString((SBase_t *) (pLocalParameter), pacAnnotations); 
     }


     /* free any memory allocated */
     mxFree(pacNotes);
     mxFree(pacAnnotations);
     mxFree(pacName);
     mxFree(pacUnits);
     /* level 2/3 only */
     if (unSBMLLevel > 1)
     {
       mxFree(pacMetaid);
       mxFree(pacId);
     }
   }

 }

/**
 * NAME:    GetFunctionDefinition
 *
 * PARAMETERS:  mxArray of functiondefinition structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the function definition mxArray structure
 *        and adds each functiondefinition to the model
 */
void
GetFunctionDefinition ( mxArray * mxFunctionDefinitions,
                        unsigned int unSBMLLevel,
                        unsigned int unSBMLVersion, 
                        Model_t * sbmlModel )
{
  size_t nNoFunctions = mxGetNumberOfElements(mxFunctionDefinitions);

  int nStatus;
  size_t nBuflen;

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacName;
  char * pacId;
  char * pacFormula;
  int nSBOTerm; 
  char * pacMetaid;

  mxArray * mxSBOTerm;
  mxArray *mxInput[1];
  mxArray *mxOutput[1];

  FunctionDefinition_t *pFuncDefinition;
  ASTNode_t *ast;

  size_t i;


  for (i = 0; i < nNoFunctions; i++) 
  {
    pFuncDefinition = Model_createFunctionDefinition(sbmlModel);

    /* get notes */
    pacNotes = ReadString(mxFunctionDefinitions, "notes", "functionDefinition", i, nNoFunctions);
    SBase_setNotesString((SBase_t *) (pFuncDefinition), pacNotes); 


    /* get name */
    pacName = ReadString(mxFunctionDefinitions, "name", "functionDefinition", i, nNoFunctions);
    FunctionDefinition_setName(pFuncDefinition, pacName);


    /* get metaid */
    pacMetaid = ReadString(mxFunctionDefinitions, "metaid", "functionDefinition", i, nNoFunctions);
    SBase_setMetaId((SBase_t *) (pFuncDefinition), pacMetaid);

    /* get id */
    pacId = ReadString(mxFunctionDefinitions, "id", "functionDefinition", i, nNoFunctions);
    FunctionDefinition_setId(pFuncDefinition, pacId);


    /* get math */
    pacFormula = ReadString(mxFunctionDefinitions, "math", "functionDefinition", i, nNoFunctions);

    /* temporary hack to convert MATLAB formula to MathML infix */

    mxInput[0] = mxCreateString(pacFormula);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

    if (nStatus != 0)
    {
      mexErrMsgTxt("Failed to convert formula");
    }

    /* get the formula returned */
    nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
    pacFormula = (char *) mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxOutput[0], (char *) pacFormula, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy formula");
    }

    /* END OF HACK */
    ast = SBML_parseFormula(pacFormula);
    LookForCSymbolTime(ast);
    LookForCSymbolDelay(ast);
    LookForCSymbolAvo(ast);

    FunctionDefinition_setMath(pFuncDefinition, ast);

    if (unSBMLVersion > 1 || unSBMLLevel > 2)
    {
      /* get sboTerm */
      mxSBOTerm = mxGetField(mxFunctionDefinitions, i, "sboTerm");
      nSBOTerm = (int)mxGetScalar(mxSBOTerm);

      SBase_setSBOTerm((SBase_t *) (pFuncDefinition), nSBOTerm);
    }

    /* get annotations */
    pacAnnotations = ReadString(mxFunctionDefinitions, "annotation", "functionDefinition", i, nNoFunctions);
    SBase_setAnnotationString((SBase_t *) (pFuncDefinition), pacAnnotations); 


    /* free any memory allocated */
    mxFree(pacNotes);
    mxFree(pacAnnotations);
    mxFree(pacName);
    mxFree(pacFormula);
    mxFree(pacId);
    mxFree(pacMetaid);
  }
}

/**
 * NAME:    GetEvent
 *
 * PARAMETERS:  mxArray of event structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the event mxArray structure
 *        and adds each event to the model
 */
void
GetEvent ( mxArray * mxEvents,
           unsigned int unSBMLLevel,
           unsigned int unSBMLVersion, 
           Model_t * sbmlModel )
{
  size_t nNoEvents = mxGetNumberOfElements(mxEvents);

  int nStatus;
  size_t nBuflen;

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacName;
  char * pacId;
  char * pacTrigger = NULL;
  char * pacDelay = NULL;
  char * pacTimeUnits = NULL;
  int nSBOTerm;
  char * pacMetaid;
  int nUseValuesFromTrigger;

  mxArray * mxUseValuesfromTrigger, *mxPriority;
  mxArray * mxTrigger, * mxDelay, * mxEventAssignments, *mxSBOTerm;

  mxArray *mxInput[1];
  mxArray * mxOutput[1];

  Event_t *pEvent;
  size_t i;


  for (i = 0; i < nNoEvents; i++) 
  {
    pEvent = Model_createEvent(sbmlModel);

    /* get notes */
    pacNotes = ReadString(mxEvents, "notes", "event", i, nNoEvents);
    SBase_setNotesString((SBase_t *) (pEvent), pacNotes); 


    /* get name */
    pacName = ReadString(mxEvents, "name", "event", i, nNoEvents);
    Event_setName(pEvent, pacName);


    /* get metaid */
    pacMetaid = ReadString(mxEvents, "metaid", "event", i, nNoEvents);
    SBase_setMetaId((SBase_t *) (pEvent), pacMetaid);

    /* get Trigger */
    mxTrigger = mxGetField(mxEvents, i, "trigger");
    if (unSBMLLevel == 2 && unSBMLVersion < 3)
    {

      nBuflen = (mxGetM(mxTrigger)*mxGetN(mxTrigger)+1);
      pacTrigger = (char *)mxCalloc(nBuflen, sizeof(char));
      nStatus = mxGetString(mxTrigger, pacTrigger, (mwSize)(nBuflen));

      if (nStatus != 0)
      {
        mexErrMsgTxt("Cannot copy Trigger");
      }
      /* temporary hack to convert MATLAB formula to MathML infix */

      mxInput[0] = mxCreateString(pacTrigger);
      nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

      if (nStatus != 0)
      {
        mexErrMsgTxt("Failed to convert formula");
      }

      /* get the formula returned */
      nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
      pacTrigger = (char *) mxCalloc(nBuflen, sizeof(char));
      nStatus = mxGetString(mxOutput[0], (char *) pacTrigger, (mwSize)(nBuflen));

      if (nStatus != 0)
      {
        mexErrMsgTxt("Cannot copy formula");
      }

      /* END OF HACK */

      if (strcmp(pacTrigger, ""))
      {
        Trigger_t * trigger = Trigger_create(unSBMLLevel, unSBMLVersion);
        Trigger_setMath(trigger, SBML_parseFormula(pacTrigger));
        Event_setTrigger(pEvent, trigger);
      }
    }
    else
    {
      GetTrigger(mxTrigger, unSBMLLevel, unSBMLVersion, pEvent);
    }
    /* get Delay */
    mxDelay = mxGetField(mxEvents, i, "delay");
    if (unSBMLLevel == 2 && unSBMLVersion < 3)
    {
      nBuflen = (mxGetM(mxDelay)*mxGetN(mxDelay)+1);
      pacDelay = (char *)mxCalloc(nBuflen, sizeof(char));
      nStatus = mxGetString(mxDelay, pacDelay, (mwSize)(nBuflen));

      if (nStatus != 0)
      {
        mexErrMsgTxt("Cannot copy Delay");
      }
      /* temporary hack to convert MATLAB formula to MathML infix */

      mxInput[0] = mxCreateString(pacDelay);
      nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

      if (nStatus != 0)
      {
        mexErrMsgTxt("Failed to convert formula");
      }

      /* get the formula returned */
      nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
      pacDelay = (char *) mxCalloc(nBuflen, sizeof(char));
      nStatus = mxGetString(mxOutput[0], (char *) pacDelay, (mwSize)(nBuflen));

      if (nStatus != 0)
      {
        mexErrMsgTxt("Cannot copy formula");
      }

      /* END OF HACK */

      if (strcmp(pacDelay, ""))
      {
        Delay_t * delay = Delay_create(unSBMLLevel, unSBMLVersion);
        Delay_setMath(delay, SBML_parseFormula(pacDelay));
        Event_setDelay(pEvent, delay);
      }
    }
    else
    {
      if ((mxDelay != NULL) && (mxIsEmpty(mxDelay) != 1)) 
      {
        GetDelay(mxDelay, unSBMLLevel, unSBMLVersion, pEvent);
      }
    }
    if (unSBMLLevel == 2 && unSBMLVersion < 3)
    {
      /* get TimeUnits */
      pacTimeUnits = ReadString(mxEvents, "timeUnits", "event", i, nNoEvents);
      Event_setTimeUnits(pEvent, pacTimeUnits);
    }

    if (unSBMLLevel > 2)
    {
      mxPriority = mxGetField(mxEvents, i, "priority");
      GetPriority(mxPriority, unSBMLLevel, unSBMLVersion, pEvent);
    }

    /* get id */
    pacId = ReadString(mxEvents, "id", "event", i, nNoEvents);
    Event_setId(pEvent, pacId);


    if (unSBMLLevel == 2 )
    {
      if (unSBMLVersion > 1)
      {
        /* get sboTerm */
        mxSBOTerm = mxGetField(mxEvents, i, "sboTerm");
        nSBOTerm = (int)mxGetScalar(mxSBOTerm);

        SBase_setSBOTerm((SBase_t *) (pEvent), nSBOTerm);
      }

      if (unSBMLVersion > 3)
      {
        /* get useValuesFromTriggerTime */
        mxUseValuesfromTrigger = mxGetField(mxEvents, i, "useValuesFromTriggerTime");
        nUseValuesFromTrigger = (int)mxGetScalar(mxUseValuesfromTrigger);

        Event_setUseValuesFromTriggerTime(pEvent, nUseValuesFromTrigger);
      }
    }
    else if (unSBMLLevel == 3)
    {
      /* get sboTerm */
      mxSBOTerm = mxGetField(mxEvents, i, "sboTerm");
      nSBOTerm = (int)mxGetScalar(mxSBOTerm);

      SBase_setSBOTerm((SBase_t *) (pEvent), nSBOTerm);

      /* get useValuesFromTriggerTime */
      mxUseValuesfromTrigger = mxGetField(mxEvents, i, "useValuesFromTriggerTime");
      nUseValuesFromTrigger = (int)mxGetScalar(mxUseValuesfromTrigger);

      Event_setUseValuesFromTriggerTime(pEvent, nUseValuesFromTrigger);
    }
    /* get list of event assignments */
    mxEventAssignments = mxGetField(mxEvents, i, "eventAssignment");
    GetEventAssignment(mxEventAssignments, unSBMLLevel, unSBMLVersion, pEvent);

    /* get annotations */
    pacAnnotations = ReadString(mxEvents, "annotation", "event", i, nNoEvents);
    SBase_setAnnotationString((SBase_t *) (pEvent), pacAnnotations); 


    /* free any memory allocated */
    mxFree(pacNotes);
    mxFree(pacAnnotations);
    mxFree(pacName);
    mxFree(pacId);
    mxFree(pacMetaid);
    if (unSBMLLevel == 2 && unSBMLVersion < 3)
    {
      mxFree(pacTrigger);
      mxFree(pacDelay);
      mxFree(pacTimeUnits);
    }
  }
}

/**
 * NAME:    GetEventAssignment
 *
 * PARAMETERS:  mxArray of event assignment structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the event
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the event assignment mxArray structure
 *        and adds each event assignment to the event
 */
void
GetEventAssignment ( mxArray * mxEventAssignment,
                     unsigned int unSBMLLevel,
                     unsigned int unSBMLVersion, 
                     Event_t * sbmlEvent )
{
  size_t nNoEventAssigns = mxGetNumberOfElements(mxEventAssignment);

  int nStatus;
  size_t nBuflen;

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacVariable;
  char * pacMath;
  int nSBOTerm;
  char * pacMetaid;

  mxArray * mxSBOTerm;
  mxArray *mxInput[1];
  mxArray *mxOutput[1];

  EventAssignment_t *pEventAssignment;
  ASTNode_t *ast;
  size_t i;


  for (i = 0; i < nNoEventAssigns; i++) 
  {
    pEventAssignment = Event_createEventAssignment(sbmlEvent);

    /* get notes */
    pacNotes = ReadString(mxEventAssignment, "notes", "eventAssignment", i, nNoEventAssigns);
    SBase_setNotesString((SBase_t *) (pEventAssignment), pacNotes);


    /* get metaid */
    pacMetaid = ReadString(mxEventAssignment, "metaid", "eventAssignment", i, nNoEventAssigns);
    SBase_setMetaId((SBase_t *) (pEventAssignment), pacMetaid);

    /* get Variable */
    pacVariable = ReadString(mxEventAssignment, "variable", "eventAssignment", i, nNoEventAssigns);
    EventAssignment_setVariable(pEventAssignment, pacVariable);

    /* get Math */
    pacMath = ReadString(mxEventAssignment, "math", "eventAssignment", i, nNoEventAssigns);

    /* temporary hack to convert MATLAB formula to MathML infix */

    mxInput[0] = mxCreateString(pacMath);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

    if (nStatus != 0)
    {
      mexErrMsgTxt("Failed to convert formula");
    }

    /* get the formula returned */
    nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
    pacMath = (char *) mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxOutput[0], (char *) pacMath, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy formula");
    }

    /* END OF HACK */
    ast = SBML_parseFormula(pacMath);
    LookForCSymbolTime(ast);
    LookForCSymbolDelay(ast);
    LookForCSymbolAvo(ast);

    EventAssignment_setMath(pEventAssignment, ast);

    if (unSBMLLevel == 2 && unSBMLVersion > 1)
    {
      /* get sboTerm */
      mxSBOTerm = mxGetField(mxEventAssignment, i, "sboTerm");
      nSBOTerm = (int)mxGetScalar(mxSBOTerm);

      SBase_setSBOTerm((SBase_t *) (pEventAssignment), nSBOTerm);
    }
    else if (unSBMLLevel == 3)
    {
      /* get sboTerm */
      mxSBOTerm = mxGetField(mxEventAssignment, i, "sboTerm");
      nSBOTerm = (int)mxGetScalar(mxSBOTerm);

      SBase_setSBOTerm((SBase_t *) (pEventAssignment), nSBOTerm);
    }

    /* get annotations */
    pacAnnotations = ReadString(mxEventAssignment, "annotation", "eventAssignment", i, nNoEventAssigns);
    SBase_setAnnotationString((SBase_t *) (pEventAssignment), pacAnnotations); 


    /* free any memory allocated */
    mxFree(pacNotes);
    mxFree(pacAnnotations);
    mxFree(pacVariable);
    mxFree(pacMath);
    mxFree(pacMetaid);
  }
}

/**
 * NAME:    GetCompartmentType
 *
 * PARAMETERS:  mxArray of compartmentType structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the compartmentType mxArray structure
 *        and adds each compartmentType to the model
 */
void
GetCompartmentType ( mxArray * mxCompartmentType,
                     unsigned int unSBMLLevel,
                     unsigned int unSBMLVersion, 
                     Model_t * sbmlModel )
{
  size_t nNoCompTypes = mxGetNumberOfElements(mxCompartmentType);

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacName;
  char * pacId;
  int nSBOTerm;
  char * pacMetaid;

  mxArray * mxSBOTerm;

  CompartmentType_t *pCompartmentType;
  size_t i;


  for (i = 0; i < nNoCompTypes; i++) 
  {
    pCompartmentType = Model_createCompartmentType(sbmlModel);

    /* get notes */
    pacNotes = ReadString(mxCompartmentType, "notes", "compartmentType", i, nNoCompTypes);
    SBase_setNotesString((SBase_t *) (pCompartmentType), pacNotes);


    /* get name */
    pacName = ReadString(mxCompartmentType, "name", "compartmentType", i, nNoCompTypes);
    CompartmentType_setName(pCompartmentType, pacName);

    /* get metaid */
    pacMetaid = ReadString(mxCompartmentType, "metaid", "compartmentType", i, nNoCompTypes);
    SBase_setMetaId((SBase_t *) (pCompartmentType), pacMetaid);

    /* get Id */
    pacId = ReadString(mxCompartmentType, "id", "compartmentType", i, nNoCompTypes);
    CompartmentType_setId(pCompartmentType, pacId);

    if (unSBMLVersion > 2)
    {
      /* get sboTerm */
      mxSBOTerm = mxGetField(mxCompartmentType, i, "sboTerm");
      nSBOTerm = (int)mxGetScalar(mxSBOTerm);

      SBase_setSBOTerm((SBase_t *) (pCompartmentType), nSBOTerm);
    }

    /* get annotations */
    pacAnnotations = ReadString(mxCompartmentType, "annotation", "compartmentType", i, nNoCompTypes);
    SBase_setAnnotationString((SBase_t *) (pCompartmentType), pacAnnotations); 


    /* free any memory allocated */
    mxFree(pacNotes);
    mxFree(pacAnnotations);
    mxFree(pacName);
    mxFree(pacId);
    mxFree(pacMetaid);
  }
}

/**
 * NAME:    GetSpeciesType
 *
 * PARAMETERS:  mxArray of speciesType structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the speciesType mxArray structure
 *        and adds each speciesType to the model
 */
void
GetSpeciesType ( mxArray * mxSpeciesType,
                 unsigned int unSBMLLevel,
                 unsigned int unSBMLVersion, 
                 Model_t * sbmlModel )
{
  size_t nNoSpeciesTypes = mxGetNumberOfElements(mxSpeciesType);

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacName;
  char * pacId;
  int nSBOTerm;
  char * pacMetaid;

  mxArray * mxSBOTerm;

  SpeciesType_t *pSpeciesType;
  size_t i;


  for (i = 0; i < nNoSpeciesTypes; i++) 
  {
    pSpeciesType = Model_createSpeciesType(sbmlModel);

    /* get notes */
    pacNotes = ReadString(mxSpeciesType, "notes", "speciesType", i, nNoSpeciesTypes);
    SBase_setNotesString((SBase_t *) (pSpeciesType), pacNotes);


    /* get name */
    pacName = ReadString(mxSpeciesType, "name", "speciesType", i, nNoSpeciesTypes);
    SpeciesType_setName(pSpeciesType, pacName);

    /* get metaid */
    pacMetaid = ReadString(mxSpeciesType, "metaid", "speciesType", i, nNoSpeciesTypes);
    SBase_setMetaId((SBase_t *) (pSpeciesType), pacMetaid);

    /* get Id */
    pacId = ReadString(mxSpeciesType, "id", "speciesType", i, nNoSpeciesTypes);
    SpeciesType_setId(pSpeciesType, pacId);

    if (unSBMLVersion > 2)
    {
      /* get sboTerm */
      mxSBOTerm = mxGetField(mxSpeciesType, i, "sboTerm");
      nSBOTerm = (int)mxGetScalar(mxSBOTerm);

      SBase_setSBOTerm((SBase_t *) (pSpeciesType), nSBOTerm);
    }

    /* get annotations */
    pacAnnotations = ReadString(mxSpeciesType, "annotation", "speciesType", i, nNoSpeciesTypes);
    SBase_setAnnotationString((SBase_t *) (pSpeciesType), pacAnnotations); 


    /* free any memory allocated */
    mxFree(pacNotes);
    mxFree(pacAnnotations);
    mxFree(pacName);
    mxFree(pacId);
    mxFree(pacMetaid);
  }
}

/**
 * NAME:    GetInitialAssignment
 *
 * PARAMETERS:  mxArray of initialAssignment structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the initialAssignment mxArray structure
 *        and adds each initialAssignment to the model
 */
void
GetInitialAssignment ( mxArray * mxInitialAssignment,
                       unsigned int unSBMLLevel,
                       unsigned int unSBMLVersion, 
			                 Model_t * sbmlModel )
{
	size_t nNoInitialAssignments = mxGetNumberOfElements(mxInitialAssignment);
  
	int nStatus;
	size_t nBuflen;

	/* values */
	char * pacNotes;
	char * pacAnnotations;
	char * pacSymbol;
  char * pacMath;
  int nSBOTerm;
	char * pacMetaid;

	mxArray * mxSBOTerm;
  mxArray *mxInput[1];
  mxArray *mxOutput[1];

	InitialAssignment_t *pInitialAssignment;
  ASTNode_t *ast;
	size_t i;


	for (i = 0; i < nNoInitialAssignments; i++) 
	{
		pInitialAssignment = Model_createInitialAssignment(sbmlModel);

		/* get notes */
    pacNotes = ReadString(mxInitialAssignment, "notes", "initialAssignment", i, nNoInitialAssignments);
		SBase_setNotesString((SBase_t *) (pInitialAssignment), pacNotes);


		/* get metaid */
    pacMetaid = ReadString(mxInitialAssignment, "metaid", "initialAssignment", i, nNoInitialAssignments);
		SBase_setMetaId((SBase_t *) (pInitialAssignment), pacMetaid);

		/* get symbol */
    pacSymbol = ReadString(mxInitialAssignment, "symbol", "initialAssignment", i, nNoInitialAssignments);
		InitialAssignment_setSymbol(pInitialAssignment, pacSymbol);

		/* get Math */
    pacMath = ReadString(mxInitialAssignment, "math", "initialAssignment", i, nNoInitialAssignments);

    /* temporary hack to convert MATLAB formula to MathML infix */

    mxInput[0] = mxCreateString(pacMath);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

    if (nStatus != 0)
    {
        mexErrMsgTxt("Failed to convert formula");
    }

    /* get the formula returned */
    nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
    pacMath = (char *) mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxOutput[0], (char *) pacMath, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
        mexErrMsgTxt("Cannot copy formula");
    }

    /* END OF HACK */
    ast = SBML_parseFormula(pacMath);
    LookForCSymbolTime(ast);
    LookForCSymbolDelay(ast);
    LookForCSymbolAvo(ast);

    InitialAssignment_setMath(pInitialAssignment, ast);
    

  	/* get sboTerm */
		mxSBOTerm = mxGetField(mxInitialAssignment, i, "sboTerm");
		nSBOTerm = (int)mxGetScalar(mxSBOTerm);

		SBase_setSBOTerm((SBase_t *) (pInitialAssignment), nSBOTerm);

		/* get annotations */
    pacAnnotations = ReadString(mxInitialAssignment, "annotation", "initialAssignment", i, nNoInitialAssignments);
		SBase_setAnnotationString((SBase_t *) (pInitialAssignment), pacAnnotations); 


    /* free any memory allocated */
	  mxFree(pacNotes);
	  mxFree(pacAnnotations);
   	mxFree(pacSymbol);
	  mxFree(pacMath);
    mxFree(pacMetaid);
	}
}

/**
 * NAME:    GetConstraint
 *
 * PARAMETERS:  mxArray of constraint structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the constraint mxArray structure
 *        and adds each constraint to the model
 */
void
GetConstraint ( mxArray * mxConstraint,
                unsigned int unSBMLLevel,
                unsigned int unSBMLVersion, 
                Model_t * sbmlModel )
{
  size_t nNoConstraints = mxGetNumberOfElements(mxConstraint);

  int nStatus;
  size_t nBuflen;

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacMessage;
  char * pacMath;
  int nSBOTerm;
  char * pacMetaid;

  mxArray * mxSBOTerm;
  mxArray *mxInput[1];
  mxArray *mxOutput[1];

  Constraint_t *pConstraint;
  ASTNode_t * ast;
  size_t i;


  for (i = 0; i < nNoConstraints; i++) 
  {
    pConstraint = Model_createConstraint(sbmlModel);

    /* get notes */
    pacNotes = ReadString(mxConstraint, "notes", "constraint", i, nNoConstraints);
    SBase_setNotesString((SBase_t *) (pConstraint), pacNotes);


    /* get metaid */
    pacMetaid = ReadString(mxConstraint, "metaid", "constraint", i, nNoConstraints);
    SBase_setMetaId((SBase_t *) (pConstraint), pacMetaid);

    /* get message */
    pacMessage = ReadString(mxConstraint, "message", "constraint", i, nNoConstraints);
    Constraint_setMessage(pConstraint, 
      XMLNode_convertStringToXMLNode(pacMessage, NULL));

    /* get Math */
    pacMath = ReadString(mxConstraint, "math", "constraint", i, nNoConstraints);

    /* temporary hack to convert MATLAB formula to MathML infix */

    mxInput[0] = mxCreateString(pacMath);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

    if (nStatus != 0)
    {
      mexErrMsgTxt("Failed to convert formula");
    }

    /* get the formula returned */
    nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
    pacMath = (char *) mxCalloc(nBuflen, sizeof(char));
    nStatus = mxGetString(mxOutput[0], (char *) pacMath, (mwSize)(nBuflen));

    if (nStatus != 0)
    {
      mexErrMsgTxt("Cannot copy formula");
    }

    /* END OF HACK */
    ast = SBML_parseFormula(pacMath);
    LookForCSymbolTime(ast);
    LookForCSymbolDelay(ast);
    LookForCSymbolAvo(ast);

    Constraint_setMath(pConstraint, ast);

    /* get sboTerm */
    mxSBOTerm = mxGetField(mxConstraint, i, "sboTerm");
    nSBOTerm = (int)mxGetScalar(mxSBOTerm);

    SBase_setSBOTerm((SBase_t *) (pConstraint), nSBOTerm);

    /* get annotations */
    pacAnnotations = ReadString(mxConstraint, "annotation", "constraint", i, nNoConstraints);
    SBase_setAnnotationString((SBase_t *) (pConstraint), pacAnnotations); 


    /* free any memory allocated */
    mxFree(pacNotes);
    mxFree(pacAnnotations);
    mxFree(pacMessage);
    mxFree(pacMath);
    mxFree(pacMetaid);
  }
}


/**
 * NAME:    GetStoichiometryMath
 *
 * PARAMETERS:  mxArray of initialAssignment structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the speciesReference
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the stoichiometryMath mxArray structure
 *        and adds each initialAssignment to the model
 */
void
GetStoichiometryMath ( mxArray * mxStoichiometryMath,
                       unsigned int unSBMLLevel,
                       unsigned int unSBMLVersion, 
                       SpeciesReference_t * sbmlSpeciesReference )
{
  int nStatus;
  size_t nBuflen;

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacMath;
  int nSBOTerm;
  char * pacMetaid;

  mxArray * mxSBOTerm;
  mxArray *mxInput[1];
  mxArray *mxOutput[1];

  StoichiometryMath_t *pStoichiometryMath;
  ASTNode_t *ast;

  if (mxStoichiometryMath == NULL) return;
  else if (mxGetNumberOfElements(mxStoichiometryMath) == 0) return;

  pStoichiometryMath = StoichiometryMath_create(unSBMLLevel, unSBMLVersion);

  /* get notes */
  pacNotes = ReadString(mxStoichiometryMath, "notes", "stoichiometryMath", 0, 0);
  SBase_setNotesString((SBase_t *) (pStoichiometryMath), pacNotes);


  /* get metaid */
  pacMetaid = ReadString(mxStoichiometryMath, "metaid", "stoichiometryMath", 0, 0);
  SBase_setMetaId((SBase_t *) (pStoichiometryMath), pacMetaid);

  /* get Math */
  pacMath = ReadString(mxStoichiometryMath, "math", "stoichiometryMath", 0, 0);

  /* temporary hack to convert MATLAB formula to MathML infix */

  mxInput[0] = mxCreateString(pacMath);
  nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

  if (nStatus != 0)
  {
    mexErrMsgTxt("Failed to convert formula");
  }

  /* get the formula returned */
  nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
  pacMath = (char *) mxCalloc(nBuflen, sizeof(char));
  nStatus = mxGetString(mxOutput[0], (char *) pacMath, (mwSize)(nBuflen));

  if (nStatus != 0)
  {
    mexErrMsgTxt("Cannot copy formula");
  }

  /* END OF HACK */
  ast = SBML_parseFormula(pacMath);
  LookForCSymbolTime(ast);
  LookForCSymbolDelay(ast);
  LookForCSymbolAvo(ast);

  StoichiometryMath_setMath(pStoichiometryMath, ast);

  /* get sboTerm */
  mxSBOTerm = mxGetField(mxStoichiometryMath, 0, "sboTerm");
  nSBOTerm = (int)mxGetScalar(mxSBOTerm);

  SBase_setSBOTerm((SBase_t *) (pStoichiometryMath), nSBOTerm);


  /* get annotations */
  pacAnnotations = ReadString(mxStoichiometryMath, "annotation", "stoichiometryMath", 0, 0);
  SBase_setAnnotationString((SBase_t *) (pStoichiometryMath), pacAnnotations); 


  SpeciesReference_setStoichiometryMath(sbmlSpeciesReference, pStoichiometryMath);

  /* free any memory allocated */
  mxFree(pacNotes);
  mxFree(pacAnnotations);
  mxFree(pacMath);
  mxFree(pacMetaid);
}


/**
 * NAME:    GetTrigger
 *
 * PARAMETERS:  mxArray of initialAssignment structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the speciesReference
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the Trigger mxArray structure
 *        and adds each initialAssignment to the model
 */
void
GetTrigger ( mxArray * mxTrigger,
             unsigned int unSBMLLevel,
             unsigned int unSBMLVersion, 
             Event_t * sbmlEvent )
{
  int nStatus;
  size_t nBuflen;

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacMath;
  int nSBOTerm;
  char * pacMetaid;
  int nPersistent;
  int nInitialValue;

  mxArray *mxPersistent, *mxInitialValue;
  mxArray * mxSBOTerm;
  mxArray *mxInput[1];
  mxArray *mxOutput[1];

  Trigger_t *pTrigger;
  ASTNode_t * ast;

  if (mxTrigger == NULL) return;
  else if (mxGetNumberOfElements(mxTrigger) == 0) return;
  pTrigger = Trigger_create(unSBMLLevel, unSBMLVersion);

  /* get notes */
  pacNotes = ReadString(mxTrigger, "notes", "trigger", 0, 0);
  SBase_setNotesString((SBase_t *) (pTrigger), pacNotes);


  /* get metaid */
  pacMetaid = ReadString(mxTrigger, "metaid", "trigger", 0, 0);
  SBase_setMetaId((SBase_t *) (pTrigger), pacMetaid);

  /* get Math */
  pacMath = ReadString(mxTrigger, "math", "trigger", 0, 0);

  /* temporary hack to convert MATLAB formula to MathML infix */

  mxInput[0] = mxCreateString(pacMath);
  nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

  if (nStatus != 0)
  {
    mexErrMsgTxt("Failed to convert formula");
  }

  /* get the formula returned */
  nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
  pacMath = (char *) mxCalloc(nBuflen, sizeof(char));
  nStatus = mxGetString(mxOutput[0], (char *) pacMath, (mwSize)(nBuflen));

  if (nStatus != 0)
  {
    mexErrMsgTxt("Cannot copy formula");
  }

  /* END OF HACK */
  ast = SBML_parseFormula(pacMath);
  LookForCSymbolTime(ast);
  LookForCSymbolDelay(ast);
  LookForCSymbolAvo(ast);

  Trigger_setMath(pTrigger, ast);


  /* get sboTerm */
  mxSBOTerm = mxGetField(mxTrigger, 0, "sboTerm");
  nSBOTerm = (int)mxGetScalar(mxSBOTerm);

  SBase_setSBOTerm((SBase_t *) (pTrigger), nSBOTerm);

  if (unSBMLLevel > 2)
  {
    /* get persistent */
    mxPersistent = mxGetField(mxTrigger, 0, "persistent");
    nPersistent = (int)mxGetScalar(mxPersistent);

    Trigger_setPersistent(pTrigger, nPersistent);

    /* get initialValue */
    mxInitialValue = mxGetField(mxTrigger, 0, "initialValue");
    nInitialValue = (int)mxGetScalar(mxInitialValue);

    Trigger_setInitialValue(pTrigger, nInitialValue);
  }

  /* get annotations */
  pacAnnotations = ReadString(mxTrigger, "annotation", "trigger", 0, 0);
  SBase_setAnnotationString((SBase_t *) (pTrigger), pacAnnotations); 


  Event_setTrigger(sbmlEvent, pTrigger);

  /* free any memory allocated */
  mxFree(pacNotes);
  mxFree(pacAnnotations);
  mxFree(pacMath);
  mxFree(pacMetaid);
}

/**
 * NAME:    GetDelay
 *
 * PARAMETERS:  mxArray of initialAssignment structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the speciesReference
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the Delay mxArray structure
 *        and adds each initialAssignment to the model
 */
void
GetDelay ( mxArray * mxDelay,
           unsigned int unSBMLLevel,
           unsigned int unSBMLVersion, 
           Event_t * sbmlEvent )
{
  int nStatus;
  size_t nBuflen;

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacMath;
  int nSBOTerm;
  char * pacMetaid;

  mxArray * mxSBOTerm;
  mxArray *mxInput[1];
  mxArray *mxOutput[1];

  Delay_t *pDelay;
  ASTNode_t * ast;
  if (mxDelay == NULL) return;
  else if (mxGetNumberOfElements(mxDelay) == 0) return;
  pDelay = Delay_create(unSBMLLevel, unSBMLVersion);

  /* get notes */
  pacNotes = ReadString(mxDelay, "notes", "delay", 0, 0);
  SBase_setNotesString((SBase_t *) (pDelay), pacNotes);


  /* get metaid */
  pacMetaid = ReadString(mxDelay, "metaid", "delay", 0, 0);
  SBase_setMetaId((SBase_t *) (pDelay), pacMetaid);

  /* get Math */
  pacMath = ReadString(mxDelay, "math", "delay", 0, 0);

  /* temporary hack to convert MATLAB formula to MathML infix */

  mxInput[0] = mxCreateString(pacMath);
  nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

  if (nStatus != 0)
  {
    mexErrMsgTxt("Failed to convert formula");
  }

  /* get the formula returned */
  nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
  pacMath = (char *) mxCalloc(nBuflen, sizeof(char));
  nStatus = mxGetString(mxOutput[0], (char *) pacMath, (mwSize)(nBuflen));

  if (nStatus != 0)
  {
    mexErrMsgTxt("Cannot copy formula");
  }

  /* END OF HACK */
  if (strcmp(pacMath, ""))
  {
    ast = SBML_parseFormula(pacMath);
    LookForCSymbolTime(ast);
    LookForCSymbolDelay(ast);
    LookForCSymbolAvo(ast);

    Delay_setMath(pDelay, ast);
  }

  /* get sboTerm */
  mxSBOTerm = mxGetField(mxDelay, 0, "sboTerm");
  nSBOTerm = (int)mxGetScalar(mxSBOTerm);

  SBase_setSBOTerm((SBase_t *) (pDelay), nSBOTerm);

  /* get annotations */
  pacAnnotations = ReadString(mxDelay, "annotation", "delay", 0, 0);
  SBase_setAnnotationString((SBase_t *) (pDelay), pacAnnotations); 


  Event_setDelay(sbmlEvent, pDelay);

  /* free any memory allocated */
  mxFree(pacNotes);
  mxFree(pacAnnotations);
  mxFree(pacMath);
  mxFree(pacMetaid);
}

/**
 * NAME:    GetPriority
 *
 * PARAMETERS:  mxArray of initialAssignment structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the speciesReference
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the Priority mxArray structure
 *        and adds each initialAssignment to the model
 */
void
GetPriority ( mxArray * mxPriority,
              unsigned int unSBMLLevel,
              unsigned int unSBMLVersion, 
              Event_t * sbmlEvent )
{
  int nStatus;
  size_t nBuflen;

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  char * pacMath;
  int nSBOTerm;
  char * pacMetaid;

  mxArray * mxSBOTerm;
  mxArray *mxInput[1];
  mxArray *mxOutput[1];

  Priority_t *pPriority;
  ASTNode_t * ast;
  if (mxPriority == NULL) return;
  else if (mxGetNumberOfElements(mxPriority) == 0) return;
  pPriority = Priority_create(unSBMLLevel, unSBMLVersion);

  /* get notes */
  pacNotes = ReadString(mxPriority, "notes", "priority", 0, 0);
  SBase_setNotesString((SBase_t *) (pPriority), pacNotes);


  /* get metaid */
  pacMetaid = ReadString(mxPriority, "metaid", "priority", 0, 0);
  SBase_setMetaId((SBase_t *) (pPriority), pacMetaid);

  /* get Math */
  pacMath = ReadString(mxPriority, "math", "priority", 0, 0);

  /* temporary hack to convert MATLAB formula to MathML infix */

  mxInput[0] = mxCreateString(pacMath);
  nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "ConvertFormulaToMathML");

  if (nStatus != 0)
  {
    mexErrMsgTxt("Failed to convert formula");
  }

  /* get the formula returned */
  nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
  pacMath = (char *) mxCalloc(nBuflen, sizeof(char));
  nStatus = mxGetString(mxOutput[0], (char *) pacMath, (mwSize)(nBuflen));

  if (nStatus != 0)
  {
    mexErrMsgTxt("Cannot copy formula");
  }

  /* END OF HACK */
  if (strcmp(pacMath, ""))
  {
    ast = SBML_parseFormula(pacMath);
    LookForCSymbolTime(ast);
    LookForCSymbolDelay(ast);
    LookForCSymbolAvo(ast);

    Priority_setMath(pPriority, ast);
  }

  /* get sboTerm */
  mxSBOTerm = mxGetField(mxPriority, 0, "sboTerm");
  nSBOTerm = (int)mxGetScalar(mxSBOTerm);

  SBase_setSBOTerm((SBase_t *) (pPriority), nSBOTerm);

  /* get annotations */
  pacAnnotations = ReadString(mxPriority, "annotation", "priority", 0, 0);
  SBase_setAnnotationString((SBase_t *) (pPriority), pacAnnotations); 


  Event_setPriority(sbmlEvent, pPriority);

  /* free any memory allocated */
  mxFree(pacNotes);
  mxFree(pacAnnotations);
  mxFree(pacMath);
  mxFree(pacMetaid);
}

#ifdef USE_FBC

/**
 * NAME:    GetFluxBound
 *
 * PARAMETERS:  mxArray of FluxBound structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the FluxBound mxArray structure
 *        and adds each FluxBound to the model
 */
void
GetFluxBound ( mxArray * mxFluxBound,
               unsigned int unSBMLLevel,
               unsigned int unSBMLVersion, 
               unsigned int unFBCVersion, 
			         Model_t * sbmlModel )
{
	size_t nNoFluxBounds = mxGetNumberOfElements(mxFluxBound);
  
	/* values */
	char * pacNotes;
	char * pacAnnotations;
  int nSBOTerm;
	char * pacMetaid;
	char * pacId;
  char * pacReaction;
  char * pacOperation;
  double dValue;
  unsigned int unIsSetValue;

	mxArray * mxSBOTerm;
	mxArray * mxValue, *mxIsSetValue;

	FluxBound_t *pFluxBound;
	size_t i;

  SBasePlugin_t *plugin = SBase_getPlugin((SBase_t *)(sbmlModel), "fbc");

	for (i = 0; i < nNoFluxBounds; i++) 
	{
		pFluxBound = FluxBound_create(unSBMLLevel, unSBMLVersion,
                                                     unFBCVersion);

		/* get notes */
    pacNotes = ReadString(mxFluxBound, "notes", "fbc_fluxBound", i, nNoFluxBounds);
		SBase_setNotesString((SBase_t *) (pFluxBound), pacNotes);


		/* get metaid */
    pacMetaid = ReadString(mxFluxBound, "metaid", "fbc_fluxBound", i, nNoFluxBounds);
		SBase_setMetaId((SBase_t *) (pFluxBound), pacMetaid);


 		/* get annotations */
    pacAnnotations = ReadString(mxFluxBound, "annotation", "fbc_fluxBound", i, nNoFluxBounds);
		SBase_setAnnotationString((SBase_t *) (pFluxBound), pacAnnotations); 


 	/* get sboTerm */
		mxSBOTerm = mxGetField(mxFluxBound, i, "sboTerm");
		nSBOTerm = (int)mxGetScalar(mxSBOTerm);

		SBase_setSBOTerm((SBase_t *) (pFluxBound), nSBOTerm);

		/* get id */
    pacId = ReadString(mxFluxBound, "fbc_id", "fbc_fluxBound", i, nNoFluxBounds);
		FluxBound_setId(pFluxBound, pacId);

		/* get Reaction */
    pacReaction = ReadString(mxFluxBound, "fbc_reaction", "fbc_fluxBound", i, nNoFluxBounds);
		FluxBound_setReaction(pFluxBound, pacReaction);

		/* get Operation */
    pacOperation = ReadString(mxFluxBound, "fbc_operation", "fbc_fluxBound", i, nNoFluxBounds);
		FluxBound_setOperation(pFluxBound, pacOperation);

    /* get value */
		mxIsSetValue = mxGetField(mxFluxBound, i, "isSetfbc_value");
		unIsSetValue = (unsigned int)(mxGetScalar(mxIsSetValue));

    if (unIsSetValue == 1)
    {
 		  mxValue = mxGetField(mxFluxBound, i, "fbc_value");
		  dValue = mxGetScalar(mxValue);

		  FluxBound_setValue(pFluxBound, dValue);
    }


    /* free any memory allocated */
	  mxFree(pacNotes);
	  mxFree(pacAnnotations);
    mxFree(pacMetaid);
    mxFree(pacId);
    mxFree(pacReaction);
    mxFree(pacOperation);

    /* add this flux bound to the model */
    FbcModelPlugin_addFluxBound(plugin, pFluxBound);
	}
}

/**
 * NAME:    GetObjective
 *
 * PARAMETERS:  mxArray of Objective structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the Objective mxArray structure
 *        and adds each Objective to the model
 */
void
GetObjective ( mxArray * mxObjective,
               unsigned int unSBMLLevel,
               unsigned int unSBMLVersion, 
               unsigned int unFBCVersion, 
               Model_t * sbmlModel )
{
  size_t nNoObjectives = mxGetNumberOfElements(mxObjective);

  /* values */
  char * pacNotes;
  char * pacAnnotations;
  int nSBOTerm;
  char * pacMetaid;
  char * pacId;
  char * pacType;

  mxArray * mxSBOTerm;
  mxArray * mxFluxObjectives;

  Objective_t *pObjective;
  size_t i;

  SBasePlugin_t *plugin = SBase_getPlugin((SBase_t *)(sbmlModel), "fbc");

  for (i = 0; i < nNoObjectives; i++) 
  {
    pObjective = Objective_create(unSBMLLevel, unSBMLVersion,
      unFBCVersion);

    /* get notes */
    pacNotes = ReadString(mxObjective, "notes", "fbc_objective", i, nNoObjectives);
    SBase_setNotesString((SBase_t *) (pObjective), pacNotes);


    /* get metaid */
    pacMetaid = ReadString(mxObjective, "metaid", "fbc_objective", i, nNoObjectives);
    SBase_setMetaId((SBase_t *) (pObjective), pacMetaid);


    /* get annotations */
    pacAnnotations = ReadString(mxObjective, "annotation", "fbc_objective", i, nNoObjectives);
    SBase_setAnnotationString((SBase_t *) (pObjective), pacAnnotations); 


    /* get sboTerm */
    mxSBOTerm = mxGetField(mxObjective, i, "sboTerm");
    nSBOTerm = (int)mxGetScalar(mxSBOTerm);

    SBase_setSBOTerm((SBase_t *) (pObjective), nSBOTerm);

    /* get id */
    pacId = ReadString(mxObjective, "fbc_id", "fbc_objective", i, nNoObjectives);
    Objective_setId(pObjective, pacId);

    /* get Type */
    pacType = ReadString(mxObjective, "fbc_type", "fbc_objective", i, nNoObjectives);
    Objective_setType(pObjective, pacType);


    /* get list of fluxobjectives */
    mxFluxObjectives = mxGetField(mxObjective, i, "fbc_fluxObjective");
    GetFluxObjective(mxFluxObjectives, unSBMLLevel, unSBMLVersion, 
      unFBCVersion, pObjective);

    /* free any memory allocated */
    mxFree(pacNotes);
    mxFree(pacAnnotations);
    mxFree(pacMetaid);
    mxFree(pacId);
    mxFree(pacType);

    /* add this flux bound to the model */
    FbcModelPlugin_addObjective(plugin, pObjective);
  }
}

/**
 * NAME:    GetFluxObjective
 *
 * PARAMETERS:  mxArray of FluxObjective structures
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *				      Pointer to the model
 *
 * RETURNS:    void
 *
 * FUNCTION:  gets data from the FluxObjective mxArray structure
 *        and adds each FluxObjective to the model
 */
void
GetFluxObjective ( mxArray * mxFluxObjective,
                   unsigned int unSBMLLevel,
                   unsigned int unSBMLVersion, 
                   unsigned int unFBCVersion, 
			             Objective_t * pObjective )
{
	size_t nNoFluxObjectives = mxGetNumberOfElements(mxFluxObjective);
  
	/* values */
	char * pacNotes;
	char * pacAnnotations;
  int nSBOTerm;
	char * pacMetaid;
	char * pacReaction;
  double dCoefficient;
  unsigned int unIsSetCoefficient = 0;

	mxArray * mxSBOTerm;
	mxArray * mxCoefficient, *mxIsSetCoefficient;

	FluxObjective_t *pFluxObjective;
	size_t i;

	for (i = 0; i < nNoFluxObjectives; i++) 
	{
		pFluxObjective = FluxObjective_create(unSBMLLevel, unSBMLVersion,
                                                     unFBCVersion);

		/* get notes */
    pacNotes = ReadString(mxFluxObjective, "notes", "fbc_fluxObjective", i, nNoFluxObjectives);
		SBase_setNotesString((SBase_t *) (pFluxObjective), pacNotes);


		/* get metaid */
    pacMetaid = ReadString(mxFluxObjective, "metaid", "fbc_fluxObjective", i, nNoFluxObjectives);
		SBase_setMetaId((SBase_t *) (pFluxObjective), pacMetaid);


		/* get annotations */
    pacAnnotations = ReadString(mxFluxObjective, "annotation", "fbc_fluxObjective", i, nNoFluxObjectives);
		SBase_setAnnotationString((SBase_t *) (pFluxObjective), pacAnnotations); 


  	/* get sboTerm */
		mxSBOTerm = mxGetField(mxFluxObjective, i, "sboTerm");
		nSBOTerm = (int)mxGetScalar(mxSBOTerm);

		SBase_setSBOTerm((SBase_t *) (pFluxObjective), nSBOTerm);

		/* get Reaction */
    pacReaction = ReadString(mxFluxObjective, "fbc_reaction", "fbc_fluxObjective", i, nNoFluxObjectives);
		FluxObjective_setReaction(pFluxObjective, pacReaction);

		/* get coefficient */
		mxIsSetCoefficient = mxGetField(mxFluxObjective, i, "isSetfbc_coefficient");
		unIsSetCoefficient = (unsigned int)(mxGetScalar(mxIsSetCoefficient));

    if (unIsSetCoefficient == 1)
    {
		  mxCoefficient = mxGetField(mxFluxObjective, i, "fbc_coefficient");
		  dCoefficient = mxGetScalar(mxCoefficient);

		  FluxObjective_setCoefficient(pFluxObjective, dCoefficient);
    }

    /* free any memory allocated */
	  mxFree(pacNotes);
	  mxFree(pacAnnotations);
    mxFree(pacMetaid);
    mxFree(pacReaction);

    /* add this flux bound to the model */
    Objective_addFluxObjective(pObjective, pFluxObjective);
	}
}
#endif
