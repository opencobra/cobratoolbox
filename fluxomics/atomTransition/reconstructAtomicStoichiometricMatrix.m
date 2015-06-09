function atomModel=reconstructAtomicStoichiometricMatrix(model,atomModel,atomMappings,missingBool)
%for a given stoichiometric model, generate an atomic stoichiometric model
%from composite reaction stoichiometry and atom mapping data
%
%INPUT
% model             metabolic stoichiometric Model
% atomModel         atomic stoichiometric Model
% atomMappings      atom mappings
% missingBool       #mapping x 1 boolean indicating empty mapping 
%                   e.g. reactions for which no atom mapping has been obtained
%
%OUTPUT
% atomModel.S       #atom x #transition atomic stoichiometric matrix
% atomModel.M       #met  x #transition recording substrate and product metabolite for each
%                   transition
% atomModel.E       #rxn x #transition matrix with reaction corresponding to atom transition 

if ~isfield(model,'SIntRxnBool')
    model = findSExRxnInd(model);
end

[nMet,nRxn]=size(model.S);

nAtoms=length(atomModel.atoms);
nBonds=length(atomModel.bonds);
nMappings=length(atomMappings);

nAtomicTransitions=0;
for p=1:nMappings
    nAtomsInOneTransition=0;
    for q=1:atomMappings(p).reactantMapping(1).numSubstrates
        nAtomsInOneTransition=nAtomsInOneTransition+atomMappings(p).reactantMapping(q).nAtoms;
    end
    nAtomicTransitions=nAtomicTransitions+nAtomsInOneTransition;
end


%generation of atomic stoichiometric matrix
%atomModel.S=sparse(nAtoms+nBonds,nAtomicTransitions);
atomModel.S=sparse(nAtoms,nAtomicTransitions);

%matrix recording the substrate and product metabolite for each atom transition
atomModel.M=sparse(nMet,nAtomicTransitions);

%matrix recording the substrate metabolite, enzyme and product metabolite for each atom transition
atomModel.E=sparse(nRxn,nAtomicTransitions);

atomModel.mappings=cell(nMappings,1);
atomModel.transitions=cell(nAtomicTransitions,1);
t=1; tt=1;
for m=1:nMappings
    if ~missingBool(m)
        %reaction abbreviation of the current atom mapping
        rxnAbbr=atomMappings(m).rxn;
        
        %name of the current atom mapping
        atomModel.maps{m,1}=atomMappings(m).name;
        
        %number of substrates and products
        nSubstrates=atomMappings(m).reactantMapping(1).numSubstrates;
        nProducts=atomMappings(m).reactantMapping(1).numProducts;
        
        %iterate through each substrate
        for s=1:nSubstrates
            %current substrate metabolite abbreviation
            metAbbrS=atomMappings(m).reactantMapping(s).metAbbr;
            %iterate through each atom in this substrate
            for aS=1:atomMappings(m).reactantMapping(s).nAtoms
                %construct the name of the substrate atom
                substrateAtomSymbol=atomMappings(m).reactantMapping(s).atomBlock{aS,1};
                substrateAtomNumber=atomMappings(m).reactantMapping(s).atomBlock{aS,2};
                %note that the virgin molfile index for the substrateAtom is aS
                substrateAtomName=[metAbbrS '_' int2str(aS) substrateAtomSymbol];
                %boolean for substrate atom from name
                substrateAtomBool=strcmp(atomModel.atoms,substrateAtomName);
                if ~any(substrateAtomBool)
                    error(['In ' atomModel.maps{m,1} ', could not find substrate atom: ' substrateAtomName]);
                end
                %consumption of one substrate atom
                atomModel.S(substrateAtomBool,t)=-1;
                %record metabolite corresponding to substrate atom in metabolite matrix
                atomModel.M(strcmp(model.mets,metAbbrS),t)=1;
                %record reaction corresponding to transition
                atomModel.E(strcmp(model.rxns,rxnAbbr),t)=1;
                
                %next find the atom in the product
                %iterate through the products
                match=0;
                for p=nSubstrates+1:nSubstrates+nProducts
                    %current product metabolite abbreviation
                    metAbbrP=atomMappings(m).reactantMapping(p).metAbbr;
                    %iterate through the atoms in the current product looking for a match
                    for aP=1:atomMappings(m).reactantMapping(p).nAtoms
                        productAtomNumber=atomMappings(m).reactantMapping(p).atomBlock{aP,2};
                        %check if substrate atom maps to product atom
                        if substrateAtomNumber==productAtomNumber
                            productAtomSymbol=atomMappings(m).reactantMapping(p).atomBlock{aP,1};
                            %note that the virgin molfile index for the productAtom is aP
                            productAtomName=[metAbbrP '_' int2str(aP) productAtomSymbol];
                            
                            %boolean for product atom from name
                            productAtomBool=strcmp(atomModel.atoms,productAtomName);
                            if ~any(productAtomBool)
                                error(['In ' atomModel.maps{m,1} 'could not find product atom ' productAtomName ' for substrate atom ' substrateAtomName]);
                            end
                            %production of one product atom
                            atomModel.S(productAtomBool,t)=1;
                            %record metabolite corresponding to product atom in metabolite matrix
                            atomModel.M(strcmp(model.mets,metAbbrP),t)=1;
                            %give the transition a name
                            atomModel.transitions{t,1}=[atomModel.maps{m,1} '_' substrateAtomName '_to_' productAtomName];
                            %index to the next transition
                            t=t+1;
                            %no need to go through rest of atoms
                            match=1;
                            break
                        end
                    end
                    %check if no need to go through rest of products
                    if match==1
                        break;
                    end
                end
                if match==0
                    error('no match for atom in product');
                end
            end
        end
        %disp(m)
    end
end

%sanity checks
%should be sum of zero for each column
sS=sum(atomModel.S,1);
if any(sS~=0)
    error('wrong mapping');
end



% if ~exist('rxnFilePath')
%     rxnFilePath=pwd;
% end
% 
% [nMet,nRxn]=size(model.S);
% 
% missingBool=false(nRxn,1);
% 
% for n=1:nRxn
%     if model.SIntRxnBool(n)==1
%         filename=[model.rxns{n} '.rxn'];
%         if ~exist([rxnFilePath filename],'file')
%             missingBool(n)=1;
%         else
%             atomMap(n).reactantMapping=readDREAMrxnFile(filename,rxnFilePath);
%         end
%     end
% end
% 
% % reactantMapping                   1 x #reactants struct array with fields (i = 1 ... #reactants):
% %
% % reactantMapping(i).nAtoms         #atoms in ith reactant
% %
% % reactantMapping(i).nBonds         #bonds in ith reactant
% %
% % reactantMapping(i).atomBlock      #atom x 5 cell array with columns:
% %                                   atomic symbol;atom number; x position, y position, z position
% %
% % reactantMapping(i).bondBlock      #bond x 3 numeric array with columns:
% %                                   first atom number, second atom number, bond type
% %
% % reactantMapping.numSubstrates    #substrates in reaction (ignoring hydrogen)
% % reactantMapping.numProducts      #products in reaction (ignoring hydrogen)
% %


