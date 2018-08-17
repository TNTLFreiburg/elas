function varargout = welcome_elas(varargin)

% FUNCTION to start ELAS user interface
%
% DESCRIPTION
%      WELCOME_ELAS, by itself, creates a new WELCOME_ELAS or raises the existing
%      singleton*.
%
%      H = WELCOME_ELAS returns the handle to a new WELCOME_ELAS or the handle to
%      the existing singleton*.
%
%      WELCOME_ELAS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WELCOME_ELAS.M with the given input arguments.
%
%      WELCOME_ELAS('Property','Value',...) creates a new WELCOME_ELAS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before welcome_elas_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to welcome_elas_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% JBehncke, June'18

% Last Modified by GUIDE v2.5 28-Jun-2018 13:07:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @welcome_elas_OpeningFcn, ...
                   'gui_OutputFcn',  @welcome_elas_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before welcome_elas is made visible.
function welcome_elas_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to welcome_elas (see VARARGIN)

% Choose default command line output for welcome_elas
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes welcome_elas wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = welcome_elas_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in link2nameAss.
function link2nameAss_Callback(hObject, eventdata, handles)
% hObject    handle to link2nameAss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
elas('NameAssign');


% --- Executes on button press in link2areasAss.
function link2areasAss_Callback(hObject, eventdata, handles)
% hObject    handle to link2areasAss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
elas('AnaAssign');


% --- Executes on button press in link2quit.
function link2quit_Callback(hObject, eventdata, handles)
% hObject    handle to link2quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf)


% --- Executes on button press in link2anatomy.
function link2anatomy_Callback(hObject, eventdata, handles)
% hObject    handle to link2anatomy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
elas('Anatomy');


% --- Executes on button press in link2viz.
function link2viz_Callback(hObject, eventdata, handles)
% hObject    handle to link2viz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
elas('Viz');

% --- Executes on button press in link2viz.
function link2vr_Callback(hObject, eventdata, handles)
% hObject    handle to link2viz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
elas('VR');


% --- Executes on selection change in link2create.
function link2create_Callback(hObject, eventdata, handles)
% hObject    handle to link2create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
createVal = get(hObject,'Value');
if createVal == 1
    elas('createH');
elseif createVal == 2
    elas('ConvImg');
elseif createVal == 3
    elas('MTV');
else
    fprintf('ELAS>   SORRY: still under construction!\n')
end
% Hints: contents = cellstr(get(hObject,'String')) returns link2create 
%        contents as cell array contents{get(hObject,'Value')} returns 
%        selected item from link2create


% --- Executes during object creation, after setting all properties.
function link2create_CreateFcn(hObject, eventdata, handles)
% hObject    handle to link2create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
                                  get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject)
elas('Quit');
