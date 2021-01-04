function [model,secretionRxnsAdded] = addSecretionProductRxns(model,microbeID,database,inputDataFolder)
% add exchange and transport reactions for experimentally shown secretion
% products

% structure of lists of reactions to add per secretion product
% non-alphanumeric characters are removed from secretion product names in
% the structure; the script accounts for this when matching with the
% experimental data input
secretionRxns = struct();
% secretionRxns.Folate = {'EX_fol(e)','FOLte','EX_5mthf(e)','MTHFTe','EX_thf(e)','THFte'};
secretionRxns.Folate = {'EX_fol(e)','FOLte','EX_5mthf(e)','MTHFTe','EX_thf(e)','THFte','EX_4abz(e)','4ABZt2','DM_GCALD','DHPS','DHNPA','AKP1','GTPCI'};
secretionRxns.Thiamin = {'EX_thm(e)','THMte'};
% secretionRxns.Riboflavin = {'EX_ribflv(e)','RIBFLVt2r'};
secretionRxns.Riboflavin = {'EX_ribflv(e)','RIBFLVt2r','PMDPHT'};
secretionRxns.Niacin = {'EX_nac(e)','EX_ncam(e)','NACt2r','EX_ncam(e)','NCAMt2r'};
secretionRxns.Pyridoxine = {'EX_pydx(e)','EX_pydxn(e)','EX_pydam(e)','PYDXtr','PYDXNtr','PYDAMtr'};
% secretionRxns.Cobalamin = {'EX_cbl1(e)','CBl1te','EX_adocbl(e)','CBLTDe'};
secretionRxns.Cobalamin = {'EX_cbl1(e)','CBl1te','EX_adocbl(e)','CBLTDe','sink_dmbzid','CPC4MT','CPC5MT','LTHRK','SHCHD2','CYRDAR'};
% secretionRxns.Menaquinone = {'EX_mqn7(e)','MQN7te','EX_mqn8(e)','MK8t'};
secretionRxns.Menaquinone = {'EX_mqn7(e)','MQN7te','EX_mqn8(e)','MK8t','AMMQT8r','AMMQT72','DHNAOT7','DHNAOT4','DHNAOT','NCOAH','DHNAS','NPHS','SUCBZL','SUCBZS','2S6HCC','ICHORS','HETT','PREN','EX_2obut(e)','2OBUTt2r','EX_adn(e)','ADNCNT3tc','DHQTi'};
% secretionRxns.GABA = {'EX_4abut(e)','ABUTt2r'};
secretionRxns.GABA = {'EX_4abut(e)','ABUTt2r','GLUDC'};
secretionRxns.Biotin ={'EX_btn(e)','BTNT5r'};
secretionRxns.Cholate = {'EX_cholate(e)','BIACt1'};
secretionRxns.Chenodeoxycholate = {'EX_C02528(e)','BIACt2'};
secretionRxns.Deoxycholate = {'EX_dchac(e)','DCAT'};
% secretionRxns.Tyramine = {'EX_tym(e)','TYMt2r'};
% secretionRxns.Tryptamine = {'EX_trypta(e)', 'TRYPTAte'};
secretionRxns.Tyramine = {'EX_tym(e)','TYMt2r','TYRCBOX'};
secretionRxns.Tryptamine = {'EX_trypta(e)','TRYPTAte','LTDCL'};
secretionRxns.TrimethylamineNoxide = {'EX_tmao(e)'};
secretionRxns.Trimethylamine = {'EX_tmao(e)', 'EX_tma(e)'};
secretionRxns.Spermine = {'EX_sprm(e)','SPRMTDe'};
secretionRxns.Spermidine = {'EX_spmd(e)','SPMDtex2'};
secretionRxns.Putrescine = {'EX_ptrc(e)','PTRCtex2'};
% secretionRxns.pCresol = {'EX_pcresol(e)','PCRESOLt2r'};
secretionRxns.pCresol = {'EX_pcresol(e)','PCRESOLt2r','4HPHACDC'};
secretionRxns.Ammonia = {'EX_nh4(e)','NH4tb'};
secretionRxns.Nitrogen = {'EX_n2(e)','N2t'};
secretionRxns.Methylamine = {'EX_mma(e)','MMAt2e'};
secretionRxns.Methanol = {'EX_meoh(e)','MEOHt2'};
secretionRxns.Lthreonine = {'EX_thr_L(e)','THRt2r'};
secretionRxns.Linoleicacid = {'EX_lnlc(e)','LNLCt'};
secretionRxns.Lithocholate = {'EX_HC02191(e)','LCAT'};
secretionRxns.Lglutamate = {'EX_glu_L(e)','GLUt2r'};
secretionRxns.Lglutamine = {'EX_gln_L(e)','GLNt2r'};
secretionRxns.Lalanine = {'EX_ala_L(e)','ALAt2r'};
secretionRxns.Indole3acetate = {'EX_ind3ac(e)','IND3ACt2r'};
% secretionRxns.Histamine = {'EX_hista(e)','HISTAt2'};
secretionRxns.Histamine = {'EX_hista(e)','HISTAt2','HISDC'};
secretionRxns.Peroxide = {'EX_h2o2(e)','H2O2t'};
secretionRxns.x_5Aminovalerate = {'EX_5aptn(e)','5APTNt2r'};
secretionRxns.x_2Oxobutyrate = {'EX_2obut(e)','2OBUTt2r'};
% secretionRxns.x_12Ethanediol = {'EX_12ethd(e)','12ETHDt'};
secretionRxns.x_12Ethanediol = {'EX_12ethd(e)','12ETHDt','LCAR2'};
% secretionRxns.Hydrogen = {'EX_h2(e)','H2td'};
secretionRxns.Hydrogen = {'EX_h2(e)','H2td','HYD4'};
% secretionRxns.Propionate = {'EX_ppa(e)','PPAtr'};
% secretionRxns.x_2Aminobutyrate = {'EX_C02356(e)','C02356t2r'};
secretionRxns.x_2Aminobutyrate = {'EX_C02356(e)','C02356t2r','RE2034C'};
% secretionRxns.x_13Propanediol = {'EX_13ppd(e)','13PPDt'};
secretionRxns.x_13Propanediol = {'EX_13ppd(e)','13PPDt','13PPDH','GLYCDH'};
% secretionRxns.x_12propanediol = {'EX_12ppd_S(e)','12PPDt'};
secretionRxns.x_12propanediol = {'EX_12ppd_S(e)','12PPDt','LCARS'};
% secretionRxns.Acetone = {'EX_acetone(e)','ACETONEt2'};
secretionRxns.Acetone = {'EX_acetone(e)','ACETONEt2','ADCi'};
% secretionRxns.Butylamine = {'EX_butam(e)','BUTAMt2r','EX_norval_L(e)','NORVALt2r','EX_M03134(e)','M03134t2r'};
secretionRxns.Butylamine = {'EX_butam(e)','BUTAMt2r','EX_norval_L(e)','NORVALt2r','EX_M03134(e)','M03134t2r','AKVALS','NORVALS','NORVALDC'};
% secretionRxns.Cadaverine = {'EX_15dap(e)','15DAPt'};
secretionRxns.Cadaverine = {'EX_15dap(e)','15DAPt','LYSDC'};
secretionRxns.Formaldehyde = {'EX_fald(e)','r1421'};
% secretionRxns.Urea = {'EX_urea(e)','UREAt'};
secretionRxns.Urea = {'EX_urea(e)','UREAt','ARGN'};
% secretionRxns.Propanol = {'EX_ppoh(e)','PPOHt2r','PPALt2r','EX_ppal(e)'};
secretionRxns.Propanol = {'EX_ppoh(e)','PPOHt2r','PPALt2r','EX_ppal(e)','ALCD3ir'};
% secretionRxns.Propanal = {'EX_ppal(e)','PPALt2r','EX_12ppd_S(e)','12PPDt'};
secretionRxns.Propanal = {'EX_ppal(e)','PPALt2r','EX_12ppd_S(e)','12PPDt','12PPDSDH'};
% secretionRxns.Phenylethylamine = {'EX_peamn(e)','PEAMNt2r'};
secretionRxns.Phenylethylamine = {'EX_peamn(e)','PEAMNt2r','PHYCBOXL'};
% secretionRxns.Isopropanol = {'EX_2ppoh(e)','2PPOHt2r','EX_acetone(e)','ACETONEt2'};
secretionRxns.Isopropanol = {'EX_2ppoh(e)','2PPOHt2r','EX_acetone(e)','ACETONEt2','ALCD20y'};
secretionRxns.Lmalate = {'EX_mal_L(e)','MALt2r'};
secretionRxns.Sulfide = {'EX_h2s(e)','H2St'};

