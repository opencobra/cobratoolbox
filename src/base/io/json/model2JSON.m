function model2JSON(model,fileName)
% This function writes a json file from matlab structure.
% I validated json format with https://jsonlint.com/.
%
% INPUT
% model     model structure
% fileName  name of file including extension .json
%
%
% Ines Thiele, May 2023

if isempty(strfind(fileName,'.json'));
    fileName = strcat(fileName,'.json');
end

fid = fopen(fileName, 'w');
fprintf(fid, '{\n');
fprintf(fid, '"metabolites":[\n');
cnt = 1;
% write metabolites
for i = 1 : length(model.mets)
    fprintf(fid, '{\n');
    met = regexprep(model.mets{i},'\[','_');
    met = regexprep(met,'\]','');
    fprintf(fid,strcat( '"id":"',met,'",\n'));
    fprintf(fid,strcat( '"name":"',model.metNames{i},'",\n'));
    x = split(model.mets{i},'[');
    comp = regexprep(x{2},'\]','');
    fprintf(fid,strcat( '"compartment":"',comp,'",\n'));
    fprintf(fid,strcat( '"charge":',num2str(model.metCharges(i)),',\n'));
    fprintf(fid,strcat( '"formula":"',(model.metFormulas{i}),'",\n'));
    fprintf(fid,'"notes":{\n');
    fprintf(fid,'"original_vmh_ids":[\n');
    fprintf(fid,strcat('"',model.mets{i},'"\n'));
    fprintf(fid,']\n');
    fprintf(fid,'},\n');
    fprintf(fid,'"annotation":{\n');
    if isfield(model, 'metBiGGID')
        fprintf(fid,'"bigg.metabolite":[\n');
        fprintf(fid,strcat('"',model.metBiGGID{i},'"\n'));
        fprintf(fid,'],\n');
    end
    if isfield(model, 'metBioCycID')
        fprintf(fid,'"biocyc":[\n');
        model.metBioCycID{i} = regexprep(model.metBioCycID{i},'%','');
        fprintf(fid,strcat('"',model.metBioCycID{i},'"\n'));
        fprintf(fid,'],\n');
    end
    if isfield(model, 'metChEBIID')
        fprintf(fid,'"chebi":[\n');
        fprintf(fid,strcat('"',model.metChEBIID{i},'"\n'));
        fprintf(fid,'],\n');
    end
    if isfield(model, 'metHMDBID')
        fprintf(fid,'"hmdb":[\n');
        fprintf(fid,strcat('"',model.metHMDBID{i},'"\n'));
        fprintf(fid,'],\n');
    end
    if isfield(model, 'metInchiKey')
        fprintf(fid,'"inchi_key":[\n');
        fprintf(fid,strcat('"',model.metInchiKey{i},'"'));
        fprintf(fid,'],');
    end
    if isfield(model, 'metKEGGID')
        fprintf(fid,'"kegg.compound":[\n');
        fprintf(fid,strcat('"',model.metKEGGID{i},'"\n'));
        fprintf(fid,'],\n');
    end
    if isfield(model, 'metMetaNetXID')
        fprintf(fid,'"metanetx.chemical":[\n');
        fprintf(fid,strcat('"',model.metMetaNetXID{i},'"\n'));
        fprintf(fid,'],\n');
    end
    if isfield(model, 'metReactomeID')
        fprintf(fid,'"reactome.compound":[\n');
        fprintf(fid,strcat('"',model.metReactomeID{i},'"\n'));
        fprintf(fid,'],\n');
    end
    if isfield(model, 'metSabiork')
        fprintf(fid,'"sabiork":[\n');
        fprintf(fid,strcat('"',model.metSabiork{i},'"\n'));
        fprintf(fid,'],\n');
        
    end
    if isfield(model, 'metSBOTerms')
        fprintf(fid,strcat('"sbo":"',model.metSBOTerms{i},'",\n'));
    end
    if isfield(model, 'metSEEDID')
        fprintf(fid,'"seed.compound":[\n');
        fprintf(fid,strcat('"',model.metSEEDID{i},'"'));
    end
    fprintf(fid,']\n');
    fprintf(fid,'}\n'); % close annotation
    if i < length(model.mets)
        fprintf(fid,'},\n'); % close metabolite
    else
        fprintf(fid,'}\n'); % close metabolite
    end
end
% close list of metabolites
fprintf(fid,'],\n');

