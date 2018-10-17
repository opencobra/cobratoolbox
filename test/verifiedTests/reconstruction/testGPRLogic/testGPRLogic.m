% The COBRAToolbox: testGPRLogic.m
%
% Purpose:
%     - test the GPR Parser logic
%
% Authors:
%     - Original File: Thomas Pfau Jan 2018
%

%Get the current directory
currentDir = pwd;

model = createToyModelForgapFind(); % we use some model, it doesn't really matter...
% The following lines are just for testing functionality. We need to assign
% things manually in order to be able to test some things. normally: just
% use changeGeneAssociation..
model.genes = {'G1','G2','G3','G4','G5','G6'}'; 
model.rules = cell(numel(model.rxns),1);
model.rules(:) = {''};
model.rules([1, 2 ,3 ,4,5, 6]) = {'x(1)&x(2)';...
                                'x(4)   | (x(3))';...
                                'x(5) & ((x(6)) | x(2))';...
                                'x(1) & ((x(2) | x(3)) | x(4))';...
                                'x(1) & (((x(3) | x(4) | x(5)) & (x(1) & x(2)) | (x(4) & x(5)) & (x(6) | x(2) | x(1))) | x(1) & x(4) & x(5)';...
                                '(((x(3) | x(4) | x(5)) & (x(1) & x(2)) | (x(4) & x(5)) & (x(6) | x(2) | x(1)))'};
                            
model = rmfield(model,'rxnGeneMat');

modelNorm = NormaliseGPRs(model);
%Now, testing this is slightly difficult, as the order of elements does not
%necessarily have to be the same. 
%we will do the following: The fifth is equivalent to clauses with these
%positions:
clauses = {[1,2,3],[1,2,4],[1,2,5],[1,4,5,6],[1,4,5],[1,2,4,5]};
%We will therefore check, whether all of those and only those clauses
%exist)
clausesToCheck = clauses;
%Now, lets extract the clauses from the rules string
clausesInModel = strsplit(modelNorm.rules{5},'|');
%now, extract the numbers from the clauses
positions = regexp(clausesInModel,'^|[\( ]x\((?<pos>[0-9]+)\)[ \)]|$','names'); %This simultaneously checks, that the format was adapted.
for i = 1:numel(positions)
    cpos = cellfun(@str2num, {positions{i}.pos});    
    clauseFound = false;
    for j = 1:numel(clausesToCheck)
        if isempty(setxor(cpos,clausesToCheck{j}))
            clausesToCheck(j) = [];
            clauseFound = true;
            break;
        end
    end
    assert(clauseFound);
end   
assert(isempty(clausesToCheck));
%Lets do the same for the grRules.

clausesInModel = strsplit(strrep(modelNorm.grRules{5},'and','&'),'or');
genes = regexp(clausesInModel,'^|[\( ](?<genes>[^\[\]\{\}\(\) &]+)[ \)]|$','names'); %This simultaneously checks, that the format was adapted.
clausesToCheck = cellfun(@(x) model.genes(x),clauses,'UniformOutput',0);
for i = 1:numel(genes)
    cpos = {genes{i}.genes};    
    clauseFound = false;
    for j = 1:numel(clausesToCheck)
        if isempty(setxor(cpos,clausesToCheck{j}))
            clausesToCheck(j) = [];
            clauseFound = true;
            break;
        end
    end
    assert(clauseFound);
end   
assert(isempty(clausesToCheck));

%and now, test the evaluation of Nodes.
assignment = containers.Map({'1','2','3','4','5','6'},{true,true,false,false,false,false});
fp = FormulaParser;
Rule5 = fp.parseFormula(modelNorm.rules{5});
assert(~Rule5.evaluate(assignment))

Rule1 = fp.parseFormula(modelNorm.rules{1});
assert(Rule1.evaluate(assignment))
%There is the 1,2,3 clause so this has to evaluate to true.
assignment('3') = true;
assert(Rule5.evaluate(assignment))

%Then, check whether 'contains' works.
%It does not contain position 20, but it does contain position 5 
assert(~Rule5.contains('20'))
assert(Rule5.contains('5'))

