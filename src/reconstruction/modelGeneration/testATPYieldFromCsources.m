function [Table_csources,TestedRxns,PercTestedRxns] = testATPYieldFromCsources(model,modelName)
% computes the ATP yield from various carbon sources in Recon2 or Recon3.
%
% USAGE:
%     [Table_csources,TestedRxns,PercTestedRxns] = testATPYieldFromCsources(model,modelName)
%
% INPUT:
%    model:            model structure
%    modelName         name of the model structure, by default Recon3
%
% OUTPUT:
%    Table_csources:   table listing ATP yield computed for the carbon sources
%    TestedRxns:       list of reactions that are contributing to ATP production from carbon sources
%    PercTestedRxns:   Fraction that tested reactions make up compared with all reactions in model
%
% .. Authors:
%    - IT 2017
%    - AH, July 2017 - Description added

if ~exist('modelName','var')
    modelName = 'Recon3';
end

%% check for the metabolites
modelClosed = model;
% prepare models for test - these changes are needed for the different
% recon versions to match the rxn abbr definitions in this script
modelClosed.rxns = regexprep(modelClosed.rxns,'\(','\[');
modelClosed.rxns = regexprep(modelClosed.rxns,'\)','\]');
modelClosed.mets = regexprep(modelClosed.mets,'\(','\[');
modelClosed.mets = regexprep(modelClosed.mets,'\)','\]');
modelClosed.rxns = regexprep(modelClosed.rxns,'ATPS4mi','ATPS4m');

if length(strmatch('EX_glc[e]',modelClosed.rxns))>0
    modelClosed.rxns{find(ismember(modelClosed.rxns,'EX_glc[e]'))} = 'EX_glc_D[e]';
end
% add reaction if it does not exist
[modelClosed, rxnIDexists] = addReaction(modelClosed,'DM_atp_c_',  'h2o[c] + atp[c]  -> adp[c] + h[c] + pi[c] ');
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

modelClosedOri = modelClosed;
TestedRxns = [];

