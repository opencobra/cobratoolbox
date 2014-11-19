/**
 * \file    addModelHistory.cpp
 * \brief   adds Model History to a model
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
using System.Collections.Generic;
using System.IO;
using System.Text;
using libsbmlcs;

public class AddModelHistory
{
    private static void printStatus(string message, long status)
    {
        string statusString;
        switch (status)
        {
            case libsbml.LIBSBML_OPERATION_SUCCESS:
                statusString = "succeeded";
                break;
            case libsbml.LIBSBML_INVALID_OBJECT:
                statusString = "invalid object";
                break;
            case libsbml.LIBSBML_OPERATION_FAILED:
                statusString = "operation failed";
                break;
            default:
                statusString = "unknown";
                break;
        }

        Console.Write(message + statusString + Environment.NewLine);

    }

    public static int Main(string[] args)
    {


        SBMLDocument d;
        int errors;

        if (args.Length != 2)
        {
            Console.Write(Environment.NewLine
                                      + "  usage: addModelHistory <input-filename> <output-filename>" + Environment.NewLine
                                      + Environment.NewLine);
            return 2;
        }


        d = libsbml.readSBML(args[0]);
        errors = (int)d.getNumErrors();

        if (errors > 0)
        {
            Console.Write("Read Error(s):" + Environment.NewLine);
            d.printErrors();

            Console.Write("Correct the above and re-run." + Environment.NewLine);
        }
        else
        {
            ModelHistory h = new ModelHistory();

            ModelCreator c = new ModelCreator();
            c.setFamilyName("Keating");
            c.setGivenName("Sarah");
            c.setEmail("sbml-team@caltech.edu");
            c.setOrganization("University of Hertfordshire");

            long status = h.addCreator(c);
            printStatus("Status for addCreator: ", status);


            Date date = new Date("1999-11-13T06:54:32");
            Date date2 = new Date("2007-11-30T06:54:00-02:00");

            status = h.setCreatedDate(date);
            printStatus("Set created date:      ", status);

            status = h.setModifiedDate(date2);
            printStatus("Set modified date:     ", status);

            status = d.getModel().setModelHistory(h);
            printStatus("Set model history:     ", status);


            libsbml.writeSBML(d, args[1]);
        }

        return errors;
    }

}
