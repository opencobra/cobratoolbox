function [BMall,ResultsAllCellLines,metRsall, maximum_contributing_rxn,maximum_contributing_flux,ATPyield] = predictFluxSplits(model, obj, met2test,samples,ResultsAllCellLines, dir,transportRxns,ATPprod,carbon_source, eucNorm)
% This function performs the flux splits analysis for the metabolites of
% interest, meaning it predicts the fraction of metabolite produced (or
% consumed) based all reactions producing (or consuming) the metabolite
%
% USAGE:
%
%    [BMall,ResultsAllCellLines,metRsall, maximum_contributing_rxn,maximum_contributing_flux,ATPyield] = predictFluxSplits(model, obj, met2test,samples,ResultsAllCellLines, dir,transportRxns,ATPprod,carbon_source, eucNorm)
%
% INPUTS:
%    model:                       Generic model, e.g., `modelMedium`
%    obj:                         objective function, e.g., biomass or ATPM
%    met2test:                    e.g., `atp[c]`. Mind that the metabolites are produced in multiple compartments.
%    samples:                     Name of conditions as in `ResultsAllCellLines`
%    ResultsAllCellLines:         Structure containing the pruned submodels of the samples
%
% OPTIONAL INPUTS:
%    dir:                         Production = 1 (default = production), else consumption = 0
%    eucNorm:                     Default: 1e-6
%    transportRxns:               Vector of reactions that do not really produce or consume the metabolite, e.g., reactions that transport ATP from one compartment to the other. This input is optional only to allow the initial prediction of all producing reactions to define the exclude reaction set.
%    carbon_source:               Reference uptake for calculation of ATP yield, e.g.,{`EX_glc(e)`}.
%    ATPprod:
%
% OUTPUTS:
%    BMall:                       Matrix of flux vectors used for calculations
%    ResultsAllCellLines:         Structure containing results of run analysis
%    metRsall:                    Matrix of flux (producing or consuming) a defined metabolite
%    maximum_contributing_rxn:    Reactions with highest flux (producing or
%                                 consuming) a defined metabolite across analyzed samples (not
%                                 necessarily >50%), if multiple reactions have the same contribution, all will be reported seperated by a back slash.
%    maximum_contributing_flux:   Matrix containing:
%
%                                 * highest flux (column 1),
%                                 * sum of flux (producing or consuming) a defined metabolite (column 2),
%                                 * percentage (column 3),
%                                 * contribution of glycolysis (column 4),
%                                 * contribution of ETC (column 5),
%                                 * combined contribution of glycolysis and ETC (column 6),
%                                 * contribution of TCA (column 7),
%                                 * combined contribution of glycolysis, ETC, and TCA (column 8).
%    ATPyield:                    ATP yield calculated from the sum of ATP production divided by the predicted uptake flux of the metabolite specified as carbon_source.
%                                 No extra constraints are applied, thus not only production  flux from the specified carbon source is considered.
% EXAMPLE:
%
%    % if met2test is not atp to reduce number of useless outputs
%    [BMall, ResultsAllCellLines, metRsall] = predictFluxSplits(model, obj, met2test,samples,ResultsAllCellLines, dir, eucNorm, transportRxns, ATPprod, carbon_source)
%
%
% .. Author: - Maike K. Aurich 13/07/15

if ~exist('dir','var') || isempty(dir)
    dir = 1;
end

if ~exist('eucNorm','var') || isempty(eucNorm)
    eucNorm = 1e-6;
end


if ~exist('transportRxns','var') || isempty(transportRxns)
    transportRxns = {};
end

if ~exist('ATPyield ','var') || isempty(ATPyield)
    ATPyield = 0;
end

if exist('carbon_source','var')
    ATPyield = 1;
end

if ~exist('ATPprod','var') || isempty(ATPprod)
    ATPproducer = 0;
elseif ~isempty(ATPprod)
    ATPproducer = 1;

end

if nargout>3
    bExtraOutputs = true;
else
    bExtraOutputs = false;
end


A = length(samples);
B= length(model.rxns);

BMall = zeros(B,A);

metRsall = [model.rxns cell(B,2*A)];

cntn=1;

