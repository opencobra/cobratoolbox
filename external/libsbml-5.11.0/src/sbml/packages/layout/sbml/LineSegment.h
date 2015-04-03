/**
 * @file    LineSegment.h
 * @brief   Definition of LineSegment for SBML Layout.
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
 * @class LineSegment
 * @sbmlbrief{layout} Representation of a line.
 *
 * The LineSegment class consists of the mandatory attribute xsi:type and two
 * child elements of type Point. One is called 'start' and represents the
 * starting point of the line, the other is called 'end' and represents the
 * endpoint of the line.  The LineSegment class is also the base class for
 * CubicBezier, which represent curved lines instead of straight ones.
 */

#ifndef LineSegment_H__
#define LineSegment_H__


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/packages/layout/common/layoutfwd.h>


#ifdef __cplusplus


#include <string>

#include <sbml/SBase.h>
#include <sbml/packages/layout/sbml/Point.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN LineSegment : public SBase
{
protected:
  /** @cond doxygenLibsbmlInternal */
  Point mStartPoint;
  Point mEndPoint;
  bool mStartExplicitlySet;
  bool mEndExplicitlySet;
  /** @endcond */

public:

  /**
   * Creates a line segment with the given SBML level, version, and package version
   * and both points set to (0.0,0.0,0.0)
   */ 
  LineSegment (unsigned int level      = LayoutExtension::getDefaultLevel(),
               unsigned int version    = LayoutExtension::getDefaultVersion(),
               unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());

  /**
   * Creates a line segment with the LayoutPkgNamespaces and both points set to (0.0,0.0,0.0)
   */ 
  LineSegment (LayoutPkgNamespaces* layoutns);


  /**
   * Creates a new line segment with the given 2D coordinates.
   */ 
  
  LineSegment (LayoutPkgNamespaces* layoutns, double x1, double y1, double x2, double y2);

  /**
   * Copy constructor.
   */
  LineSegment(const LineSegment& orig);

  /**
   * Creates a new line segment with the given 3D coordinates.
   */ 
  LineSegment(LayoutPkgNamespaces* layoutns, double x1, double y1, double z1, double x2, double y2, double z2);

  /**
   * Creates a new line segment with the two given points.
   */ 
  
  LineSegment (LayoutPkgNamespaces* layoutns, const Point* start, const Point* end);


  /**
   * Creates a new LineSegment from the given XMLNode
   */
  LineSegment(const XMLNode& node, unsigned int l2version=4);

  /**
   * Destructor.
   */ 
  
  virtual ~LineSegment ();

  /**
   * Assignment operator
   */
  virtual LineSegment& operator=(const LineSegment& orig);


  /**
   * Returns a List of all child SBase objects, including those nested to an
   * arbitrary depth
   *
   * @return a List* of pointers to all children objects.
   */
  virtual List* getAllElements(ElementFilter* filter=NULL);


  /**
   * Returns the start point of the line.
   */ 
  
  const Point* getStart () const;

  /**
   * Returns the start point of the line.
   */ 
  
  Point* getStart ();

  /**
   * Initializes the start point with a copy of the given Point object.
   */
  
  void setStart (const Point* start);

  /**
   * Initializes the start point with the given coordinates.
   */
  
  void setStart (double x, double y, double z = 0.0);

  /**
   * Returns the end point of the line.
   */ 
  
  const Point* getEnd () const;

  /**
   * Returns the end point of the line.
   */ 
  
  Point* getEnd ();

  /**
   * Initializes the end point with a copy of the given Point object.
   */
  
  void setEnd (const Point* end);

  /**
   * Initializes the end point with the given coordinates.
   */
  
  void setEnd (double x, double y, double z = 0.0);

  /** @cond doxygenLibsbmlInternal */

  bool getStartExplicitlySet() const;

  bool getEndExplicitlySet() const;

  /** @endcond */

  /**
   * Does noting since no defaults are defined for LineSegment.
   */ 
  
  void initDefaults ();

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
   * Creates and returns a deep copy of this LineSegment.
   * 
   * @return a (deep) copy of this LineSegment.
   */
  virtual LineSegment* clone () const;


  /**
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_LAYOUT_LINESEGMENT, SBMLLayoutTypeCode_t}
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


  /** @cond doxygenLibsbmlInternal */
  /**
   *
   * Subclasses should override this method to write their xmlns attriubutes
   * (if any) to the XMLOutputStream. 
   *
   */
  virtual void writeXMLNS (XMLOutputStream& stream) const;
  /** @endcond */
};

