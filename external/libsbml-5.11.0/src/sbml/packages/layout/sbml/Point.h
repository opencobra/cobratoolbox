/**
 * @file    Point.h
 * @brief   Definition of Point for SBML Layout.
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
 * @class Point
 * @sbmlbrief{layout} Representation of a point.
 *
 * A point is specified via the required attributes 'x', 'y' and an optional
 * attribute 'z', all of which are of type double. If the attribute z is not
 * specified, the object is a two dimensional object.  The Point class also
 * has an optional attribute id of type SId. While not used in the
 * &ldquo;layout&rdquo; package, it can be used by programs to refer to the
 * elements.
 */

#ifndef Point_H__
#define Point_H__


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/packages/layout/common/layoutfwd.h>

#ifdef __cplusplus

#include <sbml/SBase.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN Point : public SBase
{
protected:
  /** @cond doxygenLibsbmlInternal */
  std::string mId;
  double mXOffset;
  double mYOffset;
  double mZOffset;
  bool mZOffsetExplicitlySet;
  std::string mElementName;
  /** @endcond */

public:

  /**
   * Creates a new point with x,y and z set to 0.0.
   */ 
  
  Point (unsigned int level      = LayoutExtension::getDefaultLevel(),
         unsigned int version    = LayoutExtension::getDefaultVersion(),
         unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());

  /**
   * Ctor.
   */
   Point(LayoutPkgNamespaces* layoutns);

        
  /**
   * Copy constructor.
   */
  Point(const Point& orig);
  
  /**
   * Creates a new point with the given coordinates.
   *
   *
   */ 
  Point (LayoutPkgNamespaces* layoutns, double x, double y, double z =0.0);

  /**
   * Creates a new Point from the given XMLNode
   */
  Point(const XMLNode& node, unsigned int l2version = 4);

  /**
   * Destructor.
   */ 
  
  virtual ~Point ();


  /**
   * Assignment operator
   */
  Point& operator=(const Point& orig);


  /**
   * Returns the x offset.
   */ 
  
  double x () const;
        
  /**
   * Returns the y offset.
   */ 
  
  double y () const;
        
  /**
   * Returns the z offset.
   */ 
  
  double z () const;
   /**
   * Returns the x offset.
   */ 
  
  double getXOffset () const;
        
  /**
   * Returns the y offset.
   */ 
  
  double getYOffset () const;
        
  /**
   * Returns the z offset.
   */ 
  
  double getZOffset () const;
        
  /**
   * Sets the x offset.
   */ 
  
  void setX (double x);
        
  /**
   * Sets the y offset.
   */ 
  
  void setY (double y);
        
  /**
   * Sets the z offset.
   */ 
  
  void setZ (double z);

  /**
   * Sets the x offset.
   */ 
  
  void setXOffset (double x);
        
  /**
   * Sets the y offset.
   */ 
  
  void setYOffset (double y);
        
  /**
   * Sets the z offset.
   */ 
  
  void setZOffset (double z);
        
  /**
   * Sets the coordinates to the given values.
   */ 
  
  void setOffsets (double x, double y, double z = 0.0);
   
  bool getZOffsetExplicitlySet() const;
  /**
   * Sets the Z offset to 0.0.
   */ 
  
  void initDefaults ();

  /**
   * Returns the value of the "id" attribute of this Point.
   */
  virtual const std::string& getId () const;

  /**
   * Predicate returning @c true or @c false depending on whether this
   * Point's "id" attribute has been set.
   */
  virtual bool isSetId () const;

  
  /**
   * Sets the value of the "id" attribute of this Point.
   */
  virtual int setId (const std::string& id);


  /**
   * Unsets the value of the "id" attribute of this Point.
   */
  virtual int unsetId ();


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
   * Sets the element name to be returned by getElementName().
   */
  virtual void setElementName(const std::string& name);


  /**
   * Returns the XML element name of
   * this SBML object.
   *
   * @return the string of the name of this element
   */
  virtual const std::string& getElementName () const ;


  /**
   * Creates and returns a deep copy of this Point.
   * 
   * @return a (deep) copy of this Point.
   */
  virtual Point* clone () const;


  /**
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_LAYOUT_POINT, SBMLLayoutTypeCode_t}
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
    XMLNode toXML(const std::string& name) const;
    
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
 * Creates a new point with the coordinates (0.0,0.0,0.0).
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
Point_t *
Point_create (void);

/**
 * Creates a new Point_t with the given coordinates.
 *
 * @param x The value of the x coordinate.
 * @param y The value of the y coordinate.
 * @param z The value of the z coordinate.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
Point_t *
Point_createWithCoordinates (double x, double y, double z);

/**
 * Frees all memory for the Point_t.
 *
 * @param p The Point_t structure.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
void
Point_free (Point_t *p);

/**
 * Sets the Z offset to 0.0
 *
 * @param p The Point_t structure.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
void
Point_initDefaults (Point_t *p);

/**
 * Sets the coordinates to the given values.
 *
 * @param p The Point_t structure.
 * @param x The value of the x coordinate.
 * @param y The value of the y coordinate.
 * @param z The value of the z coordinate.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
void
Point_setOffsets (Point_t *p, double x, double y, double z);

/**
 * Sets the x offset.
 *
 * @param p The Point_t structure.
 * @param x The value of the x coordinate.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
void
Point_setX (Point_t *p, double x);

/**
 * Sets the y offset.
 *
 * @param p The Point_t structure.
 * @param y The value of the y coordinate.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
void
Point_setY (Point_t *p, double y);

/**
 * Sets the z offset.
 *
 * @param p The Point_t structure.
 * @param z The value of the z coordinate.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
void
Point_setZ (Point_t *p, double z);

/**
 * Gets the x offset.
 *
 * @param p The Point_t structure.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
double
Point_x (const Point_t *p);

/**
 * Gets the y offset.
 *
 * @param p The Point_t structure.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
double
Point_y (const Point_t *p);

/**
 * Gets the z offset.
 *
 * @param p The Point_t structure.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
double
Point_z (const Point_t *p);


/**
 * Sets the x offset.
 *
 * @param p The Point_t structure.
 * @param x The value of the x offset.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
void
Point_setXOffset (Point_t *p, double x);

/**
 * Sets the y offset.
 *
 * @param p The Point_t structure.
 * @param y The value of the y offset.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
void
Point_setYOffset (Point_t *p, double y);

/**
 * Sets the z offset.
 *
 * @param p The Point_t structure.
 * @param z The value of the z offset.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
void
Point_setZOffset (Point_t *p, double z);

/**
 * Gets the x offset.
 *
 * @param p The Point_t structure.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
double
Point_getXOffset (const Point_t *p);

/**
 * Gets the y offset.
 *
 * @param p The Point_t structure.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
double
Point_getYOffset (const Point_t *p);

/**
 * Gets the z offset.
 *
 * @param p The Point_t structure.
 *
 * @memberof Point_t
 */ 
LIBSBML_EXTERN
double
Point_getZOffset (const Point_t *p);

/**
 * @return a (deep) copy of this Point_t.
 *
 * @param p The Point_t structure.
 *
 * @memberof Point_t
 */
LIBSBML_EXTERN
Point_t *
Point_clone (const Point_t *p);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* !SWIG */
#endif  /* Point_H__ */
