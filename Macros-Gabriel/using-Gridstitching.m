clear all;
javaaddpath 'C:\Program Files (x86)\Matlab\R2018a\java\mij.jar';
javaaddpath 'C:\Program Files (x86)\Matlab\R2018a\java\ij.jar'
MIJ.start;
%% Parameters
% direction of the folder where filters are stored
dirFilter="D:\Filters\";
folder="C:\Users\Gabriel Thon\Desktop\Codes\Matlab\210526-Image-formatting-grid-stitching\test\";
Gridstitching(dirFilter,folder);
