/**
 * @file    XMLNode.cpp
 * @brief   A node in an XML document tree
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

#include <sbml/util/memory.h>
#include <sbml/util/util.h>

/** @cond doxygenLibsbmlInternal */
#include <sbml/xml/XMLInputStream.h>
#include <sbml/xml/XMLOutputStream.h>
#include <sbml/xml/XMLConstructorException.h>
/** @endcond */

#include <sbml/xml/XMLNode.h>

/** @cond doxygenIgnored */

using namespace std;

/** @endcond */

LIBSBML_CPP_NAMESPACE_BEGIN
#ifdef __cplusplus

/*
 * @return s with whitespace removed from the beginning and end.
 */
static const string
trim (const string& s)
{
  static const string whitespace(" \t\r\n");

  string::size_type begin = s.find_first_not_of(whitespace);
  string::size_type end   = s.find_last_not_of (whitespace);

  return (begin == string::npos) ? std::string() : s.substr(begin, end - begin + 1);
}


/*
 * Creates a new empty XMLNode with no children.
 */
XMLNode::XMLNode ()
{
}


/*
 * Destroys this XMLNode.
 */
XMLNode::~XMLNode ()
{
}


/*
 * Creates a new XMLNode by copying token.
 */
XMLNode::XMLNode (const XMLToken& token) : XMLToken(token)
{
}


/*
 * Creates a new start element XMLNode with the given set of attributes and
 * namespace declarations.
 */
XMLNode::XMLNode (  const XMLTriple&     triple
                  , const XMLAttributes& attributes
                  , const XMLNamespaces& namespaces
                  , const unsigned int   line
                  , const unsigned int   column) 
                  : XMLToken(triple, attributes, namespaces, line, column)
{
}


/*
 * Creates a start element XMLNode with the given set of attributes.
 */
XMLNode::XMLNode (  const XMLTriple&      triple
                  , const XMLAttributes&  attributes
                  , const unsigned int    line
                  , const unsigned int    column )
                  : XMLToken(triple, attributes, line, column)
{
}  


/*
 * Creates an end element XMLNode with the given set of attributes.
 */
XMLNode::XMLNode (  const XMLTriple&   triple
                  , const unsigned int line
                  , const unsigned int column )
                  : XMLToken(triple, line, column)
{
}


/*
 * Creates a text XMLNode.
 */
XMLNode::XMLNode (  const std::string& chars
                  , const unsigned int line
                  , const unsigned int column )
                  : XMLToken(chars, line, column)
{
}


/** @cond doxygenLibsbmlInternal */
/*
 * Creates a new XMLNode by reading XMLTokens from stream.  The stream must
 * be positioned on a start element (stream.peek().isStart() == true) and
 * will be read until the matching end element is found.
 */
XMLNode::XMLNode (XMLInputStream& stream) : XMLToken( stream.next() )
{
  if ( isEnd() ) return;

  std::string s;

  while ( stream.isGood() )
  {
    const XMLToken& next = stream.peek();


    if ( next.isStart() )
    {
      addChild( XMLNode(stream) );
    }
    else if ( next.isText() )
    {
      s = trim(next.getCharacters());
      if (s != "")
        addChild( stream.next() );
      else
        stream.skipText();
    }
    else if ( next.isEnd() )
    {
      stream.next();
      break;
    }
  }
}
/** @endcond */


/*
 * Copy constructor; creates a copy of this XMLNode.
 */
XMLNode::XMLNode(const XMLNode& orig):
      XMLToken (orig)
{
  this->mChildren.assign( orig.mChildren.begin(), orig.mChildren.end() ); 
}


 /*
  * Assignment operator for XMLNode.
  */
XMLNode& 
XMLNode::operator=(const XMLNode& rhs)
{
  if (&rhs == NULL)
  {
    throw XMLConstructorException("Null argument to assignment operator");
  }
  else if(&rhs!=this)
  {
    this->XMLToken::operator=(rhs);
    this->mChildren.assign( rhs.mChildren.begin(), rhs.mChildren.end() ); 
  }

  return *this;
}

