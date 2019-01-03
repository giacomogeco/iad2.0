function iad_detections2dB_insert(Mpriv,station,date)


mysql('open', station.dBhost, station.dBuser, station.dBpassword );
mysql('use','W_detections')  
mysql('status')

date=num2str((date-datenum(1970,1,0))*86400);

query=['delete from ',station.name,' where time >= ' ,date];
mysql(query)


for i=1:size(Mpriv,1)
             query=['insert into ',station.name,' values (''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'')'];
             mysql(sprintf(query,...
             num2str((Mpriv(i,1)-datenum(1970,1,0))*86400),...
             num2str(Mpriv(i,2)),...
             num2str(Mpriv(i,3)),...
             num2str(Mpriv(i,4)),...
             num2str(Mpriv(i,5)),...
             num2str(Mpriv(i,6)),...
	     num2str(Mpriv(i,7)),...
	     num2str(Mpriv(i,8)),...
             num2str(Mpriv(i,9))));
  
end
% disp(query)
mysql('closeall')

return
