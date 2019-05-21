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
        'ListString', {'Hierarchical Probabilistic Assignment (HPA)',...
                       'Probabilistic Assignment incl projection',...
                       'Probabilistic Assignment'},...
        'ListSize', [400 45],...
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
% - check for matter assignment
%=======================================================================
% Assignment of electrodes to the type of matter by using images after
% segmentation. Every pixel in the pre-implantation image corresponds to 
% a certain type.
%-----------------------------------------------------------------------
mquest = questdlg('Integrate information from segmentation?', ...
                      'Matter type', 'Yes', 'No', 'Yes');
if strcmp(mquest, 'Yes')              
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
end
   
%=======================================================================
% - start selected area assignment loop
%=======================================================================
lpath = ELAS.ASSIGNMENTSCRIPTpath;
if PreTypeChoice == 1 || PreAssChoice == 3
    
    %___________________________________________________________________
    %
    % Probabilisitic Assignment for all electrodes types, without 
    % cortical projection
    %___________________________________________________________________
    
    % Create assignment variable 'F', containing the MNI coordinates and 
    % the electrode names, as well as the names of the assigned anatomic 
    % regions and the matter type.
    mth = 'dpa';

    %-load and define needed assignment variables out of toolbox
    %-------------------------------------------------------------------
    fprintf('ELAS>   Loading variables...\n')
    load([lpath filesep 'areasv22.mritv_session.mat'])
    load([lpath filesep 'AllAreas_v22_MPM.mat'])
    load([lpath filesep 'Macro.mat'])
    load([lpath filesep 'macrolabels.mat'])
    load([lpath filesep 'FV_no_cerebellum.mat'], 'FV', 'FVplot')
    
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
    if strcmp(mquest, 'Yes')
        F.matter = matter;
        F.matter_num = matter_num;
    end
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

elseif PreAssChoice == 1
    
    %___________________________________________________________________
    %
	% HPA for grid & strip electrodes
    %___________________________________________________________________
    mth = 'hpa';
    
    % select root paths and load variables
    %-------------------------------------------------------------------
    if strcmp(E.lsend, 'n.a.')
        warning(['End point of horizontal ramus has to be defined for' ...
                 ' HPA mode! Check variable ''E.lsend...'''])
        fprintf('ELAS>   Done! \n')
        return
    end
    fprintf('ELAS>   Loading variables...\n')
	load([lpath filesep 'areasv22.mritv_session.mat'],'mri')
    load([lpath filesep 'AllAreas_v22_MPM.mat'],'MAP')
    load([lpath filesep 'areas_v22.mat'])
    load([lpath filesep 'Labels.mat'])
    load([lpath filesep 'FV_no_cerebellum.mat'], 'FV', 'FVplot')
    load([lpath filesep 'Macro.mat'],'Labels')
    load([lpath filesep 'macrolabels.mat'],'macrolabel')
    load([lpath filesep 'indimaps.mat'],'MAPbins','MAPnames')
    
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
    prelabels{1,2} = 5; prelabels{1,3} = MAPnames{5};
    prelabels{2,2} = 1; prelabels{2,3} = MAPnames{1};
    prelabels{3,2} = 2; prelabels{3,3} = MAPnames{2};
    prelabels{4,2} = 4; prelabels{4,3} = MAPnames{4};
    prelabels{5,2} = 5; prelabels{5,3} = MAPnames{5};
    prelabels{6,2} = 4; prelabels{6,3} = MAPnames{4};
    prelabels{7,2} = 3; prelabels{7,3} = MAPnames{3};
    prelabels{8,2} = 3; prelabels{8,3} = MAPnames{3};
    prelabels{9,2} = 6; prelabels{9,3} = MAPnames{6};
    prelabels{10,2} = ''; prelabels{10,3} = '';
    
    reverseStr = '';
    elecnt = 1;
    for pl = 1:size(prelabels,1)
        if ~isempty(prelabels{pl}) && pl~=10
            
            %-create individual probability MAP (IPM)
            MAP = MAP_all(1,logical(MAPbins(:,prelabels{pl,2})));

            for e = prelabels{pl}
                msg = sprintf(['ELAS>   Assigning electrodes to anatomical ' ... 
                      'areas: electrode %d/%d\n'], elecnt, numel(E.names));
                fprintf([reverseStr, msg])
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
                
				% HPA for individual areas, incl projection
				%------------------------------------------              
                %-MNI -> Anatomical MNI; for this step, coordinates  
                % E.mni are expected to be MNIs
                E.mniy(e) = E.mniy(e)-4; E.mniz(e) = E.mniz(e)+5;
                %-perform cortical projection
                [assign_num,macro_num,proj_coord,~,Call] = ...
                           elas_cortical_projection(...
                           [E.mnix(e) E.mniy(e) E.mniz(e)], ...
                           all_areas,assignment_method,mri_all);
                              
