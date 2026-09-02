function [dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R, dATME, BG, dBTM, M2BiE, M2BiW, BTi2R, BTiE] = buildAtomAndBondTransitionMultigraph(model, RXNFileDir, options)
% Builds a matlab digraph object representing an atom transition multigraph
% and a bond transition multigraph
% corresponding to a metabolic network from reaction stoichiometry and atom
% mappings.
% -----Atoms
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
% ---Bonds
% Note that B = incidence(dBTM) returns a  `b` x `s` bond transition 
% directed multigraph incidence matrix where `b` is the number of bonds and 
% `s` is the number of directed bond transitions. Each bond transition
% inherits the orientation of its corresponding reaction.
%
% A stoichimetric matrix may be decomposed into a set of bond transitions
% with the following decomposition in terms of bonds: 
%
%  N=\left(UW^{T}\right)^{-1}UBF
%
% UW^{T} is a diagonal matrix, where each diagonal entry is the number of 
% bonds in each metabolite, so U*W^{T}*N = U*B*F
% 
% With respect to the input, N is the subset of model.S corresponding to bond mapped reactions
%
% With respect to the output U := M2Bi 
%                            W := M2BiW
%                            F := BTi2R
%                            B := incidence(dBTM);
% so we have the decomposition in terms of bond M2Bi*M2BiW'*N = M2Bi*B*BTi2R
%
% USAGE:
%
%    [dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R, dBTM, M2BiE, M2BiW, BTiE] = buildAtomAndBondTransitionMultigraph(model, RXNFileDir, options)
%
% INPUTS:
%    model:         Directed stoichiometric hypergraph (COBRA model structure) with fields:
%
%                     * .S - The `m` x `n` stoichiometric matrix for the metabolic network
%                     * .mets - An `m` x 1 array of metabolite identifiers. Should match metabolite identifiers in `rxnfiles`.
%                     * .rxns - An `n` x 1 array of reaction identifiers. Should match rxnfile names in `RXNFileDir`.
%
%    RXNFileDir:    Path to directory containing `rxnfiles` with atom mappings
%                   for internal reactions in `S`. File names should
%                   correspond to reaction identifiers in input `rxns`.
%                   e.g. git clone https://github.com/opencobra/ctf ~/fork-ctf
%                        then RXNFileDir = ~/fork-ctf/rxns/atomMapped
%
% OPTIONAL INPUT:
%    options:       A structure of customisable options for the function:
%
%                     * .sanityChecks - boolean controlling whether sanity checks are performed within the function (default = 1)
%                     * .bondTransitionMultigraph - boolean specifying whether the function generates the bond transition multigraph (default = 1)
% 
%
% OUTPUT:
%    dATM:          Directed atom transition multigraph as a MATLAB digraph structure with the following tables:
%
%                   * .Nodes — Table of node information, with `p` rows, one for each atom.
%                   * .Nodes.Atom - unique index for each atom
%                   * .Nodes.Atom - unique alphanumeric id for each atom by concatenation of the metabolite, atom and element
%                   * .Nodes.AtomIndex - unique numeric id for each atom in atom transition multigraph
%                   * .Nodes.Met - metabolite containing each atom
%                   * .Nodes.AtomNumber - unique numeric id for each atom in an atom mapping
%                   * .Nodes.Element - atomic element of each atom
%                       
%                   * .EdgeTable — Table of edge information, with `s` rows, one for each bond transition instance.
%                   * .EdgeTable.EndNodes - two-column cell array of character vectors that defines the graph edges     
%                   * .EdgeTable.Trans - unique alphanumeric id for each bond transition instance by concatenation of the reaction, head and tail atoms
%                   * .EdgeTable.TansInstIndex - unique numeric id for each bond transition instance
%                   * .EdgeTable.dirTransInstIndex - unique numeric id for each directed bond transition instance
%                   * .EdgeTable.Rxn - reaction corresponding to each bond transition
%                   * .EdgeTable.HeadBondIndex - head Nodes.BondIndex
%                   * .EdgeTable.TailBondIndex - tail Nodes.BondIndex
%
%    metAtomMappedBool:    `m x 1` boolean vector indicating atom mapped metabolites
%    rxnAtomMappedBool:    `n x 1` boolean vector indicating atom mapped reactions
%    M2Ai:               `m` x `a` matrix mapping each metabolite to an atom in the directed atom transition multigraph
%    Ti2R:               `t` x `n` matrix mapping each directed atom transition instance to a mapped reaction
%    dATME:              directed atom transition multigraph (`dATM`) augmented with an energy node per reaction, used to build the bond transition multigraph
%    BG:                 bond graph (MATLAB graph) of the bonds, built from the nodes of `dATME`
%
%    dBTM:          Directed bond transition multigraph as a MATLAB digraph structure with the following tables:
%
%                   * .Nodes — Table of node information, with `q` rows, one for each bonds.
%                   * .Nodes.Bond - unique alphanumeric id for each bond by
%                   concatenation of the metabolite, head bond and tail
%                   bond
%                   * .Nodes.BondIndex - unique numeric id for each bond in bond transition multigraph
%                   * .Nodes.BondHeadAtom  -  the  alphanumeric id for the
%                   head atom forming the bond
%                   * .Nodes.BondTailAtom - the alphanumeric id for the
%                   tail atom forming the bond
%                   * .Nodes.BondHeadAtomIndex  - the numeric id for the
%                   head atom forming the bond
%                   * .Nodes.BondTailAtomIndex  - the numeric id for the
%                   tail atom forming the bond
%                   * .Nodes.Met - metabolite containing each bond
%                   * .Nodes.BondType - the type of each bond (1 for a single bond, 2 for a double bond, and 3 for a triple bond)  
%                   * .EdgeTable — Table of edge information, with `q` rows, one for each atom transition instance.
%                   * .EdgeTable.EndNodes - two-column cell array of character vectors that defines the graph edges     
%                   * .EdgeTable.Trans - unique alphanumeric id for each atom transition instance by concatenation of the reaction, head and tail atoms
%                   * .EdgeTable.TansInstIndex - unique numeric id for each atom transition instance
%                   * .EdgeTable.dirTransInstIndex - unique numeric id for each directed atom transition instance
%                   * .EdgeTable.Rxn - reaction corresponding to each atom transition
%                   * .EdgeTable.HeadBondIndex - head Nodes.BondIndex
%                   * .EdgeTable.TailBondIndex - tail Nodes.BondIndex
%                   * .EdgeTable.HeadBond   -    head Nodes.Bond
%                   * .EdgeTable.TailBond   -    tail Nodes.Bond
%                   * .EdgeTable.HeadMet    -    head Nodes.Met
%                   * .EdgeTable.TailMet    -    tail Nodes.Met
%                   * .EdgeTable.HeadMetBondTypes  - head Nodes.BondTypes
%                   * .EdgeTable.TailMetBondTypes  - tail Nodes.BondTypes
%
%    M2BiE:              `m` x `b` matrix mapping each metabolite to a bond in the directed bond transition multigraph
%    M2BiW:              `m` x `b` matrix specifying the bond type of each metabolite-bond entry of `M2BiE`
%    BTi2R:              `s` x `n` matrix mapping each directed bond transition instance to a mapped reaction
%    BTiE:               incidence matrix of the directed bond transition multigraph (`incidence(dBTM)`)

