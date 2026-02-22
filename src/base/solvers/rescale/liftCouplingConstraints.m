function [model] = liftCouplingConstraints(model, BIG, printLevel, equalities)
% Reformulates badly-scaled coupling constraints C*v <=> d
% by lifting them to a better scaled problem in a higher dimension by
% introducing dummy variables.
%
% Assumes `C` does not contain very small entries and transforms constraints
% containing very large entries (entries larger than BIG).
%  
% 
%
% Reformulation techniques are described in detail in:
% Sun, Y., Fleming, R. M., Thiele, I., & Saunders, M. A. (2013). Robust flux balance analysis of multiscale biochemical reaction networks. BMC Bioinformatics, 14(1). https://doi.org/10.1186/1471-2105-14-240
% See also tutorial here:
% https://opencobra.github.io/cobratoolbox/stable/tutorials/tutorial_numCharactWBM.html
%
% USAGE:
%
%    [LPproblem] = reformulate(model, BIG, printLevel)
%
% INPUTS:
%    model: 
%                         * C - `k x n` Left hand side of C*v <= d
%                         * d - `k x 1` Right hand side of C*v <= d
%                         * ctrs `k x 1` Cell Array of Strings giving IDs of the coupling constraints
%                         * dsense - `k x 1` character array with entries in {L,E,G}
%
% OPTIONAL INPUTS
%    'BIG'                Value consided a large coefficient. BIG should be set between 1000 and 10000 on double precision machines.
%    `printLevel`         1 or 0 enables/diables printing respectively.
%     equalities          true means also deals with original constraints containing equalities (default false - only deals with original constraints that are inequalities)
%
% OUTPUTS:
%    model: 
%                         * E	            m x evars	Sparse or Full Matrix of Double	Matrix of additional, non metabolic variables (e.g. Enzyme capacity variables)
%                         * evarlb	    evars x 1	    Column Vector of Doubles	Lower bounds of the additional variables
%                         * evarub	    evars x 1	    Column Vector of Doubles	Upper bounds of the additional variables
%                         * evarc	    evars x 1	    Column Vector of Doubles	Objective coefficient of the additional variables
%                         * evars	    evars x 1	    Column Cell Array of Strings	IDs of the additional variables
%                         * evarNames	evars x 1	    Column Cell Array of Strings	Names of the additional variables
%                         * C	         ctrs x n	    Sparse or Full Matrix of Double	Matrix of additional Constraints (e.g. Coupling Constraints)
%                         * ctrs	     ctrs x 1	    Column Cell Array of Strings	IDs of the additional Constraints
%                         * ctrNames	 ctrs x 1	    Column Cell Array of Strings	Names of the of the additional Constraints
%                         * d	         ctrs x 1	    Column Vector of Doubles	Right hand side values of the additional Constraints
%                         * dsense	     ctrs x 1	    Column Vector of Chars	Senses of the additional Constraints
%                         * D	        ctrs x evars	Sparse or Full Matrix of Double	Matrix to store elements that contain interactions between additional Constraints and additional Variables.
%   
%    The linear optimisation problem derived from this model is then of the form
%                          [S, E; C, D]*x  {L,E,G}  [b;d]       
%
% .. Authors:
%       - Michael Saunders, saunders@stanford.edu
%       - Yuekai Sun, yuekai@stanford.edu, Systems Optimization Lab (SOL), Stanford University
%       - Ronan Fleming, extended to expand metadata
%       - Tânia Barata, extended to handle with pre-existing D and E and to split
%       complex constraints into simpler ones
% ..
%    VERSION HISTORY:
%      0.1.0
%      0.1.1  Optimized code for large sparse S and C matrices.
%      0.1.2  Committed Prof. Saunders' suggestions and optimizations.
%      0.2.0  Implemented new method that for transforming badly-scaled S matrices
%             that yields smaller programs.
%      0.2.1  c = maxval(k1) was overwriting vector c. Changed to qty = maxval(k1).
%      0.3    Oct 1st Tailored to WBMs - Ronan Fleming

