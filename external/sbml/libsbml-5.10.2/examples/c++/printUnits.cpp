/**
 * @file    printUnits.cpp
 * @brief   Prints some unit information about the model
 * @author  Sarah Keating
 * @author  Michael Hucka
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
#include <sbml/SBMLTypes.h>

#include <sbml/UnitDefinition.h>
#include <sbml/units/UnitFormulaFormatter.h>
#include <sbml/units/FormulaUnitsData.h>


using namespace std;
LIBSBML_CPP_NAMESPACE_USE

int
main (int argc, char *argv[])
{
  if (argc != 2)
  {
    cout << endl << "Usage: printUnits filename" << endl << endl;
    return 1;
  }

  const char* filename   = argv[1];
  SBMLDocument* document = readSBML(filename);

  if (document->getNumErrors() > 0)
  {
    cerr << "Encountered the following SBML errors:" << endl;
    document->printErrors(cerr);
    return 1;
  }

  Model* model = document->getModel();

  if (model == 0)
  {
    cout << "No model present." << endl;
    return 1;
  }

  unsigned int i,j;
  for (i = 0; i < model->getNumSpecies(); i++)
  {
    Species* s = model->getSpecies(i);
    cout << "Species " << i << ": "
      << UnitDefinition::printUnits(s->getDerivedUnitDefinition()) << endl;
  }

  for (i = 0; i < model->getNumCompartments(); i++)
  {
    Compartment *c = model->getCompartment(i);
    cout << "Compartment " << i << ": "
      << UnitDefinition::printUnits(c->getDerivedUnitDefinition()) 
      << endl;
  }

  for (i = 0; i < model->getNumParameters(); i++)
  {
    Parameter *p = model->getParameter(i);
    cout << "Parameter " << i << ": "
      << UnitDefinition::printUnits(p->getDerivedUnitDefinition()) 
      << endl;
  }


  for (i = 0; i < model->getNumInitialAssignments(); i++)
  {
    InitialAssignment *ia = model->getInitialAssignment(i);
    cout << "InitialAssignment " << i << ": " 
      << UnitDefinition::printUnits(ia->getDerivedUnitDefinition()) << endl;
    cout << "        undeclared units: ";
    cout << (ia->containsUndeclaredUnits() ? "yes\n" : "no\n");
  }

  for (i = 0; i < model->getNumEvents(); i++)
  {
    Event *e = model->getEvent(i);
    cout << "Event " << i << ": " << endl;

    if (e->isSetDelay())
    {
      cout << "Delay: " 
        << UnitDefinition::printUnits(e->getDelay()->getDerivedUnitDefinition()) << endl;
      cout << "        undeclared units: ";
      cout << (e->getDelay()->containsUndeclaredUnits() ? "yes\n" : "no\n");
    }
      
    for (j = 0; j < e->getNumEventAssignments(); j++)
    {
      EventAssignment *ea = e->getEventAssignment(j);
      cout << "EventAssignment " << j << ": " 
        << UnitDefinition::printUnits(ea->getDerivedUnitDefinition()) << endl;
      cout << "        undeclared units: ";
      cout << (ea->containsUndeclaredUnits() ? "yes\n" : "no\n");
    }
  }

  for (i = 0; i < model->getNumReactions(); i++)
  {
    Reaction *r = model->getReaction(i);
      
    cout << "Reaction " << i << ": " << endl;

    if (r->isSetKineticLaw())
    {
      cout << "Kinetic Law: " 
        << UnitDefinition::printUnits(r->getKineticLaw()->getDerivedUnitDefinition()) << endl;
      cout << "        undeclared units: ";
      cout << (r->getKineticLaw()->containsUndeclaredUnits() ? "yes\n" : "no\n");
    }

    for (j = 0; j < r->getNumReactants(); j++)
    {
      SpeciesReference *sr = r->getReactant(j);

      if (sr->isSetStoichiometryMath())
      {
        cout << "Reactant stoichiometryMath" << j << ": " 
          << UnitDefinition::printUnits(sr->getStoichiometryMath()->getDerivedUnitDefinition()) << endl;
        cout << "        undeclared units: ";
        cout << (sr->getStoichiometryMath()->containsUndeclaredUnits() ? "yes\n" : "no\n");
      }
    }

    for (j = 0; j < r->getNumProducts(); j++)
    {
      SpeciesReference *sr = r->getProduct(j);

      if (sr->isSetStoichiometryMath())
      {
        cout << "Product stoichiometryMath" << j << ": " 
          << UnitDefinition::printUnits(sr->getStoichiometryMath()->getDerivedUnitDefinition()) << endl;
        cout << "        undeclared units: ";
        cout << (sr->getStoichiometryMath()->containsUndeclaredUnits() ? "yes\n" : "no\n");
      }
    }
  }

  for (i = 0; i < model->getNumRules(); i++)
  {
    Rule *r = model->getRule(i);
    cout << "Rule " << i << ": " 
      << UnitDefinition::printUnits(r->getDerivedUnitDefinition()) << endl;
    cout << "        undeclared units: ";
    cout << (r->containsUndeclaredUnits() ? "yes\n" : "no\n");
  }

  delete document;
  return 0;
}
