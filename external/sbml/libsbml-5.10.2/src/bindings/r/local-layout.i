/**
 * Filename    : local-layout.i
 * Description : SBML Layout include file for bindings.
 * Organization: European Media Laboratories Research gGmbH
 * Created     : 2005-04-17
 *
 * Copyright 2005 European Media Laboratories Research gGmbH
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 2.1 of the License, or
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY, WITHOUT EVEN THE IMPLIED WARRANTY OF
 * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  The software and
 * documentation provided hereunder is on an "as is" basis, and the
 * European Media Laboratories gGmbH have no obligations to provide maintenance, support,
 * updates, enhancements or modifications.  In no event shall the
 * European Media Laboratory gGmbH be liable to any party for direct, indirect, special,
 * incidental or consequential damages, including lost profits, arising
 * out of the use of this software and its documentation, even if the
 * European Media Laboratories gGmbH have been advised of the possibility of such damage.  See
 * the GNU Lesser General Public License for more details.
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

SBMLCONSTRUCTOR_EXCEPTION(BoundingBox)
SBMLCONSTRUCTOR_EXCEPTION(GraphicalObject)
SBMLCONSTRUCTOR_EXCEPTION(CompartmentGlyph)
SBMLCONSTRUCTOR_EXCEPTION(LineSegment)
SBMLCONSTRUCTOR_EXCEPTION(CubicBezier)
SBMLCONSTRUCTOR_EXCEPTION(Curve)
SBMLCONSTRUCTOR_EXCEPTION(Dimensions)
SBMLCONSTRUCTOR_EXCEPTION(Layout)
SBMLCONSTRUCTOR_EXCEPTION(LayoutPkgNamespaces)
SBMLCONSTRUCTOR_EXCEPTION(ListOfCompartmentGlyphs)
SBMLCONSTRUCTOR_EXCEPTION(ListOfGraphicalObjects)
SBMLCONSTRUCTOR_EXCEPTION(ListOfLayouts)
SBMLCONSTRUCTOR_EXCEPTION(ListOfLineSegments)
SBMLCONSTRUCTOR_EXCEPTION(ListOfReactionGlyphs)
SBMLCONSTRUCTOR_EXCEPTION(ListOfSpeciesGlyphs)
SBMLCONSTRUCTOR_EXCEPTION(ListOfSpeciesReferenceGlyphs)
SBMLCONSTRUCTOR_EXCEPTION(ListOfTextGlyphs)
SBMLCONSTRUCTOR_EXCEPTION(Point)
SBMLCONSTRUCTOR_EXCEPTION(ReactionGlyph)
SBMLCONSTRUCTOR_EXCEPTION(SpeciesGlyph)
SBMLCONSTRUCTOR_EXCEPTION(SpeciesReferenceGlyph)
SBMLCONSTRUCTOR_EXCEPTION(TextGlyph)
SBMLCONSTRUCTOR_EXCEPTION(ListOfReferenceGlyphs)
SBMLCONSTRUCTOR_EXCEPTION(ReferenceGlyph)
SBMLCONSTRUCTOR_EXCEPTION(GeneralGlyph)

/**
 * Convert LineSegment objects into the most specific type possible.
 */
%typemap(out) LineSegment*
{
  $result = SWIG_NewPointerObj($1, GetDowncastSwigType($1), $owner | %newpointer_flags);
}

/**
 * Convert GraphicalObject objects into the most specific type possible.
 */
%typemap(out) GraphicalObject*
{
  $result = SWIG_NewPointerObj($1, GetDowncastSwigType($1), $owner | %newpointer_flags);
}

#endif

