/**
 * @file    Layout.h
 * @brief   Definition of Layout for SBML Layout.
 * @author  Ralph Gauges
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
 * Copyright (C) 2004-2008 by European Media Laboratories Research gGmbH,
 *     Heidelberg, Germany
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ------------------------------------------------------------------------ -->
 *
 * @class Layout
 * @sbmlbrief{layout} The layout of a diagram of an SBML model.
 *
 * The Layout class stores layout information for some or all elements of the
 * SBML model as well as additional objects that need not be connected to the
 * model. The Layout has two attributes: id and name. Additionally, a
 * Dimensions element specifies the size of the layout.  The actual layout
 * elements are contained in several lists, namely: a
 * ListOfCompartmentGlyphs, a ListOfSpeciesGlyphs, a ListOfReactionGlyphs, a
 * ListOfTextGlyphs, and a ListOfAdditionalGraphicalObjects. Each of these
 * lists can only occur once, and, if present, are not allowed to be empty.
 */

#ifndef Layout_H__
#define Layout_H__


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/packages/layout/common/layoutfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>
#include <sbml/packages/layout/sbml/Dimensions.h>
#include <sbml/packages/layout/sbml/CompartmentGlyph.h>
#include <sbml/packages/layout/sbml/SpeciesGlyph.h>
#include <sbml/packages/layout/sbml/ReactionGlyph.h>
#include <sbml/packages/layout/sbml/TextGlyph.h>
#include <sbml/packages/layout/sbml/GraphicalObject.h>
#include <sbml/packages/layout/sbml/SpeciesReferenceGlyph.h>

#include <sbml/packages/layout/extension/LayoutExtension.h>

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * @class ListOfCompartmentGlyphs
 * @sbmlbrief{layout} A list of CompartmentGlyph objects.
 * 
 * The ListOfCompartmentGlyphs is a container for the CompartmentGlyph elements of a Layout.
 * 
 * @copydetails doc_what_is_listof
 *
 * @see CompartmentGlyph
 */
class LIBSBML_EXTERN ListOfCompartmentGlyphs : public ListOf
{
public:

  /**
   * Creates and returns a deep copy of this ListOfCompartmentGlyphs.
   * 
   * @return a (deep) copy of this ListOfCompartmentGlyphs.
   */
  virtual ListOfCompartmentGlyphs* clone () const;


  /**
   * Ctor.
   */
   ListOfCompartmentGlyphs(unsigned int level      = LayoutExtension::getDefaultLevel(),
                           unsigned int version    = LayoutExtension::getDefaultVersion(),
                           unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());


  /**
   * Ctor.
   */
   ListOfCompartmentGlyphs(LayoutPkgNamespaces* layoutns);


  /**
   * Returns the libSBML type code for the SBML objects
   * contained in this ListOf object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_LAYOUT_COMPARTMENTGLYPH, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of
   * this SBML object.
   *
   * @return the string of the name of this element
   */
  virtual const std::string& getElementName () const;


   /**
    * Creates an XMLNode object from this.
    */
    XMLNode toXML() const;


  /**
   * Get a CompartmentGlyph from the ListOfCompartmentGlyphs.
   *
   * @param n the index number of the CompartmentGlyph to get.
   * 
   * @return the nth CompartmentGlyph in this ListOfCompartmentGlyphs.
   *
   * @see size()
   */
  virtual CompartmentGlyph * get(unsigned int n); 


  /**
   * Get a CompartmentGlyph from the ListOfCompartmentGlyphs.
   *
   * @param n the index number of the CompartmentGlyph to get.
   * 
   * @return the nth CompartmentGlyph in this ListOfCompartmentGlyphs.
   *
   * @see size()
   */
  virtual const CompartmentGlyph * get(unsigned int n) const; 

  /**
   * Get a CompartmentGlyph from the ListOfCompartmentGlyphs
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the CompartmentGlyph to get.
   * 
   * @return CompartmentGlyph in this ListOfCompartmentGlyphs
   * with the given @p sid or @c NULL if no such
   * CompartmentGlyph exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual CompartmentGlyph* get (const std::string& sid);


  /**
   * Get a CompartmentGlyph from the ListOfCompartmentGlyphs
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the CompartmentGlyph to get.
   * 
   * @return CompartmentGlyph in this ListOfCompartmentGlyphs
   * with the given @p sid or @c NULL if no such
   * CompartmentGlyph exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const CompartmentGlyph* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfCompartmentGlyphs items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual CompartmentGlyph* remove (unsigned int n);


  /**
   * Removes item in this ListOfCompartmentGlyphs items with the given identifier.
   *
   * The caller owns the returned item and is responsible for deleting it.
   * If none of the items in this list have the identifier @p sid, then @c
   * NULL is returned.
   *
   * @param sid the identifier of the item to remove
   *
   * @return the item removed.  As mentioned above, the caller owns the
   * returned item.
   */
  virtual CompartmentGlyph* remove (const std::string& sid);

    
protected:

  /** @cond doxygenLibsbmlInternal */
  /**
   * Create and return an SBML object of this class, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);
  /** @endcond */
};

/**
 * @class ListOfSpeciesGlyphs
 * @sbmlbrief{layout} A list of SpeciesGlyph objects.
 * 
 * The ListOfSpeciesGlyphs is a container for the SpeciesGlyph elements of a Layout.
 * 
 * @copydetails doc_what_is_listof
 *
 * @see SpeciesGlyph
 */
class LIBSBML_EXTERN ListOfSpeciesGlyphs : public ListOf
{
public:

  /**
   * Creates and returns a deep copy of this ListOfSpeciesGlyphs.
   * 
   * @return a (deep) copy of this ListOfSpeciesGlyphs.
   */
  virtual ListOfSpeciesGlyphs* clone () const;


  /**
   * Ctor.
   */
   ListOfSpeciesGlyphs(unsigned int level      = LayoutExtension::getDefaultLevel(),
                       unsigned int version    = LayoutExtension::getDefaultVersion(),
                       unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());


  /**
   * Ctor.
   */
   ListOfSpeciesGlyphs(LayoutPkgNamespaces* layoutns);


