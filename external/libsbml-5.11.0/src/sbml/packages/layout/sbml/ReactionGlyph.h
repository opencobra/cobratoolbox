/**
 * @file    ReactionGlyph.h
 * @brief   Definition of ReactionGlyph for SBML Layout.
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
 * @class ReactionGlyph
 * @sbmlbrief{layout} A glyph for an SBML reaction.
 *
 * Analogous to how a Reaction object has to at least have one reactant or
 * product, the ReactionGlyph has to at least have one SpeciesReferenceGlyph
 * stored in the ListOfSpeciesReferenceGlyphs. Figure 12 on the following
 * page provides the UML diagram for the class definition.  The ReactionGlyph
 * inherits from GraphicalObject. In addition to the attributes inherited
 * from GraphicalObject, the ReactionGlyph is described by an attribute
 * reaction, a Curve element and a listOfSpeciesReferenceGlyphs element.  The
 * Curve describes the center section of a ReactionGlyph. The center section
 * is frequently used by tools to separate the point where substrates arcs
 * come together, from the point where product arcs split off. The Curve is
 * optional, and when not present the dimensions of the inherited BoundingBox
 * describes the center section, by storing its position and dimension.
 */

#ifndef ReactionGlyph_H__
#define ReactionGlyph_H__


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/packages/layout/common/layoutfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/ListOf.h>
#include <sbml/packages/layout/sbml/Curve.h>
#include <sbml/packages/layout/sbml/SpeciesReferenceGlyph.h>
#include <sbml/packages/layout/sbml/GraphicalObject.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * @class ListOfSpeciesReferenceGlyphs
 * @sbmlbrief{layout} A list of SpeciesReferenceGlyph objects.
 * 
 * The ListOfSpeciesReferenceGlyphs is a container for the SpeciesReferenceGlyphs elements of a ReactionGlyph.
 * 
 * @copydetails doc_what_is_listof
 *
 * @see SpeciesReferenceGlyph
 */
class LIBSBML_EXTERN ListOfSpeciesReferenceGlyphs : public ListOf
{
public:

  /**
   * Creates and returns a deep copy of this ListOfSpeciesReferenceGlyphs.
   * 
   * @return a (deep) copy of this ListOfSpeciesReferenceGlyphs.
   */
  virtual ListOfSpeciesReferenceGlyphs* clone () const;

  /**
   * Ctor.
   */
   ListOfSpeciesReferenceGlyphs(unsigned int level      = LayoutExtension::getDefaultLevel(), 
                                unsigned int version    = LayoutExtension::getDefaultVersion(), 
                                unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());

  /**
   * Ctor.
   */
   ListOfSpeciesReferenceGlyphs(LayoutPkgNamespaces* layoutns);


  /**
   * Returns the libSBML type code for the SBML objects
   * contained in this ListOf object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_LAYOUT_SPECIESREFERENCEGLYPH, SBMLTypeCode_t} (default).
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
   * Get a SpeciesReferenceGlyph from the ListOfSpeciesReferenceGlyphs.
   *
   * @param n the index number of the SpeciesReferenceGlyph to get.
   * 
   * @return the nth SpeciesReferenceGlyph in this ListOfSpeciesReferenceGlyphs.
   *
   * @see size()
   */
  virtual SpeciesReferenceGlyph * get(unsigned int n); 


  /**
   * Get a SpeciesReferenceGlyph from the ListOfSpeciesReferenceGlyphs.
   *
   * @param n the index number of the SpeciesReferenceGlyph to get.
   * 
   * @return the nth SpeciesReferenceGlyph in this ListOfSpeciesReferenceGlyphs.
   *
   * @see size()
   */
  virtual const SpeciesReferenceGlyph * get(unsigned int n) const; 

  /**
   * Get a SpeciesReferenceGlyph from the ListOfSpeciesReferenceGlyphs
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the SpeciesReferenceGlyph to get.
   * 
   * @return SpeciesReferenceGlyph in this ListOfSpeciesReferenceGlyphs
   * with the given @p sid or @c NULL if no such
   * SpeciesReferenceGlyph exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual SpeciesReferenceGlyph* get (const std::string& sid);


  /**
   * Get a SpeciesReferenceGlyph from the ListOfSpeciesReferenceGlyphs
   * based on its identifier.
   *
   * @param sid a string representing the identifier 
   * of the SpeciesReferenceGlyph to get.
   * 
   * @return SpeciesReferenceGlyph in this ListOfSpeciesReferenceGlyphs
   * with the given @p sid or @c NULL if no such
   * SpeciesReferenceGlyph exists.
   *
   * @see get(unsigned int n)
   * @see size()
   */
  virtual const SpeciesReferenceGlyph* get (const std::string& sid) const;