% write reactions
fprintf(fid, '"reactions":[\n');
for i = 1 : length(model.rxns)
    fprintf(fid, '{\n');
    rxn = model.rxns{i};
    fprintf(fid,strcat( '"id":"',rxn,'",\n'));
    fprintf(fid,strcat( '"name":"',model.rxnNames{i},'",\n'));
    fprintf(fid,'"metabolites":{\n');
    [metList, stoichiometries] = findMetsFromRxns(model,i);
    metList= metList{1};
    stoichiometries = stoichiometries{1};
    for j = 1 : length(metList)
        met = regexprep(metList{j},'\[','_');
        met = regexprep(met,'\]','');
        if isempty(strfind(num2str(stoichiometries(j,1)),'.'))
            fprintf(fid,strcat('"',met,'":',num2str(stoichiometries(j,1)),'.0'));
        else
            fprintf(fid,strcat('"',met,'":',num2str(stoichiometries(j,1)),''));
        end
        if j <  length(metList)
            fprintf(fid, ',\n');
        else
            fprintf(fid, '\n');
        end
    end
    fprintf(fid, '},\n');
    fprintf(fid,strcat('"lower_bound":',num2str(model.lb(i)),',\n'));
    fprintf(fid,strcat('"upper_bound":',num2str(model.ub(i)),',\n'));
    fprintf(fid,strcat('"gene_reaction_rule":"',model.grRules{i},'",\n'));
    try
        fprintf(fid,strcat('"subsystem":"',model.subSystems{i},'",\n'));
    catch % there seems to be a cell array in some instances
        a=model.subSystems{i};
        fprintf(fid,strcat('"subsystem":"',a{1},'",\n'));
    end
    fprintf(fid,strcat('"notes":','{\n'));
    fprintf(fid,strcat('"original_vmh_ids":','[\n'));
    fprintf(fid,strcat('"',model.rxns{i},'"\n'));
    fprintf(fid,']\n');
    fprintf(fid,'},\n');
    
    
    fprintf(fid,'"annotation":{\n');
    if isfield(model,'rxnMetaNetXID')
        fprintf(fid,'"metanetx.reaction":[\n');
        fprintf(fid,strcat('"',model.rxnMetaNetXID{i},'"\n'));
        fprintf(fid,'],\n');
    end
    if isfield(model,'rxnSBOTerms')
        fprintf(fid,strcat('"sbo":"',model.rxnSBOTerms{i},'"\n'));
    end

    fprintf(fid,'}'); % close annotation
    if i < length(model.rxns)
        fprintf(fid,'},\n'); % close reaction
    else
        fprintf(fid,'}\n'); % close reaction
    end
end
% close list of reactions
fprintf(fid,'],\n');

% write genes
% here is a more comprehensive annotation version from Recon3D
%
% {
% "id":"26_AT1",
% "name":"AOC1",
% "notes":{
% "original_bigg_ids":[
% "26.1"
% ]
% },
% "annotation":{
% "ccds":[
% "CCDS43679.1",
% "CCDS64797.1"
% ],
% "ncbigene":[
% "26"
% ],
% "ncbigi":[
% "73486661",
% "1034654825",
% "1034654831",
% "440918691",
% "1034654829",
% "1034654827"
% ],
% "omim":[
% "104610"
% ],
% "refseq_name":[
% "AOC1"
% ],
% "refseq_synonym":[
% "KAO",
% "DAO",
% "DAO1",
% "ABP",
% "ABP1"
% ],
% "sbo":"SBO:0000243"
% }
% },
fprintf(fid, '"genes":[\n');
for i = 1 : length(model.genes)
    fprintf(fid, '{\n');
    fprintf(fid,strcat( '"id":"',model.genes{i},'",\n'));
    fprintf(fid,strcat( '"name":"','",\n'));
    fprintf(fid,strcat( '"notes":{','\n'));
    fprintf(fid,strcat( '"original_vmh_ids":[','\n'));
    fprintf(fid,strcat( '"',model.genes{i},'"\n'));
    fprintf(fid,strcat( ']\n'));
    fprintf(fid,strcat( '},\n'));
    fprintf(fid,strcat( '"annotation":{','\n'));
    if isfield(model,'geneSBOTerms')
        fprintf(fid,strcat('"sbo":"',model.geneSBOTerms{i},'"\n'));
    end
    
    fprintf(fid,strcat( '}\n')); % close annotation
    
    if i < length(model.genes)
        fprintf(fid, '},\n');
    else
        fprintf(fid, '}\n');
    end
end
% close list of genes
fprintf(fid,'],\n');
% model ID
fprintf(fid, strcat('"id":"',model.modelID,'",\n'));
% compartments
[~, uniqueCompartments, ~, ~] = getCompartment(model.mets);
fprintf(fid, strcat('"compartments":{','\n'));
for i = 1 : length(uniqueCompartments)
    if strcmp('c',uniqueCompartments{i})
        fprintf(fid, '"c":"cytosol"');
    elseif strcmp('e',uniqueCompartments{i})
        fprintf(fid, '"e":"extracellular space"');
    elseif strcmp('g',uniqueCompartments{i})
        fprintf(fid, '"g":"golgi apparatus",');
    elseif strcmp('i',uniqueCompartments{i})
        fprintf(fid, '"i":"inner mitochondrial compartment"');
    elseif strcmp('l',uniqueCompartments{i})
        fprintf(fid, '"l":"lysosome"');
    elseif strcmp('m',uniqueCompartments{i})
        fprintf(fid, '"m":"mitochondria"');
    elseif strcmp('n',uniqueCompartments{i})
        fprintf(fid, '"n":"nucleus"');
    elseif strcmp('r',uniqueCompartments{i})
        fprintf(fid, '"r":"endoplasmic reticulum"');
    elseif strcmp('p',uniqueCompartments{i})
        fprintf(fid, '"p":"periplasm');
    elseif strcmp('x',uniqueCompartments{i})
        fprintf(fid, '"x":"peroxisome/glyoxysome"');
    end
    if i < length(uniqueCompartments)
        fprintf(fid, ',\n');
    else
        fprintf(fid, '\n');
    end
end
fprintf(fid, '},\n'); % close compartments
if isfield(model,'modelAnnotation')
    fprintf(fid, strcat('"version":"',model.modelAnnotation{2},'"\n'));
end

fprintf(fid, '}\n'); % close file
fclose(fid);