function createPanModels(agoraPath, panPath, taxonLevel)
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
%
%   createPanModels(agoraPath,panPath,taxonLevel)
%
% INPUTS:
%    agoraPath     String containing the path to the AGORA reconstructions.
%                  Must end with a file separator.
%    panPath       String containing the path to an empty folder that the
%                  created pan-models will be stored in. Must end with a file separator.
%    taxonLevel    String with desired taxonomical level of the pan-models.
%                  Allowed inputs are 'Species','Genus','Family','Order', 'Class','Phylum'.
%
% .. Authors
%       - Stefania Magnusdottir, 2016
%       - Almut Heinken, 06/2018: adapted to function.

[~, infoFile, ~] = xlsread('AGORA_infoFile.xlsx');  % create the pan-models

% get the reaction and metabolite database
metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', '\t', 'ReadVariableNames', false);
metaboliteDatabase = table2cell(metaboliteDatabase);
database.metabolites = metaboliteDatabase;
reactionDatabase = readtable('ReactionDatabase.txt', 'Delimiter', '\t', 'ReadVariableNames', false);
reactionDatabase = table2cell(reactionDatabase);
database.reactions = reactionDatabase;

% List all species in the AGORA resource
findTaxCol = find(strcmp(infoFile(1, :), taxonLevel));
allTaxa = unique(infoFile(2:end, findTaxCol));

% Remove unclassified organisms
allTaxa(strncmp('unclassified', allTaxa, 12)) = [];
allTaxa(~cellfun(@isempty, strfind(allTaxa, 'bacteri')))
built = ls(panPath);

% Remove models that have already been assembled from the list of models to create
built = cellstr(built);
built = strrep(built, '.mat', '');
toCreate = setdiff(allTaxa, built);

