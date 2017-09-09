function compatibleStatus = isCompatible(solverName, printLevel, specificSolverVersion)

    global CBTDIR

    % define a default printLevel
    if nargin < 2
        printLevel = 1;
    end

    % determine specific version
    if nargin < 3
        specificSolverVersion = '';
    end

    % define a false compatible status as default
    compatibleStatus = false;

    % check if the solver and the matlab version are compatible
    compatMatrixFile = [CBTDIR filesep 'docs' filesep 'source' filesep 'installation' filesep 'compatMatrix.md'];

    % read in the file with the compatibility matrix
    C = {};
    compatMatrix = {};
    fid = fopen(compatMatrixFile);
    while 1
        tline = fgetl(fid);
        if ~ischar(tline)
            break;
        end
        if length(tline) > 1
            if printLevel > 1
                disp(tline);
            end
            if strcmp(tline(1), '|')

                % split the line at the vertical bar
                Cpart = strsplit(tline, '|');
                Cpart = Cpart(2:end-1);

                % convert incompatible flag
                Cpart = strrep(Cpart, ':x:', '0');

                % convert compatible flag
                Cpart = strrep(Cpart, ':white_check_mark:', '1');

                C{end+1} = strtrim(Cpart);
            else
                if ~isempty(C)
                    compatMatrix{end+1} = C;
                    C = {};
                end
            end
        end
    end
    compatMatrix{end+1} = C;

    % select the compatibility matrix based on the OS
    if isunix
        compatMatrix = compatMatrix{1};
    else
        compatMatrix = compatMatrix{2};
    end

    compatMatlabVersions = compatMatrix{1};
    compatMatlabVersions = compatMatlabVersions(2:end);
    versionMatlab = ['R' version('-release')];

    colIndexVersion = strcmpi(versionMatlab, compatMatlabVersions);

    solverNameAlias = strrep(upper(solverName), '_', '');

    solverVersion = getCobraSolverVersion(solverName);

    % check compatibility of CPLEX
    for i = 1:length(compatMatrix)
        row = compatMatrix{i};
        solverNameRow = row{1};
        solverNameRow = upper(solverNameRow);
        solverNameRow = strrep(solverNameRow, ' ', '');
        solverNameRow = strrep(solverNameRow, '.', '');
        if strcmpi([solverNameAlias, solverVersion], solverNameRow)

            % retrieve the compatibility status from the table
            compatibilityBoolean = row{colIndexVersion + 1};

            % convert to boolean
            compatibilityBoolean = logical(compatibilityBoolean(:)' - '0');
            if compatibilityBoolean
                compatibleStatus = true;
                if printLevel > 0
                    fprintf([' > ', upper(solverName), ' (version ', solverVersion, ') is compatible with MATLAB ', versionMatlab, '.\n']);
                end
                break;
            else
                if printLevel > 0
                    fprintf([' > ', upper(solverName), ' (version ', solverVersion, ') is NOT compatible with MATLAB ', versionMatlab, '.\n']);
                end
            end
        end
    end

end