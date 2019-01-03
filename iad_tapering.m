function sig=iad_tapering(sig,N)

%>>> sig= vettore riga

sig=sig(:,:);
nr=size(sig,2)-N;
H=hanning(N);
H=[H(1:end/2);ones(nr,1);H(end/2+1:end)];
% size(H)
for i=1:size(sig,1)
    sig(i,:)=sig(i,:).*H';
end
                                   
return