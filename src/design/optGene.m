function [x, population, scores, optGeneSol] = optGene(model, targetRxn, substrateRxn, generxnList, MaxKOs, population)
% Implements the optgene algorithm.
%
% USAGE:
%
%    [x, population, scores, optGeneSol] = optGene(model, targetRxn, substrateRxn, generxnList, MaxKOs, population)
%
% INPUTS:
%    mode:          Model of reconstruction
%    targetRxn:     String name of reaction which is to be maximized.
%    substrateRxn:
%    generxnList:   List of genes or `rxns` which can be knocked out.  The
%                   program will guess which of the two it is, based on the
%                   content in model.
%
% OPTIONAL INPUT:
%    MaxKOs:
%    population:    population matrix (binary matrix). Use this
%                   parameter to interrupt simulation and resume afterwards.
%
% OUTPUTS:
%    x:             best optimized value found
%    population:    Population of individuals.  Pass this back into optgene to
%                   continue simulating where you left off.
%    scores:        An array of scores
%    optGeneSol:    `optGene` solution strcture
%
% .. Authors: - Jan Schellenberger and Adam Feist 04/08/08

global HTABLE % hash table for hashing results... faster than not using it.
HTABLE = java.util.Hashtable;
global MaxKnockOuts

ngenes = length(generxnList);

% figure out if list is genes or reactions
rxnok = 1;
geneok = 1;
for i = 1:length(generxnList)
    if(~ ismember(generxnList{i}, model.rxns)),  rxnok = 0; end
    if(~ ismember(generxnList{i}, model.genes)),geneok = 0; end
end
if geneok
    display('assuming list is genes');
elseif rxnok
    display('assuming list is reactions');
else
    display('list appears to be neither genes nor reactions:  aborting');
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PARAMETERS - set parameters here %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 5
    MaxKnockOuts = 10;
else
    MaxKnockOuts = MaxKOs;
end
mutationRate = 1/ngenes; % paper: a mutation rate of 1/(genome size) was found to be optimal for both representations.
crossovermutationRate = mutationRate*.2;  % the rate of mutation after a crossover.  This value should probably be fairly low.  It is only there to ensure that not every member of the population ends up with the same genotype.
CrossoverFraction = .80;    % Percentage of offspring created by crossing over (as opposed to mutation). 0.7 - 0.8 were found to generate the highest mean, but this can be adjusted.
PopulationSize = [125 125 125 125]; % paper: it was found that an increase beyond 125 individuals did not improve the results significantly.
Generations = 10000;    % paper: 5000.  maximum number of generations to perform
TimeLimit =  3600*24*2;  % global time limit in seconds
StallTimeLimit = 3600*24*1;   % Stall time limit (terminate after this much time of not finding an improvement in fitness)
StallGenLimit =  10000;       % terminate after this many generations of not finding an improvement
PlotFcns =  {@gaplotscores, @gaplotbestf, @gaplotscorediversity, @gaplotstopping, @gaplotmutationdiversity}; % what to plot.
crossfun = @(a,b,c,d,e,f) crossoverCustom(a,b,c,d,e,f,crossovermutationRate);
MigrationFraction = .1;   % how many individuals migrate (.1 * 125 ~ 12 individuals).
MigrationInterval = 100;  % how often individuals migrate from one population to another.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% END PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InitialPopulation = [];
if nargin > 5
    InitialPopulation = double(population);
end
options = gaoptimset(                                   ...
    'PopulationType', 'bitstring',                          ...
    'CreationFcn', @lowmutationcreation,                    ...
    'MutationFcn', {@mutationUniformEqual, mutationRate},   ...
    'PopulationSize', PopulationSize,                       ...
    'StallTimeLimit', StallTimeLimit,                       ...
    'TimeLimit', TimeLimit,                                 ...
    'PlotFcns', PlotFcns,                                   ...
    'InitialPopulation', InitialPopulation,                 ...
    'CrossoverFraction', CrossoverFraction,                 ...
    'CrossoverFcn', crossfun,                               ...
    'StallGenLimit', StallGenLimit,                         ...
    'Generations', Generations,                             ...
    'TolFun', 1e-10,                                        ...
    'Vectorize', 'on', ...
    'MigrationFraction', MigrationFraction, ...
    'MigrationInterval', MigrationInterval ...
    ... % 'SelectionFcn',  @selectionstochunif ...
    );

%     options
%     pause;

%finess function call
%FitnessFunction = @(x) optGeneFitness(x,model,targetRxn, generxnList, geneok);
FitnessFunction = @(x) optGeneFitnessTilt(x,model,targetRxn, generxnList, geneok);

gap.fitnessfcn  = FitnessFunction;
gap.nvars = ngenes;
gap.options = options;

[x,FVAL,REASON,OUTPUT,population, scores] = ga(gap);

% save the solution
[optGeneSol] = GetOptGeneSol(model, targetRxn, substrateRxn, generxnList, population, x, scores, geneok); % in case of genes

return;


