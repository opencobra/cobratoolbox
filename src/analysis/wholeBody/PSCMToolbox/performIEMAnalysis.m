function [IEMSolutions, IEMTable, missingMetAll] = performIEMAnalysis(model, geneMarkerList, compartment, urine, minRxnsFluxHealthy, causal, reverseDirObj, fractionKO, minBiomarker, fixIEMlb, LPSolver)
% Perform inborn-error-of-metabolism (IEM) analysis from a list of genes
%
% This function performs the IEM analysis from a list of genes, testing for
% the defined biomarker metabolites in one or more biofluid compartments.
%
% USAGE:
%
%    [IEMSolutions, IEMTable, missingMetAll] = performIEMAnalysis(model, geneMarkerList, compartment, urine, minRxnsFluxHealthy, causal, reverseDirObj, fractionKO, minBiomarker, fixIEMlb, LPSolver)
%
% INPUTS:
%    model:                Whole-body metabolic model, with fields:
%
%                            * .modelID - model identifier
%    geneMarkerList:       Cell array of gene marker lists and the biomarkers to test for
%    compartment:          List of biofluid compartments in which the biomarkers appear
%    urine:                Also test for urine excretion of the biomarker metabolite (default true)
%    minRxnsFluxHealthy:    Minimum flux value(s) through the IEMRxns (default 0.75)
%    causal:               If 1, use only genes whose loss causes loss of function of the
%                          associated reactions; otherwise use all associated reactions (default)
%    reverseDirObj:        The function maximises the objective flux by default; if set to
%                          1, it also checks the minimisation problem
%    fractionKO:           Fraction of knockout applied to the IEM reactions (default 1)
%    minBiomarker:         Minimise through the biomarker reaction (default 0)
%    fixIEMlb:             Fix the IEM reaction lb = ub (default 0)
%    LPSolver:             LP solver to use ('ILOGcomplex' default, 'tomlab_cplex')
%
% OUTPUTS:
%    IEMSolutions:         Structure of predictions for each gene ('NA' where a metabolite
%                          does not occur in a biofluid)
%    IEMTable:             Cell array of predictions for each gene (same content as IEMSolutions)
%    missingMetAll:        Metabolites not appearing in a biofluid
%
% .. Author: - Ines Thiele, 2020-2021

if ~exist('compartment','var')
    compartment = {'[bc]'};
end
if ~exist('urine','var')
    urine = 1; % test for urine metabolites
end
if ~exist('minRxnsFluxHealthy','var')
    minRxnsFluxHealthy = 0.75;
end

if ~exist('reverseDirObj','var')
    reverseDirObj = 0;
end

if ~exist('fractionKO','var')
    fractionKO = 1;% complete KO
end
if ~exist('minBiomarker','var')
    minBiomarker = 0;% no minimization of flux through biomarkers
end

if ~exist('fixIEMlb','var')
    fixIEMlb = 0;% lb = 0 for IEM rxns, while ub is constraint to (1-fractionKO)*solution.v(find(model.c));
end

if ~exist('LPSolver','var')
    LPSolver = 'ILOGcomplex';
    LPSolver = 'tomlab_cplex';
end


if  ~exist('causal','var')
    causal = 0;
end
modelO = model;
missingMetAll = [];
for k = 1 : size(geneMarkerList,1)
    markers = split(geneMarkerList(k,2),';');
    
    cnt = 1;
    model = modelO;
    clear rxnNames missingMet
    BiomarkerRxns = [];
    cnt2 = 1;
    if ~isempty(compartment)
        for i = 1 : length(markers)
            for j = 1 : length(compartment)
                
                [model,rxnNames(cnt,1)] = addDemandReaction(model,[markers{i} compartment{j}],0);
                % not all metabolites appear in biofluids though there may
                % be in recon
                if isempty(find(contains(modelO.mets,[markers{i} compartment{j}])))
                    missingMet(cnt2,1) = rxnNames(cnt,1);
                    cnt2 = cnt2+1;
                end
                cnt = cnt + 1;
            end
        end
        BiomarkerRxns = [BiomarkerRxns,rxnNames];
    end
    if urine
        rxnName = regexprep(BiomarkerRxns,'DM_','EX_');
        rxnName = regexprep(rxnName,'\[bc\]','[u]');
        BiomarkerRxns = [BiomarkerRxns;rxnName];
    end
    for i = 1 : length(BiomarkerRxns)
        BiomarkerRxns{i,2} = 'non reported';
    end
    [IEMRxns, grRules] = getRxnsFromGene(model,geneMarkerList{k},causal);
    [IEMSol] = checkIEM_WBM(model,IEMRxns, BiomarkerRxns,minRxnsFluxHealthy);
    % remove 0's for those metabolites that do not occur in a specific
    % biolfuid to be able to distinguish results from being 0 in flux due
    % to the model not being able to produce them in the biofluid vs those
    % that are currently not present in the biofluid and should be added.
    if exist('missingMet','var')
        for i = 1 : length(missingMet)
            x = find(contains(IEMSol(:,1),missingMet{i}));
            for j = 1 : length(x)
                IEMSol{x(j),2} = 'NA';
            end
        end
    end
    % store results in a structure
    geneMarkerListName = regexprep(geneMarkerList{k},'\.','_');
    IEMSolutions.(['G_' geneMarkerListName]).solution = IEMSol;
    IEMSolutions.(['G_' geneMarkerListName]).BiomarkerRxns = BiomarkerRxns;
    IEMSolutions.(['G_' geneMarkerListName]).IEMRxns = IEMRxns;
    IEMSolutions.(['G_' geneMarkerListName]).minRxnsFluxHealthy = minRxnsFluxHealthy;
    if isfield(model,'modelID')
        IEMSolutions.(['G_' geneMarkerListName]).modelID = model.modelID;
    end
    % keep track of metabolites that are missing from a biofluid
    if exist('missingMet','var')
    missingMetAll = [missingMetAll;missingMet];
    end
end
missingMetAll = unique(missingMetAll);
% get results into a table format
F = fieldnames(IEMSolutions);
cnt = 1;
clear IEMTable

for i = 1 : length(F)
    tmp = regexprep(F{i},'G_','');
    
    if  size(IEMSolutions.(F{i}).solution,1)>=5
        for j = 5 : size(IEMSolutions.(F{i}).solution,1)
            IEMTable{cnt,1} = regexprep(tmp,'_(\d)','');
            if (contains(IEMSolutions.(F{i}).solution(j,1),'Healthy'))
                value = regexprep(IEMSolutions.(F{i}).solution(j,1),'Healthy:','');
                IEMTable(cnt,2) = value;
                IEMTable(cnt,3) =IEMSolutions.(F{i}).solution(j,2);
            elseif contains(IEMSolutions.(F{i}).solution(j,1),'Disease')
                IEMTable(cnt,4) = IEMSolutions.(F{i}).solution(j,2);
                cnt = cnt + 1;
            end
        end
    else
        IEMTable{cnt,1} = regexprep(tmp,'_(\d)','');
        IEMTable{cnt,2} = 'No Rxn Assoc';
        cnt = cnt + 1;
    end
end
