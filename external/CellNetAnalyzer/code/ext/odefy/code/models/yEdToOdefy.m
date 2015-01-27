% YEDTOODEFY  Convert graphs from yEd GraphML files to Odefy.
%
%   Odefy can interpret the contained graphs as two different types of
%   model representations. Please refer to the HTML help for detailed
%   information on the graph representations of Boolean models.
%
%   1. Regular interaction graphs: Simple regulatory graphs with activating
%      and inhibiting edges. As the combination of multiple input edges
%      into a boolean function (whether to use OR or AND) is ambigious, we
%      need to define a generic logic (see below).
%
%   2. Boolean hypergraph representation: Capable of describing arbitrary
%      boolean functions. 
%
%   The graph contained in the given yEd GraphML is treated as a hypergraph
%   if and only if this is explicitely stated in the function or call or 
%   the graph contains at least one node labelled "&"
%
%   MODEL=YEDTOODEFY(FILE) loads an Odefy model from a given yEd GraphML
%   file. 
%
%   MODEL=YEDTOODEFY(FILE,ACTLOGIC,COMBLOGIC,INHLOGIC) provides the generic
%   logic defined by ACTLOGIC,COMBLOGIC,INHLOGIC for conventional
%   interaction graphs. For more details, see
%
%   help GraphToOdefy
%
%   MODEL=YEDTOODEFY(FILE, 'hyper') explicitely forces Odefy to treat the
%   contained graph as a boolean hypergraph.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function model = yEdToOdefy(varargin)

% print warning in octave mode
if ~IsMatlab
    fprintf('\nWARNING: This function probably crashes under Octave due to the xmlread implementation.\n\n');
end

% get parameters
file = varargin{1};
hypergraph=false;
if nargin>1
    if isstr(varargin{2})
        if strcmp(varargin{2},'hyper')
            hypergraph=true;
        else
            error('String argument may only be ''hyper''');
        end
    end
end
% logic given?
if ~hypergraph && nargin>1
    if nargin~=4
        error('Must provide 3 values for the generic logic');
    else
        % get logic
        actLogic = varargin{2};
        combLogic = varargin{3};
        inhLogic = varargin{3};
    end
elseif ~hypergraph
    actLogic=2;
    combLogic=1;
    inhLogic=2;
end

% model name
[pathstr, name] = fileparts(file) ;
modelname = name;

xDoc = xmlread(file);
xRoot = xDoc.getDocumentElement;

%%% STEP 1: parse all species
allNodes = xDoc.getElementsByTagName('node');
cnodes = cell(allNodes.getLength,2);
containsAnd=0;
nonAnd=0;
for i = 0:allNodes.getLength-1
    % get node
    thisNode = allNodes.item(i);
    % store its id, then get the yEd label
    id = thisNode.getAttribute('id');
    labelnode = getFirstNamedChildSequence(thisNode, {'data', 'y:ShapeNode','y:NodeLabel','#text'});
    label = labelnode.getData;
    % store node ID along with its label
    cnodes{i+1,1} = char(id);
    cnodes{i+1,2} = char(label);
    % remember if there was at least one &
    if strcmp(cnodes{i+1,2},'&')
        containsAnd=1;
    else
        nonAnd = nonAnd+1;
    end
    % check for valid variable names
    if (strcmp(char(label),'&') ~= 1 && ~isvarname(char(label)))
        error(['Invalid network - "' char(label) '" is not a valid MATLAB variable name.']);
    end
end

if numel(unique(cnodes(:,2)))-containsAnd < nonAnd
    error('The graph contains duplicate node labels');
end

%%% STEP 2: parse all edges
allEdges = xDoc.getElementsByTagName('edge');
cedges = cell(allEdges.getLength,3);

% empty?
if allEdges.getLength == 0
    error('Invalid Boolean network - Graph does not contain any interactions');
end

for i = 0:allEdges.getLength-1
    % get node
    thisEdge = allEdges.item(i);
    % store source & target labels (directly translated from IDs to labels)
    cedges{i+1,1} = FindIndex(cnodes, char(thisEdge.getAttribute('source')));
    cedges{i+1,2} = FindIndex(cnodes, char(thisEdge.getAttribute('target')));
    % determine type of interaction
    % target=white_diamond => inhibition, everything else => activation
    datanode = getFirstNamedChild(thisEdge, 'data');
    yedgenode = datanode.getFirstChild;
    yedgenode = yedgenode.getNextSibling;
    yarrowsnode = getFirstNamedChild(yedgenode, 'y:Arrows');
    cedges{i+1,3} = 1-strcmp('white_diamond', char(yarrowsnode.getAttribute('target')));
