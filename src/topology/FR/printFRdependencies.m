function printFRdependencies(model,filePathName)
%report on the dependencies between rows of [F,R], either to the command
%line (default) or to a specified text file
%
%INPUT
%model          model output from checkRankFR
%
%OPTIONAL INPUT
%filePathName   full file name for printing dependencies to file

%vanilla forward and reverse half stoichiometric matrices
F       = -model.S;
F(F<0)  =    0;
R       =  model.S;
R(R<0)  =    0;

%recover indices from boolean vectors
dR=find(model.FRdrows);
wR=find(model.FRwrows);
    
if exist('filePathName','var')
    %Open or create new file for writing. Append data to the end of the file
    fileID = fopen(filePathName,'a');

    %print out dependencies to file
    for i=1:size(model.FRW,1)
        fprintf(fileID,'%s%s',model.mets{dR(i)},' is dependent on: ');
        ind=find(model.FRW(i,:));
        if length(ind)<9
            for j=1:length(ind)
                fprintf(fileID,'%s',model.mets{ind(j)});
                if j==length(ind)
                    fprintf(fileID,'%s\n','.');
                else
                    fprintf(fileID,'%s',' and ');
                end
            end
        else
            fprintf(fileID,'%s\n',' 10 or more metabolites, will not be displayed');
        end
        %print out reactions involving dependent rows
        F0=F;
        F0(:,~model.FRVcols)=0;
        R0=R;
        R0(:,~model.FRVcols)=0;
        indRxn=[find(F0(dR(i),:)~=0) find(R0(dR(i),:)~=0)];
        if length(indRxn)>1
            fprintf(fileID,'%s\n','The reactions are:');
        else
            fprintf(fileID,'%s\n','The reaction is:');
        end
        for k=1:length(indRxn)
            printFlag=0;
            %printing to file does not normally print out model.rxn{}
            fprintf(fileID,'%s\t',model.rxns{indRxn(k)});
            tmp=printRxnFormula(model,model.rxns{indRxn(k)},printFlag);
            fprintf(fileID,'%s\n',tmp{1});
        end
        fprintf(fileID,'\n');
    end
    
    %display the rows involved
    FRdisplay=[F(:,model.FRVcols), R(:,model.FRVcols)];
    FRdisplay=FRdisplay([wR;dR],:);
    FRdisplay=FRdisplay(:,sum(FRdisplay,1)~=0);
    FRdisplay=full(FRdisplay);
    %disp(FRdisplay)
    
    fprintf(fileID,'%s%d%s%d%s%d%s\n','FR subset of dimension ',size(FRdisplay,1),' x ', size(FRdisplay,2), ', of rank ', rank(FRdisplay),'.');
    if max(size(FRdisplay))>15
        fprintf(fileID,'%s\n','More than 15 rows or columns in the dependency, so will not display.');
    else
        fprintf(fileID,'%d%s\n', length(wR), ' independent rows:');
        fclose(fileID);
        %disp(FRdisplay(1:length(wR),:))
        dlmwrite(filePathName,FRdisplay(1:length(wR),:),'-append','delimiter',' ');
        fileID = fopen(filePathName,'a');
        fprintf(fileID,'%d%s\n',length(dR),' dependent rows:');
        fclose(fileID);
        %disp(FRdisplay(length(wR)+1:end,:))
        dlmwrite(filePathName,FRdisplay(length(wR)+1:end,:),'-append','delimiter',' ')
    end