% Build pan-models
for i = 1:size(toCreate, 1)
    models = find(ismember(infoFile(:, findTaxCol), toCreate{i, 1}));
    if size(models, 1) == 1
        modelPath = [agoraPath filesep infoFile{models, 1} '.mat'];
        model = readCbModel(modelPath);
        % rename biomass reaction to agree with other pan-models
        bio = find(strncmp(model.rxns, 'biomass', 7));
        model.rxns{bio, 1} = 'biomassPan';
    elseif size(models, 1) > 1
        for j = 1:size(models, 1)
            modelPath = [agoraPath filesep infoFile{models(j), 1} '.mat'];
            model = readCbModel(modelPath);
            bio = find(strncmp(model.rxns, 'biomass', 7));
            if j == 1
                panModel.rxns = model.rxns;
                panModel.grRules = model.grRules;
                panModel.rxnNames = model.rxnNames;
                panModel.subSystems = model.subSystems;
                panModel.lb = model.lb;
                panModel.ub = model.ub;
                forms = printRxnFormula(model, model.rxns, false, false, false, [], false);
                panModel.formulas = forms;
                % biomass products and substrates with coefficients
                bioPro = model.mets(find(model.S(:, bio) > 0), 1);
                bioProSC = full(model.S(find(model.S(:, bio) > 0), bio));
                bioSub = model.mets(find(model.S(:, bio) < 0), 1);
                bioSubSC = full(model.S(find(model.S(:, bio) < 0), bio));
            else
                panModel.rxns = [panModel.rxns; model.rxns];
                panModel.grRules = [panModel.grRules; model.grRules];
                panModel.rxnNames = [panModel.rxnNames; model.rxnNames];
                panModel.subSystems = [panModel.subSystems; model.subSystems];
                panModel.lb = [panModel.lb; model.lb];
                panModel.ub = [panModel.ub; model.ub];
                forms = printRxnFormula(model, model.rxns, false, false, false, [], false);
                panModel.formulas = [panModel.formulas; forms];
                % biomass products and substrates with coefficients
                bioPro = [bioPro; model.mets(find(model.S(:, bio) > 0), 1)];
                bioProSC = [bioProSC; full(model.S(find(model.S(:, bio) > 0), bio))];
                bioSub = [bioSub; model.mets(find(model.S(:, bio) < 0), 1)];
                bioSubSC = [bioSubSC; full(model.S(find(model.S(:, bio) < 0), bio))];
            end
        end
        % take out biomass reactions
        bio = find(strncmp(panModel.rxns, 'biomass', 7));
        panModel.rxns(bio) = [];
        panModel.grRules(bio) = [];
        panModel.rxnNames(bio) = [];
        panModel.subSystems(bio) = [];
        panModel.lb(bio) = [];
        panModel.ub(bio) = [];
        panModel.formulas(bio) = [];
        % set up data matrix for rBioNet
        [uniqueRxns, oldInd] = unique(panModel.rxns);
        rbio.data = cell(size(uniqueRxns, 1), 14);
        rbio.data(:, 1) = num2cell(ones(size(rbio.data, 1), 1));
        rbio.data(:, 2) = uniqueRxns;
        rbio.data(:, 3) = panModel.rxnNames(oldInd);
        rbio.data(:, 4) = panModel.formulas(oldInd);
        rbio.data(:, 6) = panModel.grRules(oldInd);
        rbio.data(:, 7) = num2cell(panModel.lb(oldInd));
        rbio.data(:, 8) = num2cell(panModel.ub(oldInd));
        rbio.data(:, 10) = panModel.subSystems(oldInd);
        rbio.description = cell(7, 1);
        % build model with rBioNet
        model = data2model(rbio.data, rbio.description, database);
        % build biomass reaction from average of all biomasses
        subs = unique(bioSub);
        prods = unique(bioPro);
        bioForm = '';
        for s = 1:size(subs, 1)
            indS = find(ismember(bioSub, subs{s, 1}));
            newCoeff = sum(bioSubSC(indS)) / j;
            bioForm = [bioForm, num2str(-newCoeff), ' ', subs{s, 1}, ' + '];
        end
        bioForm = bioForm(1:end - 3);
        bioForm = [bioForm, ' -> '];
        for p = 1:size(prods, 1)
            indP = find(ismember(bioPro, prods{p, 1}));
            newCoeff = sum(bioProSC(indP)) / j;
            bioForm = [bioForm, num2str(newCoeff), ' ', prods{p, 1}, ' + '];
        end
        bioForm = bioForm(1:end - 3);
        % add biomass reaction to pan model
        model = addReaction(model, 'biomassPan', bioForm);
        model.comments{end + 1, 1} = '';
        model.citations{end + 1, 1} = '';
        model.rxnConfidenceScores{end + 1, 1} = '';
        model.rxnECNumbers{end + 1, 1} = '';
        model.rxnKEGGID{end + 1, 1} = '';
    end
    % update some fields to new standards
    model.osenseStr = 'max';
    if isfield(model, 'rxnConfidenceScores')
        model = rmfield(model, 'rxnConfidenceScores');
    end
    model.rxnConfidenceScores = zeros(length(model.rxns), 1);
    for j = 1:length(model.rxns)
        model.subSystems{j, 1} = cellstr(model.subSystems{j, 1});
        model.rxnKEGGID{j, 1} = '';
        model.rxnECNumbers{j, 1} = '';
    end
    for j = 1:length(model.mets)
        if strcmp(model.metPubChemID{j, 1}, '[]') || isempty(model.metPubChemID{j, 1})
            model.metPubChemID{j, 1} = string;
        end
        if strcmp(model.metChEBIID{j, 1}, '[]') || isempty(model.metChEBIID{j, 1})
            model.metChEBIID{j, 1} = string;
        end
        if strcmp(model.metKEGGID{j, 1}, '[]') || isempty(model.metKEGGID{j, 1})
            model.metKEGGID{j, 1} = string;
        end
        if strcmp(model.metInChIString{j, 1}, '[]') || isempty(model.metInChIString{j, 1})
            model.metInChIString{j, 1} = string;
        end
        if strcmp(model.metHMDBID{j, 1}, '[]') || isempty(model.metHMDBID{j, 1})
            model.metHMDBID{j, 1} = string;
        end
    end
    model.metPubChemID = cellstr(model.metPubChemID);
    model.metChEBIID = cellstr(model.metChEBIID);
    model.metKEGGID = cellstr(model.metKEGGID);
    model.metInChIString = cellstr(model.metInChIString);
    model.metHMDBID = cellstr(model.metHMDBID);
    % fill in descriptions
    model = rmfield(model, 'description');
    model.description.organism = toCreate{i, 1};
    model.description.name = toCreate{i, 1};
    model.description.author = 'Stefania Magnusdottir, Almut Heinken, Laura Kutt, Dmitry A. Ravcheev, Eugen Bauer, Alberto Noronha, Kacy Greenhalgh, Christian Jaeger, Joanna Baginska, Paul Wilmes, Ronan M.T. Fleming, and Ines Thiele';
    model.description.date = date;

    % Adapt fields to current standard
    model = convertOldStyleModel(model);
    savePath = [panPath filesep 'pan' strrep(toCreate{i, 1}, ' ', '_') '.mat'];
    save(savePath, 'model');
