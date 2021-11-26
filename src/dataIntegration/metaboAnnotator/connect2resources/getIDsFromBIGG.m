% This m file annotates the metabolite studeture with IDs from BiGG using
% an offline file.
% Ines Thiele 2020/2021

fileName = 'bigg_models_metabolites.xlsx';
[NUM,TXT,RAW]=xlsread(fileName);
%% first based on perfect match between BiggID and VMH ID
clear kegg chebi hmdb biocyc metatnetx inchikey seed lipidmaps bigg
% column 5 in RAW contains the other DB IDs
cntK = 1; kegg{cntK,1} = 'abbr';kegg{cntK,2} = 'keggId';  cntK = cntK+1;
cntC = 1; chebi{cntC,1} = 'abbr';chebi{cntC,2} = 'cheBIId';  cntC = cntC+1;
cntH = 1; hmdb{cntH,1} = 'abbr';hmdb{cntH,2} = 'hmdb';  cntH = cntH+1;
cntB = 1; biocyc{cntB,1} = 'abbr';biocyc{cntB,2} = 'biocyc';  cntB = cntB+1;
cntM = 1; metatnetx{cntM,1} = 'abbr';metatnetx{cntM,2} = 'metanetx';  cntM = cntM+1;
cntI = 1; inchikey{cntI,1} = 'abbr';inchikey{cntI,2} = 'inchiKey';  cntI = cntI+1;
cntS = 1; seed{cntS,1} = 'abbr';seed{cntS,2} = 'seed';  cntS = cntS+1;
cntL = 1; lipidmaps{cntL,1} = 'abbr';lipidmaps{cntL,2} = 'lipidmaps';  cntL = cntL+1;
cntG = 1; bigg{cntG,1} = 'abbr';bigg{cntG,2} = 'biggId';  cntG = cntG+1;
cntR = 1; reactome{cntR,1} = 'abbr';reactome{cntR,2} = 'reactome';  cntR = cntR+1;
for i = 1 : size(RAW,1)
    bigg{cntG,1} = RAW{i,1};
    bigg{cntG,2} = RAW{i,1};
    cntG = cntG+1;
    if isempty(find(isnan((RAW{i,5}))))
        [NEWSTR,MATCHES] = split(RAW{i,5},';');
        for j= 1 : length(NEWSTR)
            NEWSTR{j} = regexprep(NEWSTR{j},'http://identifiers.org/','');
            NEWSTR{j} = regexprep(NEWSTR{j},'https://identifiers.org/','');
            [token, remain]= strtok(NEWSTR{j},'\/');
            if strfind(token,'kegg')
                remain = regexprep(remain,'\/','');
                kegg{cntK,1} = RAW{i,1};
                kegg{cntK,2} = remain;
                cntK = cntK+1;
            elseif strfind(token,'chebi')
                remain = regexprep(remain,'\/CHEBI:','');
                chebi{cntC,1} = RAW{i,1};
                chebi{cntC,2} = remain;
                cntC = cntC + 1;
            elseif strfind(token,'hmdb')
                remain = regexprep(remain,'\/','');
                hmdb{cntH,1} = RAW{i,1};
                hmdb{cntH,2} = remain;
                cntH = cntH + 1;
            elseif strfind(token,'biocyc')
                remain = regexprep(remain,'\/META:','');
                biocyc{cntB,1} = RAW{i,1};
                biocyc{cntB,2} = remain;
                cntB = cntB + 1;
            elseif strfind(token,'metanetx')
                remain = regexprep(remain,'\/','');
                metatnetx{cntM,1} = RAW{i,1};
                metatnetx{cntM,2} = remain;
                cntM = cntM + 1;
            elseif strfind(token,'inchikey')
                remain = regexprep(remain,'\/','');
                inchikey{cntI,1} = RAW{i,1};
                inchikey{cntI,2} = remain;
                cntI = cntI + 1;
            elseif strfind(token,'seed')
                remain = regexprep(remain,'\/','');
                seed{cntS,1} = RAW{i,1};
                seed{cntS,2} = remain;
                cntS = cntS + 1;
            elseif strfind(token,'LipidMaps')
                remain = regexprep(remain,'\/','');
                lipidmaps{cntL,1} = RAW{i,1};
                lipidmaps{cntL,2} = remain;
                cntL = cntL + 1;
            elseif strfind(token,'reactome')
                remain = regexprep(remain,'\/','');
                reactome{cntR,1} = RAW{i,1};
                reactome{cntR,2} = remain;
                cntR = cntR + 1;
                
            end
        end
    end
