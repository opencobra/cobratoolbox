function [metMWrange,metForm,ele,metEle,rxnBal,infeasibility,inconUB,sol,LP] = computeMetMWrange(model,metKnown,metInterest,rxns,percent,varargin)
% Compute the minimum and maximum molecular weight (MW) of a metabolie
% given a set of formulas for the known metabolites using a set of reactions. 
% Done by first minimizing the mass-and-charge imbalance. Then fixing the 
% imbalance at the minimum or higher level, minimize and maximize the molecular
% weight of the met of interest.
%
%[metMWrange,metForm,metFeas,rxnBal,ele,metEle,LP] = computeMetMWrange(model,metKnown,metInterest,rxns,percent,param)
% Input: 
%    model         COBRA model
%    metKnown      A known set of metabolites with formulas (character array or IDs)
%    metInterest   The metabolite of interest (character or ID)
%    rxns          The set of reactions used to compute the formula of metInterest 
%                  (character array or IDs)
%    (optional)
%    percent       The percent of inconsistency allowed when calculating the range
%                  for the molecular weight. The constraints added are
%                  sum(inconsistency_e) <= min(sum(inconsistency_e)) * (1 + percent)
%                  for each element e. Default percent = 0
%    parameters    Parameters for Cobra Toolbox (see help solveCobraLP), 
%                  parameter name followed by value, or parameter structre
%
% Output:
%    metMWrange    [min MW, max MW] (1 x 2 vector)
%    metForm       The corresponding empirical formulas (1 x 2 cell array)
%    ele           elements corresponding to the row of rxnBal, as well as
%                  to the coloumn of metEle
%  (metEle, rxnBal, sol, infeasibility, inconUB, each being a structure 
%  with .minIncon, .minMW, .maxMW, corresponding to the results from
%  min. inconsistency, min. molecular weight and max. molecular weight)
%    metEle        Chemical formulae in a #mets by #elements matrix
%    rxnBal        Elemental balance of each reaction (#elements x #rxns matrix)
%    infeasibility Infeasibility from the corresponding optimization (#elements x 1 vector)
%    inconUB       the maximum allowed inconsistency used to obtain solutions (#elements x 1 vector)
%                  If an element e is generic, it does not contribute to
%                  the molecular weight and the optimization is not performed.
%                  inconUB.minMW(e) = inconUB.maxMW(e) = NaN in this case.
%    sol           #elements x 1 solution structure array returned by solveCobraLP
%    LP            LP structure for solveCobraLP

%% Initialization
if nargin < 5 || isempty(percent)
    percent = 0;
end
if nargin < 4 || isempty(rxns)
    rxnC = find(sum(model.S~=0,1)>1 & (model.lb ~=0 | model.ub ~= 0)')';
elseif iscell(rxns) || ischar(rxns)
    rxnC = findRxnIDs(model,rxns);
else
    rxnC = rxns;
end
if any(rxnC == 0)
    error('%s in rxns is not in the model.', rxns{find(rxnC==0,1)});
end
if nargin < 2 || isempty(metKnown)
    metKnown = model.mets(~cellfun(@isempty,model.metFormulas));
end
if iscell(metKnown) || ischar(metKnown)
    metK = findMetIDs(model,metKnown);
else
    metK = metKnown;
end
if any(metK == 0)
    error('%s in metKnown is not in the model.', metKnown{find(metK==0,1)});
end
if iscell(metInterest) || ischar(metInterest)
    metInterest = findMetIDs(model,metInterest);
end
metInterest0 = metInterest;
if metInterest == 0
    error('The ID for the metabolite of interest is incorrect.');
elseif ismember(metInterest,metK)
    metK(metK == metInterest) = [];
end
metKform = cellfun(@isempty,model.metFormulas(metK));
if any(metKform)
    warning('Some mets in metKnown do not have formulas in the model. Ignore them.');
end
%All formulas must be in the form of e.g. Abc2Bcd1. Elements are
%represented by one capital letter followed by lower case letter or
%underscore, followed by a number for the stoichiometry. No brackets or
%other symbols allowed.
[metK,metKform] = deal(metK(~metKform), model.metFormulas(metK(~metKform)));
%%Now handled by checkEleBalance
% re = regexp(metKform,'[A-Z][a-z_]*(\-?\d+\.?\d*)?','match');
% re = cellfun(@(x) strjoin(x,''),re,'UniformOutput',false);
% goodForm = strcmp(re, strtrim(metKform));
% if ~all(goodForm)
%     goodForm = find(~goodForm,1);
%     error('%s has an invalid formula %s\n',metKnown{goodForm},metKform{goodForm});
% end
%get feasibility tolerance
if ~isempty(varargin) && isstruct(varargin{1}) && isfield(varargin{1}, 'feasTol')
    feasTol = varargin{1}.feasTol;
else
    feasTolInInput = find(strcmp(varargin,'feasTol'),1);
    if ~isempty(feasTolInInput)
        if feasTolInInput == numel(varargin) || ~isnumeric(varargin{feasTolInInput+1})
            error('Invalid input for the parameter feasTol.');
        end
        feasTol = varargin{find(feasTolInInput)+1};
    else
        feasTol = getCobraSolverParams('LP',{'feasTol'});
    end
end
%total inconsistence allowed
tolIncon = @(incon) round(incon * (1 + 1e-7 + abs(percent)) + 1e-5,8,'significant');
%% main loop
[~,ele,metEleK] = checkEleBalance(metKform);%chemical formulae in matrix
eleCh = strcmp(ele,'Charge'); %charge
m = size(model.S,1);%number of mets
nE = numel(ele);%number of elements
mK = numel(metK);%number of known mets
mU = m - mK; %number of unknown mets
metU = setdiff((1:m)',metK); %index for unknown mets
metInterest = find(metU == metInterest); %met of interest
nR = numel(rxnC); %number of reactions to be balanced

LP = struct();
%constraint matrix: S_unknown' n_unknown + x_pos - x_neg
LP.A = [model.S(metU,rxnC)', speye(nR), -speye(nR); sparse(1, mU + nR*2)];
LP.ub = inf(mU + nR * 2, 1);
%give an upper bound for the met of interest
LP.ub(metInterest) = 1e7;
LP.lb = zeros(mU + nR * 2, 1);
%minimize sum(x_pos + x_neg)
cMinIncon = [zeros(mU,1); ones(nR * 2, 1)];
LP.csense = [char('E' * ones(1, nR)), 'L'];
%molecular weight of each element
cMW = MW(ele);
%chemical formulae
[metEle.minIncon, metEle.minMW, metEle.maxMW] = deal(NaN(m, nE));
[metEle.minIncon(metK,:), metEle.minMW(metK,:), metEle.maxMW(metK,:)] = deal(metEleK);
%infeasibility of each solve
[infeasibility.minIncon, infeasibility.minMW, infeasibility.maxMW] = deal(inf(nE,1));
%bound on the total inconsistency allowed
[inconUB.minMW, inconUB.maxMW] = deal(zeros(nE, 1));
for j = 1:nE
    LP.A(end,:) = 0;
    LP.c = cMinIncon;
    %RHS: -S_known' * n_known
    LP.b = [-model.S(metK,rxnC)' * metEleK(:,j); 0];
    LP.osense = 1; %minimize
    if eleCh(j)
        LP.lb(1:mU) = -inf;
        LP.lb(metInterest) = -1e7;
    end
    %solve for minimum inconsistency
    if nargin < 6
        sol.minIncon(j) = solveCobraLP(LP);
    else
        sol.minIncon(j) = solveCobraLP(LP, varargin{:});
    end
    if isfield(sol.minIncon(j),'full') && numel(sol.minIncon(j).full) == mU + nR*2
        metEle.minIncon(metU,j) = sol.minIncon(j).full(1:mU);
    else
        metEle.minIncon(metU,j) = NaN;
    end
    %manually check feasibility
    infeas = checkSolFeas(LP, sol.minIncon(j));
    infeasibility.minIncon(j) = infeas;
    if infeas <= feasTol %should always be feasible
        %find the range for the stoichiometry
        if ~isnan(cMW(j)) && cMW(j) > 0  %exclude generic groups, which have value NaN in c
            %change objective to the stoichiometry for elemental component in the met of interest
            LP.c(:) = 0;
            LP.c(metInterest) = cMW(j);
            %sum(inconsist_e) <= min_inconsist_e * (1+percent)
            LP.A(end,:) = cMinIncon';
            inconJ = tolIncon(sol.minIncon(j).obj);
            LP.b(end) = inconJ;
            %solve for minimum molecular weight
            LP.osense = 1;
            %reuse the basis if it exists.
            if isfield(sol.minIncon(j), 'basis')
                LP.basis = sol.minIncon(j).basis;
            end
            f = 1e-6;
            while f <= 1e-4
                if nargin < 6
                    sol.minMW(j) = solveCobraLP(LP);
                else
                    sol.minMW(j) = solveCobraLP(LP, varargin{:});
                end
                infeas = checkSolFeas(LP, sol.minMW(j));
                if infeas <= feasTol
                    break
                end
                f = f * 10;
                LP.b(end) = inconJ * (1 + f);
            end
            if isfield(sol.minMW(j),'full') && numel(sol.minMW(j).full) == mU + nR*2
                metEle.minMW(metU,j) = sol.minMW(j).full(1:mU);
            else
                metEle.minMW(metU,j) = NaN;
            end
            %infeasibility
            infeasibility.minMW(j) = infeas;
            %inconsistency bound
            inconUB.minMW(j) = LP.b(end);
            LP.b(end) = inconJ;
            %solve for maximum molecular weight
            LP.osense = -1;
            f = 1e-6;
            while f <= 1e-4
                if nargin < 6
                    sol.maxMW(j) = solveCobraLP(LP);
                else
                    sol.maxMW(j) = solveCobraLP(LP, varargin{:});
                end
                infeas = checkSolFeas(LP, sol.maxMW(j));
                if infeas <= feasTol
                    break
                end
                f = f * 10;
                LP.b(end) = inconJ * (1 + f);
            end
            if isfield(sol.maxMW(j),'full') && numel(sol.maxMW(j).full) == mU + nR*2
                metEle.maxMW(metU,j) = sol.maxMW(j).full(1:mU);
            else
                metEle.maxMW(metU,j) = NaN;
            end
            %infeasibility
            infeasibility.maxMW(j) = infeas;
            %inconsistency bound
            inconUB.maxMW(j) = LP.b(end);
        else
            %the current element has no weight (generic element).
            %The solution would be the same.
            [metEle.minMW(metU,j), metEle.maxMW(metU,j)] = deal(metEle.minIncon(metU,j));
            [sol.minMW(j), sol.maxMW(j)] = deal(sol.minIncon(j));
            [sol.minMW(j).obj, sol.maxMW(j).obj] = deal(0);
            [infeasibility.minMW(j), infeasibility.maxMW(j)] = deal(infeasibility.minIncon(j));
            [inconUB.minMW(j), inconUB.maxMW(j)] = deal(NaN);
        end
    end
    if eleCh(j)
        LP.lb(:) = 0;
    end
end

%% post-process to get the MW range
%reaction balance
rxnBal.minIncon = metEle.minIncon' * model.S;
rxnBal.minMW = metEle.minMW' * model.S;
rxnBal.maxMW = metEle.maxMW' * model.S;
    
metMWrange = [sum([sol.minMW.obj]), sum([sol.maxMW.obj])];
metInterestMatrix = [metEle.minMW(metInterest0,:);metEle.maxMW(metInterest0,:)];
metForm = convertMatrixFormulas(ele,metInterestMatrix);
metForm = metForm(:)';

eleG = isnan(cMW) & ~eleCh(:);
if any(abs(metInterestMatrix(:,eleG)) > 1e-6,1)
    fprintf('Biomass contains some generic groups.\n');
end

end
