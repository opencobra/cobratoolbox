function [model,oxGapfillRxns,anaerGrowthOK] = anaerobicGrowthGapfill(model, biomassReaction, database)
% Tests if the input microbe model can grow anaerobically and gap-fills
% by adding anaerobic co-factor utilizing reactions.
%
% USAGE
%       [model,oxGapfillRxns,anaerGrowthOK] = anaerobicGrowthGapfill(model, biomassReaction, database)
%
% INPUT
% model             COBRA model structure
% biomassReaction   Biomass reaction abbreviation
% database          rBioNet reaction database containing min. 3 columns:
%                   Column 1: reaction abbreviation, Column 2: reaction
%                   name, Column 3: reaction formula.
%
% OUTPUT
% model             COBRA model structure
%
% .. Authors:
% Almut Heinken and Stefania Magnusdottir, 2016-2019

tol = 1e-6;
model_old=model;

anaerGrowthOK=1;
% Test if model can grow anaerobically
model = changeRxnBounds(model, 'EX_o2(e)', 0, 'l');

% block internal O2-utilizing cytosolic reactions
if any(ismember(model.mets, 'o2[c]'))
    o2rxns = find(any(model.S(ismember(model.mets, 'o2[c]'), :), 1));
    model = changeRxnBounds(model, model.rxns(o2rxns), 0, 'b');
end

