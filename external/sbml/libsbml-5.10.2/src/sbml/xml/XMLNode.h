/**
 * @file    XMLNode.h
 * @brief   Class definition of XMLNode, a node in an XML document tree.
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
 * ---------------------------------------------------------------------- -->
 *
 * @class XMLNode
 * @sbmlbrief{core} A node in libSBML's XML document tree.
 * 
 * Beginning with version 3.0.0, libSBML implements an XML abstraction
 * layer.  This layer presents a uniform XML interface to calling programs
 * regardless of which underlying XML parser libSBML has actually been
 * configured to use.  The basic data object in the XML abstraction is a
 * @em node, represented by XMLNode.
 *
 * An XMLNode can contain any number of children.  Each child is another
 * XMLNode, thereby forming a tree.  The methods XMLNode::getNumChildren()
 * and XMLNode::getChild(@if java long@endif) can be used to access the tree
 * structure starting from a given node.
 *
 * Each XMLNode is subclassed from XMLToken, and thus has the same methods
 * available as XMLToken.  These methods include XMLToken::getNamespaces(),
 * XMLToken::getPrefix(), XMLToken::getName(), XMLToken::getURI(), and
 * XMLToken::getAttributes().
 *
 * @section xmlnode-str2xmlnode Conversion between an XML string and an XMLNode
 *
 * LibSBML provides the following utility functions for converting an XML
 * string (e.g., <code>&lt;annotation&gt;...&lt;/annotation&gt;</code>)
 * to/from an XMLNode object.
 * <ul>
 * <li> XMLNode::toXMLString() returns a string representation of the XMLNode object. 
 *
 * <li> XMLNode::convertXMLNodeToString(@if java XMLNode@endif)
 * (static function) returns a string representation 
 * of the given XMLNode object.
 *
 * <li> XMLNode::convertStringToXMLNode(@if java String@endif)
 * (static function) returns an XMLNode object converted 
 * from the given XML string.
 * </ul>
 *
 * The returned XMLNode object by XMLNode::convertStringToXMLNode(@if java String@endif)
 * is a dummy root (container) XMLNode if the given XML string has two or
 * more top-level elements (e.g.,
 * &quot;<code>&lt;p&gt;...&lt;/p&gt;&lt;p&gt;...&lt;/p&gt;</code>&quot;). In the
 * dummy root node, each top-level element in the given XML string is
 * contained as a child XMLNode. XMLToken::isEOF() can be used to identify
 * if the returned XMLNode object is a dummy node or not.  Here is an
 * example: @if clike
 * @verbatim
// Checks if the XMLNode object returned by XMLNode::convertStringToXMLNode() is a dummy root node:
                                                                                         
std::string str = "..."; 
XMLNode* xn = XMLNode::convertStringToXMLNode(str);                                      
if ( xn == NULL )
{                                                                                      
  // returned value is null (error)                                                    
  ...
}                                                                                      
else if ( xn->isEOF() )                                                                 
{                                                                                      
  // root node is a dummy node                                                         
  for ( int i = 0; i < xn->getNumChildren(); i++ )                                          
  {                                                                                    
    // access to each child node of the dummy node.                                    
    XMLNode& xnChild = xn->getChild(i);                                                  
    ...                                                                                
  }                                                                                    
}                                                                                      
else                                                                                   
{                                                                                      
  // root node is NOT a dummy node                                                     
  ...                                                                                  
}
@endverbatim
  *  @endif@if java
@verbatim
// Checks if the returned XMLNode object is a dummy root node:

String str = "...";
XMLNode xn = XMLNode.convertStringToXMLNode(str);
if ( xn == null )
{
  // returned value is null (error)
  ...
}
else if ( xn.isEOF() )
{
  // root node is a dummy node
  for ( int i = 0; i < xn.getNumChildren(); i++ )
  {
    // access to each child node of the dummy node.
    XMLNode xnChild = xn.getChild(i);
    ...
  }
}
else
{
  // root node is NOT a dummy node
  ...
}
@endverbatim
 * @endif@if python
@verbatim
xn = XMLNode.convertStringToXMLNode("<p></p>")
if xn == None:
  # Do something to handle exceptional situation.

elif xn.isEOF():
  # Node is a dummy node.

else:
  # None is not a dummy node.
@endverbatim
 * @endif@~
 */

#ifndef XMLNode_h
#define XMLNode_h

#include <sbml/xml/XMLExtern.h>
#include <sbml/xml/XMLToken.h>
#include <sbml/common/sbmlfwd.h>


#ifdef __cplusplus

#include <vector>
#include <cstdlib>

LIBSBML_CPP_NAMESPACE_BEGIN

/** @cond doxygenLibsbmlInternal */
class XMLInputStream;
class XMLOutputStream;
/** @endcond */


class LIBLAX_EXTERN XMLNode : public XMLToken
{
public:

  /**
   * Creates a new empty XMLNode with no children.
   */
  XMLNode ();


  /**
   * Creates a new XMLNode by copying token.
   *
   * @param token XMLToken to be copied to XMLNode
   */
  XMLNode (const XMLToken& token);


