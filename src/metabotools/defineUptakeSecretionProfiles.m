function [cond1_uptake, cond2_uptake, cond1_secretion, cond2_secretion, slope_Ratio] = defineUptakeSecretionProfiles(input_A,input_B, data_RXNS, tol,essAA_excl,exclude_upt,exclude_secr,add_secr, add_upt)
% This function calculated the slope ratios and gives out uptake&secretion profiles for condition 1 and condition 2
%
% USAGE:
%
%    [cond1_uptake, cond2_uptake, cond1_secretion, cond2_secretion, slope_Ratio] = defineUptakeSecretionProfiles(input_A, input_B, data_RXNS, tol, essAA_excl, exclude_upt, exclude_secr, add_secr, add_upt)
%
% INPUTS:
%    input_A:             Matrix, 4 columns 
%
%                           1. Control TP1, 
%                           2. Control TP2, 
%                           3. Condition 1 TP1, 
%                           4. Condition 1 TP 2
%    input_B:             Matrix, 4 columns
%
%                           1. Control2 TP1, 
%                           2. Control2 TP2, 
%                           3. Condition 2 TP1, 
%                           4. Condition 2 TP 2
%    data_RXNS:           Exchange reactions same order as `input_A` and `input_B`
%    tol:                 minimal threshold to call uptake or secretion (Default 0.05)=5%
%
% OPTIONAL INPUTS:
%    essAA_excl:          If essential amino acids should be excluded from the secretion profile 1(yes), or 0(no) (Default = 0); 
%                         `essAAs` = {`EX_his_L(e)`; `EX_ile_L(e)`; `EX_leu_L(e)`; `EX_lys_L(e)`; `EX_met_L(e)`; `EX_phe_L(e)`; `EX_thr_L(e)`; `EX_trp_L(e)`; `EX_val_L(e)`}
%    exclude_upt:         Exclude uncertain metabolites from uptake (e.g., metabolites from GlutaMax, e.g., `EX_gln_L(e)`, `EX_cys_L(e)`, `EX_ala_L(e)`)
%    exclude_secr:        Exclude uncertain metabolites from secretion (e.g., metabolites from GlutaMax, e.g., `EX_gln_L(e)`, `EX_cys_L(e)`, `EX_ala_L(e)`)
%    add_secr:            Due to mising data points automatic analysis might do wrong assignment of metabolites to secretion 
%    add_upt:             Due to mising data points automatic analysis might do wrong assignment of metabolites to uptake 
%
% OUTPUTS:
%    cond1_uptake:        List of exchanges that specify consumed metabolites in condition 1        
%    cond2_uptake:        List of exchanges that specify consumed metabolites in condition 2
%    cond1_secretion:     List of exchanges that specify released metabolites in condition 1
%    cond2_secretion:     List of exchanges that specify released metabolites in condition 2
%    slope_Ratio:         For length of inputA/B, relative difference
%
% .. Author: - Maike K. Aurich 27/05/15

if ~exist('tol','var') || isempty(tol)
    tol = 0.05;
end

if ~exist('essAA_excl','var') || isempty(essAA_excl)
    essAA_excl = 0;
end




%% calculate slope for control (TP2/TP1) and condition (TP2/TP1) of both conditions (cell types, or cell lines), and slope ration between conditions


for i=1:length(input_A)
    
    control1(i,1) = input_A(i,2)/input_A(i,1);
    cond1(i,1) = input_A(i,4)/input_A(i,3);
    slope_cond1(i,1) = cond1(i,1)/ control1(i,1);
    
    control2(i,1) = input_B(i,2)/input_B(i,1);
    cond2(i,1) = input_B(i,4)/input_B(i,3);
    slope_cond2(i,1) = cond2(i,1)/ control2(i,1);
    
    slope_Ratio(i,1) = slope_cond2(i,1)/slope_cond1(i,1);
    
    
end


%% Make uptake and secretion profiles 
%%define uptake and secretion for each condition based on the slope

cond1_uptake = {};
cond2_uptake = {};
cond1_secretion = {};
cond2_secretion = {};

cond1_uptake = data_RXNS(find(slope_cond1<1-tol));
cond2_uptake = data_RXNS(find(slope_cond2<1-tol));

cond1_secretion = data_RXNS(find(slope_cond1>1+tol));
cond2_secretion = data_RXNS(find(slope_cond2>1+tol));
 
%% exclude secretion of essAAs and modify as specified

if exist('essAA_excl','var')
    
    cond1_secretion(find(ismember(cond1_secretion, essAA_excl)))='';
    cond2_secretion(find(ismember(cond2_secretion, essAA_excl)))='';
    
end


if exist('exclude_secr','var')
    cond1_secretion(find(ismember(cond1_secretion, exclude_secr)))='';
    cond2_secretion(find(ismember(cond2_secretion, exclude_secr)))='';
end 

if exist('exclude_upt','var')
    cond1_uptake(find(ismember(cond1_uptake, exclude_upt)))='';
    cond2_uptake(find(ismember(cond2_uptake, exclude_upt)))='';
    
end

if exist('add_secr','var')
    cond1_secretion = [cond1_secretion;add_secr];
    cond2_secretion = [cond2_secretion;add_secr];
    
end

if exist('add_upt','var')
    cond1_uptake = [cond1_uptake;add_upt];
    cond2_uptake = [cond2_uptake;add_upt];
    
end

%% make sure vectors are unique
cond1_secretion = unique(cond1_secretion);
cond2_secretion = unique(cond2_secretion);
cond1_uptake = unique(cond1_uptake);
cond2_uptake = unique(cond2_uptake);

 end

