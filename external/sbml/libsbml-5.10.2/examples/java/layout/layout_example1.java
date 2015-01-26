/**
 * \file    layout_example1.java
 * \brief   SBML Layout example
 * \author  Ralph Gauges
 * 
/* Copyright 2004 European Media Laboratories Research gGmbH
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
 * European Media Laboratories Research gGmbH have no obligations to
 * provide maintenance, support, updates, enhancements or modifications.
 * In no event shall the European Media Laboratories Research gGmbH be
 * liable to any party for direct, indirect, special, incidental or
 * consequential damages, including lost profits, arising out of the use of
 * this software and its documentation, even if the European Media
 * Laboratories Research gGmbH have been advised of the possibility of such
 * damage.  See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * The original code contained here was initially developed by:
 *
 *     Ralph Gaugess
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

import org.sbml.libsbml.*;

public class layout_example1
{
  /**
   * Loads the SWIG generated libsbml Java module when this class is
   * loaded.
   */
  static
  {
    System.loadLibrary("sbmlj");
  }

  public static Point createPoint(double x, double y)
  {
    Point point = new Point();
    point.setX(x);
    point.setY(y);
    return point;
  }
  
  public static Dimensions createDimensions(double width, double height)
  {
    Dimensions dim = new Dimensions();
    dim.setWidth(width);
    dim.setHeight(height);
    return dim;
  }
  
  public static BoundingBox createBoundingBox(String id, double x, double y, double width, double height)
  {
    BoundingBox bounds = new BoundingBox();
    bounds.setId(id);
    bounds.setX(x);
    bounds.setY(y);
    bounds.setWidth(width);
    bounds.setHeight(height);
    return bounds;
  }
  
  public static void main (String args[])
  {

    // create the document

    SBMLDocument document=new SBMLDocument(2,1);
      
    // ensure the layout api is enabled
    document.enablePackage(LayoutExtension.getXmlnsL2(),"layout", true);
      
    // create the Model

    Model model=document.createModel("TestModel");


    // create the Compartment

    Compartment compartment=model.createCompartment();
    compartment.setId("Compartment_1");

    // create the Species

    Species species1=model.createSpecies();
    species1.setId("Species_1");
    species1.setCompartment(compartment.getId());

    Species species2=model.createSpecies();
    species2.setId("Species_2");
    species2.setCompartment(compartment.getId());

    // create the Reactions

    Reaction reaction1=model.createReaction();
    reaction1.setId("Reaction_1");

    SpeciesReference reference1=reaction1.createReactant();
    reference1.setSpecies(species1.getId());
    reference1.setId("SpeciesReference_1");

    reaction1.setReversible(false);

    SpeciesReference reference2=reaction1.createProduct();
    reference2.setSpecies(species2.getId());
    reference2.setId("SpeciesReference_2");

    Reaction reaction2=model.createReaction();
    reaction2.setId("Reaction_2");
    reaction2.setReversible(false);

    SpeciesReference reference3=reaction2.createReactant();
    reference3.setSpecies(species2.getId());
    reference3.setId("SpeciesReference_3");

    SpeciesReference reference4=reaction2.createProduct();
    reference4.setSpecies(species1.getId());
    reference4.setId("SpeciesReference_4");

    // create the Layout
        
    LayoutModelPlugin mplugin = (LayoutModelPlugin)(model.getPlugin("layout"));
    Layout layout=mplugin.createLayout();

    layout.setId("Layout_1");
    layout.setDimensions(createDimensions(400,220));


    // create the CompartmentGlyph

    CompartmentGlyph compartmentGlyph=layout.createCompartmentGlyph();
    compartmentGlyph.setId("CompartmentGlyph_1");
    compartmentGlyph.setCompartmentId(compartment.getId());
    compartmentGlyph.setBoundingBox(createBoundingBox("bb1", 5, 5, 390, 210));


    // create the SpeciesGlyphs

    SpeciesGlyph speciesGlyph1=layout.createSpeciesGlyph();
    speciesGlyph1.setId("SpeciesGlyph_1");
    speciesGlyph1.setSpeciesId(species1.getId());
    speciesGlyph1.setBoundingBox(createBoundingBox("bb2", 80, 26, 240, 24));

    TextGlyph textGlyph1=layout.createTextGlyph();
    textGlyph1.setId("TextGlyph_01");
    textGlyph1.setBoundingBox(createBoundingBox("bbA", 92, 26, 228, 24));
    textGlyph1.setOriginOfTextId(speciesGlyph1.getId());
    textGlyph1.setGraphicalObjectId(speciesGlyph1.getId());

    SpeciesGlyph speciesGlyph2=layout.createSpeciesGlyph();
    speciesGlyph2.setId("SpeciesGlyph_2");
    speciesGlyph2.setSpeciesId(species2.getId());
    speciesGlyph2.setBoundingBox(createBoundingBox("bb3", 80, 170, 240, 24));

    TextGlyph textGlyph2=layout.createTextGlyph();
    textGlyph2.setId("TextGlyph_02");
    textGlyph2.setBoundingBox(createBoundingBox("bbB", 92, 170, 228, 24));
    textGlyph2.setOriginOfTextId(speciesGlyph2.getId());
    textGlyph2.setGraphicalObjectId(speciesGlyph2.getId());

    // create the ReactionGlyphs

    ReactionGlyph reactionGlyph1=layout.createReactionGlyph();
    reactionGlyph1.setId("ReactionGlyph_1");
    reactionGlyph1.setReactionId(reaction1.getId());

    Curve reactionCurve1=reactionGlyph1.getCurve();
    LineSegment ls=reactionCurve1.createLineSegment();
    ls.setStart(createPoint(165,105));
    ls.setEnd(createPoint(165, 115));

    ReactionGlyph reactionGlyph2=layout.createReactionGlyph();
    reactionGlyph2.setId("ReactionGlyph_2");
    reactionGlyph2.setReactionId(reaction2.getId());

    Curve reactionCurve2=reactionGlyph2.getCurve();
    ls=reactionCurve2.createLineSegment();
    ls.setStart(createPoint(235, 105));
    ls.setEnd(createPoint(235,115));

    // add the SpeciesReferenceGlyphs

    SpeciesReferenceGlyph speciesReferenceGlyph1=reactionGlyph1.createSpeciesReferenceGlyph();
    speciesReferenceGlyph1.setId("SpeciesReferenceGlyph_1");
    speciesReferenceGlyph1.setSpeciesGlyphId(speciesGlyph1.getId());
    speciesReferenceGlyph1.setSpeciesReferenceId(reference1.getId());
    speciesReferenceGlyph1.setRole(libsbmlConstants.SPECIES_ROLE_SUBSTRATE);

    Curve speciesReferenceCurve1=speciesReferenceGlyph1.getCurve();
    CubicBezier cb=speciesReferenceCurve1.createCubicBezier();
    cb.setStart(createPoint(165.0,105.0));
    cb.setBasePoint1(createPoint(165.0,90.0));
    cb.setBasePoint2(createPoint(165.0,90.0));
    cb.setEnd(createPoint(195.0,60.0));

    SpeciesReferenceGlyph speciesReferenceGlyph2=reactionGlyph1.createSpeciesReferenceGlyph();
    speciesReferenceGlyph2.setId("SpeciesReferenceGlyph_2");
    speciesReferenceGlyph2.setSpeciesGlyphId(speciesGlyph2.getId());
    speciesReferenceGlyph2.setSpeciesReferenceId(reference2.getId());
    speciesReferenceGlyph2.setRole(libsbmlConstants.SPECIES_ROLE_PRODUCT);

    Curve speciesReferenceCurve2=speciesReferenceGlyph2.getCurve();
    cb=speciesReferenceCurve2.createCubicBezier();
    cb.setStart(createPoint(165.0,115.0));
    cb.setBasePoint1(createPoint(165.0,130.0));
    cb.setBasePoint2(createPoint(165.0,130.0));
    cb.setEnd(createPoint(195.0,160.0));


    SpeciesReferenceGlyph speciesReferenceGlyph3=reactionGlyph2.createSpeciesReferenceGlyph();
    speciesReferenceGlyph3.setId("SpeciesReferenceGlyph_3");
    speciesReferenceGlyph3.setSpeciesGlyphId(speciesGlyph2.getId());
    speciesReferenceGlyph3.setSpeciesReferenceId(reference3.getId());
    speciesReferenceGlyph3.setRole(libsbmlConstants.SPECIES_ROLE_SUBSTRATE);

    Curve speciesReferenceCurve3=speciesReferenceGlyph3.getCurve();
    cb=speciesReferenceCurve3.createCubicBezier();
    cb.setStart(createPoint(235.0,115.0));
    cb.setBasePoint1(createPoint(235.0,130.0));
    cb.setBasePoint2(createPoint(235.0,130.0));
    cb.setEnd(createPoint(205.0,160.0));

    SpeciesReferenceGlyph speciesReferenceGlyph4=reactionGlyph2.createSpeciesReferenceGlyph();
    speciesReferenceGlyph4.setId("SpeciesReferenceGlyph_4");
    speciesReferenceGlyph4.setSpeciesGlyphId(speciesGlyph1.getId());
    speciesReferenceGlyph4.setSpeciesReferenceId(reference4.getId());
    speciesReferenceGlyph4.setRole(libsbmlConstants.SPECIES_ROLE_PRODUCT);

    Curve speciesReferenceCurve4=speciesReferenceGlyph4.getCurve();
    cb=speciesReferenceCurve4.createCubicBezier();
    cb.setStart(createPoint(235.0,105.0));
    cb.setBasePoint1(createPoint(235.0,90.0));
    cb.setBasePoint2(createPoint(235.0,90.0));
    cb.setEnd(createPoint(205.0,60.0));


    libsbml.writeSBML(document,"TestModel1-java.xml");

    System.gc();
  }
}
