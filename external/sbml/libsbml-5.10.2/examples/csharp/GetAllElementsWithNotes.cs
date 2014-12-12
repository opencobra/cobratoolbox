/**
 * @file    GetAllElementsWithNotes.cs
 * @brief   Utility program, demontrating how to use the element filter
 *          class to search the model for elements with specific attributes
 *          in this example, we look for elements with notes
 *
 * @author  Frank T. Bergmann
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

/// <summary>
/// This class implements an element filter, that can be used to find elements
/// with notes
/// </summary>
public class NotesFilter : ElementFilter
{
    /// <summary>
    /// The program is to be invoked with one argument, the input file. 
    /// </summary>
    /// <param name="args">command line arguments</param>
    /// <returns>0 in case of no errors</returns>
    public static int Main(string[] args)
    {
        if (args.Length != 1)
        {
            Console.WriteLine("{0}Usage: getAllElementsWithNotes filename{0}{0}", Environment.NewLine);
            return 1;
        }

        string filename = args[0];

        // read the document
        long start = DateTime.Now.Ticks;
        SBMLDocument document = libsbml.readSBMLFromFile(filename);
        long stop = DateTime.Now.Ticks;


        Console.WriteLine();
        Console.WriteLine("            filename: {0}", filename);
        Console.WriteLine("      read time (ms): {0}", TimeSpan.FromTicks(stop - start).TotalMilliseconds);

        // stop in case of serious errors
        long errors = document.getNumErrors(libsbml.LIBSBML_SEV_ERROR);
        if (errors > 0)
        {
            Console.WriteLine("            error(s): {0}", errors);
            document.printErrors();
            return (int)errors;
        }


		// create the filter we want to use
		var filter = new NotesFilter();
        //  get a list of all elements with notes 
        start = DateTime.Now.Ticks;
		Console.WriteLine("    searching ......:");
        SBaseList allElements = document.getListOfAllElements(filter);
        stop = DateTime.Now.Ticks;
        Console.WriteLine("    search time (ms): {0}", TimeSpan.FromTicks(stop - start).TotalMilliseconds);
        Console.WriteLine();
        Console.WriteLine(" elements with notes: {0}", allElements.getSize());
        Console.WriteLine();

        // if we got here all went well ... 
        return 0;
    }

    /// <summary>
    /// Constructor initializing this element filter
    /// </summary>
    public NotesFilter()
    {
    }

    /// <summary>
    /// The function performing the filtering, here we just check 
    /// that we have a valid element, and that it has notes.
    /// </summary>
    /// <param name="element">the current element</param>
    /// <returns><b>true</b> if element is to be included, <b>false</b> otherwise</returns>
    public override bool filter(SBase element)
    {
        // return in case we don't have a valid element
        if (element == null || !element.isSetNotes())
            return false;

        // otherwise we have notes set and want to keep the element
        if (!element.isSetId())
            Console.WriteLine("                     found : {0}", element.getId());
		else
			Console.WriteLine("                     found element without id");

        return true;
    }


}
