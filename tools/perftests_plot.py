import sys
import json
import matplotlib.pyplot as plt

if len(sys.argv) != 2:
    print("No input file detected!")
    print("Usage: python perftests_plot.py [benchmark_output_file_name]")
else:
    file_name = sys.argv[1]

    fptr = open(file_name, "r")
    contents = fptr.read()

    print(contents)

    # Create a json ob
    json_obj = json.loads(contents)

    test_names = []
    samples = []

    for test in json_obj["outputs"]:
        test_names.append(test["name"] + "," + test["executor"])
        samples.append(test["series"])

    fig = plt.figure()
    ax = fig.add_subplot()
    bp = ax.boxplot(samples)

    ax.set_xticklabels(test_names)

    plt.show()


    
    
