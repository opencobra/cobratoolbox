function printSolutionGEM(MatricesSUX, solution, logFile, itNum)
% Displays the solution for `growthExpMatch` iterations
%
% USAGE:
%
%    printSolutionGEM(MatricesSUX, solution, logFile, itNum)
%
% INPUTS:
%    MatricesSUX:    SUX Matrix
%    solution:       MILP solution that consists of the continuous solution, integer
%                    solution, objective value, stat, full solution, and
%                    imported reactions
%    logFile:        solution is printed in this file (name of reaction added and
%                    flux of that particular reaction) (Default = GEMLog.txt)
%    itNum:          number of iterations
%
% .. Author:
%       - IT,  11-10-07
%       - Joseph Kang, modified 11/18/09
if nargin >2
    save([logFile '_solution_' num2str(itNum)], 'solution');
    if ~strcmp(logFile(end-3:end),'.txt'), logFile = [logFile '.txt']; end
    if (itNum ==1)
        fid = fopen(logFile,'w');
    else
        fid = fopen(logFile,'a');
    end
    fprintf(fid,'%s','Iteration:');
    fprintf(fid,'\t');
    fprintf(fid,'%d',itNum);
    fprintf(fid,'\n');
else
    fid=1;
end

fprintf(fid, '%s','Objective Value:');
fprintf(fid,'\t');
fprintf(fid,'%d',solution.obj);
fprintf(fid,'\n');
fprintf(fid,'\n');
% prints only non-zero results
for i=1:length(solution.cont)
    if (solution.cont(i)~= 0)  && MatricesSUX.MatrixPart(i)~= 1
        fprintf(fid,'%d',i);
        fprintf(fid,'\t');
        fprintf(fid,'%s', MatricesSUX.rxns{i});
        fprintf(fid,'\t');
        fprintf(fid,'%d',solution.cont(i));
        fprintf(fid,'\n');
    end
end

fprintf(fid,'\n');
if nargin >2
    fclose(fid);
end
