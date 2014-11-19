/**
 * @file    convertSBML.java
 * @brief   Converts SBML L1 documents (any version) to L2v3
 * @author  Michael Hucka
 * @author  Nicolas Rodriguez
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

import org.sbml.libsbml.SBMLDocument;
import org.sbml.libsbml.SBMLReader;
import org.sbml.libsbml.libsbml;
 

public class convertSBML
{
  public static void main (String[] args)
  {
    long latestLevel   = SBMLDocument.getDefaultLevel();
    long latestVersion = SBMLDocument.getDefaultVersion();

    if (args.length != 2)
    {
      println("Usage: convertSBML input-filename output-filename\n" +
          "This program will attempt to convert an SBML model either to\n" +
          "Level " + latestLevel + " " + "Version " + latestVersion + " " +
          "(if the model is not already), or if the\n" +
          "model is already at that Level and Version, this program\n" +
          "will attempt to convert it to SBML Level 1 Version 2.");
      System.exit(1);
    }

    String inputFile      = args[0];
    String outputFile     = args[1];
    SBMLDocument document = libsbml.readSBML(inputFile);

    if (document.getNumErrors() > 0)
    {
      document.printErrors(libsbml.cerr);
      println("Conversion skipped.  Please correct the above problems first.");
      System.exit(1);
    }

    /**
     * If the given model is not already L2v4, assume that the user wants
     * to convert it to the latest release of SBML (which is L2v4
     * currently).  If the model is already L2v4, assume that the user
     * wants to attempt to convert it down to Level 1 (specifically L1v2).
     */

    if (document.getLevel() < latestLevel ||
        document.getVersion() < latestVersion)
    {
      document.setLevelAndVersion(latestLevel, latestVersion);
    }
    else
    {
      document.setLevelAndVersion(1, 2);
    }
      
    if (document.getNumErrors() > 0)
    {
      println("Conversion Error(s):");
      document.printErrors(libsbml.cerr);
      println("Conversion skipped.  Either libSBML does not (yet) have\n" +
              "the ability to convert this model, or (automatic) conversion"+
              "\nis not possible.\n");
      System.exit(1);
    }
    else
    {
      libsbml.writeSBML(document, outputFile);
    }
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

