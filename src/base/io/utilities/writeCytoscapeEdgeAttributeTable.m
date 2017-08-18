function writeCytoscapeEdgeAttributeTable(model, C, B, N, replicateMetBool, filename)
% Writes out a set of boolean edge attributes as one of a pair of colours,
% 'Red' for 'yes', 'Black' for 'no'
%
% USAGE:
%
%    writeCytoscapeEdgeAttributeTable(model, C, B, N, replicateMetBool, filename)
%
% INPUTS:
%    model:               structure with obligatory field .S - `met` x `reaction`
%    C:                   `reaction` x `attribute` cell array
%    B:                   `reaction` x `attribute` Boolean matrix
%    N:                   `reaction` x `attribute` numeric array
%    replicateMetBool:    boolean for replicated mets
%    filename:            name of the file


yesColor='Red';
noColor='Black';

if ~exist('filename','var')
    if isfield(model,'description')
      x=1
        filename=[model.description 'edgeAttributes.txt'];
    else
      x=2
        filename='edgeAttributes.txt';
    end
end

[nMet,nRxn]=size(model.S);

if ~isfield(model,'SIntRxnBool')
  x=3
    model.SIntRxnBool=true(nRxn,1);
end

allowedMet=true(nMet,1);
selMet=true(nMet,1);

%write unique reaction cycles as edge attribute files
fid=fopen(filename,'w');

for n=1:nRxn
    if model.SIntRxnBool(n)
      x=4
        % Reaction IDs
        if (model.lb(n) < 0)
          x=5
            metInd = find(model.S(:,n) ~= 0 & allowedMet & selMet);
            for j = 1:length(metInd)
                m = metInd(j);
                if replicateMetBool(m)
                  x=6
                    fprintf(fid,'%s (rev) %s\t',model.rxns{n},[model.mets{m} '_' model.rxns{n}]);
                else
                  x=7
                    fprintf(fid,'%s (rev) %s\t',model.rxns{n},model.mets{m});
                end
                %attributes
                if ~isempty(C)
                  x=8
                    %attributes
                    for c=1:size(C,2)
                        fprintf(fid,'%s\t',C{n,c});
                    end
                end
                if ~isempty(B)
                  x=9
                    %attributes
                    for c=1:size(B,2)
                        if B(n,c)~=0
                          x=10
                            %true colour
                            fprintf(fid,'%s\t',yesColor);
                        else
                          x=11
                            %false colour
                            fprintf(fid,'%s\t',noColor);
                        end
                    end
                end
                if ~isempty(N)
                  x=12
                    for c=1:size(N,2)
                        fprintf(fid,'%d\t',N(n,c));
                    end
                end
                fprintf(fid,'\n');
            end
        else
          x=13
            metInd = find(model.S(:,n) < 0 & allowedMet & selMet);
            for j = 1:length(metInd)
                m = metInd(j);
                if replicateMetBool(m)
                  x=14
                    fprintf(fid,'%s (dir) %s\t',[model.mets{m} '_' model.rxns{n}],model.rxns{n});
                else
                  x=15
                    fprintf(fid,'%s (dir) %s\t',model.mets{m},model.rxns{n});
                end
                %attributes
                if ~isempty(C)
                  x=16
                    %attributes
                    for c=1:size(C,2)
                        fprintf(fid,'%s\t',C{n,c});
                    end
                end
                if ~isempty(B)
                  x=17
                    for c=1:size(B,2)
                        if B(n,c)~=0
                          x=18
                            %true colour
                            fprintf(fid,'%s\t',yesColor);
                        else
                          x=19
                            %false colour
                            fprintf(fid,'%s\t',noColor);
                        end
                    end
                end
                if ~isempty(N)
                  x=20
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
                  x=21
                    fprintf(fid,'%s (dir) %s\t',model.rxns{n},[model.mets{m} '_' model.rxns{n}]);
                else
                  x=22
                    fprintf(fid,'%s (dir) %s\t',model.rxns{n},model.mets{m});
                end
                %attributes
                if ~isempty(C)
                  x=23
                    %attributes
                    for c=1:size(C,2)
                        fprintf(fid,'%s\t',C{n,c});
                    end
                end
                if ~isempty(B)
                  x=24
                    for c=1:size(B,2)
                        if B(n,c)~=0
                          x=25
                            %true colour
                            fprintf(fid,'%s\t',yesColor);
                        else
                          x=26
                            %false colour
                            fprintf(fid,'%s\t',noColor);
                        end
                    end
                end
                if ~isempty(N)
                  x=27
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
