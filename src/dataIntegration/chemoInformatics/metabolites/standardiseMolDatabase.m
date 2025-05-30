function standardisationReport = standardiseMolDatabase(molDir, metList, standardisedDir, standardisationApproach)
% Standardize an MDL MOL file directory by representing the reaction using 
% normal chemical graphs, hydrogen suppressed chemical graphs, and chemical 
% graphs with protonated molecules. The function also updates the header 
% with the standardization information. It makes use of ChemAxon's 
% standardizer and openBabel.
%
% USAGE:
%
% [standardised, nonStandardised, InChIs, SMILES] = standardiseMolDatabase(molDir, standardisedDir, standardiseMolFiles)
%
% INPUTS:
%    molDir:	Path to directory that contain the MDL MOL files
%                          to be standardised.
%
% OPTIONAL INPUTS:
%    metList: 1 x n lest of metabolites to standardise
%    standardisedDir: Path to directory that will contain the standardised 
%           MDL MOL files (default: current directory).
%    standardisationApproach: String contianing the type of standarization 
%           for the moldecules (default: 'explicitH' if openBabel is 
%           installed, otherwise 'basic')
%
%           'explicitH' - Normal chemical graphs.
%           'implicitH' - Hydrogen suppressed chemical graphs.
%           'neutral' - Neutral molecules
%           'basic' - Updating the header.
%
% OUTPUTS:
%    standardisationReport: Struct array with the standarization report:
%
%           * .standardised: list of standardised metabolite structures
%           * .nonStandardised: list of metabolite structures that were not
%                   standardised.
%           * .InChIs: list of InChIs from the obtained metabolite
%                   structures
%           * .SMILES: list of SMILES from the obtained metabolite
%                   structures
%           * .InChIKeys: list of InChIKeys from the obtained metabolite
%                   structures
%
%    A standardised molecular structures database
%
% .. Author: - German Preciat 25/06/2020


molDir = [regexprep(molDir,'(/|\\)$',''), filesep];
if nargin < 2 || isempty(metList)
    metList = [];
end
if nargin < 3 || isempty(standardisedDir)
    standardisedDir = [pwd filesep];
else
    % Make sure input path ends with directory separator
    standardisedDir = [regexprep(standardisedDir,'(/|\\)$',''), filesep];
end
% Check if openBabel is installed
if nargin < 4 || isempty(standardisationApproach)
    standardisationApproach = 'explicitH';
end

% Check if cxcalc and OpenBabel are installed
[cxcalcInstalled, ~] = system('cxcalc');
cxcalcInstalled = ~cxcalcInstalled;
if cxcalcInstalled == 0
    cxcalcInstalled = false;
end
if isunix || ispc 
    obabelCommand = 'obabel';
else
    obabelCommand = 'openbabel.obabel';
end
[oBabelInstalled, ~] = system(obabelCommand);
if any(oBabelInstalled == [127 0])
    oBabelInstalled = false;
    standardisationApproach = 'basic';
end

% Assign directories and create them
standardisedMolFiles = [standardisedDir 'molFiles' filesep];
if cxcalcInstalled
    standardisedImages = [standardisedDir 'images' filesep];
end
if ~exist(standardisedMolFiles, 'dir')
    mkdir(standardisedMolFiles)
    if cxcalcInstalled
        mkdir(standardisedImages)
    end
end

% do not standardize
moleculesNotS = {'nad.mol'; 'nadh.mol'; 'nadp.mol'; 'nadph.mol'};

% The new MOL files are readed
% Get list of MOL files
d = dir(molDir);
d = d(~[d.isdir]);
aMets = {d.name}';
aMets = aMets(~cellfun('isempty', regexp(aMets,'(\.mol)$')));        
if ~isempty(metList)
    aMets = aMets(ismember(regexprep(aMets, '.mol', ''), metList));
end
    
fprintf('\n Standardizing %d MOL files ... \n', size(aMets, 1));

