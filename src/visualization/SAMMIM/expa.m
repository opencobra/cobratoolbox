function [model, fullmodel] = expa(model,varargin)
% function [model fullmodel] = expaths(model,print)
% 
% This function finds the extreme pathways of a stoichiometric model
% according to the algorithm by Schilling, Letscher and Palsson:
% 
% Schilling, C. H., Letscher, D. & Palsson, B. O. Theory for the systemic 
% definition of metabolic pathways and their use in interpreting metabolic 
% function from a pathway-oriented perspective. Journal of theoretical 
% biology 203, 229–48 (2000). 
% 
% This algorithm is defined in appendix B of the citation above. Steps of
% the algorithm and relevant excerpts from the paper are quoted as comments
% throuhghout the code
% 
% INPUT:
% model - model is inputed in the format used with the COBRA toolbox.
% Minimum required fields are
%   S - stoichiometric coefficient matrix
%   lb - lower bound for reactions
%   ub - upper bound for reactions
%   rev - reversibility flag for each reaction in the model. Freely
%       exchanged metabolites (From exchange reactions) are not determined to
%       be so through their reversibility flag, but through non-zero upper and
%       lower bounds. Inputs have a zero upper bound and outputs have a zero
%       lower bound
%   c - objective function
%   rxns - reaction names
% 
% OPTIONAL INPUT
% Print - If this input is given and is 1, 'y' or 'Y' the function prints
% the progress of the algorithm.
% 
% OUTPUTS
% fullmodel - decomposed model of original model inputed. Reversible
%   reactions get decomposed into two forward reactions. All fields mentioned
%   above get adjusted, as well as rules,rxnGeneMat,grRules,subSystems,
%   confidenceScores,rxnReferences,rxnECNumbers,rxnNotes,rxnNames. These are
%   commonly used COBRA fields. most importantly, a matrix P is added as a
%   field and corresponds to the extreme pathways.
% model - the model outputted matches the original model inputed. This is a
%   collapsed version of the 'fullmodel' output, where the reversible
%   reactions that had been decomposed are combined again. The extreme
%   pathways are combined as absolute value.

if nargin > 1 && (varargin{1} == 'y' || varargin{1} == 'Y' || varargin{1} == 1)
    print = 1;
else
    print = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initialize variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S = full(model.S);
rxns = model.rxns;
ub = model.ub;
lb = model.lb;
rev = model.rev;

%% Arrange model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Put things in order first. Rearrange reactions so that exchange fluxes are
%in the end and decompose all reversible reactions into two opposing
%fluxes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%make sure vectors are row vectors
if iscolumn(rxns)
    rxns = rxns';
end
if iscolumn(lb)
    lb = lb';
end
if iscolumn(ub)
    ub = ub';
end
if iscolumn(rev)
    rev = rev';
end
%Define what kind of flux each of the fluxes are. 'x' means exchange flux
%and i means 'internal'
sz = size(S);
fluxtype = cell(1,sz(2));
xcount = 0;
icount = 0;
for i = 1:sz(2)
    if length(find(S(:,i))) == 1
        fluxtype{i} = 'x';
        xcount = xcount+1;
    else
        fluxtype{i} = 'i';
        icount = icount+1;
    end
end

%Decompose all reversible reactions into two fluxes. "All internal
%reactions that are considered to be capable of operating in a reversible
%fashion are considered as two fluxes occuring in opposite directions,
%therefore constraining all internal fluxes to be non-negative.
[m n] = size(S);
%make room
S = [S zeros(m,n)];
lb = [lb zeros(1,length(lb))];
ub = [ub zeros(1,length(ub))];
rev = [rev zeros(1,length(rev))];
fluxtype = cat(2,fluxtype,cell(1,length(fluxtype)));
rxns = cat(2,rxns,cell(1,length(rxns)));
%Decompose
count = 1;
ixs = zeros(1,2*n);
ixs(1:n) = 1:n;
for i = 1:n
    %If reaction is reversible
    if model.rev(i) && fluxtype{i} == 'i'
        %Add reverse of the reaction
        S(:,n+count) =  -S(:,i);
        fluxtype{n+count} = 'i';
        rxns{n+count} = [rxns{i} '_rev'];
        ixs(n+count) = i;
        ub(n+count) = -lb(i);
        lb(i) = 0;
        lb(n+count) = 0;
        rev(n+count) = 1;
        count = count+1;
    end
