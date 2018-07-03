function varargout = elas_plotGUI(varargin)

% FUNCTION (under elas) to create figure for electrode 2 name and lobe 
%          assignment
%       
% SYNTAX 
%          output = elas_plotGUI(input)
%
%
% INPUT
%          'input': struct containing variables
%               .x/y/z      (nx1 double), coordinates of electrodes
%               .sx/sy/sz   (nx1 double), coordinates of sulci
%               .lc         (double), # of electrodes
%               .elNam      'char', preassignment of electrode name
%               .anAbb      'char', init value for anatomical preassignment
%               .az         (double), azimuth angle of plot view
%               .el         (double), elevation of plot view
%          (see elas_namesass)
% 
% OUTPUT
%          'outputP': struct containing variables
%               .names      {cell}, defined electrode names
%               .coordsX    (nx1 double), x-coordinates
%               .coordsY    (nx1 double), y-coordinates
%               .coordsZ    (nx1 double), z-coordinates
%               .nc         (double), index of next electrode
%               .lc         (double), # of electrodes
%               .elNam      'char', preassignment of electrode name
%
% DESCRIPTION
%          ELAS_PLOTGUI, by itself, creates a new ELAS_PLOTGUI or raises 
%          the existing singleton*.
%
%          H = ELAS_PLOTGUI returns the handle to a new ELAS_PLOTGUI or the 
%          handle to the existing singleton*.
%
%          ELAS_PLOTGUI('CALLBACK',hObject,eventData,handles,...) calls the 
%          local function named CALLBACK in ELAS_PLOTGUI.M with the given 
%          input arguments.
%
%          ELAS_PLOTGUI('Property','Value',...) creates a new ELAS_PLOTGUI 
%          or raises the existing singleton*.  Starting from the left, 
%          property value pairs are applied to the GUI before 
%          elas_plotGUI_OpeningFcn gets called. An unrecognized property 
%          name or invalid value makes property application stop.  All 
%          inputs are passed to elas_plotGUI_OpeningFcn via varargin.
%
%          *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only 
%          one instance to run (singleton)".
%
% JBehncke, June'18


% Last Modified by GUIDE v2.5 05-Jun-2018 16:37:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @elas_plotGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @elas_plotGUI_OutputFcn, ...
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


% --- Executes just before elas_plotGUI is made visible.
function elas_plotGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to elas_plotGUI (see VARARGIN)

% Choose default command line output for elas_plotGUI
handles.output = hObject;

% This sets the initial plot values
if nargin<4 || ~isstruct(varargin{1})
    handles.params.coordsX = 1:0.1:10;
    handles.params.coordsY = 1:0.1:10;
    handles.params.coordsZ = 1:0.1:10;
    fprintf('ELAS>   ERROR: No input data... \r\n');
else
    handles.params.coordsX = varargin{1}.x;
    handles.params.coordsY = varargin{1}.y;
    handles.params.coordsZ = varargin{1}.z;
end

% set value for edit box
set(handles.link2editNme, 'String', [varargin{1}.elNam '1'])
set(handles.link2editAbb, 'String', varargin{1}.anAbb)
% handles.params.elNam = varargin{1}.elNam;
handles.params.nc = 1;
handles.params.lc = varargin{1}.lc;

% Update handles structure
guidata(hObject, handles);
 
% This sets up the initial plot - only do when we are invisible
% so window can get raised using elas_plotQuestBox.
if strcmp(get(hObject,'Visible'),'off')
    
    set(hObject,'Visible','on')
    
    % plot electrodes
    plot3(handles.params.coordsX, ...
          handles.params.coordsY, ...
          handles.params.coordsZ,'b*')
    hold on
    
    % mark current electrode
    plot3(handles.params.coordsX(1), ...
          handles.params.coordsY(1), ...
          handles.params.coordsZ(1),'r*');
    
    % plot sulci
    if ~isempty(varargin{1}.sx)
        scatter3(varargin{1}.sx, varargin{1}.sy, varargin{1}.sz, 5, ...
                           'MarkerEdgeColor', 'y', 'MarkerFaceColor', 'y');
    end
        
    % plot brain 
    S = varargin{2};
    patch('Faces', [S.fS(:,2),S.fS(:,1),S.fS(:,3)], ...
          'Vertices', [S.vS(:,2),S.vS(:,1),S.vS(:,3)], ...
          'EdgeColor', 'none', 'CData', S.cS, 'FaceColor', 'interp', ...
          'FaceAlpha', 0.15) 
    lighting phong
    axis equal
    colormap(S.cm)
    view(0,90)
    camlight headlight
    axis equal
    axis off
    set(gca, 'color', [0.94 0.94 0.94])
    
    % settings
    if isfield(varargin{1},'az')
        view(varargin{1}.az,varargin{1}.el)
    end
    rotate3d
    
end

% UIWAIT makes elas_plotGUI wait for user response (see UIRESUME)
uiwait(handles.figure1)


% --- Outputs from this function are returned to the command line.
function varargout = elas_plotGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.params;

delete(hObject)




