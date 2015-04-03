/**
 * @file    convertSBML.cpp
 * @brief   Converts SBML documents between levels
 * @author  Michael Hucka
 * @author  Sarah Keating
 * @author  Ben Bornstein
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


using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using libsbmlcs;

public class ConvertSBML
{
    public static int Main(string[] args)
    {

        int latestLevel = (int)SBMLDocument.getDefaultLevel();

        int latestVersion = (int)SBMLDocument.getDefaultVersion();


        if (args.Length != 2)
        {
            Console.Write("Usage: convertSBML input-filename output-filename" + Environment.NewLine
                                      + "This program will attempt to convert a model either to" + Environment.NewLine
                                      + "SBML Level " + latestLevel + " Version " + latestVersion
                                      + " (if the model is not already) or, if " + Environment.NewLine
                                      + "the model is already expressed in Level " + latestLevel
                                      + " Version " + latestVersion + ", this" + Environment.NewLine
                                      + "program will attempt to convert the model to Level 1 Version 2."
                                      + Environment.NewLine);
            return 1;
        }

        string inputFile = args[0];
        string outputFile = args[1];

        SBMLDocument document = libsbml.readSBML(inputFile);

        long errors = document.getNumErrors();

        if (errors > 0)
        {
            Console.Error.Write("Encountered the following SBML errors:" + Environment.NewLine);
            document.printErrors();
            Console.Error.Write("Conversion skipped.  Please correct the problems above first."
            + Environment.NewLine);
            return (int)errors;
        }

        /**
   * If the given model is not already L2v4, assume that the user wants to
   * convert it to the latest release of SBML (which is L2v4 currently).
   * If the model is already L2v4, assume that the user wants to attempt to
   * convert it down to Level 1 (specifically L1v2).
   */


        int olevel = (int)document.getLevel();

        int oversion = (int)document.getVersion();
        bool success;

        if (olevel < latestLevel || oversion < latestVersion)
        {
            Console.Write("Attempting to convert Level " + olevel + " Version " + oversion
                                      + " model to Level " + latestLevel
                                      + " Version " + latestVersion + "." + Environment.NewLine);
            success = document.setLevelAndVersion(latestLevel, latestVersion);
        }
        else
        {
            Console.Write ("Attempting to convert Level " + olevel + " Version " + oversion
                                       + " model to Level 1 Version 2." + Environment.NewLine);
            success = document.setLevelAndVersion(1, 2);
        }

        errors = document.getNumErrors();

        if (!success)
        {
            Console.Error.Write("Unable to perform conversion due to the following:" + Environment.NewLine);
            document.printErrors();
            Console.Write(Environment.NewLine);
            Console.Write("Conversion skipped.  Either libSBML does not (yet)" + Environment.NewLine
                                      + "have the ability to convert this model or (automatic)" + Environment.NewLine
                                      + "conversion is not possible in this case." + Environment.NewLine);

            return (int)errors;
        }
        else if (errors > 0)
        {
            Console.Write("Information may have been lost in conversion; but a valid model ");
            Console.Write("was produced by the conversion.\nThe following information ");
            Console.Write("was provided:\n");
            document.printErrors();
            libsbml.writeSBML(document, outputFile);
        }
        else
        {
            Console.Write("Conversion completed." + Environment.NewLine);
            libsbml.writeSBML(document, outputFile);
        }

        return 0;
    }


}