  /**
   * Returns the libSBML type code for the SBML objects
   * contained in this ListOf object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_LAYOUT_SPECIESGLYPH, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of
   * this SBML object.
   *
   * @return the string of the name of this element
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a SpeciesGlyph from the ListOfSpeciesGlyphs.
   *
   * @param n the index number of the SpeciesGlyph to get.
   * 
   * @return the nth SpeciesGlyph in this ListOfSpeciesGlyphs.
   *
   * @see size()
   */
  virtual SpeciesGlyph * get(unsigned int n); 


  /**
   * Get a SpeciesGlyph from the ListOfSpeciesGlyphs.
   *
   * @param n the index number of the SpeciesGlyph to get.
   * 
   * @return the nth SpeciesGlyph in this ListOfSpeciesGlyphs.
   *
   * @see size()
   */
  virtual const SpeciesGlyph * get(unsigned int n) const; 

  /**
   * Get a SpeciesGlyph from the ListOfSpeciesGlyphs
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the SpeciesGlyph to get.
   * 
   * @return SpeciesGlyph in this ListOfSpeciesGlyphs
   * with the given @p sid or @c NULL if no such
   * SpeciesGlyph exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual SpeciesGlyph* get (const std::string& sid);


  /**
   * Get a SpeciesGlyph from the ListOfSpeciesGlyphs
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the SpeciesGlyph to get.
   * 
   * @return SpeciesGlyph in this ListOfSpeciesGlyphs
   * with the given @p sid or @c NULL if no such
   * SpeciesGlyph exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const SpeciesGlyph* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfSpeciesGlyphs items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual SpeciesGlyph* remove (unsigned int n);


  /**
   * Removes item in this ListOfSpeciesGlyphs items with the given identifier.
   *
   * The caller owns the returned item and is responsible for deleting it.
   * If none of the items in this list have the identifier @p sid, then @c
   * NULL is returned.
   *
   * @param sid the identifier of the item to remove
   *
   * @return the item removed.  As mentioned above, the caller owns the
   * returned item.
   */
  virtual SpeciesGlyph* remove (const std::string& sid);


   /**
    * Creates an XMLNode object from this.
    */
    XMLNode toXML() const;
    
protected:

  /** @cond doxygenLibsbmlInternal */
  /**
   * Create and return an SBML object of this class, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);
  /** @endcond */
};

/**
 * @class ListOfReactionGlyphs
 * @sbmlbrief{layout} A list of ReactionGlyph objects.
 * 
 * The ListOfReactionGlyphs is a container for the ReactionGlyph elements of a Layout.
 * 
 * @copydetails doc_what_is_listof
 *
 * @see ReactionGlyph
 */
class LIBSBML_EXTERN ListOfReactionGlyphs : public ListOf
{
public:

  /**
   * Creates and returns a deep copy of this ListOfReactionGlyphs.
   * 
   * @return a (deep) copy of this ListOfReactionGlyphs.
   */
  virtual ListOfReactionGlyphs* clone () const;


  /**
   * Ctor.
   */
   ListOfReactionGlyphs(unsigned int level      = LayoutExtension::getDefaultLevel(),
                        unsigned int version    = LayoutExtension::getDefaultVersion(),
                        unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());


  /**
   * Ctor.
   */
   ListOfReactionGlyphs(LayoutPkgNamespaces* layoutns);


  /**
   * Returns the libSBML type code for the SBML objects
   * contained in this ListOf object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_LAYOUT_REACTIONGLYPH, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of
   * this SBML object.
   *
   * @return the string of the name of this element
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a ReactionGlyph from the ListOfReactionGlyphs.
   *
   * @param n the index number of the ReactionGlyph to get.
   * 
   * @return the nth ReactionGlyph in this ListOfReactionGlyphs.
   *
   * @see size()
   */
  virtual ReactionGlyph * get(unsigned int n); 


  /**
   * Get a ReactionGlyph from the ListOfReactionGlyphs.
   *
   * @param n the index number of the ReactionGlyph to get.
   * 
   * @return the nth ReactionGlyph in this ListOfReactionGlyphs.
   *
   * @see size()
   */
  virtual const ReactionGlyph * get(unsigned int n) const; 

  /**
   * Get a ReactionGlyph from the ListOfReactionGlyphs
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the ReactionGlyph to get.
   * 
   * @return ReactionGlyph in this ListOfReactionGlyphs
   * with the given @p sid or @c NULL if no such
   * ReactionGlyph exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual ReactionGlyph* get (const std::string& sid);


  /**
   * Get a ReactionGlyph from the ListOfReactionGlyphs
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the ReactionGlyph to get.
   * 
   * @return ReactionGlyph in this ListOfReactionGlyphs
   * with the given @p sid or @c NULL if no such
   * ReactionGlyph exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const ReactionGlyph* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfReactionGlyphs items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual ReactionGlyph* remove (unsigned int n);


  /**
   * Removes item in this ListOfReactionGlyphs items with the given identifier.
   *
   * The caller owns the returned item and is responsible for deleting it.
   * If none of the items in this list have the identifier @p sid, then @c
   * NULL is returned.
   *
   * @param sid the identifier of the item to remove
   *
   * @return the item removed.  As mentioned above, the caller owns the
   * returned item.
   */
  virtual ReactionGlyph* remove (const std::string& sid);


   /**
    * Creates an XMLNode object from this.
    */
    XMLNode toXML() const;
    
protected:

  /** @cond doxygenLibsbmlInternal */
  /**
   * Create and return an SBML object of this class, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);
  /** @endcond */
};

/**
 * @class ListOfTextGlyphs
 * @sbmlbrief{layout} A list of TextGlyph objects.
 * 
 * The ListOfTextGlyphs is a container for the TextGlyph elements of a Layout.
 * 
 * @copydetails doc_what_is_listof
 *
 * @see TextGlyph
 */
class LIBSBML_EXTERN ListOfTextGlyphs : public ListOf
{
public:

  /**
   * Creates and returns a deep copy of this ListOfTextGlyphs.
   * 
   * @return a (deep) copy of this ListOfTextGlyphs.
   */
  virtual ListOfTextGlyphs* clone () const;


  /**
   * Ctor.
   */
   ListOfTextGlyphs(unsigned int level      = LayoutExtension::getDefaultLevel(),
                    unsigned int version    = LayoutExtension::getDefaultVersion(),
                    unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());


