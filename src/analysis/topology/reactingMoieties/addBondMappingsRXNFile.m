function [bondMappings] = addBondMappingsRXNFile(rxnfileName, rxnfileDirectory)
% Add bond mappings from an MDL rxn file.
%USAGE:
%
%   [bonds,bondMappings,nTotalBondTransitions] = addBondMappingsRXNFile(rxnfileName, rxnfileDirectory)
%
% INPUT:
%    rxnfileName:         The file name.
%
% OPTIONAL INPUT:
%    rxnfileDirectory:    Path to directory containing the rxnfile. Defaults
%                         to current directory.
%
% OUTPUTS:
% bondMappings:                Table of bond mapping information, with `s` rows, one for each bond transition. 
%                          * .mets - A `s` x 1 cell array of metabolite identifiers for bonds.
%                          * .headAtoms - A `s` x 1 vector containing the numbering of the first atom forming the bond within each metabolite. 
%                          * .tailAtoms -  A `s` x 1 vector containing the
%                          numbering of the second atom forming the bond within each metabolite.
%                          * .bTypes -  A `s` x 1 vector of the bond
%                          type within each metabolite (1 for a single bond, 2 for a double bond, and 3 for a triple bond).
%                          * .headAtomTransitionNrs -  A `s` x 1 vector of
%                          atom transition indice of the first atom forming
%                          the bond within each metabolite. 
%                          * .tailAtomTransitionNrs -  A `s` x 1 vector of
%                          atom transition indice of the second atom forming
%                          the bond within each metabolite. 
%                          * .isSubstrate - A `s` x 1 logical array. True for substrates, false for
%                         products in the reaction for bonds.
%                          * .instances - A `s` x 1 vector indicating which instance of a repeated metabolite atom `i` belongs to for bonds. 
%                          * .bondIndex - A 's'x 1 vector indicating a
%                          unique numeric id for each bond
%                          * .bondTypeInstance - A `s` x 1 vector
%                          indicating which instance of a repeated bond
%                          with bTypes~=1 (ex: if bTypes=2--->bondTypeINstance(1)=1;bondTypeINstance(1)=2))
%                          * .isReacting - A 's'x 1 vector indicating if a
%                          bond is broken (-1), formed (1) or conserved (0)
%                          * .bondTransitionNrs - A 's'x 1 vector
%                          indicating bond transition indices.
%  
%    
%                         
%   
% .. Author: - Hadjar Rahou, 2022 


rxnfileName = regexprep(rxnfileName,'(\.rxn)$',''); % Format inputs and remove rxnfile ending from reaction identifier

if ~exist('rxnfileDirectory','var')
    rxnfileDirectory = pwd;
end
if ~exist('options','var')
    options=[];
end

% Make sure input path ends with directory separator
rxnfileDirectory = [regexprep(rxnfileDirectory,'(/|\\)$',''), filesep];

% Read reaction file
if strcmp(rxnfileName, '3AIBTm')
    rxnFilePath = [rxnfileDirectory '3AIBtm (Case Conflict).rxn'];
else
    rxnFilePath = [rxnfileDirectory rxnfileName '.rxn'];
end
%Read the RXN File
[atoms,bonds] = readABRXNFile(rxnfileName,rxnfileDirectory);

%construct a graph for the substrate by using the atomTransitionNrs for the
%atoms forming the bonds 
s= bonds.headAtomTransitionNrs(bonds.isSubstrate==1);
t=bonds.tailAtomTransitionNrs(bonds.isSubstrate==1);
w=bonds.bTypes(bonds.isSubstrate==1);
%atom nodes
sAtoms=atoms(atoms.isSubstrate==1,:);
GSubstrate=graph(s,t,w,sAtoms);
%construct a graph for the product  by using the atomTransitionNrs
s= bonds.headAtomTransitionNrs(bonds.isSubstrate==0);
t=bonds.tailAtomTransitionNrs(bonds.isSubstrate==0);
w=bonds.bTypes(bonds.isSubstrate==0);
%atom nodes
pAtoms=atoms(atoms.isSubstrate==0,:);
GProduct=graph(s,t,w,pAtoms);

