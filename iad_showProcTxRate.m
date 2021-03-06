clear all,close all
% stz='lvn'; %... 19 Nov - 15 Jul
% stz='no2'; %... 11 Nov - 01 Jul
stz='no1'; %... 27 Nov - 24 May

FROM=input('FROM (yyyy-mm-dd)','s');
TO=input('TO (yyyy-mm-dd)','s');
FROM=datenum(FROM,'yyyy-mm-dd');
TO=datenum(TO,'yyyy-mm-dd');
nownames=FROM:TO;
%  Selezione file da aprire
% wpath='http://148.251.122.130/PROC/proc/';
wpath='~/Downloads/proc/';
trate=[];
txrate=[];
% gm2_logproc_20181122.txt
for i=1:length(nownames)
    filename=[stz,'_logproc_',datestr(nownames(i),'yyyymmdd'),'.txt'];
    fileW=[wpath,filename];
    disp(fileW)
    try
%         urlwrite(fileW,'pippo.txt');
%         [Tp,txRate] = iad_readProcLogFile('pippo.txt');
        [Tp,txRate] = iad_readProcLogFile(fileW);
        trate=cat(1,trate,Tp);
        txrate=cat(1,txrate,txRate);
    catch
    end

end

j1 = txrate>= 80;
j2 = txrate< 80;
txrate(j1) = 1;
txrate(j2) = 0;
trateI = round(trate*1440)/1440;
j=trateI >= FROM & trateI < TO;
trateI=trateI(j);
txrateI=txrate(j);

trateT=FROM:1/1440:TO-1/1440;
txrateM=zeros(size(trateT));
for i=1:length(trateT)-1
    j1 = find(trateI == trateT(i));
%     j2 = find(trateI == trateT(i+1));

    if isempty(j1) 
        j2 = find(trateI == trateT(i+1));
        if isempty(j2)
            txrateM(i)=0;
        else
            txrateM(i)=txrateI(j2(1));
        end
    else
        txrateM(i)=txrateI(j1(1));
    end
end     
return
%%
F1=figure;set(F1,'Color','w','pos',[15 40 1400 770])
p=plot(trateT,txrateM,'sk');
set(p,'markersize',4,'markerfacecolor','r')
grid on
set(gca,'FontSize',14,'xlim',[FROM TO])
mean(txrateM)

%%
clear all
f1 = load('IDA-LVN-2018-2019-TxRate');
% f1.txrateM(f1.txrateM == 999)=100;
f2 = load('IDA-NO1-2018-2019-TxRate');
% f2.txrateM(f2.txrateM == 999)=100;
f3 = load('IDA-NO2-2018-2019-TxRate');
% f3.txrateM(f3.txrateM == 999)=100;

F1=figure;set(F1,'Color','w','pos',[15 40 1400 770])
ax(1)=subplot(311);
p=plot(f1.trateT,f1.txrateM,'sk');
set(p,'markersize',2,'markerfacecolor','r')
grid on
ax(2)=subplot(312);
p=plot(f2.trateT,f2.txrateM,'sk');
set(p,'markersize',2,'markerfacecolor','r')
grid on
ax(3)=subplot(313);
p=plot(f3.trateT,f3.txrateM,'sk');
set(p,'markersize',2,'markerfacecolor','r')
grid on
set(ax,'FontSize',14)
linkaxes(ax,'x')

%%


first = datenum(2018,11,1);
last = datenum(2019,5,31,23,0,0);
period=1/24;
bins = period*(floor(first/period):ceil(last/period));
time=bins(1:end)';
[LVNrate, loc] = histc(f1.trateT', bins);
LVNrate = accumarray(loc,f1.txrateM,size(time),@mean,NaN);
[NO1rate, loc] = histc(f2.trateT', bins);
NO1rate = accumarray(loc,f2.txrateM,size(time),@mean,NaN);
[NO2rate, loc] = histc(f3.trateT', bins);
NO2rate = accumarray(loc,f3.txrateM,size(time),@mean,NaN);


F1=figure;set(F1,'Color','w','pos',[15 40 1400 770])
ax(1)=subplot(311);
p=plot(time,LVNrate*100,'sk');
set(p,'markersize',2,'markerfacecolor','r')
grid on
ax(2)=subplot(312);
p=plot(time,NO1rate*100,'ks');
set(p,'markersize',2,'markerfacecolor','r')
grid on
ax(3)=subplot(313);
p=plot(time,NO2rate*100,'ks');
set(p,'markersize',2,'markerfacecolor','r')
grid on
set(ax,'FontSize',14)
linkaxes(ax,'x')

