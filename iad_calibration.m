%% EVENTI GMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nownames=[];
% ConfFileName='conf_GMS_2013.txt';
%% da rivedere per raggrupp. dets xx
% {'CH1','CH2','CH3','CH4'}; OK
% 4 exploions and one controlled avalanche
T={'2014-02-02 07:15:58';'2014-02-02 07:44:58'};
%% GMS Naturale da rivedere {'C1','CH2','CH3','CH4'}
T={'2014-01-16 15:40:00';'2014-01-16 16:00:00'};
%% Alta frequenza no event
% {'CH1','CH2','CH3','CH4'}; OK
%
T={'2014-01-22 12:00:00';'2014-01-22 12:15:00'};
%% Alta frequenza
% {'CH1','CH2','CH3','CH4'}; OK

T={'2014-01-22 13:00:00';'2014-01-22 13:30:00'};
%% Sembra naturale !!! da rivedere  
% {'CH1','CH2','CH3','CH4'}; OK

T={'2014-01-22 14:00:00';'2014-01-22 14:15:00'};
%% % Alta frequenza 
% {'CH1','CH2','CH3','CH4'}; OK

T={'2014-01-22 15:00:00';'2014-01-22 15:15:00'};
%% % Alta frequenza                       
% {'CH1','CH2','CH3','CH4'}; OK

T={'2014-01-22 16:45:00';'2014-01-22 17:00:00'};
%% ???
% {'CH1','CH2','CH3','CH4'}; OK
% 
T={'2014-01-28 16:00:00';'2014-01-28 16:30:00'};
%% ???
% {'CH1','CH2','CH3','CH4'}; OK
% 
T={'2014-02-02 07:15:00';'2014-02-02 07:30:00'};
%% % goms explosion sequence
% {'C1','CH2','CH3','CH4'}; OK !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% 
T={'2013-12-26 06:55:27';'2013-12-26 07:05:27'};
%% ?????
T={'2014-02-14 05:15:00';'2014-02-14 05:30:00'};
% {'C1','CH3','CH4'}; MANCA CH2 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


% NON CI SONO DATI o PARAMETRI SBAGLIATI
nownames=cat(1,nownames,datenum('2014-02-14 05:15:00'):60/86400:datenum('2014-02-14 05:30:00')); % RIMETTERE NEL DATABASE               manca ch2
nownames=cat(1,nownames,datenum('2014-02-14 05:20:16'):60/86400:datenum('2014-02-14 05:30:16')); % goms explosion sequence              manca CH2 sostituito con C2




%% NO1
% 27-Oct-2015 14:30:00 - 27-Oct-2015 14:45:00 primo evento fibra no1




return

%% EVENTI ISC

% 2012-2013 (DA METTERE )
% nownames=datenum('2012-12-10 07:30:00'):60/86400:datenum('2012-12-1007:45:00'); % SEQUENZA ESPLOSIVA CON CONTROLLED 
% nownames=datenum('2012-12-10 11:55:00'):60/86400:datenum('2012-12-10 12:02:00'); % NATURAL


% 2013-2014
% NON CI SONO DATI o PARAMETRI SBAGLIATI (loc='00';net='VS';name='ISC',ip='';chan={'CH1','CH2','CH3','CH4'};
% nownames=datenum('2013-02-06 01:15:00'):60/86400:datenum('2013-02-06 01:44:00'); % VALANGONE
% DATI PRESENTI
% nownames=datenum('2014-01-07 09:15:00'):60/86400:datenum('2014-01-07 09:30:00'); % SEMBRA VALANGA MA NON � {'CH1','CH2','CH3','CH4'}; OK
% nownames=datenum('2014-01-26 09:00:00'):60/86400:datenum('2014-01-26 09:15:00'); % SEQUENZA ESPLOSIVA OK   {'CH1','CH2','CH3','CH4'}; OK  
% nownames=datenum('2014-01-29 14:00:00'):60/86400:datenum('2014-01-2914:15:00'); % SEMBRA VALANGA MA NON �  {'CH1','CH2','CH3','CH4'}; OK 
% nownames=datenum('2014-02-17 07:00:00'):60/86400:datenum('2014-02-17 07:15:00'); % SEQUENZA ESPLOSIVA OK   {'CH1','CH2','CH3','CH4'}; OK 
% nownames=datenum('2014-03-23 12:00:00'):60/86400:datenum('2014-03-23 12:15:00'); % SEQUENZA ESPLOSIVA OK   {'CH1','CH2','CH3','CH4'}; OK 

