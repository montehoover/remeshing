import glob
from pstats import Stats
import numpy as np
import optimesh
import pandas as pd
import pygalmesh
import pymeshlab as ml
import yaml

import copy
import sys
import time
from functools import wraps
from pathlib import Path

class Mesh():
    def __init__(self, F, V):
        self.F = F
        self.V = V
        self.n_faces = self.F.shape[0]
        self.n_vertices = self.V.shape[0]

    def copy(self):
        return copy.deepcopy(self)

    def to_mat_indexing(self):
        return to_mat_indexing(self)

    def avg_edge_len(self):
        return get_avg_edge_len(self)

def time_it(func):
    """
    Add "@time_it" decorator to the top of any function definition for which we
    want to print runtime information.
    """
    @wraps(func)
    def _time_it(*args, **kwargs):
        print(f"Running {func.__name__}...")
        start = time.perf_counter()
        result = func(*args, **kwargs)
        end = time.perf_counter()
        elapsed = end - start
        print(f"{func.__name__} completed in {elapsed:.2f} s")
        return result
    return _time_it


def get_config(args):
    config = {}

    # Defaults:
    config["meshes"] = [args.mesh]
    config["algs"] = [args.alg]
    config["results_file"] = sys.stdout
    config["plot"] = True
    config["force_rerun"] = False
    config["write_bem_files"] = False
    config["clean"] = False

    # If yaml config file provided
    if args.config:
        with open(args.config) as f:
            yaml_dict = yaml.safe_load(f)
        
        meshes = []
        for filename in yaml_dict["meshes"]:
            # Accept individual filenames or glob patterns (folder/* or folder/**/*)
            meshes += glob.glob(filename)
        
        config["meshes"] = meshes
        if yaml_dict["results_file"]:
            config["results_file"] = open(yaml_dict["results_file"], "a")
        config["plot"] = yaml_dict["plot"]
        config["force_rerun"] = yaml_dict["force_rerun"]
        config["write_bem_files"] = yaml_dict["write_bem_files"]
        config["bem_scale"] = yaml_dict["bem_scale"]
        config["clean"] = yaml_dict["clean"]

    return config


def to_mat_indexing(mesh):
    """
    Given a numpy array that contains indexes of something else as their values,
    convert these indexes from 0-based to 1-based for matlab use.
    """
    mesh = mesh.copy()
    # Do nothing if it's already in 1-based indexing
    if 0 in mesh.F:
        mesh.F = mesh.F + 1
    return mesh

def from_mat_indexing(mesh):
    """
    Given a numpy array that contains indexes of something else as their values,
    convert these indexes from 1-based (Matlab) to 0-based.
    """
    mesh = mesh.copy()
    # Do nothing if it's already in 1-based indexing
    if 0 not in mesh.F:
        mesh.F = mesh.F - 1
    return mesh    

def get_avg_edge_len(mesh):
    ms = ml.MeshSet()
    ms.add_mesh(ml.Mesh(mesh.V, mesh.F))
    geo_stats = ms.get_geometric_measures()
    avg_edge_len = geo_stats["avg_edge_length"]
    return avg_edge_len

def get_AR_stats(AR):
    AR_avg = np.nanmean(AR)
    AR_min = np.nanmin(AR)
    # What percent of triangle Aspect Ratios are below a certain value
    AR7 = np.sum(AR < 0.7) / AR.size
    AR4 = np.sum(AR < 0.4) / AR.size
    AR3 = np.sum(AR < 0.3) / AR.size
    return AR_avg, AR_min, AR7, AR4, AR3

def get_stats_full(mesh):
    from .bindings import matlab as mat
    Q, AR, min_angle = mat.get_mesh_quality(mesh.F, mesh.V)
    is_correct, msg, valence = check_mesh(mesh)
    AR_avg, AR_min, AR7, AR4, AR3 = get_AR_stats(AR)
    n_faces = mesh.n_faces
    avg_edge_len = get_avg_edge_len(mesh)
    if not is_correct:
        mesh = clean_mesh(mesh)
    concave_ratio, convex_ratio = get_curvature(mesh)
    total_curvature = concave_ratio + convex_ratio
    return Q, AR, AR_avg, AR_min, AR7, AR4, AR3, min_angle, valence, n_faces, avg_edge_len, concave_ratio, convex_ratio, total_curvature, is_correct, msg

