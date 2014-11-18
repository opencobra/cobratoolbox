/**
 * @file    ReferenceGlyph.h
 * @brief   Definition of ReferenceGlyph for SBML Layout.
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
 * @class ReferenceGlyph
 * @sbmlbrief{layout} Connection between an object and a glyph.
 *
 * The ReferenceGlyph element describes the graphical connection between an
 * arbitrary GraphicalObject (or derived element) and a GeneralGlyph (which
 * would be an arrow or some curve in most cases). A ReferenceGlyph inherits
 * from GraphicalObject. Additionally it has a mandatory attribute 'glyph'
 * and two optional attributes 'reference' and 'role'. Optionally, the
 * ReferenceGlyph also has an element 'curve'.  The ReferenceGlyph should
 * either contain a bounding box or a curve specification.  If both are
 * given, the bounding box should be ignored.
 */

#ifndef ReferenceGlyph_H__
#define ReferenceGlyph_H__

#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/packages/layout/common/layoutfwd.h>

#ifdef __cplusplus


#include <string>

#include <sbml/packages/layout/sbml/GraphicalObject.h>
#include <sbml/packages/layout/sbml/Curve.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>

LIBSBML_CPP_NAMESPACE_BEGIN

class LIBSBML_EXTERN ReferenceGlyph : public GraphicalObject
{
protected:
  /** @cond doxygenLibsbmlInternal */
  std::string mReference;
  std::string mGlyph;
  std::string mRole;
  Curve mCurve;
  bool mCurveExplicitlySet;
  /** @endcond */
  
public:

  /**
   * Creates a new ReferenceGlyph with the given SBML level, version and
   * package version.  The id if the associated 
   * reference and the id of the associated  glyph are set to the
   * empty string.  The role is set to empty.
   */
  
  ReferenceGlyph (unsigned int level      = LayoutExtension::getDefaultLevel(),
                         unsigned int version    = LayoutExtension::getDefaultVersion(),
                         unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());

  
  /**
   * Ctor.
   */
  ReferenceGlyph(LayoutPkgNamespaces* layoutns);
        

  /**
   * Creates a new ReferenceGlyph.  The id is given as the first
   * argument, the id of the associated glyph is given as the
   * second argument.  The third argument is the id of the associated
   * reference and the fourth argument is the role.
   */ 
  
  ReferenceGlyph (LayoutPkgNamespaces* layoutns, const std::string& sid,
                          const std::string& glyphId,
                          const std::string& referenceId,
                          const std::string& role );
        

  /**
   * Creates a new ReferenceGlyph from the given XMLNode
   */
  ReferenceGlyph(const XMLNode& node, unsigned int l2version=4);

  /**
   * Copy constructor.
   */
   ReferenceGlyph(const ReferenceGlyph& source);

  /**
   * Assignment operator.
   */
   virtual ReferenceGlyph& operator=(const ReferenceGlyph& source);

  /**
   * Destructor.
   */ 
  
  virtual ~ReferenceGlyph (); 

  /**
   * Returns a List of all child SBase objects, including those nested to an
   * arbitrary depth
   *
   * @return a List* of pointers to all children structures.
   */
  virtual List* getAllElements(ElementFilter* filter=NULL);

  /**
   * @copydoc doc_renamesidref_common
   */
  virtual void renameSIdRefs(const std::string& oldid, const std::string& newid);

        
  /**
   * Returns the id of the associated glyph.
   */ 
  
  const std::string& getGlyphId () const;
        
  /**
   * Sets the id of the associated glyph.
   */ 
  
  void setGlyphId (const std::string& glyphId);
        
  /**
   * Returns the id of the associated sbml reference.
   */ 
  
  const std::string& getReferenceId() const;
        
  /**
   * Sets the id of the associated sbml reference.
   */ 
  
  void setReferenceId (const std::string& id);

  /**
   * Returns a string representation of the role.
   */ 
  
  const std::string& getRole() const;
  
  /**
   * Sets the role.
   */ 
  
  void setRole (const std::string& role);
        
  /**
   * Returns the curve object for the reference glyph
   */ 
  Curve* getCurve () ;

  /**
   * Returns the curve object for the reference glyph
   */ 
  const Curve* getCurve () const;

  /**
   * Sets the curve object for the reference glyph.
   */ 
  
  void setCurve (const Curve* curve);
       
  /**
   * Returns true if the curve consists of one or more segments.
   */ 
  
    bool isSetCurve () const;


  bool getCurveExplicitlySet() const;
  /**
   * Returns true if the id of the associated glyph is not the
   * empty string.
   */ 
  
  bool isSetGlyphId () const;
        
  /**
   * Returns true if the id of the associated reference is not the
   * empty string.
   */ 
  
  bool isSetReferenceId() const;
        
  /**
   * Returns true of role is different from the empty string.
   */ 
  
  bool isSetRole () const;
        
  /**
   * Calls initDefaults on GraphicalObject 
   */ 
  
  void initDefaults ();

  /**
   * Creates a new LineSegment object, adds it to the end of the list of
   * curve segment objects of the curve and returns a reference to the
   * newly created object.
   */
  
  LineSegment* createLineSegment ();

  /**
   * Creates a new CubicBezier object, adds it to the end of the list of
   * curve segment objects of the curve and returns a reference to the
   * newly created object.
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
   * Creates and returns a deep copy of this ReferenceGlyph.
   * 
   * @return a (deep) copy of this ReferenceGlyph.
   */
  virtual ReferenceGlyph* clone () const;


