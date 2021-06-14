unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ExtDlgs, ComCtrls, Buttons, Menus, windows;


type
  { TForm1 }

  TForm1 = class(TForm)
    bright: TButton;
    brightBar: TTrackBar;
    bText: TEdit;
    blueBtn: TButton;
    btnLoad: TButton;
    clearBtn: TButton;
    Panel5: TPanel;
    contrast: TButton;
    contrastBar: TTrackBar;
    greenBtn: TButton;
    Panel4: TPanel;
    redBtn: TButton;
    colorBalance: TButton;
    convolution: TButton;
    correlation: TButton;
    gText: TEdit;
    kernel: TEdit;
    grayscale: TButton;
    invers: TButton;
    Label1: TLabel;
    monochrom: TButton;
    monocolor: TButton;
    mode: TButton;
    Panel1: TPanel;
    gRadio: TRadioButton;
    bRadio: TRadioButton;
    Panel2: TPanel;
    hpf: TRadioButton;
    hpf1: TRadioButton;
    lpf: TRadioButton;
    Panel3: TPanel;
    rRadio: TRadioButton;
    rText: TEdit;
    saveBtn: TButton;
    thresBar: TTrackBar;
    threshold: TButton;
    scaleText: TEdit;
    Image1: TImage;
    scaleBtn: TBitBtn;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    scalexBar: TTrackBar;
    ScrollBox1: TScrollBox;
    kernelBar: TTrackBar;
    redBar: TTrackBar;
    greenBar: TTrackBar;
    blueBar: TTrackBar;
    thresText: TEdit;
    procedure blueBarChange(Sender: TObject);
    procedure blueBtnClick(Sender: TObject);
    procedure brightClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure correlationClick(Sender: TObject);
    procedure colorBalanceClick(Sender: TObject);
    procedure convolutionClick(Sender: TObject);
    procedure kernelBarChange(Sender: TObject);
    procedure modeClick(Sender: TObject);
    procedure monocolorClick(Sender: TObject);
    procedure clearBtnClick(Sender: TObject);
    procedure contrastClick(Sender: TObject);
    procedure grayscaleClick(Sender: TObject);
    procedure greenBarChange(Sender: TObject);
    procedure greenBtnClick(Sender: TObject);
    procedure inversClick(Sender: TObject);
    procedure monochromClick(Sender: TObject);
    procedure redBarChange(Sender: TObject);
    procedure redBtnClick(Sender: TObject);
    procedure saveBtnClick(Sender: TObject);
    procedure scaleBtnClick(Sender: TObject);
    procedure scalexBarChange(Sender: TObject);
    procedure thresBarChange(Sender: TObject);
    procedure thresholdClick(Sender: TObject);
    procedure OnUpdate(Sender: TObject);
    procedure OnStart(Sender: TObject);
    function truncate(a: integer): integer;
    procedure InitKernelMean();
    procedure PaddingBitmap();
  private

  public

  end;

var
  Form1: TForm1;
  x,y,gray: Integer;
  bitmapR,bitmapG,bitmapB,paddingR,paddingG,paddingB,cBR, cBG, cBB: array[0..10000,0..10000] of byte;
  thres: array[0..10000,0..10000] of boolean;
  clr: array[0..1000,0..1000] of TColor;
  w,h,bw,bh:integer;
  kernelMean: array[0..100,0..100] of double;
  k, kHalf: integer;


implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnLoadClick(Sender: TObject);
begin

  if OpenPictureDialog1.Execute then
  begin
    image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
    OnStart(Sender);
    OnUpdate(Sender);
  end;

end;

procedure TForm1.correlationClick(Sender: TObject);
var
  x,y,xK,yK: integer;
  cR,cG,cB: double;
