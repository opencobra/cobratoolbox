function test_main
% TODO Check the directory
test_examples
test_sparse_to_csr
test_csr_to_sparse % should always come after sparse_to_csr
test_bipartite_matching
test_dfs
test_load_gaimc_graph
test_largest_component
test_examples

end
