%driver_atom_mappings_left_null_DREAM
%Compare left nullspace basis vectors with cycles of atoms within various models

%clear

%CHANGE SOME PATHS HERE DEPENDING ON USER
% operator='rfleming';
operator='hulda';
switch operator
    case 'rfleming'
        basePath='/home/rfleming/workspace/graphStoich/';
        pathCellNetAnalyzer=[basePath 'code/CellNetAnalyzer/'];
        atomModelPath = '';
    case 'nikos'
        %basePath= ;
        %pathCellNetAnalyzer= ;
        %atomModelPath = '';
    case 'hulda'
        basePath = '/home/huldash/Dropbox/graphStoich/';
        pathCellNetAnalyzer=[basePath 'code/CellNetAnalyzer/'];
        atomModelPath = [basePath 'Hulda_Fluxomics/Results/Recon2_DA_network/'];
    otherwise
        
end

addpath([basePath 'code/atomTransition/'])
addpath([basePath 'code/circuits/'])

%Choose the model to analyse
%modelToUse='iCore';
%modelToUse='iTryp';
modelToUse='DA';

%DREAM http://selene.princeton.edu/dream/
%First, E. L., Gounaris, C. E., and Floudas, C. A. Stereochemically Consistent Reaction Mapping and
%Identification of Multiple Reaction Mechanisms through Integer Linear Optimization.
%Journal of Chemical Information and Modeling, 52(1):84?92, 2012.
%
%writeDREAM=0 assumes that the output from DREAM is already present
%writeDREAM=1 writes the input files for DREAM
writeDREAM=0;

%readDREAM=0 assumes that the atomModel is already present
%readDREAM=1 reads the output from DREAM and generates the atomModel mappings and transitions
readDREAM=1;

%
computeCycles=0;
analyseCycles=0;

computeCoCycles=0;

writeCytoscapeInput=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch modelToUse
    case 'iCore'
        %E.coli central metabolism
        modelPath='data/iCore/';
        currentPath= [basePath modelPath 'iCore_MDL_RXN/'];
        cd(currentPath)
        molFilePath=[basePath modelPath 'iCore_mol_files/'];
        rxnFilePath=[basePath modelPath 'iCore_MDL_RXN_OUT/'];
        load([basePath modelPath 'ecoli_core_xls2model.mat']);
    case 'iTryp'
        %Trypanosome anaeorobic glycolysis
        modelPath='data/iTryp/';
        currentPath= [basePath modelPath 'iTryp_MDL_RXN/'];
        cd(currentPath)
        molFilePath=[basePath 'data/imPR90068/imPR90068_mol_files/'];
        rxnFilePath=[basePath modelPath 'iTryp_MDL_RXN_OUT/'];
        %load([basePath modelPath 'iTrypAnaerobicGlycolysisLoop.mat']);
        load([basePath modelPath 'iTryp_Paths_Pools_21-Apr-2012.mat']);
        %model.P - extreme pathways
        %model.Pl - extreme pools
        model.biomassRxnAbbr='EX_glc(e)';
        %"iTryp_Apr20th"   ID bde02e7e1590d15fd95549c8da58e297  (one mechanism)
        % "iTryp_21stApr"  ID 7d26a531c1b9418753417d8e2f6826a2  (multiple mechanisms)
    case 'DA'
        modelPath = 'Hulda_Fluxomics/';
        molFilePath=[basePath modelPath 'Data/molfiles/Recon2_explicitH/'];
        rxnFilePath=[basePath modelPath 'Results/Recon2_DA_network/AtomMapping/DREAM/min_bonds_broken_single_mapping/DA_rxns/'];
        load([basePath modelPath 'Results/Recon2_DA_network/DA_network.mat']);
end


[nMet,nRxn]=size(model.S);
%finds the reactions in the model which export/import from the model
%boundary i.e. mass unbalanced reactions
%e.g. Exchange reactions
%     Demand reactions
%     Sink reactions
model = findSExRxnInd(model);
nIntRxn=nnz(model.SIntRxnBool);

%internal metabolites
if ~isfield(model,'SIntMetBool')
    model=findSExMetInd(model);
end