  /**
   * Ctor.
   */
   ListOfTextGlyphs(LayoutPkgNamespaces* layoutns);


  /**
   * Returns the libSBML type code for the SBML objects
   * contained in this ListOf object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_LAYOUT_TEXTGLYPH, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of
   * this SBML object.
   *
   * @return the string of the name of this element
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a TextGlyph from the ListOfTextGlyphs.
   *
   * @param n the index number of the TextGlyph to get.
   * 
   * @return the nth TextGlyph in this ListOfTextGlyphs.
   *
   * @see size()
   */
  virtual TextGlyph * get(unsigned int n); 


  /**
   * Get a TextGlyph from the ListOfTextGlyphs.
   *
   * @param n the index number of the TextGlyph to get.
   * 
   * @return the nth TextGlyph in this ListOfTextGlyphs.
   *
   * @see size()
   */
  virtual const TextGlyph * get(unsigned int n) const; 

  /**
   * Get a TextGlyph from the ListOfTextGlyphs
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the TextGlyph to get.
   * 
   * @return TextGlyph in this ListOfTextGlyphs
   * with the given @p sid or @c NULL if no such
   * TextGlyph exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual TextGlyph* get (const std::string& sid);


  /**
   * Get a TextGlyph from the ListOfTextGlyphs
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the TextGlyph to get.
   * 
   * @return TextGlyph in this ListOfTextGlyphs
   * with the given @p sid or @c NULL if no such
   * TextGlyph exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const TextGlyph* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfTextGlyphs items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual TextGlyph* remove (unsigned int n);


  /**
   * Removes item in this ListOfTextGlyphs items with the given identifier.
   *
   * The caller owns the returned item and is responsible for deleting it.
   * If none of the items in this list have the identifier @p sid, then @c
   * NULL is returned.
   *
   * @param sid the identifier of the item to remove
   *
   * @return the item removed.  As mentioned above, the caller owns the
   * returned item.
   */
  virtual TextGlyph* remove (const std::string& sid);


   /**
    * Creates an XMLNode object from this.
    */
    XMLNode toXML() const;
    
protected:

  /** @cond doxygenLibsbmlInternal */
  /**
   * Create and return an SBML object of this class, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);
  /** @endcond */
};

class LIBSBML_EXTERN Layout : public SBase
{
protected:
  /** @cond doxygenLibsbmlInternal */
  std::string mId;
  std::string mName;
  Dimensions mDimensions;
  ListOfCompartmentGlyphs mCompartmentGlyphs;
  ListOfSpeciesGlyphs mSpeciesGlyphs;
  ListOfReactionGlyphs mReactionGlyphs;
  ListOfTextGlyphs mTextGlyphs;
  ListOfGraphicalObjects mAdditionalGraphicalObjects;
  bool mDimensionsExplicitlySet;
  /** @endcond */

protected:
  /** @cond doxygenLibsbmlInternal */
  GraphicalObject*
  removeObjectWithId (ListOf* list, const std::string& id);
  /** @endcond */
  
  /** @cond doxygenLibsbmlInternal */
  const GraphicalObject*
  getObjectWithId (const ListOf* list, const std::string& id) const;
  /** @endcond */
  
  /** @cond doxygenLibsbmlInternal */
  GraphicalObject*
  getObjectWithId (ListOf* list, const std::string& id) ;
  /** @endcond */

public:

  /**
   * Creates a new Layout with the given level, version, and package version.
   */
   Layout(unsigned int level      = LayoutExtension::getDefaultLevel(),
          unsigned int version    = LayoutExtension::getDefaultVersion(),
          unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());


  /**
   * Creates a new Layout with the given LayoutPkgNamespaces object.
   */
   Layout(LayoutPkgNamespaces* layoutns);


  /**
   * Creates a new Layout with the given @p id and dimensions.
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */
  Layout (LayoutPkgNamespaces* layoutns, const std::string& id, const Dimensions* dimensions);


  /**
   * Creates a new Layout from the given XMLNode
   * (only for SBML Level2)
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */
  Layout (const XMLNode& node, unsigned int l2version = 4);

  /**
   * Copy constructor.
   */
   Layout(const Layout& source);

  /**
   * Assignment operator.
   */
   Layout& operator=(const Layout& source);



  /**
   * Destructor.
   */ 
  
  virtual ~Layout ();


  /**
   * Does nothing since no defaults are defined for Layout.
   */ 
  
  void initDefaults ();    

        
  /**
   * Returns the value of the "id" attribute of this Layout.
   */
  virtual const std::string& getId () const;


  /**
   * Predicate returning @c true or @c false depending on whether this
   * Layout's "id" attribute has been set.
   */
  virtual bool isSetId () const;

  
  /**
   * Sets the value of the "id" attribute of this Layout.
   */
  virtual int setId (const std::string& id);


  /**
   * Unsets the value of the "id" attribute of this Layout.
   */
  virtual int unsetId ();


  /**
   * Returns the value of the "name" attribute of this Layout.
   */
  virtual const std::string& getName () const;


  /**
   * Predicate returning @c true or @c false depending on whether this
   * Layout's "name" attribute has been set.
   */
  virtual bool isSetName () const;

  
  /**
   * Sets the value of the "name" attribute of this Layout.
   */
  virtual int setName (const std::string& name);


  /**
   * Unsets the value of the "name" attribute of this Layout.
   */
  virtual int unsetName ();


  /**
   * Returns the dimensions of the layout.
   */ 
  
  const Dimensions* getDimensions () const;

  /**
   * Returns the dimensions of the layout.
   */ 
  
  Dimensions* getDimensions ();

  /**
   * Sets the dimensions of the layout.
   */ 
    
  void setDimensions (const Dimensions* dimensions);

  /**
   * Predicate returning true if the dimensions has been set
   */
  bool getDimensionsExplicitlySet() const;

  /**
   * Returns the ListOf object that holds all compartment glyphs.
   */ 
  
  const ListOfCompartmentGlyphs* getListOfCompartmentGlyphs () const;

  /**
   * Returns the ListOf object that holds all species glyphs.
   */ 
   
  const ListOfSpeciesGlyphs* getListOfSpeciesGlyphs () const;

