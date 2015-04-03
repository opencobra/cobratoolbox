/**
 * \file    TestUtilsUnit.c
 * \brief   Utilities on units unit tests (no pun intended)
 * \author  Sarah Keating and Ralph Gauges
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
 * Copyright (C) 2006-2008 by the California Institute of Technology,
 *     Pasadena, CA, USA 
 *  
 * Copyright (C) 2002-2005 jointly by the following organizations: 
 *     1. California Institute of Technology, Pasadena, CA, USA
 *     2. Japan Science and Technology Agency, Japan
 * 
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation.  A copy of the license agreement is provided
 * in the file named "LICENSE.txt" included with this software distribution
 * and also available online as http://sbml.org/software/libsbml/license.html
 * ---------------------------------------------------------------------- -->*/

#include <sbml/common/common.h>

#include <sbml/Unit.h>
#include <sbml/UnitDefinition.h>
#include <sbml/math/ASTNode.h>

#include <check.h>

LIBSBML_CPP_NAMESPACE_USE

BEGIN_C_DECLS

START_TEST(test_unit_remove_scale)
{
    Unit * u = new Unit(2, 4);
    u->setKind(UNIT_KIND_LITRE);
    u->setScale(-3);
    
    Unit::removeScale(u);

    fail_unless(u->getMultiplier() == 0.001);
    fail_unless(u->getScale() == 0);
    fail_unless(u->getExponent() == 1);
    fail_unless(u->getOffset() == 0.0);
    fail_unless(u->getKind() == UNIT_KIND_LITRE);

    delete u; 
}
END_TEST

START_TEST(test_unit_merge_units)
{
    Unit * u = new Unit(2, 4);
    u->setKind(UNIT_KIND_LITRE);
    u->setScale(-3);
    u->setMultiplier(2);
    Unit * u1 = new Unit(2, 4);
    u1->setKind(UNIT_KIND_LITRE);
    u1->setExponent(2);
    u1->setMultiplier(2); 
    
    Unit::merge(u, u1);

    fail_unless(u->getMultiplier() == 0.2);
    fail_unless(u->getScale() == 0);
    fail_unless(u->getExponent() == 3);
    fail_unless(u->getOffset() == 0.0);
    fail_unless(u->getKind() == UNIT_KIND_LITRE);

    fail_unless(u1->getMultiplier() == 2);
    fail_unless(u1->getScale() == 0);
    fail_unless(u1->getExponent() == 2);
    fail_unless(u1->getOffset() == 0.0);
    fail_unless(u1->getKind() == UNIT_KIND_LITRE);

    delete u; 
    delete u1;
}
END_TEST

