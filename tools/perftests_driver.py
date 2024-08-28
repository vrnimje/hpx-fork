#! /usr/bin/python3.9

import os
import sys
import json
import subprocess
import time

def run_command(command):
    print(f"Running command: {command}")
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    out, err = process.communicate()
    if err:
        print(f"Error running command: {err.decode('utf-8')}")
    return out.decode('utf-8')

def generate_plot(baseline, current, perftest_name):
    pass



def main():
    if len(sys.argv) < 2:
        print("Usage: perftests_driver.py [test_name] [commands ...]")
        sys.exit(1)
    command = ' '.join(sys.argv[2:])

    test_name = sys.argv[1].removesuffix("_perftest")
    current_dir = os.path.dirname(__file__)

    # Run command
    current_results = run_command(command)
    current_results_dir = os.path.join(current_dir, "perftests_results")
    if not os.path.exists(current_results_dir):
        os.mkdir(current_results_dir)
    current_results_file = os.path.join(current_results_dir, f"{test_name}.json")

    # Write results to file
    with open(current_results_file, 'w') as f:
        f.write(current_results)


    # Get baseline file
    baseline_dir = os.path.join(current_dir, "perftests_ci/perftest/references/lsu_default")
    baseline_file = os.path.join(baseline_dir, f"{test_name}.json")

    # Call perftests_plot.py
    plot_command = f"python3.9 {os.path.join(current_dir, 'perftests_plot.py')} {baseline_file} {current_results_file} {test_name}"
    plot_output = run_command(plot_command)
    print(plot_output)

    # TODO: Print cdash markup here

if __name__ == '__main__':
    main()
