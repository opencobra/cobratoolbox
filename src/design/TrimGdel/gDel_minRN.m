function [gvalue gr pr it success] = gDel_minRN(model, targetMet, maxLoop, PRLB, GRLB)
% gDel_minRN (Step 1 of TrimGdel) determines a gene-deletion strategy by
% mixed-integer linear programming that achieves growth coupling for the
% target metabolite, repressing the maximum number of reactions through the
% gene-protein-reaction (GPR) relations.
%
% USAGE:
%
%    [gvalue gr pr it success] = gDel_minRN(model, targetMet, maxLoop, PRLB, GRLB)
%
% INPUTS:
%    model:        COBRA model structure with the fields:
%
%                * .rxns - reaction identifiers (n x 1 cell array)
%                * .mets - metabolite identifiers (m x 1 cell array)
%                * .genes - gene identifiers (g x 1 cell array)
%                * .grRules - gene-protein-reaction association rules (n x 1 cell array)
%                * .S - stoichiometric matrix (m x n, sparse)
%                * .c - linear objective coefficients (n x 1)
%                * .lb - lower flux bounds (n x 1)
%                * .ub - upper flux bounds (n x 1)
%
%    targetMet:    target metabolite identifier (e.g. 'btn_c')
%    maxLoop:      maximum number of iterations performed in gDel_minRN
%    PRLB:         minimum required production rate of the target metabolite
%                  used while searching for gene-deletion strategy candidates
%                  (not guaranteed once GR is maximized without PRLB)
%    GRLB:         minimum required growth rate used while searching for
%                  gene-deletion strategy candidates
%
% OUTPUTS:
%    gvalue gr pr it success:    Step 1 returns these five values together as
%                                the multiple-assignment list
%                                [gvalue gr pr it success]:
%
%                                * gvalue - gene-deletion strategy candidate:
%                                  column 1 lists the genes, column 2 is a 0/1
%                                  vector (0 = gene deleted, 1 = gene retained)
%                                * gr - growth rate obtained when the strategy is
%                                  applied and the growth rate is maximized
%                                * pr - target-metabolite production rate under
%                                  growth-rate maximization for that strategy
%                                * it - number of iterations needed to obtain the
%                                  solution
%                                * success - whether an appropriate strategy was
%                                  found (1 = success, 0 = failure)
%
% .. Author:    - Takeyuki Tamura, Mar 06, 2025
%

tic;
ori_model = model;
n = size(model.rxns, 1);
for i=1:n
   if model.ub(i) > 9999
       model.ub(i) = 1000;
   end
   if model.lb(i) < -9999
       model.lb(i) = -1000;
   end
end

gvalue = [];
gr = -1; pr = -1; it = 0; success = 0;

params.IntFeasTol = 1e-09;
changeTolerance = 1000;

sss=sprintf('gDel-minRN.mat');

[ori_model, targetRID, extype] = modelSetting(ori_model, targetMet);
[model, targetRID, extype] = modelSetting(model, targetMet);

m = size(model.mets, 1);
n = size(model.rxns, 1);
g = size(model.genes, 1);
vg = zeros(g, 1);
gid = find(model.c);
pid = targetRID;
model2 = model;
model2.c(gid) = 0;
model2.c(targetRID) = 1;

gm2.obj = -model2.c;
gm2.A = sparse(model2.S);
gm2.modelsense = 'Min';
gm2.sense = repmat('=', 1, m);
gm2.lb = model2.lb;
gm2.ub = model2.ub;
optPre = gurobi(gm2);

if strcmp(optPre.status, 'OPTIMAL') ~= 1
    display('no solution 1')
    return;
elseif -optPre.objval < PRLB
    display('TMPR < PRLB')
    return;
end
    
model2 = model;
model.lb(pid) = PRLB;
model.lb(gid) = GRLB;

gm.obj = -model.c;
gm.A = sparse(model.S);
gm.modelsense = 'Min';
gm.sense = repmat('=', 1, m);
gm.lb = model.lb;
gm.ub = model.ub;
opt0 = gurobi(gm);

TMGR = -opt0.objval;
big = TMGR; 
[term, ng, nt, nr, nko, reactionKO, reactionKO2term] = readGeneRules(model);
 [f, A, b, Aeq, beq, lb, ub, xname] = geneReactionMILP(model, term, ng, nt, nr, nko);
 
 lp.Aeq = [model.S zeros(m, ng+nt+nko+nko);
               zeros(size(Aeq, 1), n) Aeq zeros(size(Aeq, 1),nko);
               zeros(nko, nr+ng+nt) changeTolerance*eye(nko) -1*eye(nko)];
