function vertface2obj(varargin)

% FUNCTION to save a set of vertice coordinates and faces (and normals) as 
%          a wavefront *.obj file
%
% DESCRIPTION
%          vertface2obj(v,f,fname)
%          vertface2obj(v,f,vn,fname)
%
% INPUT
%          'v':     (nx3 double), matrix of vertex coordinates
%          'f':     (mx3 double), matrix of vertex indices
%          'vn':    (nx3 double), matrix of vertex normals
%          'fname': string, is the filename to save the obj file.
%
% Aug'18

%-check input
v = varargin{1};
f = varargin{2};
if nargin < 4
    vn = [];
    fname = varargin{3};
else
    vn = varargin{3};
    fname = varargin{4};
end
    
%-open file
fid = fopen(fname,'w');

%-write vertices
for i=1:size(v,1)
fprintf(fid,'v %f %f %f\n',v(i,1),v(i,2),v(i,3));
end

%-write vertex normals
if ~isempty(vn)
    fprintf(fid,'g normals\n');
    for i=1:size(vn,1)
    fprintf(fid,'vn %d %d %d\n',vn(i,1),vn(i,2),vn(i,3));
    end
end
    
%-write faces
fprintf(fid,'g faces\n');
for i=1:size(f,1)
fprintf(fid,'f %d %d %d\n',f(i,1),f(i,2),f(i,3));
end
fprintf(fid,'g\n');

%-close file
fclose(fid);