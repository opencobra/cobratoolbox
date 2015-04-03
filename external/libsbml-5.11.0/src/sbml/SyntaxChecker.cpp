/**
 * @file    SyntaxChecker.cpp
 * @brief   Syntax checking functions
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
 * ---------------------------------------------------------------------- -->*/

#include <sbml/SyntaxChecker.h>
#include <cstring>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/**
 * elements permitted on the body element of xhtml
 */

static const char * XHTML_ELEMENTS[] =
{
      "a"
    , "abbr"
    , "acronym"
    , "address"
    , "applet"
    , "b"
    , "basefont"
    , "bdo"
    , "big"
    , "blockquote"
    , "br"
    , "button"
    , "center"
    , "cite"
    , "code"
    , "del"
    , "dfn"
    , "dir"
    , "div"
    , "dl"
    , "em"
    , "fieldset"
    , "font"
    , "form"
    , "h1"
    , "h2"
    , "h3"
    , "h4"
    , "h5"
    , "h6"
    , "hr"
    , "i"
    , "iframe"
    , "img"
    , "input"
    , "ins"
    , "isindex"
    , "kbd"
    , "label"
    , "map"
    , "menu"
    , "noframes"
    , "noscript"
    , "object"
    , "ol"
    , "p"
    , "pre"
    , "q"
    , "s"
    , "samp"
    , "script"
    , "select"
    , "small"
    , "span"
    , "strike"
    , "strong"
    , "sub"
    , "sup"
    , "table"
    , "textarea"
    , "tt"
    , "u"
    , "ul"
    , "var"
};

bool
SyntaxChecker::isValidSBMLSId(std::string sid)
{
  size_t size = sid.size();
  if (size==0) return false;
  size_t n = 0;

  char c = sid[n];
  bool okay = (isalpha(c) || (c == '_'));
  n++;

  while (okay && n < size)
  {
    c = sid[n];
    okay = (isalnum(c) || c == '_');
    n++;
  }

  return okay;

}

#ifndef SWIG
/*
 * Checks the validity of the given srcId and sets the srcId to dstId
 * and returns LIBSBML_OPERATION_SUCCESS if the srcId is valid, otherwise 
 * srcId is not set to the dstId and returns LIBSBML_INVALID_ATTRIBUTE_VALUE.
 */
int 
SyntaxChecker::checkAndSetSId(const std::string &srcId, std::string &dstId)
{
  if (!(SyntaxChecker::isValidSBMLSId(srcId)))
  {
    return LIBSBML_INVALID_ATTRIBUTE_VALUE;
  }
  else
  {
    dstId = srcId;
    return LIBSBML_OPERATION_SUCCESS;
  }  
}
#endif


bool
SyntaxChecker::isValidXMLID(std::string id)
{
  string::iterator it = id.begin();
  // an empty id is not a valid XML id
  if (it == id.end()) return false;
 
  // first character must be a letter or '_' or ':'
  unsigned char c = *it;
  bool okay;

  if (c < 0x80)
  {
    okay = (isUnicodeLetter(it, 1) || c == '_' || c == ':');
    it++;
  }
  else if (c >> 5 == 0x6)
  {
    okay = (isUnicodeLetter(it, 2));
    it++;
    it++;
  }
  else if (c >> 4 == 0xe)
  {
    okay = (isUnicodeLetter(it, 3));
    it++;
    it++;
    it++;
  }
  else
  {
    okay = false;
    it++;
  }


  // remaining chars must be 
  // letter | digit | '.' | '-' | ' ' | ':' | CombiningChar | Extender
  while (okay && it < id.end())
  {
    c = *it;
    
    // need to find multibyte sequences
    if (c < 0x80)
    {
      okay = (
          isUnicodeLetter(it, 1)  ||
          isUnicodeDigit(it, 1)   ||
            c == '.'              ||
            c == '-'              ||
            c == '_'              ||
            c == ':'              );
    }
    else if (c >> 5 == 0x6)
    {
      okay = (
          isUnicodeLetter(it, 2)  ||
          isUnicodeDigit(it, 2)   ||
          isCombiningChar(it, 2)  ||
          isExtender(it, 2)       );
      it++;
    }
    else if (c >> 4 == 0xe)
    {
      okay = (
          isUnicodeLetter(it, 3)  ||
          isUnicodeDigit(it, 3)   ||
          isCombiningChar(it, 3)  ||
          isExtender(it, 3)       );
      it++;
      it++;
    }
    else if (c >> 3 == 0x1e)
    {
      okay = (
          isUnicodeLetter(it, 4)  ||
          isUnicodeDigit(it, 4)   ||
          isCombiningChar(it, 4)  ||
          isExtender(it, 4)       );
      it += 3;
    }
    it++;
  }
  return okay;

}




bool 
SyntaxChecker::isValidXMLanyURI(std::string uri)
{
  string::iterator it = uri.begin();
 
  // keep a record of the first character 
  unsigned char c = *it;
  
  bool okay = true;
  
  // find the first occurrence of :
  size_t colonPos = uri.find(':');

  // find first occurence of /
  size_t slashPos = uri.find('/');

  // find first occurence of #
  size_t hashPos = uri.find('#');

  // find next occurence of #
  size_t hashPos1 = uri.find('#', hashPos+1);

  // find first occurence of ?
  size_t questPos = uri.find('?');

  // find first occurence of '['
  size_t openPos = uri.find('[');

  // find first occurence of ']'
  size_t closePos = uri.find(']');


  // quite hard to quantify the rules for the anyURI as many of them
  // relate to resolving rather than syntax

  // the following do apply:
  //1. If the uri starts with abc: before any slashes then it 
  //   must start with a letter
  //2.  there can never be more than one # fragment
  //3. the [ and ] are not allowed in the path part - only in fragment or query
  //   so cannot occur before a # or a ?

  // so Rule 1
  if (colonPos < slashPos)
  {
    okay = isalpha(c); 
  }

  // Rule 2
  if (okay == true && hashPos1 != string::npos)
  {
    okay = false;
  }

  // Rule 3
  if (okay == true && (openPos != string::npos || closePos != string::npos))
  {
    if (hashPos != string::npos)
    {
      if (questPos != string::npos)
      {
        if (questPos < hashPos)
        {
          if (openPos < questPos || closePos < questPos)
          {
            okay = false;
          }
        }
        else
        {
          if (openPos < hashPos || closePos < hashPos)
          {
            okay = false;
          }
        }
      }
      else
      {
        if (openPos < hashPos || closePos < hashPos)
        {
          okay = false;
        }
      }
    }
    else
    {
      if (questPos != string::npos)
      {
        if (openPos < questPos || closePos < questPos)
        {
          okay = false;
        }
      }
      else
      {
        // found [ or ] before any # or ?
        okay = false;
      }
    }
  }

  return  okay;
}

