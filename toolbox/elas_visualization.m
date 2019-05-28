function elas_visualization

% FUNCTION (under ELAS) to visualize results of assignment
%
% DESCRIPTION 
%          input file:    header '*_H.mat' containing electrode meta info
%
%          'elas_visualization.m' opens a GUI where areas as well as 
%          electrode groups can be selected on/off. The final visualization
%          (brain + group(s) + area(s)) can be saved in different views of 
%          the plot. Typical formats are supported, e.g. *.fig or *.png.
%          
%
% JBehncke, June'18

fprintf('\nELAS>   Still computing... \r')

%=======================================================================
global ELAS
%=======================================================================

%=======================================================================
% - load variables
%=======================================================================
fprintf('ELAS>   Load variables... \r')
choice = questdlg('Does header file already exist?', 'Input', ...
                  'Yes', 'No', 'Yes');
if strcmp(choice, 'Yes')
    if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
        [filename, pathname] = uigetfile([ELAS.OUTPUTpath filesep '*.mat'],...
                        'Select file containing header variable H');
    else
        [filename, pathname] = uigetfile('*.mat',...
                        'Select file containing header variable H');
    end
    if isequal([filename,pathname],[0,0])
        msgbox('No file selected!','WARNING','warn');
        fprintf('ELAS>   Done! \n')
        return  
    end
    load([pathname filename])
else
    [H] = elas_getallF;
    if isempty(H)
        warning('off','backtrace')
        warning('Either header H has to be loaded or created. Try again!')
        warning('on','backtrace')
        fprintf('ELAS>   Done! \r');
        return
    end
end

PreBrainChoice = listdlg('PromptString','Select brain mode:',...
    'SelectionMode','single',...
    'ListString', {'ICBM152 standard brain'...
                   'individual brain'},...
    'ListSize', [200 50],...
    'Name', 'Brain mode');      
if isempty(PreBrainChoice)
    msgbox('Brain mode has to be defined!',...
       'WARNING','warn');
    fprintf('ELAS>   Done! \r\n')
    return
end

load([ELAS.ASSIGNMENTSCRIPTpath filesep 'ICBM152_HD_213.mat'])
if PreBrainChoice == 2
%     g = gifti(['E:\Data Joos\01_Matlab\09_electrode_localization\testData\' ...
%                'testPat\15_FR1_day1\c1wr15_FR1_day1.surf.gii']);
 	[filename, pathname] = uigetfile([ELAS.OUTPUTpath filesep '*.gii'],...
                        'Select *.gii file containing individual brain');
    if isequal([filename,pathname],[0,0])
        msgbox('No file selected! ICBM152 brain used for visualization.', ...
               'WARNING','warn');
    else
        g = gifti([pathname filename]);
        S.cS = zeros(size(g.vertices,1),1);
        S.vS = double(g.vertices);
        S.fS = double(g.faces);
    end
end

%=======================================================================
% - get area mode and load MAP
%=======================================================================
PreAreaChoice = listdlg('PromptString','Select area mode:',...
    'SelectionMode','single',...
    'ListString', {'all assigned areas'...
                   'all cortical areas'...
                   'all areas'},...
    'ListSize', [200 50],...
    'Name', 'Area mode');      
if isempty(PreAreaChoice)
    msgbox('Area mode has to be defined!',...
       'WARNING','warn');
    fprintf('ELAS>   Done! \r\n')
    return
end

%=======================================================================
% - get meta info
%=======================================================================
srcPar_areas.OR = [76 116 64];
%-get electrode groups
electrodes.subjName = H.subjName;
all_groups = unique({H.channels(:).group});
all_ch_ind = 1:numel(H.channels);
for a = 1:numel(all_groups) 
    electrodes.groups{1,a} = all_ch_ind(strcmp({H.channels(:).group}, ...
                                                        all_groups{a}));
    electrodes.groups{2,a} = all_groups{a};
end
%-convert electrodes coordinates
for a = 1:numel(H.channels)
    electrodes.xyz(a,:) = [H.channels(a).MNI_x, ...
                           H.channels(a).MNI_y, ...
                           H.channels(a).MNI_z];
    electrodes.assign{a,1} = H.channels(a).ass_cytoarchMap{1};
end
                           