begin
  //inisial variabel
  k:= kernelBar.Position;
  kHalf:= k div 2;
  InitKernelMean();
  PaddingBitmap();

  //loop image
  for y:= kHalf to (image1.height+kHalf) do
  begin
    for x:= kHalf to (image1.width+kHalf) do
    begin
      //inisial variabel hasil * +
      cR:= 0;
      cG:= 0;
      cB:= 0;
    for yK:= 1 to k do             //loop kernel y
    begin
      for xK:= 1 to k do           //loop kernel x
      begin
        //timpa nilai variabel
        //gunakan rumus korelasi
        cR:= cR+(paddingR[x+(xK-k+kHalf), y+(yK-k+kHalf)]*kernelMean[xK,yK]);
        cG:= cG+(paddingG[x+(xK-k+kHalf), y+(yK-k+kHalf)]*kernelMean[xK,yK]);
        cB:= cB+(paddingB[x+(xK-k+kHalf), y+(yK-k+kHalf)]*kernelMean[xK,yK]);
      end;
    end;
      cBR[x-kHalf,y-kHalf]:= truncate(Round(cR));     //masukan nilai korelasi
      cBG[x-kHalf,y-kHalf]:= truncate(Round(cG));     //sesuai ukuran image
      cBB[x-kHalf,y-kHalf]:= truncate(Round(cB));
    end;
  end;

  //ganti nilai piksel image
  for y:= 0 to image1.height-1 do
  begin
    for x:= 0 to image1.width-1 do
    begin
      image1.Canvas.Pixels[x,y]:= RGB(cBR[x,y],cBG[x,y],cBB[x,y]);
    end;
  end;

end;

procedure TForm1.colorBalanceClick(Sender: TObject);
var
  newR,newG,newB: byte;
begin
  for y:=0 to image1.height-1 do
  begin
    for x:=0 to image1.width-1 do
    begin
      newR:=truncate(bitmapR[x,y]+redBar.Position);
      newG:=truncate(bitmapG[x,y]+greenBar.Position);
      newB:=truncate(bitmapB[x,y]+blueBar.Position);
      image1.canvas.pixels[x,y]:=rgb(newR,newG,newB);
    end;
  end;
end;

procedure TForm1.convolutionClick(Sender: TObject);
var
  cR,cG,cB:Real;
  xK,yK:Integer;
begin
  //inisial variabel
  k:=kernelBar.Position;
  kHalf:=k div 2;
  InitKernelMean();
  PaddingBitmap();

  //loop  image
  for y:=kHalf to (image1.height+kHalf) do
  begin
    for x:=kHalf to (image1.width+kHalf) do
    begin
      //inisial variabel penampung hasil * +
      cR:=0;
      cG:=0;
      cB:=0;
      for yK:=1 to k do                    //loop kernel y
      begin
        for xK:=1 to k do                  //loop kernel x
        begin
          //timpa nilai variabel
          //gunakan rumus konvulsi
          cR:= cR+(paddingR[x-(xK-k+kHalf),y-(yK-k+kHalf)]*kernelMean[xK,yK]);
          cG:= cG+(paddingG[x-(xK-k+kHalf),y-(yK-k+kHalf)]*kernelMean[xK,yK]);
          cB:= cB+(paddingB[x-(xK-k+kHalf),y-(yK-k+kHalf)]*kernelMean[xK,yK]);
        end;
      end;
        cBR[x-kHalf, y-kHalf]:= truncate(Round(cR)); //masukan nilai konvulsi
        cBG[x-kHalf, y-kHalf]:= truncate(Round(cG)); //sesuai ukuran image
        cBB[x-kHalf, y-kHalf]:= truncate(Round(cB));
    end;
  end;

  //ganti nilai piksel image
  for y:= 0 to image1.height-1 do
  begin
    for x:= 0 to image1.width-1 do
    begin
      image1.Canvas.Pixels[x,y]:= RGB(cBR[x,y], cBG[x,y], cBB[x,y]);
    end;
  end;
end;

procedure TForm1.kernelBarChange(Sender: TObject);
begin
  kernel.Text:=IntToStr(kernelBar.Position);
