/**
 * @file    addLayout.cpp
 * @brief   This example adds a layout to the loaded model.
 * @author  Sarah Keating
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
#include <string>


#include "sbml/SBMLTypes.h"
#include "sbml/packages/layout/common/LayoutExtensionTypes.h"

#if (!defined LIBSBML_HAS_PACKAGE_LAYOUT)
#error "This example requires libSBML to be built with the layout extension."
#endif

using namespace std;
LIBSBML_CPP_NAMESPACE_USE

int main(int argc, char** argv){

  if (argc != 2)
  {
    cout << endl << "Usage: addLayout input-filename"
         << endl << endl;
    return 2;
  }

  SBMLDocument *d = readSBML(argv[1]);
  if ( d->getNumErrors() > 0)
  {
    d->printErrors();
  }
  else
  {
    // enable the layout package
    // note layout in L2 uses a different namespace than L3
    if (d->getLevel() == 2)
    {
      d->enablePackage(LayoutExtension::getXmlnsL2(), "layout",  true);
    }
    else if (d->getLevel() == 3)
    {
      d->enablePackage(LayoutExtension::getXmlnsL3V1V1(), "layout",  true);
    }

    // get the model plugin
    Model * model = d->getModel();

    LayoutModelPlugin* mplugin
      = static_cast<LayoutModelPlugin*>(model->getPlugin("layout"));
    
    // create the Layout
    LayoutPkgNamespaces layoutns(d->getLevel(), d->getVersion());
    Layout* layout = mplugin->createLayout();

    layout->setId("Layout_1");
    Dimensions dim(&layoutns, 400.0, 220.0);
    layout->setDimensions(&dim);

    // write out the model
    writeSBML(d, "added-layout.xml");
  }
}

