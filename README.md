## Learning Temporal Context for Activity Recognition 

This repository contains algorithms and data that we used for our work on long-term temporal models for activity recognition, which we will present at the ECAI 2016 conference [[1](#references)].
With these codes and data, you should be able to reproduce experiments performed on the two datasets described in Section 5 of [[1](#references)].
The software is related to the Frequency Map Enhancement (FreMEn)[[2](#references)] method and the data are part of the datasets for long-term mobile robot autonomy ([DaLTeMoR](https://lcas.lincoln.ac.uk/owncloud/shared/datasets)) provided by the Lincoln Centre for Autonomous Systems ([LCAS](http://robots.lincoln.ac.uk)).

### How to compile and run 

The project uses standard libraries and we provide relevant Makefiles to compile it, so the only think you need to do is to go to the <b>src</b> folder an call `make`.
Now, to quickly test the method, call e.g.

`../bin/fremen ../data/aruba/ FN 5 15 0.2|grep Precision`

You should get 15 lines that show how the classification performed each day.
Each value contains the day, number of correct and incorrect classifications, classification precision etc.

The arguments in this example are as follows:

1. <b>../data/aruba</b> is the location of the dataset,
1. <b>FN</b> is selection of the spatio-temporal model. First letter determines temporal model (FreMEn) in this case and <b>N</b> means that <i>None</i> spatial context is used. See the code <i> main/fremen.cpp</i> for details.
1. <b>5</b> stands for order of the model - 5 periodics in the aforementioned example,
1. <b>15</b> is the number of days used in the experiment,  
1. <b>0.2</b> is the filename of the confusion matrix or the value of elements at the matrix diagonal, i.e. we used 0.2 for <i>weak</i> and 0.8 for <i>strong</i> in the experiments described in [1](reference).


### Datasets

Datasets are located in the `data` folder. Each dataset consists of 5 files 

1. <b>activity.min</b> contains the timelines of activities per minute, (e.g. 1440 lines of that file represent one day).
1. <b>activity.names</b> contains names of the activities so you know what are the ID's in the previous file mean. 
1. <b>locations.min</b> containes IDs of rooms where the person was. Again 1440 lines of that file represent one day.
1. <b>locations.names</b> provides room types of the rooms' IDs in <b>locations.min</b>. 

### Benchmark 

If it works OK, then you can try to reproduce our experiments.
You will need to have the `alglib` installed - simply invoke `sudo apt-get install libalglib-dev`
Go to the <i>eval_scripts</i> folder and call `make`.
This will create a small binary for statistical testing.

Then, running

1. ``./process_dataset.sh aruba``, processes the <i>aruba</i> dataset, see Section 5 of [[1](#references)].
1. ``./summarize_results.sh aruba``, performs statistical tests over the <i>aruba</i> dataset results calculated in the previous step and generates <i>aruba.pdf</i>, which provides comparison of the individual temporal models.
1. ``./process_dataset.sh witham`` and ``./summarize_results.sh witham`` does the same for the <i>witham</i> dataset.
1. ``./draw_results.sh``, processes the results of both <i>aruba</i> and <i>witham</i> and generates the figures (in <i>fig</i> format) used in the Section 5 of [[1](#references)].

### Conditions of use 

If you use the software for your research, please cite either [[2](#references)] (is you use FreMEn) or [[1](#references)] that describes FreMEn's application to activity recognition..
Since one of the datasets used is based on the [CASAS](http://ailab.wsu.edu/casas/) datasets, you should also cite the article [[3](#references)].

### References

1. C.Coppola, T.Krajnik, T.Duckett, N.Bellotto: <b>[](http://raw.githubusercontent.com/wiki/gestom/fremen/papers/fremen_2016_ECAI.pdf)</b> In proceedings of the European Conference on Artificial Intelligence  (ECAI), 2016. [[bibtex](http://raw.githubusercontent.com/wiki/gestom/fremen/papers/fremen_2016_ECAI.bib)]
1. T.Krajnik, J.P.Fentanes, G.Cielniak, C.Dondrup, T.Duckett: <b>[Spectral Analysis for Long-Term Robotic Mapping.](http://raw.githubusercontent.com/wiki/gestom/fremen/papers/fremen_2014_ICRA.pdf)</b> In proceedings of the IEEE International Conference on Robotics and Automation (ICRA), 2014. [[bibtex](http://raw.githubusercontent.com/wiki/gestom/fremen/papers/fremen_2014_ICRA.bib)]
1. D.J. Cook: <b>[Learning setting-generalized activity models for smart spaces.](http://eecs.wsu.edu/~cook/pubs/is10.pdf)</b> IEEE Intelligent Systems, 2012. [[bibtex](http://dblp.uni-trier.de/rec/bibtex/journals/expert/Cook12)]
