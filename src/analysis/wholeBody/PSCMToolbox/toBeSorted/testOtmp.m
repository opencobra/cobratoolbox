%
% modelClosed = addReactionOri(modelClosed, 'H2Ot','h2o[e] <=> h2o[c]');
% modelClosed = addReactionOri(modelClosed, 'H2Otm','h2o[c] <=> h2o[m]');
% modelClosed = addReactionOri(modelClosed,'O2t','o2[e] <=> o2[c]');
% modelClosed = addReactionOri(modelClosed, 'O2tm','o2[c] <=> o2[m]');
% modelClosed = addReactionOri(modelClosed,'CO2tm','co2[c] <=> co2[m]');%heart
% modelClosed = addReactionOri(modelClosed,'CO2t','co2[e] <=> co2[c]');%heart
%
% modelClosed = addReactionOri(modelClosed,'PYRt2m',	'h[c] + pyr[c] -> h[m] + pyr[m]');%muscle
% modelClosed = addReactionOri(modelClosed,'L_LACtcm'	,'lac_L[c] -> lac_L[m]');%NA
% modelClosed = addReactionOri(modelClosed,'LDH_Lm'	,'nad[m] + lac_L[m] <=> h[m] + nadh[m] + pyr[m]');%NA
% modelClosed = addReactionOri(modelClosed,'SUCCt2m',	'pi[m] + succ[c] <=> pi[c] + succ[m]');%NA
% modelClosed = addReactionOri(modelClosed,'GLUt2m','h[c] + glu_L[c]  <=> h[m] + glu_L[m]');%muscle
% modelClosed = addReactionOri(modelClosed,'r0819','akg[c] + succ[m] <=> akg[m] + succ[c]');% lung
% modelClosed = addReactionOri(modelClosed,'r0191','utp[c] + f6p[c] -> h[c] + udp[c] + fdp[c]');%lung?
% modelClosed = addReactionOri(modelClosed,'GLCt1r','glc_D[e] <=> glc_D[c]');%lung?
% modelClosed = addReactionOri(modelClosed,'r0509','q10[m] + succ[m] -> q10h2[m] + fum[m]');%lung?
% modelClosed = addReactionOri(modelClosed,'LDH_L','nad[c] + lac_L[c] <=> h[c] + pyr[c] + nadh[c]');
% modelClosed = addReactionOri(modelClosed,'DCK1m', 'atp[m] + dcyt[m] <=> h[m] + adp[m] + dcmp[m]');%lung
% modelClosed = addReactionOri(modelClosed,'VALTA','akg[c] + val_L[c] <=> glu_L[c] + 3mob[c]');
% modelClosed = addReactionOri(modelClosed,'DCMPtm','dcmp[m] <=> dcmp[c]');%lung
% modelClosed = addReactionOri(modelClosed,'VALTAm','akg[m] + val_L[m] <=> glu_L[m] + 3mob[m]');
% modelClosed = addReactionOri(modelClosed,'HMR_8475','dcyt[c] <=> dcyt[m]');%lung
% modelClosed = addReactionOri(modelClosed,'VALt5m','val_L[c]  <=> val_L[m]');
% modelClosed = addReactionOri(modelClosed,'r0377','atp[c] + dcyt[c] -> h[c] + adp[c] + dcmp[c]');%heart
% modelClosed = addReactionOri(modelClosed,'3MOBt2im','h[c] + 3mob[c] -> h[m] + 3mob[m]');%lung?
% modelClosed = addReactionOri(modelClosed, 'r0165','h[c] + udp[c] + pep[c] -> pyr[c] + utp[c]');
% modelClosed = addReactionOri(modelClosed, 'SUCCt2m','pi[m] + succ[c] <=> pi[c] + succ[m]');
%

