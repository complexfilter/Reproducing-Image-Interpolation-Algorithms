function y2=RMLS_Interpolation_my_understanding(x,options)   % 2X enlarge 
     options.y_bilinear = double(bilinearup2(x));
     y1= first_pass(x ,options);
     y2=second_pass(y1,options);
end
%% first pass
function y=first_pass(x,options)
MP=30;% pad size
[m,n]=size(x);
x=double(x);
y = double(bicubic(x));
% pad orignal image
Eim = [repmat(y(1,:),MP,1);y;repmat(y(2*m,:),MP,1)];
Eim = [repmat(Eim(:,1),1,MP),Eim,repmat(Eim(:,2*n),1,MP)];
rang=255;
% rang=0;
Eim=Eim+rang;
% threshold
% th=10000;
win=options.win;         %trainnig window
swin=options.swin;       %similarity window
lamda = options.lamda;
deta  = options.deta;
cnt=1;
nx=zeros(4*win^2,1);
ny=zeros(4*win^2,1);

for i=-2*(win-1)-1:2:2*win
    for j=-2*(win-1)-1:2:2*win
        nx(cnt)=j;
        ny(cnt)=i;
        cnt=cnt+1;
    end
end

iy=[-1 -1  1 1];
ix=[-1  1 -1 1];
my=[-1 -1  1 1];
mx=[-1  1 -1 1];

[M,N]=size(Eim);
pixel_number = 2*win*2*win;  
unlabel_number = (2*win-1)^2;
proceeded_unlabel_number = floor((2*win-1)^2/2); 
Y_hat = zeros(1,proceeded_unlabel_number);           
%%%%%%%%%
w = 2*swin+1;
L = (2*win)^2;
X=zeros(w*w,L);
label_neighbor=zeros(4*win^2,4);
location_diff=zeros(2,4*win^2);
kernel = options.kernel;
%%%%%%%%%%
count = 1;

