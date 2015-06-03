# Predicting Popularity of NYTimes blogpost
### A Kaggle competition

This is a collection of IPython notebooks in Python for a Kaggle competition.

The task was to predict popularity (0,1) of ~ 2000 NYTime postings in December based on historical records
of ~ 7'000 articles from September-November of the same year.

The features given:
- Titles
- Abstract/text snippets
- Names of sections/subsections

The approaches tried:

- Feature engineering and feature selection:
    - bag of words on Title/Abstract (unigrams and bigrams)
    - filtering on statistical significance of 'important'/'not important' words (based on t-test 
    between popular/not popular groupings)
    - filtering out time-sensitive features by randomizing/regularizing/bagging/filtering for consistent importance  
    - entity name extraction (due to http://nbviewer.ipython.org/gist/mattsco/8dddf256244fb7d47d47 )

- Classification models:
    - GLM, including randomized GLM, with L1 and L2 penalties (a.k.a. Lasso and Ridge for classification)
    - SVM (mainly for regularization)
    - Random Forest and randomized Random Forest (Extra Trees Classifier)
    - Gradient Boosting Classifier  

Lessons learnt:
- All methods will overfit to training set, if features are too reach.
- Avoid duplication of features (multicollinearity).
- Entity names extraction was equal in performance to simple bag of words on title plus abstract
when duplication was removed.
- Use Extra Trees Classifier instead of vanilla plain Random Forest to make models more robust.
- GBM, even though very time consuming when tuning, did not show results superior to RF.

All the notebooks presented here are also available at
http://r-train.ru/tag/kaggle/
