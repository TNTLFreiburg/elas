function export_mni_mtv

% FUNCTION to transform mni coordinates from MTV into ELAS format
%
% SYNTAX
%         export_mni_mtv 
%
% DESCRIPTION
%         This function is based on the MTV environment and its global
%         variable 'mri'. To extract the mni coordinates, the corresponding
%         MTV session (and only this one!) has to be opened to have access
%         to the stored coordinates.
%
%         MTV, Mri TeleVision, MATLAB user interface by Tonio Ball
%
% OUTPUT
%         '*savename*_mri_coords.mat'
%
% JBehncke, June'18

fprintf('\n        Still computing... \r');

%=======================================================================
global mri	
%=======================================================================

%=======================================================================
% - get mri data and transform (AG BALL, using MTV mri data)
%=======================================================================
% MNI origin of MRI data (Freiburg): [79 113 51]
% MNI origin of MPMs: [76 116 64]
% extract color values for electrodes and sulci 
%-----------------------------------------------------------------------
MTVopen = questdlg(['Make sure MTV is open and the current electrode '...
                   'session loaded. Is it?'],'MTV open?','Yes','No','Yes');

if strcmpi(MTVopen,'Yes')  
    % get yellow markers (electrodes)
    %-------------------------------------------------------------------
    rdata = mri.overlay(1).data(:,:,:,1); 
    gdata = mri.overlay(1).data(:,:,:,2); 
    rxyz = find(rdata==255);        % extract indices with red=255
    gxyz = find(gdata==255);        % extract indices with green=255
    ydata = intersect(rxyz,gxyz);   % find intersection (yellow)
    mri_dat.X = mri.XYZ(1,ydata);   % MNI coordinates
    mri_dat.Y = mri.XYZ(2,ydata);
    mri_dat.Z = mri.XYZ(3,ydata);
    if size(mri_dat.X,2) ~= 1
        mri_dat.X = mri_dat.X';
        mri_dat.Y = mri_dat.Y';
        mri_dat.Z = mri_dat.Z';
    end
    sulci = questdlg('Does mri data include sulci?',  ...
                     'Select sulci option','Yes','No','Yes');
    % get green markers (sulci) 
    %-------------------------------------------------------------------
    if strcmp(sulci, 'Yes')
        gdata(ydata) = 0;           % set yellow points to zero
        ydata = find(gdata);        % find rest values (only green left)
        mri_dat.sX = mri.XYZ(1,ydata);   % MNI coordinates
        mri_dat.sY = mri.XYZ(2,ydata);
        mri_dat.sZ = mri.XYZ(3,ydata);
        if size(mri_dat.sX,2) ~= 1
            mri_dat.sX =mri_dat. sX';
            mri_dat.sY = mri_dat.sY';
            mri_dat.sZ = mri_dat.sZ';
        end
    end
    % get pseudonym and name of electrode group
    %-------------------------------------------------------------------
    while 1          
        inputAss = inputdlg({'Enter pseudonym of patient:'...
                             'Enter name of electrode group:'},'Input', ...
                             1,{'patient ID' 'group'});                        
        if isempty(inputAss)
            fprintf(['        ERROR: Pseudonym and electrode group have' ...
                                                      ' to be named! \n']);
        else
            break
        end    
    end
    mri_dat.patID = inputAss{1,1};
    mri_dat.group = inputAss{2,1};
    % save data
    %-------------------------------------------------------------------
    savename = [mri_dat.patID '_' mri_dat.group '.mri_coords.mat'];
    uisave('mri_dat', savename) 
else
    fprintf('ELAS>   Done! \n');
    return
end