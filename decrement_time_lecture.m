mPatient = patBuilder(50,70, 170, 1);
dur = 10*60;
plan = [4, 0];
time = 0:1/60:dur;
t1 = 0:1/60:120;
u1 = zeros(size(t1));
h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
set(h,'Position',[100 100 1250 500])

filename = 'decrement_time.gif';
filename_1 = 'decrement_time_1.gif';

input =  build_TCI_eleveld (mPatient, plan, dur, 0);
sys_ele = eleveld18_expand(mPatient);
sys_ele = sys_ele(2);
[y,tOut,x] = lsim(sys_ele,input,time);
subplot(1,2,1)
hold
ylim([0 4])
s(1) = line([0 t1(1201)], 3*[1 1]);
s(2) = line([0 t1(1201)], 2*[1 1]);
s(3) = line([0 t1(1201)], 1.5*[1 1]);
s(1).Color='b';
s(2).Color='k';
s(3).Color='r';
xlabel('Time (min)')
ylabel('Plasma concentration (mcg/mL)')
title ('Drug concentration following infusion end')


subplot(1,2,2)
hold
xlim([0 10])
ylim([0 25])

xlabel('Infusion duration (hour)')
ylabel('Time to reach decrement value (min)')
title ('Decrement time')
first = true;

for val =(60:60:600)*60
    subplot(1,2,1)
    y = lsim(sys_ele,u1,t1, x(val,:));
    plot(t1(1:1201),y(1:1201)*1000)
    
    
    if first
        legend ({'25%','50%','62.5%','Concentration'},'AutoUpdate','off')
    end
    
    subplot(1,2,2)
    plot(val/3600, t1(find(y < 3e-3,1)),'b.')
    plot(val/3600, t1(find(y < 2e-3,1)),'k.')
    plot(val/3600, t1(find(y < 1.5e-3,1)),'r.')
    
    if first
        legend ({'25%','50%','62.5%'},'AutoUpdate','off')
        first = false;
    end
    
    drawnow
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if val/3600 == 1
        imwrite(imind,cm,filename_1,'gif', 'Loopcount',0);
        imwrite(imind,cm,filename,'gif', 'Loopcount',0, 'DelayTime', 2);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append', 'DelayTime', 2);
    end
    
end
