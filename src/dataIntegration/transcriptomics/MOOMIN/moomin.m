function [model, MILPsolutions, MILPproblem] = moomin(model, expression, varargin)
% MOOMIN (`Pusa et al., 2019`) generates a hypothesis of a metabolic shift using
% a metabolic network and differential expression data. Based on changes in the expression
% of genes, each reaction is given a colour to indicate an increase, a decrease, or no
% change in flux.
%
% USAGE:
%
%    [model, MILPsolutions, MILPproblem] = moomin(model, expression, varargin)
%
% INPUTS:
%    model:             input model (COBRA model structure)
%    expression:        structure with the following fields
%
%                         * .GeneID - vector of gene IDs
%                         * .PPDE - vector of posterior probabilities of differential
%                         expression
%                         * .FC - vector of log fold changes
%
% Optional parameters can be entered the standard MATLAB way with parameter name followed
% by parameter value: i.e. ,'pThresh', 0.9)
%
% OPTIONAL INPUTS:
%    pThresh:           threshold for differential expression (default 0.9)
%    alpha:             alpha parameter of the weight function, a higher value means less
%                       evidence is needed for a change to be inferred (default 3)
%                       0 < alpha < 10, a good range is [0.5, 3]
%    stoichiometry:     Boolean to choose if stoichiometry is considered (default 1)
%    enumerate:         integer to determine the maximum number of alternative optimal
%                       solutions that are enumerated  (default 1 ie only one solution)
%    precision:         integer to determine up to how many significant numbers the
%                       weights are evaluated. Will influence the uniqueness of weight
%                       values. (default 7)
%    solverTimeLimit:	time limit for the MILP solver (default 1000)
%    solverPrintLevel:  print level parameter for the MILP solver (default 0)
%    solverParameters:	struct containing solver parameters to be passed on to
%						solverCobraMILP
%
% OUTPUTS:
%    model:             input model with additional fields containing outputs of the
%                       algorithm. Rows correspond to reactions. The colours are coded by
%                         2 - reverse red (r.red) ie increase, reaction in reverse
%                         1	- red ie increase
%                         0 - grey ie no change
%                         -1 - blue ie decrease
%                         -2 - reverse blue (r.blue) ie decrease, reaction in reverse
%                         6	- yellow ie unspecified change in a reversible reaction
%                       Additional fields are
%
%                         * .inputColours - colours inferred solely based on data
%                         * .outputColours - matrix, colours inferred by the algorithm
%                           columns correspond to alternative optimal solutions
%                         * .weights - the reaction weights used in the algorithm
%                         * .leadingGenes -  the genes "responsible" for the colour and
%                           weight of a reaction
%                         * .frequency - how often a reaction is coloured in a solution
%                         * .combined - an attempted consensus between all optimal
%                           solutions (colour differs between solutions -> 6)
%                         * .PPDE - PPDEs of the model genes. -1 for missing values
%                         * .FC - fold changes of the model genes. 0 for missing values
%    MILPsolutions      raw outputs of 'solveCobraMILP'
%    MILPproblem        the final MILP-problem solved (or was attempted to be solved)
%
% `Pusa et al. (2019). MOOMIN – Mathematical explOration of 'Omics data on a MetabolIc Network.`
%
% .. Author: - Taneli Pusa 01/2020

	pThresh = 0.9;
	alpha = 3;
	beta = 2; % additional parameter used in the weight function
	epsilon = 1;
	useStoichiometry = 1;
	enumerate = 1;
	precision = 7;
    solverParameters = struct;
	
	model.ub(:) = 100;
    model.lb(model.lb~=0) = -100;
	
	if ~isempty(varargin)
		if rem(size(varargin, 2), 2) ~= 0
			error('Check optional inputs.');
		else
			for i = 1:2:size(varargin, 2)
				switch varargin{1, i}
					case 'pThresh'
						pThresh = varargin{1, i+1};
					case 'alpha'
						alpha = varargin{1, i+1};
					case 'stoichiometry'
						useStoichiometry = varargin{1, i+1};
					case 'enumerate'
						enumerate = varargin{1, i+1};
					case 'precision'
						precision = varargin{1, i+1};
					case 'solverTimeLimit'
						solverParameters.timeLimit = varargin{1, i+1};
					case 'solverPrintLevel'
						solverParameters.printLevel = varargin{1, i+1};
					case 'solverParameters'
						solverParameters = varargin{1, i+1};
					otherwise
						error('Could not recognise optional input names.\nNo input named "%s"',...
							varargin{1,i});
				end
			end
		end
    end
	
	% find expression data for the model genes
	[~, indInData, indInModel] = intersect(expression.GeneID, model.genes);
	if numel(indInData) == 0
		warning('It looks like no gene IDs match between the model and the data.');
	end
	PPDE = repmat(-1, numel(model.genes), 1);
	PPDE(indInModel) = expression.PPDE(indInData);
	FC = zeros(numel(model.genes), 1);
	FC(indInModel) = expression.FC(indInData);
	
	% determine colours and weights first for genes
	geneColours = (PPDE > pThresh) .* sign(FC);
	geneWeights = arrayfun(@(x) weightFunction(x, alpha, beta, pThresh), PPDE);
	
	% determine colours and weights for reactions
	nReactions = size(model.rxns, 1);
	reactionColours = zeros(nReactions, 1);
	reactionWeights = zeros(nReactions, 1);
	leadingGenes = zeros(nReactions, 1);
	for reacInd = 1:nReactions
		% get the associated genes as a list
		indAssGenesCell = regexp(model.rules{reacInd, 1},'\d+', 'match');
		indAssGenes = [];
		if ~isempty(indAssGenesCell)
			for i = 1:size(indAssGenesCell, 2)
				indAssGenes = [indAssGenes; str2double(indAssGenesCell{1, i})];
			end
		end
		if isempty(indAssGenes)
			reactionWeights(reacInd) = weightFunction(0, alpha, beta, pThresh);
			leadingGenes(reacInd, 1) = 0;
		else
			assColours = geneColours(indAssGenes);
			assWeights = geneWeights(indAssGenes);
			% a contradiction of colours
			if any(assColours == 1) && any(assColours == -1)
				reactionWeights(reacInd) = weightFunction(0.5, alpha, beta, pThresh);
				leadingGenes(reacInd, 1) = 0;
			else
				reactionColours(reacInd) = sign(sum(assColours));
				[reactionWeights(reacInd), ind] = max(assWeights);
				if reactionColours(reacInd) ~= 0
					leadingGenes(reacInd, 1) = indAssGenes(ind);
				else
					leadingGenes(reacInd, 1) = 0;
				end
			end
		end
	end
	
	model.PPDE = PPDE;
	model.FC = FC;
	model.leadingGenes = leadingGenes;
	reactionWeights = round(reactionWeights, precision, 'significant');
	
	% create the MILP problem
	nMetabs = size(model.S, 1);
	optimum = -sum(abs(reactionWeights));

	% with stoichiometric constraints
	if useStoichiometry
		ub = repmat(max(model.ub), nReactions, 1);
		lb = repmat(-max(model.ub), nReactions, 1);
		% impose a priori colours
		for i = 1:nReactions
			if reactionColours(i) == 1 && model.lb(i) == 0
				lb(i) = 0;
			elseif reactionColours(i) == -1 && model.lb(i) == 0
				ub(i) = 0;
			end
		end
		[i, j, v] = find([model.S; repmat(eye(nReactions), 4, 1)]);
		% stoichiometry
		A = sparse(i, j, v, nMetabs + 4 * nReactions, 3 * nReactions);
		% x+=1 -> v>=epsilon
		A(nMetabs + 1:nMetabs + nReactions, nReactions + 1:2 * nReactions)...
			= diag(lb - epsilon);
		% x+=0 -> v<=0
		A(nMetabs + nReactions + 1:nMetabs + 2 * nReactions,...
			nReactions + 1:2 * nReactions) = diag(-ub);
		% x-=1 -> v<=-epsilon
		A(nMetabs + 2 * nReactions + 1:nMetabs + 3 * nReactions,...
			2 * nReactions + 1:3 * nReactions) = diag(ub + epsilon);
		% x-=0 -> v>=0
		A(nMetabs + 3 * nReactions + 1:nMetabs + 4 * nReactions,...
			2 * nReactions + 1:3 * nReactions) = diag(-lb);
		% place holder for optimality constraint
		A = [A; zeros(1, nReactions), reactionWeights', reactionWeights'];

		csense(1:nMetabs) = 'E';
		csense(nMetabs + 1:nMetabs + nReactions) = 'G';
		csense(nMetabs + nReactions + 1:nMetabs + 2 * nReactions) = 'L';
		csense(nMetabs + 2 * nReactions + 1:nMetabs + 3 * nReactions) = 'L';
		csense(nMetabs + 3 * nReactions + 1:nMetabs + 4 * nReactions) = 'G';
		csense = [csense 'G'];

		c = [zeros(nReactions, 1); reactionWeights; reactionWeights];

		b = [zeros(nMetabs, 1); lb; zeros(nReactions, 1); ub; zeros(nReactions, 1)];
		b = [b; optimum];

		ub = [ub; ones(2 * nReactions, 1)];
		lb = [lb; zeros(2 * nReactions, 1)];

		vartype(1:nReactions) = 'C';
		vartype(nReactions + 1:3 * nReactions) = 'B';
		
	% with only topological constraints
	else
		ub = ones(nMetabs + 2 * nReactions, 1);
		lb = ub - 1;
		% impose a priori colours
		for i = 1:nReactions
			if reactionColours(i) == 1 && model.lb(i) == 0
				ub(nMetabs+nReactions + i, 1) = 0;
			elseif reactionColours(i) == -1 && model.lb(i) == 0
				ub(nMetabs + i) = 0;
			end
		end   

		A = sparse(nReactions + 3 * nMetabs, nMetabs + nReactions * 2);
		% x+ and x- cannot be 1 at the same time
		A(1:nReactions, nMetabs + 1:end) = [eye(nReactions), eye(nReactions)];
		% if a connected arc is included, a node is included
		A(nReactions + 1:nReactions + nMetabs, 1:nMetabs) = -diag(sum(model.S ~= 0, 2));
		A(nReactions + 1:nReactions + nMetabs, nMetabs + 1:end)...
			= [model.S ~= 0, model.S ~= 0];
		% if a node is included, it has to have an outgoing arc
		A(nReactions + nMetabs + 1:nReactions + 2 * nMetabs, 1:nMetabs) = -eye(nMetabs);
		A(nReactions + nMetabs + 1:nReactions + 2 * nMetabs,...
			nMetabs + 1:nMetabs + nReactions) = model.S < 0;
		A(nReactions + nMetabs + 1:nReactions + 2 * nMetabs, nMetabs + nReactions + 1:end)...
			= model.S > 0;
		% if a node is included, it has to have an incoming arc
		A(nReactions + 2 * nMetabs + 1:end, 1:nMetabs) = -eye(nMetabs);
		A(nReactions + 2 * nMetabs + 1:end, nMetabs + 1:nMetabs + nReactions)...
			 = model.S > 0;
		A(nReactions + 2 * nMetabs + 1:end, nMetabs + nReactions + 1:end) = model.S < 0;
		% place holder for optimum
		A = [A; zeros(1, nMetabs), reactionWeights', reactionWeights'];

		csense(1:nReactions) = 'L';
		csense(nReactions + 1:nReactions + nMetabs) = 'L';
		csense(nReactions + nMetabs + 1:nReactions + 2 * nMetabs) = 'G';
		csense(nReactions + 2 * nMetabs + 1:nReactions + 3 * nMetabs) = 'G';
		csense = [csense, 'G'];

		c = [zeros(nMetabs, 1); reactionWeights; reactionWeights];

		b = [ones(nReactions, 1); zeros(3 * nMetabs, 1)];
		b = [b; optimum];

		vartype(1:nMetabs + 2 * nReactions) = 'B';
	end
	
	MILPproblem.A = A;
	MILPproblem.b = b;
	MILPproblem.c = c;
	MILPproblem.lb = lb;
	MILPproblem.ub = ub;
	MILPproblem.csense = csense;
	MILPproblem.vartype = vartype;
	MILPproblem.osense = -1;
	MILPproblem.x0 = [];
	
	% solve the MILP
	cont = 1;
	counter = 1;
	model.outputColours = [];
	MILPsolutions = {};
	% loop to enumerate alternative optima
	while cont
		if useStoichiometry
			solution = solveCobraMILP(MILPproblem, solverParameters);
		else
			solution = solveCobraMILP(MILPproblem, solverParameters);
		end
	
		% write solution into output structure
		if solution.stat == 1
			outputColours = zeros(nReactions, 1);
			if useStoichiometry
				outputColours(solution.int(1:nReactions) > 1e-4) = 1;
				outputColours(solution.int(nReactions + 1:end) > 1e-4) = -1;
			else
				outputColours(solution.int(nMetabs + 1:nMetabs + nReactions) > 1e-4) = 1;
				outputColours(solution.int(nMetabs + nReactions + 1:end) > 1e-4) = -1;
			end
			% impose a priori colours
			for i = 1:nReactions
				if outputColours(i) == 1 && reactionColours(i) == -1
					outputColours(i) = -2;
				elseif outputColours(i) == -1 && reactionColours(i) == 1
					outputColours(i) = 2;
				elseif outputColours(i) ~= 0 && reactionColours(i) == 0 && model.lb(i) < 0
					outputColours(i) = 6;
				end
			end
		elseif counter == 1
			fprintf('\nCould not solve MILP #1. Check solver time limit.\n');
			outputColours = [];
		else
			outputColours = [];
		end
	
		model.outputColours = [model.outputColours outputColours];
		
		MILPsolutions = [MILPsolutions; solution];
		
		cont = solution.stat == 1 && counter < enumerate;
		if counter == 1
			if useStoichiometry
				MILPproblem.b(end, 1) = solution.obj;
			else
				MILPproblem.b(end, 1) = solution.obj;
			end
		end
		% add constraints for enumeration
		previousSol = outputColours ~= 0;
		if cont
			if useStoichiometry
				MILPproblem.A = [MILPproblem.A; zeros(1, nReactions),...
					(2 * previousSol - 1)', (2 * previousSol - 1)'];
			else
				MILPproblem.A = [MILPproblem.A; zeros(1, nMetabs),...
					(2 * previousSol - 1)', (2 * previousSol - 1)'];
			end
			MILPproblem.b = [MILPproblem.b; sum(previousSol) - 1];
			MILPproblem.csense = [MILPproblem.csense, 'L'];
		end
		counter = counter + 1;
	end
	
	model.inputColours = reactionColours;
	model.weights = reactionWeights;
	
	if ~isempty(model.outputColours)
		% count how often a reaction appears in a solution
		model.frequency = sum(model.outputColours ~= 0, 2) / size(model.outputColours, 2);
	
		% combine alternative solutions
		combined = zeros(nReactions, 1);
		for i = 1:nReactions
			row = model.outputColours(i, :);
			if any(row)
				colours = row(find(row));
				if all(colours(1)==colours)
					combined(i,1) = colours(1);
				else
					combined(i,1) = 6;
				end
			end
		end
		model.combined = combined;
	end
    