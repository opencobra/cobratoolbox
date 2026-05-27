function [involvedMets, deadEnds, deadRxns] = draw_by_rxn(model, rxns, drawMap, direction, initialMet, excludeMets, flux, save, closev, reportDeadEnds)
% Defines the visualisation scope from a list of reactions.
%
% USAGE:
%
%    [involvedMets, deadEnds, deadRxns] = draw_by_rxn(model, rxns, drawMap, direction, initialMet, excludeMets, flux, save, closev, reportDeadEnds)
%
% INPUTS:
%    model:            COBRA model structure.
%    rxns:             Cell array of reaction abbreviations in the COBRA model,
%                      or a cell vector from the MATLAB workspace.
%
% OPTIONAL INPUTS:
%    drawMap:          Boolean indicating whether to visualise the COBRA model.
%                      Set this to `false` to avoid rendering large maps and
%                      return results faster.
%
%                      Default: false
%
%    direction:        Direction used by the algorithm. Allowed values are:
%
%                      * 'struc' - Visualise all metabolites connected to the
%                        specified reactions, without considering steady-state
%                        fluxes. This represents the structure of the COBRA model.
%
%                      * 'sub' - Visualise only metabolites acting as substrates
%                        for the specified reactions. Reaction direction is
%                        inferred from the stoichiometric matrix and
%                        steady-state fluxes.
%
%                      * 'prod' - Visualise only metabolites acting as products
%                        for the specified reactions. Reaction direction is
%                        inferred from the stoichiometric matrix and
%                        steady-state fluxes.
%
%                      * 'both' - Visualise both substrates and products for the
%                        specified reactions. Reaction direction is inferred from
%                        the stoichiometric matrix and steady-state fluxes.
%
%                      Default: 'struc'
%
%    initialMet:       Cell array containing the abbreviation of the initial
%                      metabolite in the COBRA model. This metabolite is shown
%                      as a green circle on the map. This option supports
%                      `draw_by_met`, which calls `draw_by_rxn` and passes
%                      `initialMet`.
%
%                      Default: empty
%
%    excludeMets:      Cell array of metabolite abbreviations to exclude from the
%                      visualisation map, for example:
%
%                         {'Met_Abbr_1', 'Met_Abbr_2', ..., 'Met_Abbr_n'}
%
%                      This option is useful for excluding highly connected
%                      metabolites such as `h`, `h2o`, `atp`, `adp`, and `nad`,
%                      to reduce visual clutter.
%
%                      Default: empty
%
%    flux:             `nRxns x 1` vector of reaction fluxes, where `nRxns` is
%                      the number of reactions in the model. Fluxes are usually
%                      obtained with `optimizeCbModel`. Flux values smaller than
%                      `-1e-9 mmol gDW^-1 h^-1` or greater than
%                      `1e-9 mmol gDW^-1 h^-1` are treated as non-zero.
%
%                      Default: vector of zeros.
%
%    save:             Boolean indicating whether to save the visualisation
%                      automatically as a JPEG file. This is useful for iterative
%                      calls with different visualisation scopes.
%
%                      Default: false
%
%    closev:           Boolean indicating whether to close the biograph viewer
%                      window after visualisation. This is useful for iterative
%                      calls with different visualisation scopes.
%
%                      Default: false
%
%    reportDeadEnds:   Boolean indicating whether to report dead-end metabolites
%                      and dead reactions in the specified visualisation scope.
%
% OUTPUTS:
%    involvedMets:     Cell array containing the metabolites involved in the
%                      specified reactions.
%    deadEnds:         Cell array containing the dead-end metabolites in the
%                      specified reactions.
%    deadRxns:         Cell array containing the dead reactions in the specified
%                      visualisation scope.
%
% NOTE:
%    This function is part of Paint4Net. It defines a metabolite visualisation
%    scope from a reaction list and supports `draw_by_met`.
%
% .. Author:
%       - Andrejs Kostromins, 3 Oct 2012, andrejs.kostromins@gmail.com
%