%                 XYZmm = [Call(:,1) Call(:,2)-4 Call(:,3)+5]';
                XYZmm = [Call(:,1) Call(:,2) Call(:,3)]';
                xyz = inv(MAP_all(1).MaxMap.mat) * ...
                                [XYZmm; ones(1,size(XYZmm,2))];
                            
                %-get probability maps for individual areas
                ProbMax = NaN(size(xyz,2),size(MAP,2));
                for PM = 1:size(MAP,2)
                    ProbMax(1:size(xyz,2),PM) = spm_sample_vol( ...
                              MAP(PM).PMap,xyz(1,:),xyz(2,:),xyz(3,:),0)';
                end
                
                %-probabilistic assignment, based on individual areas
                tempProbs = zeros(size(ProbMax));
                for indxx  = 1:size(XYZmm,2) 
                    if any(ProbMax(indxx,:))
                        Probs = find(ProbMax(indxx,1:end)>0); 
                        for getPr = Probs
                            [Ploc,~,~] = Min_Max(MAP( ...
                                              getPr).PMap,xyz(:,indxx));
                            tempProbs(indxx,getPr) = Ploc;
                        end
                    end
                end
                
                %-get areas and probabilities
                areaProbs = mean(tempProbs,1);
                goalAreas = find(areaProbs>0);
                if ~isempty(goalAreas)
                    [~,sortP] = sort(areaProbs(goalAreas),'descend');
                    assign = cell(1,size(goalAreas,2));
                    p_area = NaN(1,size(goalAreas,2));
                    for getPr = 1:size(goalAreas,2)
                        assign{getPr} = MAP(goalAreas(sortP(getPr))).name;
                        p_area(getPr) = areaProbs(goalAreas(sortP(getPr)));
                    end
                else
                    assign = 'n.a.';
                    p_area = NaN;
                end    
                
                %-define sulci tag
                if pl == 6
                    sulci_tag = 'LS';
                elseif pl == 7
                    sulci_tag = 'CS';
                else
                    sulci_tag = []; 
                end               
                
                %-get macroanatomic labels
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

                % PA for all areas, incl projection
				%------------------------------------------
                %-get probability maps for all areas
                ProbMax = NaN(size(xyz,2),size(MAP_all,2));
                for PM = 1:size(MAP_all,2)
                    ProbMax(1:size(xyz,2),PM) = spm_sample_vol( ...
                           MAP_all(PM).PMap,xyz(1,:),xyz(2,:),xyz(3,:),0)';
                end
                
                %-probabilistic assignment, based on all areas
                tempProbs = zeros(size(ProbMax));
                for indxx  = 1:size(XYZmm,2) 
                    if any(ProbMax(indxx,:))
                        Probs = find(ProbMax(indxx,1:end)>0); 
                        for getPr = Probs
                            [Ploc,~,~] = Min_Max(MAP_all( ...
                                              getPr).PMap,xyz(:,indxx));
                            tempProbs(indxx,getPr) = Ploc;
                        end
                    end
                end
                
                %-get areas and probabilities
                areaProbs = mean(tempProbs,1);
                goalAreas = find(areaProbs>0);
                if ~isempty(goalAreas)
                    [~,sortP] = sort(areaProbs(goalAreas),'descend');
                    all_assign = cell(1,size(goalAreas,2));
                    p_area = NaN(1,size(goalAreas,2));
                    for getPr = 1:size(goalAreas,2)
                        all_assign{getPr} = MAP_all( ...
                                        goalAreas(sortP(getPr))).name;
                     	all_p_area(getPr) = areaProbs( ...
                                                goalAreas(sortP(getPr)));
                    end
                else
                    all_assign = 'n.a.';
                    all_p_area = NaN;
                end  
                    
                if assign_num>0
                    assign_num = assign_num-min(all_areas)+1;
                    all_assign_num = assign_num-min(all_areas)+1;
                else
                    all_assign_num = NaN;
                end
                
                %-results of assignment are written in F
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
                F.all_p_area{e} = all_p_area;
                if strcmp(mquest, 'Yes')
                    F.matter = matter;
                    F.matter_num = matter_num;
                end
                F.sulci{e} = sulci_tag;
                
                elecnt = elecnt + 1;
            end
       	elseif ~isempty(prelabels{pl}) && pl==10
            for e = prelabels{pl}
                fprintf(['        Bad pre-assigment for electrode #%s! ' ...
                         'Assignment skipped...\n'], char(E.names{e}))
                reverseStr = '';               
                
                %-results of assignment are written in F
                F.assign_coord = assign_coord;
                F.projection_coord(:,e) = [NaN;NaN;NaN];
                F.label{e} = 'error';
                F.assign{e} = 'error';
             	F.assign_num(e) = NaN;
                F.all_assign{e} = 'error';
                F.all_assign_num(e) = NaN;
                F.matter = 'error';
                F.matter_num = 'error';
                F.sulci{e} = 'error';
                
                elecnt = elecnt + 1;
            end
        end
    end   

