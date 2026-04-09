  # Sanity                                                                                                                                                                      
  make sanity FSDB=1
                                                                                                                                                                                
  # Directed tests                                                                                                                                                              
  make run TESTNAME=deu_base_test CFG=../tb/cfg/directed_dt01.cfg FSDB=1                                                                                                        
  make run TESTNAME=deu_base_test CFG=../tb/cfg/directed_full_valid.cfg FSDB=1                                                                                                  
  make run TESTNAME=deu_base_test CFG=../tb/cfg/pipeline_timing.cfg FSDB=1                                                                                                      
                                                                                                                                                                                
  # Random tests                                                                                                                                                                
  make run TESTNAME=deu_random_test CFG=../tb/cfg/random_full.cfg FSDB=1                                                                                                        
  make run TESTNAME=deu_random_test CFG=../tb/cfg/random_vld_toggle.cfg FSDB=1   
