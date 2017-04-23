function [modelA_QUANT,modelB_QUANT] = setSemiQuantConstraints(modelA, modelB, cond1_upt_higher, cond2_upt_higher, cond2_secr_higher,cond1_secr_higher)
% This function establishes constraints for two models (`modelA` and `modelB`) based on the relative
% difference of signal intensities obtained from two samples. The prerequisite for the adjustment is that constraints have been applied on which the relative differences can be applied:
% 
% * (A) The uptake rates have been established based on the medium composition and concentrations (i.e., `setMediumConstraints`), and 
% * (B) qualitative constraints have been applied based on know detection limits or small values (i.e., `setQualitativeConstraints`). 
%
% USAGE:
%
%    [modelA_QUANT, modelB_QUANT] = setSemiQuantConstraints(modelA, modelB, cond1_upt_higher, cond2_upt_higher, cond2_secr_higher, cond1_secr_higher)
%
% INPUTS:
%    modelA:                      model constrained according to condition 1
%    modelB:                      model constrained according to condition 2
%    cond1_upt_higher:            Exchange reactions and relative differences with higher uptake in condition 1 compared to condition 2
%    cond2_upt_higher:            Exchange reactions and relative differences with higher uptake in condition 2 compared to condition 1
%    cond2_secr_higher:           Exchange reactions and relative differences with higher secretion in condition 2 compared to condition 1
%    cond1_secr_higher:           Exchange reactions and relative differences with higher secretion in condition 1 compared to condition 2
%
%
% OUTPUTS:
%    modelA_QUANT:                model constrained according to condition 1
%    modelB_QUANT:                model constrained according to condition 2
%
% .. Author: - Maike K. Aurich 13/02/15

modelA2 = modelA;
modelB2 = modelB;
    
for a=1:length(cond2_upt_higher(:,1))
    M = find(ismember(modelA.rxns, cond2_upt_higher{a,1}));
    C = find(ismember(modelB.rxns, cond2_upt_higher{a,1}));
   
         modelB2.lb(C)= (modelB.lb(C)*(1-(cond2_upt_higher{a,2}))); %lower in CEM
        uptake_lower_stat(a,5) = modelB.lb(C);
            uptake_lower_stat(a,6) = modelB.ub(C);
            uptake_lower_stat(a,7)= (modelB.lb(C)*(1-(cond2_upt_higher{a,2})));
            uptake_lower_Rxns(a,2) = modelB.rxns(C);    
            if ((cond2_upt_higher{a,2}))>1
                modelB2.lb(C)= (modelB.lb(C)/((cond2_upt_higher{a,2})));
                uptake_lower_stat(a,5) = modelB.lb(C);
                uptake_lower_stat(a,6) = modelB.ub(C);
                uptake_lower_stat(a,8)= (modelB.lb(C)/cond2_upt_higher{a,2});
                uptake_lower_Rxns(a,2) = modelB.rxns(C);
            end
                      
end 

a=a+1;
for b=1:length(cond1_upt_higher(:,1))
           M = find(ismember(modelA.rxns, cond1_upt_higher{b,1}));
    C = find(ismember(modelB.rxns, cond1_upt_higher{b,1}));
           modelA2.lb(M)= (1-(cond1_upt_higher{b,2}/100))*(modelB.lb(C)); %higher in CEM
           c=b+a;
          uptake_lower_stat(c,5) =modelA.lb(M);
            uptake_lower_stat(c,6) =  modelA.ub(M);
            uptake_lower_stat(c,7)= (1-(cond1_upt_higher{b,2}/100))*(modelB.lb(C));
            uptake_lower_Rxns(c,2) = modelA.rxns(M);    
              
                   
end    

clear b a

for  b=1:length(cond2_secr_higher(:,1))
      M = find(ismember(modelA.rxns, cond2_secr_higher{b,1}));
    C = find(ismember(modelB.rxns, cond2_secr_higher{b,1}));
      c=c+1;
    
    modelA2.lb(M)= (1+(cond2_secr_higher{b,2}/100))*(modelB.lb(C));%lower in CEM
  
          uptake_lower_stat(c,5) = modelA.lb(M);
            uptake_lower_stat(c,6) =  modelA.ub(M);
            uptake_lower_stat(c,7)= (1+(cond2_secr_higher{b,2}/100))*(modelB.lb(C));
            uptake_lower_Rxns(c,2) =  modelA.rxns(M);    
            
    
  
end


for  b=1:length(cond1_secr_higher(:,1))
     c=c+1;
    M = find(ismember(modelA.rxns, cond1_secr_higher{b,1}));
    C = find(ismember(modelB.rxns, cond1_secr_higher{b,1}));
    modelB2.lb(C)= (1+(cond1_secr_higher{b,2}/100))*(modelB.lb(C));%higher in CEM
     uptake_lower_stat(c,5) = modelB.lb(C);
            uptake_lower_stat(c,6) =  modelB.ub(C);
            uptake_lower_stat(c,7) = (1+(cond1_secr_higher{b,2}/100))*(modelB.lb(C));
            uptake_lower_Rxns(c,2) =  modelB.rxns(C);    
            
        if ((cond1_secr_higher{b,2})/100)>1
                modelB2.lb(C)= ((modelB.lb(C)*(cond1_secr_higher{b,2}/100)));
                uptake_lower_stat(b,5) = modelB.lb(C);
                uptake_lower_stat(b,6) = modelB.ub(C);
                uptake_lower_stat(b,8)= (1+(cond1_secr_higher{b,2}/100))*(modelB.lb(C));
                uptake_lower_Rxns(b,2) = modelB.rxns(C);
            end
                           
    
    
end



% [minFlux_modelA2,maxFlux_modelA2] = fastFVA(modelA2,0);
% [minFlux_modelB2,maxFlux_modelB2] = fastFVA(modelB2,0);



modelA_QUANT = modelA2;
modelB_QUANT = modelB2;


% results_FVA.minFlux_modelA2 = minFlux_modelA2;
% results_FVA.maxFlux_modelA2 = maxFlux_modelA2;
% results_FVA.minFlux_modelB2 = minFlux_modelB2;
% results_FVA.maxFlux_modelB2 = maxFlux_modelB2;


end

