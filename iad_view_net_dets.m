function iad_view_net_dets
% global E FROM
wpath='http://148.251.122.130/DETECTIONS/';
FROM=input('FROM (yyyy-mm-dd_HH)','s');
TO=input('TO (yyyy-mm-dd_HH)','s');
FROM=datenum(FROM,'yyyy-mm-dd_HH');
T0=datenum(TO,'yyyy-mm-dd_HH');
nownames=FROM:1/24:T0;
nfile=length(nownames);
% stz={'rp1','no1','no2','no3','fru','gm2','gms','prt'};
stz={'rsp','lpb','rpc','hrm'};
nstz=length(stz);

for istz=1:nstz

    prsA=[];bkzA=[];bkzsdA=[];velA=[];velsdA=[];smbA=[];
    fpkA=[];cnsA=[];timeA=[];iexA=[];
    
    prsE=[];bkzE=[];bkzsdE=[];velE=[];velsdE=[];smbE=[];
    fpkE=[];cnsE=[];timeE=[];iexE=[];

    if nfile>0
        dataA=[];
        dataE=[];
        for i=1:nfile
            filename=[char(stz(istz)),'_',datestr(nownames(i),'yyyymmdd_HHMMSS'),'.csv'];
            fileA=[wpath,char(stz(istz)),'_Det_Av/',char(stz(istz)),'_',datestr(nownames(i),'yyyymmdd'),'/',...
                filename];
            disp(fileA)
            try
                urlwrite(fileA,'pippo.csv');
                dataA=cat(1,dataA,textread('pippo.csv'));
                for icu=1:size(dataA,2)
                    eval(['VarName',num2str(icu),'=dataA(:,',num2str(icu),');'])
                end
                [tx,j]=unique(VarName1);
                tt=tx;
                timeA=cat(1,timeA,tt);
                prsA=cat(1,prsA,VarName2(j));
                bkzA=cat(1,bkzA,VarName3(j));
                bkzsdA=cat(1,bkzsdA,VarName4(j));
                velA=cat(1,velA,VarName5(j));
                velsdA=cat(1,velsdA,VarName6(j));
                smbA=cat(1,smbA,VarName7(j));
                fpkA=cat(1,fpkA,VarName8(j));
                cnsA=cat(1,cnsA,VarName9(j));
                iexA=cat(1,iexA,VarName10(j));
            catch
                disp(['...file not founded'])
                
            end
            
            fileE=[wpath,char(stz(istz)),'_Det_Ex/',char(stz(istz)),'_',datestr(nownames(i),'yyyymmdd'),'/',...
                filename];
            disp(fileE)
            try
                urlwrite(fileE,'pippo.csv');
                dataE=cat(1,dataE,textread('pippo.csv'));
                for icu=1:size(dataE,2)
                    eval(['VarName',num2str(icu),'=dataE(:,',num2str(icu),');'])
                end
                [tx,j]=unique(VarName1);
                tt=tx;
                timeE=cat(1,timeE,tt);
                prsE=cat(1,prsE,VarName2(j));
                bkzE=cat(1,bkzE,VarName3(j));
                bkzsdE=cat(1,bkzsdE,VarName4(j));
                velE=cat(1,velE,VarName5(j));
                velsdE=cat(1,velsdE,VarName6(j));
                smbE=cat(1,smbE,VarName7(j));
                fpkE=cat(1,fpkE,VarName8(j));
                cnsE=cat(1,cnsE,VarName9(j));
                iexE=cat(1,iexE,VarName10(j));
            catch
                disp(['...file not founded'])
                continue
            end
            
        end
        
    end
    
    if isempty(timeA)
        dtsA.(char(stz(istz))).time=FROM;
        dtsA.(char(stz(istz))).prs=NaN;
        dtsA.(char(stz(istz))).bkz=NaN;
        dtsA.(char(stz(istz))).bkzsd=NaN;
        dtsA.(char(stz(istz))).vel=NaN;
        dtsA.(char(stz(istz))).velsd=NaN;
        dtsA.(char(stz(istz))).smb=NaN;
        dtsA.(char(stz(istz))).fpk=NaN;
        dtsA.(char(stz(istz))).cns=NaN;
        dtsA.(char(stz(istz))).iex=NaN;
    else         
        dtsA.(char(stz(istz))).time=timeA;
        dtsA.(char(stz(istz))).prs=prsA;
        dtsA.(char(stz(istz))).bkz=bkzA;
        dtsA.(char(stz(istz))).bkzsd=bkzsdA;
        dtsA.(char(stz(istz))).vel=velA;
        dtsA.(char(stz(istz))).velsd=velsdA;
        dtsA.(char(stz(istz))).smb=smbA;
        dtsA.(char(stz(istz))).fpk=fpkA;
        dtsA.(char(stz(istz))).cns=cnsA;
        dtsA.(char(stz(istz))).iex=iexA;
    end