%=======================================================================
% - extract areas
%=======================================================================
fprintf('ELAS>   Extract areas... \r')
if PreAreaChoice == 1
    load([ELAS.ASSIGNMENTSCRIPTpath filesep 'areasv22.mritv_session.mat'])
    load([ELAS.ASSIGNMENTSCRIPTpath filesep 'AllAreas_v22_MPM.mat'])
    area_names = cell(1, numel(H.channels));
    for a = 1:numel(H.channels)
        area_names{a} = H.channels(a).ass_cytoarchMap{1,1};
    end  
    getmaps = MAP(ismember({MAP(:).name}, area_names));
    area_locs = zeros(3, numel(getmaps));
    for a = 1:numel(H.channels)
        get_ind = find(ismember({getmaps(:).name}, ...
                               H.channels(a).ass_cytoarchMap{1,1}), 1);
        if ~isempty(get_ind) && H.channels(a).MNI_x <= 0
            area_locs(1,get_ind) = 1;
        elseif ~isempty(get_ind) && H.channels(a).MNI_x >= 0
            area_locs(2,get_ind) = 1;
        end
        if sum(area_locs(1:2, get_ind)) == 2
            area_locs(3,get_ind) = 1;
        end
    end
    areas = cell(numel(getmaps),1);
    for a = 1:numel(getmaps)
        xyz = find(mri.image.data == getmaps(a).GV);
        [areas{a}(:,1),areas{a}(:,2),areas{a}(:,3)] = ...
                                     ind2sub(size(mri.image.data),xyz);
        [areas{a},~] = transfCS([areas{a}(:,1), areas{a}(:,2), ...
                            areas{a}(:,3)], 'mri','mni', srcPar_areas);
        if area_locs(3,a) == 1
        elseif area_locs(2,a) == 1
            rightHem = areas{a}(:,1) >= 0;
            areas{a} = areas{a}(rightHem,:);
        else
            leftHem = areas{a}(:,1) <= 0;
            areas{a} = areas{a}(leftHem,:);
        end
    end
elseif PreAreaChoice == 2
    load([ELAS.ASSIGNMENTSCRIPTpath filesep ...
                                 'all_cortical_v22.mritv_session.mat'])
    load([ELAS.ASSIGNMENTSCRIPTpath filesep 'all_cortical_v22_MPM.mat'])
    getmaps = MAP;
    areas = cell(numel(MAP),1);
    for a = 1:numel(MAP)
        xyz = find(mri.image.data == MAP(a).GV);
        [areas{a}(:,1),areas{a}(:,2),areas{a}(:,3)] = ...
                                     ind2sub(size(mri.image.data),xyz);
        [areas{a},~] = transfCS([areas{a}(:,1), areas{a}(:,2), ...
                            areas{a}(:,3)], 'mri','mni', srcPar_areas);
    end
else
    load([ELAS.ASSIGNMENTSCRIPTpath filesep 'areasv22.mritv_session.mat'])
    load([ELAS.ASSIGNMENTSCRIPTpath filesep 'AllAreas_v22_MPM.mat'])
    getmaps = MAP;
    areas = cell(numel(MAP),1);
    for a = 1:numel(MAP)
        xyz = find(mri.image.data == MAP(a).GV);
        [areas{a}(:,1),areas{a}(:,2),areas{a}(:,3)] = ...
                                     ind2sub(size(mri.image.data),xyz);
        [areas{a},~] = transfCS([areas{a}(:,1), areas{a}(:,2), ...
                            areas{a}(:,3)], 'mri','mni', srcPar_areas);
    end
end

%=======================================================================
% - convert electrode coordinates and assign to areas
%=======================================================================
% - MNI -> Anatomical MNI (brain and areas are in Anatomical MNI!!!)
electrodes.xyz(:,2) = electrodes.xyz(:,2)-4;
electrodes.xyz(:,3) = electrodes.xyz(:,3)+5;
% - assign electrodes to areas in 'getmaps'
for a = 1:size(electrodes.assign,1)
    electrodes.assign{a,2} = ...
                  find(strcmp(electrodes.assign{a}, {getmaps(:).name}));
end

%=======================================================================
% - call plot function
%=======================================================================
fprintf('ELAS>   Plot selection... \r')
[~] = elas_vizGUI(electrodes, areas, getmaps, S);
%=======================================================================

fprintf('ELAS>   Done! \n')