end


if containsAnd || hypergraph
    %%% STEP 3: assemble interaction matrix
    
    % iterate over all the edges
    intermat = [];
    notmat = [];
    numinter = 0;
    hyperarcint = [];
    for i=1:size(cedges,1)
        % map source and target to actual indices, if not &
        if (strcmp(cnodes{cedges{i,1},2},'&'))
            source = -1;
        else
            source = cedges{i,1};
        end
        if (strcmp(cnodes{cedges{i,2},2},'&'))
            target = -1;
        else
            target = cedges{i,2};
        end
        
        if (source == -1 && target == -1)
        elseif (source == target && source >= 0)
            % no &, self edges are entered as a 2
            numinter = numinter+1;
            intermat(source,numinter) = 2;
        elseif (source > 0 && target > 0)
            % no & incident to this edge => create new reaction
            numinter = numinter + 1;
            intermat(source,numinter) = -1;
            intermat(target,numinter) = 1;
            % and the not matrix (for inhibition)
            if (cedges{i,3} == 0)
                notmat(source,numinter) = 1;
            end
        else
            % this is part of a hyperarc, get its index (& node in the graph)
            if (source == -1)
                hindex = cedges{i,1};
            else
                hindex = cedges{i,2};
            end
            % map it to a reaction
            if numel(hyperarcint) < hindex || hyperarcint(hindex) == 0
                % it is the first time we see this hyperarc
                numinter = numinter+1;
                hyperarcint(hindex) = numinter;
                hint = numinter;
            else
                hint = hyperarcint(hindex);
            end
            % set values
            if (source > 0)
                % source
                % already set as target? => self-loop
                if (matexists(intermat,source,hint) && intermat(source,hint) == 1)
                    intermat(source,hint) = 2;
                else
                    intermat(source,hint) = -1;
                end
                % not matrix, eventually
                if (cedges{i,3} == 0)
                    notmat(source,hint) = 1;
                end
            else
                % target
                % already set as source? => self-loop
                if (matexists(intermat,target,hint) && intermat(target,hint) == -1)
                    intermat(target,hint) = 2;
                else
                    intermat(target,hint) = 1;
                end
            end
            
        end
        
    end
    % scale not matrix to the same size as the interaction matrix
    if (size(notmat,1) < size(intermat,1))
        notmat(size(intermat,1),1) = 0;
    end
    if (size(notmat,2) < size(intermat,2))
        notmat(1,size(intermat,2)) = 0;
    end
    
    
    % delete zero rows (correspond to & nodes)
    zerorows = find(sum(abs(intermat),2)==0);
    intermat(zerorows,:) = [];
    notmat(zerorows,:) = [];
    
    % invert not matrix
    notmat = 1-notmat;
    
    % finally, assemble species names
    species = cell(1,size(intermat,1));
    specnum = 0;
    for i=1:size(cnodes,1)
        if (~strcmp(cnodes{i,2},'&'))
            specnum = specnum+1;
            species{specnum} = cnodes{i,2};
        end
    end
    
    model = CNAToOdefy(species,intermat,notmat,modelname);
    
else
    % conventional graph
    A=[];
    for i=1:size(cedges,1)
        if cedges{i,3}==1
            val=1;
        else
            val=-1;
        end
        A(cedges{i,1},cedges{i,2})=val;
    end
    % stretch, if necessary
    if size(A,1)~=size(A,2)
        A(max(size(A,1),size(A,2)),max(size(A,1),size(A,2)))=0;
    end     
    
    model = GraphToOdefy(A, actLogic, combLogic, inhLogic);
    model.species = cnodes(:,2)';
    model.name = modelname;
end







function r = matexists(mat, i, j)
r = (size(mat,1) >= i && size(mat,2) >= j);

function ind = FindIndex(list, search)

ind = -1;
for i=1:numel(list)
    if (strcmp(list{i,1},search))
        ind = i;
        break,
    end
end


function child=getFirstNamedChild(node, name)

child = [];
checknode = node.getFirstChild;
while ~isempty(checknode)
    % no text nodes
    %    if (checknode.getNodeType == 1)
    if strcmp(checknode.getNodeName,name)
        child = checknode;
        break
    end
    %    end
    checknode = checknode.getNextSibling;
end


function child=getFirstNamedChildSequence(node, names)
curnode = node;
for i=1:numel(names)
    curnode = getFirstNamedChild(curnode, names{i});
end

child=curnode;