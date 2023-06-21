function [sys,volume, clearance] = remiElev(mPatient, stepSize)
% https://doi.org/10.1097/ALN.0000000000001634

Weight = mPatient.Weight;
Height = mPatient.Height;
Age = mPatient.Age;
gender = mPatient.gender;

mPatientRef = patBuilder(35,70,170,1); %70-kg, 35-year-old, 170-cm male patient.

th = [2.88,-0.00554, -0.00327, -0.0315, 0.47,-0.026];

Vref = [5.81, 8.82, 5.03];
Clref = [2.58,1.72,.124];

    function f = alsallami(mPatient)
        BMI = mPatient.Weight/((mPatient.Height/100)^2);
        if mPatient.gender
            f = (0.88 + (1-0.88)/(1+((mPatient.Age/13.4)^-12.7)))*((9270*mPatient.Weight)/(6680 + 216*BMI));
        else
            f = (1.11 + (1-1.11)/(1+((mPatient.Age/7.1)^-1.1)))*((9270*mPatient.Weight)/(8780 + 244*BMI));
        end
    end

    function f = sigmoid(x, E50, lambda)
        f = (x.^lambda)./(x.^lambda + E50.^lambda);
    end

    function f = aging(x, age)
        f = exp(x*(age - 35));
    end

SIZE = alsallami(mPatient)/alsallami(mPatientRef);

KMAT = sigmoid(Weight, th(1), 2);
if mPatient.gender
    KSEX = 1;
else
    KSEX = 1 + th(5)* sigmoid(Age, 12, 6)*(1-sigmoid(Age, 45, 6));
end



volume = [ Vref(1) * SIZE * aging(th(2),Age)
    Vref(2) * SIZE * aging(th(3),Age) * KSEX
    Vref(3) * SIZE * aging(th(4),Age) * exp(th(6)*(Weight - 70))]';
clearance = [ Clref(1) * SIZE^0.75 * (KMAT/sigmoid(mPatientRef.Weight, th(1), 2)) * KSEX * aging(th(3),Age)
Clref(2) * (volume(2)/Vref(2))^0.75 * aging(th(2),Age) * KSEX
Clref(3) * (volume(3)/Vref(3))^0.75 * aging(th(2),Age) * KSEX]';

thk = -0.0289;
ke0ref = 1.09;
ke0 = ke0ref*aging(thk(1),Age);

sys = mam2ss(clearance,volume, ke0);
if (nargin==2)
    sys=c2d(sys, stepSize,'zoh');
end
end