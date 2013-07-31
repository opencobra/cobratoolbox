% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function formula = rGenerateFormula(meta_meta,reversible,abbreviation)
% Generate reaction formula and do a balance check.
% Only for use by the ReconstructionTool.
% rxn = rGenerateFormula(meta_meta)
%
% INPUT 
%   meta_meta - a special ReconstructionTool object
%   reversible - 0 or 1
%   abbreviation - Reaction abbreviation
%
% OUTPUT 
%   reaction formula    - on success
%   []                  - if canceled
output = BalancePrep(meta_meta);

leftside    = output{1};
rightside   = output{2};
charge_l    = output{3};
charge_r    = output{4};
balance     = balancecheck(meta_meta); %Verify that reaction is balanced.
if ~isempty(balance) || ~(charge_l == charge_r) %reaction is unbalanced
    charge = cell(3,1);
    charge(1:3,1) = {'Charge', charge_l, charge_r};
    balance_charge = [charge, balance];% All data is here
    
    unbalanced(abbreviation,{balance_charge}); % Initiate unbalanced window
end

% Reversible sign
if reversible == 0
    rev_str = ' -> ';
else
    rev_str = ' <=> ';
end

formula = [leftside rev_str rightside];





