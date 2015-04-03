#
# @file    TestSBMLConstructorException.rb
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
require 'test/unit'
require 'libSBML'

class TestSBMLConstructorException < Test::Unit::TestCase

  @@ERR_MSG = "Level/version/namespaces combination is invalid"

  @@SN11 = LibSBML::SBMLNamespaces.new(1,1)
  @@SN12 = LibSBML::SBMLNamespaces.new(1,2)
  @@SN21 = LibSBML::SBMLNamespaces.new(2,1)
  @@SN22 = LibSBML::SBMLNamespaces.new(2,2)
  @@SN23 = LibSBML::SBMLNamespaces.new(2,3)
  @@SN24 = LibSBML::SBMLNamespaces.new(2,4)
  @@SN31 = LibSBML::SBMLNamespaces.new(3,1)
  @@SN99 = LibSBML::SBMLNamespaces.new(9,9)

  def test_CompartmentType_constructor
    s = nil;
    begin
      s = LibSBML::CompartmentType.new(2,2)
      s = LibSBML::CompartmentType.new(2,3)
      s = LibSBML::CompartmentType.new(2,4)
      s = LibSBML::CompartmentType.new(@@SN22)
      s = LibSBML::CompartmentType.new(@@SN23)
      s = LibSBML::CompartmentType.new(@@SN24)
    rescue SBMLConstructorException 
      s = nil
    end
    assert(s != nil)

    msg = ""
    begin
      s = LibSBML::CompartmentType.new(1,1)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s,  @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::CompartmentType.new(1,2)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s,  @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::CompartmentType.new(2,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::CompartmentType.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
    msg = ""
    begin
      s = LibSBML::CompartmentType.new(@@SN11)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s,  @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::CompartmentType.new(@@SN12)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s,  @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::CompartmentType.new(@@SN21)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::CompartmentType.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_Compartment_constructor
    s = nil
    begin
      s = LibSBML::Compartment.new(1,1)
      s = LibSBML::Compartment.new(1,2)
      s = LibSBML::Compartment.new(2,1)
      s = LibSBML::Compartment.new(2,2)
      s = LibSBML::Compartment.new(2,3)
      s = LibSBML::Compartment.new(2,4)
      s = LibSBML::Compartment.new(3,1)
      s = LibSBML::Compartment.new(@@SN11)
      s = LibSBML::Compartment.new(@@SN12)
      s = LibSBML::Compartment.new(@@SN21)
      s = LibSBML::Compartment.new(@@SN22)
      s = LibSBML::Compartment.new(@@SN23)
      s = LibSBML::Compartment.new(@@SN24)
      s = LibSBML::Compartment.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    
    begin
      s = LibSBML::Compartment.new(9,9)
    rescue SBMLConstructorException 
      msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
	msg = ""
    
    begin
      s = LibSBML::Compartment.new(@@SN99)
    rescue SBMLConstructorException 
      msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_Constraint_constructor
    s = nil
    begin
      s = LibSBML::Constraint.new(2,2)
      s = LibSBML::Constraint.new(2,3)
      s = LibSBML::Constraint.new(2,4)
      s = LibSBML::Constraint.new(3,1)
      s = LibSBML::Constraint.new(@@SN22)
      s = LibSBML::Constraint.new(@@SN23)
      s = LibSBML::Constraint.new(@@SN24)
      s = LibSBML::Constraint.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    begin
      s = LibSBML::Constraint.new(1,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    msg = ""
    begin
      s = LibSBML::Constraint.new(1,2)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::Constraint.new(2,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

	msg = ""
    begin
      s = LibSBML::Constraint.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
    msg = ""
    begin
      s = LibSBML::Constraint.new(@@SN11)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::Constraint.new(@@SN12)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::Constraint.new(@@SN21)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::Constraint.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_InitialAssignment_constructor
    s = nil
    begin
      s = LibSBML::InitialAssignment.new(2,2)
      s = LibSBML::InitialAssignment.new(2,3)
      s = LibSBML::InitialAssignment.new(2,4)
      s = LibSBML::InitialAssignment.new(3,1)
      s = LibSBML::InitialAssignment.new(@@SN22)
      s = LibSBML::InitialAssignment.new(@@SN23)
      s = LibSBML::InitialAssignment.new(@@SN24)
      s = LibSBML::InitialAssignment.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    begin
      s = LibSBML::InitialAssignment.new(1,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    msg = ""
    begin
      s = LibSBML::InitialAssignment.new(1,2)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::InitialAssignment.new(2,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::InitialAssignment.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
    msg = ""
    begin
      s = LibSBML::InitialAssignment.new(@@SN11)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::InitialAssignment.new(@@SN12)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::InitialAssignment.new(@@SN21)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::InitialAssignment.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_Species_constructor
    s = nil
    begin
      s = LibSBML::Species.new(1,1)
      s = LibSBML::Species.new(1,2)
      s = LibSBML::Species.new(2,1)
      s = LibSBML::Species.new(2,2)
      s = LibSBML::Species.new(2,3)
      s = LibSBML::Species.new(2,4)
      s = LibSBML::Species.new(3,1)
      s = LibSBML::Species.new(@@SN11)
      s = LibSBML::Species.new(@@SN12)
      s = LibSBML::Species.new(@@SN21)
      s = LibSBML::Species.new(@@SN22)
      s = LibSBML::Species.new(@@SN23)
      s = LibSBML::Species.new(@@SN24)
      s = LibSBML::Species.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    
    begin
      s = LibSBML::Species.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
	msg = ""
    
    begin
      s = LibSBML::Species.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
  end

  def test_SpeciesType_constructor
    s = nil
    begin
      s = LibSBML::SpeciesType.new(2,2)
      s = LibSBML::SpeciesType.new(2,3)
      s = LibSBML::SpeciesType.new(2,4)
      s = LibSBML::SpeciesType.new(@@SN22)
      s = LibSBML::SpeciesType.new(@@SN23)
      s = LibSBML::SpeciesType.new(@@SN24)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""

    begin
      s = LibSBML::SpeciesType.new(1,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    msg = ""
    begin
      s = LibSBML::SpeciesType.new(1,2)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::SpeciesType.new(2,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

	msg = ""
    begin
      s = LibSBML::SpeciesType.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    begin
      s = LibSBML::SpeciesType.new(@@SN11)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::SpeciesType.new(@@SN12)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::SpeciesType.new(@@SN21)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::SpeciesType.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_Delay_constructor
    s = nil
    begin
      s = LibSBML::Delay.new(2,1)
      s = LibSBML::Delay.new(2,2)
      s = LibSBML::Delay.new(2,3)
      s = LibSBML::Delay.new(2,4)
      s = LibSBML::Delay.new(3,1)
      s = LibSBML::Delay.new(@@SN21)
      s = LibSBML::Delay.new(@@SN22)
      s = LibSBML::Delay.new(@@SN23)
      s = LibSBML::Delay.new(@@SN24)
      s = LibSBML::Delay.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    begin
      s = LibSBML::Delay.new(1,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    msg = ""
    begin
      s = LibSBML::Delay.new(1,2)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::Delay.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::Delay.new(@@SN11)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::Delay.new(@@SN12)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    begin
      s = LibSBML::Delay.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_Trigger_constructor
    s = nil
    begin
      s = LibSBML::Trigger.new(2,1)
      s = LibSBML::Trigger.new(2,2)
      s = LibSBML::Trigger.new(2,3)
      s = LibSBML::Trigger.new(2,4)
      s = LibSBML::Trigger.new(3,1)
      s = LibSBML::Trigger.new(@@SN21)
      s = LibSBML::Trigger.new(@@SN22)
      s = LibSBML::Trigger.new(@@SN23)
      s = LibSBML::Trigger.new(@@SN24)
      s = LibSBML::Trigger.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    begin
      s = LibSBML::Trigger.new(1,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    msg = ""
    begin
      s = LibSBML::Trigger.new(1,2)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

	msg = ""
    begin
      s = LibSBML::Trigger.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::Trigger.new(@@SN11)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::Trigger.new(@@SN12)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    begin
      s = LibSBML::Trigger.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_Event_constructor
    s = nil
    begin
      s = LibSBML::Event.new(2,1)
      s = LibSBML::Event.new(2,2)
      s = LibSBML::Event.new(2,3)
      s = LibSBML::Event.new(2,4)
      s = LibSBML::Event.new(3,1)
      s = LibSBML::Event.new(@@SN21)
      s = LibSBML::Event.new(@@SN22)
      s = LibSBML::Event.new(@@SN23)
      s = LibSBML::Event.new(@@SN24)
      s = LibSBML::Event.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""

    begin
      s = LibSBML::Event.new(1,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    msg = ""
    begin
      s = LibSBML::Event.new(1,2)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::Event.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    begin
      s = LibSBML::Event.new(@SN11)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::Event.new(@SN12)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    begin
      s = LibSBML::Event.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_EventAssignment_constructor
    s = nil
    begin
      s = LibSBML::EventAssignment.new(2,1)
      s = LibSBML::EventAssignment.new(2,2)
      s = LibSBML::EventAssignment.new(2,3)
      s = LibSBML::EventAssignment.new(2,4)
      s = LibSBML::EventAssignment.new(3,1)
      s = LibSBML::EventAssignment.new(@@SN21)
      s = LibSBML::EventAssignment.new(@@SN22)
      s = LibSBML::EventAssignment.new(@@SN23)
      s = LibSBML::EventAssignment.new(@@SN24)
      s = LibSBML::EventAssignment.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    begin
      s = LibSBML::EventAssignment.new(1,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    msg = ""
    begin
      s = LibSBML::EventAssignment.new(1,2)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::EventAssignment.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::EventAssignment.new(@@SN11)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::EventAssignment.new(@@SN12)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    begin
      s = LibSBML::EventAssignment.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_ModifierSpeciesReference_constructor
    s = nil
    begin
      s = LibSBML::ModifierSpeciesReference.new(2,1)
      s = LibSBML::ModifierSpeciesReference.new(2,2)
      s = LibSBML::ModifierSpeciesReference.new(2,3)
      s = LibSBML::ModifierSpeciesReference.new(2,4)
      s = LibSBML::ModifierSpeciesReference.new(3,1)
      s = LibSBML::ModifierSpeciesReference.new(@@SN21)
      s = LibSBML::ModifierSpeciesReference.new(@@SN22)
      s = LibSBML::ModifierSpeciesReference.new(@@SN23)
      s = LibSBML::ModifierSpeciesReference.new(@@SN24)
      s = LibSBML::ModifierSpeciesReference.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    begin
      s = LibSBML::ModifierSpeciesReference.new(1,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    msg = ""
    begin
      s = LibSBML::ModifierSpeciesReference.new(1,2)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::ModifierSpeciesReference.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::ModifierSpeciesReference.new(@@SN11)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::ModifierSpeciesReference.new(@@SN12)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    begin
      s = LibSBML::ModifierSpeciesReference.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_StoichiometryMath_constructor
    s = nil
    begin
      s = LibSBML::StoichiometryMath.new(2,1)
      s = LibSBML::StoichiometryMath.new(2,2)
      s = LibSBML::StoichiometryMath.new(2,3)
      s = LibSBML::StoichiometryMath.new(2,4)
      s = LibSBML::StoichiometryMath.new(@@SN21)
      s = LibSBML::StoichiometryMath.new(@@SN22)
      s = LibSBML::StoichiometryMath.new(@@SN23)
      s = LibSBML::StoichiometryMath.new(@@SN24)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    begin
      s = LibSBML::StoichiometryMath.new(1,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    msg = ""
    begin
      s = LibSBML::StoichiometryMath.new(1,2)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::StoichiometryMath.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    msg = ""
    begin
      s = LibSBML::StoichiometryMath.new(@@SN11)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::StoichiometryMath.new(@@SN12)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    msg = ""
    begin
      s = LibSBML::StoichiometryMath.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_SpeciesReference_constructor
    s = nil
    begin
      s = LibSBML::SpeciesReference.new(1,1)
      s = LibSBML::SpeciesReference.new(1,2)
      s = LibSBML::SpeciesReference.new(2,1)
      s = LibSBML::SpeciesReference.new(2,2)
      s = LibSBML::SpeciesReference.new(2,3)
      s = LibSBML::SpeciesReference.new(2,4)
      s = LibSBML::SpeciesReference.new(3,1)
      s = LibSBML::SpeciesReference.new(@@SN11)
      s = LibSBML::SpeciesReference.new(@@SN12)
      s = LibSBML::SpeciesReference.new(@@SN21)
      s = LibSBML::SpeciesReference.new(@@SN22)
      s = LibSBML::SpeciesReference.new(@@SN23)
      s = LibSBML::SpeciesReference.new(@@SN24)
      s = LibSBML::SpeciesReference.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    
    begin
      s = LibSBML::SpeciesReference.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    
    begin
      s = LibSBML::SpeciesReference.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_FunctionDefinition_constructor
    s = nil
    begin
      s = LibSBML::FunctionDefinition.new(2,1)
      s = LibSBML::FunctionDefinition.new(2,2)
      s = LibSBML::FunctionDefinition.new(2,3)
      s = LibSBML::FunctionDefinition.new(2,4)
      s = LibSBML::FunctionDefinition.new(3,1)
      s = LibSBML::FunctionDefinition.new(@@SN21)
      s = LibSBML::FunctionDefinition.new(@@SN22)
      s = LibSBML::FunctionDefinition.new(@@SN23)
      s = LibSBML::FunctionDefinition.new(@@SN24)
      s = LibSBML::FunctionDefinition.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    begin
      s = LibSBML::FunctionDefinition.new(1,1)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    msg = ""
    begin
      s = LibSBML::FunctionDefinition.new(1,2)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    msg = ""
    begin
      s = LibSBML::FunctionDefinition.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::FunctionDefinition.new(@@SN11)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

    msg = ""
    begin
      s = LibSBML::FunctionDefinition.new(@@SN12)
    rescue SBMLConstructorException
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    
    begin
      s = LibSBML::FunctionDefinition.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_KineticLaw_constructor
    s = nil
    begin
      s = LibSBML::KineticLaw.new(1,1)
      s = LibSBML::KineticLaw.new(1,2)
      s = LibSBML::KineticLaw.new(2,1)
      s = LibSBML::KineticLaw.new(2,2)
      s = LibSBML::KineticLaw.new(2,3)
      s = LibSBML::KineticLaw.new(2,4)
      s = LibSBML::KineticLaw.new(3,1)
      s = LibSBML::KineticLaw.new(@@SN11)
      s = LibSBML::KineticLaw.new(@@SN12)
      s = LibSBML::KineticLaw.new(@@SN21)
      s = LibSBML::KineticLaw.new(@@SN22)
      s = LibSBML::KineticLaw.new(@@SN23)
      s = LibSBML::KineticLaw.new(@@SN24)
      s = LibSBML::KineticLaw.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    
    begin
      s = LibSBML::KineticLaw.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    msg = ""
    
    begin
      s = LibSBML::KineticLaw.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_Model_constructor
    s = nil
    begin
      s = LibSBML::Model.new(1,1)
      s = LibSBML::Model.new(1,2)
      s = LibSBML::Model.new(2,1)
      s = LibSBML::Model.new(2,2)
      s = LibSBML::Model.new(2,3)
      s = LibSBML::Model.new(2,4)
      s = LibSBML::Model.new(3,1)
      s = LibSBML::Model.new(@@SN11)
      s = LibSBML::Model.new(@@SN12)
      s = LibSBML::Model.new(@@SN21)
      s = LibSBML::Model.new(@@SN22)
      s = LibSBML::Model.new(@@SN23)
      s = LibSBML::Model.new(@@SN24)
      s = LibSBML::Model.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    
    begin
      s = LibSBML::Model.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    msg = ""
    
    begin
      s = LibSBML::Model.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_Parameter_constructor
    s = nil
    begin
      s = LibSBML::Parameter.new(1,1)
      s = LibSBML::Parameter.new(1,2)
      s = LibSBML::Parameter.new(2,1)
      s = LibSBML::Parameter.new(2,2)
      s = LibSBML::Parameter.new(2,3)
      s = LibSBML::Parameter.new(2,4)
      s = LibSBML::Parameter.new(3,1)
      s = LibSBML::Parameter.new(@@SN11)
      s = LibSBML::Parameter.new(@@SN12)
      s = LibSBML::Parameter.new(@@SN21)
      s = LibSBML::Parameter.new(@@SN22)
      s = LibSBML::Parameter.new(@@SN23)
      s = LibSBML::Parameter.new(@@SN24)
      s = LibSBML::Parameter.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    
    begin
      s = LibSBML::Parameter.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	    msg = ""
    
    begin
      s = LibSBML::Parameter.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_Reaction_constructor
    s = nil
    begin
      s = LibSBML::Reaction.new(1,1)
      s = LibSBML::Reaction.new(1,2)
      s = LibSBML::Reaction.new(2,1)
      s = LibSBML::Reaction.new(2,2)
      s = LibSBML::Reaction.new(2,3)
      s = LibSBML::Reaction.new(2,4)
      s = LibSBML::Reaction.new(3,1)
      s = LibSBML::Reaction.new(@@SN11)
      s = LibSBML::Reaction.new(@@SN12)
      s = LibSBML::Reaction.new(@@SN21)
      s = LibSBML::Reaction.new(@@SN22)
      s = LibSBML::Reaction.new(@@SN23)
      s = LibSBML::Reaction.new(@@SN24)
      s = LibSBML::Reaction.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    
    begin
      s = LibSBML::Reaction.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
	msg = ""
    
    begin
      s = LibSBML::Reaction.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG

  end

  def test_Unit_constructor
    s = nil
    begin
      s = LibSBML::Unit.new(1,1)
      s = LibSBML::Unit.new(1,2)
      s = LibSBML::Unit.new(2,1)
      s = LibSBML::Unit.new(2,2)
      s = LibSBML::Unit.new(2,3)
      s = LibSBML::Unit.new(2,4)
      s = LibSBML::Unit.new(3,1)
      s = LibSBML::Unit.new(@@SN11)
      s = LibSBML::Unit.new(@@SN12)
      s = LibSBML::Unit.new(@@SN21)
      s = LibSBML::Unit.new(@@SN22)
      s = LibSBML::Unit.new(@@SN23)
      s = LibSBML::Unit.new(@@SN24)
      s = LibSBML::Unit.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    
    begin
      s = LibSBML::Unit.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    msg = ""
    
    begin
      s = LibSBML::Unit.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_UnitDefinition_constructor
    s = nil
    begin
      s = LibSBML::UnitDefinition.new(1,1)
      s = LibSBML::UnitDefinition.new(1,2)
      s = LibSBML::UnitDefinition.new(2,1)
      s = LibSBML::UnitDefinition.new(2,2)
      s = LibSBML::UnitDefinition.new(2,3)
      s = LibSBML::UnitDefinition.new(2,4)
      s = LibSBML::UnitDefinition.new(3,1)
      s = LibSBML::UnitDefinition.new(@@SN11)
      s = LibSBML::UnitDefinition.new(@@SN12)
      s = LibSBML::UnitDefinition.new(@@SN21)
      s = LibSBML::UnitDefinition.new(@@SN22)
      s = LibSBML::UnitDefinition.new(@@SN23)
      s = LibSBML::UnitDefinition.new(@@SN24)
      s = LibSBML::UnitDefinition.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""
    
    begin
      s = LibSBML::UnitDefinition.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
    msg = ""
    
    begin
      s = LibSBML::UnitDefinition.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_AssignmentRule_constructor
    s = nil
    begin
      s = LibSBML::AssignmentRule.new(1,1)
      s = LibSBML::AssignmentRule.new(1,2)
      s = LibSBML::AssignmentRule.new(2,1)
      s = LibSBML::AssignmentRule.new(2,2)
      s = LibSBML::AssignmentRule.new(2,3)
      s = LibSBML::AssignmentRule.new(2,4)
      s = LibSBML::AssignmentRule.new(3,1)
      s = LibSBML::AssignmentRule.new(@@SN11)
      s = LibSBML::AssignmentRule.new(@@SN12)
      s = LibSBML::AssignmentRule.new(@@SN21)
      s = LibSBML::AssignmentRule.new(@@SN22)
      s = LibSBML::AssignmentRule.new(@@SN23)
      s = LibSBML::AssignmentRule.new(@@SN24)
      s = LibSBML::AssignmentRule.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""

    begin
      s = LibSBML::AssignmentRule.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
    msg = ""

    begin
      s = LibSBML::AssignmentRule.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_AlgebraicRule_constructor
    s = nil
    begin
      s = LibSBML::AlgebraicRule.new(1,1)
      s = LibSBML::AlgebraicRule.new(1,2)
      s = LibSBML::AlgebraicRule.new(2,1)
      s = LibSBML::AlgebraicRule.new(2,2)
      s = LibSBML::AlgebraicRule.new(2,3)
      s = LibSBML::AlgebraicRule.new(2,4)
      s = LibSBML::AlgebraicRule.new(3,1)
      s = LibSBML::AlgebraicRule.new(@@SN11)
      s = LibSBML::AlgebraicRule.new(@@SN12)
      s = LibSBML::AlgebraicRule.new(@@SN21)
      s = LibSBML::AlgebraicRule.new(@@SN22)
      s = LibSBML::AlgebraicRule.new(@@SN23)
      s = LibSBML::AlgebraicRule.new(@@SN24)
      s = LibSBML::AlgebraicRule.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""

    begin
      s = LibSBML::AlgebraicRule.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
	msg = ""

    begin
      s = LibSBML::AlgebraicRule.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_RateRule_constructor
    s = nil
    begin
      s = LibSBML::RateRule.new(1,1)
      s = LibSBML::RateRule.new(1,2)
      s = LibSBML::RateRule.new(2,1)
      s = LibSBML::RateRule.new(2,2)
      s = LibSBML::RateRule.new(2,3)
      s = LibSBML::RateRule.new(2,4)
      s = LibSBML::RateRule.new(3,1)
      s = LibSBML::RateRule.new(@@SN11)
      s = LibSBML::RateRule.new(@@SN12)
      s = LibSBML::RateRule.new(@@SN21)
      s = LibSBML::RateRule.new(@@SN22)
      s = LibSBML::RateRule.new(@@SN23)
      s = LibSBML::RateRule.new(@@SN24)
      s = LibSBML::RateRule.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""

    begin
      s = LibSBML::RateRule.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
	msg = ""

    begin
      s = LibSBML::RateRule.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end

  def test_Priority_constructor
    s = nil
    begin
      s = LibSBML::Priority.new(3,1)
      s = LibSBML::Priority.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""

    begin
      s = LibSBML::Priority.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
	msg = ""

    begin
      s = LibSBML::Priority.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end
  
  def test_LocalParameter_constructor
    s = nil
    begin
      s = LibSBML::LocalParameter.new(3,1)
      s = LibSBML::LocalParameter.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""

    begin
      s = LibSBML::LocalParameter.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
	msg = ""

    begin
      s = LibSBML::LocalParameter.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end
  
  def test_SBMLNamespaces_constructor
    s = nil
    begin
      s = LibSBML::SBMLNamespaces.new(3,1)
      s = LibSBML::SBMLNamespaces.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)
  end
  
  def test_SBMLDocument_constructor
    s = nil
    begin
      s = LibSBML::SBMLDocument.new(1,1)
      s = LibSBML::SBMLDocument.new(1,2)
      s = LibSBML::SBMLDocument.new(2,1)
      s = LibSBML::SBMLDocument.new(2,2)
      s = LibSBML::SBMLDocument.new(2,3)
      s = LibSBML::SBMLDocument.new(2,4)
      s = LibSBML::SBMLDocument.new(3,1)
      s = LibSBML::SBMLDocument.new(@@SN11)
      s = LibSBML::SBMLDocument.new(@@SN12)
      s = LibSBML::SBMLDocument.new(@@SN21)
      s = LibSBML::SBMLDocument.new(@@SN22)
      s = LibSBML::SBMLDocument.new(@@SN23)
      s = LibSBML::SBMLDocument.new(@@SN24)
      s = LibSBML::SBMLDocument.new(@@SN31)
    rescue SBMLConstructorException 
       s = nil
    end
    assert(s != nil)

    msg = ""

    begin
      s = LibSBML::SBMLDocument.new(9,9)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
	
	msg = ""

    begin
      s = LibSBML::SBMLDocument.new(@@SN99)
    rescue SBMLConstructorException 
       msg = $!
    end
    assert_equal msg.to_s, @@ERR_MSG
  end
end


