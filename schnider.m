function [sys, volume, clearance] = schnider(mPatient, stepSize)
Age = mPatient.Age;
Weight = mPatient.Weight;
Height = mPatient.Height;
gender = mPatient.gender;

th =[ 4.27;
18.9;
238.;
1.89;
1.29;
.836;
-.391;
.0456;
-.0681;
.0264;
-.024
0.316];

tpeak = 1.6;
ike0 = [.1;2];
t1=0:.001:4;
u=zeros(size(t1));
u(1)=1;
    
switch gender
    case 1
        lbm = (1.1 *Weight) - 128*((Weight/Height).^2);
    otherwise
        lbm = (1.07 *Weight) - 148*((Weight/Height).^2);
end

volume = [th(1) th(2)+th(7)*(Age-53) th(3)];
clearance=[	th(4)+(Weight-77)*th(8)+(lbm-59)*th(9)+(Height-177)*th(10)
    th(5) + th(11)*(Age-53)
    th(6)]';

options = optimset('Display','off'); % Turn off Display
ke0 = fzero(@(tke0) getKe0(clearance,volume,tke0,tpeak, u, t1), ike0, options);

sys = mam2ss_2(clearance,volume,ke0);
if (nargin==3)
    sys=c2d(sys, stepSize,'zoh');
end
end