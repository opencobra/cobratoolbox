/**
 * \file    TranslateSBML.c
 * \brief   MATLAB code for translating SBML document into MATLAB structure
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

#include <stdio.h>
#include <string.h>

#include <mex.h>

#ifndef USE_OCTAVE
#include <matrix.h>
#endif

#include <sbml/SBMLReader.h>
#include <sbml/SBMLTypes.h>
#include <sbml/util/util.h>

#include <sbml/extension/SBasePlugin.h>

#ifdef USE_FBC

#include <sbml/packages/fbc/extension/FbcExtension.h>
#include <sbml/packages/fbc/extension/FbcModelPlugin.h>
#include <sbml/packages/fbc/extension/FbcSpeciesPlugin.h>

#include <sbml/packages/fbc/sbml/FluxBound.h>
#include <sbml/packages/fbc/sbml/FluxObjective.h>
#include <sbml/packages/fbc/sbml/Objective.h>

#endif

void GetUnitDefinition     (Model_t *, unsigned int, unsigned int);
void GetCompartment        (Model_t *, unsigned int, unsigned int);
void GetParameter          (Model_t *, unsigned int, unsigned int);
void GetReaction           (Model_t *, unsigned int, unsigned int);
void GetSpecies            (Model_t *, unsigned int, unsigned int);
void GetRule               (Model_t *, unsigned int, unsigned int);
void GetFunctionDefinition (Model_t *, unsigned int, unsigned int);
void GetEvent              (Model_t *, unsigned int, unsigned int);
void GetCompartmentType    (Model_t *, unsigned int, unsigned int);
void GetSpeciesType        (Model_t *, unsigned int, unsigned int);
void GetInitialAssignment  (Model_t *, unsigned int, unsigned int);
void GetConstraint         (Model_t *, unsigned int, unsigned int);

void GetUnit (UnitDefinition_t *, unsigned int, unsigned int);

void GetReactants  (Reaction_t *, unsigned int, unsigned int);
void GetProducts   (Reaction_t *, unsigned int, unsigned int);
void GetKineticLaw (Reaction_t *, unsigned int, unsigned int);
void GetModifier   (Reaction_t *, unsigned int, unsigned int);

void GetKineticLawParameters (KineticLaw_t *, unsigned int, unsigned int);

void GetStoichiometryMath (SpeciesReference_t *, unsigned int, unsigned int);

void GetDelay           (Event_t *, unsigned int, unsigned int);
void GetTrigger         (Event_t *, unsigned int, unsigned int);
void GetEventAssignment (Event_t *, unsigned int, unsigned int);
void GetPriority        (Event_t *, unsigned int, unsigned int);

void GetNamespaces   (SBMLDocument_t *);



mxArray * CreateIntScalar (int);
const char    * TypecodeToChar  (int);
const char    * RuleType_toString (RuleType_t);
const char    * ErrorSeverity_toString(unsigned int);

void LookForCSymbolTime(ASTNode_t *);
void LookForCSymbolDelay(ASTNode_t *);
void LookForCSymbolAvo(ASTNode_t *);

static mxArray * mxSpeciesReturn             = NULL;
static mxArray * mxCompartReturn             = NULL;
static mxArray * mxParameterReturn           = NULL;
static mxArray * mxUnitReturn                = NULL;
static mxArray * mxUnitDefReturn             = NULL;
static mxArray * mxReactionReturn            = NULL;
static mxArray * mxReactantReturn            = NULL;
static mxArray * mxProductReturn             = NULL;
static mxArray * mxKineticLawReturn          = NULL;
static mxArray * mxKineticLawParameterReturn = NULL;
static mxArray * mxListRuleReturn            = NULL;
static mxArray * mxFunctionDefReturn         = NULL;
static mxArray * mxEventReturn               = NULL;
static mxArray * mxModifierReturn            = NULL;
static mxArray * mxEventAssignReturn         = NULL;
static mxArray * mxCompartmentTypeReturn     = NULL;
static mxArray * mxSpeciesTypeReturn         = NULL;
static mxArray * mxInitialAssignReturn       = NULL;
static mxArray * mxConstraintReturn          = NULL;
static mxArray * mxNSReturn                  = NULL;
static mxArray * mxTriggerReturn             = NULL;
static mxArray * mxDelayReturn               = NULL;
static mxArray * mxStoichiometryMathReturn   = NULL;
static mxArray * mxPriorityReturn            = NULL;

const char *    pacCSymbolTime              = NULL;
const char *    pacCSymbolDelay              = NULL;
const char *    pacCSymbolAvo              = NULL;

int fbcPresent = 0;

#ifdef USE_FBC

void GetFluxBound          (Model_t *, unsigned int, unsigned int);
void GetObjective          (Model_t *, unsigned int, unsigned int);
void GetFluxObjective   (Objective_t *, unsigned int, unsigned int, unsigned int);

#endif

static mxArray * mxFluxBoundReturn           = NULL;
static mxArray * mxObjectiveReturn           = NULL;
static mxArray * mxFluxObjectiveReturn       = NULL;

const char *    pacActiveObj              = NULL;

#ifndef USE_FBC

typedef enum
{
    SBML_FBC_ASSOCIATION      = 800
   ,SBML_FBC_FLUXBOUND        = 801
   ,SBML_FBC_FLUXOBJECTIVE    = 802
   ,SBML_FBC_GENEASSOCIATION  = 803
   ,SBML_FBC_OBJECTIVE        = 804
} SBMLFbcTypeCode_t;

#endif

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
 *            any returns are made through the mxArray * prhs
 */
void
mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* variables */
  char *pacFilename = NULL;
  char *pacTempString1, *pacTempString2;
  size_t nBufferLen, nBuflen;
  int nStatus;
  FILE *fp;
  mxArray * mxFilename[2], * mxExt[1];
  int validateFlag = 0;
  int listFlag = 0;
  int verboseFlag = 1;
 
  int nNoFields_l1v1 = 13;
  int nNoFields_l2v1 = 19;
  int nNoFields_l2v2 = 24;
  int nNoFields_l2v3 = 24;
  int nNoFields_l2v4 = 24;
  int nNoFields_l3v1 = 30;
  int nNoFields_l3v1_fbc = 34;

  const char *error_struct[] =
  {
    "line",
    "errorId",
    "severity",
    "message"
  };

  const char *field_names_l1v1[] =
  {
    "typecode",
    "notes",
    "annotation",
    "SBML_level",
    "SBML_version",
    "name",
    "unitDefinition",
    "compartment",
    "species",
    "parameter",
    "rule",
    "reaction",
    "namespaces"
  };

  const char *field_names_l2v1[] =
  {
    "typecode",
    "metaid",
    "notes",
    "annotation",
    "SBML_level",
    "SBML_version",
    "name",
    "id",
    "functionDefinition",
    "unitDefinition",
    "compartment",
    "species",
    "parameter",
    "rule",
    "reaction",
    "event",
    "time_symbol",
    "delay_symbol",
    "namespaces"
  };

  const char *field_names_l2v2[] =
  {
    "typecode",
    "metaid",
    "notes",
    "annotation",
    "SBML_level",
    "SBML_version",
    "name",
    "id",
    "sboTerm",
    "functionDefinition",
    "unitDefinition",
    "compartmentType",
    "speciesType",
    "compartment",
    "species",
    "parameter",
    "initialAssignment",
    "rule",
    "constraint",
    "reaction",
    "event",
    "time_symbol",
    "delay_symbol",
    "namespaces"
  };

  const char *field_names_l2v3[] =
  {
    "typecode",
    "metaid",
    "notes",
    "annotation",
    "SBML_level",
    "SBML_version",
    "name",
    "id",
    "sboTerm",
    "functionDefinition",
    "unitDefinition",
    "compartmentType",
    "speciesType",
    "compartment",
    "species",
    "parameter",
    "initialAssignment",
    "rule",
    "constraint",
    "reaction",
    "event",
    "time_symbol",
    "delay_symbol",
    "namespaces"
  };

  const char *field_names_l2v4[] =
  {
    "typecode",
    "metaid",
    "notes",
    "annotation",
    "SBML_level",
    "SBML_version",
    "name",
    "id",
    "sboTerm",
    "functionDefinition",
    "unitDefinition",
    "compartmentType",
    "speciesType",
    "compartment",
    "species",
    "parameter",
    "initialAssignment",
    "rule",
    "constraint",
    "reaction",
    "event",
    "time_symbol",
    "delay_symbol",
    "namespaces"
  };

  const char *field_names_l3v1[] =
  {
    "typecode",
    "metaid",
    "notes",
    "annotation",
    "SBML_level",
    "SBML_version",
    "name",
    "id",
    "timeUnits",
    "substanceUnits",
    "volumeUnits",
    "areaUnits",
    "lengthUnits",
    "extentUnits",
    "conversionFactor",
    "sboTerm",
    "functionDefinition",
    "unitDefinition",
    "compartment",
    "species",
    "parameter",
    "initialAssignment",
    "rule",
    "constraint",
    "reaction",
    "event",
    "time_symbol",
    "delay_symbol",
    "avogadro_symbol",
    "namespaces"
  };

  const char *field_names_l3v1_fbc[] =
  {
    "typecode",
    "metaid",
    "notes",
    "annotation",
    "SBML_level",
    "SBML_version",
    "fbc_version",
    "name",
    "id",
    "timeUnits",
    "substanceUnits",
    "volumeUnits",
    "areaUnits",
    "lengthUnits",
    "extentUnits",
    "conversionFactor",
    "sboTerm",
    "functionDefinition",
    "unitDefinition",
    "compartment",
    "species",
    "parameter",
    "initialAssignment",
    "rule",
    "constraint",
    "reaction",
    "event",
    "fbc_fluxBound",
    "fbc_objective",
    "fbc_activeObjective",
    "time_symbol",
    "delay_symbol",
    "avogadro_symbol",
    "namespaces"
  };

  mwSize dims[2] = {1, 1};
  mwSize errordims[2];

  SBMLDocument_t *sbmlDocument;
  Model_t *sbmlModel;
  const XMLError_t *e;
  const char * pacName = NULL;
  const char * pacId = NULL;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacTypecode = NULL;
  const char * pacTimeUnits = NULL;
  const char * pacSubstanceUnits = NULL;
  const char * pacVolumeUnits = NULL;
  const char * pacAreaUnits = NULL;
  const char * pacLengthUnits = NULL;
  const char * pacExtentUnits = NULL;
  const char * pacConversionFactor = NULL;
  int nSBO = -1;
  unsigned int unSBMLLevel;
  unsigned int unSBMLVersion;
  unsigned int unFBCVersion;
  unsigned int totalerrors = 0;
  unsigned int warnings = 0;
  unsigned int errors = 0;
  mxArray * mxErrors[1], *mxNone[1];
  char * pacError;
  char * pacErrors1, * pacError1;
  unsigned int i;
  mxArray *mxPrompt[2], *mxReply[1], *mxWarn[1], *mxPrompt1[2];
  const char *pacPromptValid = "Do you want to validate the model? Enter y/n ";
  const char *pacPromptLoadAnyway = "Do you want to load the model anyway? Enter y/n ";
  const char *pacPromptValidAnyway = "There are errors found during reading. Do you want to continue validation? Enter y/n ";
  char *pacReply;
  char *pacWarn;
  const char *pacNone = "No model returned.";
  const char *pacList = "Do you want to exclude the warnings from the list? Enter y/n ";
  unsigned int usingOctave = 0;
  mxArray * mxOctave[1];
  int outputErrors = 0;
  char * msgTxt = NULL;
  const char *pacL3packages = "Level 3 packages detected. Information WILL be lost.";
  int packages = 0;

  pacCSymbolTime = NULL;
  pacCSymbolDelay = NULL;
  pacCSymbolAvo = NULL;
  pacActiveObj = NULL;

  fbcPresent = 0;
  
  /* determine whether we are in octave or matlab */

  mexCallMATLAB(1, mxOctave, 0, NULL, "isoctave");
  
  nBuflen = (mxGetM(mxOctave[0])*mxGetN(mxOctave[0])+1);
  pacTempString1 = (char *) mxCalloc(nBuflen, sizeof(char));
  nStatus = mxGetString(mxOctave[0], pacTempString1, (mwSize)(nBuflen));
  mxDestroyArray(mxOctave[0]);

  if (nStatus != 0)
  {
    mexErrMsgTxt("Bad octave read");
  }

  if (!(strcmp_insensitive(pacTempString1, "0") == 0))
    usingOctave = 1;

 /**
   * check number and type of arguments
   * cannot write to more than two output argument
   */
  if (nlhs > 2)
  {
    mexErrMsgTxt("Too many output arguments.");
  }

  if (nlhs > 1)
  {
    outputErrors = 1;
  }
  /** 
   * need the name of the sbml file to translate
   * can supply by name
   * or user can browse the system
   */

   /* argument supplied */
   if (nrhs > 0)
   {
       /**
        * MUST be at least one input argument
        * first argument must be a row vector of type string
        * i.e. the filename containing the sbml to be read
        */
        if ((nrhs > 3) || (mxIsChar(prhs[0]) != 1) || (mxGetM(prhs[0]) != 1))
        {
            mexErrMsgTxt("Usage: = TranslateSBML(filename, validFlag(optional), verboseFlag(optional))");
        }
        
        if (nrhs > 1 && !mxIsNumeric(prhs[1]))
        {
            mexErrMsgTxt("Usage:TranslateSBML(filename, validFlag(optional), verboseFlag(optional))\n validFlag is optional but must be a number");
        }

        if (nrhs > 2 && !mxIsNumeric(prhs[2]))
        {
            mexErrMsgTxt("Usage:TranslateSBML(filename, validFlag(optional), verboseFlag(optional))\n verboseFlag is optional but must be a number");
        }
       /**
        * get length of input string 
        * allocate memory and copy to a C string
        */
        nBufferLen  = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;
        pacFilename = (char *) mxCalloc(nBufferLen, sizeof(char));
        nStatus     = mxGetString(prhs[0], pacFilename, (mwSize)(nBufferLen));
 
        if (nStatus != 0)
        {
            mexErrMsgTxt("Not enough space to read filename");
        }

       /* check that the file exists */
        fp = fopen( pacFilename, "r");
        if(fp == NULL)
        {
          msgTxt = (char *) mxCalloc(nBufferLen+35, sizeof(char));
          sprintf(msgTxt, "File %s does not exist on this path", pacFilename);
          mexErrMsgTxt(msgTxt);
        }
        else
        {
            fclose(fp);
        }
        
        /* if a second argument has been given this is the flag indicating
         * whether to validate the Model or not
         */
        if (nrhs > 1)
        {
          validateFlag = (int) mxGetScalar(prhs[1]);   
        }
        
        /* if a third argument has been given this is the flag indicating
         * whether to print out errors or not
         */
        if (nrhs > 2)
        {
          verboseFlag = (int) mxGetScalar(prhs[2]);   
        }
            
   }
   /* no argument supplied - browse */
   else
   {
     if (usingOctave == 0)
     {
        /* extension to look for */
        mxExt[0] = mxCreateString(".xml");
        nStatus = mexCallMATLAB(2, mxFilename, 1, mxExt, "uigetfile");
        
        if (nStatus != 0)
        {
            mexErrMsgTxt("Failed to read filename");
        }
 
        /* get the filename returned */
        nBuflen = (mxGetM(mxFilename[0])*mxGetN(mxFilename[0])+1);
        pacTempString1 = (char *) mxCalloc(nBuflen, sizeof(char));
        nStatus = mxGetString(mxFilename[0], pacTempString1, (mwSize)(nBuflen));
        
        if (nStatus != 0)
        {
            mexErrMsgTxt("Cannot copy filename");
        }

        nBufferLen = (mxGetM(mxFilename[1])*mxGetN(mxFilename[1])+1);
        pacTempString2 = (char *) mxCalloc(nBufferLen, sizeof(char));
        nStatus = mxGetString(mxFilename[1], pacTempString2, (mwSize)(nBufferLen));
        
        if (nStatus != 0)
        {
            mexErrMsgTxt("Cannot copy path");
        }

        pacFilename = (char *) mxCalloc(nBufferLen+nBuflen, sizeof(char));
		    strcpy(pacFilename, pacTempString2);
        strcat(pacFilename, pacTempString1);
 
        /* check that the file exists */
        fp = fopen( pacFilename, "r");
        if(fp == NULL)
        {
          msgTxt = (char *) mxCalloc(nBufferLen+35, sizeof(char));
          sprintf(msgTxt, "File %s does not exist on this path", pacFilename);
          mexErrMsgTxt(msgTxt);
        }
        else
        {
            fclose(fp);
        }
    
        mxPrompt[0]= mxCreateString(pacPromptValid);
        mxPrompt[1]= mxCreateString("s");
        mexCallMATLAB(1, mxReply, 2, mxPrompt, "input");
        mxDestroyArray(mxPrompt[0]);
        mxDestroyArray(mxPrompt[1]);

        nBufferLen = (mxGetM(mxReply[0])*mxGetN(mxReply[0])+1);
        pacReply = (char *) mxCalloc(nBufferLen, sizeof(char));
        mxGetString(mxReply[0], pacReply, (mwSize)(nBufferLen));
        mxDestroyArray(mxReply[0]);
  
        if (strcmp_insensitive(pacReply, "y") == 0)
        {
            validateFlag = 1;
        }
     }
     else
     {
       mexErrMsgTxt("Octave requires the filename as argument"); 
     } 
  }


  sbmlDocument = readSBML(pacFilename);

  /* at this point - if there have been fatal errors 
   * dont try anything else
   */
  if (SBMLDocument_getModel(sbmlDocument) == NULL)
  {
    pacReply = (char *)mxCalloc(3,sizeof(char));
    pacReply[0] = 'n';
    pacReply[1] = '\0';
    /*mxPrompt[0] = mxCreateString("Fatal errors were encountered; read was abandoned");
    */
    if (outputErrors == 1)
    {
      totalerrors = SBMLDocument_getNumErrors(sbmlDocument);
      errordims[0] = 1;
      errordims[1] = totalerrors;
      plhs[1] = mxCreateStructArray(2, errordims, 4, error_struct);
      for (i = 0; i < SBMLDocument_getNumErrors(sbmlDocument); i++)
      {
        e = (const XMLError_t *) SBMLDocument_getError(sbmlDocument, i);
        mxSetField(plhs[1], i, "line", CreateIntScalar(XMLError_getLine(e)));
        mxSetField(plhs[1], i, "errorId", CreateIntScalar(XMLError_getErrorId(e)));
        mxSetField(plhs[1], i, "severity", mxCreateString(ErrorSeverity_toString(XMLError_getSeverity(e))));
        mxSetField(plhs[1], i, "message", mxCreateString(XMLError_getMessage(e)));
      }
    }
  }
  else
  {
    /* check for errors at read */
    totalerrors = SBMLDocument_getNumErrors(sbmlDocument);

    if (validateFlag > 0)
    {
      if (verboseFlag > 0 && totalerrors > 0)
      {
        mxPrompt[0]= mxCreateString(pacPromptValidAnyway);
        mxPrompt[1]= mxCreateString("s");
        mexCallMATLAB(1, mxReply, 2, mxPrompt, "input");
        mxDestroyArray(mxPrompt[0]);
        mxDestroyArray(mxPrompt[1]);

        nBufferLen = (mxGetM(mxReply[0])*mxGetN(mxReply[0])+1);
        pacReply = (char *) mxCalloc(nBufferLen, sizeof(char));
        mxGetString(mxReply[0], pacReply, (mwSize)(nBufferLen));
        mxDestroyArray(mxReply[0]);
  
        if (strcmp_insensitive(pacReply, "y") == 0)
        {
            totalerrors += SBMLDocument_checkConsistency(sbmlDocument);
        }
      }
      else
      {
        totalerrors += SBMLDocument_checkConsistency(sbmlDocument);
      }
    }

    /* divide the totalerrors into errors 
     * and warnings
     */
    for (i = 0; i < totalerrors; i++)
    {
      e = (const XMLError_t *) SBMLDocument_getError(sbmlDocument, i);
      if (XMLError_getSeverity(e) < 2)
      {
        warnings = warnings + 1;
      }
    }
    errors = totalerrors - warnings;

    if (outputErrors == 1)
    {
      errordims[0] = 1;
      errordims[1] = totalerrors;
      plhs[1] = mxCreateStructArray(2, errordims, 4, error_struct);
    }
  
  /**
   *  if errors occur report these 
   *  promt user as to whether to import the Model    
   */

    if (totalerrors != 0)
    {
      pacErrors1 = (char *) mxCalloc(60, sizeof(char));
      pacError1  = (char *) mxCalloc(20, sizeof(char));

      sprintf(pacErrors1, "The model contains %u errors", errors);
      if (warnings > 0) 
      {
        sprintf(pacError1, " and %u warnings.\n", warnings);
      }
      else
      {
        sprintf(pacError1, ".\n");
      }
      pacErrors1 = safe_strcat(pacErrors1, pacError1);
      

      if (warnings > 0)
      {
        if (verboseFlag == 1)
        {
          mxPrompt[0]= mxCreateString(pacList);
          mxPrompt[1]= mxCreateString("s");
          mxErrors[0] = mxCreateString(pacErrors1);

          mexCallMATLAB(0, NULL, 1, mxErrors, "disp");
          mxDestroyArray(mxErrors[0]);
          mexCallMATLAB(1, mxWarn, 2, mxPrompt, "input");

          nBufferLen = (mxGetM(mxWarn[0])*mxGetN(mxWarn[0])+1);
          pacWarn = (char *) mxCalloc(nBufferLen, sizeof(char));
          mxGetString(mxWarn[0], pacWarn, (mwSize)(nBufferLen));

          if (strcmp_insensitive(pacWarn, "n") == 0) 
          {
            listFlag = 1;
          }

          mxDestroyArray(mxPrompt[0]);
          mxDestroyArray(mxPrompt[1]);
          mxDestroyArray(mxWarn[0]);

        }
      }

      mxPrompt1[0]= mxCreateString(pacPromptLoadAnyway);
      mxPrompt1[1]= mxCreateString("s");

      /* only allocate memory if we are going to print the error messages */
      if (verboseFlag == 1)
      {
        pacError  = (char *) mxCalloc(1000, sizeof(char));

        mxErrors[0] = mxCreateString("\n************************************\nLine ErrorId Severity Message\n");
        mexCallMATLAB(0, NULL, 1, mxErrors, "disp");
        mxDestroyArray(mxErrors[0]);
      }
      for (i = 0; i < SBMLDocument_getNumErrors(sbmlDocument); i++)
      {
        e = (const XMLError_t *) SBMLDocument_getError(sbmlDocument, i);

        if (verboseFlag == 1)
        {
          if (listFlag == 1)
          {
            sprintf(pacError, "%u: (%u)  %s %s\n",
	            XMLError_getLine(e), XMLError_getErrorId(e),
              ErrorSeverity_toString(XMLError_getSeverity(e)),
	            XMLError_getMessage(e));
            
            mxErrors[0] = mxCreateString(pacError);
            mexCallMATLAB(0, NULL, 1, mxErrors, "disp");          
            mxDestroyArray(mxErrors[0]);
          }
          else if (XMLError_getSeverity(e) > 1)
          {
            sprintf(pacError, "%u: (%u)  %s %s\n",
	            XMLError_getLine(e), XMLError_getErrorId(e),
              ErrorSeverity_toString(XMLError_getSeverity(e)),
	            XMLError_getMessage(e));
            
            mxErrors[0] = mxCreateString(pacError);
            mexCallMATLAB(0, NULL, 1, mxErrors, "disp");
            mxDestroyArray(mxErrors[0]);    
          }
        }
        if (outputErrors == 1)
        {
          mxSetField(plhs[1], i, "line", CreateIntScalar(XMLError_getLine(e)));
          mxSetField(plhs[1], i, "errorId", CreateIntScalar(XMLError_getErrorId(e)));
          mxSetField(plhs[1], i, "severity", mxCreateString(ErrorSeverity_toString(XMLError_getSeverity(e))));
          mxSetField(plhs[1], i, "message", mxCreateString(XMLError_getMessage(e)));
        }

      }
      
      if (errors == 0 && listFlag == 0)
      {
        pacReply = (char *)mxCalloc(3,sizeof(char));
        pacReply[0] = 'y';
        pacReply[1] = '\0';
      }
      else if (validateFlag == 0)
      {
        mxErrors[0] = mxCreateString("Error encountered during read.");
        mexCallMATLAB(0, NULL, 1, mxErrors, "disp");
        mxDestroyArray(mxErrors[0]);
        pacReply = (char *)mxCalloc(3,sizeof(char));
        pacReply[0] = 'y';
        pacReply[1] = '\0';
      }
      else
      {
        if (verboseFlag == 1)
        {
          mexCallMATLAB(1, mxReply, 2, mxPrompt1, "input");

          nBufferLen = (mxGetM(mxReply[0])*mxGetN(mxReply[0])+1);
          pacReply = (char *) mxCalloc(nBufferLen, sizeof(char));
          mxGetString(mxReply[0], pacReply, (mwSize)(nBufferLen));
          mxDestroyArray(mxReply[0]);
        }
        else
        {
          pacReply = (char *)mxCalloc(3,sizeof(char));
          pacReply[0] = 'y';
          pacReply[1] = '\0';

        }
      }

      mxDestroyArray(mxPrompt1[0]);
    }
    else
    {
      pacReply = (char *)mxCalloc(3,sizeof(char));
      pacReply[0] = 'y';
      pacReply[1] = '\0';

    }
  }
  /* if pacReply is 'y' we read the Model */
  if (strcmp_insensitive(pacReply, "y") == 0) 
  {
    sbmlModel = SBMLDocument_getModel(sbmlDocument);

    unSBMLLevel   = SBMLDocument_getLevel(sbmlDocument);
    unSBMLVersion = SBMLDocument_getVersion(sbmlDocument);
    
    pacTypecode    = TypecodeToChar(SBase_getTypeCode((SBase_t*) sbmlModel));
    pacNotes       = SBase_getNotesString((SBase_t*) sbmlModel);
    pacAnnotations = SBase_getAnnotationString((SBase_t*) sbmlModel);
      
    if (pacTypecode == NULL)
    {
      pacTypecode = "";
    }
    if (pacNotes == NULL)
    {
      pacNotes = "";
    }
    if (pacAnnotations == NULL)
    {
      pacAnnotations = "";
    }


    if (unSBMLLevel > 2)
    {
      packages = SBase_getNumPlugins((SBase_t *)(sbmlDocument));
      if (packages > 0)
      {
        if (SBase_getPlugin((SBase_t *)(sbmlDocument), "fbc") != NULL)
        {
          fbcPresent = 1;
          unFBCVersion = SBasePlugin_getPackageVersion(
                         SBase_getPlugin((SBase_t *)(sbmlDocument), "fbc"));
        }
      }
    }

    GetNamespaces    (sbmlDocument);

    GetCompartment   (sbmlModel, unSBMLLevel, unSBMLVersion);
    GetParameter     (sbmlModel, unSBMLLevel, unSBMLVersion);
    GetSpecies       (sbmlModel, unSBMLLevel, unSBMLVersion);
    GetUnitDefinition(sbmlModel, unSBMLLevel, unSBMLVersion);
    GetRule          (sbmlModel, unSBMLLevel, unSBMLVersion);
    GetReaction      (sbmlModel, unSBMLLevel, unSBMLVersion);

    switch (unSBMLLevel)
    {
    case 1:
      pacName   = Model_getId(sbmlModel);
      if (pacName == NULL)
      {
        pacName = "";
      }
      break;
    case 2:
      pacName   = Model_getName(sbmlModel);
      pacMetaid = SBase_getMetaId((SBase_t*)sbmlModel);
      pacId     = Model_getId(sbmlModel);
      GetFunctionDefinition(sbmlModel, unSBMLLevel, unSBMLVersion);
      GetEvent(sbmlModel, unSBMLLevel, unSBMLVersion);

      if (pacName == NULL)
      {
        pacName = "";
      }
      if (pacMetaid == NULL)
      {
        pacMetaid = "";
      }
      if (pacId == NULL){
        pacId = "";
      }
      if (pacCSymbolTime == NULL) {
        pacCSymbolTime = "";
      }
      if (pacCSymbolDelay == NULL) {
        pacCSymbolDelay = "";
      }
      switch (unSBMLVersion)
      {
      case 1:
        break;
      case 2:
      case 3:
      case 4:
        if (SBase_isSetSBOTerm((SBase_t*)sbmlModel)) {
          nSBO = SBase_getSBOTerm((SBase_t*)sbmlModel);
        }
        else
        {
          nSBO = -1;
        }
        GetCompartmentType  (sbmlModel, unSBMLLevel, unSBMLVersion);
        GetSpeciesType      (sbmlModel, unSBMLLevel, unSBMLVersion);
        GetInitialAssignment(sbmlModel, unSBMLLevel, unSBMLVersion);
        GetConstraint       (sbmlModel, unSBMLLevel, unSBMLVersion);
        break;
      }
      break;
    case 3:
      if (SBase_isSetSBOTerm((SBase_t*)sbmlModel)) {
        nSBO = SBase_getSBOTerm((SBase_t*)sbmlModel);
      }
      else
      {
        nSBO = -1;
      }
      pacName             = Model_getName(sbmlModel);
      pacMetaid           = SBase_getMetaId((SBase_t*)sbmlModel);
      pacId               = Model_getId(sbmlModel);
      pacTimeUnits        = Model_getTimeUnits(sbmlModel);
      pacSubstanceUnits   = Model_getSubstanceUnits(sbmlModel);
      pacVolumeUnits      = Model_getVolumeUnits(sbmlModel);
      pacAreaUnits        = Model_getAreaUnits(sbmlModel);
      pacLengthUnits      = Model_getLengthUnits(sbmlModel);
      pacExtentUnits      = Model_getExtentUnits(sbmlModel);
      pacConversionFactor = Model_getConversionFactor(sbmlModel);
      GetFunctionDefinition(sbmlModel, unSBMLLevel, unSBMLVersion);
      GetEvent(sbmlModel, unSBMLLevel, unSBMLVersion);
      GetInitialAssignment(sbmlModel, unSBMLLevel, unSBMLVersion);
      GetConstraint       (sbmlModel, unSBMLLevel, unSBMLVersion);
      if (fbcPresent == 1)
      {
#ifdef USE_FBC
        GetFluxBound (sbmlModel, unSBMLLevel, unSBMLVersion);
        GetObjective (sbmlModel, unSBMLLevel, unSBMLVersion);
#endif
      }
      if (pacName == NULL)
      {
        pacName = "";
      }
      if (pacMetaid == NULL)
      {
        pacMetaid = "";
      }
      if (pacId == NULL){
        pacId = "";
      }
      if (pacCSymbolTime == NULL) {
        pacCSymbolTime = "";
      }
      if (pacCSymbolDelay == NULL) {
        pacCSymbolDelay = "";
      }
      if (pacCSymbolAvo == NULL) {
        pacCSymbolAvo = "";
      }
      if (pacActiveObj == NULL) {
        pacActiveObj = "";
      }
      if ( pacTimeUnits == NULL )
        pacTimeUnits = "";
      if ( pacSubstanceUnits == NULL )
        pacSubstanceUnits = "";
      if ( pacVolumeUnits == NULL )
        pacVolumeUnits = "";
      if ( pacAreaUnits == NULL )
        pacAreaUnits = "";
      if ( pacLengthUnits == NULL )
        pacLengthUnits = "";
      if ( pacExtentUnits == NULL )
        pacExtentUnits = "";
      if ( pacConversionFactor == NULL )
        pacConversionFactor = "";
      break;
    }

    if (unSBMLLevel == 1)
    {
      plhs[0] = mxCreateStructArray(2, dims, nNoFields_l1v1, field_names_l1v1);
    }
    else if (unSBMLLevel == 2 && unSBMLVersion == 1)
    {
      plhs[0] = mxCreateStructArray(2, dims, nNoFields_l2v1, field_names_l2v1);
    }
    else if (unSBMLLevel == 2 && unSBMLVersion == 2)
    {
      plhs[0] = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLLevel == 2 && unSBMLVersion == 3)
    {
      plhs[0] = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
    else if (unSBMLLevel == 2 && unSBMLVersion == 4)
    {
      plhs[0] = mxCreateStructArray(2, dims, nNoFields_l2v4, field_names_l2v4);
    }
    else if (unSBMLLevel == 3 && unSBMLVersion == 1)
    {
      if (fbcPresent == 0)
      {
        plhs[0] = mxCreateStructArray(2, dims, nNoFields_l3v1, field_names_l3v1);
      }
      else
      {
        plhs[0] = mxCreateStructArray(2, dims, nNoFields_l3v1_fbc, field_names_l3v1_fbc);
      }
    }


    mxSetField( plhs[0], 0, "typecode", mxCreateString(pacTypecode) ); 
    if (unSBMLLevel  > 1)
    {
      mxSetField(plhs[0], 0, "metaid", mxCreateString(pacMetaid));
    }
    mxSetField( plhs[0], 0, "name"    , mxCreateString(pacName)     );

    if (unSBMLLevel > 1)
    {
      mxSetField(plhs[0], 0, "id", mxCreateString(pacId));
    }

    mxSetField( plhs[0], 0, "SBML_level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( plhs[0], 0, "SBML_version"    , CreateIntScalar(unSBMLVersion) );
    if (unSBMLLevel > 2 && fbcPresent == 1)
    {
      mxSetField( plhs[0], 0, "fbc_version"    , CreateIntScalar(unFBCVersion) );
    }

    mxSetField( plhs[0], 0, "notes"      , mxCreateString(pacNotes)       );
    mxSetField( plhs[0], 0, "annotation", mxCreateString(pacAnnotations) );

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if (unSBMLLevel == 2)
    {
      if (unSBMLVersion > 1) 
      {
        mxSetField(plhs[0], 0, "sboTerm", CreateIntScalar(nSBO));
      }
      mxSetField(plhs[0], 0,"functionDefinition", mxFunctionDefReturn);
    }
    else if (unSBMLLevel > 2)
    {

      mxSetField( plhs[0], 0, "timeUnits"      , mxCreateString(pacTimeUnits)       );
      mxSetField( plhs[0], 0, "substanceUnits"      , mxCreateString(pacSubstanceUnits)       );
      mxSetField( plhs[0], 0, "volumeUnits"      , mxCreateString(pacVolumeUnits)       );
      mxSetField( plhs[0], 0, "areaUnits"      , mxCreateString(pacAreaUnits)       );
      mxSetField( plhs[0], 0, "lengthUnits"      , mxCreateString(pacLengthUnits)       );
      mxSetField( plhs[0], 0, "extentUnits"      , mxCreateString(pacExtentUnits)       );
      mxSetField( plhs[0], 0, "conversionFactor"      , mxCreateString(pacConversionFactor)       );
      mxSetField(plhs[0], 0, "sboTerm", CreateIntScalar(nSBO));
      mxSetField(plhs[0], 0,"functionDefinition", mxFunctionDefReturn);
    }

    mxSetField( plhs[0], 0, "unitDefinition", mxUnitDefReturn   );

    if (unSBMLLevel == 2 && unSBMLVersion > 1)
    {
      mxSetField(plhs[0], 0,"compartmentType", mxCompartmentTypeReturn);
      mxSetField(plhs[0], 0,"speciesType"    , mxSpeciesTypeReturn);
    }

    mxSetField( plhs[0], 0, "compartment"   , mxCompartReturn   );
    mxSetField( plhs[0], 0, "species"       , mxSpeciesReturn   );
    mxSetField( plhs[0], 0, "parameter"     , mxParameterReturn );

    if ((unSBMLLevel == 2 && unSBMLVersion > 1) || unSBMLLevel > 2)
    {
      mxSetField(plhs[0], 0,"initialAssignment", mxInitialAssignReturn);
    }

    mxSetField( plhs[0], 0, "rule"          , mxListRuleReturn  );

    if ((unSBMLLevel == 2 && unSBMLVersion > 1) || unSBMLLevel > 2)
    {
      mxSetField(plhs[0], 0,"constraint", mxConstraintReturn);
    }

    mxSetField( plhs[0], 0, "reaction"      , mxReactionReturn  );

    if (unSBMLLevel > 1)
    {
      mxSetField(plhs[0], 0, "event", mxEventReturn);
    }
    if (unSBMLLevel > 2 && fbcPresent == 1)
    {
      mxSetField(plhs[0], 0, "fbc_fluxBound", mxFluxBoundReturn);
      mxSetField(plhs[0], 0, "fbc_objective", mxObjectiveReturn);
      mxSetField(plhs[0], 0, "fbc_activeObjective", mxCreateString(pacActiveObj));
    }
    if (unSBMLLevel > 1)
    {
      mxSetField(plhs[0], 0, "time_symbol", mxCreateString(pacCSymbolTime));
      mxSetField(plhs[0], 0, "delay_symbol", mxCreateString(pacCSymbolDelay));
    }
    if (unSBMLLevel > 2)
    {
      mxSetField(plhs[0], 0, "avogadro_symbol", mxCreateString(pacCSymbolAvo));
    }
    
    mxSetField( plhs[0], 0, "namespaces"      , mxNSReturn  );

    if (packages > 0)
    {
      if (packages > 1 || fbcPresent == 0)
      {
        mxNone[0] = mxCreateString(pacL3packages);
        mexCallMATLAB(0, NULL, 1, mxNone, "disp");  
      }
    }
    
  }
  else
  {
    /* we havent read in a Model */
    mxNone[0] = mxCreateString(pacNone);
    mexCallMATLAB(0, NULL, 1, mxNone, "disp");
    mxDestroyArray(mxNone[0]);

    plhs[0] = mxCreateStructArray(0, 0, 0, NULL);
  }



}

const char *
ErrorSeverity_toString(unsigned int severity)
{
  const char * pacSeverity;
  switch(severity)
  {
  case 0:
    pacSeverity = "Info    ";
    break;
  case 1:
    pacSeverity = "Warning ";
    break;
  case 2:
    pacSeverity = "Error   ";
    break;
  case 3:
  default:
    pacSeverity = "Fatal   ";
    break;
  }
  return pacSeverity;
}


void
GetNamespaces(SBMLDocument_t * document)
{
  const XMLNamespaces_t * NS = SBMLDocument_getNamespaces(document);
  int n = XMLNamespaces_getLength(NS);
  mwSize dims[2] = {1, n};

  /* fields within a namespace structure */
  const int nNoFields = 2;
  const char *field_names[] = {	
    "prefix", 
    "uri"
  };
      

  const char * pacPrefix = NULL;
  const char * pacURI = NULL;
  
  int i;
  
  mxNSReturn = mxCreateStructArray(2, dims, nNoFields, field_names);
  
  for (i = 0; i < n; i++)
  {
    pacPrefix = XMLNamespaces_getPrefix(NS, i);
    pacURI    = XMLNamespaces_getURI(NS, i);
   
    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacPrefix == NULL) {
      pacPrefix = "";
    }
    if (pacURI == NULL) {
      pacURI = "";
    }

    mxSetField(mxNSReturn, i, "prefix", mxCreateString(pacPrefix)); 
    mxSetField(mxNSReturn, i, "uri",    mxCreateString(pacURI)); 
  }
  
  
  
}
/**
 * NAME:    TypecodeToChar
 *
 * PARAMETERS:  SBMLTypeCode_t typecode 
 *
 * RETURNS:    char *
 *
 * FUNCTION:  converts typecode to humanly readable string
 */
