function x = testMOMA()
%testMOMA tests the functions of MOMA and linearMOMA based on the paper
%   "Analysis of optimality in natural and perturbed metabolic networks"
%   (http://www.pnas.org/content/99/23/15112.full)
%   MOMA employs quadratic programming to identify a point in flux space,
%   which is closest to the wild-type point, compatibly with the gene
%   deletion constraint. 
%   In other words, through MOMA, we test the hypothesis that the real
%   knockout steady state is better approximated by the flux minimal 
%   response to the perturbation than by the optimal one
x=1;
tol = 0.0001;

% save director
ori = pwd;

%change to testMOMA director
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

display('MOMA requires a QP solver to be installed.  QPNG does not work.');
load('ecoli_core_model.mat')
[modelOut,hasEffect,constrRxnNames,deletedGenes] = deleteModelGenes(model,'b3956'); %gene for reaction PPC
sol = MOMA(model, modelOut);

if  abs(0.8463 - sol.f) < tol
    disp('MOMA returned the correct solution')
else
    disp('MOMA returned the incorrect solution')
    x= 0;
end

sol = linearMOMA(model, modelOut);

if abs(0.8608 - sol.f) < tol
    disp('linearMOMA returned the correct solution')
else
    disp('linearMOMA returned the incorrect solution')
    x= 0;
end

%return to original director
cd(ori);
end