end
%Clear empty space
for i = 2*n:-1:1
    if ~isempty(find(S(:,i),1))
        i = i+1;
        S(:,i:2*n) = [];
        lb(i:2*n) = [];
        ub(i:2*n) = [];
        rev(i:2*n) = [];
        rxns(i:2*n) = [];
        fluxtype(i:2*n) = [];
        ixs(i:2*n) = [];
        break
    end
end
[~, n] = size(S);

%Arrange matrix so that exchange fluxes come after the internal fluxes
%%"We typically structure the stoichiometric matrix so that the first
%%series of columns represent the internal fluxes and the remaining columns
%%represent the exchange fluxes"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%rearrange reactions by name
[rxns indexes] = sort(rxns);
ub = ub(indexes);
lb = lb(indexes);
rev = rev(indexes);
fluxtype = fluxtype(indexes);
S = S(:,indexes);
ixs = ixs(indexes);
%rearrange reactions by type
[fluxtype indexes] = sort(fluxtype);
rxns = rxns(indexes);
ub = ub(indexes);
lb = lb(indexes);
rev = rev(indexes);
S = S(:,indexes);
ixs = ixs(indexes);

%Save new model
model.S = sparse(S);
model.rxns = rxns;
model.ub = ub;
model.lb = lb;
model.fluxtype = fluxtype;
model.rev = rev;
model.c = zeros(1,n);
if isfield(model,'rules')
    model.rules = model.rules(ixs);
end
if isfield(model,'rxnGeneMat')
    model.rxnGeneMat = model.rxnGeneMat(ixs,:);
end
if isfield(model,'grRules')
    model.grRules = model.grRules(ixs);
end
if isfield(model,'subSystems')
    model.subSystems = model.subSystems(ixs);
end
if isfield(model,'confidenceScores')
    model.confidenceScores = model.confidenceScores(ixs);
end
if isfield(model,'rxnReferences')
    model.rxnReferences = model.rxnReferences(ixs);
end
if isfield(model,'rxnECNumbers')
    model.rxnECNumbers = model.rxnECNumbers(ixs);
end
if isfield(model,'rxnNotes')
    model.rxnNotes = model.rxnNotes(ixs);
end
if isfield(model,'rxnNames')
    model.rxnNames = model.rxnNames(ixs);
end

%% Begin Algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Begin Extreme pathway algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S = full(model.S);
sz = size(S);
%The algorithm begins with the formulation of an initial matrix consisting
%of an n by n identity matrix appended to the transpose of the
%stoichiometry matrix S, ST
[metsnum rxnnum] = size(S);
T0 = zeros(rxnnum,rxnnum + metsnum);
T0(:,1:rxnnum) = eye(rxnnum);
T0(:,rxnnum+1:end) = S';

%Then we examine the constraints on each of the exchange fluxes as given in
%the equation: alphaj <= bj <= betaj. If the exchange flux is constrained
%to be positive nothing is done. however, if the exchange flux is 
%constrained to be negative, then we multiply the corresponding row of the 
%initial matrix by -1. If the exchange flux is unconstrained then we move 
%the entire row to a temporaty matrix, TE. This completes the 
%initialization of the first tableau, TO.
remove = [];
szT0 = size(T0);
TE = [];
for i = szT0(1)-xcount:szT0(1)
    if lb(i) < 0 && ub(i) > 0
        TE = [TE; T0(i,:)];
        remove = [remove i];
    elseif lb(i) < 0 && ub(i)<=0
        T0(i,:) = T0(i,:)*(-1);
    end
end

for i = length(remove):-1:1
    T0(remove(i),:) = [];
