function fv = pointcloud2isosurface(pc)

% FUNCTION to extract isosurface from pointcloud
%
%
% SYNTAX
%         fv = pointcloud2isosurface(pc)
%
% DESCRIPTION
%         'pc':          (nx3 double), of point cloud coordinates
%
% OUTPUT
%         'fv':         struct, containing fields 'faces' & 'vertices'
%
%
% JBehncke, Aug'18

%-get vertices of surface by looking at nearest neighbours
%----------------------------------------------------------------------
vertices = [];
for b = 1:size(pc,1)
    defdist = sqrt((pc(b,1)-pc(:,1)).^2 + ...
                   (pc(b,2)-pc(:,2)).^2 + ...
                   (pc(b,3)-pc(:,3)).^2);
    if numel(find(defdist < 2)) < 27
        vertices = [vertices; pc(b,:)];
    end
end
distMat = NaN(size(vertices,1), size(vertices,1));
for b = 1:size(vertices,1)
    distMat(:,b) = sqrt((vertices(b,1)-vertices(:,1)).^2 + ...
                        (vertices(b,2)-vertices(:,2)).^2 + ...
                        (vertices(b,3)-vertices(:,3)).^2);
end

%-create faces by triangulation
%----------------------------------------------------------------------
faces = [];
reverseStr = '';
for b = 1:size(vertices,1)
    msg = sprintf('        Converting vertex %d/%d\n', ...
                   b, size(vertices,1));
    fprintf([reverseStr, msg])
    reverseStr = repmat(sprintf('\b'), 1, length(msg));

    getnn_b = find(distMat(:,b) < 2);
    getnn_b(getnn_b==b) = [];
    for c = getnn_b'
        getnn_c = find(distMat(getnn_b,c) < 1.5);
        getnn_c(getnn_b(getnn_c)==c) = [];
        if isempty(getnn_c)
            getnn_c = find(distMat(getnn_b,c) < 2);
            getnn_c(getnn_b(getnn_c)==c) = [];
        end
        if ~isempty(getnn_c)
            newfaces = NaN(numel(getnn_c), 3);
            for d = 1:numel(getnn_c)
                newfaces(d,:) = [b, c, getnn_b(getnn_c(d))];                            
            end
            newfaces = unique(sort(newfaces,2),'rows');
            faces = [faces; newfaces];
        end
    end  
    faces = unique(sort(faces,2),'rows');
end
faces = unique(sort(faces,2),'rows');

%-write output
%----------------------------------------------------------------------
fv.vertices = vertices;
fv.faces = faces;