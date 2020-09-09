function [c,I]=sort(a,DIM)
%sort: sort in ascending order

if isempty(a),c=a;I=[];return;end

if nargin==2
 %second parameter should be of type double
 DIM=double(DIM);
else
 DIM=1;
end
if nargin==1
 if min(size(a))==1%deal with either row or column vectors as rows
  if size(a,1)==1 %row vector
   [c,I]=mp_dvec_sort_bubble_a(transpose(a));I=I';
   %send back a true mp-value
   %original c=x(I,:); %does not work due to a bug somewhere in matlab
   %the workaround: invoke directly the subsref routine
   SS.type='()';SS.subs={':' I};c=subsref(a,SS);
  else
   [c,I]=mp_dvec_sort_bubble_a(a);
   %same as before
   SS.type='()';SS.subs={I ':'};c=subsref(a,SS);
  end
 else
  %do the same for each column
  SS.type='()';SS.subs={':' 1};
  [c,I]=sort(subsref(a,SS));        
  for k=2:size(a,2)
   SS.subs={':' k};
   [dummy,I(:,k)]=sort(subsref(a,SS));
   SS.subs={':' k};
   c=subsasgn(c,SS,dummy);
  end
 end  
else
 %we only deal with two-dimensional objects, so let's consider both cases
 %and disregard the others
 switch DIM
  case 1
   %standard order; call the routine without the DIM parameter
   [c,I]=sort(a);
  case 2
   %call the routine with the transpose
   dummy=transpose(a);
   [c,I]=sort(dummy);
   %and transpose the answer
   c=transpose(c);
  otherwise
   error(['unsupported option; we recognize only DIM=1 or 2, not ' num2str(DIM)]) 
 end
end
