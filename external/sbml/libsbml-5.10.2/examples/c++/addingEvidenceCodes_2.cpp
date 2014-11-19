/**
 * \file    addingEvidenceCodes_2.cpp
 * \brief   adds evidence codes to a species in a model
 * \author  Sarah Keating
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

#include <sbml/annotation/CVTerm.h>
using namespace std;
LIBSBML_CPP_NAMESPACE_USE

int
main (int argc, char *argv[])
{

  SBMLDocument* d;
  unsigned int  errors, n;
  Species *s;

  if (argc != 3)
  {
    cout << endl
         << "  usage: addingEvidenceCodes_2 <input-filename> <output-filename>" << endl
         << "  Adds controlled vocabulary term to a species"          << endl
         << endl;
    return 2;
  }


  d      = readSBML(argv[1]);
  errors = d->getNumErrors();

  if (errors > 0)
  {
    cout << "Read Error(s):" << endl;
	  d->printErrors(cout);

    cout << "Correct the above and re-run." << endl;
  }
  else
  {
  
    n = d->getModel()->getNumSpecies();
    
    if (n <= 0)
    {
      cout << "Model has no species.\n Cannot add CV terms\n";
    }
    else
    {
      s = d->getModel()->getSpecies(0);

      /* check that the species has a metaid
       * no CVTerms will be added if there is no metaid to reference
       */
      if (!s->isSetMetaId())
        s->setMetaId("metaid_0000052");

      CVTerm * cv1 = new CVTerm(BIOLOGICAL_QUALIFIER);
      cv1->setBiologicalQualifierType(BQB_OCCURS_IN);
      cv1->addResource("urn:miriam:obo.go:GO%3A0005764");

      s->addCVTerm(cv1);

      // now create the additional annotation
 
      //<rdf:Statement> 
      //  <rdf:subject rdf:resource="#metaid_0000052"/> 
      //  <rdf:predicate rdf:resource="http://biomodels.net/biology-qualifiers/occursIn"/> 
      //  <rdf:object rdf:resource="urn:miriam:obo.go:GO%3A0005764"/> 
      //  <bqbiol:isDescribedBy> 
      //    <rdf:Bag> 
      //      <rdf:li rdf:resource="urn:miriam:obo.eco:ECO%3A0000004"/> 
      //      <rdf:li rdf:resource="urn:miriam:pubmed:7017716"/> 
      //    </rdf:Bag> 
      //  </bqbiol:isDescribedBy> 
      //</rdf:Statement> 

      /* attributes */
      XMLAttributes blank_att = XMLAttributes();
      
      XMLAttributes resource_att = XMLAttributes();

      /* create the outer statement node */
      XMLTriple statement_triple = XMLTriple("Statement", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");

      XMLToken statement_token = XMLToken(statement_triple, blank_att);

      XMLNode statement = XMLNode(statement_token);

      /*create the subject node */
      XMLTriple subject_triple = XMLTriple("subject", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");
      
      resource_att.clear();
      resource_att.add("rdf:resource", "#" + s->getMetaId());
      
      XMLToken subject_token = XMLToken(subject_triple, resource_att);

      XMLNode subject = XMLNode(subject_token);


      /*create the predicate node */
      XMLTriple predicate_triple = XMLTriple("predicate", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");
      
      resource_att.clear();
      resource_att.add("rdf:resource",
        "http://biomodels.net/biology-qualifiers/occursIn");
      
      XMLToken predicate_token = XMLToken(predicate_triple, resource_att);

      XMLNode predicate = XMLNode(predicate_token);

      /*create the object node */
      XMLTriple object_triple = XMLTriple("object", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");
      
      resource_att.clear();
      resource_att.add("rdf:resource", "urn:miriam:obo.go:GO%3A0005764");
      
      XMLToken object_token = XMLToken(object_triple, resource_att);

      XMLNode object = XMLNode(object_token);

      /* create the bqbiol node */
      XMLTriple bqbiol_triple = XMLTriple("isDescribedBy", 
        "http://biomodels.net/biology-qualifiers/",
        "bqbiol");

      XMLToken bqbiol_token = XMLToken(bqbiol_triple, blank_att);

      XMLNode bqbiol = XMLNode(bqbiol_token);

      /* create the bag node */
      XMLTriple bag_triple = XMLTriple("Bag", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");

      XMLToken bag_token = XMLToken(bag_triple, blank_att);
      
      XMLNode bag = XMLNode(bag_token);

      /* create each li node and add to the bag */
      XMLTriple li_triple = XMLTriple("li", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");

      resource_att.clear();
      resource_att.add("rdf:resource", "urn:miriam:obo.eco:ECO%3A0000004");

      XMLToken li_token = XMLToken(li_triple, resource_att);
      li_token.setEnd();

      XMLNode li = XMLNode(li_token);

      bag.addChild(li);

      resource_att.clear();
      resource_att.add("rdf:resource", "urn:miriam:pubmed:7017716");
      li_token = XMLToken(li_triple, resource_att);
      li_token.setEnd();
      li = XMLNode(li_token);

      bag.addChild(li);

      /* add the bag to bqbiol */
      bqbiol.addChild(bag);

      /* add subject, predicate, object and bqbiol to statement */
      statement.addChild(subject);
      statement.addChild(predicate);
      statement.addChild(object);
      statement.addChild(bqbiol);


      /* create a top-level RDF element 
       * this will ensure correct merging
       */

      XMLNamespaces xmlns = XMLNamespaces();
      xmlns.add("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf");
      xmlns.add("http://purl.org/dc/elements/1.1/", "dc");
      xmlns.add("http://purl.org/dc/terms/", "dcterms");
      xmlns.add("http://www.w3.org/2001/vcard-rdf/3.0#", "vCard");
      xmlns.add("http://biomodels.net/biology-qualifiers/", "bqbiol");
      xmlns.add("http://biomodels.net/model-qualifiers/", "bqmodel");

      XMLTriple RDF_triple = XMLTriple("RDF", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");
  
      XMLToken RDF_token = XMLToken(RDF_triple, blank_att, xmlns);

      XMLNode annotation = XMLNode(RDF_token);

      /* add the staement node to the RDF node */     
      annotation.addChild(statement);

      s->appendAnnotation(&annotation);

      writeSBML(d, argv[2]);
    }
  }

  delete d;
  return errors;
}

