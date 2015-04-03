/**
 * @file    local-layout.i
 * @brief   cs-specific SWIG directives for wrapping libSBML layout API this file 
 *          has been adapted from the SWIG java bindings written by 
 * 	    Ben Bornstein and Akiya Jouraku
 * @author  Frank Bergmann (fbergman@u.washington.edu)
 * @author  Akiya Jouraku
 *
 */

/*
 *This file is part of libSBML.  Please visit http://sbml.org for more
 *information about SBML, and the latest version of libSBML.
 *
 *Copyright (C) 2013-2014 jointly by the following organizations:
 *    1. California Institute of Technology, Pasadena, CA, USA
 *    2. EMBL European Bioinformatics Institute (EMBL-EBI), Hinxton, UK
 *    3. University of Heidelberg, Heidelberg, Germany
 *
 *Copyright 2008 California Institute of Technology.
 *
 *This library is free software; you can redistribute it and/or modify it
 *under the terms of the GNU Lesser General Public License as published by
 *the Free Software Foundation.  A copy of the license agreement is provided
 *in the file named "LICENSE.txt" included with this software distribution
 *and also available online as http://sbml.org/software/libsbml/license.html
 */

#ifdef USE_LAYOUT

/**
 * Adds DownCastBase(long cPtr, boolean owner) method for the layout package extension
 */
