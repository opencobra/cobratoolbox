function options = lusolSet(varargin)
% lusolSet creates or alters an options structure for lusol*.m.
%
% lusolSet             (with no input or output arguments)
%    displays all parameter names and their default values.
%
% options = lusolSet   (with no input arguments)
%    creates a structure with all fields set to their default values.
%
% options = lusolSet(oldopts,'PARAM1',VALUE1,'PARAM2',VALUE2,...);
%    creates a copy of oldopts with new values for the named parameters.
%    Case is ignored for parameter names, and it is sufficient to give
%    only the leading characters that uniquely identify the parameter.  
%    EXAMPLE:
%    options = lusolSet(options,'pivot','TCP','factor',5.0);
%    is equivalent to  options.Pivoting  = 'TCP';
%                      options.FactorTol = 1e-12;  
%
% options = lusolSet(oldopts,newopts);
%    combines an existing structure oldopts with a new structure newopts.
%    Parameters in newopts with non-empty values overwrite the
%    corresponding parameters in oldopts.


% options.PrintFile   A file number for statistics and error messages.
% options.PrintLevel  = 0 suppresses output
%                     = 1 gives error messages
%                     =10 gives LU statistics
%                     =50 gives info on each pivot choice
% options.MaxCol      The maximum number of columns to search
% options.Pivoting    'TPP' for Threshold Partial  Pivoting
%                     'TRP' for Threshold Rook     Pivoting
%                     'TCP' for Threshold Complete Pivoting
% options.KeepLU      'Yes' for normal use
%                     'No'  if L and U should not be saved (just p and q)
%                           (**** 'No' probably doesn't work yet ****)
% options.FactorTol   Bounds |Lij| during LU factorization (>= 1.0).
% options.UpdateTol   Bounds |Lij| during LU updates       (>= 1.0).
% options.DropTol     For neglecting small Aij and small entries in L and U.
% options.Utol1       Absolute tol for flagging small diagonals of U.
% options.Utol2       Relative tol for flagging small diagonals of U.
% options.Uspace      Factor limiting waste space in  U.
%                     The row or column lists are compressed if their
%                     length exceeds Uspace times the length of
%                     either file after the last compression.
% options.Dense1      (TPP only) The density at which the Markowitz pivot
%                     strategy should search maxcol columns and no rows.
% options.Dense2      (TPP only) The density at which the Markowitz pivot
%                     strategy should search only 1 column,
%                     or (if storage is available) the remaining matrix
%                     should be factorized by a dense LU code.


% lusolSet.m is derived from optimset.m (Revision 1.14, 1998/08/17)
% in the Optimization Toolbox of The MathWorks, Inc.

% The Matlab interface to LUSOL is maintained by
% Michael O'Sullivan and Michael Saunders, SOL, Stanford University.
%
% 18 Oct 2000: MAS: First version of lusolSet.m.
% 15 Apr 2001: MJO: Added output options (i.e., Rank, etc) 
% 14 Aug 2002: MAS: Added TRP option.

if (nargin == 0)        % Set default options.
    defoptions.PrintFile  =     6;
    defoptions.PrintLevel =    10;
    defoptions.MaxCol     =     5;
    defoptions.Pivoting   = 'TPP';
    defoptions.KeepLU     = 'Yes';
    defoptions.FactorTol  =  10.0;
    defoptions.UpdateTol  =   4.0;
    defoptions.DropTol    = eps^(4/5);
    defoptions.Utol1      = eps^(2/3);
    defoptions.Utol2      = eps^(2/3);
    defoptions.Uspace     =   3.0;
    defoptions.Dense1     =   0.3;
    defoptions.Dense2     =   0.5;
    defoptions.Inform     =     0;
    defoptions.Nsing      =     0;
    defoptions.Rank       =     0;
    defoptions.Growth     =   0.0;

    if (nargout == 0)    % Display options.
       disp('lusol default options:')
       disp( defoptions )
    else
       options = defoptions;
    end
    return;
end

Names = ...
[
    'PrintFile  '
    'PrintLevel '
    'MaxCol     '
    'Pivoting   '
    'KeepLU     '
    'FactorTol  '
    'UpdateTol  '
    'DropTol    '
    'Utol1      '
    'Utol2      '
    'Uspace     '
    'Dense1     '
    'Dense2     '
    'Inform     '
    'Nsing      '
    'Rank       '
    'Growth     '
];
m     = size (Names,1);
names = lower(Names);

% The remaining clever stuff is from optimset.m.

% Combine all leading options structures o1, o2, ... in lusolSet(o1,o2,...).
options = [];
for j = 1:m
    eval(['options.' Names(j,:) '= [];']);
end
i = 1;
while i <= nargin
    arg = varargin{i};
    if isstr(arg)                         % arg is an option name
       break;
    end
    if ~isempty(arg)                      % [] is a valid options argument
       if ~isa(arg,'struct')
          error(sprintf(['Expected argument %d to be a ' ...
                'string parameter name ' ...
                'or an options structure\ncreated with lusolSet.'], i));
       end
       for j = 1:m
          if any(strcmp(fieldnames(arg),deblank(Names(j,:))))
             eval(['val = arg.' Names(j,:) ';']);
          else
             val = [];
          end
          if ~isempty(val)
             eval(['options.' Names(j,:) '= val;']);
          end
       end
    end
    i = i + 1;
end

% A finite state machine to parse name-value pairs.
if rem(nargin-i+1,2) ~= 0
    error('Arguments must occur in name-value pairs.');
end

expectval = 0;                          % start expecting a name, not a value

while i <= nargin
    arg = varargin{i};

    if ~expectval
       if ~isstr(arg)
          error(sprintf(['Expected argument %d to be a ' ...
                         'string parameter name.'], i));
       end

       lowArg = lower(arg);
       j = strmatch(lowArg,names);
       if isempty(j)                       % if no matches
          error(sprintf('Unrecognized parameter name ''%s''.', arg));
       elseif length(j) > 1                % if more than one match
          % Check for any exact matches
          % (in case any names are subsets of others)
          k = strmatch(lowArg,names,'exact');
          if length(k) == 1
             j = k;
          else
             msg = sprintf('Ambiguous parameter name ''%s'' ', arg);
             msg = [msg '(' deblank(Names(j(1),:))];
             for k = j(2:length(j))'
                msg = [msg ', ' deblank(Names(k,:))];
             end
             msg = sprintf('%s).', msg);
             error(msg);
          end
       end
    else
       eval(['options.' Names(j,:) '= arg;']);
    end

    expectval = ~expectval;
    i = i + 1;
end

if expectval
    error(sprintf('Expected value for parameter ''%s''.', arg));
end
