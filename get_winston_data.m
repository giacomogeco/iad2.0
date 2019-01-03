function [data,w]=get_winston_data(stz,channels,network,to,tend,ip,port,location)

if nargin<6,
    ip='127.0.0.1';
    port=16088;
    location='--';
end

ds=datasource('winston',ip,port);
obj=scnlobject(stz,channels,network,location);
w=waveform(ds,obj,to,tend);

if isempty(w),
    disp('isempty w')
    data=[];
    return
end
w=fix_data_length(w);
% w=fillgaps(w,[]);
yy=get(w,'data');
tt=get(w,'timevector');

% if length(w)~=4,
%     data=[];
%      disp('not 4 channels -->no data')
%     return
% end

% yy=cell2mat(yy');
chname=get(w,'channel');
if ~iscell(chname),
    
    data=[];
    disp('not iscell -- no data')
    return
end

% to=get(w,'start');
smp=get(w,'freq');
data.tt=tt{1};

for ich=1:length(w),
  eval(['data.',chname{ich},'=yy{',num2str(ich),'};']);
  eval(['data.',chname{ich},'(data.',chname{ich},'==0)=NaN;']);
end

treq=linspace(to,tend,round((tend-to)*86400*smp(1)))'; %intervallo di tempo richiesto

if length(treq)>length(data.tt),
    for ich=1:length(w),
         eval(['data.',chname{ich},'=interp1(data.tt,data.',chname{ich},',treq,''linear'',NaN);']);
    end
    data.tt=treq;
end

return
