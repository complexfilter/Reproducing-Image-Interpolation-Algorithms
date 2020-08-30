function Znew=bicubic(f)
%�ú�������������ͼ�����е�˫�������Բ�ֵ����
%f����Ҫ�����ͼ���ļ�
%Z��ԭʼͼ��z=f(x,y)�ĻҶ�ֵ�ľ���
%Xnew,Ynew�����µ�ͼ�������϶�Ӧ���������ά��
%Znew�ǲ�ֵ���µ�ͼ�����
Z=f;%imread(f);
%imshow(Z);
%title('ԭʼͼ��');
[dim(1) dim(2) dim(3)]=size(Z);%��ȡͼ��ά���������ж��Ƿ��ɫͼ��

Zold=double(Z);%ת��Ϊ˫�����ͼ�С��ֵ���
for i=1:2
   for j=1:2
      Znew(i:2:2*dim(1),j:2:2*dim(2))=Zold;%�ϲ�����������С
   end
end
Xnew=2*dim(1);
Ynew=2*dim(2);
      
        for i=1:2:Xnew
            for j=2:2:Ynew
                P2=[Znew(i,max(j-3,1))    Znew(i,j-1)   Znew(i,min(j+1,Ynew-1))   Znew(i,min(j+3,Ynew-1))];
                a=[-(1/16) 9/16 9/16 -(1/16)]';
                Znew(i,j)=P2*a;
            end
        end
        for i=2:2:Xnew
            for j=1:2:Ynew
                P3=[Znew(max(i-3,1),j)    Znew(i-1,j)   Znew(min(i+1,Xnew-1),j)   Znew(min(i+3,Xnew-1),j)];
                a=[-(1/16) 9/16 9/16 -(1/16)]';
                Znew(i,j)=P3*a;
            end
        end
        for i=2:2:Xnew-2
            for j=2:2:Ynew-2
                P1 = [Znew(i,max(j-3,1))    Znew(i,j-1)   Znew(i,min(j+1,Ynew-1))   Znew(i,min(j+3,Ynew-1))];
                a=[-(1/16) 9/16 9/16 -(1/16)]';
                Znew(i,j)=P1*a;
               
            end
        end
        %����
for i=1:Xnew
    Znew(i,Ynew)=Znew(i,Ynew-1);
end
for j=1:Ynew
    Znew(Xnew,j)=Znew(Xnew-1,j);
end
Znew=uint8(Znew);
%figure;
%imshow(Znew);
%title('bicubic��ֵ��ͼ��');