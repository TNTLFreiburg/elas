function elas_createH

% FUNCTION (under ELAS) to create header H from SDY-files, containing 
%          channel information; specific usage working for AG Ball
%
% OUTPUT
%         'H', being a [1 x 1 struct], containing information about the
%         channels 
%
%         '*savename*_H.mat'
%
% JBehncke, Apr'15


fprintf('\nELAS>   Still computing... \r');

%=======================================================================
global ELAS
%=======================================================================

%=======================================================================
% - read SDY file containing channel information
%=======================================================================
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    [filename, pathname] = uigetfile([ELAS.OUTPUTpath filesep '*.sdy'],...
             'Select SDY file containing channels information to convert');
else
    [filename, pathname] = uigetfile('*.sdy',...
             'Select SDY file containing channels information to convert');
end

if isequal([filename, pathname],[0,0])
    disp('ELAS>   ERROR: No file selected!');
    fprintf('ELAS>   Done! \r\n');
    return    
end

H = SDYreadECoG([pathname filename]);


%=======================================================================
% - load variables F for each electrode type
%=======================================================================
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    [filename, pathname] = uigetfile([ELAS.OUTPUTpath filesep '*.mat'],...
      'Select ALL *.mat files for different electrode types containing variable F',...
      'MultiSelect', 'on');
else
    [filename, pathname] = uigetfile('*.mat',...
      'Select ALL *.mat files for different electrode types containing variable F',...
      'MultiSelect', 'on');
end
if isequal([filename, pathname],[0,0])
    disp('ELAS>   ERROR: No file selected!');
    fprintf('ELAS>   Done! \r\n');
    return    
end


%=======================================================================
% - write electrode information in header variable H
%=======================================================================
if ischar(filename)
    loopSz = 1;
    load([pathname filename])
else
    loopSz = size(filename,2);
end
elecGroups = cell(loopSz,2);
for a = 1:loopSz             % for each file containing F
    
    if ~ischar(filename)
        load([pathname filename{1,a}])
    end
    
    if strcmp(F.signalType,'ECoG-Grid')
        elecGroups{a,2} = 'CAR';
    elseif strcmp(F.signalType,'SEEG') || strcmp(F.signalType,'ECoG-Strip')
        elecGroups{a,2} = 'BIP';
    else
        elecGroups{a,2} = 'CAR';
    end
    
    for b = 1:numel(F.names)           % for each electrode in F
        correctFname = F.names{1,b}(1:(max(strfind(F.names{1,b},'_'))-1));
        for k = 1:numel(H.channels)    % for each channel in header
            H.channels{1,k}.ass_cytoarchMap_stats = struct;
            if strcmpi(H.channels{1,k}.name,correctFname)
                elecGroups{a,1} = cat(2,elecGroups{a,1},k);              
                H.channels{1,k}.signalType = F.signalType;
                H.channels{1,k}.MNI_x = F.assign_coord(1,b);
                H.channels{1,k}.MNI_y = F.assign_coord(2,b);
                H.channels{1,k}.MNI_z = F.assign_coord(3,b);
                H.channels{1,k}.ass_brainAtlas = F.label{1,b};
                if isfield(F,'assign')
                    if iscell(F.assign{1,b})
                        H.channels{1,k}.ass_cytoarchMap = F.assign{1,b};
                        H.channels{1,k}.ass_cytoarchMap_stats.area = F.assign{1,b};
                    else
                        H.channels{1,k}.ass_cytoarchMap = F.assign(1,b);
                        H.channels{1,k}.ass_cytoarchMap_stats.area = F.assign(1,b);
                    end
                else
                    if iscell(F.all_assign{1,b})
                        H.channels{1,k}.ass_cytoarchMap = F.all_assign{1,b};
                        H.channels{1,k}.ass_cytoarchMap_stats.area = F.all_assign{1,b};
                    else
                        H.channels{1,k}.ass_cytoarchMap = F.all_assign(1,b);
                        H.channels{1,k}.ass_cytoarchMap_stats.area = F.all_assign(1,b);
                    end
                end    
                if isfield(F,'p_area')
                    H.channels{1,k}.ass_cytoarchMap_stats.p_area = F.p_area{1,b};
                end    
                if isfield(F,'p_bnds')
                    H.channels{1,k}.ass_cytoarchMap_stats.p_bnds = F.p_bnds{1,b};
                end
                H.channels{1,k}.sulci = F.sulci{1,b};
                if isfield(F,'matter')
                    H.channels{1,k}.ass_matterType = F.matter{1,b};
                    H.channels{1,k}.p_grayMatter = F.matter_num{1,b}(1,1);
                    H.channels{1,k}.p_whiteMatter = F.matter_num{1,b}(2,1);
                    H.channels{1,k}.p_cerebroSpinalFluid = F.matter_num{1,b}(3,1);
                else
                    H.channels{1,k}.ass_matterType = [];
                    H.channels{1,k}.p_grayMatter = [];
                    H.channels{1,k}.p_whiteMatter = [];
                    H.channels{1,k}.p_cerebroSpinalFluid = [];
                end
                if isfield(F,'projection_coord')
                    H.channels{1,k}.projection_coord = F.projection_coord(1,b);
                end 
                H.channels{1,k}.group = F.group;
            end   
        end
        
    end
    