% .. Authors: - Ronan M. T. Fleming, 2022, Hadjar Rahou 2022 (Bond section)

if ~exist('options','var')
    options=[];
end

if ~isfield(options,'sanityChecks')
    options.sanityChecks=1;
end
if ~isfield(options,'bondTransitionMultigraph')
    options.bondTransitionMultigraph=1;
end

[nMets,nRxns]=size(model.S);

if length(unique(model.mets))~=length(model.mets)
    error('duplicate metabolites')
end

if length(unique(model.rxns))~=length(model.rxns)
    error('duplicate reactions')
end


[modelOut,nTotalAtomTransitions,nTotalBondTransitions] = checkABRXNFiles(model, RXNFileDir);
mbool = modelOut.metRXNBool; % `m` x 1 vector, true if metabolite identified in at least one RXN file
rbool = modelOut.RXNBool; % `n` x 1 boolean vector, true if RXN file exists

%identify the protons in the atom mapped subset
pat = 'h[' + lettersPattern(1) + ']';
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
[atoms,~] = readABRXNFile(tmp{1},RXNFileDir);
atomMets=atoms.mets;
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
%                   * .Nodes.mets - metabolite containing each atom
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
    'VariableNames',{'EndNodes','Trans','TransInstIndex','dirTransInstIndex','rxns','HeadAtomIndex','TailAtomIndex',...
    'HeadAtom','TailAtom','HeadMet','TailMet','HeadMetAtomNumber','TailMetAtomNumber','Element'});

% NodeTable = table(ATN.atoms,ATN.atomIndex,ATN.model.mets,ATN.atns,ATN.elements,...
%     'VariableNames',{'Atom','AtomIndex','mets','AtomNumber','Element'});


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
            [atoms,~] = readABRXNFile(model.rxns{i},RXNFileDir);
            atomMets=atoms.mets;
            atomElements=atoms.elements;
            atomNumbers=atoms.metNrs;
            atomTransitionNumbers=atoms.atomTransitionNrs;
            isSubstrate=atoms.isSubstrate;
            instances=atoms.instances;
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
%             if ~all(as == ss)  %HadjarToRemove
%                 if all(as == ss  | hBool)
%                     fprintf('%s%s\n',model.rxns{i}, ' stoichiometry matches upto protons.')
%                 else
%                     fprintf('%s%s\n',model.rxns{i}, ' stoichiometry in model and rxnfile do not match:')
%                     fprintf('%s\t,', 'In model:')
%                     printRxnFormula(model,'rxnAbbrList',model.rxns{i});
%                     fprintf('%s\t,', 'In rxnfile:')
%                     model2.S(:,ismember(model.rxns,model.rxns{i}))=as;
%                     printRxnFormula(model2,'rxnAbbrList',model.rxns{i});
%                     fprintf('\n');
%                 end
%             end
            
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
                EdgeTable.rxns{k} = model.rxns{i};
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
            % SPECKIT OVERRIDE (2026-09-02): this branch referenced SUCCESS, a
            % variable only ever assigned by the movefile call below, which is
            % commented out -- so the very first RXN file that failed to parse
            % threw "Unrecognized function or variable 'SUCCESS'" from inside
            % this catch block itself, crashing the entire pipeline instead of
            % being logged and skipped as clearly intended. Quarantining (moving
            % the file out of RXNFileDir into not_parsed/) stays disabled, since
            % silently relocating files out of a shared RXN corpus on a parse
            % failure is a separate, deliberate decision for someone to make --
            % this just makes the existing "log it and move on" intent work.
            fprintf('%s%s%s\n','Reaction file ', model.rxns{i}, ...
                '.rxn could not be parsed for atom mappings and was skipped.')
            disp(getReport(ME))
        end
    end
end
if nTotalAtomTransitions ~= k-1
    warning('Missing atom transitions')
end

%% Directed atom transition multigraph as a matlab directed multigraph object
dATM = digraph(EdgeTable);

