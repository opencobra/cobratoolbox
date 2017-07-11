% draw_by_met.m
% Script of the Paint4Net to define the scope of visualization by a
% metabolite
%
% function [involvedRxns,involvedMets,deadEnds,deadRxns]=draw_by_met(model,metAbbr,drawMap,radius,direction,excludeMets,flux,save,closev)
%
% INPUT
%
% model - COBRA Toolbox model
% metAbbr - a cell type variable that can take a value that represents the
%       abbreviation of a metabolite in the COBRA model. This metabolite is
%       the start point for visualization. 
%
% OPTIONAL INPUT
%
% drawMap - a logical type variable that can take value of true or false
%       (default is false) indicating whether to visualize the COBRA model or not.
%       The main idea of this argument is to ensure possibility to save
%       time by not visualizing a large COBRA model and get a result faster.
% radius - a double type variable that can take a value of natural numbers
%       (1,2,3…n). The argument radius indicates the depth of an analysis
%       of the initial metabolite (the argument metAbbr) and it is tightly 
%       connected to the optional argument direction. For example, if user 
%       is interested in the substrates of ethanol, the user can analyse substrates
%       step by step starting from the first reactions where the argument radius 
%       is equal to 1 and moving to the next reactions by increasing the value 
%       of the argument radius.
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
%       This argument is essential for the command draw_by_met of the Paint4Net v1.0
%       because the command draw_by_met is calling out the command draw_by_rxn
%       and passing the argument direction.
% excludeMets - a list of metabolites (default is empty) that will be excluded
%       from the visualization map of the COBRA model in form of the abbreviations
%       of the metabolites separated by a comma
%       {'Met_Abbr_1','Met_Abbr_2',...,'Met_Abbr_n'} or a cell type vector 
%       in the MATLAB workspace that contains the static abbreviations of the
%       metabolites. The main idea of this argument is to ensure possibility 
%       to exclude very employed metabolites (e.g., h, h2o, atp, adp, nad etc.)
%       to avoid unnecessary mesh on the map.
% flux - a double type Nx1 size vector of fluxes of reactions where N is number 
%       of reactions (default is vector of x). This vector is calculated during
%       the optimization of the objective function. Use the command
%       optimizeCbModel.m.
% save - a boolean type variable that can take value of true or false
%       (default is false) indicating whether to automatically save visualization as jpeg file or not.
%       This is usefull for iterative function call with different
%       input arguments for visualization scope.
% closev - a boolean type variable that can take value of true or false
%       (default is false) indicating whether to close the biograph viewer
%       window or not after the visualization. This is usefull for iterative
%       function call with different input arguments for visualization
%       scope.
%
% OUTPUT
%
% involvedRxns - a cell type vector that contains a list of the involved
%       reactions according to the set of input arguments.
% involvedMets - a cell type vector that contains a list of the involved metabolites
%       in the specified reactions.
% deadEnds - a cell type vector that contains a list of the dead end
%       metabolites in the specified reactions.
%
% Andrejs Kostromins 04/10/2012 E-mail: andrejs.kostromins@gmail.com

function [involvedRxns,involvedMets,deadEnds,deadRxns]=draw_by_met(model,metAbbr,drawMap,radius,direction,excludeMets,flux,save,closev)

if nargin<3 %if the number of arguments < 3, drawMap=false
   drawMap=false;
end

if nargin<4 %if the number of arguments < 4, radius=1
    radius=1;
end

if nargin<7 %if the number of arguments < 7, fill flux vector with x
    for q=1:length(model.rxns)
          flux(q)='x';
    end
end

if nargin<8 %if the number of arguments < 8, save=false
    save=false;
end

if nargin<9 %if the number of arguments < 8, closev=false
    closev=false;
end
    
