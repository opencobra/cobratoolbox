function AGORA2_dir = downloadAGORA2(directory)
% Download and unpack agora2
% INPUT
% directory     Directory indicating where to donwload AGORA2
%
% OUTPUT
% AGORA2_dir    Directory to AGORA2 folder
%
% Author:  Tim Hensen, 2024

% Download AGORA2
websave('AGORA2_annotatedMat_A_C','https://www.vmh.life/files/reconstructions/AGORA2/version2.01/mat_files/zipped/AGORA2_annotatedMat_A_C.zip.zip')
websave('AGORA2_annotatedMat_D_F','https://www.vmh.life/files/reconstructions/AGORA2/version2.01/mat_files/zipped/AGORA2_annotatedMat_D_F.zip.zip')
websave('AGORA2_annotatedMat_G_P','https://www.vmh.life/files/reconstructions/AGORA2/version2.01/mat_files/zipped/AGORA2_annotatedMat_G_P.zip.zip')
websave('AGORA2_annotatedMat_R_Y','https://www.vmh.life/files/reconstructions/AGORA2/version2.01/mat_files/zipped/AGORA2_annotatedMat_R_Y.zip')

% Unzip to folder
AGORA2_dir = [directory filesep 'AGORA2'];
mkdir(AGORA2_dir)
unzip('AGORA2_annotatedMat_A_C', AGORA2_dir)
unzip('AGORA2_annotatedMat_D_F', AGORA2_dir)
unzip('AGORA2_annotatedMat_G_P', AGORA2_dir)
unzip('AGORA2_annotatedMat_R_Y', AGORA2_dir)
end