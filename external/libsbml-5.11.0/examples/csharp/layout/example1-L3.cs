/// 
/// \file    example1-L3.cs
/// \brief   SBML Layout example
/// \author  Ralph Gauges
/// \author  Akiya Jouraku
/// \author  Frank Bergmann (translated to C# and adapted to use libsbml-5 package version)
/// 

using System;
using libsbmlcs;

class Example1
{
	public static void Main (string[] args)
	{
		
		//
		// Creates an SBMLNamespaces object with the given SBML level, version
		// package name, package version.
		//
		// (NOTE) By defualt, the name of package (i.e. "layout") will be used
		// if the arugment for the prefix is missing or empty. Thus the argument
		// for the prefix can be added as follows:
		//
		//    SBMLNamespaces sbmlns(3,1,"layout",1,"LAYOUT");
		//
		
		SBMLNamespaces sbmlns = new SBMLNamespaces (3, 1, "layout", 1);
		
		//
		// (NOTES) The above code creating an SBMLNamespaces object can be replaced 
		//         with one of the following other styles.
		//
		// (1) Creates an SBMLNamespace object with a SBML core namespace and then
		//     adds a layout package namespace to the object. 
		//
		//         SBMLNamespaces sbmlns(3,1);
		//         sbmlns.addPkgNamespace("layout",1);
		//
		//           OR
		//
		//         SBMLNamespaces sbmlns(3,1);
		//         sbmlns.addNamespace(LayoutExtension::XmlnsL3V1V1,"layout");
		//
		// (2) Creates a LayoutPkgNamespaces object (SBMLNamespace derived class for
		//     layout package. The class is basically used for createing an SBase derived
		//     objects belonging to the layout package) with the given SBML level, version, 
		//     and package version
		//
		//        LayoutPkgNamespaces sbmlns(3,1,1);
		//     
		
		// create the document
		
		SBMLDocument document = new SBMLDocument (sbmlns);
		
		// set the "required" attribute of layout package  to "true"
		document.setPkgRequired ("layout", true);
		
		// create the Model
		
		Model model = document.createModel ();
		model.setId ("TestModel");
		document.setModel (model);
		
		
		// create the Compartment
		
		Compartment compartment = model.createCompartment ();
		compartment.setId ("Compartment_1");
		compartment.setConstant (true);
		
		// create the Species
		
		Species species1 = model.createSpecies ();
		species1.setId ("Species_1");
		species1.setCompartment (compartment.getId ());
		species1.setHasOnlySubstanceUnits (false);
		species1.setBoundaryCondition (false);
		species1.setConstant (false);
		
		Species species2 = model.createSpecies ();
		species2.setId ("Species_2");
		species2.setCompartment (compartment.getId ());
		species2.setHasOnlySubstanceUnits (false);
		species2.setBoundaryCondition (false);
		species2.setConstant (false);
		
		// create the Reactions
		
		Reaction reaction1 = model.createReaction ();
		reaction1.setId ("Reaction_1");
		reaction1.setReversible (false);
		reaction1.setFast (false);
		
		SpeciesReference reference1 = reaction1.createReactant ();
		reference1.setSpecies (species1.getId ());
		reference1.setId ("SpeciesReference_1");
		reference1.setConstant (false);
		
		
		SpeciesReference reference2 = reaction1.createProduct ();
		reference2.setSpecies (species2.getId ());
		reference2.setId ("SpeciesReference_2");
		reference2.setConstant (false);
		
		Reaction reaction2 = model.createReaction ();
		reaction2.setId ("Reaction_2");
		reaction2.setReversible (false);
		reaction2.setFast (false);
		
		SpeciesReference reference3 = reaction2.createReactant ();
		reference3.setSpecies (species2.getId ());
		reference3.setId ("SpeciesReference_3");
		reference3.setConstant (false);
		
		SpeciesReference reference4 = reaction2.createProduct ();
		reference4.setSpecies (species1.getId ());
		reference4.setId ("SpeciesReference_4");
		reference4.setConstant (false);
		
		
		// create the Layout
		
		//
		// set the LayoutPkgNamespaces for Level 3 Version1 Layout Version 1
		//
		LayoutPkgNamespaces layoutns = new LayoutPkgNamespaces (3, 1, 1);
		
		//
		// Get a LayoutModelPlugin object plugged in the model object.
		//
		// The type of the returned value of SBase::getPlugin() function is SBasePlugin, and
		// thus the value needs to be casted for the corresponding derived class.
		//
		
		LayoutModelPlugin mplugin = (LayoutModelPlugin)(model.getPlugin ("layout"));
		
		if (mplugin == null) {
			Console.Error.WriteLine ("[Fatal Error] Layout Extension Level " + layoutns.getLevel () + " Version " + layoutns.getVersion () + " package version " + layoutns.getPackageVersion () + " is not registered.");
			Environment.Exit (1);
		}
		
		//
		// Creates a Layout object via LayoutModelPlugin object.
		//
		Layout layout = mplugin.createLayout ();
		
		layout.setId ("Layout_1");
		Dimensions dim = new Dimensions (layoutns, 400.0, 220.0);
		layout.setDimensions (dim);
		
		
		// create the CompartmentGlyph
		
		CompartmentGlyph compartmentGlyph = layout.createCompartmentGlyph ();
		compartmentGlyph.setId ("CompartmentGlyph_1");
		compartmentGlyph.setCompartmentId (compartment.getId ());
		BoundingBox bb = new BoundingBox (layoutns, "bb1", 5, 5, 390, 210);
		compartmentGlyph.setBoundingBox (bb);
		
		
		// create the SpeciesGlyphs
		
		SpeciesGlyph speciesGlyph1 = layout.createSpeciesGlyph ();
		speciesGlyph1.setId ("SpeciesGlyph_1");
		speciesGlyph1.setSpeciesId (species1.getId ());
		bb = new BoundingBox (layoutns, "bb2", 80, 26, 240, 24);
		speciesGlyph1.setBoundingBox (bb);
		
		TextGlyph textGlyph1 = layout.createTextGlyph ();
		textGlyph1.setId ("TextGlyph_01");
		bb = new BoundingBox (layoutns, "bbA", 92, 26, 228, 24);
		textGlyph1.setBoundingBox (bb);
		textGlyph1.setOriginOfTextId (speciesGlyph1.getId ());
		textGlyph1.setGraphicalObjectId (speciesGlyph1.getId ());
		
		SpeciesGlyph speciesGlyph2 = layout.createSpeciesGlyph ();
		speciesGlyph2.setId ("SpeciesGlyph_2");
		speciesGlyph2.setSpeciesId (species2.getId ());
		bb = new BoundingBox (layoutns, "bb3", 80, 170, 240, 24);
		speciesGlyph2.setBoundingBox (bb);
		
		TextGlyph textGlyph2 = layout.createTextGlyph ();
		textGlyph2.setId ("TextGlyph_02");
		bb = new BoundingBox (layoutns, "bbB", 92, 170, 228, 24);
		textGlyph2.setBoundingBox (bb);
		textGlyph2.setOriginOfTextId (speciesGlyph2.getId ());
		textGlyph2.setGraphicalObjectId (speciesGlyph2.getId ());
		
		// create the ReactionGlyphs
		
		ReactionGlyph reactionGlyph1 = layout.createReactionGlyph ();
		reactionGlyph1.setId ("ReactionGlyph_1");
		reactionGlyph1.setReactionId (reaction1.getId ());
		
		Curve reactionCurve1 = reactionGlyph1.getCurve ();
		LineSegment ls = reactionCurve1.createLineSegment ();
		Point p = new Point (layoutns, 165, 105);
		ls.setStart (p);
		p = new Point (layoutns, 165, 115);
		ls.setEnd (p);
		
		ReactionGlyph reactionGlyph2 = layout.createReactionGlyph ();
		reactionGlyph2.setId ("ReactionGlyph_1");
		reactionGlyph2.setReactionId (reaction2.getId ());
		
		Curve reactionCurve2 = reactionGlyph2.getCurve ();
		ls = reactionCurve2.createLineSegment ();
		p = new Point (layoutns, 235, 105);
		ls.setStart (p);
		p = new Point (layoutns, 235, 115);
		ls.setEnd (p);
		
		// add the SpeciesReferenceGlyphs
		
		SpeciesReferenceGlyph speciesReferenceGlyph1 = reactionGlyph1.createSpeciesReferenceGlyph ();
		speciesReferenceGlyph1.setId ("SpeciesReferenceGlyph_1");
		speciesReferenceGlyph1.setSpeciesGlyphId (speciesGlyph1.getId ());
		speciesReferenceGlyph1.setSpeciesReferenceId (reference1.getId ());
		speciesReferenceGlyph1.setRole (libsbml.SPECIES_ROLE_SUBSTRATE);
		
		Curve speciesReferenceCurve1 = speciesReferenceGlyph1.getCurve ();
		CubicBezier cb = speciesReferenceCurve1.createCubicBezier ();
		p = new Point (layoutns, 165, 105);
		cb.setStart (p);
		p = new Point (layoutns, 165, 90);
		cb.setBasePoint1 (p);
		p = new Point (layoutns, 165, 90);
		cb.setBasePoint2 (p);
		p = new Point (layoutns, 195, 60);
		cb.setEnd (p);
		
		SpeciesReferenceGlyph speciesReferenceGlyph2 = reactionGlyph1.createSpeciesReferenceGlyph ();
		speciesReferenceGlyph2.setId ("SpeciesReferenceGlyph_2");
		speciesReferenceGlyph2.setSpeciesGlyphId (speciesGlyph2.getId ());
		speciesReferenceGlyph2.setSpeciesReferenceId (reference2.getId ());
		speciesReferenceGlyph2.setRole (libsbml.SPECIES_ROLE_PRODUCT);
		
		Curve speciesReferenceCurve2 = speciesReferenceGlyph2.getCurve ();
		cb = speciesReferenceCurve2.createCubicBezier ();
		p = new Point (layoutns, 165, 115);
		cb.setStart (p);
		p = new Point (layoutns, 165, 130);
		cb.setBasePoint1 (p);
		p = new Point (layoutns, 165, 130);
		cb.setBasePoint2 (p);
		p = new Point (layoutns, 195, 160);
		cb.setEnd (p);
		
		
		SpeciesReferenceGlyph speciesReferenceGlyph3 = reactionGlyph2.createSpeciesReferenceGlyph ();
		speciesReferenceGlyph3.setId ("SpeciesReferenceGlyph_3");
		speciesReferenceGlyph3.setSpeciesGlyphId (speciesGlyph2.getId ());
		speciesReferenceGlyph3.setSpeciesReferenceId (reference3.getId ());
		speciesReferenceGlyph3.setRole (libsbml.SPECIES_ROLE_SUBSTRATE);
		
		Curve speciesReferenceCurve3 = speciesReferenceGlyph3.getCurve ();
		cb = speciesReferenceCurve3.createCubicBezier ();
		p = new Point (layoutns, 235, 115);
		cb.setStart (p);
		p = new Point (layoutns, 235, 130);
		cb.setBasePoint1 (p);
		p = new Point (layoutns, 235, 130);
		cb.setBasePoint2 (p);
		p = new Point (layoutns, 205, 160);
		cb.setEnd (p);
		
		SpeciesReferenceGlyph speciesReferenceGlyph4 = reactionGlyph2.createSpeciesReferenceGlyph ();
		speciesReferenceGlyph4.setId ("SpeciesReferenceGlyph_4");
		speciesReferenceGlyph4.setSpeciesGlyphId (speciesGlyph1.getId ());
		speciesReferenceGlyph4.setSpeciesReferenceId (reference4.getId ());
		speciesReferenceGlyph4.setRole (libsbml.SPECIES_ROLE_PRODUCT);
		
		Curve speciesReferenceCurve4 = speciesReferenceGlyph4.getCurve ();
		cb = speciesReferenceCurve4.createCubicBezier ();
		p = new Point (layoutns, 235, 105);
		cb.setStart (p);
		p = new Point (layoutns, 235, 90);
		cb.setBasePoint1 (p);
		p = new Point (layoutns, 235, 90);
		cb.setBasePoint2 (p);
		p = new Point (layoutns, 205, 60);
		cb.setEnd (p);
		
		libsbml.writeSBML (document, "layout_example1_L3-cs.xml");			
		Console.WriteLine("all done ...");
	}
}