const char *
TypecodeToChar (int typecode)
{
  const char * pacTypecode;

  switch (typecode)
  {
    case SBML_COMPARTMENT:
      pacTypecode = "SBML_COMPARTMENT";
      break;

    case SBML_EVENT:
      pacTypecode = "SBML_EVENT";
      break;

    case SBML_EVENT_ASSIGNMENT:
      pacTypecode = "SBML_EVENT_ASSIGNMENT";
      break;

    case SBML_FUNCTION_DEFINITION:
      pacTypecode = "SBML_FUNCTION_DEFINITION";
      break;

    case SBML_KINETIC_LAW:
      pacTypecode = "SBML_KINETIC_LAW";
      break;

    case SBML_MODEL:
      pacTypecode = "SBML_MODEL";
      break;

    case SBML_PARAMETER:
      pacTypecode = "SBML_PARAMETER";
      break;

    case SBML_LOCAL_PARAMETER:
      pacTypecode = "SBML_LOCAL_PARAMETER";
      break;

    case SBML_REACTION:
      pacTypecode = "SBML_REACTION";
      break;

    case SBML_SPECIES:
      pacTypecode = "SBML_SPECIES";
      break;

    case SBML_SPECIES_REFERENCE:
      pacTypecode = "SBML_SPECIES_REFERENCE";
      break;

    case SBML_MODIFIER_SPECIES_REFERENCE:
      pacTypecode = "SBML_MODIFIER_SPECIES_REFERENCE";
      break;    

    case SBML_UNIT_DEFINITION:
      pacTypecode = "SBML_UNIT_DEFINITION";
      break;

    case SBML_UNIT:
      pacTypecode = "SBML_UNIT";
      break;

    case SBML_ASSIGNMENT_RULE:
      pacTypecode = "SBML_ASSIGNMENT_RULE";
      break;

    case SBML_ALGEBRAIC_RULE:
      pacTypecode = "SBML_ALGEBRAIC_RULE";
      break;

    case SBML_RATE_RULE:
      pacTypecode = "SBML_RATE_RULE";
      break;

    case SBML_SPECIES_CONCENTRATION_RULE:
      pacTypecode = "SBML_SPECIES_CONCENTRATION_RULE";
      break;

    case SBML_COMPARTMENT_VOLUME_RULE:
      pacTypecode = "SBML_COMPARTMENT_VOLUME_RULE";
      break;

    case SBML_PARAMETER_RULE:
      pacTypecode = "SBML_PARAMETER_RULE";
      break;

    case SBML_CONSTRAINT:
      pacTypecode = "SBML_CONSTRAINT";
      break;

    case SBML_INITIAL_ASSIGNMENT:
      pacTypecode = "SBML_INITIAL_ASSIGNMENT";
      break;

    case SBML_COMPARTMENT_TYPE:
      pacTypecode = "SBML_COMPARTMENT_TYPE";
      break;

    case SBML_SPECIES_TYPE:
      pacTypecode = "SBML_SPECIES_TYPE";
      break;

    case SBML_TRIGGER:
      pacTypecode = "SBML_TRIGGER";
      break;

    case SBML_DELAY:
      pacTypecode = "SBML_DELAY";
      break;

    case SBML_STOICHIOMETRY_MATH:
      pacTypecode = "SBML_STOICHIOMETRY_MATH";
      break;

    case SBML_PRIORITY:
      pacTypecode = "SBML_PRIORITY";
      break;

    case SBML_FBC_FLUXBOUND:
      pacTypecode = "SBML_FBC_FLUXBOUND";
      break;

    case SBML_FBC_FLUXOBJECTIVE:
      pacTypecode = "SBML_FBC_FLUXOBJECTIVE";
      break;

    case SBML_FBC_OBJECTIVE:
      pacTypecode = "SBML_FBC_OBJECTIVE";
      break;

    default:
      pacTypecode = "ERROR";
      break;
  }

  return pacTypecode;
}

/**
 * NAME:    CreateIntScalar
 *
 * PARAMETERS:  int Value 
 *
 * RETURNS:    mxArray *
 *
 * FUNCTION:  emulates the function mxCreateDoubleScalar
 *            creates an UINT32 array with one element
 *            assigns Value to the element
 */
mxArray *
CreateIntScalar (int nValue)
{
  mxArray * pArray;
  int * panData;
  
  pArray = mxCreateNumericMatrix(1,1,mxINT32_CLASS, mxREAL);
  panData = (int *)mxGetData(pArray);
  panData[0] = nValue;

  return pArray;
}


/**
 * NAME:    GetSpecies
 *
 * PARAMETERS:  Pointer to a model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the species mxArray structure
 *            populates the structure with all the species in the model
 *
 */
