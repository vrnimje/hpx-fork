import sys
import json
import matplotlib.pyplot as plt

if len(sys.argv) != 3:
    print("Usage: python perftests_plot.py [path_to_first_result.json] [path_to_second_result.json]")
else:
    test_name = sys.argv[1]
    f1 = open(sys.argv[1], 'r')
    f2 = open(sys.argv[2], 'r')
    json_obj1 = json.loads(f1.read())
    json_obj2 = json.loads(f2.read())

    test_names = []
    samples = []

    for test1, test2 in zip(json_obj1["outputs"], json_obj2["outputs"]):
        if test1["name"] == test2["name"]:
            test_names.append(test1["name"] + " (current),\n" + test1["executor"])
            samples.append(test1["series"])
            test_names.append(test2["name"] + ",\n" + test2["executor"])
            samples.append(test2["series"])
        else:
            exit(1)

    fig = plt.figure(figsize=(20, 6))
    ax = fig.add_subplot()
    bp = ax.boxplot(samples, showfliers=False)
    plt.setp(ax.set_xticklabels(test_names), fontsize=7)
    # plt.show()
    plt.savefig("test.jpg")
    