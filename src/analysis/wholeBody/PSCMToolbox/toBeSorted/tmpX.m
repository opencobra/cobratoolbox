clear Table_csources
for i =13%1 :length(O)
    if ~strcmp('gender',O{i})
        model = OrganCompendium.(O{i}).modelAllComp;
        model.lb(find(model.lb<0))=-1000;
        model.ub(find(model.ub<0))=0;
        model.ub(find(model.ub>0))=1000;
        model.lb(find(model.lb>0))=0;
        
        resultsFileName = strcat(gender,O{i});
        if strcmp('Brain',O{i}) || strcmp('Scord',O{i})
            extraCellCompIn = '[csf]';
            extraCellCompOut = '[csf]';
        elseif ~isempty(find(~cellfun(@isempty,strfind(model.rxns,'[bp]')))) && ~strcmp('Liver',O{i})
            extraCellCompIn = '[bc]';
            % the out compartment does not matter as all out are anyway open
            extraCellCompOut = '[bp]';
        elseif ~isempty(find(~cellfun(@isempty,strfind(model.rxns,'[bd]')))) && ~strcmp('Liver',O{i})
            extraCellCompIn = '[bc]';
            % the out compartment does not matter as all out are anyway open
            extraCellCompOut = '[bd]';
        else
            extraCellCompIn = '[bc]';
            % the out compartment does not matter as all out are anyway open
            extraCellCompOut = '[bc]';
        end
        %NOTE I have to test also Liver with bp input
        
        % revert the direction of sinks
        SI = strmatch('sink_',model.rxns);
        for k = 1 : length(SI)
            if ~isempty(find(model.S(:,SI(k))==1))% positive entry
                % flip it
                model.S(find(model.S(:,SI(k))==1),SI(k)) = -1;
                model.lb(SI(k)) = min(model.lb(SI(k)),model.ub(SI(k)));
                model.lb(SI(k)) = max(model.lb(SI(k)),model.ub(SI(k)));
            end
        end
        % revert the direction of sinks
        SI = strmatch('DM_',model.rxns);
        for k = 1 : length(SI)
            if ~isempty(find(model.S(:,SI(k))==1)) && length(find(model.S(:,SI(k))==1))==1% positive entry
                % flip it
                model.S(find(model.S(:,SI(k))==1),SI(k)) = -1;
                model.lb(SI(k)) = 0%min(model.lb(SI(k)),model.ub(SI(k)));
                model.lb(SI(k)) = max(model.lb(SI(k)),model.ub(SI(k)));
            end
        end
        
        modelClosed = model;
        % prepare models for test - these changes are needed for the different
        % recon versions to match the rxn abbr definitions in this script
        modelClosed.rxns = regexprep(modelClosed.rxns,'\(','\[');
        modelClosed.rxns = regexprep(modelClosed.rxns,'\)','\]');
        modelClosed.mets = regexprep(modelClosed.mets,'\(','\[');
        modelClosed.mets = regexprep(modelClosed.mets,'\)','\]');
        modelClosed.rxns = regexprep(modelClosed.rxns,'ATPS4mi','ATPS4m');
        
        % replace older abbreviation of glucose exchange reaction with the one used
        % in this script
        if length(strmatch(strcat('EX_glc',extraCellCompIn),modelClosed.rxns))>0
            modelClosed.rxns{find(ismember(modelClosed.rxns,strcat('EX_glc',extraCellCompIn)))} = strcat('EX_glc_D',extraCellCompIn);
        end
        if length(strmatch(strcat('EX_glc',extraCellCompOut),modelClosed.rxns))>0
            modelClosed.rxns{find(ismember(modelClosed.rxns,strcat('EX_glc',extraCellCompOut)))} = strcat('EX_glc_D',extraCellCompOut);
        end
        
        % add reaction if it does not exist
        [modelClosed, rxnIDexists] = addReaction(modelClosed,'DM_atp_c_',  'h2o[c] + atp[c] -> adp[c] + h[c] + pi[c] ');
        if length(rxnIDexists)>0
            modelClosed.rxns{rxnIDexists} = 'DM_atp_c_'; % rename reaction in case that it exists already
        end
         modelexchanges1 = strmatch('Ex_',modelClosed.rxns);
            modelexchanges4 = strmatch('EX_',modelClosed.rxns);
            modelexchanges2 = strmatch('DM_',modelClosed.rxns);
            modelexchanges3 = strmatch('sink_',modelClosed.rxns);
            % also close biomass reactions
            BM= (find(~cellfun(@isempty,strfind(lower(modelClosed.mets),'bioma'))));
            
            selExc = (find( full((sum(abs(modelClosed.S)==1,1) ==1) & (sum(modelClosed.S~=0) == 1))))';
            
            modelexchanges = unique([modelexchanges1;modelexchanges2;modelexchanges3;modelexchanges4;selExc;BM]);
            modelClosed.lb(find(ismember(modelClosed.rxns,modelClosed.rxns(modelexchanges))))=0;
            modelClosed.c = zeros(length(modelClosed.rxns),1);
            modelClosed = changeObjective(modelClosed,'DM_atp_c_');
            modelClosed.ub(selExc)=1000;
            
            TestedRxns = [];
         
            
                modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_o2[bc]')))) = -1000;
                modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_h2o[bc]')))) = -1000;
                modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_h2o[bc]')))) = 1000;
                modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_h2o[bd]')))) = 0;
                modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_h2o[bd]')))) = 1000;
                modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_h2o[bp]')))) = -1000;
                modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_h2o[bp]')))) = 1000;
                modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_co2[bc]')))) = 1000;
                modelClosed.lb(find(ismember(modelClosed.rxns,strcat('EX_glc_D[bp]')))) = -1;
                modelClosed.ub(find(ismember(modelClosed.rxns,strcat('EX_glc_D[bp]')))) = -1;
             FBA = optimizeCbModel(modelClosed,'max','zero')
        O{i}
        
    end
end