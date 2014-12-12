/**
 * @file    printMath.java
 * @brief   Prints Rule, Reaction, and Event formulas in a given SBML Document
 * @author  Nicolas Rodriguez (translated from libSBML C++ examples)
 * @author  Sarah Keating
 * @author  Ben Bornstein
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


import org.sbml.libsbml.ASTNode;
import org.sbml.libsbml.Event;
import org.sbml.libsbml.Delay;
import org.sbml.libsbml.Trigger;
import org.sbml.libsbml.EventAssignment;
import org.sbml.libsbml.FunctionDefinition;
import org.sbml.libsbml.KineticLaw;
import org.sbml.libsbml.Model;
import org.sbml.libsbml.Reaction;
import org.sbml.libsbml.Rule;
import org.sbml.libsbml.SBMLDocument;
import org.sbml.libsbml.SBMLReader;
import org.sbml.libsbml.libsbml;
 

public class printMath
{
  public static void main (String[] args)
  {        
    if (args.length != 1)
    {
      println("Usage: java printMath filename");
      System.exit(1);
    }

    String filename       = args[0];
    SBMLReader reader     = new SBMLReader();
    SBMLDocument document;
    Model        model;
    int          level, version;

    document = reader.readSBML(filename);

    if (document.getNumErrors() > 0)
    {
      document.printErrors();
      println("Printing skipped.  Please correct the above problems first.");
      System.exit(1);
    }

    model = document.getModel();

    if (model == null)
    {
      println("There does not appear to be a model in this file");
      System.exit(0);
    }

    level   = (int) document.getLevel();
    version = (int) document.getVersion();

    println("File: " + filename +
            " (Level " + level + ", version " + version + ")");

    printMath(model);
  }

 
  static void printFunctionDefinition (int n, FunctionDefinition fd)
  {
    if (fd.isSetMath())
    {
      print("FunctionDefinition " + n + ", " + fd.getId() + "(");

      ASTNode math = fd.getMath();

      /* Print function arguments. */
      if (math.getNumChildren() > 1)
      {
        print(" " + math.getLeftChild().getName());
                
        for (int i = 1; i < math.getNumChildren() - 1; ++i)
        {
          print(",  " + math.getChild(i).getName());
        }
      }

      print(") := ");

      /* Print function body. */
      if (math.getNumChildren() == 0)
      {
        println("(no body defined)");
      }
      else
      {
        math = math.getChild(math.getNumChildren() - 1);
        println(libsbml.formulaToString(math));
      }
    }
  }


  static void printRuleMath (int n, Rule r)
  {
    if (r.isSetMath())
    {
      String formula = libsbml.formulaToString(r.getMath());
      String var     = r.getVariable();

      if (r.getVariable().length() > 0)
      println("Rule " + n + ", formula: " + var + " = " + formula);
      else
      println("Rule " + n + ", formula: " + formula + " = 0");
    }
  }
    
    
  static void printReactionMath (int n, Reaction r)
  {
    if (r.isSetKineticLaw())
    {
      KineticLaw kl = r.getKineticLaw();
            
      if ( kl.isSetMath() )
      {
        String formula = libsbml.formulaToString( kl.getMath() );
        println("Reaction " + n + ", formula: " + formula);
      }
    }
  }

    
  static void printEventAssignmentMath (int n, EventAssignment ea)
  {
    if (ea.isSetMath())
    {
      String variable = ea.getVariable();
      String formula  = libsbml.formulaToString( ea.getMath() );
            
      println("  EventAssignment " + n + ", trigger: " + variable + " = " +
              formula);
    }
  }


  static void printEventMath (int n, Event e)
  {
    String formula;


    if (e.isSetDelay())
    {
      formula = libsbml.formulaToString(e.getDelay().getMath());
      println("Event " + n + " delay: " + formula);
    }

    if (e.isSetTrigger())
    {
      formula = libsbml.formulaToString(e.getTrigger().getMath());
      println("Event " + n + " trigger: " + formula);
    }

    for (int i = 0; i < e.getNumEventAssignments(); ++i)
    {
      printEventAssignmentMath(i + 1, e.getEventAssignment(i));
    }

    println("\n");
  }
    
    
  static void printMath (Model model)
  {
    for (int n = 0; n < model.getNumFunctionDefinitions(); ++n)
    {
      printFunctionDefinition(n + 1, model.getFunctionDefinition(n));
      println("");
    }

    for (int n = 0; n < model.getNumRules(); ++n)
    {
      printRuleMath(n + 1, model.getRule(n));
      println("");
    }

    for (int n = 0; n < model.getNumReactions(); ++n)
    {
      printReactionMath(n + 1, model.getReaction(n));
      println("");
    }

    for (int n = 0; n < model.getNumEvents(); ++n)
    {
      printEventMath(n + 1, model.getEvent(n));
    }
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
