function map = readCbMap(fileName)
% readCbMap reads in a map from a textfile and returns a map struct
%
% map = readCbMap(fileName)
%
%INPUT
% fileName is the text file exported from BiGG database
%
%OUTPUT
% map                   Map structure
%   molPosition             the positions of the metabolite nodes
%   molIndex                index for molecule node(same as connection index)
%   molName                 full name of metabiolites
%   molAbbreviation         The abbreviation formetabolites(labels)
%   molLabelPos             The positions to display the metabolite's labels
%   molPrime                Y if metabolite is primary and N if not
%   rxnPosition             the positions of the reaction nodes
%   rxnLabelPosition        the positions of the reaction nodes' labels if the
%                           node is a midpoint
%   rxnIndex                the index of reaction nodes used in connection
%   connection              the node connection matrix
%   connectionAbb           the reaction abbreviations assigned to each
%                           segment
%   connectionName          the name of reactions
%   connectionReversibile   1 if reaction is reversible and 0 otherwise
%


% The general format of the import file in 9 cols
if nargin < 1
    [fileName,filePath] = uigetfile({'*.txt'});
else
    filePath = '';
    if isempty(regexp(fileName,'.txt$', 'once'))
        fileName = strcat(fileName,'.txt');
    end
end


format = '%s %n %s %f %f %f %f %n %s';
fid = fopen(strcat(filePath,fileName));
molecules = textscan(fid, format,'delimiter', '\t','HeaderLines',1);
fclose(fid);

molAbb = molecules{1,1};
molComp = molecules{1,2};
molPrim = molecules{1,3};
molLabelx = molecules{1,4};
molLabely = molecules{1,5};
molPosx = molecules{1,6};
molPosy = molecules{1,7};
molName = molecules{1,9};
molId = molecules{1,8};
% s = size(molLabelx);            %lenght of a general column
% i = 1;

% while i<= s(1)
%     if strcmp(molAbb(i),'Reactions Nodes')
%         rxnN = i;               % number of molecules
%     elseif strcmp(molAbb(i),'Reactions')
%         rxnEnd = i;
%     elseif strcmp(molAbb(i),'Texts')
%         textBeg = i;
%     end
%     i= i+1;
% end

rxnN = (strmatch('Reactions Nodes',molAbb));
rxnEnd = strmatch('Reactions',molAbb,'exact');
textBeg = strmatch('Texts',molAbb);

indexMols = (1:(rxnN-1));
indexRxnNodes = ((rxnN+1):(rxnEnd-1));
indexRxnNames = ((rxnEnd+1):(textBeg-1));
indexTexts = ((textBeg+1):length(molAbb));

rxnNum = (rxnEnd-rxnN-1);       % number of rxn nodes
connectionNum = textBeg-rxnEnd;    % number of connections: connectionNum 

% set up the position matrix for molecules
molPos(:,1) = molPosx(indexMols);  
molPos(:,2) = molPosy(indexMols);

% set up the position matrix for molecules' labels
molLabelPos = [molLabelx(indexMols) molLabely(indexMols)];

% set up the position matrix for reactions
%rxnPos = [molLabelx(indexRxnNodes) molLabely(indexRxnNodes)];
%Updated BiGG to output files in a less disorganized fashion
rxnPos = [molPosx(indexRxnNodes) molPosy(indexRxnNodes)];

% set up the position matrix for reactions' labels
%rxnLabelPos = [molPosx(indexRxnNodes) molPosy(indexRxnNodes)];
%Updated BiGG to output files in a less disorganized fashion
rxnLabelPos = [molLabelx(indexRxnNodes) molLabely(indexRxnNodes)];

% reaction ids
rxnId = molId(indexRxnNodes);

% set up the connection matrix
node = [molLabelx(indexRxnNames) molLabely(indexRxnNames)];


% set up the reversibility for each connection
r = zeros(connectionNum,1);
r(strmatch('Reversible',molPrim(indexRxnNames),'exact'))=1;

rxnAbb = molAbb(indexRxnNames);
rxnName = molName(indexRxnNames);

%% Handling other shapes and texts
shapeIDs = [strmatch('Circle',molAbb); strmatch('Rect',molAbb); strmatch('Line',molAbb)];
indexShapes = logical(sparse(length(molAbb),1));
indexShapes(shapeIDs) = 1;
map.shapeType = molAbb(indexShapes);
map.shapePos = [molLabelx(indexShapes) molLabely(indexShapes)];
map.shapeSize = [molPosx(indexShapes) molPosy(indexShapes)];
for i=1:length(shapeIDs)
    str = molName(shapeIDs(i));
    [colorStr, str] = strtok(str,':');
    [c1,c2] = strtok(colorStr,'/');
    [c2,c3] = strtok(c2,'/');
    c3 = regexprep(c3,'\/','');
    if isnan(str2double(c3))
        c3 = 0;
    end
    [thickness, style] = strtok(str,'@');
    thickness = regexprep(thickness,'(\w*):','');
    style = regexprep(style,'\@','');
    map.shapeStyle(i,1) = style;
    map.shapeThickness(i,1) = str2num(thickness{1,1});
    map.shapeColor(i,1:3) = [str2double(c1{1,1}) str2double(c2{1,1}) str2double(c3{1,1})];
end
indexShapes(1:textBeg) = 1;
map.text = molName(~indexShapes);
map.textFont = molAbb(~indexShapes);
map.textPos = [molLabelx(~indexShapes) molLabely(~indexShapes)];
map.textSize = molPosx(~indexShapes);

map.molPosition = molPos';
map.molIndex = molId(1:(rxnN-1));
map.molName = molName(1:(rxnN-1));
map.molAbbreviation = molAbb(1:(rxnN-1));
map.molLabelPos = molLabelPos;
map.molPrime = molPrim(1:(rxnN-1));
map.molCompartment = molComp(1:(rxnN-1));
map.rxnPosition = rxnPos';
map.rxnLabelPosition = rxnLabelPos';
map.rxnIndex = rxnId;
map.connection = node;
map.connectionAbb = rxnAbb;
map.connectionName = rxnName;
map.connectionReversible = r;
end
