/**
 * @file    util.c
 * @brief   Supporting functions for example code
 * @author  Ben Bornstein
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

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <sys/stat.h>

#if defined(WIN32) && !defined(CYGWIN)
#  include <windows.h>
#else
#  include <sys/time.h>
#endif /* WIN32 && !CYGWIN */



/**
 * @return the number of milliseconds elapsed since the Epoch.
 */
#ifdef __BORLANDC__
unsigned long
#else 
unsigned long long
#endif
getCurrentMillis (void)
{
#ifdef __BORLANDC__
  unsigned long result = 0;
#else
  unsigned long long result = 0;
#endif

#ifdef __BORLANDC__
  result = (unsigned long) GetTickCount();
#else
#if WIN32 && !defined(CYGWIN)

  result = (unsigned long long) GetTickCount();

#else

  struct timeval tv;

  if (gettimeofday(&tv, NULL) == 0)
  {
    result = (unsigned long long) (tv.tv_sec * 1000) + (tv.tv_usec * .001);
  }

#endif /* WIN32 && !CYGWIN */
#endif

  return result;
}


/**
 * @return the size (in bytes) of the given filename.
 */
unsigned long
getFileSize (const char *filename)
{
  struct stat   s;
  unsigned long result = 0;


  if (stat(filename, &s) == 0)
  {
    result = s.st_size;
  }

  return result;
}


/**
 * Removes whitespace from both ends of the given string.  The string
 * is modified in-place.  This function returns a pointer to the (same)
 * string buffer.
 *
 * This was originally in libSBML's util/util.c, but moved here to
 * make this set of example programs more self-contained.
 */
char *
trim_whitespace (char *s)
{
  char *end;
  int   len;

  if (s == NULL) return NULL;

  len = strlen(s);
  end = s + len - 1;

  /**
   * Skip leading whitespace.
   *
   * When this loop terminates, s will point the first non-whitespace
   * character of the string or NULL.
   */
  while ( len > 0 && isspace(*s) )
  {
    s++;
    len--;
  }

  /**
   * Skip trailing whitespace.
   *
   * When this loop terminates, end will point the last non-whitespace
   * character of the string.
   */
  while ( len > 0 && isspace(*end) )
  {
    end--;
    len--;
  }

  s[len] = '\0';

  return s;
}


#define INPUT_LINE_LENGTH 1024

/**
 * The function get_line reads a line from a file (in this case "stdin" and
 * returns it as a string.  It is taken from the utilities library of the
 * VIENNA RNA PACKAGE ( http://www.tbi.univie.ac.at/~ivo/RNA/ )
 */
char*
get_line ( FILE *fp )
{
  /* reads lines of arbitrary length from fp */
  char s[INPUT_LINE_LENGTH], *line, *cp;
  
  line = NULL;
  do
  {
    if ( fgets( s, 512, fp ) == NULL ) break;
    cp = strchr( s, '\n' );
    if ( cp != NULL ) *cp = '\0';
    if ( line == NULL )
      line = (char *) calloc( 1+strlen(s), sizeof(char) );
    else
      line = (char *)realloc( line, 1+strlen( s )+strlen( line ) );
    strcat( line, s );
  } while ( cp == NULL );

  return line;
}