%% Creation Function
% generates initial warmup with much lower number of mutations (on average
% one mutation per
function [Population] = lowmutationcreation(GenomeLength,FitnessFcn,options)
totalPopulation = sum(options.PopulationSize);
initPopProvided = size(options.InitialPopulation,1);
individualsToCreate = totalPopulation - initPopProvided;

% Initialize Population to be created
Population = true(totalPopulation,GenomeLength);
% Use initial population provided already
if initPopProvided > 0
    Population(1:initPopProvided,:) = options.InitialPopulation;
end
% Create remaining population
Population(initPopProvided+1:end,:) = logical(1/GenomeLength > rand(individualsToCreate,GenomeLength));
return;

%% Mutation Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% mutation function %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mutationChildren = mutationUniformEqual(parents,options,GenomeLength,FitnessFcn,state,thisScore,thisPopulation,mutationRate)
global MaxKnockOuts
if(nargin < 8)
    mutationRate = 0.01; % default mutation rate
end
mutationChildren = zeros(length(parents),GenomeLength);
for i=1:length(parents)
    child = thisPopulation(parents(i),:);
    kos = sum(child);
    mutationPoints = find(rand(1,length(child)) < mutationRate);
    child(mutationPoints) = ~child(mutationPoints);

    if MaxKnockOuts > 0
        while(sum(child(:))> MaxKnockOuts)
            ind2 = find(child);
            removeindex = ind2(randint(1,1,length(ind2))+1);
            child(removeindex) = 0;
        end
    end

    % with 50% chance, you will have fewer knockouts after mutation
    % than before.  This is to stop aquiring so many mutations.
    if rand > .5 && kos > 1
        while(sum(child(:))>= kos)
            ind2 = find(child);
            removeindex = ind2(randint(1,1,length(ind2))+1);
            child(removeindex) = 0;
        end
    end
    mutationChildren(i,:) = child;
end
return;

%% Crossover Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% crossover function %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xoverKids  = crossoverCustom(parents,options,GenomeLength,FitnessFcn,unused,thisPopulation, mutationRate)
nKids = length(parents)/2;
% Extract information about linear constraints
% Allocate space for the kids
xoverKids = zeros(nKids,GenomeLength);

global MaxKnockOuts;

% To move through the parents twice as fast as thekids are
% being produced, a separate index for the parents is needed
index = 1;

% for each kid...
for i=1:nKids
    % get parents
    r1 = parents(index);
    index = index + 1;
    r2 = parents(index);
    index = index + 1;

    % Randomly select half of the genes from each parent
    % This loop may seem like brute force, but it is twice as fast as the
    % vectorized version, because it does no allocation.
    for j = 1:GenomeLength
        if(rand > 0.5)
            xoverKids(i,j) = thisPopulation(r1,j);
        else
            xoverKids(i,j) = thisPopulation(r2,j);
        end
    end
    if MaxKnockOuts>0
        while(sum(xoverKids(i,:))> MaxKnockOuts)
            ind2 = find(xoverKids(i,:));
            removeindex = ind2(randint(1,1,length(ind2))+1);
            xoverKids(i,removeindex) = 0;
        end
    end
end
% also apply mutations to crossover kids...
xoverKids = mutationUniformEqual(1:size(xoverKids,1) ,[],GenomeLength,[],[],[],xoverKids,mutationRate);
return;


function state = gaplotmutationdiversity(options,state,flag,p1)
%GAPLOTSCOREDIVERSITY Plots a histogram of this generation's scores.
%   STATE = GAPLOTSCOREDIVERSITY(OPTIONS,STATE,FLAG) plots a histogram of current
%   generation's scores.
%
%   Example:
%   Create an options structure that uses GAPLOTSCOREDIVERSITY
%   as the plot function
%     options = gaoptimset('PlotFcns',@gaplotscorediversity);

%   Copyright 2003-2007 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2007/05/23 18:49:53 $
global MaxKnockOuts
if nargin < 4
    p1 = 10;
end

p1 = MaxKnockOuts+1;
p1 = [0:(MaxKnockOuts)];
switch flag
    case 'init'
        title('Mutation Histogram','interp','none')
        xlabel('number of mutations');
        ylabel('Number of individuals');
    case 'iter'
        % Check if Rank is a field and there are more than one objectives, then plot for Rank == 1
        if size(state.Score,2) > 1 && isfield(state,'Rank')
            index = (state.Rank == 1);
            % When there is one point hist will treat it like a vector
            % instead of matrix; we need to add one more duplicate row
            if nnz(index) > 1
                set(gca,'ylimmode','auto');
                hist(sum(state.Population(index,:)),p1);
            else
                set(gca,'ylim',[0 1]);
                hist([sum(state.Population(index,:)); sum(state.Population(index,:))],p1);
            end
            % Legend for each function <min max> values on the Pareto front
            nObj = size(state.Score,2);
            fminval = min(state.Score(index,:),[],1);
            fmaxval = max(state.Score(index,:),[],1);
            legendText = cell(1,nObj);
            for i = 1:nObj
               legendText{i} = ['fun',num2str(i),' [',sprintf('%g  ',fminval(i)), ...
                   sprintf('%g',fmaxval(i)),']'];
            end
            legend(legendText);
        else % else plot all score
            hist(sum(state.Population,2),p1);
        end
end
