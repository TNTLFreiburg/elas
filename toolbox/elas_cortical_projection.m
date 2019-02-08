function [A,M,Ca,Aall,Call]=elas_cortical_projection(Emni,region, ...
                                                     assignment_method,mri)

% FUNCTION (under ELAS) to perform an anatomical assignment based on the 
%          a projection onto the cortical surface
%          
%
% DESCRIPTION In this step, the electrodes are assigned to a specific    
%          anatomic region.       
%
% OUTPUT
%          A:  grey value of assigend voxel (most frequent)
%
%          M:  macrolabel of assigned voxel  (most frequent)
%
%          Ca: coordinate of assigend voxel (most frequent)
%
%          Aall: grey values of assigned voxels for all normals
%
%          Call: coordinates of assigned voxels for all normals
%
% TBall, modified by JBehncke (Feb'19)


%=======================================================================
global FV macrolabel FVplot  
%=======================================================================

%=======================================================================
%-get vertices and normals of hull points in dist to closest hull point
%=======================================================================
%-get linear index and coordinates of Emni in MTV volume
%-----------------------------------------------------------------------
Ef = find(mri.XYZ(1, :) == Emni(1) & mri.XYZ(2 ,:) == Emni(2) & ...
          mri.XYZ(3, :) == Emni(3));
[Ex, Ey, Ez] = ind2sub(size(mri.image(1).data),Ef);

%-find closest point of hull from shrinkwrap to MNI coordinate 
%-----------------------------------------------------------------------
Ed = metasurf_dist([Ex, Ey, Ez], FV.vertices);
m = find(Ed==min(Ed)); m = m(1); % get closest point
V = FV.vertices(m,:); % get closest point on hull

%-all points on hull within given distance to projected voxel, sorted in 
% ascending order according to distance from electrode center
%-----------------------------------------------------------------------
Ed = metasurf_dist(V, FV.vertices); % distance of vert to min hull point
m = find(Ed<assignment_method.mindist); % vertices in def distance
Edm = Ed(m);
[~, ix] = sort(Edm);
Vall = FV.vertices(m(ix), :); 

% example: to get VertexNormals for FV:
% figure; h = patch(FV); FV.VertexNormals = get(h,'VertexNormals')
%-----------------------------------------------------------------------

%-normals at closest points, normalized to length 1
%-----------------------------------------------------------------------
N = FV.VertexNormals(m, :);
N = N./repmat(sqrt(sum((N.^2),2)), [1 3]);

%=======================================================================
%-for all extracted vertices get grey values in certain volume
%=======================================================================
for r = 1:size(N, 1) 
    %-normal vector at V(r,:)
    %-------------------------------------------------------------------
    s = [linspace(-10,10,41); linspace(-10,10,41); linspace(-10,10,41)]'; 
    S = repmat(N(r, :), [size(s,1) 1]).*s;
    S = S + repmat(Vall(r, :), [size(s,1) 1]);

    if assignment_method.plot
        plot3(S(:,1), S(:,2), S(:,3), 'r-')
        h = plot3(Vall(r,1),Vall(r,2),Vall(r,3),'bo');
        set(h,'markersize',4,'markerfacecolor','b')
    end
    
    %-assign local S to base S
    %-------------------------------------------------------------------
    assignin('base','S',S)

    %-check which end of normal vector is closer to brain center and keep 
    % inner half of normal vector
    %-------------------------------------------------------------------
    bc = [76 96 92]; % volume center
    d1 = metasurf_dist(S(1,:), bc);   % point closest to volume center
    d2 = metasurf_dist(S(end,:), bc); % most distant point from center
    if d1<d2
        S = S(1:21, :); % searching for matches up to 10 mm underneath brain surface
        S = flip(S, 1); % first point of S is closest to the hull
    else
        S = S(21:end, :);
    end

    %-get data values along S
    %-------------------------------------------------------------------
    S=round(S);
    try
        Si = sub2ind(size(mri.image(1).data), S(:,1), S(:,2), S(:,3));
        Sdat = mri.image(1).data(Si); %assigned grey values
        f = find(ismember(Sdat,region)); %check interference with grey values of respective lobe (region)
        n = find(Sdat>0); %first voxel on the colin brain surface
        if isempty(f)
            Aall(r) = 0;
            Call(r,:) = mri.XYZ(:,Si(n(1))); % %first voxel on the colin brain surface for n.a.       
        else
            Aall(r) = Sdat(f(1)); % first assigned voxel along S 
            Call(r,:) = mri.XYZ(:,Si(f(1))); % coordinates of first assigned voxel 
        end
    catch
        Aall(r) = -1;

    end
    try
        Si = sub2ind(size(macrolabel.image(1).data),S(:,1),S(:,2),S(:,3));
        Sdat = macrolabel.image(1).data(Si);
        f = find(Sdat>0); %voxel of colin brain that overlaps with vector
        if isempty(f)
            Mall(r) = 0;
        else
            Mall(r) = Sdat(f(1)); %first voxel of colin brain surface that overlaps with vector
        end
    catch
        Mall(r) = -1;
    end
end

%=======================================================================
%-extract most frequent grey values and their coordinates
%=======================================================================
if ~isempty(find(Aall>0,1))
    A = mode(Aall(Aall>0));% most frequently occuring grey value
    Ci = Aall==A; %indices of most frequently occuring grey value
    C = Call(Ci,:); % coordinates at these indices
elseif ~isempty(find(Aall==0,1))
    A = 0; 
    Ci = Aall==0;  
    C = Call(Ci,:); % first voxels of unassigned vectors
else
    A=-1; 
end

%=======================================================================
%-extract macrolabels
%=======================================================================
if ~isempty(find(Mall>0,1))
    M = mode(Mall(Mall>0)); 
elseif ~isempty(find(Mall==0,1))
    M = 0; 
else
    M = -1; 
end

%=======================================================================
%-extract assigend coordinate
%=======================================================================
Cm = mean(C,1); %mean value of coordinates belonging to the assigned area
Cdist = metasurf_dist(Cm,C); %distance of vectors to the mean coordinate
Cs = min(Cdist);  % coordinates which are assigned to assigned area CLOSEST 
                  % to mean coordinate of area 
Cind = Cdist==Cs; 
Ca = C(Cind,:);
%if respective coordinate is part of several vectors...
if numel(Ca)>3 && numel(unique(Ca)==3) 
    Ca = Ca(1,:);
end

