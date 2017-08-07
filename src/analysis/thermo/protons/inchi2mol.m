function successbool = inchi2mol(inchis, filenames, outputdir, overwrite)
% Convert InChI strings to mol files using OpenBabel. Compatible with
% Windows and Unix.
%
% USAGE:
%
%    successbool = inchi2mol(inchis, filenames, outputdir, overwrite)
%
% INPUTS:
%    inchis:         `n x 1` Cell array of InChI strings
%    filenames:      `n x 1` Cell array of mol file names without file extension. Default is {'1' ;'2' ;...}
%    outputdir:      Directory for mol files. Default is 'CurrentDirectory\molfiles'.
%    overwrite:      0, [1]. Specify whether to overwrite existing mol files in outputdir.
%
% OUTPUTS:
%    successbool:    `n x 1` logical vector with 1 at indices corresponding to
%                    inchis that were successfully converted to mol files and 0 elsewhere.
%
% .. Author: - Hulda SH  Feb. 2011

if ~iscell(inchis) && size(inchis,1) == 1 % Format input and set defaults, If a single InChI is input as string
    inchis = {inchis};
end

if ~exist('filenames','var') || isempty(filenames) % Create cell array of default filenames
    filenames = 1:length(inchis);
    filenames = filenames';
    filenames = num2str(filenames);
    filenames = mat2cell(filenames,ones(1,size(filenames,1)),size(filenames,2));
    filenames = deblank(filenames);
end

if ~iscell(filenames) && size(filenames,1) == 1 % If a single file name is input as string
    filenames = {filenames};
end

if size(inchis) ~= size(filenames)
    error('inchis and filenames should be the same size.');
end

% Set other defaults
if ~exist('outputdir','var') || isempty(outputdir)
    if ~exist([pwd '\molfiles'],'dir')
        mkdir(pwd,'molfiles')
    end
    outputdir = [pwd '\molfiles'];
end

if ~exist('overwrite','var') || isempty(overwrite)
    overwrite = 0;
end

% Begin conversion
if ~exist('outputdir','dir') % Create output directory
    mkdir(outputdir)
end

system(['cd ' outputdir]); % Make OS cd to outputdir
cd(outputdir); % Make Matlab cd to outputdir

% List existing mol files in outputdir
d = dir(outputdir);
existingMolFiles = cat(2,d.name);
existingMolFiles = ['.mol' existingMolFiles];

nInchis = length(inchis);
successbool = false(nInchis,1);

for n = 1:nInchis
    if ~isempty(inchis{n})
        if isempty(strfind(existingMolFiles,['.mol' filenames{n} '.mol'])) || overwrite == 1 % If mol file of same name does not already exist or if it should be overwritten
            system(['echo ' inchis{n} ' > inchi.inchi']); % Temporary place holder for inchi. Overwritten in each loop.
            system(['babel inchi.inchi ' filenames{n} '.mol']); % Convert InChI to mol file

            f = dir([outputdir '\' filenames{n} '.mol']);
            if f.bytes > eps % If mol file is empty the conversion failed
                successbool(n) = true;
            else
                delete([outputdir '\' filenames{n} '.mol']) % Delete empty mol files
            end
        end
    end
end

delete([outputdir '\inchi.inchi'])