if radius>0 %if radius > 0

    if ~isempty(flux) %if flux vector is not empty

        if nargin<5 %if the number of arguments < 5, direction='struc'
            direction='struc';
        end

        if nargin<6 %if the number of arguments < 6, excludeMets{1}=''
            excludeMets{1}='';
        end            
        
        Rxns=findRxnsFromMets(model,metAbbr); %find reactions around the initial metabolite

        if length(Rxns)~=0 %if the list is not empty
            
            RxnsID=findRxnIDs(model,Rxns); %find reaction IDs in the model
            metID=findMetIDs(model,metAbbr); %find initial metabolite ID in the model
            involvedRxns{1}='No rxns'; %declare variable
            
            for q=1:length(RxnsID) %cycle through the reaction IDs
                
                switch direction %check the value of the variable direction
                    
                    case 'sub' %in cace of direction = 'sub'
                        
                        %if (the reaction in the S matrix has negative coefficient and the flux is negative or the opposite) and the flux is not equal to x, add to involved reactions 
                        if (model.S(metID,RxnsID(q))<0 && flux(RxnsID(q))<-1e-9 || model.S(metID,RxnsID(q))>0 && flux(RxnsID(q))>1e-9)&&flux(RxnsID(q))~='x'
                            
                           if strcmp(involvedRxns{1},'No rxns')
                              involvedRxns{1,1}=Rxns{q};            
                           else
                              involvedRxns{length(involvedRxns)+1,1}=Rxns{q};
                           end
                           
                        end
                        
                    case 'prod' %in cace of direction = 'prod'
                        
                        %if (the reaction in the S matrix has positive coefficient, but the flux is negative or the opposite) and the flux is not equal to x, add to involved reactions
                        if (model.S(metID,RxnsID(q))>0 && flux(RxnsID(q))<-1e-9 || model.S(metID,RxnsID(q))<0 && flux(RxnsID(q))>1e-9) && flux(RxnsID(q))~='x'
                            
                           if strcmp(involvedRxns{1},'No rxns')
                              involvedRxns{1,1}=Rxns{q};            
                           else
                              involvedRxns{length(involvedRxns)+1,1}=Rxns{q};
                           end
                           
                        end
                        
                    case 'both' %in cace of direction = 'both'
                        
                        %if (the reaction in the S matrix has nonzero coefficient and the flux is negative or positive) and the flux is not equal to x, add to involved reactions
                        if (model.S(metID,RxnsID(q))~=0 && (flux(RxnsID(q))<-1e-9 || flux(RxnsID(q))>1e-9))&&flux(RxnsID(q))~='x'
                            
                           if strcmp(involvedRxns{1},'No rxns')
                              involvedRxns{1,1}=Rxns{q};            
                           else
                              involvedRxns{length(involvedRxns)+1,1}=Rxns{q};
                           end
                           
                        end
                        
                    case 'struc' %in cace of direction = 'struc'
                        
                        if model.S(metID,RxnsID(q))~=0 %if the reaction in the S matrix has nonzero coefficient, add to involved reactions
                            
                           if strcmp(involvedRxns{1},'No rxns')
                              involvedRxns{1,1}=Rxns{q};            
                           else
                              involvedRxns{length(involvedRxns)+1,1}=Rxns{q};
                           end
                           
                        end
                        
                end
                
            end

            if ~strcmp(involvedRxns{1},'No rxns') %if the list of involved reactions is not empty
                
                for q=1:radius-1 %cycle through the radius-1
                    involvedRxns=findNearRxns(model,involvedRxns,direction,flux);
                end  

                [involvedMets,deadEnds,deadRxns]=draw_by_rxn(model,involvedRxns,drawMap,direction,metAbbr,excludeMets,flux,save,closev); %call out the command draw_by_rxn with obtained arguments
                
            else %if the list of involved reactions is empty
                
                switch direction %check the value of the variable direction
                    
                    case 'sub' %in cace of direction = 'sub'                    
                        disp(['According to given fluxes no substrates were found for metabolite ',metAbbr{1}])                    
                    case 'prod' %in cace of direction = 'prod'                    
                        disp(['According to given fluxes no products were found for metabolite ',metAbbr{1}])
                    case 'both' %in cace of direction = 'both'
                        disp(['According to given fluxes no substrates and products were found for metabolite ',metAbbr{1}])                
                end            
                
                %declare variables
                deadEnds='No dead ends';
                involvedRxns='No rxns';
                involvedMets='No mets';
                
            end          

        else %if the initial metabolite is not present in the model
            
            disp(strcat(metAbbr,' is not present in the model'))
            deadEnds='No dead ends';
            involvedRxns='No rxns';
            involvedMets='No mets';
            
        end
        
    else %if flux vector is empty
        
        disp('The flux vector is empty')
        deadEnds='No dead ends';
        involvedRxns='No rxns';
        involvedMets='No mets';
        
    end
    
else %if radius is not > 0
    
    disp('The value of the argument RADIUS must be a natural number, for example, 1,2,3...n')
    deadEnds='No dead ends';
    involvedRxns='No rxns';
    involvedMets='No mets';
    
end    
