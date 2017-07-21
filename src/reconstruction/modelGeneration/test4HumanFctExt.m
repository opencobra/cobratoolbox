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

if nargin<2
    test = 'all';
end
if nargin<3
    optionSinks = 0; % do not close
end

if optionSinks
    % close sink reactions
    model.lb(strmatch('sink_',model.rxns))=0;
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
    A = find(ismember(model.rxns,new(i,1)));
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
    A = find(ismember(model.mets,met));
    model.mets(A,1)= original_mets(i,1);
end

for i=1:length(new_mets)
    M = regexprep(new_mets(i,1),'(','[');
    M = regexprep(M,')',']');
    met = new_mets(i,1);
    A = find(ismember(M,met));
    model.mets(A,1)= original_mets(i,1);
end
% close sink reactions
model.lb(strmatch('DM_',model.rxns))=0;
%aerobic
model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;

model.c(find(model.c)) = 0;
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
    % %  if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% "Human Recon 1 human  biomass"
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.c(ismember(model.rxns,'biomass_reaction'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Human Recon 1 test human biomass';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% "Human Recon 1 human  biomass"
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.c(ismember(model.rxns,'biomass_maintenance_noTrTr'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Human Recon 1 test human biomass (noTrTr)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% "Human Recon 1 human  biomass"
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.c(ismember(model.rxns,'biomass_maintenance'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Human Recon 1 test human biomass (maintenance)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% do not apply base medium for Harvey
    if strcmp(test,'Harvey') == 0
        model = modelOri;
        mediumCompounds = {'EX_co2(e)', 'EX_h(e)', 'EX_h2o(e)', 'EX_hco3(e)', 'EX_nh4(e)', 'EX_o2(e)', 'EX_pi(e)', 'EX_so4(e)'};
        ions={'EX_ca2(e)', 'EX_cl(e)', 'EX_co(e)', 'EX_fe2(e)', 'EX_fe3(e)', 'EX_k(e)', 'EX_na1(e)', 'EX_i(e)', 'EX_sel(e)'};
        I = strmatch('EX_', modelOri.rxns);

        for i=1:length(I);
            Ex= I(i);
            modelOri.lb(Ex,1) = 0;
            if modelOri.ub(Ex,1) < 0;
                modelOri.ub(Ex,1)=1;
            end
            %  modelOri.ub(Ex,1) = 1;% uncomment to run for tcell models
        end
        modelOri.lb(find(ismember(modelOri.rxns,mediumCompounds)))=-100;
        modelOri.lb(find(ismember(modelOri.rxns,ions)))=-1;
    end
    %% ATP max aerobic, glc, v0.05
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, glc';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ATP max, anaerobic glc, v0.05
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=0;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, anaerobic, glc';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ATP max, aerobic, citrate
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_cit(e)'))=-1;model.ub(ismember(model.rxns,'EX_cit(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, citrate';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ATP max, aerobic, EtOH substrate v0.05
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_etoh(e)'))=-1;model.ub(ismember(model.rxns,'EX_etoh(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, etoh';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ATP max, aerobic, glutamate v0.05
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glu-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_glu-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, glu-L';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ATP max, aerobic, glutamine substrate
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_gln-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_gln-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, gln-L';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ATP max, aerobic, glycine substrate v0.05
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_gly(e)'))=-1;model.ub(ismember(model.rxns,'EX_gly(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, gly';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ATP max, aerobic, lactate substrate v0.05
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_lac-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_lac-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, lac-L';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ATP max, aerobic, proline substrate v0.05
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_pro-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_pro-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'DM_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, pro-L';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ATP production via electron transport chain
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    %model.lb(ismember(model.rxns,'CYOOm3'))=1; % there is an alternative
    %reaction
    if ~isempty(find(ismember(model.rxns,'CYOR-u10m'))) && ~isempty(find(ismember(model.rxns,'NADH2-u10m')))
        if  model.ub(ismember(model.rxns,'CYOR-u10m'))>=1 && model.ub(ismember(model.rxns,'NADH2-u10m'))>=1
            model.lb(ismember(model.rxns,'CYOR-u10m'))=1;
            model.lb(ismember(model.rxns,'NADH2-u10m'))=1;
            model.c(ismember(model.rxns,'DM_atp(c)'))=1;
            if find(model.c)>0
                FBA = optimizeCbModel(model,'max','zero');
                TestSolution(k,1) = FBA.f;
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
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
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
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_gthrd(e)'))=-1;
    model.c(ismember(model.rxns,'GTHP'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gthrd reduces h2o2, GTHP (c) ';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    model = modelOri;
    model.lb(ismember(model.rxns,'EX_gthrd(e)'))=-1;model.ub(ismember(model.rxns,'gthox(e)'))=1;
    model.c(find(model.c)) = 0;
    model.c(ismember(model.rxns,'GTHPe'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gthrd reduces h2o2, GTHP (e) ';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_gthrd(e)'))=-1;
    model.c(ismember(model.rxns,'GTHPm'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gthrd reduces h2o2, GTHP (m) ';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gly -> co2 and nh4 (via glycine cleavage system)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gly(c)','co2(c)','nh4(c)'},[-1 -1; 0.1 100; 0.1 100]);
    model.lb(ismember(model.rxns,'EX_nh4(e)'))=0;model.ub(ismember(model.rxns,'EX_nh4(e)'))=1000;
    model.c(ismember(model.rxns,'sink_nh4(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gly -> co2 + nh4';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% 12ppd-S -> mthgxl
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'12ppd-S(c)','mthgxl(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_mthgxl(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '12ppd-S(c) -> mthgxl(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% 12ppd-S -> pyr
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'12ppd-S(c)','pyr(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '12ppd-S(c) -> pyr(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% 3pg -> gly
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'3pg(c)','gly(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gly(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '3pg(c) -> gly(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% 3pg -> ser-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'3pg(c)','ser-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ser-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '3pg(c) -> ser-L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% 4abut -> succ[m]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'4abut(c)','succ(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_succ(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '4abut(c) -> succ(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% 4hpro-LT(m) -> glx(m)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'4hpro-LT(m)','glx(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glx(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '4hpro-LT(m) -> glx(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% 5aop -> pheme
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'5aop(c)','pheme(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pheme(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '5aop(c) -> pheme(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% aact -> mthgxl
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'aact(c)','mthgxl(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_mthgxl(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'aact(c) -> mthgxl(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% acac[m] -> acetone[m]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'acac(m)','acetone(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_acetone(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acac(m) -> acetone(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% acac[m] -> bhb[m]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'acac(m)','bhb(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_bhb(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acac(m) -> bhb(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% acald -> ac
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'acald(c)','ac(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ac(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acald(c) -> ac(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% accoa(c) -> pmtcoa(c) -> malcoa(m)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'accoa(c)','pmtcoa(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pmtcoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'accoa(c) -> pmtcoa(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% accoa(c) -> pmtcoa(c) -> malcoa(m)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pmtcoa(c)','malcoa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_malcoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pmtcoa(c) -> malcoa(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% acetone -> mthgxl
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'acetone(c)','mthgxl(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_mthgxl(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acetone(c) -> mthgxl(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% acgal -> udpacgal
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'acgal(c)','udpacgal(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_udpacgal(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acgal(c) -> udpacgal(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% acgam -> cmpacna
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'acgam(c)','cmpacna(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cmpacna(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acgam(c) -> cmpacna(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% acorn -> orn
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'acorn(c)','orn(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_orn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'acorn(c) -> orn(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% adrnl -> 34dhoxpeg
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'adrnl(c)','34dhoxpeg(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_34dhoxpeg(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'adrnl(c) -> 34dhoxpeg(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% adrnl -> 34dhoxpeg (2) % duplicate
    %% adrnl -> 34dhoxpeg (3) % duplicate
    %% akg[c] -> glu-L[c] % I adjusted lb since otherwise not feasible
    % model = modelOri;
    % model.c(find(model.c)) = 0;
    % [model] = addSinkReactions(model,{'akg(c)','glu-L(c)'},[-1 -1; 0 100]);
    % model.c(ismember(model.rxns,'sink_glu-L(c)'))=1;
    %   FBA = optimizeCbModel(model,'max','zero');
    % TestSolution(k,1) = FBA.f;
    % TestSolutionName{k,1} = 'akg(c) -> glu-L(c)';
    % k = k +1;clear FBA
    %% akg[c] -> glu-L[c] % I adjusted lb since otherwise not feasible
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_akg(e)'))=-1;model.ub(ismember(model.rxns,'EX_akg(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('ALATA_L',model.rxns,'exact'))
        model.c(ismember(model.rxns,'ALATA_L'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'akg(c) -> glu-L(c) (ALATA_L)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% akg[c] -> glu-L[c]
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_akg(e)'))=-1;model.ub(ismember(model.rxns,'EX_akg(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('ASPTA',model.rxns,'exact'))
        model.c(ismember(model.rxns,'ASPTA'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'akg(c) -> glu-L(c) (ASPTA)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% akg[m[ -> oaa[m]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'akg(m)','oaa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_oaa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'akg(m) -> oaa(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% akg[m] -> glu-L[m]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'akg(m)','glu-L(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glu-L(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'akg(m) -> glu-L(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'akg(m)'},-1 , -1);
    if ~isempty(strmatch('ASPTAm',model.rxns,'exact'))
        model.c(ismember(model.rxns,'ASPTAm'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'akg(m) -> glu-L(m) (ASPTAm)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% ala-B -> msa
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ala-B(c)','msa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_msa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ala-B(c) -> msa(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ala-D -> pyr
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ala-D(c)','pyr(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ala-D(c) -> pyr(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ala-L -> ala-D
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ala-L(c)','ala-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ala-L(c) -> ala-D(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ala-L -> pyr
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ala-L(c)','pyr(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ala-L(c) -> pyr(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arachd(c) -> malcoa(m)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'arachd(c)','malcoa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_malcoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arachd(c) -> malcoa(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arachd(r) -> txa2(r)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'arachd(r)','txa2(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_txa2(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arachd(r) -> txa2(r)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arg-L -> creat
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'arg-L(c)','creat(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_creat(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arg-L(c) -> creat(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arg-L -> glu-L (m)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'arg-L(c)','glu-L(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glu-L(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arg-L -> glu-L (m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arg-L -> no
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'arg-L(c)','no(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_no(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arg-L -> no';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arg-L -> pcreat
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'arg-L(c)','pcreat(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pcreat(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arg-L(c) -> pcreat(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ascb -> eryth
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ascb-L(c)','eryth(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'DM_ascb_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'DM_ascb_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_eryth(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ascb-L(c) -> eryth(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ascb -> lyxnt
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ascb-L(c)','lyxnt(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'DM_ascb_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'DM_ascb_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_lyxnt(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ascb-L(c) -> lyxnt(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ascb -> thrnt
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ascb-L(c)','thrnt(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'DM_ascb_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'DM_ascb_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_thrnt(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ascb-L(c) -> thrnt(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ascb -> xylnt
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ascb-L(c)','xylnt(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'DM_ascb_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'DM_ascb_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_xylnt(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ascb-L(c) -> xylnt(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% asn-L -> oaa
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'asn-L(c)','oaa(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_oaa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asn-L(c) -> oaa(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% asp-L + hco3 -> arg-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'asp-L(c)','hco3(c)','arg-L(c)'},[-1 -1;-1 -1;0 100]);
    model.c(ismember(model.rxns,'sink_arg-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asp-L(c) + hco3(c) -> arg-L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% asp-L -> ala-B
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'asp-L(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asp-L(c) -> ala-B(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% asp-L -> asn-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'asp-L(c)','asn-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_asn-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asp-L(c) -> asn-L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% asp-L -> fum (via argsuc)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'asp-L(c)','argsuc(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_argsuc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asp-L(c) -> argsuc(c), asp-L -> fum (via argsuc), 1';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'argsuc(c)','fum(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_fum(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'argsuc(c) -> fum(c), asp-L -> fum (via argsuc), 2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% asp-L -> fum (via dcamp)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'asp-L(c)','dcamp(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_asp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_asp_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_dcamp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asp-L(c) -> dcamp(c), asp-L -> fum (via dcamp), 1';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(find(ismember(model.rxns,'sink_asp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_asp_L(c)')))=-1;
    [model] = addSinkReactions(model,{'dcamp(c)','fum(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_fum(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dcamp(c) -> fum(c), asp-L -> fum (via dcamp), 2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(find(ismember(model.rxns,'sink_asp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_asp_L(c)')))=-1;
    [model] = addSinkReactions(model,{'dcamp(c)','fum(c)'},[-1 -1; 0 100]);
    if ~isempty(strmatch('ADSS',model.rxns,'exact'))
        model.c(ismember(model.rxns,'ADSS'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dcamp(c) -> fum(c), asp-L -> fum (via dcamp), 3';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% asp-L -> oaa
    model = modelOri;
    model.c(find(model.c)) = 0;
    % causes an infeasible model in Recon2
    %[model] = addSinkReactions(model,{'asp-L(c)','oaa(c)'},[-1 -1; 0 100]);
    [model] = addSinkReactions(model,{'asp-L(c)','oaa(c)'},[-1 -0.99; 0 100]);
    model.c(ismember(model.rxns,'sink_oaa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'asp-L(c) -> oaa(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% carn -> ala-B
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'carn(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'carn -> ala-B';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% chol(c) + dag_hs(c) -> pe_hs(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'chol(c)','dag_hs(c)','pe_hs(c)'},[-1 -1;-1 -1;0 100]);
    model.c(ismember(model.rxns,'sink_pe_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'chol(c) + dag_hs(c) -> pe_hs(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% choline -> betaine -> glycine
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'chol(m)','glyb(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glyb(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'choline -> betaine (glyb) -> glycine, 1 [m]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glyb(m)','gly(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gly(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'choline -> betaine (glyb) -> glycine, 2 [m]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% coke(r) -> pecgoncoa(r)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'coke(r)','pecgoncoa(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pecgoncoa(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'coke(r) -> pecgoncoa(r)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% core2[g] -> ksii_core2[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'core2(g)','ksii_core2(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ksii_core2(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'core2(g) -> ksii_core2(g)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% core4[g] -> ksii_core4[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'core4(g)','ksii_core4(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ksii_core4(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'core4(g) -> ksii_core4(g)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cspg_a[ly] -> 2 gal[ly] + glcur[ly] + xyl-D[ly] %I adjusted lb since otw infeasible
    model = modelOri;
    model.c(find(model.c)) = 0;
    % may cause an infeasible model
    %[model] = addSinkReactions(model,{'cspg_a(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    [model] = addSinkReactions(model,{'cspg_a(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -0.99; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_xyl-D(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cspg_a[ly] -> gal[ly] + glcur[ly] + xyl-D[ly]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cspg_b[ly] -> 2gal[ly] + glcur[ly] + xyl-D[ly]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'cspg_b(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_xyl-D(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cspg_b[ly] -> gal[ly] + glcur[ly] + xyl-D[ly]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cspg_c[ly] -> 2 gal[ly] + glcur[ly] + xyl-D[ly]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'cspg_c(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_xyl-D(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cspg_c[ly] -> gal[ly] + glcur[ly] + xyl-D[ly]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cspg_d[ly] -> 2 gal[ly] + glcur[ly] + xyl-D[ly]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'cspg_d(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_xyl-D(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cspg_d[ly] -> gal[ly] + glcur[ly] + xyl-D[ly]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cspg_e[ly] -> 2 gal[ly] + glcur[ly] + xyl-D[ly]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'cspg_e(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_xyl-D(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cspg_e[ly] -> gal[ly] + glcur[ly] + xyl-D[ly]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cys-L + glu-L + gly -> ghtrd
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'cys-L(c)', 'glu-L(c)','gly(c)','gthrd(c)'},[-1 -1;-1 -1;-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gthrd(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cys-L + glu-L + gly -> ghtrd';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cys-L -> 3sala -> so4 %I adjusted lb since otw infeasible
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'cys-L(c)','3sala(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'EX_so4(e)'))=0;model.ub(ismember(model.rxns,'EX_so4(e)'))=1000;
    model.c(ismember(model.rxns,'sink_3sala(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cys-L -> 3sala -> so4, 1';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'3sala(c)','so4(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'EX_so4(e)'))=0;model.ub(ismember(model.rxns,'EX_so4(e)'))=1000;
    model.c(ismember(model.rxns,'sink_so4(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cys-L -> 3sala -> so4, 2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cys-L -> hyptaur
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'cys-L(c)','hyptaur(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_hyptaur(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cys-L(c) -> hyptaur(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cystine -> cys-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'Lcystin(c)','cys-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cys-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cystine (Lcystin) -> cys-L';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dhap -> mthgxl
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'dhap(c)','mthgxl(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_mthgxl(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dhap(c) -> mthgxl(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dmpp -> ggdp
    model = modelOri;
    model.c(find(model.c)) = 0;

    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end

    [model] = addSinkReactions(model,{'dmpp(c)','ggdp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ggdp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dmpp(c) -> ggdp(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dna(n) -> dna5mtc(n)
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'dna(n)','dna5mtc(n)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dna5mtc(n)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dna(n) -> dna5mtc(n) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dolichol_L -> dolmanp_L(r)
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'dolichol_L(c)','dolmanp_L(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dolmanp_L(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dolichol_L(c) -> dolmanp_L(r) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dolichol_L -> g3m8mpdol_L[r]
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'dolichol_L(c)','g3m8mpdol_L(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_g3m8mpdol_L(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dolichol_L(c) -> g3m8mpdol_L(r) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dolichol_U -> dolmanp_U[r]
    model = modelOri;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'dolichol_U(c)','dolmanp_U(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dolmanp_U(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dolichol_U(c) -> dolmanp_U(r) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dolichol_U -> g3m8mpdol_U[r]
    model = modelOri;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'dolichol_U(c)','g3m8mpdol_U(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_g3m8mpdol_U(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dolichol_U(c) -> g3m8mpdol_U(r) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dopa -> homoval (1)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    [model] = addSinkReactions(model,{'dopa(c)','homoval(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'DM_dopa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'DM_dopa(c)')))=-1;
    model.c(ismember(model.rxns,'sink_homoval(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dopa(c) -> homoval(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dopa -> homoval (2) %duplicate
    %% etoh -> acald
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'etoh(c)','acald(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_acald(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'etoh(c) -> acald(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% f6p + g3p -> r5p
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'f6p(c)','g3p(c)','r5p(c)'},[-1 -1; -1 -1;0 100]);
    model.c(ismember(model.rxns,'sink_r5p(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'f6p(c) + g3p(c) -> r5p(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% frdp -> dolichol_L
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'frdp(c)','dolichol_L(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dolichol_L(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'frdp(c) -> dolichol_L(r) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% frdp -> dolichol_U
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'frdp(c)','dolichol_U(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dolichol_U(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'frdp(c) -> dolichol_U(r) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from ade(c) to amp(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ade(c)','amp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_amp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ade(c) -> amp(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from adn(c) to urate(x)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'adn(c)','urate(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_urate(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'adn(c) -> urate(x)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from ADP(c) to dATP(n)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model,rxnsInModel] = addSinkReactions(model,{'adp(c)','datp(n)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_datp(n)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'adp(c) -> datp(n)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from CDP(c) to dCTP(n)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model,rxnsInModel] = addSinkReactions(model,{'cdp(c)','dctp(n)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_dctp(n)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cdp(c) -> dctp(n)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from cmp to cytd
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'cmp(c)','cytd(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cytd(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cmp(c) -> cytd(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from cytd to ala-B
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'cytd(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cytd(c) -> ala-B(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from dcmp to ala-B
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'dcmp(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'dcmp(c) -> ala-B(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from GDP(c) to dGTP(n)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gdp(c)','dgtp(n)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_dgtp(n)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gdp(c) -> dgtp(n)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from gln-L + HCO3 to UMP(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gln-L(c)','hco3(c)','ump(c)'},[-1 -1;-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ump(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gln-L + HCO3 -> UMP(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from gsn(c) to urate(x)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gsn(c)','urate(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_urate(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gsn(c) -> urate(x)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from gua(c) to gmp(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gua(c)','gmp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gmp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gua(c) -> gmp(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from hxan(c) to imp(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'hxan(c)','imp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_imp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hxan(c) -> imp(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from imp to ATP
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'imp(c)','atp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_atp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'imp(c) -> atp(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from imp to gtp
    model = modelOri;
    model.c(find(model.c)) = 0;
    % may cause an infeasible model
    %[model] = addSinkReactions(model,{'imp(c)','gtp(c)'},[-1 -1; 0 100]);
    [model] = addSinkReactions(model,{'imp(c)','gtp(c)'},[-1 -0.99; 0 100]);
    model.c(ismember(model.rxns,'sink_gtp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'imp(c) -> gtp(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from imp(c) to urate(x)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'imp(c)','urate(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_urate(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'imp(c) -> urate(x)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from prpp to imp
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'prpp(c)','imp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_imp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'prpp(c) -> imp(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from pydx(c) to pydx5p(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pydx(c)','pydx5p(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_pydx(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_pydx(c)')))=-1;
    model.c(ismember(model.rxns,'sink_pydx5p(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pydx(c) -> pydx5p(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from thm(c) to thmpp(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'thm(c)','thmpp(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_thmpp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thm(c) -> thmpp(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from thm(e) to thmpp(m) %does not work; changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'thm(e)','thmpp(m)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'EX_thm(e)')))=-1;
    model.ub(find(ismember(model.rxns,'EX_thm(e)')))=-1;
    model.c(ismember(model.rxns,'sink_thmpp(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thm(e) -> thmpp(m) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from thmmp(e) to thmpp(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'thmmp(e)','thmpp(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'EX_thmmp(e)')))=-1;
    model.ub(find(ismember(model.rxns,'EX_thmmp(e)')))=-1;
    model.c(ismember(model.rxns,'sink_thmpp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thmmp(e) -> thmpp(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from thmmp(e) to thmpp(m)%does not work; changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model.lb(find(ismember(model.rxns,'EX_thmmp(e)')))=-1;
    model.ub(find(ismember(model.rxns,'EX_thmmp(e)')))=-1;
    [model] = addSinkReactions(model,{'thmpp(m)'},[ 0 100]);
    model.c(ismember(model.rxns,'sink_thmpp(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thmmp(e) -> thmpp(m) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from tyr-L(m) to q10(m)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'tyr-L(m)','q10(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_q10(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(m) -> q10(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from UDP(c) to dTTP(n)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'udp(c)','dttp(n)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_dttp(n)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'udp(c) -> dttp(n)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% from ump to ala-B
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ump(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ump(c) -> ala-B(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% fru -> dhap
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'fru(c)','dhap(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dhap(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fru(c) -> dhap(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% fru -> g3p
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'fru(c)','g3p(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_g3p(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fru(c) -> g3p(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% fuc -> gdpfuc
    model = modelOri;
    model.c(find(model.c)) = 0;

    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'fuc-L(c)','gdpfuc(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gdpfuc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fuc-L(c) -> gdpfuc(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% fum[m] -> oaa[m]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'fum(m)','oaa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_oaa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fum(m) -> oaa(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% g1p -> dtdprmn
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'g1p(c)','dtdprmn(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dtdprmn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'g1p(c) -> dtdprmn(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% g3p -> mthgxl
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'g3p(c)','mthgxl(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_mthgxl(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'g3p(c) -> mthgxl(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% g6p -> r5p
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'g6p(c)','r5p(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_r5p(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'g6p(c) -> r5p(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% g6p -> ru5p
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'g6p(c)','ru5p-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ru5p-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'g6p(c) -> ru5p-D(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gal -> glc
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gal(c)','glc-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glc-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gal(c) -> glc-D(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gal -> udpgal
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gal(c)','udpgal(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_udpgal(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gal(c) -> udpgal(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% galgluside(g) -> galgalgalthcrm_hs(g)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','galgalgalthcrm_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_galgalgalthcrm_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> galgalgalthcrm_hs(g)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% galgluside_hs(g) -> acgagbside_hs(g)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','acgagbside_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_acgagbside_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> acgagbside_hs(g)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% galgluside_hs(g) -> acnacngalgbside_hs(g)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','acnacngalgbside_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_acnacngalgbside_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> acnacngalgbside_hs(g)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% galgluside_hs(g) -> gd1b2_hs(g)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','gd1b2_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gd1b2_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> gd1b2_hs(g)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% galgluside_hs(g) -> gd1c_hs(g)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','gd1c_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gd1c_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> gd1c_hs(g)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% galgluside_hs(g) -> gp1c_hs(g)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','gp1c_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gp1c_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> gp1c_hs(g)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% galgluside_hs(g) -> gq1balpha_hs(g)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'galgluside_hs(g)','gq1balpha_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gq1balpha_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'galgluside_hs(g) -> gq1balpha_hs(g)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gam6p -> uacgam
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gam6p(c)','uacgam(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_uacgam(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gam6p(c) -> uacgam(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gdpmann -> gdpfuc
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gdpmann(c)','gdpfuc(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gdpfuc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gdpmann(c) -> gdpfuc(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glc -> inost
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glc-D(c)','inost(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_inost(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glc-D(c) -> inost(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glc -> lac + atp + h2o % I assumed lac-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glc-D(c)','lac-L(c)','atp(c)','h2o(c)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_lac-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glc-D(c) -> lac-L(c) + atp(c) + h2o(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glc -> lac-D
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glc-D(c)','lac-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_lac-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glc-D(c) -> lac-D(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glc -> lcts[g] (2)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glc-D(c)','lcts(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_lcts(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glc-D(c) -> lcts(g)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glc -> pyr
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glc-D(c)','pyr(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glc-D(c) -> pyr(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gln -> nh4
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gln-L(c)','nh4(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'EX_nh4(e)'))=0;model.ub(ismember(model.rxns,'EX_nh4(e)'))=1000;
    model.c(ismember(model.rxns,'sink_nh4(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gln-L(c) -> nh4(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gln-L(m) -> glu-L(m)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gln-L(m)','glu-L(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glu-L(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gln-L(m) -> glu-L(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gln-L[m] -> glu-L[m]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gln-L(m)','glu-L(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glu-L(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gln-L(m) -> glu-L(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glu5sa -> pro-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glu5sa(c)','pro-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pro-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glu5sa(c) -> pro-L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glu-L -> 4abut
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glu-L(c)','4abut(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_4abut(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glu-L(c) -> 4abut(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glu-L -> gln-L[c] %I adjusted lb since otw infeasible
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glu-L(c)','gln-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glu-L(c) -> gln-L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glu-L -> pro-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glu-L(c)','pro-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pro-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glu-L -> pro-L';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glu-L(m) -> akg(m)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glu-L(m)','akg(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_akg(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glu-L(m) -> akg(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gluside_hs(g) -> galgluside_hs(g)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gluside_hs(g)','galgluside_hs(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_galgluside_hs(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gluside_hs(g) -> galgluside_hs(g)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glx[m] -> glyclt[m]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glx(m)','glyclt(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glyclt(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glx(m) -> glyclt(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gly -> ser-L -> pyr (via SERD_L) % SERD_L does not exist in human
    % (L-serine deaminase)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gly(c)','ser-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ser-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gly(c) -> ser-L(c) -> pyr(c), 1';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ser-L(c)','pyr(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gly(c) -> ser-L(c) -> pyr(c), 2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glyc -> glc
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glyc(c)','glc-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glc-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glyc(c) -> glc-D(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glyc(c) + Rtotal(c) + Rtotal2(c) -> dag_hs(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glyc(c)','Rtotal(c)','Rtotal2(c)','dag_hs(c)'},[-1 -1;-1 -1;-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dag_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glyc(c) + Rtotal(c) + Rtotal2(c) -> dag_hs(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glyc(c) + Rtotal(c) -> tag_hs(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'glyc(c)','Rtotal(c)','tag_hs(c)'},[-1 -1;-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_tag_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glyc(c) + Rtotal(c) -> tag_hs(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glyclt -> gly
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glyclt(c)','gly(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gly(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glyclt(c) -> gly(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glygn2 -> glc % changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glygn2(c)','glc-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glc-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glygn2(c) -> glc-D(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glygn2[e] -> glc[e]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glygn2(e)','glc-D(e)'},[-1 -1; 0 100]);
    %model.c(ismember(model.rxns,'sink_glc-D(e)'))=1;
    if ~isempty(strmatch('AMY2e',model.rxns,'exact'))
        model = changeObjective(model,'AMY2e',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glygn2(e) -> glc-D(e) - via AMY2e';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glyx -> oxa % I assumed glx
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glx(c)','oxa(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_oxa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glx(c) -> oxa(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ha[l] -> acgam[l] + glcur[l]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ha(l)','acgam(l)','glcur(l)'},[-1 -1; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_acgam(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ha[l] -> acgam[l] + glcur[l]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% His -> glu-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'his-L(c)','glu-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glu-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'his-L(c) -> glu-L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% his-L -> hista
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'his-L(c)','hista(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_his_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_his_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_hista(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'his-L(c) -> hista(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hista -> 3mlda
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'hista(c)','3mlda(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'DM_hista(c)')))=-1;
    model.ub(find(ismember(model.rxns,'DM_hista(c)')))=-1;
    model.c(ismember(model.rxns,'sink_3mlda(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hista(c) -> 3mlda(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hista -> im4ac
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'hista(c)','im4act(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_im4act(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hista(c) -> im4ac(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hmgcoa(x) -> chsterol(r)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'hmgcoa(x)','chsterol(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_chsterol(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hmgcoa(x) -> chsterol(r)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hmgcoa(x) -> frdp(x)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'hmgcoa(x)','frdp(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_frdp(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hmgcoa(x) -> frdp(x)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hmgcoa(x) -> xoldiolone(r)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'hmgcoa(x)','xoldiolone(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_xoldiolone(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hmgcoa(x) -> xoldiolone(r)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hmgcoa(x) -> xoltriol(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'hmgcoa(x)','xoltriol(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_xoltriol(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hmgcoa(x) -> xoltriol(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hmgcoa(x)-chsterol(r) %duplicate
    % model = modelOri;
    % model.c(find(model.c)) = 0;
    % [model] = addSinkReactions(model,{'hmgcoa(x)','chsterol(r)'},[-1 -1; 0 100]);
    % model.c(ismember(model.rxns,'sink_chsterol(r)'))=1;
    %   FBA = optimizeCbModel(model,'max','zero');
    % TestSolution(k,1) = FBA.f;
    % TestSolutionName{k,1} = 'hmgcoa(x) -> chsterol(r)';
    % k = k +1;clear FBA
    %% hpyr -> 2pg
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'hpyr(c)','2pg(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_2pg(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hpyr(c) -> 2pg(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hpyr -> glyclt
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'hpyr(c)','glyclt(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glyclt(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hpyr(c) -> glyclt(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hpyr -> glyc-S
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'hpyr(c)','glyc-S(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glyc-S(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hpyr(c) -> glyc-S(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hspg(l) -> 2 gal(l) + glcur(l) + xyl-D(l) %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'hspg(l)','gal(l)','glcur(l)','xyl-D(l)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_xyl-D(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hspg(l) -> gal(l) + glcur(l) + xyl-D(l)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hyptaur(c) -> taur(x)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'hyptaur(c)','taur(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_taur(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hyptaur(c) -> taur(x)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ile-L -> accoa
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ile-L(c)','accoa(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_ile_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_ile_L(c)')))=-1;
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    model.c(ismember(model.rxns,'sink_accoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ile-L(c) -> accoa(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% inost -> pail_hs
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'inost(c)','pail_hs(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pail_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'inost(c) -> pail_hs(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% inost -> pail45p_hs
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'inost(c)','pail45p_hs(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pail45p_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'inost(c) -> pail45p_hs(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% inost -> pail4p_hs
    model = modelOri;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'inost(c)','pail4p_hs(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pail4p_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'inost(c) -> pail4p_hs(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% inost -> xu5p-D
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'inost(c)','xu5p-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_xu5p-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'inost(c) -> xu5p-D(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ipdp(x) -> sql(r)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ipdp(x)','sql(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_sql(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ipdp(x) -> sql(r)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% itacon[m] -> pyr[m] %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'itacon(m)','pyr(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'itacon(m) -> pyr(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ksi[l] -> man[l] + acgam[l]
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'ksi(l)','man(l)','acgam(l)'},[-1 -1; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_acgam(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ksi[l] -> man[l] + acgam[l] (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ksii_core2(l) -> Ser/Thr(l)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model,rxnsInModel] = addSinkReactions(model,{'ksii_core2(l)','Ser/Thr(l)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_Ser/Thr(l)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ksii_core2(l) -> Ser/Thr(l)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ksii_core4(l) -> Ser/Thr(l)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model,rxnsInModel] = addSinkReactions(model,{'ksii_core4(l)','Ser/Thr(l)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_Ser/Thr(l)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ksii_core4(l) -> Ser/Thr(l)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% l2fn2m2masn[g] -> ksi[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'l2fn2m2masn(g)','ksi(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ksi(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'l2fn2m2masn(g) -> ksi(g) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% lac -> glc % i assumed lac-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'lac-L(c)','glc-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glc-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'lac-L(c) -> glc-D(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% Lcyst(c) -> taur(x)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'Lcyst(c)','taur(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_taur(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Lcyst(c) -> taur(x)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% leu-L -> accoa
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'leu-L(c)','accoa(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_leu_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_leu_L(c)')))=-1;
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    model.c(ismember(model.rxns,'sink_accoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'leu-L(c) -> accoa(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% lys-L[c] -> accoa[m] (via saccrp-L pathway)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'lys-L(c)','accoa(m)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_lys_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_lys_L(c)')))=-1;
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'lys-L[c] -> accoa[m] (via saccrp-L pathway)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% lys-L[x] -> aacoa[m] (via Lpipecol pathway)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(find(ismember(model.rxns,'EX_lys-L(e)')))=-1;
    model.ub(find(ismember(model.rxns,'EX_lys-L(e)')))=-1;
    [model] = addSinkReactions(model,{'lys-L(x)','aacoa(m)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    model.c(ismember(model.rxns,'sink_aacoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'lys-L[x] -> aacoa[m] (via Lpipecol pathway)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% m8masn[r] -> nm4masn[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'m8masn(r)','nm4masn(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_nm4masn(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'm8masn(r) -> nm4masn(g)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% man -> gdpmann
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'man(c)','gdpmann(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gdpmann(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'man(c) -> gdpmann(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% man6p -> kdn
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'man6p(c)','kdn(c)'},[-1 -1; 0 100]);
    if ~isempty(strmatch('ACNAM9PL2',model.rxns,'exact'))
        model.c(ismember(model.rxns,'ACNAM9PL2'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'man6p(c) -> kdn(c) - via ACNAM9PL2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% mescon[m] -> pyr[m] %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'mescon(m)','pyr(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pyr(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'mescon(m) -> pyr(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% met-L -> cys-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'met-L(c)','cys-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cys-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'met-L(c) -> cys-L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% mi145p -> inost
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'mi145p(c)','inost(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_inost(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'mi145p(c) -> inost(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% missing dtmp-3aib testing ???
    %% msa -> ala-B %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'msa(m)','ala-B(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'msa(m) -> ala-B(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% mthgxl -> 12ppd-S
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'mthgxl(c)','12ppd-S(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_12ppd-S(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'mthgxl(c) -> 12ppd-S(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% mthgxl -> lac-D
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'mthgxl(c)','lac-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_lac-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'mthgxl(c) -> lac-D(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% n2m2nmasn[l] -> man[l] + acgam[l]
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'n2m2nmasn(l)','man(l)','acgam(l)'},[-1 -1; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_acgam(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'n2m2nmasn[l] -> man[l] + acgam[l] (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% nm4masn[g] -> l2fn2m2masn[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'nm4masn(g)','l2fn2m2masn(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_l2fn2m2masn(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'nm4masn(g) -> l2fn2m2masn(g) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% nm4masn[g] -> n2m2nmasn[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'nm4masn(g)','n2m2nmasn(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_n2m2nmasn(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'nm4masn(g) -> n2m2nmasn(g) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% nm4masn[g] -> s2l2fn2m2masn[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'nm4masn(g)','s2l2fn2m2masn(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_s2l2fn2m2masn(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'nm4masn(g) -> s2l2fn2m2masn(g) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% npphr -> 34dhoxpeg %npphr does not exists
    % model = modelOri;
    % model.c(find(model.c)) = 0;
    % [model] = addSinkReactions(model,{'npphr(c)','34dhoxpeg(c)'},[-1 -1; 0 100]);
    % model.c(ismember(model.rxns,'sink_34dhoxpeg(c)'))=1;
    %   FBA = optimizeCbModel(model,'max','zero');
    % TestSolution(k,1) = FBA.f;
    % TestSolutionName{k,1} = 'npphr(c) -> 34dhoxpeg(c)';
    % k = k +1;clear FBA
    %% o2- -> h2o2 -> o2 + h2o
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'o2s(c)','h2o2(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_h2o2(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'o2- -> h2o2 -> o2 + h2o, 1';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model = modelOri;
    model.c(find(model.c)) = 0;

    model.lb(ismember(model.rxns,'EX_h2o(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'h2o2(c)','o2(c)','h2o(c)'},[-1 -1; -1 -1; 0.1 100]);
    model.c(ismember(model.rxns,'sink_h2o(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'o2- -> h2o2 -> o2 + h2o, 2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% orn -> nh4 v0.05
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'orn(c)','nh4(c)'},[-1 -1; 0 100]);
    model.lb(ismember(model.rxns,'EX_nh4(e)'))=0;model.ub(ismember(model.rxns,'EX_nh4(e)'))=1000;
    model.c(ismember(model.rxns,'sink_nh4(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'orn(c) -> nh4(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% orn -> ptrc
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'orn(c)','ptrc(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ptrc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'orn(c) -> ptrc(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% orn -> spmd
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'orn(c)','spmd(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_spmd(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'orn(c) -> spmd(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% orn -> sprm
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model,rxnsInModel] = addSinkReactions(model,{'orn(c)','sprm(c)'},[-1 -1; 0 100]);
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_sprm(c)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'orn(c) -> sprm(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pail_hs -> gpi_prot_hs[r]
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'pail_hs(c)','gpi_prot_hs(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gpi_prot_hs(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pail_hs(c) -> gpi_prot_hs(r) (with RMPI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pail45p -> mi145p
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pail45p_hs(c)','mi145p(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_mi145p(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pail45p(c) -> mi145p(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% phe-L -> pac
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'phe-L(c)','pac(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pac(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> pac(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% phe-L -> pacald
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'phe-L(c)','pacald(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pacald(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> pacald(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% phe-L -> peamn
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'phe-L(c)','peamn(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_peamn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> peamn(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% phe-L -> phaccoa
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'phe-L(c)','phaccoa(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_phe_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_phe_L(c)')))=-1;
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    model.c(ismember(model.rxns,'sink_phaccoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> phaccoa(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% phe-L -> pheacgln
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'phe-L(c)','pheacgln(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_phe_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_phe_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_pheacgln(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> pheacgln(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% phe-L -> phpyr
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'phe-L(c)','phpyr(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_phe_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_phe_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_phpyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> phpyr(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% phe-L -> tyr-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'phe-L(c)','tyr-L(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_phe_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_phe_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_tyr-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phe-L(c) -> tyr-L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pheme -> bilirub %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pheme(c)','bilirub(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_pheme(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_pheme(c)')))=-1;
    model.c(ismember(model.rxns,'sink_bilirub(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pheme(c) -> bilirub(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% phytcoa(x) -> dmnoncoa(m)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'phytcoa(x)','dmnoncoa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_dmnoncoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phytcoa(x) -> dmnoncoa(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pmtcoa(c) -> crmp_hs(c)
    model = modelOri;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pmtcoa(c)','crmp_hs(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_crmp_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pmtcoa(c) -> crmp_hs(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pmtcoa(c) -> sphmyln_hs(c)
    model = modelOri;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pmtcoa(c)','sphmyln_hs(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_sphmyln_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pmtcoa(c) -> sphmyln_hs(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ppcoa[m] -> succoa[m]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ppcoa(m)','succoa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_succoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ppcoa(m) -> succoa(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pro-L -> glu-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pro-L(c)','glu-L(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_pro_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_pro_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_glu-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_glu_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pro-L(c) -> glu-L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ptrc -> ala-B
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ptrc(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ptrc(c) -> ala-B(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ptrc -> spmd
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ptrc(c)','spmd(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_spmd(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ptrc(c) -> spmd(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pyr -> fad[m] + h[m] %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'pyr(c)','fadh2(m)','fad(m)','h(m)'},[-1 -1;-1 0;  0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_fad(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr -> fad[m] + h[m] (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pyr -> lac-D
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pyr(c)','lac-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_lac-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr(c) -> lac-D(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pyr -> nad[m] + h[m] %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'pyr(c)','nad(m)','h(m)'},[-1 -1; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_nad(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr -> nad[m] + h[m] (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pyr[c] -> accoa[m] + co2[c] + nadh[m] %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pyr(c)','accoa(m)','nadh(m)','co2(c)'},[-1 -1; 0.1 100; 0.1 100; 0.1 100]);
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    model.lb(find(ismember(model.rxns,'sink_nad(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_nad(c)')))=1;
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr[c] -> accoa[m] + co2(c) + nadh[m]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pyr<>ala-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pyr(c)','ala-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr(c) -> ala-L(c), 1';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ala-L(c)','pyr(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_ala_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_ala_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr(c) -> ala-L(c), 2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% R_group
    %% s2l2fn2m2masn[l] -> man[l] + acgam[l]
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'s2l2fn2m2masn(l)','man(l)','acgam(l)'},[-1 -1; 0.1 100; 0.1 100]);
    model.c(ismember(model.rxns,'sink_man(l)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 's2l2fn2m2masn(l) -> man[l] + acgam[l] (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% Ser/Thr[g] + udpacgal[g] -> core2[g] %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model = changeRxnBounds(model,'GALNTg',0.1,'l');
    [model] = addSinkReactions(model,{'Ser/Thr(g)';'udpacgal(g)';'core2(g)'},[-1 -1; -1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_core2(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser/Thr[g] + udpacgal[g] -> core2[g] - via GALNTg and DM_core4[g] (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% Ser/Thr[g] + udpacgal[g] -> core4[g] %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model = changeRxnBounds(model,'GALNTg',0.1,'l');
    [model] = addSinkReactions(model,{'Ser/Thr(g)';'udpacgal(g)';'core4(g)'},[-1 -1; -1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_core4(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser/Thr[g] + udpacgal[g] -> core4[g] - via GALNTg and DM_core4[g] (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% Ser/Thr[g] + udpacgal[g] -> dsTn_antigen[g] % dsTn_antigen does not exists
    % model = modelOri;
    % model.c(find(model.c)) = 0;
    % [model] = addSinkReactions(model,{'Ser/Thr(g)','udpacgal(g)','dsTn_antigen(g)'},[-1 -1;-1 -1; 0 100]);
    % model.c(ismember(model.rxns,'sink_dsTn_antigen(g)'))=1;
    %   FBA = optimizeCbModel(model,'max','zero');
    % TestSolution(k,1) = FBA.f;
    % TestSolutionName{k,1} = 'Ser/Thr[g] + udpacgal[g] -> dsTn_antigen[g]';
    % k = k +1;clear FBA
    %% Ser/Thr[g] + udpacgal[g] -> Tn_antigen[g] % dsTn_antigen does not exists
    % - I used Tn_antigen instead %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    [model] = addSinkReactions(model,{'Ser/Thr(g)','udpacgal(g)','Tn_antigen(g)'},[-1 -1;-1 -1; 0 100]);
    % model.c(ismember(model.rxns,'sink_Tn_antigen(g)'))=1;
    if ~isempty(strmatch('GALNTg',model.rxns,'exact'))
        model = changeObjective(model, 'GALNTg',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser/Thr[g] + udpacgal[g] -> Tn_antigen[g] - via GALNTg (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% Ser/Thr[g] + udpacgal[g] -> sTn_antigen[g] %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    if ~isempty(strmatch('GALNTg',model.rxns,'exact'))
        model = changeRxnBounds(model,'GALNTg',0.1,'l');
        [model] = addSinkReactions(model,{'Ser/Thr(g)','udpacgal(g)','sTn_antigen(g)'},[-1 -1;-1 -1; 0 100]);
        if (rxnsInModel(1) >-1) % reaction exits already in model
            model=changeObjective(model,model.rxns(rxnsInModel(1),1));
        else
            model=changeObjective(model,'sink_sTn_antigen(g)',1);
        end
        if find(model.c)>0
            FBA = optimizeCbModel(model,'max','zero');
            TestSolution(k,1) = FBA.f;
        else
            TestSolution(k,1) = NaN;
        end
        TestSolutionName{k,1} = 'Ser/Thr[g] + udpacgal[g] -> sTn_antigen[g] - via GALNTg and DM_sTn_antigen(g) (with RPMI medium)';
        if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    else
        TestSolution(k,1) = NaN;
        TestSolutionName{k,1} = 'Ser/Thr[g] + udpacgal[g] -> sTn_antigen[g] - via GALNTg and DM_sTn_antigen(g)';
        if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    end
    %% Ser-Gly/Ala-X-Gly[er] -> cs_pre[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','cs_pre(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cs_pre(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> cs_pre[g]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% Ser-Gly/Ala-X-Gly[er] -> cspg_a[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','cspg_a(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cspg_a(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> cspg_a[g]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% Ser-Gly/Ala-X-Gly[er] -> cspg_c[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','cspg_c(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cspg_c(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> cspg_c[g]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% Ser-Gly/Ala-X-Gly[er] -> cspg_d[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','cspg_d(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cspg_d(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> cspg_d[g]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% Ser-Gly/Ala-X-Gly[er] -> cspg_e[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','cspg_e(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cspg_e(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> cspg_e[g]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% Ser-Gly/Ala-X-Gly[er] -> hspg[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','hspg(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_hspg(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> hspg[g]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% Ser-Gly/Ala-X-Ser[er] -> cspg_b[g]
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Ser-Gly/Ala-X-Gly(r)','cspg_b(g)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_cspg_b(g)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Ser-Gly/Ala-X-Gly[r] -> cspg_b[g]';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ser-L -> cys-L
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ser-L(c)','cys-L(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_ser_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_ser_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_cys-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_cys_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ser-L(c) -> cys-L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% so4 -> PAPS
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'so4(c)','paps(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_paps(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'so4(c) -> paps(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% spmd -> sprm
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model,rxnsInModel] = addSinkReactions(model,{'spmd(c)','sprm(c)'},[-1 -1; 0 100]);
    %  model.c(ismember(model.rxns,'sink_sprm(c)'))=1;
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_sprm(c)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'spmd(c) -> sprm(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% srtn -> f5hoxkyn
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    [model] = addSinkReactions(model,{'srtn(c)','f5hoxkyn(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'DM_srtn(c)')))=-1;
    model.ub(find(ismember(model.rxns,'DM_srtn(c)')))=-1;
    model.c(ismember(model.rxns,'sink_f5hoxkyn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'srtn(c) -> f5hoxkyn(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% srtn -> fna5moxam
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    [model] = addSinkReactions(model,{'srtn(c)','fna5moxam(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'DM_srtn(c)')))=-1;
    model.ub(find(ismember(model.rxns,'DM_srtn(c)')))=-1;
    model.c(ismember(model.rxns,'sink_fna5moxam(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'srtn(c) -> fna5moxam(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% srtn -> nmthsrtn
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'srtn(c)','nmthsrtn(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'DM_srtn(c)')))=-1;
    model.ub(find(ismember(model.rxns,'DM_srtn(c)')))=-1;
    model.c(find(ismember(model.rxns,'sink_nmthsrtn(c)')))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'srtn(c) -> nmthsrtn(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% strch1[e] -> glc[e]
    model = modelOri;
    model.c(find(model.c)) = 0;
    model = changeRxnBounds(model,'EX_strch1(e)',-1,'l');
    model = changeRxnBounds(model,'EX_strch1(e)',-1,'u');
    model = changeRxnBounds(model,'EX_glc(e)',0,'l');
    model = changeRxnBounds(model,'EX_glc(e)',1000,'u');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    if ~isempty(strmatch('AMY1e',model.rxns,'exact'))
        model.c(ismember(model.rxns,'AMY1e'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'strch1(e) -> glc-D(e) via AMY1e';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% succoa[m] -> oaa[m]
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'succoa(m)','oaa(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_oaa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'succoa(m) -> oaa(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% taur(x) -> tchola(x)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'taur(x)','tchola(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_tchola(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'taur(x) -> tchola(x)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% thcholstoic(x) -> gchola(x)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'thcholstoic(x)','gchola(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_gchola(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thcholstoic(x) -> gchola(x)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% thcholstoic(x) -> tchola(x)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'thcholstoic(x)','tchola(x)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_tchola(x)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thcholstoic(x) -> tchola(x)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% thcholstoich(x) -> tchola(x) % thcholstoich does not exist in model
    % model = modelOri;
    % model.c(find(model.c)) = 0;
    % [model] = addSinkReactions(model,{'thcholstoich(x)','tchola(x)'},[-1 -1; 0 100]);
    % model.c(ismember(model.rxns,'sink_tchola(x)'))=1;
    %   FBA = optimizeCbModel(model,'max','zero');
    % TestSolution(k,1) = FBA.f;
    % TestSolutionName{k,1} = 'thcholstoich(x) -> tchola(x)';
    % k = k +1;clear FBA
    %% thr-L -> ppcoa
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'trp-L(c)','ppcoa(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    model.c(ismember(model.rxns,'sink_ppcoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> ppcoa(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% trp-L -> accoa
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'trp-L(c)','accoa(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    model.c(ismember(model.rxns,'sink_accoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> accoa(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% trp-L -> anth
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model,rxnsInModel] = addSinkReactions(model,{'trp-L(c)','anth(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_anth(c)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> anth(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% trp-L -> id3acald
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'trp-L(c)','id3acald(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_id3acald(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> id3acald(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% trp-L -> kynate
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'trp-L(c)','kynate(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_kynate(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> kynate(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% trp-L -> melatn
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'trp-L(c)','melatn(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_melatn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> melatn(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% trp-L -> melatn
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'trp-L(c)','Lfmkynr(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_Lfmkynr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> Lfmkynr(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% trp-L -> melatn
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'trp-L(c)','Lkynr(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_Lkynr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> Lkynr(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% trp-L -> melatn
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'trp-L(c)','nformanth(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_nformanth(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> nformanth(c)';
    model.lb(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% srtn(c) -> 5moxact(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    [model] = addSinkReactions(model,{'srtn(c)','5moxact(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'DM_srtn(c)')))=-1;
    model.ub(find(ismember(model.rxns,'DM_srtn(c)')))=-1;
    model.c(ismember(model.rxns,'sink_5moxact(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'srtn(c) -> 5moxact(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% srtn(c) -> 6hoxmelatn(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    [model] = addSinkReactions(model,{'srtn(c)','6hoxmelatn(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'DM_srtn(c)')))=-1;
    model.ub(find(ismember(model.rxns,'DM_srtn(c)')))=-1;
    model.c(ismember(model.rxns,'sink_6hoxmelatn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'srtn(c) -> 6hoxmelatn(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% trp-L -> quln
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'trp-L(c)','quln(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_quln(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> quln(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% trp-L -> srtn
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'trp-L(c)','srtn(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_trp_L(c)')))=-1;
    model.c(ismember(model.rxns,'DM_srtn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> srtn(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% Tyr-ggn -> glygn2
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'Tyr-ggn(c)','glygn2(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_Tyr-ggn(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_Tyr-ggn(c)')))=-1;
    model.c(ismember(model.rxns,'sink_glygn2(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Tyr-ggn(c) -> glygn2(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% tyr-L -> 34hpp
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'tyr-L(c)','34hpp(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_34hpp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> 34hpp(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% tyr-L -> 4hphac
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'tyr-L(c)','4hphac(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_4hphac(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> 4hphac(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% tyr-L -> adrnl
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'tyr-L(c)','adrnl(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_adrnl(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> adrnl(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% tyr-L -> dopa
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'tyr-L(c)','dopa(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_dopa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> dopa(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% tyr-L -> fum + acac
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'tyr-L(c)','fum(c)','acac(c)'},[-1 -1; 0.1 100; 0.1 100]);
    model.lb(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_fum(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> fum(c) + acac(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% tyr-L -> melanin
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model,rxnsInModel] = addSinkReactions(model,{'tyr-L(c)','melanin(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    if (rxnsInModel(2) >-1) % reaction exits already in model
        model=changeObjective(model,model.rxns(rxnsInModel(2),1));
    else
        model=changeObjective(model,'sink_melanin(c)',1);
    end
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> melanin(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% tyr-L -> nrpphr
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'tyr-L(c)','nrpphr(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_tyr_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_nrpphr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyr-L(c) -> nrpphr(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% uacgam + udpglcur -> ha[e] %changing lb has no effect
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'uacgam(c)','udpglcur(c)','ha(e)'},[-1 -1; -1 -1;0 100]);
    %model.c(ismember(model.rxns,'sink_ha(c)'))=1;
    if ~isempty(strmatch('HAS2',model.rxns,'exact'))
        model=changeObjective(model,'HAS2',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} =  'uacgamv(c) + udpglcur(c) -> ha[e] - via HAS2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% uacgam -> m8masn[r]
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'uacgam(c)','m8masn(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_m8masn(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'uacgam(c) -> m8masn(r)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% udpglcur -> xu5p-D
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'udpglcur(c)','xu5p-D(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_xu5p-D(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'udpglcur(c) -> xu5p-D(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ura -> ala-B
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'ura(c)','ala-B(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_ala-B(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ura(c) -> ala-B(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% val-L -> 3aib
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'val-L(c)','3aib(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_val_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_val_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_3aib(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'val-L(c) -> 3aib(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% val-L -> succoa
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'val-L(c)','succoa(m)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_val_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_val_L(c)')))=-1;
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    model.c(ismember(model.rxns,'sink_succoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'val-L(c) -> succoa(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% xoltriol(m) -> thcholstoic(m)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'xoltriol(m)','thcholstoic(m)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_thcholstoic(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'xoltriol(m) -> thcholstoic(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% xylu-D -> glyclt
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'xylu-D(c)','glyclt(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glyclt(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'xylu-D(c) -> glyclt(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
end

%% Test for IEC ori  - works only for models with 'u'=lumen compartments
if strcmp(test,'IECOri')
    % 1) glucose to lactate conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln_L(u)',0,'b');
    model=changeObjective(model,'EX_lac-L(e)');
    %FBA=optimizeCbModel(model,'min')
    FBA=optimizeCbModel(model,'max')
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glucose to lactate conversion';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

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
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to glucose conversion - ASPTAm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'FUM');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to glucose conversion - FUM';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'MDH');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to glucose conversion - MDH';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'G6PPer');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to glucose conversion - G6PPer';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 3); glutamine to proline conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_PRO-L(u)',0,'b');
    model=changeObjective(model,'P5CRm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to proline conversion - P5CRm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'P5CRxm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to proline conversion - P5CRxm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 4); glutamine to ornithine conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_ORN(U)',0,'b');
    model=changeObjective(model,'ORNTArm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to ornithine conversion - ORNTArm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 5); glutamine to citrulline converion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeObjective(model,'OCBTm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to citrulline converion - OCBTm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

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
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to lactate - LDH_L';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

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
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to aspartate - ASPTA';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

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
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to co2 - AKGDm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 9); glutamine to ammonia
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_GLU-L(u)',0,'b');
    model=changeObjective(model,'GLUNm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glutamine to ammonia - GLUNm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

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
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'putriscine to methionine (depends on oxygen uptake) - UNK2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 11); basolateral secretion of alanine
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeRxnBounds(model,'EX_GLU-L(u)',0,'b');
    model=changeRxnBounds(model,'EX_ala_L(u)',0,'b');
    model=changeObjective(model,'EX_ala_L(e)');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'basolateral secretion of alanine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 12); basolateral secretion of lactate
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',0,'b');
    model=changeRxnBounds(model,'EX_glc_D(u)',0,'b');
    model=changeObjective(model,'EX_lac-L(e)');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'basolateral secretion of lactate';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 13);synthesis of arginine from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_ARG-L(u)',0,'b');
    model=changeRxnBounds(model,'EX_arg_L(e)',0,'b');
    model=changeObjective(model,'ARGSL');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'synthesis of arginine from glutamine - ARGSL';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 14);synthesis of proline from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_PRO-L(u)',0,'b');
    model=changeRxnBounds(model,'EX_pro-L(e)',0,'b');
    model=changeObjective(model,'P5CR');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'synthesis of proline from glutamine - P5CR';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'P5CRm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'synthesis of proline from glutamine - P5CRm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'P5CRxm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'synthesis of proline from glutamine - P5CRxm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

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
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'synthesis of alanine from glutamine - ALATA_L';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 16); basolateral secretion of proline
    model=modelOri;
    model=changeRxnBounds(model,'EX_PRO-L(u)',0,'b');
    model=changeObjective(model,'EX_pro-L(e)');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'basolateral secretion of proline';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 17); basolateral secretion of arginine
    model=modelOri;
    model=changeRxnBounds(model,'EX_ARG-L(u)',0,'b');
    model=changeObjective(model,'EX_arg_L(e)');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'basolateral secretion of arginine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 18); basolateral secretion of ornithine
    model=modelOri;
    model=changeRxnBounds(model,'EX_ORN(U)',0,'b');
    model=changeObjective(model,'EX_orn(e)');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'basolateral secretion of ornithine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 19); synthesis of spermine from ornithine
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'SPRMS');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'synthesis of spermine from ornithine - SPRMS';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 20);synthesis of spermidine from ornithine
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'SPMS');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'synthesis of spermidine from ornithine - SPMS';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 21); synthesis of nitric oxide from arginine
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'NOS2');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'synthesis of nitric oxide from arginine - NOS2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 22); synthesis of cholesterol
    model=modelOri;
    model=changeRxnBounds(model,'EX_chsterol(u)',0,'b');
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'DSREDUCr');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'synthesis of cholesterol - DSREDUCr';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 23); denovo purine synthesis
    model=modelOri;
    model=changeObjective(model,'ADSL1');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'de novo purine synthesis - ADSL1';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'GMPS2');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'de novo purine synthesis - GMPS2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 24); salvage of purine bases
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'ADPT');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'salvage of purine bases - ADPT';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'GUAPRT');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'salvage of purine bases - GUAPRT';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'HXPRT');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'salvage of purine bases - HXPRT';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 25); purine catabolism
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'XAOx');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'purine catabolism - XAOx';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 26); pyrimidine synthesis (check for both with and without bicarbonate uptake);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_hco3(e)',-1,'l');
    model=changeObjective(model,'TMDS');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'pyrimidine synthesis (with hco3 uptake) - TMDS';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'CTPS2');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'pyrimidine synthesis (with hco3 uptake) - CTPS2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 27); pyrimidine catabolism
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_hco3(e)',-1,'l');
    model=changeObjective(model,'UPPN');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'pyrimidine catabolism - UPPN';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'BUP2');
    FBA=optimizeCbModel(model)
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'pyrimidine catabolism - BUP2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

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
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'fructose to glucose conversion - TRIOK';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 29); uptake and secretion of cholic acid
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_cholate(u)',-1,'l');
    model=changeObjective(model,'CHOLATEt2u');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'uptake and secretion of cholic acid - CHOLATEt2u'; % SHOULD THIS BE MIN?
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'CHOLATEt3');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'uptake and secretion of cholic acid - CHOLATEt3';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 30); Uptake and secretion of glycocholate
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_GCHOLA(u)',-1,'l');
    model=changeObjective(model,'GCHOLAt2u');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'uptake and secretion of cholic glycocholate - GCHOLAt2u';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'GCHOLAt3');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'uptake and secretion of cholic glycocholate - GCHOLAt3';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 31); Uptake and secretion of tauro-cholate
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_TCHOLA(u)',-1,'l');
    model=changeObjective(model,'TCHOLAt2u');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'uptake and secretion of tauro-cholate - TCHOLAt2u';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'TCHOLAt3');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'uptake and secretion of tauro-cholate - TCHOLAt3';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 32); Synthesis of fructose-6-phosphate from erythrose-4-phosphate (HMP shunt);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'TKT2');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Synthesis of fructose-6-phosphate from erythrose-4-phosphate (HMP shunt) - TKT2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 33); Malate to pyruvate (malic enzyme);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'ME2');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Malate to pyruvate (malic enzyme) - ME2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeObjective(model,'ME2m');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Malate to pyruvate (malic enzyme) - ME2m';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 34); Synthesis of urea (urea cycle);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_arg_L(e)',-1,'l');
    model=changeObjective(model,'ARGN');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Synthesis of urea (urea cycle) - ARGN';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

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
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Cysteine to pyruvate - 3SPYRSP';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 36); Methionine to cysteine  (check for dependancy over pe_hs);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_pe_hs(u)',-1,'l');
    model=changeRxnBounds(model,'EX_cys_L(u)',0,'b');
    model=changeObjective(model,'CYSTGL');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Methionine to cysteine - CYSTGL';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 37); Synthesis of triacylglycerol (TAG reformation); (check for dependancy over dag_hs and RTOTAL3);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_dag_hs(u)',-1,'l');
    model=changeRxnBounds(model,'EX_RTOTAL3(u)',-1,'l');
    model=changeRxnBounds(model,'EX_TAG_HS(u)',0,'b');
    model=changeObjective(model,'DGAT');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Synthesis of triacylglycerol (TAG reformation) - DGAT';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 38); Phosphatidylcholine synthesis (check for dependancy over pe_hs);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_pe_hs(u)',-1,'l');
    model=changeRxnBounds(model,'EX_PCHOL_HS(u)',0,'b');
    model=changeObjective(model,'PETOHMm_hs');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Phosphatidylcholine synthesis - PETOHMm_hs';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 39); Synthesis of FMN from riboflavin
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_fmn(u)',0,'b');
    model=changeObjective(model,'RBFK');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Synthesis of FMN from riboflavin - RBFK';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 40); synthesis of FAD from riboflavin
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_FAD(u)',0,'b');
    model=changeObjective(model,'FMNAT');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'synthesis of FAD from riboflavin - FMNAT';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 41); Synthesis of 5-methyl-tetrahydrofolate from folic acid
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_5mthf(u)',0,'b');
    model=changeObjective(model,'MTHFR3');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Synthesis of 5-methyl-tetrahydrofolate from folic acid - MTHFR3';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 42); Putriscine to GABA
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_4ABUT(u)',0,'b');
    model=changeObjective(model,'ABUTD');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Putriscine to GABA - ABUTD';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 43); Superoxide dismutase
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'SPODMm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Superoxide dismutase - SPODMm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 44); Availability of bicarbonate from Carbonic anhydrase reaction
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'H2CO3Dm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Availability of bicarbonate from Carbonic anhydrase reaction - H2CO3Dm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 45); Regeneration of citrate (TCA cycle);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'CSm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Regeneration of citrate (TCA cycle) - CSm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 46); Histidine to FIGLU
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'IZPN');
    FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');

    % 47); binding of guar gum fiber to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_GUM(u)',-1,'l');
    model=changeRxnBounds(model,'EX_GCHOLA(u)',-1,'l');
    model=changeObjective(model,'EX_GUMGCHOL(u)');
    FBA=optimizeCbModel(model,'min');
    %FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'binding of guar gum fiber to bile acids - EX_GUMGCHOL(e)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_TCHOLA(u)',-1,'l');
    model=changeObjective(model,'GUMTCHOLe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'binding of guar gum fiber to bile acids - GUMTCHOLe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_DCHAC(u)',-1,'l');
    model=changeObjective(model,'GUMDCHAe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'binding of guar gum fiber to bile acids - GUMDCHAe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 48); binding of psyllium fiber to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_PSYL(u)',-1,'l');
    model=changeRxnBounds(model,'EX_GCHOLA(u)',-1,'l');
    model=changeObjective(model,'PSYGCHe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'binding of psyllium fiber to bile acids - PSYGCHe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_TCHOLA(u)',-1,'l');
    model=changeObjective(model,'PSYTCHe');
    FBA=optimizeCbModel(model,'min');
    %FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'binding of psyllium fiber to bile acids - PSYTCHe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_TDECHOLA(u)',-1,'l');
    model=changeObjective(model,'PSYTDECHe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'binding of psyllium fiber to bile acids - PSYTDECHe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 49);binding to beta glucan fibers to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_BGLC(u)',-1,'l');
    model=changeRxnBounds(model,'EX_GCHOLA(u)',-1,'l');
    model=changeObjective(model,'BGLUGCHe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'binding to beta glucan fibers to bile acids - BGLUGCHe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_TCHOLA(u)',-1,'l');
    model=changeObjective(model,'BGLUTCHLe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'binding to beta glucan fibers to bile acids - BGLUTCHLe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_TDECHOLA(u)',-1,'l');
    model=changeObjective(model,'BGLUTDECHOe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'binding to beta glucan fibers to bile acids - BGLUTDECHOe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 50); binding of pectin fiber to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_PECT(u)',-1,'l');
    model=changeRxnBounds(model,'EX_GCHOLA(u)',-1,'l');
    model=changeObjective(model,'PECGCHLe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'binding of pectin fiber to bile acids - PECGCHLe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_TCHOLA(u)',-1,'l');
    model=changeObjective(model,'PECTCHLe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'binding of pectin fiber to bile acids - PECTCHLe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    model=changeRxnBounds(model,'EX_DCHAC(u)',-1,'l');
    model=changeObjective(model,'PECDCHe');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'binding of pectin fiber to bile acids - PECDCHe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 52); heme synthesis
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'FCLTm');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'heme synthesis - FCLTm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    % 53); heme degradation
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeObjective(model,'HOXG');
    %FBA=optimizeCbModel(model,'min');
    FBA=optimizeCbModel(model,'max');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'heme degradation - HOXG';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
end

%% metabolic tasks based on Enterocyte model - without original ('u')
% compartment I deleted the last argument in changeObjective from here
% onwards (SS)
if strcmp(test,'IEC') || strcmp(test,'all')|| strcmp(test,'Harvey')
    %% glucose to lactate conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_glc(e)',-1,'b');
    if ~isempty(strmatch('EX_lac-L(e)',model.rxns,'exact'))
        model=changeObjective(model,'EX_lac-L(e)',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glucose to lactate conversion';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %%  glutamine to glucose conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model=changeRxnBounds(model,'EX_glc(e)',0,'b');
    model=changeRxnBounds(model,'EX_malt(e)',0,'b');
    model=changeRxnBounds(model,'EX_strch1(e)',0,'b');
    model=changeRxnBounds(model,'EX_strch2(e)',0,'b');
    model=changeRxnBounds(model,'EX_sucr(e)',0,'b');

    if ~isempty(strmatch('GLUNm',model.rxns,'exact'))
        model=changeObjective(model,'GLUNm',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to glucose conversion - GLUNm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% glutamine to glucose conversion - ASPTAm
    if ~isempty(strmatch('ASPTAm',model.rxns,'exact'))
        model=changeObjective(model,'ASPTAm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to glucose conversion - ASPTAm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% 'glutamine to glucose conversion - FUM'
    if ~isempty(strmatch('FUM',model.rxns,'exact'))
        model=changeObjective(model,'FUM',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to glucose conversion - FUM';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glutamine to glucose conversion - MDH
    if ~isempty(strmatch('MDH',model.rxns,'exact'))
        model=changeObjective(model,'MDH',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to glucose conversion - MDH';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glutamine to glucose conversion - G6PPer
    if ~isempty(strmatch('G6PPer',model.rxns,'exact'))
        model=changeObjective(model,'G6PPer',1);
        FBA = optimizeCbModel(model,'max','zero');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to glucose conversion - G6PPer';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glutamine to proline conversion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model=changeRxnBounds(model,'EX_glc(e)',0,'b');
    model=changeRxnBounds(model,'EX_pro-L(e)',0,'b');

    if ~isempty(strmatch('P5CRm',model.rxns,'exact'))
        model=changeObjective(model,'P5CRm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to proline conversion - P5CRm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glutamine to proline conversion - P5CRxm
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model=changeRxnBounds(model,'EX_glc(e)',0,'b');
    model=changeRxnBounds(model,'EX_pro-L(e)',0,'b');

    if ~isempty(strmatch('P5CRxm',model.rxns,'exact'))
        model=changeObjective(model,'P5CRxm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to proline conversion - P5CRxm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% glutamine to ornithine conversion
    model=modelOri;

    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'l');
    if ~isempty(strmatch('ORNTArm',model.rxns,'exact'))
        model=changeObjective(model,'ORNTArm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to ornithine conversion - ORNTArm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% glutamine to citrulline converion
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    if ~isempty(strmatch('OCBTm',model.rxns,'exact'))
        model=changeObjective(model,'OCBTm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to citrulline converion - OCBTm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% glutamine to lactate
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    if ~isempty(strmatch('LDH_L',model.rxns,'exact'))
        model=changeObjective(model,'LDH_L',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to lactate - LDH_L';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% glutamine to aspartate
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    if ~isempty(strmatch('ASPTA',model.rxns,'exact'))
        model=changeObjective(model,'ASPTA',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to aspartate - ASPTA';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% glutamine to co2
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    if ~isempty(strmatch('AKGDm',model.rxns,'exact'))
        model=changeObjective(model,'AKGDm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to co2 - AKGDm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glutamine to ammonia
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    if ~isempty(strmatch('GLUNm',model.rxns,'exact'))
        model=changeObjective(model,'GLUNm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine to ammonia - GLUNm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% putriscine to methionine (depends on oxygen uptake);
    model=modelOri;
    model=changeRxnBounds(model,'EX_ptrc(e)',-1,'b');
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    if ~isempty(strmatch('UNK2',model.rxns,'exact'))
        model=changeObjective(model,'UNK2',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'putriscine to methionine (depends on oxygen uptake) - UNK2';
    if ~isnan(TestSolution(k,1)); if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ; end ;k = k +1;clear FBA

    %%  secretion of alanine
    model=modelOri;

    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('EX_ala_L(e)',model.rxns,'exact'))
        model=changeObjective(model,'EX_ala_L(e)',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'secretion of alanine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %%  secretion of lactate
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('EX_lac-L(e)',model.rxns,'exact'))
        model=changeObjective(model,'EX_lac-L(e)');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'secretion of lactate';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% synthesis of arginine from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('ARGSL',model.rxns,'exact'))
        model=changeObjective(model,'ARGSL',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of arginine from glutamine - ARGSL';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% synthesis of proline from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('P5CR',model.rxns,'exact'))
        model=changeObjective(model,'P5CR',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of proline from glutamine - P5CR';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% synthesis of proline from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('P5CRm',model.rxns,'exact'))
        model=changeObjective(model,'P5CRm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of proline from glutamine - P5CRm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% synthesis of proline from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('P5CRxm',model.rxns,'exact'))
        model=changeObjective(model,'P5CRxm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of proline from glutamine - P5CRxm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% synthesis of alanine from glutamine
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gln-L(e)',-1,'b');
    if ~isempty(strmatch('ALATA_L',model.rxns,'exact'))
        model=changeObjective(model,'ALATA_L',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of alanine from glutamine - ALATA_L';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% basolateral secretion of proline
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('EX_pro-L(e)',model.rxns,'exact'))
        model=changeObjective(model,'EX_pro-L(e)',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'secretion of proline';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% basolateral secretion of arginine
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('EX_arg-L(e)',model.rxns,'exact'))
        model=changeObjective(model,'EX_arg-L(e)',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'secretion of arginine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% basolateral secretion of ornithine
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('EX_orn(e)',model.rxns,'exact'))
        model=changeObjective(model,'EX_orn(e)',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'secretion of ornithine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% synthesis of spermine from ornithine
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_orn(e)'))=-1;model.ub(ismember(model.rxns,'EX_orn(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('SPRMS',model.rxns,'exact'))
        model=changeObjective(model,'SPRMS',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of spermine from ornithine - SPRMS';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% synthesis of spermidine from ornithine
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_orn(e)'))=-1;model.ub(ismember(model.rxns,'EX_orn(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('SPMS',model.rxns,'exact'))
        model=changeObjective(model,'SPMS',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of spermidine from ornithine - SPMS';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% synthesis of nitric oxide from arginine
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_arg-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_arg-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('NOS2',model.rxns,'exact'))
        model=changeObjective(model,'NOS2',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of nitric oxide from arginine - NOS2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %%  synthesis of cholesterol
    model=modelOri;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    if ~isempty(strmatch('DSREDUCr',model.rxns,'exact'))
        model=changeObjective(model,'DSREDUCr',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of cholesterol - DSREDUCr (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% denovo purine synthesis
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('ADSL1',model.rxns,'exact'))
        model=changeObjective(model,'ADSL1',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'de novo purine synthesis - ADSL1';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% de novo purine synthesis - GMPS2
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('GMPS2',model.rxns,'exact'))
        model=changeObjective(model,'GMPS2');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'de novo purine synthesis - GMPS2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% salvage of purine bases
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('ADPT',model.rxns,'exact'))
        model=changeObjective(model,'ADPT',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'salvage of purine bases - ADPT';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% salvage of purine bases - GUAPRT
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('GUAPRT',model.rxns,'exact'))
        model=changeObjective(model,'GUAPRT',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'salvage of purine bases - GUAPRT';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% salvage of purine bases - HXPRT
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('HXPRT',model.rxns,'exact'))
        model=changeObjective(model,'HXPRT',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'salvage of purine bases - HXPRT';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% purine catabolism
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('XAOx',model.rxns,'exact'))
        model=changeObjective(model,'XAOx',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'purine catabolism - XAOx';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% pyrimidine synthesis (with hco3 uptake) - TMDS
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model=changeRxnBounds(model,'EX_hco3(e)',-1,'b');
    if ~isempty(strmatch('TMDS',model.rxns,'exact'))
        model=changeObjective(model,'TMDS',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyrimidine synthesis (with hco3 uptake) - TMDS';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% pyrimidine synthesis (with hco3 uptake) - CTPS2
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model=changeRxnBounds(model,'EX_hco3(e)',-1,'b');
    if ~isempty(strmatch('CTPS2',model.rxns,'exact'))
        model=changeObjective(model,'CTPS2',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyrimidine synthesis (with hco3 uptake) - CTPS2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% pyrimidine catabolism
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model=changeRxnBounds(model,'EX_hco3(e)',-1,'b');
    if ~isempty(strmatch('UPPN',model.rxns,'exact'))
        model=changeObjective(model,'UPPN',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyrimidine catabolism - UPPN';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% 'pyrimidine catabolism - BUP2
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model=changeRxnBounds(model,'EX_hco3(e)',-1,'b');
    if ~isempty(strmatch('BUP2',model.rxns,'exact'))
        model=changeObjective(model,'BUP2',1);
        FBA=optimizeCbModel(model)
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyrimidine catabolism - BUP2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% fructose to glucose conversion
    model=modelOri;

    model.lb(ismember(model.rxns,'EX_fru(e)'))=-1;model.ub(ismember(model.rxns,'EX_fru(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('TRIOK',model.rxns,'exact'))
        model=changeObjective(model,'TRIOK',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fructose to glucose conversion - TRIOK';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% uptake and secretion of cholic acid
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_cholate(e)',-1,'l');
    model=changeRxnBounds(model,'EX_cholate(e)',1000,'u');
    % model=changeObjective(model,'CHOLATEt2u');
    %FBA=optimizeCbModel(model,'min');
    %FBA=optimizeCbModel(model,'max');
    % TestSolution(k,1) = FBA.f;
    % TestSolutionName{k,1} = 'uptake and secretion of cholic acid - CHOLATEt2u'; % SHOULD THIS BE MIN?
    % k = k +1;clear FBA
    if ~isempty(strmatch('CHOLATEt3',model.rxns,'exact'))
        model=changeObjective(model,'CHOLATEt3',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
        TestSolutionName{k,1} = 'uptake of cholic acid - CHOLATEt3';
    else
        TestSolution(k,1) = NaN;
    end
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %     if ~isempty(strmatch('CHOLATEt3',model.rxns,'exact'))
    %         FBA=optimizeCbModel(model,'min');
    %         TestSolution(k,1) = FBA.f;
    %     else
    %         TestSolution(k,1) = NaN;
    %     end
    %     TestSolutionName{k,1} = 'secretion of cholic acid - CHOLATEt3';
    %  if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% Uptake and secretion of glycocholate
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gchola(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gchola(e)',1000,'u');
    % model=changeObjective(model,'GCHOLAt2u');
    %FBA=optimizeCbModel(model,'min');
    %FBA=optimizeCbModel(model,'max');
    %TestSolution(k,1) = FBA.f;
    %TestSolutionName{k,1} = 'uptake and secretion of cholic glycocholate - GCHOLAt2u';
    %k = k +1;clear FBA
    if ~isempty(strmatch('GCHOLAt3',model.rxns,'exact'))
        model=changeObjective(model,'GCHOLAt3',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'uptake of cholic glycocholate - GCHOLAt3';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %     if ~isempty(strmatch('GCHOLAt3',model.rxns,'exact'))
    %         FBA=optimizeCbModel(model,'min');
    %         TestSolution(k,1) = FBA.f;
    %     else
    %         TestSolution(k,1) = NaN;
    %     end
    %     TestSolutionName{k,1} = 'secretion of cholic glycocholate - GCHOLAt3';
    %  if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% Uptake and secretion of tauro-cholate
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_tchola(e)',-1,'l');
    model=changeRxnBounds(model,'EX_tchola(e)',1000,'u');
    % model=changeObjective(model,'TCHOLAt2u');
    %FBA=optimizeCbModel(model,'min');
    %FBA=optimizeCbModel(model,'max');
    %TestSolution(k,1) = FBA.f;
    % TestSolutionName{k,1} = 'uptake and secretion of tauro-cholate - TCHOLAt2u';
    %k = k +1;clear FBA
    if ~isempty(strmatch('TCHOLAt3',model.rxns,'exact'))
        model=changeObjective(model,'TCHOLAt3',1);
        % FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'uptake of tauro-cholate - TCHOLAt3';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %     if ~isempty(strmatch('TCHOLAt3',model.rxns,'exact'))
    %         FBA=optimizeCbModel(model,'min');
    %         TestSolution(k,1) = FBA.f;
    %     else
    %         TestSolution(k,1) = NaN;
    %     end
    %     TestSolutionName{k,1} = 'secretion of tauro-cholate - TCHOLAt3';
    %  if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% Synthesis of fructose-6-phosphate from erythrose-4-phosphate (HMP shunt);
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('TKT2',model.rxns,'exact'))
        model=changeObjective(model,'TKT2',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Synthesis of fructose-6-phosphate from erythrose-4-phosphate (HMP shunt) - TKT2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% Malate to pyruvate (malic enzyme);
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('ME2',model.rxns,'exact'))
        model=changeObjective(model,'ME2',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Malate to pyruvate (malic enzyme) - ME2';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% Malate to pyruvate (malic enzyme);
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('ME2m',model.rxns,'exact'))
        model=changeObjective(model,'ME2m',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Malate to pyruvate (malic enzyme) - ME2m';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% Synthesis of urea (urea cycle);
    model=modelOri;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    if ~isempty(strmatch('ARGN',model.rxns,'exact'))
        model=changeObjective(model,'ARGN',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Synthesis of urea (urea cycle) - ARGN (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% Cysteine to pyruvate
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_cys-L(e)',-1,'b');
    if ~isempty(strmatch('3SPYRSP',model.rxns,'exact'))
        model=changeObjective(model,'3SPYRSP',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Cysteine to pyruvate - 3SPYRSP';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% Methionine to cysteine  (check for dependancy over pe_hs);
    model=modelOri;
    model=changeRxnBounds(model,'EX_met_L(e)',-1,'b');
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_pe_hs(e)',-1,'l');
    if ~isempty(strmatch('CYSTGL',model.rxns,'exact'))
        model=changeObjective(model,'CYSTGL',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Methionine to cysteine - CYSTGL';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% Synthesis of triacylglycerol (TAG reformation); (check for dependancy over dag_hs and RTOTAL3);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_dag_hs(e)',-1,'l');
    model=changeRxnBounds(model,'EX_Rtotal3(e)',-1,'l');
    if ~isempty(strmatch('DGAT',model.rxns,'exact'))
        model=changeObjective(model,'DGAT');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Synthesis of triacylglycerol (TAG reformation) - DGAT';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% Phosphatidylcholine synthesis (check for dependancy over pe_hs);
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_pe_hs(e)',-1,'l');
    if ~isempty(strmatch('PETOHMm_hs',model.rxns,'exact'))
        model=changeObjective(model,'PETOHMm_hs',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Phosphatidylcholine synthesis - PETOHMm_hs';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% Synthesis of FMN from riboflavin
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    model=changeRxnBounds(model,'EX_ribflv(e)',-1,'b');
    if ~isempty(strmatch('RBFK',model.rxns,'exact'))
        model=changeObjective(model,'RBFK',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Synthesis of FMN from riboflavin - RBFK';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% synthesis of FAD from riboflavin
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    model=changeRxnBounds(model,'EX_ribflv(e)',-1,'b');
    if ~isempty(strmatch('FMNAT',model.rxns,'exact'))
        model=changeObjective(model,'FMNAT',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'synthesis of FAD from riboflavin - FMNAT';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% Synthesis of 5-methyl-tetrahydrofolate from folic acid
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_fol(e)',-1,'b');
    if ~isempty(strmatch('MTHFR3',model.rxns,'exact'))
        model=changeObjective(model,'MTHFR3',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Synthesis of 5-methyl-tetrahydrofolate from folic acid - MTHFR3';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% Putriscine to GABA
    model=modelOri;
    model=changeRxnBounds(model,'EX_o2(e)',-1,'l');
    model=changeRxnBounds(model,'EX_ptrc(e)',-1,'b');
    if ~isempty(strmatch('ABUTD',model.rxns,'exact'))
        model=changeObjective(model,'ABUTD',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Putriscine to GABA - ABUTD';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% Superoxide dismutase
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('SPODMm',model.rxns,'exact'))
        model=changeObjective(model,'SPODMm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Superoxide dismutase - SPODMm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% Availability of bicarbonate from Carbonic anhydrase reaction
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('H2CO3Dm',model.rxns,'exact'))
        model=changeObjective(model,'H2CO3Dm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Availability of bicarbonate from Carbonic anhydrase reaction - H2CO3Dm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% Regeneration of citrate (TCA cycle);
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('CSm',model.rxns,'exact'))
        model=changeObjective(model,'CSm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Regeneration of citrate (TCA cycle) - CSm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% Histidine to FIGLU
    model=modelOri;
    model.lb(find(ismember(model.rxns,'EX_his-L(e)')))=-1;
    model.ub(find(ismember(model.rxns,'EX_his-L(e)')))=-1;
    model=changeRxnBounds(model,'EX_o2(e)',-40,'l');
    model=changeRxnBounds(model,'EX_o2(e)',-1,'u');
    if ~isempty(strmatch('IZPN',model.rxns,'exact'))
        model=changeObjective(model,'IZPN',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'Histidine to FIGLU - IZPN';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    %% binding of guar gum fiber to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_gum(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gchola(e)',-1,'l');
    if ~isempty(strmatch('EX_gumgchol(e)',model.rxns,'exact'))
        model=changeObjective(model,'EX_gumgchol(e)',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of guar gum fiber to bile acids - EX_gumgchol(e)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    model=modelOri;
    model=changeRxnBounds(model,'EX_tchola(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gum(e)',-1,'l');

    if ~isempty(strmatch('GUMTCHOLe',model.rxns,'exact'))
        model=changeObjective(model,'GUMTCHOLe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of guar gum fiber to bile acids - GUMTCHOLe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    model=modelOri;
    if ~isempty(strmatch('GUMDCHAe',model.rxns,'exact'))
        model=changeRxnBounds(model,'EX_dchac(e)',-1,'l');
        model=changeRxnBounds(model,'EX_gum(e)',-1,'l');
        model=changeObjective(model,'GUMDCHAe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of guar gum fiber to bile acids - GUMDCHAe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% binding of psyllium fiber to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_psyl(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gchola(e)',-1,'l');
    if ~isempty(strmatch('PSYGCHe',model.rxns,'exact'))
        model=changeObjective(model,'PSYGCHe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of psyllium fiber to bile acids - PSYGCHe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA


    model=modelOri;
    model=changeRxnBounds(model,'EX_psyl(e)',-1,'l');
    model=changeRxnBounds(model,'EX_tchola(e)',-1,'l');
    if ~isempty(strmatch('PSYTCHe',model.rxns,'exact'))
        model=changeObjective(model,'PSYTCHe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of psyllium fiber to bile acids - PSYTCHe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    model=modelOri;
    if ~isempty(strmatch('PSYTDECHe',model.rxns,'exact'))
        model=changeRxnBounds(model,'EX_tdechola(e)',-1,'l');
        model=changeRxnBounds(model,'EX_psyl(e)',-1,'l');
        model=changeObjective(model,'PSYTDECHe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of psyllium fiber to bile acids - PSYTDECHe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% binding to beta glucan fibers to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_bglc(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gchola(e)',-1,'l');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('BGLUGCHe',model.rxns,'exact'))
        model=changeObjective(model,'BGLUGCHe',1);
        %FBA=optimizeCbModel(model,'min');
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding to beta glucan fibers to bile acids - BGLUGCHe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    model=modelOri;
    model=changeRxnBounds(model,'EX_bglc(e)',-1,'l');
    model=changeRxnBounds(model,'EX_tchola(e)',-1,'l');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('BGLUTCHLe',model.rxns,'exact'))
        model=changeObjective(model,'BGLUTCHLe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding to beta glucan fibers to bile acids - BGLUTCHLe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    model=modelOri;
    model=changeRxnBounds(model,'EX_bglc(e)',-1,'l');
    model=changeRxnBounds(model,'EX_tdechola(e)',-1,'l');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('BGLUTDECHOe',model.rxns,'exact'))
        model=changeObjective(model,'BGLUTDECHOe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding to beta glucan fibers to bile acids - BGLUTDECHOe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% binding of pectin fiber to bile acids
    model=modelOri;
    model=changeRxnBounds(model,'EX_pect(e)',-1,'l');
    model=changeRxnBounds(model,'EX_gchola(e)',-1,'l');
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('PECGCHLe',model.rxns,'exact'))
        model=changeObjective(model,'PECGCHLe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of pectin fiber to bile acids - PECGCHLe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    model=modelOri;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model=changeRxnBounds(model,'EX_pect(e)',-1,'l');
    model=changeRxnBounds(model,'EX_tchola(e)',-1,'l');
    if ~isempty(strmatch('PECTCHLe',model.rxns,'exact'))
        model=changeObjective(model,'PECTCHLe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of pectin fiber to bile acids - PECTCHLe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    model=modelOri;
    if ~isempty(strmatch('PECDCHe',model.rxns,'exact'))
        model=changeRxnBounds(model,'EX_dchac(e)',-1,'l');
        model=changeRxnBounds(model,'EX_pect(e)',-1,'l');
        model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
        model=changeObjective(model,'PECDCHe',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'binding of pectin fiber to bile acids - PECDCHe';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% heme synthesis
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    if ~isempty(strmatch('FCLTm',model.rxns,'exact'))
        model=changeObjective(model,'FCLTm',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'heme synthesis - FCLTm';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% heme degradation
    model=modelOri;
    model.lb(ismember(model.rxns,'EX_pheme(e)'))=-1;model.ub(ismember(model.rxns,'EX_pheme(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    if ~isempty(strmatch('HOXG',model.rxns,'exact'))
        model=changeObjective(model,'HOXG',1);
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'heme degradation - HOXG';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

end

%% these functions are new based on muscle and kidney work of SS

if strcmp(test,'all')|| strcmp(test,'Harvey')

    %% Muscle objectives: valine -> pyruvate
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_val_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_val_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pyr(m)'},[0 100]);
    model.c(ismember(model.rxns,'sink_pyr(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'valine -> pyruvate';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% leucine -> pyruvate
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_leu_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_leu_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pyr(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'leucine -> pyruvate';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% isoleucine -> pyruvate
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_ile_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_ile_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pyr(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'isoleucine -> pyruvate';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% threonine -> alanine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_thr_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_thr_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'threonine -> alanine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% aspartate -> pyruvate
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_asp_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_asp_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pyr(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_pyr(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'aspartate -> pyruvate';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% serine -> alanine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_ser_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_ser_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'serine -> alanine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glycine -> alanine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_gly(e)'))=-1;model.ub(ismember(model.rxns,'EX_gly(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glycine -> alanine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% aspartate -> alanine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_asp_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_asp_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'aspartate -> alanine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% tyrosine -> glutamine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_tyr_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_tyr_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tyrosine -> glutamine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% lysine -> glutamine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_lys-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_lys-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'lysine -> glutamine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% phenylalanine -> glutamine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_phe_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_phe_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phenylalanine -> glutamine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cysteine -> glutamine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_cys-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_cys-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cysteine -> glutamine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cysteine -> alanine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_cys-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_cys-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cysteine -> alanine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% leucine -> glutamine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_leu_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_leu_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'leucine -> glutamine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% leucine -> alanine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_leu_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_leu_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'leucine -> alanine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% valine -> glutamine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_val_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_val_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'valine -> glutamine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% valine -> alanine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_val_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_val_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'valine -> alanine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% isoleucine -> glutamine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_ile_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_ile_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'isoleucine -> glutamine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% isoleucine -> alanine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_ile_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_ile_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'isoleucine -> alanine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% methionine -> glutamine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_met_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_met_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'methionine -> glutamine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% methionine -> alanine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_met_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_met_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ala-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ala-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_ala_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'methionine -> alanine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arginine -> ornithine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_arg-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_arg-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'orn(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_orn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arginine -> ornithine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arginine -> proline
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_arg-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_arg-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pro-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_pro-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_pro_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arginine -> proline';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ornithine -> putrescine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_orn(e)'))=-1;model.ub(ismember(model.rxns,'EX_orn(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ptrc(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ptrc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ornithine -> putrescine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glutamate -> glutamine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_glu-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_glu-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'gln-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_gln_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamate -> glutamine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% methionine -> spermine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_met_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_met_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'sprm(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_sprm(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'methionine -> spermine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% methionine -> spermidine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_met_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_met_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'spmd(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_spmd(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'methionine -> spermidine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% spermidine -> putrescine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_spmd(e)'))=-1;model.ub(ismember(model.rxns,'EX_spmd(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'ptrc(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_ptrc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'spermidine -> putrescine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ADP -> ATP/ adenylate kinase
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    if ~isempty(strmatch('AK1',model.rxns,'exact'))
        model.c(ismember(model.rxns,'AK1'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ADP -> ATP/ adenylate kinase';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ADP -> ATP/ adenylate kinase
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    if ~isempty(strmatch('AK1',model.rxns,'exact'))
        model.c(ismember(model.rxns,'AK1m'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ADP -> ATP/ adenylate kinase (mitochondrial)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% phosphocreatine -> creatine/ cytosolic creatine kinase
    model = modelOri;
    model.c(find(model.c)) = 0;
    model = addReaction(model,'EX_pcreat(e)','pcreat[e] <=>');
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    model.lb(ismember(model.rxns,'EX_pcreat(e)'))=-1;model.ub(ismember(model.rxns,'EX_pcreat(e)'))=-1;
    [model] = addSinkReactions(model,{'creat(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_creat(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'phosphocreatine -> creatine/ cytosolic creatine kinase';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% creatine -> phosphocreatine/mitochondrial creatine kinase
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_creat(e)'))=-1;model.ub(ismember(model.rxns,'EX_creat(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'pcreat(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_pcreat(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'creatine -> phosphocreatine/mitochondrial creatine kinase';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% fructose -> lactate/ oxidation of fructose
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_fru(e)'))=-1;model.ub(ismember(model.rxns,'EX_fru(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'lac-L(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_lac-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fructose -> lactate/ oxidation of fructose';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% fructose -> glycogen/ glycogenesis
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_fru(e)'))=-1;model.ub(ismember(model.rxns,'EX_fru(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'glygn2(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_glygn2(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fructose -> glycogen/ glycogenesis';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glucose -> erythrose/ HMP shunt
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'e4p(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_e4p(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glucose -> erythrose/ HMP shunt';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% tag_hs(c) -> mag_hs(c)/ lipolysis
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_tag_hs(e)'))=-1;model.ub(ismember(model.rxns,'EX_tag_hs(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'mag-hs(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_mag-hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tag_hs(c) -> mag_hs(c)/ lipolysis';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% tag_hs(c) -> glyc(c)/ lipolysis
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_tag_hs(e)'))=-1;model.ub(ismember(model.rxns,'EX_tag_hs(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'glyc(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_glyc(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'tag_hs(c) -> glyc(c)/ lipolysis';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pmtcoa -> acetylCoA/ beta oxidation from pmtcoa
    model = modelOri;
    %         for i = 1 : length(RPMI_composition)
    %         model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    %     end
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_hdca(e)'))=-1;model.ub(ismember(model.rxns,'EX_hdca(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    [model] = addSinkReactions(model,{'accoa(m)'},[0 100]);
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pmtcoa -> acetylCoA/ beta oxidation from pmtcoa';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% odecoa -> acetylCoA/ beta oxidation from oleic acid
    model = modelOri;
    %         for i = 1 : length(RPMI_composition)
    %         model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    %     end
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_ocdcea(e)'))=-1;model.ub(ismember(model.rxns,'EX_ocdcea(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    [model] = addSinkReactions(model,{'accoa(m)'},[0 100]);
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'odecoa -> acetylCoA/ beta oxidation from oleic acid (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% lnlccoa -> acetylCoA/ beta oxidation from linoleic acid
    model = modelOri;
    %         for i = 1 : length(RPMI_composition)
    %         model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    %     end
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_lnlc(e)'))=-1;model.ub(ismember(model.rxns,'EX_lnlc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    [model] = addSinkReactions(model,{'accoa(m)'},[0 100]);
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'lnlccoa -> acetylCoA/ beta oxidation from linoleic acid (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glycerol -> dhap/ glycerol utilizing machinery
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_glyc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glyc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'dhap(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_dhap(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glycerol -> dhap/ glycerol utilizing machinery';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% adenine -> amp/ salvage of adenine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_adn(e)'))=-1;model.ub(ismember(model.rxns,'EX_adn(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'amp(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_amp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'adenine -> amp/ salvage of adenine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hypoxanthine -> imp/ salvage of hypoxanthine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_hxan(e)'))=-1;model.ub(ismember(model.rxns,'EX_hxan(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'imp(c)'},[0 100]);
    model.c(ismember(model.rxns,'INSK'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hypoxanthine -> imp/ salvage of hypoxanthine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% guanine -> gmp/ salvage of guanine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_gua(e)'))=-1;model.ub(ismember(model.rxns,'EX_gua(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'prpp(c)','gmp(c)'},[-1 0;0 100]);
    model.c(ismember(model.rxns,'GUAPRT'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'guanine -> gmp/ salvage of guanine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ribose -> imp/ denovo purine synthesis
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_rib_D(e)'))=-1;model.ub(ismember(model.rxns,'EX_rib_D(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'imp(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_imp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ribose -> imp/ denovo purine synthesis';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% thymd -> thym/ thymidine phosphorylase
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_thymd(e)'))=-1;model.ub(ismember(model.rxns,'EX_thymd(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'thym(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_thym(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'thymd -> thym/ thymidine phosphorylase';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glutamine -> cmp/ pyrimidine synthesis
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_gln-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_gln-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'cmp(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_cmp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine -> cmp/ pyrimidine synthesis';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glutamine -> dtmp/ pyrimidine synthesis
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=0;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_gln-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_gln-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'dtmp(c)'},[0 100]);
    model.c(ismember(model.rxns,'sink_dtmp(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'glutamine -> dtmp/ pyrimidine synthesis';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% Kidney objectives: citr_L(c) -> arg_L(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'citr-L(c)','arg-L(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_citr(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_citr(c)')))=-1;
    model.c(ismember(model.rxns,'sink_arg-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_arg_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'citr_L(c) -> arg_L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cys_L(c) -> taur(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'cys-L(c)','taur(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_taur(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'cys_L(c) -> taur(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gly(c) -> orn(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gly(c)','orn(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_orn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gly(c) -> orn(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% citr_L(c) -> urea(c)/ partial urea cycle in kidney
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'citr-L(c)','urea(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_urea(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'citr_L(c) -> urea(c)/ partial urea cycle in kidney';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gthrd(c) -> glycine(c)/ glutathione breakdown via ?-glutamyl-transeptidase
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'gly(c)','gthrd(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_gly(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_gly(c)')))=-1;
    model.c(ismember(model.rxns,'sink_gthrd(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gthrd(c) -> glycine(c)/ glutathione breakdown via glutamyl-transeptidase';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pro_L(c) -> GABA(c)/ GABA synthesis in kidney
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pro-L(c)','4abut(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_4abut(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pro_L(c) -> GABA(c)/ GABA synthesis in kidney';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pro_L(c) -> orn(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pro-L(c)','orn(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_orn(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pro_L(c) -> orn(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% met_L(c) -> hcys_L(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'met-L(c)','hcys-L(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_met_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_met_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_hcys-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'met_L(c) -> hcys_L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hcys_L(c) -> met_L(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'hcys-L(c)','met-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_met-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_met_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hcys_L(c) -> met_L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% hcys_L(c) -> cys_L(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    [model] = addSinkReactions(model,{'hcys-L(c)','cys-L(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_ser_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_ser_L(c)')))=-1;
    model.c(ismember(model.rxns,'sink_cys-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_cys_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'hcys_L(c) -> cys_L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% 'lys-L(c) -> glu_L(c) / lysine degradation
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'lys-L(c)','glu-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glu-L(c)'))=1;
    model.c(ismember(model.rxns,'sink_glu_L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'lys-L(c) -> glu_L(c) / lysine degradation';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% trp-L(c) -> trypta(c) / tryptophan degradation
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'trp-L(c)','trypta(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_trypta(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'trp-L(c) -> trypta(c) / tryptophan degradation';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% kynate(c) -> nicotinamide(c) / nicotinamide from tryptophan metabolite
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'kynate(c)','nicrnt(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_nicrnt(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'kynate(c) -> nicotinamide(c) / nicotinamide from tryptophan metabolite';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pyr(c) -> lac-L(c)/ lactate dehydrogenase
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pyr(c)','lac-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_lac-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pyr(c) -> lac-L(c)/ lactate dehydrogenase';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% ATP max, aerobic, pyruvate/ pyruvate dehydrogenase-->TCA->energy
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_pyr(e)'))=-1;model.ub(ismember(model.rxns,'EX_pyr(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;

    if ~isempty(strmatch('DM_atp(c)',model.rxns,'exact'))
        model.c(ismember(model.rxns,'DM_atp(c)'))=1;
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'ATP max, aerobic, pyruvate/ pyruvate dehydrogenase-->TCA->energy';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% gal(c) -> udpg(c)/ galactose utilization
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'gal(c)','udpg(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_udpg(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'gal(c) -> udpg(c)/ galactose utilization';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% fru(c) -> lac_L(c)/ fructose conversion to glucose & utilization
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'fru(c)','lac-L(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_lac-L(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'fru(c) -> lac_L(c)/ fructose conversion to glucose & utilization';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% malcoa(c) -> eicostetcoa(c)/ fatty acid elongation
    model = modelOri;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'malcoa(c)','eicostetcoa(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_eicostetcoa(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'malcoa(c) -> eicostetcoa(c)/ fatty acid elongation (wtih RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% accoa(c) -> chsterol(r)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'accoa(c)','chsterol(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_chsterol(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'accoa(c) -> chsterol(r)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% inost(c) -> glac(r)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'inost(c)','glac(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_glac(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'inost(c) -> glac(r)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pail_hs(c) -> pail4p_hs(c)/ inositol kinase
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pail_hs(c)','pail4p_hs(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_pail4p_hs(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'pail_hs(c) -> pail4p_hs(c)/ inositol kinase';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arachd(c) -> prostgh2(c)/ prostaglandin synthesis
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'arachd(c)','prostgh2(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_prostgh2(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arachd(c) -> prostgh2(c)/ prostaglandin synthesis';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arachd(c) -> prostgd2(r)/ prostaglandin synthesis
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'arachd(c)','prostgd2(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_prostgd2(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arachd(c) -> prostgd2(r)/ prostaglandin synthesis';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arachd(c) -> prostge2(r)/ prostaglandin synthesis
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'arachd(c)','prostge2(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_prostge2(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arachd(c) -> prostge2(r)/ prostaglandin synthesis';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arachd(c) -> prostgi2(r)/ prostaglandin synthesis
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'arachd(c)','prostgi2(r)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_prostgi2(r)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'arachd(c) -> prostgi2(r)/ prostaglandin synthesis';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% 25hvitd3(m) -> 2425dhvitd3(m)/ 24,25-dihydroxycalciol synthesis
    model = modelOri;
    model.c(find(model.c)) = 0;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=0;
    % results in an infeasible model in Recon2
    %[model] = addSinkReactions(model,{'25hvitd3(m)','2425dhvitd3(m)'},[-1 -1; 0 100]);
    [model] = addSinkReactions(model,{'25hvitd3(m)','2425dhvitd3(m)'},[-1 -0.99; 0 100]);
    model.c(ismember(model.rxns,'sink_2425dhvitd3(m)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = '25hvitd3(m) -> 2425dhvitd3(m)/ 24,25-dihydroxycalciol synthesis (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% caro(c) -> retinal(c)/ vitamin A synthesis
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'caro(c)','retinal(c)'},[-1 -1; 0 100]);
    model.c(ismember(model.rxns,'sink_retinal(c)'))=1;
    if find(model.c)>0
        FBA = optimizeCbModel(model,'max','zero');
        TestSolution(k,1) = FBA.f;
    else
        TestSolution(k,1) = NaN;
    end
    TestSolutionName{k,1} = 'caro(c) -> retinal(c)/ vitamin A synthesis';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% missing part starts
    %% synthesis of glutamate from ornithine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_orn(e)'))=-1;model.ub(ismember(model.rxns,'EX_orn(e)'))=-1;
%     [model,rxnNames,rxnIDexists] = addDemandReaction(model,'glu-L(c)');
    [model] = addDemandReaction(model,'glu-L(c)');
%     if ~isempty(rxnIDexists)
%         model.c(rxnIDexists)=1;
%     else
        model.c(ismember(model.rxns,'DM_glu-L(c)'))=1;
%     end
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'synthesis of glutamate from ornithine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% synthesis of proline from ornithine
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_orn(e)'))=-1;model.ub(ismember(model.rxns,'EX_orn(e)'))=-1;
    [model] = addDemandReaction(model,'pro-L(m)');
    model.c(ismember(model.rxns,'DM_pro-L(m)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'synthesis of proline from ornithine';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% visual cycle in retina
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'retinol-cis-11(c)','retinal(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_retinal(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'visual cycle in retina';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pail_hs(c) -> pchol_hs(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pail_hs(c)','pchol-hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_pchol-hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'pail_hs(c) -> pchol_hs(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pail_hs(c) -> pe_hs(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pail_hs(c)','pe_hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_pe_hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'pail_hs(c) -> pe_hs(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pail_hs(c) -> ps_hs(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pail_hs(c)','ps-hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_ps-hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'pail_hs(c) -> ps_hs(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pail_hs(c) -> g3pc(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pail_hs(c)','g3pc(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_g3pc(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'pail_hs(c) -> g3pc(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dag_hs(c) -> pchol_hs(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'dag_hs(c)','pchol-hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_pchol-hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'dag_hs(c) -> pchol_hs(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dag_hs(c) -> pe_hs(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'dag_hs(c)','pe_hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_pe_hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'dag_hs(c) -> pe_hs(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dag_hs(c) -> clpn_hs(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'dag_hs(c)','clpn-hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_clpn-hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'dag_hs(c) -> clpn_hs(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% dag_hs(c) -> pgp_hs(c)
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'dag_hs(c)','pgp-hs(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_pgp-hs(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'dag_hs(c) -> pgp_hs(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% bhb(m) -> acac(m)/ ketone body utilization
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'bhb(m)','acac(m)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_acac(m)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'bhb(m) -> acac(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% mal_m(m) -> pyr(m)/ malic enzyme
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'mal-L(m)','pyr(m)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_pyr(m)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'mal_L(m) -> pyr(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% glu_L(c) -> gln_L(c)/ glutamine synthase
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'glu-L(c)','gln-L(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_gln-L(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'glu_L(c) -> gln_L(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% cys_L(c) -> coa(c)/ CoA synthesis from cysteine
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'cys-L(c)','coa(c)'},[-1 -1; 0 100]);
    model.lb(find(ismember(model.rxns,'sink_cys-L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_cys-L(c)')))=-1;
    model.lb(find(ismember(model.rxns,'sink_cys_L(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_cys_L(c)')))=-1;
    model.c(ismember(model.rxns,'DPCOAK'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'cys_L(c) -> coa(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% occoa(m) -> accoa(m)/ octanoate oxidation
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'occoa(m)','accoa(m)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'occoa(m) -> accoa(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% lnlncgcoa(c) -> dlnlcgcoa(c)/ fatty acid elongation
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'lnlncgcoa(c)','dlnlcgcoa(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_dlnlcgcoa(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'lnlncgcoa(c) -> dlnlcgcoa(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% chol(c) -> ach(c)/ acetyl-choline synthesis in brain
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'chol(c)','ach(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_ach(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'chol(c) -> ach(c)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% pyr(m) -> oaa(m)/ pyruvate carboxylase
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'pyr(m)','oaa(m)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_oaa(m)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'pyr(m) -> oaa(m)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% GABA aminotransferase
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glu-L(e)'))=-1;model.ub(ismember(model.rxns,'EX_glu-L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'ABTArm'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'GABA aminotransferase';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% methionine adenosyltransferase
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_met_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_met_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    model.c(ismember(model.rxns,'METAT'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'methionine adenosyltransferase';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% creatine synthesis
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_arg_L(e)'))=-1;model.ub(ismember(model.rxns,'EX_arg_L(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_gly(e)'))=-1;model.ub(ismember(model.rxns,'EX_gly(e)'))=-1;
    [model] = addSinkReactions(model,{'crtn(c)'},[0 1000]);
    model.c(ismember(model.rxns,'sink_crtn(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'creatine synthesis';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arachd(c) -> leuktrE4(c)/ leukotriene synthesis
    % requires multiple medium compounds --> RPMI

    model = modelOri;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'arachd(c)','leuktrE4(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_leuktrE4(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'arachd(c) -> leuktrE4(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% arachd(c) -> C06314(c)/ lipoxin synthesis
    model = modelOri;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'arachd(c)','C06314(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_C06314(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'arachd(c) -> C06314(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% nrpphr(c) -> 3mox4hoxm(c)/ degradation of norepinephrine
    model = modelOri;
    for i = 1 : length(RPMI_composition)
        model = changeRxnBounds(model,RPMI_composition{i},-1,'l');
    end
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'nrpphr(c)','3mox4hoxm(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_3mox4hoxm(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'nrpphr(c) -> 3mox4hoxm(c) (with RPMI medium)';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
    %% sbt_D(c) -> fru(c)/sorbitol pathway
    model = modelOri;
    model.c(find(model.c)) = 0;
    [model] = addSinkReactions(model,{'sbt-D(c)','fru(c)'},[-1 -1; 0 1000]);
    model.c(ismember(model.rxns,'sink_fru(c)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'sbt_D(c) -> fru(c)/sorbitol pathway';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    %% new addition 26.04.2017
    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'accoa(m)'},0,  1000);
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    model.c(ismember(model.rxns,'sink_accoa(m)'))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Mitochondrial accoa de novo synthesis from glc';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA

    model = modelOri;
    model.c(find(model.c)) = 0;
    model.lb(ismember(model.rxns,'EX_glc(e)'))=-1;model.ub(ismember(model.rxns,'EX_glc(e)'))=-1;
    model.lb(ismember(model.rxns,'EX_o2(e)'))=-40;model.ub(ismember(model.rxns,'EX_o2(e)'))=-1;
    [model] = addSinkReactions(model,{'succoa(m)'},0,1000);
    model.c(ismember(model.rxns,'sink_succoa(m)'))=1;
    model.lb(find(ismember(model.rxns,'sink_coa(c)')))=-1;
    model.ub(find(ismember(model.rxns,'sink_coa(c)')))=1;
    FBA = optimizeCbModel(model,'max','zero');
    TestSolution(k,1) = FBA.f;
    TestSolutionName{k,1} = 'Mitochondrial succoa de novo synthesis from glc';
    if ~isnan(TestSolution(k,1)); TestedRxns = [TestedRxns; model.rxns(find(abs(FBA.x)>tol))]; end ;k = k +1;clear FBA
end

TestSolutionName(:,2) = num2cell(TestSolution);
TestedRxns = unique(TestedRxns);
TestedRxns = intersect(modelOri.rxns,TestedRxns); % only those reactions that are also in modelOri not those that have been added to the network
PercTestedRxns = length(TestedRxns)*100/length(modelOri.rxns);
