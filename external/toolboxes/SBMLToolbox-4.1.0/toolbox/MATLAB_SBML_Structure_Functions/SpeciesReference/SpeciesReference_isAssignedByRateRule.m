function y = SpeciesReference_isAssignedByRateRule(SBMLSpeciesReference, SBMLRules)
% y = SpeciesReference_isAssignedByRateRule(SBMLSpeciesReference, SBMLRules)
%
% Takes
%
% 1. SBMLSpeciesReference, an SBML SpeciesReference structure
% 2. SBMLRules; the array of rules from an SBML Model structure
%
% Returns
%
% y = 
%   - the index of the rateRule used to assigned value to the SpeciesReference
%   - 0 if the SpeciesReference is not assigned by rateRule 
%
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





 
y = 0;

%-------------------------------------------------------------------
% check input arguments are as expected
if (~isstruct(SBMLSpeciesReference))
    error(sprintf('%s', ...
      'argument must be an SBML SpeciesReference structure'));
end;
 
[sbmlLevel, sbmlVersion] = GetLevelVersion(SBMLSpeciesReference);

if (~isSBML_SpeciesReference(SBMLSpeciesReference, sbmlLevel, sbmlVersion))
  error('SpeciesReference_isAssignedByRateRule(SBMLSpeciesReference, SBMLRules)\n%s', ...
    'first argument must be an SBMLSpeciesReference structure');
elseif (sbmlLevel < 3)
  error('SpeciesReference cannot be assigned by rules in SBML level %u', sbmlLevel);
end;


NumRules = length(SBMLRules);

if (NumRules < 1)
    error('SpeciesReference_isAssignedByRateRule(SBMLSpeciesReference, SBMLRules)\n%s', ...
      'SBMLRule structure is empty');
else
    for i = 1:NumRules
        if (~isSBML_Rule(SBMLRules(i), sbmlLevel, sbmlVersion))
            error('SpeciesReference_isAssignedByRateRule(SBMLSpeciesReference, SBMLRules)\n%s', ...
              'second argument must be an array of SBMLRule structures');
        end;
    end;
end;

%--------------------------------------------------------------------------

% loop through each rule and check whether the SpeciesReference is assigned by it
%determine the name or id of the SpeciesReference
name = SBMLSpeciesReference.id;

for i = 1:NumRules
    if (strcmp(SBMLRules(i).typecode, 'SBML_RATE_RULE'))
        if (strcmp(SBMLRules(i).variable, name))
            % once found return as cannot occur more than once
            y = i;
            return;
        end;
    end;
end;

