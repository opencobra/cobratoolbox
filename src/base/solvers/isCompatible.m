function compatibleStatus = isCompatible(solverName, printLevel)

    global CBTDIR

    % define a default printLevel
    if nargin < 2
        printLevel = 0;
    end

    % define a false compatible status as default
    compatibleStatus = false;

    % read in the file with the compatibility matrix

    % retrieve the matlab version
    matlabVersion = version('-release');

    % check if the solver and the matlab version are compatible
    compatMatrixFile = [CBTDIR filesep 'docs' filesep 'source' filesep 'installation' filesep 'compatMatrix.md'];

    %{
        fid = fopen(compatMatrixFile);
        N = 11; % number of columns
        C_text = textscan(fid,'%s',N,'Delimiter','|');
        C_data1 = textscan(fid,[repmat('%s',[1,N-1])],'CollectOutput',1,'Delimiter','|')
        tableData = C_data1{1};
        headerData = C_text{1};
        headerData = headerData(3:end-1);
    %}
    C = {};
    compatMatrix = {};
    fid = fopen(compatMatrixFile);
    while 1
        tline = fgetl(fid);
        if ~ischar(tline)
            break;
        end
        if length(tline) > 1
        %disp(tline)
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
    %keyboard
    compatMatlabVersions = compatMatrix{1};
    compatMatlabVersions = compatMatlabVersions(2:end);
    versionMatlab = ['R' version('-release')];

    colIndexVersion = strmatch(versionMatlab, compatMatlabVersions);

    %solverName = 'gurobi';
    solverNameAlias = strrep(upper(solverName), '_', '');

    solverVersion = getCobraSolverVersion(solverName);

    % check compatibility of CPLEX
    for i = 1:length(compatMatrix)
        row = compatMatrix{i};
        solverNameRow = row{1};
        solverNameRow = upper(solverNameRow);
        solverNameRow = strrep(solverNameRow, ' ', '');
        solverNameRow = strrep(solverNameRow, '.', '');
        comaptibilityBoolean = row{colIndexVersion};
        if strcmpi([solverNameAlias, solverVersion], solverNameRow)
            if comaptibilityBoolean
                compatibleStatus = true;
                fprintf([' > ', upper(solverName), ' (version ', solverVersion, ') is compatible with MATLAB ', versionMatlab, '.\n']);
                break;
            end
        end
    end

    % return the compatibility status
    if printLevel > 0
        fprintf(['The selected solver ', solverName, ' and this MATLAB version (', matlabVersion, ') are not compatible. Please select a compatible pair.\n']);
    end

end