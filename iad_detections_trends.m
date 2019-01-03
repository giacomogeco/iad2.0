function [vappG,var]=iad_detections_trends(data,minX,maxX,numBinX)

tl=zeros(numBinX,1);
fr=zeros(numBinX,1);
bx=linspace(minX,maxX,numBinX-1)';

tl(1)=mean(data(data(:,1)<=bx(1),2));
fr(1)=sum(data(:,1)<=bx(1));
for i=2:numBinX-1
    tl(i)=mean(data(data(:,1)>bx(i-1) & data(:,1)<=bx(i),2));
    fr(i)=sum((data(:,1)>bx(i-1) & data(:,1)<=bx(i)));
end
tl(numBinX)=mean(data(data(:,1)>bx(numBinX-1),2));
fr(numBinX)=sum(data(:,1)>bx(numBinX-1));

tl=tl(1:end-1);
bx=bx(isfinite(tl));
tl=tl(isfinite(tl));
if isempty(bx)
    C=NaN;
    var=NaN;
    return
end

P = polyfit(bx,tl,1);
yy=bx*P(1)+P(2);
% C=sign(P(1));
var=sign(P(1))*abs(yy(end)-yy(1));
vappG=P(1)/86400;

% var=sum(abs(diff(tl)));

return