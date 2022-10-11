import numpy as np
import matlab.engine

# Gets called when this file is imported. This takes 20 seconds or so.
eng = matlab.engine.start_matlab()

# Matlab imports
eng.addpath(eng.genpath('src/matlab/meshChecker'))
eng.addpath(eng.genpath('src/matlab/gptoolbox'))

def to_mat(a):
    a = to_mat_indexing(a)
    a = to_mat_type(a)
    return a

def to_mat_type(a: np.ndarray) -> matlab.double:
    """
    Convert a numpy array into a matlab array.
    Matlab only works with pure python data so we have to convert
    to a list first. If you pass matlab the list, it treats it as
    a cell array so we must convert that type to double.
    """
    return matlab.double(a.tolist())

def to_mat_indexing(a):
    """
    Given a numpy array that contains indexes of something else as their values,
    convert these indexes from 0-based to 1-based for matlab use.
    """
    # Do nothing if it's already in 1-based indexing
    if 0 in a:
        a = a + 1
    return a

def plotMesh(F, V):
    eng.plotMesh(to_mat(F), to_mat(V), nargout=0)

def read_ply(filename):
    V, F, _, _ = eng.read_ply(filename, nargout=4)
    V = np.asarray(V)
    F = np.asarray(F)
    return F, V

def check_mesh(faces, vertices):
    faces = to_mat(faces)
    vertices = to_mat(vertices)
    is_correct, msg = eng.check_mesh(faces, vertices, nargout=2)
    return is_correct, msg

def mesh_checker2q(faces, vertices):
    faces = to_mat(faces)
    vertices = to_mat(vertices)
    eng.mesh_checker2q(faces, vertices, nargout=0)

def get_Q(faces, vertices):
    faces = to_mat(faces)
    vertices = to_mat(vertices)
    Q = eng.get_Q(faces, vertices, nargout=1)
    return Q

def get_AR(faces, vertices):
    faces = to_mat(faces)
    vertices = to_mat(vertices)
    AR = eng.get_AR(faces, vertices, nargout=1)
    AR = np.asarray(AR)
    return AR

def get_angle_stats(faces, vertices):
    faces = to_mat(faces)
    vertices = to_mat(vertices)
    min_angle, max_angle, imin_angle, imax_angle = eng.get_angle_stats(faces, vertices, nargout=4)
    return min_angle, max_angle, imin_angle, imax_angle

def get_mesh_quality(faces, vertices):
    faces = to_mat(faces)
    vertices = to_mat(vertices)
    Q, AR_avg, min_angle, AR = eng.get_mesh_quality(faces, vertices, nargout=4)
    AR = np.asarray(AR)
    return Q, AR, min_angle

def get_mesh_quality_brief(faces, vertices):
    faces = to_mat(faces)
    vertices = to_mat(vertices)
    Q, AR_avg, min_angle = eng.get_mesh_quality(faces, vertices, nargout=3)
    return Q, AR_avg, min_angle

def get_valence(faces, vertices):
    faces = to_mat(faces)
    vertices = to_mat(vertices)
    min_valence, max_valence, imin_valence, imax_valence = eng.get_valence(faces, vertices, nargout=4)
    return max_valence