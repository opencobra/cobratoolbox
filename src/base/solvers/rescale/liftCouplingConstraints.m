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
%     equalities          true deals with equalities in constraints (default false)
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
if isfield(model, 'D') && (~(isempty(model.D)))
    model.D_old = model.D;
    model.E_old = model.E;
    model.evarlb_old = model.evarlb;
    model.evarub_old = model.evarub;
    model.evarc_old = model.evarc;
    model.evars_old  = model.evars;
    model.evarNames_old = model.evarNames;
    model.d_old = model.d;
    model.dsense_old = model.dsense;
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
% TO REMOVE?
% hasC = any(abs(A)>0, 2);
% hasD = any(abs(model.D_old)>0, 2);
% hasOneC = sum(abs(A) > 0, 2)==1;
% hasOneD = sum(abs(model.D_old) > 0, 2)==1;

% split constraints with more than 2 variables into combinations of
% constraints with 2 variables 
A1 = A;
b1 = b;
dsense1 = dsense;
ctrs1 = ctrs;
split = (sum(abs(A1)>0, 2)>2) & (any(abs(A1)>BIG, 2)) & (b == 0);
while any(split) % while the are constraints with more than 2 variables that need lifting
    rowsIdx2Split = find(split);
    for ri = rowsIdx2Split
        r = A1(ri, :); % select row to split into other rows, e.g. -v1 -1e6v2 + u2 < 0     
        [~, bigElIdx] = max(abs(r));
        allIdx = find(abs(r)>0); 
        otherIdx = setdiff(allIdx, bigElIdx); % index of all other non-zero elements of that row besides the biggest element 
        other = r(otherIdx);
        A1 = [A1, zeros(size(A1, 1), 1)]; % introduce new variable z, for now empty
        % change original row,
        % for e.g. above, change to -1e6*v2 + z < 0:
        A1(ri, :) = zeros(1, size(A1, 2)); % reset original row
        A1(ri, bigElIdx) = r(bigElIdx); % introduce again the biggest element in original row
        A1(ri, end) = 1; % add z to original row
        % add additional row that defines the replacemnt variable z,
        % in e.g. above z = u2 -v1 <=> z -u2 + v1 = 0:
        A1(end+1, :) = zeros(1, size(A1, 2));
        A1(end, end) = 1;
        A1(end, otherIdx) = -1*other;
        b1 = [b1; 0];
        dsense1 = [dsense1; 'E']; % definition of replacement variable is equality 
        ctrs1 = [ctrs1; {sprintf('%s_split%d', ctrs1{ri}, sum(startsWith(ctrs1, ctrs1{ri})))}];
        split(ri) = 0; % the current row has been split, so it does not need to be split again in next iteration of while loop
        newrow = A1(end, :);
        split(end+1) = (sum(abs(newrow)>0, 2)>2) & (any(abs(newrow)>BIG, 2)) & (b == 0);
    end
   end
A = A1;
b = b1;
dsense = dsense1;
ctrs = ctrs1;


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
    % TO REMOVE?
    % % select coupling constraint with only flux variables - no extra
    % % variables:
    % flxBool = (L|G) & b == 0 & (~hasD);
    % % select coupling constraint rows with exactly 2 flux variables
    % cuprowBool  = (L|G) & b == 0 & boolPairRow & (~hasD); % if a row in C is inequality, rhs is 0 and it has
    %                                                       % exackly two coefficients that are different from 0 cuprowBool is 1
    % % select constraint rows with flux variables and extra variables
    % flxExtrBool = (L|G) & b == 0 & hasD & hasC;
    % % select constraint rows with only extra variables
    % vrbBool = (L|G) & b == 0 & hasD & (~hasC);
    % % select constraint rows with exactly 1 flux variable and 1 extra
    % % variable
    % oneEachflxExtrBool = (L|G) & b == 0 & hasOneC & hasOneD;