/*
 * Creates and returns a deep copy of this XMLNode.
 * 
 * @return a (deep) copy of this XMLNode.
 */
XMLNode* 
XMLNode::clone () const
{
  return new XMLNode(*this);
}


/*
 * Adds a copy of child node to this XMLNode.
 */
int
XMLNode::addChild (const XMLNode& node)
{
  /* catch case where node is NULL
   */
  if (&(node) == NULL)
  {
    return LIBSBML_OPERATION_FAILED;
  }

  if (isStart())
  {
    mChildren.push_back(node);
    /* need to catch the case where this node is both a start and
    * an end element
    */
    if (isEnd()) unsetEnd();
    return LIBSBML_OPERATION_SUCCESS;
  }
  else if (isEOF())
  {
    mChildren.push_back(node);
    // this causes strange things to happen when node is written out
    //   this->mIsStart = true;
    return LIBSBML_OPERATION_SUCCESS;
  }
  else
  {
    return LIBSBML_INVALID_XML_OPERATION;
  }

}


/*
 * Inserts a copy of child node as the nth child of this XMLNode.
 */
XMLNode&
XMLNode::insertChild (unsigned int n, const XMLNode& node)
{
  /* catch case where node is NULL
   */
  if (&(node) == NULL)
  {
    return const_cast<XMLNode&>(node);
  }

  unsigned int size = (unsigned int)mChildren.size();

  if ( (n >= size) || (size == 0) )
  {
    mChildren.push_back(node);
    return mChildren.back();
  }

  return *(mChildren.insert(mChildren.begin() + n, node));
}


/*
 * Removes the nth child of this XMLNode and returned the removed node.
 * The caller owns the returned node and is responsible for deleting it.
 *
 * @return the removed child, or NULL if the given index is out of range. 
 */
XMLNode* 
XMLNode::removeChild(unsigned int n)
{
  XMLNode* rval = NULL;

  if ( n < getNumChildren() )
  {
    rval = mChildren[n].clone();
    mChildren.erase(mChildren.begin() + n);
  }
  
  return rval;
}

/* 
 * remove all children
 */
int
XMLNode::removeChildren()
{
  mChildren.clear(); 
  return LIBSBML_OPERATION_SUCCESS;
}


/*
 * Returns the nth child of this XMLNode.
 */
XMLNode&
XMLNode::getChild (unsigned int n)
{
   return const_cast<XMLNode&>( 
            static_cast<const XMLNode&>(*this).getChild(n)
          );
}


/*
 * Returns the nth child of this XMLNode.
 */
const XMLNode&
XMLNode::getChild (unsigned int n) const
{
  static const XMLNode outOfRange;

  unsigned int size = getNumChildren();
  if ( (n < size) && (size > 0) )
  {
    return mChildren[n];
  }
  else
  {
    // An empty XMLNode object, which is neither start node, 
    // end node, nor text node, returned if the given index 
    // is out of range. 
    // Currently, this object is allocated as a static object
    // to avoid a memory leak.
    // This may be fixed in the futrure release.
    return outOfRange;
  }
}

/**
 * Returns the first child of this XMLNode with the corresponding name.
 *
 * If no child with corrsponding name can be found, 
 * this method returns an empty node.
 *
 * @param name the name of the node to return
 * 
 * @return the first child of this XMLNode with given name.
 */
XMLNode&
XMLNode::getChild (const std::string&  name)
{
  return const_cast<XMLNode&>( 
                static_cast<const XMLNode&>(*this).getChild(name)
                );
}
/**
 * Returns the first child of this XMLNode with the corresponding name.
 *
 * If no child with corrsponding name can be found, 
 * this method returns an empty node.
 *
 * @param name the name of the node to return
 * 
 * @return the first child of this XMLNode with given name.
 */
const XMLNode& 
XMLNode::getChild (const std::string&  name) const
{
  static const XMLNode outOfRange;
  int index = getIndex(name);
  if (index != -1)
  {
    return getChild((unsigned int)index);
  }
  else 
  {
    // An empty XMLNode object, which is neither start node, 
    // end node, nor text node, returned if the given index 
    // is out of range. 
    // Currently, this object is allocated as a static object
    // to avoid a memory leak.
    // This may be fixed in the futrure release.
    return outOfRange;
  }

}

