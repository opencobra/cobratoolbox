function [dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R] = buildAtomTransitionMultigraph(model, RXNFileDir, options)
% Builds a matlab digraph object representing an atom transition multigraph
% corresponding to a metabolic network from reaction stoichiometry and atom
% mappings.
%
% The multigraph nature is due to possible duplicate atom transitions,
% where the same pair of atoms are involved in the same atom transition in
% different reactions.
%
% The directed nature is due to possible duplicate atom transitions, where
% the same pair of atoms are involved in atom transitions of opposite
% orientation, corresponding to reactions in different directions.
%
% Note that A = incidence(dATM) returns a  `a` x `t` atom transition 
% directed multigraph incidence matrix where `a` is the number of atoms and 
% `t` is the number of directed atom transitions. Each atom transition
% inherits the orientation of its corresponding reaction.
%
% A stoichimetric matrix may be decomposed into a set of atom transitions
% with the following atomic decomposition: 
%
%  N=\left(VV^{T}\right)^{-1}VAE
%
% VV^{T} is a diagonal matrix, where each diagonal entry is the number of 
% atoms in each metabolite, so V*V^{T}*N = V*A*E
% 
% With respect to the input, N is the subset of model.S corresponding to atom mapped reactions
%
% With respect to the output V := M2Ai 
%                            E := Ti2R
%                            A := incidence(dATM);
% so we have the atomic decomposition M2Ai*M2Ai'*N = M2Ai*A*Ti2R
%
% USAGE:
%
%    [dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R] = buildAtomTransitionNetwork(model, RXNFileDir, options)
%
% INPUTS:
%    model:         Directed stoichiometric hypergraph
%                   Represented by a matlab structure with following fields:
%
%                     * .S - The `m` x `n` stoichiometric matrix for the metabolic network
%                     * .mets - An `m` x 1 array of metabolite identifiers. Should match
%                       metabolite identifiers in `rxnfiles`.
%                     * .rxns - An `n` x 1 array of reaction identifiers. Should match
%                       rxnfile names in `rxnFileDir`.
%                     * .lb -  An `n` x 1 vector of lower bounds on fluxes.
%                     * .ub - An `n` x 1 vector of upper bounds on fluxes.
%
%    RXNFileDir:    Path to directory containing `rxnfiles` with atom mappings
%                   for internal reactions in `S`. File names should
%                   correspond to reaction identifiers in input `rxns`.
%                   e.g. git clone https://github.com/opencobra/ctf ~/fork-ctf
%                        then RXNFileDir = ~/fork-ctf/rxns/atomMapped        
% 
%
% OUTPUT:
%    dATM:          Directed atom transition multigraph as a MATLAB digraph structure with the following tables:
%
%                   * .Nodes — Table of node information, with `p` rows, one for each atom.
%                   * .Nodes.Atom - unique index for each atom
%                   * .Nodes.AtomIndex - unique alphanumeric id for each atom by concatenation of the metabolite, atom and element
%                   * .Nodes.Met - metabolite containing each atom
%                   * .Nodes.AtomNumber - unique numeric id for each atom in an atom mapping
%                   * .Nodes.Element - atomic element of each atom
%                       
%                   * .EdgeTable — Table of edge information, with `q` rows, one for each atom transition instance.
%                   * .EdgeTable.EndNodes - two-column cell array of character vectors that defines the graph edges     
%                   * .EdgeTable.Trans - unique alphanumeric id for each atom transition instance by concatenation of the reaction, head and tail atoms
%                   * .EdgeTable.TansInstIndex - unique numeric id for each atom transition instance
%                   * .EdgeTable.dirTransInstIndex - unique numeric id for each directed atom transition instance
%                   * .EdgeTable.Rxn - reaction corresponding to each atom transition
%                   * .EdgeTable.HeadAtomIndex - head Nodes.AtomIndex
%                   * .EdgeTable.TailAtomIndex - tail Nodes.AtomIndex
%
% metRXNBool:       `m x 1` boolean vector indicating atom mapped metabolites
% rxnRXNBool:       `n x 1` boolean vector indicating atom mapped reactions
% M2Ai              `m` x `a` matrix mapping each metabolite to an atom in the directed atom transition multigraph 
% Ti2R              `t` x `n` matrix mapping each directed atom transition instance to a mapped reaction
%
% The internal stoichiometric matrix may be decomposition into
% N = (M2Ai*M2Ai)^(-1)*M2Ai*Ti*Ti2R;
% where Ti = incidence(dATM), is incidence matrix of directed atom transition multigraph.

