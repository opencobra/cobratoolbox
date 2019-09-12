function model = convertOldCouplingFormat(model)
%Converts an old style model implementation of coupling constraints to a
%new style
%
% INPUT
% model     model with model.A but without model.d   
%
% OUTPUT
%    model:     A COBRA model structure with the following fields
%
%                * `.S` - The stoichiometric matrix
%                * `.c` - Objective coeff vector
%                * `.lb` - Lower bound vector
%                * `.ub` - Upper bound vector              
%                  * `.b`: accumulation/depletion vector (default 0 for each metabolite).
%                  * `.C`: the Constraint matrix;
%                  * `.d`: the right hand side vector for C;
%                  * `.dsense`: the constraint sense vector;

if isfield(model,'A') && isfield(model,'S')
%     if printLevel >=1
%         warning('The inserted Model contains an old style coupling matrix (A). The MAtrix will be converted into a Coupling Matrix (C) and fields will be adapted.')
%     end
    [nMets,nRxns] = size(model.S);
    if size(model.S,1) == size(model.A,1)
        bool=strncmp('slack_',model.mets,length('slack_'));
        if any(bool)
            %this is a draft harvey or harvetta
            nMetNames = length(model.metNames);
            if nMets~=nMetNames
                model.metNames=cell(nnz(~bool),1);
            end
            
            nMetFormulas = length(model.metFormulas);
            if nMets~=nMetFormulas
                model.metFormulas=cell(nnz(~bool),1);
            end
            
            nMetCharges = length(model.metCharge);
            if nMets~=nMetCharges
                model.metCharges=ones(nnz(~bool),1)*NaN;
            end
            model=rmfield(model,'metCharge');
            %         %metCharges is an empty character array but needs to be a numeric vector
            %         model.metCharges=ones(size(model.mets,1),1)*NaN;
            
            mets=model.mets(~bool);
            ctrs=model.mets(bool);
            
            S=model.A(~bool,:);
            csense=columnVector(model.csense(~bool));
            b=columnVector(model.b(~bool));
            C=model.A(bool,:);
            dsense=columnVector(model.csense(bool));
            d=columnVector(model.b(bool));
                
            %replace some fields
            model.rxnNotes=cell(nRxns,1);
            model.rxnECNumbers=cell(nRxns,1);
            model.rxnReferences=cell(nRxns,1);
            model=rmfield(model,'rules');
            model.rxnNames=cell(nRxns,1);
            
            model.rxnECNumbers = columnVector(model.rxnECNumbers);
            model.grRulesNotes = columnVector(model.grRulesNotes);
            model.rxnECNumbers = columnVector(model.rxnECNumbers);
            model.rxnReferences = columnVector(model.rxnReferences);
            
            %grRule{x} needs to be a character array, but some grRules{x} are cells
            bool=cellfun(@(y) ischar(y) , model.grRules);
            for i=1:length(bool)
                if ~bool(i)
                    %replace cell with contents of cell
                    tmp=model.grRules{i};
                    model.grRules{i}=tmp{1};
                end
            end
            bool=cellfun(@(y) ischar(y) , model.grRules);
            if ~any(bool)
                error('convertOldCouplingFormat: model.grRules format still wrong')
            end
            
            %add any missing model.genes that were present in model.grRules
            %uses code from generateRules.m
            [~,genes] = preparseGPR(model.grRules);  % preparse all model.grRules
            allGenes =  unique([genes{~cellfun(@isempty,genes)}]); %Get the unique gene list
            if (~isfield(model, 'genes'))
                newGenes = allGenes;
            else
                %         C = setdiff(A,B) for vectors A and B, returns the values in A that
                %         are not in B with no repetitions. C will be sorted.
                newGenes = setdiff(allGenes,model.genes);
            end
            if ~isempty(newGenes)
                model = addGenes(model,newGenes);
            end
                       
        else
            error('not clear what type of old model this is')
        end
    else
        % get the Constraint data
        C = model.A(nMets+1:end,:);
        ctrs = columnVector(model.mets(nMets+1:end));
        if isempty(ctrs)
            ctrs=cell(size(model.A,1)-size(model.S,1),1);
        end
        dsense =  columnVector(model.csense(nMets+1:end));
        d = columnVector(model.b(nMets+1:end));
        
        % now, we assume, that those are the only modified fields, if not,
        % something is seriously broken.
        mets = columnVector(model.mets(1:nMets));
        b = columnVector(model.b(1:nMets));
        csense = columnVector(model.csense(1:nMets));
    end


    % set the constraint data
    model.S = S;
    model.mets = mets;
    model.csense = csense;
    model.b = b;
    
    model.C = C;
    model.ctrs = ctrs;
    model.dsense = dsense;
    model.d = d;
    
    %remove model.A
    model = rmfield(model,'A');
end

model = orderfields(model);

