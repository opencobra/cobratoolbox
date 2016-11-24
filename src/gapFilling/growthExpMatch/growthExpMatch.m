function [solution]=growthExpMatch(model, KEGGFilename, compartment, iterations, dictionary, logFile, threshold,KEGGBlackList)
%growExpMatch run the growthExpMatch algorithm
%
%   [solution]=growthExpMatch(model, KEGGFilename, compartment, iterations, dictionary, logFile, threshold, KEGGBlackList)
%
%INPUTS
% model         COBRA model structure
% KEGGFilename  File name containing Kegg database (.lst file with list of
%               reactions: each listing is reaction name followed by colon
%               followed by the reaction formula)
% compartment   [c] --> transport from cytoplasm [c] to extracellulat space
%               [e] (default), [p] creates transport from [c] to [p] 
%               and from [p] to [c]
% iterations    Number of iterations to run
% dictionary    n x 2 cell array of metabolites names for conversion from 
%               Kegg ID's to the compound abbreviations from BiGG database 
%               (1st column is compound abb. (non-compartmenalized) and 
%               2nd column is Kegg ID) Both columns are the same length.
%
%OPTINAL INPUTS
% logFile       solution is printed in this file (name of reaction added and
%               flux of that particular reaction) (Default = GEMLog.txt)
%
% threshold     threshold number for biomass reaction; model is considered 
%               to be growing when the flux of the biomass reaction is 
%               above threshold. (Default = 0.05)
%
%OUTPUT
% solution  MILP solution that consists of the continuous solution, integer
%               solution, objective value, stat, full solution, and
%               imported reactions
%
%
%%Procedure to run SMILEY:
%(1) obtain all input files (ie. model, CompAbr, and KeggID are from BiGG, KeggList is from Kegg website)
%(2) remove desired reaction from model with removeRxns, or set the model
%       on a particular Carbon or Nitrogen source
%(3) create an SUX Matrix by using the function MatricesSUX =
%       generateSUXMatrix(model,dictionary, KEGGFilename,compartment)
%(4) run it through SMILEY using [solution,b,solInt]=Smiley(MatricesSUX)
%(5) solution.importedRxns contains the solutions to all iterations
%
% MILPproblem
%  A      LHS matrix
%  b      RHS vector
%  c      Objective coeff vector
%  lb     Lower bound vector
%  ub     Upper bound vector
%  osense Objective sense (-1 max, +1 min)
%  csense Constraint senses, a string containting the constraint sense for
%         each row in A ('E', equality, 'G' greater than, 'L' less than).
%  vartype Variable types
%  x0      Initial solution

% Based on IT 11/2008
% Edited by JDO on 4/19/11

if nargin <8
    KEGGBlackList = {};
end
if nargin<2
    MatricesSUX= model;
    iterations=2;
else
    MatricesSUX = generateSUXMatrix(model,dictionary, KEGGFilename,KEGGBlackList,compartment);
end
if nargin <6
    logFile='GEMLog';
end
if nargin <7
    threshold= 0.05;
end


MatricesSUXori = MatricesSUX;

startKegg = find(MatricesSUX.MatrixPart ==2, 1, 'first');
stopKegg = find(MatricesSUX.MatrixPart ==2, 1, 'last');
lengthKegg = stopKegg -startKegg +1;
startEx = find(MatricesSUX.MatrixPart ==3, 1, 'first');
stopEx = find(MatricesSUX.MatrixPart ==3, 1, 'last');
lengthEx = stopEx -startEx +1;
if isempty(lengthEx)
    lengthEx = 0;
end

vmax = 1000;

[a,b]=size(MatricesSUX.S);

cols = b + lengthKegg + lengthEx;
rows = a + lengthKegg + lengthEx;

[i1,j1,s1] = find(MatricesSUX.S);

% Kegg
%add rows
i2a=(a+1:a+lengthKegg)';
j2a=(startKegg:stopKegg)';
s2a=ones(lengthKegg,1);
%add cols
i2b=(a+1:a+lengthKegg)';
j2b=(b+1:b+lengthKegg)';
s2b=-vmax*ones(lengthKegg,1);

