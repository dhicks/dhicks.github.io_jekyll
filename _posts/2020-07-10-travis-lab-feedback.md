---
layout: post
title: "Configuring Github and Travis-CI for Automated Lab Feedback"
---

Last summer, in anticipating for teaching for the first time since 2013, I started reading about [ungrading](https://www.insidehighered.com/news/2019/04/02/professors-reflections-their-experiences-ungrading-spark-renewed-interest-student), and somewhere (maybe even in that piece, I didn't check) read about a computer scientist who uses [continuous integration](https://en.wikipedia.org/wiki/Continuous_integration) (CI) to automatically give students feedback on their CS lab assignments.  Each lab assignment has well-specified goals, and the CI automated tests evaluate the students' solutions are correct.  These successes can simply be counted automatically, specifications-grading style, or the instructor can review the code after it's working for things like coding style and efficiency.  

This fall I'll be teaching a graduate methods course on data science.  This seems like a great course for implementing this CI approach.  But, I haven't used CI before, and [the tutorials for using Travis-CI with R](https://kieranhealy.org/blog/archives/2015/10/16/using-containerized-travis-ci-to-check-r-in-rmarkdown-files/) turned out to be unnecessarily complicated, not least because Travis-CI now has good support for R.  The purpose of this post is to briefly review how to set up Github and Travis-CI for automated lab feedback.  

This repo provides a template for each lab assignment:  <https://github.com/data-science-methods/lab-test>.  


# Basic lab workflow #

*This setup assumes a workflow for lab assignments where students clone a Github repository with instructions, data, etc.; complete the assignment in a single R script; that a working solution has deterministic values for variables with set names; and that students submit their work using a pull request.*  A different programming language (or multiple programming languages) will require different infrastructure for running unit tests.  Multiple R scripts (including more complex project structures) will require more articulated test files.  Writing unit tests for non-deterministic values will be quite a bit more complicated than the simple tests in the example.  


# Instructor: Account setup #

You'll only need to do these steps once.  

1. You'll need a Github account.  I went ahead and created a separate organization for my course, so that the course website and lab repos all live together.  But that's strictly unnecessary.  
2. You'll need a [Travis-CI](https://travis-ci.org) account, which you create using a Github login.  Travis-CI is free for working with public Github repositories.  
3. If you created a new organization for your course, make sure it shows up in your Travis-CI settings:  Click on your profile picture (upper-right corner), then Settings.   Look for the list of organizations on the left-hand column.  If it's not there, then at the bottom of that column you should see a link to "Review and add your authorized organizations."  

I *think* that's basically it.  Travis-CI should be able to see your public repositories.  


# Instructor: Repository setup #

You'll do these steps when you create each lab assignment.  

1. In the [template repo](https://github.com/data-science-methods/lab-test), click the green "Use this template" button (where the Clone button usually lives) to create a new repo for the lab.  
2. Clone the new repo to the machine where you work.  
3. Edit `lab.R` with the assignment instructions.  
4. **If you add any packages to the setup, add them to `DESCRIPTION` as well.** 
	- Travis-CI assumes that R repositories are packages.  It will automatically install dependencies, but only if all of the dependencies (including `testthat`) are listed in the `DESCRIPTION` file.  You don't need any of the usual package metadata; all you need are the list of `Imports`.  
5. For each problem in the assignment, write appropriate tests in `tests/test_lab.R`.  You write tests using `testthat` expectations:  <https://testthat.r-lib.org/reference/index.html>.  
6. If you changed any file names, make sure they're consistent across `lab.R`, `tests/test_lab.R`, and `.travis.yml` (it needs to know where to point `testthat::test_dir()`).  
7. Optional: Create a `solutions` branch.  Fill in solutions for each problem, and run `testthat::test_dir('tests')` to check that your instructions and tests work as expected.  Cherry-pick any corrections back to `master`. 
8. Push `master` back up to Github.  
9. In Travis-CI's Settings, find the lab repo and flip the switch to turn on CI.  (In my experience, it can take like 10 seconds for Travis-CI to see the new repo or a push/pull request to an active repo.) 
10. Optional: Push `solutions` up to ensure that Travis-CI is working as expected.  
	- Note that there doesn't appear to be a way to have a private branch of a public repo.  


# Student: Lab workflow #

The students will do these steps when they work on the lab assignment.  

1. Fork the lab assignment to their own account, then clone the fork to their working machine.  
2. Modify the yaml header for the lab assignment with their name and so on. 
3. Work in `lab.R` to complete the assignment, per instructions.  
4. **If any packages are added to the setup, add them to `DESCRIPTION` as well.**
5. At any point, run `testthat::test_dir('tests')` to get immediate feedback on their progress.  
6. At any point, submit a pull request to get automated feedback via Travis-CI.  
	- [Travis-CI docs on building pull requests](https://docs.travis-ci.com/user/pull-requests/)
7. Submit their work by submitting a final (passing) pull request.  
8. Optional: Use the RStudio knitr button (or `rmarkdown::render('lab.R')`) to generate a pretty HTML or PDF version of their completed assignment.  