%   modelClosed = addReactionOri(modelClosed, 'AKGDm','akg[m] + nad[m] + coa[m] -> nadh[m] + co2[m] + succoa[m]');
%   modelClosed = addReactionOri(modelClosed, 'CSm','h2o[m] + accoa[m] + oaa[m] -> h[m] + coa[m] + cit[m]');
%   modelClosed = addReactionOri(modelClosed, 'ENO','2pg[c] <=> h2o[c] + pep[c]');
%   modelClosed = addReactionOri(modelClosed, 'FBA','fdp[c] <=> dhap[c] + g3p[c]');
%   modelClosed = addReactionOri(modelClosed, 'FUMm','h2o[m] + fum[m] <=> mal_L[m]');
%   modelClosed = addReactionOri(modelClosed, 'GAPD','pi[c] + nad[c] + g3p[c] <=> h[c] + nadh[c] + 13dpg[c]');
%   modelClosed = addReactionOri(modelClosed,   'GLCt1r','glc_D[e] <=> glc_D[c]');
%   modelClosed = addReactionOri(modelClosed,  'GLUt2m','h[c] + glu_L[c] <=> h[m] + glu_L[m]');
%   modelClosed = addReactionOri(modelClosed,       'ICDHxm','nad[m] + icit[m] -> akg[m] + nadh[m] + co2[m]');
%   modelClosed = addReactionOri(modelClosed, 'MDHm','nad[m] + mal_L[m] <=> h[m] + nadh[m] + oaa[m]');
%   modelClosed = addReactionOri(modelClosed,  'PDHm','nad[m] + coa[m] + pyr[m] -> nadh[m] + co2[m] + accoa[m]');
%   modelClosed = addReactionOri(modelClosed, 'PGI','g6p[c] <=> f6p[c]');
%   modelClosed = addReactionOri(modelClosed, 'PGK','atp[c] + 3pg[c] <=> adp[c] + 13dpg[c]');
%   modelClosed = addReactionOri(modelClosed, 'PGM','2pg[c] <=> 3pg[c]');
%   modelClosed = addReactionOri(modelClosed, 'PYK','h[c] + adp[c] + pep[c] -> atp[c] + pyr[c]');
%   modelClosed = addReactionOri(modelClosed, 'SUCOASm','coa[m] + atp[m] + succ[m] <=> adp[m] + pi[m] + succoa[m]');
%   modelClosed = addReactionOri(modelClosed, 'TPI','dhap[c] <=> g3p[c]');
% modelClosed = addReactionOri(modelClosed, 'HEX1','atp[c] + glc_D[c] -> h[c] + adp[c] + g6p[c]');
% modelClosed = addReactionOri(modelClosed,'ACONTm','cit[m] <=> icit[m]');

% Heart

