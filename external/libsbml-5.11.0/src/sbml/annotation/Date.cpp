/**
 * @file    Date.cpp
 * @brief   Date I/O
 * @author  Sarah Keating
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
 * the Free Software Foundation.  A copy of the license agreement is
 * provided in the file named "LICENSE.txt" included with this software
 * distribution.  It is also available online at
 * http://sbml.org/software/libsbml/license.html
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */


#include <sbml/annotation/Date.h>
#include <sbml/common/common.h>
#include <sbml/SBase.h>
#include <cstdio>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/*
 * creates a date from the individual fields entered as numbers
 */
Date::Date(unsigned int year, unsigned int month, 
    unsigned int day, unsigned int hour, 
    unsigned int minute, unsigned int second,
    unsigned int sign, unsigned int hoursOffset,
    unsigned int minutesOffset) :
  mHasBeenModified (false)
{
  mYear   = year;
  mMonth  = month;
  mDay    = day;
  mHour   = hour;  
  mMinute = minute;
  mSecond = second;
  
  mSignOffset   = sign;
  mHoursOffset  = hoursOffset;
  mMinutesOffset  = minutesOffset;;
  
  parseDateNumbersToString();
}


/*
 * creates a date from a string
 */
Date::Date (const std::string& date) :
  mHasBeenModified (false)
{ 
  if (&(date) == NULL)
    mDate = "";
  else
    mDate = date; 

  parseDateStringToNumbers();
  parseDateNumbersToString();

}

Date::~Date() {}

/*
 * Copy constructor.
 */
Date::Date(const Date& orig)
{
  if (&orig == NULL)
  {
    throw SBMLConstructorException("Null argument to copy constructor");
  }
  else
  {
    mYear   = orig.mYear;
    mMonth  = orig.mMonth;
    mDay    = orig.mDay;
    mHour   = orig.mHour;  
    mMinute = orig.mMinute;
    mSecond = orig.mSecond;
    
    mSignOffset     = orig.mSignOffset;
    mHoursOffset    = orig.mHoursOffset;
    mMinutesOffset  = orig.mMinutesOffset;;

    mDate = orig.mDate;

    mHasBeenModified = orig.mHasBeenModified;
  }
}

/*
 * Assignment operator
 */
Date& Date::operator=(const Date& rhs)
{
  if (&rhs == NULL)
  {
    throw SBMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    mYear   = rhs.mYear;
    mMonth  = rhs.mMonth;
    mDay    = rhs.mDay;
    mHour   = rhs.mHour;  
    mMinute = rhs.mMinute;
    mSecond = rhs.mSecond;
    
    mSignOffset     = rhs.mSignOffset;
    mHoursOffset    = rhs.mHoursOffset;
    mMinutesOffset  = rhs.mMinutesOffset;;

    mDate = rhs.mDate;

    mHasBeenModified = rhs.mHasBeenModified;
  }

  return *this;
}

/*
 * @return a (deep) copy of this Date.
 */
Date* Date::clone () const
{
  return new Date(*this);
}

/*
 * sets the value of the year checking appropriateness
 */
