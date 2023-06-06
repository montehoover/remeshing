# Remeshing

## Getting Started

### Installation:

1. Clone this repo:
    ```
    git clone https://gitlab.umiacs.umd.edu/pirl/remeshing.git`
    cd remeshing
    ```
2. Create conda environment. If needed install miniconda from https://docs.conda.io/en/latest/miniconda.html.
    ```
    conda env create -f environment.yml
    conda activate remeshing
    ```
3. Install matlab. If on a UMIACS machine, use the module utility:
    ```
    module add matlab
    ```
4. Build the "Matlab Engine for Python" module that we will import:  
    Linux:  
    ```
    $ which matlab
    /opt/common/matlab-r2015a/bin/matlab
    $ cd /opt/common/matlab-r2015a/extern/engines/python
    $ python setup.py install --prefix="$CONDA_PREFIX/lib/python3.9/site-packages"
    ```
    Windows:  
    ```
    $ where.exe matlab
    C:\Program Files\MATLAB\R2022a\bin\matlab.exe
    $ cd C:\Program Files\MATLAB\R2022a\extern\engines\python
    $ python setup.py install --prefix=$env:CONDA_PREFIX
    running install
    ...
    Installed c:\users\monte\miniconda3\envs\remeshing\lib\site-packages\matlabengineforpython-r2022a-py3.9.egg
    Processing dependencies for matlabengineforpython===R2022a
    Finished processing dependencies for matlabengineforpython===R2022a
    ```
### Running

Calling main.py from the command line with the sample data provided prints a brief set of statistics.
1. Activate virtual environment using conda:
   ```
   conda activate remeshing
   ```
2. Run main.py:
    ```
    $ python main.py --mesh data/demo_head.ply
    Processing data/demo_head.ply...
    Recording stats for data\demo_head.ply found on disk.
    data\demo_head.ply
    Q: 0.734
    Avg edge: 1.442 mm
    Faces: 165,522
    Min angle: 0.733 deg

    Successfully remeshed 1 meshes.
    ```

To process batches of meshes, list the file or folders to search for meshes in a yaml config file. An example is provided in config.yaml. Note that one of the example meshes contains folded faces that will be corrected and written to a new mesh file.
1. Run main.py with a yaml config file:
    ```
    $ python main.py --config config.yml 
    Processing data/demo_head.ply...
    Recording stats for data\demo_head.ply found on disk.
    Processing data/demo_head2.OBJ...
    Recording stats for data\demo_head2.OBJ found on disk.
    Found the following issues: Mesh passed basic correctness tests successfully. Found folded faces.
    Cleaning mesh...
    Mesh cleaned successfully.
    Results written to results.txt

    Successfully processed 2 meshes.
    ```

## Specifying remeshing algorithm

Specify one or more algorithms by adding a code snippet on [here in `main.py`](https://github.com/montehoover/remeshing/blob/2a9a7e5627c9e8f84a86192e89ab37f4076ab59c/main.py#L36). (Sorry for the awkward interface. Feel free to see [this issue](https://github.com/montehoover/remeshing/issues/2) and help fix it!)

The code snippet should be in the following format:

```python
alg_descriptor = "iso_2mm"
alg = remesh_isotropic
params = {"target_edge_len": 2.0, "iterations": 9}
new_mesh = run_alg(alg, original_mesh, params, filename, alg_descriptor, results_file, plot_flag, rerun_flag, bem_flag)
```

Here are the details:
`alg_descriptor` - user-provided string used for creating the filename for the modified mesh. It can be whatever you want.
`alg` - function name of one of the remeshing functions defined on [here in `helpers.py`](https://github.com/montehoover/remeshing/blob/2a9a7e5627c9e8f84a86192e89ab37f4076ab59c/src/python/helpers.py#L628). Details on all of the possible functions are below in [Remeshing algorithm options](#remeshing- algorithm-options).
`params` - parameters specific to the function as given in the function definition.
`new_mesh` - this line executes the above specifications and incorporates the options provided in config.yml. No need to change anything in this line.

## Remeshing algorithms
1. [`remesh_isotropic`](https://github.com/montehoover/remeshing/blob/2a9a7e5627c9e8f84a86192e89ab37f4076ab59c/src/python/helpers.py#L629):  
MeshLab's implemention of Botsch & Kobbelt's local modifications with projection remeshing algorithm. Strongly recommended as the default remeshing algorithm. In most cases it is both the fastest algorithm and yields the best mesh quality. Can specify either a target element size or a target number of elements. [Botsch & Kobbelt paper](https://dl.acm.org/doi/10.1145/1057432.1057457] [Meshlab documentation](https://pymeshlab.readthedocs.io/en/latest/filter_list.html?highlight=isotropic#meshing_isotropic_explicit_remeshing)

2. [`remesh_optimesh`](https://github.com/montehoover/remeshing/blob/2a9a7e5627c9e8f84a86192e89ab37f4076ab59c/src/python/helpers.py#L681):  
A series of delaunay-triangulation based approaches from https://github.com/meshpro/optimesh. (Update May 2023 - it looks like a free license might be necessary to run this now. I haven't tried it.)

3. 

## License

Copyright (c) 2022 Monte Hoover under MIT License. Work builds on mesh processing tools from Nail Gumerov and Jeremy Hu. Gptoolbox (https://github.com/alecjacobson/gptoolbox/) is used for file io in matlab.![image](https://github.com/montehoover/remeshing/assets/193172/a8045298-d665-49ae-bce4-2ff2b5b08544)
