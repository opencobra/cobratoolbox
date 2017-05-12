function [cond1_upt_higher, cond2_upt_higher, cond2_secr_higher,cond1_secr_higher, cond1_uptake_LODs,cond2_uptake_LODs,cond1_secretion_LODs, cond2_secretion_LODs] = calculateQuantitativeDiffs(data_RXNS,slope_Ratio,ex_RXNS, lod_mM, cond1_uptake, cond2_uptake, cond1_secretion, cond2_secretion)
% This function provides sets of exchange reactions with higher uptake and
% secretion in condition 1 and condition 2.
%
% USAGE:
%
%    [cond1_upt_higher, cond2_upt_higher, cond2_secr_higher, cond1_secr_higher, cond1_uptake_LODs, cond2_uptake_LODs, cond1_secretion_LODs, cond2_secretion_LODs] = calculateQuantitativeDiffs(data_RXNS, slope_Ratio, ex_RXNS, lod_mM, cond1_uptake, cond2_uptake, cond1_secretion, cond2_secretion);
%
% INPUTS:
%    data_RXNS:              Exchange reactions same order as Input_A and Input_B
%    slope_Ratio:            For length of inputA/B, relative difference
%    ex_RXNS:                Exchange reactions in the same order as LODs(lod_mM)
%    lod_mM:                 Detection limits in mM
%    cond1_uptake:           List of exchanges that specify consumed metabolites in condition 1        
%    cond2_uptake:           List of exchanges that specify consumed metabolites in condition 2
%    cond1_secretion:        List of exchanges that specify released metabolites in condition 1
%    cond2_secretion:        List of exchanges that specify released metabolites in condition 2
%
% OUTPUTS:
%    cond1_upt_higher:       Exchange reactions and relative differences with higher uptake in condition 1 compared to condition 2
%    cond2_upt_higher:       Exchange reactions and relative differences with higher uptake in condition 2 compared to condition 1
%    cond2_secr_higher:      Exchange reactions and relative differences with higher secretion in condition 2 compared to condition 1
%    cond1_secr_higher:      Exchange reactions and relative differences with higher secretion in condition 1 compared to condition 2
%    cond1_uptake_LODs:      Detection limits for metabolites with higher uptake in condition 1
%    cond2_uptake_LODs:      Detection limits for metabolites with higher uptake in condition 2
%    cond1_secretion_LODs:   Detection limits for metabolites with higher secretion in condition 1
%    cond2_secretion_LODs:   Detection limits for metabolites with higher secretion in condition 2
%  
% .. Authors:
%       - Ines Thiele
%       - Maike K. Aurich 27/05/15

cond1_uptake_LODs = [];
cond2_uptake_LODs = [];

cond1_secretion_LODs = [];
cond2_secretion_LODs = [];
% get LODs
for i=1:length(cond1_uptake)
   cond1_uptake_LODs(i,1) = lod_mM(find(ismember(ex_RXNS, cond1_uptake(i))));
end
 
for i=1:length(cond2_uptake)
   cond2_uptake_LODs(i,1) = lod_mM(find(ismember(ex_RXNS, cond2_uptake(i))));
end

for i=1:length(cond1_secretion)
   cond1_secretion_LODs(i,1) = lod_mM(find(ismember(ex_RXNS, cond1_secretion(i))));
end

for i=1:length(cond2_secretion)
   cond2_secretion_LODs(i,1) = lod_mM(find(ismember(ex_RXNS, cond2_secretion(i))));
end


% %% Get Semi-quantitative differences  
% 
% % find overlap in uptake and secretion
common_upt = intersect(cond1_uptake,cond2_uptake);
common_secr = intersect(cond1_secretion,cond2_secretion);
 
% 
for i=1:length(common_secr)
 common_slope_secr(i,1) = slope_Ratio(find(ismember(data_RXNS, common_secr(i))));
end
% 
% 
for i=1:length(common_upt)
 common_slope_upt(i,1) = slope_Ratio(find(ismember(data_RXNS, common_upt(i))));
end
%  

%% 


 %% Split in higher and lower uptake and secretion per condition.

m=1;
n=1;

for i=1:length(common_slope_upt)
    %find higher uptake in cond1 (uptake is higher in cond1 when slopeRatio < 1)
    if common_slope_upt(i,1)<1
        cond1_upt_higher{n,1}=common_upt(i); %put in excange name
        cond1_upt_higher{n,2}=100-(common_slope_upt(i)*100); % put in change value
        n=n+1;
        
        %find lower uptake in cond2 (uptake is higher in cond2 when slopeRatio > 1)
    elseif common_slope_upt(i,1)>=1
         cond2_upt_higher{m,1}=common_upt(i); %put in excange name
        cond2_upt_higher{m,2}=(common_slope_upt(i)-1); % put in change value, subtract one 
        m=m+1;
    end
        
end 

%%
m=1;
n=1;

for i=1:length(common_slope_secr)
    %find higher secretion in cond1 (secretion is higher in cond1 when slopeRatio < 1)
    if common_slope_secr(i,1)<1
        cond2_secr_higher{n,1}=common_secr(i); %put in excange name
        cond2_secr_higher{n,2}=(1-common_slope_secr(i))*100; % put in change value
        n=n+1;
        
        %find higher secretion in cond2 (secretion is higher in cond2 when slopeRatio > 1)
    elseif common_slope_secr(i,1)>=1
         cond1_secr_higher{m,1}=common_secr(i); %put in excange name
        cond1_secr_higher{m,2}=common_slope_secr(i)*100; % put in change value
        m=m+1;
    end
        
end 
        

 end

 



 
 
 
 

 