bool
SyntaxChecker::isValidUnitSId(std::string units)
{
  return isValidSBMLSId(units);
}


bool 
SyntaxChecker::hasExpectedXHTMLSyntax(const XMLNode * xhtml, 
                                     SBMLNamespaces * sbmlns)
{
  if (xhtml == NULL) return false;
  bool correctSyntax = true;
  unsigned int i;
  unsigned int level = (sbmlns) ? sbmlns->getLevel() : SBML_DEFAULT_LEVEL ;

  /*
  * namespace declaration is variable
  * if a whole html tag has been used
  * or a whole body tag then namespace can be implicitly declared
  */
  XMLNamespaces *toplevelNS = (sbmlns) ? sbmlns->getNamespaces() : NULL;
  /* SBML Level 3 relaxed the restrictions on XHTML notes */

  if (level > 2)
  {
    for (i = 0; i < xhtml->getNumChildren(); i++)
    {
      if (!SyntaxChecker::hasDeclaredNS(xhtml->getChild(i), toplevelNS))
      {
        correctSyntax = false;
        break;
      }
    }
  }
  else
  {
    
    unsigned int children = xhtml->getNumChildren();

    if (children > 1)
    {
      /* each element must be allowed and declare namespace */
      for (i=0; i < children; i++)
      {
        if (SyntaxChecker::isAllowedElement(xhtml->getChild(i)))
        {
          if (!SyntaxChecker::hasDeclaredNS(xhtml->getChild(i), toplevelNS))
          {
            correctSyntax = false;
            break;
          }
        }
        else
        {
          correctSyntax = false;
          break;
        }
      }
    }
    else
    {
      /* only one element which can be html or body with either implicit/explicit
      * namespace declaration
      * OR could be one of the listed elements.
      */

      const string& top_name = xhtml->getChild(0).getName();

      if (top_name != "html" && top_name != "body"
        && !SyntaxChecker::isAllowedElement(xhtml->getChild(0)))
      {
        correctSyntax = false;
      }
      else
      {
        if (!SyntaxChecker::hasDeclaredNS(xhtml->getChild(0), toplevelNS))
        {
          correctSyntax = false;
        }
      }
      /* if it is an html doc then it must include title and body */ 
      if (top_name == "html" 
        && !SyntaxChecker::isCorrectHTMLNode(xhtml->getChild(0)))
      {
        correctSyntax = false;
      }
    }
  }

  return correctSyntax;
}


/** @cond doxygenLibsbmlInternal */
bool
SyntaxChecker::isValidInternalUnitSId(std::string units)
{
  return isValidInternalSId(units);
}


bool
SyntaxChecker::isValidInternalSId(std::string sid)
{
  unsigned int size = (unsigned int)sid.size();

  if (size == 0)
  {
    return true;
  }

  unsigned int n = 0;

  char c = sid[n];
  bool okay = (isalpha(c) || (c == '_'));
  n++;

  while (okay && n < size)
  {
    c = sid[n];
    okay = (isalnum(c) || c == '_');
    n++;
  }

  return okay;

}


bool 
SyntaxChecker::isAllowedElement(const XMLNode& node)
{
  bool allowed = true;
    
  const char * top = node.getName().c_str();
  static const int size = sizeof(XHTML_ELEMENTS) / sizeof(XHTML_ELEMENTS[0]);

  int index = util_bsearchStringsI(XHTML_ELEMENTS, top, 0, size - 1);
  allowed = (index < size);

  return allowed;
}

bool 
SyntaxChecker::hasDeclaredNS(const XMLNode& node, const XMLNamespaces* toplevelNS)
{
  bool correctSyntax = true;

  /* check whether the element has the namespaces declared */
  if (node.getNamespaces().hasURI("http://www.w3.org/1999/xhtml"))
  {
    /* no need to check that element is tagged with XHTML namespace */
    return correctSyntax;
  }
  else if (toplevelNS != NULL)
  {
    /* need to check that element is tagged with XHTML namespace */
    if (toplevelNS->getURI(node.getPrefix()) != "http://www.w3.org/1999/xhtml")
    {
      correctSyntax = false;
    }
  }
  else
  {
    correctSyntax = false;
  }
  
  return correctSyntax;
}

bool 
SyntaxChecker::isCorrectHTMLNode(const XMLNode& node)
{
  bool correctSyntax = true;

  if (node.getName() != "html")
  {
    correctSyntax = false;
    return correctSyntax;
  }

  /* an html node should have two children named head and body */
  unsigned int children = node.getNumChildren();

  /* avoid further checks if not 2 children */
  if (children != 2)
  {
    correctSyntax = false;
    return correctSyntax;
  }
  else
  {
    if (node.getChild(0).getName() != "head")
    {
      correctSyntax = false;
    }
    else
    {
      /* head should have at least 1 child title */
      if (!(node.getChild(0).getNumChildren() > 0))
      {
        correctSyntax = false;
        return correctSyntax;
      }
      else
      {
        bool found = false;
        for (unsigned int i = 0; i < node.getChild(0).getNumChildren(); i++)
        {
          if (node.getChild(0).getChild(i).getName() == "title")
          {
            found = true;
          }
        }
        if (!found)
        {
          correctSyntax = false;
        }
      }
    }
    if (node.getChild(1).getName() != "body")
    {
      correctSyntax = false;
    }
  }

  
  return correctSyntax;
}

/*
 * Checks if a character is part of the Unicode Letter set.
 * @return true if the character is a part of the set, false otherwise.
 */
