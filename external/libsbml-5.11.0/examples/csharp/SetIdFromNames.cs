/**
 * @file    SetIdFromNames.cs
 * @brief   Utility program, renaming all SIds that also have 
 *          names specified. The new id will be derived from 
 *          the name, with all invalid characters removed. 
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
/// This class implements an identifier transformer, that means it can be used
/// to rename all sbase elements. 
/// </summary>
public class SetIdFromNames : IdentifierTransformer
{
    /// <summary>
    /// The program is to be invoked with two arguments, the input and output file. 
    /// </summary>
    /// <param name="args">command line arguments</param>
    /// <returns>0 in case of no errors</returns>
    public static int Main(string[] args)
    {
        if (args.Length != 2)
        {
            Console.WriteLine("{0}Usage: setIdFromNames filename output{0}{0}", Environment.NewLine);
            return 1;
        }

        string filename = args[0];
        string output = args[1];

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


        // get a list of all elements, as we will need to know all identifiers
        // so that we don't create duplicates. 
        SBaseList allElements = document.getListOfAllElements();

        // get a list of all ids
        var allIds = getAllIds(allElements);

        // create the transformer with the ids
        var trans = new SetIdFromNames(allIds);

        // rename the identifiers (using the elements we already gathered before)
        start = DateTime.Now.Ticks;
        document.getModel().renameIDs(allElements, trans);
        stop = DateTime.Now.Ticks;
        Console.WriteLine("    rename time (ms): {0}", TimeSpan.FromTicks(stop - start).TotalMilliseconds);

        // write to file
        start = DateTime.Now.Ticks;
        libsbml.writeSBMLToFile(document, output);
        stop = DateTime.Now.Ticks;
        Console.WriteLine("     write time (ms): {0}", TimeSpan.FromTicks(stop - start).TotalMilliseconds);
        Console.WriteLine();

        // if we got here all went well ... 
        return 0;
    }

    /// <summary>
    /// Constructor initializing this transformer with a list of 
    /// ids that are currently used in the model (and thus newly generated
    /// ids have to be different)
    /// </summary>
    /// <param name="ids">vector of current ids</param>
    public SetIdFromNames(List<string> ids)
    {
        existingIds = ids;
    }

    /** 
	 * Cleans the name, so it represents a valid SId
	 * 
	 * Taken from COPASI (released under the artistic license)
	 * https://github.com/copasi/COPASI/blob/master/copasi/utilities/utility.cpp
	 */
    public string NameToSbmlId(string name)
    {
        // We convert all non allowed characters to '_'
        // letter ::= ’a’..’z’,’A’..’Z’
        // digit  ::= ’0’..’9’
        // idChar ::= letter | digit | ’_’
        // SId    ::= (letter | ’_’ ) idChar*

        var IdStream = new StringBuilder();
        int count = 0;
        int end = name.Length;

        if ('0' <= name[count] && name[count] <= '9')
        {
            IdStream.Append('_');
        }

        for (; count != end; ++count)
        {
            // second, third or forth character of a multi-byte encoding
            if (0x80 == (name[count] & 0xc0))
            {
                continue;
            }

            if (('0' <= name[count] && name[count] <= '9') ||
                ('a' <= name[count] && name[count] <= 'z') ||
                ('A' <= name[count] && name[count] <= 'Z'))
            {
                IdStream.Append(name[count]);
            }
            else
            {
                IdStream.Append('_');
            }
        }

        string Id = IdStream.ToString();

        if (Id[Id.Length - 1] != '_')
        {
            return Id;
        }

        return Id.Substring(0, Id.Length - 1);
    }

    /** 
	 * Generates the id out of the name, and ensures it is unique. 
	 * It does so by appending numbers to the original name. 
	 */
    string getValidIdForName(string name)
    {
        string baseString = NameToSbmlId(name);
        string id = baseString;
        int count = 1;
        while (existingIds.Contains(id))
        {
            id = string.Format("{0}_{1}", baseString, count);
            ++count;

        }
        return id;
    }

    readonly List<string> existingIds;

    /// <summary>
    /// The function actually doing the transforming. This function is called 
    /// once for each SBase element in the model. 
    /// </summary>
    /// <param name="element">the current element</param>
    /// <returns>status code</returns>
    public override int transform(SBase element)
    {
        // return in case we don't have a valid element
        if (element == null || element.getTypeCode() == libsbml.SBML_LOCAL_PARAMETER)
            return libsbml.LIBSBML_OPERATION_SUCCESS;

        // or if there is nothing to do
        if (!element.isSetName() || element.getId() == element.getName())
            return libsbml.LIBSBML_OPERATION_SUCCESS;

        // find the new id
        string newId = getValidIdForName(element.getName());

        // set it
        element.setId(newId);

        // remember it
        existingIds.Add(newId);

        return libsbml.LIBSBML_OPERATION_SUCCESS;
    }


    /**
     * Returns a list of all ids from the given list of elements
     */
    public static List<string> getAllIds(SBaseList allElements)
    {
        var result = new List<string>();
        if (allElements == null || allElements.getSize() == 0)
            return result;

        for (uint i = 0; i < allElements.getSize(); ++i)
        {
            SBase current = allElements.get(i);
            if (current.isSetId() && current.getTypeCode() != libsbml.SBML_LOCAL_PARAMETER)
            {
                result.Add(current.getId());
            }
        }

        return result;
    }

    
}
