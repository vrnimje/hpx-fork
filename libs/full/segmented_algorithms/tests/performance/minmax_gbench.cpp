//  Copyright (c) 2016 Hartmut Kaiser
//
//  SPDX-License-Identifier: BSL-1.0
//  Distributed under the Boost Software License, Version 1.0. (See accompanying
//  file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

#include <hpx/config.hpp>
#if !defined(HPX_COMPUTE_DEVICE_CODE)
#include <hpx/hpx.hpp>
#include <hpx/hpx_init.hpp>

#include <hpx/include/parallel_generate.hpp>
#include <hpx/include/parallel_minmax.hpp>
#include <hpx/include/partitioned_vector.hpp>
#include <hpx/iostream.hpp>
#include <hpx/modules/timing.hpp>

#include <hpx/modules/program_options.hpp>

#include <cstddef>
#include <cstdint>
#include <iostream>
#include <random>
#include <string>
#include <vector>
#include <benchmark/benchmark.h>

///////////////////////////////////////////////////////////////////////////////
// Define the vector types to be used.
HPX_REGISTER_PARTITIONED_VECTOR(int)
unsigned int seed = (unsigned int) std::random_device{}();

///////////////////////////////////////////////////////////////////////////////
struct random_fill
{
    random_fill()
      : gen(seed)
      , dist(0, RAND_MAX)
    {
    }

    int operator()()
    {
        return dist(gen);
    }

    std::mt19937 gen;
    std::uniform_int_distribution<> dist;

    template <typename Archive>
    void serialize(Archive&, unsigned)
    {
    }
};

///////////////////////////////////////////////////////////////////////////////
void run_min_element_benchmark(benchmark::State &s, hpx::partitioned_vector<int> const& v)
{
    // invoke min
    for (auto _ : s)
    { 
        hpx::min_element(hpx::execution::par, v.begin(), v.end());
    }
}

// ///////////////////////////////////////////////////////////////////////////////
void run_max_element_benchmark(
    benchmark::State &s, hpx::partitioned_vector<int> const& v)
{
    for (auto _ : s)
    { 
        hpx::max_element(hpx::execution::par, v.begin(), v.end());
    }
}

// ///////////////////////////////////////////////////////////////////////////////
void run_minmax_element_benchmark(
    benchmark::State &s, hpx::partitioned_vector<int> const& v)
{
    for (auto _ : s)
    { 
        hpx::minmax_element(hpx::execution::par, v.begin(), v.end());
    }
}

///////////////////////////////////////////////////////////////////////////////
int hpx_main(hpx::program_options::variables_map& vm)
{
    if (hpx::get_locality_id() == 0)
    {
        // pull values from cmd
        std::size_t size = vm["vector_size"].as<std::size_t>();
        //bool csvoutput = vm.count("csv_output") != 0;
        int test_count = vm["test_count"].as<int>();

        // create as many partitions as we have localities
        hpx::partitioned_vector<int> v(
            size, hpx::container_layout(hpx::find_all_localities()));

        // initialize data
        hpx::generate(hpx::execution::par, v.begin(), v.end(), random_fill());

        benchmark::RegisterBenchmark("min_element", run_min_element_benchmark, v)->Unit(benchmark::kMillisecond)
                                                                                 ->DisplayAggregatesOnly(true)
                                                                                 ->Repetitions(test_count);

        benchmark::RegisterBenchmark("max_element", run_max_element_benchmark, v)->Unit(benchmark::kMillisecond)
                                                                                 ->DisplayAggregatesOnly(true)
                                                                                 ->Repetitions(test_count);

        benchmark::RegisterBenchmark("minmax_element", run_minmax_element_benchmark, v)->Unit(benchmark::kMillisecond)
                                                                                       ->DisplayAggregatesOnly(true)
                                                                                       ->Repetitions(test_count);

        // run benchmark
        // double time_minmax = run_minmax_element_benchmark(test_count, v);
        // double time_min = run_min_element_benchmark(test_count, v);
        // double time_max = run_max_element_benchmark(test_count, v);
        benchmark::RunSpecifiedBenchmarks();

        // if (csvoutput)
        // {
        //     std::cout << "minmax" << test_count << "," << time_minmax
        //               << std::endl;
        //     std::cout << "min" << test_count << "," << time_min << std::endl;
        //     std::cout << "max" << test_count << "," << time_max << std::endl;
        // }

        return hpx::finalize();
    }

    return 0;
}

int main(int argc, char** argv)
{
    // ::benchmark::Initialize(&argc, argv);
    
    std::srand((unsigned int) std::time(nullptr));

    // initialize program
    std::vector<std::string> const cfg = {
        "hpx.os_threads=all", "hpx.run_hpx_main!=1"};

    hpx::program_options::options_description cmdline(
        "usage: " HPX_APPLICATION_STRING " [options]");

    cmdline.add_options()("vector_size",
        hpx::program_options::value<std::size_t>()->default_value(1000),
        "size of vector (default: 1000)")("test_count",
        hpx::program_options::value<int>()->default_value(100),
        "number of tests to be averaged (default: 100)")(
        "csv_output", "print results in csv format")("seed,s",
        hpx::program_options::value<unsigned int>(),
        "the random number generator seed to use for this run");

    hpx::init_params init_args;
    init_args.desc_cmdline = cmdline;
    init_args.cfg = cfg;
    return hpx::init(argc, argv, init_args);
    return 0;
}
#endif
