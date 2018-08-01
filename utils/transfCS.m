function [out,vals] = transfCS(varargin)   

% FUNCTION to transform coordinates from/to MRI, MNI or SCS system
%
% SYNTAX
%          [out,vals] = transfCS(in,src,dest,srcPar)
%
% INPUT
%          'in', (n x 3 double) of coordinates to tranform, n for number of
%          points and 3 dimensions for [x y z]
%
%          'src', source system {'mri','voxel','mni','scs'}
%
%          'dest', destination system {'mri','voxel','mni','scs'}
%
%          Depending on source/destination coordinate system, certain 
%          parameters are needed for the transformation. If source or 
%          destination system is one of the following, set srcPar to (where
%          the points have to be given in mri coordinates):
%               VOXEL:   srcPar = struct(...
%                               VS,[])         voxel size; default: 1mm
%               MNI:     srcPar = struct(...
%                               OR,[])         origin of MNI system in MRI,
%                                              default: [99 138 69]
%                                              origin depends on MRI system
%                                              ICBM152:     [99 138 69]
%                                              MTV:         [79 113 51]
%               SCS:     srcPar = struct(...
%                               NAS,[],...     nasion
%                               RPA,[],...     right pre-auricular point
%                               LPA,[])        left pre-auricular point
%          e.g. for mni <--> scs create the struct
%                   srcPar = struct(...
%                               OR,[],...      origin of MNI system
%                               NAS,[],...     nasion
%                               RPA,[],...     right pre-auricular point
%                               LPA,[])        left pre-auricular point
%
% OUTPUT
%          'out', (n x 3 double) of transformed coordinates
%
%          'vals', struct of output transformation variables
%
% DESCRIPTION
%          VOXEL system: Coordinates system used to index voxels in the
%          space of the MRI volume. The first voxel is located at the 
%          bottom-left-posterior of the MRI volume, (1,1,1).
%
%          MRI system: Coordinates system used to index voxels in the space 
%          of the MRI volume (in [mm]). MRI = VOXEL * VOXELSIZE
%
%          MNI system: Coordinate system based on a specific brain
%          template. To use an individual brain template, a normalization
%          step of the corresponding brain image is required. Subsequently 
%          the input of the origin coordinates is necessary.
%          see: <http://www.bic.mni.mcgill.ca/~louis/stx_history.html>
%
%          SCS system: Coordinate system based on the nasion, the right and
%          the left pre-auricular point. 
%               Origin: midway on the line joining LPA and RPA
%               Axis X: from the origin towards the nasion (exactly
%                       through)
%               Axis Y: from the origin towards LPA in the plane defined by
%                       (NAS,RPA,LPA) and orthogonal to X
%               Axis Z: from the origin towards top of the head, orthogonal
%                       to X and Y
%          see: <http://neuroimage.usc.edu/brainstorm/CoordinateSystems#MRI_coordinates>
%
%         
% JBehncke, Aug'18


%==========================================================================
%-Check input
%==========================================================================
if size(varargin{1},2) == 3
    in = varargin{1};
    trnsp = false;
elseif size(varargin{1},1) == 3
    in = varargin{1}';
    trnsp = true;
else
    fprintf(['        ERROR: Dimensions of input data ''in'' ' ...
                                 'have to be either (n x 3) or (3 x n)!']); 
    return
end
src = lower(varargin{2});
dest = lower(varargin{3});
if strcmp(src, dest)
    return;
end
% fprintf('        Transform %s to %s coordinates...\n',src,dest); 


%==========================================================================
%-TRANSFORMATION: source --> MRI
%========================================================================== 
if strcmp(src,'mri')                                     %-Input mri to mri
%-------------------------------------------------------------------------- 

    mri = in;

%--------------------------------------------------------------------------
elseif strcmp(src,'voxel')                             %-Input voxel to mri
%--------------------------------------------------------------------------

    %-Define voxelsize
    if nargin < 4 || (nargin > 3 && ~isfield(varargin{4},'VS'))
        fprintf('        Voxelsize set to 1mm!\n');
        vs = 1;
    else
        vs = varargin{4}.VS;
    end
    
    %-Apply transformation & write output
    mri = in * vs;
    vals.VS = vs;
    
