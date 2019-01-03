
function [MW,MS,xc,lag]=iad_allineawf(M,c,plotta,smp)
%... M=matrice colonna delle forme d'onda estratte
%... c=campioni di shift

% clear all,close all
% load explosion
% M=filtrax(pp',1,20,100);clear pp
% c=100;


msz=size(M);
nforme=msz(2);
[xx,ixx]=xcorr(M,c,'coeff');
xx=xx(:,2:nforme);

% [cmax,lag]=max(xx);
% lag=ixx(lag)-1;
% jd=find(lag>0);
% js=find(lag<0);
% j0=find(lag==0);
% 
% ilag=lag;
% ilag(js)=1;
% 
% flag=size(M,1)+zeros(1,nforme-1);
% flag(js)=size(M,1)+lag(js);
% l=flag-ilag+1;
% return
% 
% lmax=size(ilag:flag,2);
% dlag=lmax-flag;
% j=find(dlag>0);
% 
% flag(j)=flag(j)+dlag(j);

% Mst=zeros(size(M));
% for i=2:nforme
%     Mst(ilag(i-1):flag(i-1),i)=M(ilag(i-1):flag(i-1),i);
% end
% Mst(:,1)=M(:,1);
% % figure,plot(Mst)

% Mn=zeros(size(M));
% Mn(:,1)=M(:,1);
% Mn(ii(1,:),1)=M(ii(1,:),1);


[cmax,lag]=max(xx);
lag=ixx(lag)-1;

MW=zeros(msz(1),nforme);
MW(:,1)=M(:,1);

for jj=1:nforme-1,
    lg=abs(lag(jj));
    xc(jj)=cmax(jj);
    if lag(jj)<0,%... shift sx
        MW(:,jj+1)=[M(lg:end,jj+1);zeros(lg-1,1)];
    end
    if lag(jj)==0,
        MW(:,jj+1)=M(:,jj+1);
    end
    if lag(jj)>0,
        MW(:,jj+1)=[zeros(lg,1);M(1:end-lg,jj+1)];
    end
    MW(:,jj+1)=MW(:,jj+1);
end
MS=sum(MW')/nforme;
if plotta==1,
    step=mean(abs(min(MW))+max(MW))/2;
    time=(0:length(MW)-1)/smp;
%     pos=get(0,'screensize');
    figure(111),
    set(gcf,'color','w'),
%     set(gcf,'pos',pos)
    ax(1)=subplot(212);set(ax(1),'pos',[.1 .05 .85 .2])
    set(gca,'fontSize',14)
%     plot(time,MW,'k'),
    grid on,hold on,
    
    plot(time,MS,'r','linewidth',1.5),hold off,box on
    title(num2str(round(mean(xc)*100)/100))
    set(ax(1),'xlim',[0 time(end)])
    kk=0;
    ax(2)=subplot(211);set(ax(2),'pos',[.1 .35 .85 .6])
    for w=1:nforme,
        kk=kk+1;

        plot(time,MW(:,w)+step*kk,'k','linewidth',1)
        hold on
    end
    set(ax(2),'xlim',[0 time(end)])
    set(gca,'fontSize',14)
    
    grid on,hold off
    linkaxes(ax,'x')
end
        

return