  /**
   * Removes the nth item from this ListOfSpeciesReferenceGlyphs items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual SpeciesReferenceGlyph* remove (unsigned int n);


  /**
   * Removes item in this ListOfSpeciesReferenceGlyphs items with the given identifier.
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
  virtual SpeciesReferenceGlyph* remove (const std::string& sid);


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



class LIBSBML_EXTERN ReactionGlyph : public GraphicalObject
{
protected:
  /** @cond doxygenLibsbmlInternal */
  std::string mReaction;
  ListOfSpeciesReferenceGlyphs mSpeciesReferenceGlyphs;
  Curve mCurve;
  bool mCurveExplicitlySet;
  /** @endcond */
        

public:

  /**
   * Creates a new ReactionGlyph.  The list of species reference glyph is
   * empty and the id of the associated reaction is set to the empty
   * string.
   */ 
   
  ReactionGlyph (unsigned int level      = LayoutExtension::getDefaultLevel(),
                 unsigned int version    = LayoutExtension::getDefaultVersion(),
                 unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());
       

  /**
   * Creates a new ReactionGlyph with the given LayoutPkgNamespaces object.
   */
  ReactionGlyph (LayoutPkgNamespaces* layoutns);


  /**
   * Creates a ResctionGlyph with the given LayoutPkgNamespaces and id.
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */ 
   
  ReactionGlyph (LayoutPkgNamespaces* layoutns, const std::string& id);

  /**
   * Creates a ResctionGlyph with the given LayoutPkgNamespaces, id and set the id of the
   * associated reaction to the second argument.
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */ 
   
  ReactionGlyph (LayoutPkgNamespaces* layoutns, const std::string& id, const std::string& reactionId);
       

  /**
   * Creates a new ReactionGlyph from the given XMLNode
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */
  ReactionGlyph(const XMLNode& node, unsigned int l2version = 4);

  /**
   * Copy constructor.
   */
   ReactionGlyph(const ReactionGlyph& source);

  /**
   * Assignment operator.
   */
  virtual  ReactionGlyph& operator=(const ReactionGlyph& source);

  /**
   * Destructor.
   */ 
   
  virtual ~ReactionGlyph(); 
       

  /**
   * Returns the id of the associated reaction.
   */  
   
  const std::string& getReactionId () const;
       
  /**
   * Sets the id of the associated reaction.
   */ 
   
  int setReactionId (const std::string& id);

  /**
   * Returns true if the id of the associated reaction is not the empty
   * string.
   */ 
  
  bool isSetReactionId () const;
       
  /**
   * Returns the ListOf object that hold the species reference glyphs.
   */  
   
  const ListOfSpeciesReferenceGlyphs* getListOfSpeciesReferenceGlyphs () const;

  /**
   * Returns the ListOf object that hold the species reference glyphs.
   */  
   
  ListOfSpeciesReferenceGlyphs* getListOfSpeciesReferenceGlyphs ();
       
  /**
   * Returns the species reference glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
   
  const SpeciesReferenceGlyph* getSpeciesReferenceGlyph (unsigned int index) const;

  /**
   * Returns the species reference glyph with the given index.
   * If the index is invalid, @c NULL is returned.
   */ 
   
  SpeciesReferenceGlyph* getSpeciesReferenceGlyph (unsigned int index) ;

  /**
   * Adds a new species reference glyph to the list.
   */
   
  void addSpeciesReferenceGlyph (const SpeciesReferenceGlyph* glyph);
       
  /**
   * Returns the number of species reference glyph objects.
   */ 
   
  unsigned int getNumSpeciesReferenceGlyphs () const;
       
  /**
   * Calls initDefaults from GraphicalObject.
   */ 
   
  void initDefaults (); 

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
   * Creates a new SpeciesReferenceGlyph object, adds it to the end of the
   * list of species reference objects and returns a reference to the newly
   * created object.
   */
  
