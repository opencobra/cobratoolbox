% The COBRAToolbox: testExtremePathways.m
%
% Purpose:
%     - testExtremePathways tests the functionality of lsr and extremePathways.
%
% Authors:
%     - Sylvain Arreckx March 2017
%
% Test problem from
%     Extreme Pathway Lengths and Reaction Participation in Genome-Scale Metabolic Networks
%     Jason A. Papin, Nathan D. Price and Bernhard Ø. Palsson

if isunix
    [status, result] = system('which lrs');
    if isempty(strfind(result, 'not found'))
        % save the current path
        currentDir = pwd;

        % initialize the test
        fileDir = fileparts(which('testExtremePathways'));
        cd(fileDir);

        S = [-1,  0,  0,  0,  0,  0, 1,  0,  0;
              1, -2, -2,  0,  0,  0, 0,  0,  0;
              0,  1,  0,  0, -1, -1, 0,  0,  0;
              0,  0,  1, -1,  1,  0, 0,  0,  0;
              0,  0,  0,  1,  0,  1, 0, -1,  0;
              0,  1,  1,  0,  0,  0, 0,  0, -1;
              0,  0, -1,  1, -1,  0, 0,  0,  0];

        model.S = S;

        % calculates the matrix of extreme pathways, P
        [P, V] = extremePathways(model);

        refP = [2, 2, 2;
                1, 0, 1;
                0, 1, 0;
                0, 1, 1;
                0, 0, 1;
                1, 0, 0;
                2, 2, 2;
                1, 1, 1;
                1, 1, 1];

        assert(all(all(refP(:, [2, 1, 3]) == P)))

        clear model;
        model.S = S;
        model.description = 'PapinPrincePalsson';
        [nMet, nRxn] = size(model.S);
        model.b = zeros(nMet, 1);
        model.directionality = zeros(nRxn, 1);
        positivity = 0;
        inequality = 1;

        [P, V] = extremePathways(model, positivity, inequality)

        refP = [ 0,  0, 2;
                 1,  1, 0;
                -1, -1, 1;
                 0, -1, 1;
                 1,  0, 0;
                 0,  1, 0;
                 0,  0, 2;
                 0,  0, 1;
                 0,  0, 1];

        assert(all(all(refP == P)))

        % Change the model to have one non integer entry.
        model.S(1, 1) = 0.5;
        try
            [P, V] = extremePathways(model);
        catch ME
            assert(length(ME.message) > 0)
        end

        % delete generated files
        delete('*.ine');
        delete('*.ext');

        % change the directory
        cd(currentDir)
    else
        fprintf('lrs not installed or not in path\n');
    end
else
    fprintf('non unix machines not yet supported\n');
end
