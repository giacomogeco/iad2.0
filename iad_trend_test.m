Fs = 2;                  % sampling rate (per unit time) 
t = (115:1/Fs:145)';     % time vector sampled at Fs per unit time
t=detections.time(j);
t=86400*(t-t(1));

% Generate a 1D data set with trend forced to 40 units y per unit time: 
y = 40*t + 123*rand(size(t)); % forced trend of 40 units y per second
y=detections.velocity(j);

% Generate a 2D data set  
% Y = y';
% Y(2,:) = y'*3;
% Y(3,:) = 50*rand(size(y'));
% 
% 
% % Generate a 3D data set with artifical trends at the corners: 
% A = rand(3,4,length(t)); % some random data
% A(1,1,:) = 1*t + 5;      % trend (slope) is one unit y per unit time at location 1,1
% A(3,1,:) = 7;            % no trend at location 3,1
% A(3,4,:) = t/2 - 1;      % trend is one half unit per unit time at 3,4
% A(1,4,:) = -3*t + 3;     % trend is negative at location 1,4
 

%           * * * 1D ARRAY EXAMPLES * * * 

plot(t,y,'*') 

iad_trend(y')

return
%%
% Wait a minute! Shouldn't y have a trend (slope) of 40? 
% --Yes. You see, this calculation has assumed that y is sampled at 1 Hz,
% when in fact Fs is 2 Hz. I suppose you could downsample y like this: 

iad_trend(y(1:2:end)')


% But that would mean discarding perfectly good data. We know Fs, so we can
% include it: 
Fs=2
iad_trend(y',Fs)


% That's better! Or just as easily, you could use the time vector in place 
% of the sampling rate: 

iad_trend(y',t)


% What if your data are not sampled at perfectly-spaced intervals in time? 
% Including the corresponding time vector will still work. To show this, let's
% create some data that are not sampled at perfect intervals: 

y2 = y([1:10 12:40 45:end]);
t2 = t([1:10 12:40 45:end]);
plot(t2,y2,'r^'); hold on;
axis([0 150 0 6000])

iad_trend(y2,t2)


% Now let's use the slope and intercept values in old y = m*x + b form. 

[m,b] = iad_trend(y2,t2);
plot(t,m*t+b)
