function minmax=posplot(header,val,varargin)
% function minmax=posplot(header,val,varargin)
% plots values of not-bad, not-aux channels
% value: values to plot, eihter one value per channel
% or a M x N matrix per channel, with size(val)= channel,M,N
%
% general options
% -------------------------------------------------------------------------
% '-names'              plot channel names
% '-names_fontsize      fontsize for plot names
% '-names_color'        text color for names
% '-number'             plot channel numbers
% '-val'                plot channel values
% '-size',[a]           define window size in % of whole window, default: 7%
% '-plotall'            plot all channels (per default, auxilliary channels
%                       are omitted)
% '-tcolor',[r,g,b]     define text color
% '-bcolor',[r,g,b]     define background color
% '-clim',[c1 c2]       colorlimits
% '-figure'             open figure
% '-title',[n]          plot figure title
% '-markel',[r,g,b,s]   mark elektrode positions [linecolor, size]
%                       (makes only sense for interpolated maps)
% '-markelf',[r,g,b]    electrode face color
% '-colormap',[cm]      pass colormap in N x 3 array
% '-colorbar',(string)  plot colorbar
%                       (only for one value per channel plot)
%                       string='mmm' plot max, min, mean ticks
%                       string='mmz' plot max, min, zero ticks
%                       default= mmz
% '-invertcolor'
%
% 1D single plot options
% -------------------------------------------------------------------------
% '-ipol' points,meth   interpolate map using griddata, points = number of
%                       points in the interpolated plot, meth =
%                       interpolation method, eg 'cubic'
% '-i_line',P,c,w,s,f   plot line through points defined by P in plot generated
%                       with -ipol, c=color, w=linewidth, s=linesytle
%                       for full line use s=1, not '-'; s=2 -> '--'
%                       f= 'finess' of the interpolation of the line; eg
%                       f=10 -> 9 points are added between each pair of
%                       points defined in P:
%                         P(1).p={'G_A8','G_B8',0.5};
%                         P(2).p={'G_B7'};
%                         P(3).p={'G_B6','G_C6'};
%                         P(4).p={'G_B5','G_C5'};
%                         P(5).p={'G_B4','G_B5',0.3};
%                         P(6).p={'G_A4','G_B4',0.4};
%                         P(7).p={'G_B3','G_B4'};
%                         P(8).p={'G_B2','G_C2'};
%                         P(9).p={'G_C2','G_D1'};
%                         P(10).p={'G_C1','G_D1',0.3};
% e.g.:
% posplot(H,val,'-figure','-smark',ones(H.noc,1),'o',6,'k','-ipol',1000,'cubic','-i_line',P,'k',3,1,10)
%
% '-delaunay'           interpolate map using delaunay triangulation
% '-smark',m,(string),ms,c  mark all elektrodes for which m==1 with marker
%                       [string] of size ms and color c in interpolated plot
% '-smarkonly'          add markers to existing plot
%
%
% 2D plot options
% -------------------------------------------------------------------------
% '-xlog'               x achis log.
% '-ylog'               y achis log.
% '-transp'             transparency for patches
%
% correlation dot plots & options
% -------------------------------------------------------------------------
% Call: posplot(H,xval,'-corr',yval) xval and yval vecors of same length
% with x and y values
% '-corr_color'         color of dots
% '-corr_ms'            makersize of dots
% '-corr_regline'       plot regression line
% '-corr_regline_color' plot regression line color
% '-corr_regline_width' plot regression line width
% !!! All 'options' must be specified !!!
%
% Example: TWO Correlations:
% V=randn(H.noc,1000);
% V2=randn(H.noc,1000,2);
% posplot(H,V,'-figure','-size',4,'-corr',V2,'-corr_color',{'r','m'},...
%  '-corr_ms',[6,6],'-corr_regline','-corr_regline_color',{'b','g'},'-corr_regline_width',[3,3])
%
% ONE correlation:
% V=randn(H.noc,1000);
% V2=randn(H.noc,1000);
% V2=repmat(V2,[1,1,2]);
% posplot(H,V,'-figure','-size',4,'-corr',V2,'-corr_color',{'r','m'},...
%  '-corr_ms',[6,6],'-corr_regline','-corr_regline_color',{'b','g'},'-corr_regline_width',[3,3])
%
%
% 2&3D single plot options
% -------------------------------------------------------------------------
% '-negup'              reversed y axis direction in 2D plots
% '-linewidth',lw       linewidth
% '-linecolor',lc       linecolor
% '-std',[stdval]       plot std around 2D plot
% '-stdcolor',c$        std color, e.g. 'g'
% '-iqr',[irqdat]       plot iqr; size irqdat = channel x time x 2
% '-iqrcolor',c$        iqr color, e.g. 'g'
% '-iqrlinestyle'       iqr linestyle
% '-iqrlinewidth'       iqr linewidth
% '-stdlinestyle'       std linestyle
% '-stdlinewidth'       std linewidth
% '-yzero',(m)          plot y=0 line, moved by m bins, if m is a vector,
%                       multiple lines are plotted
% '-xzero',(m)          plot x=0 line, m -> usage as with -yzero
%                       if header has field zerotimebin, axis is plotted
%                       here
% '-axcolor', c         color for above
% '-plotmean',[t]       if t is scalar plot mean for t, if size(t)= [1 2],
%                       plot mean value between t1 and t2
% '-map',from,to        plot mean from:to as map
% '-xtick',[xt,xtl]     plot xticks @ xt with xticklabels xtl
% '-ytick',[yt,ytl]     plot yticks
% '-tickcolor',c        color for above
% '-ylim',[yl1 yl2]     axis ylim
% '-multiplot',c        plot multiple lineplots from 3D-array
%                       (channel x time x line) in colors c, for instance
%                       {'k','m'} for two lines in black and magenta
% '-box',arg, width     plot box with width width around subplots
%                       arg zB arg={'H3','b','O3','b','G3','r'}
% '-text',a,p,fs,w,fn   plot text within subplots at position p and
%                       fontsize fs and weight w, and fontname fn
%                       a zB a={'H3','x','O3','GG','G3','a'}
%                       pos zB [0.1,0.1]
% '-plotcolor',arg,c    plot subplots in color c (channels x 3 array) for subplots
%                       arg zB arg={'H3','b','O3','b','G3','r'}
% '-multimap'
% '-movie'
% '-markpoint',dat,m,s,c  dat = vektor channel x time with 0 and 1's, all
%                       time points == 1 -> maked with marker m (eg 'o')
%                       of size s (eg 10) and color c
%
% examples:
% posplot(H,val,'-figure','-size',5,'-iqr',iqrval,'-ylim',[-15 15],'-markpoint',M,'o',3,'g')
%
% T. Ball 2006-2009