int 
Date::setYear    (unsigned int year)
{
  if (year <1000 || year > 9999)
  {
    mYear = 2000;
    parseDateNumbersToString();
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mYear = year;
    parseDateNumbersToString();
    mHasBeenModified = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}

/*
 * sets the value of the year checking appropriateness
 */
int 
Date::setMonth   (unsigned int month)
{
  if (month < 1 || month > 12)
  {
    mMonth = 1;
    parseDateNumbersToString();
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mMonth = month;
    parseDateNumbersToString();
    mHasBeenModified = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}

/*
 * sets the value of the year checking appropriateness
 */
int 
Date::setDay     (unsigned int day)
{
  bool validDay = true;
  if (day < 1 || day > 31)
  {
    validDay = false;
  }
  else
  {
    switch (mMonth)
    {
    case 4:
    case 6:
    case 9:
    case 11:
      if (day > 30) validDay = false;
      break;
    case 2:
      if (mYear % 4 == 0)
      {
        if (day > 29) validDay = false;
      }
      else
      {
         if (day > 28) validDay = false;
      }
      break;
    case 1:
    case 3:
    case 5:
    case 7:
    case 8:
    case 10:
    case 12:
    default:
      break;
    }
  }
  
  if (!validDay)
  {
    mDay = 1;
    parseDateNumbersToString();
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mDay = day;
    parseDateNumbersToString();
    mHasBeenModified = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
} 

/*
 * sets the value of the year checking appropriateness
 */
int 
Date::setHour    (unsigned int hour)
{
  if (/*hour < 0 ||*/ hour > 23)
  {
    mHour = 0;
    parseDateNumbersToString();
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mHour = hour;
    parseDateNumbersToString();
    mHasBeenModified = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}

/*
 * sets the value of the year checking appropriateness
 */
int 
Date::setMinute  (unsigned int minute)
{
  if (/*minute < 0 ||*/ minute > 59)
  {
    mMinute = 0;
    parseDateNumbersToString();
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mMinute = minute;
    parseDateNumbersToString();
    mHasBeenModified = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}

/*
 * sets the value of the year checking appropriateness
 */
int 
Date::setSecond  (unsigned int second)
{
  if (/*second < 0 ||*/ second > 59)
  {
    mSecond = 0;
    parseDateNumbersToString();
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mSecond = second;
    parseDateNumbersToString();
    mHasBeenModified = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}

/*
 * sets the value of the year checking appropriateness
 */
int 
Date::setSignOffset    (unsigned int sign)
{
  if (/*sign < 0 ||*/ sign > 1)
  {
    mSignOffset = 0;
    parseDateNumbersToString();
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mSignOffset = sign;
    parseDateNumbersToString();
    mHasBeenModified = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}


/*
 * sets the value of the year checking appropriateness
 */
int 
Date::setHoursOffset    (unsigned int hour)
{
  if (/*hour < 0 ||*/ hour > 12)
  {
    mHoursOffset = 0;
    parseDateNumbersToString();
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mHoursOffset = hour;
    parseDateNumbersToString();
    mHasBeenModified = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}

/*
 * sets the value of the year checking appropriateness
 */
int 
Date::setMinutesOffset  (unsigned int minute)
{
  if (/*minute < 0 ||*/ minute > 59)
  {
    mMinutesOffset = 0;
    parseDateNumbersToString();
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    mMinutesOffset = minute;
    parseDateNumbersToString();
    mHasBeenModified = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}

/*
 * sets the value of the date string checking appropriateness
 */
int 
Date::setDateAsString (const std::string& date)
{
  /* if date is NULL consider this as resetting 
   * the date completely
   */
 
  if (&(date) == NULL)
  {
    mDate = "";
    // revert to default numbers
    // rewrite date string to reflect the defaults
    parseDateStringToNumbers();
    parseDateNumbersToString();
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else if (date.empty())
  {
    mDate = "";
    // revert to default numbers
    // rewrite date string to reflect the defaults
    parseDateStringToNumbers();
    parseDateNumbersToString();
    mHasBeenModified = true;
    return LIBSBML_OPERATION_SUCCESS;
  }

  /* Date must be: YYYY-MM-DDThh:mm:ssTZD
   * where TZD is either Z or +/-HH:MM
   */
  mDate = date;

  if (!representsValidDate())
  {
    mDate = "";
    parseDateNumbersToString();
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    parseDateStringToNumbers();
    parseDateNumbersToString();
    mHasBeenModified = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
}



/** @cond doxygenLibsbmlInternal */
/*
 * returns the date in numbers as a W3CDTF string
 */
void
Date::parseDateNumbersToString()
{
  char cdate[10];

  if (mMonth < 10)
    sprintf(cdate, "%u-0%u-", mYear, mMonth);
  else
    sprintf(cdate, "%u-%u-", mYear, mMonth);
  mDate = cdate;
  
  if (mDay < 10)
    sprintf(cdate, "0%uT", mDay);
  else
    sprintf(cdate, "%uT", mDay);
  mDate.append(cdate);

  if (mHour < 10)
    sprintf(cdate, "0%u:", mHour);
  else
    sprintf(cdate, "%u:", mHour);
  mDate.append(cdate);
  
  if (mMinute < 10)
    sprintf(cdate, "0%u:", mMinute);
  else
    sprintf(cdate, "%u:", mMinute);
  mDate.append(cdate);
  
  if (mSecond < 10)
    sprintf(cdate, "0%u", mSecond);
  else
    sprintf(cdate, "%u", mSecond);
  mDate.append(cdate);

  if (mHoursOffset == 0 && mMinutesOffset == 0)
  {
    sprintf(cdate, "Z");
    mDate.append(cdate);
  }
  else
  {
    if (mSignOffset == 0)
      sprintf(cdate, "-");
    else
      sprintf(cdate, "+");
    mDate.append(cdate);

    if (mHoursOffset < 10)
      sprintf(cdate, "0%u:", mHoursOffset);
    else
      sprintf(cdate, "%u:", mHoursOffset);
    mDate.append(cdate);
    
    if (mMinutesOffset < 10)
      sprintf(cdate, "0%u", mMinutesOffset);
    else
      sprintf(cdate, "%u", mMinutesOffset);
    mDate.append(cdate);
  }

}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
void
Date::parseDateStringToNumbers()
{
  std::string::size_type length = mDate.length();

  if (length == 0 )
  {
    mYear   = 2000;
    mMonth  = 1;
    mDay    = 1;
    mHour   = 0;  
    mMinute = 0;
    mSecond = 0;
    
    mSignOffset   = 0;
    mHoursOffset  = 0;
    mMinutesOffset  = 0;
  }
  else
  {
    const char * cdate = mDate.c_str();
    char year[5];
    year[4] = '\0';
    char block[3];
    block[2] = '\0';
    
    year[0] = (length > 0) ? cdate[0] : 0;
    year[1] = (length > 1) ? cdate[1] : 0;    
    year[2] = (length > 2) ? cdate[2] : 0;
    year[3] = (length > 3) ? cdate[3] : 0;

    mYear = (int)strtol(year, NULL, 10);
    
    block[0] = (length > 5) ? cdate[5] : 0;
    block[1] = (length > 6) ? cdate[6] : 0;
    
    mMonth = (int)strtol(block, NULL, 10);

    block[0] = (length > 8) ? cdate[8] : 0;
    block[1] = (length > 9) ? cdate[9] : 0;
    
    mDay = (int)strtol(block, NULL, 10);

    block[0] = (length > 11) ? cdate[11] : 0;
    block[1] = (length > 12) ? cdate[12] : 0;
    
    mHour = (int)strtol(block, NULL, 10);

    block[0] = (length > 14) ? cdate[14] : 0;
    block[1] = (length > 15) ? cdate[15] : 0;
    
    mMinute = (int)strtol(block, NULL, 10);

    block[0] = (length > 17) ? cdate[17] : 0;
    block[1] = (length > 18) ? cdate[18] : 0;
    
    mSecond = (int)strtol(block, NULL, 10);

    if (length > 19 && cdate[19] == '+')
    {
      mSignOffset = 1;
      block[0] = (length > 20) ? cdate[20] : 0;
      block[1] = (length > 21) ? cdate[21] : 0;
      mHoursOffset = (int)strtol(block, NULL, 10);

      block[0] = (length > 23) ? cdate[23] : 0;
      block[1] = (length > 24) ? cdate[24] : 0;
      mMinutesOffset = (int)strtol(block, NULL, 10);
    }
    else if (length > 19 && cdate[19] == '-')
    {
      mSignOffset = 0;
      block[0] = (length > 20) ? cdate[20] : 0;
      block[1] = (length > 21) ? cdate[21] : 0;
      mHoursOffset = (int)strtol(block, NULL, 10);

      block[0] = (length > 23) ? cdate[23] : 0;
      block[1] = (length > 24) ? cdate[24] : 0;
      mMinutesOffset = (int)strtol(block, NULL, 10);
    }
    else
    {
      mSignOffset = 0;
      mHoursOffset = 0;
      mMinutesOffset = 0;
    }
  }
}

bool
Date::representsValidDate()
{
  bool valid = true;
//  parseDateNumbersToString();
  const char * cdate = mDate.c_str();

  if (mDate.length() != 20 && mDate.length() != 25)
  {
    valid = false;
  }
  else if (cdate[4]  != '-' ||
      cdate[7]  != '-' ||
      cdate[10] != 'T' ||
      cdate[13] != ':' ||
      cdate[16] != ':')
  {
    valid = false;
  }
  else if (cdate[19] != 'Z' &&
      cdate[19] != '+' && 
      cdate[19] != '-')
  {
    valid = false;
  }
  else if (cdate[19] != 'Z' &&
           cdate[22] != ':')
  {
    valid = false;
  }


  if (getMonth() > 12 ||
      getDay() > 31   ||
      getHour() > 23  ||
      getMinute() > 59 ||
      getSecond() > 59 ||
      getSignOffset() > 1 ||
      getHoursOffset() > 11 ||
      getMinutesOffset() > 59)
  {
    valid = false;
  }
  else
  {
    switch(getMonth())
    {
    case 4:
    case 6:
    case 9:
    case 11:
      if (getDay() > 30)
        valid = false;
      break;
    case 2:
      if (getYear() % 4 == 0)
      {
        if (getDay() > 29)
          valid = false;
      }
      else
      {
        if (getDay() > 28)
          valid = false;
      }
      break;
    default:
      break;
    }
  }
  
  return valid;
}

bool
Date::hasBeenModified()
{
  return mHasBeenModified;
}

void
Date::resetModifiedFlags()
{
  mHasBeenModified = false;
}
/** @endcond */

#endif /* __cplusplus */


/** @cond doxygenIgnored */

LIBSBML_EXTERN
Date_t *
Date_createFromValues(unsigned int year, unsigned int month, 
    unsigned int day, unsigned int hour, 
    unsigned int minute, unsigned int second,
    unsigned int sign, unsigned int hoursOffset,
    unsigned int minutesOffset)
{
  return new(nothrow) Date(year, month, day, hour, minute,
    second, sign, hoursOffset, minutesOffset);
}


LIBSBML_EXTERN
Date_t *
Date_createFromString (const char * date)
{
  if (date == NULL ) return NULL;
  return new(nothrow) Date(date);
}


LIBSBML_EXTERN
void
Date_free(Date_t * date)
{
  delete static_cast<Date*>(date);
}


LIBSBML_EXTERN
Date_t *
Date_clone (const Date_t* date)
{
  if (date == NULL ) return NULL;
  return static_cast<Date*>( date->clone() );
}


LIBSBML_EXTERN
const char *
Date_getDateAsString(Date_t * date)
{
  if (date == NULL) return NULL;
  return date->getDateAsString().c_str();
}


LIBSBML_EXTERN
unsigned int
Date_getYear(Date_t * date)
{
  if (date == NULL) return SBML_INT_MAX;
  return date->getYear();
}


LIBSBML_EXTERN
unsigned int
Date_getMonth(Date_t * date)
{
  if (date == NULL) return SBML_INT_MAX;
  return date->getMonth();
}


LIBSBML_EXTERN
unsigned int
Date_getDay(Date_t * date)
{
  if (date == NULL) return SBML_INT_MAX;
  return date->getDay();
}


LIBSBML_EXTERN
unsigned int
Date_getHour(Date_t * date)
{
  if (date == NULL) return SBML_INT_MAX;
  return date->getHour();
}


LIBSBML_EXTERN
unsigned int
Date_getMinute(Date_t * date)
{
  if (date == NULL) return SBML_INT_MAX;
  return date->getMinute();
}


LIBSBML_EXTERN
unsigned int
Date_getSecond(Date_t * date) 
{ 
  if (date == NULL) return SBML_INT_MAX;
  return date->getSecond(); 
} 


LIBSBML_EXTERN
unsigned int
Date_getSignOffset(Date_t * date) 
{ 
  if (date == NULL) return SBML_INT_MAX;
  return date->getSignOffset(); 
} 


LIBSBML_EXTERN
unsigned int
Date_getHoursOffset(Date_t * date) 
{ 
  if (date == NULL) return SBML_INT_MAX;
  return date->getHoursOffset(); 
} 


LIBSBML_EXTERN
unsigned int
Date_getMinutesOffset(Date_t * date) 
{ 
  if (date == NULL) return SBML_INT_MAX;
  return date->getMinutesOffset(); 
} 


LIBSBML_EXTERN
int
Date_setYear(Date_t * date, unsigned int value) 
{ 
  if (date == NULL) return LIBSBML_INVALID_OBJECT;
  return date->setYear(value); 
}


LIBSBML_EXTERN
int
Date_setMonth(Date_t * date, unsigned int value) 
{ 
  if (date == NULL) return LIBSBML_INVALID_OBJECT;
  return date->setMonth(value); 
}


LIBSBML_EXTERN
int
Date_setDay(Date_t * date, unsigned int value) 
{ 
  if (date == NULL) return LIBSBML_INVALID_OBJECT;
  return date->setDay(value); 
}


LIBSBML_EXTERN
int
Date_setHour(Date_t * date, unsigned int value) 
{ 
  if (date == NULL) return LIBSBML_INVALID_OBJECT;
  return date->setHour(value); 
}


LIBSBML_EXTERN
int
Date_setMinute(Date_t * date, unsigned int value) 
{ 
  if (date == NULL) return LIBSBML_INVALID_OBJECT;
  return date->setMinute(value); 
}


LIBSBML_EXTERN
int
Date_setSecond(Date_t * date, unsigned int value) 
{ 
  if (date == NULL) return LIBSBML_INVALID_OBJECT;
  return date->setSecond(value); 
}


LIBSBML_EXTERN
int
Date_setSignOffset(Date_t * date, unsigned int value) 
{ 
  if (date == NULL) return LIBSBML_INVALID_OBJECT;
  return date->setSignOffset(value); 
}


LIBSBML_EXTERN
int
Date_setHoursOffset(Date_t * date, unsigned int value) 
{ 
  if (date == NULL) return LIBSBML_INVALID_OBJECT;
  return date->setHoursOffset(value); 
}


LIBSBML_EXTERN
int
Date_setMinutesOffset(Date_t * date, unsigned int value) 
{ 
  if (date == NULL) return LIBSBML_INVALID_OBJECT;
  return date->setMinutesOffset(value); 
}

LIBSBML_EXTERN
int
Date_setDateAsString(Date_t * date, const char *str)
{
  if (date == NULL) return LIBSBML_INVALID_OBJECT;
  return (str == NULL) ? date->setDateAsString("") :
                          date->setDateAsString(str);
}


LIBSBML_EXTERN
int
Date_representsValidDate(Date_t *date)
{
  if (date == NULL) return (int)false;
  return static_cast<int> (date->representsValidDate());
}

/** @endcond */

LIBSBML_CPP_NAMESPACE_END