function link2editNme_Callback(hObject, eventdata, handles)
% hObject    handle to link2editNme (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of link2editNme as text
%        str2double(get(hObject,'String')) returns contents of link2editNme as a double


% --- Executes during object creation, after setting all properties.
function link2editNme_CreateFcn(hObject, eventdata, handles)
% hObject    handle to link2editNme (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), ...
                                  get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in link2nxtElec.
function link2nxtElec_Callback(hObject, eventdata, handles)
% hObject    handle to link2nxtElec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.params.nc > handles.params.lc
    set(handles.link2editNme, 'String', 'error: complete')
    return
end
handles.params.names{handles.params.nc} = ...
                                   [get(handles.link2editNme, 'String') ...
                                  '_' get(handles.link2editAbb, 'String')];
currentName = handles.params.names{handles.params.nc};

% make changes to GUI
handles.params.nc = handles.params.nc + 1;
set(handles.txt4lastElec, 'String', currentName)
if handles.params.nc <= handles.params.lc
    % plot all electrodes blue
    plot3(handles.params.coordsX, ...
          handles.params.coordsY, ...
          handles.params.coordsZ,'b*')
    hold on
    
    % mark all named electrodes black
    plot3(handles.params.coordsX(1:handles.params.nc-1), ...
          handles.params.coordsY(1:handles.params.nc-1), ...
          handles.params.coordsZ(1:handles.params.nc-1),'k*');
      
    % mark current electrode red
    plot3(handles.params.coordsX(handles.params.nc), ...
          handles.params.coordsY(handles.params.nc), ...
          handles.params.coordsZ(handles.params.nc),'r*');
else
    % mark all electrodes black
    plot3(handles.params.coordsX, ...
          handles.params.coordsY, ...
          handles.params.coordsZ,'k*');
    set(handles.link2editNme, 'String', 'complete')
end
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in link2prevElec.
function link2prevElec_Callback(hObject, eventdata, handles)
% hObject    handle to link2prevElec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.params.nc <= 1
    set(handles.link2editNme, 'String', 'error: first electrode')
    return
end

% make changes to GUI
handles.params.nc = handles.params.nc-1;
% plot all electrodes blue
plot3(handles.params.coordsX, ...
      handles.params.coordsY, ...
      handles.params.coordsZ,'b*')
hold on

% mark all named electrodes black
plot3(handles.params.coordsX(1:handles.params.nc-1), ...
      handles.params.coordsY(1:handles.params.nc-1), ...
      handles.params.coordsZ(1:handles.params.nc-1),'k*');

% mark current electrode red
plot3(handles.params.coordsX(handles.params.nc), ...
      handles.params.coordsY(handles.params.nc), ...
      handles.params.coordsZ(handles.params.nc),'r*');

% set new name suggestion
if handles.params.nc == 1
    set(handles.txt4lastElec, 'String', '-----')
else
    set(handles.txt4lastElec, 'String', ...
                                 handles.params.names{handles.params.nc-1})
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in link2noElec.
function link2noElec_Callback(hObject, eventdata, handles)
% hObject    handle to link2noElec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.params.nc > handles.params.lc
    set(handles.link2editNme, 'String', 'error: complete')
    return
end
handles.params.names{handles.params.nc} = 'no electrode';

% make changes to GUI
handles.params.nc = handles.params.nc + 1;
set(handles.txt4lastElec, 'String', 'no electrode')
if handles.params.nc <= handles.params.lc
   	% plot all electrodes blue
    plot3(handles.params.coordsX, ...
          handles.params.coordsY, ...
          handles.params.coordsZ,'b*')
    hold on
    
    % mark all named electrodes black
    plot3(handles.params.coordsX(1:handles.params.nc-1), ...
          handles.params.coordsY(1:handles.params.nc-1), ...
          handles.params.coordsZ(1:handles.params.nc-1),'k*');
      
    % mark current electrode red
    plot3(handles.params.coordsX(handles.params.nc), ...
          handles.params.coordsY(handles.params.nc), ...
          handles.params.coordsZ(handles.params.nc),'r*');
else
    % mark all electrodes black
    plot3(handles.params.coordsX, ...
          handles.params.coordsY, ...
          handles.params.coordsZ,'k*');
    set(handles.link2editNme, 'String', 'complete')
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in link2end.
function link2end_Callback(hObject, eventdata, handles)
% hObject    handle to link2end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gcf)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles.params, 'names')
    handles.params.names = [];
end
if handles.params.nc <= handles.params.lc
    handles.params.warn = ['Assignment incomplete, last ' ...
                           'electrode named: nc = ' ...
                           num2str(handles.params.nc-1) '!'];
end
% Update handles structure
guidata(hObject, handles);

uiresume(hObject)


% --- Executes during object creation, after setting all properties.
function txt4lastElec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt4lastElec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function link2editAbb_Callback(hObject, eventdata, handles)
% hObject    handle to link2editAbb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of link2editAbb as text
%        str2double(get(hObject,'String')) returns contents of link2editAbb as a double


% --- Executes during object creation, after setting all properties.
function link2editAbb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to link2editAbb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in link2rotate.
function link2rotate_Callback(hObject, eventdata, handles)
% hObject    handle to link2rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotate3d


% --- Executes on button press in link2zoomin.
function link2zoomin_Callback(hObject, eventdata, handles)
% hObject    handle to link2zoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom
zoom(1.02)
rotate3d


% --- Executes on button press in link2zoomout.
function link2zoomout_Callback(hObject, eventdata, handles)
% hObject    handle to link2zoomout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom
zoom(0.98)
rotate3d


% --- Executes on button press in link2pan.
function link2pan_Callback(hObject, eventdata, handles)
% hObject    handle to link2pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pan
