% Define the input and output directories relative to MATLAB Drive
inputDir = fullfile('MATLAB Drive', 'downloaded_mlx_files');
outputDir = fullfile('MATLAB Drive', 'pdf_results');

% Create the output directory if it doesn't exist
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Get a list of all .mlx files in the input directory
mlxFiles = dir(fullfile(inputDir, '*.mlx'));

% Loop through each .mlx file and convert to PDF
for i = 1:length(mlxFiles)
    % Get the full absolute path of the .mlx file
    mlxFilePath = fullfile(mlxFiles(i).folder, mlxFiles(i).name);
    
    % Define the output PDF file name and path
    [~, fileName, ~] = fileparts(mlxFiles(i).name);
    pdfFilePath = fullfile(outputDir, [fileName, '.pdf']);
    
    % Convert the .mlx file to PDF
    matlab.internal.liveeditor.openAndConvert(mlxFilePath, pdfFilePath);
    
    % Display a message to indicate successful conversion
    fprintf('Converted %s to PDF and saved as %s\n', mlxFiles(i).name, pdfFilePath);
end

% Final message indicating the script has completed
fprintf('Conversion of all .mlx files to PDF is complete.\n');
