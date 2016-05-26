function fail = TestIsSBML_LocalParameter

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




p_l3 = struct('typecode', {'SBML_LOCAL_PARAMETER'}, 'metaid', {''}, 'notes', {''}, 'annotation', {''},'name', {''}, ...
    'id', {''}, 'value', {''}, 'units', {''}, 'sboTerm', {''}, 'isSetValue', {''});

fail = TestFunction('isSBML_LocalParameter', 2, 1, p_l3, 1, 0);
fail = fail + TestFunction('isSBML_LocalParameter', 3, 1, p_l3, 1, 1, 0);
fail = fail + TestFunction('isSBML_LocalParameter', 3, 1, p_l3, 1, 2, 0);
fail = fail + TestFunction('isSBML_LocalParameter', 2, 1, p_l3, 2, 0);
fail = fail + TestFunction('isSBML_LocalParameter', 3, 1, p_l3, 2, 1, 0);
fail = fail + TestFunction('isSBML_LocalParameter', 3, 1, p_l3, 2, 2, 0);
fail = fail + TestFunction('isSBML_LocalParameter', 3, 1, p_l3, 2, 3, 0);
fail = fail + TestFunction('isSBML_LocalParameter', 3, 1, p_l3, 2, 4, 0);
fail = fail + TestFunction('isSBML_LocalParameter', 3, 1, p_l3, 3, 1, 1);
fail = fail + TestFunction('isValid', 1, 1, p_l3, 1);










