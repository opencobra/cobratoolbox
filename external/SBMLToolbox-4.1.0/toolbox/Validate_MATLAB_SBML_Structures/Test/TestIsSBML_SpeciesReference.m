function fail = TestIsSBML_SpeciesReference

%<!---------------------------------------------------------------------------
% This file is part of SBMLToolbox.  Please visit http://sbml.org for more
% information about SBML, and the latest version of SBMLToolbox.
%
% Copyright (C) 2009-2012 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. EMBL European Bioinformatics Institute (EBML-EBI), Hinxton, UK
%
% Copyright (C) 2006-2008 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA
%     2. University of Hertfordshire, Hatfield, UK
%
% Copyright (C) 2003-2005 jointly by the following organizations: 
%     1. California Institute of Technology, Pasadena, CA, USA 
%     2. Japan Science and Technology Agency, Japan
%     3. University of Hertfordshire, Hatfield, UK
%
% SBMLToolbox is free software; you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation.  A copy of the license agreement is provided
% in the file named "LICENSE.txt" included with this software distribution.
%----------------------------------------------------------------------- -->




sr_l1 = struct('typecode', {'SBML_SPECIES_REFERENCE'}, 'notes', {''}, 'annotation', {''},'species', ...
    {''}, 'stoichiometry', {''}, 'denominator', {''});

sr_l2 = struct('typecode', {'SBML_SPECIES_REFERENCE'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''},'species', ...
    {''}, 'stoichiometry', {''}, 'denominator', {''}, 'stoichiometryMath', {''});

sr_l2v2 = struct('typecode', {'SBML_SPECIES_REFERENCE'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''},'species', ...
    {''}, 'id', {''}, 'name', {''}, 'sboTerm', {''}, 'stoichiometry', {''}, 'stoichiometryMath', {''});

sr_l3v1 = struct('typecode', {'SBML_SPECIES_REFERENCE'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''},'species', ...
    {''}, 'id', {''}, 'name', {''}, 'sboTerm', {''}, 'stoichiometry', {''}, 'constant', {''}, 'isSetStoichiometry', {''});

fail = TestFunction('isSBML_SpeciesReference', 2, 1, sr_l1, 1, 1);
fail = fail + TestFunction('isSBML_SpeciesReference', 3, 1, sr_l1, 1, 1, 1);
fail = fail + TestFunction('isSBML_SpeciesReference', 3, 1, sr_l1, 1, 2, 1);
fail = fail + TestFunction('isSBML_SpeciesReference', 2, 1, sr_l2, 2, 1);
fail = fail + TestFunction('isSBML_SpeciesReference', 3, 1, sr_l2, 2, 1, 1);
fail = fail + TestFunction('isSBML_SpeciesReference', 3, 1, sr_l2v2, 2, 2, 1);
fail = fail + TestFunction('isSBML_SpeciesReference', 3, 1, sr_l2v2, 2, 3, 1);
fail = fail + TestFunction('isSBML_SpeciesReference', 3, 1, sr_l2v2, 2, 4, 1);
fail = fail + TestFunction('isSBML_SpeciesReference', 3, 1, sr_l3v1, 3, 1, 1);
fail = fail + TestFunction('isValid', 1, 1, sr_l1, 1);
fail = fail + TestFunction('isValid', 1, 1, sr_l2, 1);
fail = fail + TestFunction('isValid', 1, 1, sr_l2v2, 1);
fail = fail + TestFunction('isValid', 1, 1, sr_l3v1, 1);










