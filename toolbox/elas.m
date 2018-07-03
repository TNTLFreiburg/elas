function varargout = elas(varargin)

% toolbox for electrode assignment                ____  _      _    ____
%                                                | ___|| |    / \  |  __)
%                                                | _|_ | |_  / 0 \ |__  |
%                                                |____/|___/|_| |_/(____/
%
% FUNCTION for localization and assignment of intracranial electrodes. 
%          This is done by using SPM12 (see below). Post-implantation and 
%          pre-implantation (only for depth electrodes) images are needed 
%          for processing. Details for use of software see manual and: 
%           
%          Kern, Behncke et al. 
%
%          This version runs with MATLAB SPM12.
%
% SOFTWARE
%         ELAS (electrode assignment toolbox), software available under
%         
%
%         SPM (statistical parametric mapping), software available under
%         http://www.fil.ion.ucl.ac.uk/spm/software/spm12/
%         
% OUTPUT
%         intermediate
%
%         'c*.img', 'w*.img',...: different types of images after doing
%         the processing steps in spm
%
%         'E': struct, containing all information about coordinates
%         (therefor also a file named '*_E.mat' will be created) 
%
%         final
%
%         'F': struct, containing all information about assignments
%         (therefor also a file named '*_F.mat' will be created) 
%
%         'H': header struct, containing all information about the
%         channels (therefor also a file named '*_H.mat' will be created) 
%
% ORDER OF PROCESSING
%         [1] CO-REGISTRATION, NORMALIZATION and if so SEGMENTATION (SPM)
%         [2] EXTRACTION OF ELECTRODE- AND SULCI-COORDINATES
%         [3] ASSIGNMENT OF ELECTRODE NAMES TO EXTRACTED POSITIONS
%         [4.1] HIERARCHICAL PROBABILISTIC ASSIGNMENT OF ELECTRODES or
%         [4.2] PROBABILISTIC ASSIGNMENT OF (DEPTH) ELECTRODES
%         [5] VISUALIZATUION OF ELECTRODES AND BRAIN AREAS
%
%
% JBehncke, June'18


%=======================================================================
% - FORMAT specifications for embedded CallBack functions
%=======================================================================
%
% FORMAT elas('Welcome')
% Open welcome screen.           
%
% FORMAT elas('AnaAssign')
% Enter anatomical electrode assignment mode. elas('AnaAssign') starts
% assignment script with choice for HPA or PA.
%
% FORMAT elas('Anatomy')
% Start SPM Anatomy toolbox.     
%
% FORMAT elas('ConvImg')
% Convert img --> nii and nii --> img.  
%
% FORMAT elas('createH', hform)
% Create header variable H. If hform is not set, elas('createH') delivers 
% default header format.
% - hform: header format {'agb', 'default'}
%
% FORMAT elas('Dir',Mfile)
% Find directory of file Mfile, which has to be in MATLAB path. If Mfile  
% is not set, elas('Dir') delivers directory of elas toolbox.
% - Mfile: name of file to search for 
%
% FORMAT elas('MTV')
% Start MTV.           
%
% FORMAT elas('NameAssign')
% Enter name assignment mode.           
%
% FORMAT elas('SPM')
% Start SPM in fMRI mode.           
%
% FORMAT elas('Quit')
% Quit electrode assignment toolbox and clear the command window.     
%
% FORMAT elas('Viz')
% Start visualization GUI.
%
%=======================================================================


%-Define global variables
%-----------------------------------------------------------------------
startup_elas('GlobalPaths');
global ELAS

%-Format arguments
%-----------------------------------------------------------------------
if nargin == 0, Action = 'Welcome'; else, Action = varargin{1}; end


%=======================================================================
switch lower(Action)                  %-START SWITCH LOOP FOR PROCESSING
%=======================================================================  
    

%=======================================================================
case 'welcome'                                   %-Welcome splash screen
%=======================================================================
% elas('Welcome')
%-----------------------------------------------------------------------
clc
disp('  ____  _      _    ____');
disp(' | ___|| |    / \  |  __)');
disp(' | _|_ | |_  / 0 \ |__  |');
disp(' |____/|___/|_| |_/(____/');
fprintf('\n Starting electrode assignment toolbox...\r')

%-Open startup window, set window defaults
%-----------------------------------------------------------------------
elaswelcome = openfig(fullfile(elas('Dir'), 'welcome_elas.fig'), ...
                                                    'new', 'invisible');
set(elaswelcome,'name',sprintf('%s','electrode assignment tb'));
set(elaswelcome,'Units','pixels','Position',[609 645 540 465]);
set(elaswelcome,'Visible','on');
fprintf(' Ready!\r')

    
%=======================================================================
case 'anaassign'            %-assignment of electrodes to anatomic areas
%=======================================================================
% elas('AnaAssign')
%-----------------------------------------------------------------------
elas_elecass;


%=======================================================================
case 'anatomy'                               %-start SPM anatomy toolbox
%=======================================================================
% elas('Anatomy')
%-----------------------------------------------------------------------
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    cd(ELAS.OUTPUTpath);
end
if exist([ELAS.SPMpath filesep 'toolbox' filesep 'Anatomy'], 'dir')
    Anatomy;
else
    warning('off','backtrace')
    warning('Anatomy toolbox is probably not installed: check status!')
 	warning('on','backtrace')
    fprintf('ELAS>   Done! \r')
end


%=======================================================================
case 'convimg'                     %-convert img --> nii and nii --> img
%=======================================================================
% elas('ConvImg')
%-----------------------------------------------------------------------
fprintf('ELAS>   Still computing... \r')
convert_image;
fprintf('ELAS>   Done! \r')


%=======================================================================
case 'createh'                                %-create header variable H
%=======================================================================
% elas('createH', hform)
%-----------------------------------------------------------------------
if nargin<2 || strcmp(varargin{2}, 'default') 
    fprintf('ELAS>   Still computing... \r')
    [~] = elas_getallF;
    fprintf('ELAS>   Done! \r\n')
elseif strcmp(varargin{2}, 'agb')
    elas_createH;
else
    warning('off','backtrace')
    warning('Unknown header format: %s!', varargin{2})
 	warning('on','backtrace')
    fprintf('ELAS>   Done! \r')
end


%=======================================================================
case 'dir'                                 %-Identify specific directory
%=======================================================================
% elas('Dir',Mfile)
%-----------------------------------------------------------------------
if nargin<2, Mfile='elas'; else Mfile=varargin{2}; end
elasdir = which(Mfile);
if isempty(elasdir)                 %-Not found or full pathname given
    if exist(Mfile,'file')==2       %-Full pathname
        elasdir = Mfile;
    else
        error(['Can''t find ',Mfile,' on MATLABPATH']);
    end
end
elasdir    = fileparts(elasdir);
varargout = {elasdir};

    
%=======================================================================
case 'mtv'                                                   %-start MTV
%=======================================================================
% elas('MTV')
%-----------------------------------------------------------------------
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    cd(ELAS.OUTPUTpath);
    fprintf('ELAS>   Still computing... \r')
end
if exist([ELAS.ELASpath filesep 'mtv'], 'dir')
    fprintf('ELAS>   Starting MTV... \r')
    MTV;
else
    warning('off','backtrace')
    warning(['MTV is probably not installed or not installed into ' ...
            'folder %s!\r'], [ELAS.ELASpath filesep 'mtv'])
 	warning('on','backtrace')
    fprintf('ELAS>   Done! \r')
end

    
%=======================================================================
case 'nameassign'           %-assignment of electrode names to positions
%=======================================================================
% elas('NameAssign')
%-----------------------------------------------------------------------
elas_namesass;


%=======================================================================
case 'spm'                                                  %-start SPM8
%=======================================================================
% elas('SPM')
%-----------------------------------------------------------------------
msgbox(['Make sure to save results before closing SPM or leave it '...
       'open until finished with whole processing pipeline!'],...
       'WARNING','warn'); 
spm('FMRI');


%=======================================================================
case 'quit'                                     %-Quit elas and clean up
%=======================================================================
% elas('Quit')
%-----------------------------------------------------------------------
% close(gcf)
local_clc
fprintf('ELAS>   Closing electrode assignment toolbox...\n')
fprintf('ELAS>   Bye!\n')


%=======================================================================
case 'viz'                                         %-start visualization
%=======================================================================
% elas('viz')
%-----------------------------------------------------------------------
elas_visualization


%=======================================================================
otherwise                                        %-Unknown action string
%=======================================================================
msg = [Action ': Unknown action string for using elas'];
error(msg)

%=======================================================================
end


%=======================================================================
function local_clc                                %-Clear command window
%=======================================================================
if ~isdeployed
    clc
end







