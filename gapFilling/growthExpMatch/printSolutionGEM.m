function printSolutionGEM(MatricesSUX, solution, logFile, itNum)
%printSolution displays the solution for growthExpMatch iterations
%
% 11-10-07 IT
%
% Modified 11/18/09: Joseph Kang

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