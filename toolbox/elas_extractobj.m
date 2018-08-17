function elas_extractobj

% FUNCTION (under ELAS) to extract coordinates and create *.obj file
%
% DESCRIPTION 
%          input file:    header '*_H.mat' containing electrode meta info
%
% OUTPUT
%          The function will create an wavefront *.obj file for each of the
%          electrodes stored in header '*_H.mat'.
%          
%
% JBehncke, Aug'18

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

%=======================================================================
% - extract electrodes surfaces
%=======================================================================
fprintf('ELAS>   Extract electrodes... \r')
%-define unit sphere
[x,y,z] = sphere;
eSz = inputdlg({'Define electrode size (1 would be a suitable value):'}, ...
                'Electrode size', [1 55], {'1'});
x = x * str2double(eSz{1,1});
y = y * str2double(eSz{1,1});
z = z * str2double(eSz{1,1});
%-extract electrode coordinates from header and create sphere
electrodes_surface = cell(numel(H.channels),3);
for a = 1:numel(H.channels)  
    electrodes_surface{a,1} = x + H.channels(a).MNI_x;
    electrodes_surface{a,2} = y + H.channels(a).MNI_y;
    electrodes_surface{a,3} = z + H.channels(a).MNI_z;
end

%=======================================================================
% - save electrodes surfaces
%=======================================================================
fprintf('ELAS>   Export electrode spheres... \r')
for a = 1:size(electrodes_surface,1)
    saveobjmesh(['sphere_' num2str(a) '.obj'], ...
                 electrodes_surface{a,1}, ...
                 electrodes_surface{a,2}, ...
                 electrodes_surface{a,3})
end     
                           
%=======================================================================
% - extract areas
%=======================================================================
fprintf('ELAS>   Extract areas... \r')
srcPar_areas.OR = [76 116 64];
load([ELAS.ASSIGNMENTSCRIPTpath filesep 'areasv22.mritv_session.mat'])
load([ELAS.ASSIGNMENTSCRIPTpath filesep 'AllAreas_v22_MPM.mat'])
area_names = cell(1, numel(H.channels));
for a = 1:numel(H.channels)
    area_names{a} = H.channels(a).ass_cytoarchMap{1,1};
end  
getmaps = MAP(ismember({MAP(:).name}, area_names));
%-get area locations according to the midline of hemispheres
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
%-extract area coordinates from Anatomy Toolbox data
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

%=======================================================================
% - convert point clouds to surfaces
%=======================================================================
fprintf('ELAS>   Convert point clouds to surfaces... \r')
for a = 1:size(electrodes_surface,1)   
    %-get vertices of surface by looking at nearest neighbours
    A.vertices = [];
    for b = 1:size(areas{a,1},1)
        defdist = sqrt((areas{a,1}(b,1)-areas{a,1}(:,1)).^2 + ...
                       (areas{a,1}(b,2)-areas{a,1}(:,2)).^2 + ...
                       (areas{a,1}(b,3)-areas{a,1}(:,3)).^2);
        if numel(find(defdist < 2)) < 27
            A.vertices = [A.vertices; areas{a,1}(b,:)];
        end
    end
    distMat = NaN(size(A.vertices,1), size(A.vertices,1));
    for b = 1:size(A.vertices,1)
        distMat(:,b) = sqrt((A.vertices(b,1)-A.vertices(:,1)).^2 + ...
                            (A.vertices(b,2)-A.vertices(:,2)).^2 + ...
                            (A.vertices(b,3)-A.vertices(:,3)).^2);
    end
    %-create faces by triangulation
    A.faces = [];
    reverseStr = '';
    for b = 1:size(A.vertices,1)
        msg = sprintf('ELAS>   Converting area %d/%d (%s), vertex %d/%d\n', ...
                       a, size(electrodes_surface,1), H.channels(a).name, ...
                       b, size(A.vertices,1));
        fprintf([reverseStr, msg])
        reverseStr = repmat(sprintf('\b'), 1, length(msg));

        getnn_b = find(distMat(:,b) < 2);
        getnn_b(getnn_b==b) = [];
        for c = getnn_b'
            getnn_c = find(distMat(getnn_b,c) < 1.5);
            getnn_c(getnn_b(getnn_c)==c) = [];
            if isempty(getnn_c)
                getnn_c = find(distMat(getnn_b,c) < 2);
                getnn_c(getnn_b(getnn_c)==c) = [];
            end
            if ~isempty(getnn_c)
                newfaces = NaN(numel(getnn_c), 3);
                for d = 1:numel(getnn_c)
                    newfaces(d,:) = [b, c, getnn_b(getnn_c(d))];                            
                end
                newfaces = unique(sort(newfaces,2),'rows');
                A.faces = [A.faces; newfaces];
            end
        end  
        A.faces = unique(sort(A.faces,2),'rows');
    end
    A.faces = unique(sort(A.faces,2),'rows');
    A.cS = zeros(length(A.vertices),1); 
    %-save areas
    fprintf('ELAS>   Export area %d/%d (%s)... \r', ...
                         a, size(electrodes_surface,1), H.channels(a).name)
    y_bu = A.faces(:,2);
    A.faces(:,2) = A.faces(:,3);
    A.faces(:,3) = y_bu;
    vertface2obj(A.vertices,A.faces, [ELAS.OUTPUTpath filesep 'surface_' ...
                 getmaps(a).name '.obj'])
    save([ELAS.OUTPUTpath filesep 'surface_' getmaps(a).name '.mat'], 'A')
end 

%%
%-TODO:
%       - smoothing
%       - create matlab gui to select different things at one time (size of
%       spheres, which coordinate to take, extract areas yes or no, extract
%       coordinates yes or no,...)
%       - complete dicription of function
%
%-IDEA FOR SMOOTHING: you can take all vertives belonging to one point and
%   extract their coordinates. Based on this you can perform a local
%   smoothing by moving the coordinate in direction of the center of mass, 
%   choosing a metrix like alpha e.g. alpha = 0.3.
%=======================================================================

fprintf('ELAS>   Done! \n')