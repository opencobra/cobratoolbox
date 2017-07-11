function Model = buildRxnEquationsFromName(Model)
% Takes a COBRA model and creates reaction equations based
% on the metabolite long names, S matrix and bound information. Returns the
% model with the additioanl field `rxnEquations`.
%
% USAGE:
%
%    Model = buildRxnEquations(Model)
%
% INPUTS:
%    Model:     COBRA format model or `Tmodel`
%
% OUTPUTS:
%    Model:     Model with corrected `rxnEquations` field.
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

if isfield(Model,'Models') % If the function is fed Tmodel, use reaction bounds from first model.
    modelNames = fieldnames(Model.Models) ;
    firstModel = modelNames{1} ;
    lb = Model.lb.(firstModel) ;
    ub = Model.ub.(firstModel) ;
else
    lb = Model.lb ;
    ub = Model.ub ;
end

%% Make the equations.
for iRxn = 1:length(Model.rxns)
    rxnCode = [] ;

    educts   = find(Model.S(:, iRxn) < 0) ;
    products = find(Model.S(:, iRxn) > 0) ;
    if lb(iRxn) < 0 && ub(iRxn) > 0
        arrow = '<==>' ;
    elseif lb(iRxn) >= 0 && ub(iRxn) > 0
        arrow = '-->' ;
    elseif lb(iRxn) < 0 && ub(iRxn) <= 0
        arrow = '<--' ;
        esave = educts ; products = educts ; educts = esave ; clear esave ;
    elseif lb(iRxn) == 0 && ub(iRxn) == 0
        arrow = '|||' ;
    else
        disp(['do not understand directionality of ' Model.rxns{iRxn}])
    end

    if ~isempty(educts)
        for ie = 1:length(educts)
            if Model.S(educts(ie), iRxn) ~= -1
                rxnCode = [rxnCode '(' num2str(-Model.S(educts(ie), iRxn)) ...
                          ') ' Model.metNames{educts(ie)} ] ;
            else
                rxnCode = [rxnCode Model.metNames{educts(ie)}] ;
            end
            rxnCode = [rxnCode ' + '] ;
        end
        % Note how just 2 positions are substracted from the end, leaving a
        % space.
        rxnCode = [rxnCode(1:end - 2) arrow] ;
    end
    if ~isempty(products)
        rxnCode = [rxnCode ' '] ;
        for ip = 1:length(products)
            if Model.S(products(ip), iRxn) ~= 1
                rxnCode = [rxnCode '(' num2str(Model.S(products(ip), iRxn))...
                          ') ' Model.metNames{products(ip)}] ;
            else
                rxnCode = [rxnCode Model.metNames{products(ip)}] ;
            end
            rxnCode = [rxnCode ' + '] ;
        end
        rxnCode = rxnCode(1:end - 3) ;
    end

    Model.rxnEquations{iRxn, 1} = rxnCode ;
    clear educts ; clear products; clear ie ; clear ip ; clear rxcode ;
end
