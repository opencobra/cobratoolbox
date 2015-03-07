#!/usr/bin/env perl
# -*-Perl-*-
##
## @file    addCustomValidator.pl
## @brief   Example creating a custom validator to be called during validation
## @author  Frank T. Bergmann
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
## 
## NOTE: This example is currently not working as SWIG does not allow for perl 
##       directos yet ... otherwise it would be working as described below.
## 

use LibSBML;
no strict;
##  
## Declares a custom validator to be called. This allows you to validate 
## any aspect of an SBML Model that you want to be notified about. You could 
## use this to notify your application that a model contains an unsupported 
## feature of SBML (either as warning). 
## 
## In this example the validator will go through the model and test for the 
## presence of 'fast' reactions and algebraic rules. If either is used a 
## warning will be added to the error log. 
## 
{
package MyCustomValidator;
   @ISA = (LibSBML::SBMLValidator);
   sub new {
     my $class = shift; 
     bless \$class => $class
   }
   sub clone {
     return new MyCustomValidator()	
   }
   sub validate{
     my $self = shift;
     # if we don't have a model we don't apply this validator.
     if ($self->getDocument() == undef or $self->getModel() == undef) {
          return 0;
     }
		
     # if we have no rules and reactions we don't apply this validator either
     if ($self->getModel()->getNumReactions() == 0 and $self->getModel()->getNumRules() == 0) {   
          return 0;
     }
		
     $numErrors = 0;
     # test for algebraic rules
     for ($i=0; $i< $self->getModel()->getNumRules();$i++) {
          if ($self->getModel()->getRule($i)->getTypeCode() == $LibSBML::SBML_ALGEBRAIC_RULE) {
               $self->getErrorLog()->add(new LibSBML::SBMLError(99999, 3, 1,
                  "This model uses algebraic rules, however this application does not support them.",
                  0, 0,
                  $LibSBML::LIBSBML_SEV_WARNING, # or LIBSBML_SEV_ERROR if you want to stop
                  $LibSBML::LIBSBML_CAT_SBML # or whatever category you prefer
                  ));
                $numErrors = $numErrors + 1;
	  }
     }

     # test for fast reactions
     for ($i=0; $i < $self->getModel()->getNumReactions(); $i++) {
         # test whether value is set, and true
	 if ($self->getModel()->getReaction($i)->isSetFast() and  $self->getModel()->getReaction($i)->getFast()) {
             self.getErrorLog().add(new LibSBML::SBMLError(99999, 3, 1,
                  "This model uses fast reactions, however this application does not support them.",
                  0, 0,
                  $LibSBML::LIBSBML_SEV_WARNING, # or LIBSBML_SEV_ERROR if you want to stop
                  $LibSBML::LIBSBML_CAT_SBML # or whatever category you prefer
                  ));
              $numErrors = $numErrors + 1;
         }
     }
     return numErrors;
   }
}

if ($#ARGV != 0) {
  print "Usage: addCustomValidator filename\n";
  exit 1;
}


# read the file name
$document = LibSBML::readSBML($ARGV[0]);

# add a custom validator
$document->addValidator(new MyCustomValidator());

# check consistency like before
$numErrors = $document->checkConsistency();

# print errors and warnings
$document->printErrors();

# return number of errors
exit $numErrors;