elseif PreAssChoice == 2
    
    %___________________________________________________________________
    %
	% Probabilisitic Assignment for grid & strip electrodes, including 
    % the cortical projection
    %___________________________________________________________________   
    mth = 'pa';
    
    % select root paths and load variables
    %-------------------------------------------------------------------
    fprintf('ELAS>   Loading variables...\n')
    load([lpath filesep 'areasv22.mritv_session.mat'])
    load([lpath filesep 'AllAreas_v22_MPM.mat'])
    load([lpath filesep 'areas_v22.mat'])
    load([lpath filesep 'Labels.mat'])
    load([lpath filesep 'FV_no_cerebellum.mat'], 'FV', 'FVplot')
    load([lpath filesep 'Macro.mat'],'Labels')
    load([lpath filesep 'macrolabels.mat'],'macrolabel')
    load([lpath filesep 'indimaps.mat'],'MAPbins','MAPnames')
    
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
	reverseStr = '';
    F.names  = E.names;
    F.signalType = inputType;
    %-create individual probability MAP (IPM) for cortical areas
    MAP = MAP_all(1,logical(MAPbins(:,6)));
    for e = 1:numel(E.names)
        msg = sprintf(['ELAS>   Assigning electrodes to anatomical ' ... 
                       'areas: electrode %d/%d\n'], e, numel(E.names));
        fprintf([reverseStr, msg])
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
		
		% PA assignment for cortical areas, incl projection
		%---------------------------------------------------
        %-MNI -> Anatomical MNI; for this step, coordinates  
        % E.mni are expected to be MNIs
        E.mniy(e) = E.mniy(e)-4; E.mniz(e) = E.mniz(e)+5;
		%-perform cortical projection
		[assign_num,macro_num,proj_coord,~,Call] = ...
				   elas_cortical_projection(...
				   [E.mnix(e) E.mniy(e) E.mniz(e)], ...
				   all_areas,assignment_method,mri_all);
		

