% LOGINDLG   Dialog for visually secure login.
%   Examples:
%       [login password] = logindlg('Title','Login Title');  % Returns the login and
%          password with the dialog title 'Login Title'.
%
%       password = logindlg;  % Returns only the password with a default
%          dialog title.
%
%       password = logindlg('Password','only');  % Displays only a password
%          edit box and returns the password.
%
%       password = logindlg('Title','Login Title','Password','only');
%          % Creates a password only dialog with 'Login Title' as the
%          dialog title.
%
%
%
%
% Author: Jeremy Smith
% Date: September 24, 2005
% Last Edit: January 28, 2010
% Version: 1.3
% Tested on: Matlab 7.0.4.365 (R14) Service Pack 2, Matlab 7.1 SP 3, and
%       Matlab 7.4.0.287 (R2007a)
% Description: custom login dialog because Matlab doesn't have an option
%       for characters in an edit field to be replaced by asterisks
%       (password security).
%
%       Note:  On very slow computers the first few password characters may 
%       have a delay before they are converted to asterisks.

% Changelist:
%   1.3: -Pressing the Escape key with focus anywhere on the dialog will
%            now cancel the dialog box
%        -Typo correction
%        -Escape no longer creates an empty character in the password field
%   1.2: -Tab no longer triggers the OK button in the password box
%        -Improved the script help
%        -Removed horizontal alignment from buttons
%        -Added the option to display only the password box
%   1.1: -Added positioning code so it'll display in the center of the screen
%        -If only one output is specified the password will be returned
%            instead of the login as in Version 1.0
%        -Escape will not only close the dialog if neither edit box is active
%        -When the dialog appears the first edit box will be active
%        -Added a few more comments
%        -Removed the clc, it was left in by mistake in Version 1.0

function [varargout]=logindlg(varargin)

% Number of inputs check
if nargin ==  0 || nargin == 2 || nargin == 4
else
    error('Incorrect number of input arguments.')
end

% Input Type Check
for i=1:1:length(varargin)
    if ~ischar(varargin{i})
        error('Inputs must be strings.')
    end
end

% Title Option
if nargin == 0
    Title = 'Login';
elseif nargin == 2 && ~isempty(strmatch('title',lower(varargin)))
    Title = varargin{2};
elseif nargin == 2 && isempty(strmatch('title',lower(varargin)))
    Title = 'Login';
elseif nargin == 4 && ~isempty(strmatch('title',lower(varargin)))
    S = strmatch('title',lower(varargin));
    if S == 1
        Title = varargin{2};
    elseif S == 3
        Title = varargin{4};
    else
        error('Invalid title.')
    end
else
    error('Invalid title.')
end

% Password Option
if nargin == 0
    Pass = 0;
elseif nargin == 2 && ~isempty(strmatch('password',lower(varargin{1}))) && ~isempty(strmatch('only',lower(varargin{2})))
    Pass = 1;
elseif nargin == 4 && ~isempty(strmatch('password',lower(varargin))) && ~isempty(strmatch('only',lower(varargin)))
    P = strmatch('password',lower(varargin));
    O = strmatch('only',lower(varargin));
    if P == 1 && O == 2
        Pass = 1;
    elseif P == 3 && O == 4
        Pass = 1;
    end
elseif nargin == 2 && isempty(strmatch('password',lower(varargin))) == 1
    Pass = 0;
else
    error('Invalid password option.')
end

% Output Error Check
if nargout > 1 && Pass == 1 || nargout > 2
    error('Too many output arguments.')
end

% Get Properties
Color = get(0,'DefaultUicontrolBackgroundcolor');

% Determine the size and position of the login interface
if Pass == 0
    Height = 9.5;
else
    Height = 5.5;
end
set(0,'Units','characters')
Screen = get(0,'screensize');
Position = [Screen(3)/2-17.5 Screen(4)/2-4.75 35 Height];
set(0,'Units','pixels')

% Create the GUI
gui.main = dialog('HandleVisibility','on',...
    'IntegerHandle','off',...
    'Menubar','none',...
    'NumberTitle','off',...
    'Name','Login',...
    'Tag','logindlg',...
    'Color',Color,...
    'Units','characters',...
    'Userdata','logindlg',...
    'Position',Position);

% Set the title
if ischar(Title) == 1
    set(gui.main,'Name',Title,'Closerequestfcn',{@Cancel,gui.main},'Keypressfcn',{@Escape})
