function renameDREAMOutputFiles(zipfile,indir,outdir)
% Replace DREAM file names with original file names.
% 
% renameDREAMOutputFiles(zipfile,indir,outdir);
% 
% INPUTS
% zipfile...    name of zipfile submitted to the DREAM server
% indir...      name of directory containing the DREAM output files
% outdir...     name of directory where renamed files should be placed
% 
% OUTPUTS
% Renamed files.
% 
% June 2015, Hulda S. Haraldsdóttir

% Format inputs
zipfile = regexprep(zipfile,'(\.zip)$',''); % remove file ending
indir = [regexprep(indir,'(/|\\)$',''), filesep]; % Make sure input path ends with directory separator
outdir = [regexprep(outdir,'(/|\\)$',''), filesep]; % Make sure output path ends with directory separator

% Rename files
intxt = fileread([indir 'messages.txt']); % Text file that maps DREAM file names to original file names.
pat = sprintf('The reaction mapping has been completed for "%s/(?<outname>[^")]+)" \\(ID (?<inname>[^\\)]+)\\) with 2D input data.',zipfile);
mapping = regexp(intxt,pat,'names');
innames = {mapping.inname}'; % DREAM file names
outnames = {mapping.outname}'; % Original file names

for i = 1:length(innames)
    filetxt = fileread([indir innames{i} '.rxn']);
    fid = fopen([outdir outnames{i} '.rxn'],'w+');
    fprintf(fid,'%s',filetxt);
    fclose(fid);
end