header=norm_cp(header);
valdim=size(size(val),2);
if valdim==2 & size(val,2)==1; valdim=1; end

cn=header.cn;
aux=header.aux;
cp=header.cp;
noc=header.noc;

markelcolor=[0 0 0];
markelsize=10;

plotnames=0; plotvalues=0; plotnumbers=0;
zerobox=0;
ssize=7;
if valdim==3; ssize=6; end
minmax=1;
ipol=0;
bcolor=[1 1 1];
markel=0;
markelf=0;
autotcolor=1;
plotall=0;
plotcolorbar=0; invertcolor=0;
negup=0;
plotstd=0; yzero=0; xzero=0; plotmean=0; smark=0;
plotmap=0; multimap=0;
linewidth=1; ytick=0;
stdcolor='r'; stdlinestyle=':'; stdlinewidth=0.5;
iqrcolor='r'; iqrlinestyle=':'; iqrlinewidth=0.5;
multiplot=0;
smarkonly=0;plotbox={};
plottext={};
set_ylim=0;
plotcolor=[];
linecolor='k';
axcolor='b';
ipol_delaunay=0;
xtick=0; ytick=0; plotiqr=0;
markpoint=0;
tickcolor=[0 0 0];
names_fontsize=12; names_color=[0 0 0]; ipolstep=1;
pxlog=0; pylog=0; plotcorr=0; plot_iline=0;
plotcorr_color=[0 0 1]; plotcorr_ms=2; corr_regline=0; corr_regline_color='k'; corr_regline_width=1;
patchalpha=1; 
if checkopt(varargin,'-i_line')
    plot_iline=1; [iline_P,iline_c,iline_w,iline_s,iline_f]=getopt(varargin,'-i_line'); 
    for r=1:numel(iline_s)
        if iline_s(r).s==1; iline_s(r).s='-'; end
        if iline_s(r).s==2; iline_s(r).s='--'; end
    end
