function model = changeCOBRAVariable(model, variableID, varargin)
% Modify an existing COBRA variable by providing new settings for the
% variable to update existing settings.
% USAGE:
%    model = changeCOBRAVariable(model, variableID, varargin)
%
% INPUTS:
%    model:             model structure
%    variableID:        The ID of the variable (or the index in the
%                       evars field) 
% 
% OPTIONAL INPUTS:
%    varargin:      
%                   * lb:               the lower bound of the variable
%                   * ub:               the upper bound of the variable
%                   * c:                the objective coefficient of the variable
%                   * Name:             The new, descriptive name of the variable.
%                   
% OUTPUT:
%    model:         model with modified variable
%
% Author: Thomas Pfau, Oct 2018


parser = inputParser();
parser.addRequired('model',@isstruct);
parser.addRequired('variableID',@(x) ischar(x) && any(ismember(model.evars,x)));
parser.addParameter('lb',[],@isnumeric);
parser.addParameter('ub',[],@(x) isnumeric(x));
parser.addParameter('c',[], @isnumeric );
parser.addParameter('Name',[], @ischar);
parser.parse(model,variableID,varargin{:});

coefs = columnVector(parser.Results.c)';


% get some model properties
if ischar(variableID)
    variableID = find(ismember(model.evars,variableID));
end

for i=1:2:numel(varargin)
    % if the field is not empty
    if ~isempty(varargin{i+1})
        % we update it accordingly.
        if iscell(model.(['evar' varargin{i}]))
            model.(['evar' varargin{i}]){variableID} = varargin{i+1};
        elseif isnumeric(model.(['evar' varargin{i}]))
            model.(['evar' varargin{i}])(variableID) = varargin{i+1};
        end
    end            
end