  /**
   * Returns the ListOf object that holds all reaction glyphs.
   */ 
   
  const ListOfReactionGlyphs* getListOfReactionGlyphs () const;

  /**
   * Returns the ListOf object that holds all text glyphs.
   */ 
   
  const ListOfTextGlyphs* getListOfTextGlyphs () const;

  /**
   * Returns the ListOf object that holds all additonal graphical objects.
   */ 
   
  const ListOfGraphicalObjects* getListOfAdditionalGraphicalObjects () const;
  
  /**
   * Returns the ListOf object that holds all compartment glyphs.
   */ 
  
  ListOfCompartmentGlyphs* getListOfCompartmentGlyphs ();

  /**
   * Returns the ListOf object that holds all species glyphs.
   */ 
   
  ListOfSpeciesGlyphs* getListOfSpeciesGlyphs ();

  /**
   * Returns the ListOf object that holds all reaction glyphs.
   */ 
   
  ListOfReactionGlyphs* getListOfReactionGlyphs ();

  /**
   * Returns the ListOf object that holds all text glyphs.
   */ 
   
  ListOfTextGlyphs* getListOfTextGlyphs ();

  /**
   * Returns the ListOf object that holds all additional graphical objects.
   */ 
   
  ListOfGraphicalObjects* getListOfAdditionalGraphicalObjects ();

  
  /**
   * Returns a List of all child SBase objects, including those nested to an
   * arbitrary depth
   *
   * @return a List* of pointers to all children objects.
   */
  virtual List* getAllElements(ElementFilter* filter=NULL);

  /**
   * Returns the compartment glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
  const CompartmentGlyph* getCompartmentGlyph (unsigned int index) const;

  /**
   * Returns the compartment glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
  CompartmentGlyph* getCompartmentGlyph (unsigned int index) ;

  /**
   * Returns the species glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
  SpeciesGlyph* getSpeciesGlyph (unsigned int index) ;

  /**
   * Returns the species glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
  const SpeciesGlyph* getSpeciesGlyph (unsigned int index) const;

  /**
   * Returns the reaction glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
  const ReactionGlyph* getReactionGlyph (unsigned int index) const;

  /**
   * Returns the reaction glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
  ReactionGlyph* getReactionGlyph (unsigned int index) ;

  /**
   * Returns the text glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
  const TextGlyph* getTextGlyph (unsigned int index) const;

  /**
   * Returns the text glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
  TextGlyph* getTextGlyph (unsigned int index) ;

  /**
   * Returns the additional graphical object with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
  const GraphicalObject* getAdditionalGraphicalObject (unsigned int index) const;

  /**
   * Returns the additional graphical object with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
  GraphicalObject* getAdditionalGraphicalObject (unsigned int index) ;

  /**
   * Returns the general glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */
  GeneralGlyph* getGeneralGlyph (unsigned int index);
  
  /**
   * Returns the general glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */
  const GeneralGlyph* getGeneralGlyph (unsigned int index) const;


  /**
   * Returns the compartment glyph that has the given @p id, or @c NULL if no
   * compartment glyph has the id.
   */
  
  const CompartmentGlyph* getCompartmentGlyph (const std::string& id) const;

  /**
   * Returns the species glyph that has the given @p id, or @c NULL if no species
   * glyph has the id.
   */
  
  const SpeciesGlyph* getSpeciesGlyph (const std::string& id) const;
        
  /**
   * Returns the reaction glyph that has the given @p id, or @c NULL if no
   * reaction glyph has the id.
   */
  
  const ReactionGlyph* getReactionGlyph (const std::string& id) const;

  /**
   * Returns the text glyph that has the given @p id, or @c NULL if no text glyph
   * has the id.
   */
  
  const TextGlyph* getTextGlyph (const std::string& id) const;

  /**
   * Returns the additional graphical object that has the given @p id, or @c NULL
   * if no graphical object has the id.
   */
  
  const GraphicalObject* getAdditionalGraphicalObject (const std::string& id) const;

  /**
   * Returns the general glyph that has the given @p id, or @c NULL
   * if no graphical object has the id.
   */
  
  const GeneralGlyph* getGeneralGlyph (const std::string& id) const;


  /**
   * Returns the compartment glyph that has the given @p id, or @c NULL if no
   * compartment glyph has the id.
   */
  
  CompartmentGlyph* getCompartmentGlyph (const std::string& id) ;

  /**
   * Returns the species glyph that has the given @p id, or @c NULL if no species
   * glyph has the id.
   */
  
  SpeciesGlyph* getSpeciesGlyph (const std::string& id) ;
        
  /**
   * Returns the reaction glyph that has the given @p id, or @c NULL if no
   * reaction glyph has the id.
   */
  
  ReactionGlyph* getReactionGlyph (const std::string& id) ;

  /**
   * Returns the text glyph that has the given @p id, or @c NULL if no text glyph
   * has the id.
   */
  
  TextGlyph* getTextGlyph (const std::string& id) ;

  /**
   * Returns the additional graphical object that has the given @p id, or @c NULL
   * if no graphical object has the id.
   */
  
  GraphicalObject* getAdditionalGraphicalObject (const std::string& id) ;

  /**
   * Returns the general glyph that has the given @p id, or @c NULL
   * if no graphical object has the id.
   */
  GeneralGlyph* getGeneralGlyph (const std::string& id);

  /**
   * Adds a new compartment glyph.
   */
  
  void addCompartmentGlyph (const CompartmentGlyph* glyph);

  /**
   * Adds a new species glyph.
   */
  
  void addSpeciesGlyph (const SpeciesGlyph* glyph);

  /**
   * Adds a new reaction glyph.
   */
  
  void addReactionGlyph (const ReactionGlyph* glyph);

  /**
   * Adds a new text glyph.
   */
  
  void addTextGlyph (const TextGlyph* glyph);

  /**
   * Adds a new additional graphical object glyph.
   */
  
  void addAdditionalGraphicalObject (const GraphicalObject* glyph);

  /**
   * Adds a new general glyph.
   */
  void addGeneralGlyph (const GeneralGlyph* glyph);


  /**
   * Returns the number of compartment glyphs for the layout.
   */
  
  unsigned int getNumCompartmentGlyphs () const;

