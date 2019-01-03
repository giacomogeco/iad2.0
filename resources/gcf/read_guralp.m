function [data]=read_guralp(pathname,filename)

%   [data] = read_guralp (pathname, filename)
%
%Decodifica file GURALP .GCF
%Restituisce una matrice "data" con tutti i canali decodificati, il 
%vettore tempo e la matrice info contenente informazioni sui dati.
%Se pathname e filename sono omessi richiede selezione dei file (selezione
%multipla). La decodifica utilizza gli Station_Parameters creati da
%"Create_Station_Parameters".
%Digitando "eval(cmd)" a seguito dell'esecuzione della routine si estrae
%automaticamente tutte le variabili nel workspace.
%
%Ultima Modifica: 2010/03/15 [R.G.]

%% Inizializzazione Variabili
data=struct;
Ist=struct;
Sps=struct;
Ns=struct;
Idx=struct;

%% Selezione file da aprire
if nargin==0
    Start_Path=pwd;
    [filename, pathname, filterindex] = uigetfile('*.gcf','MultiSelect', 'on','StartPath',Start_Path);
elseif nargin==1
     pathname='';
end

switch class(filename)
    case 'cell'
        nfile=size(filename,2);
    case 'char'
        nfile=size(filename,1);
        tempfile=filename;
        clear filename
        for n=1:nfile
            filename(n)={tempfile(n,:)};
        end
end

%% ESTRAZIONE DATA DAI FILE
for n=1:nfile
    file=char(filename(n));
    disp(strcat('reading:...',file));
    [samples,streamID,sps,ist]=readgcffile(strcat(pathname,file));
    
    if sum(streamID(1)=='1234567890')>0
        streamID(1)='A';
    end
   %     chconv=mcc_dm24_c2uV(streamID);
    chconv=(27./((2^24)/2));
    samples=samples'*chconv;
    ns=length(samples);
    if isfield(data,streamID)==1
        samples=[getfield(data,streamID),samples];
        ist=[getfield(Ist,streamID),ist];
        sps=[getfield(Sps,streamID),sps];
        ns=[getfield(Ns,streamID),ns];
    end
    Ist=setfield(Ist,streamID,ist);
    Sps=setfield(Sps,streamID,sps);
    Ns=setfield(Ns,streamID,ns);
    data=setfield(data,streamID,samples);
end

%% DATA SORTING
field=fieldnames(data);
for n=1:length(field);
    cfield=char(field(n));
    ist=getfield(Ist,cfield);
    if issorted(ist)==0
            disp(strcat(cfield,'...sorting...')) 
            [sist,sidx]=sort(ist);
            ns=getfield(Ns,cfield);
            msidx=[(cumsum(ns)-ns+1)',cumsum(ns)'];
            samples=getfield(data,cfield);
            nsamples=[];
            for nn=1:length(sist)
                nsamples=[nsamples,samples(msidx(sidx(nn),1):msidx(sidx(nn),2))];
            end
            data=setfield(data,cfield,nsamples);
            Ist=setfield(Ist,cfield,sist);
    end
end

%% INTEGRITY and CONTINUITY CHECK
% Integrit�: continuit� del passo di campionamento
% Continuit�: continuit� del tempo di inizio
field=fieldnames(data);
for n=1:length(field);
    cfield=char(field(n));
    ist=getfield(Ist,cfield);
    sps=getfield(Sps,cfield);
    ns=getfield(Ns,cfield);
    ti=ist(1);
    te=ist(end)+ns(end)/sps(1)/86400;
    Ist=setfield(Ist,cfield,[ti,te]);             %... !!! Rinomina Ist !!!
    sps=unique(sps);                              %... !!! Rinomina Sps !!!
    %.......................................... Integrity check
    ichk=size(sps,2)==1;
    if ichk==0
        disp('!!! ERRORE CRITICO, IMPOSSIBILE CONTINUARE !!!' )
        disp('  Rilevato errore nel passo di campionamento  ')
        return
    end
    Sps=setfield(Sps,cfield,sps);
    %.......................................... Continuity check
    cchk=round(diff(ist)*86400*sps);
    tns=sum(ns);
    ens=round((te-ti)*86400*sps);
    nsamples=nan(1,ens);
    samples=getfield(data,cfield);
    idx=cumsum([1,ns(1:end-1)]);
    idx=[idx',(idx+ns-1)'];
    nidx=cumsum([1, round(diff(ist)*sps*86400)]);
    nidx=[nidx',(nidx+ns-1)'];
    for k=1:size(idx,1)
        nsamples(nidx(k,1):nidx(k,2))=samples(idx(k,1):idx(k,2));
    end
    data=setfield(data,cfield,nsamples);
    Ns=setfield(Ns,cfield,length(nsamples)); %... !!! Rinomina Ns !!!
