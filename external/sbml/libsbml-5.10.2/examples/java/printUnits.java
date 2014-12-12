/**
 * @file    printUnits.java
 * @brief   Prints some unit information about the model
 * @author  Akira Funahashi (translated from libSBML C++ examples (using other Java examples provided by Nicolas Rodriguez))
 * @author  Sarah Keating
 * @author  Michael Hucka
 *
 * <!--------------------------------------------------------------------------
 * This sample program is distributed under a different license than the rest
 * of libSBML.  This program uses the open-source MIT license, as follows:
 *
 * Copyright (c) 2013-2014 by the California Institute of Technology
 * (California, USA), the European Bioinformatics Institute (EMBL-EBI, UK)
 * and the University of Heidelberg (Germany), with support from the National
 * Institutes of Health (USA) under grant R01GM070923.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * Neither the name of the California Institute of Technology (Caltech), nor
 * of the European Bioinformatics Institute (EMBL-EBI), nor of the University
 * of Heidelberg, nor the names of any contributors, may be used to endorse
 * or promote products derived from this software without specific prior
 * written permission.
 * ------------------------------------------------------------------------ -->
 */


import org.sbml.libsbml.libsbml;
import org.sbml.libsbml.Model;
import org.sbml.libsbml.ModelCreator;
import org.sbml.libsbml.ModelHistory;
import org.sbml.libsbml.SBMLWriter;
import org.sbml.libsbml.SBMLDocument;
import org.sbml.libsbml.SBMLReader;
import org.sbml.libsbml.Species; 
import org.sbml.libsbml.Compartment; 
import org.sbml.libsbml.Parameter; 
import org.sbml.libsbml.InitialAssignment; 
import org.sbml.libsbml.Rule; 
import org.sbml.libsbml.Reaction; 
import org.sbml.libsbml.KineticLaw; 
import org.sbml.libsbml.SpeciesReference; 
import org.sbml.libsbml.Event;
import org.sbml.libsbml.EventAssignment; 
import org.sbml.libsbml.UnitDefinition;

public class printUnits
{
  public static void main (String[] args)
  {        
    if (args.length != 1)
    {
      println("\nUsage: java printUnits filename\n");
      System.exit(1);
    }

    String filename       = args[0];
    SBMLReader reader     = new SBMLReader();
    SBMLWriter writer     = new SBMLWriter();

    SBMLDocument d = reader.readSBML(filename);

    if (d.getNumErrors() > 0)
    {
      println("Encountered the following SBML errors:");
      d.printErrors();
      System.exit(1);
    }

    Model model = d.getModel();

    if (model == null)
    {
      println("No model present.");
      System.exit(1);
    }


    for (int n = 0; n < model.getNumCompartments(); n++)
    {
      Compartment c = model.getCompartment(n);

      println("Compartment #" + (n+1) + " --");
      println("  id in model: " + c.getId());

      printUD(c.getDerivedUnitDefinition());
    }
    
    for (int n = 0; n < model.getNumSpecies(); n++)
    {
      Species s = model.getSpecies(n);

      println("Species #" + (n+1) + " --");
      println("  id in model: " + s.getId());

      printUD(s.getDerivedUnitDefinition());
    }

    for (int n = 0; n < model.getNumParameters(); n++)
    {
      Parameter p = model.getParameter(n);

      println("Parameter #" + (n+1) + " --");
      println("  id in model: " + p.getId());

      printUD(p.getDerivedUnitDefinition());
    }

    for (int n = 0; n < model.getNumInitialAssignments(); n++)
    {
      InitialAssignment ia = model.getInitialAssignment(n);

      println("InitialAssignment #" + (n+1) + " --");
      println("  id in model: " + ia.getId());

      printUD(ia.getDerivedUnitDefinition());

      if (ia.containsUndeclaredUnits())
      {
        println(" undeclared parameters?: yes");
      }
      else
      {
        println(" undeclared parameters?: no");
      }

      print("\n");
    }
    
    for (int n = 0; n < model.getNumRules(); n++)
    {
      Rule r = model.getRule(n);

      println("Rule #" + (n+1) + " --");
      println("  id in model: " + r.getId());

      printUD(r.getDerivedUnitDefinition());

      if (r.containsUndeclaredUnits())
      {
        println(" undeclared parameters?: yes");
      }
      else
      {
        println(" undeclared parameters?: no");
      }

      print("\n");
    }

    for (int n = 0; n < model.getNumEvents(); n++)
    {
      Event e = model.getEvent(n);

      println("Event #" + (n+1) + " --");
      println("  id in model: " + e.getId());
      
      if (e.isSetDelay())
      {
        println("Delay:");

        printUD(e.getDelay().getDerivedUnitDefinition());

        if (e.getDelay().containsUndeclaredUnits())
        {
          println(" undeclared parameters?: yes");
        }
        else
        {
          println(" undeclared parameters?: no");
        }

        print("\n");

        for (int nn = 0; nn < e.getNumEventAssignments(); nn++)
        {
          EventAssignment ea = e.getEventAssignment(nn);

          println("EventAssignment #" + (n+1) + " --");
          println("  id in model: " + ea.getId());

          printUD(ea.getDerivedUnitDefinition());

          if (ea.containsUndeclaredUnits())
          {
            println(" undeclared parameters?: yes");
          }
          else
          {
            println(" undeclared parameters?: no");
          }

          print("\n");

        }
      }
    }

    for (int n = 0; n < model.getNumReactions(); n++)
    {
      Reaction rn = model.getReaction(n);

      println("Reaction #" + (n+1) + " --");
      println("  id in model: " + rn.getId());

      if (rn.isSetKineticLaw())
      {
        printUD(rn.getKineticLaw().getDerivedUnitDefinition());

        if (rn.getKineticLaw().containsUndeclaredUnits())
        {
          println(" undeclared parameters?: yes");
        }
        else
        {
          println(" undeclared parameters?: no");
        }
      }
      print("\n");
      for (int nn = 0; nn < rn.getNumReactants(); nn++)
      {
        SpeciesReference sr = rn.getReactant(nn);

        if (sr.isSetStoichiometryMath())
        {
          println("Reactant #" + (n+1) + " --");
          println("  id in model: " + sr.getSpecies());

          printUD(sr.getStoichiometryMath().getDerivedUnitDefinition());

          if (sr.getStoichiometryMath().containsUndeclaredUnits())
          {
            println(" undeclared parameters?: yes");
          }
          else
          {
            println(" undeclared parameters?: no");
          }
       
          print("\n");
        }
      }
      for (int nn = 0; nn < rn.getNumProducts(); nn++)
      {
        SpeciesReference sr = rn.getProduct(nn);

        if (sr.isSetStoichiometryMath())
        {
          println("Product #" + (n+1) + " --");
          println("  id in model: " + sr.getSpecies());

          printUD(sr.getStoichiometryMath().getDerivedUnitDefinition());

          if (sr.getStoichiometryMath().containsUndeclaredUnits())
          {
            println(" undeclared parameters?: yes");
          }
          else
          {
            println(" undeclared parameters?: no");
          }
       
          print("\n");
        }
      }
    }

  }

