function [solICONGEMs, boundEf] = ICONGEMs(model, exp, genetxt, condition, threshold, alpha, numericFlag)
% Algorithm to Integrate a Gene Co-expression Network and Genome-scale Metabolic Model:
% This algorithm calculates the reaction flux distribution for each condition by applying 
% quadratic programming.
%
% USAGE:
%
%    [solICONGEMs, boundEf] = ICONGEMs(model, exp, genetxt, condition, threashold, alpha, numericFlag)
%
% INPUTS:
%
%    model:           input model (COBRA model structure)
%    exp:             expression profile corresponding to the gene names that 
%                     extract from gene expression profile file
%    genetxt:         list of gene names that extract from gene expression profile
%                     file
%    numericFlag:     1 if using Human Recon  (Default = 0).
%
% OPTIONAL INPUTS:
%    threshold:           The value of the correlation coefficient for constructing 
%                         the co-expression network (default value: 0.9).
%    condition:           Row vector indicating the number of conditions 
%                         corresponding to the conditions in exp 
%                         (default value: 1:size(exp, 2)).
%    alpha:               The value for the proportion of biomass (default value: 1).
%                         
% OUTPUTS:
%    solICONGEMs:             Flux distribution table corresponding to reaction flux names.
%    boundEf:                 Upper bound of E-flux.
%
% EXAMPLES:
%    % This could be an example that can be copied from the documentation to MATLAB:
%    solution = ICONGEMs(model, exp, genetxt, condition, threashold, alpha, numericFlag)
%    % without optional values:
%    solution = ICONGEMs(model, exp, genetxt)
%
%..Author: 
%    -Thummarat Paklao, 01/02/2024, Department of Mathematics and Computer Science, Faculty of Science, Chulalongkorn University, Thailand. 
%    -Apichat Suratanee, 01/02/2024, Department of Mathematics, Faculty of Applied Science, King Mongkut's University of Technology North Bangkok. 
%    -Kitiporn Plaimas, 01/02/2024, Department of Mathematics and Computer Science, Faculty of Science, Chulalongkorn University, Thailand.    

if (nargin < 4 || isempty(condition))
      condition = 1:size(exp, 2);
end
if (nargin < 5 || isempty(threshold))
      threshold = 0.9;
end
if (nargin < 6 || isempty(alpha))
      alpha = 0.99;
end
if (nargin < 7 || isempty(numericFlag))
      numericFlag = 0;
end

% construct the template model

if ~isempty(model.rules)
    model.grRules = model.rules;
end

modelN = model;
modelN.lb(modelN.lb >= 0) = 0;
modelN.lb(modelN.lb < 0) = -1000;
modelN.ub(modelN.ub <= 0) = 0;
modelN.ub(modelN.ub > 0) = 1000;

% convert to irreversible format

[modelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(modelN);

% Check that the gene names in the gene expression profile agree with 
% the gene names in the metabolic model.

geneinMet = zeros(size(genetxt, 1) - 1, 1);
for i = 2:size(genetxt, 1)
    for j = 1:size(modelIrrev.genes, 1)
        if string(genetxt(i)) == string(modelIrrev.genes(j))
            geneinMet(i - 1) = 1;
        end
    end
end
if sum(sum(geneinMet)) == 0
    disp("gene name in gene expression data is not agree gene name in metabolic model")
end

% Choose only the gene expression profiles that match genes in the metabolic model.

exp1 = exp(geneinMet == 1, :);
txt2 = genetxt([0; geneinMet] == 1, 1);

% remove missing data

[exp1, TF] = rmmissing(exp1, 1);
txt2 = txt2(~TF, 1);
geneincoexnet = modelIrrev.genes(~TF);

% Construct co-expression network 

cor = corr((exp1)');
cor1 = cor >= threshold;

% Find gene pairs that have a high correlation in the co-expression network.

indCorGene = zeros(1, 2);
l = 1;
for i = 1:size(cor, 1)
    for j = i:size(cor,1)
        if (cor1(i,j) ~= 0) && (i ~= j)
            indCorGene(l, 1) = i;
            indCorGene(l, 2) = j;
            l = l + 1;
         end
    end
end

coGene = cell(size(indCorGene, 1), 2);
coGene(:, 1) = geneincoexnet(indCorGene(:, 1), 1);
coGene(:, 2) = geneincoexnet(indCorGene(:, 2), 1);

NameRxn={};
for i = 1:size(modelIrrev.genes)
    [z1, NameRxn{i}] = findRxnsFromGenes(modelIrrev, modelIrrev.genes{i, 1}, numericFlag, 1);
end

% Find reactions that correspond to the gene

NameCorRxn = {};
for i = 1:size(coGene, 1)
    NameCorRxn{i, 1} = NameRxn{find(modelIrrev.genes == string(coGene(i, 1)))};
    NameCorRxn{i, 2} = NameRxn{find(modelIrrev.genes == string(coGene(i, 2)))};
end

f = 0;
h = 0;
indCorRxn = zeros(10, 2);
for i = 1:size(NameCorRxn, 1)
    if (~isempty(NameCorRxn{i, 1}) && ~isempty(NameCorRxn{i, 2}))
    for j = 1:size(NameCorRxn{i, 1}, 1)
        f = f + size(NameCorRxn{i, 2}, 1);
        indCorRxn(h + 1 : h + size(NameCorRxn{i, 2}, 1), 1) = findRxnIDs(modelIrrev, NameCorRxn{i, 1}{j, 1}); 
            for w = 1:size(NameCorRxn{i, 2}, 1)
                indCorRxn(h + w,2)=findRxnIDs(modelIrrev,NameCorRxn{i, 2}{w, 1}); 
            end
            h = f;
    end
    end
end

% Construct a reaction pair matrix.

R = zeros(length(modelIrrev.rxns),length(modelIrrev.rxns));
for i = 1:size(indCorRxn, 1)
    if indCorRxn(i, 1) ~= indCorRxn(i, 2)
        R(indCorRxn(i, 1), indCorRxn(i, 2)) = 1;       
    end
end

% Construct an irreversible reaction matrix from the reversible reactions 
% that are decomposed into the same components.

Re = zeros(size(R));
for i = 1:length(model.rxns)
    if length(rev2irrev{i, 1}) == 2
        Re(i, rev2irrev{i,1}(2)) = 1;
    end
end

% Process gene expression data based on Gene-Protien-Reaction (GPR) associations.

geneExdat = zeros(length(modelIrrev.genes), 1);
nupb = zeros(length(modelIrrev.rules), size(exp, 2));
for ch = 1:size(exp, 2)
for i = 1:length(modelIrrev.genes)
    cc = 0;
    for j = 1:length(genetxt(:, 1)) - 1
        if string(modelIrrev.genes(i)) == string(genetxt(j + 1, 1))
            geneExdat(i) = exp(j, ch);
            cc = cc + 1;
        end
    end
    if geneExdat(i) == 0 && cc == 0
        geneExdat(i) = 1000;
    end
end

for i = 1:length(modelIrrev.rules)
    rulegene = modelIrrev.rules{i};
    if isempty(rulegene)
        rsum = 1000;
    else
        newrule = split(rulegene,"|");
        nrule = size(newrule, 1);
        rsum = 0;
        for j = 1:nrule
            newrule1 = newrule{j};
            nnrule = length(newrule1);
            rmin = inf;
            for k = 1:nnrule
                if newrule1(k) == 'x'
                    r1 = k+2;
                end
                if (newrule1(k) == ')' && newrule1(k-1) ~= ' ' && newrule1(k - 1) ~= ')')
                    rmin = min(rmin, geneExdat(str2num(convertCharsToStrings((newrule1(r1:k - 1))))));
                end    
            end
            rsum = rsum + rmin;
        end 
    end
    nupb(i, ch) = rsum;
end

end
PosNupb = nupb >= 1000;
nupb(PosNupb) = max(nupb(~PosNupb));

% Construct a table for reporting the results

solution = table(model.rxns);
solutionFull = table(modelIrrev.rxns);
solutionEf = table(model.rxns);
solutionEfFull = table(modelIrrev.rxns);
n = 0;
 
% Construct the model and calculate the flux distribution.

for ch = condition
    n = n + 1;
disp("Condition :"); disp(ch);
model3 = changeRxnBounds(modelIrrev,modelIrrev.rxns, nupb(:, ch), 'u');
solution1 = optimizeCbModel(model3);

Trans0 = zeros(size(modelIrrev.mets, 1),size(modelIrrev.rxns, 1));
Trans2 = -1 * eye(size(modelIrrev.rxns, 1));
S2 = zeros(size(modelIrrev.rxns, 1));
bn = (-1) * ones(size(modelIrrev.rxns, 1), 1);
for i = 1:length(modelIrrev.rxns)
    if  max(nupb(i, :)) ~= 0
        S2(i, i) = 1 / max(nupb(i, :));
    end
    if max(nupb(i, :)) == 0
        Trans2(i, i) = 0;
        bn(i, 1) = 0;
    end
end

Obj4 = [modelIrrev.c' zeros(1, size(modelIrrev.rxns, 1))];

lob = [model3.lb;  ones(size(modelIrrev.rxns, 1), 1)];
upb = [model3.ub; 2 * ones(size(modelIrrev.rxns, 1), 1)];

O = [zeros(size(R)) zeros(size(R)); zeros(size(R)) R]; 
Aeq = [modelIrrev.S Trans0; S2 Trans2; Obj4]; 
beq = [zeros(size(modelIrrev.mets, 1), 1); bn; alpha * solution1.f];

model2 = struct;
model2.lb = lob;
model2.ub = upb; 
model2.A = sparse(Aeq);
model2.sense = [char('=' * ones(size(model2.A,1) - 1, 1)) ; char('>')]; 
model2.rhs = beq;
model2.modelsense = 'max'; 
numrxn = [1:length(modelIrrev.rxns)]; 
j = 1;
for i = 1:length(model.rxns)
    if length(Re(Re(i, :)>0)) == 1
model2.quadcon(j).Qrow = i;
model2.quadcon(j).Qcol = numrxn(Re(i, :)>0);
model2.quadcon(j).Qval = 1.0;
model2.quadcon(j).rhs = 0.0;
model2.quadcon(j).q = sparse(zeros(2*size(Re, 1), 1));
model2.quadcon(j).sense = '=';
j = j + 1;
    end
end
model2.Q = sparse(O);
params.NonConvex = 2;
result = gurobi(model2, params);
x = result.x;
solutionFull(:, n + 1) = table(x(1:size(modelIrrev.rxns),1));
solutionEfFull(:, n + 1) = table(solution1.x);
solFlux = [];
solFluxEf = [];
for i = 1:length(model.rxns)
    if length(rev2irrev{i, 1}) == 1
        solFlux(i, 1) = x(i, 1);
        solFluxEf(i, 1) = solution1.x(i, 1);
    else
        solFlux(i, 1) = (x(rev2irrev{i, 1}(1, 1))-x(rev2irrev{i, 1}(1, 2)));
        solFluxEf(i, 1) = (solution1.x(rev2irrev{i, 1}(1, 1))-solution1.x(rev2irrev{i, 1}(1, 2)));
        if solFluxEf(i, 1)>=0
            solutionEfFull{rev2irrev{i, 1}(1, 1), n + 1} = solFluxEf(i, 1);
            solutionEfFull{rev2irrev{i, 1}(1, 2), n + 1} = 0;
        elseif solFluxEf(i, 1)<0
            solutionEfFull{rev2irrev{i, 1}(1, 1), n + 1} = 0;
            solutionEfFull{rev2irrev{i, 1}(1, 2), n + 1} = abs(solFluxEf(i, 1));

        end
    end
end
solution(:, n + 1) = table(solFlux);
solutionEf(:, n + 1) = table(solFluxEf);

end
boundEf = table(nupb);
solICONGEMs.sol = solution;
solICONGEMs.solRev = solutionFull;

solEflux.sol = solutionEf;
solEflux.solRev = solutionEfFull;

% Export the results

filename = 'result.csv';
writetable(solution, filename)
end

