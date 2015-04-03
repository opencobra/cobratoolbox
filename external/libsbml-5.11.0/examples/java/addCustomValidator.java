/**
 * @file    addCustomValidator.cpp
 * @brief   Example creating a custom validator to be called during validation
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

import org.sbml.libsbml.SBMLDocument;
import org.sbml.libsbml.SBMLError;
import org.sbml.libsbml.SBMLValidator;
import org.sbml.libsbml.libsbml;

/**
 * Declares a custom validator to be called. This allows you to validate any
 * aspect of an SBML Model that you want to be notified about. You could use
 * this to notify your application that a model contains an unsupported feature
 * of SBML (either as warning).
 * 
 * In this example the validator will go through the model and test for the
 * presence of 'fast' reactions and algebraic rules. If either is used a warning
 * will be added to the error log.
 */
public class addCustomValidator extends SBMLValidator {
    public addCustomValidator() {
        super();
    }

    public addCustomValidator(addCustomValidator orig) {
        super(orig);
    }

    public @Override
    SBMLValidator clone() {
        return new addCustomValidator(this);
    }

    public @Override
    long validate() {
        // if we don't have a model we don't apply this validator.
        if (getDocument() == null || getModel() == null)
            return 0;

        // if we have no rules and reactions we don't apply this validator
        // either
        if (getModel().getNumReactions() == 0 && getModel().getNumRules() == 0)
            return 0;

        int numErrors = 0;
        // test for algebraic rules
        for (int i = 0; i < getModel().getNumRules(); i++) {
            if (getModel().getRule(i).getTypeCode() == libsbml.SBML_ALGEBRAIC_RULE) {

                getErrorLog()
                        .add(new SBMLError(
                                99999,
                                3,
                                1,
                                "This model uses algebraic rules, however this application does not support them.",
                                0, 0, libsbml.LIBSBML_SEV_WARNING, // or
                                                                    // LIBSBML_SEV_ERROR
                                                                    // if you
                                                                    // want to
                                                                    // stop
                                libsbml.LIBSBML_CAT_SBML // or whatever category
                                                            // you prefer
                        ));

                numErrors++;
            }
        }

        // test for fast reactions
        for (int i = 0; i < getModel().getNumReactions(); i++) {
            // test whether value is set, and true
            if (getModel().getReaction(i).isSetFast()
                    && getModel().getReaction(i).getFast()) {

                getErrorLog()
                        .add(new SBMLError(
                                99999,
                                3,
                                1,
                                "This model uses fast reactions, however this application does not support them.",
                                0, 0, libsbml.LIBSBML_SEV_WARNING, // or
                                                                    // LIBSBML_SEV_ERROR
                                                                    // if you
                                                                    // want to
                                                                    // stop
                                libsbml.LIBSBML_CAT_SBML // or whatever category
                                                            // you prefer
                        ));

                numErrors++;

            }
        }

        return numErrors;
    }

    public static void main(String[] args) {
        if (args.length != 1) {
            System.out.println("Usage: addCustomValidator filename");
            System.exit(1);
        }

        System.loadLibrary("sbmlj");

        // read the file name
        SBMLDocument document = libsbml.readSBML(args[0]);

        // add a custom validator
        document.addValidator(new addCustomValidator());

        // check consistency like before
        int numErrors = (int) document.checkConsistency();

        // print errors and warnings
        document.printErrors();

        // return number of errors
        System.exit(numErrors);

    }

};
