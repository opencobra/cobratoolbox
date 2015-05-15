function [ref,normalizedFlux,newListRxn] = addFlux(model,FBA_result,parsed,listRxn)

% Change the thickness attributes of the reaction links in a CellDesigner
% model structure and make them propotional to the flux values obtained
% from COBRA functions
%
%
%INPUTS
%
% model               A COBRA model structure
% FBAresult           FBA results of a COBRA simulation by the
%                     'optimizeCbModel' fucntion
% parsed              The CD model structure outputed by the 'parseCD'
%                     function
% listRxn             A list of reaction IDs, after which the flux values
%                     are modified or added. P.s., the reaction IDs must be
%                     present in both the parsed CD model and the COBRA
%                     model structures. the reactions can be examined by
%                     'cmpR' funciton.
%
%
%OUTPUTS
%
% ref                 An updated parsed CellDesigner model that include
%                     information about the width of reaciton links
%
% normalizedFlux      A list of normalised flux values generated based on
%                     'FBA_result'.
%
%
%EXAMPLE
%
% [ parsed_1 ] = addFlux(recon2,fba_results,parsePD,listRxn);
%
% Longfei Mao Oct/2014



ref=parsed;
FBAsolution=FBA_result;

%%%% 1)

% if ~isempty(listRxn)
%     for ll=1:length(listRxn);
%         ind(ll)=find(strcmp(listRxn(ll),model.rxns(:))); % record every index number for each reaction present in the model.rxn.
%     end
% else
%     error('no reaction in the reaction list can be found');
% end

%%%% 2)

% for 1:length(ind(:))

%%%%%%%%%%%%      obtain the reaction indecies in the model
if (iscell(listRxn))
    [tmp,rxnID] = ismember(listRxn,model.rxns);
    
    %%%% check if the reaction names of the listRxn appear in the list of
    %%%% the rection name list of the model.
    if rxnID==0;
        [tmp,rxnID] = ismember(listRxn,model.rxnNames);
    end
else
    rxnID = find(strcmp(model.rxns,listRxn));
    if (isempty(rxnID))
        rxnID = 0;
    end
    if (length(rxnID) > 1)
        rxnID = rxnID(1);
    end    
    %%%% check if the reaction names of the listRxn appear in the list of
    %%%% the rection name list of the model.
    if rxnID==0
        rxnID = find(strcmp(model.rxnNames,listRxn));
    end    
end
if rxnID==0
    disp(rxnID)
    error('cannot find the reaction IDs in the model');    
end
flux(:,1)=FBAsolution.x(rxnID)
%%%%%% normalise the flux values.
absFlux=abs(flux);
rxnWidth=absFlux/max(absFlux);
rxnWidth(rxnWidth>=1)=8;   % normalize the values in the descending order
rxnWidth(rxnWidth>0.8 & rxnWidth<1)=6;
rxnWidth(rxnWidth>0.5 & rxnWidth<=0.8)=5;
rxnWidth(rxnWidth>0.2 & rxnWidth<=0.5)=4;
rxnWidth(rxnWidth>1e-3 & rxnWidth<=0.2)=3;
rxnWidth(rxnWidth<1e-3)=0;
% normalized values
normalizedFlux=flux(:,1);
normalizedFlux(:,2)=rxnWidth(:,1);


%results=[];


[ID_row,ID_Column]=size(ref.r_info.ID);

for m=1:ID_row;
    for n=1:ID_Column;
        r=iscellstr(ref.r_info.ID(m,n));
        if ~r; 
            %results(or,1)=m; 
            %results(or,2)=n;
            ref.r_info.ID{m,n}=' '
        end;
    end;
end

for r=1: length(flux)
    rxnList_width(r)=rxnWidth(r);
    id=find(ismember(ref.r_info.ID,listRxn(r)))  % a situation where the third column stores the reaction IDs.
    if id
        [m,n]=size(ref.r_info.ID);
        if id>m*(n-1)  % the third column of ref.r_info.ID contains reaction ID; for example: {'re5160','re8','DESAT16_2'}
            newRxnName=ref.r_info.ID{id-2*m}; % newRxnName is defined to be the ID in the first column of ref.r_info.ID.
        end
        try
        [rw,cw]=size(ref.(newRxnName).width)
        catch
            return
            
        end
        
        for  ddr=1:rw
            for  ddc=1:cw
                ref.(newRxnName).width{ddr,ddc}=rxnList_width(r)
                fprintf('set %s ''s width to %d \n',newRxnName,rxnList_width(r));
            end
        end
        newListRxn{r,1}=newRxnName;
    else
        % newRxnName=listRxn{r};
        %%%%%%%% modifying the parsed CD model
        % ref.(listRxn{r}) %
        if ~isfield(ref,listRxn{r})
            newRxnName=strcat('R_',listRxn{r});
            if  isempty(strfind(newRxnName,'(e)'))
                newRxnName=strrep(newRxnName,'(e)','_e');
            end
            if ~isfield(ref,newRxnName)
                disp(listRxn{r});
                fprintf('error ! the listRxn{%d}',r);
                r=r+1  % procede to the next reaction
            else
                [rw,cw]=size(ref.(newRxnName).width)
                for  ddr=1:rw
                    for  ddc=1:cw
                        ref.(newRxnName).width{ddr,ddc}=rxnList_width(r)
                        fprintf('set %s ''s width to %d \n',newRxnName,rxnList_width(r));
                    end
                end
                
            end
        end
    end
end
