function D=iad_mcc_analysis(t,M,station,array,type)
%=================== Analysis Parameters ==================================
if strcmp(type,'avalanches')
    win=station.av_window;
    sh=station.av_shift;
    F=station.av_frequencyband;
    minR=station.av_minconsistency;
    nmux=station.av_resampling;
    trplts=station.av_trplts;
    mlag=station.av_maxlag;
    O=station.av_filterorder;
    Rp=station.av_filterripple;
    tpw=station.av_taper;
    bkzmaxstd=station.av_azmaxstd;
else
    win=station.ex_window;
    sh=station.ex_shift;
    F=station.ex_frequencyband;
    minR=station.ex_minconsistency;
    nmux=station.ex_resampling;   
    trplts=station.ex_trplts;
    mlag=station.ex_maxlag;
    O=station.ex_filterorder;
    Rp=station.ex_filterripple;
    tpw=station.ex_taper;
    bkzmaxstd=station.ex_azmaxstd;
end
%===================== Data Matrix Init ===================================
smp=station.smp(1);
sensors=station.sensors;
iactive=sensors==1;
M=M(iactive,:);
%... tolgo i nan
ms=sum(M,1);
M=M(:,isfinite(ms));
t=t(isfinite(ms));
if size(M,2)<smp*10
    D.data=[];
    D.legend=[];
    disp('no data to process')
    return
end
%===================== Array Geometry Init ================================
xstzi=array.x(iactive);ystzi=array.y(iactive);nstzc=sum(sensors==1);
cps=smp*nmux;
maxl=mlag*cps;
%====================== Spline Parameters Init ============================
dt1=1/smp;dt2=1/cps;
nw=round(smp*win);
nskip=round(smp*sh);
nn=nw*nmux;
t1=dt1*(0:nw-1);t2=dt2*(0:nn-1);
%=================== Output Variables Init ================================
nd=length(t);
Ind=1:nskip:nd-nw;
if Ind(end)+nw>nd-nw
    Ind=[Ind nd-nw];
end
nlo=length(Ind);
prs=NaN*zeros(nlo,length(F)-1);
azz=prs;azzsd=prs;
slw=prs;slwsd=prs;
cc=prs;
rs=prs;
Fp=prs;
Iex=prs;
txx=prs(:,1);
snr=txx;
%=================== Array Data Filtering =================================
FP=struct;
for i=1:length(F)-1
    Wp=[F(i) F(i+1)]/(smp/2);
    [b,a] = cheby1(O,Rp,Wp);
    FP.(strcat('f',num2str(i)))=[b;a];
end
fp=FP.(strcat('f',num2str(1)));
M=filtfilt(fp(1,:),fp(2,:),M');M=M';
%==========================================================================
noise=median(mean(abs(M),2));
iframe=0;
k=0;
for j=Ind
    jend=j+nw;
    k=k+1;
    pp=zeros(nstzc,nn); % era nstz DDD
    datf=M(:,j:jend-1);
    if isempty(datf)
        disp('Warning isempty(dataf)')
        continue
    else
        iframe=iframe+1;
        txx(iframe)=t(j);  %.. inizio finestra
        for fi=1:length(F)-1
            for in=1:nstzc %era nstz DDD                
                if nmux>1
                    pp(in,:)=spline(t1,datf(in,:),t2);
                else
                    pp(in,:)=datf(in,:);
                end
            end          
            pp=iad_tapering(pp,tpw);            
            %... cross correlation analysis assuming plane wave front 
            [pmx,~, cmax,az,azsd,va,vasd,RR,~,ffp,iex,~]=iad_locator_planewave(pp,...
                maxl,trplts,fi,...
                xstzi,ystzi,minR,cps,bkzmaxstd,station,type);          
%             % iserimento pdx parametro
%             [pmx, pdx, cmax,az,azsd,va,vasd,RR,~,ffp,iex,cex]=iad_locator_planewave(pp,...
%                 maxl,trplts,fi,...
%                 xstzi,ystzi,minR,cps,bkzmaxstd,station,type);           
            az=az*180/pi;                           
            if ~isnan(az)
                azz(iframe,fi)=az;
                azzsd(iframe,fi)=azsd;
                slw(iframe,fi)=va;
                slwsd(iframe,fi)=vasd;
                prs(iframe,fi)=pmx;
%                 pd(iframe,:)=pdx;               
%                 cc(iframe,fi)=cex;
                cc(iframe,fi)=cmax;               
                rs(iframe,fi)=RR;
                Fp(iframe,fi)=ffp;
                Iex(iframe,fi)=iex;
            else
%                 azz(iframe,fi)=1000;
            end
        end
    end
    if isnan(prs(iframe,1))
    else
        snr(iframe)=20*log10(abs(prs(iframe,1))/noise);
    end
end
finestra=sh;
txx=round(txx*86400/finestra)/(86400/finestra);
D.data=[txx(~isnan(azz)),prs(~isnan(azz)),azz(~isnan(azz)),azzsd(~isnan(azz)),slw(~isnan(azz)),...
    slwsd(~isnan(azz)),cc(~isnan(azz)),Fp(~isnan(azz)),rs(~isnan(azz)),Iex(~isnan(azz))];
% D.data=[txx(~isnan(azz)),prs(~isnan(azz)),azz(~isnan(azz)),azzsd(~isnan(azz)),slw(~isnan(azz)),...
%     slwsd(~isnan(azz)),cc(~isnan(azz)),Fp(~isnan(azz)),rs(~isnan(azz)),Iex(~isnan(azz)),...
%     pd(~isnan(azz),:)];
D.legend={'1.time';'2.pressure';'3.backazimuth';'4.backazimuth_sd';'5.velocity';...
    '6.velocity_sd';'7.semblance';'8.frequency_peak';'9.consistency';'10.ExplosionIndex'};
% iserimento pdx parametro
% D.legend={'1.time';'2.pressure';'3.backazimuth';'4.backazimuth_sd';'5.velocity';...
%     '6.velocity_sd';'7.semblance';'8.frequency_peak';'9.consistency';'10.ExplosionIndex';...
%     '11. Sensor s pressure (Pa)'};
clear txx prs azz azzsd slw slwd cc Fp rs
return