bool 
SyntaxChecker::isUnicodeLetter(std::string::iterator it, unsigned int numBytes)
{
  /*
  * Letter ::=  BaseChar | Ideographic 
  * BaseChar ::=  [#x0041-#x005A] | [#x0061-#x007A] | [#x00C0-#x00D6] | 
  * [#x00D8-#x00F6] | [#x00F8-#x00FF] | [#x0100-#x0131] | [#x0134-#x013E] | 
  * [#x0141-#x0148] | [#x014A-#x017E] | [#x0180-#x01C3] | [#x01CD-#x01F0] | 
  * [#x01F4-#x01F5] | [#x01FA-#x0217] | [#x0250-#x02A8] | [#x02BB-#x02C1] | 
  * #x0386 | [#x0388-#x038A] | #x038C | [#x038E-#x03A1] | [#x03A3-#x03CE] | 
  * [#x03D0-#x03D6] | #x03DA | #x03DC | #x03DE | #x03E0 | [#x03E2-#x03F3] | 
  * [#x0401-#x040C] | [#x040E-#x044F] | [#x0451-#x045C] | [#x045E-#x0481] | 
  * [#x0490-#x04C4] | [#x04C7-#x04C8] | [#x04CB-#x04CC] | [#x04D0-#x04EB] | 
  * [#x04EE-#x04F5] | [#x04F8-#x04F9] | [#x0531-#x0556] | #x0559 | 
  * [#x0561-#x0586] | [#x05D0-#x05EA] | [#x05F0-#x05F2] | [#x0621-#x063A] | 
  * [#x0641-#x064A] | [#x0671-#x06B7] | [#x06BA-#x06BE] | [#x06C0-#x06CE] | 
  * [#x06D0-#x06D3] | #x06D5 | [#x06E5-#x06E6] | [#x0905-#x0939] | #x093D | 
  * [#x0958-#x0961] | [#x0985-#x098C] | [#x098F-#x0990] | [#x0993-#x09A8] | 
  * [#x09AA-#x09B0] | #x09B2 | [#x09B6-#x09B9] | [#x09DC-#x09DD] | 
  * [#x09DF-#x09E1] | [#x09F0-#x09F1] | [#x0A05-#x0A0A] | [#x0A0F-#x0A10] | 
  * [#x0A13-#x0A28] | [#x0A2A-#x0A30] | [#x0A32-#x0A33] | [#x0A35-#x0A36] | 
  * [#x0A38-#x0A39] | [#x0A59-#x0A5C] | #x0A5E | [#x0A72-#x0A74] | 
  * [#x0A85-#x0A8B] | #x0A8D | [#x0A8F-#x0A91] | [#x0A93-#x0AA8] | 
  * [#x0AAA-#x0AB0] | [#x0AB2-#x0AB3] | [#x0AB5-#x0AB9] | #x0ABD | #x0AE0 | 
  * [#x0B05-#x0B0C] | [#x0B0F-#x0B10] | [#x0B13-#x0B28] | [#x0B2A-#x0B30] | 
  * [#x0B32-#x0B33] | [#x0B36-#x0B39] | #x0B3D | [#x0B5C-#x0B5D] | 
  * [#x0B5F-#x0B61] | [#x0B85-#x0B8A] | [#x0B8E-#x0B90] | [#x0B92-#x0B95] | 
  * [#x0B99-#x0B9A] | #x0B9C | [#x0B9E-#x0B9F] | [#x0BA3-#x0BA4] | 
  * [#x0BA8-#x0BAA] | [#x0BAE-#x0BB5] | [#x0BB7-#x0BB9] | [#x0C05-#x0C0C] | 
  * [#x0C0E-#x0C10] | [#x0C12-#x0C28] | [#x0C2A-#x0C33] | [#x0C35-#x0C39] | 
  * [#x0C60-#x0C61] | [#x0C85-#x0C8C] | [#x0C8E-#x0C90] | [#x0C92-#x0CA8] | 
  * [#x0CAA-#x0CB3] | [#x0CB5-#x0CB9] | #x0CDE | [#x0CE0-#x0CE1] | 
  * [#x0D05-#x0D0C] | [#x0D0E-#x0D10] | [#x0D12-#x0D28] | [#x0D2A-#x0D39] | 
  * [#x0D60-#x0D61] | [#x0E01-#x0E2E] | #x0E30 | [#x0E32-#x0E33] | 
  * [#x0E40-#x0E45] | [#x0E81-#x0E82] | #x0E84 | [#x0E87-#x0E88] | #x0E8A | 
  * #x0E8D | [#x0E94-#x0E97] | [#x0E99-#x0E9F] | [#x0EA1-#x0EA3] | #x0EA5 | 
  * #x0EA7 | [#x0EAA-#x0EAB] | [#x0EAD-#x0EAE] | #x0EB0 | [#x0EB2-#x0EB3] | 
  * #x0EBD | [#x0EC0-#x0EC4] | [#x0F40-#x0F47] | [#x0F49-#x0F69] | 
  * [#x10A0-#x10C5] | [#x10D0-#x10F6] | #x1100 | [#x1102-#x1103] | 
  * [#x1105-#x1107] | #x1109 | [#x110B-#x110C] | [#x110E-#x1112] | #x113C | 
  * #x113E | #x1140 | #x114C | #x114E | #x1150 | [#x1154-#x1155] | #x1159 | 
  * [#x115F-#x1161] | #x1163 | #x1165 | #x1167 | #x1169 | [#x116D-#x116E] | 
  * [#x1172-#x1173] | #x1175 | #x119E | #x11A8 | #x11AB | [#x11AE-#x11AF] | 
  * [#x11B7-#x11B8] | #x11BA | [#x11BC-#x11C2] | #x11EB | #x11F0 | #x11F9 | 
  * [#x1E00-#x1E9B] | [#x1EA0-#x1EF9] | [#x1F00-#x1F15] | [#x1F18-#x1F1D] | 
  * [#x1F20-#x1F45] | [#x1F48-#x1F4D] | [#x1F50-#x1F57] | #x1F59 | #x1F5B | 
  * #x1F5D | [#x1F5F-#x1F7D] | [#x1F80-#x1FB4] | [#x1FB6-#x1FBC] | #x1FBE | 
  * [#x1FC2-#x1FC4] | [#x1FC6-#x1FCC] | [#x1FD0-#x1FD3] | [#x1FD6-#x1FDB] | 
  * [#x1FE0-#x1FEC] | [#x1FF2-#x1FF4] | [#x1FF6-#x1FFC] | #x2126 | 
  * [#x212A-#x212B] | #x212E | [#x2180-#x2182] | [#x3041-#x3094] | 
  * [#x30A1-#x30FA] | [#x3105-#x312C] | [#xAC00-#xD7A3]  
  * Ideographic ::=  [#x4E00-#x9FA5] | #x3007 | [#x3021-#x3029]
  */
  bool letter = false;


  unsigned char c1 = *it;
  unsigned char c2 ;/* = *(it+1); */
  unsigned char c3 ;/* = *(it+2); */
  
  switch (numBytes)
  {
  case 1:
    if (c1 >= 65 && c1 <= 90)
    {
      letter = true;
    }
    else if (c1 >= 97 && c1 <= 122)
    {
      letter = true;
    }
  break;
  case 2:
    c2 = *(it+1);
    switch (c1)
    {
      case 224:
        if ((128 <= c2 && 150 >= c2)
        ||  (152 <= c2 && 182 >= c2)
        ||  (184 <= c2 && 191 >= c2))
        {
          letter = true;
        }
      break;
      case 196:
        if ((128 <= c2 && 177 >= c2)
        ||  (180 <= c2 && 190 >= c2))
        {
          letter = true;
        }
      break;
      case 197:
        if ((129 <= c2 && 136 >= c2)
        ||  (138 <= c2 && 190 >= c2))
        {
          letter = true;
        }
      break;
      case 198:
        if ((128 <= c2 && 191 >= c2))
        {
          letter = true;
        }
      break;
      case 199:
        if ((128 <= c2 && 131 >= c2)
        ||  (141 <= c2 && 176 >= c2)
        ||  (180 <= c2 && 181 >= c2)
        ||  (186 <= c2 && 191 >= c2))
        {
          letter = true;
        }
      break;
      case 200:
        if ((128 <= c2 && 151 >= c2))
        {
          letter = true;
        }
      break;
      case 201:
        if ((144 <= c2 && 191 >= c2))
        {
          letter = true;
        }
      break;
      case 202:
        if ((128 <= c2 && 168 >= c2)
        ||  (187 <= c2 && 191 >= c2))
        {
          letter = true;
        }
      break;
      case 203:
        if ((128 <= c2 && 129 >= c2))
        {
          letter = true;
        }
      break;
      case 206:
        if ((c2 == 134)
        ||  (136 <= c2 && 138 >= c2)
        ||  (c2 == 140)
        ||  (142 <= c2 && 161 >= c2)
        ||  (163 <= c2 && 191 >= c2))
        {
          letter = true;
        }
      break;
      case 207:
        if ((128 <= c2 && 142 >= c2)
        ||  (144 <= c2 && 150 >= c2)
        ||  (c2 == 154)
        ||  (c2 == 158)
        ||  (c2 == 160)
        ||  (162 <= c2 && 179 >= c2))
        {
          letter = true;
        }
      break;
      case 208:
        if ((129 <= c2 && 140 >= c2)
        ||  (142 <= c2 && 191 >= c2))
        {
          letter = true;
        }
      break;
      case 209:
        if ((128 <= c2 && 143 >= c2)
        ||  (145 <= c2 && 156 >= c2)
        ||  (158 <= c2 && 191 >= c2))
        {
          letter = true;
        }
      break;
      case 210:
        if ((128 <= c2 && 129 >= c2)
        ||  (144 <= c2 && 191 >= c2))
        {
          letter = true;
        }
      break;
      case 211:
        if ((128 <= c2 && 132 >= c2)
        ||  (135 <= c2 && 136 >= c2)
        ||  (139 <= c2 && 140 >= c2)
        ||  (144 <= c2 && 171 >= c2)
        ||  (174 <= c2 && 181 >= c2)
        ||  (184 <= c2 && 185 >= c2))
        {
          letter = true;
        }
      break;
      case 212:
        if ((177 <= c2 && 191 >= c2))
        {
          letter = true;
        }
      break;
      case 213:
        if ((128 <= c2 && 150 >= c2)
        ||  (c2 == 153)
        ||  (161 <= c2 && 191 >= c2))
        {
          letter = true;
        }
      break;
      case 214:
        if ((128 <= c2 && 134 >= c2))
        {
          letter = true;
        }
      break;
      case 215:
        if ((144 <= c2 && 170 >= c2)
        ||  (176 <= c2 && 178 >= c2))
        {
          letter = true;
        }
      break;
      case 216:
        if ((161 <= c2 && 186 >= c2))
        {
          letter = true;
        }
      break;
      case 217:
        if ((129 <= c2 && 138 >= c2)
        ||  (177 <= c2 && 191 >= c2))
        {
          letter = true;
        }
      break;
      case 218:
        if ((128 <= c2 && 183 >= c2)
        ||  (186 <= c2 && 190 >= c2))
        {
          letter = true;
        }
      break;
      case 219:
        if ((128 <= c2 && 142 >= c2)
        ||  (144 <= c2 && 147 >= c2)
        ||  (c2 == 149)
        ||  (165 <= c2 && 166 >= c2))
        {
          letter = true;
        }
        break;
    }
    break;
case 3:
  c2 = *(it+1);
  c3 = *(it+2);
  switch (c1)
  {
    case 224:
      switch (c2)
      {
        case 164:
          if ((133 <= c3 && 185 >= c3)
          ||  (c3 == 189))
          {
            letter = true;
          }
          break;
        case 165:
          if ((152 <= c3 && 161 >= c3))
          {
            letter = true;
          }
          break;
        case 166:
          if ((133 <= c3 && 140 >= c3)
          ||  (143 <= c3 && 144 >= c3)
          ||  (147 <= c3 && 168 >= c3)
          ||  (170 <= c3 && 176 >= c3)
          ||  (c3 == 178)
          ||  (182 <= c3 && 185 >= c3))
          {
            letter = true;
          }
          break;
        case 167:
          if ((156 <= c3 && 157 >= c3)
          ||  (159 <= c3 && 161 >= c3)
          ||  (176 <= c3 && 177 >= c3))
          {
            letter = true;
          }
          break;
        case 168:
          if ((133 <= c3 && 138 >= c3)
          ||  (143 <= c3 && 144 >= c3)
          ||  (147 <= c3 && 168 >= c3)
          ||  (170 <= c3 && 176 >= c3)
          ||  (178 <= c3 && 179 >= c3)
          ||  (181 <= c3 && 182 >= c3)
          ||  (184 <= c3 && 185 >= c3))
          {
            letter = true;
          }
          break;
        case 169:
          if ((153 <= c3 && 156 >= c3)
          ||  (c3 == 158)
          ||  (178 <= c3 && 180 >= c3))
          {
            letter = true;
          }
          break;
        case 170:
          if ((133 <= c3 && 139 >= c3)
          ||  (c3 == 141)
          ||  (143 <= c3 && 145 >= c3)
          ||  (147 <= c3 && 168 >= c3)
          ||  (170 <= c3 && 176 >= c3)
          ||  (178 <= c3 && 179 >= c3)
          ||  (181 <= c3 && 185 >= c3)
          ||  (c3 == 189))
          {
            letter = true;
          }
          break;
        case 171:
          if (c3 == 160)
          {
            letter = true;
          }
          break;
        case 172:
          if ((133 <= c3 && 140 >= c3)
          ||  (143 <= c3 && 144 >= c3)
          ||  (147 <= c3 && 168 >= c3)
          ||  (170 <= c3 && 176 >= c3)
          ||  (178 <= c3 && 179 >= c3)
          ||  (182 <= c3 && 185 >= c3)
          ||  (c3 == 189))
          {
            letter = true;
          }
          break;
        case 173:
          if ((156 <= c3 && 157 >= c3)
          ||  (159 <= c3 && 161 >= c3))
          {
            letter = true;
          }
          break;
        case 174:
          if ((133 <= c3 && 138 >= c3)
          ||  (142 <= c3 && 144 >= c3)
          ||  (146 <= c3 && 149 >= c3)
          ||  (153 <= c3 && 154 >= c3)
          ||  (c3 == 156)
          ||  (158 <= c3 && 159 >= c3)
          ||  (163 <= c3 && 164 >= c3)
          ||  (168 <= c3 && 170 >= c3)
          ||  (174 <= c3 && 181 >= c3)
          ||  (183 <= c3 && 185 >= c3))
          {
            letter = true;
          }
          break;
        case 176:
          if ((133 <= c3 && 140 >= c3)
          ||  (142 <= c3 && 144 >= c3)
          ||  (146 <= c3 && 168 >= c3)
          ||  (170 <= c3 && 179 >= c3)
          ||  (181 <= c3 && 185 >= c3))
          {
            letter = true;
          }
          break;
        case 177:
          if ((160 <= c3 && 161 >= c3))
          {
            letter = true;
          }
          break;
        case 178:
          if ((133 <= c3 && 140 >= c3)
          ||  (142 <= c3 && 144 >= c3)
          ||  (146 <= c3 && 168 >= c3)
          ||  (170 <= c3 && 179 >= c3)
          ||  (181 <= c3 && 185 >= c3))
          {
            letter = true;
          }
          break;
        case 179:
          if ((c3 == 158)
          ||  (160 <= c3 && 161 >= c3))
          {
            letter = true;
          }
          break;
        case 180:
          if ((133 <= c3 && 140 >= c3)
          ||  (142 <= c3 && 144 >= c3)
          ||  (146 <= c3 && 168 >= c3)
          ||  (170 <= c3 && 185 >= c3))
          {
            letter = true;
          }
          break;
        case 181:
          if ((160 <= c3 && 161 >= c3))
          {
            letter = true;
          }
          break;
        case 184:
          if ((129 <= c3 && 174 >= c3)
          ||  (c3 == 176)
          ||  (178 <= c3 && 179 >= c3))
          {
            letter = true;
          }
          break;
        case 185:
          if ((128 <= c3 && 133 >= c3))
          {
            letter = true;
          }
          break;
        case 186:
          if ((129 <= c3 && 130 >= c3)
          ||  (c3 == 132)
          ||  (135 <= c3 && 136 >= c3)
          ||  (c3 == 138)
          ||  (c3 == 141)
          ||  (148 <= c3 && 151 >= c3)
          ||  (153 <= c3 && 159 >= c3)
          ||  (161 <= c3 && 163 >= c3)
          ||  (c3 == 165)
          ||  (c3 == 167)
          ||  (170 <= c3 && 171 >= c3)
          ||  (173 <= c3 && 174 >= c3)
          ||  (c3 == 176)
          ||  (178 <= c3 && 179 >= c3)
          ||  (c3 == 189))
          {
            letter = true;
          }
          break;
        case 187:
          if ((128 <= c3 && 132 >= c3))
          {
            letter = true;
          }
          break;
        case 189:
          if ((128 <= c3 && 135 >= c3)
          ||  (137 <= c3 && 169 >= c3))
          {
            letter = true;
          }
          break;
        default:
          break;
        }
    break;
    case 225:
      switch (c2)
      {
        case 130:
          if ((160 <= c3 && 191 >= c3))
          {
            letter = true;
          }
          break;
        case 131:
          if ((128 <= c3 && 133 >= c3)
          ||  (144 <= c3 && 182 >= c3))
          {
            letter = true;
          }
          break;
        case 132:
          if ((c3 == 128)
          ||  (130 <= c3 && 131 >= c3)
          ||  (133 <= c3 && 135 >= c3)
          ||  (c3 == 137)
          ||  (139 <= c3 && 140 >= c3)
          ||  (142 <= c3 && 146 >= c3)
          ||  (c3 == 188)
          ||  (c3 == 190))
          {
            letter = true;
          }
          break;
        case 133:
          if ((c3 == 128)
          ||  (c3 == 140)
          ||  (c3 == 142)
          ||  (c3 == 144)
          ||  (148 <= c3 && 149 >= c3)
          ||  (c3 == 153)
          ||  (159 <= c3 && 161 >= c3)
          ||  (c3 == 163)
          ||  (c3 == 165)
          ||  (c3 == 167)
          ||  (c3 == 169)
          ||  (173 <= c3 && 174 >= c3)
          ||  (178 <= c3 && 179 >= c3)
          ||  (c3 == 181))
          {
            letter = true;
          }
          break;
        case 134:
          if ((c3 == 158)
          ||  (c3 == 168)
          ||  (c3 == 171)
          ||  (174 <= c3 && 175 >= c3)
          ||  (183 <= c3 && 184 >= c3)
          ||  (c3 == 186)
          ||  (188 <= c3 && 191 >= c3))
          {
            letter = true;
          }
          break;
        case 135:
          if ((128 <= c3 && 130 >= c3)
          ||  (c3 == 171)
          ||  (c3 == 176)
          ||  (c3 == 185))
          {
            letter = true;
          }
          break;
        case 184:
          if ((128 <= c3 && 191 >= c3))
          {
            letter = true;
          }
          break;
        case 185:
          if ((128 <= c3 && 191 >= c3))
          {
            letter = true;
          }
          break;
        case 186:
          if ((128 <= c3 && 155 >= c3)
          ||  (160 <= c3 && 191 >= c3))
          {
            letter = true;
          }
          break;
        case 187:
          if ((128 <= c3 && 185 >= c3))
          {
            letter = true;
          }
          break;
        case 188:
          if ((128 <= c3 && 149 >= c3)
          ||  (152 <= c3 && 157 >= c3)
          ||  (160 <= c3 && 191 >= c3))
          {
            letter = true;
          }
          break;
        case 189:
          if ((128 <= c3 && 133 >= c3)
          ||  (136 <= c3 && 141 >= c3)
          ||  (144 <= c3 && 151 >= c3)
          ||  (c3 == 153)
          ||  (c3 == 155)
          ||  (c3 == 157)
          ||  (159 <= c3 && 189 >= c3))
          {
            letter = true;
          }
          break;
        case 190:
          if ((128 <= c3 && 180 >= c3)
          ||  (182 <= c3 && 188 >= c3)
          ||  (c3 == 190))
          {
            letter = true;
          }
          break;
        case 191:
          if ((134 <= c3 && 140 >= c3)
          ||  (144 <= c3 && 147 >= c3)
          ||  (150 <= c3 && 155 >= c3)
          ||  (160 <= c3 && 172 >= c3)
          ||  (178 <= c3 && 180 >= c3)
          ||  (182 <= c3 && 188 >= c3))
          {
            letter = true;
          }
          break;
        default:
          break;
        }
    break;
    case 212:
      switch (c2)
      {
        case 191:
          if ((130 <= c3 && 132 >= c3))
          {
            letter = true;
          }
          break;
        default:
          break;
        }
    break;
    case 226:
      switch (c2)
      {
        case 132:
          if ((c3 == 166)
          ||  (170 <= c3 && 171 >= c3)
          ||  (c3 == 174))
          {
            letter = true;
          }
          break;
        case 134:
          if ((128 <= c3 && 130 >= c3))
          {
            letter = true;
          }
          break;
        default:
          break;
        }
    break;
    case 227:
      switch (c2)
      {
        case 128:
          if ((c3 == 135)
          ||  (161 <= c3 && 169 >= c3))
          {
            letter = true;
          }
          break;
        case 129:
          if ((129 <= c3 && 191 >= c3))
          {
            letter = true;
          }
          break;
        case 130:
          if ((128 <= c3 && 148 >= c3)
          ||  (161 <= c3 && 191 >= c3))
          {
            letter = true;
          }
          break;
        case 131:
          if ((128 <= c3 && 186 >= c3))
          {
            letter = true;
          }
          break;
        case 132:
          if ((133 <= c3 && 172 >= c3))
          {
            letter = true;
          }
          break;
       default:
          break;
        }
    break;
    case 228:
      if (c2 >= 184)
      {
        letter = true;
      }
    break;
    case 233:
      if (128 <= c2 && 189 >= c2)
      {
        letter = true;
      }
      else if (c2 == 190)
      {
        if (128 <= c3 && 165 >= c3)
        {
          letter = true;
        }
      }
    break;
    case 234:
      if (c2 >= 176)
      {
        letter = true;
      }
    break;
    case 229:
    case 230:
    case 231:
    case 232:
    case 235:
    case 236:
      {
        letter = true;
      }
    break;
    case 237:
      if (128 <= c2 && 157 >= c2)
      {
        letter = true;
      }
      else if (c2 == 158)
      {
        if (128 <= c3 && 163 >= c3)
        {
          letter = true;
        }
      }
    break;

    }
    break;
  default:
    break;
  }
      
  return letter; 
}

