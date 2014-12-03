%try to correlate left nullspace basis vectors with sets of atoms conserved
%in transitions within the E.coli core model
clear

addpath('/home/common/IEM/IEMdirectionality/data/imPR90068/code')

folder= '/home/common/IEM/IEMdirectionality/data/imPR90068';
cd(folder)

%iCoreED
load '/home/rfleming/workspace/Stanford/convexFBA/data/iCore/rawData/ecoli_core_xls2model.mat'

[nMet,nRxn]=size(model.S);

%finds the reactions in the model which export/import from the model
%boundary i.e. mass unbalanced reactions
%e.g. Exchange reactions
%     Demand reactions
%     Sink reactions
model = findSExRxnInd(model);

nIntRxn=nnz(model.SIntRxnBool);

p=1;
correspondingName{p,1}='ACALDt';
correspondingName{p,2}='ACALDtpp';
p=p+1;
correspondingName{p,1}='ACONTa';
correspondingName{p,2}='ACONTa-b';
p=p+1;
correspondingName{p,1}='ACONTb';
correspondingName{p,2}='ACONTb-b';
p=p+1;
correspondingName{p,1}='ACt2r';
correspondingName{p,2}='ACt2rpp';
p=p+1;
correspondingName{p,1}='AKGt2r';
correspondingName{p,2}='AKGt2rpp';
p=p+1;
correspondingName{p,1}='ATPS4r';
correspondingName{p,2}='ATPS4rpp';
p=p+1;
correspondingName{p,1}='CO2t';
correspondingName{p,2}='CO2tpp';
p=p+1;
correspondingName{p,1}='CYTBD';
correspondingName{p,2}='CYTBDpp';
p=p+1;
correspondingName{p,1}='D_LACt2';
correspondingName{p,2}='D-LACt2pp';
p=p+1;
correspondingName{p,1}='ETOHt2r';
correspondingName{p,2}='ETOHt2rpp';
p=p+1;
correspondingName{p,1}='FORt2';
correspondingName{p,2}='FORt2pp';
p=p+1;
correspondingName{p,1}='FORti';
correspondingName{p,2}='FORtppi';
p=p+1;
correspondingName{p,1}='FRD7';
correspondingName{p,2}='';%like FRD2, FRD3 but not quite
p=p+1;
correspondingName{p,1}='FRUpts2';
correspondingName{p,2}='FRUpts2pp';
p=p+1;
correspondingName{p,1}='FUMt2_2';
correspondingName{p,2}='FUMt2_2pp';
p=p+1;
correspondingName{p,1}='GLCpts';
correspondingName{p,2}='GLCptspp';
p=p+1;
correspondingName{p,1}='GLNabc';
correspondingName{p,2}='GLNabcpp';
p=p+1;
correspondingName{p,1}='GLUt2r';
correspondingName{p,2}='GLUt2rpp';
p=p+1;
correspondingName{p,1}='H2Ot';
correspondingName{p,2}='H2Otpp';
p=p+1;
correspondingName{p,1}='MALt2_2';
correspondingName{p,2}='MALt2_2pp';
p=p+1;
correspondingName{p,1}='NADH16';
correspondingName{p,2}='NADH16pp';
p=p+1;
correspondingName{p,1}='NH4t';
correspondingName{p,2}='NH4tpp';
p=p+1;
correspondingName{p,1}='O2t';
correspondingName{p,2}='O2tpp';
p=p+1;
correspondingName{p,1}='PIt2r';
correspondingName{p,2}='PIt2rpp';
p=p+1;
correspondingName{p,1}='PYRt2r';
correspondingName{p,2}='PYRt2rpp';
p=p+1;
correspondingName{p,1}='SUCCt2_2';
correspondingName{p,2}='SUCCt2_2pp';
p=p+1;
correspondingName{p,1}='SUCCt3';
correspondingName{p,2}='SUCCt3pp';
p=p+1;
correspondingName{p,1}='THD2';
correspondingName{p,2}='THD2pp';
p=p+1;

