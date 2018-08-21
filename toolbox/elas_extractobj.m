function elas_extractobj

% FUNCTION (under ELAS) to create wavefront *.obj files for electrode 
%          spheres and brain areas
%
% DESCRIPTION 
%          You will be prompted to either select a header file or to create
%          a header by loading all '*_F.mat' files containing assignment of
%          electrodes.
%
% OUTPUT
%          The function will create wavefront *.obj files. According to  
%          the selection, different objects will be provided:
%               - one object for each electrode sphere
%               - one object for each related brain area
%               - one object for the ICBM152 brain
%          
%
% JBehncke, Aug'18

fprintf('\nELAS>   Still computing... \r')

%=======================================================================
global ELAS
%=======================================================================

%=======================================================================
% - load header
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
% - get extraction parameters
%=======================================================================
params = elas_extractGUI;
if ~params.electrodes && ~params.areas && ~params.brain
    fprintf('ELAS>   No objects selected for extraction... \n')
end 

%=======================================================================
% - export electrodes surfaces
%=======================================================================
if params.electrodes
    fprintf('ELAS>   Extract electrodes... \r')
    %-define unit sphere
    [x,y,z] = sphere;
    x = x * params.spheresz; 
    y = y * params.spheresz; 
    z = z * params.spheresz;
    %-extract electrode coordinates from header and create sphere
    electrodes_surface = cell(numel(H.channels),3);
    if params.coordtype
        for a = 1:numel(H.channels)  
            electrodes_surface{a,1} = x + H.channels(a).MNI_x;
            electrodes_surface{a,2} = y + H.channels(a).MNI_y;
            electrodes_surface{a,3} = z + H.channels(a).MNI_z;
        end
    else
        for a = 1:numel(H.channels)  
            electrodes_surface{a,1} = x + ...
                                      H.channels(a).projection_coord(1);
            electrodes_surface{a,2} = y + ... 
                                      H.channels(a).projection_coord(2);
            electrodes_surface{a,3} = z + ...
                                      H.channels(a).projection_coord(3);
        end
    end
    %-export electrode spheres
    fprintf('ELAS>   Export electrode spheres... \r')
    for a = 1:size(electrodes_surface,1)
        saveobjmesh(['sphere_' num2str(a) '.obj'], ...
                     electrodes_surface{a,1}, ...
                     electrodes_surface{a,2}, ...
                     electrodes_surface{a,3})
    end    
end
                           
%=======================================================================
% - export areas
%=======================================================================
if params.areas
    %-extract areas
    %------------------------------------------------------------------
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
    %-convert point clouds to surfaces
    %------------------------------------------------------------------
    fprintf('ELAS>   Convert point clouds to surfaces... \r')
    for a = 1:size(areas,1)   
        fprintf('ELAS>   Converting area %d/%d (%s)...\n', a, ...
                           size(areas,1), H.channels(a).name)
        %-extract isosurface
        A = pointcloud2isosurface(areas{a,1});
        %-smoothing of surface if selected
        if params.smooth
            fprintf('ELAS>   Smooth surface of area %d/%d (%s)...\n', ...
                                a, size(areas,1), H.channels(a).name)
            A = smooth_surface(A, 1000);
            filetag = '_smoothed';
        else
            filetag = '';
        end
        A.cS = zeros(length(A.vertices),1);                
        %-save areas
        fprintf('ELAS>   Export area %d/%d (%s)... \r', ...
                 a, size(areas,1), H.channels(a).name)
        y_bu = A.faces(:,2);
        A.faces(:,2) = A.faces(:,3);
        A.faces(:,3) = y_bu;
        vertface2obj(A.vertices,A.faces, [ELAS.OUTPUTpath filesep ...
                     'surface_' getmaps(a).name filetag '.obj'])
        save([ELAS.OUTPUTpath filesep 'surface_' getmaps(a).name ...
              filetag '.mat'], 'A')
    end 
end

%=======================================================================
% - export ICBM brain
%=======================================================================
if params.brain
    fprintf('ELAS>   Extract brain... \r')
    [~] = copyfile([ELAS.ASSIGNMENTSCRIPTpath filesep 'ICBM152.obj'], ...
                                                        ELAS.OUTPUTpath);
end
%=======================================================================
 
fprintf('ELAS>   Done! \n')