def get_stats_brief(mesh):
    from .bindings import matlab as mat
    Q, AR_avg, min_angle = mat.get_mesh_quality_brief(mesh.F, mesh.V)
    is_correct, msg, valence = check_mesh(mesh)
    n_faces = mesh.n_faces
    avg_edge_len = get_avg_edge_len(mesh)
    return Q, AR_avg, min_angle, n_faces, avg_edge_len, is_correct, msg

def check_mesh(mesh):
    from .bindings import matlab as mat
    is_correct, msg = mat.check_mesh(mesh.F, mesh.V)
    
    try:
        valence = mat.get_valence(mesh.F, mesh.V) 
    except Exception as e:
        if "valency" in str(e) and "left and right sides have a different number of elements" in str(e):
            valence = None
            is_correct = False
            msg += " Issue with the number of edges compared to vertices."
        else:
            raise
    intersects, intersects_msg = check_intersections_and_folds(mesh)
    if intersects:
        is_correct = False
        msg += intersects_msg
    return is_correct, msg, valence


def check_intersections_and_folds(mesh):
    ms = ml.MeshSet()
    ms.add_mesh(ml.Mesh(mesh.V, mesh.F))
    intersects = False
    msg = "No self-intersecting or folded faces"
    ms.compute_selection_by_self_intersections_per_face()
    if ms.current_mesh().selected_face_number() > 0:
        intersects = True
        msg = " Found self-intersecting faces."
    try:
        # The mesh has to be oriented correctly or else the folded faces won't be selected properly. 
        ms.meshing_re_orient_faces_coherentely()
        ms.meshing_re_orient_faces_coherentely()
    except(Exception) as e:
        print(e, "Continuing...")
    ms.compute_selection_bad_faces(usear=False, usenf=True, select_folded_faces=True)
    if ms.current_mesh().selected_face_number() > 0:
        intersects = True
        msg = " Found folded faces."
    return intersects, msg


