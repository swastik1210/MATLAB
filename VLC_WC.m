%%
theta = 60 ;
% semi-angle at half power

ml=-log10 ( 2 ) / log10 ( cosd ( theta ) ) ;
%Lambertian order of emission

P_LED =35;
%transmitted optical power by individual LED

nLED =20;
% number of LED array nLED*nLED

P_total=nLED*nLED*P_LED ;
%Total transmitted power

Adet=0.25e-4;
%detector physical area of a PD

Ts =2;
%gain of an optical filter ; ignore if no filter is used

index = 1.5 ;
%refractive index of lens of a PD; 

FOV =60;
%FOV of areceiver

G_Con =( index^2 ) / ( sind ( FOV ).^2 ) ;
%gain of an optical concentrator ;
%%
lx =6; ly =6; lz =3;
% room dimension in meter

h = 2 ;
%the distance between source and receiver plane

[ XT , YT ]= meshgrid ([-lx/6 lx/6 ] , [ -ly /6 ly /6 ] ) ;
% position of LED; it is assumed all LEDs are located at same point 
% for one LED simulation located at the central of the room ,
%use XT=0 and YT=0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nx=lx*5 ; Ny=ly*5 ;
% number of grid in the receiver plane
x= linspace (-lx/2 , lx/2 , Nx ) ;
y= linspace (-ly/2 , ly/2 , Ny ) ;
[ XR , YR ]= meshgrid ( x , y ) ;
D1= sqrt ((XR-XT(1,1)).^2 + (YR-YT(1,1)).^2 + h^2);
% distance vector from source 1
cosphi_A1=h./D1 ;
% angle vector
receiver_angle=acosd ( cosphi_A1 ) ;
% alternative methods to calculate angle , more accurate if the angle are neagtive
% nr =[0 0 1] ;
% RT=[1.25 1.25 ] ; % transmitter location
% for r =1: length ( x )
% for c =1: length ( y )
% angleA12= atan ( sqrt (( x(r)?1.25).^2 + (y(c) ? 1.25).^2)./h ) ;
% costheta(r,c) =cos( angleA12 ) ;
% end
% end
%
%%
% D2= fliplr(D1 ) ;
% due to symmetry
% D3= flipud(D1 ) ;
% D4= fliplr(D3 ) ;

H_A1=(ml+1)*Adet.*cosphi_A1.^(ml+1)./(2*pi.*D1.^2 ) ;
%channel DC gain of source 1

P_rec_A1=P_total.*H_A1.* Ts.*G_Con ;
% received power from source 1 ;

P_rec_A1( abs(receiver_angle)>FOV)=0;
% if the angle of arrival is greater than FOV, no current is generated at
% the photodide
P_rec_A2= fliplr ( P_rec_A1 ) ;
% received power from source 2 , due to symmetry no need separate
% calulations
P_rec_A3= flipud ( P_rec_A1 ) ;
P_rec_A4= fliplr( P_rec_A3 ) ;
P_rec_total=P_rec_A1+P_rec_A2+P_rec_A3+P_rec_A4;
P_rec_dBm=10* log10 (P_rec_total);
P_rec_max=max(P_rec_dBm);
P_rec_max=max(P_rec_max);
P_rec_min=min(P_rec_dBm);
P_rec_min=max(P_rec_min);
delta_P_rec= P_rec_max-P_rec_min;
figure;
surfc ( x , y , P_rec_dBm) ;
figure;
surfc ( x , y , P_rec_dBm) ;
az=0;
el=90;
view(az,el);
% contour(x,y,_rec_dBm); hold on
% mesh ( x , y , P rec dBm) ;