/**
 * \file    appendAnnotation.cpp
 * \brief   adds annotation strings to a model and a species
 * \author  Akiya Jouraku
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

#include <stdio.h>
#include <sbml/SBMLTypes.h>

#include <sbml/xml/XMLNode.h>
#include <sbml/annotation/CVTerm.h>
#include <sbml/annotation/ModelHistory.h>

int
main (int argc, char *argv[])
{

  SBMLDocument_t* d;
  Model_t* m;
  unsigned int  errors;

  if (argc != 3)
  {
    printf("\n"
      "  usage: appendAnnotation <input-filename> <output-filename>\n"
      "\n");
    return 2;
  }


  d      = readSBML(argv[1]);
  errors = SBMLDocument_getNumErrors(d);

  if (errors > 0)
  {
    printf("Read Error(s):\n");
    SBMLDocument_printErrors(d, stdout);	 
    printf("Correct the above and re-run.\n");
  }
  else
  {
    int n;
    Species_t* s;

    char* model_history_annotation = 
       "<annotation>\n"
       "  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
       "    <rdf:Description rdf:about=\"#\">\n"
       "      <dc:creator rdf:parseType=\"Resource\">\n"
       "        <rdf:Bag>\n"
       "          <rdf:li rdf:parseType=\"Resource\">\n"
       "            <vCard:N rdf:parseType=\"Resource\">\n"
       "              <vCard:Family>Keating</vCard:Family>\n"
       "              <vCard:Given>Sarah</vCard:Given>\n"
       "            </vCard:N>\n"
       "            <vCard:EMAIL>sbml-team@caltech.edu</vCard:EMAIL>\n"
       "            <vCard:ORG>\n"
       "              <vCard:Orgname>University of Hertfordshire</vCard:Orgname>\n"
       "            </vCard:ORG>\n"
       "          </rdf:li>\n"
       "        </rdf:Bag>\n"
       "      </dc:creator>\n"
       "      <dcterms:created rdf:parseType=\"Resource\">\n"
       "        <dcterms:W3CDTF>1999-11-13T06:54:32Z</dcterms:W3CDTF>\n"
       "      </dcterms:created>\n"
       "      <dcterms:modified rdf:parseType=\"Resource\">\n"
       "        <dcterms:W3CDTF>2007-11-31T06:54:00-02:00</dcterms:W3CDTF>\n"
       "      </dcterms:modified>\n"
       "    </rdf:Description>\n"
       "  </rdf:RDF>\n"
       "</annotation>\n";
    
    m = SBMLDocument_getModel(d);
    SBase_appendAnnotationString((SBase_t*)m, model_history_annotation);

    /*
     * The above code can be replaced by the following code.
     *

       ModelHistory * h = new ModelHistory();

       ModelCreator *c = new ModelCreator();
       c->setFamilyName("Keating");
       c->setGivenName("Sarah");
       c->setEmail("sbml-team@caltech.edu");
       c->setOrganisation("University of Hertfordshire");

       h->addCreator(c);

       Date * date = new Date("1999-11-13T06:54:32");
       Date * date2 = new Date("2007-11-31T06:54:00-02:00");

       h->setCreatedDate(date);
       h->setModifiedDate(date2);

       d->getModel()->setModelHistory(h);

      *
      */


    n = Model_getNumSpecies(m);

    if (n > 0)
    {
      char* cvterms_annotation = "<annotation>\n"
        "  <rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:vCard=\"http://www.w3.org/2001/vcard-rdf/3.0#\" xmlns:bqbiol=\"http://biomodels.net/biology-qualifiers/\" xmlns:bqmodel=\"http://biomodels.net/model-qualifiers/\">\n"
        "    <rdf:Description rdf:about=\"#\">\n"
        "      <bqbiol:isVersionOf>\n"
        "        <rdf:Bag>\n"
        "          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0005892\"/>\n"
        "          <rdf:li rdf:resource=\"http://www.ebi.ac.uk/interpro/#IPR002394\"/>\n"
        "        </rdf:Bag>\n"
        "      </bqbiol:isVersionOf>\n"
        "      <bqbiol:is>\n"
        "        <rdf:Bag>\n"
        "          <rdf:li rdf:resource=\"http://www.geneontology.org/#GO:0005895\"/>\n"
        "        </rdf:Bag>\n"
        "      </bqbiol:is>\n"
        "    </rdf:Description>\n"
        "  </rdf:RDF>\n"
        "</annotation>\n";

      s = Model_getSpecies(m, 0);

      SBase_appendAnnotationString((SBase_t*)s, cvterms_annotation);

      /*
       * The above code can be replaced by the following code.
       *

         CVTerm *cv = new CVTerm();
         cv->setQualifierType(BIOLOGICAL_QUALIFIER);
         cv->setBiologicalQualifierType(BQB_IS_VERSION_OF);
         cv->addResource("http://www.geneontology.org/#GO:0005892");

         CVTerm *cv2 = new CVTerm();
         cv2->setQualifierType(BIOLOGICAL_QUALIFIER);
         cv2->setBiologicalQualifierType(BQB_IS);
         cv2->addResource("http://www.geneontology.org/#GO:0005895");

         CVTerm *cv1 = new CVTerm();
         cv1->setQualifierType(BIOLOGICAL_QUALIFIER);
         cv1->setBiologicalQualifierType(BQB_IS_VERSION_OF);
         cv1->addResource("http://www.ebi.ac.uk/interpro/#IPR002394");

         s->addCVTerm(cv);
         s->addCVTerm(cv2);
         s->addCVTerm(cv1);

        *
        */
    }
  
    writeSBML(d, argv[2]);
  }

  SBMLDocument_free(d);
  return errors;
}


