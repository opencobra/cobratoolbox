% The COBRAToolbox: testGapFind.m
%
% Purpose:
%     - testGapFind tests the validity of gapFind.
%
% Authors:
%     - Original file: Thomas Pfau Sept 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGapFind'));
cd(fileDir);

testModel = createToyModelForgapFind();
%test solver packages
solverPkgs = {'tomlab_cplex', 'ibm_cplex', 'gurobi', 'glpk'};

for k = 1:length(solverPkgs)
    
    solverOK  = changeCobraSolver(solverPkgs{k}, 'MILP', 0);
    
    if solverOK
        fprintf( 'Testing gapFind with solver %s ...\n',solverPkgs{k});
        %The Basic function should find exactly one Metabolite (H) as gapped
        %The Cycle goes undetected as it can carry flux and I is blocked but not
        %gapped.
        [allGaps, rootGaps, downstreamGaps] = gapFind(testModel);
        
        assert(isempty(downstreamGaps))
        assert(isequal(allGaps,{'H'}));
        assert(isequal(rootGaps,{'H'}));
        
        %Now, we change this to also find No Consumption gaps, It now detects I
        %alng H and does still not detect anything downstream.
        [allGaps, rootGaps, downstreamGaps] = gapFind(testModel,true);
        assert(isempty(downstreamGaps))
        assert(isequal(allGaps,{'H';'I'}));
        assert(isequal(rootGaps,{'H';'I'}));
        
        %Finally, we eliminate the cycle. This should yield E as additional Gap
        %(starting point of the disconnected part) and F and G as downstream Gaps.
        testModelWOCycle = removeRxns(testModel,'R6');
        [allGaps, rootGaps, downstreamGaps] = gapFind(testModelWOCycle);
        dsGaps = {'F';'G'};
        rGaps = {'E';'H'};
        aGaps = union(dsGaps,rGaps);
        assert(isequal(downstreamGaps,dsGaps))
        assert(isequal(allGaps,aGaps));
        assert(isequal(rootGaps,rGaps));
        
        %Only test for one solver (testing multiple solvers is a waste of
        %time)
        
        break
    end
    
end
if exist('MILPProblem.mat','file')
    delete('MILPProblem.mat')
end
if exist('MILPProblem.mat','file')
    delete('MILPProblem.mat')
end