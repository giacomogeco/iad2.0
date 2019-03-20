
stz='hrm';

FROM=input('FROM (yyyy-mm-dd)','s');
TO=input('TO (yyyy-mm-dd)','s');
FROM=datenum(FROM,'yyyy-mm-dd');
TO=datenum(TO,'yyyy-mm-dd');
nownames=FROM:TO;

%% Selezione file da aprire

wpath='http://148.251.122.130/PROC/proc/';
trate=[];
txrate=[];
% gm2_logproc_20181122.txt
for i=1:length(nownames)
    filename=[stz,'_logproc_',datestr(nownames(i),'yyyymmdd'),'.txt'];
    fileW=[wpath,filename];
    disp(fileW)
    try
        urlwrite(fileW,'pippo.txt');
        [Tp,txRate] = iad_readProcLogFile('pippo.txt');
        trate=cat(1,trate,Tp);
        txrate=cat(1,txrate,txRate);
    catch
    end

end

%%


F1=figure;set(F1,'Color','w','pos',[15 40 1400 770])
% Pressure
p=plot(trate,txrate,'ok');set(p,'markersize',4,'markerfacecolor','r')
grid on
set(gca,'FontSize',14)



trate=floor(trate*1440)/1440;
j=trate>=FROM & trate<TO;
trate=trate(j);
txrate=txrate(j);

trateT=FROM:1/1440:TO-1/1440;
txrateM=zeros(size(trateT));
[C,IA,IB] = union(trateT,trateM);

% txrateM(IB)=txrate


