/**
 * @file    replaceOneFD.java
 * @brief   replaces a given function definition in a specific part of the model
 * @author  Frank Bergmann
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

import java.lang.*;
import java.io.*;
import org.sbml.libsbml.*;

/**
 * This example is not something you would normally do, what you would want to do is to 
 * call the inline function definition converter. However, if for example you would only 
 * want to expand one function definition, you could use the methods in SBMLTransform 
 * directly. 
 */
class replaceOneFD
{
  public static void main(String[] args)
  {
    if (args.length != 4)
    {
      System.out.println("Usage: replaceOneFD filename functionDefinitionId reactionId outfile");
      System.exit(1);
    }

    String filename = args[0];
    String outFile = args[3];
    String functionDefinitionId = args[1];
    String reactionId = args[2];
    SBMLDocument document = libsbml.readSBML(filename);

    if (document.getNumErrors(libsbml.LIBSBML_SEV_ERROR)  > 0)
    {
      System.out.println("The models contains errors, please correct them before continuing.");
      document.printErrors();
      System.exit(1);
    }

    Model model = document.getModel();
    FunctionDefinition functionDefinition = model.getFunctionDefinition(functionDefinitionId);
    if (functionDefinition == null)
    {
      System.out.println();
      System.out.println("No functiondefinition with the given id can be found.");
      System.exit(1);
    }

    Reaction reaction = model.getReaction(reactionId);
    if (reaction == null)
    {
      System.out.println();
      System.out.println("No reaction with the given id can be found.");
      System.exit(1);
    }

    if (!reaction.isSetKineticLaw() || !reaction.getKineticLaw().isSetMath())
    {
      System.out.println();
      System.out.println("The reaction has no math set. ");
      System.exit(1);
    }

    // Until here it was all setup, all we needed was an ASTNode, in which we wanted to 
    // replace calls to a function definition, with the function definitions content. 
    //
    SBMLTransforms.replaceFD(reaction.getKineticLaw().getMath(), functionDefinition);

    // finally write to file
    libsbml.writeSBML(document, outFile);

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