% check anaerobic growth
model = changeObjective(model, biomassReaction);
FBA = optimizeCbModel(model, 'max');
if FBA.f < tol

    % List oxygen-utilizing reactions and their anaerobic cofactor-utilizing
    % partner reaction
    anaerobicRxns = {
        'PDX5PO', {'PDX5PO2'}
        'ASPO6', {'ASPO5','EX_succ(e)','SUCCt'}
        'DHORDi', {'DHORDfum','EX_succ(e)','SUCCt'}
        'CPPPGO', {'CPPPGO2','5DOAN','DM_5DRIB'}
        'AHMMPS', {'AMPMS2'}
        'UNKENZ',{'ACCOAC'}
        };
    
    % add anaerobic reactions to model (if contains O2-using reaction)
    for i = 1:length(anaerobicRxns)
        if any(ismember(model.rxns, anaerobicRxns{i, 1}))
            for j=1:length(anaerobicRxns{i, 2})
            formula = database.reactions{ismember(database.reactions(:, 1), anaerobicRxns{i, 2}{j}), 3};
            model = addReaction(model, anaerobicRxns{i, 2}{j}, 'reactionFormula', formula);
            end
        end
    end
    
    % reactions for anaerobic quinone synthesis
    anaerobicQuinone = {
        'OMMBLHX3'
        'DMQMT'
        'OMPHHX3'
        'OPHHX3'
        'OMBZLM'
        };
    
    % add anaerobic reactions for quinone synthesis if contains aerobic
    % versions
    if any(ismember(model.rxns, {'2OMMBOX', 'OMPHHX'}))
        for i = 1:length(anaerobicQuinone)
            formula = database.reactions{ismember(database.reactions(:, 1), anaerobicQuinone{i}), 3};
            model = addReaction(model, anaerobicQuinone{i}, 'reactionFormula', formula, 'geneRule', 'AnaerobicGapfill');
        end
    end
    
    % test if can grow now
    FBA = optimizeCbModel(model, 'max');
    if FBA.f < tol

        % List possible fixes if model contains reaction in column 1
        testFix = {
            'PHE4MO', {'EX_tyr_L(e)', 'TYRt2r'}  % very unlikely tyrosine synthesis reaction
            'H2SO', {'EX_so4(e)', 'SO4t2'}  % sulfate requirement-add a transporter instead
            'r0389', {'EX_pydx(e)', 'PYDXabc'}  % could be replaced by reaction 1.1.1.65 but only found in few bacteria
            'ASPT', {'EX_asp_L(e)', 'ASPt2r'}  % need aspartate to produce fumarate
            'QUILSYN', {'EX_nac(e)', 'NACt2r', 'NAPRT'}  % can only produce NAD aerobically
            'PYAM5POr', {'EX_pydx(e)', 'PYDXabc'}  % some can only produce PYDX5P aerobically
            'PYAM5POr', {'EX_pydxn(e)', 'PYDXNabc', 'PDX5PO2'}  % some can only produce PYDX5P aerobically
            };
        for i = 1:size(testFix, 1)
            if any(ismember(model.rxns, testFix{i, 1}))
                modelTest = model;
                newRxns = testFix{i, 2};
                for j = 1:length(newRxns)
                    % add reactions
                    formula = database.reactions{ismember(database.reactions(:, 1), newRxns{j}), 3};
                    modelTest = addReaction(modelTest, newRxns{j}, 'reactionFormula', formula, 'geneRule', 'AnaerobicGapfill');
                end
                % test growth
                FBA = optimizeCbModel(modelTest, 'max');
                if FBA.f > tol
                    model = modelTest;
                    break
                end
            end
        end
    end
    
    % List possible fixes if model does NOT contain reaction in column 1
    testFix = {
        'EX_sheme(e)', {'EX_sheme(e)', 'SHEMEabc'}  % if it is due to inability to synthesize heme
        'EX_pheme(e)', {'EX_pheme(e)', 'HEMEti'}  % if it is due to inability to synthesize heme
        'EX_ser_L(e)', {'EX_ser_L(e)', 'SERt2r'}  % if due to deleting the Kegg gapfilled reaction R03472, which used to synthesize serine from glycolaldehyde (makes no sense), fill in serine transporter
        };
    for i = 1:size(testFix, 1)
        modelTest = model;
        newRxns = testFix{i, 2};
        for j = 1:length(newRxns)
            % add reactions
            formula = database.reactions{ismember(database.reactions(:, 1), newRxns{j}), 3};
            modelTest = addReaction(modelTest, newRxns{j}, 'reactionFormula', formula, 'geneRule', 'AnaerobicGapfill');
        end
        % test growth
        FBA = optimizeCbModel(modelTest, 'max');
        if FBA.f >= tol
            model = modelTest;
        end
    end
    
    % make sure quinones can be regenerated from quinols
    if any(ismember(model.rxns, 'AMMQT8'))
        modelTest = model;
        formula = database.reactions{ismember(database.reactions(:, 1), 'AMMQLT8'), 3};
        modelTest = addReaction(modelTest, 'AMMQLT8', 'reactionFormula', formula, 'geneRule', 'AnaerobicGapfill');
        % test growth
        FBA = optimizeCbModel(modelTest, 'max');
        if FBA.f >= tol
            model = modelTest;
        end
    end
    
    % Try adding fumarate reductase reactions
    rxns={
        'FRD2'
        'FRD3'
        'FRD7'
        };
    modelTest=model;
    for i=1:length(rxns)
        if isempty(find(ismember(model.rxns, rxns{i})))
            modelTest = addReaction(modelTest, rxns{i}, 'reactionFormula', database.reactions{find(ismember(database.reactions(:, 1), rxns{i})), 3}, 'geneRule', 'AnaerobicGapfill');
        end
    end
    % test growth
    FBA = optimizeCbModel(modelTest, 'max');
    if FBA.f >= tol
        model = modelTest;
    end
    
    % some models can't consume 5-Methylthio-D-ribose
    if any(ismember(model.rxns, 'DKMPPD2'))
        formula = database.reactions{ismember(database.reactions(:, 1), 'DM_5MTR'), 3};
        model = addReaction(model, 'DM_5MTR', 'reactionFormula', formula, 'geneRule', 'AnaerobicGapfill');
    end
    
    % some models need oxygen to produce 3-methyl-2-oxopentanoate
    if any(ismember(model.rxns, 'ILEDA')) && ~any(ismember(model.rxns, 'ILETA'))
        rxns={
            'EX_3mop(e)'
            '3MOPt2r'
            };
        modelTest=model;
        for i=1:length(rxns)
            if isempty(find(ismember(model.rxns, rxns{i})))
                modelTest = addReaction(modelTest, rxns{i}, 'reactionFormula', database.reactions{find(ismember(database.reactions(:, 1), rxns{i})), 3}, 'geneRule', 'AnaerobicGapfill');
            end
        end
        % test growth
        FBA = optimizeCbModel(modelTest, 'max');
        if FBA.f >= tol
            model = modelTest;
        end
    end
    
    
    % some cases: demand reaction in thiamin biosynthesis pathway fixes it
    if any(ismember(model.rxns, 'THZPSN'))
        rxns={
            'DM_4HBA'
            };
        modelTest=model;
        for i=1:length(rxns)
            if isempty(find(ismember(model.rxns, rxns{i})))
                modelTest = addReaction(modelTest, rxns{i}, 'reactionFormula', database.reactions{find(ismember(database.reactions(:, 1), rxns{i})), 3}, 'geneRule', 'AnaerobicGapfill');
            end
        end
        % test growth
        FBA = optimizeCbModel(modelTest, 'max');
        if FBA.f >= tol
            model = modelTest;
        end
    end
    
    % rare case-some models cannot generate any ATP without oxygen
    if ~any(ismember(model.rxns, 'ATPS4'))
        rxns={
            'ATPS4'
            };
        modelTest=model;
        for i=1:length(rxns)
            if isempty(find(ismember(model.rxns, rxns{i})))
                modelTest = addReaction(modelTest, rxns{i}, 'reactionFormula', database.reactions{find(ismember(database.reactions(:, 1), rxns{i})), 3}, 'geneRule', 'AnaerobicGapfill');
            end
        end
        % test growth
        FBA = optimizeCbModel(modelTest, 'max');
        if FBA.f >= tol
            model = modelTest;
        end
    end
    
    % rare case-acetyl-CoA biosynthesis blocked
    if any(ismember(model.rxns, 'FAO181O'))
        rxns={
            'ACS'
            'H2CO3D'
            };
        modelTest=model;
        for i=1:length(rxns)
            if isempty(find(ismember(model.rxns, rxns{i})))
                modelTest = addReaction(modelTest, rxns{i}, 'reactionFormula', database.reactions{find(ismember(database.reactions(:, 1), rxns{i})), 3}, 'geneRule', 'AnaerobicGapfill');
            end
        end
        % test growth
        FBA = optimizeCbModel(modelTest, 'max');
        if FBA.f >= tol
            model = modelTest;
        end
    end
    % rare case-acetyl-CoA biosynthesis blocked (acetate lacking)
    if any(ismember(model.rxns, 'ACKr')) && any(ismember(model.rxns, 'PTAr')) && any(ismember(model.rxns, 'ACOAD20'))
        rxns={
            'EX_ac(e)'
            'ACtr'
            };
        modelTest=model;
        for i=1:length(rxns)
            if isempty(find(ismember(model.rxns, rxns{i})))
                modelTest = addReaction(modelTest, rxns{i}, 'reactionFormula', database.reactions{find(ismember(database.reactions(:, 1), rxns{i})), 3}, 'geneRule', 'AnaerobicGapfill');
            end
        end
        % test growth
        FBA = optimizeCbModel(modelTest, 'max');
        if FBA.f >= tol
            model = modelTest;
        end
    end
    
    % rare case-10-Formyltetrahydrofolate biosynthesis blocked
    if any(ismember(model.rxns, '5MTHFCL'))
        rxns={
            'FTHFL'
            };
        modelTest=model;
        for i=1:length(rxns)
            if isempty(find(ismember(model.rxns, rxns{i})))
                modelTest = addReaction(modelTest, rxns{i}, 'reactionFormula', database.reactions{find(ismember(database.reactions(:, 1), rxns{i})), 3}, 'geneRule', 'AnaerobicGapfill');
            end
        end
        % test growth
        FBA = optimizeCbModel(modelTest, 'max');
        if FBA.f >= tol
            model = modelTest;
        end
    end
    
    % test again for anaerobic growth
    FBA = optimizeCbModel(model, 'max');
    % add quinone transporters and exchanges
    if FBA.f < tol
        quinoneRxns = {
            'EX_q8(e)'
            'Q8abc'
            };
        for i = 1:length(quinoneRxns)
            formula = database.reactions{ismember(database.reactions(:, 1), quinoneRxns{i}), 3};
            model = addReaction(model, quinoneRxns{i}, 'reactionFormula', formula, 'geneRule', 'AnaerobicGapfill');
        end
        % test growth
        FBA = optimizeCbModel(modelTest, 'max');
        if FBA.f >= tol
            model = modelTest;
        end
    end
    
    % add demethylmenaquinone transporters and exchanges
    quinoneRxns = {
        'EX_2dmmq8(e)'
        '2DMMQ8abc'
        };
    for i = 1:length(quinoneRxns)
        formula = database.reactions{ismember(database.reactions(:, 1), quinoneRxns{i}), 3};
        model = addReaction(model, quinoneRxns{i}, 'reactionFormula', formula, 'geneRule', 'AnaerobicGapfill');
    end
    
    % final test for anaerobic growth
    FBA = optimizeCbModel(modelTest, 'max');
    if FBA.f < tol
        warning('Model cannot grow anaerobically after gap-filling.')
        anaerGrowthOK=0;
    end
    
    % get the reactions that were added
    rxnsPreAnaerGapfill = model_old.rxns;
    oxGapfillRxns = setdiff(model.rxns, rxnsPreAnaerGapfill);
    
    % add the reactions to the previous version of the model
    model=model_old;
    for i = 1:length(oxGapfillRxns)
        formula = database.reactions{ismember(database.reactions(:, 1), oxGapfillRxns{i}), 3};
        model = addReaction(model, oxGapfillRxns{i}, 'reactionFormula', formula, 'geneRule', 'AnaerobicGapfill');
    end
    
else
    model=model_old;
    oxGapfillRxns={};
end

% relax constraints-cause infeasibility problems
relaxConstraints=model.rxns(find(model.lb>0));
model=changeRxnBounds(model,relaxConstraints,0,'l');

% change back to unlimited medium
% list exchange reactions
exchanges = model.rxns(strncmp('EX_', model.rxns, 3));
% open all exchanges
model = changeRxnBounds(model, exchanges, -1000, 'l');
model = changeRxnBounds(model, exchanges, 1000, 'u');

end
