
# ReconMap tutorial

This  tutorial will guide you through the necessary steps of accessing ReconMap.

## 1 - Request an account

To access ReconMap please follow the link: http://vmh.life/#mapnavigator.

To access the Overlay functionality you will need to create an user account. To do so, access the ADMIN area and request and account. We will  get back to you as soon as possible with your credentials.


<img src="http://vmh.uni.lu/resources/images/mapviewer/tutorial-1.png" width="500" alt="Request an account">

## 2 - Overlay Menu

When registered, you can login to your account and access the overlay menu.

> **NOTE**: After logging in get back to ReconMap by clicking the "Home" button on the top right of your screen.

From this menu it is possible to upload a text file (tab delimited) with a specific format described below.

<img src="http://vmh.uni.lu/resources/images/mapviewer/tutorial-2.PNG" width="200" alt="Overlay menu">

---
### 2.1 - TSV file structure

Below is a simple example where 5 reactions are specified, along with a thickness and a color for the edges.


```
# VERSION=1.0                                           						
# NAME=Duplicated reactions						
# DESCRIPTION=Reactions to curate						
entrez gene	uniprot	gene ontology	compartment	reactionIdentifier	lineWidth	color
                                                RE1519M	10	#6617B5
                                                RE1632R	10	#6617B5
                                                RE2147R	10	#6617B5
                                                RE2973R	10	#6617B5
                                                RE3627M	10	#6617B5
```

## 3 - Remote access to ReconMap

In order to access remotely to ReconMap, the user has to be registered and add the details of the MINERVA instance where the map is running. Here is an example of how this structure works.


```matlab
minerva.minervaURL = 'http://vmh.uni.lu/MapViewer/galaxy.xhtml';
minerva.login = 'username';
minerva.password = 'password';
minerva.map = 'ReconMap-2.01';
```

This structure stores the URL of the minerva instance, the username and password, and finally the model we want to upload the overlay to (this is important as each instance can have several maps).

After this we can load the latest version of Recon from the VMH database (https://vmh.uni.lu/#download)

### 3.1 - Overlaying a flux distribution


```matlab
load('path\to\model\Recon204.mat');
```

After loading the model we can now perform a normal FBA and get a flux distribution as a result. After this it is just a matter of utilizing the function *buildFluxDistLayout* and we are set!

> **NOTE**: If it is the first time using the CobraToolbox do not forget to initialize the CobraToolbox (*initCobraToolbox*)

For this function to work it is necessary to add the minerva structure we definded earlier as an argument, the model we are optimizing (for the reaction identifiers), the FBA solution and finally a title for the overlay.


```matlab
changeCobraSolver('glpk', 'LP');
FBAsolution = optimizeCbModel(model, 'max');
buildFluxDistLayout(minerva, model, FBAsolution, 'Flux distribution 1')
```

If everything is correctly defined you should get the following message in the MATLAB prompt. Thr function returns a structure with 2 values. In the first index it will display 1 if the overlay was successfully uploaded and 0 if not. The second index will contain a success or error message.

```
ans = 
    [1]    'Overlay was sucessfully sent t...'
```

And now you can visualize your flux distributio overlaid in the network!

### 3.2 - Overlaying subsystems

Another possibility provided is to overlay subsystems of the model. That can be achieved using the function *generateSubsytemsLayout* with the minerva structure defined before, the model, the name of the subsystem and finally a color of choice.


```matlab
generateSubsytemsLayout(minerva, modelR204, 'Pyruvate metabolism', '#6617B5');
```

Alternatively, the user can also run the function *generateSubsystemLayouts* that will generate a layout for each found subsystem in the model.
