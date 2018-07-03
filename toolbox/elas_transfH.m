function [outH] = elas_transfH(inH)

% FUNCTION (under ELAS) to transform header from ELAS format to analysis 
%          format; subfunction of 'elas_createH.m'
%
% SYNTAX
%          [outH] = transfH(inH)
%
% INPUT
%          'inH': header in form of a struct (ELAS format)
%
% OUTPUT
%          'outH': output header in form of a struct
%
%         
% JBehncke, Apr'16


%========================================================================
if iscell(inH.channels)                             %-header in ELAS format
%========================================================================
    
outH = rmfield(inH,'channels');
for a = 1:size(inH.channels,2)

    outH.channels(a).name = inH.channels{a}.name;
    outH.channels(a).numberOnAmplifier = inH.channels{a}.numberOnAmplifier;
    
    if isfield(inH.channels{a},'signalType')
        outH.channels(a).signalType = inH.channels{a}.signalType;
    else
        if length(outH.channels(a).name) < 3
            outH.channels(a).signalType = 'n.a.';
        else
            switch outH.channels(a).name(1:3)
                case 'EKG'
                    outH.channels(a).signalType = 'EKG';
                case 'ECG'
                    outH.channels(a).signalType = 'EKG';
                case 'EOG'
                    outH.channels(a).signalType = 'EOG';
                case 'EMG'
                    outH.channels(a).signalType = 'EMG';
                case 'Tri'
                    outH.channels(a).signalType = 'Trigger';
                otherwise
                    outH.channels(a).signalType = 'EEG';
            end
        end
    end
    
    if isfield(inH.channels{a},'MNI_x')
        outH.channels(a).MNI_x = inH.channels{a}.MNI_x;
        outH.channels(a).MNI_y = inH.channels{a}.MNI_y;
        outH.channels(a).MNI_z = inH.channels{a}.MNI_z;
    else
        outH.channels(a).MNI_x = [];
        outH.channels(a).MNI_y = [];
        outH.channels(a).MNI_z = [];
    end
    
    if isfield(inH.channels{a},'ass_brainAtlas')
        outH.channels(a).ass_brainAtlas = inH.channels{a}.ass_brainAtlas;
    else
        outH.channels(a).ass_brainAtlas = 'n.a.';
    end
    
    if isfield(inH.channels{a},'ass_cytoarchMap')
        outH.channels(a).ass_cytoarchMap = inH.channels{a}.ass_cytoarchMap;
    else
        outH.channels(a).ass_cytoarchMap = [];
    end
    
    if isfield(inH.channels{a},'ass_cytoarchMap_stats')
        outH.channels(a).ass_cytoarchMap_stats = ...
                                     inH.channels{a}.ass_cytoarchMap_stats;
    else
        outH.channels(a).ass_cytoarchMap_stats = [];
    end
    
    if isfield(inH.channels{a},'ass_matterType')
        outH.channels(a).ass_matterType = inH.channels{a}.ass_matterType;
    else
        outH.channels(a).ass_matterType = [];
    end
    
    if isfield(inH.channels{a},'p_grayMatter')
        outH.channels(a).p_grayMatter = inH.channels{a}.p_grayMatter;
    else
        outH.channels(a).p_grayMatter = [];
    end
    
    if isfield(inH.channels{a},'p_whiteMatter')
        outH.channels(a).p_whiteMatter = inH.channels{a}.p_whiteMatter;
    else
        outH.channels(a).p_whiteMatter = [];
    end
    
    if isfield(inH.channels{a},'p_cerebroSpinalFluid')
        outH.channels(a).p_cerebroSpinalFluid = ...
                                      inH.channels{a}.p_cerebroSpinalFluid;
    else
        outH.channels(a).p_cerebroSpinalFluid = [];
    end  
    
end


%========================================================================
elseif isstruct(inH.channels)                %-header already in new format
%========================================================================

outH = inH;
for a = 1:size(outH.channels,2)
    
    if strcmpi(outH.channels(a).signalType,'n.a.')
        if length(outH.channels(a).name) > 2 
            switch outH.channels(a).name(1:3)
                case 'EKG'
                    outH.channels(a).signalType = 'EKG';
                case 'ECG'
                    outH.channels(a).signalType = 'EKG';
                case 'EOG'
                    outH.channels(a).signalType = 'EOG';
                case 'EMG'
                    outH.channels(a).signalType = 'EMG';
                case 'Tri'
                    outH.channels(a).signalType = 'Trigger';
                otherwise
                    outH.channels(a).signalType = 'EEG';
            end
        end
    end
    
end


%========================================================================
else                                           %-header in unknown format
%========================================================================
    
fprintf('ELAS>   Unknown header format, transformation aborted...\n')
return
 

%========================================================================    
end
%========================================================================