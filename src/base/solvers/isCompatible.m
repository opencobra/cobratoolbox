function compatibleStatus = isCompatible(solverName, printLevel, specificSolverVersion)
% determine the compatibility status of a solver based on the file compatMatrix.md
%
% USAGE:
%    compatibleStatus = isCompatible(solverName, printLevel, specificSolverVersion)
%
% INPUT:
%    solverName:            Name of the solver
%    printLevel:            verbose level (default: 0)
%    specificSolverVersion: string with specific solver version (example: '12.7.1' or '6.5.1')
%
% OUTPUT:
%    compatibleStatus:      compatibility status
%
%                             * 1:  compatible with the COBRA Toolbox (tested)
%                             * 0:  not compatible with the COBRA Toolbox (tested)
%                             * -1: unverified compatibility with the COBRA Toolbox (not tested)
%
% .. Author: - Laurent Heirendt, August 2017
%

    global CBTDIR

    % define a default printLevel
    if nargin < 2
        printLevel = 1;
    end

    % determine specific version
    if nargin < 3
        specificSolverVersion = '';
    end

    % define the same interface for tomlab and quadMinos
    if strcmp(solverName, 'tomlab_snopt')
        solverName = 'tomlab_cplex';
    end

    if strcmp(solverName, 'quadMinos')
        solverName = 'dqqMinos';
    end

    if strcmp(solverName, 'lindo_old')
        solverName = 'lindo_legacy';
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
        if ~ischar(tline), break; end

        % if the line is not empty, read it in
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
    if isunix && ~ismac
        compatMatrix = compatMatrix{1}; % linux
    elseif ismac
        compatMatrix = compatMatrix{2}; % macOS
    else
        compatMatrix = compatMatrix{3}; % Windows
    end

    % determine the version of MATLAB and the corresponding column
    compatMatlabVersions = compatMatrix{1}(2:end);
    versionMatlab = ['R' version('-release')];
    colIndexVersion = strmatch(versionMatlab, compatMatlabVersions);

    % any MATLAB version that is not explicitly supported yields a compatibility status of -1
    if isempty(colIndexVersion)
        compatibleStatus = -1;
        if printLevel > 0
            fprintf([' > The solver compatibility is not tested with MATLAB ', versionMatlab, '.\n']);
        end
    else
        % replace any underscores in the solvername
        solverNameAlias = strrep(upper(solverName), '_', '');

        % set the solver version to be checked
        if exist('specificSolverVersion', 'var') && ~isempty(specificSolverVersion)
            solverVersion = strrep(specificSolverVersion, '.', '');
        else
            solverVersion = getCobraSolverVersion(solverName, 0);
        end

        % check compatibility of solver
        for i = 1:length(compatMatrix)
            % save the row of the compatibilitx matrix
            row = compatMatrix{i};

            % determine the name of the solver
            solverNameRow = row{1};
            solverNameRow = upper(solverNameRow);
            solverNameRow = regexprep(solverNameRow, {'\ ', '\.'}, '');

            % find the correct row
            if strcmpi([solverNameAlias, solverVersion], solverNameRow)
                % retrieve the compatibility status from the table
                compatibilityBoolean = row{colIndexVersion + 1};

                % define output of solverVersion
                if ~isempty(solverVersion),
                    txtSolverVersion = [' (version ', solverVersion, ')'];
                else
                    txtSolverVersion = '';
                end

                % determine the compatibility status
                if strcmpi(compatibilityBoolean, '1')
                    compatibleStatus = 1;
                    if printLevel > 0
                        fprintf([' > ', lower(solverName), txtSolverVersion, ' is compatible and fully tested with MATLAB ', versionMatlab, '.\n']);
                    end
                elseif strcmpi(compatibilityBoolean, '0')
                    compatibleStatus = 0;
                    if printLevel > 0
                        fprintf([' > ', lower(solverName), txtSolverVersion, ' is NOT compatible with MATLAB ', versionMatlab, '.\n']);
                    end
                else
                    compatibleStatus = -1;
                    if printLevel > 0
                        fprintf([' > The compatibility of ', upper(solverName), txtSolverVersion, ' is not fully tested and might not be compatible with MATLAB ', versionMatlab, '.\n']);
                    end
                end
            end
        end
    end

    % special case: cplex_direct
    if strcmp(solverName, 'cplex_direct') && ~verLessThan('matlab', '8.4')
        compatibleStatus = 0;
        if printLevel > 0
            fprintf([' > ', 'cplex_direct is NOT compatible with MATLAB ', versionMatlab, '. Try using the tomlab_cplex interface.\n']);
        end
    end
end