lp.beq = [zeros(m, 1); zeros(size(Aeq, 1),1); zeros(nko, 1)];
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

lp.A = [zeros(size(A,1), n) A zeros(size(A,1), nko);
           z3(ind,:) zeros(size(ind,2), ng+nt) z1(ind, ind) zeros(size(ind, 2), nko);
               -z3(ind, :) zeros(size(ind, 2),ng+nt) z2(ind, ind) zeros(size(ind, 2),nko)];
lp.b = [b; zeros(2*nko, 1)];
lp.lb = [model.lb; lb; zeros(nko, 1)];
lp.ub = [model.ub; ub; changeTolerance*ones(nko, 1)];
lp.f = [-model.c; zeros(ng+nt, 1); big*ones(nko, 1); zeros(nko, 1)];
for i = 1:n
    s1 = repelem('C', n);
    s2 = repelem('B', ng+nt+nko);
    s3 = repelem('I', nko);
    lp.ctype = sprintf('%s%s%s', s1, s2, s3);
end
A2 = lp.A;
b2 = lp.b;

it = 1;
while it <= maxLoop
    it
    gr = -1; pr = -1;

    gm.obj = lp.f;
    gm.A = sparse([lp.A; lp.Aeq]);
    gm.rhs =[lp.b; lp.beq];
    gm.modelsense = 'Min';
    gm.sense = horzcat(repmat('<', 1, size(lp.A, 1)), repmat('=', 1, size(lp.Aeq, 1)));
    gm.lb = lp.lb;
    gm.ub = lp.ub;
    gm.vtype = lp.ctype;
    % find a gene deletion strategy candidate
    opt = gurobi(gm,params);
    

    if strcmp(opt.status, 'OPTIMAL')
        for i = 1:n
            vx(i, it) = opt.x(i);
            result{i, it+1} = opt.x(i);
            result{i, 1} = model.rxns{i};
        end
        for i=1:ng
            vg(i, it) = opt.x(n+i);
            result{n+i, 1} = xname{i};
            result{n+i, it+1} = vg(i,it);
            gvalue{i, 1} = xname{i};
            gvalue{i, 2} = vg(i, it) > 0.1;
        end
        for i = 1:nt
            vt(i, 1) = opt.x(n+ng+i);
            result{n+ng+i, 1} = xname{ng+i};
            result{n+ng+i, it+1} = opt.x(n+ng+i);
        end
        for i=1:nko
            vko(i, it) = opt.x(n+ng+nt+i);
            vnewadd(i,it) = opt.x(n+ng+nt+nko+i);
            result{n+ng+nt+i, 1} = xname{ng+nt+i};
            result{n+ng+nt+i, it+1} = opt.x(n+ng+nt+i);
        end
    
    else
        system('rm -f clone*.log');
        if it == 1
            display('no solution 2')
            return;
        end
        display('no more candidates')
        system('rm -f clone*.log');
        return;
    end
    [grRules] = calculateGR(ori_model, gvalue);
    
    lb2 = ori_model.lb;
    ub2 = ori_model.ub;
    for i = 1:nr
        if grRules{i, 4} == 0
            lb2(i) = 0;
            ub2(i) = 0;
        end
    end

    gm2.obj = -ori_model.c;
    gm2.modelsense = 'Min';
    gm2.A = sparse(model.S);
    gm2.sense = repmat('=', 1, m);
    gm2.lb = lb2;
    gm2.ub = ub2;
    gm2.rhs = zeros(m,1);
    % validate the gene deletion candidate
    opt2 = gurobi(gm2,params);

    gm3 = gm2;
    gm3.obj(gid) = 0;
    gm3.obj(pid) = 1;
    gm3.lb(gid) = opt2.x(gid);
    gm3.ub(gid) = opt2.x(gid);
    % evaluate the minimum PR under the GR maximazation.
    opt3 = gurobi(gm3);
    
    grprList(it, :) = [opt2.x(gid) opt3.x(pid)];
    gr = opt2.x(gid); pr = opt3.x(pid);
    result2(:, it) = opt2.x;
    
    if (opt2.x(gid) >= GRLB) &&  (opt3.x(pid) >= PRLB)
        [opt2.x(gid) opt3.x(pid)];
        vg(:,it);
        success = 1;
        time = toc;
        system('rm -f clone*.log');
        return;
    end
    
    zeroList(:,it) = vko(:, it) < 0.01;
    dA = [zeros(1, nr+ng+nt) -(zeroList(:, it))' zeros(1, nko)];
    db = -1;
    lp.A = [lp.A; dA];
    lp.b = [lp.b; db];

    it = it + 1;
    system('rm -f clone*.log');
end
vg = vg > 0.1;

end

