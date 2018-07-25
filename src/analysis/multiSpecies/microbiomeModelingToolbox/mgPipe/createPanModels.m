function createPanModels(agoraPath,panPath,taxonLevel)
% This function creates pan-models for all unique taxa (e.g., species)
% included in the AGORA resource. If reconstructions of multiple strains
% in a given taxon are present, the reactions in these reconstructions will
% be combined into a pan-reconstruction. The pan-biomass reactions will be
% built from the average of all biomasses. Futile cycles that result from
% the newly combined reaction content are removed by setting certain
% reactions irreversible. These reactions have been determined manually.
% NOTE: Futile cycle removal has only been tested at the species and genus
% level. Pan-models at higher taxonomical levels (e.g., family) may
% contain futile cycles and produce unrealistically high ATP flux.
% The pan-models can be used an input for mgPipe if taxon abundance data is
% available at a higher level than strain, e.g., species, genus.
%
% USAGE:
% createPanModels(agoraPath,panPath,taxonLevel)
%
% REQUIRED INPUTS:
% agoraPath     String containing the path to the folder where the AGORA
%               reconstructions are located. Needs to end in '\' or '/'
%               depending on operating system.
% panPath       String containing the path to an empty folder that the
%               created pan-models will be stored in. Needs to end in '\'
%               or '/' depending on operating system.
% taxonLevel    String with desired taxonomical level of the pan-models.
%               Allowed inputs are 'Species','Genus','Family','Order',
%               'Class','Phylum'.
%
% Authors
% -Stefania Magnusdottir, 2016
% -Almut Heinken, 06/2018: adapted to function.

%% Create the pan-models
% List all species in the AGORA resource
[~,infoFile,~]=xlsread('AGORA_infoFile.xlsx');
findTaxCol=find(strcmp(infoFile(1,:),taxonLevel));
allTaxa=unique(infoFile(2:end,findTaxCol));
% Remove unclassified organisms
allTaxa(strncmp('unclassified',allTaxa,12))=[];
allTaxa(~cellfun(@isempty,strfind(allTaxa,'bacteri')))
built=ls(panPath);
% Remove models that have already been assembled from the list of models to
% create
built=cellstr(built);
built=strrep(built,'.mat','');
toCreate=setdiff(allTaxa,built);

% Build pan-models
for i=1:size(toCreate,1)
    models=find(ismember(infoFile(:,findTaxCol),toCreate{i,1}));
    if size(models,1) == 1
        model=readCbModel([agoraPath,infoFile{models,1},'.mat']);
        % rename biomass reaction to agree with other pan-models
        bio=find(strncmp(model.rxns,'biomass',7));
        model.rxns{bio,1}='biomassPan';
    elseif size(models,1) > 1
        for j=1:size(models,1)
            model=readCbModel([agoraPath,infoFile{models(j),1},'.mat']);
            bio=find(strncmp(model.rxns,'biomass',7));
            if j==1
                panModel.rxns=model.rxns;
                panModel.grRules=model.grRules;
                panModel.rxnNames=model.rxnNames;
                panModel.subSystems=model.subSystems;
                panModel.lb=model.lb;
                panModel.ub=model.ub;
                forms=printRxnFormula(model,model.rxns,false,false,false,[],false);
                panModel.formulas=forms;
                % biomass products and substrates with coefficients
                bioPro=model.mets(find(model.S(:,bio)>0),1);
                bioProSC=full(model.S(find(model.S(:,bio)>0),bio));
                bioSub=model.mets(find(model.S(:,bio)<0),1);
                bioSubSC=full(model.S(find(model.S(:,bio)<0),bio));
            else
                panModel.rxns=[panModel.rxns ; model.rxns];
                panModel.grRules=[panModel.grRules ; model.grRules];
                panModel.rxnNames=[panModel.rxnNames ; model.rxnNames];
                panModel.subSystems=[panModel.subSystems ; model.subSystems];
                panModel.lb=[panModel.lb ; model.lb];
                panModel.ub=[panModel.ub ; model.ub];
                forms=printRxnFormula(model,model.rxns,false,false,false,[],false);
                panModel.formulas=[panModel.formulas ; forms];
                % biomass products and substrates with coefficients
                bioPro=[bioPro ; model.mets(find(model.S(:,bio)>0),1)];
                bioProSC=[bioProSC ; full(model.S(find(model.S(:,bio)>0),bio))];
                bioSub=[bioSub ; model.mets(find(model.S(:,bio)<0),1)];
                bioSubSC=[bioSubSC ; full(model.S(find(model.S(:,bio)<0),bio))];
            end
        end
        % take out biomass reactions
        bio=find(strncmp(panModel.rxns,'biomass',7));
        panModel.rxns(bio)=[];
        panModel.grRules(bio)=[];
        panModel.rxnNames(bio)=[];
        panModel.subSystems(bio)=[];
        panModel.lb(bio)=[];
        panModel.ub(bio)=[];
        panModel.formulas(bio)=[];
        % set up data matrix for rBioNet
        [uniqueRxns,oldInd]=unique(panModel.rxns);
        rbio.data=cell(size(uniqueRxns,1),14);
        rbio.data(:,1)=num2cell(ones(size(rbio.data,1),1));
        rbio.data(:,2)=uniqueRxns;
        rbio.data(:,3)=panModel.rxnNames(oldInd);
        rbio.data(:,4)=panModel.formulas(oldInd);
        rbio.data(:,6)=panModel.grRules(oldInd);
        rbio.data(:,7)=num2cell(panModel.lb(oldInd));
        rbio.data(:,8)=num2cell(panModel.ub(oldInd));
        rbio.data(:,10)=panModel.subSystems(oldInd);
        rbio.description=cell(7,1);
        % build model with rBioNet
        model = data2model(rbio.data,rbio.description);
        % build biomass reaction from average of all biomasses
        subs = unique(bioSub);
        prods = unique(bioPro);
        bioForm='';
        for s=1:size(subs,1)
            indS=find(ismember(bioSub,subs{s,1}));
            newCoeff=sum(bioSubSC(indS))/j;
            bioForm=[bioForm, num2str(-newCoeff), ' ', subs{s,1}, ' + '];
        end
        bioForm=bioForm(1:end-3);
        bioForm = [bioForm,' -> '];
        for p=1:size(prods,1)
            indP=find(ismember(bioPro,prods{p,1}));
            newCoeff=sum(bioProSC(indP))/j;
            bioForm=[bioForm, num2str(newCoeff), ' ', prods{p,1}, ' + '];
        end
        bioForm=bioForm(1:end-3);
        % add biomass reaction to pan model
        model=addReaction(model,'biomassPan',bioForm);
        model.comments{end+1,1} = '';
        model.citations{end+1,1} = '';
        model.rxnConfidenceScores{end+1,1} = '';
        model.rxnECNumbers{end+1,1} = '';
        model.rxnKEGGID{end+1,1} = '';
    end
    % update some fields to new standards
    model.osenseStr='max';
    if isfield(model,'rxnConfidenceScores')
        model=rmfield(model,'rxnConfidenceScores');
    end
    model.rxnConfidenceScores=zeros(length(model.rxns),1);
    for j=1:length(model.rxns)
        model.subSystems{j,1}=cellstr(model.subSystems{j,1});
        model.rxnKEGGID{j,1}='';
        model.rxnECNumbers{j,1}='';
    end
    for j=1:length(model.mets)
        if strcmp(model.metPubChemID{j,1},'[]') || isempty(model.metPubChemID{j,1})
            model.metPubChemID{j,1}=string;
        end
        if strcmp(model.metChEBIID{j,1},'[]') || isempty(model.metChEBIID{j,1})
            model.metChEBIID{j,1}=string;
        end
        if strcmp(model.metKEGGID{j,1},'[]') || isempty(model.metKEGGID{j,1})
            model.metKEGGID{j,1}=string;
        end
        if strcmp(model.metInChIString{j,1},'[]') || isempty(model.metInChIString{j,1})
            model.metInChIString{j,1}=string;
        end
        if strcmp(model.metHMDBID{j,1},'[]') || isempty(model.metHMDBID{j,1})
            model.metHMDBID{j,1}=string;
        end
    end
    model.metPubChemID=cellstr(model.metPubChemID);
    model.metChEBIID=cellstr(model.metChEBIID);
    model.metKEGGID=cellstr(model.metKEGGID);
    model.metInChIString=cellstr(model.metInChIString);
    model.metHMDBID=cellstr(model.metHMDBID);
    % fill in descriptions
    model=rmfield(model,'description');
    model.description.organism = toCreate{i,1};
    model.description.name = toCreate{i,1};
    model.description.author = 'Stefania Magnusdottir, Almut Heinken, Laura Kutt, Dmitry A. Ravcheev, Eugen Bauer, Alberto Noronha, Kacy Greenhalgh, Christian Jaeger, Joanna Baginska, Paul Wilmes, Ronan M.T. Fleming, and Ines Thiele';
    model.description.date=date;
    
    % Adapt fields to current standard
    model=convertOldStyleModel(model);
    save([panPath,'pan',strrep(toCreate{i,1},' ','_'),'.mat'],'model')
