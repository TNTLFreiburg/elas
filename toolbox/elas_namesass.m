function [E] = elas_namesass

% FUNCTION (under ELAS) to assign electrode names to extracted positions
%
% DESCRIPTION In this step, electrode names are assigned to extracted 
%          positions and electrodes are pre-allocated to lobes. 
%          The variable 'E' is the essential output and will be saved and 
%          used for further processing.
%
% INPUT
%          '*.mat'-file has to be loaded, containing coordinates in values 
%          of the MNI space:
%          mni_dat = struct(...
%                     X, ...      (nx1 double) x-coords, electrodes
%                     Y, ...      (nx1 double) y-coords, electrodes
%                     Z, ...      (nx1 double) z-coords, electrodes
%                     sX, ...     (nx1 double) x-coords, sulci (optional)
%                     sX, ...     (nx1 double) y-coords, sulci (optional)
%                     sX, ...     (nx1 double) z-coords, sulci (optional)
%                     patID, ...  'str', patient ID (optional)
%                     group)      'str', name of electrode group (optional)                    
%
% OUTPUT
%          '*savename*_E.mat'
%
% JBehncke, June'18 (TBall, HRuescher)

fprintf('\nELAS>   Still computing... \r')

%=======================================================================
global ELAS
%=======================================================================

%=======================================================================
% - load mri variable, colormap & surface
%=======================================================================
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    [filename, pathname] = uigetfile([ELAS.OUTPUTpath filesep '*.mat'],...
                                    'Select file containing mri variable');
else
    [filename, pathname] = uigetfile('*.mat',...
                                    'Select file containing mri variable');
end
if isequal([filename,pathname],[0,0])
    msgbox('No file selected!','WARNING','warn');
    fprintf('ELAS>   Done! \n')
    return  
end 
sulci = questdlg('Does mri data include sulci?', 'Select sulci option', ...
                 'Yes','No','Yes');
load([pathname filename])
if exist('mni_dat', 'var')
elseif exist('mri_dat', 'var')
    mni_dat = mri_dat;
else
    msg = 'Loaded file doesn''t contain struct ''mni_dat''. Please check!';
    msgbox(msg,'WARNING','warn');
    warning('off','backtrace')
    warning(msg)
    warning('on','backtrace')
    fprintf('ELAS>   Done! \n')
    return  
end
load([ELAS.ASSIGNMENTSCRIPTpath filesep 'ICBM152_HD_213.mat'])
S.cS = zeros(length(S.vS),1);

% set saving name and electrode vector
%-----------------------------------------------------------------------
while 1
    if isfield(mni_dat, 'patID')
        init_pseu = mni_dat.patID;
    else
        init_pseu = 'patient';
    end
    if isfield(mni_dat, 'group')
        init_grp = mni_dat.group;
    else
        init_grp = 'e.g. G';
    end
    inputAss = inputdlg({'Enter name of patient:'...
                         'Enter name of electrode group:'}, filename, ...
                         [1 50; 1 50],{init_pseu init_grp});
    if isempty(inputAss)
        fprintf(['ELAS>   ERROR: Patient and electrode group have' ...
                                                  ' to be named! \n'])
    else
        break
    end
end

%=======================================================================
% - get mri data (open source)
%=======================================================================
% GET THE RIGHT COORDINATES:
% The ICBM brain is stored in MRI coordinates and has its MNI origin in
% [99 138 69]. Here, this has to be considered when transforming MNI
% coordinates to MRI.
%-----------------------------------------------------------------------
if size(mni_dat.X,2) ~= 1
    X = mni_dat.X';
    Y = mni_dat.Y';
    Z = mni_dat.Z';
else
    X = mni_dat.X;
    Y = mni_dat.Y;
    Z = mni_dat.Z;
end
srcPar.OR = [99 138 69];
[elecCoords,~] = transfCS([X, Y, Z],'mni','mri', srcPar);
data.x = elecCoords(:,1);
data.y = elecCoords(:,2);
data.z = elecCoords(:,3);
if strcmp(sulci, 'Yes')
    if size(mni_dat.sX,2) ~= 1
        mni_dat.sX = mni_dat.sX';
        mni_dat.sY = mni_dat.sY';
        mni_dat.sZ = mni_dat.sZ';
    end
    [elecCoords,~] = transfCS([mni_dat.sX, mni_dat.sY, mni_dat.sZ], ...
                              'mni','mri', srcPar);
    data.sx = elecCoords(:,1);
    data.sy = elecCoords(:,2);
    data.sz = elecCoords(:,3);
else
    data.sx = [];
end