if ~isequal(size(GSubstrate.Nodes,1), size(GProduct.Nodes,1))
    warning('The substrate graph and the product graph do not have the same dimensions in reaction "%s". The reaction may be unbalanced.', rxnfileName);
end
%Find the broken and formed bonds
idReactingBonds=triu(adjacency(GProduct,'weighted')-adjacency(GSubstrate,'weighted'));

%add bondIndex to bonds
bonds.bondIndex=(1:size(bonds,1))';

%Create bond transitions where each bond is extended by the type of
%the bond. For example: if typeBond==2 ---> 2 bond transitions
idx=find(bonds.bTypes~=1);
newBonds=bonds;
%remove bTypes column
%newBonds=removevars(newBonds,['bTypes']);
%remove rows with bTypes~=1(T is newBonds with only the bond with bTypes==1)
T=newBonds(~ismember(newBonds.bondIndex,idx),:);
%add bondTypeInstance variable (ex: if bTypes=2--->bondTypeINstance(1)=1;bondTypeINstance(1)=2)
T.bondTypeInstance=ones(size(T,1),1);
%create a table for the bonds with bTypes~=1(S is newBonds with only the bond with bTypes~=1 extended by bTypes)
S=cell2table(cell(0,12),'variableNames',T.Properties.VariableNames);
 for i=1:length(idx)
     type=bonds.bTypes(bonds.bondIndex(idx(i)),:);
     C=newBonds(newBonds.bondIndex==idx(i),:); 
     newC=cell2table(cell(0,12),'variableNames',T.Properties.VariableNames);
     for j=1:type
       C.bondTypeInstance=j;
       newC=[newC;C];  
     end
     S=[S;newC];
 end
 %bondMappings is a table of all the bond transitions
bondMappings=[T;S];
bondMappings=sortrows(bondMappings,'bondIndex');
%add the variable isReacting to the bondMappings table. This variable has 3
%values (-1: if a bond is broken, 0: if a bond is conserved, 1: if a bond is formed )
bondMappings.isReacting=zeros(size(bondMappings,1),1);
%find the broken bonds in bondMappings
[ub,vb]=find(idReactingBonds<0);
 for i=1:length(ub)
     typeBrokenBond=idReactingBonds(ub(i),vb(i));
     brokenBondIndex=bondMappings.bondIndex(((bondMappings.headAtomTransitionNrs==ub(i))&(bondMappings.tailAtomTransitionNrs==vb(i)& (bondMappings.isSubstrate))|((bondMappings.headAtomTransitionNrs==vb(i))&(bondMappings.tailAtomTransitionNrs==ub(i))& (bondMappings.isSubstrate)))); %the order of atoms in the bonds is not important. 
     typeBondIndex=bondMappings.bondTypeInstance(bondMappings.bondIndex==unique(brokenBondIndex));
     for j=1:abs(typeBrokenBond)
           bondMappings.isReacting((bondMappings.bondIndex==unique(brokenBondIndex))&(bondMappings.bondTypeInstance==typeBondIndex(length(typeBondIndex)+1-j)))=-1;%Start by the reacting bonds with the higher bondTypeInstance
     end    
 end
 %find the formed bonds in bondMappings
 [uf,vf]=find(idReactingBonds>0);
 for i=1:length(uf)
     formedBondIndex=bondMappings.bondIndex(((bondMappings.headAtomTransitionNrs==uf(i))&(bondMappings.tailAtomTransitionNrs==vf(i)& ~(bondMappings.isSubstrate))|((bondMappings.headAtomTransitionNrs==vf(i))&(bondMappings.tailAtomTransitionNrs==uf(i))& ~(bondMappings.isSubstrate))));%the order of atoms in the bonds is not important.
     typeBondIndex=bondMappings.bondTypeInstance(bondMappings.bondIndex==unique(formedBondIndex));
     typeFormedBond=idReactingBonds(uf(i),vf(i));
     for j=1:abs(typeFormedBond)
         bondMappings.isReacting((bondMappings.bondIndex==unique(formedBondIndex))&( bondMappings.bondTypeInstance==typeBondIndex(length(typeBondIndex)+1-j)))=1;%Start by the reacting bonds with the higher bondTypeInstance
     end   
 end

