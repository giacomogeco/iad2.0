function data=iad_read_gcffile(namestz,t15,gcfstreamID,gcfGain,station)
         
% global stzID

% to=input('start time (yyyy-mm-dd_HH:MM)','s');
% tend=input('end time (yyyy-mm-dd_HH:MM)','s');
% to=datenum(to,'yyyy-mm-dd_HH:MM');
% tend=datenum(tend,'yyyy-mm-dd_HH:MM');

% t15=to:15/1440:tend;

% ip='http://85.10.199.200/DATA/';
ip='http://148.251.122.130/DATA/';

% http://85.10.199.200/DATA/gm2/2016/gm2_20160113/gm2_20160113_0000a480e4.gcf
%%.... LETTURA FILES
for i=1:length(t15)
%     load(strcat(lower(namestz),'.mat'))
    for is=1:length(gcfstreamID),
%         index=strmatch(lower(stzID(is)),station.chname);
        file=[ip,lower(namestz),'/',datestr(t15(i),'yyyy'),'/',...
        lower(namestz),'_',datestr(t15(i),'yyyymmdd'),'/',...
        lower(namestz),'_',datestr(t15(i),'yyyymmdd_HHMM'),lower(char(gcfstreamID(is))),'.gcf'];
        disp(file)
        urlwrite(file,[lower(namestz),'_',datestr(t15(i),'yyyymmdd_HHMM'),lower(char(gcfstreamID(is))),'.gcf']);
        filename(is,:)=[lower(namestz),'_',datestr(t15(i),'yyyymmdd_HHMM'),lower(char(gcfstreamID(is))),'.gcf'];
    end
    filename=cellstr(filename)';
    
%     http://85.10.199.200/matfiles/GMS/2016/GMS_20160113/GMS_20160113_000000.mat
%     try
        a=read_guralp([pwd,'/'],filename);
        
        if i==1,
            tim=a.tt;
        else
            tim=cat(2,tim,a.tt);
        end
%         a=rmfield(a,'tt');
%         a=rmfield(a,'info');
%         ch=fieldnames(a);
%         keyboard
        
        for ii=1:length(gcfstreamID)
            delete(char(filename(ii)))
            sID=char(gcfstreamID(ii));
            if sum(sID(1)=='1234567890')>0
                sID(1)='A';
            end
            sig=a.(upper(sID));
%             sig=a.((sID));
           
            if i==1,
                data.(char(station.wschannels(ii)))=sig/gcfGain(ii);
            else
                data.(char(station.wschannels(ii)))=cat(2,data.(char(station.wschannels(ii))),sig/gcfGain(ii));
            end
        end
        clear filename
        

%     catch
%         disp(['...file not found'])
%         continue
%     end
        
        
end
data.tt=tim;
data = structfun(@(x) ( x' ), data, 'UniformOutput', false);
return