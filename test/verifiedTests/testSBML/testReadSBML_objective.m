%test reading COBRA models with symbols in objective reactions and multiple objective reactions
for jTest = 1:2
    if jTest == 1
        %test objective reactions with symbols
        fprintf('   Testing readSBML for models with symbols in objective reactions ...\n');
        model = createModel({'EX_a(e)';'EX_b(e)'},{'Test A';'Test B'},...
            {'a[e] <=>'; 'b[e] <=>'});
        model.c = [1;0];
    elseif jTest == 2
        %test more than one objective reactions with >1 objective reactions
        fprintf('   Testing readSBML for models with >1 objective reactions ...\n');
        model = createModel({'EX_a';'EX_b'},{'Test A';'Test B'},...
            {'a[e] <=>'; 'b[e] <=>'});
        model.c = [1; -2];
    end
    model.lb = model.lb(:);
    model.ub = model.ub(:);
    %add the fields outputted by readSBML
    [model.modelVersion.SBML_level,model.modelVersion.SBML_version,...
        model.modelVersion.fbc_version] = deal(3,1,2);
    metField = {;'metChEBIID';'metHMDBID';'metInChIString';'metKEGGID';'metPubChemID'};
    for j = 1:numel(metField)
        model.(metField{j}) = repmat({''},numel(model.mets),1);
    end
    model.metCharges = zeros(numel(model.mets),1);
    model.metFormulas = {'C';'C'};
    rxnField = {'rxnConfidenceScores';'rxnECNumbers';'rxnNotes';'rxnReferences'};
    for j = 1:numel(rxnField)
        model.(rxnField{j}) = repmat({''},numel(model.rxns),1);
    end
    model.osense = -1;
    model.description = 'test_sbml_obj.xml';
    model.genes = cell(1,0);
    %i/o
    writeCbModel(model,'sbml', 'test_sbml_obj');
    model2 = readCbModel('test_sbml_obj.xml');
    assert(isequal(model,model2));
    fprintf(' Done.\n\n');
end
delete('test_sbml_obj.xml')