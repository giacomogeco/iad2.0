function D=iad_mcc_analysis_ex(t,M,...
    win,sh,F,minR,nmux,...
    smp,sensors,...
    arrayfile,...
    trplts,mlag,O,Rp,tpw,bkzmaxstd,...
	slh,working_dir)

% global slh working_dir

%... tolgo i nan
ms=sum(M,1);
M=M(:,isfinite(ms));
t=t(isfinite(ms));

if size(M,2)<smp*10,
    D=[];
    disp('no data to process')
    return
end

iactive=sensors==1;
load([working_dir,slh,'arrays',slh,arrayfile])
xstzi=array.x(iactive);ystzi=array.y(iactive);
% zstzi=array.z(iactive);stzID=array.id(iactive);
nstzc=sum(sensors==1);
               
cps=smp*nmux;
maxl=mlag*cps;

%===============================================================
info.maxl=maxl;info.freq=F;info.win=win;info.shift=sh;
info.minR=minR;info.nmux=nmux;
%===============================================================
dt1=1/smp;dt2=1/cps;
nw=round(smp*win);
nskip=round(smp*sh);
nn=nw*nmux;
t1=dt1*(0:nw-1);t2=dt2*(0:nn-1);

dF=diff(F);
for k=1:24,nfft=2^k;if nfft<max(nw);mm=k+1;end,end
nfft=2^mm;

FP=struct;
for i=1:length(F)-1,
    Wp=[F(i) F(i+1)]/(smp/2);
    [b,a] = cheby1(O,Rp,Wp);
    FP.(strcat('f',num2str(i)))=[b;a];
    [~,w1]=freqz(b,a,nfft);
end

%%
%... tolgo i nan
nd=length(t);
Ind=1:nskip:nd-nw;
if Ind(end)+nw>nd-nw,
    Ind=[Ind nd-nw];
end
%.......... inizializzo variabili orarie ..................
nlo=length(Ind);
prs=NaN*zeros(nlo,length(F)-1);
azz=prs;azzsd=prs;
slw=prs;slwsd=prs;
cc=prs;
rs=prs;
Fp=prs;
txx=prs(:,1);
snr=txx;
Ex_flag=txx;

% figure,plot(M')
M=M(iactive,:);
fp=FP.(strcat('f',num2str(1)));
M=filtfilt(fp(1,:),fp(2,:),M');M=M';
% M=filter(fp(1,:),fp(2,:),M');M=M';
% iactive
% figure,plot(M')
% return
noise=median(mean(abs(M),2));

% iactive
% size(xstzi),size(M)
iframe=0;
for j=Ind,
    jend=j+nw;
    k=k+1;
    pp=zeros(nstzc,nn); % era nstz DDD
    datf=M(:,j:jend-1);
    if isempty(datf),
        continue
    else
        iframe=iframe+1;
        txx(iframe)=t(j);  %.. inizio finestra

        for fi=1:length(F)-1,
%             fp=FP.(strcat('f',num2str(fi)));

            for in=1:nstzc, %era nstz DDD
                %... filtro
%                 datf=filtfilt(fp(1,:),fp(2,:),dat(in,:));
                %... interpolo
                if nmux>1,
                    pp(in,:)=spline(t1,datf(in,:),t2);
                else
                    pp(in,:)=datf(in,:);
                end
            end
            
%             disp('!!!!!!!!!!  WARNING adding noise')
%             pp=iad_add_noise(pp,.1);
%             disp('!!!!!!!!!!  WARNING noise added')
%             tpw
            pp=iad_tapering(pp,tpw);
            
%             [MW,MS,xc,lag]=allineawf(pp',maxl,0,cps);
%             %... cross correlation analysis assuming plane wave front 
%             figure(111),plot(pp')
%             title(num2str(round(xc*100)/100))
%             pause
            [pmx,cmax,az,azsd,va,vasd,RR,~,ffp]=iad_locator_planewave(pp,...
                maxl,trplts,fi,...
                xstzi,ystzi,minR,cps,bkzmaxstd);
                az=az*180/pi;
                
            
            if ~isnan(az),
                
%                 load rp1_ex_master_01_20_Hz_bis
%                 rp1_wf_100=rp1_wf_100(1:200);
%                 mx=max(pp');mx=repmat(mx',[1 size(sts,2)]);
                
%                 size(mx)
%                 size(rp1_wf_100)
%                 Mtest=cat(1,pp./mx,rp1_wf_100./max(rp1_wf_100));
%                 Mtest=cat(1,pp./mx,sts./max(sts));
                
%                 xxEx=iad_wf_finder(rp1_wf_100,pp);
%                     
%                 [~,~,xxEx,~]=iad_allineawf(Mtest',60,0,cps);
                
                azz(iframe,fi)=az;
                azzsd(iframe,fi)=azsd;
                slw(iframe,fi)=va;
                slwsd(iframe,fi)=vasd;
                prs(iframe,fi)=pmx;
                cc(iframe,fi)=cmax;
                rs(iframe,fi)=RR;
                Fp(iframe,fi)=ffp;
                
                Ex_flag(iframe,fi)=NaN;
                
            end
        end
        
        
    end
%     size(prs),iframe
    if isnan(prs(iframe,1)),
    else
        snr(iframe)=20*log10(abs(prs(iframe,1))/noise);
    end

end
% close(h)

finestra=sh;
txx=round(txx*86400/finestra)/(86400/finestra);

% figure,plot(txx,azz,'.')
D.data=[txx(~isnan(azz)),prs(~isnan(azz)),azz(~isnan(azz)),azzsd(~isnan(azz)),slw(~isnan(azz)),...
    slwsd(~isnan(azz)),cc(~isnan(azz)),Fp(~isnan(azz)),rs(~isnan(azz)),Ex_flag(~isnan(azz))];
D.legend={'1.time';'2.pressure';'3.backazimuth';'4.backazimuth_sd';'5.velocity';...
    '6.velocity_sd';'7.semblance';'8.frequency_peak';'9.consistency';'10.ex_flag'};

clear txx prs azz azzsd slw slwd cc Fp rs
D.info=info;

return

return
D=struct;
D.time=txx;
D.pressure=prs;
D.backazimuth=azz;
D.backazimuth_sd=azzsd;
D.velocity=slw;
D.velocity_sd=slwsd;
D.semblance=cc;
D.peak_freq=Fp;
D.consistency=rs;

%%
shortNames = structfun(@(x) ( cat(1,x,FF) ), F, 'UniformOutput', false);



return
%% DETECTIONS TO EVENTS
detections=[]; events=[];
j1=find(azzsd<5);
j2=find(slwsd<200);
[j,i1,i2]=intersect(j1,j2);


% plot(txx(j),prs(j),'.r')

if isempty(j),
    disp('no stable detections')
    return
else

    DT=3*info.shift*info.nmux+.05;
    [detections,events]=detection2events(DT,L,txx(j)',prs(j),cc(j),...
        azz(j),slw(j),rs(j),Fp(j),snr(j),info);
end


return