void
GetSpecies ( Model_t      *pModel,
             unsigned int unSBMLLevel,
             unsigned int unSBMLVersion )
{
  int n = Model_getNumSpecies(pModel);
  mwSize dims[2] = {1, n};

  /* fields within a species structure */
  const int nNoFields_l1 = 13;
  const char *field_names_l1[] = {	
    "typecode", 
		"notes", 
		"annotation",
		"name", 
		"compartment",
		"initialAmount", 
		"units",
		"boundaryCondition", 
		"charge",
		"isSetInitialAmount", 
		"isSetCharge",
    "level",
    "version"};
  
  const int nNoFields_l2 = 20;
  const char *field_names_l2[] = {	
    "typecode",		
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
		"compartment",
		"initialAmount", 
		"initialConcentration", 
		"substanceUnits",
		"spatialSizeUnits", 
		"hasOnlySubstanceUnits", 
		"boundaryCondition", 
		"charge", 
		"constant",
		"isSetInitialAmount", 
		"isSetInitialConcentration", 
		"isSetCharge",
    "level",
    "version"};

   const int nNoFields_l2v2 = 21;
   const char *field_names_l2v2[] = {	
    "typecode",		
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
    "speciesType",
		"compartment",
		"initialAmount", 
		"initialConcentration", 
		"substanceUnits",
		"spatialSizeUnits", 
		"hasOnlySubstanceUnits", 
		"boundaryCondition", 
		"charge", 
		"constant",
		"isSetInitialAmount", 
		"isSetInitialConcentration", 
		"isSetCharge",
    "level",
    "version"};
    
   const int nNoFields_l2v3 = 21;
   const char *field_names_l2v3[] = {	
    "typecode",		
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
    "speciesType",
		"compartment",
		"initialAmount", 
		"initialConcentration", 
		"substanceUnits",
		"hasOnlySubstanceUnits", 
		"boundaryCondition", 
		"charge", 
		"constant",
		"isSetInitialAmount", 
		"isSetInitialConcentration", 
		"isSetCharge",
    "level",
    "version"};
                  
   const int nNoFields_l2v4 = 21;
   const char *field_names_l2v4[] = {	
    "typecode",		
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
    "speciesType",
		"compartment",
		"initialAmount", 
		"initialConcentration", 
		"substanceUnits",
		"hasOnlySubstanceUnits", 
		"boundaryCondition", 
		"charge", 
		"constant",
		"isSetInitialAmount", 
		"isSetInitialConcentration", 
		"isSetCharge",
    "level",
    "version"};

   const int nNoFields_l3v1 = 19;
   const char *field_names_l3v1[] = {	
    "typecode",		
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
		"compartment",
		"initialAmount", 
		"initialConcentration", 
		"substanceUnits",
		"hasOnlySubstanceUnits", 
		"boundaryCondition", 
		"constant",
    "conversionFactor",
		"isSetInitialAmount", 
		"isSetInitialConcentration",
    "level",
    "version"};

   const int nNoFields_l3v1_fbc = 23;
   const char *field_names_l3v1_fbc[] = {	
    "typecode",		
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
		"compartment",
		"initialAmount", 
		"initialConcentration", 
		"substanceUnits",
		"hasOnlySubstanceUnits", 
		"boundaryCondition", 
		"constant",
    "conversionFactor",
		"isSetInitialAmount", 
		"isSetInitialConcentration",
    "fbc_charge",
    "fbc_chemicalFormula",
    "isSetfbc_charge",
    "level",
    "version",
    "fbc_version"};

  /* values */
  const char * pacTypecode;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacName;
  const char * pacId = NULL;
  const char * pacMetaid = NULL;
  const char * pacCompartment;
  const char * pacUnits = NULL;
  const char * pacSpatialSizeUnits = NULL;
  const char * pacSpeciesType = NULL;
  const char * pacConversionFactor = NULL;
  const char * pacChemicalFormula = NULL;

  double dInitialAmount = 0.0;
  double dInitialConcentration = 0.0;

  int nHasOnlySubsUnits = 0;
  int nBoundaryCondition = 0;
  int nCharge = 1;
  int nConstant = 0;
  int nSBO = -1;

  unsigned int unIsSetInit = 1;
  unsigned int unIsSetInitConc = 1;
  unsigned int unIsSetCharge = 1;

  unsigned int unFBCVersion;

  int i;
  Species_t *pSpecies;

  double dZero = 0.0;
      
  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxSpeciesReturn = mxCreateStructArray(2, dims, nNoFields_l1, field_names_l1);
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxSpeciesReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxSpeciesReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion == 3) 
    {
      mxSpeciesReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
    else if (unSBMLVersion == 4) 
    {
      mxSpeciesReturn = mxCreateStructArray(2, dims, nNoFields_l2v4, field_names_l2v4);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1 && fbcPresent == 0)
    {
      mxSpeciesReturn = mxCreateStructArray(2, dims, nNoFields_l3v1, field_names_l3v1);
    }
    else
    {
      mxSpeciesReturn = mxCreateStructArray(2, dims, nNoFields_l3v1_fbc, field_names_l3v1_fbc);
    }
  }


  for (i = 0; i < n; i++) {
    
    pSpecies = Model_getSpecies(pModel, i);
    
    /* determine the values */
    pacTypecode        = TypecodeToChar(SBase_getTypeCode((SBase_t*) pSpecies));
    pacNotes           = SBase_getNotesString((SBase_t*) pSpecies);
    pacAnnotations     = SBase_getAnnotationString((SBase_t*) pSpecies);
    
    if (unSBMLLevel == 1)
    {
      pacName            = Species_getId(pSpecies);
    }
    else
    {
      pacName            = Species_getName(pSpecies);
    }
    pacCompartment     = Species_getCompartment(pSpecies);
    dInitialAmount     = Species_getInitialAmount(pSpecies);
    nBoundaryCondition = Species_getBoundaryCondition(pSpecies);
    unIsSetInit        = Species_isSetInitialAmount(pSpecies);
    if (unSBMLLevel < 3)
    {
      nCharge            = Species_getCharge(pSpecies);
      unIsSetCharge      = Species_isSetCharge(pSpecies);
    }
    if (unSBMLLevel == 1) 
    {
      pacUnits         = Species_getUnits(pSpecies);
    }
    else if (unSBMLLevel == 2) 
    {
      pacId                 = Species_getId(pSpecies);
      pacMetaid = SBase_getMetaId((SBase_t*)pSpecies);
      dInitialConcentration = Species_getInitialConcentration(pSpecies);
      pacUnits              = Species_getSubstanceUnits(pSpecies);
      nHasOnlySubsUnits     = Species_getHasOnlySubstanceUnits(pSpecies);
      nConstant             = Species_getConstant(pSpecies);
      unIsSetInitConc       = Species_isSetInitialConcentration(pSpecies);
    
      switch (unSBMLVersion)
      {
      case 1:
        pacSpatialSizeUnits = Species_getSpatialSizeUnits(pSpecies);
        break;
      case 2:
        pacSpatialSizeUnits = Species_getSpatialSizeUnits(pSpecies);
        pacSpeciesType      = Species_getSpeciesType(pSpecies);
       break;
      case 3:
      case 4:
        pacSpeciesType      = Species_getSpeciesType(pSpecies);
        if (SBase_isSetSBOTerm((SBase_t*) pSpecies)) 
        {
          nSBO = SBase_getSBOTerm((SBase_t*) pSpecies);
        }
        else
        {
          nSBO = -1;
        }
        break;
      default:
        break;
      }
    }
    else if (unSBMLLevel == 3) 
    {
      pacId                 = Species_getId(pSpecies);
      pacMetaid = SBase_getMetaId((SBase_t*)pSpecies);
      dInitialConcentration = Species_getInitialConcentration(pSpecies);
      pacUnits              = Species_getSubstanceUnits(pSpecies);
      nHasOnlySubsUnits     = Species_getHasOnlySubstanceUnits(pSpecies);
      nConstant             = Species_getConstant(pSpecies);
      unIsSetInitConc       = Species_isSetInitialConcentration(pSpecies);
      pacConversionFactor   = Species_getConversionFactor(pSpecies);
    
      if (SBase_isSetSBOTerm((SBase_t*) pSpecies)) 
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pSpecies);
      }
      else
      {
        nSBO = -1;
      }
      if (fbcPresent == 1)
      {
#ifdef USE_FBC
       unFBCVersion = SBasePlugin_getPackageVersion(SBase_getPlugin((SBase_t *)(pSpecies), "fbc"));
        pacChemicalFormula = FbcSpeciesPlugin_getChemicalFormula(SBase_getPlugin((SBase_t *)(pSpecies), "fbc"));
        nCharge            = FbcSpeciesPlugin_getCharge(SBase_getPlugin((SBase_t *)(pSpecies), "fbc"));
        unIsSetCharge      = FbcSpeciesPlugin_isSetCharge(SBase_getPlugin((SBase_t *)(pSpecies), "fbc"));
#else
        unFBCVersion = 0;
#endif
      }
    }

    
    /* record any unset values as NAN */
    if (unIsSetInitConc == 0) 
    {
      dInitialConcentration = 0.0/dZero;
    }
    if (unIsSetInit == 0) 
    {
        dInitialAmount = 0.0/dZero;
    }
    if (unIsSetCharge == 0) 
    {
    /* if charge is not set it is assumed to be zero */
        nCharge = 0;
    }

    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacName == NULL) {
      pacName = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }
    if (pacCompartment == NULL) {
      pacCompartment = "";
    }
    if (pacUnits == NULL) {
      pacUnits = "";
    }
    if (pacSpatialSizeUnits == NULL) {
      pacSpatialSizeUnits = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacSpeciesType == NULL) {
      pacSpeciesType = "";
    }
    if (pacConversionFactor == NULL) {
      pacConversionFactor = "";
    }
    if (pacChemicalFormula == NULL) {
      pacChemicalFormula = "";
    }

    /* put into structure */
    mxSetField( mxSpeciesReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxSpeciesReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );
    if (unSBMLLevel > 2 && fbcPresent == 1)
    {
      mxSetField( mxSpeciesReturn, i, "fbc_version"    , CreateIntScalar(unFBCVersion) );
    }

    mxSetField(mxSpeciesReturn,i,"typecode",mxCreateString(pacTypecode));
    if (unSBMLLevel > 1)
    {
      mxSetField(mxSpeciesReturn, i, "metaid", mxCreateString(pacMetaid));
    }
    mxSetField(mxSpeciesReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxSpeciesReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2) 
    {
      mxSetField(mxSpeciesReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxSpeciesReturn,i,"name",mxCreateString(pacName)); 
    if (unSBMLLevel == 2) 
    {
      mxSetField(mxSpeciesReturn,i,"id",mxCreateString(pacId)); 
      if (unSBMLVersion != 1) 
      {
        mxSetField(mxSpeciesReturn,i,"speciesType",mxCreateString(pacSpeciesType));
      }
    }
    else if (unSBMLLevel == 3) 
    {
      mxSetField(mxSpeciesReturn,i,"id",mxCreateString(pacId)); 
    }
    mxSetField(mxSpeciesReturn,i,"compartment",mxCreateString(pacCompartment)); 
    mxSetField(mxSpeciesReturn,i,"initialAmount",mxCreateDoubleScalar(dInitialAmount)); 
    if (unSBMLLevel == 1) 
    {
      mxSetField(mxSpeciesReturn,i,"units",mxCreateString(pacUnits)); 
      mxSetField(mxSpeciesReturn,i,"boundaryCondition",CreateIntScalar(nBoundaryCondition)); 
      mxSetField(mxSpeciesReturn,i,"charge",CreateIntScalar(nCharge)); 
      mxSetField(mxSpeciesReturn,i,"isSetInitialAmount",CreateIntScalar(unIsSetInit)); 
      mxSetField(mxSpeciesReturn,i,"isSetCharge",CreateIntScalar(unIsSetCharge)); 
    }
    else if (unSBMLLevel == 2) 
    {
      mxSetField(mxSpeciesReturn,i,"initialConcentration",mxCreateDoubleScalar(dInitialConcentration)); 
      mxSetField(mxSpeciesReturn,i,"substanceUnits",mxCreateString(pacUnits)); 
      if (unSBMLVersion < 3)
      {
        mxSetField(mxSpeciesReturn,i,"spatialSizeUnits",mxCreateString(pacSpatialSizeUnits)); 
      }
      mxSetField(mxSpeciesReturn,i,"hasOnlySubstanceUnits",CreateIntScalar(nHasOnlySubsUnits)); 
      mxSetField(mxSpeciesReturn,i,"boundaryCondition",CreateIntScalar(nBoundaryCondition)); 
      mxSetField(mxSpeciesReturn,i,"charge",CreateIntScalar(nCharge)); 
      mxSetField(mxSpeciesReturn,i,"constant",CreateIntScalar(nConstant)); 
      mxSetField(mxSpeciesReturn,i,"isSetInitialAmount",CreateIntScalar(unIsSetInit)); 
      mxSetField(mxSpeciesReturn,i,"isSetInitialConcentration",CreateIntScalar(unIsSetInitConc)); 
      mxSetField(mxSpeciesReturn,i,"isSetCharge",CreateIntScalar(unIsSetCharge)); 
    }
    else if (unSBMLLevel == 3) 
    {
      mxSetField(mxSpeciesReturn,i,"initialConcentration",mxCreateDoubleScalar(dInitialConcentration)); 
      mxSetField(mxSpeciesReturn,i,"substanceUnits",mxCreateString(pacUnits)); 
      mxSetField(mxSpeciesReturn,i,"hasOnlySubstanceUnits",CreateIntScalar(nHasOnlySubsUnits)); 
      mxSetField(mxSpeciesReturn,i,"boundaryCondition",CreateIntScalar(nBoundaryCondition)); 
      mxSetField(mxSpeciesReturn,i,"constant",CreateIntScalar(nConstant)); 
      mxSetField(mxSpeciesReturn,i,"conversionFactor",mxCreateString(pacConversionFactor)); 
      mxSetField(mxSpeciesReturn,i,"isSetInitialAmount",CreateIntScalar(unIsSetInit)); 
      mxSetField(mxSpeciesReturn,i,"isSetInitialConcentration",CreateIntScalar(unIsSetInitConc)); 
      if (fbcPresent == 1)
      {
        mxSetField(mxSpeciesReturn,i,"fbc_charge",CreateIntScalar(nCharge)); 
        mxSetField(mxSpeciesReturn,i,"fbc_chemicalFormula",mxCreateString(pacChemicalFormula)); 
        mxSetField(mxSpeciesReturn,i,"isSetfbc_charge",CreateIntScalar(unIsSetCharge)); 
     }
    }
  }

}


/**
 * NAME:    GetUnitDefinition
 *
 * PARAMETERS:  Pointer to a model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the unit definition mxArray structure
 *            populates the structure with all the unit definition in the model
 *
 */
void
GetUnitDefinition ( Model_t      *pModel,
                    unsigned int unSBMLLevel,
                    unsigned int unSBMLVersion )
{
  int n = Model_getNumUnitDefinitions(pModel);
  mwSize dims[2] = {1, n};

  /* fields within a unit definition structure */
  const int nNoFields_l1 = 7;
  const char * field_names_l1[] = {	
    "typecode", 
		"notes", 
		"annotation",
		"name", 
		"unit",
    "level",
    "version"};
  
  const int nNoFields_l2 = 9;
  const char * field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
		"unit",
    "level",
    "version"};
  
  const int nNoFields_l2v3 = 10;
  const char * field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
		"unit",
    "level",
    "version"};

  /* determine the values */
  const char * pacTypecode;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacName;
  const char * pacId = NULL;
  const char * pacMetaid = NULL;

  int nSBO = -1;

  UnitDefinition_t *pUnitDefinition;
  int i;
   
  /**
   * create the structure array 
   */
  if (unSBMLLevel == 1) 
  {
    mxUnitDefReturn = mxCreateStructArray(2, dims, nNoFields_l1, field_names_l1);
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion > 2)
    {
      mxUnitDefReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
    else
    {
      mxUnitDefReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxUnitDefReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }


  for (i = 0; i < n; i++) {
    pUnitDefinition = Model_getUnitDefinition(pModel, i);

    /* determine the values */

    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t*) pUnitDefinition));
    pacNotes        = SBase_getNotesString((SBase_t*) pUnitDefinition);
    pacAnnotations  = SBase_getAnnotationString((SBase_t*) pUnitDefinition);
    
    if (unSBMLLevel == 1)
    {
      pacName            = UnitDefinition_getId(pUnitDefinition);
    }
    else
    {
      pacName            = UnitDefinition_getName(pUnitDefinition);
    }
    GetUnit(pUnitDefinition, unSBMLLevel, unSBMLVersion);
    
    if (unSBMLLevel == 2) 
    {
      pacId = UnitDefinition_getId(pUnitDefinition);
      pacMetaid = SBase_getMetaId((SBase_t*)pUnitDefinition);
      
      if (unSBMLVersion > 2) 
      {
        if (SBase_isSetSBOTerm((SBase_t*) pUnitDefinition)) 
        {
          nSBO = SBase_getSBOTerm((SBase_t*) pUnitDefinition);
        }
        else
        {
          nSBO = -1;
        }
      }
    }

    else if (unSBMLLevel == 3) 
    {
      pacId = UnitDefinition_getId(pUnitDefinition);
      pacMetaid = SBase_getMetaId((SBase_t*)pUnitDefinition);
      
      if (SBase_isSetSBOTerm((SBase_t*) pUnitDefinition)) 
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pUnitDefinition);
      }
      else
      {
        nSBO = -1;
      }
    }

    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacName == NULL) {
      pacName = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }    
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }

    /* put into structure */
    mxSetField( mxUnitDefReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxUnitDefReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxUnitDefReturn,i,"typecode",mxCreateString(pacTypecode)); 
    if (unSBMLLevel > 1)
    {
      mxSetField(mxUnitDefReturn, i, "metaid", mxCreateString(pacMetaid));
    }
    mxSetField(mxUnitDefReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxUnitDefReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2)
    {
      mxSetField(mxUnitDefReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxUnitDefReturn,i,"name",mxCreateString(pacName)); 
    if (unSBMLLevel > 1) 
    {
      mxSetField(mxUnitDefReturn,i,"id",mxCreateString(pacId)); 
    }
    mxSetField(mxUnitDefReturn,i,"unit",mxUnitReturn); 
    
    mxUnitReturn = NULL;

  }
}


/**
 * NAME:    GetCompartment
 *
 * PARAMETERS:  Pointer to a model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the compartment mxArray structure
 *            populates the structure with all the compartment in the model
 *
 */
void
GetCompartment ( Model_t      *pModel,
                 unsigned int unSBMLLevel,
                 unsigned int unSBMLVersion )
{
  int n = Model_getNumCompartments(pModel);
  mwSize dims[2] = {1, n};

  /* fields within a compartment structure */
  const int nNoFields_l1 = 10;
  const char *field_names_l1[] = {	
    "typecode", 
		"notes", 
		"annotation",
		"name", 
		"volume",
		"units", 
		"outside", 
		"isSetVolume",
    "level",
    "version"};

  const int nNoFields_l2 = 15;
  const char *field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
		"spatialDimensions", 
		"size",
		"units", 
		"outside", 
		"constant", 
		"isSetSize", 
		"isSetVolume",
    "level",
    "version"};

  const int nNoFields_l2v2 = 16;
  const char *field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
    "compartmentType",
		"spatialDimensions", 
		"size",
		"units", 
		"outside", 
		"constant", 
		"isSetSize", 
		"isSetVolume",
    "level",
    "version"};

  const int nNoFields_l2v3 = 17;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
    "compartmentType",
		"spatialDimensions", 
		"size",
		"units", 
		"outside", 
		"constant", 
		"isSetSize", 
		"isSetVolume",
    "level",
    "version"};

  const int nNoFields_l3v1 = 15;
  const char *field_names_l3v1[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
		"spatialDimensions", 
		"size",
		"units", 
		"constant", 
		"isSetSize", 
    "isSetSpatialDimensions",
    "level",
    "version"};

  /* field values */
  const char * pacTypecode;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacName;
  const char * pacId = NULL;
  const char * pacMetaid = NULL;
  const char * pacUnits;
  const char * pacOutside = NULL;
  const char * pacCompartmentType = NULL;

  double dVolume = 1.0;
  double dSize = 1.0;
  double dSpatialDimensions = 0.0;

  unsigned int unSpatialDimensions = 3;
  unsigned int unIsSetVolume = 1;
  unsigned int unIsSetSize = 1;
  unsigned int unIsSetSpatialDimensions = 1;


  int nConstant = 1;
  int nSBO = -1;

  Compartment_t *pCompartment;
  int i;

  double dZero = 0.0;

  /* create the structure array  */
  if (unSBMLLevel == 1) 
  {
      mxCompartReturn = mxCreateStructArray(2, dims, nNoFields_l1, field_names_l1);
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxCompartReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxCompartReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxCompartReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxCompartReturn = mxCreateStructArray(2, dims, nNoFields_l3v1, field_names_l3v1);
    }
  }

  for (i = 0; i < n; i++) {
    pCompartment = Model_getCompartment(pModel, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t*) pCompartment));
  
    pacNotes        = SBase_getNotesString((SBase_t*) pCompartment);
    pacAnnotations  = SBase_getAnnotationString((SBase_t*) pCompartment);
    
    if (unSBMLLevel == 1)
    {
      pacName            = Compartment_getId(pCompartment);
    }
    else
    {
      pacName            = Compartment_getName(pCompartment);
    }
    pacUnits        = Compartment_getUnits(pCompartment);
    if (unSBMLLevel < 3)
    {
      pacOutside      = Compartment_getOutside(pCompartment);
    }
    unIsSetVolume   = Compartment_isSetVolume(pCompartment);
    
    if (unSBMLLevel == 1) 
    {
      dVolume = Compartment_getVolume(pCompartment);
    }
    else if (unSBMLLevel == 2) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pCompartment);
      pacId               = Compartment_getId(pCompartment);
      unSpatialDimensions = Compartment_getSpatialDimensions(pCompartment);
      dSize               = Compartment_getSize(pCompartment);
      nConstant           = Compartment_getConstant(pCompartment);
      unIsSetSize         = Compartment_isSetSize(pCompartment);
  
      switch (unSBMLVersion)
      {
      case 1:
        break;
      case 2:
        pacCompartmentType = Compartment_getCompartmentType(pCompartment);
        break;
      case 3:
      case 4:
        pacCompartmentType = Compartment_getCompartmentType(pCompartment);
       if (SBase_isSetSBOTerm((SBase_t*) pCompartment)) 
        {
          nSBO = SBase_getSBOTerm((SBase_t*) pCompartment);
        }
       else
       {
         nSBO = -1;
       }
        break;
      default:
        break;
      }
    }
    else if (unSBMLLevel == 3) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pCompartment);
      pacId               = Compartment_getId(pCompartment);
      if (Compartment_isSetSpatialDimensions(pCompartment))
      {
        dSpatialDimensions = Compartment_getSpatialDimensionsAsDouble(pCompartment);
        unIsSetSpatialDimensions = 1;
      }
      else
      {
        dSpatialDimensions = 0.0/dZero;
        unIsSetSpatialDimensions = 0;
      }
      dSize               = Compartment_getSize(pCompartment);
      nConstant           = Compartment_getConstant(pCompartment);
      unIsSetSize         = Compartment_isSetSize(pCompartment);
  
      if (SBase_isSetSBOTerm((SBase_t*) pCompartment)) 
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pCompartment);
      }
      else
      {
        nSBO = -1;
      }
    }

    /* record any unset values as NAN */
    if (unIsSetVolume == 0) 
    {
        dVolume = 0.0/dZero;
    }
    if (unIsSetSize == 0) 
    {
        dSize = 0.0/dZero;
    }
    if (unIsSetSpatialDimensions == 0) 
    {
        dSpatialDimensions = 0.0/dZero;
    }
    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacName == NULL) {
      pacName = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }
    if (pacUnits == NULL) {
      pacUnits = "";
    }
    if (pacOutside == NULL) {
      pacOutside = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }    
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacCompartmentType == NULL) {
      pacCompartmentType = "";
    }

    /* put into structure */
    mxSetField( mxCompartReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxCompartReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxCompartReturn,i,"typecode",mxCreateString(pacTypecode)); 
    if (unSBMLLevel > 1)
    {
      mxSetField(mxCompartReturn, i, "metaid", mxCreateString(pacMetaid));
    }
    mxSetField(mxCompartReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxCompartReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2)
    {
      mxSetField(mxCompartReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxCompartReturn,i,"name",mxCreateString(pacName)); 
    if (unSBMLLevel == 1) {
      mxSetField(mxCompartReturn,i,"volume",mxCreateDoubleScalar(dVolume)); 
    }
    else if (unSBMLLevel == 2) {
      mxSetField(mxCompartReturn,i,"id",mxCreateString(pacId)); 

      if (unSBMLVersion != 1){
        mxSetField(mxCompartReturn,i,"compartmentType",mxCreateString(pacCompartmentType)); 
      }

      mxSetField(mxCompartReturn,i,"spatialDimensions",CreateIntScalar(unSpatialDimensions)); 
      mxSetField(mxCompartReturn,i,"size",mxCreateDoubleScalar(dSize)); 
    }
    else if (unSBMLLevel == 3) {
      mxSetField(mxCompartReturn,i,"id",mxCreateString(pacId)); 
      mxSetField(mxCompartReturn,i,"spatialDimensions",mxCreateDoubleScalar(dSpatialDimensions)); 
      mxSetField(mxCompartReturn,i,"size",mxCreateDoubleScalar(dSize)); 
    }
    
    mxSetField(mxCompartReturn,i,"units",mxCreateString(pacUnits)); 
    if (unSBMLLevel < 3)
    {
      mxSetField(mxCompartReturn,i,"outside",mxCreateString(pacOutside)); 
    }
    if (unSBMLLevel > 1) {
      mxSetField(mxCompartReturn,i,"constant",CreateIntScalar(nConstant)); 
      mxSetField(mxCompartReturn,i,"isSetSize",CreateIntScalar(unIsSetSize)); 
    }
    if (unSBMLLevel < 3)
    {
      mxSetField(mxCompartReturn,i,"isSetVolume",CreateIntScalar(unIsSetVolume)); 
    }
    else
    {
      mxSetField(mxCompartReturn,i,"isSetSpatialDimensions",CreateIntScalar(unIsSetSpatialDimensions)); 
    }
  }
}


/**
 * NAME:    GetParameter
 *
 * PARAMETERS:  Pointer to a model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the parameter mxArray structure
 *        populates the structure with all the parameters in the model
 *
 */
