<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet>

<!--
\file    example1.cpp
\brief   SBML Layout example
\author  Ralph Gauges

$Id: layout2svg.xsl 11938 2010-09-20 02:04:23Z mhucka $
$HeadURL: https://sbml.svn.sourceforge.net/svnroot/sbml/trunk/libsbml/examples/layout/layout2svg.xsl $

Copyright 2004 European Media Laboratories Research gGmbH

This library is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation; either version 2.1 of the License, or
any later version.

This library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY, WITHOUT EVEN THE IMPLIED WARRANTY OF
MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  The software and
documentation provided hereunder is on an "as is" basis, and the
European Media Laboratories Research gGmbH have no obligations to
provide maintenance, support, updates, enhancements or modifications.
In no event shall the European Media Laboratories Research gGmbH be
liable to any party for direct, indirect, special, incidental or
consequential damages, including lost profits, arising out of the use of
this software and its documentation, even if the European Media
Laboratories Research gGmbH have been advised of the possibility of such
damage.  See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this library; if not, write to the Free Software Foundation,
Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.

The original code contained here was initially developed by:

    Ralph Gaugess
    Bioinformatics Group
    European Media Laboratories Research gGmbH
    Schloss-Wolfsbrunnenweg 31c
    69118 Heidelberg
    Germany

    http://www.eml-research.de/english/Research/BCB/
    mailto:ralph.gauges@eml-r.villa-bosch.de

Contributor(s):
-->


