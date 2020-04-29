function writeMoominOutput(model, fileName, varargin)
% Writes the output of MOOMIN into a text file.
%
% USAGE:
%
%    writeMoominOutput(model, fileName, varargin)
%
% INPUTS:
%    model:         COBRA model structure output by MOOMIN
%    filename:      name of the output file
%
% Optional parameters can be entered the standard MATLAB way with parameter name followed
% by parameter value: i.e. ,'nSolution', 3)
%
% OPTIONAL INPUTS
%    nSolution:     number of the solution that is output (default 1)
%    format:        control the output format
%
%                    * 'standard': default output, a tab-delimited file giving output
%                                  colours for reactions for one solution
%                    * 'full': a tab-delimited file listing one solution as well as other
%                              information
%                    * 'json': a .json file of colours for one solution
%    type:          choose which kind of solution is written
%
%                    * 'output': one solution, as specified by nSolution (default)
%                    * 'input': input ie a priori colours
%                    * 'combined': consensus (combination of all optimal solutions found)
%                    * 'frequency': how often a reaction is coloured
%    string         Boolean to control if colours are written out or coded by numbers (default 1)
%
% .. Author: - Taneli Pusa 09/2019

	if ~isfield(model,'outputColours') || isempty(model.outputColours)
		error('Model contains no solutions.');
	end

	nSolution = 1;
	fileFormat = 'standard';
	solutionType = 'output';
	writeAsString = 1;
	
	if ~isempty(varargin)
		if rem(size(varargin, 2), 2) ~= 0
			error('Check optional inputs.');
		else
			for i = 1:2:size(varargin, 2)
				switch varargin{1, i}
					case 'nSolution'
						nSolution = varargin{1, i + 1};
						if nSolution > size(model.outputColours, 2)
							error('There are only %d solutions.', size(model.outputColours, 2));
						end
					case 'format'
						fileFormat = varargin{1, i + 1};
					case 'type'
						solutionType = varargin{1, i + 1};
					case 'string'
						writeAsString = varargin{1, i + 1};
					otherwise
						error('Could not recognise optional input names.\nNo input named "%s"',...
							varargin{1, i});
				end
			end
		end
	end
	
	IDlist = cellfun(@(x) strcat('R_', x), model.rxns, 'UniformOutput', false);

	inputAsString = coloursAsString(model.inputColours);
	outputAsString = coloursAsString(model.outputColours(:, nSolution));
	
	if strcmp(fileFormat, 'full')
		[weight, sortByWeight] = sort(model.weights, 'descend');
		ID = IDlist(sortByWeight);
		output = model.outputColours(sortByWeight, :);
		output = output(:, nSolution);
		input = model.inputColours(sortByWeight);
		leadingGeneInds = model.leadingGenes(sortByWeight);
		leadingGene = {};
		FC = {};
		for i = 1:size(leadingGeneInds, 1)
			if leadingGeneInds(i) > 0
				leadingGene = [leadingGene;...
					model.expression.GeneID(leadingGeneInds(i), :)];
				FC = [FC; model.expression.FC(leadingGeneInds(i), 1)];
			else
				leadingGene = [leadingGene; 'NA'];
				FC = [FC; 'NA'];
			end
		end
		name = model.rxnNames(sortByWeight);
		model = creategrRulesField(model);
		GPR = model.grRules(sortByWeight);
		subsystem = model.subSystems(sortByWeight);
		frequency = model.frequency(sortByWeight);
		consensus = model.combined(sortByWeight);
		if writeAsString
			output = coloursAsString(output);
			input = coloursAsString(input);
			consensus = coloursAsString(consensus);
		end
		outputTable = table(ID, name, input, output, consensus, frequency,...
			weight, GPR, subsystem, leadingGene, FC);
		writetable(outputTable, fileName, 'Delimiter', '\t', 'FileType', 'text');
	else
		switch solutionType
			case 'output'
				output = model.outputColours(:, nSolution);
			case 'input'
				output = model.inputColours;
			case 'combined'
				output = model.combined;
			case 'frequency'
				output = model.frequency;
			otherwise
				error('Unknown type option "%s"', solutionType);
		end
		if writeAsString && ~strcmp(solutionType, 'frequency')
			output = coloursAsString(output);
		end
		switch fileFormat
			case 'json'
				jsonStr = '{';
				outPutIsNumeric = isnumeric(output(1));
				for reacInd = 1:size(model.rxns ,1) - 1
					if outPutIsNumeric
						colourStr = num2str(output(reacInd));
					else
						colourStr = output{reacInd, 1};
					end
					jsonStr = [jsonStr, '"', model.rxns{reacInd, 1}, '": ',...
						colourStr, ', '];
				end
				if outPutIsNumeric
					colourStr = num2str(output(end));
				else
					colourStr = output{end, 1};
				end
				jsonStr = [jsonStr, '"', model.rxns{end, 1}, '": ',...
					colourStr, '}'];
				fileID = fopen(fileName, 'w');
				fprintf(fileID, jsonStr);
				fclose(fileID);
			case 'standard'
				outputTable = table(IDlist, output, 'variableNames', {'rxnID', solutionType});
				writetable(outputTable, fileName, 'Delimiter', '\t', 'FileType', 'text');
			otherwise
				error('Unknown format option "%s"', fileFormat);
		end
	end
end

function colours = coloursAsString(colourVector)
% auxiliary function to turn reaction colour numbers into string format

	colours = {};
	
	for ind = 1:size(colourVector, 1)
		switch colourVector(ind)
		case 2
			colours = [colours; 'r.red'];
		case 1
			colours = [colours; 'red'];
		case 0
			colours = [colours; 'grey'];
		case -1
			colours = [colours; 'blue'];
		case -2
			colours = [colours; 'r.blue'];
		case 6
			colours = [colours; 'yellow'];
		end
	end
end
	
	
	