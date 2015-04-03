/** 
 * @file    getAllElementsWithNotes.java
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
import java.util.Vector;
import org.sbml.libsbml.ElementFilter;
import org.sbml.libsbml.SBMLDocument;
import org.sbml.libsbml.SBase;
import org.sbml.libsbml.SBaseList;
import org.sbml.libsbml.libsbml;

public class getAllElementsWithNotes
    extends ElementFilter
{

    /**
     * @param args
     */
    public static void main(String[] args)
    {
        System.loadLibrary("sbmlj");
        System.out.println("Using libSBML : "
            + libsbml.getLibSBMLDottedVersion());
        if (args.length != 1)
        {
            System.out.format("\nUsage: getAllElementsWithNotes filename\n\n");
            System.exit(1);
        }

        String filename = args[0];

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

        // create the filter to use
        getAllElementsWithNotes filter = new getAllElementsWithNotes();
        // get a list of all elements, as we will need to know all identifiers
        // so that we don't create duplicates.
        start = System.currentTimeMillis();
        System.out.println("    searching ......:");
        SBaseList allElements = document.getListOfAllElements(filter);
        stop = System.currentTimeMillis();
        System.out.format("  seaching took (ms): %d\n", (stop - start));
        System.out.format(" elements with notes: %d\n", (allElements.getSize()));

        // if we got here all went well ...

    }


    // <summary>
    // Constructor initializing this element filter
    // </summary>
    public getAllElementsWithNotes()
    {
    }


    @Override
    public boolean filter(SBase element)
    {
        // return in case we don't have a valid element
        if (element == null
            || !element.isSetNotes())
            return false;

        // otherwise we have notes set and want to keep the element
        if (element.isSetId())
            System.out.println("                     found : " + element.getId() );
        else 
            System.out.println("                     found element without id");

        return true;
    }


}
