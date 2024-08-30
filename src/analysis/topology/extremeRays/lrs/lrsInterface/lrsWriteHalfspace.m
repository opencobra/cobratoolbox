function fileNameOut = lrsWriteHalfspace(A, b, csense, modelName, param)
% Outputs a file for lrs to convert an H-representation (half-space) of a
% polyhedron to a V-representation (vertex / ray) via vertex enumeration
%
% USAGE:
%
%    lrsWriteHalfspace(A, b, csense, modelName, param)
%
% INPUTS:
%    A:             m x n matrix of linear constraints :math:`A x (csense) b`
%
% OPTIONAL INPUTS:
%    b:             m x 1 rhs of linear constraints
%    csense:        m x 1 char with ('E'),'G' or 'L'
%    modelName:     name of the model to be used when generating filenames, 'model' by default
%    param.positivity:    {0, (1)} if positivity == 1, then positive orthant base
%    param.inequality:    {0, (1)} if inequality == 1, then use two inequalities rather than a single equaltiy

%    f:             linear objective for a linear optimization problem in rational arithmetic
%
%                   minimise :math:`f^T x`,
%                   subject to :math:`A x = (a)`, :math:`D x \geq (d)`
%    sh:            {(0), 1} if `sh == 1`, output a shell script for submitting qsub job

% Ronan Fleming 2021

if ~exist('b','var') || isempty(b)
    b = zeros(size(A,1),1);
end
if ~exist('csense','var') || isempty(csense)
    csense(1:size(A,1),1) = 'E';
end
if ~exist('modelName','var')
    modelName = 'test';
end
if ~exist('param','var')
    param = struct();
end
if ~isfield(param,'positivity')
    param.positivity = 0;
end
if ~isfield(param,'inequality')
    param.positivity = 0;
end
if ~isfield(param,'sh')
    param.sh = 0;
end

if exist('f','var') ~= 1
    f = [];
end

if length(csense)~=size(A,1)
    error('csense must equal the number of rows of A')
end


eqBool = csense == 'E';
leBool = csense == 'L';
geBool = csense == 'G';
if ~all(eqBool | leBool | geBool)
    error('mis-specified csense')
end
A0  = A;
b0 = b;

A = A(eqBool,:);
a = b0(eqBool);

A0(leBool,:) = -A0(leBool,:);
b0(leBool,:) = -b0(leBool,:);

D = A0(leBool | geBool,:);
d = b0(leBool | geBool);

if ~isempty(A)
    [rlt, clt] = size(A);
else
    rlt = 0;
    clt = 0;
end

if ~contains(modelName,filesep)
    modelName = [pwd filesep modelName];
end

if param.inequality == 0
%     if param.positivity == 0
%         modelName = [modelName '_pos_eq'];
%     else
%         modelName = [modelName '_neg_eq'];
%     end
else
    if param.positivity == 1
        modelName = [modelName '_pos_ineq'];
    else
        modelName = [modelName '_neg_ineq'];
    end
end
fileNameOut = [modelName '.ine'];


% if inequality==1, then use two inequalities rather than a single equaltiy
if param.inequality == 0
    fid = fopen(fileNameOut, 'w');
    fprintf(fid, '%s\n%s\n', modelName, 'H-representation');

    if ~isempty(f)
        fprintf(fid, '%s\n', 'lponly');
        fprintf(fid, '%s', 'minimize ');
        fprintf(fid, '%s', int2str(0));
        for c = 2:clt
            fprintf(fid, '%s%s', int2str(f(c)), ' ');
        end
        fprintf(fid, '\n');
    end

    if ~isempty(A)
        % equality representation
        fprintf(fid, '%s', 'linearity ');
        fprintf(fid, '%s', int2str(rlt));
        fprintf(fid, '%s', ' ');
        for r = 1:rlt - 1
            fprintf(fid, '%s%s', int2str(r), ' ');
        end
        fprintf(fid, '%s\n', int2str(rlt));
    end

    % check if inequalities
    if isempty(D)
        fprintf(fid, '%s\n', 'begin');
        if param.positivity == 1
            % number of rows & another set of rows for each inequality if it's
            % to be positive
            fprintf(fid, '%s%s', int2str(rlt + clt), ' ');
        else
            % number of rows
            fprintf(fid, '%s%s', int2str(rlt), ' ');
        end
    else
        [Drlt, Dclt] = size(D);
        fprintf(fid, '%s\n', 'begin');
        if ~isempty(A)
            if param.positivity == 1
                % number of rows & another set of rows for each inequality if it's
                % to be positive
                fprintf(fid, '%s%s', int2str(rlt + Drlt + clt), ' ');
            else
                % number of rows
                fprintf(fid, '%s%s', int2str(rlt + Drlt), ' ');
            end
        else
            if param.positivity == 1
                % number of rows & another set of rows for each inequality if it's
                % to be positive
                fprintf(fid, '%s%s', int2str(Drlt + clt), ' ');
            else
                % number of rows
                fprintf(fid, '%s%s', int2str(Drlt), ' ');
            end
        end
    end

    if ~isempty(A)
        % number of columns & zero column as we have -a+A.v=0
        fprintf(fid, '%s%s%s\n', int2str(clt + 1), ' ', 'integer');
        for r = 1:rlt
            % equality constraint
            % each row preceded by column a as we have A.v=a
            fprintf(fid, '%s%s', int2str(-a(r, 1)), ' ');
            for c = 1:clt - 1
                fprintf(fid, '%s%s', int2str(A(r, c)), ' ');
            end
            fprintf(fid, '%s\n', int2str(A(r, clt)));
        end
        if ~isempty(D)
            % more complicated inequalities
            for r = 1:Drlt
                % inequality constraint
                % each row preceded by column -d as we have D.x>=d
                fprintf(fid, '%s%s', int2str(-d(r, 1)), ' ');
                for c = 1:Dclt - 1
                    fprintf(fid, '%s%s', int2str(D(r, c)), ' ');
                end
                fprintf(fid, '%s\n', int2str(D(r, Dclt)));
            end
        end
    else
        % number of columns & zero column as we have -d+D.v.>=0
        fprintf(fid, '%s%s%s\n', int2str(Dclt + 1), ' ', 'integer');
        % more complicated inequalities
        for r = 1:Drlt
            % inequality constraint
            % each row preceded by column -d as we have D.x>=d
            fprintf(fid, '%s%s', int2str(-d(r, 1)), ' ');
            for c = 1:Dclt - 1
                fprintf(fid, '%s%s', int2str(D(r, c)), ' ');
            end
            fprintf(fid, '%s\n', int2str(D(r, Dclt)));
        end
    end

    if ~isempty(A)
        % non-negative variable inequalities
        if param.positivity == 1
            % add non-negative constraints individually
            for c1 = 1:clt
                fprintf(fid, '%s%s', int2str(0), ' ');
                for c2 = 1:clt - 1
                    if c2 == c1
                        fprintf(fid, '%s%s', int2str(1), ' ');
                    else
                        fprintf(fid, '%s%s', int2str(0), ' ');
                    end
                end
                c2 = c2 + 1;
                if c2 == c1
                    fprintf(fid, '%s\n', int2str(1));
                else
                    fprintf(fid, '%s\n', int2str(0));
                end
            end
        end
    else
        % non-negative variable inequalities
        if param.positivity == 1
            % add non-negative constraints individually
            for c1 = 1:Dclt
                fprintf(fid, '%s%s', int2str(0), ' ');
                for c2 = 1:Dclt - 1
                    if c2 == c1
                        fprintf(fid, '%s%s', int2str(1), ' ');
                    else
                        fprintf(fid, '%s%s', int2str(0), ' ');
                    end
                end
                c2 = c2 + 1;
                if c2 == c1
                    fprintf(fid, '%s\n', int2str(1));
                else
                    fprintf(fid, '%s\n', int2str(0));
                end
            end
        end
    end