void
GetParameter ( Model_t      *pModel,
               unsigned int unSBMLLevel,
               unsigned int unSBMLVersion )
{
  int n = Model_getNumParameters(pModel);
  mwSize dims[2] = {1, n};

  /* fields within a species structure */
  const int nNoFields_l1 = 9;
  const char *field_names_l1[] = {	
    "typecode", 
		"notes", 
		"annotation",
		"name", 
		"value",
		"units",
		"isSetValue",
    "level",
    "version"};
  const int nNoFields_l2 = 12;
  const char *field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
		"value",
		"units", 
		"constant", 
		"isSetValue",
    "level",
    "version"};
   const int nNoFields_l2v2 = 13;
  const char *field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
		"value",
		"units", 
		"constant",
    "sboTerm",
		"isSetValue",
    "level",
    "version"};
   const int nNoFields_l2v3 = 13;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
		"value",
		"units", 
		"constant",
		"isSetValue",
    "level",
    "version"};
 
  const char * pacTypecode;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacName;
  const char * pacId = NULL;
  const char * pacMetaid = NULL;
  const char * pacUnits;
  int nSBO = -1;

  double dValue;

  unsigned int unIsSetValue = 1;
  int nConstant = 1;

  Parameter_t *pParameter;

  int i;
  double dZero =0.0;    
  
  /* create the structure array  */
  if (unSBMLLevel == 1) 
  {
      mxParameterReturn = mxCreateStructArray(2, dims, nNoFields_l1, field_names_l1);
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxParameterReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxParameterReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxParameterReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxParameterReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }


  for (i = 0; i < n; i++) {
    pParameter = Model_getParameter(pModel, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t*) pParameter));
  
    pacNotes        = SBase_getNotesString((SBase_t*) pParameter);
    pacAnnotations  = SBase_getAnnotationString((SBase_t*) pParameter);
    
    if (unSBMLLevel == 1)
    {
      pacName            = Parameter_getId(pParameter);
    }
    else
    {
      pacName            = Parameter_getName(pParameter);
    }
    dValue          = Parameter_getValue(pParameter);
    pacUnits        = Parameter_getUnits(pParameter);
    unIsSetValue    = Parameter_isSetValue(pParameter);
   
    if (unSBMLLevel == 2) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pParameter);
      pacId     = Parameter_getId(pParameter);
      nConstant = Parameter_getConstant(pParameter);

      switch (unSBMLVersion)
      {
      case 1:
        break;
      case 2:
        if (SBase_isSetSBOTerm((SBase_t*) pParameter)) 
        {
          nSBO = SBase_getSBOTerm((SBase_t*) pParameter);
        }
        else
        {
          nSBO = -1;
        }
        break;
      case 3:
      case 4:
        if (SBase_isSetSBOTerm((SBase_t*) pParameter)) 
        {
          nSBO = SBase_getSBOTerm((SBase_t*) pParameter);
        }
        else
        {
          nSBO = -1;
        }
        break;
      default:
        break;
      }
    }
    else if (unSBMLLevel == 3) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pParameter);
      pacId     = Parameter_getId(pParameter);
      nConstant = Parameter_getConstant(pParameter);
      if (SBase_isSetSBOTerm((SBase_t*) pParameter)) 
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pParameter);
      }
      else
      {
        nSBO = -1;
      }
    }

    /* record any unset values as NAN */
    if (unIsSetValue == 0) {
        dValue = 0.0/dZero;
    }
    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacName == NULL) {
      pacName = "";
    }
    if (pacUnits == NULL) {
      pacUnits = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }    
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }

    /* put into structure */
    mxSetField( mxParameterReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxParameterReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxParameterReturn,i,"typecode",mxCreateString(pacTypecode)); 
    if (unSBMLLevel > 1)
    {
      mxSetField(mxParameterReturn, i, "metaid", mxCreateString(pacMetaid));
    }
    mxSetField(mxParameterReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxParameterReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2) 
    {
      mxSetField(mxParameterReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxParameterReturn,i,"name",mxCreateString(pacName)); 
    if (unSBMLLevel > 1) {
      mxSetField(mxParameterReturn,i,"id",mxCreateString(pacId)); 
    }
    mxSetField(mxParameterReturn,i,"value",mxCreateDoubleScalar(dValue)); 
    mxSetField(mxParameterReturn,i,"units",mxCreateString(pacUnits)); 
    if (unSBMLLevel > 1) 
    {
      mxSetField(mxParameterReturn,i,"constant",CreateIntScalar(nConstant)); 
    }
    if (unSBMLLevel == 2 && unSBMLVersion == 2){
        mxSetField(mxParameterReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxParameterReturn,i,"isSetValue",CreateIntScalar(unIsSetValue)); 
  }
}


/**
 * NAME:    GetReaction
 *
 * PARAMETERS:  Pointer to a model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the reaction mxArray structure
 *            populates the structure with all the reactions in the model
 *
 */
void GetReaction ( Model_t      *pModel,
                   unsigned int unSBMLLevel,
                   unsigned int unSBMLVersion )
{
  int n = Model_getNumReactions(pModel);
  mwSize dims[2] = {1, n};

  /* fields within a species structure */
  const int nNoFields_l1 = 11;
  const char *field_names_l1[] = {	
    "typecode", 
		"notes", 
		"annotation",
		"name", 
		"reactant",
		"product", 
		"kineticLaw",
		"reversible", 
		"fast",
    "level",
    "version"};
  const int nNoFields_l2 = 15;
  const char *field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
		"reactant",
		"product", 
		"modifier", 
		"kineticLaw",
		"reversible", 
		"fast", 
		"isSetFast",
    "level",
    "version"};
  const int nNoFields_l2v2 = 16;
  const char *field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
		"reactant",
		"product", 
		"modifier", 
		"kineticLaw",
		"reversible", 
		"fast",
    "sboTerm",
		"isSetFast",
    "level",
    "version"};
  const int nNoFields_l2v3 = 16;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
		"reactant",
		"product", 
		"modifier", 
		"kineticLaw",
		"reversible", 
		"fast",
		"isSetFast",
    "level",
    "version"};
  const int nNoFields_l3v1 = 17;
  const char *field_names_l3v1[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
		"reactant",
		"product", 
		"modifier", 
		"kineticLaw",
		"reversible", 
		"fast",
    "compartment",
		"isSetFast",
    "level",
    "version"};

  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacName;
  const char * pacId = NULL;
  const char * pacCompartment = NULL;
  int nSBO = -1;

  int nReversible;
  int nFast;

  unsigned int unIsSetFast = 1;
  Reaction_t *pReaction;

  int i;
  
  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxReactionReturn = mxCreateStructArray(2, dims, nNoFields_l1, field_names_l1);
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxReactionReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxReactionReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxReactionReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxReactionReturn = mxCreateStructArray(2, dims, nNoFields_l3v1, field_names_l3v1);
    }
  }


  for (i = 0; i < n; i++) {
    pReaction = Model_getReaction(pModel, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t*) pReaction));
    
    pacNotes        = SBase_getNotesString((SBase_t*) pReaction);
    pacAnnotations  = SBase_getAnnotationString((SBase_t*) pReaction);
    
    if (unSBMLLevel == 1)
    {
      pacName            = Reaction_getId(pReaction);
    }
    else
    {
      pacName            = Reaction_getName(pReaction);
    }
    nReversible     = Reaction_getReversible(pReaction);
    nFast           = Reaction_getFast(pReaction);
    GetReactants(pReaction, unSBMLLevel, unSBMLVersion);
    GetProducts(pReaction, unSBMLLevel, unSBMLVersion);
    
    GetKineticLaw(pReaction, unSBMLLevel, unSBMLVersion);
    
    if (unSBMLLevel == 2) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pReaction);
      pacId       = Reaction_getId(pReaction);
      unIsSetFast = Reaction_isSetFast(pReaction);
      GetModifier(pReaction, unSBMLLevel, unSBMLVersion);   
        
      switch (unSBMLVersion)
      {
      case 1:
        break;
      case 2:
        if (SBase_isSetSBOTerm((SBase_t*) pReaction)) 
        {
          nSBO = SBase_getSBOTerm((SBase_t*) pReaction);
        }
        else
        {
          nSBO = -1;
        }
        break;
      case 3:
      case 4:
        if (SBase_isSetSBOTerm((SBase_t*) pReaction)) 
        {
          nSBO = SBase_getSBOTerm((SBase_t*) pReaction);
        }
        else
        {
          nSBO = -1;
        }
        break;
      default:
        break;
      }
    }
    else if (unSBMLLevel == 3) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pReaction);
      pacId       = Reaction_getId(pReaction);
      unIsSetFast = Reaction_isSetFast(pReaction);
      GetModifier(pReaction, unSBMLLevel, unSBMLVersion);   
      pacCompartment       = Reaction_getCompartment(pReaction);
        
      if (SBase_isSetSBOTerm((SBase_t*) pReaction)) 
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pReaction);
      }
      else
      {
        nSBO = -1;
      }
   }

    /* record any unset values as not specified */
    if (unIsSetFast == 0) {
    /* since in level 2 the fast field is optional a 
    value of -1 indicates that the user has chosen not to set */
        nFast = -1;
    }
    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacName == NULL) {
      pacName = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacCompartment == NULL) {
      pacCompartment = "";
    }

    /* put into structure */
    mxSetField( mxReactionReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxReactionReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxReactionReturn,i,"typecode",mxCreateString(pacTypecode)); 
    if (unSBMLLevel > 1)
    {
      mxSetField(mxReactionReturn, i, "metaid", mxCreateString(pacMetaid));
    }
    mxSetField(mxReactionReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxReactionReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2) 
    {
      mxSetField(mxReactionReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxReactionReturn,i,"name",mxCreateString(pacName)); 
    if (unSBMLLevel > 1) {
      mxSetField(mxReactionReturn,i,"id",mxCreateString(pacId)); 
    }
    mxSetField(mxReactionReturn,i,"reactant",mxReactantReturn); 
    mxSetField(mxReactionReturn,i,"product",mxProductReturn); 
    if (unSBMLLevel > 1) {
      mxSetField(mxReactionReturn,i,"modifier",mxModifierReturn); 
    }
    mxSetField(mxReactionReturn,i,"kineticLaw",mxKineticLawReturn); 
    mxSetField(mxReactionReturn,i,"reversible",CreateIntScalar(nReversible)); 
    mxSetField(mxReactionReturn,i,"fast",CreateIntScalar(nFast)); 
    if (unSBMLLevel == 2) {
       if (unSBMLVersion == 2){
        mxSetField(mxReactionReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
      }
      mxSetField(mxReactionReturn,i,"isSetFast",CreateIntScalar(unIsSetFast)); 
   }
    else if (unSBMLLevel == 3)
    {
      mxSetField(mxReactionReturn,i,"compartment",mxCreateString(pacCompartment)); 
      mxSetField(mxReactionReturn,i,"isSetFast",CreateIntScalar(unIsSetFast)); 
    }

    mxReactantReturn   = NULL;
    mxProductReturn    = NULL;
    mxKineticLawReturn = NULL;
    mxModifierReturn   = NULL;
  }
}


/**
 * NAME:    GetUnit
 *
 * PARAMETERS:  Pointer to a unit definition
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the unit mxArray structure
 *            populates the structure with all the units in the unit definition
 */
void
GetUnit ( UnitDefinition_t *pUnitDefinition,
          unsigned int     unSBMLLevel,
          unsigned int     unSBMLVersion )
{
  int n = UnitDefinition_getNumUnits(pUnitDefinition);
  mwSize dims[2] = {1, n};

  /* fields within a species structure */
  const int nNoFields_l1 = 8;
  const char *field_names_l1[] = {	
    "typecode", 
		"notes", 
		"annotation",
		"kind", 
		"exponent",
		"scale",
    "level",
    "version"};
  const int nNoFields_l2 = 11;
  const char *field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"kind", 
		"exponent", 
		"scale", 
		"multiplier", 
		"offset",
    "level",
    "version"};
  const int nNoFields_l2v2 = 10;
  const char *field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"kind", 
		"exponent", 
		"scale", 
		"multiplier",
    "level",
    "version"};
  const int nNoFields_l2v3 = 11;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"kind", 
		"exponent", 
		"scale", 
		"multiplier",
    "level",
    "version"};
  /* determine the values */
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacUnitKind;
  int nExponent = 1;
  int nScale = 0;
  double dMultiplier = 1.0;
  double dOffset = 0.0;
  int nSBO = -1;
  double dExponent = 1.0;

  Unit_t *pUnit;
  int i;
      

  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxUnitReturn = mxCreateStructArray(2, dims, nNoFields_l1, field_names_l1);
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxUnitReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxUnitReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxUnitReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxUnitReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }

  for (i = 0; i < n; i++) {
    pUnit = UnitDefinition_getUnit(pUnitDefinition, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t*) pUnit));
    
    pacNotes        = SBase_getNotesString((SBase_t*) pUnit);
    pacAnnotations  = SBase_getAnnotationString((SBase_t*) pUnit);
    
    pacUnitKind     = UnitKind_toString(Unit_getKind(pUnit));
    nScale          = Unit_getScale(pUnit);
    if (unSBMLLevel == 1) 
    {
      nExponent       = Unit_getExponent(pUnit);
    }
    else if (unSBMLLevel == 2) 
    {
      nExponent       = Unit_getExponent(pUnit);
      pacMetaid = SBase_getMetaId((SBase_t*)pUnit);
      dMultiplier = Unit_getMultiplier(pUnit);
      switch (unSBMLVersion)
      {
      case 1:
        dOffset = Unit_getOffset(pUnit);
        break;
      case 2:
       break;
      case 3:
      case 4:
        if (SBase_isSetSBOTerm((SBase_t*) pUnit)) 
        {
          nSBO = SBase_getSBOTerm((SBase_t*) pUnit);
        }
        else
        {
          nSBO = -1;
        }
        break;
      default:
        break;
      }
   }

    else if (unSBMLLevel == 3) 
    {
      dExponent       = Unit_getExponentAsDouble(pUnit);
      pacMetaid = SBase_getMetaId((SBase_t*)pUnit);
      dMultiplier = Unit_getMultiplier(pUnit);
      if (SBase_isSetSBOTerm((SBase_t*) pUnit)) 
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pUnit);
      }
      else
      {
        nSBO = -1;
      }
   }

    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacUnitKind == NULL) {
      pacUnitKind = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }    
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }

    /* put into structure */
    mxSetField( mxUnitReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxUnitReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxUnitReturn,i,"typecode",mxCreateString(pacTypecode)); 
    if (unSBMLLevel > 1)
    {
      mxSetField(mxUnitReturn, i, "metaid", mxCreateString(pacMetaid));
    }
    mxSetField(mxUnitReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxUnitReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2)
    {
      mxSetField(mxUnitReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxUnitReturn,i,"kind",mxCreateString(pacUnitKind)); 
    if (unSBMLLevel < 3)
    {
      mxSetField(mxUnitReturn,i,"exponent",CreateIntScalar(nExponent)); 
    }
    else
    {
      mxSetField(mxUnitReturn,i,"exponent",mxCreateDoubleScalar(dExponent)); 
    }
    mxSetField(mxUnitReturn,i,"scale",CreateIntScalar(nScale)); 
    if (unSBMLLevel == 2) {
      mxSetField(mxUnitReturn,i,"multiplier",mxCreateDoubleScalar(dMultiplier)); 
      if (unSBMLVersion == 1) {
        mxSetField(mxUnitReturn,i,"offset",mxCreateDoubleScalar(dOffset)); 
      }
    }
    else if (unSBMLLevel > 2)
    {
      mxSetField(mxUnitReturn,i,"multiplier",mxCreateDoubleScalar(dMultiplier)); 
    }
  }
}


/**
 * NAME:    GetReactants
 *
 * PARAMETERS:  Pointer to a reaction
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 * RETURNS:    void
 *
 * FUNCTION:  creates the species reference mxArray structure
 *            populates the structure with all the species references 
 *            listed as reactants in the reaction
 */
void
GetReactants ( Reaction_t   *pReaction,
               unsigned int unSBMLLevel,
               unsigned int unSBMLVersion )
{
  int n = Reaction_getNumReactants(pReaction);
  mwSize dims[2] = {1, n};

  /* fields within a species structure */
  const int nNoFields_l1 = 8;
  const char *field_names_l1[] = {	
    "typecode", 
		"notes", 
		"annotation",
		"species", 
		"stoichiometry",
		"denominator",
    "level",
    "version"};
  const int nNoFields_l2 = 10;
  const char *field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"species", 
		"stoichiometry",
		"denominator", 
		"stoichiometryMath",
    "level",
    "version"};
  const int nNoFields_l2v2 = 12;
  const char *field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"species", 
    "id",
    "name",
    "sboTerm",
		"stoichiometry",
		"stoichiometryMath",
    "level",
    "version"};
  const int nNoFields_l2v3 = 12;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"species", 
    "id",
    "name",
		"stoichiometry",
		"stoichiometryMath",
    "level",
    "version"};
  const int nNoFields_l3v1 = 13;
  const char *field_names_l3v1[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"species", 
    "id",
    "name",
		"stoichiometry",
		"constant",
    "isSetStoichiometry",
    "level",
    "version"};
   /* determine the values */
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacSpecies;
  const char * pacStoichMath = NULL;
  const char * pacId = NULL;
  const char * pacName = NULL;
  int nSBO = -1;
  
  int nStoichiometry = 1;
  int nDenominator = 1;
  unsigned int unIsSetStoichiometry = 1;
  
  int nConstant = 1;

  double dStoichiometry = 1.0;

  SpeciesReference_t *pReactant;
  int i;
      

  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxReactantReturn = mxCreateStructArray(2, dims, nNoFields_l1, field_names_l1);
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxReactantReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxReactantReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxReactantReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxReactantReturn = mxCreateStructArray(2, dims, nNoFields_l3v1, field_names_l3v1);
    }
  }

  for (i = 0; i < n; i++) {
    pReactant = Reaction_getReactant(pReaction, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t*) pReactant));
    
    pacNotes        = SBase_getNotesString((SBase_t*) pReactant);
    pacAnnotations  = SBase_getAnnotationString((SBase_t*) pReactant);
    
    pacSpecies      = SpeciesReference_getSpecies(pReactant);
    if (unSBMLLevel == 1) 
    {
      nStoichiometry = (int) SpeciesReference_getStoichiometry(pReactant);
      nDenominator = SpeciesReference_getDenominator(pReactant);
    }
    else if (unSBMLLevel == 2) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pReactant);
      switch (unSBMLVersion)
      {
      case 1:
        nDenominator = SpeciesReference_getDenominator(pReactant);
        dStoichiometry = SpeciesReference_getStoichiometry(pReactant);
        if (SpeciesReference_isSetStoichiometryMath(pReactant) == 1) 
        {
          pacStoichMath = SBML_formulaToString(StoichiometryMath_getMath(SpeciesReference_getStoichiometryMath(pReactant)));
        }
        break;
      case 2:
        dStoichiometry = SpeciesReference_getStoichiometry(pReactant);
        if (SpeciesReference_isSetStoichiometryMath(pReactant) == 1) 
        {
          pacStoichMath = SBML_formulaToString(StoichiometryMath_getMath(SpeciesReference_getStoichiometryMath(pReactant)));
        }
        pacId       = SpeciesReference_getId(pReactant);
        pacName     = SpeciesReference_getName(pReactant);
        if (SBase_isSetSBOTerm((SBase_t*) pReactant)) {
          nSBO = SBase_getSBOTerm((SBase_t*) pReactant);
        }
        else
        {
          nSBO = -1;
        }
        break;
      case 3:
      case 4:
        dStoichiometry = SpeciesReference_getStoichiometry(pReactant);
        GetStoichiometryMath(pReactant, unSBMLLevel, unSBMLVersion);
        pacId       = SpeciesReference_getId(pReactant);
        pacName     = SpeciesReference_getName(pReactant);
        if (SBase_isSetSBOTerm((SBase_t*) pReactant)) {
          nSBO = SBase_getSBOTerm((SBase_t*) pReactant);
        }
        else
        {
          nSBO = -1;
        }
        break;
      default:
        break;
      }
    }
    else if (unSBMLLevel == 3) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pReactant);
      dStoichiometry = SpeciesReference_getStoichiometry(pReactant);
      pacId       = SpeciesReference_getId(pReactant);
      pacName     = SpeciesReference_getName(pReactant);
      if (SBase_isSetSBOTerm((SBase_t*) pReactant)) {
        nSBO = SBase_getSBOTerm((SBase_t*) pReactant);
      }
      else
      {
        nSBO = -1;
      }
      nConstant = SpeciesReference_getConstant(pReactant);
      unIsSetStoichiometry = SpeciesReference_isSetStoichiometry(pReactant);
   }
        
    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacSpecies == NULL) {
      pacSpecies = "";
    }
    if (pacStoichMath == NULL) {
      pacStoichMath = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }    
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }
    if (pacName == NULL) {
      pacName = "";
    }

    /* put into structure */
    mxSetField( mxReactantReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxReactantReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxReactantReturn,i,"typecode",mxCreateString(pacTypecode)); 
    if (unSBMLLevel > 1)
    {
      mxSetField(mxReactantReturn, i, "metaid", mxCreateString(pacMetaid));
    }
    mxSetField(mxReactantReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxReactantReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2) 
    {
      mxSetField(mxReactantReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxReactantReturn,i,"species",mxCreateString(pacSpecies));
    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2)
    {
      mxSetField(mxReactantReturn,i,"id",mxCreateString(pacId));
      mxSetField(mxReactantReturn,i,"name",mxCreateString(pacName));
    }
    if (unSBMLLevel == 2 && unSBMLVersion == 2)
    {
      mxSetField(mxReactantReturn,i,"id",mxCreateString(pacId));
      mxSetField(mxReactantReturn,i,"name",mxCreateString(pacName));
      mxSetField(mxReactantReturn,i,"sboTerm",CreateIntScalar(nSBO));
    }
    if (unSBMLLevel == 1) {
      mxSetField(mxReactantReturn,i,"stoichiometry",CreateIntScalar(nStoichiometry)); 
      mxSetField(mxReactantReturn,i,"denominator",CreateIntScalar(nDenominator));
    }
    else if (unSBMLLevel == 2) {
      mxSetField(mxReactantReturn,i,"stoichiometry",mxCreateDoubleScalar(dStoichiometry));
      if (unSBMLVersion == 1) {
       mxSetField(mxReactantReturn,i,"denominator",CreateIntScalar(nDenominator));
      }
      if(unSBMLVersion < 3)
      {
        mxSetField(mxReactantReturn,i,"stoichiometryMath",mxCreateString(pacStoichMath));
      }
      else
      {
        mxSetField(mxReactantReturn,i,"stoichiometryMath",mxStoichiometryMathReturn);
      }
    }
    else if (unSBMLLevel == 3) {
      mxSetField(mxReactantReturn,i,"stoichiometry",mxCreateDoubleScalar(dStoichiometry)); 
      mxSetField(mxReactantReturn,i,"constant",CreateIntScalar(nConstant)); 
      mxSetField(mxReactantReturn,i,"isSetStoichiometry",CreateIntScalar(unIsSetStoichiometry)); 
     }
    
    mxStoichiometryMathReturn = NULL;
  }
}


/**
 * NAME:    GetProducts
 *
 * PARAMETERS:  Pointer to a reaction
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the species reference mxArray structure
 *            populates the structure with all the species references 
 *            listed as products in the reaction
 */
void
GetProducts ( Reaction_t   *pReaction,
              unsigned int unSBMLLevel,
              unsigned int unSBMLVersion )
{
  int n = Reaction_getNumProducts(pReaction);
  mwSize dims[2] = {1, n};

  /* fields within a species structure */
  const int nNoFields_l1 = 8;
  const char *field_names_l1[] = {
    "typecode", 
		"notes", 
		"annotation",
		"species", 
		"stoichiometry",
		"denominator",
    "level",
    "version"};
  const int nNoFields_l2 = 10;
  const char *field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"species", 
		"stoichiometry",
		"denominator", 
		"stoichiometryMath",
    "level",
    "version"};