%     ismb=dtsA.(char(stz(istz))).smb>.6 & dtsA.(char(stz(istz))).prs>=0;
%     dtsA.(char(stz(istz))) = structfun(@(x) ( x(ismb) ), dtsA.(char(stz(istz))), 'UniformOutput', false);
    
    if isempty(timeE)
        dtsE.(char(stz(istz))).time=FROM;
        dtsE.(char(stz(istz))).prs=NaN;
        dtsE.(char(stz(istz))).bkz=NaN;
        dtsE.(char(stz(istz))).bkzsd=NaN;
        dtsE.(char(stz(istz))).vel=NaN;
        dtsE.(char(stz(istz))).velsd=NaN;
        dtsE.(char(stz(istz))).smb=NaN;
        dtsE.(char(stz(istz))).fpk=NaN;
        dtsE.(char(stz(istz))).cns=NaN;
        dtsE.(char(stz(istz))).iex=NaN;
    else
        dtsE.(char(stz(istz))).time=timeE;
        dtsE.(char(stz(istz))).prs=prsE;
        dtsE.(char(stz(istz))).bkz=bkzE;
        dtsE.(char(stz(istz))).bkzsd=bkzsdE;
        dtsE.(char(stz(istz))).vel=velE;
        dtsE.(char(stz(istz))).velsd=velsdE;
        dtsE.(char(stz(istz))).smb=smbE;
        dtsE.(char(stz(istz))).fpk=fpkE;
        dtsE.(char(stz(istz))).cns=cnsE;
        dtsE.(char(stz(istz))).iex=iexE;
    end
%     ismb=dtsE.(char(stz(istz))).smb>0 & dtsE.(char(stz(istz))).prs>=0;
%     dtsE.(char(stz(istz))) = structfun(@(x) ( x(ismb) ), dtsE.(char(stz(istz))), 'UniformOutput', false);
    
end




%%

