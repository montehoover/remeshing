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
    Note: on UMIACS machines I had to also use the build location option and then I had to do something manually. I can't remember exactly what I did, but it ended up working in the end.  

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

### License

Copyright (c) 2022 Monte Hoover under MIT License. Work builds on mesh processing tools from Nail Gumerov and Jeremy Hu. Gptoolbox (https://github.com/alecjacobson/gptoolbox/) is used for file io in matlab.
