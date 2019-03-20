function iad_merge_ida_evts
global FROM dtsA evsA
% clear all
close all


wpath='http://148.251.122.130/DETECTIONS/';
FROM=input('FROM (yyyy-mm-dd_HH)','s');
TO=input('TO (yyyy-mm-dd_HH)','s');
FROM=datenum(FROM,'yyyy-mm-dd_HH');
T0=datenum(TO,'yyyy-mm-dd_HH');
nownames=FROM:1/24:T0;
nfile=length(nownames);
% stz={'rp1','no1','no2','no3','fru','gm2','gms','prt'};
% stz={'gm2','gms','gtn'};
stz={'hrm'};

nstz=length(stz);

DT=2.51;
L=20;


for istz=1:nstz
    DTS.(char(stz(istz)))=[]; 
    if nfile>0

        for i=1:nfile
            filename=[char(stz(istz)),'_',datestr(nownames(i),'yyyymmdd_HHMMSS'),'.csv'];
            fileA=[wpath,char(stz(istz)),'_Det_Av/',char(stz(istz)),'_',datestr(nownames(i),'yyyymmdd'),'/',...
                filename];
            disp(fileA)
            try
                urlwrite(fileA,'pippo.csv');
                dataA=textread('pippo.csv');
                for icu=1:size(dataA,2)
                    eval(['VarName',num2str(icu),'=dataA(:,',num2str(icu),');'])
                end
                [tx,j]=unique(VarName1);
                tt=tx;
                
                [~,~,dts,~]=iad_detections2events(DT,L,tt',VarName2(j),VarName7(j),VarName3(j),VarName5(j),VarName9(j),VarName8(j),VarName10(j),.5);
                    
                DTS.(char(stz(istz)))=cat(2,DTS.(char(stz(istz))),dts);
                
            catch
                disp(['...file not founded'])
                
            end
                     
        end
        
    end
%      
    dtsA.(char(stz(istz))).time=DTS.(char(stz(istz)))(1,:);
    dtsA.(char(stz(istz))).prs=DTS.(char(stz(istz)))(2,:);
    dtsA.(char(stz(istz))).bkz=DTS.(char(stz(istz)))(4,:);
    dtsA.(char(stz(istz))).vel=DTS.(char(stz(istz)))(6,:);
    dtsA.(char(stz(istz))).smb=DTS.(char(stz(istz)))(7,:);
    dtsA.(char(stz(istz))).cns=DTS.(char(stz(istz)))(3,:);
    dtsA.(char(stz(istz))).fpk=DTS.(char(stz(istz)))(5,:);
 
end
% dtsA.hrm

working_dir=pwd;
slh='/';
net='wyssen';

%%
DT=2.51;L=40;
for istz=1:nstz   
    [~,~,~,eVts]=iad_detections2events(DT,L,dtsA.(char(stz(istz))).time,...
        dtsA.(char(stz(istz))).prs',...
        dtsA.(char(stz(istz))).smb',...
        dtsA.(char(stz(istz))).bkz',...
        dtsA.(char(stz(istz))).vel',...
        dtsA.(char(stz(istz))).cns',...
        dtsA.(char(stz(istz))).fpk',...
        zeros(size(dtsA.(char(stz(istz))).fpk)),...
        .5);
    
    evsA.(char(stz(istz)))=eVts;
    
    if evsA.(char(stz(istz))).data(1,1)~=0
        
    
        ConfFileName=['conf_',char(stz(istz)),'_2018_tst.txt'];
        station=iad_read_ascii2cell([working_dir,slh,'conf_files',slh,net,slh,ConfFileName]);

        iprobabilistic=find(evsA.(char(stz(istz))).data(:,3) > station.nav_mindur(1) & ...    %... Duration
            evsA.(char(stz(istz))).data(:,6) > station.nav_minpressure(1) & ...               %... Amplitude
            evsA.(char(stz(istz))).data(:,11) < station.nav_maxvel(1) & ...                   %... App. Vel.
            evsA.(char(stz(istz))).data(:,19) < station.nav_maxveltrend(1) & ...                                        %... App. Vel. "trend"
            evsA.(char(stz(istz))).data(:,10) < station.nav_meanvel(1) & ...                  %... App. Vel.
            evsA.(char(stz(istz))).data(:,10) > station.nav_minvel(1) & ...
            abs(evsA.(char(stz(istz))).data(:,21)-evsA.(char(stz(istz))).data(:,20)) < station.nav_maxbazstd(1));                       %... App. Vel.         

        if ~isempty(iprobabilistic)
        %... Associao probabilit 50% (low probability) a tutti gli eventi
            evsA.(char(stz(istz))).data=evsA.(char(stz(istz))).data(iprobabilistic,:);
            evsA.(char(stz(istz))).data(:,17)=.5*ones(1,length(iprobabilistic));

            ideterministic=find(evsA.(char(stz(istz))).data(:,3)>station.nav_mindur(2) & ...    %... Duration
                evsA.(char(stz(istz))).data(:,6)>station.nav_minpressure(2) & ...               %... Amplitude
                evsA.(char(stz(istz))).data(:,11)<station.nav_maxvel(2) & ...                   %... App. Vel.
                evsA.(char(stz(istz))).data(:,19)<station.nav_maxveltrend(2) & ...                                      %... App. Vel. "trend"
                evsA.(char(stz(istz))).data(:,10)<station.nav_meanvel(2) & ...                  %... App. Vel.
                evsA.(char(stz(istz))).data(:,10)>station.nav_minvel(2) & ...
                abs(evsA.(char(stz(istz))).data(:,21)-evsA.(char(stz(istz))).data(:,20)) < station.nav_maxbazstd(2) | ... %... App. Vel.
                (evsA.(char(stz(istz))).data(:,3)>100 & evsA.(char(stz(istz))).data(:,6)>.8));  % se dura pi?? di 100s e la pressione supera 0.2                     

            if ~isempty(ideterministic)
            %... Associao probabili 100% (high probability) a gli eventi sopra la seconda soglia
                evsA.(char(stz(istz))).data(ideterministic,17)=ones(1,length(ideterministic));
            end
        end
    end
    
    evsA.(char(stz(istz)))=rmfield(evsA.(char(stz(istz))),'legend');
    
%     evsMr.(char(stz(istz))) = structfun(@(x) ( x(iprobabilistic,:) ), evsA.(char(stz(istz))), 'UniformOutput', false);
%     evsHr.(char(stz(istz))) = structfun(@(x) ( x(ideterministic,:) ), evsA.(char(stz(istz))), 'UniformOutput', false);
    
    
end
% [detections,EVENTS,dts,evts]=iad_detections2events(DT,L,txx,prs,cc,azz,slw,rs,Fp,iexp,shift)
% dts=vertcat(txx,prs',rs',azz',Fp',slw',cc');

%%

F1=figure;set(F1,'Color','w','pos',[15 40 1400 770])

tit=annotation('textbox',[.4 .96 .4 .025],'String',...
    ['IDA Detections & Alerts from ',datestr(FROM,'mmm-dd-yyyy HH'),' to ',datestr(T0,'mmm-dd-yyyy HH')]);
set(tit,'HorizontalAlignment','center','FontSize',16,'LineStyle','none')
HH.ax(1)=axes;set(HH.ax(1),'units','normalized','position',[0.05 0.7 0.9 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(1),'on'),grid(HH.ax(1),'on'),box(HH.ax(1),'on')
HH.ax(2)=axes;set(HH.ax(2),'units','normalized','position',[0.05 0.4 0.9 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(2),'on'),grid(HH.ax(2),'on'),box(HH.ax(2),'on')
HH.ax(3)=axes;set(HH.ax(3),'units','normalized','position',[0.05 0.1 0.9 0.25],'fontsize',14),hold(HH.ax(3),'on'),grid(HH.ax(3),'on'),box(HH.ax(3),'on')
HH.ax(4)=axes;set(HH.ax(4),'units','normalized','position',[0.05 0.7 0.9 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(4),'on'),grid(HH.ax(4),'on'),box(HH.ax(4),'on')
HH.ax(5)=axes;set(HH.ax(5),'units','normalized','position',[0.05 0.4 0.9 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(5),'on'),grid(HH.ax(5),'on'),box(HH.ax(5),'on')
HH.ax(6)=axes;set(HH.ax(6),'units','normalized','position',[0.05 0.1 0.9 0.25],'fontsize',14),hold(HH.ax(6),'on'),grid(HH.ax(6),'on'),box(HH.ax(6),'on')
% hold(HH.ax,'on')
% 
% % HH.ax(7)=axes;set(HH.ax(7),'units','normalized','position',[0.53 0.7 0.425 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(7),'on'),grid(HH.ax(7),'on'),box(HH.ax(7),'on')
% % HH.ax(8)=axes;set(HH.ax(8),'units','normalized','position',[0.53 0.4 0.425 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(8),'on'),grid(HH.ax(8),'on'),box(HH.ax(8),'on')
% % HH.ax(9)=axes;set(HH.ax(9),'units','normalized','position',[0.53 0.1 0.425 0.25],'fontsize',14),hold(HH.ax(9),'on'),grid(HH.ax(9),'on'),box(HH.ax(9),'on')
% % HH.ax(10)=axes;set(HH.ax(10),'units','normalized','position',[0.53 0.7 0.425 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(10),'on'),grid(HH.ax(10),'on'),box(HH.ax(10),'on')
% % HH.ax(11)=axes;set(HH.ax(11),'units','normalized','position',[0.53 0.4 0.425 0.25],'fontsize',14,'xticklabel',''),hold(HH.ax(11),'on'),grid(HH.ax(11),'on'),box(HH.ax(11),'on')
% % HH.ax(12)=axes;set(HH.ax(12),'units','normalized','position',[0.53 0.1 0.425 0.25],'fontsize',14),hold(HH.ax(12),'on'),grid(HH.ax(12),'on'),box(HH.ax(12),'on')
% 
mrksz=8;
phH=[];phM=[];chM=[];chH=[];
for i=1:length(stz)  
    ts=86400*(dtsA.(char(stz(i))).time-FROM);
    ph(i)=plot(HH.ax(1),ts,dtsA.(char(stz(i))).prs,'.');set(ph(i),'markersize',mrksz),
    if evsA.(char(stz(istz))).data(1,1)~=0
        id=evsA.(char(stz(istz))).data(:,17)==1;
        ip=evsA.(char(stz(istz))).data(:,17)==0.5;
        if sum(ip)>0
            tsEm=86400*(evsA.(char(stz(istz))).data(ip,1)-FROM);
            phM(i)=plot(HH.ax(1),tsEm,evsA.(char(stz(istz))).data(ip,6),'^k');
            set(phM(i),'markersize',mrksz,'markerfacecolor','g')
        end
        if sum(id)>0
            tsEh=86400*(evsA.(char(stz(istz))).data(id,1)-FROM);
            phH(i)=plot(HH.ax(1),tsEh,evsA.(char(stz(istz))).data(id,6),'^k');
            set(phH(i),'markersize',mrksz,'markerfacecolor','r')  
        end
    end
    
    bh(i)=plot(HH.ax(2),ts,dtsA.(char(stz(i))).bkz,'.');set(bh(i),'markersize',mrksz)
    vh(i)=plot(HH.ax(3),ts,dtsA.(char(stz(i))).vel,'.');set(vh(i),'markersize',mrksz)
       
    ch(i)=plot(HH.ax(4),ts,dtsA.(char(stz(i))).smb,'.');set(ch(i),'markersize',mrksz),
    if evsA.(char(stz(istz))).data(1,1)~=0
        if sum(ip)>0
            chM(i)=plot(HH.ax(4),tsEm,evsA.(char(stz(istz))).data(ip,4),'^k');
            set(chM(i),'markersize',mrksz,'markerfacecolor','g')
        end
        if sum(id)>0
            chH(i)=plot(HH.ax(4),tsEh,evsA.(char(stz(istz))).data(id,4),'^k');
            set(chH(i),'markersize',mrksz,'markerfacecolor','r')
        end
    end
    rh(i)=plot(HH.ax(5),ts,dtsA.(char(stz(i))).cns,'.');
    set(rh(i),'markersize',mrksz)
    fh(i)=plot(HH.ax(6),ts,dtsA.(char(stz(i))).fpk,'.');
    set(fh(i),'markersize',mrksz)
end
% 
legend(HH.ax(1),ph,stz)
legend(HH.ax(4),ch,stz)
% 
% legend(HH.ax(7),ph,stz)
% legend(HH.ax(10),ch,stz)
% 
grid on
HH.axtrendsG1=hggroup;
HH.axtrendsG2=hggroup;
ylabel(HH.ax(1),'Pa')
ylabel(HH.ax(2),'back-azimuth (?N)')
ylabel(HH.ax(3),'velocity (m/s)')
HH.axtrendsG1=[HH.ax([1:3]) ph phM phH bh vh];  % prs, bkz, vel
ylabel(HH.ax(4),'Semblance')
ylabel(HH.ax(5),'connsistency')
ylabel(HH.ax(6),'frequency (Hz)')
HH.axtrendsG2=[HH.ax([4:6]) ch chM chH rh fh];    % cohe, res, freq
% 
set(HH.axtrendsG2,'visible','off')
% 
HH.TMP=uicontrol('Style', 'popup',...
       'String', 'PRS-BAZ-VEL|COH-CON-FRE',...
       'units','normalized','Position',[.12 .96 .2 .03],...
       'Callback',{@switchparams,HH},...
       'HandleVisibility','on',...
       'backgroundcolor','w','foregroundcolor','k',...
       'TooltipString','Switch parameters',...
       'fontsize',14);
% 
% 
xtk=get(HH.ax(3),'xtick');
set(HH.ax(3),'xtick',xtk,'xticklabel',datestr(FROM+xtk/86400,15))
set(HH.ax(6),'xtick',xtk,'xticklabel',datestr(FROM+xtk/86400,15))
% set(HH.ax(9),'xtick',xtk,'xticklabel',datestr(FROM+xtk/86400,15))
% set(HH.ax(12),'xtick',xtk,'xticklabel',datestr(FROM+xtk/86400,15))
linkaxes(HH.ax,'x')
% 
% 
zobj=zoom;   
set(zobj,'ActionPostCallback',{@setclim,FROM,HH.ax});
set(zobj,'Enable','on');
% 
% 
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
dtday=(xlim(2)-xlim(1))/86400;
if dtday>4
    dtklabel=6;
else
    dtklabel=13;
end
    
    

step=round(diff(xlim)/10);

xt=min(xlim):step:max(xlim);
for i=1:length(ax)
    ylm=get(ax(i),'ylim');dylm=ylm(2)-ylm(1);
    set(ax(i),'xtick',xt,'xticklabel','','xlim',xlim,...
        'ytick',[mean(ylm)-dylm/4 mean(ylm) mean(ylm)+dylm/4])
    if i==3 || i==6 || i==9 || i==12
        set(ax(i),'xtick',xt,'xticklabel',datestr(t(1)+xt/86400,dtklabel))
    end
end

return
% % 
% % 
