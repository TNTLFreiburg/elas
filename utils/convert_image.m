function convert_image

% FUNCTION to convert files: nii --> hdr/img or hdr/img --> nii
%
%
% SYNTAX
%         convert_image
%
% REMARKS
%         This script uses SPM.
%
%
% J. Behncke, June'18

fprintf('\nELAS>   Still computing... \r')

%=======================================================================
global ELAS
%=======================================================================

%=======================================================================
% - select files
%=======================================================================
if exist('ELAS','var') && isfield(ELAS,'OUTPUTpath')
    [filename, pathname] = uigetfile([ELAS.OUTPUTpath filesep '*.mat'],...
                    'Select file containing header variable H');
else
    [filename, pathname] = uigetfile('*.mat',...
                    'Select file containing header variable H');
end
f = fullfile(pathname, filename);

%=======================================================================
% - convert image/nii files
%=======================================================================
for i=1:size(f,1)
	input = deblank(f(i,:));
	[~,fname,ext] = fileparts(input);
    if strcmp(ext, '.nii')
        fprintf('ELAS>   Convert to image format... \r')
        output = strcat(fname,'.img');
    elseif strcmp(ext, '.img')
        fprintf('ELAS>   Convert to nii format... \r')
        output = strcat(fname,'.nii');
    else
        warning('Image file format ''%s'' not supported!\n', ext)
        return
    end
    V=spm_vol(input);
    ima=spm_read_vols(V);
    V.fname=output;
    spm_write_vol(V,ima);
end
%=======================================================================

fprintf('ELAS>   Done! \n')