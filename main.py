import argparse
import pickle

from src.python.helpers import *


def run(config):
    plot_flag = config["plot"]
    rerun_flag = config["force_rerun"]
    bem_flag = config["write_bem_files"]
    clean_flag = config["clean"]
    results_file = config["results_file"]
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
        
        # Open mesh file and print stats
        orig_edge_len = original_mesh.avg_edge_len()
        alg_descriptor = ""
        alg = print_stats_only
        params = {"filename": edit_filename(filename, alg_descriptor)}
        new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, results_file, plot_flag, rerun_flag, bem_flag, clean_flag=clean_flag, run_haus=False)

        #######################################
        # Enter any remeshing algorithms here
        #######################################

        # alg_descriptor = "iso_same"
        # alg = remesh_isotropic
        # params = {"target_num_faces": original_mesh.n_faces * 1.02, "iterations": 9}
        # new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, outfile, plot_flag, rerun_flag, bem_flag)

        # alg_descriptor = "iso_2mm"
        # alg = remesh_isotropic
        # params = {"target_edge_len": 2.0, "iterations": 9}
        # new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, results_file, plot_flag, rerun_flag, bem_flag)

        #######################################
        # End of algorithms
        #######################################

    if stats_dict:
        with open("results.pkl", "wb") as f:
            pickle.dump(stats_dict, f)
    print(f"Successfully processed {len(config['meshes'])} meshes.")
    if results_file.name != "<stdout>":
        print(f"Results written to {results_file.name}")
        results_file.close()
    if plot_flag:
        input("\nPress enter to close the plots...\n> ")
        print("Closing...")


if __name__ == "__main__":
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
    # parser.add_argument("-c", "--config", default="config.yml",
    #                     help="Run on a series of meshes and algs specified by a yaml config file.")
    if len(sys.argv) <= 1:
        # Print help message and exit
        parser.parse_args(["--help"])
    args = parser.parse_args()
    config = get_config(args)
    run(config)