%=======================================================================
% - get mri data and transform (AG BALL, using MTV mri data)
%=======================================================================
% MNI origin of MRI data (Freiburg): [79 113 51]
% MNI origin of MPMs: [76 116 64]
% extract color values for electrodes and sulci 
%-----------------------------------------------------------------------
% rdata = mri.overlay(1).data(:,:,:,1); 
% gdata = mri.overlay(1).data(:,:,:,2); 
% rxyz = find(rdata==255);        % extract indices with red=255
% gxyz = find(gdata==255);        % extract indices with green=255
% ydata = intersect(rxyz,gxyz);   % find intersection (yellow)
% [data.x,data.y,data.z] = ind2sub(size(rdata),ydata); % MRI coordinates
% X = mri.XYZ(1,ydata);   % MNI coordinates
% Y = mri.XYZ(2,ydata);
% Z = mri.XYZ(3,ydata);
% if size(X,2) ~= 1
%     X = X';
%     Y = Y';
%     Z = Z';
% end
% srcPar.OR = [99 138 69];
% [elecCoords,~] = transfCS([X, Y, Z],'mni','mri', srcPar);
% data.x = elecCoords(:,1);
% data.y = elecCoords(:,2);
% data.z = elecCoords(:,3);
% 
% % get green markers (sulci) 
% %-----------------------------------------------------------------------
% if strcmp(sulci, 'Yes')
%     gdata(ydata) = 0;           % set yellow points to zero
%     ydata = find(gdata);        % find rest values (only green left)
%     [data.sx,data.sy,data.sz] = ind2sub(size(gdata),ydata); % MRI coordinates
%     sX = mri.XYZ(1,ydata);   % MNI coordinates
%     sY = mri.XYZ(2,ydata);
%     sZ = mri.XYZ(3,ydata);
%     if size(sX,2) ~= 1
%         sX = sX';
%         sY = sY';
%         sZ = sZ';
%     end
%     [elecCoords,~] = transfCS([sX, sY, sZ],'mni','mri', srcPar);
%     data.sx = elecCoords(:,1);
%     data.sy = elecCoords(:,2);
%     data.sz = elecCoords(:,3);
% 
% else
%     data.sx = [];
% end

%=======================================================================
% - call GUI
%=======================================================================
% define variable for plot GUI and variable E
%-----------------------------------------------------------------------
data.lc = numel(data.x);
data.elNam = inputAss{2,1};
data.anAbb = 'DE';
data.az = 220;
data.el = 10;
clear E
E.mnix = X; 
E.mniz = Z; 
E.mniy = Y;
E.patID = inputAss{1,1};
E.group = inputAss{2,1};
E.mri_origin = srcPar.OR;

% assignment 2 names
%-----------------------------------------------------------------------
outputP = elas_plotGUI(data,S);
if isempty(outputP.names)
    msg = 'No electrodes named, no file was saved!';
    msgbox(msg,'WARNING','warn');
    warning('off','backtrace')
    warning(msg)
    warning('on','backtrace')
    fprintf('ELAS>   Done! \n')
    return  
end
if isfield(outputP, 'warn')
    warning('off','backtrace')
    warning(outputP.warn)
    warning('on','backtrace')
end
E.names = cell(1,numel(E.mnix));
for a = 1:numel(E.mnix)
    if a <= numel(outputP.names)
        E.names{a} = outputP.names{a};
    else
        E.names{a} = 'not named';
    end
end

% check end point of horizontal ramus and MNI space
%-----------------------------------------------------------------------
savename = [inputAss{1,1} '_' inputAss{2,1}];
while 1
    ls = inputdlg({['Enter MNI y-coordinate of the end point of ' ...
                  'horizontal ramus (LS):']}, savename, 1, {''});
    if isempty(ls)
        fprintf('ELAS>   ERROR: Y-coordinate has to be defined! \n')
    elseif isempty(ls{1,1})
        fprintf('ELAS>   ERROR: Y-coordinate has to be defined! \n')
    else
        if strcmp(ls{1,1}, 'na')
            E.lsend = 'n.a.'; break
        else
            ls = str2double(ls{1,1});
            if ~isnan(ls)
                E.lsend = ls; break 
            else
                fprintf('ELAS>   ERROR: Input must be a number! \n')
            end
        end
    end                
end

% check if outputpath exists and save variable 'E' as mat
%-----------------------------------------------------------------------
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    savenameAll = [ELAS.OUTPUTpath filesep savename];
else
    savenameAll = [pwd filesep savename];
end
fprintf('ELAS>   Save variable E as: %s_E.mat \n', [savenameAll,'_E.mat'])
uisave('E', [savenameAll,'_E.mat'])
%=======================================================================

fprintf('ELAS>   Done! \n')
    