## Test template

A simple test template reads:
```

```

## Run the test locally on your machine

Please make sure that your test runs individually by typing after a fresh start:
```Matlab
initCobraToolbox
cd test/verifiedTests/<testFolder>/
<testName>
```

Please then verify that the test runs in the test suite by running:
```Matlab
testAll
```
Alternatively, you can run the test suite in the background by typing:
````sh
matlab -nodesktop -nosplash < test/testAll.m
````
