function varargout = elas_vizGUI(varargin)
% ELAS_VIZGUI MATLAB code for elas_vizGUI.fig
%      ELAS_VIZGUI, by itself, creates a new ELAS_VIZGUI or raises the existing
%      singleton*.
%
%      H = ELAS_VIZGUI returns the handle to a new ELAS_VIZGUI or the handle to
%      the existing singleton*.
%
%      ELAS_VIZGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ELAS_VIZGUI.M with the given input arguments.
%
%      ELAS_VIZGUI('Property','Value',...) creates a new ELAS_VIZGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before elas_vizGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to elas_vizGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help elas_vizGUI

% Last Modified by GUIDE v2.5 28-Jun-2018 13:06:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @elas_vizGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @elas_vizGUI_OutputFcn, ...
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


% --- Executes just before elas_vizGUI is made visible.
function elas_vizGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to elas_vizGUI (see VARARGIN)

% Choose default command line output for elas_vizGUI
handles.output = hObject;
handles.params.subjName = varargin{1}.subjName;
handles.params.cm = varargin{4}.cm;

% Update handles structure
guidata(hObject, handles);

if strcmp(get(hObject,'Visible'),'off')
    
    set(hObject,'Visible','on')
    hold on
    
    % plot areas
    handles.params.getcolors = NaN(numel(varargin{2}),3);
    for a = 1:numel(varargin{2})
        handles.params.h(a) = scatter3(varargin{2}{a}(:,1), ...
                    varargin{2}{a}(:,2), varargin{2}{a}(:,3), ...
                    30, 'filled', ...
                    'MarkerEdgeAlpha', 0.1, 'MarkerFaceAlpha', 0.1);
        handles.params.getcolors(a,:) = handles.params.h(a).CData;
        set(handles.params.h(a), 'Visible', 'off')
    end
    
    % plot electrodes
    for a = 1:size(varargin{1}.groups,2)
        for b = 1:size(varargin{1}.groups{1,a},2)
            if isempty(varargin{1}.assign{varargin{1}.groups{1,a}(b),2})
                pltc = [1, 1, 1];
            else
                pltc = handles.params.getcolors( ...
                   varargin{1}.assign{varargin{1}.groups{1,a}(b),2},:);
            end
            handles.params.(['group' num2str(a)])(b) = scatter3( ...
                    varargin{1}.xyz(varargin{1}.groups{1,a}(b),1), ...
                    varargin{1}.xyz(varargin{1}.groups{1,a}(b),2), ... 
                    varargin{1}.xyz(varargin{1}.groups{1,a}(b),3), ...
                    50, 'filled', 'MarkerFaceColor', pltc, ...
                    'MarkerEdgeColor', [0,0,0]);
%             handles.params.h2(a,b) = plot3( ...
%                         varargin{1}.xyz(varargin{1}.groups{1,a},1), ...
%                         varargin{1}.xyz(varargin{1}.groups{1,a},2), ...
%                         varargin{1}.xyz(varargin{1}.groups{1,a},3), 'w*');
        end
    end
        
    % plot brain 
    patch('Faces', [varargin{4}.fS(:,1), ...
                    varargin{4}.fS(:,2), ...
                    varargin{4}.fS(:,3)], ...
          'Vertices', [varargin{4}.vS(:,1), ...
                       varargin{4}.vS(:,2), ...
                       varargin{4}.vS(:,3)], ...
          'EdgeColor', 'none', 'CData', varargin{4}.cS, 'FaceColor', ...
          'interp', 'FaceAlpha', 0.08) 
    lighting phong
    axis equal
    colormap(varargin{4}.cm)
    view(0,90)
    camlight headlight
    axis equal
    axis off
    set(gca, 'color', [0.94 0.94 0.94])
    view(220,10)
    
    rotate3d
    
end

max_lines = 34;
diff_lines = 2;
% create checkboxes for areas
for a = 1:numel(varargin{2})
    posVec = [220+(floor((a-1)/max_lines)*30) ...
                       68.8-mod(max_lines+a-1, max_lines)*diff_lines 30 2];
    handles.button(a) = uicontrol( ...
                'style', 'checkbox', 'Units', 'characters', ...
                'BackgroundColor','k','ForegroundColor','w', ...
                'Position', posVec, 'tag', num2str(a), ...
                'Callback', @(hObject,eventdata)elas_vizGUI('checkbox_area', ...
                hObject,eventdata,guidata(hObject)), ...
                'Visible', 'on', 'String', varargin{3}(a).name);