% 'Atom'
%Bout = mapAontoBOld(Akey,Bkey,Ain,Bin)
Atom =  mapAontoBOld([dATM.Edges.HeadAtom; dATM.Edges.TailAtom],dATM.Nodes.Name,[dATM.Edges.HeadAtom; dATM.Edges.TailAtom]);
% 'AtomIndex'
AtomIndex = (1:size(dATM.Nodes,1))';
% 'Met'
Met = mapAontoBOld([dATM.Edges.HeadAtom; dATM.Edges.TailAtom],dATM.Nodes.Name,[dATM.Edges.HeadMet; dATM.Edges.TailMet]);
% 'AtomNumber'
AtomNumber = mapAontoBOld([dATM.Edges.HeadAtom; dATM.Edges.TailAtom],dATM.Nodes.Name,[dATM.Edges.HeadMetAtomNumber; dATM.Edges.TailMetAtomNumber]);
% 'Element'
Element = mapAontoBOld([dATM.Edges.HeadAtom; dATM.Edges.TailAtom],dATM.Nodes.Name,[dATM.Edges.Element; dATM.Edges.Element]);

dATM.Nodes = addvars(dATM.Nodes,Atom,AtomIndex,Met,AtomNumber,Element,'NewVariableNames',{'Atom','AtomIndex','mets','AtomNumber','Element'});

dATM.Edges.HeadAtomIndex = mapAontoBOld(dATM.Nodes.Name,dATM.Edges.EndNodes(:,1),dATM.Nodes.AtomIndex);
dATM.Edges.TailAtomIndex = mapAontoBOld(dATM.Nodes.Name,dATM.Edges.EndNodes(:,2),dATM.Nodes.AtomIndex);

%Create a numeric version, where the alphanumeric EndNodes are replaced by Atom indices
Nodes = dATM.Nodes;
Nodes = removevars(Nodes,'Name');
Edges = dATM.Edges;
Edges.EndNodes = [Edges.HeadAtomIndex, Edges.TailAtomIndex];
dATM = digraph(Edges,Nodes);
dATM.Edges.TransInstIndex = (1:size(dATM.Edges,1))';
dATM.Edges.dirTransInstIndex = (1:size(dATM.Edges,1))';

