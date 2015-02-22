
%% Load Data

clc
src1        = 'C:\Users\brian\Dropbox\lib_source_code\cpp\rBFQ_Simulator\RTC_log.txt';
src2        = 'C:\Users\brian\Dropbox\lib_source_code\cpp\rBFQ_Simulator\rtc';
dst         = '';

dat         = dlmread(src1);
simdat      = dlmread(src2);




hold on;
close all
t0          = 10;
te          = 50;

sel         = (dat(:,1)>t0)&(dat(:,1)<te);

time        = dat(sel,1);
active      = boolean(dat(sel,2));
nnError     = dat(sel,3);
nnLR        = dat(sel,4);
optimal_ori = dat(sel,5:7);
optimal_pos = dat(sel,8:10);


theta       = simdat(:,6:8);
dtheta      = simdat(:,3:5);
for idx = 1:3
    theta(:,idx)  = smooth(theta(:,idx),333/2)*180/pi;
    dtheta(:,idx)  = smooth(dtheta(:,idx),333/2)*180/pi;
end
theta = theta(sel,:);
dtheta = dtheta(sel,:);
%% Naming

trial_name      = input('Input Trial-Name     : ','s');
speed           = input('Input mm/s landspeed : ','s');
n_neurons       = input('Input Neuron Count   : ','s');
n_layers        = input('Input Layer  Count   : ','s');


pos_plot_name   = [dst,trial_name,'_V_',speed,'_nN_',n_neurons,'_nL_',n_layers,'_pos.png'];
vel_plot_name   = [dst,trial_name,'_V_',speed,'_nN_',n_neurons,'_nL_',n_layers,'_vel.png'];
nns_plot_name   = [dst,trial_name,'_V_',speed,'_nN_',n_neurons,'_nL_',n_layers,'_nns.png'];

pos_fig_name    = [dst,trial_name,'_V_',speed,'_nN_',n_neurons,'_nL_',n_layers,'_pos.fig'];
vel_fig_name    = [dst,trial_name,'_V_',speed,'_nN_',n_neurons,'_nL_',n_layers,'_vel.fig'];
nns_fig_name    = [dst,trial_name,'_V_',speed,'_nN_',n_neurons,'_nL_',n_layers,'_nns.fig'];


save([dst,trial_name,'_V_',speed,'_nN_',n_neurons,'_nL_',n_layers,'_botdata'],'dat')
save([dst,trial_name,'_V_',speed,'_nN_',n_neurons,'_nL_',n_layers,'_simdata'],'simdat')

%% Global Settings

font_size = 12;


%% Theta
figure(1)

fig_labels = {'\theta_{x}, degrees','\theta_{y}, degrees'};
for coord = 1:2
    subplot(2,1,coord); cla; hold on
    
    set(gca,'YLIM',[-8,8])
    set(gca,'YTICK',-8:2:8)
    plot_partition(t0:10:te,'r--')
    plot_patch(t0:10:te,1:2:8,'r','FaceAlpha',0.1)
    plot_patch(t0:10:te,2:2:8,'g','FaceAlpha',0.1)
    plot(   time, theta(:,coord),'k')
    
    ylabel(fig_labels{coord},'FontSize',font_size)
    xlabel('t,s','FontSize',font_size)
  
    if(coord==1)
        title(['Angular Trunk Position; Pitch and Roll   \bf{(',num2str(t0),' s - ',num2str(te),' s)}'],'FontSize',font_size)
    end
end
print('-dpng','-r400',pos_plot_name)

%% dTheta
figure(2)

fig_labels = {'d\theta_{x}/dt, deg/s','d\theta_{y}/dt, deg/s'};
for coord = 1:2
    subplot(2,1,coord); cla; hold on
    
    set(gca,'YLIM',[min(dtheta(:,coord))-0.01,max(dtheta(:,coord))+0.01])
    plot_partition(t0:10:te,'r--')
    plot_patch(t0:10:te,1:2:8,'r','FaceAlpha',0.1)
    plot_patch(t0:10:te,2:2:8,'g','FaceAlpha',0.1)
    plot(   time, dtheta(:,coord),'k')
    
    ylabel(fig_labels{coord},'FontSize',font_size)
    xlabel('t,s','FontSize',font_size)
    
    if(coord==1)
        title(['Angular Trunk Velocity; Pitch and Roll   \bf{(',num2str(t0),' s - ',num2str(te),' s)}'],'FontSize',font_size)
    end
end
print('-dpng','-r400',vel_plot_name)



%% NARX Neural Network

figure(3)
cla

subplot(2,1,1); cla

title(['NARX-Network MSE and LR   \bf{(',num2str(t0),' s - ',num2str(te),' s)}'],'FontSize',font_size)
    
hold on
set(gca,'YLIM',[min(nnError)-0.01,max(nnError)+0.01])
plot_patch(t0:10:te,1:2:8,'r','FaceAlpha',0.1)
plot_patch(t0:10:te,2:2:8,'g','FaceAlpha',0.1)
plot(time, nnError,'b','LineWidth',1)
plot(time, smooth(nnError,1000),'k','LineWidth',1.5)
plot_partition(t0:10:te,'r--')
ylabel('MSE','FontSize',font_size)

subplot(2,1,2); cla
hold on

set(gca,'YLIM',[min(nnLR)-1e-4,max(nnLR)+1e-4])
plot_patch(t0:10:te,1:2:8,'r','FaceAlpha',0.1)
plot_patch(t0:10:te,2:2:8,'g','FaceAlpha',0.1)
plot(time, nnLR,'b','LineWidth',1)
plot(time, smooth(nnLR,1000),'k','LineWidth',1.5)
plot_partition(t0:10:te,'r--')
ylabel('Learning Rate','FontSize',font_size)
xlabel('t,s','FontSize',font_size)

print('-dpng','-r400',nns_plot_name)