% also test deletion with and clause removal
comparison = '(x(4) & x(5) & (x(6) | x(2)))';
compForm = fp.parseFormula(comparison);
head = fp.parseFormula(model.rules{6});
head.deleteLiterals('1',false);
assert(head.isequal(compForm));


%Finally, test the deletion of a literal
head = fp.parseFormula(model.rules{5});
head.deleteLiteral('1');

%Delete all unnecessary rules (makes this faster)
modelNorm.rules(:) = {''};
modelNorm = rmfield(modelNorm,'grRules');
modelNorm.rules{5} = head.toString(true);
modelNorm = NormaliseGPRs(modelNorm);
%now, if we remove the first gene, the clauses should be as follows:
%(Essentially the first clauses minus the 1)
clauses = {[2,3],[2,4],[2,5],[4,5,6],[4,5],[2,4,5]};
%We will therefore check, whether all of those and only those clauses
%exist)
clausesToCheck = clauses;
%Now, lets extract the clauses from the rules string
clausesInModel = strsplit(modelNorm.rules{5},'|');
%now, extract the numbers from the clauses
positions = regexp(clausesInModel,'^|[\( ]x\((?<pos>[0-9]+)\)[ \)]|$','names'); %This simultaneously checks, that the format was adapted.
for i = 1:numel(positions)
    cpos = cellfun(@str2num, {positions{i}.pos});    
    clauseFound = false;
    for j = 1:numel(clausesToCheck)
        if isempty(setxor(cpos,clausesToCheck{j}))
            clausesToCheck(j) = [];
            clauseFound = true;
            break;
        end
    end
    assert(clauseFound);
end   
assert(isempty(clausesToCheck));

%Convert from DNF to CNF
%This formula is equivalent to (x(1) | x(2)) & (x(3) | x(4)) & (x(5) | x(6))
DNFFormula = fp.parseFormula('x(1) & x(3) & x(5) | (x(1) & x(3) & x(6) | x(1) & x(4) & x(5)) | (x(1) & x(4)) & x(6) | x(2) & x(3) & x(5) | x(2) & x(3) & x(6) | x(2) & x(4) & x(5) | x(2) & x(4) & x(6)');
CNFFormula = DNFFormula.convertToCNF();

clauses ={[1,2],[3,4],[5,6]};
clausesToCheck = clauses;
%Now, lets extract the clauses from the rules string
clausesInModel = strsplit(CNFFormula.toString(1),'&');
%now, extract the numbers from the clauses
positions = regexp(clausesInModel,'^|[\( ]x\((?<pos>[0-9]+)\)[ \)]|$','names'); %This simultaneously checks, that the format was adapted.
for i = 1:numel(positions)
    cpos = cellfun(@str2num, {positions{i}.pos});    
    clauseFound = false;
    for j = 1:numel(clausesToCheck)
        if isempty(setxor(cpos,clausesToCheck{j}))
            clausesToCheck(j) = [];
            clauseFound = true;
            break;
        end
    end
    assert(clauseFound);
end   
assert(isempty(clausesToCheck));

%And also test another formula:
formula = fp.parseFormula('x(1) | x(2) & x(3) | (x(3) & ( x(4) | x(5)) & x(6))');
CNFFormula = formula.convertToCNF();
%This formula is equivalent to:
%(x(1) | x(3)) & (x(1) | x(2) | x(6)) & (x(1) | x(2) | x(4) | x(5))
clauses = {[1,3],[1,2,6],[1,2,4,5]};
clausesToCheck = clauses;
clausesInModel = strsplit(CNFFormula.toString(1),'&');
%now, extract the numbers from the clauses
positions = regexp(clausesInModel,'^|[\( ]x\((?<pos>[0-9]+)\)[ \)]|$','names'); %This simultaneously checks, that the format was adapted.
for i = 1:numel(positions)
    cpos = cellfun(@str2num, {positions{i}.pos});    
    clauseFound = false;
    for j = 1:numel(clausesToCheck)
        if isempty(setxor(cpos,clausesToCheck{j}))
            clausesToCheck(j) = [];
            clauseFound = true;
            break;
        end
    end
    assert(clauseFound);
end   
assert(isempty(clausesToCheck));