rxnAtomMappedBool = ismember(model.rxns,dATM.Edges.rxns); % True for reactions included in dATM
metAtomMappedBool = ismember(model.mets,dATM.Nodes.mets); % True for metabolites included in dATM

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
[~,atoms2mets] = ismember(dATM.Nodes.mets,model.mets(metAtomMappedBool));
M2Ai = sparse(atoms2mets,(1:nAtoms)',1,nMappedMets,nAtoms);

%matrix mapping one or more directed atom transition instances to each mapped reaction
nTransInstances = size(dATM.Edges,1);
[~,transInstance2rxns] = ismember(dATM.Edges.rxns,model.rxns(rxnAtomMappedBool));
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
%% Build bond transition network....(to edit)
%                   * .Nodes — Table of node information, with `q` rows, one for each bond.
%                   * .Nodes.Bond - unique alphanumeric id for each bond by
%                   concatenation of the unique alphanumeric id for the
%                   head atom and the tail atom.
%                   * .Nodes.....
%                   * .Nodes.BondIndex - unique numeric id for each bond in bond transition multigraph
%                   * .Nodes.mets - metabolite containing each bond
%                   * .Nodes.
%                   * .Nodes.
%                   * .Edges — Table of edge information, with `q` rows, one for each atom transition instance.
%                   * .Edges.EndNodes - two-column cell array of character vectors that defines the graph edges
%                   * .Edges.Trans - unique alphanumeric id for each atom transition instance by concatenation of the reaction, head and tail atoms
%                   * .Edges.TransIstIndex - unique numeric id for each directed atom transition instance
%                   * .Edges.OrigTransIstIndex - unique numeric id for each atom transition instance, with original ordering of data
%                   * .Edges.Rxn - reaction corresponding to each atom transition
%                   * .Edges.HeadAtomIndex - head Nodes.AtomIndex
%                   * .Edges.TailAtomIndex - tail Nodes.AtomIndex
if  options.bondTransitionMultigraph
%Add energy node to dATM (an additional node that represents the energy used to break or build chemical bonds)
%EnergyNode=table({'E'}', size(dATM.Nodes, 1)+1, {'energy'}', 1, {'E'}', 'VariableNames', {'Atom' 'AtomIndex' 'mets' 'AtomNumber' 'Element'});
%dATME= addnode(dATM, EnergyNode);
%Find nToatalBondTransitions
%nTotalBondTransitions=66;
EdgeTable = table(...
    cell(nTotalBondTransitions,2),...
    cell(nTotalBondTransitions,1),...
    zeros(nTotalBondTransitions,1),...
    zeros(nTotalBondTransitions,1),...
    cell(nTotalBondTransitions,1),...
    cell(nTotalBondTransitions,1),...
    cell(nTotalBondTransitions,1),...
    cell(nTotalBondTransitions,1),...
    zeros(nTotalBondTransitions,1),...
    zeros(nTotalBondTransitions,1),...
    zeros(nTotalBondTransitions,1),...
    zeros(nTotalBondTransitions,1),...
    cell(nTotalBondTransitions,1),...
    zeros(nTotalBondTransitions,1),...
    zeros(nTotalBondTransitions,1),...
    cell(nTotalBondTransitions,1),...
    cell(nTotalBondTransitions,1),...
    cell(nTotalBondTransitions,1),...
    cell(nTotalBondTransitions,1),...
    cell(nTotalBondTransitions,1),...
    cell(nTotalBondTransitions,1),...
    zeros(nTotalBondTransitions,1),...
    zeros(nTotalBondTransitions,1),...
    'VariableNames',{'EndNodes','Trans','TransInstIndex','dirTransInstIndex','HeadBondHeadAtom','HeadBondTailAtom','TailBondHeadAtom','TailBondTailAtom','HeadBondHeadAtomIndex','HeadBondTailAtomIndex','TailBondHeadAtomIndex','TailBondTailAtomIndex','rxns','HeadBondIndex','TailBondIndex',...
    'HeadBond','TailBond','HeadBondElmts','TailBondElmts','HeadMet','TailMet','HeadMetBondTypes','TailMetBondTypes'});
k=1;
%nTotalBonds=0;
% Ground truth bond count per metabolite, read once from each metabolite's own RXN-file
% molblock (feature 019-canonicalize-bond-node-keys, FR-008 per-metabolite sanity check)
metBondCountGroundTruth = containers.Map('KeyType','char','ValueType','double');
% Symmetry/resonance equivalence-class canonicalization caches, computed once per
% metabolite the first time it is seen (feature 020-canonicalize-symmetric-atom-bonds,
% FR-001/FR-002/FR-005): metAtomCanonicalRankMap/metUnsafeNeighborsMap map a metabolite
% identifier to its own containers.Map (see identifyAtomEquivalenceClasses.m).
% metBondTypeFirstSeen maps a canonicalized bond-node key to the bond type recorded the
% first time that key was encountered, so a resonance-ambiguous bond's formal type
% resolves deterministically (FR-003) rather than via mapAontoBOld's incidental
% Head-before-Tail duplicate-key resolution (research R7).
metAtomCanonicalRankMap = containers.Map('KeyType','char','ValueType','any');
metUnsafeNeighborsMap = containers.Map('KeyType','char','ValueType','any');
metBondTypeFirstSeen = containers.Map('KeyType','char','ValueType','double');
% Build bond transition network
for i = 1:nRxns
    if rbool(i)
        try
            [atoms,bonds] = readABRXNFile(model.rxns{i},RXNFileDir);
            [bondMappings] = addBondMappingsRXNFile(model.rxns{i},RXNFileDir);
            % record each metabolite's true bond count (one instance only) the first time it is seen
            firstInstanceBondMets = unique(bonds.mets(bonds.instances==1));
            for bMetIdx = 1:numel(firstInstanceBondMets)
                bMet = firstInstanceBondMets{bMetIdx};
                if ~isKey(metBondCountGroundTruth, bMet)
                    metBondCountGroundTruth(bMet) = nnz(strcmp(bonds.mets, bMet) & bonds.instances==1);
                end
                if ~isKey(metAtomCanonicalRankMap, bMet)
                    metAtomBool = strcmp(atoms.mets, bMet) & atoms.instances==1;
                    metBondBool = strcmp(bonds.mets, bMet) & bonds.instances==1;
                    [canonicalRankMap, ~, unsafeNeighborsMap] = identifyAtomEquivalenceClasses(...
                        atoms.metNrs(metAtomBool), atoms.elements(metAtomBool), ...
                        bonds.headAtoms(metBondBool), bonds.tailAtoms(metBondBool), bonds.bTypes(metBondBool), bMet);
                    metAtomCanonicalRankMap(bMet) = canonicalRankMap;
                    metUnsafeNeighborsMap(bMet) = unsafeNeighborsMap;
                end
            end
            %Add energy node to dATM for each reaction(an additional node that represents the energy used to break or build chemical bonds)
            EnergyNode=table({'E'}', size(dATM.Nodes, 1)+1, {model.rxns{i}}', 1, {'E'}', 'VariableNames', {'Atom' 'AtomIndex' 'mets' 'AtomNumber' 'Element'});
            dATME= addnode(dATM, EnergyNode);
            %add atomNumber to headAtoms of energy node
            %bondMappings.headAtoms(ismember(bondMappings.mets,'energy'))=dATME.Nodes.AtomNumber(ismember(dATME.Nodes.mets,'energy'));
            bondMappings.headAtoms(ismember(bondMappings.mets,model.rxns{i}))=dATME.Nodes.AtomNumber(ismember(dATME.Nodes.mets,model.rxns{i}));
            %add atomNumber to tailAtoms of energy node
            %bondMappings.tailAtoms(ismember(bondMappings.mets,'energy'))=dATME.Nodes.AtomNumber(ismember(dATME.Nodes.mets,'energy'));
            bondMappings.tailAtoms(ismember(bondMappings.mets,model.rxns{i}))=dATME.Nodes.AtomNumber(ismember(dATME.Nodes.mets,model.rxns{i}));
            %nTotalBonds=nTotalBonds+size(bonds,1)
            %Check that stoichiometry in rxnfile matches the one in S(already done in atom section)
            rxnMets = unique(atoms.mets);
            for j=1:max(bondMappings.bondTransitionNrs)
                substrateBondNumber = find(bondMappings.bondTransitionNrs==j & bondMappings.isSubstrate);
                productBondNumber = find(bondMappings.bondTransitionNrs==j & ~bondMappings.isSubstrate);
                % Symmetry/resonance equivalence-class canonicalization (feature
                % 020-canonicalize-symmetric-atom-bonds, FR-002): remap each bond's raw atom
                % numbers to their equivalence class's canonical representative before
                % canonicalBondKey orders them, so canonicalBondKey's existing atom-number
                % sort correctly collapses a symmetric/resonance-ambiguous bond onto one
                % identity regardless of which RXN file supplied it. canonicalBondKey.m
                % itself is unchanged (research R6).
                [substrateHeadAtomNum, substrateTailAtomNum] = safeCanonicalizeBondAtoms(...
                    bondMappings.mets{substrateBondNumber}, bondMappings.headAtoms(substrateBondNumber), ...
                    bondMappings.tailAtoms(substrateBondNumber), metAtomCanonicalRankMap, metUnsafeNeighborsMap);
                [productHeadAtomNum, productTailAtomNum] = safeCanonicalizeBondAtoms(...
                    bondMappings.mets{productBondNumber}, bondMappings.headAtoms(productBondNumber), ...
                    bondMappings.tailAtoms(productBondNumber), metAtomCanonicalRankMap, metUnsafeNeighborsMap);
                [bondSubstrateID, subMet1, subAtomNum1, subElem1, subMet2, subAtomNum2, subElem2] = canonicalBondKey(...
                    bondMappings.mets{substrateBondNumber}, substrateHeadAtomNum, bondMappings.headAtomElements{substrateBondNumber},...
                    bondMappings.mets{substrateBondNumber}, substrateTailAtomNum, bondMappings.tailAtomElements{substrateBondNumber});
                [bondProductID, prodMet1, prodAtomNum1, prodElem1, prodMet2, prodAtomNum2, prodElem2] = canonicalBondKey(...
                    bondMappings.mets{productBondNumber}, productHeadAtomNum, bondMappings.headAtomElements{productBondNumber},...
                    bondMappings.mets{productBondNumber}, productTailAtomNum, bondMappings.tailAtomElements{productBondNumber}); %Add the type of bonds (30/08/2024)
                bondSubstrateType=[subElem1 '-' subElem2];%
                bondProductType=[prodElem1 '-' prodElem2];%
                % First-seen bond-type cache (feature 020, FR-003): record each canonicalized
                % bond-node's bond type only the first time that key is encountered.
                if ~isKey(metBondTypeFirstSeen, bondSubstrateID)
                    metBondTypeFirstSeen(bondSubstrateID) = bondMappings.bTypes(substrateBondNumber);
                end
                if ~isKey(metBondTypeFirstSeen, bondProductID)
                    metBondTypeFirstSeen(bondProductID) = bondMappings.bTypes(productBondNumber);
                end
                EdgeTable.EndNodes{k,1} = bondSubstrateID;
                EdgeTable.EndNodes{k,2} = bondProductID;
                EdgeTable.Trans{k} = [model.rxns{i}  '#' bondSubstrateID '#' bondProductID];
                EdgeTable.TransInstIndex(k) = k;
                EdgeTable.dirTransInstIndex(k) = k;
                EdgeTable.HeadBondHeadAtom(k)=dATME.Nodes.Atom((ismember(dATME.Nodes.mets,subMet1))&(dATME.Nodes.AtomNumber==subAtomNum1)&(ismember(dATME.Nodes.Element,subElem1)));
                EdgeTable.HeadBondTailAtom(k)=dATME.Nodes.Atom((ismember(dATME.Nodes.mets,subMet2))&(dATME.Nodes.AtomNumber==subAtomNum2)&(ismember(dATME.Nodes.Element,subElem2)));
                EdgeTable.TailBondHeadAtom(k)=dATME.Nodes.Atom((ismember(dATME.Nodes.mets,prodMet1))&(dATME.Nodes.AtomNumber==prodAtomNum1)&(ismember(dATME.Nodes.Element,prodElem1)));
                EdgeTable.TailBondTailAtom(k)=dATME.Nodes.Atom((ismember(dATME.Nodes.mets,prodMet2))&(dATME.Nodes.AtomNumber==prodAtomNum2)&(ismember(dATME.Nodes.Element,prodElem2)));
                EdgeTable.HeadBondHeadAtomIndex(k)=dATME.Nodes.AtomIndex((ismember(dATME.Nodes.mets,subMet1))&(dATME.Nodes.AtomNumber==subAtomNum1)&(ismember(dATME.Nodes.Element,subElem1)));
                EdgeTable.HeadBondTailAtomIndex(k)=dATME.Nodes.AtomIndex((ismember(dATME.Nodes.mets,subMet2))&(dATME.Nodes.AtomNumber==subAtomNum2)&(ismember(dATME.Nodes.Element,subElem2)));
                EdgeTable.TailBondHeadAtomIndex(k)=dATME.Nodes.AtomIndex((ismember(dATME.Nodes.mets,prodMet1))&(dATME.Nodes.AtomNumber==prodAtomNum1)&(ismember(dATME.Nodes.Element,prodElem1)));
                EdgeTable.TailBondTailAtomIndex(k)=dATME.Nodes.AtomIndex((ismember(dATME.Nodes.mets,prodMet2))&(dATME.Nodes.AtomNumber==prodAtomNum2)&(ismember(dATME.Nodes.Element,prodElem2)));
                EdgeTable.rxns{k} = model.rxns{i};
                EdgeTable.HeadBondIndex(k) = NaN;
                EdgeTable.TailBondIndex(k) = NaN;
                EdgeTable.HeadBond{k} = bondSubstrateID;
                EdgeTable.TailBond{k} = bondProductID;
                EdgeTable.HeadBondElmts(k) = {bondSubstrateType};%%
                EdgeTable.TailBondElmts(k) = {bondProductType};%%
                EdgeTable.HeadMet{k} = bondMappings.mets{substrateBondNumber};
                EdgeTable.TailMet{k} = bondMappings.mets{productBondNumber};
                EdgeTable.HeadMetBondTypes(k) = bondMappings.bTypes(substrateBondNumber);
                EdgeTable.TailMetBondTypes(k) = bondMappings.bTypes(productBondNumber);
                k=k+1;
                end
        catch ME
            % SPECKIT OVERRIDE (2026-09-02): this loop had no try/catch at all,
            % unlike the equivalent atom-transition loop above it -- a single
            % malformed or unparseable RXN file here crashed the whole pipeline
            % with no diagnostic. Mirror the atom-transition loop's log-and-skip
            % behavior instead of aborting the run.
            fprintf('%s%s%s\n','Reaction file ', model.rxns{i}, ...
                '.rxn could not be parsed for bond mappings and was skipped.')
            disp(getReport(ME))
        end
    end
end

%% Directed bond transition multigraph as a matlab directed multigraph object
dBTM = digraph(EdgeTable);


% 'Bond'
Bond =  mapAontoBOld([dBTM.Edges.HeadBond; dBTM.Edges.TailBond],dBTM.Nodes.Name,[dBTM.Edges.HeadBond; dBTM.Edges.TailBond]);
%'Bond Type with elements only'
%BondElmts =  mapAontoBOld([dBTM.Edges.HeadBondElmts; dBTM.Edges.TailBondElmts],dBTM.Nodes.Name,[dBTM.Edges.HeadBondElmts; dBTM.Edges.TailBondElmts]);
BondElmts=cell(length(Bond),1);
% 'AtomIndex'
BondIndex = (1:size(dBTM.Nodes,1))';
% 'Met'
Met = mapAontoBOld([dBTM.Edges.HeadBond; dBTM.Edges.TailBond],dBTM.Nodes.Name,[dBTM.Edges.HeadMet; dBTM.Edges.TailMet]);
% 'AtomNumber'
BondType = mapAontoBOld([dBTM.Edges.HeadBond; dBTM.Edges.TailBond],dBTM.Nodes.Name,[dBTM.Edges.HeadMetBondTypes; dBTM.Edges.TailMetBondTypes]);
% First-seen bond-type override (feature 020-canonicalize-symmetric-atom-bonds, FR-003):
% mapAontoBOld's duplicate-key resolution (lowest index in a Head-before-Tail-concatenated
% key list) is deterministic per run but not intentionally "first RXN file encountered for
% this metabolite" -- override from the explicit first-seen cache built above (research R7)
% so a resonance-ambiguous bond's formal type is deterministic and traceable to a specific,
% named rule rather than an incidental property of the edge-construction order.
for bondTypeNodeIdx = 1:numel(BondType)
    if isKey(metBondTypeFirstSeen, dBTM.Nodes.Name{bondTypeNodeIdx})
        BondType(bondTypeNodeIdx) = metBondTypeFirstSeen(dBTM.Nodes.Name{bondTypeNodeIdx});
    end
end
HeadBondHeadAtomIndex=mapAontoBOld(dBTM.Edges.EndNodes(:,1),dBTM.Nodes.Name,dBTM.Edges.HeadBondHeadAtomIndex);
TailBondHeadAtomIndex=mapAontoBOld(dBTM.Edges.EndNodes(:,2),dBTM.Nodes.Name,dBTM.Edges.TailBondHeadAtomIndex);
HeadBondHeadAtomIndex(isnan(HeadBondHeadAtomIndex))=TailBondHeadAtomIndex(isnan(HeadBondHeadAtomIndex));
BondHeadAtomIndex=HeadBondHeadAtomIndex;
HeadBondTailAtomIndex=mapAontoBOld(dBTM.Edges.EndNodes(:,1),dBTM.Nodes.Name,dBTM.Edges.HeadBondTailAtomIndex);
TailBondTailAtomIndex=mapAontoBOld(dBTM.Edges.EndNodes(:,2),dBTM.Nodes.Name,dBTM.Edges.TailBondTailAtomIndex);
HeadBondTailAtomIndex(isnan(HeadBondTailAtomIndex))=TailBondTailAtomIndex(isnan(HeadBondTailAtomIndex));
BondTailAtomIndex=HeadBondTailAtomIndex;

HeadBondHeadAtom=mapAontoBOld(dBTM.Edges.EndNodes(:,1),dBTM.Nodes.Name,dBTM.Edges.HeadBondHeadAtom);
TailBondHeadAtom=mapAontoBOld(dBTM.Edges.EndNodes(:,2),dBTM.Nodes.Name,dBTM.Edges.TailBondHeadAtom);
HeadBondHeadAtom(find(cellfun(@isempty,HeadBondHeadAtom)))=TailBondHeadAtom(find(cellfun(@isempty,HeadBondHeadAtom)));
BondHeadAtom=HeadBondHeadAtom;
HeadBondTailAtom=mapAontoBOld(dBTM.Edges.EndNodes(:,1),dBTM.Nodes.Name,dBTM.Edges.HeadBondTailAtom);
TailBondTailAtom=mapAontoBOld(dBTM.Edges.EndNodes(:,2),dBTM.Nodes.Name,dBTM.Edges.TailBondTailAtom);
HeadBondTailAtom(find(cellfun(@isempty,HeadBondTailAtom)))=TailBondTailAtom(find(cellfun(@isempty,HeadBondTailAtom)));
BondTailAtom=HeadBondTailAtom;
dBTM.Nodes = addvars(dBTM.Nodes,Bond,BondIndex,BondElmts,BondHeadAtom,BondTailAtom,BondHeadAtomIndex,BondTailAtomIndex,Met,BondType,'NewVariableNames',{'Bond','BondIndex','BondElmts','BondHeadAtom','BondTailAtom','BondHeadAtomIndex','BondTailAtomIndex','mets','BondType'});
%Add bond Elements
for i=1:size(dBTM.Nodes,1)
    bondTail=dBTM.Nodes.BondHeadAtomIndex(i);
    bondHead=dBTM.Nodes.BondTailAtomIndex(i);
    dBTM.Nodes.BondElmts(i)={[dATME.Nodes.Element{bondTail} '-' dATME.Nodes.Element{bondHead}]};
end


dBTM.Edges.HeadBondIndex = mapAontoBOld(dBTM.Nodes.Name,dBTM.Edges.EndNodes(:,1),dBTM.Nodes.BondIndex);
dBTM.Edges.TailBondIndex = mapAontoBOld(dBTM.Nodes.Name,dBTM.Edges.EndNodes(:,2),dBTM.Nodes.BondIndex);
%Create a numeric version, where the alphanumeric EndNodes are replaced by Bond indices
Nodes = dBTM.Nodes;
Nodes = removevars(Nodes,'Name');
Edges = dBTM.Edges;
Edges = removevars(Edges,["HeadBondHeadAtom","HeadBondTailAtom","TailBondHeadAtom","TailBondTailAtom","HeadBondHeadAtomIndex","HeadBondTailAtomIndex","TailBondHeadAtomIndex","TailBondTailAtomIndex"]);
Edges.EndNodes = [Edges.HeadBondIndex, Edges.TailBondIndex];
dBTM = digraph(Edges,Nodes);
dBTM.Edges.TransInstIndex = (1:size(dBTM.Edges,1))';
dBTM.Edges.dirTransInstIndex = (1:size(dBTM.Edges,1))';

%Create the molecular graphs
EdgeTableBond=table([dBTM.Nodes.BondHeadAtomIndex dBTM.Nodes.BondTailAtomIndex], full(dBTM.Nodes.BondType), dBTM.Nodes.Bond, full(dBTM.Nodes.BondIndex),dBTM.Nodes.BondHeadAtom, dBTM.Nodes.BondTailAtom, dBTM.Nodes.mets, 'VariableNames',{'EndNodes' 'Weight' 'Bond' 'BondIndex' 'BondHeadAtom' 'BondTailAtom' 'mets'});
BG=graph(EdgeTableBond,dATME.Nodes);

rxnBondMappedBool = ismember(model.rxns,dBTM.Edges.rxns); % True for reactions included in dBTM
metBondMappedBool = ismember(model.mets,dBTM.Nodes.mets(~ismember(dBTM.Nodes.Bond,{'E'}))); % True for metabolites included in dBTM

if any(mbool & ~metBondMappedBool)
    fprintf('%u%s%u%s\n',nnz(mbool), ' metabolites should be bond mapped, but only ' ,nnz(metBondMappedBool), ' in the dBTM:')
    disp(model.mets(mbool & ~metBondMappedBool))    
end
if any(rbool & ~rxnBondMappedBool)
    fprintf('%u%s%u%s\n',nnz(rbool), ' reactions should be bond mapped, but only ' ,nnz(rxnBondMappedBool), ' in the dBTM:')
    disp(model.rxns(rbool & ~rxnBondMappedBool))
end
%need to extract again because there may be problems reading an individual bond mapping
N = sparse(model.S(metBondMappedBool,rxnBondMappedBool)); % Stoichometric matrix of atom mapped reactions
[nBondMappedMets,nBondMappedRxns] = size(N);

if options.sanityChecks
    %double check that there is no reordering of nodes
    diffIndex = diff(dBTM.Nodes.BondIndex);
    if any(diffIndex~=1)
        fprintf('%s\n','reordering of nodes of moiety transition graph')
    end
end

if options.sanityChecks
    %double check that there is no reordering of edges
    diffIndex = diff(dBTM.Edges.TransInstIndex);
    if any(diffIndex~=1)
        fprintf('%s\n','reordering of edges of moiety transition graph')
    end
end

if options.sanityChecks
    % For each atom/bond-mapped metabolite, the number of distinct bond nodes in dBTM.Nodes
    % attributed to it must equal that metabolite's own bond count, read once from its
    % canonical RXN-file molblock (not summed across reactions). A mismatch here is a hard
    % signal of a node-key collision or duplication bug (feature 019-canonicalize-bond-node-keys,
    % FR-008), reported as a non-fatal warning consistent with this function's other sanity
    % checks -- pipeline execution continues and return values are unaffected.
    bondMappedMets = model.mets(metBondMappedBool);
    for metIdx = 1:numel(bondMappedMets)
        met = bondMappedMets{metIdx};
        if isKey(metBondCountGroundTruth, met)
            actualBondNodeCount = nnz(strcmp(dBTM.Nodes.mets, met));
            trueBondCount = metBondCountGroundTruth(met);
            if actualBondNodeCount ~= trueBondCount
                warning('%s bond-graph node count (%d) does not match its true bond count (%d) from its own RXN-file molblock.', met, actualBondNodeCount, trueBondCount);
            end
        end
    end
end

%matrix to map each metabolite to one or more bonds
nBonds = size(dBTM.Nodes,1);
%[~,bonds2mets] = ismember(dBTM.Nodes.Met,model.mets(metBondMappedBool));
%M2Bi = full(sparse(bonds2mets,(1:nBonds)',1,nMappedMets,nBonds));
M2BiE=zeros(length(model.mets),nBonds);
for i=1:length(model.mets)
    M2BiE(i,:)=(ismember(dBTM.Nodes.mets,model.mets(i)))';
end

%Matrix that specifies the type of chemical bonds in M2Bi
M2BiW=zeros(length(model.mets),nBonds);
for i=1:length(model.mets)
    bondId=find(ismember(dBTM.Nodes.mets,model.mets(i)));
    M2BiW(i,bondId)=dBTM.Nodes.BondType(bondId);
end

%Matrix mapping one or more directed atom transition instances to each mapped reaction
nTransInstances = size(dBTM.Edges,1);
[~,transInstance2rxns] = ismember(dBTM.Edges.rxns,model.rxns(rxnBondMappedBool));
BTi2R = full(sparse((1:nTransInstances)',transInstance2rxns,1,nTransInstances,nMappedRxns));

% %Matrix R2Bi taht maps each bond to each reaction in the network
% R2Bi=zeros(nBonds,length(model.rxns));
% for i=1:length(model.rxns)
%    idx=unique([dBTM.Edges.HeadBondIndex(ismember(dBTM.Edges.Rxn,model.rxns(i)));dBTM.Edges.TailBondIndex(ismember(dBTM.Edges.Rxn,model.rxns(i)))]);
%    R2Bi(idx,i)=1;
% end

%Incidence matrix of directed bond transition multigraph
BTiE= incidence(dBTM);

if options.sanityChecks   
    bool=~any(BTiE,1);
    if any(bool)
        error('Bond transition matrix must not have any zero columns.')
    end
    bool=~any(BTiE,2);
    if any(bool)
        error('Bond transition matrix must not have any zero rows.')
    end
    
    colNonZeroCount=(BTiE~=0)'*ones(size(BTiE,1),1);
    if any(colNonZeroCount~=2)
        error('Bond transition matrix must have two entries per column.')
    end
    
    colCount=BTiE'*ones(size(BTiE,1),1);
    if any(colCount~=0)
        error('Bond transition matrix must have two entries per column, -1 and 1.')
    end
    
    %These atoms must be exchanged by reactions across the boundary of the system otherwise they cannot be produced or consumed.
    rowNonZeroCount=(BTiE~=0)*ones(size(BTiE,2),1);
    rowsWithOnlyOneEntryBool = rowNonZeroCount==1;
    rowsWithoutPositiveEntryBool = sum(BTiE>0,2)==0;
    rowsWithoutNegativeEntryBool = sum(BTiE<0,2)==0;
     
    if any(rowsWithOnlyOneEntryBool)
        fprintf('%u\t%s\n',nnz(rowsWithOnlyOneEntryBool), 'rows of TiE = incidence(dBTM), with only one entry.')
        bondsOnlyCosumed = dBTM.Nodes(rowsWithoutPositiveEntryBool,:);
    end
    
    if any(rowsWithoutPositiveEntryBool)
        fprintf('%u\t%s\n',nnz(rowsWithOnlyOneEntryBool & rowsWithoutPositiveEntryBool), 'rows of TiE = incidence(dBTM), with only one negative entry and no positive entry.')
        bondsOnlyCosumed = dBTM.Nodes(rowsWithOnlyOneEntryBool & rowsWithoutPositiveEntryBool,:);
    end
    
    if any(rowsWithoutNegativeEntryBool)
        fprintf('%u\t%s\n',nnz(rowsWithOnlyOneEntryBool & rowsWithoutNegativeEntryBool), 'rows of TiE = incidence(dBTM), with only one positive entry and no negative entry.')
        bondsOnlyProduced = dBTM.Nodes(rowsWithOnlyOneEntryBool & rowsWithoutNegativeEntryBool,:);
    end
end


%Decomposition in terms of bonds
%Check the formula for the stoichiometric matrix without the protons (no bonds in a proton)
%res=(M2BiW*M2BiE')*N - M2BiE*BTiE*BTi2R;
res=(M2BiW(metBondMappedBool,:)*M2BiE(metBondMappedBool,:)')*N - M2BiE(metBondMappedBool,:)*BTiE*BTi2R;
if max(max(abs(res)))~=0
    metsAll = model.mets(metBondMappedBool);   % was: model.mets(~hBool)
    rxns = model.rxns(rxnBondMappedBool);
     d  = diag(M2BiE*M2BiW');
     D  = spdiags(1./d,0,length(d),length(d));
    N2  = D*M2BiE*BTiE*BTi2R;
    N2  = N2(metBondMappedBool,:);   % was: N2(~hBool,:)
    fprintf('%s\n','Inconsistency between reaction stoichiometry and bond mapped reactions (inconsistent stoichiometry?):')
    for j=1:size(res,2)
        if any(res(:,j)~=0)
            %fprintf('%s\n',rxns{j})
            printRxnFormula(model,rxns{j});
            fprintf('%s\t\t%s\t\t%s\n','res','N','N2')
            for i=1:size(res,1)
                if res(i,j)~=0
                    fprintf('%i\t%s\t%i\t%s\t%i\t%s\n',full(res(i,j)),metsAll{i},full(N(i,j)),metsAll{i},full(N2(i,j)),metsAll{i})
                end
            end
            fprintf('\n')
        end
    end
    warning('Inconsistent directed bond transition multigraph')
end

else

end

end

function [headOut, tailOut] = safeCanonicalizeBondAtoms(met, headRaw, tailRaw, canonicalRankMapByMet, unsafeNeighborsMapByMet)
% Remap a bond's raw head/tail atom numbers to their symmetry-equivalence-class
% canonical representative, for one metabolite (feature 020-canonicalize-symmetric-atom-bonds).
% A metabolite absent from canonicalRankMapByMet (e.g. a reaction's energy pseudo-node)
% is passed through unchanged.
headOut = headRaw;
tailOut = tailRaw;
if ~isKey(canonicalRankMapByMet, met)
    return;
end
rankMap = canonicalRankMapByMet(met);
unsafeMap = unsafeNeighborsMapByMet(met);
headOut = safeCanonicalizeOneAtom(headRaw, tailRaw, rankMap, unsafeMap);
tailOut = safeCanonicalizeOneAtom(tailRaw, headRaw, rankMap, unsafeMap);
end

function atomOut = safeCanonicalizeOneAtom(atomRaw, otherAtomRaw, rankMap, unsafeMap)
% Substitute atomRaw's equivalence-class canonical representative, UNLESS the bond's
% other endpoint (otherAtomRaw) is itself simultaneously bonded to another member of
% atomRaw's class -- substituting in that case would collapse two genuinely distinct,
% simultaneously-present bonds onto one canonical key (e.g. a gem-dimethyl pair's shared
% backbone carbon), undercounting the metabolite's true bond count.
atomOut = atomRaw;
if ~isKey(rankMap, atomRaw)
    return;
end
canonicalRep = rankMap(atomRaw);
if canonicalRep == atomRaw
    return; % already canonical (singleton class, or this class's own minimum)
end
if isKey(unsafeMap, canonicalRep) && ismember(otherAtomRaw, unsafeMap(canonicalRep))
    return; % unsafe: the other endpoint is also bonded to another member of this class
end
atomOut = canonicalRep;
end