end
ncuprowBool = (~cuprowBool);
% TO REMOVE?
% % select other coupling contraints without extra variables: 
% ncuprowBool = (~cuprowBool) & flxBool;
% % select constraints with flux variables and extra variables that were not
% % pre-selected (with more or less than 1 varible each)
% % nSelected = (~oneEachflxExtrBool) & flxExtrBool;

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
[Clifted, dummyCounts, newcon, maxind, maxval, ctrs_cuprow, ...
    ctrs_new, evars, badrowInd, nbadrow, ndum, cupcon, nEvars] = liftRows(C, cupcon, BIG, logbig, printLevel, ctrs_cuprow, rxns);

% %% To REMOVE? _ ITS IN FUNCTION
% [minval,minind] = min(abs(C),[],2); % Added comment: the first min value index
% [maxval,maxind] = max(abs(C),[],2);
% badrowBool  = maxval>=BIG;
% 
% maxval  = maxval(badrowBool);
% maxind  = maxind(badrowBool);
% badrowInd  = find(badrowBool);
% nbadrow = length(badrowInd);
% 
% cupcon  = dsense(cuprowBool);
% 
% if nbadrow==0
%     fprintf('%s\n','Model.C is well scaled. Nothing to do.')
%     return
% end
% if printLevel > 0
%     fprintf([...
%         'Replacing %i badly-scaled coupling constraints with sequences of\n'...
%         'well-scaled coupling constraints. This may take a few minutes.\n'...
%         ],nbadrow)
% end
% 
% % Replace badly-scaled coupling constraints with sequences of well-scaled
% % coupling constraints.
% % The loop processes "bad" rows of matrix `C` identified by `badrowInd` and modifies
% % `C` by adding dummy blocks and adjusting certain matrix elements.
% % Dummy variables are introduced to handle large values (`qty`) in `C(i, j)`,
% % and the matrix `C` is expanded accordingly. The `newcon` array stores updated
% % constraints, one for each dummy variable added.
% 
% [m,n]  = size(C);  % Get the dimensions of matrix C, with m as the number of rows and n as the number of columns
% ndum   = 0;        % Initialize the variable ndum, which will count the number of dummy variables added
% newcon = [];       % Initialize an empty array newcon, which will store new constraints
% 
% debug = 0;
% dummyCounts=zeros(nbadrow,1);
% for k1 = 1:nbadrow  % Loop over all the bad rows (nbadrow) identified in the problem
%     i = badrowInd(k1);  % Get the index of the current bad row from badrowInd(k1)
%     if printLevel > 0
%         stepSize = 1000;
%         if mod(i,stepSize)==0
%             fprintf('progress: %i ...\n',k1/nbadrow);
%         end
%     end
%     % if i==22550
%     %     disp(i)
%     % end
%     j   = maxind(k1);  % Get the column index corresponding to the maximum value for this row
%     qty = maxval(k1);  % Get the maximum value itself for this row
%     j2 = minind(k1);  % Get the column index corresponding to the minimum value for this row
% 
%     sgn = sign(C(i,j));  % Determine the sign of the element C(i,j) (positive or negative)
%     dum = max(floor(log(qty)/logbig),1);  % Calculate the number of dummy variables needed based on the log of the max value
%     dummyCounts(k1)=dum;
% 
%     if 0
%         stp = 2^ceil(log2(qty)/dum);  % Compute the step size as a power of 2, ensuring equal division by the number of dummies
%     else
%         stp = nthroot(qty,dum+1);
%     end
% 
%     if debug
%         disp(full(C))
%     end
%     C(i,j)     = 0;            % Set the original element C(i,j) to zero, as it's replaced by the dummy
%     if debug
%         disp(full(C))
%     end
% 
%     if sgn==-1
%         % Create a diagonal block matrix dumblk using sparse diagonal representation.
%         % This matrix has 1 on the diagonal and -stp on the superdiagonal, with 'dum' size.
%         dumblk = spdiags(sgn*[-ones(dum,1) stp*ones(dum,1)],[0 1],dum,dum);
%         if debug
%             disp(full(dumblk))
%         end
%         C      = blkdiag(C,dumblk);  % Add the new diagonal block dumblk to the matrix C, expanding its size
%         if debug
%             disp(full(C))
%         end
% 
%         C(i,n+1)   = sgn*stp;      % Update the matrix C: Set the element in row i and the new (n+1) column to sgn*stp
%         if debug
%             disp(full(C))
%         end
%         C(m+dum,j) = sgn*qty/stp^dum;  % Update C at the new row (m+dum) and column j with the adjusted qty/stp^dum
%         if debug
%             disp(full(C))
%         end
%     else
%         % Create a diagonal block matrix dumblk using sparse diagonal representation.
%         % This matrix has 1 on the diagonal and -stp on the superdiagonal, with 'dum' size.
%         dumblk = spdiags([ones(dum,1) -stp*ones(dum,1)],[0 1],dum,dum);
%         if debug
%             disp(full(dumblk))
%         end
%         C      = blkdiag(C,dumblk);  % Add the new diagonal block dumblk to the matrix C, expanding its size
%         if debug
%             disp(full(C))
%         end
% 
%         C(i,n+1)   = -stp;      % Update the matrix C: Set the element in row i and the new (n+1) column to sgn*stp
%         if debug
%             disp(full(C))
%         end
%         C(m+dum,j) = sgn*qty/stp^dum;  % Update C at the new row (m+dum) and column j with the adjusted qty/stp^dum
%         if debug
%             disp(full(C))
%         end
%     end
% 
%     if 1
%         %double check for remaining large entries in this row
%         bool = abs(C(i,:))>BIG;
%         if any(bool)
%             warning([int2str(nnz(bool)) ' entries in C(i,:) > BIG'])
%         end
%         %double check for new large entries in this dummy block
%         bool = max(abs(C(m+1:m+dum,:)),[],2)>BIG;
%         if any(bool)
%             warning([int2str(nnz(bool)) ' entries in C(i,:) > BIG'])
%         end
%     end
% 
%     [m,n] = size(C);  % Update the dimensions of matrix C after adding the new dummy block
%     ndum  = ndum+dum;  % Increment the count of dummy variables by dum
% 
%     % Append the constraint associated with row i to the new constraints array, repeated 'dum' times
%     newcon = [newcon; repmat(cupcon(i),dum,1)];
% end
% 
% 
% % model.evars	evars x 1	Column Cell Array of Strings	IDs of the additional variables
% %model.ctrs ctrs x 1	Column Cell Array of Strings	IDs of the additional Constraints
% nEvars = sum(dummyCounts);
% evars = repmat({'LIFT'},nEvars,1);
% ctrs_new = repmat({'LIFT'},nEvars,1);
% 
% ndum=0;
% for k1 = 1:nbadrow
%     dum = dummyCounts(k1);
%     ctrString   = ctrs_cuprow{badrowInd(k1)}; % Get the index of the current bad row from badrowInd(k1)
%     rxnString   = model.rxns{maxind(k1)};  % Get the column index corresponding to the maximum value for this row
% 
%     ctrs_new(ndum+1:ndum+dum,1) = append(ctrs_new(ndum+1:ndum+dum,1), arrayfun(@num2str, (1:dum)', 'UniformOutput', false), repmat({['_' ctrString]},dum,1));
%     evars(ndum+1:ndum+dum,1)    = append(   evars(ndum+1:ndum+dum,1), arrayfun(@num2str, (1:dum)', 'UniformOutput', false), repmat({['_' rxnString]},dum,1));
% 
%     ctrs_cuprow{badrowInd(k1)} = ['LIFT0_' ctrs_cuprow{badrowInd(k1)}]; %Annotate the original coupling constraint identifier with dummy0
% 
%     ndum  = ndum+dum;  % Increment the count of dummy variables by dum
% end
% %% END COPY HERE

model.C      = [[A(ncuprowBool,:) sparse(nnz(ncuprowBool),ndum)]; Clifted];
model.D      = model.C(:,size(model.C_old,2)+1:end);
model.C(:,size(model.C_old,2)+1:end) = [];
model.d      = [b(ncuprowBool); b(cuprowBool) ; zeros(ndum,1)];
model.dsense = [dsense(ncuprowBool); cupcon; newcon];
model.ctrs   = [ctrs(ncuprowBool); ctrs_cuprow; ctrs_new];


% Add additional variables and constraints to model
% model.E	m x evars	Sparse or Full Matrix of Double	Matrix of additional, non metabolic variables (e.g. Enzyme capacity variables)
if isfield(model, 'D_old') && (~isempty(model.D_old))
    model.E      = sparse(size(model.S,1), size(model.D, 2));
    model.evarlb = [model.evarlb_old; -Inf(nEvars,1)];
    model.evarub =  [model.evarub_old; Inf(nEvars,1)];
    model.evarc = [model.evarc_old; zeros(nEvars,1)];
    model.evars  = [model.evars_old; evars];
else
    model.E      = sparse(size(model.S,1), nEvars);
    % model.evarlb	evars x 1	Column Vector of Doubles	Lower bounds of the additional variables
    model.evarlb = -Inf(nEvars,1);
    % model.evarub	evars x 1	Column Vector of Doubles	Upper bounds of the additional variables
    model.evarub =  Inf(nEvars,1);
    % model.evarc	evars x 1	Column Vector of Doubles	Objective coefficient of the additional variables
    model.evarc = zeros(nEvars,1);
    % model.evars	evars x 1	Column Cell Array of Strings	IDs of the additional variables
    model.evars  = evars;
end
% model.evarNames	evars x 1	Column Cell Array of Strings	Names of the additional variables
model.evarNames = model.evars;

model.modelID = [modelID '_liftedCouplingConstraints'];


% TO REMOVE
% %% lift constraint rows with flux variables and extra variables
% % NEW PART START
% A = [model.C_old model.D_old];
% C = A(oneEachflxExtrBool, :); % select constraints with exactly 1 flux variable and 1 extra variable
% ctrs_selected = ctrs(oneEachflxExtrBool);
% 
% rxns = model.rxns;
% [Clifted, dummyCounts, newcon, maxind, maxval, ctrs_cuprow, ...
%     ctrs_new, evars, badrowInd, nbadrow, ndum, cupcon, nEvars] = liftRows(C, dsense, BIG, logbig, printLevel, oneEachflxExtrBool, ctrs_selected, rxns);
% 
% C = [[A(nSelected,:) sparse(nnz(nSelected),ndum)]; Clifted];
% D = C(:,size(model.C_old,2)+1:end);
% C(:,size(model.C_old,2)+1:end) = [];
% d      = [b(nSelected); b(oneEachflxExtrBool) ; zeros(ndum,1)];
% dsense = [dsense(nSelected); cupcon; newcon];
% ctrs   = [ctrs(nSelected); ctrs_cuprow; ctrs_new];
% 
% full(Clifted)
% 
% 
% % Add additional variables and constraints to model
% % model.E	m x evars	Sparse or Full Matrix of Double	Matrix of additional, non metabolic variables (e.g. Enzyme capacity variables)
% E      = sparse(size(model.S,1), nEvars);
% % model.evarlb	evars x 1	Column Vector of Doubles	Lower bounds of the additional variables
% evarlb = -Inf(nEvars,1);
% % model.evarub	evars x 1	Column Vector of Doubles	Upper bounds of the additional variables
% evarub =  Inf(nEvars,1);
% % model.evarc	evars x 1	Column Vector of Doubles	Objective coefficient of the additional variables
% evarc = zeros(nEvars,1);
% % model.evars	evars x 1	Column Cell Array of Strings	IDs of the additional variables
% evars  = evars;
% % model.evarNames	evars x 1	Column Cell Array of Strings	Names of the additional variables
% evarNames = evars;
% 
% 
% % TO REMOVE
% % [m, n] = size(C);
% % ndum   = 0;        % Initialize the variable ndum, which will count the number of dummy variables added
% % newcon = [];       % Initialize an empty array newcon, which will store new constraints
% % 
% % bigger = abs(C) >= BIG; % logical matrix. true when norm of entry bigger than big
% % badrowBoolFlxVrb = any(bigger); % logical. true when row has at least 1 entry for lifting
% % badrowIndFlxVrb = find(badrowBoolFlxVrb);
% % nbadrowFlxVrb = numel(badrowIndFlxVrb);  
% 
% 
% % TO REMOVE
% % for k1 = 1:nbadrowFlxVrb  % Loop over all the bad rows identified in the problem
% %     i = badrowIndFlxVrb(k1);  % Get the index of the current bad row
% %     badEntryInd = find(bigger(i)); % For the current bad row, get the indices of bad entries (with absolute value > BIG)
% %     nbadEntry = numel(badEntryInd); % Number of columns with entry above BIG for the current bad row
% %     for k2 = 1:nbadEntry
% %         j = badEntryInd(k2);
% %         qty = C(i, j); % for current bad row select one bad entry/element
% %         qtyAbs = abs(qty);
% %         sgn = sign(qty); % sign of bd element
% %         dum = max(floor(log(qtyAbs)/logbig),1);  % Calculate the number of dummy variables needed based on the log of the max value
% %        if 0
% %             stp = 2^ceil(log2(qtyAbs)/dum);  % Compute the step size as a power of 2, ensuring equal division by the number of dummies
% %        else
% %             stp = nthroot(qtyAbs,dum+1);
% %        end
% %        C(i,j) = 0;            % Set the original element C(i,j) to zero, as it's replaced by the dummy
% %        if sgn==-1
% %             % Create a diagonal block matrix dumblk using sparse diagonal representation.
% %             % This matrix has 1 on the diagonal and -stp on the superdiagonal, with 'dum' size.
% %             dumblk = spdiags(sgn*[-ones(dum,1) stp*ones(dum,1)],[0 1],dum,dum);
% %             C      = blkdiag(C,dumblk);  % Add the new diagonal block dumblk to the matrix C, expanding its size       
% %             C(i,n+1)   = sgn*stp;      % Update the matrix C: Set the element in row i and the new (n+1) column to sgn*stp
% %             C(m+dum,j) = sgn*qtyAbs/stp^dum;  % Update C at the new row (m+dum) and column j with the adjusted qty/stp^dum
% %         else
% %             % Create a diagonal block matrix dumblk using sparse diagonal representation.
% %             % This matrix has 1 on the diagonal and -stp on the superdiagonal, with 'dum' size.
% %             dumblk = spdiags([ones(dum,1) -stp*ones(dum,1)],[0 1],dum,dum);
% %             C      = blkdiag(C,dumblk);  % Add the new diagonal block dumblk to the matrix C, expanding its size
% %             C(i,n+1)   = -stp;      % Update the matrix C: Set the element in row i and the new (n+1) column to sgn*stp
% %             C(m+dum,j) = sgn*qtyAbs/stp^dum;  % Update C at the new row (m+dum) and column j with the adjusted qty/stp^dum
% %         end
% %             full(C)
% %             [m,n] = size(C);  % Update the dimensions of matrix C after adding the new dummy block
% %             ndum  = ndum+dum;  % Increment the count of dummy variables by dum
% % 
% %     end
% % end
% 
% 
% 
% 
%     % NEW PART END

% remove 'old' fields
nms = fieldnames(model);
oldFds = nms(endsWith(nms, '_old'));
rmfield(model, oldFds);


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
