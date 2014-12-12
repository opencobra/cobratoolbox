/**
 * @file    SpeciesGlyph.h
 * @brief   Definition of SpeciesGlyph for SBML Layout.
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
 * @class SpeciesGlyph
 * @sbmlbrief{layout} A glyph for an SBML species.
 *
 * In addition to the attributes it inherits from GraphicalObject, the
 * SpeciesGlyph object has an optional 'species' attribute.
 */

#ifndef SpeciesGlyph_H__
#define SpeciesGlyph_H__


#include <sbml/common/extern.h>
#include <sbml/common/sbmlfwd.h>
#include <sbml/packages/layout/common/layoutfwd.h>


#ifdef __cplusplus


#include <string>
#include <sbml/packages/layout/sbml/GraphicalObject.h>
#include <sbml/packages/layout/extension/LayoutExtension.h>

LIBSBML_CPP_NAMESPACE_BEGIN


class LIBSBML_EXTERN SpeciesGlyph : public GraphicalObject
{
protected:
  /** @cond doxygenLibsbmlInternal */
  std::string mSpecies;        
  /** @endcond */


public:

  /**
   * Creates a new SpeciesGlyph with the given SBML level, version, and package version
   * and the id of the associated species set to the empty string.
   */        
  
  SpeciesGlyph (unsigned int level      = LayoutExtension::getDefaultLevel(),
                unsigned int version    = LayoutExtension::getDefaultVersion(),
                unsigned int pkgVersion = LayoutExtension::getDefaultPackageVersion());

  /**
   * Ctor.
   */
  SpeciesGlyph(LayoutPkgNamespaces* layoutns);


  /**
   * Creates a new SpeciesGlyph with the given @p id. 
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */   
  SpeciesGlyph (LayoutPkgNamespaces* layoutns, const std::string& id);

  /**
   * Creates a new SpeciesGlyph with the given @p id and the id of the
   * associated species object set to the second argument.
   *
   * (FOR BACKWARD COMPATIBILITY)
   *
   */   
  SpeciesGlyph (LayoutPkgNamespaces* layoutns, const std::string& id, const std::string& speciesId);
        

  /**
   * Creates a new SpeciesGlyph from the given XMLNode
   */
  SpeciesGlyph(const XMLNode& node, unsigned int l2version=4);

  /**
   * Copy constructor.
   */
   SpeciesGlyph(const SpeciesGlyph& source);

  /**
   * Assignment operator.
   */
   virtual SpeciesGlyph& operator=(const SpeciesGlyph& source);

  /**
   * Destructor.
   */ 
  
  virtual ~SpeciesGlyph ();        

  /**
   * @copydoc doc_renamesidref_common
   */
  virtual void renameSIdRefs(const std::string& oldid, const std::string& newid);

  /**
   * Returns the id of the associated species object.
   */ 
  
  const std::string& getSpeciesId () const;
        
  /**
   * Sets the id of the associated species object.
   */ 
  
  void setSpeciesId (const std::string& id);
        
  /**
   * Returns true if the id of the associated species object is not the
   * empty string.
   */ 
  
  bool isSetSpeciesId () const;    

  /**
   * Calls initDefaults from GraphicalObject.
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
   * Creates and returns a deep copy of this SpeciesGlyph.
   * 
   * @return a (deep) copy of this SpeciesGlyph.
   */
  virtual SpeciesGlyph* clone () const;


  /**
   * Returns the libSBML type code of this object instance.
   *
   * @copydetails doc_what_are_typecodes
   *
   * @return the SBML type code for this object:
   * @sbmlconstant{SBML_LAYOUT_SPECIESGLYPH, SBMLLayoutTypeCode_t}
   *
   * @copydetails doc_warning_typecodes_not_unique
   *
   * @see getElementName()
   * @see getPackageName()
   */
  virtual int getTypeCode () const;


   /**
    * Creates an XMLNode object from this.
    */
    virtual XMLNode toXML() const;
    
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
 * Creates a new SpeciesGlyph_t and returns the pointer to it.
 * 
 * @memberof SpeciesGlyph_t
 */
LIBSBML_EXTERN
SpeciesGlyph_t *
SpeciesGlyph_create (void);

/**
 * Create a new SpeciesGlyph_t structure from a template.
 * 
 * @param temp The SpeciesGlyph_t structure to copy
 *
 * @memberof SpeciesGlyph_t
 */
LIBSBML_EXTERN
SpeciesGlyph_t *
SpeciesGlyph_createFrom (const SpeciesGlyph_t *temp);


/**
 * Creates a new SpeciesGlyph_t with the given @p id
 * 
 * @param sid The id of the created SpeciesGlyph_t
 *
 * @memberof SpeciesGlyph_t
 */
LIBSBML_EXTERN
SpeciesGlyph_t *
SpeciesGlyph_createWith (const char *sid);

/**
 * Creates a new SpeciesGlyph_t referencing with the given id and species id.
 * 
 * @param id The id of the created SpeciesGlyph_t
 * @param speciesId The string to use as the species id
 *
 * @memberof SpeciesGlyph_t
 */
LIBSBML_EXTERN
SpeciesGlyph_t *
SpeciesGlyph_createWithSpeciesId (const char *id, const char *speciesId);

/**
 * Frees the memory taken by the given compartment glyph.
 * 
 * @param sg The SpeciesGlyph_t structure
 *
 * @memberof SpeciesGlyph_t
 */
LIBSBML_EXTERN
void
SpeciesGlyph_free (SpeciesGlyph_t *sg);

/**
 * Sets the associated species id. 
 * 
 * @param sg The SpeciesGlyph_t structure
 * @param id The string to use as the species id
 *
 * @memberof SpeciesGlyph_t
 */
LIBSBML_EXTERN
void
SpeciesGlyph_setSpeciesId (SpeciesGlyph_t *sg, const char *id);

/**
 * Gets the the id of the associated species.
 * 
 * @param sg The SpeciesGlyph_t structure
 *
 * @memberof SpeciesGlyph_t
 */
LIBSBML_EXTERN
const char *
SpeciesGlyph_getSpeciesId (const SpeciesGlyph_t *sg);

/**
 * Returns 0 if the  id of the associated species is the empty string.
 * otherwise.
 * 
 * @param sg The SpeciesGlyph_t structure
 *
 * @memberof SpeciesGlyph_t
 */
LIBSBML_EXTERN
int
SpeciesGlyph_isSetSpeciesId (const SpeciesGlyph_t *sg);

/**
 * Calls initDefaults from GraphicalObject.
 * 
 * @param sg The SpeciesGlyph_t structure
 *
 * @memberof SpeciesGlyph_t
 */ 
LIBSBML_EXTERN
void
SpeciesGlyph_initDefaults (SpeciesGlyph_t *sg);

/**
 * @return a (deep) copy of this SpeciesGlyph_t.
 * 
 * @param sg The SpeciesGlyph_t structure
 *
 * @memberof SpeciesGlyph_t
 */
LIBSBML_EXTERN
SpeciesGlyph_t *
SpeciesGlyph_clone (const SpeciesGlyph_t *sg);


END_C_DECLS
LIBSBML_CPP_NAMESPACE_END


#endif  /* !SWIG */
#endif  /* SpeciesGlyph_H__ */