% .. Authors: - Ronan M. T. Fleming, 2022.

if ~exist('options','var')
    options=[];
end

if ~isfield(options,'sanityChecks')
    options.sanityChecks=1;
end

[nMets,nRxns]=size(model.S);

if length(unique(model.mets))~=length(model.mets)
    error('duplicate metabolites')
end

if length(unique(model.rxns))~=length(model.rxns)
    error('duplicate reactions')
end


[modelOut, nTotalAtomTransitions] = checkRXNFiles(model, RXNFileDir);
mbool = modelOut.metRXNBool; % `m` x 1 vector, true if metabolite identified in at least one RXN file
rbool = modelOut.RXNBool; % `n` x 1 boolean vector, true if RXN file exists

%identify the protons in the atom mapped subset
pat = '[' + lettersPattern(1) + ']';
hBool = strcmp(model.mets,'h') | matches(model.mets,pat);

if 0
    if ~all(mbool) && all(mbool & hBool)
        disp('hack to ingnore imbalanced protons')
        mbool(hBool)=1;
    end
end

fprintf('Generating atom transition network for reactions with atom mappings...\n');

% Read atom mapping from rxnfile to test if it is decompartmentalised
tmp = model.rxns(rbool);
[atomMets,~,~,~,~,~] = readRXNFile(tmp{1},RXNFileDir);

decompartmentaliseRXN=0;
atomMetAbbr  = atomMets{1};
metAbbr = model.mets{1};
if ~strcmp(atomMetAbbr(end),metAbbr(end))
    if strcmp(atomMetAbbr(end),']')
        decompartmentaliseRXN=1;
    elseif strcmp(metAbbr(end),']')
        for i=1:length(model.mets)
            model.mets{i} = model.mets{i}(1:end-2);
        end
    end
end

%                   * .Nodes — Table of node information, with `p` rows, one for each atom.
%                   * .Nodes.Atom - unique alphanumeric id for each atom by concatenation of the metabolite, atom and element
%                   * .Nodes.AtomIndex - unique numeric id for each atom in atom transition multigraph
%                   * .Nodes.Met - metabolite containing each atom
%                   * .Nodes.AtomNumber - unique numeric id for each atom in an atom mapping
%                   * .Nodes.Element - atomic element of each atom
%                   * .Edges — Table of edge information, with `q` rows, one for each atom transition instance.
%                   * .Edges.EndNodes - two-column cell array of character vectors that defines the graph edges
%                   * .Edges.Trans - unique alphanumeric id for each atom transition instance by concatenation of the reaction, head and tail atoms
%                   * .Edges.TransIstIndex - unique numeric id for each directed atom transition instance
%                   * .Edges.OrigTransIstIndex - unique numeric id for each atom transition instance, with original ordering of data
%                   * .Edges.Rxn - reaction corresponding to each atom transition
%                   * .Edges.HeadAtomIndex - head Nodes.AtomIndex
%                   * .Edges.TailAtomIndex - tail Nodes.AtomIndex

EdgeTable = table(...
    cell(nTotalAtomTransitions,2),...
    cell(nTotalAtomTransitions,1),...
    zeros(nTotalAtomTransitions,1),...
    zeros(nTotalAtomTransitions,1),...
    cell(nTotalAtomTransitions,1),...
    zeros(nTotalAtomTransitions,1),...
    zeros(nTotalAtomTransitions,1),...
    cell(nTotalAtomTransitions,1),...
    cell(nTotalAtomTransitions,1),...
    cell(nTotalAtomTransitions,1),...
    cell(nTotalAtomTransitions,1),...
    zeros(nTotalAtomTransitions,1),...
    zeros(nTotalAtomTransitions,1),...
    cell(nTotalAtomTransitions,1),...
    'VariableNames',{'EndNodes','Trans','TransInstIndex','dirTransInstIndex','Rxn','HeadAtomIndex','TailAtomIndex',...
    'HeadAtom','TailAtom','HeadMet','TailMet','HeadMetAtomNumber','TailMetAtomNumber','Element'});

% NodeTable = table(ATN.atoms,ATN.atomIndex,ATN.model.mets,ATN.atns,ATN.elements,...
%     'VariableNames',{'Atom','AtomIndex','Met','AtomNumber','Element'});


