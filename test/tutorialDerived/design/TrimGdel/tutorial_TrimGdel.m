%% TrimGdel
%% Author(s): Takeyuki Tamura, Kyoto University
%% Reviewer(s): Ronan M.T. Fleming
%% INTRODUCTION 
% TrimGdel determines a minimal gene deletion strategy to achieve growth-coupled 
% production for a given target metabolite and a genome-scale model even in the 
% worst-case analysis (ensures the weak-growth-coupled production). It should 
% be noted that TrimGdel directly implements the Boolean functions of GPR rules, 
% whereas gMCS-based methods convert GPR rules into a stoichiometric representation, 
% which may introduce approximations in the Boolean functions. Consequently, the 
% gene deletion strategies derived from TrimGdel often differ from those obtained 
% using gMCS-based methods. On the other hand, the gMCS-based methods can ensure 
% growth-coupled production even when the growth rate is not maximized. (ensures 
% the strong-growth-coupled production)
%% MATERIALS - EQUIPMENT SETUP
% MATLAB and Gurobi are required for this version. 
%% PROCEDURE
%% 1. Toy example (~5 sec)
% In this tutorial, we apply TrimGdel to a toy example represented in Fig. 2 
% of [1].
% 
% First we load the small toy exapmle of Fig. 2 of [1]. The target metabolite 
% is set as m6.

load('TrimGdelToyExample.mat');
targetMet = 'm6'
%% 2. Step 1
% As Step 1 of TrimGdel, gDel_minRN is applied. gDel_minRN identifies the gene 
% deletion strategy that leads to growth-coupled production while maximizing the 
% number of reppressed reactions.
% 
% gdel_minRN iteratively finds and verifies candidate solutions. If a candidate 
% does not lead to growth-coupled production, it is added to the exclusion set, 
% and the next candidate is explored. maxloop sets the upper limit on the number 
% of iterations, which is set to 1 here.
% 
% When searching for candidate solutions, lower bounds are set for the growth 
% rate and production rate, represented by GRLB and PRLB, respectively. Here, 
% both are set to 1.
% 
% Step 1 (gDel_minRN) outputs gvalue, which represents the gene deletion strategy; 
% gr, the maximum growth rate achieved; pr, the minimum production rate when the 
% growth rate is maximized; it, the number of iterations required to find a solution; 
% and success, indicating whether the process was successful or not.
% 
% The obtained strategy represented by gvalue deletes three genes, g1, g3, g4. 
% gr = 5, pr = 5, it = 1, and success = 1 are obtained.

maxLoop = 1;
PRLB = 1;
GRLB = 1;

[gvalue gr pr it success] = gDel_minRN(model, targetMet, maxLoop, PRLB, GRLB) % Step 1
%% 3. Steps 2 and 3
% Steps 2 and 3 reduces the size of gene deletions, starting with the gene deletion 
% strategy obtained by Step 1. When Step 1 fails, Steps 2 and 3 are omitted and 
% TrimGdel outputs failure.
% 
% The obtained strategy represented by gvalue deletes only one genes, g4. GR 
% = 10, PR = 10, size1 = 3, size2 = 3, and size3 = 1 are obtained.

if success
    [gvalue, GR, PR, size1, size2, size3] = step2and3(model, targetMet, gvalue) % Step 2 and 3


else
    gvalue = [];
    GR = 0;
    PR = 0;
    size1 = 0;
    size2 = 0;
    size3 = 0;
end
%% ANTICIPATED RESULTS
% GR = 10, PR = 10, size1 = 3, size2 = 3, size3 = 1 gvalue indicates the deletion 
% of only g4 (b0004).
%% _Acknowledgments_
% The author sincerely appreciate the administrators and reviewers.
%% REFERENCES
% _1. Tamura, T. Trimming gene deletion strategies for growth-coupled production 
% in constraint-based metabolic networks: TrimGdel. IEEE/ACM Transactions on Computational 
% Biology and Bioinformatics. 20, 2, 1540-1549 (2023)._