  /**
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_LAYOUT_REFERENCEGLYPH, SBMLLayoutTypeCode_t}
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
 * Creates a new ReferenceGlyph_t structure and returns a pointer to it.
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
ReferenceGlyph_t *
ReferenceGlyph_create (void);

/**
 * Creates a new ReferenceGlyph_t from a template.
 *
 * @param temp The ReferenceGlyph_t structure to copy
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
ReferenceGlyph_t *
ReferenceGlyph_createFrom (const ReferenceGlyph_t *temp);

/**
 * Creates a new ReferenceGlyph_t.  The id is given as the first
 * argument, the id of the associated reference is given as the
 * second argument.  The third argument is the id of the associated
 * glyph and the fourth argument is the role.
 *
 * @param sid The string to use as the ID of the SpeciesReferenceGlyph_t
 * @param glyphId The string to use as the glyph.
 * @param referenceId The string to use as the reference.
 * @param role The role of the created ReferenceGlyph_t
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
ReferenceGlyph_t *
ReferenceGlyph_createWith ( const char *sid,
                            const char *glyphId,
                            const char *referenceId,
                            const char* role );


/**
 * Frees the memory for the ReferenceGlyph_t
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
void
ReferenceGlyph_free (ReferenceGlyph_t *rg);


/**
 * Sets the reference for the glyph.
 *
 * @param rg The ReferenceGlyph_t structure
 * @param id The string to use as the reference.
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
void
ReferenceGlyph_setReferenceId (ReferenceGlyph_t *rg,
                               const char *id);

/**
 * Gets the reference id for the given  glyph.
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
const char *
ReferenceGlyph_getReferenceId(const ReferenceGlyph_t *rg);

/**
 * Returns 0 if the reference reference has not been set for this
 * glyph and 1 otherwise.
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
int
ReferenceGlyph_isSetReferenceId(const ReferenceGlyph_t *rg);

/**
 * Sets the glyph reference for the glyph.
 *
 * @param rg The ReferenceGlyph_t structure
 * @param id The string to use as the glyph.
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
void
ReferenceGlyph_setGlyphId (ReferenceGlyph_t *rg,
                           const char *id);

/**
 * Gets the reference id for the given glyph.
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
const char *
ReferenceGlyph_getGlyphId (const ReferenceGlyph_t *rg);

/**
 * Returns 0 if the reference has not been set for this
 * glyph and 1 otherwise.
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
int
ReferenceGlyph_isSetGlyphId (const ReferenceGlyph_t *rg);


/**
 * Sets the curve for the reference glyph.
 *
 * @param rg The ReferenceGlyph_t structure
 * @param c The Curve_t to set for the ReferenceGlyph_t
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
void
ReferenceGlyph_setCurve (ReferenceGlyph_t *rg, Curve_t *c);

/**
 * Gets the Curve_t for the given reference glyph.
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
Curve_t *
ReferenceGlyph_getCurve (ReferenceGlyph_t *rg);

/**
 * Returns true if the Curve_t has one or more LineSegment.
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
int
ReferenceGlyph_isSetCurve(ReferenceGlyph_t* rg);

/**
 * Sets the role of the reference glyph based on the string. 
 *
 * @param rg The ReferenceGlyph_t structure
 * @param r The role to use for the ReferenceGlyph_t
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
void
ReferenceGlyph_setRole (ReferenceGlyph_t *rg, const char *r);

/**
 * Returns the role of the reference.
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */ 

LIBSBML_EXTERN
const char*
ReferenceGlyph_getRole(const ReferenceGlyph_t* rg);


/**
 * Returns true if the role is not empty.
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */ 
LIBSBML_EXTERN
int
ReferenceGlyph_isSetRole(const ReferenceGlyph_t *rg);

/**
 * Calls initDefaults on GraphicalObject 
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */ 
LIBSBML_EXTERN
void
ReferenceGlyph_initDefaults (ReferenceGlyph_t *rg);

/**
 * Creates a new LineSegment_t structure, adds it to the end of the list of
 * curve segments of the curve and returns a reference to the newly
 * created structure.
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
LineSegment_t *
ReferenceGlyph_createLineSegment (ReferenceGlyph_t *rg);

/**
 * Creates a new CubicBezier_t structure, adds it to the end of the list of
 * curve segment of the curve and returns a reference to the newly
 * created structure.
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
CubicBezier_t *
ReferenceGlyph_createCubicBezier (ReferenceGlyph_t *rg);

/**
 * @return a (deep) copy of this ReferenceGlyph_t.
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
ReferenceGlyph_t *
ReferenceGlyph_clone (const ReferenceGlyph_t *rg);

/**
 * Returns non-zero if the id is set
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
int
ReferenceGlyph_isSetId (const ReferenceGlyph_t *rg);

/**
 * Returns the id
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
const char *
ReferenceGlyph_getId (const ReferenceGlyph_t *rg);


/**
 * Sets the id
 *
 * @param rg The ReferenceGlyph_t structure
 * @param sid The string to use as the ID of the ReferenceGlyph_t
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
int
ReferenceGlyph_setId (ReferenceGlyph_t *rg, const char *sid);


/**
 * Unsets the id
 *
 * @param rg The ReferenceGlyph_t structure
 *
 * @memberof ReferenceGlyph_t
 */
LIBSBML_EXTERN
void
ReferenceGlyph_unsetId (ReferenceGlyph_t *rg);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif /* !SWIG */
#endif /* ReferenceGlyph_H__ */
