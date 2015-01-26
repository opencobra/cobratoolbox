/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    SBMLExternalValidator.cpp
 * @brief   Implementation of SBMLExternalValidator, a validator calling external programs
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
 * ------------------------------------------------------------------------ -->
 */

#include <sbml/validator/SBMLExternalValidator.h>

#ifdef __cplusplus

#include <algorithm>
#include <string>
#include <vector>
#include <map>
#include <sstream>

#include <sbml/common/sbmlfwd.h>
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLNode.h>
#include <sbml/SBMLError.h>
#include <sbml/SBMLWriter.h>

#if defined (WIN32) && !defined (CYGWIN)

#define WIN32_LEAN_AND_MEAN
#include <Windows.h>

#else

#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#endif

using namespace std;
LIBSBML_CPP_NAMESPACE_BEGIN


SBMLExternalValidator::SBMLExternalValidator() : SBMLValidator()
{

}


SBMLExternalValidator::SBMLExternalValidator(const SBMLExternalValidator& orig) :
SBMLValidator(orig)
  , mProgram(orig.mProgram)
  , mArguments(orig.mArguments)
  , mSBMLFileName(orig.mSBMLFileName)
  , mOutputFileName(orig.mOutputFileName)
{
}

SBMLValidator* 
SBMLExternalValidator::clone() const
{
  return new SBMLExternalValidator(*this);
}

/*
 * Destroy this object.
 */
SBMLExternalValidator::~SBMLExternalValidator ()
{

}


const std::string& 
SBMLExternalValidator::getProgram()  const
{
  return mProgram;
}

void 
SBMLExternalValidator::setProgram (std::string program)
{
  mProgram = program;
}

const std::string& 
SBMLExternalValidator::getOutputFileName()  const
{
  return mOutputFileName;
}

void 
SBMLExternalValidator::setOutputFileName(std::string outputFileName)
{
  mOutputFileName = outputFileName;
}

const std::string& SBMLExternalValidator::getSBMLFileName()  const
{
  return mSBMLFileName;
}

void 
SBMLExternalValidator::setSBMLFileName(std::string sbmlFileName)
{
  mSBMLFileName = sbmlFileName;
}

void 
SBMLExternalValidator::clearArguments()
{
  mArguments.clear();
}

void 
SBMLExternalValidator::addArgument(std::string arg)
{
  mArguments.push_back(arg);
}

const std::vector<std::string>& 
SBMLExternalValidator::getArguments() const
{
  return mArguments;
}

void 
SBMLExternalValidator::setArguments(std::vector<std::string> args)
{
  mArguments = args;
}

/** 
 * Starts the program with arguments and waits for it to end. The program will be invoked with
 * 
 * program sbmlFile ARGS
 *
 * and is expected to produce the output file
 */
void startProgramAndWaitForFinish(std::string& mProgram, std::string& sbmlFile, vector<string> args)
{
  if (mProgram.empty()) return;

  bool bWait = true; // wait for program to end  
  string commandLineString = mProgram + " \"" + sbmlFile +"\"";
  vector<string>::iterator it; 
  for (it = args.begin();it != args.end(); it++)
    commandLineString += " \"" + (*it) +"\""; 
  const char* commandLine = commandLineString.c_str();

#if defined (WIN32) && !defined (CYGWIN)
  STARTUPINFO si;
	memset(&si,0,sizeof(si));
	si.cb = sizeof(si);     // Set byte count

	si.dwFlags = STARTF_USESHOWWINDOW;
	si.wShowWindow  = SW_SHOWNORMAL;
	
	PROCESS_INFORMATION pi;


  if(!CreateProcess(NULL, (LPTSTR) (LPCTSTR) commandLine,
		NULL,NULL,FALSE,0,NULL,NULL,&si,&pi))
		return; // couldn't start program

	if (bWait)
		WaitForSingleObject( pi.hProcess, INFINITE );
#else
  int pid = fork();

	if (pid == -1)			// Fork failed.
		return; 

	if (pid == 0)			// This is the child process.
	{
		char *argv[4];
		const char *command = "sh";
		const char *arg = "-c";
		argv[0] = const_cast<char*>(command);
		argv[1] = const_cast<char*>(arg);
		argv[2] = const_cast<char*>(commandLine);
		argv[3] = NULL;

		if (execvp("/bin/sh", argv) > -1) // Only returns on failure.
			return; // couldn't start program

	}
  


	// If pid != -1 or 0, then we're the parent thread.
	// Simply exit and hope the child process started.
	if (bWait)
  {
    int child_status;   
    waitpid (pid, &child_status, 0);

  }
#endif

}

