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

% Calculate the ellipsoid parameters
ellipsoid.X = single(dlmread('allcoords.txt'))';
[ ellipsoid.center, ellipsoid.radii, ellipsoid.evecs, ellipsoid.v, ellipsoid.chi2 ] = ellipsoid_fit(ellipsoid.X');

mesh_projection(ScalpOBJ,PortionOBJ,ellipsoid);