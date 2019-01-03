function [pmx,cmax,az,azsd,va,vasd,RR,sts,tfly,ffp,Pxx]=iad_locator_planewave_O(pp,maxl,iclose,fi,...
    xstzi,ystzi,minR,cps)

if isempty(fi),fi=1;end

nstzc=length(xstzi);
az=NaN;va=NaN;pmx=NaN;vasd=NaN;azsd=NaN;sts=NaN;ffp=NaN;Pxx=NaN;
%... consistency
[c,l]=xcorr(pp',maxl,'coeff');
[co,icc]=max(c);
cmax=mean(mean(co,2));
lagg=reshape(l(icc),[nstzc nstzc])';  %... samples

RR=iad_consistency(lagg,iclose,nstzc);
RR=abs(sum(RR,2));
RR=sqrt(sum(RR.^2)/size(RR,1));

mx=max(lagg');
tfly=zeros(size(lagg));
for i=1:nstzc,
    tfly(i,:)=lagg(i,:)-mx(i);
end

tfly=round(mean(-tfly));

if RR<=minR*cps, 
    cmb3=iad_combntns(1:nstzc,3);    %... triplet's combination
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
            
            an(an<0)=2*pi+an(an<0); %... tra 0 e 360
            
            dt1=tfly(index(2))-tfly(index(1));
            dt2=tfly(index(3))-tfly(index(1));

            %... componentidel campo d'onda
            X(ii)=dt1*r(3)*cos(an(3))-dt2*r(2)*cos(an(2));
            Y(ii)=dt2*r(2)*sin(an(2))-dt1*r(3)*sin(an(3));
           
            if ispolycw({xx},{yy}),
            else
                X(ii)=-X(ii);
                Y(ii)=-Y(ii);
            end
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
%             disp(strcat('back-azimuth=',num2str(rad2deg(atan2(X(k),Y(k)))),' �N'))
%             pause
            
%             BA(k)=rad2deg(atan2(X(k),Y(k)));
%             
        end
%         atan2((X),(Y))
        az1(i)=atan2(median(X),median(Y));
    end
   
    az1(az1<0)=2*pi+az1(az1<0);
    azsd=circ_std(az1,[],[],2);
    
    %... soglia deviazione standard back-azimuth sui 4 triangoli
%     if azsd>deg2rad(15)
%         disp('noise!!!!')
%         pmx=NaN;cmax=NaN;az=NaN;azsd=NaN;va=NaN;vasd=NaN;RR=NaN;sts=NaN;
%         return
%     end

    az=circ_median(az1,2);
    az(az<0)=2*pi+az(az<0);

    cmb2=iad_combntns(1:nstzc,2);
    
    xc=xstzi(cmb2);yc=ystzi(cmb2);
    dcR=zeros(1,size(cmb2,1));llgg=dcR;
    igo=0;
    for ix=1:size(cmb2,1)
        [ag,dc]=cart2pol(yc(ix,:)-yc(ix,1),xc(ix,:)-xc(ix,1));
        dcR(ix)=abs(dc(2).*cos(az-ag(2)));
        llgg(ix)=abs(diff(tfly(cmb2(ix,:))));
        if llgg(ix)>10,
            igo=igo+1;
            va(igo)=dcR(ix)./(llgg(ix)/(cps(fi)));
        end
    end
    
    vasd=nanstd(va);
    va=nanmedian(va);
    

%     delays=llgg/cps(fi);
%     jgood=delays>(1/cps(fi))*2; %... !!!!!!!!!!!!!!!!!!!!
%     if length(find(jgood==1))<3
%         disp('OCCHIO!!!')
%         pmx=NaN;cmax=NaN;az=NaN;azsd=NaN;va=NaN;vasd=NaN;RR=NaN;sts=NaN;
%         return
%     else
%         CA=polyfit([zeros(1,nstzc) dcR(jgood)],[zeros(1,nstzc) delays(jgood)],1);
%         va=1./CA(1);
%     end
  
%     vmin=0; vmax=10000;
%     va=va(va>vmin & va<vmax);
%     va=median(va(isfinite(va) & va>vmin & va<vmax));
%     vasd=std(va(isfinite(va) & va>vmin & va<vmax));
%     va
    %... ampiezza massima tracciato steccato. contempla valori massimi
    %... negativi e positivi

    [~,sts]=iad_stack_traces(pp,tfly);
    
    [pmx,~]=max(abs(sts));    %... Pa
    for k=1:24,
        nfft=2^k;
        if nfft>size(sts,2);
            break
        end
    end
    
%     sts1=filtrax(sts,10,40,cps);
%     sts2=filtrax(sts,.1,10,cps);
%     sts=sts2-sts1;
    [Pxx,Fxx] = pwelch(sts,length(sts),length(sts)-1,nfft*2,cps,'oneside');
%     
%     figure(111)
%     ax(1)=subplot(211);
%     plot((0:length(sts)-1)/cps,sts,'k')
%     ax(2)=subplot(212);
%     semilogx(Fxx,log10(Pxx)),grid on
%     hold on
%     [iPxx,iffp]=max(log10(Pxx));
%     iffp=Fxx(iffp)
%    plot(iffp,iPxx,'ob')
% %     semilogx(Fxx,detrend(log10(Pxx)),'r')
% Pxxd=log10(Pxx')-smooth(log10(Pxx),round(nfft/4));
%     semilogx(Fxx,Pxxd,'r')
%     [iPxx,iffp]=max(Pxxd);
%     iffp=Fxx(iffp)
%    plot(iffp,iPxx,'or')
%     
%     pause
%     cla
    
    
    [Pxx,ffp]=max(Pxx);
    ffp=Fxx(ffp);
%     disp(strcat('Amplitude =',num2str(pmx),'+-',num2str(std(max(abs(pp'))))))
%     disp(strcat('Back-Azimuth =',num2str(round(rad2deg(az)*100)/100),'+-',num2str(round(rad2deg(azsd)*100)/100),' �N'))
    disp(['Apparent velocity =',num2str(round(va*10)/10),' m/s']) 
    
%     disp(strcat('Amplitude=',num2str(pmx),'+-',num2str(std(max(abs(pp'))))))
%     disp(strcat('times=',num2str(tfly)))
end

return