end

%% Remove futile cycles
% Create table with information on reactions to replace to remove futile
% cycles. This information was determined manually by S.M. and A.H.
reactionsToReplace={'if','removed','removed_formula','added','added_formula';'LYSt2r AND LYSt3r','LYSt3r','h[e] + lys_L[c] <=> h[c] + lys_L[e]','LYSt3','h[e] + lys_L[c] -> h[c] + lys_L[e]';'FDHr','FDHr','for[c] + nad[c] <=> co2[c] + nadh[c]','FDH','nad[c] + for[c]  -> nadh[c] + co2[c] ';'GLYO1','GLYO1','h2o[c] + o2[c] + gly[c] <=> nh4[c] + h2o2[c] + glx[c]','GLYO1i','h2o[c] + o2[c] + gly[c] -> nh4[c] + h2o2[c] + glx[c]';'EAR40xr','EAR40xr','but2eACP[c] + h[c] + nadh[c] <=> butACP[c] + nad[c]','EAR40x','but2eACP[c] + h[c] + nadh[c] -> butACP[c] + nad[c]';'PROt2r AND PROt4r','PROt4r','na1[e] + pro_L[e] <=> na1[c] + pro_L[c]','PROt4','na1[e] + pro_L[e]  -> na1[c] + pro_L[c] ';'FOROXAtex AND FORt','FORt','for[e] <=> for[c]',[],[];'NO2t2r AND NTRIR5','NO2t2r','h[e] + no2[e] <=> h[c] + no2[c]','NO2t2','h[e] + no2[e] -> h[c] + no2[c] ';'NOr1mq AND NHFRBOr','NHFRBOr','h[c] + nadh[c] + 2 no[c] <=> h2o[c] + n2o[c] + nad[c]','NHFRBO','h[c] + nadh[c] + 2 no[c] -> h2o[c] + n2o[c] + nad[c]';'NIR AND L_LACDr','L_LACDr','2 ficytC[c] + lac_L[c] <=> 2 focytC[c] + pyr[c] + 2 h[c]','L_LACD','2 ficytC[c] + lac_L[c] -> 2 focytC[c] + pyr[c] + 2 h[c]';'PIt6b AND PIt7','PIt7','3 na1[e] + pi[e]  <=> pi[c] + 3 na1[c] ','PIt7ir','3 na1[e] + pi[e] -> 3 na1[c] + pi[c]';'ABUTt2r AND GLUABUTt7','ABUTt2r','h[e] + 4abut[e]  <=> h[c] + 4abut[c] ','ABUTt2','h[e] + 4abut[e] -> h[c] + 4abut[c]';'ABUTt2r AND ABTAr','ABTAr','4abut[c] + akg[c] <=> glu_L[c] + sucsal[c]','ABTA','4abut[c] + akg[c] -> glu_L[c] + sucsal[c]';'Kt1r AND Kt3r','Kt3r','h[e] + k[c] <=> h[c] + k[e]','Kt3','h[e] + k[c] -> h[c] + k[e]';'CYTDt4 AND CYTDt2r','CYTDt2r','h[e] + cytd[e]  <=> h[c] + cytd[c] ','CYTDt2','cytd[e] + h[e] -> cytd[c] + h[c]';'ASPt2_2 AND ASPt2r','ASPt2r','asp_L[e] + h[e] <=> asp_L[c] + h[c]','ASPte','asp_L[c]  -> asp_L[e] ';'ASPt2_3 AND ASPt2r','ASPt2r','asp_L[e] + h[e] <=> asp_L[c] + h[c]','ASPt2','asp_L[e] + h[e] -> asp_L[c] + h[c]';'FUMt2_2 AND FUMt2r','FUMt2r','fum[e] + h[e] <=> fum[c] + h[c]','FUMt','fum[c] <=> fum[e]';'SUCCt2_2 AND SUCCt2r','SUCCt2r','h[e] + succ[e] <=> h[c] + succ[c]','SUCCt','succ[c] <=> succ[e]';'SUCCt2_3r AND SUCCt2r','SUCCt2r','h[e] + succ[e] <=> h[c] + succ[c]',[],[];'MALFADO AND MDH','MALFADO','fad[c] + mal_L[c] <=> oaa[c] + fadh2[c]','MALFADOi','fad[c] + mal_L[c] -> oaa[c] + fadh2[c]';'MALFADO AND GLXS','MALFADO','fad[c] + mal_L[c] <=> oaa[c] + fadh2[c]','MALFADOi','fad[c] + mal_L[c] -> oaa[c] + fadh2[c]';'r0392 AND GLXCL','r0392','h2o[c] + nad[c] + glyald[c]  <=> 2 h[c] + nadh[c] + glyc_R[c] ','ALDD8x','glyald[c] + h2o[c] + nad[c] -> glyc_R[c] + 2 h[c] + nadh[c]';'HACD1 AND PHPB2','PHPB2','aacoa[c] + h[c] + nadph[c] <=> 3hbcoa[c] + nadp[c]','PHPB2i','aacoa[c] + h[c] + nadph[c] -> 3hbcoa[c] + nadp[c]';'PPCKr AND PPCr','PPCKr','atp[c] + oaa[c] <=> adp[c] + co2[c] + pep[c]','PPCK','atp[c] + oaa[c] -> adp[c] + co2[c] + pep[c]';'PPCKr AND GLFRDO AND FXXRDO','PPCKr','atp[c] + oaa[c] <=> adp[c] + co2[c] + pep[c]','PPCK','atp[c] + oaa[c] -> adp[c] + co2[c] + pep[c]';'BTCOADH AND FDNADOX_H AND ACOAD1','ACOAD1','b2coa[c] + h[c] + nadh[c] <=> btcoa[c] + nad[c]','ACOAD1i','b2coa[c] + h[c] + nadh[c] -> btcoa[c] + nad[c]';'ACKr AND ACEDIPIT AND APAT AND DAPDA AND 26DAPLLAT','26DAPLLAT','26dap_LL[c] + akg[c] <=> h[c] + h2o[c] + thdp[c] + glu_L[c]','26DAPLLATi','h[c] + h2o[c] + thdp[c] + glu_L[c] -> 26dap_LL[c] + akg[c]';'ACKr AND ACEDIPIT AND APAT AND DAPDA','DAPDA','h2o[c] + n6all26d[c] <=> 26dap_LL[c] + ac[c]','DAPDAi','h2o[c] + n6all26d[c] -> 26dap_LL[c] + ac[c]';'MALNAt AND NAt3_1 AND MALt2r','NAt3_1','h[e] + na1[c]  <=> h[c] + na1[e] ','NAt3','h[e] + na1[c] -> h[c] + na1[e]';'MALNAt AND NAt3_1 AND MALt2r','MALt2r','h[e] + mal_L[e] <=> h[c] + mal_L[c]','MALt2','h[e] + mal_L[e] -> h[c] + mal_L[c]';'MALNAt AND NAt3_1 AND MALt2r AND URIt2r AND URIt4','URIt2r','h[e] + uri[e]  <=> h[c] + uri[c] ','URIt2','h[e] + uri[e] -> h[c] + uri[c]';'DADNt2r AND HYXNt','HYXNt','hxan[e]  <=> hxan[c] ','HYXNti','hxan[e] -> hxan[c]';'URIt2r AND URAt2r','URAt2r','h[e] + ura[e] <=> h[c] + ura[c]','URAt2','h[e] + ura[e] -> h[c] + ura[c]';'XANt2r AND URAt2r','URAt2r','h[e] + ura[e] <=> h[c] + ura[c]','URAt2','h[e] + ura[e] -> h[c] + ura[c]';'XANt2r AND CSNt6','CSNt6','csn[e] + h[e] <=> csn[c] + h[c]','CSNt2','csn[e] + h[e] -> csn[c] + h[c]';'XANt2r AND DADNt2r','XANt2r','h[e] + xan[e] <=> h[c] + xan[c]','XANt2','h[e] + xan[e] -> h[c] + xan[c]';'XANt2r AND XPPTr','XPPTr','ppi[c] + xmp[c] <=> prpp[c] + xan[c]','XPPT','prpp[c] + xan[c] -> ppi[c] + xmp[c]';'XANt2r AND PUNP7','XANt2r','h[e] + xan[e] <=> h[c] + xan[c]','XANt2','h[e] + xan[e] -> h[c] + xan[c]';'r1667 AND ARGt2r','ARGt2r','arg_L[e] + h[e] <=> arg_L[c] + h[c]','ARGt2','arg_L[e] + h[e] -> arg_L[c] + h[c]';'GLUt2r AND NAt3_1 AND GLUt4r','GLUt4r','glu_L[e] + na1[e] <=> glu_L[c] + na1[c]','r1144','na1[e] + glu_L[e]  -> na1[c] + glu_L[c] ';'GLYt2r AND NAt3_1 AND GLYt4r','GLYt2r','h[e] + gly[e]  <=> h[c] + gly[c] ','GLYt2','gly[e] + h[e] -> gly[c] + h[c]';'MALNAt AND L_LACNa1t AND L_LACt2r','L_LACt2r','h[e] + lac_L[e]  <=> h[c] + lac_L[c] ','L_LACt2','h[e] + lac_L[e] -> h[c] + lac_L[c]';'G3PD8 AND SUCD4 AND G3PD1','G3PD8','fad[c] + glyc3p[c] <=> dhap[c] + fadh2[c]','G3PD8i','fad[c] + glyc3p[c] -> fadh2[c] + dhap[c]';'ACOAD1 AND ACOAD1f AND SUCD4','ACOAD1f','btcoa[c] + fad[c] <=> b2coa[c] + fadh2[c]','ACOAD1fi','btcoa[c] + fad[c] -> b2coa[c] + fadh2[c]';'PGK AND D_GLY3PR','D_GLY3PR','g3p[c] + nadp[c] + h2o[c] <=> 3pg[c] + 2 h[c] + nadph[c]','D_GLY3PRi','g3p[c] + nadp[c] + h2o[c] -> 3pg[c] + 2 h[c] + nadph[c]';'r0010 AND H202D','H202D','nadh[c] + h2o2[c] + h[c] <=> 2 h2o[c] + nad[c]','NPR','h2o2[c] + h[c] + nadh[c] -> 2 h2o[c] + nad[c]';'ACCOACL AND BTNCL','BTNCL','atp[c] + apoC_Lys_btn[c] + hco3[c] <=> h[c] + pi[c] + btn_co2[c] + adp[c]','BTNCLi','atp[c] + apoC_Lys_btn[c] + hco3[c] -> h[c] + pi[c] + btn_co2[c] + adp[c]';'r0220 AND r0318','r0318','atp[c] + 2 h[c] + ppa[c] <=> ppi[c] + HC01668[c]','r0318i','atp[c] + 2 h[c] + ppa[c] -> ppi[c] + HC01668[c] ';'MTHFRfdx AND FDNADOX_H','FDNADOX_H','nad[c] + fdxrd[c] <=> h[e] + nadh[c] + fdxox[c]',[],[];'FDNADOX_H AND FDX_NAD_NADP_OX','FDX_NAD_NADP_OX','fdxrd[c] + nadh[c] + 2 nadp[c] <=> fdxox[c] + nad[c] + h[c] + 2 nadph[c]','FDX_NAD_NADP_OXi','fdxrd[c] + nadh[c] + 2 nadp[c] -> fdxox[c] + nad[c] + h[c] + 2 nadph[c]';'r1088','r1088','h[e] + cit[e] <=> h[c] + cit[c]','CITt2','cit[e] + h[e] -> cit[c] + h[c]';'NACUP AND NACt2r','NACUP',[],[],[];'NCAMUP AND NCAMt2r','NCAMUP',[],[],[];'ORNt AND ORNt2r','ORNt',[],[],[];'FORt AND FORt2r','FORt',[],[],[];'ARABt AND ARABDt2','ARABt',[],[],[];'ASPte AND ASPt2_2','ASPte',[],[],[];'ASPte AND ASPt2_3','ASPte',[],[],[];'ASPt2 AND ASPt2_2','ASPt2',[],[],[];'ASPt2 AND ASPt2_3','ASPt2',[],[],[];'THYMDt AND THMDt2r','THYMDt',[],[],[];'CBMK AND CBMKr','CBMKr',[],[],[];'SPTc AND TRPS2r AND TRPAS2','TRPS2r','ser_L[c] + indole[c] <=> h2o[c] + trp_L[c]','TRPS2','indole[c] + ser_L[c] -> h2o[c] + trp_L[c]';'PROD3 AND PROD3i','PROD3',[],[],[];'PROPAT4te AND PROt2r AND PROt2','PROt2r',[],[],[];'CITt10i AND CITCAt AND CITCAti','CITCAt',[],[],[];'GUAt2r AND GUAt','GUAt2r','gua[e] + h[e] <=> gua[c] + h[c]','GUAt2','gua[e] + h[e] -> gua[c] + h[c]';'PROPAT4te AND PROt4r AND PROt4','PROt4r',[],[],[];'INSt2 AND INSt','INSt2','ins[e] + h[e] <=> ins[c] + h[c]','INSt2i','ins[e] + h[e] -> ins[c] + h[c]';'GNOXuq AND GNOXuqi','GNOXuq',[],[],[];'GNOXmq AND GNOXmqi','GNOXmq',[],[],[];'RBPC AND PRKIN','PRKIN','atp[c] + ru5p_D[c] <=> adp[c] + rb15bp[c] + h[c]','PRKINi','atp[c] + ru5p_D[c] -> adp[c] + rb15bp[c] + h[c]';'MMSAD5 AND MSAS AND MALCOAPYRCT AND PPCr AND ACALD','ACALD','acald[c] + coa[c] + nad[c] <=> accoa[c] + h[c] + nadh[c]','ACALDi','acald[c] + coa[c] + nad[c] -> accoa[c] + h[c] + nadh[c]';'PGK AND G1PP AND G16BPS AND G1PPT','G16BPS','3 h[c] + 13dpg[c] + g1p[c] <=> 3pg[c] + M01966[c]','G16BPSi','3 h[c] + 13dpg[c] + g1p[c] -> 3pg[c] + M01966[c]';'FRD7 AND SUCD1 AND G3PD8','G3PD8','fad[c] + glyc3p[c] <=> dhap[c] + fadh2[c]','G3PD8i','fad[c] + glyc3p[c] -> fadh2[c] + dhap[c]';'PROPAT4te AND PROt2r','PROt2r','h[e] + pro_L[e] <=> h[c] + pro_L[c]','PROt2','h[e] + pro_L[e] -> h[c] + pro_L[c]';'LACLi AND PPCr AND RPE AND PKL AND FTHFL AND MTHFC','MTHFC','h2o[c] + methf[c] <=> 10fthf[c] + h[c]','MTHFCi','h2o[c] + methf[c] -> 10fthf[c] + h[c]';'RMNt2 AND RMNt2_1','RMNt2_1',[],[],[];'MNLpts AND MANAD_D AND MNLt6','MNLt6','h[e] + mnl[e] <=> h[c] + mnl[c]','MNLt6i','h[e] + mnl[e] -> h[c] + mnl[c]';'FDNADOX_H AND SULRi AND FXXRDO','FXXRDO','3 h2o[c] + h2s[c] + 3 fdxox[c] <=> 2 h[c] + so3[c] + 3 fdxrd[c]','FXXRDOi','2 h[c] + so3[c] + 3 fdxrd[c] -> 3 h2o[c] + h2s[c] + 3 fdxox[c]';'FDNADOX_H AND AKGS AND BTCOADH AND OOR2r','OOR2r','fdxrd[c] + co2[c] + succoa[c] <=> fdxox[c] + akg[c] + coa[c] + h[c]','OOR2','fdxrd[c] + co2[c] + succoa[c] -> fdxox[c] + akg[c] + coa[c] + h[c]';'FDNADOX_H AND AKGS AND BTCOADH AND OOR2 AND POR4','POR4','fdxrd[c] + co2[c] + accoa[c] <=> fdxox[c] + pyr[c] + coa[c] + h[c]','POR4i','h[c] + coa[c] + pyr[c] + fdxox[c] -> co2[c] + accoa[c] + fdxrd[c]';'FDNADOX_H AND AKGS AND OAASr AND ICDHx AND POR4i','ICDHx','icit[c] + nad[c] <=> akg[c] + co2[c] + nadh[c]','ICDHxi','icit[c] + nad[c] -> akg[c] + co2[c] + nadh[c]';'GLXS AND GCALDL AND GCALDDr','GCALDDr','gcald[c] + h2o[c] + nad[c] <=> glyclt[c] + 2 h[c] + nadh[c]','GCALDD','h2o[c] + nad[c] + gcald[c] -> 2 h[c] + nadh[c] + glyclt[c]';'GLYCLTDxr AND GLYCLTDx','GLYCLTDxr',[],[],[];'GCALDD AND GCALDDr','GCALDDr',[],[],[];'BGLA AND BGLAr','BGLAr',[],[],[];'AKGMAL AND MALNAt AND AKGt2r','AKGt2r','akg[e] + h[e] <=> akg[c] + h[c]','AKGt2','akg[e] + h[e] -> akg[c] + h[c]';'TRPS1 AND TRPS2r AND TRPS3r','TRPS2r','ser_L[c] + indole[c] <=> h2o[c] + trp_L[c]','TRPS2','indole[c] + ser_L[c] -> h2o[c] + trp_L[c]';'OAACL AND OAACLi','OAACL',[],[],[];'DHDPRy AND DHDPRyr','DHDPRyr',[],[],[];'EDA_R AND EDA','EDA_R',[],[],[];'GLYC3Pt AND GLYC3Pti','GLYC3Pt',[],[],[];'FA180ACPHrev AND STCOATA AND FACOAL180','FACOAL180','atp[c] + coa[c] + ocdca[c] <=> amp[c] + ppi[c] + stcoa[c]','FACOAL180i','atp[c] + coa[c] + ocdca[c] -> amp[c] + ppi[c] + stcoa[c]';'CITt2 AND CAt4i AND CITCAt','CITCAt','ca2[e] + h[e] + cit[e] <=> ca2[c] + h[c] + cit[c]','CITCAti','ca2[e] + h[e] + cit[e] -> ca2[c] + h[c] + cit[c]';'AHCYSNS_r AND AHCYSNS','AHCYSNS_r',[],[],[];'FDOXR AND GLFRDO AND OOR2r AND FRDOr','FRDOr','fdxrd[c] + nadp[c] <=> fdxox[c] + h[c] + nadph[c]','FRDO','fdxrd[c] + nadp[c] -> fdxox[c] + h[c] + nadph[c]';'GNOX AND GNOXy AND GNOXuq AND GNOXmq','GNOXmq','mqn8[c] + glc_bD[c] <=> mql8[c] + g15lac[c]','GNOXmqi','mqn8[c] + glc_bD[c] -> mql8[c] + g15lac[c]';'GNOX AND GNOXy AND GNOXuq AND GNOXmqi','GNOXuq','q8[c] + glc_bD[c] <=> q8h2[c] + g15lac[c]','GNOXuqi','q8[c] + glc_bD[c] -> q8h2[c] + g15lac[c]';'SHSL1r AND SHSL2 AND SHSL4r','SHSL4r','h2o[c] + suchms[c] <=> 2obut[c] + h[c] + nh4[c] + succ[c]','SHSL4','h2o[c] + suchms[c] -> h[c] + 2obut[c] + nh4[c] + succ[c]';'AHSERL3 AND CYSS3r AND METSOXR1r AND SHSL4r','TRDRr','nadph[c] + trdox[c] + h[c] <=> trdrd[c] + nadp[c]','TRDR','h[c] + nadph[c] + trdox[c] -> nadp[c] + trdrd[c]';'ACACT1r AND ACACt2 AND ACACCTr AND OCOAT1r','OCOAT1r','acac[c] + succoa[c] <=> aacoa[c] + succ[c]','OCOAT1','acac[c] + succoa[c] -> aacoa[c] + succ[c]';'ACONT AND ACONTa AND ACONTb','ACONT',[],[],[];'ALAt2r AND ALAt4r','ALAt2r','h[e] + ala_L[e] <=> h[c] + ala_L[c]','ALAt2','ala_L[e] + h[e] -> ala_L[c] + h[c]';'CYTK2 AND DCMPDA AND URIDK3','DCMPDA','h2o[c] + h[c] + dcmp[c] <=> nh4[c] + dump[c]','DCMPDAi','h2o[c] + h[c] + dcmp[c]  -> nh4[c] + dump[c]';'MALNAt AND NAt3_1 AND PIt7ir','NAt3_1','h[e] + na1[c]  <=> h[c] + na1[e] ','NAt3','h[e] + na1[c] -> h[c] + na1[e]';'PIt6b AND PIt7ir','PIt6b','h[e] + pi[e] <=> h[c] + pi[c]','PIt6bi','h[e] + pi[e] -> h[c] + pi[c]';'LEUTA AND LLEUDr','LLEUDr','h2o[c] + nad[c] + leu_L[c] <=> nadh[c] + nh4[c] + h[c] + 4mop[c]','LLEUD','h2o[c] + nad[c] + leu_L[c] -> nadh[c] + nh4[c] + h[c] + 4mop[c]';'ILETA AND L_ILE3MR','L_ILE3MR','h2o[c] + nad[c] + ile_L[c] <=> nadh[c] + nh4[c] + h[c] + 3mop[c]','L_ILE3MRi','h2o[c] + nad[c] + ile_L[c] -> nadh[c] + nh4[c] + h[c] + 3mop[c]';'TRSARry AND TRSARr','TRSARr','2h3oppan[c] + h[c] + nadh[c] <=> glyc_R[c] + nad[c]','TRSAR','2h3oppan[c] + h[c] + nadh[c] -> glyc_R[c] + nad[c]';'THRD AND THRAr AND PYRDC','THRAr','thr_L[c] <=> acald[c] + gly[c]','THRAi','thr_L[c] -> acald[c] + gly[c]';'THRD AND GLYAT AND PYRDC','GLYAT','accoa[c] + gly[c] <=> 2aobut[c] + coa[c]','GLYATi','accoa[c] + gly[c] -> 2aobut[c] + coa[c]';'SUCD1 AND SUCD4 AND SUCDimq AND NADH6','SUCD1','fad[c] + succ[c] <=> fadh2[c] + fum[c]','SUCD1i','fad[c] + succ[c] -> fadh2[c] + fum[c]';'POR4 AND SUCDimq AND NADH6 AND PDHa AND FRD7 AND FDOXR AND NTRIR4','POR4','fdxrd[c] + co2[c] + accoa[c] <=> fdxox[c] + pyr[c] + coa[c] + h[c]','POR4i','h[c] + coa[c] + pyr[c] + fdxox[c] -> co2[c] + accoa[c] + fdxrd[c]';'SUCDimq AND NADH6 AND HYD1 AND HYD4 AND FRD7 AND FDOXR AND NTRIR4','FDOXR','4 h2o[c] + 2 nh4[c] + 6 fdxox[c] <=> 4 h[c] + 2 no2[c] + 6 fdxrd[c]','FDOXRi','4 h[c] + 2 no2[c] + 6 fdxrd[c] -> 4 h2o[c] + 2 nh4[c] + 6 fdxox[c]';'PPCr AND SUCOAS AND OAASr AND ICDHx AND POR4i AND ACONTa AND ACONTb AND ACACT1r AND 3BTCOAI AND OOR2r','ICDHx','icit[c] + nad[c] <=> akg[c] + co2[c] + nadh[c]','ICDHxi','icit[c] + nad[c] -> akg[c] + co2[c] + nadh[c]';'PYNP1r AND CSNt6','PYNP1r','csn[c] + r1p[c] <=> cytd[c] + pi[c]','PYNP1','csn[c] + r1p[c] -> cytd[c] + pi[c]';'ASPK AND ASAD AND HSDy','ASPK','asp_L[c] + atp[c] <=> 4pasp[c] + adp[c]','ASPKi','asp_L[c] + atp[c] -> 4pasp[c] + adp[c]';'GLUt2r AND GLUABUTt7 AND ABTAr','GLUt2r','glu_L[e] + h[e] <=> glu_L[c] + h[c]','GLUt2','glu_L[e] + h[e] -> glu_L[c] + h[c]';'DURAD AND DHPM1 AND UPPN','DURAD','nadp[c] + 56dura[c] <=> h[c] + nadph[c] + ura[c]','DURADi','nadp[c] + 56dura[c] -> h[c] + nadph[c] + ura[c]';'XU5PG3PL AND PKL','PKL',[],[],[];'G16BPS AND G1PPT AND PGK AND GAPD_NADP AND GAPD','G16BPS','3 h[c] + 13dpg[c] + g1p[c] <=> 3pg[c] + M01966[c]','G16BPSi','3 h[c] + 13dpg[c] + g1p[c] -> 3pg[c] + M01966[c]';'G1PPT AND PGK AND GAPD_NADP AND GAPD','G1PPT','4 h[c] + 2 g1p[c] <=> glc_D[c] + M01966[c]','G1PPTi','4 h[c] + 2 g1p[c] -> glc_D[c] + M01966[c]';'PPIt2e AND GUAPRT AND AACPS6 AND GALT','PPIt2e','h[c] + ppi[c] -> h[e] + ppi[e]','PPIte','ppi[c]  -> ppi[e]';'PPIt2e AND GLGC AND NADS2 AND SADT','PPIt2e','h[c] + ppi[c] -> h[e] + ppi[e]','PPIte','ppi[c]  -> ppi[e]';'MCOATA AND MALCOAPYRCT AND C180SNrev','MCOATA','ACP[c] + malcoa[c]  <=> coa[c] + malACP[c]','MACPMT','ACP[c] + malcoa[c] -> coa[c] + malACP[c]';'PPCr AND MALCOAPYRCT AND MMSAD5 AND MSAS','PPCr','h[c] + pi[c] + oaa[c] <=> h2o[c] + co2[c] + pep[c]','PPC','co2[c] + h2o[c] + pep[c] -> h[c] + oaa[c] + pi[c]';'ACt2r AND ACtr','ACtr','ac[e]  <=> ac[c]',[],[];'LEUt2r AND LEUtec','LEUtec','leu_L[e]  <=> leu_L[c]',[],[];'PTRCt2r AND PTRCtex2','PTRCtex2','ptrc[c]  <=> ptrc[e]',[],[];'TYRt2r AND TYRt','TYRt','tyr_L[e]  <=> tyr_L[c] ',[],[];'OCBT AND CITRH AND CBMKr','CBMKr','nh4[c] + atp[c] + co2[c]  <=> 2 h[c] + adp[c] + cbp[c]','CBMK','nh4[c] + atp[c] + co2[c]  -> 2 h[c] + adp[c] + cbp[c]';'TSULt2 AND SO3t AND H2St AND TRDRr','TRDRr','h[c] + nadph[c] + trdox[c]  <=> nadp[c] + trdrd[c] ','TRDR','h[c] + nadph[c] + trdox[c] -> nadp[c] + trdrd[c]'};
% List Western diet constraints to test if the pan-model produces
% reasonable ATP flux on this diet.
dietConstraints={'EX_fru(e)','-0.14899','1000';'EX_glc_D(e)','-0.14899','1000';'EX_gal(e)','-0.14899','1000';'EX_man(e)','-0.14899','1000';'EX_mnl(e)','-0.14899','1000';'EX_fuc_L(e)','-0.14899','1000';'EX_glcn(e)','-0.14899','1000';'EX_rmn(e)','-0.14899','1000';'EX_arab_L(e)','-0.17878','1000';'EX_drib(e)','-0.17878','1000';'EX_rib_D(e)','-0.17878','1000';'EX_xyl_D(e)','-0.17878','1000';'EX_oxa(e)','-0.44696','1000';'EX_lcts(e)','-0.074493','1000';'EX_malt(e)','-0.074493','1000';'EX_sucr(e)','-0.074493','1000';'EX_melib(e)','-0.074493','1000';'EX_cellb(e)','-0.074493','1000';'EX_tre(e)','-0.074493','1000';'EX_strch1(e)','-0.25734','1000';'EX_amylopect900(e)','-1.5673e-05','1000';'EX_amylose300(e)','-4.7019e-05','1000';'EX_arabinan101(e)','-0.00016628','1000';'EX_arabinogal(e)','-2.1915e-05','1000';'EX_arabinoxyl(e)','-0.00030665','1000';'EX_bglc(e)','-7.05e-08','1000';'EX_cellul(e)','-2.8212e-05','1000';'EX_dextran40(e)','-0.00017632','1000';'EX_galmannan(e)','-1.4106e-05','1000';'EX_glcmannan(e)','-3.2881e-05','1000';'EX_homogal(e)','-0.00012823','1000';'EX_inulin(e)','-0.00047019','1000';'EX_kestopt(e)','-0.0028212','1000';'EX_levan1000(e)','-1.4106e-05','1000';'EX_lmn30(e)','-0.00047019','1000';'EX_lichn(e)','-8.2976e-05','1000';'EX_pect(e)','-3.3387e-05','1000';'EX_pullulan1200(e)','-1.1755e-05','1000';'EX_raffin(e)','-0.0047019','1000';'EX_rhamnogalurI(e)','-1.4492e-05','1000';'EX_rhamnogalurII(e)','-0.00026699','1000';'EX_starch1200(e)','-1.1755e-05','1000';'EX_xylan(e)','-3.2059e-05','1000';'EX_xyluglc(e)','-1.3146e-05','1000';'EX_arachd(e)','-0.003328','1000';'EX_chsterol(e)','-0.004958','1000';'EX_glyc(e)','-1.7997','1000';'EX_hdca(e)','-0.39637','1000';'EX_hdcea(e)','-0.036517','1000';'EX_lnlc(e)','-0.35911','1000';'EX_lnlnca(e)','-0.017565','1000';'EX_lnlncg(e)','-0.017565','1000';'EX_ocdca(e)','-0.16928','1000';'EX_ocdcea(e)','-0.68144','1000';'EX_octa(e)','-0.012943','1000';'EX_ttdca(e)','-0.068676','1000';'EX_ala_L(e)','-1','1000';'EX_cys_L(e)','-1','1000';'EX_ser_L(e)','-1','1000';'EX_arg_L(e)','-0.15','1000';'EX_his_L(e)','-0.15','1000';'EX_ile_L(e)','-0.15','1000';'EX_leu_L(e)','-0.15','1000';'EX_lys_L(e)','-0.15','1000';'EX_asn_L(e)','-0.225','1000';'EX_asp_L(e)','-0.225','1000';'EX_thr_L(e)','-0.225','1000';'EX_glu_L(e)','-0.18','1000';'EX_met_L(e)','-0.18','1000';'EX_gln_L(e)','-0.18','1000';'EX_pro_L(e)','-0.18','1000';'EX_val_L(e)','-0.18','1000';'EX_phe_L(e)','-1','1000';'EX_tyr_L(e)','-1','1000';'EX_gly(e)','-0.45','1000';'EX_trp_L(e)','-0.08182','1000';'EX_12dgr180(e)','-1','1000';'EX_26dap_M(e)','-1','1000';'EX_2dmmq8(e)','-1','1000';'EX_2obut(e)','-1','1000';'EX_3mop(e)','-1','1000';'EX_4abz(e)','-1','1000';'EX_4hbz(e)','-1','1000';'EX_5aop(e)','-1','1000';'EX_ac(e)','-1','1000';'EX_acald(e)','-1','1000';'EX_acgam(e)','-1','1000';'EX_acmana(e)','-1','1000';'EX_acnam(e)','-1','1000';'EX_ade(e)','-1','1000';'EX_adn(e)','-1','1000';'EX_adpcbl(e)','-1','1000';'EX_akg(e)','-1','1000';'EX_ala_D(e)','-1','1000';'EX_amet(e)','-1','1000';'EX_amp(e)','-1','1000';'EX_anth(e)','-1','1000';'EX_arab_D(e)','-1','1000';'EX_avite1(e)','-1','1000';'EX_btn(e)','-1','1000';'EX_ca2(e)','-1','1000';'EX_cbl1(e)','-1','1000';'EX_cgly(e)','-1','1000';'EX_chol(e)','-1','1000';'EX_chor(e)','-1','1000';'EX_cit(e)','-1','1000';'EX_cl(e)','-1','1000';'EX_cobalt2(e)','-1','1000';'EX_csn(e)','-1','1000';'EX_cu2(e)','-1','1000';'EX_cytd(e)','-1','1000';'EX_dad_2(e)','-1','1000';'EX_dcyt(e)','-1','1000';'EX_ddca(e)','-1','1000';'EX_dgsn(e)','-1','1000';'EX_etoh(e)','-1','1000';'EX_fald(e)','-1','1000';'EX_fe2(e)','-1','1000';'EX_fe3(e)','-1','1000';'EX_fe3dcit(e)','-1','1000';'EX_fol(e)','-1','1000';'EX_for(e)','-1','1000';'EX_fum(e)','-1','1000';'EX_gam(e)','-1','1000';'EX_glu_D(e)','-1','1000';'EX_glyc3p(e)','-1','1000';'EX_gsn(e)','-1','1000';'EX_gthox(e)','-1','1000';'EX_gthrd(e)','-1','1000';'EX_gua(e)','-1','1000';'EX_h(e)','-1','1000';'EX_h2(e)','-1','1000';'EX_h2s(e)','-1','1000';'EX_hom_L(e)','-1','1000';'EX_hxan(e)','-1','1000';'EX_indole(e)','-1','1000';'EX_ins(e)','-1','1000';'EX_k(e)','-1','1000';'EX_lac_L(e)','-1','1000';'EX_lanost(e)','-1','1000';'EX_mal_L(e)','-1','1000';'EX_metsox_S_L(e)','-1','1000';'EX_mg2(e)','-1','1000';'EX_mn2(e)','-1','1000';'EX_mobd(e)','-1','1000';'EX_mqn7(e)','-1','1000';'EX_mqn8(e)','-1','1000';'EX_na1(e)','-1','1000';'EX_nac(e)','-1','1000';'EX_ncam(e)','-1','1000';'EX_nmn(e)','-1','1000';'EX_no2(e)','-1','1000';'EX_no2(e)','-1','1000';'EX_no3(e)','-1','1000';'EX_orn(e)','-1','1000';'EX_pheme(e)','-1','1000';'EX_phyQ(e)','-1','1000';'EX_pi(e)','-1','1000';'EX_pime(e)','-1','1000';'EX_pnto_R(e)','-1','1000';'EX_ptrc(e)','-1','1000';'EX_pydam(e)','-1','1000';'EX_pydx(e)','-1','1000';'EX_pydx5p(e)','-1','1000';'EX_pydxn(e)','-1','1000';'EX_q8(e)','-1','1000';'EX_retinol(e)','-1','1000';'EX_ribflv(e)','-1','1000';'EX_sel(e)','-1','1000';'EX_sheme(e)','-1','1000';'EX_so4(e)','-1','1000';'EX_spmd(e)','-1','1000';'EX_succ(e)','-1','1000';'EX_thf(e)','-1','1000';'EX_thm(e)','-1','1000';'EX_thymd(e)','-1','1000';'EX_ura(e)','-1','1000';'EX_uri(e)','-1','1000';'EX_vitd3(e)','-1','1000';'EX_xan(e)','-1','1000';'EX_zn2(e)','-1','1000';'EX_meoh(e)','-10','1000';'EX_h2o(e)','-10','1000'};

