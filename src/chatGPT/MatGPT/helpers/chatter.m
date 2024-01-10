classdef chatter < chatGPT
    %CHATTER extends chatGPT superclass
    %   This subclass adds a new method 'injectChatLog'

    methods
        function responseText = chat(obj,prompt,options)
            %CHAT This send http requests to the api
            %   Pass the prompt as input argument to send the request
            %   Only messages with valid roles are sent in messages object
            arguments
                obj
                prompt string {mustBeTextScalar}
                options.timeout double {mustBeScalarOrEmpty}
                options.stop string {mustBeText,mustBeNonzeroLengthText}
            end

            % retrieve API key from the environment
            api_key = getenv("OPENAI_API_KEY");
            if isempty(api_key)
                id = "chatter:missingKey";
                msg = "No API key found in the enviroment variable" + newline;
                msg = msg + "Before using, set an environment variable ";
                msg = msg + "with your OpenAI API key as 'MY_OPENAI_KEY'";
                msg = msg + newline + newline + "setenv('MY_OPENAI_KEY','your key here')";
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

            % extract messages with valid roles
            m = obj.messages;
            roles = arrayfun(@(x) string(x.role),m);
            m(~ismember(roles,["system","user","assistant"])) = [];
            % shorten calls to MATLAB HTTP interfaces
            import matlab.net.*
            import matlab.net.http.*
            % construct http message content
            % 
            if isfield(options,'stop')
                query = struct('model',obj.model,'messages',m,'max_tokens',obj.max_tokens,'temperature',obj.temperature,'stop',options.stop);
            else
                query = struct('model',obj.model,'messages',m,'max_tokens',obj.max_tokens,'temperature',obj.temperature);
            end            
            % the headers for the API request
            headers = HeaderField('Content-Type', 'application/json');
            headers(2) = HeaderField('Authorization', "Bearer " + api_key);
            % the request message
            request = RequestMessage('post',headers,query);

            % Create a HTTPOptions object; set proxy in MATLAB Web Preferences if needed
            httpOpts = matlab.net.http.HTTPOptions;
            % Set the ConnectTimeout option to 30 seconds
            if isfield(options,'timeout') && options.timeout > 0
                httpOpts.ConnectTimeout = options.timeout;
            end
            % send the request and store the response
            response = send(request, URI(obj.api_endpoint),httpOpts);

            % extract the response text
            if response.StatusCode == "OK"
                % extract text from the response
                responseText = response.Body.Data.choices(1).message;
                responseText = string(responseText.content);
                responseText = strtrim(responseText);
                % add the text to the messages with 'assistant' role
                obj.messages = [obj.messages, ...
                    struct('role',"assistant",'content',responseText)];
                % add the numbers of tokens used
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
                if string(response.StatusCode) == "401"
                    responseText = responseText + newline + "Check your API key.";
                    responseText = responseText + newline + "You may have an invalid API key.";
                elseif string(response.StatusCode) == "404"
                    responseText = responseText + newline + "You may not have access to the model: " + ...
                        obj.model + ". Consider using another model.";
                elseif string(response.StatusCode) == "429"
                    responseText = responseText + newline + "You exceeded the API limit. Your free trial for OpenAI API may have expired.";
                end
                id = "chatter:invalidKey";
                ME = MException(id,responseText);
                throw(ME)
            end
        end

        function injectChatLog(obj,role,content)
            %INJECTCHATLOG injects a message into messages object
            %   This method add a new message externally that hold
            %   information for display or record keeping and not to be
            %   sent to ChatGPT API. 
            %   role must be something other than system, user or
            %   assistant.
            if ~ismember(role, ["system","user","assistant"])
                obj.messages = [obj.messages,struct('role',role,'content',content)];
            end
        end
    end
end