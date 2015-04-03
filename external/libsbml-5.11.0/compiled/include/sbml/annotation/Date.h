/**
 * @file    Date.h
 * @brief   Date I/O
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
 * ------------------------------------------------------------------------ -->
 *
 * @class Date
 * @sbmlbrief{core} A MIRIAM-compliant date representation.
 *
 * @htmlinclude not-sbml-warning.html
 *
 * A Date object stores a reasonably complete representation of date and
 * time.  Its purpose is to serve as a way to store dates to be read and
 * written in the <a target="_blank"
 * href="http://www.w3.org/TR/NOTE-datetime">W3C date format</a> used in
 * RDF Dublin Core annotations within SBML.  The W3C date format is a
 * restricted form of <a target="_blank"
 * href="http://en.wikipedia.org/wiki/ISO_8601">ISO 8601</a>, the
 * international standard for the representation of dates and times.  A
 * time and date value in this W3C format takes the form
 * YYYY-MM-DDThh:mm:ssXHH:ZZ (e.g., <code>1997-07-16T19:20:30+01:00</code>)
 * where XHH:ZZ is the time zone offset.  The libSBML Date object contains
 * the following fields to represent these values:
 * 
 * @li @em year: an unsigned int representing the year.  This should be a
 * four-digit number such as @c 2011.
 * 
 * @li @em month: an unsigned int representing the month, with a range of
 * values of 1&ndash;12.  The value @c 1 represents January, and so on.
 *
 * @li @em day: an unsigned int representing the day of the month, with a
 * range of values of 1&ndash;31.
 * 
 * @li @em hour: an unsigned int representing the hour on a 24-hour clock,
 * with a range of values of 0&ndash;23.
 * 
 * @li @em minute: an unsigned int representing the minute, with a range
 * of 0&ndash;59.
 * 
 * @li @em second: an unsigned int representing the second, with a range
 * of 0&ndash;59.
 * 
 * @li @em sign: an unsigned int representing the sign of the offset (@c 0
 * signifying @c + and @c 1 signifying @c -).  See the paragraph below for
 * further explanations.
 * 
 * @li @em hours offset: an unsigned int representing the time zone's hour
 * offset from GMT.
 * 
 * @li @em minute offset: an unsigned int representing the time zone's
 * minute offset from GMT.
 *
 * To illustrate the time zone offset, a value of <code>-05:00</code> would
 * correspond to USA Eastern Standard Time.  In the Date object, this would
 * require a value of @c 1 for the sign field, @c 5 for the hour offset and
 * @c 0 for the minutes offset.
 *
 * In the restricted RDF annotations used in SBML, described in
 * Section&nbsp;6 of the SBML Level&nbsp;2 and Level&nbsp;3 specification
 * documents, date/time stamps can be used to indicate the time of
 * creation and modification of a model.  The following SBML model fragment
 * illustrates this:
@verbatim
<model metaid="_180340" id="GMO" name="Goldbeter1991_MinMitOscil">
    <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                 xmlns:dc="http://purl.org/dc/elements/1.1/"
                 xmlns:dcterms="http://purl.org/dc/terms/"
                 xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" >
            <rdf:Description rdf:about="#_180340">
                <dc:creator>
                    <rdf:Bag>
                        <rdf:li rdf:parseType="Resource">
                            <vCard:N rdf:parseType="Resource">
                                <vCard:Family>Shapiro</vCard:Family>
                                <vCard:Given>Bruce</vCard:Given>
                            </vCard:N>
                            <vCard:EMAIL>bshapiro@jpl.nasa.gov</vCard:EMAIL>
                            <vCard:ORG rdf:parseType="Resource">
                                <vCard:Orgname>NASA Jet Propulsion Laboratory</vCard:Orgname>
                            </vCard:ORG>
                        </rdf:li>
                    </rdf:Bag>
                </dc:creator>
                <dcterms:created rdf:parseType="Resource">
                    <dcterms:W3CDTF>2005-02-06T23:39:40+00:00</dcterms:W3CDTF>
                </dcterms:created>
                <dcterms:modified rdf:parseType="Resource">
                    <dcterms:W3CDTF>2005-09-13T13:24:56+00:00</dcterms:W3CDTF>
                </dcterms:modified>
            </rdf:Description>
        </rdf:RDF>
    </annotation>
</model>
@endverbatim
 */

