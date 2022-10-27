%%This is an Example to show how to use Fast-SL
load Ecoli_core_model
%cutoff- 1% of Wildtype growth rate
%Lethals upto Order 2
%Output is stored in 'ecoli_core_model_Gene_Lethals.mat'
%initCobraToolbox
fastSLgenes(model,0.01,3,0); 
