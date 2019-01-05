function [detections,EVENTS,dts,evts]=iad_detections2events(DT,L,txx,prs,cc,azz,slw,rs,Fp,iexp,shift)

ii=find(isfinite(prs)==1);
txx=txx(ii);prs=prs(ii);cc=cc(ii);azz=azz(ii);slw=slw(ii);
rs=rs(ii);Fp=Fp(ii);

n1=length(txx);
disp(['... ',num2str(n1),' Detections'])

%.... 1 ....%
%... calcolo la lunghezza delle detezioni
dt=diff((txx*86400));  % decimi di sec
ij=find(dt>DT); %... indici dei dt non "continui"
ti=[0,ij]+1;
tf=ij;tf=[tf,length(txx)];
le=tf-ti+1;   %... number of detections
ij=find(le<L);
Index=[];
for i=1:length(ij)
    index=(ti(ij(i)):tf(ij(i)));
    Index=[Index,index];
end
txx(Index)=''; prs(Index)='';rs(Index)=''; azz(Index)='';
Fp(Index)=''; slw(Index)=''; cc(Index)='';
disp(strcat(num2str(length(Index)),' detections removed'))

%.... 2 ....%
dt=diff((txx*86400));
ij=find(dt>DT);
ti=[0,ij]+1;
tf=ij;tf=[tf,length(txx)];
disp(strcat(num2str(n1-length(Index)),' detections remaining'))

dts=vertcat(txx,prs',rs',azz',Fp',slw',cc');

detections.time=txx;
detections.pressure=prs';
detections.backazimuth=azz';
detections.velocity=slw';
detections.peakfrequency=Fp';
detections.coherence=cc';
detections.consistency=rs';
% detections=vertcat(txx,prs',rs',azz',Fp',slw',cc');


Pm=zeros(1,length(ti));Pd=Pm;Pmax=Pm;Pmin=Pm;
Sm=Pm;Smax=Pm;Sd=Pm;Smin=Pm;Str=Pm;D=Pm;
Am=Pm;Ad=Pm;
Fm=Pm;Fd=Pm;Fam=Pm;Fmin=Pm;Fmax=Pm;
Cm=Pm;Cd=Pm;
Rm=Pm;Rd=Pm;
Amin=Pm;Amax=Pm;tAZmax=Pm;azvar=Pm;
ttPmax=Pm;
Prb=Pm;
Iexp=Pm;
Sia=Pm;Siv=Pm;

if isempty(txx),
    tti=0;ttf=0;
    disp('no events')
    EVENTS=[];
    evts.data=vertcat(tti',ttf',D,Cm,Cd,Pmax,Pd,Am,azvar,Sm,Smax,Str,Fm,Fd,Rm,Rd,Prb,Sia,Siv,Amin,Amax,Iexp,Fmin,Fam);
    
    evts.legend={'1.Tempo inizio finestra';'2.Tempo fine finstra';'3.Durata';'4.Coerenza media';...
    '5.Coerenza STD';'6.Pressione max';'7.Pressione STD';'8.Azimuth medio';'9. Max. Azimuth Variation';...
    '10.Velocity media';'11.Velocity max';'12.Velocity STD';'13.Frequenza media';'14.Frequenza STD';...
    '15.Consistenza media';'16.Consistenza STD';'17.Probability';'18.Az. Stability index';...
    '19.Vel. Stability index';'20.Az. start';'21.Az end';'22.Isexplosion';...
    '23. Frequenza minima';'23. Frequenza Iniziale'};
    return
    
else
%     h = waitbar(0,'Please wait...');
    for i=1:length(ti)
%         waitbar(i / length(ti))
        idx=ti(i):tf(i);
%         if length(idx)<L,
%             continue
%         end
        ff=Fp(idx);
        ss=slw(idx);
        ss=iad_hampel(1:length(ss),ss);%ss=ss';
        
        aa=azz(idx)';
        aa=iad_hampel(1:length(aa),aa);aa=aa';
        
        pp=prs(idx);
        
        c=cc(idx);
        r=rs(idx);
        twi=txx(idx);
        expi=iexp(idx);
        
        
        %... isexplosion
        Iexp(i)=nanmedian(expi);if isnan(Iexp(i)), Iexp(i)=0; end
        
        %... duration
        D(i)=86400*(txx(tf(i))-txx(ti(i)))+shift;%+(nw/cps)/86400;
        
        %... coherence parameters
        Cm(i)=mean(c);
        Cd(i)=std(c);
        
        %... pressure parameters
        [Pmax(i),iPm]=max(pp);
        Pm(i)=mean(pp);
        Pmin(i)=min(pp);
        Pd(i)=std(pp);
        
        %... Velocity
%         ss=mcc_hampel(1:length(ss),ss);
        Sm(i)=nanmedian(ss);
        Sd(i)=nanstd(ss);
        Smax(i)=nanmax(ss);
        Smin(i)=nanmin(ss);
        
        if D(i)>60
            ixxx=find(twi<twi(1)+30/86400);
            [RR,ZZ]=corrcoef(twi(ixxx),ss(ixxx));%... inserito il 16 Gen 2017 - modificato a 60 sec 12 dec 2018

        else
            [RR,ZZ]=corrcoef(twi,ss);%... inserito il 16 Gen 2017
%             Siv(i)=RR(2,1);if isnan(Siv(i)), Siv(i)=0; end        
        end
        Siv(i)=RR(2,1);if isnan(Siv(i)), Siv(i)=0; end     