for n=1:nRxn
    if model.SIntRxnBool(n)
        [status, result] = unix(['cp ' folder '/imPR90068_mappings_09_06_11b/' model.rxns{n} '.txt ' folder '/iCoreED_atom_mappings/' model.rxns{n} '.txt']);
        if status==1
            %not success
             [status, result] = unix(['cp ' folder '/imPR90068_mappings_09_06_11b/' model.rxns{n} '-w.txt ' folder '/iCoreED_atom_mappings/' model.rxns{n} '.txt']);
             if status==0
                 %success
                 fprintf('%s\n',[model.rxns{n} ' -w'])
             else
                 bool=strcmp(correspondingName(:,1),model.rxns{n});
                 if strcmp(model.rxns{n},'SUCCt2_2')
                     pause(eps)
                 end
                 if nnz(bool)==1
                    [status, result] = unix(['cp ' folder '/imPR90068_mappings_09_06_11b/' correspondingName{bool,2} '.txt ' folder '/iCoreED_atom_mappings/' model.rxns{n} '.txt']);
                 else
                     error('')
                 end
                 if status==0
                     fprintf('%s\n',[model.rxns{n} ' - corresponding reaction from iAF1260'])
                 else
                     fprintf('%s\n',[model.rxns{n} ' NO ATOM TRANSITION FOUND'])
                 end
             end
        end
    end
end

model=findSExMetInd(model);
[status, result]=unix('mkdir iCoreED_mol_files');
for m=1:nMet
    metAbbr=model.mets{m};
    metAbbr=metAbbr(1:end-3);
    [status, result] = unix(['cp ' folder '/imPR90068_mol_files/' metAbbr '.mol ' folder '/iCoreED_mol_files/' metAbbr '.mol']);
    if status~=0
        fprintf('%s\n',[metAbbr ' - no mol file'])
    end
end

cd()

model.metBonds=cell(nMet,1);
model.metBondMatrix{m}=cell(nMet,1);
model.metNumAtoms=zeros(nMet,1);
for m=1:nMet
    metAbbr=model.mets{m};
    metAbbr=metAbbr(1:end-3);
    [bonds,nAtoms] = extractBondsFromMol([folder '/iCoreED_mol_files/' metAbbr]);
    model.metBonds{m}=bonds;
    bondMatrix=sparse(bonds(:,1),bonds(:,2),bonds(:,3),nAtoms,nAtoms);
    model.metBondMatrix{m}=bondMatrix;
    model.metNumAtoms(m,1)=nAtoms;
end