### Experimental. ###
def clean_mesh(mesh):
    print("Cleaning mesh...")
    ms = ml.MeshSet()
    ms.add_mesh(ml.Mesh(mesh.V, mesh.F))
    ITER_LIMIT = 25
    INNER_LIMIT = 10
    outer_iter = 0
    # Before iterating, first remove any obvious problems that might contribute to manifold/holes issues
    # Remove extraneous vertices, faces, and parts
    ms.meshing_remove_duplicate_vertices()
    ms.meshing_remove_duplicate_faces()
    ms.meshing_remove_connected_component_by_face_number()
    # Select and delete incorrect faces
    ms.compute_selection_by_self_intersections_per_face()
    ms.meshing_remove_selected_vertices_and_faces()

    # Fix manifold issues, holes, and self-intersections in this loop.
    # A second loop will follow to fix folded faces
    topo = ms.get_topological_measures()
    ms.compute_selection_by_self_intersections_per_face()
    while (outer_iter < ITER_LIMIT and (
           not topo["is_mesh_two_manifold"] or
           topo["number_holes"] > 0 or
           ms.current_mesh().selected_face_number() > 0)):
        
        inner_iter = 0
        # Fix the basic manifold problems
        topo = ms.get_topological_measures()
        while not topo["is_mesh_two_manifold"] and inner_iter < INNER_LIMIT:
            ms.meshing_repair_non_manifold_edges(method="Remove Faces")
            ms.meshing_repair_non_manifold_vertices()
            topo = ms.get_topological_measures()
            inner_iter += 1
        inner_iter = 0

        # Fix the basic holes
        topo = ms.get_topological_measures()
        while topo["number_holes"] > 0 and inner_iter < INNER_LIMIT:
            ms.meshing_close_holes()
            topo = ms.get_topological_measures()
            inner_iter += 1
        inner_iter = 0

        # Now work on the self-intersections and folded faces
        try:
            # The mesh has to be manifold to re-orient the faces, but we need them oriented correctly or else
            # the folded faces won't be selected properly.
            ms.meshing_re_orient_faces_coherentely()
            ms.meshing_re_orient_faces_coherentely()
        except(Exception) as e:
            print(e, "Continuing...")
        ms.compute_selection_by_self_intersections_per_face()
        while ms.current_mesh().selected_face_number() > 0 and inner_iter < INNER_LIMIT:
            ms.meshing_remove_selected_vertices_and_faces()
            ms.compute_selection_bad_faces(usear=False, usenf=True, select_folded_faces=True)
            ms.meshing_remove_selected_vertices_and_faces()
            ms.compute_selection_from_mesh_border()
            ms.meshing_remove_selected_vertices_and_faces()
            ms.meshing_close_holes()
            ms.meshing_close_holes()
            ms.meshing_close_holes()
            ms.compute_selection_by_self_intersections_per_face()
            inner_iter += 1
        inner_iter = 0
        
        topo = ms.get_topological_measures()
        ms.compute_selection_by_self_intersections_per_face()
        outer_iter += 1
    outer_iter = 0

    # A loop specifically for folded faces:
    try:
        # The mesh has to be oriented correctly or else
        # the folded faces won't be selected properly. 
        ms.meshing_re_orient_faces_coherentely()
        ms.meshing_re_orient_faces_coherentely()
    except(Exception) as e:
        print(e, "Continuing...")
    topo = ms.get_topological_measures()
    ms.compute_selection_bad_faces(usear=False, usenf=True, select_folded_faces=True)
    while (outer_iter < ITER_LIMIT and (
            topo["number_holes"] > 0 or 
            ms.current_mesh().selected_face_number() > 0)
            ):      
        ms.meshing_remove_selected_vertices_and_faces()
        ms.compute_selection_from_mesh_border()
        ms.meshing_remove_selected_vertices_and_faces()
        if outer_iter > 1:
            # If folded faces persist, trydeleting a double selection of the border
            ms.compute_selection_from_mesh_border()
            ms.meshing_remove_selected_vertices_and_faces()
        ms.meshing_close_holes()
        ms.meshing_close_holes()
        ms.meshing_close_holes()
        topo = ms.get_topological_measures()
        if topo["number_holes"] > 0:
            # If holes persist, try deleting a double selection of the border
            ms.compute_selection_from_mesh_border()
            ms.meshing_remove_selected_vertices_and_faces()
            ms.compute_selection_from_mesh_border()
            ms.meshing_remove_selected_vertices_and_faces()
            ms.meshing_close_holes()
            ms.meshing_close_holes()
            ms.meshing_close_holes()
        topo = ms.get_topological_measures()
        ms.compute_selection_bad_faces(usear=False, usenf=True, select_folded_faces=True)
        outer_iter += 1

    # Fix orientation
    ms.meshing_remove_connected_component_by_face_number()    
    ms.meshing_re_orient_faces_coherentely()
    ms.meshing_re_orient_faces_coherentely()
    ms.meshing_re_orient_faces_coherentely()
    
    # Final checks
    F = ms.current_mesh().face_matrix()
    V = ms.current_mesh().vertex_matrix()
    mesh = Mesh(F, V)
    from .bindings import matlab as mat
    is_correct, msg = mat.check_mesh(mesh.F, mesh.V)
    issues = 0
    if not is_correct:
        issues += 1
        print(f"Failed to clean all mesh issues. {msg}")
    topo = ms.get_topological_measures()
    if not topo["is_mesh_two_manifold"]:
        issues += 1
        print("Failed to clean all mesh issues. Mesh is not manifold.")
    if topo["number_holes"] > 0:
        issues += 1
        print(f"Failed to clean all mesh issues. Mesh has {topo['number_holes']} holes.")
    ms.compute_selection_by_self_intersections_per_face()
    intersects = ms.current_mesh().selected_face_number()
    if intersects > 0:
        issues += 1
        print(f"Failed to clean all mesh issues. Mesh has {intersects} self-intersecting faces.")
    ms.compute_selection_bad_faces(usear=False, usenf=True, select_folded_faces=True)
    folds = ms.current_mesh().selected_face_number()
    if folds > 0:
        issues += 1
        print(f"Failed to clean all mesh issues. Mesh has {folds} folded faces.")
    if issues == 0:
        print("Mesh cleaned successfully.")
    return mesh

