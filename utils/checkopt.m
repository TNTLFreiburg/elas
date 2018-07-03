function out=checkopt(v,varargin)
% function opt_or_x=checkopt(v,opt)
% checks whether option(s) opt is/are found in varargin cell array v
% returns 1 if one or more of the options in opt are found, zero if not
% opt may be string with 1 option name or cell array with multiple option
% names
% 
% general format of optional argumwnts: 
% e.g. data=newcar(eeg,'-f','butter',0.5,'high','-mat')
% -> main options are strings starting with a '-' and may have 
% string or numeric arguments following behind

%  strmatch funktioniert nicht, weil v numerische Zellen enthalten kann!

out=0;
subopt='';
if nargin==2
    opt=varargin;
elseif nargin==3
    opt=varargin{1};
    subopt=varargin{2};
end

if ischar(opt)
	for r=1:length(v)
        b=v{r};
        if ischar(b)
            if length(b)==length(opt)
                if b==opt
                    out=1;
                    optpos=r;
                end
            end
        end
	end
else
    for r=1:length(opt)
        o=opt{r};
        for rr=1:length(v)
            b=v{rr};
            if ischar(b) & ischar(o) & length(b)==length(o)
                if b==o; out=1; end
            end
	    end
    end
end

if out==1 & ~isempty(subopt)
    out=0;
    r=optpos;
    while 1
        b=v{r};
        if ischar(b)
            if length(b)==length(subopt)
                if b==subopt
                    out=1;
                end
            end
        end
        r=r+1;
        if r==length(v)+1; break; end
        bb=v{r};
        if strmatch('-',bb)==1; break; end
	end
end


    
    