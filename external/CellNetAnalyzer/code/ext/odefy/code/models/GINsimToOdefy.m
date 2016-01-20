% GINSIMTOODEFY  Convert a GINSim model to an Odefy model
%
%   MODEL=GINSIMTOODEFY(FILENAME) takes a file FILENAME in GINSim xml-
%   format and converts the contained GINSim model into an ODEfy model 
%   structure. 
%
%   MODEL=GINSIMTOODEFY(FILENAME,MODELNAME) directly assigns the name 
%   MODELNAME to the resulting Odefy model.
%
%   CAUTION: Multi-level logics are ignored as ODEfy can yet only convert
%   Boolean models. Logical parameters and basevalues larger than 1 are set 
%   to 1. Each edge is considered active if its source is 1. 
%   
%
%   GINsim (Gene Interaction Network simulation) is a software tool for the
%   modeling and simulation of genetic regulatory networks. GINSim is 
%   available at http://gin.univ-mrs.fr/.
%   
%   Reference:
%   A.G. Gonzalez, A. Naldi, L. Sanchez, D.Thieffry, C. Chaouiya
%   GINsim: a software suite for the qualitative modelling, simulation and 
%   analysis of regulatory networks. Biosystems (2006), 84(2):91-100

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function odefymodel=GINsimToOdefy(filename, modelname)


    xDoc = xmlread(filename);
    xRoot = xDoc.getDocumentElement;
    
    if nargin==2
        odefymodel.name=modelname; % set model name
    else
        odefymodel.name='GINsim_import';
    end
    
    allNodes=xDoc.getElementsByTagName('node'); % get nodes
    allEdges=xDoc.getElementsByTagName('edge'); % get edges
    odefymodel.species=cell(1,allNodes.getLength);
    
    
    % get node identifier
    for i=0:1:(allNodes.getLength-1) % iterate over all nodes
        thisNode=allNodes.item(i);
        Id=thisNode.getAttribute('id');
        odefymodel.species{i+1}=char(Id);
    end
    
    % get inspecies per node
    for i=0:1:(allNodes.getLength-1) % iterate over all nodes
        odefymodel.tables(i+1).inspecies=[]; % create field inspecies
    end    
    for i=0:1:(allEdges.getLength-1) % iterate over all edges
        thisEdge=allEdges.item(i); 
        from=FindIndex(odefymodel.species ,thisEdge.getAttribute('from'));
        to=FindIndex(odefymodel.species ,thisEdge.getAttribute('to'));
        odefymodel.tables(to).inspecies=[odefymodel.tables(to).inspecies, from]; % add inspecies
    end

    % assemble truth tables
    for i=0:1:(allNodes.getLength-1)
        thisNode=allNodes.item(i);
        NumOfInputs=numel(odefymodel.tables(i+1).inspecies);
        
        % create truth tables and fill with basevalues
        basevalue=str2double(char(thisNode.getAttribute('basevalue')))>0; % get the node's basal value, multi-level logics are ignored
        if NumOfInputs==0 % no inspecies
            odefymodel.tables(i+1).truth=[]; % empty truth table
            continue; % nothing else to do
        elseif NumOfInputs==1 % only one inspecies
            odefymodel.tables(i+1).truth=basevalue*[1 1]; % one-dimensional truth vector
        else % more than 1 inspecies
            odefymodel.tables(i+1).truth=basevalue*ones(2*ones(1,numel(odefymodel.tables(i+1).inspecies))); % create truth cube
        end
        
        % consider incoming edges
        for b=0:(2^NumOfInputs-1) % iterate over all fields of the truth cube
            activeInputs=odefymodel.tables(i+1).inspecies(bin2vec(b, NumOfInputs)==1); % get identifier of all active inspecies
            
            % create list of all functional edges
            funcEdges=[];
            for j=0:1:(allEdges.getLength-1) % iterate over all edges
                thisEdge=allEdges.item(j);
                to=FindIndex(odefymodel.species, thisEdge.getAttribute('to'));
                if to~=(i+1) % not an incoming edge
                    continue
                end
                from=FindIndex(odefymodel.species, thisEdge.getAttribute('from'));
                if ismember(from, activeInputs) % edge is functional
                    funcEdges{numel(funcEdges)+1}=char(thisEdge.getAttribute('id')); % add to list of functional edges
                end
            end % iteration over all edges (j)
 
            if isempty(funcEdges) % no edge is functional
                continue; % leave basevalue in truth table
            end
            
            % check if logical parameter is defined
            defined=0;
            allParams=thisNode.getElementsByTagName('parameter');
            for j=0:1:(allParams.getLength-1) % iterate over all defined logical parameters 
                thisParam=allParams.item(j);
                [start_idx, end_idx, extents, edgeList, tokens, names, splits] = regexp(char(thisParam.getAttribute('idActiveInteractions')), '\S*'); % get single edges
                if isequal(sort(funcEdges), sort(edgeList)) % are lists equal upto ordering
                    odefymodel.tables(i+1).truth(b+1)=str2double(char(thisParam.getAttribute('val')))>0; % set to specified logical parameter, multi-level logics are ignored
                    defined=1; % yes, a logical parameter was specified, do not use default value below
                end
            end % iteration over all defined logical parameters (j)
            if ~defined % no logical parameter specified
                odefymodel.tables(i+1).truth(b+1)=0; % use defaul value 0
            end
        end % iteration over all fields (b)
    end % iteration over all nodes (i)
    
end % main function


function ind = FindIndex(list, search)

ind = find(strcmp(list,search));
if numel(ind)==0
    ind=-1;
end
% ind = -1;
% for i=1:numel(list)
%     if (strcmp(list{i},search))
%         ind = i;
%         break,
%     end
% end

end



function v = bin2vec(binnum, n)

v = zeros(n,1);

for i=n-1:-1:0
    pow2 = 2^i;
    if binnum >= pow2
        v(i+1) = 1;
        binnum = binnum - pow2;
    end
end

end