  static void printUD (UnitDefinition ud)
  {
    for (int p = 0; p < ud.getNumUnits(); p++)
    {
      int kind = ud.getUnit(p).getKind();
      int exp = ud.getUnit(p).getExponent();
      print(libsbml.UnitKind_toString(kind) + "(exponent = " +  exp + ")");

      if ( p + 1 < ud.getNumUnits())
      {
        print(", ");
      }
    }
    print("\n\n");
  }

  static void print (String msg)
  {
    System.out.print(msg);
  }

  static void println (String msg)
  {
    System.out.println(msg);
  }


  /**
   * Loads the SWIG-generated libSBML Java module when this class is
   * loaded, or reports a sensible diagnostic message about why it failed.
   */
  static
  {
    String varname;
    String shlibname;

    if (System.getProperty("os.name").startsWith("Mac OS"))
    {
      varname = "DYLD_LIBRARY_PATH";    // We're on a Mac.
      shlibname = "'libsbmlj.jnilib'";
    }
    else
    {
      varname = "LD_LIBRARY_PATH";      // We're not on a Mac.
      shlibname = "'libsbmlj.so' and/or 'libsbml.so'";
    }

    try
    {
      System.loadLibrary("sbmlj");
      // For extra safety, check that the jar file is in the classpath.
      Class.forName("org.sbml.libsbml.libsbml");
    }
    catch (UnsatisfiedLinkError e)
    {
      System.err.println("Error encountered while attempting to load libSBML:");
      e.printStackTrace();
      System.err.println("Please check the value of your " + varname +
                         " environment variable and/or" +
                         " your 'java.library.path' system property" +
                         " (depending on which one you are using) to" +
                         " make sure it list the directories needed to" +
                         " find the " + shlibname + " library file and the" +
                         " libraries it depends upon (e.g., the XML parser).");
      System.exit(1);
    }
    catch (ClassNotFoundException e)
    {
      System.err.println("Error: unable to load the file 'libsbmlj.jar'." +
                         " It is likely that your -classpath command line " +
                         " setting or your CLASSPATH environment variable " +
                         " do not include the file 'libsbmlj.jar'.");
      System.exit(1);
    }
    catch (SecurityException e)
    {
      System.err.println("Error encountered while attempting to load libSBML:");
      e.printStackTrace();
      System.err.println("Could not load the libSBML library files due to a"+
                         " security exception.\n");
      System.exit(1);
    }
  }
}

