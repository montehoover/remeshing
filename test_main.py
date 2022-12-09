import main
from src.python.helpers import get_config

# Simply run "pytest -s" from the command line to run these tests.
# It will find all files named test_*.py and run all functions named test_*().

def test_main():
    """
    All this does is run the equivalent of "python main.py --config config.yml" and it 
    passes the test if no exceptions are thrown.
    """
    completed = False
    
    # The equivalent of the code under 'if name == "__main__":'
    args = main.parse(["main.py", "-c=config.yml"])
    config = get_config(args)
    main.run(config)

    completed = True
    assert completed == True
