#!/usr/bin/env python
##
## \file    addingEvidenceCodes_2.py
## \brief   adds evidence codes to a species in a model
## \author  Sarah Keating
##
## <!--------------------------------------------------------------------------
## This sample program is distributed under a different license than the rest
## of libSBML.  This program uses the open-source MIT license, as follows:
##
## Copyright (c) 2013-2014 by the California Institute of Technology
## (California, USA), the European Bioinformatics Institute (EMBL-EBI, UK)
## and the University of Heidelberg (Germany), with support from the National
## Institutes of Health (USA) under grant R01GM070923.  All rights reserved.
##
## Permission is hereby granted, free of charge, to any person obtaining a
## copy of this software and associated documentation files (the "Software"),
## to deal in the Software without restriction, including without limitation
## the rights to use, copy, modify, merge, publish, distribute, sublicense,
## and/or sell copies of the Software, and to permit persons to whom the
## Software is furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
## THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
## FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
## DEALINGS IN THE SOFTWARE.
##
## Neither the name of the California Institute of Technology (Caltech), nor
## of the European Bioinformatics Institute (EMBL-EBI), nor of the University
## of Heidelberg, nor the names of any contributors, may be used to endorse
## or promote products derived from this software without specific prior
## written permission.
## ------------------------------------------------------------------------ -->

import sys
import os.path
from libsbml import *

def main (args):
  """usage: addingEvidenceCodes_2 <input-filename> <output-filename>
     Adds controlled vocabulary term to a species
  """
  if len(args) != 3:
    print(main.__doc__)
    sys.exit(2)

  d = readSBML(args[1]);
  errors = d.getNumErrors();
  
  if (errors > 0):
    print("Read Error(s):\n");
    d.printErrors();
    
    print("Correct the above and re-run.\n");
  else:
    n = d.getModel().getNumSpecies();
    if (n <= 0):
        print("Model has no species.\n Cannot add CV terms\n");
    else:
        s = d.getModel().getSpecies(0);

        # check that the species has a metaid
        # no CVTerms will be added if there is no metaid to reference
        # 
        if (not s.isSetMetaId()):
            s.setMetaId("metaid_0000052");

        cv1 = CVTerm(BIOLOGICAL_QUALIFIER);
        cv1.setBiologicalQualifierType(BQB_OCCURS_IN);
        cv1.addResource("urn:miriam:obo.go:GO%3A0005764");

        s.addCVTerm(cv1);

        # now create the additional annotation

        # <rdf:Statement> 
        #   <rdf:subject rdf:resource="#metaid_0000052"/> 
        #   <rdf:predicate rdf:resource="http://biomodels.net/biology-qualifiers/occursIn"/> 
        #   <rdf:object rdf:resource="urn:miriam:obo.go:GO%3A0005764"/> 
        #   <bqbiol:isDescribedBy> 
        #     <rdf:Bag> 
        #       <rdf:li rdf:resource="urn:miriam:obo.eco:ECO%3A0000004"/> 
        #       <rdf:li rdf:resource="urn:miriam:pubmed:7017716"/> 
        #     </rdf:Bag> 
        #   </bqbiol:isDescribedBy> 
        # </rdf:Statement> 

        # attributes
        blank_att = XMLAttributes();

        resource_att = XMLAttributes();

        #  create the outer statement node 
        statement_triple = XMLTriple("Statement",
                                               "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                               "rdf");

        statement_token = XMLToken(statement_triple, blank_att);

        statement = XMLNode(statement_token);

        # create the subject node
        subject_triple = XMLTriple("subject",
                                             "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                             "rdf");

        resource_att.clear();
        resource_att.add("rdf:resource", "#" + s.getMetaId());

        subject_token = XMLToken(subject_triple, resource_att);

        subject = XMLNode(subject_token);


        #create the predicate node 
        predicate_triple = XMLTriple("predicate",
                                               "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                               "rdf");

        resource_att.clear();
        resource_att.add("rdf:resource",
                         "http://biomodels.net/biology-qualifiers/occursIn");

        predicate_token = XMLToken(predicate_triple, resource_att);

        predicate = XMLNode(predicate_token);

        #create the object node 
        object_triple = XMLTriple("object",
                                            "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                            "rdf");

        resource_att.clear();
        resource_att.add("rdf:resource", "urn:miriam:obo.go:GO%3A0005764");

        object_token = XMLToken(object_triple, resource_att);

        object_ = XMLNode(object_token);

        # create the bqbiol node 
        bqbiol_triple = XMLTriple("isDescribedBy",
                                            "http://biomodels.net/biology-qualifiers/",
                                            "bqbiol");

        bqbiol_token = XMLToken(bqbiol_triple, blank_att);

        bqbiol = XMLNode(bqbiol_token);

        # create the bag node 
        bag_triple = XMLTriple("Bag",
                                         "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                         "rdf");

        bag_token = XMLToken(bag_triple, blank_att);

        bag = XMLNode(bag_token);

        # create each li node and add to the bag 
        li_triple = XMLTriple("li",
                                        "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                        "rdf");

        resource_att.clear();
        resource_att.add("rdf:resource", "urn:miriam:obo.eco:ECO%3A0000004");

        li_token = XMLToken(li_triple, resource_att);
        li_token.setEnd();

        li = XMLNode(li_token);

        bag.addChild(li);

        resource_att.clear();
        resource_att.add("rdf:resource", "urn:miriam:pubmed:7017716");
        li_token = XMLToken(li_triple, resource_att);
        li_token.setEnd();
        li = XMLNode(li_token);

        bag.addChild(li);

        # add the bag to bqbiol 
        bqbiol.addChild(bag);

        # add subject, predicate, object and bqbiol to statement 
        statement.addChild(subject);
        statement.addChild(predicate);
        statement.addChild(object_);
        statement.addChild(bqbiol);


        # create a top-level RDF element 
        # this will ensure correct merging
        # 

        xmlns = XMLNamespaces();
        xmlns.add("http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdf");
        xmlns.add("http://purl.org/dc/elements/1.1/", "dc");
        xmlns.add("http://purl.org/dc/terms/", "dcterms");
        xmlns.add("http://www.w3.org/2001/vcard-rdf/3.0#", "vCard");
        xmlns.add("http://biomodels.net/biology-qualifiers/", "bqbiol");
        xmlns.add("http://biomodels.net/model-qualifiers/", "bqmodel");

        RDF_triple = XMLTriple("RDF",
                                         "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
                                         "rdf");

        RDF_token = XMLToken(RDF_triple, blank_att, xmlns);

        annotation = XMLNode(RDF_token);

        # add the staement node to the RDF node 
        annotation.addChild(statement);

        s.appendAnnotation(annotation);

        writeSBML(d, args[2]);

  return errors;

if __name__ == '__main__':
  main(sys.argv)  
