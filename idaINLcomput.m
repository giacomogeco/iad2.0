function inl=idaINLcomput(data,smp)

% data = n-sensors x m data matrix
% smp = sampling rate

load GLN_GLW_data

FF=[1 7];
win=15*60*smp;
NFFT=2^nextpow2(win);
inl=NaN*zeros(1,size(data,2));
for i=1:size(data,2)
    d=data(:,i);
    trace=idaTapering(detrend(d),smp);
    [p,f] = pwelch(trace,win,win-1,NFFT,smp);
    
    j=find(f>=FF(1) & f<=FF(2));
    linl=p(j);
    nj=length(j);

    jj=find(ff>=FF(1));
    ffr=ff(jj);glwr=glw(jj);
    frange=linspace(FF(1),FF(2),nj);
    glwi=interp1(ffr,glwr,frange);
    
    inl(i)=sum(10*log10(linl')-glwi)/length(glwi);
end


function sig=idaTapering(sig,N)

sig=sig(:,:);
nr=size(sig,2)-N;
H=hanning(N);
H=[H(1:end/2);ones(nr,1);H(end/2+1:end)];
for i=1:size(sig,1)
    sig(i,:)=sig(i,:).*H';
end
return