function [sys,volume, clearance] = remiMdl(mPatient, stepSize)

Weight = mPatient.Weight;
Height = mPatient.Height;
Age = mPatient.Age;
gender = mPatient.gender;

switch gender
case 1
    lbm = (1.1 *Weight) - 128*((Weight/Height).^2);
otherwise
    lbm = (1.07 *Weight) - 148*((Weight/Height).^2);
end

volume = [  5.1-0.0201*(Age-40.0)+0.072*(lbm-55.0)
            9.82-0.0811*(Age-40.0)+0.108*(lbm-55.0)
            5.42]';
clearance = [   2.6-0.0162*(Age-40.0)+0.0191*(lbm-55.0)
                2.05-0.0301*(Age-40.0)
                0.076-0.00113*(Age-40.0)]';
ke0=0.595-0.007*(Age-40.0);

sys = mam2ss(clearance,volume, ke0);
if (nargin==2)
    sys=c2d(sys, stepSize,'zoh');
end