/**
 * <!-- ~ ~ ~ ~ ~ Start of common documentation strings ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
 * The following text is used as common documentation blocks copied multiple
 * times elsewhere in this file.  The use of @class is a hack needed because
 * Doxygen's @copydetails command has limited functionality.  Symbols
 * beginning with "doc_" are marked as ignored in our Doxygen configuration.
 * ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  -->
 *
 * @class doc_date_string_format
 *
 * @par
 * The date format expresses a date and time value as a string of the form
 * YYYY-MM-DDThh:mm:ssXHH:ZZ, where
 * 
 * @li @em YYYY is a four-digit integer representing the year.  This
 * should be a four-digit number such as @c 2011.
 * 
 * @li @em MM is a two-digit integer representing the month, with a range
 * of values of 01&ndash;12.  The value @c 1 represents January, and so
 * on.
 *
 * @li @em DD is a two-digit integer representing the day of the month,
 * with a range of values of 01&ndash;31.
 * 
 * @li @em hh is a two-digit integer representing the hour on a 24-hour
 * clock, with a range of values of 00&ndash;23.
 * 
 * @li @em mm is a two-digit integer representing the minute, with a
 * range of 00&ndash;59.
 * 
 * @li @em ss is a two-digit integer representing the second, with a
 * range of 0&ndash;59.
 * 
 * @li @em X is the the sign of the time zone offset, either @c + or
 * <code>-</code>.
 *
 * @li @em HH is a two-digit integer representing the hour of the time
 * zone offset, with a range of 00&ndash;23.
 *
 * @li @em ZZ is a two-digit integer representing the minutes of the time
 * zone offset, with a range of 00&ndash;59.
 *
 * In the string format above, it is important not to forget the literal
 * character @c T in the string.  Here is an example date/time string:
 * <code>1997-07-16T19:20:30+01:00</code>, which would represent July 16,
 * 1997, at 19:20:30 in Central European Time (which is UTC +1:00).
 */


#ifndef Date_h
#define Date_h


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/common/operationReturnValues.h>
#include <sbml/util/List.h>

#include <sbml/xml/XMLNode.h>


#ifdef __cplusplus

