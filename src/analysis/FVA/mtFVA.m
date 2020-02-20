function [minFlux, maxFlux]= mtFVA(LPproblem, rxnsIdx, cpxControl)
% Perform flux variability analysis using multi-threading (via a JAVA VM)
% and CPLEX as solver.
%
% USAGE:
%
%    [minFlux, maxFlux] = mtFVA(LPproblem, rxnsIdx, cpxControl)
%
% INPUT:
%    LPproblem:   COBRA LPproblem structure
%
%    rxnsIdx:     Vector of reaction indices for which to run the
%                 optimizations; a positive index indicates a maximization,
%                 a negative index a minimization of the respective
%                 reaction; by default the fluxes through all reactions are
%                 minimzed and maximized
%
%   cpxControl:   used as parameter for setCplexParam
%
% OUTPUTS:
%    minFlux:     Minimum flux for each reaction
%    maxFlux:     Maximum flux for each reaction
%
%
% .. Authors:
%       - Axel von Kamp  3/21/19

global ILOG_CPLEX_PATH
global CBTDIR
global CBT_LP_PARAMS;

[cplex_root, arch]= fileparts(ILOG_CPLEX_PATH);
cplex_root= fileparts(cplex_root);
cobra_binary_dir= fullfile(CBTDIR, 'binary');
cplex_jar= fullfile(cplex_root, 'lib', 'cplex.jar');
if ~exist(fullfile(cobra_binary_dir, 'CplexFVA.class'), 'file')
  % compilation only necessary once, needs the JAVA compiler javac (not
  % included in Matlab's JAVA installtion)
  disp('Compiling JAVA classes.');
  status= system('javac -version');
  if status ~= 0
    error('Cannot call JAVA compiler; please check if ''javac'' is available on your system.')
  end
  javaVer= version('-java');
  javaVer= regexp(javaVer, '(\d+\.\d+)', 'tokens');
  javaVer= javaVer{1}{1};
  
  curr_dir= pwd();
  cd(fullfile(CBTDIR, 'src', 'analysis', 'FVA'));
  if ispc
     status= system(sprintf('javac -cp "%s" -target %s -source %s CplexFVA.java CplexFVARunnable.java SignedTaskCounter.java',...
      cplex_jar, javaVer, javaVer));   
  else
    status= system(sprintf('javac -cp ''%s'' -target %s -source %s CplexFVA.java CplexFVARunnable.java SignedTaskCounter.java',...
      cplex_jar, javaVer, javaVer));
  end
  if status
    cd(curr_dir);
    error('Failed to compile JAVA classes.');
  end
  movefile('CplexFVARunnable.class', cobra_binary_dir);
  movefile('SignedTaskCounter.class', cobra_binary_dir);
  movefile('CplexFVA.class', cobra_binary_dir);
  cd(curr_dir);
  disp('Compilation finished.');
end

[~, numCols]= size(LPproblem.S);
minFlux= LPproblem.lb;
maxFlux= LPproblem.ub;

cgp= Cplex(); % only used for saving the model and reading the results later
cgp.Model.A= LPproblem.A;
cgp.Model.lhs= LPproblem.b;
cgp.Model.lhs(LPproblem.csense == 'L')= -Inf;
cgp.Model.rhs= LPproblem.b;
cgp.Model.rhs(LPproblem.csense == 'G')= Inf;
cgp.Model.lb= LPproblem.lb;
cgp.Model.ub= LPproblem.ub;
cgp.Model.obj= sparse([], [], [], numCols, 1); % needed for consistent array lengths

if isfield(CBT_LP_PARAMS, 'feasTol')
  cgp.Param.simplex.tolerances.feasibility.Cur= CBT_LP_PARAMS.feasTol;
end
if isfield(CBT_LP_PARAMS, 'optTol')
  cgp.Param.simplex.tolerances.optimality.Cur= CBT_LP_PARAMS.optTol;
end
cgp= setCplexParam(cgp, cpxControl, true);

fname= tempname();
lpfile= [fname, '.sav'];
prmfile= [fname, '.prm'];

cgp.writeModel(lpfile);
cgp.writeParam(prmfile);

javacmd= fullfile(char(java.lang.System.getProperty('java.home')), 'bin', 'java');
cplex_bin= fullfile(cplex_root, 'bin', arch);
if ispc
  [status, cmdout]= system(sprintf(...
    '"%s" -Djava.library.path="%s" -cp "%s;%s" CplexFVA %s %s %s', javacmd, cplex_bin, cplex_jar,...
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