#define TO_ANY(target,value)\
{\
  stringstream str; str << value; str >> target;\
}

int getInt(string value)
{
  int intValue=0; TO_ANY(intValue,value );
  return intValue;
}

int getCategory(string category)
{  
  return LIBSBML_CAT_INTERNAL;
}

int getSeverity(string severity)
{
  if (severity == "error")
    return LIBSBML_SEV_ERROR;
  else if (severity == "warning")
    return LIBSBML_SEV_WARNING;
  else if (severity == "fatal")
    return LIBSBML_SEV_FATAL;
  else if (severity == "advisory")
    return LIBSBML_SEV_INFO;
  return LIBSBML_SEV_NOT_APPLICABLE;
}

void parseResultFile(std::string &mOutputFileName, std::vector<SBMLError>& errors)
{
  XMLInputStream stream (mOutputFileName.c_str());  

  if (!stream.isGood())
  {
    // output file is not readable we could run add a warning
    return;
  }

  const XMLToken  element  = stream.next();
  int errorId=0; 
  int categoryId=0;
  int severityId=0;
  int line=0;
  int column=0;
  string message;
  bool started = false;
  if (element.getName() == "validation-results")
  {
    while ( stream.isGood() )
    {
      stream.skipText();
      const XMLToken& next = stream.peek();
      if ( !stream.isGood() ) break;

      if ( next.isEndFor(element) )
      {
        stream.next();
        break;
      }
      else if ( next.isStart() )
      {
         const std::string nextName = next.getName();

         if (nextName == "problem")
         {
           categoryId = getCategory(next.getAttrValue("category"));
           errorId = getInt(next.getAttrValue("code"));
           severityId = getSeverity(next.getAttrValue("severity"));

           if (started)
           {             
             errors.push_back(SBMLError(errorId, 3, 1, message, line, column, severityId, categoryId));
             //started = false;
           }
           
           started = true;
           stream.next();
       
         } 
         else if (nextName == "location")
         {
           line = getInt(next.getAttrValue("line"));
           column = getInt(next.getAttrValue("column"));
           stream.next();
         } 
         else if (nextName == "message")
         {
           stream.next();
           const XMLToken& next1 = stream.next();           
           if (next1.isText())
           message = next1.getCharacters();
         }           
         else
         {
           stream.skipPastEnd( stream.next() );
         }
      }
      else
      {
        stream.skipPastEnd( stream.next() );
      }
    }
  }

  if (started)
    errors.push_back(SBMLError(errorId, 3, 1, message, line, column, severityId, categoryId));

}

unsigned int 
SBMLExternalValidator::validate()
{

  // write model to file
  writeSBMLToFile(getDocument(), mSBMLFileName.c_str());

  // start program  sbmlfile ARGS which should produce the output file
  startProgramAndWaitForFinish(mProgram, mSBMLFileName, mArguments);

  // parse the output file
  parseResultFile(mOutputFileName, mFailures);

  return (unsigned int)mFailures.size();
}

unsigned int 
SBMLExternalValidator::getNumArguments() const
{
  return (unsigned int)mArguments.size();
}

std::string 
SBMLExternalValidator::getArgument(unsigned int n) const
{
  return (n < mArguments.size()) ? mArguments[n] : std::string();
}


LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


/** @endcond */
