/**
 * Filename    : layout.i
 * Description : SBML Layout swig file for bindings.
 * Organization: European Media Laboratories Research gGmbH
 * Created     : 2004-07-15
 *
 * Copyright 2004 European Media Laboratories Research gGmbH
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 2.1 of the License, or
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY, WITHOUT EVEN THE IMPLIED WARRANTY OF
 * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  The software and
 * documentation provided hereunder is on an as is" basis, and the European
 * Media Laboratories gGmbH have no obligations to provide maintenance,
 * support, updates, enhancements or modifications.  In no event shall the
 * European Media Laboratory gGmbH be liable to any party for direct,
 * indirect, special, incidental or consequential damages, including lost
 * profits, arising out of the use of this software and its documentation,
 * even if the European Media Laboratories gGmbH have been advised of the
 * possibility of such damage.  See the GNU Lesser General Public License
 * for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
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
 */

#ifdef USE_LAYOUT

%newobject Model::removeLayout;

%ignore BoundingBox::getPosition                      () const;
%ignore BoundingBox::getDimensions                    () const;
%ignore GraphicalObject::getBoundingBox               () const;
%ignore CubicBezier::getBasePoint1                    () const;
%ignore CubicBezier::getBasePoint2                    () const;
%ignore LineSegment::getStart                         () const;
%ignore LineSegment::getEnd                           () const;
%ignore Curve::getListOfCurveSegments                 () const;
%ignore Layout::getDimensions                         () const;
%ignore Layout::getListOfCompartmentGlyphs            () const;
%ignore Layout::getListOfSpeciesGlyphs                () const;
%ignore Layout::getListOfReactionGlyphs               () const;
%ignore Layout::getListOfTextGlyphs                   () const;
%ignore Layout::getListOfAdditionalGraphicalObjects   () const;
%ignore ReactionGlyph::getListOfSpeciesReferenceGlyphs() const;

%newobject parseLayouts;
%newobject parseLayoutId;
%newobject deleteLayoutIdAnnotation;
%newobject deleteLayoutAnnotation;
%newobject removeCompartmentGlyph;
%newobject removeSpeciesGlyph;
%newobject removeReactionGlyph;
%newobject removeTextGlyph;
%newobject removeAdditionalGraphicalObject;
%newobject removeSpeciesReferenceGlyph;

%include sbml/packages/layout/sbml/SpeciesReferenceRole.h
%include sbml/packages/layout/sbml/Point.h
%include sbml/packages/layout/sbml/Dimensions.h
%include sbml/packages/layout/sbml/BoundingBox.h
%include sbml/packages/layout/sbml/GraphicalObject.h
%include sbml/packages/layout/sbml/CompartmentGlyph.h
%include sbml/packages/layout/sbml/LineSegment.h
%include sbml/packages/layout/sbml/CubicBezier.h
%include sbml/packages/layout/sbml/Curve.h
%include sbml/packages/layout/sbml/SpeciesReferenceGlyph.h
%include sbml/packages/layout/sbml/ReferenceGlyph.h
%include sbml/packages/layout/sbml/GeneralGlyph.h
%include sbml/packages/layout/sbml/ReactionGlyph.h
%include sbml/packages/layout/sbml/SpeciesGlyph.h
%include sbml/packages/layout/sbml/TextGlyph.h
%include sbml/packages/layout/sbml/Layout.h

%include sbml/packages/layout/extension/LayoutExtension.h
%include sbml/packages/layout/extension/LayoutModelPlugin.h
%include sbml/packages/layout/extension/LayoutSpeciesReferencePlugin.h

%include sbml/packages/layout/util/LayoutAnnotation.h

%include sbml/packages/layout/validator/LayoutSBMLError.h

%template(LayoutPkgNamespaces) SBMLExtensionNamespaces<LayoutExtension>;



#endif /* USE_LAYOUT */
