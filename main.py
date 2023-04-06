import argparse
import pickle

from src.python.helpers import *


def run(config):
    plot_flag = config["plot"]
    rerun_flag = config["force_rerun"]
    bem_flag = config["write_bem_files"]
    clean_flag = config["clean"]
    results_file = config["results_file"]
    stats_flag = config["stats_flag"]
    stats_dict = {}
    for filename in config["meshes"]:
        print(f"Processing {filename}...")
        
        # Original mesh - read, plot, and print it's stats
        try:
            original_mesh = read_mesh_from_file(filename)
        except ValueError as e:
            # Tried to read non-mesh file. Can occur if iterating through heterogeneous file types, 
            # so simply print the message and continue with the next file
            print(e)
            continue
        
        # Just print stats
        alg_descriptor = ""
        alg = print_stats_only
        params = {"filename": edit_filename(filename, alg_descriptor)}
        new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, results_file, plot_flag, rerun_flag, bem_flag, stats_dict, stats_flag, clean_flag=clean_flag, run_haus=False)

        #######################################
        # Enter any remeshing algorithms here
        #######################################

        # alg_descriptor = "iso_same"
        # alg = remesh_isotropic
        # params = {"target_num_faces": original_mesh.n_faces * 1.02, "iterations": 9}
        # new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, results_file, plot_flag, rerun_flag, bem_flag, stats_dict, stats_flag, clean_flag=clean_flag, run_haus=True)

        # alg_descriptor = "iso_2mm"
        # alg = remesh_isotropic
        # params = {"target_edge_len": 2.0, "iterations": 9}
        # new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, results_file, plot_flag, rerun_flag, bem_flag, clean_flag=clean_flag, run_haus=True)

        # # alg_descriptor = "optimesh_CVT"
        # # alg = remesh_optimesh
        # # params = {"alg": "CVT (full)"}
        # # new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, results_file, plot_flag, rerun_flag, bem_flag, stats_dict, stats_flag, clean_flag=clean_flag, run_haus=True)

        # alg_descriptor = "optimesh_ODT"
        # alg = remesh_optimesh
        # params = {"alg": "ODT (fixed-point)"}
        # new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, results_file, plot_flag, rerun_flag, bem_flag, stats_dict, stats_flag, clean_flag=clean_flag, run_haus=True)

        # alg_descriptor = "optimesh_CPT"
        # alg = remesh_optimesh
        # params = {"alg": "CPT (linear-solve)"}
        # new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, results_file, plot_flag, rerun_flag, bem_flag, stats_dict, stats_flag, clean_flag=clean_flag, run_haus=True)

        # alg_descriptor = "cgal2"
        # alg = remesh_cgal
        # params = {"target_edge_len":  original_mesh.avg_edge_len(), "min_angle": 25, "max_distance": original_mesh.avg_edge_len() / 20}
        # new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, results_file, plot_flag, rerun_flag, bem_flag, stats_dict, stats_flag, clean_flag=clean_flag, run_haus=True)

        # # # Intended only for point clouds
        # # alg_descriptor = "poisson"
        # # alg = poisson_reconstruction
        # # params = {}
        # # new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, results_file, plot_flag, rerun_flag, bem_flag, clean_flag=clean_flag, run_haus=False)

        # # Print stats comparison between mesh listed in config.yml and another mesh with the same name and <alg_descriptor> added
        # alg_descriptor = "parametric"
        # alg = print_stats_only
        # params = {"filename": edit_filename(filename, alg_descriptor)}
        # new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, results_file, plot_flag, rerun_flag, bem_flag, stats_dict, stats_flag, clean_flag=clean_flag, run_haus=True)

        #######################################
        # End of algorithms
        #######################################

    if stats_flag:
        with open(config["stats_file"], "wb") as f:
            pickle.dump(stats_dict, f)
    print(f"Successfully processed {len(config['meshes'])} meshes.")
    if results_file.name != "<stdout>":
        print(f"Results written to {results_file.name}")
        results_file.close()
    if plot_flag:
        input("\nPress enter to close the plots...\n> ")
        print("Closing...")

def parse(argv):
    parser = argparse.ArgumentParser(
        description="""
                    Analyze a series of meshes with options for remeshing and repairing.
                    """)
    parser.add_argument(
        "-m", "--mesh", help="Triangle mesh file (.ply, .obj, etc.) to process.")
    parser.add_argument(
        "-a", "--alg", help="Remeshing algorithm to apply.")
    parser.add_argument("-c", "--config",
                        help="Run on a series of meshes and algs specified by a yaml config file.")
    if len(argv) <= 1:
        # Print help message and exit
        parser.parse_args(["--help"])
    # Normally you would just call parser.pars_args(), and by default this parses sys.argv[1:]
    args = parser.parse_args(argv[1:])
    return args

if __name__ == "__main__":
    args = parse(sys.argv)
    config = get_config(args)
    run(config)
