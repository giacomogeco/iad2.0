function [data,tim]=readiadmatfile(to,tend,ip,namestz)

% to=input('start time (yyyy-mm-dd_HH:MM)','s');
% tend=input('end time (yyyy-mm-dd_HH:MM)','s');
% to=datenum(to,'yyyy-mm-dd_HH:MM');
% tend=datenum(tend,'yyyy-mm-dd_HH:MM');

t15=to:15/1440:tend;

data=[];
tim=[];
% ip='http://85.10.199.200/matfiles/';
% ip='http://148.251.122.130/matfiles/';

%%.... LETTURA FILES
for i=1:length(t15)
    
%     http://85.10.199.200/matfiles/GMS/2016/GMS_20160113/GMS_20160113_000000.mat
    file=[ip,upper(namestz),'/',datestr(t15(i),'yyyy'),'/',...
        upper(namestz),'_',datestr(t15(i),'yyyymmdd'),'/',...
        upper(namestz),'_',datestr(t15(i),'yyyymmdd_HHMMSS'),'.mat'];
        
%         disp(file)
        try
            urlwrite(file,'pippo.mat');
            a=load('pippo.mat');
            a=a.data;
            if i==1,
                tim=a.tt';
            else
                tim=cat(2,tim,a.tt');
            end
            a=rmfield(a,'tt');
            ch=fieldnames(a);
            for ii=1:length(ch)
                sig=a.(char(ch(ii)));
                
                if i==1,
                    data.(['CH',num2str(ii)])=sig';
                else
                    data.(['CH',num2str(ii)])=cat(2,data.(['m',num2str(ii)]),sig');
                end
            end
            
            
            
        catch
            disp(['...file not found'])
            continue
        end
        
        
end


return
