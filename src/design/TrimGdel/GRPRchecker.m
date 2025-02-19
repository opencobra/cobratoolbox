function [GR ,PR] = GRPRchecker(model, targetMet, givenGvalue)
% GRPRchecker calculates the maximum GR and the minimu PR 
% under the GR maximization when a constraint-based model, a target
% metabolite, and a gene deletion stratety are given.
%
% function [GR, PR]  
%      = GRPRchecker(model, targetMet, givenGvalue)
%
% INPUTS
%  model     COBRA model structure containing the following required fields to perform gDel_minRN.
%    rxns                    Rxns in the model
%    mets                    Metabolites in the model
%    genes               Genes in the model
%    grRules            Gene-protein-reaction relations in the model
%    S                       Stoichiometric matrix (sparse)
%    b                       RHS of Sv = b (usually zeros)
%    c                       Objective coefficients
%    lb                      Lower bounds for fluxes
%    ub                      Upper bounds for fluxes
%    rev                     Reversibility of fluxes
%
%  targetMet   target metabolites
%              (e.g.,  'btn_c')
%  givenGvalue    The first column is the list of genes in the original model.
%                 The second column contains a 0/1 vector indicating which genes should be deleted.
%                 0 indicates genes to be deleted.
%                 1 indecates genes to be remained.
%
% OUTPUTS
%  GR        the growth rate obained when the gene deletion strategy is
%            applied and the growth rate is maximized.
%  PR        the minimum target metabolite production rate obained 
%            when the gene deletion strategy is applied and the growth rate is maximized.
%
%   Feb. 10, 2025  Takeyuki TAMURA
%


[model, targetRID, extype] = modelSetting(model, targetMet);

m = size(model.mets, 1);
n = size(model.rxns, 1);
g = size(model.genes, 1);
gid = find(model.c);
pid = targetRID;


model2 = model;
[grRules0] = calculateGR(model, givenGvalue);
lb2 = model.lb;
ub2 = model.ub;

for i=1:n
    if grRules0{i, 4} == 0
        lb2(i) = 0;
        ub2(i) = 0;
    end
end

gm.A = sparse(model.S);
gm.obj = -model.c;
gm.modelsense = 'Min';
gm.sense = repmat('=', 1, size(model.S, 1));
gm.lb = lb2;
gm.ub = ub2;
opt0 = gurobi(gm);

[opt0.x(gid) opt0.x(pid)]

GR0 = -opt0.objval;
lb2(gid) = GR0;
ub2(gid) = GR0;
model2.c(gid) = 0;
model2.c(pid) = 1;

gm2.A = sparse(model.S);
gm2.obj = model2.c;
gm2.modelsense = 'Min';
gm2.sense = repmat('=', 1, size(model.S, 1));
gm2.lb = lb2;
gm2.ub = ub2;
opt1 = gurobi(gm2);

GR = GR0
PR = opt1.x(pid)
[GR PR]

return;
end