def get_hausdorff(mesh1, mesh2):
    ms = ml.MeshSet()
    ms.add_mesh(ml.Mesh(mesh1.V, mesh1.F))
    mesh1_id = ms.current_mesh_id()
    ms.add_mesh(ml.Mesh(mesh2.V, mesh2.F))
    mesh2_id = ms.current_mesh_id()
    dist12 = ms.get_hausdorff_distance(sampledmesh=mesh1_id, targetmesh=mesh2_id)
    dist21 = ms.get_hausdorff_distance(sampledmesh=mesh2_id, targetmesh=mesh1_id)
    haus_max = np.max([dist12['max'], dist21['max']])
    haus_mean = np.mean([dist12['mean'], dist21['mean']])
    return haus_max, haus_mean

def get_curvature(mesh):
    """
    Get concavity and convexity ratios of a mesh.
    Meshlab nicely turns these values into a heatmap that you can visualize
    where flat regions are green, concave regions are red, and convex regions are blue.
    Here we extract the curvature from these color values.
    Since we have RGB values for every vertex, we could simply sum and return all the
    reds and the blues, but we want hot red to add more to concavity value than orange-
    red or yellow. Thus we use the formula (red + (1 - green)) / 2 to get a concavity
    value between 0 and 1 where red=1, green=0 is 1; red=1, green=1 is 0.5; and red=0.5,
    green=1 is 0.25.
    """
    ms = ml.MeshSet()
    ms.add_mesh(ml.Mesh(mesh.V, mesh.F))
    ms.compute_curvature_principal_directions_per_vertex()
    curv_heatmap = ms.current_mesh().vertex_color_matrix()
    r = curv_heatmap[:, 0]
    g = curv_heatmap[:, 1]
    b = curv_heatmap[:, 2]
    concavity_per_vertex = (r + 1 - g) / 2
    total_convexity = (b + 1 - g) / 2
    concave_ratio = concavity_per_vertex.mean() # concavity per vertex / num_vertexes
    convex_ratio = total_convexity.mean()
    return concave_ratio, convex_ratio    

def read_mesh_from_file(filename):
    # Alternate implementation using meshio
    # import meshio
    # iomesh = meshio.read(filename)
    # V = iomesh.points[:,0:3] #Some formats include quality information in vertex matrix
    # F = iomesh.cells_dict['triangle']

    # Handle Faces.dat and Vertices.dat files
    if "faces.dat" in filename.lower():
        F_filename = filename
        V_filename = filename.lower().replace("faces.dat", "vertices.dat")
        if Path(V_filename).exists():
            return read_mesh_from_dat_files(F_filename, V_filename)

    ms = ml.MeshSet()
    # Read the file, with good error handling
    try:
        ms.load_new_mesh(filename)
    except(ml.PyMeshLabException) as e:
        if "File does not exist" in str(e):
            raise ValueError(f"'{filename}' was not found.") from e
        elif "Unknown format for load" in str(e):
            raise ValueError(f"File '{filename}' was not of any known mesh type.") from e
    F = ms.current_mesh().face_matrix()
    V = ms.current_mesh().vertex_matrix()
    if len(F) == 0 or len(V) == 0:
        raise ValueError(f"File '{filename}' was not of any known mesh type.")
    mesh = Mesh(F, V)
    return mesh