/** @endcond */


/** @cond doxygenLibsbmlInternal */
/*
  * Checks if a character is part of the Unicode Digit set.
  * @return true if the character is a part of the set, false otherwise.
  */
bool 
SyntaxChecker::isUnicodeDigit(std::string::iterator it, unsigned int numBytes)
{
  /*
  * Digit ::=  [#x0030-#x0039] | [#x0660-#x0669] | [#x06F0-#x06F9] | 
  * [#x0966-#x096F] | [#x09E6-#x09EF] | [#x0A66-#x0A6F] | [#x0AE6-#x0AEF] | 
  * [#x0B66-#x0B6F] | [#x0BE7-#x0BEF] | [#x0C66-#x0C6F] | [#x0CE6-#x0CEF] | 
  * [#x0D66-#x0D6F] | [#x0E50-#x0E59] | [#x0ED0-#x0ED9] | [#x0F20-#x0F29]    
  */
  bool digit = false;


  unsigned char c1 = *it;
  unsigned char c2 ;/* = *(it+1); */
  unsigned char c3 ;/* = *(it+2); */
  
  switch (numBytes)
  {
  case 1:
    if (48 <= c1 && 57 >= c1)
    {
      digit = true;
    }
    break;
  case 2:
    c2 = *(it+1);
    switch (c1)
    {
      case 217:
        if ((160 <= c2 && 169 >= c2))
        {
          digit = true;
        }
      break;
      case 219:
        if ((176 <= c2 && 185 >= c2))
        {
          digit = true;
        }
      break;
    }
    break;
  case 3:
  c2 = *(it+1);
  c3 = *(it+2);
  switch (c1)
  {
    case 224:
      switch (c2)
      {
        case 165:
          if ((166 <= c3 && 175 >= c3))
          {
            digit = true;
          }
          break;
        case 167:
          if ((166 <= c3 && 175 >= c3))
          {
            digit = true;
          }
          break;
        case 169:
          if ((166 <= c3 && 175 >= c3))
          {
            digit = true;
          }
          break;
        case 171:
          if ((166 <= c3 && 175 >= c3))
          {
            digit = true;
          }
          break;
        case 173:
          if ((166 <= c3 && 175 >= c3))
          {
            digit = true;
          }
          break;
        case 175:
          if ((167 <= c3 && 175 >= c3))
          {
            digit = true;
          }
          break;
        case 177:
          if ((166 <= c3 && 175 >= c3))
          {
            digit = true;
          }
          break;
        case 179:
          if ((166 <= c3 && 175 >= c3))
          {
            digit = true;
          }
          break;
        case 181:
          if ((166 <= c3 && 175 >= c3))
          {
            digit = true;
          }
          break;
        case 185:
          if ((144 <= c3 && 153 >= c3))
          {
            digit = true;
          }
          break;
        case 187:
          if ((144 <= c3 && 153 >= c3))
          {
            digit = true;
          }
          break;
        case 188:
          if ((160 <= c3 && 169 >= c3))
          {
            digit = true;
          }
          break;
      }

      break;
    default:
      break;
  }

  break;
  }
      
  return digit; 
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/**
  * Checks if a character is part of the Unicode CombiningChar set.
  * @return true if the character is a part of the set, false otherwise.
  */
bool 
SyntaxChecker::isCombiningChar(std::string::iterator it, unsigned int numBytes)
{
  bool combiningChar = false;

  /* combiningChar unicodes in UTF-8 decimal form

  UNICODE    UTF-8(1)  UTF-8(2)   UTF-8(3)
  #x0300 -    204      128 - 191
    #x0345    205      128 - 133
  #x0360 - 1  205      160 - 161
  #x0483 - 6  210      131 - 134
  #x0591 - A1 214      145 - 161
  #x05A3 - B9 214      163 - 185
  #x05BB - D  214      187 - 189
  #x05BF      214      191
  #x05C1 - 2  215      129 - 130
  #x05C4      215      132
  #x064B - 52 217      139 - 146
  #x0670      217      176
  #x06D6 - F  219      150 - 159
  #x06E0 - 4  219      160 - 164
  #x06E7 - 8  219      167 - 168
  #x06EA - D  219      170 - 173
  #x0901 - 3  224      164        129 - 131
  #x093C      224      164        188
  #x093E      224      164        190 - 191
        - 4C  224      165        128 - 140
  #x094D      224      165        141
  #x0951 - 4  224      165        145 - 148
  #x0962 - 3  224      165        162 - 163
  #x0981 - 3  224      166        129 - 131
  #x09BC      224      166        188
  #x09BE - F  224      166        190 - 191
  #x09C0 - 4  224      167        128 - 132
  #x09C7 - 8  224      167        135 - 136
  #x09CB - D  224      167        139 - 141
  #x09D7      224      167        151
  #x09E2 - 3  224      167        162 - 163
  #x0A02      224      168        130
  #x0A3C      224      168        188
  #x0A3E - F  224      168        190 - 191
  #x0A40 - 2  224      169        128 - 130
  #x0A47 - 8  224      169        135 - 136
  #x0A4B - D  224      169        139 - 141
  #x0A70 - 1  224      169        176 - 177
  #x0A81 - 3  224      170        129 - 131
  #x0ABC      224      170        188
  #x0ABE      224      170        190 - 191
     -    C5  224      171        128 - 133
  #x0AC7 - 9  224      171        135 - 137
  #x0ACB - D  224      171        139 - 141
  #x0B01 - 3  224      172        129 - 131
  #x0B3C      224      172        188
  #x0B3E      224      172        190 - 191
     -    43  224      173        128 - 131
  #x0B47 - 8  224      173        135 - 136
  #x0B4B - D  224      173        139 - 141
  #x0B56 - 7  224      173        150 - 151
  #x0B82 - 3  224      174        130 - 131
  #x0BBE      224      174        190 - 191
     -    C2  224      175        128 - 130
  #x0BC6 - 8  224      175        134 - 136
  #x0BCA - D  224      175        138 - 141
  #x0BD7      224      175        151
  #x0C01 - 3  224      176        129 - 131
  #x0C3E      224      176        190 - 191
     -    44  224      177        128 - 132
  #x0C46 - 8  224      177        134 - 136
  #x0C4A - D  224      177        138 - 141
  #x0C55 - 6  224      177        149 - 150
  #x0C82 - 3  224      178        130 - 131
  #x0CBE      224      178        190 - 191
     -    C4  224      179        128 - 132
  #x0CC6 - 8  224      179        134 - 136
  #x0CCA - D  224      179        138 - 141
  #x0CD5 - 6  224      179        149 - 150 
  #x0D02 - 3  224      180        130 - 131
  #x0D3E      224      180        190 - 191
     -    43  224      181        128 - 131
  #x0D46 - 8  224      181        134 - 136
  #x0D4A - D  224      181        138 - 141
  #x0D57      224      181        151
  #x0E31      224      184        177
  #x0E34 - A  224      184        180 - 186
  #x0E47 - E  224      185        135 - 142
  #x0EB1      224      186        177
  #x0EB4 - 9  224      186        180 - 185
  #x0EBB - C  224      186        187 - 188
  #x0EC8 - D  224      187        136 - 141
  #x0F18 - 9  224      188        152 - 153
  #x0F35      224      188        181
  #x0F37      224      188        183
  #x0F39      224      188        185
  #x0F3E - F  224      188        190 - 191
  #x0F71      224      189        177 - 191
     -    84  224      190        128 - 132
  #x0F86 - B  224      190        134 - 139
  #x0F90 - 5  224      190        144 - 149
  #x0F97      224      190        151
  #x0F99      224      190        153 - 
     -    AD  224      190              173
  #x0FB1 - 7  224      190        177 - 183
  #x0FB9      224      190        185
  #x20D0 - C  226      131        144 - 156
  #x20E1      226      131        161
  #x302A - F  227      128        170 - 175
  #x3099 - A  227      130        153 - 154

  */

  unsigned char c1 = *it;
  unsigned char c2 ;/* = *(it+1); */
  unsigned char c3 ;/* = *(it+2); */
  
  switch (numBytes)
  {
  case 2:
   c2 = *(it+1);
   if (c1 == 204)
    {
      if (c2 >= 128 && c2 <= 191)
      {
        combiningChar = true;
      }
    }
    else if (c1 == 205)
    {
      if (c2 >= 128 && c2 <= 133)
      {
        combiningChar = true;
      }
      else if ( c2 == 160 || c2 == 161)
      {
        combiningChar = true;
      }
    }
    else if (c1 == 210)
    {
      if (c2 >= 131 && c2 <= 134)
      {
        combiningChar = true;
      }
    }
    else if (c1 == 214)
    {
      if (c2 >= 145 && c2 <= 161)
      {
        combiningChar = true;
      }
      else if (c2 >= 163 && c2 <= 185)
      {
        combiningChar = true;
      }
      else if (c2 >= 187 && c2 <= 189)
      {
        combiningChar = true;
      }
      else if (c2 == 191)
      {
        combiningChar = true;
      }
    }
    else if (c1 == 215)
    {
      if (c2 >= 129 && c2 <= 130)
      {
        combiningChar = true;
      }
      else if (c2 == 132)
      {
        combiningChar = true;
      }
    }
    else if (c1 == 217)
    {
      if (c2 >= 139 && c2 <= 146)
      {
        combiningChar = true;
      }
      else if (c2 == 176)
      {
        combiningChar = true;
      }
    }
    else if (c1 == 219)
    {
      if (c2 >= 150 && c2 <= 159)
      {
        combiningChar = true;
      }
      else if (c2 >= 160 && c2 <= 164)
      {
        combiningChar = true;
      }
      else if (c2 >= 167 && c2 <= 168)
      {
        combiningChar = true;
      }
      else if (c2 >= 170 && c2 <= 173)
      {
        combiningChar = true;
      }
    }
    break;
  case 3:
    c2 = *(it+1);
    c3 = *(it+2);
    if (c1 == 226)
    { 
      if (c2 == 131)
      {
        if (c3 == 161
          || (144 <= c3 && 156 >= c3))
        {
          combiningChar = true;
        }
      }
    }
    else if (c1 == 227)
    {
      if (c2 == 128)
      {
        if (170 <= c3 && 175 >= c3)
        {
          combiningChar = true;
        }
      }
      else if (c2 == 130)
      {
        if (153 <= c3 && 154 >= c3)
        {
          combiningChar = true;
        }
      }
    }
    else if (c1 == 224)
    {
      switch (c2)
      {
      case 164:
        if (  (129 <= c3 && 131 >= c3)  ||
              (c3 == 188)               ||
              (190 <= c3 && 191 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 165:
        if (  (128 <= c3 && 140 >= c3)  ||
              (c3 == 141)               ||
              (145 <= c3 && 148 >= c3)  ||
              (162 <= c3 && 163 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 166:
        if (  (129 <= c3 && 131 >= c3)  ||
              (c3 == 188)               ||
              (190 <= c3 && 191 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 167:
        if (  (128 <= c3 && 132 >= c3)  ||
              (135 <= c3 && 136 >= c3)  ||
              (139 <= c3 && 141 >= c3)  ||
              (c3 == 151)               ||
              (162 <= c3 && 163 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 168:
        if (  (c3 == 130)               ||
              (c3 == 188)               ||
              (190 <= c3 && 191 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 169:
        if (  (128 <= c3 && 130 >= c3)  ||
              (135 <= c3 && 136 >= c3)  ||
              (139 <= c3 && 141 >= c3)  ||
              (176 <= c3 && 177 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 170:
        if (  (129 <= c3 && 131 >= c3)  ||
              (c3 == 188)               ||
              (190 <= c3 && 191 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 171:
        if (  (128 <= c3 && 130 >= c3)  ||
              (135 <= c3 && 137 >= c3)  ||
              (139 <= c3 && 141 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 172:
        if (  (129 <= c3 && 131 >= c3)  ||
              (c3 == 188)               ||
              (190 <= c3 && 191 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 173:
        if (  (128 <= c3 && 131 >= c3)  ||
              (135 <= c3 && 136 >= c3)  ||
              (139 <= c3 && 141 >= c3)  ||
              (150 <= c3 && 151 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 174:
        if (  (130 <= c3 && 131 >= c3)  ||
              (190 <= c3 && 191 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 175:
        if (  (128 <= c3 && 130 >= c3)  ||
              (134 <= c3 && 136 >= c3)  ||
              (138 <= c3 && 141 >= c3)  ||
              (c3 == 151)               )
        {
          combiningChar = true;
        }

        break;
      case 176:
        if (  (129 <= c3 && 131 >= c3)  ||
              (190 <= c3 && 191 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 177:
        if (  (128 <= c3 && 132 >= c3)  ||
              (134 <= c3 && 136 >= c3)  ||
              (138 <= c3 && 141 >= c3)  ||
              (149 <= c3 && 150 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 178:
        if (  (130 <= c3 && 131 >= c3)  ||
              (190 <= c3 && 191 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 179:
        if (  (128 <= c3 && 132 >= c3)  ||
              (134 <= c3 && 136 >= c3)  ||
              (138 <= c3 && 141 >= c3)  ||
              (149 <= c3 && 150 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 180:
        if (  (130 <= c3 && 131 >= c3)  ||
              (190 <= c3 && 191 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 181:
        if (  (128 <= c3 && 131 >= c3)  ||
              (134 <= c3 && 136 >= c3)  ||
              (138 <= c3 && 141 >= c3)  ||
              (c3 == 151)               )
        {
          combiningChar = true;
        }

        break;
      case 184:
        if (  (c3 == 170)               ||
              (180 <= c3 && 186 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 185:
        if (  (135 <= c3 && 142 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 186:
        if (  (c3 == 177)               ||
              (180 <= c3 && 185 >= c3)  ||
              (187 <= c3 && 188 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 187:
        if (  (136 <= c3 && 141 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 188:
        if (  (152 <= c3 && 153 >= c3)  ||
              (c3 == 181)               ||
              (c3 == 183)               ||
              (c3 == 185)               ||
              (190 <= c3 && 191 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 189:
        if (  (177 <= c3 && 191 >= c3)  )
        {
          combiningChar = true;
        }

        break;
      case 190:
        if (  (128 <= c3 && 132 >= c3)  ||
              (134 <= c3 && 139 >= c3)  ||
              (144 <= c3 && 149 >= c3)  ||
              (c3 == 151)               ||
              (153 <= c3 && 173 >= c3)  ||
              (177 <= c3 && 183 >= c3)  ||
              (c3 == 185)               )
        {
          combiningChar = true;
        }

        break;
      default:
        break;
      }

    }
  default:
    break;
  }
      
  return combiningChar; 
}
/** @endcond */


/** @cond doxygenLibsbmlInternal */
/**
  * Checks if a character is part of the Unicode Extender set.
  * @return true if the character is a part of the set, false otherwise.
  */
bool 
SyntaxChecker::isExtender(std::string::iterator it, unsigned int numBytes)
{
  bool extender = false;

  /* extender unicodes in UTF-8 decimal form

  UNICODE UTF-8(1)  UTF-8(2)  UTF-8(3)
  #x00B7  194       183
  #x02D0  203       144
  #x02D1  203       145
  #x0387  206       135
  #x0640  217       128
  #x0E46  224       185       134
  #x0EC6  224       187       134
  #x3005  227       128       133
  #x3031- 227       128       177-
  #x3035                      181
  #x309D  227       130       157
  #x309E  227       130       158
  #x30FC- 227       131       188-
  #x30FE                      190

  */

  unsigned char c1 = *it;
  unsigned char c2 ;/* = *(it+1); */
  unsigned char c3 ;/* = *(it+2); */
  
  switch (numBytes)
  {
  case 2:
    c2 = *(it+1);
    if (c1 == 194 && c2 == 183)
    {
      extender = true;
    }
    else if (c1 == 203)
    {
      if (c2 == 144 || c2 == 145)
      {
        extender = true;
      }
    }
    else if (c1 == 206 && c2 == 135)
    {
      extender = true;
    }
    else if (c1 == 217 && c2 == 128)
    {
      extender = true;
    }
    break;
  case 3:
    c2 = *(it+1);
    c3 = *(it+2);
    if (c1 == 224)
    {
      if (c2 == 185 || c2 == 187)
      {
        if (c3 == 134)
        {
          extender = true;
        }
      }
    }
    else if (c1 == 227)
    {
      if (c2 == 128)
      {
        if (c3 == 133 || (c3 >= 177 && c3 <= 181))
        {
          extender = true;
        }
      }
      else if (c2 == 130)
      {
        if (c3 == 157 || c3 == 158)
        {
          extender = true;
        }
      }
      else if (c2 == 131)
      {
         if (c3 >= 188 && c3 <= 190)
        {
          extender = true;
        }
     }
    }
  default:
    break;
  }
      
  return extender; 
}
/** @endcond */

#endif /* __cplusplus */
/** @cond doxygenIgnored */

LIBSBML_EXTERN
int
SyntaxChecker_isValidSBMLSId(const char * sid)
{
  return static_cast<int>((sid == NULL) ? 
    SyntaxChecker::isValidSBMLSId("") : SyntaxChecker::isValidSBMLSId(sid));
}


LIBSBML_EXTERN
int
SyntaxChecker_isValidXMLID(const char * id)
{
  return static_cast<int>((id == NULL) ? 
    SyntaxChecker::isValidXMLID("") : SyntaxChecker::isValidXMLID(id));
}


LIBSBML_EXTERN
int
SyntaxChecker_isValidUnitSId(const char * units)
{
  return static_cast<int>((units == NULL) ? 
    SyntaxChecker::isValidUnitSId("") : SyntaxChecker::isValidUnitSId(units));
}


LIBSBML_EXTERN
int
SyntaxChecker_hasExpectedXHTMLSyntax(XMLNode_t * node, 
                                     SBMLNamespaces_t * sbmlns)
{
  return (node != NULL) ? static_cast<int>
    (SyntaxChecker::hasExpectedXHTMLSyntax(node, sbmlns)) : 0;
}

LIBSBML_CPP_NAMESPACE_END

/** @endcond */

