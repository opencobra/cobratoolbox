/**
 * @file    Curve.h
 * @brief   Definition of Curve for SBML Layout.
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
 * @class Curve
 * @sbmlbrief{layout} A curve connecting elements in a diagram.
 *
 * The Curve class describes how to connect elements in a diagram defined
 * with the use of the &ldquo;layout&rdquo; package. A curve is fully
 * specified by a mandatory listOfCurveSegments element and is used in four
 * places in the &ldquo;layout&rdquo; package:
 *
 * @li SpeciesReferenceGlyph: Here it describes a curve from/to the center
 * piece of the parent ReactionGlyph to/from the SpeciesGlyph it represents.
 *
 * @li ReactionGlyph: Here it describes a curve for the center piece of a
 * reaction.
 *
 * @li ReferenceGlyph: Here it describes a curve from/to the center piece of
 * the parent GeneralGlyph to/from the glyph it represents.
 *
 * @li GeneralGlyph: Here it describes a curve for the center piece of an
 * additional relationship.
 *
 * In the text above, the term 'center piece' refers to either the Curve
 * element of a ReactionGlyph, or its BoundingBox.
 */

#ifndef Curve_H__
#define Curve_H__


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/packages/layout/common/layoutfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/ListOf.h>
#include <sbml/packages/layout/sbml/LineSegment.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>

LIBSBML_CPP_NAMESPACE_BEGIN

/**
 * @class ListOfLineSegments
 * @sbmlbrief{layout} A list of LineSegment objects.
 * 
 * The ListOfLineSegments is a container for the LineSegment elements of a Curve.
 * 
 * @copydetails doc_what_is_listof
 *
 * @see Input
 */
class LIBSBML_EXTERN ListOfLineSegments : public ListOf
{
 public:

  /**
   * Creates and returns a deep copy of this ListOfLineSegments.
   * 
   * @return a (deep) copy of this ListOfLineSegments.
   */
  virtual ListOfLineSegments* clone () const;


  /**
   * Ctor.
   */
   ListOfLineSegments(unsigned int level      = LayoutExtension::getDefaultLevel(), 
                      unsigned int version    = LayoutExtension::getDefaultVersion(), 
                      unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());

  /**
   * Ctor.
   */
   ListOfLineSegments(LayoutPkgNamespaces* layoutns);


  /**
   * Returns the libSBML type code for the SBML objects
   * contained in this ListOf object.
   * 
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for objects contained in this list:
   * @sbmlconstant{SBML_LAYOUT_LINESEGMENT, SBMLTypeCode_t} (default).
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
   * Get a LineSegment from the ListOfLineSegments.
   *
   * @param n the index number of the LineSegment to get.
   * 
   * @return the nth LineSegment in this ListOfLineSegments.
   *
   * @see size()
   */
  virtual LineSegment * get(unsigned int n); 


  /**
   * Get a LineSegment from the ListOfLineSegments.
   *
   * @param n the index number of the LineSegment to get.
   * 
   * @return the nth LineSegment in this ListOfLineSegments.
   *
   * @see size()
   */
  virtual const LineSegment * get(unsigned int n) const; 


  /**
   * Removes the nth item from this ListOfLineSegments items and returns a pointer to
   * it.
   *
   * The caller owns the returned item and is responsible for deleting it.
   *
   * @param n the index of the item to remove
   *
   * @see size()
   */
  virtual LineSegment* remove (unsigned int n);


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
  
  
  virtual bool isValidTypeForList(SBase * item);
};
  
class LIBSBML_EXTERN Curve : public SBase
{
protected:
  /** @cond doxygenLibsbmlInternal */
  ListOfLineSegments mCurveSegments;
  /** @endcond */


public:

  /**
   * Creates a curve with an empty list of segments.
   */ 
  
  Curve (unsigned int level      = LayoutExtension::getDefaultLevel(),
         unsigned int version    = LayoutExtension::getDefaultVersion(),
         unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());


  /**
   * Creates a new Curve with the given LayoutPkgNamespaces object.
   */
  Curve (LayoutPkgNamespaces* layoutns);


  /**
   * Creates a new Curve from the given XMLNode
   */
  Curve(const XMLNode& node, unsigned int l2version=4);


  /**
   * Copy constructor.
   */
   Curve(const Curve& source);

  /**
   * Assignment operator.
   */
   Curve& operator=(const Curve& source);

  /**
   * Destructor.
   */ 
  virtual ~Curve ();

  /**
   * Does nothing since no defaults are defined for Curve.
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
   * Returns a reference to the ListOf object that holds all the curve
   * segments.
   */
  
  const ListOfLineSegments* getListOfCurveSegments () const;
       
  /**
   * Returns a refernce to the ListOf object That holds all the curve
   * segments.
   */
  
