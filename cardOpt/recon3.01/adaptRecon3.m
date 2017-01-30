function [model_adapted, addedReactions, removedReactions] = adaptRecon3(model);

% model_adapted = adaptRecon3(model)
% Amend Recon3 to Recon3.01 by adding/removing reactions/metabolites

% INPUT
% model = Cobra model (i.e. Recon3)
%
% OUTPUT
% model_adapted = Cobra model adapted by adding/removing
%                 reactions/metabolites
% varargout{1}  = added reactions
% varargout{2}  = removed reactions
% A. Nicolae, June 2016
% D. El Assal, October 2016

model_adapted = model;
solver = 'gurobi6'
changeCobraSolver(solver, 'LP');

%% Virtual Reaction / Potential Definition

% Remove all reactions that contain "metabolites" are not really
%metabolites, but look as if they try to mimic some change in potential:
%metList = model.mets(find(model.SInConsistentMetBool));
metList = {'HC02111[c]'; 'HC02111[m]'; 'HC02112[r]'; 'HC02112[c]'; ...
    'HC02112[m]'; 'HC02112[x]'; 'HC02113[r]'; 'HC02113[c]'; ...
    'HC02113[m]'; 'HC02113[x]'; 'HC02114[c]'; 'HC02115[m]'; 'HC02115[c]';...
    'Temp001[c]'; 'HC01797[c]'}; 
rxns2remove = findRxnsFromMets(model, metList);
model_adapted = removeRxns(model_adapted, rxns2remove);

%% Other inconsistent metabolites:
metList1 = {'M03164[c]'; 'CE2726[c]'; 'dha[c]'; 'dad_2[l]'; 'glgchlo[c]'};
rxnList1 = findRxnsFromMets(model, metList1);
indList1 = findMetIDs(model, metList1);

%Identify the metabolites that are either inconsistent or that have unknown
%consistency:
metBool=~model.SConsistentMetBool;
%Use findMinimalLeakageMode to identify reactions that give rise to a leak
%or siphon:
modelBoundsFlag=0;
epsilon=1e-4;
printLevel=2;
[Vp,Yp,statp,Vn,Yn,statn] = findMinimalLeakageMode(model, metBool,...
        modelBoundsFlag,epsilon,printLevel);
    
