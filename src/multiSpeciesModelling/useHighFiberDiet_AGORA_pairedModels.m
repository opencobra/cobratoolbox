function [modelOut] = useHighFiberDiet_AGORA_pairedModels(modelIn)
% assigns a high fiber diet for the 773 AGORA microbes
% Please cite "Magnusdottir, Heinken et al., Nat Biotechnol. 2017 35(1):81-89"
% if you use this script for your own analysis.
% Almut Heinken 16.03.2017

model = modelIn;
model = changeRxnBounds(model, model.rxns(strmatch('EX_', model.rxns)), 0, 'l');

DietConstraints = {
    % simple sugars and starch
    'EX_fru[u]'	, -0.03947;
    'EX_glc_D[u]'	, -0.03947;
    'EX_gal[u]'	, -0.03947;
    'EX_man[u]'	, -0.03947;
    'EX_mnl[u]'	, -0.03947;
    'EX_fuc_L[u]'	, -0.03947;
    'EX_glcn[u]'	, -0.03947;
    'EX_rmn[u]'	, -0.03947;
    'EX_arab_L[u]'	, -0.04737;
    'EX_drib[u]'	, -0.04737;
    'EX_rib_D[u]'	, -0.04737;
    'EX_xyl_D[u]'	, -0.04737;
    'EX_oxa[u]'	, -0.11842;
    'EX_lcts[u]'	, -0.01974;
    'EX_malt[u]'	, -0.01974;
    'EX_sucr[u]'	, -0.01974;
    'EX_melib[u]'	, -0.01974;
    'EX_cellb[u]'	, -0.01974;
    'EX_tre[u]'	, -0.01974;
    'EX_strch1[u]'	, -0.06818;
    % fiber
    'EX_amylopect900[u]'	, -0.0003472222;
    'EX_amylose300[u]'	, -0.0010416667;
    'EX_arabinan101[u]'	, -0.0036836935;
    'EX_arabinogal[u]'	, -0.0004854997;
    'EX_arabinoxyl[u]'	, -0.0067934783;
    'EX_bglc[u]'	, -0.0000015625;
    'EX_cellul[u]'	, -0.000625;
    'EX_dextran40[u]'	, -0.00390625;
    'EX_galmannan[u]'	, -0.0003125;
    'EX_glcmannan[u]'	, -0.0007284382;
    'EX_homogal[u]'	, -0.0028409091;
    'EX_inulin[u]'	, -0.0104166667;
    'EX_kestopt[u]'	, -0.0625;
    'EX_levan1000[u]'	, -0.0003125;
    'EX_lmn30[u]'	, -0.0104166667;
    'EX_lichn[u]'	, -0.0018382353;
    'EX_pect[u]'	, -0.000739645;
    'EX_pullulan1200[u]'	, -0.0002604167;
    'EX_raffin[u]'	, -0.1041666667;
    'EX_rhamnogalurI[u]'	, -0.0003210616;
    'EX_rhamnogalurII[u]'	, -0.0059148265;
    'EX_starch1200[u]'	, -0.0002604167;
    'EX_xylan[u]'	, -0.0007102273;
    'EX_xyluglc[u]'	, -0.0002912395;
    % fat
    'EX_arachd[u]'	, -0.001664;
    'EX_chsterol[u]'	, -0.002479;
    'EX_glyc[u]'	, -0.899827;
    'EX_hdca[u]'	, -0.198185;
    'EX_hdcea[u]'	, -0.018258;
    'EX_lnlc[u]'	, -0.179555;
    'EX_lnlnca[u]'	, -0.008783;
    'EX_lnlncg[u]'	, -0.008783;
    'EX_ocdca[u]'	, -0.084641;
    'EX_ocdcea[u]'	, -0.340722;
    'EX_octa[u]'	, -0.006471;
    'EX_ttdca[u]'	, -0.034338;
    % protein
    'EX_ala_L[u]'	, -1;
    'EX_cys_L[u]'	, -1;
    'EX_ser_L[u]'	, -1;
    'EX_arg_L[u]'	, -0.15;
    'EX_his_L[u]'	, -0.15;
    'EX_ile_L[u]'	, -0.15;
    'EX_leu_L[u]'	, -0.15;
    'EX_lys_L[u]'	, -0.15;
    'EX_asn_L[u]'	, -0.225;
    'EX_asp_L[u]'	, -0.225;
    'EX_thr_L[u]'	, -0.225;
    'EX_glu_L[u]'	, -0.18;
    'EX_met_L[u]'	, -0.18;
    'EX_gln_L[u]'	, -0.18;
    'EX_pro_L[u]'	, -0.18;
    'EX_val_L[u]'	, -0.18;
    'EX_phe_L[u]'	, -1;
    'EX_tyr_L[u]'	, -1;
    'EX_gly[u]'	, -0.45;
    'EX_trp_L[u]'	, -0.08182;
    % minerals, vitamins, cofactors, other
    'EX_12dgr180[u]'	, -1;
    'EX_26dap_M[u]'	, -1;
    'EX_2dmmq8[u]'	, -1;
    'EX_2obut[u]'	, -1;
    'EX_3mop[u]'	, -1;
    'EX_4abz[u]'	, -1;
    'EX_4hbz[u]'	, -1;
    'EX_5aop[u]'	, -1;
    'EX_ac[u]'	, -1;
    'EX_acald[u]'	, -1;
    'EX_acgam[u]'	, -1;
    'EX_acmana[u]'	, -1;
    'EX_acnam[u]'	, -1;
    'EX_ade[u]'	, -1;
    'EX_adn[u]'	, -1;
    'EX_adocbl[u]'	, -1;
    'EX_akg[u]'	, -1;
    'EX_ala_D[u]'	, -1;
    'EX_amet[u]'	, -1;
    'EX_amp[u]'	, -1;
    'EX_anth[u]'	, -1;
    'EX_arab_D[u]'	, -1;
    'EX_avite1[u]'	, -1;
    'EX_btn[u]'	, -1;
    'EX_ca2[u]'	, -1;
    'EX_cbl1[u]'	, -1;
    'EX_cgly[u]'	, -1;
    'EX_chol[u]'	, -1;
    'EX_chor[u]'	, -1;
    'EX_cit[u]'	, -1;
    'EX_cl[u]'	, -1;
    'EX_cobalt2[u]'	, -1;
    'EX_csn[u]'	, -1;
    'EX_cu2[u]'	, -1;
    'EX_cytd[u]'	, -1;
    'EX_dad_2[u]'	, -1;
    'EX_dcyt[u]'	, -1;
    'EX_ddca[u]'	, -1;
    'EX_dgsn[u]'	, -1;
    'EX_etoh[u]'	, -1;
    'EX_fald[u]'	, -1;
    'EX_fe2[u]'	, -1;
    'EX_fe3[u]'	, -1;
    'EX_fe3dcit[u]'	, -1;
    'EX_fol[u]'	, -1;
    'EX_for[u]'	, -1;
    'EX_fum[u]'	, -1;
    'EX_gam[u]'	, -1;
    'EX_glu_D[u]'	, -1;
    'EX_glyc3p[u]'	, -1;
    'EX_glyleu[u]'	, -2;
    'EX_gsn[u]'	, -1;
    'EX_gthox[u]'	, -1;
    'EX_gthrd[u]'	, -1;
    'EX_gua[u]'	, -1;
    'EX_h[u]'	, -1;
    'EX_h2[u]'	, -1;
    'EX_h2s[u]'	, -1;
    'EX_hom_L[u]'	, -1;
    'EX_hxan[u]'	, -1;
    'EX_indole[u]'	, -1;
    'EX_ins[u]'	, -1;
    'EX_k[u]'	, -1;
    'EX_lac_L[u]'	, -1;
    'EX_lanost[u]'	, -1;
    'EX_mal_L[u]'	, -1;
    'EX_metsox_S_L[u]' , -1;
    'EX_mg2[u]'	, -1;
    'EX_mn2[u]'	, -1;
    'EX_mobd[u]'	, -1;
    'EX_mqn7[u]'	, -1;
    'EX_mqn8[u]'	, -1;
    'EX_na1[u]'	, -1;
    'EX_nac[u]'	, -1;
    'EX_ncam[u]'	, -1;
    'EX_nmn[u]'	, -1;
    'EX_no2[u]'	, -1;
    'EX_no2[u]'	, -1;
    'EX_no3[u]'	, -1;
    'EX_orn[u]'	, -1;
    'EX_pheme[u]'	, -1;
    'EX_phyQ[u]'	, -1;
    'EX_pi[u]'	, -1;
    'EX_pime[u]'	, -1;
    'EX_pnto_R[u]'	, -1;
    'EX_ptrc[u]'	, -1;
    'EX_pydam[u]'	, -1;
    'EX_pydx[u]'	, -1;
    'EX_pydx5p[u]'	, -1;
    'EX_pydxn[u]'	, -1;
    'EX_q8[u]'	, -1;
    'EX_retinol[u]'	, -1;
    'EX_ribflv[u]'	, -1;
    'EX_sel[u]'	, -1;
    'EX_sheme[u]'	, -1;
    'EX_so4[u]'	, -1;
    'EX_spmd[u]'	, -1;
    'EX_succ[u]'	, -1;
    'EX_thf[u]'	, -1;
    'EX_thm[u]'	, -1;
    'EX_thymd[u]'	, -1;
    'EX_ura[u]'	, -1;
    'EX_uri[u]'	, -1;
    'EX_vitd3[u]'	, -1;
    'EX_xan[u]'	, -1;
    'EX_zn2[u]'	, -1;
    % only for methanogens
    'EX_meoh[u]'	, -10;
    % other compounds
    'EX_h2o[u]'	, -10;
};

for i = 1:length(DietConstraints)
    model = changeRxnBounds(model, DietConstraints{i, 1}, DietConstraints{i, 2}, 'l');
end

modelOut = model;

end
