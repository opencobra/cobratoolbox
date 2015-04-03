/**
 * @file    setIdFromNames.java
 * @brief   Utility program, renaming all SIds that also has
 *          names specified. The new id will be derived from
 *          the name, with all invalid characters removed. 
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

import java.util.Vector;
import org.sbml.libsbml.IdentifierTransformer;
import org.sbml.libsbml.SBMLDocument;
import org.sbml.libsbml.SBase;
import org.sbml.libsbml.SBaseList;
import org.sbml.libsbml.libsbml;

public class setIdFromNames
    extends IdentifierTransformer
{

    /**
     * @param args
     */
    public static void main(String[] args)
    {
        System.loadLibrary("sbmlj");
        System.out.println("Using libSBML : "
            + libsbml.getLibSBMLDottedVersion());
        if (args.length != 2)
        {
            System.out.format("\nUsage: setIdFromNames filename output\n\n");
            System.exit(1);
        }

        String filename = args[0];
        String output = args[1];

        // read the document
        long start = System.currentTimeMillis();
        SBMLDocument document = libsbml.readSBMLFromFile(filename);
        long stop = System.currentTimeMillis();

        System.out.println();
        System.out.format("            filename: %s\n", filename);
        System.out.format("      read time (ms): %d\n", (stop - start));

        // stop in case of serious errors
        long errors = document.getNumErrors(libsbml.LIBSBML_SEV_ERROR);
        if (errors > 0)
        {
            System.out.format("            error(s): %d\n", errors);
            document.printErrors();
            System.exit((int) errors);
        }

        // get a list of all elements, as we will need to know all identifiers
        // so that we don't create duplicates.
        SBaseList allElements = document.getListOfAllElements();

        // get a list of all ids
        Vector<String> allIds = getAllIds(allElements);

        // create the transformer with the ids
        setIdFromNames trans = new setIdFromNames(allIds);

        // rename the identifiers (using the elements we already gathered
        // before)
        start = System.currentTimeMillis();
        document.getModel().renameIDs(allElements, trans);
        stop = System.currentTimeMillis();
        System.out.format("    rename time (ms): %d\n", (stop - start));

        // write to file
        start = System.currentTimeMillis();
        libsbml.writeSBMLToFile(document, output);
        stop = System.currentTimeMillis();
        System.out.format("     write time (ms): %d\n", (stop - start));
        System.out.println();

        // if we got here all went well ...

    }


    // <summary>
    // Constructor initializing this transformer with a list of
    // ids that are currently used in the model (and thus newly generated
    // ids have to be different)
    // </summary>
    // <param name="ids">vector of current ids</param>
    public setIdFromNames(Vector<String> ids)
    {
        existingIds = ids;
    }

    Vector<String> existingIds;


    /**
     * Cleans the name, so it represents a valid SId
     * 
     * Taken from COPASI (released under the artistic license)
     * https://github.com/copasi/COPASI/blob/master/copasi/utilities/utility.cpp
     */
    public String nameToSbmlId(String name)
    {
        // We convert all non allowed characters to '_'
        // letter ::= 'a'..'z','A'..'Z'
        // digit ::= '0'..'9'
        // idChar ::= letter | digit | '_'
        // SId ::= (letter | '_' ) idChar*

        StringBuilder IdStream = new StringBuilder();
        int count = 0;
        int end = name.length();

        if ('0' <= name.charAt(count) && name.charAt(count) <= '9')
        {
            IdStream.append('_');
        }

        for (; count != end; ++count)
        {
            // second, third or forth character of a multi-byte encoding
            if (0x80 == (name.charAt(count) & 0xc0))
            {
                continue;
            }

            if (('0' <= name.charAt(count) && name.charAt(count) <= '9')
                || ('a' <= name.charAt(count) && name.charAt(count) <= 'z')
                || ('A' <= name.charAt(count) && name.charAt(count) <= 'Z'))
            {
                IdStream.append(name.charAt(count));
            }
            else
            {
                IdStream.append('_');
            }
        }

        String Id = IdStream.toString();

        if (Id.charAt(Id.length() - 1) != '_')
        {
            return Id;
        }

        return Id.substring(0, Id.length() - 1);
    }


    /**
     * Generates the id out of the name, and ensures it is unique.
     * It does so by appending numbers to the original name.
     */
    String getValidIdForName(String name)
    {
        String baseString = nameToSbmlId(name);
        String id = baseString;
        int count = 1;
        while (existingIds.contains(id))
        {
            id = String.format("%s_%d", baseString, count);
            ++count;

        }
        return id;
    }


    @Override
    public int transform(SBase element)
    {
        // return in case we don't have a valid element
        if (element == null
            || element.getTypeCode() == libsbml.SBML_LOCAL_PARAMETER)
            return libsbml.LIBSBML_OPERATION_SUCCESS;

        // or if there is nothing to do
        if (!element.isSetName() || element.getId() == element.getName())
            return libsbml.LIBSBML_OPERATION_SUCCESS;

        // find the new id
        String newId = getValidIdForName(element.getName());

        // set it
        element.setId(newId);

        // remember it
        existingIds.add(newId);

        return libsbml.LIBSBML_OPERATION_SUCCESS;
    }


    /**
     * Returns a list of all ids from the given list of elements
     */
    public static Vector<String> getAllIds(SBaseList allElements)
    {
        Vector<String> result = new Vector<String>();
        if (allElements == null || allElements.getSize() == 0) return result;

        for (int i = 0; i < allElements.getSize(); ++i)
        {
            SBase current = allElements.get(i);
            if (current.isSetId()
                && current.getTypeCode() != libsbml.SBML_LOCAL_PARAMETER)
            {
                result.add(current.getId());
            }
        }

        return result;
    }

}