%         Sav(i)=NaN; 
        
        if length(twi)<9
            Str(i)=0;
        else
            npol=round(length(ss)/3);
            Str(i)=iad_detections_trends([twi;ss']',twi(1),twi(end),npol);
        end
        
        
%         [azvar(i),Str(i)]=detections2migration(aa,ss);
%         [Str(i),azvar(i),Atrend(i)]=detections2downhillcoeff(ss,aa,L);
        
        %... azimuth parameters
        Am(i) = circ_median(aa(1:end)*pi/180,2);    %... azimuth medio
        Amin(i) = aa(1);    %... azimuth start
        Amax(i) = aa(end);    %... azimuth end
        
        azvar(i)=atan2(sind(aa(1)-aa(end)), cosd(aa(1)-aa(end)));
%         aav=aa-aa(1);
%         azvar(i) = mod(max(aav)-min(aav),360);
        
%         azvar(i) = circ_std(aa(1:end)*pi/180,[],[],2);
%         if length(twi)<9
%             azvar(i)=0;
%         else
%             npol=round(length(ss)/3);
%             azvar(i)=iad_detections_trends([twi;unwrap(aa)]',twi(1),twi(end),npol);
%         end
        [RR,ZZ]=corrcoef(twi,aa); %... inserito il 16 Gen 2017
       	Sia(i)=RR(2,1);
        
        Atrend(i)=NaN;  %... clock/underclock wise migration
%         daz=rad2deg(abs(atan2(sind(circ_median(aa(end-5:end)*pi/180,2)-circ_median(aa(1:5)*pi/180,2)),...
%             cosd(circ_median(aa(end-5:end)*pi/180,2)-circ_median(aa(1:5)*pi/180,2)))));
%         Amin(i)=aa(1);
%         Amax(i)=aa(end);
        
%         [X,Y] = pol2cart(aa,3e3);
%         Atrend(i)=ispolycw(X,Y);
        %... frequency parameters
        Fm(i)=nanmedian(ff);
        Fd(i)=nanstd(ff);
        Fam(i)=ff(iPm);
        Fmax(i)=nanmax(ff);
        Fmin(i)=nanmin(ff);
        
        %... residual parameters
        Rm(i)=nanmean(r);
        Rd(i)=nanstd(r);
        
        ttPmax(i)=twi(iPm);

    end
    tti=txx(ti)';ttf=txx(tf)';
    disp(strcat(num2str(length(tti)),' events'))
    
%     close(h)
end


Am(Am<0)=Am(Am<0)+2*pi;Am=rad2deg(Am);
% Amin(Amin<0)=Amin(Amin<0)+2*pi;Amin=rad2deg(Amin);
% Amax(Amax<0)=Amax(Amax<0)+2*pi;Amax=rad2deg(Amax);
% % azvar=rad2deg(azvar);

EVENTS.timeon=tti';
EVENTS.timeend=ttf';
EVENTS.timeamax=ttPmax;

EVENTS.durata=D;

EVENTS.meancoherence=Cm;
EVENTS.stdcoherence=Cd;

EVENTS.meanpressure=Pm;
EVENTS.maxpressure=Pmax;
EVENTS.stdpressure=Pd;
EVENTS.minpressure=Pmin;

EVENTS.meanazimuth=Am;
EVENTS.maxazimuth=Amax;
EVENTS.stdazimuth=azvar;
EVENTS.minazimuth=Amin;
EVENTS.azvar=azvar;
EVENTS.aztrend=Atrend;

EVENTS.meanvelocity=Sm;
EVENTS.maxvelocity=Smax;
EVENTS.stdvelocity=Sd;
EVENTS.minvelocity=Smin;
% EVENTS.velocitytrend=St\r;
% EVENTS.angularvelocity=Sav;

EVENTS.meanfrequency=Fm;
EVENTS.maxfrequency=Fmax;
EVENTS.stdfrequency=Fd;
EVENTS.minfrequency=Fmin;
EVENTS.maxamplitudefrequency=Fmin;

EVENTS.meanconsistency=Rm;
EVENTS.maxconsistency=Rd;

events=vertcat(tti',ttf',D,Cm,Cd,Pmax,Pd,Am,azvar,Sm,Smax,Str,Fm,Fd,Rm,Rd,Prb,Sia,Siv,Amin,Amax,Iexp,Fmin,Fam);

evts.data=events';
evts.legend={'1.Tempo inizio finestra';'2.Tempo fine finstra';'3.Durata';'4.Coerenza media';...
    '5.Coerenza STD';'6.Pressione max';'7.Pressione STD';'8.Azimuth medio';'9. Max. Azimuth Variation';...
    '10.Velocity media';'11.Velocity max';'12.Velocity STD';'13.Frequenza media';'14.Frequenza STD';...
    '15.Consistenza media';'16.Consistenza STD';'17.Probability';'18.Az. Stability index';...
    '19.Vel. Stability index';'20.Az. start';'21.Az end';'22.Isexplosion';...
    '23. Frequenza minima';'23. Frequenza Iniziale'};



% events=vertcat(tti',ttf',ttPmax,tAZmax,...  %... (1-4) TEMPI
%     Cm,Cd,...                               %... (5-6) COERENZA
%     Pm,Pmax,Pd,Pmin,...                     %... (7-10) PRESSIONE
%     Am,Amax,Ad,Amin,...                     %... (11-14) BACK-AZIMUTH
%     Sm,Smax,Sd,Smin,...                     %... (15-18) VELOCITY
%     Fm,Fmax,Fd,Fmin,Fam,...                 %... (19-23) FREQUENCY
%     Rm,Rd);                                 %... (24-25) RESIDUALS
% 
% 

return
