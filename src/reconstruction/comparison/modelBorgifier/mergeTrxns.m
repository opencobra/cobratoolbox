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
function Tmodel = mergeTrxns(Tmodel, mergerxns, mergerxnsratio)
% mergeTmodel merges identical reactions within Tmodel that were accidently
% kept separate during the model matching process.
% 
% USAGE:
%    Tmodel = mergeTrxns(Tmodel, mergerxns, mergerxnsratio)
%
% INPUTS:
%    Tmodel:            Template model
%    mergerxns:         Cell array of reactions to be merged
%    mergerxnsratio
%
% OUTPUTS:
%    Tmodel:            Tmodel with reduced number of reactions. 
%
% CALLS:
%    charpos
%
% CALLED BY:
%

nowRemoveRxns = [] ;
rxnfields = fieldnames(Tmodel) ;
rxnfields = rxnfields(strncmp(rxnfields, 'rxn', 3)) ;
rxnfields{end + 1} = 'grRules' ;
rxnfields{end + 1} = 'subSystems' ;
rxnfields = setdiff(rxnfields, 'rxns') ;
    
for i = 1:length(mergerxns)
    % remember which duplicate reactions should be removed
    nowRemoveRxns(end + (1:length(mergerxns{i}(2:end))) ) = mergerxns{i}(2:end) ; %#ok<*AGROW>
        
    % merge model-specific information
    modelfields = fieldnames(Tmodel.Models) ;
    for im = 1:length(modelfields)
        % rxns in Models
        Tmodel.Models.(modelfields{im}).rxns(mergerxns{i}(1)) = ...
            logical(sum( Tmodel.Models.(modelfields{im}).rxns(mergerxns{i}))) ;
        % objective
        Tmodel.c.(modelfields{im})(mergerxns{i}(1)) = ...
            sum(Tmodel.c.(modelfields{im})(mergerxns{i})) ;
        % bounds & reversibilites
%         Tmodel.rev.(modelfields{im})(mergerxns{i}(1)) = ...
%             sign(sum(Tmodel.rev.(modelfields{im})(mergerxns{i}))) ;
        if mergerxnsratio(i) > 0
            nowlb = Tmodel.lb.(modelfields{im})(mergerxns{i}) ;
            nowlb(2:end) = nowlb(2:end) ./ mergerxnsratio(i) ;
            nowlb = nowlb(nowlb ~= 0) ;
            if isempty(nowlb)
                nowlb = 0 ;
            elseif length(nowlb) > 1
                nowlb = mean(nowlb) ;
            end
            Tmodel.lb.(modelfields{im})(mergerxns{i}(1)) = nowlb ;
            
            nowub = (Tmodel.ub.(modelfields{im})(mergerxns{i})) ;
            nowub(2:end) = nowub(2:end) ./ mergerxnsratio(i) ;            
            nowub = nowub(nowub ~= 0) ;
            if isempty(nowub)
                nowub = 0 ;
            elseif length(nowub) > 1
                nowub = mean(nowub) ;
            end
            Tmodel.ub.(modelfields{im})(mergerxns{i}(1)) = nowub ;
            
        elseif mergerxnsratio(i) < 0
            nowlb = [Tmodel.lb.(modelfields{im})(mergerxns{i}(1)) Tmodel.ub.(modelfields{im})(mergerxns{i}(2:end)) ] ;
            nowlb(2:end) = nowlb(2:end) ./ mergerxnsratio(i) ;            
            nowlb = nowlb(nowlb ~= 0) ;
            if isempty(nowlb)
                nowlb = 0 ;
            elseif length(nowlb) > 1
                nowlb = mean(nowlb) ;
            end
            Tmodel.lb.(modelfields{im})(mergerxns{i}(1)) = nowlb ;
            
            nowub = [Tmodel.ub.(modelfields{im})(mergerxns{i}(1)) Tmodel.lb.(modelfields{im})(mergerxns{i}(2:end)) ] ;
            nowub(2:end) = nowub(2:end) ./ mergerxnsratio(i) ;            
            nowub = nowub(nowub ~= 0) ;
            if isempty(nowub)
                nowub = 0 ;
            elseif length(nowub) > 1
                nowub = mean(nowub) ;
            end
            Tmodel.ub.(modelfields{im})(mergerxns{i}(1)) = nowub ;
            
        else
            warning('mergeRxnRatio should not be 0')
        end
    end
    
    % rxns - choose the id with less number characters as simple logic to
    % prefere the more biological name. This will anyways be checked again
    % in cleanTmodel
    nowNumCharAvg = cellfun(@mean, cellfun(@charpos,Tmodel.rxns(mergerxns{i}) , 'UniformOutput', false))  ; 
    if iscell(Tmodel.rxns(mergerxns{i}(find(nowNumCharAvg == max(nowNumCharAvg),1))))
        Tmodel.rxns(mergerxns{i}(1)) = Tmodel.rxns(mergerxns{i}(find(nowNumCharAvg == max(nowNumCharAvg), 1))) ;
    else
        Tmodel.rxns{mergerxns{i}(1)} = Tmodel.rxns(mergerxns{i}(find(nowNumCharAvg == max(nowNumCharAvg), 1))) ;
    end
    
    % Other rxn fields
    for ir = 1:length(rxnfields)
        Tmodel.(rxnfields{ir}){mergerxns{i}(1)} = strjoin(Tmodel.(rxnfields{ir})(mergerxns{i}), '|') ;
    end
end

% Remove excess fields
Tmodel.rxns(nowRemoveRxns) = [] ;
Tmodel.S(:,nowRemoveRxns) = [] ;
for im = 1:length(modelfields)
    Tmodel.Models.(modelfields{im}).rxns(nowRemoveRxns) = [] ;
    Tmodel.c.(modelfields{im})(nowRemoveRxns) = [] ;
    Tmodel.lb.(modelfields{im})(nowRemoveRxns) = [] ;
    Tmodel.ub.(modelfields{im})(nowRemoveRxns) = [] ;
end
for ir = 1:length(rxnfields)
    Tmodel.(rxnfields{ir})(nowRemoveRxns) = [] ;
end