end
szT0 = size(T0);
%Step 1: Identify all metabolites that do not have an unconstrained
%exchange flux associated with them. The total number of such metabolites
%is denoted by mu.
if ~isempty(TE)
    c = [];
    szTE = size(TE);
    test = TE(:,rxnnum+1:end);
    c = find(sum(abs(test),1)==0);
else
    c = 1:length(model.mets);
end
mu = length(c);
clear test x
T0 = sparse(T0);
TE = sparse(TE);
%Step 5: repeat teps 2 to 4 for all of the metabolites that do not have an
%unconstrained exchange flux operating on the metabolite. This is performed
%by this for loop containing steps 2 to 4.
tic
alreadysaidso = false;
while ~isempty(c)
%Determine Best c to be used min(pos*neg). By using the best argument c
%possible we minimize the computational cost.
posnum = sum(T0(:,rxnnum+c)>0);
negnum = sum(T0(:,rxnnum+c)<0);
[~ , i] = min(posnum.*negnum);
%Print progress:
if print
    fprintf([num2str(length(c)) ' metabolites left'...
        '\t' model.mets{c(i)} '\n'])
    fprintf(['Size of T is: ' num2str(size(T0,1)) '\n'])
end
tic
%Step 2: Begin forming the new matrix Tx by copying all rows from Tx-1
%which contain a zero in the column of ST that corresponds  to the first
%metabolite indentified in step 1, denoted by the index c
    %Initialize T1
    %find rows that contain a zero in the metabolite's column
    temp = find(T0(:,rxnnum+c(i))==0);
    %copy rows to T1
    T1 = T0(temp,:);
    %find all other rows
    x = 1:size(T0,1);
    y = ~ismember(x,temp);
    x = x(y);
    %clear rows from T0
    T0 = T0(x,:);
    szT0 = size(T0);
    
%Step 3: Of the remaining rows in T(x-1) add together all possible
%combinations of rows which contain values of the opposite sign in the
%colum c, such that the addition produces a zero in this column.
%Find vectors of positive and negative numbers
pos = find(T0(:,rxnnum+c(i))>0);
neg = find(T0(:,rxnnum+c(i))<0);
%Get matrix of rows with negative coefficients
T0neg = T0(neg,:);
T0neg = clearrows(T0neg);
%Get matrix of rows with positive coefficients
T0pos = T0(pos,:);
T0pos = clearrows(T0pos);
if print
fprintf([num2str(size(T0pos,1)) ' positive rows\n'])
fprintf([num2str(size(T0neg,1)) ' negative rows\n'])
end
if ~isempty(pos) && ~isempty(neg)
    if alreadysaidso
        saidsofornow = true;
    else
        saidsofornow = false;
    end
    if size(T0pos,1) < size(T0neg,1)
        %get positive coefficients
        posent = T0(pos,rxnnum+c(i));
        %Make diagonal matrix with negative coefficients
        negM = abs(diag(T0(neg,rxnnum+c(i))));
        s = size(negM,1);
        for ij = 1:length(pos)
            if saidsofornow
                fprintf(['Calculating ' num2str(ij) ' of ' num2str(length(pos)) ...
                    ', size of T is ' num2str(size(T1,1)) '\n'])
            end
            temp = repmat(T0(pos(ij),:),s,1);
            T1 = [T1; negM*temp + diag(ones(1,s)*posent(ij))*T0neg];
            %Clear conical dependence (Step 4). Auxiliar function.
            T1 = clearrows(T1);
            if toc>15 && ~saidsofornow
                fprintf(['Currentyl on ' num2str(ij) ' of ' num2str(length(pos)) ...
                    ', size of T is ' num2str(size(T1,1)) '\n'])
                fprintf('Computation is getting costly! Metabolites still to go:\n')
                for ijk = 1:length(c)
                    fprintf([model.mets{c(ijk)} '\n'])
                end
                bol = askinput('Would you like to proceed (p) or exit expa calculation (r)',{'p' 'r'});
                if bol == 'r'
                    model = []; 
                    fullmodel = [];
                    fprintf('Exiting expa calculation. Empty outputs returned\n\n')
                    return
                end
                bol = askinput(['Would you like me to keep asking whether you would like to procced (a)?\n',...
                    'or would you like to go on with expa calculation to the end (e)?'], {'a' 'e'});
                
                saidsofornow = true;
                if bol == 'e'
                    alreadysaidso = true;
                end
            end
        end
    else
        %get negative coefficients
        negent = T0(neg,rxnnum+c(i));
        %Make diagonal matrix with positive coefficients
        posM = diag(T0(pos,rxnnum+c(i)));
        s = size(posM,1);
        for ij = 1:length(neg)
            if saidsofornow
                fprintf(['Calculating ' num2str(ij) ' of ' num2str(length(neg)) ...
                    ', size of T is ' num2str(size(T1,1)) '\n'])
            end
            temp = repmat(T0(neg(ij),:),s,1);
            T1 = [T1; posM*temp + abs(diag(ones(1,s)*negent(ij)))*T0pos];
            %Clear conical dependence (Step 4). Auxiliar function.
            T1 = clearrows(T1);
            if toc>15 && ~saidsofornow
                fprintf(['Currentyl on ' num2str(ij) ' of ' num2str(length(neg)) ...
                    ', size of T is ' num2str(size(T1,1)) '\n'])
                fprintf('Computation is getting costly! Metabolites still to go:\n')
                for ijk = 1:length(c)
                    fprintf([model.mets{c(ijk)} '\n'])
                end
                bol = askinput('Would you like to proceed (p) or exit expa calculation (r)',{'p' 'r'});
                if bol == 'r'
                    model = []; 
                    fullmodel = [];
                    fprintf('Exiting expa calculation. Empty outputs returned\n\n')
                    return
                end
                bol = askinput(['Would you like me to keep asking whether you would like to procced (a)?\n',...
                    'or would you like to go on with expa calculation to the end (e)?'], {'a' 'e'});
                saidsofornow = true;
                if bol == 'e'
                    alreadysaidso = true;
                end
            end
        end
    end