const int nNoFields_l2v2 = 12;
  const char *field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"species", 
    "id",
    "name",
    "sboTerm",
		"stoichiometry",
		"stoichiometryMath",
    "level",
    "version"};
  const int nNoFields_l2v3 = 12;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"species", 
    "id",
    "name",
		"stoichiometry",
		"stoichiometryMath",
    "level",
    "version"};
  const int nNoFields_l3v1 = 13;
  const char *field_names_l3v1[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"species", 
    "id",
    "name",
		"stoichiometry",
		"constant",
    "isSetStoichiometry",
    "level",
    "version"};
   /* determine the values */
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacSpecies;
  const char * pacStoichMath = NULL;
  const char * pacId = NULL;
  const char * pacName = NULL;
  int nSBO = -1;
  
  int nStoichiometry = 1;
  int nDenominator = 1;
  
  unsigned int unIsSetStoichiometry = 1;
  
  int nConstant = 1;

  double dStoichiometry = 1.0;

  SpeciesReference_t *pProduct;
  int i;
      

  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxProductReturn = mxCreateStructArray(2, dims, nNoFields_l1, field_names_l1);
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxProductReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxProductReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxProductReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxProductReturn = mxCreateStructArray(2, dims, nNoFields_l3v1, field_names_l3v1);
    }
  }

  for (i = 0; i < n; i++) {
    pProduct = Reaction_getProduct(pReaction, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t*) pProduct));
    
    pacNotes        = SBase_getNotesString((SBase_t*) pProduct);
    pacAnnotations  = SBase_getAnnotationString((SBase_t*) pProduct);
    
    pacSpecies      = SpeciesReference_getSpecies(pProduct);
    if (unSBMLLevel == 1) 
    {
      nStoichiometry = (int) SpeciesReference_getStoichiometry(pProduct);
      nDenominator = SpeciesReference_getDenominator(pProduct);
    }
    else if (unSBMLLevel == 2) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pProduct);
      switch (unSBMLVersion)
      {
      case 1:
        dStoichiometry = SpeciesReference_getStoichiometry(pProduct);
        if (SpeciesReference_isSetStoichiometryMath(pProduct) == 1) 
        {
          pacStoichMath = SBML_formulaToString(StoichiometryMath_getMath(SpeciesReference_getStoichiometryMath(pProduct)));
        }
        nDenominator = SpeciesReference_getDenominator(pProduct);
        break;
      case 2:
        dStoichiometry = SpeciesReference_getStoichiometry(pProduct);
        if (SpeciesReference_isSetStoichiometryMath(pProduct) == 1) 
        {
          pacStoichMath = SBML_formulaToString(StoichiometryMath_getMath(SpeciesReference_getStoichiometryMath(pProduct)));
        }
        pacId       = SpeciesReference_getId(pProduct);
        pacName     = SpeciesReference_getName(pProduct);
        if (SBase_isSetSBOTerm((SBase_t*) pProduct)) {
          nSBO = SBase_getSBOTerm((SBase_t*) pProduct);
        }
        else
        {
          nSBO = -1;
        }
        break;
      case 3:
      case 4:
        dStoichiometry = SpeciesReference_getStoichiometry(pProduct);
        GetStoichiometryMath(pProduct, unSBMLLevel, unSBMLVersion);
        pacId       = SpeciesReference_getId(pProduct);
        pacName     = SpeciesReference_getName(pProduct);
        if (SBase_isSetSBOTerm((SBase_t*) pProduct)) {
          nSBO = SBase_getSBOTerm((SBase_t*) pProduct);
        }
        else
        {
          nSBO = -1;
        }
        break;
      default:
        break;
      }
    }
    else if (unSBMLLevel == 3) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pProduct);
      unIsSetStoichiometry = SpeciesReference_isSetStoichiometry(pProduct);
      dStoichiometry = SpeciesReference_getStoichiometry(pProduct);
      pacId       = SpeciesReference_getId(pProduct);
      pacName     = SpeciesReference_getName(pProduct);
      if (SBase_isSetSBOTerm((SBase_t*) pProduct)) {
        nSBO = SBase_getSBOTerm((SBase_t*) pProduct);
      }
      else
      {
        nSBO = -1;
      }
      nConstant = SpeciesReference_getConstant(pProduct);
   }

    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacSpecies == NULL) {
      pacSpecies = "";
    }
    if (pacStoichMath == NULL) {
      pacStoichMath = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }    
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }
    if (pacName == NULL) {
      pacName = "";
    }

    /* put into structure */
    mxSetField( mxProductReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxProductReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxProductReturn,i,"typecode",mxCreateString(pacTypecode)); 
    if (unSBMLLevel > 1)
    {
      mxSetField(mxProductReturn, i, "metaid", mxCreateString(pacMetaid));
    }
    mxSetField(mxProductReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxProductReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2) 
    {
      mxSetField(mxProductReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxProductReturn,i,"species",mxCreateString(pacSpecies)); 
    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2)
    {
      mxSetField(mxProductReturn,i,"id",mxCreateString(pacId));
      mxSetField(mxProductReturn,i,"name",mxCreateString(pacName));
    }
    if (unSBMLLevel == 2 && unSBMLVersion == 2)
    {
      mxSetField(mxProductReturn,i,"id",mxCreateString(pacId));
      mxSetField(mxProductReturn,i,"name",mxCreateString(pacName));
      mxSetField(mxProductReturn,i,"sboTerm",CreateIntScalar(nSBO));
    }
    if (unSBMLLevel == 1) {
      mxSetField(mxProductReturn,i,"stoichiometry",CreateIntScalar(nStoichiometry)); 
      mxSetField(mxProductReturn,i,"denominator",CreateIntScalar(nDenominator));
    }
    else if (unSBMLLevel == 2) {
      mxSetField(mxProductReturn,i,"stoichiometry",mxCreateDoubleScalar(dStoichiometry)); 
      if (unSBMLVersion == 1) {
        mxSetField(mxProductReturn,i,"denominator",CreateIntScalar(nDenominator));
      }
      if(unSBMLVersion < 3)
      {
        mxSetField(mxProductReturn,i,"stoichiometryMath",mxCreateString(pacStoichMath));
      }
      else
      {
        mxSetField(mxProductReturn,i,"stoichiometryMath",mxStoichiometryMathReturn);
      }
    }
    else if (unSBMLLevel == 3) {
      mxSetField(mxProductReturn,i,"stoichiometry",mxCreateDoubleScalar(dStoichiometry)); 
      mxSetField(mxProductReturn,i,"constant",CreateIntScalar(nConstant)); 
      mxSetField(mxProductReturn,i,"isSetStoichiometry",CreateIntScalar(unIsSetStoichiometry)); 
     }
    
    mxStoichiometryMathReturn = NULL;
  }
}


/**
 * NAME:    GetStoichiometryMath
 *
 * PARAMETERS:  Pointer to a speciesReference
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the trigger mxArray structure
 *            populates the structure with trigger
 *            in the event
 */
void
GetStoichiometryMath ( SpeciesReference_t      *pSpeciesReference,
                     unsigned int unSBMLLevel,
                     unsigned int unSBMLVersion )
{
  int n = (SpeciesReference_isSetStoichiometryMath(pSpeciesReference)) ? 1 : 0;
  mwSize dims[2] = {1, n};

  const int nNoFields_l2v3 = 8;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"math",
    "level",
    "version"};
  /* determine the values */
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacFormula = NULL;
  int nSBO = -1;

  StoichiometryMath_t * pStoichiometryMath;
  
  /* variables for mathML - matlab hack */
  int nStatus;
  size_t nBuflen;
  mxArray * mxInput[1], * mxOutput[1];
   

  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
    mxStoichiometryMathReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion > 2)
    {
      mxStoichiometryMathReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
    else  
    {
      mxStoichiometryMathReturn = NULL;
    }
  }

  if (SpeciesReference_isSetStoichiometryMath(pSpeciesReference))
  {
  pStoichiometryMath = SpeciesReference_getStoichiometryMath(pSpeciesReference);

  /* determine the values */
  pacTypecode       = TypecodeToChar(SBase_getTypeCode((SBase_t *) pStoichiometryMath));

  pacNotes          = SBase_getNotesString((SBase_t *) pStoichiometryMath);
  pacAnnotations    = SBase_getAnnotationString((SBase_t *) pStoichiometryMath);
  pacMetaid = SBase_getMetaId((SBase_t*)pStoichiometryMath);

  if (SBase_isSetSBOTerm((SBase_t*) pStoichiometryMath))
  {
    nSBO = SBase_getSBOTerm((SBase_t*) pStoichiometryMath);
  }
  else
  {
    nSBO = -1;
  }
    
  if (StoichiometryMath_isSetMath(pStoichiometryMath)) {
    LookForCSymbolTime((ASTNode_t*)StoichiometryMath_getMath(pStoichiometryMath));
    LookForCSymbolDelay((ASTNode_t*)StoichiometryMath_getMath(pStoichiometryMath));
    pacFormula = SBML_formulaToString((ASTNode_t*)StoichiometryMath_getMath(pStoichiometryMath));

     /* temporary hack to convert MathML in-fix to MATLAB compatible formula */

    mxInput[0] = mxCreateString(pacFormula);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");

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

    mxDestroyArray(mxInput[0]);
    mxDestroyArray(mxOutput[0]);
    /* END OF HACK */
  }
  /**
   * check for NULL strings - Matlab doesnt like creating 
   * a string that is NULL
   */
  if (pacNotes == NULL) {
    pacNotes = "";
  }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
  if (pacAnnotations == NULL) {
    pacAnnotations = "";
  }
  if (pacFormula == NULL) {
    pacFormula = "";
  }

  /* put into structure */
  mxSetField( mxStoichiometryMathReturn, 0, "level"      , CreateIntScalar(unSBMLLevel)   ); 
  mxSetField( mxStoichiometryMathReturn, 0, "version"    , CreateIntScalar(unSBMLVersion) );

  mxSetField(mxStoichiometryMathReturn, 0, "typecode",   mxCreateString(pacTypecode)); 
  mxSetField(mxStoichiometryMathReturn, 0, "metaid", mxCreateString(pacMetaid));
  mxSetField(mxStoichiometryMathReturn, 0, "notes",      mxCreateString(pacNotes));
  mxSetField(mxStoichiometryMathReturn, 0, "annotation", mxCreateString(pacAnnotations));

  if (strcmp(pacAnnotations, "") != 0)
  {
    util_free((char*)pacAnnotations);
  }
  if (strcmp(pacNotes, "") != 0)
  {
    util_free((char*)pacNotes);
  }

  mxSetField(mxStoichiometryMathReturn, 0, "sboTerm",    CreateIntScalar(nSBO)); 
  mxSetField(mxStoichiometryMathReturn, 0, "math",       mxCreateString(pacFormula)); 
  }
}
/**
 * NAME:    GetKineticLaw
 *
 * PARAMETERS:  Pointer to a reaction
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the kinetic law mxArray structure
 *            populates the structure with the kinetic law 
 *            for the reaction
 */
void
GetKineticLaw ( Reaction_t   *pReaction,
                unsigned int unSBMLLevel,
                unsigned int unSBMLVersion)
{
  int n = Reaction_isSetKineticLaw(pReaction) ? 1 : 0;
  mwSize dims[2] = {1, n};

  /* fields within a species structure */
  const int nNoFields_l1 = 9;
  const char *field_names_l1[] = {	
    "typecode", 
		"notes", 
		"annotation",
		"formula",	
		"parameter",
		"timeUnits", 
		"substanceUnits",
    "level",
    "version"};
  const int nNoFields_l2 = 11;
  const char *field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"formula", 
		"math", 
		"parameter",
		"timeUnits", 
		"substanceUnits",
    "level",
    "version"};
  const int nNoFields_l2v2 = 10;
  const char *field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"formula", 
		"math", 
		"parameter",
    "sboTerm",
    "level",
    "version"};
  const int nNoFields_l2v3 = 10;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"formula", 
		"math", 
		"parameter",
    "level",
    "version"};
  const int nNoFields_l3v1 = 9;
  const char *field_names_l3v1[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"math", 
		"localParameter",
    "level",
    "version"};
  /* determine the values */
  const char * pacTypecode = NULL;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacFormula = NULL;
  const char * pacTimeUnits = NULL;
  const char * pacSubstanceUnits = NULL;
  const char * pacMathFormula = NULL;
  int nSBO = -1;

  KineticLaw_t *pKineticLaw;
  
  /* variables for mathML - matlab hack */
  int nStatus;
  size_t nBuflen;
  mxArray * mxInput[1], * mxOutput[1];


  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxKineticLawReturn = mxCreateStructArray(2, dims, nNoFields_l1, field_names_l1);
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxKineticLawReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxKineticLawReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxKineticLawReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxKineticLawReturn = mxCreateStructArray(2, dims, nNoFields_l3v1, field_names_l3v1);
    }
  }

  /* determine the values dealing with the very unusual situation in which
     no kinetic law has been set */
   
  if (n == 1)
  {
  pKineticLaw = Reaction_getKineticLaw(pReaction);


  if (pKineticLaw != NULL)
  {
    pacTypecode = TypecodeToChar(SBase_getTypeCode((SBase_t*) pKineticLaw));
    
    pacNotes          = SBase_getNotesString((SBase_t*) pKineticLaw);
    pacAnnotations    = SBase_getAnnotationString((SBase_t*) pKineticLaw);
    
    if (unSBMLLevel < 3)
    {
      pacFormula        = KineticLaw_getFormula(pKineticLaw);
    }

    GetKineticLawParameters(pKineticLaw, unSBMLLevel, unSBMLVersion);
    
    if (unSBMLLevel == 1)
    {
      pacTimeUnits      = KineticLaw_getTimeUnits(pKineticLaw);
      pacSubstanceUnits = KineticLaw_getSubstanceUnits(pKineticLaw);
    }
    else if (unSBMLLevel == 2)
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pKineticLaw);
     /* if level two set the math formula */
     if (KineticLaw_isSetMath(pKineticLaw)) 
      {
        /* look for csymbol time */
        LookForCSymbolTime((ASTNode_t*)KineticLaw_getMath(pKineticLaw));
        LookForCSymbolDelay((ASTNode_t*)KineticLaw_getMath(pKineticLaw));
      /*  KineticLaw_setFormulaFromMath(pKineticLaw); */
        pacMathFormula = SBML_formulaToString((ASTNode_t*)KineticLaw_getMath(pKineticLaw));
      }
      
      switch (unSBMLVersion)
      {
      case 1:
        pacTimeUnits      = KineticLaw_getTimeUnits(pKineticLaw);
        pacSubstanceUnits = KineticLaw_getSubstanceUnits(pKineticLaw);
        break;
      case 2:
        if (SBase_isSetSBOTerm((SBase_t*) pKineticLaw)) 
        {
          nSBO = SBase_getSBOTerm((SBase_t*) pKineticLaw);
        }
         else
        {
          nSBO = -1;
        }
       break;
      case 3:
      case 4:
        if (SBase_isSetSBOTerm((SBase_t*) pKineticLaw)) 
        {
          nSBO = SBase_getSBOTerm((SBase_t*) pKineticLaw);
        }
        else
        {
          nSBO = -1;
        }
        break;
      default:
        break;
      }
    }
    else if (unSBMLLevel == 3)
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pKineticLaw);
     /* if level two set the math formula */
     if (KineticLaw_isSetMath(pKineticLaw)) 
      {
        /* look for csymbol time */
        LookForCSymbolTime((ASTNode_t*)KineticLaw_getMath(pKineticLaw));
        LookForCSymbolDelay((ASTNode_t*)KineticLaw_getMath(pKineticLaw));
        LookForCSymbolAvo((ASTNode_t*)KineticLaw_getMath(pKineticLaw));
      /*  KineticLaw_setFormulaFromMath(pKineticLaw); */
        pacMathFormula = SBML_formulaToString((ASTNode_t*)KineticLaw_getMath(pKineticLaw));
      }
      
      if (SBase_isSetSBOTerm((SBase_t*) pKineticLaw)) 
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pKineticLaw);
      }
        else
      {
        nSBO = -1;
      }
    }
    
    /* temporary hack to convert MathML in-fix to MATLAB compatible formula */
    
    if (unSBMLLevel < 3)
    {
      mxInput[0] = mxCreateString(pacFormula);
      nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");
      
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

      mxDestroyArray(mxInput[0]);
      mxDestroyArray(mxOutput[0]);
      /* END OF HACK */
    }
    else
    {
      mxInput[0] = mxCreateString(pacMathFormula);
      nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");
      
      if (nStatus != 0)
      {
          mexErrMsgTxt("Failed to convert formula");
      }
      
      /* get the formula returned */
      nBuflen = (mxGetM(mxOutput[0])*mxGetN(mxOutput[0])+1);
      pacMathFormula = (char *) mxCalloc(nBuflen, sizeof(char));
      nStatus = mxGetString(mxOutput[0], (char *) pacMathFormula, (mwSize)(nBuflen));
      
      if (nStatus != 0)
      {
          mexErrMsgTxt("Cannot copy formula");
      }

      mxDestroyArray(mxInput[0]);
      mxDestroyArray(mxOutput[0]);
      /* END OF HACK */
    }
 }
  else 
  {
    pacFormula = NULL;
    pacMathFormula = NULL;
    mxKineticLawParameterReturn = NULL;
  }

  /**
   * check for NULL strings - Matlab doesnt like creating 
   * a string that is NULL
   */
  if (pacTypecode == NULL) {
    pacTypecode = "SBML_KINETIC_LAW";
  }
  if (pacFormula == NULL) {
    pacFormula = "";
  }
  if (pacMathFormula == NULL) {
    pacMathFormula = "";
  }
  if (pacTimeUnits == NULL) {
    pacTimeUnits = "";
  }
  if (pacSubstanceUnits == NULL) {
    pacSubstanceUnits = "";
  }
  if (pacNotes == NULL) {
    pacNotes = "";
  }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
  if (pacAnnotations == NULL) {
    pacAnnotations = "";
  }

  /* put into structure */
    mxSetField( mxKineticLawReturn, 0, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxKineticLawReturn, 0, "version"    , CreateIntScalar(unSBMLVersion) );

  mxSetField(mxKineticLawReturn,0,"typecode",mxCreateString(pacTypecode)); 
    if (unSBMLLevel > 1)
    {
      mxSetField(mxKineticLawReturn, 0, "metaid", mxCreateString(pacMetaid));
    }
  mxSetField(mxKineticLawReturn, 0, "notes",mxCreateString(pacNotes));
  mxSetField(mxKineticLawReturn, 0, "annotation",mxCreateString(pacAnnotations));

  if (strcmp(pacAnnotations, "") != 0)
  {
    util_free((char*)pacAnnotations);
  }
  if (strcmp(pacNotes, "") != 0)
  {
    util_free((char*)pacNotes);
  }

  if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2) 
  {
    mxSetField(mxKineticLawReturn, 0,"sboTerm",CreateIntScalar(nSBO)); 
  }
  if (unSBMLLevel < 3)
  {
    mxSetField(mxKineticLawReturn,0,"formula",mxCreateString(pacFormula)); 
  }
  if (unSBMLLevel > 1) {
    mxSetField(mxKineticLawReturn,0,"math",mxCreateString(pacMathFormula)); 
  }
  if (unSBMLLevel < 3)
  {
    mxSetField(mxKineticLawReturn,0,"parameter",mxKineticLawParameterReturn); 
  }
  else
  {
    mxSetField(mxKineticLawReturn,0,"localParameter",mxKineticLawParameterReturn); 
  }
  if (unSBMLLevel == 1 || (unSBMLLevel == 2 && unSBMLVersion == 1))
  {
    mxSetField(mxKineticLawReturn,0,"timeUnits",mxCreateString(pacTimeUnits)); 
    mxSetField(mxKineticLawReturn,0,"substanceUnits",mxCreateString(pacSubstanceUnits)); 
  }
  if (unSBMLLevel == 2 && unSBMLVersion == 2) {
    mxSetField(mxKineticLawReturn,0,"sboTerm",CreateIntScalar(nSBO)); 
  }
}
}


/**
 * NAME:    GetKineticLawParameters
 *
 * PARAMETERS:  Pointer to a kinetic law
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the parameter mxArray structure
 *            populates the structure with all the parameters 
 *            listed as for the kinetic law
 */
void
GetKineticLawParameters ( KineticLaw_t *pKineticLaw,
                          unsigned int unSBMLLevel,
                          unsigned int unSBMLVersion )
{
  int n = KineticLaw_getNumParameters(pKineticLaw);
  mwSize dims[2] = {1, n};

  const int nNoFields_l1 = 9;
  const char *field_names_l1[] = {	
    "typecode", 
		"notes", 
		"annotation",
		"name", 
		"value",
		"units", 
		"isSetValue",
    "level",
    "version"};
  const int nNoFields_l2 = 12;
  const char *field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
		"value",
		"units", 
		"constant", 
		"isSetValue",
    "level",
    "version"};
    const int nNoFields_l2v2 = 13;
  const char *field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
		"value",
		"units", 
		"constant",
    "sboTerm",
		"isSetValue",
    "level",
    "version"};
    const int nNoFields_l2v3 = 13;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
		"value",
		"units", 
		"constant",
		"isSetValue",
    "level",
    "version"};
    const int nNoFields_l3v1 = 12;
  const char *field_names_l3v1[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
		"value",
		"units", 
		"isSetValue",
    "level",
    "version"};
 
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacName;
  const char * pacId = NULL;
  const char * pacUnits;
  int nSBO = -1;

  double dValue;

  unsigned int unIsSetValue = 1;
  int nConstant = 1;

  Parameter_t *pParameter;

  int i;
  
  double dZero = 0.0;
      
  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxKineticLawParameterReturn = mxCreateStructArray(2, dims, nNoFields_l1, field_names_l1);
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxKineticLawParameterReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxKineticLawParameterReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxKineticLawParameterReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxKineticLawParameterReturn = mxCreateStructArray(2, dims, nNoFields_l3v1, field_names_l3v1);
    }
  }


  for (i = 0; i < n; i++) {
    pParameter = KineticLaw_getParameter(pKineticLaw, i);
    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t*) pParameter));
    
    pacNotes        = SBase_getNotesString((SBase_t*) pParameter);
    pacAnnotations  = SBase_getAnnotationString((SBase_t*) pParameter);
    
    if (unSBMLLevel == 1)
    {
      pacName            = Parameter_getId(pParameter);
    }
    else
    {
      pacName            = Parameter_getName(pParameter);
    }
    dValue          = Parameter_getValue(pParameter);
    pacUnits        = Parameter_getUnits(pParameter);
    unIsSetValue    = Parameter_isSetValue(pParameter);
    
    if (unSBMLLevel == 2) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pParameter);
      pacId     = Parameter_getId(pParameter);
      nConstant = Parameter_getConstant(pParameter);
      switch (unSBMLVersion)
      {
      case 1:
        break;
      case 2:
        if (SBase_isSetSBOTerm((SBase_t*) pParameter)) 
        {
          nSBO = SBase_getSBOTerm((SBase_t*) pParameter);
        }
        else
        {
          nSBO = -1;
        }
        break;
      case 3:
      case 4:
        if (SBase_isSetSBOTerm((SBase_t*) pParameter)) 
        {
          nSBO = SBase_getSBOTerm((SBase_t*) pParameter);
        }
        else
        {
          nSBO = -1;
        }
        break;
      default:
        break;
      }
    }

   else if (unSBMLLevel == 3) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pParameter);
      pacId     = Parameter_getId(pParameter);
      if (SBase_isSetSBOTerm((SBase_t*) pParameter)) 
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pParameter);
      }
      else
      {
        nSBO = -1;
      }
    }

    /* record any unset values as NAN */
    if (unIsSetValue == 0) {
        dValue = 0.0/dZero;
    }
    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacName == NULL) {
      pacName = "";
    }
    if (pacUnits == NULL) {
      pacUnits = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }

    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }

    /* put into structure */
    mxSetField( mxKineticLawParameterReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxKineticLawParameterReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxKineticLawParameterReturn,i,"typecode",mxCreateString(pacTypecode)); 
    if (unSBMLLevel > 1)
    {
      mxSetField(mxKineticLawParameterReturn, i, "metaid", mxCreateString(pacMetaid));
    }
    mxSetField(mxKineticLawParameterReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxKineticLawParameterReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2) 
    {
      mxSetField(mxKineticLawParameterReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxKineticLawParameterReturn,i,"name",mxCreateString(pacName)); 
    if (unSBMLLevel > 1) {
      mxSetField(mxKineticLawParameterReturn,i,"id",mxCreateString(pacId)); 
    }
    mxSetField(mxKineticLawParameterReturn,i,"value",mxCreateDoubleScalar(dValue)); 
    mxSetField(mxKineticLawParameterReturn,i,"units",mxCreateString(pacUnits)); 
    if (unSBMLLevel == 2) {
      mxSetField(mxKineticLawParameterReturn,i,"constant",CreateIntScalar(nConstant)); 
       if (unSBMLVersion == 2){
        mxSetField(mxKineticLawParameterReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
      }
   }
    mxSetField(mxKineticLawParameterReturn,i,"isSetValue",CreateIntScalar(unIsSetValue)); 
  }
}