def write_mesh_to_file(mesh, filename):
    ms = ml.MeshSet()
    ms.add_mesh(ml.Mesh(mesh.V, mesh.F))
    ms.save_current_mesh(filename)

def read_mesh_from_dat_files(F_filename, V_filename, keep_mat_indexing=False):
    try:
        with open(F_filename) as f:
            faces = np.loadtxt(f)
    except(ValueError) as e:
        message = e.args[0]
        # If error is due to header on first line then skip it
        if "Wrong number of columns" in message:
            with open(F_filename) as f:
                faces = np.loadtxt(f, skiprows=1, dtype=int)
        else: 
            raise
    try:
        with open(V_filename) as f:
            vertices = np.loadtxt(f)
    except(ValueError) as e:
        message = e.args[0]
        # If error is due to header on first line then skip it
        if "Wrong number of columns" in message:
            with open(V_filename) as f:
                vertices = np.loadtxt(f, skiprows=1, dtype=float)
        else: 
            raise
    mesh = Mesh(faces, vertices)
    if not keep_mat_indexing:
        mesh = from_mat_indexing(mesh)
    return mesh

def write_mesh_to_dat_files(mesh, F_filename, V_filename):
    with open(F_filename, 'w') as f:
        f.write(f"{mesh.n_faces:10d}\n")
        for v1, v2, v3 in mesh.F.astype(int):
            f.write(f"{v1:10d} {v2:11d} {v3:11d}\n")
    with open(V_filename, 'w') as f:
        f.write(f"{mesh.n_vertices:10d}\n")
        for x, y, z in mesh.V.astype(float):
            f.write(f"{x:30.18f} {y:30.18f} {z:30.18f}\n")

def write_bem_files(mesh, filename, bem_scale, simplify_names=False):
    """
    Write a mesh to <filename>_faces.dat and <filename>_vertices.dat for use
    in BEM solver. Change from mm to m scale and change from 0-based to 1-based
    indexing.
    """
    # The BEM solver operates in meters as the unit scale. If the average edge length
    # is over 1, that indicates our mesh either currently in mm scale and we need to change
    # it, or the mesh has huge 1 meter long triangle edges and isn't suitable for BEM at all.
    edge_len = mesh.avg_edge_len()
    if edge_len > 1:
        print(f"Detected triangle edges of size {edge_len:.3f}. Assuming this is on mm scale and changing to meter scale.")
        mesh = change_scale(mesh, scale="mm_to_m")
    mesh = to_mat_indexing(mesh)
    # Prepare new filenames
    if simplify_names:
        orig_full_path = Path(filename)
        V_filename = orig_full_path.with_name("Vertices.dat")
        F_filename = orig_full_path.with_name("Faces.dat")
    else:
        V_filename = edit_filename(filename, suffix="vertices", extension=".dat")
        F_filename = edit_filename(filename, suffix="faces", extension=".dat")
    # Write the two .dat files
    write_mesh_to_dat_files(mesh, F_filename, V_filename)

def get_new_filename(filename, alg_descriptor):
    # Handle cases where we are working with faces.dat, vertices.dat file pairs
    if "faces.dat" in filename.lower():
        # Often these .dat pairs are simply named "Faces.dat" and "Vertices.dat"
        # We ultimately want to write out a "x.ply" file, so we need to construct a new name by removing "Faces" and adding the
        # folder name so it won't be blank.
        folder_name = Path(filename).parent.name
        filename = filename.lower().replace("faces.dat", f"{folder_name}.dat")
        return edit_filename(filename, suffix=alg_descriptor, extension=".ply")
    else:
        return edit_filename(filename, suffix=alg_descriptor)

def edit_filename(filename, suffix=None, prefix=None, extension=None):
    """
    Edit a filename by adding a prefix, a suffix, or changing the extension.
    """
    full_path = Path(filename)
    name = full_path.stem #the filename without extension
    ext = full_path.suffix
    if prefix:
        name = prefix + "_" + name
    if suffix:
        name = name + "_" + suffix
    if extension:
        ext = extension
    full_path = full_path.with_stem(name)
    full_path = full_path.with_suffix(ext)
    return str(full_path)

