function [H] = elas_getallF

% FUNCTION (under ELAS) to create header, containing information of all  
%          different electrode groups (stored in F files)
%
% OUTPUT
%         '*savename*_H.mat'
%
% JBehncke, June'18


%=======================================================================
global ELAS
%=======================================================================


ELAS.OUTPUTpath = 'E:\Data Joos\01_Matlab\Repository\git\elas_open';
%=======================================================================
% - load variables F for each electrode type
%=======================================================================
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    [filename, pathname] = uigetfile([ELAS.OUTPUTpath filesep '*.mat'],...
      ['Select ALL *.mat files for different electrode types containing' ...
      ' variable F'], 'MultiSelect', 'on');
else
    [filename, pathname] = uigetfile('*.mat',...
      ['Select ALL *.mat files for different electrode types containing' ...
      ' variable F'], 'MultiSelect', 'on');
end
if isequal([filename, pathname],[0,0])
    disp('ELAS>   ERROR: No file selected!');
    H = [];
    return    
end

%=======================================================================
% - enter subject name
%=======================================================================
%-guess pseudonym
%-----------------------------------------------------------------------
if ischar(filename) 
    pos = strfind(filename,'_');
    if isempty(pos)
        pseuSuggest = '';
    else
        pseuSuggest = filename(1:pos(end-1)-1); 
    end
    loopSz = 1;
    load([pathname filename])
else
    pos = strfind(filename{1,1},'_');
    if isempty(pos)
        pseuSuggest = '';
    else
        pseuSuggest = filename{1,1}(1:pos(end-1)-1);  
    end
    loopSz = size(filename,2);
    load([pathname filename{1,1}])
end
if isfield(F, 'patID')
    H.subjName = F.patID;
else
    inputH = inputdlg({'Enter pseudonym of patient:'},...
                    'Input',1,{pseuSuggest});
    if isempty(inputH)
        disp('ELAS>   ERROR: No pseudonym defined!');
        H = [];
        return    
    end
    H.subjName = inputH{1,1};
end
H.triggerCH = [];

%=======================================================================
% - write electrode information in header variable H
%=======================================================================
cnt = 1;
for a = 1:loopSz             % for each file containing F  
    if ~ischar(filename)
        load([pathname filename{1,a}])
    end
    for b = 1:numel(F.names)           % for each electrode in F
        correctFname = F.names{1,b}(1:(max(strfind(F.names{1,b},'_'))-1));
        H.channels(1,cnt).name = correctFname;
        H.channels(1,cnt).signalType = F.signalType;
        H.channels(1,cnt).MNI_x = F.assign_coord(1,b);
        H.channels(1,cnt).MNI_y = F.assign_coord(2,b);
        H.channels(1,cnt).MNI_z = F.assign_coord(3,b);
        H.channels(1,cnt).ass_brainAtlas = F.label{1,b};
        if isfield(F,'assign')
            if iscell(F.assign{1,b})
                H.channels(1,cnt).ass_cytoarchMap = F.assign{1,b};
                H.channels(1,cnt).ass_cytoarchMap_stats.area = F.assign{1,b};
            else
                H.channels(1,cnt).ass_cytoarchMap = F.assign(1,b);
                H.channels(1,cnt).ass_cytoarchMap_stats.area = F.assign(1,b);
            end
        else  
            if iscell(F.all_assign{1,b})
                H.channels(1,cnt).ass_cytoarchMap = F.all_assign{1,b};
                H.channels(1,cnt).ass_cytoarchMap_stats.area = F.all_assign{1,b};
            else
                H.channels(1,cnt).ass_cytoarchMap = F.all_assign(1,b);
                H.channels(1,cnt).ass_cytoarchMap_stats.area = F.all_assign(1,b);
            end
        end    
        if isfield(F,'p_area')
            H.channels(1,cnt).ass_cytoarchMap_stats.p_area = F.p_area{1,b};
        end    
        if isfield(F,'p_bnds')
            H.channels(1,cnt).ass_cytoarchMap_stats.p_bnds = F.p_bnds{1,b};
        end
        H.channels(1,cnt).sulci = F.sulci{1,b};
        if isfield(F,'matter')
            H.channels(1,cnt).ass_matterType = F.matter{1,b};
            H.channels(1,cnt).p_grayMatter = F.matter_num{1,b}(1,1);
            H.channels(1,cnt).p_whiteMatter = F.matter_num{1,b}(2,1);
            H.channels(1,cnt).p_cerebroSpinalFluid = F.matter_num{1,b}(3,1);
        else
            H.channels(1,cnt).ass_matterType = [];
            H.channels(1,cnt).p_grayMatter = [];
            H.channels(1,cnt).p_whiteMatter = [];
            H.channels(1,cnt).p_cerebroSpinalFluid = [];
        end
        if isfield(F,'projection_coord')
            H.channels(1,cnt).projection_coord = F.projection_coord(1,b);
        end 
        H.channels(1,cnt).group = F.group;
        cnt = cnt + 1;
    end   
end


%=======================================================================
% - save header as *.mat file
%=======================================================================
savename = H.subjName;
if exist('outputpath','var')
    uisave('H',[ELAS.OUTPUTpath filesep savename '_H.mat']);
else
    uisave('H',[savename '_H.mat']);    
end
%=======================================================================