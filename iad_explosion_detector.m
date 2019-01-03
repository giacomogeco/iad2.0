function [sgnW,xxxW]=iad_explosion_detector(st,nstzc)

% st(st<.5)=0;

%figure(111);plot(st'), drawnow
cWnd=10;
stLength=size(st,2);

%xcorr gloabale su stack
%[xst,lst]=xcorr(st',cWnd);
%xstRsh=reshape(xst,[size(lst,2),nstzc,nstzc]);     
%xstSW=xstRsh(floor(size(lst,2)/2)+1,:,:);
%xSWGlb=(mean(mean((xstSW))))
% xSW=zeros(stLength-cWnd+1,1)*NaN;
%  keyboard
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
    xSW(j+1)=mean(xstSW(:));
  %prv(j+1)=xstSW(1,2);
end

%r=mean(xSW);
% xSW=detrend(xSW);

xSWCenter=xSW(2*cWnd:stLength-2*cWnd);
xSWCt=1:length(xSWCenter);
%xSWCenter=xSW;
[m,mm]=max(xSWCenter,[],2); 
%0.5*(m-r)

k=find(xSWCenter>0.1*m);%.5*(m-r));

xSWi=zeros(size(xSWCenter));
xSWi(k)=xSWCenter(k);

% sgnW=NaN;
sgnW=0;
xxxW=0;
% if (size(k,2)>0 && k(end)<stLength-5*cWnd && k(1)>5*cWnd)
if (size(k,2)>0 && k(end)<stLength && k(1)>1)
    sgnW=k(end)-k(1);
    xxxW=mean(xSWi(k));
else
end
    
% if size(k,2)<k(end)-k(1)
%     sgnW=sgnW/2-(k(end)-k(1)-size(k,2));
% end
% figure(111);
% subplot(211),plot(st');
% subplot(212),plot(xSWCt,xSWCenter)
% hold on
% plot(xSWCt,xSWi,'or')
%     title(num2str(sgnW))
% % drawnow
% pause
% hold off
return


