% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011


%This script takes in a reconstruction model and prints it out into a text
%file. It can be used standalone from the rBioNet.
%
% >> model2text(data,model)
%   data: model or .mat datafile table as in ReconstructionCreator (RC)
%   model: true if data is a model, false if RC table.

function model2text(data,model)
if model
    data = model2data(data,1);
end

[FileName, PathName] = uiputfile('.txt');
if FileName == 0
    return;
end

fid = fopen(fullfile(PathName,FileName),'w');
rxns = data{1};
mets = data{5};
desc = data{2};


%	#Model - the model fields are in the following order. Number of rows are fixed.
%		Name
%		Organism
%		Author
%		Notes
%		Geneindex
%		Geneindex notes

%desc_fields = {'% Name','%Organism','Author','Notes','Geneindex','Geneindex notes'};
fprintf(fid,...
    ['%% This is a COBRA reconstruction model exported to a text file \n'...
    '%% with the rBioNet. These structures are intended to move models\n'...
    '%% between rBioNet in Matlab and the web version. Currently under\n'...
    '%% construction. June 28 2011, Stefan Gretar Thorleifsson.\n'...
    '%%\n'...
    '%% \t # - denotes a specific field is starting description/reaction/metabolites\n'...
    '%% \t %% - denotes comments\n']);

fprintf(fid,'%%\n%%\n%%\n');

fprintf(fid,['#Description\n'...
    'Name\t%s\n'...
    'Organism\t%s\n'...
    'Author\t%s\n'...
    'Notes\t%s\n'...
    'Geneindex_File\t%s\n'...
    'Geneindex_Date\t%s\n'...
    'Geneindex_Source\t%s\n'],...
    desc{1}, desc{2}, desc{3}, desc{4}, desc{5}, desc{6}, desc{7});

% for i = 1:length(desc)
%     fprintf(fid,'%s\n',desc{i});
% end


rxn_fields = {'% Abbreviation',' Description ', 'Formula', 'Reversible', 'GPR' ,...
    'LB' , 'UB' , 'Mechanism Confidence Score', 'Subsystem', 'References',...
    'Notes', 'EC number', 'KeggID'}; 

fprintf(fid,'%%\n%%\n%%\n');

for i = 1:length(rxn_fields)
    fprintf(fid, '%s\t',rxn_fields{i});
end
fprintf(fid,'\n#Reactions\n');

for i = 1:size(rxns,1)
    %Cannot print logical
    if rxns{i,5}
        rxns{i,5} = '1';
    else
        rxns{i,5} = '0';
    end
    rxns{i,7} = num2str(rxns{i,7});
    rxns{i,8} = num2str(rxns{i,8});
    rxns{i,9} = num2str(rxns{i,9});
    if ~isempty(rxns{i,3})
        rxns{i,3} = regexprep(rxns{i,3},'\t', '');
    end
    if ~isempty(rxns{i,12})
        rxns{i,12} = regexprep(rxns{i,12},'\t', '');
    end
    
    if ~isempty(rxns{i,13})
        rxns{i,13} = regexprep(rxns{i,13},'\t', '');
    end
     if ~isempty(rxns{i,14})
        rxns{i,14} = regexprep(rxns{i,14},'\t', '');
     end
    
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\n',...
        rxns{i,2}, rxns{i,3}, rxns{i,4}, rxns{i,5}, rxns{i,6},...
        rxns{i,7}, rxns{i,8}, rxns{i,9}, rxns{i,10}, rxns{i,11}, rxns{i,12},...
        rxns{i,13}, rxns{i,14});
end

%	Abbreviation | Description | Neutral formula | Charged formula | Charge | KeggID | PubChemID |
%	CheBIID | Inchi String | Smile | HMDB


met_fields = {'%Abbreviation', 'Description', 'Neutral formula', 'Charged formula',...
    'Charge', 'KeggID','PubChemID', 'CheBlID', 'Inchi String', 'Smile', 'HMDB',...
    'metHepatoNetID','metEHMNID'};

fprintf(fid,'%%\n%%\n%%\n');

for i = 1:length(met_fields)
    fprintf(fid, '%s\t',met_fields{i});
end
fprintf(fid,'\n#Metabolites\n');

for i = 1:size(mets,1)
    
    if isa(mets{i,4},'cell')
        a = mets{i,4};
        mets{i,4} = a{1};
    end
    mets{i,4} = num2str(mets{i,4});
    
    fprintf(fid, '%s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \t %s \n',...
        mets{i,1}, mets{i,2}, '',mets{i,3}, mets{i,4}, mets{i,5}, mets{i,6},...
        mets{i,7}, mets{i,8}, mets{i,9},mets{i,10}, mets{i,11}, mets{i,12});
end



fclose(fid);