end

%% COSTRINGIMENTO VETTORI
sps=[];
ist=[];
ns=[];
for n=1:length(field)
    cfield=char(field(n));
    ns(n,:)=getfield(Ns,cfield);
    sps=[sps;getfield(Sps,cfield)];
    ist=[ist;getfield(Ist,cfield)]; 
end

%... Limiti MINIMI vettori tempo
ti=max(ist(:,1));
te=min(ist(:,2));
iidx=ti-ist(:,1);
eidx=ist(:,2)-te;
iidx=round(iidx.*sps*86400);
eidx=round(eidx.*sps*86400);

%... Taglio dei dati
for n=1:length(field)
    cfield=char(field(n));
    samples=getfield(data,cfield);
    samples=samples(iidx(n)+1:end-eidx(n));
    data=setfield(data,cfield,samples);
end

%% CREAZIONE DEI VETTORI TEMPO
%.... Numero di campioni
sps=unique(sps);
nsmp=round((te-ti)*sps*86400);

nt=length(sps);
for n=1:nt
    tt=1:nsmp(n);
    tt=tt/sps(n);
    tt=tt/86400;
    tt=tt-tt(1);
    tt=tt+ti;
    switch sps(n)
        case 100
            data=setfield(data,'tt',tt);
        case 4
            data=setfield(data,'mt',tt);
        otherwise
            tname=strcat('t',num2str(n));
            data=setfield(data,tname,tt);
    end
end

%% Rinomina field secondo station_parameters file

j=findstr(file,'_');
stz=char(file(1:j(1)-1));
% disp(strcat('Loading station parameters:...',stz));
% stz
% file_stz=strcat(lower(stz),'.mat');
% a=exist(file_stz,'file');
% if a==2
%     load(file_stz)
% %     disp('ALERT!!!!!!!!!!!')
% %     load gry_2009
%     ch=(station.channel);
% %     ch=ch(5:8)
%     chname=station.chname;
%     gain=station.gain;
%     nch=length(ch);
%     field=(fieldnames(data));
%    
%     for n=1:nch
%         cch=char(ch(n));
%         chi=strmatch(cch,field);
%         if ~isempty(chi)
%             data=setfield(data,char(chname(n)),getfield(data,char(field(chi)))./gain(n));
%             data=rmfield(data,char(field(chi)));
%             Sps=setfield(Sps,char(chname(n)),getfield(Sps,char(field(chi))));
%             Sps=rmfield(Sps,char(field(chi)));
%             Ist=setfield(Ist,char(chname(n)),getfield(Ist,char(field(chi))));
%             Ist=rmfield(Ist,char(field(chi)));
%         else
%             disp(strcat('MISSING CHANNEL:...',ch(n)));
%         end
%     end
%     station.file=file_stz;
% else
%     disp('!!! STATION PARAMETERS NOT AVAILABLES !!!')
%     station.file='File Not Available';
% end

%% Riepilogo Informazioni
% Creazione struttura info
% info=struct();
% info.stz=stz;
% info.file=filename;
% info.path=pathname;
% info.channel=fieldnames(data);
% info.sps=Sps;
% info.t=Ist;
% info.station=station;
% data.info=info;

%% Comando creazione variabili
% stringa di comando per creazione variabili
ch=fieldnames(data);
nch=length(ch);
out='[';
in='(';
for n=1:nch-1
    out=strcat(out,char(ch(n)),',');
    in=strcat(in,'data.',char(ch(n)),',');
end
out=strcat(out,char(ch(n+1)),']');
in=strcat(in,'data.',char(ch(n+1)),')');

cmd=strcat(out,'=deal',in,';');
cmd=strcat(cmd,'clear data');
assignin('caller','cmd',cmd)

return