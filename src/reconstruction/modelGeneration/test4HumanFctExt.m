function [TestSolution,TestSolutionName,TestedRxns,PercTestedRxns] = test4HumanFctExt(model,test,optionSinks)
% test for the ~288 human functions
%
% USAGE:
%     [TestSolution,TestSolutionName,TestedRxns,PercTestedRxns] = test4HumanFctExt(model,test,optionSinks)
%
% INPUT:
%    model:             model structure (Recon1, with desired in silico condition)
%    test:              possible statements: Recon1, IECori, IEC, all (default)
%                       (choose IECori if you intend to test the IEC model OR a model that
%                       contains lumen ('u') as compartment otw choose IEC);
%                       all check for Recon1 and IEC
%    option:            if true = set sink reactions to 0 (default, leave unchanged).
%                       Note that all lb's of exchanges and demands will be set to 0
%
% OUTPUT:
%    TestSolution:      array containing the optimal value for the different tests
%    TestSolutionName:  array containing the names  for the different tests
%
% .. Authors:
%       - Ines Thiele, 09/05/09
%       - MKA, 03/04/12 some of the reaction names have changed in newer versions of Recon1
%         and Recon2. Comment setup til line 146 if using an old version.
%       - MKA, 24/05/12 finds correct EX_reactions and changes these to zero
%       - IT, 07/20/12 added tests for sIEC model
%       - AH, 07/12/17 minor changes to constraints that were resulting in infeasible models
%       - Uri David Akavia, 15-Jul-2018 rewrote the function to minimize
%         warnings and hopefully speedup

if nargin<2
    test = 'all';
end
if nargin<3
    optionSinks = 0; % do not close
end

model = findSExRxnInd(model);

if optionSinks
    % close sink reactions
    model.lb(model.SinkRxnBool)=0;
end

TestSolution = [];
%%
% S ='';
%  S = warning('QUERY','VERBOSE');
%% Setup

% for organ atlas derived from Harvey only
if strcmp(test,'Harvey')
    model.rxns = regexprep(model.rxns,'\[bc\]','\(e\)');
end

diary('Test4Functions_diary.txt');
TestedRxns =[];
tol = 1e-6;
% fixes the model met names in cases the compartments are not given with ()
model.mets = regexprep(model.mets,'[','(');
model.mets = regexprep(model.mets,']',')');
model.mets = regexprep(model.mets,'_','-');
model.mets = regexprep(model.mets,'-FSLASH-','/');

model.rxns = regexprep(model.rxns,'\[','\(');
model.rxns = regexprep(model.rxns,'\]','\)');

% replace reaction names
new = {'DM_atp_c_'
    'EX_gln_L(e)'
    'EX_glu_L(e)'
    'EX_lac_L(e)'
    'EX_pro_L(e)'
    'EX_cys_L(e)'
    'EX_lys_L(e)'
    'EX_arg_L(e)'
    'EX_his_L(e)'
    'EX_glc_D(e)'
    'CYOR_u10m'
    'NADH2_u10m'
    'EX_4hpro(e)'
    % due to innermitochondrial membrane representation in recon3
    'ASPGLUmi'
    'ATPS4mi'
    'CYOR_u10mi'
    'Htmi'
    'NADH2_u10mi'
    'CYOOm3i'
    'CYOOm2i'};

original = {'DM_atp(c)'
    'EX_gln-L(e)'
    'EX_glu-L(e)'
    'EX_lac-L(e)'
    'EX_pro-L(e)'
    'EX_cys-L(e)'
    'EX_lys-L(e)'
    'EX_arg-L(e)'
    'EX_his-L(e)'
    'EX_glc(e)'
    'CYOR-u10m'
    'NADH2-u10m'
    'EX_4HPRO'
    'ASPGLUm'
    'ATPS4m'
    'CYOR-u10m'
    'Htm'
    'NADH2-u10m'
    'CYOOm3'
    'CYOOm2'};

for i=1:length(new)
    A = ismember(model.rxns,new(i,1));
    model.rxns(A,1)= original(i,1);
end

%replace metabolite names

new_mets = {'Ser-Gly-Ala-X-Gly(r)'
    'Ser-Thr(g)'
    'Ser-Thr(l)'
    'ksii-core2(g)'
    'ksii-core4(g)'
    'ksii-core2(l)'
    'ksii-core4(l)'
    'cspg-a(l)'
    'cspg-b(l)'
    'cspg-c(l)'
    'cspg-d(l)'
    'cspg-e(l)'
    'cspg-a(g)'
    'cspg-b(g)'
    'cspg-c(g)'
    'cspg-d(g)'
    'cspg-e(g)'
    'galgluside-hs(g)'
    'gluside-hs(g)'
    'galgalgalthcrm-hs(g)'
    'acgagbside-hs(g)'
    'acnacngalgbside-hs(g)'
    'gd1b2-hs(g)'
    'gd1c-hs(g)'
    'gq1balpha-hs(g)'
    'dag-hs(c)'
    'pe-hs(c)'
    'tag-hs(c)'
    'cs-pre(g)'
    'crmp-hs(c)'
    'sphmyln-hs(c)'
    'pail-hs(c)'
    'pail45p-hs(c)'
    'pail4p-hs(c)'
    'dolichol-L(c)'
    'dolmanp-L(r)'
    'dolichol-U(c)'
    'dolmanp-U(r)'
    'dolichol-L(r)'
    'dolichol-U(r)'
    'gpi-prot-hs(r)'
    'g3m8mpdol-L(r)'
    'g3m8mpdol-U(r)'
    'gp1c-hs(g)'
    'dsTn-antigen(g)'
    'sTn-antigen(g)'
    'Tn-antigen(g)'
    };
original_mets = {'Ser-Gly/Ala-X-Gly(r)'
    'Ser/Thr(g)'
    'Ser/Thr(l)'
    'ksii_core2(g)'
    'ksii_core4(g)'
    'ksii_core2(l)'
    'ksii_core4(l)'
    'cspg_a(l)'
    'cspg_b(l)'
    'cspg_c(l)'
    'cspg_d(l)'
    'cspg_e(l)'
    'cspg_a(g)'
    'cspg_b(g)'
    'cspg_c(g)'
    'cspg_d(g)'
    'cspg_e(g)'
    'galgluside_hs(g)'
    'gluside_hs(g)'
    'galgalgalthcrm_hs(g)'
    'acgagbside_hs(g)'
    'acnacngalgbside_hs(g)'
    'gd1b2_hs(g)'
    'gd1c_hs(g)'
    'gq1balpha_hs(g)'
    'dag_hs(c)'
    'pe_hs(c)'
    'tag_hs(c)'
    'cs_pre(g)'
    'crmp_hs(c)'
    'sphmyln_hs(c)'
    'pail_hs(c)'
    'pail45p_hs(c)'
    'pail4p_hs(c)'
    'dolichol_L(c)'
    'dolmanp_L(r)'
    'dolichol_U(c)'
    'dolmanp_U(r)'
    'dolichol_L(r)'
    'dolichol_U(r)'
    'gpi_prot_hs(r)'
    'g3m8mpdol_L(r)'
    'g3m8mpdol_U(r)'
    'gp1c_hs(g)'
    'dsTn_antigen(g)'
    'sTn_antigen(g)'
    'Tn_antigen(g)'
    };
for i=1:length(new_mets)
    met = new_mets(i,1);
    A = ismember(model.mets,met);
    model.mets(A,1)= original_mets(i,1);
end

for i=1:length(new_mets)
    M = regexprep(new_mets(i,1),'(','[');
    M = regexprep(M,')',']');
    met = new_mets(i,1);
    A = ismember(M,met);
    model.mets(A,1)= original_mets(i,1);
end
% close demand reactions
% Note that this will CLOSE ATP demand reaction, which findSExRxnInd keeps
% open!
model.lb(strncmp('DM_',model.rxns, 3))=0;
%aerobic
model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;

model.c(model.c ~= 0) = 0;
modelOri = model;
k = 1;
RPMI_composition={'EX_ala_L(e)','EX_arg-L(e)','EX_asn_L(e)','EX_asp_L(e)','EX_cys-L(e)','EX_gln-L(e)','EX_glu-L(e)','EX_gly(e)','EX_his-L(e)','EX_ile_L(e)','EX_leu_L(e)','EX_lys-L(e)','EX_met_L(e)','EX_phe_L(e)','EX_4HPRO','EX_pro-L(e)','EX_ser_L(e)','EX_thr_L(e)','EX_trp_L(e)','EX_tyr_L(e)','EX_val_L(e)','EX_ascb_L(e)','EX_btn(e)','EX_chol(e)','EX_pnto_R(e)','EX_fol(e)','EX_ncam(e)','EX_pydxn(e)','EX_ribflv(e)','EX_thm(e)','EX_cbl1(e)','EX_inost(e)','EX_ca2(e)','EX_fe3(e)','EX_k(e)','EX_hco3(e)','EX_na1(e)','EX_pi(e)','EX_glc(e)','EX_hxan(e)','EX_lnlc(e)','EX_lipoate(e)','EX_ptrc(e)','EX_pyr(e)','EX_thymd(e)','EX_etha(e)','EX_gthrd(e)'};

