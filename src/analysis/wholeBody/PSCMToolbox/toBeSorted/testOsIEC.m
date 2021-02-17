
i=6
model = OrganCompendium.(O{i}).modelAllComp;
model.lb(find(model.lb<0))=-1000;
model.ub(find(model.ub<0))=0;
model.ub(find(model.ub>0))=1000;
model.lb(find(model.lb>0))=0;


X = {'PIt2m'
    'ATPS4m'
    'CYOR_u10m'
    'Htm'
    'NADH2_u10m'
    'CYOOm3'
    'CYOOm2'};
% new formulation of oxPhos reactions based on the changes done in Recon 2.2
% rxn abbr - old reaction - new reaction

Ri={'PIt2mi'    'h[c] + pi[c] -> h[m] + pi[m]'  'h[i] + pi[i] -> h[m] + pi[m]'
    % 'ASPGLUmi'	'h[c] + glu_L[c] + asp_L[m]  -> h[m] + glu_L[m] + asp_L[c] '	'asp_L[m] + glu_L[c] + h[i]  -> asp_L[c] + glu_L[m] + h[m] '
    'ATPS4mi'	'4 h[c] + adp[m] + pi[m]  -> h2o[m] + 3 h[m] + atp[m] '	'adp[m] + pi[m] + 4 h[i]  -> atp[m] + h2o[m] + 3 h[m] '
    'CYOR_u10mi'	'2 h[m] + 2 ficytC[m] + q10h2[m]  -> 4 h[c] + q10[m] + 2 focytC[m] '	'2 ficytC[m] + 2 h[m] + q10h2[m]  -> 2 focytC[m] + q10[m] + 4 h[i] '
    'Htmi'	'h[c]  -> h[m] '	'h[i]  -> h[m] '
    'NADH2_u10mi'	'5 h[m] + nadh[m] + q10[m]  -> 4 h[c] + nad[m] + q10h2[m] '	'5 h[m] + nadh[m] + q10[m]  -> nad[m] + q10h2[m] + 4 h[i] '
    'CYOOm3i'	'o2[m] + 7.92 h[m] + 4 focytC[m]  -> 1.96 h2o[m] + 4 h[c] + 4 ficytC[m] + 0.02 o2s[m] '	'4 focytC[m] + 7.92 h[m] + o2[m]  -> 4 ficytC[m] + 1.96 h2o[m] + 4 h[i] + 0.02 o2s[m] '
    'CYOOm2i' '4.0 focytC[m] + 8.0 h[m] + o2[m] -> 4.0 ficytC[m] + 4.0 h[c] + 2.0 h2o[m] '  '4.0 focytC[m] + 8.0 h[m] + o2[m] -> 4.0 ficytC[m] + 4.0 h[i] + 2.0 h2o[m] '};

for i = 1 : length(Ri)
    model = addReactionOri(model,Ri{i,1},Ri{i,3});
    RID = find(ismember(model.rxns,Ri{i,1}));
    %        model.subSystems{RID} = model.subSystems{find(ismember(model.rxns,X(i)))};
    %       model.grRules{RID} = model.grRules{find(ismember(model.rxns,X(i)))};
end
model  = rmfield(model,'rxnGeneMat');

model = removeRxnsOri(model,X);



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
% 

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



modelClosed.lb(find(ismember(modelClosed.rxns,strcat('r0205')))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,strcat('r0205')))) = 0;

modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_o2[bc]')))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_h2o[bc]')))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_h2o[bc]')))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_h2o[luSI]')))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_h2o[luSI]')))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_h2o[bp]')))) = 1000;


modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_co2[bc]')))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_co2[bp]')))) = 1000;
%modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_glc_D[luSI]')))) = -1;
%modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_glc_D[luSI]')))) = -1;
 modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_glc_D[bc]')))) = -1;
 modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_glc_D[bc]')))) = -1;



modelClosed = addReactionOri(modelClosed, 'H2Ot','h2o[e] <=> h2o[c]');
modelClosed = addReactionOri(modelClosed, 'H2Otm','h2o[c] <=> h2o[m]');
modelClosed = addReactionOri(modelClosed,'O2t','o2[e] <=> o2[c]');
modelClosed = addReactionOri(modelClosed, 'O2tm','o2[c] <=> o2[m]');
modelClosed = addReactionOri(modelClosed,'CO2tm','co2[c] <=> co2[m]');%heart
modelClosed = addReactionOri(modelClosed,'CO2t','co2[e] <=> co2[c]');%heart


       modelClosed = addReactionOri(modelClosed,'L_LACtcm'	,'lac_L[c] -> lac_L[m]');%NA
        modelClosed = addReactionOri(modelClosed,'LDH_Lm'	,'nad[m] + lac_L[m] <=> h[m] + nadh[m] + pyr[m]');%NA
modelClosed = addReactionOri(modelClosed,'DCK1m', 'atp[m] + dcyt[m] <=> h[m] + adp[m] + dcmp[m]');%lung
 modelClosed = addReactionOri(modelClosed,'DCMPtm','dcmp[m] <=> dcmp[c]');%lung
 modelClosed = addReactionOri(modelClosed,'HMR_8475','dcyt[c] <=> dcyt[m]');%lung
 modelClosed = addReactionOri(modelClosed,'r0377','atp[c] + dcyt[c] -> h[c] + adp[c] + dcmp[c]');%heart
modelClosed = addReactionOri(modelClosed,'VALTA','akg[c] + val_L[c] <=> glu_L[c] + 3mob[c]');
modelClosed = addReactionOri(modelClosed,'VALTAm','akg[m] + val_L[m] <=> glu_L[m] + 3mob[m]');
modelClosed = addReactionOri(modelClosed,'VALt5m','val_L[c]  <=> val_L[m]');
modelClosed = addReactionOri(modelClosed,'3MOBt2im','h[c] + 3mob[c] -> h[m] + 3mob[m]');%lung?
   modelClosed = addReactionOri(modelClosed,   'GLCt1r','glc_D[e] <=> glc_D[c]');
     modelClosed = addReactionOri(modelClosed,'EX_glc_D[bc]','glc_D[bc] <=>');
 modelClosed = addReactionOri(modelClosed,'Tr_EX_glc_D[e]_[bc]','glc_D[e] <=> glc_D[bc]');

modelClosed.lb(find(ismember(modelClosed.rxns, 'Tr_EX_o2[e]_[bc]')))=-1000;

 modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_glc_D[bc]')))) = -1;
 modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_glc_D[bc]')))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero')
FBA2= optimizeCbModel(modelClosed,'max')