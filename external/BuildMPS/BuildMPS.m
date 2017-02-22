function [Contain]=BuildMPS(A, b, Aeq, beq, cost, L, U, PbName, varargin)
%
% function Contain=BuildMPS(A, b, Aeq, beq, cost, L, U, PbName); OR
%          Contain=BuildMPS(..., Param1, Value1, ...);
%
% Build ascii fixed-width MPS matrix string that contains linear
% programming (LP) problem:
%
% Minimizing (for x in R^n): f(x) = cost'*x, subject to
%       A*x <= b        (LE)
%       Aeq*x = beq     (EQ)
%       L <= x <= U     (BD).
%
% Also supported is integer/mixte programming problem similar to the above,
% where a subset of components of x is restricted to be integer (N set) or
% binary set {0,1}.
%
% INPUTS:
%   A: (m x n) matrix
%   b: (m x 1) matrix
%   Aeq: (k x n) matrix
%   beq: (k x 1) matrix
%   cost: (n x 1) matrix
%   L: (1 x n), (n x 1) or (1 x 1)
%   U: (1 x n), (n x 1) or (1 x 1)
%
% Remark: To disable constraint(s) (LE, EQ, BD), please use empty []
%         for corresponding input matrix/rhs parameters.
%
% Optional:
%   - PbName is a string of problem name, default value is 'GENERIC'.
% Other Params:
%    'EleNames', 'EqtNames', or 'VarNames'
%     Cells contain string of respectively
%        (LE) equations, (EQ) equations, or variable names
%   - 'EleNameFun', 'EqtNameFun', or 'VarNameFun'
%     Corresponding Value are function handles that return
%     Equation/Variable name from equation/Variable number
%       Example: > VarNameFun=@(m) char('x'+(m-1));
%     These functions will NOT be used if names of equations/variables
%     are defined.
%   - Param is 'MPSfilename': output MPS file to be saved
%     No saving if MPSfilename is undefined.
%   - 'I', 'Int', 'Integer', 'Integers'
%       Array that stores the indexes that defines the set of integer
%       variables (>=0). The indexes must belong to [1,..., n] and
%       correspond to the column of A, Aeq.
%   - 'B', 'Bin', 'Binary', 'Binaries'
%       Array that stores the index that defines the set of binary
%       variables {0,1}. Indexes follow the same convention as with integer
%       case.
%   - 'QUAD', 'Q': a structure with following fields
%         'Q': (n x n) matrix
%            The lower triangle of Q is assumed to be the transpose of the
%            upper triangle (in other word, Q must be symmetric and we use
%            only the upper part).
%         'g': (n x 1) vector
%         'bquad': scalar
%         'name' (optional): string, name of the constraint.
%                if qs.name is 'COST' then the quadratic term in the
%                cost function to be minimized (see below)
%         'type' (optional): must contains the string 'QLE'
%                (This field is reserved for future for extension of BuildMPS)
%
%      QUAD parameters is used to enforce an additional quadratic
%      constraint on the unknown x of the type:
%           0.5*x'*Q*x + g'*x <= bquad        (QLE)
%
%      Provide as many QUAD parameters as the number of constraints to be
%      meet.
%      Spatial case: if name is 'COST' then it corresponds to a quadratic
%      term of the cost function
%           f(x) = cost'*x + 0.5*x'*Q*x
%      For this case, the 'g' and 'bquad' fields will be ignored.
%
% OUTPUT:
%   Contain: char matrix of the MPS format description of LP/IP problem.
%
% RESTRICTION:
%   Only single column rhs (b and beq) is supported.
%
% The MPS (Mathematical Programming System) file format was introduced by
% IBM in 1970s, but has also been accepted by most subsequent linear
% programming codes. To learn about MPS format, please see:
%   http://lpsolve.sourceforge.net/5.5/mps-format.htm
%
% See also: SaveMPS
%
% Usage example:
%
%     A = [1 1 0; -1 0 -1];
%     b = [5; -10];
%     L = [0; -1; 0];
%     U = [4; +1; +inf];
%     Aeq = [0 -1 1];
%     beq = 7;
%     cost = [1 4 9];
%     VarNameFun = @(m) (char('x'+(m-1))); % returning varname 'x', 'y' 'z'
% 
%     Qle = [2 1 0;
%          1 2 0;
%          0 0 1];
%     g = [0; 0; -3];
%     bquad = 100;
%     quad_le = struct('Q', Qle, ...
%                      'g', g, ...
%                      'bquad', bquad);
% 
%     Qcost = speye(3);
%     quad_cost = struct('Q', Qcost, ...
%                        'name', 'cost'), 
%     Contain = BuildMPS(A, b, Aeq, beq, cost, L, U, 'Pbtest', ...
%                        'VarNameFun', VarNameFun, ...
%                        'EqtNames', {'Equality'}, ...
%                        'Q', quad_le, 'Q', quad_cost, ...
%                        'Integer', [1], ... % first variable 'x' integer
%                        'MPSfilename', 'Pbtest.mps');
%
% Author: Bruno Luong
% update: 15-Jul-2008: sligly improved number formatting
%         25-Aug-2009: Improvement in handling sparse matrix
%         03-Sep-2009: integer/binary variables
%         02-May-2010: quadratic term