LIBSBML_CPP_NAMESPACE_END

#endif /* __cplusplus */


#ifndef SWIG

LIBSBML_CPP_NAMESPACE_BEGIN
BEGIN_C_DECLS



/**
 * Creates a LineSegment_t and returns the pointer.
 *
 * @memberof LineSegment_t
 */
LIBSBML_EXTERN
LineSegment_t *
LineSegment_create (void);


/**
 * Creates a LineSegment_t from a template.
 *
 * @param temp The LineSegment_t structure to copy.
 *
 * @memberof LineSegment_t
 */
LIBSBML_EXTERN
LineSegment_t *
LineSegment_createFrom (const LineSegment_t *temp);

/**
 * Creates a LineSegment_t with the given points and returns the pointer.
 *
 * @param start The Point_t at which the line segment starts
 * @param end   The Point_t at which the line segment ends
 *
 * @memberof LineSegment_t
 */
LIBSBML_EXTERN
LineSegment_t *
LineSegment_createWithPoints (const Point_t *start, const Point_t *end);

/**
 * Creates a LineSegment_t with the given coordinates and returns the
 * pointer.
 *
 * @param x1 The value of the x coordinate of the start Point_t.
 * @param y1 The value of the y coordinate of the start Point_t.
 * @param z1 The value of the z coordinate of the start Point_t.
 * @param x2 The value of the x coordinate of the end Point_t.
 * @param y2 The value of the y coordinate of the end Point_t.
 * @param z2 The value of the z coordinate of the end Point_t.
 *
 * @memberof LineSegment_t
 */
LIBSBML_EXTERN
LineSegment_t *
LineSegment_createWithCoordinates (double x1, double y1, double z1,
                                   double x2, double y2, double z2);

/**
 * Frees the memory for the line segment.
 *
 * @param ls The LineSegment_t structure.
 *
 * @memberof LineSegment_t
 */
LIBSBML_EXTERN
void
LineSegment_free (LineSegment_t *ls);


/**
 * Initializes the start point with a copy of the given Point_t structure.
 *
 * @param ls The LineSegment_t structure.
 * @param start The Point_t at which the line segment starts
 *
 * @memberof LineSegment_t
 */
LIBSBML_EXTERN
void 
LineSegment_setStart (LineSegment_t *ls, const Point_t *start);

/**
 * Initializes the end point with a copy of the given Point_t structure.
 *
 * @param ls  The LineSegment_t structure.
 * @param end The Point_t at which the line segment ends
 *
 * @memberof LineSegment_t
 */
LIBSBML_EXTERN
void 
LineSegment_setEnd (LineSegment_t *ls, const Point_t *end);


/**
 * Returns the start point of the line.
 *
 * @param ls The LineSegment_t structure.
 *
 * @memberof LineSegment_t
 */ 
LIBSBML_EXTERN
Point_t *
LineSegment_getStart (LineSegment_t *ls);

/**
 * Returns the end point of the line.
 *
 * @param ls The LineSegment_t structure.
 *
 * @memberof LineSegment_t
 */ 
LIBSBML_EXTERN
Point_t *
LineSegment_getEnd (LineSegment_t *ls);

/**
 * Does noting since no defaults are defined for LineSegment_t.
 *
 * @param ls The LineSegment_t structure.
 *
 * @memberof LineSegment_t
 */ 
LIBSBML_EXTERN
void
LineSegment_initDefaults (LineSegment_t *ls);

/**
 * @return a (deep) copy of this LineSegment_t.
 *
 * @param ls The LineSegment_t structure.
 *
 * @memberof LineSegment_t
 */
LIBSBML_EXTERN
LineSegment_t *
LineSegment_clone (const LineSegment_t *ls);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* !SWIG */
#endif  /* LineSegment_H__ */