k=1;
% Build atom transition network
for i = 1:nRxns
    if rbool(i)       
        try
            % Read atom mapping from rxnfile
            
            %    atomMets:                A `p` x 1 cell array of metabolite identifiers for atoms.
            %    atomElements:            A `p` x 1 cell array of element symbols for atoms.
            %    atomNumbers:             A `p` x 1 vector containing the numbering of atoms within each metabolite molfile.
            %    atomTransitionNumbers:   A `p` x 1 vector of atom transition indices.
            %    isSubstrate:             A `p` x 1 logical array. True for substrates, false for products in the reaction.
            %    instances:               A `p` x 1 vector indicating which instance of a repeated metabolite atom `i` belongs to.
            [atomMets,atomElements,atomNumbers,atomTransitionNumbers,isSubstrate,instances] = ...
                readRXNFile(model.rxns{i},RXNFileDir);
            
            if decompartmentaliseRXN
                for n=1:length(atomMets)
                    atomMets{n,1}=atomMets{n,1}(1:end-3);
                end
            end
            
%             if any(matches(atomMets,'h'))
%                 disp(model.rxns{i})
%                 disp(atomMets)
%             end
            
            % Check that stoichiometry in rxnfile matches the one in S
            uniqueAtomMets = unique(atomMets);
            ss = model.S(mbool,i);
            as = sparse(length(ss),1);
            for j = 1:length(uniqueAtomMets)
                uniqueAtomMet = uniqueAtomMets{j};
                
                if isSubstrate(strcmp(atomMets,uniqueAtomMet))
                    as(strcmp(model.mets,uniqueAtomMet)) = -max(instances(strcmp(atomMets,uniqueAtomMet)));
                else
                    
                    as(strcmp(model.mets,uniqueAtomMet)) = max(instances(strcmp(atomMets,uniqueAtomMet)));
                end
            end
            if ~all(as == ss)
                if all(as == ss  | hBool)
                    fprintf('%s%s\n',model.rxns{i}, ' stoichiometry matches upto protons.')
                else
                    fprintf('%s%s\n',model.rxns{i}, ' stoichiometry in model and rxnfile do not match:')
                    fprintf('%s\t,', 'In model:')
                    printRxnFormula(model,'rxnAbbrList',model.rxns{i});
                    fprintf('%s\t,', 'In rxnfile:')
                    model2.S(:,ismember(model.rxns,model.rxns{i}))=as;
                    printRxnFormula(model2,'rxnAbbrList',model.rxns{i});
                    fprintf('\n');
                end
            end
            
            nAtomTransitions = length(isSubstrate)/2;
            for j=1:nAtomTransitions
                substrateAtomNumber = find(atomTransitionNumbers==j & isSubstrate);
                productAtomNumber = find(atomTransitionNumbers==j & ~isSubstrate);
                
                substrateID =[atomMets{substrateAtomNumber}...
                    '#' num2str(atomNumbers(substrateAtomNumber))...
                    '#' atomElements{substrateAtomNumber}];
                productID   = [atomMets{productAtomNumber}...
                    '#' num2str(atomNumbers(productAtomNumber))...
                    '#' atomElements{productAtomNumber}];
                
                if ~strcmp(atomElements{substrateAtomNumber},atomElements{productAtomNumber})
                    error('elemental mismatch')
                end
                
                %                 if any(matches(atomMets{productAtomNumber},'nadph'))
                %                     disp(model.rxns{i})
                %                 end
                
                %atom transition
                EdgeTable.EndNodes{k,1} = substrateID;
                EdgeTable.EndNodes{k,2} = productID;
                EdgeTable.Trans{k} = [model.rxns{i}  '#' substrateID '#' productID];
                EdgeTable.TransInstIndex(k) = k;
                EdgeTable.dirTransInstIndex(k) = k;
                EdgeTable.Rxn{k} = model.rxns{i};
                EdgeTable.HeadAtomIndex(k) = NaN;
                EdgeTable.TailAtomIndex(k) = NaN;
                EdgeTable.HeadAtom{k} = substrateID;
                EdgeTable.TailAtom{k} = productID;
                EdgeTable.HeadMet{k} = atomMets{substrateAtomNumber};
                EdgeTable.TailMet{k} = atomMets{productAtomNumber};
                EdgeTable.HeadMetAtomNumber(k) = atomNumbers(substrateAtomNumber);
                EdgeTable.TailMetAtomNumber(k) = atomNumbers(productAtomNumber);
                EdgeTable.Element{k} = atomElements{substrateAtomNumber};
                k=k+1;
            end
        catch ME
            
            if ~exist([RXNFileDir filesep 'not_parsed'],'dir')
                mkdir([RXNFileDir filesep 'not_parsed'])
            end
            %[SUCCESS,~,~] = movefile([RXNFileDir filesep model.rxns{i} '.rxn'],[RXNFileDir filesep 'not_parsed' filesep model.rxns{i} '.rxn']);
            if SUCCESS
                fprintf('%s%s%s%s%s\n','Reaction file ', model.rxns{i},'.rxn could not be parsed for atom mappings, so moved to pwd/not_parsed/',model.rxns{i}, '.rxn')
            else
                fprintf(['Reaction file ' rnx '.rxn could not be parsed for atom mappings and not moved to pwd/not_parsed either.'])
                disp(getReport(ME))
            end
        end
    end