/**
 * NAME:    GetModifier
 *
 * PARAMETERS:  Pointer to a reaction
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the species reference mxArray structure
 *            populates the structure with all the species references 
 *            listed as modifiers in the reaction
 */
void
GetModifier ( Reaction_t   *pReaction,
              unsigned int unSBMLLevel,
              unsigned int unSBMLVersion )
{
  int n = Reaction_getNumModifiers(pReaction);
  mwSize dims[2] = {1, n};

  /* fields within a species structure */
  const int nNoFields_l2 = 7;
  const char *field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"species",
    "level",
    "version"};
  const int nNoFields_l2v2 = 10;
  const char *field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"species",
    "id",
    "name",
    "sboTerm",
    "level",
    "version"};
  const int nNoFields_l2v3 = 10;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"species",
    "id",
    "name",
    "level",
    "version"};
  /* determine the values */
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacSpecies;
  const char * pacId = NULL;
  const char * pacName = NULL;
  int nSBO = -1;

  SpeciesReference_t *pModifier;
  int i;
      

  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxModifierReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxModifierReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxModifierReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxModifierReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxModifierReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }


  for (i = 0; i < n; i++) {
    pModifier = Reaction_getModifier(pReaction, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t*) pModifier));
    
    pacNotes        = SBase_getNotesString((SBase_t*) pModifier);
    pacAnnotations  = SBase_getAnnotationString((SBase_t*) pModifier);
    pacMetaid = SBase_getMetaId((SBase_t*)pModifier);
    
    pacSpecies      = SpeciesReference_getSpecies(pModifier);
    if ((unSBMLLevel == 2 && unSBMLVersion > 1) || unSBMLLevel > 2)
    {
      pacId   = SpeciesReference_getId(pModifier);
      pacName = SpeciesReference_getName(pModifier);
      if (SBase_isSetSBOTerm((SBase_t*) pModifier)) 
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pModifier);
      }
      else
      {
        nSBO = -1;
      }
    }       

    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacSpecies == NULL) {
      pacSpecies = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
   if (pacId == NULL) {
      pacId = "";
    }
    if (pacName == NULL) {
      pacName = "";
    }

    /* put into structure */
    mxSetField( mxModifierReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxModifierReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxModifierReturn,i,"typecode",mxCreateString(pacTypecode)); 
    if (unSBMLLevel > 1)
    {
      mxSetField(mxModifierReturn, i, "metaid", mxCreateString(pacMetaid));
    }
    mxSetField(mxModifierReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxModifierReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2)
    {
      mxSetField(mxModifierReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxModifierReturn,i,"species",mxCreateString(pacSpecies)); 
    if (!(unSBMLLevel == 2 && unSBMLVersion == 1))
    {
      mxSetField(mxModifierReturn,i,"id",mxCreateString(pacId));
      mxSetField(mxModifierReturn,i,"name",mxCreateString(pacName));
    }
    if (unSBMLLevel == 2 && unSBMLVersion == 2)
    {
      mxSetField(mxModifierReturn,i,"sboTerm",CreateIntScalar(nSBO));
    }

  }
}


/**
 * NAME:    GetListRule
 *
 * PARAMETERS:  Pointer to a model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the rule mxArray structure
 *            populates the structure with all the rules in the model
 */
void
GetRule ( Model_t      *pModel,
              unsigned int unSBMLLevel,
              unsigned int unSBMLVersion )
{
  int n = Model_getNumRules(pModel);
  mwSize dims[2] = {1, n};

  /* fields within a rule structure */
  const int nNoFields_l1 = 12;
  const char *field_names_l1[] = {	
    "typecode", 
    "notes", 
    "annotation",
    "type",
    "formula", 
    "variable", 
    "species", 
    "compartment",
    "name", 
    "units",
    "level",
    "version"};
 
  const int nNoFields_l2 = 12;
  const char *field_names_l2[] = {	
    "typecode", 
    "metaid",
    "notes", 
    "annotation",
    "formula", 
    "variable", 
    "species", 
    "compartment",
    "name", 
    "units",
    "level",
    "version"};
  const int nNoFields_l2v2 = 13;
  const char *field_names_l2v2[] = {	
    "typecode", 
    "metaid",
    "notes", 
    "annotation",
    "sboTerm",
    "formula", 
    "variable", 
    "species", 
    "compartment",
    "name", 
    "units",
    "level",
    "version"};
  const int nNoFields_l2v3 = 13;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
    "notes", 
    "annotation",
    "sboTerm",
    "formula", 
    "variable", 
    "species", 
    "compartment",
    "name", 
    "units",
    "level",
    "version"};
  
  /* determine the values */
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacType = NULL;
  const char * pacFormula = NULL;
  const char * pacVariable = NULL;
  const char * pacSpecies = NULL;
  const char * pacCompartment = NULL;
  const char * pacName = NULL;
  const char * pacUnits = NULL;
  int nSBO = -1;

  Rule_t *pRule;
  int i;
  
  /* variables for mathML - matlab hack */
  int nStatus;
  size_t nBuflen;
  mxArray * mxInput[1], * mxOutput[1];

  if (unSBMLLevel == 1) 
  {
      mxListRuleReturn = mxCreateStructArray(2, dims, nNoFields_l1, field_names_l1);
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxListRuleReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxListRuleReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxListRuleReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxListRuleReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }

  for (i = 0; i < n; i++) {
    pRule = Model_getRule(pModel, i);
    /* determine the values */
    
    if (unSBMLLevel > 1)
      pacTypecode     = TypecodeToChar(Rule_getTypeCode(pRule));
    else
      pacTypecode     = TypecodeToChar(Rule_getL1TypeCode(pRule));
    
    /* need to look for an l1 algebraic rule */
    if (!strcmp(pacTypecode, "ERROR"))
       pacTypecode     = TypecodeToChar(Rule_getTypeCode(pRule));
       

    
    pacNotes        = SBase_getNotesString((SBase_t*) pRule);
    pacAnnotations  = SBase_getAnnotationString((SBase_t*) pRule);
    
    if (unSBMLLevel == 1) 
    {
      pacFormula = Rule_getFormula(pRule);
    }
    else if (unSBMLLevel > 1) 
    {
      pacMetaid = SBase_getMetaId((SBase_t*)pRule);
      if (Rule_isSetFormula(pRule) == 1){
        LookForCSymbolTime((ASTNode_t*)Rule_getMath(pRule));
        LookForCSymbolDelay((ASTNode_t*)Rule_getMath(pRule));
        LookForCSymbolAvo((ASTNode_t*)Rule_getMath(pRule));
        pacFormula = SBML_formulaToString((ASTNode_t*)Rule_getMath(pRule));
      }
    }

  /* temporary hack to convert MathML in-fix to MATLAB compatible formula */
  
  mxInput[0] = mxCreateString(pacFormula);
  nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");
  
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

  mxDestroyArray(mxInput[0]);
  mxDestroyArray(mxOutput[0]);
  /* END OF HACK */    
 
  /* values for different types of rules */
  if (unSBMLLevel == 1)
  {
    switch(Rule_getL1TypeCode(pRule)) {
      case SBML_ASSIGNMENT_RULE:
        if (unSBMLLevel == 1) {
          pacType = RuleType_toString(Rule_getType(pRule));
        }

        if (Rule_isSetVariable( pRule) == 1) {
          pacVariable = Rule_getVariable( pRule);
        }
        else {
          pacVariable = "";
        }
        pacSpecies = "";
        pacCompartment = "";
        pacName = "";
        pacUnits = "";
        break;
      case SBML_ALGEBRAIC_RULE:
        pacVariable = "";
        pacSpecies = "";
        pacCompartment = "";
        pacName = "";
        pacUnits = "";
        break;
      case SBML_RATE_RULE:
        if (Rule_isSetVariable( pRule) == 1) {
          pacVariable = Rule_getVariable( pRule);
        }
        else {
          pacVariable = "";
        }
        pacSpecies = "";
        pacCompartment = "";
        pacName = "";
        pacUnits = "";
        break;
      case SBML_SPECIES_CONCENTRATION_RULE:
        if (unSBMLLevel == 1) {
          pacType = RuleType_toString(Rule_getType( pRule));
        }
        pacVariable = "";
  
        if (Rule_isSetVariable( pRule) == 1) {
          pacSpecies = Rule_getVariable( pRule);
        }
        else {
          pacSpecies = "";
        }
        pacCompartment = "";
        pacName = "";
        pacUnits = "";
        break;
      case SBML_COMPARTMENT_VOLUME_RULE:
        if (unSBMLLevel == 1) {
          pacType = RuleType_toString(Rule_getType(pRule));
        }
      pacVariable = "";
        pacSpecies = "";

        if (Rule_isSetVariable( pRule) == 1) {
          pacCompartment = Rule_getVariable( pRule);
        }
        else {
          pacCompartment = "";
        }
        pacName = "";
        pacUnits = "";
        break;
      case SBML_PARAMETER_RULE:
        if (unSBMLLevel == 1) {
          pacType = RuleType_toString(Rule_getType(pRule));
        }
        pacVariable = "";
        pacSpecies = "";
        pacCompartment = "";

        if (Rule_isSetVariable( pRule) == 1) {
          pacName = Rule_getVariable( pRule);
        }
        else {
          pacName = "";
        }
        if (Rule_isSetUnits(pRule) == 1) {
          pacUnits = Rule_getUnits( pRule);
        }
        else {
          pacUnits = "";
        }
        break;
      default:
        pacVariable = "";
        pacSpecies = "";
        pacCompartment = "";
        pacName = "";
        pacUnits = "";
        break;
    }
  }
  else
  {    
    switch(Rule_getTypeCode(pRule)) 
    {
      case SBML_ASSIGNMENT_RULE:
        if (unSBMLLevel == 1) {
          pacType = RuleType_toString(Rule_getType(pRule));
        }

        if (Rule_isSetVariable( pRule) == 1) {
          pacVariable = Rule_getVariable( pRule);
        }
        else {
          pacVariable = "";
        }
        pacSpecies = "";
        pacCompartment = "";
        pacName = "";
        pacUnits = "";
        break;
      case SBML_ALGEBRAIC_RULE:
        pacVariable = "";
        pacSpecies = "";
        pacCompartment = "";
        pacName = "";
        pacUnits = "";
        break;
      case SBML_RATE_RULE:
        if (Rule_isSetVariable( pRule) == 1) {
          pacVariable = Rule_getVariable( pRule);
        }
        else {
          pacVariable = "";
        }
        pacSpecies = "";
        pacCompartment = "";
        pacName = "";
        pacUnits = "";
        break;
      case SBML_SPECIES_CONCENTRATION_RULE:
        if (unSBMLLevel == 1) {
          pacType = RuleType_toString(Rule_getType( pRule));
        }
        pacVariable = "";
  
        if (Rule_isSetVariable( pRule) == 1) {
          pacSpecies = Rule_getVariable( pRule);
        }
        else {
          pacSpecies = "";
        }
        pacCompartment = "";
        pacName = "";
        pacUnits = "";
        break;
      case SBML_COMPARTMENT_VOLUME_RULE:
        if (unSBMLLevel == 1) {
          pacType = RuleType_toString(Rule_getType(pRule));
        }
      pacVariable = "";
        pacSpecies = "";

        if (Rule_isSetVariable( pRule) == 1) {
          pacCompartment = Rule_getVariable( pRule);
        }
        else {
          pacCompartment = "";
        }
        pacName = "";
        pacUnits = "";
        break;
      case SBML_PARAMETER_RULE:
        if (unSBMLLevel == 1) {
          pacType = RuleType_toString(Rule_getType(pRule));
        }
        pacVariable = "";
        pacSpecies = "";
        pacCompartment = "";

        if (Rule_isSetVariable( pRule) == 1) {
          pacName = Rule_getVariable( pRule);
        }
        else {
          pacName = "";
        }
        if (Rule_isSetUnits(pRule) == 1) {
          pacUnits = Rule_getUnits( pRule);
        }
        else {
          pacUnits = "";
        }
        break;
      default:
        pacVariable = "";
        pacSpecies = "";
        pacCompartment = "";
        pacName = "";
        pacUnits = "";
        break;
    }
    if (!(unSBMLLevel == 2 && unSBMLVersion == 1))
    {
      if (SBase_isSetSBOTerm((SBase_t*) pRule))
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pRule);
      }
      else
      {
        nSBO = -1;
      }
   }
  }


    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacTypecode == NULL) {
      pacTypecode = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacFormula == NULL) {
      pacFormula = "";
    }
    if (pacType == NULL) {
      pacType = "";
    }

    /* put into structure */
    mxSetField( mxListRuleReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxListRuleReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxListRuleReturn,i,"typecode",mxCreateString(pacTypecode)); 
    if (unSBMLLevel > 1)
    {
      mxSetField(mxListRuleReturn, i, "metaid", mxCreateString(pacMetaid));
    }
    mxSetField(mxListRuleReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxListRuleReturn, i, "annotation",mxCreateString(pacAnnotations));


    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }


    if (unSBMLLevel == 1){
        mxSetField(mxListRuleReturn,i,"type",mxCreateString(pacType));
    }
    else if ((unSBMLLevel == 2 && unSBMLVersion != 1) || unSBMLLevel > 2)
    {
      mxSetField(mxListRuleReturn, i, "sboTerm", CreateIntScalar(nSBO));
    }
    mxSetField(mxListRuleReturn,i,"formula",mxCreateString(pacFormula)); 
    mxSetField(mxListRuleReturn,i,"variable",mxCreateString(pacVariable)); 
    mxSetField(mxListRuleReturn,i,"species",mxCreateString(pacSpecies)); 
    mxSetField(mxListRuleReturn,i,"compartment",mxCreateString(pacCompartment)); 
    mxSetField(mxListRuleReturn,i,"name",mxCreateString(pacName)); 
    mxSetField(mxListRuleReturn,i,"units",mxCreateString(pacUnits)); 

  }
}


/**
 * NAME:    GetFunctionDefinition
 *
 * PARAMETERS:  Pointer to a model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the function definition mxArray structure
 *            populates the structure with all the function definition in
 *            the model
 */
void
GetFunctionDefinition ( Model_t      *pModel,
                        unsigned int unSBMLLevel,
                        unsigned int unSBMLVersion )
{
  int n = Model_getNumFunctionDefinitions(pModel);
  mwSize dims[2] = {1, n};

  /* fields within a species structure */
  const int nNoFields_l2 = 9;
  const char * field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
		"math",
    "level",
    "version"};
  /* fields within a species structure */
  const int nNoFields_l2v2 = 10;
  const char * field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
		"math",
    "level",
    "version"};
  const int nNoFields_l2v3 = 10;
  const char * field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id", 
		"math",
    "level",
    "version"};
  
  /* determine the values */
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacName;
  const char * pacId = NULL;
  const char * pacFormula = NULL;

  int nSBO = -1;

  FunctionDefinition_t *pFuncDefinition;
  int i;
  /* variables for mathML - matlab hack */
  int nStatus;
  size_t nBuflen;
  mxArray * mxInput[1], * mxOutput[1];


  /**
   * create the structure array 
   * n instances
   */
  if (unSBMLLevel == 1) 
  {
      mxFunctionDefReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxFunctionDefReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxFunctionDefReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxFunctionDefReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxFunctionDefReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }

  for (i = 0; i < n; i++) {
    pFuncDefinition = Model_getFunctionDefinition(pModel, i);
    
    /* determine the values */
    pacTypecode        = TypecodeToChar(SBase_getTypeCode((SBase_t *) pFuncDefinition));
    
    pacNotes            = SBase_getNotesString((SBase_t *) pFuncDefinition);
    pacAnnotations      = SBase_getAnnotationString((SBase_t *) pFuncDefinition);
    pacMetaid = SBase_getMetaId((SBase_t*)pFuncDefinition);
    
    pacName             = FunctionDefinition_getName(pFuncDefinition);
    pacId               = FunctionDefinition_getId(pFuncDefinition);
    
    if ((unSBMLLevel == 2 && unSBMLVersion > 1) || unSBMLLevel > 2)
    {
      if (SBase_isSetSBOTerm((SBase_t*) pFuncDefinition)) 
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pFuncDefinition);
      }
      else
      {
        nSBO = -1;
      }
   }
   if (FunctionDefinition_isSetMath(pFuncDefinition)) 
   {
      LookForCSymbolTime((ASTNode_t*)FunctionDefinition_getMath(pFuncDefinition));
      LookForCSymbolDelay((ASTNode_t*)FunctionDefinition_getMath(pFuncDefinition));
      LookForCSymbolAvo((ASTNode_t*)FunctionDefinition_getMath(pFuncDefinition));
      pacFormula = SBML_formulaToString((ASTNode_t*)FunctionDefinition_getMath(pFuncDefinition));
    }
  /* temporary hack to convert MathML in-fix to MATLAB compatible formula */
    
    mxInput[0] = mxCreateString(pacFormula);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");
    
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
    
    mxDestroyArray(mxInput[0]);
    mxDestroyArray(mxOutput[0]);
  /* END OF HACK */
    /**
     * check for NULL strings - Matlab doesnt like creating
     * a string that is NULL
     */
    if (pacName == NULL) {
      pacName = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }
    if (pacFormula == NULL) {
      pacFormula = "";
    }

    /* put into structure */
    mxSetField( mxFunctionDefReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxFunctionDefReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxFunctionDefReturn,i,"typecode",mxCreateString(pacTypecode)); 
    mxSetField(mxFunctionDefReturn, i, "metaid", mxCreateString(pacMetaid));
    mxSetField(mxFunctionDefReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxFunctionDefReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion != 1) || unSBMLLevel > 2)
    {
      mxSetField(mxFunctionDefReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxFunctionDefReturn,i,"name",mxCreateString(pacName)); 
    mxSetField(mxFunctionDefReturn,i,"id",mxCreateString(pacId)); 
    mxSetField(mxFunctionDefReturn,i,"math",mxCreateString(pacFormula)); 


  }
}


/**
 * NAME:    GetEvent
 *
 * PARAMETERS:  Pointer to a model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the event mxArray structure
 *            populates the structure with all the events in the model
 */
void
GetEvent (Model_t      *pModel,
          unsigned int unSBMLLevel,
          unsigned int unSBMLVersion )
{
  int n = Model_getNumEvents(pModel);
  mwSize dims[2] = {1, n};

  /* fields within a event structure */
  const int nNoFields_l2 = 12;
  const char * field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
		"trigger", 
		"delay", 
		"timeUnits", 
		"eventAssignment",
    "level",
    "version"};
  const int nNoFields_l2v2 = 13;
  const char * field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id", 
		"trigger", 
		"delay", 
		"timeUnits",
    "sboTerm",
		"eventAssignment",
    "level",
    "version"};
  const int nNoFields_l2v3 = 12;
  const char * field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
    "name", 
		"id", 
		"trigger", 
		"delay", 
		"eventAssignment",
    "level",
    "version"};
  const int nNoFields_l2v4 = 13;
  const char * field_names_l2v4[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
    "name", 
		"id",
    "useValuesFromTriggerTime",
		"trigger", 
		"delay", 
		"eventAssignment",
    "level",
    "version"};
  const int nNoFields_l3v1 = 14;
  const char * field_names_l3v1[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
    "name", 
		"id",
    "useValuesFromTriggerTime",
		"trigger", 
		"delay", 
    "priority",
		"eventAssignment",
    "level",
    "version"};
  
  /* determine the values */
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacName;
  const char * pacId = NULL;
  const char * pacTrigger = NULL;
  const char * pacDelay = NULL;
  const char * pacTimeUnits = NULL;
  int nSBO = -1;
  int nUseValuesFromTriggerTime = 0;

  Event_t *pEvent;
  int i;
  /* variables for mathML - matlab hack */
  int nStatus;
  size_t nBuflen;
  mxArray * mxInput[1], * mxOutput[1];
   
  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxEventReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxEventReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxEventReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion == 3) 
    {
      mxEventReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
    else if (unSBMLVersion == 4) 
    {
      mxEventReturn = mxCreateStructArray(2, dims, nNoFields_l2v4, field_names_l2v4);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxEventReturn = mxCreateStructArray(2, dims, nNoFields_l3v1, field_names_l3v1);
    }
  }
  for (i = 0; i < n; i++) {
    pEvent = Model_getEvent(pModel, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t *) pEvent));
    pacMetaid = SBase_getMetaId((SBase_t*)pEvent);
    
    pacNotes        = SBase_getNotesString((SBase_t *) pEvent);
    pacAnnotations  = SBase_getAnnotationString((SBase_t *) pEvent);
   
    pacName         = Event_getName(pEvent);
    pacId = Event_getId(pEvent);

    if (unSBMLLevel == 2 && unSBMLVersion < 3)
    {
      pacTimeUnits    = Event_getTimeUnits(pEvent);
    }
    if ((unSBMLLevel == 2 && unSBMLVersion > 1) || unSBMLLevel > 2)
    {
      if (SBase_isSetSBOTerm((SBase_t*) pEvent))
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pEvent);
      }
      else
      {
        nSBO = -1;
      }
    }
    if ((unSBMLLevel == 2 && unSBMLVersion ==4) || unSBMLLevel > 2)
    {
      nUseValuesFromTriggerTime = Event_getUseValuesFromTriggerTime(pEvent);
    }
    GetEventAssignment(pEvent, unSBMLLevel, unSBMLVersion);
    
    if (unSBMLLevel == 2 && unSBMLVersion < 3)
    {
      if (Event_isSetTrigger(pEvent)) 
      {
        LookForCSymbolTime((ASTNode_t*)Trigger_getMath(Event_getTrigger(pEvent)));
        LookForCSymbolDelay((ASTNode_t*)Trigger_getMath(Event_getTrigger(pEvent)));
        LookForCSymbolAvo((ASTNode_t*)Trigger_getMath(Event_getTrigger(pEvent)));
        pacTrigger = SBML_formulaToString((ASTNode_t*)Trigger_getMath(Event_getTrigger(pEvent)));
      }

      if (Event_isSetDelay(pEvent)) 
      {
        LookForCSymbolTime((ASTNode_t*)Delay_getMath(Event_getDelay(pEvent)));
        LookForCSymbolDelay((ASTNode_t*)Delay_getMath(Event_getDelay(pEvent)));
        LookForCSymbolAvo((ASTNode_t*)Delay_getMath(Event_getDelay(pEvent)));
        pacDelay      = SBML_formulaToString((ASTNode_t*)Delay_getMath(Event_getDelay(pEvent)));
      }
        /* temporary hack to convert MathML in-fix to MATLAB compatible formula */

      mxInput[0] = mxCreateString(pacTrigger);
      nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");

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

      mxDestroyArray(mxInput[0]);
      mxDestroyArray(mxOutput[0]);
      /* END OF HACK */


      if (Event_isSetDelay(pEvent)) 
      {
        /* temporary hack to convert MathML in-fix to MATLAB compatible formula */

      mxInput[0] = mxCreateString(pacDelay);
      nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");

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

      mxDestroyArray(mxInput[0]);
      mxDestroyArray(mxOutput[0]);
      /* END OF HACK */
      }
    }
    else
    {
      GetTrigger(pEvent, unSBMLLevel, unSBMLVersion);
      GetDelay(pEvent, unSBMLLevel, unSBMLVersion);
    }
    if (unSBMLLevel == 3)
    {
      GetPriority(pEvent, unSBMLLevel, unSBMLVersion);
    }
    /**        
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacName == NULL) {
      pacName = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }
    if (pacTimeUnits == NULL) {
      pacTimeUnits = "";
    }
    if (pacTrigger == NULL) {
      pacTrigger = "";
    }
    if (pacDelay == NULL) {
      pacDelay = "";
    }

    /* put into structure */
    mxSetField( mxEventReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxEventReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxEventReturn,i,"typecode",mxCreateString(pacTypecode)); 
    mxSetField(mxEventReturn, i, "metaid", mxCreateString(pacMetaid));
    mxSetField(mxEventReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxEventReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2) 
    {
      mxSetField(mxEventReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxEventReturn,i,"name",mxCreateString(pacName)); 
    mxSetField(mxEventReturn,i,"id",mxCreateString(pacId)); 
    if ((unSBMLLevel == 2 && unSBMLVersion == 4) || unSBMLLevel > 2)
    {
      mxSetField(mxEventReturn,i,"useValuesFromTriggerTime",CreateIntScalar(nUseValuesFromTriggerTime)); 
    }
    if (unSBMLLevel == 2 && unSBMLVersion < 3)
    {
      mxSetField(mxEventReturn,i,"trigger",mxCreateString(pacTrigger)); 
      mxSetField(mxEventReturn,i,"delay",mxCreateString(pacDelay)); 
    }
    else
    {
      mxSetField(mxEventReturn,i,"trigger",mxTriggerReturn); 
      mxSetField(mxEventReturn,i,"delay",mxDelayReturn); 
    }
    if (unSBMLLevel == 2 && unSBMLVersion < 3)
    {
      mxSetField(mxEventReturn,i,"timeUnits",mxCreateString(pacTimeUnits));
    }
    if (unSBMLLevel == 2 && unSBMLVersion == 2)
    {
      mxSetField(mxEventReturn,i,"sboTerm", CreateIntScalar(nSBO)); 
    }  
    mxSetField(mxEventReturn,i,"eventAssignment",mxEventAssignReturn); 

    if (unSBMLLevel == 3)
    {
      mxSetField(mxEventReturn,i,"priority",mxPriorityReturn); 
    }
    mxEventAssignReturn = NULL;
    mxTriggerReturn = NULL;
    mxDelayReturn = NULL;
    mxPriorityReturn = NULL;


  }
}


