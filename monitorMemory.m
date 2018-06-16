%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% VERSIONING:
% 20160218: Initial version
%
% Author: LAURENT HEIRENDT - LCSB - Luxembourg
%
% PURPOSE: Monitor the memory usage inside the workspace and sum up the bytes
% OUTPUT: Memory usage in MB
%
% Note: Slight modifications of the monitor_memory_whos() function ...
% from MatlabCentral by Nicha Dvornek
%
% www.mathworks.com/matlabcentral/fileexchange/ ...
% 50091-subspaceem--a-fast-maximum-a-posteriori-algorithm-for-cryo-em-single-particle-reconstruction/content/Utils/monitor_memory_whos.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ memoryInUse ] = monitorMemory( )

	mem_elements = evalin('base','whos');

	N = size(mem_elements,1);

	if N > 0
		for i = 1:N
			memory_array(i) = mem_elements(i).bytes;
		end

		memoryInUse = sum(memory_array);
		memoryInUse = memoryInUse/1048576;
	else
		memoryInUse = 0;
	end
