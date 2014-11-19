/**
 * @file    GeneralGlyph.h
 * @brief   Definition of GeneralGlyph for SBML Layout.
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
 * @class GeneralGlyph
 * @sbmlbrief{layout} A glyph for miscellaneous items.
 *
 * The GeneralGlyph is used to facilitate the representation of elements
 * other than Compartment, Species and Reaction and thus can be used for the
 * display of relationships of Rule or elements defined by other SBML
 * packages. It closely follows the structure of the ReactionGlyph.
 * GeneralGlyph is defined to have an optional attribute reference as well as
 * the elements curve, listOfReferenceGlyphs and listOfSubGlyphs.
 */

#ifndef GeneralGlyph_H__
#define GeneralGlyph_H__


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/packages/layout/common/layoutfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/ListOf.h>
#include <sbml/packages/layout/sbml/Curve.h>
#include <sbml/packages/layout/sbml/ReferenceGlyph.h>
#include <sbml/packages/layout/sbml/GraphicalObject.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * @class ListOfReferenceGlyphs
 * @sbmlbrief{layout} A list of ReferenceGlyph objects.
 * 
 * The ListOfReferenceGlyphs is a container for the ReferenceGlyph elements of a GeneralGlyph.
 * 
 * @copydetails doc_what_is_listof
 *
 * @see ReferenceGlyph
 */
class LIBSBML_EXTERN ListOfReferenceGlyphs : public ListOf
{
public:

  /**
   * Creates and returns a deep copy of this ListOfReferenceGlyphs.
   * 
   * @return a (deep) copy of this ListOfReferenceGlyphs.
   */
  virtual ListOfReferenceGlyphs* clone () const;

  /**
   * Ctor.
   */
   ListOfReferenceGlyphs(unsigned int level      = LayoutExtension::getDefaultLevel(), 
                                unsigned int version    = LayoutExtension::getDefaultVersion(), 
                                unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());

  /**
   * Ctor.
   */
   ListOfReferenceGlyphs(LayoutPkgNamespaces* layoutns);


   /**
   * Returns the libSBML type code for the SBML objects
   * contained in this ListOf object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_LAYOUT_REFERENCEGLYPH, SBMLTypeCode_t} (default).
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
   * Get a ReferenceGlyph from the ListOfReferenceGlyphs.
   *
   * @param n the index number of the ReferenceGlyph to get.
   * 
   * @return the nth ReferenceGlyph in this ListOfReferenceGlyphs.
   *
   * @see size()
   */
  virtual ReferenceGlyph * get(unsigned int n); 


  /**
   * Get a ReferenceGlyph from the ListOfReferenceGlyphs.
   *
   * @param n the index number of the ReferenceGlyph to get.
   * 
   * @return the nth ReferenceGlyph in this ListOfReferenceGlyphs.
   *
   * @see size()
   */
  virtual const ReferenceGlyph * get(unsigned int n) const; 

  /**
   * Get a ReferenceGlyph from the ListOfReferenceGlyphs
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the ReferenceGlyph to get.
   * 
   * @return ReferenceGlyph in this ListOfReferenceGlyphs
   * with the given @p sid or @c NULL if no such
   * ReferenceGlyph exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual ReferenceGlyph* get (const std::string& sid);


  /**
   * Get a ReferenceGlyph from the ListOfReferenceGlyphs
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the ReferenceGlyph to get.
   * 
   * @return ReferenceGlyph in this ListOfReferenceGlyphs
   * with the given @p sid or @c NULL if no such
   * ReferenceGlyph exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const ReferenceGlyph* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfReferenceGlyphs items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual ReferenceGlyph* remove (unsigned int n);


  /**
   * Removes item in this ListOfReferenceGlyphs items with the given identifier.
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
  virtual ReferenceGlyph* remove (const std::string& sid);


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



class LIBSBML_EXTERN GeneralGlyph : public GraphicalObject
{
protected:
  /** @cond doxygenLibsbmlInternal */
  std::string mReference;
  ListOfReferenceGlyphs mReferenceGlyphs;
  ListOfGraphicalObjects mSubGlyphs;
  Curve mCurve;
  bool mCurveExplicitlySet;
  /** @endcond */
        

public:

