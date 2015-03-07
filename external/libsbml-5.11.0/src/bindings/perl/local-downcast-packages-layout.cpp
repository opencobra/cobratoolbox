
#ifdef USE_LAYOUT
else if (pkgName == "layout")
{
    switch (sb->getTypeCode())
    {
		case SBML_LIST_OF:
			name = sb->getElementName();
			if(name == "listOfCompartmentGlyphs"){
				return SWIGTYPE_p_ListOfCompartmentGlyphs;
			}
			else if(name == "listOfAdditionalGraphicalObjects"){
				return SWIGTYPE_p_ListOfGraphicalObjects;
			}
			else if(name == "listOfLayouts"){
				return SWIGTYPE_p_ListOfLayouts;
			}
			else if(name == "listOfCurveSegments"){
				return SWIGTYPE_p_ListOfLineSegments;
			}
			else if(name == "listOfSpeciesGlyphs"){
				return SWIGTYPE_p_ListOfSpeciesGlyphs;
			}
			else if(name == "listOfSpeciesReferenceGlyphs"){
				return SWIGTYPE_p_ListOfSpeciesReferenceGlyphs;
			}
			else if(name == "listOfReactionGlyphs"){
				return SWIGTYPE_p_ListOfReactionGlyphs;
			}
			else if(name == "listOfTextGlyphs"){
				return SWIGTYPE_p_ListOfTextGlyphs;
			}
			else if(name == "listOfReferenceGlyphs"){
				return SWIGTYPE_p_ListOfReferenceGlyphs;
			}
			return SWIGTYPE_p_ListOf;
			
		case SBML_LAYOUT_BOUNDINGBOX:
			return SWIGTYPE_p_BoundingBox;
			
		case SBML_LAYOUT_COMPARTMENTGLYPH:
			return SWIGTYPE_p_CompartmentGlyph;
			
		case SBML_LAYOUT_CUBICBEZIER:
			return SWIGTYPE_p_CubicBezier;
			
		case SBML_LAYOUT_CURVE:
			return SWIGTYPE_p_Curve;
			
		case SBML_LAYOUT_DIMENSIONS:
			return SWIGTYPE_p_Dimensions;
			
		case SBML_LAYOUT_GRAPHICALOBJECT:
			return SWIGTYPE_p_GraphicalObject;
			
		case SBML_LAYOUT_LAYOUT:
			return SWIGTYPE_p_Layout;
			
		case SBML_LAYOUT_LINESEGMENT:
			return SWIGTYPE_p_LineSegment;
			
		case SBML_LAYOUT_POINT:
			return SWIGTYPE_p_Point;
			
		case SBML_LAYOUT_REACTIONGLYPH:
			return SWIGTYPE_p_ReactionGlyph;
			
		case SBML_LAYOUT_SPECIESGLYPH:
			return SWIGTYPE_p_SpeciesGlyph;
			
		case SBML_LAYOUT_SPECIESREFERENCEGLYPH:
			return SWIGTYPE_p_SpeciesReferenceGlyph;
			
		case SBML_LAYOUT_TEXTGLYPH:
			return SWIGTYPE_p_TextGlyph;
			
		case SBML_LAYOUT_REFERENCEGLYPH:
			return SWIGTYPE_p_ReferenceGlyph;
			
		case SBML_LAYOUT_GENERALGLYPH:
			return SWIGTYPE_p_GeneralGlyph;
			
		default:
			return SWIGTYPE_p_SBase;
    }
}
#endif // USE_LAYOUT
