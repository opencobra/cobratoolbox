function rule = Model_getAssignmentRuleByVariable(SBMLModel, variable)
% assignmentRule = Model_getAssignmentRuleByVariable(SBMLModel, variable)
%
% Takes
%
% 1. SBMLModel, an SBML Model structure
% 2. variable; a string representing the variable of SBML AssignmentRule structure
%
% Returns
%
% 1. the SBML AssignmentRule structure that has this variable
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



























% check that input is correct
if (~isValidSBML_Model(SBMLModel))
    error(sprintf('%s\n%s', 'Model_getAssignmentRuleByVariable(SBMLModel, variable)', 'first argument must be an SBML model structure'));
elseif (~ischar(variable))
    error(sprintf('%s\n%s', 'Model_getAssignmentRuleByVariable(SBMLModel, variable)', 'second argument must be a string'));
end;

rule = [];

% get level and version
sbmlLevel = SBMLModel.SBML_level;
sbmlVersion = SBMLModel.SBML_version;

for i = 1:length(SBMLModel.rule)
  if (isSBML_AssignmentRule(SBMLModel.rule(i), sbmlLevel, sbmlVersion))
    if (strcmp(variable, AssignmentRule_getVariable(SBMLModel.rule(i))))
      rule = SBMLModel.rule(i);
        break;
    end;
end;
  end;

%if level and version fields are not on returned object add them
if ~isempty(rule) && ~isfield(rule, 'level')
  rule.level = SBMLModel.SBML_level;
  rule.version = SBMLModel.SBML_version;
end;
