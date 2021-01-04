function [resolveBlocked,model]=connectRxnGapfilling(model,database)
% script to connect blocked reactions in reconstruction if possible

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;

resolveBlocked={};
cnt=1;
previousObj=model.rxns(model.c==1);
tol=0.0000001;

% some reconstructions cannot take up ammonia
if ~isempty(find(ismember(model.rxns,'EX_nh4(e)')))
    formula = database.reactions{ismember(database.reactions(:, 1), 'NH4tb'), 3};
    model = addReaction(model, 'NH4tb', 'reactionFormula', formula);
end

% gamma-butyrobetaine and crotonobetaine -> currently blocked. Known to be produced by different gut bacteria
% other groups of bacteria further convert these metabolites -> transport
% out assumed
% PMID: 25440057
% gamma-butyrobetaine is produced by same enzyme as crotonobetaine
% KEGG Enzyme: 2.8.3.21

% Reactions that can unblock the potentially blocked reaction in the
% first column. The solutions were determined manually.
rxns2Unblock={
    'N2OFO','EX_n2(e)','N2t','EX_n2o(e)','N2Ot',[],[],[],[],[]
    'NIT_n1p4','EX_n2(e)','N2t','EX_h2(e)','H2td','EX_nh4(e)','NH4tb',[],[],[]
    'N2OO','EX_no(e)','EX_n2o(e)',[],[],[],[],[],[],[]
    'NHFRBOr','EX_no(e)','NOt','EX_n2o(e)','N2Ot',[],[],[],[],[]
    'NHFRBO','EX_no(e)','NOt','EX_n2o(e)','N2Ot',[],[],[],[],[]
    'CRNCBCT','CRNBTCT','BBTCOAOX','EX_gbbtn(e)','GBBTNt','EX_ctbt(e)','CTBTt','EX_crn(e)','CRNabc',[]
    '3HACPR1','DM_btn',[],[],[],[],[],[],[],[]
    'BTS4','DM_dad_5','sink_s','DM_btn',[],[],[],[],[],[]
    'AMAOTr','DM_AMOB',[],[],[],[],[],[],[],[]
    'DEXTRINASE','EX_dextrin(e)','DEXTRINabc',[],[],[],[],[],[],[]
    'MANA4','EX_mantr(e)','MANTRabc',[],[],[],[],[],[],[]
    'STYSGH','EX_stys(e)','STYSabc',[],[],[],[],[],[],[]
    'AHEXASE3','EX_chtbs(e)','CHTBSabc',[],[],[],[],[],[],[]
    'GLXO1','EX_oxa(e)','OXAte',[],[],[],[],[],[],[]
    'DHNPA','EX_gcald(e)','GCALDt',[],[],[],[],[],[],[]
    'AHMMPS','EX_gcald(e)','GCALDt',[],[],[],[],[],[],[]
    'AB6PGH','DM_HQN',[],[],[],[],[],[],[],[]
    'MTAN','DM_5MTR',[],[],[],[],[],[],[],[]
    'THZPSN','DM_4HBA',[],[],[],[],[],[],[],[]
    'GCDCHOLBHSe','EX_dgchol(e)','EX_gly(e)','EX_C02528(e)',[],[],[],[],[],[]
    'GCHOLBHSe','EX_gchola(e)','EX_gly(e)','EX_cholate(e)',[],[],[],[],[],[]
    'TCHOLBHSe','EX_tchola(e)','EX_taur(e)','EX_cholate(e)',[],[],[],[],[],[]
    'TCDCHOLBHSe','EX_tdchola(e)','EX_taur(e)','EX_C02528(e)',[],[],[],[],[],[]
    'TDCABSHe','EX_tdechola(e)','EX_dchac(e)','EX_taur(e)',[],[],[],[],[],[]
    'PDHbr','PDHa',[],[],[],[],[],[],[],[]
    'PMACPME','EACPR2','3HACPR2','3OAACPR2','GACPCD','EACPR1','3HACPR1','3OAACPR1','MALCOACD','MALCOAMT'
    'PLACOR','EX_plac(e)','PLACt2r',[],[],[],[],[],[],[]
    % connect benzoate metabolism
    'MNDLMDH','EX_rmndlmd(e)','RMNDLMDt2r','EX_bz(e)','BZte',[],[],[],[],[]
    'TFDXNOR','EX_tln(e)','TLNt2r','EX_bz(e)','BZte',[],[],[],[],[]
    'BZAMAH','EX_bzam(e)','BZAMt2r','EX_bz(e)','BZte',[],[],[],[],[]
    'BOCLUH','EX_bocbnleu(e)','BOCBNLEUt2r','EX_bz(e)','BZte',[],[],[],[],[]
    };
