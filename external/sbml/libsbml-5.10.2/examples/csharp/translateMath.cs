/**
 * @file    translateMath.cpp
 * @brief   Translates infix formulas into MathML and vice-versa
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
using System.Text;
using libsbmlcs;

public class TranslateMath
{

    public static int Main(string[] args)
    {
        string line;
        string trimmed;
        string result;
        string str;
        long len;
        StringBuilder sb = new StringBuilder(1024);


        Console.WriteLine("This program translates infix formulas into MathML and");
        Console.WriteLine("vice-versa.  Enter or return on an empty line triggers");
        Console.WriteLine("translation. Ctrl-C quits");

        while (true)
        {
            Console.WriteLine("Enter infix formula or MathML expression (Ctrl-C to quit):");
            Console.Write("> ");

            line = Console.ReadLine();
            while (line != null)
            {
                trimmed = line.Trim();
                len = trimmed.Length;
                if (len > 0)
                {
                    sb.AppendLine(trimmed);
                }
                else
                {
                    str = sb.ToString();
                    result = (str[0] == '<') ? translateMathML(str) : translateInfix(str);

                    Console.WriteLine("Result:\n\n" + result + "\n\n");
                    sb = new StringBuilder(1024);
                    break;
                }

                line = Console.ReadLine();
            }
        }
    }


    /**
     * Translates the given infix formula into MathML.
     *
     * @return the MathML as a string.  The caller owns the memory and is
     * responsible for freeing it.
     */
    public static string translateInfix(string formula)
    {
        ASTNode math = libsbml.parseFormula(formula);

        string result = libsbml.writeMathMLToString(math);

        return result;
    }


    /**
     * Translates the given MathML into an infix formula.  The MathML must
     * contain no leading whitespace, but an XML header is optional.
     *
     * @return the infix formula as a string.  The caller owns the memory and
     * is responsible for freeing it.
     */
    public static string translateMathML(string xml)
    {
        ASTNode math = libsbml.readMathMLFromString(xml);
        string result = libsbml.formulaToString(math);
        return result;
    }
}
