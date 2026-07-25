function [gvalue, GR, PR, size1, size2, size3, success] = TrimGdel(model, targetMet, maxLoop, PRLB, GRLB)
% TrimGdel computes a minimal gene-deletion strategy that achieves
% growth-coupled production of a target metabolite for a genome-scale
% model, appropriately accounting for gene-protein-reaction (GPR) rules.
% The strategy is guaranteed even in the worst case (weak growth-coupled
% production). Gurobi is required for this version; a CPLEX version is
% available at https://github.com/MetNetComp/TrimGdel.
%
% USAGE:
%
%    [gvalue, GR, PR, size1, size2, size3, success] = TrimGdel(model, targetMet, maxLoop, PRLB, GRLB)
%
% INPUTS:
%    model:        COBRA model structure. TrimGdel passes the whole model to
%                  its subroutines gDel_minRN (Step 1) and step2and3 (Steps 2
%                  and 3), which require the reaction, metabolite, gene,
%                  GPR-rule, stoichiometry, objective and flux-bound fields.
%    targetMet:    target metabolite identifier (e.g. 'btn_c')
%    maxLoop:      maximum number of iterations performed in gDel_minRN
%    PRLB:         minimum required production rate of the target metabolite
%                  used while gDel_minRN searches for gene-deletion strategy
%                  candidates (not guaranteed once GR is maximized without PRLB)
%    GRLB:         minimum required growth rate used while gDel_minRN searches
%                  for gene-deletion strategy candidates
%
% OUTPUTS:
%    gvalue:       the resulting small gene-deletion strategy. Column 1 lists
%                  the genes; column 2 is a 0/1 vector (0 = gene deleted,
%                  1 = gene retained)
%    GR:           the maximum growth rate when the strategy in gvalue is applied
%    PR:           the minimum production rate of the target metabolite under
%                  growth-rate maximization when the strategy in gvalue is applied
%    size1:        the number of gene deletions after Step 1
%    size2:        the number of gene deletions after Step 2
%    size3:        the number of gene deletions after Step 3
%    success:      whether an appropriate gene-deletion strategy was obtained
%                  (1 = success, 0 = failure)
%
% NOTE:
%
%    T. Tamura, "Trimming Gene Deletion Strategies for Growth-Coupled
%    Production in Constraint-Based Metabolic Networks: TrimGdel,"
%    in IEEE/ACM Transactions on Computational Biology and Bioinformatics,
%    vol. 20, no. 2, pp. 1540-1549, 2023.
%
%    Comprehensive computational results are accumulated in the MetNetComp
%    database: https://metnetcomp.github.io/database1/indexFiles/index.html
%
%    T. Tamura, "MetNetComp: Database for Minimal and Maximal Gene-Deletion
%    Strategies for Growth-Coupled Production of Genome-Scale Metabolic
%    Networks," in IEEE/ACM Transactions on Computational Biology and
%    Bioinformatics, vol. 20, no. 6, pp. 3748-3758, 2023.
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

