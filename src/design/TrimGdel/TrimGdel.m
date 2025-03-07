function [gvalue, GR, PR, size1, size2, size3, success] = TrimGdel(model, targetMet, maxLoop, PRLB, GRLB)
% TrimGdel appropriately considers GPR rules and determines 
% a minimal gene deletion strategies to achieve growth-coupled production 
% for a given target metabolite and a genome-scale model.
% even in the worst-case analysis (ensures the weak-growth-coupled production).
%
% Gurobi is required for this version. 
% The CPLEX version is available on https://github.com/MetNetComp/TrimGdel
%
% USAGE:
%
%    function [gvalue, GR, PR, size1, size2, size3, success] 
%                      = TrimGdel(model, targetMet, maxLoop, PRLB, GRLB)
%
% INPUTS:
%    model:    COBRA model structure containing the following required fields to perform gDel_minRN.
%
%        *.rxns:       Rxns in the model
%        *.mets:       Metabolites in the model
%        *.genes:      Genes in the model
%        *.grRules:    Gene-protein-reaction relations in the model
%        *.S:          Stoichiometric matrix (sparse)
%        *.b:          RHS of Sv = b (usually zeros)
%        *.c:          Objective coefficients
%        *.lb:         Lower bounds for fluxes
%        *.ub:         Upper bounds for fluxes
%        *.rev:        Reversibility of fluxes
%
%    targetMet:    target metabolites    (e.g.,  'btn_c')
%    maxLoop:      the maximum number of iterations in gDel_minRN
%    PRLB:         the minimum required production rates of the target metabolites
%                  when gDel-minRN searches the gene deletion
%                  strategy candidates. 
%                  (But it is not ensured to achieve this minimum required value
%                  when GR is maximized withoug PRLB.)
%    GRLB:         the minimum required growth rate 
%                  when gDel-minRN searches the gene deletion
%                  strategy candidates. 
%
% OUTPUTS:
%    gvalue:     a small gene deletion strategy (obtained by TrimGdel).
%                The first column is the list of genes.
%                The second column is a 0/1 vector indicating which genes should be deleted.
%                    0: indicates genes to be deleted.
%                    1: indecates genes to be remained.
%    GR:         the maximum growth rate when the obtained gene deletion
%                strategy represented by gvalue is applied.
%    PR:         the minimum production rate of the target metabolite under 
%                the maximization of the growth rate when the obtained gene deletion
%                strategy represented by gvalue is applied.
%    size1:      the number of gene deletions after Step1.
%    size2:      the number of gene deletions after Step2.
%    size3:      the number of gene deletions after Step3.
%    success:    indicates whether TrimGdel obained an appropriate gene
%                deletion strategy. (1:success, 0:failure)
%
% NOTE:
%
%    T. Tamura, "Trimming Gene Deletion Strategies for Growth-Coupled 
%    Production in Constraint-Based Metabolic Networks: TrimGdel," 
%    in IEEE/ACM Transactions on Computational Biology and Bioinformatics,
%    vol. 20, no. 2, pp. 1540-1549, 2023.
%
%    Comprehensive computational results are accumulated in MetNetComp
%    database.
%    https://metnetcomp.github.io/database1/indexFiles/index.html
%
%    T. Tamura, "MetNetComp: Database for Minimal and Maximal Gene-Deletion Strategies 
%    for Growth-Coupled Production of Genome-Scale Metabolic Networks," 
%    in IEEE/ACM Transactions on Computational Biology and Bioinformatics, 
%    vol. 20, no. 6, pp. 3748-3758, 2023, 
% 
% .. Author:    - Takeyuki Tamura, Mar 06, 2025
%

[gvalue gr pr it success] = gDel_minRN(model, targetMet, maxLoop, PRLB, GRLB) % Step 1
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

end

