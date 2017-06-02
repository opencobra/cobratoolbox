function [status, message]=xlwrite(filename,A,sheet, range)
% XLWRITE Write to Microsoft Excel spreadsheet file using Java
%   XLWRITE(FILE,ARRAY) writes ARRAY to the first worksheet in the Excel
%   file named FILE, starting at cell A1. It aims to have exactly the same
%   behaviour as XLSWRITE. See also XLSWRITE.
%
%   XLWRITE(FILE,ARRAY,SHEET) writes to the specified worksheet.
%
%   XLWRITE(FILE,ARRAY,RANGE) writes to the rectangular region
%   specified by RANGE in the first worksheet of the file. Specify RANGE
%   using the syntax 'C1:C2', where C1 and C2 are opposing corners of the
%   region.
%
%   XLWRITE(FILE,ARRAY,SHEET,RANGE) writes to the specified SHEET and
%   RANGE.
%
%   STATUS = XLWRITE(FILE,ARRAY,SHEET,RANGE) returns the completion
%   status of the write operation: TRUE (logical 1) for success, FALSE
%   (logical 0) for failure.  Inputs SHEET and RANGE are optional.
%
%   Input Arguments:
%
%   FILE    String that specifies the file to write. If the file does not
%           exist, XLWRITE creates a file, determining the format based on
%           the specified extension. To create a file compatible with Excel
%           97-2003 software, specify an extension of '.xls'. If you do not 
%           specify an extension, XLWRITE applies '.xls'.
%   ARRAY   Two-dimensional logical, numeric or character array or, if each
%           cell contains a single element, a cell array.
%   SHEET   Worksheet to write. One of the following:
%           * String that contains the worksheet name.
%           * Positive, integer-valued scalar indicating the worksheet
%             index.
%           If SHEET does not exist, XLWRITE adds a new sheet at the end
%           of the worksheet collection. 
%   RANGE   String that specifies a rectangular portion of the worksheet to
%           read. Not case sensitive. Use Excel A1 reference style.
%           * If you specify a SHEET, RANGE can either fit the size of
%             ARRAY or specify only the first cell (such as 'D2').
%           * If you do not specify a SHEET, RANGE must include both 
%             corners and a colon character (:), even for a single cell
%             (such as 'D2:D2').
%           * If RANGE is larger than the size of ARRAY, Excel fills the
%             remainder of the region with #N/A. If RANGE is smaller than
%             the size of ARRAY, XLWRITE writes only the subset that fits
%             into RANGE to the file.
%
%   Note
%   * This function requires the POI library to be in your javapath.
%     To add the Apache POI Library execute commands: 
%     (This assumes the POI lib files are in folder 'poi_library')
%       javaaddpath('poi_library/poi-3.8-20120326.jar');
%       javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
%       javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
%       javaaddpath('poi_library/xmlbeans-2.3.0.jar');
%       javaaddpath('poi_library/dom4j-1.6.1.jar');
%   * Excel converts Inf values to 65535. XLWRITE converts NaN values to
%     empty cells.
%
%   EXAMPLES
%   % Write a 7-element vector to testdata.xls:
%   xlwrite('testdata.xls', [12.7, 5.02, -98, 63.9, 0, -.2, 56])
%
%   % Write mixed text and numeric data to testdata2.xls
%   % starting at cell E1 of Sheet1:
%   d = {'Time','Temperature'; 12,98; 13,99; 14,97};
%   xlwrite('testdata2.xls', d, 1, 'E1')
%
%
%   REVISIONS
%   20121004 - First version using JExcelApi
%   20121101 - Modified to use POI library instead of JExcelApi (allows to
%           generate XLSX)
%   20121127 - Fixed bug: use existing rows if present, instead of 
%           overwrite rows by default. Thanks to Dan & Jason.
%   20121204 - Fixed bug: if a numeric sheet is given & didn't exist,
%           an error was returned instead of creating the sheet. Thanks to Marianna
%   20130106 - Fixed bug: use existing cell if present, instead of
%           overwriting. This way original XLS formatting is kept & not
%           overwritten.
%   20130125 - Fixed bug & documentation. Incorrect working of NaN. Thanks Klaus
%   20130227 - Fixed bug when no sheet number given & added Stax to java
%               load. Thanks to Thierry
%
%   Copyright 2012-2013, Alec de Zegher
%==============================================================================

% Check if POI lib is loaded
if exist('org.apache.poi.ss.usermodel.WorkbookFactory', 'class') ~= 8 ...
    || exist('org.apache.poi.hssf.usermodel.HSSFWorkbook', 'class') ~= 8 ...
    || exist('org.apache.poi.xssf.usermodel.XSSFWorkbook', 'class') ~= 8
    
    error('xlWrite:poiLibsNotLoaded',...
        'The POI library is not loaded in Matlab.\nCheck that POI jar files are in Matlab Java path!');
end

% Import required POI Java Classes
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.xssf.usermodel.*;
import org.apache.poi.ss.usermodel.*;

import org.apache.poi.ss.util.*;

status=0;

% If no sheet & xlrange is defined, attribute an empty value to it
if nargin < 3; sheet = []; end
if nargin < 4; range = []; end

% Check if sheetvariable contains range data
if nargin < 4 && ~isempty(strfind(sheet,':'))
    range = sheet;
    sheet = [];
