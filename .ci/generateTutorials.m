function generateTutorials(destinationFolder)

global CBTDIR

import matlab.internal.*

if ~isempty(strfind(version, 'R2016b'))
    openAndConvert = @matlab.internal.richeditor.openAndConvert;
end 
if ~isempty(strfind(version, 'R2017b'))
    openAndConvert = @matlab.internal.liveeditor.openAndConvert;
end 
[status, msg, msgID] = mkdir(destinationFolder);

% Gather all MLX files in the tutorials folder
mlxFiles = dir([CBTDIR filesep 'tutorials' filesep '**' filesep '*.mlx']);
totalNumberOfFiles = length(mlxFiles);

if totalNumberOfFiles >= 1
    % Go through all MLX files
    showprogress(0, 'Generating HTML and PDF files ...');
	for k = 1:totalNumberOfFiles
        showprogress(k / totalNumberOfFiles);
        fullFileName = fullfile(mlxFiles(k).folder, mlxFiles(k).name);
        [status, msg, msgID] = mkdir([destinationFolder strrep(mlxFiles(k).folder, CBTDIR, '')]);
        openAndConvert(fullFileName, [destinationFolder strrep(mlxFiles(k).folder, CBTDIR, '') filesep mlxFiles(k).name(1:end-4) '.html'])
        openAndConvert(fullFileName, [destinationFolder strrep(mlxFiles(k).folder, CBTDIR, '') filesep mlxFiles(k).name(1:end-4) '.pdf'])
    end
else
	fprintf(' > The tutorial folder does not contain any file.\n');
end