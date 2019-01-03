
t = 1:length(noisyECG_withTrend);
[p,s,mu] = polyfit((1:numel(noisyECG_withTrend))',noisyECG_withTrend,6);
f_y = polyval(p,(1:numel(noisyECG_withTrend))',[],mu);

ECG_data = noisyECG_withTrend - f_y;        % Detrend data

figure
plot(t,ECG_data)
grid on
ax = axis;
axis([ax(1:2) -1.2 1.2])
title('Detrended ECG Signal')
xlabel('Samples')
ylabel('Voltage(mV)')
legend('Detrended ECG Signal')

%%

[~,locs_Rwave] = findpeaks(ECG_data,'MinPeakHeight',0.1,...
                                    'MinPeakDistance',50*2);
                                
%%
hold on
plot(locs_Rwave,ECG_data(locs_Rwave),'rv','MarkerFaceColor','r')

%%

% sig=filtrax(noisyECG_withTrend,10,20,50);
sig=noisyECG_withTrend;
clear Sia
for i=1:length(sig)-100
     
    
    [RR,ZZ]=corrcoef(sig(i:i+100-1),rp1_wf_50); %... inserito il 16 Gen 2017
       	Sia(i)=RR(2,1);
end


%%

[~,locs_Rwave] = findpeaks(Sia,'MinPeakHeight',0.7,...
                                    'MinPeakDistance',50*2);
                                
%%
t=1:length(sig);
figure
plot(t,sig,'k'),grid on
hold on

plot(t(locs_Rwave),sig(locs_Rwave),'rv','MarkerFaceColor','r')