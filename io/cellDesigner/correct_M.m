function [r_info]=correct_M(ref,listN,listR);

% ref_corrected=correct_M(ref,cmp_recon2map_M.listOfNotFound(:,6),listForCorrection(:,2))

col_name=2;


r_info=ref.r_info;
r_listN=listN
r_listR=listR


for n=1:length(r_listR)
    r_info.species(r_listN{n},col_name)=r_listR(n);
end


