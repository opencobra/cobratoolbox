function [involvedRxns, involvedMets, deadEnds, deadRxns] = draw_by_met(model, metAbbr, drawMap, radius, direction, excludeMets, flux, save, closev)
% Defines the visualisation scope from a starting metabolite.
%
% USAGE:
%
%    [involvedRxns, involvedMets, deadEnds, deadRxns] = draw_by_met(model, metAbbr, drawMap, radius, direction, excludeMets, flux, save, closev)
%
% INPUTS:
%    model:           COBRA model structure.
%    metAbbr:         Cell array containing the abbreviation of a metabolite in
%                     the COBRA model. This metabolite is used as the starting
%                     point for visualisation.
%
% OPTIONAL INPUTS:
%    drawMap:         Logical indicating whether to visualise the COBRA model.
%                     Set this to `false` to avoid rendering large maps and
%                     return results faster.
%
%                     Default: false
%
%    radius:          Positive integer defining the search depth from `metAbbr`.
%                     This option is used with `direction` to expand the
%                     analysis step by step from the starting metabolite.
%
%                     For example, to inspect substrates of ethanol, start with
%                     `radius = 1`, then increase the radius to include the next
%                     reaction layers.
%
%    direction:       Direction used by the algorithm. Allowed values are:
%
%                     * 'struc' - Visualise all metabolites connected to the
%                       specified reactions, without considering steady-state
%                       fluxes. This represents the structure of the COBRA model.
%
%                     * 'sub' - Visualise only metabolites acting as substrates
%                       for the specified reactions. Reaction direction is
%                       inferred from the stoichiometric matrix and
%                       steady-state fluxes.
%
%                     * 'prod' - Visualise only metabolites acting as products
%                       for the specified reactions. Reaction direction is
%                       inferred from the stoichiometric matrix and
%                       steady-state fluxes.
%
%                     * 'both' - Visualise both substrates and products for the
%                       specified reactions. Reaction direction is inferred from
%                       the stoichiometric matrix and steady-state fluxes.
%
%                     Default: 'struc'
%
%    excludeMets:     Cell array of metabolite abbreviations to exclude from the
%                     visualisation map, for example:
%
%                        {'Met_Abbr_1', 'Met_Abbr_2', ..., 'Met_Abbr_n'}
%
%                     This option is useful for excluding highly connected
%                     metabolites such as `h`, `h2o`, `atp`, `adp`, and `nad`,
%                     to reduce visual clutter.
%
%                     Default: empty
%
%    flux:            `nRxns x 1` vector of reaction fluxes, where `nRxns` is
%                     the number of reactions in the model. Fluxes are usually
%                     obtained with `optimizeCbModel`. Flux values smaller than
%                     `-1e-9 mmol gDW^-1 h^-1` or greater than
%                     `1e-9 mmol gDW^-1 h^-1` are treated as non-zero.
%
%                     Default: vector of zeros.
%
%    save:            Boolean indicating whether to save the visualisation
%                     automatically as a JPEG file. This is useful for iterative
%                     calls with different visualisation scopes.
%
%                     Default: false
%
%    closev:          Boolean indicating whether to close the biograph viewer
%                     window after visualisation. This is useful for iterative
%                     calls with different visualisation scopes.
%
%                     Default: false
%
% OUTPUTS:
%    involvedRxns:    Cell array containing the reactions involved according to
%                     the input arguments.
%    involvedMets:    Cell array containing the metabolites involved in the
%                     specified reactions.
%    deadEnds:        Cell array containing the dead-end metabolites in the
%                     specified reactions.
%    deadRxns:        Cell array containing the dead reactions in the specified
%                     visualisation scope.
%
% NOTE:
%    This function is part of Paint4Net. It defines a reaction and metabolite
%    visualisation scope around a starting metabolite.
%
% .. Author:
%       - Andrejs Kostromins, 4 Oct 2012, andrejs.kostromins@gmail.com
%

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