% Cite 
% Sun, Y., Fleming, R.M., Thiele, I., Saunders, M. Robust flux balance analysis of multiscale biochemical reaction networks. 
% BMC Bioinformatics 14, 240 (2013). https://doi.org/10.1186/1471-2105-14-240
% https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-14-240


if ~exist('BIG','var')
    BIG=1000;
end
logbig  = log(BIG);

if ~exist('printLevel','var')
    printLevel=1;
end

if ~exist('equalities', 'var') || isempty(equalities)
    equalities = false;
end

bool_sIEC_biomass_reactionIEC01b_trtr = strcmp(model.rxns,'sIEC_biomass_reactionIEC01b_trtr');
% the following homogeneization step is only required for WBM whose biomass
% reaction is 'sIEC_biomass_reactionIEC01b_trtr'. For that model,
% coupling constraints with single-entry were removed and those with
% 3-entry were replaced by a par of two entries:
if any(bool_sIEC_biomass_reactionIEC01b_trtr)
    boolSingleRow = sum(abs(model.C)>0,2)==1;
    boolTripleRow = sum(abs(model.C)>0,2)==3;
    boolBlankRow = sum(abs(model.C)>0,2)==0;
    if any(boolSingleRow) || any(boolTripleRow) || any(boolBlankRow)
        if printLevel > 0
            fprintf('%s\n')
            fprintf('%d %s\n',nnz(boolSingleRow), ' = # rows C(i,:)  with one entry')
            fprintf('%d %s\n',nnz(boolTripleRow), ' = # rows C(i,:)  with three entries')
            fprintf('%s\n','Removing any coupling constraints with single')
            fprintf('%s\n','Replacing any triple-entry coupling constraints with two double entries')
        end
        model = homogeniseCouplingConstraints(model);
        if printLevel > 0
            fprintf('%s\n')
        end
    end
end

%save the old versions
model.C_old = model.C;
model.d_old = model.d;
model.ctrs_old = model.ctrs;
model.dsense_old = model.dsense;
if isfield(model, 'D') && (~(isempty(model.D)))
    model.D_old = model.D;
    model.E_old = model.E;
    model.evarlb_old = model.evarlb;
    model.evarub_old = model.evarub;
    model.evarc_old = model.evarc;
    model.evars_old  = model.evars;
    model.evarNames_old = model.evarNames;
end

if isfield(model, 'D') && (~isempty(model.D))
    A = [model.C model.D];
else
    A = model.C;
end
b      = model.d;
dsense = char(model.dsense);
ctrs = model.ctrs;

if isfield(model,'modelID')
    modelID=[model.modelID '_lifted'];
else
    modelID='aLiftedModel';
end

% split constraints with more than 2 variables into combinations of
% constraints with 2 variables 
if ~isfield(model, 'evars')
    model.evars = {};
    model.evarlb = [];
    model.evarub = [];
    model.evarc = [];
end

evars = model.evars;
evarlb = model.evarlb;
evarub = model.evarub;
evarc = model.evarc;

if equalities
    split = (sum(abs(A)>0, 2)>2) & (any(abs(A)>=BIG, 2)) & (b == 0);
else
    split = (sum(abs(A)>0, 2)>2) & (any(abs(A)>=BIG, 2)) & (b == 0) & (dsense == 'L' | dsense == 'G');
end