% % Testing metBool with one entry at a time:
%  for i = 1:length(indList1);
%      model.metBool1 = zeros(length(model.mets),1);
%      model.metBool1(indList1(i),1) = 1;
%      [~,~,statp,~,~,statn] = findMinimalLeakageMode(model, model.metBool1);
%      statp(i,1) = statp;
%      statn(i,1) = statn;
%  end
% %% Biomass demand reactions
% 
% lipids_list = {'chsterol[c]', ...
%     'pail_hs[c]',...
%     'ps_hs[c]',...
%     'sphmyln_hs[c]',...
%     'clpn_hs[c]',...
%     'pe_hs[c]', ...
%     'pchol_hs[c]'}; % lipids for biomass synthesis
% 
% aa_list = {'glu_L[c]', 'asp_L[c]','ala_L[c]', 'gly[c]','ser_L[c]',...
%     'thr_L[c]','arg_L[c]','phe_L[c]','pro_L[c]','tyr_L[c]', 'lys_L[c]', 'his_L[c]', ...
%     'leu_L[c]', 'ile_L[c]'}; % amino acids demanded for proteins
% ntRNA_list  = {'cmp[c]', 'amp[c]','gmp[c]', 'ump[c]'}; % nucleic bases
% neuromelanin_rxns = {'NM_1','NM_5', 'NM_6', 'NM_7', 'NM_2', 'NM_4', 'NM_3', 'NM_8', 'DM_neuromelanin(c)'}; % Recon3 rxns for neuromelanin
% neuromelanin_mets = {'CE1562[c]','CE5026[c]', 'CE1261[c]','4glu56dihdind[c]',...
%     'ind56qn[c]', '5cysdopa[c]', 'CE5025[c]', 'CE4888[c]'}; % metabolites demanded for neuromelanin synthesis
% 
% 
% % Add demand rxns for lipids
% for i = 1:length(lipids_list);
%     curr_lipid = lipids_list{i};
%     curr_DM_rxn = strcat('DM_lipid_', curr_lipid(1:end-3), '(c)');
%     irxn = findRxnIDs(model, curr_DM_rxn);
%     if irxn == 0 % add only if the curr rxn is not in the model
%         [~, rxnIDexists] = addReaction(model_adapted, curr_DM_rxn, curr_lipid);
%         if isempty(rxnIDexists)
%             [model_adapted] = addReaction(model_adapted, curr_DM_rxn, curr_lipid);
%             model_adapted = changeRxnBounds(model_adapted, curr_DM_rxn, 0, 'l');
%             model_adapted = changeRxnBounds(model_adapted, curr_DM_rxn, 100, 'u');
%         end
%     end
% end
% 
% % Add demand rxns for proteins
% for i = 1:length(aa_list);
%     curr_aa          = aa_list{i};
%     curr_DM_Prxn     = strcat('DM_protein_', curr_aa(1:end-3), '(c)');
%     irxn = findRxnIDs(model, curr_DM_Prxn);
%     if irxn == 0 % add only if the curr rxn is not in the model
%         [~, rxnIDexists] = addReaction(model_adapted, curr_DM_Prxn, curr_aa);
%         if isempty(rxnIDexists)
%             model_adapted    = addReaction(model_adapted, curr_DM_Prxn, curr_aa);
%             model_adapted    = changeRxnBounds(model_adapted, curr_DM_Prxn, 0, 'l');
%             model_adapted    = changeRxnBounds(model_adapted, curr_DM_Prxn, 100, 'u');
%         end
%     end
% end
% 
% % Add demand rxns for nucleic acids
% for i = 1:length(ntRNA_list);
%     curr_ntRNA = ntRNA_list{i};
%     curr_DM_RNArxn = strcat('DM_RNA_', curr_ntRNA(1:end-3), '(c)');
%     irxn = findRxnIDs(model, curr_DM_RNArxn);
%     if irxn == 0 % add only if the curr rxn is not in the original model
%         [~, rxnIDexists] = addReaction(model_adapted, curr_DM_RNArxn, curr_ntRNA);
%         if isempty(rxnIDexists)
%             model_adapted = addReaction(model_adapted, curr_DM_RNArxn, curr_ntRNA);
%             model_adapted = changeRxnBounds(model_adapted, curr_DM_RNArxn, 0, 'l');
%             model_adapted = changeRxnBounds(model_adapted, curr_DM_RNArxn, 100, 'u');
%         end
%     end
% end
% 
% %% Neuromelanin demand reactions
% 
% % Remove neuromelanin rxns
% model_adapted = removeRxns(model_adapted, neuromelanin_rxns);
% 
% % Add neuromelanin precursor demand rxns
% for i = 1:length(neuromelanin_mets);
%     curr_neuroPrec   = neuromelanin_mets{i};
%     curr_DM_Nrxn     = strcat('DM_neuromelanin_', curr_neuroPrec(1:end-3), '(c)');
%     irxn = findRxnIDs(model, curr_DM_Nrxn);
%     if irxn == 0 % add only if the curr rxn is not in the original model
%         [~, rxnIDexists] = addReaction(model_adapted, curr_DM_Nrxn, curr_neuroPrec);
%         if isempty(rxnIDexists)
%             model_adapted    = addReaction(model_adapted, curr_DM_Nrxn, curr_neuroPrec);
%             model_adapted    = changeRxnBounds(model_adapted, curr_DM_Nrxn, 0, 'l');
%             model_adapted    = changeRxnBounds(model_adapted, curr_DM_Nrxn, 100, 'u');
%         end
%     end
% end


%% Summary of reactions added/removed:

addedReactions = setdiff(model_adapted.rxns, model.rxns); % added reactions
removedReactions = setdiff(model.rxns, model_adapted.rxns); % removed reactions