end

%% Remove futile cycles
% Create table with information on reactions to replace to remove futile
% cycles. This information was determined manually by Stefania
% Magnusdottir and Almut Heinken.
reactionsToReplace = {'if', 'removed', 'added'; 'LYSt2r AND LYSt3r', 'LYSt3r', 'LYSt3'; 'FDHr', 'FDHr', 'FDH'; 'GLYO1', 'GLYO1', 'GLYO1i'; 'EAR40xr', 'EAR40xr', 'EAR40x'; 'PROt2r AND PROt4r', 'PROt4r', 'PROt4'; 'FOROXAtex AND FORt', 'FORt', []; 'NO2t2r AND NTRIR5', 'NO2t2r', 'NO2t2'; 'NOr1mq AND NHFRBOr', 'NHFRBOr', 'NHFRBO'; 'NIR AND L_LACDr', 'L_LACDr', 'L_LACD'; 'PIt6b AND PIt7', 'PIt7', 'PIt7ir'; 'ABUTt2r AND GLUABUTt7', 'ABUTt2r', 'ABUTt2'; 'ABUTt2r AND ABTAr', 'ABTAr', 'ABTA'; 'Kt1r AND Kt3r', 'Kt3r', 'Kt3'; 'CYTDt4 AND CYTDt2r', 'CYTDt2r', 'CYTDt2'; 'ASPt2_2 AND ASPt2r', 'ASPt2r', 'ASPte'; 'ASPt2_3 AND ASPt2r', 'ASPt2r', 'ASPt2'; 'FUMt2_2 AND FUMt2r', 'FUMt2r', 'FUMt'; 'SUCCt2_2 AND SUCCt2r', 'SUCCt2r', 'SUCCt'; 'SUCCt2_3r AND SUCCt2r', 'SUCCt2r', []; 'MALFADO AND MDH', 'MALFADO', 'MALFADOi'; 'MALFADO AND GLXS', 'MALFADO', 'MALFADOi'; 'r0392 AND GLXCL', 'r0392', 'ALDD8x'; 'HACD1 AND PHPB2', 'PHPB2', 'PHPB2i'; 'PPCKr AND PPCr', 'PPCKr', 'PPCK'; 'PPCKr AND GLFRDO AND FXXRDO', 'PPCKr', 'PPCK'; 'BTCOADH AND FDNADOX_H AND ACOAD1', 'ACOAD1', 'ACOAD1i'; 'ACKr AND ACEDIPIT AND APAT AND DAPDA AND 26DAPLLAT', '26DAPLLAT', '26DAPLLATi'; 'ACKr AND ACEDIPIT AND APAT AND DAPDA', 'DAPDA', 'DAPDAi'; 'MALNAt AND NAt3_1 AND MALt2r', 'NAt3_1', 'NAt3'; 'MALNAt AND NAt3_1 AND MALt2r', 'MALt2r', 'MALt2'; 'MALNAt AND NAt3_1 AND MALt2r AND URIt2r AND URIt4', 'URIt2r', 'URIt2'; 'DADNt2r AND HYXNt', 'HYXNt', 'HYXNti'; 'URIt2r AND URAt2r', 'URAt2r', 'URAt2'; 'XANt2r AND URAt2r', 'URAt2r', 'URAt2'; 'XANt2r AND CSNt6', 'CSNt6', 'CSNt2'; 'XANt2r AND DADNt2r', 'XANt2r', 'XANt2'; 'XANt2r AND XPPTr', 'XPPTr', 'XPPT'; 'XANt2r AND PUNP7', 'XANt2r', 'XANt2'; 'r1667 AND ARGt2r', 'ARGt2r', 'ARGt2'; 'GLUt2r AND NAt3_1 AND GLUt4r', 'GLUt4r', 'r1144'; 'GLYt2r AND NAt3_1 AND GLYt4r', 'GLYt2r', 'GLYt2'; 'MALNAt AND L_LACNa1t AND L_LACt2r', 'L_LACt2r', 'L_LACt2'; 'G3PD8 AND SUCD4 AND G3PD1', 'G3PD8', 'G3PD8i'; 'ACOAD1 AND ACOAD1f AND SUCD4', 'ACOAD1f', 'ACOAD1fi'; 'PGK AND D_GLY3PR', 'D_GLY3PR', 'D_GLY3PRi'; 'r0010 AND H202D', 'H202D', 'NPR'; 'ACCOACL AND BTNCL', 'BTNCL', 'BTNCLi'; 'r0220 AND r0318', 'r0318', 'r0318i'; 'MTHFRfdx AND FDNADOX_H', 'FDNADOX_H', []; 'FDNADOX_H AND FDX_NAD_NADP_OX', 'FDX_NAD_NADP_OX', 'FDX_NAD_NADP_OXi'; 'r1088', 'r1088', 'CITt2'; 'NACUP AND NACt2r', 'NACUP', []; 'NCAMUP AND NCAMt2r', 'NCAMUP', []; 'ORNt AND ORNt2r', 'ORNt', []; 'FORt AND FORt2r', 'FORt', []; 'ARABt AND ARABDt2', 'ARABt', []; 'ASPte AND ASPt2_2', 'ASPte', []; 'ASPte AND ASPt2_3', 'ASPte', []; 'ASPt2 AND ASPt2_2', 'ASPt2', []; 'ASPt2 AND ASPt2_3', 'ASPt2', []; 'THYMDt AND THMDt2r', 'THYMDt', []; 'CBMK AND CBMKr', 'CBMKr', []; 'SPTc AND TRPS2r AND TRPAS2', 'TRPS2r', 'TRPS2'; 'PROD3 AND PROD3i', 'PROD3', []; 'PROPAT4te AND PROt2r AND PROt2', 'PROt2r', []; 'CITt10i AND CITCAt AND CITCAti', 'CITCAt', []; 'GUAt2r AND GUAt', 'GUAt2r', 'GUAt2'; 'PROPAT4te AND PROt4r AND PROt4', 'PROt4r', []; 'INSt2 AND INSt', 'INSt2', 'INSt2i'; 'GNOXuq AND GNOXuqi', 'GNOXuq', []; 'GNOXmq AND GNOXmqi', 'GNOXmq', []; 'RBPC AND PRKIN', 'PRKIN', 'PRKINi'; 'MMSAD5 AND MSAS AND MALCOAPYRCT AND PPCr AND ACALD', 'ACALD', 'ACALDi'; 'PGK AND G1PP AND G16BPS AND G1PPT', 'G16BPS', 'G16BPSi'; 'FRD7 AND SUCD1 AND G3PD8', 'G3PD8', 'G3PD8i'; 'PROPAT4te AND PROt2r', 'PROt2r', 'PROt2'; 'LACLi AND PPCr AND RPE AND PKL AND FTHFL AND MTHFC', 'MTHFC', 'MTHFCi'; 'RMNt2 AND RMNt2_1', 'RMNt2_1', []; 'MNLpts AND MANAD_D AND MNLt6', 'MNLt6', 'MNLt6i'; 'FDNADOX_H AND SULRi AND FXXRDO', 'FXXRDO', 'FXXRDOi'; 'FDNADOX_H AND AKGS AND BTCOADH AND OOR2r', 'OOR2r', 'OOR2'; 'FDNADOX_H AND AKGS AND BTCOADH AND OOR2 AND POR4', 'POR4', 'POR4i'; 'FDNADOX_H AND AKGS AND OAASr AND ICDHx AND POR4i', 'ICDHx', 'ICDHxi'; 'GLXS AND GCALDL AND GCALDDr', 'GCALDDr', 'GCALDD'; 'GLYCLTDxr AND GLYCLTDx', 'GLYCLTDxr', []; 'GCALDD AND GCALDDr', 'GCALDDr', []; 'BGLA AND BGLAr', 'BGLAr', []; 'AKGMAL AND MALNAt AND AKGt2r', 'AKGt2r', 'AKGt2'; 'TRPS1 AND TRPS2r AND TRPS3r', 'TRPS2r', 'TRPS2'; 'OAACL AND OAACLi', 'OAACL', []; 'DHDPRy AND DHDPRyr', 'DHDPRyr', []; 'EDA_R AND EDA', 'EDA_R', []; 'GLYC3Pt AND GLYC3Pti', 'GLYC3Pt', []; 'FA180ACPHrev AND STCOATA AND FACOAL180', 'FACOAL180', 'FACOAL180i'; 'CITt2 AND CAt4i AND CITCAt', 'CITCAt', 'CITCAti'; 'AHCYSNS_r AND AHCYSNS', 'AHCYSNS_r', []; 'FDOXR AND GLFRDO AND OOR2r AND FRDOr', 'FRDOr', 'FRDO'; 'GNOX AND GNOXy AND GNOXuq AND GNOXmq', 'GNOXmq', 'GNOXmqi'; 'GNOX AND GNOXy AND GNOXuq AND GNOXmqi', 'GNOXuq', 'GNOXuqi'; 'SHSL1r AND SHSL2 AND SHSL4r', 'SHSL4r', 'SHSL4'; 'AHSERL3 AND CYSS3r AND METSOXR1r AND SHSL4r', 'TRDRr', 'TRDR'; 'ACACT1r AND ACACt2 AND ACACCTr AND OCOAT1r', 'OCOAT1r', 'OCOAT1'; 'ACONT AND ACONTa AND ACONTb', 'ACONT', []; 'ALAt2r AND ALAt4r', 'ALAt2r', 'ALAt2'; 'CYTK2 AND DCMPDA AND URIDK3', 'DCMPDA', 'DCMPDAi'; 'MALNAt AND NAt3_1 AND PIt7ir', 'NAt3_1', 'NAt3'; 'PIt6b AND PIt7ir', 'PIt6b', 'PIt6bi'; 'LEUTA AND LLEUDr', 'LLEUDr', 'LLEUD'; 'ILETA AND L_ILE3MR', 'L_ILE3MR', 'L_ILE3MRi'; 'TRSARry AND TRSARr', 'TRSARr', 'TRSAR'; 'THRD AND THRAr AND PYRDC', 'THRAr', 'THRAi'; 'THRD AND GLYAT AND PYRDC', 'GLYAT', 'GLYATi'; 'SUCD1 AND SUCD4 AND SUCDimq AND NADH6', 'SUCD1', 'SUCD1i'; 'POR4 AND SUCDimq AND NADH6 AND PDHa AND FRD7 AND FDOXR AND NTRIR4', 'POR4', 'POR4i'; 'SUCDimq AND NADH6 AND HYD1 AND HYD4 AND FRD7 AND FDOXR AND NTRIR4', 'FDOXR', 'FDOXRi'; 'PPCr AND SUCOAS AND OAASr AND ICDHx AND POR4i AND ACONTa AND ACONTb AND ACACT1r AND 3BTCOAI AND OOR2r', 'ICDHx', 'ICDHxi'; 'PYNP1r AND CSNt6', 'PYNP1r', 'PYNP1'; 'ASPK AND ASAD AND HSDy', 'ASPK', 'ASPKi'; 'GLUt2r AND GLUABUTt7 AND ABTAr', 'GLUt2r', 'GLUt2'; 'DURAD AND DHPM1 AND UPPN', 'DURAD', 'DURADi'; 'XU5PG3PL AND PKL', 'PKL', []; 'G16BPS AND G1PPT AND PGK AND GAPD_NADP AND GAPD', 'G16BPS', 'G16BPSi'; 'G1PPT AND PGK AND GAPD_NADP AND GAPD', 'G1PPT', 'G1PPTi'; 'PPIt2e AND GUAPRT AND AACPS6 AND GALT', 'PPIt2e', 'PPIte'; 'PPIt2e AND GLGC AND NADS2 AND SADT', 'PPIt2e', 'PPIte'; 'MCOATA AND MALCOAPYRCT AND C180SNrev', 'MCOATA', 'MACPMT'; 'PPCr AND MALCOAPYRCT AND MMSAD5 AND MSAS', 'PPCr', 'PPC'; 'ACt2r AND ACtr', 'ACtr', []; 'LEUt2r AND LEUtec', 'LEUtec', []; 'PTRCt2r AND PTRCtex2', 'PTRCtex2', []; 'TYRt2r AND TYRt', 'TYRt', []; 'OCBT AND CITRH AND CBMKr', 'CBMKr', 'CBMK'; 'TSULt2 AND SO3t AND H2St AND TRDRr', 'TRDRr', 'TRDR'; 'AMPSO3OX AND SADT AND EX_h2s(e) AND CHOLSH', 'AMPSO3OX', 'AMPSO3OXi'};