while any(split) % while the are constraints with more than 2 variables that need lifting
    rowsIdx2Split = find(split);
    for ri = rowsIdx2Split
        r = A(ri, :); % select row to split into other rows, e.g. -v1 -1e6v2 + u2 < 0     
        [~, bigElIdx] = max(abs(r));
        allIdx = find(abs(r)>0); 
        otherIdx = setdiff(allIdx, bigElIdx); % index of all other non-zero elements of that row besides the biggest element 
        other = r(otherIdx);
        A = [A, zeros(size(A, 1), 1)]; % introduce new variable z, for now empty
        evars = [evars; {sprintf('z_%d', sum(startsWith(evars, 'z_')) + 1)}];
        evarlb = [evarlb; -Inf];
        evarub = [evarub; Inf];
        evarc = [evarc; 0];
        % change original row,
        % for e.g. above, change to -1e6*v2 + z < 0:
        A(ri, :) = zeros(1, size(A, 2)); % reset original row
        A(ri, bigElIdx) = r(bigElIdx); % introduce again the biggest element in original row
        A(ri, end) = 1; % add z to original row
        % add additional row that defines the replacemnt variable z,
        % in e.g. above z = u2 -v1 <=> z -u2 + v1 = 0:
        A(end+1, :) = zeros(1, size(A, 2));
        A(end, end) = 1;
        A(end, otherIdx) = -1*other;
        b = [b; 0];
        dsense = [dsense; 'E']; % definition of replacement variable is equality 
        ctrs = [ctrs; {sprintf('%s_split%d', ctrs{ri}, sum(startsWith(ctrs, ctrs{ri})))}];
        split(ri) = false; % the current row has been split, so it does not need to be split again in next iteration of while loop
        newrow = A(end, :);
        if equalities
            split(end+1) = (sum(abs(newrow)>0, 2)>2) & (any(abs(newrow)>=BIG, 2)) & (b(end) == 0); 
        else
            split(end+1) = (sum(abs(newrow)>0, 2)>2) & (any(abs(newrow)>=BIG, 2)) & (b(end) == 0) & (dsense(end)~='E');
        end
    end
end

model.evars_preLift = evars; % extra variables from splitting are joined to group of original extra variables to not break code bellow where new evars are considered only the ones created from lifting
model.evarNames_preLift = evars;
model.evarlb_preLift = evarlb;
model.evarub_preLift = evarub;
model.evarc_preLift = evarc;

[m,n]  = size(A);  % Get the dimensions of matrix A, with m as the number of rows and n as the number of columns
% find badly scaled coupling constraints
L       = dsense=='L';
G       = dsense=='G';
E       = dsense=='E';
if ~equalities && any(E) % if equalities true equalities are processed
        error(['equality dsense at ' int2str(nnz(E)) ' positions'])
end

boolSingleRow = sum(abs(A)>0,2)==1;
boolPairRow = sum(abs(A)>0,2)==2;
boolTripleRow = sum(abs(A)>0,2)==3;
boolMultipleRow = sum(abs(A)>0,2)>3;
signA = sign(A);
boolOppositeSignsRow = sum(signA,2)==0;
boolPositiveSignsRow = sum(signA,2)==2;

%detect the coupling constraint rows
if 0
    if equalities
        cuprowBool  = (L|G|E) & b == 0 & boolPairRow & boolOppositeSignsRow;
    else
        cuprowBool  = (L|G) & b == 0 & boolPairRow & boolOppositeSignsRow;
    end
else
    if equalities
        cuprowBool  = (L|G|E) & b == 0 & boolPairRow;
    else
        cuprowBool  = (L|G) & b == 0 & boolPairRow;
    end
end
ncuprowBool = (~cuprowBool);