end;

procedure TForm1.modeClick(Sender: TObject);
begin
  OnUpdate(Sender);
end;

procedure TForm1.monocolorClick(Sender: TObject);
begin
  if rRadio.Checked=true then
  begin
    for y:=0 to image1.height-1 do
    begin
      for x:=0 to image1.width-1 do
      begin
        image1.canvas.pixels[x,y]:=rgb(bitmapR[x,y],0,0);
      end;
    end;
  end
  else if gRadio.Checked=true then
  begin
    for y:=0 to image1.height-1 do
    begin
      for x:=0 to image1.width-1 do
      begin
        image1.canvas.pixels[x,y]:=rgb(0,bitmapG[x,y],0);
      end;
    end;
  end
  else if bRadio.Checked=true then
  begin
    for y:=0 to image1.height-1 do
    begin
      for x:=0 to image1.width-1 do
      begin
        image1.canvas.pixels[x,y]:=rgb(0,0,bitmapB[x,y]);
      end;
    end;
  end;
end;

procedure TForm1.clearBtnClick(Sender: TObject);
begin
  image1.width:=w;
  image1.height:=h;
  image1.picture.bitmap.width:=bw;
  image1.picture.bitmap.height:=bh;
  for y:=0 to image1.height-1 do
  begin
    for x:=0 to image1.width-1 do
    begin
      image1.canvas.pixels[x,y]:=clr[x,y];
      bitmapR[x,y]:=red(clr[x,y]);
      bitmapG[x,y]:=green(clr[x,y]);
      bitmapB[x,y]:=blue(clr[x,y]);
    end;
  end;
end;

procedure TForm1.contrastClick(Sender: TObject);
var
  G: real;
  newR,newG,newB:integer;
begin
  //buat nilai intensitas
  G:= (259*(contrastBar.Position+255))/(255*(259-contrastBar.Position));
  for y:=0 to image1.height-1 do    //loop sebanyak tinggi image
  begin
    for x:=0 to image1.width-1 do   //loop sebanyak lebar image
    begin
      newR:= truncate(round(G*(bitmapR[x,y]-128)+128));//gunakan rumus kontras
      newG:= truncate(round(G*(bitmapG[x,y]-128)+128));//dengan pusat 128
      newB:= truncate(round(G*(bitmapB[x,y]-128)+128));
      Image1.canvas.pixels[x,y]:= rgb(newR,newG,newB);//masukan piksel kontras
    end;
  end;
  OnUpdate(Sender); //optional
end;

procedure TForm1.grayscaleClick(Sender: TObject);
var
  gray: Integer;
begin
  for y:=0 to image1.height-1 do
  begin
    for x:=0 to image1.width-1 do
    begin
      gray:=(bitmapR[x,y]+bitmapG[x,y]+bitmapB[x,y]) div 3;
      image1.canvas.pixels[x,y]:=rgb(gray,gray,gray);
    end;
  end;
end;

procedure TForm1.greenBarChange(Sender: TObject);
begin
  gText.Text:=IntToStr(greenBar.Position);
end;

procedure TForm1.greenBtnClick(Sender: TObject);
var
  newG:integer;
begin
  for y:=0 to image1.height-1 do
  begin
    for x:=0 to image1.width-1 do
    begin
      newG:= truncate(bitmapG[x,y]+greenBar.Position);
      image1.canvas.pixels[x,y]:=rgb(bitmapR[x,y],newG,bitmapB[x,y]);
    end;
  end;
end;

procedure TForm1.inversClick(Sender: TObject);
var
  newR,newG,newB:integer;
begin
  for y:=0 to image1.height-1 do
  begin
    for x:=0 to image1.width-1 do
    begin
      newR:=255-bitmapR[x,y];
      newG:=255-bitmapG[x,y];
      newB:=255-bitmapB[x,y];
      image1.canvas.pixels[x,y]:=rgb(newR,newG,newB);
    end;
  end;