% List Western diet constraints to test if the pan-model produces
% reasonable ATP flux on this diet.
dietConstraints = readtable('WesternDietAGORA.txt');
dietConstraints = table2cell(dietConstraints);
dietConstraints(:, 2) = cellstr(num2str(cell2mat(dietConstraints(:, 2))));
% set a solver if not done yet
global CBT_LP_SOLVER
solver = CBT_LP_SOLVER;
if isempty(solver)
    initCobraToolbox;
end

dInfo = dir(panPath);
panModels = {dInfo.name};
panModels = panModels';
panModels(~contains(panModels(:, 1), '.mat'), :) = [];

% Test ATP production and remove futile cycles if applicable.
for i = 1:length(panModels)
    modelPath = [panPath filesep panModels{i}];
    model = readCbModel(modelPath);
    model = useDiet(model, dietConstraints);
    model = changeObjective(model, 'DM_atp_c_');
    FBA = optimizeCbModel(model, 'max');
    % Ensure that pan-models can still produce biomass
    model = changeObjective(model, 'biomassPan');
    if FBA.f > 50
        for j = 2:size(reactionsToReplace, 1)
            rxns = strsplit(reactionsToReplace{j, 1}, ' AND ');
            go = true;
            for k = 1:size(rxns, 2)
                if isempty(find(ismember(model.rxns, rxns{k})))
                    go = false;
                end
            end
            if go
                % Only make the change if biomass can still be produced
                modelTest = removeRxns(model, reactionsToReplace{j, 2});
                if ~isempty(reactionsToReplace{j, 3})
                    RxForm = database.reactions(find(ismember(database.reactions(:, 1), reactionsToReplace{j, 3})), 3);
                    modelTest = addReaction(modelTest, reactionsToReplace{j, 3}, RxForm{1, 1});
                end
                FBA = optimizeCbModel(modelTest, 'max');
                if FBA.f > 1e-5
                    model = modelTest;
                end
            end
        end
        % set back to unlimited medium
        model = changeRxnBounds(model, model.rxns(strmatch('EX_', model.rxns)), -1000, 'l');
        % Adapt fields to current standard
        model = convertOldStyleModel(model);
        save(modelPath, 'model');
    end
end
