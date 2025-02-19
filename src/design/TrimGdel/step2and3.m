function [gvalue, GR, PR, size1, size2, size3] = step2and3(model, targetMet, givenGvalue)
% The function step2and3 implements Step 2 and Step 3 of TrimGdel.
% Step 2 minimizes the number of deleted genes while maintaining 
% which reactions are repressed.
% Step 3 trims unnecessary deleted genes while maintaining GR and PR
% at the maximization of GR.
%
% function [gvalue, finalGRPR, size1, size2, size3] = step2and3(model, targetMet, givenGvalue)
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
%             (e.g.,  'btn_c')
%  givenGvalue  a large gene deletion strategy (obtained by step1).
%              The first column is the list of genes.
%              The second column is a 0/1 vector indicating which genes should be deleted.
%              0 indicates genes to be deleted.
%              1 indecates genes to be remained.
%
% OUTPUTS
%  gvalue       a small gene deletion strategy (obtained by TrimGdel).
%              The first column is the list of genes.
%              The second column is a 0/1 vector indicating which genes should be deleted.
%              0 indicates genes to be deleted.
%              1 indecates genes to be remained.
%  GR           the maximum growth rate when the obtained gene deletion
%              strategy represented by gvalue is applied.
%  PR           the minimum production rate of the target metabolite under 
%              the maximization of the growth rate when the obtained gene deletion
%              strategy represented by gvalue is applied.
% size1        the number of gene deletions after Step1.
% size2        the number of gene deletions after Step2.
% size3        the number of gene deletions after Step3.
%
%   Feb. 10, 2025  Takeyuki TAMURA
%

sss = sprintf('step2and3.mat');
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

gm0.obj = -model.c;
gm0.A = sparse(model.S);
gm0.rhs = zeros(m, 1);
gm0.modelsense = 'Min';
gm0.sense = repmat('=', 1, m);
gm0.lb = lb2;
gm0.ub = ub2;
% derives the initial maximum GR.
opt0 = gurobi(gm0);

GR0 = -opt0.objval;
lb2(gid) = GR0;
ub2(gid) = GR0;
model2.c(gid) = 0;
model2.c(pid) = 1;

gm1.obj = -model2.c;
gm1.A = sparse(model.S);
gm1.rhs = zeros(m, 1);
gm1.modelsense = 'Min';
gm1.sense = repmat('=', 1, m);
gm1.lb = lb2;
gm1.ub = ub2;
% derives the initial minimum PR under the GR maximization.
opt1 = gurobi(gm1);

GRLB = opt1.x(gid);
PRLB = opt1.x(pid);
[term, ng, nt, nr, nko, reactionKO, reactionKO2term] = readGeneRules(model);
[f, intcon, A, b, Aeq, beq, lb, ub, xname] = geneReactionMILP(model, term, ng, nt, nr, nko, reactionKO);

lp.Aeq = Aeq;
lp.beq = [zeros(size(lp.Aeq, 1), 1)];
j = 1;
for i=1:size(model.grRules, 1)
    if isempty(model.grRules{i, :}) == 0
        ind(1,j) = i;
        j = j+1;
    end
end
z1 = -diag(model.ub);
z2 = diag(model.lb);
z3 = eye(n);
lp.A = A;
lp.b = b;
lp.lb = lb;
lp.ub = ub;

for i=1:ng
    if givenGvalue{i, 2} == 1
        lp.lb(i, 1) = 1;
        lp.ub(i, 1) = 1;
    end
end

[grRules0] = calculateGR(model, givenGvalue);

j = 1;
for i=1:n
    if isempty(model.grRules{i, 1}) == 0
        lp.lb(ng+nt+j, 1) = grRules0{i, 4};
        lp.ub(ng+nt+j, 1) = grRules0{i, 4};
        j = j + 1;
    end
end

lp.f = [-ones(ng, 1); zeros(nt, 1); zeros(nko, 1)];
for i=1:n
    s2 = repelem('B', ng+nt+nko);
    lp.ctype = sprintf('%s%s', s2);
end

gm.obj = lp.f;
gm.A = sparse([lp.A; lp.Aeq]);
gm.rhs = [lp.b; lp.beq];
gm.modelsense = 'Min';
gm.sense = horzcat(repmat('<', 1, size(lp.A,1)), repmat('=', 1, size(lp.Aeq, 1)));
gm.lb = lp.lb;
gm.ub = lp.ub;
gm.vtype = lp.ctype;
% MILP for Step 2
opt = gurobi(gm);

gvalue = givenGvalue;
if strcmp(opt.status, 'OPTIMAL')
    for i=1:ng
        vg(i, 1) = opt.x(i);
        gvalue{i, 2} = opt.x(i);
    end
    for i=1:nt
        vt(i, 1) = opt.x(ng+i);
    end
    for i=1:nko
        vko(i, 1) = opt.x(ng+nt+i);
    end
end
gvalue0 = gvalue;

trimmed = 1;
model2 = model;
grprlist(1, 1) = opt1.x(gid);
grprlist(1, 2) = opt1.x(pid);
grprlist(1,3) = opt1.x(gid);
grprlist(1,4) = opt1.x(pid);
k = 2;

while trimmed == 1;
    trimmed = 0;
    for i=1:ng
        i
        if gvalue{i, 2} == 0
            gvalue{i, 2} = 1;
            [grRules2] = calculateGR(model, gvalue);
            lb2 = model.lb;
            ub2 = model.ub;

            for j=1:n
                if grRules2{j, 4} == 0
                    lb2(j) = 0;
                    ub2(j) = 0;
                end
            end

            gm2.obj = -model.c;
            gm2.A = sparse(model.S);
            gm2.rhs = zeros(m, 1);
            gm2.modelsense = 'Min';
            gm2.sense = repmat('=', 1, m);
            gm2.lb = lb2;
            gm2.ub = ub2;
            % evaluate the maximum GR when a gene deletion is trimmed.
            opt2 = gurobi(gm2);
            

            grprlist(k, 1) = opt2.x(gid);
            grprlist(k, 2) = opt2.x(pid);
            GR2 = -opt2.objval;
            lb2(gid) = GR2;
            ub2(gid) = GR2;
            model2.c(gid) = 0;
            model2.c(pid) = 1;

            gm3.obj = model2.c;
            gm3.A = sparse(model.S);
            gm3.rhs = zeros(m, 1);
            gm3.modelsense = 'Min';
            gm3.sense = repmat('=', 1, m);
            gm3.lb = lb2;
            gm3.ub = ub2;
            % evaluate the minimum PR under the GR maximization when a gene
            % is trimmed.
            opt3 = gurobi(gm3);
            

            grprlist(k, 3) = opt3.x(gid);
            grprlist(k, 4) = opt3.x(pid);
            if  ((opt3.x(gid) < 0.999 * GRLB) || (opt3.x(pid) < 0.999*PRLB))
                gvalue{i, 2} = 0;
                grprlist(k, :) = grprlist(k-1, :);
                
            else
                trimmed = 1;
               
            end
            GR = grprlist(k, 3);
            PR = grprlist(k, 4);
            k = k+1;
        end
    end
end

gvalueList = horzcat(givenGvalue(:, 2), gvalue0(:, 2), gvalue(:, 2));
size1 = size(find(cell2mat(givenGvalue(:, 2)) == 0), 1);
size2 = size(find(cell2mat(gvalue0(:, 2)) == 0), 1);
size3 = size(find(cell2mat(gvalue(:, 2)) == 0), 1);

return;
end

