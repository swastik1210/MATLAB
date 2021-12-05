
cover=imread('1peppers.bmp');
cover=rgb2gray(cover);
cover=imresize(cover,2);
[Mc, Nc] = size(cover);
figure;
imshow(cover);

watermark= imread('monarch.bmp');
watermark=imresize(watermark,0.25);
figure;
imshow(watermark);

cov=imresize(cover,0.25);
[cover_h,cover_w,~] = size(cov/4);
[watermark_h,watermark_w,~] = size(watermark);

width = (cover_w - watermark_w);
height = (cover_h - watermark_h);
padded_watermark = padarray(watermark,[height width],0,'pre');

wm = imbinarize(padded_watermark);


[LL1,LH1,HL1,HH1]=dwt2(cover,'haar');
figure
subplot(2,2,1)
imshow(uint8(LL1));title('approx')
subplot(2,2,2)
imshow(LH1,[]);title('horizontal')
subplot(2,2,3)
imshow(HL1,[]);title('vertical')
subplot(2,2,4)
imshow(HH1,[]);title('diagonal')

[LL2,LH2,HL2,HH2]=dwt2(LL1,'haar');
figure
subplot(2,2,1)
imshow(uint8(LL2));title('approx')
subplot(2,2,2)
imshow(LH2,[]);title('horizontal')
subplot(2,2,3)
imshow(HL2,[]);title('vertical')
subplot(2,2,4)
imshow(HH2,[]);title('diagonal')

DCT_HL2=dct2(double(HL2));
figure
imshow(DCT_HL2);title('DCT Cover')
DCT_WM=dct2(double(wm));
figure
imshow(DCT_WM);title('DCT WM')


combined_DCT=DCT_HL2+DCT_WM;
figure
imshow(combined_DCT);title('Combined DCT')


combined_IDCT=idct2(combined_DCT);

figure
imshow(combined_IDCT);title('IDCT')

HL2_new=0.0001*(combined_IDCT+HL2);
LL1=idwt2(LL2,LH2,HL2_new,HH2,'haar');

IDWT2=idwt2(LL1,LH1,HL1,HH1,'haar');
figure;
imshow(uint8(LL1));title('1st level reconstruction')
figure;
imshow(cover);title('original')
figure;
imshow(uint8(IDWT2));title('watermarked')
IDWT2=uint8(IDWT2);

%IDWT2=imnoise(IDWT2,'salt & pepper',0.01);
%IDWT2=imnoise(IDWT2,'gaussian',0,0.01);
%mask=[-1 -1 -1;-1 9 -1;-1 -1 -1];
%mask=fspecial('average',[4,4]);
%IDWT2=imfilter(IDWT2,mask);
%IDWT2=medfilt2(IDWT2,[4,4]);
imwrite(IDWT2,'dwm2bw.jpg','Quality',50);

MSE = mean(mean((double(IDWT2) - double(cover)).^2))/(Mc*Nc); 
PSNR = 10*log10(255*255/MSE);                             
fprintf('\n PSNR between orignal and extracted watermark = %f\n', PSNR);
fprintf('\n MSE between orignal and extracted watermark = %f\n', MSE);


%------------------- Extraction---------------------------------

extract=imread('dwm2bw.jpg');
[ea1,eh1,ev1,ed1]=dwt2(extract,'haar');
figure
subplot(2,2,1)
imshow(uint8(ea1));title('approx')
subplot(2,2,2)
imshow(eh1,[]);title('horizontal')
subplot(2,2,3)
imshow(ev1,[]);title('vertical')
subplot(2,2,4)
imshow(ed1,[]);title('diagonal')
ea1=ea1-LL1;
eh1=eh1-LH1;
ev1=ev1-HL1;
ed1=ed1-HH1;
[ea2,eh2,ev2,ed2]=dwt2(ea1,'haar');
figure
subplot(2,2,1)
imshow(uint8(ea2));title('approx')
subplot(2,2,2)
imshow(eh2,[]);title('horizontal')
subplot(2,2,3)
imshow(ev2,[]);title('vertical')
subplot(2,2,4)
imshow(ed2,[]);title('diagonal')
ea2=ea2-LL2;
eh2=eh2-LH2;
ev2=ev2-HL2;
ed2=ed2-HH2;

DCT_eh2=dct2((ev2));
figure
imshow(DCT_eh2);title('DCT ')

extract = combined_DCT - DCT_HL2;
figure
imshow(extract);title('extracted DCT')
extracted_watermark = idct2(extract);
figure
imshow(extracted_watermark);title('IDCT')

I2 = imcrop(extracted_watermark,[129 129 256-129 256-129]);
I2 = imresize(I2,2);
figure;
imshow((I2));
imwrite(I2,'ex_watermark.jpg');
ea2=ea2+LL2;
eh2=eh2+LH2;
ev2=ev2+HL2;
ed2=ed2+HH2;
ea1=idwt2(ea2,eh2,ev2,ed2,'haar');
ea1=ea1+LL1;
eh1=eh1+LH1;
ev1=ev1+HL1;
ed1=ed1+HH1;
ex_watermark=idwt2(ea1,eh1,ev1,ed1,'haar');
watermark=imresize(watermark,4);
figure;
subplot(1,2,1)
imshow(uint8(ea1));title('1st level reconstruction')
subplot(1,2,2)
imshow(uint8(ex_watermark));title('without watermark')
figure;
subplot(2,2,1)
imshow(I2);title('original watermark')
subplot(2,2,2)
imshow(watermark);title('extracted watermark')
subplot(2,2,3)
imshow(uint8(cover));title('original cover ')
subplot(2,2,4)
imshow(uint8(ex_watermark));title('extracted cover')
