classdef chatGPT < handle
    %CHATGPT defines a class to access ChatGPT API
    %   Create an instance using your own API key, and optionally
    %   max_tokens that determine the length of the response
    %
    %   chat method lets you send a prompt text to the API as HTTP request
    %   and parses the response.
    %
    %   Before using, set an environment variable with your OpenAI API key
    %   named OPENAI_API_KEY
    %   
    %   setenv("OPENAI_API_KEY","your key here")

    properties (Access = public)
        % the API endpoint
        api_endpoint = "https://api.openai.com/v1/chat/completions";
        % ChatGPT model to use - gpt-3.5-turbo, etc.
        model;
        % what role the bot should play
        role;
        % the max length of response
        max_tokens;
        % temperature = 0 precise, = 1 balanced, = 2 creative
        temperature;
        % store chat log in messages object
        messages;
        % store usage
        completion_tokens = 0;
        prompt_tokens = 0;
        total_tokens = 0;
    end

    methods
        function obj = chatGPT(options)
            %CHATGPT Constructor method to create an instance
            %   Set up an instance with optional parameters

            arguments
                options.model string {mustBeTextScalar, ...
                    mustBeMember(options.model, ...
                    ["gpt-3.5-turbo","gpt-3.5-turbo-0613", ...
                    "gpt-4","gpt-4-0613", ...
                    "gpt-4-32k","gpt-4-32k-0613"])} = "gpt-3.5-turbo";
                options.role string {mustBeTextScalar} = ...
                    "You are a helpful assistant.";
                options.max_tokens (1,1) double {mustBeNumeric, ...
                    mustBeLessThan(options.max_tokens,4096)} = 1000;
                options.temperature (1,1) double {mustBeNumeric, ...
                    mustBeInRange(options.temperature,0,2)} = 1;
            end

            obj.model = options.model;
            obj.role = options.role;
            obj.max_tokens = options.max_tokens;
            obj.temperature = options.temperature;
            obj.messages = struct('role',"system",'content',obj.role);
        end

        function responseText = chat(obj,prompt)
            %CHAT This send http requests to the api
            %   Pass the prompt as input argument to send the request

            arguments
                obj
                prompt string {mustBeTextScalar}
            end

            % retrieve API key from the environment
            api_key = getenv("OPENAI_API_KEY");
            if isempty(api_key)
                id = "chatGPT:missingKey";
                msg = "No API key found in the enviroment variable" + newline;
                msg = msg + "Before using, set an environment variable ";
                msg = msg + "with your OpenAI API key as 'MY_OPENAI_KEY'";
                msg = msg + newline + newline + "setenv('OPENAI_API_KEY','your key here')";
                ME = MException(id,msg);
                throw(ME)
            end

            % constructing messages object that retains the chat history
            % send user prompt with 'user' role
            if ~isempty(obj.messages)
                obj.messages = [obj.messages, ...
                    struct('role',"user",'content',prompt)];
            else
                obj.messages = struct('role',"user",'content',prompt);
            end
    
            % shorten calls to MATLAB HTTP interfaces
            import matlab.net.*
            import matlab.net.http.*
            % construct http message content
            query = struct('model',obj.model,'messages',obj.messages,'max_tokens',obj.max_tokens,'temperature',obj.temperature);
            % the headers for the API request
            headers = HeaderField('Content-Type', 'application/json');
            headers(2) = HeaderField('Authorization', "Bearer " + api_key);
            % the request message
            request = RequestMessage('post',headers,query);
            % send the request and store the response
            response = send(request, URI(obj.api_endpoint));
            % extract the response text
            if response.StatusCode == "OK"
                % extract text from the response
                responseText = response.Body.Data.choices(1).message;
                responseText = string(responseText.content);
                responseText = strtrim(responseText);
                % add the text to the messages with 'assistant' role
                obj.messages = [obj.messages, ...
                    struct('role',"assistant",'content',responseText)];
                % add the tokens used
                obj.completion_tokens = obj.completion_tokens + ...
                    response.Body.Data.usage.completion_tokens;
                obj.prompt_tokens = obj.prompt_tokens + ...
                    response.Body.Data.usage.prompt_tokens;
                obj.total_tokens = obj.total_tokens + ...
                    response.Body.Data.usage.total_tokens;
            else
                responseText = "Error ";
                responseText = responseText + response.StatusCode + newline;
                responseText = responseText + response.StatusLine.ReasonPhrase;
            end
        end

        function [completion_tokensd, prompt_tokens, total_tokens] = usage(obj)
            %USAGE retunrs the number of tokens used
            completion_tokensd = obj.completion_tokens;
            prompt_tokens = obj.prompt_tokens;
            total_tokens = obj.total_tokens;
        end

        function saveChat(obj,options)
            %SAVECHAT saves the chat history in a file 
            % Specify the format using .mat, .xlsx or .json
            arguments
                obj
                options.format string {mustBeTextScalar, ...
                    mustBeMember(options.format, ...
                    [".mat",".xlsx",".json"])} = ".mat";
            end
            if isempty(obj.messages)
                warning("No chat history.")
            else
                if options.format == ".mat"
                    s = obj.messages;
                    save("chathistory.mat","s")
                elseif options.format == ".xlsx"
                    tbl = struct2table(obj.messages);
                    writetable(tbl,"chathistory.xlsx")
                elseif options.format == ".json"
                    json = jsonencode(obj.messages);
                    writelines(json,"chathistory.json")
                else
                    error("Unknown format.")
                end
            end

        end

    end
end