end
% if checkopt(varargin,'-transp'); patchalpha=getopt(varargin,'-transp'); end
% if checkopt(varargin,'-i_line')
%     plot_iline=1; [iline_P,iline_c,iline_w,iline_s,iline_f]=getopt(varargin,'-i_line');
%     if iline_s==1; iline_s='-'; end
%     if iline_s==2; iline_s='--'; end
% end
if checkopt(varargin,'-corr_regline_width'); corr_regline_width=getopt(varargin,'-corr_regline_width'); end
if checkopt(varargin,'-corr_regline'); corr_regline=1; end
if checkopt(varargin,'-corr'); plotcorr=1; plotcorrY=getopt(varargin,'-corr'); plotall=1; end
if checkopt(varargin,'-corr_color'); plotcorr_color=getopt(varargin,'-corr_color'); end
if checkopt(varargin,'-corr_ms'); plotcorr_ms=getopt(varargin,'-corr_ms'); end
if checkopt(varargin,'-xlog'); pxlog=1; end
if checkopt(varargin,'-ylog'); pylog=1; end
if checkopt(varargin,'-names_color'); names_color=getopt(varargin,'-names_color'); end
if checkopt(varargin,'-names_fontsize'); names_fontsize=getopt(varargin,'-names_fontsize'); end
if checkopt(varargin,'-tickcolor'); tickcolor=getopt(varargin,'-tickcolor'); end
if checkopt(varargin,'-delaunay'); ipol_delaunay=1; end
if checkopt(varargin,'-smarkonly'); smarkonly=1; end
if checkopt(varargin,'-multiplot'); multiplot=1; valdim=2; multicolor=getopt(varargin,'-multiplot'); end
if checkopt(varargin,'-multimap'); multimap=1; end
if checkopt(varargin,'-names'); plotnames=1; end
if checkopt(varargin,'-map'); plotmap=1; [map_from,map_to]=getopt(varargin,'-map'); end
if checkopt(varargin,'-ytick'); ytick=1; [ytick_yt, ytick_ytl]=getopt(varargin,'-ytick'); end
if checkopt(varargin,'-xtick'); xtick=1; [xtick_xt, xtick_xtl]=getopt(varargin,'-xtick'); end
if checkopt(varargin,'-markpoint'); markpoint=1; [markpointdat,markpointM,markpointS,markpointC]=getopt(varargin,'-markpoint'); end
if checkopt(varargin,'-smark'); smark=1; ipol=1; [smarks,smarkstring,markelsize,markelcolor]=getopt(varargin,'-smark'); end
if checkopt(varargin,'-val'); plotvalues=1; end
if checkopt(varargin,'-number'); plotnumbers=1; end
if checkopt(varargin,'-size'); ssize=getopt(varargin,'-size'); end
if checkopt(varargin,'-size'); ssize=getopt(varargin,'-size'); end
if checkopt(varargin,'-plotall'); plotall=1; end
if checkopt(varargin,'-zerobox'); zerobox=1; end
if checkopt(varargin,'-clim'); clim=getopt(varargin,'-clim'); minmax=0; end
if checkopt(varargin,'-figure'); figure; end
if checkopt(varargin,'-ipol'); ipol=1; [ipolstep,ipolmeth]=getopt(varargin,'-ipol'); end
if checkopt(varargin,'-bcolor'); bcolor=getopt(varargin,'-bcolor'); end
if checkopt(varargin,'-markel'); markel=1; markelopt=getopt(varargin,'-markel'); markelcolor=markelopt(1:3); markelsize=markelopt(4); end
if checkopt(varargin,'-markelf'); markelf=1; markelfcolor=getopt(varargin,'-markelf'); end
if checkopt(varargin,'-colorbar'); plotcolorbar=1; cbstyle=getopt(varargin,'-colorbar'); if findstr(cbstyle,'NoOpt')==1; cbstyle='mmz'; end; end
if checkopt(varargin,'-invertcolor'); invertcolor=1; end
if checkopt(varargin,'-negup'); negup=1; end
if checkopt(varargin,'-std'); plotstd=1; stddat=getopt(varargin,'-std'); if valdim~=2; error('option -plotstd only with 2D plot'); end; end
if checkopt(varargin,'-xzero'); xzero=1; move_xzero=getopt(varargin,'-xzero'); if isstr(move_xzero); move_xzero=0; end; end
if checkopt(varargin,'-iqr'); plotiqr=1; iqrdat=getopt(varargin,'-iqr'); if valdim~=2; error('option -plotstd only with 2D plot'); end; end
if checkopt(varargin,'-yzero'); yzero=1; move_yzero=getopt(varargin,'-yzero'); if isstr(move_yzero); move_yzero=0; end; end
if checkopt(varargin,'-colormap'); m=getopt(varargin,'-colormap'); colormap(m); else m=colormap; end
if checkopt(varargin,'-plotmean'); plotmean=1; plotmeantime=getopt(varargin,'-plotmean'); end
if checkopt(varargin,'-linewidth'); linewidth=getopt(varargin,'-linewidth'); end
if checkopt(varargin,'-stdcolor'); stdcolor=getopt(varargin,'-stdcolor'); end
if checkopt(varargin,'-iqrcolor'); iqrcolor=getopt(varargin,'-iqrcolor'); end
if checkopt(varargin,'-stdlinestyle'); stdlinestyle=getopt(varargin,'-stdlinestyle'); end
if checkopt(varargin,'-stdlinewidth'); stdlinewidth=getopt(varargin,'-stdlinewidth'); end
if checkopt(varargin,'-box'); [plotbox,plotboxwidth]=getopt(varargin,'-box'); end
if checkopt(varargin,'-iqrlinestyle'); iqrlinestyle=getopt(varargin,'-iqrlinestyle'); end
if checkopt(varargin,'-iqrlinewidth'); iqrlinewidth=getopt(varargin,'-iqrlinewidth'); end
if checkopt(varargin,'-text'); [plottext,plottext_pos,plottext_fs,plottext_wheight,plottext_fn]=getopt(varargin,'-text'); end
if checkopt(varargin,'-ylim'); set_ylim=1; set_ylim_val=getopt(varargin,'-ylim'); end
if checkopt(varargin,'-plotcolor'); [plotcolor,plotcolorC]=getopt(varargin,'-plotcolor'); end
if checkopt(varargin,'-linecolor'); linecolor=getopt(varargin,'-linecolor'); end
if checkopt(varargin,'-axcolor'); axcolor=getopt(varargin,'-axcolor'); end

