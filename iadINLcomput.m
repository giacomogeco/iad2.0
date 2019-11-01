function inl=iadINLcomput(t1,station,ConfFileName)

global working_dir slh net
load GLN_GLW_data

% disp(['Loading ',upper(namestz),' data From:',datestr(to,0),' To: ',datestr(tend,0)])
%
namestz=station.name;
switch namestz
    case {'lvn','gm2','gms','gtn','rsp','hrm','lpb','rpc'}
        data=iad_readWYACserverdata(station,upper(namestz),t1-15/1440,t1);
    otherwise
        data=iad_read_ws_data(ConfFileName,working_dir,slh,net,t1-15/1440,t1,[],[]);
end
%%

FF=[1 7];

win=15*60*station.smp(1);
NFFT=2^nextpow2(win);
inl=NaN*zeros(1,length(station.smp));
for i=1:length(station.smp)
    disp((['CH',num2str(i)]))
    d=data.(['CH',num2str(i)]);
    trace=iad_tapering(detrend(d'),station.smp(1));
    [p,f] = pwelch(trace,win,win-1,NFFT,station.smp(1));
    
    j=find(f>=FF(1) & f<=FF(2));
    linl=p(j);
    nj=length(j);

    jj=find(ff>=FF(1));
    ffr=ff(jj);glwr=glw(jj);
    frange=linspace(FF(1),FF(2),nj);
    glwi=interp1(ffr,glwr,frange);
    
    inl(i)=sum(10*log10(linl')-glwi)/length(glwi);
    
    Pi(i,:)=linl;
    
%     figure,semilogx(f,10*log10(p))
%     hold on
%     semilogx(frange,10*log10(linl'))
%     plot(frange,glwi)

end

for i=1:length(station.smp)
    for j=i+1:length(station.smp)       
        Pw(i,j)=sum(Pi(i,:)-Pi(j,:));
    end
end
Pw=sum(sum(Pw));
    
        


return