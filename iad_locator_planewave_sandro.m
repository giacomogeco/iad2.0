function [pmx,cmax,az,azsd,va,vasd,RR,sts,tfly,ffp,Pxx]=iad_locator_planewave_sandro(pp,maxl,iclose,fi)

% pp matrice riga (nstz x nsamples)
% maxl max lag di corss-correlaton (samples)
% iclose triplette [1 2 3;1 2 4] ('' tutte le combinazioni)
% fi (optional)

global nstzc cps minR xstz ystz zstz
global sensors
% global LAG

% global cccmax

% global distx disty  % NNNNNBBBBB TEST
% distx=[];disty=[];

senidx=find(sensors==1);
xstz=xstz(:);ystz=ystz(:);zstz=zstz(:);
xstzi=xstz(senidx);ystzi=ystz(senidx);%zstzi=zstz(senidx);

if isempty(fi),fi=1;end

az=NaN;va=NaN;pmx=NaN;vasd=NaN;azsd=NaN;sts=NaN;ffp=NaN;Pxx=NaN;
%... consistency
[c,l]=xcorr(pp',maxl,'coeff');
[co,icc]=max(c);
cmax=mean(mean(co,2));
lagg=reshape(l(icc),[nstzc nstzc])';  %... samples

   
% rango=sum(sum(lagg+lagg'));
% lagg=(conv2(lagg,ones(nstzc,nstzc))+conv2(ones(nstzc,nstzc),lagg))/2;
% if rango~=0
%     disp('...... SANGRO .....')

RR=mcc_consistency(lagg,iclose,nstzc);
RR=abs(sum(RR,2));
RR=sqrt(sum(RR.^2)/size(RR,1));

% ...... SANDRO .....
lagg=(lagg*ones(nstzc,nstzc)+ones(nstzc,nstzc)*lagg)/nstzc;

mx=max(lagg');
tfly=zeros(size(lagg));
for i=1:nstzc,
    tfly(i,:)=lagg(i,:)-mx(i);
end

tfly=round(mean(-tfly));

% if RR<=minR*cps, 
cmb3=mcc_combntns(1:nstzc,3);    %... triplet's combination
%     Y=zeros(1,3);X=Y;
az1=zeros(1,size(cmb3,1));
for i=1:size(cmb3,1),
    lindex=cmb3(i,:);   %... i-tripletta
    for ii=1:3, %... per ogni ii-centro della i-esima tripletta (2008, Ludwik Liszka - IRF Sweden)

        if ii==1,
            index=[lindex(1) lindex(2) lindex(3)];
        end
        if ii==2,
            index=[lindex(2) lindex(3) lindex(1)];
        end
        if ii==3,
            index=[lindex(3) lindex(1) lindex(2)];
        end

        xx=xstzi(index);yy=ystzi(index);

        [an,r]=cart2pol(yy-yy(1),xx-xx(1));

        an(an<0)=2*pi+an(an<0); %... tra 0 e 360°

        dt1=tfly(index(2))-tfly(index(1));
        dt2=tfly(index(3))-tfly(index(1));

        %... componentidel campo d'onda
        X(ii)=dt1*r(3)*cos(an(3))-dt2*r(2)*cos(an(2));
        Y(ii)=dt2*r(2)*sin(an(2))-dt1*r(3)*sin(an(3));
        if ispolycw(xx,yy),
        else
            X(ii)=-X(ii);
            Y(ii)=-Y(ii);
        end

%             atan2(X(ii),Y(ii))
%             
%             disp('--------------')
%             disp(strcat('triplets=',num2str(lindex)))
%             disp(strcat('celtral sensor=',num2str(index(1))))
%             disp(strcat('index=',num2str(index)))
%             disp(strcat('t',num2str(index(2)),'-t',num2str(index(1)),'=',num2str(dt1))),
%             disp(strcat('dist',num2str(index(1)),num2str(index(2)),'=',num2str(r(2))))
%             disp(strcat('angle',num2str(index(1)),num2str(index(2)),'=',num2str(rad2deg(an(2)))))
%             disp(strcat('t',num2str(index(3)),'-t',num2str(index(1)),'=',num2str(dt2))),
%             disp(strcat('dist',num2str(index(1)),num2str(index(3)),'=',num2str(r(3))))
%             disp(strcat('angle',num2str(index(1)),num2str(index(3)),'=',num2str(rad2deg(an(3)))))
%             disp(strcat('X=',num2str(X(k))))
%             disp(strcat('Y=',num2str(Y(k))))
%             disp(strcat('is counter clock-wise=',num2str(ccw)))
%             disp(strcat('back-azimuth=',num2str(rad2deg(atan2(X(k),Y(k)))),' °N'))
%             pause

%             BA(k)=rad2deg(atan2(X(k),Y(k)));
%             
    end
%         atan2((X),(Y))
    az1(i)=atan2(median(X),median(Y));
end

az1(az1<0)=2*pi+az1(az1<0);
% az=nanmedian(az1,2)
az=circ_median(az1,2);
az(az<0)=2*pi+az(az<0);

azsd=circ_std(az1,[],[],2);


%... soglia deviazione standard back-azimuth sui 4 triangoli
%     if azsd>deg2rad(30)
% %         disp('noise!!!!')
%         pmx=NaN;cmax=NaN;az=NaN;azsd=NaN;va=NaN;vasd=NaN;RR=NaN;sts=NaN;
%         return
%     end
% az=circ_median(az1,2);
% az(az<0)=2*pi+az(az<0);

cmb2=mcc_combntns(1:nstzc,2);
xc=xstzi(cmb2);yc=ystzi(cmb2);
dcR=zeros(1,size(cmb2,1));llgg=dcR;
igo=0;
for ix=1:size(cmb2,1)
    [ag,dc]=cart2pol(yc(ix,:)-yc(ix,1),xc(ix,:)-xc(ix,1));
%         [ag,el,dc]=cart2sph(yc(ix,:)-yc(ix,1),xc(ix,:)-xc(ix,1),zc(ix,:)-zc(ix,1));
    dcR(ix)=abs(dc(2).*cos(az-ag(2)));
    llgg(ix)=abs(diff(tfly(cmb2(ix,:))));

%         [ag2,dc2]=cart2pol(yc(ix,1)-yc(ix,:),xc(ix,1)-xc(ix,:));
%         VV(ix)=dcR(ix)./(llgg(ix)/(cps(fi)));
%         AN(ix,1)=ag(2);
%         AN(ix,2)=ag2(2);

    if llgg(ix)>1,
        igo=igo+1;
        va(igo)=dcR(ix)./(llgg(ix)/(cps(fi)));
    end
end

%     AN(AN<0)=AN(AN<0)+2*pi;AN=rad2deg(AN);
%     daz(:,1)=rad2deg(abs(atan2(sind(rad2deg(az)-AN(:,1)),cosd(rad2deg(az)-AN(:,1)))));
%     daz(:,2)=rad2deg(abs(atan2(sind(rad2deg(az)-AN(:,2)),cosd(rad2deg(az)-AN(:,2)))));
%     daz=min(daz,[],2);
%     [~,iazmin]=min(daz);
%     VV=VV(iazmin)


%     figure(111)
%     plot([zeros(1,3) dcR],[zeros(1,3) llgg/cps(fi)],'+r'),grid on,set(gca,'ylim',[0 1],'xlim',[0 max(dcR)*1.1])
%     hold on
%     plot(1:max(dcR),(1:max(dcR))/340,'k-.')
%     

delays=llgg/cps(fi);
jgood=delays>5/cps(fi);

vasd=std(dcR(jgood)./delays(jgood));
[CA,s]=polyfit([zeros(1,length(jgood)) dcR(jgood)],[zeros(1,length(jgood)) delays(jgood)],1);
%     [CA,s]=polyfit([dcR(jgood)],[delays(jgood)],1);

% (inv(s.R)*inv(s.R)')*s.normr^2/s.df
% R: [2x2 double]
%        df: 9
%     normr: 0.0537
va=1./CA(1);
%     vasd=0;
%     s.normr
%     a = polyparci(CA,s);
%     cc=sqrt((a(1,2)*a(1,2))/(a(1,1)*a(2,2)))
%     
%     0.0156   -0.0000
%     0.0156    0.0000
%     b_err = sqrt(diag((s.R)\inv(s.R'))./s.normr.^2./s.df) 
%     [y,ste] = polyval(CA,[zeros(1,nstzc) dcR(jgood)],S,mu);
%     [z,s]=polyfit(x,y,1);
%     ste = sqrt(diag(inv(s.R)*inv(s.R'))./s.normr.^2./s.df);
%     
%     xx=0:20:150;
%     yy=CA(1)*xx+CA(2);
%     plot(xx,yy,'b')
%     pause
%     hold off
%     dcR(2)/delays(2)

%     vasd=0;
% %     
%     vmin=0; vmax=10000;
%     va=va(va>vmin & va<vmax);
%     va=median(va(isfinite(va) & va>vmin & va<vmax));
%     vasd=std(va(isfinite(va) & va>vmin & va<vmax));
%     
%... ampiezza massima tracciato steccato. contempla valori massimi
%... negativi e positivi

[st,sts]=mcc_stack(pp,tfly);

%figure(111);plot(st'), drawnow
cWnd=10;
stLength=size(st,2);

%xcorr gloabale su stack
%[xst,lst]=xcorr(st',cWnd);
%xstRsh=reshape(xst,[size(lst,2),nstzc,nstzc]);     
%xstSW=xstRsh(floor(size(lst,2)/2)+1,:,:);
%xSWGlb=(mean(mean((xstSW))))

for j=0:stLength-cWnd
    %st=st';
    %stW=st(:,j:j+cWnd)
    wnd=zeros(nstzc,j);
    wnd=cat(2,wnd,ones(nstzc,cWnd));
    wnd=cat(2,wnd,zeros(nstzc,stLength-(j+cWnd)));      
    
    %xcorr su finestrina mobile
    stW=st.*wnd;
    [xst,lst]=xcorr(stW',cWnd);    
    xstRsh=reshape(xst,[size(lst,2),nstzc,nstzc]);     
    xstSW=xstRsh(floor(size(lst,2)/2)+1,:,:);
    xSW(j+1)=(mean(mean(((xstSW)))));
  %prv(j+1)=xstSW(1,2);
end
%r=mean(xSW);
xSW=detrend(xSW);
figure(111);plot(xSW),drawnow
xSWCenter=xSW(2*cWnd:stLength-2*cWnd);
%xSWCenter=xSW;
[m,mm]=max(xSWCenter,[],2); 
%0.5*(m-r)
k=find(xSWCenter>0.1*m);%.5*(m-r));
sgnW=NaN;
if((size(k,2)>0)&(k(end)<stLength-5*cWnd)&(k(1)>5*cWnd))
    sgnW=k(end)-k(1);
end;
if(sgnW>30)
    sgnW=NaN;
end;
%[pks,locs,w,p] = findpeaks(abs(xSW),'MinPeakProm',0.05,'WidthReference','halfheight'); 
% [P,lP]=max(pks);   
%  sgnW=NaN;
%  if(size(P)==1)
%     if((locs(lP)-w(lP)/2)>0)&&((locs(lP)+w(lP)/2)<size(st,2))          
%        sgnW=w(lP)-cWnd;
%    end
%  end



tfly=tfly/cps;

% load('/Users/giacomo/Documents/item/progetti/wyssen/Canada/Artillery_waveforms/McDW/rp1_ex_master_01_20_Hz.mat')
% load('/Users/giacomo/Documents/item/progetti/wyssen/Canada/Artillery_waveforms/McDW/20170210_wf.mat')
% load gun
% artillery=gun;
% size(sts)
% sts=smooth(sts,10);
% artillery=resample(artillery,cps,50);
% aaa=[sts;artillery];
% [ccc,lll]=xcorr(aaa',size(artillery,2),'coeff');
% [ccco,icc]=max(ccc);
% 
% cccmax=mean(mean(ccco,2));
% % figure(111),plot(aaa'),pause
% if cccmax>.9
%     cmax=1;
% end

% m/s /1000
% km2rad(km)
% radtodeg(rad);

% M/sec = (Degrees/sec * R *Pi)/360
% XX=km2deg(xstz/1e3-xstz(1)/1e3);
% YY=km2deg(ystz/1e3-ystz(1)/1e3);

% vag=va*360/(6380*pi);
% beam = mcc_tdelay ( pp', cps, XX, YY, az, vag);



% figure(111),plot(beam),title(num2str(round(ffp))),pause

[pmx,~]=max(abs(sts));    %... Pa
for k=1:24,
    nfft=2^k;
    if nfft>size(sts,2);
        break
    end
end

[Pxx,Fxx] = pwelch(detrend(sts),[],[],nfft*2,cps,'oneside');
[Pxx,ffp]=max(Pxx);
% ffp=Fxx(ffp);

% size(sts)
ffp = mcc_bfstat(st');


%     disp(strcat('Amplitude =',num2str(pmx),'+-',num2str(std(max(abs(pp'))))))
%     disp(strcat('Back-Azimuth =',num2str(round(rad2deg(az)*100)/100),'+-',num2str(round(rad2deg(azsd)*100)/100),' °N'))
%     disp(strcat('Apparent velocity =',num2str(round(va*10)/10),' m/s +-',num2str(round(vasd*100)/100),' m/s')) 
% pause
%     disp(strcat('Ampl?itude=',num2str(pmx),'+-',num2str(std(max(abs(pp'))))))
%     disp(strcat('times=',num2str(tfly)))
% end
ffp=sgnW;
return