/**
 * Return the index of the first child of this XMLNode with the given name.
 *
 *
 * @param name a string, the name of the child for which the 
 * index is required.
 *
 * @return the index of the first child of this XMLNode with the given name, or -1 if not present.
 */
int
XMLNode::getIndex (const std::string& name) const
{
  if (&name == NULL) return -1;

  for (unsigned int index = 0; index < getNumChildren(); ++index)
  {
    if (getChild(index).getName() == name) return index;
  }
  
  return -1;
}

/**
 * Compare this XMLNode against another XMLNode returning true if both nodes
 * represent the same XML tree, or false otherwise.
 *
 *
 * @param other another XMLNode to compare against
 *
 * @return boolean indicating whether this XMLNode represents the same XML tree as another.
 */
bool 
XMLNode::equals(const XMLNode& other, bool ignoreURI /*=false*/) const
{
  if (&other == NULL) return false;

  bool equal;//=true;
  // check if the nodes have the same name,
  equal=getName()==other.getName();
  if (!equal) return false;
  // the same namespace uri, 
  equal=(ignoreURI ||  getURI()==other.getURI());
  if (!equal) return false;

  XMLAttributes attr1=getAttributes(); 
  XMLAttributes attr2=other.getAttributes();
  int i=0,iMax=attr1.getLength();
  //the same attributes and the same number of children
  equal=(iMax==attr2.getLength());
  std::string attrName;
  while(equal && i<iMax)
  {
    attrName=attr1.getName(i);
    equal=(attr2.getIndex(attrName)!=-1);
    // also check the namspace
    equal=(equal && (attr1.getURI(i)==attr2.getURI(i) 
      || (attr1.getPrefix(i) == "" && getURI() == attr2.getURI(i))
      || (attr2.getPrefix(i) == "" && other.getURI() == attr1.getURI(i))
      ));
    ++i;
  }

  // recursively check all children
  i=0;
  iMax=getNumChildren();
  equal=(equal && (iMax==(int)other.getNumChildren()));
  while(equal && i<iMax)
  {
    equal=getChild(i).equals(other.getChild(i), ignoreURI);
    ++i;
  }
  return equal; 
}


/**
 * Return a boolean indicating whether this XMLNode has a child with the given name.
 *
 *
 * @param name a string, the name of the child to be checked.
 *
 * @return boolean indicating whether this XMLNode has a child with the given name.
 */
bool 
XMLNode::hasChild (const std::string& name) const
{
  return getIndex(name) != -1;
}

/*
 * @return the number of children for this XMLNode.
 */
unsigned int
XMLNode::getNumChildren () const
{
  return (unsigned int)mChildren.size();
}


/** @cond doxygenLibsbmlInternal */
/*
 * Writes this XMLNode and its children to stream.
 */
void
XMLNode::write (XMLOutputStream& stream) const
{
  if (&stream == NULL) return;

  unsigned int children = getNumChildren();

  XMLToken::write(stream);

  if (children > 0)
  {
    bool haveTextNode = false;
    for (unsigned int c = 0; c < children; ++c) 
    {
        const XMLNode& current = getChild(c);
        stream << current;
        haveTextNode |= current.isText();
    }

    if (!mTriple.isEmpty())
    {
      // edge case ... we have an element with a couple of elements, and 
      // one is a text node (ugly!) in this case we can get a hanging
      // indent ... so we downindent ... 
      if (children > 1 && haveTextNode)
      {
        stream.downIndent();
      }
      stream.endElement( mTriple );
    }
  }
  else if ( isStart() && !isEnd() ) 
  {
    stream.endElement( mTriple );
  }

}
/** @endcond */


/*
 * Returns a string which is converted from this XMLNode.
 */
