# ReconMap tutorial

This short tutorial will guide you through the necessary steps of accessing ReconMap programmaticaly.

---
## 1 - TSV file structure

In ReconMap it is possible to upload a simple tsv file as an overlay. Below there is a simple example where 5 reactions are specified, along with a thickness and a color for the edges.

```
# VERSION=1.0                                           						
# NAME= Example overlay name				
# DESCRIPTION= Here I add a small description to my overlay. This will be displayed in the ReconMap!						
entrez gene	uniprot	gene ontology	compartment	reactionIdentifier	lineWidth	color
                                                RE1519M	10	#6617B5
                                                RE1632R	10	#6617B5
                                                RE2147R	10	#6617B5
                                                RE2973R	10	#6617B5
                                                RE3627M	10	#6617B5
```

## 2 - MINERVA structure in MATLAB

In order to access remotely to ReconMap, the user has to be registered and add the details of the MINERVA instance where the map is running. Here is an example of how this structure works.


```matlab
minerva.minervaURL = 'http://address.to.minerva/minerva/galaxy.xhtml';
minerva.login = 'username';
minerva.password = 'password';
minerva.model = 'map_1';
```

This structure stores the URL of the minerva instance, the username and password, and finally the model we want to upload the overlay to (this is important as each instance can have several maps).

After this we can load the latest version of Recon from the VMH database (https://vmh.uni.lu/#download)

## 3 - Overlaying a flux distribution


```matlab
load('Recon2.v04.mat');
```

After loading the model we can now perform a normal FBA and get a flux distribution as a result. After this it is just a matter of utilizing the function *buildFluxDistLayout* and we are set!

> **NOTE**: If it is the first time using the CobraToolbox do not forget to initialize the CobraToolbox (*initCobraToolbox*)

For this function to work it is necessary to add the minerva structure we defindes earlier as an argument, the model we are optimizing (for the reaction identifiers), the FBA solution and finally a title for the overlay.


```matlab
FBAsolution = optimizeCbModel(modelR204, 'max');
buildFluxDistLayout(minerva, modelR204, FBAsolution, 'Flux distribution1')
```

If everything is correctly defined you should get the following message in the MATLAB prompt

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><body>
<form id="default_form" name="default_form" method="post" action="/minerva/galaxy.xhtml" enctype="application/x-www-form-urlencoded">
<input type="hidden" name="default_form" value="default_form" />

		<center><span id="default_form:status">OK</span>
		</center><input type="hidden" name="javax.faces.ViewState" id="javax.faces.ViewState" value="-6438394932709968941:-3468150282262329640" autocomplete="off" />
</form></body>
</html>
```

And now you can visualize your flux distributio overlaid in the network!

## 4 - Overlaying subsystems

Another possibility provided is to overlay subsystems of the model. That can be achieved using the function *generateSubsytemsLayout* with the minerva structure defined before, the model, the name of the subsystem and finally a color of choice.


```matlab
generateSubsytemsLayout(minerva, modelR204, 'Pyruvate metabolism', '#6617B5');
```

Alternatively, the user can also run the function *generateSubsystemLayouts* that will generate a layout for each found subsystem in the model.
