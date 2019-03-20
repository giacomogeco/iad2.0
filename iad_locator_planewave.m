function [pmx,cmax,az,azsd,va,vasd,RR,sts,ffp,iex,cex]=iad_locator_planewave(pp,maxl,iclose,fi,...
    xstz,ystz,minR,cps,bkzmaxstd,station,type)

nstzc=length(xstz);
sensors=ones(1,nstzc);

if isempty(fi),fi=1;end

az=NaN;va=NaN;pmx=NaN;vasd=NaN;azsd=NaN;sts=NaN;ffp=NaN;iex=NaN;cex=NaN;
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
tfly=mean(-tfly);

% RR=0;
if RR<=minR*cps,

    cmb3=iad_combntns(find(sensors==1),3);    %... triplet's combination
%     Y=zeros(1,3);X=Y;
    az1=zeros(1,size(cmb3,1));
    for i=1:size(cmb3,1),
        lindex=cmb3(i,:);   %... i-tripletta
        for ii=1:3, %... per ogni ii-centro della i-esima tripletta (2008, Ludwik Liszka - IRF Sweden)

            if ii==1,
                index=[lindex(1) lindex(2) lindex(3)];
            end
            if ii==2
                index=[lindex(2) lindex(3) lindex(1)];
            end
            if ii==3
                index=[lindex(3) lindex(1) lindex(2)];
            end

            xx=xstz(index);yy=ystz(index);
            
            AA(1)=xx(3)-xx(1);
            AA(2)=yy(3)-yy(1);
            AA(3)=0;
            BB(1)=xx(2)-xx(1);
            BB(2)=yy(2)-yy(1);
            BB(3)=0;
            C(ii)=norm(cross(AA,BB)/(norm(AA)*norm(BB)));
            
            [an,r]=cart2pol(yy-yy(1),xx-xx(1));
            an(an<0)=2*pi+an(an<0); %... tra 0 e 360???

            dt1=tfly(index(2))-tfly(index(1));
            dt2=tfly(index(3))-tfly(index(1));

            %... componenti del campo d'onda
            X(ii)=dt1*r(3)*cos(an(3))-dt2*r(2)*cos(an(2));
            Y(ii)=dt2*r(2)*sin(an(2))-dt1*r(3)*sin(an(3));

            if ispolycw({xx},{yy})
            else
                X(ii)=-X(ii);Y(ii)=-Y(ii);
            end
        end
        az1(i)=atan2(median(X),median(Y));
        
        CC(i)=mean(C);
    end
    
    jgood=CC>.1;

    az1(az1<0)=2*pi+az1(az1<0);

    if strcmp(station.name,'lpb')
        disp('.... Giacomo modification 2018-12-24 !!!!!!!')
        az=az1(4);
    else
        az=circ_median(az1,2);
    end

    
    az(az<0)=2*pi+az(az<0);
    
%     azsd=nanstd(az1);
    azsd=circ_std(az1,[],[],2);
%... filtro deviazione standard bkz sui triangoli
	if azsd>deg2rad(bkzmaxstd)
    %    disp('WARNING deviazione standard bkz sui triangoli')
        az=NaN;va=NaN;pmx=NaN;vasd=NaN;azsd=NaN;sts=NaN;ffp=NaN;
		return
    end
%     rad2deg(az1)
    


    %... meth 2
    cmb2=iad_combntns(1:nstzc,2);
%     lindx=sub2ind([nstzc nstzc],cmb2(:,2),cmb2(:,1));
    xc=xstz(cmb2);yc=ystz(cmb2);
    dcR=zeros(1,size(cmb2,1));llgg=dcR;
    va=zeros(1,size(xc,1));
    igo=0;
    for ix=1:size(cmb2,1)
        [ag,dc]=cart2pol(yc(ix,:)-yc(ix,1),xc(ix,:)-xc(ix,1));
        dcR(ix)=abs(dc(2).*cos(az-ag(2)));
        llgg(ix)=abs(diff(tfly(cmb2(ix,:))));
        if llgg(ix)>2,
            igo=igo+1;
            va(igo)=dcR(ix)./(llgg(ix)/(cps(fi)));
        end
%         va(ix)=dcR./(abs(lagg(lindx(ix))/(cps(fi))));
    end
    
%     vasd=nanstd(va);
%     va=nanmedian(va);

    
    delays=llgg/cps(fi);
    jgood=delays>1/cps(fi);
    
    DCR=[zeros(1,nstzc) dcR(jgood)];%dcR(jgood);
    DT=[zeros(1,nstzc) delays(jgood)];%delays(jgood);
    
%     CA=polyfit([zeros(1,nstzc) dcR(jgood)],[zeros(1,nstzc) delays(jgood)],1);
%     CA=polyfit([dcR(jgood)],[delays(jgood)],1);
    CA=polyfit(DCR,DT,1);
    va=1./CA(1);
    vasd=0;
    
    if isnan(va)
        az=NaN;va=NaN;pmx=NaN;vasd=NaN;azsd=NaN;sts=NaN;ffp=NaN;
        return
    end

    %... ampiezza massima tracciato steccato. contempla valori massimi
    %... negativi e positivi
    [st,sts]=iad_stack_traces(pp,tfly);
    [pmx,~]=max(abs(sts));    %... Pa
    
    if station.ExplYes && strcmp(type,'explosions')
        if pmx>station.ex_minpressure
            for itwr=1:size(station.twr_baz,1)
%                 disp('... finding')
                if station.twr_baz(itwr,1)>station.twr_baz(itwr,2)
                    out = iad_check_unwrap ( station.twr_baz(itwr,:))    ;
                    out2=wrapTo180(az*180/pi);
                    if out2>=out(1) && out2<=out(2) 
                        [iex,cex]=iad_explosion_detector(st,nstzc);
                    end
                else
                    if az*180/pi>=station.twr_baz(itwr,1) && az*180/pi<=station.twr_baz(itwr,2) 
                        [iex,cex]=iad_explosion_detector(st,nstzc);
                    end
                end
            end
        end
    end  
   
    
    %%%% FAN %%%%%%%
    c=xcorr(sts,sts); 
    [~,fp]=findpeaks(c);
    if length(fp)>1
        s=nanmean(diff(fp))/cps;%siz=1/s;
    else
        s=fp/cps;
    end
    ffp=1/s;    %... Hz (Sandro)
%     siz=s*340;  %... m  (Sandro)
    
    
%     disp(strcat('App. Vel.=',num2str(va)))
end
return
