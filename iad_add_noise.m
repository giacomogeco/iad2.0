function MN=iad_add_noise(M,snr)

noise = awgn(detrend(M),snr,'measured','linear') ;

mx=max(M');mx=repmat(mx',[1 size(M,2)]);
MN=detrend(M)+detrend(noise);
mxn=max(MN');mxn=repmat(mxn',[1 size(MN,2)]);
MN=MN./mxn;
MN=MN.*mx;

return