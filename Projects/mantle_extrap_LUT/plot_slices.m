clear all
% pick slice conditions
phi_slice = 0;
freq_slice = 1;
gs_slice = 1;
methods = {'andrade_psp','eburgers_psp','xfit_premelt'};
Nmeth = length(methods);

% load the box
load("data/VBR_Box.mat")

% get ranges of SV
range.phi = unique(VBR.in.SV.phi);
range.T = unique(VBR.in.SV.T_K);
range.gs = unique(VBR.in.SV.dg_um);
range.f = unique(VBR.in.SV.f);
% how many of each
range.NT = length(range.T);
range.Ngs = length(range.gs);
range.Nphi = length(range.phi);
range.Nf = length(range.f);

%% Get unrelaxed compliance
Ju = 1./VBR.out.elastic.anharmonic.Gu;

%% First make a 2-D slice

% find the correct slices for the non-varying dimensions
islice_phi = find(range.phi == phi_slice);
dim_phi = 2;
islice_f = find(range.f == freq_slice);
dim_phi = 4;

% get J1 and J2 slices
% dimensions of nT
J1_slice = nan(range.NT,range.Ngs,Nmeth);
J2_slice = nan(range.NT,range.Ngs,Nmeth);
% do the slicing to fill in the J1, J2
for imeth = 1:Nmeth
    J1_slice(:,:,imeth) = squeeze(VBR.out.anelastic.(methods{imeth}).J1(:,islice_phi,:,islice_f));
    J2_slice(:,:,imeth) = squeeze(VBR.out.anelastic.(methods{imeth}).J2(:,islice_phi,:,islice_f));
end
Ju_slice = squeeze(Ju(:,islice_phi,:));
Jstar_slice = J1_slice + 1i*J2_slice;
qindiv_slice = J2_slice./J1_slice;
Jstar_eff_slice = sum(Jstar_slice,3) - (Nmeth-1)*Ju_slice;
qeff_slice = imag(Jstar_eff_slice)./real(Jstar_eff_slice);

%% plot 
figure(212231),clf
% first few are individual methods
for imeth = 1:Nmeth
    subplot(1,Nmeth+1,imeth), hold on
    contourf(range.T,range.gs,1000*qindiv_slice(:,:,imeth)',100,'linestyle','none');
    hcb = colorbar;
    title(methods{imeth})
    xlabel('Temp')
    ylabel('grainsize')
set(get(hcb,'label'),'String','1000/Q')
clim([0 30])
end
subplot(1,Nmeth+1,Nmeth+1);
contourf(range.T,range.gs,1000*qeff_slice',100,'linestyle','none');
colorbar
clim([0 30])

%% now make the mechanism map
% qmech_slice = nan(size(qeff_slice));
% for ii = 1:size(qindiv_slice,1)
%     for jj = 1:size(qindiv_slice,2);
%         [~,qmech_slice(ii,jj)] = max(qindiv_slice(ii,jj,:));
%     end
% end
qmech_slice = max(J2_slice, [],3);

figure(121)
contourf(range.T,1000*range.gs,qmech_slice',100,'linestyle','none');hold on
clim([0 Nmeth])
[C,h] = contour(range.T,1000*range.gs,1000*qeff_slice',[5:5:30],'k','linewidth',2);
clabel(C,h);
    xlabel('Temp')
    ylabel('grainsize')
set(gca,'box','on','linewidth',2)

%% Now make a 1-D slice

% find the correct slices for the non-varying dimensions
islice_phi = find(range.phi == phi_slice);
dim_phi = 2;
islice_f = find(range.f == freq_slice);
dim_phi = 4;
islice_gs = mindex(range.gs,gs_slice);
dim_phi = 3;

% get J1 and J2 slices
% dimensions of nT
J1_line = nan(range.NT,Nmeth);
J2_line = nan(range.NT,Nmeth);
% do the slicing to fill in the J1, J2
for imeth = 1:Nmeth
    J1_line(:,imeth) = squeeze(VBR.out.anelastic.(methods{imeth}).J1(:,islice_phi,islice_gs,islice_f));
    J2_line(:,imeth) = squeeze(VBR.out.anelastic.(methods{imeth}).J2(:,islice_phi,islice_gs,islice_f));
end
Ju_line = squeeze(Ju(:,islice_phi,islice_gs));
Jstar_line = J1_line + 1i*J2_line;
qindiv_line = J2_line./J1_line;
Jstar_eff_line = sum(Jstar_line,2) - (Nmeth-1)*Ju_line;
qeff = imag(Jstar_eff_line)./real(Jstar_eff_line);

%% plot 
figure(212232),clf

% J1
subplot(4,1,1), hold on
%first plot individual
plot(range.T,J2_line,'linewidth',2)
% then effective
plot(range.T,imag(Jstar_eff_line),'k','linewidth',2)
ylabel('J2')
set(gca,'LineWidth',2,'box','on','YScale','log')

% J1
subplot(4,1,2), hold on
%first plot individual
plot(range.T,J1_line,'linewidth',2)
% then effective
plot(range.T,real(Jstar_eff_line),'k','linewidth',2)
ylabel('J1')
set(gca,'LineWidth',2,'box','on','YScale','log')
set(gca,'YLim',[0 max(real(Jstar_eff_line))])

% QINV
subplot(4,1,3), hold on
%first plot individual
plot(range.T,1000*qindiv_line,'linewidth',2)
% then effective
plot(range.T,1000*qeff,'k','linewidth',2)
ylabel('1000/Qs')
% xlabel('Temp')
legend([methods,{'effective'}],'location','southeast')
set(gca,'LineWidth',2,'box','on','yscale','log')

% Magnitude of compliance
% subplot(4,1,4), hold on
% %first plot individual
% plot(range.T,abs(Jstar_line),'linewidth',2)
% % then effective
% plot(range.T,abs(Jstar_eff_line),'k','linewidth',2)
% ylabel('Compliance mag')
% xlabel('Temp')
% % legend([methods,{'effective'}],'location','northwest')
% set(gca,'LineWidth',2,'box','on','yscale','log')
% set(gca,'YLim',[0 max(abs(Jstar_eff_line))])

% Magnitude of shear modulus
subplot(4,1,4), hold on
%first plot individual
plot(range.T,1./abs(Jstar_line),'linewidth',2)
% then effective
plot(range.T,1./abs(Jstar_eff_line),'k','linewidth',2)
ylabel('Modulus mag')
xlabel('Temp')
% legend([methods,{'effective'}],'location','northwest')
set(gca,'LineWidth',2,'box','on','yscale','log')
set(gca,'YLim',[0 max(1./abs(Jstar_eff_line))])
