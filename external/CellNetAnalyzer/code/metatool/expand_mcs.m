function [mcs, reac_ind, mcs_ind]= expand_mcs(mcs, sub)
% mcs is a logical matrix
% the rows of sub correspond to the subsets, the columns to the reactions
% mcs_ind maps the expanded mcs to the original mcs

[num_sub, num_reac]= size(sub);

if(isempty(mcs))
	reac_ind=1:num_reac;
	mcs_ind=[];
	return;
end

num_alt= sum(sub ~= 0, 2)' - 1; %A# row vector
rep= find(num_alt); %A# subsets with more than one reaction
reac_ind= zeros(num_reac, 1); %A# maps the rows of the expanded mcs to the reaction indices
arc_alt= cell(1, num_sub);
for i= 1:num_sub
  ind= find(sub(i, :));
  reac_ind(i)= ind(1);
  if length(ind) > 1
    arc_alt{i}= ind(2:end);
  end
end
prev= size(mcs, 2);
num_total= ones(prev, 1);
for i= rep
  num_total(mcs(i, :))= num_total(mcs(i, :)) * (num_alt(i) + 1);
end
num_total= sum(num_total);

if nargout >= 3
  mcs_ind= 1:prev;
  mcs_ind(prev+1:num_total)= 0;
end
mcs(:, prev+1:num_total)= 0;
new_row= num_sub + 1;
mcs(new_row:num_reac, :)= 0;
for i= rep
  ind= find(mcs(i, 1:prev)); %A# 'find' neccesary for octave compatibility when using 'ind' below
  num_paths= length(ind);
  first= prev + 1;
  last= prev + num_paths*num_alt(i);
  prev= last;
  mcs(:, first:last)= repmat(mcs(:, ind), 1, num_alt(i));
  mcs(i, first:last)= false; %# remove representative arc
  if nargout >= 3
    mcs_ind(first:last)= repmat(mcs_ind(ind), 1, num_alt(i));
  end
  last= first - 1 + num_paths;
  for arc= arc_alt{i}
    reac_ind(new_row)= arc;
    mcs(new_row, first:last)= true; %# set alternative arc
    first= first + num_paths;
    last= last + num_paths;
    new_row= new_row + 1;
  end
end
reac_ind(new_row:end)= find(~any(sub, 1)); %A# finally add indices of blocked reactions
unperm(reac_ind)= 1:num_reac;
mcs= mcs(unperm, :);