#include <string>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN Date
{
public:
 
  /**
   * Creates a time and date representation for use in model annotations
   * and elsewhere.
   *
   * The following is the complete set of possible arguments to this
   * constructor, with default values as indicated:
   *
   * @param year an unsigned integer representing the year.  This should be
   * a four-digit number such as @c 2011.  (Default value used if this
   * argument is not given: @c 2000.)
   * 
   * @param month an unsigned integer representing the month, with a range
   * of values of 1&ndash;12.  The value @c 1 represents January, and so
   * on.  (Default value used if this argument is not given: @c 1.)
   *
   * @param day an unsigned integer representing the day of the month, with
   * a range of values of 1&ndash;31.  (Default value used if this argument
   * is not given: @c 1.)
   * 
   * @param hour an unsigned integer representing the hour on a 24-hour
   * clock, with a range of values of 0&ndash;23.  (Default value used if
   * this argument is not given: @c 0.)
   * 
   * @param minute an unsigned integer representing the minute, with a
   * range of 0&ndash;59.  (Default value used if this argument is not
   * given: @c 0.)
   * 
   * @param second an unsigned integer representing the second, with a
   * range of 0&ndash;59.  (Default value used if this argument is not
   * given: @c 0.)
   * 
   * @param sign an unsigned integer representing the sign of the offset
   * (@c 0 signifying @c + and @c 1 signifying @c -).  See the paragraph
   * below for further explanations.  (Default value used if this argument
   * is not given: @c 0.)
   * 
   * @param hoursOffset an unsigned integer representing the time zone's
   * hour offset from GMT.  (Default value used if this argument is not
   * given: @c 0.)
   * 
   * @param minutesOffset an unsigned integer representing the time zone's
   * minute offset from GMT.  (Default value used if this argument is not
   * given: @c 0.)
   *
   * To illustrate the time zone offset, a value of <code>-05:00</code>
   * would correspond to USA Eastern Standard Time.  In the Date object,
   * this would require a value of @c 1 for the sign field, @c 5 for the
   * hour offset and @c 0 for the minutes offset.
   * 
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  Date(unsigned int year = 2000, unsigned int month = 1, 
    unsigned int day = 1, unsigned int hour = 0, 
    unsigned int minute = 0, unsigned int second = 0,
    unsigned int sign = 0, unsigned int hoursOffset = 0,
    unsigned int minutesOffset = 0);

 
  /**
   * Creates a Date object from a string expressing a date and time value.
   *
   * This constructor expects its argument to be in the <a target="_blank"
   * href="http://www.w3.org/TR/NOTE-datetime">W3C date format with time
   * zone offset</a>, used in RDF Dublin Core annotations within SBML.
   * 
   * @copydetails doc_date_string_format 
   *
   * If this constructor is given a @c NULL argument or a string of length
   * zero, it constructs a Date object with the value of January 1, 2000,
   * at time 00:00 UTC.  Otherwise, the argument @em must be in the
   * complete format described above, or unpredictable results will happen.
   *
   * @param date a string representing the date.
   */
  Date (const std::string& date); 


  /**
   * Destroys this Date.
   */
  ~Date();


  /**
   * Copy constructor; creates a copy of this Date.
   *
   * @param orig the object to copy.
   * 
   * @throws SBMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  Date(const Date& orig);


  /**
   * Assignment operator.
   *
   * @param rhs The object whose values are used as the basis of the
   * assignment.
   *
   * @throws SBMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  Date& operator=(const Date& rhs);


  /**
   * Creates and returns a deep copy of this Date object.
   *
   * @return the (deep) copy of this Date object.
   */
  Date* clone () const;


  /**
   * Returns the year from this Date.
   *
   * @return the year from this Date.
   */
  unsigned int getYear()    { return mYear;   }


  /**
   * Returns the month from this Date.
   *
   * @return the month from this Date.
   */
  unsigned int getMonth()   { return mMonth;  }


  /**
   * Returns the day from this Date.
   *
   * @return the day from this Date.
   */
  unsigned int getDay()     { return mDay;    }


  /**
   * Returns the hour from this Date.
   *
   * @return the hour from this Date.
   */
  unsigned int getHour()    { return mHour;   }


  /**
   * Returns the minute from this Date.
   *
   * @return the minute from this Date.
   */
  unsigned int getMinute()  { return mMinute; }


  /**
   * Returns the seconds from this Date.
   *
   * @return the seconds from this Date.
   */
  unsigned int getSecond()  { return mSecond; }
  

  /**
   * Returns the sign of the time zone offset from this Date.
   *
   * @return the sign of the offset from this Date.
   */
  unsigned int getSignOffset()    { return mSignOffset;   }
 

  /**
   * Returns the hours of the time zone offset from this Date.
   *
   * @return the hours of the offset from this Date.
   */
  unsigned int getHoursOffset()   { return mHoursOffset;  }

  
  /**
   * Returns the minutes of the time zone offset from this Date.
   *
   * @return the minutes of the offset from this Date.
   */
   unsigned int getMinutesOffset() { return mMinutesOffset;}

   
  /**
   * Returns the current Date value in text-string form.
   *
   * The string returned will be in the <a target="_blank"
   * href="http://www.w3.org/TR/NOTE-datetime">W3C date format with time
   * zone offset</a>, used in RDF Dublin Core annotations within SBML.
   *
   * @copydetails doc_date_string_format 
   *
   * @return the date as a string.
   */
  const std::string& getDateAsString() { return mDate; }


  /**
   * Sets the value of the year of this Date object.
   *
   * The value given as argument must be between 1000 and 9999 inclusive.
   * (In the millennium during which this libSBML documentation is being
   * written, a typical value is @c 2011, but we hope that SBML will
   * continue to be used for a long time.)
   *  
   * @param year an unsigned int representing the year.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setYear    (unsigned int year);    


  /**
   * Sets the value of the month of this Date object.
   *
   * @param month an unsigned int representing the month; it must be in the
   * range 1&ndash;12 or an error will be signaled.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setMonth   (unsigned int month);   


  /**
   * Sets the value of the day of this Date object.
   *  
   * @param day an unsigned int representing the day; it must be in the
   * range 0&ndash;31 or an error will be signaled.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setDay     (unsigned int day);  


  /**
   * Sets the value of the hour of this Date object.
   *  
   * @param hour an unsigned int representing the hour to set; it must be
   * in the range 0&ndash;23 or an error will be signaled.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setHour    (unsigned int hour); 


  /**
   * Sets the value of the minute of this Date object.
   *  
   * @param minute an unsigned int representing the minute to set; it must
   * be in the range 0&ndash;59 or an error will be signaled.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setMinute  (unsigned int minute);  


  /**
   * Sets the value of the second of the Date object.
   *  
   * @param second an unsigned int representing the seconds; it must
   * be in the range 0&ndash;59 or an error will be signaled.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setSecond  (unsigned int second);


  /**
   * Sets the value of the sign of the time zone offset of this Date object.
   *
   * The only permissible values are @c 0 and @c 1.
   *  
   * @param sign an unsigned int representing the sign of the offset, with
   * @c 0 signifying @c + and @c 1 signifying @c -.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setSignOffset   (unsigned int sign); 


  /**
   * Sets the value of this Date object's time zone hour offset.
   *  
   * @param hoursOffset an unsigned int representing the hours of the
   * offset; it must be in the range 0&ndash;23 or an error will be
   * signaled.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setHoursOffset  (unsigned int hoursOffset);  
  

  /**
   * Sets the value of this Date object's time zone minutes offset.
   *  
   * @param minutesOffset an unsigned int representing the minutes of the
   * offset; it must be in the range 0&ndash;59 or an error will be
   * signaled.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setMinutesOffset(unsigned int minutesOffset);


  /**
   * Sets the value of this Date object using a date and time value
   * expressed as a text string.
   * 
   * This method expects its argument to be in the <a target="_blank"
   * href="http://www.w3.org/TR/NOTE-datetime">W3C date format with time
   * zone offset</a>, used in RDF Dublin Core annotations within SBML.
   *
   * @copydetails doc_date_string_format 
   *
   * If this method is given a @c NULL argument or a string of length zero,
   * it constructs a Date object with the value of January 1, 2000, at time
   * 00:00 UTC.  Otherwise, the argument @em must be in the complete format
   * described above, or unpredictable results will happen.
   *
   * @param date a string representing the date.
   *
   * @copydetails doc_returns_success_code
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
   */
  int setDateAsString (const std::string& date);


  /**
   * Returns true or false depending on whether this date object represents
   * a valid date and time value.
   *
   * This method verifies that the date/time value stored in this object is
   * well-formed and represents plausible values.  A time and date value in
   * the W3C format takes the form YYYY-MM-DDThh:mm:ssXHH:ZZ (e.g.,
   * <code>1997-07-16T19:20:30+01:00</code>) where XHH:ZZ is the time zone
   * offset.  This method checks such things as whether the value of the
   * month number is less than or equal to 12, whether the value of the
   * minutes number is less than or equal to 59, whether a time zone offset
   * is set, etc.
   *
   * @return @c true if the date is valid, @c false otherwise.
   */
  bool representsValidDate();


  /** @cond doxygenLibsbmlInternal */
  
  bool hasBeenModified();

  void resetModifiedFlags();
   
  
  /** @endcond */

protected:
  /** @cond doxygenLibsbmlInternal */

  /**
   * Sets the value of the individual numbers from the date 
   * as a string.
   */
  void parseDateStringToNumbers();

  /**
   * Sets the value of the date as a string from the individual numbers.
   */
  void parseDateNumbersToString();

  unsigned int mYear;
  unsigned int mMonth;
  unsigned int mDay;
  unsigned int mHour;
  unsigned int mMinute;
  unsigned int mSecond;

  /* 0 means - and 1 means + */
  unsigned int mSignOffset; 

  unsigned int mHoursOffset;
  unsigned int mMinutesOffset;

  std::string mDate;

  bool mHasBeenModified;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */

#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a date optionally from the individual fields entered as numbers.
 *
 * @param year an unsigned int representing the year.
 * @param month an unsigned int representing the month.
 * @param day an unsigned int representing the day.
 * @param hour an unsigned int representing the hour.
 * @param minute an unsigned int representing the minute.
 * @param second an unsigned int representing the second.
 * @param sign an unsigned int representing the sign of the offset 
 * (0/1 equivalent to +/-). 
 * @param hoursOffset an unsigned int representing the hoursOffset.
 * @param minutesOffset an unsigned int representing the minutesOffset.
 *
 * @return pointer to the newly created Date_t structure.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
Date_t *
Date_createFromValues(unsigned int year, unsigned int month, 
    unsigned int day, unsigned int hour, 
    unsigned int minute, unsigned int second,
    unsigned int sign, unsigned int hoursOffset,
    unsigned int minutesOffset);

/**
 * Creates a date from a string.
 *
 * @param date a string representing the date.
 *
 * @return pointer to the newly created Date_t structure.
 *
 * @note the string should be in W3CDTF format 
 * YYYY-MM-DDThh:mm:ssTZD (eg 1997-07-16T19:20:30+01:00)
 * where TZD is the time zone designator.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
Date_t *
Date_createFromString (const char * date); 

/**
 * Destroys this Date_t.
 *
 * @param date Date_t structure to be freed.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
void
Date_free(Date_t* date);

/**
 * Creates a deep copy of the given Date_t structure
 * 
 * @param date the Date_t structure to be copied
 * 
 * @return a (deep) copy of the given Date_t structure.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
Date_t *
Date_clone (const Date_t* date);

/**
 * Returns the Date_t as a string.
 *
 * @param date the Date_t structure to be queried
 * 
 * @return the date as a string.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
const char *
Date_getDateAsString(Date_t * date);

/**
 * Returns the year from this Date_t.
 *
 * @param date the Date_t structure to be queried
 * 
 * @return the year from this Date_t.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
unsigned int
Date_getYear(Date_t * date);

/**
 * Returns the month from this Date_t.
 *
 * @param date the Date_t structure to be queried
 * 
 * @return the month from this Date_t.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
unsigned int
Date_getMonth(Date_t * date);

/**
 * Returns the day from this Date_t.
 *
 * @param date the Date_t structure to be queried
 * 
 * @return the day from this Date_t.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
unsigned int
Date_getDay(Date_t * date);

/**
 * Returns the hour from this Date_t.
 *
 * @param date the Date_t structure to be queried
 * 
 * @return the hour from this Date_t.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
unsigned int
Date_getHour(Date_t * date);

/**
 * Returns the minute from this Date_t.
 *
 * @param date the Date_t structure to be queried
 * 
 * @return the minute from this Date_t.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
unsigned int
Date_getMinute(Date_t * date);

/**
 * Returns the seconds from this Date_t.
 *
 * @param date the Date_t structure to be queried
 * 
 * @return the seconds from this Date_t.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
unsigned int
Date_getSecond(Date_t * date);

/**
 * Returns the sign of the offset from this Date_t.
 *
 * @param date the Date_t structure to be queried
 * 
 * @return the sign of the offset from this Date_t.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
unsigned int
Date_getSignOffset(Date_t * date);

/**
 * Returns the hours of the offset from this Date_t.
 *
 * @param date the Date_t structure to be queried
 * 
 * @return the hours of the offset from this Date_t.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
unsigned int
Date_getHoursOffset(Date_t * date);

/**
 * Returns the minutes of the offset from this Date_t.
 *
 * @param date the Date_t structure to be queried
 * 
 * @return the minutes of the offset from this Date_t.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
unsigned int
Date_getMinutesOffset(Date_t * date);

/**
 * Sets the value of the year checking appropriateness.
 *  
 * @param date the Date_t structure to be set
 * @param value an unsigned int representing the year to set.  
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
int
Date_setYear(Date_t * date, unsigned int value);

/**
 * Sets the value of the month checking appropriateness.
 *  
 * @param date the Date_t structure to be set
 * @param value an unsigned int representing the month to set.  
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
int
Date_setMonth(Date_t * date, unsigned int value);

/**
 * Sets the value of the day checking appropriateness.
 *  
 * @param date the Date_t structure to be set
 * @param value an unsigned int representing the day to set.  
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
int
Date_setDay(Date_t * date, unsigned int value);

/**
 * Sets the value of the hour checking appropriateness.
 *  
 * @param date the Date_t structure to be set
 * @param value an unsigned int representing the hour to set.  
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
int
Date_setHour(Date_t * date, unsigned int value);

/**
 * Sets the value of the minute checking appropriateness.
 *  
 * @param date the Date_t structure to be set
 * @param value an unsigned int representing the minute to set.  
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
int
Date_setMinute(Date_t * date, unsigned int value);

/**
 * Sets the value of the second checking appropriateness.
 *  
 * @param date the Date_t structure to be set
 * @param value an unsigned int representing the second to set.  
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
int
Date_setSecond(Date_t * date, unsigned int value);

/**
 * Sets the value of the offset sign checking appropriateness.
 *  
 * @param date the Date_t structure to be set
 * @param value an unsigned int representing the sign of the 
 * offset to set.  
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
int
Date_setSignOffset(Date_t * date, unsigned int value);

/**
 * Sets the value of the offset hour checking appropriateness.
 *  
 * @param date the Date_t structure to be set
 * @param value an unsigned int representing the hours of the 
 * offset to set.  
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
int
Date_setHoursOffset(Date_t * date, unsigned int value);

/**
 * Sets the value of the offset minutes checking appropriateness.
 *  
 * @param date the Date_t structure to be set
 * @param value an unsigned int representing the minutes of the 
 * offset to set.  
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
int
Date_setMinutesOffset(Date_t * date, unsigned int value);

/**
 * Sets the value of the date from a string.
 *  
 * @param date the Date_t structure to be set
 * @param str string representing the date to set.  
 *
 * @copydetails doc_returns_success_code
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_ATTRIBUTE_VALUE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
int
Date_setDateAsString(Date_t * date, const char* str);


/**
 * Returns true or false depending on whether this date structure represents
 * a valid date and time value.
 *
 * This method verifies that the date/time value stored in this structure is
 * well-formed and represents plausible values.  A time and date value in
 * the W3C format takes the form YYYY-MM-DDThh:mm:ssXHH:ZZ (e.g.,
 * <code>1997-07-16T19:20:30+01:00</code>) where XHH:ZZ is the time zone
 * offset.  This method checks such things as whether the value of the
 * month number is less than or equal to 12, whether the value of the
 * minutes number is less than or equal to 59, whether a time zone offset
 * is set, etc.
 *
 * @param date the Date_t structure to be checked
 *
 * @return @c true if the date is valid, @c false otherwise.
 *
 * @memberof Date_t
 */
LIBSBML_EXTERN
int
Date_representsValidDate(Date_t *date);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /** Date_h **/

