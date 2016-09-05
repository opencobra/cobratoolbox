%% Copyright (C) 2005 Axel von Kamp
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; if not, write to the Free Software
%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function freq_analysis(fid, sys)
  if fid == -1
    fid= 1; % stdout in Octave; seems to be accepted by Matlab as well
  end
  if isfield(sys, 'ext')
    stext= [sys.st; sys.ext];
  else
    stext= sys.st;
  end
  conn= sum(stext ~= 0, 2); % connectivity of the metabolites
  mc= max(conn);
  freq= zeros(1, mc);
  edge= zeros(1, mc);
  for i= 1:length(conn)
    c= conn(i);
    if c ~= 0 % do not include unused metabolites in statistics
      edge(c)= 1;
      freq(c)= freq(c) + 1;
    end
  end
  edge= find(edge);
  freq= freq(edge);
  if length(edge) < 2
    fprintf(fid, '\nThis network has only metabolites with connectivity %d.\n', edge);
    return;
  end
  edge= log(edge);
  freq= log(freq);
  b= polyfit(edge, freq, 1);
  cf= corrcoef(edge, freq);
  if ~exist('octave_config_info', 'builtin') % true when using MATLAB
    cf= cf(1,2);
  end
  fprintf(fid, '\nfreq_of_nodes = %.4g * edges^(%+.4g)\nLinear correlation coefficient: %.4g.\n', exp(b(2)), b(1), cf);
  
  Table_r_2sides= [
  5,  .754, .875, .951
  6,  .707, .834, .925
  7,  .666, .798, .898
  8,  .632, .765, .872
  9,  .602, .735, .847
  10, .576, .708, .823
  11, .553, .684, .801
  12, .532, .661, .780
  13, .514, .641, .760
  14, .497, .623, .742
  15, .482, .606, .725
  16, .468, .590, .708
  17, .456, .575, .693
  18, .444, .561, .679
  19, .433, .549, .665
  20, .423, .537, .652
  21, .413, .526, .640
  22, .404, .515, .629
  23, .396, .505, .618
  24, .388, .496, .607
  25, .381, .487, .597
  26, .374, .478, .588
  27, .367, .470, .579
  28, .361, .463, .570
  29, .355, .456, .562
  30, .349, .449, .554
  35, .325, .418, .519
  40, .304, .393, .490
  50, .273, .354, .443
  60, .250, .325, .408
  70, .232, .302, .380
  80, .217, .283, .357
  90, .205, .267, .338
 100, .195, .254, .321
 120, .178, .232, .294
 150, .159, .208, .263
 200, .138, .181, .230
 250, .124, .162, .206
 300, .113, .148, .188
 350, .105, .137, .175
 400, .098, .128, .164
 500, .088, .115, .146
 700, .074, .097, .124
1000, .062, .081, .104
1500, .050, .066, .085
2000, .044, .058, .073 ];

  n= length(edge) - 2;
  i= 1;
  while i <= 46
    if Table_r_2sides(i, 1) >= n
      break;
    end
    i= i + 1;
  end
  switch sum(Table_r_2sides(i, 2:4) < abs(cf))
    case 1
      fprintf(fid, 'The dependency is significant (p < 0.05).\n');
    case 2
      fprintf(fid, 'The dependency is significant (p < 0.01).\n');
    case 3
      fprintf(fid, 'The dependency is significant (p < 0.001).\n');
    otherwise
      fprintf(fid, 'The dependency is not significant (p > 0.05).\n');
  end
  fprintf(fid, '\n');
