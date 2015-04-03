#!/usr/bin/env ruby
#
# @file    convertSBML.rb
# @brief   Converts SBML documents between levels 
# @author  Alex Gutteridge (Ruby conversion of examples/c/convertSBML.c)
# @author  Ben Bornstein
# @author  Michael Hucka
#
#
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

require 'libSBML'
     
latest_level   = LibSBML::SBMLDocument::getDefaultLevel
latest_version = LibSBML::SBMLDocument::getDefaultVersion               

if ARGV.size != 2
  puts "Usage: ruby convertSBML.rb input-filename output-filename"
  puts "This program will attempt to convert a model either to"
  puts "SBML Level #{latest_level} Version #{latest_version} (if the model is not already) or, if"
  puts "the model is already expressed in Level #{latest_level} Version #{latest_version}, this"
  puts "program will attempt to convert the model to Level 1 Version 2."
  exit(1)
end

d = LibSBML::readSBML(ARGV[0])

if d.getNumErrors > 0
  puts "Encountered the following SBML error(s)"
  d.printErrors
  puts "Conversion skipped. Please correct the problems above first"
  exit d.getNumErrors
end
                                    
success = false

if d.getLevel < latest_level || d.getVersion < latest_version
  puts "Attempting to convert model to SBML Level #{latest_level} Version #{latest_version}"
  success = d.setLevelAndVersion(latest_level,latest_version)    
else
  puts "Attempting to convert model to SBML Level 1 Version 2"
  success = d.setLevelAndVersion(1,2)
end

if not success
  puts "Unable to perform conversion due to the following:"  
  d.printErrors
  puts "Conversion skipped.  Either libSBML does not (yet) have"
  puts "ability to convert this model, or (automatic) conversion"
  puts "is not possible in this case."
elsif d.getNumErrors > 0
  puts "Information may have been lost in conversion; but a valid model"
  puts "was produced by the conversion.\nThe following information "
  puts "was provided:"
  d.printErrors
  LibSBML::writeSBML(d, ARGV[1]);
else
  puts "Conversion completed."
  LibSBML::writeSBML(d, ARGV[1])
end

