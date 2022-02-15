%% -- mat2PDB.m --
%
% this function creates a PDB from coordinate data. Represent all inputs as
% a structure field for it to be read. The output format is as given in
% online documentation (as of July 2012 when writing this program)
% http://www.wwpdb.org/documentation/format33/sect9.html#ATOM
%
% Make sure all data input is one-dimensional with the same length. If 
% they are not the same length, the program ignores user input, states 
% an error, and uses defaults. All string inputs should be in cell-format.
% Keep in mind the "element" and "charge" inputs are strings in 
% cell-format, not numbers. 
%
%
% -- required inputs (3) --
%
% input value        meaning
%
% input.X            orthagonal X coordinate data (angstroms)
% input.Y            orthagonal Y coordinate data (angstroms)
% input.Z            orthagonal Z coordinate data (angstroms)
%
% -- optional inputs (12): generates defaults when not user-specified --
%
% input value        meaning                           default value
%
% input.outfile      output file name                 "mat2PDB.pdb"
% input.recordName   output record name of atoms      "ATOM"
% input.atomNum      atom serial number                sequential number
% input.atomName     name of atoms                    "OW" (water oxygen)
% input.altLoc       alt. location indicator          " "
% input.resName      name of residue                  "SOL" (water)
% 
% input.chainID      protein chain identifier         "A"
% input.resNum       residue sequence number           sequential number
% input.occupancy    occupancy factor                 "1.00"
% input.betaFactor   beta factor, temperature         "0.00"
% input.element      element symbol                   "O" (oxygen)
% input.charge       atomic charge                    " "
%
%
% -- example uses --
%
% % translates both X and Y coordinates of 3IJU.pdb by 5 angstroms
% PDBdata = pdb2mat('3IJU.pdb');
% PDBdata.X = PDBdata.X + 5;
% PDBdata.Y = PDBdata.Y + 5;
% mat2pdb(PDBdata)
% 
% % make a PDB with 30 atoms in random places within a 10 angstrom box
% data.X = rand(1,20)*10;
% data.Y = rand(1,20)*10;
% data.Z = rand(1,20)*10;
% mat2pdb(data)
%
% 

function mat2pdb(input)
%% review XYZ coordinate data 

% coordinate data is required! Checking XYZ input
if ~isfield(input, 'X') || ~isfield(input, 'Y') || ~isfield(input, 'Z')
    fprintf('we need xyz coordinate data to make a PDB!!\n\texiting...\n');
    return;
end
X = input.X;
Y = input.Y;
Z = input.Z;
if length(X) ~= length(Y) || length(X) ~= length(Z)
    fprintf('xyz coordinate data is not of equal lengths!\n\texiting...\n');
    return;
end

%% review optional data inputs

% in case optional data data not given, fill in blanks
if ~isfield(input, 'outfile')
    input.outfile = 'mat2PDB.pdb';
end
if ~isfield(input, 'recordName')
    input.recordName = cell(1,length(X));
    input.recordName(1:end) = {'ATOM'};
end
if ~isfield(input, 'atomNum')
    input.atomNum = 1:length(X);
end
if ~isfield(input, 'atomName')
    input.atomName = cell(1,length(X));
    input.atomName(1:end) = {'OW'};
end
if ~isfield(input, 'altLoc')
    input.altLoc = cell(1,length(X));
    input.altLoc(1:end) = {' '};
end
if ~isfield(input, 'resName')
    input.resName = cell(1,length(X));
    input.resName(1:end) = {'SOL'};
end
if ~isfield(input, 'chainID')
    input.chainID = cell(1,length(X));
    input.chainID(1:end) = {'A'};
end
if ~isfield(input, 'resNum')
    input.resNum = 1:length(X);
end
if ~isfield(input, 'occupancy')
    input.occupancy = ones(1,length(X));
end
if ~isfield(input, 'betaFactor')
    input.betaFactor = zeros(1, length(X));
