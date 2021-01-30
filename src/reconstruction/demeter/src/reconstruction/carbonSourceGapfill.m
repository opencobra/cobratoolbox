function [model, addedRxns, removedRxns] = carbonSourceGapfill(model, microbeID, database,inputDataFolder)
% Gap-fills carbon source utilization pathways in a microbial reconstruction based on
% experimental evidence.
%
% USAGE
%   [model, addedRxns_carbonSources, removedRxns_carbonSources] =
%   carbonSourceGapfill(model, microbeID, database,inputDataFolder)
%
% INPUT
% model             COBRA model structure
% microbeID         Microbe ID corresponding to that in Column 1 in
%                   carbonSourcesTable
% database          rBioNet reaction database containing min. 3 columns:
%                   Column 1: reaction abbreviation, Column 2: reaction
%                   name, Column 3: reaction formula.
% inputDataFolder   Folder with experimental data and database files
%                   to load
%
% OUTPUT
% model             COBRA model structure refined through experimental data
%                   for carbon sources
% addedRxns         List of reactions that were added during refinement
% removedRxns       List of reactions that were removed during refinement
% 
%
% Almut Heinken and Stefania Magnusdottir, 2016-2020

addedRxns={};
removedRxns={};

carbonSourcesTable = readtable([inputDataFolder filesep 'CarbonSourcesTable.txt'], 'Delimiter', '\t', 'ReadVariableNames', false);
% remove the reference columns
for i=1:11
    if ismember(['Ref' num2str(i)],carbonSourcesTable.Properties.VariableNames)
carbonSourcesTable.(['Ref' num2str(i)])=[];
    end
end
carbonSourcesTable = table2cell(carbonSourcesTable);

mInd = find(ismember(carbonSourcesTable(:, 1), microbeID));
if isempty(mInd)
    warning(['Microbe ID not found in carbon source data table: ', microbeID])
end

cSources = carbonSourcesTable(1,find(strcmp(carbonSourcesTable(mInd, 1:end),'1')));
if isempty(cSources)
    warning(['No carbon sources found for ', microbeID])
end

