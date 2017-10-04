function Model = orderModelFieldsBorg(Model)
% Puts the fields in the correct order in the structure.
% Called by `verifyModel`, `readCbTModel`, calls `TmodelFields`.
%
% USAGE:
%
%    Model = orderModelFieldsBorg(Model)
%
% INPUTS:
%    Model:    model structure with unsorted fiels
%
% OUTPUTS:
%    Model:    model strucutre with sorted fields
%
% Please cite:
% `Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale
% metabolic reconstructions with modelBorgifier. Bioinformatics
% (Oxford, England), 30(7), 1036?8`. http://doi.org/10.1093/bioinformatics/btt747
%
% ..
%    Edit the above text to modify the response to help addMetInfo
%    Last Modified by GUIDE v2.5 06-Dec-2013 14:19:28
%    This file is published under Creative Commons BY-NC-SA.
%
%    Correspondance:
%    johntsauls@gmail.com
%
%    Developed at:
%    BRAIN Aktiengesellschaft
%    Microbial Production Technologies Unit
%    Quantitative Biology and Sequencing Platform
%    Darmstaeter Str. 34-36
%    64673 Zwingenberg, Germany
%    www.brain-biotech.de

fields = TmodelFields ;  % Order fields. Get correct order.
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