% read in the secretion product data
secretionTable = readtable([inputDataFolder filesep 'secretionProductTable.txt'], 'Delimiter', '\t', 'ReadVariableNames', false);
secretionTable = table2cell(secretionTable);
% remove the reference columns
for i=1:11
    if ~isempty(find(strcmp(['Ref' num2str(i)],secretionTable(1,:))))
secretionTable(:,find(strcmp(['Ref' num2str(i)],secretionTable(1,:))))=[];
    end
end

secretionGapfillAddConditional = {
    % secretion products, condition, add reaction(s)
    'Sulfide', '~any(ismember(model.rxns, {''CYSDS'',''CYSTS_H2S''}))', {'CYSDS'}
    'Trimethylamine', '~any(ismember(model.rxns, {''TMAOR1e'',''TMAOR2e''}))', {'TMAOt2r','TMAt2r','TMAOR1','TMAOR2'}
    };

% secretion product list from input table
% modify names to agree with structure
% can only contain alphabetic, numeric, or underscore characters and cannot
% start with a number or underscore.
% Any non-alphabetic, numeric, or underscore characters removed. Any names
% starting with a number changed to x_number.
products = secretionTable(1, 2:end);
numStart = find(~cellfun(@isempty, regexp(products, '^\d+')));% find names that start with numbers
products(numStart) = strcat('x_', products(numStart));
products = regexprep(products, '\W', '');% remove special characters