end


% extract the other IDs from bigg
[metabolite_structure] = addAnnotations(metabolite_structure,seed,fileName);
[metabolite_structure] = addAnnotations(metabolite_structure,kegg,fileName);
[metabolite_structure] = addAnnotations(metabolite_structure,inchikey,fileName);
[metabolite_structure] = addAnnotations(metabolite_structure,biocyc,fileName);
[metabolite_structure] = addAnnotations(metabolite_structure,hmdb,fileName);
[metabolite_structure] = addAnnotations(metabolite_structure,chebi,fileName);
[metabolite_structure] = addAnnotations(metabolite_structure,metatnetx,fileName);
[metabolite_structure] = addAnnotations(metabolite_structure,lipidmaps,fileName);
[metabolite_structure] = addAnnotations(metabolite_structure,bigg,fileName);
[metabolite_structure] = addAnnotations(metabolite_structure,reactome,fileName);
[IDs,IDcount2,Table] = getStats(metabolite_structure);
%% Now try to find new BIGG IDs using the other IDs
clear bigg
cntG = 1; bigg{cntG,1} = 'abbr';bigg{cntG,2} = 'biggId';  cntG = cntG+1;
for k=2:size(Table,1)
    b =  find(strcmp(Table(1,:),'biggId'));
    bigg = map2Bigg(Table,k,bigg,seed,'seed');
    bigg = map2Bigg(Table,k,bigg,lipidmaps,'lipidmaps');
    bigg = map2Bigg(Table,k,bigg,hmdb,'hmdb');
    %  bigg = map2Bigg(Table,k,bigg,chebi,'cheBlId');
    bigg = map2Bigg(Table,k,bigg,kegg,'keggId');
    bigg = map2Bigg(Table,k,bigg,biocyc,'biocyc');
    bigg = map2Bigg(Table,k,bigg,metatnetx,'metanetx');
    bigg = map2Bigg(Table,k,bigg,inchikey,'inchiKey');
end
[metabolite_structure] = addAnnotations(metabolite_structure,bigg);
[IDs,IDcount2,Table] = getStats(metabolite_structure);

%% repeat mapping from above



clear kegg chebi hmdb biocyc metatnetx inchikey seed lipidmaps bigg
% column 5 in RAW contains the other DB IDs
cntK = 1; kegg{cntK,1} = 'abbr';kegg{cntK,2} = 'keggId';  cntK = cntK+1;
cntC = 1; chebi{cntC,1} = 'abbr';chebi{cntC,2} = 'cheBIId';  cntC = cntC+1;
cntH = 1; hmdb{cntH,1} = 'abbr';hmdb{cntH,2} = 'hmdb';  cntH = cntH+1;
cntB = 1; biocyc{cntB,1} = 'abbr';biocyc{cntB,2} = 'biocyc';  cntB = cntB+1;
cntM = 1; metatnetx{cntM,1} = 'abbr';metatnetx{cntM,2} = 'metanetx';  cntM = cntM+1;
cntI = 1; inchikey{cntI,1} = 'abbr';inchikey{cntI,2} = 'inchiKey';  cntI = cntI+1;
cntS = 1; seed{cntS,1} = 'abbr';seed{cntS,2} = 'seed';  cntS = cntS+1;
cntL = 1; lipidmaps{cntL,1} = 'abbr';lipidmaps{cntL,2} = 'lipidmaps';  cntL = cntL+1;
cntG = 1; bigg{cntG,1} = 'abbr';bigg{cntG,2} = 'biggId';  cntG = cntG+1;
metsX= Table(:,strcmp(Table(1,:),'biggId'));
for i = 1 : length(metsX)
    mets{i} = char(metsX{i});
