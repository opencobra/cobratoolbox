/**
 * @cond doxygenLibsbmlInternal
 *
 * @file    XMLTokenizer.cpp
 * @brief   Uses an XMLHandler to deliver an XML stream as a series of tokens
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

#include <sstream>

#include <sbml/xml/XMLToken.h>
#include <sbml/xml/XMLTokenizer.h>

using namespace std;

LIBSBML_CPP_NAMESPACE_BEGIN

/*
 * Creates a new XMLTokenizer.
 */
XMLTokenizer::XMLTokenizer () :
   mInChars( false )
 , mInStart( false )
 , mEOFSeen( false )
{
}


/**
 * Copy Constructor
 */
XMLTokenizer::XMLTokenizer (const XMLTokenizer& other)
  : mInChars(other.mInChars)
  , mInStart(other.mInStart)
  , mEOFSeen(other.mEOFSeen)
  , mEncoding(other.mEncoding)
  , mVersion(other.mVersion)
  , mCurrent(other.mCurrent)
  , mTokens(other.mTokens)
{
}


/*
 * Destroys this XMLTokenizer.
 */
XMLTokenizer::~XMLTokenizer ()
{
}


/*
 * @return the encoding of the underlying XML document.
 */
const string&
XMLTokenizer::getEncoding ()
{
  return mEncoding;
}


/*
 * @return the version of the underlying XML document.
 */
const string&
XMLTokenizer::getVersion ()
{
  return mVersion;
}


/*
 * @return true if this XMLTokenizer has at least one XMLToken ready to
 * deliver, false otherwise.
 *
 * Note that hasNext() == false does not imply isEOF() == true.  The
 * XMLTokenizer may simply be waiting for the XMLParser to parse more of
 * the document.
 */
bool
XMLTokenizer::hasNext () const
{
  return (mTokens.size() > 0);
}


/*
 * @return true if the end of the XML file (document) has been reached
 * and there are no more tokens to consume, false otherwise.
 */
bool
XMLTokenizer::isEOF () const
{
  return mEOFSeen && !hasNext();
}


/*
 * Consume the next XMLToken and return it.
 *
 * @return the next XMLToken.
 */
XMLToken
XMLTokenizer::next ()
{
  XMLToken token( peek() );
  mTokens.pop_front();

  return token;
}


/*
 * Returns the next XMLToken without consuming it.  A subsequent call to
 * either peek() or next() will return the same token.
 *
 * @return the next XMLToken.
 */
const XMLToken&
XMLTokenizer::peek ()
{
  return mTokens.front();
}


/*
 * Prints a string representation of the underlying token stream, for
 * debugging purposes.
 */
string
XMLTokenizer::toString ()
{
  ostringstream stream;

  for (unsigned int n = 0; n < mTokens.size(); ++n)
  {
    stream << '[' << mTokens[n].toString() << ']' << endl;
  }

  return stream.str();
}


/*
 * Receive notification of the XML declaration, i.e.
 * <?xml version="1.0" encoding="UTF-8"?>
 */
void
XMLTokenizer::XML (const string& version, const string& encoding)
{
  mVersion = version;
  mEncoding = encoding;
}


/*
 * Receive notification of the start of an element.
 */
void
XMLTokenizer::startElement (const XMLToken& element)
{
  if (&element == NULL) return; 

  if (mInChars || mInStart)
  {
    mInChars = false;
    mTokens.push_back( mCurrent );
  }

  //
  // We delay pushing element onto mTokens until we see either an end
  // elment (in which case we can collapse start and end elements into a
  // single token) or the beginning of character data.
  //
  mInStart = true;
  mCurrent = element;
}


/*
 * Receive notification of the end of the document.
 */
void
XMLTokenizer::endDocument ()
{
  mEOFSeen = true;
}


/*
 * Receive notification of the end of an element.
 */
void
XMLTokenizer::endElement (const XMLToken& element)
{
  if (mInChars)
  {
    mInChars = false;
    mTokens.push_back( mCurrent );
  }

  if (mInStart)
  {
    mInStart = false;
    mCurrent.setEnd();
    mTokens.push_back( mCurrent );
  }
  else if (&element != NULL) 
  {
    mTokens.push_back(element);
  }
}


/*
 * Receive notification of character data inside an element.
 */
void
XMLTokenizer::characters (const XMLToken& data)
{
  if (&data == NULL) return; 

  if (mInStart)
  {
    mInStart = false;
    mTokens.push_back( mCurrent );
  }

  if (mInChars)
  {
    mCurrent.append( data.getCharacters() );
  }
  else
  {
    mInChars = true;
    mCurrent = data;
  }
}