if nargin<8 || isempty(PbName)
    PbName='GENERIC';
end

%
% Columns indices of MPS fields
%
idx1=02:03;
idx2=05:12;
idx3=15:22;
idx4=25:36;
idx5=40:47;
idx6=50:61;
idxlist={idx1 idx2 idx3 idx4 idx5 idx6};

%
% Default returned value if error occurs
%
Contain=[]; %#ok
OK = 0;  %#ok

%
% Get the size of the input matrices
%
[neq nvar]=size(Aeq);
[nle sizeA2]=size(A);

if neq==0 % Aeq is empty, i.e., no equality constraint
    nvar=sizeA2;
    Aeq=zeros(0,nvar);
elseif nle==0 % A is empty, i.e., no LE constraint
    sizeA2=nvar;
    A=zeros(0,nvar);
end

%
% Default values for naming functions (nested functions)
%
elenamefun = @elename;
eqtnamefun = @eqtname;
varnamefun = @varname;
MPSfilename = ''; % MPSfilename

% default empty integer and binary sets
iset = [];
bset = [];

%
% Parse options (varargin)
%
parseoptions(varargin{:});

% Number of quadratic constraints
nquadle = length(quadle);

if ~exist('elenames','var')
    elenames=arrayfun(elenamefun, (1:nle), 'UniformOutput', false);
end
if ~exist('eqtnames','var')
    eqtnames=arrayfun(eqtnamefun, (1:neq), 'UniformOutput', false);
end
if ~exist('varnames','var')
    varnames=arrayfun(varnamefun, (1:nvar), 'UniformOutput', false);
end

if nargin<6 || isempty(L)
    L=-inf(1,nvar);
elseif isscalar(L) % extend L if it's a scalar input
    Lval=L;
    L=zeros(1,nvar);
    L(:)=Lval;
else % BUG corrected, reshape L in row
    L = reshape(L,1,[]);
end
if nargin<7 || isempty(U)
    U=+inf(1,nvar);
elseif isscalar(U) % extend U if it's a scalar input
    Uval=U;
    U=zeros(1,nvar);
    U(:)=Uval;
else % BUG corrected, reshape U in row
    U = reshape(U,1,[]);
end

%
% Dimension check
%
if length(beq)~=neq || length(b)~=nle || ...
   length(cost)~=nvar || ...
   length(L)~=nvar || length(U)~=nvar || ...
   sizeA2~=nvar
    error('BuildMPS:DimensionsUnMatched', ...
          'BuildMPS: dimensions do not match');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set problem name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