patchalpha;

if plotmap
    size(val)
    newval=squeeze(mean(val(:,map_from:map_to),2));
    size(newval)
    clear val
    val=newval;
    valdim=1;
end

%if multimap


if valdim==1 | plotmean

    if plotmean
        if isfield(header,'zerotimebin'); plotmeantime=...
                plotmeantime+header.zerotimebin; end
        if size(plotmeantime,2)==1; plotmeantime=[plotmeantime,plotmeantime]; end
        for r=1:noc
            nval(r)=mean(val(r,plotmeantime(1):plotmeantime(2)));
        end
        val=nval;
    end
    if invertcolor; val=val*(-1); end
    % plot single value at each channel position
    hold on
    if plotall
        z=1;
        for r=1:noc
            val2(z)=val(r);
            val2cp(z,1:2)=cp(r,1:2);
            val2cn(z)=cn(r);
            if smark; val2smarks(z)=smarks(r); end
            z=z+1;
        end
    else
        z=1;
        for r=1:noc
            skip=0;
            for rr=1:length(aux)
                n1=char(cn(r));
                n2=char(aux(rr));
                if length(n1)==length(n2)
                    if n1==n2; skip=1; end
                end
            end
            if skip==0
                val2(z)=val(r);
                val2cp(z,1:2)=cp(r,1:2);
                val2cn(z)=cn(r);
                if smark; val2smarks(z)=smarks(r); end
                z=z+1;
            end
        end
    end

    if minmax
        colstep=range(val2)/(size(m,1)-1);
    else
        colstep=(clim(2)-clim(1))/(size(m,1)-1);
    end

    pos=get(gcf,'Position');
    w=pos(3)*(ssize/100);
    h=pos(4)*(ssize/100);

    hold on
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',[])
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    set(gca,'XLim',[0 1])
    set(gca,'YLim',[0 1])


    if ~ipol & ~ipol_delaunay

        for r=1:length(val2)

            if minmax
                if max(diff(val))~=0
                    col(1:3)=m(1+floor((val2(r)-min(val2))/colstep),1:3);
                else
                    col=[1 1 1];
                end
            else
                1+floor((val2(r)-clim(1))/colstep);
                if 1+floor((val2(r)-clim(1))/colstep)>=size(m,1)
                    col(1:3)=m(end,1:3);
                elseif (1+floor((val2(r)-clim(1)))/colstep)<=1
                    col(1:3)=m(1,1:3);
                else
                    col(1:3)=m(1+floor((val2(r)-clim(1))/colstep),1:3);
                end
            end

            l=val2cp(r,1)-ssize/200;
            b=val2cp(r,2)-ssize/200;
            w=ssize/100;

            ph=patch([l l+w l+w l],[b b b+w b+w],col);
            set(ph,'facealpha',patchalpha,'edgealpha',patchalpha);
            if zerobox & val(r)==0
                set(ph,'linewidth',5)
            end
            if ~plotvalues & plotnames
                h=text(l+w/10,b+w/2,val2cn(r));
                set(h,'interpreter','none','fontsize',names_fontsize,'color',names_color)
            elseif ~plotnames & plotvalues
                h=text(l+w/10,b+w/2,num2str(val(r)));
                set(h,'interpreter','none')
            elseif plotnames & plotvalues
                h1=char(val2cn(r));
                h2=num2str(val(r));
                h=text(l+w/10,b+w/2,sprintf([h1,'\n',h2]));
                set(h,'interpreter','none','fontsize',names_fontsize,'color',names_color)
            end
            if plotvalues | plotnames
                if autotcolor
                    %autocol=[1-sum(col)/3,1-sum(col)/3,1-sum(col)/3];

                    autocol=[1-col(1),1-col(2),1-col(3)];
                    set(h,'Color',autocol)
                else
                    set(h,'Color',tcolor)
                end
            end
        end
    else
        if ~smarkonly & ipol_delaunay
            tri=delaunay(val2cp(:,1),val2cp(:,2));
            trisurf(tri,val2cp(:,1),val2cp(:,2), ones(length(val2cp),1), val2)
            if minmax==0; caxis(clim); end
            shading interp
        elseif ~smarkonly & ipol
            X=linspace((min(val2cp(:,1))),(max(val2cp(:,1))),ipolstep);
            Y=linspace((min(val2cp(:,2))),(max(val2cp(:,2))),ipolstep);
            [Xi,Yi]=meshgrid(X,Y);
            Vi=griddata(val2cp(:,1),val2cp(:,2),val2,Xi,Yi,ipolmeth);
            imagesc(Vi); axis tight
            if minmax==0; caxis(clim); end
        end
        if markel
            for e=1:length(val2cp)
                h=plot3(val2cp(:,1),val2cp(:,2),ones(length(val2cp))*2,'o');
                set(h,'color',markelcolor)
                if markelf; set(h,'markerfacecolor',markelfcolor); end
                set(h,'MarkerSize',markelsize)
            end
        end
        minx=min(val2cp(:,1)); maxx=max(val2cp(:,1)); miny=min(val2cp(:,2)); maxy=max(val2cp(:,2));
        xl=get(gca,'xlim'); yl=get(gca,'ylim');
        xsc=xl(2)/(maxx-minx); ysc=yl(2)/(maxy-miny);
        if smark
            for e=1:numel(val2smarks)
                if val2smarks(e)==1
                    if ~ipol
                        h=plot3(val2cp(e,1),val2cp(e,2),1,smarkstring);
                    else
                        h=plot3((val2cp(e,1)-minx)*xsc+1,(val2cp(e,2)-miny)*ysc+1,1,smarkstring);
                    end
                    set(h,'color',markelcolor)
                    if markelf; set(h,'markerfacecolor',markelfcolor); end
                    set(h,'MarkerSize',markelsize)
                end
            end
        end

