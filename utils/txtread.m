function [rawOutput] = txtread(file)

% FUNCTION to write data from text file into a cell array of "objects"
%
%
% SYNTAX
%         [rawOutput] = txtread(file)
%
% DESCRIPTION
%         'file', being a string containing path to file; if no directory
%         in string included, file has to be in current directory
%
% OUTPUT
%         'rawOutput', being a [m x n cell], m for number of lines in data
%         file and n for number of "objects"
%
% JBehncke, Mrz'15


% load file data with delimiter 'newline' (\n)
fid = fopen( file, 'r' );
directScan = textscan( fid, '%s', 'delimiter', '\n');
directScan = directScan{1};
fclose(fid);

% write every data "object" into next cell according to line in raw data
numrows = size(directScan,1);
rawOutput = cell(1);
for i = 1:numrows
    directScan{i}(end+1) = 9;
    tmp = regexprep(regexp(directScan{i},'[^\t]*\t','match'),'\t','');
    rawOutput(i,1:numel(tmp)) = tmp;
end

end