%typemap(cscode) LayoutExtension
%{
	public override SBasePlugin DowncastSBasePlugin(IntPtr cPtr, bool owner)
	{
		if (cPtr.Equals(IntPtr.Zero)) return null;
		
		SBasePlugin sbp = new SBasePlugin(cPtr, false);
		SBase sb = sbp.getParentSBMLObject();

		switch( sb.getTypeCode() )
		{
			case (int) libsbml.SBML_MODEL:
				return new LayoutModelPlugin(cPtr,owner);
			case (int) libsbml.SBML_SPECIES_REFERENCE:
			case (int) libsbml.SBML_MODIFIER_SPECIES_REFERENCE:
				return new LayoutSpeciesReferencePlugin(cPtr,owner);
			default:
				return new SBasePlugin(cPtr,owner);
		}
	}

	public override SBase DowncastSBase(IntPtr cPtr, bool owner)
	{
		if (cPtr.Equals(IntPtr.Zero)) return null;
		
		SBase sb = new SBase(cPtr, false);
		switch( sb.getTypeCode() )
		{
			case (int) libsbml.SBML_LIST_OF:
			     string name = sb.getElementName();
		             if(name =="listOfCompartmentGlyphs")
			     {
		               return new ListOfCompartmentGlyphs(cPtr, owner);
                             }
		             else if(name =="listOfAdditionalGraphicalObjects")
			     {
		               return new ListOfGraphicalObjects(cPtr, owner);
                             }
		             else if(name =="listOfLayouts")
                             {
		               return new ListOfLayouts(cPtr, owner);
                             }
		             else if(name =="listOfCurveSegments")
			     {
		               return new ListOfLineSegments(cPtr, owner);
                             }
		             else if(name =="listOfSpeciesGlyphs")
			     {
		               return new ListOfSpeciesGlyphs(cPtr, owner);
                             }
		             else if(name =="listOfSpeciesReferenceGlyphs")
			     {
		               return new ListOfSpeciesReferenceGlyphs(cPtr, owner);
                             }
		             else if(name =="listOfReactionGlyphs")
			     {
		               return new ListOfReactionGlyphs(cPtr, owner);
                             }
		             else if(name =="listOfTextGlyphs")
			     {
		               return new ListOfTextGlyphs(cPtr, owner);
                             }
					 else if(name =="listOfReferenceGlyphs")
			     {
		               return new ListOfReferenceGlyphs(cPtr, owner);
                             }
					 
		             return new ListOf(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_BOUNDINGBOX:
				return new BoundingBox(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_COMPARTMENTGLYPH:
				return new CompartmentGlyph(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_CUBICBEZIER:
				return new CubicBezier(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_CURVE:
				return new Curve(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_DIMENSIONS:
				return new Dimensions(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_GRAPHICALOBJECT:
				return new GraphicalObject(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_LAYOUT:
				return new Layout(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_LINESEGMENT:
				return new LineSegment(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_POINT:
				return new Point(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_REACTIONGLYPH:
				return new ReactionGlyph(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_SPECIESGLYPH:
				return new SpeciesGlyph(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_SPECIESREFERENCEGLYPH:
				return new SpeciesReferenceGlyph(cPtr, owner);
				
			case (int) libsbml.SBML_LAYOUT_TEXTGLYPH:
				return new TextGlyph(cPtr, owner);
			
			case (int) libsbml.SBML_LAYOUT_REFERENCEGLYPH:
				return new ReferenceGlyph(cPtr, owner);
			
			case (int) libsbml.SBML_LAYOUT_GENERALGLYPH:
				return new GeneralGlyph(cPtr, owner);
			
			default:
				return new SBase(cPtr, owner);
		}
	}
%}


//
// Convert LineSegment objects into the most specific object possible.
//
%typemap("csout") LineSegment*
{
	return (LineSegment) libsbml.DowncastSBase($imcall, $owner);
}

//
// Convert LineSegment objects into the most specific object possible.
//
%typemap("csout") GraphicalObject*
{
	return (GraphicalObject) libsbml.DowncastSBase($imcall, $owner);
}

COVARIANT_RTYPE_CLONE(LayoutExtension)
COVARIANT_RTYPE_CLONE(BoundingBox)
COVARIANT_RTYPE_CLONE(CompartmentGlyph)
COVARIANT_RTYPE_CLONE(CubicBezier)
COVARIANT_RTYPE_CLONE(Curve)
COVARIANT_RTYPE_CLONE(Dimensions)
COVARIANT_RTYPE_CLONE(GraphicalObject)
COVARIANT_RTYPE_CLONE(Layout)
COVARIANT_RTYPE_CLONE(LineSegment)
COVARIANT_RTYPE_CLONE(Point)
COVARIANT_RTYPE_CLONE(ReactionGlyph)
COVARIANT_RTYPE_CLONE(SpeciesGlyph)
COVARIANT_RTYPE_CLONE(SpeciesReferenceGlyph)
COVARIANT_RTYPE_CLONE(TextGlyph)
COVARIANT_RTYPE_CLONE(ReferenceGlyph)
COVARIANT_RTYPE_CLONE(GeneralGlyph)
COVARIANT_RTYPE_CLONE(ListOfGraphicalObjects)
COVARIANT_RTYPE_CLONE(ListOfLayouts)
COVARIANT_RTYPE_CLONE(ListOfLineSegments)
COVARIANT_RTYPE_CLONE(ListOfReactionGlyphs)
COVARIANT_RTYPE_CLONE(ListOfSpeciesGlyphs)
COVARIANT_RTYPE_CLONE(ListOfSpeciesReferenceGlyphs)
COVARIANT_RTYPE_CLONE(ListOfTextGlyphs)
COVARIANT_RTYPE_CLONE(ListOfCompartmentGlyphs)
COVARIANT_RTYPE_CLONE(ListOfReferenceGlyphs)

COVARIANT_RTYPE_LISTOF_GET_REMOVE(GraphicalObject)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(Layout)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(LineSegment)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(ReactionGlyph)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(SpeciesGlyph)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(SpeciesReferenceGlyph)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(TextGlyph)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(CompartmentGlyph)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(ReferenceGlyph)
COVARIANT_RTYPE_LISTOF_GET_REMOVE(GeneralGlyph)

SBMLCONSTRUCTOR_EXCEPTION(BoundingBox)
SBMLCONSTRUCTOR_EXCEPTION(GraphicalObject)
SBMLCONSTRUCTOR_EXCEPTION(CompartmentGlyph)
SBMLCONSTRUCTOR_EXCEPTION(LineSegment)
SBMLCONSTRUCTOR_EXCEPTION(CubicBezier)
SBMLCONSTRUCTOR_EXCEPTION(Curve)
SBMLCONSTRUCTOR_EXCEPTION(Dimensions)
SBMLCONSTRUCTOR_EXCEPTION(Layout)
SBMLCONSTRUCTOR_EXCEPTION(ReferenceGlyph)
SBMLCONSTRUCTOR_EXCEPTION(GeneralGlyph)
SBMLCONSTRUCTOR_EXCEPTION(LayoutPkgNamespaces)
SBMLCONSTRUCTOR_EXCEPTION(ListOfCompartmentGlyphs)
SBMLCONSTRUCTOR_EXCEPTION(ListOfGraphicalObjects)
SBMLCONSTRUCTOR_EXCEPTION(ListOfLayouts)
SBMLCONSTRUCTOR_EXCEPTION(ListOfLineSegments)
SBMLCONSTRUCTOR_EXCEPTION(ListOfReactionGlyphs)
SBMLCONSTRUCTOR_EXCEPTION(ListOfSpeciesGlyphs)
SBMLCONSTRUCTOR_EXCEPTION(ListOfSpeciesReferenceGlyphs)
SBMLCONSTRUCTOR_EXCEPTION(ListOfTextGlyphs)
SBMLCONSTRUCTOR_EXCEPTION(ListOfReferenceGlyphs)
SBMLCONSTRUCTOR_EXCEPTION(Point)
SBMLCONSTRUCTOR_EXCEPTION(ReactionGlyph)
SBMLCONSTRUCTOR_EXCEPTION(SpeciesGlyph)
SBMLCONSTRUCTOR_EXCEPTION(SpeciesReferenceGlyph)
SBMLCONSTRUCTOR_EXCEPTION(TextGlyph)

#endif


