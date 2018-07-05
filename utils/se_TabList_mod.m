function elAss = se_TabList_mod(X, Y, Z)

% FUNCTION (under ELAS) that assigns MNI coordinate to the anatomical areas
%          
% DESCRIPTION This function allows an assignment of the electrodes' MNI
%          coordinates to anatomical areas, based on anatomy and 
%          probabilistic assignment. 

%
% NECESSITIES 
%          MNI coordinates X, Y and Z
%
%          Anatomy toolbox (currently version 1.8)
%
% OUTPUT 
%          'elAss', being a struct of electrode assignments
% 
% REMARK 
%          this code is modified from: se_TabList.m of Anatomy Toolbox
%
% JBehncke, June18


%=======================================================================
global MAP ELAS
%=======================================================================

%=======================================================================
% - probabilitic MAP (loading)
%=======================================================================
MapName = [ELAS.SPMANApath filesep 'Anatomy_v22c_MPM.matt']; 
se_getMap('anat',MapName);

%=======================================================================
% - structure initialization (defaults = 'n.a.', not-available)
%=======================================================================
elAss = struct;
% default: not-available (n.a.)
elAss.brainAtlas = 'n.a.';          % anatomical assignment    
elAss.probabAss_area{1} = 'n.a.';   % probabilistic assignment
elAss.probabAss_elec{1} = 'n.a.';   % probability of MNI voxel (electrode) to belong to the assigned area
elAss.probabAss_bnds{1} = 'n.a.';   % lowest probability of neighboring MNI voxels to belong to the assigned area

%=======================================================================
% - MNIs -> Anatomical MNIs, assumes MNIs !!!
%=======================================================================
XYZmm = [X Y-4 Z+5]';           % Anatomical MNIs
xyz = inv(MAP(1).MaxMap.mat) * [XYZmm; ones(1,size(XYZmm,2))] ;

%=======================================================================
% - assigment algorithm
%=======================================================================
for PM = 1:size(MAP,2)
    ProbMax(1:size(xyz,2),PM+1) = spm_sample_vol(MAP(PM).PMap,xyz(1,:),xyz(2,:),xyz(3,:),0)';
end
ProbMax(:,1) = spm_sample_vol(MAP(1).MaxMap,xyz(1,:),xyz(2,:),xyz(3,:),0)'; ProbMax(:,1) = ProbMax(:,1) .* (ProbMax(:,1) > 99);

for indxx  = 1:size(XYZmm,2)

    % "anatomical" assignment
    ML = round(spm_sample_vol(MAP(1).Macro,xyz(1,indxx),xyz(2,indxx),xyz(3,indxx),0)');
    if ML > 0;
        MLl = MAP(1).MLabels.Labels{ML};
        elAss.brainAtlas = MLl;
    end

    % "probabilistic" assignment
    if any(ProbMax(indxx,:))
        Probs = find(ProbMax(indxx,2:end)>0); [value sortP]= sort(ProbMax(indxx,Probs+1));
        c = 1;
        for getPr = size(Probs,2):-1:1
            [Ploc, Pmin, Pmax] = MinMax(MAP(Probs(sortP(getPr))).PMap,xyz(:,indxx));
            elAss.probabAss_elec{c} = Ploc;
            elAss.probabAss_bnds{c} = [Pmin; Pmax];
            elAss.probabAss_area{c} = MAP(Probs(sortP(getPr))).name;
            
            c = c+1;
        end
    end
end
%=======================================================================

function [Ploc, Pmin, Pmax] = MinMax(map,tmp)
sample = spm_sample_vol(map,...
    [tmp(1)-1 tmp(1) tmp(1)+1 tmp(1)-1 tmp(1) tmp(1)+1 tmp(1)-1 tmp(1) tmp(1)+1 ...
    tmp(1)-1 tmp(1) tmp(1)+1 tmp(1)-1 tmp(1) tmp(1)+1 tmp(1)-1 tmp(1) tmp(1)+1 ...
    tmp(1)-1 tmp(1) tmp(1)+1 tmp(1)-1 tmp(1) tmp(1)+1 tmp(1)-1 tmp(1) tmp(1)+1], ....
    [tmp(2)-1 tmp(2)-1 tmp(2)-1 tmp(2) tmp(2) tmp(2) tmp(2)+1 tmp(2)+1 tmp(2)+1 ...
    tmp(2)-1 tmp(2)-1 tmp(2)-1 tmp(2) tmp(2) tmp(2) tmp(2)+1 tmp(2)+1 tmp(2)+1 ...
    tmp(2)-1 tmp(2)-1 tmp(2)-1 tmp(2) tmp(2) tmp(2) tmp(2)+1 tmp(2)+1 tmp(2)+1], ...
    [tmp(3)-1 tmp(3)-1 tmp(3)-1 tmp(3)-1 tmp(3)-1 tmp(3)-1 tmp(3)-1 tmp(3)-1 tmp(3)-1 ...
    tmp(3) tmp(3) tmp(3) tmp(3) tmp(3) tmp(3) tmp(3) tmp(3) tmp(3) ...
    tmp(3)+1 tmp(3)+1 tmp(3)+1 tmp(3)+1 tmp(3)+1 tmp(3)+1 tmp(3)+1 tmp(3)+1 tmp(3)+1],...
    0);
Pmin = min(sample)/2.5;
Pmax = max(sample)/2.5;
Ploc =  sample(14)/2.5;