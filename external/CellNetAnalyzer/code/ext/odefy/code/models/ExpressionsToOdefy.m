% EXPRESSIONSTOODEFY  Generate an Odefy model from Boolean expressions.
%
%   MODEL=EXPRESSIONSTOODEFY(EXPR) generates an Odefy model from the set of
%   Boolean equations EXPR. EXPR can be (a) a cell array of strings or (b)
%   a file containing one Boolean equation per line.
%
%   MODEL=EXPRESSIONSTOODEFY(EXPR,MODELNAME) directly assigns the name 
%   MODELNAME to the resulting Odefy model.
%
%
%  Each expression must have the form
%     varname = expression
%
%  Allowed operators are: 
%    &&  logical AND
%    ||  logical OR 
%    ~   logical NOT
%
%  Input species are marked with "<>" as the Boolean expression:
%
%  Example call:
%    model = ExpressionsToOdefy({'a = a || b','b = a && b'})
%
%  Example with input species:
%    model = ExpressionsToOdefy({'a = <>','b = a','c = a && ~b'}, 'FFL')

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function model=ExpressionsToOdefy(expr, modelname)

if isstr(expr)
    expr = ReadFileLines(expr);
end

numvars = numel(expr);
varnames{numvars} = '';

% first run, gather all variables
for i=1:numvars
    % where is the =?
    eq = strfind(expr{i}, '=');
    % get variable name
    varnames{i} = strtrim(expr{i}(1:eq-1));
    [x isvalid] = validvarname(varnames{i});
    if ~isvalid
        error('Invalid variable name ''%s''',varnames{i});
    end
end
model.species = varnames;

% iterate over expressions again, this time we create the truth tables
for i=1:numvars
    % where is the =?
    eq = strfind(expr{i}, '=');
    curexpr = expr{i}(eq+1:end);
    % if this is '<>' => input species
    if (strcmp(strtrim(curexpr),'<>'))
        model.tables(i).truth = [];
        model.tables(i).inspecies = [];
    else
        % get all tokens
        inputs = [];
        inputindex = 0;
        r = curexpr;
        while (1)
            [t,r] = strtok(r, ' ()|&~');
            if (numel(t) == 0) 
                break
            end
            % is this token a variable?
            if (~strcmpi(t,'&&') && ~strcmpi(t,'||') && ~strcmpi(t,'~') && ~strcmpi(t,'1') && ~strcmpi(t,'0')  && ~strcmpi(t,'false')  )
                % yes it is, find its index
                index = FindIndex(varnames,t);
                if (index < 0)
                    error(['Unknown variable: ' t ' in expression ' num2str(i)]);
                end
                if (numel(find(inputs==index)) == 0)
                    inputindex = inputindex + 1;
                    inputs(inputindex) = index;
                end
            end
        end
        % initialize truth table
        if (inputindex== 1)
            truth = zeros(2,1);
        else
            truth = zeros(ones(1,inputindex)*2);
        end
        % we know the input species, evaluate all combinations,
        for j=0:2^inputindex-1
            state = bin2vec(j,inputindex);
            % set values accordingly
            for k=1:inputindex
                if state(k) == 0
                    l = 'false';
                else
                    l = 'true';
                end
                eval([varnames{inputs(k)} '=' l ';']);
            end
            % evaluate expression
            eval(['truth(' num2str(j+1) ') = ' curexpr ';']);

        end
        % save in model
        model.tables(i).truth = truth;
        model.tables(i).inspecies = inputs;    
    end
end

if nargin>=2
    model.name = validvarname(modelname);
else
    model.name = 'odefymodel';
end


function ind = FindIndex(list, search)

ind = -1;
for i=1:numel(list)
    if (strcmp(list{i},search))
        ind = i;
        break,
    end
end


function v = bin2vec(binnum, n)

v = zeros(n,1);

for i=n-1:-1:0
    pow2 = 2^i;
    if binnum >= pow2
        v(i+1) = 1;
        binnum = binnum - pow2;
    end
end

% Read all lines from a given file and return cell array
function l=ReadFileLines(file)
h = fopen(file, 'r');
l={};
while ~feof(h)
    l{end+1} = fgetl(h);
end
fclose(h);