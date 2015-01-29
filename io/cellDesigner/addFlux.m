function [ref,normalizedFlux] = addFlux(model,FBA_result,parsed,listRxn)

% [ parsed_1 ] = addFlux(recon2,fba_results,parsePD,listRxn);



% INPUT

% model - a COBRA model
% FBAresult - FBA results;
% parsed - outputed by pareCD function
% listRxn - a list of reaction present in both the CellDsigner file and the
% COBRA model; the list can be identified by cmpR funciton.



%OUTPUT

% ref - a updated parased CellDesigner model.
% normalizedFlux - a list of normalized flux values.


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


rxnWidth(rxnWidth>=1)=10;   % normalize the values in the descending order
rxnWidth(rxnWidth>0.5 & rxnWidth<1)=5; 
rxnWidth(rxnWidth>1e-3 & rxnWidth<=0.5)=2;
rxnWidth(rxnWidth<1e-3)=0;
 % normalized values
    %
                 %

normalizedFlux=flux(:,1);
normalizedFlux(:,2)=rxnWidth(:,1);



for r=1: length(flux)
    
    rxnList_width(r)=rxnWidth(r);
    
    newRxnName=listRxn{r};
    
    %%%%%%%% modifying the parsed CD model
    
    % ref.(listRxn{r}) %
    if ~isfield(ref,listRxn{r})
        
        newRxnName=strcat('R_',listRxn{r});
        if  isempty(strfind(newRxnName,'(e)'))     
            newRxnName=strrep(newRxnName,'(e)','_e');
        end
        
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