%% Lift coupling constraint rows with exactly 2 variables
if printLevel > 0
    fprintf('\n')
    fprintf('%d %s\n',n, ' = # cols model.C')
    fprintf('%d %s\n',m, ' = # rows model.C')
    fprintf('%d %s\n',nnz(L), ' = # rows C(i,:)*v < d(i)')
    fprintf('%d %s\n',nnz(G), ' = # rows C(i,:)*v > d(i)')
    fprintf('%d %s\n',nnz(E), ' = # rows C(i,:)*v = d(i)')
    fprintf('%d %s\n',m - nnz(L) - nnz(G), ' = # rows minus # rows C(i,:) < d(i) minus # rows C(i,:) > d(i)')
    fprintf('%d %s\n',nnz(boolPairRow), ' = # rows C(i,:)  with two entries')
    fprintf('%d %s\n',nnz(boolSingleRow), ' = # rows C(i,:)  with one entry')
    fprintf('%d %s\n',nnz(boolTripleRow), ' = # rows C(i,:)  with three entries')
    fprintf('%d %s\n',nnz(boolMultipleRow), ' = # rows C(i,:)  with more than three entries')
    fprintf('%d %s\n',m - nnz(boolPairRow), ' = # rows C(i,:)  without two entries')
    fprintf('%d %s\n',m - nnz(boolPairRow) - nnz(boolSingleRow) -nnz(boolTripleRow) , ' = # rows C(i,:)  without 1,2, or 3 entries')
    fprintf('%d %s\n',nnz(boolOppositeSignsRow), ' = # rows C(i,:)  with both entries having opposite signs')
    fprintf('%d %s\n',nnz(boolPositiveSignsRow), ' = # rows C(i,:)  with both entries having positive signs')
    fprintf('%d %s\n',m - nnz(boolPairRow & (boolOppositeSignsRow | boolPositiveSignsRow)), ' = # rows C(i,:)  without two entries of any signs')
    fprintf('\n')
end

C       = A(cuprowBool,:);
ctrs_cuprow = ctrs(cuprowBool);
cupcon  = dsense(cuprowBool);

rxns = model.rxns;
[Clifted, newcon, ctrs_cuprow, ...
    ctrs_new, evars, ndum, cupcon, nEvars] = liftRows(C, cupcon, BIG, logbig, printLevel, ctrs_cuprow, rxns);

model.C      = [[A(ncuprowBool,:) sparse(nnz(ncuprowBool),ndum)]; Clifted];
model.D      = model.C(:,size(model.C_old,2)+1:end);
model.C(:,size(model.C_old,2)+1:end) = [];
model.d      = [b(ncuprowBool); b(cuprowBool) ; zeros(ndum,1)];
model.dsense = [dsense(ncuprowBool); cupcon; newcon];
model.ctrs   = [ctrs(ncuprowBool); ctrs_cuprow; ctrs_new];

% Add additional variables and constraints to model
% model.E	m x evars	Sparse or Full Matrix of Double	Matrix of additional, non metabolic variables (e.g. Enzyme capacity variables)
model.E      = sparse(size(model.S,1), size(model.D, 2));
% model.evarlb	evars x 1	Column Vector of Doubles	Lower bounds of the additional variables
model.evarlb = [model.evarlb_preLift; -Inf(nEvars,1)];
% model.evarub	evars x 1	Column Vector of Doubles	Upper bounds of the additional variables
model.evarub =  [model.evarub_preLift; Inf(nEvars,1)];
% model.evarc = zeros(nEvars,1);
model.evarc = [model.evarc_preLift; zeros(nEvars,1)];
% model.evars	evars x 1	Column Cell Array of Strings	IDs of the additional variables
model.evars  = [model.evars_preLift; evars];
model.evarNames = model.evars;

model.modelID = [modelID '_liftedCouplingConstraints'];

% remove 'old' fields
nms = fieldnames(model);
oldFds = nms(endsWith(nms, '_old'));
model = rmfield(model, oldFds);


%% TODO - find the code that fixes this in the WBM
if isfield(model,'subSystems')
    ind = find(~cellfun(@(y) ischar(y) , model.subSystems));
    if ~isempty(ind)
        for i=1:length(ind)
            tmp = model.subSystems{ind(i)};
            model.subSystems{ind(i)} = tmp{1};
        end
    end
end

try
    if 0
        %subsystems interference
        %                   * 'simpleCheck' returns false if this is not a valid model and true if it is a valid model, ignored if any other option is selected. (Default: false)
        results = verifyModel(model,'simpleCheck', true);
        assert(results.simpleCheck)
    else
        if isfield(model,'S')
            A = [model.S, model.E;model.C, model.D];
            assert((length(model.rxns)+length(model.evars))==(size(model.C,2)+size(model.D,2)))
        end
    end
catch
    error('lifting of whole body model did not proceed correctly')
end

end

%%