if plot_iline
    L=iline_P;
    for ll=1:numel(L)
        clear PP
        for pp=1:numel(L(ll).P)
            if numel(L(ll).P(pp).p)==1
                PP(pp,:)=header.cp(na2nu(header,char(L(ll).P(pp).p)),:);
            elseif numel(L(ll).P(pp).p)==2
                n1=na2nu(header,char(L(ll).P(pp).p{1}));
                n2=na2nu(header,char(L(ll).P(pp).p{2}));
                PP(pp,1)=mean([header.cp(n1,1),header.cp(n2,1)]);
                PP(pp,2)=mean([header.cp(n1,2),header.cp(n2,2)]);
            elseif numel(L(ll).P(pp).p)==3
                n1=na2nu(header,char(L(ll).P(pp).p{1}));
                n2=na2nu(header,char(L(ll).P(pp).p{2}));
                gew1=L(ll).P(pp).p{3}; gew2=2-L(ll).P(pp).p{3};
                PP(pp,1)=(header.cp(n1,1)*gew1+header.cp(n2,1)*gew2)/2;
                PP(pp,2)=(header.cp(n1,2)*gew1+header.cp(n2,2)*gew2)/2;
            else
                error('Too much arguments in P-struct!')
            end
        end
        PP(:,1)=(PP(:,1)-minx).*xsc;
        PP(:,2)=(PP(:,2)-miny).*ysc;
        [PPyi,PPxi]=pathinterp(PP(:,1),PP(:,2),iline_f);
        PPh=plot(PPxi,PPyi,iline_s(ll).s);
        set(PPh,'linewidth',iline_w(ll),'color',iline_c(ll).c)
    end
