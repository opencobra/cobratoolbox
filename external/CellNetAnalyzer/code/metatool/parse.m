function sys= parse(fname, strict)
% parser for Metatool; can read the regular and the extended format
% $Revision: 441 $

if nargin < 2
  strict= false; %A# whether or not to allow undeclared reactions/metabolites
end
% t= cputime;
sys.err= 1;
sys.int_met= cell(0,1);
sys.ext_met= cell(0,1);
rev_react_name= cell(0,1);
irrev_react_name= cell(0,1);
section= 0; %A# delimits 1 ENZREV, 2 ENZIR(R)EV, 3 METINT, 4 METEXT, 5 CAT; 0 is comment header
[fid, msg]= fopen(fname, 'r');
if fid == -1
  disp(['Error opening file ', fname]);
  disp(msg);
  return;
end
cat_sect= cell(0, 1);
while feof(fid) == 0
  finput= fgetl(fid);
  if isempty(finput) || (section == 0 && finput(1) ~= '-') || finput(1) == '#'
    continue; %A# skip empty lines and comments
  end
  if finput(1) == '-' %A# new section begins
    switch finput(~isspace(finput))
      case '-ENZREV'
        section= 1;
      case {'-ENZIRREV', '-ENZIREV'}
        section= 2;
      case '-METINT'
        section= 3;
      case '-METEXT'
        section= 4;
      case '-CAT'
        section= 5;
      otherwise
        disp(['Error: unknown section header ', finput]);
        return;
    end %A# switch
  else
    if section == 5
      cat_sect{end+1}= finput; %A# only collect lines of -CAT section, parsing comes later
    else
      %A# parsing of finput for sections 1 - 4
      finput= regexp(strtok(finput, '#'), '(\S+)', 'tokens'); %A# strtok removes trailing comments
      switch section
        case 1
          rev_react_name= [rev_react_name; [finput{:}]'];
        case 2
          irrev_react_name= [irrev_react_name; [finput{:}]'];
        case 3
          sys.int_met= [sys.int_met; [finput{:}]'];
        case 4
          sys.ext_met= [sys.ext_met; [finput{:}]'];
      end
    end
  end
end
% disp(cputime - t);
fclose(fid);
is= intersect(irrev_react_name, rev_react_name);
if ~isempty(is)
  disp('Error: the following reactions were both declared as reversible and irreversible');
  disp(is);
  return;
end
is= intersect(sys.int_met, sys.ext_met);
if ~isempty(is)
  disp('Error: the following metabolites were both declared as internal and external');
  disp(is);
  return;
end
irrev_react_name= remove_duplicates(irrev_react_name);
rev_react_name= remove_duplicates(rev_react_name);
sys.int_met= remove_duplicates(sys.int_met);
sys.ext_met= remove_duplicates(sys.ext_met);
sys.react_name= [irrev_react_name; rev_react_name];
sys.irrev_react= [ones(1, length(irrev_react_name)), zeros(1, length(rev_react_name))];
%A# do not set up 'st' and 'ext' as fields of 'sys' yet because
%A# access to these fields when filling in the coefficients is very
%A# slow in octave (why?)
st= zeros(length(sys.int_met), length(sys.irrev_react));
ext= zeros(length(sys.ext_met), length(sys.irrev_react));
if strict && isempty(st)
  disp('Error: no internal metabolites and/or no reactions were declared');
  return;
end
if isempty(cat_sect)
  disp('Error: -CAT section empty or missing');
  return;
end
cat_sect= regexprep(cat_sect,'\s*[\.\\]?\s*$|#.*',''); %A# deletes trailing . and \ and whitespaces | and comments
%A# could append a ' ' at the end of each line to simplify separator
%A# recognition below but strcat does not work on cell arrays in octave 
%A# identify reaction definitions
% [reac_tok, tok_end]= regexp(cat_sect, '\s*(\S*)\s+:\s+', 'tokens', 'end', 'once');
[reac_tok, tok_start, tok_end]= regexp(cat_sect, '\s*(\S*)\s+:\s+', 'tokens', 'start', 'end', 'once');
errs= find([tok_start{:}] > 1); %A# occurs e.g. if a line starts like 'aaa bbb : '
for i= errs
  disp(['Error: invalid reaction definition ''', cat_sect{i}(1:tok_end{i}), '''']);
end
if ~isempty(errs)
  return;
end
% disp(cputime - t);
i= 1;
while i < length(cat_sect) %A# not <= because last line cannot be continued
  if isempty(reac_tok{i + 1}) %A# merge with next line
    cat_sect{i}= [cat_sect{i}, ' ', cat_sect{i + 1}];
    cat_sect(i + 1)= [];
    reac_tok(i + 1)= [];
    tok_end(i + 1)= [];
  else
    i= i + 1;
  end
end
% disp(cputime - t);
reac_tok= [reac_tok{:}]; %A# turn into cell array of strings
if iscell(reac_tok{1}) %A# certain octave versions use an additional layer of cells
  reac_tok= [reac_tok{:}];
end
tok_end= [tok_end{:}]; %A# turn into numeric vector
%A# make sure to capture separators correctly when right hand side is completely empty
[lrhs_sep, sep_start, sep_end]= regexp(cat_sect, '\s+(==?|=>|<=)\s+|\s+(==?|=>|<=)$', 'tokens', 'start', 'end');
num_sep= cellfun('length', lrhs_sep);
err_sep= num_sep ~= 1;
if any(err_sep)
  disp('Error: incorrect separators (=|==|=>|<=) in the definition of the following reactions');
  disp(reac_tok(err_sep)');
  return;
end
% disp(cputime - t);
%A# the following conversions are somewhat expensive under octave
% lrhs_sep= [lrhs_sep{:}]; %A# remove one layer of cell array encapsulation
% lrhs_sep= [lrhs_sep{:}]; %A# turn into cell array of strings
% sep_start= [sep_start{:}]; %A# turn into numeric vector
% sep_end= [sep_end{:}]; %A# turn into numeric vector
lhs= cell(length(cat_sect), 1);
rhs= cell(length(cat_sect), 1);
% disp(cputime - t);
for i= 1:length(cat_sect)
  lhs{i}= cat_sect{i}(tok_end(i):sep_start{i}); %A# makes sure first/last character in lhs{i} is whitespace
  if isspace(cat_sect{i}(sep_end{i}))
    rhs{i}= cat_sect{i}(sep_end{i}:length(cat_sect{i})); %A# makes sure first character in rhs{i} is whitespace
  else %A# right hand side was emmpty and last captured token belongs to the separator itself
    rhs{i}= '';
  end
  rhs{i}(end+1)= ' '; %A# makes sure last character in rhs{i} is whitespace
end
cat_sect= [lhs, rhs]; %A# the columns are the left-hand sides resp. right_hand sides
% disp(cputime - t);
%A# if a coefficient is specified but no metabolite (e.g. '...+ 1 +...')
%A# the pattern will interpret the coefficient as metabolite without
%A# coefficient
%A# the (?<err>\S+) part captures anything that does not fit into the
%A# correct input pattern
cat_sect= regexp(cat_sect,...
  '\s+(?<coeff>(?:(?:\d+|\d*\.\d+|\d+\.\d*)(?:(?:e|E|e\+|E\+|e-|E-)\d+)?))?(?(1)\s+)(?<met>\S+)\s+(?<plsn>\+)?|(?<err>\S+)\s+', 'names');
%A#                  42      .42    42.     e1
% disp(cputime - t);
if exist('octave_config_info', 'builtin'); %A# > 0 for octave, 0 otherwise (Matlab)
  %A# octave produces structs with fields containing cell arrays during
  %A# named capture; these are converted to struct arrays to achieve the
  %A# same arrangement of cat_sect as under Matlab
  for i= 1:numel(cat_sect)
    syms= cat_sect{i};
    cat_sect{i}= struct('coeff', syms.coeff, 'met', syms.met, 'plsn', syms.plsn, 'err', syms.err);
  end
end
%A# check if something didn't fit into the input pattern
found_errs= false;
for i= 1:size(cat_sect, 1)
  for lhrh= 1:2
    if ~isempty(cat_sect{i, lhrh}) %A# prevents errors under octave
      errs= {cat_sect{i, lhrh}.err};
      has_errs= ~(cellfun('isempty', errs));
      if any(has_errs)
        found_errs= true;
        disp(['Error: Confusing input in definition of reaction ', reac_tok{i}, ' near']);
        disp(errs(has_errs));
      end
    end
  end
end
if found_errs
  return;
end
num_met_tok= cellfun('length', cat_sect);
num_met_tok= cumsum(num_met_tok(:));
met_tok= cell(1, num_met_tok(end));
% coeff_tok= cell(1, num_met_tok(end)); %A# collecting coefficients is probably only a minor improvement
first= 1;
for i= 1:numel(cat_sect) %A# collect all metabolites names into one cell array
  last= first + length(cat_sect{i}) - 1;
%   [met_tok{first:last}]= cat_sect{i}.met; %A# works under Matlab only
  [met_tok(first:last)]= {cat_sect{i}.met};
%   [coeff_tok(first:last)]= {cat_sect{i}.coeff};
  first= last + 1;
end
if ~isempty(sys.int_met) || ~isempty(sys.ext_met)
  [declared, met_ind]= ismember(met_tok, [sys.int_met; sys.ext_met]);
else %A# ismember({...}, {}) leads to an error in octave
  declared= false(size(met_tok));
  met_ind= zeros(size(met_tok));
end
ext_met= met_ind > length(sys.int_met); %A# indicates which metabolites are external
met_ind(ext_met)= met_ind(ext_met) - length(sys.int_met);
undeclared= ~declared;
if any(undeclared)
  undeclared= find(undeclared);
  undecl_met= met_tok(undeclared);
  chk_str= str2double(undecl_met); % Matlab str2double interprets 'i' and 'j' as complex numbers!
  undeclared= undeclared(isnan(chk_str) | ~isreal(chk_str)); %A# the other errors will be reported later
  clear chk_str;
  undecl_met= unique(met_tok(undeclared));
  if ~isempty(undecl_met)
    if strict
      disp('Error: the following metabolites are undeclared');
      disp(undecl_met');
      return;
    else
      disp('The following metabolites are undeclared and will be added as internal metabolites');
      disp(undecl_met');
      sys.int_met= [sys.int_met; undecl_met'];
      [dummy, met_ind(undeclared)]= ismember(met_tok(undeclared), undecl_met);
      met_ind(undeclared)= met_ind(undeclared) + size(st, 1); %A# ext_met is false by default
      st= [st; zeros(length(undecl_met), size(st, 2))];
    end
  end
end
if ~isempty(sys.react_name)
  [declared, reac_ind]= ismember(reac_tok, sys.react_name);
else %A# ismember({...}, {}) leads to an error in octave
  declared= false(size(reac_tok));
  reac_ind= zeros(size(reac_tok));
end
undeclared= ~declared;
if any(undeclared)
  if strict
    disp('Error: the following reactions are undeclared');
    disp(reac_tok(undeclared)');
    return;
  else %A# append undeclared reactions regardless of their reversibility
    disp('The following undeclared reactions are added to the system');
    disp(reac_tok(undeclared)');
    num_undeclared= sum(undeclared);
    sys.irrev_react= [sys.irrev_react, ones(1, num_undeclared)]; %A# will be modified later
    sys.react_name= [sys.react_name; [reac_tok(undeclared)]'];
    %A# this circuitious assignment of indices allows recognition of
    %A# undeclared reactions that have multiple definitions
    [dummy, reac_ind(undeclared)]= ismember(reac_tok(undeclared), reac_tok(undeclared));
    reac_ind(undeclared)= size(st, 2) + reac_ind(undeclared);
    st= [st, zeros(size(st, 1), num_undeclared)];
    ext= [ext, zeros(size(ext, 1), num_undeclared)];
  end
end
%A# find out if any reactions are undefined or defined more than once
defined= zeros(1, size(st, 2));
for i= 1:length(reac_ind)
  defined(reac_ind(i))= defined(reac_ind(i)) + 1;
end
mult_def= defined > 1; %A# check this first
if any(mult_def)
  disp('Error: the following reactions are defined more than once');
  disp(sys.react_name(mult_def));
  return;
end
undefined= defined == 0;
if any(undefined)
  if strict
    disp('Error: the following reactions are declared but not defined');
  else
    disp('Warning: the following reactions were declared but not defined; they will be removed from the system');
    %A# the actual removal takes place later in order not to mess up the
    %A# indices here
  end
  disp(sys.react_name(undefined));
  if strict
    return;
  end
end
% disp(cputime - t);
%A# set up so that num_met_tok(sub2ind(size(cat_sect), i, lhrh)) + j indexes met_ind and ext_met
num_met_tok= [0; num_met_tok]; %A# last element is actually superfluous
for i= 1:size(cat_sect, 1)
  reac= reac_ind(i);
  switch lrhs_sep{i}{1}{1} %A# vectorize this before for loop begins?
    case '=' %A# valid for reversible and irreversible reactions
      sn= -1;
      if undeclared(i)
        sys.irrev_react(reac)= 0;
      end
    case '==' %A# use this to override a declaration as irreversible reaction
      sn= -1;
      if ~undeclared(i) && sys.irrev_react(reac)
        if strict
          found_errs= true;
        else
          disp(['Warning: conflicting reversibility for reaction ', reac_tok{i}]);
          disp('Reaction is now treated as reversible');
        end
      end
      sys.irrev_react(reac)= 0;
    case '=>'
      if ~sys.irrev_react(reac)
        if strict
          found_errs= true;
        else
          disp(['Warning: conflicting reversibility for reaction ', reac_tok{i}]);
          disp('Reaction is now treated as irreversible (forward direction)');
          sys.irrev_react(reac)= 1;
        end
      end
      sn= -1;
    case '<='
      if ~sys.irrev_react(reac)
        if strict
          found_errs= true;
        else
          disp(['Warning: conflicting reversibility for reaction ', reac_tok{i}]);
          disp('Reaction is now treated as irreversible (backward direction)');
          sys.irrev_react(reac)= 1;
        end
      end
      sn= 1;
  end
  if found_errs
    disp(['Error: conflicting reversibility for reaction ', reac_tok{i}]);
  end
  for lhrh= 1:2
    syms= cat_sect{i, lhrh}; %A# syms is a struct array with fields coeff, met, plsn
%     pos= num_met_tok(sub2ind(size(cat_sect), i, lhrh)) %A# pos + j indexes met_ind and ext_met
    pos= num_met_tok(i + (lhrh - 1)*size(cat_sect, 1)); %A# same as line above but without function call
    for j= 1:length(syms)
      coeff= syms(j).coeff;
      if isempty(coeff)
        coeff= sn;
      else
        coeff= sn*sscanf(coeff, '%f'); %A# call sscanf directly instead of indirectly via str2double
      end
      if met_ind(pos+j) == 0
        disp(['Error: missing metabolite after coefficient ', met_tok{pos+j}, ' in reaction ', reac_tok{i}]);
        return;
      end
      if ext_met(pos+j)
        ext(met_ind(pos+j), reac)= ext(met_ind(pos+j), reac) + coeff;
      else
        st(met_ind(pos+j), reac)= st(met_ind(pos+j), reac) + coeff;
      end
      if (j < length(syms) && isempty(syms(j).plsn)) || (j == length(syms) && ~isempty(syms(j).plsn))
        disp(['Warning: incorrect syntax in definition of reaction ', reac_tok{i}]);
      end
    end
    sn= -sn;
  end
end
if any(undefined)
  sys.react_name(undefined)= [];
  sys.irrev_react(undefined)= [];
  sys.st= st(:, ~undefined);
  sys.ext= ext(:, ~undefined);
else
  sys.st= st;
  sys.ext= ext;
end
unused= ~any(sys.st, 2);
if any(unused)
  disp('Warning: The following internal metabolites are never used');
  disp(sys.int_met(unused));
end
unused= ~any(sys.ext, 2);
if any(unused)
  disp('Warning: The following external metabolites are never used');
  disp(sys.ext_met(unused));
end
sys.err= 0;
% disp(cputime - t);

function C= remove_duplicates(C)
% remove duplicate elements from cell array C without affecting the order
% of the other elements
[unq, ind]= unique(C);
if length(unq) < length(C)
  rep= false(size(C));
  rep(ind)= true;
  disp('The following duplicate declarations were removed');
  disp(C(~rep));
  C= C(rep);
end