end
clear T0 temp pos neg T0pos T0neg posM negM posent negent
T0 = T1;
szT0 = size(T0);
clear T1
c(i) = [];
end

T1 = T0;
clear T0
clear temp
%note that the number of extreme pathways will be equal to the number of
%rows in T1
%Step 6: Next we append TE to the bottom of T1

T1 = [T1; TE];
%Step 8: follow the same procedure as in step 7 for each of the columns on
%the right side fo the tableau containing nonzero entries

for i = sz(2)+1:size(T1,2)
    if ~isempty(find(T1(:,i),1))
%Step 7: Starting at the n+1 column (or the first non-zero column on the
%right side), if Ti,(n+1) does not equal zero, then add the corresponding
%non-zero row from TE to row i so as to produce a zero in the (n+1) column.
%This is done by simply multiplying the corresponding row in TE by Ti,(n+1)
%and adding this to row i. Repeat this procedure for each of the rows in
%the upper portion of the tableau so as to create zeros in the entire upper
%portion of the (n+1) column. When finished, remove the row in TE
%corresponding to the exchange flux for the metabolite just balanced.
        x = find(T1(:,i));
        if length(x) > 1
            for j = 1:length(x)-1
                T1(x(j),:) = T1(x(j),:) + T1(x(end),:)*T1(x(j),i);
            end
        end
        T1(x(end),:) = [];
    end