  /**
   * Creates a new GeneralGlyph.  The list of reference glyph and subglyphs is
   * empty and the id of the associated element is set to the empty
   * string.
   */ 
   
  GeneralGlyph (unsigned int level      = LayoutExtension::getDefaultLevel(),
                 unsigned int version    = LayoutExtension::getDefaultVersion(),
                 unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());
       

  /**
   * Creates a new GeneralGlyph with the given LayoutPkgNamespaces object.
   */
  GeneralGlyph (LayoutPkgNamespaces* layoutns);


  /**
   * Creates a glyph with the given LayoutPkgNamespaces and id.
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */ 
   
  GeneralGlyph (LayoutPkgNamespaces* layoutns, const std::string& id);

  /**
   * Creates a glyph with the given LayoutPkgNamespaces, id and set the id of the
   * associated element to the second argument.
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */ 
   
  GeneralGlyph (LayoutPkgNamespaces* layoutns, const std::string& id, const std::string& referenceId);
       

  /**
   * Creates a new GeneralGlyph from the given XMLNode
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */
  GeneralGlyph(const XMLNode& node, unsigned int l2version = 4);

  /**
   * Copy constructor.
   */
   GeneralGlyph(const GeneralGlyph& source);

  /**
   * Assignment operator.
   */
  virtual  GeneralGlyph& operator=(const GeneralGlyph& source);

  /**
   * Destructor.
   */ 
   
  virtual ~GeneralGlyph(); 
  
  /**
   * Returns a List of all child SBase objects, including those nested to an
   * arbitrary depth
   *
   * @return a List* of pointers to all children objects.
   */
  virtual List* getAllElements(ElementFilter* filter=NULL);


  /**
   * @copydoc doc_renamesidref_common
   */
  virtual void renameSIdRefs(const std::string& oldid, const std::string& newid);


  /**
   * Returns the id of the associated element.
   */  
   
  const std::string& getReferenceId () const;
       
  /**
   * Sets the id of the associated element.
   */ 
   
  int setReferenceId (const std::string& id);

  /**
   * Returns true if the id of the associated element is not the empty
   * string.
   */ 
  
  bool isSetReferenceId () const;
       
  /**
   * Returns the ListOf object that hold the reference glyphs.
   */  
   
  const ListOfReferenceGlyphs* getListOfReferenceGlyphs () const;

  /**
   * Returns the ListOf object that hold the reference glyphs.
   */  
   
  ListOfReferenceGlyphs* getListOfReferenceGlyphs ();
       
  /**
   * Returns the ListOf object that hold the sub glyphs.
   */  
   
  const ListOfGraphicalObjects* getListOfSubGlyphs () const;

  /**
   * Returns the ListOf object that hold the sub glyphs.
   */  
   
  ListOfGraphicalObjects* getListOfSubGlyphs ();
       
  /**
   * Returns the reference glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
   
  const ReferenceGlyph* getReferenceGlyph (unsigned int index) const;

  /**
   * Returns the reference glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
   
  ReferenceGlyph* getReferenceGlyph (unsigned int index) ;

  /**
   * Returns the sub glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
   
  const GraphicalObject* getSubGlyph (unsigned int index) const;

  /**
   * Returns the sub glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
   
  GraphicalObject* getSubGlyph (unsigned int index) ;

  /**
   * Adds a new reference glyph to the list.
   */
   
  void addReferenceGlyph (const ReferenceGlyph* glyph);
       

  /**
   * Adds a new subglyph to the list.
   */
   
  void addSubGlyph (const GraphicalObject* glyph);

  /**
   * Returns the number of reference glyph objects.
   */ 
   
  unsigned int getNumReferenceGlyphs () const;

  /**
   * Returns the number of subglyph objects.
   */ 
   
  unsigned int getNumSubGlyphs () const;
       
  /**
   * Calls initDefaults from GraphicalObject.
   */ 
   
  void initDefaults (); 

  /**
   * Returns the curve object for the reaction glyph
   */ 
  const Curve* getCurve () const;

  /**
   * Returns the curve object for the reaction glyph
   */ 
  Curve* getCurve () ;

  /**
   * Sets the curve object for the reaction glyph.
   */ 
  
  void setCurve (const Curve* curve);
       
  /**
   * Returns true if the curve consists of one or more segments.
   */ 
  