unsigned int
XMLTokenizer::determineNumberChildren(bool & valid, const std::string& element)
{
  valid = false;
  unsigned int numChildren = 0;
  std::string closingTag = element;
  bool forcedElement = true;
  if (closingTag.empty() == true) 
  {
    closingTag = "apply";
    forcedElement = false;
  }

  // if there is only one token there cannot be any children 
  size_t size = mTokens.size();
  if (size < 2)
  {
    return numChildren;
  }

  // we assume that the first unread token is a 
  // function and that at some point in the
  // list of tokens we will hit the end of the 
  // element for that function
  // need to count the number of starts

  unsigned int index = 0;
  XMLToken firstUnread = mTokens.at(index);
  while (firstUnread.isText() && index < size - 1)
  {
    // skip any text
    index++;
    firstUnread = mTokens.at(index);
  }


  // if we have an apply the firstToken should be a function
  // that is both a start and an end
  // unless we are reading a user function
  // or a csymbol
  // if the tag is not a start and an end this is an error
  // we want to exit
  // but be happy that the read is ok
  // and the error gets logged elsewhere
  if (closingTag == "apply")
  {
    std::string firstName = firstUnread.getName();

    if (firstName != "ci" && firstName != "csymbol")
    {
      if (firstUnread.isStart() != true 
        || (firstUnread.isStart() == true &&  firstUnread.isEnd() != true))
      {
        valid = true;
        return numChildren;
      }
    }
  }

  index = 1;
  if (forcedElement == true)
  {
    index = 0;
  }

  unsigned int depth = 0;
  std::string name;
  bool cleanBreak = false;
  XMLToken next = mTokens.at(index);
  while (index < size-2)
  {
    // skip any text elements
    while(next.isText() == true && index < size-1)
    {
      index++;
      next = mTokens.at(index);
    }
    if (next.isEnd() == true && next.getName() == closingTag)
    {
      valid = true;
      break;
    }
    // iterate to first start element
    while (next.isStart() == false && index < size-1)
    {
      index++;
      next = mTokens.at(index);
    }

    // check we have not reached the end
    // this would be a bad place if we have so set num children to zero
    if (index == size)
    {
      numChildren = 0;
      break;
    }

    // record the name of the start element
    name = next.getName();
    numChildren++;

 //   index++;
    // check we have not reached the end
    if (index + 1 == size)
    {
      numChildren = 0;
      break;
    }
    else if (next.isEnd() == false)
    {
      index++;
      if (index < size)
      {
        next = mTokens.at(index);
      }
      else
      {
        break;
      }
    }

    // iterate to the end of </name>
    // checking that we have not got a nested element <name></name>
    cleanBreak = false;
    while (index < size-1)
    {
      if (next.isStart() == true && next.isEnd() == false && next.getName() == name)
      {
        depth++;
      }

      if (next.isEnd() == true && next.getName() == name)
      {
        if (depth == 0)
        {
          cleanBreak = true;
          break;
        }
        else
        {
          depth--;
        }
      }

      index++;
      next = mTokens.at(index);
    }

    index++;
    if (index < size)
    {
      next = mTokens.at(index);
    }
  } 

  // we might have hit the end of the loop and the end of the correct tag
  // but the loop hits before it can record that it was valid
  if (valid == false && cleanBreak == true)
  {
  if (index >= size-2 && next.isEnd() == true && next.getName() == closingTag)
  {
      valid = true;
  }
  }

  return numChildren;
}

unsigned int
XMLTokenizer::determineNumSpecificChildren(bool & valid, 
                                           const std::string& qualifier, 
                                        const std::string& container)
{
  valid = false;
  unsigned int numQualifiers = 0;

  size_t size = mTokens.size();
  if (size < 2)
  {
    return numQualifiers;
  }

  unsigned int depth = 0;
  unsigned int index = 0;
  std::string name;
  
  XMLToken next = mTokens.at(index);
  name = next.getName();
  if (next.isStart() == true && next.isEnd() == true && index < size)
  {
    //if (qualifier.empty() == false && name == qualifier)
    //{
      numQualifiers++;
      index++;
      next = mTokens.at(index);
    //}
    //else
    //{
    //  index++;
    //  next = mTokens.at(index);
    //}
  }
  bool cleanBreak = false;

  while (index < size-2)
  {
    // skip any text elements
    while(next.isText() == true && index < size-1)
    {
      index++;
      next = mTokens.at(index);
    }

    if (next.isEnd() == true && next.getName() == container)
    {
      valid = true;
      break;
    }
    // iterate to first start element
    while (next.isStart() == false && index < size-1)
    {
      index++;
      next = mTokens.at(index);
    }

    if (next.isStart() == true && next.isEnd() == true)
    {
      if (qualifier.empty() == true)
      {
        // if we are not looking for a specifc element then
        // we may have a child that is a start and end
        // such as <true/>
        numQualifiers++;
      }
      index++;
      if (index < size)
      {
        next = mTokens.at(index);
        continue;
      }
    }
    // check we have not reached the end
    // this would be a bad place if we have so set num children to zero
    if (index == size)
    {
      numQualifiers = 0;
      break;
    }

    // record the name of the start element
    name = next.getName();
    if (qualifier.empty() == true || name == qualifier)
    {
      numQualifiers++;
    }

//    index++;
    // check we have not reached the end
    if (index+1 == size)
    {
      numQualifiers = 0;
      break;
    }
    else
    {
      index++;
      next = mTokens.at(index);
    }

    // iterate to the end of </name>
    // checking that we have not got a nested element <name></name>
    cleanBreak = false;
    while (index < size-1)
    {
      if (next.isStart() == true && next.getName() == name)
      {
        depth++;
      }

      if (next.isEnd() == true && next.getName() == name)
      {
        if (depth == 0)
        {
          cleanBreak = true;
          break;
        }
        else
        {
          depth--;
        }
      }

      index++;
      if (index < size)
      {
        next = mTokens.at(index);
      }
    }

    index++;
    if (index < size)
    {
      next = mTokens.at(index);
    }
  }  

  // we might have hit the end of the loop and the end of the correct tag
  if (valid == false && cleanBreak == true)
  {
  if (index >= size-2 && next.isEnd() == true && next.getName() == container)
  {
      valid = true;
  }
  }
  //if (index >= size-2 && next.isEnd() == true && next.getName() == container)
  //{
  //    valid = true;
  //}

  return numQualifiers;
}


LIBSBML_CPP_NAMESPACE_END

/** @endcond */