end
% create checkboxes for electrode groups
for a = 1:size(varargin{1}.groups,2)
    posVec = [8+(floor((a-1)/max_lines)*30) ...
                       68.8-mod(max_lines+a-1, max_lines)*diff_lines 20 2];
    handles.button2(a) = uicontrol( ...
                'style', 'checkbox', 'Units', 'characters', ...
                'BackgroundColor','k','ForegroundColor','w', ...
                'Position', posVec, 'tag', num2str(a), ...
                'Callback', @(hObject,eventdata)elas_vizGUI('checkbox_group', ...
                hObject,eventdata,guidata(hObject)), ...
                'Visible', 'on', 'String', varargin{1}.groups(2,a), ...
                'Value', 1);
end

guidata(hObject, handles);

% UIWAIT makes elas_vizGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = elas_vizGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];

delete(hObject)


% --- Executes on button press in link2end.
function link2end_Callback(hObject, eventdata, handles)
% hObject    handle to link2end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(gcf)


% --- Executes on button press in checkbox_area.
function checkbox_area(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

area_tag = str2double(get(hObject,'tag'));
if get(hObject,'Value') == 1
    set(handles.params.h(area_tag), 'Visible', 'on')
else
    set(handles.params.h(area_tag), 'Visible', 'off')
end

% --- Executes on button press in checkbox_group.
function checkbox_group(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

group_tag = str2double(get(hObject,'tag'));
if get(hObject,'Value') == 1
    set(handles.params.(['group' num2str(group_tag)]), ...
                                            'Visible', 'on')
else
    set(handles.params.(['group' num2str(group_tag)]), ...
                                            'Visible', 'off')
end


% --- Executes on button press in link2zoomin.
function link2zoomin_Callback(hObject, eventdata, handles)
% hObject    handle to link2zoomin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom
zoom(1.02)
set(handles.link2pan, 'Value', 0)
rotate3d
guidata(hObject, handles);

% --- Executes on button press in link2zoomout.
function link2zoomout_Callback(hObject, eventdata, handles)
% hObject    handle to link2zoomout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom
zoom(0.98)
set(handles.link2pan, 'Value', 0)
rotate3d
guidata(hObject, handles);

% --- Executes on button press in link2pan.
function link2pan_Callback(hObject, eventdata, handles)
% hObject    handle to link2pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    pan
else
    rotate3d
end


% --- Executes on button press in link2save.
function link2save_Callback(hObject, eventdata, handles)
% hObject    handle to link2save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ELAS

savename = [handles.params.subjName '_elasPLOT'];
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    [file, path] = uiputfile({'*.fig';'*.png';'*.jpg';'*.tif';'*.emf';'*.bmp'}, ...
                        'Save figure', [ELAS.OUTPUTpath filesep savename]);
else
    [file, path] = uiputfile({'*.fig';'*.png';'*.jpg';'*.tif';'*.emf';'*.bmp'}, ... 
                        'Save figure', savename);
end
if file == 0
    return
end
fname = fullfile(path, file);
[pth,nme,ext] = fileparts(fname);

% create invisible figure to export brain and electrode plot, and save
plt = figure('Visible','off','Position',[437 79 1228 930]);
copyobj(handles.mainfig, plt)
plt.Colormap = handles.params.cm;
set(plt,'CreateFcn','set(gcbf,''Visible'',''on'')')
if strcmp(ext, '.fig')
	savefig(plt, fname)
elseif strcmp(ext, '.png')
    print(plt, fullfile(pth, nme), '-dpng', '-r300');
elseif strcmp(ext, '.jpeg')
    print(plt, fullfile(pth, nme), '-djpeg', '-r300');
elseif strcmp(ext, '.tif')
    print(plt, fullfile(pth, nme), '-dtiff', '-r300');
elseif strcmp(ext, '.emf')
    print(plt, fullfile(pth, nme), '-dmeta', '-r300');
elseif strcmp(ext, '.bmp')
    print(plt, fullfile(pth, nme), '-dbmp', '-r300');
else
    fprintf('ELAS>   Format ''%s'' not supported, figure not saved! \r', ext)
    delete(plt)
    return
end
fprintf('ELAS>   Figure saved as: %s \r', fname)
delete(plt)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
guidata(hObject, handles);
uiresume(hObject);