if readDREAM || writeDREAM
    %Creating all the atoms in the atomModel
    nFormulaeNonHatomsMolFile=zeros(nMet,1);
    nFormulaeBonds=zeros(nMet,1);
    for m=1:nMet
        metAbbr=model.mets{m}(1:end-3);
        molFileName=[molFilePath metAbbr '.mol'];
        %read mol files
        [atomBlock,bondBlock,nNonHatoms,nBonds,nonHformula]=readMolFile(molFileName);
        atomModel.mets(m).atomBlock=atomBlock;
        atomModel.mets(m).bondBlock=bondBlock;
        atomModel.mets(m).nNonHatoms=nNonHatoms;
        atomModel.mets(m).nBonds=nBonds;
        %non hydrogen formula from mol files
        atomModel.mets(m).nonHformula=nonHformula;
        nFormulaeBonds(m)=nBonds;
        nFormulaeNonHatomsMolFile(m)=nNonHatoms;
    end
    nBonds=sum(nFormulaeBonds);
    nNonHatoms=sum(nFormulaeNonHatomsMolFile);
    
    %assumes no H
    hBool = false(size(model.mets));
    hBool(strmatch('h[',model.mets)) = true;
    
    if 0
        %checking that reactions are balanced according to the formulae given in the model
        [massImbalance,imBalancedMass,imBalancedCharge,imBalancedBool,Elements] = checkMassChargeBalance(model);
        if nnz(massImbalance)~=0
            error('stoichiometric model is imbalanced');
        end
    end
    
    if 0
        %checking that formulae are the same in the model as in the mol files
        nonHElements = {'C', 'O', 'P', 'S', 'N', 'Mg','X','Fe','Zn','Co','R'};
        for m=1:nMet
            for n=1:length(nonHElements)
                %ignore protons
                if ~isempty(atomModel.mets(m).nonHformula)
                    molN  =numAtomsOfElementInFormula(atomModel.mets(m).nonHformula,nonHElements{n});
                    modelN=numAtomsOfElementInFormula(model.metFormulas{m},nonHElements{n});
                    if molN~=modelN
                        fprintf('%s\n',['Molecule ' model.mets{m} ' is ' int2str(molN) 'in mol file, but ' int2str(modelN) ' in model.'])
                    end
                end
            end
        end
    end
    
    if 0
        %model formulae
        [nFormulaeAtoms,nFormulaeNonHatomsModel]=getNumAtomsInFormula(model.metFormulas);
    end
    
    % reactantMapping(i).atomBlock      #atom x 5 cell array with columns:
    %                                   atomic symbol;atom number; x position, y position, z position
    % reactantMapping(i).bondBlock      #bond x 3 numeric array with columns:
    %                                   first atom number, second atom number, bond type
    atomModel.atoms=cell(nNonHatoms,1);
    atomModel.bonds=cell(nBonds,1);
    n=1;
    r=1;
    %naming of all of the atoms and the bonds in the atomModel
    for m=1:nMet
        for p=1:size(atomModel.mets(m).atomBlock,1)
            atomModel.atoms{n,1}=[model.mets{m} '_' int2str(p) atomModel.mets(m).atomBlock{p,1}];
            n=n+1;
        end
        for p=1:size(atomModel.mets(m).bondBlock,1)
            atomModel.bonds{r,1}=[model.mets{m} '_' int2str(atomModel.mets(m).bondBlock(p,1)) '_' int2str(atomModel.mets(m).bondBlock(p,2)) '_' int2str(atomModel.mets(m).bondBlock(p,3))];
            r=r+1;
        end
    end
end


%writing files for DREAM input - this only has to be done once
if writeDREAM
    if 1
        for n=1:nRxn
            if model.SIntRxnBool(n)==1
                %write an MDL reaction file to the current path
                filename=model.rxns{n};
                rxnBool=false(nRxn,1);
                rxnBool(n)=1;
                writeMDLrxnFile(model,molFilePath,rxnBool,filename);
            end
        end
    end
    
    %can also write out individual files to debug the correct input format
    if 0
        rxnAbbr='ACKr';
        %test ACKr first
        bool=false(nRxn,1);
        bool(strcmp(model.rxns,rxnAbbr))=1;
        %write an MDL reaction file to the current path
        writeMDLrxnFile(model,molFilePath,bool,rxnAbbr);
    end
    
    if 0
        rxnAbbr='ADK1';
        %test ACKr first
        bool=false(nRxn,1);
        bool(strcmp(model.rxns,rxnAbbr))=1;
        %write an MDL reaction file to the current path
        writeMDLrxnFile(model,molFilePath,bool,rxnAbbr);
    end
    
    if 0
        rxnAbbr='CYTBD';
        %test ACKr first
        bool=false(nRxn,1);
        bool(strcmp(model.rxns,rxnAbbr))=1;
        %write an MDL reaction file to the current path
        writeMDLrxnFile(model,molFilePath,bool,rxnAbbr);
    end
    
    if 0
        rxnAbbr='GLUSy';
        %test ACKr first
        bool=false(nRxn,1);
        bool(strcmp(model.rxns,rxnAbbr))=1;
        %write an MDL reaction file to the current path
        writeMDLrxnFile(model,molFilePath,bool,rxnAbbr);
    end
end