maximum_contributing_rxn = {};
maximum_contributing_flux = [];
RxnsNamesAll = [];
%% change
for k =1:length(samples)

    %% Predict flux distribution
    %Recon names
    namesRecon = model.rxns;
    % submodel names
    submodel = eval(['ResultsAllCellLines.' samples{k} '.modelPruned']);

    [ID,XI] = ismember(namesRecon, submodel.rxns);

    submodel = changeObjective(submodel,obj);

    %[solBMa,LPProblem]=solveCobraLPCPLEX(submodel,1,0,0,[],1e-6);

    solBMa =optimizeCbModel(submodel,'max',1e-6);

    solBMa.obj = solBMa.f; % purpose of renaming fields?
    %BMs(k,2) = solBMa.obj;
    solBMa.full = solBMa.x;
    %solBMa.x = solBMa.full;

    %setting the fluxes below eucNorm to zero
    for i=1:length(solBMa.x)
        if abs(solBMa.x(i))< eucNorm % threshold applied to solBMa.x but flux splits computed with solBMa.full
            solBMa.x(i)=0;
        end
    end

    BMall(ID,k) = solBMa.x(XI(ID));

    %% Compute flux splits
    % Remove excluded reactions (transportRxns)
    tmpModel.mets = submodel.mets;
    isIncluded = ~ismember(submodel.rxns,transportRxns);
    tmpModel.S = submodel.S(:,isIncluded);
    tmpV = solBMa.full(isIncluded);
    [P,C,vP,vC] = computeFluxSplits(tmpModel,met2test,tmpV);

    % decide if production (1) or consumption ~1.
    vMetAll = zeros(size(isIncluded));
    metprod_phi = zeros(size(isIncluded));
    if dir == 1
        vMetAll(isIncluded) = vP;
        metprod_phi(isIncluded) = P;
    else
        vMetAll(isIncluded) = vC;
        metprod_phi(isIncluded) = C;
    end

    % collect results for submodel
    metprod = find(vMetAll);
    RxnsNamesAll = submodel.rxns(metprod);
    vMetAll = vMetAll(metprod);
    metprod_phi = metprod_phi(metprod);
    metRs = [RxnsNamesAll num2cell([vMetAll metprod_phi])];

    % map results to generic model
    [IDm,XIm] = ismember(model.rxns,RxnsNamesAll);
    metRsall(IDm,2*k) = cellstr(char(vMetAll(XIm(IDm))));
    metRsall(IDm,2*k+1) = cellstr(char(metprod_phi(XIm(IDm))));

    clear IDm
    name  = ['flux_split_' strtok(met2test{1}, '[')];

    ResultsAllCellLines.(samples{k}).(name).metRs = metRs;

    %% check for contribution of glycolysis etc.
    if ATPproducer == 1
        idx_gly =find(ismember(metRs(:,1), ATPprod(2:3,1)));
        idx_ETC =find(ismember(metRs(:,1), ATPprod(1,1)));
        idx_glu = find(ismember(metRs(:,1), ATPprod(4,1)));

        A(k,1)=sum(vMetAll);
        maximum_contributing_rxn(k,1) = RxnsNamesAll(find(ismember(vMetAll,max(vMetAll)),1));
        %maximum_contributing_rxn(k,1) = RxnsNamesAll(find(vMetAll==max(vMetAll)));

        maximum_contributing_flux(k,1) = max(vMetAll);
        maximum_contributing_flux(k,2) = sum(vMetAll);
        maximum_contributing_flux(k,3) = max(vMetAll)/sum(vMetAll)*100;
        maximum_contributing_flux(k,4) = (vMetAll(idx_gly(1,1))+ vMetAll(idx_gly(2,1)))/sum(vMetAll)*100; % contriburion of glycolysis
        maximum_contributing_flux(k,5) = vMetAll(idx_ETC)/sum(vMetAll)*100; % contribution of ETC
        maximum_contributing_flux(k,6) = maximum_contributing_flux(k,4)+ maximum_contributing_flux(k,5);

        if ~isempty(vMetAll(idx_glu))
            maximum_contributing_flux(k,7) = vMetAll(idx_glu)/sum(vMetAll)*100; %contribution of TCA to ATP
            maximum_contributing_flux(k,8) = maximum_contributing_flux(k,6)+ maximum_contributing_flux(k,7);%contribution of glycolysis, TCA and ETC
        else
            maximum_contributing_flux(k,7) = nan;
            maximum_contributing_flux(k,8) = nan;
        end

        vglc= solBMa.full(find(ismember(submodel.rxns,carbon_source)),1);
        ATPyield(k,1) = (maximum_contributing_flux(k,2)/abs(vglc));

        ResultsAllCellLines.(samples{k}).(name).maximum_contributing_flux = maximum_contributing_flux(k,:);
        ResultsAllCellLines.(samples{k}).(name).maximum_contributing_rxn = maximum_contributing_rxn(k,1);

    elseif ATPproducer == 0

        ATPyield = [];

        A(k,1)=sum(vMetAll);
        maximum_contributing_rxn{k,1} = strjoin(RxnsNamesAll(find(ismember(vMetAll,max(vMetAll))),:)','\\');

        maximum_contributing_flux(k,1) = max(vMetAll);
        maximum_contributing_flux(k,2) = sum(vMetAll);
        maximum_contributing_flux(k,3) = max(vMetAll)/sum(vMetAll)*100;

        ResultsAllCellLines.(samples{k}).(name).maximum_contributing_flux = maximum_contributing_flux(k,1);
        ResultsAllCellLines.(samples{k}).(name).maximum_contributing_rxn = maximum_contributing_rxn{k,1};
    end

    clear metsR vMetAll idx* RxnsNamesAll
end

end
