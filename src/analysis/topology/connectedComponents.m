function [groups, orphans, R, C] = connectedComponents(model, type, figures, files)
% Assuming two reactions are connected if they share metabolites, calculates the connected components
% in the stoichiometric matrix, that is, the sets of reactions that share a set of metabolites
%
% USAGE:
%
%    [groups, orphans, R, C] = connectedComponents(model, type, figures)
%
% INPUT:
%    model:
%
% OPTIONAL INPUTS:
%    type:       {('allComponents'), 'largestComponent'}
%    figures:    Will generate plots of the grouping algorithm as it creates block diagonal
%                groups in from top left to bottom right in `W`.
%    files:      Indicator, whether several files containing indicator
%                matrices are generated.
% OUTPUTS:
%    groups:     a structure array (the number of distinct groups is length(groups)) with fields:
%
%                  * `groups(i).num_els` - number of reactions in group `i`.
%                  * `groups(i).block` - sub-block identity of group `i`.
%                  * `groups(i).elements` - reactions of W that are in group `i`.
%                  * `groups(i).degrees` - degrees of connection for each reaction in group `i`.
%    orphans:    elements of W that were not in any group, becasue they did not meet the constraints.
%    R:          reaction adjacency
%    C:          compound adjacency
%
% All components require:
% Connected Component Analysis on an Undirected Graph by Tristan Ursell
% http://www.mathworks.com/matlabcentral/fileexchange/35442-connected-component-analysis-on-an-undirected-graph.
%
% Largest component requires:
% gaimc : Graph Algorithms In Matlab Code by David Gleich
% http://www.mathworks.com/matlabcentral/fileexchange/24134-gaimc-graph-algorithms-in-matlab-code.
%
%  .. Author:
%        - Ronan Fleming, 2012
%        - Thomas Pfau May 2017, Speedup and addition of files indicator

if ~exist('type','var')
    type='allComponents';
end
if ~exist('figures','var')
    figures=0;
end
if ~exist('files','var')
    files=0;
end

model=findSExRxnInd(model);


%stoichiometric matrix
S=model.S;
%dont include exchange reactions
S(:,~model.SIntRxnBool)=0;

[m,n]=size(S);

%binary form
B=sparse(m,n);
B(S~=0)=1;

%Compound adjacency
C1=B*B';

%number of reactions a species participates in
nReactionsSpeciesParticipatesIn=diag(C1,0);

%take out connections by cofactors
[nReactionsSpeciesParticipatesInSorted,IX] = sort(nReactionsSpeciesParticipatesIn,'descend');
%model.mets(IX(1:80))

% %omit reactions connected by cofactors
% omitMet=false(m,1);
% for i=1:m
%     metAbbr=model.mets{i};
%     if strcmp(metAbbr(1:2),'h[')
%         omitMet(i)=1;
%         continue;
%     end
%     if strcmp(metAbbr(1:3),'k[')
%         omitMet(i)=1;
%         continue;
%     end
%     if length(metAbbr)>3
%         if strcmp(metAbbr(1:3),'pi[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:3),'cl[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:3),'o2[')
%             omitMet(i)=1;
%             continue;
%         end
%     end
%
%     if length(metAbbr)>4
%         if strcmp(metAbbr(1:4),'na1[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'h2o[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'co2[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'atp[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'adp[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'utp[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'gtp[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'gdp[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'amp[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'nad[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'fad[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'coa[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'ppi[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'nh4[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'ACP[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'thf[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:4),'crn[')
%             omitMet(i)=1;
%             continue;
%         end
%     end
%
%     if length(metAbbr)>5
%         if strcmp(metAbbr(1:5),'nadh[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:5),'fadh[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:5),'nadp[')
%             omitMet(i)=1;
%             continue;
%         end
%     end
%
%     if length(metAbbr)>6
%         if strcmp(metAbbr(1:6),'nadph[')
%             omitMet(i)=1;
%             continue;
%         end
%         if strcmp(metAbbr(1:6),'accoa[')
%             omitMet(i)=1;
%             continue;
%         end
%     end
%
% end
%
% %omit these metabolites
% B(omitMet,:)=0;

%Reaction adjacency
R1=B'*B;

%number of species in a reaction
nMolecularSpeciesInReaction=diag(R1,0);

R=R1;
%Set the diagonal to 0
R(logical(eye(size(R1,1)))) = 0;

if files
    R2=triu(R);
    fid=fopen('reactionAdjacencyOtherThanCofactors.txt','w');
    for j=1:n
        fprintf(fid,'%s\t',model.rxns{j});
    end
    fprintf(fid,'\n');
    for j=1:n
        fprintf(fid,'%s\t',model.rxns{j});
        for k=1:n
            fprintf(fid,'%u\t',full(R2(j,k)));
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
end


C=C1;
%Set the diagonal to 0
C(logical(eye(size(C1,1)))) = 0;

if strcmp(type,'largestComponent')
    if ~exist('largest_component')
        error('Install gamic and add it to your path. (http://www.mathworks.com/matlabcentral/fileexchange/24134-gaimc-graph-algorithms-in-matlab-code)')
    end
    [Acc,p] = largest_component(R);
    degree=sum(Acc);
    groups(1).num_els=nnz(degree);
    groups(1).block='largest';
    groups(1).elements=find(p);
    groups(1).degrees=degree;
    orphans=[];
else
    if figures==1
        [groups,orphans]=graph_analysis(R,'plot',1);
    else
        [groups,orphans]=graph_analysis(R);
    end

end

if files
    fid=fopen('reactionsNotConnectedByAnything.txt','w');
    bool=model.SIntRxnBool;
    bool(groups.elements) = 0;
    for j=1:n
        if bool(j)
            fprintf(fid,'%s\n',model.rxns{j});
        end
    end
    fclose(fid);
end