%Exchange
%add rows
i3a=(a+lengthKegg+1:rows)';
j3a=(startEx:stopEx)';
s3a=ones(lengthEx,1);
%add cols
i3b=(a+lengthKegg+1:rows)';
j3b=(b+lengthKegg+1:cols)';
s3b=-vmax*ones(lengthEx,1);

if isempty(MatricesSUX.c);
    disp('No biomass reaction found');
else
    biomass_rxn_loc = find(MatricesSUX.c);
end

i = [i1;i2a;i2b;i3a;i3b;rows+1];
j=[j1;j2a;j2b;j3a;j3b;biomass_rxn_loc];
s=[s1;s2a;s2b;s3a;s3b;1];

MatricesSUX.A = sparse(i,j,s);
MatricesSUX.b = zeros(size(MatricesSUX.A,1),1);
%%% Set the threshold to 0.05 %%%
MatricesSUX.b(size(MatricesSUX.A,1),1) = threshold;

MatricesSUX.cOuter = zeros(size(MatricesSUX.A,2),1);
MatricesSUX.cOuter(b+1:b+lengthKegg)=1;
MatricesSUX.cOuter(b+lengthKegg+1:cols)=2.1;

MatricesSUX.csense(1:a)='E';
MatricesSUX.csense(a+1:rows)='L';
MatricesSUX.csense(rows+1) = 'G';

MatricesSUX.lb(b+1:cols)=0;
MatricesSUX.ub(b+1:cols)=1;
MatricesSUX.rxns(b+1:cols)=strcat(MatricesSUX.rxns(startKegg:stopEx),'dummy');

MatricesSUX.MatrixPart(b+1:cols)=4;
Int= find(MatricesSUX.MatrixPart>=4);

spy(MatricesSUX.A)

x0=zeros(size(MatricesSUX.A,2),1);

solInt=zeros(length(Int),1);

%%% setting the MILPproblem %%%
vartype(b+1:cols) = 'B';
vartype(1:b) = 'C';

MILPproblem.A = MatricesSUX.A;
MILPproblem.b = MatricesSUX.b;
MILPproblem.c = MatricesSUX.cOuter;
MILPproblem.lb = MatricesSUX.lb;
MILPproblem.ub = MatricesSUX.ub;
MILPproblem.csense = MatricesSUX.csense;
MILPproblem.osense = 1;
MILPproblem.vartype = vartype;
MILPproblem.x0 = x0;

for i = 1: iterations
    solution = solveCobraMILP(MILPproblem);
    
    if(solution.obj~=0)
        solInt(:,i+1)=solution.int;
        printSolutionGEM(MatricesSUX, solution,logFile,i);
        MILPproblem.A(rows+i+1,j2b(1):cols) = solInt(:,i+1)';
        MILPproblem.b(rows+i+1) = sum(solInt(:,i+1))-.1;
        MILPproblem.csense(rows+i+1) = 'L';
%         save([logFile '_solution_' num2str(i)]);
    end
    
    
    solution.importedRxns = findImportedReactions(solInt, MatricesSUX);
    tmp=find(solution.cont);
    for j=1:length(tmp)
        if(tmp(j)>=Int(1))
            MILPproblem.ub(tmp(j))=solution.cont(tmp(j));%%%
        end
    end
    if (solution.stat~=1)
        break
    end
end
printSolutionGEM(MatricesSUX, solution);

function importedRxns = findImportedReactions(solInt, MatricesSUX)
importedRxns= {};
stopModel = find((MatricesSUX.MatrixPart ==1), 1, 'last');
for i = 1: size(solInt,2)-1
    [x,y] = find(solInt(:, i+1));
    for j = 1: size(x)
        importedRxns{i, j} = MatricesSUX.rxns(stopModel + x(j));
        MatricesSUX.rxns(stopModel + x(j));
    end
end