  bool isSetCurve () const;


  bool getCurveExplicitlySet() const;
  /**
   * Creates a new ReferenceGlyph object, adds it to the end of the
   * list of reference objects and returns a reference to the newly
   * created object.
   */
  
  ReferenceGlyph* createReferenceGlyph ();
    
  /**
   * Creates a new LineSegment object, adds it to the end of the list of
   * curve segment objects of the curve and returns a reference to the
   * newly created object.
   */
  
  LineSegment* createLineSegment();
    
  /**
   * Creates a new CubicBezier object, adds it to the end of the list of
   * curve segment objects of the curve and returns a reference to the
   * newly created object.
   */
   CubicBezier* createCubicBezier();

  /**
   * Remove the reference glyph with the given index.
   * A pointer to the object is returned. If no object has been removed, NULL
   * is returned.
   */
  
  ReferenceGlyph*
  removeReferenceGlyph(unsigned int index);

  /**
   * Remove the subglyph with the given index.
   * A pointer to the object is returned. If no object has been removed, NULL
   * is returned.
   */
  
  GraphicalObject*
  removeSubGlyph(unsigned int index);

  /**
   * Remove the reference glyph with the given @p id.
   * A pointer to the object is returned. If no object has been removed, NULL
   * is returned.
   */
  
  ReferenceGlyph*
  removeReferenceGlyph(const std::string& id);

  /**
   * Remove the subglyph with the given @p id.
   * A pointer to the object is returned. If no object has been removed, NULL
   * is returned.
   */
  
  GraphicalObject*
  removeSubGlyph(const std::string& id);

  /**
   * Returns the index of the reference glyph with the given @p id.
   * If the glyph does not contain a reference glyph with this
   * id, @if cpp numeric_limits<unsigned int>::max() @else cpp the
   * value of the maximum long integer@endif@~ is returned as an indicator.
   */
  
  unsigned int
  getIndexForReferenceGlyph(const std::string& id) const;

  /**
   * Returns the index of the subglyph with the given @p id.
   * If the glyph does not contain a subglyph with this
   * id, @if cpp numeric_limits<unsigned int>::max() @else cpp the
   * value of the maximum long integer@endif@~ is returned as an indicator.
   */
  
  unsigned int
  getIndexForSubGlyph(const std::string& id) const;


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
   * Creates and returns a deep copy of this GeneralGlyph.
   * 
   * @return a (deep) copy of this GeneralGlyph.
   */
  virtual GeneralGlyph* clone () const;