% microbe index in file
orgRow = find(strcmp(microbeID, secretionTable(:, 1)));

% find the secretion products for this microbe
spCols = find(cellfun(@str2num, secretionTable(orgRow, 2:end)) == 1);

% added rxns list
secretionRxnsAdded = {};

if ~isempty(spCols)
    secProds = products(spCols);
    for i = 1:length(secProds)
        % add rxns that are not already in model
        rxns2Add = setdiff(secretionRxns.(secProds{i}), model.rxns);
        if ~isempty(rxns2Add)
            for j = 1:length(rxns2Add)
                RxnForm = database.reactions(find(ismember(database.reactions(:, 1), rxns2Add{j})), 3);
                model = addReaction(model, rxns2Add{j}, 'reactionFormula', RxnForm{1, 1}, 'geneRule','secretionProductGapfill');
            end
            secretionRxnsAdded = union(secretionRxnsAdded, rxns2Add);
        end
        % add conditional reactions
        if any(ismember(secretionGapfillAddConditional(:, 1), secProds{i}))
            conditions = find(ismember(secretionGapfillAddConditional(:, 1), secProds{i}));
            for k = 1:length(conditions)
                if eval(secretionGapfillAddConditional{conditions(k), 2})
                    addRxns = secretionGapfillAddConditional{conditions(k), 3};
                    for j = 1:length(addRxns)
                        if ~any(ismember(model.rxns, addRxns{j}))
                            formula = database.reactions{ismember(database.reactions(:, 1), addRxns{j}), 3};
                            model = addReaction(model, addRxns{j}, 'reactionFormula', formula, 'geneRule', 'secretionProductGapfill');
                            secretionRxnsAdded = union(secretionRxnsAdded, addRxns{j});
                        end
                    end
                end
            end
        end
    end
end

end