/**
 * NAME:    GetEventAssignment
 *
 * PARAMETERS:  Pointer to a event
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the event assignment mxArray structure
 *            populates the structure with all the event assignments
 *            in the event
 */
void
GetEventAssignment ( Event_t      *pEvent,
                     unsigned int unSBMLLevel,
                     unsigned int unSBMLVersion )
{
  int n = Event_getNumEventAssignments(pEvent);
  mwSize dims[2] = {1, n};

  const int nNoFields_l2 = 8;
  const char *field_names_l2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"variable", 
		"math",
    "level",
    "version"};
  const int nNoFields_l2v2 = 9;
  const char *field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"variable",
    "sboTerm",
		"math",
    "level",
    "version"};
  const int nNoFields_l2v3 = 9;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"variable",
		"math",
    "level",
    "version"};
  /* determine the values */
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacVariable;
  const char * pacFormula = NULL;
  int nSBO = -1;

  EventAssignment_t * pEventAssignment;
  int i;
  
  /* variables for mathML - matlab hack */
  int nStatus;
  size_t nBuflen;
  mxArray * mxInput[1], * mxOutput[1];
   

  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxEventAssignReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxEventAssignReturn = mxCreateStructArray(2, dims, nNoFields_l2, field_names_l2);
    }
    else if (unSBMLVersion == 2) 
    {
      mxEventAssignReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxEventAssignReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxEventAssignReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }

 for (i = 0; i < n; i++) 
 {
    pEventAssignment = Event_getEventAssignment(pEvent, i);

    /* determine the values */
    pacTypecode       = TypecodeToChar(SBase_getTypeCode((SBase_t *) pEventAssignment));
    
    pacNotes          = SBase_getNotesString((SBase_t *) pEventAssignment);
    pacAnnotations    = SBase_getAnnotationString((SBase_t *) pEventAssignment);
    pacMetaid = SBase_getMetaId((SBase_t*)pEventAssignment);
    
    pacVariable       = EventAssignment_getVariable(pEventAssignment);
    if (!(unSBMLLevel == 2 && unSBMLVersion == 1))
    {
      if (SBase_isSetSBOTerm((SBase_t*) pEventAssignment))
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pEventAssignment);
      }
      else
      {
        nSBO = -1;
      }
    }
     
     if (EventAssignment_isSetMath(pEventAssignment)) {
      LookForCSymbolTime((ASTNode_t*)EventAssignment_getMath(pEventAssignment));
      LookForCSymbolDelay((ASTNode_t*)EventAssignment_getMath(pEventAssignment));
      LookForCSymbolAvo((ASTNode_t*)EventAssignment_getMath(pEventAssignment));
      pacFormula = SBML_formulaToString((ASTNode_t*)EventAssignment_getMath(pEventAssignment));
    }
   /* temporary hack to convert MathML in-fix to MATLAB compatible formula */
  
  mxInput[0] = mxCreateString(pacFormula);
  nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");
  
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

  mxDestroyArray(mxInput[0]);
  mxDestroyArray(mxOutput[0]);
  /* END OF HACK */

    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacVariable == NULL) {
      pacVariable = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
      if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }

    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacFormula == NULL) {
      pacFormula = "";
    }

    /* put into structure */
    mxSetField( mxEventAssignReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxEventAssignReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxEventAssignReturn,i,"typecode",mxCreateString(pacTypecode)); 
    mxSetField(mxEventAssignReturn, i, "metaid", mxCreateString(pacMetaid));
    mxSetField(mxEventAssignReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxEventAssignReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
     util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
     util_free((char*)pacNotes);
    }

    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2)
    {
      mxSetField(mxEventAssignReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxEventAssignReturn,i,"variable",mxCreateString(pacVariable)); 
    if (unSBMLLevel == 2 && unSBMLVersion == 2)
    {
      mxSetField(mxEventAssignReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxEventAssignReturn,i,"math",mxCreateString(pacFormula)); 


  }

}
/**
 * NAME:    GetTrigger
 *
 * PARAMETERS:  Pointer to a event
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the trigger mxArray structure
 *            populates the structure with trigger
 *            in the event
 */
void
GetTrigger ( Event_t      *pEvent,
                     unsigned int unSBMLLevel,
                     unsigned int unSBMLVersion )
{
  int n = (Event_isSetTrigger(pEvent)) ? 1 : 0;
  mwSize dims[2] = {1, n};


  const int nNoFields_l2v3 = 8;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"math",
    "level",
    "version"};
  const int nNoFields_l3v1 = 10;
  const char *field_names_l3v1[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
    "persistent",
    "initialValue",
		"math",
    "level",
    "version"};
  /* determine the values */
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacFormula = NULL;
  int nSBO = -1;
  int nPersistent = 0;
  int nInitialValue = 0;

  Trigger_t * pTrigger;
  
  /* variables for mathML - matlab hack */
  int nStatus;
  size_t nBuflen;
  mxArray * mxInput[1], * mxOutput[1];
   

  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
    mxTriggerReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion > 2)
    {
      mxTriggerReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
    else  
    {
      mxTriggerReturn = NULL;
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxTriggerReturn = mxCreateStructArray(2, dims, nNoFields_l3v1, field_names_l3v1);
    }
  }

  if (Event_isSetTrigger(pEvent))
  {
  pTrigger = Event_getTrigger(pEvent);

  /* determine the values */
  pacTypecode       = TypecodeToChar(SBase_getTypeCode((SBase_t *) pTrigger));

  pacNotes          = SBase_getNotesString((SBase_t *) pTrigger);
  pacAnnotations    = SBase_getAnnotationString((SBase_t *) pTrigger);
    pacMetaid = SBase_getMetaId((SBase_t*)pTrigger);

  if (SBase_isSetSBOTerm((SBase_t*) pTrigger))
  {
    nSBO = SBase_getSBOTerm((SBase_t*) pTrigger);
  }
  else
  {
    nSBO = -1;
  }
    
  if (Trigger_isSetMath(pTrigger)) {
    LookForCSymbolTime((ASTNode_t*)Trigger_getMath(pTrigger));
    LookForCSymbolDelay((ASTNode_t*)Trigger_getMath(pTrigger));
    LookForCSymbolAvo((ASTNode_t*)Trigger_getMath(pTrigger));
    pacFormula = SBML_formulaToString((ASTNode_t*)Trigger_getMath(pTrigger));

     /* temporary hack to convert MathML in-fix to MATLAB compatible formula */

    mxInput[0] = mxCreateString(pacFormula);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");

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

    mxDestroyArray(mxInput[0]);
    mxDestroyArray(mxOutput[0]);
    /* END OF HACK */
  }

  if (unSBMLLevel > 2)
  {
    nPersistent = Trigger_getPersistent(pTrigger);
    nInitialValue = Trigger_getInitialValue(pTrigger);
  }
  /**
   * check for NULL strings - Matlab doesnt like creating 
   * a string that is NULL
   */
  if (pacNotes == NULL) {
    pacNotes = "";
  }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
  if (pacAnnotations == NULL) {
    pacAnnotations = "";
  }
  if (pacFormula == NULL) {
    pacFormula = "";
  }

  /* put into structure */
  mxSetField( mxTriggerReturn, 0, "level"      , CreateIntScalar(unSBMLLevel)   ); 
  mxSetField( mxTriggerReturn, 0, "version"    , CreateIntScalar(unSBMLVersion) );

  mxSetField(mxTriggerReturn, 0, "typecode",   mxCreateString(pacTypecode)); 
  mxSetField(mxTriggerReturn, 0, "metaid", mxCreateString(pacMetaid));
  mxSetField(mxTriggerReturn, 0, "notes",      mxCreateString(pacNotes));
  mxSetField(mxTriggerReturn, 0, "annotation", mxCreateString(pacAnnotations));

  if (strcmp(pacAnnotations, "") != 0)
  {
      util_free((char*)pacAnnotations);
  }
  if (strcmp(pacNotes, "") != 0)
  {
      util_free((char*)pacNotes);
  }

  mxSetField(mxTriggerReturn, 0, "sboTerm",    CreateIntScalar(nSBO));
  if (unSBMLLevel > 2)
  {
    mxSetField(mxTriggerReturn, 0, "persistent", CreateIntScalar(nPersistent));
    mxSetField(mxTriggerReturn, 0, "initialValue", CreateIntScalar(nInitialValue));
  }
  mxSetField(mxTriggerReturn, 0, "math",       mxCreateString(pacFormula)); 


  }
}


/**
 * NAME:    GetDelay
 *
 * PARAMETERS:  Pointer to a event
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the trigger mxArray structure
 *            populates the structure with trigger
 *            in the event
 */
void
GetDelay ( Event_t      *pEvent,
                     unsigned int unSBMLLevel,
                     unsigned int unSBMLVersion )
{
  int n = (Event_isSetDelay(pEvent)) ? 1 : 0;
  mwSize dims[2] = {1, n};

  const int nNoFields_l2v3 = 8;
  const char *field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"math",
    "level",
    "version"};
  /* determine the values */
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacFormula = NULL;
  int nSBO = -1;

  Delay_t * pDelay;
  
  /* variables for mathML - matlab hack */
  int nStatus;
  size_t nBuflen;
  mxArray * mxInput[1], * mxOutput[1];



  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
    mxDelayReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion > 2)
    {
      mxDelayReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
    else  
    {
      mxDelayReturn = NULL;
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxDelayReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }

  if (Event_isSetDelay(pEvent))
  {
    pDelay = Event_getDelay(pEvent);

    /* determine the values */
    pacTypecode       = TypecodeToChar(SBase_getTypeCode((SBase_t *) pDelay));

    pacNotes          = SBase_getNotesString((SBase_t *) pDelay);
    pacAnnotations    = SBase_getAnnotationString((SBase_t *) pDelay);
    pacMetaid = SBase_getMetaId((SBase_t*)pDelay);

    if (SBase_isSetSBOTerm((SBase_t*) pDelay))
    {
      nSBO = SBase_getSBOTerm((SBase_t*) pDelay);
    }
    else
    {
      nSBO = -1;
    }
      
    if (Delay_isSetMath(pDelay)) 
    {
      LookForCSymbolTime((ASTNode_t*)Delay_getMath(pDelay));
      LookForCSymbolDelay((ASTNode_t*)Delay_getMath(pDelay));
      LookForCSymbolAvo((ASTNode_t*)Delay_getMath(pDelay));
      pacFormula = SBML_formulaToString((ASTNode_t*)Delay_getMath(pDelay));

       /* temporary hack to convert MathML in-fix to MATLAB compatible formula */

      mxInput[0] = mxCreateString(pacFormula);
      nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");

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

      mxDestroyArray(mxInput[0]);
      mxDestroyArray(mxOutput[0]);
      /* END OF HACK */
    }
    /**
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacNotes == NULL) {
      pacNotes = "";
    }
      if (pacMetaid == NULL)
      {
        pacMetaid = "";
      }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacFormula == NULL) {
      pacFormula = "";
    }

    /* put into structure */
    mxSetField( mxDelayReturn, 0, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxDelayReturn, 0, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxDelayReturn, 0, "typecode",   mxCreateString(pacTypecode)); 
    mxSetField(mxDelayReturn, 0, "metaid", mxCreateString(pacMetaid));
    mxSetField(mxDelayReturn, 0, "notes",      mxCreateString(pacNotes));
    mxSetField(mxDelayReturn, 0, "annotation", mxCreateString(pacAnnotations));


    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    mxSetField(mxDelayReturn, 0, "sboTerm",    CreateIntScalar(nSBO)); 
    mxSetField(mxDelayReturn, 0, "math",       mxCreateString(pacFormula)); 


  }
}


/**
 * NAME:    GetPriority
 *
 * PARAMETERS:  Pointer to a event
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the trigger mxArray structure
 *            populates the structure with trigger
 *            in the event
 */
void
GetPriority ( Event_t      *pEvent,
                     unsigned int unSBMLLevel,
                     unsigned int unSBMLVersion )
{
  int n = (Event_isSetPriority(pEvent)) ? 1 : 0;
  mwSize dims[2] = {1, n};


  const int nNoFields_l3v1 = 8;
  const char *field_names_l3v1[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"math",
    "level",
    "version"};
  /* determine the values */
  const char * pacTypecode;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacFormula = NULL;
  int nSBO = -1;

  Priority_t * pPriority;
  
  /* variables for mathML - matlab hack */
  int nStatus;
  size_t nBuflen;
  mxArray * mxInput[1], * mxOutput[1];
   

  /* create the structure array */
  if (unSBMLLevel < 3) 
  {
    mxPriorityReturn = NULL;
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxPriorityReturn = mxCreateStructArray(2, dims, nNoFields_l3v1, field_names_l3v1);
    }
  }

  if (Event_isSetPriority(pEvent))
  {
  pPriority = Event_getPriority(pEvent);

  /* determine the values */
  pacTypecode       = TypecodeToChar(SBase_getTypeCode((SBase_t *) pPriority));

  pacNotes          = SBase_getNotesString((SBase_t *) pPriority);
  pacAnnotations    = SBase_getAnnotationString((SBase_t *) pPriority);
  pacMetaid = SBase_getMetaId((SBase_t*)pPriority);

  if (SBase_isSetSBOTerm((SBase_t*) pPriority))
  {
    nSBO = SBase_getSBOTerm((SBase_t*) pPriority);
  }
  else
  {
    nSBO = -1;
  }
    
  if (Priority_isSetMath(pPriority)) 
  {
    LookForCSymbolTime((ASTNode_t*)Priority_getMath(pPriority));
    LookForCSymbolDelay((ASTNode_t*)Priority_getMath(pPriority));
    LookForCSymbolAvo((ASTNode_t*)Priority_getMath(pPriority));
    pacFormula = SBML_formulaToString((ASTNode_t*)Priority_getMath(pPriority));

    /* temporary hack to convert MathML in-fix to MATLAB compatible formula */

    mxInput[0] = mxCreateString(pacFormula);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");

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

    mxDestroyArray(mxInput[0]);
    mxDestroyArray(mxOutput[0]);
    /* END OF HACK */
  }
  /**
  * check for NULL strings - Matlab doesnt like creating 
  * a string that is NULL
  */
  if (pacNotes == NULL) {
    pacNotes = "";
  }
  if (pacMetaid == NULL)
  {
    pacMetaid = "";
  }
  if (pacAnnotations == NULL) {
    pacAnnotations = "";
  }
  if (pacFormula == NULL) {
    pacFormula = "";
  }

  /* put into structure */
  mxSetField( mxPriorityReturn, 0, "level"      , CreateIntScalar(unSBMLLevel)   ); 
  mxSetField( mxPriorityReturn, 0, "version"    , CreateIntScalar(unSBMLVersion) );

  mxSetField(mxPriorityReturn, 0, "typecode",   mxCreateString(pacTypecode)); 
  mxSetField(mxPriorityReturn, 0, "metaid", mxCreateString(pacMetaid));
  mxSetField(mxPriorityReturn, 0, "notes",      mxCreateString(pacNotes));
  mxSetField(mxPriorityReturn, 0, "annotation", mxCreateString(pacAnnotations));

  if (strcmp(pacAnnotations, "") != 0)
  {
      util_free((char*)pacAnnotations);
  }
  if (strcmp(pacNotes, "") != 0)
  {
      util_free((char*)pacNotes);
  }

  mxSetField(mxPriorityReturn, 0, "sboTerm",    CreateIntScalar(nSBO));
  mxSetField(mxPriorityReturn, 0, "math",       mxCreateString(pacFormula)); 


  }
}


void
LookForCSymbolTime(ASTNode_t * astMath)
{
  unsigned int nChild, i;
  ASTNode_t * astChild;
  ASTNodeType_t type;

  nChild = ASTNode_getNumChildren(astMath);

  if (nChild == 0)
  {
    type = ASTNode_getType(astMath);
    if (type == AST_NAME_TIME)
    {
      /* csymbol time found -if it has already been found
        * replace the name in this instance
        */
      if (pacCSymbolTime == NULL) {
        pacCSymbolTime = (const char *) ASTNode_getName(astMath);
      }
      else {
        ASTNode_setName(astMath, pacCSymbolTime);
      }
    }
  }
  
  for (i = 0; i < nChild; i++)
  {
    astChild = ASTNode_getChild(astMath, i);
    if (ASTNode_getNumChildren(astChild) > 0)
    {
      LookForCSymbolTime(astChild);
    }
    else
    {
      type = ASTNode_getType(astChild);
      if (type == AST_NAME_TIME)
      {
        /* csymbol time found -if it has already been found
         * replace the name in this instance
         */
        if (pacCSymbolTime == NULL) {
          pacCSymbolTime = (const char *) ASTNode_getName(astChild);
        }
        else {
          ASTNode_setName(astChild, pacCSymbolTime);
        }
      }
    }
  }
}
void
LookForCSymbolDelay(ASTNode_t * astMath)
{
  unsigned int nChild, i;
  ASTNode_t * astChild;
  ASTNodeType_t type;

  nChild = ASTNode_getNumChildren(astMath);

  if (nChild == 0)
    return;

  type = ASTNode_getType(astMath);
  if (type == AST_FUNCTION_DELAY)
  {
    /* csymbol delay found -if it has already been found
      * replace the name in this instance
      */
    if (pacCSymbolDelay == NULL) {
      pacCSymbolDelay = (const char *) ASTNode_getName(astMath);
    }
    else {
      ASTNode_setName(astMath, pacCSymbolDelay);
    }
  }

  for (i = 0; i < nChild; i++)
  {
    astChild = ASTNode_getChild(astMath, i);
    LookForCSymbolDelay(astChild);
  }
}
void
LookForCSymbolAvo(ASTNode_t * astMath)
{
  unsigned int nChild, i;
  ASTNode_t * astChild;
  ASTNodeType_t type;

  nChild = ASTNode_getNumChildren(astMath);

  if (nChild == 0)
  {
    type = ASTNode_getType(astMath);
    if (type == AST_NAME_AVOGADRO)
    {
      /* csymbol time found -if it has already been found
        * replace the name in this instance
        */
      if (pacCSymbolAvo == NULL) {
        pacCSymbolAvo = (const char *) ASTNode_getName(astMath);
      }
      else {
        ASTNode_setName(astMath, pacCSymbolAvo);
      }
    }
  }
  
  for (i = 0; i < nChild; i++)
  {
    astChild = ASTNode_getChild(astMath, i);
    if (ASTNode_getNumChildren(astChild) > 0)
    {
      LookForCSymbolAvo(astChild);
    }
    else
    {
      type = ASTNode_getType(astChild);
      if (type == AST_NAME_AVOGADRO)
      {
        /* csymbol time found -if it has already been found
         * replace the name in this instance
         */
        if (pacCSymbolAvo == NULL) {
          pacCSymbolAvo = (const char *) ASTNode_getName(astChild);
        }
        else {
          ASTNode_setName(astChild, pacCSymbolAvo);
        }
      }
    }
  }
}


const char *
RuleType_toString (RuleType_t typecode)
{
  const char * pacTypecode;

  switch (typecode)
  {
    case RULE_TYPE_RATE:
      pacTypecode = "rate";
    break;

    case RULE_TYPE_SCALAR:
      pacTypecode = "scalar";
    break;

    default:
      pacTypecode = "ERROR";
    break;
  }

  return pacTypecode;
}
/**
 * NAME:    GetCompartmentType
 *
 * PARAMETERS:  Pointer to a model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the event mxArray structure
 *            populates the structure with all the events in the model
 */
