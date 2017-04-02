function lrsInput(A, D, filename, positivity, inequality, a, d, f, sh)
% output a file for lrs to convert an H-representation (half-space) of a
% polyhedron to a V-representation (vertex/ray) via vertex enumeration
%
% INPUT
% A          matrix of linear equalities A*x=(a)
% D          matrix of linear inequalities D*x>=(d)
% filename   base name of output file
%
% OPTIONAL INPUT
% positivity {0,(1)} if positivity==1, then positive orthant base
% inequality {0,(1)} if inequality==1, then use two inequalities rather than a single equaltiy
% a          boundry values for matrix of linear equalities A*x=a
% d          boundry values for matrix of linear inequalities D*x>=d
% f          linear objective for a linear optimization problem in rational arithmetic
%            minimise     f'*x
%            subject to   A*x=(a)
%                         D*x>=(d)
% sh         {(0),1} if sh==1, output a shell script for submitting qsub job

if ~isempty(A)
    [rlt, clt] = size(A);
else
    rlt = 0;
    clt = 0;
end

% OPTION
% if a does not exist we assume A*x=0;
if exist('a') ~= 1
    a = zeros(rlt, 1);
elseif ~all(size(a) == [rlt, 1])
    error('Matrix A and vector a should have the same number of rows');
end
if ~isempty(D)
    [Drlt, Dclt] = size(D);
    % if d does not exist we assume D*x>=0;
    if exist('d') ~= 1
        d = zeros(Drlt, 1);
    end
else
    Drlt = 0;
    Dclt = 0;
end

if exist('positivity') ~= 1
    positivity = 1;
end
if exist('inequality') ~= 1
    inequality = 1;
end
if exist('sh') ~= 1
    sh = 0;
end
if exist('f') ~= 1
    f = [];
end

% if inequality==1, then use two inequalities rather than a single equaltiy
if inequality == 0
    if positivity == 1
        filenameSuffix = [filename '_pos_eq'];
        filenameFull = [filenameSuffix '.ine'];
    else
        filenameSuffix = [filename '_neg_eq'];
        filenameFull = [filenameSuffix '.ine'];
    end

    fid = fopen(filenameFull, 'w');
    fprintf(fid, '%s\n%s\n', filename, 'H-representation');

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
        if positivity == 1
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
            if positivity == 1
                % number of rows & another set of rows for each inequality if it's
                % to be positive
                fprintf(fid, '%s%s', int2str(rlt + Drlt + clt), ' ');
            else
                % number of rows
                fprintf(fid, '%s%s', int2str(rlt + Drlt), ' ');
            end
        else
            if positivity == 1
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
        if positivity == 1
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
        if positivity == 1
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
    if positivity == 1
        filenameSuffix = [filename '_pos_ineq'];
        filenameFull = [filenameSuffix '.ine'];
    else
        filenameSuffix = [filename '_neg_ineq'];
        filenameFull = [filenameSuffix '.ine'];
    end
    fid = fopen(filenameFull, 'w');
    fprintf(fid, '%s\n%s\n', filename, 'H-representation');

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
    if positivity == 1
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

if sh == 1
    filenameSh = [filenameSuffix '.sh'];
    fid = fopen(filenameSh, 'w');
    fprintf(fid, '%s\n', '#!/bin/bash');
    fprintf(fid, '%s\n', ['(time lrs ' filenameSuffix '.ine > /nas/rfleming/' filenameSuffix '.ext) 2> ' filenameSuffix '.time']);
    fclose(fid);
end