end
if nTotalAtomTransitions ~= k-1
    warning('Missing atom transitions')
end

%% Directed atom transition multigraph as a matlab directed multigraph object
dATM = digraph(EdgeTable);

% 'Atom'
%Bout = mapAontoB(Akey,Bkey,Ain,Bin)
Atom =  mapAontoB([dATM.Edges.HeadAtom; dATM.Edges.TailAtom],dATM.Nodes.Name,[dATM.Edges.HeadAtom; dATM.Edges.TailAtom]);
% 'AtomIndex'
AtomIndex = (1:size(dATM.Nodes,1))';
% 'Met'
Met = mapAontoB([dATM.Edges.HeadAtom; dATM.Edges.TailAtom],dATM.Nodes.Name,[dATM.Edges.HeadMet; dATM.Edges.TailMet]);
% 'AtomNumber'
AtomNumber = mapAontoB([dATM.Edges.HeadAtom; dATM.Edges.TailAtom],dATM.Nodes.Name,[dATM.Edges.HeadMetAtomNumber; dATM.Edges.TailMetAtomNumber]);
% 'Element'
Element = mapAontoB([dATM.Edges.HeadAtom; dATM.Edges.TailAtom],dATM.Nodes.Name,[dATM.Edges.Element; dATM.Edges.Element]);

dATM.Nodes = addvars(dATM.Nodes,Atom,AtomIndex,Met,AtomNumber,Element,'NewVariableNames',{'Atom','AtomIndex','Met','AtomNumber','Element'});

dATM.Edges.HeadAtomIndex = mapAontoB(dATM.Nodes.Name,dATM.Edges.EndNodes(:,1),dATM.Nodes.AtomIndex);
dATM.Edges.TailAtomIndex = mapAontoB(dATM.Nodes.Name,dATM.Edges.EndNodes(:,2),dATM.Nodes.AtomIndex);

%Create a numeric version, where the alphanumeric EndNodes are replaced by Atom indices
Nodes = dATM.Nodes;
Nodes = removevars(Nodes,'Name');
Edges = dATM.Edges;
Edges.EndNodes = [Edges.HeadAtomIndex, Edges.TailAtomIndex];
dATM = digraph(Edges,Nodes);
dATM.Edges.TransInstIndex = (1:size(dATM.Edges,1))';
dATM.Edges.dirTransInstIndex = (1:size(dATM.Edges,1))';

rxnAtomMappedBool = ismember(model.rxns,dATM.Edges.Rxn); % True for reactions included in dATM
metAtomMappedBool = ismember(model.mets,dATM.Nodes.Met); % True for metabolites included in dATM

if any(mbool & ~metAtomMappedBool)
    fprintf('%u%s%u%s\n',nnz(mbool), ' metabolites should be atom mapped, but only ' ,nnz(metAtomMappedBool), ' in the dATM:')
    disp(model.mets(mbool & ~metAtomMappedBool))    
end
if any(rbool & ~rxnAtomMappedBool)
    fprintf('%u%s%u%s\n',nnz(rbool), ' reactions should be atom mapped, but only ' ,nnz(rxnAtomMappedBool), ' in the dATM:')
    disp(model.rxns(rbool & ~rxnAtomMappedBool))
end

%need to extract again because there may be problems reading an individual atom mapping
N = sparse(model.S(metAtomMappedBool,rxnAtomMappedBool)); % Stoichometric matrix of atom mapped reactions
[nMappedMets,nMappedRxns] = size(N);

if options.sanityChecks
    %double check that there is no reordering of nodes
    diffIndex = diff(dATM.Nodes.AtomIndex);
    if any(diffIndex~=1)
        fprintf('%s\n','reordering of nodes of moiety transition graph')
    end
end

if options.sanityChecks
    %double check that there is no reordering of edges
    diffIndex = diff(dATM.Edges.TransInstIndex);
    if any(diffIndex~=1)
        fprintf('%s\n','reordering of edges of moiety transition graph')
    end
end