end
for i = 1 : size(RAW,1)
    M =  strmatch(RAW{i,1},mets,'exact');
    if ~isempty(M)
        for k = 1 : length(M) % these would be potential duplicates
            if isempty(find(isnan((RAW{i,5}))))
                [NEWSTR,MATCHES] = split(RAW{i,5},';');
                for j= 1 : length(NEWSTR)
                    NEWSTR{j} = regexprep(NEWSTR{j},'http://identifiers.org/','');
                    NEWSTR{j} = regexprep(NEWSTR{j},'https://identifiers.org/','');
                    [token, remain]= strtok(NEWSTR{j},'\/');
                    if strfind(token,'kegg')
                        remain = regexprep(remain,'\/','');
                        kegg{cntK,1} =  regexprep(Table{M(k),1},'VMH_','');
                        kegg{cntK,2} = remain;
                        cntK = cntK+1;
                    elseif strfind(token,'chebi')
                        remain = regexprep(remain,'\/CHEBI:','');
                        chebi{cntC,1} =  regexprep(Table{M(k),1},'VMH_','');
                        chebi{cntC,2} = remain;
                        cntC = cntC + 1;
                    elseif strfind(token,'hmdb')
                        remain = regexprep(remain,'\/','');
                        hmdb{cntH,1} =  regexprep(Table{M(k),1},'VMH_','');
                        hmdb{cntH,2} = remain;
                        cntH = cntH + 1;
                    elseif strfind(token,'biocyc')
                        remain = regexprep(remain,'\/META:','');
                        biocyc{cntB,1} =  regexprep(Table{M(k),1},'VMH_','');
                        biocyc{cntB,2} = remain;
                        cntB = cntB + 1;
                    elseif strfind(token,'metanetx')
                        remain = regexprep(remain,'\/','');
                        metatnetx{cntM,1} = regexprep(Table{M(k),1},'VMH_','');
                        metatnetx{cntM,2} = remain;
                        cntM = cntM + 1;
                    elseif strfind(token,'inchikey')
                        remain = regexprep(remain,'\/','');
                        inchikey{cntI,1} = regexprep(Table{M(k),1},'VMH_','');
                        inchikey{cntI,2} = remain;
                        cntI = cntI + 1;
                    elseif strfind(token,'seed')
                        remain = regexprep(remain,'\/','');
                        seed{cntS,1} = regexprep(Table{M(k),1},'VMH_','');
                        seed{cntS,2} = remain;
                        cntS = cntS + 1;
                    elseif strfind(token,'LipidMaps')
                        remain = regexprep(remain,'\/','');
                        lipidmaps{cntL,1} = regexprep(Table{M(k),1},'VMH_','');
                        lipidmaps{cntL,2} = remain;
                        cntL = cntL + 1;
                        
                    end
                end
            end
        end
    end
end

[metabolite_structure] = addAnnotations(metabolite_structure,seed);
[metabolite_structure] = addAnnotations(metabolite_structure,kegg);
[metabolite_structure] = addAnnotations(metabolite_structure,inchikey);
[metabolite_structure] = addAnnotations(metabolite_structure,biocyc);
[metabolite_structure] = addAnnotations(metabolite_structure,hmdb);
[metabolite_structure] = addAnnotations(metabolite_structure,chebi);
[metabolite_structure] = addAnnotations(metabolite_structure,metatnetx);
[metabolite_structure] = addAnnotations(metabolite_structure,lipidmaps);
[metabolite_structure] = addAnnotations(metabolite_structure,bigg);
[IDs,IDcount3,Table] = getStats(metabolite_structure);