%% *Initialise and verify The COBRA Toolbox*
% *Authors: Sylvain Arreckx, Luxembourg Centre for Systems Biomedicine*
% 
% *Reviewers: *
%% MATERIALS - EQUIPMENT SETUP
% Please ensure that all the required dependencies of The COBRA Toolbox have 
% been properly installed by following the installation guide <https://opencobra.github.io/cobratoolbox/stable/installation.html 
% here>. In particular, |git| and |curl| must be installed.
%% PROCEDURE 
% At the start of each MATLAB session, The COBRA Toolbox must be initialised. 
% Navigate to the directory where you installed The COBRA Toolbox and initialise 
%%
initCobraToolbox(false) % false, as we don't want to update
%% 
% The user who primarily uses the official openCOBRA repository may automatically 
% initialise The COBRA Toolbox. To do so, edit the MATLAB |startup.m| file and 
% add a line with |initCobraToolbox| so that The COBRA Toolbox is initialised 
% each time that MATLAB is started. 					

if usejava('desktop')  % This line of code is to avoid execution in non gui-environments    
    edit startup.m
end
%% *ANTICIPATED RESULTS*
% The initialisation step automatically checks the configuration of all of the 
% required and some of the optional software dependencies. During initialisation, 
% all git submodules are udpated. The solver paths are set when available and 
% compatible. A system-dependent table with the solver status is returned, together 
% with solver suggestions. The user is also presented with options to update The 
% COBRA Toolbox when necessary.
%% CRITICAL STEP
% During initialisation, a check for software dependencies is made and reported 
% to the command window. It is not necessary that all possible dependencies are 
% satisfied before beginning to use the toolbox, e.g., satisfaction of a dependency 
% on a multi-scale linear optimisation solver is not necessary for modelling with 
% a mono-scale metabolic model. However, other software dependencies are essential 
% to be satisfied, e.g., dependency on a linear optimisation solver must be satisfied 
% for any method that uses flux balance analysis. 
%% TROUBLESHOOTING
% # Read the output of the initialisation script in the command window. Any 
% warning or error messages, though often brief, will often point toward the source 
% of the problem during initialisation if read literally. 
% # Verify that all software versions are supported and have been correctly 
% installed. 
% # Ensure that you are using the latest version of The COBRA Toolbox by typing 
% |updateCobraToolbox|
% # Verify and test The COBRA Toolbox, as described in the "Verify and test 
% The COBRA Toolbox" tutorial. 
% # Finally, if nothing else works, consult the COBRA Toolbox forum, as described 
% in the "Engaging with The COBRA Toolbox community" tutorial.
%% Check available optimisation solvers 	
% At initialisation, one from a set of available optimisation solvers will be 
% selected as the default solver. If |Gurobi| is installed, it is used as the 
% default solver for LP, QP and MILP problems. Otherwise, the |GLPK| solver is 
% selected by for LP and MILP problems. It is important to check if the solvers 
% installed are satisfactory. A table stating the solver compatibility and availability 
% is printed to the user during initialisation. 
% 
% 2| Check the currently selected solvers with |changeCobraSolver|
%%
changeCobraSolver
%% ANTICIPATED RESULTS 
% A list of solvers assigned to solve each class of optimisation solver is returned. 				
%% CRITICAL STEP
% A dependency on at least one linear optimisation solver must be satisfied 
% for flux balance analysis. 
%% Verify and test The COBRA Toolbox
%% TIMING ∼30 min
% 3| Optionally test the functionality of The COBRA Toolbox locally, especially 
% if one encounters an error running a function. The test suite runs tailored 
% tests that verify the output and proper execution of core functions on the locally 
% configured system. The full test suite can be invoked by typing:
%%
testAll
%% ANTICIPATED RESULTS
% The test suite starts by initialising The COBRA Toolbox and thereafter, all 
% of the tests are run. At the end of the test run, a comprehensive summary table 
% is presented in which the respective tests and their test outcome is shown. 
% On a properly configured system that is compatible with the most recent version 
% of The COBRA Toolbox, all tests should pass.
%% TROUBLESHOOTING
% If some third party dependencies are not properly installed, some tests may 
% fail. The test suite, despite some tests failing, is not interrupted. The tests 
% that fail are listed with a false status in the column Passed. The specific 
% test can then be run individually to determine the exact cause of the error. 
% If the error can be fixed, follow the tutorial on how to contribute to The COBRA 
% Toolbox and contribute a fix.