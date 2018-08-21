function fv = smooth_surface(varargin)

% FUNCTION to smooth isosurfaces
%
%
% SYNTAX
%         fv = smooth_surface(A, alpha)
%         fv = smooth_surface(vertices, faces, alpha)
%
% DESCRIPTION
%         'A':          struct, containing fields 'faces' & 'vertices'
%         'vertices':   (nx3 double)
%         'faces':      (mx3 double)
%         'alpha':      (double), weight of smoothing
%
% OUTPUT
%         'fv':         struct, containing fields 'faces' & 'vertices'
%
%
% JBehncke, Aug'18

%-check input
%----------------------------------------------------------------------
if nargin<3
    vertices = varargin{1}.vertices;
    faces = varargin{1}.faces;
    alpha = varargin{2};
else
    vertices = varargin{1};
    faces = varargin{2};
    alpha = varargin{3};
end

%-smooth vertices
%----------------------------------------------------------------------
storevert = vertices;
for a = 1:size(storevert,1)
    vertenv = unique(faces(sum(faces == a,2) ~= 0,:));
    storevert(a,:) = (vertices(a,:) + ...
                            alpha*mean(vertices(vertenv,:)))/(1+alpha);
end

%-write output
%----------------------------------------------------------------------
fv.vertices = storevert;
fv.faces = faces;