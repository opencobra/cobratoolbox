%%  -- pdb2mat.m --
% This program is the most speedy way to read a PDB file that I could come
% up with. It's function is simple: give it a PDB file and out comes a
% matlab-friendly data structure. In cumbersomely large PDB's (such as those that 
% include solvent), this can shave off a good amount of time relative to
% many programs. Unfortunately there is no easy way to hasten the slowest
% step, which is turning strings into doubles.
%
% The output format is as given in online documentation 
% (as of July 2012 when writing this program)
% http://www.wwpdb.org/documentation/format33/sect9.html#ATOM
%
% It outputs 14 pieces total of information about the PDB. 
% 
% -- mandatory information (11) --
% 
% outfile    (the name of the PDB, this is the only input on the command line)
% 
% recordName (the class or type of atom, such as ATOM, HETATM, SOL, etc)
% atomNum    (serial number of the atom)
% atomName   (elemental identification of the atom)
% altLoc     (alt. location indicator)
% resName    (name of the amino acid/residue)
% 
% chainID    (protein chain identifier)
% resNum     (index number of the amino acid)
% X          (X position of atom)
% Y          (Y position of atom)
% Z          (Z position of atom)
% 
% -- optional information (4) --
% These are extra data about the atoms. In PDBQT's they hold the partial
% charge, for CHARMM this is the chain name, and so on. 
% 
% occupancy
% betaFactor
% element
% charge
%
% 
% -- example usage: plot the atoms of 3IJU.pdb --
% 
% 
% PDBdata = pdb2mat('3IJU.pdb');               % read in data from PDB file
% plot3(PDBdata.X, PDBdata.Y, PDBdata.Z, '.'); % make a 3D plot of data
% 
% -- example usage: translate the atoms of 3IJU.pdb by 10 angstroms in x direction --
% 
% PDBdata = pdb2mat('3IJU.pdb');               % read in data from PDB file
% PDBdata.X = PDBdata.X + 10;                  % translate coordinates
% PDBdata.outfile = '3IJU_tran10angXdir.pdb';  % update file name
% mat2pdb(PDBdata);                            % output data in PDB format
% 
%% --- HOW TO MAKE THIS CODE FASTER! --- >> COMMENT OUT WHAT YOU DON'T USE!!
%
% This program reads everything about the PDB by default. If you want a
% faster code for whatever reason, you can comment out the lines you don't
% need. Each numeric data removed (such at resNum, or betaFactor) speeds it 
% up by 7-8%. Each string data removed (such as resName or atomName) speeds
% it up by 1-2%.

function [PDBdata] = pdb2mat(readFile)
%% -- OUTPUT --

tic;

PDBdata.outfile = readFile;

% initialize file
FileID = fopen(readFile);
rawText = fread(FileID,inf,'*char');

% parse lines by end-of-lines
splitLines = strread(rawText, '%s', 'delimiter', '\n');

% initialize variables
numLines = length(splitLines);

recordName = cell(1,numLines);
atomNum    = cell(1,numLines);
atomName   = cell(1,numLines);
altLoc     = cell(1,numLines);
resName    = cell(1,numLines);

chainID    = cell(1,numLines);
resNum     = cell(1,numLines);
X          = cell(1,numLines);
Y          = cell(1,numLines);
Z          = cell(1,numLines);

comment    = cell(1,numLines);

% read each line
m = 1;
for n = 1:numLines
    
    thisLine = cell2mat(splitLines(n));
    
    if length(thisLine) > 53 && sum(isstrprop(thisLine(23:53), 'alpha')) == 0
        
        recordName(m) = {thisLine(1:6)};
        atomNum(m)    = {thisLine(7:11)};
        atomName(m)   = {thisLine(13:16)};
        altLoc(m)     = {thisLine(17)};
        resName(m)    = {thisLine(18:20)};
        
        chainID(m)    = {thisLine(22)};
        resNum(m)     = {thisLine(23:26)};
        X(m)          = {thisLine(31:38)};
        Y(m)          = {thisLine(39:46)};
        Z(m)          = {thisLine(47:54)};
        
        comment(m)            = {thisLine(55:end)};
        
        m = m + 1;
    end
    
end

% trim exess
keepData = logical(strcmp(recordName,'ATOM  ') + strcmp(recordName,'HETATM'));

recordName = recordName(keepData);
atomNum    = atomNum(keepData);
atomName   = atomName(keepData);
altLoc     = altLoc(keepData);
resName    = resName(keepData);

chainID    = chainID(keepData);
resNum     = resNum(keepData);
X          = X(keepData);
Y          = Y(keepData);
Z          = Z(keepData);

comment    = comment(keepData);

% parse out "comment" section
occupancy  = cell(1, length(recordName));
betaFactor = cell(1, length(recordName));
element    = cell(1, length(recordName));
charge     = cell(1, length(recordName));

% fix spacing
for n = 1:length(recordName)
    thisLine = sprintf('%-26s',cell2mat(comment(n)));
    occupancy(n)  = {thisLine(1:6)};
    betaFactor(n) = {thisLine(7:12)};
    element(n)    = {thisLine(13:24)};
    charge(n)     = {thisLine(25:26)};
end

% reformat data for convenience
PDBdata.recordName = strtrim(recordName);
PDBdata.atomNum    = str2double(atomNum);
PDBdata.atomName   = strtrim(atomName);
PDBdata.altLoc     = altLoc;
PDBdata.resName    = strtrim(resName);

PDBdata.chainID    = chainID;
PDBdata.resNum     = str2double(resNum);
PDBdata.X          = str2double(X);
PDBdata.Y          = str2double(Y);
PDBdata.Z          = str2double(Z);

PDBdata.occupancy  = str2double(occupancy);
PDBdata.betaFactor = str2double(betaFactor);
PDBdata.element    = strtrim(element);
PDBdata.charge     = strtrim(charge);

% I commented these lines out, since they cause more problems than they
% solve. They do clean up the output for certain situations.

% if isnan(PDBdata.occupancy(1))
%     PDBdata.occupancy = strtrim(PDBdata.occupancy);
% end
% if isnan(PDBdata.betaFactor(1))
%     PDBdata.occupancy = strtrim(PDBdata.betaFactor);
% end



% close file
fclose(FileID);

toc;

end