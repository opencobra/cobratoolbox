metabolite_structureOri = metabolite_structure;
[IDs,IDcount3,Table] = getStats(metabolite_structure);
VMH_col = 1;
Mets = fieldnames(metabolite_structure);
fields = fieldnames(metabolite_structure.(Mets{1}));
if 1
    HMDB_col = strmatch('hmdb',fields,'exact');
    
    if ~isempty(HMDB_col) % hmdb field exists in metabolite_structure as a field
        filePh = fopen('VMH_Met_all.txt','w');
        for i = 1 : size(Mets,1)
            if ~isempty(metabolite_structure.(Mets{i}).hmdb) && isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb)))
                met = regexprep(Mets{i},'^M_','');
                fprintf(filePh,'%s\t',met);
                HMDBId = metabolite_structure.(Mets{i}).hmdb;
                if HMDBOri % as in VMH now
                    % HMDB switch from a 5 digit code to a 7 digit code
                    % so the current ID's are a mixture
                elseif HMDBFive
                    if regexp(HMDBId,'HMDB00\d\d\d\d\d$')% seven digit ID in VMH
                        HMDBId = regexprep(HMDBId,'HMDB00','HMDB');
                    end
                elseif HMDBSeven
                    if regexp(HMDBId,'HMDB\d\d\d\d\d$')% five digit ID
                        HMDBId = regexprep(HMDBId,'HMDB','HMDB00');
                    end
                end
                fprintf(filePh,'%s\n',HMDBId);
            end
        end
        fclose(filePh);
        system('perl parse_HMDB2.pl');
    end
    
    fid = fopen('parsed_hmdb_part.txt');
    C2 = textscan(fid,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s','delimiter','\t');
    fclose(fid);
    hmdb_vmh = [C2{1} C2{2}];
    hmdb_smile = [C2{2} C2{5}];
    hmdb_inchiString = [C2{2} C2{6}];
    hmdb_inchiKey = [C2{2} C2{7}];
    hmdb_keggId = [C2{2} C2{8}];
    hmdb_biocyc = [C2{2} C2{9}];
    hmdb_cheBIId = [C2{2} C2{10}];
    hmdb_food_db = [C2{2} C2{16}];
    hmdb_drugbank = [C2{2} C2{17}];
    hmdb_chemspider = [C2{2} C2{17}];
    hmdb_pubChemId = [C2{2} C2{15}];
    % assign IDs to known vmh-hmdb matchings
    [metabolite_structure] = addAnnotations(metabolite_structure,hmdb_vmh);
    % fill all the data
    for i = 5 :size(C2,2)
        [metabolite_structure] = addAnnotations(metabolite_structure,[C2{1} C2{i}]);
    end
    [IDs,IDcount4,Table] = getStats(metabolite_structure);
end

% find new hmdb id's using the other id's
for i=1:size(Mets,1)
    if (isempty(metabolite_structure.(Mets{i}).hmdb) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb),1))) % no hmdb id
        clear M;
        % greb kegg
        if  ~isempty(metabolite_structure.(Mets{i}).keggId) && isempty(find(isnan(metabolite_structure.(Mets{i}).keggId),1))
            % try to find it in hmdb data
            M = strmatch(metabolite_structure.(Mets{i}).keggId,hmdb_keggId(:,2),'exact');
            if length(M)==1
                % assign hmdb id
                hmdb_keggId{M,2}
                hmdb_keggId{M,1}
                Mets{i}
                metabolite_structure.(Mets{i}).hmdb = hmdb_keggId{M,1};
                % assign VMH ID to C2
                met = regexprep(Mets{i},'^M_','');
                C2{1,1}{M,1} = met;
            end
        end
        % greb chebi
        if  ~isempty(metabolite_structure.(Mets{i}).cheBIId) && isempty(find(isnan(metabolite_structure.(Mets{i}).cheBIId),1)) ...
                 && (isempty(metabolite_structure.(Mets{i}).hmdb) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb),1)))
            
            % try to find it in hmdb data
            M = strmatch(metabolite_structure.(Mets{i}).cheBIId,hmdb_cheBIId(:,2),'exact');
            if length(M)==1
                % assign hmdb id
                hmdb_cheBIId{M,2}
                hmdb_cheBIId{M,1}
                Mets{i}
                metabolite_structure.(Mets{i}).hmdb = hmdb_cheBIId{M,1};
                % assign VMH ID to C2
                met = regexprep(Mets{i},'^M_','');
                C2{1,1}{M,1} = met;
            end
        end
        % greb food_db
        if  ~isempty(metabolite_structure.(Mets{i}).food_db) && isempty(find(isnan(metabolite_structure.(Mets{i}).food_db),1))...
                 && (isempty(metabolite_structure.(Mets{i}).hmdb) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb),1)))
            % try to find it in hmdb data
            M = strmatch(metabolite_structure.(Mets{i}).food_db,hmdb_food_db(:,2),'exact');
            if length(M)==1
                % assign hmdb id
                hmdb_food_db{M,2}
                hmdb_food_db{M,1}
                Mets{i}
                metabolite_structure.(Mets{i}).hmdb = hmdb_food_db{M,1};
                % assign VMH ID to C2
                met = regexprep(Mets{i},'^M_','');
                C2{1,1}{M,1} = met;
            end
        end
        % greb pubChemId
        if  ~isempty(metabolite_structure.(Mets{i}).pubChemId) && isempty(find(isnan(metabolite_structure.(Mets{i}).pubChemId),1))...
                 && (isempty(metabolite_structure.(Mets{i}).hmdb) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb),1)))
            % try to find it in hmdb data
            M = strmatch(metabolite_structure.(Mets{i}).pubChemId,hmdb_pubChemId(:,2),'exact');
            if length(M)==1
                % assign hmdb id
                hmdb_pubChemId{M,2}
                hmdb_pubChemId{M,1}
                Mets{i}
                metabolite_structure.(Mets{i}).hmdb = hmdb_pubChemId{M,1};
                % assign VMH ID to C2
                met = regexprep(Mets{i},'^M_','');
                C2{1,1}{M,1} = met;
            end
        end
        % greb drugbank
        if  ~isempty(metabolite_structure.(Mets{i}).drugbank) && isempty(find(isnan(metabolite_structure.(Mets{i}).drugbank),1))...
                 && (isempty(metabolite_structure.(Mets{i}).hmdb) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb),1)))
            % try to find it in hmdb data
            M = strmatch(metabolite_structure.(Mets{i}).drugbank,hmdb_drugbank(:,2),'exact');
            if length(M)==1
                % assign hmdb id
                hmdb_drugbank{M,2}
                hmdb_drugbank{M,1}
                Mets{i}
                metabolite_structure.(Mets{i}).hmdb = hmdb_drugbank{M,1};
                % assign VMH ID to C2
                met = regexprep(Mets{i},'^M_','');
                C2{1,1}{M,1} = met;
            end
        end
        % greb chemspider
        if  ~isempty(metabolite_structure.(Mets{i}).chemspider) && isempty(find(isnan(metabolite_structure.(Mets{i}).chemspider),1))...
                 && (isempty(metabolite_structure.(Mets{i}).hmdb) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb),1)))
            % try to find it in hmdb data
            M = strmatch(metabolite_structure.(Mets{i}).chemspider,hmdb_chemspider(:,2),'exact');
            if length(M)==1
                % assign hmdb id
                hmdb_chemspider{M,2}
                hmdb_chemspider{M,1}
                Mets{i}
                metabolite_structure.(Mets{i}).hmdb = hmdb_chemspider{M,1};
                % assign VMH ID to C2
                met = regexprep(Mets{i},'^M_','');
                C2{1,1}{M,1} = met;
            end
        end
        % greb inchiKey
        if  ~isempty(metabolite_structure.(Mets{i}).inchiKey) && isempty(find(isnan(metabolite_structure.(Mets{i}).inchiKey),1))...
                 && (isempty(metabolite_structure.(Mets{i}).hmdb) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb),1)))
            id = metabolite_structure.(Mets{i}).inchiKey;
            % try to find it in hmdb data
            
            M = strmatch(metabolite_structure.(Mets{i}).inchiKey,hmdb_inchiKey(:,2),'exact');
            if length(M)==1
                % assign hmdb id
                hmdb_inchiKey{M,2}
                hmdb_inchiKey{M,1}
                Mets{i}
                metabolite_structure.(Mets{i}).hmdb = hmdb_inchiKey{M,1};
                % assign VMH ID to C2
                met = regexprep(Mets{i},'^M_','');
                C2{1,1}{M,1} = met;
            end
        end
        % greb inchiString
        if  ~isempty(metabolite_structure.(Mets{i}).inchiString) && isempty(find(isnan(metabolite_structure.(Mets{i}).inchiString),1))...
                 && (isempty(metabolite_structure.(Mets{i}).hmdb) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb),1)))
            % try to find it in hmdb data
            M = strmatch(metabolite_structure.(Mets{i}).inchiString,hmdb_inchiString(:,2),'exact');
            if length(M)==1
                % assign hmdb id
                hmdb_inchiString{M,2}
                hmdb_inchiString{M,1}
                Mets{i}
                metabolite_structure.(Mets{i}).hmdb = hmdb_inchiString{M,1};
                % assign VMH ID to C2
                met = regexprep(Mets{i},'^M_','');
                C2{1,1}{M,1} = met;
            end
        end
        % greb smile
        if  ~isempty(metabolite_structure.(Mets{i}).smile) && isempty(find(isnan(metabolite_structure.(Mets{i}).smile),1))...
                 && (isempty(metabolite_structure.(Mets{i}).hmdb) || ~isempty(find(isnan(metabolite_structure.(Mets{i}).hmdb),1)))
            % try to find it in hmdb data
            M = strmatch(metabolite_structure.(Mets{i}).smile,hmdb_smile(:,2),'exact');
            if length(M)==1
                % assign hmdb id
                hmdb_smile{M,2}
                hmdb_smile{M,1}
                Mets{i}
                metabolite_structure.(Mets{i}).hmdb = hmdb_smile{M,1};
                % assign VMH ID to C2
                met = regexprep(Mets{i},'^M_','');
                C2{1,1}{M,1} = met;
            end
        end
    end
end

% now repeat mapping other ID's based on new hmdb id's in updated C2
% update C2{1} which contains the vmh id's
for i = 5 :size(C2,2)
    [metabolite_structure] = addAnnotations(metabolite_structure,[C2{1} C2{i}]);
end
[IDs,IDcount4,Table] = getStats(metabolite_structure);

