/**
 * @file    util.h
 * @brief   Utility functions
 * @author  Ben Bornstein
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
 * in the file named "LICENSE.txt" included with this software distribution and
 * also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#ifndef util_h
#define util_h

#include <stdio.h>
#include <stdarg.h>

#include <sbml/common/extern.h>

/** @cond doxygenLibsbmlInternal */

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Easier-to-read and NULL-friendly string comparison.
 */
LIBSBML_EXTERN
unsigned int
streq (const char *s, const char *t);


/**
 * Identical to snprintf except printing always occurs according to the
 * "C" locale.  This function does not affect the locale of the calling
 * program.
 */
int
c_locale_snprintf (char *str, size_t size, const char *format, ...);


/**
 * Identical to vsnprintf except printing always occurs according to the
 * "C" locale.  This function does not affect the locale of the calling
 * program.
 */
int
c_locale_vsnprintf (char *str, size_t size, const char *format, va_list ap);


/**
 * Identical to strtod except conversion always occurs according to the
 * "C" locale.  This function does not affect the locale of the calling
 * program.
 */
double
c_locale_strtod (const char *nptr, char **endptr);


/**
 * Attempts to open filename for the given access mode and return a pointer
 * to it.  If the filename could not be opened, prints an error message and
 * exits.
 */
LIBSBML_EXTERN
FILE *
safe_fopen (const char *filename, const char *mode);


/**
 * Returns a pointer to a new string which is the concatenation of the
 * strings str1 and str2.  Memory for the new string is obtained with
 * safe_malloc() and can be freed with safe_free().
 *
 * NOTE: This strcat behaves differently than standard library strcat().
 */
LIBSBML_EXTERN
char *
safe_strcat (const char *str1, const char *str2);


/**
 * @return a pointer to a new string which is a duplicate of the string s.
 * Memory for the string is obtained with safe_malloc() and can be freed
 * with safe_free().
 */
LIBSBML_EXTERN
char *
safe_strdup (const char* s);


/**
 * Compares two strings s1 and s2, ignoring the case of the characters.
 *
 * @return an integer less than, equal to, or greater than zero if s1 is
 * found, respectively, to be less than, to match, or be greater than s2.
 */
LIBSBML_EXTERN
int
strcmp_insensitive (const char *s1, const char *s2);


/**
 * Peforms a binary search on the string table strings to find string s.
 *
 * All strings from strings[lo] to strings[hi] are searched.  The string
 * comparison function used is strcmp_insensitive().  Since the search is
 * binary, the strings table must be sorted, irrespecitve of case.
 *
 * @return the index of s in strings, if s was found, or stop + 1
 * otherwise.
 */
LIBSBML_EXTERN
int
util_bsearchStringsI (const char **strings, const char *s, int lo, int hi);


/**
 * @returns true (non-zero) if filename exists, false (zero) otherwise.
 */
LIBSBML_EXTERN
int
util_file_exists (const char *filename);


/**
 * Removes leading and trailing whitespace from the string s.
 *
 * @return a pointer to a new string which is a duplicate of the string s,
 * with leading and trailing whitespace removed or NULL is s is NULL.
 *
 * Whitespace is determined by isspace().
 */
LIBSBML_EXTERN
char *
util_trim (const char *s);


/**
 * Removes leading and trailing whitespace from the string s.
 *
 * @return a pointer to the first non-whitespace character of the string s
 * (which may be the terminating NULL), or @c NULL if s is @c NULL.  The first
 * trailing whitespace character will be replaced with NULL.
 *
 * Whitespace is determined by isspace().
 */
LIBSBML_EXTERN
char *
util_trim_in_place (char *s);


/** @endcond */


/**
 * Returns a representation of @c NaN.
 * 
 * @return a (quiet) NaN.
 */
LIBSBML_EXTERN
double
util_NaN (void);


/**
 * Returns a representation of the IEEE-754 "Negative Infinity" value.
 * 
 * @return IEEE-754 Negative Infinity.
 */
LIBSBML_EXTERN
double
util_NegInf (void);


