function [dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R, dATME, BG ,dBTM, M2BiE, M2BiW,BTi2R, BTiE] = buildAtomAndBondTransitionMultigraph(model, RXNFileDir, options)
% Builds a matlab digraph object representing an atom transition multigraph
% and a bond transition multigraph
% corresponding to a metabolic network from reaction stoichiometry and atom
% mappings.
%-----Atoms
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
%---Bonds
%Note that B = incidence(dBTM) returns a  `b` x `s` bond transition 
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
%    options: A structure that contains two fields representing
%    customisable options for the function.
%                 * .sanityChecks - A boolean variable that controls whether
%                 sanity checks are performed within the function.
%                 * .bondTransitionMultigraph - A boolean variable that
%                 specifies whether the function generates the bond transition
%                 multigraph.
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
% metRXNBool:       `m x 1` boolean vector indicating atom mapped metabolites
% rxnRXNBool:       `n x 1` boolean vector indicating atom mapped reactions
% M2Ai              `m` x `a` matrix mapping each metabolite to an atom in the directed atom transition multigraph 
% Ti2R              `t` x `n` matrix mapping each directed atom transition instance to a mapped reaction
%
% The internal stoichiometric matrix may be decomposition into
% N = (M2Ai*M2Ai)^(-1)*M2Ai*Ti*Ti2R;
% where Ti = incidence(dATM), is incidence matrix of directed atom transition multigraph.
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
% metRXNBool:       `m x 1` boolean vector indicating bond mapped metabolites
% rxnRXNBool:       `n x 1` boolean vector indicating bond mapped reactions
% M2Bi              `m` x `b` matrix mapping each metabolite to an bond in the directed bond transition multigraph 
% BTi2R             `s` x `n` matrix mapping each directed bond transition instance to a mapped reaction
%
% The internal stoichiometric matrix may be decomposition into
% N= (M2Bi*M2Bi')^(-1)*M2Bi*B*BTi2R  (To edit)
% where BTi = incidence(dBTM), is incidence matrix of directed bond transition multigraph.

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
            
            if ~exist([RXNFileDir filesep 'not_parsed'],'dir')
                mkdir([RXNFileDir filesep 'not_parsed'])
            end
            %[SUCCESS,~,~] = movefile([RXNFileDir filesep model.rxns{i} '.rxn'],[RXNFileDir filesep 'not_parsed' filesep model.rxns{i} '.rxn']); %Hadjar
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
% Build bond transition network
for i = 1:nRxns
    [atoms,bonds] = readABRXNFile(model.rxns{i},RXNFileDir);
    [bondMappings] = addBondMappingsRXNFile(model.rxns{i},RXNFileDir);
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
             bondSubstrateID =[bondMappings.mets{substrateBondNumber}...
                    '#' num2str(bondMappings.headAtoms(substrateBondNumber))...
                    '#' bondMappings.headAtomElements{substrateBondNumber}...
                    '#' bondMappings.mets{substrateBondNumber}...
                    '#' num2str(bondMappings.tailAtoms(substrateBondNumber))...
                    '#' bondMappings.tailAtomElements{substrateBondNumber}];
              bondProductID =[bondMappings.mets{productBondNumber}...
                    '#' num2str(bondMappings.headAtoms(productBondNumber))...
                    '#' bondMappings.headAtomElements{productBondNumber}...
                    '#' bondMappings.mets{productBondNumber}...
                    '#' num2str(bondMappings.tailAtoms(productBondNumber))...
                    '#' bondMappings.tailAtomElements{productBondNumber}]; %Add the type of bonds (30/08/2024)
               bondSubstrateType=[bondMappings.headAtomElements{substrateBondNumber} '-' bondMappings.tailAtomElements{substrateBondNumber}];%
               bondProductType=[bondMappings.headAtomElements{productBondNumber} '-' bondMappings.tailAtomElements{productBondNumber}];%
               EdgeTable.EndNodes{k,1} = bondSubstrateID;
               EdgeTable.EndNodes{k,2} = bondProductID;
               EdgeTable.Trans{k} = [model.rxns{i}  '#' bondSubstrateID '#' bondProductID];
               EdgeTable.TransInstIndex(k) = k;
               EdgeTable.dirTransInstIndex(k) = k;
               EdgeTable.HeadBondHeadAtom(k)=dATME.Nodes.Atom((ismember(dATME.Nodes.mets,bondMappings.mets{substrateBondNumber}))&(dATME.Nodes.AtomNumber==bondMappings.headAtoms(substrateBondNumber))&(ismember(dATME.Nodes.Element,bondMappings.headAtomElements{substrateBondNumber})));
               EdgeTable.HeadBondTailAtom(k)=dATME.Nodes.Atom((ismember(dATME.Nodes.mets,bondMappings.mets{substrateBondNumber}))&(dATME.Nodes.AtomNumber==bondMappings.tailAtoms(substrateBondNumber))&(ismember(dATME.Nodes.Element,bondMappings.tailAtomElements{substrateBondNumber})));
               EdgeTable.TailBondHeadAtom(k)=dATME.Nodes.Atom((ismember(dATME.Nodes.mets,bondMappings.mets{productBondNumber}))&(dATME.Nodes.AtomNumber==bondMappings.headAtoms(productBondNumber))&(ismember(dATME.Nodes.Element,bondMappings.headAtomElements{productBondNumber})));
               EdgeTable.TailBondTailAtom(k)=dATME.Nodes.Atom((ismember(dATME.Nodes.mets,bondMappings.mets{productBondNumber}))&(dATME.Nodes.AtomNumber==bondMappings.tailAtoms(productBondNumber))&(ismember(dATME.Nodes.Element,bondMappings.tailAtomElements{productBondNumber})));
               EdgeTable.HeadBondHeadAtomIndex(k)=dATME.Nodes.AtomIndex((ismember(dATME.Nodes.mets,bondMappings.mets{substrateBondNumber}))&(dATME.Nodes.AtomNumber==bondMappings.headAtoms(substrateBondNumber))&(ismember(dATME.Nodes.Element,bondMappings.headAtomElements{substrateBondNumber})));
               EdgeTable.HeadBondTailAtomIndex(k)=dATME.Nodes.AtomIndex((ismember(dATME.Nodes.mets,bondMappings.mets{substrateBondNumber}))&(dATME.Nodes.AtomNumber==bondMappings.tailAtoms(substrateBondNumber))&(ismember(dATME.Nodes.Element,bondMappings.tailAtomElements{substrateBondNumber})));
               EdgeTable.TailBondHeadAtomIndex(k)=dATME.Nodes.AtomIndex((ismember(dATME.Nodes.mets,bondMappings.mets{productBondNumber}))&(dATME.Nodes.AtomNumber==bondMappings.headAtoms(productBondNumber))&(ismember(dATME.Nodes.Element,bondMappings.headAtomElements{productBondNumber})));
               EdgeTable.TailBondTailAtomIndex(k)=dATME.Nodes.AtomIndex((ismember(dATME.Nodes.mets,bondMappings.mets{productBondNumber}))&(dATME.Nodes.AtomNumber==bondMappings.tailAtoms(productBondNumber))&(ismember(dATME.Nodes.Element,bondMappings.tailAtomElements{productBondNumber})));
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
res=(M2BiW(~hBool,:)*M2BiE(~hBool,:)')*N - M2BiE(~hBool,:)*BTiE*BTi2R;
if max(max(abs(res)))~=0
    mets = model.mets(metBondMappedBool);
    rxns = model.rxns(rxnBondMappedBool);
     d  = diag(M2BiE*M2BiW');
     D  = spdiags(1./d,0,length(d),length(d));
    N2  = D*M2BiE*BTiE*BTi2R;
    fprintf('%s\n','Inconsistency between reaction stoichiometry and bond mapped reactions (inconsistent stoichiometry?):')
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
    warning('Inconsistent directed bond transition multigraph')
end
   
else 
    
end 





