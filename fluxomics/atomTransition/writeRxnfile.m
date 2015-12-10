function writeRxnfile(s,mets,molfileNames,molfileDirectory,rxnfileName,rxnfileDirectory)
% Writes a rxnfile (Accelrys, San Diego, CA) for a metabolic reaction.
% 
% writeRxnfile(s,mets,molfileNames,molfileDirectory,rxnfileName,rxnfileDirectory)
% 
% INPUTS
% s                 ... An m x 1 vector of stoichiometric coefficients.
% mets              ... An m x 1 cell array of metabolite identifiers.
% 
% OPTIONAL INPUTS
% molfileNames      ... An m x 1 cell array of molfile names for
%                       metabolites in mets. Defaults to mets.
% molfileDirectory  ... Path to directory containing input molfiles. 
%                       Defaults to current directory.
% rxnfileName       ... A name for the output rxnfile. Defaults to
%                       'rxn.rxn'.
% rxnfileDirectory  ... Path to directory where the output rxnfile should
%                       be saved. Defaults to current directory.
% 
% OUTPUT
% The file 'rxnfileDirectory/rxnfileName.rxn'
% 
% June 2015, Hulda S. Haraldsdóttir and Ronan M. T. Fleming

%% format inputs

% set defaults for optional inputs
if nargin < 3
    molfileNames = mets;
end
if nargin < 4
    molfileDirectory = '';
end
if nargin < 5
    rxnfileName = 'rxn';
end
if nargin < 6
    rxnfileDirectory = '';
end

% Rename inputs
mols = molfileNames;
rxn = rxnfileName;
moldir = molfileDirectory;
rxndir = rxnfileDirectory;

% Remove irrelevant metabolites
mets = mets(s ~= 0);
mols = mols(s ~= 0);
s = s(s ~= 0);
s = s(:); % Make sure s is a column vector
s = full(s);

% Reformat string inputs
mols = regexprep(mols,'(\.mol)$','');
rxn = regexprep(rxn,'(\.rxn)$','');

moldir = regexprep(moldir,'\\','/');
if ~isempty(moldir)
    if ~strcmp(moldir(end),'/')
        moldir = [moldir '/'];
    end
end

rxndir = regexprep(rxndir,'\\','/');
if ~isempty(rxndir)
    if ~strcmp(rxndir(end),'/')
        rxndir = [rxndir '/'];
    end
end

%% Build Rxnfile

% Write reaction equation
reactants = [num2cell(abs(s(s < 0))) mets(s < 0)]';
leftside = sprintf('%d %s + ',reactants{:});
leftside = regexprep(leftside,'( \+ )$','');
leftside = regexprep(leftside,'1 ','');
products = [num2cell(s(s > 0)) mets(s > 0)]';
rightside = sprintf('%d %s + ',products{:});
rightside = regexprep(rightside,'( \+ )$','');
rightside = regexprep(rightside,'1 ','');
rxnformula = sprintf('%s -> %s',leftside,rightside);

rxnfile = sprintf('$RXN\n%s\n\n%s\n',rxn,rxnformula); % First four lines of rxnfile

% Add Reactant/Product line
nr = sum(abs(s(s < 0))); % nr. of reactants
np = sum(abs(s(s > 0))); % nr. of products
rxnfile = [rxnfile sprintf('% 3d% 3d\n',nr,np)];

% Add molfiles for reactants
for i = find(s < 0)'
    molfile = fileread([moldir mols{i} '.mol']);
    molfile = deblank(molfile);
    molfile = regexprep(molfile,'^([^\n]*\n)',sprintf('%s\n',mets{i}));
    molsection = sprintf('$MOL\n%s\n',molfile);
    molsection = repmat(molsection,1,abs(s(i)));
    rxnfile = [rxnfile molsection];
end

% Add molfiles for products
for i = find(s > 0)'
    molfile = fileread([moldir mols{i} '.mol']);
    molfile = deblank(molfile);
    molfile = regexprep(molfile,'^([^\n]*\n)',sprintf('%s\n',mets{i}));
    molsection = sprintf('$MOL\n%s\n',molfile);
    molsection = repmat(molsection,1,abs(s(i)));
    rxnfile = [rxnfile molsection];
end

fidout = fopen([rxndir rxn '.rxn'],'w+');
fprintf(fidout,'%s',rxnfile);
fclose(fidout);

end