model.rxnSubstrateBonds=cell(nRxn,1);
model.rxnProductBonds=cell(nRxn,1);
model.rxnBonds=cell(nRxn,1);
for n=1:nRxn
    if model.SIntRxnBool(n)==1 && ~strcmp(model.rxns{n},'FRD7') && ~strcmp(model.rxns{n},'AKGDH') && ~strcmp(model.rxns{n},'CYTBD')
        disp(model.rxns{n})
        atomMappings = readAtomMapping([folder '/iCoreED_atom_mappings/' model.rxns{n} '.txt']);
        [totAtoms,nMappings]=size(atomMappings);
        nMappings=nMappings/2;
        
        for p=1:nMappings
            model.rxnAtomMapping{n,p}=sparse(atomMappings(:,p*2-1),atomMappings(:,p*2),ones(totAtoms,1),totAtoms,totAtoms);
        end
        
        model.rxnSubstrateBonds{n}=sparse(totAtoms,totAtoms);
        z=1;
        for m=1:nMet
            if model.S(m,n)<0
                %bonds in substrate above the diagonal
                model.rxnSubstrateBonds{n}(z:z+model.metNumAtoms(m)-1,z:z+model.metNumAtoms(m)-1)=model.metBondMatrix{m};
                z=z+model.metNumAtoms(m);
            end
        end
        
        model.rxnProductBonds{n}=sparse(totAtoms,totAtoms);
        z=1;
        for m=1:nMet
            if model.S(m,n)>0
                %bonds in product above the diagonal
                model.rxnProductBonds{n}(z:z+model.metNumAtoms(m)-1,z:z+model.metNumAtoms(m)-1)=model.metBondMatrix{m}';
                z=z+model.metNumAtoms(m);
            end
        end
        
       
        if 0
            atomSubstrate=cell(totAtoms,nMappings);
            for p=1:nMappings
                z=1;
                for m=1:nMet
                    if model.S(m,n)<0
                        metAbbr=model.mets{m};
                        metAbbr=metAbbr(1:end-3);
                        [bonds,nAtoms] = extractBondsFromMol([folder '/iCoreED_mol_files/' metAbbr]);
                        %match all of the bonds in the substrate with the indices
                        %of the atoms
                        for q=z:z+nAtoms-1
                            ind= find(q==atomMappings(:,p*2-1));
                            if isempty(ind)
                                error('No atom')
                            end
                            atomSubstrate{ind,p}=metAbbr;
                            z=z+1;
                        end
                        pause(eps)
                    end
                end
            end
            
            atomProduct=cell(totAtoms,nMappings);
            for p=1:nMappings
                z=1;
                for m=1:nMet
                    if model.S(m,n)>0
                        metAbbr=model.mets{m};
                        metAbbr=metAbbr(1:end-3);
                        [bonds,nAtoms] = extractBondsFromMol([folder '/iCoreED_mol_files/' metAbbr]);
                        %match all of the bonds in the substrate with the indices
                        %of the atoms
                        for q=z:z+nAtoms-1
                            ind= find(q==atomMappings(:,p*2));
                            if isempty(ind)
                                error('No atom')
                            end
                            atomProduct{ind,p}=metAbbr;
                            z=z+1;
                        end
                    end
                end
            end
        end
       pause(eps)        
   end
end

%find the metabolite bonds that are invariant with respect to all mappings
%of all reactions
for m=1:nMet
    inVariantbondMatrix=model.metBondMatrix{m}~=0;
    for n=1:nRxn
        if model.SIntRxnBool(n)==1 && ~strcmp(model.rxns{n},'FRD7') && ~strcmp(model.rxns{n},'AKGDH') && ~strcmp(model.rxns{n},'CYTBD')
            %only if metabolite is a substrate check the atom mappings
            if model.S(m,n)<0
                %bonds in the substrates
                rxnSubstrateBonds=model.rxnSubstrateBonds{n}+model.rxnSubstrateBonds{n}';
                rxnSubstrateBonds=rxnSubstrateBonds~=0;
                
                %find the indices corresponding to the current substrate
                z=1;
                for m2=1:nMet
                    if m==m2
                        firstInd=z;
                        lastInd=z+model.metNumAtoms(m)-1;
                    else
                        z=z+model.metNumAtoms(m2);
                    end
                end

                %cycle through each mapping
                p=1;
                while ~isempty(model.rxnAtomMapping{n,p})
                    rxnProductBondsOrigOrder=model.rxnProductBonds{n}+model.rxnProductBonds{n}';
                    rxnProductBondsSubstrateOrder=model.rxnAtomMapping{n,p}*rxnProductBondsOrigOrder*model.rxnAtomMapping{n,p}';
                    rxnProductBondsSubstrateOrder=rxnProductBondsSubstrateOrder~=0;
                    %atoms in order of the substrates
                    newBonds=rxnSubstrateBonds~=rxnProductBondsSubstrateOrder;
                    invariantBonds=rxnSubstrateBonds & rxnProductBondsSubstrateOrder;
                    
                    %store the invariant bonds
                    size(invariantBonds)
                    disp(firstInd)
                    disp(lastInd)
                    inVariantbondMatrix=inVariantbondMatrix & invariantBonds(firstInd:lastInd,firstInd:lastInd);
                    pause(eps)
                    p=p+1;
               end
            end
        end
    end
    model.metInvariantBond{m}=inVariantbondMatrix;
    pause(eps)
end