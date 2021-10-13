function generateTutorials(destinationFolder, method, varargin)
%convert .mlx files into .html and .pdf versions
%
%INPUT
% destinationFolder  path to the folder to put the html and pdf files
% varargin           names of specific tutorials

if ~exist('method')
    method ='BOTH';
end
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
else
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
    switch method
        case 'BOTH'
            showprogress(0, 'Generating HTML and PDF files ...');
        case 'PDF'
            showprogress(0, 'Generating PDF files ...');
        case 'HTML'
            showprogress(0, 'Generating HTML files ...');
    end
    
    for k = 1:totalNumberOfFiles
        fullFileName = fullfile(mlxFiles(k).folder, mlxFiles(k).name);
        mFileName = fullfile([mlxFiles(k).folder filesep mlxFiles(k).name(1:end-4) '.m']);
        [~, ~, ~] = mkdir([destinationFolder strrep(mlxFiles(k).folder, CBTDIR, '')]);
        fprintf('%s\n',fullFileName);
        switch method
            case 'BOTH'
                htmlFileName = [destinationFolder strrep(mlxFiles(k).folder, CBTDIR, '') filesep mlxFiles(k).name(1:end-4) '.html'];
                if ~exist(htmlFileName,'file')
                    openAndConvert(fullFileName, htmlFileName);
                end
                pdfFileName = [destinationFolder strrep(mlxFiles(k).folder, CBTDIR, '') filesep mlxFiles(k).name(1:end-4) '.pdf'];
                if ~exist(pdfFileName,'file')
                    openAndConvert(fullFileName, pdfFileName);
                end
                closeNoPrompt(matlab.desktop.editor.getAll)
            case 'HTML'
                htmlFileName = [destinationFolder strrep(mlxFiles(k).folder, CBTDIR, '') filesep mlxFiles(k).name(1:end-4) '.html'];
                if ~exist(htmlFileName,'file')
                    openAndConvert(fullFileName, htmlFileName);
                end
                closeNoPrompt(matlab.desktop.editor.getAll)
            case 'PDF'
                pdfFileName = [destinationFolder strrep(mlxFiles(k).folder, CBTDIR, '') filesep mlxFiles(k).name(1:end-4) '.pdf'];
                if ~exist(pdfFileName,'file')
                    openAndConvert(fullFileName, pdfFileName);
                end
                closeNoPrompt(matlab.desktop.editor.getAll)
        end
        % Note: for converting manually the .mlx files to a .m file, uncomment the following lines:
        % delete(mFileName)
        % openAndConvert(fullFileName, mFileName)
        
        showprogress(k / totalNumberOfFiles);
    end
else
    fprintf('%s\n',destinationFolder)
    fprintf(' > The tutorial folder does not contain any file.\n');
end
end