std::string XMLNode::toXMLString() const
{
  std::ostringstream oss;
  XMLOutputStream xos(oss,"UTF-8",false);
  write(xos);

  return oss.str();
}


/*
 * Returns a string which is converted from a given XMLNode.
 */
std::string XMLNode::convertXMLNodeToString(const XMLNode* xnode)
{
  if(xnode == NULL) return "";

  std::ostringstream oss;
  XMLOutputStream xos(oss,"UTF-8",false);
  xnode->write(xos);

  return oss.str();
}


/*
 * Returns a XMLNode which is converted from a given string.
 */
XMLNode* XMLNode::convertStringToXMLNode(const std::string& xmlstr, const XMLNamespaces* xmlns)
{
  if (&xmlstr == NULL) return NULL;

  XMLNode* xmlnode     = NULL;
  std::ostringstream oss;
  const char* dummy_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
  const char* dummy_element_start = "<dummy";
  const char* dummy_element_end   = "</dummy>";


  oss << dummy_xml;
  oss << dummy_element_start;
  if(xmlns != NULL)
  {
    for(int i=0; i < xmlns->getLength(); i++)
    {
      oss << " xmlns";
      if(xmlns->getPrefix(i) != "") oss << ":" << xmlns->getPrefix(i);
      oss << "=\"" << xmlns->getURI(i) << '"';
    }
  }
  oss << ">";
  oss << xmlstr;
  oss << dummy_element_end;


  const char* xmlstr_c = safe_strdup(oss.str().c_str());
  XMLInputStream xis(xmlstr_c,false);
  XMLNode* xmlnode_tmp = new XMLNode(xis);

  if(xis.isError() || (xmlnode_tmp->getNumChildren() == 0) )
  {
    delete xmlnode_tmp;
    return NULL;
  }


  /**
   * this is fine if the first child is a parent element
   * it actually falls down if all your elements have equal footing
   * eg 
   *  <p>The following is MathML markup:</p>
   *  <p xmlns="http://www.w3.org/1999/xhtml"> Test2 </p>
   */

  if (xmlnode_tmp->getNumChildren() == 1)
  {
    xmlnode = new XMLNode(xmlnode_tmp->getChild(0));
  }
  else
  {
    xmlnode = new XMLNode();
    for(unsigned int i=0; i < xmlnode_tmp->getNumChildren(); i++)
    {
      xmlnode->addChild(xmlnode_tmp->getChild(i));
    }
  }

  delete xmlnode_tmp;
  safe_free(const_cast<char*>(xmlstr_c));

  return xmlnode;
}


/** @cond doxygenLibsbmlInternal */
/*
 * Inserts this XMLNode and its children into stream.
 */
LIBLAX_EXTERN
XMLOutputStream& operator<< (XMLOutputStream& stream, const XMLNode& node)
{
  node.write(stream);
  return stream;
}
/** @endcond */


#endif /* __cplusplus */
/** @cond doxygenIgnored */


LIBLAX_EXTERN
XMLNode_t *
XMLNode_create (void)
{
  return new(nothrow) XMLNode;
}


LIBLAX_EXTERN
XMLNode_t *
XMLNode_createFromToken (const XMLToken_t *token)
{
  if (token == NULL) return NULL;
  return new(nothrow) XMLNode(*token);
}


LIBLAX_EXTERN
XMLNode_t *
XMLNode_createStartElement  (const XMLTriple_t *triple,
                             const XMLAttributes_t *attr)
{
  if (triple == NULL || attr == NULL) return NULL;
  return new(nothrow) XMLNode(*triple, *attr);
}


LIBLAX_EXTERN
XMLNode_t *
XMLNode_createStartElementNS (const XMLTriple_t     *triple,
                              const XMLAttributes_t *attr,
                              const XMLNamespaces_t *ns)
{
  if (triple == NULL || attr == NULL || ns == NULL) return NULL;
  return new(nothrow) XMLNode(*triple, *attr, *ns);
}


LIBLAX_EXTERN
XMLNode_t *
XMLNode_createEndElement (const XMLTriple_t *triple)
{
  if (triple == NULL) return NULL;
  return new(nothrow) XMLNode(*triple);
}


