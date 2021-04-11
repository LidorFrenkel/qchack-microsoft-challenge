# Grover Insurance Seller
This project using Grover algorithm in order to show the most relevant people to try and sell them health insurance.

## Overview 
Let's take a look at an insurance company - a crowded room of workers calling random people in order to convince them to buy health insurance. Most of those random people probably will say 'No', so this worker just spent the last 10 minutes convincing a potential customer when it's actually was pretty obvious this user will say 'No'.

## Our Idea
We thought of creating a 'profile' for a potential customer, based on age, the number of children, salary, and health state, so we could contact only the most relevant people, which have the highest chance to actually buy insurance.
The characteristics are:
1) Age: more than 30.
2) Number of children: more than 2.
3) Salary: more than 30K a month.
4) Health state (on a scale of 1 to 10): more than 7.

If a user has 2 or more characteristics, he is a potential customer and we want to try and sell him health insurance.

## The algorithm 
Our algorithm has few stages:
* Getting as input a matrix that represents the characteristics of each user (In our case, we created the input matrix).
* Taking each parameter of the customer and determining whether his characteristics fit our 'profile' or not. 
* The last part is to run the Grover algorithm, which gets as input the mertix with the 'score' and gets one potential customer as output.
