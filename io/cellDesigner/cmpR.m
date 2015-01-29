function [ results ] = cmpR(parsed,model)

% example: cmp_PD_recon2_result=cmpR(parsePD,recon2)


%% INPUT
% parsed - 'parseCD'outputed variable, e.g., parseRecon2

% model= a COBRA model;

% there are three fields "meid, id and name"; we would like to compare
% the reaction IDs in Recon 2 to thoese three independent columns.

%% OUTPUT
%  main: This contains all the analysis results.                                  
%  listOfFound: a list of reactions in the focusing model that
%  are present in the reference COBRA model.
%  listOfNotFound: a list of reactions in the focusing model that
%  are NOT present in the reference COBRA model.
%  list_of_rxns_not_present_in_ReferenceModel: A list of reactions in the
%  reference model that are NOT included in the focusing model.



%%



% isempty(find(~cellfun('isempty',strfind(model.mets,secM_red))));

rxnList_p=parsed.r_info.ID(:,:);
[r_original,c_original]=size(parsed.r_info.ID);

rxnList_m(:,1)=model.rxns(:,1);rxnList_m(:,2)=model.rxnNames(:,1);

rxnList_m(:,:)=lower(rxnList_m(:,:));%% Convert string to lowercase.
%rxnList_p=lower(rxnList_p);

results.main=rxnList_p;  % rxnList_p, the parsed CD model.



nF=1; nU=1;
for r_p=1:length(rxnList_p(:,1));

    for numOfID=1:c_original;  % three different forms of ID, names;
        
        %% the rxn acts as the keywords in the searching
        rxn=strtrim(rxnList_p(r_p,numOfID)); % removing the leading and the trailing white space from the string.
         rxn{1}=lower(rxn{1}); %% Convert string to lowercase.
        
        % find(~cellfun('isempty',strfind(rxnList_m(:,1),name{2})))
        if ~ischar(rxn{1})
            disp(rxn{1})
            rxn{1}=char(rxn{1});
           % error('wrong');

        end
        
        
        if ~isempty(find(~cellfun('isempty',strfind(rxnList_m(:,1),rxn{1})))) % rxnList_m a COBRA model;
            results.main{r_p,c_original+2}='found';
            results.listOfFound(nF,1:c_original)=rxnList_p(r_p,1:c_original);  % rxnList_p parsed model
            results.listOfFound{nF,c_original+2}='Present in the Reference mode';
            nF=nF+1;
             break;
        elseif numOfID==c_original
            results.listOfNotFound(nU,1:c_original)=rxnList_p(r_p,1:c_original);;
            results.listOfNotFound{nU,c_original+2}='Not Present in the Reference mode';
            nU=nU+1;
        end
        
        
    end
    
end




nL=1;rxnList_p_2=parsed.r_info.ID(:,:);
nn=1;

 
    
    
for col=1:c_original
    for row=1:r_original;
        
        masterList(nn,1)=rxnList_p_2(row,col);
        nn=nn+1;
    end
end



disp('start searching reactions present in the reference model but not in the CD model')
for r_m=1:length(rxnList_m(:,1));
    

        
        rxn=strtrim(rxnList_m(r_m,1)); % removing the leading and the trailing white space from the string.
        %         try
      %  if isempty(find(strcmpi(rxn,rxnList_p_2(:,col))))
      
         if isempty(find(strcmpi(rxn,masterList(:,1)))) 

            results.list_of_rxns_not_present_in_ReferenceModel(nL,1)=rxn;
            
            %isempty(find(~cellfun('isempty',strfind(rxnList_p(:,1),rxn{1}))));
            % results.main_{r_p,c_original+2}='found';
            % results.listOfFound(nF,1:3)=rxnList_p(r_p,1:3);
            %results.listOfFound{nF,c_original+2}='Present in the Reference mode';
            %nF=nF+1;
            %     else
            %
            %         results.listOfNotFound(nU,1:3)=rxnList_p(r_p,1:3);;
            %         results.listOfNotFound{nU,c_original+2}='Not Present in the Reference mode';
            %
            nL=nL+1;

        %         catch
        %             disp(rxnList_m{r_m,1})
        %             disp(rxnList_p(:,col))
        %         end
        
    end
    
end

