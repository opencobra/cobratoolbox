/**
 * @file    setIdFromNames.cpp
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
 * The NameIdTransformer class transforms the id of a given SBase 
 * element by replacing it with a string derived from the name. 
 * 
 * It won't do anything if the name is the same as the id, or if 
 * no name is set. 
 */ 
class NameIdTransformer : public IdentifierTransformer
{
public:
	NameIdTransformer(const vector<string> &ids) 
	: IdentifierTransformer()
	, existingIds(ids)
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
		if (!element->isSetName() || element->getId() == element->getName())			
			return LIBSBML_OPERATION_SUCCESS;

		// find the new id
		string newId = getValidIdForName(element->getName());

		// set it
		element->setId(newId);

		// remember it
		existingIds.push_back(newId);
		
		return LIBSBML_OPERATION_SUCCESS;
			
	}

private: 

	/** 
	 * Cleans the name, so it represents a valid SId
	 * 
	 * Taken from COPASI (released under the artistic license)
	 * https://github.com/copasi/COPASI/blob/master/copasi/utilities/utility.cpp
	 */ 
	std::string nameToSbmlId(const std::string & name)
	{
	// We convert all non allowed characters to '_'
	// letter ::= 'a'..'z','A'..'Z'
	// digit  ::= '0'..'9'
	// idChar ::= letter | digit | '_'
	// SId    ::= (letter | '_' ) idChar*
	
	std::ostringstream IdStream;
	
	std::string::const_iterator it = name.begin();
	std::string::const_iterator end = name.end();
	
	if ('0' <= *it && *it <= '9')
		{
		IdStream << '_';
		}
	
	for (; it != end; ++it)
		{
		// second, third or forth character of a multi-byte encoding
		if (0x80 == (*it & 0xc0))
			{
			continue;
			}
	
		if (('0' <= *it && *it <= '9') ||
			('a' <= *it && *it <= 'z') ||
			('A' <= *it && *it <= 'Z'))
			{
			IdStream << *it;
			}
		else
			{
			IdStream << '_';
			}
		}
	
	std::string Id = IdStream.str();
	
	if (Id[Id.length() - 1] != '_')
		{
		return Id;
		}
	
	return Id.substr(0, Id.length() - 1);
	}
	
	/** 
	 * Generates the id out of the name, and ensures it is unique. 
	 * It does so by appending numbers to the original name. 
	 */ 
	string getValidIdForName(const string& name)
	{
		string base = nameToSbmlId(name);
		string id(base);
		int count = 1;
		while (containsId(id))
		{
			std::ostringstream idStream;
			idStream << base << "_" << count;
			id = idStream.str();
			++count;
			
		}
		return id;
	}
	
	/** 
	 * Checks whether the given id is already in the vector. 
	 */	 
	bool containsId(string &id)
	{
		vector<string>::const_iterator it = existingIds.begin();
		while(it != existingIds.end())
		{
			if ((*it) == id) return true;
			++it;
		}
		return false;
	}
	
	vector<string> existingIds;
};

/**
 * Returns a list of all ids from the given list of elements
 */
vector<string> getAllIds(List* allElements)
{
	vector<string> result; 
	if (allElements == NULL || allElements->getSize() == 0) 
		return result;
	
	for (unsigned long int i = 0; i < allElements->getSize(); ++i)
	{
		const SBase* current = static_cast<const SBase*>(allElements->get(i));
		if (current->isSetId() && current->getTypeCode() != SBML_LOCAL_PARAMETER)
		{			
			result.push_back(current->getId());
		}
	}
	
	return result;
}

BEGIN_C_DECLS

int
main (int argc, char* argv[])
{
    if (argc != 3)
    {
        cout << endl << "Usage: setIdFromNames filename output" << endl << endl;
        return 1;
    }
    
    const char* filename   = argv[1];
    const char* output     = argv[2];
    
        
    SBMLDocument* document;
    SBMLReader reader;
#ifdef __BORLANDC__
    unsigned long start, stop;
#else
    unsigned long long start, stop;
#endif
    
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
	// so that we don't create duplicates. 
	List* allElements = document->getAllElements(); 
	
	// get a list of all ids
	const vector<string>& allIds = getAllIds(allElements);
	
	// create the transformer with the ids
	NameIdTransformer trans(allIds);
	
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