end;

procedure TForm1.monochromClick(Sender: TObject);
var
  gray: Integer;
begin
  if rRadio.Checked=true then
  begin
    for y:=0 to image1.height-1 do
    begin
      for x:=0 to image1.width-1 do
      begin
        gray:=(bitmapR[x,y]+bitmapG[x,y]+bitmapB[x,y]) div 3;
        image1.canvas.pixels[x,y]:=rgb(gray,0,0);
      end;
    end;
  end
  else if gRadio.Checked=true then
  begin
    for y:=0 to image1.height-1 do
    begin
      for x:=0 to image1.width-1 do
      begin
        gray:=(bitmapR[x,y]+bitmapG[x,y]+bitmapB[x,y]) div 3;
        image1.canvas.pixels[x,y]:=rgb(0,gray,0);
      end;
    end;
  end
  else if bRadio.Checked=true then
  begin
    for y:=0 to image1.height-1 do
    begin
      for x:=0 to image1.width-1 do
      begin
        gray:=(bitmapR[x,y]+bitmapG[x,y]+bitmapB[x,y]) div 3;
        image1.canvas.pixels[x,y]:=rgb(0,0,gray);
      end;
    end;
  end;
end;



procedure TForm1.redBarChange(Sender: TObject);
begin
  rText.Text:=IntToStr(redBar.Position);
end;

procedure TForm1.redBtnClick(Sender: TObject);
var
  newR:integer;
begin
  for y:=0 to image1.height-1 do
  begin
    for x:=0 to image1.width-1 do
    begin
      newR:= truncate(bitmapR[x,y]+redBar.Position);
      image1.canvas.pixels[x,y]:=rgb(newR,bitmapG[x,y],bitmapB[x,y]);
    end;
  end;
end;

procedure TForm1.saveBtnClick(Sender: TObject);
begin
  if savepicturedialog1.Execute then
  begin
    Image1.picture.SaveToFile(savepicturedialog1.FileName);
  end;
end;


procedure TForm1.brightClick(Sender: TObject);
var
  newR,newG,newB:integer;
begin
  for y:=0 to Image1.Height-1 do
  begin
    for x:=0 to Image1.width-1 do
    begin
      newR := truncate(bitmapR[x,y]+brightBar.Position);
      newG := truncate(bitmapG[x,y]+brightBar.Position);
      newB := truncate(bitmapB[x,y]+brightBar.Position);
      Image1.canvas.pixels[x,y]:= rgb(newR,newG,newB);
    end;
  end;
end;

procedure TForm1.blueBarChange(Sender: TObject);
begin
  bText.Text:=IntToStr(blueBar.Position);
end;

procedure TForm1.blueBtnClick(Sender: TObject);
var
  newB:integer;
begin
  for y:=0 to image1.height-1 do
  begin
    for x:=0 to image1.width-1 do
    begin
      newB:= truncate(bitmapB[x,y]+blueBar.Position);
      image1.canvas.pixels[x,y]:=rgb(bitmapR[x,y],bitmapG[x,y],newB);
    end;
  end;
end;

procedure TForm1.scaleBtnClick(Sender: TObject);
var
  scale,i: Integer;
  stepR,stepG,stepB: Integer;
  R,G,B,R1,G1,B1,R2,G2,B2: Byte;
