# *freqmix*: Frequency mixing decomposer
This is the official repository of *freqmix*, a toolbox for decomposing frequency mixing within time-series signals. Originally purposed for neuroscientific data, e.g., EEG, LPF data) but is general to any time-series signal data. It examines harmonics, triplets and quadruplets.

<p align="center">
  <img src="doc/artwork/freqmix_workflow.png" width="800" />
</p>

Rhythmic neural oscillations underpin cognitive and motoric processes and regulate numerous activity-dependent cellular processes in the brain. In the presence of non-linearities, concurrent oscillatory signals can combine to generate novel oscillations, a process described as frequency mixing. It has not yet been determined whether frequency mixing occurs at the single neuron, nor the origin of frequency mixing in neural activity. Moreover, the presence of frequency mixing in human brain activity and whether it plays a functional role is still an open question.
Here, we introduce a mathematical framework to robustly identify frequency mixing interactions in noisy data using higher-order dependence tests on the instantaneous phase of frequency components.


## Installation

For users who are not familiar with MatLab and would like to use this code, we apologise that it isn't available in other languages. 

Please clone the repository and you can start straight away. and install any necessary requirements/dependencies as below.


## Requirements and dependencies

### Necessary
* MatLab
* Bioinformatics Toolbox

### Helpful
* Parallel processing Toolbox


## Main Work Flow

### 1. Load your data
### 2. Define your configuration
### 3. Run mixing
### 4. Run statistics
### 5. Run plotting



## Contributors

- Robert Peach, GitHub: `peach-lucien <https://github.com/peach-lucien>`_
- Charlotte Luff
- to add.

We are always on the look out for individuals that are interested in contributing to this open-source project. Even if you are just using *freqmix* and made some minor updates, we would be interested in your input. 

To contribute you just need to follow some simple steps:
1. Create a github account and sign-in.
2. Fork the hcga repository to your own github account. You can do this by clicking on the upper right Fork link.
3. Clone the forked repository to your local machine e.g. ```git clone https://github.com/your_user_name/freqmix.git```
4. Navigate to your local repository in the command terminal.
5. Add the original hcga repository as your upstream e.g. ```git remote add upstream https://github.com/barahona-research-group/freqmix.git```
6. Pull the latest changes by typing ```git pull upstream master```
7. Create a new branch with some name by typing ```git checkout -b BRANCH_NAME```
8. Make the changes to the code that you wanted to make.
9. Commit your changes with ``` git add -A ``` 
10. Stage your changes with ``` git commit -m "DESCRIPTION OF CHANGES"```
11. Push your changes by typing ```git push origin BRANCH_NAME```
12. Go back to the forked repository on the github website and begin the pull request by clicking the green compare and pull request button. 

Thanks for anyone and everyone that chooses to contribute on this project.



## Cite

Please cite our paper if you use this code in your own work:

```

The bibtex reference:

```

## Run example

In the example folder you can find various examples in the `examples/` directory:

* Example 1: 
* Example 2: 
* Example 3: 
* Example 4: 




## Our other available packages

If you are interested in trying our other packages, see the below list:
* [GDR](https://github.com/barahona-research-group/GDR) : Graph diffusion reclassification. A methodology for node classification using graph semi-supervised learning.
* [hcga](https://github.com/barahona-research-group/hcga) : Highly comparative graph analysis. A graph analysis toolbox that performs massive feature extraction from a set of graphs, and applies supervised classification methods.
* [MSC](https://github.com/barahona-research-group/MultiscaleCentrality) : MultiScale Centrality: A scale dependent metric of node centrality.
* [DynGDim](https://github.com/barahona-research-group/DynGDim) : Dynamic Graph Dimension: Computing the relative, local and global dimension of complex networks.
* [PyGenStability](https://github.com/barahona-research-group/PyGenStability) : Markov Stability: Computing the Markov Stability graph community detection algorithm in Python.
* [RMST](https://github.com/barahona-research-group/RMST) : Relaxed Minimum Spanning Tree: Computing the relaxed minimum spanning tree to sparsify networks whilst retaining dynamic structure.
* [StEP](https://github.com/barahona-research-group/StEP) :  Spatial-temporal Epidemiological Proximity: Characterising contact in disease outbreaks via a network model of spatial-temporal proximity.





