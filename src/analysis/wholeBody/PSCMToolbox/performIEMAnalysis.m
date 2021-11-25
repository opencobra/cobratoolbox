function [IEMSolutions,IEMTable,missingMetAll] = performIEMAnalysis(model,geneMarkerList,compartment,urine,minRxnsFluxHealthy, reverseDirObj, fractionKO,minBiomarker,fixIEMlb, LPSolver)
% This function performs the IEMAnalysis from a list of genes, testing for
% the defined biomarker metabolites in one or more biofluid compartments.
%
% INPUT
% model                 WBM model structure
% geneMarkerList        Cell array containing the geneMarkerLists and
%                       the biomarkers to be tested for
%                       e.g.,
%                       geneMarkerListMarkerList = {
%                             '5053.1' 'trp_L;actyr;phe_L;tyr_L'
%                             '249.1' '3pg;cholp;glyc3p;ethamp'
%                             };
% compartment           List of biofluid compartments that the biomarkers
%                       appear in and should be tested for
% urine                 Indicate whether you want to test for the urine
%                       excretion of the biomarker metabolite as well. Default = true
% minRxnsFluxHealthy    Min flux value(s) through the IEMRxns (Default: 0.75
%                       corresponding to 75%)
% reverseDirObj         The function maximizes the objective flux by
%                       default. If set to 1, the function also checks the minimization problem.
% fractionKO            By default, a complete knowckout of BiomarkerRxnsthe IEM
%                       reactions is computed but it is possible to set a fraction (default = 1
%                       for 100% knockout)
% minBiomarker          Minimization through biomarker reaction (default = 0)
% fixIEMlb              fix IEM to lb = ub
%                       =(1-fractionKO)*solution.v(find(model.c)) (default = 0, i.e., lb =0,
%                       while ub = (1-fractionKO)*solution.v(find(model.c))
% LPSolver              Define LPSolver ('ILOGcomplex' - default;
%                       'tomlab_cplex')
% 
%
% OUTPUT
% IEMSolutions      Structure containing the predictions for each gene.
%                   Metabolites that are not occurring in a biofluid, will have a 'NA' in the
%                   corresponding fields
% IEMTable          Cell array containing the predictions for each gene (same
%                   content as in IEMSolutions
% missingMetAll     Metabolites not appearing in a biolfuid
%
% Ines Thiele - 2020-2021

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
    [IEMRxns, grRules] = getRxnsFromGene(model,geneMarkerList{k},1);
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
    for j = 5 : size(IEMSolutions.(F{i}).solution,1)
        tmp = regexprep(F{i},'G_','');
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
end
