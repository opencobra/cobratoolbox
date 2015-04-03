/**
 * @file    printUnits.cpp
 * @brief   Prints some unit information about the model
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


using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using libsbmlcs;

public class PrintUnits
{
    public static int Main(string[] args)
    {
        if (args.Length != 1)
        {
            Console.WriteLine("Usage: printUnits filename");
            return 1;
        }

        string filename = args[0];
        SBMLDocument document = libsbml.readSBML(filename);

        if (document.getNumErrors() > 0)
        {
            Console.Error.WriteLine("Encountered the following SBML errors:");
            document.printErrors();
            return 1;
        }

        Model model = document.getModel();

        if (model == null)
        {
            Console.WriteLine("No model present.");
            return 1;
        }

        int i, j;
        for (i = 0; i < model.getNumSpecies(); i++)
        {
            Species s = model.getSpecies(i);
            Console.WriteLine("Species " + i + ": "
            + UnitDefinition.printUnits(s.getDerivedUnitDefinition()));
        }

        for (i = 0; i < model.getNumCompartments(); i++)
        {
            Compartment c = model.getCompartment(i);
            Console.WriteLine("Compartment " + i + ": "
                                          + UnitDefinition.printUnits(c.getDerivedUnitDefinition()))
            ;
        }

        for (i = 0; i < model.getNumParameters(); i++)
        {
            Parameter p = model.getParameter(i);
            Console.WriteLine("Parameter " + i + ": "
                                          + UnitDefinition.printUnits(p.getDerivedUnitDefinition()))
            ;
        }


        for (i = 0; i < model.getNumInitialAssignments(); i++)
        {
            InitialAssignment ia = model.getInitialAssignment(i);
            Console.WriteLine("InitialAssignment " + i + ": "
                                          + UnitDefinition.printUnits(ia.getDerivedUnitDefinition()));
            Console.WriteLine("        undeclared units: ");
            Console.WriteLine((ia.containsUndeclaredUnits() ? "yes\n" : "no\n"));
        }

        for (i = 0; i < model.getNumEvents(); i++)
        {
            Event e = model.getEvent(i);
            Console.WriteLine("Event " + i + ": ");

            if (e.isSetDelay())
            {
                Console.WriteLine("Delay: "
                                                  + UnitDefinition.printUnits(e.getDelay().getDerivedUnitDefinition()));
                Console.WriteLine("        undeclared units: ");
                Console.WriteLine((e.getDelay().containsUndeclaredUnits() ? "yes\n" : "no\n"));
            }

            for (j = 0; j < e.getNumEventAssignments(); j++)
            {
                EventAssignment ea = e.getEventAssignment(j);
                Console.WriteLine("EventAssignment " + j + ": "
                                                  + UnitDefinition.printUnits(ea.getDerivedUnitDefinition()));
                Console.WriteLine("        undeclared units: ");
                Console.WriteLine((ea.containsUndeclaredUnits() ? "yes\n" : "no\n"));
            }
        }

        for (i = 0; i < model.getNumReactions(); i++)
        {
            Reaction r = model.getReaction(i);

            Console.WriteLine("Reaction " + i + ": ");

            if (r.isSetKineticLaw())
            {
                Console.WriteLine("Kinetic Law: "
                                                  + UnitDefinition.printUnits(r.getKineticLaw().getDerivedUnitDefinition()));
                Console.WriteLine("        undeclared units: ");
                Console.WriteLine((r.getKineticLaw().containsUndeclaredUnits() ? "yes\n" : "no\n"));
            }

            for (j = 0; j < r.getNumReactants(); j++)
            {
                SpeciesReference sr = r.getReactant(j);

                if (sr.isSetStoichiometryMath())
                {
                    Console.WriteLine("Reactant stoichiometryMath" + j + ": "
                                                          + UnitDefinition.printUnits(sr.getStoichiometryMath().getDerivedUnitDefinition()));
                    Console.WriteLine("        undeclared units: ");
                    Console.WriteLine((sr.getStoichiometryMath().containsUndeclaredUnits() ? "yes\n" : "no\n"));
                }
            }

            for (j = 0; j < r.getNumProducts(); j++)
            {
                SpeciesReference sr = r.getProduct(j);

                if (sr.isSetStoichiometryMath())
                {
                    Console.WriteLine("Product stoichiometryMath" + j + ": "
                                                          + UnitDefinition.printUnits(sr.getStoichiometryMath().getDerivedUnitDefinition()));
                    Console.WriteLine("        undeclared units: ");
                    Console.WriteLine((sr.getStoichiometryMath().containsUndeclaredUnits() ? "yes\n" : "no\n"));
                }
            }
        }

        for (i = 0; i < model.getNumRules(); i++)
        {
            Rule r = model.getRule(i);
            Console.WriteLine("Rule " + i + ": "
                                          + UnitDefinition.printUnits(r.getDerivedUnitDefinition()));
            Console.WriteLine("        undeclared units: ");
            Console.WriteLine((r.containsUndeclaredUnits() ? "yes\n" : "no\n"));
        }

        return 0;
    }
}
