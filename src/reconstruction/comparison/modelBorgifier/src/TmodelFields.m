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
function fields = TmodelFields(~)
% TmodelFields returns the field names of the Tmodel structure. This is
% to help allievate control between different scripts.
%
% USAGE:
%    fields = TmodelFields(~)
%
%INPUTS:
%    None
% 
% OUTPUTS:
%    Fields:       A column cell array that contains the following in order. 
%       rxnFields
%       rNumField
%       metFields
%       mNumFields
%       allFields
%
% CALLS:
%    None
% 
% CALLED BY:
%    cleanTmodel
%    readCbTmodel
%    verifyModel
%    organizeModelCool
%    TmodelStats
%    orderModelFields
%

% Declare fields
fields = cell(4,1) ;

% Reaction related fields that are cell arrays.
rxnFields = {'rxns' 'rxnID' 'rxnNames' 'subSystems' 'rxnECNumbers' ...
             'rxnKEGGID' 'rxnSEEDID' 'rxnEquations' ...
             'rxnReferences' 'rxnNotes' 'grRules'}' ;
fields{1,1} = rxnFields ; 
             
% Reaction related fields that are numeric arrays. 
rNumFields = {'rev' 'lb' 'ub' 'c'}' ;
fields{2,1} = rNumFields ; 
             
% Metabolite related fields that are cell arrays
metFields = {'mets' 'metID' 'metNames' 'metFormulas' ...
             'metKEGGID' 'metSEEDID' ...
             'metChEBIID' 'metPubChemID' 'metInChIString'}' ;
fields{3,1} = metFields ;

% Metabolite related fields that are numeric arrays.
mNumFields = {'metCharge'} ; 
fields{4,1} = mNumFields ; 

% All field names in correct order (27 fields).
allFields = {'rxns' 'mets' 'S' 'rev' 'lb' 'ub' 'c' ...
             'rxnID' 'rxnNames' 'subSystems' 'rxnEquations' ...
             'rxnECNumbers' 'rxnKEGGID' 'rxnSEEDID' ...
             'rxnReferences' 'rxnNotes' 'grRules' ...
             'metID' 'metNames' 'metFormulas' 'metCharge' ...
             'metKEGGID' 'metSEEDID' 'metChEBIID' 'metPubChemID' ...
             'metInChIString' ...
             'genes' 'description'}' ;
fields{5,1} = allFields ; 
                