%matrix to map each metabolite to one or more atoms
nAtoms = size(dATM.Nodes,1);
[~,atoms2mets] = ismember(dATM.Nodes.Met,model.mets(metAtomMappedBool));
M2Ai = sparse(atoms2mets,(1:nAtoms)',1,nMappedMets,nAtoms);

%matrix mapping one or more directed atom transition instances to each mapped reaction
nTransInstances = size(dATM.Edges,1);
[~,transInstance2rxns] = ismember(dATM.Edges.Rxn,model.rxns(rxnAtomMappedBool));
Ti2R = sparse((1:nTransInstances)',transInstance2rxns,1,nTransInstances,nMappedRxns);

%incidence matrix of directed atom transition multigraph
Ti = incidence(dATM);

if options.sanityChecks   
    bool=~any(Ti,1);
    if any(bool)
        error('Atom transition matrix must not have any zero columns.')
    end
    bool=~any(Ti,2);
    if any(bool)
        error('Atom transition matrix must not have any zero rows.')
    end
    
    colNonZeroCount=(Ti~=0)'*ones(size(Ti,1),1);
    if any(colNonZeroCount~=2)
        error('Atom transition matrix must have two entries per column.')
    end
    
    colCount=Ti'*ones(size(Ti,1),1);
    if any(colCount~=0)
        error('Atom transition matrix must have two entries per column, -1 and 1.')
    end
    
    %These atoms must be exchanged by reactions across the boundary of the system otherwise they cannot be produced or consumed.
    rowNonZeroCount=(Ti~=0)*ones(size(Ti,2),1);
    rowsWithOnlyOneEntryBool = rowNonZeroCount==1;
    rowsWithoutPositiveEntryBool = sum(Ti>0,2)==0;
    rowsWithoutNegativeEntryBool = sum(Ti<0,2)==0;
     
    if any(rowsWithOnlyOneEntryBool)
        fprintf('%u\t%s\n',nnz(rowsWithOnlyOneEntryBool), 'rows of Ti = incidence(dATM), with only one entry.')
        atomsOnlyCosumed = dATM.Nodes(rowsWithoutPositiveEntryBool,:);
    end
    
    if any(rowsWithoutPositiveEntryBool)
        fprintf('%u\t%s\n',nnz(rowsWithOnlyOneEntryBool & rowsWithoutPositiveEntryBool), 'rows of Ti = incidence(dATM), with only one negative entry and no positive entry.')
        atomsOnlyCosumed = dATM.Nodes(rowsWithOnlyOneEntryBool & rowsWithoutPositiveEntryBool,:);
    end
    
    if any(rowsWithoutNegativeEntryBool)
        fprintf('%u\t%s\n',nnz(rowsWithOnlyOneEntryBool & rowsWithoutNegativeEntryBool), 'rows of Ti = incidence(dATM), with only one positive entry and no negative entry.')
        atomsOnlyProduced = dATM.Nodes(rowsWithOnlyOneEntryBool & rowsWithoutNegativeEntryBool,:);
    end
       
    if 0
        %Graph Laplacian
        La = Ti*Ti';
        %Degree matrix
        D = diag(diag(La));
        
        res = adj + D - La;
        if max(max(res))~=0
            error('failed to convert to adjacency matrix')
        end
        
        L = laplacian(G);
        res = La - L;
        if max(max(res))~=0
            error('Inconsistent atom transition graph')
        end
        
        I = incidence(ATG);
        res = Ti - I;
        if max(max(res))~=0
            error('Inconsistent atom transition graph')
        end
        
        clear G D La;
    end
end

%atomic decomposition
res=(M2Ai*M2Ai')*N - M2Ai*Ti*Ti2R;
if max(max(abs(res)))~=0
    mets = model.mets(metAtomMappedBool);
    rxns = model.rxns(rxnAtomMappedBool);
     d  = diag(M2Ai*M2Ai');
     D  = spdiags(1./d,0,length(d),length(d));
    N2  = D*M2Ai*Ti*Ti2R;
    fprintf('%s\n','Inconsistency between reaction stoichiometry and atom mapped reactions (inconsistent stoichiometry?):')
    for j=1:nMappedRxns
        if any(res(:,j)~=0)
            %fprintf('%s\n',rxns{j})
            printRxnFormula(model,rxns{j});
            fprintf('%s\t\t%s\t\t%s\n','res','N','N2')
            for i=1:nMappedMets
                if res(i,j)~=0
                    fprintf('%i\t%s\t%i\t%s\t%i\t%s\n',full(res(i,j)),mets{i},full(N(i,j)),mets{i},full(N2(i,j)),mets{i})
                end
            end
            fprintf('\n')
        end
    end
    warning('Inconsistent directed atom transition multigraph')
end


