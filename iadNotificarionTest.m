% function iadNotificarionTest

testTime=datenum(station.testTime);
if ((now()>testTime)&&(nowOld<testTime))
   sendTestRunning=true;
%        build Ev_Nav,Ev_Cav,Ev_ex
   Ev_Nav=zeros(1,24);
   Ev_Nav(1)=now();
   Ev_Cav=zeros(1,24);
   Ev_Cav(1)=now();
   Ev_Ex=zeros(1,24);
   Ev_Ex(1)=now();
   disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Sending Test Alerts');
   nowOld=now();
end

if (sendTestRunning) %sandro 12122018
   sendTestRunning=false;
%        Ev_Nav=[];
%        Ev_Cav=[];
%        Ev_Ex=[];
   disp('sending test finished. Ev deleted');
end %endSandro 