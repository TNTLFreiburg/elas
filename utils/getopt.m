function varargout=getopt(v,opt)
% varargout=getopt(v,opt)
% returns arguments of option opt in varargin cell array v

for r=1:length(v)
    b=v{r};
    if ischar(b)
        if length(b)==length(opt)
            if b==opt
                optpos=r;
            end
        end
    end
end

z=1;
while 1
    optpos=optpos+1;
    if optpos>length(v); break; end
    b=v{optpos};
    if ischar(b)
        if b(1)=='-'; break; end
    end
    varargout(z)={b};
    z=z+1;
end

if z==1
    varargout{1}='NoOpt';
end