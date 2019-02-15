function [minFlux, maxFlux]= mtFVA(model, rxnsIdx)
% Perform flux variability analysis using multi-threading (via a JAVA VM)
% and CPLEX as solver.
%
% USAGE:
%
%    [minFlux, maxFlux] = mtFVA(model, rxnsIdx)
%
% INPUT:
%    model:       COBRA model structure, all rows in model.S are currently
%                 treated as equality constraints 
%
% OPTIONAL INPUTS:
%    rxnsIdx:     Vector of reaction indices for which to run the
%                 optimizations; a positive index indicates a maximization,
%                 a negative index a minimization of the respective
%                 reaction; by default the fluxes through all reactions are
%                 minimzed and maximized
%
% OUTPUTS:
%    minFlux:     Minimum flux for each reaction
%    maxFlux:     Maximum flux for each reaction
%
%
% .. Authors:
%       - Axel von Kamp  2/15/19

global ILOG_CPLEX_PATH
global CBTDIR

[cplex_root, arch]= fileparts(ILOG_CPLEX_PATH);
cplex_root= fileparts(cplex_root);
cobra_binary_dir= fullfile(CBTDIR, 'binary');
cplex_jar= fullfile(cplex_root, 'lib', 'cplex.jar');
if ~exist(fullfile(cobra_binary_dir, 'CplexFVA.class'), 'file')
  % compilation only necessary once, needs the JAVA compiler javac (not
  % included in Matlab's JAVA installtion)
  disp('Compiling JAVA classes.');
  curr_dir= pwd();
  cd(cobra_binary_dir)
  if ispc
     status= system(sprintf('javac -cp "%s" CplexFVA.java CplexFVARunnable.java SignedTaskCounter.java',...
      cplex_jar), '-echo');   
  else
    status= system(sprintf('javac -cp ''%s'' CplexFVA.java CplexFVARunnable.java SignedTaskCounter.java',...
      cplex_jar), '-echo');
  end
  cd(curr_dir);
  if status
    error('Could not compile JAVA classes.');
  end
  disp('Compilation finished.');
end

[numMets, numRxns]= size(model.S);
minFlux= NaN(numRxns, 1);
maxFlux= NaN(numRxns, 1);

if nargin < 2
  rxnsIdx= 1:numRxns;
  rxnsIdx= [rxnsIdx, -rxnsIdx]; % positive index: maximization, negative index: minimization
end

cgp= Cplex(); % only used for saving the model and reading the results later
cgp.Model.A= model.S;
cgp.Model.lhs= sparse([], [], [], numMets, 1);
cgp.Model.rhs= sparse([], [], [], numMets, 1);
cgp.Model.lb= model.lb;
cgp.Model.ub= model.ub;
cgp.Model.obj= sparse([], [], [], numRxns, 1); % needed for consistent array lengths

fname= tempname();
lpfile= [fname, '.sav'];
prmfile= [fname, '.prm'];

cgp.writeModel(lpfile);
cgp.writeParam(prmfile);

javacmd= fullfile(char(java.lang.System.getProperty('java.home')), 'bin', 'java');
cplex_bin= fullfile(cplex_root, 'bin', arch);
if ispc
  [status, cmdout]= system(sprintf(...
    '"%s" -Djava.library.path="%s" -cp "%s:%s" CplexFVA %s %s %s', javacmd, cplex_bin, cplex_jar,...
    cobra_binary_dir, lpfile, prmfile, sprintf('%d ', rxnsIdx)));
else
  [status, cmdout]= system(sprintf(...
    '''%s'' -Djava.library.path=''%s'' -cp ''%s:%s'' CplexFVA %s %s %s', javacmd, cplex_bin, cplex_jar,...
    cobra_binary_dir, lpfile, prmfile, sprintf('%d ', rxnsIdx)));
end

if status
  disp(cmdout);
  error('FVA failed.');
else
  cgp.readModel(lpfile);
  idx= -rxnsIdx(rxnsIdx < 0);
  minFlux(idx)= cgp.Model.lb(idx);
  idx= rxnsIdx(rxnsIdx > 0);
  maxFlux(idx)= cgp.Model.ub(idx);
end

delete(lpfile)
delete(prmfile)
