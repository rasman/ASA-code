mPatient = patBuilder(50,70, 170, 1);

dur = 10*60;
plan = [4, 0];
time = 0:1/60:dur;
t1 = 0:1/60:120;
u1 = zeros(size(t1));
h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
set(h,'Position',[100 100 1250 500])

filename = 'mega_dose.gif';

input =  build_TCI_eleveld (mPatient, plan, dur, 0);
sys_ele = eleveld18_expand(mPatient);
sys_ele = sys_ele(2);
[y,tOut,x] = lsim(sys_ele,input,time);

input2 =  input;
input2(1) = input2(1)*3;
[y2,tOut2,x2] = lsim(sys_ele,input2,time);


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
for val =[60, 150, 300, 600] *60
    subplot(1,2,1)
    y = lsim(sys_ele,u1,t1, x(val,:));
    h1= plot(t1(1:1201),y(1:1201)*1000);
    
    y2 = lsim(sys_ele,u1,t1, x2(val,:));
    plot(t1(1:1201),y2(1:1201)*1000,'Color',h1.Color, 'LineStyle','-.' );
    
    
    if first
        legend ({'','','',strcat(int2str(input(1)/60), ' mg'), strcat(int2str(input2(1)/60), ' mg')},'AutoUpdate','off')
    end
    
    subplot(1,2,2)
    plot(val/3600, t1(find(y < 3e-3,1)),'b.')
    plot(val/3600, t1(find(y < 2e-3,1)),'k.')
    plot(val/3600, t1(find(y < 1.5e-3,1)),'r.')
    plot(val/3600, t1(find(y2 < 3e-3,1)),'bo')
    plot(val/3600, t1(find(y2 < 2e-3,1)),'ko')
    plot(val/3600, t1(find(y2 < 1.5e-3,1)),'ro')
    
    
    if first
        legend ({strcat(int2str(input(1)/60), ' mg'), strcat(int2str(input2(1)/60), ' mg')},'AutoUpdate','off')
        first = false;
    end
    drawnow
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if val/3600 == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',0, 'DelayTime', 2);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append', 'DelayTime', 2);
    end
    
end
