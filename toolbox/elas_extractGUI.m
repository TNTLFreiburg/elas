function varargout = elas_extractGUI(varargin)
% ELAS_EXTRACTGUI MATLAB code for elas_extractGUI.fig
%      ELAS_EXTRACTGUI, by itself, creates a new ELAS_EXTRACTGUI or raises the existing
%      singleton*.
%
%      H = ELAS_EXTRACTGUI returns the handle to a new ELAS_EXTRACTGUI or the handle to
%      the existing singleton*.
%
%      ELAS_EXTRACTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ELAS_EXTRACTGUI.M with the given input arguments.
%
%      ELAS_EXTRACTGUI('Property','Value',...) creates a new ELAS_EXTRACTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before elas_extractGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to elas_extractGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help elas_extractGUI

% Last Modified by GUIDE v2.5 20-Aug-2018 11:30:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @elas_extractGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @elas_extractGUI_OutputFcn, ...
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


% --- Executes just before elas_extractGUI is made visible.
function elas_extractGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to elas_extractGUI (see VARARGIN)

% Choose default command line output for elas_extractGUI
handles.output = hObject;
set(handles.link2spheresz,'String',1)

handles.params.electrodes = get(handles.link2elecselection,'Value');
handles.params.areas = get(handles.link2areaselection,'Value');
handles.params.brain = get(handles.link2brainselection,'Value');
handles.params.coordtype = get(handles.link2realcoord,'Value');
handles.params.spheresz = str2double(get(handles.link2spheresz,'String'));
handles.params.smooth = get(handles.link2smooth,'Value');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes elas_extractGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = elas_extractGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
guidata(hObject, handles);
handles.params.electrodes = get(handles.link2elecselection,'Value');
handles.params.areas = get(handles.link2areaselection,'Value');
handles.params.brain = get(handles.link2brainselection,'Value');
handles.params.coordtype = get(handles.link2realcoord,'Value');
handles.params.spheresz = str2double(get(handles.link2spheresz,'String'));
handles.params.smooth = get(handles.link2smooth,'Value');

varargout{1} = handles.params;

delete(hObject)



% --- Executes on button press in link2elecselection.
function link2elecselection_Callback(hObject, eventdata, handles)
% hObject    handle to link2elecselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of link2elecselection


% --- Executes on button press in link2areaselection.
function link2areaselection_Callback(hObject, eventdata, handles)
% hObject    handle to link2areaselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of link2areaselection


% --- Executes on button press in link2areaselection.
function link2brainselection_Callback(hObject, eventdata, handles)
% hObject    handle to link2brainselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of link2areaselection


% --- Executes on button press in link2areaselection.
function link2smooth_Callback(hObject, eventdata, handles)
% hObject    handle to link2smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of link2areaselection



function link2spheresz_Callback(hObject, eventdata, handles)
% hObject    handle to link2spheresz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of link2spheresz as text
%        str2double(get(hObject,'String')) returns contents of link2spheresz as a double
checksphsz = get(handles.link2spheresz,'String');
if isnan(str2double(checksphsz))
    msg = 'Size of sphere has to be a real number!';
    warning('off','backtrace')
    warning(msg)
    warning('on','backtrace')
    warndlg(msg)
    set(handles.link2spheresz,'String',1)
elseif ~isempty(regexp(checksphsz,',','ONCE'))
    commapos = regexp(checksphsz,',');
    if commapos(1) == 1
        set(handles.link2spheresz,'String',['0.' checksphsz(2:end)])
    else
        set(handles.link2spheresz,'String',[checksphsz(1:commapos(1)-1) ...
                                        '.' checksphsz(commapos(1)+1:end)])
    end
end


% --- Executes during object creation, after setting all properties.
function link2spheresz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to link2spheresz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white')
end


% --- Executes on button press in link2realcoord.
function link2realcoord_Callback(hObject, eventdata, handles)
% hObject    handle to link2realcoord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of link2realcoord
if get(handles.link2realcoord,'Value') == 1
    set(handles.link2projcoord,'Value',0)
else
    set(handles.link2projcoord,'Value',1)
end
guidata(hObject, handles);


% --- Executes on button press in link2projcoord.
function link2projcoord_Callback(hObject, eventdata, handles)
% hObject    handle to link2projcoord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of link2projcoord
if get(handles.link2projcoord,'Value') == 1
    set(handles.link2realcoord,'Value',0)
else
    set(handles.link2realcoord,'Value',1)
end
guidata(hObject, handles);


% --- Executes on button press in link2extract.
function link2extract_Callback(hObject, eventdata, handles)
% hObject    handle to link2extract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
if ~get(handles.link2elecselection,'Value') && ...
                            ~get(handles.link2areaselection,'Value') && ...
                            ~get(handles.link2brainselection,'Value')
    questoutput = questdlg('No objects selected for extraction. Proceed?',...
                                       'Quit extraction?','yes','no','no');
    if strcmp(questoutput, 'yes')
        close(gcf)
    end
else
    close(gcf)
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
guidata(hObject, handles);
uiresume(hObject);
