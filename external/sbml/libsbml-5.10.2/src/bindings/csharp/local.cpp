/**
 * @file   local.cpp
 * @brief  C#-specific SWIG support code for wrapping libSBML API
 * @author Frank Bergmann (fbergman@u.washington.edu)
 * @author Akiya Jouraku
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
 * -------------------------------------------------------------------------->*/


//--------------------------------------------------------------------------------
// (Currently (2008-07-25), this file is used only for Windows)
//
// Utility functions for converting encodings between Unitocde, UTF8 and ANSI CP 
//
// 1) char*    convertUnicodeToUTF8(const wchar_t* src_wstr) 
// 2) char*    convertUnicodeToACP(const wchar_t* src_wstr) 
// 3) wchar_t* convertUTF8ToUnicode(const char* src_str) 
// 4) char*    convertACPToUTF8(const char* src_str) 
// 5) char*    convertUTF8ToACP(const char* src_str) 
//
//--------------------------------------------------------------------------------

#ifdef WIN32

// do not include MFC
#define WIN32_LEAN_AND_MEAN 
// do not include GDI by default
#define NOGDI

#include <windows.h>
#include <winnls.h>

//
// convert Unicode -> UTF8 (for Windows)
//
char* convertUnicodeToUTF8(const wchar_t* src_wstr) 
{
  int    length;
  int    clength;
  char*  sbuf;

  //
  // Unicode -> UTF8
  //

  //
  // Check wbuf length		
  //
  length = WideCharToMultiByte(CP_UTF8, 0, (LPCWSTR)src_wstr, -1, NULL, 0, NULL, NULL);

  if(length == 0){
    return NULL;
  }

  sbuf = new char[length+1];

  //
  // Convert
  //
  clength = WideCharToMultiByte(CP_UTF8, 0, (LPCWSTR)src_wstr, -1, sbuf, length, NULL, NULL);
  sbuf[clength] = 0;

  if(clength == 0){
    delete [] sbuf;
    return NULL;
  }

  return sbuf;
}


//
// convert Unicode -> ANSI CP (for Windows)
//
char* convertUnicodeToACP(const wchar_t* src_wstr) 
{
  int    length;
  int    clength;
  char*  sbuf;

  //
  // Unicode -> ANSI CP
  //

  //
  // Check wbuf length		
  //
  length = WideCharToMultiByte(CP_ACP, 0, (LPCWSTR)src_wstr, -1, NULL, 0, NULL, NULL);

  if(length == 0){
    return NULL;
  }

  sbuf = new char[length+1];

  //
  // Convert
  //
  clength = WideCharToMultiByte(CP_ACP, 0, (LPCWSTR)src_wstr, -1, sbuf, length, NULL, NULL);
  sbuf[clength] = 0;

  if(clength == 0){
    delete [] sbuf;
    return NULL;
  }

  return sbuf;
}


//
// convert UTF8 -> Unicode (for Windows)
//
wchar_t* convertUTF8ToUnicode(const char* src_str) 
{
  int      length;
  int      c_length;
  wchar_t* wbuf;

  //
  // UTF8 -> Unicode
  //

  // Check src_str length
  length = MultiByteToWideChar(CP_UTF8, 0, (LPCSTR)src_str, -1, NULL, 0);
  if(length == 0){
    return NULL;
  }

  wbuf = new wchar_t[length+1];

  // Convert
  c_length = MultiByteToWideChar(CP_UTF8, 0, (LPCSTR)src_str, -1, wbuf, length);
  wbuf[c_length] = 0;
  if(c_length == 0) {
    delete [] wbuf;
    return NULL;
  }

  return wbuf;

}


//
// convert ANSI CP -> UTF8  for Windows
//
char* convertACPToUTF8(const char* src_str) 
{
  int      length;
  int      c_length;
  wchar_t* wbuf;
  char*    ubuf;

  //
  // ANSI CP -> Unicode
  //
  
  // Check src_str length
  length = MultiByteToWideChar(CP_ACP, 0, (LPCSTR)src_str, -1, NULL, 0);
  if(length == 0){
  	return NULL;
  }

  wbuf = new wchar_t[length+1];

  // Convert
  c_length = MultiByteToWideChar(CP_ACP, 0,(LPCSTR)src_str,-1,wbuf,length);
  wbuf[c_length] = 0;

  if(c_length == 0) {
    delete [] wbuf;
    return NULL;
  }

  //
  // Unicode -> UTF8
  //

  // Check wbuf length		
  length = WideCharToMultiByte(CP_UTF8, 0, (LPCWSTR)wbuf,-1,NULL,0,NULL,NULL);

  if(length == 0){
    delete [] wbuf;
    return NULL;
  }

  ubuf = new char[length+1];

  // Convert
  c_length = WideCharToMultiByte(CP_UTF8, 0, (LPCWSTR)wbuf,-1,ubuf,length,NULL,NULL);
  ubuf[c_length] = 0;

  if(c_length == 0){
    delete [] wbuf;
    delete [] ubuf;
    return NULL;
  }

  delete [] wbuf;
  return ubuf;

}


//
// convert UTF8 -> ANSI CP  for Windows
//
char* convertUTF8ToACP(const char* src_str) 
{
  int      length;
  int      c_length;
  wchar_t* wbuf;
  char*    ubuf;

  //
  // UTF8 -> Unicode
  //

  // Check src_str length
  length = MultiByteToWideChar(CP_UTF8, 0, (LPCSTR)src_str, -1, NULL, 0);
  if(length == 0){
    return NULL;
  }

  wbuf = new wchar_t[length+1];

  // Convert
  c_length = MultiByteToWideChar(CP_UTF8, 0,(LPCSTR)src_str,-1,wbuf,length);
  wbuf[c_length] = 0;
  if(c_length == 0) {
    delete [] wbuf;
    return NULL;
  }

  //
  // Unicode -> ANSI CP
  //

  // Check wbuf length		
  length = WideCharToMultiByte(CP_ACP, 0, (LPCWSTR)wbuf,-1,NULL,0,NULL,NULL);

  if(length == 0){
    delete [] wbuf;
    return NULL;
  }

  ubuf = new char[length+1];

  // Convert
  c_length = WideCharToMultiByte(CP_ACP, 0, (LPCWSTR)wbuf,-1,ubuf,length,NULL,NULL);
  ubuf[c_length] = 0;

  if(c_length == 0){
    delete [] wbuf;
    delete [] ubuf;
    return NULL;
  }

  delete [] wbuf;
  return ubuf;

}

#endif // WIN32

