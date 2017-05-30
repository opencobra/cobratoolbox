# Documentation guide

To enable automatic documentation generation the function has to be formatted properly.
Automatic documentation works on any comments that are placed between the function header and the first line of code. Anything starting with the comment sign `%` will be taken into consideration. There should be one free space between `%` and the text.
````Matlab
% this is correct

%this is not correct
````
Please leave a space after every coma and before and after `=`. Do not leave it inside braces `{}, [], ()`.
````Matlab
function [output1, output2, output3] = someFunction(input1, input2, input3) % good practice

function [ output1,output2,output3 ]=someFunction( input1,input2,input3 ) % bad practice
````
The description begins with a short explanation of what the function does.
After the last line of comment leave one empty line before the body of the function.
````Matlab
function [output1, output2, output3] = someFunction(input1, input2, input3)
% This is a description of the function that helps understand how the function works
% Here the description continues, then we leave an empty comment line
%
% Here additional comment blocks are used

x = 5; % the body of the function begins after one empty line
````
## Comments blocks
Recognized fields that will be extracted as separate blocks are: `USAGE:`, `INPUT:` or `INPUTS:` (in case there is more than one input arguement), `OUTPUT:`, `OUTPUTS:` (as mentioned before), `EXAMPLE:` and `NOTE:`.
Each of them should have  some elements inside and should be separated from another block by an empty line. Any element of the block must be indented by 4 spaces from the comment sign `%`.
````Matlab
% INPUTS:
%    input1:     Description of input1
%    input2:     Description of input2
% input3:    Description <-- this is bad practice
%
% OUTPUTS:
%    output1:    Description of output1
````
If the indentation differ between the line, the line with less indentation will break those with more.
### `USAGE:`
Block `USAGE:` shows how the function should be used. It is important to leave one empty line before using `USAGE:`, after using the keyword and after the example.
````Matlab
% the end of the description
%
% USAGE:
%
%    [output1, output2, output3] = someFunction(input1, input2, input3)
%
% here the other section can begin
````
### `INPUT: / OUTPUT:`
The elements of blocks: `INPUT:`, `INPUTS:`, `OUTPUT:` and `OUTPUTS:` must finish with a colon `:`, after that a description is provided. The indentation between the argument with colon and the description should be minimally 4 spaces. Ideally descriptions begin at the same place, so arguments with shorter names have a longer free space before the description begins.
````Matlab
% INPUTS:
%    input1:     Description of input1 <-- good practice
%    input2      No colon <-- bad practice
%    input3: Not enough distance (4+ spaces) <-- bad practice
%
% OUTPUTS:
%    longerNameOutput:    Description of longerNameOutput after 4 spaces
%    output1:             Description begins at the same place as the longest argument <-- good practice
%    output2:    Description begins too soon <-- bad practice
````
In case arguments are structures and it is needed to present the fields of the structure it is possible to list them. To do that an empty line is added and then in the next line after a small indent - 2 spaces, we list the sub-arguments beginning with a `*` and a space. It is not necessary to leave an empty line after listing sub-arguments and writing the next normal argument.
````Matlab
% OUTPUT:
%    output:    contains three fields:
%
%                 * .field1 - first field of the structure.
%               * .field2 - no indent <-- bad practice
%                 * .field3 - multi-line comment must begin always
%                   where the text of the first line begins <-- good practice
%                 * .field4 - multi-line comment where
%                 the text in line 2 begins too soon <-- bad practice
%    next:      next argument can be added without empty line
````
It is also possible to replace `*` with a numbered list. To do that use numbers with a dot `1.` instead of `*`.
````Matlab
% OPTIONAL INPUT:
%    input:    contains fields:
%
%                1. first element of a numbered list
%                2. second element of a numbered list
````
### `EXAMPLE:`
To provide a real example of usage the `EXAMPLE` block is given. It requires the same treating as `USAGE`. Leave one empty line before the keyword `EXAMPLE`, after it and after the properly indented (4 spaces) code snippet.
````Matlab
% here another block can end
%
% EXAMPLE:
%
%    result = someFunction(input1, input2)
%    %additional comment if necessary
%
% here another block can begin
````
### `NOTE:`
In case there is a very important information that could not be left in the description of the function, you can use the `NOTE:` block. Apply the same rules as with `USAGE` and `EXAMPLE` - empty lines and indentation. Remember that you can always include a normal text in the end as long as you leave one space free after the comment sign.
This is example of a `NOTE:` and normal text after all blocks.
````Matlab
%
% NOTE:
%
%    This is a note that contains a very important information.
%    It will be clearly visible in the documentation online.
%
% This is an additional final comment that is not important enough to be a note
% but cannot be a description
````
### `Author(s):`
To add the author follow one of two templates.
In case of only one author you can use the shorter version. Remember about the structure - one space , two dots `..`, one space, keyword `Author`, colon `:`.
````Matlab
%
% .. Author: - Name, date, additional information if needed

x = 5; % here the body of the function begins
````
In case there are more than one authors or the file was overhauled, improved, updated by multiple people use this version. Remember about equal indentation.
````Matlab
%
% .. Authors:
%       - Name1, date, additional information if needed
%       - Name2, date, additional information if needed <-- good practice of adding authors
% - Name3, date, no indent <-- bad practice
%
% Authors - no colon, no indent, no " .. " format <-- very bad practice
%       - Name1, date, additional information if needed

x = 5; % here the body of the function begins
````
## FULL EXAMPLE:
A complete example of a function is provided here. In case of doubts follow the formatting of the example. Remember about colons, indentations and keywords!
````Matlab
function [output1, output2] = someFunction(input1, input2, input3, input4)
% This is a description of the function that helps understand how the function works
% Here the description continues, then we leave an empty comment line
%
% USAGE:
%
%    [output1, output2] = someFunction(input1, input2, input3, input4)
%
% INPUTS:
%    input1:     Description of input1
%    input2:     Description of input2
%
% OPTIONAL INPUT:
%    input3:     Structure with fields:
%
%                       * First field - description
%                       * Second field - description
%    input4:     Description of input4
%
% OUTPUT:
%    output1:    Description of output1
%
% OPTIONAL OUTPUT:
%    output2:    Description of output2
%
% EXAMPLE:
%
%    %this could be an example that can be copied from the documentation to MATLAB
%    [output1, output2] = someFunction(11, '22', structure, [1;2])
%    %without optional values
%    output1 = someFunction(11, '22')
%
% NOTE:
%    This is a very important information to be highlighted
%
% This is a final comment that cannot be in the description but can be useful
%
% .. Author: - Name, date, some information
````
