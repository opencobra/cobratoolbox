function [ResultsOrganEss] = organEssentiality(model, LPSolver)
% Compute organ essentiality in a whole-body model
%
% This function computes the organ essentiality in a whole-body model by
% setting each organ's value to zero in the whole-body objective reaction,
% setting all organ-specific reaction bounds to zero (lower and upper), and
% then computing whether a non-zero flux through this objective is still
% possible.
%
% USAGE:
%
%    [ResultsOrganEss] = organEssentiality(model, LPSolver)
%
% INPUTS:
%    model:     Whole-body metabolic model, with fields:
%
%                 * .sex - 'male' or 'female'
%                 * .A - constraint matrix (stoichiometry plus coupling constraints)
%    LPSolver:    LP solver to use ('ILOGcomplex', 'tomlab_cplex' default)
%
% OUTPUT:
%    ResultsOrganEss:    Maximal flux value for the whole-body reaction for each organ:
%                       col 1 organ name, col 2 max flux, col 3 min flux (if minimisation
%                       is activated; default inactive), col 4 solver status (1 feasible,
%                       5 feasible with numerical difficulties, 3 infeasible)
%
% .. Authors:
% ..    - Ines Thiele, 2016
% ..    - Ines Thiele, added option to specify LPSolver - 10/2018

if ~exist('LPSolver','var')
    LPSolver = 'tomlab_cplex';
end

% Route through the COBRA solver abstraction (optimizeWBModel) so this module
% honours changeCobraSolver; the former solveCobraLPCPLEX fast path is removed
% (feature 015-solver-spine-hardening).
[solverOK, solverInstalled] = changeCobraSolver(LPSolver, 'LP');

% reset the bounds on the whole-body objective
model = changeRxnBounds(model,'Whole_body_objective_rxn',0,'l');
model = changeRxnBounds(model,'Whole_body_objective_rxn',1000,'u');

% define whole-body objective as objective function
model = changeObjective(model,'Whole_body_objective_rxn');

sex = model.sex;

% List of organs
getOrganWeightFraction;
OrganLists;
for i  = 1 : length(OrgansListShort)
    modelOrganEss = model;
    % redefine objective by removing the organ from the whole-body reaction
    O = strmatch(OrgansListShort{i},ObjectiveComponents);
    R = find(ismember(modelOrganEss.rxns,'Whole_body_objective_rxn'));
    M = find(ismember(modelOrganEss.mets,strcat(ObjectiveComponents{O},'_dummy_objective')));
    modelOrganEss.S(M,R)=0; % no requirement of this objective part in OF
    modelOrganEss = changeObjective(modelOrganEss,'Whole_body_objective_rxn');
    % set all reaction bounds in this organ to 0
    R1 = strmatch(OrgansListShort{i},modelOrganEss.rxns);
    modelOrganEss.lb(R1)=0;
    modelOrganEss.ub(R1)=0;
    % maximize the whole-body reaction
    modelOrganEss.osenseStr = 'max';
    tic;
    FBA = optimizeWBModel(modelOrganEss);
    timeTaken = toc;
    fprintf('%u%s%s%s%f\n',timeTaken,' sec. ',OrgansListShort{i},' obj = ',FBA.f)
    ResultsOrganEss(i,1)=OrgansListShort(i);
    
    feasible = FBA.stat == 1;
    if feasible
        ResultsOrganEss{i,2}=num2str(FBA.v(modelOrganEss.c~=0)); % max
        if 0 % also compute the minimal possible flux through the objective
            modelOrganEss.osenseStr = 'min';
            tic;
            FBA = optimizeWBModel(modelOrganEss);
            timeTaken = toc;
            ResultsOrganEss{i,3}=num2str(FBA.v(modelOrganEss.c)~=0);%min
        end
        %feasible
        ResultsOrganEss{i,4}=num2str(FBA.origStat);
    else
        if FBA.stat == -1 ||  FBA.stat == 2
            %display solution in case there is a problem
            fprinf('%s\n',['Problem with FBA for organ: ' ResultsOrganEss{i,1} '. FBA solution is:'])
            FBA
        end
            
        %infeasible or otherwise
        ResultsOrganEss{i,2}=NaN; % min
        ResultsOrganEss{i,3}=NaN;%max
        ResultsOrganEss{i,4}=num2str(FBA.origStat);
    end
end
