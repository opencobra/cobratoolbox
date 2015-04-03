/**
 * @file    validateSBML.cs
 * @brief   Validates one or more SBML files
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

  public class validateSBML
  {
    private static int  NumInvalid         = 0;
    private static bool enableUnitCCheck  = true;

    public static void Main (string[] args)
    {
      if (args.Length < 1)
      {
        string myname = Path.GetFileName(Environment.GetCommandLineArgs()[0]);
        Console.WriteLine("Usage: {0} [-u] inputFile1 [inputFile2 ...]", myname);
        Console.WriteLine("  -u : skips unit consistency check");
        Environment.Exit(1);
      }
      else if ( args.Length == 1 && args[0] == "-u" )
      {
        string myname = Path.GetFileName(Environment.GetCommandLineArgs()[0]);
        Console.WriteLine("Usage: {0} [-u] inputFile1 [inputFile2 ...]", myname);
        Console.WriteLine("  -u : skips unit consistency check");
        Environment.Exit(1);
      }

      if ( args[0] == "-u" )
      {
        enableUnitCCheck = false;
      }

      foreach ( string inputFile in args )
      {
        if (inputFile == "-u")
        {
          continue;
        }

        Console.WriteLine("---------------------------------------------------------------------------");
        validate(inputFile);
      }

      Console.WriteLine("---------------------------------------------------------------------------");
      Console.WriteLine("Validated {0} files, {1} valid files, {2} invalid files."
                         , args.Length
                         , args.Length - NumInvalid
                         , NumInvalid
                       );
      if ( ! enableUnitCCheck )
      {
        Console.WriteLine("(Unit consistency checks skipped)");
      }

      if (NumInvalid > 0 )
      {
        Environment.Exit(1);
      }
    }

    public static void validate(string inputFile)
    {
      if ( ! File.Exists(inputFile) )
      {
        Console.WriteLine("[Error] {0} : No such file.", inputFile);
        ++NumInvalid;
        return;
      }

      SBMLDocument sbmlDoc;
      long start, stop;
      double timeRead;

      start    = System.DateTime.UtcNow.ToFileTimeUtc();
      sbmlDoc  = libsbml.readSBML(inputFile);
      stop     = System.DateTime.UtcNow.ToFileTimeUtc();
      timeRead = (double)(stop - start)/10000;

      long errors = sbmlDoc.getNumErrors();
      FileInfo fi = new FileInfo(inputFile);

      bool   seriousErrors   = false;
      long   numReadErrors   = 0;
      long   numReadWarnings = 0;
      string errMsgRead      = "";

      if (errors > 0 )
      {
        for (int i = 0; i < errors; i++)
        {
          long severity = sbmlDoc.getError(i).getSeverity();
          if (severity == libsbml.LIBSBML_SEV_ERROR || severity == libsbml.LIBSBML_SEV_FATAL )
          {
            seriousErrors = true;
            ++numReadErrors;
          }
          else {
            ++numReadWarnings;
          }
        }
        
        errMsgRead = sbmlDoc.getErrorLog().toString();
      }

      // If serious errors are encountered while reading an SBML document, it
      // does not make sense to go on and do full consistency checking because
      // the model may be nonsense in the first place.


      long   numCCErrors   = 0;
      long   numCCWarnings = 0;
      string errMsgCC      = "";
      bool   skipCC        = false;
      double timeCC        = 0.0;  

      if (seriousErrors)  
      {
        skipCC = true;
        errMsgRead += "Further consistency checking and validation aborted.";
        ++NumInvalid;
      }
      else
      {
        long failures;

        sbmlDoc.setConsistencyChecks(libsbml.LIBSBML_CAT_UNITS_CONSISTENCY, enableUnitCCheck);
        start    = System.DateTime.UtcNow.ToFileTimeUtc();
        failures = sbmlDoc.checkConsistency();
        stop     = System.DateTime.UtcNow.ToFileTimeUtc();
        timeCC    = (double)(stop - start)/10000;
  
        bool isInvalid = false; 
        if (failures > 0)
        {
          for (int i = 0; i < failures; i++)
          {
            long severity = sbmlDoc.getError(i).getSeverity();
            if (severity == libsbml.LIBSBML_SEV_ERROR || severity == libsbml.LIBSBML_SEV_FATAL )
            {
              ++numCCErrors;
              isInvalid = true;
            }
            else {
              ++numCCWarnings;
            }
          }

          if ( isInvalid)
          {
            ++NumInvalid;
          }

          errMsgCC = sbmlDoc.getErrorLog().toString();
        }
      }

      //
      // print results
      //

      Console.WriteLine("               filename : {0}", inputFile);
      Console.WriteLine("       file size (byte) : {0}", fi.Length);
      Console.WriteLine("         read time (ms) : {0}", timeRead    );
      Console.WriteLine("      c-check time (ms) : {0}", ( skipCC ? "skipped" : timeCC.ToString()       ));
      Console.WriteLine("    validation error(s) : {0}", numReadErrors   + numCCErrors  );
      Console.WriteLine("  (consistency error(s)): {0}", ( skipCC ? "skipped" : numCCErrors.ToString()   ));
      Console.WriteLine("  validation warning(s) : {0}", numReadWarnings + numCCWarnings);
      Console.WriteLine("(consistency warning(s)): {0}", ( skipCC ? "skipped" : numCCWarnings.ToString() ));
      if ( errMsgRead != ""  || errMsgCC != "")
      {
        Console.WriteLine("\n===== validation error/warning messages =====\n"); 
        if ( errMsgRead != "")
        {
          Console.WriteLine(errMsgRead);
        }
        if ( errMsgCC != "")
        {
          Console.WriteLine("*** consistency check ***\n");
          Console.WriteLine(errMsgCC);
        }
      }

    }
  
  }
}
