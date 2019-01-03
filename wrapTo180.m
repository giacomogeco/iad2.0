function lon = wrapTo180(lon)
%wrapTo180 Wrap angle in degrees to [-180 180]
%
%   lonWrapped = wrapTo180(LON) wraps angles in LON, in degrees, to the
%   interval [-180 180] such that 180 maps to 180 and -180 maps to -180.
%   (In general, odd, positive multiples of 180 map to 180 and odd,
%   negative multiples of 180 map to -180.)
%
%   See also wrapTo360, wrapTo2Pi, wrapToPi.

% Copyright 2007-2008 The MathWorks, Inc.

q = (lon < -180) | (180 < lon);
lon(q) = wrapTo360(lon(q) + 180) - 180;

function lon = wrapTo360(lon)
%wrapTo360 Wrap angle in degrees to [0 360]
%
%   lonWrapped = wrapTo360(LON) wraps angles in LON, in degrees, to the
%   interval [0 360] such that zero maps to zero and 360 maps to 360.
%   (In general, positive multiples of 360 map to 360 and negative
%   multiples of 360 map to zero.)
%
%   See also wrapTo180, wrapToPi, wrapTo2Pi.

% Copyright 2007-2008 The MathWorks, Inc.

positiveInput = (lon > 0);
lon = mod(lon, 360);
lon((lon == 0) & positiveInput) = 360;