  /**
   * Creates a new start element XMLNode with the given set of attributes and
   * namespace declarations.
   *
   * @param triple XMLTriple.
   * @param attributes XMLAttributes, the attributes to set.
   * @param namespaces XMLNamespaces, the namespaces to set.
   * @param line an unsigned int, the line number (default = 0).
   * @param column an unsigned int, the column number (default = 0).
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLNode (  const XMLTriple&     triple
           , const XMLAttributes& attributes
           , const XMLNamespaces& namespaces
           , const unsigned int   line   = 0
           , const unsigned int   column = 0 );


  /**
   * Creates a start element XMLNode with the given set of attributes.
   *
   * @param triple XMLTriple.
   * @param attributes XMLAttributes, the attributes to set.
   * @param line an unsigned int, the line number (default = 0).
   * @param column an unsigned int, the column number (default = 0).
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
  */
  XMLNode (  const XMLTriple&      triple
           , const XMLAttributes&  attributes
           , const unsigned int    line   = 0
           , const unsigned int    column = 0 );


  /**
   * Creates an end element XMLNode.
   *
   * @param triple XMLTriple.
   * @param line an unsigned int, the line number (default = 0).
   * @param column an unsigned int, the column number (default = 0).
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLNode (  const XMLTriple&    triple
           , const unsigned int  line   = 0
           , const unsigned int  column = 0 );


  /**
   * Creates a text XMLNode.
   *
   * @param chars a string, the text to be added to the XMLToken
   * @param line an unsigned int, the line number (default = 0).
   * @param column an unsigned int, the column number (default = 0).
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  XMLNode (  const std::string&  chars
           , const unsigned int  line   = 0
           , const unsigned int  column = 0 );


  /** @cond doxygenLibsbmlInternal */
  /**
   * Creates a new XMLNode by reading XMLTokens from stream.  
   *
   * The stream must be positioned on a start element
   * (<code>stream.peek().isStart() == true</code>) and will be read until
   * the matching end element is found.
   *
   * @param stream XMLInputStream from which XMLNode is to be created.
   */
  XMLNode (XMLInputStream& stream);
  /** @endcond */


  /**
   * Destroys this XMLNode.
   */
  virtual ~XMLNode ();

  
  /**
   * Copy constructor; creates a copy of this XMLNode.
   * 
   * @param orig the XMLNode instance to copy.
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p orig is @c NULL.
   */
  XMLNode(const XMLNode& orig);


  /**
   * Assignment operator for XMLNode.
   *
   * @param rhs The XMLNode object whose values are used as the basis
   * of the assignment.
   *
   * @throws XMLConstructorException
   * Thrown if the argument @p rhs is @c NULL.
   */
  XMLNode& operator=(const XMLNode& rhs);


  /**
   * Creates and returns a deep copy of this XMLNode object.
   *
   * @return the (deep) copy of this XMLNode object.
   */
  XMLNode* clone () const;


  /**
   * Adds a copy of @p node as a child of this XMLNode.
   *
   * The given @p node is added at the end of the list of children.
   *
   * @param node the XMLNode to be added as child.
   *
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
   *
   * @note The given node is added at the end of the children list.
   */
  int addChild (const XMLNode& node);


  /**
   * Inserts a copy of the given node as the <code>n</code>th child of this
   * XMLNode.
   *
   * If the given index @p n is out of range for this XMLNode instance,
   * the @p node is added at the end of the list of children.  Even in
   * that situation, this method does not throw an error.
   *
   * @param n an integer, the index at which the given node is inserted
   * @param node an XMLNode to be inserted as <code>n</code>th child.
   *
   * @return a reference to the newly-inserted child @p node
   */
  XMLNode& insertChild (unsigned int n, const XMLNode& node);


  /**
   * Removes the <code>n</code>th child of this XMLNode and returns the
   * removed node.
   *
   * It is important to keep in mind that a given XMLNode may have more
   * than one child.  Calling this method erases all existing references to
   * child nodes @em after the given position @p n.  If the index @p n is
   * greater than the number of child nodes in this XMLNode, this method
   * takes no action (and returns @c NULL).
   *
   * @param n an integer, the index of the node to be removed
   *
   * @return the removed child, or @c NULL if @p n is greater than the number
   * of children in this node
   *
   * @note The caller owns the returned node and is responsible for deleting it.
   */
  XMLNode* removeChild(unsigned int n);


  /**
   * Removes all children from this node.
   * @return integer value indicating success/failure of the
   * function.   The possible values
   * returned by this function are:
   * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
   */
  int removeChildren();


  /**
   * Returns the <code>n</code>th child of this XMLNode.
   *
   * If the index @p n is greater than the number of child nodes,
   * this method returns an empty node.
   *
   * @param n an unsigned integer, the index of the node to return
   * 
   * @return the <code>n</code>th child of this XMLNode.
   */
  XMLNode& getChild (unsigned int n);


  /**
   * Returns the  <code>n</code>th child of this XMLNode.
   *
   * If the index @p n is greater than the number of child nodes,
   * this method returns an empty node.
   *
   * @param n an unsigned integer, the index of the node to return
   * 
   * @return the <code>n</code>th child of this XMLNode.
   */
  const XMLNode& getChild (unsigned int n) const;


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
  XMLNode& getChild (const std::string&  name);	


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
  const XMLNode& getChild (const std::string&  name) const;
	

  /**
   * Return the index of the first child of this XMLNode with the given name.
   *
   * @param name a string, the name of the child for which the 
   * index is required.
   *
   * @return the index of the first child of this XMLNode with the given
   * name, or -1 if not present.
   */
  int getIndex (const std::string& name) const;