  SpeciesReferenceGlyph* createSpeciesReferenceGlyph ();
        
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
   * Remove the species reference glyph with the given index.
   * A pointer to the object is returned. If no object has been removed, NULL
   * is returned.
   */
  
  SpeciesReferenceGlyph*
  removeSpeciesReferenceGlyph(unsigned int index);

  /**
   * Remove the species reference glyph with the given @p id.
   * A pointer to the object is returned. If no object has been removed, NULL
   * is returned.
   */
  
  SpeciesReferenceGlyph*
  removeSpeciesReferenceGlyph(const std::string& id);

  /**
   * Returns the index of the species reference glyph with the given @p id.
   * If the reaction glyph does not contain a species reference glyph with this
   * id, @if cpp numeric_limits<unsigned int>::max() @else the
   * value of the maximum long integer@endif@~ is returned as an indicator.
   */
  
  unsigned int
  getIndexForSpeciesReferenceGlyph(const std::string& id) const;


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
   * Creates and returns a deep copy of this ReactionGlyph object.
   * 
   * @return a (deep) copy of this ReactionGlyph.
   */
  virtual ReactionGlyph* clone () const;


  /**
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_LAYOUT_REACTIONGLYPH, SBMLLayoutTypeCode_t}
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
 * Creates a new ReactionGlyph_t and returns the pointer to it.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
ReactionGlyph_t *
ReactionGlyph_create (void);


/**
 * Creates a new ReactionGlyph_t structure from a template.
 *
 * @param temp The ReactionGlyph_t structure to copy.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
ReactionGlyph_t *
ReactionGlyph_createFrom (const ReactionGlyph_t *temp);

/**
 * Frees the memory taken up by the attributes.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
void
ReactionGlyph_clear (ReactionGlyph_t *rg);


/**
 * Creates a new ReactionGlyph_t with the given @p sid
 *
 * @param sid The string to use as the ID of the ReactionGlyph_t
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
ReactionGlyph_t *
ReactionGlyph_createWith (const char *sid);

/**
 * Creates a new ReactionGlyph_t referencing the given reaction.
 *
 * @param sid The string to use as the ID of the ReactionGlyph_t
 * @param reactionId The string to use as the reaction ID.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
ReactionGlyph_t *
ReactionGlyph_createWithReactionId (const char *sid, const char *reactionId);

/**
 * Frees the memory taken by the given reaction glyph.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
void
ReactionGlyph_free (ReactionGlyph_t *rg);

/**
 * Sets the reference reaction for the reaction glyph.
 *
 * @param rg The ReactionGlyph_t structure.
 * @param id The string to use as the reaction ID.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
void
ReactionGlyph_setReactionId (ReactionGlyph_t *rg,const char *id);

/**
 * Gets the reference reactions id for the given reaction glyph.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
const char *
ReactionGlyph_getReactionId (const ReactionGlyph_t *rg);

/**
 * Returns 0 if the reference reaction has not been set for this glyph and
 * 1 otherwise.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
int
ReactionGlyph_isSetReactionId (const ReactionGlyph_t *rg);

/**
 * Add a SpeciesReferenceGlyph_t structure to the list of
 * SpeciesReferenceGlyph_t's.
 *
 * @param rg The ReactionGlyph_t structure.
 * @param srg The SpeciesReferenceGlyph_t structure to add.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
void
ReactionGlyph_addSpeciesReferenceGlyph (ReactionGlyph_t         *rg,
                                        SpeciesReferenceGlyph_t *srg);

/**
 * Returns the number of SpeciesReferenceGlyphs for the ReactionGlyph_t.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
unsigned int
ReactionGlyph_getNumSpeciesReferenceGlyphs (const ReactionGlyph_t *rg);

/**
 * Returns the pointer to the SpeciesReferenceGlyph_t's for the given index.
 *
 * @param rg The ReactionGlyph_t structure.
 * @param index The index of the SpeciesReferenceGlyph_t to return.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
SpeciesReferenceGlyph_t *
ReactionGlyph_getSpeciesReferenceGlyph (ReactionGlyph_t *rg,
                                        unsigned int index);


/**
 * Returns the list structure that holds all species reference glyphs.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */ 
LIBSBML_EXTERN
ListOf_t *
ReactionGlyph_getListOfSpeciesReferenceGlyphs (ReactionGlyph_t *rg);

/**
 * Removes the species reference glyph with the given index.  If the index
 * is invalid, nothing is removed.
 *
 * @param rg The ReactionGlyph_t structure.
 * @param index The index of the SpeciesReferenceGlyph_t to remove.
 *
 * @memberof ReactionGlyph_t
 */ 
LIBSBML_EXTERN
SpeciesReferenceGlyph_t *
ReactionGlyph_removeSpeciesReferenceGlyph (ReactionGlyph_t *rg,
                                           unsigned int index);

/**
 * Calls initDefaults from GraphicalObject.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */ 
LIBSBML_EXTERN
void
ReactionGlyph_initDefaults (ReactionGlyph_t *rg);

/**
 * Sets the curve for the reaction glyph.
 *
 * @param rg The ReactionGlyph_t structure.
 * @param c The Curve_t to set for the SpeciesReferenceGlyph_t
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
void
ReactionGlyph_setCurve (ReactionGlyph_t *rg, Curve_t *c);

/**
 * Gets the Curve_t for the given reaction glyph.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
Curve_t *
ReactionGlyph_getCurve (ReactionGlyph_t *rg);

/**
 * Returns true if the Curve_t has one or more LineSegment.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
int
ReactionGlyph_isSetCurve (ReactionGlyph_t *rg);

/**
 * Creates a new SpeciesReferenceGlyph_t structure, adds it to the end of the
 * list of species reference glyphs and returns a pointer to the newly
 * created structure.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
SpeciesReferenceGlyph_t *
ReactionGlyph_createSpeciesReferenceGlyph (ReactionGlyph_t *rg);

/**
 * Creates a new SpeciesReferenceGlyph_t structure, adds it to the end of the
 * list of species reference glyphs and returns a pointer to the newly
 * created structure.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
SpeciesReferenceGlyph_t *
ReactionGlyph_createSpeciesReferenceGlyph (ReactionGlyph_t *rg);

/**
 * Creates a new LineSegment_t structure, adds it to the end of the list of
 * curve segments and returns a pointer to the newly created
 * structure.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
LineSegment_t *
ReactionGlyph_createLineSegment (ReactionGlyph_t *rg);

/**
 * Creates a new CubicBezier_t structure, adds it to the end of the list of
 * curve segments and returns a pointer to the newly created
 * structure.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
CubicBezier_t *
ReactionGlyph_createCubicBezier (ReactionGlyph_t *rg);

/**
 * Remove the species reference glyph with the given index.
 * A pointer to the structure is returned. If no structure has been removed, NULL
 * is returned.
 *
 * @param rg The ReactionGlyph_t structure.
 * @param index The index of the SpeciesReferenceGlyph_t to remove.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
SpeciesReferenceGlyph_t*
ReactionGlyph_removeSpeciesReferenceGlyph(ReactionGlyph_t* rg,unsigned int index);

/**
 * Remove the species reference glyph with the given @p id.
 * A pointer to the structure is returned. If no structure has been removed, NULL
 * is returned.
 *
 * @param rg The ReactionGlyph_t structure.
 * @param id The id of the SpeciesReferenceGlyph_t to remove.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
SpeciesReferenceGlyph_t*
ReactionGlyph_removeSpeciesReferenceGlyphWithId(ReactionGlyph_t* rg,const char* id);

/**
 * Returns the index of the species reference glyph with the given @p id.
 * If the reaction glyph does not contain a species reference glyph with this
 * id, UINT_MAX from limits.h is returned.
 *
 * @param rg The ReactionGlyph_t structure.
 * @param id The idof the SpeciesReferenceGlyph_t to find.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
unsigned int
ReactionGlyph_getIndexForSpeciesReferenceGlyph(ReactionGlyph_t* rg,const char* id);

/**
 * @return a (deep) copy of this ReactionGlyph_t.
 *
 * @param rg The ReactionGlyph_t structure.
 *
 * @memberof ReactionGlyph_t
 */
LIBSBML_EXTERN
ReactionGlyph_t *
ReactionGlyph_clone (const ReactionGlyph_t *rg);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* !SWIG */
#endif  /* !ReactionGlyph_H__ */
