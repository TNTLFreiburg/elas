function elas_elecass

% FUNCTION (under ELAS) to perform hierarchic probabilisitc assignment 
%          (HPA) and probabilistic assignment (without cortical projection
%          to anatomic regions, and assignment to matter type (for depth 
%          electrodes)
%
% DESCRIPTION In this step, the electrodes are assigned to a specific    
%          anatomic region. Besides, the segmentation images are used to
%          assign the depth electrodes to a certain matter type. The 
%          variable 'F' is the essential output, containing the MNI 
%          coordinates and the electrode names, as well as the names of 
%          the assigned anatomic regions and the matter type.   
%
%          ECoG-Grid and ECoG-Gtrip: choice between HPA and probabilistic 
%                   assignment for surface electrodes
%          SEEG:    probabilistic assignment for depth electrodes
%          other:   e.g. EEG, EMG, EOG, ECG, Trigger: no assignment, only 
%                   names of channels and signal type will be passed to 
%                   variable F
%
% OUTPUT
%          '*savename*_F.mat'
%
% JBehncke, June'18


fprintf('\nELAS>   Still computing... \r')

%=======================================================================
global ELAS FV macrolabel FVplot
%=======================================================================

%=======================================================================
% - load coordinate varibale E
%=======================================================================
fprintf('ELAS>   Select files... \r')
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    [filenameA, pathname] = uigetfile([ELAS.OUTPUTpath filesep '*.mat'],...
                    'Select file containing coordinate variable E');
else
    [filenameA, pathname] = uigetfile('*.mat',...
                    'Select file containing coordinate variable E');
end

if isequal([filenameA,pathname],[0,0])
    msgbox('No file selected!',...
   'WARNING','warn');
    fprintf('ELAS>   Done! \n')
    return  
end 
load([pathname filenameA])

%=======================================================================
% - define signal type and select assignment technique, if necessary
%=======================================================================
PreTypeChoice = listdlg('PromptString', ...
    'Enter signal type of electrodes:',...
    'SelectionMode','single',...
    'ListString', {'SEEG'...
                   'ECoG-Grid'...
                   'ECoG-Strip',...
                   'EEG'...
                   'EMG'...
                   'EOG'...
                   'ECG'...
                   'Trigger'},...
	'ListSize', [400 120],...
    'Name', 'Signal type');                 
if PreTypeChoice == 1
    inputType = 'SEEG';
elseif PreTypeChoice == 2
    inputType = 'ECoG-Grid';
elseif PreTypeChoice == 3
    inputType = 'ECoG-Strip';
elseif PreTypeChoice == 4
    inputType = 'EEG';
elseif PreTypeChoice == 5
    inputType = 'EMG';
elseif PreTypeChoice == 6
    inputType = 'EOG';
elseif PreTypeChoice == 7
    inputType = 'ECG';
elseif PreTypeChoice == 8
    inputType = 'Trigger';
else
    msgbox('Signal type has to be defined!',...
       'WARNING','warn');
    fprintf('ELAS>   Done! \n')
    return
end
if PreTypeChoice == 2 || PreTypeChoice == 3
    PreAssChoice = listdlg('PromptString', ...
        'Select assignment technique:', ...
        'SelectionMode','single',...
        'ListString', {'Hierarchical Probabilistic Assignment (HPA)'...
                       'Probabilistic Assignment'},...
        'ListSize', [400 30],...
        'Name', 'Assignment technique');      
    if isempty(PreAssChoice)
        msgbox('Signal type has to be defined!',...
           'WARNING','warn');
        fprintf('ELAS>   Done! \n')
        return
    end
else
    PreAssChoice = 0;
end

%=======================================================================
% - start selected assignment loop
%=======================================================================
lpath = ELAS.ASSIGNMENTSCRIPTpath;
if PreTypeChoice == 1
    
    %___________________________________________________________________
    %
    % Probabilisitic Assignment for stereotactic and interhemispheric 
    % electrodes, without cortical projection
    %
    % Assignment of electrodes to the type of matter by using images  
    % after segmentation. Every pixel in the pre-implantation image  
    % corresponds to a certain type.
    %___________________________________________________________________

    % read segmented image files for:
    %-------------------------------------------------------------------
    % grey matter
    [filename, pathname] = uigetfile( ...
               {'*.img;*.nii','All Image-Files'},...
               'Select segmented grey matter file (c1*.img,c1*.nii)',...
               ELAS.OUTPUTpath);
    if isequal([filename,pathname],[0,0])
        disp('ELAS>   ERROR: No file selected!');
        warning('No assignment to matter type! Continuing..')
    else
        [gmri, origin_gmri.OR] = elas_imgread(filename,pathname);
        % white matter       
        [filename, pathname] = uigetfile( ...
                   {'*.img;*.nii', 'All Image-Files'}, ...
                   ['Select segmented white matter file ' ...
                   '(c2*.img,c2*.nii)'],pathname);
        if isequal([filename,pathname],[0,0])
            disp('ELAS>   ERROR: No file selected!');
            fprintf('ELAS>   Done! \n')
            return
        end    
        [wmri, origin_wmri.OR] = elas_imgread(filename,pathname);
        % cerebrospinal fluid (CSF)
        [filename, pathname] = uigetfile( ...
                   {'*.img;*.nii', 'All Image-Files'},...
                   'Select segmented CSF file (c3*.img,c3*.nii)',...
                   pathname);
        if isequal([filename,pathname],[0,0])
            disp('ELAS>   ERROR: No file selected!');
            fprintf('ELAS>   Done! \n')
            return
        end
        [csfmri, origin_csfmri.OR] = elas_imgread(filename,pathname);

        % transform coordinates
        %---------------------------------------------------------------
        [tmpcoorg,~] = transfCS([E.mnix, E.mniy, E.mniz], 'mni', ...
                                                    'mri', origin_gmri);
        [tmpcoorw,~] = transfCS([E.mnix, E.mniy, E.mniz], 'mni', ...
                                                    'mri', origin_wmri);
        [tmpcoorc,~] = transfCS([E.mnix, E.mniy, E.mniz], 'mni', ...
                                                  'mri', origin_csfmri);        
    end    
    
    % assign electrodes to matter type
    %-------------------------------------------------------------------
    fprintf('ELAS>   Assigning electrodes to matter type...\n')
    matter = cell(1,numel(E.mnix));
    matter_num = cell(1,numel(E.mnix));
    maxInd = NaN(1,numel(E.mnix)); 
    for a = 1:numel(E.mnix)
        try
            matter_num{1,a} = cat(1, ...
                 gmri(tmpcoorg(a,1),tmpcoorg(a,2),tmpcoorg(a,3)),...
                 wmri(tmpcoorw(a,1),tmpcoorw(a,2),tmpcoorw(a,3)),...
                 csfmri(tmpcoorc(a,1),tmpcoorc(a,2),tmpcoorc(a,3)));
            [~,maxInd(1,a)] = max(matter_num{1,a});
            if maxInd(1,a) == 1
                matter{1,a} = 'Grey Matter';
            elseif maxInd(1,a) == 2
                matter{1,a} = 'White Matter';
            elseif maxInd(1,a) == 3
                matter{1,a} = 'Cerebro-Spinal Fluid';
            end
        catch
            warning(['Assignment to matter type not possible ' ...
                     'for electrode #%d! Assignment skipped...'], a)
            matter{1,a} = 'n.a.';
        end
    end


    % Create assignment variable 'F', containing the MNI coordinates and 
    % the electrode names, as well as the names of the assigned anatomic 
    % regions and the matter type.

    %-load and define needed assignment variables out of toolbox
    %-------------------------------------------------------------------
    fprintf('ELAS>   Loading variables...\n')
    load([lpath filesep 'areasv22.mritv_session.mat'])
    load([lpath filesep 'AllAreas_v22_MPM.mat'])
%     [an,~] = xlsread([lpath filesep 'areas_v22.xls']);
    load([lpath filesep 'Macro.mat'])
    load([lpath filesep 'macrolabels.mat'])
    load([lpath filesep 'FV_no_cerebellum.mat'], 'FV', 'FVplot')
    
%     %-define assignment method
%     %-------------------------------------------------------------------
%     assignment_method.method = 1;  	% 1 -> purely normal based
%     assignment_method.plot = 0;  	% 1 -> plot normals
%     assignment_method.mindist = 5;	% all hull points <= this distance in mm
%                                     % are projected onto the probabilistc maps 
%     
%     %-get grey values
%     %-------------------------------------------------------------------
%     gv = NaN(1,numel(MAP));
%     for a = 1:numel(MAP)                                                  
%         gv(a) = MAP(a).GV; 
%     end
%     all_areas = gv(an >= 0);

    % write results into variable 'F' & get information from anatomy tb script
    %-------------------------------------------------------------------
    F.names  = E.names;
    F.signalType = inputType;
    F.assign_coord = NaN(3,numel(E.mnix));
    F.projection_coord = 'no projection';
    F.label = cell(1,size(E.mnix,2));
    F.all_assign = cell(1,size(E.mnix,2));
    F.all_assign_num = NaN(1,numel(E.mnix));
    F.p_area = cell(1,size(E.mnix,2));
    F.p_bnds = cell(1,size(E.mnix,2));
    F.matter = matter;
    F.matter_num = matter_num;
    F.sulci = cell(1,numel(E.mnix));
    
    reverseStr = '';
    for a = 1:numel(E.mnix)
        msg = sprintf(['ELAS>   Assigning electrodes to anatomical ' ... 
                       'areas: electrode %d/%d\n'], a, numel(E.mnix));
    	fprintf([reverseStr, msg])
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        F.assign_coord(:,a) = cat(1,E.mnix(a),E.mniy(a),E.mniz(a));
        evalc('elAss = se_TabList_mod(E.mnix(a), E.mniy(a), E.mniz(a))');
        F.all_assign{1,a} = elAss.probabAss_area;
        F.p_area{1,a} = elAss.probabAss_elec;
        F.p_bnds{1,a} = elAss.probabAss_bnds;
        F.label{1,a} = elAss.brainAtlas;
        F.sulci{1,a} = [];
    end

elseif (PreTypeChoice == 2 || PreTypeChoice == 3) && PreAssChoice == 1
    
    %___________________________________________________________________
    %
	% HPA for grid & strip electrodes
    %___________________________________________________________________
    
    % select root paths and load variables
    %-------------------------------------------------------------------
    if strcmp(E.lsend, 'n.a.')
        warning(['End point of horizontal ramus has to be defined for' ...
                 ' HPA mode! Check variable ''E.lsend...'''])
        fprintf('ELAS>   Done! \n')
        return
    end
    fprintf('ELAS>   Loading variables...\n')
	load([lpath filesep 'areasv22.mritv_session.mat'])
    load([lpath filesep 'AllAreas_v22_MPM.mat'])
    [an,~] = xlsread([lpath filesep 'areas_v22.xls']);
    lobe = xlsread([lpath filesep 'Labels.xls'],'E1:E116');
    load([lpath filesep 'FV_no_cerebellum.mat'], 'FV', 'FVplot')
    load([lpath filesep 'Macro.mat'])
    load([lpath filesep 'macrolabels.mat'])
    
    % get grey values for all areas
    %-------------------------------------------------------------------
  	gv_all = NaN(1,numel(MAP));
    for r=1:numel(MAP)           % get grey values  
        gv_all(r) = MAP(r).GV; 
    end
    all_areas = gv_all(an>=0);
    mri_all = mri;
    MAP_all = MAP;
                         
    %-define assignment method
    %-------------------------------------------------------------------
    assignment_method.method = 1;   % 1 -> purely normal based
    assignment_method.plot = 1;     % 1 -> plot normals
    assignment_method.mindist = 5;  % all hull points <= this distance 
                      % in mm are projected onto the probabilistc maps 
  
    % create assign_coord and all_assign_num looping over electrodes 
    %-------------------------------------------------------------------
    fprintf('ELAS>   Creating assignment coordinates...\n')
    assign_coord = NaN(3,numel(E.mnix));
    for a = 1:numel(E.mnix)
        assign_coord(:,a) = cat(1,E.mnix(a),E.mniy(a),E.mniz(a));
    end
    
    %-implement plot
    %-------------------------------------------------------------------
    if assignment_method.plot
        figure('Name','elas: hull projection','Numbertitle','off', ...
               'color','k') 
        hold on
        % plots normalized brain for visualization    
        cS=zeros(length(FVplot.vertices),1);
        patch('Faces', FVplot.faces, 'Vertices', FVplot.vertices,...
              'EdgeColor', 'w', 'CData', cS, 'FaceColor', 'interp');
        hold on
        lightangle(45,30);
        set(gcf,'Renderer','zbuffer'); lighting phong
        set(gca,'dataaspectRatio',[1 1 1])
        set(gca,'ydir','reverse')
        set(gca,'xdir','reverse')
        camlight headlight
        view(66,2)    
        axis equal
        axis off
    end
    pause(1) 
    
    %-assignment of projected electrodes (HPA & PA)
    %-------------------------------------------------------------------
    clear F 
    F.names  = E.names;
    F.signalType = inputType;
    prelabels = cell(9,1);
    for e = 1:numel(E.names)
        Name = char(E.names{e});
        if E.mniy(e)<E.lsend && ~strcmpi(Name(end-1:end),'FR') && ...
                                             ~strcmpi(Name(end-1:end),'CS') 
            % temporo-parieto-occipital electrodes
            prelabels{1} = [prelabels{1}, e];
        elseif strcmpi(Name(end-1:end),'FR')
            % frontal electrodes
            prelabels{2} = [prelabels{2}, e];
        elseif strcmpi(Name(end-1:end),'PA')
            % parietal electrodes
            prelabels{3} = [prelabels{3}, e];
        elseif strcmpi(Name(end-1:end),'TE')
            % temporal electrodes
            prelabels{4} = [prelabels{4}, e];
        elseif E.mniy(e)>E.lsend && strcmpi(Name(end-1:end),'OC')
            % parieto-occipital electrodes 
            prelabels{5} = [prelabels{5}, e];
        elseif strcmpi(Name(end-1:end),'LS')      
            % electrodes over the lateral sulcus
            prelabels{6} = [prelabels{6}, e];
        elseif strcmpi(Name(end-1:end),'CS')      
            % electrodes over the central sulcus
            prelabels{7} = [prelabels{7}, e];
        elseif E.mniy(e)>E.lsend && strcmpi(Name(end-1:end),'FP')
            % fronto-parietal electrodes (not clearly delineated by CS)
            prelabels{8} = [prelabels{8}, e];
        elseif strcmpi(Name(end-1:end),'NA')
            % electrodes without landmark information
            prelabels{9} = [prelabels{9}, e];
        else
            sprintf(['        Bad pre-assigment for electrode #%d! ' ...
                     'Assignment skipped...\n'], e);
            prelabels{10} = [prelabels{10}, e];          
        end
    end
    prelabels{1,2} = 'parietal_occipital_temporal_v22_MPM.mat';
    prelabels{1,3} = 'parietal_occipital_temporal_v22.mritv_session.mat';
    prelabels{2,2} = 'frontal_v22_MPM.mat';
    prelabels{2,3} = 'frontal_v22.mritv_session.mat';
    prelabels{3,2} = 'parietal_occipital_v22_MPM.mat';
    prelabels{3,3} = 'parietal_occipital_v22.mritv_session.mat';
    prelabels{4,2} = 'temporal_occipital_v22_MPM.mat';
    prelabels{4,3} = 'temporal_occipital_v22.mritv_session.mat';
    prelabels{5,2} = 'parietal_occipital_temporal_v22_MPM.mat';
    prelabels{5,3} = 'parietal_occipital_temporal_v22.mritv_session.mat';
    prelabels{6,2} = 'temporal_occipital_v22_MPM.mat';
    prelabels{6,3} = 'temporal_occipital_v22.mritv_session.mat';
    prelabels{7,2} = 'frontal_parietal_v22_MPM.mat';
    prelabels{7,3} = 'frontal_parietal_v22.mritv_session.mat';
    prelabels{8,2} = 'frontal_parietal_v22_MPM.mat';
    prelabels{8,3} = 'frontal_parietal_v22.mritv_session.mat';
    prelabels{9,2} = 'all_cortical_v22_MPM.mat';
    prelabels{9,3} = 'all_cortical_v22.mritv_session.mat';
    prelabels{10,2} = '';
    prelabels{10,3} = '';
    reverseStr = '';
    elecnt = 1;
    for pl = 1:size(prelabels,1)
        if ~isempty(prelabels{pl}) && pl~=10
            load([lpath filesep prelabels{pl,2}])
            load([lpath filesep prelabels{pl,3}])
            gv = NaN(1,numel(MAP));
            for r=1:numel(MAP)           % get grey values  
                gv(r) = MAP(r).GV; 
            end
            for e = prelabels{pl}
                msg = sprintf(['ELAS>   Assigning electrodes to anatomical ' ... 
                      'areas: electrode %d/%d\n'], elecnt, numel(E.names));
                fprintf([reverseStr, msg])
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
                
                label_assign_num = [];
                x = E.mnix(e);
                y = E.mniy(e);
                z = E.mniz(e);

                [assign_num,macro_num,~,all] = electrode_assignment(...
                                         [x,y,z],gv,assignment_method,mri);
                
                
                % assign touched grey values to area
                if assign_num>0
                    assign_num_mult = unique(all(all>0));
                    assign = cell(1,numel(assign_num_mult));
                    p_area = NaN(1,numel(assign_num_mult));
                    for a = 1:numel(assign_num_mult) 
                        assign{a} = MAP(gv == assign_num_mult(a)).name;
                        p_area(a) = numel(find(all==assign_num_mult(a)))/ ...
                                    numel(all(all~=0));
                    end
                    [p_area,sortInd] = sort(p_area,'descend');
                    assign = assign(sortInd);
                    assign_num = assign_num-min(gv)+1;
                elseif assign_num == 0
                    assign = 'n.a.';
                    p_area = NaN;
                else
                    assign = 'error';
                    p_area = NaN;
                end       
                
                if pl == 6
                    sulci_tag = 'LS';
                elseif pl == 7
                    sulci_tag = 'CS';
                else
                    sulci_tag = []; 
                end               
                if macro_num > 0
                    label_assign = char(Labels{macro_num});
                    label_assign_num = macro_num;
                    label_assign_lobe = lobe(macro_num);
                elseif macro_num == 0
                    label_assign = 'n.a.';
                    label_assign_num = macro_num;
                    label_assign_lobe = 'n.a.';
                else
                    label_assign = 'error';
                    label_assign_num = NaN;
                    label_assign_lobe = 'error';
                end
                
                % PA of electrodes without info about CS/LS 
                [all_assign_num,~,proj_coord,~] = electrode_assignment( ...
                              [x,y,z],all_areas,assignment_method,mri_all); 
                if all_assign_num > 0
                    all_assign = MAP_all(gv_all == all_assign_num).name;
                    all_assign_num = all_assign_num-min(gv_all)+1;
                elseif all_assign_num == 0
                    all_assign = 'n.a.';
                else
                    all_assign = 'error';
                    all_assign_num = NaN;
                end
                
                % Results of assignment are written in F
                F.assign_coord = assign_coord;
                F.projection_coord(:,e) = proj_coord';
                F.label{e} = label_assign;
                F.label_num(e) = label_assign_num;
                F.label_num_lobe(e) = label_assign_lobe;
                F.assign{e} = assign;
                if isempty(assign_num)
                    F.assign_num(e) = NaN;
                else
                    F.assign_num(e) = assign_num;
                end
                F.p_area{e} = p_area;
                F.all_assign{e} = all_assign;
                F.all_assign_num(e) = all_assign_num;
                F.sulci{e} = sulci_tag;
                
                elecnt = elecnt + 1;
            end
       	elseif ~isempty(prelabels{pl}) && pl==10
            for e = prelabels{pl}
                fprintf(['        Bad pre-assigment for electrode #%s! ' ...
                         'Assignment skipped...\n'], char(E.names{e}))
                reverseStr = '';               
                
                % Results of assignment are written in F
                F.assign_coord = assign_coord;
                F.projection_coord(:,e) = [NaN;NaN;NaN];
                F.label{e} = 'error';
                F.assign{e} = 'error';
             	F.assign_num(e) = NaN;
                F.all_assign{e} = 'error';
                F.all_assign_num(e) = NaN;
                F.sulci{e} = 'error';
                
                elecnt = elecnt + 1;
            end
        end
    end   

elseif (PreTypeChoice == 2 || PreTypeChoice == 3) && PreAssChoice == 2
    
    %___________________________________________________________________
    %
	% Probabilisitic Assignment for grid & strip electrodes
    %___________________________________________________________________
    
    % select root paths and load variables
    %-------------------------------------------------------------------
    fprintf('ELAS>   Loading variables...\n')
    load([lpath filesep 'areasv22.mritv_session.mat'])
    load([lpath filesep 'AllAreas_v22_MPM.mat'])
	[an,ann_all] = xlsread([lpath filesep 'areas_v22.xls']);
    load([lpath filesep 'FV_no_cerebellum.mat'], 'FV', 'FVplot')
    load([lpath filesep 'Macro.mat']) 
    lobe = xlsread([lpath filesep 'Labels.xls'],'E1:E116');
    load([lpath filesep 'macrolabels.mat'])
    
    % get grey values for all areas
    %-------------------------------------------------------------------
  	gv_all = NaN(1,numel(MAP));
    for r=1:numel(MAP)           % get grey values  
        gv_all(r) = MAP(r).GV; 
    end
    all_areas = gv_all(an>=0);
    mri_all = mri;
                             
    %-define assignment method
    %-------------------------------------------------------------------
    assignment_method.method = 1;   % 1 -> purely normal based
    assignment_method.plot = 1;     % 1 -> plot normals
    assignment_method.mindist = 5;  % all hull points <= this distance 
                      % in mm are projected onto the probabilistc maps 

    
    %-get grayvalues from anatomy toolbox and assign them for HPA
    %-------------------------------------------------------------------
    load([lpath filesep 'all_cortical_v22.mritv_session.mat'])
    load([lpath filesep 'all_cortical_v22_MPM.mat'])
    gv = NaN(1,numel(MAP));
    for r=1:numel(MAP)           %grey values  
        gv(r) = MAP(r).GV; 
    end  
    clear F   

    % create assign_coord and all_assign_num looping over electrodes 
    %-------------------------------------------------------------------
    fprintf('ELAS>   Creating assignment coordinates...\n')
    assign_coord = NaN(3,numel(E.mnix));
    for a = 1:numel(E.mnix)
        assign_coord(:,a) = cat(1,E.mnix(a),E.mniy(a),E.mniz(a));
    end
    
    %-implement plot
    %-------------------------------------------------------------------
    if assignment_method.plot
        figure('Name','elas: hull projection','Numbertitle','off', ...
               'color','k') 
        hold on
        % plots normalized brain for visualization    
        cS=zeros(length(FVplot.vertices),1);
        patch('Faces', FVplot.faces, 'Vertices', FVplot.vertices,...
              'EdgeColor', 'w', 'CData', cS, 'FaceColor', 'interp');
        hold on
        lightangle(45,30);
        set(gcf,'Renderer','zbuffer'); lighting phong
        set(gca,'dataaspectRatio',[1 1 1])
        set(gca,'ydir','reverse')
        set(gca,'xdir','reverse')
        camlight headlight
        view(66,2)    
        axis equal
        axis off
    end
    pause(1) 
    
    %-assignment of projected electrodes (HPA & PA)
    %-------------------------------------------------------------------
    reverseStr = '';
    F.names  = E.names;
    F.signalType = inputType;
    for e = 1:numel(E.names)
        msg = sprintf(['ELAS>   Assigning electrodes to anatomical ' ... 
                       'areas: electrode %d/%d\n'], e, numel(E.names));
        fprintf([reverseStr, msg])
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        x = E.mnix(e);
        y = E.mniy(e);
        z = E.mniz(e);
        
        % probabilistic assignment for all cortical areas
        [assign_num,macro_num,~,all] = electrode_assignment( ...
                                         [x,y,z],gv,assignment_method,mri); 
        
        % assign touched grey values to area
        if assign_num>0
            assign_num_mult = unique(all(all~=0));
            assign = cell(1,numel(assign_num_mult));
            p_area = NaN(1,numel(assign_num_mult));
            for a = 1:numel(assign_num_mult) 
                assign{a} = ann{gv==assign_num_mult(a)};
                p_area(a) = numel(find(all==assign_num_mult(a)))/ ...
                            numel(all(all~=0));
            end
            [p_area,sortInd] = sort(p_area,'descend');
            assign = assign(sortInd);
            assign_num = assign_num-min(gv)+1;
        elseif assign_num == 0
            assign = 'n.a.';
            p_area = NaN;
        else
            assign = 'error';
            p_area = NaN;
        end 

        if macro_num > 0
            label_assign = char(Labels{macro_num});
            label_assign_num = macro_num;
            label_assign_lobe = lobe(macro_num);
        elseif macro_num == 0
            label_assign = 'n.a.';
            label_assign_num = macro_num;
            label_assign_lobe = 'n.a.';
        else
            label_assign = 'error';
            label_assign_num = NaN;
            label_assign_lobe = 'error';
        end

        % probabilistic assignment for all areas
        [all_assign_num,~,proj_coord,~] = electrode_assignment( ...
                              [x,y,z],all_areas,assignment_method,mri_all); 
        if all_assign_num > 0
            all_assign = ann_all{gv_all == all_assign_num};
            all_assign_num = all_assign_num-min(gv_all)+1;
        elseif all_assign_num == 0
            all_assign = 'n.a.';
        else
            all_assign = 'error';
            all_assign_num = NaN;
        end

        % Results of assignment are written in F
        F.assign_coord = assign_coord;
        F.projection_coord(:,e) = proj_coord';
        F.label{e} = label_assign;
        F.label_num(e) = label_assign_num;
        F.label_num_lobe(e) = label_assign_lobe;
        F.assign{e} = assign;
        if isempty(assign_num)
            F.assign_num(e) = NaN;
        else
            F.assign_num(e) = assign_num;
        end
        F.p_area{e} = p_area;
        F.all_assign{e} = all_assign;
        F.all_assign_num(e) = all_assign_num;

    end
    
elseif PreTypeChoice > 3 && PreTypeChoice < 9
    
    F.names  = E.names;
    F.signalType = inputType;
    
else
    
    msgbox('Type of assignment has to be defined!',...
       'WARNING','warn');
    fprintf('ELAS>   Done! \n')
    return    
    
end

%=======================================================================
% - check save name and save assignment variable F
%=======================================================================
if isfield(E, 'patID')
    pseuSuggest = E.patID; 
else
    pos = strfind(filenameA,'_');
    pseuSuggest = filenameA(1:pos(end-1)-1); 
end
if isfield(E, 'group')
    groupSuggest = E.group; 
else
    pos = strfind(filenameA,'_');
    groupSuggest = filenameA(pos(end-1)+1:max(pos)-1);  
end
savename = [pseuSuggest '_' groupSuggest];
F.patID = pseuSuggest;
F.group = groupSuggest;

fprintf('ELAS>   Save variable F as: %s_F.mat \n', [savename '_F.mat'])
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    uisave('F', [ELAS.OUTPUTpath filesep savename '_F.mat']);
else
    uisave('F', [pwd filesep savename '_F.mat']);
end
%=======================================================================

fprintf('ELAS>   Done! \n')