def change_scale(mesh, scale="mm_to_m"):
    mesh = mesh.copy()
    if scale == "mm_to_m":
        mesh.V = mesh.V / 1000
    elif scale == "m_to_mm":
        mesh.V = mesh.V * 1000
    else:
        raise ValueError(f"Scale must either be 'mm_to_m' or 'm_to_mm', but instead got '{scale}'")
    return mesh

def center_on_origin(mesh):
    mesh = mesh.copy()
    mesh.V = mesh.V - mesh.V.mean(axis=0)
    return mesh

def get_edge_len_from_faces(surface_area, target_num_faces, scale_factor=1.05):
    """
    Inverse of get_faces_from_edge_len(). scale_factor accounts for the fact that the
    triangles are not perfectly equilateral, so there are more total triangles than the
    formula for the area of an equilateral triangle represents. Choose a value between
    1.0 and 1.5, with 1.0 being a mesh with perfectly equilateral triangles. A good
    heuristic is to use 2.0 - Q, with Q being the expected Q value after remeshing.
    """
    target_num_faces = scale_factor * target_num_faces
    area_equilateral = surface_area / target_num_faces
    target_edge_len = np.sqrt((4 / np.sqrt(3) ) * area_equilateral)
    return target_edge_len

def get_faces_from_edge_len(surface_area, target_edge_len, scale_factor=1.15):
    """
    Get the estimated number of faces that goes with a desired edge length resolution.
    Quadratic edge collapse takes a number of faces as a target, and this allows us
    to get a good estimate for that number if we only know our desired edge length.
    Based on dividing the surface area by the formula for area of an equilateral
    triangle, combined with a scale factor because we know our triangles will typically
    be skinnier than that.

    The skinnier the triangles in the mesh, the larger the scale factor should be, with
    a value somewhere between 1.0 and 1.5. Use a scale factor of 1.0 for a uniform 
    equilateral triangle mesh.
    """
    area_equilateral = target_edge_len**2 * np.sqrt(3) / 4
    target_num_faces = surface_area / area_equilateral
    target_num_faces = scale_factor * target_num_faces
    return int(target_num_faces)


def plot_mesh(mesh):
    from .bindings import matlab as mat
    matlab_mesh = mesh.to_mat_indexing()
    mat.plotMesh(matlab_mesh.F, matlab_mesh.V)


def get_mesh_stats(mesh, comparison_mesh=None, run_haus=True, stats_dict=None, name="placeholder"):
    if run_haus and comparison_mesh:
        haus_max, haus_mean = get_hausdorff(mesh, comparison_mesh)
    else:
        haus_max = None
        haus_mean = None
    if stats_dict is None:
        Q_exp, AR_avg, min_angle, n_faces, avg_edge_len, is_correct, msg = get_stats_brief(mesh)
    else:
        Q, AR, AR_avg, AR_min, AR7, AR4, AR3, min_angle, valence, n_faces, avg_edge_len, concave, convex, total_curv, is_correct, msg = get_stats_full(mesh)
        stats_dict[name] = [n_faces, Q, AR_avg, AR_min, AR7, AR4, AR3, min_angle, valence, haus_max, haus_mean, concave, convex, total_curv, AR]
    stats = {}
    stats["AR_avg"] = AR_avg
    stats["haus_max"] = haus_max
    stats["avg_edge_len"] = avg_edge_len
    stats["n_faces"] = n_faces
    stats["min_angle"] = min_angle 
    stats["Q_exp"] = Q_exp 
    stats["is_correct"] = is_correct 
    stats["msg"] = msg
    return stats


