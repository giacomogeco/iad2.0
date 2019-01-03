
function iad_detections2events_exp_test(T0,tt,Mf,time,prs,bkz,iexp)

% close all
figure,

time=86400*(time-T0);

plot(tt,Mf(1,:),'k'),grid on
hold on,plot(time,iexp,'o')

n1=length(time);
disp(['... ',num2str(n1),' Detections'])

vec=time'+prs+bkz;
ii=find(iexp>=10 & iexp<=25);

time=time(ii);prs=prs(ii);bkz=bkz(ii);iexp=iexp(ii);

n1=length(time);
disp(['... ',num2str(n1),' Detections'])

%.... 1 ....%
%... calcolo la lunghezza delle detezioni
dt=diff((time));  % decimi di sec
ij=find(dt>0.21); %... indici dei dt non "continui"
ti=[0,ij]+1;
tf=ij;tf=[tf,length(time)];
le=tf-ti+1;   %... number of detections
ij=find(le<3);
Index=[];
for i=1:length(ij)
    index=(ti(ij(i)):tf(ij(i)));
    Index=[Index,index];
end
time(Index)=''; prs(Index)='';bkz(Index)=''; iexp(Index)='';

hold on
plot(time,iexp,'.r')

dt=diff((bkz'));  % decimi di sec
ij=find(dt>0); %... indici dei dt non "continui"
ti=[0,ij]+1;
tf=ij;tf=[tf,length(bkz)];
le=tf-ti+1;   %... number of detections
ij=find(le<3);
Index=[];
for i=1:length(ij)
    index=(ti(ij(i)):tf(ij(i)));
    Index=[Index,index];
end

time(Index)=''; iexp(Index)='';prs(Index)=''; bkz(Index)='';


plot(time,iexp,'^y')
