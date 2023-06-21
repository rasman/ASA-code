mPatient0 = patBuilder(50,70,170,1);
sys_ele0 =  eleveld18(mPatient0);
sys_ele0.TimeUnit = 'min';
t = 0:1/60:120;
u = ones(size(t))*.15*70;
y = lsim(sys_ele0, u, t);
[y2,t2] = step(sys_ele0);
h = figure;
axis tight manual % this ensures that getframe() returns a consistent size
set(h,'Position',[100 100 1200 600])
filename = 'dose_stable.gif';
plot(t,y*1000)
line([0 120],y2(end)*.15*70*[1 1]*1000, 'Color','k','LineStyle','--')
ylim([0 6.5])
xlabel('Time (min)')
ylabel('Effect Site (mcg/mL)')
title('Propofol, 150 mcg/kg/min (70 kg, 170 cm, Male)')
frame = getframe(h);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,filename,'gif');