% 		XYZmm = [Call(:,1) Call(:,2)-4 Call(:,3)+5]';
        XYZmm = [Call(:,1) Call(:,2) Call(:,3)]';
		xyz = inv(MAP_all(1).MaxMap.mat) * ...
						[XYZmm; ones(1,size(XYZmm,2))];
					
		%-get probability maps for cortical areas
		ProbMax = NaN(size(xyz,2),size(MAP,2));
		for PM = 1:size(MAP,2)
			ProbMax(1:size(xyz,2),PM) = spm_sample_vol( ...
					  MAP(PM).PMap,xyz(1,:),xyz(2,:),xyz(3,:),0)';
		end
		
		%-probabilistic assignment, based on cortical areas
		tempProbs = zeros(size(ProbMax));
		for indxx  = 1:size(XYZmm,2) 
			if any(ProbMax(indxx,:))
				Probs = find(ProbMax(indxx,1:end)>0); 
				for getPr = Probs
					[Ploc,~,~] = Min_Max(MAP( ...
									  getPr).PMap,xyz(:,indxx));
					tempProbs(indxx,getPr) = Ploc;
				end
			end
		end
		
		%-get areas and probabilities
		areaProbs = mean(tempProbs,1);
		goalAreas = find(areaProbs>0);
		if ~isempty(goalAreas)
			[~,sortP] = sort(areaProbs(goalAreas),'descend');
			assign = cell(1,size(goalAreas,2));
			p_area = NaN(1,size(goalAreas,2));
			for getPr = 1:size(goalAreas,2)
				assign{getPr} = MAP(goalAreas(sortP(getPr))).name;
				p_area(getPr) = areaProbs(goalAreas(sortP(getPr)));
			end
		else
			assign = 'n.a.';
			p_area = NaN;
		end  	

		%-get macroanatomic labels
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
	
		% PA assignment for all areas, incl projection
		%---------------------------------------------------
		%-get probability maps for all areas
		ProbMax = NaN(size(xyz,2),size(MAP_all,2));
		for PM = 1:size(MAP_all,2)
			ProbMax(1:size(xyz,2),PM) = spm_sample_vol( ...
				   MAP_all(PM).PMap,xyz(1,:),xyz(2,:),xyz(3,:),0)';
		end
		
		%-probabilistic assignment, based on all areas
		tempProbs = zeros(size(ProbMax));
		for indxx  = 1:size(XYZmm,2) 
			if any(ProbMax(indxx,:))
				Probs = find(ProbMax(indxx,1:end)>0); 
				for getPr = Probs
					[Ploc,~,~] = Min_Max(MAP_all( ...
									  getPr).PMap,xyz(:,indxx));
					tempProbs(indxx,getPr) = Ploc;
				end
			end
		end
		
		%-get areas and probabilities
		areaProbs = mean(tempProbs,1);
		goalAreas = find(areaProbs>0);
		if ~isempty(goalAreas)
			[~,sortP] = sort(areaProbs(goalAreas),'descend');
			all_assign = cell(1,size(goalAreas,2));
			p_area = NaN(1,size(goalAreas,2));
			for getPr = 1:size(goalAreas,2)
				all_assign{getPr} = MAP_all( ...
								goalAreas(sortP(getPr))).name;
				all_p_area(getPr) = areaProbs( ...
										goalAreas(sortP(getPr)));
			end
		else
			all_assign = 'n.a.';
			all_p_area = NaN;
		end  
			
		if assign_num>0
			assign_num = assign_num-min(all_areas)+1;
			all_assign_num = assign_num-min(all_areas)+1;
        else
            all_assign_num = NaN;
		end

        %-results of assignment are written in F
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
		F.all_p_area{e} = all_p_area;
        if strcmp(mquest, 'Yes')
            F.matter = matter;
            F.matter_num = matter_num;
        end
		F.sulci{e} = [];

    end
    
elseif PreTypeChoice > 3 && PreTypeChoice < 9
    
    mth = 'no';
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
    F.patID = E.patID; 
else
    answer = inputdlg({'Enter patient ID:'},'Input',[1 35],{'patient ID'});
    F.patID = answer{1};
end
if isfield(E, 'group')
    F.group = E.group;
else
    answer = inputdlg({'Enter group name:'},'Input',[1 35],{'group'});
    F.group = answer{1};
end
savename = [F.patID '_' F.group '_' mth];

fprintf('ELAS>   Save variable F as: %s_F.mat \n', [savename '_F.mat'])
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    uisave('F', [ELAS.OUTPUTpath filesep savename '_F.mat']);
else
    uisave('F', [pwd filesep savename '_F.mat']);
end
%=======================================================================

fprintf('ELAS>   Done! \n')