function ffp=iad_peak_frequency(sts,cps,win,shift)

% Tolgo il microbarom
F=.3;
Wp=F/(cps/2);
[b,a] = cheby1(3,.02,Wp,'low');
s1=filtfilt(b,a,sts);
sts=sts-s1;
[Pxx,Fxx] = pwelch(detrend(sts),win,shift,2^(nextpow2(size(sts,2))),cps,'oneside');
[~,ffp]=max(Pxx);
ffp=Fxx(ffp);
return