LIBLAX_EXTERN
XMLNode_t *
XMLNode_createTextNode (const char *text)
{
  return (text != NULL) ? new(nothrow) XMLNode(text) : new(nothrow) XMLNode;
}


#if 0

/**
 * Creates a new XMLNode_t structure by reading XMLTokens from stream.  
 *
 * The stream must
 * be positioned on a start element (stream.peek().isStart() == true) and
 * will be read until the matching end element is found.
 *
 * @param stream XMLInputStream from which XMLNode_t structure is to be created.
 *
 * @return pointer to the new XMLNode_t structure.
 */
LIBLAX_EXTERN
XMLNode_t *
XMLNode_createFromStream (XMLInputStream_t *stream)
{
  return new(nothrow) XMLNode(stream);
}

#endif

LIBLAX_EXTERN
XMLNode_t *
XMLNode_clone (const XMLNode_t* n)
{
  if (n == NULL) return NULL;
  return static_cast<XMLNode*>( n->clone() );
}


LIBLAX_EXTERN
void
XMLNode_free (XMLNode_t *node)
{
  if (node == NULL) return;
  delete static_cast<XMLNode*>(node);
}


LIBLAX_EXTERN
int
XMLNode_addChild (XMLNode_t *node, const XMLNode_t *child)
{
  if (node == NULL || child == NULL) return LIBSBML_INVALID_OBJECT;
  return node->addChild(*child);
}


LIBLAX_EXTERN
XMLNode_t*
XMLNode_insertChild (XMLNode_t *node, unsigned int n, const XMLNode_t *child)
{
  if (node == NULL || child == NULL )
  {
    return NULL;
  }

  return &(node->insertChild(n, *child));
}


LIBLAX_EXTERN
XMLNode_t* 
XMLNode_removeChild(XMLNode_t *node, unsigned int n)
{
  if (node == NULL) return NULL;
  return node->removeChild(n);
}


LIBLAX_EXTERN
int
XMLNode_removeChildren (XMLNode_t *node)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->removeChildren();
}


LIBLAX_EXTERN
const char *
XMLNode_getCharacters (const XMLNode_t *node)
{
  if (node == NULL) return NULL;
  return node->getCharacters().empty() ? NULL : node->getCharacters().c_str();
}


LIBLAX_EXTERN
int 
XMLNode_setTriple(XMLNode_t *node, const XMLTriple_t *triple)
{
  if(node == NULL || triple == NULL) return LIBSBML_INVALID_OBJECT;
  return node->setTriple(*triple);
}


LIBLAX_EXTERN
const char *
XMLNode_getName (const XMLNode_t *node)
{
  if (node == NULL) return NULL;
  return node->getName().empty() ? NULL : node->getName().c_str();
}


LIBLAX_EXTERN
const char *
XMLNode_getPrefix (const XMLNode_t *node)
{
  if (node == NULL) return NULL;
  return node->getPrefix().empty() ? NULL : node->getPrefix().c_str();
}


LIBLAX_EXTERN
const char *
XMLNode_getURI (const XMLNode_t *node)
{
  if (node == NULL) return NULL;
  return node->getURI().empty() ? NULL : node->getURI().c_str();
}


LIBLAX_EXTERN
const XMLNode_t *
XMLNode_getChild (const XMLNode_t *node, const int n)
{
  if (node == NULL) return NULL;
  return &(node->getChild(n));
}


LIBLAX_EXTERN
XMLNode_t *
XMLNode_getChildNC (XMLNode_t *node, const unsigned int n)
{
  if (node == NULL) return NULL;
  return &(node->getChild(n));
}

LIBLAX_EXTERN
XMLNode_t *
XMLNode_getChildForNameNC (XMLNode_t *node, const char*  name)
{
  if (node == NULL) return NULL;
  return &(node->getChild(name));
}

LIBLAX_EXTERN
const XMLNode_t *
XMLNode_getChildForName (const XMLNode_t *node, const char*  name)
{
  if (node == NULL) return NULL;
  return &(node->getChild(name));
}

