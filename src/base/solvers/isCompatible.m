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

    % default compatibility status
    compatibleStatus = -1;

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

                % convert untested flag
                Cpart = strrep(Cpart, ':warning:', '-1');

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

    % determine the version of MATLAB and the corresponding column
    compatMatlabVersions = compatMatrix{1};
    compatMatlabVersions = compatMatlabVersions(2:end);
    versionMatlab = ['R' version('-release')];
    colIndexVersion = strmatch(versionMatlab, compatMatlabVersions);

    % replace any underscores in the solvername
    solverNameAlias = strrep(upper(solverName), '_', '');

    % set the solver version to be checked
    if exist('specificSolverVersion', 'var') && ~isempty(specificSolverVersion)
        solverVersion = strrep(specificSolverVersion, '.', '');
    else
        solverVersion = getCobraSolverVersion(solverName);
    end

    % check compatibility of solver
    for i = 1:length(compatMatrix)
        row = compatMatrix{i};

        % determine the name of the solver
        solverNameRow = row{1};
        solverNameRow = upper(solverNameRow);
        solverNameRow = strrep(solverNameRow, ' ', '');
        solverNameRow = strrep(solverNameRow, '.', '');

        % find the correct row
        if strcmpi([solverNameAlias, solverVersion], solverNameRow)

            % retrieve the compatibility status from the table
            compatibilityBoolean = row{colIndexVersion + 1};

            % determine the compatibility status
            if strcmpi(compatibilityBoolean, '1')
                compatibleStatus = 1;
                if printLevel > 0
                    fprintf([' > ', upper(solverName), ' (version ', solverVersion, ') is compatible with MATLAB ', versionMatlab, '.\n']);
                end
            elseif strcmp(compatibilityBoolean, '0')
                compatibleStatus = 0;
                if printLevel > 0
                    fprintf([' > ', upper(solverName), ' (version ', solverVersion, ') is NOT compatible with MATLAB ', versionMatlab, '.\n']);
                end
            else
                compatibleStatus = -1;
                if printLevel > 0
                    fprintf([' > The compatibility of ', upper(solverName), ' (version ', solverVersion, ') is not tested with MATLAB ', versionMatlab, '.\n']);
                end
            end
        end
    end
end