if strcmp(O{i},'Nkcells')
    model = OrganCompendium.(O{i}).modelAllComp;
    model.lb(find(model.lb<0))=-1000;
    model.ub(find(model.ub<0))=0;
    model.ub(find(model.ub>0))=1000;
    model.lb(find(model.lb>0))=0;
    % [X,TestSolutionName] = Test4HumanFctExtv4(model,'Harvey');
    resultsFileName = strcat(gender,O{i});
    if strcmp('Brain',O{i}) || strcmp('Scord',O{i})
        extraCellCompIn = '[csf]';
        extraCellCompOut = '[csf]';
    elseif ~isempty(find(~cellfun(@isempty,strfind(model.rxns,'[bp]')))) && ~strcmp('Liver',O{i})
        extraCellCompIn = '[bc]';
        % the out compartment does not matter as all out are anyway open
        extraCellCompOut = '[bp]';
    elseif ~isempty(find(~cellfun(@isempty,strfind(model.rxns,'[bd]')))) && ~strcmp('Liver',O{i})
        extraCellCompIn = '[bc]';
        % the out compartment does not matter as all out are anyway open
        extraCellCompOut = '[bd]';
    else
        extraCellCompIn = '[bc]';
        % the out compartment does not matter as all out are anyway open
        extraCellCompOut = '[bc]';
    end
    %NOTE I have to test also Liver with bp input
    
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
    
    modelClosed = model;
    % prepare models for test - these changes are needed for the different
    % recon versions to match the rxn abbr definitions in this script
    modelClosed.rxns = regexprep(modelClosed.rxns,'\(','\[');
    modelClosed.rxns = regexprep(modelClosed.rxns,'\)','\]');
    modelClosed.mets = regexprep(modelClosed.mets,'\(','\[');
    modelClosed.mets = regexprep(modelClosed.mets,'\)','\]');
    modelClosed.rxns = regexprep(modelClosed.rxns,'ATPS4mi','ATPS4m');
    
    % replace older abbreviation of glucose exchange reaction with the one used
    % in this script
    if length(strmatch(strcat('EX_glc',extraCellCompIn),modelClosed.rxns))>0
        modelClosed.rxns{find(ismember(modelClosed.rxns,strcat('EX_glc',extraCellCompIn)))} = strcat('EX_glc_D',extraCellCompIn);
    end
    if length(strmatch(strcat('EX_glc',extraCellCompOut),modelClosed.rxns))>0
        modelClosed.rxns{find(ismember(modelClosed.rxns,strcat('EX_glc',extraCellCompOut)))} = strcat('EX_glc_D',extraCellCompOut);
    end
    
    % add reaction if it does not exist
    [modelClosed, rxnIDexists] = addReactionOri(modelClosed,'DM_atp_c_',  'h2o[c] + atp[c]  -> adp[c] + h[c] + pi[c]');
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
    modelClosed = modelClosedOri;
    modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_o2',extraCellCompIn)))) = -1000;
    modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_h2o',extraCellCompIn)))) = -1000;
    modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_h2o',extraCellCompOut)))) = 1000;
    modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_co2',extraCellCompOut)))) = 1000;
    modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_glc_D',extraCellCompIn)))) = -1;
    modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_glc_D',extraCellCompIn)))) = -1;
    
    
    modelClosed = addReactionOri(modelClosed, 'H2Ot','h2o[e] <=> h2o[c]');
    modelClosed = addReactionOri(modelClosed, 'H2Otm','h2o[c] <=> h2o[m]');
    modelClosed = addReactionOri(modelClosed,'O2t','o2[e] <=> o2[c]');
    modelClosed = addReactionOri(modelClosed, 'O2tm','o2[c] <=> o2[m]');
    modelClosed = addReactionOri(modelClosed,'CO2tm','co2[c] <=> co2[m]');%heart
    modelClosed = addReactionOri(modelClosed,'CO2t','co2[e] <=> co2[c]');%heart
    
    modelClosed = addReactionOri(modelClosed,'L_LACtcm'	,'lac_L[c] -> lac_L[m]');%NA
    modelClosed = addReactionOri(modelClosed,'LDH_Lm'	,'nad[m] + lac_L[m] <=> h[m] + nadh[m] + pyr[m]');%NA
    modelClosed = addReactionOri(modelClosed,'GLCt1r','glc_D[e] <=> glc_D[c]');%lung?
    modelClosed = addReactionOri(modelClosed,'r0377','atp[c] + dcyt[c] -> h[c] + adp[c] + dcmp[c]');%heart
    modelClosed = addReactionOri(modelClosed,'VALTA','akg[c] + val_L[c] <=> glu_L[c] + 3mob[c]');
    modelClosed = addReactionOri(modelClosed,'VALTAm','akg[m] + val_L[m] <=> glu_L[m] + 3mob[m]');
    modelClosed = addReactionOri(modelClosed,'VALt5m','val_L[c]  <=> val_L[m]');
    modelClosed = addReactionOri(modelClosed,'ATPtm','adp[c] + atp[m] -> atp[c] + adp[m]');
    modelClosed = addReactionOri(modelClosed,'EX_glc_D[bc]','glc_D[bc] <=>');
    modelClosed = addReactionOri(modelClosed,'Tr_EX_glc_D[e]_[bc]','glc_D[e] <=> glc_D[bc]');
    %
      modelClosed = addReactionOri(modelClosed,'PYRt2m',	'h[c] + pyr[c] -> h[m] + pyr[m]');%muscle
      modelClosed = addReactionOri(modelClosed,'L_LACtcm'	,'lac_L[c] -> lac_L[m]');%NA
      modelClosed = addReactionOri(modelClosed,'LDH_Lm'	,'nad[m] + lac_L[m] <=> h[m] + nadh[m] + pyr[m]');%NA
      modelClosed = addReactionOri(modelClosed,'LDH_L','nad[c] + lac_L[c] <=> h[c] + pyr[c] + nadh[c]');
     modelClosed = addReactionOri(modelClosed,'SUCCt2m',	'pi[m] + succ[c] <=> pi[c] + succ[m]');%NA
     modelClosed = addReactionOri(modelClosed,'r0819','akg[c] + succ[m] <=> akg[m] + succ[c]');% lung
          modelClosed = addReactionOri(modelClosed,'GLUt2m','h[c] + glu_L[c]  <=> h[m] + glu_L[m]');%muscle
       modelClosed = addReactionOri(modelClosed,'r0191','utp[c] + f6p[c] -> h[c] + udp[c] + fdp[c]');%lung?
    modelClosed = addReactionOri(modelClosed,'GLCt1r','glc_D[e] <=> glc_D[c]');%lung?
     modelClosed = addReactionOri(modelClosed,'r0509','q10[m] + succ[m] -> q10h2[m] + fum[m]');%lung?
     modelClosed = addReactionOri(modelClosed,'DCK1m', 'atp[m] + dcyt[m] <=> h[m] + adp[m] + dcmp[m]');%lung
    modelClosed = addReactionOri(modelClosed,'DCMPtm','dcmp[m] <=> dcmp[c]');%lung
     modelClosed = addReactionOri(modelClosed,'HMR_8475','dcyt[c] <=> dcyt[m]');%lung
       modelClosed = addReactionOri(modelClosed,'r0377','atp[c] + dcyt[c] -> h[c] + adp[c] + dcmp[c]');%heart
       modelClosed = addReactionOri(modelClosed,'VALTA','akg[c] + val_L[c] <=> glu_L[c] + 3mob[c]');
      modelClosed = addReactionOri(modelClosed,'VALTAm','akg[m] + val_L[m] <=> glu_L[m] + 3mob[m]');
      modelClosed = addReactionOri(modelClosed,'VALt5m','val_L[c]  <=> val_L[m]');
    modelClosed = addReactionOri(modelClosed,'3MOBt2im','h[c] + 3mob[c] -> h[m] + 3mob[m]');%lung?
    modelClosed = addReactionOri(modelClosed, 'r0165','h[c] + udp[c] + pep[c] -> pyr[c] + utp[c]');
    modelClosed = changeRxnBounds(modelClosed, 'DCMPtm',-1000,'l');
    
                      modelClosed = addReactionOri(modelClosed, 'AKGDm','akg[m] + nad[m] + coa[m] -> nadh[m] + co2[m] + succoa[m]');
                modelClosed = addReactionOri(modelClosed, 'CSm','h2o[m] + accoa[m] + oaa[m] -> h[m] + coa[m] + cit[m]');
                modelClosed = addReactionOri(modelClosed, 'ENO','2pg[c] <=> h2o[c] + pep[c]');
                modelClosed = addReactionOri(modelClosed, 'FBA','fdp[c] <=> dhap[c] + g3p[c]');
                modelClosed = addReactionOri(modelClosed, 'FUMm','h2o[m] + fum[m] <=> mal_L[m]');
                modelClosed = addReactionOri(modelClosed, 'GAPD','pi[c] + nad[c] + g3p[c] <=> h[c] + nadh[c] + 13dpg[c]');
                modelClosed = addReactionOri(modelClosed,   'GLCt1r','glc_D[e] <=> glc_D[c]');
                modelClosed = addReactionOri(modelClosed,  'GLUt2m','h[c] + glu_L[c] <=> h[m] + glu_L[m]');
                modelClosed = addReactionOri(modelClosed,       'ICDHxm','nad[m] + icit[m] -> akg[m] + nadh[m] + co2[m]');
                modelClosed = addReactionOri(modelClosed, 'MDHm','nad[m] + mal_L[m] <=> h[m] + nadh[m] + oaa[m]');
                modelClosed = addReactionOri(modelClosed,  'PDHm','nad[m] + coa[m] + pyr[m] -> nadh[m] + co2[m] + accoa[m]');
                modelClosed = addReactionOri(modelClosed, 'PGI','g6p[c] <=> f6p[c]');
                modelClosed = addReactionOri(modelClosed, 'PGK','atp[c] + 3pg[c] <=> adp[c] + 13dpg[c]');
                modelClosed = addReactionOri(modelClosed, 'PGM','2pg[c] <=> 3pg[c]');
                modelClosed = addReactionOri(modelClosed, 'PYK','h[c] + adp[c] + pep[c] -> atp[c] + pyr[c]');
                modelClosed = addReactionOri(modelClosed, 'SUCOASm','coa[m] + atp[m] + succ[m] <=> adp[m] + pi[m] + succoa[m]');
                modelClosed = addReactionOri(modelClosed, 'TPI','dhap[c] <=> g3p[c]');
              modelClosed = addReactionOri(modelClosed, 'HEX1','atp[c] + glc_D[c] -> h[c] + adp[c] + g6p[c]');
              modelClosed = addReactionOri(modelClosed,'ACONTm','cit[m] <=> icit[m]');
      modelClosed = addReactionOri(modelClosed,'ATPtm','adp[c] + atp[m] -> atp[c] + adp[m]');
          modelClosed = addReactionOri(modelClosed,'EX_glc_D[bc]','glc_D[bc] <=>');
          modelClosed = addReactionOri(modelClosed,'Tr_EX_glc_D[e]_[bc]','glc_D[e] <=> glc_D[bc]');
    
    modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_glc_D',extraCellCompIn)))) = -1;
    modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_glc_D',extraCellCompIn)))) = -1;
    
    
    FBA = optimizeCbModel(modelClosed,'max')
end