LIBLAX_EXTERN
int 
XMLNode_getIndex (const XMLNode_t *node, const char*  name)
{
  if (node == NULL) return -1;
  return (node->getIndex(name));
}

LIBLAX_EXTERN
int 
XMLNode_hasChild (const XMLNode_t *node, const char*  name)
{
  if (node == NULL) return (int)false;
  return static_cast<int>( node->hasChild(name) );
}

LIBLAX_EXTERN
int 
XMLNode_equals(const XMLNode_t *node, const XMLNode_t* other)
{
  if (node == NULL && other == NULL) return (int)true;
  if (node == NULL || other == NULL) return (int)false;
  return static_cast<int>( node->equals(*other) );
}

LIBLAX_EXTERN
unsigned int
XMLNode_getNumChildren (const XMLNode_t *node)
{
  if (node == NULL) return 0;
  return node->getNumChildren();
}


LIBLAX_EXTERN
const XMLAttributes_t *
XMLNode_getAttributes (const XMLNode_t *node)
{
  if (node == NULL) return NULL;
  return &(node->getAttributes());
}


LIBLAX_EXTERN
int 
XMLNode_setAttributes(XMLNode_t *node, const XMLAttributes_t* attributes)
{
  if (node == NULL || attributes == NULL) return LIBSBML_INVALID_OBJECT;
  return node->setAttributes(*attributes);
}


LIBLAX_EXTERN
int 
XMLNode_addAttr ( XMLNode_t *node,  const char* name, const char* value )
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->addAttr(name, value, "", "");
}


LIBLAX_EXTERN
int 
XMLNode_addAttrWithNS ( XMLNode_t *node,  const char* name
                        , const char* value
                        , const char* namespaceURI
                        , const char* prefix      )
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->addAttr(name, value, namespaceURI, prefix);
}



LIBLAX_EXTERN
int 
XMLNode_addAttrWithTriple (XMLNode_t *node, const XMLTriple_t *triple, const char* value)
{
  if (node == NULL || triple == NULL) return LIBSBML_INVALID_OBJECT;
  return node->addAttr(*triple, value);
}


LIBLAX_EXTERN
int 
XMLNode_removeAttr (XMLNode_t *node, int n)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->removeAttr(n);
}


LIBLAX_EXTERN
int 
XMLNode_removeAttrByName (XMLNode_t *node, const char* name)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->removeAttr(name, "");
}


LIBLAX_EXTERN
int 
XMLNode_removeAttrByNS (XMLNode_t *node, const char* name, const char* uri)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->removeAttr(name, uri);
}


LIBLAX_EXTERN
int 
XMLNode_removeAttrByTriple (XMLNode_t *node, const XMLTriple_t *triple)
{
  if (node == NULL || triple == NULL) return LIBSBML_INVALID_OBJECT;
  return node->removeAttr(*triple);
}


LIBLAX_EXTERN
int 
XMLNode_clearAttributes(XMLNode_t *node)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->clearAttributes();
}



LIBLAX_EXTERN
int 
XMLNode_getAttrIndex (const XMLNode_t *node, const char* name, const char* uri)
{
  if (node == NULL) return -1;
  return node->getAttrIndex(name, uri);
}


LIBLAX_EXTERN
int 
XMLNode_getAttrIndexByTriple (const XMLNode_t *node, const XMLTriple_t *triple)
{
  if (node == NULL || triple == NULL) return -1;
  return node->getAttrIndex(*triple);
}


LIBLAX_EXTERN
int 
XMLNode_getAttributesLength (const XMLNode_t *node)
{
  if (node == NULL) return 0;
  return node->getAttributesLength();
}