  /**
   * Returns the number of species glyphs for the layout.
   */
   
  unsigned int getNumSpeciesGlyphs () const;

  /**
   * Returns the number of reaction glyphs for the layout.
   */
  
  unsigned int getNumReactionGlyphs () const;

  /**
   * Returns the number of text glyphs for the layout.
   */
   
  unsigned int getNumTextGlyphs () const;

  /**
   * Returns the number of additional graphical objects for the layout.
   */
  unsigned int getNumAdditionalGraphicalObjects () const;

  /**
   * Returns the number of general glyphs for the layout.
   */
  unsigned int getNumGeneralGlyphs () const;
  

  /**
   * Creates a CompartmentGlyph object, adds it to the end of the
   * compartment glyph objects list and returns a pointer to the newly
   * created object.
   */
  
  CompartmentGlyph* createCompartmentGlyph ();

  /**
   * Creates a SpeciesGlyph object, adds it to the end of the species glyph
   * objects list and returns a pointer to the newly created object.
   */
  
  SpeciesGlyph* createSpeciesGlyph ();

  /**
   * Creates a ReactionGlyph object, adds it to the end of the reaction
   * glyph objects list and returns a pointer to the newly created
   * object.
   */
  
  ReactionGlyph* createReactionGlyph ();

  /**
   * Creates a GeneralGlyph object, adds it to the end of the additional 
   * objects list and returns a reference to the newly created object.
   */
  GeneralGlyph*  createGeneralGlyph();

  /**
   * Creates a TextGlyph object, adds it to the end of the text glyph
   * objects list and returns a pointer to the newly created object.
   */
  
  TextGlyph* createTextGlyph ();

  /**
   * Creates a GraphicalObject object, adds it to the end of the additional
   * graphical objects list and returns a pointer to the newly created
   * object.
   */
  
  GraphicalObject* createAdditionalGraphicalObject ();

  /**
   * Creates a new SpeciesReferenceGlyph for the last ReactionGlyph and
   * adds it to its list of SpeciesReferenceGlyph objects.  A pointer to
   * the newly created object is returned.
   */
  
  SpeciesReferenceGlyph* createSpeciesReferenceGlyph();


  /**
   * Creates a new LineSegment for the Curve object of the last
   * ReactionGlyph or the last SpeciesReferenceGlyph in the last
   * ReactionGlyph and adds it to its list of SpeciesReferenceGlyph
   * objects.  A pointer to the newly created object is returned.
   */
  
  LineSegment* createLineSegment ();

  /**
   * Creates a new CubicBezier for the Curve object of the last
   * ReactionGlyph or the last SpeciesReferenceGlyph in the last
   * ReactionGlyph and adds it to its list of SpeciesReferenceGlyph
   * objects.  A pointer to the newly created object is returned.
   */
  
  CubicBezier* createCubicBezier ();

  /**
   * Removes the compartment glyph with the given index from the layout.
   * A pointer to the compartment glyph that was removed is returned.
   * If no compartment glyph has been removed, @c NULL is returned.
   */
  
  CompartmentGlyph* removeCompartmentGlyph(unsigned int index);

  /**
   * Removes the species glyph with the given index from the layout.
   * A pointer to the species glyph that was removed is returned.
   * If no species glyph has been removed, @c NULL is returned.
   */
  
  SpeciesGlyph* removeSpeciesGlyph(unsigned int index);
  
  /**
   * Removes the reaction glyph with the given index from the layout.
   * A pointer to the reaction glyph that was removed is returned.
   * If no reaction glyph has been removed, @c NULL is returned.
   */
  
  ReactionGlyph* removeReactionGlyph(unsigned int index);
  
  /**
   * Removes the text glyph with the given index from the layout.
   * A pointer to the text glyph that was removed is returned.
   * If no text glyph has been removed, @c NULL is returned.
   */
  
  TextGlyph* removeTextGlyph(unsigned int index);
  
  /**
   * Removes the graphical object with the given index from the layout.
   * A pointer to the graphical object that was removed is returned.
   * If no graphical object has been removed, @c NULL is returned.
   */
  
  GraphicalObject* removeAdditionalGraphicalObject(unsigned int index);

  /**
   * Remove the compartment glyph with the given @p id.
   * A pointer to the removed compartment glyph is returned.
   * If no compartment glyph has been removed, @c NULL is returned.
   */
  
  CompartmentGlyph*
  removeCompartmentGlyph(const std::string id);


  /**
   * Remove the species glyph with the given @p id.
   * A pointer to the removed species glyph is returned.
   * If no species glyph has been removed, @c NULL is returned.
   */
  
  SpeciesGlyph*
  removeSpeciesGlyph(const std::string id);


  /**
   * Remove the reaction glyph with the given @p id.
   * A pointer to the removed reaction glyph is returned.
   * If no reaction glyph has been removed, @c NULL is returned.
   */
  
  ReactionGlyph*
  removeReactionGlyph(const std::string id);


  /**
   * Remove the species reference glyph with the given @p id.
   * A pointer to the removed species reference glyph is returned.
   * If no species reference glyph has been removed, @c NULL is returned.
   */
  
  SpeciesReferenceGlyph*
  removeSpeciesReferenceGlyph(const std::string id);


  /**
   * Remove the text glyph with the given @p id.
   * A pointer to the removed text glyph is returned.
   * If no text glyph has been removed, @c NULL is returned.
   */
  
  TextGlyph*
  removeTextGlyph(const std::string id);


  /**
   * Remove the graphical object with the given @p id.
   * A pointer to the removed graphical object is returned.
   * If no graphical object has been removed, @c NULL is returned.
   */
  
  GraphicalObject*
  removeAdditionalGraphicalObject(const std::string id);

  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses should override this method to write out their contained
   * SBML objects as XML elements.  Be sure to call your parents
   * implementation of this method as well.  For example:
   *
   *   SBase::writeElements(stream);
   *   mReactants.write(stream);
   *   mProducts.write(stream);
   *   ...
   */
  virtual void writeElements (XMLOutputStream& stream) const;
  /** @endcond */

  /**
   * Returns the XML element name of
   * this SBML object.
   *
   * @return the string of the name of this element
   */
  virtual const std::string& getElementName () const ;


