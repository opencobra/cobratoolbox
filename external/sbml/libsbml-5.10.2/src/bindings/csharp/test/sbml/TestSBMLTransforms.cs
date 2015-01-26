/// 
///  @file    TestSBMLTransforms.cs
///  @brief   SBMLTransforms unit tests
///  @author  Frank Bergmann (Csharp conversion)
///  @author  Akiya Jouraku (Csharp conversion)
///  @author  Sarah Keating 
///  
///  This test file was converted from src/sbml/test/TestSBMLTransforms.cpp
///  with the help of conversion sciprt (ctest_converter.pl).
/// 
/// <!---------------------------------------------------------------------------
///  This file is part of libSBML.  Please visit http://sbml.org for more
///  information about SBML, and the latest version of libSBML.
/// 
///  Copyright 2005-2010 California Institute of Technology.
///  Copyright 2002-2005 California Institute of Technology and
///                      Japan Science and Technology Corporation.
///  
///  This library is free software; you can redistribute it and/or modify it
///  under the terms of the GNU Lesser General Public License as published by
///  the Free Software Foundation.  A copy of the license agreement is provided
///  in the file named "LICENSE.txt" included with this software distribution
///  and also available online as http://sbml.org/software/libsbml/license.html
/// --------------------------------------------------------------------------->*/


namespace LibSBMLCSTest {

  using libsbmlcs;

  using  System.IO;

  public class TestSBMLTransforms {

    private const double DBL_EPSILON =  2.2204460492503131e-016;

    public class AssertionError : System.Exception 
    {
      public AssertionError() : base()
      {
        
      }
    }


    static void assertTrue(bool condition)
    {
      if (condition == true)
      {
        return;
      }
      throw new AssertionError();
    }

    static void assertEquals(object a, object b)
    {
      if ( (a == null) && (b == null) )
      {
        return;
      }
      else if ( (a == null) || (b == null) )
      {
        throw new AssertionError();
      }
      else if (a.Equals(b))
      {
        return;
      }
  
      throw new AssertionError();
    }

    static void assertNotEquals(object a, object b)
    {
      if ( (a == null) && (b == null) )
      {
        throw new AssertionError();
      }
      else if ( (a == null) || (b == null) )
      {
        return;
      }
      else if (a.Equals(b))
      {
        throw new AssertionError();
      }
    }

    static void assertEquals(bool a, bool b)
    {
      if ( a == b )
      {
        return;
      }
      throw new AssertionError();
    }

    static void assertNotEquals(bool a, bool b)
    {
      if ( a != b )
      {
        return;
      }
      throw new AssertionError();
    }

    static void assertEquals(int a, int b)
    {
      if ( a == b )
      {
        return;
      }
      throw new AssertionError();
    }

    static void assertNotEquals(int a, int b)
    {
      if ( a != b )
      {
        return;
      }
      throw new AssertionError();
    }

    public bool isnan(double x)
    {
      return (x != x);
    }

    bool equalDouble(double a, double b)
    {
      return (System.Math.Abs(a - b) < System.Math.Sqrt(DBL_EPSILON));
    }


    public void test_SBMLTransforms_replaceFD()
    {
      SBMLReader reader = new SBMLReader();
      SBMLDocument d;
      Model m;
      ASTNode ast;
      FunctionDefinition fd;
      ListOfFunctionDefinitions lofd;
      string filename =  "../../sbml/test/test-data/";
      filename += "multiple-functions.xml";
      d = reader.readSBML(filename);
      if (d == null);
      {
      }
      m = d.getModel();
      assertTrue( m.getNumFunctionDefinitions() == 2 );
      d.expandFunctionDefinitions();
      assertTrue( d.getModel().getNumFunctionDefinitions() == 0 );
      ast = d.getModel().getReaction(0).getKineticLaw().getMath();
      assertTrue((  "S1 * p * compartmentOne / t" == libsbml.formulaToString(ast) ));
      ast = d.getModel().getReaction(1).getKineticLaw().getMath();
      assertTrue((  "S1 * p * compartmentOne / t" == libsbml.formulaToString(ast) ));
      ast = d.getModel().getReaction(2).getKineticLaw().getMath();
      assertTrue((  "S1 * p * compartmentOne / t" == libsbml.formulaToString(ast) ));
    }

    public void test_SBMLTransforms_replaceIA()
    {
      SBMLReader reader = new SBMLReader();
      SBMLDocument d;
      Model m;
      ASTNode ast;
      FunctionDefinition fd;
      ListOfFunctionDefinitions lofd;
      string filename =  "../../sbml/test/test-data/";
      filename += "initialAssignments.xml";
      d = reader.readSBML(filename);
      if (d == null);
      {
      }
      m = d.getModel();
      assertTrue( m.getNumInitialAssignments() == 2 );
      assertEquals( false, (m.getCompartment(0).isSetSize()) );
      assertTrue( m.getParameter(1).getValue() == 2 );
      d.expandInitialAssignments();
      assertTrue( d.getModel().getNumInitialAssignments() == 0 );
      assertEquals( true, d.getModel().getCompartment(0).isSetSize() );
      assertTrue( d.getModel().getCompartment(0).getSize() == 25.0 );
      assertTrue( m.getParameter(1).getValue() == 50 );
    }

    public void test_SBMLTransforms_replaceIA_species()
    {
      SBMLReader reader = new SBMLReader();
      SBMLDocument d;
      Model m;
      ASTNode ast;
      FunctionDefinition fd;
      ListOfFunctionDefinitions lofd;
      string filename =  "../../sbml/test/test-data/";
      filename += "initialAssignments_species.xml";
      d = reader.readSBML(filename);
      if (d == null);
      {
      }
      m = d.getModel();
      assertTrue( m.getNumInitialAssignments() == 3 );
      assertTrue( m.getParameter(1).getValue() == 0.75 );
      assertEquals( false, (m.getParameter(2).isSetValue()) );
      assertEquals( true, m.getSpecies(2).isSetInitialAmount() );
      assertTrue( m.getSpecies(2).getInitialAmount() == 2 );
      d.expandInitialAssignments();
      assertTrue( d.getModel().getNumInitialAssignments() == 0 );
      assertTrue( m.getParameter(1).getValue() == 3 );
      assertEquals( true, m.getParameter(2).isSetValue() );
      assertTrue( m.getParameter(2).getValue() == 0.75 );
      assertEquals( false, (m.getSpecies(2).isSetInitialAmount()) );
      assertTrue( m.getSpecies(2).getInitialConcentration() == 2 );
    }

  }
}