for i=1+MP+1:2:M-MP+1
   for j=1+MP+1:2:N-MP+1

      unlabel_neighbor = diag(Eim(i+my,j+mx));
      unlabel_neighbor_extend = [unlabel_neighbor' 1]';
      
if count>1  
  if var(unlabel_neighbor)<options.th 
     fxi = options.y_bilinear((i-MP),(j-MP))+255;
     wi = [0.25,0.25,0.25,0.25,0];
  else
      for k=1:4
        label_neighbor(:,k)=diag(Eim(i+2*iy(k)+ny,j+2*ix(k)+nx));
      end
      label_neighbor_extend = [label_neighbor ones(2*win*2*win,1)]';
      label_value = diag(Eim(i+ny,j+nx))';
      center = Eim(i-swin:i+swin,j-swin:j+swin);
      CB_kernel = center.*kernel;
      CB_kernel = CB_kernel(:);
      CB_kernel = repmat(CB_kernel,1,L); 
      k=1;
      for ii=i-2*(win-1)-1:2:i+2*win
          for jj=j-2*(win-1)-1:2:j+2*win
             sample =  Eim(ii-2*swin:2:ii+2*swin,jj-2*swin:2:jj+2*swin);%label sample similar win
             sample_kernel = sample.*kernel;
             sample_kernel = sample_kernel(:);
             X(:,k) = sample_kernel;
             location_diff(:,k) = [ii-i,jj-j];
             k=k+1;              
          end
      end        
      if options.weight_fg == 0
         weight=Computweight_matrix(CB_kernel,X);
      elseif options.weight_fg == 1
         weight=Computweight_matrix_bilateral(CB_kernel,X,location_diff); 
      end
      [S,Y_hat] = GetInformationForUnlabel_firstpass(i,j,win,swin,Eim,options);
      [wi, fxi] = RMLS_mm(unlabel_neighbor_extend, weight, label_value, label_neighbor_extend, lamda, S, Y_hat, deta);
   end
else
     if var(unlabel_neighbor)<options.th 
        fxi = options.y_bilinear((i-MP),(j-MP))+255;
        wi = [0.25,0.25,0.25,0.25,0];
     else
        for k=1:4
            label_neighbor(:,k)=diag(Eim(i+2*iy(k)+ny,j+2*ix(k)+nx));
        end
        label_neighbor_extend = [label_neighbor ones(2*win*2*win,1)]';
        label_value = diag(Eim(i+ny,j+nx))';

        center = Eim(i-swin:i+swin,j-swin:j+swin);
        CB_kernel = center.*kernel;
        CB_kernel = CB_kernel(:);
        CB_kernel = repmat(CB_kernel,1,L);
 
        k=1;
        for ii=i-2*(win-1)-1:2:i+2*win
          for jj=j-2*(win-1)-1:2:j+2*win
             sample = Eim(ii-2*swin:2:ii+2*swin,jj-2*swin:2:jj+2*swin);%label sample similar win
             sample_kernel = sample.*kernel;
             sample_kernel = sample_kernel(:);
             X(:,k) = sample_kernel;
             location_diff(:,k) = [ii-i,jj-j];
             k=k+1;              
          end
        end        
        if options.weight_fg == 0
           weight=Computweight_matrix(CB_kernel,X);
        elseif options.weight_fg == 1
           weight=Computweight_matrix_bilateral(CB_kernel,X,location_diff); 
        end
        [wi, fxi] = RMLS_mm_my_understanding(unlabel_neighbor_extend, weight, label_value, label_neighbor_extend);
      end
end
     Eim(i,j) = fxi;
     tempval=fxi-rang;
     if (tempval>=0)&&(tempval<=255)
        y((i-MP),(j-MP))=tempval;
     end 
     count = count+1;
   end
end
end
%% second pass
function y=second_pass(x,options)
y=x;
MP=30;
[m,n]=size(x);
Eim = [repmat(x(1,:),MP,1);x;repmat(x(m,:),MP,1)];
Eim = [repmat(Eim(:,1),1,MP),Eim,repmat(Eim(:,n),1,MP)];
my=[0 0 1 -1];
mx=[-1 1 0 0];
% th=10000;
win=options.win-1;
swin=options.swin;
cnt=1;
lamda = options.lamda;
deta = options.deta;
rang=255;
% rang=0;
Eim=Eim+rang;
for i=-(win-1):win
    for j=-(win-1):win
        nx(cnt)=i-j;ny(cnt)=i+j-1;cnt=cnt+1;
    end
end
[M,N]=size(Eim);
Y_hat = zeros(1,24);
%%%%%%%%%
w = 2*swin+1;
L = (2*win)^2;
X=zeros(w*w,L);
% kernel = make_kernel(swin);
% kernel = kernel / sum(sum(kernel));%normalization
% options.kernel = kernel;
kernel = options.kernel;
%%%%%%%%%%
count = 1;
for i=1+MP+1:2:M-MP
   for j=1+MP:2:N-MP
       fprintf('%d_%d\n',i,j);      
      unlabel_neighbor = diag(Eim(i+my,j+mx));
      unlabel_neighbor_extend = [unlabel_neighbor' 1]';
      if count>1
          if var(unlabel_neighbor)<options.th 
               wi = [0.25,0.25,0.25,0.25,0];
               fxi = sum(unlabel_neighbor'.*[0.25,0.25,0.25,0.25]);
          else   
               center = Eim(i-swin:i+swin,j-swin:j+swin);
               CB_kernel = center.*kernel;
               CB_kernel = CB_kernel(:);
               CB_kernel = repmat(CB_kernel,1,L);
               for k=1:(2*win)^2
                   r(k,1)=Eim(i+ny(k),j+nx(k));
                   pos(k,1)=i+ny(k);
                   pos(k,2)=j+nx(k);
                   C(k,:)=[Eim(i+2*my(1)+ny(k),j+2*mx(1)+nx(k)) Eim(i+2*my(2)+ny(k),j+2*mx(2)+nx(k)) Eim(i+2*my(3)+ny(k),j+2*mx(3)+nx(k)) Eim(i+2*my(4)+ny(k),j+2*mx(4)+nx(k))];
                   sample = Eim(pos(k,1)-2*swin:2:pos(k,1)+2*swin,pos(k,2)-2*swin:2:pos(k,2)+2*swin);
                   sample_kernel = sample.*kernel;
                   sample_kernel = sample_kernel(:);
                   X(:,k) = sample_kernel;
                   location_diff(:,k) = [pos(k,1)-i,pos(k,2)-j];
               end
               weight=Computweight_matrix_bilateral(CB_kernel,X,location_diff); 
               label_value = r';
               label_neighbor_extend = [C ones(2*win*2*win,1)]';
               [S,Y_hat] = GetInformationForUnlabel_secondpass(i,j,pos,win,swin,Eim,0,options);
               [wi, fxi] = RMLS_mm_my_understanding(unlabel_neighbor_extend, weight, label_value, label_neighbor_extend, S, Y_hat, deta);
           end
      else
           if var(unlabel_neighbor)<options.th 
                 wi = [0.25,0.25,0.25,0.25,0];
                fxi = sum(unlabel_neighbor'.*[0.25,0.25,0.25,0.25]);
           else
               center = Eim(i-swin:i+swin,j-swin:j+swin);
               CB_kernel = center.*kernel;
               CB_kernel = CB_kernel(:);
               CB_kernel = repmat(CB_kernel,1,L);%�ظ�L��
               for k=1:(2*win)^2
                   r(k,1)=Eim(i+ny(k),j+nx(k));
                   pos(k,1)=i+ny(k);pos(k,2)=j+nx(k);
                   C(k,:)=[Eim(i+2*my(1)+ny(k),j+2*mx(1)+nx(k)) Eim(i+2*my(2)+ny(k),j+2*mx(2)+nx(k)) Eim(i+2*my(3)+ny(k),j+2*mx(3)+nx(k)) Eim(i+2*my(4)+ny(k),j+2*mx(4)+nx(k))];
                   sample = Eim(pos(k,1)-2*swin:2:pos(k,1)+2*swin,pos(k,2)-2*swin:2:pos(k,2)+2*swin);
                   sample_kernel = sample.*kernel;
                   sample_kernel = sample_kernel(:);
                   X(:,k) = sample_kernel;
                   location_diff(:,k) = [pos(k,1)-i,pos(k,2)-j];
               end
               weight=Computweight_matrix_bilateral(CB_kernel,X,location_diff); 
               label_value = r';
               label_neighbor_extend = [C ones(2*win*2*win,1)]';              
               [wi, fxi] = RMLS_mm(unlabel_neighbor_extend, weight, label_value, label_neighbor_extend, lamda);
          end
      end     
           
      Eim(i,j) = fxi;
      tempval=fxi-rang;
      if (tempval>=0)&&(tempval<=255)
         y((i-MP),(j-MP))=tempval;
      end 
      count = count+1;
   end
end

count = 1;
for i=1+MP:2:M-MP
   for j=1+MP+1:2:N-MP
       unlabel_neighbor = diag(Eim(i+my,j+mx));
       unlabel_neighbor_extend = [unlabel_neighbor' 1]';
       if count>1
          if var(unlabel_neighbor)<options.th 
                 fxi = sum(unlabel_neighbor'.*[0.25,0.25,0.25,0.25]);
                  wi = [0.25,0.25,0.25,0.25,0];
          else
             center = Eim(i-swin:i+swin,j-swin:j+swin);
             CB_kernel = center.*kernel;
             CB_kernel = CB_kernel(:);
             CB_kernel = repmat(CB_kernel,1,L);
             for k=1:(2*win)^2
                 r(k,1)=Eim(i+ny(k),j+nx(k));
                 pos(k,1)=i+ny(k);pos(k,2)=j+nx(k);
                 C(k,:)=[Eim(i+2*my(1)+ny(k),j+2*mx(1)+nx(k)) Eim(i+2*my(2)+ny(k),j+2*mx(2)+nx(k)) Eim(i+2*my(3)+ny(k),j+2*mx(3)+nx(k)) Eim(i+2*my(4)+ny(k),j+2*mx(4)+nx(k))];
                 sample = Eim(pos(k,1)-2*swin:2:pos(k,1)+2*swin,pos(k,2)-2*swin:2:pos(k,2)+2*swin);
                 sample_kernel = sample.*kernel;
                 sample_kernel = sample_kernel(:);
                 X(:,k) = sample_kernel;                
                 location_diff(:,k) = [pos(k,1)-i,pos(k,2)-j];
             end

             weight=Computweight_matrix_bilateral(CB_kernel,X,location_diff); 
             label_value = r';
             label_neighbor_extend = [C ones(2*win*2*win,1)]';
             [S,Y_hat] = GetInformationForUnlabel_secondpass(i,j,pos,win,swin,Eim,1,options);
             [wi, fxi] = RMLS_mm(unlabel_neighbor_extend, weight, label_value, label_neighbor_extend, lamda, S, Y_hat, deta);
           end
       else
           if var(unlabel_neighbor)<options.th 
             fxi = sum(unlabel_neighbor'.*[0.25,0.25,0.25,0.25]);
              wi = [0.25,0.25,0.25,0.25,0];
           else
             center = Eim(i-swin:i+swin,j-swin:j+swin);
             CB_kernel = center.*kernel;
             CB_kernel = CB_kernel(:);
             CB_kernel = repmat(CB_kernel,1,L);
             for k=1:(2*win)^2
                 r(k,1)=Eim(i+ny(k),j+nx(k));
                 pos(k,1)=i+ny(k);pos(k,2)=j+nx(k);
                 C(k,:)=[Eim(i+2*my(1)+ny(k),j+2*mx(1)+nx(k)) Eim(i+2*my(2)+ny(k),j+2*mx(2)+nx(k)) Eim(i+2*my(3)+ny(k),j+2*mx(3)+nx(k)) Eim(i+2*my(4)+ny(k),j+2*mx(4)+nx(k))];
                 sample = Eim(pos(k,1)-2*swin:2:pos(k,1)+2*swin,pos(k,2)-2*swin:2:pos(k,2)+2*swin);
                 sample_kernel = sample.*kernel;
                 sample_kernel = sample_kernel(:);
                 X(:,k) = sample_kernel;                
                 location_diff(:,k) = [pos(k,1)-i,pos(k,2)-j];
             end
             weight=Computweight_matrix_bilateral(CB_kernel,X,location_diff);
             label_value = r';
             label_neighbor_extend = [C ones(2*win*2*win,1)]';
             [wi, fxi] = RMLS_mm(unlabel_neighbor_extend, weight, label_value, label_neighbor_extend);             
           end
       end     
      Eim(i,j) = fxi;
      tempval=fxi-rang;
      if (tempval>=0)&&(tempval<=255)
         y((i-MP),(j-MP))=tempval;
      end 
      count = count+1;
   end
end
end