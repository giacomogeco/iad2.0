function [samples,streamID,sps,ist] = readgcffile2(filename, streamID)
% ReadGCFFile
%
%   [SAMPLES,STREAMID,SPS,IST] = READGCFFILE(filename, streamID)
%
%   Reads in the specified GCF formatted file, and returns:
%     Samples - an array of all samples in file
%     Stream ID (string up to 6 characters)
%     SPS - sample rate of data in SAMPLES
%     IST - start time of data, as serial date number
%
%   example:
%   [samples,streamid,sps,ist]=readgcffile('test.gcf');
%   streams=readgcffile('test.gcf','list');
%   [samples,streamid,sps,ist]=readgcffile('test.gcf','TESTZ2');
%
%   M. McGowan, Guralp Systems Ltd. email: mmcgowan@guralp.com
%   2004/09/23 M. McGowan (mmcgowan@guralp.com)
%     Added support for multiple streams in a GCF file, where the user can
%     specify which stream ID they want to extract. See 'streamID' input
%     parameter. This is optional - if ommited, it will use the first
%     streamID it finds. Note that it IS case-sensitive - all IDs should be
%     uppercase.
%     [SAMPLES,STREAMID,SPS,IST] = READGCFFILE(FILENAME, 'list')
%     Specifying 'list' for the streamID will return a cell array of strings,
%     one string for each streamID found in the file. This can be used to
%     iterate through each streamID in the file to read all the data contained
%     in the file. For an example, see the 'plot' option.
%     READGCFFILE(FILENAME, 'plot')
%     The 'plot' option is an example of reading all streams in a file and
%     displaying them.
%
%     If the specified stream is a status stream, 'samples' will return an
%     array of numbers which can be converted into text using
%     char(samples').
%
%     Modified code to cope with gaps, overlaps and out-of-sequence data.
%     Uses the first block timestamp as a reference, so will not return any
%     data in the file that has a timestamp older than the first
%     block in file.
%     In the case of an overlap, the data found further through the file will
%     overwrite the data read earlier.
%     Where a gap exists, it will be padded with sample values of NaN.
%

if exist('streamID') && strcmp(streamID,'plot'),
  plotfile(filename);
  return
end

fid = fopen(filename,'r','ieee-be');
if fid==-1,
    [p,n,e]=fileparts(filename);
    if ~strcmpi(e,'.gcf'),
        fname2 = [filename,'.gcf'];
        fid = fopen(fname2,'r','ieee-be');
    end
end
if fid==-1,
    error(['Unable to open file "',filename,'"']);
    return; 
end

if exist('streamID') && strcmp(streamID,'list'),
  samples=getstreamidlist(fid);
  fclose(fid);
  return
end

if exist('streamID'),
  streamID = base2dec(streamID,36); % faster to compare numbers than strings
end
% to read the file, first create the array to handle the entire file's samples,
% then read in block by block, copying into the array in the correct place.
% This is MUCH faster than adding on to the end of an array each block.
sampcount=samplesinfile(fid);
samples=NaN*ones(sampcount,1);
sampcount=1;

onesec = datenum(0,0,0,0,0,1);
onemsec = onesec/1000;

while ~feof(fid)
  if ~exist('streamID'), % no stream ID has been pre-specified, so use the first one we find
    [blksamples,blksysID,blkstreamID,blksps,blkist] = readgcfblock(fid);
    streamID = blkstreamID;
  else
    [blksamples,blksysID,blkstreamID,blksps,blkist] = readgcfblock(fid,streamID);
  end
  if ~exist('sps'),
    sps = blksps;
  end
  if ~exist('ist'),
    ist = blkist;
  end
  if (sps>0) && (length(blksamples)>0),
    if exist('expectedtime'),
      if expectedtime+onemsec < blkist,
        disp(['Warning: Gap in ',dec2base(blkstreamID,36),', Expected ',datestr(expectedtime,31),', found ',datestr(blkist,31)]);
      end
      if blkist+onemsec < expectedtime,
        disp(['Warning: Overlap in ',dec2base(blkstreamID,36),', Expected ',datestr(expectedtime,31),', found ',datestr(blkist,31)]);
      end
    end
    secs = length(blksamples)/sps;
    expectedtime = blkist + secs*onesec;
  end
  % Copy the samples into the pre-prepared array
  if blksps>0,
    ofs = round((blkist-ist)*blksps/onesec);
  else
    ofs = sampcount;
  end
  endofs = ofs + length(blksamples);
  while endofs > length(samples), %if array not big enough, expand until it is
    samples = [samples;NaN*ones(length(samples),1)];
  end
  
  if ofs>=0,
    samples(ofs+1:endofs)=blksamples;
    sampcount = max([sampcount,endofs]);
  else
    disp(['Warning: discarding data from',dec2base(blkstreamID,36),' as it is before the start of file. FileStart=',datestr(ist,31),' BlockStart=',datestr(blkist,31)]);
  end
end
fclose(fid);
samples=samples(1:sampcount);     % trim samples array to actual length
streamID = dec2base(streamID,36); % convert numerical streamID back to a string



function [samps,sysID,streamID,sps,ist] = readgcfblock(fid,nstrid)
samps=[];
sps=0;
ist=0;
sysID = fread(fid,1,'uint32');
streamID = fread(fid,1,'uint32');
if exist('nstrid'), % if we have specified a particular ID, keep searching until we find it
  while ~feof(fid) && (nstrid ~= streamID),
    fseek(fid,1016,'cof');
    sysID = fread(fid,1,'uint32');
    streamID = fread(fid,1,'uint32');
  end
end
if feof(fid)
  return 
end

date = fread(fid,1,'ubit15');
time = fread(fid,1,'ubit17');
reserved = fread(fid,1,'uint8');
sps = fread(fid,1,'uint8');
compressioncode = fread(fid,1,'uint8');
numrecords = fread(fid,1,'uint8');

% Convert GCF coded time to Matlab coded time
hours = floor(time / 3600);
mins = rem(time,3600);
ist = datenum(1989,11,17, hours, floor(mins / 60), rem(mins,60) ) + date;

if (sps ~= 0),
   fic = fread(fid,1,'int32');
   switch compressioncode
   case 1,
      diffs = fread(fid,numrecords,'int32');
   case 2,
      diffs = fread(fid,numrecords*2,'int16');
   case 4,
      diffs = fread(fid,numrecords*4,'int8');
   end
   ric = fread(fid,1,'int32',1000-numrecords*4);
   diffs(1) = fic;
   samps = cumsum(diffs);
else
   samps = char(fread(fid,numrecords*4,[num2str(numrecords*4),'*uchar=>uchar'],1008-numrecords*4)');
end




function samps = samplesinfile(fid)
fseek(fid,14,'bof');
% Read number-of-records and compression-code of every block into an array
nr = fread(fid,'uint16',1022);
% Separate number-of-records and compression-code from the 16 bit value read
cc = bitshift(nr,-8);
nr = bitand(nr,255);
% sum up the number of samples in each block
samps=sum(cc.*nr);
frewind(fid);



function list = getstreamidlist(fid)
fseek(fid,4,'bof');
list=fread(fid,'uint32',1020);
list=dec2base(list,36);
list=unique(cellstr(list));


function plotfile(fname)
% EXAMPLE SCRIPT TO READ AND PLOT ALL STREAMS IN A GCF FILE
list=readgcffile(fname,'list');
for i = 1:length(list),
  [samples,id,sps]=readgcffile(fname,list{i});
  subplot(length(list),1,i);
  if sps>0,
    plot((0:1/sps:(length(samples)-1)/sps),samples);
  else
    disp(char(samples'));
  end
  ylabel(id);
end