classdef TextHelper
    %TEXTHELPER Collection of static methods for text processing
    %   TextHelper has multiple static methods that can be used for the
    %   weird text processing used by MatGPT

    methods (Access=public,Static)
        %% codeBlockPattern
        function [startPat,endPat] = codeBlockPattern()
            % CODEBLOCKPATTERN - text matching pattern for the code blocks in backticks
            %
            %   [startPat,endPat] = codeBlockPattern returns some start and end
            %   patterns for the backticks so you can use for

            % Code blocks start and end with 3 backticks
            backticks = "```";
            startPat = backticks + wildcardPattern + newline;
            endPat = newline + backticks + (newline|textBoundary);            
        end
       
        %% exceptionReport
        function report = shortErrorReport(ME)
            % shortErrorReport - get a shortened report from MException
            %
            %   report = shortErrorReport(ME) will use the getReport method
            %   from MException input and shorten it to show the error
            %   message and first stack entry

            % Get full report from MException object and remove HTML tags
            report = getReport(ME);
            report = TextHelper.removeHTMLtags(report);

            % Count occurrences of "Error" (how big is the Stack)
            errorPattern = "Error" + wildcardPattern(Except="Error");
            stackCount = count(report,errorPattern);

            % Construct pattern to match all but the first stack entry
            allButFirstError = asManyOfPattern(errorPattern,1,stackCount-1) + textBoundary;

            % Extract before the constructed pattern.            
            report = extractBefore(report,allButFirstError);
        end

        function str = removeHTMLtags(str)
            % removeHTMLtags - removes all HTML tags from a string. This is
            % usefull because MATLAB's error messages often come with
            % hyperlinks. This function removes them.
            htmlTags = "<" + wildcardPattern + ">";
            str = erase(str,htmlTags);
        end

        function newStr = replaceCodeMarkdown(str,options)
            % replaceCodeMarkdown - Replaces ``` markdown with <code> tags
            %
            %   newStr = replaceCodeMarkdown(str) will parse the input str
            %   and replace any code blocks enclosed in backticks ``` with
            %   <code> tags using the style class "code-block"
            %
            %   newStr = replaceCodeBlocks(___,type=T) specifies the type
            %   of markdown to replace or the specific tag used:
            %       "block"    - (default) code enclosed in "```"
            %       "inline"   - code enclosed in "`"
            %       T          - code enclosed in the string stored in T
            %
            %   newStr = replaceCodeBlocks(___,className=C) specifies the
            %   class name used in the code tag in a string. Default is
            %   "code-block"
            %
            %   Example input:
            %
            %       ```matlab
            %       x = 1;                   
            %       ```
            %
            %    Example output:
            %
            %       <code class="code-block">x=1;</code>
            %
            arguments
                str string {mustBeTextScalar}
                options.type string {mustBeTextScalar} = "block"
                options.className string {mustBeTextScalar} = "code-block";
            end

            switch options.type
                case "block"
                    [startTag,endTag] = TextHelper.codeBlockPattern();
                case "inline"
                    startTag = "`";
                    endTag = "`";
                otherwise
                    startTag = options.type;
                    endTag = options.type;
            end

            % Extract text with and without the tgs            
            textWithoutTags = extractBetween(str,startTag,endTag);
            textWithTags = extractBetween(str,startTag,endTag, ...
                Boundaries="inclusive");
            
            % Replace the blocks with backticks with alternae versions
            textWithCodeTags = "<code class=""" + options.className + """>" +  ...
                textWithoutTags + "</code>";
            newStr = replace(str,textWithTags,textWithCodeTags);
        end

        function newStr = replaceTableMarkdown(str)
            %REPLACETABLE replaces Markdown table with HTML table
            %   Accepts a scalar string array as input
            %   table must have the border for the header i.e. | --- |

            arguments
                str string {mustBeTextScalar}
            end

            % define table pattern
            tblpat = lineBoundary + "|" + (" "|"-") + wildcardPattern(1,Inf) + (" "|"-") + "|" + lineBoundary;
            % extract table
            tblstr = extract(str,tblpat);
            % table is not found, exit
            if isempty(tblstr)
                newStr = str;
                return
            end
            try
                % remove "|" at the beginning and end of a line
                tblBordersPat = [lineBoundary+"|","|"+lineBoundary];
                trimmedTbl = strtrim(erase(strtrim(tblstr), tblBordersPat));
                % split each line by "|"
                splittedTbl = arrayfun(@(x) (strtrim(split(x,"|")))', trimmedTbl, UniformOutput=false);
                % get the number of columns in each line
                numCols = cellfun(@numel, splittedTbl);
                % find the header separator
                separatorPat = optionalPattern(":") + asManyOfPattern(characterListPattern("-"),2) + optionalPattern(":");
                % the header is the 1 row up
                headerRowIdx = find(cellfun(@(x) all(contains(x,separatorPat)), splittedTbl),1) - 1;
                % lines with the same number of cols are in the table
                rowIdx = numCols == numCols(headerRowIdx);
                % extract table block and merge lines into a string
                tblBlock = splittedTbl(rowIdx);
                mergedTbl = vertcat(tblBlock{:});
                % extract header
                theader = string(mergedTbl(1,:));
                % extract body
                tbody = mergedTbl(3:end,:);
                % generate table header
                htmlTbl = "<table class='resp'>" + newline;
                htmlTbl = htmlTbl + "<thead>" + newline;
                htmlTbl = htmlTbl + "<tr>" + newline;
                for ii = 1:numel(theader)
                    htmlTbl = htmlTbl + "<th>" + theader(ii) + "</th>" + newline;
                end
                htmlTbl = htmlTbl + "</tr>" + newline;
                htmlTbl = htmlTbl + "</thead>" + newline;
                % generate table body
                htmlTbl = htmlTbl + "<tbody>" + newline;
                for ii = 1:size(tbody,1)
                    htmlTbl = htmlTbl + "<tr>" + newline;
                    for jj = 1:numel(theader)
                        htmlTbl = htmlTbl + "<td>" + tbody(ii,jj) + "</td>" + newline;
                    end
                    htmlTbl = htmlTbl + "</tr>" + newline;
                end
                htmlTbl = htmlTbl + "</tbody>" + newline;
                htmlTbl = htmlTbl + "</table>";
                % replace markdown table with html table
                newStr = replace(str,join(tblstr,newline),htmlTbl);
            catch
                % if error, return the original string
                newStr = str;
                return
            end
        end
    end
end