% pathway, rxns to add
carbGapfillAdd = {
    '2-oxoglutarate', {'EX_akg(e)', 'AKGt2r'}
    '2-oxobutyrate', {'EX_2obut(e)', '2OBUTt2r'}
    '4-Hydroxyproline', {'EX_4hpro_LT(e)', '4HPRO_LTt', 'HYPD'}
    'Acetate', {'EX_ac(e)', 'ACtr'}
    'Alginate', {'EX_algin(e)', 'ALGIN_DEGe', 'EX_mannur(e)', 'MANNURabc', 'EX_gulur(e)', 'MANNURRx', 'MANNURRy'}
    'alpha-Mannan', {'EX_mannan(e)', 'MANNANASEe', 'EX_man(e)', 'MANabc', ...
                     'HEX4', 'MAN6PI'}
    'L-alanine', {'EX_ala_L(e)', 'ALAt2r', 'ALATA_L'}
    'Amylopectin', {'EX_amylopect900(e)', 'AMYLOPECTe', 'EX_glc_D(e)', 'GLCabc', ...
                    'EX_malt(e)', 'MALTabc', 'EX_malttr(e)', 'MALTTRabc', 'MLTG1'}
    'Amylose', {'EX_amylose300(e)', 'AMYLe', 'EX_glc_D(e)', 'GLCabc', 'EX_malt(e)', ...
                'MALTabc'}
    'Arabinan', {'EX_arabinan101(e)', 'ARABINANASEe', 'EX_arab_L(e)', 'ARBabc', ...
                 'EX_gal(e)', 'GALabc', 'EX_rmn(e)', 'RMNt2', 'EX_galur(e)', 'GALURt2r'}
    'Arabinogalactan', {'EX_arabinogal(e)', 'ARABINOGALASEe', 'EX_arab_L(e)', ...
                        'ARBabc', 'EX_gal(e)', 'GALabc', 'EX_rmn(e)', 'RMNt2', 'EX_glcur(e)', ...
                        'GLCURt2r'}
    'D-arabinose', {'EX_arab_D(e)', 'ARB_Dabc', 'EX_gcald(e)', 'GCALDt', 'ARABI', ...
                    'RBK_D', 'RPE', 'XYLK', 'KHK2', 'FBA4'}
    'L-arabinose', {'EX_arab_L(e)', 'ARBabc', 'ARAI', 'RBK_L1', 'RBP4E', 'RPE', 'RPI'}
    'L-arabitol', {'EX_abt(e)', 'ABT_Lt2', 'ABTOXy', 'ARAI', 'RBK_L1', 'RBP4E'}
    'Arabinoxylan', {'EX_arabinoxyl(e)', 'ARABINOXYL_DEGe', 'EX_arab_L(e)', ...
                     'ARBabc', 'EX_gal(e)', 'GALabc', 'EX_xyl_D(e)', 'XYLabc', 'EX_glc_D(e)', ...
                     'GLCabc'}
    'Arbutin', {'EX_arbt(e)','ARBTpts','AB6PGH','AB6PGH2','DM_HQN'}
    'L-arginine', {'EX_arg_L(e)', 'ARGt2r', 'ARGDA', 'OCBT', 'CBMKr', 'ORNTA', ...
                   'G5SADs', 'P5CD'}
    'L-asparagine', {'EX_asn_L(e)', 'ASNt2r'}
    'L-aspartate', {'EX_asp_L(e)', 'ASPt2r' , 'ASPT', 'FUM', 'MDH', 'CS', 'ACONT' 'ICDHy', 'SUCD1', 'SUCD4', 'SUCDi'}
    'beta-Glucan', {'EX_bglc(e)', 'EX_glc_D(e)', 'GLCabc', 'BGLC_DEGe'}
    'Butanol', {'EX_btoh(e)', 'BTOHt2r', 'ALCD4', 'BTALDH', 'PBUTT', 'BUTKr', 'EX_but(e)', 'BUTt2r'}
    'Butyrate', {'EX_but(e)', 'BUTt2', 'BUTCT', 'ACOAD1f', 'ECOAH1', 'HACD1', ...
                 'ACACT1r', 'SUCD1', 'SUCD4'}
    'Cellobiose', {'EX_cellb(e)', 'PGI', 'PFK', 'TPI', ...
                   'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
    'Cellotetrose'  {'EX_cellttr(e)', 'CELLTTR_DEG', 'CELLTTRabc'}
    'Cellulose', {'EX_cellul(e)', 'EX_glc_D(e)', 'CELLUL_DEGe'}
    'Chitin', {'EX_chitin(e)', 'CHITIN_DEGe', 'EX_acgam(e)'}
    'Choline', {'EX_chol(e)', 'CHLt2r', 'EX_tma(e)', 'TMAt2r', 'CHOLTMAL', ...
                'EX_acald(e)', 'ACALDt'}
    'Chondroitin sulfate', {'EX_cspg_a(e)', 'EX_cspg_b(e)', 'EX_cspg_c(e)', ...
                            'EX_cspg_a_degr(e)', 'EX_cspg_b_degr(e)', 'EX_cspg_c_degr(e)', 'EX_cspg_ab_rest(e)', ...
                            'EX_cspg_c_rest(e)', 'EX_acgalglcur(e)', 'EX_acgalidour(e)', 'EX_acgalidour2s(e)', ...
                            'EX_idour(e)', 'EX_so4(e)', 'SO4t2', 'EX_acgal(e)', 'ACGALt2r', 'EX_glcur(e)', ...
                            'GLCURt2r', 'CSABCASE_A_e', 'CSABCASE_B_e', 'CSABCASE_C_e', 'CS4TASE', ...
                            'CS4TASE2', 'CS6TASE', 'GLCAASEe', 'IS2TASE', 'IDOURASE'}
    'cis-Aconitate', {'EX_acon_C(e)', 'ACON_Ct2', 'ACONTa', 'ACONTb'}
    'Citrate', {'EX_cit(e)', 'r1088', 'CITL'}
    'CO2', {'EX_co2(e)', 'CO2t', 'PPCKr'}
    'L-cysteine', {'EX_cys_L(e)', 'CYSt2r', 'EX_h2s(e)', 'H2St', 'CYSDS'}
    'Deoxyribose', {'EX_drib(e)', 'DRIBabc', 'DRBK', 'DRPA'}
    'Dextran', {'EX_dextran40(e)', 'EX_malt(e)', 'MALTabc', 'DEXTRAN40e'}
    'Dextrin', {'EX_dextrin(e)', 'DEXTRINabc', 'DEXTRINASE', 'HEX1'}
    'Erythritol', {'EX_ethrtl(e)', 'ETHRTLabc', 'ETHRTLK', 'ETHRTL1PDH', 'ERYTH1PDE', 'ERYTH1PLE', 'ERYTH4PDE'}
    'Ethanolamine', {'EX_etha(e)', 'ETHAt2', 'ETHAAL'}
    'Fructooligosaccharides', {'EX_kestopt(e)', 'EX_kestottr(e)', 'EX_kesto(e)', ...
                               'EX_glc_D(e)', 'GLCabc', 'EX_fru(e)', 'FRUt2r', 'KESTOASEe', 'KESTOTTRASEe', ...
                               'KESTOPTASEe', 'HEX7', 'PFK', 'TPI', ...
                'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
    'Fructose', {'EX_fru(e)', 'PFK', 'TPI', 'GAPD', ...
                'PGK', 'PGM', 'ENO', 'PYK'}
    'D-Fructuronate'    {'EX_fruur(e)', 'FRUURt2r'}
    'L-fucose', {'EX_fuc_L(e)', 'FUCt2_1', 'FCI', 'FCLK', 'FCLPA', 'LCARS', ...
                 'EX_12ppd_S(e)', '12PPDt'}
    'Fumarate', {'EX_fum(e)', 'FUMt2r'}
    'Galactan', {'EX_galactan(e)', 'GALASE_GALe', 'EX_gal(e)'}
    'Galactomannan', {'EX_galmannan(e)', 'GALMANNAN_DEGe', 'EX_man(e)', 'MANabc', ...
                      'EX_gal(e)', 'GALabc'}
    'Galactosamine', {'EX_galam(e)', 'GALAMt2r', 'HEX11', 'GALAM6PDA', 'PFK_2', 'TGBPA'}
    'Galactose', {'EX_gal(e)', 'GALabc', 'GALK', 'UGLT', 'UDPG4E', 'PGMT', 'PGI', ...
                  'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
    'D-galacturonic acid', {'EX_galur(e)', 'GALURt2r', 'GUI2', 'TAGURr', 'ALTRH', ...
                      'DDGLK', 'EDA'}
    'Glucomannan', {'EX_glcmannan(e)', 'GLCMANNAN_DEGe', 'EX_man(e)', 'MANabc', ...
                    'EX_glc_D(e)', 'GLCabc'}
    'D-gluconate (Entner-Doudoroff pathway)', {'EX_glcn(e)', 'GLCNt2r', 'GLCDe', ...
                                             'GNK', 'EDD', 'EDA'}
    'D-glucosamine', {'EX_gam(e)', 'GAMt2r', 'HEX10', 'G6PDA'}
    'D-glucose', {'EX_glc_D(e)', 'GLCabc', 'HEX1', 'PGI', 'PFK', 'TPI', ...
                'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
    'D-glucuronic acid', {'EX_glcur(e)', 'GLCURt2r', 'GUI1', 'MANAO', 'MNNH', ...
                        'DDGLK', 'EDA'}
    'L-glutamate', {'EX_glu_L(e)', 'GLUt2r', 'ASPTA', 'ASPT', 'FUM', 'MDH', 'CS', 'ACONT' 'ICDHy', 'SUCD1', 'SUCD4', 'SUCDi'}
    'L-glutamine', {'EX_gln_L(e)', 'GLNt2r'}
    'Glycerol', {'EX_glyc(e)', 'GLYCt', 'GLYK', 'G3PD1'}
    'Glycogen', {'EX_glygn2(e)', 'EX_glygn4(e)', 'EX_glygn5(e)', 'EX_malt(e)', ...
                 'MALTabc', 'EX_Tyr_ggn(e)', 'EX_glc_D(e)', 'GLCabc', 'AMY2e', 'O16G1e', ...
                 'GAMYe'}
    'Glycine', {'EX_gly(e)', 'GLYt2r'}
    'Heparin', {'EX_hspg(e)', 'EX_hspg_degr_1(e)', 'EX_hspg_degr_2(e)', 'EX_hspg_degr_3(e)', ...
                'EX_hspg_degr_4(e)', 'EX_hspg_degr_5(e)', 'EX_hspg_degr_6(e)', 'EX_hspg_degr_7(e)', ...
                'EX_hspg_degr_8(e)', 'EX_hspg_degr_9(e)', 'EX_hspg_degr_10(e)', 'EX_hspg_degr_11(e)', ...
                'EX_hspg_degr_12(e)', 'EX_hspg_degr_13(e)', 'EX_hspg_degr_14(e)', 'EX_hspg_degr_15(e)', ...
                'EX_hspg_rest(e)', 'EX_gam26s(e)', 'EX_idour(e)', 'EX_so4(e)', 'SO4t2', ...
                'EX_gal(e)', 'GALabc', 'EX_glcur(e)', 'GLCURt2r', 'EX_gam(e)', 'GAMt2r', ...
                'HEPARL1_e', 'IDOURASE_HS1', 'IDOURASE_HS2', 'IDOURASE_HS3', 'AS3TASE_HS1', ...
                'AS3TASE_HS2', 'AS6TASE_HS1', 'AS6TASE_HS2', 'GAM2STASE_HS1', 'GAM2STASE_HS2', ...
                'GAM2STASE_HS3', 'GLCAASE_HSe', 'GLCNACASE_HS1', 'GLCNACASE_HS2', ...
                'IS2TASE_HS1', 'GALASE_HSe'}
    'L-histidine', {'EX_his_L(e)', 'HISt2r', 'HISD', 'URCN', 'IZPN', 'FGLU', ...
                    'FORAMD'}
    'Homogalacturonan', {'EX_homogal(e)', 'EX_ac(e)', 'ACt2r', 'EX_galur(e)', ...
                         'GALURt2r', 'EX_meoh(e)', 'MEOHt2', 'HOMOGALASEe'}
    'Hyaluronan', {'EX_ha(e)', 'EX_ha_deg1(e)', 'EX_ha_pre1(e)', 'EX_glcur(e)', ...
                   'GLCURt2r', 'EX_acgam(e)', 'ACGAMtr2', 'GLCAASE8e', 'GLCAASE9e', 'NACHEX27e'}
    'L-Idonate', {'EX_idon_L(e)', 'IDONt2r', 'IDOND', '5DGLCNR'}
    'Indole', {'EX_indole(e)', 'INDOLEt2r', 'TRPS1', 'TRPS2', 'TRPS3r'}
    'Inosine', {'EX_ins(e)', 'INSt2i'}
    'Inositol', {'EX_inost(e)', 'INSTt2r', 'INS2D', '2INSD', 'DKDID', 'D5KGK', 'D5KGPA'}
    'Inulin', {'EX_inulin(e)'}  % conditional based on genus (Bacteroides)
    'Isobutyrate', {'EX_isobut(e)', 'ISOBUTt2r', 'FACOALib', 'IBCOAMPO', 'ECOAH12', ...
                    '3HBCOAHL', 'HIBDkt', 'MMTSAO', 'SUCD1', 'SUCD4'}
    'L-isoleucine', {'EX_ile_L(e)', 'ILEt2r', 'ILETA', 'OIVD3', '2MECOAOX', 'ECOAH9', ...
                   'HACD9', 'MACCOAT', 'MCITS', 'MCITD', 'MICITDr', 'MCITL2', 'SUCD1', 'SUCD4'}
    'Isomaltose', {'EX_isomal(e)', 'ISOMALabc', 'ISOMALT'}
    'Isovalerate', {'EX_isoval(e)', 'ISOVALt2r', 'FACOALiv', 'ACOAD8', 'MCCCr', ...
                    'MGCOAH', 'HMGL', 'OCOAT1r', 'ACACT1r', 'SUCD1', 'SUCD4'}
    'D-lactate', {'EX_lac_D(e)', 'D_LACt2i', 'LDH_D', 'PYK'}
    'L-lactate', {'EX_lac_L(e)', 'L_LACt2', 'LDH_L', 'PYK'}
    'Lactose', {'EX_lcts(e)', 'GALK', 'UGLT', 'UDPG4E', 'PGMT', ...
                'HEX1', 'PGI', 'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
    'Laminarin', {'EX_lmn30(e)', 'EX_lmn2(e)', 'EX_glc_D(e)', 'GLCabc', 'LMNe', ...
                  'LMN2e'}
    'Lichenin', {'EX_lichn(e)', 'LICHN_DEGe', 'EX_glc_D(e)', 'GLCabc'}
    'L-leucine', {'EX_leu_L(e)', 'LEUt2r', 'LEUTA', 'OIVD1r', 'ACOAD8', 'MCCCr', ...
                  'MGCOAH', 'HMGL', 'OCOAT1r', 'ACACT1r', 'SUCD1', 'SUCD4'}
    'Levan', {'EX_levan1000(e)', 'EX_levanb(e)', 'LEVANB_ABC', 'EX_levanttr(e)', ...
              'EX_levantttr(e)', 'EX_fru(e)', 'FRUt2r', 'LEVANASE_1e', 'LEVANASE_2e', ...
              'LEVANASE_3e', 'LEVANASE_4e', 'FRUASE1'}
    'L-lysine', {'EX_lys_L(e)', 'LYSt2r', 'EX_15dap(e)', '15DAPt', 'LYSDC', ...
                 'DAPAT', 'PPRDNDH', 'APTNAT', 'OXPTNDH', 'GLCOAS', 'GLUTCOADH2', 'ECOAH1', ...
                 'HACD1', 'ACACT1r', 'SUCD1', 'SUCD4'}
    'L-lyxose', {'EX_lyx_L(e)', 'LYXabc', 'EX_gcald(e)', 'GCALDt', 'LYXI', ...
                 'RMK2', 'RMPA2'}
    'L-malate', {'EX_mal_L(e)', 'MALt2r'}
    'D-maltose', {'EX_malt(e)', 'MALTabc', 'PGI', 'PFK', 'TPI', ...
                'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
    'Mannitol', {'EX_mnl(e)'}
    'Mannose', {'EX_man(e)', 'MANabc', 'HEX4', 'MAN6PI'}
    'Melibiose', {'EX_melib(e)', 'MELIBabc', 'GALS3', 'GALK', 'UGLT', 'UDPG4E', ...
                  'HEX1', 'PGI', 'PFK', 'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
    'L-methionine', {'EX_met_L(e)', 'METt2r', 'EX_ch4s(e)', 'CH4St', 'METGL', ...
                     'OBDHc'}
    'Mucin', {'EX_T_antigen(e)', 'EX_Tn_antigen(e)', 'EX_core2(e)', 'EX_core3(e)', ...
              'EX_core4(e)', 'EX_core5(e)', 'EX_core6(e)', 'EX_core7(e)', 'EX_core8(e)', ...
              'EX_dsT_antigen(e)', 'EX_dsT_antigen(e)', 'EX_f1a(e)', 'EX_gncore1(e)', ...
              'EX_gncore2(e)', 'EX_sT_antigen(e)', 'EX_sTn_antigen(e)', 'EX_Ser_Thr(e)', ...
              'EX_gal(e)', 'GALabc', 'EX_acgal(e)', 'ACGALt2r', 'EX_acgam(e)', 'ACGAMtr2', ...
              'EX_acnam(e)', 'ACNAMabc', 'GALASE_OGLYCAN1e', 'GALASE_OGLYCAN2e', ...
              'GALASE_OGLYCAN3e', 'GALNACASE_OGLYCAN1e', 'GALNACASE_OGLYCAN2e', ...
              'GALNACASE_OGLYCAN3e', 'GLCNACASE_OGLYCAN1e', 'GLCNACASE_OGLYCAN2e', ...
              'GLCNACASE_OGLYCAN3e', 'GLCNACASE_OGLYCAN4e', 'GLCNACASE_OGLYCAN5e', ...
              'GLCNACASE_OGLYCAN6e', 'SIAASE_OGLYCAN1e', 'SIAASE_OGLYCAN2e', 'SIAASE_OGLYCAN3e'}
    'N-acetylgalactosamine', {'EX_acgal(e)', 'ACGALt2r', 'ACGALK3', 'AGDC2', ...
                              'GALAM6PDA', 'PFK_2', 'TGBPA'}
    'N-acetylglucosamine', {'EX_acgam(e)', 'ACGAMtr2', 'ACGAMK', 'AGDC', 'G6PDA'}
    'N-acetylmannosamine', {'EX_acmana(e)', 'ACMANAtr'}
    'N-acetylneuraminic acid', {'EX_acnam(e)', 'ACNAMabc', 'ACNML', 'AMANK', ...
                            'AMANAPEr', 'AGDC', 'G6PDA'}
    'L-ornithine', {'EX_orn(e)', 'ORNt2r', 'EX_ptrc(e)', 'PTRCt2r', 'ORNDC'}
    'Orotate', {'EX_orot(e)', 'OROte'}
    'Oxalate', {'EX_for(e)', 'FORt2r', 'EX_oxa(e)', 'FOROXAtex', 'FORMCOAT', ...
                'OXCOADC', 'ATPS3'}
    'Oxaloacetate', {'EX_oaa(e)', 'OAAt2r'}
    'Pectic galactan', {'EX_pecticgal(e)', 'EX_arab_L(e)', 'ARBabc', 'EX_gal(e)', ...
                        'GALabc', 'EX_rmn(e)', 'RMNt2', 'EX_ac(e)', 'ACtr', 'EX_galur(e)', ...
                        'GALURt2r', 'EX_meoh(e)', 'MEOHt2', 'PECTICGALASEe'}
    'Pectin', {'EX_pect(e)', 'EX_galur(e)', 'GALURt2r', 'EX_meoh(e)', 'MEOHt2', ...
               'PECTIN_DEGe'}
    'Phenylacetate', {'EX_pac(e)', 'PACt2r', 'PACCOAL', 'PHACOAO', 'HBCD', ...
                      '3OXCOAT', 'KACOAT2'}
    'L-phenylalanine', {'EX_phe_L(e)', 'PHEt2r', 'PHETA1', 'EX_phpyr(e)', 'PHPYRt2r'}
    'L-proline', {'EX_pro_L(e)', 'PROt2r', 'PROD2', 'PROD3', 'P5CD', 'SUCD1', 'SUCD4'}
    'Propionate', {'EX_ppa(e)', 'PPAt2r', 'EX_succ(e)', 'SUCCt2r', 'ACCOAL', ...
                   'MCITS', 'MCITD', 'MICITD', 'MCITL2'}
    'D-Psicose', {'EX_psics_D(e)', 'PSICSabc', 'PSICSE'}
    'Pullulan', {'EX_pullulan1200(e)', 'PULLe', 'EX_malttr(e)', 'MALTTRabc', ...
                 'MLTG1'}
    'Pyruvate', {'EX_pyr(e)', 'PYRt2r'}
    'Raffinose', {'EX_raffin(e)', 'RAFFabc', 'GALK', 'UGLT', 'PGMT', 'UDPG4E', ...
                  'SUCR', 'HEX7', 'HEX1', 'PGI', 'PFK', 'TPI', 'GAPD', 'PGK', ...
                  'PGM', 'ENO', 'PYK'}
    'Resistant starch', {'EX_starch1200(e)', 'EX_glc_D(e)', 'GLCabc', 'EX_malt(e)', ...
                         'MALTabc', 'EX_malttr(e)', 'MALTTRabc', 'AMYe'}
    'Rhamnogalacturonan I', {'EX_rhamnogalurI(e)', 'EX_arab_L(e)', 'ARBabc', ...
                             'EX_gal(e)', 'GALabc', 'EX_rmn(e)', 'RMNt2', 'EX_galur(e)', 'GALURt2r', ...
                             'EX_xyl_D(e)', 'XYLabc', 'RHAMNOGALURASEe_I'}
    'Rhamnogalacturonan II', {'EX_rhamnogalurII(e)', 'EX_arab_L(e)', 'ARBabc', ...
                              'EX_gal(e)', 'GALabc', 'EX_rmn(e)', 'RMNt2', 'EX_galur(e)', 'GALURt2r', ...
                              'EX_fuc_L(e)', 'FUCt2_1', 'EX_glcur(e)', 'GLCURt2r', 'EX_2omfuc(e)', ...
                              'EX_2omxyl(e)', 'EX_apio-D(e)', 'EX_acerA(e)', 'EX_kdo(e)', 'EX_3ddlhept(e)', ...
                              'RHAMNOGALURASEe_II'}
    'L-rhamnose', {'EX_rmn(e)', 'RMNt2', 'EX_12ppd_S(e)', '12PPDt', 'RMI', ...
                   'RMK', 'RMPA', 'LCARS'}
    'D-ribose', {'EX_rib_D(e)', 'RIBabc', 'RBK'}
    'Salicin', {'EX_salcn(e)', 'SALCpts', '6PHBG', 'DM_2HYMEPH'}
    'L-serine', {'EX_ser_L(e)', 'SERt2r', 'r0060'}
    'D-Sorbitol', {'EX_sbt_D(e)', 'SBTt6', 'SBTD_D2'}
    'L-Sorbose', {'EX_srb_L(e)', 'SRB_Labc', 'SBTOR', 'SBTD_D2'}
    'Stachyose', {'EX_stys(e)', 'STYSabc', 'STYSGH', 'GALS3'}
    'Starch', {'EX_strch1(e)', 'EX_strch2(e)', 'EX_glc_D(e)', 'GLCabc', 'EX_malt(e)', ...
               'MALTabc', 'AMY1e', 'O16G2e'}
    'Stickland reaction', {'EX_pro_L(e)', 'PROt2r', 'EX_gly(e)', 'GLYt2r', ...
                           'EX_ala_L(e)', 'ALAt2r', 'EX_ile_L(e)', 'ILEt2r', 'EX_leu_L(e)' 'LEUt2r', ...
                           'EX_tyr_L(e)', 'TYRt2r', 'EX_trp_L(e)', 'TRPt2r', 'EX_val_L(e)', 'VALt2r', ...
                           'EX_glyb(e)', 'GLYBt2r', 'EX_tma(e)', 'TMAt2r', 'EX_2mbut(e)', '2MBUTt2r', ...
                           'EX_isoval(e)', 'ISOVALt2r', 'EX_isobut(e)', 'ISOBUTt2r', 'EX_pac(e)', ...
                           'PACt2r', 'EX_pppn(e)', 'PPPNt2r', 'EX_5aptn(e)', '5APTNt2r', 'EX_ind3ppa(e)', ...
                           'IND3PPAt2r', 'PROLR', 'ALAD_L', 'PDHa', 'PDHbr', 'PDHc', 'PHETA1', ...
                           'IOR2', 'PACCOALr', 'PLACOR', 'PLACD', 'CINNMR', 'TRPDA_H', 'LEUTA', ...
                           'VALTA', 'ILETA', 'GLYR', 'PRO_DR', 'LEU_ST', 'VAL_ST', 'ILE_ST', 'GLYB_R'}
    'Succinate', {'EX_succ(e)', 'SUCCt2r'}
    'Sucrose', {'EX_sucr(e)', 'HEX7', 'PGI', 'PFK', ...
                'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
    'D-Tagatose', {'EX_tagat_D(e)', 'TAGATabc', 'KHK3', 'FBA5'}
    'D-Tagaturonate', {'EX_tagur(e)', 'TAGURabc', 'TAGURr', 'ALTRH', 'DDGLK', 'EDA'}
    'Trehalose', {'EX_tre(e)', 'HEX1', 'PGI', 'PFK', ...
                  'TPI', 'GAPD', 'PGK', 'PGM', 'ENO', 'PYK'}
    'L-threonine', {'EX_thr_L(e)', 'THRt2r', 'THRD_L', 'OBDHc', 'PTA2', 'PPAKr', ...
                    'EX_ppa(e)', 'PPAt2r'}
    'L-tryptophan', {'EX_trp_L(e)', 'TRPt2r', 'TRPAS2', 'EX_indole(e)', 'INDOLEt2r'}
    'D-Turanose', {'EX_turan_D(e)', 'TURANabc', 'TURAN_DEG', 'HEX1'}
    'L-tyrosine', {'EX_tyr_L(e)', 'TYRt2r', 'TYRTA', 'IOR3', 'PACCOAL2r', 'EX_4hphac(e)', ...
                   'HPACt2r'}
    'L-valine', {'EX_val_L(e)', 'VALt2r', 'VALTA', 'OIVD2', 'ACOADH2', 'ECOAH12', ...
                 '3HBCOAHL', 'HIBDkt', 'MMTSAO'}
    'Urea', {'EX_urea(e)', 'EX_urea(e)', 'UREAt', 'UREA'}
    'Xylan', {'EX_xylan(e)', 'EX_xyl_D(e)', 'XYLabc', 'XYLAN_DEGe'}
    'Xylitol', {'EX_xylt(e)', 'XYLTabc', 'XYLTD_Dr'}
    'Xyloglucan', {'EX_xyluglc(e)', 'EX_xyl_D(e)', 'XYLabc', 'EX_fuc_L(e)', 'FUCt2_1', ...
                   'EX_arab_L(e)', 'ARBabc', 'EX_gal(e)', 'GALabc', 'EX_glc_D(e)', 'GLCabc', ...
                   'XYLUGLC_DEGe'}
    'Xylooligosaccharides', {'EX_xylottr(e)', 'XYLOTTRabc', 'XYLOTTR_DEG', 'XYLI1', 'XYLK'}
    'D-xylose', {'EX_xyl_D(e)', 'XYLabc', 'XYLI1', 'XYLK'}
};

carbGapfillAddConditional = {
    % c-source, condition, add reaction(s)
    '2-oxobutyrate', 'any(ismember(model.rxns, ''ACHBPL'')) && ~any(ismember(model.rxns, {''OBTFL'', ''OBDHc''}))', {'KARA2', 'DHAD2'}
    'Cellobiose', 'any(ismember(model.rxns, ''CELBpts''))', {'BGLA1', 'HEX1'}
    'Cellobiose', '~any(ismember(model.rxns, ''CELBpts''))', {'BGLA','CELLBabc', 'HEX1'}
    'Fructose', 'any(ismember(model.rxns, ''FRUpts''))', {'FBA2'}
    'Fructose', '~any(ismember(model.rxns, ''FRUpts''))', {'FRUt2r', 'HEX7'}
    'Glycerol', 'isempty(intersect(model.rxns, {''FRD7'', ''N2Ormq'', ''N2OO'', ''CYTBD'', ''SUCD4'', ''NOr1mq'', ''NO3rPuq''}))', {'DM_q8h2[c]'}
    'Inositol', 'isempty(intersect(model.rxns, {''MMSAD3'', ''AMAMTi'', ''APATr'', ''MMSAD5'', ''3HPPD'', ''MMSAD4i''}))', {'MMSAD3'}
    'Inulin', 'strncmp(''Bacteroides'', microbeID, 11)', {'EX_kestopt(e)', 'EX_glc_D(e)', 'EX_fru(e)', 'FRUt2r', 'INULINASEe', 'KESTOPTASEe'}
    'Inulin', '~strncmp(''Bacteroides'', microbeID, 11)', {'INULINabc', 'INULINASE'}
    'Inulin', 'any(ismember(model.rxns, ''HEX1''))', {'HEX7'}
    'Inulin', '~any(ismember(model.rxns, ''HEX1''))', {'KHK'}
    'Lactose', 'any(ismember(model.rxns, ''LACpts''))', {'6PGALSZ', 'GAL6PI', 'PFK_2', 'TGBPA'}
    'Lactose', '~any(ismember(model.rxns, ''LACpts''))', {'LACZ','LCTSabc'}
    'D-maltose', 'any(ismember(model.rxns, ''MALTpts''))', {'MALT6PH', 'HEX1'}
    'D-maltose', '~any(ismember(model.rxns, ''MALTpts''))', {'MALT','MALTabc', 'HEX1'}
    'Mannitol', 'any(ismember(model.rxns, ''MNLpts''))', {'M1PD'}
    'Mannitol', '~any(ismember(model.rxns, ''MNLpts''))', {'MANAD_D', 'MNLt6', 'HEX7'}
    'Raffinose', '~any(ismember(model.rxns, ''RAFH''))', {'RAFGH'}
    'Raffinose', 'any(ismember(model.rxns, ''RAFH''))', {'GALS3'}
    'Stachyose', 'any(ismember(model.rxns, ''GALS3''))', {'RAFH'}
    'Stachyose', 'any(ismember(model.rxns, ''GALT''))', {'GALK'}
    'Succinate', '~any(ismember(model.rxns, {''N2OO'', ''CYTBD'', ''NO3rPuq''}))', {'DM_q8h2[c]', 'EX_q8(e)', 'Q8abc'}
    'Sucrose', '~any(ismember(model.rxns, ''SUCpts''))', {'SUCR', 'SUCRt2', 'HEX1'}
    'Sucrose', 'any(ismember(model.rxns, ''SUCpts''))', {'FFSD'}
    'Trehalose', '~any(ismember(model.rxns, ''TREpts''))', {'TREH', 'TREabc'}
    'Trehalose', 'any(ismember(model.rxns, ''TREpts'')) && ~any(ismember(model.rxns, {''TRE6PPGT'', ''TRE6PP''}))', {'TRE6PH'}
    'Trehalose', 'any(ismember(model.rxns, ''TREpts'')) && any(ismember(model.rxns, ''TRE6PPGT''))', {'PGMT'}
    'Trehalose', 'any(ismember(model.rxns, ''TREpts'')) && ~any(ismember(model.rxns, ''TRE6PPGT''))  && any(ismember(model.rxns, ''TRE6PP''))', {'TREH'}
    'D-Turanose', 'any(ismember(model.rxns, ''HEX1'')) && ~any(ismember(model.rxns, ''FRUt2r''))', {'HEX7'}
    'Xylitol', 'any(ismember(model.rxns, ''TKT2''))', {'XYLK'}
    'Xylitol', 'any(ismember(model.rxns, ''KHK2''))', {'FBA4'}
    };

carbGapfillRemove = {
    'Butyrate', {'BUTCTr','BUTt2r'}
    'CO2', {'PPCK'}
    'Oxalate', {'ATPS4'}
    'Stickland reaction', {'PACCOAL'}
};

%%
% go through carbon sources
for i = 1:length(cSources)
    fprintf('Refining carbon source "%s" for %s.\n', cSources{i}, microbeID)

    % start by removing reactions if needed
    if any(ismember(carbGapfillRemove(:, 1), cSources{i}))
        remRxns = carbGapfillRemove{find(ismember(carbGapfillRemove(:, 1), cSources{i})), 2};
        model = removeRxns(model, remRxns);
        removedRxns{length(removedRxns)+1,1} = remRxns;
    end

    % add pathway reactions
    addRxns = carbGapfillAdd{find(ismember(carbGapfillAdd(:, 1), cSources{i})), 2};
    for j = 1:length(addRxns)
        if ~any(ismember(model.rxns, addRxns{j}))
            formula = database.reactions{ismember(database.reactions(:, 1), addRxns{j}), 3};
            model = addReaction(model, addRxns{j}, 'reactionFormula', formula, 'geneRule', 'CarbonSourceGapfill');
            addedRxns{length(addedRxns)+1,1} = addRxns{j};
        end
    end
  
    % add conditional reactions
    if any(ismember(carbGapfillAddConditional(:, 1), cSources{i}))
        conditions = find(ismember(carbGapfillAddConditional(:, 1), cSources{i}));
        for k = 1:length(conditions)
            if eval(carbGapfillAddConditional{conditions(k), 2})
                addRxns = carbGapfillAddConditional{conditions(k), 3};
                for j = 1:length(addRxns)
                    if ~any(ismember(model.rxns, addRxns{j}))
                        formula = database.reactions{ismember(database.reactions(:, 1), addRxns{j}), 3};
                        model = addReaction(model, addRxns{j}, 'reactionFormula', formula, 'geneRule', 'CarbonSourceGapfill');
                        addedRxns{length(addedRxns)+1,1} = addRxns{j};
                    end
                end
            end
        end
    end
end

% The following reactions are always added given the corresponding
% conditions:

condRxns={
    {'MCITS'},{'EX_ppa(e)','PPAt2r'}
    {'ARABASE3e'},{'EX_arab_L(e)','EX_arabttr(e)'}
    };
for i=size(condRxns,1)
    if length(intersect(model.rxns, condRxns{i,1})) == length(condRxns{i,1})
        for j=1:length(condRxns{i,2})
        formula = database.reactions{ismember(database.reactions(:, 1), condRxns{i,2}{j}), 3};
        model = addReaction(model, condRxns{i,2}{j}, 'reactionFormula', formula, 'geneRule', 'CarbonSourceGapfill');
        addedRxns{length(addedRxns)+1,1} = condRxns{i,2}{j};
        end
    end
end

end
