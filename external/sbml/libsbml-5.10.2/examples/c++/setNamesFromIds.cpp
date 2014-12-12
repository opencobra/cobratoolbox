/**
 * @file    setNamesFromIds.cpp
 * @brief   Utility program, renaming all Names to match their ids. 
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


#include <iostream>
#include <sstream>
#include <vector>
#include <string>

#include <sbml/SBMLTypes.h>
#include <sbml/common/extern.h>
#include <sbml/common/operationReturnValues.h>
#include "util.h"


using namespace std;
LIBSBML_CPP_NAMESPACE_USE


/** 
 * The NameIdTransformer class transforms the name of a given SBase 
 * element by replacing it with its id. 
 * 
 * It won't do anything if the name is the same as the id, or if 
 * no id is set. 
 */ 
class NameIdTransformer : public IdentifierTransformer
{
public:
	NameIdTransformer() 
	: IdentifierTransformer()
	{
	}

	/** 
	 * The actual transform implementation
	 */
	int transform(SBase* element)
	{
		// return in case we don't have a valid element
		if (element == NULL || element->getTypeCode() == SBML_LOCAL_PARAMETER)	
			return LIBSBML_OPERATION_SUCCESS;

		// or if there is nothing to do
		if (!element->isSetId() || element->getId() == element->getName())			
			return LIBSBML_OPERATION_SUCCESS;

		// set it
		element->setName(element->getId());

		
		return LIBSBML_OPERATION_SUCCESS;
			
	}

};

BEGIN_C_DECLS

int
main (int argc, char* argv[])
{
    if (argc != 3)
    {
        cout << endl << "Usage: setNamesFromIds filename output" << endl << endl;
        return 1;
    }
    
    const char* filename   = argv[1];
    const char* output     = argv[2];
    
        
    SBMLDocument* document;
    SBMLReader reader;
    unsigned long long start, stop;
    
    start    = getCurrentMillis();
    document = reader.readSBML(filename);
    stop     = getCurrentMillis();
    
    unsigned int errors = document->getNumErrors(LIBSBML_SEV_ERROR);
    
    cout << endl;
    cout << "            filename: " << filename              << endl;
    cout << "      read time (ms): " << stop - start          << endl;
    
    if (errors > 0)
    {
		cout << "            error(s): " << errors << endl;
        document->printErrors(cerr);
        delete document;
        return errors;
    }
    
	start = stop;
	
	// get a list of all elements, as we will need to know all identifiers
	List* allElements = document->getAllElements(); 
	
	// create the transformer 
	NameIdTransformer trans;
	
	// rename the identifiers (using the elements we already gathered before)
	document->getModel()->renameIDs(allElements, &trans);    
	stop     = getCurrentMillis();
	cout << "    rename time (ms): " << stop - start          << endl;
	start = stop;
	
    // write to file
    writeSBMLToFile(document, output);
    stop     = getCurrentMillis();
	cout << "     write time (ms): " << stop - start          << endl;   
	cout << endl;
	
    delete document;
    return errors;
}

END_C_DECLS
