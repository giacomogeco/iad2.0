clear all,close all

first = datenum(2018,12,01);
last = datenum(2019,4,30);
period=15/1440;
bins = period*(floor(first/period):ceil(last/period));
Te=bins(1:end)';


first2 = datenum(2017,12,01);
last2 = datenum(2018,4,30);
% period=15/1440;
bins2 = period*(floor(first2/period):ceil(last2/period));
Te2=bins2(1:end)';

DT=1.51;L=10;


rp2=load('IDAStatusRP220172018v2.mat');
rp2.iNl=rp2.iNl';rp2.pRs=rp2.pRs';
[tMe,pRs,E]=iad_DtsGrouping(DT,L,rp2.tTd,rp2.pRs);
[Ni, loci] = histc(tMe, bins2); %... loc Nx1
[Nii, locii] = histc(rp2.tT', bins2); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;
Ea=[];Pa=[];Inl=[];
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te2),@nansum,0);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te2),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',rp2.iNl(i,:),size(Te2),@nansum,NaN);
end
rp2.Time=Te2;
rp2.AcouticEnergy=Ea;
rp2.DetectionRate=Ni;
rp2.AcouticPressure=Pa;
rp2.InfrasonicNoiseLevel=Inl;


% no1=load('IDAStatusNO120182019.mat');
no1=load('IDAStatusNO120182019v2.mat');
no1.iNl=no1.iNl';no1.pRs=no1.pRs';
j=find(no1.tT>datenum(2018,11,28));
no1.tT=no1.tT(j);
no1.nDs=no1.nDs(j);
no1.sCk=no1.sCk(j);
no1.iNl=no1.iNl(:,j);
no1.iNls=nanmedian(no1.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,no1.tTd,no1.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(no1.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;
Ea=[];Pa=[];Inl=[];
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,0);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',no1.iNl(i,:),size(Te),@nansum,NaN);
end
no1.Time=Te;
no1.AcouticEnergy=Ea;
no1.DetectionRate=Ni;
no1.AcouticPressure=Pa;
no1.InfrasonicNoiseLevel=Inl;



rsp=load('IDAStatusRSP20182019v2.mat');
rsp.iNl=rsp.iNl';rsp.pRs=rsp.pRs';
j=find(rsp.tT>datenum(2018,12,6));
rsp.tT=rsp.tT(j);
rsp.nDs=rsp.nDs(j);
rsp.sCk=rsp.sCk(j);
rsp.iNl=rsp.iNl(:,j);
%>>>>> Remove outlayers
XX=1:size(rsp.iNl,2);
[rsp.iNl(1,:),I,Y0,LB,UB] = hampel(XX,rsp.iNl(1,:));
[rsp.iNl(2,:),I,Y0,LB,UB] = hampel(XX,rsp.iNl(2,:));
[rsp.iNl(3,:),I,Y0,LB,UB] = hampel(XX,rsp.iNl(3,:));
[rsp.iNl(4,:),I,Y0,LB,UB] = hampel(XX,rsp.iNl(4,:));
[rsp.iNl(5,:),I,Y0,LB,UB] = hampel(XX,rsp.iNl(5,:));
rsp.iNls=nanmedian(rsp.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,rsp.tTd,rsp.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(rsp.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;
Ea=[];Pa=[];Inl=[];
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,0);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',rsp.iNl(i,:),size(Te),@nansum,NaN);
end
rsp.Time=Te;
rsp.AcouticEnergy=Ea;
rsp.DetectionRate=Ni;
rsp.AcouticPressure=Pa;
rsp.InfrasonicNoiseLevel=Inl;





gtn=load('IDAStatusGTN20182019.mat');
gtn.iNl=gtn.iNl';gtn.pRs=gtn.pRs';
%>>>>> Remove outlayers
XX=1:size(gtn.iNl,2);
[gtn.iNl(1,:),I,Y0,LB,UB] = hampel(XX,gtn.iNl(1,:));
[gtn.iNl(2,:),I,Y0,LB,UB] = hampel(XX,gtn.iNl(2,:));
[gtn.iNl(3,:),I,Y0,LB,UB] = hampel(XX,gtn.iNl(3,:));
[gtn.iNl(4,:),I,Y0,LB,UB] = hampel(XX,gtn.iNl(4,:));
gtn.iNls=nanmedian(gtn.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,gtn.tTd,gtn.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(gtn.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;
Ea=[];Pa=[];Inl=[];
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,0);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',gtn.iNl(i,:),size(Te),@nansum,NaN);
end
gtn.Time=Te;
gtn.AcouticEnergy=Ea;
gtn.DetectionRate=Ni;
gtn.AcouticPressure=Pa;
gtn.InfrasonicNoiseLevel=Inl;





gm2=load('IDAStatusGM220182019.mat');
gm2.iNl=gm2.iNl';gm2.pRs=gm2.pRs';
j=find(gm2.tT>datenum(2018,12,7));
gm2.tT=gm2.tT(j);
gm2.nDs=gm2.nDs(j);
gm2.iNl=gm2.iNl(:,j);
%>>>>> Remove outlayers
XX=1:size(gm2.iNl,2);
[gm2.iNl(1,:),I,Y0,LB,UB] = hampel(XX,gm2.iNl(1,:));
[gm2.iNl(2,:),I,Y0,LB,UB] = hampel(XX,gm2.iNl(2,:));
[gm2.iNl(3,:),I,Y0,LB,UB] = hampel(XX,gm2.iNl(3,:));
[gm2.iNl(4,:),I,Y0,LB,UB] = hampel(XX,gm2.iNl(4,:));
gm2.iNls=nanmedian(gm2.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,gm2.tTd,gm2.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(gm2.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;
Ea=[];Pa=[];Inl=[];
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,0);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',gm2.iNl(i,:),size(Te),@nansum,NaN);
end
gm2.Time=Te;
gm2.AcouticEnergy=Ea;
gm2.DetectionRate=Ni;
gm2.AcouticPressure=Pa;
gm2.InfrasonicNoiseLevel=Inl;






% no2=load('IDAStatusNO220182019.mat'); % xcorr with sensor5
% no2=load('IDAStatusNO220182019.mat'); % xcorr without sensor5
no2=load('IDAStatusNO220182019v2.mat');
no2.iNl=no2.iNl';no2.pRs=no2.pRs';
% no2.iNl(5,:)=NaN;
no2.iNls=nanmedian(no2.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,no2.tTd,no2.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(no2.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;
Ea=[];Pa=[];Inl=[];
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,0);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',no2.iNl(i,:),size(Te),@nansum,NaN);
end
no2.Time=Te;
no2.AcouticEnergy=Ea;
no2.DetectionRate=Ni;
no2.AcouticPressure=Pa;
no2.InfrasonicNoiseLevel=Inl;





gms=load('IDAStatusGMS20182019.mat');
gms.iNl=gms.iNl';gms.pRs=gms.pRs';
j=find(gms.tT>datenum(2018,12,7));
gms.tT=gms.tT(j);
gms.nDs=gms.nDs(j);
gms.iNl=gms.iNl(:,j);
gms.iNls=nanmedian(gms.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,gms.tTd,no2.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(gms.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;
Ea=[];Pa=[];Inl=[];
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,0);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',gms.iNl(i,:),size(Te),@nansum,NaN);
end
gms.Time=Te;
gms.AcouticEnergy=Ea;
gms.DetectionRate=Ni;
gms.AcouticPressure=Pa;
gms.InfrasonicNoiseLevel=Inl;








prt=load('IDAStatusPRT20182019.mat');
prt.iNl=prt.iNl';prt.pRs=prt.pRs';
prt.iNls=nanmedian(prt.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,prt.tTd,prt.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(prt.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;
Ea=[];Pa=[];Inl=[];
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,0);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',prt.iNl(i,:),size(Te),@nansum,NaN);
end
prt.Time=Te;
prt.AcouticEnergy=Ea;
prt.DetectionRate=Ni;
prt.AcouticPressure=Pa;
prt.InfrasonicNoiseLevel=Inl;






lvn=load('IDAStatusLVN20182019v2.mat');
lvn.iNl=lvn.iNl';lvn.pRs=lvn.pRs';
lvn.pRs=lvn.pRs(1:4,:);
j=find(lvn.tT>datenum(2018,12,6));
lvn.tT=lvn.tT(j);
lvn.nDs=lvn.nDs(j);
% lvn.sCk=lvn.sCk(j);
lvn.iNl=lvn.iNl(:,j);
%>>>>> Remove outlayers
XX=1:size(lvn.iNl,2);
[lvn.iNl(1,:),I,Y0,LB,UB] = hampel(XX,lvn.iNl(1,:));
[lvn.iNl(2,:),I,Y0,LB,UB] = hampel(XX,lvn.iNl(2,:));
[lvn.iNl(3,:),I,Y0,LB,UB] = hampel(XX,lvn.iNl(3,:));
[lvn.iNl(4,:),I,Y0,LB,UB] = hampel(XX,lvn.iNl(4,:));
lvn.iNls=nanmedian(lvn.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,lvn.tTd,lvn.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(lvn.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;
Ea=[];Pa=[];Inl=[];
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,0);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',lvn.iNl(i,:),size(Te),@nansum,NaN);
end
lvn.Time=Te;
lvn.AcouticEnergy=Ea;
lvn.DetectionRate=Ni;
lvn.AcouticPressure=Pa;
lvn.InfrasonicNoiseLevel=Inl;




hrm=load('IDAStatusHRM20182019.mat');
hrm.iNl=hrm.iNl';hrm.pRs=hrm.pRs';
j=find(hrm.tT>datenum(2018,12,6));
hrm.tT=hrm.tT(j);
hrm.nDs=hrm.nDs(j);
hrm.iNl=hrm.iNl(:,j);
j=find(hrm.tT>datenum(2018,12,14,12,0,0) & hrm.tT<datenum(2018,12,17,12,0,0));
hrm.tT(j)=[];
hrm.nDs(j)=[];
hrm.iNl(:,j)=[];
% %>>>>> Remove outlayers
XX=1:size(hrm.iNl,2);
[hrm.iNl(1,:),I,Y0,LB,UB] = hampel(XX,hrm.iNl(1,:));
[hrm.iNl(2,:),I,Y0,LB,UB] = hampel(XX,hrm.iNl(2,:));
[hrm.iNl(3,:),I,Y0,LB,UB] = hampel(XX,hrm.iNl(3,:));
[hrm.iNl(4,:),I,Y0,LB,UB] = hampel(XX,hrm.iNl(4,:));
[hrm.iNl(5,:),I,Y0,LB,UB] = hampel(XX,hrm.iNl(5,:));
hrm.iNls=nanmedian(hrm.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,hrm.tTd,hrm.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(hrm.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;
Ea=[];Pa=[];Inl=[];
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,0);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',hrm.iNl(i,:),size(Te),@nansum,NaN);
end
hrm.Time=Te;
hrm.AcouticEnergy=Ea;
hrm.DetectionRate=Ni;
hrm.AcouticPressure=Pa;
hrm.InfrasonicNoiseLevel=Inl;



% lpb=load('IDAStatusLPB20182019.mat');
lpb=load('IDAStatusLPB20182019v2.mat');
lpb.iNl=lpb.iNl';lpb.pRs=lpb.pRs';
j=find(lpb.tT>datenum(2018,12,6));
lpb.tT=lpb.tT(j);
lpb.nDs=lpb.nDs(j);
lpb.sCk=lpb.sCk(j);
lpb.iNl=lpb.iNl(:,j);
j=find(lpb.tT>datenum(2019,2,2) & lpb.tT<datenum(2019,2,6,12,0,0));
lpb.tT(j)=[];
lpb.nDs(j)=[];
lpb.sCk(j)=[];
lpb.iNl(:,j)=[];
lpb.iNls=nanmedian(lpb.iNl);
[tMe,pRs,E]=iad_DtsGrouping(DT,L,lpb.tTd,lpb.pRs);
[Ni, loci] = histc(tMe, bins); %... loc Nx1
[Nii, locii] = histc(lpb.tT', bins); %... loc Nx1
loci(loci==0)=1;
locii(locii==0)=1;
Ea=[];Pa=[];Inl=[];
for i=1:size(E,2)
    Ea(i,:) = accumarray(loci',E(:,i)',size(Te),@nansum,0);
    Pa(i,:) = accumarray(loci',pRs(:,i)',size(Te),@nanmean,NaN);
    Inl(i,:) = accumarray(locii',lpb.iNl(i,:),size(Te),@nansum,NaN);
end
lpb.Time=Te;
lpb.AcouticEnergy=Ea;
lpb.DetectionRate=Ni;
lpb.AcouticPressure=Pa;
lpb.InfrasonicNoiseLevel=Inl;



alerts=load('IDAsAlerts2018-2019');
ids={'no1', 'no2','lvn', ...
    'gtn','gm2','gms','prt',...
    'rsp','lpb','hrm'};
sitename={'Grasdalen','Indreesdalen','Lavangsdalen',...
    'Guttannen','Reckingen','Blitzingen','Quinto',...
    'Ross Peak','Loop Brook', 'Hermit'};

% ids={'no1', 'no2','lvn', ...
%     'rsp','lpb'};
% sitename={'Grasdalen','Indreesdalen','Lavangsdalen',...
%     'Ross Peak','Loop Brook'}

dBalerts=[];


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
figure;set(gcf,'color','w')
ax(1)=subplot(311);hold(ax(1),'on'),grid(ax(1),'on')
ax(2)=subplot(312);hold(ax(2),'on'),grid(ax(2),'on')
ax(3)=subplot(313);hold(ax(3),'on'),grid(ax(3),'on')

for i=1:length(ids)    
    ll=eval(['nanmedian(',char(ids(i)),'.InfrasonicNoiseLevel)']);
    ss=eval(['nanmedian(',char(ids(i)),'.AcouticEnergy)']);ss=20*log10(ss);
    
    [qq,ww]=hist(ss,0:2:150);
    
    if i<4
        p=plot(ax(1),0:2:150,qq,'o-');
        set(p,'markerfacecolor',clr(i,:),'markeredgecolor','k','color',clr(i,:),'markersize',psiz)
    end
    if i>=4 && i<8
        p=plot(ax(2),0:2:150,qq,'o-');
        set(p,'markerfacecolor',clr(i,:),'markeredgecolor','k','color',clr(i,:),'markersize',psiz)
    end
    if i>=8
        p=plot(ax(3),0:2:150,qq,'o-');
        set(p,'markerfacecolor',clr(i,:),'markeredgecolor','k','color',clr(i,:),'markersize',psiz)
    end
    sS=cat(1,sS,qq);
    
    j=ll>25 & isnan(ss);
    oPrn=cat(1,oPrn,100*sum(j)/length(ll));       
end
legend(ax(1),sitename(1:3))
legend(ax(2),sitename(4:7))
legend(ax(3),sitename(8:10))

set(ax,'FontSize',14,'xlim',[70 150],'Box','on')
linkaxes(ax,'xy') 

%% ISL over time 
erg=10:5:150;
f2=figure;set(f2,'pos',[750 70 710 735],'color','w')
iSl=[];
aiSl=[];
for i=1:length(ids)
    a1=eval(['median(',char(ids(i)),'.AcouticEnergy)']);
    a1(a1==0)=1;
    a1=20*log10(a1);
    a2=eval(['nanmedian(',char(ids(i)),'.InfrasonicNoiseLevel)']);
    
    jj=find(a2>15);
    a3=a1;a3(jj)=[];
    
    [kk,cc]=hist(a3,erg);
    iSl=cat(1,iSl,kk);
    
    
    jj=a2<10;
    aiSl=cat(1,aiSl,nansum);
    
    
    
    ax(i)=subplot(length(ids),1,i);plot(eval([char(ids(i)),'.Time']),a1,'.k');grid on,hold on
    datetick('x',12,'keeplimits'),set(ax(i),'xticklabel','')
%     if i==8
%         return
%     end
    
    j1=a2<15 & a2>0;
    j2=a1<80 & a1>0;
    jj=find((j1+j2)==2);
    p=plot(eval([char(ids(i)),'.Time(jj)']),a1(jj),'ok');
    set(p,'markerfacecolor','r','markersize',5)
%     legend(char(sitename(i)))
%     stem(datenum(alerts.T.(char(ids(i)))),70+zeros(size(alerts.T.(char(ids(i))),1)),'r')
end
set(ax,'fontsize',14,'ylim',[0 150])
linkaxes(ax,'xy')
datetick('x',12,'keeplimits')


%% ISL with INL below 10 dB
