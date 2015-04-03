/**
 * @file    CubicBezier.h
 * @brief   Definition of CubicBezier for SBML Layout.
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
 * @class CubicBezier
 * @sbmlbrief{layout} A Cubic B&eacute;zier smooth curve.
 *
 * In order to be able to represent smooth curves the &ldquo;layout&rdquo;
 * package defines the class CubicBezier. It represents a Bezier curve, and
 * is readily available in most graphics APIs.  The class CubicBezier is
 * derived from LineSegment. It consists of four elements: the two inherited
 * elements 'start' and 'end', which specify the starting point and the
 * endpoint of the cubic bezier curve, and two elements 'basePoint1' and
 * 'basePoint2', which specify the two additional base points that are needed
 * to describe a cubic bezier curve.
 */

#ifndef CubicBezier_H__
#define CubicBezier_H__


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/packages/layout/common/layoutfwd.h>

#ifdef __cplusplus


#include <string>

#include <sbml/packages/layout/sbml/LineSegment.h>
#include <sbml/packages/layout/sbml/Point.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN CubicBezier : public LineSegment
{
protected:
  /** @cond doxygenLibsbmlInternal */
  Point mBasePoint1;
  Point mBasePoint2;
  bool mBasePt1ExplicitlySet;
  bool mBasePt2ExplicitlySet;
  /** @endcond */


public:

  /**
   * Creates a CubicBezier and returns the pointer.
   */
  
  CubicBezier (unsigned int level      = LayoutExtension::getDefaultLevel(), 
               unsigned int version    = LayoutExtension::getDefaultVersion(), 
               unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());


  /**
   * Ctor.
   */
  CubicBezier (LayoutPkgNamespaces* layoutns);

  /**
   * Creates a CubicBezier with the given 2D coordinates and returns the
   * pointer.
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */
  
  CubicBezier (LayoutPkgNamespaces* layoutns, double x1, double y1, double x2, double y2);

  /**
   * Creates a CubicBezier with the given 3D coordinates and returns the
   * pointer.
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */
  
  CubicBezier (LayoutPkgNamespaces* layoutns, double x1, double y1, double z1,
               double x2, double y2, double z2);

  /**
   * Copy constructor.
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */
  CubicBezier(const CubicBezier& orig);

  /**
   * Creates a CubicBezier with the given points and returns the pointer.
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */
  
  CubicBezier (LayoutPkgNamespaces* layoutns, const Point* start, const Point* end);

  /**
   * Creates a CubicBezier with the given points and returns the pointer.
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */
  
  CubicBezier (LayoutPkgNamespaces* layoutns, const Point* start, const Point* base1,
               const Point* base2, const Point* end);


  /**
   * Creates a new Layout from the given XMLNode
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */
  CubicBezier(const XMLNode& node, unsigned int l2version=4);

  /**
   * Destructor.
   */ 
  
  virtual ~CubicBezier ();

  /**
   * Assignment operator
   */
  virtual CubicBezier& operator=(const CubicBezier& orig);

  /**
   * Returns a List of all child SBase objects, including those nested to an
   * arbitrary depth
   *
   * @return a List* of pointers to all children objects.
   */
  virtual List* getAllElements(ElementFilter* filter=NULL);

  /**
   * Returns the first base point of the curve (the one closer to the
   * starting point).
   */ 
  
  const Point* getBasePoint1 () const;

  /**
   * Returns the first base point of the curve (the one closer to the
   * starting point).
   */ 
  
  Point* getBasePoint1 ();

  /**
   * Initializes first base point with a copy of the given point.
   */
  
  void setBasePoint1 (const Point* p);

  /**
   * Initializes first base point with the given coordinates.
   */
  
  void setBasePoint1 (double x, double y, double z = 0.0);

  /**
   * Returns the second base point of the curve (the one closer to the end
   * point).
   */ 
  
  const Point* getBasePoint2 () const;

  /**
   * Returns the second base point of the curve (the one closer to the end
   * point).
   */ 
  
  Point* getBasePoint2 ();

  /**
   * Initializes second base point with a copy of the given point.
   */
  
  void setBasePoint2 (const Point* p);

  /**
   * Initializes second base point with the given coordinates.
   */
  
  void setBasePoint2 (double x, double y, double z = 0.0);

  /** @cond doxygenLibsbmlInternal */

  bool getBasePt1ExplicitlySet() const;

  bool getBasePt2ExplicitlySet() const;

  /** @endcond */

  /**
   * Calls initDefaults from LineSegment.
   */ 
  
  void initDefaults ();

  /**
   * Makes a line from a CubicBezier by setting both base points into the
   * middle between the start and the end point.
   */
  
  void straighten ();

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
   * Creates and returns a deep copy of this CubicBezier.
   * 
   * @return a (deep) copy of this CubicBezier.
   */
  virtual CubicBezier* clone () const;


  /**
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_LAYOUT_CUBICBEZIER, SBMLLayoutTypeCode_t}
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
 * Creates a CubicBezier_t and returns the pointer.
 *
 * @memberof CubicBezier_t
 */
LIBSBML_EXTERN
CubicBezier_t *
CubicBezier_create ();

/**
 * Creates a CubicBezier_t with the given points and returns the pointer.
 *
 * @param x1 The value of the x coordinate of the start Point_t.
 * @param y1 The value of the y coordinate of the start Point_t.
 * @param z1 The value of the z coordinate of the start Point_t.
 * @param x2 The value of the x coordinate of the base1 Point_t.
 * @param y2 The value of the y coordinate of the base1 Point_t.
 * @param z2 The value of the z coordinate of the base1 Point_t.
 * @param x3 The value of the x coordinate of the base2 Point_t.
 * @param y3 The value of the y coordinate of the base2 Point_t.
 * @param z3 The value of the z coordinate of the base2 Point_t.
 * @param x4 The value of the x coordinate of the end Point_t.
 * @param y4 The value of the y coordinate of the end Point_t.
 * @param z4 The value of the z coordinate of the end Point_t.
 *
 * @memberof CubicBezier_t
 */
LIBSBML_EXTERN
CubicBezier_t *
CubicBezier_createWithCoordinates (double x1, double y1, double z1,
                                   double x2, double y2, double z2,
                                   double x3, double y3, double z3,
                                   double x4, double y4, double z4);

/**
 * Creates a CubicBezier_t with the given coordinates and returns the pointer.
 *
 * @param start The value of the 'start' Point_t
 * @param base1 The value of the 'base1' Point_t
 * @param base2 The value of the 'base2' Point_t
 * @param end The value of the 'end' Point_t
 *
 * @memberof CubicBezier_t
 */
LIBSBML_EXTERN
CubicBezier_t *
CubicBezier_createWithPoints (const Point_t *start, const Point_t *base1,
                              const Point_t *base2, const Point_t *end);


/**
 * Creates a CubicBezier_t structure from a template.
 *
 * @param temp The CubicBezier_t structure to copy.
 *
 * @memberof CubicBezier_t
 */
LIBSBML_EXTERN
CubicBezier_t *
CubicBezier_createFrom (const CubicBezier_t *temp);


/**
 * Frees the memory for the cubic bezier.
 *
 * @param cb The CubicBezier_t structure.
 *
 * @memberof CubicBezier_t
 */
LIBSBML_EXTERN
void
CubicBezier_free (CubicBezier_t *cb);

/**
 * Initializes start point with a copy of the given point.
 *
 * @param cb The CubicBezier_t structure.
 * @param point The Point_t structure to use as the start point.
 *
 * @memberof CubicBezier_t
 */
LIBSBML_EXTERN
void
CubicBezier_setStart (CubicBezier_t *cb, const Point_t *point);

/**
 * Initializes end point with a copy of the given point.
 *
 * @param cb The CubicBezier_t structure.
 * @param point The Point_t structure to use as the end point.
 *
 * @memberof CubicBezier_t
 */
LIBSBML_EXTERN
void
CubicBezier_setEnd (CubicBezier_t *cb, const Point_t *point);

/**
 * Initializes the first base point with a copy of the given point.
 *
 * @param cb The CubicBezier_t structure.
 * @param point The Point_t structure to use as the base1 point.
 *
 * @memberof CubicBezier_t
 */
LIBSBML_EXTERN
void
CubicBezier_setBasePoint1 (CubicBezier_t *cb, const Point_t *point);

/**
 * Initializes second base point with a copy of the given point.
 *
 * @param cb The CubicBezier_t structure.
 * @param point The Point_t structure to use as the base2 point.
 *
 * @memberof CubicBezier_t
 */
LIBSBML_EXTERN
void
CubicBezier_setBasePoint2 (CubicBezier_t *cb, const Point_t *point);

/**
 * Returns the starting point of the curve.
 *
 * @param cb The CubicBezier_t structure.
 *
 * @memberof CubicBezier_t
 */ 
LIBSBML_EXTERN
Point_t *
CubicBezier_getStart (CubicBezier_t *cb);

/**
 * Returns the endpoint of the curve.
 *
 * @param cb The CubicBezier_t structure.
 *
 * @memberof CubicBezier_t
 */ 
LIBSBML_EXTERN
Point_t *
CubicBezier_getEnd (CubicBezier_t *cb);

/**
 * Returns the first base point of the curve (the one closer to the
 * starting point).
 *
 * @param cb The CubicBezier_t structure.
 *
 * @memberof CubicBezier_t
 */ 
LIBSBML_EXTERN
Point_t *
CubicBezier_getBasePoint1 (CubicBezier_t *cb);


/**
 * Returns the second base point of the curve (the one closer to the end
 * point).
 *
 * @param cb The CubicBezier_t structure.
 *
 * @memberof CubicBezier_t
 */ 
LIBSBML_EXTERN
Point_t *
CubicBezier_getBasePoint2 (CubicBezier_t *cb);

/**
 * Calls initDefaults from LineSegment.
 *
 * @param cb The CubicBezier_t structure.
 *
 * @memberof CubicBezier_t
 */ 
LIBSBML_EXTERN
void
CubicBezier_initDefaults (CubicBezier_t *cb);

/**
 * @return a (deep) copy of this CubicBezier_t.
 *
 * @param cb The CubicBezier_t structure.
 *
 * @memberof CubicBezier_t
 */
LIBSBML_EXTERN
CubicBezier_t *
CubicBezier_clone (const CubicBezier_t *cb);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* !SWIG */
#endif  /* CubicBezier_H__ */