def print_mesh_stats(stats, name="placeholder", file=sys.stdout, stats_dict=None, print_angle=True, print_jQ=False):
    AR_avg = stats["AR_avg"]
    haus_max = stats["haus_max"] 
    avg_edge_len = stats["avg_edge_len"] 
    n_faces = stats["n_faces"] 
    min_angle = stats["min_angle"]  
    Q_exp = stats["Q_exp"] 
    is_correct = stats["is_correct"] 
    msg = stats["msg"] 
    print(name, file=file)
    print(f"Q: {AR_avg:.3f}", file=file)
    if haus_max:
        print(f"Hausdorff: {haus_max:.3f} mm", file=file)
    print(f"Avg edge: {avg_edge_len:.3f} mm", file=file)
    print(f"Faces: {n_faces:,}", file=file)
    if print_angle:
        print(f"Min angle: {min_angle:.3g} deg", file=file)
    if print_jQ:
        print(f"Experimental Q: {Q_exp:.3f}", file=file)
    if not is_correct:
        print("Issues with mesh connectivity:", msg, file=file)
    print(file=file) # newline
    file.flush() # Force this to be written now instead of at the end of the program
    

def run_alg(func, orig_mesh, params, mesh_filename, alg_descriptor, outfile=sys.stdout, plot=True, force_rerun=False, to_bem=False, bem_scale=None, stats_dict=None, clean_flag=False, run_haus=True):
    new_filename = get_new_filename(mesh_filename, alg_descriptor)
    if Path(new_filename).exists() and not force_rerun:
        print(f"Recording stats for {new_filename} found on disk.")
        new_mesh = read_mesh_from_file(new_filename)
    else:
        try:
            new_mesh = func(orig_mesh, **params)
            write_mesh_to_file(new_mesh, new_filename)
        # Since we're calling 3rd party libraries we might get unknown exeptions. 
        # We want to log the message but continue with other algs/meshes.
        except(Exception) as e:
            print(f"Error in {func.__name__}(), '{alg_descriptor}': {type(e)} {e}")
            return None
    if plot:
        plot_mesh(new_mesh)
    if to_bem:
        write_bem_files(new_mesh, new_filename, bem_scale)
    stats = get_mesh_stats(new_mesh, orig_mesh, run_haus, stats_dict)
    if not stats["is_correct"] and clean_flag:
        print(f"Found the following issues: {stats['msg']}")
        new_mesh = clean_mesh(new_mesh)
        new_filename = edit_filename(new_filename, "cleaned")
        write_mesh_to_file(new_mesh, new_filename)
    print_mesh_stats(stats, name=new_filename, file=outfile)
    return new_mesh


@time_it # Print runtime information for all calls of this
def remesh_isotropic(mesh, target_edge_len=None, target_num_faces=None, iterations=9, checksurfdist=True, selectedonly=False, featuredeg=30):
    """
    MeshLab's implemention of Botsch & Kobbelt's local modifications with projection remeshing algorithm: https://dl.acm.org/doi/10.1145/1057432.1057457
    https://pymeshlab.readthedocs.io/en/latest/filter_list.html?highlight=isotropic#meshing_isotropic_explicit_remeshing

    checksurfdist=True is meshlab default
    """
    ms = ml.MeshSet()
    ms.add_mesh(ml.Mesh(mesh.V, mesh.F))
    if target_edge_len:
        targetlen=ml.AbsoluteValue(target_edge_len)
    elif target_num_faces:
        # Note that this will be skipped if both target_edge_len and target_num_faces are both provided
        geo_stats = ms.get_geometric_measures()
        area = geo_stats["surface_area"]
        target_edge_len = get_edge_len_from_faces(area, target_num_faces)
        targetlen=ml.AbsoluteValue(target_edge_len)
    else:
        # If no edge length is provided, use 1% of the bounding box diagonal as the target length (this is the meshlab default)
        targetlen=ml.Percentage(1)
    ms.meshing_isotropic_explicit_remeshing(targetlen=targetlen, iterations=iterations, checksurfdist=checksurfdist, selectedonly=selectedonly, featuredeg=featuredeg)
    F = ms.current_mesh().face_matrix()
    V = ms.current_mesh().vertex_matrix()
    new_mesh = Mesh(F, V)
    return new_mesh