  /**
   * Creates and returns a deep copy of this Layout.
   * 
   * @return a (deep) copy of this Layout.
   */
  virtual Layout* clone () const;


  /**
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_LAYOUT_LAYOUT, SBMLLayoutTypeCode_t}
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


  /**
   * Accepts the given SBMLVisitor.
   *
   * @return the result of calling <code>v.visit()</code>, which indicates
   * whether or not the Visitor would like to visit the SBML object's next
   * sibling object (if available).
   */
  virtual bool accept (SBMLVisitor& v) const;
   

   /**
    * Creates an XMLNode object from this.
    */
    XMLNode toXML() const;


  /** @cond doxygenLibsbmlInternal */
  /**
   * Sets the parent SBMLDocument of this SBML object.
   *
   * @param d the SBMLDocument object to use
   */
  virtual void setSBMLDocument (SBMLDocument* d);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Sets this SBML object to child SBML objects (if any).
   * (Creates a child-parent relationship by the parent)
   *
   * Subclasses must override this function if they define
   * one ore more child elements.
   * Basically, this function needs to be called in
   * constructor, copy constructor, assignment operator.
   *
   * @see setSBMLDocument
   * @see enablePackageInternal
   */
  virtual void connectToChild ();
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Enables/Disables the given package with this element and child
   * elements (if any).
   * (This is an internal implementation for enablePakcage function)
   *
   * @note Subclasses in which one or more child elements are defined
   * must override this function.
   */
  virtual void enablePackageInternal(const std::string& pkgURI,
                                     const std::string& pkgPrefix, bool flag);
  /** @endcond */

    
protected:
  /** @cond doxygenLibsbmlInternal */
  /**
   * Create and return an SBML object of this class, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or NULL if the token was not recognized.
   */
  virtual SBase*
  createObject (XMLInputStream& stream);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses should override this method to get the list of
   * expected attributes.
   * This function is invoked from corresponding readAttributes()
   * function.
   */
  virtual void addExpectedAttributes(ExpectedAttributes& attributes);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses should override this method to read values from the given
   * XMLAttributes set into their specific fields.  Be sure to call your
   * parents implementation of this method as well.
   */
  virtual void readAttributes (const XMLAttributes& attributes, 
                               const ExpectedAttributes& expectedAttributes);
  /** @endcond */


  /** @cond doxygenLibsbmlInternal */
  /**
   * Subclasses should override this method to write their XML attributes
   * to the XMLOutputStream.  Be sure to call your parents implementation
   * of this method as well.  For example:
   *
   *   SBase::writeAttributes(stream);
   *   stream.writeAttribute( "id"  , mId   );
   *   stream.writeAttribute( "name", mName );
   *   ...
   */
  virtual void writeAttributes (XMLOutputStream& stream) const;
  /** @endcond */

};


/**
 * @class ListOfLayouts
 * @sbmlbrief{layout} A list of Layout objects.
 * 
 * The ListOfLayouts is a container for the Layout elements of an extended Model element.
 * 
 * @copydetails doc_what_is_listof
 *
 * @see Layout
 */
class LIBSBML_EXTERN ListOfLayouts : public ListOf
{
public:

  /**
   * Creates and returns a deep copy of this ListOfLayouts.
   * 
   * @return a (deep) copy of this ListOfLayouts.
   */
  virtual ListOfLayouts* clone () const;


  /**
   * Ctor.
   */
   ListOfLayouts(unsigned int level      = LayoutExtension::getDefaultLevel(), 
                 unsigned int version    = LayoutExtension::getDefaultVersion(), 
                 unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());


  /**
   * Ctor.
   */
   ListOfLayouts(LayoutPkgNamespaces* layoutns);


  /**
   * Returns the libSBML type code for the SBML objects
   * contained in this ListOf object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_LAYOUT_LAYOUT, SBMLTypeCode_t} (default).
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getItemTypeCode () const;


  /**
   * Returns the XML element name of
   * this SBML object.
   *
   * @return the string of the name of this element
   */
  virtual const std::string& getElementName () const;


  /**
   * Get a Layout from the ListOfLayouts.
   *
   * @param n the index number of the Layout to get.
   * 
   * @return the nth Layout in this ListOfLayouts.
   *
   * @see size()
   */
  virtual Layout * get(unsigned int n); 


  /**
   * Get a Layout from the ListOfLayouts.
   *
   * @param n the index number of the Layout to get.
   * 
   * @return the nth Layout in this ListOfLayouts.
   *
   * @see size()
   */
  virtual const Layout * get(unsigned int n) const; 

  /**
   * Get a Layout from the ListOfLayouts
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the Layout to get.
   * 
   * @return Layout in this ListOfLayouts
   * with the given @p id or @c NULL if no such
   * Layout exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual Layout* get (const std::string& sid);


  /**
   * Get a Layout from the ListOfLayouts
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the Layout to get.
   * 
   * @return Layout in this ListOfLayouts
   * with the given @p sid or @c NULL if no such
   * Layout exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const Layout* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfLayouts items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual Layout* remove (unsigned int n);


  /**
   * Removes item in this ListOfLayouts items with the given identifier.
   *
   * The caller owns the returned item and is responsible for deleting it.
   * If none of the items in this list have the identifier @p sid, then @c
   * NULL is returned.
   *
   * @param sid the identifier of the item to remove
   *
   * @return the item removed.  As mentioned above, the caller owns the
   * returned item.
   */
  virtual Layout* remove (const std::string& sid);


   /**
    * Creates an XMLNode object from this.
    */
    XMLNode toXML() const;


    void resetElementNamespace(const std::string& uri);
    
protected:

  /** @cond doxygenLibsbmlInternal */
  /**
   * Create and return an SBML object of this class, if present.
   *
   * @return the SBML object corresponding to next XMLToken in the
   * XMLInputStream or NULL if the token was not recognized.
   */
  virtual SBase* createObject (XMLInputStream& stream);

  virtual void writeXMLNS (XMLOutputStream& stream) const;
  /** @endcond */
};


LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * Creates a new Layout_t and returns a pointer to it.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
Layout_t *
Layout_create (void);

