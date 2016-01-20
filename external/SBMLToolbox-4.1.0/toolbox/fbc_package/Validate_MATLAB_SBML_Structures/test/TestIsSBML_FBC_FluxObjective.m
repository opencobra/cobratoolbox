function fail = TestIsSBML_FBC_FluxObjective

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

s_l3v1_bad = struct('typecode', {'SBML_FBC_FLUXOBJETIVE'}, 'metaid', {''}, ...
  'notes', {''}, 'annotation', {''}, 'sboTerm', {''}, 'fbc_reaction', {''}, ...
    'fbc_coefficient', {''}, 'isSetfbc_coefficient', {0}, ...
    'level', {3}, 'version', {1}, 'fbc_version', {1});



s_l3v1 = struct('typecode', {'SBML_FBC_FLUXOBJECTIVE'}, 'metaid', {''}, ...
  'notes', {''}, 'annotation', {''}, 'sboTerm', {''}, 'fbc_reaction', {''}, ...
    'fbc_coefficient', {''}, 'isSetfbc_coefficient', {0}, ...
    'level', {3}, 'version', {1}, 'fbc_version', {1});

fail = TestFunction('isSBML_FBC_FluxObjective', 4, 1, s_l3v1, 3, 1, 1, 1);
fail = fail + TestFunction('isSBML_FBC_FluxObjective', 3, 1, s_l3v1, 3, 1, 1);
fail = fail + TestFunction('isSBML_FBC_FluxObjective', 3, 1, s_l3v1, 2, 4, 0);
fail = fail + TestFunction('isSBML_FBC_FluxObjective', 2, 1, s_l3v1, 3, 1);
fail = fail + TestFunction('isSBML_FBC_FluxObjective', 2, 1, s_l3v1, 2, 0);
fail = fail + TestFunction('isSBML_FBC_FluxObjective', 1, 1, s_l3v1, 1);
fail = fail + TestFunction('isValid', 1, 1, s_l3v1, 1);
fail = fail + TestFunction('isValid', 2, 1, s_l3v1, 3, 1);
fail = fail + TestFunction('isValid', 2, 1, s_l3v1, 2, 0);
fail = fail + TestFunction('isValid', 3, 1, s_l3v1, 3, 1, 1);
fail = fail + TestFunction('isValid', 3, 1, s_l3v1, 2, 4, 0);
fail = fail + TestFunction('isValid', 4, 1, s_l3v1, 3, 1, 1, 1);
fail = fail + TestFunction('isValid', 4, 1, s_l3v1, 2, 1, 1, 0);
fail = fail + TestFunction('isValid', 4, 1, s_l3v1, 3, 1, 2, 0);
fail = fail + TestFunction('isValidFBC', 1, 1, s_l3v1, 1);
fail = fail + TestFunction('isValidFBC', 2, 1, s_l3v1, 3, 1);
fail = fail + TestFunction('isValidFBC', 2, 1, s_l3v1, 2, 0);
fail = fail + TestFunction('isValidFBC', 3, 1, s_l3v1, 3, 1, 1);
fail = fail + TestFunction('isValidFBC', 3, 1, s_l3v1, 2, 4, 0);
fail = fail + TestFunction('isValidFBC', 4, 1, s_l3v1, 3, 1, 1, 1);
fail = fail + TestFunction('isValidFBC', 4, 1, s_l3v1, 2, 1, 1, 0);
fail = fail + TestFunction('isValidFBC', 4, 1, s_l3v1, 3, 1, 2, 0);
fail = fail + TestFunction('isSBML_FBC_FluxObjective', 4, 1, s_l3v1_bad, 3, 1, 1, 0);
fail = fail + TestFunction('isSBML_FBC_FluxObjective', 3, 1, s_l3v1_bad, 3, 1, 0);
fail = fail + TestFunction('isSBML_FBC_FluxObjective', 3, 1, s_l3v1_bad, 2, 4, 0);
fail = fail + TestFunction('isSBML_FBC_FluxObjective', 2, 1, s_l3v1_bad, 3, 0);
fail = fail + TestFunction('isSBML_FBC_FluxObjective', 2, 1, s_l3v1_bad, 2, 0);
fail = fail + TestFunction('isSBML_FBC_FluxObjective', 1, 1, s_l3v1_bad, 0);
fail = fail + TestFunction('isValid', 1, 1, s_l3v1_bad, 0);
fail = fail + TestFunction('isValid', 2, 1, s_l3v1_bad, 3, 0);
fail = fail + TestFunction('isValid', 2, 1, s_l3v1_bad, 2, 0);
fail = fail + TestFunction('isValid', 3, 1, s_l3v1_bad, 3, 1, 0);
fail = fail + TestFunction('isValid', 3, 1, s_l3v1_bad, 2, 4, 0);
fail = fail + TestFunction('isValid', 4, 1, s_l3v1_bad, 3, 1, 1, 0);
fail = fail + TestFunction('isValid', 4, 1, s_l3v1_bad, 2, 1, 1, 0);
fail = fail + TestFunction('isValid', 4, 1, s_l3v1_bad, 3, 1, 2, 0);
fail = fail + TestFunction('isValidFBC', 1, 1, s_l3v1_bad, 0);
fail = fail + TestFunction('isValidFBC', 2, 1, s_l3v1_bad, 3, 0);
fail = fail + TestFunction('isValidFBC', 2, 1, s_l3v1_bad, 2, 0);
fail = fail + TestFunction('isValidFBC', 3, 1, s_l3v1_bad, 3, 1, 0);
fail = fail + TestFunction('isValidFBC', 3, 1, s_l3v1_bad, 2, 4, 0);
fail = fail + TestFunction('isValidFBC', 4, 1, s_l3v1_bad, 3, 1, 1, 0);
fail = fail + TestFunction('isValidFBC', 4, 1, s_l3v1_bad, 2, 1, 1, 0);
fail = fail + TestFunction('isValidFBC', 4, 1, s_l3v1_bad, 3, 1, 2, 0);