l_name=setfields([],0,'NAME');
l_name=setfields(l_name,3,PbName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set equations in ROWS and COST
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
l_rows=setfields([],0,'ROWS');

l_cost=setfields([],1,'N',2,'COST');

l_rows_eq=emptyline(neq);
for m=1:neq
    l_rows_eq(m,:)=setfields(l_rows_eq(m,:),1,'E',2,eqtnames{m});
end

l_rows_le=emptyline(nle+nquadle);
for m=1:nle
    l_rows_le(m,:)=setfields(l_rows_le(m,:),1,'L',2,elenames{m});
end
for m=1:nquadle
    l_rows_le(nle+m,:)=setfields(l_rows_le(nle+m,:),1,'L',2,quadle(m).name);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set coefficients of constraint equations in COLUMNS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Put all the linear constraint terms of quadratic in a matrix
quadle_g = cat(2,quadle(:).g).'; % (nquadle x nvar)
CostAeq = [cost(:).'; 
           Aeq;
           A;
           quadle_g]; % CostAeq is sparse if any is sparse
MustWrite = (CostAeq ~= 0);
NWrite = sum(MustWrite,1);
NLines = sum(ceil(NWrite/2));

l_columns=setfields([],0,'COLUMNS');
l_columnsbody=emptyline(NLines);

c=0;
for n=1:nvar % Loop over variables
    var=varnames{n};
    field=3;
    eqtn = find(MustWrite(:,n)); % subset of (1:1+neq+nle+nquadle)
    for m=eqtn(:).' % 1:1+neq+nle+nquadle % Loop over eqt
        if m==1
            colname='COST';
            val = cost(n);
        elseif m<=1+neq
            colname=eqtnames{m-1};
            val=Aeq(m-1,n);
        elseif m<=1+neq+nle
            colname=elenames{m-(1+neq)};
            val=A(m-(1+neq),n);
        else
            iquad = m-(1+neq+nle);
            colname=quadle(iquad).name;
            val=quadle_g(iquad,n);            
        end
        if field==3
            c=c+1;
            l_columnsbody(c,:)=setfields(l_columnsbody(c,:),...
                2,var,...
                field,colname, ...
                field+1,val);
            field=5;
        else % field==5
            l_columnsbody(c,:)=setfields(l_columnsbody(c,:),...
                field,colname, ...
                field+1,val);
            field=3;
        end
    end % for-loop eqt
end % for-loop variables
l_columnsbody(c+1:end,:)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set equation RHS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
quadle_bquad = [quadle(:).bquad]; % (1 x nquadle)

rhs=[beq(:); b(:); quadle_bquad(:)];
MustWrite = (rhs ~= 0);
NWrite = sum(MustWrite);
NLines = ceil(NWrite/2);

l_rhs=setfields([],0,'RHS');
l_rhsbody=emptyline(NLines);
c=0;
field=3;
eqt = find(MustWrite); % subset of (1:neq+nle)
for m=eqt(:).' % 1:neq+nle+nquadle % Loop over eqt
    if m<=neq
        colname=eqtnames{m};
        val=rhs(m);
    elseif m<=neq+nle
        colname=elenames{m-neq};
        val=rhs(m);
    else
        colname=quadle(m-(neq+nle)).name;
        val=rhs(m);
    end
    if field==3
        c=c+1;
        l_rhsbody(c,:)=setfields(l_rhsbody(c,:),...
            2,'RHS',...
            field,colname, ...
            field+1,val);
        field=5;
    else
        l_rhsbody(c,:)=setfields(l_rhsbody(c,:),...
            field,colname, ...
            field+1,val);
        field=3;
    end
end % for-loop eqt
l_rhsbody(c+1:end,:)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set bound constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
l_bound=setfields([],0,'BOUNDS');

VarType=zeros(size(U));
%
% Var types (local definition)
%
VarType(:)=0; % real
VarType(iset) = 1; % integer
VarType(bset) = 2; % binary

% Force lower/upper bound for integer variables to be integer as well
L(iset) = max(ceil(L(iset)),0); % integer lower bound cannot be negative
U(iset) = floor(U(iset));

% Values not used, but we set for clarity
L(bset) = 0;
U(bset) = 1;

upinf=(U==inf);
loinf=(L==-inf);
lonz=(L~=0) & ~loinf;

BoundType=zeros(size(U));

%
% Bound types (local definition)
%
BoundType(:) = 3; % Default, 0<=x, real variable
BoundType(upinf & loinf) = 1; % free, real
BoundType(upinf & lonz) = 2; % lo<=x (lo ~= 0), real
BoundType(~upinf & lonz) = 4; % lo<=x<=up, integer or real
BoundType(~upinf & loinf) = 5; % x<=up, real
BoundType(~upinf & ~loinf & ~lonz) = 6; % 0<=x<=up, integer or real
BoundType(upinf & VarType==1) = 7; %  lo<=x, integer
BoundType(bset) = 8; % binary, x = 0 or 1

NLines = sum(ismember(BoundType,[1 2 6 7 8])) + ...
         sum(ismember(BoundType,[4 5]))*2;
l_boundbody=emptyline(NLines);
c=0;
for n=1:nvar
    var=varnames{n};
    lo=L(n);
    up=U(n);
    vtype = VarType(n);
    if (vtype==2) % Type 8, binary variables
        c=c+1;
        l_boundbody(c,:)=setfields(l_boundbody(c,:),...
            1, 'BV', ...
            2, 'BND1', ...
            3, var, ...
            4, 1); % Field 4 must be 1.0 or blank 
    elseif (up==inf)
        if (lo==-inf) % Type 1, Free real variable, one line
            c=c+1;
            l_boundbody(c,:)=setfields(l_boundbody(c,:),...
                1, 'FR', ...
                2, 'BND1', ...
                3, var, ...
                4, 0);
        elseif (lo~=0) || (vtype==1) % Type 2, or Type 7 lo<=x, one line
            c = c+1;
            if vtype==1 % integer, Type 7
                LOstr = 'LI';
            else % real, Type 2
                LOstr = 'LO';
            end
            l_boundbody(c,:)=setfields(l_boundbody(c,:),...
                1, LOstr, ...
                2, 'BND1', ...
                3, var, ...
                4, lo);
        % else 0<=x<=inf: Type3, real variable nothing to write
        end
    else % up<inf
        if lo>-inf
            if lo~=0 % Type 4, lo<=x<=up
                c=c+1;
                if vtype==1 % integer
                    LOstr = 'LI';
                else % real
                    LOstr = 'LO';
                end
                l_boundbody(c,:)=setfields(l_boundbody(c,:),...
                    1, LOstr, ...
                    2, 'BND1', ...
                    3, var, ...
                    4, lo);
            %else % 0<=x<=up % Type 6
            end
        else % if lo==-inf % Type 5, x<=up
            c=c+1;
            l_boundbody(c,:)=setfields(l_boundbody(c,:),...
                1, 'MI', ...
                2, 'BND1', ...
                3, var, ...
                4, 0);
        end
        % Common Type 4, 5, or 6
        % Type 6 is 0<=x<=up
        c=c+1;
        if vtype==1 % integer
            HIstr = 'UI';
        else % real
            HIstr = 'UP';
        end
        l_boundbody(c,:)=setfields(l_boundbody(c,:),...
            1, HIstr, ...
            2, 'BND1', ...
            3, var, ...
            4, up);
    end
end % for-loop on variable
l_boundbody(c+1:end,:)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quad section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for m=1:nquadle
    % Get the current quad structure
    qs = quadle(m);
    l_quad = setfields([],0,'QSECTION');
    l_quad = setfields(l_quad,3,qs.name);
    
    % Use only the upper-triangular part of Q
    [i j Qij] = find(triu(qs.Q));
    NLines = length(Qij);
    l_quadbody = emptyline(NLines);
    
    for n=1:NLines % Loop over non-zeros elements
        vari=varnames{i(n)};
        varj=varnames{j(n)};
        l_quadbody(n,:) = setfields(l_quadbody(n,:), ...
            2,vari,...
            3,varj, ...
            4,Qij(n));
    end
    
    quadle(m).qsection = [l_quad; 
                          l_quadbody]; %#ok

end % for-loop on quadratic constraints

if nquadle>1
    % concatenate together all the qsections
    l_allquad = cat(1,quadle(:).qsection);
else
    % empty line
    l_allquad = l_name([],:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the last card
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
l_end=setfields([],0,'ENDATA');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Concatenate together all parts of mps format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Contain=[l_name; ...
         l_rows; ...
         l_cost; ...
         l_rows_eq; ...
         l_rows_le; ...
         l_columns; ...
         l_columnsbody; ...
         l_rhs; ...
         l_rhsbody; ...
         l_bound; ...
         l_boundbody; ...
         l_allquad; ...
         l_end];

if ~isempty(MPSfilename)
    %
    % Save the Contain in MPSfilename
    %
    OK = SaveMPS(MPSfilename, Contain);
    if ~OK % Something is wrong during saving
        warning('BuildMPS:SavingFailure', ...
                ['BuildMPS: Cannot save ' MPSfilename]);
    end
else % Nothing to save
    OK = 1;
end

% return % Uncomment the RETURN statement causes M-lint to crash on 2009A
% There is no instructions from now on, juts nested functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nested functions: BE AWARE, the functions have access to local
% variables of BuildMPS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Generate n empty lines of MPS data
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function l=emptyline(n)
        if nargin<1 || isempty(n)
            n=1;
        end
        l=char(zeros(n,61));
        l(:)=' ';
    end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Convert to string at the fixed length of 12
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function str=num2fixedlengthstr(num, maxlength, roundingflag)
        % function str=num2fixedlengthstr(num); OR
        % str=num2fixedlengthstr(..., maxlength, roundingflag);
        %
        % Convert double NUM to decimal string having MAXLENGTH [12] as maximum
        % length. Smart conversion with accurate result despite length constraint.
        %
        % ROUNDINGFLAG: 0 or [1]
        %   0: truncate fracional part (quicker)
        %   1: rounding fracional part (more accurate).
        %
        % Last update: 15/Aug/2008, remove leading "0" when the string starts
        %              as "0.xxxx"
        %
        if nargin<2
            maxlength=12;
        end

        if nargin<3
            roundingflag=1; % rounding by default
        end

        if num>=0
            fracNDigits=maxlength;
        else
            fracNDigits=maxlength-1;
        end
        % "%G" format:
        % ANSI specification X3.159-1989: "Programming Language C,"
        % ANSI, 1430 Broadway, New York, NY 10018.
        str=num2str(num,['%0.' num2str(fracNDigits) 'G']);
        %
        % Try to compact the string data to fit inside the field length
        %
        while length(str)>maxlength
            if regexp(str,'^0\.') % delete the leading 0 in "0.xxx"
                str(1)=[];
                continue;
            end
            [istart iend]=regexp(str,'[+-](0)+'); % +/- followed by multiples 0
            if ~isempty(istart) % Remove zero in xxxE+000yy or xxxE-000yy
                str(istart+1:iend)=[];
                continue
            else
                [istart iend]=regexp(str,'E[+]');
                if ~isempty(istart) % Remove "+" char in xxxE+yyy
                    str(iend)=[];
                    continue
                end
            end
            idot=find(str=='.',1,'first');
            if ~isempty(idot)
                iE=find(str=='E',1,'first');
                if roundingflag % rounding fraction part
                    % Calculate the Length of the fractional part
                    % Adjust its number of digits and start over again
                    if ~isempty(iE) % before the mantissa
                        fracNDigits=maxlength-length(str)+iE-idot-1;
                        str=num2str(num,['%0.' num2str(fracNDigits) 'E']);
                    else %if idot<=maxlength+1 % no manissa
                        fracNDigits=maxlength-idot;
                        str=num2str(num,['%0.' num2str(fracNDigits) 'f']);
                    end
                    roundingflag=0; % won't do rounding again
                    continue % second pass with new string
                else
                    % truncate the fractional part
                    if ~isempty(iE) % before the mantissa
                        str(maxlength-length(str)+iE:iE-1)=[];
                        return;
                    else %if idot<=maxlength+1 % no mantissa
                        str(maxlength+1:end)=[];
                        return;
                    end
                end
            end
            % it should not never go here, unless BUG
            error('BuildMPS: cannot convert %0.12e to string\n',num);
        end % while loop

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set the field of an MPS line by value
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function l=setfield(l,field,var)

        if isnumeric(var) % numerical data, convert to string
            var=num2fixedlengthstr(var); % convert to 12-length string
        end

        if isempty(l)
            l=emptyline;
        end
        if ~isempty(field) && field>0
            idx=idxlist{field};
        else
            idx=1:61;
        end
        if length(var)>length(idx)
            var=var(1:length(idx));
        else
            idx=idx(1:length(var));
        end
        l(idx)=var;

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set multiple fields of an MPS line by values
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function l=setfields(l, varargin)
        for k=1:2:length(varargin)
            l=setfield(l, varargin{k}, varargin{k+1});
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate equation name for (LE) constraint
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function name=elename(m)
        name=['LE' num2str(m)];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate equation name for (EQ) constraint
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function name=eqtname(m)
        name=['EQ' num2str(m)];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate variable name
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function name=varname(n)
        name=['X' num2str(n)];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Generate equation name for (QLE) constraint
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function name=quadlename(m)
        name=['QLE' num2str(m)];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parse a pair of Name/Value option
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function parseoption(strname, value)
        if ischar(strname)
            strname = strtrim(lower(strname));
            switch strname
                case 'elenames',                   
                    if ~iscell(value) || length(value)~=nle || ...
                        ~all(cellfun(@ischar, value))
                        error('BuildMPS:IncorrectEleNames', ...
                    'BuildMPS: EleNames must be cell of %d strings', nle);
                    end
                    elenames = value;
                case 'eqtnames',
                    if ~iscell(value) || length(value)~=neq || ...
                            ~all(cellfun(@ischar, value))
                        error('BuildMPS:IncorrectEqtNames', ...
                    'BuildMPS: EqtNames must be cell of %d strings', neq);
                    end
                    eqtnames = value;
                case 'varnames',
                    if ~iscell(value) || length(value)~=nvar || ...
                            ~all(cellfun(@ischar, value))
                        error('BuildMPS:IncorrectVarNames', ...
                    'BuildMPS: VarNames must be cell of %d strings', nvar);
                    end
                    varnames = value;
                case 'varnamefun',
                    if ischar(value)
                        value=str2func(value);
                    end
                    if ~isa(value,'function_handle')
                        error('BuildMPS:IncorrectVarNameFun', ...
                              'BuildMPS: VarNameFun must be a function');
                    end
                    varnamefun = value;
                case 'eqtnamefun',
                    if ischar(value)
                        value=str2func(value);
                    end
                    if ~isa(value,'function_handle')
                        error('BuildMPS:IncorrectEqtNameFun', ...
                              'BuildMPS: EqtNameFun must be a function');
                    end
                    eqtnamefun = value;
                case 'elenamefun',
                    if ischar(value)
                        value=str2func(value);
                    end
                    if ~isa(value,'function_handle')
                        error('BuildMPS:IncorrectEleNameFun', ...
                              'BuildMPS: EleNameFun must be a function');
                    end
                    elenamefun = value;
                case 'mpsfilename',
                    if ~ischar(value)
                        error('BuildMPS:IncorrectMPSfilename', ...
                              'BuildMPS: MPSfilename must be a string');
                    end
                    MPSfilename = value;
                case  {'i' 'int' 'integer' 'integers'},
                    iset = value(:);
                    if any(iset<1 | iset>nvar)
                        error('Integer set contains invalid index');
                    end
                case {'b' 'bin' 'binary' 'binaries'},
                    bset = value(:);
                    if any(bset<1 | bset>nvar)
                        error('Binary set contains invalid index');                        
                    end
                case {'quad' 'q'},
                    qcounter = length(quadle)+1;
                    % Basic check of quad structure
                    if isstruct(value)
                        qs = value;
                        if ~isfield(qs,'Q') || ~isequal(size(qs.Q),[nvar nvar])
                            error('Missing or invalid <Q> field in QUAD structure');
                        end
                        if ~isfield(qs,'g') || isempty(qs.g)
                            qs.g = zeros(nvar,1);
                        elseif isequal(size(qs.g), [1 nvar])
                            % reshape in column
                            qs.g = qs.g(:);
                        elseif ~isequal(size(qs.g), [nvar 1])
                            error('Invalid <g> field in QUAD');
                        end
                        if ~isfield(qs,'bquad') || isempty(qs.bquad)
                            qs.bquad = 0;
                        end
                        if ~isscalar(qs.bquad)
                            error('Missing or invalid <bquad> field in QUAD structure');
                        end  
                        if ~isfield(qs,'type')
                            qs.type = 'QLE';
                        end
                        if ~strcmpi(qs.type ,'QLE')
                            error('Invalid <type> field in QUAD structure');
                        end
                        if ~isfield(qs,'name') || isempty(qs.name)
                            qs.name = quadlename(qcounter);
                        elseif strcmpi(qs.name,'COST') %
                            qs.name = 'COST'; % force to be upper case
                            % The linear term for the functional must be
                            % provides in the 5th parameter
                            % so we set 'g' to zero
                            qs.g(:) = 0;
                            qs.bquad(:) = 0;
                        end
                    else
                        if isempty(value)
                            return % ignore empty argument
                        end
                        error('Invalid input QUAD (must be a structure)');
                    end
                    quadle(qcounter) = orderfields(qs);
                otherwise
                    warning('BuildMPS:UnknownParams', ...
                        ['BuildMPS: Unknown parameter ' strname]);
            end
        else
            error('BuildMPS:IncorrectCall', ...
                  'BuildMPS: options must be pair of Name/Value');
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parse options
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function parseoptions(varargin)
        if mod(nargin,2)
            error('BuildMPS:IncorrectCall', ...
                  'BuildMPS: options must be pair of Name/Value');            
        end
        
        % default empty quadle
        quadle = struct('Q', {}, ...
                        'g', {}, ...
                        'bquad', {}, ...
                        'type', {}, ...
                        'name', {} ...
                        );
                    
        quadle = orderfields(quadle);         
        
        %
        % Loop over pair of Name/Value option
        %
        for ivararg=1:2:nargin
            parseoption(varargin{ivararg},varargin{ivararg+1});
        end
   
    end

end % BuildMPS
