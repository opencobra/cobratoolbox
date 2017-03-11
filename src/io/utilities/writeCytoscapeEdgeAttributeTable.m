function writeCytoscapeEdgeAttributeTable(model,C,B,N,replicateMetBool,filename)
%write out a set of boolean edge attributes as one of a pair of colours,
%Red for yes, Black for No
%
%INPUT
% model.S       #met x #reaction
% C             #reaction x #attribute cell array
% B             #reaction x #attribute Boolean matrix
% N             #reaction x #attribute numeric array


yesColor='Red';
noColor='Black';

if ~exist('filename','var')
    if isfield(model,'description')
        filename=[model.description 'edgeAttributes.txt'];
    else
        filename='edgeAttributes.txt';
    end
end

[nMet,nRxn]=size(model.S);

if ~isfield(model,'rev')
    model.rev=true(nRxn,1);
end

if ~isfield(model,'SIntRxnBool')
    model.SIntRxnBool=true(nRxn,1);
end

allowedMet=true(nMet,1);
selMet=true(nMet,1);

%write unique reaction cycles as edge attribute files
fid=fopen(filename,'w');

for n=1:nRxn
    if model.SIntRxnBool(n)
        % Reaction IDs
        if (model.rev(n))
            metInd = find(model.S(:,n) ~= 0 & allowedMet & selMet);
            for j = 1:length(metInd)
                m = metInd(j);
                if replicateMetBool(m)
                    fprintf(fid,'%s (rev) %s\t',model.rxns{n},[model.mets{m} '_' model.rxns{n}]);
                else
                    fprintf(fid,'%s (rev) %s\t',model.rxns{n},model.mets{m});
                end
                %attributes
                if ~isempty(C)
                    %attributes
                    for c=1:size(C,2)
                        fprintf(fid,'%s\t',C{n,c});
                    end
                end
                if ~isempty(B)
                    %attributes
                    for c=1:size(B,2)
                        if B(n,c)~=0
                            %true colour
                            fprintf(fid,'%s\t',yesColor);
                        else
                            %false colour
                            fprintf(fid,'%s\t',noColor);
                        end
                    end
                end
                if ~isempty(N)
                    for c=1:size(N,2)
                        fprintf(fid,'%d\t',N(n,c));
                    end
                end
                fprintf(fid,'\n');
            end
        else
            metInd = find(model.S(:,n) < 0 & allowedMet & selMet);
            for j = 1:length(metInd)
                m = metInd(j);
                if replicateMetBool(m)
                    fprintf(fid,'%s (dir) %s\t',[model.mets{m} '_' model.rxns{n}],model.rxns{n});
                else
                    fprintf(fid,'%s (dir) %s\t',model.mets{m},model.rxns{n});
                end
                %attributes
                if ~isempty(C)
                    %attributes
                    for c=1:size(C,2)
                        fprintf(fid,'%s\t',C{n,c});
                    end
                end
                if ~isempty(B)
                    for c=1:size(B,2)
                        if B(n,c)~=0
                            %true colour
                            fprintf(fid,'%s\t',yesColor);
                        else
                            %false colour
                            fprintf(fid,'%s\t',noColor);
                        end
                    end
                end
                if ~isempty(N)
                    for c=1:size(N,2)
                        fprintf(fid,'%d\t',N(n,c));
                    end
                end
                fprintf(fid,'\n');
            end
            metInd = find(model.S(:,n) > 0 & allowedMet & selMet);
            for j = 1:length(metInd)
                m = metInd(j);
                if replicateMetBool(m)
                    fprintf(fid,'%s (dir) %s\t',model.rxns{n},[model.mets{m} '_' model.rxns{n}]);
                else
                    fprintf(fid,'%s (dir) %s\t',model.rxns{n},model.mets{m});
                end
                %attributes
                if ~isempty(C)
                    %attributes
                    for c=1:size(C,2)
                        fprintf(fid,'%s\t',C{n,c});
                    end
                end
                if ~isempty(B)
                    for c=1:size(B,2)
                        if B(n,c)~=0
                            %true colour
                            fprintf(fid,'%s\t',yesColor);
                        else
                            %false colour
                            fprintf(fid,'%s\t',noColor);
                        end
                    end
                end
                if ~isempty(N)
                    for c=1:size(N,2)
                        fprintf(fid,'%d\t',N(n,c));
                    end
                end
                fprintf(fid,'\n');
            end
        end
    end
end
fclose(fid);