  /**
   * Return a boolean indicating whether this XMLNode has a child with the
   * given name.
   *
   * @param name a string, the name of the child to be checked.
   *
   * @return boolean indicating whether this XMLNode has a child with the
   * given name.
   */
  bool hasChild (const std::string& name) const;

	
  /**
   * Compare this XMLNode against another XMLNode returning true if both
   * nodes represent the same XML tree, or false otherwise.
   *
   * @param other another XMLNode to compare against.
   *
   * @param ignoreURI whether to ignore the namespace URI when doing the
   * comparison.
   *
   * @return boolean indicating whether this XMLNode represents the same XML
   * tree as another.
   */
  bool equals(const XMLNode& other, bool ignoreURI=false) const;
	

  /**
   * Returns the number of children for this XMLNode.
   *
   * @return the number of children for this XMLNode.
   */
  unsigned int getNumChildren () const;


  /** @cond doxygenLibsbmlInternal */
  /**
   * Writes this XMLNode and its children to stream.
   *
   * @param stream XMLOutputStream, stream to which this XMLNode
   * is to be written.
   */
  void write (XMLOutputStream& stream) const;
  /** @endcond */


  /**
   * Returns a string representation of this XMLNode. 
   *
   * @return a string derived from this XMLNode.
   */
  std::string toXMLString() const;


  /**
   * Returns a string representation of a given XMLNode. 
   *
   * @param node the XMLNode to be represented as a string
   *
   * @return a string-form representation of @p node
   */
  static std::string convertXMLNodeToString(const XMLNode* node);


  /**
   * Returns an XMLNode which is derived from a string containing XML
   * content.
   *
   * The XML namespace must be defined using argument @p xmlns if the
   * corresponding XML namespace attribute is not part of the string of the
   * first argument.
   *
   * @param xmlstr string to be converted to a XML node.
   * @param xmlns XMLNamespaces the namespaces to set (default value is @c NULL).
   *
   * @note The caller owns the returned XMLNode and is reponsible for
   * deleting it.  The returned XMLNode object is a dummy root (container)
   * XMLNode if the top-level element in the given XML string is NOT
   * <code>&lt;html&gt;</code>, <code>&lt;body&gt;</code>,
   * <code>&lt;annotation&gt;</code>, or <code>&lt;notes&gt;</code>.  In
   * the dummy root node, each top-level element in the given XML string is
   * contained as a child XMLNode. XMLToken::isEOF() can be used to
   * identify if the returned XMLNode object is a dummy node.
   *
   * @return a XMLNode which is converted from string @p xmlstr.  If the
   * conversion failed, this method returns @c NULL.
   *
   * @ifnot hasDefaultArgs @htmlinclude warn-default-args-in-docs.html @endif@~
   */
  static XMLNode* convertStringToXMLNode(const std::string& xmlstr,
                                         const XMLNamespaces* xmlns = NULL);


#ifndef SWIG

  /** @cond doxygenLibsbmlInternal */
  /**
   * Inserts this XMLNode and its children into stream.
   *
   * @param stream XMLOutputStream, stream to which the XMLNode
   * is to be written.
   * @param node XMLNode, node to be written to stream.
   *
   * @return the stream with the node inserted.
   */
  LIBLAX_EXTERN
  friend
  XMLOutputStream& operator<< (XMLOutputStream& stream, const XMLNode& node);
  /** @endcond */

#endif  /* !SWIG */


protected:
  /** @cond doxygenLibsbmlInternal */

