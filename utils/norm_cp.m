function H=norm_cp(H,margin)
% function H=norm_cp(H,margin)
% returns normalized channel positions ranging between 0 and 1
% the distance from 0 and 1 of the outermost channels is set to margin
% default for margin: 0.05

if nargin==1; margin=0.05; end
file=H;
file.cp(:,1)=file.cp(:,1)-min(file.cp(:,1));
file.cp(:,2)=file.cp(:,2)-min(file.cp(:,2));
file.cp(:,1)=file.cp(:,1)/max(file.cp(:,1));
if max(file.cp(:,2))~=0
    file.cp(:,2)=file.cp(:,2)/max(file.cp(:,2));
end

file.cp=file.cp*(1-margin*2)+margin;

H=file;