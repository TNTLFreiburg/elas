function [H] = SDYreadECoG(filename)

% FUNCTION to create header H from SDY channel file
%
%
% SYNTAX
%         [H] = SDYreadECoG(filename)
%
% DESCRIPTION
%         'filename', being a string containing path to file
%
% OUTPUT
%         'H', being a [1 x 1 struct], containing information about the
%         channels 
%
% JBehncke, Apr'15


% convert SDY file to MATLAB structure
rawH = parseXML(filename);

% get position of 'channels'
for i = 1:size(rawH.Children,2)
    if strcmp(rawH.Children(1,i).Name,'Channels')
        CHnum = i;
    end    
end
if ~exist('CHnum','var')
    dlg = ['ERROR: "Channels" could not be found, reading header file '...
           '%s. \r\nCheck variable rawH.Children while using function '... 
           'SDYreadECoG.m! \r\n'];
    fprintf(dlg,filename);
    H = [];
    return
end

% get position of 'names'
for i = 1:size(rawH.Children(1,CHnum).Children(1,i).Attributes,2)
    if strcmp(rawH.Children(1,CHnum).Children(1,1).Attributes(1,i).Name,'name')
        NMnum = i;
    end    
end 
if ~exist('NMnum','var')
    dlg = ['ERROR: "name" could not be found, reading header file '...
           '%s. \r\nCheck variable rawH.Children(1,%d).Children(1,1).Attributes'... 
           ' while using function SDYreadECoG.m! \r\n'];
    fprintf(dlg,filename,CHnum);
    H = [];
    return
end

% get names and positions of channels from rawH
for i = 1:size(rawH.Children(1,CHnum).Children,2)
    if strcmp(rawH.Children(1,CHnum).Children(1,i).Name,'Channel')
        
        if strcmp(rawH.Children(1,CHnum).Children(1,i).Attributes(1,NMnum).Name,'name') 
            channels{1,i}.name = rawH.Children(1,CHnum).Children(1,i).Attributes(1,NMnum).Value;
            channels{1,i}.numberOnAmplifier = i;
        else
            dlg = ['ERROR: Name of Electrode #%d can not be assigned '...
                   'correctly. \r\nCheck variable '... 
                   'rawH.Children(1,%d).Children(1,%d).Attributes(1,%d).Name'...
                   ' while using function SDYreadECoG.m! \r\n'];
            fprintf(dlg,i,CHnum,i,NMnum);
            return
        end

    end    
end

% def H.channels
H.channels = channels;

% get position of 'study'
for i = 1:size(rawH.Children,2)
    if strcmp(rawH.Children(1,i).Name,'Study')
        STnum = i;
    end    
end
if ~exist('STnum','var')
    dlg = ['ERROR: "Study" could not be found, reading header file '...
           '%s. \r\nCheck variable rawH.Children'... 
           ' while using function SDYreadECoG.m! \r\n'];
    fprintf(dlg,filename);
    return
end

% get sampling rate from rawH
for i = 1:size(rawH.Children(1,STnum).Attributes,2)
    if strcmp(rawH.Children(1,STnum).Attributes(1,i).Name,'eeg_sample_rate')        
    	generalSettings.srate = str2double(rawH.Children(1,STnum).Attributes(1,i).Value);
    end    
end

% def H.generalSettings
H.generalSettings = generalSettings;

% search for trigger channel
for i = 1:size(H.channels,2)
    if strcmpi(H.channels{1,i}.name,'Trigger')
        H.triggerCH = i;
        return
    end    
end

disp('ATTENTION: Trigger channel could not be found in imported data!')
H.triggerCH = 0;
  
end
