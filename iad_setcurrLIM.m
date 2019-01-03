function iad_setcurrLIM(hh,ee,t,ax) 

axon=get(gcf,'currentaxes');
xlim=get(axon,'xlim');

dt=abs(diff(xlim));

if dt>1*86400 && dt<7*86400 
    tformat=6;
end

if dt>7*86400 
    tformat=12;
end

if dt>15*60 && dt<1*86400 
    tformat=15;
end

if dt<15*60
    tformat=13;
end

if ~exist('tformat','var')
    tformat=15;
end

step=round(diff(xlim)/10);
xt=min(xlim):step:max(xlim);
for i=1:length(ax)
    set(ax(i),'xtick',xt,'xticklabel','','xlim',xlim)
    if i==length(ax),
        set(ax(i),'xtick',xt,'xticklabel',datestr(t(1)+xt/86400,tformat))
    end
end


return