y = 0;
n = 0;
nonStandardised = [];
InChIs = [];
InChIKeys = [];
for i = 1:size(aMets, 1)
%     try
        name = aMets{i};
        
        if oBabelInstalled
            
            % Obtain SMILES
            command = [obabelCommand ' -imol ' molDir name ' -osmiles'];
            [~, cmdout] = system(command);
            cmdout = splitlines(cmdout);
            cmdout = split(cmdout{end - 2});
            smiles = cmdout{1};
            SMILES{i, 1} = smiles;
            
            % Obtain inChIKey and InChI
            % inChIKey
            command = [obabelCommand ' -imol ' molDir name ' -oinchikey'];
            [~, cmdout] = system(command);
            cmdout = split(cmdout);
            inchikeyIdx = find(cellfun(@numel, cmdout) == 27);
            if ~isempty(inchikeyIdx)
                InChIKey = ['InChIKey=' cmdout{inchikeyIdx}];
                InChIKeys{i, 1} = InChIKey;
            else
                InChIKey = '';
                InChIKeys{i, 1} = {''};
            end
            % InChI
            command = [obabelCommand ' -imol ' molDir name ' -oinchi'];
            [~, cmdout] = system(command);
            cmdout = split(cmdout);
            if any(contains(cmdout,'InChI=1S'))
                InChIs{i, 1} = cmdout{contains(cmdout,'InChI=1S')};
                fid2 = fopen('tmp', 'w');
                fprintf(fid2, '%s\n', cmdout{contains(cmdout,'InChI=1S')});
                fclose(fid2);
                % Create an InChI based-MOL file
                if ~ismember(aMets{i}, moleculesNotS)
                    command = [obabelCommand ' -iinchi tmp -O ' standardisedMolFiles name ' --gen2D'];
                else
                    copyfile([molDir name], standardisedMolFiles)
                end
                [~, ~] = system(command);
                delete('tmp')
            else
                InChIs{i, 1} = {''};
                fid2 = fopen('tmp', 'w');
                fprintf(fid2, '%s\n', smiles);
                fclose(fid2);
                if ~ismember(aMets{i}, moleculesNotS)
                    command = [obabelCommand ' -ismiles tmp -O ' standardisedMolFiles name ' --gen2D'];
                else
                    copyfile([molDir name], standardisedMolFiles)
                end    
                [~, ~] = system(command);
                delete('tmp')
            end
            
            % Adapt database
            switch standardisationApproach
                case 'explicitH'
                    command = [obabelCommand ' -imol ' standardisedMolFiles name ' -O ' standardisedMolFiles name ' -h'];
                    [~, ~] = system(command);
                case 'implicitH'
                    % Delete explicit hydrogens
                    command = [obabelCommand ' -imol ' standardisedMolFiles name ' -O ' standardisedMolFiles name ' -d'];
                    [~, ~] = system(command);
                case 'neutral'
                    % Neutralize molecule
                    command = [obabelCommand ' -imol ' standardisedMolFiles name ' -O ' standardisedMolFiles name ' –neutralize'];
                    [~, ~] = system(command);
            end
        else
            
            InChIKey = '';
            copyfile([molDir name], standardisedMolFiles)
            
        end
        
        % Rewrite headings
        molFile = regexp(fileread([standardisedMolFiles name]), '\n', 'split')';
        molFile{1} = name(1:end-4);
        molFile{2} = ['COBRA Toolbox - ' standardisationApproach ' molecule - ' datestr(datetime)];
        molFile{3} = InChIKey;
        fid2 = fopen([standardisedMolFiles name], 'w');
        fprintf(fid2, '%s\n', molFile{:});
        fclose(fid2);
        % Generate images
        if cxcalcInstalled
            fdata = dir([standardisedMolFiles name]);
            command = ['molconvert jpeg:w' num2str(fdata.bytes / 2.5) ',h' num2str(fdata.bytes / 2.5) ' ' standardisedMolFiles name ' -o ' standardisedImages name(1:end-4) '.jpeg'];
            [~, ~] = system(command);
        end
        
        % Save data and delete the non-standardised molecule
        y = y + 1;
        standardised{y, 1} = name(1:end - 4);
        %     delete([molDir name])
        
%     catch
%         
%         % Save data in case it is not standardised
%         n = n + 1;
%         nonStandardised{n, 1} = name(1:end - 4);
%         
%     end
end

% Prepare report
standardisationReport.standardisationApproach = standardisationApproach;
standardisationReport.standardised = standardised;
standardisationReport.nonStandardised = nonStandardised;
if exist('InChIs', 'var')
    standardisationReport.InChIs = InChIs;
end
if exist('SMILES', 'var')
    standardisationReport.SMILES = SMILES;
end
if exist('InChIKeys', 'var')
    standardisationReport.InChIKeys = InChIKeys;
end

end