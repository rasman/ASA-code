function data_f=  dose_dist
% Plot variability of dose distribtion for standardized dosing of propofol
% and remifentanil
% p = gcp('nocreate'); % If no pool, do not create new one.
% if isempty(p)
%     parpool(2);
% end
datOut{2,1} = [];

mPatient0 = patBuilder(50,70,170,1);
sys_ele0 =  eleveld18(mPatient0);
sys_rem0 = remiElev(mPatient0);

[y_ele,t] = impulse(sys_ele0,6);
dat_ele = lsiminfo(y_ele,t);

[y_rem,t] = impulse(sys_rem0,6);
dat_rem = lsiminfo(y_rem,t);

goal_ele = 150*dat_ele.Max;
goal_rem = 50*dat_rem.Max;
Weight_range = 40:5:150;
for ge = 1:2
    t1=0:.001:4;
    u=zeros(size(t1));
    u(1)=1;
    %for ge = 1:2
    gender = ge -1;
    count = 0;
    result_mat = zeros(3289,7);
    for Weight = Weight_range
        for Age = 20:5:80
            for Height = 150:5:200
                count = count+1;
                switch gender
                    case 1
                        lbm = (1.1 *Weight) - 128*((Weight/Height).^2);
                    otherwise
                        lbm = (1.07 *Weight) - 148*((Weight/Height).^2);
                end

                mPatient = patBuilder( Age,Weight,Height,gender);
                sys_ele =  eleveld18(mPatient);
                sys_rem = remiElev(mPatient);
                [y_ele,t] = impulse(sys_ele,6);
                dat_ele = lsiminfo(y_ele,t);

                [y_rem,t] = impulse(sys_rem,6);
                dat_rem = lsiminfo(y_rem,t);

                result_mat(count,:) = [gender, Weight, Age, Height, lbm, goal_ele/dat_ele.Max, goal_rem/dat_rem.Max];
            end
        end
    end
    datOut{ge,1} = result_mat;
end

data_f = cell2mat(datOut);

weight_plot = 20:max(data_f(:,5));
val1 = data_f(:,5)>20;

h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
set(h,'Position',[100 100 1200 600])
filename = 'dose_weight.gif';

subplot(2,2,1)
title('Propofol, Ref Dose 150 mg (70 kg, 170 cm, Male)')
hold on;
xlabel('Total Body Weight (kg)')
ylabel('Dose (mg)')
plot(data_f(:,2), data_f(:,6),'.')
plot(Weight_range, [Weight_range*2;Weight_range*2.5],'r-.')
xlim([40 150])
ylim([80 330])

subplot(2,2,3)

hold on;
xlabel('Lean Body Weight (kg)')
ylabel('Dose (mg)')
plot(data_f(val1,5), data_f(val1,6),'.')
plot(weight_plot, [weight_plot*2;weight_plot*2.5],'r-.')
xlim([20 80])
ylim([80 330])


subplot(2,2,2)
title('Remifentanil, Ref Dose 50 mcg (70 kg, 170 cm, Male)')
hold on;
xlabel('Total Body Weight (kg)')
ylabel('Dose (mcg)')
plot(data_f(:,2), data_f(:,7),'.')
plot(Weight_range, [Weight_range*.5;Weight_range],'r-.')
xlim([40 150])
ylim([20 110])

subplot(2,2,4)

hold on;
xlabel('Lean Body Weight (kg)')
ylabel('Dose (mcg)')
val1 = data_f(:,5)>20;
plot(data_f(val1,5), data_f(val1,7),'.')
plot(weight_plot, [weight_plot*.5;weight_plot],'r-.')
xlim([20 80])
ylim([20 110])

frame = getframe(h);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,filename,'gif');