START_TEST(test_unit_convert_SI)
{
    UnitDefinition * ud;

    /* Avogadro */
    Unit * u1 = new Unit(3, 1);
    u1->setKind(UNIT_KIND_AVOGADRO);
    u1->initDefaults();
    
    ud = Unit::convertToSI(u1);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 6.02214179e23);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);
    delete ud;

    ///* Ampere */
    Unit * u = new Unit(2, 4);
    u->setKind(UNIT_KIND_AMPERE);
    u->setScale(-3);
    u->setMultiplier(2);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.002);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);
    delete ud;

    /* becquerel */
    /* 1 becquerel = 1 sec^-1 = (0.1 sec)^-1 */
    u->setKind(UNIT_KIND_BECQUEREL);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.5);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == -1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* candela */
    u->setKind(UNIT_KIND_CANDELA);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 2);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_CANDELA);
    delete ud;

    ///* Celsius 
    //u->setKind(UNIT_KIND_CELSIUS);
    //u->setMultiplier(1);
    //u->setScale(0);
    //u->setExponent(1);
    //u->setOffset(0.0);
    //
    //ud = Unit::convertToSI(u);

    //fail_unless(ud->getNumUnits() == 1);

    //fail_unless(ud->getUnit(0)->getMultiplier() == 1);
    //fail_unless(ud->getUnit(0)->getScale() == 0);
    //fail_unless(ud->getUnit(0)->getExponent() == 1);
    //fail_unless(ud->getUnit(0)->getOffset() == 273.15);
    //fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_KELVIN);
    //*/

    ///* coulomb */
    ///* 1 coulomb = 1 Ampere second */
    u->setKind(UNIT_KIND_COULOMB);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 2);

    fail_unless(ud->getUnit(0)->getMultiplier() == 2);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == 1);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* dimensionless */
    u->setKind(UNIT_KIND_DIMENSIONLESS);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 2);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);
    delete ud;
    
    ///* farad */
    ///* 1 Farad = 1 m^-2 kg^-1 s^4 A^2 */
    u->setKind(UNIT_KIND_FARAD);
    u->setMultiplier(1);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 4);

    fail_unless(ud->getUnit(0)->getMultiplier() == 1);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 2);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == -1);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);

    fail_unless(ud->getUnit(2)->getMultiplier() == 1);
    fail_unless(ud->getUnit(2)->getScale() == 0);
    fail_unless(ud->getUnit(2)->getExponent() == -2);
    fail_unless(ud->getUnit(2)->getOffset() == 0.0);
    fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);

    fail_unless(ud->getUnit(3)->getMultiplier() == 1);
    fail_unless(ud->getUnit(3)->getScale() == 0);
    fail_unless(ud->getUnit(3)->getExponent() == 4);
    fail_unless(ud->getUnit(3)->getOffset() == 0.0);
    fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* gram */
    ///* 1 gram = 0.001 Kg */
    u->setKind(UNIT_KIND_GRAM);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.002);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_KILOGRAM);
    delete ud;

    ///* gray */
    ///* 1 Gray = 1 m^2 sec^-2 */
    u->setKind(UNIT_KIND_GRAY);
    u->setMultiplier(1);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 2);

    fail_unless(ud->getUnit(0)->getMultiplier() == 1);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 2);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == -2);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* henry */
    ///* 1 Henry = 1 m^2 kg s^-2 A^-2 */
    u->setKind(UNIT_KIND_HENRY);
    u->setMultiplier(4);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 4);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.5);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == -2);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == 1);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);

    fail_unless(ud->getUnit(2)->getMultiplier() == 1);
    fail_unless(ud->getUnit(2)->getScale() == 0);
    fail_unless(ud->getUnit(2)->getExponent() == 2);
    fail_unless(ud->getUnit(2)->getOffset() == 0.0);
    fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);

    fail_unless(ud->getUnit(3)->getMultiplier() == 1);
    fail_unless(ud->getUnit(3)->getScale() == 0);
    fail_unless(ud->getUnit(3)->getExponent() == -2);
    fail_unless(ud->getUnit(3)->getOffset() == 0.0);
    fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* hertz */
    ///* 1 hertz = 1 sec^-1 = (0.1 sec)^-1 */
    u->setKind(UNIT_KIND_HERTZ);
    u->setMultiplier(1);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 1);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == -1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* item */
    u->setKind(UNIT_KIND_ITEM);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 2);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_ITEM);
    delete ud;
    
    ///* joule */
    ///* 1 joule = 1 m^2 kg s^-2 */
    u->setKind(UNIT_KIND_JOULE);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 3);

    fail_unless(ud->getUnit(0)->getMultiplier() == 2.0);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_KILOGRAM);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == 2);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_METRE);

    fail_unless(ud->getUnit(2)->getMultiplier() == 1);
    fail_unless(ud->getUnit(2)->getScale() == 0);
    fail_unless(ud->getUnit(2)->getExponent() == -2);
    fail_unless(ud->getUnit(2)->getOffset() == 0.0);
    fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* katal */
    ///* 1 katal = 1 mol s^-1 */
    u->setKind(UNIT_KIND_KATAL);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 2);

    fail_unless(ud->getUnit(0)->getMultiplier() == 2.0);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == -1);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
    delete ud;
 
    ///* kelvin */
    u->setKind(UNIT_KIND_KELVIN);
    u->setMultiplier(2);
    u->setScale(-3);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.002);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_KELVIN);
    delete ud;

    ///* kilogram */
    u->setKind(UNIT_KIND_KILOGRAM);
    u->setMultiplier(2);
    u->setScale(-3);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.002);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_KILOGRAM);
    delete ud;

    ///* litre */
    ///* 1 litre = 0.001 m^3 = (0.1 m)^3*/ 
    u->setKind(UNIT_KIND_LITRE);
    u->setMultiplier(8);
    u->setScale(-3);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.02);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 3);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
    delete ud;

    // /* litre */
    ///* 1 litre = 0.001 m^3 = (0.1 m)^3*/ 
    u->setKind(UNIT_KIND_LITER);
    u->setMultiplier(8);
    u->setScale(-3);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.02);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 3);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
    delete ud;

    ///* lumen */
    ///* 1 lumen = 1 candela*/ 
    u->setKind(UNIT_KIND_LUMEN);
    u->setMultiplier(2);
    u->setScale(-3);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.002);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_CANDELA);
    delete ud;

    ///* lux */
    ///* 1 lux = 1 candela m^-2*/ 
    u->setKind(UNIT_KIND_LUX);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 2);

    fail_unless(ud->getUnit(0)->getMultiplier() == 2.0);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_CANDELA);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == -2);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_METRE);
    delete ud;
 
    ///* metre */
    u->setKind(UNIT_KIND_METRE);
    u->setMultiplier(2);
    u->setScale(-3);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.002);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
    delete ud;

    ///* meter */
    u->setKind(UNIT_KIND_METER);
    u->setMultiplier(2);
    u->setScale(-3);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.002);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);
    delete ud;

    ///* mole */
    u->setKind(UNIT_KIND_MOLE);
    u->setMultiplier(2);
    u->setScale(-3);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.002);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_MOLE);
    delete ud;

    ///* newton */
    ///* 1 newton = 1 m kg s^-2 */
    u->setKind(UNIT_KIND_NEWTON);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 3);

    fail_unless(ud->getUnit(0)->getMultiplier() == 2.0);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_KILOGRAM);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == 1);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_METRE);

    fail_unless(ud->getUnit(2)->getMultiplier() == 1);
    fail_unless(ud->getUnit(2)->getScale() == 0);
    fail_unless(ud->getUnit(2)->getExponent() == -2);
    fail_unless(ud->getUnit(2)->getOffset() == 0.0);
    fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* ohm */
    ///* 1 ohm = 1 m^2 kg s^-3 A^-2 */
    u->setKind(UNIT_KIND_OHM);
    u->setMultiplier(4);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 4);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.5);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == -2);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == 1);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);

    fail_unless(ud->getUnit(2)->getMultiplier() == 1);
    fail_unless(ud->getUnit(2)->getScale() == 0);
    fail_unless(ud->getUnit(2)->getExponent() == 2);
    fail_unless(ud->getUnit(2)->getOffset() == 0.0);
    fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);

    fail_unless(ud->getUnit(3)->getMultiplier() == 1);
    fail_unless(ud->getUnit(3)->getScale() == 0);
    fail_unless(ud->getUnit(3)->getExponent() == -3);
    fail_unless(ud->getUnit(3)->getOffset() == 0.0);
    fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    /* pascal */
    /* 1 pascal = 1 m^-1 kg s^-2 */
    u->setKind(UNIT_KIND_PASCAL);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 3);

    fail_unless(ud->getUnit(0)->getMultiplier() == 2.0);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_KILOGRAM);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == -1);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_METRE);

    fail_unless(ud->getUnit(2)->getMultiplier() == 1);
    fail_unless(ud->getUnit(2)->getScale() == 0);
    fail_unless(ud->getUnit(2)->getExponent() == -2);
    fail_unless(ud->getUnit(2)->getOffset() == 0.0);
    fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* radian */
    u->setKind(UNIT_KIND_RADIAN);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 2);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);
    delete ud;

    ///* second */
    u->setKind(UNIT_KIND_SECOND);
    u->setMultiplier(2);
    u->setScale(-3);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.002);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* siemens */
    ///* 1 siemen = 1 m^-2 kg^-1 s^3 A^2 */
    u->setKind(UNIT_KIND_SIEMENS);
    u->setMultiplier(1);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 4);

    fail_unless(ud->getUnit(0)->getMultiplier() == 1);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 2);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == -1);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);

    fail_unless(ud->getUnit(2)->getMultiplier() == 1);
    fail_unless(ud->getUnit(2)->getScale() == 0);
    fail_unless(ud->getUnit(2)->getExponent() == -2);
    fail_unless(ud->getUnit(2)->getOffset() == 0.0);
    fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);

    fail_unless(ud->getUnit(3)->getMultiplier() == 1);
    fail_unless(ud->getUnit(3)->getScale() == 0);
    fail_unless(ud->getUnit(3)->getExponent() == 3);
    fail_unless(ud->getUnit(3)->getOffset() == 0.0);
    fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* sievert */
    ///* 1 Sievert = 1 m^2 sec^-2 */
    u->setKind(UNIT_KIND_SIEVERT);
    u->setMultiplier(1);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 2);

    fail_unless(ud->getUnit(0)->getMultiplier() == 1);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 2);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_METRE);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == -2);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* steradian */
    u->setKind(UNIT_KIND_STERADIAN);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 1);

    fail_unless(ud->getUnit(0)->getMultiplier() == 2);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_DIMENSIONLESS);
    delete ud;

    ///* tesla */
    ///* 1 tesla = 1 kg s^-2 A^-1 */
    u->setKind(UNIT_KIND_TESLA);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 3);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.5);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == -1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == 1);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);

    fail_unless(ud->getUnit(2)->getMultiplier() == 1);
    fail_unless(ud->getUnit(2)->getScale() == 0);
    fail_unless(ud->getUnit(2)->getExponent() == -2);
    fail_unless(ud->getUnit(2)->getOffset() == 0.0);
    fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* volt */
    ///* 1 volt = 1 m^2 kg s^-3 A^-1 */
    u->setKind(UNIT_KIND_VOLT);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 4);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.5);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == -1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == 1);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);

    fail_unless(ud->getUnit(2)->getMultiplier() == 1);
    fail_unless(ud->getUnit(2)->getScale() == 0);
    fail_unless(ud->getUnit(2)->getExponent() == 2);
    fail_unless(ud->getUnit(2)->getOffset() == 0.0);
    fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);

    fail_unless(ud->getUnit(3)->getMultiplier() == 1);
    fail_unless(ud->getUnit(3)->getScale() == 0);
    fail_unless(ud->getUnit(3)->getExponent() == -3);
    fail_unless(ud->getUnit(3)->getOffset() == 0.0);
    fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* watt */
    ///* 1 watt = 1 m^2 kg s^-3 */
    u->setKind(UNIT_KIND_WATT);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 3);

    fail_unless(ud->getUnit(0)->getMultiplier() == 2.0);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == 1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_KILOGRAM);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == 2);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_METRE);

    fail_unless(ud->getUnit(2)->getMultiplier() == 1);
    fail_unless(ud->getUnit(2)->getScale() == 0);
    fail_unless(ud->getUnit(2)->getExponent() == -3);
    fail_unless(ud->getUnit(2)->getOffset() == 0.0);
    fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_SECOND);
    delete ud;

    ///* weber */
    ///* 1 weber = 1 m^2 kg s^-2 A^-1 */
    u->setKind(UNIT_KIND_WEBER);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    ud = Unit::convertToSI(u);

    fail_unless(ud->getNumUnits() == 4);

    fail_unless(ud->getUnit(0)->getMultiplier() == 0.5);
    fail_unless(ud->getUnit(0)->getScale() == 0);
    fail_unless(ud->getUnit(0)->getExponent() == -1);
    fail_unless(ud->getUnit(0)->getOffset() == 0.0);
    fail_unless(ud->getUnit(0)->getKind() == UNIT_KIND_AMPERE);

    fail_unless(ud->getUnit(1)->getMultiplier() == 1);
    fail_unless(ud->getUnit(1)->getScale() == 0);
    fail_unless(ud->getUnit(1)->getExponent() == 1);
    fail_unless(ud->getUnit(1)->getOffset() == 0.0);
    fail_unless(ud->getUnit(1)->getKind() == UNIT_KIND_KILOGRAM);

    fail_unless(ud->getUnit(2)->getMultiplier() == 1);
    fail_unless(ud->getUnit(2)->getScale() == 0);
    fail_unless(ud->getUnit(2)->getExponent() == 2);
    fail_unless(ud->getUnit(2)->getOffset() == 0.0);
    fail_unless(ud->getUnit(2)->getKind() == UNIT_KIND_METRE);

    fail_unless(ud->getUnit(3)->getMultiplier() == 1);
    fail_unless(ud->getUnit(3)->getScale() == 0);
    fail_unless(ud->getUnit(3)->getExponent() == -2);
    fail_unless(ud->getUnit(3)->getOffset() == 0.0);
    fail_unless(ud->getUnit(3)->getKind() == UNIT_KIND_SECOND);



    delete u; 
    delete u1;
    delete ud;
    
}
END_TEST