  std::vector<XMLNode> mChildren;

  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif  /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS

/**
 * Creates a new empty XMLNode_t structure with no children
 * and returns a pointer to it.
 *
 * @return pointer to the new XMLNode_t structure.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
XMLNode_t *
XMLNode_create (void);


/**
 * Creates a new XMLNode_t structure by copying token and returns a pointer
 * to it.
 *
 * @param token XMLToken_t structure to be copied to XMLNode_t structure.
 *
 * @return pointer to the new XMLNode_t structure.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
XMLNode_t *
XMLNode_createFromToken (const XMLToken_t *token);


/**
 * Creates a new start element XMLNode_t structure with XMLTriple_t 
 * and XMLAttributes_t structures set and returns a pointer to it.
 *
 * @param triple XMLTriple_t structure to be set.
 * @param attr XMLAttributes_t structure to be set.
 *
 * @return pointer to new XMLNode_t structure.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
XMLNode_t *
XMLNode_createStartElement  (const XMLTriple_t *triple,
			     const XMLAttributes_t *attr);


/**
 * Creates a new start element XMLNode_t structure with XMLTriple_t, 
 * XMLAttributes_t and XMLNamespaces_t structures set and returns a 
 * pointer to it.
 *
 * @param triple XMLTriple_t structure to be set.
 * @param attr XMLAttributes_t structure to be set.
 * @param ns XMLNamespaces_t structure to be set.
 *
 * @return pointer to new XMLNode_t structure.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
XMLNode_t *
XMLNode_createStartElementNS (const XMLTriple_t *triple,
                              const XMLAttributes_t *attr,
                              const XMLNamespaces_t *ns);


/**
 * Creates a new end element XMLNode_t structure with XMLTriple_t 
 * structure set and returns a pointer to it.
 *
 * @param triple XMLTriple_t structure to be set.
 *
 * @return pointer to new XMLNode_t structure.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
XMLNode_t *
XMLNode_createEndElement (const XMLTriple_t *triple);

/**
 * Creates a text XMLNode_t.  Defaults to creating the node with a line number of 0 and a column number of 0.
 *
 * @param text the text to be added to the XMLToken_t
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
XMLNode_t *
XMLNode_createTextNode (const char *text);


/**
 * Creates a deep copy of the given XMLNode_t structure
 * 
 * @param n the XMLNode_t structure to be copied
 * 
 * @return a (deep) copy of the given XMLNode_t structure.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
XMLNode_t *
XMLNode_clone (const XMLNode_t* n);


/**
 * Destroys this XMLNode_t structure.
 *
 * @param node XMLNode_t structure to be freed.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
void
XMLNode_free (XMLNode_t *node);


/**
 * Adds a copy of child node to this XMLNode_t structure.
 *
 * @param node XMLNode_t structure to which child is to be added.
 * @param child XMLNode_t structure to be added as child.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_addChild (XMLNode_t *node, const XMLNode_t *child);


/**
 * Inserts a copy of child node to this XMLNode_t structure.
 *
 * @param node XMLNode_t structure to which child is to be added.
 * @param n the index at which the given node is inserted
 * @param child XMLNode_t structure to be inserted as nth child.
 *
 * @return the newly inserted child in this XMLNode_t. 
 * NULL will be returned if the given child is NULL. 
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
XMLNode_t*
XMLNode_insertChild (XMLNode_t *node, unsigned int n, const XMLNode_t *child);


/**
 * Removes the nth child of this XMLNode_t and returned the removed node.
 *
 * @param node XMLNode_t structure to which child is to be removed.
 * @param n the index of the node to be removed
 *
 * @return the removed child, or NULL if the given index is out of range. 
 *
 * @note This function invalidates all existing references to child nodes 
 * after the position or first.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
XMLNode_t* 
XMLNode_removeChild(XMLNode_t *node, unsigned int n);


/**
 * Removes all children from this node.
 *
 * @param node XMLNode_t structure whose children to remove.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_removeChildren (XMLNode_t *node);


/**
 * Returns the text of this element.
 *
 * @param node XMLNode_t structure to be queried.
 *
 * @return the characters of this XML text.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
const char *
XMLNode_getCharacters (const XMLNode_t *node);


/**
 * Sets the XMLTripe_t (name, uri and prefix) of this XML element.
 * Nothing will be done if this XML element is a text node.
 *
 * @param node XMLNode_t structure to which the triple to be added.
 * @param triple an XMLTriple_t, the XML triple to be set to this XML element.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_setTriple(XMLNode_t *node, const XMLTriple_t *triple);


/**
 * Returns the (unqualified) name of this XML element.
 *
 * @param node XMLNode_t structure to be queried.
 *
 * @return the (unqualified) name of this XML element.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
const char *
XMLNode_getName (const XMLNode_t *node);


/**
 * Returns the namespace prefix of this XML element.
 *
 * @param node XMLNode_t structure to be queried.
 *
 * @return the namespace prefix of this XML element.  
 *
 * @note If no prefix
 * exists, an empty string will be return.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
const char *
XMLNode_getPrefix (const XMLNode_t *node);


/**
 * Returns the namespace URI of this XML element.
 *
 * @param node XMLNode_t structure to be queried.
 *
 * @return the namespace URI of this XML element.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
const char *
XMLNode_getURI (const XMLNode_t *node);


/**
 * Returns the nth child of this XMLNode_t structure.
 *
 * @param node XMLNode_t structure to be queried.
 * @param n the index of the node to return
 *
 * @return the nth child of this XMLNode_t structure.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
const XMLNode_t *
XMLNode_getChild (const XMLNode_t *node, const int n);


/**
 * Returns the (non-const) nth child of this XMLNode_t structure.
 *
 * @param node XMLNode_t structure to be queried.
 * @param n the index of the node to return
 *
 * @return the non-const nth child of this XMLNode_t structure.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
XMLNode_t *
XMLNode_getChildNC (XMLNode_t *node, const unsigned int n);

/**
 * Returns the (non-const) the first child of the XMLNode_t structure node with the given name.
 *
 * If no child with corrsponding name can be found, 
 * this method returns an empty node.
 *
 * @param node XMLNode_t structure to be queried.
 * @param name the name of the node to return
 * 
 * @return the first child of this XMLNode_t with given name.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
XMLNode_t *
XMLNode_getChildForNameNC (XMLNode_t *node, const char*  name);	

/**
 * Returns the first child of the XMLNode_t structure node with the given name.
 *
 * If no child with corrsponding name can be found, 
 * this method returns an empty node.
 *
 * @param node XMLNode_t structure to be queried.
 * @param name the name of the node to return
 * 
 * @return the first child of this XMLNode_t with given name.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
const XMLNode_t *
XMLNode_getChildForName (const XMLNode_t *node, const char*  name);

/**
 * Return the index of the first child of the XMLNode_t structure node with the given name.
 *
 * @param node XMLNode_t structure to be queried.
 * @param name a string, the name of the child for which the 
 * index is required.
 *
 * @return the index of the first child of node with the given name, or -1 if not present.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_getIndex (const XMLNode_t *node, const char*  name);

/**
 * Return a boolean indicating whether node has a child with the given name.
 *
 * @param node XMLNode_t structure to be queried.
 * @param name a string, the name of the child to be checked.
 *
 * @return true (non-zero) if this node has a child with the given name false (zero) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_hasChild (const XMLNode_t *node, const char*  name);

/**
 * Compare one XMLNode against another XMLNode returning true (non-zero) if both nodes
 * represent the same XML tree, or false (zero) otherwise.
 *
 *
 * @param node the original XMLNode_t structure
 * @param other another XMLNode_t to compare against
 *
 * @return true (non-zero) if both nodes
 * represent the same XML tree, or false (zero) otherwise
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_equals(const XMLNode_t *node, const XMLNode_t* other);

/**
 * Returns the number of children for this XMLNode_t structure.
 *
 * @param node XMLNode_t structure to be queried.
 *
 * @return the number of children for this XMLNode_t structure.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
unsigned int
XMLNode_getNumChildren (const XMLNode_t *node);


/**
 * Returns the attributes of this element.
 *
 * @param node XMLNode_t structure to be queried.
 *
 * @return the XMLAttributes_t of this XML element.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
const XMLAttributes_t *
XMLNode_getAttributes (const XMLNode_t *node);


/**
 * Sets an XMLAttributes_t to this XMLNode_t.
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure to which attributes to be set.
 * @param attributes XMLAttributes to be set to this XMLNode_t.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note This function replaces the existing XMLAttributes_t with the new one.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_setAttributes (XMLNode_t *node, const XMLAttributes_t* attributes);


/**
 * Adds an attribute with the given local name to the attribute set in this XMLNode_t.
 * (namespace URI and prefix are empty)
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure to which an attribute to be added.
 * @param name a string, the local name of the attribute.
 * @param value a string, the value of the attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note if the local name without namespace URI already exists in the
 * attribute set, its value will be replaced.
 *
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_addAttr ( XMLNode_t *node,  const char* name, const char* value );


/**
 * Adds an attribute with a prefix and namespace URI to the attribute set 
 * in this XMLNode_t optionally 
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure to which an attribute to be added.
 * @param name a string, the local name of the attribute.
 * @param value a string, the value of the attribute.
 * @param namespaceURI a string, the namespace URI of the attribute.
 * @param prefix a string, the prefix of the namespace
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note if local name with the same namespace URI already exists in the
 * attribute set, its value and prefix will be replaced.
 *
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_addAttrWithNS ( XMLNode_t *node,  const char* name
                      , const char* value
                      , const char* namespaceURI
                      , const char* prefix      );


/**
 * Adds an attribute with the given XMLTriple/value pair to the attribute set
 * in this XMLNode_t.
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @note if local name with the same namespace URI already exists in the 
 * attribute set, its value and prefix will be replaced.
 *
 * @param node XMLNode_t structure to which an attribute to be added.
 * @param triple an XMLTriple_t, the XML triple of the attribute.
 * @param value a string, the value of the attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_addAttrWithTriple (XMLNode_t *node, const XMLTriple_t *triple, const char* value);


/**
 * Removes an attribute with the given index from the attribute set in
 * this XMLNode_t.
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure from which an attribute to be removed.
 * @param n an integer the index of the resource to be deleted
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_removeAttr (XMLNode_t *node, int n);


/**
 * Removes an attribute with the given local name (without namespace URI) 
 * from the attribute set in this XMLNode_t.
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure from which an attribute to be removed.
 * @param name   a string, the local name of the attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_removeAttrByName (XMLNode_t *node, const char* name);


/**
 * Removes an attribute with the given local name and namespace URI from 
 * the attribute set in this XMLNode_t.
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure from which an attribute to be removed.
 * @param name   a string, the local name of the attribute.
 * @param uri    a string, the namespace URI of the attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_removeAttrByNS (XMLNode_t *node, const char* name, const char* uri);


/**
 * Removes an attribute with the given XMLTriple_t from the attribute set 
 * in this XMLNode_t.  
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure from which an attribute to be removed.
 * @param triple an XMLTriple_t, the XML triple of the attribute.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_removeAttrByTriple (XMLNode_t *node, const XMLTriple_t *triple);


/**
 * Clears (deletes) all attributes in this XMLNode_t.
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure from which attributes to be cleared.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_clearAttributes(XMLNode_t *node);


/**
 * Return the index of an attribute with the given local name and namespace URI.
 *
 * @param node XMLNode_t structure to be queried.
 * @param name a string, the local name of the attribute.
 * @param uri  a string, the namespace URI of the attribute.
 *
 * @return the index of an attribute with the given local name and namespace URI, 
 * or -1 if not present.
 *
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_getAttrIndex (const XMLNode_t *node, const char* name, const char* uri);


/**
 * Return the index of an attribute with the given XMLTriple_t.
 *
 * @param node XMLNode_t structure to be queried.
 * @param triple an XMLTriple_t, the XML triple of the attribute for which 
 *        the index is required.
 *
 * @return the index of an attribute with the given XMLTriple_t, or -1 if not present.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_getAttrIndexByTriple (const XMLNode_t *node, const XMLTriple_t *triple);


/**
 * Return the number of attributes in the attributes set.
 *
 * @param node XMLNode_t structure to be queried.
 *
 * @return the number of attributes in the attributes set in this XMLNode_t.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_getAttributesLength (const XMLNode_t *node);


/**
 * Return the local name of an attribute in the attributes set in this 
 * XMLNode_t (by position).
 *
 * @param node XMLNode_t structure to be queried.
 * @param index an integer, the position of the attribute whose local name 
 * is required.
 *
 * @return the local name of an attribute in this list (by position).  
 *
 * @note If index
 * is out of range, an empty string will be returned.  Use XMLNode_hasAttr(...) 
 * to test for the attribute existence.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char* 
XMLNode_getAttrName (const XMLNode_t *node, int index);


/**
 * Return the prefix of an attribute in the attribute set in this 
 * XMLNode (by position).
 *
 * @param node XMLNode_t structure to be queried.
 * @param index an integer, the position of the attribute whose prefix is 
 * required.
 *
 * @return the namespace prefix of an attribute in the attribute set
 * (by position).  
 *
 * @note If index is out of range, an empty string will be
 * returned. Use XMLNode_hasAttr(...) to test for the attribute existence.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char* 
XMLNode_getAttrPrefix (const XMLNode_t *node, int index);


/**
 * Return the prefixed name of an attribute in the attribute set in this 
 * XMLNode (by position).
 *
 * @param node XMLNode_t structure to be queried.
 * @param index an integer, the position of the attribute whose prefixed 
 * name is required.
 *
 * @return the prefixed name of an attribute in the attribute set 
 * (by position).  
 *
 * @note If index is out of range, an empty string will be
 * returned.  Use XMLNode_hasAttr(...) to test for attribute existence.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char* 
XMLNode_getAttrPrefixedName (const XMLNode_t *node, int index);


/**
 * Return the namespace URI of an attribute in the attribute set in this 
 * XMLNode (by position).
 *
 * @param node XMLNode_t structure to be queried.
 * @param index an integer, the position of the attribute whose namespace 
 * URI is required.
 *
 * @return the namespace URI of an attribute in the attribute set (by position).
 *
 * @note If index is out of range, an empty string will be returned.  Use
 * XMLNode_hasAttr(index) to test for attribute existence.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char* 
XMLNode_getAttrURI (const XMLNode_t *node, int index);


/**
 * Return the value of an attribute in the attribute set in this XMLNode_t 
 * (by position).
 *
 * @param node XMLNode_t structure to be queried.
 * @param index an integer, the position of the attribute whose value is 
 * required.
 *
 * @return the value of an attribute in the attribute set (by position).  
 *
 * @note If index
 * is out of range, an empty string will be returned. Use XMLNode_hasAttr(...)
 * to test for attribute existence.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char* 
XMLNode_getAttrValue (const XMLNode_t *node, int index);


/**
 * Return a value of an attribute with the given local name (without namespace URI).
 *
 * @param node XMLNode_t structure to be queried.
 * @param name a string, the local name of the attribute whose value is required.
 *
 * @return The attribute value as a string.  
 *
 * @note If an attribute with the given local name (without namespace URI) 
 * does not exist, an empty string will be returned.  
 * Use XMLNode_hasAttr(...) to test for attribute existence.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char* 
XMLNode_getAttrValueByName (const XMLNode_t *node, const char* name);


/**
 * Return a value of an attribute with the given local name and namespace URI.
 *
 * @param node XMLNode_t structure to be queried.
 * @param name a string, the local name of the attribute whose value is required.
 * @param uri  a string, the namespace URI of the attribute.
 *
 * @return The attribute value as a string.  
 *
 * @note If an attribute with the 
 * given local name and namespace URI does not exist, an empty string will be 
 * returned.  
 * Use XMLNode_hasAttr(name, uri) to test for attribute existence.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char* 
XMLNode_getAttrValueByNS (const XMLNode_t *node, const char* name, const char* uri);


/**
 * Return a value of an attribute with the given XMLTriple_t.
 *
 * @param node XMLNode_t structure to be queried.
 * @param triple an XMLTriple_t, the XML triple of the attribute whose 
 *        value is required.
 *
 * @return The attribute value as a string.  
 *
 * @note If an attribute with the
 * given XMLTriple_t does not exist, an empty string will be returned.  
 * Use XMLNode_hasAttr(...) to test for attribute existence.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char* 
XMLNode_getAttrValueByTriple (const XMLNode_t *node, const XMLTriple_t *triple);


/**
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given index exists in the attribute set in this 
 * XMLNode.
 *
 * @param node XMLNode_t structure to be queried.
 * @param index an integer, the position of the attribute.
 *
 * @return @c non-zero (true) if an attribute with the given index exists in 
 * the attribute set in this XMLNode_t, @c zero (false) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_hasAttr (const XMLNode_t *node, int index);


/**
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given local name (without namespace URI) 
 * exists in the attribute set in this XMLNode_t.
 *
 * @param node XMLNode_t structure to be queried.
 * @param name a string, the local name of the attribute.
 *
 * @return @c non-zero (true) if an attribute with the given local name 
 * (without namespace URI) exists in the attribute set in this XMLNode_t, 
 * @c zero (false) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_hasAttrWithName (const XMLNode_t *node, const char* name);

/**
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given local name and namespace URI exists 
 * in the attribute set in this XMLNode_t.
 *
 * @param node XMLNode_t structure to be queried.
 * @param name a string, the local name of the attribute.
 * @param uri  a string, the namespace URI of the attribute.
 *
 * @return @c non-zero (true) if an attribute with the given local name 
 * and namespace URI exists in the attribute set in this XMLNode_t, 
 * @c zero (false) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_hasAttrWithNS (const XMLNode_t *node, const char* name, const char* uri);


/**
 * Predicate returning @c true or @c false depending on whether
 * an attribute with the given XML triple exists in the attribute set in 
 * this XMLNode_t
 *
 * @param node XMLNode_t structure to be queried.
 * @param triple an XMLTriple_t, the XML triple of the attribute 
 *
 * @return @c non-zero (true) if an attribute with the given XML triple exists
 * in the attribute set in this XMLNode_t, @c zero (false) otherwise.
 *
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_hasAttrWithTriple (const XMLNode_t *node, const XMLTriple_t *triple);


/**
 * Predicate returning @c true or @c false depending on whether 
 * the attribute set in this XMLNode_t set is empty.
 * 
 * @param node XMLNode_t structure to be queried.
 *
 * @return @c non-zero (true) if the attribute set in this XMLNode_t is empty, 
 * @c zero (false) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_isAttributesEmpty (const XMLNode_t *node);



/**
 * Returns the XML namespace declarations for this XML element.
 *
 * @param node XMLNode_t structure to be queried.
 *
 * @return the XML namespace declarations for this XML element.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
const XMLNamespaces_t *
XMLNode_getNamespaces (const XMLNode_t *node);


/**
 * Sets an XMLnamespaces_t to this XML element.
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure to be queried.
 * @param namespaces XMLNamespaces_t to be set to this XMLNode_t.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @note This function replaces the existing XMLNamespaces_t with the new one.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_setNamespaces(XMLNode_t *node, const XMLNamespaces_t* namespaces);


/**
 * Appends an XML namespace prefix and URI pair to this XMLNode_t.
 * If there is an XML namespace with the given prefix in this XMLNode_t, 
 * then the existing XML namespace will be overwritten by the new one.
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure to be queried.
 * @param uri a string, the uri for the namespace
 * @param prefix a string, the prefix for the namespace
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_addNamespace (XMLNode_t *node, const char* uri, const char* prefix);


/**
 * Removes an XML Namespace stored in the given position of the XMLNamespaces_t
 * of this XMLNode_t.
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure to be queried.
 * @param index an integer, position of the removed namespace.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_removeNamespace (XMLNode_t *node, int index);


/**
 * Removes an XML Namespace with the given prefix.
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure to be queried.
 * @param prefix a string, prefix of the required namespace.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INDEX_EXCEEDS_SIZE, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_removeNamespaceByPrefix (XMLNode_t *node, const char* prefix);


/**
 * Clears (deletes) all XML namespace declarations in the XMLNamespaces_t 
 * of this XMLNode_t.
 * Nothing will be done if this XMLNode_t is not a start element.
 *
 * @param node XMLNode_t structure to be queried.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_XML_OPERATION, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_clearNamespaces (XMLNode_t *node);


/**
 * Look up the index of an XML namespace declaration by URI.
 *
 * @param node XMLNode_t structure to be queried.
 * @param uri a string, uri of the required namespace.
 *
 * @return the index of the given declaration, or -1 if not present.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_getNamespaceIndex (const XMLNode_t *node, const char* uri);


/**
 * Look up the index of an XML namespace declaration by prefix.
 *
 * @param node XMLNode_t structure to be queried.
 * @param prefix a string, prefix of the required namespace.
 *
 * @return the index of the given declaration, or -1 if not present.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_getNamespaceIndexByPrefix (const XMLNode_t *node, const char* prefix);


/**
 * Returns the number of XML namespaces stored in the XMLNamespaces_t 
 * of this XMLNode_t.
 *
 * @param node XMLNode_t structure to be queried.
 *
 * @return the number of namespaces in this list.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int 
XMLNode_getNamespacesLength (const XMLNode_t *node);


/**
 * Look up the prefix of an XML namespace declaration by position.
 *
 * Callers should use getNamespacesLength() to find out how many 
 * namespaces are stored in the XMLNamespaces.
 *
 * @param node XMLNode_t structure to be queried.
 * @param index an integer, position of the removed namespace.
 * 
 * @return the prefix of an XML namespace declaration in the XMLNamespaces_t 
 * (by position).  
 *
 * @note returned char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char* 
XMLNode_getNamespacePrefix (const XMLNode_t *node, int index);


/**
 * Look up the prefix of an XML namespace declaration by its URI.
 *
 * @param node XMLNode_t structure to be queried.
 * @param uri a string, uri of the required namespace.
 *
 * @return the prefix of an XML namespace declaration given its URI.  
 *
 * @note returned char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char* 
XMLNode_getNamespacePrefixByURI (const XMLNode_t *node, const char* uri);


/**
 * Look up the URI of an XML namespace declaration by its position.
 *
 * @param node XMLNode_t structure to be queried.
 * @param index an integer, position of the removed namespace.
 *
 * @return the URI of an XML namespace declaration in the XMLNamespaces_t
 * (by position).  
 *
 * @note returned char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char* 
XMLNode_getNamespaceURI (const XMLNode_t *node, int index);


/**
 * Look up the URI of an XML namespace declaration by its prefix.
 *
 * @param node XMLNode_t structure to be queried.
 * @param prefix a string, prefix of the required namespace.
 *
 * @return the URI of an XML namespace declaration given its prefix.  
 *
 * @note returned char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char* 
XMLNode_getNamespaceURIByPrefix (const XMLNode_t *node, const char* prefix);


/**
 * Predicate returning @c true or @c false depending on whether 
 * the XMLNamespaces_t of this XMLNode_t is empty.
 * 
 * @param node XMLNode_t structure to be queried.
 *
 * @return @c non-zero (true) if the XMLNamespaces_t of this XMLNode_t is empty, 
 * @c zero (false) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_isNamespacesEmpty (const XMLNode_t *node);


/**
 * Predicate returning @c true or @c false depending on whether 
 * an XML Namespace with the given URI is contained in the XMLNamespaces_t of
 * this XMLNode_t.
 * 
 * @param node XMLNode_t structure to be queried.
 * @param uri a string, the uri for the namespace
 *
 * @return @c no-zero (true) if an XML Namespace with the given URI is 
 * contained in the XMLNamespaces_t of this XMLNode_t,  @c zero (false) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_hasNamespaceURI(const XMLNode_t *node, const char* uri);


/**
 * Predicate returning @c true or @c false depending on whether 
 * an XML Namespace with the given prefix is contained in the XMLNamespaces_t of
 * this XMLNode_t.
 *
 * @param node XMLNode_t structure to be queried.
 * @param prefix a string, the prefix for the namespace
 * 
 * @return @c no-zero (true) if an XML Namespace with the given URI is 
 * contained in the XMLNamespaces_t of this XMLNode_t, @c zero (false) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_hasNamespacePrefix(const XMLNode_t *node, const char* prefix);


/**
 * Predicate returning @c true or @c false depending on whether 
 * an XML Namespace with the given uri/prefix pair is contained in the 
 * XMLNamespaces_t of this XMLNode_t.
 *
 * @param node XMLNode_t structure to be queried.
 * @param uri a string, the uri for the namespace
 * @param prefix a string, the prefix for the namespace
 * 
 * @return @c non-zero (true) if an XML Namespace with the given uri/prefix pair is 
 * contained in the XMLNamespaces_t of this XMLNode_t,  @c zero (false) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_hasNamespaceNS(const XMLNode_t *node, const char* uri, const char* prefix);


/**
 * Returns a string which is converted from a given XMLNode_t. 
 *
 * @param node XMLNode_t to be converted to a string.
 *
 * @return a string (char*) which is converted from a given XMLNode_t.
 *
 * @note returned char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
char *
XMLNode_toXMLString(const XMLNode_t *node);


/**
 * Returns a string which is converted from a given XMLNode_t. 
 *
 * @param node XMLNode_t to be converted to a string.
 *
 * @return a string (char*) which is converted from a given XMLNode_t.
 *
 * @note returned char* should be freed with safe_free() by the caller.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
const char *
XMLNode_convertXMLNodeToString(const XMLNode_t *node);


/**
 * Returns an XMLNode_t pointer which is converted from a given string containing
 * XML content.
 *
 * XMLNamespaces (the second argument) must be given if the corresponding 
 * xmlns attribute is not included in the string of the first argument. 
 *
 * @param xml string to be converted to a XML node.
 * @param xmlns XMLNamespaces_t structure the namespaces to set.
 *
 * @return pointer to XMLNode_t structure which is converted from a given string. 
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
XMLNode_t *
XMLNode_convertStringToXMLNode(const char * xml, const XMLNamespaces_t* xmlns);


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLNode_t structure is an XML element.
 * 
 * @param node XMLNode_t structure to be queried.
 *
 * @return @c non-zero (true) if this XMLNode_t structure is an XML element, @c zero (false) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_isElement (const XMLNode_t *node);


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLNode_t structure is an XML end element.
 * 
 * @param node XMLNode_t structure to be queried.
 *
 * @return @c non-zero (true) if this XMLNode_t structure is an XML end element, @c zero (false) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_isEnd (const XMLNode_t *node); 


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLNode_t structure is an XML end element for the given start element.
 * 
 * @param node XMLNode_t structure to be queried.
 * @param element XMLNode_t structure, element for which query is made.
 *
 * @return @c non-zero (true) if this XMLNode_t structure is an XML end element for the given
 * XMLNode_t structure start element, @c zero (false) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_isEndFor (const XMLNode_t *node, const XMLNode_t *element);


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLNode_t structure is an end of file marker.
 * 
 * @param node XMLNode_t structure to be queried.
 *
 * @return @c non-zero (true) if this XMLNode_t structure is an end of file (input) marker, @c zero (false)
 * otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_isEOF (const XMLNode_t *node);


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLNode_t structure is an XML start element.
 * 
 * @param node XMLNode_t structure to be queried.
 *
 * @return @c true if this XMLNode_t structure is an XML start element, @c false otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_isStart (const XMLNode_t *node);


/**
 * Predicate returning @c true or @c false depending on whether 
 * this XMLNode_t structure is an XML text element.
 * 
 * @param node XMLNode_t structure to be queried.
 *
 * @return @c non-zero (true) if this XMLNode_t structure is an XML text element, @c zero (false) otherwise.
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_isText (const XMLNode_t *node);


/**
 * Declares this XML start element is also an end element.
 *
 * @param node XMLNode_t structure to be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_setEnd (XMLNode_t *node);


/**
 * Declares this XMLNode_t structure is an end-of-file (input) marker.
 *
 * @param node XMLNode_t structure to be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_setEOF (XMLNode_t *node);


/**
 * Declares this XML start/end element is no longer an end element.
 *
 * @param node XMLNode_t structure to be set.
 *
 * @return integer value indicating success/failure of the
 * function.  @if clike The value is drawn from the
 * enumeration #OperationReturnValues_t. @endif@~ The possible values
 * returned by this function are:
 * @li @sbmlconstant{LIBSBML_OPERATION_SUCCESS, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_OPERATION_FAILED, OperationReturnValues_t}
 * @li @sbmlconstant{LIBSBML_INVALID_OBJECT, OperationReturnValues_t}
 *
 * @memberof XMLNode_t
 */
LIBLAX_EXTERN
int
XMLNode_unsetEnd (XMLNode_t *node);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END

#endif  /* !SWIG */
#endif  /* XMLNode_h */
