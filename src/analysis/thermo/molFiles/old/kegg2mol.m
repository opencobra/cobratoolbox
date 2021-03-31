function kegg2mol(cid,molfileDir,mets,takeMajorMS,pH,takeMajorTaut)
% Retreive molfiles from the KEGG Compound database.
% 
% kegg2mol(cid,molfileDir,mets,takeMajorMS,pH,takeMajorTaut)
% 
% INPUTS
% cid               m x 1 array of KEGG Compound identifiers.
% 
% OPTIONAL INPUTS
% molfileDir        Path to directory where molfiles will be saved. Default
%                   is molfilesFromKegg.
% mets              m x 1 array of metabolite identifiers. Used to name
%                   molfiles. KEGG Compound ID will be used if mets is
%                   omitted. 
% takeMajorMS       {(0),1}. If 0 (default), molfiles will be downloaded
%                   directly from KEGG. If 1, they will save as the major
%                   microspecies at the pH specified in input variable pH.
%                   Computing major microspecies requires ChemAxon's
%                   calculator plugins (cxcalc).
% pH                pH for computing major microspecies.
% takeMajorTaut     {0,(1)}. If 1 (default), molfiles will be saved as the
%                   major tautomers of the major microspecies at the
%                   specified pH. 
% 
% WRITTEN OUTPUTS
% One molfile for each metabolite with a KEGG Compound ID.

% If takeMajorMS == 1; approximately 2 seconds per kegg id
% If takeMajorMS == 0; approximately 0.3 seconds per kegg id

% Configure inputs
cid = reshape(cid,length(cid),1);
if ischar(cid)
    cid = strtrim(cellstr(cid));
end
if isnumeric(cid)
    eval(['cid = {' regexprep(sprintf('''C%05d''; ',cid),'(;\s)$','') '};']);
end

if ~exist('molfileDir','var')
    molfileDir = 'molfilesFromKegg';
elseif isempty(molfileDir)
    molfileDir = 'molfilesFromKegg';
end
[success,message] = mkdir(molfileDir);
if success ~= 1
    error(message)
end
if ~strcmp(molfileDir(end),filesep)
    molfileDir = [molfileDir filesep];
end

if ~exist('mets','var')
    mets = cid;
elseif isempty(mets)
    mets = cid;
end
mets = reshape(mets,length(mets),1);
if ischar(mets)
    mets = strtrim(cellstr(mets));
end
if isnumeric(mets)
    mets = strtrim(cellstr(num2str(mets)));
end
mets = regexprep(mets,'(\[\w\])$',''); % Remove compartment assignment

if ~exist('takeMajorMS','var')
    takeMajorMS = 0;
elseif isempty(takeMajorMS)
    takeMajorMS = 0;
end
if ~exist('pH','var')
    pH = 7;
elseif isempty(pH)
    pH = 7;
end
if ~exist('takeMajorMS','var')
    takeMajorTaut = 1;
elseif isempty(takeMajorMS)
    takeMajorTaut = 1;
end

% Only retreive molfiles for unique metabolites
bool = ~cellfun('isempty',cid);
umets = mets(bool);
ucid = cid(bool);
[umets,crossi] = unique(umets);
ucid = ucid(crossi);

% List all elements
elements = {'H', 'He', 'Li', 'Be', 'B', 'C', 'N', 'O', 'F', 'Ne', 'Na', 'Mg', 'Al', 'Si', 'P', 'S', 'Cl', 'Ar', 'K', 'Ca',...
    'Sc', 'Ti', 'V', 'Cr', 'Mn', 'Fe', 'Co', 'Ni', 'Cu', 'Zn', 'Ga', 'Ge', 'As', 'Se', 'Br', 'Kr', 'Rb', 'Sr', 'Y',...
    'Zr', 'Nb', 'Mo', 'Tc', 'Ru', 'Rh', 'Pd', 'Ag', 'Cd', 'In', 'Sn', 'Sb', 'Te', 'I', 'Xe', 'Cs', 'Ba', 'La', 'Ce',...
    'Pr', 'Nd', 'Pm', 'Sm', 'Eu', 'Gd', 'Tb', 'Dy', 'Ho', 'Er', 'Tm', 'Yb', 'Lu', 'Hf', 'Ta', 'W', 'Re', 'Os', 'Ir',...
    'Pt', 'Au', 'Hg', 'Tl', 'Pb', 'Bi', 'Po', 'At', 'Rn', 'Fr', 'Ra', 'Ac', 'Th', 'Pa', 'U', 'Np', 'Pu', 'Am', 'Cm',...
    'Bk', 'Cf', 'Es', 'Fm', 'Md', 'No', 'Lr', 'Rf', 'Db', 'Sg', 'Bh', 'Hs', 'Mt', 'Ds', 'Rg', 'Cn', 'Uut', 'Fl', 'Uup', 'Lv', 'Uus', 'Uuo'};

% Retreive molfiles
nomol = {};
for i = 1:length(umets)
    met = umets{i};
    id = ucid{i};
    [mol,success] = urlread(sprintf('http://rest.kegg.jp/get/cpd:%s/mol', id)); % API
    
    if success == 0
        nomol = [nomol; {met}];
        continue;
    end
    
    mol = regexprep(mol,'\r',''); % Remove carriage returns
    mol = regexprep(mol,'[^\n]*\n',[id '\n'],'once'); % Replace top line with KEGG ID
    mol = regexprep(mol,'M  END.*','M  END'); % Remove all lines after end of molfile
    
    % Identify variable structures containing R groups, repeat units etc.
    % ChemAxon's calculator plugins cannot compute major microspecies for
    % such structures.
    atoms = {};
    if takeMajorMS == 1
        % Get atom list
        lines = regexp(mol,'\n','split');
        atomCount = str2double(lines{4}(1:3));
        if atomCount > 0
            atomBlock = lines(5:5 + atomCount - 1);
            pat = '[^a-z_A-z]+(?<atom>[a-z_A-Z]+)[^a-z_A-z]+';
            atoms = regexp(atomBlock,pat,'names');
            atoms = [atoms{:}]';
            atoms = {atoms.atom}';
        end
        
        % Check for repeat units
        if ~isempty(strmatch('M  STY',lines))
            atoms = {};
        end
    end
    
    if takeMajorMS == 0 || ~all(ismember(atoms,elements)) || isempty(atoms) || (length(atoms) == 2 && all(strcmp(atoms,'H'))) % Write raw molfile from KEGG directly to file
        fid = fopen([molfileDir met '.mol'],'w+');
        fprintf(fid,'%s',mol);
        fclose(fid);
    else % Get major microspecies and write to file
        fid = fopen('tmp.mol','w+'); % Write raw molfile from KEGG to temporary file
        fprintf(fid,'%s',mol);
        fclose(fid);
        
        if takeMajorTaut == 1
            majorTautOption = 'true';
        else
            majorTautOption = 'false';
        end
        
        status = system(['cxcalc -o ' molfileDir met '.mol majorms -H ' num2str(pH) ' -f mol -M ' majorTautOption ' tmp.mol']); % Call ChemAxon's calculator plugin (cxcalc) to compute major microspecies
        
        if status ~= 0
            nomol = [nomol; {met}];
        end
    end
end

delete('tmp.mol'); % Delete temporary file

if ~isempty(nomol)
    fprintf(['Could not retreive molfiles from KEGG for metabolites:\n' sprintf('%s\n', nomol{:})]);
end
