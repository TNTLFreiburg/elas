function D = metasurf_dist(p1, pn)

% FUNCTION (under ELAS) to get distance of point to point cloud
%
% INPUT
%          p1: (3x1 double), point
%
%          pn: (3xn double), pointcloud
%
% OUTPUT
%          D: (3xn double), distance 
%
%
% TBall, modified by JBehncke (May'18)

if size(pn ,1)~=3; pn = pn'; end
if size(pn, 1)~=3; error('no valid point list'); end

if size(p1, 1)~=3; p1 = p1'; end
if size(p1, 1)~=3; error('no valid singular point'); end

p1n = repmat(p1, 1, size(pn,2));
pd = pn - p1n;
pd = pd.^2;
ps = sum(pd, 1);
D = ps.^(0.5);