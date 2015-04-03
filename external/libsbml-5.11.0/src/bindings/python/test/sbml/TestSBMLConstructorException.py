#
# @file    TestSBMLConstructorException.py
# @brief   SBMLConstructorException unit tests
# @author  Akiya Jouraku 
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
#
import sys
import unittest
import libsbml

class TestSBMLConstructorException(unittest.TestCase):

  ERR_MSG = "Level/version/namespaces combination is invalid"
  SN11 = libsbml.SBMLNamespaces(1,1)
  SN12 = libsbml.SBMLNamespaces(1,2)
  SN21 = libsbml.SBMLNamespaces(2,1)
  SN22 = libsbml.SBMLNamespaces(2,2)
  SN23 = libsbml.SBMLNamespaces(2,3)
  SN24 = libsbml.SBMLNamespaces(2,4)
  SN31 = libsbml.SBMLNamespaces(3,1)
  SN99 = libsbml.SBMLNamespaces(9,9)

  def test_CompartmentType_constructor(self):
    s = None;
    try:
      s = libsbml.CompartmentType(2,2)
      s = libsbml.CompartmentType(2,3)
      s = libsbml.CompartmentType(2,4)
      s = libsbml.CompartmentType(self.SN22)
      s = libsbml.CompartmentType(self.SN23)
      s = libsbml.CompartmentType(self.SN24)
    except ValueError:
      s = None
    pass
    self.assert_(s != None)

    msg = ""

    try:
      s = libsbml.CompartmentType(1,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg,  self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.CompartmentType(1,2)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg,  self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.CompartmentType(2,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.CompartmentType(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.CompartmentType(self.SN11)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg,  self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.CompartmentType(self.SN12)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg,  self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.CompartmentType(self.SN21)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.CompartmentType(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_Compartment_constructor(self):
    s = None
    try:
      s = libsbml.Compartment(1,1)
      s = libsbml.Compartment(1,2)
      s = libsbml.Compartment(2,1)
      s = libsbml.Compartment(2,2)
      s = libsbml.Compartment(2,3)
      s = libsbml.Compartment(2,4)
      s = libsbml.Compartment(3,1)
      s = libsbml.Compartment(self.SN11)
      s = libsbml.Compartment(self.SN12)
      s = libsbml.Compartment(self.SN21)
      s = libsbml.Compartment(self.SN22)
      s = libsbml.Compartment(self.SN23)
      s = libsbml.Compartment(self.SN24)
      s = libsbml.Compartment(self.SN31)
    except ValueError:
       s = None
    pass
    self.assert_(s != None)

    msg = ""
    
    try:
      s = libsbml.Compartment(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    
    try:
      s = libsbml.Compartment(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_Constraint_constructor(self):
    s = None
    try:
      s = libsbml.Constraint(2,2)
      s = libsbml.Constraint(2,3)
      s = libsbml.Constraint(2,4)
      s = libsbml.Constraint(3,1)
      s = libsbml.Constraint(self.SN22)
      s = libsbml.Constraint(self.SN23)
      s = libsbml.Constraint(self.SN24)
      s = libsbml.Constraint(self.SN31)
    except ValueError:
       s = None
    pass
    self.assert_(s != None)

    msg = ""

    try:
      s = libsbml.Constraint(1,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    try:
      s = libsbml.Constraint(1,2)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.Constraint(2,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.Constraint(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.Constraint(self.SN11)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.Constraint(self.SN12)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.Constraint(self.SN21)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.Constraint(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_InitialAssignment_constructor(self):
    s = None
    try:
      s = libsbml.InitialAssignment(2,2)
      s = libsbml.InitialAssignment(2,3)
      s = libsbml.InitialAssignment(2,4)
      s = libsbml.InitialAssignment(3,1)
      s = libsbml.InitialAssignment(self.SN22)
      s = libsbml.InitialAssignment(self.SN23)
      s = libsbml.InitialAssignment(self.SN24)
      s = libsbml.InitialAssignment(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    try:
      s = libsbml.InitialAssignment(1,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    try:
      s = libsbml.InitialAssignment(1,2)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.InitialAssignment(2,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.InitialAssignment(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.InitialAssignment(self.SN11)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.InitialAssignment(self.SN12)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.InitialAssignment(self.SN21)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.InitialAssignment(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_Species_constructor(self):
    s = None
    try:
      s = libsbml.Species(1,1)
      s = libsbml.Species(1,2)
      s = libsbml.Species(2,1)
      s = libsbml.Species(2,2)
      s = libsbml.Species(2,3)
      s = libsbml.Species(2,4)
      s = libsbml.Species(3,1)
      s = libsbml.Species(self.SN11)
      s = libsbml.Species(self.SN12)
      s = libsbml.Species(self.SN21)
      s = libsbml.Species(self.SN22)
      s = libsbml.Species(self.SN23)
      s = libsbml.Species(self.SN24)
      s = libsbml.Species(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)
	
    msg = ""
    
    try:
      s = libsbml.Species(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    
    try:
      s = libsbml.Species(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_SpeciesType_constructor(self):
    s = None
    try:
      s = libsbml.SpeciesType(2,2)
      s = libsbml.SpeciesType(2,3)
      s = libsbml.SpeciesType(2,4)
      s = libsbml.SpeciesType(self.SN22)
      s = libsbml.SpeciesType(self.SN23)
      s = libsbml.SpeciesType(self.SN24)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    try:
      s = libsbml.SpeciesType(1,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    try:
      s = libsbml.SpeciesType(1,2)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.SpeciesType(2,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.SpeciesType(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.SpeciesType(self.SN11)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.SpeciesType(self.SN12)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.SpeciesType(self.SN21)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.SpeciesType(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_Delay_constructor(self):
    s = None
    try:
      s = libsbml.Delay(2,1)
      s = libsbml.Delay(2,2)
      s = libsbml.Delay(2,3)
      s = libsbml.Delay(2,4)
      s = libsbml.Delay(3,1)
      s = libsbml.Delay(self.SN21)
      s = libsbml.Delay(self.SN22)
      s = libsbml.Delay(self.SN23)
      s = libsbml.Delay(self.SN24)
      s = libsbml.Delay(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    try:
      s = libsbml.Delay(1,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    try:
      s = libsbml.Delay(1,2)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.Delay(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    try:
      s = libsbml.Delay(self.SN11)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.Delay(self.SN12)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    try:
      s = libsbml.Delay(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_Trigger_constructor(self):
    s = None
    try:
      s = libsbml.Trigger(2,1)
      s = libsbml.Trigger(2,2)
      s = libsbml.Trigger(2,3)
      s = libsbml.Trigger(2,4)
      s = libsbml.Trigger(3,1)
      s = libsbml.Trigger(self.SN21)
      s = libsbml.Trigger(self.SN22)
      s = libsbml.Trigger(self.SN23)
      s = libsbml.Trigger(self.SN24)
      s = libsbml.Trigger(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    try:
      s = libsbml.Trigger(1,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    try:
      s = libsbml.Trigger(1,2)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.Trigger(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    try:
      s = libsbml.Trigger(self.SN11)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.Trigger(self.SN12)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    try:
      s = libsbml.Trigger(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_Event_constructor(self):
    s = None
    try:
      s = libsbml.Event(2,1)
      s = libsbml.Event(2,2)
      s = libsbml.Event(2,3)
      s = libsbml.Event(2,4)
      s = libsbml.Event(3,1)
      s = libsbml.Event(self.SN21)
      s = libsbml.Event(self.SN22)
      s = libsbml.Event(self.SN23)
      s = libsbml.Event(self.SN24)
      s = libsbml.Event(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    try:
      s = libsbml.Event(1,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    try:
      s = libsbml.Event(1,2)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.Event(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.Event(self.SN11)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.Event(self.SN12)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    try:
      s = libsbml.Event(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_EventAssignment_constructor(self):
    s = None
    try:
      s = libsbml.EventAssignment(2,1)
      s = libsbml.EventAssignment(2,2)
      s = libsbml.EventAssignment(2,3)
      s = libsbml.EventAssignment(2,4)
      s = libsbml.EventAssignment(3,1)
      s = libsbml.EventAssignment(self.SN21)
      s = libsbml.EventAssignment(self.SN22)
      s = libsbml.EventAssignment(self.SN23)
      s = libsbml.EventAssignment(self.SN24)
      s = libsbml.EventAssignment(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    try:
      s = libsbml.EventAssignment(1,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    try:
      s = libsbml.EventAssignment(1,2)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.EventAssignment(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.EventAssignment(self.SN11)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.EventAssignment(self.SN12)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    try:
      s = libsbml.EventAssignment(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_ModifierSpeciesReference_constructor(self):
    s = None
    try:
      s = libsbml.ModifierSpeciesReference(2,1)
      s = libsbml.ModifierSpeciesReference(2,2)
      s = libsbml.ModifierSpeciesReference(2,3)
      s = libsbml.ModifierSpeciesReference(2,4)
      s = libsbml.ModifierSpeciesReference(3,1)
      s = libsbml.ModifierSpeciesReference(self.SN21)
      s = libsbml.ModifierSpeciesReference(self.SN22)
      s = libsbml.ModifierSpeciesReference(self.SN23)
      s = libsbml.ModifierSpeciesReference(self.SN24)
      s = libsbml.ModifierSpeciesReference(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    try:
      s = libsbml.ModifierSpeciesReference(1,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    try:
      s = libsbml.ModifierSpeciesReference(1,2)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.ModifierSpeciesReference(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.ModifierSpeciesReference(self.SN11)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.ModifierSpeciesReference(self.SN12)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    try:
      s = libsbml.ModifierSpeciesReference(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_StoichiometryMath_constructor(self):
    s = None
    try:
      s = libsbml.StoichiometryMath(2,1)
      s = libsbml.StoichiometryMath(2,2)
      s = libsbml.StoichiometryMath(2,3)
      s = libsbml.StoichiometryMath(2,4)
      s = libsbml.StoichiometryMath(self.SN21)
      s = libsbml.StoichiometryMath(self.SN22)
      s = libsbml.StoichiometryMath(self.SN23)
      s = libsbml.StoichiometryMath(self.SN24)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    try:
      s = libsbml.StoichiometryMath(1,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    try:
      s = libsbml.StoichiometryMath(1,2)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.StoichiometryMath(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.StoichiometryMath(self.SN11)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.StoichiometryMath(self.SN12)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    try:
      s = libsbml.StoichiometryMath(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_SpeciesReference_constructor(self):
    s = None
    try:
      s = libsbml.SpeciesReference(1,1)
      s = libsbml.SpeciesReference(1,2)
      s = libsbml.SpeciesReference(2,1)
      s = libsbml.SpeciesReference(2,2)
      s = libsbml.SpeciesReference(2,3)
      s = libsbml.SpeciesReference(2,4)
      s = libsbml.SpeciesReference(3,1)
      s = libsbml.SpeciesReference(self.SN11)
      s = libsbml.SpeciesReference(self.SN12)
      s = libsbml.SpeciesReference(self.SN21)
      s = libsbml.SpeciesReference(self.SN22)
      s = libsbml.SpeciesReference(self.SN23)
      s = libsbml.SpeciesReference(self.SN24)
      s = libsbml.SpeciesReference(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    
    try:
      s = libsbml.SpeciesReference(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    
    try:
      s = libsbml.SpeciesReference(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_FunctionDefinition_constructor(self):
    s = None
    try:
      s = libsbml.FunctionDefinition(2,1)
      s = libsbml.FunctionDefinition(2,2)
      s = libsbml.FunctionDefinition(2,3)
      s = libsbml.FunctionDefinition(2,4)
      s = libsbml.FunctionDefinition(3,1)
      s = libsbml.FunctionDefinition(self.SN21)
      s = libsbml.FunctionDefinition(self.SN22)
      s = libsbml.FunctionDefinition(self.SN23)
      s = libsbml.FunctionDefinition(self.SN24)
      s = libsbml.FunctionDefinition(self.SN31)
    except ValueError:
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    try:
      s = libsbml.FunctionDefinition(1,1)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    msg = ""
    try:
      s = libsbml.FunctionDefinition(1,2)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    try:
      s = libsbml.FunctionDefinition(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.FunctionDefinition(self.SN11)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)

    msg = ""
    try:
      s = libsbml.FunctionDefinition(self.SN12)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
    
    try:
      s = libsbml.FunctionDefinition(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_KineticLaw_constructor(self):
    s = None
    try:
      s = libsbml.KineticLaw(1,1)
      s = libsbml.KineticLaw(1,2)
      s = libsbml.KineticLaw(2,1)
      s = libsbml.KineticLaw(2,2)
      s = libsbml.KineticLaw(2,3)
      s = libsbml.KineticLaw(2,4)
      s = libsbml.KineticLaw(3,1)
      s = libsbml.KineticLaw(self.SN11)
      s = libsbml.KineticLaw(self.SN12)
      s = libsbml.KineticLaw(self.SN21)
      s = libsbml.KineticLaw(self.SN22)
      s = libsbml.KineticLaw(self.SN23)
      s = libsbml.KineticLaw(self.SN24)
      s = libsbml.KineticLaw(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    
    try:
      s = libsbml.KineticLaw(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    
    try:
      s = libsbml.KineticLaw(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_Model_constructor(self):
    s = None
    try:
      s = libsbml.Model(1,1)
      s = libsbml.Model(1,2)
      s = libsbml.Model(2,1)
      s = libsbml.Model(2,2)
      s = libsbml.Model(2,3)
      s = libsbml.Model(2,4)
      s = libsbml.Model(3,1)
      s = libsbml.Model(self.SN11)
      s = libsbml.Model(self.SN12)
      s = libsbml.Model(self.SN21)
      s = libsbml.Model(self.SN22)
      s = libsbml.Model(self.SN23)
      s = libsbml.Model(self.SN24)
      s = libsbml.Model(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    
    try:
      s = libsbml.Model(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    
    try:
      s = libsbml.Model(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_Parameter_constructor(self):
    s = None
    try:
      s = libsbml.Parameter(1,1)
      s = libsbml.Parameter(1,2)
      s = libsbml.Parameter(2,1)
      s = libsbml.Parameter(2,2)
      s = libsbml.Parameter(2,3)
      s = libsbml.Parameter(2,4)
      s = libsbml.Parameter(3,1)
      s = libsbml.Parameter(self.SN11)
      s = libsbml.Parameter(self.SN12)
      s = libsbml.Parameter(self.SN21)
      s = libsbml.Parameter(self.SN22)
      s = libsbml.Parameter(self.SN23)
      s = libsbml.Parameter(self.SN24)
      s = libsbml.Parameter(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    
    try:
      s = libsbml.Parameter(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    
    try:
      s = libsbml.Parameter(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_Reaction_constructor(self):
    s = None
    try:
      s = libsbml.Reaction(1,1)
      s = libsbml.Reaction(1,2)
      s = libsbml.Reaction(2,1)
      s = libsbml.Reaction(2,2)
      s = libsbml.Reaction(2,3)
      s = libsbml.Reaction(2,4)
      s = libsbml.Reaction(3,1)
      s = libsbml.Reaction(self.SN11)
      s = libsbml.Reaction(self.SN12)
      s = libsbml.Reaction(self.SN21)
      s = libsbml.Reaction(self.SN22)
      s = libsbml.Reaction(self.SN23)
      s = libsbml.Reaction(self.SN24)
      s = libsbml.Reaction(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    
    try:
      s = libsbml.Reaction(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    
    try:
      s = libsbml.Reaction(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_Unit_constructor(self):
    s = None
    try:
      s = libsbml.Unit(1,1)
      s = libsbml.Unit(1,2)
      s = libsbml.Unit(2,1)
      s = libsbml.Unit(2,2)
      s = libsbml.Unit(2,3)
      s = libsbml.Unit(2,4)
      s = libsbml.Unit(3,1)
      s = libsbml.Unit(self.SN11)
      s = libsbml.Unit(self.SN12)
      s = libsbml.Unit(self.SN21)
      s = libsbml.Unit(self.SN22)
      s = libsbml.Unit(self.SN23)
      s = libsbml.Unit(self.SN24)
      s = libsbml.Unit(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    
    try:
      s = libsbml.Unit(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    
    try:
      s = libsbml.Unit(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_UnitDefinition_constructor(self):
    s = None
    try:
      s = libsbml.UnitDefinition(1,1)
      s = libsbml.UnitDefinition(1,2)
      s = libsbml.UnitDefinition(2,1)
      s = libsbml.UnitDefinition(2,2)
      s = libsbml.UnitDefinition(2,3)
      s = libsbml.UnitDefinition(2,4)
      s = libsbml.UnitDefinition(3,1)
      s = libsbml.UnitDefinition(self.SN11)
      s = libsbml.UnitDefinition(self.SN12)
      s = libsbml.UnitDefinition(self.SN21)
      s = libsbml.UnitDefinition(self.SN22)
      s = libsbml.UnitDefinition(self.SN23)
      s = libsbml.UnitDefinition(self.SN24)
      s = libsbml.UnitDefinition(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""
    
    try:
      s = libsbml.UnitDefinition(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""
    
    try:
      s = libsbml.UnitDefinition(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_AssignmentRule_constructor(self):
    s = None
    try:
      s = libsbml.AssignmentRule(1,1)
      s = libsbml.AssignmentRule(1,2)
      s = libsbml.AssignmentRule(2,1)
      s = libsbml.AssignmentRule(2,2)
      s = libsbml.AssignmentRule(2,3)
      s = libsbml.AssignmentRule(2,4)
      s = libsbml.AssignmentRule(3,1)
      s = libsbml.AssignmentRule(self.SN11)
      s = libsbml.AssignmentRule(self.SN12)
      s = libsbml.AssignmentRule(self.SN21)
      s = libsbml.AssignmentRule(self.SN22)
      s = libsbml.AssignmentRule(self.SN23)
      s = libsbml.AssignmentRule(self.SN24)
      s = libsbml.AssignmentRule(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""

    try:
      s = libsbml.AssignmentRule(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""

    try:
      s = libsbml.AssignmentRule(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_AlgebraicRule_constructor(self):
    s = None
    try:
      s = libsbml.AlgebraicRule(1,1)
      s = libsbml.AlgebraicRule(1,2)
      s = libsbml.AlgebraicRule(2,1)
      s = libsbml.AlgebraicRule(2,2)
      s = libsbml.AlgebraicRule(2,3)
      s = libsbml.AlgebraicRule(2,4)
      s = libsbml.AlgebraicRule(3,1)
      s = libsbml.AlgebraicRule(self.SN11)
      s = libsbml.AlgebraicRule(self.SN12)
      s = libsbml.AlgebraicRule(self.SN21)
      s = libsbml.AlgebraicRule(self.SN22)
      s = libsbml.AlgebraicRule(self.SN23)
      s = libsbml.AlgebraicRule(self.SN24)
      s = libsbml.AlgebraicRule(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""

    try:
      s = libsbml.AlgebraicRule(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""

    try:
      s = libsbml.AlgebraicRule(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

  def test_RateRule_constructor(self):
    s = None
    try:
      s = libsbml.RateRule(1,1)
      s = libsbml.RateRule(1,2)
      s = libsbml.RateRule(2,1)
      s = libsbml.RateRule(2,2)
      s = libsbml.RateRule(2,3)
      s = libsbml.RateRule(2,4)
      s = libsbml.RateRule(3,1)
      s = libsbml.RateRule(self.SN11)
      s = libsbml.RateRule(self.SN12)
      s = libsbml.RateRule(self.SN21)
      s = libsbml.RateRule(self.SN22)
      s = libsbml.RateRule(self.SN23)
      s = libsbml.RateRule(self.SN24)
      s = libsbml.RateRule(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""

    try:
      s = libsbml.RateRule(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""

    try:
      s = libsbml.RateRule(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass
  
  def test_Priority_constructor(self):
    s = None
    try:
      s = libsbml.Priority(3,1)
      s = libsbml.Priority(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""

    try:
      s = libsbml.Priority(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""

    try:
      s = libsbml.Priority(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass
  
  def test_LocalParameter_constructor(self):
    s = None
    try:
      s = libsbml.LocalParameter(3,1)
      s = libsbml.LocalParameter(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""

    try:
      s = libsbml.LocalParameter(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""

    try:
      s = libsbml.LocalParameter(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass
  
  def test_SBMLNamespaces_constructor(self):
    s = None
    try:
      s = libsbml.SBMLNamespaces(3,1)
      s = libsbml.SBMLNamespaces(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)
  pass
  
  def test_SBMLDocument_constructor(self):
    s = None
    try:
      s = libsbml.SBMLDocument(1,1)
      s = libsbml.SBMLDocument(1,2)
      s = libsbml.SBMLDocument(2,1)
      s = libsbml.SBMLDocument(2,2)
      s = libsbml.SBMLDocument(2,3)
      s = libsbml.SBMLDocument(2,4)
      s = libsbml.SBMLDocument(3,1)
      s = libsbml.SBMLDocument(self.SN11)
      s = libsbml.SBMLDocument(self.SN12)
      s = libsbml.SBMLDocument(self.SN21)
      s = libsbml.SBMLDocument(self.SN22)
      s = libsbml.SBMLDocument(self.SN23)
      s = libsbml.SBMLDocument(self.SN24)
      s = libsbml.SBMLDocument(self.SN31)
    except ValueError:
      inst = sys.exc_info()[1]
      s = None
    pass
    self.assert_(s != None)

    msg = ""

    try:
      s = libsbml.SBMLDocument(9,9)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
	
    msg = ""

    try:
      s = libsbml.SBMLDocument(self.SN99)
    except ValueError:
      inst = sys.exc_info()[1]
      msg = inst.args[0]
    pass
    self.assertEqual( msg, self.ERR_MSG)
  pass

def suite():
  suite = unittest.TestSuite()
  suite.addTest(unittest.makeSuite(TestSBMLConstructorException))

  return suite

if __name__ == "__main__":
  if unittest.TextTestRunner(verbosity=1).run(suite()).wasSuccessful() :
    sys.exit(0)
  else:
    sys.exit(1)