begin
  //inisial
  scale:=scalexBar.Position;
  //ukuran dikali dengan skala
  image1.picture.bitmap.width:=image1.picture.bitmap.width*scale;
  image1.picture.bitmap.height:=image1.picture.bitmap.height*scale;
  image1.Width:=w*scale;
  image1.Height:=h*scale;

  //bersihkan piksel
  for y:=0 to image1.height-1 do
  begin
    for x:=0 to image1.width-1 do
    begin
      image1.canvas.pixels[x,y]:=rgb(0,0,0);
    end;
  end;

  //interpolar horizontal
  for y:=0 to image1.height-1 do         //loop tinggi image
  begin
    for x:=0 to image1.width-1 do        //loop lebar image
    begin
      //isi variabel dengan rumus (fi2-fi1/skala)
      stepR:=round((bitmapR[x+1,y]-bitmapR[x,y])/scale);
      stepG:=round((bitmapG[x+1,y]-bitmapG[x,y])/scale);
      stepB:=round((bitmapB[x+1,y]-bitmapB[x,y])/scale);
      //scaling image
      image1.canvas.pixels[x*scale,y*scale]:=rgb(bitmapR[x,y],bitmapG[x,y],bitmapB[x,y]);
      for i:=1 to scale-1 do
      begin
        //isi piksel kosong secara horizontal --------
        R:=bitmapR[x,y]+(i*stepR);
        G:=bitmapG[x,y]+(i*stepG);
        B:=bitmapB[x,y]+(i*stepB);
        image1.canvas.pixels[x*scale+i,y*scale]:=rgb(R,G,B);
      end;
    end;
  end;

  //interpolar vertical
  for x:=0 to image1.width*scale-1 do     //loop tinggi image
  begin
    for y:=0 to image1.height-1 do        //loop lebar image
    begin
      //tampung warna piksel image yang sudah terinterpolasi horizontal
      R1:= Red(image1.Canvas.Pixels[x,y*scale]);
      R2:= Red(image1.Canvas.Pixels[x,(y+1)*scale]);

      G1:= Green(image1.Canvas.Pixels[x,y*scale]);
      G2:= Green(image1.Canvas.Pixels[x,(y+1)*scale]);

      B1:= Blue(image1.Canvas.Pixels[x,y*scale]);
      B2:= Blue(image1.Canvas.Pixels[x,(y+1)*scale]);

      //isi variabel dengan rumus (fi2-fi1/skala)
      stepR:=round((R2-R1)/scale);
      stepG:=round((G2-G1)/scale);
      stepB:=round((B2-B1)/scale);
      for i:=1 to scale-1 do
      begin
        //isi piksel kosong secara vertikal ||||||||
        R:=R1+(i*stepR);
        G:=G1+(i*stepG);
        B:=B1+(i*stepB);
        image1.canvas.pixels[x,y*scale+i]:=rgb(R,G,B);
      end;
    end;
  end;
  OnUpdate(Sender); //optional. untuk update bitmap
end;

procedure TForm1.scalexBarChange(Sender: TObject);
begin
  scaleText.Text:=IntToStr(scalexBar.Position);
end;

procedure TForm1.thresBarChange(Sender: TObject);
begin
  thresText.Text:=IntToStr(thresBar.Position);      //update text
  for y:=0 to Image1.Height-1 do                    //loop sebanyak tinggi image
  begin
    for x:=0 to Image1.Width-1 do                   //loop sebanyak lebar image
    begin
      gray:= (bitmapR[x,y]+bitmapG[x,y]+bitmapB[x,y]) div 3;//buat nilai gray
      if gray<=thresBar.Position then               //cek nilai gray
        thres[x,y]:=true                            //jika true
      else
        thres[x,y]:=false                           //jika false
    end;
  end;
end;

procedure TForm1.thresholdClick(Sender: TObject);
begin
  for y:=0 to image1.height-1 do                  //loop sebanyak tinggi image
  begin
    for x:=0 to image1.width-1 do                 //loop sebanyak lebar image
    begin
      if thres[x,y] = false then                  //cek nilai biner jika false
      begin
        image1.canvas.pixels[x,y]:=rgb(255,255,255)//ubah piksel image jadi putih
      end
      else                                     //else atau true
      begin
        image1.canvas.pixels[x,y]:=rgb(0,0,0); //ubah piksel image jadi hitam
      end;
    end;
  end;
end;

function TForm1.truncate(a: integer): integer;
begin
  if a > 255 then
  begin
    a:=255;
  end
  else if a < 0 then
  begin
    a:=0;
  end;
  result := a;
