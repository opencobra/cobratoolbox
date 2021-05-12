function [model,removedBioComp,addedReactionsBiomass] = rebuildBiomassReaction(model,microbeID,biomassReaction,database,infoFile)
% Part of the DEMETER pipeline. This function rebuilds the biomass
% objective function of the reconstruction based on taxonomical information
% for the organism. The biomass formulation is based on gram-staining, 
% taxonomy (Bacteria vs. Archaea), and phylum-specific features.
%
% USAGE
%       [model,removedBioComp,addedReactionsBiomass] = rebuildBiomassReaction(model,microbeID,biomassReaction,database,infoFile)
%
% INPUTS
% model:                  COBRA model structure
% biomassReaction:        Biomass reaction abbreviation
% microbeID:              ID of the reconstructed microbe that serves as the
%                         reconstruction name and to identify it in input tables
% infoFile:               Table with taxonomic and gram staining 
%                         information on microbes to reconstruct
%
% OUTPUTS
% model:                  COBRA model structure
% removedBioComp:         Removed components that shpould not be in the BOF
% addedReactionsBiomass:  Reactions that were added to enable flux through
%                         the rebuilt BOF
%
% AUTHOR:
%       - Almut Heinken, 03/2020

addedReactionsBiomass={};
removedBioComp={};