void
GetCompartmentType (Model_t      *pModel,
                    unsigned int unSBMLLevel,
                    unsigned int unSBMLVersion )
{
  int n = Model_getNumCompartmentTypes(pModel);
  mwSize dims[2] = {1, n};

  /* fields within a compartmentType structure */
  const int nNoFields_l2v2 = 8;
  const char * field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id",
    "level",
    "version"};
  const int nNoFields_l2v3 = 9;
  const char * field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id",
    "level",
    "version"};
  
  /* determine the values */
  const char * pacTypecode = NULL;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacName = NULL;
  const char * pacId = NULL;
  int nSBO = -1;

  CompartmentType_t *pCompartmentType;
  int i;
   
  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxCompartmentTypeReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxCompartmentTypeReturn = NULL;
    }
    else if (unSBMLVersion == 2) 
    {
      mxCompartmentTypeReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxCompartmentTypeReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }

  for (i = 0; i < n; i++) 
  {
    pCompartmentType = Model_getCompartmentType(pModel, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t *) pCompartmentType));
    
    pacNotes        = SBase_getNotesString((SBase_t *) pCompartmentType);
    pacAnnotations  = SBase_getAnnotationString((SBase_t *) pCompartmentType);
    pacMetaid = SBase_getMetaId((SBase_t*)pCompartmentType);
    
    pacName         = CompartmentType_getName(pCompartmentType);
    pacId = CompartmentType_getId(pCompartmentType);
    switch (unSBMLVersion)
    {
    case 1:
      break;
    case 2:
      break;
    case 3:
    case 4:
      if (SBase_isSetSBOTerm((SBase_t*) pCompartmentType)) 
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pCompartmentType);
      }
      else
      {
        nSBO = -1;
      }
      break;
    default:
      break;
    }

    /**        
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacName == NULL) {
      pacName = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }

    /* put into structure */
    mxSetField( mxCompartmentTypeReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxCompartmentTypeReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxCompartmentTypeReturn,i,"typecode",mxCreateString(pacTypecode)); 
    mxSetField(mxCompartmentTypeReturn, i, "metaid", mxCreateString(pacMetaid));
    mxSetField(mxCompartmentTypeReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxCompartmentTypeReturn, i, "annotation",mxCreateString(pacAnnotations));


    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if (unSBMLLevel == 2 && unSBMLVersion > 2) 
    {
      mxSetField(mxCompartmentTypeReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxCompartmentTypeReturn,i,"name",mxCreateString(pacName)); 
    mxSetField(mxCompartmentTypeReturn,i,"id",mxCreateString(pacId)); 


  }
}

/**
 * NAME:    GetSpeciesType
 *
 * PARAMETERS:  Pointer to a model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the event mxArray structure
 *            populates the structure with all the events in the model
 */
void
GetSpeciesType (Model_t      *pModel,
                    unsigned int unSBMLLevel,
                    unsigned int unSBMLVersion )
{
  int n = Model_getNumSpeciesTypes(pModel);
  mwSize dims[2] = {1, n};

  /* fields within a SpeciesType structure */
  const int nNoFields_l2v2 = 8;
  const char * field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"name", 
		"id",
    "level",
    "version"};
  const int nNoFields_l2v3 = 9;
  const char * field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"name", 
		"id",
    "level",
    "version"};
  
  /* determine the values */
  const char * pacTypecode = NULL;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacName = NULL;
  const char * pacId = NULL;
  int nSBO = -1;

  SpeciesType_t *pSpeciesType;
  int i;
   
  /* create the structure array */
  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxSpeciesTypeReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxSpeciesTypeReturn = NULL;
    }
    else if (unSBMLVersion == 2) 
    {
      mxSpeciesTypeReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxSpeciesTypeReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }

  for (i = 0; i < n; i++) 
  {
    pSpeciesType = Model_getSpeciesType(pModel, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t *) pSpeciesType));
    
    pacNotes        = SBase_getNotesString((SBase_t *) pSpeciesType);
    pacAnnotations  = SBase_getAnnotationString((SBase_t *) pSpeciesType);
    pacMetaid = SBase_getMetaId((SBase_t*)pSpeciesType);
    
    pacName         = SpeciesType_getName(pSpeciesType);
    pacId = SpeciesType_getId(pSpeciesType);
    switch (unSBMLVersion)
    {
    case 1:
      break;
    case 2:
      break;
    case 3:
    case 4:
      if (SBase_isSetSBOTerm((SBase_t*) pSpeciesType)) 
      {
        nSBO = SBase_getSBOTerm((SBase_t*) pSpeciesType);
      }
      else
      {
        nSBO = -1;
      }
      break;
    default:
      break;
    }

    /**        
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacName == NULL) {
      pacName = "";
    }
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }

    /* put into structure */
    mxSetField( mxSpeciesTypeReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxSpeciesTypeReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxSpeciesTypeReturn,i,"typecode",mxCreateString(pacTypecode)); 
    mxSetField(mxSpeciesTypeReturn, i, "metaid", mxCreateString(pacMetaid));
    mxSetField(mxSpeciesTypeReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxSpeciesTypeReturn, i, "annotation",mxCreateString(pacAnnotations));


    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    if (unSBMLLevel == 2 && unSBMLVersion > 2) 
    {
      mxSetField(mxSpeciesTypeReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxSpeciesTypeReturn,i,"name",mxCreateString(pacName)); 
    mxSetField(mxSpeciesTypeReturn,i,"id",mxCreateString(pacId)); 


  }
}

/**
 * NAME:    GetInitialAssignment
 *
 * PARAMETERS:  Pointer to a model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the InitialAssignment mxArray structure
 *            populates the structure with all the InitialAssignments in the model
 */
void
GetInitialAssignment (Model_t      *pModel,
          unsigned int unSBMLLevel,
          unsigned int unSBMLVersion )
{
  int n = Model_getNumInitialAssignments(pModel);
  mwSize dims[2] = {1, n};

  /* fields within a InitialAssignment structure */
  const int nNoFields_l2v2 = 9;
  const char * field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
		"symbol",
    "sboTerm",
		"math",
    "level",
    "version"};
  const int nNoFields_l2v3 = 9;
  const char * field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"symbol",
		"math",
    "level",
    "version"};
  
  /* determine the values */
  const char * pacTypecode = NULL;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacSymbol = NULL;
  int nSBO = -1;
  const char * pacMath = NULL;

  InitialAssignment_t *pInitialAssignment;
  int i;
  /* variables for mathML - matlab hack */
  int nStatus;
  size_t nBuflen;
  mxArray * mxInput[1], * mxOutput[1];
   
  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxInitialAssignReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxInitialAssignReturn = NULL;
    }
    else if (unSBMLVersion == 2) 
    {
      mxInitialAssignReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxInitialAssignReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxInitialAssignReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }

  for (i = 0; i < n; i++) {
    pInitialAssignment = Model_getInitialAssignment(pModel, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t *) pInitialAssignment));
    
    pacNotes        = SBase_getNotesString((SBase_t *) pInitialAssignment);
    pacAnnotations  = SBase_getAnnotationString((SBase_t *) pInitialAssignment);
    pacMetaid = SBase_getMetaId((SBase_t*)pInitialAssignment);
  
    pacSymbol       = InitialAssignment_getSymbol(pInitialAssignment);
    if (SBase_isSetSBOTerm((SBase_t*) pInitialAssignment)){
      nSBO = SBase_getSBOTerm((SBase_t*) pInitialAssignment);
    }
    else
    {
      nSBO = -1;
    }

    if (InitialAssignment_isSetMath(pInitialAssignment) == 1) {
      LookForCSymbolTime((ASTNode_t*)InitialAssignment_getMath(pInitialAssignment));
      LookForCSymbolDelay((ASTNode_t*)InitialAssignment_getMath(pInitialAssignment));
      LookForCSymbolAvo((ASTNode_t*)InitialAssignment_getMath(pInitialAssignment));
      pacMath = SBML_formulaToString((ASTNode_t*)InitialAssignment_getMath(pInitialAssignment));
    }

    /* temporary hack to convert MathML in-fix to MATLAB compatible formula */

    mxInput[0] = mxCreateString(pacMath);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");

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

    mxDestroyArray(mxInput[0]);
    mxDestroyArray(mxOutput[0]);
    /* END OF HACK */



    /**        
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacSymbol == NULL) {
      pacSymbol = "";
    }
    if (pacMath == NULL) {
      pacMath = "";
    }

    /* put into structure */
    mxSetField( mxInitialAssignReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxInitialAssignReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxInitialAssignReturn, i, "typecode",   mxCreateString(pacTypecode)); 
    mxSetField(mxInitialAssignReturn, i, "metaid", mxCreateString(pacMetaid));
    mxSetField(mxInitialAssignReturn, i, "notes",      mxCreateString(pacNotes));
    mxSetField(mxInitialAssignReturn, i, "annotation", mxCreateString(pacAnnotations));


    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }


    if ((unSBMLLevel == 2 && unSBMLVersion > 2) || unSBMLLevel > 2) 
    {
      mxSetField(mxInitialAssignReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    }
    mxSetField(mxInitialAssignReturn, i, "symbol",     mxCreateString(pacSymbol)); 
    if (unSBMLVersion == 2)
    {
      mxSetField(mxInitialAssignReturn, i, "sboTerm",    CreateIntScalar(nSBO)); 
    }
    mxSetField(mxInitialAssignReturn, i, "math",       mxCreateString(pacMath)); 


  }
}

/**
 * NAME:    GetConstraint
 *
 * PARAMETERS:  Pointer to a model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the Constraint mxArray structure
 *            populates the structure with all the Constraint in the model
 */
void
GetConstraint (Model_t      *pModel,
          unsigned int unSBMLLevel,
          unsigned int unSBMLVersion )
{
  int n = Model_getNumConstraints(pModel);
  mwSize dims[2] = {1, n};

  /* fields within a Constraint structure */
  const int nNoFields_l2v2 = 9;
  const char * field_names_l2v2[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"math",
    "message",
    "level",
    "version"};
  
  const int nNoFields_l2v3 = 9;
  const char * field_names_l2v3[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
		"math",
    "message",
    "level",
    "version"};
  
  /* determine the values */
  const char * pacTypecode = NULL;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacMessage = NULL;
  int nSBO = -1;
  const char * pacMath = NULL;

  Constraint_t *pConstraint;
  int i;
  /* variables for mathML - matlab hack */
  int nStatus;
  size_t nBuflen;
  mxArray * mxInput[1], * mxOutput[1];
   
  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxConstraintReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    if (unSBMLVersion == 1)
    {
      mxConstraintReturn = NULL;
    }
    else if (unSBMLVersion == 2) 
    {
      mxConstraintReturn = mxCreateStructArray(2, dims, nNoFields_l2v2, field_names_l2v2);
    }
    else if (unSBMLVersion > 2) 
    {
      mxConstraintReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxConstraintReturn = mxCreateStructArray(2, dims, nNoFields_l2v3, field_names_l2v3);
    }
  }

  for (i = 0; i < n; i++) {
    pConstraint = Model_getConstraint(pModel, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t *) pConstraint));
  
    pacNotes        = SBase_getNotesString((SBase_t *) pConstraint);
    pacAnnotations  = SBase_getAnnotationString((SBase_t *) pConstraint);
    pacMetaid = SBase_getMetaId((SBase_t*)pConstraint);

    if (Constraint_isSetMessage(pConstraint)) {
      pacMessage = XMLNode_convertXMLNodeToString(Constraint_getMessage(pConstraint));
    }

    if (SBase_isSetSBOTerm((SBase_t*) pConstraint)) {
      nSBO = SBase_getSBOTerm((SBase_t*) pConstraint);
    }
    else
    {
      nSBO = -1;
    }

    if (Constraint_isSetMath(pConstraint)) {
      LookForCSymbolTime((ASTNode_t*)Constraint_getMath(pConstraint));
      LookForCSymbolDelay((ASTNode_t*)Constraint_getMath(pConstraint));
      LookForCSymbolAvo((ASTNode_t*)Constraint_getMath(pConstraint));
      pacMath = SBML_formulaToString((ASTNode_t*)Constraint_getMath(pConstraint));
    }
    
    /* temporary hack to convert MathML in-fix to MATLAB compatible formula */

    mxInput[0] = mxCreateString(pacMath);
    nStatus = mexCallMATLAB(1, mxOutput, 1, mxInput, "CheckAndConvert");

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
    mxDestroyArray(mxInput[0]);
    mxDestroyArray(mxOutput[0]);

    /* END OF HACK */



    /**        
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacMessage == NULL) {
      pacMessage = "";
    }
    if (pacMath == NULL) {
      pacMath = "";
    }

    /* put into structure */
    mxSetField( mxConstraintReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxConstraintReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );

    mxSetField(mxConstraintReturn,i,"typecode",mxCreateString(pacTypecode)); 
    mxSetField(mxConstraintReturn, i, "metaid", mxCreateString(pacMetaid));
    mxSetField(mxConstraintReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxConstraintReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    mxSetField(mxConstraintReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    mxSetField(mxConstraintReturn,i,"math",mxCreateString(pacMath)); 
    mxSetField(mxConstraintReturn,i,"message",mxCreateString(pacMessage)); 


  }
}

#ifdef USE_FBC

/**
 * NAME:    GetFluxBound
 *
 * PARAMETERS:  Pointer to a Model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the FluxBound mxArray structure
 *            populates the structure with all the FluxBound in the Model
 */
void
GetFluxBound (Model_t      *pModel,
          unsigned int unSBMLLevel,
          unsigned int unSBMLVersion )
{
  SBasePlugin_t *plugin =  SBase_getPlugin((SBase_t *)(pModel), "fbc");
  int n = FbcModelPlugin_getNumFluxBounds(plugin);
  mwSize dims[2] = {1, n};

  /* fields within a FluxBound structure */
  const int nNoFields_l3v1_fbc = 13;
  const char * field_names_l3v1_fbc[] = {	
    "typecode", 
    "metaid",
    "notes", 
		"annotation",
    "sboTerm",
    "fbc_id",
    "fbc_reaction",
    "fbc_operation",
    "fbc_value",
    "isSetfbc_value",
    "level",
    "version",
    "fbc_version"};
  
  /* determine the values */
  const char * pacTypecode = NULL;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacId = NULL;
  int nSBO = -1;
  const char * pacReaction = NULL;
  const char * pacOperation = NULL;
  double dValue;
  unsigned int unIsSetValue = 0;
  double dZero = 0.0;

  unsigned int unFBCVersion;

  FluxBound_t *pFluxBound;
  int i;
  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxFluxBoundReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    mxFluxBoundReturn = NULL;
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxFluxBoundReturn = 
        mxCreateStructArray(2, dims, nNoFields_l3v1_fbc, field_names_l3v1_fbc);
    }
  }

  for (i = 0; i < n; i++) {
    pFluxBound = FbcModelPlugin_getFluxBound(plugin, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t *) pFluxBound));
  
    pacNotes        = SBase_getNotesString((SBase_t *) pFluxBound);
    pacAnnotations  = SBase_getAnnotationString((SBase_t *) pFluxBound);
    pacMetaid = SBase_getMetaId((SBase_t*)pFluxBound);

    pacId           = FluxBound_getId(pFluxBound);
    pacReaction     = FluxBound_getReaction(pFluxBound);
    pacOperation    = FluxBound_getOperation(pFluxBound);
    dValue          = FluxBound_getValue(pFluxBound);
    unIsSetValue    = FluxBound_isSetValue(pFluxBound);

    unFBCVersion = SBasePlugin_getPackageVersion(plugin);



    /**        
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }
    if (pacReaction == NULL) {
      pacReaction = "";
    }
    if (pacOperation == NULL) {
      pacOperation = "";
    }

    /* record any unset values as NAN */
    if (unIsSetValue == 0) {
        dValue = 0.0/dZero;
    }

    /* put into structure */
    mxSetField( mxFluxBoundReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxFluxBoundReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );
    mxSetField( mxFluxBoundReturn, i, "fbc_version"    , CreateIntScalar(unFBCVersion) );

    mxSetField(mxFluxBoundReturn,i,"typecode",mxCreateString(pacTypecode)); 
    mxSetField(mxFluxBoundReturn, i, "metaid", mxCreateString(pacMetaid));
    mxSetField(mxFluxBoundReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxFluxBoundReturn, i, "annotation",mxCreateString(pacAnnotations));


    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    mxSetField(mxFluxBoundReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    mxSetField(mxFluxBoundReturn,i,"fbc_id",mxCreateString(pacId)); 
    mxSetField(mxFluxBoundReturn,i,"fbc_reaction",mxCreateString(pacReaction)); 
    mxSetField(mxFluxBoundReturn,i,"fbc_operation",mxCreateString(pacOperation)); 
    mxSetField(mxFluxBoundReturn,i,"fbc_value",mxCreateDoubleScalar(dValue)); 
    mxSetField(mxFluxBoundReturn,i,"isSetfbc_value",CreateIntScalar(unIsSetValue)); 



  }
}


/**
 * NAME:    GetObjective
 *
 * PARAMETERS:  Pointer to a Model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the Objective mxArray structure
 *            populates the structure with all the Objective in the Model
 */
void
GetObjective (Model_t      *pModel,
          unsigned int unSBMLLevel,
          unsigned int unSBMLVersion )
{
  SBasePlugin_t *plugin =  SBase_getPlugin((SBase_t *)(pModel), "fbc");
  int n = FbcModelPlugin_getNumObjectives(plugin);
  mwSize dims[2] = {1, n};

  /* fields within a Objective structure */
  const int nNoFields_l3v1_fbc = 11;
  const char * field_names_l3v1_fbc[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
    "fbc_id",
    "fbc_type",
    "fbc_fluxObjective",
    "level",
    "version",
    "fbc_version"};
  
  /* determine the values */
  const char * pacTypecode = NULL;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  const char * pacId = NULL;
  int nSBO = -1;
  const char * pacType = NULL;

  unsigned int unFBCVersion;

  Objective_t *pObjective;
  int i;
  
  /* get the activeObjective */
  pacActiveObj = FbcModelPlugin_getActiveObjectiveId(plugin);

  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxObjectiveReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    mxObjectiveReturn = NULL;
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxObjectiveReturn = 
        mxCreateStructArray(2, dims, nNoFields_l3v1_fbc, field_names_l3v1_fbc);
    }
  }

  for (i = 0; i < n; i++) {
    pObjective = FbcModelPlugin_getObjective(plugin, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t *) pObjective));
  
    pacNotes        = SBase_getNotesString((SBase_t *) pObjective);
    pacAnnotations  = SBase_getAnnotationString((SBase_t *) pObjective);
    pacMetaid = SBase_getMetaId((SBase_t*)pObjective);

    pacId           = Objective_getId(pObjective);
    pacType         = Objective_getType(pObjective);

    unFBCVersion = SBasePlugin_getPackageVersion(plugin);

    GetFluxObjective(pObjective, unSBMLLevel, unSBMLVersion, unFBCVersion);

    /**        
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacId == NULL) {
      pacId = "";
    }
    if (pacType == NULL) {
      pacType = "";
    }

    /* put into structure */
    mxSetField( mxObjectiveReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxObjectiveReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );
    mxSetField( mxObjectiveReturn, i, "fbc_version"    , CreateIntScalar(unFBCVersion) );

    mxSetField(mxObjectiveReturn,i,"typecode",mxCreateString(pacTypecode)); 
    mxSetField(mxObjectiveReturn, i, "metaid", mxCreateString(pacMetaid));
    mxSetField(mxObjectiveReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxObjectiveReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
      pacAnnotations = NULL;
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
      pacNotes = NULL;
    }

    mxSetField(mxObjectiveReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    mxSetField(mxObjectiveReturn,i,"fbc_id",mxCreateString(pacId)); 
    mxSetField(mxObjectiveReturn,i,"fbc_type",mxCreateString(pacType)); 
    mxSetField(mxObjectiveReturn,i,"fbc_fluxObjective",mxFluxObjectiveReturn); 

    mxFluxObjectiveReturn = NULL;
  }
}


/**
 * NAME:    GetObjective
 *
 * PARAMETERS:  Pointer to a Model
 *              unSBMLLevel
 *              unSBMLVersion - included for possible expansion needs
 *
 * RETURNS:    void
 *
 * FUNCTION:  creates the Objective mxArray structure
 *            populates the structure with all the Objective in the Model
 */
void
GetFluxObjective (Objective_t      *pObjective,
          unsigned int unSBMLLevel,
          unsigned int unSBMLVersion,
          unsigned int unFBCVersion)
{
  int n = Objective_getNumFluxObjectives(pObjective);
  mwSize dims[2] = {1, n};

  /* fields within a structure */
  const int nNoFields_l3v1_fbc = 11;
 const char * field_names_l3v1_fbc[] = {	
    "typecode", 
    "metaid",
		"notes", 
		"annotation",
    "sboTerm",
    "fbc_reaction",
    "fbc_coefficient",
    "isSetfbc_coefficient",
    "level",
    "version",
    "fbc_version"};
  
  /* determine the values */
  const char * pacTypecode = NULL;
  const char * pacMetaid = NULL;
  const char * pacNotes = NULL;
  const char * pacAnnotations = NULL;
  int nSBO = -1;
  const char * pacReaction = NULL;
  double dCoefficient = 0.0;
  unsigned int unIsSetCoefficient = 0;
  double dZero = 0.0;


  FluxObjective_t *pFluxObjective;
  int i;
  /* create the structure array */
  if (unSBMLLevel == 1) 
  {
      mxObjectiveReturn = NULL;
  }
  else if (unSBMLLevel == 2) 
  {
    mxObjectiveReturn = NULL;
  }
  else if (unSBMLLevel == 3) 
  {
    if (unSBMLVersion == 1)
    {
      mxFluxObjectiveReturn = 
        mxCreateStructArray(2, dims, nNoFields_l3v1_fbc, field_names_l3v1_fbc);
    }
  }

  for (i = 0; i < n; i++) {
    pFluxObjective = Objective_getFluxObjective(pObjective, i);

    /* determine the values */
    pacTypecode     = TypecodeToChar(SBase_getTypeCode((SBase_t *) pFluxObjective));
  
    pacNotes        = SBase_getNotesString((SBase_t *) pFluxObjective);
    pacAnnotations  = SBase_getAnnotationString((SBase_t *) pFluxObjective);
    pacMetaid = SBase_getMetaId((SBase_t*)pFluxObjective);

    pacReaction        = FluxObjective_getReaction(pFluxObjective);
    dCoefficient       = FluxObjective_getCoefficient(pFluxObjective);
    unIsSetCoefficient = FluxObjective_isSetCoefficient(pFluxObjective);


    /**        
     * check for NULL strings - Matlab doesnt like creating 
     * a string that is NULL
     */
    if (pacNotes == NULL) {
      pacNotes = "";
    }
    if (pacMetaid == NULL)
    {
      pacMetaid = "";
    }
    if (pacAnnotations == NULL) {
      pacAnnotations = "";
    }
    if (pacReaction == NULL) {
      pacReaction = "";
    }

    /* record any unset values as NAN */
    if (unIsSetCoefficient == 0) {
        dCoefficient = 0.0/dZero;
    }


    /* put into structure */
    mxSetField( mxFluxObjectiveReturn, i, "level"      , CreateIntScalar(unSBMLLevel)   ); 
    mxSetField( mxFluxObjectiveReturn, i, "version"    , CreateIntScalar(unSBMLVersion) );
    mxSetField( mxFluxObjectiveReturn, i, "fbc_version"    , CreateIntScalar(unFBCVersion) );

    mxSetField(mxFluxObjectiveReturn,i,"typecode",mxCreateString(pacTypecode)); 
    mxSetField(mxFluxObjectiveReturn, i, "metaid", mxCreateString(pacMetaid));
    mxSetField(mxFluxObjectiveReturn, i, "notes",mxCreateString(pacNotes));
    mxSetField(mxFluxObjectiveReturn, i, "annotation",mxCreateString(pacAnnotations));

    if (strcmp(pacAnnotations, "") != 0)
    {
      util_free((char*)pacAnnotations);
    }
    if (strcmp(pacNotes, "") != 0)
    {
      util_free((char*)pacNotes);
    }

    mxSetField(mxFluxObjectiveReturn,i,"sboTerm",CreateIntScalar(nSBO)); 
    mxSetField(mxFluxObjectiveReturn,i,"fbc_reaction",mxCreateString(pacReaction)); 
    mxSetField(mxFluxObjectiveReturn,i,"fbc_coefficient",mxCreateDoubleScalar(dCoefficient)); 
    mxSetField(mxFluxObjectiveReturn,i,"isSetfbc_coefficient",CreateIntScalar(unIsSetCoefficient)); 

  

  }
}

#endif 
