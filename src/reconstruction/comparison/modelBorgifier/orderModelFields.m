% This file is published under Creative Commons BY-NC-SA.
%
% Please cite:
% Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale 
% metabolic reconstructions with modelBorgifier. Bioinformatics 
% (Oxford, England), 30(7), 1036?8. http://doi.org/10.1093/bioinformatics/btt747
%
% Correspondance:
% johntsauls@gmail.com
%
% Developed at:
% BRAIN Aktiengesellschaft
% Microbial Production Technologies Unit
% Quantitative Biology and Sequencing Platform
% Darmstaeter Str. 34-36
% 64673 Zwingenberg, Germany
% www.brain-biotech.de
%
function Model = orderModelFields(Model)
% orderModelFields puts the fields in the correct order in the structure. 
%
% USAGE:
%    Model = orderModelFields(Model)
%
% INPUTS:
%    Model
%
% OUTPUTS:
%    Model
%
% CALLS:
%    TmodelFields
%
% CALLED BY:
%    verifyModel
%    readCbTModel
%

%% Order fields.
% Get correct order. 
fields = TmodelFields ; 
correctOrder = fields{5} ;

% Current Field names in the model. 
fieldNames = fieldnames(Model) ;

% Extra fields should go at the end.
fieldOrder = zeros(length(fieldNames), 1) ;
extraFieldIndex = length(correctOrder) + 1 ;

% Determine current field position
for iField = 1:length(fieldNames)
    fieldIndex = strcmp(fieldNames{iField}, correctOrder) ;
    fieldIndex = find(fieldIndex) ;
    if fieldIndex
        fieldOrder(fieldIndex) = iField ;
    else
        fieldOrder(extraFieldIndex) = iField ;
        extraFieldIndex = extraFieldIndex + 1 ;
    end
end

% fix vFieldOrderS
fieldOrder(fieldOrder == 0) = [] ;

% Organize
Model = orderfields(Model, fieldOrder) ;
