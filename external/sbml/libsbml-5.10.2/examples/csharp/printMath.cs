/**
 * @file    printMath.cpp
 * @brief   Prints Rule, Reaction, and Event formulas in a given SBML Document
 * @author  Ben Bornstein
 * @author  Sarah Keating
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


public class PrintMath
{

    private static void
    printFunctionDefinition(int n, FunctionDefinition fd)
    {
        ASTNode math;
        string formula;


        if (fd.isSetMath())
        {
            Console.Write("FunctionDefinition " + n + ", " + fd.getId());

            math = fd.getMath();

            /* Print function arguments. */
            if (math.getNumChildren() > 1)
            {
                Console.Write("(" + (math.getLeftChild()).getName());

                for (n = 1; n < math.getNumChildren() - 1; ++n)
                {
                    Console.Write(", " + (math.getChild(n)).getName());
                }
            }

            Console.Write(") := ");

            /* Print function body. */
            if (math.getNumChildren() == 0)
            {
                Console.Write("(no body defined)");
            }
            else
            {
                math = math.getChild(math.getNumChildren() - 1);
                formula = libsbml.formulaToString(math);
                Console.Write(formula + Environment.NewLine);

            }
        }
    }


    private static void
    printRuleMath(int n, Rule r)
    {
        string formula;


        if (r.isSetMath())
        {
            formula = libsbml.formulaToString(r.getMath());

            if (r.getVariable().Length > 0)
            {
                Console.Write("Rule " + n + ", formula: "
                                 + r.getVariable() + " = " + formula + Environment.NewLine);
            }
            else
            {
                Console.Write("Rule " + n + ", formula: "
                                 + formula + " = 0" + Environment.NewLine);
            }

        }
    }


    private static void
    printReactionMath(int n, Reaction r)
    {
        string formula;
        KineticLaw kl;


        if (r.isSetKineticLaw())
        {
            kl = r.getKineticLaw();

            if (kl.isSetMath())
            {
                formula = libsbml.formulaToString(kl.getMath());
                Console.Write("Reaction " + n + ", formula: " + formula + Environment.NewLine);
            }
        }
    }


    private static void
    printEventAssignmentMath(int n, EventAssignment ea)
    {
        string variable;
        string formula;


        if (ea.isSetMath())
        {
            variable = ea.getVariable();
            formula = libsbml.formulaToString(ea.getMath());

            Console.Write("  EventAssignment " + n
                                  + ", trigger: " + variable + " = " + formula + Environment.NewLine);

        }
    }


    private static void
    printEventMath(int n, Event e)
    {
        string formula;
        int i;


        if (e.isSetDelay())
        {
            formula = libsbml.formulaToString(e.getDelay().getMath());
            Console.Write("Event " + n + " delay: " + formula + Environment.NewLine);
        }

        if (e.isSetTrigger())
        {
            formula = libsbml.formulaToString(e.getTrigger().getMath());
            Console.Write("Event " + n + " trigger: " + formula + Environment.NewLine);
        }

        for (i = 0; i < e.getNumEventAssignments(); ++i)
        {
            printEventAssignmentMath(i + 1, e.getEventAssignment(i));
        }

        Console.WriteLine();
    }


    private static void
    printMath(Model m)
    {
        int n;


        for (n = 0; n < m.getNumFunctionDefinitions(); ++n)
        {
            printFunctionDefinition(n + 1, m.getFunctionDefinition(n));
        }

        for (n = 0; n < m.getNumRules(); ++n)
        {
            printRuleMath(n + 1, m.getRule(n));
        }

        Console.WriteLine();

        for (n = 0; n < m.getNumReactions(); ++n)
        {
            printReactionMath(n + 1, m.getReaction(n));
        }

        Console.WriteLine();

        for (n = 0; n < m.getNumEvents(); ++n)
        {
            printEventMath(n + 1, m.getEvent(n));
        }
    }


    public static int Main(string[] args)
    {

        if (args.Length != 1)
        {
            Console.Write(Environment.NewLine + "Usage: printMath filename" + Environment.NewLine + Environment.NewLine);
            return 1;
        }

        string filename = args[0];
        SBMLDocument document = libsbml.readSBML(filename);

        if (document.getNumErrors() > 0)
        {
            Console.Error.Write("Encountered the following SBML errors:" + Environment.NewLine);
            document.printErrors(new OStream(OStream.CERR));
            return 1;
        }

        Model model = document.getModel();

        if (model == null)
        {
            Console.Write("No model present." + Environment.NewLine);
            return 1;
        }

        printMath(model);
        Console.WriteLine();
        return 0;
    }

}
