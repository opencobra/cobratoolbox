function Rxns = findNearRxns(model, Rxns, direction, flux)
% Finds neighbouring reactions for Paint4Net visualisation.
%
% USAGE:
%
%    Rxns = findNearRxns(model, Rxns, direction, flux)
%
% INPUTS:
%    model:        COBRA model structure.
%    Rxns:         Cell array of reaction abbreviations in the COBRA model, or
%                  a cell vector from the MATLAB workspace.
%
% OPTIONAL INPUTS:
%    direction:    Direction used by the algorithm. Allowed values are:
%
%                  * 'struc' - Find all metabolites connected to the specified
%                    reactions, without considering steady-state fluxes. This
%                    represents the structure of the COBRA model.
%
%                  * 'sub' - Find metabolites acting as substrates for the
%                    specified reactions. Reaction direction is inferred from the
%                    stoichiometric matrix and steady-state fluxes.
%
%                  * 'prod' - Find metabolites acting as products for the
%                    specified reactions. Reaction direction is inferred from the
%                    stoichiometric matrix and steady-state fluxes.
%
%                  * 'both' - Find both substrates and products for the specified
%                    reactions. Reaction direction is inferred from the
%                    stoichiometric matrix and steady-state fluxes.
%
%                  Default: 'struc'
%
%    flux:         `nRxns x 1` vector of reaction fluxes, where `nRxns` is the
%                  number of reactions in the model. Fluxes are usually obtained
%                  with `optimizeCbModel`. Flux values smaller than
%                  `-1e-9 mmol gDW^-1 h^-1` or greater than
%                  `1e-9 mmol gDW^-1 h^-1` are treated as non-zero.
%
%                  Default: vector of zeros.
%
% OUTPUT:
%    Rxns:         Cell array of neighbouring reaction abbreviations from the
%                  COBRA model.
%
% NOTE:
%    This function is an additional Paint4Net routine. It supports
%    `draw_by_met`, which calls `draw_by_rxn` and passes the `direction`
%    argument.
%
% .. Author:
%       - Andrejs Kostromins, 17 Feb 2012, andrejs.kostromins@gmail.com
%

RxnsIDs=findRxnIDs(model,Rxns); %find reaction IDs in the model
metIndexes(1)=-1; %declare variable

for q=1:length(RxnsIDs) %cycle through the reaction IDs
    
    metIndex = find(model.S(:,RxnsIDs(q))); %find metabolite index in the S matrix
    
    for w=1:length(metIndex) %cycle till the met index
        
        switch direction %check the value of the variable direction
            
            case 'sub' %in cace of direction = 'sub'
                
                %if the metabolite in the S matrix has positive coefficient, but the flux is negative or the opposite
                if model.S(metIndex(w),RxnsIDs(q))>0 && flux(RxnsIDs(q))<-1e-9 || model.S(metIndex(w),RxnsIDs(q))<0 && flux(RxnsIDs(q))>1e-9
                    
                    if metIndexes(1)==-1
                        metIndexes(1,1)=metIndex(w); %add to the list of indexes           
                    else
                        
                        unique=true;
                        
                        for e=1:length(metIndexes) %cycle through the indexes
                            
                            if metIndexes(e)==metIndex(w); %if index already exist
                                unique=false;
                                break;
                            end
                            
                        end
                        
                        if unique %if index is unique
                            metIndexes(1+length(metIndexes),1)=metIndex(w);                
                        end
                        
                    end     
                    
                end
                
            case 'prod' %in cace of direction = 'prod'
                
                %if the metabolite in the S matrix has negative coefficient and the flux is negative or the opposite
                if model.S(metIndex(w),RxnsIDs(q))<0 && flux(RxnsIDs(q))<-1e-9 || model.S(metIndex(w),RxnsIDs(q))>0 && flux(RxnsIDs(q))>1e-9
                    
                    if metIndexes(1)==-1
                        metIndexes(1,1)=metIndex(w); %add to the list of indexes             
                    else
                        
                        unique=true;
                        
                        for e=1:length(metIndexes) %cycle through the indexes
                            
                            if metIndexes(e)==metIndex(w); %if index already exist
                                unique=false;
                                break;
                            end
                            
                        end
                        
                        if unique %if index is unique
                            metIndexes(1+length(metIndexes),1)=metIndex(w);                
                        end
                        
                    end   
                    
                end
                
            case 'both' %in cace of direction = 'both'
                
                %if the reaction in the S matrix has nonzero coefficient and the flux is negative or positive
                if model.S(metIndex(w),RxnsIDs(q))~=0 && (flux(RxnsIDs(q))<-1e-9 || flux(RxnsIDs(q))>1e-9)
                    
                    if metIndexes(1)==-1
                        metIndexes(1,1)=metIndex(w); %add to the list of indexes            
                    else
                        
                        unique=true;
                        
                        for e=1:length(metIndexes) %cycle through the indexes
                            
                            if metIndexes(e)==metIndex(w); %if index already exist
                                unique=false;
                                break;
                            end
                            
                        end
                        
                        if unique %if index is unique
                            metIndexes(1+length(metIndexes),1)=metIndex(w);                
                        end
                        
                    end   
                    
                end
                
            case 'struc' %in cace of direction = 'struc'
                
                
                if model.S(metIndex(w),RxnsIDs(q))~=0 %if the reaction in the S matrix has nonzero coefficient
                    
                    if metIndexes(1)==-1
                        metIndexes(1,1)=metIndex(w); %add to the list of indexes             
                    else
                        
                        unique=true;
                        
                        for e=1:length(metIndexes) %cycle through the indexes
                            
                            if metIndexes(e)==metIndex(w); %if index already exist
                                unique=false;
                                break;
                            end
                            
                        end
                        
                        if unique %if index is unique
                            metIndexes(1+length(metIndexes),1)=metIndex(w);                
                        end
                        
                    end  
                    
                end  
                
        end   
        
    end
    