START_TEST(test_unit_areIdentical)
{
    Unit * u = new Unit(2, 4);
    u->setKind(UNIT_KIND_LITRE);
    u->setScale(-3);
    Unit * u1 = new Unit(2, 4);
    u1->setKind(UNIT_KIND_LITRE);
    u1->setScale(-3);
    
    int identical = Unit::areIdentical(u, u1);

    fail_unless(identical == 1);
    
    u->setKind(UNIT_KIND_KATAL);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    identical = Unit::areIdentical(u, u1);
    
    fail_unless(identical == 0);

    delete u; 
    delete u1;
}
END_TEST

START_TEST(test_unit_areEquivalent)
{
    Unit * u = new Unit(2, 4);
    u->setKind(UNIT_KIND_LITRE);
    Unit * u1 = new Unit(2, 4);
    u1->setKind(UNIT_KIND_LITRE);
    u1->setScale(-3);
    
    int equivalent = Unit::areEquivalent(u, u1);

    fail_unless(equivalent == 1);

    u->setKind(UNIT_KIND_MOLE);
    u->setMultiplier(2);
    u->setScale(0);
    u->setExponent(1);
    u->setOffset(0.0);
    
    equivalent = Unit::areEquivalent(u, u1);
    
    fail_unless(equivalent == 0);

    delete u; 
    delete u1;
}
END_TEST


Suite *
create_suite_UtilsUnit (void) 
{ 
  Suite *suite = suite_create("UtilsUnit");
  TCase *tcase = tcase_create("UtilsUnit");
 

  tcase_add_test( tcase, test_unit_remove_scale     );
  tcase_add_test( tcase, test_unit_merge_units      );
  tcase_add_test( tcase, test_unit_convert_SI       );
  tcase_add_test( tcase, test_unit_areIdentical     );
  tcase_add_test( tcase, test_unit_areEquivalent    );

  suite_add_tcase(suite, tcase);

  return suite;
}


END_C_DECLS
