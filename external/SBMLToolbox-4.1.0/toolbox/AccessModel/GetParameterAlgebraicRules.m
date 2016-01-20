function [Parameter, AlgebraicRules] = GetParameterAlgebraicRules(SBMLModel)
% [parameters, algebraicRules] = GetParameterAlgebraicRules(SBMLModel)
% 
% Takes
% 
% 1. SBMLModel, an SBML Model structure
% 
% Returns 
% 
% 1. an array of strings representing the identifiers of all parameters
% 2. an array of 
%
%  - the character representation of each algebraic
%    rule the parameter appears in 
%  - '0' if the particular parameter is not in an algebraic rule
%
% *EXAMPLE:*
%
%      model has 3 parameters (k1, k2, k3) 
%            and 2 algebraic rules with formula 'k2+7' and 'k2-k3'
% 
%           [parameters, algebraicRules] = GetParameterAlgebraicRules(model)
%                   
%                    parameters     = ['k1', 'k2', 'k3']
%                    algebraicRules = {'0', ['k2+7', 'k2-k3'], ['k2-k3']}
%
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


% check input is an SBML model
if (~isValidSBML_Model(SBMLModel))
    error('GetParameterAlgebraicRules(SBMLModel)\n%s', 'input must be an SBMLModel structure');
end;

%--------------------------------------------------------------

% get information from the model
Parameter = GetGlobalParameters(SBMLModel);
NumberParameter = length(SBMLModel.parameter);
Rules = Model_getListOfAlgebraicRules(SBMLModel);
NumRules = Model_getNumAlgebraicRules(SBMLModel);

for i = 1:NumberParameter
    output = '';


    if (NumRules > 0)
        %determine which rules it occurs within
        RuleNo = Parameter_isInAlgebraicRule(SBMLModel.parameter(i), Rules);

        for j = 1:length(RuleNo)
            if (RuleNo(j) > 0)
                output{j} = Rules(RuleNo(j)).formula;
            end;
        end;
    end;



    % finished looking for this Parameter
    % record rate law and loop to next Parameter
    % rate = 0 if no law found
    if (isempty(output))
        AlgebraicRules{i} = '0';
    else
        AlgebraicRules{i} = output;
    end;
end; % for NumParameter