if find(strcmp(infoFile(:,1),microbeID))
    phylCol=find(strcmp(infoFile(1,:),'Phylum'));
    phylum=infoFile{find(strcmp(infoFile(:,1),microbeID)),phylCol};
    genCol=find(strcmp(infoFile(1,:),'Genus'));
    genus=infoFile{find(strcmp(infoFile(:,1),microbeID)),genCol};
    
    if strcmp(phylum,'Tenericutes')
        %% special case: for organisms without a cell wall
        bio = find(strcmp(model.rxns, biomassReaction));
        bioPro = model.mets(find(model.S(:, bio) > 0), 1);
        bioProSC = full(model.S(find(model.S(:, bio) > 0), bio));
        bioSub = model.mets(find(model.S(:, bio) < 0), 1);
        bioSubSC = full(model.S(find(model.S(:, bio) < 0), bio));
        
        model=removeRxns(model,biomassReaction);
        
        cellWallComp={'ai17tca1[c]','ai17tcaacgam[c]','ai17tcaala_D[c]','ai17tcaglc[c]','glyc45tca[c]','glyc45tcaala_D[c]','glyc45tcaglc[c]','i17tca1[c]','i17tcaacgam[c]','i17tcaala_D[c]','i17tcaglc[c]','sttca1[c]','sttcaacgam[c]','sttcaala_D[c]','sttcaglc[c]','tcam[c]','udcpdp[c]','PGP[c]','PGPm1[c]','colipa[c]'};
        % remove cell wall components
        [C,IA] = intersect(bioSub,cellWallComp);
        removedBioComp=union(removedBioComp,C);
        bioSubSC(IA,:)=[];
        bioSub(IA,:)=[];
        [C,IA] = intersect(bioPro,cellWallComp);
        removedBioComp=union(removedBioComp,C);
        bioProSC(IA,:)=[];
        bioPro(IA,:)=[];
        
        if strncmp(microbeID,'Mycoplasma',10)
            % has a cholesterol requirement
            row2add=size(bioSub,1)+1;
            bioSub{row2add,1}='chsterol[c]';
            bioSubSC(row2add,1)=0.0018061;
        end
        
        % build biomass reaction from remaining components
        bioFormSub = '';
        for s = 1:size(bioSub, 1)
            if s < size(bioSub,1)
                bioFormSub = [bioFormSub, num2str(abs(bioSubSC(s,1))), ' ', bioSub{s, 1}, ' + '];
            else
                bioFormSub = [bioFormSub, num2str(abs(bioSubSC(s,1))), ' ', bioSub{s, 1}];
            end
        end
        
        bioFormPro = '';
        for s = 1:size(bioPro, 1)
            if s < size(bioPro,1)
                bioFormPro = [bioFormPro, num2str(abs(bioProSC(s,1))), ' ', bioPro{s, 1}, ' + '];
            else
                bioFormPro = [bioFormPro, num2str(abs(bioProSC(s,1))), ' ', bioPro{s, 1}];
            end
        end
        bioForm = [bioFormSub ' -> ' bioFormPro];
        
        model = addReaction(model,biomassReaction,bioForm);
        
        if strncmp(microbeID,'Mycoplasma',10)
            rxns2Add={'EX_chsterol(e)','CHSTEROLup'};
            
            for j = 1:length(rxns2Add)
                RxnForm = database.reactions(find(ismember(database.reactions(:, 1), rxns2Add{j})), 3);
                model = addReaction(model, rxns2Add{j}, RxnForm{1, 1});
            end
            addedReactionsBiomass=union(addedReactionsBiomass,rxns2Add);
        end
        
    elseif any(strcmp(phylum,{'Euryarchaeota','Crenarchaeota','Thaumarchaeota'}))
        %% special case: for Archaea
        bio = find(strcmp(model.rxns, biomassReaction));
        bioPro = model.mets(find(model.S(:, bio) > 0), 1);
        bioProSC = full(model.S(find(model.S(:, bio) > 0), bio));
        bioSub = model.mets(find(model.S(:, bio) < 0), 1);
        bioSubSC = full(model.S(find(model.S(:, bio) < 0), bio));
        
        model=removeRxns(model,biomassReaction);
        
        bacterialComp={'ai17tca1[c]','ai17tcaacgam[c]','ai17tcaala_D[c]','ai17tcaglc[c]','glyc45tca[c]','glyc45tcaala_D[c]','glyc45tcaglc[c]','i17tca1[c]','i17tcaacgam[c]','i17tcaala_D[c]','i17tcaglc[c]','sttca1[c]','sttcaacgam[c]','sttcaala_D[c]','sttcaglc[c]','tcam[c]','udcpdp[c]','PGP[c]','PGPm1[c]','colipa[c]','clpn180[c]','clpnai17[c]','clpni17[c]','pe180[c]','peai17[c]','pei17[c]','pg180[c]','pgai17[c]','pgi17[c]'};
        % remove cell wall components only in bacteria
        [C,IA] = intersect(bioSub,bacterialComp);
        removedBioComp=union(removedBioComp,C);
        bioSubSC(IA,:)=[];
        bioSub(IA,:)=[];
        [C,IA] = intersect(bioPro,bacterialComp);
        removedBioComp=union(removedBioComp,C);
        bioProSC(IA,:)=[];
        bioPro(IA,:)=[];
        
        % add archaeal membrane lipids-retrieved from Methanosarcina barkeri
        % reconstruction iAF692
        archaealComp={'dpgpi[c]','gdpgpi[c]','dpgps[c]','dpgpe[c]','dpgpg[c]','3hdpgps[c]','3hdpgpe[c]','3hdpgpg[c]','3hdpgpi[c]'};
        % factor based on lipids in previous M. ruminantum BOF
        archaealFactor1=0.010648;
        % add existing biomass metabolites if found
        condArchaealComp={'hspmd[c]'};
        archaealFactor2=0.0030965;
        
        % add the archaeal lipids
        for i=1:size(archaealComp)
            row2add=size(bioSub,1)+1;
            bioSub{row2add,1}=archaealComp{i,1};
            bioSubSC(row2add,1)=archaealFactor1;
        end
        
        archaealRxns={'AGAIAGT','ATIH','AGAID','ASD','ATSH','CDGGGSAT','CDGGGPP3','CDGGGS','DGGGPS','GGGPS','HASD','HATSH','CDGGGSAT2','CDGGGPP4','DGGPGP2','HATGH','CDGGGS2','DGGGPS2','FRTT2','GRTT2','DMATT2','DPMVD2','ATGH','DGGPGP','HATIH','CDGGIPT','CDGGIPT2','MI1PP','DMATT','FRTT','GRTT','DPMVDc','PMEVKc','MEVK1c','HMGCOARxi','HMGCOAS','ACACT1r','G3PD1','PGMT','MI1PS'};
        for i = 1:length(archaealRxns)
            RxnForm = database.reactions(find(ismember(database.reactions(:, 1), archaealRxns{i})), 3);
            model = addReaction(model, archaealRxns{i}, 'reactionFormula', RxnForm{1, 1}, 'geneRule','demeterGapfill');
        end
        addedReactionsBiomass=union(addedReactionsBiomass,archaealRxns);
        
        % add gram-positive cell wall components that may be present
        for i=1:size(condArchaealComp,1)
            if ~isempty(intersect(condArchaealComp{i,1},model.mets))
                row2add=size(bioSub,1)+1;
                bioSub{row2add,1}=condArchaealComp{i,1};
                bioSubSC(row2add,1)=archaealFactor2;
            end
        end
        
        % rebuild biomass reactions
        bioFormSub = '';
        for s = 1:size(bioSub, 1)
            if s < size(bioSub,1)
                bioFormSub = [bioFormSub, num2str(abs(bioSubSC(s,1))), ' ', bioSub{s, 1}, ' + '];
            else
                bioFormSub = [bioFormSub, num2str(abs(bioSubSC(s,1))), ' ', bioSub{s, 1}];
            end
        end
        
        bioFormPro = '';
        for s = 1:size(bioPro, 1)
            if s < size(bioPro,1)
                bioFormPro = [bioFormPro, num2str(abs(bioProSC(s,1))), ' ', bioPro{s, 1}, ' + '];
            else
                bioFormPro = [bioFormPro, num2str(abs(bioProSC(s,1))), ' ', bioPro{s, 1}];
            end
        end
        bioForm = [bioFormSub ' -> ' bioFormPro];
        model = addReaction(model,biomassReaction,bioForm);
        model=changeObjective(model,biomassReaction);
        
    else
        %% all other organisms depending on whether they are gram -positive or -negative
        % get from the collected organism data whether organism is
        % gram-positive or -negative
        gramCol=find(strcmp(infoFile(1,:),'Gram Staining'));
        gramStatus=infoFile{find(strcmp(infoFile(:,1),microbeID)),gramCol};
        
        if ~isempty(gramStatus) && any(strcmp(gramStatus,{'Gram+','Gram-'}))
            % remove teichoic acid components from gram-negative organisms
            gramposComp={'ai17tca1[c]','ai17tcaacgam[c]','ai17tcaala_D[c]','ai17tcaglc[c]','glyc45tca[c]','glyc45tcaala_D[c]','glyc45tcaglc[c]','i17tca1[c]','i17tcaacgam[c]','i17tcaala_D[c]','i17tcaglc[c]','sttca1[c]','sttcaacgam[c]','sttcaala_D[c]','sttcaglc[c]','tcam[c]'};
            
            % add teichoic acid to gram-positive organisms
            % factors calculated from the average of all biomass reactions
            gramposComp2Add={'tcam[c]','0.001885';'glyc45tcaglc[c]','0.001806';'glyc45tcaala_D[c]','0.001806';'glyc45tca[c]','0.001806'};
            
            % add biosynthesis pathway if needed
            gramposRxns={'ALAPGPL','ACGAMT','G3PCT','UAG2E','UACMAMO','UACMAMAT','CDPGLYCGPT','TECAUE','PGPGT','TECAGE','UDPGDr','UAG4E','TEICH45','TECAAE','TECA4S'};
            
            % add gram-positive cell wall metabolites present in some models and
            % currently blocked
            condGramposComp={'udpglcur[c]','0.001806','DM_udpglcur(c)';'teich_45_BS[c]','0.001806','DM_teich_45_BS(c)'};
            
            % remove LPS components from gram-positive organisms
            gramnegComp={'colipa[c]'};
            
            % add LPS to gram-negative organisms
            % factors calculated from the average of all biomass reactions
            gramnegComp2Add={'colipa[c]','0.025039'};
            
            % add gram-negative cell wall metabolites present in some models and
            % currently blocked
            condGramnegComp={'dtdprmn[c]','0.02504','DM_dtdprmn(c)';'kdo2lipid4L[c]','0.02504','DM_kdo2lipid4L(c)'};
            
            % add biosynthesis pathway if needed
            gramnegRxns={'S7PIr','GMHEPK','GMHEPPA','GMHEPAT','AGMHE','MOAT3C','HEPK1','HEPK2','HEPT3','TDPAGTA','TDPGDH','G1PTT','TDPADGAT','TDPDRRr','TDPDRE','RHAT1','USHD','UAGAAT','UHGADA','U23GAAT','LPADSS','TDSK','MOAT','KDOS','KDOCT2','CDOSKT','EDTXS1','EDTXS2','HEPT1','HEPT2','HEPT3','HEPT4','GALT1','GLCTR2','GLCTR1','GLCTR3','EX_arab_D(e)','ARABDt2','TALA','TKT1','TKT2','EX_ddca(e)','DDCAt','3OAS60','3OAS80','3OAS100','3OAS120','3OAS121','3OAS140','3OAS141','3OAS160','3OAS161','3OAS180','3OAS181'};
            
            bio = find(strcmp(model.rxns, biomassReaction));
            bioPro = model.mets(find(model.S(:, bio) > 0), 1);
            bioProSC = full(model.S(find(model.S(:, bio) > 0), bio));
            bioSub = model.mets(find(model.S(:, bio) < 0), 1);
            bioSubSC = full(model.S(find(model.S(:, bio) < 0), bio));
            model=removeRxns(model,biomassReaction);
            
            % get the gram status from the collected data. Include bacteria here
            % that stain gram negative but have gram positive cell wall structure
            if strcmp(gramStatus,'Gram+') || any(strcmp(genus,{'Acidaminobacter','Gracilibacter','Mageeibacillus'})) || strcmp(phylum,'Deinococcus-Thermus')
                %% fix and gapfill gram-positive organisms
                [C,IA] = intersect(bioSub,gramnegComp);
                removedBioComp=union(removedBioComp,C);
                bioSubSC(IA,:)=[];
                bioSub(IA,:)=[];
                [C,IA] = intersect(bioPro,gramnegComp);
                removedBioComp=union(removedBioComp,C);
                bioProSC(IA,:)=[];
                bioPro(IA,:)=[];
                
                % add the most common teichoic acid components if not in biomass
                if isempty(intersect(gramposComp,bioSub))
                    for i=1:size(gramposComp2Add,1)
                        row2add=size(bioSub,1)+1;
                        bioSub{row2add,1}=gramposComp2Add{i,1};
                        bioSubSC(row2add,1)=str2num(gramposComp2Add{i,2});
                    end
                end
                
                % add gram-positive cell wall components that may be present
                for i=1:size(condGramposComp,1)
                    if ~isempty(intersect(condGramposComp{i,1},model.mets))
                        row2add=size(bioSub,1)+1;
                        bioSub{row2add,1}=condGramposComp{i,1};
                        bioSubSC(row2add,1)=str2num(condGramposComp{i,2});
                        if ~isempty(intersect(condGramposComp{i,3},model.rxns))
                            model=removeRxns(model,condGramposComp{i,3});
                        end
                    end
                end
                
                % rebuild biomass reactions
                bioFormSub = '';
                for s = 1:size(bioSub, 1)
                    if s < size(bioSub,1)
                        bioFormSub = [bioFormSub, num2str(abs(bioSubSC(s,1))), ' ', bioSub{s, 1}, ' + '];
                    else
                        bioFormSub = [bioFormSub, num2str(abs(bioSubSC(s,1))), ' ', bioSub{s, 1}];
                    end
                end
                
                bioFormPro = '';
                for s = 1:size(bioPro, 1)
                    if s < size(bioPro,1)
                        bioFormPro = [bioFormPro, num2str(abs(bioProSC(s,1))), ' ', bioPro{s, 1}, ' + '];
                    else
                        bioFormPro = [bioFormPro, num2str(abs(bioProSC(s,1))), ' ', bioPro{s, 1}];
                    end
                end
                bioForm = [bioFormSub ' -> ' bioFormPro];
                model = addReaction(model,biomassReaction,bioForm);
                model=changeObjective(model,biomassReaction);
                
                % add teichoic acid biosynthesis
                rxns2Add=setdiff(gramposRxns,model.rxns);
                for i = 1:length(rxns2Add)
                    RxnForm = database.reactions(find(ismember(database.reactions(:, 1), rxns2Add{i})), 3);
                    model = addReaction(model, rxns2Add{i}, 'reactionFormula', RxnForm{1, 1}, 'geneRule','demeterGapfill');
                end
                addedReactionsBiomass=union(addedReactionsBiomass,rxns2Add);
                
            elseif strcmp(gramStatus,'Gram-') && ~strcmp(genus,'Acidaminobacter') && ~strcmp(phylum,'Deinococcus-Thermus')
                %% fix and gapfill gram-negative organisms
                [C,IA] = intersect(bioSub,gramposComp);
                removedBioComp=union(removedBioComp,C);
                bioSubSC(IA,:)=[];
                bioSub(IA,:)=[];
                [C,IA] = intersect(bioPro,gramposComp);
                removedBioComp=union(removedBioComp,C);
                bioProSC(IA,:)=[];
                bioPro(IA,:)=[];
                
                % add LPS biosynthesis components if not in biomass
                for i=1:size(gramnegComp2Add,1)
                    if isempty(intersect(gramnegComp2Add{i,1},bioSub))
                        row2add=size(bioSub,1)+1;
                        bioSub{row2add,1}=gramnegComp2Add{i,1};
                        bioSubSC(row2add,1)=str2num(gramnegComp2Add{i,2});
                    end
                end
                
                % add gram-negative cell wall components that may be present
                for i=1:size(condGramnegComp,1)
                    if ~isempty(intersect(condGramnegComp{i,1},model.mets))
                        row2add=size(bioSub,1)+1;
                        bioSub{row2add,1}=condGramnegComp{i,1};
                        bioSubSC(row2add,1)=str2num(condGramnegComp{i,2});
                        if ~isempty(intersect(condGramnegComp{i,3},model.rxns))
                            model=removeRxns(model,condGramnegComp{i,3});
                        end
                    end
                end
                
                % rebuild biomass reactions
                bioFormSub = '';
                for s = 1:size(bioSub, 1)
                    if s < size(bioSub,1)
                        bioFormSub = [bioFormSub, num2str(abs(bioSubSC(s,1))), ' ', bioSub{s, 1}, ' + '];
                    else
                        bioFormSub = [bioFormSub, num2str(abs(bioSubSC(s,1))), ' ', bioSub{s, 1}];
                    end
                end
                
                bioFormPro = '';
                for s = 1:size(bioPro, 1)
                    if s < size(bioPro,1)
                        bioFormPro = [bioFormPro, num2str(abs(bioProSC(s,1))), ' ', bioPro{s, 1}, ' + '];
                    else
                        bioFormPro = [bioFormPro, num2str(abs(bioProSC(s,1))), ' ', bioPro{s, 1}];
                    end
                end
                bioForm = [bioFormSub ' -> ' bioFormPro];
                model = addReaction(model,biomassReaction,bioForm);
                model=changeObjective(model,biomassReaction);
                
                % add LPS biosynthesis pathway
                rxns2Add=setdiff(gramnegRxns,model.rxns);
                for i = 1:length(rxns2Add)
                    RxnForm = database.reactions(find(ismember(database.reactions(:, 1), rxns2Add{i})), 3);
                    model = addReaction(model, rxns2Add{i}, 'reactionFormula', RxnForm{1, 1}, 'geneRule','demeterGapfill');
                end
                addedReactionsBiomass=union(addedReactionsBiomass,rxns2Add);
                
            end
            addedReactionsBiomass=addedReactionsBiomass';
        end
    end
else
    warning('No organism information provided. The pipeline will not be able to curate the reconstruction based on gram status.')
end

end
