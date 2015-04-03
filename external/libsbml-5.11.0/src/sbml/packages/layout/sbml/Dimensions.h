/**
 * @file    Dimensions.h
 * @brief   Definition of Dimensions for SBML Layout.
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
 * @class Dimensions
 * @sbmlbrief{layout} Spatial dimensions of a 2D or 3D shape.
 *
 * A dimension is specified via the required attributes width, height and an
 * optional attribute depth, all of which are of type double. If the
 * attribute depth is not specified, the object is a two dimensional object.
 * The width attribute of Dimensions specifies the size of the object in the
 * direction of the positive x axis, the height attribute specifies the size
 * of the object along the positive y axis and the depth attribute specifies
 * the size of the object along the positive z axis. All sizes for Dimensions
 * objects are positive values, and so the attributes are not allowed to take
 * negative values.  The Dimensions class also has an optional attribute id
 * of type SId. While not used in the &ldquo;layout&rdquo; package, it can be
 * used by programs to refer to the elements.
 */

#ifndef Dimensions_H__
#define Dimensions_H__


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/packages/layout/common/layoutfwd.h>

#ifdef __cplusplus

#include <sbml/SBase.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>


LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN Dimensions : public SBase
{
protected:
  /** @cond doxygenLibsbmlInternal */
  std::string mId;
  double mW;
  double mH;
  double mD;
  bool mDExplicitlySet;
  /** @endcond */


public:

  /**
   * Creates a new Dimensions object with the given level, version, and package version
   * and with all sizes set to 0.0.
   */
   Dimensions(unsigned int level      = LayoutExtension::getDefaultLevel(),
              unsigned int version    = LayoutExtension::getDefaultVersion(),
              unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());


  /**
   * Creates a new Dimensions object with the given LayoutPkgNamespaces object.
   */
   Dimensions(LayoutPkgNamespaces* layoutns);


  /**
   * Copy constructor.
   */
  Dimensions(const Dimensions& orig);

  /**
   * Creates a new Dimensions object with the given sizes.
   *
   */ 
  
  Dimensions (LayoutPkgNamespaces* layoutns, double w, double h, double d = 0.0);


  /**
   * Creates a new Dimensions object from the given XMLNode
   */
   Dimensions(const XMLNode& node, unsigned int l2version = 4);
 
  /**
   * Frees memory taken up by the Dimensions object.
   */ 
  
  virtual ~Dimensions ();

  /**
   * Assignment operator
   */
  Dimensions& operator=(const Dimensions& orig);

  /**
   * Returns the width.
   */
  
  double width () const;

  /**
   * Returns the height.
   */
  
  double height () const;

  /**
   * Returns the depth.
   */
  
  double depth () const;

  /**
   * Returns the width.
   */
  
  double getWidth () const;

  /**
   * Returns the height.
   */
  
  double getHeight () const;

  /**
   * Returns the depth.
   */
  
  double getDepth () const;

  /**
   * Sets the width to the given value.
   */ 
  
  void setWidth (double w);

  /**
   * Sets the height to the given value.
   */ 
  
  void setHeight (double h);

  /**
   * Sets the depth to the given value.
   */ 
  
  void setDepth (double d);

  /**
   * Sets all sizes of the Dimensions object to the given values.
   */ 
  
  void setBounds (double w, double h, double d = 0.0);

  bool getDExplicitlySet() const;
  /**
   * Sets the depth to 0.0
   */ 
  
  void initDefaults ();

  /**
   * Returns the value of the "id" attribute of this Dimensions.
   */
  virtual const std::string& getId () const;

  /**
   * Predicate returning @c true or @c false depending on whether this
   * Dimensions's "id" attribute has been set.
   */
  virtual bool isSetId () const;

  
  /**
   * Sets the value of the "id" attribute of this Dimensions.
   */
  virtual int setId (const std::string& id);


  /**
   * Unsets the value of the "id" attribute of this Dimensions.
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
   * Returns the XML element name of
   * this SBML object.
   *
   * @return the string of the name of this element
   */
  virtual const std::string& getElementName () const ;


  /**
   * Creates and returns a deep copy of this Dimensions.
   *
   * @return a (deep) copy of this Dimensions object.
   */
  virtual Dimensions* clone () const;


  /**
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_LAYOUT_DIMENSIONS, SBMLLayoutTypeCode_t}
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
 * Creates a new Dimensions_t structure with all sizes set to 0.0.
 *
 * @memberof Dimensions_t
 */ 
LIBSBML_EXTERN
Dimensions_t *
Dimensions_create ();

/**
 * Creates a new Dimensions_t structure with the given sizes.
 *
 * @param w The width of the created Dimensions_t
 * @param h The height of the created Dimensions_t
 * @param d The depth of the created Dimensions_t
 *
 * @memberof Dimensions_t
 */ 
LIBSBML_EXTERN
Dimensions_t *
Dimensions_createWithSize (double w, double h, double d);

/**
 * Frees memory taken up by the Dimensions_t structure.
 *
 * @param d The Dimensions_t structure
 *
 * @memberof Dimensions_t
 */ 
LIBSBML_EXTERN
void
Dimensions_free (Dimensions_t *d);

/**
 * Sets the depth to 0.0
 *
 * @param d The Dimensions_t structure
 *
 * @memberof Dimensions_t
 */ 
LIBSBML_EXTERN
void
Dimensions_initDefaults (Dimensions_t *d);

/**
 * Sets all sizes of the Dimensions_t structure to the given values.
 *
 * @param d The Dimensions_t structure
 * @param width The value to use for the width of the Dimensions_t
 * @param height The value to use for the height of the Dimensions_t
 * @param depth The value to use for the depth of the Dimensions_t
 *
 * @memberof Dimensions_t
 */ 
LIBSBML_EXTERN
void
Dimensions_setBounds (Dimensions_t *d, double width, double height, double depth);

/**
 * Sets the width to the given value.
 *
 * @param d The Dimensions_t structure
 * @param width The value to use for the width of the Dimensions_t
 *
 * @memberof Dimensions_t
 */ 
LIBSBML_EXTERN
void
Dimensions_setWidth (Dimensions_t *d, double width);

/**
 * Sets the height to the given value.
 *
 * @param d The Dimensions_t structure
 * @param height The value to use for the height of the Dimensions_t
 *
 * @memberof Dimensions_t
 */ 
LIBSBML_EXTERN
void
Dimensions_setHeight (Dimensions_t *d, double height);

/**
 * Sets the depth to the given value.
 *
 * @param d The Dimensions_t structure
 * @param depth The value to use for the depth of the Dimensions_t
 *
 * @memberof Dimensions_t
 */ 
LIBSBML_EXTERN
void
Dimensions_setDepth (Dimensions_t *d, double depth);

/**
 * Returns the height.
 *
 * @param d The Dimensions_t structure
 *
 * @memberof Dimensions_t
 */
LIBSBML_EXTERN
double
Dimensions_height (const Dimensions_t *d);

/**
 * Returns the width.
 *
 * @param d The Dimensions_t structure
 *
 * @memberof Dimensions_t
 */
LIBSBML_EXTERN
double
Dimensions_width (const Dimensions_t *d);

/**
 * Returns the depth.
 *
 * @param d The Dimensions_t structure
 *
 * @memberof Dimensions_t
 */ 
LIBSBML_EXTERN
double
Dimensions_depth (const Dimensions_t *d);

/**
 * Returns the height.
 *
 * @param d The Dimensions_t structure
 *
 * @memberof Dimensions_t
 */
LIBSBML_EXTERN
double
Dimensions_getHeight (const Dimensions_t *d);

/**
 * Returns the width.
 *
 * @param d The Dimensions_t structure
 *
 * @memberof Dimensions_t
 */
LIBSBML_EXTERN
double
Dimensions_getWidth (const Dimensions_t *d);

/**
 * Returns the depth.
 *
 * @param d The Dimensions_t structure
 *
 * @memberof Dimensions_t
 */ 
LIBSBML_EXTERN
double
Dimensions_getDepth (const Dimensions_t *d);

/**
 * @return a (deep) copy of this Dimensions_t.
 *
 * @param d The Dimensions_t structure
 *
 * @memberof Dimensions_t
 */
LIBSBML_EXTERN
Dimensions_t *
Dimensions_clone (const Dimensions_t *d);



END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* !SWIG */
#endif  /* Dimensions_H__ */