/**
 * Creates a new Layout_t with the given @p id and returns a pointer to it.
 *
 * @param sid The id of the created Layout_t
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
Layout_t *
Layout_createWith (const char *sid);

/**
 * Creates a Layout_t structure from a template.
 *
 * @param temp The Layout_t structure to copy
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
Layout_t *
Layout_createFrom (const Layout_t *temp);

/**
 * Creates a new Layout_t with the given width, height and depth and returns
 * a pointer to it.  The depth value defaults to 0.0.
 *
 * @param sid    The id of the created Layout_t
 * @param width  The value of the width.
 * @param height The value of the height.
 * @param depth  The value of the depth.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
Layout_t *
Layout_createWithSize (const char *sid,
                       double width, double height, double depth);

/**
 * Creates a new Layout_t with the given Dimensions_t and returns a pointer to
 * it.
 *
 * @param sid        The id of the created Layout_t
 * @param dimensions The dimensions of the created Layout_t structure.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
Layout_t *
Layout_createWithDimensions (const char *sid, const Dimensions_t *dimensions);

/** 
 * Frees the memory for the given layout.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
void 
Layout_free (Layout_t *l);


/**
 * Sets the dimensions of the given Layout_t structure
 *
 * @param l The Layout_t structure
 * @param dimensions The dimensions to use for the Layout_t structure.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
void
Layout_setDimensions (Layout_t *l, const Dimensions_t *dimensions);

/**
 * Adds a new compartment glyph to the list of compartment glyphs.
 *
 * @param l The Layout_t structure
 * @param cg The CompartmentGlyph_t to add to the Layout_t structure.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
void
Layout_addCompartmentGlyph (Layout_t *l, CompartmentGlyph_t *cg);

/**
 * Adds a new species glyph to the list of species glyphs.
 *
 * @param l The Layout_t structure
 * @param sg The SpeciesGlyph_t to add to the Layout_t structure.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
void
Layout_addSpeciesGlyph (Layout_t *l, SpeciesGlyph_t *sg);

/**
 * Adds a new reaction glyph to the list of reaction glyphs.
 *
 * @param l The Layout_t structure
 * @param rg The ReactionGlyph_t to add to the Layout_t structure.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
void
Layout_addReactionGlyph (Layout_t *l, ReactionGlyph_t *rg);

/**
 * Adds a new GraphicalObject to the list of additional graphical objects.
 *
 * @param l The Layout_t structure
 * @param go The GraphicalObject_t to add to the Layout_t structure.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
void
Layout_addAdditionalGraphicalObject (Layout_t *l, GraphicalObject_t *go);

/**
 * Adds a new TextGlyph to the list of text glyphs.
 *
 * @param l The Layout_t structure
 * @param tg The TextGlyph_t to add to the Layout_t structure.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
void
Layout_addTextGlyph (Layout_t *l, TextGlyph_t *tg);


/**
 * Returns a pointer to the CompartmentGlyph_t with the given index.
 *
 * @param l The Layout_t structure
 * @param index The index of the desired CompartmentGlyph_t.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
CompartmentGlyph_t *
Layout_getCompartmentGlyph (Layout_t *l, unsigned int index);

/**
 * Returns a pointer to the SpeciesGlyph_t with the given index.
 *
 * @param l The Layout_t structure
 * @param index The index of the desired SpeciesGlyph_t.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
SpeciesGlyph_t *
Layout_getSpeciesGlyph (Layout_t *l, unsigned int index);


/**
 * Returns a pointer to the ReactionGlyph_t with the given index.
 *
 * @param l The Layout_t structure
 * @param index The index of the desired ReactionGlyph_t.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
ReactionGlyph_t *
Layout_getReactionGlyph (Layout_t *l, unsigned int index);


/**
 * Returns a pointer to the AdditionalGraphicalObject_t with the given index.
 *
 * @param l The Layout_t structure
 * @param index The index of the desired GraphicalObject_t.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
GraphicalObject_t *
Layout_getAdditionalGraphicalObject (Layout_t *l, unsigned int index);

/**
 * Returns a pointer to the GraphicalObject_t with the given index.
 *
 * @param l The Layout_t structure
 * @param index The index of the desired TextGlyph_t.
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
TextGlyph_t *
Layout_getTextGlyph (Layout_t *l, unsigned int index);


/**
 * Returns a pointer to the list of CompartmentGlyph_t's.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
ListOf_t *
Layout_getListOfCompartmentGlyphs (Layout_t *l);

/**
 * Returns a pointer to the list of SpeciesGlyphs.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
ListOf_t *
Layout_getListOfSpeciesGlyphs (Layout_t *l);


/**
 * Returns a pointer to the list of ReactionGlyphs.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
ListOf_t *
Layout_getListOfReactionGlyphs (Layout_t *l);


/**
 * Returns a pointer to the list of additional GraphicalObjects.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
ListOf_t *
Layout_getListOfAdditionalGraphicalObjects (Layout_t *l);

/**
 * Returns a pointer to the list of TextGlyphs.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
ListOf_t *
Layout_getListOfTextGlyphs (Layout_t *l);


/**
 * Returns a Dimensions_t pointer from the layout.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
Dimensions_t*
Layout_getDimensions(Layout_t *l);

/**
 * Returns the number of CompartmentGlyphs.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
unsigned int
Layout_getNumCompartmentGlyphs (const Layout_t *l);

/**
 * Returns the number of SpeciesGlyphs.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
unsigned int
Layout_getNumSpeciesGlyphs (const Layout_t *l);


/**
 * Returns the number of ReactionGlyphs.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
unsigned int
Layout_getNumReactionGlyphs (const Layout_t *l);

/**
 * Returns the number of additional GraphicalObjects.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
unsigned int
Layout_getNumAdditionalGraphicalObjects (const Layout_t *l);

/**
 * Returns the number of TextGlyphs.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
unsigned int
Layout_getNumTextGlyphs (const Layout_t *l);

/**
 * Removes the compartment glyph with the given index.  If the index is
 * invalid, nothing is deleted.
 *
 * @param l The Layout_t structure
 * @param index The index of the CompartmentGlyph_t to remove.
 *
 * @memberof Layout_t
 */ 
LIBSBML_EXTERN
CompartmentGlyph_t *
Layout_removeCompartmentGlyph (Layout_t *l, unsigned int index);

