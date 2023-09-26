[ mPatient ] = patBuilder( 50,70,177,1);
[schnid.sys, schnid.V, schnid.Cl] = schnider(mPatient);
[remi_mdl.sys, remi_mdl.V, remi_mdl.Cl] = remiMdl(mPatient);

t = 0:1/60:120;
u = ones(size(t))*0.25*mPatient.Weight/1000;
yr_max = lsim(remi_mdl.sys, u,t);


cp50= 2.2E-3;
cr50 = 33.1E-3;
n = 5.0;
alpha = 3.6;
concP_wake  = 0:0.01e-3:5E-3;
conr_calc = @(concP,effect) cr50*((effect/(1-effect))^(1/n) - concP/cp50)./(1 + alpha*concP/cp50);
concR_wake = [conr_calc(concP_wake,0.5); conr_calc(concP_wake,0.95)];
concR_wake(concR_wake<0) = NaN;


cp50_a= 4.2E-3;
cr50_a = 8.8E-3;
n_a = 8.3;
alpha_a = 8.2;
concP_a  = 0:0.01e-3:cp50_a*2;
conr_calc_a = @(concP_a,effect) cr50_a*((effect/(1-effect))^(1/n_a) - concP_a/cp50_a)./(1 + alpha_a*concP_a/cp50_a);
concR_a = [conr_calc_a(concP_a,0.5); conr_calc_a(concP_a,0.9)];
concR_a(concR_a<0) = NaN;


cp50_t= 4.6E-3;
cr50_t = 23.1E-3;
n_t = 6.0;
alpha_t = 14.7;
concP_tet  = 0:0.01e-3:cp50_t*2;
conr_calc_t = @(concP_tet,effect) cr50_t*((effect/(1-effect))^(1/n_t) - concP_tet/cp50_t)./(1 + alpha_t*concP_tet/cp50_t);
concR_tet = [conr_calc_t(concP_tet,0.5); conr_calc_t(concP_tet,0.9)];
concR_tet(concR_tet<0) = NaN;


t = 0:1/60:120;
up_PSH = ones(size(t))* 150*mPatient.Weight/1000;
up_PSH(1:60)=2*mPatient.Weight;
ur_PSH = ones(size(t))* 0.05*mPatient.Weight/1000;
yp_PSH = lsim(schnid.sys, up_PSH, t);
yr_PSH = lsim(remi_mdl.sys, ur_PSH, t);


up_ES = ones(size(t));
up_ES(1:60)=2*mPatient.Weight;
up_ES(60:15*60) =  120*mPatient.Weight/1000;
up_ES(15*60:30*60) =  100*mPatient.Weight/1000;
up_ES(30*60:60*60) =  90*mPatient.Weight/1000;
up_ES(60*60:90*60) =  83*mPatient.Weight/1000;
up_ES(90*60:end) =  75*mPatient.Weight/1000;
ur_ES = ones(size(t))* 0.08*mPatient.Weight/1000;
ur_ES(1:6) = 35/1000*10;
yp_ES = lsim(schnid.sys, up_ES, t);
yr_ES = lsim(remi_mdl.sys, ur_ES, t);

h = figure;
% axis tight manual % this ensures that getframe() returns a consistent size
set(h,'Position',[100 100 600 500])
filename0 = 'isobolo_blank.gif';
filename = 'isobolo_dosing.gif';
filename_end = 'isobolo_last.gif';

hold on
xlabel('Remifentanil (ng/mL)')
ylabel('Propofol (mcg/mL)')
title ('Isobologram')

plot(concR_wake(1,:)*1e3, concP_wake*1e3, 'b-','LineWidth',2)
plot(concR_wake(2,1:10:end)*1e3, concP_wake(1:10:end)*1e3, 'b:','LineWidth',2)
plot(concR_tet(1,:)*1e3, concP_tet*1e3, 'r-','LineWidth',2)
% plot(concR_a(1,:), concP_a, 'k-')
% plot(concR_wake(2,:), concP_wake, 'b.')
% plot(concR_tet(2,:), concP_tet, 'r.')
% line([1 1]*yr_max(end)*1000, [0 cp50_t])
xlim([0 4.5])
ylim([0 5])

legend ({'50% LOC', '95% LOC', '50% Tetany'},'AutoUpdate','off')
%exportgraphics(gca,filename0)
frame = getframe(h);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,filename0,'gif');

ax1 = gca;
f2 = figure();
ax2 = copyobj(ax1,f2);

first = true;
figure(h)
for val =(10:5:120)*60
    
    plot(yr_PSH(val)*1e6, yp_PSH(val,1)*1e3, 'k.','MarkerSize',12)
    plot(yr_ES(val)*1e6, yp_ES(val,1)*1e3, 'm.','MarkerSize',12)
    if first
        first = false;
        legend ({'50% LOC', '95% LOC', '50% Tetany','P: 150 mkm, R = 0.05 mkm','P: Decrease, R = 0.08 mkm'},'AutoUpdate','off')
    end
    drawnow
    frame = getframe(h);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    % Write to the GIF File
    if val == 600
        imwrite(imind,cm,filename,'gif', 'Loopcount',0, 'DelayTime', 1);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append', 'DelayTime', 1);
    end

end

figure(f2)
set(f2,'Position',[100 100 600 500])
plot(yr_PSH(val)*1e6, yp_PSH(val,1)*1e3, 'ko','MarkerSize',12)
plot(yr_ES(val)*1e6, yp_ES(val,1)*1e3, 'mo','MarkerSize',12)
legend ({'50% LOC', '95% LOC', '50% Tetany','P: 150 mkm','P: Titrate'},'AutoUpdate','off')

frame = getframe(f2);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,filename_end,'gif');