end
set(gca,'xcolor','w','ycolor','w')
xl=get(gca,'xlim'); yl=get(gca,'ylim');
xls=(xl(2)-xl(1))/100; yls=(xl(2)-yl(1))/100;
set(gca,'xlim',[xl(1)-xls xl(2)+xls],'xlim',[yl(1)-yls yl(2)+yls])
axis tight
    end

    minmax=[min(val2),max(val2)];
    if checkopt(varargin,'-title')
        t=getopt(varargin,'-title');
        title(t)
    end

    if ~smarkonly
        set(gca,'color',bcolor)
    end

    if plotcolorbar
        cbh=colorbar;
        if minmax
            cb1=min(val2);
            cb3=max(val2);
        else
            cb1=clim_org(1);
            cb3=clim_org(2);
        end
        if cbstyle=='mmm'
            cb2=mean([cb1,cb3]);
            cb2pos=0.5;
        else
            if cb1<0 & cb3>0
                cb2=0;
                cb2pos=-min(val2)/range(val2);
            else
                warning('no zero value in colorbar, using mean instead')
                cb2=mean([cb1,cb3]);
                cb2pos=0.5;
            end
        end
        set(cbh,'ytick',[0 cb2pos 1]);
        set(cbh,'yticklabel',[cb1,cb2,cb3]);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif valdim==2 & ~plotmean

    if plotall; aux=[]; end

    for lines=1:size(val,3)
        z=1;
        for r=1:noc
            skip=0;
            for rr=1:length(aux)
                n1=char(cn(r));
                n2=char(aux(rr));
                if length(n1)==length(n2)
                    if n1==n2; skip=1; end
                end
            end
            if skip==0
                newdat=val(r,:,lines);
                val2(z,1:size(val,2),lines)=newdat;
                minval2(z,lines)=min(newdat);
                maxval2(z,lines)=max(newdat);
                val2cp(z,1:2)=cp(r,1:2);
                val2cn(z)=cn(r);
                if plotcorr; val3(z,1:size(val,2),:)=plotcorrY(r,:,:); end
                if plotstd
                    stddat2(z,1:size(val,2),lines)=stddat(r,:,lines);
                    minstd2(z,lines)=min(newdat-stddat(r,:,lines));
                    maxstd2(z,lines)=max(newdat+stddat(r,:,lines));
                end
                if plotiqr
                    if ~multiplot
                        iqrdat2(z,1:size(val,2),1:2)=iqrdat(r,:,:);
                        miniqr2(z)=min(newdat-iqrdat(r,:,1));
                        maxiqr2(z)=max(newdat+iqrdat(r,:,2));
                    else
                        iqrdat2(z,1:size(val,2),1:2,:)=iqrdat(r,:,:,:);
                        miniqr2(z,lines)=(min(newdat-iqrdat(r,:,1,lines)));
                        maxiqr2(z,lines)=(max(newdat+iqrdat(r,:,2,lines)));
                    end
                end
                if markpoint
                    if ~multiplot
                        markpointdat2(z,1:size(val,2))=markpointdat(r,:);
                    else
                        markpointdat2(z,1:size(val,2),lines)=markpointdat(r,:,lines);
                    end
                end
                z=z+1;
            end
        end
    end

    minall=min(minval2(:));
    maxall=max(maxval2(:));

   
    if plotstd
        minstdall=min(minstd2(:));
        maxstdall=max(maxstd2(:));
    end
    if plotiqr
        miniqrall=min(miniqr2(:));
        maxiqrall=max(maxiqr2(:));
    end

    if plotall
        val2=val;
        val2cn=header.cn;
        val2cp=header.cp;
        try; stddat2=stddat; end
        try; iqrdat2=iqrdat; end
    end

    for lines=1:size(val,3)
        for r=1:size(val2,1)
            subplot('position',[val2cp(r,1)-ssize/200 val2cp(r,2)-ssize/200 ssize/100 ssize/100])
            hold on
            set(gca,'XTickLabel',[])
            set(gca,'YTickLabel',[])
            set(gca,'XTick',[])
            set(gca,'YTick',[])
            set(gca,'xcolor','w')
            set(gca,'ycolor','w')
            set(gca,'ButtonDownFcn','call_copy');
            if plotstd
                tp=size(val2,2);
                dat=squeeze(val2(r,:,lines));
                sdat=squeeze(stddat2(r,:,lines));
                x=[1:tp,tp:-1:1];
                ydat2=dat-sdat;
                ydat2=ydat2(end:-1:1);
                y=[dat+sdat,ydat2];
                h=patch(x,y,stdcolor(lines,:));
                set(h,'facealpha',patchalpha,'edgealpha',patchalpha);
                set(h,'ButtonDownFcn','call_copy');
                set(h,'linestyle',stdlinestyle,...
                    'linewidth',stdlinewidth)
            end
            if plotiqr
                tp=size(val2,2);
                dat=squeeze(val2(r,:,lines));
                sdat1=squeeze(iqrdat2(r,:,1,lines));
                sdat2=squeeze(iqrdat2(r,:,2,lines));
                x=[1:tp,tp:-1:1];
                ydat2=dat-sdat1;
                ydat2=ydat2(end:-1:1);
                y=[dat+sdat2,ydat2];
                h=patch(x,y,iqrcolor(lines,:));
                set(h,'facealpha',patchalpha,'edgealpha',patchalpha);
                set(h,'ButtonDownFcn','call_copy');
                set(h,'linestyle',iqrlinestyle,...
                    'linewidth',iqrlinewidth)
            end
            if ~plotcorr
                h=plot(squeeze(val2(r,:,lines)),'-');
                set(h,'ButtonDownFcn','call_copy');
                set(h,'linewidth',linewidth,'color',linecolor)
            else
                subplot('position',[val2cp(r,1)-ssize/200 val2cp(r,2)-ssize/200 ssize/100 ssize/100])
                hold on
                set(gca,'XTickLabel',[])
                set(gca,'YTickLabel',[])
                set(gca,'XTick',[])
                set(gca,'YTick',[])
                set(gca,'xcolor','w')
                set(gca,'ycolor','w')
                set(gca,'ButtonDownFcn','call_copy');
                for rrr=1:size(val3,3)
                    h=plot(squeeze(val2(r,:)),squeeze(val3(r,:,rrr)),'.');
                    set(h,'MarkerEdgeColor',char(plotcorr_color(rrr)),'MarkerFaceColor',char(plotcorr_color(rrr)),...
                        'MarkerSize',plotcorr_ms(rrr));
                    set(h,'ButtonDownFcn','call_copy');
                end
                for rrr=1:size(val3,3)
                    if corr_regline
                        [p,s]=polyfit(squeeze(val2(r,:)),squeeze(val3(r,:,rrr)),1);
                        xl=get(gca,'xlim');
                        y1=xl(1)*p(1)+p(2);
                        y2=xl(2)*p(1)+p(2);
                        h=plot([xl(1) xl(2)],[y1 y2],'r-');
                        set(h,'linewidth',corr_regline_width(rrr),'color',char(corr_regline_color(rrr)));
                        set(h,'ButtonDownFcn','call_copy');
                    end
                end
            end
            if markpoint
                DAT=squeeze(val2(r,:,lines));
                DAT2=markpointdat2(r,:,lines);
                htemp=plot(find(DAT2==1),DAT(find(DAT2==1)),markpointM);
                set(htemp,'markersize',markpointS,'markerfacecolor',...
                    markpointC,'markeredgecolor',markpointC,...
                    'ButtonDownFcn','call_copy');
            end
            if multiplot
                try
                    set(h,'color',char(multicolor(lines)))
                catch
                    set(h,'color',multicolor(lines,:))
                end
            end
            axis tight

            if ~isempty(plotcolor)
                z=1;
                while 1
                    if iscell(plotcolor)
                        n=char(plotcolor{z});
                        n=na2nu(header,n);
                    else
                        n=plotcolor(z);
                    end
                    if r==n
                        set(gca,'color',plotcolorC(z,:))
                    end
                    z=z+1;
                    if z>size(plotcolor,2); break; end
                end
            end

            if ~plotstd
                set(gca,'ylim',[minall maxall])
            elseif plotstd
                set(gca,'ylim',[minstdall maxstdall])
            end
            if plotiqr
                set(gca,'ylim',[miniqrall maxiqrall])
            end

            if set_ylim
                set(gca,'ylim',[set_ylim_val(1) set_ylim_val(2)])
            end

            ylimdef=get(gca,'ylim');
            xlimdef=get(gca,'xlim');
            if yzero & ylimdef(1)<move_yzero
                for rr=1:length(move_yzero)
                    h=plot([xlimdef(1),xlimdef(2)],[move_yzero(rr) move_yzero(rr)],axcolor);
                    set(h,'ButtonDownFcn','call_copy');
                end
            end
            if xzero & isfield(header,'zerotimebin')
                for rr=1:length(move_xzero)
                    h=plot([header.zerotimebin+move_xzero(rr)...
                        header.zerotimebin+move_xzero(rr)],[ylimdef(1),ylimdef(2)],axcolor);
                    set(h,'ButtonDownFcn','call_copy');
                end
            elseif xzero & xlimdef(1)<move_xzero
                for rr=1:length(move_xzero)
                    h=plot([move_xzero(rr) move_xzero(rr)],[ylimdef(1),ylimdef(2)],axcolor);
                    set(h,'ButtonDownFcn','call_copy');
                end
            end
            if negup; set(gca,'ydir','reverse'); end
            if plotnumbers
                h=title(num2str(na2nu(header,char(val2cn(r)))));
                set(h,'VerticalAlignment','top')
                set(h,'ButtonDownFcn','call_copy');
            end
            if plotnames
                h=title(char(val2cn(r)));
                set(h,'VerticalAlignment','top')
                set(h,'ButtonDownFcn','call_copy');
                set(h,'interpreter','none','fontsize',names_fontsize,'color',names_color)
            end
            if ytick
                % ytick_ytl=ytick_yt;
                set(gca,'ytick',ytick_yt,'yticklabel',ytick_ytl)
            end
            if xtick
                % xtick_xtl=xtick_xt;
                set(gca,'xtick',xtick_xt,'xticklabel',xtick_xtl)
            end
            if pxlog; set(gca, 'xscale', 'log'); end
            if pylog; set(gca, 'yscale', 'log'); end
            set(gca,'xcolor',tickcolor)
            set(gca,'ycolor',tickcolor)
        end
    end


