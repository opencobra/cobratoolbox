/**
 * @file    echoSBML.cs
 * @brief   Echos an SBML model.
 * @author  Akiya Jouraku (translated from libSBML C++ examples)
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

namespace LibSBMLCSExample
{
  using System;
  using System.IO;
  using libsbmlcs;

  public class echoSBML
  {
    public static void Main (string[] args)
    {
      if (args.Length != 2)
      {
        string myname = Path.GetFileName(Environment.GetCommandLineArgs()[0]);
        Console.WriteLine("Usage: {0} input-filename output-filename", myname);
        Environment.Exit(1);
      }

      string inputFile  = args[0];
      string outputFile = args[1];

      if ( ! File.Exists(inputFile) )
      {
        Console.WriteLine("[Error] {0} : No such file.", inputFile);
        Environment.Exit(1);        
      }

      SBMLReader   reader  = new SBMLReader();
      SBMLWriter   writer  = new SBMLWriter();
      SBMLDocument sbmlDoc = reader.readSBML(inputFile);

      if ( sbmlDoc.getNumErrors() > 0)
      {
        sbmlDoc.printErrors(); 
        Console.WriteLine("[Error] Cannot read {0}", inputFile);
        Environment.Exit(1);        
      }

      writer.writeSBML(sbmlDoc, outputFile);

      Console.WriteLine("[OK] Echoed {0} to {1}", inputFile, outputFile);
    }
  }

}
