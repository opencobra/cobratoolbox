%% *Initialise the COBRA Toolbox*
% *Authors: Ronan Fleming, School of Medicine, University of Galway*
% 
% *Reviewers:* 
%% MATERIALS - EQUIPMENT SETUP
% Please ensure that all the required dependencies (e.g. , |git| and |curl|) 
% of The COBRA Toolbox have been properly installed by following the installation 
% guide <https://opencobra.github.io/cobratoolbox/stable/installation.html here>.
%% PROCEDURE
% At the start of each MATLAB session, The COBRA Toolbox should be initialised. 
% Navigate to the directory where you installed The COBRA Toolbox and initialise, 
% but without updating it.

updateToolbox=1;
initCobraToolbox(updateToolbox) % false, as we don't want to update
%% 
% The user who primarily uses the official openCOBRA repository may automatically 
% initialise The COBRA Toolbox. To do so, edit the MATLAB |startup.m| file and 
% add a line with |initCobraToolbox| so that The COBRA Toolbox is initialised 
% each time that MATLAB is started. 					

if usejava('desktop') && 0  % This line of code is to avoid execution in non gui-environments    
    edit startup.m
end
%% *ANTICIPATED RESULTS*
% The initialisation step automatically checks the configuration of all of the 
% required and some of the optional software dependencies. During initialisation, 
% all git submodules are udpated. The solver paths are set when available and 
% compatible. A system-dependent table with the solver status is returned, together 
% with solver suggestions. The user is also presented with options to update The 
% COBRA Toolbox when necessary. It is important to check if the solvers installed 
% are satisfactory. A table stating the solver compatibility and availability 
% is printed to the user during initialisation. 
%% CRITICAL STEP
% During initialisation, a check for software dependencies is made and reported 
% to the command window. It is not necessary that all possible dependencies are 
% satisfied before beginning to use the toolbox, e.g., satisfaction of a dependency 
% on a multi-scale linear optimisation solver is not necessary for modelling with 
% a mono-scale metabolic model. However, other software dependencies are essential 
% to be satisfied, e.g., dependency on a linear optimisation solver must be satisfied 
% for any method that uses flux balance analysis. 
%% TROUBLESHOOTING
%% 
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