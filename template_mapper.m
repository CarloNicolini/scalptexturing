addpath(genpath('~/Psychtoolbox/'));
addpath('arcball/');
Screen('CloseAll');
clear all;
close all;
KbName('UnifyKeyNames');


ScalpOBJ = LoadOBJFile2('ScalpSurfaceMesh.obj');
%if ~isfield(ScalpOBJ.normals)
    ScalpOBJ = AddNormalsToOBJ(ScalpOBJ);
%end

PortionOBJ = LoadOBJFile2('Portion_rightside.obj');
%if ~isfield(PortionOBJ.normals)
%    PortionOBJ = AddNormalsToOBJ(PortionOBJ);
%end

mesh_projection(ScalpOBJ,PortionOBJ);