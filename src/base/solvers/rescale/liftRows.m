function [Clifted, newcon, ctrs_cuprow, ...
    ctrs_new, evars, ndum, cupcon, nEvars] = liftRows(C, cupcon, BIG, logbig, printLevel, ctrs_cuprow, rxns)   
    % Helper for liftCouplingConstraints. Implements the lifting
    %
    % INPUTS:
    %   C           k x n double
    %               Subset of coupling constraints (2-variable rows to be lifted)
    %   cupcon      k x 1 char       
    %               Senses for rows in C (L/G/E)
    %   BIG         double
    %               Threshold for "large" coefficients. TRiggers lifting
    %   logbig      double
    %               log(BIG)
    %   printLevel  double
    %               0 or 1. If 1 prints extra information
    %   ctrs_cuprow k x 1 cell array of chr
    %               IDs of the selected constraints. Correspnds to rows in C
    %   rxns        nRxns x 1 cell array of chr
    %               model rxn IDs
    %
    % OUTPUTS:
    %   Clifted     k' x n' double
    %               Lifted constraint matrix
    %   newcon      ndum x 1 char
    %               Senses of added dummy constraints
    %   ctrs_cuprow k' x 1 cell array of char
    %               Updated IDs for original coupling constraints.
    %   ctrs_new    ndum x 1 cell array of char
    %               IDs for dummy constraints
    %   evars       nEvars x 1 cell array of char
    %               IDs of new dummy variables
    %   ndum        double
    %               Total number of dummy constraints rows added
    %   cupcon      k' x 1 char
    %               Senses for rows in Clifted (L/G/E)
    %   nEvars      double
    %               Total number of dummy variables

    [~,minind] = min(abs(C),[],2);
    [maxval,maxind] = max(abs(C),[],2);
    badrowBool  = maxval>=BIG;
    
    maxval  = maxval(badrowBool);
    maxind  = maxind(badrowBool);
    badrowInd  = find(badrowBool);
    nbadrow = length(badrowInd);
    
    
    if nbadrow==0
        fprintf('%s\n','Model.C is well scaled. Nothing to do.')
        return
    end
    if printLevel > 0
        fprintf([...
            'Replacing %i badly-scaled coupling constraints with sequences of\n'...
            'well-scaled coupling constraints. This may take a few minutes.\n'...
            ],nbadrow)
    end
    
    % Replace badly-scaled coupling constraints with sequences of well-scaled
    % coupling constraints.
    % The loop processes "bad" rows of matrix `C` identified by `badrowInd` and modifies
    % `C` by adding dummy blocks and adjusting certain matrix elements.
    % Dummy variables are introduced to handle large values (`qty`) in `C(i, j)`,
    % and the matrix `C` is expanded accordingly. The `newcon` array stores updated
    % constraints, one for each dummy variable added.
    
    [m,n]  = size(C);  % Get the dimensions of matrix C, with m as the number of rows and n as the number of columns
    ndum   = 0;        % Initialize the variable ndum, which will count the number of dummy variables added
    newcon = [];       % Initialize an empty array newcon, which will store new constraints
    
    debug = 0;
    dummyCounts=zeros(nbadrow,1);
    for k1 = 1:nbadrow  % Loop over all the bad rows (nbadrow) identified in the problem
        i = badrowInd(k1);  % Get the index of the current bad row from badrowInd(k1)
        if printLevel > 0
            stepSize = 1000;
            if mod(i,stepSize)==0
                fprintf('progress: %i ...\n',k1/nbadrow);
            end
        end
        % if i==22550
        %     disp(i)
        % end
        j   = maxind(k1);  % Get the column index corresponding to the maximum value for this row
        qty = maxval(k1);  % Get the maximum value itself for this row
        j2 = minind(k1);  % Get the column index corresponding to the minimum value for this row
    
        sgn = sign(C(i,j));  % Determine the sign of the element C(i,j) (positive or negative)
        dum = max(floor(log(qty)/logbig),1);  % Calculate the number of dummy variables needed based on the log of the max value
        dummyCounts(k1)=dum;
    
        if 0
            stp = 2^ceil(log2(qty)/dum);  % Compute the step size as a power of 2, ensuring equal division by the number of dummies
        else
            stp = nthroot(qty,dum+1);
        end
    
        if debug
            disp(full(C))
        end
        C(i,j)     = 0;            % Set the original element C(i,j) to zero, as it's replaced by the dummy
        if debug
            disp(full(C))
        end
    
        if sgn==-1
            % Create a diagonal block matrix dumblk using sparse diagonal representation.
            % This matrix has 1 on the diagonal and -stp on the superdiagonal, with 'dum' size.
            dumblk = spdiags(sgn*[-ones(dum,1) stp*ones(dum,1)],[0 1],dum,dum);
            if debug
                disp(full(dumblk))
            end
            C      = blkdiag(C,dumblk);  % Add the new diagonal block dumblk to the matrix C, expanding its size
            if debug
                disp(full(C))
            end
    
            C(i,n+1)   = sgn*stp;      % Update the matrix C: Set the element in row i and the new (n+1) column to sgn*stp
            if debug
                disp(full(C))
            end
            C(m+dum,j) = sgn*qty/stp^dum;  % Update C at the new row (m+dum) and column j with the adjusted qty/stp^dum
            if debug
                disp(full(C))
            end
        else
            % Create a diagonal block matrix dumblk using sparse diagonal representation.
            % This matrix has 1 on the diagonal and -stp on the superdiagonal, with 'dum' size.
            dumblk = spdiags([ones(dum,1) -stp*ones(dum,1)],[0 1],dum,dum);
            if debug
                disp(full(dumblk))
            end
            C      = blkdiag(C,dumblk);  % Add the new diagonal block dumblk to the matrix C, expanding its size
            if debug
                disp(full(C))
            end
    
            C(i,n+1)   = -stp;      % Update the matrix C: Set the element in row i and the new (n+1) column to sgn*stp
            if debug
                disp(full(C))
            end
            C(m+dum,j) = sgn*qty/stp^dum;  % Update C at the new row (m+dum) and column j with the adjusted qty/stp^dum
            if debug
                disp(full(C))
            end
        end
    
        if 1
            %double check for remaining large entries in this row
            bool = abs(C(i,:))>BIG;
            if any(bool)
                warning([int2str(nnz(bool)) ' entries in C(i,:) > BIG'])
            end
            %double check for new large entries in this dummy block
            bool = max(abs(C(m+1:m+dum,:)),[],2)>BIG;
            if any(bool)
                warning([int2str(nnz(bool)) ' entries in C(i,:) > BIG'])
            end
        end
    
        [m,n] = size(C);  % Update the dimensions of matrix C after adding the new dummy block
        ndum  = ndum+dum;  % Increment the count of dummy variables by dum
    
        % Append the constraint associated with row i to the new constraints array, repeated 'dum' times
        newcon = [newcon; repmat(cupcon(i),dum,1)];
    end
    Clifted = C;

    % model.evars	evars x 1	Column Cell Array of Strings	IDs of the additional variables
    %model.ctrs ctrs x 1	Column Cell Array of Strings	IDs of the additional Constraints
    nEvars = sum(dummyCounts);
    evars = repmat({'LIFT'},nEvars,1);
    ctrs_new = repmat({'LIFT'},nEvars,1);
    
    ndum=0;
    for k1 = 1:nbadrow
        dum = dummyCounts(k1);
        ctrString   = ctrs_cuprow{badrowInd(k1)}; % Get the index of the current bad row from badrowInd(k1)
        rxnString   = rxns{maxind(k1)};  % Get the column index corresponding to the maximum value for this row
        
        ctrs_new(ndum+1:ndum+dum,1) = append(ctrs_new(ndum+1:ndum+dum,1), arrayfun(@num2str, (1:dum)', 'UniformOutput', false), repmat({['_' ctrString]},dum,1));
        evars(ndum+1:ndum+dum,1)    = append(   evars(ndum+1:ndum+dum,1), arrayfun(@num2str, (1:dum)', 'UniformOutput', false), repmat({['_' rxnString]},dum,1));
    
        ctrs_cuprow{badrowInd(k1)} = ['LIFT0_' ctrs_cuprow{badrowInd(k1)}]; %Annotate the original coupling constraint identifier with dummy0
    
        ndum  = ndum+dum;  % Increment the count of dummy variables by dum
    end
end

