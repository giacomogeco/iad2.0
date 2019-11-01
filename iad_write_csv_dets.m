function iad_write_csv_dets(tt,Det_Av,working_dir,slh,namestz,field)

if ~isempty(Det_Av)
    savedat=Det_Av.data;
    tsave=savedat(:,1);
    ii=find(tsave<tt(1)+60/86400);
    ii=1:length(tsave);
    if ~isempty(ii)
        filename=[working_dir,slh,'detections',slh,...
            namestz,'_',field,slh,...
            namestz,'_',datestr(floor(tt(1)*24)/24,'yyyymmdd'),slh,...
            namestz,'_',datestr(floor(tt(1)*24)/24,'yyyymmdd_HHMMSS'),'.csv'];
        mkdir([working_dir,slh,'detections',slh,...
            namestz,'_',field,slh,...
            namestz,'_',datestr(floor(tt(1)*24)/24,'yyyymmdd')]);
        fid=fopen(filename,'a+');
        savedat=savedat(ii,:);
        for i=1:size(savedat,1)
            for j=1:size(savedat,2)
                fprintf(fid,num2str(savedat(i,j),15));
                fprintf(fid,'\t');
            end
            fprintf(fid,'\n');
        end
        fclose(fid);
    end
end

return
