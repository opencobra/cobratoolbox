function fail = TestIsSBML_Species

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




s_l1 = struct('typecode', {'SBML_SPECIES'}, 'notes', {''}, 'annotation', {''},'name', {''}, 'compartment', {''}, ...
    'initialAmount', {''}, 'units', {''}, 'boundaryCondition', {''}, 'charge', {''}, 'isSetInitialAmount', {''}, ...
    'isSetCharge', {''});

s_l2 = struct('typecode', {'SBML_SPECIES'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''},'name', {''}, 'id', {''}, ...
    'compartment', {''}, 'initialAmount', {''}, 'initialConcentration', {''}, 'substanceUnits', {''}, ...
    'spatialSizeUnits', {''}, 'hasOnlySubstanceUnits', {''}, 'boundaryCondition', {''}, 'charge', {''}, ...
    'constant', {''}, 'isSetInitialAmount', {''}, 'isSetInitialConcentration', {''}, 'isSetCharge', {''});

s_l2v2 = struct('typecode', {'SBML_SPECIES'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''},'name', {''}, ...
    'id', {''}, 'speciesType', {''}, 'compartment', {''}, 'initialAmount', {''}, 'initialConcentration', {''}, ...
    'substanceUnits', {''}, 'spatialSizeUnits', {''}, 'hasOnlySubstanceUnits', {''}, 'boundaryCondition', {''}, ...
    'charge', {''}, 'constant', {''}, 'isSetInitialAmount', {''}, 'isSetInitialConcentration', {''}, 'isSetCharge', {''});

s_l2v3 = struct('typecode', {'SBML_SPECIES'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''}, 'sboTerm', {''}, 'name', {''}, ...
    'id', {''}, 'speciesType', {''}, 'compartment', {''}, 'initialAmount', {''}, 'initialConcentration', {''}, ...
    'substanceUnits', {''}, 'hasOnlySubstanceUnits', {''}, 'boundaryCondition', {''}, ...
    'charge', {''}, 'constant', {''}, 'isSetInitialAmount', {''}, 'isSetInitialConcentration', {''}, 'isSetCharge', {''});

s_l3v1 = struct('typecode', {'SBML_SPECIES'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''}, 'sboTerm', {''}, 'name', {''}, ...
    'id', {''}, 'compartment', {''}, 'initialAmount', {''}, 'initialConcentration', {''}, ...
    'substanceUnits', {''}, 'hasOnlySubstanceUnits', {''}, 'boundaryCondition', {''}, ...
    'constant', {''}, 'isSetInitialAmount', {''}, 'isSetInitialConcentration', {''}, 'conversionFactor', {''});

fail = TestFunction('isSBML_Species', 2, 1, s_l1, 1, 1);
fail = fail + TestFunction('isSBML_Species', 3, 1, s_l1, 1, 1, 1);
fail = fail + TestFunction('isSBML_Species', 3, 1, s_l1, 1, 2, 1);
fail = fail + TestFunction('isSBML_Species', 2, 1, s_l2, 2, 1);
fail = fail + TestFunction('isSBML_Species', 3, 1, s_l2, 2, 1, 1);
fail = fail + TestFunction('isSBML_Species', 3, 1, s_l2v2, 2, 2, 1);
fail = fail + TestFunction('isSBML_Species', 3, 1, s_l2v3, 2, 3, 1);
fail = fail + TestFunction('isSBML_Species', 3, 1, s_l2v3, 2, 4, 1);
fail = fail + TestFunction('isSBML_Species', 3, 1, s_l3v1, 3, 1, 1);
fail = fail + TestFunction('isValid', 1, 1, s_l1, 1);
fail = fail + TestFunction('isValid', 1, 1, s_l2, 1);
fail = fail + TestFunction('isValid', 1, 1, s_l2v2, 1);
fail = fail + TestFunction('isValid', 1, 1, s_l2v3, 1);
fail = fail + TestFunction('isValid', 1, 1, s_l3v1, 1);










