function writeReactionListThermo(model,FileName,start,stop)
% exports a list of reactions and bounds to a text file
%
% INPUT
% model
% FileName  Name of output file
%
% OPTIONAL INPUT
% start     integer index of first reaction index to write out
% stop      integer index of last reaction index to write out
%
% Ines Thiele 07/12/07
% Ronan Fleming - slight adaption for thermodynamic model

if nargin < 4
    stop = length(model.rxns);
end

if nargin < 3
    start = 1;
end

h = waitbar(0, 'Writing reaction list is in Progress ...');
fid = fopen(FileName,'w');
for j=start:stop
    fprintf(fid,'%d',j);
    fprintf(fid,'\t');
    fprintf(fid,'%s',model.rxns{j});
    fprintf(fid,'\t');
    fprintf(fid,'%s',model.rxn(j).officialName);
    fprintf(fid,'\t');
    tmp=find(model.S(:,j)<0);
    for i=1:length(tmp)
        fprintf(fid,'%d',-1*model.S(tmp(i),j));
        fprintf(fid,'%s',' ');
        fprintf(fid,'%s',model.mets{tmp(i)});
        if (i~=length(tmp))
            fprintf(fid,'%s',' + ');
        end
    end
    clear tmp;
    if(model.lb(j)<0)
        fprintf(fid,'%s',' <==> ');
    elseif    (strncmp(model.rxns{j},'EX_',3)) || (strncmp(model.rxns{j},'Exch_',5))
        % exception for exchange reactions whose compounds are only
        % secreted
        if length(find(model.S(:,j)>0))==0
            fprintf(fid,'%s',' <==> ');
        end
    else
        fprintf(fid,'%s', ' --> ');
    end
    tmp=find(model.S(:,j)>0);
    for i=1:length(tmp)
        fprintf(fid,'%d',model.S(tmp(i),j));
        fprintf(fid,'%s',' ');
        fprintf(fid,'%s',model.mets{tmp(i)});

        if (i~=length(tmp))
            fprintf(fid,'%s',' + ');
        end
    end
    clear tmp;
    fprintf(fid,'\t');
    fprintf(fid,'%d ',model.lb(j));
    fprintf(fid,'\t');
    fprintf(fid,'%d ',model.ub(j));
    fprintf(fid,'\t');
    %     if (model.subsystem)
    %         fprintf(fid,'%s',model.subsytem{i});
    %         fprintf(fid,'\t');
    %     end
    fprintf(fid,'\n');
    waitbar((j - start + 1)/(stop-start+1),h);
end
fclose(fid);
close(h);