end
H.subjName = F.patID;
for a = 1:size(H.channels,2)              % for all channels
             
    if ~isfield(H.channels{1,a},'signalType')
        if length(H.channels{1,a}.name) < 3
            H.channels{1,a}.signalType = 'EEG';
        else
            switch H.channels{1,a}.name(1:3)
                case 'EKG'
                    H.channels{1,a}.signalType = 'EKG';
                case 'ECG'
                    H.channels{1,a}.signalType = 'EKG';
                case 'EOG'
                    H.channels{1,a}.signalType = 'EOG';
                case 'EMG'
                    H.channels{1,a}.signalType = 'EMG';
                case 'Tri'
                    H.channels{1,a}.signalType = 'Trigger';
                otherwise
                    H.channels{1,a}.signalType = 'EEG';
            end
        end
    end

end


%=======================================================================
% - create matrix for spatial filter
%=======================================================================
spatialFilt = zeros(size(H.channels,2));
filtType = listdlg('PromptString','Select default spatial filter(s)',...
                   'SelectionMode','single',...
                   'ListString', {'CAR' 'CAR/BIP' 'CAR & CAR/BIP'},...               
                   'ListSize', [400 70],...
                   'Name', 'Filter type');
if isempty(filtType)
    disp('ELAS>   ERROR: No filter type selected!');
    fprintf('ELAS>   Done! \r\n');
    return    
end

switch filtType   
case 1
    
    for a = 1:size(elecGroups,1)
        for b = elecGroups{a,1}
            for c = elecGroups{a,1}
                if b == c
                    spatialFilt(b,c) = 1-1/size(elecGroups{a,1},2);
                else
                    spatialFilt(b,c) = -1/size(elecGroups{a,1},2);
                end
            end
        end
    end   
    for a = size(H.channels,2):-1:1
        if sum(spatialFilt(:,a) == 0) == size(H.channels,2)
            spatialFilt(:,a) = [];
        end
    end
    H.CARfilt = spatialFilt;
    
case 2
    
    for a = 1:size(elecGroups,1)
        if strcmp(elecGroups{a,2},'BIP')
            indVect = NaN(1,size(elecGroups{a,1},2));
            cnt = 1;
            for b = elecGroups{a,1}
                numbExtr = regexp(H.channels{1,b}.name, '\d+', 'match');
                indVect(1,cnt) = str2double(numbExtr{1,end});
                cnt = cnt + 1;
            end
            [~,grpInds] = sort(indVect);
            cnt = 1;
            for b = grpInds(1,1:end-1)
                c = elecGroups{a,1}(1,b);
                spatialFilt(c,c) = 1;
                spatialFilt(elecGroups{a,1}(1,grpInds(1,cnt+1)),c) = -1;
                cnt = cnt + 1;
            end        
        elseif strcmp(elecGroups{a,2},'CAR')
            for b = elecGroups{a,1}
                for c = elecGroups{a,1}
                    if b == c
                        spatialFilt(b,c) = 1-1/size(elecGroups{a,1},2);
                    else
                        spatialFilt(b,c) = -1/size(elecGroups{a,1},2);
                    end
                end
            end
        end
    end
    for a = size(H.channels,2):-1:1
        if sum(spatialFilt(:,a) == 0) == size(H.channels,2)
            spatialFilt(:,a) = [];
        end
    end
    H.CARBIPfilt = spatialFilt;
    
case 3
    
    for a = 1:size(elecGroups,1)
        for b = elecGroups{a,1}
            for c = elecGroups{a,1}
                if b == c
                    spatialFilt(b,c) = 1-1/size(elecGroups{a,1},2);
                else
                    spatialFilt(b,c) = -1/size(elecGroups{a,1},2);
                end
            end
        end
    end
    for a = size(H.channels,2):-1:1
        if sum(spatialFilt(:,a) == 0) == size(H.channels,2)
            spatialFilt(:,a) = [];
        end
    end
    H.CARfilt = spatialFilt;
    
    spatialFilt = zeros(size(H.channels,2));
    for a = 1:size(elecGroups,1)
        if strcmp(elecGroups{a,2},'BIP')
            indVect = NaN(1,size(elecGroups{a,1},2));
            cnt = 1;
            for b = elecGroups{a,1}
                numbExtr = regexp(H.channels{1,b}.name, '\d+', 'match');
                indVect(1,cnt) = str2double(numbExtr{1,end});
                cnt = cnt + 1;
            end
            [~,grpInds] = sort(indVect);
            cnt = 1;
            for b = grpInds(1,1:end-1)
                c = elecGroups{a,1}(1,b);
                spatialFilt(c,c) = 1;
                spatialFilt(elecGroups{a,1}(1,grpInds(1,cnt+1)),c) = -1;
                cnt = cnt + 1;
            end        
        elseif strcmp(elecGroups{a,2},'CAR')
            for b = elecGroups{a,1}
                for c = elecGroups{a,1}
                    if b == c
                        spatialFilt(b,c) = 1-1/size(elecGroups{a,1},2);
                    else
                        spatialFilt(b,c) = -1/size(elecGroups{a,1},2);
                    end
                end
            end
        end
    end
    for a = size(H.channels,2):-1:1
        if sum(spatialFilt(:,a) == 0) == size(H.channels,2)
            spatialFilt(:,a) = [];
        end
    end
    H.CARBIPfilt = spatialFilt;
    
end


%=======================================================================
% - transform into new header format
%=======================================================================
H = elas_transfH(H);


%=======================================================================
% - save header as *.mat file
%=======================================================================
savename = H.subjName;
if exist('outputpath','var')
    uisave('H',[ELAS.OUTPUTpath filesep savename '_header.mat']);
else
    uisave('H',[savename '_header.mat']);    
end
%=======================================================================

fprintf('ELAS>   Done! \n');