% test for max ATP hydrolysis flux from only o2 and the defined carbon
% source
%% glucose aerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_glc_D[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_glc_D[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{2,1} = strcat(modelName,': ATP yield');
Table_csources{3,1} = strcat(modelName,': ATPS4m yield');
Table_csources{4,1} = 'Theoretical';
Table_csources{5,1} = 'Recon 2.2: ATP yield';
% fill in results
k = 2;
Table_csources{1,k} = 'glc - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
Table_csources{4,k} = '31';
Table_csources{5,k} = '32';
k = k+1; clear FBA

% glc anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
%modelClosed.lb(find(ismember(modelClosed.rxns,'EX_pi[e]'))) = -1000;
%modelClosed = addExchangeRxn(modelClosed,{'glc_D[e]'});
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_glc_D[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_glc_D[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
% fill in results
Table_csources{1,k} = 'glc - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
Table_csources{4,k} = '2';
Table_csources{5,k} = '2';
k = k+1; clear FBA


%% glutamine aerobic
modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_gln_L[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_gln_L[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
% fill in results
Table_csources{1,k} = 'gln_L - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
Table_csources{4,k} = 'NA';
Table_csources{5,k} = 'NA';
k = k+1; clear FBA

% gln anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
%modelClosed.lb(find(ismember(modelClosed.rxns,'EX_pi[e]'))) = -1000;
%modelClosed = addExchangeRxn(modelClosed,{'glc_D[e]'});
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_gln_L[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_gln_L[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
% fill in results
Table_csources{1,k} = 'gln_L - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
Table_csources{4,k} = 'NA';
Table_csources{5,k} = 'NA';
k = k+1; clear FBA

%% fru aerobic

modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_fru[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_fru[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'fru - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m')))); k = k+1; clear FBA

% fru anaerobic
modelClosed = changeObjective(modelClosed,'DM_atp_c_');
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_fru[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_fru[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'fru - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m')))); k = k+1; clear FBA

%% but aerobic
modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_but[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_but[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];

Table_csources{1,k} = 'but - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>=0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '21.5';
Table_csources{5,k} = '22';
k = k+1; clear FBA
% but anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_but[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_but[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'but - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '0';
Table_csources{5,k} = '0';
k = k+1; clear FBA

% caproic aerobic
modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_caproic[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_caproic[e]'))) = -1;
%
FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'caproic - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '35.25';
Table_csources{5,k} = '36';
k = k+1; clear FBA
% caproic anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_caproic[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_caproic[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'caproic - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '0';
Table_csources{5,k} = '0';
k = k+1; clear FBA

% octa aerobic
modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_octa[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_octa[e]'))) = -1;
%
FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'octa - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '49';
Table_csources{5,k} = '50';
k = k+1; clear FBA
% octa anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
modelClosed.c = zeros(length(modelClosed.rxns),1);
modelClosed = changeObjective(modelClosed,'DM_atp_c_');
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_octa[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_octa[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'octa - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '0';
Table_csources{5,k} = '0';
k = k+1; clear FBA
% dca aerobic
modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
modelClosed.c = zeros(length(modelClosed.rxns),1);
modelClosed = changeObjective(modelClosed,'DM_atp_c_');
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_dca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_dca[e]'))) = -1;
%
FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'dca - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '62.75';
Table_csources{5,k} = '64';
k = k+1; clear FBA
% dca anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_dca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_dca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'dca - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '0';
Table_csources{5,k} = '0';
k = k+1; clear FBA

% ddca aerobic
modelClosed = modelClosedOri;
modelClosed.c = zeros(length(modelClosed.rxns),1);
modelClosed = changeObjective(modelClosed,'DM_atp_c_');
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_ddca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_ddca[e]'))) = -1;
%
FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'ddca - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '76.5';
Table_csources{5,k} = '82.5';
k = k+1; clear FBA
% ddca anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_ddca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_ddca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'ddca - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '0';
Table_csources{5,k} = '0';
k = k+1; clear FBA

% ttdca aerobic
modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_ttdca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_ttdca[e]'))) = -1;
%
FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'ttdca - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '90.25';
Table_csources{5,k} = '92';
k = k+1; clear FBA
% ddca anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_ttdca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_ttdca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];

Table_csources{1,k} = 'ttdca - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '0';
Table_csources{5,k} = '0';
k = k+1; clear FBA

%hdca aerobic
modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_hdca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_hdca[e]'))) = -1;
%
FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'hdca - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '104';
Table_csources{5,k} = '106.75';
k = k+1; clear FBA
% ddca anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_hdca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_hdca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'hdca - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '0';
Table_csources{5,k} = '0';
k = k+1; clear FBA

% ocdca aerobic
modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_ocdca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_ocdca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'ocdca - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '117.75';
Table_csources{5,k} = '120';
k = k+1; clear FBA
% ddca anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_ocdca[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_ocdca[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'ocdca - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '0';
Table_csources{5,k} = '0';
k = k+1; clear FBA
% arach aerobic
modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_arach[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_arach[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'arach - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '131.5';
Table_csources{5,k} = '134';
k = k+1; clear FBA
% ddca anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_arach[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_arach[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'arach - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end

Table_csources{4,k} = '0';
Table_csources{5,k} = '0';
k = k+1; clear FBA

% docosac aerobic
modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_docosac[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_docosac[e]'))) = -1;
%
FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'docosac - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '145.25';
Table_csources{5,k} = '147.25';
k = k+1; clear FBA
% ddca anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_docosac[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_docosac[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'docosac - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '0';
Table_csources{5,k} = '0';
k = k+1; clear FBA

% lgnc aerobic
modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_lgnc[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_lgnc[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'lgnc - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '159';
Table_csources{5,k} = '160.5';
k = k+1; clear FBA
% ddca anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
modelClosed.c = zeros(length(modelClosed.rxns),1);
modelClosed = changeObjective(modelClosed,'DM_atp_c_');
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_lgnc[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_lgnc[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'lgnc - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '0';
Table_csources{5,k} = '0';
k = k+1; clear FBA

% hexc aerobic
modelClosed = modelClosedOri;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = -1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_hexc[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_hexc[e]'))) = -1;

%
FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];

Table_csources{1,k} = 'hexc - aerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '172.75';
Table_csources{5,k} = '170.75';
k = k+1; clear FBA
% ddca anaerobic
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_o2[e]'))) = 0;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = -1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_h2o[e]'))) = 1000;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_co2[e]'))) = 1000;
modelClosed.lb(find(ismember(modelClosed.rxns,'EX_hexc[e]'))) = -1;
modelClosed.ub(find(ismember(modelClosed.rxns,'EX_hexc[e]'))) = -1;

FBA = optimizeCbModel(modelClosed,'max','zero');
TestedRxns = [TestedRxns; modelClosed.rxns(find(FBA.x))];
Table_csources{1,k} = 'hexc - anaerobic';
Table_csources(2,k) = num2cell(FBA.f);
if length(FBA.x)>0
    Table_csources(3,k) = num2cell(FBA.x(find(ismember(modelClosed.rxns,'ATPS4m'))));
end
Table_csources{4,k} = '0';
Table_csources{5,k} = '0';
k = k+1; clear FBA
Table_csources=Table_csources';
TestedRxns = unique(TestedRxns);
TestedRxns = intersect(model.rxns,TestedRxns); % only those reactions that are also in modelOri not those that have been added to the network
PercTestedRxns = length(TestedRxns)*100/length(model.rxns);
