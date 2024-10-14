function model = homogeniseCouplingConstraints(model)
% (1) remove coupling constraints with only one entry
% (1) replace each coupling constraint with 3 entries, with a pair with 2
% entries
%
% USAGE:
%   model = homogeniseCouplingConstraints(model)
%
% INPUTS:
%  model.C:
%  model.ctrs:
%  model.dsense:
%  model.rxns:
%
% OUTPUTS:
%  model.C:
%  model.ctrs:
%  model.dsense:
%  model.rxns:
%
% NOTE: Assumes sIEC_biomass_reactionIEC01b_trtr AND
% sIEC_biomass_reactionIEC01b are the only pair of doubly coupled reactions
% and will error if not
%
% Author(s): Ronan Fleming, 2024

% Get the dimensions of model.C, with m as the number of rows and n as the number of columns
[m,n]  = size(model.C);

% identify coupling constraints with three entries
tripleRowInd = find(sum(abs(model.C)>0,2)==3);
if ~isempty(tripleRowInd)
    bool_sIEC_biomass_reactionIEC01b_trtr = strcmp(model.rxns,'sIEC_biomass_reactionIEC01b_trtr');
    if 0
        % coupling should be sIEC_biomass_reactionIEC01b_trtr < sIEC_biomass_reactionIEC01b
        boolMistakeCoupling = ismember(model.ctrs,'slack_sIEC_biomass_reactionIEC01b');
        bool_sIEC_biomass_reactionIEC01b = ismember(model.rxns,'sIEC_biomass_reactionIEC01b');
        bool_sIEC_biomass_reactionIEC01b_trtr = ismember(model.rxns,'sIEC_biomass_reactionIEC01b_trtr');
        model.C(boolMistakeCoupling,bool_sIEC_biomass_reactionIEC01b)=-1;
        model.C(boolMistakeCoupling,bool_sIEC_biomass_reactionIEC01b_trtr)=-1;
        model.dsense(boolMistakeCoupling)='L';

        bool_sIEC_biomass_reactionIEC01b = strcmp(model.rxns,'sIEC_biomass_reactionIEC01b');
        % replace with two coupling constraints with a pair of entries
        % each
        model.C = [model.C;sparse(length(tripleRowInd),size(model.C,2))];
        model.d = [model.d;sparse(length(tripleRowInd),1)];
        model.ctrs = [model.ctrs;cell(length(tripleRowInd),1)];
        model.dsense = [model.dsense;repmat('',length(tripleRowInd),1)];
        for i = 1:length(tripleRowInd)
            boolRow = model.C(tripleRowInd(i),:)~=0;
            boolRow(bool_sIEC_biomass_reactionIEC01b)=0;
            boolRow(bool_sIEC_biomass_reactionIEC01b_trtr)=0;
            dsense = model.dsense(tripleRowInd(i));
            %half the coupling coefficient for the
            %sIEC_biomass_reactionIEC01b reaction
            model.C(tripleRowInd(i),bool_sIEC_biomass_reactionIEC01b)=model.C(tripleRowInd(i),bool_sIEC_biomass_reactionIEC01b)/2;
            %replicate the coupling constraint but half the coupling coefficient for the
            %sIEC_biomass_reactionIEC01b_trtr reaction
            model.C(m+i,boolRow)=model.C(tripleRowInd(i),boolRow);
            model.d(m+i,1)=model.d(tripleRowInd(i),1);
            model.C(m+i,bool_sIEC_biomass_reactionIEC01b_trtr)=model.C(tripleRowInd(i),bool_sIEC_biomass_reactionIEC01b_trtr)/2;
            model.ctrs{m+i}=[model.ctrs{tripleRowInd(i)} '_trtr'];
            model.dsense(m+i)=dsense;
            %remove triplet coupling coefficient for the
            %bool_sIEC_biomass_reactionIEC01b_trtr reaction
            model.C(tripleRowInd(i),bool_sIEC_biomass_reactionIEC01b_trtr)=0;
        end
    else
        %remove any coupling constraints associated with reaction sIEC_biomass_reactionIEC01b_trtr
        model.C(:,bool_sIEC_biomass_reactionIEC01b_trtr)=0;
    end

    if any(sum(abs(model.C)>0,2)==3)
        error('triplets not completely replaced')
    end
end


% remove coupling constraints with no entry
boolBlankRow = sum(abs(model.C)>0,2)==0;
model.ctrs = model.ctrs(~boolBlankRow);
model.dsense = model.dsense(~boolBlankRow);
model.d = model.d(~boolBlankRow);
model.C(boolBlankRow,:)=[];

% remove coupling constraints with only one entry
boolSingleRow = sum(abs(model.C)>0,2)==1;
model.ctrs = model.ctrs(~boolSingleRow);
model.dsense = model.dsense(~boolSingleRow);
model.d = model.d(~boolSingleRow);
model.C(boolSingleRow,:)=[];

if any(sum(abs(model.C)>0,2)==1)
    error('singles not completely replaced')
end



L       = model.dsense=='L';
G       = model.dsense=='G';
E       = model.dsense=='E';
if any(E)
    error(['equality dsense at ' int2str(nnz(E)) ' positions'])
end

signC = sign(model.C);
boolNegativeSignsRow = sum(signC,2)==-2;
if any(boolNegativeSignsRow)

        fprintf('\n')
        fprintf('%d %s\n',nnz(boolNegativeSignsRow), ' = # rows model.C with both negative signs switched to both positive')

    %switch signs to positive
    model.C(boolNegativeSignsRow,:) = - model.C(boolNegativeSignsRow,:);
    %switch less than to greater than
    model.dsense(boolNegativeSignsRow & L) = repmat('G',nnz(boolNegativeSignsRow & L),1);
    %switch greater than to less than
    model.dsense(boolNegativeSignsRow & G) = repmat('L',nnz(boolNegativeSignsRow & G),1);
end

end