
function [tMe,pRs,E]=iad_DtsGrouping(DT,L,txx,prs)


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
txx(Index)=''; prs(Index)='';

dt=diff((txx*86400));
ij=find(dt>DT);
ti=[0,ij]+1;
tf=ij;tf=[tf,length(txx)];

pRs=[];tMe=[];E=[];
for i=1:length(ti)
        idx=ti(i):tf(i);
        
        tMe=cat(2,tMe,txx(idx(1)));
        pp=prs(idx);
        
        d=86400*(tf(i)-ti(i));
        
        pRs=cat(1,pRs,nanmax(pp'));
        
        E=cat(1,E,nanmax(pp')*d);     
end
        

return