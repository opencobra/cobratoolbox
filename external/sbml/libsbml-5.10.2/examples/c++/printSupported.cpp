/**
 * @file    printSupported.cpp
 * @brief   Prints supported SBML Levels and Versions for the LibSBML library
 * @author  Frank Bergmann
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
#include <vector>
#include <string>
#include <sbml/SBMLTypes.h>


using namespace std;
LIBSBML_CPP_NAMESPACE_USE

int
main (int argc, char* argv[])
{
  const List* supported = 
    SBMLNamespaces::getSupportedNamespaces();

  cout << "LibSBML: " << getLibSBMLDottedVersion() << " supports: " << endl;

  for (unsigned int i = 0; i < supported->getSize(); i++)
  {
       const SBMLNamespaces *current = (const SBMLNamespaces *)supported->get(i);
       cout << "\tSBML Level " << current->getLevel() << " Version: " << current->getVersion() << endl;
  }
  
  cout << endl;
  cout << "LibSBML is compiled against: " << endl;
  if (isLibSBMLCompiledWith("expat"))
    cout << "\tExpat:      "  << getLibSBMLDependencyVersionOf("expat") << endl;
  if (isLibSBMLCompiledWith("libxml"))
    cout << "\tLibXML:     "  << getLibSBMLDependencyVersionOf("libxml") << endl;
  if (isLibSBMLCompiledWith("xerces-c"))
    cout << "\tXerces-C++: "  << getLibSBMLDependencyVersionOf("xerces-c") << endl;
  if (isLibSBMLCompiledWith("zlib"))
    cout << "\tZlib:       "  << getLibSBMLDependencyVersionOf("zlib") << endl;
  if (isLibSBMLCompiledWith("bzip"))
    cout << "\tbzip2:      "  << getLibSBMLDependencyVersionOf("bzip") << endl;
    
  cout << endl;

  return 0;
}


