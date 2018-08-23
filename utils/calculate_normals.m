function fv = calculate_normals(varargin)

% FUNCTION to caluclate vertex normals based on faces and vertices
%
%
% SYNTAX
%         fv = calculate_normals(A)
%         fv = calculate_normals(vertices, faces)
%
% DESCRIPTION
%         'A':          struct, containing fields 'faces' & 'vertices'
%         'vertices':   (nx3 double)
%         'faces':      (mx3 double)
%
% OUTPUT
%         'fv':         struct, containing fields 'faces', 'vertices'
%                       and normals
%
%
% JBehncke, Aug'18

%-check input
%----------------------------------------------------------------------
if nargin<2
    vertices = varargin{1}.vertices;
    faces = varargin{1}.faces;
else
    vertices = varargin{1};
    faces = varargin{2};
end

%-calculate vertex normals
%----------------------------------------------------------------------
TR = triangulation(faces, vertices);
P = incenter(TR);
vertexnormals = faceNormal(TR);  
comass = mean(TR.Points,1);
for b = 1:size(P,1)
    if ((comass-P(b,:))*vertexnormals(b,:)') > 0
        vertexnormals(b,:) = -vertexnormals(b,:);
    end
end

%-write output
%----------------------------------------------------------------------
fv.vertices = vertices;
fv.faces = faces;
fv.vertexnormals = vertexnormals;