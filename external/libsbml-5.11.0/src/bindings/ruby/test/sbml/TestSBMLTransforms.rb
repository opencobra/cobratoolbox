#
# @file    TestSBMLTransforms.rb
# @brief   SBMLTransforms unit tests
#
# @author  Akiya Jouraku (Ruby conversion)
# @author  Sarah Keating 
# 
# This test file was converted from src/sbml/test/TestSBMLTransforms.cpp
# with the help of conversion sciprt (ctest_converter.pl).
#
#<!---------------------------------------------------------------------------
# This file is part of libSBML.  Please visit http://sbml.org for more
# information about SBML, and the latest version of libSBML.
#
# Copyright 2005-2010 California Institute of Technology.
# Copyright 2002-2005 California Institute of Technology and
#                     Japan Science and Technology Corporation.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation.  A copy of the license agreement is provided
# in the file named "LICENSE.txt" included with this software distribution
# and also available online as http://sbml.org/software/libsbml/license.html
#--------------------------------------------------------------------------->*/
require 'test/unit'
require 'libSBML'
include Math

class TestSBMLTransforms < Test::Unit::TestCase

  @@DBL_EPSILON =  2.2204460492503131e-16

  def equalDouble (a, b)
    return ((a-b).abs < sqrt(@@DBL_EPSILON))
  end

  def isnan(x)
    return (x != x)
  end

  def pow(x, y)
    return x ** y
  end

  def test_SBMLTransforms_replaceFD
    reader = LibSBML::SBMLReader.new()
    filename = "../../sbml/test/test-data/"
    filename += "multiple-functions.xml"
    d = reader.readSBML(filename)
    if (d == nil)
    end
    m = d.getModel()
    assert( m.getNumFunctionDefinitions() == 2 )
    d.expandFunctionDefinitions()
    assert( d.getModel().getNumFunctionDefinitions() == 0 )
    ast = d.getModel().getReaction(0).getKineticLaw().getMath()
    assert ((  "S1 * p * compartmentOne / t" == LibSBML::formulaToString(ast) ))
    ast = d.getModel().getReaction(1).getKineticLaw().getMath()
    assert ((  "S1 * p * compartmentOne / t" == LibSBML::formulaToString(ast) ))
    ast = d.getModel().getReaction(2).getKineticLaw().getMath()
    assert ((  "S1 * p * compartmentOne / t" == LibSBML::formulaToString(ast) ))
  end

  def test_SBMLTransforms_replaceIA
    reader = LibSBML::SBMLReader.new()
    filename = "../../sbml/test/test-data/"
    filename += "initialAssignments.xml"
    d = reader.readSBML(filename)
    if (d == nil)
    end
    m = d.getModel()
    assert( m.getNumInitialAssignments() == 2 )
    assert_equal false, (m.getCompartment(0).isSetSize())
    assert( m.getParameter(1).getValue() == 2 )
    d.expandInitialAssignments()
    assert( d.getModel().getNumInitialAssignments() == 0 )
    assert_equal true, d.getModel().getCompartment(0).isSetSize()
    assert( d.getModel().getCompartment(0).getSize() == 25.0 )
    assert( m.getParameter(1).getValue() == 50 )
  end

  def test_SBMLTransforms_replaceIA_species
    reader = LibSBML::SBMLReader.new()
    filename = "../../sbml/test/test-data/"
    filename += "initialAssignments_species.xml"
    d = reader.readSBML(filename)
    if (d == nil)
    end
    m = d.getModel()
    assert( m.getNumInitialAssignments() == 3 )
    assert( m.getParameter(1).getValue() == 0.75 )
    assert_equal false, (m.getParameter(2).isSetValue())
    assert_equal true, m.getSpecies(2).isSetInitialAmount()
    assert( m.getSpecies(2).getInitialAmount() == 2 )
    d.expandInitialAssignments()
    assert( d.getModel().getNumInitialAssignments() == 0 )
    assert( m.getParameter(1).getValue() == 3 )
    assert_equal true, m.getParameter(2).isSetValue()
    assert( m.getParameter(2).getValue() == 0.75 )
    assert_equal false, (m.getSpecies(2).isSetInitialAmount())
    assert( m.getSpecies(2).getInitialConcentration() == 2 )
  end

end

