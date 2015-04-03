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

#include <stdio.h>
#include <sbml/SBMLTypes.h>

#include <sbml/annotation/CVTerm.h>
#include <sbml/xml/XMLTriple.h>

int
main (int argc, char *argv[])
{

  SBMLDocument_t* d;
  Model_t* m;
  unsigned int  errors, n;
  Species_t *s;

  if (argc != 3)
  {
    printf("\n"
         "  usage: addingEvidenceCodes_2 <input-filename> <output-filename>\n"
         "  Adds controlled vocabulary term to a species\n"
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
  
    m = SBMLDocument_getModel(d);
    n =  Model_getNumSpecies(m);
    
    if (n <= 0)
    {
     printf( "Model has no reactions.\n Cannot add CV terms\n");
    }
    else
    {
      CVTerm_t *cv1;
      XMLAttributes_t* blank_att;
      XMLAttributes_t* resource_att;
      XMLTriple_t* statement_triple;
      XMLToken_t* statement_token;

      XMLNode_t* statement;
      XMLTriple_t* subject_triple ;
      XMLToken_t* subject_token;
      XMLNode_t* subject;
      XMLTriple_t* predicate_triple;
      XMLToken_t* predicate_token;
      XMLNode_t* predicate;
      XMLTriple_t* object_triple;
      XMLToken_t* object_token;
      XMLNode_t* object;
      XMLTriple_t* bqbiol_triple;
      XMLToken_t* bqbiol_token;
      XMLNode_t* bqbiol;
      XMLTriple_t* bag_triple;

      XMLToken_t* bag_token;
      XMLNode_t* bag;
      XMLTriple_t* li_triple;
      XMLToken_t* li_token;

      XMLNode_t* li;
      XMLNamespaces_t* xmlns;
      XMLTriple_t* RDF_triple;
      XMLToken_t* RDF_token;
      XMLNode_t* annotation;

      s = Model_getSpecies(m ,0);

      /* check that the species has a metaid
       * no CVTerms will be added if there is no metaid to reference
       */
      if (!SBase_isSetMetaId((SBase_t*)s))
        SBase_setMetaId((SBase_t*)s, "metaid_0000052");

      cv1 = CVTerm_createWithQualifierType(BIOLOGICAL_QUALIFIER);
      CVTerm_setBiologicalQualifierType(cv1, BQB_OCCURS_IN);
      CVTerm_addResource(cv1, "urn:miriam:obo.go:GO%3A0005764");

      SBase_addCVTerm((SBase_t*)s, cv1);

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
      blank_att = XMLAttributes_create();
      
      resource_att = XMLAttributes_create();

      /* create the outer statement node */
      statement_triple = XMLTriple_createWith("Statement", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");

      statement_token = XMLToken_createWithTripleAttr (statement_triple, blank_att);
      statement = XMLNode_createFromToken (statement_token);

      /*create the subject node */
      subject_triple = XMLTriple_createWith ("subject", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");
      
      XMLAttributes_clear(resource_att);      
      XMLAttributes_add(resource_att, "rdf:resource", SBase_getMetaId((SBase_t*)s));
      
      
      subject_token = XMLToken_createWithTripleAttr (subject_triple, resource_att);
      
      subject = XMLNode_createFromToken (subject_token);


      /*create the predicate node */      
      predicate_triple = XMLTriple_createWith ("predicate", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");
      
      XMLAttributes_clear(resource_att);      
      XMLAttributes_add(resource_att, "rdf:resource", 
        "http://biomodels.net/biology-qualifiers/occursIn");
      

      predicate_token = XMLToken_createWithTripleAttr (predicate_triple, resource_att);

      
      predicate = XMLNode_createFromToken (predicate_token);

      /*create the object node */
      object_triple = XMLTriple_createWith("object", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");
      
      XMLAttributes_clear(resource_att);      
      XMLAttributes_add(resource_att, "rdf:resource", 
        "urn:miriam:obo.go:GO%3A0005764");
      
      object_token = XMLToken_createWithTripleAttr(object_triple, resource_att);

      object = XMLNode_createFromToken(object_token);

      /* create the bqbiol node */
      bqbiol_triple = XMLTriple_createWith("isDescribedBy", 
        "http://biomodels.net/biology-qualifiers/",
        "bqbiol");

      bqbiol_token = XMLToken_createWithTripleAttr(bqbiol_triple, blank_att);

      bqbiol = XMLNode_createFromToken (bqbiol_token);

      /* create the bag node */
      bag_triple = XMLTriple_createWith("Bag", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");
      bag_token = XMLToken_createWithTripleAttr(bag_triple, blank_att);
      
      bag = XMLNode_createFromToken(bag_token);

      /* create each li node and add to the bag */
      li_triple = XMLTriple_createWith("li", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");

      XMLAttributes_clear(resource_att);      
      XMLAttributes_add(resource_att, "rdf:resource", 
        "urn:miriam:obo.eco:ECO%3A0000004");

      li_token = XMLToken_createWithTripleAttr(li_triple, resource_att);
      XMLToken_setEnd(li_token);
      
      li = XMLNode_createFromToken(li_token);

      XMLNode_addChild(bag, li);
      
      XMLAttributes_clear(resource_att);      
      XMLAttributes_add(resource_att, "rdf:resource", 
       "urn:miriam:pubmed:7017716");
      li_token = XMLToken_createWithTripleAttr(li_triple, resource_att);
      XMLToken_setEnd(li_token);

      li = XMLNode_createFromToken(li_token);

      XMLNode_addChild(bag, li);

      /* add the bag to bqbiol */
      XMLNode_addChild(bqbiol, bag);
      

      /* add subject, predicate, object and bqbiol to statement */
      XMLNode_addChild(statement, subject);
      XMLNode_addChild(statement, predicate);
      XMLNode_addChild(statement, object);
      XMLNode_addChild(statement, bqbiol);
      

      /* create a top-level RDF element 
       * this will ensure correct merging
       */

      xmlns = XMLNamespaces_create();
      XMLNamespaces_add(xmlns, "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf");
      XMLNamespaces_add(xmlns, "http://purl.org/dc/elements/1.1/", "dc");
      XMLNamespaces_add(xmlns, "http://purl.org/dc/terms/", "dcterms");
      XMLNamespaces_add(xmlns, "http://www.w3.org/2001/vcard-rdf/3.0#", "vCard");
      XMLNamespaces_add(xmlns, "http://biomodels.net/biology-qualifiers/", "bqbiol");
      XMLNamespaces_add(xmlns, "http://biomodels.net/model-qualifiers/", "bqmodel");

      RDF_triple = XMLTriple_createWith("RDF", 
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        "rdf");
  
      RDF_token = XMLToken_createWithTripleAttrNS(RDF_triple, blank_att, xmlns);

      annotation = XMLNode_createFromToken(RDF_token);

      /* add the staement node to the RDF node */   
      XMLNode_addChild(annotation, statement);      

      SBase_appendAnnotation((SBase_t*)s, annotation);

      writeSBML(d, argv[2]);
    }
  }

  SBMLDocument_free(d);
  return errors;
}