idSubstrateConservedBonds= find((bondMappings.isReacting==0)&(bondMappings.isSubstrate==1));
idProductConservedBonds=  find((bondMappings.isReacting==0)&(bondMappings.isSubstrate==0));
%Create bondTransitionNrs for each row in bondMappings . For the conserved bonds, they should have the same
%bondTransitionNrs in the substrate and the product
bondMappings.bondTransitionNrs=zeros(size(bondMappings,1),1);
% for i=1:length(idSubstrateConservedBonds)  
%     headAtomTransitionNr=bondMappings.headAtomTransitionNrs(idSubstrateConservedBonds(i));
%     tailAtomTransitionNr=bondMappings.tailAtomTransitionNrs(idSubstrateConservedBonds(i));
%     bondTypeConservedBond=bondMappings.bondTypeInstance(idSubstrateConservedBonds(i));
%     bondMappings.bondTransitionNrs((bondMappings.isReacting==0)&((bondMappings.headAtomTransitionNrs==headAtomTransitionNr)&(bondMappings.tailAtomTransitionNrs==tailAtomTransitionNr)|((bondMappings.tailAtomTransitionNrs==headAtomTransitionNr)&(bondMappings.headAtomTransitionNrs==tailAtomTransitionNr)))&((bondMappings.bondTypeInstance==bondTypeConservedBond)))=i;
% end
k=1;
for i=1:size(bondMappings,1)
    if (bondMappings.isReacting(i)==0 & bondMappings.bondTransitionNrs(i)==0)
          headAtomTransitionNr=bondMappings.headAtomTransitionNrs(i);
          tailAtomTransitionNr=bondMappings.tailAtomTransitionNrs(i);
          bondTypeConservedBond=bondMappings.bondTypeInstance(i);
          bondMappings.bondTransitionNrs((bondMappings.isReacting==0)&((bondMappings.headAtomTransitionNrs==headAtomTransitionNr)&(bondMappings.tailAtomTransitionNrs==tailAtomTransitionNr)|((bondMappings.tailAtomTransitionNrs==headAtomTransitionNr)&(bondMappings.headAtomTransitionNrs==tailAtomTransitionNr)))&((bondMappings.bondTypeInstance==bondTypeConservedBond)))=k;
          k=k+1;
    end
    %Map reacting bond to the energy node
     %energy=table({'energy'}', NaN, NaN, 1,{'E'},{'E'},NaN, NaN, NaN,
     %1,NaN , 1,NaN,
     %NaN,'variableNames',bondMappings.Properties.VariableNames); %One node
     %for all the reactions
     energy=table({rxnfileName}', NaN, NaN, 1,{'E'},{'E'},NaN, NaN, NaN, 1,NaN , 1,NaN, NaN,'variableNames',bondMappings.Properties.VariableNames);% It is better to have an energy node for each reaction
    if (bondMappings.isReacting(i)<0 & bondMappings.bondTransitionNrs(i)==0)
        bondMappings.bondTransitionNrs(i)=k;
        energy.bondTransitionNrs(1)=k;
        energy.isReacting(1)=-1;
        energy.isSubstrate(1)=0;
        energy.bondIndex(1)=bondMappings.bondIndex(size(bondMappings,1))+1;
        bondMappings=[bondMappings;energy];
        k=k+1;
    end
    if (bondMappings.isReacting(i)>0 & bondMappings.bondTransitionNrs(i)==0)
        bondMappings.bondTransitionNrs(i)=k;
        energy.bondTransitionNrs(1)=k;
        energy.isReacting(1)=1;
        energy.isSubstrate(1)=1;
        energy.bondIndex(1)=bondMappings.bondIndex(size(bondMappings,1))+1;
        bondMappings=[bondMappings;energy];
        k=k+1;
    end
    
    
end 
nTotalBondTransitions=size(bondMappings,1);

bondMappings= sortrows(bondMappings,'bondTransitionNrs');
%Map reacting bond to the energy node
%bondMappingsEnergy=bondMappings;

%Checks specific for bond transitions(ToDo)
%
%
%