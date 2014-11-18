/**
 * \file    addCVTerms.cpp
 * \brief   adds controlled vocabulary terms to a species in a model
 * \author  Sarah Keating
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
using libsbmlcs;

public class AddCVTerms
{
    public static int Main(string[] args)
    {

        SBMLDocument d;
        long errors, n;
        Species s;

        if (args.Length != 2)
        {
            Console.WriteLine("  usage: addCVTerms <input-filename> <output-filename>");
            Console.WriteLine("  Adds controlled vocabulary term to a species");
            return 2;
        }


        d = libsbml.readSBML(args[0]);
        errors = d.getNumErrors();

        if (errors > 0)
        {
            Console.WriteLine("Read Error(s):");
            d.printErrors();

            Console.WriteLine("Correct the above and re-run.");
        }
        else
        {

            n = d.getModel().getNumSpecies();

            if (n <= 0)
            {
                Console.WriteLine("Model has no species.\n Cannot add CV terms\n");
            }
            else
            {
                s = d.getModel().getSpecies(0);

                CVTerm cv = new CVTerm();
                cv.setQualifierType(libsbml.BIOLOGICAL_QUALIFIER);
                cv.setBiologicalQualifierType(libsbml.BQB_IS_VERSION_OF);
                cv.addResource("http://www.geneontology.org/#GO:0005892");

                CVTerm cv2 = new CVTerm();
                cv2.setQualifierType(libsbml.BIOLOGICAL_QUALIFIER);
                cv2.setBiologicalQualifierType(libsbml.BQB_IS);
                cv2.addResource("http://www.geneontology.org/#GO:0005895");

                CVTerm cv1 = new CVTerm();
                cv1.setQualifierType(libsbml.BIOLOGICAL_QUALIFIER);
                cv1.setBiologicalQualifierType(libsbml.BQB_IS_VERSION_OF);
                cv1.addResource("http://www.ebi.ac.uk/interpro/#IPR002394");

                s.addCVTerm(cv);
                s.addCVTerm(cv2);
                s.addCVTerm(cv1);

                libsbml.writeSBML(d, args[1]);
            }
        }

        return (int)errors;
    }

}