F1=figure;set(F1,'Color','w','pos',[15 40 1400 770])
% Pressure
HH.ax(1)=axes;set(HH.ax(1),'units','normalized','position',[0.05 0.7 0.425 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(1),'on'),grid(HH.ax(1),'on'),box(HH.ax(1),'on')
HH.ax(2)=axes;set(HH.ax(2),'units','normalized','position',[0.05 0.4 0.425 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(2),'on'),grid(HH.ax(2),'on'),box(HH.ax(2),'on')
HH.ax(3)=axes;set(HH.ax(3),'units','normalized','position',[0.05 0.1 0.425 0.25],'fontsize',14),hold(HH.ax(3),'on'),grid(HH.ax(3),'on'),box(HH.ax(3),'on')
HH.ax(4)=axes;set(HH.ax(4),'units','normalized','position',[0.05 0.7 0.425 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(4),'on'),grid(HH.ax(4),'on'),box(HH.ax(4),'on')
HH.ax(5)=axes;set(HH.ax(5),'units','normalized','position',[0.05 0.4 0.425 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(5),'on'),grid(HH.ax(5),'on'),box(HH.ax(5),'on')
HH.ax(6)=axes;set(HH.ax(6),'units','normalized','position',[0.05 0.1 0.425 0.25],'fontsize',14),hold(HH.ax(6),'on'),grid(HH.ax(6),'on'),box(HH.ax(6),'on')


HH.ax(7)=axes;set(HH.ax(7),'units','normalized','position',[0.53 0.7 0.425 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(7),'on'),grid(HH.ax(7),'on'),box(HH.ax(7),'on')
HH.ax(8)=axes;set(HH.ax(8),'units','normalized','position',[0.53 0.4 0.425 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(8),'on'),grid(HH.ax(8),'on'),box(HH.ax(8),'on')
HH.ax(9)=axes;set(HH.ax(9),'units','normalized','position',[0.53 0.1 0.425 0.25],'fontsize',14),hold(HH.ax(9),'on'),grid(HH.ax(9),'on'),box(HH.ax(9),'on')
HH.ax(10)=axes;set(HH.ax(10),'units','normalized','position',[0.53 0.7 0.425 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(10),'on'),grid(HH.ax(10),'on'),box(HH.ax(10),'on')
HH.ax(11)=axes;set(HH.ax(11),'units','normalized','position',[0.53 0.4 0.425 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(11),'on'),grid(HH.ax(11),'on'),box(HH.ax(11),'on')
HH.ax(12)=axes;set(HH.ax(12),'units','normalized','position',[0.53 0.1 0.425 0.25],'fontsize',14),hold(HH.ax(12),'on'),grid(HH.ax(12),'on'),box(HH.ax(12),'on')



mrksz=8;
for i=1:length(stz)
    
    ts=86400*(dtsA.(char(stz(i))).time-FROM);
    ph(i)=plot(HH.ax(1),ts,dtsA.(char(stz(i))).prs,'.');set(ph(i),'markersize',mrksz)
    bh(i)=plot(HH.ax(2),ts,dtsA.(char(stz(i))).bkz,'.');set(bh(i),'markersize',mrksz)
    vh(i)=plot(HH.ax(3),ts,dtsA.(char(stz(i))).vel,'.');set(vh(i),'markersize',mrksz)
       
    ch(i)=plot(HH.ax(4),ts,dtsA.(char(stz(i))).smb,'.');set(ch(i),'markersize',mrksz)
    rh(i)=plot(HH.ax(5),ts,dtsA.(char(stz(i))).cns,'.');set(rh(i),'markersize',mrksz)
    fh(i)=plot(HH.ax(6),ts,dtsA.(char(stz(i))).fpk,'.');set(fh(i),'markersize',mrksz)
    
    
    ts=86400*(dtsE.(char(stz(i))).time-FROM);
    phe(i)=plot(HH.ax(7),ts,dtsE.(char(stz(i))).prs,'.');set(ph(i),'markersize',mrksz)
    bhe(i)=plot(HH.ax(8),ts,dtsE.(char(stz(i))).bkz,'.');set(bh(i),'markersize',mrksz)
    vhe(i)=plot(HH.ax(9),ts,dtsE.(char(stz(i))).vel,'.');set(vh(i),'markersize',mrksz)
       
    che(i)=plot(HH.ax(10),ts,dtsE.(char(stz(i))).smb,'.');set(ch(i),'markersize',mrksz)
    rhe(i)=plot(HH.ax(11),ts,dtsE.(char(stz(i))).cns,'.');set(rh(i),'markersize',mrksz)
    fhe(i)=plot(HH.ax(12),ts,dtsE.(char(stz(i))).fpk,'.');set(fh(i),'markersize',mrksz)
    
end

legend(HH.ax(1),ph,stz)
legend(HH.ax(4),ch,stz)

legend(HH.ax(7),ph,stz)
legend(HH.ax(10),ch,stz)

grid on
HH.axtrendsG1=hggroup;
HH.axtrendsG2=hggroup;
ylabel(HH.ax(1),'Pa')
ylabel(HH.ax(2),'back-azimuth (?N)')
ylabel(HH.ax(3),'velocity (m/s)')
HH.axtrendsG1=[HH.ax([1:3 7:9]) ph bh vh phe bhe vhe];  % prs, bkz, vel
ylabel(HH.ax(4),'Semblance')
ylabel(HH.ax(5),'connsistency')
ylabel(HH.ax(6),'frequency (Hz)')
HH.axtrendsG2=[HH.ax([4:6 10:12]) ch rh fh che rhe fhe];    % cohe, res, freq

set(HH.axtrendsG2,'visible','off')

HH.TMP=uicontrol('Style', 'popup',...
       'String', 'PRS-BAZ-VEL|COH-CON-FRE',...
       'units','normalized','Position',[.12 .96 .2 .03],...
       'Callback',{@switchparams,HH},...
       'HandleVisibility','on',...
       'backgroundcolor','w','foregroundcolor','k',...
       'TooltipString','Switch parameters',...
       'fontsize',14);


xtk=get(HH.ax(3),'xtick');
set(HH.ax(3),'xtick',xtk,'xticklabel',datestr(FROM+xtk/86400,15))
set(HH.ax(6),'xtick',xtk,'xticklabel',datestr(FROM+xtk/86400,15))
set(HH.ax(9),'xtick',xtk,'xticklabel',datestr(FROM+xtk/86400,15))
set(HH.ax(12),'xtick',xtk,'xticklabel',datestr(FROM+xtk/86400,15))
linkaxes(HH.ax,'x')


zobj=zoom;   
set(zobj,'ActionPostCallback',{@setclim,FROM,HH.ax});
set(zobj,'Enable','on');


function switchparams(h,ev,HH)

switch get(gcbo,'value')
    case 1
        set(HH.axtrendsG2,'visible','off')
        set(HH.axtrendsG1,'visible','on')
    case 2
        set(HH.axtrendsG1,'visible','off')
        set(HH.axtrendsG2,'visible','on')
        
end


function setclim(h,ev,t,ax) 

axon=get(gcf,'currentaxes');
xlim=get(axon,'xlim');

step=round(diff(xlim)/10);

xt=min(xlim):step:max(xlim);
for i=1:length(ax)
    ylm=get(ax(i),'ylim');dylm=ylm(2)-ylm(1);
    set(ax(i),'xtick',xt,'xticklabel','','xlim',xlim,...
        'ytick',[mean(ylm)-dylm/4 mean(ylm) mean(ylm)+dylm/4])
    if i==3 || i==6 || i==9 || i==12
        set(ax(i),'xtick',xt,'xticklabel',datestr(t(1)+xt/86400,13))
    end
end

return
% % 
% % 
