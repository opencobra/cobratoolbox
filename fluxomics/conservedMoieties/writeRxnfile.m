function writeRxnfile(mets,stoichiometry,rxnfileName,molfileDirectory,rxnfileDirectory)

%% format inputs
if nargin < 3
    rxnfileName = 'rxn';
end
if nargin < 4
    molfileDirectory = '';
end
if nargin < 5
    rxnfileDirectory = '';
end

s = stoichiometry;
rxn = rxnfileName;
moldir = molfileDirectory;
rxndir = rxnfileDirectory;

mets = mets(s ~= 0);
s = s(s ~= 0);
s = full(s);

mets = regexprep(mets,'(\.mol)$','');
compmets = mets;
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
reactants = [num2cell(abs(s(s < 0))) mets(s < 0)]';
leftside = sprintf('%d %s + ',reactants{:});
leftside = regexprep(leftside,'( \+ )$','');
leftside = regexprep(leftside,'1 ','');
products = [num2cell(s(s > 0)) mets(s > 0)]';
rightside = sprintf('%d %s + ',products{:});
rightside = regexprep(rightside,'( \+ )$','');
rightside = regexprep(rightside,'1 ','');
rxnformula = sprintf('%s -> %s',leftside,rightside);

rxnfile = sprintf('$RXN\n%s\n\n%s\n',rxn,rxnformula); % First four lines

% Add Reactant/Product line
nr = sum(abs(s(s < 0))); % nr. of reactants
np = sum(abs(s(s > 0))); % nr. of products
rxnfile = [rxnfile sprintf('% 3d% 3d\n',nr,np)];

mets = regexprep(mets,'(\[\w\])$','');

% Add molfiles for reactants
for i = find(s < 0)'
    molfile = fileread([moldir mets{i} '.mol']);
    molfile = deblank(molfile);
    molfile = regexprep(molfile,'^([^\n]*\n)',sprintf('%s\n',compmets{i}));
    molsection = sprintf('$MOL\n%s\n',molfile);
    molsection = repmat(molsection,1,abs(s(i)));
    rxnfile = [rxnfile molsection];
end

% Add molfiles for products
for i = find(s > 0)'
    molfile = fileread([moldir mets{i} '.mol']);
    molfile = deblank(molfile);
    molfile = regexprep(molfile,'^([^\n]*\n)',sprintf('%s\n',compmets{i}));
    molsection = sprintf('$MOL\n%s\n',molfile);
    molsection = repmat(molsection,1,abs(s(i)));
    rxnfile = [rxnfile molsection];
end

fidout = fopen([rxndir rxn '.rxn'],'w+');
fprintf(fidout,'%s',rxnfile);
fclose(fidout);

end