if strcmp(test,'Recon1') || strcmp(test,'all') || strcmp(test,'Harvey')

    % %      %% "Human Recon 1 test mouse biomass"
    % %     model = modelOri;
    % %     model.c(find(model.c)) = 0;
    % %     model.c(ismember(model.rxns,'biomass_mm_1_no_glygln'))=1;
    % %       FBA = optimizeCbModel(model,'max','zero');
    % %     TestSolution(k,1) = FBA.f);
    % %     TestSolutionName{k,1} = 'Human Recon 1 test mouse biomass';
    % %  k = k +1;clear FBA
  %% "Human Recon 1 human  biomass"
    model = modelOri;
    model.c(ismember(model.rxns,'biomass_reaction'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Human Recon 1 test human biomass';
    k = k +1;clear FBA
    %% "Human Recon 1 human  biomass"
    model = modelOri;
    model.c(ismember(model.rxns,'biomass_maintenance_noTrTr'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Human Recon 1 test human biomass (noTrTr)';
    k = k +1;clear FBA
    %% "Human Recon 1 human  biomass"
    model = modelOri;
    
    model.c(ismember(model.rxns,'biomass_maintenance'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Human Recon 1 test human biomass (maintenance)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)]; end ;k = k +1;clear FBA
    %% do not apply base medium for Harvey
    if strcmp(test,'Harvey') == 0
        model = modelOri; % What is this line doing?
        mediumCompounds = {'EX_co2(e)', 'EX_h(e)', 'EX_h2o(e)', 'EX_hco3(e)', 'EX_nh4(e)', 'EX_o2(e)', 'EX_pi(e)', 'EX_so4(e)'};
        ions={'EX_ca2(e)', 'EX_cl(e)', 'EX_co(e)', 'EX_fe2(e)', 'EX_fe3(e)', 'EX_k(e)', 'EX_na1(e)', 'EX_i(e)', 'EX_sel(e)'};
        I = modelOri.rxns(modelOri.ExchRxnBool & ~modelOri.biomassBool);

        for i=1:length(I)
            Ex= I(i);
            modelOri.lb(Ex,1) = 0;
            if modelOri.ub(Ex,1) < 0
                modelOri.ub(Ex,1)=1;
            end
            %  modelOri.ub(Ex,1) = 1;% uncomment to run for tcell models
        end
        modelOri.lb(ismember(modelOri.rxns,mediumCompounds))=-100;
        modelOri.lb(ismember(modelOri.rxns,ions))=-1;
    end
    %% ATP max aerobic, glc, v0.05
    model = modelOri;
    
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
        TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, glc';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)]; end ;k = k +1;clear FBA
    %% ATP max, anaerobic glc, v0.05
    model = modelOri;
    
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=0;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
        TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, anaerobic, glc';
    k = k +1;clear FBA
    %% ATP max, aerobic, citrate
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_cit(e)'))=-1;model.ub(ismember(model.rxns,'EX_cit(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
        TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, citrate';
    k = k +1;clear FBA
    %% ATP max, aerobic, EtOH substrate v0.05
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_etoh(e)'))=-1;model.ub(ismember(model.rxns,'EX_etoh(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, etoh';
    k = k +1;clear FBA
    %% ATP max, aerobic, glutamate v0.05
    model = modelOri;
    
    model.lb(ismember(model.rxns,'EX_glu-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_glu-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, glu-L';
    k = k +1;clear FBA
    %% ATP max, aerobic, glutamine substrate
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_gln-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_gln-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, gln-L';
    k = k +1;clear FBA
    %% ATP max, aerobic, glycine substrate v0.05
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_gly(e)'))=-1;model.ub(ismember(model.rxns,'EX_gly(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, gly';
    k = k +1;clear FBA
    %% ATP max, aerobic, lactate substrate v0.05
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_lac-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_lac-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, lac-L';
    k = k +1;clear FBA
    %% ATP max, aerobic, proline substrate v0.05
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_pro-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_pro-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, pro-L';
    k = k +1;clear FBA
    %% ATP production via electron transport chain
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    %model.lb(ismember(model.rxns,'CYOOm3'))=1; % there is an alternative
    %reaction
    if any(ismember(model.rxns,'CYOR-u10m')) && any(ismember(model.rxns,'NADH2-u10m'))
        if  model.ub(ismember(model.rxns,'CYOR-u10m'))>=1 && model.ub(ismember(model.rxns,'NADH2-u10m'))>=1
            model.lb(ismember(model.rxns,'CYOR-u10m'))=1;
            model.lb(ismember(model.rxns,'NADH2-u10m'))=1;
            model.c(ismember(model.rxns,'DM_atp(c)'))=1;
            if find(model.c)>0
                FBA = optimizeCbModel(model,'max','zero');
                TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
            else
                TestSolution(k,1) = NaN;
            end
        else
            TestSolution(k,1) = NaN;
        end
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP production via electron transport chain';
    k = k +1;clear FBA
    %% add RMPI medium to model
    if 0
        if strcmp(test,'Harvey') == 0
            RPMI_composition={'EX_ala_L(e)','EX_arg_L(e)','EX_asn_L(e)','EX_asp_L(e)','EX_cys_L(e)','EX_gln-L(e)','EX_glu-L(e)','EX_gly(e)','EX_his_L(e)','EX_ile_L(e)','EX_leu_L(e)','EX_lys_L(e)','EX_met_L(e)','EX_phe_L(e)','EX_4HPRO','EX_pro-L(e)','EX_ser_L(e)','EX_thr_L(e)','EX_trp_L(e)','EX_tyr_L(e)','EX_val_L(e)','EX_ascb_L(e)','EX_btn(e)','EX_chol(e)','EX_pnto_R(e)','EX_fol(e)','EX_ncam(e)','EX_pydxn(e)','EX_ribflv(e)','EX_thm(e)','EX_cbl1(e)','EX_inost(e)','EX_ca2(e)','EX_fe3(e)','EX_k(e)','EX_hco3(e)','EX_na1(e)','EX_pi(e)','EX_glc(e)','EX_hxan(e)','EX_lnlc(e)','EX_lipoate(e)','EX_ptrc(e)','EX_pyr(e)','EX_thymd(e)','EX_etha(e)','EX_gthrd(e)'};
            for i = 1 : length(RPMI_composition)
                modelOri = changeRxnBounds(modelOri,RPMI_composition{i},-1,'l');
            end
        end
    end

    %% gthrd reduces h2o2
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_gthrd(e)'))=-1;
    model.c(ismember(model.rxns,'GTHP'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gthrd reduces h2o2, GTHP (c) ';
    k = k +1;clear FBA

    model = modelOri;
    model.lb(ismember(model.rxns,'EX_gthrd(e)'))=-1;model.ub(ismember(model.rxns,'gthox(e)'))=1;
    
    model.c(ismember(model.rxns,'GTHPe'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gthrd reduces h2o2, GTHP (e) ';
    k = k +1;clear FBA

    model = modelOri;
    model.lb(ismember(model.rxns,'EX_gthrd(e)'))=-1;
    model.c(ismember(model.rxns,'GTHPm'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gthrd reduces h2o2, GTHP (m) ';
    k = k +1;clear FBA
    %% gly -> co2 and nh4 (via glycine cleavage system)
    model = modelOri;
    [model] = addSinkReactions(model,{'gly(c)','co2(c)','nh4(c)'},[-1 -1; 0.1 100; 0.1 100]);
    model.lb(ismember(model.rxns,'EX_nh4(e)'))=0;model.ub(ismember(model.rxns,'EX_nh4(e)'))=1000;
    model.c(ismember(model.rxns,'sink_nh4(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gly -> co2 + nh4';
    k = k +1;clear FBA

    %% 12ppd-S -> mthgxl
    model = modelOri;
    [model] = addSinkReactions(model,{'12ppd-S(c)','mthgxl(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_mthgxl(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '12ppd-S(c) -> mthgxl(c)';
    k = k +1;clear FBA
    %% 12ppd-S -> pyr
    model = modelOri;
    [model] = addSinkReactions(model,{'12ppd-S(c)','pyr(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '12ppd-S(c) -> pyr(c)';
    k = k +1;clear FBA
    %% 3pg -> gly
    model = modelOri;
    [model] = addSinkReactions(model,{'3pg(c)','gly(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gly(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '3pg(c) -> gly(c)';
    k = k +1;clear FBA
    %% 3pg -> ser-L
    model = modelOri;
    [model] = addSinkReactions(model,{'3pg(c)','ser-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ser-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '3pg(c) -> ser-L(c)';
    k = k +1;clear FBA
    %% 4abut -> succ[m]
    model = modelOri;
    [model] = addSinkReactions(model,{'4abut(c)','succ(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_succ(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '4abut(c) -> succ(m)';
    k = k +1;clear FBA
    %% 4hpro-LT(m) -> glx(m)
    model = modelOri;
    [model] = addSinkReactions(model,{'4hpro-LT(m)','glx(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glx(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '4hpro-LT(m) -> glx(m)';
    k = k +1;clear FBA
    %% 5aop -> pheme
    model = modelOri;
    [model] = addSinkReactions(model,{'5aop(c)','pheme(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pheme(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '5aop(c) -> pheme(c)';
    k = k +1;clear FBA
    %% aact -> mthgxl
    model = modelOri;
    [model] = addSinkReactions(model,{'aact(c)','mthgxl(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_mthgxl(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'aact(c) -> mthgxl(c)';
    k = k +1;clear FBA
    %% acac[m] -> acetone[m]
    model = modelOri;
    [model] = addSinkReactions(model,{'acac(m)','acetone(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_acetone(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acac(m) -> acetone(m)';
    k = k +1;clear FBA
    %% acac[m] -> bhb[m]
    model = modelOri;
    [model] = addSinkReactions(model,{'acac(m)','bhb(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_bhb(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acac(m) -> bhb(m)';
    k = k +1;clear FBA
    %% acald -> ac
    model = modelOri;
    [model] = addSinkReactions(model,{'acald(c)','ac(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ac(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acald(c) -> ac(c)';
    k = k +1;clear FBA
    %% accoa(c) -> pmtcoa(c) -> malcoa(m)
    model = modelOri;
    [model] = addSinkReactions(model,{'accoa(c)','pmtcoa(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pmtcoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'accoa(c) -> pmtcoa(c)';
    k = k +1;clear FBA
    %% accoa(c) -> pmtcoa(c) -> malcoa(m)
    model = modelOri;
    [model] = addSinkReactions(model,{'pmtcoa(c)','malcoa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_malcoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pmtcoa(c) -> malcoa(m)';
    k = k +1;clear FBA
    %% acetone -> mthgxl
    model = modelOri;
    [model] = addSinkReactions(model,{'acetone(c)','mthgxl(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_mthgxl(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acetone(c) -> mthgxl(c)';
    k = k +1;clear FBA
    %% acgal -> udpacgal
    model = modelOri;
    [model] = addSinkReactions(model,{'acgal(c)','udpacgal(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_udpacgal(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acgal(c) -> udpacgal(c)';
    k = k +1;clear FBA
    %% acgam -> cmpacna
    model = modelOri;
    [model] = addSinkReactions(model,{'acgam(c)','cmpacna(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cmpacna(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acgam(c) -> cmpacna(c)';
    k = k +1;clear FBA
    %% acorn -> orn
    model = modelOri;
    [model] = addSinkReactions(model,{'acorn(c)','orn(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_orn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acorn(c) -> orn(c)';
    k = k +1;clear FBA
    %% adrnl -> 34dhoxpeg
    model = modelOri;
    
    [model] = addSinkReactions(model,{'adrnl(c)','34dhoxpeg(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_34dhoxpeg(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'adrnl(c) -> 34dhoxpeg(c)';
    k = k +1;clear FBA
    %% adrnl -> 34dhoxpeg (2) % duplicate
    %% adrnl -> 34dhoxpeg (3) % duplicate
    %% akg[c] -> glu-L[c] % I adjusted lb since otherwise not feasible
    % model = modelOri;
    % 
    % [model] = addSinkReactions(model,{'akg(c)','glu-L(c)'},[-1 -1; 0 100]);
    % model.c(ismember(model.rxns,'sink_glu-L(c)'))=1;
    %   FBA = optimizeCbModel(model,'max','zero');
    % TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    % TestSolutionName{k,1} = 'akg(c) -> glu-L(c)';
    % k = k +1;clear FBA
    %% akg[c] -> glu-L[c] % I adjusted lb since otherwise not feasible
    model = modelOri;
    
    model.lb(ismember(model.rxns,'EX_akg(e)'))=-1;model.ub(ismember(model.rxns,'EX_akg(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('ALATA_L',model.rxns))
        model.c(ismember(model.rxns,'ALATA_L'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'akg(c) -> glu-L(c) (ALATA_L)';
    k = k +1;clear FBA

    %% akg[c] -> glu-L[c]
    model = modelOri;
    
    model.lb(ismember(model.rxns,'EX_akg(e)'))=-1;model.ub(ismember(model.rxns,'EX_akg(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('ASPTA',model.rxns))
        model.c(ismember(model.rxns,'ASPTA'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'akg(c) -> glu-L(c) (ASPTA)';
    k = k +1;clear FBA

    %% akg[m[ -> oaa[m]
    model = modelOri;
    
    [model] = addSinkReactions(model,{'akg(m)','oaa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_oaa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'akg(m) -> oaa(m)';
    k = k +1;clear FBA
    %% akg[m] -> glu-L[m]
    model = modelOri;
    
    [model] = addSinkReactions(model,{'akg(m)','glu-L(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glu-L(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'akg(m) -> glu-L(m)';
    k = k +1;clear FBA
    model = modelOri;
    
    [model] = addSinkReactions(model,{'akg(m)'},-1 , -1);
    if any(strcmp('ASPTAm',model.rxns))
        model.c(ismember(model.rxns,'ASPTAm'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'akg(m) -> glu-L(m) (ASPTAm)';
    k = k +1;clear FBA

    %% ala-B -> msa
    model = modelOri;
    
    [model] = addSinkReactions(model,{'ala-B(c)','msa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_msa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ala-B(c) -> msa(m)';
    k = k +1;clear FBA
    %% ala-D -> pyr
    model = modelOri;
    
    [model] = addSinkReactions(model,{'ala-D(c)','pyr(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ala-D(c) -> pyr(c)';
    k = k +1;clear FBA
    %% ala-L -> ala-D
    model = modelOri;
    
    [model] = addSinkReactions(model,{'ala-L(c)','ala-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ala-L(c) -> ala-D(c)';
    k = k +1;clear FBA
    %% ala-L -> pyr
    model = modelOri;
    
    [model] = addSinkReactions(model,{'ala-L(c)','pyr(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ala-L(c) -> pyr(c)';
    k = k +1;clear FBA
    %% arachd(c) -> malcoa(m)
    model = modelOri;
    
    [model] = addSinkReactions(model,{'arachd(c)','malcoa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_malcoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arachd(c) -> malcoa(m)';
    k = k +1;clear FBA
    %% arachd(r) -> txa2(r)
    model = modelOri;
    
    [model] = addSinkReactions(model,{'arachd(r)','txa2(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_txa2(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arachd(r) -> txa2(r)';
    k = k +1;clear FBA
    %% arg-L -> creat
    model = modelOri;
    
    [model] = addSinkReactions(model,{'arg-L(c)','creat(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_creat(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arg-L(c) -> creat(c)';
    k = k +1;clear FBA
    %% arg-L -> glu-L (m)
    model = modelOri;
    
    [model] = addSinkReactions(model,{'arg-L(c)','glu-L(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glu-L(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arg-L -> glu-L (m)';
    k = k +1;clear FBA
    %% arg-L -> no
    model = modelOri;
    
    [model] = addSinkReactions(model,{'arg-L(c)','no(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_no(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arg-L -> no';
    k = k +1;clear FBA
    %% arg-L -> pcreat
    model = modelOri;
    
    [model] = addSinkReactions(model,{'arg-L(c)','pcreat(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pcreat(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arg-L(c) -> pcreat(c)';
    k = k +1;clear FBA
    %% ascb -> eryth
    model = modelOri;
    
    [model] = addSinkReactions(model,{'ascb-L(c)','eryth(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'DM_ascb_L(c)'))=-1;
    model.ub(ismember(model.rxns,'DM_ascb_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_eryth(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ascb-L(c) -> eryth(c)';
    k = k +1;clear FBA
    %% ascb -> lyxnt
    model = modelOri;
    
    [model] = addSinkReactions(model,{'ascb-L(c)','lyxnt(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'DM_ascb_L(c)'))=-1;
    model.ub(ismember(model.rxns,'DM_ascb_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_lyxnt(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ascb-L(c) -> lyxnt(c)';
    k = k +1;clear FBA
    %% ascb -> thrnt
    model = modelOri;
    
    [model] = addSinkReactions(model,{'ascb-L(c)','thrnt(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'DM_ascb_L(c)'))=-1;
    model.ub(ismember(model.rxns,'DM_ascb_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_thrnt(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ascb-L(c) -> thrnt(c)';
    k = k +1;clear FBA
    %% ascb -> xylnt
    model = modelOri;
    
    [model] = addSinkReactions(model,{'ascb-L(c)','xylnt(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'DM_ascb_L(c)'))=-1;
    model.ub(ismember(model.rxns,'DM_ascb_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_xylnt(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ascb-L(c) -> xylnt(c)';
    k = k +1;clear FBA
    %% asn-L -> oaa
    model = modelOri;
    
    [model] = addSinkReactions(model,{'asn-L(c)','oaa(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_oaa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asn-L(c) -> oaa(c)';
    k = k +1;clear FBA
    %% asp-L + hco3 -> arg-L
    model = modelOri;
    
    [model] = addSinkReactions(model,{'asp-L(c)','hco3(c)','arg-L(c)'},[-1 -1;-1 -1;0 100]);
    model.c(ismember(model.rxns,'sink_arg-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asp-L(c) + hco3(c) -> arg-L(c)';
    k = k +1;clear FBA
    %% asp-L -> ala-B
    model = modelOri;
    
    [model] = addSinkReactions(model,{'asp-L(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asp-L(c) -> ala-B(c)';
    k = k +1;clear FBA
    %% asp-L -> asn-L
    model = modelOri;
    
    [model] = addSinkReactions(model,{'asp-L(c)','asn-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_asn-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asp-L(c) -> asn-L(c)';
    k = k +1;clear FBA
    %% asp-L -> fum (via argsuc)
    model = modelOri;
    
    [model] = addSinkReactions(model,{'asp-L(c)','argsuc(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_argsuc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asp-L(c) -> argsuc(c), asp-L -> fum (via argsuc), 1';
    k = k +1;clear FBA
    model = modelOri;
    
    [model] = addSinkReactions(model,{'argsuc(c)','fum(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_fum(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'argsuc(c) -> fum(c), asp-L -> fum (via argsuc), 2';
    k = k +1;clear FBA
    %% asp-L -> fum (via dcamp)
    model = modelOri;
    
    [model] = addSinkReactions(model,{'asp-L(c)','dcamp(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_asp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_asp_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_dcamp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asp-L(c) -> dcamp(c), asp-L -> fum (via dcamp), 1';
    k = k +1;clear FBA
    model = modelOri;
    
    model.lb(ismember(model.rxns,'sink_asp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_asp_L(c)'))=-1;
    [model] = addSinkReactions(model,{'dcamp(c)','fum(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_fum(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dcamp(c) -> fum(c), asp-L -> fum (via dcamp), 2';
    k = k +1;clear FBA
    model = modelOri;
    
    model.lb(ismember(model.rxns,'sink_asp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_asp_L(c)'))=-1;
    [model] = addSinkReactions(model,{'dcamp(c)','fum(c)'},[-1 -1; 0 100]);
    if any(strcmp('ADSS',model.rxns))
        model.c(ismember(model.rxns,'ADSS'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dcamp(c) -> fum(c), asp-L -> fum (via dcamp), 3';
    k = k +1;clear FBA

    %% asp-L -> oaa
    model = modelOri;
    % causes an infeasible model in Recon2
    %[model] = addSinkReactions(model,{'asp-L(c)','oaa(c)'},[-1 -1; 0 100]);
    [model] = addSinkReactions(model,{'asp-L(c)','oaa(c)'},[-1 -0.99; 0 100]);
    model.c(ismember(model.rxns,'sink_oaa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asp-L(c) -> oaa(c)';
    k = k +1;clear FBA
    %% carn -> ala-B
    model = modelOri;
    
    [model] = addSinkReactions(model,{'carn(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'carn -> ala-B';
    k = k +1;clear FBA
    %% chol(c) + dag_hs(c) -> pe_hs(c)
    model = modelOri;
    
    [model] = addSinkReactions(model,{'chol(c)','dag_hs(c)','pe_hs(c)'},[-1 -1;-1 -1;0 100]);
    model.c(ismember(model.rxns,'sink_pe_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'chol(c) + dag_hs(c) -> pe_hs(c)';
    k = k +1;clear FBA
    %% choline -> betaine -> glycine
    model = modelOri;
    
    [model] = addSinkReactions(model,{'chol(m)','glyb(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glyb(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'choline -> betaine (glyb) -> glycine, 1 [m]';
    k = k +1;clear FBA
    model = modelOri;
    
    [model] = addSinkReactions(model,{'glyb(m)','gly(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gly(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'choline -> betaine (glyb) -> glycine, 2 [m]';
    k = k +1;clear FBA
    %% coke(r) -> pecgoncoa(r)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'coke(r)','pecgoncoa(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pecgoncoa(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'coke(r) -> pecgoncoa(r)';
    k = k +1;clear FBA
    %% core2[g] -> ksii_core2[g]
    model = modelOri;
    [model] = addSinkReactions(model,{'core2(g)','ksii_core2(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ksii_core2(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'core2(g) -> ksii_core2(g)';
    k = k +1;clear FBA
    %% core4[g] -> ksii_core4[g]
    model = modelOri;
    [model] = addSinkReactions(model,{'core4(g)','ksii_core4(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ksii_core4(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'core4(g) -> ksii_core4(g)';
    k = k +1;clear FBA
    %% cspg_a[ly] -> 2 gal[ly] + glcur[ly] + xyl-D[ly] %I adjusted lb since otw infeasible
    model = modelOri;
    % may cause an infeasible model
    %[model] = addSinkReactions(model,{'cspg_a(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    [model] = addSinkReactions(model,{'cspg_a(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -0.99; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_xyl-D(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cspg_a[ly] -> gal[ly] + glcur[ly] + xyl-D[ly]';
    k = k +1;clear FBA
    %% cspg_b[ly] -> 2gal[ly] + glcur[ly] + xyl-D[ly]
    model = modelOri;
    [model] = addSinkReactions(model,{'cspg_b(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_xyl-D(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cspg_b[ly] -> gal[ly] + glcur[ly] + xyl-D[ly]';
    k = k +1;clear FBA
    %% cspg_c[ly] -> 2 gal[ly] + glcur[ly] + xyl-D[ly]
    model = modelOri;
    [model] = addSinkReactions(model,{'cspg_c(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_xyl-D(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cspg_c[ly] -> gal[ly] + glcur[ly] + xyl-D[ly]';
    k = k +1;clear FBA
    %% cspg_d[ly] -> 2 gal[ly] + glcur[ly] + xyl-D[ly]
    model = modelOri;
    [model] = addSinkReactions(model,{'cspg_d(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_xyl-D(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cspg_d[ly] -> gal[ly] + glcur[ly] + xyl-D[ly]';
    k = k +1;clear FBA
    %% cspg_e[ly] -> 2 gal[ly] + glcur[ly] + xyl-D[ly]
    model = modelOri;
    [model] = addSinkReactions(model,{'cspg_e(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_xyl-D(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cspg_e[ly] -> gal[ly] + glcur[ly] + xyl-D[ly]';
    k = k +1;clear FBA
    %% cys-L + glu-L + gly -> ghtrd
    model = modelOri;
    [model] = addSinkReactions(model,{'cys-L(c)', 'glu-L(c)','gly(c)','gthrd(c)'},[-1 -1;-1 -1;-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gthrd(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cys-L + glu-L + gly -> ghtrd';
    k = k +1;clear FBA
    %% cys-L -> 3sala -> so4 %I adjusted lb since otw infeasible
    model = modelOri;
    [model] = addSinkReactions(model,{'cys-L(c)','3sala(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'EX_so4(e)'))=0;model.ub(ismember(model.rxns,'EX_so4(e)'))=1000;
    model.c(ismember(model.rxns,'sink_3sala(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cys-L -> 3sala -> so4, 1';
    k = k +1;clear FBA
    model = modelOri;
    [model] = addSinkReactions(model,{'3sala(c)','so4(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'EX_so4(e)'))=0;model.ub(ismember(model.rxns,'EX_so4(e)'))=1000;
    model.c(ismember(model.rxns,'sink_so4(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cys-L -> 3sala -> so4, 2';
    k = k +1;clear FBA
    %% cys-L -> hyptaur
    model = modelOri;
    [model] = addSinkReactions(model,{'cys-L(c)','hyptaur(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_hyptaur(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cys-L(c) -> hyptaur(c)';
    k = k +1;clear FBA
    %% cystine -> cys-L
    model = modelOri;
    [model] = addSinkReactions(model,{'Lcystin(c)','cys-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cys-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cystine (Lcystin) -> cys-L';
    k = k +1;clear FBA
    %% dhap -> mthgxl
    model = modelOri;
    [model] = addSinkReactions(model,{'dhap(c)','mthgxl(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_mthgxl(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dhap(c) -> mthgxl(c)';
    k = k +1;clear FBA
    %% dmpp -> ggdp
    model = modelOri;


    model = changeRxnBounds(model,RPMI_composition,-1,'l');

    [model] = addSinkReactions(model,{'dmpp(c)','ggdp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ggdp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dmpp(c) -> ggdp(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% dna(n) -> dna5mtc(n)
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');

    [model] = addSinkReactions(model,{'dna(n)','dna5mtc(n)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dna5mtc(n)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dna(n) -> dna5mtc(n) (with RPMI medium)';
    k = k +1;clear FBA
    %% dolichol_L -> dolmanp_L(r)
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');

    [model] = addSinkReactions(model,{'dolichol_L(c)','dolmanp_L(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dolmanp_L(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dolichol_L(c) -> dolmanp_L(r) (with RPMI medium)';
    k = k +1;clear FBA
    %% dolichol_L -> g3m8mpdol_L[r]
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');

    [model] = addSinkReactions(model,{'dolichol_L(c)','g3m8mpdol_L(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_g3m8mpdol_L(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dolichol_L(c) -> g3m8mpdol_L(r) (with RPMI medium)';
    k = k +1;clear FBA
    %% dolichol_U -> dolmanp_U[r]
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');

    [model] = addSinkReactions(model,{'dolichol_U(c)','dolmanp_U(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dolmanp_U(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dolichol_U(c) -> dolmanp_U(r) (with RPMI medium)';
    k = k +1;clear FBA
    %% dolichol_U -> g3m8mpdol_U[r]
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');

    [model] = addSinkReactions(model,{'dolichol_U(c)','g3m8mpdol_U(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_g3m8mpdol_U(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dolichol_U(c) -> g3m8mpdol_U(r) (with RPMI medium)';
    k = k +1;clear FBA
    %% dopa -> homoval (1)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    [model] = addSinkReactions(model,{'dopa(c)','homoval(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'DM_dopa(c)'))=-1;
    model.ub(ismember(model.rxns,'DM_dopa(c)'))=-1;
    model.c(ismember(model.rxns,'sink_homoval(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dopa(c) -> homoval(c)';
    k = k +1;clear FBA
    %% dopa -> homoval (2) %duplicate
    %% etoh -> acald
    model = modelOri;
    [model] = addSinkReactions(model,{'etoh(c)','acald(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_acald(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'etoh(c) -> acald(c)';
    k = k +1;clear FBA
    %% f6p + g3p -> r5p
    model = modelOri;
    [model] = addSinkReactions(model,{'f6p(c)','g3p(c)','r5p(c)'},[-1 -1; -1 -1;0 100]);
    model.c(ismember(model.rxns,'sink_r5p(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'f6p(c) + g3p(c) -> r5p(c)';
    k = k +1;clear FBA
    %% frdp -> dolichol_L
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');

    [model] = addSinkReactions(model,{'frdp(c)','dolichol_L(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dolichol_L(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'frdp(c) -> dolichol_L(r) (with RPMI medium)';
    k = k +1;clear FBA
    %% frdp -> dolichol_U
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');

    [model] = addSinkReactions(model,{'frdp(c)','dolichol_U(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dolichol_U(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'frdp(c) -> dolichol_U(r) (with RPMI medium)';
    k = k +1;clear FBA
    %% from ade(c) to amp(c)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ade(c)','amp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_amp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ade(c) -> amp(c)';
    k = k +1;clear FBA
    %% from adn(c) to urate(x)
    model = modelOri;
    [model] = addSinkReactions(model,{'adn(c)','urate(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_urate(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'adn(c) -> urate(x)';
    k = k +1;clear FBA
    %% from ADP(c) to dATP(n)
    model = modelOri;
    [model,rxnsInModel] = addSinkReactions(model,{'adp(c)','datp(n)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_datp(n)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'adp(c) -> datp(n)';
    k = k +1;clear FBA
    %% from CDP(c) to dCTP(n)
    model = modelOri;
    [model,rxnsInModel] = addSinkReactions(model,{'cdp(c)','dctp(n)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_dctp(n)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cdp(c) -> dctp(n)';
    k = k +1;clear FBA
    %% from cmp to cytd
    model = modelOri;
    [model] = addSinkReactions(model,{'cmp(c)','cytd(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cytd(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cmp(c) -> cytd(c)';
    k = k +1;clear FBA
    %% from cytd to ala-B
    model = modelOri;
    [model] = addSinkReactions(model,{'cytd(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cytd(c) -> ala-B(c)';
    k = k +1;clear FBA
    %% from dcmp to ala-B
    model = modelOri;
    [model] = addSinkReactions(model,{'dcmp(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dcmp(c) -> ala-B(c)';
    k = k +1;clear FBA
    %% from GDP(c) to dGTP(n)
    model = modelOri;
    [model] = addSinkReactions(model,{'gdp(c)','dgtp(n)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_dgtp(n)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gdp(c) -> dgtp(n)';
    k = k +1;clear FBA
    %% from gln-L + HCO3 to UMP(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'gln-L(c)','hco3(c)','ump(c)'},[-1 -1;-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ump(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gln-L + HCO3 -> UMP(c)';
    k = k +1;clear FBA
    %% from gsn(c) to urate(x)
    model = modelOri;
    [model] = addSinkReactions(model,{'gsn(c)','urate(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_urate(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gsn(c) -> urate(x)';
    k = k +1;clear FBA
    %% from gua(c) to gmp(c)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gua(c)','gmp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gmp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gua(c) -> gmp(c)';
    k = k +1;clear FBA
    %% from hxan(c) to imp(c)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'hxan(c)','imp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_imp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hxan(c) -> imp(c)';
    k = k +1;clear FBA
    %% from imp to ATP
    model = modelOri;
    [model] = addSinkReactions(model,{'imp(c)','atp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'imp(c) -> atp(c)';
    k = k +1;clear FBA
    %% from imp to gtp
    model = modelOri;
    % may cause an infeasible model
    %[model] = addSinkReactions(model,{'imp(c)','gtp(c)'},[-1 -1; 0 100]);
    [model] = addSinkReactions(model,{'imp(c)','gtp(c)'},[-1 -0.99; 0 100]);
    model.c(ismember(model.rxns,'sink_gtp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'imp(c) -> gtp(c)';
    k = k +1;clear FBA
    %% from imp(c) to urate(x)
    model = modelOri;
    [model] = addSinkReactions(model,{'imp(c)','urate(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_urate(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'imp(c) -> urate(x)';
    k = k +1;clear FBA
    %% from prpp to imp
    model = modelOri;
    [model] = addSinkReactions(model,{'prpp(c)','imp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_imp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'prpp(c) -> imp(c)';
    k = k +1;clear FBA
    %% from pydx(c) to pydx5p(c)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pydx(c)','pydx5p(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_pydx(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_pydx(c)'))=-1;
    model.c(ismember(model.rxns,'sink_pydx5p(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pydx(c) -> pydx5p(c)';
    k = k +1;clear FBA
    %% from thm(c) to thmpp(c)
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');

    [model] = addSinkReactions(model,{'thm(c)','thmpp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_thmpp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thm(c) -> thmpp(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% from thm(e) to thmpp(m) %does not work; changing lb has no effect
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');

    [model] = addSinkReactions(model,{'thm(e)','thmpp(m)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'EX_thm(e)'))=-1;
    model.ub(ismember(model.rxns,'EX_thm(e)'))=-1;
    model.c(ismember(model.rxns,'sink_thmpp(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thm(e) -> thmpp(m) (with RPMI medium)';
    k = k +1;clear FBA
    %% from thmmp(e) to thmpp(c)
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');

    [model] = addSinkReactions(model,{'thmmp(e)','thmpp(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'EX_thmmp(e)'))=-1;
    model.ub(ismember(model.rxns,'EX_thmmp(e)'))=-1;
    model.c(ismember(model.rxns,'sink_thmpp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thmmp(e) -> thmpp(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% from thmmp(e) to thmpp(m)%does not work; changing lb has no effect
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    model.lb(ismember(model.rxns,'EX_thmmp(e)'))=-1;
    model.ub(ismember(model.rxns,'EX_thmmp(e)'))=-1;
    [model] = addSinkReactions(model,{'thmpp(m)'},[ 0 100]);
    model.c(ismember(model.rxns,'sink_thmpp(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thmmp(e) -> thmpp(m) (with RPMI medium)';
    k = k +1;clear FBA
    %% from tyr-L(m) to q10(m)
    model = modelOri;
    [model] = addSinkReactions(model,{'tyr-L(m)','q10(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_q10(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(m) -> q10(m)';
    k = k +1;clear FBA
    %% from UDP(c) to dTTP(n)
    model = modelOri;
    [model] = addSinkReactions(model,{'udp(c)','dttp(n)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_dttp(n)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'udp(c) -> dttp(n)';
    k = k +1;clear FBA
    %% from ump to ala-B
    model = modelOri;
    [model] = addSinkReactions(model,{'ump(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ump(c) -> ala-B(c)';
    k = k +1;clear FBA
    %% fru -> dhap
    model = modelOri;
    [model] = addSinkReactions(model,{'fru(c)','dhap(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dhap(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fru(c) -> dhap(c)';
    k = k +1;clear FBA
    %% fru -> g3p
    model = modelOri;
    [model] = addSinkReactions(model,{'fru(c)','g3p(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_g3p(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fru(c) -> g3p(c)';
    k = k +1;clear FBA
    %% fuc -> gdpfuc
    model = modelOri;

    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'fuc-L(c)','gdpfuc(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gdpfuc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fuc-L(c) -> gdpfuc(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% fum[m] -> oaa[m]
    model = modelOri;
    [model] = addSinkReactions(model,{'fum(m)','oaa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_oaa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fum(m) -> oaa(m)';
    k = k +1;clear FBA
    %% g1p -> dtdprmn
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'g1p(c)','dtdprmn(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dtdprmn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'g1p(c) -> dtdprmn(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% g3p -> mthgxl
    model = modelOri;
    [model] = addSinkReactions(model,{'g3p(c)','mthgxl(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_mthgxl(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'g3p(c) -> mthgxl(c)';
    k = k +1;clear FBA
    %% g6p -> r5p
    model = modelOri;
    [model] = addSinkReactions(model,{'g6p(c)','r5p(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_r5p(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'g6p(c) -> r5p(c)';
    k = k +1;clear FBA
    %% g6p -> ru5p
    model = modelOri;
    [model] = addSinkReactions(model,{'g6p(c)','ru5p-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ru5p-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'g6p(c) -> ru5p-D(c)';
    k = k +1;clear FBA
    %% gal -> glc
    model = modelOri;
    [model] = addSinkReactions(model,{'gal(c)','glc-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glc-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gal(c) -> glc-D(c)';
    k = k +1;clear FBA
    %% gal -> udpgal
    model = modelOri;
    [model] = addSinkReactions(model,{'gal(c)','udpgal(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_udpgal(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gal(c) -> udpgal(c)';
    k = k +1;clear FBA
    %% galgluside(g) -> galgalgalthcrm_hs(g)
    model = modelOri;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','galgalgalthcrm_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_galgalgalthcrm_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> galgalgalthcrm_hs(g)';
    k = k +1;clear FBA
    %% galgluside_hs(g) -> acgagbside_hs(g)
    model = modelOri;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','acgagbside_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_acgagbside_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> acgagbside_hs(g)';
    k = k +1;clear FBA
    %% galgluside_hs(g) -> acnacngalgbside_hs(g)
    model = modelOri;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','acnacngalgbside_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_acnacngalgbside_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> acnacngalgbside_hs(g)';
    k = k +1;clear FBA
    %% galgluside_hs(g) -> gd1b2_hs(g)
    model = modelOri;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','gd1b2_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gd1b2_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> gd1b2_hs(g)';
    k = k +1;clear FBA
    %% galgluside_hs(g) -> gd1c_hs(g)
    model = modelOri;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','gd1c_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gd1c_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> gd1c_hs(g)';
    k = k +1;clear FBA
    %% galgluside_hs(g) -> gp1c_hs(g)
    model = modelOri;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','gp1c_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gp1c_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> gp1c_hs(g)';
    k = k +1;clear FBA
    %% galgluside_hs(g) -> gq1balpha_hs(g)
    model = modelOri;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','gq1balpha_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gq1balpha_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> gq1balpha_hs(g)';
    k = k +1;clear FBA
    %% gam6p -> uacgam
    model = modelOri;
    [model] = addSinkReactions(model,{'gam6p(c)','uacgam(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_uacgam(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gam6p(c) -> uacgam(c)';
    k = k +1;clear FBA
    %% gdpmann -> gdpfuc
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gdpmann(c)','gdpfuc(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gdpfuc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gdpmann(c) -> gdpfuc(c)';
    k = k +1;clear FBA
    %% glc -> inost
    model = modelOri;
    [model] = addSinkReactions(model,{'glc-D(c)','inost(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_inost(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glc-D(c) -> inost(c)';
    k = k +1;clear FBA
    %% glc -> lac + atp + h2o % I assumed lac-L
    model = modelOri;
    [model] = addSinkReactions(model,{'glc-D(c)','lac-L(c)','atp(c)','h2o(c)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_lac-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glc-D(c) -> lac-L(c) + atp(c) + h2o(c)';
    k = k +1;clear FBA
    %% glc -> lac-D
    model = modelOri;
    [model] = addSinkReactions(model,{'glc-D(c)','lac-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_lac-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glc-D(c) -> lac-D(c)';
    k = k +1;clear FBA
    %% glc -> lcts[g] (2)
    model = modelOri;
    [model] = addSinkReactions(model,{'glc-D(c)','lcts(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_lcts(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glc-D(c) -> lcts(g)';
    k = k +1;clear FBA
    %% glc -> pyr
    model = modelOri;
    [model] = addSinkReactions(model,{'glc-D(c)','pyr(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glc-D(c) -> pyr(c)';
    k = k +1;clear FBA
    %% gln -> nh4
    model = modelOri;
    [model] = addSinkReactions(model,{'gln-L(c)','nh4(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'EX_nh4(e)'))=0;model.ub(ismember(model.rxns,'EX_nh4(e)'))=1000;
    model.c(ismember(model.rxns,'sink_nh4(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gln-L(c) -> nh4(c)';
    k = k +1;clear FBA
    %% gln-L(m) -> glu-L(m)
    model = modelOri;
    [model] = addSinkReactions(model,{'gln-L(m)','glu-L(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glu-L(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gln-L(m) -> glu-L(m)';
    k = k +1;clear FBA
    %% gln-L[m] -> glu-L[m]
    model = modelOri;
    [model] = addSinkReactions(model,{'gln-L(m)','glu-L(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glu-L(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gln-L(m) -> glu-L(m)';
    k = k +1;clear FBA
    %% glu5sa -> pro-L
    model = modelOri;
    [model] = addSinkReactions(model,{'glu5sa(c)','pro-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pro-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glu5sa(c) -> pro-L(c)';
    k = k +1;clear FBA
    %% glu-L -> 4abut
    model = modelOri;
    [model] = addSinkReactions(model,{'glu-L(c)','4abut(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_4abut(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glu-L(c) -> 4abut(c)';
    k = k +1;clear FBA
    %% glu-L -> gln-L[c] %I adjusted lb since otw infeasible
    model = modelOri;
    [model] = addSinkReactions(model,{'glu-L(c)','gln-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glu-L(c) -> gln-L(c)';
    k = k +1;clear FBA
    %% glu-L -> pro-L
    model = modelOri;
    [model] = addSinkReactions(model,{'glu-L(c)','pro-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pro-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glu-L -> pro-L';
    k = k +1;clear FBA
    %% glu-L(m) -> akg(m)
    model = modelOri;
    [model] = addSinkReactions(model,{'glu-L(m)','akg(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_akg(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glu-L(m) -> akg(m)';
    k = k +1;clear FBA
    %% gluside_hs(g) -> galgluside_hs(g)
    model = modelOri;
    [model] = addSinkReactions(model,{'gluside_hs(g)','galgluside_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_galgluside_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gluside_hs(g) -> galgluside_hs(g)';
    k = k +1;clear FBA
    %% glx[m] -> glyclt[m]
    model = modelOri;
    [model] = addSinkReactions(model,{'glx(m)','glyclt(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glyclt(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glx(m) -> glyclt(m)';
    k = k +1;clear FBA
    %% gly -> ser-L -> pyr (via SERD_L) % SERD_L does not exist in human
    % (L-serine deaminase)
    model = modelOri;
    [model] = addSinkReactions(model,{'gly(c)','ser-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ser-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gly(c) -> ser-L(c) -> pyr(c), 1';
    k = k +1;clear FBA
    model = modelOri;
    [model] = addSinkReactions(model,{'ser-L(c)','pyr(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gly(c) -> ser-L(c) -> pyr(c), 2';
    k = k +1;clear FBA
    %% glyc -> glc
    model = modelOri;
    [model] = addSinkReactions(model,{'glyc(c)','glc-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glc-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glyc(c) -> glc-D(c)';
    k = k +1;clear FBA
    %% glyc(c) + Rtotal(c) + Rtotal2(c) -> dag_hs(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'glyc(c)','Rtotal(c)','Rtotal2(c)','dag_hs(c)'},[-1 -1;-1 -1;-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dag_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glyc(c) + Rtotal(c) + Rtotal2(c) -> dag_hs(c)';
    k = k +1;clear FBA
    %% glyc(c) + Rtotal(c) -> tag_hs(c)
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');

    [model] = addSinkReactions(model,{'glyc(c)','Rtotal(c)','tag_hs(c)'},[-1 -1;-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_tag_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glyc(c) + Rtotal(c) -> tag_hs(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% glyclt -> gly
    model = modelOri;
    [model] = addSinkReactions(model,{'glyclt(c)','gly(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gly(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glyclt(c) -> gly(c)';
    k = k +1;clear FBA
    %% glygn2 -> glc % changing lb has no effect
    model = modelOri;
    [model] = addSinkReactions(model,{'glygn2(c)','glc-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glc-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glygn2(c) -> glc-D(c)';
    k = k +1;clear FBA
    %% glygn2[e] -> glc[e]
    model = modelOri;
    [model] = addSinkReactions(model,{'glygn2(e)','glc-D(e)'},[-1 -1; 0 100]);
    %model.c(ismember(model.rxns,'sink_glc-D(e)'))=1;
    if any(strcmp('AMY2e',model.rxns))
        model = changeObjective(model,'AMY2e',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glygn2(e) -> glc-D(e) - via AMY2e';
    k = k +1;clear FBA
    %% glyx -> oxa % I assumed glx
    model = modelOri;
    [model] = addSinkReactions(model,{'glx(c)','oxa(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_oxa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glx(c) -> oxa(c)';
    k = k +1;clear FBA
    %% ha[l] -> acgam[l] + glcur[l]
    model = modelOri;
    [model] = addSinkReactions(model,{'ha(l)','acgam(l)','glcur(l)'},[-1 -1; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_acgam(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ha[l] -> acgam[l] + glcur[l]';
    k = k +1;clear FBA
    %% His -> glu-L
    model = modelOri;
    [model] = addSinkReactions(model,{'his-L(c)','glu-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glu-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'his-L(c) -> glu-L(c)';
    k = k +1;clear FBA
    %% his-L -> hista
    model = modelOri;
    [model] = addSinkReactions(model,{'his-L(c)','hista(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_his_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_his_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_hista(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'his-L(c) -> hista(c)';
    k = k +1;clear FBA
    %% hista -> 3mlda
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'hista(c)','3mlda(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'DM_hista(c)'))=-1;
    model.ub(ismember(model.rxns,'DM_hista(c)'))=-1;
    model.c(ismember(model.rxns,'sink_3mlda(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hista(c) -> 3mlda(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% hista -> im4ac
    model = modelOri;
    [model] = addSinkReactions(model,{'hista(c)','im4act(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_im4act(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hista(c) -> im4ac(c)';
    k = k +1;clear FBA
    %% hmgcoa(x) -> chsterol(r)
    model = modelOri;
    [model] = addSinkReactions(model,{'hmgcoa(x)','chsterol(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_chsterol(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hmgcoa(x) -> chsterol(r)';
    k = k +1;clear FBA
    %% hmgcoa(x) -> frdp(x)
    model = modelOri;
    [model] = addSinkReactions(model,{'hmgcoa(x)','frdp(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_frdp(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hmgcoa(x) -> frdp(x)';
    k = k +1;clear FBA
    %% hmgcoa(x) -> xoldiolone(r)
    model = modelOri;
    [model] = addSinkReactions(model,{'hmgcoa(x)','xoldiolone(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_xoldiolone(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hmgcoa(x) -> xoldiolone(r)';
    k = k +1;clear FBA
    %% hmgcoa(x) -> xoltriol(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'hmgcoa(x)','xoltriol(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_xoltriol(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hmgcoa(x) -> xoltriol(c)';
    k = k +1;clear FBA
    %% hmgcoa(x)-chsterol(r) %duplicate
    % model = modelOri;
    % [model] = addSinkReactions(model,{'hmgcoa(x)','chsterol(r)'},[-1 -1; 0 100]);
    % model.c(ismember(model.rxns,'sink_chsterol(r)'))=1;
    %   FBA = optimizeCbModel(model,'max','zero');
    % TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    % TestSolutionName{k,1} = 'hmgcoa(x) -> chsterol(r)';
    % k = k +1;clear FBA
    %% hpyr -> 2pg
    model = modelOri;
    [model] = addSinkReactions(model,{'hpyr(c)','2pg(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_2pg(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hpyr(c) -> 2pg(c)';
    k = k +1;clear FBA
    %% hpyr -> glyclt
    model = modelOri;
    [model] = addSinkReactions(model,{'hpyr(c)','glyclt(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glyclt(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hpyr(c) -> glyclt(c)';
    k = k +1;clear FBA
    %% hpyr -> glyc-S
    model = modelOri;
    [model] = addSinkReactions(model,{'hpyr(c)','glyc-S(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glyc-S(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hpyr(c) -> glyc-S(c)';
    k = k +1;clear FBA
    %% hspg(l) -> 2 gal(l) + glcur(l) + xyl-D(l) %changing lb has no effect
    model = modelOri;
    [model] = addSinkReactions(model,{'hspg(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_xyl-D(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hspg(l) -> gal(l) + glcur(l) + xyl-D(l)';
    k = k +1;clear FBA
    %% hyptaur(c) -> taur(x)
    model = modelOri;
    [model] = addSinkReactions(model,{'hyptaur(c)','taur(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_taur(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hyptaur(c) -> taur(x)';
    k = k +1;clear FBA
    %% ile-L -> accoa
    model = modelOri;
    [model] = addSinkReactions(model,{'ile-L(c)','accoa(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_ile_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_ile_L(c)'))=-1;
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    model.c(ismember(model.rxns,'sink_accoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ile-L(c) -> accoa(c)';
    k = k +1;clear FBA
    %% inost -> pail_hs
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'inost(c)','pail_hs(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pail_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'inost(c) -> pail_hs(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% inost -> pail45p_hs
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'inost(c)','pail45p_hs(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pail45p_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'inost(c) -> pail45p_hs(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% inost -> pail4p_hs
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'inost(c)','pail4p_hs(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pail4p_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'inost(c) -> pail4p_hs(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% inost -> xu5p-D
    model = modelOri;
    [model] = addSinkReactions(model,{'inost(c)','xu5p-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_xu5p-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'inost(c) -> xu5p-D(c)';
    k = k +1;clear FBA
    %% ipdp(x) -> sql(r)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ipdp(x)','sql(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_sql(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ipdp(x) -> sql(r)';
    k = k +1;clear FBA
    %% itacon[m] -> pyr[m] %changing lb has no effect
    model = modelOri;
    [model] = addSinkReactions(model,{'itacon(m)','pyr(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'itacon(m) -> pyr(m)';
    k = k +1;clear FBA
    %% ksi[l] -> man[l] + acgam[l]
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'ksi(l)','man(l)','acgam(l)'},[-1 -1; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_acgam(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ksi[l] -> man[l] + acgam[l] (with RPMI medium)';
    k = k +1;clear FBA
    %% ksii_core2(l) -> Ser/Thr(l)
    model = modelOri;
    [model,rxnsInModel] = addSinkReactions(model,{'ksii_core2(l)','Ser/Thr(l)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_Ser/Thr(l)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ksii_core2(l) -> Ser/Thr(l)';
    k = k +1;clear FBA
    %% ksii_core4(l) -> Ser/Thr(l)
    model = modelOri;
    [model,rxnsInModel] = addSinkReactions(model,{'ksii_core4(l)','Ser/Thr(l)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_Ser/Thr(l)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ksii_core4(l) -> Ser/Thr(l)';
    k = k +1;clear FBA
    %% l2fn2m2masn[g] -> ksi[g]
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'l2fn2m2masn(g)','ksi(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ksi(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'l2fn2m2masn(g) -> ksi(g) (with RPMI medium)';
    k = k +1;clear FBA
    %% lac -> glc % i assumed lac-L
    model = modelOri;
    [model] = addSinkReactions(model,{'lac-L(c)','glc-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glc-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'lac-L(c) -> glc-D(c)';
    k = k +1;clear FBA
    %% Lcyst(c) -> taur(x)
    model = modelOri;
    [model] = addSinkReactions(model,{'Lcyst(c)','taur(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_taur(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Lcyst(c) -> taur(x)';
    k = k +1;clear FBA
    %% leu-L -> accoa
    model = modelOri;
    [model] = addSinkReactions(model,{'leu-L(c)','accoa(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_leu_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_leu_L(c)'))=-1;
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    model.c(ismember(model.rxns,'sink_accoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'leu-L(c) -> accoa(c)';
    k = k +1;clear FBA
    %% lys-L[c] -> accoa[m] (via saccrp-L pathway)
    model = modelOri;
    [model] = addSinkReactions(model,{'lys-L(c)','accoa(m)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_lys_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_lys_L(c)'))=-1;
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'lys-L[c] -> accoa[m] (via saccrp-L pathway)';
    k = k +1;clear FBA
    %% lys-L[x] -> aacoa[m] (via Lpipecol pathway)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_lys-L(e)'))=-1;
    model.ub(ismember(model.rxns,'EX_lys-L(e)'))=-1;
    [model] = addSinkReactions(model,{'lys-L(x)','aacoa(m)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    model.c(ismember(model.rxns,'sink_aacoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'lys-L[x] -> aacoa[m] (via Lpipecol pathway)';
    k = k +1;clear FBA
    %% m8masn[r] -> nm4masn[g]
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'m8masn(r)','nm4masn(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_nm4masn(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'm8masn(r) -> nm4masn(g)';
    k = k +1;clear FBA
    %% man -> gdpmann
    model = modelOri;
    [model] = addSinkReactions(model,{'man(c)','gdpmann(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gdpmann(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'man(c) -> gdpmann(c)';
    k = k +1;clear FBA
    %% man6p -> kdn
    model = modelOri;
    [model] = addSinkReactions(model,{'man6p(c)','kdn(c)'},[-1 -1; 0 100]);
    if any(strcmp('ACNAM9PL2',model.rxns))
        model.c(ismember(model.rxns,'ACNAM9PL2'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'man6p(c) -> kdn(c) - via ACNAM9PL2';
    k = k +1;clear FBA

    %% mescon[m] -> pyr[m] %changing lb has no effect
    model = modelOri;
    [model] = addSinkReactions(model,{'mescon(m)','pyr(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'mescon(m) -> pyr(m)';
    k = k +1;clear FBA
    %% met-L -> cys-L
    model = modelOri;
    [model] = addSinkReactions(model,{'met-L(c)','cys-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cys-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'met-L(c) -> cys-L(c)';
    k = k +1;clear FBA
    %% mi145p -> inost
    model = modelOri;
    [model] = addSinkReactions(model,{'mi145p(c)','inost(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_inost(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'mi145p(c) -> inost(c)';
    k = k +1;clear FBA
    %% missing dtmp-3aib testing ???
    %% msa -> ala-B %changing lb has no effect
    model = modelOri;
    [model] = addSinkReactions(model,{'msa(m)','ala-B(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'msa(m) -> ala-B(m)';
    k = k +1;clear FBA
    %% mthgxl -> 12ppd-S
    model = modelOri;
    [model] = addSinkReactions(model,{'mthgxl(c)','12ppd-S(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_12ppd-S(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'mthgxl(c) -> 12ppd-S(c)';
    k = k +1;clear FBA
    %% mthgxl -> lac-D
    model = modelOri;
    [model] = addSinkReactions(model,{'mthgxl(c)','lac-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_lac-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'mthgxl(c) -> lac-D(c)';
    k = k +1;clear FBA
    %% n2m2nmasn[l] -> man[l] + acgam[l]
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'n2m2nmasn(l)','man(l)','acgam(l)'},[-1 -1; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_acgam(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'n2m2nmasn[l] -> man[l] + acgam[l] (with RPMI medium)';
    k = k +1;clear FBA
    %% nm4masn[g] -> l2fn2m2masn[g]
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'nm4masn(g)','l2fn2m2masn(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_l2fn2m2masn(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'nm4masn(g) -> l2fn2m2masn(g) (with RPMI medium)';
    k = k +1;clear FBA
    %% nm4masn[g] -> n2m2nmasn[g]
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'nm4masn(g)','n2m2nmasn(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_n2m2nmasn(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'nm4masn(g) -> n2m2nmasn(g) (with RPMI medium)';
    k = k +1;clear FBA
    %% nm4masn[g] -> s2l2fn2m2masn[g]
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'nm4masn(g)','s2l2fn2m2masn(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_s2l2fn2m2masn(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'nm4masn(g) -> s2l2fn2m2masn(g) (with RPMI medium)';
    k = k +1;clear FBA
    %% npphr -> 34dhoxpeg %npphr does not exists
    % model = modelOri;
    % [model] = addSinkReactions(model,{'npphr(c)','34dhoxpeg(c)'},[-1 -1; 0 100]);
    % model.c(ismember(model.rxns,'sink_34dhoxpeg(c)'))=1;
    %   FBA = optimizeCbModel(model,'max','zero');
    % TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    % TestSolutionName{k,1} = 'npphr(c) -> 34dhoxpeg(c)';
    % k = k +1;clear FBA
    %% o2- -> h2o2 -> o2 + h2o
    model = modelOri;
    [model] = addSinkReactions(model,{'o2s(c)','h2o2(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_h2o2(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'o2- -> h2o2 -> o2 + h2o, 1';
    k = k +1;clear FBA
    model = modelOri;

    model.lb(ismember(model.rxns,'EX_h2o(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'h2o2(c)','o2(c)','h2o(c)'},[-1 -1; -1 -1; 0.1 100]);
    model.c(ismember(model.rxns,'sink_h2o(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'o2- -> h2o2 -> o2 + h2o, 2';
    k = k +1;clear FBA
    %% orn -> nh4 v0.05
    model = modelOri;
    [model] = addSinkReactions(model,{'orn(c)','nh4(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'EX_nh4(e)'))=0;model.ub(ismember(model.rxns,'EX_nh4(e)'))=1000;
    model.c(ismember(model.rxns,'sink_nh4(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'orn(c) -> nh4(c)';
    k = k +1;clear FBA
    %% orn -> ptrc
    model = modelOri;
    [model] = addSinkReactions(model,{'orn(c)','ptrc(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ptrc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'orn(c) -> ptrc(c)';
    k = k +1;clear FBA
    %% orn -> spmd
    model = modelOri;
    [model] = addSinkReactions(model,{'orn(c)','spmd(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_spmd(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'orn(c) -> spmd(c)';
    k = k +1;clear FBA
    %% orn -> sprm
    model = modelOri;
    [model,rxnsInModel] = addSinkReactions(model,{'orn(c)','sprm(c)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_sprm(c)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'orn(c) -> sprm(c)';
    k = k +1;clear FBA
    %% pail_hs -> gpi_prot_hs[r]
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'pail_hs(c)','gpi_prot_hs(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gpi_prot_hs(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pail_hs(c) -> gpi_prot_hs(r) (with RMPI medium)';
    k = k +1;clear FBA
    %% pail45p -> mi145p
    model = modelOri;
    [model] = addSinkReactions(model,{'pail45p_hs(c)','mi145p(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_mi145p(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pail45p(c) -> mi145p(c)';
    k = k +1;clear FBA
    %% phe-L -> pac
    model = modelOri;
    [model] = addSinkReactions(model,{'phe-L(c)','pac(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pac(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> pac(c)';
    k = k +1;clear FBA
    %% phe-L -> pacald
    model = modelOri;
    [model] = addSinkReactions(model,{'phe-L(c)','pacald(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pacald(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> pacald(c)';
    k = k +1;clear FBA
    %% phe-L -> peamn
    model = modelOri;
    [model] = addSinkReactions(model,{'phe-L(c)','peamn(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_peamn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> peamn(c)';
    k = k +1;clear FBA
    %% phe-L -> phaccoa
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'phe-L(c)','phaccoa(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_phe_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_phe_L(c)'))=-1;
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    model.c(ismember(model.rxns,'sink_phaccoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> phaccoa(c)';
    k = k +1;clear FBA
    %% phe-L -> pheacgln
    model = modelOri;
    [model] = addSinkReactions(model,{'phe-L(c)','pheacgln(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_phe_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_phe_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_pheacgln(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> pheacgln(c)';
    k = k +1;clear FBA
    %% phe-L -> phpyr
    model = modelOri;
    [model] = addSinkReactions(model,{'phe-L(c)','phpyr(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_phe_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_phe_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_phpyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> phpyr(c)';
    k = k +1;clear FBA
    %% phe-L -> tyr-L
    model = modelOri;
    [model] = addSinkReactions(model,{'phe-L(c)','tyr-L(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_phe_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_phe_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_tyr-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> tyr-L(c)';
    k = k +1;clear FBA
    %% pheme -> bilirub %changing lb has no effect
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pheme(c)','bilirub(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_pheme(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_pheme(c)'))=-1;
    model.c(ismember(model.rxns,'sink_bilirub(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pheme(c) -> bilirub(c)';
    k = k +1;clear FBA
    %% phytcoa(x) -> dmnoncoa(m)
    model = modelOri;
    [model] = addSinkReactions(model,{'phytcoa(x)','dmnoncoa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dmnoncoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phytcoa(x) -> dmnoncoa(m)';
    k = k +1;clear FBA
    %% pmtcoa(c) -> crmp_hs(c)
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'pmtcoa(c)','crmp_hs(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_crmp_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pmtcoa(c) -> crmp_hs(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% pmtcoa(c) -> sphmyln_hs(c)
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'pmtcoa(c)','sphmyln_hs(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_sphmyln_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pmtcoa(c) -> sphmyln_hs(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% ppcoa[m] -> succoa[m]
    model = modelOri;
    [model] = addSinkReactions(model,{'ppcoa(m)','succoa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_succoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ppcoa(m) -> succoa(m)';
    k = k +1;clear FBA
    %% pro-L -> glu-L
    model = modelOri;
    [model] = addSinkReactions(model,{'pro-L(c)','glu-L(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_pro_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_pro_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_glu-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_glu_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pro-L(c) -> glu-L(c)';
    k = k +1;clear FBA
    %% ptrc -> ala-B
    model = modelOri;
    [model] = addSinkReactions(model,{'ptrc(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ptrc(c) -> ala-B(c)';
    k = k +1;clear FBA
    %% ptrc -> spmd
    model = modelOri;
    [model] = addSinkReactions(model,{'ptrc(c)','spmd(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_spmd(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ptrc(c) -> spmd(c)';
    k = k +1;clear FBA
    %% pyr -> fad[m] + h[m] %changing lb has no effect
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'pyr(c)','fadh2(m)','fad(m)','h(m)'},[-1 -1;-1 0;  0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_fad(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr -> fad[m] + h[m] (with RPMI medium)';
    k = k +1;clear FBA
    %% pyr -> lac-D
    model = modelOri;
    [model] = addSinkReactions(model,{'pyr(c)','lac-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_lac-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr(c) -> lac-D(c)';
    k = k +1;clear FBA
    %% pyr -> nad[m] + h[m] %changing lb has no effect
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'pyr(c)','nad(m)','h(m)'},[-1 -1; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_nad(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr -> nad[m] + h[m] (with RPMI medium)';
    k = k +1;clear FBA
    %% pyr[c] -> accoa[m] + co2[c] + nadh[m] %changing lb has no effect
    model = modelOri;
    [model] = addSinkReactions(model,{'pyr(c)','accoa(m)','nadh(m)','co2(c)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    model.lb(ismember(model.rxns,'sink_nad(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_nad(c)'))=1;
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr[c] -> accoa[m] + co2(c) + nadh[m]';
    k = k +1;clear FBA
    %% pyr<>ala-L
    model = modelOri;
    [model] = addSinkReactions(model,{'pyr(c)','ala-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr(c) -> ala-L(c), 1';
    k = k +1;clear FBA
    model = modelOri;
    [model] = addSinkReactions(model,{'ala-L(c)','pyr(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_ala_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_ala_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr(c) -> ala-L(c), 2';
    k = k +1;clear FBA
    %% R_group
    %% s2l2fn2m2masn[l] -> man[l] + acgam[l]
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'s2l2fn2m2masn(l)','man(l)','acgam(l)'},[-1 -1; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_man(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 's2l2fn2m2masn(l) -> man[l] + acgam[l] (with RPMI medium)';
    k = k +1;clear FBA
    %% Ser/Thr[g] + udpacgal[g] -> core2[g] %changing lb has no effect
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    model = changeRxnBounds(model,'GALNTg',0.1,'l');
    [model] = addSinkReactions(model,{'Ser/Thr(g)';'udpacgal(g)';'core2(g)'},[-1 -1; -1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_core2(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser/Thr[g] + udpacgal[g] -> core2[g] - via GALNTg and DM_core4[g] (with RPMI medium)';
    k = k +1;clear FBA
    %% Ser/Thr[g] + udpacgal[g] -> core4[g] %changing lb has no effect
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    model = changeRxnBounds(model,'GALNTg',0.1,'l');
    [model] = addSinkReactions(model,{'Ser/Thr(g)';'udpacgal(g)';'core4(g)'},[-1 -1; -1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_core4(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser/Thr[g] + udpacgal[g] -> core4[g] - via GALNTg and DM_core4[g] (with RPMI medium)';
    k = k +1;clear FBA
    %% Ser/Thr[g] + udpacgal[g] -> dsTn_antigen[g] % dsTn_antigen does not exists
    % model = modelOri;
    % [model] = addSinkReactions(model,{'Ser/Thr(g)','udpacgal(g)','dsTn_antigen(g)'},[-1 -1;-1 -1; 0 100]);
    % model.c(ismember(model.rxns,'sink_dsTn_antigen(g)'))=1;
    %   FBA = optimizeCbModel(model,'max','zero');
    % TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    % TestSolutionName{k,1} = 'Ser/Thr[g] + udpacgal[g] -> dsTn_antigen[g]';
    % k = k +1;clear FBA
    %% Ser/Thr[g] + udpacgal[g] -> Tn_antigen[g] % dsTn_antigen does not exists
    % - I used Tn_antigen instead %changing lb has no effect
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'Ser/Thr(g)','udpacgal(g)','Tn_antigen(g)'},[-1 -1;-1 -1; 0 100]);
    % model.c(ismember(model.rxns,'sink_Tn_antigen(g)'))=1;
    if any(strcmp('GALNTg',model.rxns))
        model = changeObjective(model, 'GALNTg',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser/Thr[g] + udpacgal[g] -> Tn_antigen[g] - via GALNTg (with RPMI medium)';
    k = k +1;clear FBA

    %% Ser/Thr[g] + udpacgal[g] -> sTn_antigen[g] %changing lb has no effect
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    if any(strcmp('GALNTg',model.rxns))
        model = changeRxnBounds(model,'GALNTg',0.1,'l');
        [model] = addSinkReactions(model,{'Ser/Thr(g)','udpacgal(g)','sTn_antigen(g)'},[-1 -1;-1 -1; 0 100]);
        if (rxnsInModel(1) >-1) % reaction exits already in model
            model=changeObjective(model,model.rxns(rxnsInModel(1),1));
        else
            model=changeObjective(model,'sink_sTn_antigen(g)',1);
        end
        if find(model.c)>0
            FBA = optimizeCbModel(model,'max','zero');
            TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
        else
            TestSolution(k,1) = NaN;
        end
        TestSolutionName{k,1} = 'Ser/Thr[g] + udpacgal[g] -> sTn_antigen[g] - via GALNTg and DM_sTn_antigen(g) (with RPMI medium)';
        k = k +1;clear FBA
    else
        TestSolution(k,1) = NaN;
        TestSolutionName{k,1} = 'Ser/Thr[g] + udpacgal[g] -> sTn_antigen[g] - via GALNTg and DM_sTn_antigen(g)';
        k = k +1;clear FBA
    end
    %% Ser-Gly/Ala-X-Gly[er] -> cs_pre[g]
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','cs_pre(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cs_pre(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> cs_pre[g]';
    k = k +1;clear FBA
    %% Ser-Gly/Ala-X-Gly[er] -> cspg_a[g]
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','cspg_a(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cspg_a(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> cspg_a[g]';
    k = k +1;clear FBA
    %% Ser-Gly/Ala-X-Gly[er] -> cspg_c[g]
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','cspg_c(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cspg_c(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> cspg_c[g]';
    k = k +1;clear FBA
    %% Ser-Gly/Ala-X-Gly[er] -> cspg_d[g]
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','cspg_d(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cspg_d(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> cspg_d[g]';
    k = k +1;clear FBA
    %% Ser-Gly/Ala-X-Gly[er] -> cspg_e[g]
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','cspg_e(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cspg_e(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> cspg_e[g]';
    k = k +1;clear FBA
    %% Ser-Gly/Ala-X-Gly[er] -> hspg[g]
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','hspg(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_hspg(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> hspg[g]';
    k = k +1;clear FBA
    %% Ser-Gly/Ala-X-Ser[er] -> cspg_b[g]
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','cspg_b(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cspg_b(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> cspg_b[g]';
    k = k +1;clear FBA
    %% ser-L -> cys-L
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ser-L(c)','cys-L(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_ser_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_ser_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_cys-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_cys_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ser-L(c) -> cys-L(c)';
    k = k +1;clear FBA
    %% so4 -> PAPS
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'so4(c)','paps(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_paps(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'so4(c) -> paps(c)';
    k = k +1;clear FBA
    %% spmd -> sprm
    model = modelOri;
    [model,rxnsInModel] = addSinkReactions(model,{'spmd(c)','sprm(c)'},[-1 -1; 0 100]);
    %  model.c(ismember(model.rxns,'sink_sprm(c)'))=1;
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_sprm(c)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'spmd(c) -> sprm(c)';
    k = k +1;clear FBA
    %% srtn -> f5hoxkyn
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    [model] = addSinkReactions(model,{'srtn(c)','f5hoxkyn(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'DM_srtn(c)'))=-1;
    model.ub(ismember(model.rxns,'DM_srtn(c)'))=-1;
    model.c(ismember(model.rxns,'sink_f5hoxkyn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'srtn(c) -> f5hoxkyn(c)';
    k = k +1;clear FBA
    %% srtn -> fna5moxam
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    [model] = addSinkReactions(model,{'srtn(c)','fna5moxam(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'DM_srtn(c)'))=-1;
    model.ub(ismember(model.rxns,'DM_srtn(c)'))=-1;
    model.c(ismember(model.rxns,'sink_fna5moxam(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'srtn(c) -> fna5moxam(c)';
    k = k +1;clear FBA
    %% srtn -> nmthsrtn
    model = modelOri;
    [model] = addSinkReactions(model,{'srtn(c)','nmthsrtn(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'DM_srtn(c)'))=-1;
    model.ub(ismember(model.rxns,'DM_srtn(c)'))=-1;
    model.c(ismember(model.rxns,'sink_nmthsrtn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'srtn(c) -> nmthsrtn(c)';
    k = k +1;clear FBA
    %% strch1[e] -> glc[e]
    model = modelOri;
    model = changeRxnBounds(model,'EX_strch1(e)',-1,'l');
    model = changeRxnBounds(model,'EX_strch1(e)',-1,'u');
    model = changeRxnBounds(model,'EX_glc(e)',0,'l');
    model = changeRxnBounds(model,'EX_glc(e)',1000,'u');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    if any(strcmp('AMY1e',model.rxns))
        model.c(ismember(model.rxns,'AMY1e'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'strch1(e) -> glc-D(e) via AMY1e';
    k = k +1;clear FBA

    %% succoa[m] -> oaa[m]
    model = modelOri;
    [model] = addSinkReactions(model,{'succoa(m)','oaa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_oaa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'succoa(m) -> oaa(m)';
    k = k +1;clear FBA
    %% taur(x) -> tchola(x)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'taur(x)','tchola(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_tchola(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'taur(x) -> tchola(x)';
    k = k +1;clear FBA
    %% thcholstoic(x) -> gchola(x)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'thcholstoic(x)','gchola(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gchola(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thcholstoic(x) -> gchola(x)';
    k = k +1;clear FBA
    %% thcholstoic(x) -> tchola(x)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'thcholstoic(x)','tchola(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_tchola(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thcholstoic(x) -> tchola(x)';
    k = k +1;clear FBA
    %% thcholstoich(x) -> tchola(x) % thcholstoich does not exist in model
    % model = modelOri;
    % [model] = addSinkReactions(model,{'thcholstoich(x)','tchola(x)'},[-1 -1; 0 100]);
    % model.c(ismember(model.rxns,'sink_tchola(x)'))=1;
    %   FBA = optimizeCbModel(model,'max','zero');
    % TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    % TestSolutionName{k,1} = 'thcholstoich(x) -> tchola(x)';
    % k = k +1;clear FBA
    %% thr-L -> ppcoa
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'trp-L(c)','ppcoa(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    model.c(ismember(model.rxns,'sink_ppcoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> ppcoa(c)';
    k = k +1;clear FBA
    %% trp-L -> accoa
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'trp-L(c)','accoa(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    model.c(ismember(model.rxns,'sink_accoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> accoa(c)';
    k = k +1;clear FBA
    %% trp-L -> anth
    model = modelOri;
    [model,rxnsInModel] = addSinkReactions(model,{'trp-L(c)','anth(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_anth(c)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> anth(c)';
    k = k +1;clear FBA
    %% trp-L -> id3acald
    model = modelOri;
    [model] = addSinkReactions(model,{'trp-L(c)','id3acald(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_id3acald(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> id3acald(c)';
    k = k +1;clear FBA
    %% trp-L -> kynate
    model = modelOri;
    [model] = addSinkReactions(model,{'trp-L(c)','kynate(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_kynate(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> kynate(c)';
    k = k +1;clear FBA
    %% trp-L -> melatn
    model = modelOri;
    [model] = addSinkReactions(model,{'trp-L(c)','melatn(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_melatn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> melatn(c)';
    k = k +1;clear FBA
    %% trp-L -> melatn
    model = modelOri;
    [model] = addSinkReactions(model,{'trp-L(c)','Lfmkynr(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_Lfmkynr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> Lfmkynr(c)';
    k = k +1;clear FBA
    %% trp-L -> melatn
    model = modelOri;
    [model] = addSinkReactions(model,{'trp-L(c)','Lkynr(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_Lkynr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> Lkynr(c)';
    k = k +1;clear FBA
    %% trp-L -> melatn
    model = modelOri;
    [model] = addSinkReactions(model,{'trp-L(c)','nformanth(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_nformanth(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> nformanth(c)';
    model.lb(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    k = k +1;clear FBA
    %% srtn(c) -> 5moxact(c)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    [model] = addSinkReactions(model,{'srtn(c)','5moxact(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'DM_srtn(c)'))=-1;
    model.ub(ismember(model.rxns,'DM_srtn(c)'))=-1;
    model.c(ismember(model.rxns,'sink_5moxact(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'srtn(c) -> 5moxact(c)';
    k = k +1;clear FBA
    %% srtn(c) -> 6hoxmelatn(c)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    [model] = addSinkReactions(model,{'srtn(c)','6hoxmelatn(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'DM_srtn(c)'))=-1;
    model.ub(ismember(model.rxns,'DM_srtn(c)'))=-1;
    model.c(ismember(model.rxns,'sink_6hoxmelatn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'srtn(c) -> 6hoxmelatn(c)';
    k = k +1;clear FBA
    %% trp-L -> quln
    model = modelOri;
    [model] = addSinkReactions(model,{'trp-L(c)','quln(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_quln(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> quln(c)';
    k = k +1;clear FBA
    %% trp-L -> srtn TODO - this doesn't make sense, since it could use the sink to fill the demand reaction
    model = modelOri;
    [model] = addSinkReactions(model,{'trp-L(c)','srtn(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_trp_L(c)'))=-1;
    model.c(ismember(model.rxns,'DM_srtn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> srtn(c)';
    k = k +1;clear FBA
    %% Tyr-ggn -> glygn2
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Tyr-ggn(c)','glygn2(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_Tyr-ggn(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_Tyr-ggn(c)'))=-1;
    model.c(ismember(model.rxns,'sink_glygn2(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Tyr-ggn(c) -> glygn2(c)';
    k = k +1;clear FBA
    %% tyr-L -> 34hpp
    model = modelOri;
    [model] = addSinkReactions(model,{'tyr-L(c)','34hpp(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_34hpp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> 34hpp(c)';
    k = k +1;clear FBA
    %% tyr-L -> 4hphac
    model = modelOri;
    [model] = addSinkReactions(model,{'tyr-L(c)','4hphac(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_4hphac(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> 4hphac(c)';
    k = k +1;clear FBA
    %% tyr-L -> adrnl
    model = modelOri;
    [model] = addSinkReactions(model,{'tyr-L(c)','adrnl(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_adrnl(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> adrnl(c)';
    k = k +1;clear FBA
    %% tyr-L -> dopa
    model = modelOri;
    [model] = addSinkReactions(model,{'tyr-L(c)','dopa(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_dopa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> dopa(c)';
    k = k +1;clear FBA
    %% tyr-L -> fum + acac
    model = modelOri;
    [model] = addSinkReactions(model,{'tyr-L(c)','fum(c)','acac(c)'},[-1 -1; 0.1 100; 0.1 100]);
    model.lb(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_fum(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> fum(c) + acac(c)';
    k = k +1;clear FBA
    %% tyr-L -> melanin
    model = modelOri;
    [model,rxnsInModel] = addSinkReactions(model,{'tyr-L(c)','melanin(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_melanin(c)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> melanin(c)';
    k = k +1;clear FBA
    %% tyr-L -> nrpphr
    model = modelOri;
    [model] = addSinkReactions(model,{'tyr-L(c)','nrpphr(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_tyr_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_nrpphr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> nrpphr(c)';
    k = k +1;clear FBA
    %% uacgam + udpglcur -> ha[e] %changing lb has no effect
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'uacgam(c)','udpglcur(c)','ha(e)'},[-1 -1; -1 -1;0 100]);
    %model.c(ismember(model.rxns,'sink_ha(c)'))=1;
    if any(strcmp('HAS2',model.rxns))
        model=changeObjective(model,'HAS2',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} =  'uacgamv(c) + udpglcur(c) -> ha[e] - via HAS2';
    k = k +1;clear FBA

    %% uacgam -> m8masn[r]
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'uacgam(c)','m8masn(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_m8masn(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'uacgam(c) -> m8masn(r)';
    k = k +1;clear FBA
    %% udpglcur -> xu5p-D
    model = modelOri;
    [model] = addSinkReactions(model,{'udpglcur(c)','xu5p-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_xu5p-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'udpglcur(c) -> xu5p-D(c)';
    k = k +1;clear FBA
    %% ura -> ala-B
    model = modelOri;
    [model] = addSinkReactions(model,{'ura(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ura(c) -> ala-B(c)';
    k = k +1;clear FBA
    %% val-L -> 3aib
    model = modelOri;
    [model] = addSinkReactions(model,{'val-L(c)','3aib(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_val_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_val_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_3aib(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'val-L(c) -> 3aib(c)';
    k = k +1;clear FBA
    %% val-L -> succoa
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'val-L(c)','succoa(m)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_val_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_val_L(c)'))=-1;
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    model.c(ismember(model.rxns,'sink_succoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'val-L(c) -> succoa(m)';
    k = k +1;clear FBA
    %% xoltriol(m) -> thcholstoic(m)
    model = modelOri;
    [model] = addSinkReactions(model,{'xoltriol(m)','thcholstoic(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_thcholstoic(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'xoltriol(m) -> thcholstoic(m)';
    k = k +1;clear FBA
    %% xylu-D -> glyclt
    model = modelOri;
    [model] = addSinkReactions(model,{'xylu-D(c)','glyclt(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glyclt(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'xylu-D(c) -> glyclt(c)';
    k = k +1;clear FBA
end

%% Test for IEC ori  - works only for models with 'u'=lumen compartments
if strcmp(test,'IECOri')
    % 1) glucose to lactate conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln_L(u)',0,'b');
    model=changeObjective(model,'EX_lac-L(e)');
    %FBA=optimizeCbModel(model,'min')
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glucose to lactate conversion';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)]; end 
    k = k +1;clear FBA

    % 2); glutamine to glucose conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_malt(u)',0,'b');
    model=changeRxnBounds(model,'EX_STRCH1(u)',0,'b');
    model=changeRxnBounds(model,'EX_strch2(u)',0,'b');
    model=changeRxnBounds(model,'EX_SUCR(u)',0,'b');
    model=changeObjective(model,'GLUNm');
    FBA=optimizeCbModel(model,'max');
    model=changeObjective(model,'ASPTAm');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'glutamine to glucose conversion - ASPTAm';
    k = k +1;clear FBA
    model=changeObjective(model,'FUM');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to glucose conversion - FUM';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)]; end 
    k = k +1;clear FBA
    model=changeObjective(model,'MDH');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to glucose conversion - MDH';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)]; end 
    k = k +1;clear FBA
    model=changeObjective(model,'G6PPer');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'glutamine to glucose conversion - G6PPer';
    k = k +1;clear FBA

    % 3); glutamine to proline conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_PRO-L(u)',0,'b');
    model=changeObjective(model,'P5CRm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'glutamine to proline conversion - P5CRm';
    k = k +1;clear FBA
    model=changeObjective(model,'P5CRxm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'glutamine to proline conversion - P5CRxm';
    k = k +1;clear FBA

    % 4); glutamine to ornithine conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_ORN(U)',0,'b');
    model=changeObjective(model,'ORNTArm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'glutamine to ornithine conversion - ORNTArm';
    k = k +1;clear FBA

    % 5); glutamine to citrulline converion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeObjective(model,'OCBTm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'glutamine to citrulline converion - OCBTm';
    k = k +1;clear FBA

    % 6); glutamine to lactate
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_malt(u)',0,'b');
    model=changeRxnBounds(model,'EX_STRCH1(u)',0,'b');
    model=changeRxnBounds(model,'EX_strch2(u)',0,'b');
    model=changeRxnBounds(model,'EX_SUCR(u)',0,'b');
    model=changeRxnBounds(model,'EX_LAC-L(u)',0,'b');
    model=changeObjective(model,'LDH_L');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'glutamine to lactate - LDH_L';
    k = k +1;clear FBA

    % 7); glutamine to aspartate
    model=modelOri;
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_ASP-L(u)',0,'b');
    model=changeRxnBounds(model,'EX_malt(u)',0,'b');
    model=changeRxnBounds(model,'EX_STRCH1(u)',0,'b');
    model=changeRxnBounds(model,'EX_strch2(u)',0,'b');
    model=changeRxnBounds(model,'EX_SUCR(u)',0,'b');
    model=changeObjective(model,'ASPTA');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'glutamine to aspartate - ASPTA';
    k = k +1;clear FBA

    % 8); glutamine to co2
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_GLU-L(u)',0,'b');
    model=changeRxnBounds(model,'EX_malt(u)',0,'b');
    model=changeRxnBounds(model,'EX_STRCH1(u)',0,'b');
    model=changeRxnBounds(model,'EX_strch2(u)',0,'b');
    model=changeRxnBounds(model,'EX_SUCR(u)',0,'b');
    model=changeObjective(model,'AKGDm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'glutamine to co2 - AKGDm';
    k = k +1;clear FBA

    % 9); glutamine to ammonia
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_GLU-L(u)',0,'b');
    model=changeObjective(model,'GLUNm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'glutamine to ammonia - GLUNm';
    k = k +1;clear FBA

    % 10); putriscine to methionine (depends on oxygen uptake);
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_GLU-L(u)',0,'b');
    model=changeRxnBounds(model,'EX_MET-L(u)',0,'b');
    model=changeRxnBounds(model,'EX_met_L(e)',0,'b');
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'UNK2');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'putriscine to methionine (depends on oxygen uptake) - UNK2';
    k = k +1;clear FBA

    % 11); basolateral secretion of alanine
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_GLU-L(u)',0,'b');
    model=changeRxnBounds(model,'EX_ala_L(u)',0,'b');
    model=changeObjective(model,'EX_ala_L(e)');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'basolateral secretion of alanine';
    k = k +1;clear FBA

    % 12); basolateral secretion of lactate
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeObjective(model,'EX_lac-L(e)');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'basolateral secretion of lactate';
    k = k +1;clear FBA

    % 13);synthesis of arginine from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_ARG-L(u)',0,'b');
    model=changeRxnBounds(model,'EX_arg_L(e)',0,'b');
    model=changeObjective(model,'ARGSL');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'synthesis of arginine from glutamine - ARGSL';
    k = k +1;clear FBA

    % 14);synthesis of proline from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_PRO-L(u)',0,'b');
    model=changeRxnBounds(model,'EX_pro-L(e)',0,'b');
    model=changeObjective(model,'P5CR');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'synthesis of proline from glutamine - P5CR';
    k = k +1;clear FBA
    model=changeObjective(model,'P5CRm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'synthesis of proline from glutamine - P5CRm';
    k = k +1;clear FBA
    model=changeObjective(model,'P5CRxm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'synthesis of proline from glutamine - P5CRxm';
    k = k +1;clear FBA

    % 15); synthesis of alanine from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_glc(e)',0,'b');
    model=changeRxnBounds(model,'EX_GLU-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_SUCR(e)',0,'b');
    model=changeRxnBounds(model,'EX_malt(e)',0,'b');
    model=changeRxnBounds(model,'EX_STRCH1(e)',0,'b');
    model=changeRxnBounds(model,'EX_strch2(e)',0,'b');
    model=changeRxnBounds(model,'EX_ala_L(e)',0,'b');
    model=changeObjective(model,'ALATA_L');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'synthesis of alanine from glutamine - ALATA_L';
    k = k +1;clear FBA

    % 16); basolateral secretion of proline
    model=modelOri;
    model=changeRxnBounds(model,'EX_PRO-L(u)',0,'b');
    model=changeObjective(model,'EX_pro-L(e)');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'basolateral secretion of proline';
    k = k +1;clear FBA

    % 17); basolateral secretion of arginine
    model=modelOri;
    model=changeRxnBounds(model,'EX_ARG-L(u)',0,'b');
    model=changeObjective(model,'EX_arg_L(e)');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'basolateral secretion of arginine';
    k = k +1;clear FBA

    % 18); basolateral secretion of ornithine
    model=modelOri;
    model=changeRxnBounds(model,'EX_ORN(U)',0,'b');
    model=changeObjective(model,'EX_orn(e)');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'basolateral secretion of ornithine';
    k = k +1;clear FBA

    % 19); synthesis of spermine from ornithine
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'SPRMS');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'synthesis of spermine from ornithine - SPRMS';
    k = k +1;clear FBA

    % 20);synthesis of spermidine from ornithine
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'SPMS');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'synthesis of spermidine from ornithine - SPMS';
    k = k +1;clear FBA

    % 21); synthesis of nitric oxide from arginine
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'NOS2');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'synthesis of nitric oxide from arginine - NOS2';
    k = k +1;clear FBA

    % 22); synthesis of cholesterol
    model=modelOri;
    model=changeRxnBounds(model,'EX_chsterol(u)',0,'b');
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'DSREDUCr');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'synthesis of cholesterol - DSREDUCr';
    k = k +1;clear FBA

    % 23); denovo purine synthesis
    model=modelOri;
    model=changeObjective(model,'ADSL1');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'de novo purine synthesis - ADSL1';
    k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'GMPS2');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'de novo purine synthesis - GMPS2';
    k = k +1;clear FBA

    % 24); salvage of purine bases
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'ADPT');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'salvage of purine bases - ADPT';
    k = k +1;clear FBA
    model=changeObjective(model,'GUAPRT');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'salvage of purine bases - GUAPRT';
    k = k +1;clear FBA
    model=changeObjective(model,'HXPRT');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'salvage of purine bases - HXPRT';
    k = k +1;clear FBA

    % 25); purine catabolism
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'XAOx');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'purine catabolism - XAOx';
    k = k +1;clear FBA

    % 26); pyrimidine synthesis (check for both with and without bicarbonate uptake);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_hco3(e)',-1,'l');
    model=changeObjective(model,'TMDS');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'pyrimidine synthesis (with hco3 uptake) - TMDS';
    k = k +1;clear FBA
    model=changeObjective(model,'CTPS2');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'pyrimidine synthesis (with hco3 uptake) - CTPS2';
    k = k +1;clear FBA

    % 27); pyrimidine catabolism
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_hco3(e)',-1,'l');
    model=changeObjective(model,'UPPN');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'pyrimidine catabolism - UPPN';
    k = k +1;clear FBA
    model=changeObjective(model,'BUP2');
    FBA=optimizeCbModel(model);
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'pyrimidine catabolism - BUP2';
    k = k +1;clear FBA

    % 28); fructose to glucose conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_SUCR(u)',0,'b');
    model=changeRxnBounds(model,'EX_malt(u)',0,'b');
    model=changeRxnBounds(model,'EX_STRCH1(u)',0,'b');
    model=changeRxnBounds(model,'EX_strch2(u)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeObjective(model,'TRIOK');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'fructose to glucose conversion - TRIOK';
    k = k +1;clear FBA

    % 29); uptake and secretion of cholic acid
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_cholate(u)',-1,'l');
    model=changeObjective(model,'CHOLATEt2u');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'uptake and secretion of cholic acid - CHOLATEt2u'; % SHOULD THIS BE MIN?
    k = k +1;clear FBA
    model=changeObjective(model,'CHOLATEt3');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'uptake and secretion of cholic acid - CHOLATEt3';
    k = k +1;clear FBA

    % 30); Uptake and secretion of glycocholate
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_GCHOLA(u)',-1,'l');
    model=changeObjective(model,'GCHOLAt2u');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'uptake and secretion of cholic glycocholate - GCHOLAt2u';
    k = k +1;clear FBA
    model=changeObjective(model,'GCHOLAt3');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'uptake and secretion of cholic glycocholate - GCHOLAt3';
    k = k +1;clear FBA

    % 31); Uptake and secretion of tauro-cholate
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_TCHOLA(u)',-1,'l');
    model=changeObjective(model,'TCHOLAt2u');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'uptake and secretion of tauro-cholate - TCHOLAt2u';
    k = k +1;clear FBA
    model=changeObjective(model,'TCHOLAt3');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'uptake and secretion of tauro-cholate - TCHOLAt3';
    k = k +1;clear FBA

    % 32); Synthesis of fructose-6-phosphate from erythrose-4-phosphate (HMP shunt);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'TKT2');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Synthesis of fructose-6-phosphate from erythrose-4-phosphate (HMP shunt) - TKT2';
    k = k +1;clear FBA

    % 33); Malate to pyruvate (malic enzyme);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'ME2');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Malate to pyruvate (malic enzyme) - ME2';
    k = k +1;clear FBA
    model=changeObjective(model,'ME2m');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Malate to pyruvate (malic enzyme) - ME2m';
    k = k +1;clear FBA

    % 34); Synthesis of urea (urea cycle);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_arg_L(e)',-1,'l');
    model=changeObjective(model,'ARGN');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Synthesis of urea (urea cycle) - ARGN';
    k = k +1;clear FBA

    % 35); Cysteine to pyruvate
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_cys-L(u)',-1,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_SUCR(u)',0,'b');
    model=changeRxnBounds(model,'EX_malt(u)',0,'b');
    model=changeRxnBounds(model,'EX_STRCH1(u)',0,'b');
    model=changeRxnBounds(model,'EX_strch2(u)',0,'b');
    model=changeObjective(model,'3SPYRSP');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Cysteine to pyruvate - 3SPYRSP';
    k = k +1;clear FBA

    % 36); Methionine to cysteine  (check for dependancy over pe_hs);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_pe_hs(u)',-1,'l');
    model=changeRxnBounds(model,'EX_cys_L(u)',0,'b');
    model=changeObjective(model,'CYSTGL');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Methionine to cysteine - CYSTGL';
    k = k +1;clear FBA

    % 37); Synthesis of triacylglycerol (TAG reformation); (check for dependancy over dag_hs and RTOTAL3);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_dag_hs(u)',-1,'l');
    model=changeRxnBounds(model,'EX_RTOTAL3(u)',-1,'l');
    model=changeRxnBounds(model,'EX_TAG_HS(u)',0,'b');
    model=changeObjective(model,'DGAT');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Synthesis of triacylglycerol (TAG reformation) - DGAT';
    k = k +1;clear FBA

    % 38); Phosphatidylcholine synthesis (check for dependancy over pe_hs);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_pe_hs(u)',-1,'l');
    model=changeRxnBounds(model,'EX_PCHOL_HS(u)',0,'b');
    model=changeObjective(model,'PETOHMm_hs');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Phosphatidylcholine synthesis - PETOHMm_hs';
    k = k +1;clear FBA

    % 39); Synthesis of FMN from riboflavin
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_fmn(u)',0,'b');
    model=changeObjective(model,'RBFK');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Synthesis of FMN from riboflavin - RBFK';
    k = k +1;clear FBA

    % 40); synthesis of FAD from riboflavin
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_FAD(u)',0,'b');
    model=changeObjective(model,'FMNAT');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'synthesis of FAD from riboflavin - FMNAT';
    k = k +1;clear FBA

    % 41); Synthesis of 5-methyl-tetrahydrofolate from folic acid
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_5mthf(u)',0,'b');
    model=changeObjective(model,'MTHFR3');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Synthesis of 5-methyl-tetrahydrofolate from folic acid - MTHFR3';
    k = k +1;clear FBA

    % 42); Putriscine to GABA
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_4ABUT(u)',0,'b');
    model=changeObjective(model,'ABUTD');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Putriscine to GABA - ABUTD';
    k = k +1;clear FBA

    % 43); Superoxide dismutase
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'SPODMm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Superoxide dismutase - SPODMm';
    k = k +1;clear FBA

    % 44); Availability of bicarbonate from Carbonic anhydrase reaction
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'H2CO3Dm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Availability of bicarbonate from Carbonic anhydrase reaction - H2CO3Dm';
    k = k +1;clear FBA

    % 45); Regeneration of citrate (TCA cycle);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'CSm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Regeneration of citrate (TCA cycle) - CSm';
    k = k +1;clear FBA

    % 46); Histidine to FORGLU
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'IZPN');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'production of forglu from histidine - IZPN';
    k = k +1;clear FBA

    % 47); binding of guar gum fiber to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_GUM(u)',-1,'l');
    model=changeRxnBounds(model,'EX_GCHOLA(u)',-1,'l');
    model=changeObjective(model,'EX_GUMGCHOL(u)');
    FBA=optimizeCbModel(model,'min');
    %FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'binding of guar gum fiber to bile acids - EX_GUMGCHOL(e)';
    k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_TCHOLA(u)',-1,'l');
    model=changeObjective(model,'GUMTCHOLe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'binding of guar gum fiber to bile acids - GUMTCHOLe';
    k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_DCHAC(u)',-1,'l');
    model=changeObjective(model,'GUMDCHAe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'binding of guar gum fiber to bile acids - GUMDCHAe';
    k = k +1;clear FBA

    % 48); binding of psyllium fiber to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_PSYL(u)',-1,'l');
    model=changeRxnBounds(model,'EX_GCHOLA(u)',-1,'l');
    model=changeObjective(model,'PSYGCHe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'binding of psyllium fiber to bile acids - PSYGCHe';
    k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_TCHOLA(u)',-1,'l');
    model=changeObjective(model,'PSYTCHe');
    FBA=optimizeCbModel(model,'min');
    %FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'binding of psyllium fiber to bile acids - PSYTCHe';
    k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_TDECHOLA(u)',-1,'l');
    model=changeObjective(model,'PSYTDECHe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'binding of psyllium fiber to bile acids - PSYTDECHe';
    k = k +1;clear FBA

    % 49);binding to beta glucan fibers to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_BGLC(u)',-1,'l');
    model=changeRxnBounds(model,'EX_GCHOLA(u)',-1,'l');
    model=changeObjective(model,'BGLUGCHe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'binding to beta glucan fibers to bile acids - BGLUGCHe';
    k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_TCHOLA(u)',-1,'l');
    model=changeObjective(model,'BGLUTCHLe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'binding to beta glucan fibers to bile acids - BGLUTCHLe';
    k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_TDECHOLA(u)',-1,'l');
    model=changeObjective(model,'BGLUTDECHOe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'binding to beta glucan fibers to bile acids - BGLUTDECHOe';
    k = k +1;clear FBA

    % 50); binding of pectin fiber to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_PECT(u)',-1,'l');
    model=changeRxnBounds(model,'EX_GCHOLA(u)',-1,'l');
    model=changeObjective(model,'PECGCHLe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'binding of pectin fiber to bile acids - PECGCHLe';
    k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_TCHOLA(u)',-1,'l');
    model=changeObjective(model,'PECTCHLe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'binding of pectin fiber to bile acids - PECTCHLe';
    k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_DCHAC(u)',-1,'l');
    model=changeObjective(model,'PECDCHe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'binding of pectin fiber to bile acids - PECDCHe';
    k = k +1;clear FBA

    % 52); heme synthesis
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'FCLTm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'heme synthesis - FCLTm';
    k = k +1;clear FBA

    % 53); heme degradation
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'HOXG');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'heme degradation - HOXG';
    k = k +1;clear FBA
end

%% metabolic tasks based on Enterocyte model - without original ('u')
% compartment I deleted the last argument in changeObjective from here
% onwards (SS)
if strcmp(test,'IEC') || strcmp(test,'all')|| strcmp(test,'Harvey')
    %% glucose to lactate conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_glc(e)',-1,'b');
    if any(strcmp('EX_lac-L(e)',model.rxns))
        model=changeObjective(model,'EX_lac-L(e)',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glucose to lactate conversion';
    k = k +1;clear FBA

    %%  glutamine to glucose conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model=changeRxnBounds(model,'EX_glc(e)',0,'b');
    model=changeRxnBounds(model,'EX_malt(e)',0,'b');
    model=changeRxnBounds(model,'EX_strch1(e)',0,'b');
    model=changeRxnBounds(model,'EX_strch2(e)',0,'b');
    model=changeRxnBounds(model,'EX_sucr(e)',0,'b');

    if any(strcmp('GLUNm',model.rxns))
        model=changeObjective(model,'GLUNm',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to glucose conversion - GLUNm';
    k = k +1;clear FBA

    %% glutamine to glucose conversion - ASPTAm
    if any(strcmp('ASPTAm',model.rxns))
        model=changeObjective(model,'ASPTAm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to glucose conversion - ASPTAm';
    k = k +1;clear FBA

    %% 'glutamine to glucose conversion - FUM'
    if any(strcmp('FUM',model.rxns))
        model=changeObjective(model,'FUM',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to glucose conversion - FUM';
    k = k +1;clear FBA
    %% glutamine to glucose conversion - MDH
    if any(strcmp('MDH',model.rxns))
        model=changeObjective(model,'MDH',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to glucose conversion - MDH';
    k = k +1;clear FBA
    %% glutamine to glucose conversion - G6PPer
    if any(strcmp('G6PPer',model.rxns))
        model=changeObjective(model,'G6PPer',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to glucose conversion - G6PPer';
    k = k +1;clear FBA
    %% glutamine to proline conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model=changeRxnBounds(model,'EX_glc(e)',0,'b');
    model=changeRxnBounds(model,'EX_pro-L(e)',0,'b');

    if any(strcmp('P5CRm',model.rxns))
        model=changeObjective(model,'P5CRm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to proline conversion - P5CRm';
    k = k +1;clear FBA
    %% glutamine to proline conversion - P5CRxm
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model=changeRxnBounds(model,'EX_glc(e)',0,'b');
    model=changeRxnBounds(model,'EX_pro-L(e)',0,'b');

    if any(strcmp('P5CRxm',model.rxns))
        model=changeObjective(model,'P5CRxm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to proline conversion - P5CRxm';
    k = k +1;clear FBA


    %% glutamine to ornithine conversion
    model=modelOri;

    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'l');
    if any(strcmp('ORNTArm',model.rxns))
        model=changeObjective(model,'ORNTArm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to ornithine conversion - ORNTArm';
    k = k +1;clear FBA

    %% glutamine to citrulline converion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    if any(strcmp('OCBTm',model.rxns))
        model=changeObjective(model,'OCBTm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to citrulline converion - OCBTm';
    k = k +1;clear FBA

    %% glutamine to lactate
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    if any(strcmp('LDH_L',model.rxns))
        model=changeObjective(model,'LDH_L',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to lactate - LDH_L';
    k = k +1;clear FBA

    %% glutamine to aspartate
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    if any(strcmp('ASPTA',model.rxns))
        model=changeObjective(model,'ASPTA',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to aspartate - ASPTA';
    k = k +1;clear FBA

    %% glutamine to co2
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    if any(strcmp('AKGDm',model.rxns))
        model=changeObjective(model,'AKGDm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to co2 - AKGDm';
    k = k +1;clear FBA
    %% glutamine to ammonia
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    if any(strcmp('GLUNm',model.rxns))
        model=changeObjective(model,'GLUNm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to ammonia - GLUNm';
    k = k +1;clear FBA

    %% putriscine to methionine (depends on oxygen uptake);
    model=modelOri;
    model=changeRxnBounds(model,'EX_ptrc(e)',-1,'b');
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    if any(strcmp('UNK2',model.rxns))
        model=changeObjective(model,'UNK2',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'putriscine to methionine (depends on oxygen uptake) - UNK2';
    k = k +1;clear FBA

    %%  secretion of alanine
    model=modelOri;

    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('EX_ala_L(e)',model.rxns))
        model=changeObjective(model,'EX_ala_L(e)',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'secretion of alanine';
    k = k +1;clear FBA

    %%  secretion of lactate
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('EX_lac-L(e)',model.rxns))
        model=changeObjective(model,'EX_lac-L(e)');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'secretion of lactate';
    k = k +1;clear FBA

    %% synthesis of arginine from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('ARGSL',model.rxns))
        model=changeObjective(model,'ARGSL',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of arginine from glutamine - ARGSL';
    k = k +1;clear FBA


    %% synthesis of proline from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('P5CR',model.rxns))
        model=changeObjective(model,'P5CR',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of proline from glutamine - P5CR';
    k = k +1;clear FBA
    %% synthesis of proline from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('P5CRm',model.rxns))
        model=changeObjective(model,'P5CRm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of proline from glutamine - P5CRm';
    k = k +1;clear FBA

    %% synthesis of proline from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('P5CRxm',model.rxns))
        model=changeObjective(model,'P5CRxm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of proline from glutamine - P5CRxm';
    k = k +1;clear FBA

    %% synthesis of alanine from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    if any(strcmp('ALATA_L',model.rxns))
        model=changeObjective(model,'ALATA_L',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of alanine from glutamine - ALATA_L';
    k = k +1;clear FBA

    %% basolateral secretion of proline
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('EX_pro-L(e)',model.rxns))
        model=changeObjective(model,'EX_pro-L(e)',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'secretion of proline';
    k = k +1;clear FBA


    %% basolateral secretion of arginine
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('EX_arg-L(e)',model.rxns))
        model=changeObjective(model,'EX_arg-L(e)',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'secretion of arginine';
    k = k +1;clear FBA

    %% basolateral secretion of ornithine
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('EX_orn(e)',model.rxns))
        model=changeObjective(model,'EX_orn(e)',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'secretion of ornithine';
    k = k +1;clear FBA


    %% synthesis of spermine from ornithine
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_orn(e)'))=-1;model.ub(ismember(model.rxns,'EX_orn(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('SPRMS',model.rxns))
        model=changeObjective(model,'SPRMS',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of spermine from ornithine - SPRMS';
    k = k +1;clear FBA


    %% synthesis of spermidine from ornithine
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_orn(e)'))=-1;model.ub(ismember(model.rxns,'EX_orn(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('SPMS',model.rxns))
        model=changeObjective(model,'SPMS',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of spermidine from ornithine - SPMS';
    k = k +1;clear FBA

    %% synthesis of nitric oxide from arginine
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_arg-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_arg-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('NOS2',model.rxns))
        model=changeObjective(model,'NOS2',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of nitric oxide from arginine - NOS2';
    k = k +1;clear FBA

    %%  synthesis of cholesterol
    model=modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    if any(strcmp('DSREDUCr',model.rxns))
        model=changeObjective(model,'DSREDUCr',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of cholesterol - DSREDUCr (with RPMI medium)';
    k = k +1;clear FBA

    %% denovo purine synthesis
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('ADSL1',model.rxns))
        model=changeObjective(model,'ADSL1',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'de novo purine synthesis - ADSL1';
    k = k +1;clear FBA

    %% de novo purine synthesis - GMPS2
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('GMPS2',model.rxns))
        model=changeObjective(model,'GMPS2');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'de novo purine synthesis - GMPS2';
    k = k +1;clear FBA

    %% salvage of purine bases
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('ADPT',model.rxns))
        model=changeObjective(model,'ADPT',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'salvage of purine bases - ADPT';
    k = k +1;clear FBA

    %% salvage of purine bases - GUAPRT
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('GUAPRT',model.rxns))
        model=changeObjective(model,'GUAPRT',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'salvage of purine bases - GUAPRT';
    k = k +1;clear FBA

    %% salvage of purine bases - HXPRT
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('HXPRT',model.rxns))
        model=changeObjective(model,'HXPRT',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'salvage of purine bases - HXPRT';
    k = k +1;clear FBA

    %% purine catabolism
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('XAOx',model.rxns))
        model=changeObjective(model,'XAOx',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'purine catabolism - XAOx';
    k = k +1;clear FBA

    %% pyrimidine synthesis (with hco3 uptake) - TMDS
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model=changeRxnBounds(model,'EX_hco3(e)',-1,'b');
    if any(strcmp('TMDS',model.rxns))
        model=changeObjective(model,'TMDS',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyrimidine synthesis (with hco3 uptake) - TMDS';
    k = k +1;clear FBA

    %% pyrimidine synthesis (with hco3 uptake) - CTPS2
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model=changeRxnBounds(model,'EX_hco3(e)',-1,'b');
    if any(strcmp('CTPS2',model.rxns))
        model=changeObjective(model,'CTPS2',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyrimidine synthesis (with hco3 uptake) - CTPS2';
    k = k +1;clear FBA

    %% pyrimidine catabolism
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model=changeRxnBounds(model,'EX_hco3(e)',-1,'b');
    if any(strcmp('UPPN',model.rxns))
        model=changeObjective(model,'UPPN',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyrimidine catabolism - UPPN';
    k = k +1;clear FBA

    %% 'pyrimidine catabolism - BUP2
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model=changeRxnBounds(model,'EX_hco3(e)',-1,'b');
    if any(strcmp('BUP2',model.rxns))
        model=changeObjective(model,'BUP2',1);
        FBA=optimizeCbModel(model);
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyrimidine catabolism - BUP2';
    k = k +1;clear FBA


    %% fructose to glucose conversion
    model=modelOri;

    model.lb(ismember(model.rxns,'EX_fru(e)'))=-1;model.ub(ismember(model.rxns,'EX_fru(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('TRIOK',model.rxns))
        model=changeObjective(model,'TRIOK',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fructose to glucose conversion - TRIOK';
    k = k +1;clear FBA


    %% uptake and secretion of cholic acid
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_cholate(e)',-1,'l');
    model=changeRxnBounds(model,'EX_cholate(e)',1000,'u');
    % model=changeObjective(model,'CHOLATEt2u');
    %FBA=optimizeCbModel(model,'min');
    %FBA=optimizeCbModel(model,'max');
    % TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    % TestSolutionName{k,1} = 'uptake and secretion of cholic acid - CHOLATEt2u'; % SHOULD THIS BE MIN?
    % k = k +1;clear FBA
    if any(strcmp('CHOLATEt3',model.rxns))
        model=changeObjective(model,'CHOLATEt3',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
        TestSolutionName{k,1} = 'uptake of cholic acid - CHOLATEt3';
    else
        TestSolution(k,1) = NaN;
    end
    k = k +1;clear FBA

    %     if any(strcmp('CHOLATEt3',model.rxns))
    %         FBA=optimizeCbModel(model,'min');
    %         TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    %     else
    %         TestSolution(k,1) = NaN;
    %     end
    %     TestSolutionName{k,1} = 'secretion of cholic acid - CHOLATEt3';
    %  k = k +1;clear FBA

    %% Uptake and secretion of glycocholate
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gchola(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gchola(e)',1000,'u');
    % model=changeObjective(model,'GCHOLAt2u');
    %FBA=optimizeCbModel(model,'min');
    %FBA=optimizeCbModel(model,'max');
    %TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    %TestSolutionName{k,1} = 'uptake and secretion of cholic glycocholate - GCHOLAt2u';
    %k = k +1;clear FBA
    if any(strcmp('GCHOLAt3',model.rxns))
        model=changeObjective(model,'GCHOLAt3',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'uptake of cholic glycocholate - GCHOLAt3';
    k = k +1;clear FBA

    %     if any(strcmp('GCHOLAt3',model.rxns))
    %         FBA=optimizeCbModel(model,'min');
    %         TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    %     else
    %         TestSolution(k,1) = NaN;
    %     end
    %     TestSolutionName{k,1} = 'secretion of cholic glycocholate - GCHOLAt3';
    %  k = k +1;clear FBA

    %% Uptake and secretion of tauro-cholate
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_tchola(e)',-1,'l');
    model=changeRxnBounds(model,'EX_tchola(e)',1000,'u');
    % model=changeObjective(model,'TCHOLAt2u');
    %FBA=optimizeCbModel(model,'min');
    %FBA=optimizeCbModel(model,'max');
    %TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    % TestSolutionName{k,1} = 'uptake and secretion of tauro-cholate - TCHOLAt2u';
    %k = k +1;clear FBA
    if any(strcmp('TCHOLAt3',model.rxns))
        model=changeObjective(model,'TCHOLAt3',1);
        % FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'uptake of tauro-cholate - TCHOLAt3';
    k = k +1;clear FBA
    %     if any(strcmp('TCHOLAt3',model.rxns))
    %         FBA=optimizeCbModel(model,'min');
    %         TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    %     else
    %         TestSolution(k,1) = NaN;
    %     end
    %     TestSolutionName{k,1} = 'secretion of tauro-cholate - TCHOLAt3';
    %  k = k +1;clear FBA

    %% Synthesis of fructose-6-phosphate from erythrose-4-phosphate (HMP shunt);
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('TKT2',model.rxns))
        model=changeObjective(model,'TKT2',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Synthesis of fructose-6-phosphate from erythrose-4-phosphate (HMP shunt) - TKT2';
    k = k +1;clear FBA

    %% Malate to pyruvate (malic enzyme);
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('ME2',model.rxns))
        model=changeObjective(model,'ME2',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Malate to pyruvate (malic enzyme) - ME2';
    k = k +1;clear FBA

    %% Malate to pyruvate (malic enzyme);
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('ME2m',model.rxns))
        model=changeObjective(model,'ME2m',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Malate to pyruvate (malic enzyme) - ME2m';
    k = k +1;clear FBA


    %% Synthesis of urea (urea cycle);
    model=modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    if any(strcmp('ARGN',model.rxns))
        model=changeObjective(model,'ARGN',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Synthesis of urea (urea cycle) - ARGN (with RPMI medium)';
    k = k +1;clear FBA

    %% Cysteine to pyruvate
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_cys-L(e)',-1,'b');
    if any(strcmp('3SPYRSP',model.rxns))
        model=changeObjective(model,'3SPYRSP',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Cysteine to pyruvate - 3SPYRSP';
    k = k +1;clear FBA


    %% Methionine to cysteine  (check for dependancy over pe_hs);
    model=modelOri;
    model=changeRxnBounds(model,'EX_met_L(e)',-1,'b');
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_pe_hs(e)',-1,'l');
    if any(strcmp('CYSTGL',model.rxns))
        model=changeObjective(model,'CYSTGL',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Methionine to cysteine - CYSTGL';
    k = k +1;clear FBA

    %% Synthesis of triacylglycerol (TAG reformation); (check for dependancy over dag_hs and RTOTAL3);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_dag_hs(e)',-1,'l');
    model=changeRxnBounds(model,'EX_Rtotal3(e)',-1,'l');
    if any(strcmp('DGAT',model.rxns))
        model=changeObjective(model,'DGAT');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Synthesis of triacylglycerol (TAG reformation) - DGAT';
    k = k +1;clear FBA

    %% Phosphatidylcholine synthesis (check for dependancy over pe_hs);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_pe_hs(e)',-1,'l');
    if any(strcmp('PETOHMm_hs',model.rxns))
        model=changeObjective(model,'PETOHMm_hs',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Phosphatidylcholine synthesis - PETOHMm_hs';
    k = k +1;clear FBA


    %% Synthesis of FMN from riboflavin
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    model=changeRxnBounds(model,'EX_ribflv(e)',-1,'b');
    if any(strcmp('RBFK',model.rxns))
        model=changeObjective(model,'RBFK',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Synthesis of FMN from riboflavin - RBFK';
    k = k +1;clear FBA

    %% synthesis of FAD from riboflavin
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    model=changeRxnBounds(model,'EX_ribflv(e)',-1,'b');
    if any(strcmp('FMNAT',model.rxns))
        model=changeObjective(model,'FMNAT',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of FAD from riboflavin - FMNAT';
    k = k +1;clear FBA


    %% Synthesis of 5-methyl-tetrahydrofolate from folic acid
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_fol(e)',-1,'b');
    if any(strcmp('MTHFR3',model.rxns))
        model=changeObjective(model,'MTHFR3',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Synthesis of 5-methyl-tetrahydrofolate from folic acid - MTHFR3';
    k = k +1;clear FBA


    %% Putriscine to GABA
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_ptrc(e)',-1,'b');
    if any(strcmp('ABUTD',model.rxns))
        model=changeObjective(model,'ABUTD',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Putriscine to GABA - ABUTD';
    k = k +1;clear FBA

    %% Superoxide dismutase
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('SPODMm',model.rxns))
        model=changeObjective(model,'SPODMm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Superoxide dismutase - SPODMm';
    k = k +1;clear FBA

    %% Availability of bicarbonate from Carbonic anhydrase reaction
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('H2CO3Dm',model.rxns))
        model=changeObjective(model,'H2CO3Dm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Availability of bicarbonate from Carbonic anhydrase reaction - H2CO3Dm';
    k = k +1;clear FBA

    %% Regeneration of citrate (TCA cycle);
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('CSm',model.rxns))
        model=changeObjective(model,'CSm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Regeneration of citrate (TCA cycle) - CSm';
    k = k +1;clear FBA


    %% Histidine to FIGLU
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_his-L(e)'))=-1;
    model.ub(ismember(model.rxns,'EX_his-L(e)'))=-1;
    model=changeRxnBounds(model,'EX_o2(e)',-40,'l');
    model=changeRxnBounds(model,'EX_o2(e)',-1,'u');
    if any(strcmp('IZPN',model.rxns))
        model=changeObjective(model,'IZPN',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Histidine to FIGLU - IZPN';
    k = k +1;clear FBA


    %% binding of guar gum fiber to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_gum(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gchola(e)',-1,'l');
    if any(strcmp('EX_gumgchol(e)',model.rxns))
        model=changeObjective(model,'EX_gumgchol(e)',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of guar gum fiber to bile acids - EX_gumgchol(e)';
    k = k +1;clear FBA

    model=modelOri;
    model=changeRxnBounds(model,'EX_tchola(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gum(e)',-1,'l');

    if any(strcmp('GUMTCHOLe',model.rxns))
        model=changeObjective(model,'GUMTCHOLe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of guar gum fiber to bile acids - GUMTCHOLe';
    k = k +1;clear FBA

    model=modelOri;
    if any(strcmp('GUMDCHAe',model.rxns))
        model=changeRxnBounds(model,'EX_dchac(e)',-1,'l');
        model=changeRxnBounds(model,'EX_gum(e)',-1,'l');
        model=changeObjective(model,'GUMDCHAe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of guar gum fiber to bile acids - GUMDCHAe';
    k = k +1;clear FBA

    %% binding of psyllium fiber to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_psyl(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gchola(e)',-1,'l');
    if any(strcmp('PSYGCHe',model.rxns))
        model=changeObjective(model,'PSYGCHe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of psyllium fiber to bile acids - PSYGCHe';
    k = k +1;clear FBA


    model=modelOri;
    model=changeRxnBounds(model,'EX_psyl(e)',-1,'l');
    model=changeRxnBounds(model,'EX_tchola(e)',-1,'l');
    if any(strcmp('PSYTCHe',model.rxns))
        model=changeObjective(model,'PSYTCHe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of psyllium fiber to bile acids - PSYTCHe';
    k = k +1;clear FBA

    model=modelOri;
    if any(strcmp('PSYTDECHe',model.rxns))
        model=changeRxnBounds(model,'EX_tdechola(e)',-1,'l');
        model=changeRxnBounds(model,'EX_psyl(e)',-1,'l');
        model=changeObjective(model,'PSYTDECHe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of psyllium fiber to bile acids - PSYTDECHe';
    k = k +1;clear FBA

    %% binding to beta glucan fibers to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_bglc(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gchola(e)',-1,'l');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('BGLUGCHe',model.rxns))
        model=changeObjective(model,'BGLUGCHe',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding to beta glucan fibers to bile acids - BGLUGCHe';
    k = k +1;clear FBA

    model=modelOri;
    model=changeRxnBounds(model,'EX_bglc(e)',-1,'l');
    model=changeRxnBounds(model,'EX_tchola(e)',-1,'l');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('BGLUTCHLe',model.rxns))
        model=changeObjective(model,'BGLUTCHLe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding to beta glucan fibers to bile acids - BGLUTCHLe';
    k = k +1;clear FBA

    model=modelOri;
    model=changeRxnBounds(model,'EX_bglc(e)',-1,'l');
    model=changeRxnBounds(model,'EX_tdechola(e)',-1,'l');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('BGLUTDECHOe',model.rxns))
        model=changeObjective(model,'BGLUTDECHOe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding to beta glucan fibers to bile acids - BGLUTDECHOe';
    k = k +1;clear FBA

    %% binding of pectin fiber to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_pect(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gchola(e)',-1,'l');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('PECGCHLe',model.rxns))
        model=changeObjective(model,'PECGCHLe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of pectin fiber to bile acids - PECGCHLe';
    k = k +1;clear FBA

    model=modelOri;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model=changeRxnBounds(model,'EX_pect(e)',-1,'l');
    model=changeRxnBounds(model,'EX_tchola(e)',-1,'l');
    if any(strcmp('PECTCHLe',model.rxns))
        model=changeObjective(model,'PECTCHLe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of pectin fiber to bile acids - PECTCHLe';
    k = k +1;clear FBA

    model=modelOri;
    if any(strcmp('PECDCHe',model.rxns))
        model=changeRxnBounds(model,'EX_dchac(e)',-1,'l');
        model=changeRxnBounds(model,'EX_pect(e)',-1,'l');
        model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
        model=changeObjective(model,'PECDCHe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of pectin fiber to bile acids - PECDCHe';
    k = k +1;clear FBA

    %% heme synthesis
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if any(strcmp('FCLTm',model.rxns))
        model=changeObjective(model,'FCLTm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'heme synthesis - FCLTm';
    k = k +1;clear FBA

    %% heme degradation
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_pheme(e)'))=-1;model.ub(ismember(model.rxns,'EX_pheme(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    if any(strcmp('HOXG',model.rxns))
        model=changeObjective(model,'HOXG',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'heme degradation - HOXG';
    k = k +1;clear FBA

end

%% these functions are new based on muscle and kidney work of SS

if strcmp(test,'all')|| strcmp(test,'Harvey')

    %% Muscle objectives: valine -> pyruvate
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_val_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_val_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pyr(m)'},[0 100]);
    model.c(ismember(model.rxns,'sink_pyr(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'valine -> pyruvate';
    k = k +1;clear FBA
    %% leucine -> pyruvate
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_leu_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_leu_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pyr(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'leucine -> pyruvate';
    k = k +1;clear FBA
    %% isoleucine -> pyruvate
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_ile_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_ile_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pyr(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'isoleucine -> pyruvate';
    k = k +1;clear FBA
    %% threonine -> alanine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_thr_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_thr_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'threonine -> alanine';
    k = k +1;clear FBA
    %% aspartate -> pyruvate
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_asp_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_asp_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pyr(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'aspartate -> pyruvate';
    k = k +1;clear FBA
    %% serine -> alanine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_ser_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_ser_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'serine -> alanine';
    k = k +1;clear FBA
    %% glycine -> alanine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_gly(e)'))=-1;model.ub(ismember(model.rxns,'EX_gly(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glycine -> alanine';
    k = k +1;clear FBA
    %% aspartate -> alanine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_asp_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_asp_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'aspartate -> alanine';
    k = k +1;clear FBA
    %% tyrosine -> glutamine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_tyr_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_tyr_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyrosine -> glutamine';
    k = k +1;clear FBA
    %% lysine -> glutamine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_lys-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_lys-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'lysine -> glutamine';
    k = k +1;clear FBA
    %% phenylalanine -> glutamine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_phe_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_phe_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phenylalanine -> glutamine';
    k = k +1;clear FBA
    %% cysteine -> glutamine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_cys-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_cys-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cysteine -> glutamine';
    k = k +1;clear FBA
    %% cysteine -> alanine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_cys-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_cys-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cysteine -> alanine';
    k = k +1;clear FBA
    %% leucine -> glutamine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_leu_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_leu_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'leucine -> glutamine';
    k = k +1;clear FBA
    %% leucine -> alanine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_leu_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_leu_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'leucine -> alanine';
    k = k +1;clear FBA
    %% valine -> glutamine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_val_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_val_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'valine -> glutamine';
    k = k +1;clear FBA
    %% valine -> alanine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_val_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_val_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'valine -> alanine';
    k = k +1;clear FBA
    %% isoleucine -> glutamine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_ile_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_ile_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'isoleucine -> glutamine';
    k = k +1;clear FBA
    %% isoleucine -> alanine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_ile_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_ile_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'isoleucine -> alanine';
    k = k +1;clear FBA
    %% methionine -> glutamine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_met_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_met_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'methionine -> glutamine';
    k = k +1;clear FBA
    %% methionine -> alanine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_met_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_met_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'methionine -> alanine';
    k = k +1;clear FBA
    %% arginine -> ornithine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_arg-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_arg-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'orn(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_orn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arginine -> ornithine';
    k = k +1;clear FBA
    %% arginine -> proline
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_arg-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_arg-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pro-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_pro-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_pro_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arginine -> proline';
    k = k +1;clear FBA
    %% ornithine -> putrescine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_orn(e)'))=-1;model.ub(ismember(model.rxns,'EX_orn(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ptrc(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ptrc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ornithine -> putrescine';
    k = k +1;clear FBA
    %% glutamate -> glutamine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_glu-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_glu-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamate -> glutamine';
    k = k +1;clear FBA
    %% methionine -> spermine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_met_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_met_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'sprm(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_sprm(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'methionine -> spermine';
    k = k +1;clear FBA
    %% methionine -> spermidine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_met_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_met_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'spmd(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_spmd(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'methionine -> spermidine';
    k = k +1;clear FBA
    %% spermidine -> putrescine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_spmd(e)'))=-1;model.ub(ismember(model.rxns,'EX_spmd(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ptrc(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ptrc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'spermidine -> putrescine';
    k = k +1;clear FBA
    %% ADP -> ATP/ adenylate kinase
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    if any(strcmp('AK1',model.rxns))
        model.c(ismember(model.rxns,'AK1'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ADP -> ATP/ adenylate kinase';
    k = k +1;clear FBA
    %% ADP -> ATP/ adenylate kinase
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    if any(strcmp('AK1',model.rxns))
        model.c(ismember(model.rxns,'AK1m'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ADP -> ATP/ adenylate kinase (mitochondrial)';
    k = k +1;clear FBA
    %% phosphocreatine -> creatine/ cytosolic creatine kinase
    model = modelOri;
    model = addReaction(model,'EX_pcreat(e)','pcreat[e] <=>');
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    model.lb(ismember(model.rxns,'EX_pcreat(e)'))=-1;model.ub(ismember(model.rxns,'EX_pcreat(e)'))=-1;
    [model] = addSinkReactions(model,{'creat(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_creat(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phosphocreatine -> creatine/ cytosolic creatine kinase';
    k = k +1;clear FBA
    %% creatine -> phosphocreatine/mitochondrial creatine kinase
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_creat(e)'))=-1;model.ub(ismember(model.rxns,'EX_creat(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pcreat(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_pcreat(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'creatine -> phosphocreatine/mitochondrial creatine kinase';
    k = k +1;clear FBA
    %% fructose -> lactate/ oxidation of fructose
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_fru(e)'))=-1;model.ub(ismember(model.rxns,'EX_fru(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'lac-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_lac-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fructose -> lactate/ oxidation of fructose';
    k = k +1;clear FBA
    %% fructose -> glycogen/ glycogenesis
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_fru(e)'))=-1;model.ub(ismember(model.rxns,'EX_fru(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'glygn2(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_glygn2(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fructose -> glycogen/ glycogenesis';
    k = k +1;clear FBA
    %% glucose -> erythrose/ HMP shunt
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'e4p(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_e4p(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glucose -> erythrose/ HMP shunt';
    k = k +1;clear FBA
    %% tag_hs(c) -> mag_hs(c)/ lipolysis
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_tag_hs(e)'))=-1;model.ub(ismember(model.rxns,'EX_tag_hs(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'mag-hs(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_mag-hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tag_hs(c) -> mag_hs(c)/ lipolysis';
    k = k +1;clear FBA
    %% tag_hs(c) -> glyc(c)/ lipolysis
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_tag_hs(e)'))=-1;model.ub(ismember(model.rxns,'EX_tag_hs(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'glyc(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_glyc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tag_hs(c) -> glyc(c)/ lipolysis';
    k = k +1;clear FBA
    %% pmtcoa -> acetylCoA/ beta oxidation from pmtcoa
    model = modelOri;
    %         for i = 1 : length(RPMI_composition)
    %         model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    %     end
    model.lb(ismember(model.rxns,'EX_hdca(e)'))=-1;model.ub(ismember(model.rxns,'EX_hdca(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    [model] = addSinkReactions(model,{'accoa(m)'},[0 100]);
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pmtcoa -> acetylCoA/ beta oxidation from pmtcoa';
    k = k +1;clear FBA
    %% odecoa -> acetylCoA/ beta oxidation from oleic acid
    model = modelOri;
    %         for i = 1 : length(RPMI_composition)
    %         model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    %     end
    model.lb(ismember(model.rxns,'EX_ocdcea(e)'))=-1;model.ub(ismember(model.rxns,'EX_ocdcea(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    [model] = addSinkReactions(model,{'accoa(m)'},[0 100]);
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'odecoa -> acetylCoA/ beta oxidation from oleic acid (with RPMI medium)';
    k = k +1;clear FBA
    %% lnlccoa -> acetylCoA/ beta oxidation from linoleic acid
    model = modelOri;
    %         for i = 1 : length(RPMI_composition)
    %         model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    %     end
    model.lb(ismember(model.rxns,'EX_lnlc(e)'))=-1;model.ub(ismember(model.rxns,'EX_lnlc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    [model] = addSinkReactions(model,{'accoa(m)'},[0 100]);
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'lnlccoa -> acetylCoA/ beta oxidation from linoleic acid (with RPMI medium)';
    k = k +1;clear FBA
    %% glycerol -> dhap/ glycerol utilizing machinery
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_glyc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glyc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'dhap(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_dhap(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glycerol -> dhap/ glycerol utilizing machinery';
    k = k +1;clear FBA
    %% adenine -> amp/ salvage of adenine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_adn(e)'))=-1;model.ub(ismember(model.rxns,'EX_adn(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'amp(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_amp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'adenine -> amp/ salvage of adenine';
    k = k +1;clear FBA
    %% hypoxanthine -> imp/ salvage of hypoxanthine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_hxan(e)'))=-1;model.ub(ismember(model.rxns,'EX_hxan(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'imp(c)'},[0 100]);
    model.c(ismember(model.rxns,'INSK'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hypoxanthine -> imp/ salvage of hypoxanthine';
    k = k +1;clear FBA
    %% guanine -> gmp/ salvage of guanine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_gua(e)'))=-1;model.ub(ismember(model.rxns,'EX_gua(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'prpp(c)','gmp(c)'},[-1 0;0 100]);
    model.c(ismember(model.rxns,'GUAPRT'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'guanine -> gmp/ salvage of guanine';
    k = k +1;clear FBA
    %% ribose -> imp/ denovo purine synthesis
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_rib_D(e)'))=-1;model.ub(ismember(model.rxns,'EX_rib_D(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'imp(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_imp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ribose -> imp/ denovo purine synthesis';
    k = k +1;clear FBA
    %% thymd -> thym/ thymidine phosphorylase
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_thymd(e)'))=-1;model.ub(ismember(model.rxns,'EX_thymd(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'thym(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_thym(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thymd -> thym/ thymidine phosphorylase';
    k = k +1;clear FBA
    %% glutamine -> cmp/ pyrimidine synthesis
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_gln-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_gln-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'cmp(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_cmp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine -> cmp/ pyrimidine synthesis';
    k = k +1;clear FBA
    %% glutamine -> dtmp/ pyrimidine synthesis
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_gln-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_gln-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'dtmp(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_dtmp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine -> dtmp/ pyrimidine synthesis';
    k = k +1;clear FBA
    %% Kidney objectives: citr_L(c) -> arg_L(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'citr-L(c)','arg-L(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_citr(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_citr(c)'))=-1;
    model.c(ismember(model.rxns,'sink_arg-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_arg_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'citr_L(c) -> arg_L(c)';
    k = k +1;clear FBA
    %% cys_L(c) -> taur(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'cys-L(c)','taur(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_taur(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cys_L(c) -> taur(c)';
    k = k +1;clear FBA
    %% gly(c) -> orn(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'gly(c)','orn(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_orn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gly(c) -> orn(c)';
    k = k +1;clear FBA
    %% citr_L(c) -> urea(c)/ partial urea cycle in kidney
    model = modelOri;
    [model] = addSinkReactions(model,{'citr-L(c)','urea(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_urea(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'citr_L(c) -> urea(c)/ partial urea cycle in kidney';
    k = k +1;clear FBA
    %% gthrd(c) -> glycine(c)/ glutathione breakdown via ?-glutamyl-transeptidase
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'gly(c)','gthrd(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_gly(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_gly(c)'))=-1;
    model.c(ismember(model.rxns,'sink_gthrd(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gthrd(c) -> glycine(c)/ glutathione breakdown via glutamyl-transeptidase';
    k = k +1;clear FBA
    %% pro_L(c) -> GABA(c)/ GABA synthesis in kidney
    model = modelOri;
    [model] = addSinkReactions(model,{'pro-L(c)','4abut(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_4abut(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pro_L(c) -> GABA(c)/ GABA synthesis in kidney';
    k = k +1;clear FBA
    %% pro_L(c) -> orn(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'pro-L(c)','orn(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_orn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pro_L(c) -> orn(c)';
    k = k +1;clear FBA
    %% met_L(c) -> hcys_L(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'met-L(c)','hcys-L(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_met_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_met_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_hcys-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'met_L(c) -> hcys_L(c)';
    k = k +1;clear FBA
    %% hcys_L(c) -> met_L(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'hcys-L(c)','met-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_met-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_met_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hcys_L(c) -> met_L(c)';
    k = k +1;clear FBA
    %% hcys_L(c) -> cys_L(c)
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'hcys-L(c)','cys-L(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_ser_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_ser_L(c)'))=-1;
    model.c(ismember(model.rxns,'sink_cys-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_cys_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hcys_L(c) -> cys_L(c)';
    k = k +1;clear FBA
    %% 'lys-L(c) -> glu_L(c) / lysine degradation
    model = modelOri;
    [model] = addSinkReactions(model,{'lys-L(c)','glu-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glu-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_glu_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'lys-L(c) -> glu_L(c) / lysine degradation';
    k = k +1;clear FBA
    %% trp-L(c) -> trypta(c) / tryptophan degradation
    model = modelOri;
    [model] = addSinkReactions(model,{'trp-L(c)','trypta(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_trypta(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> trypta(c) / tryptophan degradation';
    k = k +1;clear FBA
    %% kynate(c) -> nicotinamide(c) / nicotinamide from tryptophan metabolite
    model = modelOri;
    [model] = addSinkReactions(model,{'kynate(c)','nicrnt(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_nicrnt(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'kynate(c) -> nicotinamide(c) / nicotinamide from tryptophan metabolite';
    k = k +1;clear FBA
    %% pyr(c) -> lac-L(c)/ lactate dehydrogenase
    model = modelOri;
    [model] = addSinkReactions(model,{'pyr(c)','lac-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_lac-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr(c) -> lac-L(c)/ lactate dehydrogenase';
    k = k +1;clear FBA
    %% ATP max, aerobic, pyruvate/ pyruvate dehydrogenase-->TCA->energy
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_pyr(e)'))=-1;model.ub(ismember(model.rxns,'EX_pyr(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;

    if any(strcmp('DM_atp(c)',model.rxns))
        model.c(ismember(model.rxns,'DM_atp(c)'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, pyruvate/ pyruvate dehydrogenase-->TCA->energy';
    k = k +1;clear FBA
    %% gal(c) -> udpg(c)/ galactose utilization
    model = modelOri;
    [model] = addSinkReactions(model,{'gal(c)','udpg(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_udpg(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gal(c) -> udpg(c)/ galactose utilization';
    k = k +1;clear FBA
    %% fru(c) -> lac_L(c)/ fructose conversion to glucose & utilization
    model = modelOri;
    [model] = addSinkReactions(model,{'fru(c)','lac-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_lac-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fru(c) -> lac_L(c)/ fructose conversion to glucose & utilization';
    k = k +1;clear FBA
    %% malcoa(c) -> eicostetcoa(c)/ fatty acid elongation
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'malcoa(c)','eicostetcoa(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_eicostetcoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'malcoa(c) -> eicostetcoa(c)/ fatty acid elongation (wtih RPMI medium)';
    k = k +1;clear FBA
    %% accoa(c) -> chsterol(r)
    model = modelOri;
    [model] = addSinkReactions(model,{'accoa(c)','chsterol(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_chsterol(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'accoa(c) -> chsterol(r)';
    k = k +1;clear FBA
    %% inost(c) -> glac(r)
    model = modelOri;
    [model] = addSinkReactions(model,{'inost(c)','glac(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glac(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'inost(c) -> glac(r)';
    k = k +1;clear FBA
    %% pail_hs(c) -> pail4p_hs(c)/ inositol kinase
    model = modelOri;
    [model] = addSinkReactions(model,{'pail_hs(c)','pail4p_hs(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pail4p_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pail_hs(c) -> pail4p_hs(c)/ inositol kinase';
    k = k +1;clear FBA
    %% arachd(c) -> prostgh2(c)/ prostaglandin synthesis
    model = modelOri;
    [model] = addSinkReactions(model,{'arachd(c)','prostgh2(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_prostgh2(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arachd(c) -> prostgh2(c)/ prostaglandin synthesis';
    k = k +1;clear FBA
    %% arachd(c) -> prostgd2(r)/ prostaglandin synthesis
    model = modelOri;
    [model] = addSinkReactions(model,{'arachd(c)','prostgd2(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_prostgd2(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arachd(c) -> prostgd2(r)/ prostaglandin synthesis';
    k = k +1;clear FBA
    %% arachd(c) -> prostge2(r)/ prostaglandin synthesis
    model = modelOri;
    [model] = addSinkReactions(model,{'arachd(c)','prostge2(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_prostge2(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arachd(c) -> prostge2(r)/ prostaglandin synthesis';
    k = k +1;clear FBA
    %% arachd(c) -> prostgi2(r)/ prostaglandin synthesis
    model = modelOri;
    [model] = addSinkReactions(model,{'arachd(c)','prostgi2(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_prostgi2(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arachd(c) -> prostgi2(r)/ prostaglandin synthesis';
    k = k +1;clear FBA
    %% 25hvitd3(m) -> 2425dhvitd3(m)/ 24,25-dihydroxycalciol synthesis
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    % results in an infeasible model in Recon2
    %[model] = addSinkReactions(model,{'25hvitd3(m)','2425dhvitd3(m)'},[-1 -1; 0 100]);
    [model] = addSinkReactions(model,{'25hvitd3(m)','2425dhvitd3(m)'},[-1 -0.99; 0 100]);
    model.c(ismember(model.rxns,'sink_2425dhvitd3(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '25hvitd3(m) -> 2425dhvitd3(m)/ 24,25-dihydroxycalciol synthesis (with RPMI medium)';
    k = k +1;clear FBA
    %% caro(c) -> retinal(c)/ vitamin A synthesis
    model = modelOri;
    [model] = addSinkReactions(model,{'caro(c)','retinal(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_retinal(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'caro(c) -> retinal(c)/ vitamin A synthesis';
    k = k +1;clear FBA

    %% missing part starts
    %% synthesis of glutamate from ornithine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_orn(e)'))=-1;model.ub(ismember(model.rxns,'EX_orn(e)'))=-1;
%     [model,rxnNames,rxnIDexists] = addDemandReaction(model,'glu-L(c)');
    [model] = addDemandReaction(model,'glu-L(c)');
%     if ~isempty(rxnIDexists)
%         model.c(rxnIDexists)=1;
%     else
        model.c(ismember(model.rxns,'DM_glu-L(c)'))=1;
%     end
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'synthesis of glutamate from ornithine';
    k = k +1;clear FBA
    %% synthesis of proline from ornithine
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_orn(e)'))=-1;model.ub(ismember(model.rxns,'EX_orn(e)'))=-1;
    [model] = addDemandReaction(model,'pro-L(m)');
    model.c(ismember(model.rxns,'DM_pro-L(m)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'synthesis of proline from ornithine';
    k = k +1;clear FBA
    %% visual cycle in retina
    model = modelOri;
    [model] = addSinkReactions(model,{'retinol-cis-11(c)','retinal(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_retinal(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'visual cycle in retina';
    k = k +1;clear FBA
    %% pail_hs(c) -> pchol_hs(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'pail_hs(c)','pchol-hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_pchol-hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'pail_hs(c) -> pchol_hs(c)';
    k = k +1;clear FBA
    %% pail_hs(c) -> pe_hs(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'pail_hs(c)','pe_hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_pe_hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'pail_hs(c) -> pe_hs(c)';
    k = k +1;clear FBA
    %% pail_hs(c) -> ps_hs(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'pail_hs(c)','ps-hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_ps-hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'pail_hs(c) -> ps_hs(c)';
    k = k +1;clear FBA
    %% pail_hs(c) -> g3pc(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'pail_hs(c)','g3pc(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_g3pc(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'pail_hs(c) -> g3pc(c)';
    k = k +1;clear FBA
    %% dag_hs(c) -> pchol_hs(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'dag_hs(c)','pchol-hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_pchol-hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'dag_hs(c) -> pchol_hs(c)';
    k = k +1;clear FBA
    %% dag_hs(c) -> pe_hs(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'dag_hs(c)','pe_hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_pe_hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'dag_hs(c) -> pe_hs(c)';
    k = k +1;clear FBA
    %% dag_hs(c) -> clpn_hs(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'dag_hs(c)','clpn-hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_clpn-hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'dag_hs(c) -> clpn_hs(c)';
    k = k +1;clear FBA
    %% dag_hs(c) -> pgp_hs(c)
    model = modelOri;
    [model] = addSinkReactions(model,{'dag_hs(c)','pgp-hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_pgp-hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'dag_hs(c) -> pgp_hs(c)';
    k = k +1;clear FBA
    %% bhb(m) -> acac(m)/ ketone body utilization
    model = modelOri;
    [model] = addSinkReactions(model,{'bhb(m)','acac(m)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_acac(m)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'bhb(m) -> acac(m)';
    k = k +1;clear FBA
    %% mal_m(m) -> pyr(m)/ malic enzyme
    model = modelOri;
    [model] = addSinkReactions(model,{'mal-L(m)','pyr(m)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_pyr(m)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'mal_L(m) -> pyr(m)';
    k = k +1;clear FBA
    %% glu_L(c) -> gln_L(c)/ glutamine synthase
    model = modelOri;
    [model] = addSinkReactions(model,{'glu-L(c)','gln-L(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'glu_L(c) -> gln_L(c)';
    k = k +1;clear FBA
    %% cys_L(c) -> coa(c)/ CoA synthesis from cysteine
    model = modelOri;
    [model] = addSinkReactions(model,{'cys-L(c)','coa(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'sink_cys-L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_cys-L(c)'))=-1;
    model.lb(ismember(model.rxns,'sink_cys_L(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_cys_L(c)'))=-1;
    model.c(ismember(model.rxns,'DPCOAK'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'cys_L(c) -> coa(c)';
    k = k +1;clear FBA
    %% occoa(m) -> accoa(m)/ octanoate oxidation
    model = modelOri;
    [model] = addSinkReactions(model,{'occoa(m)','accoa(m)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'occoa(m) -> accoa(m)';
    k = k +1;clear FBA
    %% lnlncgcoa(c) -> dlnlcgcoa(c)/ fatty acid elongation
    model = modelOri;
    [model] = addSinkReactions(model,{'lnlncgcoa(c)','dlnlcgcoa(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_dlnlcgcoa(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'lnlncgcoa(c) -> dlnlcgcoa(c)';
    k = k +1;clear FBA
    %% chol(c) -> ach(c)/ acetyl-choline synthesis in brain
    model = modelOri;
    [model] = addSinkReactions(model,{'chol(c)','ach(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_ach(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'chol(c) -> ach(c)';
    k = k +1;clear FBA
    %% pyr(m) -> oaa(m)/ pyruvate carboxylase
    model = modelOri;
    [model] = addSinkReactions(model,{'pyr(m)','oaa(m)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_oaa(m)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'pyr(m) -> oaa(m)';
    k = k +1;clear FBA
    %% GABA aminotransferase
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glu-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_glu-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'ABTArm'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'GABA aminotransferase';
    k = k +1;clear FBA
    %% methionine adenosyltransferase
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_met_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_met_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'METAT'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'methionine adenosyltransferase';
    k = k +1;clear FBA
    %% creatine synthesis
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_arg_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_arg_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_gly(e)'))=-1;model.ub(ismember(model.rxns,'EX_gly(e)'))=-1;
    [model] = addSinkReactions(model,{'crtn(c)'},[0 1000]);
    model.c(ismember(model.rxns,'sink_crtn(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'creatine synthesis';
    k = k +1;clear FBA
    %% arachd(c) -> leuktrE4(c)/ leukotriene synthesis
    % requires multiple medium compounds --> RPMI

    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'arachd(c)','leuktrE4(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_leuktrE4(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'arachd(c) -> leuktrE4(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% arachd(c) -> C06314(c)/ lipoxin synthesis
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'arachd(c)','C06314(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_C06314(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'arachd(c) -> C06314(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% nrpphr(c) -> 3mox4hoxm(c)/ degradation of norepinephrine
    model = modelOri;
    model = changeRxnBounds(model,RPMI_composition,-1,'l');
    [model] = addSinkReactions(model,{'nrpphr(c)','3mox4hoxm(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_3mox4hoxm(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'nrpphr(c) -> 3mox4hoxm(c) (with RPMI medium)';
    k = k +1;clear FBA
    %% sbt_D(c) -> fru(c)/sorbitol pathway
    model = modelOri;
    [model] = addSinkReactions(model,{'sbt-D(c)','fru(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_fru(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'sbt_D(c) -> fru(c)/sorbitol pathway';
    k = k +1;clear FBA

    %% new addition 26.04.2017
    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'accoa(m)'},0,  1000);
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Mitochondrial accoa de novo synthesis from glc';
    k = k +1;clear FBA

    model = modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'succoa(m)'},0,1000);
    model.c(ismember(model.rxns,'sink_succoa(m)'))=1;
    model.lb(ismember(model.rxns,'sink_coa(c)'))=-1;
    model.ub(ismember(model.rxns,'sink_coa(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f; TestedRxns = [TestedRxns; model.rxns(abs(FBA.x)>tol)];
    TestSolutionName{k,1} = 'Mitochondrial succoa de novo synthesis from glc';
    k = k +1;clear FBA
end

TestSolutionName(:,2) = num2cell(TestSolution);
TestedRxns = unique(TestedRxns);
TestedRxns = intersect(modelOri.rxns,TestedRxns); % only those reactions that are also in modelOri not those that have been added to the network
PercTestedRxns = length(TestedRxns)*100/length(modelOri.rxns);