<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:math="http://exslt.org/math"
    extension-element-prefixes="math"
    >

    <!-- The following import was documented on the exslt
    webpage, but saxon and xsltproc work without it -->
    <!-- <xsl:import href="math.xsl" /> -->


    <xsl:variable name="SPECIES_GLYPH_GRADIENT_STOP_COLOR_1">white</xsl:variable>
    <xsl:variable name="SPECIES_GLYPH_GRADIENT_STOP_COLOR_2">lightblue</xsl:variable>
    
    <xsl:variable name="COMPARTMENT_GLYPH_STROKE">green</xsl:variable>
    <xsl:variable name="COMPARTMENT_GLYPH_STROKE_WIDTH">2</xsl:variable>
    <xsl:variable name="COMPARTMENT_GLYPH_FILL">lightyellow</xsl:variable>
    <xsl:variable name="COMPARTMENT_GLYPH_RX">30</xsl:variable>
    
    <xsl:variable name="SPECIES_GLYPH_STROKE">black</xsl:variable>
    <xsl:variable name="SPECIES_GLYPH_STROKE_WIDTH">0</xsl:variable>
    <xsl:variable name="SPECIES_GLYPH_FILL">url(#speciesGlyphGradient)</xsl:variable>
     
    <xsl:variable name="REACTION_GLYPH_STROKE">red</xsl:variable>
    <xsl:variable name="REACTION_GLYPH_STROKE_WIDTH">2</xsl:variable>
    <xsl:variable name="REACTION_GLYPH_FILL">lightred</xsl:variable>
    <xsl:variable name="DRAW_REACTION_PSEUDO_NODES">true</xsl:variable>
    <xsl:variable name="REACTION_PSEUDO_NODE_RADIUS">2</xsl:variable>

    <xsl:variable name="SPECIES_REFERENCE_GLYPH_STROKE">orange</xsl:variable>
    <xsl:variable name="SPECIES_REFERENCE_GLYPH_STROKE_WIDTH">2</xsl:variable>
    <xsl:variable name="SPECIES_REFERENCE_GLYPH_FILL">burlywood</xsl:variable>

    <xsl:variable name="TEXT_GLYPH_LENGTH_ADJUST">spacing</xsl:variable>
    <xsl:variable name="TEXT_GLYPH_FILL">black</xsl:variable>
    <xsl:variable name="TEXT_GLYPH_FONT_FAMILY">Helvetica</xsl:variable>
    <xsl:variable name="TEXT_GLYPH_FONT_SCALE">0.8</xsl:variable>

    <xsl:variable name="CURVE_SEGMENT_DEFAULT_STROKE_WIDTH">2</xsl:variable>
    <xsl:variable name="CURVE_SEGMENT_DEFAULT_STROKE">black</xsl:variable>
    <xsl:variable name="CURVE_SEGMENT_DEFAULT_STROKE_FILL">none</xsl:variable>
    <xsl:variable name="CURVE_SEGMENT_DEFAULT_STROKE_DASHARRAY">none</xsl:variable>
    <xsl:variable name="CURVE_SEGMENT_DEFAULT_STROKE_DASHOFFSET">0</xsl:variable>

    <xsl:variable name="CURVE_SEGMENT_INHIBITOR_STROKE_WIDTH">2</xsl:variable>
    <xsl:variable name="CURVE_SEGMENT_INHIBITOR_STROKE">red</xsl:variable>
    <xsl:variable name="CURVE_SEGMENT_INHIBITOR_STROKE_FILL">none</xsl:variable>
    <xsl:variable name="CURVE_SEGMENT_INHIBITOR_STROKE_DASHARRAY">5,3</xsl:variable>
    <xsl:variable name="CURVE_SEGMENT_INHIBITOR_STROKE_DASHOFFSET">0</xsl:variable>

    <xsl:variable name="CURVE_SEGMENT_ACTIVATOR_STROKE_WIDTH">2</xsl:variable>
    <xsl:variable name="CURVE_SEGMENT_ACTIVATOR_STROKE">green</xsl:variable>
    <xsl:variable name="CURVE_SEGMENT_ACTIVATOR_STROKE_FILL">none</xsl:variable>
    <xsl:variable name="CURVE_SEGMENT_ACTIVATOR_STROKE_DASHARRAY">5,3</xsl:variable>
    <xsl:variable name="CURVE_SEGMENT_ACTIVATOR_STROKE_DASHOFFSET">0</xsl:variable>

    
    <xsl:variable name="ARROW_HEAD_LENGTH">15</xsl:variable>
    <xsl:variable name="ARROW_HEAD_WIDTH">10</xsl:variable>
    
    <!-- Root element -->
    <xsl:template match="/">
        <xsl:apply-templates select="child::*[name()='sbml']" />
    </xsl:template>


    <!-- sbml element --> 
    <xsl:template match="child::*[name()='sbml']">
        <xsl:apply-templates select="child::*[name()='model']" />
    </xsl:template>


    <!-- model element -->
    <xsl:template match="child::*[name()='model']">
        <xsl:apply-templates select="child::*[name()='annotation']" />
    </xsl:template>


    <!-- model elements annotation -->
    <xsl:template match="child::*[name()='annotation']">
        <xsl:apply-templates select="child::*[name()='listOfLayouts']" />
    </xsl:template>


    <!-- listOfLayouts element -->
    <xsl:template match="child::*[name()='listOfLayouts']">
        <xsl:apply-templates select="child::*[name()='layout' and position()=1]" />
    </xsl:template>


    <!-- layout element -->
    <xsl:template match="child::*[name()='layout']">

        <!-- generate top level svg element -->
        <xsl:element name="svg"    
            use-attribute-sets="layout-dimensions" >

            <xsl:element name="desc">
                <xsl:text>SVG image generated from SVG layout</xsl:text>
            </xsl:element>
            <!-- define the gradient for the species reference glyphs -->
            <!-- the stop-color for 100% should be made into a variable -->
            <xsl:element name="defs">
                <xsl:element name="radialGradient">
                    <xsl:attribute name="id">speciesGlyphGradient</xsl:attribute>    
                    <xsl:element name="stop">
                        <xsl:attribute name="offset">0%</xsl:attribute>
                        <xsl:attribute name="stop-color"><xsl:value-of select="$SPECIES_GLYPH_GRADIENT_STOP_COLOR_1" /></xsl:attribute>
                    </xsl:element>
                    <xsl:element name="stop">
                        <xsl:attribute name="offset">100%</xsl:attribute>
                        <xsl:attribute name="stop-color"><xsl:value-of select="$SPECIES_GLYPH_GRADIENT_STOP_COLOR_2" /></xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:element>

            <xsl:apply-templates/> 

        </xsl:element>      

    </xsl:template>    



    <!-- listOfCompartmentGlyphs element -->
    <xsl:template match="child::*[name()='listOfCompartmentGlyphs']">
        <xsl:apply-templates select="child::*[name()='compartmentGlyph']" />
    </xsl:template>


    <!-- compartmentGlyph element -->
    <xsl:template match="child::*[name()='compartmentGlyph']">
        <xsl:element name="rect" use-attribute-sets="boundingBox">
            <xsl:attribute name="fill"><xsl:value-of select="$COMPARTMENT_GLYPH_FILL" /></xsl:attribute>
            <xsl:attribute name="stroke"><xsl:value-of select="$COMPARTMENT_GLYPH_STROKE" /></xsl:attribute>
            <xsl:attribute name="stroke-width"><xsl:value-of select="$COMPARTMENT_GLYPH_STROKE_WIDTH" /></xsl:attribute>
            <xsl:attribute name="rx"><xsl:value-of select="$COMPARTMENT_GLYPH_RX" /></xsl:attribute>
        </xsl:element>
    </xsl:template>


    <!-- speciesGlyph element -->
    <!-- make rx always half the box height -->
    <xsl:template match="child::*[name()='speciesGlyph']">
        <xsl:element name="rect" use-attribute-sets="boundingBox">
            <xsl:attribute name="rx">10</xsl:attribute>
            <xsl:attribute name="fill"><xsl:value-of select="$SPECIES_GLYPH_FILL" /></xsl:attribute>
            <xsl:attribute name="stroke"><xsl:value-of select="$SPECIES_GLYPH_STROKE" /></xsl:attribute>
            <xsl:attribute name="stroke-width"><xsl:value-of select="$SPECIES_GLYPH_STROKE_WIDTH" /></xsl:attribute>
        </xsl:element>
    </xsl:template>


    <!-- reactionGlyph element -->
    <xsl:template match="child::*[name()='reactionGlyph']">
        <xsl:choose>
            <xsl:when test="child::*[name()='curve']">
                <xsl:apply-templates select="child::*[name()='curve']" />
                <xsl:if test="$DRAW_REACTION_PSEUDO_NODES='true'">
                    <xsl:if test="count(child::*[name()='curve']/child::*[name()='listOfCurveSegments']/child::*) &gt; 0">
                        <xsl:element name="circle">
                            <xsl:attribute name="cx">
                                <xsl:value-of select="child::*[name()='curve']/child::*[name()='listOfCurveSegments']/child::*[position()=1]/child::*[name()='start']/attribute::x" />
                            </xsl:attribute>
                            <xsl:attribute name="cy">
                                <xsl:value-of select="child::*[name()='curve']/child::*[name()='listOfCurveSegments']/child::*[position()=1]/child::*[name()='start']/attribute::y" />
                            </xsl:attribute>
                            <xsl:attribute name="r">
                                <xsl:value-of select="$REACTION_PSEUDO_NODE_RADIUS" />
                            </xsl:attribute>
                            <xsl:attribute name="stroke">black</xsl:attribute>
                            <xsl:attribute name="stroke-width">2</xsl:attribute>
                            <xsl:attribute name="fill">black</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="circle">
                            <xsl:attribute name="cx">
                                <xsl:value-of select="child::*[name()='curve']/child::*[name()='listOfCurveSegments']/child::*[position()=last()]/child::*[name()='end']/attribute::x" />
                            </xsl:attribute>
                            <xsl:attribute name="cy">
                                <xsl:value-of select="child::*[name()='curve']/child::*[name()='listOfCurveSegments']/child::*[position()=last()]/child::*[name()='end']/attribute::y" />
                            </xsl:attribute>
                            <xsl:attribute name="r">
                                <xsl:value-of select="$REACTION_PSEUDO_NODE_RADIUS" />
                            </xsl:attribute>
                            <xsl:attribute name="stroke">black</xsl:attribute>
                            <xsl:attribute name="stroke-width">2</xsl:attribute>
                            <xsl:attribute name="fill">black</xsl:attribute>
                        </xsl:element>
                    </xsl:if>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="rect" use-attribute-sets="boundingBox">
                    <xsl:attribute name="fill"><xsl:value-of select="$REACTION_GLYPH_FILL" /></xsl:attribute>
                    <xsl:attribute name="stroke"><xsl:value-of select="$REACTION_GLYPH_STROKE" /></xsl:attribute>
                    <xsl:attribute name="stroke-width"><xsl:value-of select="$REACTION_GLYPH_STROKE_WIDTH" /></xsl:attribute>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="child::*[name()='listOfSpeciesReferenceGlyphs']" />
    </xsl:template>


    <!-- speciesReferenceGlyph element -->
    <!-- make fill and stroke into variable -->
    <xsl:template match="child::*[name()='speciesReferenceGlyph']">
        <!-- check if this is a substrate
        and the reaction is irreversible,
        then don't draw the arrowhead -->
        <xsl:variable name="isSubstrate">
            <xsl:call-template name="isSubstrate">
                <xsl:with-param name="Id" select="attribute::speciesReference" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="isReversibleSubstrate">
            <xsl:call-template name="belongsToReversibleReaction">
                <xsl:with-param name="Id" select="attribute::speciesReference" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:comment>id: <xsl:value-of select="attribute::id" /></xsl:comment>
        <xsl:choose>
            <xsl:when test="child::*[name()='curve']">
                <xsl:apply-templates select="child::*[name()='curve']" >
                    <xsl:with-param name="drawArrowHead" select="( $isSubstrate!='1' ) or ( $isReversibleSubstrate != 'false' )" />
                    <xsl:with-param name="role" select="attribute::role" />
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="rect" use-attribute-sets="boundingBox">
                    <xsl:attribute name="fill"><xsl:value-of select="$SPECIES_REFERENCE_GLYPH_FILL" /></xsl:attribute>
                    <xsl:attribute name="stroke"><xsl:value-of select="$SPECIES_REFERENCE_GLYPH_STROKE" /></xsl:attribute>
                    <xsl:attribute name="stroke-width"><xsl:value-of select="$SPECIES_REFERENCE_GLYPH_STROKE_WIDTH" /></xsl:attribute>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- textGlyph element -->
    <xsl:template match="child::*[name()='textGlyph']">
        <xsl:element name="g">
            <xsl:element name="text" use-attribute-sets="textPositionAndSize">
                <xsl:attribute name="lengthAdjust"><xsl:value-of select="$TEXT_GLYPH_LENGTH_ADJUST" /></xsl:attribute>
                <xsl:attribute name="fill"><xsl:value-of select="$TEXT_GLYPH_FILL" /></xsl:attribute>
                <xsl:attribute name="font-family"><xsl:value-of select="$TEXT_GLYPH_FONT_FAMILY" /></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="attribute::text">
                        <xsl:value-of select="attribute::text" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="attribute::originOfText">
                                <xsl:call-template name="getNameForId">
                                    <xsl:with-param name="Id" ><xsl:value-of select="attribute::originOfText" /></xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:comment>Neither text nor originOfText attribute given on textGlyph with id<xsl:value-of select="attribute::id" /> .</xsl:comment>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose> 
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- curve element -->
    <xsl:template match="child::*[name()='curve']">
        <xsl:param name="drawArrowHead" select="0" />
        <xsl:param name="role" select="undefined" />
        <xsl:apply-templates select="child::*[name()='listOfCurveSegments']">
            <xsl:with-param name="drawArrowHead" select="$drawArrowHead" />
            <xsl:with-param name="role" select="$role" />
        </xsl:apply-templates>
    </xsl:template>

    <!-- listOfSpeciesReferenceGlyphs element -->
    <xsl:template match="child::*[name()='listOfSpeciesReferenceGlyphs']" >
        <xsl:apply-templates select="child::*[name()='speciesReferenceGlyph']"/>
    </xsl:template>

    <!-- listOfCurveSegments element -->
    <xsl:template match="child::*[name()='listOfCurveSegments']" >
        <xsl:param name="drawArrowHead" select="0" />
        <xsl:param name="role" select="undefined" />
        <xsl:apply-templates select="child::*[name()='curveSegment']">
            <xsl:with-param name="drawArrowHead" select="$drawArrowHead" />
            <xsl:with-param name="role" select="$role" />
        </xsl:apply-templates>  
    </xsl:template>

    <!-- curveSegment element -->
    <xsl:template match="child::*[name()='curveSegment']" >
        <xsl:param name="drawArrowHead" select="0" />
        <xsl:param name="role" select="undefined" />
        <xsl:variable name="stroke-width">
            <xsl:choose>
            <xsl:when test="$role='inhibitor'">
                <xsl:value-of select="$CURVE_SEGMENT_INHIBITOR_STROKE_WIDTH" />
            </xsl:when>
            <xsl:when test="$role='activator'">
                <xsl:value-of select="$CURVE_SEGMENT_ACTIVATOR_STROKE_WIDTH" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$CURVE_SEGMENT_DEFAULT_STROKE_WIDTH" />
            </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="stroke">
            <xsl:choose>   
            <xsl:when test="$role='inhibitor'">
                <xsl:value-of select="$CURVE_SEGMENT_INHIBITOR_STROKE" />
            </xsl:when>
            <xsl:when test="$role='activator'">
                <xsl:value-of select="$CURVE_SEGMENT_ACTIVATOR_STROKE" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$CURVE_SEGMENT_DEFAULT_STROKE" />
            </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="fill">
            <xsl:choose>
            <xsl:when test="$role='inhibitor'">
                <xsl:value-of select="$CURVE_SEGMENT_INHIBITOR_STROKE_FILL" />
            </xsl:when>
            <xsl:when test="$role='activator'">
                <xsl:value-of select="$CURVE_SEGMENT_ACTIVATOR_STROKE_FILL" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$CURVE_SEGMENT_DEFAULT_STROKE_FILL" />
            </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="stroke-dasharray">
            <xsl:choose>    
            <xsl:when test="$role='inhibitor'">
                <xsl:value-of select="$CURVE_SEGMENT_INHIBITOR_STROKE_DASHARRAY" />
            </xsl:when>
            <xsl:when test="$role='activator'">
                <xsl:value-of select="$CURVE_SEGMENT_ACTIVATOR_STROKE_DASHARRAY" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$CURVE_SEGMENT_DEFAULT_STROKE_DASHARRAY" />
            </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="stroke-dashoffset">
            <xsl:choose>   
            <xsl:when test="$role='inhibitor'">
                <xsl:value-of select="$CURVE_SEGMENT_INHIBITOR_STROKE_DASHOFFSET" />
            </xsl:when>
            <xsl:when test="$role='activator'">
                <xsl:value-of select="$CURVE_SEGMENT_ACTIVATOR_STROKE_DASHOFFSET" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$CURVE_SEGMENT_DEFAULT_STROKE_DASHOFFSET" />
            </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="attribute::xsi:type='LineSegment'">
                <xsl:element name="line" use-attribute-sets="lineSegment">
                    <xsl:attribute name="stroke-width"><xsl:value-of select="$stroke-width" /></xsl:attribute>
                    <xsl:attribute name="stroke"><xsl:value-of select="$stroke" /></xsl:attribute>
                    <xsl:attribute name="fill"><xsl:value-of select="$fill" /></xsl:attribute>
                    <xsl:attribute name="stroke-dasharray"><xsl:value-of select="$stroke-dasharray" /></xsl:attribute>
                    <xsl:attribute name="stroke-dashoffset"><xsl:value-of select="$stroke-dashoffset" /></xsl:attribute>
                </xsl:element>
                <!-- if it is the last curveSegment and drawArrowHead!=0, then draw an arrow head -->
                <xsl:if test="position()=last() and $drawArrowHead!=0">
                    <xsl:call-template name="calculateArrowHeadPath" >
                        <xsl:with-param name="x1" select="child::*[name()='start']/attribute::x" />
                        <xsl:with-param name="y1" select="child::*[name()='start']/attribute::y" />
                        <xsl:with-param name="x2" select="child::*[name()='end']/attribute::x" />
                        <xsl:with-param name="y2" select="child::*[name()='end']/attribute::y" />
                        <xsl:with-param name="stroke" select="$stroke" />
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:when test="attribute::xsi:type='CubicBezier'">
                <xsl:choose>
                    <xsl:when test="count(child::*)=2">
                        <xsl:element name="path" use-attribute-sets="cubicBezier2Points">
                            <xsl:attribute name="stroke-width"><xsl:value-of select="$stroke-width" /></xsl:attribute>
                            <xsl:attribute name="stroke"><xsl:value-of select="$stroke" /></xsl:attribute>
                            <xsl:attribute name="fill"><xsl:value-of select="$fill" /></xsl:attribute>
                            <xsl:attribute name="stroke-dasharray"><xsl:value-of select="$stroke-dasharray" /></xsl:attribute>
                            <xsl:attribute name="stroke-dashoffset"><xsl:value-of select="$stroke-dashoffset" /></xsl:attribute>
                        </xsl:element>
                        <!-- if it is the last curveSegment and drawArrowHead!=0, then draw an arrow head -->
                        <xsl:if test="position()=last() and $drawArrowHead!=0">
                            <xsl:call-template name="calculateArrowHeadPath" >
                                <xsl:with-param name="x1" select="child::*[name()='start']/attribute::x" />
                                <xsl:with-param name="y1" select="child::*[name()='start']/attribute::y" />
                                <xsl:with-param name="x2" select="child::*[name()='end']/attribute::x" />
                                <xsl:with-param name="y2" select="child::*[name()='end']/attribute::y" />
                                <xsl:with-param name="stroke" select="$stroke" />
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when> 
                    <xsl:when test="count(child::*)=4">
                        <xsl:element name="path" use-attribute-sets="cubicBezier4Points">
                            <xsl:attribute name="stroke-width"><xsl:value-of select="$stroke-width" /></xsl:attribute>
                            <xsl:attribute name="stroke"><xsl:value-of select="$stroke" /></xsl:attribute>
                            <xsl:attribute name="fill"><xsl:value-of select="$fill" /></xsl:attribute>
                            <xsl:attribute name="stroke-dasharray"><xsl:value-of select="$stroke-dasharray" /></xsl:attribute>
                            <xsl:attribute name="stroke-dashoffset"><xsl:value-of select="$stroke-dashoffset" /></xsl:attribute>
                 </xsl:element>
                        <!-- if it is the last curveSegment and drawArrowHead!=0, then draw an arrow head -->
                        <xsl:if test="position()=last() and $drawArrowHead!=0">
                            <xsl:call-template name="calculateArrowHeadPath" >
                                <xsl:with-param name="x1" select="child::*[name()='basePoint2']/attribute::x" />
                                <xsl:with-param name="y1" select="child::*[name()='basePoint2']/attribute::y" />
                                <xsl:with-param name="x2" select="child::*[name()='end']/attribute::x" />
                                <xsl:with-param name="y2" select="child::*[name()='end']/attribute::y" />
                                <xsl:with-param name="stroke" select="$stroke" />
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when> 
                    <xsl:otherwise>
                        <xsl:comment>Curve Segment needs 2 or 4 points!!!</xsl:comment>
                    </xsl:otherwise>
                </xsl:choose>  
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>Could not find a LineSegment or CubiBezier!!!</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- attribute set that determines position and size
    for a textGlyph -->
    <!-- make dx and dy variables -->
    
    <xsl:attribute-set name="textPositionAndSize">
        <xsl:attribute name="x"><xsl:value-of select="child::*[name()='boundingBox']/child::*[name()='position']/attribute::x" /></xsl:attribute>
        <xsl:attribute name="y"><xsl:value-of select="child::*[name()='boundingBox']/child::*[name()='position']/attribute::y" /></xsl:attribute>
        <xsl:attribute name="dx"><xsl:value-of select="10" /></xsl:attribute>
        <xsl:attribute name="dy"><xsl:value-of select="child::*[name()='boundingBox']/child::*[name()='dimensions']/attribute::height - 5" /></xsl:attribute>
        <xsl:attribute name="textLength"><xsl:value-of select="child::*[name()='boundingBox']/child::*[name()='dimensions']/attribute::width" /></xsl:attribute>
        <xsl:attribute name="font-size"><xsl:value-of select="child::*[name()='boundingBox']/child::*[name()='dimensions']/attribute::height * $TEXT_GLYPH_FONT_SCALE" /></xsl:attribute>
    </xsl:attribute-set>

    <!-- attribute set that generates the two points for a line segment -->
    <xsl:attribute-set name="lineSegment">
        <xsl:attribute name="x1"><xsl:value-of select="child::*[name()='start']/attribute::x" /></xsl:attribute>
        <xsl:attribute name="y1"><xsl:value-of select="child::*[name()='start']/attribute::y" /></xsl:attribute>
        <xsl:attribute name="x2"><xsl:value-of select="child::*[name()='end']/attribute::x" /></xsl:attribute>
        <xsl:attribute name="y2"><xsl:value-of select="child::*[name()='end']/attribute::y" /></xsl:attribute>
    </xsl:attribute-set>

    <!-- attribute set that generates the four points for
    a cubic bezier -->
    <xsl:attribute-set name="cubicBezier4Points">
        <xsl:attribute name="d">M <xsl:value-of select="child::*[name()='start']/attribute::x" /><xsl:text> </xsl:text><xsl:value-of select="child::*[name()='start']/attribute::y" /> C <xsl:value-of select="child::*[name()='basePoint1']/attribute::x" /><xsl:text> </xsl:text><xsl:value-of select="child::*[name()='basePoint1']/attribute::y" /><xsl:text> </xsl:text><xsl:value-of select="child::*[name()='basePoint2']/attribute::x" /><xsl:text> </xsl:text><xsl:value-of select="child::*[name()='basePoint2']/attribute::y" /><xsl:text> </xsl:text><xsl:value-of select="child::*[name()='end']/attribute::x" /><xsl:text> </xsl:text><xsl:value-of select="child::*[name()='end']/attribute::y" /></xsl:attribute>
    </xsl:attribute-set>    

    <!-- attribute set that generates the four points for a
    cubic bezier where only two points have been specified
    in the file.
    This effectively is a straight line, but if the resulting SVG file is opened in an graphics program,
    the curve can be edited as cubic bezier.
    -->
    <xsl:attribute-set name="cubicBezier2Points">
        <xsl:attribute name="d">M <xsl:value-of select="child::*[name()='start']/attribute::x" /><xsl:text> </xsl:text><xsl:value-of select="child::*[name()='start']/attribute::y" /> L <xsl:value-of select="child::*[name()='end']/attribute::x" /><xsl:text> </xsl:text><xsl:value-of select="child::*[name()='end']/attribute::y" /></xsl:attribute>
    </xsl:attribute-set>

    <!-- creates the attributes for a box -->
    <xsl:attribute-set name="boundingBox">
        <xsl:attribute name="x"><xsl:value-of select="child::*[name()='boundingBox']/child::*[name()='position']/attribute::x" /></xsl:attribute>
        <xsl:attribute name="y"><xsl:value-of select="child::*[name()='boundingBox']/child::*[name()='position']/attribute::y" /></xsl:attribute>
        <xsl:attribute name="width"><xsl:value-of select="child::*[name()='boundingBox']/child::*[name()='dimensions']/attribute::width" /></xsl:attribute>
        <xsl:attribute name="height"><xsl:value-of select="child::*[name()='boundingBox']/child::*[name()='dimensions']/attribute::height" /></xsl:attribute>
    </xsl:attribute-set>


    <!-- get the dimensions for the layout -->
    <xsl:attribute-set name="layout-dimensions">
        <xsl:attribute name="width"><xsl:value-of select="child::*[name()='dimensions']/attribute::width" />pt</xsl:attribute>
        <xsl:attribute name="height"><xsl:value-of select="child::*[name()='dimensions']/attribute::height" />pt</xsl:attribute>
        <xsl:attribute name="viewBox">0 0 <xsl:value-of select="child::*[name()='dimensions']/attribute::width" /><xsl:text> </xsl:text><xsl:value-of select="child::*[name()='dimensions']/attribute::height" /></xsl:attribute>
        <xsl:attribute name="version">1.1</xsl:attribute>
    </xsl:attribute-set>


    <!-- given the id of an object this template tries to find the name,
    if the object does not have a name, the id is returned.
    -->
    <xsl:template name="getNameForId" >
        <xsl:param name="Id" />
        <xsl:for-each select="/child::*[name()='sbml']/descendant-or-self::*" >
            <xsl:if test="attribute::id=$Id" >
                <xsl:choose>
                    <xsl:when test="attribute::name">
                        <xsl:value-of select="attribute::name" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$Id" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- given two points that make a straight line, this
    template calculates an arrow head that is located
    at the end of the line and points in the direction
    of the line
    -->
    <xsl:template name="calculateArrowHeadPath" >
        <xsl:param name="x1" />
        <xsl:param name="y1" />
        <xsl:param name="x2" />
        <xsl:param name="y2" />
        <xsl:param name="stroke" />
        <xsl:param name="d1" select="$ARROW_HEAD_LENGTH" />
        <xsl:param name="d2" select="$ARROW_HEAD_WIDTH div 2" />
        <xsl:variable name="slope" select="( $y2 - $y1 ) div ( $x2 - $x1 )" />
        <xsl:variable name="invslope" select="-1 div $slope" />
        <xsl:variable name="sqrtSlope" select="math:sqrt( ( $slope * $slope ) + 1 )" />
        <xsl:variable name="sqrtInvSlope" select="math:sqrt( 1 + ( $invslope * $invslope ) )" />
        <xsl:variable name="xOffset1" select="$d1 div $sqrtSlope" />
        <xsl:variable name="yOffset1" select="$slope * $xOffset1" />
        <xsl:variable name="xOffset2" select="$d2 div $sqrtInvSlope" />
        <xsl:variable name="yOffset2" select="$invslope * $xOffset2" />
        <xsl:element name="path">
            <xsl:attribute name="stroke"><xsl:value-of select="$stroke" /></xsl:attribute>
            <xsl:attribute name="fill"><xsl:value-of select="$stroke" /></xsl:attribute>
            <xsl:choose>
                <xsl:when test="( $x2 - $x1 ) = 0">
                    <xsl:attribute name="d" >
                        <xsl:text>M </xsl:text>
                        <xsl:value-of select="$x2" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$y2" />
                        <xsl:text> L </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$y2 &lt; $y1">
                                <xsl:value-of select="$x2 + $d2" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$y2 + $d1" />
                                <xsl:text> L </xsl:text>
                                <xsl:value-of select="$x2 - $d2" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$y2 + $d1" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$x2 + $d2" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$y2 - $d1" />
                                <xsl:text> L </xsl:text>
                                <xsl:value-of select="$x2 - $d2" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$y2 - $d1" />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> Z</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="( $y2 - $y1 ) = 0">
                    <xsl:attribute name="d" >
                        <xsl:text>M </xsl:text>
                        <xsl:value-of select="$x2" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$y2" />
                        <xsl:text> L </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$x2 &lt; $x1" >
                                <xsl:value-of select="$x2 + $d1" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$y2 + $d2" />
                                <xsl:text> L </xsl:text>
                                <xsl:value-of select="$x2 + $d1" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$y2 - $d2" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$x2 - $d1" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$y2 + $d2" />
                                <xsl:text> L </xsl:text>
                                <xsl:value-of select="$x2 - $d1" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$y2 - $d2" />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> Z</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="d" >
                        <xsl:text>M </xsl:text>
                        <xsl:value-of select="$x2" />
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$y2" />
                        <xsl:text> L </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$x1 &gt; $x2">
                                <xsl:value-of select="$x2 + $xOffset1 + $xOffset2" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$y2 + $yOffset1 + $yOffset2" />
                                <xsl:text> L </xsl:text>
                                <xsl:value-of select="$x2 + $xOffset1 - $xOffset2" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$y2 + $yOffset1 - $yOffset2" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$x2 - $xOffset1 + $xOffset2" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$y2 - $yOffset1 + $yOffset2" />
                                <xsl:text> L </xsl:text>
                                <xsl:value-of select="$x2 - $xOffset1 - $xOffset2" />
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$y2 - $yOffset1 - $yOffset2" />
                            </xsl:otherwise>
                    </xsl:choose>
                        <xsl:text> Z</xsl:text>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!-- find out if a given id belongs to a species reference which is a substrate -->
    <xsl:template name="isSubstrate">
        <xsl:param name="Id" /> 
        <xsl:for-each select="/child::*[name()='sbml']/child::*[name()='model']/child::*[name()='listOfReactions']/child::*[name()='reaction']/child::*[name()='listOfReactants']/child::*[name()='speciesReference']" >
            <xsl:if test="child::*[name()='annotation']/child::*[name()='layoutId']/attribute::id=$Id" >
                <xsl:value-of select="1" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    
    <!-- determines if a species reference belongs to a reversible reaction --> 
    <xsl:template name="belongsToReversibleReaction">
        <xsl:param name="Id" />
        <!-- select all species references that are in the listOfReactants from all reactions and go through them -->
        <xsl:for-each select="/child::*[name()='sbml']/child::*[name()='model']/child::*[name()='listOfReactions']/child::*[name()='reaction']/child::*[name()='listOfReactants']/child::*[name()='speciesReference']" >
            <!-- if the id fits the given id return the value of the reversible
             attribute of it's parent reaction -->
             <xsl:if test="child::*[name()='annotation']/child::*[name()='layoutId']/attribute::id=$Id" >
                 <!-- if there is no reversible attribute, an empty string
                 is returned. Otherwise, true or false are returned.
                 Since true is the default value, the caller only
                 has to check wether the return value is false, all
                 else is true
                 -->
                 <xsl:choose>
                     <xsl:when test="count(../../attribute::reversible)=0">
                         <xsl:text>true</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                         <xsl:value-of select="../../attribute::reversible" />
                     </xsl:otherwise>
                 </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
 </xsl:stylesheet>