/**
 * Returns a representation of the IEEE-754 "Positive Infinity" value.
 * 
 * @return IEEE-754 Positive Infinity
 */
LIBSBML_EXTERN
double
util_PosInf (void);


/**
 * Returns a representation of the IEEE-754 "Negative Zero" value.
 * 
 * @return IEEE-754 Negative Zero.
 */
LIBSBML_EXTERN
double
util_NegZero (void);


/**
 * Function for testing whether a given value represents negative infinity.
 *
 * @param d the floating-point value to test
 * 
 * @return @c -1 (for false) if @p d represents negative infinity, @c 1 if
 * @p d represents positive infinity, and @c 0 otherwise.
 */
LIBSBML_EXTERN
int
util_isInf (double d);

/**
 * @return 1 if the number is NaN and 0 otherwise.
 */
LIBSBML_EXTERN
int
util_isNaN (double d);

/**
 * @return 1 if the number is finite and 0 otherwise.
 */
LIBSBML_EXTERN
int
util_isFinite (double d);


/**
 * Function for testing whether a given value represents negative zero.
 *
 * @param d the floating-point value to test
 * 
 * @return nonzero (for true) if @p d is an IEEE-754 negative zero, zero
 * (for false) otherwise.
 */
LIBSBML_EXTERN
int
util_isNegZero (double d);


/**
 * Function for freeing memory allocated by libSBML functions
 *
 * @param element pointer to the object to be freed.  It must
 * be data that was originally allocated by a libSBML function.
 * 
 * This function was introduced to deal with a specific memory issue
 * arising on Windows OS when using libSBML compiled against a static MSVC
 * runtime library.  In this situation, it was not possible to use the
 * standard <code>free()</code> function when freeing memory that was
 * actually allocated within the libSBML function call.  The following is
 * an example of where the free function fails and needs to be replaced
 * with util_free().
 * @code
 *    char * formula = SBML_formulaToString(astNode);
 *    free(formula);
 * @endcode
 *
 * @note This function is only necessary when using a version of libSBML
 * compiled and linked against a static MSVC runtime library.
 */
LIBSBML_EXTERN
void
util_free (void * element);

/**
 * Function for freeing memory allocated by libSBML functions
 *
 * @param objects pointer to the array to be freed.  It must
 * be data that was originally allocated by a libSBML function.
 * @param length number of elements in the array to be freed.
 * 
 * This function was introduced to deal with a specific memory issue
 * arising on Windows OS when using libSBML compiled against a static MSVC
 * runtime library.  In this situation, it was not possible to use the
 * standard <code>free()</code> function when freeing memory that was
 * actually allocated within the libSBML function call.  The following is
 * an example of where the free function fails and needs to be replaced
 * with util_freeArray().
 * @code
 *    int length;
 *    SBMLNamespaces_t** supported = SBMLNamespaces_getSupportedNamespaces(&length);
 *    free(supported);
 * @endcode
 *
 * @note This function is only necessary when using a version of libSBML
 * compiled and linked against a static MSVC runtime library.
 */
LIBSBML_EXTERN
void
util_freeArray (void ** objects, int length);

/**
 * @return the machine epsilon
 */
LIBSBML_EXTERN 
double util_epsilon();

/**
 * @return 1 if the number are equal up to the machine epsilon and 0 otherwise.
 */
LIBSBML_EXTERN
int util_isEqual(double a, double b);

/** @cond doxygenLibsbmlInternal */

/*
 * Function prototypes to supress gcc compiler warnings about implicit
 * declaration of isnan and finite which occur despite the inclusion of
 * math.h where they are defined.  In fact, even a simple example
 * triggers this warning:
 *
 * #include <math.h>
 *
 * int main (int argc, char **argv) { return isnan(1.0); }
 *
 *  % gcc -ansi -Wall test.c
 *  test.c:3: warning: implicit declaration of function `isnan'
 */
#ifndef __cplusplus

#if !defined(isnan)
  int isnan  (double d);
#endif

#if !defined(finite)
  int finite (double d);
#endif

#endif


/** @endcond */

END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /** util_h **/

