---
layout: single
author_profile: true
comments: false
title: Research snapshot 
classes: wide
permalink: /research/
header:
    overlay_image: /assets/images/galaxy.jpg
    overlay_filter: 0.25
gallery:
  - image_path: /assets/images/Mouse.gif
    title: "Image 2 title caption"
  - image_path: spike_control.png
    title: "Image 3 title caption"
---

Here is a highlight of some of the projects I have worked on over the past few years. The central theme being using optimization, statistical modeling, machine learning, control and dynamical sytems to gain a deeper understanding of neural circuits.

## Biophysically detailed models of single neurons
<img src="/assets/images/opt_graphical_abstract.png" height="350" width="350" align='right'> 
{: style="text-align: justify"}
Using morphology (diameter and length of digitally reconstructed segments) and electrophysiology (in-vitro recording of the membrane voltage under a standardized set of current protocols) data to constrain a multi-compartmental model of single neurons.

* Distribute a set of active conductances along the entire morphology (hence, called all-active models) and fit the maximal values for these conductances via a multi-objective optimization framework using evolutionary algorithms.

* Do the optmized conductances preserve information about the broader cell-type identity?

* Establish causal relationship between different modalities of data - are the ion channels indicative of the genetic signature of the underlying cell and how these channels affect electrophysiological properties e.g., shape of the action potential, Afterhyperpolarization(AHP).


## Simulate networks of neuron models to probe computational power, connectivity rules, and extracellular signature of cell classes
<img src="/assets/images/300_neurons.png" height="250" width="150" align='left'>

* Probe computational properties by simulating biophysically realisitic models of neurons and furthermore networks under synapses, resembling real physiological states. Can we classify neurons according to their computational bandwidth -  within species across regions, cross species in homologous regions?

* Examine efficacies of unique structural connectivity properties of specialized cells (**Chandelier**), as seen in the Electron Microscopy (EM) data, by simulating single neuron/networks under equivalent synapse configurations.

* Use experimental (in-vivo) and simulated extracellular signature of neurons along recording depth to link muti-modal data and furthermore infer cell-types.


## Control theoretic approach to design stimulation patterns for neural circuits
<p align="center">
<img src="/assets/images/Mouse.gif" height="250" width="320"> 

<img src="/assets/images/spike_control.png" height="400" width="500" hspace="10"> 
</p>
Neurocontrol : Leveraging control theoretic principles to systematically perturb neural circuits.

* Fit a point process generalized linear model to the neural spiking data and using this model to design exogenous stimulation for target spiking patterns in the underlying system.

* Apply systems and optimal control theory to design inputs for non-linear dynamical systems.

* A generative decision model hypothesis that explains the neural dynamics in experimental data for locust olfactory circuits.