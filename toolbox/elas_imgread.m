function [mriRaw, origin] = elas_imgread(filename,pathname)  

% FUNCTION (under ELAS) to write data content of x,y,z coordinates from a   
%          img file into a 3-D matrix; uses spm
%
% SYNTAX
%         [mriRaw, XYZ] = imgread(filename,pathname)  
%
% DESCRIPTION
%         SPM (statistical parametric mapping), software e.g. available 
%         under:    <http://www.fil.ion.ucl.ac.uk/spm/software/spm12/>
%
%         'filename':   string containing name of the file
%
%         'pathname':   string containing path for file directory
%
% OUTPUT
%         'mriRaw':     3D double containing the data values
%
%         'origin':   	(1x3 double), MNI origin according to MRI coords
%
% JBehncke, Mrz'15

V = spm_vol([pathname filename]);
origin = abs([V.mat(1,4) V.mat(2,4) V.mat(3,4)]);
[Y, ~] = spm_read_vols(V);
mriRaw = single(Y);

end