if readDREAM
    %reading DREAM output
    [atomMappings,missingBool]=readModelsDREAMatomMappings(model,rxnFilePath,modelToUse);
    
    if nnz(missingBool)>0
        warning([int2str(nnz(missingBool)) ' missing DREAM output reaction files'])
    end
    
    %reconstructing the atomic stoichiometric matrix
    atomModel=reconstructAtomicStoichiometricMatrix(model,atomModel,atomMappings,missingBool);
    
    nAtomicTransitions=length(atomModel.transitions);
    if 0
        %figure of the atomic stoichiometric matrix
        figure
        spy(atomModel.S(1:nNonHatoms,1:nAtomicTransitions),5)
        set(gca,'FontSize',16)
        title(['Atomic stoichiometric matrix (' int2str(nMet) ', ' int2str(nnz(model.SIntRxnBool)) ')'],'FontSize',16)
        ylabel(['Non-H Atoms in metabolites, # = ' int2str(nNonHatoms)],'FontSize',16)
        xlabel(['Atom transitions, #= ' int2str(nAtomicTransitions)],'FontSize',16)
    end
    %
    if 0
        csvwrite('iCoreAtomS.csv',full(atomModel.S));
    end
    save([atomModelPath 'atomModel.mat'],'atomModel');
end

if computeCycles
    
    %compute cycles in the atomicStoichiometric matrix using Johnsons Algorithm
    currentPath=pwd;
    cd(pathCellNetAnalyzer)
    startcna(1)
    cd(currentPath);
    undirected=1;
    tic
    [C,csigns] = getStoichCircuitsJohnson(atomModel.S,undirected);
    toc
    close_cna
    if ~exist('atomModel','var')
        load atomModel
    end
    atomModel.C=C;
    cd([basePath modelPath])
    save([atomModelPath 'atomModel.mat'],'atomModel');
end

