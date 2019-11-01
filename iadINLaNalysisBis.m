clear all,close all

first = datenum(2018,12,01);
last = datenum(2019,6,1);
period=15/1440;
bins = period*(floor(first/period):ceil(last/period));
Te=bins(1:end)';

% DT=1.51;L=10;

% Grasdalen
a=load('IDAStatusNO120182019v2.mat');a.iNl=a.iNl';
j=a.tT<datenum(2018,12,7);a.tT(j)=[];a.iNl(:,j)=[];
no1=load('/Users/giacomo/Google Drive/GeCo/Projects/WYSSEN/IDA_Design/IDA-BC-Tender/PerformanceAnalysis/ida_Grasdalen_2018-2019.mat');
% 02-Feb-2019 02:10:52 - 05-Feb-2019 19:29:36  % spikes
tMe=no1.eVts.data(:,1);
E=no1.eVts.data(:,6).*no1.eVts.data(:,3);
pRs=no1.eVts.data(:,6);
% j=tMe<datenum(2018,12,7);
% E(j)=[];pRs(j)=[];tMe(j)=[];
% j=tMe>datenum(2019,2,2) & tMe<datenum(2019,2,6);
% E(j)=[];pRs(j)=[];tMe(j)=[];
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(a.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;

Ea = accumarray(loci,E,size(Te),@nansum,0);
Pa = accumarray(loci,pRs,size(Te),@nanmean,NaN);
Inl=[];
for i=1:size(a.iNl,1)
    Inl(i,:) = accumarray(locii',a.iNl(i,:),size(Te),@nanmedian,NaN);
end
no1.Time=Te;
no1.AcouticEnergy=Ea;
no1.DetectionRate=Ni;
no1.AcouticPressure=Pa;
no1.InfrasonicNoiseLevel=Inl;

% Indreesdalen
a=load('IDAStatusNO220182019v2.mat');a.iNl=a.iNl';
j=a.tT<datenum(2018,12,7);a.tT(j)=[];a.iNl(:,j)=[];
no2=load('/Users/giacomo/Google Drive/GeCo/Projects/WYSSEN/IDA_Design/IDA-BC-Tender/PerformanceAnalysis/ida_Indreesdalen_2018-2019.mat');
tMe=no2.eVts.data(:,1);
E=no2.eVts.data(:,6).*no2.eVts.data(:,3);
pRs=no2.eVts.data(:,6);
% j=tMe<datenum(2018,12,6);
% E(j)=[];pRs(j)=[];tMe(j)=[];
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(a.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;

Ea = accumarray(loci,E,size(Te),@nansum,0);
Pa = accumarray(loci,pRs,size(Te),@nanmean,NaN);
Inl=[];
for i=1:size(a.iNl,1)
    Inl(i,:) = accumarray(locii',a.iNl(i,:),size(Te),@nanmedian,NaN);
end
no2.Time=Te;
no2.AcouticEnergy=Ea;
no2.DetectionRate=Ni;
no2.AcouticPressure=Pa;
no2.InfrasonicNoiseLevel=Inl;


% Lavangsdalen
a=load('IDAStatusLVN20182019v2.mat');a.iNl=a.iNl';
j=a.tT<datenum(2018,12,7);a.tT(j)=[];a.iNl(:,j)=[];
lvn=load('/Users/giacomo/Google Drive/GeCo/Projects/WYSSEN/IDA_Design/IDA-BC-Tender/PerformanceAnalysis/ida_Lavangsdalen_2018-2019.mat');
tMe=lvn.eVts.data(:,1);
E=5*lvn.eVts.data(:,6).*lvn.eVts.data(:,3);
pRs=5*lvn.eVts.data(:,6);
% j=tMe<datenum(2018,12,6);
% E(j)=[];pRs(j)=[];tMe(j)=[];
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(a.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;

Ea = accumarray(loci,E,size(Te),@nansum,0);
Pa = accumarray(loci,pRs,size(Te),@nanmean,NaN);
Inl=[];
for i=1:size(a.iNl,1)
    Inl(i,:) = accumarray(locii',a.iNl(i,:),size(Te),@nanmedian,NaN);
end
lvn.Time=Te;
lvn.AcouticEnergy=Ea;
lvn.DetectionRate=Ni;
lvn.AcouticPressure=Pa;
lvn.InfrasonicNoiseLevel=Inl;



% Blitzingen
a=load('IDAStatusGMS20182019.mat');a.iNl=a.iNl';
j=a.tT<datenum(2018,12,7);a.tT(j)=[];a.iNl(:,j)=[];
gms=load('/Users/giacomo/Google Drive/GeCo/Projects/WYSSEN/IDA_Design/IDA-BC-Tender/PerformanceAnalysis/ida_Blitzingen_2018-2019.mat');
tMe=gms.eVts.data(:,1);
E=5*gms.eVts.data(:,6).*gms.eVts.data(:,3);
pRs=5*gms.eVts.data(:,6);
% j=tMe<datenum(2018,12,6);
% E(j)=[];pRs(j)=[];tMe(j)=[];
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(a.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;

Ea = accumarray(loci,E,size(Te),@nansum,0);
Pa = accumarray(loci,pRs,size(Te),@nanmean,NaN);
Inl=[];
for i=1:size(a.iNl,1)
    Inl(i,:) = accumarray(locii',a.iNl(i,:),size(Te),@nanmedian,NaN);
end
gms.Time=Te;
gms.AcouticEnergy=Ea;
gms.DetectionRate=Ni;
gms.AcouticPressure=Pa;
gms.InfrasonicNoiseLevel=Inl;

% Reckingen
a=load('IDAStatusGM220182019.mat');a.iNl=a.iNl';
j=a.tT<datenum(2018,12,7);a.tT(j)=[];a.iNl(:,j)=[];
gm2=load('/Users/giacomo/Google Drive/GeCo/Projects/WYSSEN/IDA_Design/IDA-BC-Tender/PerformanceAnalysis/ida_Reckingen_2018-2019.mat');
tMe=gm2.eVts.data(:,1);
E=5*gm2.eVts.data(:,6).*gm2.eVts.data(:,3);
pRs=5*gm2.eVts.data(:,6);
% j=tMe<datenum(2018,12,6);
% E(j)=[];pRs(j)=[];tMe(j)=[];
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(a.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;

Ea = accumarray(loci,E,size(Te),@nansum,0);
Pa = accumarray(loci,pRs,size(Te),@nanmean,NaN);
Inl=[];
for i=1:size(a.iNl,1)
    Inl(i,:) = accumarray(locii',a.iNl(i,:),size(Te),@nanmedian,NaN);
end
gm2.Time=Te;
gm2.AcouticEnergy=Ea;
gm2.DetectionRate=Ni;
gm2.AcouticPressure=Pa;
gm2.InfrasonicNoiseLevel=Inl;



% Quinto
a=load('IDAStatusPRT20182019.mat');a.iNl=a.iNl';
% j=a.tT<datenum(2018,12,7);a.tT(j)=[];a.iNl(:,j)=[];
prt=load('/Users/giacomo/Google Drive/GeCo/Projects/WYSSEN/IDA_Design/IDA-BC-Tender/PerformanceAnalysis/ida_Quinto_2018-2019.mat');
tMe=prt.eVts.data(:,1);
E=prt.eVts.data(:,6).*prt.eVts.data(:,3);
pRs=prt.eVts.data(:,6);
% j=tMe<datenum(2018,12,6);
% E(j)=[];pRs(j)=[];tMe(j)=[];
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(a.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;

Ea = accumarray(loci,E,size(Te),@nansum,0);
Pa = accumarray(loci,pRs,size(Te),@nanmean,NaN);
Inl=[];
for i=1:size(a.iNl,1)
    Inl(i,:) = accumarray(locii',a.iNl(i,:),size(Te),@nanmedian,NaN);
end
prt.Time=Te;
prt.AcouticEnergy=Ea;
prt.DetectionRate=Ni;
prt.AcouticPressure=Pa;
prt.InfrasonicNoiseLevel=Inl;


% Guttannen
a=load('IDAStatusGTN20182019.mat');a.iNl=a.iNl';
j=a.tT<datenum(2018,12,7);a.tT(j)=[];a.iNl(:,j)=[];
gtn=load('/Users/giacomo/Google Drive/GeCo/Projects/WYSSEN/IDA_Design/IDA-BC-Tender/PerformanceAnalysis/ida_Guttannen_2018-2019.mat');
tMe=gtn.eVts.data(:,1);
E=5*gtn.eVts.data(:,6).*gtn.eVts.data(:,3);
pRs=5*gtn.eVts.data(:,6);
% j=tMe<datenum(2018,12,6);
% E(j)=[];pRs(j)=[];tMe(j)=[];
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(a.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;

Ea = accumarray(loci,E,size(Te),@nansum,0);
Pa = accumarray(loci,pRs,size(Te),@nanmean,NaN);
Inl=[];
for i=1:size(a.iNl,1)
    Inl(i,:) = accumarray(locii',a.iNl(i,:),size(Te),@nanmedian,NaN);
end
gtn.Time=Te;
gtn.AcouticEnergy=Ea;
gtn.DetectionRate=Ni;
gtn.AcouticPressure=Pa;
gtn.InfrasonicNoiseLevel=Inl;




% Ross Peak
a=load('IDAStatusRSP20182019v2.mat');a.iNl=a.iNl';
j=a.tT<datenum(2018,12,7);a.tT(j)=[];a.iNl(:,j)=[];
rsp=load('/Users/giacomo/Google Drive/GeCo/Projects/WYSSEN/IDA_Design/IDA-BC-Tender/PerformanceAnalysis/ida_RossPeak_2018-2019.mat');
tMe=rsp.eVts.data(:,1);
E=5*rsp.eVts.data(:,6).*rsp.eVts.data(:,3);
pRs=5*rsp.eVts.data(:,6);
j=tMe<datenum(2018,12,6);
E(j)=[];pRs(j)=[];tMe(j)=[];
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(a.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;

Ea = accumarray(loci,E,size(Te),@nansum,0);
Pa = accumarray(loci,pRs,size(Te),@nanmean,NaN);
Inl=[];
for i=1:size(a.iNl,1)
    Inl(i,:) = accumarray(locii',a.iNl(i,:),size(Te),@nanmedian,NaN);
end
rsp.Time=Te;
rsp.AcouticEnergy=Ea;
rsp.DetectionRate=Ni;
rsp.AcouticPressure=Pa;
rsp.InfrasonicNoiseLevel=Inl;


% Loop Brook
a=load('IDAStatusLPB20182019v2.mat');a.iNl=a.iNl';
j=a.tT<datenum(2018,12,7);a.tT(j)=[];a.iNl(:,j)=[];
lpb=load('/Users/giacomo/Google Drive/GeCo/Projects/WYSSEN/IDA_Design/IDA-BC-Tender/PerformanceAnalysis/ida_LoopBrook_2018-2019.mat');
% 02-Feb-2019 02:10:52 - 05-Feb-2019 19:29:36  % spikes
tMe=lpb.eVts.data(:,1);
E=5*lpb.eVts.data(:,6).*lpb.eVts.data(:,3);
pRs=5*lpb.eVts.data(:,6);
j=tMe<datenum(2018,12,7);
E(j)=[];pRs(j)=[];tMe(j)=[];
j=tMe>datenum(2019,2,2) & tMe<datenum(2019,2,6);
E(j)=[];pRs(j)=[];tMe(j)=[];
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(a.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;

Ea = accumarray(loci,E,size(Te),@nansum,0);
Pa = accumarray(loci,pRs,size(Te),@nanmean,NaN);
Inl=[];
for i=1:size(a.iNl,1)
    Inl(i,:) = accumarray(locii',a.iNl(i,:),size(Te),@nanmedian,NaN);
end
lpb.Time=Te;
lpb.AcouticEnergy=Ea;
lpb.DetectionRate=Ni;
lpb.AcouticPressure=Pa;
lpb.InfrasonicNoiseLevel=Inl;



% Hermit
a=load('IDAStatusHRM20182019.mat');a.iNl=a.iNl';
j=a.tT<datenum(2018,12,7);a.tT(j)=[];a.iNl(:,j)=[];
hrm=load('/Users/giacomo/Google Drive/GeCo/Projects/WYSSEN/IDA_Design/IDA-BC-Tender/PerformanceAnalysis/ida_Hermit_2018-2019.mat');
% 02-Feb-2019 02:10:52 - 05-Feb-2019 19:29:36  % spikes
tMe=hrm.eVts.data(:,1);
E=5*hrm.eVts.data(:,6).*hrm.eVts.data(:,3);
pRs=5*hrm.eVts.data(:,6);
j=tMe<datenum(2018,12,7);
E(j)=[];pRs(j)=[];tMe(j)=[];
% j=tMe>datenum(2019,2,2) & tMe<datenum(2019,2,6);
% E(j)=[];pRs(j)=[];tMe(j)=[];
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(a.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;

Ea = accumarray(loci,E,size(Te),@nansum,0);
Pa = accumarray(loci,pRs,size(Te),@nanmean,NaN);
Inl=[];
for i=1:size(a.iNl,1)
    Inl(i,:) = accumarray(locii',a.iNl(i,:),size(Te),@nanmedian,NaN);
end
hrm.Time=Te;
hrm.AcouticEnergy=Ea;
hrm.DetectionRate=Ni;
hrm.AcouticPressure=Pa;
hrm.InfrasonicNoiseLevel=Inl;







alerts=load('IDAsAlerts2018-2019');
ids={'no1', 'no2','lvn', ...
    'gtn','gm2','gms','prt',...
    'rsp','lpb','hrm'};
sitename={'Grasdalen','Indreesdalen','Lavangsdalen',...
    'Guttannen','Reckingen','Blitzingen','Quinto',...
    'Ross Peak','Loop Brook', 'Hermit'};

% ids={'no1','no2','lvn',...
%     'gms','gm2','prt','gtn',...
%     'rsp','lpb','hrm'};
% sitename={'Grasdalen','Indreesdalen','Lavangsdalen',...
%     'Blitzingen','Reckingen','Quinto','Guttannen',...
%     'Ross Peak','Loop Brook','Hermit'};

dBalerts=[];

return


%%
iT1=15;
iT2=25;
clear sts
pp=4;

for i=1:length(ids)
    tinl = eval([char(ids(i)),'.Time']);
    inl=eval(['nanmedian(',char(ids(i)),'.InfrasonicNoiseLevel)']);
    
    
    nv=length(inl);
%     sts(1:3)=0;
    sts=zeros(1,nv);
    for ii=pp:nv
        t4=tinl(ii-pp+1:ii);
        i4=inl(ii-pp+1:ii);
        
        j1=find(i4>iT1);
        j2=find(i4>iT2);
        if length(j1)>=pp
            sts(ii)=1;
        end
        if length(j2)>=pp
            sts(ii)=2;
        end
       
        
        
    end
    
    status.(char(ids(i))).time=tinl;
    status.(char(ids(i))).value=sts;
   
    
end
%% Status over time 
f1=figure;set(f1,'pos',[5 70 710 735],'color','w')
for i=1:length(ids)
    aaz=status.(char(ids(i))).value;
    time=status.(char(ids(i))).time;
%     time=datenum(alerts.T.(char(ids(i))));
%     dB=[];
%     for ii=1:length(time)
%         j=find(eval([char(ids(i)),'.Time>time(ii)']));
%         eval([char(ids(i)),'.INLonNavAlerts(ii)=aaz(j(1))']);
%         dB=cat(1,dB,aaz(j(1)));
%     end
%     
%     dBalerts=cat(1,dBalerts,dB);
    j0=aaz==0;
    j1=aaz==1;
    j2=aaz==2;
    ax(i)=subplot(length(ids),1,i);
    p=plot(time(j0),aaz(j0),'ok');grid on,hold on
    set(p,'markerfacecolor','g','markeredgecolor','none','markersize',4)
    p=plot(time(j1),aaz(j1),'ok');grid on
    set(p,'markerfacecolor',[1 180/255 10/255],'markeredgecolor','none','markersize',4)
    p=plot(time(j2),aaz(j2),'ok');grid on
    set(p,'markerfacecolor','r','markeredgecolor','none','markersize',4)
    datetick('x',12,'keeplimits'),set(ax(i),'xticklabel','')
    
%     legend(char(sitename(i)))
%     p=plot(datenum(alerts.T.(char(ids(i)))),dB,'ok');
%     set(p,'markerfacecolor','r','markersize',5)
end
set(ax,'ylim',[0 2],'fontsize',14)
linkaxes(ax,'xy') 
datetick('x',12,'keeplimits')

%% INL over time 
f1=figure;set(f1,'pos',[5 70 710 735],'color','w')
for i=1:length(ids)
    aaz=eval(['nanmedian(',char(ids(i)),'.InfrasonicNoiseLevel)']);
    
    time=datenum(alerts.T.(char(ids(i))));
    dB=[];
    for ii=1:length(time)
        j=find(eval([char(ids(i)),'.Time>time(ii)']));
        eval([char(ids(i)),'.INLonNavAlerts(ii)=aaz(j(1))']);
        dB=cat(1,dB,aaz(j(1)));
    end
    
    dBalerts=cat(1,dBalerts,dB);
    ax(i)=subplot(length(ids),1,i);plot(eval([char(ids(i)),'.Time']),aaz,'.-k');grid on,hold on
    datetick('x',12,'keeplimits'),set(ax(i),'xticklabel','')
%     legend(char(sitename(i)))
    p=plot(datenum(alerts.T.(char(ids(i)))),dB,'ok');
    set(p,'markerfacecolor','r','markersize',5)
end
set(ax,'ylim',[-5 70],'fontsize',14)
linkaxes(ax,'xy') 
datetick('x',12,'keeplimits')

%% 
rng=-5:2:70;

for ii=1:length(sitename)
    
    eval([char(ids(ii)),'.nDsh=[]'])
    ll=eval(['nanmedian(',char(ids(ii)),'.InfrasonicNoiseLevel)']);
%     tt=eval(['nanmedian(',char(ids(ii)),'.Time)']);
    dd=eval([char(ids(ii)),'.DetectionRate']);
%     dd=eval([char(ids(ii)),'.AcouticEnergy']);
    
    
    for i=1:length(rng)-1
    
        j=find(ll>=rng(i) & ll<rng(i+1));
        if isempty(j)
            eval([char(ids(ii)),'.nDsh(i)=0;']);
        else
            eval([char(ids(ii)),'.nDsh(i)=nansum(dd(j));']);
        end
    end
        
end

psiz=6;
clr=colormap(jet);
clr=clr(1:floor(size(clr,1)/length(ids)):end,:);
figure
for i=1:length(ids)
    p=semilogy(rng(1:end-1),(eval([char(ids(i)),'.nDsh'])),'ok');
    set(p,'markerfacecolor',clr(i,:),'markersize',psiz),hold on
end

legend(sitename)

[NN,BB]=hist(dBalerts,rng);
pp=bar(rng,(NN));set(pp,'FaceAlpha',.2)

set(gca,'FontSize',14,'xlim',[rng(1) rng(end-1)])
set(gcf,'Color','w')
xlabel('INL (dB rel to GLW)')
ylabel('#')
grid
axis square

%% % INL above 25 dB
oPrn=[];
sS=[];

psiz=6;
clr=colormap(jet);
clr=clr(1:floor(size(clr,1)/length(ids)):end,:);
% figure;set(gcf,'color','w')
% ax(1)=subplot(311);hold(ax(1),'on'),grid(ax(1),'on')
% ax(2)=subplot(312);hold(ax(2),'on'),grid(ax(2),'on')
% ax(3)=subplot(313);hold(ax(3),'on'),grid(ax(3),'on')

for i=1:length(ids)    
    ll=eval(['nanmedian(',char(ids(i)),'.InfrasonicNoiseLevel)']);
    ss=eval([char(ids(i)),'.AcouticEnergy']);
    ss(ss<=0)=NaN;ss=20*log10(ss);
    
    [qq,ww]=hist(ss,-30:2:50);
%     
%     if i<4
%         p=plot(ax(1),0:2:150,qq,'o-');
%         set(p,'markerfacecolor',clr(i,:),'markeredgecolor','k','color',clr(i,:),'markersize',psiz)
%     end
%     if i>=4 && i<8
%         p=plot(ax(2),0:2:150,qq,'o-');
%         set(p,'markerfacecolor',clr(i,:),'markeredgecolor','k','color',clr(i,:),'markersize',psiz)
%     end
%     if i>=8
%         p=plot(ax(3),0:2:150,qq,'o-');
%         set(p,'markerfacecolor',clr(i,:),'markeredgecolor','k','color',clr(i,:),'markersize',psiz)
%     end
    sS=cat(1,sS,qq);
    
    j=ll>25 & isnan(ss);
    oPrn=cat(1,oPrn,100*sum(j)/length(ll));       
end
% legend(ax(1),sitename(1:3))
% legend(ax(2),sitename(4:7))
% legend(ax(3),sitename(8:10))

% set(ax,'FontSize',14,'xlim',[70 150],'Box','on')
% linkaxes(ax,'xy') 

%% ISL over time 
erg=-30:2:50;
f2=figure;set(f2,'pos',[750 70 710 735],'color','w')
iSl=[];
aiSl=[];
for i=1:length(ids)
    a1=eval([char(ids(i)),'.AcouticEnergy']);
    a1(a1<=0)=NaN;a1=20*log10(a1);
    a2=eval(['nanmedian(',char(ids(i)),'.InfrasonicNoiseLevel)']);
    
    jj=find(a2>15);
    a3=a1;a3(jj)=[];
    
    [kk,cc]=hist(a3,erg);
    iSl=cat(1,iSl,kk);
    
    
    jj=a2<10;
    aiSl=cat(1,aiSl,nansum(a1(jj)));
    

    ax(i)=subplot(length(ids),1,i);plot(eval([char(ids(i)),'.Time']),a1,'.k');grid on,hold on
    datetick('x',12,'keeplimits'),set(ax(i),'xticklabel','')
    
%     j1=a2<15 & a2>0;
%     j2=a1<80 & a1>0;
%     jj=find((j1+j2)==2);
%     p=plot(eval([char(ids(i)),'.Time(jj)']),a1(jj),'ok');
%     set(p,'markerfacecolor','r','markersize',5)
%     legend(char(sitename(i)))
%     stem(datenum(alerts.T.(char(ids(i)))),70+zeros(size(alerts.T.(char(ids(i))),1)),'r')
end
set(ax,'fontsize',14,'ylim',[-30 50])
% linkaxes(ax,'xy')
% datetick('x',12,'keeplimits')


%% scenarios 





