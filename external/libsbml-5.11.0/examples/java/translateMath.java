/**
 * @file    translateMath.java
 * @brief   Translates infix formulas into MathML and vice-versa
 * @author  Nicolas Rodriguez (translated from libSBML C++ examples)
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


import java.io.IOException;

import org.sbml.libsbml.SBMLDocument;
import org.sbml.libsbml.SBMLReader;
import org.sbml.libsbml.libsbml;


public class translateMath
{
  public static void main (String[] args)
  {
    if (args.length != 0)
    {
      println("Usage: java translateMath\n");
      System.exit(1);
    }

    println("This program translates infix formulas into MathML and" +
            " vice-versa. \nCtrl-D or Ctrl-Z quits and triggers" +
            " translation.\n");
        
    char c;
    int  i = 0;

    String mathStr = new String();

    try
    {
      // Hit CTRL-Z on PC's to send EOF, CTRL-D on Unix
      while (i != -1)
      {
        // Read a character from keyboard.
        i  = System.in.read();

    // System.in.read() returns everything, including things
    // like return, backspace, etc.  Filter those out.
    if (i < 32 || i > 127)
      continue;

        // 1 byte character is returned as an int, so cast it to a char.
        c = (char) i;
        mathStr += c;
      }
    }
    catch (IOException ioe)
    {
      println( "IO error:" + ioe );
    }

    // If the input starts with '<', assume it's XML content.
    String result = (mathStr.charAt(0) == '<') ?
                    translateMathML(mathStr) : translateInfix(mathStr);

    println("Result:\n");
    println(result);
  }


  /**
   * Translates the given infix formula into MathML.
   *
   * @return the MathML as a string.
   */
  static String translateInfix (String formula)
  {
    return libsbml.writeMathMLToString( libsbml.parseFormula(formula) );
  }


  /**
   * Translates the given MathML into an infix formula.  The MathML must
   * contain no leading whitespace, but an XML header is optional.
   *
   * @return the infix formula as a string.
   */
  static String translateMathML (String xml)
  {
    return libsbml.formulaToString( libsbml.readMathMLFromString(xml) );
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
    try
    {
      System.loadLibrary("sbmlj");
      // For extra safety, check that the jar file is in the classpath.
      Class.forName("org.sbml.libsbml.libsbml");
    }
    catch (UnsatisfiedLinkError e)
    {
      System.err.println("Error encountered while attempting to load libSBML:");
      System.err.println("Please check the value of your "
                         + (System.getProperty("os.name").startsWith("Mac OS")
                            ? "DYLD_LIBRARY_PATH" : "LD_LIBRARY_PATH") +
                         " environment variable and/or your" +
                         " 'java.library.path' system property (depending on" +
                         " which one you are using) to make sure it list the" +
                         " directories needed to find the " +
                         System.mapLibraryName("sbmlj") + " library file and" +
                         " libraries it depends upon (e.g., the XML parser).");
      System.exit(1);
    }
    catch (ClassNotFoundException e)
    {
      System.err.println("Error: unable to load the file 'libsbmlj.jar'." +
                         " It is likely that your -classpath command line " +
                         " setting or your CLASSPATH environment variable " +
                         " do not include the file 'libsbmlj.jar'.");
      e.printStackTrace();

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