end

for q=1:length(metIndexes) %cycle through the indexes
    mets{q,1}=model.mets{metIndexes(q)};
end

Rxns2=findRxnsFromMets(model,mets);  %find reactions around the metabolites
RxnsID=findRxnIDs(model,Rxns2); %find reaction IDs in the model
metsID2=findMetIDs(model,mets); %find metabolite IDs in the model
Direction_Rxns{1}='-1'; %declare variable

for q=1:length(RxnsID) %cycle through the reaction IDs
    
    for w=1:length(metsID2) %cycle through the metabolite IDs
        
        switch direction %check the value of the variable direction
            
            case 'sub' %in cace of direction = 'sub'
                
                %if the metabolite in the S matrix has negative coefficient and the flux is negative or the opposite
                if model.S(metsID2(w),RxnsID(q))<0 && flux(RxnsID(q))<-1e-9 || model.S(metsID2(w),RxnsID(q))>0 && flux(RxnsID(q))>1e-9
                    
                   if strcmp(Direction_Rxns{1},'-1')
                      Direction_Rxns{1,1}=Rxns2{q};            
                   else
                      Direction_Rxns{length(Direction_Rxns)+1,1}=Rxns2{q};
                   end
                   
                end
                
            case 'prod' %in cace of direction = 'prod'
                
                %if the metabolite in the S matrix has positive coefficient, but the flux is negative or the opposite
                if model.S(metsID2(w),RxnsID(q))>0 && flux(RxnsID(q))<-1e-9 || model.S(metsID2(w),RxnsID(q))<0 && flux(RxnsID(q))>1e-9
                    
                   if strcmp(Direction_Rxns{1},'-1')
                      Direction_Rxns{1,1}=Rxns2{q};            
                   else
                      Direction_Rxns{length(Direction_Rxns)+1,1}=Rxns2{q};
                   end
                   
                end
                
            case 'both' %in cace of direction = 'both'
                
               %if the reaction in the S matrix has nonzero coefficient and the flux is negative or positive 
               if model.S(metsID2(w),RxnsID(q))~=0 && (flux(RxnsID(q))<-1e-9 || flux(RxnsID(q))>1e-9)
                   
                   if strcmp(Direction_Rxns{1},'-1')
                      Direction_Rxns{1,1}=Rxns2{q};            
                   else
                      Direction_Rxns{length(Direction_Rxns)+1,1}=Rxns2{q};
                   end
                   
               end
               
            case 'struc' %in cace of direction = 'struc'
                
                
               if model.S(metsID2(w),RxnsID(q))~=0 %if the reaction in the S matrix has nonzero coefficient
                   
                   if strcmp(Direction_Rxns{1},'-1')
                      Direction_Rxns{1,1}=Rxns2{q};            
                   else
                      Direction_Rxns{length(Direction_Rxns)+1,1}=Rxns2{q};
                   end
                   
               end
                
        end    
        
    end
    
end

if ~strcmp(Direction_Rxns{1},'-1') %if list of reactions is not empty
    
    for q=1:length(Direction_Rxns) %cycle through the reactions
        
        for w=1:length(Rxns) %cycle through the reactions
            
            unique=true;
            
            if strcmp(Rxns{w,1},Direction_Rxns{q,1}); %check uniqueness of reaction
               unique=false;       
               break;
            end      
            
        end

        if unique %if reaction is unique
               Rxns{1+length(Rxns),1}=Direction_Rxns{q};                
        end 
        
    end
    
end