end

% check if input data is given
if isempty(A)
    error('xlwrite:EmptyInput', 'Input array is empty!');
end
% Check that input data is not bigger than 2D
if ndims(A) > 2
	error('xlwrite:InputDimension', ...
        'Dimension of input array should not be higher than two.');
end

% Set java path to same path as Matlab path
java.lang.System.setProperty('user.dir', pwd);

% Open a file
xlsFile = java.io.File(filename);

% If file does not exist create a new workbook
if xlsFile.isFile()
    % create XSSF or HSSF workbook from existing workbook
    fileIn = java.io.FileInputStream(xlsFile);
    xlsWorkbook = WorkbookFactory.create(fileIn);
else
    % Create a new workbook based on the extension. 
    [~,~,fileExt] = fileparts(filename);
    
    % Check based on extension which type to create. If no (valid)
    % extension is given, create XLSX file
    switch lower(fileExt)
        case '.xls'
            xlsWorkbook = HSSFWorkbook();
        case '.xlsx'
            xlsWorkbook = XSSFWorkbook();
        otherwise
            xlsWorkbook = XSSFWorkbook();
            
            % Also update filename with added extension
            filename = [filename '.xlsx'];
    end
end

% If sheetname given, enter data in this sheet
if ~isempty(sheet)
    if isnumeric(sheet)
        % Java uses 0-indexing, so take sheetnumer-1
        % Check if the sheet can exist 
        if xlsWorkbook.getNumberOfSheets() >= sheet && sheet >= 1
            xlsSheet = xlsWorkbook.getSheetAt(sheet-1);
        else
            % There are less number of sheets, that the requested sheet, so
            % return an empty sheet
            xlsSheet = [];
        end
    else
        xlsSheet = xlsWorkbook.getSheet(sheet);
    end
    
    % Create a new sheet if it is empty
    if isempty(xlsSheet)
        warning('xlwrite:AddSheet', 'Added specified worksheet.');
        
        % Add the sheet
        if isnumeric(sheet)
            xlsSheet = xlsWorkbook.createSheet(['Sheet ' num2str(sheet)]);
        else
            % Create a safe sheet name
            sheet = WorkbookUtil.createSafeSheetName(sheet);
            xlsSheet = xlsWorkbook.createSheet(sheet);
        end
    end
    
else
    % check number of sheets
    nSheets = xlsWorkbook.getNumberOfSheets();
    
    % If no sheets, create one
    if nSheets < 1
        xlsSheet = xlsWorkbook.createSheet('Sheet 1');
    else
        % Select the first sheet
        xlsSheet = xlsWorkbook.getSheetAt(0);
    end
end

% if range is not specified take start row & col at A1
% locations are 0 indexed
if isempty(range)
    iRowStart = 0;
    iColStart = 0;
    iRowEnd = size(A, 1)-1;
    iColEnd = size(A, 2)-1;
else
    % Split range in start & end cell
    iSeperator = strfind(range, ':');
    if isempty(iSeperator)
        % Only start was defined as range
        % Create a helper to get the row and column
        cellStart = CellReference(range);
        iRowStart = cellStart.getRow();
        iColStart = cellStart.getCol();
        % End column calculated based on size of A
        iRowEnd = iRowStart + size(A, 1)-1;
        iColEnd = iColStart + size(A, 2)-1;
    else
        % Define start & end cell
        cellStart = range(1:iSeperator-1);
        cellEnd = range(iSeperator+1:end);
        
        % Create a helper to get the row and column
        cellStart = CellReference(cellStart);
        cellEnd = CellReference(cellEnd);
        
        % Get start & end locations
        iRowStart = cellStart.getRow();
        iColStart = cellStart.getCol();
        iRowEnd = cellEnd.getRow();
        iColEnd = cellEnd.getCol();
    end
end

% Get number of elements in A (0-indexed)
nRowA = size(A, 1)-1;
nColA = size(A, 2)-1;

% If data is a cell, convert it
if ~iscell(A)
    A = num2cell(A);
end

% Iterate over all data
for iRow = iRowStart:iRowEnd
    % Fetch the row (if it exists)
    currentRow = xlsSheet.getRow(iRow); 
    if isempty(currentRow)
        % Create a new row, as it does not exist yet
        currentRow = xlsSheet.createRow(iRow);
    end
    
    % enter data for all cols
    for iCol = iColStart:iColEnd
        % Check if cell exists
        currentCell = currentRow.getCell(iCol);
        if isempty(currentCell)
            % Create a new cell, as it does not exist yet
            currentCell = currentRow.createCell(iCol);
        end
        
        % Check if we are still in array A
        if (iRow-iRowStart)<=nRowA && (iCol-iColStart)<=nColA
            % Fetch the data
            data = A{iRow-iRowStart+1, iCol-iColStart+1};
            
            if ~isempty(data)          
                % if it is a NaN value, convert it to an empty string
                if isnumeric(data) && isnan(data)
                    data = '';
                end
                
                % Write data to cell
                currentCell.setCellValue(data);
            end

        else
            % Set field to NA
            currentCell.setCellErrorValue(FormulaError.NA.getCode());
        end
    end
end

% Write & close the workbook
fileOut = java.io.FileOutputStream(filename);
xlsWorkbook.write(fileOut);
fileOut.close();

status = 1;

end