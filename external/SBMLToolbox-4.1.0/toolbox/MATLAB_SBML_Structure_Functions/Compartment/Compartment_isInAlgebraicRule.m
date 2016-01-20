function y = Compartment_isInAlgebraicRule(SBMLCompartment, SBMLRules)
% y = Compartment_isInAlgebraicRule(SBMLCompartment, SBMLRules)
%
% Takes
%
% 1. SBMLCompartment, an SBML Compartment structure
% 2. SBMLRules; the array of rules from an SBML Model structure
%
% Returns
%
% y = 
%   - an array of the indices of any algebraicRules the id of the Compartment appears in 
%   - 0 if the Compartment appears in no algebraicRules 
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

if (~isstruct(SBMLCompartment))
    error(sprintf('%s', ...
      'argument must be an SBML Compartment structure'));
end;
 
[sbmlLevel, sbmlVersion] = GetLevelVersion(SBMLCompartment);

if (~isSBML_Compartment(SBMLCompartment, sbmlLevel, sbmlVersion))
  error('Compartment_isInAlgebraicRule(SBMLCompartment, SBMLRules)\n%s', ...
    'first argument must be an SBMLCompartment structure');
end;


NumRules = length(SBMLRules);

if (NumRules < 1)
    error('Compartment_isInAlgebraicRule(SBMLCompartment, SBMLRules)\n%s', ...
      'SBMLRule structure is empty');
else
    for i = 1:NumRules
        if (~isSBML_Rule(SBMLRules(i), sbmlLevel, sbmlVersion))
            error('Compartment_isInAlgebraicRule(SBMLCompartment, SBMLRules)\n%s', ...
              'second argument must be an array of SBMLRule structures');
        end;
    end;
end;

%--------------------------------------------------------------------------

% loop through each rule and check whether the Compartment occurs
%determine the name or id of the Compartment
if (sbmlLevel == 1)
    name = SBMLCompartment.name;
else
    if (isempty(SBMLCompartment.id))
        name = SBMLCompartment.name;
    else
        name = SBMLCompartment.id;
    end;
end;

y = [];
for i = 1:NumRules
    index = matchName(SBMLRules(i).formula, name);
    if (~isempty(index) && strcmp(SBMLRules(i).typecode, 'SBML_ALGEBRAIC_RULE'))
        y = [y;i];
    end;
end;

if isempty(y)
  y = 0;
end;