else
    %print out dependencies to console
    for i=1:size(model.FRW,1)
        fprintf('%s%s',model.mets{dR(i)},' is dependent on: ')
        ind=find(abs(model.FRW(i,:))>1e-6);
        if length(ind)<9
            for j=1:length(ind)
                fprintf('%s',model.mets{ind(j)})
                if j==length(ind)
                    fprintf('%s\n','.');
                else
                    fprintf('%s',' and ');
                end
            end
        else
            fprintf('%s\n',' 10 or more metabolites, will not be displayed')
        end
        %print out reactions involving dependent rows
        F0=F;
        F0(:,~model.FRVcols)=0;
        R0=R;
        R0(:,~model.FRVcols)=0;
        indRxn=[find(F0(dR(i),:)~=0) find(R0(dR(i),:)~=0)];
        if length(indRxn)>1
            fprintf('%s\n','The reactions are:')
        else
            fprintf('%s\n','The reaction is:')
        end
        for k=1:length(indRxn)
            printRxnFormula(model,model.rxns{indRxn(k)});
            fprintf('\n')
        end
        fprintf('\n')
    end
    
    %display the rows involved
    FRdisplay=[F(:,model.FRVcols), R(:,model.FRVcols)];
    FRdisplay=FRdisplay([wR;dR],:);
    FRdisplay=FRdisplay(:,sum(FRdisplay,1)~=0);
    FRdisplay=full(FRdisplay);
    %disp(FRdisplay)
    
    fprintf('%s%d%s%d%s%d%s\n','FR subset of dimension ',size(FRdisplay,1),' x ', size(FRdisplay,2), ', of rank ', rank(FRdisplay),'.')
    if max(size(FRdisplay))>15
        fprintf('%s\n','More than 15 rows or columns in the depencency, so will not display.')
    else
        fprintf('%d%s\n', length(wR), ' independent rows:')
        disp(FRdisplay(1:length(wR),:))
        fprintf('%d%s\n',length(dR),' dependent rows:')
        disp(FRdisplay(length(wR)+1:end,:))
    end
end


%old code
%     %print out dependencies
%     for i=1:size(model.FRW,1)
%         fprintf('%s%s',model.mets{dR(i)},' is dependent on: ')
%         ind=find(model.FRW(i,:)>0);
%         for j=1:length(ind)
%             fprintf('%s',model.mets{ind(j)})
%             if j==length(ind)
%                 fprintf('%s\n','.');
%             else
%                 fprintf('%s',' and ');
%             end
%         end
%     end

if 0
    if printLevel>2 && model.FRcolRankDeficiency>0
        if 0
            for i=1:size(model.FRVW,2)
                fprintf('%s%s',model.rxns{dC(i)},' is dependent on: ')
                ind=find(model.FRVW(:,i)>0);
                for j=1:length(ind)
                    fprintf('%s',model.rxns{ind(j)})
                    if j==length(ind)
                        fprintf('%s\n','.');
                    else
                        fprintf('%s',' and ');
                    end
                end
            end
        else
            %print out metabolites involved in dependent cols
            for i=1:size(model.FRVW,2)
                fprintf('%s%s',model.rxns{dC(i)},' is dependent on: ')
                ind=find(model.FRVW(i,:)>0);
                for j=1:length(ind)
                    fprintf('%s',model.rxns{ind(j)})
                    if j==length(ind)
                        fprintf('%s\n','.');
                    else
                        fprintf('%s',' and ');
                    end
                end
                fprintf('%s\n','The metabolites  are:')
                F0=F;
                F0(~model.FRrows,:)=0;
                R0=R;
                R0(~model.FRrows,:)=0;
                indMet=[find(F0(:,dC(i))~=0)' find(R0(:,dC(i))~=0)'];
                disp(indMet)
                %             for k=1:length(indMet)
                %                 printRxnFormula(model,model.mets{indMet(k)});
                %             end
                fprintf('\n\n')
            end
            
            %display the cols involved
            FRdisplay=[F(model.FRrows,:), R(model.FRrows,:)];
            FRdisplay=FRdisplay(:,[wC;dC]);
            FRdisplay=FRdisplay(sum(FRdisplay,2)~=0,:);
            FRdisplay=full(FRdisplay);
            %disp(FRdisplay)
            
            fprintf('%s%d%s%d%s%d%s\n','FRV subset of dimension ',size(FRdisplay,1),' x ', size(FRdisplay,2), ', of rank ', rank(FRdisplay),'.')
            fprintf('%d%s\n', length(wC), ' independent cols:')
            if length(wC)>10
                fprintf('%s\n','Too many to print out.')
            else
                disp(FRdisplay(:,1:length(wC)))
            end
            fprintf('%d%s\n',length(dC),' dependent rows:')
            
            if length(dC)>10
                fprintf('%s\n','Too many to print out.')
            else
                disp(FRdisplay(:,length(wC)+1:end))
            end
        end
    end
    
end