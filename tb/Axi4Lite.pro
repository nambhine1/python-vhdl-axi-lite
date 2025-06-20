TestSuite Test_axi4_register 

SetLogSignals true


analyze TestCtrl_e.vhd
analyze TbAxi4.vhd


#Testcases:

analyze TbAxi4_BasicReadWrite.vhd

simulate TbAxi4_BasicReadWrite