/**
 * Removes the species glyph with the given index.  If the index is
 * invalid, nothing is deleted.
 *
 * @param l The Layout_t structure
 * @param index The index of the SpeciesGlyph_t to remove.
 *
 * @memberof Layout_t
 */ 
LIBSBML_EXTERN
SpeciesGlyph_t *
Layout_removeSpeciesGlyph (Layout_t *l, unsigned int index);

/**
 * Removes the reaction glyph with the given index.  If the index is
 * invalid, nothing is deleted.
 *
 * @param l The Layout_t structure
 * @param index The index of the ReactionGlyph_t to remove.
 *
 * @memberof Layout_t
 */ 
LIBSBML_EXTERN
ReactionGlyph_t *
Layout_removeReactionGlyph (Layout_t *l, unsigned int index);
 
/**
 * Removes the text glyph with the given index.  If the index is invalid,
 * nothing is deleted.
 *
 * @param l The Layout_t structure
 * @param index The index of the TextGlyph_t to remove.
 *
 * @memberof Layout_t
 */ 
LIBSBML_EXTERN
TextGlyph_t *
Layout_removeTextGlyph (Layout_t *l, unsigned int index);
 
/**
 * Removes the graphical object with the given index.  If the index is
 * invalid, nothing is deleted.
 *
 * @param l The Layout_t structure
 * @param index The index of the GraphicalObject_t to remove.
 *
 * @memberof Layout_t
 */ 
LIBSBML_EXTERN
GraphicalObject_t *
Layout_removeAdditionalGraphicalObject (Layout_t *l, unsigned int index);

/**
 * Removes the compartment glyph with the given @p id.  If the id is
 * not found, nothing is deleted.
 *
 * @param l The Layout_t structure
 * @param id The id of the CompartmentGlyph_t to remove.
 *
 * @memberof Layout_t
 */ 
LIBSBML_EXTERN
CompartmentGlyph_t *
Layout_removeCompartmentGlyphWithId (Layout_t *l, const char* id);

/**
 * Removes the species glyph with the given @p id.  If the id is
 * not found, nothing is deleted.
 *
 * @param l The Layout_t structure
 * @param id The id of the SpeciesGlyph_t to remove.
 *
 * @memberof Layout_t
 */ 
LIBSBML_EXTERN
SpeciesGlyph_t *
Layout_removeSpeciesGlyphWithId (Layout_t *l, const char* id);

/**
 * Removes the species reference glyph with the given @p id.  If the id is
 * not found, nothing is deleted.
 *
 * @param l The Layout_t structure
 * @param id The id of the SpeciesReferenceGlyph_t to remove.
 *
 * @memberof Layout_t
 */ 
LIBSBML_EXTERN
SpeciesReferenceGlyph_t *
Layout_removeSpeciesReferenceGlyphWithId (Layout_t *l, const char* id);

/**
 * Removes the reaction glyph with the given @p id.  If the id is
 * not found, nothing is deleted.
 *
 * @param l The Layout_t structure
 * @param id The id of the ReactionGlyph_t to remove.
 *
 * @memberof Layout_t
 */ 
LIBSBML_EXTERN
ReactionGlyph_t *
Layout_removeReactionGlyphWithId (Layout_t *l, const char* id);
 
/**
 * Removes the text glyph with the given @p id.  If the id is not found,
 * nothing is deleted.
 *
 * @param l The Layout_t structure
 * @param id The id of the TextGlyph_t to remove.
 *
 * @memberof Layout_t
 */ 
LIBSBML_EXTERN
TextGlyph_t *
Layout_removeTextGlyphWithId (Layout_t *l, const char* id);
 
/**
 * Removes the graphical object with the given @p id.  If the id is
 * not found, nothing is deleted.
 *
 * @param l The Layout_t structure
 * @param id The id of the GraphicalObject_t to remove.
 *
 * @memberof Layout_t
 */ 
LIBSBML_EXTERN
GraphicalObject_t *
Layout_removeAdditionalGraphicalObjectWithId (Layout_t *l, const char* id);
    
/**
 * Does nothing since no defaults are defined for Layout_t.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */ 
LIBSBML_EXTERN
void
Layout_initDefaults (Layout_t *l);


/**
 * Creates a ComparmentGlyph_t structure, adds it to the end of the
 * compartment glyphs list and returns a pointer to the newly
 * created structure.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
CompartmentGlyph_t *
Layout_createCompartmentGlyph (Layout_t *l);

/**
 * Creates a SpeciesGlyph_t structure, adds it to the end of the species glyphs
 * list and returns a pointer to the newly created structure.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
SpeciesGlyph_t *
Layout_createSpeciesGlyph (Layout_t *l);


/**
 * Creates a ReactionGlyph_t structure, adds it to the end of the reaction
 * glyphs list and returns a pointer to the newly created structure.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
ReactionGlyph_t *
Layout_createReactionGlyph (Layout_t *l);

/**
 * Creates a GeneralGlyph_t structure, adds it to the end of the additional
 * objects list and returns a pointer to the newly created structure.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
GeneralGlyph_t *
Layout_createGeneralGlyph (Layout_t *l);


/**
 * Creates a TextGlyph_t structure, adds it to the end of the text glyphs
 * list and returns a pointer to the newly created structure.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
TextGlyph_t *
Layout_createTextGlyph (Layout_t *l);


/**
 * Creates a GraphicalObject_t structure, adds it to the end of the additional
 * graphical objects list and returns a pointer to the newly created
 * structure.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
GraphicalObject_t *
Layout_createAdditionalGraphicalObject (Layout_t *l);

/**
 * @return a (deep) copy of this Layout_t.
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
Layout_t *
Layout_clone (const Layout_t *l);


/**
 * Returns non-zero if the id is set
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
int
Layout_isSetId (const Layout_t *l);


/**
 * Returns the id
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
const char *
Layout_getId (const Layout_t *l);


/**
 * Sets the id
 *
 * @param l The Layout_t structure
 * @param sid The string to use as the ID of the Layout_t
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
int
Layout_setId (Layout_t *l, const char *sid);


/**
 * Unsets the id
 *
 * @param l The Layout_t structure
 *
 * @memberof Layout_t
 */
LIBSBML_EXTERN
void
Layout_unsetId (Layout_t *l);



END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* !SWIG */
#endif  /* Layout_H__ */
