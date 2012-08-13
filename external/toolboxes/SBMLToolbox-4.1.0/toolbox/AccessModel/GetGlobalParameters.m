function varargout = GetGlobalParameters(SBMLModel)
% [names, values] = GetGlobalParameters(SBMLModel)
% 
% Takes
% 
% 1. SBMLModel, an SBML Model structure
% 
% Returns 
% 
% 1. an array of strings representing the identifiers of 
%                all global parameters within the model 
% 2. an array of the values of each parameter
% 
% *NOTE:* the value returned will be (in order)
%
%   - determined from assignmentRules/initialAssignments where appropriate
%   - the attribute 'value' for the given parameter
%   - NaN, if the value is not specified in any way within the model

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
    error('GetGlobalParameters(SBMLModel)\n%s', 'input must be an SBMLModel structure');
end;

%------------------------------------------------------------
% determine the number of parameters within the model
NumParams = length(SBMLModel.parameter);

%------------------------------------------------------------
% loop through the list of parameters
for i = 1:NumParams
    
    %determine the name or id of the parameter
    if (SBMLModel.SBML_level == 1)
        name = SBMLModel.parameter(i).name;
    else
        if (isempty(SBMLModel.parameter(i).id))
            name = SBMLModel.parameter(i).name;
        else
            name = SBMLModel.parameter(i).id;
        end;
    end;
    
    % save into an array of character names
    CharArray{i} = name;
    
    % put the value into the array
    Values(i) = SBMLModel.parameter(i).value;
    
   % might be an initial assignment in l2v2
    if ((SBMLModel.SBML_level == 2 && SBMLModel.SBML_version > 1) ...
        || SBMLModel.SBML_level == 3)
      IA = Model_getInitialAssignmentBySymbol(SBMLModel, name);
      if (~isempty(IA))
        % remove this from the substtution
        newSBMLModel = SBMLModel;
        newSBMLModel.parameter(i) = [];
        for fd = 1:Model_getNumFunctionDefinitions(SBMLModel)
          newFormula = SubstituteFunction(IA.math, Model_getFunctionDefinition(SBMLModel, fd));
          if (~isempty(newFormula))
           IA.math = newFormula;
          end;
        end;
        Values(i) = Substitute(IA.math, newSBMLModel);  
      end;
    end;
     % might be set by assignment rule
    AR = Model_getAssignmentRuleByVariable(SBMLModel, name);
    if (~isempty(AR))
        newSBMLModel = SBMLModel;
        newSBMLModel.parameter(i) = [];
        for fd = 1:Model_getNumFunctionDefinitions(SBMLModel)
          newFormula = SubstituteFunction(AR.formula, Model_getFunctionDefinition(SBMLModel, fd));
          if (~isempty(newFormula))
           AR.formula = newFormula;
          end;
        end;
        Values(i) = Substitute(AR.formula, newSBMLModel);  
    end;
end;

%--------------------------------------------------------------------------
% assign output

if (NumParams ~= 0)
    varargout{1} = CharArray;
    varargout{2} = Values;
else
    varargout{1} = [];
    varargout{2} = [];
end;