LIBLAX_EXTERN
char* 
XMLNode_getAttrName (const XMLNode_t *node, int index)
{
  if (node == NULL) return NULL;
  
  const std::string str = node->getAttrName(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLNode_getAttrPrefix (const XMLNode_t *node, int index)
{
  if (node == NULL) return NULL;

  const std::string str = node->getAttrPrefix(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLNode_getAttrPrefixedName (const XMLNode_t *node, int index)
{
  if (node == NULL) return NULL;

  const std::string str = node->getAttrPrefixedName(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLNode_getAttrURI (const XMLNode_t *node, int index)
{
  if (node == NULL) return NULL;
  const std::string str = node->getAttrURI(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLNode_getAttrValue (const XMLNode_t *node, int index)
{
  if (node == NULL) return NULL;

  const std::string str = node->getAttrValue(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}



LIBLAX_EXTERN
char* 
XMLNode_getAttrValueByName (const XMLNode_t *node, const char* name)
{
  if (node == NULL) return NULL;

  const std::string str = node->getAttrValue(name, "");

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLNode_getAttrValueByNS (const XMLNode_t *node, const char* name, const char* uri)
{
  if (node == NULL) return NULL;
  const std::string str = node->getAttrValue(name, uri);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLNode_getAttrValueByTriple (const XMLNode_t *node, const XMLTriple_t *triple)
{
  if (node == NULL || triple == NULL) return NULL;
  const std::string str = node->getAttrValue(*triple);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
int
XMLNode_hasAttr (const XMLNode_t *node, int index)
{
  if (node == NULL) return (int)false;
  return node->hasAttr(index);
}


LIBLAX_EXTERN
int
XMLNode_hasAttrWithName (const XMLNode_t *node, const char* name)
{
  if (node == NULL) return (int)false;
  return node->hasAttr(name, "");
}


LIBLAX_EXTERN
int
XMLNode_hasAttrWithNS (const XMLNode_t *node, const char* name, const char* uri)
{
  if (node == NULL) return (int)false;
  return node->hasAttr(name, uri);
}


LIBLAX_EXTERN
int
XMLNode_hasAttrWithTriple (const XMLNode_t *node, const XMLTriple_t *triple)
{
  if (node == NULL || triple == NULL) return (int)false;
  return node->hasAttr(*triple);
}


LIBLAX_EXTERN
int
XMLNode_isAttributesEmpty (const XMLNode_t *node)
{
  if (node == NULL) return (int)false;
  return node->isAttributesEmpty();
}



LIBLAX_EXTERN
const XMLNamespaces_t *
XMLNode_getNamespaces (const XMLNode_t *node)
{
  if (node == NULL) return NULL;
  return &(node->getNamespaces());
}


LIBLAX_EXTERN
int 
XMLNode_setNamespaces(XMLNode_t *node, const XMLNamespaces_t* namespaces)
{
  if (node == NULL || namespaces == NULL) return LIBSBML_INVALID_OBJECT;
  return node->setNamespaces(*namespaces);
}


LIBLAX_EXTERN
int 
XMLNode_addNamespace (XMLNode_t *node, const char* uri, const char* prefix)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->addNamespace(uri, prefix);
}


LIBLAX_EXTERN
int 
XMLNode_removeNamespace (XMLNode_t *node, int index)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->removeNamespace(index);
}


LIBLAX_EXTERN
int 
XMLNode_removeNamespaceByPrefix (XMLNode_t *node, const char* prefix)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->removeNamespace(prefix);
}


LIBLAX_EXTERN
int 
XMLNode_clearNamespaces (XMLNode_t *node)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->clearNamespaces();
}


LIBLAX_EXTERN
int 
XMLNode_getNamespaceIndex (const XMLNode_t *node, const char* uri)
{
  if (node == NULL) return -1;
  return node->getNamespaceIndex(uri);
}


LIBLAX_EXTERN
int 
XMLNode_getNamespaceIndexByPrefix (const XMLNode_t *node, const char* prefix)
{
  if (node == NULL) return -1;
  return node->getNamespaceIndexByPrefix(prefix);
}


LIBLAX_EXTERN
int 
XMLNode_getNamespacesLength (const XMLNode_t *node)
{
  if (node == NULL) return 0;
  return node->getNamespacesLength();
}


LIBLAX_EXTERN
char* 
XMLNode_getNamespacePrefix (const XMLNode_t *node, int index)
{
  if (node == NULL) return NULL;
  const std::string str = node->getNamespacePrefix(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLNode_getNamespacePrefixByURI (const XMLNode_t *node, const char* uri)
{
  if (node == NULL) return NULL;
  const std::string str = node->getNamespacePrefix(uri);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLNode_getNamespaceURI (const XMLNode_t *node, int index)
{
  if (node == NULL) return NULL;
  const std::string str = node->getNamespaceURI(index);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
char* 
XMLNode_getNamespaceURIByPrefix (const XMLNode_t *node, const char* prefix)
{
  if (node == NULL) return NULL;
  const std::string str = node->getNamespaceURI(prefix);

  return str.empty() ? NULL : safe_strdup(str.c_str());
}


LIBLAX_EXTERN
int
XMLNode_isNamespacesEmpty (const XMLNode_t *node)
{
  if (node == NULL) return (int)false;
  return node->isNamespacesEmpty();
}


LIBLAX_EXTERN
int
XMLNode_hasNamespaceURI(const XMLNode_t *node, const char* uri)
{
  if (node == NULL) return (int) false;
  return node->hasNamespaceURI(uri);
}


LIBLAX_EXTERN
int
XMLNode_hasNamespacePrefix(const XMLNode_t *node, const char* prefix)
{
  if (node == NULL) return (int)false;
  return node->hasNamespacePrefix(prefix);
}


LIBLAX_EXTERN
int
XMLNode_hasNamespaceNS(const XMLNode_t *node, const char* uri, const char* prefix)
{
  if (node == NULL) return (int)false;
  return node->hasNamespaceNS(uri, prefix);
}



LIBLAX_EXTERN
char *
XMLNode_toXMLString(const XMLNode_t *node)
{
  if (node == NULL) return NULL;
  return safe_strdup(node->toXMLString().c_str());
}


LIBLAX_EXTERN
const char *
XMLNode_convertXMLNodeToString(const XMLNode_t *node)
{
  if (node == NULL) return NULL;
  return safe_strdup((XMLNode::convertXMLNodeToString(node)).c_str());
}


LIBLAX_EXTERN
XMLNode_t *
XMLNode_convertStringToXMLNode(const char * xml, const XMLNamespaces_t* xmlns)
{
  if (xml == NULL) return NULL;
  return XMLNode::convertStringToXMLNode(xml, xmlns);
}


LIBLAX_EXTERN
int
XMLNode_isElement (const XMLNode_t *node)
{
  if (node == NULL ) return (int)false;
  return static_cast<int>( node->isElement() );
}


LIBLAX_EXTERN
int
XMLNode_isEnd (const XMLNode_t *node) 
{
  if (node == NULL) return (int)false;
  return static_cast<int>( node->isEnd() );
}


LIBLAX_EXTERN
int
XMLNode_isEndFor (const XMLNode_t *node, const XMLNode_t *element)
{
  if (node == NULL) return (int)false;
  return static_cast<int>( node->isEndFor(*element) );
}


LIBLAX_EXTERN
int
XMLNode_isEOF (const XMLNode_t *node)
{
  if (node == NULL) return (int) false;
  return static_cast<int>( node->isEOF() );
}


LIBLAX_EXTERN
int
XMLNode_isStart (const XMLNode_t *node)
{
  if (node == NULL) return (int)false;
  return static_cast<int>( node->isStart() );
}


LIBLAX_EXTERN
int
XMLNode_isText (const XMLNode_t *node)
{
  if (node == NULL) return (int)false;
  return static_cast<int>( node->isText() );
}


LIBLAX_EXTERN
int
XMLNode_setEnd (XMLNode_t *node)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->setEnd();
}


LIBLAX_EXTERN
int
XMLNode_setEOF (XMLNode_t *node)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->setEOF();
}


LIBLAX_EXTERN
int
XMLNode_unsetEnd (XMLNode_t *node)
{
  if (node == NULL) return LIBSBML_INVALID_OBJECT;
  return node->unsetEnd();
}


/** @endcond */

LIBSBML_CPP_NAMESPACE_END
