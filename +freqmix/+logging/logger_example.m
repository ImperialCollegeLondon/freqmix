% File information:
%   version 1.0 (feb 2014)
%   (c) Martin Vogel
%   email: matlab@martin-vogel.info
%
% Revision history:
%   1.0 (feb 2014) initial release version

%% displogger example

odl = logging.displogger();
for i = 1:3
    odl.log(sprintf('sample I outer loop #%i:', i));
    odl.push();
    for j=1:2
        odl.log(sprintf('sample I middle loop #%i:', j));
        odl.push();
        for k=1:3
            odl.log(sprintf('sample I inner loop #%i', k));
        end
        odl.pop();
    end
    odl.pop();
end
odl.delete();

%% textfilelogger example

otl = logging.textfilelogger();
for i = 1:3
    otl.log(sprintf('sample II outer loop #%i:', i));
    otl.push();
    for j=1:2
        otl.log(sprintf('sample II middle loop #%i:', j));
        otl.push();
        for k=1:3
            otl.log(sprintf('sample II inner loop #%i', k));
        end
        otl.pop();
    end
    otl.pop();
end
% save file name before object deletion!!
tfn = otl.filename;
otl.delete();
edit(tfn);

%% duplogger example

otl = textfilelogger();
odil = displogger();
odul = duplogger({otl, odil});
for i = 1:3
    odul.log(sprintf('sample III outer loop #%i:', i));
    odul.push();
    for j=1:2
        odul.log(sprintf('sample III middle loop #%i:', j));
        odul.push();
        for k=1:3
            odul.log(sprintf('sample III inner loop #%i', k));
        end
        odul.pop();
    end
    odul.pop();
end
% save file name before object deletion!!
tfn = otl.filename;
odul.delete();
otl.delete();
odil.delete();
edit(tfn);



