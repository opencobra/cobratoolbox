/**
 * @file    layoutfwd.h
 * @brief   C Structure declarations for SBML Layout.
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
 * ---------------------------------------------------------------------- -->
 *
 * The original code contained here was initially developed by:
 *
 *     Ralph Gauges
 *     Bioinformatics Group
 *     European Media Laboratories Research gGmbH
 *     Schloss-Wolfsbrunnenweg 31c
 *     69118 Heidelberg
 *     Germany
 *
 *     http://www.eml-research.de/english/Research/BCB/
 *     mailto:ralph.gauges@eml-r.villa-bosch.de
 *
 * Contributor(s):
 *
 *     Akiya Jouraku <jouraku@bio.keio.ac.jp>
 *     Modified this file for package extension in libSBML5
 *
 */


#ifndef layoutfwd_h__
#define layoutfwd_h__


/**
 * Forward declaration of all opaque C types.
 *
 * Declaring all types up-front avoids "redefinition of type 'Foo'" compile
 * errors and allows our combined C/C++ headers to depend minimally upon
 * each other.  Put another way, the type definitions below serve the same
 * purpose as "class Foo;" forward declarations in C++ code.
 */

#ifdef __cplusplus
#  define CLASS_OR_STRUCT class
#else
#  define CLASS_OR_STRUCT struct
#endif  /* __cplusplus */

LIBSBML_CPP_NAMESPACE_BEGIN

typedef CLASS_OR_STRUCT BoundingBox                     BoundingBox_t;
typedef CLASS_OR_STRUCT CompartmentGlyph                CompartmentGlyph_t;
typedef CLASS_OR_STRUCT CubicBezier                     CubicBezier_t;
typedef CLASS_OR_STRUCT Curve                           Curve_t;
typedef CLASS_OR_STRUCT Dimensions                      Dimensions_t;
typedef CLASS_OR_STRUCT GeneralGlyph                    GeneralGlyph_t;
typedef CLASS_OR_STRUCT GraphicalObject                 GraphicalObject_t;
typedef CLASS_OR_STRUCT Layout                          Layout_t;
typedef CLASS_OR_STRUCT LineSegment                     LineSegment_t;
typedef CLASS_OR_STRUCT Point                           Point_t;
typedef CLASS_OR_STRUCT ReactionGlyph                   ReactionGlyph_t;
typedef CLASS_OR_STRUCT ReferenceGlyph                  ReferenceGlyph_t;
typedef CLASS_OR_STRUCT SpeciesGlyph                    SpeciesGlyph_t;
typedef CLASS_OR_STRUCT SpeciesReferenceGlyph           SpeciesReferenceGlyph_t;
typedef CLASS_OR_STRUCT TextGlyph                       TextGlyph_t;

LIBSBML_CPP_NAMESPACE_END

#undef CLASS_OR_STRUCT


#endif  /* layoutfwd_h__ */