@time_it # Print runtime information for all calls of this
def remesh_edgecollapse(mesh, target_edge_len=None, target_num_faces=None):
    ms = ml.MeshSet()
    ms.add_mesh(ml.Mesh(mesh.V, mesh.F))
    if target_edge_len:
        geo_stats = ms.get_geometric_measures()
        area = geo_stats["surface_area"]
        num_faces_desired = get_faces_from_edge_len(area, target_edge_len)
    elif target_num_faces:
        # Note that this will be skipped if both target_edge_len and target_num_faces are both provided
        num_faces_desired = int(target_num_faces)
    else:
        num_faces_desired = mesh.n_faces // 4
    # This parameter is supposed to retain more faces in flat regions in order to improve triangle quality 
    # in those areas. That is not what we want (we want to reduce faces with simplification algs and then
    # improve quality with another alg) and it is False by default, and yet I'm setting it to True here
    # because in practice it yielded identical meshes except in the case of the sphere where it prevented
    # massive artifacts.
    planar_simplify = True
    ms.meshing_decimation_quadric_edge_collapse(targetfacenum=num_faces_desired, planarquadric=planar_simplify)
    F = ms.current_mesh().face_matrix()
    V = ms.current_mesh().vertex_matrix()
    new_mesh = Mesh(F, V)
    return new_mesh

@time_it # Print runtime information for all calls of this
def remesh_optimesh(mesh, alg="CVT (full)"):
    # alg = "CVT (block-diagonal)"    # Uniform, Quasi-Newton iteration, block diagonal Hessian
    # alg = "CVT (diagonal)"          # Uniform, quasi-Newton iteration, diagonal Hessian
    # alg = "CVT (full)"              # Uniform, quasi-Newton iteration, full Hessian
    # alg = "lloyd"                   # Uniform, variant of CVT. Use with omega==2.0
    # alg = "ODT (fixed-point)"       # Uniform, fixed point iteration
    # alg = "ODT (bfgs)"              # Uniform, non-linear optimization
    # alg = "CPT (linear-solve)"      # Non-uniform 
    # alg = "CPT (fixed-point)"       # Uniform,  fixed point iteration
    # alg = "CPT (quasi-newton)"      # Uniform, quasi-Newton iteration
    # alg = "laplace"
    
    # Be sure to use copy() on any mesh input because optimesh corrupts the original mesh somehow      
    V, F = optimesh.optimize_points_cells(
        mesh.V.copy(), mesh.F.copy(), alg, 1.0e-2, 20
    )
    new_mesh = Mesh(F, V)
    return new_mesh

@time_it # Print runtime information for all calls of this
def remesh_cgal(mesh, target_edge_len, min_angle=25, max_distance=None, max_feat_edge=None, max_delaunay_rad=None):
    # Defaults:
    if not max_distance:                    # Controls general fidelity to original mesh
        max_distance = target_edge_len / 30
    if not max_feat_edge:                   # Controls fidelity at sharp features
        max_feat_edge = target_edge_len / 3
    if not max_delaunay_rad:
        max_delaunay_rad = target_edge_len * 3
    write_mesh_to_file(mesh, "temp.ply") # pygalmesh's api only supports reading mesh from disk
    mesh = pygalmesh.remesh_surface(
        "temp.ply",
        max_edge_size_at_feature_edges=max_feat_edge,
        max_radius_surface_delaunay_ball=max_delaunay_rad,
        max_facet_distance=max_distance,
        min_facet_angle=min_angle,
        verbose=True,
    )
    new_mesh = Mesh(mesh.cells_dict['triangle'], mesh.points)
    return new_mesh

@time_it # Print runtime information for all calls of this
def print_stats_only(mesh, filename):
    """
    A NOP placeholder function used when we have a mesh on file and we simply 
    want to print the stats for it and potentially run other admin tasks like 
    plotting or writing to BEM format.
    """
    new_mesh = read_mesh_from_file(filename)
    return new_mesh