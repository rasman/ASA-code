mPatient = patBuilder(50,70, 170, 1);
dur = 4*60;
plan = [4, 0];
time = 0:1/60:dur;
t1 = 0:1/60:120;
u1 = zeros(size(t1));
h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
set(h,'Position',[100 100 1250 500])

filename = 'decrement_time_pk_var.gif';
filename_1 = 'decrement_time_1_pk_var.gif';

input =  build_TCI_eleveld (mPatient, plan, dur, 0);
val = dur*60;

% Preop plot canvas

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
xlim([0 4])
ylim([0 25])

xlabel('Decrement percentage')
xticks([1,2,3]);
xticklabels({'25%', '50%', '62.5'})
ylabel('Time to reach decrement value (min)')
title ('Decrement time after 4 hours')
first = true;

N = 2000;
location = nan(N,3);
d_time = nan(N,3);

for iter = 1:N
    sys_ele = eleveld18_vary(mPatient);
    sys_ele = sys_ele(2);
    [y1,tOut,x] = lsim(sys_ele,input,time);
    
    subplot(1,2,1)
    y = lsim(sys_ele,u1,t1, x(val,:));
    plot(t1(1:1201),y(1:1201)*1000,'b')
    
    
    if first
        legend ({'25%','50%','62.5%','Concentration'},'AutoUpdate','off','Location','southeast')
    end
    

    location(iter, 1) = find(y < 3e-3,1);
    location(iter, 2) = find(y < 2e-3,1);
    location(iter, 3) = find(y < 1.5e-3,1);
    
    d_time(iter, 1) = find(y < y1(end)*3/4,1);
    d_time(iter, 2) = find(y < y1(end)/2,1);
    d_time(iter, 3) = find(y < y1(end)*1.5/4,1);
    
    if mod(iter,100) ==0
        disp(iter)
    end
end

subplot(1,2,2)
hold off
plot(ones(1,length(location)), t1(location(:,1)),'b.')
hold on
plot(ones(1,length(location))+1, t1(location(:,2)),'k.')
plot(ones(1,length(location))+2, t1(location(:,3)),'r.')
legend ({'25%','50%','62.5%'},'AutoUpdate','off')


xlim([0 4])
ylim([0 25])
xlabel('Decrement percentage')
xticks([1,2,3]);
xticklabels({'25%', '50%', '62.5'})
ylabel('Time to reach decrement value (min)')
title ('Decrement time after 4 hours')

frame = getframe(h);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,filename,'gif');