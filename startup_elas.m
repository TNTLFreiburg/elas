function startup_elas(varargin)

% FUNCTION to start electrode assignment toolbox ELAS and create path 
%          settings for the local computing
%
% DESCRIPTION
%         This function loads needed local settings for working with ELAS 
%         and sets global paths.
%         Until ELAS is not embedded in spm: define SPMpath
%
%
% JBehncke, July'15

%=======================================================================
% - FORMAT specifications for embedded CallBack functions
%=======================================================================
%
% FORMAT startup_elas or startup_elas('Welcome')
% Start ELAS and SPM. Only perform once!    
%
% FORMAT startup_elas or startup_elas('Elas')
% Start only ELAS without SPM.
%
% FORMAT startup_elas('GlobalPaths')
% To make sure that the paths are always available, they are set as global
% variables at the startup of the toolbox and every call of a function. 
%=======================================================================

global ELAS

%=======================================================================
% - EDIT SPM PATH HERE!!!
%======================================================================= 

%-directory to main SPM folder (...\spm8)
%------------------------------------------------------------------------
ELAS.SPMpath = 'E:\Data Joos\01_Matlab\Repository\Functions\spm12';

%-checks whether path is set
%------------------------------------------------------------------------
if ~isdir(ELAS.SPMpath)
    ELAS.SPMpath = uigetdir(pwd,...
                      'Please select spm directory...');
end


%=======================================================================
% - DEFINE PATHS
%======================================================================= 

%-directory to main ELAS toolbox folder (...\elas)
%------------------------------------------------------------------------
ELAS.ELASpath = fileparts(which(mfilename));

%-directory to main MTV folder (...\MTV)
%------------------------------------------------------------------------
if exist([ELAS.ELASpath filesep 'mtv'], 'dir')
    ELAS.MTVpath = [ELAS.ELASpath filesep 'mtv'];
else
    ELAS.MTVpath = '';
end

%-directory to main SPM folder (...\spm8)
%------------------------------------------------------------------------
% sep = regexp(ELAS.ELASpath,filesep);
% ELAS.SPMpath = ELAS.ELASpath(1:sep(end-1)-1);
% this directory will depend in final version (embedded in spm) of the spm
% working directory and therefor can not be defined now!!!

%-directory to local, personal output folder
%------------------------------------------------------------------------
if ~isfield(ELAS,'OUTPUTpath')
	ELAS.OUTPUTpath = uigetdir(pwd,...
                      'Please select directory for data output...');
end 


%-Format arguments
%-----------------------------------------------------------------------
if nargin == 0, Action = 'Welcome'; else, Action = varargin{1}; end


%=======================================================================
switch lower(Action)                  %-START SWITCH LOOP FOR PROCESSING
%=======================================================================  
    

%=======================================================================
case 'welcome'                        %-load settings at toolbox startup
%=======================================================================
% elas('Welcome')
%-----------------------------------------------------------------------

%-change dir and add working paths
%------------------------------------------------------------------------
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    if ~isdir(ELAS.OUTPUTpath)
        ELAS.OUTPUTpath = pwd;
    end
    cd(ELAS.OUTPUTpath)
end    
addpath(genpath(ELAS.ELASpath),genpath(ELAS.SPMpath));

% WARNING                                 %-WARNING - DO NOT CLOSE SPM!!!
%-----------------------------------------------------------------------
msg = sprintf(['Do NOT close SPM until computing is finished and '...
               'results are saved! \r\n']);
msgbox(msg,'WARNING','warn');

%-SPM8                                     %-start SPM8 under 'FMRI' mode
%-----------------------------------------------------------------------
spm('FMRI');

%-ELAS                               %-start electrode assignment toolbox
%-----------------------------------------------------------------------
elas;


%=======================================================================
case 'elas'                           %-load settings at toolbox startup
%=======================================================================
% elas('Elas')
%-----------------------------------------------------------------------

%-change dir and add working paths
%------------------------------------------------------------------------
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    cd(ELAS.OUTPUTpath);
end    
addpath(genpath(ELAS.ELASpath),genpath(ELAS.SPMpath));

%-ELAS                               %-start electrode assignment toolbox
%-----------------------------------------------------------------------
elas;


%=======================================================================
case 'globalpaths'                            %-set global working paths
%=======================================================================
% elas('GlobalPaths')
%-----------------------------------------------------------------------

%-directory to ELAS toolbox folder 'toolbox'
%-----------------------------------------------------------------------
ELAS.ASSIGNMENTSCRIPTpath = [ELAS.ELASpath filesep 'toolbox'];

%-directory to SPM toolbox folder 'Anatomy'
%-----------------------------------------------------------------------
ELAS.SPMANApath = [ELAS.SPMpath filesep 'toolbox' filesep 'Anatomy'];


%=======================================================================
otherwise                                        %-Unknown action string
%=======================================================================
msg = [Action ': Unknown action string for using startup_elas'];
error(msg);

%=======================================================================
end
