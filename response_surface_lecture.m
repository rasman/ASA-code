concP = 0:0.1e-3:1.75*2.2E-3;
concR = 0:1e-3:1.75*33.1E-3;
[CP,CR] = meshgrid(concP,concR);

resp_prob = responseProbability(CP,CR);
surf(CP*1000,CR*1000,resp_prob*100)
xlabel('Propofol Ec (mcg/ml)')
ylabel('Remi Ec (ng/ml)')
zlabel('Probability of LOC (%)')