% Initialize output variables with default values
involvedMets = {};
deadEnds = {};
deadRxns = {};


if nargin<7 %if the number of arguments < 7, use default flux vector of zeros
    flux = zeros(length(model.rxns), 1); % Default to zero flux
 end

  if nargin<8 %if the number of arguments < 8, save=false
        save=false;
  end
    if nargin<9
        closev=false; %if the number of arguments < 9, closev=false
    end
if  nargin<10
    reportDeadEnds = 0; % no deadends are returns
    deadEnds = {};
    deadRxns = {};
end

if ~isempty(flux) && isnumeric(flux) %if flux vector is not empty and contains numeric values
    Start_time2=clock;
    Start_time=clock;
         
    %print start time for task
    Start_time=strcat(num2str(Start_time(1)),'_',num2str(Start_time(2)),'_',num2str(Start_time(3)),'_',num2str(Start_time(4)),'_',num2str(Start_time(5)),'_',num2str(Start_time(6)))
   
    if nargin<3 %if the number of arguments < 3, drawMap=false
        drawMap=false;
    end  

    if nargin<4 %if the number of arguments < 4, direction='struc'
        direction='struc';
    end

    if nargin<5 %if the number of arguments < 5, initialMet{1}=''
        initialMet{1}='';
    end
    
    if nargin<6 %if the number of arguments < 6, excludeMets{1}=''
        excludeMets{1}='';
    end

    %declares variables
    not_present_rxns{1}='0';
    rxns_index=1;

    for i=1:length(rxns) %cycle through the list of reactions
        
        exist=false;
        
        for j=1:length(model.rxns) %cycle through the reactions in the model
            
            if strcmp(model.rxns{j},rxns{i}) %if particular reaction exists in the model
               j=length(model.rxns); 
               exist=true;
            end

            if j==length(model.rxns) && exist~=true % if partucular reaction does not exist in the model, add to the list of not present reactions
               not_present_rxns{rxns_index}=rxns{i};
               rxns_index=rxns_index+1;
            end
            
        end
        
    end

    if not_present_rxns{1}=='0'; %if all reactions were present in the model 

        RxIDs=findRxnIDs(model,rxns); %find reaction IDs in the model
        
        %declare variables
        involvedMets={};
        mets_index=1;    

        for y=1:length(model.mets) %cycle through the metabolites in the model
            
            for x=1:length(RxIDs) %cycle through the reaction IDs
                
                switch direction %check the value of the variable direction
                    
                    case 'sub' %in cace of direction = 'sub'
                         
                        if model.S(y,RxIDs(x))<0 && flux(RxIDs(x))>1e-9 || model.S(y,RxIDs(x))>0 && flux(RxIDs(x))<-1e-9 %if the metabolite in the S matrix has negative coefficient, but the flux is positive or the opposite
                            
                            if ~strcmp(excludeMets{1},'') %if the list of excludable metabolites is not empty
                                
                                exclude=false;
                                
                                for v=1:length(excludeMets) %cycle through the metabolites in the list of excludable metabolites
                                    
                                    if strcmp(excludeMets{v},model.mets{y}) %if particular metabolite exists in the list of excludable metabolites
                                        exclude=true;
                                        break;
                                    end
                                    
                                end
                                
                                if exclude==false %if must not be excluded from visualization, add to the list of involved metabolites
                                    involvedMets{mets_index,1}=model.mets{y};
                                    mets_index=mets_index+1;    
                                end
                                
                            else %if the list of excludable metabolites is empty, add to the list of involved metabolites
                                
                                involvedMets{mets_index,1}=model.mets{y};
                                mets_index=mets_index+1;
                                
                            end
                            break;
                            
                        end
                        
                    case 'prod' %in cace of direction = 'prod'
                        
                        if model.S(y,RxIDs(x))>0 && flux(RxIDs(x))>1e-9 || model.S(y,RxIDs(x))<0 && flux(RxIDs(x))<-1e-9 %if the metabolite in the S matrix has positive coefficient and the flux is positive or the opposite
                            
                            if ~strcmp(excludeMets{1},'') %if the list of excludable metabolites is not empty
                                
                                exclude=false;
                                
                                for v=1:length(excludeMets) %cycle through the metabolites in the list of excludable metabolites
                                    
                                    if strcmp(excludeMets{v},model.mets{y}) %if particular metabolite exists in the list of excludable metabolites
                                        exclude=true;
                                        break;
                                    end
                                    
                                end
                                
                                if exclude==false %if must not be excluded from visualization, add to the list of involved metabolites
                                    involvedMets{mets_index,1}=model.mets{y};
                                    mets_index=mets_index+1;    
                                end
                                
                            else %if the list of excludable metabolites is empty, add to the list of involved metabolites
                                
                                involvedMets{mets_index,1}=model.mets{y};
                                mets_index=mets_index+1;
                                
                            end                
                            break;
                            
                        end
                        
                    case 'struc' %in cace of direction = 'struc'
                        
                        if model.S(y,RxIDs(x))<0 || model.S(y,RxIDs(x))>0 %if the metabolite in the S matrix has negative or possitive coefficient  
                            
                            if ~strcmp(excludeMets{1},'') %if the list of excludable metabolites is not empty
                                
                                exclude=false;
                                
                                for v=1:length(excludeMets) %cycle through the metabolites in the list of excludable metabolites
                                    
                                    if strcmp(excludeMets{v},model.mets{y}) %if particular metabolite exists in the list of excludable metabolites
                                        exclude=true;
                                        break;
                                    end
                                    
                                end
                                
                                if exclude==false %if must not be excluded from visualization, add to the list of involved metabolites
                                    involvedMets{mets_index,1}=model.mets{y};
                                    mets_index=mets_index+1;    
                                end
                                
                            else %if the list of excludable metabolites is empty, add to the list of involved metabolites
                                
                                involvedMets{mets_index,1}=model.mets{y};
                                mets_index=mets_index+1;
                                
                            end                
                            break;
                            
                        end
                    case 'both' %in cace of direction = 'both'
                        %if (the metabolite in the S matrix has negative coefficient, but the flux is positive or the opposite) or (the metabolite in the S matrix has positive coefficient and the flux is positive or the opposite)
                        if model.S(y,RxIDs(x))<0 && flux(RxIDs(x))>1e-9 || model.S(y,RxIDs(x))>0 && flux(RxIDs(x))<-1e-9 || model.S(y,RxIDs(x))>0 || model.S(y,RxIDs(x))>0 && flux(RxIDs(x))>1e-9 || model.S(y,RxIDs(x))<0 && flux(RxIDs(x))<-1e-9
                            
                            if ~strcmp(excludeMets{1},'') %if the list of excludable metabolites is not empty
                                
                                exclude=false;
                                
                                for v=1:length(excludeMets) %cycle through the metabolites in the list of excludable metabolites
                                    
                                    if strcmp(excludeMets{v},model.mets{y}) %if particular metabolite exists in the list of excludable metabolites
                                        exclude=true;
                                        break;
                                    end
                                    
                                end
                                
                                if exclude==false %if must not be excluded from visualization, add to the list of involved metabolites
                                    involvedMets{mets_index,1}=model.mets{y};
                                    mets_index=mets_index+1;    
                                end
                                
                            else %if the list of excludable metabolites is empty, add to the list of involved metabolites
                                
                                involvedMets{mets_index,1}=model.mets{y};
                                mets_index=mets_index+1;
                                
                            end                
                            break;
                            
                        end
                        
                end
                
            end
            
        end
       
        if nargin>4 && ~isempty(initialMet) && ~strcmp(initialMet{1},'') %if the number of arguments > 4 and the argument initialMet is not empty
            
            if ~ismember(initialMet{1},involvedMets) %if initialMet is not already in the list of involved metabolites, add initalMet to the list of involved metabolotes
                involvedMets{length(involvedMets)+1,1}=initialMet{1};
            end 
            
        end

        MetIDs=findMetIDs(model,involvedMets); %find metabolite IDs in the model
        for x=1:length(RxIDs) %cycle through the reaction IDs
            
            for y=1:length(MetIDs) %cycle through the metabolite IDs
                
                if model.S(MetIDs(y),RxIDs(x))==0 || model.ub(RxIDs(x))==0&&model.lb(RxIDs(x))==0%if the metabolite in the S matrix has coefficient=0 and botj bounds =0, add zeros into conectivity matrix 
                    matrix(y,x+length(MetIDs))=0;
                    matrix(x+length(MetIDs),y)=0;                    
                elseif model.S(MetIDs(y),RxIDs(x))<0 && flux(RxIDs(x))>1e-9 %if the metabolite in the S matrix has negative coefficient, but the flux is positive, add native direction entry into conectivity matrix 
                    matrix(y,x+length(MetIDs))=1;
                    matrix(x+length(MetIDs),y)=0;                    
                elseif model.S(MetIDs(y),RxIDs(x))<0 && flux(RxIDs(x))<-1e-9 %if the metabolite in the S matrix has negative coefficient and the flux is negative, add not-native direction entry into conectivity matrix
                    matrix(y,x+length(MetIDs))=0;
                    matrix(x+length(MetIDs),y)=1;                    
                elseif model.S(MetIDs(y),RxIDs(x))>0 && flux(RxIDs(x))>1e-9 %if the metabolite in the S matrix has positive coefficient and the flux is positive, add native direction entry into conectivity matrix
                    matrix(length(MetIDs)+x,y)=1;
                    matrix(y,length(MetIDs)+x)=0;                    
                elseif model.S(MetIDs(y),RxIDs(x))>0 && flux(RxIDs(x))<-1e-9 %if the metabolite in the S matrix has positive coefficient, but the flux is negative, add not-native direction entry into conectivity matrix
                    matrix(length(MetIDs)+x,y)=0;
                    matrix(y,length(MetIDs)+x)=1;                     
                elseif model.S(MetIDs(y),RxIDs(x))<0 && abs(flux(RxIDs(x))) <= 1e-9 && model.ub(RxIDs(x))>1e-9%if there is no significant flux and the metabolite in the S matrix has negative coefficient, and u.bound >0, add native direction entry into conectivity matrix
                    matrix(y,x+length(MetIDs))=1;
                    matrix(x+length(MetIDs),y)=0;
                elseif model.S(MetIDs(y),RxIDs(x))<0 && abs(flux(RxIDs(x))) <= 1e-9 && model.ub(RxIDs(x))==0&& model.lb(RxIDs(x))<-1e-9%if there is no significant flux and the metabolite in the S matrix has negative coefficient, and u.bound=0, but l.bound<0, add non-native direction entry into conectivity matrix
                    matrix(length(MetIDs)+x,y)=1;
                    matrix(y,length(MetIDs)+x)=0;
                elseif model.S(MetIDs(y),RxIDs(x))>0 && abs(flux(RxIDs(x))) <= 1e-9 && model.ub(RxIDs(x))>1e-9%if there is no significant flux and the metabolite in the S matrix has positive coefficient, and u.bound >0, add native direction entry into conectivity matrix
                    matrix(length(MetIDs)+x,y)=1;
                    matrix(y,length(MetIDs)+x)=0;  
                elseif model.S(MetIDs(y),RxIDs(x))>0 && abs(flux(RxIDs(x))) <= 1e-9 && model.ub(RxIDs(x))==0&& model.lb(RxIDs(x))<-1e-9%if there is no significant flux and the metabolite in the S matrix has positive coefficient, and u.bound=0, but l.bound<0, add non-native direction entry into conectivity matrix
                    matrix(y,x+length(MetIDs))=1;
                    matrix(x+length(MetIDs),y)=0;
                end
                
            end
            
        end

        %declare variables
        MetsNodesIDs=[1:length(MetIDs)];
        DeadMetsID(1)=-1;
        
        for v=1:length(MetsNodesIDs) %cycle through the metabolite node IDs
            
            if sum(matrix(v,:)) + sum(matrix(:,v))<2 %if the sum in the conectivity matrix < 2 (0 or 1 incoming/outgoing arrow), add to the list of dead end metabolites
                
                if DeadMetsID(1)==-1
                    DeadMetsID(1)=v;
                    deadEnds{1,1}=involvedMets{v,1};
                else
                    DeadMetsID(length(DeadMetsID)+1)=v;
                    deadEnds{length(deadEnds)+1,1}=involvedMets{v,1};
                end
                
            %if the sum in the conectivity matrix > 1 (at least 2 incoming and 0 outgoing arrows or at least 2 outgoing and 0 incoming arrows) it could be dead end metabolite  
            elseif sum(matrix(v,:)) + sum(matrix(:,v))>1 && sum(matrix(v,:))>0 && sum(matrix(:,v))==0 || sum(matrix(v,:)) + sum(matrix(:,v))>1 && sum(matrix(v,:))==0 && sum(matrix(:,v))>0
                
                DeadMet=true;            
                
                for w=length(MetsNodesIDs)+1:length(matrix) %cycle through the conectivity matrix starting from the first reaction index
                    
                    if matrix(v,w)==1 &&model.lb(RxIDs(w-length(MetsNodesIDs)))<-1e-9&&model.ub(RxIDs(w-length(MetsNodesIDs)))>1e-9 %if the coefficient in the conectivity matrix = 1 and this reaction in the model is reversible, then it is not a dead end metabolite                 
                        DeadMet=false;
                        break;
                    end
                    
                end

                if DeadMet==true
                    
                    for w=length(MetsNodesIDs)+1:length(matrix) %cycle through the conectivity matrix starting from the first reaction index
                        
                        if matrix(w,v)==1 && model.lb(RxIDs(w-length(MetsNodesIDs)))<-1e-9&&model.ub(RxIDs(w-length(MetsNodesIDs)))>1e-9  %if the coefficient in the conectivity matrix = 1 and this reaction in the model is reversible, then it is not a dead end metabolite                                
                            DeadMet=false;
                            break;
                        end
                        
                    end

                    if DeadMet==true %if still dead end, add to the list of dead end metabolites
                        
                        if DeadMetsID(1)==-1
                               DeadMetsID(1)=v;
                               deadEnds{1,1}=involvedMets{v,1};
                        else
                               DeadMetsID(length(DeadMetsID)+1)=v;
                               deadEnds{length(deadEnds)+1,1}=involvedMets{v,1};
                        end
                        
                    end
                    
                end  
                
            end
            
        end   

        if DeadMetsID(1)==-1 %if no dead ends
            deadEnds = {};
        end
        
        DeadRxnsID(1)=-1;%declare variable
        DeadRxnsID2(1)={'-1'};%declare variable
        
        %performe FVA
        if reportDeadEnds == 1
        [minFlux,maxFlux] = fluxVariability(model,100,'max',rxns);
        
        for v=1:length(minFlux)
            if minFlux(v)<1e-9&maxFlux(v)==minFlux(v)&minFlux(v)>-1e-9
                 if strcmp(DeadRxnsID2(1),'-1')
                     DeadRxnsID2(1)=rxns(v);                                          
                 else
                      DeadRxnsID2(length(DeadRxnsID2)+1)=rxns(v);                                              
                end
            end
        end     
        
        deadRxns=DeadRxnsID2';  %return list of dead reactions 
        end

        if strcmp(drawMap,'true') %if drawMap=true
            
            ids=involvedMets;

            if nargin>4 && ~isempty(initialMet) && ~strcmp(initialMet{1},''); %if the number of arguments > 4 and the argument initialMet is not empty
                
                for v=1:length(ids); %cycle through the node ids
                    
                    if strcmp(initialMet,ids{v});
                        initialMetID=v; %get the initial met ID
                    end
                    
                end
                
            end

            for v=1:length(RxIDs); %cycle through the reaction ids
                ids{length(ids)+1}=strcat(model.rxns{RxIDs(v)},' (',num2str(flux(RxIDs(v))),')'); %node id=reaction abbr+flux rate
                flux_rate{length(ids)+1} = (flux(RxIDs(v)));
                RxnsNodesIDs(v)=length(ids); %get all reaction nodes IDs
            end

            ids=ids';      

            % Convert adjacency matrix to digraph
            G = digraph(matrix);

            % Set default node names
            nodeNames = ids; % Default node names from ids
            G.Nodes.Name = nodeNames(:);
            
            % Initialize compact NodeLabel with default IDs (similar to original biograph)
            for i = 1:length(ids)
                G.Nodes.NodeLabel{i} = ids{i};
            end

            % Customize nodes based on involvedMets - use shorter labels
            for m = 1:length(involvedMets)
                for n = 1:length(model.mets)
                    if strcmp(involvedMets{m}, model.mets{n})
                        try
                            if isfield(model, 'metNames') && length(model.metNames) >= n && ~isempty(model.metNames{n})
                                % Use just the metabolite name, not "Name: ..."
                                metName = model.mets{n};
                                metNameLong = model.metNames{n};
                                metFormula = model.metFormulas{n};
                                if length(metName) > 15  % Truncate long names
                                    metName = [metName(1:12) '...'];
                                end
                                G.Nodes.Name{m} = ['Metabolite Names: ' , metNameLong, ' Formula: ', metFormula];
                                G.Nodes.NodeLabel{m} = metName;
                            end
                        catch
                            % Keep default label if error occurs
                        end
                        try
                            if isfield(model, 'metFormulas') && length(model.metFormulas) >= n && ~isempty(model.metFormulas{n})
                                G.Nodes.Description{m} = strcat('Charged formula: ', newline, model.metFormulas{n});
                            end
                        catch
                            % Handle errors silently
                        end
                    end
                end
            end

            % Customize reaction nodes - use shorter labels
            for m = 1:length(RxIDs)
                for n = 1:length(model.rxns)
                    if strcmp(model.rxns{RxIDs(m)}, model.rxns{n})
                        try
                            if isfield(model, 'rxnNames') && length(model.rxnNames) >= n && ~isempty(model.rxnNames{n});
                                % Use just the reaction name, not "Name: ..."
                                rxnName = model.rxns{n};
                                rxnNameLong = model.rxnNames{n};
                                RxnFormula = printRxnFormula(model,model.rxns{n});
                                if length(rxnName) > 15  % Truncate long names
                                    rxnName = [rxnName(1:12) '...'];
                                end
                                G.Nodes.Name{length(involvedMets) + m} = ['Reaction: ', rxnNameLong];
                                G.Nodes.NodeLabel{length(involvedMets) + m} = [rxnName, disp(flux(m))];
                            end
                        catch
                            % Keep default label if error occurs
                        end
                        try
                            strtmp = printRxnFormula(model, model.rxns{RxIDs(m)}, false);
                            G.Nodes.Description{length(involvedMets) + m} = ...
                                strcat('Reaction: ', strtmp{1}, ' lb=', num2str(model.lb(RxIDs(m))), ' ub=', num2str(model.ub(RxIDs(m))));
                        catch
                            % Handle errors silently
                        end
                    end
                end
            end

            % Visualize the graph with custom labels and smaller font
            h = plot(G, 'Layout', 'layered', 'NodeLabel', G.Nodes.NodeLabel, 'NodeFontSize', 8); % Use smaller font size
            h.EdgeColor = [0.5, 0.5, 0.5]; % Default edge color

            % Adjust edge properties based on flux
            max_flux = max(abs(flux));
            if max_flux == 0
               %max_flux = 1; % Avoid division by zero
            end
            % for 
            %     q = 1:length(RxIDs)
            %     ids{length(ids)+1}=strcat(model.rxns{RxIDs(q)},' (',num2str(flux(RxIDs(q))),')'); %node id=reaction abbr+flux rate
            %     flux_rate{length(ids)+1} = (flux(RxIDs(q)))
                
                % disp('THIS IS q = 1:length(RxIDs)');
                % disp(q);
            for p = length(MetsNodesIDs) + 1:length(ids);
                [oeid,onid] = outedges(G, p);
                [ieid,inid] = inedges(G, p);
                eid = [oeid;ieid];
                flux_value = flux(RxIDs(p - length(MetsNodesIDs)));
                if flux_value > 1e-9;
                    % Positive flux: Green edges
                    highlight(h, 'Edges', eid, 'LineWidth', abs(7 * (flux_value / max_flux)), 'EdgeColor', 'green', 'EdgeLabelColor', 'green' , 'ArrowSize', 17)%, ArrowPosition=0.5);
                elseif flux_value < -1e-9;
                    % Negative flux: Blue edges
                    highlight(h, 'Edges', eid, 'LineWidth', abs(7 * (flux_value / max_flux)), 'EdgeColor', 'blue', 'EdgeLabelColor', 'blue' , 'ArrowSize', 17)%, ArrowPosition=0.5);
                end
            end
            % Highlight specific nodes (reactions, metabolites, etc.)
            highlight(h, RxnsNodesIDs, 'Marker', 'square', 'NodeColor', [241/255, 176/255, 102/255]); % Reaction nodes AS STARTS W/ 'Marker', 'hexagram',
            highlight(h, MetsNodesIDs, 'Marker', 'o', 'NodeColor', [0.8, 0.8, 1.0]); % Metabolite nodes - light blue
            disp('Metabolite nodes - light blue: Reaction nodes - Orange')
            
            % Adjust node sizes to be more manageable
            h.MarkerSize = 8; % Smaller nodes
            h.NodeFontSize = 8; % Smaller font
            h.NodeFontAngle = "italic"
            
            % Add highlighting for dead ends and special metabolites
            if DeadMetsID(1) ~= -1
                highlight(h, DeadMetsID, 'NodeColor', [1, 0, 0]); % Red for dead ends
            end
            
            % Highlight initial metabolite if specified
            if nargin > 4 && ~isempty(initialMet) && ~strcmp(initialMet{1}, '') %&& exist('initialMetID', 'var') <-Removed this, was causing errors
                highlight(h, initialMetID, 'NodeColor', '#47a81d')%, MarkerSize==10); % Green for initial metabolite
            end

            % Save graph visualization if needed
            if strcmp(save, 'true')
                saveas(gcf, strcat('graph_', datestr(now, 'yyyymmdd_HHMMSS'), '.jpg'));
            end

            % Close visualization if specified
            if strcmp(closev, 'true')
                close(gcf);
            end
        end

    else %if in the input list was at least one unexisting reaction in the model
        
        disp('The following reactions are not present in the model:')
        not_present_rxns(~strcmp(not_present_rxns, '0'))
        involvedMets = {};
        deadEnds = {};
        deadRxns = {};
        
    end
    
else %if flux vector is empty or contains non-numeric values
    
    disp('The flux vector is empty or contains non-numeric values')
    involvedMets = {};
    deadEnds = {};
    deadRxns = {};
        
end
end
