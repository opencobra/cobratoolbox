function x = testModelManipulation()
%testModelManipulation tests addReaction, removeReaction, removeMetabolite
%   first creates a simple toy network with basic S, lb, ub, rxns, mets
%   tests addReaction, removeReaction, removeMetabolite
%   then creates an empty matrix and does the previous procedures.
%   Then tests convertToReversible, and convertToIrreversible using the 
%   iJR904 model. Prints whether each test was successful or not.
%
%   Joseph Kang 04/16/09
%   Richard Que (12/16/09) Added testing of convertToIrrevsible/Reversible


%%
%
%

oriFolder = pwd;
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

%Test with non-empty model
%addReaction, removeReaction, removeMetabolite
x=1;
model.S = [-1, 0, 0 ,0 , 0, 0, 0;
            1, -1, 0, 0, 0, 0, 0;
            0, -1, 0,-1, 0, 0, 0;
            0, 1, 0, 1, 0, 0, 0;
            0, 1, 0, 1, 0, 0, 0;
            0, 1,-1, 0, 0, 0, 0;
            0, 0, 1,-1, 1, 0, 0;
            0, 0, 0, 1,-1,-1, 0;
            0, 0, 0, 0, 1, 0, 0;
            0, 0, 0, 0,-1, 0, 0;
            0, 0, 0, 0, 0, 1, 1;
            0, 0, 0, 0, 0, 1, -1];
model.lb = [0, 0, 0, 0, 0, 0, 0];
model.ub = [20, 20, 20, 20, 20, 20, 20];
model.rxns = {'GLCt1'; 'HEX1'; 'PGI'; 'PFK'; 'FBP'; 'FBA'; 'TPI'};
model.mets = {'glc-D[e]'; 'glc-D'; 'atp'; 'H'; 'adp'; 'g6p';'f6p'; 'fdp'; 'pi'; 'h2o'; 'g3p'; 'dhap'};
sc =  [-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
mets_length= length(model.mets);
rxns_length= length(model.rxns);


model = addReaction(model, 'EX_glc', model.mets, sc, 0, 0, 20);

%check if rxns length was incremented by 1
if(length(model.rxns) ~= rxns_length+1)
    disp('Incorrect rxns length after addReaction using list approach');
    x=0;
else
    disp('Correct rxns length after addReaction using list approach');
end
      

%model.S;
%model.rxns;
%model.mets;

model = removeRxns(model, {'EX_glc'} );

%check if rxns length was decremented by 1
if(length(model.rxns) ~= rxns_length)
    disp('Incorrect rxns length after removeRxns');
    x=0;
else
    disp('Correct rxns length after removeRxns');
end

model = addReaction(model,'newRxn1','A -> B + 2 C');
 
if(length(model.rxns) ~= rxns_length+1)
    disp('Incorrect rxns length after addReaction using formula approach');
    x=0;
else
    disp('Correct rxns length after addReaction using formula approach');
end

if(length(model.mets) ~= mets_length+3)
    disp('Incorrect mets length after addReaction using formula approach');
    x=0;
else
    disp('Correct mets length after addReaction using formula approach');
end

model = changeRxnBounds(model, model.rxns, 2, 'u');
if(model.ub(1) ~= 2)
    disp('Incorrect rxn bounds after changeRxnBounds');
    x=0;
else
    disp('Correct rxn bounds after changeRxnBounds');
end


model = removeRxns(model, {'newRxn1'});

model = removeMetabolites(model, {'A', 'B', 'C'});
if(length(model.mets) ~= mets_length)
    disp('Incorrect mets length after removeMetabolites');
    x=0;
else
    disp('Correct mets length after removeMetabolites');
end
%%


%Tests with empty model
%addReaction works incorrectly? S matrix is inverted (nMets is nRxns while
%nRxns is nMets...
disp('  ');
disp('  ');
disp('Starting empty model tests: ');
    
model.S= [];
model.rxns = {};
model.mets = {};
model.lb = [];
model.ub = [];


rxns_length = 0;
mets_length = 0;


model = addReaction(model,'newRxn1','A -> B + 2 C');

if(length(model.rxns) ~= rxns_length+1)
    disp('Incorrect rxns length after addReaction using formula approach');
    x=0;
else
    disp('Correct rxns length after addReaction using formula approach');
end

if(length(model.mets) ~= mets_length+3)
    disp('Incorrect mets length after addReaction using formula approach');
    x=0;
else
    disp('Correct mets length after addReaction using formula approach');
end

model = changeRxnBounds(model, model.rxns, 2, 'u');
if(model.ub(1) ~= 2)
    disp('Incorrect rxn bounds after changeRxnBounds');
    x=0;
else
    disp('Correct rxn bounds after changeRxnBounds');
end


model = removeRxns(model, {'newRxn1'});
if(length(model.rxns) ~= rxns_length)
    disp('Incorrect rxns length after removeRxns');
    x=0;
else
    disp('Correct rxns length after removeRxns');
end


model = removeMetabolites(model, {'A', 'B', 'C'});
if(length(model.mets) ~= mets_length)
    disp('Incorrect mets length after removeMetabolites');
    x=0;
else
    disp('Correct mets length after removeMetabolites');
end

%% Convert to irreversible
fprintf('\n\nTesting convertToIrreversible\n');
load('testModelManipulation.mat','model','modelIrrev');
[testModelIrrev,matchRev,rev2irrev,irrev2rev] = convertToIrreversible(model);

if ~isSameCobraModel(modelIrrev,testModelIrrev);
    display('Model not converted to irreversible properly');
    x=0;
else
    display('Model converted to irreversible properly');
end

%% Convert to reversible
fprintf('\n\nTesting convertToReversible\n');
testModelRev = convertToReversible(testModelIrrev);
load('testModelManipulation.mat','modelRev');

if ~isSameCobraModel(modelRev,testModelRev);
    display('Model not converted to reversible properly');
    x=0;
else
    display('Model converted to reversible properly');
end


cd(oriFolder);



end

