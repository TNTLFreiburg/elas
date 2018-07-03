function [H] = XMLreadECoG(filename)

% FUNCTION to create header H from XML electrode file
%
%
% SYNTAX
%         [H] = XMLreadECoG(filename)
%
% DESCRIPTION
%         'filename', being a string containing path to file
%
% OUTPUT
%         'H', being a header [1 x 1 struct], containing information about 
%         the electrodes 
%
% JBehncke, Apr'15

% convert XML file to MATLAB structure
rawH = parseXML(filename);

% get names and positions of electrodes from rawH
Ecnt = 1;
for i = 1:size(rawH.Children,2)
    if strcmp(rawH.Children(1,i).Name,'Electrode')
        
        if strcmp(rawH.Children(1,i).Children(1,1).Name,'Label') 
            en{1,i} = rawH.Children(1,i).Children(1,1).Children.Data;
        else
            dlg = ['ERROR: Label of Electrode #%d is not correct. \r\n'...
                   'Check variable rawH.Children(1,%d).Children(1,1).Name'...
                   ' while using function XMLreadECoG.m! \r\n'];
            fprintf(dlg,i,i);
            return
        end
        if strcmp(rawH.Children(1,i).Children(1,3).Name,'XCoordinate') 
            ep(i,1) = str2double(rawH.Children(1,i).Children(1,3).Children.Data);
        else
            dlg = ['ERROR: XCoordinate of Electrode #%d is not correct.'...
                   '\r\nCheck variable rawH.Children(1,%d).Children(1,1).Name'...
                   ' while using function XMLreadECoG.m! \r\n'];
            fprintf(dlg,i,i);
            return
        end 
        if strcmp(rawH.Children(1,i).Children(1,4).Name,'YCoordinate') 
            ep(i,2) = str2double(rawH.Children(1,i).Children(1,4).Children.Data);
        else
            dlg = ['ERROR: YCoordinate of Electrode #%d is not correct.'...
                   '\r\nCheck variable rawH.Children(1,%d).Children(1,1).Name'...
                   ' while using function XMLreadECoG.m! \r\n'];
            fprintf(dlg,i,i);
            return
        end 

        Ecnt = Ecnt + 1;
    end    
end

% def H.electrodes (electrode name) & H.electrodesPos (electrode position)
H.electrodes = en;
H.electrodesPos = ep;

end