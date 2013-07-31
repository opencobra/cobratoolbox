%setup the paths to the data, scripts and functions, load data, +/- generate docs

%clear workspace
clear

%find the absolute path of this COBRA toolbox extension
global vonBdir
vonBdir=which('generateVonBertalanffyDocumentation');
if isempty(vonBdir)
    error('Current directory must be */vonBertalanffy')
end
vonBdir=vonBdir(1:end-length('/generateVonBertalanffyDocumentation.m'));

if 1
    %adjustedAlberty2006 contains metabolites adjusted to a common baseline
    load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'alberty2006' filesep 'adjustedAlberty2006.mat']);
else
    load([vonBdir filesep 'setupThermoModel' filesep 'experimentalData' filesep 'alberty2006' filesep 'Alberty2006.mat']);
end
load([vonBdir filesep 'setupThermoModel' filesep  'experimentalData' filesep 'alberty2006' filesep 'metAbbrAlbertyAbbr.mat']);
load([vonBdir filesep 'setupThermoModel' filesep  'experimentalData' filesep 'groupContribution' filesep 'jankowskiGroupData.mat']);

if isempty(which('pHbalanceProtons'))
    fprintf('Add the toolbox to the matlab path.\n')
    %add the toolbox path to the matlab path
    addpath(genpath(vonBdir));
    savepath;
end

if ~exist([vonBdir filesep 'doc'])
    if ~(exist('m2html','file') ~= 2)
        fprintf('Generating html documentation... \n')
        generateVonBertalanffyDocumentation;
        fprintf('...documentation complete.\n')
    end
end