end;

procedure TForm1.OnStart(Sender: TObject);
begin
  w:=image1.width;
  h:=image1.height;
  bw:=image1.picture.bitmap.width;
  bh:=image1.picture.bitmap.height;
  rText.Text:=IntToStr(redBar.Position);
  gText.Text:=IntToStr(greenBar.Position);
  bText.Text:=IntToStr(blueBar.Position);
  scaleText.Text:=IntToStr(scalexBar.Position);
  thresText.Text:=IntToStr(thresBar.Position);
  kernel.Text:=IntToStr(kernelBar.Position);
  lpf.Checked:=true;;
  for y:=0 to image1.height-1 do
  begin
    for x:=0 to image1.width-1 do
    begin
      clr[x,y]:=image1.canvas.pixels[x,y];
    end;
  end;
end;

procedure TForm1.OnUpdate(Sender: TObject);
begin
  for y:=0 to image1.height-1 do
  begin
    for x:=0 to image1.width-1 do
    begin
      bitmapR[x,y]:=red(image1.Canvas.Pixels[x,y]);
      bitmapG[x,y]:=green(image1.Canvas.Pixels[x,y]);
      bitmapB[x,y]:=blue(image1.Canvas.Pixels[x,y]);
    end;
  end;
end;

procedure TForm1.InitKernelMean();
begin
  if lpf.Checked = true then
  begin
    for y:= 1 to k do                            //loop sebanyak kernel
    begin
      for x:= 1 to k do
      begin
        kernelMean[x,y]:= 1/(k*k);              //Kernel Smoothing
      end;
    end;
  end
  else
  begin
    for y:= 1 to k do                           //loop sebanyak kernel
    begin
      for x:= 1 to k do
      begin
        kernelMean[x, y]:= -1;
      end;
    end;
    if hpf.Checked = true then
      kernelMean[kHalf, kHalf]:= (k*k)-1        //Kernel Deteksi Tepi
    else if hpf1.Checked = true then
      kernelMean[kHalf, kHalf]:= (k*k);         //Kernel Sharpen
  end;
end;

procedure TForm1.PaddingBitmap();
begin;
  //buat padding vertikal
  for y:= 0 to image1.height+kHalf  do          //loop sebanyak tinggi+kernel/2
  begin
    for x:= 0 to kHalf-1 do                     //sebanyak kernel div 2
    begin
      paddingR[0+x,y]:=255;                     //sisi kiri
      paddingR[image1.width+kHalf+x,y]:=255;    //sisi kanan

      paddingG[0+x,y]:=255;
      paddingG[image1.width+kHalf+x,y]:=255;

      paddingB[0+x,y]:=255;
      paddingB[image1.width+kHalf+x,y]:=255;
    end;
  end;

  //padding horizontal
  for x:= 0 to image1.width+kHalf do            //loop sebanyak lebar+kernel/2
  begin
    for y:= 0 to kHalf-1 do                     //sebanyak kernel div 2
    begin
      paddingR[x,0+y]:= 255;                    //sisi atas
      paddingR[x,image1.height+kHalf+y]:=255;   //sisi bawah

      paddingG[x,0+y]:= 255;
      paddingG[x,image1.height+kHalf+y]:=255;

      paddingB[x,0+y]:= 255;
      paddingB[x,image1.height+kHalf+y]:=255;
    end;
  end;

  //isi bagian bukan padding
  for y:= kHalf to (image1.height+kHalf-1) do
  begin
    for x:= kHalf to (image1.width+kHalf-1) do
    begin
      paddingR[x,y]:= bitmapR[x-kHalf,y-kHalf];  //isi dengan warna bitmap
      paddingG[x,y]:= bitmapG[x-kHalf,y-kHalf];
      paddingB[x,y]:= bitmapB[x-kHalf,y-kHalf];
    end;
  end;
end;





end.