%--------------------------------------------------------------------------
elseif strcmp(src,'mni')                                 %-Input mni to mri
%--------------------------------------------------------------------------
        
    %-MNI origin in voxel (Anterior Commisure???)
    if nargin < 4 || (nargin > 3 && ~isfield(varargin{4},'OR'))
        fprintf('        Origin set to [99 138 69]!\n');
        origin = [99 138 69]; % coordinates according to spm transformation
    else
        origin = varargin{4}.OR;
    end
    
    %-Apply transformation & write output
    T = cat(1,eye(3),[origin(1) origin(2) origin(3)]);
    mri = cat(2,in,ones(size(in,1),1)) * T;
    vals.OR = origin;
    vals.T1 = T;
    
%--------------------------------------------------------------------------
elseif strcmp(src,'scs')                                 %-Input scs to mri
%--------------------------------------------------------------------------
    
    %-Check fiducials
    if nargin < 4 || (nargin > 3 && ~isfield(varargin{4},'NAS'))
        fprintf(['        ERROR: Assert that varargin{4} is '...
                 'struct containing fields NAS, RPA and LPA before ' ...
                 'runnning transformation from %s to %s!\n'],src,dest);
        return
    else
        vals = varargin{4};
    end
    
    %-Calculate transformation matrices
    [R,T] = calcTransMatSCS(vals.NAS,vals.LPA,vals.RPA);
    T(4,:) = T(4,:) * (-1);
    P = [0 1 0;-1 0 0;0 0 1];

    %-Permute dimensions, apply transformation and write output   
    mri = round(cat(2,(in * P)/R,ones(size(in,1),1)) * T);   
    vals.P = P;
    vals.T1 = T;
    vals.R1 = inv(R);
    
%--------------------------------------------------------------------------
else                                                       %-Unknown input
%--------------------------------------------------------------------------

    fprintf('        Unknown source coordinate system: %s',src); 
    
end
%--------------------------------------------------------------------------


%==========================================================================
%-TRANSFORMATION: MRI --> destination
%==========================================================================
if strcmp(dest,'mri')                                   %-Mri to output mri
%--------------------------------------------------------------------------
    
    out = mri;

%--------------------------------------------------------------------------
elseif strcmp(dest,'voxel')                           %-Mri to output voxel
%--------------------------------------------------------------------------
    
    %-Define voxelsize
    if nargin < 4 || (nargin > 3 && ~isfield(varargin{4},'VS'))
        fprintf('        Voxelsize set to 1mm!\n');
        vs = 1;
    else
        vs = varargin{4}.VS;
    end
    
    %-Apply transformation & write output
    out = mri / vs;
    vals.VS = vs;

%--------------------------------------------------------------------------
elseif strcmp(dest,'mni')                               %-Mri to output mni
%--------------------------------------------------------------------------
    
    %-MNI origin in voxel (Anterior Commisure???)
    if nargin < 4 || (nargin > 3 && ~isfield(varargin{4},'OR'))
        fprintf('        Origin set to [99 138 69]!\n');
        origin = [99 138 69]; % coordinates according to spm transformation
    else
        origin = varargin{4}.OR;
    end
    
    %-Apply transformation & write output
    T = cat(1,eye(3),[-origin(1) -origin(2) -origin(3)]); 
    out = cat(2,mri,ones(size(mri,1),1)) * T;
    vals.OR = origin;
    vals.T2 = T;

%--------------------------------------------------------------------------
elseif strcmp(dest,'scs')                               %-Mri to output scs
%--------------------------------------------------------------------------
    
    %-Check fiducials
    if nargin < 4 || (nargin > 3 && ~isfield(varargin{4},'NAS'))
        fprintf(['        ERROR: Assert that varargin{4} is '...
                 'struct containing fields NAS, RPA and LPA before ' ...
                 'runnning transformation from %s to %s!\n'],src,dest);
        return
    else
        vals = varargin{4};
    end
    
    %-Calculate transformation matrices
    [R,T] = calcTransMatSCS(vals.NAS,vals.LPA,vals.RPA);
    P = [0 -1 0;1 0 0;0 0 1];

    %-Apply transformation, permute dimensions and write output
    out = round(cat(2,mri,ones(size(mri,1),1)) * T * R) * P;    
    vals.P = P;
    vals.T2 = T;
    vals.R2 = R;

%--------------------------------------------------------------------------
else                                                       %-Unknown output
%--------------------------------------------------------------------------

    fprintf('        Unknown destination coordinate system: %s',dest);  
    
end
%--------------------------------------------------------------------------


%==========================================================================
%-Check output
%==========================================================================
if trnsp
    out = out';
end
% fprintf('                 Done!\n');