% set a solver if not done yet
global CBT_LP_SOLVER
solver = CBT_LP_SOLVER;
if isempty(solver)
    initCobraToolbox;
end

dInfo = dir(panPath);
panModels={dInfo.name};
panModels=panModels';
panModels(~contains(panModels(:,1),'.mat'),:)=[];

% Test ATP production and remove futile cycles if applicable.
for i=1:length(panModels)
    model=readCbModel([panPath,panModels{i}]);
    model=useDiet(model,dietConstraints);
    model=changeObjective(model,'DM_atp_c_');
    FBA=optimizeCbModel(model,'max');
    % Ensure that pan-models can still produce biomass
    model=changeObjective(model,'biomassPan');
    if FBA.f > 50
        for j=2:size(reactionsToReplace,1)
            rxns=strsplit(reactionsToReplace{j,1},' AND ');
            go=1;
            for k=1:size(rxns,2)
                if isempty(find(ismember(model.rxns,rxns{k})))
                    go=0;
                end
            end
            if go==1
                % Only make the change if biomass can still be produced
                modelTest=removeRxns(model,reactionsToReplace{j,2});
                if ~isempty(reactionsToReplace{j,4})
                    modelTest=addReaction(modelTest,reactionsToReplace{j,4},reactionsToReplace{j,5});
                end
                FBA=optimizeCbModel(modelTest,'max');
                if FBA.f>0.00001
                    model=modelTest;
                end
            end
        end
        % set back to unlimited medium
        model = changeRxnBounds(model, model.rxns(strmatch('EX_', model.rxns)), -1000, 'l');
        % Adapt fields to current standard
        model=convertOldStyleModel(model);
        save([panPath,panModels{i}],'model')
    end   
end