elseif valdim==3
    % plot matrix at each channel position
    minval=min(val(:));
    maxval=max(val(:));
    for r=1:size(val,1)
        subplot('position',[header.cp(r,1)-ssize/200 header.cp(r,2)-ssize/200 ssize/100 ssize/100])
        hold on
        set(gca,'XTickLabel',[])
        set(gca,'YTickLabel',[])
        set(gca,'XTick',[])
        set(gca,'YTick',[])
        h=imagesc(squeeze(val(r,:,:)));
        set(h,'ButtonDownFcn','call_copy');
        axis tight

        if ~isempty(plotbox)
            z=1;
            while 1
                n=char(plotbox{z});
                c=char(plotbox{z+1});
                if r==na2nu(header,n)
                    set(gca,'LineWidth',plotboxwidth)
                    set(gca,'color',c)
                    set(gca,'xcolor',c)
                    set(gca,'ycolor',c)
                end
                z=z+2;
                if z>size(plotbox,2); break; end
            end
        end

        if ~isempty(plottext)
            z=1;
            while 1
                n=char(plottext{z});
                c=char(plottext{z+1});
                if r==na2nu(header,n)
                    text(plottext_pos(1),plottext_pos(2),...
                        c,'fontsize',plottext_fs,...
                        'fontweight',plottext_wheight,...
                        'fontname',plottext_fn)
                end
                z=z+2;
                if z>size(plottext,2); break; end
            end
        end

        if ~minmax
            set(gca,'clim',clim)
        else
            set(gca,'clim',[minval maxval])
        end
        if plotnames
            xl=get(gca,'xlim'); yl=get(gca,'ylim');
            h=text(xl(2)/6,yl(2)/4,char(header.cn(r)));
            set(h,'ButtonDownFcn','call_copy');
            set(h,'interpreter','none','fontsize',names_fontsize,'color',names_color)
        end
        if ytick
            set(gca,'ytick',ytick_yt,'yticklabel',ytick_ytl)
        end
        if xtick
            set(gca,'xtick',xtick_xt,'xticklabel',xtick_xtl)
        end
    end
    minmax=[minval,maxval];
end

set(gcf,'color',bcolor)
% axis off

