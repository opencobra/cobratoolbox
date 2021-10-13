function [fileNameOut, extension] = lrsWriteRay(Q,modelName,vertexBool,param)
% Outputs a file for lrs to convert an V-representation (vertex / ray) of a
% polyhedron to a H-representation (half-space) via facet enumeration
%
% V-representation:
%     m is the number of input rows, each being a vertex, ray or line.
%     n is the number of input columns and d=n-1 is dimension of the input.
%     Each vertex is given in the form:
% 
%     1   v_1   v_1  ... v_d
% 
%     Each ray is given in the form:
% 
%     0   r_1   r_2...   r_d
% 
%     where  r_1  ...   r_d  is a point on the ray.
% 
%     There must be at least one vertex in each file. 
%     For bounded polyhedra there will be no rays entered. 
%     The coefficients can be entered as integers or rationals in the format x/y. 
%     An input line can be specified as a ray and then included in the linearity option (see below).
%
% INPUT
% Q             m x n integer matrix where each row is a variable and each column is a vertex or ray
% modelName     string giving the prefix of the *.ext file that will contain the vertex representation
%               It is assumed the file is pwd/*.ine, otherwise provide the full path.
%
% OPTIONAL INPUT
% vertexBool         n x 1 Boolean vector indicating which columns of Q are vertices
%                    By default, all columns of Q are assumed to be rays.
%
% param:             parameter structure with the following fields:
%    *.positivity:    if equals to 1, then positive orthant base
%    *.inequality:    if equals to 1, then represent as two inequalities rather than a single equality
%    *.shellScript:   if equals to 1, then lrs is run through a bash script
%    *.redund         if equals to 0, then remove redundant linear equalities 

% Ronan Fleming 2021

[nMonomial,nRay]=size(Q);
if ~exist('vertexBool','var')
    fprintf('%s\n',['Assuming ' int2str(nRay) ' rays']);
    vertexBool = zeros(nRay,1);
end

if ~exist('param','var')
    param = struct();
end
if ~isfield(param,'positivity')
    param.positivity  = 0;
end
if ~isfield(param,'inequality')
    param.inequality  = 0;
end
if ~isfield(param,'shellScript')
    param.shellScript  = 0;
end
if ~isfield(param,'facetEnumeration')
    %assume vertex enumeration, unless specified that it is facet enumeration
    param.facetEnumeration  = 1;
end
if ~isfield(param,'redund')
    param.redund  = 1;
end

if param.redund ==0
    %remove all redundant halfspaces
    redundCmd = 'redund 0 0'; 
end

%lrs wants each row to be a ray so transpose
Q=Q';

extension = '.ext';
fileNameOut=[modelName extension];
fid=fopen(fileNameOut,'w');
fprintf(fid,'%s\n%s\n',modelName,'V-representation');

if any(~vertexBool)
    ind = find(vertexBool);
    if ~isempty(ind)
        fprintf(fid,'%s%s','linearity ',int2str(nnz(vertexBool)));
        for j = 1:length(ind)
            fprintf(fid,'%s%s',' ',int2str(ind(j)));
        end
        fprintf(fid,'\n');
    end
end

fprintf(fid,'%s\n','begin');

if ~any(vertexBool)
    fprintf(fid,'%s\n',[int2str(nRay+1) ' ' int2str(nMonomial+1) ' integer']);
    %there must be at least one vertex
    for r=1:nRay+1
        if r==1
            for d=1:nMonomial+1
                if d==1
                    fprintf(fid,'%s',[int2str(1)]);
                else
                    fprintf(fid,'%s',[' ' int2str(0)]);
                end
            end
        else
            for d=1:nMonomial+1
                if d==1
                    fprintf(fid,'%s',[int2str(0)]);
                else
                    fprintf(fid,'%s',[' ' int2str(Q(r-1,d-1))]);
                end
            end
        end
        fprintf(fid,'\n');
    end
else
    fprintf(fid,'%s\n',[int2str(nRay) ' ' int2str(nMonomial+1) ' integer']);
    for r=1:nRay
        for d=1:nMonomial+1
            if d==1
                fprintf(fid,'%s',[int2str(vertexBool(r)+0)]);
            else
                fprintf(fid,'%s',[' ' int2str(Q(r,d-1))]);
            end
        end
        fprintf(fid,'\n');
    end
end

%set of vertices specifying positive orthant
if param.positivity
    for i=1:nMonomial
        fprintf(fid,'%s',int2str(1));
        for j=1:nMonomial
            if i==j
                fprintf(fid,'%s',[' ' int2str(1)]);
            else
                fprintf(fid,'%s',[' ' int2str(0)]);
            end
        end
        fprintf(fid,'\n');
    end
end

fprintf(fid,'%s\n','end');
if param.redund==0
    %remove redundant halfspaces
    fprintf(fid,'%s\n',redundCmd);
end
fclose(fid);
                