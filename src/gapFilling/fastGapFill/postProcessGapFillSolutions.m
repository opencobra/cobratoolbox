function [AddedRxnsExtended] = postProcessGapFillSolutions(AddedRxns,model,BlockedRxns,IdentifyPW)
%%[AddedRxnsExtended] = postProcessGapFillSolutions(AddedRxns,model,BlockedRxns,IdentifyPW)
%
% This function uses the output from fastGapFill and signs generalized
% function to the identified solutions from the universal database (e.g.,
% 'Metabolic reaction', 'Transport reaction', 'Exchange reaction'). It also
% provides basic statistics for the solution. One can use the option
% 'IdentifyPW' to compute for each solved blocked reaction a flux vector,
% such that the flux through this reaction is maximized while the sum of
% all fluxes is minimized. This analysis can be helpful to put the solution
% reactions into the network context.
%
% INPUT
% AddedRxns             Output from fastGapFill.m
% model                 Model structure. Original model given as input into prepareFastGapFill
% IdentifyPW            Optional: identifies reactions that are need from
%                       consistent model and added reactions to have flux through previously
%                       blocked reaction. default: false
%
% OUTPUT
% AddedRxnsExtended     Structure containing the information present in
%                       AddedRxns along with the statistics and if desired pathways containing
%                       the flux vectors.
%
% June 2013
% Ines Thiele, http://thielelab.eu


if ~exist('IdentifyPW','var')
    IdentifyPW = 0;
end

% postprocess solutions
if length(AddedRxns.rxns) > 0
    [a,b] = strtok(AddedRxns.rxns,'\[');
    b = regexprep(b,'\]r','');
    b = regexprep(b,'\[','');
    Metabolic = 0;
    Transport = 0;
    Exchange = 0;
    for i = 1 : length(b)
        if isempty(char(b(i)))
            AddedRxns.subSystem{i}= 'Metabolic reaction';
            Metabolic = Metabolic + 1;
        elseif strcmp('e]',b(i))
            AddedRxns.subSystem{i}='Exchange reaction';
            Exchange = Exchange + 1;
        elseif strcmp('n',b(i))
            AddedRxns.subSystem{i}='Nucleus <=> cytosol transport';
            Transport = Transport + 1;
        elseif strcmp('g',b(i))
            AddedRxns.subSystem{i}='Golgi <=> cytosol transport';
            Transport = Transport + 1;
        elseif strcmp('m',b(i))
            AddedRxns.subSystem{i}='Mitochondrion <=> cytosol transport';
            Transport = Transport + 1;
        elseif strcmp('l',b(i))
            AddedRxns.subSystem{i}='Lysosome <=> cytosol transport';
            Transport = Transport + 1;
        elseif strcmp('r',b(i))
            AddedRxns.subSystem{i}='ER <=> cytosol transport';
            Transport = Transport + 1;
        elseif strcmp('e',b(i))
            AddedRxns.subSystem{i}='Extracellular space <=> cytosol transport';
            Transport = Transport + 1;
        elseif strcmp('x',b(i))
            AddedRxns.subSystem{i}='Peroxisome <=> cytosol transport';
            Transport = Transport + 1;
        elseif strcmp('p',b(i))
            AddedRxns.subSystem{i}='Periplasm <=> cytosol transport';
            Transport = Transport + 1;
        else
            AddedRxns.subSystem{i}=strcat(b{i},' <=> cytosol transport');
            Transport = Transport + 1;
        end
    end
    AddedRxns.subSystem = AddedRxns.subSystem';
    AddedRxns.Stats.metabolicSol = Metabolic;
    AddedRxns.Stats.transportSol = Transport;
    AddedRxns.Stats.exchangeSol = Exchange;

    if IdentifyPW
        % model
        modelFilled = model;
        % Index = length(model.rxns)+1;
        % add found solutions to model
        for i = 1 : length(AddedRxns.rxns)
            modelFilled = addReaction(modelFilled,char(AddedRxns.rxns(i)),char(AddedRxns.rxnFormula(i)));
        end

        % find blocked reactions in modelFilled
        Rxns = find(ismember(modelFilled.rxns,BlockedRxns.solvableRxns));

        for i = 1 : length(BlockedRxns.solvableRxns)
            modelFilled.c = zeros(length(modelFilled.c),1);
            % set blocked reaction as objective
            modelFilled.c(Rxns(i)) = 1;
            % perform LP to reconstitute pathway
            % I am using taxi cab (Manhattan norm) as the shortest possible
            % solution
            FBA = optimizeCbModel(modelFilled,'max','one');
            if FBA.f == 0
                % minimize flux through reaction
                % perform LP to reconstitute pathway
                FBA = optimizeCbModel(modelFilled,'min','one');
            end
            % find reactions in FBA solution
            name= modelFilled.rxns{Rxns(i)};
            name = regexprep(name,'\(e\)','');
            name = regexprep(name,'^\d','x');
            if ~isempty(FBA.x)
                FBA.x(FBA.x>=-1e-8&FBA.x<=1e-8)=0;
                if ~isempty(find(FBA.x)~=0)
                    AddedRxns.solvableRxnsSol.(name).solution(:,1) = modelFilled.rxns(FBA.x~=0);
                    AddedRxns.solvableRxnsSol.(name).solution(:,2) = printRxnFormula(modelFilled,AddedRxns.solvableRxnsSol.(name).solution(:,1),false);
                    tmp = FBA.x(FBA.x~=0);
                    for k = 1 : length(tmp)
                        AddedRxns.solvableRxnsSol.(name).solution{k,3}=num2str(tmp(k));
                    end
                    clear tmp
                    % highlight which reaction have not been part of flux consistent
                    % network
                    tmp2 = find(ismember(AddedRxns.solvableRxnsSol.(name).solution(:,1),AddedRxns.rxns));
                    AddedRxns.solvableRxnsSol.(name).solution(tmp2,4)={'added'};
                    clear tmp2
                    tmp2 = find(ismember(AddedRxns.solvableRxnsSol.(name).solution(:,1),BlockedRxns.solvableRxns));
                    AddedRxns.solvableRxnsSol.(name).solution(tmp2,4)={'previously blocked'};

                    clear tmp2
                else
                    AddedRxns.Problem.(name) = BlockedRxns.solvableFormula(i);
                end
            else
                AddedRxns.Problem.(name) = BlockedRxns.solvableFormula(i);
            end
            clear FBA name
        end
    end
    AddedRxnsExtended = AddedRxns;
else
    AddedRxnsExtended = [];
end
