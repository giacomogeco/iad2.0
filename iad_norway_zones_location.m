function [zid,ztext]=iad_norway_zones_location(brs,bre,zonefilename)

load(zonefilename)
zid=[];
ZN=[];
ztext=[];

out = iad_check_unwrap ([brs bre]);
db=out(2)-out(1);
a=ones(1,360);
b=0*a;
if sign(db)==1
    idx=round(out(1):out(2));
    idx(idx<=0)=idx(idx<=0)+360;
    b(round(idx))=1;
else
    idx=round(out(1):-1:out(2)+1);
    idx(idx<=0)=idx(idx<=0)+360;
    b(round(idx))=1;
end
j2=(sign(zone.rotation)==sign(db));
% figure,rose(1:360,a+b),view(90,-90)
ztext=[];
k=0;
iZ=[];
for i=1:length(zone.number)
%     disp(['... check ',char(zone.name(i)),' compatibility'])
    B=zeros(1,360);
    out = iad_check_unwrap ([zone.startbkz(i) zone.endbkz(i)]);
    if sign(zone.rotation(i))==1
        idx=round(out(1):out(2));
        idx(idx<=0)=idx(idx<=0)+360;
        idx=round(idx);
        idx(idx==0)=360;
        B(idx)=1;
        
        %... "contemplating" the starting zone Dec. 21 2018
        if zone.startbkz(i)>brs
%             disp('start bkz univoque')
            B=B*0;           
            
        end
    else
        idx=out(1):-1:out(2)+1;
        idx(idx<=0)=idx(idx<=0)+360;
        idx=round(idx);
        idx(idx==0)=360;
        B(idx)=1;
        
        %... "contemplating" the starting zone Dec. 21 2018
        if zone.startbkz(i)<brs
%             disp('start bkz univoque')
            B=B*0;
            
        end
    end
    
%     b = misurata (1x360)
%     B = teorica (1x360)   
    j1=find((b+B)>1);
    
    %... "contemplating" few migration Dec., 18 2018  ??!! 
    prc = round(1000*length(j1)/sum(B))/10;
    if prc<10
        j1=[];
        prc=0;
    end
    disp([num2str(prc),' %'])
    
    if ~isempty(j1) && j2(i)==1
        k=k+1;
        iZ=cat(1,iZ,i);
        zid=[zid,i];
        if k==1
            ztext=char(zone.name(i));
        else
            ztext=[ztext,' or ',char(zone.name(i))];
        end        
    end
    
end

if isempty(zid)
    ztext='Uncertain';
    zid=0;
else
    if length(zid)>1
        ztext='Uncertain';
    end
end
        



disp(['ZONE: ',ztext])    
return



