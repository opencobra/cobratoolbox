% findNearRxns.m
% Additional script of the Paint4Net to find the neightbor reactions
%
% function Rxns=findNearRxns(model,Rxns,direction,flux)
%
% INPUT
%
% model - COBRA Toolbox model
% metAbbr - a cell type variable that can take a value that represents the
%       abbreviation of a metabolite in the COBRA model. This metabolite is
%       the start point for visualization. 
% Rxns - a list of reactions in the COBRA model in the form
%       {'Rxn_Abbr_1','Rxn_Abbr_2',...,'Rxn_Abbr_n'} or cell type vector from the
%       MATLAB workcpase.
% direction - a string type variable that can take value of 'struc', 'sub',
%       'prod' or 'both' (default is 'struc') indicating a direction for the
%       algorithm. In case of 'struc' (structure) the algorithm visualizes all
%       metabolites connected to the specified reactions in the argument rxns.
%       The key feature of this function is visualization of all specified reactions
%       not taking in account a steady state fluxes in that way representing the
%       structure of the COBRA model. In case of 'sub' (substrates) the algorithm
%       visualizes only those metabolites which are substrates for the specified 
%       reactions in the argument rxns. This time the algorithm is using a stoichiometric 
%       matrix and the steady state fluxes to determine direction of each reaction. 
%       The algorithm is using an assumption that only those fluxes which rates
%       are smaller than -10-9 mmol*g-1*h-1 or greater than +10-9 mmol*g-1*h-1 
%       are non-zero fluxes. In case of 'prod' (products) the algorithm visualizes 
%       only those metabolites which are products for the specified reactions in 
%       the argument rxns but in case of 'both' the algorithm visualizes both
%       – substrates and products - for the specified reactions in the argument
%       rxns. For both cases the algorithm is using the same rules regarding to 
%       calculation of the directions for each reaction as for case of 'sub'.
%       This argument is essential for the command draw_by_met of the
%       Paint4Net v1.2
%       because the command draw_by_met is calling out the command draw_by_rxn
%       and passing the argument direction.
% flux - a double type Nx1 size vector of fluxes of reactions where N is number 
%       of reactions (default is vector of x). This vector is calculated during
%       the optimization of the objective function. Use the command
%       optimizeCbModel.m.
%
% OUTPUT
%
% Rxns - a list of reactions from the COBRA model.
%
% Andrejs Kostromins 17/02/2012 E-mail: andrejs.kostromins@gmail.com

function Rxns=findNearRxns(model,Rxns,direction,flux)

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