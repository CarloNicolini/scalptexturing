addpath(genpath('~/Psychtoolbox/'));

Screen('CloseAll');
clear all;
close all;

L = LoadOBJFile('ScalpSurfaceMeshUV.obj');
KbName('UnifyKeyNames');
%L=LoadOBJFile('~/workspace/cncsvision/data/objmodels/happyBuddha.obj');
% Compute the normals to the mesh surface 
%LN = AddNormalsToOBJ(L);

mesh_projection(L,1,true);