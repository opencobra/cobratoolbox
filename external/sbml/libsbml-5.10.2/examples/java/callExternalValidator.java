/**
 * @file    callExternalValidator.cpp
 * @brief   Example that shows how to call an external program for validation
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

import java.util.List;
import java.util.Vector;

import org.sbml.libsbml.SBMLDocument;
import org.sbml.libsbml.SBMLExternalValidator;
import org.sbml.libsbml.libsbml;

public class callExternalValidator {
    public static void main(String[] args) {
        System.loadLibrary("sbmlj");

        if (args.length < 3) {
            System.out
                    .println("Usage: callExternalValidator filename externalValidator [ tempSBMLFile outputFile [ ADDITIONAL-ARGS] ]");
            System.exit(1);
        }

        String filename = args[0];

        // read additional args
        String externalValidator = args[1];

        String tempSBMLFileName = filename + "_temp.xml";
        if (args.length > 2)
            tempSBMLFileName = args[2];

        String outputFile = filename + "_out.xml";
        if (args.length > 3)
            outputFile = args[3];

        List<String> additionalArgs = new Vector<String>();
        for (int i = 4; i < args.length; i++)
            additionalArgs.add(args[i]);

        // add the output file as additional arg
        additionalArgs.add(outputFile);

        // read the file name
        SBMLDocument document = libsbml.readSBML(filename);

        // create a new external validator that will write the model to
        // tempFile, then call teh externalValidator with the given number of
        // arguments
        // to produce the output file. This output file will then be parsed and
        // its
        // errors will be added to the error log.
        SBMLExternalValidator validator = new SBMLExternalValidator();

        validator.setProgram(externalValidator);
        validator.setSBMLFileName(tempSBMLFileName);
        validator.setOutputFileName(outputFile);
        for (String item : additionalArgs) {
            validator.addArgument(item);
        }

        // this means that the external program will be called with the
        // following arguments
        //
        // externalValidator tempSBMLFileName additionalArgs
        //
        // (where additionalargs contains the output file as last argument)
        //
        // The output file that is generated should be an XML document following
        // the
        // Validator XML format as described here:
        // http://sbml.org/validator/api/#xml
        //

        // disable all regular checks
        document.setApplicableValidators((short) 0);

        // add a custom validator
        document.addValidator(validator);

        // check consistency like before
        int numErrors = (int) document.checkConsistency();

        // print errors and warnings
        document.printErrors();

        // return number of errors
        System.exit(numErrors);

    }
}
