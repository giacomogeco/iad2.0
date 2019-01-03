clear all
close all
clear global
warning off
% function inl(t0,station)
ConfFileName='conf_lc1_2017_priv.txt';
namestz='fru';
net='wyssen';
save(['~/',namestz,'_temp.mat'],'net','namestz','ConfFileName')
%%%%%%%%%% SET PATHS %%%%%%%%%%%
global working_dir slh
[working_dir,slh]=iad_setpath;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(['~/',namestz,'_temp.mat'])

matfilepath='http://148.251.122.130/matfiles/';


%%%%%%%%%% STATIONS & PROCESSING PARAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	station=iad_read_ascii2cell([working_dir,slh,'conf_files',slh,net,slh,ConfFileName]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clock_offset=station.clockoffset;		%... offset (ore) between pc clock and UTC time 


channels=station.wschannels;

%station.gain=[.4 .4 .4 .4 .4];
t1=datenum(2017,12,1);
t2=datenum(2018,5,31);

% station.gain=[.2 .2 .2 .2 .2];
% t1=datenum(2017,11,30);
% t2=datenum(2018,5,31);

ww=3/24;

tv=t1:ww:t2;
ntv=length(tv);

PS.i1=[];PS.i2=[];PS.i3=[];PS.i4=[];PS.i5=[];
PS.a1=[];PS.a2=[];PS.a3=[];PS.a4=[];PS.a5=[];
PS.b1=[];PS.b2=[];PS.b3=[];PS.b4=[];PS.b5=[];
PS.rs1=[];PS.rs2=[];PS.rs3=[];PS.rs4=[];PS.rs5=[];
% PS=P;
T=[];
RMS.s1=[];RMS.s2=[];RMS.s3=[];RMS.s4=[];RMS.s5=[];

PSD.s1=[];PSD.s2=[];PSD.s3=[];PSD.s4=[];PSD.s5=[];

% g = fittype('a^2/x+b^2+2*b*a/sqrt(x)','coeff',{'a','b'});
smp=station.smp(1);

for it=1:ntv-1
    
    T1=tv(it);
    T2=T1+ww;
    
    disp(datestr(T1))
    
    [data,w]=get_winston_data(station.wsstation,...
        channels,...
        station.wsnetwork,...
        T1,T2,...
        station.wsserver,...
        station.wsport,...
        station.wslocation);
    
    
%     data=iad_readmatfile(T1,T2-15/1440,matfilepath,station);
    
    if isempty(data)
        disp('!!! Warning No Data on WS !!!') 
        continue
    end

    nw=length(data.tt);
    T=cat(1,T,T1);
    for i=1:length(station.wschannels)
        sconv=(station.advoltage/2^station.adbit)/station.gain(i);

        sig=data.(char(station.wschannels(i)))*sconv;
%         sig=(data.(char(station.wschannels(i))));
        
        ifin=isfinite(sig);
        
        
        if sum(ifin)==0
            PS.(['a',num2str(i)])=cat(1,PS.(['a',num2str(i)]),NaN);
            PS.(['b',num2str(i)])=cat(1,PS.(['b',num2str(i)]),NaN);
            PS.(['rs',num2str(i)])=cat(1,PS.(['rs',num2str(i)]),NaN);
            PS.(['i',num2str(i)])=cat(1,PS.(['i',num2str(i)]),NaN);
            RMS.(['s',num2str(i)])=cat(2,RMS.(['s',num2str(i)]),NaN);
            
             PSD.(['s',num2str(i)])=cat(1,PSD.(['s',num2str(i)]),NaN*zeros(1,2049));
            continue
        end
        sig=detrend(sig(ifin));
        [p,f] = pwelch(sig,length(sig),length(sig)-1,2^12,smp);
        
%         figure(111)
%          semilogx(f,10*log10(p)),hold on,grid on
%          set(gca,'xlim',[1e-2 25],'ylim',[-80 0])
        p=real(p);
        p=iad_smoothlog(p,100);
        
        
        
%         semilogx(f,10*log10(p)),hold off
        %... 1/r fit analysis
        j=find(f>=1 & f<=10);
        pint=p(j);
        fint=f(j);
        [curve2, gof2] = iad_createFit(fint,pint);

        PS.(['a',num2str(i)])=cat(1,PS.(['a',num2str(i)]),curve2.a);
        PS.(['b',num2str(i)])=cat(1,PS.(['b',num2str(i)]),curve2.b);
        PS.(['rs',num2str(i)])=cat(1,PS.(['rs',num2str(i)]),gof2.rsquare);
        
        %... spetrum integral analysis
%         j=find(f>=1 & f<=10);
        PS.(['i',num2str(i)])=cat(1,PS.(['i',num2str(i)]),sum(p(j))/length(j));
        
        %... signal RMS computation
        sigf=filtrax(sig,1,10,smp);
        RMS.(['s',num2str(i)])=cat(2,RMS.(['s',num2str(i)]),rms(sigf));
        
        PSD.(['s',num2str(i)])=cat(1,PSD.(['s',num2str(i)]),p);
    end
    
end
% ws_noise2dB_insert(EF,station);
F=f(j);
return


%%
% close all,
% clear all

% load('rp1-coeff_1-3Hz.mat');
% load('no1-coeff_1-3Hz.mat');
%load('prt-coeff_1-3Hz.mat');

load rp2_2017_2018_ina_3

time=T;
RMS1=[RMS.s1];
RMS2=[RMS.s2];
RMS3=[RMS.s3];
RMS4=[RMS.s4];

frange=[0.5 10];
j=find(F>=frange(1) & F<=frange(2));
ff=F(j);



figure
set(gcf,'Color','w')

jnowind=1:length(T);

ax(1)=subplot(311);
p=plot(time(jnowind),RMS1(jnowind),'ok');set(p,'markersize',4,'markerfacecolor','m')
hold on
p=plot(time(jnowind),RMS2(jnowind),'ok');set(p,'markersize',4,'markerfacecolor','r')
p=plot(time(jnowind),RMS3(jnowind),'ok');set(p,'markersize',4,'markerfacecolor','g')
p=plot(time(jnowind),RMS4(jnowind),'ok');set(p,'markersize',4,'markerfacecolor','b')
hold on
grid on
set(gca,'fontsize',14,'yscale','lin')
title('RMS')

ax(2)=subplot(312);
p=plot(time(jnowind),(PS.a1(jnowind)),'ok');set(p,'markersize',4,'markerfacecolor','m')
hold on
p=plot(time(jnowind),(PS.a2(jnowind)),'ok');set(p,'markersize',4,'markerfacecolor','r')
p=plot(time(jnowind),(PS.a3(jnowind)),'ok');set(p,'markersize',4,'markerfacecolor','g')
p=plot(time(jnowind),(PS.a4(jnowind)),'ok');set(p,'markersize',4,'markerfacecolor','b')
grid on
set(gca,'fontsize',14)
title(['a Coefficient - ',num2str(frange(1)),'-',num2str(frange(2)),' Hz'])

ax(3)=subplot(313);
p=plot(time(jnowind),(PS.i1(jnowind)),'ok');set(p,'markersize',4,'markerfacecolor','m')
hold on
p=plot(time(jnowind),(PS.i2(jnowind)),'ok');set(p,'markersize',4,'markerfacecolor','r')
p=plot(time(jnowind),(PS.i3(jnowind)),'ok');set(p,'markersize',4,'markerfacecolor','g')
p=plot(time(jnowind),(PS.i4(jnowind)),'ok');set(p,'markersize',4,'markerfacecolor','b')
grid on
set(gca,'fontsize',14)
title('Rsquare')

linkaxes(ax,'x')


%%
clear all

load('rp1-inl.mat');
% d2=load('no1-inl-02.mat');

d=PS;d=rmfield(d,'s5');

time=[T];

RMS1=[RMS.s1];
RMS2=[RMS.s2];
RMS3=[RMS.s3];
RMS4=[RMS.s4];
% rms.s5=[d1.RMS.s5,d2.RMS.s5];


frange=[.5 10];
j=find(F>=frange(1) & F<=frange(2));
ff=F(j);
% fref=logspace(log10(frange(1)),log10(frange(2)),length(ff));
% -0.4336    7.2524  -33.9696  -17.0065
dBref=-17*log10(ff)-39;
% dBref=dBref(j);

dc = structfun(@(x) ( x(:,j) ), d, 'UniformOutput', false);

% A1=sum(10*log10(d.s1(:,j))./repmat(dBref,[size(time,1) 1]),2);
% A2=sum(10*log10(d.s2(:,j))./repmat(dBref,[size(time,1) 1]),2);
% A3=sum(10*log10(d.s3(:,j))./repmat(dBref,[size(time,1) 1]),2);
% A4=sum(10*log10(d.s4(:,j))./repmat(dBref,[size(time,1) 1]),2);
% A5=sum(10*log10(d.s5(:,j))./repmat(dBref,[size(time,1) 1]),2);

A1=sum(10*log10(dc.s1),2)./repmat(sum(dBref),[size(time,1) 1]);
A2=sum(10*log10(dc.s2),2)./repmat(sum(dBref),[size(time,1) 1]);
A3=sum(10*log10(dc.s3),2)./repmat(sum(dBref),[size(time,1) 1]);
A4=sum(10*log10(dc.s4),2)./repmat(sum(dBref),[size(time,1) 1]);
% A5=sum(10*log10(dc.s5),2)./repmat(sum(dBref),[size(time,1) 1]); 


figure
set(gcf,'Color','w')

jnowind=RMS1<3.2e3;

ax(1)=subplot(211);
p=plot(time(jnowind),RMS1(jnowind),'ok');set(p,'markersize',4,'markerfacecolor','m')
hold on
p=plot(time(jnowind),RMS2(jnowind),'ok');set(p,'markersize',4,'markerfacecolor','r')
p=plot(time(jnowind),RMS3(jnowind),'ok');set(p,'markersize',4,'markerfacecolor','g')
p=plot(time(jnowind),RMS4(jnowind),'ok');set(p,'markersize',4,'markerfacecolor','b')
hold on
grid on
set(gca,'fontsize',14,'yscale','lin')
title('RMS')

ax(2)=subplot(212);
p=plot(time(jnowind),(A1(jnowind)),'ok');set(p,'markersize',4,'markerfacecolor','m')
hold on
p=plot(time(jnowind),(A2(jnowind)),'ok');set(p,'markersize',4,'markerfacecolor','r')
p=plot(time(jnowind),(A3(jnowind)),'ok');set(p,'markersize',4,'markerfacecolor','g')
p=plot(time(jnowind),(A4(jnowind)),'ok');set(p,'markersize',4,'markerfacecolor','b')
grid on
set(gca,'fontsize',14)
title('ATTENUATION')

linkaxes(ax,'x')