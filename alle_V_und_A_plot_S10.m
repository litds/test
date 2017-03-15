clc
clear all
close all
Files=dir(fullfile('Data\flbi08\','*CAN.zip')); % Load zip.Dateien
Querbeschl=zeros(500000,8);
Geschw=zeros(500000,8);

j=1
for i=1:1:length(Files)

i/length(Files)
    
Trace=char(Files(i).name);
Name=strrep(Trace,'_CAN.zip',''); 

% Load Data File
IMPORT_(['Data\flbi08\' Trace]);

%IMPORT_('flbi08_sdr03_150929_01_CAN.d97');

Deg2Rad=pi/180;
g2ms=9.81;

axAll=[];
pAll=[];
vRAll=[];    


CAN_v_FL=ABS_Front_Wheel_Speed./3.6;                                        % on CAN
CAN_v_RL=ABS_Rear_Wheel_Speed./3.6;                                         % on CAN
CAN_ax=LAS_Ax1.*g2ms;
CAN_ay=LAS_Ay1.*g2ms;
CAN_az=LAS_Az_Vertical_Acc.*g2ms;
CAN_omx=LAS_Psip3_Roll_Rate.*Deg2Rad;
CAN_omy=LAS_Psip3_Roll_Rate.*0;                                             % No Signal available due to 5D Sensor -> set to zero
CAN_omz=LAS_Psip1_Yaw_Rate.*Deg2Rad;
CAN_PitchAngle=ABS_Pitch_Info; 
CAN_RollAngle=ABS_Lean_Angle;

SaveResult=0;
Time=q_T0;
Speed=CAN_v_RL;
RollAngle=CAN_RollAngle;
YawRate=CAN_omz;
%LateralAcc=CAN_ay.*cos(RollAngle*pi/180)+CAN_az.*sin(RollAngle*pi/180);
v = Speed;
vv= v.*v;
r = vv ./ (9.81 * tan(RollAngle*pi/180));    
LateralAccTheo= vv ./r;
Speed=Speed*3.6;

for m=1:1:length(LateralAccTheo)
Querbeschl(m,j)=LateralAccTheo(m,1);
end
for n=1:1:length(Speed)
Geschw(n,j)=Speed(n,1);
end

j=j+1;
end


vDist=zeros(1,250);
DistGeschw=zeros(500000,250);
DistQuerbeschl=zeros(500000,250);
for o=1:1:250;
    vDist(o)=o;
end
for o=1:1:250
    k=1;
    for m=1:1:500000
        for n=1:1:8
            if Geschw(m,n)>vDist(o)-0.1 && Geschw(m,n)<vDist(o)+0.1
            DistGeschw(k,o)=Geschw(m,n);
            DistQuerbeschl(k,o)=Querbeschl(m,n);
            k=k+1;
            end
        end
    end
end
for m=1:1:500000
    for n=1:1:250
        if DistQuerbeschl(m,n)==0
            DistQuerbeschl(m,n)=NaN;
        end
    end
end


h=boxplot(DistQuerbeschl);
grid on
grid minor
%hgsave('flbi08.png');
title('flbi08')
xlabel('Geschwindigkeit(km/h)')
ylabel('Querbeschleunigung(m/s^2)')
xlim([0 250])
xLabels={'0','10','20','30','40','50','60','70',...
    '80','90','100','110','120','130','140','150'...
    ,'160','170','180','190','200','210','220','230',...
    '240','250'};
set(gca,'XTick',[0:10:250],'XtickLabel',xLabels);
g=findobj(h,'Tag','Upper Whisker');
k=get(g,'YData');
k=cell2mat(k);



x=[1:1:250];
y=k(:,2);
y=y';
y_Filter=zeros(1,250);
x_Filter=zeros(1,250);
b=1

for z=1:1:250
    if isnan(y(1,z))==0;
      y_Filter(1,b)=y(1,z);
      x_Filter(1,b)=x(1,z);
      b=b+1;
    end
end

for z=250:-1:1
    if y_Filter(1,z)==0;
        y_Filter(:,z)=[];
        x_Filter(:,z)=[];
    end
end

p=polyfit(x_Filter,y_Filter,6);
z=polyval(p,x_Filter);
figure(2)
plot(k(:,2));
hold on
plot(x_Filter,z);
grid on
grid minor
strp1=num2str(p(1));
strp2=num2str(p(2));
strp3=num2str(p(3));
strp4=num2str(p(4));
strp5=num2str(p(5));
strp6=num2str(p(6));
strp7=num2str(p(7));
% strp8=num2str(p(8));
% strp9=num2str(p(9));
% strp10=num2str(p(10));
str=['flbi08: ' 'y=' strp1 'x^6' '+' strp1 'x^5' '+' strp3 'x^4' '+' strp4 'x^3'...
    '+' strp5 'x^2' '+' strp6 'x' '+' strp7]
title(str);
xlabel('Geschwindigkeit(km/h)')
ylabel('Querbeschleunigung(m/s^2)')
xlim([0 250])
xLabels={'0','10','20','30','40','50','60','70',...
    '80','90','100','110','120','130','140','150'...
    ,'160','170','180','190','200','210','220','230',...
    '240','250'};
set(gca,'XTick',[0:10:250],'XtickLabel',xLabels);