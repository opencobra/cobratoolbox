% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011

%input is meta_meta from ReconstructionTool (same type of file)
%Output is leftside, rightside, charge_l and charge_r in varargout
%Stefan G. Thorleifsson 2010

function output = BalancePrep(meta_meta)
output = [];
if isempty(meta_meta)
    return
end

S = size(meta_meta);

for i = 1:S(1); 
    if ismember('',meta_meta(i,6))
        msgbox(['Reaction cannot be created with metabolites that are'... 
            'missing the charged formula. ' meta_meta(i,1)  ],...
            'Missing charge formula','warn');
        return
    end
end
%---------- Creating formula ---------------- begin


%initialize variables
leftside = []; rightside = [];
charge_left = []; charge_right = [];

for i = 1:S(1)
    
    %creating metabolite [compartment] ready
    comp_str = meta_meta{i,4};
    comp_cnt = regexpi(comp_str,'\(');
    comp = comp_str(comp_cnt+1);
    
    if meta_meta{i,3} == 1 % No numbers
        newmetab = [meta_meta{i,1} '[' comp ']'];
    else
        newmetab = [num2str(meta_meta{i,3}) ' ' meta_meta{i,1} '[' comp ']'];
    end
    
    % Dividing left from right.
    if strmatch(meta_meta(i,5),'Substrate','exact')
        charge_left = [charge_left str2double(meta_meta{i,7})*meta_meta{i,3}]; %adding up the charge
        
        if isempty(leftside)
            leftside = newmetab;
        else
            leftside = [leftside ' + ' newmetab];
        end
    elseif strmatch(meta_meta(i,5),'Product','exact')
        charge_right = [charge_right str2double(meta_meta{i,7})*meta_meta{i,3}];%adding up the charge
        if isempty(rightside)
            rightside = newmetab;
        else
            rightside = [rightside ' + ' newmetab];
        end
    else
        msgbox('Something is wrong with Substrate and Product.',...
            'Reaction balance.','error');
        return
    end
end

charge_l = sum(charge_left);
charge_r = sum(charge_right);

output = {leftside,rightside,charge_l,charge_r};