end

% Texts
if Pass == 0
    gui.login_text = uicontrol(gui.main,'Style','text','FontSize',8,'HorizontalAlign','left','Units','characters','String','Login','Position',[1 7.65 20 1]);
end
gui.password_text = uicontrol(gui.main,'Style','text','FontSize',8,'HorizontalAlign','left','Units','characters','String','Password','Position',[1 4.15 20 1]);

% Edits
if Pass == 0
    gui.edit1 = uicontrol(gui.main,'Style','edit','FontSize',8,'HorizontalAlign','left','BackgroundColor','white','Units','characters','String','','Position',[1 6.02 33 1.7],'KeyPressfcn',{@Escape});
end
gui.edit2 = uicontrol(gui.main,'Style','edit','FontSize',8,'HorizontalAlign','left','BackgroundColor','white','Units','characters','String','','Position',[1 2.52 33 1.7],'KeyPressfcn',{@KeyPress_Function,gui.main},'Userdata','');

% Buttons
gui.OK = uicontrol(gui.main,'Style','push','FontSize',8,'Units','characters','String','OK','Position',[12 .2 10 1.7],'Callback',{@OK,gui.main},'KeyPressfcn',{@Escape});
gui.Cancel = uicontrol(gui.main,'Style','push','FontSize',8,'Units','characters','String','Cancel','Position',[23 .2 10 1.7],'Callback',{@Cancel,gui.main},'KeyPressfcn',{@Escape});

setappdata(0,'logindlg',gui) % Save handle data
setappdata(gui.main,'Check',0) % Error check setup. If Check remains 0 an empty cell array will be returned

if Pass == 0
    uicontrol(gui.edit1) % Make the first edit box active
else
    uicontrol(gui.edit2)  % Make the second edit box active if the first isn't present
end

% Pause the GUI and wait for a button to be pressed
uiwait(gui.main)

Check = getappdata(gui.main,'Check'); % Check to see if a button was pressed

% Format output
if Check == 1
    if Pass == 0
        Login = get(gui.edit1,'String');
    end
    Password = get(gui.edit2,'Userdata');
    
    if nargout == 1 % If only one output specified output Password
        varargout(1) = {Password};
    elseif nargout == 2 % If two outputs specified output both Login and Password
        varargout(1) = {Login};
        varargout(2) = {Password};
    end
else % If OK wasn't pressed output nothing
    if nargout == 1
        varargout(1) = {[]};
    elseif nargout == 2
        varargout(1) = {[]};
        varargout(2) = {[]};
    end
end

delete(gui.main) % Close the GUI
setappdata(0,'logindlg',[]) % Erase handles from memory

%% Hide Password
function KeyPress_Function(h,eventdata,fig)
% Function to replace all characters in the password edit box with
% asterisks
password = get(h,'Userdata');
key = get(fig,'currentkey');

switch key
    case 'backspace'
        password = password(1:end-1); % Delete the last character in the password
    case 'return'  % This cannot be done through callback without making tab to the same thing
        gui = getappdata(0,'logindlg');
        OK([],[],gui.main);
    case 'tab'  % Avoid tab triggering the OK button
        gui = getappdata(0,'logindlg');
        uicontrol(gui.OK);
    case 'escape'
        % Close the login dialog
        Escape(fig,[])
    otherwise
        password = [password get(fig,'currentcharacter')]; % Add the typed character to the password
end

SizePass = size(password); % Find the number of asterisks
if SizePass(2) > 0
    asterisk(1,1:SizePass(2)) = '*'; % Create a string of asterisks the same size as the password
    set(h,'String',asterisk) % Set the text in the password edit box to the asterisk string
else
    set(h,'String','')
end

set(h,'Userdata',password) % Store the password in its current state

%% Cancel
function Cancel(h,eventdata,fig)
uiresume(fig)

%% OK
function OK(h,eventdata,fig)
% Set the check and resume
setappdata(fig,'Check',1)
uiresume(fig)

%% Escape
function Escape(h,eventdata)
% Close the login if the escape button is pushed and neither edit box is
% active
fig = h;
while ~strcmp(get(fig,'Type'),'figure')
    fig = get(fig,'Parent');
end
key = get(fig,'currentkey');

if isempty(strfind(key,'escape')) == 0
    Cancel([],[],fig)
end