  /**
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_LAYOUT_GENERALGLYPH, SBMLLayoutTypeCode_t}
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
    virtual XMLNode toXML() const;


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


LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * Creates a new GeneralGlyph_t and returns the pointer to it.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
GeneralGlyph_t *
GeneralGlyph_create (void);


/**
 * Creates a new GeneralGlyph_t structure from a template.
 *
 * @param temp The GeneralGlyph_t structure to copy.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
GeneralGlyph_t *
GeneralGlyph_createFrom (const GeneralGlyph_t *temp);


/**
 * Creates a new GeneralGlyph_t with the given @p sid
 *
 * @param gg The GeneralGlyph_t structure.
 * @param sid The id of the created SpeciesGlyph_t
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
GeneralGlyph_t *
GeneralGlyph_createWith (const char *sid);


/**
 * Creates a new GeneralGlyph_t referencing the given element.
 *
 * @param gg The GeneralGlyph_t structure.
 * @param sid The id of the created SpeciesGlyph_t
 * @param referenceId The referenceId of the created SpeciesGlyph_t
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
GeneralGlyph_t *
GeneralGlyph_createWithReferenceId (const char *sid, const char *referenceId);


/**
 * Frees the memory taken by the given glyph.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
void
GeneralGlyph_free (GeneralGlyph_t *gg);


/**
 * Sets the reference for the glyph.
 *
 * @param gg The GeneralGlyph_t structure.
 * @param id The string to use as the referenceId of the GeneralGlyph_t
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
void
GeneralGlyph_setReferenceId (GeneralGlyph_t *gg,const char *id);


/**
 * Gets the reference id for the given glyph.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
const char *
GeneralGlyph_getReferenceId (const GeneralGlyph_t *gg);


/**
 * Returns 0 if the reference element has not been set for this glyph and
 * 1 otherwise.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
int
GeneralGlyph_isSetReferenceId (const GeneralGlyph_t *gg);


/**
 * Add a ReferenceGlyph_t object to the list of
 * ReferenceGlyph_t's.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
void
GeneralGlyph_addReferenceGlyph (GeneralGlyph_t   *gg,
                                ReferenceGlyph_t *srg);

/**
 * Returns the number of ReferenceGlyphs for the GeneralGlyph_t.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
unsigned int
GeneralGlyph_getNumReferenceGlyphs (const GeneralGlyph_t *gg);


/**
 * Returns the pointer to the ReferenceGlyph_t's for the given index.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
ReferenceGlyph_t *
GeneralGlyph_getReferenceGlyph (GeneralGlyph_t *gg,
                                unsigned int index);


/**
 * Returns the list object that holds all reference glyphs.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */ 
LIBSBML_EXTERN
ListOf_t *
GeneralGlyph_getListOfReferenceGlyphs (GeneralGlyph_t *gg);


/**
 * Removes the reference glyph with the given index.  If the index
 * is invalid, nothing is removed.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */ 
LIBSBML_EXTERN
ReferenceGlyph_t *
GeneralGlyph_removeReferenceGlyph (GeneralGlyph_t *gg,
                                   unsigned int index);

/**
 * Calls initDefaults from GraphicalObject.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */ 
LIBSBML_EXTERN
void
GeneralGlyph_initDefaults (GeneralGlyph_t *gg);


/**
 * Sets the curve for the reaction glyph.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
void
GeneralGlyph_setCurve (GeneralGlyph_t *gg, Curve_t *c);


/**
 * Gets the Curve_t for the given reaction glyph.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
Curve_t *
GeneralGlyph_getCurve (GeneralGlyph_t *gg);


/**
 * Returns true if the Curve_t has one or more LineSegment.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
int
GeneralGlyph_isSetCurve (GeneralGlyph_t *gg);


/**
 * Creates a new ReferenceGlyph_t structure, adds it to the end of the
 * list of reference glyphs and returns a pointer to the newly
 * created structure.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
ReferenceGlyph_t *
GeneralGlyph_createReferenceGlyph (GeneralGlyph_t *gg);


/**
 * Creates a new ReferenceGlyph_t structure, adds it to the end of the
 * list of reference glyphs and returns a pointer to the newly
 * created structure.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
ReferenceGlyph_t *
GeneralGlyph_createReferenceGlyph (GeneralGlyph_t *gg);


/**
 * Creates a new LineSegment_t structure, adds it to the end of the list of
 * curve segments and returns a pointer to the newly created
 * structure.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
LineSegment_t *
GeneralGlyph_createLineSegment (GeneralGlyph_t *gg);


/**
 * Creates a new CubicBezier_t structure, adds it to the end of the list of
 * curve segments and returns a pointer to the newly created
 * structure.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
CubicBezier_t *
GeneralGlyph_createCubicBezier (GeneralGlyph_t *gg);


/**
 * Remove the reference glyph with the given index.
 * A pointer to the structure is returned. If no structure has been removed, NULL
 * is returned.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
ReferenceGlyph_t*
GeneralGlyph_removeReferenceGlyph(GeneralGlyph_t* gg, unsigned int index);


/**
 * Remove the reference glyph with the given @p id.
 * A pointer to the structure is returned. If no structure has been removed, NULL
 * is returned.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
ReferenceGlyph_t*
GeneralGlyph_removeReferenceGlyphWithId(GeneralGlyph_t* gg, const char* id);


/**
 * Returns the index of the reference glyph with the given @p id.
 * If the reaction glyph does not contain a reference glyph with this
 * id, UINT_MAX from limits.h is returned.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
unsigned int
GeneralGlyph_getIndexForReferenceGlyph(GeneralGlyph_t* gg,const char* id);


/**
 * @return a (deep) copy of this GeneralGlyph_t.
 *
 * @param gg The GeneralGlyph_t structure.
 *
 * @memberof GeneralGlyph_t
 */
LIBSBML_EXTERN
GeneralGlyph_t *
GeneralGlyph_clone (const GeneralGlyph_t *gg);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* !SWIG */
#endif  /* !GeneralGlyph_H__ */