if computeCoCycles
    %compute co-cycles for the atomicStoichiometric matrix using Johnsons Algorithm
    currentPath=pwd;
    cd(pathCellNetAnalyzer)
    startcna(1)
    cd(currentPath);
    undirected=1;
    tic
    [G,gsigns] = getStoichCircuitsJohnson(atomModel.S',undirected);
    G=sparse(G);
    toc
    close_cna
    if ~exist('atomModel','var')
        load atomModel
    end
    atomModel.G=G;
    cd([basePath modelPath])
    save([atomModelPath 'atomModel.mat'],'atomModel');
end

if analyseCycles
    %analysis of cycles
    cd([basePath modelPath])
    if ~exist('atomModel','var')
        load atomModel
    end
    [nTransitions,nCycles]=size(atomModel.C);
    [nMets,nRxns]=size(model.S);
    
    nTransitionsPerCycle=sum(atomModel.C,1)';
    if 0
        figure
        hist(nTransitionsPerCycle)
        ylabel('# cycles')
        xlabel('# transitions in a cycle')
    end
    
    %long cycles
    longCycleBool=false(nCycles,1);
    longCycleBool(nTransitionsPerCycle>2)=1;
    fprintf('%s\n',['Number of atomic cycles of length greater than 2: ' int2str(nnz(longCycleBool))]);
    fprintf('%s\n','Lengths: '); disp(nTransitionsPerCycle(longCycleBool)')

    %find cycles between metabolites 
    atomModel.Cm=sparse(nCycles,nMets);
    nMetPerCycle=sparse(nCycles,1);
    metParticipationPerCycle=sparse(nCycles,1);
    %find cycles through enzymes
    atomModel.Cr=sparse(nRxns,nCycles);
    nRxnPerCycle=sparse(nCycles,1);
    rxnParticipationPerCycle=sparse(nCycles,1);
    fprintf('%s\n','----')
    for c=1:nCycles
        %get transitions in current cycle
        transitionBool=atomModel.C(:,c)~=0;
        %metabolites involved in current cycle
        metaboliteParticipation=sum(atomModel.M(:,transitionBool),2);
        metParticipationPerCycle(c,1)=sum(metaboliteParticipation);
        metaboliteBool=metaboliteParticipation~=0;
        nMetPerCycle(c,1)=nnz(metaboliteBool);
        metBool4=metaboliteParticipation>2;
        if any(metBool4)
            ind=find(metBool4);
            transitionNames=atomModel.transitions(transitionBool);
            element=transitionNames{1}(end);
            for p=1:length(ind)
                fprintf('%s\n',['Same ' element ' atom cycles twice through ' model.mets{ind(p)}])
            end
            atomModel.Cm(c,metaboliteBool)=metaboliteParticipation(metaboliteBool)/2;
        else
            atomModel.Cm(c,metaboliteBool)=1;
        end
    end
    
    %long cycles
    AL=atomModel.Cm(longCycleBool,:);
    AS=full(atomModel.Cm(longCycleBool,:)*model.S(:,model.SIntRxnBool));
    AS1=AS;
    AS1(AS~=0)=1;
    AS1t=AS1';
    unbalancedReactions=sum(AS1,1)';
    
    %unique cycles between metabolites
    atomModel.Um  = unique(atomModel.Cm, 'rows');
    UmS=full(atomModel.Um*model.S(:,model.SIntRxnBool));
    %rational left nullspace of UmS
    Nm=null(UmS','r');
    
    fprintf('%s\n','----')
    for c=1:nCycles
        %get transitions in current cycle
        transitionBool=atomModel.C(:,c)~=0;
        %reactions involved in current cycle
        reactionParticipation=sum(atomModel.E(:,transitionBool),2);
        rxnParticipationPerCycle(c,1)=sum(reactionParticipation);
        reactionBool=reactionParticipation~=0;
        nRxnPerCycle(c,1)=nnz(reactionBool);
        rxnBool4=metaboliteParticipation>2;
        if any(rxnBool4)
            ind=find(rxnBool4);
            transitionNames=atomModel.transitions(transitionBool);
            element=transitionNames{1}(end);
            for p=1:length(ind)
                fprintf('%s\n',['Same ' element ' atom cycles twice through ' model.rxns{ind(p)}])
            end
            atomModel.Cr(reactionBool,c)=reactionParticipation(reactionBool)/2;
        else
            atomModel.Cr(reactionBool,c)=1;
        end
    end
    fprintf('%s\n','----')
   
    %unique cycles between reactions
    atomModel.Ur  = unique(atomModel.Cr', 'rows')';
    SUr=full(model.S(:,model.SIntRxnBool)*atomModel.Ur);
    %rational nullspace of SUr
    Nr=null(SUr,'r');
    
    %unique cycles between metabolites and reactions
    atomModel.Cmr=[atomModel.Cm,atomModel.Cr'];
    atomModel.Umr  = unique(atomModel.Cmr, 'rows')';
end

analysePools=0;
if analysePools
    if ~isfield(model,'Pl')
        load iTryp_Paths_Pools_21-Apr-2012
    end
    %find the weighting of each unique cycle that reproduces each left nullspace basis vector,
    %if there is one.
    X=sparse(size(atomModel.U,1),size(model.Pl,1));
    if 0
        for n=1:size(model.Pl,1)
            X(:,n)= atomModel.U'\model.Pl(n,:)';
        end
    else
        tmp.S=atomModel.U';
        tmp.lb=zeros(size(atomModel.U,1),1);
        %tmp.lb=-5*ones(size(atomModel.U,1),1);
        tmp.ub=5*ones(size(atomModel.U,1),1);
        tmp.c=ones(size(atomModel.U,1),1);
        %positive linear combination
        for n=1:size(model.Pl,1)
            tmp.b=model.Pl(n,:)';
            solution = optimizeCbModel(tmp,'min','one');
            if ~isempty(solution.x)
                X(:,n)=solution.x;
                if nnz(X(:,n))==1
                    fprintf('%s\n',['Cycle U(' int2str(find(X(:,n)~=0)) ',:) matches left null basis vector L(' int2str(n) ',:)']);
                end
            end
        end
    end
end
save([atomModelPath 'atomModel.mat'],'atomModel');

if writeCytoscapeInput
    [modelPlane,replicateMetBool,metData,rxnData]=planariseModel(model);
    cd([pwd '/cytoscape'])
    
    %INPUTS
    % model         COBRA metabolic network model
    % fileBase      Base file name (without extensions) for Cytoscape input
    %               files that are generated by the function
    %
    %OPTIONAL INPUTS
    % rxnList       List of reactions that will included in the output
    %               (Default = all reactions)
    % rxnData       Vector or matrix of data or cell array of strings to output for each
    %               reaction in rxnList (Default = empty)
    % metList       List of metabolites that will be included in the output
    %               (Default = all metabolites)
    % metData       Vector or matrix of data or cell array of strings to output
    %               for each metabolite in metList (Default = empty)
    % metDegreeThr  Maximum degree of metabolites that will be included in the
    %               output. Allows filtering out highly connected metabolites
    %               such as h2o or atp (Default = no filtering)
    
    fileBase=modelToUse;
    rxnList=model.rxns(model.SIntRxnBool);
    metList=modelPlane.mets;
    notShownMets = outputNetworkCytoscape(modelPlane,fileBase,rxnList,rxnData,metList,metData);
    
    %metabolite abbreviations as attributes for all duplicated nodes
    writeCytoscapeNodeAttributeTable(modelPlane,model,model.mets,[],[],[fileBase '_nodeMetabolites.txt'])
    
    %reaction abbreviations as attributes for all edges for same reaction
    writeCytoscapeEdgeAttributeTable(model,model.rxns,[],[],replicateMetBool,[fileBase '_edgeReactions.txt']);
    
    %colour edges in cycles
    writeCytoscapeEdgeAttributeTable(model,[],atomModel.Ur,[],replicateMetBool,[fileBase '_edgeCycles.txt']);    
end


return