else
    % use two inequalities rather than a single equality
    if ~isempty(A)
        fprintf('%s\n', 'We assume that equalities are present.');
    end

    fid = fopen(fileNameOut, 'w');
    fprintf(fid, '%s\n%s\n', modelName, 'H-representation');

    if ~isempty(f)
        fprintf(fid, '%s\n', 'lponly');
        fprintf(fid, '%s', 'minimize ');
        fprintf(fid, '%s', int2str(0));
        for c = 1:clt
            fprintf(fid, '%s%s', int2str(f(c)), ' ');
        end
        fprintf(fid, '\n');
    end

    % For problems where all variables non-negative and all constraints
    % are inequalities it is not necessary to give the non-negative
    % constraints explicitly if the nonnegative option is used. -lrs 4.2
    if param.positivity == 1
        fprintf(fid, '%s\n', 'nonnegative ');
    end

    % check if inequalities
    if isempty(D)
        fprintf(fid, '%s\n', 'begin');
        % number of rows
        fprintf(fid, '%s%s', int2str(rlt * 2), ' ');
    else
        [Drlt, Dclt] = size(D);
        fprintf(fid, '%s\n', 'begin');
        % number of rows
        fprintf(fid, '%s%s', int2str(rlt * 2 + Drlt), ' ');
    end

    % number of columns & extra a column for A.x=a
    fprintf(fid, '%s%s%s\n', int2str(clt + 1), ' ', 'integer');

    for r = 1:rlt
        % having two conjugate sign changes inequalities is faster than a single
        % equality.
        % each row preceded by a, -a + A*x >=0
        fprintf(fid, '%s%s', int2str(-a(r, 1)), ' ');
        for c = 1:clt - 1
            fprintf(fid, '%s%s', int2str(A(r, c)), ' ');
        end
        fprintf(fid, '%s\n', int2str(A(r, clt)));

        % sign changed inequality
        % each row preceded by a, a - A*x >= 0
        fprintf(fid, '%s%s', int2str(a(r, 1)), ' ');
        for c = 1:clt - 1
            fprintf(fid, '%s%s', int2str(A(r, c) * -1), ' ');
        end
        fprintf(fid, '%s\n', int2str(A(r, clt) * -1));
    end
    % more complicated inequalities
    if ~isempty(D)
        for r = 1:Drlt
            % inequality constraint
            % each row preceded by column d as we have D.x>=d
            fprintf(fid, '%s%s', int2str(-d(r)), ' ');
            for c = 1:Dclt - 1
                fprintf(fid, '%s%s', int2str(D(r, c)), ' ');
            end
            fprintf(fid, '%s\n', int2str(D(r, Dclt)));
        end
    end
end
fprintf(fid, '%s\n', 'end');
fclose(fid);

if param.sh == 1
    filenameSh = [filenameSuffix '.sh'];
    fid = fopen(filenameSh, 'w');
    fprintf(fid, '%s\n', '#!/bin/bash');
    fprintf(fid, '%s\n', ['(time lrs ' filenameSuffix '.ine > /nas/rfleming/' filenameSuffix '.ext) 2> ' filenameSuffix '.time']);
    fclose(fid);
end
