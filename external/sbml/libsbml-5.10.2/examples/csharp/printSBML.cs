/**
 * @file    printModel.cpp
 * @brief   Prints some information about the top-level model
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
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using libsbmlcs;

public class PrintSBML
{
    public static int Main(string[] args)
    {

        if (args.Length != 1)
        {
            Console.Write(Environment.NewLine + "Usage: printSBML filename" + Environment.NewLine + Environment.NewLine);
            return 1;
        }

        string filename = args[0];
        SBMLDocument document = libsbml.readSBML(filename);

        if (document.getNumErrors() > 0)
        {
            Console.WriteLine("Encountered the following SBML errors:" + Environment.NewLine);
            document.printErrors();
            return 1;
        }

        int level = (int)document.getLevel();
        int version = (int)document.getVersion();

        Console.Write(Environment.NewLine
                              + "File: " + filename
                              + " (Level " + level + ", version " + version + ")" + Environment.NewLine);

        Model model = document.getModel();

        if (model == null)
        {
            Console.Write("No model present." + Environment.NewLine);
            return 1;
        }

        Console.Write("               "
                              + (level == 1 ? "name: " : "  id: ")
                              + (model.isSetId() ? model.getId() : "(empty)") + Environment.NewLine);

        if (model.isSetSBOTerm())
            Console.Write("      model sboTerm: " + model.getSBOTerm() + Environment.NewLine);

        Console.Write("functionDefinitions: " + model.getNumFunctionDefinitions() + Environment.NewLine);
        Console.Write("    unitDefinitions: " + model.getNumUnitDefinitions() + Environment.NewLine);
        Console.Write("   compartmentTypes: " + model.getNumCompartmentTypes() + Environment.NewLine);
        Console.Write("        specieTypes: " + model.getNumSpeciesTypes() + Environment.NewLine);
        Console.Write("       compartments: " + model.getNumCompartments() + Environment.NewLine);
        Console.Write("            species: " + model.getNumSpecies() + Environment.NewLine);
        Console.Write("         parameters: " + model.getNumParameters() + Environment.NewLine);
        Console.Write(" initialAssignments: " + model.getNumInitialAssignments() + Environment.NewLine);
        Console.Write("              rules: " + model.getNumRules() + Environment.NewLine);
        Console.Write("        constraints: " + model.getNumConstraints() + Environment.NewLine);
        Console.Write("          reactions: " + model.getNumReactions() + Environment.NewLine);
        Console.Write("             events: " + model.getNumEvents() + Environment.NewLine);
        Console.Write(Environment.NewLine);

        return 0;
    }
}
