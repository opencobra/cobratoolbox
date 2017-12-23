function generateTutorials(destinationFolder, varargin)

    import matlab.internal.*

    p = inputParser;
    addRequired(p, 'destinationFolder', @ischar);
    addOptional(p, 'specificTutorial', '', @ischar);
    parse(p, destinationFolder, varargin{:});
    specificTutorial = p.Results.specificTutorial;

    global CBTDIR
    if isempty(CBTDIR)
        initCobraToolbox
    end

    if strcmp(version('-release'), '2016b')
        openAndConvert = @matlab.internal.richeditor.openAndConvert;
    end
    if strcmp(version('-release'), '2017b')
        openAndConvert = @matlab.internal.liveeditor.openAndConvert;
    end
    [~, ~, ~] = mkdir(destinationFolder);

    % Gather MLX files in the tutorials folder
    if isempty(specificTutorial)
        mlxFiles = dir([CBTDIR filesep 'tutorials' filesep '**' filesep '*.mlx']);
    else
        mlxFiles = dir([CBTDIR filesep 'tutorials' filesep '**' filesep 'tutorial_' specificTutorial '.mlx']);
    end

    toBeKept = [];
    for k = 1:length(mlxFiles)
        if isempty(strfind(mlxFiles(k).folder, 'additionalTutorials'))
           toBeKept = [toBeKept, k];
        end
    end
    mlxFiles = mlxFiles(toBeKept);

    totalNumberOfFiles = length(mlxFiles);

    if totalNumberOfFiles >= 1
        % Go through all MLX files
        showprogress(0, 'Generating HTML and PDF files ...');
        for k = 1:totalNumberOfFiles
            fullFileName = fullfile(mlxFiles(k).folder, mlxFiles(k).name);
            [~, ~, ~] = mkdir([destinationFolder strrep(mlxFiles(k).folder, CBTDIR, '')]);
            openAndConvert(fullFileName, [destinationFolder strrep(mlxFiles(k).folder, CBTDIR, '') filesep mlxFiles(k).name(1:end-4) '.html'])
            showprogress(k / totalNumberOfFiles);
        end
    else
        fprintf(' > The tutorial folder does not contain any file.\n');
    end
end