rxnsInModel=intersect(model.rxns,rxns2Unblock(:,1),'stable');
if ~isempty(ver('distcomp')) && any(strcmp(solver,{'ibm_cplex','tomlab_cplex','cplex_direct'}))
    [minFlux, maxFlux, ~, ~] = fastFVA(model, 0, 'max', 'ibm_cplex', ...
        rxnsInModel, 'S');
else
    [minFlux, maxFlux] = fluxVariability(model, 0, 'max', rxnsInModel);
end
for i=1:length(rxnsInModel)
    if minFlux(i) < tol && maxFlux(i) < tol
        gapfilledRxns=rxns2Unblock(find(strcmp(rxns2Unblock(:,1),rxnsInModel{i})),2:end);
        gapfilledRxns=gapfilledRxns(~cellfun('isempty',gapfilledRxns));
        for j=1:length(gapfilledRxns)
            if ~any(ismember(model.rxns, gapfilledRxns{j}))
                formula = database.reactions{ismember(database.reactions(:, 1), gapfilledRxns{j}), 3};
                model = addReaction(model, gapfilledRxns{j}, 'reactionFormula', formula);
                resolveBlocked{cnt,1}=gapfilledRxns{j};
                cnt=cnt+1;
            end
        end
    end
end
% Metabolites that are commonly dead ends in the first column, and reactions
% that can connect them. Passive diffusion of fatty acid metabolites is
%  assumed. The solutions were determined manually.
mets2Connect={'ddca[c]','EX_ddca(e)','DDCAt';'ttdca[c]','EX_ttdca(e)','TTDCAtr';'ttdcea[c]','EX_ttdcea(e)','TTDCEAte';'hdca[c]','EX_hdca(e)','HDCAtr';'hdcea[c]','EX_hdcea(e)','HDCEAtr';'ocdca[c]','EX_ocdca(e)','OCDCAtr';'ocdcea[c]','EX_ocdcea(e)','OCDCEAtr';'kdo2lipid4L[c]','DM_kdo2lipid4L(c)',[];'teich_45_BS[c]','DM_teich_45_BS(c)',[];'2hyoxplac[c]','EX_2hyoxplac(e)','2HYOXPLACt2r';'3hcinnm[c]','EX_3hcinnm(e)','3HCINNMt2r';'dhcinnm[c]','EX_dhcinnm(e)','DHCINNMt2r';'3hphac[c]','EX_3hphac(e)','33HPHACt2r';'34dhpha[c]','EX_34dhpha(e)','34DHPHAt2r';'3hpppn[c]','EX_3hpppn(e)','HPPPNte';'dhpppn[c]','EX_dhpppn(e)','DHPPPNt2r';'4hoxpacd[c]','EX_4hoxpacd(e)','4HOXPACDt2r'};
for i=1:size(mets2Connect,1)
    if any(ismember(model.mets,mets2Connect{i,1}))
        gapfilledRxns=mets2Connect(i,2:end);
        gapfilledRxns=gapfilledRxns(~cellfun('isempty',gapfilledRxns));
        for j=1:length(gapfilledRxns)
            if ~any(ismember(model.rxns, gapfilledRxns{j}))
                formula = database.reactions{ismember(database.reactions(:, 1), gapfilledRxns{j}), 3};
                model = addReaction(model, gapfilledRxns{j}, 'reactionFormula', formula);
                resolveBlocked{cnt,1}=gapfilledRxns{j};
                cnt=cnt+1;
            end
        end
    end
end

% test on unlimited medium if the gapfilled reactions are also blocked,
% delete them if that is the case
model=changeRxnBounds(model,model.rxns(strmatch('EX_',model.rxns)),-1000,'l');
model=changeObjective(model,previousObj);
if ~isempty(ver('distcomp')) && any(strcmp(solver,{'ibm_cplex','tomlab_cplex','cplex_direct'}))
    [minFlux, maxFlux, ~, ~] = fastFVA(model, 0, 'max', 'ibm_cplex', ...
        resolveBlocked, 'S');
else
    [minFlux, maxFlux] = fluxVariability(model, 0, 'max', resolveBlocked);
end

cnt=1;
delArray=[];
if ~isempty(resolveBlocked)
    for i=1:length(resolveBlocked)
        if abs(minFlux(i))<tol && abs(maxFlux(i))<tol
            model=removeRxns(model,resolveBlocked{i,1});
            delArray(cnt,1)=i;
            cnt=cnt+1;
        end
    end
end
if ~isempty(delArray)
    resolveBlocked(delArray,:)=[];
end

end