end
if ~isfield(input, 'element')
    input.element = cell(1,length(X));
    input.element(1:end) = {'O'};
end
if ~isfield(input, 'charge')
    input.charge = cell(1,length(X));
    input.charge(1:end) = {' '};
end

outfile    = input.outfile;
recordName = input.recordName;
atomNum    = input.atomNum;
atomName   = input.atomName;
altLoc     = input.altLoc;
resName    = input.resName;
chainID    = input.chainID;
resNum     = input.resNum;
occupancy  = input.occupancy;
betaFactor = input.betaFactor;
element    = input.element;
charge     = input.charge;

%% remove faulty inputs

if length(recordName) ~= length(X)
    fprintf('recordName input is not the correct length!\n\tignoring user input\n');
    recordName = cell(1,length(X));
    recordName(1:end) = {'ATOM'};
end
if length(atomNum) ~= length(X)
    fprintf('atom serial number input is not the correct length!\n\tignoring user input\n');
    atomNum = 1:length(X);
end
if length(atomName) ~= length(X)
    fprintf('atom name input is not the correct length!\n\tignoring user input\n');
    atomName = cell(1,length(X));
    atomName(1:end) = {'OW'};
end
if length(altLoc) ~= length(X)
    fprintf('alternate location input is not the correct length!\n\tignoring user input\n');
    altLoc = cell(1,length(X));
    altLoc(1:end) = {' '};
end
if length(resName) ~= length(X)
    fprintf('residue name input is not the correct length!\n\tignoring user input\n');
    resName = cell(1,length(X));
    resName(1:end) = {'SOL'};
end
if length(chainID) ~= length(X)
    fprintf('chain ID input is not the correct length!\n\tignoring user input\n');
    chainID = cell(1,length(X));
    chainID(1:end) = {'A'};
end
if length(resNum) ~= length(X)
    fprintf('residue number input is not the correct length!\n\tignoring user input\n');
    resNum = 1:length(X);
end
if length(occupancy) ~= length(X)
    fprintf('occupancy input is not the correct length!\n\tignoring user input\n');
    occupancy = ones(1,length(X));
end
if length(betaFactor) ~= length(X)
    fprintf('beta factor input is not the correct length!\n\tignoring user input\n');
    betaFactor = zeros(1, length(X));
end
if length(element) ~= length(X)
    fprintf('element symbol input is not the correct length!\n\tignoring user input\n');
    element = cell(1,length(X));
    element(1:end) = {'O'};
end
if length(charge) ~= length(X)
    fprintf('charge input is not the correct length!\n\tignoring user input\n');
    charge = cell(1,length(X));
    charge(1:end) = {' '};
end

% fix atomName spacing
for n = 1:length(atomName)
    atomName(n) = {sprintf('%-3s',cell2mat(atomName(n)))};
end


%% create PDB

% open file
fprintf('outputting PDB in file %s\n', outfile);
FILE = fopen(outfile, 'w');

% output data
for n = 1:length(atomNum)
    
    % standard PDB output line
    fprintf( FILE, '%-6s%5u%5s%1.1s%3s %1.1s%4u%12.3f%8.3f%8.3f%6.2f%6.2f%12s%2s\n', ...
        cell2mat(recordName(n)), atomNum(n), cell2mat(atomName(n)), ...
        cell2mat(altLoc(n)), cell2mat(resName(n)), cell2mat(chainID(n)), ...
        resNum(n), X(n), Y(n), Z(n), occupancy(n), betaFactor(n), ...
        cell2mat(element(n)), cell2mat(charge(n)));
    
    % output progress in terminal
    if ~mod(n,400)
        fprintf('   %6.2f%%', 100*n / length(atomNum));
        if ~mod(n, 4000)
            fprintf('\n');
        end
    end
    
end
fprintf( FILE, 'END\n');

% close file
fprintf('   %6.2f%%\n    done! closing file...\n', 100);

fclose(FILE);

end