end
%The final tableau, Tfinal, wil contain the transpose of the matrix P
%containing the extreme pathways in place of the original identity matrix.
model.P = T1(:,1:sz(2));
fullmodel = model;
%Revert model back to original model
s = length(model.rxns);
for i = s:-1:1
    %If reaction is the reverse of another reaction enter the loop
    if length(model.rxns{i})>3 && strcmp(model.rxns{i}(end-3:end),'_rev')
        %find index if original reaction
        j = find(ismember(model.rxns,model.rxns{i}(1:end-4)));
        if ~all(size(model.P(:,j))==size(model.P(:,i)))
            keyboard
        end
        %Fix matrix P and upper and lower bounds
        model.P(:,j) = model.P(:,j) - model.P(:,i);
        model.lb(j) = -model.ub(i);
        %Define reaction as reversible
        model.rev(j) = 1;
        %Delete _rev reaction
        model.S(:,i) = [];
        model.rxns(i) = [];
        model.rev(i) = [];
        model.lb(i) = [];
        model.ub(i) = [];
        model.c(i) = [];
        model.P(:,i) = [];
        model.fluxtype(i) = [];
        if isfield(model,'rules')
            model.rules(i) = [];
        end
        if isfield(model,'rxnGeneMat')
            model.rxnGeneMat(i,:) = [];
        end
        if isfield(model,'grRules')
            model.grRules(i) = [];
        end
        if isfield(model,'subSystems')
            model.subSystems(i) = [];
        end
        if isfield(model,'confidenceScores')
            model.confidenceScores(i) = [];
        end
        if isfield(model,'rxnReferences')
            model.rxnReferences(i) = [];
        end
        if isfield(model,'rxnECNumbers')
            model.rxnECNumbers(i) = [];
        end
        if isfield(model,'rxnNotes')
            model.rxnNotes(i) = [];
        end
        if isfield(model,'rxnNames')
            model.rxnNames(i) = [];
        end
    end
end
    fullmodel.rev = fullmodel.rev';
    fullmodel.lb = fullmodel.lb';
    fullmodel.ub = fullmodel.ub';
    fullmodel.c = fullmodel.c';
    fullmodel.rxns = fullmodel.rxns';
    model.rev = model.rev';
    model.lb = model.lb';
    model.ub = model.ub';
    model.c = model.c';
    model.rxns = model.rxns';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Support function for expa.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function M = clearrows(M)
    %Step 4: For all of the rows added to Tx in steps 2 and 3 check to make
    %sure that no row exists that is a non-negative combination of any other set
    %of rows in Tx. One method used is as follows:
    %Let A(i) equal the set of column indices, j, for which the elements of row
    %i equal zero. Then check to determine if there exists another row h for
    %which A(i) is a subset of A(h).
    %   A(i) is contained in A(h), i~=h
    %   where
    %   A(i) = {j:T(i,j)=0, 1<=j<=columns of T}
    %Thus if these equations hold true for any distinct os i and h, then row i
    %must be eliminated from T1
    %Here we will calculate the matrix test as follows:
    %In this matrix, if a column index is zero in row i and not zero in row h,
    %which would mean that A(i) is not contained in A(h), test(i,h) >= 1. So if
    %test(i,h) == 0 and i~=h, row i must be removed.
    %reverse test row. If test(i,h) == 1 remove row i
    test = double(M==0)*double(M'~=0);
    test = double(test==0) - eye(size(test,1));

    %Now we see if there are no rows with the exact same row indexes
    test = (test - tril(test)')>0;

    M = [M sum(test,2)];
    M = sortrows(M,size(M,2));
    x = length(find(sum(test,2)));
    M = M(1:size(M,1)-x,1:size(M,2)-1);
end

function x = askinput(str,answers)
    x = input([str '\n'],'s');
    while ~ismember(x,answers)
        if length(x)>7 && isequal(x(1:6),'lookup')
            temp = x(8:end);
            load expa_elementary_data.mat
            pos = find(ismember(metabolites,temp));
            if ~isempty(pos)
                fprintf([formulas{pos} '    ' names{pos} '\n'])
            end
            clear metabolites names formulas
        elseif length(x)>7 && isequal(x,'printall')
            fprintf(['h2o, co2, o2, h2o2, nh4, no2, no3, no, h2s,\n'...
            'so3, so4, h, h2, pi, ppi, coa, accoa, ppcoa, aacoa,\n',...
            'butcoa, succoa, atp, gtp, adp, gdp, amp, gmp, nad,\n'...
            'nadp, nadh, nadph, fad, fadh, na1, ahcys, amet, thf, mlthf,\n'...
            'q8h2, q8, mql8, mqn8, 2dmmql8, 2dmmq8\n']);
        end
        x = input([str '\n'],'s');
    end
end

