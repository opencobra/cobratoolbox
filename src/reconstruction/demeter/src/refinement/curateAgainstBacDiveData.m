function [model, addedRxns, removedRxns] = curateAgainstBacDiveData(model, microbeID, database, inputDataFolder)
% Gap-fills and/or removes reactions in a genome-scale reconstructions
% based on data from BacDive (https://bacdive.dsmz.de).
%
% USAGE
%   [model, addedRxns, removedRxns] = gapfillAgainstBacDiveData(model, microbeID, database, inputDataFolder)
%
% INPUT
% model             COBRA model structure
% microbeID:        ID of the reconstructed microbe that serves as the
%                   reconstruction name and to identify it in input tables
% database          rBioNet reaction database containing min. 3 columns:
%                   Column 1: reaction abbreviation, Column 2: reaction
%                   name, Column 3: reaction formula.
% inputDataFolder   Folder with experimental data and database files
%                   to load
%
% OUTPUT
% model             COBRA model structure refined through BacDive data
% addedRxns         List of reactions that were added during refinement
% removedRxns       List of reactions that were removed during refinement
%
% .. Author:
% Almut Heinken, 11/2021

addedRxns={};
removedRxns={};

% check if files with BacDive data can be found, do not perform the
% refinement otherwise
if exist([inputDataFolder filesep 'BacDive_Uptake_Data.txt'])==2 && exist([inputDataFolder filesep 'BacDive_Secretion_Data.txt'])==2
    uptakeTable = readInputTableForPipeline([inputDataFolder filesep 'BacDive_Uptake_Data.txt']);
    secretionTable = readInputTableForPipeline([inputDataFolder filesep 'BacDive_Secretion_Data.txt']);
    
    tol=0.0000001;
    
    gfRxns = model.rxns(find(strcmp(model.grRules,'')));
    gfRxns = union(gfRxns, model.rxns(strncmp('Unknown', model.grRules, length('Unknown'))));
    gfRxns = union(gfRxns, model.rxns(strncmp('0000000.0.peg', model.grRules, length('0000000.0.peg'))));
    gfRxns = union(gfRxns, model.rxns(strncmp('AUTOCOMPLETION', model.grRules, length('AUTOCOMPLETION'))));
    gfRxns = union(gfRxns, model.rxns(strncmp('INITIALGAPFILLING', model.grRules, length('INITIALGAPFILLING'))));
    
    % open all exchanges
    exRxns = model.rxns(find(strncmp(model.rxns,'EX_',3)));
    model = changeRxnBounds(model, exRxns, -1000, 'l');
    model = changeRxnBounds(model, exRxns, 1000, 'u');
    
    %% define reaction sets
    % metabolite uptake pathways, reactions to add
    uptakePathwayAdd = {
        '2hb', {'EX_2hb(e)', '2HBt2'}
        '2obut', {'EX_2obut(e)', '2OBUTt2r'}
        '2ppoh', {'EX_2ppoh(e)','2PPOHt2r','EX_acetone(e)','ACETONEt2','ALCD20y'}
        '4abz', {'EX_4abz(e)', '4ABZt2'}
        '4abut', {'EX_4abut(e)', 'ABUTt2r'}
        '4hbz', {'EX_4hbz(e)', '4HBZt2'}
        '4hpro_LT', {'EX_4hpro_LT(e)', '4HPRO_LTt', 'HYPD', 'P5CR'}
        '5aptn', {'EX_5aptn(e)', '5APTNt2r'}
        '5oxpro', {'EX_5oxpro(e)', '5OXPROt'}
        'abt', {'EX_abt(e)', 'ABT_Lt2'}
        'abt_D', {'EX_abt_D(e)', 'ABT_Dt2'}
        'ac', {'EX_ac(e)', 'ACtr'}
        'acac', {'EX_acac(e)', 'ACACt'}
        'acetone', {'EX_acetone(e)', 'ACETONEt2'}
        'acgal', {'EX_acgal(e)', 'ACGALt2r', 'ACGALK3', 'AGDC2', 'GALAM6PDA', 'PFK_2', 'TGBPA'}
        'acgam', {'EX_acgam(e)', 'ACGAMtr2', 'ACGAMK', 'AGDC', 'G6PDA'}
        'acmana', {'EX_acmana(e)', 'ACMANAtr'}
        'acnam', {'EX_acnam(e)', 'ACNAMabc', 'ACNML', 'AMANK', 'AMANAPEr', 'AGDC', 'G6PDA'}
        'acon_C', {'EX_acon_C(e)', 'ACON_Ct2', 'ACONTa', 'ACONTb'}
        'actn', {'EX_actn_R(e)', 'ACTNdiff'}
        'ad', {'EX_ad(e)', 'ADtr', 'AMID4'}
        'ade', {'EX_ade(e)', 'ADEt2r'}
        'akg', {'EX_akg(e)', 'AKGt2r'}
        'ala_B', {'EX_ala_B(e)', 'BALAt2r'}
        'ala_D', {'EX_ala_D(e)', 'DALAt2r'}
        'ala_L', {'EX_ala_L(e)', 'ALAt2r', 'ALATA_L'}
        'algin', {'EX_algin(e)', 'ALGIN_DEGe', 'EX_mannur(e)', 'MANNURabc', 'EX_gulur(e)', 'MANNURRx', 'MANNURRy'}
        'alltn', {'EX_alltn(e)', 'ALLTNt2r'}
        'amylose300', {'EX_amylose300(e)', 'AMYLe', 'EX_glc_D(e)', 'GLCabc', 'EX_malt(e)', 'MALTabc'}
        'adn', {'EX_adn(e)', 'ADNt2'}
        'adpac', {'EX_adpac(e)', 'ADPACtd'}
        'arabinogal', {'EX_arabinogal(e)', 'ARABINOGALASEe', 'EX_arab_L(e)', 'ARBabc', 'EX_gal(e)', 'GALabc', 'EX_rmn(e)', 'RMNt2', 'EX_glcur(e)', 'GLCURt2r'}
        'arab_D', {'EX_arab_D(e)', 'ARB_Dabc', 'EX_gcald(e)', 'GCALDt', 'ARABI', 'RBK_D', 'RPE', 'XYLK', 'KHK2', 'FBA4'}
        'arab_L', {'EX_arab_L(e)', 'ARBabc', 'ARAI', 'RBK_L1', 'RBP4E', 'RPE', 'RPI'}
        'arabinoxyl', {'EX_arabinoxyl(e)', 'ARABINOXYL_DEGe', 'EX_arab_L(e)', 'ARBabc', 'EX_gal(e)', 'GALabc', 'EX_xyl_D(e)', 'XYLabc', 'EX_glc_D(e)', 'GLCabc'}
        'arbt', {'EX_arbt(e)','ARBTpts','AB6PGH','AB6PGH2','DM_HQN'}
        'arg_L', {'EX_arg_L(e)', 'ARGt2r', 'ARGDA', 'OCBT', 'CBMKr', 'ORNTA', 'G5SADs', 'P5CD'}
        'asn_L', {'EX_asn_L(e)', 'ASNt2r'}
        'asp_D', {'EX_asp_D(e)', 'ASPDTDe'}
        'asp_L', {'EX_asp_L(e)', 'ASPt2r' , 'ASPT', 'FUM', 'MDH', 'CS', 'ACONT' 'ICDHy', 'SUCD1', 'SUCD4', 'SUCDi'}
        'bglc', {'EX_bglc(e)', 'EX_glc_D(e)', 'GLCabc', 'BGLC_DEGe'}
        'bgly', {'EX_bgly(e)', 'BGLYte'}
        'bhb', {'EX_bhb(e)', 'BHBt'}
        'btn', {'EX_btn(e)', 'BTNabc', 'DM_btn'}
        'btoh', {'EX_btoh(e)', 'BTOHt2r', 'ALCD4', 'BTALDH', 'PBUTT', 'BUTKr', 'EX_but(e)', 'BUTt2r'}
        'btd_RR', {'EX_btd_RR(e)', 'BTDt1_RR'}
        'but', {'EX_but(e)', 'BUTt2', 'BUTCT', 'ACOAD1f', 'ECOAH1', 'HACD1', 'ACACT1r', 'SUCD1', 'SUCD4'}
        'butam', {'EX_butam(e)','BUTAMt2r'}
        'bz', {'EX_bz(e)', 'BZt'}
        'C02356', {'EX_C02356(e)', 'C02356t2r'}
        'cellb', {'EX_cellb(e)', 'PGI', 'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
        'cellul', {'EX_cellul(e)', 'EX_glc_D(e)', 'CELLUL_DEGe'}
        'cit', {'EX_cit(e)', 'r1088', 'CITL'}
        'citr_L', {'EX_citr_L(e)', 'CITR_Lt2'}
        'co2', {'EX_co2(e)', 'CO2t', 'PPCKr'}
        'creat', {'EX_creat(e)', 'r0942'}
        'cspg_a', {'EX_cspg_a(e)', 'EX_cspg_b(e)', 'EX_cspg_c(e)', 'EX_cspg_a_degr(e)', 'EX_cspg_b_degr(e)', 'EX_cspg_c_degr(e)', 'EX_cspg_ab_rest(e)', 'EX_cspg_c_rest(e)', 'EX_acgalglcur(e)', 'EX_acgalidour(e)', 'EX_acgalidour2s(e)', 'EX_idour(e)', 'EX_so4(e)', 'SO4t2', 'EX_acgal(e)', 'ACGALt2r', 'EX_glcur(e)', 'GLCURt2r', 'CSABCASE_A_e', 'CSABCASE_B_e', 'CSABCASE_C_e', 'CS4TASE', 'CS4TASE2', 'CS6TASE', 'GLCAASEe', 'IS2TASE', 'IDOURASE'}
        'cys_L', {'EX_cys_L(e)', 'CYSt2r', 'EX_h2s(e)', 'H2St', 'CYSDS'}
        'dad_2', {'EX_dad_2(e)', 'DADNt2'}
        'dca', {'EX_dca(e)', 'DCATDc'}
        'dextran40', {'EX_dextran40(e)', 'EX_malt(e)', 'MALTabc', 'DEXTRAN40e'}
        'dextrin', {'EX_dextrin(e)', 'DEXTRINabc', 'DEXTRINASE', 'HEX1'}
        'dma', {'EX_dma(e)', 'DMAt2r'}
        'ethrtl', {'EX_ethrtl(e)', 'ETHRTLabc', 'ETHRTLK', 'ETHRTL1PDH', 'ERYTH1PDE', 'ERYTH1PLE', 'ERYTH4PDE'}
        'etha', {'EX_etha(e)', 'ETHAt2', 'ETHAAL'}
        'etoh', {'EX_etoh(e)', 'ETOHt2r'}
        'f6p', {'EX_f6p(e)','F6Pt2r'}
        'fe2', {'EX_fe2(e)','FE2abc'}
        'fru', {'EX_fru(e)', 'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
        'for', {'EX_for(e)','FORt'}
        'fuc_L', {'EX_fuc_L(e)', 'FUCt2_1', 'FCI', 'FCLK', 'FCLPA', 'LCARS', 'EX_12ppd_S(e)', '12PPDt'}
        'fum', {'EX_fum(e)', 'FUMt2r'}
        'g6p', {'EX_g6p(e)','DGLU6Pt2'}
        'gal', {'EX_gal(e)', 'GALabc', 'GALK', 'UGLT', 'UDPG4E', 'PGMT', 'PGI', 'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
        'galct_D', {'EX_galct_D(e)','GALACt','GALCTD'}
        'galctn_D', {'EX_galctn_D(e)','GALCTNt2r','GALCTND','DDGALK','DDPGALA'}
        'galt', {'EX_galt(e)','GALTpts'}
        'galur', {'EX_galur(e)', 'GALURt2r', 'GUI2', 'TAGURr', 'ALTRH', 'DDGLK', 'EDA'}
        'gam', {'EX_gam(e)', 'GAMt2r', 'HEX10', 'G6PDA'}
        'glcmannan', {'EX_glcmannan(e)', 'GLCMANNAN_DEGe', 'EX_man(e)', 'MANabc', 'EX_glc_D(e)', 'GLCabc'}
        'glcn', {'EX_glcn(e)', 'GLCNt2r', 'GLCDe', 'GNK', 'EDD', 'EDA'}
        'glcr', {'EX_glcr(e)','GLCRt2'}
        'glc_D', {'EX_glc_D(e)', 'GLCabc', 'HEX1', 'PGI', 'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
        'glcur', {'EX_glcur(e)', 'GLCURt2r', 'GUI1', 'MANAO', 'MNNH', 'DDGLK', 'EDA'}
        'glu_L', {'EX_glu_L(e)', 'GLUt2r', 'ASPTA', 'ASPT', 'FUM', 'MDH', 'CS', 'ACONT' 'ICDHy', 'SUCD1', 'SUCD4', 'SUCDi'}
        'gln_L', {'EX_gln_L(e)', 'GLNt2r'}
        'glutar', {'EX_glutar(e)', 'GLUTARt2r'}
        'glx', {'EX_glx(e)', 'GLXt'}
        'glyald', {'EX_glyald[e]','GLYALDt'}
        'glyb', {'EX_glyb(e)', 'GLYBt2r'}
        'glyc', {'EX_glyc(e)', 'GLYCt', 'GLYK', 'G3PD1'}
        'glyc_R', {'EX_glyc_R(e)', 'GLYC_Rt'}
        'glygn2', {'EX_glygn2(e)', 'EX_glygn4(e)', 'EX_glygn5(e)', 'EX_malt(e)', 'MALTabc', 'EX_Tyr_ggn(e)', 'EX_glc_D(e)', 'GLCabc', 'AMY2e', 'O16G1e', 'GAMYe'}
        'gly', {'EX_gly(e)', 'GLYt2r'}
        'glyclt', {'EX_glyclt(e)', 'GLYCLTt2r'}
        'glyglu', {'EX_glyglu(e)', 'GLYGLUabc','GLYGLU1c'}
        'glypro', {'EX_glypro(e)', 'GLYPROabc','GLYPROPRO1c'}
        'gua', {'EX_gua(e)', 'GUAt2r'}
        'h2', {'EX_h2(e)', 'H2td'}
        'h2s', {'EX_h2s(e)', 'H2St'}
        'hspg', {'EX_hspg(e)', 'EX_hspg_degr_1(e)', 'EX_hspg_degr_2(e)', 'EX_hspg_degr_3(e)', 'EX_hspg_degr_4(e)', 'EX_hspg_degr_5(e)', 'EX_hspg_degr_6(e)', 'EX_hspg_degr_7(e)', 'EX_hspg_degr_8(e)', 'EX_hspg_degr_9(e)', 'EX_hspg_degr_10(e)', 'EX_hspg_degr_11(e)', 'EX_hspg_degr_12(e)', 'EX_hspg_degr_13(e)', 'EX_hspg_degr_14(e)', 'EX_hspg_degr_15(e)', 'EX_hspg_rest(e)', 'EX_gam26s(e)', 'EX_idour(e)', 'EX_so4(e)', 'SO4t2', 'EX_gal(e)', 'GALabc', 'EX_glcur(e)', 'GLCURt2r', 'EX_gam(e)', 'GAMt2r', 'HEPARL1_e', 'IDOURASE_HS1', 'IDOURASE_HS2', 'IDOURASE_HS3', 'AS3TASE_HS1', 'AS3TASE_HS2', 'AS6TASE_HS1', 'AS6TASE_HS2', 'GAM2STASE_HS1', 'GAM2STASE_HS2', 'GAM2STASE_HS3', 'GLCAASE_HSe', 'GLCNACASE_HS1', 'GLCNACASE_HS2', 'IS2TASE_HS1', 'GALASE_HSe'}
        'his_L', {'EX_his_L(e)', 'HISt2r', 'HISD', 'URCN', 'IZPN', 'FGLU', 'FORAMD'}
        'hxan', {'EX_hxan(e)', 'HXANt2r'}
        'indole', {'EX_indole(e)', 'INDOLEt2r', 'TRPS1', 'TRPS2', 'TRPS3r'}
        'ins', {'EX_ins(e)', 'INSt2i'}
        'inost', {'EX_inost(e)', 'INSTt2r', 'INS2D', '2INSD', 'DKDID', 'D5KGK', 'D5KGPA'}
        'inulin', {'EX_inulin(e)'}
        'isobut', {'EX_isobut(e)', 'ISOBUTt2r', 'FACOALib', 'IBCOAMPO', 'ECOAH12', '3HBCOAHL', 'HIBDkt', 'MMTSAO', 'SUCD1', 'SUCD4'}
        'ile_L', {'EX_ile_L(e)', 'ILEt2r', 'ILETA', 'OIVD3', '2MECOAOX', 'ECOAH9', 'HACD9', 'MACCOAT', 'MCITS', 'MCITD', 'MICITDr', 'MCITL2', 'SUCD1', 'SUCD4'}
        'isoval', {'EX_isoval(e)', 'ISOVALt2r', 'FACOALiv', 'ACOAD8', 'MCCCr', 'MGCOAH', 'HMGL', 'OCOAT1r', 'ACACT1r', 'SUCD1', 'SUCD4'}
        'lac_D', {'EX_lac_D(e)', 'D_LACt2', 'LDH_D', 'PYK'}
        'lac_L', {'EX_lac_L(e)', 'L_LACt2r', 'LDH_L', 'PYK'}
        'lactl', {'EX_lactl(e)', 'LACTLt', 'GALASE_LACTL'}
        'lcts', {'EX_lcts(e)', 'GALK', 'UGLT', 'UDPG4E', 'PGMT', 'HEX1', 'PGI', 'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
        'Lkynr', {'EX_hLkynr[e]', 'LKYNRt2r'}
        'lmn30', {'EX_lmn30(e)', 'EX_lmn2(e)', 'EX_glc_D(e)', 'GLCabc', 'LMNe', 'LMN2e'}
        'lichn', {'EX_lichn(e)', 'LICHN_DEGe', 'EX_glc_D(e)', 'GLCabc'}
        'leu_L', {'EX_leu_L(e)', 'LEUt2r', 'LEUTA', 'OIVD1r', 'ACOAD8', 'MCCCr', 'MGCOAH', 'HMGL', 'OCOAT1r', 'ACACT1r', 'SUCD1', 'SUCD4'}
        'lys_L', {'EX_lys_L(e)', 'LYSt2r', 'EX_15dap(e)', '15DAPt', 'LYSDC', 'DAPAT', 'PPRDNDH', 'APTNAT', 'OXPTNDH', 'GLCOAS', 'GLUTCOADH2', 'ECOAH1', 'HACD1', 'ACACT1r', 'SUCD1', 'SUCD4'}
        'M03134', {'EX_M03134(e)', 'M03134t2r'}
        'mal_D', {'EX_mal_D(e)', 'MAL_Dt2r'}
        'mal_L', {'EX_mal_L(e)', 'MALt2r'}
        'malt', {'EX_malt(e)', 'MALTabc', 'PGI', 'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
        'malttr', {'EX_malttr(e)', 'MALTTRabc', 'MLTG1'}
        'mannan', {'EX_mannan(e)', 'MANNANASEe', 'EX_man(e)', 'MANabc', 'HEX4', 'MAN6PI'}
        'meoh', {'EX_meoh(e)', 'MEOHt2','PRDX','ALDD1'}
        'mma', {'EX_mma(e)', 'MMAt2e'}
        'mnl', {'EX_mnl(e)'}
        'man', {'EX_man(e)', 'MANabc', 'HEX4', 'MAN6PI'}
        'melib', {'EX_melib(e)', 'MELIBabc', 'GALS3', 'GALK', 'UGLT', 'UDPG4E', 'HEX1', 'PGI', 'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
        'met_L', {'EX_met_L(e)', 'METt2r', 'EX_ch4s(e)', 'CH4St', 'METGL', 'OBDHc'}
        'nh4', {'EX_nh4(e)', 'NH4tb'}
        'no2', {'EX_no2(e)', 'NO2t2r'}
        'no3', {'EX_no3(e)', 'NO3abc', 'NO3R1', 'NO3R2', 'EX_no2(e)', 'NO2t2r'}
        'oaa', {'EX_oaa(e)', 'OAAt2r'}
        'ocdcea', {'EX_ocdcea(e)', 'OCDCEAtr'}
        'octa', {'EX_octa(e)', 'OCTAt'}
        'orn', {'EX_orn(e)', 'ORNt2r', 'EX_ptrc(e)', 'PTRCt2r', 'ORNDC'}
        'oxa', {'EX_oxa(e)', 'EX_for(e)', 'FORt2r', 'FOROXAtex', 'FORMCOAT', 'OXCOADC', 'ATPS3'}
        'pect', {'EX_pect(e)', 'EX_galur(e)', 'GALURt2r', 'EX_meoh(e)', 'MEOHt2', 'PECTIN_DEGe'}
        'pac', {'EX_pac(e)', 'PACt2r', 'PACCOAL', 'PHACOAO', 'HBCD', '3OXCOAT', 'KACOAT2'}
        'phe_L', {'EX_phe_L(e)', 'PHEt2r', 'PHETA1', 'EX_phpyr(e)', 'PHPYRt2r'}
        'phenol', {'EX_phenol(e)', 'PHENOLt2r'}
        'pime', {'EX_pime(e)', 'PIMEtr'}
        'pro_L', {'EX_pro_L(e)', 'PROt2r', 'PROD2', 'PROD3', 'P5CD', 'SUCD1', 'SUCD4'}
        'ppa', {'EX_ppa(e)', 'PPAt2r', 'EX_succ(e)', 'SUCCt2r', 'ACCOAL', 'MCITS', 'MCITD', 'MICITD', 'MCITL2'}
        'ppoh', {'EX_ppoh(e)', 'PPOHt2r'}
        'pppn', {'EX_pppn(e)', 'PPPNt2r'}
        'psics_D', {'EX_psics_D(e)', 'PSICSabc', 'PSICSE'}
        'ptrc', {'EX_ptrc(e)'}
        'pullulan1200', {'EX_pullulan1200(e)', 'PULLe', 'EX_malttr(e)', 'MALTTRabc', 'MLTG1'}
        'pyr', {'EX_pyr(e)', 'PYRt2r'}
        'raffin', {'EX_raffin(e)', 'RAFFabc', 'GALK', 'UGLT', 'PGMT', 'UDPG4E', 'SUCR', 'HEX7', 'HEX1', 'PGI', 'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
        'rbt', {'EX_rbt(e)', 'Rbtt2'}
        'rmn', {'EX_rmn(e)', 'RMNt2', 'EX_12ppd_S(e)', '12PPDt', 'RMI', 'RMK', 'RMPA', 'LCARS'}
        'rib_D', {'EX_rib_D(e)', 'RIBabc', 'RBK'}
        'salc', {'EX_salc(e)', 'SALCt2'}
        'salcn', {'EX_salcn(e)', 'SALCpts', '6PHBG', 'DM_2HYMEPH'}
        'sarcs', {'EX_sarcs(e)', 'SARCStex'}
        'sbt_D', {'EX_sbt_D(e)', 'SBTt6', 'SBTD_D2'}
        'sebacid', {'EX_sebacid(e)', 'SEBACIDtd'}
        'ser_D', {'EX_ser_D(e)', 'DSERt2r'}
        'ser_L', {'EX_ser_L(e)', 'SERt2r', 'r0060'}
        'so3', {'EX_so3(e)', 'SO3t2'}
        'so4', {'EX_so4(e)', 'SO4t2'}
        'sprm', {'EX_sprm(e)', 'SPRMt2r'}
        'srb_L', {'EX_srb_L(e)', 'SRB_Labc', 'SBTOR', 'SBTD_D2'}
        'stys', {'EX_stys(e)', 'STYSabc', 'STYSGH', 'GALS3'}
        'strch1', {'EX_strch1(e)', 'EX_strch2(e)', 'EX_glc_D(e)', 'GLCabc', 'EX_malt(e)', 'MALTabc', 'AMY1e', 'O16G2e'}
        'succ', {'EX_succ(e)', 'SUCCt2r'}
        'subeac', {'EX_subeac(e)', 'SUBEACtd'}
        'sucr', {'EX_sucr(e)', 'HEX7', 'PGI', 'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
        'tagat_D', {'EX_tagat_D(e)', 'TAGATabc', 'KHK3', 'FBA5'}
        'tartr_L', {'EX_tartr_L(e)', 'TARTRt2r'}
        'tet', {'EX_tet(e)', 'TETt2r'}
        'thymd', {'EX_thymd(e)', 'THMDt2r'}
        'tma', {'EX_tma(e)', 'TMAt2r'}
        'tre', {'EX_tre(e)', 'HEX1', 'PGI', 'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
        'thr_L', {'EX_thr_L(e)', 'THRt2r', 'THRD_L', 'OBDHc', 'PTA2', 'PPAKr', 'EX_ppa(e)', 'PPAt2r'}
        'trp_L', {'EX_trp_L(e)', 'TRPt2r', 'TRPAS2', 'EX_indole(e)', 'INDOLEt2r'}
        'trypta', {'EX_trypta(e)', 'TRYPTAte'}
        'tststerone', {'EX_tststerone(e)', 'TSTSTERONEt'}
        'tsul', {'EX_tsul(e)', 'TSULabc'}
        'turan_D', {'EX_turan_D(e)', 'TURANabc', 'TURAN_DEG', 'HEX1'}
        'tyr_L', {'EX_tyr_L(e)', 'TYRt2r', 'TYRTA', 'IOR3', 'PACCOAL2r', 'EX_4hphac(e)', 'HPACt2r'}
        'val_L', {'EX_val_L(e)', 'VALt2r', 'VALTA', 'OIVD2', 'ACOADH2', 'ECOAH12', '3HBCOAHL', 'HIBDkt', 'MMTSAO'}
        'urate', {'EX_urate(e)', 'URATEtr'}
        'urea', {'EX_urea(e)', 'EX_urea(e)', 'UREAt', 'UREA'}
        'uri', {'EX_uri(e)', 'URIt2'}
        'xan', {'EX_xan(e)', 'XANt2r'}
        'xylan', {'EX_xylan(e)', 'EX_xyl_D(e)', 'XYLabc', 'XYLAN_DEGe'}
        'xylt', {'EX_xylt(e)', 'XYLTabc', 'XYLTD_Dr'}
        'xyl_D', {'EX_xyl_D(e)', 'XYLabc', 'XYLI1', 'XYLK'}
        };
    
    uptakePathwayAddConditional = {
        % metabolite uptake, condition, add reaction(s)
        '2obut', 'any(ismember(model.rxns, ''ACHBPL'')) && ~any(ismember(model.rxns, {''OBTFL'', ''OBDHc''}))', {'KARA2', 'DHAD2'}
        'cellb', 'any(ismember(model.rxns, ''CELBpts''))', {'BGLA1', 'HEX1'}
        'cellb', '~any(ismember(model.rxns, ''CELBpts''))', {'BGLA','CELLBabc', 'HEX1'}
        'fru', 'any(ismember(model.rxns, ''FRUpts''))', {'FBA2'}
        'fru', '~any(ismember(model.rxns, ''FRUpts''))', {'FRUt2r', 'HEX7'}
        'glyc', 'isempty(intersect(model.rxns, {''FRD7'', ''N2Ormq'', ''N2OO'', ''CYTBD'', ''SUCD4'', ''NOr1mq'', ''NO3rPuq''}))', {'DM_q8h2[c]'}
        'inost', 'isempty(intersect(model.rxns, {''MMSAD3'', ''AMAMTi'', ''APATr'', ''MMSAD5'', ''3HPPD'', ''MMSAD4i''}))', {'MMSAD3'}
        'inulin', 'strncmp(''Bacteroides'', microbeID, 11)', {'EX_kestopt(e)', 'EX_glc_D(e)', 'EX_fru(e)', 'FRUt2r', 'INULINASEe', 'KESTOPTASEe'}
        'inulin', '~strncmp(''Bacteroides'', microbeID, 11)', {'INULINabc', 'INULINASE'}
        'inulin', 'any(ismember(model.rxns, ''HEX1''))', {'HEX7'}
        'inulin', '~any(ismember(model.rxns, ''HEX1''))', {'KHK'}
        'lcts', 'any(ismember(model.rxns, ''LACpts''))', {'6PGALSZ', 'GAL6PI', 'PFK_2', 'TGBPA'}
        'lcts', '~any(ismember(model.rxns, ''LACpts''))', {'LACZ','LCTSabc'}
        'malt', 'any(ismember(model.rxns, ''MALTpts''))', {'MALT6PH', 'HEX1'}
        'malt', '~any(ismember(model.rxns, ''MALTpts''))', {'MALT','MALTabc', 'HEX1'}
        'mnl', 'any(ismember(model.rxns, ''MNLpts''))', {'M1PD'}
        'mnl', '~any(ismember(model.rxns, ''MNLpts''))', {'MANAD_D', 'MNLt6', 'HEX7'}
        'raffin', '~any(ismember(model.rxns, ''RAFH''))', {'RAFGH'}
        'raffin', 'any(ismember(model.rxns, ''RAFH''))', {'GALS3'}
        'stys', 'any(ismember(model.rxns, ''GALS3''))', {'RAFH'}
        'stys', 'any(ismember(model.rxns, ''GALT''))', {'GALK'}
        'succ', '~any(ismember(model.rxns, {''N2OO'', ''CYTBD'', ''NO3rPuq''}))', {'DM_q8h2[c]', 'EX_q8(e)', 'Q8abc'}
        'sucr', '~any(ismember(model.rxns, ''SUCpts''))', {'SUCR', 'SUCRt2', 'HEX1'}
        'sucr', 'any(ismember(model.rxns, ''SUCpts''))', {'FFSD'}
        'tre', '~any(ismember(model.rxns, ''TREpts''))', {'TREH', 'TREabc'}
        'tre', 'any(ismember(model.rxns, ''TREpts'')) && ~any(ismember(model.rxns, {''TRE6PPGT'', ''TRE6PP''}))', {'TRE6PH'}
        'tre', 'any(ismember(model.rxns, ''TREpts'')) && any(ismember(model.rxns, ''TRE6PPGT''))', {'PGMT'}
        'tre', 'any(ismember(model.rxns, ''TREpts'')) && ~any(ismember(model.rxns, ''TRE6PPGT''))  && any(ismember(model.rxns, ''TRE6PP''))', {'TREH'}
        'turan_D', 'any(ismember(model.rxns, ''HEX1'')) && ~any(ismember(model.rxns, ''FRUt2r''))', {'HEX7'}
        'xylt', 'any(ismember(model.rxns, ''TKT2''))', {'XYLK'}
        'xylt', 'any(ismember(model.rxns, ''KHK2''))', {'FBA4'}
        };
    
    % metabolite secretion pathways, reactions to add
    secretionPathwayAdd = {
        'ac', {'EX_ac(e)', 'ACtr', 'ACKr', 'PTAr'}
        'actn_R', {'EX_actn_R(e)', 'ACTNdiff', 'ACTNDH', 'ACALD'}
        'btd_RR', {'EX_btd_RR(e)', 'BTDt1_RR', 'BTDD_RR'}
        'btoh', {'EX_btoh(e)', 'BTOHt2r', 'ALCD4', 'BTALDH'}
        'but', {'EX_but(e)', 'BUTt2r', 'ACACT1r', 'HACD1', 'ECOAH1', 'ECOAH1R', '3HBCOAE', 'BTCOADH', 'FDNADOX_H', 'BTCOAACCOAT'}
        'ch4', {'EX_ch4(e)', 'CH4t','EX_h2(e)', 'H2td', 'EX_for(e)', 'FORt', 'EX_ac(e)', 'ACtr', 'EX_nh4(e)', 'NH4tb', 'EX_etoh(e)', 'ETOHt2r', 'EX_acald(e)', 'ACALDt', 'EX_meoh(e)', 'MEOHt2',  'EX_hco3(e)', 'HCO3abc', 'H2CO3D', 'ALCD2y', 'PC', 'MDH', 'FUM', 'SUCD1', 'SUCD4', 'SUCOAS', 'AKGS', 'GLUDxi', 'GLUDy', 'GLNS', 'GLUSx', 'GLUSy', 'POR4', 'PPS', 'ACS', 'ALCD2y', 'FDH', 'MCOMR', 'MH4MPTMT', 'COBCOMOX', 'MCOX', 'MCOX2', 'MTTH4MPTH', 'FMFUROr', 'MPHZEH', 'COF420_NADP_OX', 'MCMMT', 'COF420H', 'ATPS4'}
        'co2', {'EX_co2(e)', 'CO2t'}
        'dha', {'EX_dha(e)', 'DHAt'}
        'etoh', {'EX_etoh(e)', 'ETOHt2r', 'ALCD2x', 'ACALD', 'ACALDt', 'EX_acald(e)', 'PYK'}
        'for', {'EX_for(e)', 'FORt', 'PFL'}
        'h2', {'EX_h2(e)', 'H2td'}
        'h2s', {'EX_h2s(e)','H2St'}
        'indole', {'EX_indole(e)', 'INDOLEt2r', 'EX_trp_L(e)', 'TRPt2r', 'TRPAS2'}
        'isobut', {'EX_isobut(e)', 'ISOBUTt2r', 'EX_val_L(e)', 'VALt2r', 'VALO'}
        'isoval', {'EX_isoval(e)', 'ISOVALt2r', 'EX_leu_L(e)', 'LEUt2r', 'LEUO', 'ISOCAPRt2r', 'EX_isocapr(e)'}
        'lac_D', {'EX_lac_D(e)', 'D_LACt2', 'LDH_D', 'PYK'}
        'lac_L', {'EX_lac_L(e)', 'L_LACt2r', 'LDH_L', 'PYK'}
        'M03134', {'EX_M03134(e)', 'M03134t2r', '5APTNt2r','EX_5aptn(e)','APTNAT','5HVALDH', '5HVALCOAT', '5HVALCOADH', '5H2PENTCOAD', '24PENTDCOAR', '3PENTI', '24PENTDCOAR2', 'VALCOADH', '3HISOVALCOAG', '3HISOVALCOAC', 'VALCOAACCOAT'}
        'n2', {'EX_n2(e)','N2t','N2OFO','EX_n2o(e)','N2Ot'}
        'nh4', {'EX_nh4(e)','NH4tb'}
        'no2', {'EX_no2(e)','NO2t2'}
        'pac', {'EX_pac(e)', 'PACt2r', 'EX_phe_L(e)', 'PHEt2r', 'PACCOALr', 'PACCOAL2r', 'IOR2', 'IOR3', 'PHETA1'}
        'pheme', {'EX_pheme(e)','PHEMEABCte','CPPPGO2','DM_dad_5','FCLTc','G1SAT','GLUTRR','GLUTRS','HMBS','PPBNGS','PPPGO3','UPP3S','UPPDC1','EX_succ(e)','SUCCt'}
        'ppa', {'EX_ppa(e)', 'PPAt2r', 'EX_succ(e)', 'SUCCt2r', 'SUCOAS', 'MMM2r' 'MME', 'MMCD', 'PTA2', 'PPAKr'}
        'so4', {'EX_so4(e)','SO4t2'}
        'succ', {'EX_succ(e)', 'SUCCt2r', 'EX_fum(e)', 'FUMt2', 'FRD2', 'FRD3', 'FRD7', 'SUCD1', 'SUCD4', 'SUCDi', 'FUM', 'MDH', 'PPCKr'}
        'trp_L', {'EX_trp_L(e)','TRPt2r','DDPA','DHQS','DHQTi','SHK3Dr','SHKK','PSCVT','CHORS','ANS','ANPRT','PRAI','IGPS','TRPS1','TRPS2','TRPS3r'}
        };
    
    secretionPathwayAddConditional = {
        % fermentation products, condition, add reaction(s)
        % Some reconstructions need to take up acetate to produce biomass -
        % gap-filled to fix this based on related strains
        'ac', 'any(ismember(model.rxns, ''FDOXR'')) && any(ismember(model.rxns, ''POR4'')) && ~any(ismember(model.rxns, ''FDNADOX_H''))', {'EX_no2(e)', 'NO2t2'}
        'ac', 'any(ismember(model.rxns, ''AGPAT180'')) && any(ismember(model.rxns, ''PPIACPT'')) && any(ismember(model.rxns, ''FAO181O''))', {'EX_ocdca(e)','OCDCAtr','FA180ACPHrev'}
        'ac', 'any(ismember(model.rxns, ''N2OFO'')) && any(ismember(model.rxns, ''OOR2r'')) && any(ismember(model.rxns, ''POR4''))', {'NIT_n1p4'}
        'ac', 'length(findRxnsFromMets(model,''fdxrd[c]''))<2 && any(ismember(model.rxns, ''POR4''))', {'FRDO'}
        'ac', '~any(ismember(model.rxns, ''ACS''))', {'ACS'}
        'ac', 'any(ismember(model.rxns, ''ACONTa''))', {'ICDHx','ICDHyr'}
        'ac', 'any(ismember(model.rxns, ''MDH'')) && any(ismember(model.rxns, ''POR4'')) && any(ismember(model.rxns, ''FUM''))', {'ACONTa','ACONTb','ICDHx','ICDHyr','OAASr'}
        'succ', '~any(ismember(model.rxns, ''PPA''))', {'PPA','PPA2'}
        };
    
    % find the pathways to add
    uptakePathways=uptakeTable(1,2:end);
    secretionPathways=secretionTable(1,2:end);
    
    uInd = find(ismember(uptakeTable(:, 1), microbeID));
    sInd = find(ismember(secretionTable(:, 1), microbeID));
    
    if ~isempty(uInd)
        if contains(version,'(R202') % for Matlab R2020a and newer
            uptakeMets = uptakePathways(find(cell2mat(uptakeTable(uInd, 2:end)) == 1));
            noUptakeMets = uptakePathways(find(cell2mat(uptakeTable(uInd, 2:end)) == -1));
        else
            uptakeMets = uptakePathways(find(str2double(uptakeTable(uInd, 2:end)) == 1));
            noUptakeMets = uptakePathways(find(str2double(uptakeTable(uInd, 2:end)) == -1));
        end
    else
        uptakeMets = {};
        noUptakeMets = {};
    end
    if ~isempty(sInd)
        if contains(version,'(R202') % for Matlab R2020a and newer
            secretionMets = secretionPathways(find(cell2mat(secretionTable(sInd, 2:end)) == 1));
            noSecretionMets = secretionPathways(find(cell2mat(secretionTable(sInd, 2:end)) == -1));
        else
            secretionMets = secretionPathways(find(str2double(secretionTable(sInd, 2:end)) == 1));
            noSecretionMets = secretionPathways(find(str2double(secretionTable(sInd, 2:end)) == -1));
        end
    else
        secretionMets = {};
        noSecretionMets = {};
    end
    if length(uptakeMets)==0 && length(noUptakeMets)==0 && length(secretionMets)==0 && length(noSecretionMets)==0
        warning(['No BacDive data found for ', microbeID])
    else
        
        %% refine based on metabolite uptake data
        
        % go through consumed metabolites
        % curate metabolites that should be consumed
        for i = 1:length(uptakeMets)
            % find pathway reactions to add
            if ~isempty(find(ismember(uptakePathwayAdd(:, 1), uptakeMets{i})))
                addRxns = uptakePathwayAdd{find(ismember(uptakePathwayAdd(:, 1), uptakeMets{i})), 2};
                
                % first check if the model can already consume the metabolite
                refine=1;
                if ~isempty(intersect(model.rxns,addRxns{1}))
                    modelTest=changeObjective(model,addRxns{1});
                    FBA=optimizeCbModel(modelTest,'min');
                    if FBA.f <-tol
                        refine=0;
                    end
                end
                
                if refine==1
                    % if the model cannot consume the metabolite (but should)
                    for j = 1:length(addRxns)
                        if ~any(ismember(model.rxns, addRxns{j}))
                            formula = database.reactions{ismember(database.reactions(:, 1), addRxns{j}), 3};
                            model = addReaction(model, addRxns{j}, 'reactionFormula', formula, 'geneRule', 'BacDiveDataRefinement');
                            addedRxns{length(addedRxns)+1,1} = addRxns{j};
                        end
                    end
                    
                    % add conditional reactions
                    if any(ismember(uptakePathwayAddConditional(:, 1), uptakeMets{i}))
                        conditions = find(ismember(uptakePathwayAddConditional(:, 1), uptakeMets{i}));
                        for k = 1:length(conditions)
                            if eval(uptakePathwayAddConditional{conditions(k), 2})
                                addRxns = uptakePathwayAddConditional{conditions(k), 3};
                                for j = 1:length(addRxns)
                                    if ~any(ismember(model.rxns, addRxns{j}))
                                        formula = database.reactions{ismember(database.reactions(:, 1), addRxns{j}), 3};
                                        model = addReaction(model, addRxns{j}, 'reactionFormula', formula, 'geneRule', 'BacDiveDataRefinement');
                                        addedRxns{length(addedRxns)+1,1} = addRxns{j};
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        % curate metabolites that should not be consumed
        for i = 1:length(noUptakeMets)
            if ~isempty(find(ismember(uptakePathwayAdd(:, 1), noUptakeMets{i})))
                % find pathway reactions to add
                addRxns = uptakePathwayAdd{find(ismember(uptakePathwayAdd(:, 1), noUptakeMets{i})), 2};
                
                % first check if the model can consume the metabolite
                refine=0;
                if ~isempty(intersect(model.rxns,addRxns{1}))
                    modelTest=changeObjective(model,addRxns{1});
                    FBA=optimizeCbModel(modelTest,'min');
                    if FBA.f <-tol
                        refine=1;
                    end
                end
                
                if refine==1
                    % if the model can consume the metabolite (but should not)
                    % remove reactions without GPRs
                    rxnsInModel=intersect(gfRxns,addedRxns);
                    for j = 1:length(rxnsInModel)
                        % check if the model can produce biomass without the
                        % reaction
                        modelTest=removeRxns(model,rxnsInModel{j});
                        FBA=optimizeCbModel(modelTest,'max');
                        if FBA.f >tol
                            removedRxns{length(removedRxns)+1,1} = rxnsInModel{j};
                        end
                    end
                end
            end
        end
        model=removeRxns(model,removedRxns);
        
        %% refine based on metabolite secretion data
        
        % go through secreted metabolites
        % curate metabolites that should be consumed
        for i = 1:length(secretionMets)
            if ~isempty(find(ismember(secretionPathwayAdd(:, 1), secretionMets{i})))
                % find pathway reactions to add
                addRxns = secretionPathwayAdd{find(ismember(secretionPathwayAdd(:, 1), secretionMets{i})), 2};
                
                % first check if the model can already consume the metabolite
                refine=1;
                if ~isempty(intersect(model.rxns,addRxns{1}))
                    modelTest=changeObjective(model,addRxns{1});
                    FBA=optimizeCbModel(modelTest,'max');
                    if FBA.f > tol
                        refine=0;
                    end
                end
                
                if refine==1
                    % if the model cannot secrete the metabolite (but should)
                    for j = 1:length(addRxns)
                        if ~any(ismember(model.rxns, addRxns{j}))
                            formula = database.reactions{ismember(database.reactions(:, 1), addRxns{j}), 3};
                            model = addReaction(model, addRxns{j}, 'reactionFormula', formula, 'geneRule', 'BacDiveDataRefinement');
                            addedRxns{length(addedRxns)+1,1} = addRxns{j};
                        end
                    end
                    
                    % add conditional reactions
                    if any(ismember(secretionPathwayAddConditional(:, 1), secretionMets{i}))
                        conditions = find(ismember(secretionPathwayAddConditional(:, 1), uptakeMets{i}));
                        for k = 1:length(conditions)
                            if eval(secretionPathwayAddConditional{conditions(k), 2})
                                addRxns = secretionPathwayAddConditional{conditions(k), 3};
                                for j = 1:length(addRxns)
                                    if ~any(ismember(model.rxns, addRxns{j}))
                                        formula = database.reactions{ismember(database.reactions(:, 1), addRxns{j}), 3};
                                        model = addReaction(model, addRxns{j}, 'reactionFormula', formula, 'geneRule', 'BacDiveDataRefinement');
                                        addedRxns{length(addedRxns)+1,1} = addRxns{j};
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        % curate metabolites that should not be secreted
        for i = 1:length(noSecretionMets)
            if ~isempty(find(ismember(secretionPathwayAdd(:, 1), noSecretionMets{i})))
                % find pathway reactions to add
                addRxns = secretionPathwayAdd{find(ismember(secretionPathwayAdd(:, 1), noSecretionMets{i})), 2};
                
                % first check if the model can consume the metabolite
                refine=0;
                if ~isempty(intersect(model.rxns,addRxns{1}))
                    modelTest=changeObjective(model,addRxns{1});
                    FBA=optimizeCbModel(modelTest,'max');
                    if FBA.f > tol
                        refine=1;
                    end
                end
                
                if refine==1
                    % if the model can consume the metabolite (but should not)
                    % remove reactions without GPRs
                    rxnsInModel=intersect(gfRxns,addedRxns);
                    for j = 1:length(rxnsInModel)
                        % check if the model can produce biomass without the
                        % reaction
                        modelTest=removeRxns(model,rxnsInModel{j});
                        FBA=optimizeCbModel(modelTest,'max');
                        if FBA.f >tol
                            removedRxns{length(removedRxns)+1,1} = rxnsInModel{j};
                        end
                    end
                end
            end
        end
        model=removeRxns(model,removedRxns);
    end
else
    warning('No BacDive data found in folder with input data.')
end

end