  ListOfLineSegments* getListOfCurveSegments ();

  /**
   * Returns a pointer to the curve segment with the given index.
   * If the index is invalid, @c NULL is returned.
   */  
  const LineSegment* getCurveSegment (unsigned int index) const;

  /**
   * Returns a pointer to the curve segment with the given index.
   * If the index is invalid, @c NULL is returned.
   */  
  LineSegment* getCurveSegment (unsigned int index);

  /**
   * Adds a new CurveSegment to the end of the list.
   */ 
  
  void addCurveSegment (const LineSegment* segment);
  
  /**
   * Returns the number of curve segments.
   */ 
  
  unsigned int getNumCurveSegments () const;


  /**
   * Creates a new LineSegment and adds it to the end of the list.  A
   * reference to the new LineSegment object is returned.
   */
  
  LineSegment* createLineSegment ();

  /**
   * Creates a new CubicBezier and adds it to the end of the list.  A
   * reference to the new CubicBezier object is returned.
   */
  
  CubicBezier* createCubicBezier ();

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
   * Creates and returns a deep copy of this Curve.
   * 
   * @return a (deep) copy of this Curve.
   */
  virtual Curve* clone () const;


  /**
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_LAYOUT_CURVE, SBMLLayoutTypeCode_t}
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

LIBSBML_CPP_NAMESPACE_END



#endif /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS


/**
 * Creates a new curve and returns the pointer to it.
 *
 * @memberof Curve_t
 */
LIBSBML_EXTERN
Curve_t *
Curve_create ();

/**
 * Creates a new Curve_t structure from a template.
 *
 * @param temp The Curve_t structure to copy.
 *
 * @memberof Curve_t
 */
LIBSBML_EXTERN
Curve_t *
Curve_createFrom (const Curve_t *temp);

/**
 * Frees the memory taken by the Curve_t.
 *
 * @param c The Curve_t structure.
 *
 * @memberof Curve_t
 */
LIBSBML_EXTERN
void
Curve_free (Curve_t *c);


/**
 * Adds a LineSegment_t to a Curve_t.
 *
 * @param c The Curve_t structure.
 * @param ls The LineSegment_t structure to add.
 *
 * @memberof Curve_t
 */
LIBSBML_EXTERN
void
Curve_addCurveSegment (Curve_t *c, LineSegment_t *ls);

/**
 * Returns the number of line segments.
 *
 * @param c The Curve_t structure.
 *
 * @memberof Curve_t
 */
LIBSBML_EXTERN
unsigned int
Curve_getNumCurveSegments (const Curve_t *c);

/**
 * Returns the line segment with the given index.
 *
 * @param c The Curve_t structure.
 * @param index The index of the curve segment to return.
 *
 * @memberof Curve_t
 */
LIBSBML_EXTERN
LineSegment_t *
Curve_getCurveSegment (const Curve_t *c, unsigned int index);

/**
 * Returns the ListOf_t structure that holds all the curve segments.
 *
 * @param c The Curve_t structure.
 *
 * @memberof Curve_t
 */ 
LIBSBML_EXTERN
ListOf_t *
Curve_getListOfCurveSegments (Curve_t *c);

/**
 * Removes the curve segment with the given index.  If the index is
 * invalid, nothing is done.
 *
 * @param c The Curve_t structure.
 * @param index The index of the curve segment to remove.
 *
 * @memberof Curve_t
 */ 
LIBSBML_EXTERN
LineSegment_t *
Curve_removeCurveSegment (Curve_t *c, unsigned int index);

/**
 * Does nothing since no defaults are defined for Curve_t.
 *
 * @param c The Curve_t structure.
 *
 * @memberof Curve_t
 */ 
LIBSBML_EXTERN
void
Curve_initDefaults (Curve_t *c);

/**
 * Creates a new LineSegment_t and adds it to the end of the list.  A pointer
 * to the new LineSegment_t structure is returned.
 *
 * @param c The Curve_t structure.
 *
 * @memberof Curve_t
 */
LIBSBML_EXTERN
LineSegment_t *
Curve_createLineSegment (Curve_t *c);

/**
 * Creates a new CubicBezier_t and adds it to the end of the list.  A pointer
 * to the new CubicBezier_t structure is returned.
 *
 * @param c The Curve_t structure.
 *
 * @memberof Curve_t
 */
LIBSBML_EXTERN
CubicBezier_t *
Curve_createCubicBezier (Curve_t *c);

/**
 * @return a (deep) copy of this Curve_t.
 *
 * @param c The Curve_t structure.
 *
 * @memberof Curve_t
 */
LIBSBML_EXTERN
Curve_t *
Curve_clone (const Curve_t *c);



END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* !SWIG */
#endif  /* Curve_H__ */
