function [t,x,hdr] = read_sac(filename)
%   [USAGE] 
%   [t,x,hdr] = read_sac('filename');

%   [INPUTS] 
%   filename:  filename ... the filename/path of the SAC file. 
% 
%   [OUTPUTS]
%   t:   sac function time axis  
%   x:   sac function data
%   hdr: a structure containing header information
%        hdr.data
%        hdr.times
%        hdr.station
%        hdr.event
%        hdr.eventstation
%        hdr.user
%        hdr.info
%        hdr.response
%
%-------------------------------------------------------------------------- 
%   Last time modified: Sep, 25, 2015
%-------------------------------------------------------------------------- 
% check that the file exists
if nargin <1, error('ERROR: filename was not given.'); end

% check that the filename/path is a string
assert(ischar(filename), ...
    'ERROR: read_sac only accepts string filenames.');
%--------------------------------------------------------------------------
% load the sac file
fid=fopen(filename, 'rb');

if (fid==-1)
  disp('can not open input data file format, press CTRL-C to exit \n');
  pause
end

head1=fread(fid, [5, 14], 'float32');
head2=fread(fid, [5, 8], 'int32');
head3=fread(fid, [24, 8], 'char');
head1=head1'; head2=head2'; head3=head3';
npts=head2(2, 5);
x=fread(fid, npts, 'float32');
fclose(fid);
%--------------------------------------------------------------------------
% Get the headers   
% hdr.data
      hdr.data.npts = head2(2,5);
      hdr.data.scale = head1(1,4);
      
% hdr.times
      hdr.times.delta   = head1(1,1); % time increment
      hdr.times.b   = head1(2,1); % begin time
      hdr.times.e   = head1(2,2); % end time
      hdr.times.o   = head1(2,3); % event origin marker
      hdr.times.a   = head1(2,4); % first arrival (P) marker
      hdr.times.t0  = head1(3,1); % time pick 0 (S) marker
      hdr.times.t1  = head1(3,2); % user-defined time pick 1
      hdr.times.t2  = head1(3,3); % user-defined time pick 2
      hdr.times.t3  = head1(3,4); % user-defined time pick 3
      hdr.times.t4  = head1(3,5); % user-defined time pick 4
      hdr.times.t5  = head1(4,1); % user-defined time pick 5
      hdr.times.t6  = head1(4,2); % user-defined time pick 6
      hdr.times.t7  = head1(4,3); % user-defined time pick 7
      hdr.times.t8  = head1(4,4); % user-defined time pick 8
      hdr.times.t9  = head1(4,5); % user-defined time pick 9
      hdr.times.k0  = char(head3(2,9:16)); % event origin time string
      hdr.times.ka  = char(head3(2,17:24)); % first arrival time string
      hdr.times.kt0 = char(head3(3,1:8)); % user-defined pick string 0
      hdr.times.kt1 = char(head3(3,9:16)); % user-defined pick string 1
      hdr.times.kt2 = char(head3(3,17:24)); % user-defined pick string 2
      hdr.times.kt3 = char(head3(4,1:8)); % user-defined pick string 3
      hdr.times.kt4 = char(head3(4,9:16)); % user-defined pick string 4
      hdr.times.kt5 = char(head3(4,17:24)); % user-defined pick string 5
      hdr.times.kt6 = char(head3(5,1:8)); % user-defined pick string 6
      hdr.times.kt7 = char(head3(5,9:16)); % user-defined pick string 7
      hdr.times.kt8 = char(head3(5,17:24)); % user-defined pick string 8
      hdr.times.kt9 = char(head3(6,1:8)); % user-defined pick string 9
      hdr.times.kf = char(head3(6,9:16)); % end of event time string

% hdr.event
      hdr.event.evla = head1(8,1); % event latitude
      hdr.event.evlo = head1(8,2); % event longitude
      hdr.event.evel = head1(8,3); % event elevation 
      hdr.event.evdp = head1(8,4); % event depth
      hdr.event.nzyear = head2(1,1); % GMT time year
      hdr.event.nzjday = head2(1,2); % event time year(Julian)
      hdr.event.nzhour = head2(1,3); % event time hour
      hdr.event.nzmin = head2(1,4); % event time minute
      hdr.event.nzsec = head2(1,5); % event time second
      hdr.event.nzmsec = head2(2,1); % event time millisecond
      hdr.event.kevnm = char(head3(1,9:24)); % event name
      hdr.event.mag = head1(8,5); % event magnitude
      hdr.event.imagtyp = []; % magnitude type
      hdr.event.imagsrc = []; % source of magnitude information

% hdr.station
      hdr.station.stla = head1(7,2); % station latitude
      hdr.station.stlo = head1(7,3); % station longitude
      hdr.station.stel = head1(7,4); % station elevation
      hdr.station.stdp = head1(7,5); % station depth 
      hdr.station.cmpaz = head1(12,3); % component azimuth relative to north
      hdr.station.cmpinc = head1(12,4); % component "incidence angle" reletive to the vertical
      hdr.station.kstnm = char(head3(1,1:8)); % station name
      hdr.stations.kcmpnm = char(head3(7,17:24)); % channel name
      hdr.stations.knetwk = char(head3(8,1:8)); % network name

% hdr.evntstation
      hdr.evsta.dist = head1(11,1); % source receiver distance (km)
      hdr.evsta.az = head1(11,2); % event-station azimuth
      hdr.evsta.baz = head1(11,3); % event-station back azimuth
      hdr.evsta.gcarc = head1(11,4); % great circle distance (deg)
    
% hdr.user
      hdr.user.data = [head1(9,1:5),head1(10,1:5)]; % user-defined variable
      hdr.user.label = [char(head3(6,17:24)),char(head3(7,1:8)),char(head3(7,9:16))];

% hdr.info
      hdr.info.iftype = head2(4,1); % type of file
      hdr.info.idep = head2(4,2); % type of independent variable
      hdr.info.iztype = head2(4,3); % reference time equivalence
      hdr.info.iinst = head2(4,5); % type of recording instrument
      hdr.info.istreg = head2(5,1); % station geographic region
      hdr.info.ievreg = head2(5,2); % event geographic region 
      hdr.info.ievtyp = head2(5,3); % type of event
      hdr.info.iqual = head2(5,4); % quality of data 
      hdr.info.isynth = head2(5,5); % synthetic data flag 

% hdr.response
      hdr.response = [head1(5,2:5),head1(6,1:5),head1(7,1)]; % intrument response parameters

t = [hdr.times.b:hdr.times.delta:(hdr.data.npts-1)*hdr.times.delta+hdr.times.b]';
