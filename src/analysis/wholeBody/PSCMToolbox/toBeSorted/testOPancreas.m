model = OrganCompendium.(O{16}).modelAllComp;
model.lb(find(model.lb<0))=-1000;
model.ub(find(model.ub<0))=0;
model.ub(find(model.ub>0))=1000;
model.lb(find(model.lb>0))=0;


% revert the direction of sinks
SI = strmatch('sink_',model.rxns);
for k = 1 : length(SI)
    if ~isempty(find(model.S(:,SI(k))==1))% positive entry
        % flip it
        model.S(find(model.S(:,SI(k))==1),SI(k)) = -1;
        model.lb(SI(k)) = min(model.lb(SI(k)),model.ub(SI(k)));
        model.lb(SI(k)) = max(model.lb(SI(k)),model.ub(SI(k)));
    end
end

i=16
modelClosed = model;
% prepare models for test - these changes are needed for the different
% recon versions to match the rxn abbr definitions in this script
modelClosed.rxns = regexprep(modelClosed.rxns,'\(','\[');
modelClosed.rxns = regexprep(modelClosed.rxns,'\)','\]');
modelClosed.mets = regexprep(modelClosed.mets,'\(','\[');
modelClosed.mets = regexprep(modelClosed.mets,'\)','\]');
modelClosed.rxns = regexprep(modelClosed.rxns,'ATPS4mi','ATPS4m');

% add reaction if it does not exist
[modelClosed, rxnIDexists] = addReactionOri(modelClosed,'DM_atp_c_',  'h2o[c] + atp[c]  -> adp[c] + h[c] + pi[c] ');
if length(rxnIDexists)>0
    modelClosed.rxns{rxnIDexists} = 'DM_atp_c_'; % rename reaction in case that it exists already
end

% close all exchange and sink reactions (lb)
modelexchanges1 = strmatch('Ex_',modelClosed.rxns);
modelexchanges4 = strmatch('EX_',modelClosed.rxns);
modelexchanges2 = strmatch('DM_',modelClosed.rxns);
modelexchanges3 = strmatch('sink_',modelClosed.rxns);
% also close biomass reactions
BM= (find(~cellfun(@isempty,strfind(lower(modelClosed.mets),'bioma'))));

selExc = (find( full((sum(abs(modelClosed.S)==1,1) ==1) & (sum(modelClosed.S~=0) == 1))))';

modelexchanges = unique([modelexchanges1;modelexchanges2;modelexchanges3;modelexchanges4;selExc;BM]);
modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
modelClosed.c = zeros(length(modelClosed.rxns),1);
modelClosed = changeObjective(modelClosed,'DM_atp_c_');
modelClosed.ub(selExc)=1000;

TestedRxns = [];

modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_o2[bc]')))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_h2o[bc]')))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_h2o[bc]')))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_h2o[lu]')))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_h2o[lu]')))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_h2o[bp]')))) = 1000;


modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_co2[bc]')))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_co2[lu]')))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_glc_D[bc]')))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_glc_D[bc]')))) = -1;


modelClosed = addReactionOri(modelClosed, 'H2Ot','h2o[e] <=> h2o[c]');
modelClosed = addReactionOri(modelClosed, 'H2Otm','h2o[c] <=> h2o[m]');
modelClosed = addReactionOri(modelClosed,'O2t','o2[e] <=> o2[c]');
modelClosed = addReactionOri(modelClosed, 'O2tm','o2[c] <=> o2[m]');
modelClosed = addReactionOri(modelClosed,'CO2tm','co2[c] <=> co2[m]');%heart
modelClosed = addReactionOri(modelClosed,'CO2t','co2[e] <=> co2[c]');%heart
modelClosed = addReactionOri(modelClosed,'CO2t[luP]','co2[luP] <=> co2[c]');%heart
% %
 modelClosed = addReactionOri(modelClosed,'L_LACtcm'	,'lac_L[c] -> lac_L[m]');%NA

FBA = optimizeCbModel(modelClosed,'max','zero')