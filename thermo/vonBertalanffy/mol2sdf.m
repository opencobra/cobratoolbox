function metList = mol2sdf(mets,molfileDir,sdfFileName,includeRs)
% Concatenates molfiles in molfileDir into one SDF file.
% 
% metList = mol2sdf(mets,molfileDir,sdfFileName)
%
% INPUTS
% mets              mx1 cell array of metabolite identifiers (e.g., BiGG
%                   abbreviations)
% molfileDir        Path to directory containing molfiles for metabolites
%                   in mets. Molfile names should match the metabolite
%                   identifiers in mets without compartment assignments.
% 
% OPTIONAL INPUTS
% sdfFileName       Name of SDF file. Default is MetStructures.sdf.
% includeRs         {0,(1)}. If 0, variable structures such as R groups and
%                   repeat units will not be included in SDF.
%
% OUTPUTS
% metList           Cell array listing metabolites in SDF.
%
% WRITTEN OUTPUTS
% sdfFileName.sdf   SDF with metabolite structures in same order as in
%                   metList. Metabolite identifiers in the SDF are the same
%                   as in MetList. 
%
% Ronan M.T. Fleming
% Hulda SH, Nov. 2012   Changed output format from CDF to SDF. Renamed
%                       function. Simplified code.

% Format inputs
if ~strcmp(molfileDir(end),filesep)
    molfileDir = [molfileDir filesep];
end

if ~exist('sdfFileName','var')
    sdfFileName = 'MetStructures.sdf';
end
if isempty(sdfFileName)
    sdfFileName = 'MetStructures.sdf';
end
if ~strcmp(sdfFileName(end-3:end),'.sdf')
    sdfFileName = [sdfFileName '.sdf'];
end

mets = reshape(mets,length(mets),1);
omets = mets; % store original metabolite identifiers
if ischar(mets)
    mets = strtrim(cellstr(mets));
end
if isnumeric(mets)
    mets = strtrim(cellstr(num2str(mets)));
end
mets = regexprep(mets,'(\[\w\])$',''); % Remove compartment assignment

if ~exist('includeRs','var')
    includeRs = 1;
end

% List all molfiles in molfile directory
d = dir(molfileDir);
dirbool = cat(1,d.isdir);
d = d(~dirbool);
molfileNames = {d.name};
molfileNames = regexprep(molfileNames,'(\.mol)$','');

molfileNames = molfileNames(ismember(molfileNames,mets)); % Only include molfiles for metabolites in mets

metList = molfileNames;

% List all elements
elements = {'H', 'He', 'Li', 'Be', 'B', 'C', 'N', 'O', 'F', 'Ne', 'Na', 'Mg', 'Al', 'Si', 'P', 'S', 'Cl', 'Ar', 'K', 'Ca',...
            'Sc', 'Ti', 'V', 'Cr', 'Mn', 'Fe', 'Co', 'Ni', 'Cu', 'Zn', 'Ga', 'Ge', 'As', 'Se', 'Br', 'Kr', 'Rb', 'Sr', 'Y',...
            'Zr', 'Nb', 'Mo', 'Tc', 'Ru', 'Rh', 'Pd', 'Ag', 'Cd', 'In', 'Sn', 'Sb', 'Te', 'I', 'Xe', 'Cs', 'Ba', 'La', 'Ce',...
            'Pr', 'Nd', 'Pm', 'Sm', 'Eu', 'Gd', 'Tb', 'Dy', 'Ho', 'Er', 'Tm', 'Yb', 'Lu', 'Hf', 'Ta', 'W', 'Re', 'Os', 'Ir',...
            'Pt', 'Au', 'Hg', 'Tl', 'Pb', 'Bi', 'Po', 'At', 'Rn', 'Fr', 'Ra', 'Ac', 'Th', 'Pa', 'U', 'Np', 'Pu', 'Am', 'Cm',...
            'Bk', 'Cf', 'Es', 'Fm', 'Md', 'No', 'Lr', 'Rf', 'Db', 'Sg', 'Bh', 'Hs', 'Mt', 'Ds', 'Rg', 'Cn', 'Uut', 'Fl', 'Uup', 'Lv', 'Uus', 'Uuo'};

% Concatenate molfiles into single SDF file
fid = fopen(sdfFileName,'w+'); % Create SDF
first = true;
for m = 1:length(molfileNames)
    molfile = fileread([molfileDir molfileNames{m} '.mol']); % Read in molfile
    molfile = reshape(molfile, 1, length(molfile)); % for compatibility with Octave (where fileread returns a column vector of chars)
    molfile = regexprep(molfile,'\r',''); % Remove carriage returns
    molfile = regexprep(molfile,'[^\n]*\n',sprintf('%s\n',molfileNames{m}),'once'); % Replace top line with metabolite identifier
    molfile = regexprep(molfile,'\n+$',''); % Ensure there is only one newline caracter at end of each molfile in the SDF
    
    if includeRs == 0
        % Get atom list
        lines = regexp(molfile,'\n','split');
        atomCount = str2double(lines{4}(1:3));
        if atomCount > 0
            atomBlock = lines(5:5 + atomCount - 1);
            pat = '[^a-z_A-z\*]+(?<atom>[a-z_A-Z\*]+)[^a-z_A-z\*]+';
            atoms = regexp(atomBlock,pat,'names');
            atoms = [atoms{:}]';
            atoms = {atoms.atom}';
            
            % If structure contains a non-elemental atom or repeat units it
            % will not be appended to SDF
            if ~all(ismember(atoms,elements)) || ~isempty(strmatch('M  STY',lines))
                metList = setdiff(metList,molfileNames{m});
                continue;
            end
        end
    end
    
    % Add molfile to SDF
    if first
        fprintf(fid,'%s\n',molfile);
        first = false;
    else
        fprintf(fid,'%s\n','$$$$');
        fprintf(fid,'%s\n',molfile);
    end
end
fclose(fid);

noMolFileCount = sum(~ismember(mets,molfileNames));
fprintf('Percentage of metabolites without mol files: %.1f%%\n', 100*noMolFileCount/length(mets));

metList = reshape(metList,length(metList),1);
if isnumeric(omets)
    metList = str2double(metList);
end




